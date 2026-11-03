"""The database of the library: ONE SQLite file for what the EA and Python share.

The tables follow the classes of the library (accounts = CAccountsCollection, ...). What the terminal already has is not saved: the EA asks
the terminal by the key. Python makes the tables and writes the big data when it starts; the EA writes the small data when an event happens
and sends its config to Python (the Market Watch symbols come with the init message of the EA). Everything is incremental: a line that is
there is never changed by the code that only adds.
"""
import contextlib
import ctypes
import os
import re
import sqlite3
import time
from pathlib import Path

import MetaTrader5 as mt5

PROGRAM_NAME = "EA V4 SQLLite"              # MQL_PROGRAM_NAME: needed to find the database
LIB_DATABASE_FOLDER = "SQLite"              # DatabaseDELib.mqh: needed to find the database
LIB_DATABASE_FILE = PROGRAM_NAME + "_Common.sqlite3"
LIB_ACCOUNTS_FOLDER = "Accounts"            # <account key>.sqlite3
TABLE_BARS = "BarSeriesDE"
TABLE_RESULT = "BarTimeSeriesCollection"
TABLE_IND_RESULT = "SignalsCollection"
TABLE_SYNC = "Setting_Sync"
TABLE_PYTHON_BRIDGE = "Setting_PythonBridge"   # the EA writes its constants here in OnInit, Python reads them (setting)
PLACE_NAMES = ("pid", "alive_at")              # the place of Python, not a setting
BUSY_MS = 60000                      # busy timeout of a write
WRITE_QUEUE_MS = 120000              # max wait for the write turn
EA_FLAG_STALE_SECONDS = 10.0         # an older EA flag file is ignored
WRITE_AGE_SECONDS = 60.0             # gathered rows are written after this long
WRITE_SLOW_SECONDS = 1.0             # a slower turn is printed
SPENT = {"bars": 0.0, "rows": 0.0, "marks": 0.0}   # seconds spent writing (report)
HISTORY_FLAG_NAME = "history_done_{}.flag"         # a History worker of the symbol id is asleep
QUEUE_SECONDS = [0.0]                # seconds waited for the turn (report)
CACHE_KIB = 32768                    # cache of a worker for the account file
PARENT_GONE_SECONDS = 60.0           # a worker stops when the parent mark is older

# accounts, symbol_base, symbols, Setting_SymbolTF and timeframes are made by the EA in OnInit; Python only reads them.



def safe(text):
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", str(text)).strip("_") or "account"


_database_path = None   # the data folder of the terminal does not change while this process lives: the terminal is asked once


def database_path():
    """The file the accounts share: MQL5\\Files\\<program name>\\LIB_DATABASE_FOLDER\\LIB_DATABASE_FILE (DatabaseDELib.mqh); LIBDB_FILE (a full path set by hand to run Python alone) wins."""
    global _database_path
    if os.environ.get("LIBDB_FILE"):
        return Path(os.environ["LIBDB_FILE"])
    if _database_path is None:
        _database_path = Path(mt5.terminal_info().data_path) / "MQL5" / "Files" / PROGRAM_NAME / LIB_DATABASE_FOLDER / LIB_DATABASE_FILE
    return _database_path


def debug_path(name):
    """A file of the Debug folder of the EA (MQL5\\Files\\<program name>\\Debug), the one the EA writes its Breadcrumb.txt to."""
    folder = database_path().parent.parent / "Debug"
    folder.mkdir(parents=True, exist_ok=True)
    return folder / name


_settings = {}   # what the EA decided, read once from the table Setting_PythonBridge (the lines that are not the place of Python)


def load_settings():
    """The lines of Setting_PythonBridge that are what the EA decides, read from the file of the database (its own read-only connection: no write, no turn); the ones
    already there stay when the table is not there yet."""
    link = sqlite3.connect(database_path().as_uri() + "?mode=ro", uri=True, timeout=BUSY_MS / 1000.0)
    try:
        for name, value in link.execute("SELECT name, value FROM " + TABLE_PYTHON_BRIDGE + " WHERE name NOT IN ('pid', 'alive_at')"):
            _settings[name] = value
    except sqlite3.OperationalError:
        pass   # the table is not there yet: the EA makes it in OnInit
    finally:
        link.close()


