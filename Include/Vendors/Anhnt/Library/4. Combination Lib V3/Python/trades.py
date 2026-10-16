import os
import re
import sqlite3
import time
from datetime import datetime, timezone
from pathlib import Path

import cache

# The trades of an account kept for the analysis: the EA sends the deals and the history orders it reads from the terminal (and what only the EA
# knows: the spread of the moment), Python keeps them in one SQLite file for each account. A line is written by its ticket: a line sent again
# (the EA sends the whole history again when it connects) changes nothing, a field the EA could not give (spread) is not erased by a later NULL.

DEAL_TYPES = {0: "BUY", 1: "SELL", 2: "BALANCE", 3: "CREDIT", 4: "CHARGE", 5: "CORRECTION", 6: "BONUS", 7: "COMMISSION", 8: "COMMISSION_DAILY",
              9: "COMMISSION_MONTHLY", 10: "COMMISSION_AGENT_DAILY", 11: "COMMISSION_AGENT_MONTHLY", 12: "INTEREST", 13: "BUY_CANCELED",
              14: "SELL_CANCELED", 15: "DIVIDEND", 16: "DIVIDEND_FRANKED", 17: "TAX"}
DEAL_ENTRIES = {0: "IN", 1: "OUT", 2: "INOUT", 3: "OUT_BY"}
DEAL_REASONS = {0: "CLIENT", 1: "MOBILE", 2: "WEB", 3: "EXPERT", 4: "SL", 5: "TP", 6: "SO", 7: "ROLLOVER", 8: "VMARGIN", 9: "SPLIT", 10: "CORPORATE_ACTION"}
ORDER_TYPES = {0: "BUY", 1: "SELL", 2: "BUY_LIMIT", 3: "SELL_LIMIT", 4: "BUY_STOP", 5: "SELL_STOP", 6: "BUY_STOP_LIMIT", 7: "SELL_STOP_LIMIT", 8: "CLOSE_BY"}
ORDER_STATES = {0: "STARTED", 1: "PLACED", 2: "CANCELED", 3: "PARTIAL", 4: "FILLED", 5: "REJECTED", 6: "EXPIRED", 7: "REQUEST_ADD", 8: "REQUEST_MODIFY",
                9: "REQUEST_CANCEL"}

DEAL_COLUMNS = [("ticket", "INTEGER PRIMARY KEY"), ("order_ticket", "INTEGER"), ("position", "INTEGER"), ("time_msc", "INTEGER"), ("time", "TEXT"),
                ("type", "INTEGER"), ("type_text", "TEXT"), ("entry", "INTEGER"), ("entry_text", "TEXT"), ("reason", "INTEGER"), ("reason_text", "TEXT"),
                ("magic", "INTEGER"), ("symbol", "TEXT"), ("volume", "REAL"), ("price", "REAL"), ("commission", "REAL"), ("swap", "REAL"),
                ("profit", "REAL"), ("sl", "REAL"), ("tp", "REAL"), ("comment", "TEXT"), ("spread", "REAL"), ("updated", "TEXT")]
ORDER_COLUMNS = [("ticket", "INTEGER PRIMARY KEY"), ("position", "INTEGER"), ("time_setup_msc", "INTEGER"), ("time_setup", "TEXT"), ("time_done_msc", "INTEGER"),
                 ("type", "INTEGER"), ("type_text", "TEXT"), ("state", "INTEGER"), ("state_text", "TEXT"), ("reason", "INTEGER"), ("reason_text", "TEXT"),
                 ("magic", "INTEGER"), ("symbol", "TEXT"), ("volume", "REAL"), ("volume_current", "REAL"), ("price", "REAL"), ("sl", "REAL"),
                 ("tp", "REAL"), ("expiration", "INTEGER"), ("comment", "TEXT"), ("updated", "TEXT")]
CHANGE_TYPES = {0: "NONE", 1: "ORDER_TYPE", 2: "ORDER_PRICE", 3: "ORDER_PRICE_SL", 4: "ORDER_PRICE_TP", 5: "ORDER_PRICE_SL_TP", 6: "ORDER_SL_TP",
                 7: "ORDER_SL", 8: "ORDER_TP", 9: "POSITION_SL_TP", 10: "POSITION_SL", 11: "POSITION_TP"}
# What changed in a live order or position (the EA sees it in its market collection and tells it before it forgets it): the history of the
# terminal does not keep when a Stop Loss was moved. Each line is one change; the bid and the ask are the last tick of that moment.
EVENT_COLUMNS = [("id", "INTEGER PRIMARY KEY AUTOINCREMENT"), ("time_msc", "INTEGER"), ("time", "TEXT"), ("ticket", "INTEGER"), ("position", "INTEGER"),
                 ("symbol", "TEXT"), ("magic", "INTEGER"), ("change", "INTEGER"), ("change_text", "TEXT"), ("type", "INTEGER"), ("type_prev", "INTEGER"),
                 ("type_text", "TEXT"), ("price", "REAL"), ("price_prev", "REAL"), ("sl", "REAL"), ("sl_prev", "REAL"), ("tp", "REAL"), ("tp_prev", "REAL"),
                 ("volume", "REAL"), ("bid", "REAL"), ("ask", "REAL"), ("spread", "REAL"), ("updated", "TEXT")]
