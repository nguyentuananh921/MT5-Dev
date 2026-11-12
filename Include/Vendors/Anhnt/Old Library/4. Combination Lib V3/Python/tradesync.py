import os
import re
import sqlite3
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path

import MetaTrader5 as mt5

from libdb import safe, account_key, database_path as library_path

# The trades of the accounts kept in the database of the library (libdb.py: SQLite\EA LibV3_Common.sqlite3), written by Python, for every program that wants to look
# at them (the EAs read it, and may write to it too): every line carries the account_key of its account, the key of a table starts with it. The columns are the properties of the library's COrder (Entities/Defines/TradingDefines.mqh), under the same names
# in lower case, one line for each order, deal or position of the terminal:
#   orders         status (ENUM_ORDER_STATUS: 0 pending now, 2 position now, 3 history order, 4 history pending, 5 balance, 6 deal) + ticket is the key;
#                  bid and ask are the tick of the open time of a deal (the terminal does not give them); the spread is (ask - bid) / point, not kept
#   orders         maps to the library class COrder (Entities/Trading/Order.mqh)
#   TradeEvent     maps to the library class CTradeEvent (Entities/Trading/TradeEvent.mqh); the schema of each table says its class (DDL). The columns are the
#                  properties of CTradeEvent (ENUM_EVENT_PROP_*). Python writes what it sees first-hand while it runs: a pending order placed, a position opened,
#                  a change of Stop Loss, Take Profit or the price of an order (with the prices before it), a StopLimit order triggered, with the bid and the ask
#                  of that moment; the rest of the properties stay NULL (closings, partial closings, reversals, balance operations come from the EA)
#   sync_state     what was saved and by whom ("history" = saved until this time in milliseconds): the program that goes on reads it and goes on from there
#   position_summary (view) one line for each way out of a position: when it was opened and closed, the bid, the ask and the spread of each
# What the library calculates from the others (direction, profit in points, the ids inside the magic number...) has no column. A line is written by its
# key: a line read again changes nothing, and a bid or an ask is never erased by a missing one.

SCHEMA = 3
IMPORTED = "imported_trade_history"   # sync_state key of an account whose old file (Trade History folder, one file for each account) was copied here
BIRTH_LATE_MS = 5000    # an order seen later than this after it was placed (Python was off): its tick is looked for at the time it was placed
TICK_WINDOW_S = 3       # seconds before the moment a tick is looked for
BACKFILL_PER_POLL = 10  # deals whose tick is looked for at each poll
HISTORY_MARGIN_S = 86400

# ENUM_ORDER_STATUS of the library
ST_MARKET_PENDING, ST_MARKET_POSITION, ST_HISTORY_ORDER, ST_HISTORY_PENDING, ST_BALANCE, ST_DEAL = 0, 2, 3, 4, 5, 6

# The columns of orders and TradeEvent are the properties of COrder (ENUM_ORDER_PROP_* in Entities/Defines/TradingDefines.mqh), one column for each,
# in the order of that enum, named as the property in lower case without ORDER_PROP_. Every column below says its property.
#   Not stored (the library calculates them from the others): TICKET_FROM, TICKET_TO, PROFIT_PT, CLOSE_BY_SL, CLOSE_BY_TP, MAGIC_ID, GROUP_ID1, GROUP_ID2,
#   PEND_REQ_ID, DIRECTION, PRICE_CLOSE, PROFIT_FULL, COMMENT_EXT, and SYMBOL: the name the account gives the symbol comes back through symbol_account.
#   symbol_id is ORDER_PROP_SYMBOL_ID (OUR symbol). A line whose symbol is not joined to one of ours yet is not written: the symbol goes to symbol_account
#   for the user to join, and the history is read again. The only column COrder has no property for: account_key (COrder knows one account).
#   The key is account_key + status + ticket.
COLUMN_TYPES = (
    ("ticket", "INTEGER NOT NULL", "ORDER_PROP_TICKET"), ("magic", "INTEGER", "ORDER_PROP_MAGIC"), ("time_open", "INTEGER", "ORDER_PROP_TIME_OPEN"),
    ("time_close", "INTEGER", "ORDER_PROP_TIME_CLOSE"), ("time_exp", "INTEGER", "ORDER_PROP_TIME_EXP"), ("type_filling", "INTEGER", "ORDER_PROP_TYPE_FILLING"),
    ("type_time", "INTEGER", "ORDER_PROP_TYPE_TIME"), ("status", "INTEGER NOT NULL", "ORDER_PROP_STATUS"), ("type", "INTEGER", "ORDER_PROP_TYPE"),
    ("reason", "INTEGER", "ORDER_PROP_REASON"), ("state", "INTEGER", "ORDER_PROP_STATE"), ("position_id", "INTEGER", "ORDER_PROP_POSITION_ID"),
    ("position_by_id", "INTEGER", "ORDER_PROP_POSITION_BY_ID"), ("deal_order_ticket", "INTEGER", "ORDER_PROP_DEAL_ORDER_TICKET"),
    ("deal_entry", "INTEGER", "ORDER_PROP_DEAL_ENTRY"), ("time_update", "INTEGER", "ORDER_PROP_TIME_UPDATE"),
    ("symbol_id", "INTEGER REFERENCES symbols (id)", "ORDER_PROP_SYMBOL_ID"),
    ("price_open", "REAL", "ORDER_PROP_PRICE_OPEN"), ("sl", "REAL", "ORDER_PROP_SL"), ("tp", "REAL", "ORDER_PROP_TP"), ("fee", "REAL", "ORDER_PROP_FEE"),
    ("profit", "REAL", "ORDER_PROP_PROFIT"), ("commission", "REAL", "ORDER_PROP_COMMISSION"), ("swap", "REAL", "ORDER_PROP_SWAP"),
    ("volume", "REAL", "ORDER_PROP_VOLUME"), ("volume_current", "REAL", "ORDER_PROP_VOLUME_CURRENT"), ("price_stop_limit", "REAL", "ORDER_PROP_PRICE_STOP_LIMIT"),
    ("bid", "REAL", "ORDER_PROP_BID"), ("ask", "REAL", "ORDER_PROP_ASK"),
    ("comment", "TEXT", "ORDER_PROP_COMMENT"), ("ext_id", "TEXT", "ORDER_PROP_EXT_ID"),
)
COLUMNS = tuple(name for name, _, _ in COLUMN_TYPES)
FIELDS = ", ".join(f"{name} {kind}" for name, kind, _ in COLUMN_TYPES)

