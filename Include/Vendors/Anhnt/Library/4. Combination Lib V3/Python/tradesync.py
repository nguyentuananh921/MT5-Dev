import os
import re
import sqlite3
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path

import MetaTrader5 as mt5

# The trades of an account kept in one SQLite file, by Python, for every program that wants to look at them (the EAs only read it). Python reads
# the terminal itself, so nothing depends on which EA is attached: the file of an account is the common source of truth of the EAs of that account.
#   deals          every deal of the history, as the terminal gives it (all its fields) + x_bid / x_ask / x_spread: the tick of the moment of the deal
#   history_orders every order of the history, as the terminal gives it
#   positions      the positions open now;  pending_orders the pending orders now (each rewritten when it changes)
#   order_birth    what Python saw the first time an order or position existed: when, the bid, the ask
#   order_events   each change of a live order or position (Stop Loss, Take Profit, price, type, volume), with the tick of that moment
#   position_summary (view) one line for each way out of a position: when it was opened and closed, the bid, the ask and the spread of each
# Columns come from the fields of the terminal, so a field it gets later is a column of its own. A line is written by its ticket: a line
# read again changes nothing, and an x_* value is never erased by a missing one.

SCHEMA = 1
SPREAD_DAYS = 14        # a deal older than this has no tick to look for
BIRTH_LATE_MS = 5000    # an order seen later than this after it was placed (Python was off): its tick is looked for at the time it was placed
TICK_WINDOW_S = 3       # seconds before the moment a tick is looked for
BACKFILL_PER_POLL = 5   # deals whose spread is looked for at each poll
HISTORY_MARGIN_S = 86400
RENAMES = {"order": "order_ticket"}   # "order" is a word of SQL

POSITION_VIEW = """CREATE VIEW position_summary AS
SELECT i.position_id AS position_id, i.symbol AS symbol,
       CASE i.type WHEN 0 THEN 'BUY' WHEN 1 THEN 'SELL' ELSE CAST(i.type AS TEXT) END AS side, i.volume AS volume,
       i.ticket AS open_ticket, strftime('%Y-%m-%d %H:%M:%f', i.time_msc / 1000.0, 'unixepoch') AS open_time, i.price AS open_price,
       i.x_bid AS open_bid, i.x_ask AS open_ask, NULLIF(i.x_spread, -1) AS open_spread,
       CASE i.reason WHEN 0 THEN 'CLIENT' WHEN 1 THEN 'MOBILE' WHEN 2 THEN 'WEB' WHEN 3 THEN 'EXPERT' WHEN 4 THEN 'SL' WHEN 5 THEN 'TP' WHEN 6 THEN 'SO' ELSE CAST(i.reason AS TEXT) END AS open_source,
       o.ticket AS close_ticket, strftime('%Y-%m-%d %H:%M:%f', o.time_msc / 1000.0, 'unixepoch') AS close_time, o.price AS close_price,
       o.x_bid AS close_bid, o.x_ask AS close_ask, NULLIF(o.x_spread, -1) AS close_spread,
       CASE o.reason WHEN 0 THEN 'CLIENT' WHEN 1 THEN 'MOBILE' WHEN 2 THEN 'WEB' WHEN 3 THEN 'EXPERT' WHEN 4 THEN 'SL' WHEN 5 THEN 'TP' WHEN 6 THEN 'SO' ELSE CAST(o.reason AS TEXT) END AS close_source,
       (SELECT SUM(d.profit + d.commission + d.swap) FROM deals d WHERE d.position_id = i.position_id AND d.type IN (0, 1)) AS net
FROM deals i LEFT JOIN deals o ON o.position_id = i.position_id AND o.entry IN (1, 3) AND o.type IN (0, 1)
WHERE i.entry = 0 AND i.type IN (0, 1)"""

CHANGE_FIELDS = ("sl", "tp", "price_open", "type", "volume")


def safe(text):
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", str(text)).strip("_") or "account"


def utc(seconds):
    return datetime.fromtimestamp(seconds, tz=timezone.utc)


def kind_of(value, name=""):
    if name.startswith("x_"):
        return "REAL"   # the extra columns start empty
    return "INTEGER" if isinstance(value, (int, bool)) else "REAL" if isinstance(value, float) else "TEXT"


def row_of(item):
    """A terminal object as a dict, with the words of SQL renamed."""
    return {RENAMES.get(key, key): value for key, value in item._asdict().items()}