KEEP_WHEN_NULL = {"deals": ("spread",), "orders": ()}


def trades_dir():
    """MQL5\\Files\\EA LibV3\\Trade History, next to the Python cache (the EA keeps its own files there)."""
    return cache.cache_dir().parent / "Trade History"


def safe(text):
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", str(text)).strip("_") or "account"


def iso(msc):
    """Time of the server as the terminal gives it (seconds since 1970 read as UTC), to the millisecond."""
    if not msc:
        return None
    return datetime.fromtimestamp(msc / 1000.0, tz=timezone.utc).strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]


def text_of(table, value):
    return None if value is None else table.get(int(value), str(int(value)))


class TradeStore:
    """The SQLite file of one account."""

    def __init__(self, path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(str(self.path))
        self.db.execute("PRAGMA journal_mode=WAL")
        self.create("deals", DEAL_COLUMNS)
        self.create("orders", ORDER_COLUMNS)
        self.create("order_events", EVENT_COLUMNS)
        self.db.execute("CREATE UNIQUE INDEX IF NOT EXISTS order_events_once ON order_events(ticket, time_msc, change, price, sl, tp)")   # a line sent twice is one line
        self.db.execute("CREATE INDEX IF NOT EXISTS deals_position ON deals(position)")
        self.db.execute("CREATE INDEX IF NOT EXISTS deals_time ON deals(time_msc)")
        self.db.commit()

    def create(self, table, columns):
        self.db.execute(f"CREATE TABLE IF NOT EXISTS {table} (" + ", ".join(f"{name} {kind}" for name, kind in columns) + ")")
        have = {row[1] for row in self.db.execute(f"PRAGMA table_info({table})")}
        for name, kind in columns:   # a column added later to the table of an older file
            if name not in have:
                self.db.execute(f"ALTER TABLE {table} ADD COLUMN {name} {kind.replace(' PRIMARY KEY', '')}")

    def upsert(self, table, columns, rows):
        names = [name for name, _ in columns]
        keep = KEEP_WHEN_NULL[table]
        updates = ", ".join(f"{name}=COALESCE(excluded.{name},{table}.{name})" if name in keep else f"{name}=excluded.{name}" for name in names[1:])
        sql = f"INSERT INTO {table} ({', '.join(names)}) VALUES ({', '.join('?' * len(names))}) ON CONFLICT(ticket) DO UPDATE SET {updates}"
        self.db.executemany(sql, [[row.get(name) for name in names] for row in rows])

    def deals(self, rows):
        now = time.strftime("%Y-%m-%d %H:%M:%S")
        for row in rows:
            row["time"] = iso(row.get("time_msc"))
            row["type_text"] = text_of(DEAL_TYPES, row.get("type"))
            row["entry_text"] = text_of(DEAL_ENTRIES, row.get("entry"))
            row["reason_text"] = text_of(DEAL_REASONS, row.get("reason"))
            row["updated"] = now
            if row.get("spread") is not None and row["spread"] < 0:
                row["spread"] = None   # the EA found no tick for it
        self.upsert("deals", DEAL_COLUMNS, rows)

    def orders(self, rows):
        now = time.strftime("%Y-%m-%d %H:%M:%S")
        for row in rows:
            row["time_setup"] = iso(row.get("time_setup_msc"))
            row["type_text"] = text_of(ORDER_TYPES, row.get("type"))
            row["state_text"] = text_of(ORDER_STATES, row.get("state"))
            row["reason_text"] = text_of(DEAL_REASONS, row.get("reason"))
            row["updated"] = now
        self.upsert("orders", ORDER_COLUMNS, rows)

    def events(self, rows):
        now = time.strftime("%Y-%m-%d %H:%M:%S")
        names = [name for name, _ in EVENT_COLUMNS][1:]
        for row in rows:
            row["time"] = iso(row.get("time_msc"))
            row["change_text"] = text_of(CHANGE_TYPES, row.get("change"))
            row["type_text"] = text_of(ORDER_TYPES, row.get("type"))
            row["updated"] = now
        self.db.executemany(f"INSERT OR IGNORE INTO order_events ({', '.join(names)}) VALUES ({', '.join('?' * len(names))})",
                            [[row.get(name) for name in names] for row in rows])

    def close(self):
        self.db.commit()
        self.db.close()


class TradeStores:
    """One TradeStore for each account that sends its trades."""

    def __init__(self):
        self.stores = {}

    def store_of(self, server, login):
        key = (server, int(login))
        if key not in self.stores:
            self.stores[key] = TradeStore(trades_dir() / f"{safe(server)}_{int(login)}.sqlite3")
        return self.stores[key]

    def store(self, message):
        """A 'trades' message of the EA: {"account": login, "server": text, "deals": [...], "orders": [...]}; returns how many lines were written."""
        store = self.store_of(message.get("server", ""), message["account"])
        deals = message.get("deals", [])
        orders = message.get("orders", [])
        events = message.get("events", [])
        if deals:
            store.deals(deals)
        if orders:
            store.orders(orders)
        if events:
            store.events(events)
        store.db.commit()
        return len(deals) + len(orders) + len(events)

    def close(self):
        for store in self.stores.values():
            store.close()
        self.stores.clear()
