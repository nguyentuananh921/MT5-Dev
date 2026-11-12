"""The database of the library: ONE SQLite file for what the EA and Python share (MQL5\\Files\\EA LibV3\\LibV3.sqlite3).

The tables follow the classes of the library (accounts = CAccountsCollection, ...). What the terminal already has is not saved: the EA asks
the terminal by the key. The EA creates the same tables when it starts first (CREATE TABLE IF NOT EXISTS, the same text as here).
"""
import json
import os
import sqlite3
import time
from pathlib import Path

import MetaTrader5 as mt5

import re

FOLDER_NAME = "SQLite"                      # inside MQL5\Files\EA LibV3
FILE_NAME = "EA LibV3_Common.sqlite3"       # the name of the EA + Common: what every account shares
TOUCH_PERIOD = 60.0   # seconds: the last_seen of the account is written again after this long

# The text is the same as in LibDatabase.mqh of the EA
ACCOUNTS = ("CREATE TABLE IF NOT EXISTS accounts (account_key TEXT NOT NULL PRIMARY KEY, server TEXT NOT NULL, login INTEGER NOT NULL, "
            "first_seen INTEGER, last_seen INTEGER)")


# The symbols: ours (symbols, the list the user keeps) and the way each account calls them (symbol_account, the names of its Market Watch). One name of
# ours for each symbol of an account. symbol_id is empty (NULL) when Python does not know which of ours it is: the user fills it in by hand.
# Python only adds the lines that are not there: a line that is there is never changed. The REFERENCES describe the relations (they are not enforced).
SYMBOLS = "CREATE TABLE IF NOT EXISTS symbols (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE)"
SYMBOL_ACCOUNT_COLUMNS = ("(account_key TEXT NOT NULL REFERENCES accounts (account_key), account_symbol TEXT NOT NULL, symbol_id INTEGER REFERENCES symbols (id), "
                          "PRIMARY KEY (account_key, account_symbol), UNIQUE (account_key, symbol_id))")
SYMBOL_ACCOUNT = "CREATE TABLE IF NOT EXISTS symbol_account " + SYMBOL_ACCOUNT_COLUMNS

# The pairs Symbol + TF the EA cares about = the rows of CSymbolTFManager (it was the "Symbols_TFs_List" of the JSON file of the configuration of each account). One list
# for each account (account_key): the symbol is OUR symbol, the name the account gives it comes back through symbol_account. Python calculates every pair; the EA and
# Python read the same list. The columns are the members of CSymbolTFSetting (Entities/Settings/SymbolTFSetting.mqh) in lower case without m_: symbol_id is m_symbol,
# tf_enum is m_tf_enum (the value of ENUM_TIMEFRAMES, never a text); account_key is the only column the class has no member for (the class knows one account).
SETTING_SYMBOLTF = ("CREATE TABLE IF NOT EXISTS Setting_SymbolTF (\n"
                    "-- Library V3: class CSymbolTFSetting (Entities/Settings/SymbolTFSetting.mqh), the rows of CSymbolTFManager (Collections/Settings/SymbolTFManager.mqh)\n"
                    "-- account_key = the account the list belongs to, symbol_id = m_symbol (OUR symbol), tf_enum = m_tf_enum (ENUM_TIMEFRAMES value), the others are the members of the same name\n"
                    "account_key TEXT NOT NULL REFERENCES accounts (account_key), symbol_id INTEGER NOT NULL REFERENCES symbols (id), "
                    "tf_enum INTEGER NOT NULL REFERENCES timeframes (tf_enum), buy_signal INTEGER NOT NULL DEFAULT 1, sell_signal INTEGER NOT NULL DEFAULT 1, "
                    "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, PRIMARY KEY (account_key, symbol_id, tf_enum))")