# The columns of TradeEvent are the properties of CTradeEvent (ENUM_EVENT_PROP_INTEGER / DOUBLE / STRING in Entities/Defines/TradingDefines.mqh), one column for
# each, in the order of those enums, named as the property in lower case without EVENT_PROP_. A column the writer cannot know is NULL.
#   symbol_id = EVENT_PROP_SYMBOL: the symbol of OUR list (symbol_account gives the name of the account).
#   The key is account_key + time_event + type_event + ticket_order_event + ticket_deal_event (the four are 0 when the event has none).
EVENT_COLUMN_TYPES = (
    ("type_event", "INTEGER NOT NULL", "EVENT_PROP_TYPE_EVENT"), ("time_event", "INTEGER NOT NULL", "EVENT_PROP_TIME_EVENT"),
    ("status_event", "INTEGER", "EVENT_PROP_STATUS_EVENT"), ("reason_event", "INTEGER", "EVENT_PROP_REASON_EVENT"),
    ("type_deal_event", "INTEGER", "EVENT_PROP_TYPE_DEAL_EVENT"), ("ticket_deal_event", "INTEGER NOT NULL DEFAULT 0", "EVENT_PROP_TICKET_DEAL_EVENT"),
    ("type_order_event", "INTEGER", "EVENT_PROP_TYPE_ORDER_EVENT"), ("ticket_order_event", "INTEGER NOT NULL DEFAULT 0", "EVENT_PROP_TICKET_ORDER_EVENT"),
    ("time_order_position", "INTEGER", "EVENT_PROP_TIME_ORDER_POSITION"), ("type_order_position", "INTEGER", "EVENT_PROP_TYPE_ORDER_POSITION"),
    ("ticket_order_position", "INTEGER", "EVENT_PROP_TICKET_ORDER_POSITION"), ("position_id", "INTEGER", "EVENT_PROP_POSITION_ID"),
    ("position_by_id", "INTEGER", "EVENT_PROP_POSITION_BY_ID"), ("magic_order", "INTEGER", "EVENT_PROP_MAGIC_ORDER"), ("magic_by_id", "INTEGER", "EVENT_PROP_MAGIC_BY_ID"),
    ("type_ord_pos_before", "INTEGER", "EVENT_PROP_TYPE_ORD_POS_BEFORE"), ("ticket_ord_pos_before", "INTEGER", "EVENT_PROP_TICKET_ORD_POS_BEFORE"),
    ("type_ord_pos_current", "INTEGER", "EVENT_PROP_TYPE_ORD_POS_CURRENT"), ("ticket_ord_pos_current", "INTEGER", "EVENT_PROP_TICKET_ORD_POS_CURRENT"),
    ("price_event", "REAL", "EVENT_PROP_PRICE_EVENT"), ("price_open", "REAL", "EVENT_PROP_PRICE_OPEN"), ("price_close", "REAL", "EVENT_PROP_PRICE_CLOSE"),
    ("price_sl", "REAL", "EVENT_PROP_PRICE_SL"), ("price_tp", "REAL", "EVENT_PROP_PRICE_TP"), ("volume_order_initial", "REAL", "EVENT_PROP_VOLUME_ORDER_INITIAL"),
    ("volume_order_executed", "REAL", "EVENT_PROP_VOLUME_ORDER_EXECUTED"), ("volume_order_current", "REAL", "EVENT_PROP_VOLUME_ORDER_CURRENT"),
    ("volume_position_executed", "REAL", "EVENT_PROP_VOLUME_POSITION_EXECUTED"), ("profit", "REAL", "EVENT_PROP_PROFIT"),
    ("price_open_before", "REAL", "EVENT_PROP_PRICE_OPEN_BEFORE"), ("price_sl_before", "REAL", "EVENT_PROP_PRICE_SL_BEFORE"),
    ("price_tp_before", "REAL", "EVENT_PROP_PRICE_TP_BEFORE"), ("price_event_ask", "REAL", "EVENT_PROP_PRICE_EVENT_ASK"), ("price_event_bid", "REAL", "EVENT_PROP_PRICE_EVENT_BID"),
    ("symbol_id", "INTEGER REFERENCES symbols (id)", "EVENT_PROP_SYMBOL"),
)
EVENT_FIELDS = ", ".join(f"{name} {kind}" for name, kind, _ in EVENT_COLUMN_TYPES)