def setting(name):
    """What the EA decided (a line of Setting_PythonBridge), asked once. KeyError while the EA has not written it: settings_ready() tells."""
    if name not in _settings:
        load_settings()
    return _settings[name]


def setting_int(name):
    return int(setting(name))


def chart_pair():
    """The pair of the chart the EA is on (account symbol, tf_enum): read again each time, the chart can change."""
    load_settings()
    return setting("chart_symbol"), setting_int("chart_tf")


_timeframes = {}


def timeframes():
    """The table timeframes of the EA (CIndicatorTemplateManager makes it): {name: tf_enum}, read once. tf_enum is the value of ENUM_TIMEFRAMES, the same as the
    TIMEFRAME_* of the MetaTrader5 package (no copy of them here)."""
    if not _timeframes:
        link = sqlite3.connect(database_path().as_uri() + "?mode=ro", uri=True, timeout=BUSY_MS / 1000.0)
        try:
            _timeframes.update(link.execute("SELECT name, tf_enum FROM timeframes"))
        finally:
            link.close()
    return _timeframes


def settings_ready():
    """The EA wrote its lines (one INSERT in OnInit: all or none)."""
    load_settings()
    return bool(_settings)


def signal_direction(side):
    """ENUM_SIGNAL_DIRECTION of "BUY" / "SELL" / "NONE", from the EA."""
    return setting_int("signal_" + side.lower())


def store_bars():
    """The bars of the terminal are copied into BarSeriesDE (EA_STORE_BARS of the EA); false: none is kept, they are taken from the terminal when they are judged."""
    return bool(setting_int("store_bars"))


_write_queue = None
_urgent_queue = None
_ea_flag = None
urgent = False   # main.py sets it for the Current and the Live worker: they write before the History workers (the EA before all)


def progress():
    """The program says here that it is alive (set by main.py to its mark_progress: the watchdog of faulthandler); nothing until it does."""


def ea_waits():
    """The EA asked for the first place a moment ago (its file is there and not stale)."""
    global _ea_flag
    try:
        if _ea_flag is None:
            _ea_flag = database_path().parent / setting("write_flag")
        return time.time() - os.path.getmtime(_ea_flag) < EA_FLAG_STALE_SECONDS
    except (OSError, AttributeError, KeyError):
        return False   # no file, or the terminal is not asked yet: the EA is not waiting


def urgent_waits():
    """A Current or Live worker is in the line to write (it holds the mutex of the urgent ones)."""
    kernel32 = ctypes.windll.kernel32
    if kernel32.WaitForSingleObject(_urgent_queue, 0) in (0, 0x80):
        kernel32.ReleaseMutex(_urgent_queue)
        return False
    return True


@contextlib.contextmanager
def write_turn():
    """The turn of a worker to write: the calculation of the workers goes on at the same time, only the writes stand in a line (one commit at a time, in the order the
    workers came). The turn ends when the commit is done: the release lets the next worker in the line write."""
    global _write_queue, _urgent_queue
    held = held_urgent = False
    if os.name == "nt":
        kernel32 = ctypes.windll.kernel32
        if _write_queue is None:
            kernel32.CreateMutexW.restype = ctypes.c_void_p
            kernel32.CreateMutexW.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_wchar_p]
            kernel32.WaitForSingleObject.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
            kernel32.ReleaseMutex.argtypes = [ctypes.c_void_p]
            _write_queue = kernel32.CreateMutexW(None, 0, setting("write_queue"))
            _urgent_queue = kernel32.CreateMutexW(None, 0, setting("write_queue") + "_Urgent")
        if _write_queue:
            clock = time.perf_counter()
            while urgent and not held_urgent:   # the urgent ones stand in a line of their own first: the History workers step aside while it is not empty
                held_urgent = kernel32.WaitForSingleObject(_urgent_queue, 1000) in (0, 0x80)
                if not held_urgent:
                    progress()
            stepped_aside = None   # since when this worker lets the EA pass in this turn
            while True:
                waited = time.perf_counter()
                held = False
                while not held and time.perf_counter() - waited < WRITE_QUEUE_MS / 1000.0:
                    held = kernel32.WaitForSingleObject(_write_queue, 1000) in (0, 0x80)   # WAIT_OBJECT_0, WAIT_ABANDONED (the worker that held it ended)
                    if not held:
                        progress()   # a worker that waits for its turn is not hung: the watchdog of the process is set again each second
                if held and (ea_waits() or (not urgent and urgent_waits())):
                    stepped_aside = stepped_aside or time.perf_counter()
                    if time.perf_counter() - stepped_aside < EA_FLAG_STALE_SECONDS:
                        kernel32.ReleaseMutex(_write_queue)   # the EA has the first place: this worker steps aside until its file is gone (or stale)
                        held = False
                        time.sleep(0.02)
                        progress()   # stepping aside is not a hang either
                        continue
                    print(f"the EA or a worker of the urgent ones asked for the first place for {EA_FLAG_STALE_SECONDS:.0f} s: this worker writes now (the priority is not a lock-out)")
                break
            QUEUE_SECONDS[0] += time.perf_counter() - clock
    try:
        yield
    finally:
        if held:
            kernel32.ReleaseMutex(_write_queue)
        if held_urgent:
            kernel32.ReleaseMutex(_urgent_queue)