# The file of ONE account (SQLite\\<server>_<login>.sqlite3) keeps what Python CALCULATES from the bars of that account: every account has its own feed of prices, so the
# results are not shared. The tables follow the classes of the library, one column for each property (SYMBOL -> symbol_id, PERIOD -> tf_enum, in lower case without the prefix),
# and every table has the same key (symbol_id, tf_enum, time) with `time` = the bar the row is about, so the tables join on it: a price is not saved where it is the high, the low,
# the open or the close of a bar (the Bar table has them), and the code of an object is not saved where it is made of its other properties.
# Bar: the OHLC are the terminal's values when Python calculated; a row for every closed bar Python looked at.
BAR = ("CREATE TABLE IF NOT EXISTS Bar (\n"
       "-- Library V3: class CBar (BAR_PROP_*). symbol_id = BAR_PROP_SYMBOL (a symbol of OUR list: symbols of EA LibV3_Common.sqlite3), tf_enum = BAR_PROP_PERIOD (ENUM_TIMEFRAMES value),\n"
       "-- time = BAR_PROP_TIME (seconds), open, high, low, close = BAR_PROP_OPEN..CLOSE, patterns_type = BAR_PROP_PATTERNS_TYPE (the flags of ENUM_PATTERN_TYPE). Not saved: the volumes and the\n"
       "-- spread (the terminal has them), the parts of the date and the type, sizes and ratios of the candle (calculated from the others)\n"
       "symbol_id INTEGER NOT NULL, tf_enum INTEGER NOT NULL, time INTEGER NOT NULL, open REAL NOT NULL, high REAL NOT NULL, low REAL NOT NULL, close REAL NOT NULL, "
       "patterns_type INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (symbol_id, tf_enum, time)) WITHOUT ROWID")
# Swing: SWING_PROP_CODE is symbol + period + time + type joined, SWING_PROP_PRICE is the high / low (wick) or the top / bottom of the body (body) of the Bar at `time`
SWING = ("CREATE TABLE IF NOT EXISTS Swing (\n"
         "-- Library V3: class CBarSwingSeries (Entities/Timeseries/SmartMoney/BarSwingSeries.mqh), SWING_PROP_*. time = SWING_PROP_TIME (the pivot bar: a row of Bar), type = SWING_PROP_TYPE\n"
         "-- (ENUM_SWING_TYPE), tf_enum = SWING_PROP_PERIOD, symbol_id = SWING_PROP_SYMBOL. Not saved: SWING_PROP_CODE (made of the key) and SWING_PROP_PRICE (the price of the Bar at time, by price_basis)\n"
         "time INTEGER NOT NULL, confirmed_time INTEGER NOT NULL, type INTEGER NOT NULL, tf_enum INTEGER NOT NULL, strength INTEGER NOT NULL, price_basis INTEGER NOT NULL, "
         "structure INTEGER NOT NULL DEFAULT 0, symbol_id INTEGER NOT NULL, PRIMARY KEY (symbol_id, tf_enum, time, type), "
         "FOREIGN KEY (symbol_id, tf_enum, time) REFERENCES Bar (symbol_id, tf_enum, time)) WITHOUT ROWID")
# MarketStructure: a candle closed beyond a Swing (BOS or CHoCH). MARKET_STRUCTURE_PROP_LEVEL and _STRONG_PRICE are the prices of the Swing at swing_time and at strong_time
MARKET_STRUCTURE = ("CREATE TABLE IF NOT EXISTS MarketStructure (\n"
                    "-- Library V3: class CMarketStructureSeries (Entities/Timeseries/SmartMoney/MarketStructureSeries.mqh), MARKET_STRUCTURE_PROP_*. time = the candle that closed beyond the Swing (a row of Bar),\n"
                    "-- type = BOS or CHoCH, swing_time = the pivot time of the broken Swing (a row of Swing), strong_time = where the move that broke it started (0 = none). Not saved: the CODE (made of the key),\n"
                    "-- LEVEL and STRONG_PRICE (prices of the Swing at swing_time and strong_time)\n"
                    "time INTEGER NOT NULL, type INTEGER NOT NULL, direction INTEGER NOT NULL, tf_enum INTEGER NOT NULL, swing_time INTEGER NOT NULL, phase INTEGER NOT NULL DEFAULT 0, "
                    "strong_time INTEGER NOT NULL DEFAULT 0, symbol_id INTEGER NOT NULL, PRIMARY KEY (symbol_id, tf_enum, time, type), "
                    "FOREIGN KEY (symbol_id, tf_enum, time) REFERENCES Bar (symbol_id, tf_enum, time)) WITHOUT ROWID")