# ENUM_TRADE_EVENT (Entities/Defines/EventDefines.mqh), ENUM_EVENT_STATUS and ENUM_EVENT_REASON (TradingDefines.mqh): the values Python writes
TE_PLACED, TE_POSITION_OPENED, TE_TRIGGERED_STOP_LIMIT = 1, 22, 40
TE_MODIFY_ORDER = {(True, False, False): 41, (True, True, False): 42, (True, False, True): 43, (True, True, True): 44,   # (price, sl, tp) of an order
                   (False, True, True): 45, (False, True, False): 46, (False, False, True): 47}
TE_MODIFY_POSITION = {(True, True): 48, (True, False): 49, (False, True): 50}                                         # (sl, tp) of a position
ES_MARKET_POSITION, ES_MARKET_PENDING, ES_MODIFY = 0, 1, 5
ER_STOPLIMIT_TRIGGERED, ER_MODIFY = 6, 7
OT_BUY_LIMIT, OT_SELL_LIMIT, OT_BUY_STOP_LIMIT, OT_SELL_STOP_LIMIT = 2, 3, 6, 7   # ENUM_ORDER_TYPE

REASON = "CASE {t}.reason WHEN 0 THEN 'CLIENT' WHEN 1 THEN 'MOBILE' WHEN 2 THEN 'WEB' WHEN 3 THEN 'EXPERT' WHEN 4 THEN 'SL' WHEN 5 THEN 'TP' WHEN 6 THEN 'SO' ELSE CAST({t}.reason AS TEXT) END"
TIME = "strftime('%Y-%m-%d %H:%M:%f', {t}.time_open / 1000.0, 'unixepoch')"
SPREAD = "CASE WHEN {t}.bid > 0 AND {t}.ask > 0 THEN ROUND({t}.ask - {t}.bid, 6) END"
POSITION_VIEW = f"""CREATE VIEW position_summary AS
SELECT i.account_key AS account_key, i.position_id AS position_id, a.account_symbol AS symbol, i.symbol_id AS symbol_id,
       CASE i.type WHEN 0 THEN 'BUY' WHEN 1 THEN 'SELL' ELSE CAST(i.type AS TEXT) END AS side, i.volume AS volume,
       i.ticket AS open_ticket, {TIME.format(t='i')} AS open_time, ROUND(i.price_open, 8) AS open_price,
       i.bid AS open_bid, i.ask AS open_ask, {SPREAD.format(t='i')} AS open_spread,
       {REASON.format(t='i')} AS open_source,
       o.ticket AS close_ticket, {TIME.format(t='o')} AS close_time, ROUND(o.price_open, 8) AS close_price,
       o.bid AS close_bid, o.ask AS close_ask, {SPREAD.format(t='o')} AS close_spread,
       {REASON.format(t='o')} AS close_source,
       (SELECT SUM(d.profit + d.commission + d.swap) FROM orders d WHERE d.account_key = i.account_key AND d.status = {ST_DEAL} AND d.position_id = i.position_id AND d.type IN (0, 1)) AS net
FROM orders i LEFT JOIN symbol_account a ON a.account_key = i.account_key AND a.symbol_id = i.symbol_id
       LEFT JOIN orders o ON o.account_key = i.account_key AND o.status = {ST_DEAL} AND o.position_id = i.position_id AND o.deal_entry IN (1, 3) AND o.type IN (0, 1)
WHERE i.status = {ST_DEAL} AND i.deal_entry = 0 AND i.type IN (0, 1)"""

def modify_event(row, before):
    """The ENUM_TRADE_EVENT of a change of a live order or position (None: nothing the library calls an event, e.g. a changed volume or profit)."""
    changed = lambda name: (before.get(name) or 0) != (row.get(name) or 0)
    if row["status"] == ST_MARKET_POSITION:
        return TE_MODIFY_POSITION.get((changed("sl"), changed("tp")))
    if before.get("type") in (OT_BUY_STOP_LIMIT, OT_SELL_STOP_LIMIT) and row.get("type") in (OT_BUY_LIMIT, OT_SELL_LIMIT):
        return TE_TRIGGERED_STOP_LIMIT
    return TE_MODIFY_ORDER.get((changed("price_open"), changed("sl"), changed("tp")))