_pair_turns = {}


@contextlib.contextmanager
def pair_turn(symbol_id, tf_enum):
    """The turn of a worker on one pair, for one step of its history: a mutex of Windows with the name of the pair, tried and never waited for. It yields True when the
    worker has the pair (another worker goes on to another pair), False when another worker has it. A worker that dies lets it go by itself."""
    held = False
    handle = None
    if os.name != "nt":
        yield True
        return
    kernel32 = ctypes.windll.kernel32
    key = (symbol_id, tf_enum)
    handle = _pair_turns.get(key)
    if handle is None:
        kernel32.CreateMutexW.restype = ctypes.c_void_p
        kernel32.CreateMutexW.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_wchar_p]
        handle = kernel32.CreateMutexW(None, 0, f"Local\\EA_V4_SQLLite_Pair_{symbol_id}_{tf_enum}")
        _pair_turns[key] = handle
    kernel32.WaitForSingleObject.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
    kernel32.ReleaseMutex.argtypes = [ctypes.c_void_p]
    held = bool(handle) and kernel32.WaitForSingleObject(handle, 0) in (0, 0x80)   # WAIT_OBJECT_0, WAIT_ABANDONED
    try:
        yield held
    finally:
        if held:
            kernel32.ReleaseMutex(handle)


MILESTONE_PREFIX = "file_current_", "file_history_"   # the setting lines of the milestone files Python makes


def milestone_set(name):
    """A milestone file (setting line `name`) next to the database: the EA prints it and takes it away."""
    try:
        (database_path().parent / setting(name)).write_text("1")
    except OSError:
        pass


def jobs_changed():
    """The EA made the jobs file (a template or a pair came or went): it is taken away, True."""
    try:
        (database_path().parent / setting("file_jobs")).unlink()
        return True
    except OSError:
        return False   # no file: nothing changed


def milestone_clear(name):
    """A milestone file (setting line `name`) of a run before goes."""
    try:
        (database_path().parent / setting(name)).unlink()
    except OSError:
        pass


def history_done_set(symbol_id, done):
    """The worker of a symbol tells that its history is all there (it sleeps) or that it works again."""
    path = database_path().parent / HISTORY_FLAG_NAME.format(symbol_id)
    try:
        if done:
            path.write_text("1")
        elif path.exists():
            path.unlink()
    except OSError:
        pass


def history_done_ids():
    """The symbols whose worker of the history is asleep."""
    ids = set()
    for path in database_path().parent.glob(HISTORY_FLAG_NAME.format("*")):
        found = re.match(r"history_done_(\d+)\.flag", path.name)
        if found:
            ids.add(int(found.group(1)))
    return ids


def history_done_clear():
    """The parent starts: what an earlier run left is not true any more."""
    folder = database_path().parent
    milestones = [folder / value for name, value in _settings.items() if name.startswith(MILESTONE_PREFIX)]
    for path in list(folder.glob(HISTORY_FLAG_NAME.format("*"))) + milestones:
        try:
            path.unlink()
        except OSError:
            pass