# Lifecycle: one row = one event of one object (Born -> Live -> Dead); the object is told by kind + symbol + period + direction + origin_time. The anchor prices are geometry Python
# calculates (the edges of a zone, the points of a trendline), they are not always the price of a bar, so they are saved
LIFECYCLE = ("CREATE TABLE IF NOT EXISTS Lifecycle (\n"
             "-- Library V3: class CLifecycleSeries (Entities/Timeseries/SmartMoney/LifecycleSeries.mqh), LIFECYCLE_PROP_*. time = the bar of the event (a row of Bar), event = ENUM_LIFECYCLE_EVENT,\n"
             "-- kind = ENUM_LIFECYCLE_OBJECT_KIND, origin_time = the time the object was born. Not saved: the CODE (made of the key)\n"
             "time INTEGER NOT NULL, event INTEGER NOT NULL, kind INTEGER NOT NULL, origin_time INTEGER NOT NULL, tf_enum INTEGER NOT NULL, direction INTEGER NOT NULL, "
             "source INTEGER NOT NULL DEFAULT 0, dead_reason INTEGER NOT NULL DEFAULT 0, anchor_a_time INTEGER NOT NULL, anchor_b_time INTEGER NOT NULL, anchor_a_price REAL NOT NULL, "
             "anchor_b_price REAL NOT NULL, symbol_id INTEGER NOT NULL, PRIMARY KEY (symbol_id, tf_enum, kind, direction, origin_time, event, time)) WITHOUT ROWID")
ACCOUNT_TABLES = (("Bar", BAR), ("Swing", SWING), ("MarketStructure", MARKET_STRUCTURE), ("Lifecycle", LIFECYCLE))

# The timeframes: the values of ENUM_TIMEFRAMES with their text (the library gives the text with TimeframeDescription()). A key to read the tables: tf_enum 16385 is H1.
TIMEFRAMES = ("CREATE TABLE IF NOT EXISTS timeframes (\n-- Library V3: the values of ENUM_TIMEFRAMES, the text is the one of TimeframeDescription() (Services/DELib/TimeseriesDELib.mqh)\n"
              "tf_enum INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE)")
TIMEFRAME_NAMES = ("M1", "M2", "M3", "M4", "M5", "M6", "M10", "M12", "M15", "M20", "M30", "H1", "H2", "H3", "H4", "H6", "H8", "H12", "D1", "W1", "MN1")


# The settings of the candle patterns (CPatternManager): what to show and alert for each pattern. ONE set for every account: the accounts differ by their symbols only. One row =
# one CPatternSetting; the members Python sends again every run (m_candles, m_has_buy, m_has_sell: the catalog of the patterns) and the colours of the markers (inputs of the EA)
# are not saved. Setting_PatternManager has one row (id = 1): the members of the manager itself.
SETTING_PATTERN = ("CREATE TABLE IF NOT EXISTS Setting_Pattern (\n"
                   "-- Library V3: class CPatternSetting (Entities/Settings/PatternSetting.mqh), the rows of CPatternManager (Collections/Settings/PatternManager.mqh)\n"
                   "-- name = m_name (the name Python sends), the others are the members of the same name without m_. The same for every account\n"
                   "name TEXT NOT NULL PRIMARY KEY, buy_signal INTEGER NOT NULL DEFAULT 1, sell_signal INTEGER NOT NULL DEFAULT 1, "
                   "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1)")
SETTING_PATTERN_MANAGER = ("CREATE TABLE IF NOT EXISTS Setting_PatternManager (\n"
                           "-- Library V3: class CPatternManager (Collections/Settings/PatternManager.mqh): ONE row. show_markers = m_show_markers (the check box of the Quick Setting tab); "
                           "m_buy_color and m_sell_color are inputs of the EA\n"
                           "id INTEGER NOT NULL PRIMARY KEY CHECK (id = 1), show_markers INTEGER NOT NULL DEFAULT 0)")