def state_to_event_sql(t, time_expr, symbol_expr):
    """The columns of TradeEvent and the SELECT that makes them from a line of the earlier layout (the state of an order or position seen for the first time:
    a pending order placed, or a position opened) whose alias is t."""
    columns = ("type_event, time_event, status_event, type_order_event, ticket_order_event, ticket_order_position, position_id, magic_order, price_event, price_open, "
               "price_sl, price_tp, volume_order_initial, volume_order_current, volume_position_executed, price_event_ask, price_event_bid, symbol_id")
    values = (f"CASE {t}.status WHEN {ST_MARKET_PENDING} THEN {TE_PLACED} ELSE {TE_POSITION_OPENED} END, {time_expr}, "
              f"CASE {t}.status WHEN {ST_MARKET_PENDING} THEN {ES_MARKET_PENDING} ELSE {ES_MARKET_POSITION} END, {t}.type, {t}.ticket, "
              f"CASE {t}.status WHEN {ST_MARKET_POSITION} THEN {t}.ticket END, {t}.position_id, {t}.magic, {t}.price_open, {t}.price_open, {t}.sl, {t}.tp, "
              f"CASE {t}.status WHEN {ST_MARKET_PENDING} THEN {t}.volume END, CASE {t}.status WHEN {ST_MARKET_PENDING} THEN {t}.volume_current END, "
              f"CASE {t}.status WHEN {ST_MARKET_POSITION} THEN {t}.volume END, {t}.ask, {t}.bid, {symbol_expr}")
    return columns, values


def utc(seconds):
    return datetime.fromtimestamp(seconds, tz=timezone.utc)


def from_deal(d):
    """A deal of the history as the properties of COrder: a deal of a buy or a sell, or a balance operation."""
    return {"status": ST_DEAL if d.type in (0, 1) else ST_BALANCE, "ticket": d.ticket, "magic": d.magic, "time_open": d.time_msc, "type": d.type,
            "reason": d.reason, "position_id": d.position_id, "deal_order_ticket": d.order, "deal_entry": d.entry, "price_open": d.price,
            "sl": getattr(d, "sl", None), "tp": getattr(d, "tp", None), "fee": d.fee, "profit": d.profit, "commission": d.commission, "swap": d.swap,
            "volume": d.volume, "symbol": d.symbol, "comment": d.comment, "ext_id": d.external_id}


def from_order(o, status):
    """An order of the history, or a pending order that is open now, as the properties of COrder."""
    return {"status": status, "ticket": o.ticket, "magic": o.magic, "time_open": o.time_setup_msc, "time_close": o.time_done_msc or None,
            "time_exp": o.time_expiration, "type_filling": o.type_filling, "type_time": o.type_time, "type": o.type, "reason": o.reason, "state": o.state,
            "position_id": o.position_id, "position_by_id": o.position_by_id, "price_open": o.price_open, "sl": o.sl, "tp": o.tp,
            "volume": o.volume_initial, "volume_current": o.volume_current, "price_stop_limit": o.price_stoplimit,
            "symbol": o.symbol, "comment": o.comment, "ext_id": o.external_id}


def from_position(p):
    """A position that is open now as the properties of COrder."""
    return {"status": ST_MARKET_POSITION, "ticket": p.ticket, "magic": p.magic, "time_open": p.time_msc, "time_update": p.time_update_msc, "type": p.type,
            "reason": p.reason, "position_id": p.identifier, "price_open": p.price_open, "sl": p.sl, "tp": p.tp, "swap": p.swap, "profit": p.profit,
            "volume": p.volume, "symbol": p.symbol, "comment": p.comment, "ext_id": p.external_id}


def old_folder():
    """Where the files of the earlier layout are (one for each account): they are copied into the database of the library, not changed."""
    if os.environ.get("TRADESYNC_DIR"):
        return Path(os.environ["TRADESYNC_DIR"])
    return Path(mt5.terminal_info().data_path) / "MQL5" / "Files" / "EA LibV3" / "Trade History"