class Source:
    """What is calculated for a pair: a type of information (BarTimeSeriesCollection, key type_infor) or an indicator template (SignalsCollection, key
    template_id). Its rows go to the result table, how far it was done to Setting_Sync (sync_object of the collection, the key as key_id)."""
    def __init__(self, result_table, sync_object, key_names, key_values):
        self.result_table, self.sync_object, self.key_names, self.key_values = result_table, sync_object, tuple(key_names), tuple(key_values)
        self.key_id = key_values[0]


class LibDatabase:
    def __init__(self):
        self.db = None         # the file the accounts share (the settings, the accounts, the symbols)
        self.acc = None        # the file of the account the terminal is logged in to (the bars and what was found on them): Accounts\<account key>.sqlite3
        self.acc_key = None    # the account of that file
        self.login_key = None      # the account_key of the row of the table accounts of the account the terminal is logged in to (asked once)
        self.pending_rows = [] # (sql, rows) of what was found, written by flush_results() in parts of batch_rows rows
        self.pending_marks = []# (key of the source, marks) of how far it was synced, written by flush_results() in one transaction of the file the accounts share
        self.pending_count = 0 # the rows that wait
        self.pending_since = 0.0   # when the first of them came (monotonic)
        self._batch_rows = None   # none: the EA says it (write_rows of Setting_PythonBridge)

    @property
    def batch_rows(self):
        """The rows that make a worker stand in the line, and the rows of one turn."""
        return self._batch_rows if self._batch_rows is not None else setting_int("write_rows")

    @batch_rows.setter
    def batch_rows(self, rows):
        self._batch_rows = rows

    def open(self):
        path = database_path()
        path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(str(path), timeout=BUSY_MS / 1000.0, isolation_level=None)
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("PRAGMA synchronous=NORMAL")
        self.db.execute(f"PRAGMA busy_timeout={BUSY_MS}")
        print(f"library database: {path}")

    def ensure(self):
        """The file and its tables are there (symbols is asked by the trade sync before the first poll of the account)."""
        if self.db is None:
            self.open()

    def current_account(self):
        """The account_key of the account the terminal is logged in to, asked of the table accounts by its login and its server (the row the EA writes in OnInit): None while
        there is no row, and then there is nothing to sync. The key is not made here: the text of the EA is the only one. Only this account is synced, never the other rows.
        The terminal is asked ONCE and the key is kept: when the terminal logs in to another account the EA starts again (OnInit) and clears the place of Python
        (REASON_ACCOUNT), so this Python stops and the EA starts the one of the new account."""
        if self.login_key is not None:
            return self.login_key
        info = mt5.account_info()
        if info is None:
            return None
        if self.db is None:
            self.open()
        row = self.db.execute("SELECT account_key FROM accounts WHERE login = ? AND server = ?", (int(info.login), info.server)).fetchone()
        if row is None:
            return None
        self.login_key = row[0]
        return self.login_key

    def open_account(self):
        """The file of the account the terminal is logged in to: False while it has no row in accounts or its file is not there (the EA makes both when it starts on the account).
        A new account (the terminal logged in to another one) closes the file of the old one."""
        key = self.current_account()
        if key is None:
            return False
        if self.acc is not None and self.acc_key == key:
            return True
        if self.acc is not None:
            self.acc.close()
            self.acc = None
        path = database_path().parent / LIB_ACCOUNTS_FOLDER / (key + ".sqlite3")
        if not path.exists():
            return False
        self.acc = sqlite3.connect(str(path), timeout=BUSY_MS / 1000.0, isolation_level=None)
        self.acc.execute(f"PRAGMA cache_size=-{CACHE_KIB}")   # wal_autocheckpoint stays the default of SQLite: a threshold of 100 MB stopped the commit that crossed it for 9 s (measured)
        self.acc.execute("PRAGMA journal_mode=WAL")   # synchronous stays FULL: what is marked in Setting_Sync is on the disk before the mark (the mark never goes before the rows and the bars)
        self.acc.execute(f"PRAGMA busy_timeout={BUSY_MS}")
        self.acc_key = key
        print(f"account database: {path}")
        return True

    def tables_ready(self):
        """The EA makes the tables of the results in OnInit: Python only adds rows to them."""
        self.ensure()
        names = {row[0] for row in self.db.execute("SELECT name FROM sqlite_master WHERE type = 'table'")}
        if not {TABLE_PYTHON_BRIDGE, TABLE_SYNC, "accounts", "Setting_IndicatorTemplate", "Setting_BarSetup", "Setting_SymbolTF", "symbols", "symbol_base", "timeframes", "indicators"} <= names:
            return False
        if not settings_ready():
            return False   # the EA has not written what it decides (Setting_PythonBridge): it does in OnInit, before it starts Python
        if "id" not in {row[1] for row in self.db.execute("PRAGMA table_info(Setting_IndicatorTemplate)")}:
            return False   # the table of an EA before the id of the template (the key of the signals): the EA makes it new when it starts
        if not self.open_account():
            return False   # no row of this account in accounts yet, or no file of it: the EA makes them when it starts on the account
        names = {row[0] for row in self.acc.execute("SELECT name FROM sqlite_master WHERE type = 'table'")}
        return {TABLE_BARS, TABLE_RESULT, TABLE_IND_RESULT} <= names

    def bridge_python_bridge(self):
        """The place of Python in the table: (the process id that holds it, the seconds since its mark); None when the lines are not there. 0 and a huge age when nobody holds it."""
        place = dict(self.db.execute("SELECT name, value FROM " + TABLE_PYTHON_BRIDGE + " WHERE name IN ('pid', 'alive_at')").fetchall())
        return None if "pid" not in place else (place["pid"], time.time() - place.get("alive_at", 0) / 1000.0)

    def alive_elsewhere_python_bridge(self):
        """Another Python wrote in the table lately: this one must not run too."""
        row = self.bridge_python_bridge()
        return row is not None and row[0] != os.getpid() and row[1] < setting_int("alive_ms") / 1000.0

    def stale_pid_python_bridge(self):
        """The process id of a Python that wrote in the table but not lately (it hangs or it is gone): 0 when there is none."""
        row = self.bridge_python_bridge()
        if row is None or row[0] == os.getpid() or row[1] < setting_int("alive_ms") / 1000.0:
            return 0
        return row[0]

    def silent_python_bridge(self):
        """The seconds since the Python of the table wrote its mark: 0 when there is no row."""
        row = self.bridge_python_bridge()
        return 0.0 if row is None else row[1]

    def parent_alive_python_bridge(self, parent_pid):
        """The Python that started this worker wrote in the table lately (a worker whose parent is gone, or replaced by a new one, stops)."""
        row = self.bridge_python_bridge()
        return row is not None and row[0] == parent_pid and row[1] < PARENT_GONE_SECONDS

    def place_python_bridge(self):
        """The process id that holds the place of the table (the row is made empty when it is not there): 0 when nobody does. Read before the checks that decide to start."""
        self.db.execute("INSERT OR IGNORE INTO " + TABLE_PYTHON_BRIDGE + " (name, value) VALUES ('pid', 0), ('alive_at', 0)")
        return self.bridge_python_bridge()[0]

    def take_place_python_bridge(self, holder, new_pid, mark):
        """The place of the table goes from the process `holder` to `new_pid` with the mark `mark` (0 = the place is given back), in one transaction. False when `holder` does not
        hold it any more."""
        self.db.execute("BEGIN IMMEDIATE")
        try:
            taken = self.db.execute("UPDATE " + TABLE_PYTHON_BRIDGE + " SET value = ? WHERE name = 'pid' AND value = ?", (new_pid, holder)).rowcount == 1
            if taken:
                self.db.execute("UPDATE " + TABLE_PYTHON_BRIDGE + " SET value = ? WHERE name = 'alive_at'", (mark,))
            self.db.commit()
        except Exception:
            self.db.rollback()
            raise
        return taken

    def claim_python_bridge(self, seen):
        """This Python takes the place of the table. Compare and set on the process id seen BEFORE the checks (place_python_bridge): when two Pythons start together only
        one changes the row. False when the row changed in between (another Python took the place first): this one stops."""
        return self.take_place_python_bridge(seen, os.getpid(), int(time.time() * 1000))

    def heartbeat_python_bridge(self):
        """Python is running: the time of its mark (UTC, milliseconds), written only while the place is its own. False when the EA cleared the place (it is closed) or another
        Python took it: this one stops."""
        done = self.db.execute("UPDATE " + TABLE_PYTHON_BRIDGE + " SET value = ? WHERE name = 'alive_at' AND (SELECT value FROM " + TABLE_PYTHON_BRIDGE + " WHERE name = 'pid') = ?",
                               (int(time.time() * 1000), os.getpid()))
        return done.rowcount == 1

    def release_python_bridge(self):
        """This Python leaves: the place is cleared when it is still its own."""
        self.take_place_python_bridge(os.getpid(), 0, 0)

    def pairs(self, symbol_id=None):
        """What is calculated: every symbol of this account that is one of ours (symbols) on every TF of the table timeframes, by tf_enum (one symbol when
        symbol_id is given, the pairs of a worker): (symbol_id, symbol of the account, tf_enum, TF name). Setting_SymbolTF only says what the EA shows."""
        if not self.open_account():
            return []
        rows = self.db.execute("SELECT a.symbol_id, a.name, t.tf_enum, t.name FROM symbols a CROSS JOIN timeframes t "
                               "WHERE a.account_key = ? AND a.symbol_id IS NOT NULL AND (? IS NULL OR a.symbol_id = ?) ORDER BY t.tf_enum, a.rowid",
                               (self.login_key, symbol_id, symbol_id)).fetchall()
        return rows

    def symbols(self):
        """The symbols of ours of this account, a worker for each: [(symbol_id, symbol of the account)]."""
        key = self.current_account()
        if key is None:
            return []
        return self.db.execute("SELECT symbol_id, name FROM symbols WHERE account_key = ? AND symbol_id IS NOT NULL ORDER BY rowid", (key,)).fetchall()

    def library_pairs(self):
        """The pairs the Library (CBarTimeSeriesCollection) keeps up to date after the first load, the ones of Setting_SymbolTF for this account: {(symbol_id, tf_enum)}."""
        key = self.current_account()
        if key is None:
            return set()
        return {(row[0], row[1]) for row in self.db.execute("SELECT symbol_id, tf_enum FROM Setting_SymbolTF WHERE account_key = ?", (key,))}

    def account_symbol(self, name):
        """The name on this account of a symbol of ours (XAUUSD -> XAUUSDc), None when the account has none."""
        key = self.current_account()
        if key is None:
            return None
        row = self.db.execute("SELECT a.name FROM symbols a JOIN symbol_base s ON s.id = a.symbol_id WHERE a.account_key = ? AND s.name = ?",
                              (key, name)).fetchone()
        return None if row is None else row[0]

    def types(self):
        """The types of information: {name: type_infor}."""
        return {name: type_infor for name, type_infor in self.db.execute("SELECT name, type_infor FROM Setting_BarInformation")}

    def all_params(self):
        """The parameters of every type: {type_infor: {param: value}}."""
        out = {}
        for type_infor, param, value in self.db.execute("SELECT type_infor, param, value FROM Setting_BarSetup"):
            out.setdefault(type_infor, {})[param] = value
        return out

    def bars_after(self, symbol_id, tf_enum, from_time, count):
        """The `count` bars of the pair from the bar `from_time` on, the oldest first, from the table of the bars (a DataFrame of the columns of the terminal)."""
        import pandas as pd
        rows = self.acc.execute("SELECT bar_time, open, high, low, close, tick_volume, spread, real_volume FROM " + TABLE_BARS +
                               " WHERE symbol_id = ? AND tf_enum = ? AND bar_time >= ? ORDER BY bar_time LIMIT ?", (symbol_id, tf_enum, from_time, count)).fetchall()
        return pd.DataFrame(rows, columns=["time", "open", "high", "low", "close", "tick_volume", "spread", "real_volume"])

    def write_bars(self, symbol_id, tf_enum, bars):
        """The closed bars (a DataFrame of the terminal) of a pair, one transaction. The table is asked how many of them it holds between the first and the
        last one: all of them, nothing is written; otherwise the chunk is written and the ones that are there stay as they are. Returns the seconds the write took
        (the wait for the turn of the line is not in them: QUEUE_SECONDS). Nothing is written while the EA keeps no bar (store_bars)."""
        if len(bars) == 0 or not store_bars():
            return 0.0
        first, last = int(bars["time"].iloc[0]), int(bars["time"].iloc[-1])
        held = self.acc.execute("SELECT COUNT(*) FROM " + TABLE_BARS + " WHERE symbol_id = ? AND tf_enum = ? AND bar_time BETWEEN ? AND ?", (symbol_id, tf_enum, first, last)).fetchone()[0]
        if held >= len(bars):
            return 0.0
        rows = list(zip([symbol_id] * len(bars), [tf_enum] * len(bars), bars["time"].astype("int64").tolist(), bars["open"].astype(float).tolist(),
                        bars["high"].astype(float).tolist(), bars["low"].astype(float).tolist(), bars["close"].astype(float).tolist(),
                        bars["tick_volume"].astype("int64").tolist(), bars["spread"].astype("int64").tolist(), bars["real_volume"].astype("int64").tolist()))
        spent = 0.0
        for start in range(0, len(rows), self.batch_rows):
            with write_turn():
                clock = time.perf_counter()
                self.acc.execute("BEGIN IMMEDIATE")
                try:
                    self.acc.executemany("INSERT OR IGNORE INTO " + TABLE_BARS + " (symbol_id, tf_enum, bar_time, open, high, low, close, tick_volume, spread, real_volume) "
                                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rows[start:start + self.batch_rows])
                    self.acc.commit()
                except Exception:
                    self.acc.rollback()
                    raise
                took = time.perf_counter() - clock
                spent += took
                if took > WRITE_SLOW_SECONDS:
                    print(f"a turn of {len(rows[start:start + self.batch_rows])} bars took {took:.1f} s")
        SPENT["bars"] += spent
        return spent

    def state(self, source, symbol_id, tf_enum):
        """(newest bar synced, lost_from_time, lost_to_time, who moved the newest bar last) of the pair and the source, None when nothing was synced yet. What is missing
        for the History workers is lost_from_time .. lost_to_time (lost_to_time > lost_from_time; lost_from_time 0: back to the first bar). What waits to be written counts
        as written: the worker does not judge again what it judged a moment ago."""
        row = self.db.execute("SELECT last_update, lost_from_time, lost_to_time, sync_by FROM " + TABLE_SYNC + " WHERE account_key = ? AND symbol_id = ? AND tf_enum = ? AND sync_object = ? AND key_id = ?",
                              (self.acc_key, symbol_id, tf_enum, source.sync_object, source.key_id)).fetchone()
        key = (symbol_id, tf_enum, source.sync_object, source.key_id)
        found = row is not None
        last_update, lost_from, lost_to, sync_by = row if found else (0, 0, 0, setting_int("object_python"))
        for pending_key, values in self.pending_marks:
            if pending_key == key:
                found = True
                last_update, lost_from, lost_to, sync_by = (values.get("last_update", last_update), values.get("lost_from_time", lost_from),
                                                            values.get("lost_to_time", lost_to), values.get("sync_by", sync_by))
        return (last_update, lost_from, lost_to, sync_by) if found else None

    def write_result(self, source, symbol_id, tf_enum, found, last_update=None, lost=None, defer=False):
        """What was found (a list of (bar time, "BUY" or "SELL")) goes to the table of the account, then how far it was synced to Setting_Sync (rows first: when
        this stops in between, the bars are judged again and the rows that are there stay). `last_update`: the newest bar synced (sync_by is Python then); `lost`: (lost_from_time,
        lost_to_time), what is still missing, (0, 0) when nothing is. A mark that is None stays as it was.
        `defer`: it is only put in the line: the line is written when batch_rows rows have gathered (or WRITE_AGE_SECONDS have passed: flush_due), not for each job."""
        keys = ", ".join(source.key_names)
        marker = ", ".join("?" for _ in source.key_names)
        if found:
            self.pending_rows.append(("INSERT OR IGNORE INTO " + source.result_table + " (symbol_id, tf_enum, " + keys + ", bar_time, signal_direction) VALUES (?, ?, " + marker + ", ?, ?)",
                                      [(symbol_id, tf_enum, *source.key_values, bar_time, signal_direction(side)) for bar_time, side in found]))
        marks = {}
        if last_update is not None:
            marks["last_update"] = int(last_update)
            marks["sync_by"] = setting_int("object_python")
        if lost is not None:
            marks["lost_from_time"], marks["lost_to_time"] = int(lost[0]), int(lost[1])
        if not (marks or found):
            return
        if self.pending_count == 0 and not self.pending_marks:
            self.pending_since = time.monotonic()
        self.pending_count += len(found)
        self.pending_marks.append(((symbol_id, tf_enum, source.sync_object, source.key_id), marks))
        if not defer or self.pending_count >= self.batch_rows:
            self.flush_results()

    def flush_due(self):
        """What waits is written when it has waited WRITE_AGE_SECONDS: the marks of a worker that finds little do not stay behind for ever."""
        if (self.pending_rows or self.pending_marks) and time.monotonic() - self.pending_since >= WRITE_AGE_SECONDS:
            self.flush_results()

    def flush_results(self):
        """What the line holds is written: the rows of every job in parts of batch_rows rows (a turn of the line of the writers for each part, so the EA can write between
        two of them), then the marks of every job in one transaction of the file the accounts share, in a turn of its own. Returns the seconds of each (the wait for the turns
        is not in them: QUEUE_SECONDS). What is in the line is gone after it, written or not: a write that fails marks nothing, so the bars are judged again."""
        rows, marks = self.pending_rows, self.pending_marks
        self.pending_rows, self.pending_marks, self.pending_count = [], [], 0
        spent_rows = spent_marks = 0.0
        try:
            for sql, values in rows:
                for start in range(0, len(values), self.batch_rows):
                    part = values[start:start + self.batch_rows]
                    with write_turn():
                        clock = time.perf_counter()
                        self.acc.execute("BEGIN IMMEDIATE")
                        try:
                            self.acc.executemany(sql, part)
                            self.acc.commit()
                        except Exception:
                            self.acc.rollback()
                            raise
                        took = time.perf_counter() - clock
                        spent_rows += took
                        if took > WRITE_SLOW_SECONDS:
                            print(f"a turn of {len(part)} rows took {took:.1f} s")
            written = [mark for mark in marks if mark[1]]   # a line of rows only (no mark) has nothing to write here
            if written:
                with write_turn():
                    clock = time.perf_counter()
                    self.db.execute("BEGIN IMMEDIATE")
                    try:
                        for (symbol_id, tf_enum, sync_object, key_id), values in written:
                            names = list(values)
                            self.db.execute("INSERT INTO " + TABLE_SYNC + " (account_key, symbol_id, tf_enum, sync_object, key_id" + "".join(", " + n for n in names) + ") VALUES (?, ?, ?, ?, ?" + ", ?" * len(names) + ") "
                                            "ON CONFLICT(account_key, symbol_id, tf_enum, sync_object, key_id) DO UPDATE SET " +
                                            ", ".join("last_update = MAX(last_update, excluded.last_update)" if n == "last_update" else f"{n} = excluded.{n}" for n in names),   # the newest bar never goes back (the Library moves it too)
                                            (self.acc_key, symbol_id, tf_enum, sync_object, key_id, *[values[n] for n in names]))
                        self.db.commit()
                    except Exception:
                        self.db.rollback()
                        raise
                    spent_marks = time.perf_counter() - clock
        finally:
            SPENT["rows"] += spent_rows
            SPENT["marks"] += spent_marks
        return spent_rows, spent_marks

    def templates(self):
        """The indicator templates the user has: (id, display, params, type_name, params_total): the id is the key of their signals; type_name (MT5 ENUM_INDICATOR
        without IND_) and params_total come from the table indicators the EA makes (CIndicatorsCollection::OnInitEvent / SyncDataToDB), joined by type_enum."""
        return self.db.execute("SELECT t.id, t.display, t.params, i.type_name, i.params_total FROM Setting_IndicatorTemplate t "
                               "LEFT JOIN indicators i ON i.type_enum = t.type_enum ORDER BY t.id").fetchall()

    def close(self):
        for connection in (self.db, self.acc):
            if connection is not None:
                try:
                    connection.close()
                except sqlite3.Error:
                    pass
        self.db = None
        self.acc = None