# The catalog of the candle patterns: what each pattern IS (not a setting). Python writes it, the EA reads it. direction = ENUM_PATTERN_DIRECTION: 0 BULLISH (Buy only), 1 BEARISH (Sell only), 2 BOTH.
PATTERN = ("CREATE TABLE IF NOT EXISTS Pattern (\n"
           "-- Library V3: class CBarPattern (PATTERN_PROP_*). name = PATTERN_PROP_NAME, type = PATTERN_PROP_TYPE (ENUM_PATTERN_TYPE), candles = PATTERN_PROP_CANDLES, "
           "direction = PATTERN_PROP_DIRECTION (ENUM_PATTERN_DIRECTION)\n"
           "name TEXT NOT NULL PRIMARY KEY, candles INTEGER NOT NULL, direction INTEGER NOT NULL CHECK (direction IN (0, 1, 2)))")


def safe(text):
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", str(text)).strip("_") or "account"


def canonical(name):
    """The name of a symbol of an account without its suffix: up to the first character that is not an upper-case letter or a digit (XAUUSDc, XAUUSDm
    and XAUUSD.a are XAUUSD). Only used to look for one of OUR symbols: the user decides when it finds none."""
    found = re.match(r"[A-Z0-9]+", name)
    return found.group(0) if found else name


def database_path():
    base = Path(os.environ["LIBDB_DIR"]) if os.environ.get("LIBDB_DIR") else Path(mt5.terminal_info().data_path) / "MQL5" / "Files" / "EA LibV3"
    return base / FOLDER_NAME / FILE_NAME


def account_database_path(info):
    """The file of one account (the bars and what Python calculates from them): <server>_<login>.sqlite3, the account_key, in the same folder."""
    return database_path().parent / f"{account_key(info)}.sqlite3"


def account_key(info):
    """<server>_<login>, letters, digits and _ . - kept: the key of the configuration of the account, of its trade database, of its row here."""
    return f"{safe(info.server)}_{int(info.login)}"