def database_path(info):
    base = Path(os.environ["TRADESYNC_DIR"]) if os.environ.get("TRADESYNC_DIR") else Path(mt5.terminal_info().data_path) / "MQL5" / "Files" / "EA LibV3" / "Trade History"
    return base / f"{safe(info.server)}_{int(info.login)}.sqlite3"


class TradeSync:
    def __init__(self):
        self.login = None
        self.server = None
        self.db = None
        self.columns = {}        # table -> the columns it has
        self.live = {}           # ("P" or "O", ticket) -> the fields of what is open now
        self.totals = (-1, -1)   # (deals, orders) in the history at the last look
        self.spread_done = False

    # ------------------------------------------------------------ the file
    def open(self, info):
        self.close()
        path = database_path(info)
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():   # a file of the first layout (a table `orders` by status) is put aside, not deleted
            try:
                probe = sqlite3.connect(str(path))
                stale = probe.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name='orders'").fetchone() is not None
                probe.close()
            except sqlite3.Error:
                stale = False
            if stale:
                aside = path.with_name(path.stem + ".before_tradesync")
                for suffix in ("", "-wal", "-shm"):
                    source = Path(str(path) + suffix)
                    if source.exists():
                        os.replace(source, Path(str(aside) + ".sqlite3" + suffix))
                print(f"trade database of the first layout put aside: {aside}.sqlite3")
        self.db = sqlite3.connect(str(path), timeout=5.0)
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("PRAGMA busy_timeout=5000")
        self.db.execute("CREATE TABLE IF NOT EXISTS order_birth (ticket INTEGER PRIMARY KEY, kind TEXT, position_id INTEGER, symbol TEXT, magic INTEGER, type INTEGER, "
                        "time_msc INTEGER, late INTEGER, bid REAL, ask REAL, spread REAL, price REAL, sl REAL, tp REAL, volume REAL)")
        self.db.execute("CREATE TABLE IF NOT EXISTS order_events (id INTEGER PRIMARY KEY AUTOINCREMENT, time_msc INTEGER, ticket INTEGER, symbol TEXT, magic INTEGER, "
                        "kind TEXT, change TEXT, type INTEGER, type_prev INTEGER, price REAL, price_prev REAL, sl REAL, sl_prev REAL, tp REAL, tp_prev REAL, "
                        "volume REAL, volume_prev REAL, bid REAL, ask REAL, spread REAL)")
        self.db.execute("CREATE UNIQUE INDEX IF NOT EXISTS order_events_once ON order_events(ticket, change, type_prev, type, price_prev, price, sl_prev, sl, tp_prev, tp, volume_prev, volume)")
        self.columns = {}
        for table in ("deals", "history_orders", "positions", "pending_orders"):
            self.columns[table] = {row[1] for row in self.db.execute(f"PRAGMA table_info({table})")}
        self.db.commit()
        self.login, self.server = info.login, info.server
        self.live = {}
        self.totals = (-1, -1)
        self.spread_done = False
        print(f"trade database of {info.server} {info.login}: {path}")

    def close(self):
        if self.db is not None:
            try:
                self.db.commit()
                self.db.close()
            except sqlite3.Error:
                pass
        self.db = None

    def ensure(self, table, row, key):
        """The table with a column for every field of this row (made when it is not there)."""
        have = self.columns.get(table, set())
        if not have:
            fields = ", ".join(f"{name} {kind_of(value, name)}" + (" PRIMARY KEY" if name == key else "") for name, value in row.items())
            self.db.execute(f"CREATE TABLE IF NOT EXISTS {table} ({fields})")
            have = {r[1] for r in self.db.execute(f"PRAGMA table_info({table})")}
        for name, value in row.items():
            if name not in have:
                self.db.execute(f"ALTER TABLE {table} ADD COLUMN {name} {kind_of(value, name)}")
                have.add(name)
        self.columns[table] = have

    def upsert(self, table, rows, key="ticket", keep=()):
        """Lines written by their key; the columns in keep are not erased by a missing value."""
        if not rows:
            return
        self.ensure(table, rows[0], key)
        names = list(rows[0])
        updates = ", ".join(f"{n}=COALESCE(excluded.{n},{table}.{n})" if n in keep else f"{n}=excluded.{n}" for n in names if n != key)
        sql = f"INSERT INTO {table} ({', '.join(names)}) VALUES ({', '.join('?' * len(names))}) ON CONFLICT({key}) DO UPDATE SET {updates}"
        self.db.executemany(sql, [[row.get(n) for n in names] for row in rows])

    def make_view(self):
        have = self.columns.get("deals", set())
        if {"position_id", "entry", "x_bid", "x_ask", "x_spread", "time_msc", "price", "reason", "type", "volume", "profit", "commission", "swap", "symbol"} <= have:
            self.db.execute("DROP VIEW IF EXISTS position_summary")
            self.db.execute(POSITION_VIEW)

    # ------------------------------------------------------------ the tick of a moment
    def tick_at(self, symbol, time_msc):
        """(bid, ask) of the last tick at or before time_msc that has both, None when the terminal has none."""
        start = utc(time_msc / 1000.0 - TICK_WINDOW_S)
        end = utc(time_msc / 1000.0 + 1)
        ticks = mt5.copy_ticks_range(symbol, start, end, mt5.COPY_TICKS_INFO)
        if ticks is None or len(ticks) == 0:
            return None
        for tick in ticks[::-1]:
            if int(tick["time_msc"]) <= time_msc and tick["bid"] > 0 and tick["ask"] > 0:
                return float(tick["bid"]), float(tick["ask"])
        return None

    def spread_of(self, symbol, bid, ask):
        info = mt5.symbol_info(symbol)
        return (ask - bid) / info.point if info is not None and info.point > 0 else None

    # ------------------------------------------------------------ the history
    def sync_history(self):
        """Deals and orders of the history, when the terminal says their number changed: all of it the first time, then from a day before the newest."""
        now = datetime.now(timezone.utc) + timedelta(days=2)
        first = utc(0)
        totals = (mt5.history_deals_total(first, now), mt5.history_orders_total(first, now))
        if None in totals or totals == self.totals:
            return
        newest = self.db.execute("SELECT MAX(time) FROM deals").fetchone()[0] if "deals" in self.columns and self.columns["deals"] else None
        start = first if self.totals == (-1, -1) and not newest else utc(max((newest or 0) - HISTORY_MARGIN_S, 0))
        deals = mt5.history_deals_get(start, now)
        orders = mt5.history_orders_get(start, now)
        if deals is None or orders is None:
            return
        if start == first and (len(deals), len(orders)) != totals:   # the terminal gave less than it counted (not loaded yet): look again at the next round
            return
        self.db.execute("BEGIN")
        self.upsert("deals", [row_of(d) | {"x_bid": None, "x_ask": None, "x_spread": None} for d in deals], keep=("x_bid", "x_ask", "x_spread"))
        self.upsert("history_orders", [row_of(o) for o in orders])
        self.fill_extra()
        self.make_view()
        self.db.commit()
        self.totals = totals
        self.spread_done = False
        print(f"trade history: {len(deals)} deal(s), {len(orders)} order(s) written")

    def fill_extra(self):
        """The bid, the ask and the spread of the moment an order was first seen go to the deals of that order that have none."""
        if "x_bid" not in self.columns.get("deals", set()):
            return
        self.db.execute("UPDATE deals SET x_bid=(SELECT bid FROM order_birth b WHERE b.ticket=deals.order_ticket), x_ask=(SELECT ask FROM order_birth b WHERE b.ticket=deals.order_ticket), "
                        "x_spread=(SELECT spread FROM order_birth b WHERE b.ticket=deals.order_ticket) WHERE x_bid IS NULL AND x_spread IS NULL AND "
                        "EXISTS (SELECT 1 FROM order_birth b WHERE b.ticket=deals.order_ticket AND b.spread IS NOT NULL)")

    def backfill_spreads(self, limit=BACKFILL_PER_POLL):
        """A few deals at a time, newest first: the tick of their time. -1 = the terminal has no tick for it, not looked for again."""
        if self.spread_done or "x_spread" not in self.columns.get("deals", set()):
            return
        since = int((time.time() - SPREAD_DAYS * 86400) * 1000)
        rows = self.db.execute("SELECT ticket, symbol, time_msc FROM deals WHERE x_spread IS NULL AND type IN (0, 1) AND time_msc > ? ORDER BY time_msc DESC LIMIT ?", (since, limit)).fetchall()
        if not rows:
            self.spread_done = True
            return
        for ticket, symbol, time_msc in rows:
            tick = self.tick_at(symbol, time_msc)
            spread = self.spread_of(symbol, *tick) if tick else None
            if tick and spread is not None:
                self.db.execute("UPDATE deals SET x_bid=?, x_ask=?, x_spread=? WHERE ticket=?", (tick[0], tick[1], spread, ticket))
            else:
                self.db.execute("UPDATE deals SET x_spread=-1 WHERE ticket=?", (ticket,))
        self.db.commit()

    # ------------------------------------------------------------ what is open now
    def birth(self, kind, row):
        """The first time an order or position is seen: the last tick, or the tick of its placement time when it was placed long before."""
        placed = int(row.get("time_setup_msc") or row.get("time_msc") or 0)
        symbol = row["symbol"]
        late = placed > 0 and time.time() * 1000 - placed > BIRTH_LATE_MS
        tick = self.tick_at(symbol, placed) if late else None
        if not late:
            last = mt5.symbol_info_tick(symbol)
            tick = (float(last.bid), float(last.ask)) if last is not None and last.bid > 0 and last.ask > 0 else None
        spread = self.spread_of(symbol, *tick) if tick else None
        self.db.execute("INSERT OR IGNORE INTO order_birth (ticket, kind, position_id, symbol, magic, type, time_msc, late, bid, ask, spread, price, sl, tp, volume) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                        (row["ticket"], kind, row.get("identifier") or row.get("position_id"), symbol, row.get("magic"), row.get("type"), placed, int(late),
                         tick[0] if tick else None, tick[1] if tick else None, spread, row.get("price_open"), row.get("sl"), row.get("tp"),
                         row.get("volume") if kind == "P" else row.get("volume_initial")))

    def event(self, kind, before, now):
        changed = [name for name in CHANGE_FIELDS if before.get(name) != now.get(name)]
        if not changed:
            return
        last = mt5.symbol_info_tick(now["symbol"])
        bid, ask = (float(last.bid), float(last.ask)) if last is not None else (None, None)
        time_msc = int(last.time_msc) if last is not None and last.time_msc else int(time.time() * 1000)
        spread = self.spread_of(now["symbol"], bid, ask) if bid and ask else None
        self.db.execute("INSERT OR IGNORE INTO order_events (time_msc, ticket, symbol, magic, kind, change, type, type_prev, price, price_prev, sl, sl_prev, tp, tp_prev, volume, volume_prev, bid, ask, spread) "
                        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                        (time_msc, now["ticket"], now["symbol"], now.get("magic"), kind, "+".join(n.upper() for n in changed), now.get("type"), before.get("type"),
                         now.get("price_open"), before.get("price_open"), now.get("sl"), before.get("sl"), now.get("tp"), before.get("tp"),
                         now.get("volume"), before.get("volume")))

    def sync_live(self, positions=None, orders=None):
        positions = mt5.positions_get() if positions is None else positions
        orders = mt5.orders_get() if orders is None else orders
        if positions is None or orders is None:
            return
        current = {("P", p["ticket"]): p for p in (row_of(x) if not isinstance(x, dict) else x for x in positions)}
        current.update({("O", o["ticket"]): o for o in (row_of(x) if not isinstance(x, dict) else x for x in orders)})
        first_look = not self.live and self.totals != (-1, -1) and not hasattr(self, "_seen_live")
        changed = False
        for key, row in current.items():
            if key not in self.live:
                self.birth(key[0], row)
                changed = True
            else:
                before = self.live[key]
                if any(before.get(n) != row.get(n) for n in row if n in ("sl", "tp", "price_open", "type", "volume", "price_current", "swap", "profit")):
                    changed = True
                if any(before.get(n) != row.get(n) for n in CHANGE_FIELDS):
                    self.event(key[0], before, row)
        if set(self.live) - set(current):
            changed = True
        self._seen_live = True
        self.live = current
        if changed:
            self.db.execute("BEGIN")
            self.db.execute("DELETE FROM positions") if "positions" in self.columns and self.columns["positions"] else None
            self.db.execute("DELETE FROM pending_orders") if "pending_orders" in self.columns and self.columns["pending_orders"] else None
            self.upsert("positions", [r for (k, _), r in current.items() if k == "P"])
            self.upsert("pending_orders", [r for (k, _), r in current.items() if k == "O"])
            self.fill_extra()
            self.db.commit()

    # ------------------------------------------------------------ one round
    def poll(self):
        """Called by the server on its rhythm: cheap when nothing changed (a few calls to the terminal)."""
        info = mt5.account_info()
        if info is None:
            return
        if info.login != self.login or info.server != self.server:   # the terminal is logged in to another account: its own file
            self.open(info)
        self.sync_history()
        self.sync_live()
        self.backfill_spreads()