class TradeSync:
    def __init__(self, lib_db):
        self.lib_db = lib_db     # LibDatabase: it makes the tables of the library and takes the names of the symbols it does not know (symbol_account)
        self.ready = True        # false while the lines of the earlier layout wait for a symbol to be joined
        self.retried = 0.0
        self.waiting = False     # lines were left out because their symbol is not joined
        self.mapped = -1         # how many symbols of this account were joined at the last look
        self.login = None
        self.server = None
        self.key = None          # account_key of the account the terminal is logged in to
        self.db = None
        self.live = {}           # (status, ticket) -> the properties of what is open now
        self.totals = (-1, -1)   # (deals, orders) in the history at the last look
        self.ticks_done = False

    # ------------------------------------------------------------ the file
    def open(self, info):
        self.close()
        self.lib_db.ensure()
        path = library_path()
        path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(str(path), timeout=5.0, isolation_level=None)   # no hidden transactions: BEGIN and commit are written out
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("PRAGMA busy_timeout=5000")
        self.key = account_key(info)
        self.login, self.server = info.login, info.server
        self.live = {}
        self.totals = (-1, -1)
        self.ticks_done = False
        self.waiting = False
        self.mapped = -1
        self.ready = self.migrate_symbol_id()
        if not self.ready:
            return
        self.migrate_trade_event()
        self.create_tables()
        self.mark("schema", SCHEMA)
        self.make_view()
        self.import_old_files()
        print(f"trade database of {info.server} {info.login}: {path}")

    def create_tables(self):
        # The comment inside the brackets is kept in the schema of the file (DBeaver shows it in the DDL): the table says the class of the library it maps to.
        self.db.execute(f"CREATE TABLE IF NOT EXISTS orders (\n-- Library V3: class COrder (Entities/Trading/Order.mqh), properties ENUM_ORDER_PROP_* (Entities/Defines/TradingDefines.mqh)\naccount_key TEXT NOT NULL, {FIELDS}, PRIMARY KEY (account_key, status, ticket))")
        self.db.execute(f"CREATE TABLE IF NOT EXISTS TradeEvent (\n-- Library V3: class CTradeEvent (Entities/Trading/TradeEvent.mqh), properties ENUM_EVENT_PROP_* (Entities/Defines/TradingDefines.mqh)\n"
                        f"-- one column for each property, in the order of the enums; symbol_id = EVENT_PROP_SYMBOL; NULL = not known to the writer\n"
                        f"account_key TEXT NOT NULL, {EVENT_FIELDS}, PRIMARY KEY (account_key, time_event, type_event, ticket_order_event, ticket_deal_event))")
        self.db.execute("CREATE TABLE IF NOT EXISTS sync_state (account_key TEXT NOT NULL, key TEXT NOT NULL, value INTEGER, writer TEXT, updated INTEGER, PRIMARY KEY (account_key, key))")

    def migrate_symbol_id(self):
        """orders is made again when it is not of the present layout: the name of the symbol replaced by its symbol_id (symbol_account says which), and the columns
        in the order of ENUM_ORDER_PROP_*. The lines are copied, and a copy of the file is kept next to it first. True when the table is of the present layout.
        When a symbol of the lines is not joined to one of ours yet nothing is changed (its name would be lost): the user joins it first."""
        columns = [row[1] for row in self.db.execute("PRAGMA table_info(orders)")]
        if not columns:
            return True
        named = "symbol_id" in columns
        same = columns == ["account_key"] + list(COLUMNS)
        noted = "COrder" in (self.db.execute("SELECT sql FROM sqlite_master WHERE name = 'orders'").fetchone()[0] or "")   # the schema says the class it maps to
        if same and noted:
            return True
        lost = set()
        if not named:
            lost.update(row[0] for row in self.db.execute(
                "SELECT DISTINCT t.account_key || ' ' || t.symbol FROM orders t WHERE t.symbol IS NOT NULL AND t.symbol <> '' AND NOT EXISTS "
                "(SELECT 1 FROM symbol_account a WHERE a.account_key = t.account_key AND a.account_symbol = t.symbol AND a.symbol_id IS NOT NULL)"))
        if lost:
            print(f"the trade tables keep the names of the symbols until these are joined to a symbol of ours (symbol_account): {sorted(lost)}")
            return False
        backup = library_path().with_name("LibV3.before_symbol_id.sqlite3" if not named else "LibV3.before_column_order.sqlite3" if not same else "LibV3.before_trade_event.sqlite3")
        self.backup_file(backup)
        self.db.execute("DROP VIEW IF EXISTS position_summary")
        self.db.execute("BEGIN")
        try:
            self.db.execute("ALTER TABLE orders RENAME TO orders_old")
            self.db.execute("CREATE TABLE IF NOT EXISTS orders (\n-- Library V3: class COrder (Entities/Trading/Order.mqh), properties ENUM_ORDER_PROP_* (Entities/Defines/TradingDefines.mqh)\n"
                            f"account_key TEXT NOT NULL, {FIELDS}, PRIMARY KEY (account_key, status, ticket))")
            keep = [name for name in COLUMNS if name != "symbol_id"]
            symbol = "t.symbol_id" if named else "(SELECT a.symbol_id FROM symbol_account a WHERE a.account_key = t.account_key AND a.account_symbol = t.symbol)"
            names = ", ".join(["account_key"] + keep + ["symbol_id"])
            values = ", ".join([f"t.{name}" for name in ["account_key"] + keep] + [symbol])
            self.db.execute(f"INSERT INTO orders ({names}) SELECT {values} FROM orders_old t")
            self.db.execute("DROP TABLE orders_old")
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        print(f"orders made again ({'symbol_id' if not named else 'the order of ENUM_ORDER_PROP_*'}; a copy of the file before: {backup.name})")
        return True

    def backup_file(self, backup):
        """A copy of the whole file next to it, once (an older copy is kept as it is)."""
        if not backup.exists():
            copy = sqlite3.connect(str(backup))
            self.db.backup(copy)
            copy.close()

    def migrate_trade_event(self):
        """TradeEvent (called order_events before) of the earlier layout, the columns of COrder with the time and the name of the event, is made again with the columns of
        CTradeEvent. Only what Python saw first-hand converts: a pending order placed (TRADE_EVENT_PENDING_ORDER_PLASED) and a position opened
        (TRADE_EVENT_POSITION_OPENED); the other lines of the earlier layout (a change of a price or a volume) have no CTradeEvent to become and are counted, not copied.
        A copy of the file is kept first."""
        tables = {row[0] for row in self.db.execute("SELECT name FROM sqlite_master WHERE type = 'table'")}
        old = "TradeEvent" if "TradeEvent" in tables else "order_events" if "order_events" in tables else None
        if old is None:
            return
        columns = [row[1] for row in self.db.execute(f"PRAGMA table_info({old})")]
        if columns == ["account_key"] + [name for name, _, _ in EVENT_COLUMN_TYPES]:
            return
        if "type_event" in columns:   # the columns of CTradeEvent, but not the present ones (a property was removed): the lines are copied column by column
            self.backup_file(library_path().with_name("LibV3.before_trade_event_property_removed.sqlite3"))
            common = ", ".join(name for name in columns if name in ["account_key"] + [n for n, _, _ in EVENT_COLUMN_TYPES])
            self.db.execute("BEGIN")
            try:
                self.db.execute("ALTER TABLE TradeEvent RENAME TO TradeEvent_old")
                self.create_tables()
                self.db.execute(f"INSERT OR IGNORE INTO TradeEvent ({common}) SELECT {common} FROM TradeEvent_old")
                self.db.execute("DROP TABLE TradeEvent_old")
                self.db.commit()
            except Exception:
                self.db.rollback()
                raise
            print(f"TradeEvent made again without the columns of the properties that CTradeEvent no longer has (a copy of the file before: LibV3.before_trade_event_property_removed.sqlite3)")
            return
        self.backup_file(library_path().with_name("LibV3.before_trade_event_columns.sqlite3"))
        symbol = "t.symbol_id" if "symbol_id" in columns else "(SELECT a.symbol_id FROM symbol_account a WHERE a.account_key = t.account_key AND a.account_symbol = t.symbol)"
        names, values = state_to_event_sql("t", "t.event_time", symbol)
        self.db.execute("BEGIN")
        try:
            self.db.execute(f"ALTER TABLE {old} RENAME TO TradeEvent_old")
            self.db.execute("DROP INDEX IF EXISTS order_events_once")
            self.db.execute("DROP INDEX IF EXISTS TradeEvent_once")
            self.create_tables()
            copied = self.db.execute(f"INSERT OR IGNORE INTO TradeEvent (account_key, {names}) SELECT t.account_key, {values} FROM TradeEvent_old t "
                                     f"WHERE t.event = 'NEW' AND t.status IN ({ST_MARKET_PENDING}, {ST_MARKET_POSITION})").rowcount
            total = self.db.execute("SELECT COUNT(*) FROM TradeEvent_old").fetchone()[0]
            self.db.execute("DROP TABLE TradeEvent_old")
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        print(f"TradeEvent made again with the columns of CTradeEvent: {copied} of {total} line(s) copied, {total - copied} had no CTradeEvent to become")

    def import_old_files(self):
        """The files of the earlier layout (<server>_<login>.sqlite3 in the Trade History folder, the layout of SCHEMA 2) are copied once, each under its own
        account_key. They are only read: they stay where they are."""
        folder = old_folder()
        if not folder.is_dir():
            return
        for old in sorted(folder.glob("*.sqlite3")):
            key = old.name[:-len(".sqlite3")]
            if ".before_" in key or self.db.execute("SELECT 1 FROM sync_state WHERE account_key = ? AND key = ?", (key, IMPORTED)).fetchone():
                continue
            try:
                self.import_file(old, key)
            except sqlite3.Error as error:
                print(f"trade history of {key} not copied: {error}")

    def import_file(self, old, key):
        self.db.execute("ATTACH DATABASE ? AS old", (str(old),))
        try:
            tables = {row[0] for row in self.db.execute("SELECT name FROM old.sqlite_master WHERE type = 'table'")}
            columns = {row[1] for row in self.db.execute("PRAGMA old.table_info(orders)")} if "orders" in tables else set()
            keep = [name for name in COLUMNS if name != "symbol_id"]
            names = ", ".join(keep + ["symbol_id"])
            values = ", ".join([f"o.{name}" for name in keep] + ["(SELECT a.symbol_id FROM symbol_account a WHERE a.account_key = ? AND a.account_symbol = o.symbol AND a.symbol_id IS NOT NULL)"])
            joined = ("(o.symbol IS NULL OR o.symbol = '' OR EXISTS (SELECT 1 FROM symbol_account a WHERE a.account_key = ? AND a.account_symbol = o.symbol "
                      "AND a.symbol_id IS NOT NULL))")
            self.db.execute("BEGIN")
            try:
                left = 0
                if {"status", "ticket"} <= columns and "order_events" in tables:
                    total = self.db.execute("SELECT COUNT(*) FROM old.orders").fetchone()[0]
                    copied = self.db.execute(f"INSERT OR REPLACE INTO orders (account_key, {names}) SELECT ?, {values} FROM old.orders o WHERE {joined}", (key, key, key)).rowcount
                    event_names, event_values = state_to_event_sql("o", "o.event_time", "(SELECT a.symbol_id FROM symbol_account a WHERE a.account_key = ? AND a.account_symbol = o.symbol AND a.symbol_id IS NOT NULL)")
                    self.db.execute(f"INSERT OR IGNORE INTO TradeEvent (account_key, {event_names}) SELECT ?, {event_values} FROM old.order_events o "
                                    f"WHERE o.event = 'NEW' AND o.status IN ({ST_MARKET_PENDING}, {ST_MARKET_POSITION}) AND {joined}", (key, key, key))
                    if "sync_state" in tables:
                        self.db.execute("INSERT OR REPLACE INTO sync_state (account_key, key, value, writer, updated) SELECT ?, key, value, writer, updated FROM old.sync_state "
                                        "WHERE key <> 'schema'", (key,))
                    left = total - copied
                    print(f"trade history of {key}: {copied} line(s) copied from {old.name}" + (f", {left} left: their symbols are not joined to a symbol of ours yet (symbol_account)" if left else ""))
                else:
                    print(f"trade history of {key}: {old.name} is not of the layout of SCHEMA 2, not copied")
                if not left:   # a file with lines left out is looked at again when the symbols are joined
                    self.db.execute("INSERT OR REPLACE INTO sync_state (account_key, key, value, writer, updated) VALUES (?, ?, ?, 'python', ?)",
                                    (key, IMPORTED, int(time.time() * 1000), int(time.time() * 1000)))
                self.db.commit()
            except Exception:
                self.db.rollback()
                raise
        finally:
            self.db.execute("DETACH DATABASE old")

    def close(self):
        if self.db is not None:
            try:
                self.db.commit()
                self.db.close()
            except sqlite3.Error:
                pass
        self.db = None

    def mark(self, key, value):
        """What was saved, and by whom: the program that goes on reads it and goes on from there."""
        self.db.execute("INSERT INTO sync_state (account_key, key, value, writer, updated) VALUES (?, ?, ?, 'python', ?) "
                        "ON CONFLICT(account_key, key) DO UPDATE SET value=excluded.value, writer=excluded.writer, updated=excluded.updated", (self.key, key, value, int(time.time() * 1000)))

    def symbol_ids(self):
        """{the name the account gives a symbol: the symbol_id of ours} for the symbols of this account that are joined."""
        return dict(self.db.execute("SELECT account_symbol, symbol_id FROM symbol_account WHERE account_key = ? AND symbol_id IS NOT NULL", (self.key,)).fetchall())

    def unknown_symbols(self, names):
        """Symbols that are not joined to one of ours: they go to symbol_account (no symbol of ours when none matches) for the user to join."""
        self.lib_db.register_symbols(sorted(names))
        self.waiting = True

    def stored(self, rows):
        """The rows as the table keeps them: the name of the symbol is replaced by its symbol_id. A row whose symbol is not joined yet is left out."""
        ids = self.symbol_ids()
        keep, unknown = [], set()
        for row in rows:
            name = row.get("symbol")
            if not name:
                keep.append(dict(row, symbol_id=None))   # a balance operation has no symbol
            elif name in ids:
                keep.append(dict(row, symbol_id=ids[name]))
            else:
                unknown.add(name)
        if unknown:
            self.unknown_symbols(unknown)
        return keep

    def upsert(self, rows):
        """Lines written by status + ticket; a bid or an ask is not erased by a missing value."""
        rows = self.stored(rows)
        if not rows:
            return
        updates = ", ".join(f"{n}=COALESCE(excluded.{n}, orders.{n})" if n in ("bid", "ask") else f"{n}=excluded.{n}" for n in COLUMNS if n not in ("status", "ticket"))
        sql = f"INSERT INTO orders (account_key, {', '.join(COLUMNS)}) VALUES (?, {', '.join('?' * len(COLUMNS))}) ON CONFLICT(account_key, status, ticket) DO UPDATE SET {updates}"
        self.db.executemany(sql, [[self.key] + [row.get(n) for n in COLUMNS] for row in rows])

    def make_view(self):
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

    # ------------------------------------------------------------ the history
    def sync_history(self):
        """Deals and orders of the history, when the terminal says their number changed: all of it the first time, then from a day before the newest."""
        mapped = self.db.execute("SELECT COUNT(*) FROM symbol_account WHERE account_key = ? AND symbol_id IS NOT NULL", (self.key,)).fetchone()[0]
        again = self.waiting and mapped != self.mapped   # a symbol was joined since lines were left out: the history is read again from the start
        self.mapped = mapped
        if again:
            self.totals = (-1, -1)
        now = datetime.now(timezone.utc) + timedelta(days=2)
        first = utc(0)
        totals = (mt5.history_deals_total(first, now), mt5.history_orders_total(first, now))
        if None in totals or totals == self.totals:
            return
        newest = self.db.execute("SELECT MAX(time_open) FROM orders WHERE account_key = ? AND status IN (?, ?)", (self.key, ST_DEAL, ST_BALANCE)).fetchone()[0]
        start = first if again or (self.totals == (-1, -1) and not newest) else utc(max((newest or 0) / 1000.0 - HISTORY_MARGIN_S, 0))
        deals = mt5.history_deals_get(start, now)
        orders = mt5.history_orders_get(start, now)
        if deals is None or orders is None:
            return
        if start == first and (len(deals), len(orders)) != totals:   # the terminal gave less than it counted (not loaded yet): look again at the next round
            return
        self.waiting = False
        self.db.execute("BEGIN")
        try:
            self.upsert([from_deal(d) for d in deals] + [from_order(o, ST_HISTORY_ORDER if o.type in (0, 1) else ST_HISTORY_PENDING) for o in orders])
            self.mark("history", int(time.time() * 1000))   # saved until now
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        self.totals = totals
        self.ticks_done = False
        print(f"trade history: {len(deals)} deal(s), {len(orders)} order(s) written")

    def backfill_ticks(self, limit=BACKFILL_PER_POLL):
        """A few deals at a time, newest first: the tick of their time. 0 and 0 = the terminal has no tick for it, not looked for again."""
        if self.ticks_done:
            return
        rows = self.db.execute("SELECT o.ticket, a.account_symbol, o.time_open FROM orders o JOIN symbol_account a ON a.account_key = o.account_key AND a.symbol_id = o.symbol_id "
                               "WHERE o.account_key = ? AND o.status = ? AND o.type IN (0, 1) AND o.bid IS NULL ORDER BY o.time_open DESC LIMIT ?", (self.key, ST_DEAL, limit)).fetchall()
        if not rows:
            self.ticks_done = True
            return
        ticks = [(ticket, self.tick_at(symbol, time_msc)) for ticket, symbol, time_msc in rows]
        self.db.execute("BEGIN")
        try:
            for ticket, tick in ticks:
                self.db.execute("UPDATE orders SET bid=?, ask=? WHERE account_key = ? AND status = ? AND ticket = ?", (tick[0] if tick else 0.0, tick[1] if tick else 0.0, self.key, ST_DEAL, ticket))
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise

    # ------------------------------------------------------------ what is open now
    def event(self, row, type_event, before=None):
        """An event of a live order or position as a CTradeEvent (type_event is its ENUM_TRADE_EVENT) with the tick of that moment. The first time it is seen
        (a pending order placed, a position opened): the last tick, or the tick of the time it was placed when that was long before (Python was off). A change
        (before is the state seen before) carries the prices before it; what Python cannot know stays NULL."""
        placed = int(row.get("time_open") or 0)
        symbol = row["symbol"]
        ids = self.symbol_ids()
        if symbol not in ids:
            self.unknown_symbols([symbol])   # nothing is written for it until the user joins it
            return
        late = before is None and placed > 0 and time.time() * 1000 - placed > BIRTH_LATE_MS
        tick, time_msc = None, int(time.time() * 1000)
        if late:
            tick, time_msc = self.tick_at(symbol, placed), placed
        else:
            last = mt5.symbol_info_tick(symbol)
            if last is not None and last.bid > 0 and last.ask > 0:
                tick = (float(last.bid), float(last.ask))
                time_msc = int(last.time_msc) if last.time_msc else time_msc
        pending = row["status"] == ST_MARKET_PENDING
        values = {"type_event": type_event, "time_event": time_msc, "type_order_event": row.get("type"), "ticket_order_event": row["ticket"],
                  "position_id": row.get("position_id"), "magic_order": row.get("magic"), "price_event": row.get("price_open"), "price_open": row.get("price_open"),
                  "price_sl": row.get("sl"), "price_tp": row.get("tp"), "price_event_ask": tick[1] if tick else None, "price_event_bid": tick[0] if tick else None,
                  "symbol_id": ids[symbol]}
        if pending:
            values.update(volume_order_initial=row.get("volume"), volume_order_current=row.get("volume_current"))
        else:
            values.update(ticket_order_position=row["ticket"], volume_position_executed=row.get("volume"))   # a hedge position has the ticket of the order that opened it
        if before is None:
            values["status_event"] = ES_MARKET_PENDING if pending else ES_MARKET_POSITION
        else:
            values.update(status_event=ES_MODIFY, reason_event=ER_STOPLIMIT_TRIGGERED if type_event == TE_TRIGGERED_STOP_LIMIT else ER_MODIFY,
                          price_open_before=before.get("price_open"), price_sl_before=before.get("sl"), price_tp_before=before.get("tp"))
        names = list(values)
        self.db.execute(f"INSERT OR IGNORE INTO TradeEvent (account_key, {', '.join(names)}) VALUES (?, {', '.join('?' * len(names))})", [self.key] + [values[n] for n in names])

    def sync_live(self, positions=None, orders=None):
        positions = mt5.positions_get() if positions is None else positions
        orders = mt5.orders_get() if orders is None else orders
        if positions is None or orders is None:
            return
        current = {(ST_MARKET_POSITION, p.ticket): from_position(p) for p in positions}
        current.update({(ST_MARKET_PENDING, o.ticket): from_order(o, ST_MARKET_PENDING) for o in orders})
        changed = False
        for key, row in current.items():
            if key not in self.live:
                self.event(row, TE_PLACED if row["status"] == ST_MARKET_PENDING else TE_POSITION_OPENED)
                changed = True
            else:
                before = self.live[key]
                if any(before.get(n) != row.get(n) for n in ("sl", "tp", "price_open", "type", "volume", "swap", "profit")):
                    changed = True
                type_event = modify_event(row, before)
                if type_event is not None:
                    self.event(row, type_event, before)
        if set(self.live) - set(current):
            changed = True
        self.live = current
        if changed:
            self.db.execute("BEGIN")
            try:
                self.db.execute("DELETE FROM orders WHERE account_key = ? AND status IN (?, ?)", (self.key, ST_MARKET_PENDING, ST_MARKET_POSITION))
                self.upsert(list(current.values()))
                self.db.commit()
            except Exception:
                self.db.rollback()
                raise

    # ------------------------------------------------------------ one round
    def poll(self):
        """Called by the server on its rhythm: cheap when nothing changed (a few calls to the terminal)."""
        info = mt5.account_info()
        if info is None:
            return
        if info.login != self.login or info.server != self.server:   # the terminal is logged in to another account: its own lines
            self.open(info)
        if not self.ready:   # the lines of the earlier layout wait for a symbol to be joined: looked at again every ten seconds
            if time.monotonic() - self.retried >= 10.0:
                self.retried = time.monotonic()
                self.open(info)
            if not self.ready:
                return
        self.sync_history()
        self.sync_live()
        self.backfill_ticks()