class LibDatabase:
    def __init__(self):
        self.db = None
        self.key = None        # the account written last
        self.touched = 0.0     # when

    def open(self):
        path = database_path()
        path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(str(path), timeout=5.0, isolation_level=None)
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("PRAGMA busy_timeout=5000")
        self.db.execute(ACCOUNTS)
        self.db.execute(SYMBOLS)
        self.db.execute(SYMBOL_ACCOUNT)
        self.db.execute(TIMEFRAMES)
        for name in TIMEFRAME_NAMES:
            self.db.execute("INSERT OR IGNORE INTO timeframes (tf_enum, name) VALUES (?, ?)", (getattr(mt5, "TIMEFRAME_" + name), name))
        self.db.execute(SETTING_SYMBOLTF)
        self.rebuild_symbol_account()
        self.rebuild_setting_symbol_tf()
        self.import_setting_symbol_tf()
        self.rebuild_setting_pattern()
        self.db.execute(SETTING_PATTERN)
        self.db.execute(SETTING_PATTERN_MANAGER)
        self.db.execute("DROP TABLE IF EXISTS Pattern")   # the catalog is written again below: a changed column list needs no migration
        self.db.execute(PATTERN)
        self.fill_pattern()
        self.import_setting_pattern()
        print(f"library database: {path}")

    def rebuild_setting_symbol_tf(self):
        """A Setting_SymbolTF of an earlier layout is made again with the rows it has. Without account_key (one list for everybody) every account gets the pairs of the
        symbols it has (symbol_account); without the REFERENCES to timeframes the rows are copied as they are. A copy of the file is kept next to it first."""
        columns = [row[1] for row in self.db.execute("PRAGMA table_info(Setting_SymbolTF)")]
        references = {row[2] for row in self.db.execute("PRAGMA foreign_key_list(Setting_SymbolTF)")}
        if "account_key" in columns and "timeframes" in references:
            return
        backup = database_path().with_name(Path(FILE_NAME).stem + ".before_setting_symboltf_account_key.sqlite3")
        if not backup.exists():
            copy = sqlite3.connect(str(backup))
            self.db.backup(copy)
            copy.close()
        self.db.execute("BEGIN")
        try:
            self.db.execute("ALTER TABLE Setting_SymbolTF RENAME TO Setting_SymbolTF_old")
            self.db.execute(SETTING_SYMBOLTF)
            flags = "o.buy_signal, o.sell_signal, o.sound_alert, o.message_alert"
            if "account_key" in columns:
                self.db.execute(f"INSERT INTO Setting_SymbolTF (account_key, symbol_id, tf_enum, buy_signal, sell_signal, sound_alert, message_alert) "
                                f"SELECT o.account_key, o.symbol_id, o.tf_enum, {flags} FROM Setting_SymbolTF_old o")
            else:
                self.db.execute(f"INSERT INTO Setting_SymbolTF (account_key, symbol_id, tf_enum, buy_signal, sell_signal, sound_alert, message_alert) "
                                f"SELECT a.account_key, o.symbol_id, o.tf_enum, {flags} FROM Setting_SymbolTF_old o JOIN symbol_account a ON a.symbol_id = o.symbol_id")
            self.db.execute("DROP TABLE Setting_SymbolTF_old")
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        total = self.db.execute("SELECT COUNT(*) FROM Setting_SymbolTF").fetchone()[0]
        print(f"Setting_SymbolTF made again with account_key and the REFERENCES to timeframes: {total} row(s) (a copy of the file before: {backup.name})")

    def import_setting_symbol_tf(self):
        """Only while Setting_SymbolTF is empty: the Symbols_TFs_List of the JSON file of each account (Configuration\\<account_key>\\Config_Setting.json) is copied
        into it under that account_key. The files are only read: they stay where they are. A pair whose symbol is not one the account has joined to one of ours
        (symbol_account) or whose timeframe is not one of the terminal is left out and printed."""
        if self.db.execute("SELECT 1 FROM Setting_SymbolTF LIMIT 1").fetchone() is not None:
            return
        folder = database_path().parent.parent / "Configuration"
        copied, left = 0, set()
        for file in sorted(folder.glob("*/Config_Setting.json")):
            key = file.parent.name
            if self.db.execute("SELECT 1 FROM accounts WHERE account_key = ?", (key,)).fetchone() is None:
                continue
            try:
                data = json.loads(file.read_text(encoding="utf-8-sig"))
            except (OSError, ValueError):
                continue
            for item in data.get("Symbols_TFs_List") or []:
                name, text = item.get("m_symbol"), str(item.get("tf_text"))
                row = self.db.execute("SELECT symbol_id FROM symbol_account WHERE account_key = ? AND account_symbol = ? AND symbol_id IS NOT NULL", (key, name)).fetchone()
                symbol_id = row[0] if row is not None else self.find_symbol(name) if name else None
                tf = getattr(mt5, "TIMEFRAME_" + text, None)
                joined = symbol_id is not None and self.db.execute("SELECT 1 FROM symbol_account WHERE account_key = ? AND symbol_id = ?", (key, symbol_id)).fetchone() is not None
                if not joined or tf is None:
                    left.add(f"{key} {name} {text}")
                    continue
                copied += self.db.execute("INSERT OR IGNORE INTO Setting_SymbolTF (account_key, symbol_id, tf_enum, buy_signal, sell_signal, sound_alert, message_alert) "
                                          "VALUES (?, ?, ?, ?, ?, ?, ?)", (key, symbol_id, tf) + tuple(int(bool(item.get(k, True))) for k in ("m_buy_signal", "m_sell_signal", "m_sound_alert", "m_message_alert"))).rowcount
        if copied or left:
            print(f"Setting_SymbolTF: {copied} pair(s) copied from the configuration of the accounts" + (f", left out (the account has no such symbol of ours): {len(left)}" if left else ""))

    def rebuild_setting_pattern(self):
        """The Setting_Pattern / Setting_PatternManager of the first layout (one set for each account_key) are made again as ONE set: the set of the account that was written
        last is kept. A copy of the file is kept next to it first."""
        columns = [row[1] for row in self.db.execute("PRAGMA table_info(Setting_Pattern)")]
        if "account_key" not in columns:
            return
        backup = database_path().with_name(Path(FILE_NAME).stem + ".before_setting_pattern_global.sqlite3")
        if not backup.exists():
            copy = sqlite3.connect(str(backup))
            self.db.backup(copy)
            copy.close()
        key = self.db.execute("SELECT account_key FROM Setting_Pattern GROUP BY account_key ORDER BY MAX(rowid) DESC LIMIT 1").fetchone()
        key = key[0] if key else None
        show = 0
        if key is not None:
            row = self.db.execute("SELECT show_markers FROM Setting_PatternManager WHERE account_key = ?", (key,)).fetchone()
            show = row[0] if row else 0
        self.db.execute("BEGIN")
        try:
            self.db.execute("ALTER TABLE Setting_Pattern RENAME TO Setting_Pattern_old")
            self.db.execute("DROP TABLE IF EXISTS Setting_PatternManager")
            self.db.execute(SETTING_PATTERN)
            self.db.execute(SETTING_PATTERN_MANAGER)
            if key is not None:
                self.db.execute("INSERT INTO Setting_Pattern (name, buy_signal, sell_signal, sound_alert, message_alert) "
                                "SELECT name, buy_signal, sell_signal, sound_alert, message_alert FROM Setting_Pattern_old WHERE account_key = ? ORDER BY rowid", (key,))
                self.db.execute("INSERT INTO Setting_PatternManager (id, show_markers) VALUES (1, ?)", (show,))
            self.db.execute("DROP TABLE Setting_Pattern_old")
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        total = self.db.execute("SELECT COUNT(*) FROM Setting_Pattern").fetchone()[0]
        print(f"Setting_Pattern made again as one set for every account: {total} pattern(s), the set of {key} (a copy of the file before: {backup.name})")

    def import_setting_pattern(self):
        """Only while Setting_Pattern is empty: "Pattern_Alerts_Setting" and "Pattern_Show_Markers" of Configuration\\Config_Setting.json are copied, in the order of the file.
        The file is only read."""
        if self.db.execute("SELECT 1 FROM Setting_Pattern LIMIT 1").fetchone() is not None:
            return
        file = database_path().parent.parent / "Configuration" / "Config_Setting.json"
        try:
            data = json.loads(file.read_text(encoding="utf-8-sig"))
        except (OSError, ValueError):
            return
        patterns = data.get("Pattern_Alerts_Setting") or {}
        for name, item in patterns.items():
            flags = tuple(int(bool(item.get(k, True))) for k in ("m_pattern_signal_buy", "m_pattern_signal_sell", "m_pattern_alert_sound", "m_pattern_alert_message"))
            self.db.execute("INSERT OR IGNORE INTO Setting_Pattern (name, buy_signal, sell_signal, sound_alert, message_alert) VALUES (?, ?, ?, ?, ?)", (name,) + flags)
        self.db.execute("INSERT OR IGNORE INTO Setting_PatternManager (id, show_markers) VALUES (1, ?)", (int(bool(data.get("Pattern_Show_Markers", False))),))
        if patterns:
            print(f"Setting_Pattern: {len(patterns)} pattern(s) copied from the configuration")

    def register_account(self, info):
        """The account the terminal is logged in to: a row the first time, the last_seen after that."""
        if self.db is None:
            self.open()
        now = int(time.time() * 1000)
        key = account_key(info)
        self.db.execute("INSERT INTO accounts (account_key, server, login, first_seen, last_seen) VALUES (?, ?, ?, ?, ?) "
                        "ON CONFLICT(account_key) DO UPDATE SET last_seen=excluded.last_seen",
                        (key, safe(info.server), int(info.login), now, now))
        new_account = key != self.key
        self.key = key
        self.touched = time.monotonic()
        if new_account:
            self.open_account_database(info)

    def fill_pattern(self):
        """The catalog is what patterns.py defines: written again at every start. "B" = BULLISH 0, "S" = BEARISH 1, "BS" = BOTH 2; Inside Bar (no side) is BOTH as in V2."""
        from patterns import CANDLES, DIRECTIONS
        direction = {"B": 0, "S": 1, "BS": 2, "": 2}
        rows = [(name, candles, direction[DIRECTIONS[name]]) for name, candles in CANDLES.items()]
        self.db.execute("BEGIN")
        try:
            self.db.execute("DELETE FROM Pattern")
            self.db.executemany("INSERT INTO Pattern (name, candles, direction) VALUES (?, ?, ?)", rows)
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise

    def open_account_database(self, info):
        """The file of the account and its tables are there (made when the account is registered; the writers open it themselves). A Bar of the first layout (no prices)
        is made again when it has no rows."""
        path = account_database_path(info)
        path.parent.mkdir(parents=True, exist_ok=True)
        con = sqlite3.connect(str(path), timeout=5.0, isolation_level=None)
        try:
            con.execute("PRAGMA journal_mode=WAL")
            columns = [row[1] for row in con.execute("PRAGMA table_info(Bar)")]
            if columns and "open" not in columns:
                if con.execute("SELECT COUNT(*) FROM Bar").fetchone()[0] == 0:
                    con.execute("DROP TABLE Bar")
                else:
                    print(f"Bar of {path.name} has rows and no prices: left as it is")
            for _, ddl in ACCOUNT_TABLES:
                con.execute(ddl)
        finally:
            con.close()

    def rebuild_symbol_account(self):
        """A symbol_account of an earlier layout (symbol_id NOT NULL, a column confirmed, no REFERENCES) is made again with the lines it has: the lines
        are not changed."""
        columns = {row[1]: row[3] for row in self.db.execute("PRAGMA table_info(symbol_account)")}
        references = self.db.execute("PRAGMA foreign_key_list(symbol_account)").fetchall()
        if columns.get("symbol_id") == 0 and "confirmed" not in columns and references:
            return
        self.db.execute("BEGIN")
        try:
            self.db.execute("ALTER TABLE symbol_account RENAME TO symbol_account_old")
            self.db.execute("CREATE TABLE symbol_account " + SYMBOL_ACCOUNT_COLUMNS)
            self.db.execute("INSERT INTO symbol_account (account_key, account_symbol, symbol_id) SELECT account_key, account_symbol, symbol_id FROM symbol_account_old")
            self.db.execute("DROP TABLE symbol_account_old")
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        print("symbol_account made again (symbol_id can be empty, no confirmed, with REFERENCES)")

    def ensure(self):
        """The file and its tables are there (symbol_account is asked by the trade sync before the first poll of the account)."""
        if self.db is None:
            self.open()

    def find_symbol(self, name):
        """The id of the symbol of ours that this name of an account is: the same name, or the name without its suffix. None when it is none of ours."""
        for candidate in (name, canonical(name)):
            row = self.db.execute("SELECT id FROM symbols WHERE name = ?", (candidate,)).fetchone()
            if row is not None:
                return row[0]
        return None

    def register_symbols(self, names):
        """The Market Watch symbols of the account the terminal is logged in to: each one that has no line yet gets one. It is joined to the symbol of ours
        it is when it is one of the symbols we have; otherwise symbol_id stays empty for the user to fill in (nothing is made in symbols). When another
        symbol of the account is already that symbol of ours (US30 and US30_x10 are not one) this one stays empty too."""
        info = mt5.account_info()
        if info is None:
            return
        if self.db is None:
            self.open()
        key = account_key(info)
        known = {row[0] for row in self.db.execute("SELECT account_symbol FROM symbol_account WHERE account_key = ?", (key,))}
        taken = {row[0] for row in self.db.execute("SELECT symbol_id FROM symbol_account WHERE account_key = ? AND symbol_id IS NOT NULL", (key,))}
        new = sorted((name for name in dict.fromkeys(names) if name and name not in known), key=lambda name: (name != canonical(name), name))
        if not new:
            return
        empty = 0
        self.db.execute("BEGIN")
        try:
            for name in new:
                symbol_id = self.find_symbol(name)
                if symbol_id in taken:
                    symbol_id = None
                if symbol_id is None:
                    empty += 1
                else:
                    taken.add(symbol_id)
                self.db.execute("INSERT INTO symbol_account (account_key, account_symbol, symbol_id) VALUES (?, ?, ?)", (key, name, symbol_id))
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        print(f"symbols of {key}: {len(new)} new line(s) in symbol_account, {empty} of them with no symbol of ours yet")

    def watch_account(self):
        """Called on the rhythm of the server: cheap (one call to the terminal) when the account is the same and was written a moment ago."""
        info = mt5.account_info()
        if info is None:
            return
        if account_key(info) != self.key or time.monotonic() - self.touched >= TOUCH_PERIOD:
            self.register_account(info)

    def close(self):
        if self.db is not None:
            try:
                self.db.close()
            except sqlite3.Error:
                pass
        self.db = None
