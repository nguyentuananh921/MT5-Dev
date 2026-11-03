"""main.py: Python calculates what is on the bars and writes it to the database; the EA only shows it. The pairs are every symbol of the Market Watch that is
one of ours (symbols) on every TF of the table timeframes (Setting_SymbolTF only says what the EA shows), what is calculated for each pair is a type of information of Setting_BarInformation (Momentum Candle, its parameters in Setting_BarSetup) and every indicator template
of Setting_IndicatorTemplate: a template the user adds gets its signals at once, with no change here. The bars go to BarSeriesDE, what was found to
BarTimeSeriesCollection / SignalsCollection, how far to Setting_Sync. It takes as many bars as the terminal has: the newest ones first, then, whenever
it has nothing else to do, a chunk of older bars at a time, back to the first bar of the history (the data is there for the machine learning later).
The EA starts ONE Python (the parent: the mark of life, the Market Watch) and the parent starts three kinds of worker:
Current (--current, one): the first chunk (the newest bars) of every pair, in this order: the pair of the chart, the other pairs of Setting_SymbolTF, every other pair.
Live (--live, one): the new bars of the pairs that are not in Setting_SymbolTF (the Library does the new bars of the others), from where Current finished.
History (--symbol-id N --parent-pid P, one for every symbol of ours): the steps back in the history of the pairs, back to the first bar, from where Current started; a worker
that has nothing left helps the pairs of the others.
The order to write to the database: the EA and the Library, then Current and Live, then History (libdb.urgent).
A worker gathers what it finds and stands in the line to write when write_rows results have gathered (Setting_PythonBridge: EA_PYTHON_WRITE_ROWS of the EA). Every worker tells where
its time goes (terminal, calculation, what it wrote, the wait for its turn) every REPORT_SECONDS.
Run the EA first (it makes the tables), or let the EA start it:
python main.py   (--terminal "C:\\Program Files\\MetaTrader 5\\terminal64.exe" when there are several terminals)"""
import argparse
import contextlib
import ctypes
import faulthandler
import os
import sqlite3
import subprocess
import sys
import time
import traceback
from pathlib import Path

import pandas as pd

import data
import indicators
import libdb
import momentum
import patterns
import signals
import structure
import swing

CHUNK_BARS = 20000      # the bars of the first load of a pair (the newest ones, so that what the chart shows comes first); Current asks fewer when the pair has a newest bar synced (bars_needed)
REALTIME_BARS = 5000    # the newest bars the Live worker asks at most when a bar closed (bars_needed)
HISTORY_STEP_BARS = 100000   # the bars of each step back in the history of a pair (every job of the pair judges them)
POLL_SECONDS = 0.2      # how often a new bar is looked for: asking the terminal for the last closed bar costs 0.1 ms
TICK_PAUSE_SECONDS = 60   # no tick for this long: the symbol rests, a closed market (the Library: TICK_PAUSE_SECONDS of CNewTickObj)
BUSY_SECONDS = 0.01     # a step of the history was made: the next one follows at once, a new bar is looked at between two steps
BEAT_SECONDS = 1.0      # how often the dead-or-alive mark is written (the EA looks at it every 5 s)
TABLES_WAIT_SECONDS = 5.0
WATCHDOG_SECONDS = 90.0   # a loop that made no progress for this long is stuck in a call of the terminal: the process ends, the EA starts it again
REARM_SECONDS = 0.5       # the watchdog is set again at most this often (a pass has thousands of jobs)
WORKER_CHECK_SECONDS = 5.0   # how often the parent looks for a symbol that has no worker, and a worker looks at its parent
REPORT_SECONDS = 30.0     # how often a worker tells where its time went
FINISHED_FORGET_SECONDS = 60.0   # a pair a worker found with no history left is looked at again after this long
SLEEP_SECONDS = 5.0       # a worker whose history is all there looks again at this pace (a new template, a new symbol wake it)
CURRENT_ID = 0            # the id of the Current worker in the files history_done_N.flag (no symbol has it): it sleeps when every pair has its first chunk

_progress = time.monotonic()   # the last time the loop went round
_beat = -BEAT_SECONDS          # the last time the mark of life was written (monotonic)
_beat_db = None                # the database the mark of life goes to
_not_calculated = set()        # the templates Python cannot calculate (yet), told once
_spent = {"terminal": 0.0, "calculation": 0.0}   # the seconds of this process by where they went (what it wrote: libdb.SPENT, the wait for its turn: libdb.QUEUE_SECONDS)
_write_rows = None   # none: the EA says how many results make a worker stand in the line to write (write_rows of Setting_PythonBridge)
_db = None                     # the database of this worker: what waits in it is written when the process stops
_started = time.monotonic()    # when this process started
_report_at = time.monotonic()  # the last time the seconds were told
_locked = 0                    # how many writes of this process found the database locked (the pass is made again)
_timing_file = None            # the file of the lines about the time (Debug\\Python_Timing.txt of the EA), every worker appends to it
_log_file = None               # the file of this process in the Debug folder of the EA: all it prints and the traceback of the watchdog


def keep_awake():
    """Windows goes to sleep (Modern Standby) when nobody touches the PC: everything stops, and a worker that was writing stopped all the others for 12 minutes. While the
    parent runs, the system is asked not to sleep (the display may go off). The request ends when the parent ends."""
    if os.name != "nt":
        return
    try:
        ES_CONTINUOUS, ES_SYSTEM_REQUIRED = 0x80000000, 0x00000001
        ctypes.windll.kernel32.SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED)
    except Exception:
        pass


def disable_quick_edit():
    """A click in the console selects text, and the console then holds every print (so the process) until Enter: switched off."""
    if os.name != "nt":
        return
    try:
        kernel32 = ctypes.windll.kernel32
        handle = kernel32.GetStdHandle(-10)   # STD_INPUT_HANDLE
        mode = ctypes.c_uint32()
        if kernel32.GetConsoleMode(handle, ctypes.byref(mode)):
            kernel32.SetConsoleMode(handle, (mode.value & ~0x0040) | 0x0080)   # no ENABLE_QUICK_EDIT_MODE, ENABLE_EXTENDED_FLAGS
    except Exception:
        pass


class Tee:
    """What the process prints goes to the console and to its file."""
    def __init__(self, console, handle):
        self.console, self.handle = console, handle

    def write(self, text):
        self.console.write(text)
        try:
            self.handle.write(text)
        except (OSError, ValueError):
            pass
        return len(text)

    def flush(self):
        self.console.flush()
        try:
            self.handle.flush()
        except (OSError, ValueError):
            pass


def start_log(name):
    """The file Debug\\<name> of the EA: print and the errors go to it too (opened for appending: a worker that is started again after a crash keeps what it printed before)."""
    global _log_file
    _log_file = open(libdb.debug_path(name), "a", encoding="utf-8", buffering=1)
    _log_file.write(f"\n===== {time.strftime('%Y-%m-%d %H:%M:%S')} process {os.getpid()} starts =====\n")
    sys.stdout = Tee(sys.stdout, _log_file)
    sys.stderr = Tee(sys.stderr, _log_file)


def arm_watchdog():
    """The watchdog of faulthandler: the traceback of a hung process goes to its file."""
    faulthandler.dump_traceback_later(WATCHDOG_SECONDS, exit=True, file=_log_file if _log_file is not None else sys.__stderr__)


def mark_progress():
    """The loop is alive: the watchdog is set again. It is the one of faulthandler (C code, a thread of its own): a call of the MetaTrader5 package that does not
    return holds the GIL, so a thread of Python would never run to end the process. Ended, the traceback of where it hung is in the log and the EA starts a new one.
    The mark of life goes with it, once a second, also in the middle of a long step, and only while the place in Setting_PythonBridge is this Python's: the EA starts
    Python when the mark is old (PYTHON_ALIVE_MS) and no busy Python runs, and it clears the place when it is closed (this Python then stops)."""
    global _progress, _beat
    now = time.monotonic()
    if now - _progress >= REARM_SECONDS:
        _progress = now
        arm_watchdog()
    if _beat_db is not None and now - _beat >= BEAT_SECONDS:
        _beat = now
        try:
            if not _beat_db.heartbeat_python_bridge():
                print("the place of this Python in Setting_PythonBridge is gone (the EA is closed and cleared it, or another Python took it): it stops with its workers")
                raise SystemExit(0)   # run_parent ends its workers in its finally
        except Exception:
            print(f"the mark of life is not written: {traceback.format_exc()}")   # the database is locked for a moment: the loop goes on


@contextlib.contextmanager
def timed(name):
    """The seconds of the block go to _spent[name]."""
    clock = time.perf_counter()
    try:
        yield
    finally:
        _spent[name] += time.perf_counter() - clock


def log_timing(text):
    """The line goes to the console and to Python_Timing.txt: the console is too fast to be read."""
    print(text)
    if _timing_file is None:
        return
    try:
        with open(_timing_file, "a", encoding="utf-8") as handle:
            handle.write(time.strftime("%H:%M:%S") + " " + text + "\n")
    except OSError:
        pass


def open_database():
    """The database of a worker: it gathers batch_rows results (write_rows of the EA) before it stands in the line to write."""
    global _db
    _db = libdb.LibDatabase()
    if _write_rows is not None:
        _db.batch_rows = _write_rows
    _db.ensure()
    return _db


def flush_pending():
    """What waits to be written is written before the process stops (it stands in the line like any write)."""
    if _db is not None and _db.acc is not None:
        try:
            _db.flush_results()
        except Exception:
            print(f"what waited was not written: {traceback.format_exc()}")


def report(label):
    """Where the time of this process went since it started (the rest is the waiting between two passes and the reading of Setting_Sync)."""
    global _report_at
    now = time.monotonic()
    if now - _report_at < REPORT_SECONDS:
        return
    _report_at = now
    elapsed = now - _started
    spent = libdb.SPENT
    written = spent["bars"] + spent["rows"] + spent["marks"]
    log_timing(f"{label}: {elapsed:.0f} s since start: calculation {_spent['calculation']:.1f} s | written in the database {written:.1f} s (bars {spent['bars']:.1f}, rows {spent['rows']:.1f}, "
               f"marks {spent['marks']:.1f}) | waiting for its turn to write {libdb.QUEUE_SECONDS[0]:.1f} s | terminal {_spent['terminal']:.1f} s | "
               f"the rest {elapsed - _spent['calculation'] - written - libdb.QUEUE_SECONDS[0] - _spent['terminal']:.1f} s | database locked {_locked} times")


class LinePrefix:
    """The workers share the console of the parent: each line a worker prints starts with its symbol."""
    def __init__(self, stream, prefix):
        self.stream, self.prefix, self.at_start = stream, prefix, True

    def write(self, text):
        for part in text.splitlines(True):
            self.stream.write((self.prefix if self.at_start else "") + part)
            self.at_start = part.endswith("\n")
        return len(text)

    def flush(self):
        self.stream.flush()


def python_running(pid):
    """Is the process a Python one that still runs (a hung Python of the EA)?"""
    try:
        out = subprocess.run(["tasklist", "/FI", f"PID eq {pid}", "/FO", "CSV", "/NH"], capture_output=True, text=True, timeout=10).stdout.lower()
    except Exception:
        return False
    return "python" in out


class Job:
    """One thing calculated for every pair: its source (the key of its rows), how many bars before a bar it needs (context) and after it (right: a swing
    is known `strength` bars later), and the calculation itself: calculate(bars, since, until)."""
    def __init__(self, label, source, context, calculate, right=0):
        self.label, self.source, self.context, self.calculate, self.right = label, source, context, calculate, right


def build_jobs(db):
    """What is calculated now: the types of information (Momentum Candle, the patterns, the swings) and one job for every indicator template. Asked each
    time: a change of the user counts at the next new bar."""
    jobs = []
    types, all_params = db.types(), db.all_params()

    def source(type_infor):
        return libdb.Source(libdb.TABLE_RESULT, libdb.setting_int("collection_series"), ("type_infor",), (type_infor,))
    if momentum.NAME in types:
        params = all_params.get(types[momentum.NAME], {})
        jobs.append(Job(momentum.NAME, source(types[momentum.NAME]), momentum.context(params),
                        lambda bars, since, until, params=params: momentum.calculate(bars, params, since, until)))
    for name in patterns.PATTERNS:
        if name in types:
            params = all_params.get(types[name], {})
            jobs.append(Job(name, source(types[name]), patterns.CONTEXT,
                            lambda bars, since, until, name=name, params=params: patterns.calculate(name, bars, params, since, until)))
    for name, high in ((swing.NAME_HIGH, True), (swing.NAME_LOW, False)):
        if name in types:
            params = all_params.get(types[name], {})
            jobs.append(Job(name, source(types[name]), swing.context(params),
                            lambda bars, since, until, high=high, params=params: swing.calculate(high, bars, params, since, until), right=swing.context(params)))
    if swing.NAME_HIGH in types and swing.NAME_LOW in types:   # BOS / CHoCH break the swings of Swing High / Swing Low (their parameters)
        high_params, low_params = all_params.get(types[swing.NAME_HIGH], {}), all_params.get(types[swing.NAME_LOW], {})
        for name, bos in ((structure.NAME_BOS, True), (structure.NAME_CHOCH, False)):
            if name in types:
                jobs.append(Job(name, source(types[name]), structure.context(high_params, low_params),
                                lambda bars, since, until, bos=bos, hp=high_params, lp=low_params: structure.calculate(bos, bars, hp, lp, since, until)))
    for template_id, display, params_text, type_name, params_total in db.templates():
        template = indicators.from_template(type_name, params_total, params_text)   # the type from the table indicators (the EA makes it), not from the display text
        if template is None:
            if display not in _not_calculated:
                _not_calculated.add(display)
                print(f"{display}: not calculated, its params do not fit the table indicators (or Python has no function for it)")
            continue
        name, params = template
        jobs.append(Job(display, libdb.Source(libdb.TABLE_IND_RESULT, libdb.setting_int("collection_signals"), ("template_id",), (template_id,)), indicators.context(params),
                        lambda bars, since, until, name=name, params=params: signals.found(name, bars, params, since, until)))
    return jobs


class Round:
    """One pass of the loop: the bars asked to the terminal once for all the jobs of a pair, and written to the database once."""
    def __init__(self, db):
        self.db, self.cache, self.closed = db, {}, {}
        self.library = db.library_pairs()   # the pairs of Setting_SymbolTF: their new bars are the Library's, Python never calculates them

    def bars(self, pair, count):
        key = (pair[0], pair[2], count)
        if key not in self.cache:
            with timed("terminal"):
                bars = data.fetch_closed_bars(pair[1], pair[3], count)
            self.db.write_bars(pair[0], pair[2], bars)   # the bars first: what is calculated is on them
            self.cache[key] = bars
        return self.cache[key]

    def last_closed(self, pair):
        """The open time of the newest closed bar of the pair, asked to the terminal once in a pass."""
        key = (pair[0], pair[2])
        if key not in self.closed:
            with timed("terminal"):
                self.closed[key] = data.fetch_last_closed_time(pair[1], pair[3])
        return self.closed[key]


class NewTick:
    """The new tick of a symbol, the rule of CNewTickObj of the Library: a symbol with no new tick has no new bar, none of its pairs is asked. No tick for
    TICK_PAUSE_SECONDS: it rests (told once), its first tick after that: it goes on (TICK_EVENT_PAUSE / TICK_EVENT_RESUME of the Library)."""
    server_offset = None   # the server time minus the clock of the PC, from the newest tick seen (TimeTradeServer of the Library)

    def __init__(self, symbol):
        self.symbol, self.prev, self.paused = symbol, None, False   # prev: (time_msc, time, bid) of the check before

    def is_new_tick(self):
        with timed("terminal"):
            tick = data.fetch_last_tick(self.symbol)
        if tick is None:
            return False
        offset = tick[1] - time.time()
        if NewTick.server_offset is None or offset > NewTick.server_offset:
            NewTick.server_offset = offset   # a tick is never later than the server: the newest gives the offset
        if self.prev is None:
            self.prev = tick   # the first launch: the next tick is the new one
            return False
        if tick[0] != self.prev[0]:
            self.prev = tick
            if self.paused:
                self.paused = False
                log_timing(f"live: {self.symbol} ticks again ({time.strftime('%Y.%m.%d %H:%M:%S', time.gmtime(tick[1]))}): it goes on")
            return True
        if not self.paused and time.time() + NewTick.server_offset - self.prev[1] >= TICK_PAUSE_SECONDS:
            self.paused = True
            log_timing(f"live: {self.symbol} has no tick since {time.strftime('%Y.%m.%d %H:%M:%S', time.gmtime(self.prev[1]))} "
                       f"({TICK_PAUSE_SECONDS} s at least): it rests")
        return False


def bars_needed(rnd, pair, jobs, limit):
    """The bars a pass asks for a pair, the rule of every worker: the bars after the oldest newest bar synced of its jobs, plus what a job needs before a bar (context)
    and after it (right: a swing confirmed now sits `right` bars back and needs `context` bars before it). `limit` caps the new bars only, the context is always added:
    more new bars than `limit` is a gap. A job with nothing synced yet: `limit` (the first chunk). The bars of a TF are counted by its length, a weekend counts too:
    it is never fewer than the terminal has."""
    states = [rnd.db.state(job.source, pair[0], pair[2]) for job in jobs]
    if not jobs or any(state is None for state in states):
        return limit
    last_closed = rnd.last_closed(pair)
    if last_closed is None:
        return limit
    new = max(0, int((last_closed - min(state[0] for state in states)) // data.tf_seconds(pair[3]))) + 1
    return min(limit, new) + max(job.context + job.right for job in jobs)


def calculate_new(rnd, pair, job, live, count):
    """The newest bars of a pair for a job. The Current worker (`live` False): the first chunk of a pair that has none (the newest bars, so that what the chart shows comes
    first; what is before the chunk is missing for the History workers), or the bars since the newest bar synced when the machine was off (a chunk that does not reach it leaves
    a gap for the History workers). The Live worker (`live` True): what a bar that closed brings, only the pairs that are not in Setting_SymbolTF (the Library does the others)
    and that Current has made. Returns how many were found, -1 when the pair is not ready for the Live worker (Current has not made its chunk or its gap yet).
    `count`: the bars asked for the pair (bars_needed), the same for every job of the pair. What is found waits in the line of the database until the rows have gathered (write_result)."""
    db = rnd.db
    symbol_id, symbol, tf_enum, tf_text = pair
    state = db.state(job.source, symbol_id, tf_enum)
    if state is None:   # nothing synced yet
        if live:
            return -1
        bars = rnd.bars(pair, CHUNK_BARS)
        with timed("calculation"):
            found = job.calculate(bars, 0, None)
        judged = min(job.context, len(bars) - 1)   # the oldest bars have not the bars before them: they are judged in the next step back
        lost = (0, 0) if len(bars) < CHUNK_BARS else (0, int(bars["time"].iloc[judged]))
        db.write_result(job.source, symbol_id, tf_enum, found, last_update=int(bars["time"].iloc[-1]), lost=lost, defer=True)
        return len(found)
    if live and (symbol_id, tf_enum) in rnd.library:
        return 0   # the new bars of a pair of Setting_SymbolTF are the Library's (it marks them in Setting_Sync)
    last_closed = rnd.last_closed(pair)
    if last_closed is None or last_closed <= state[0]:
        return 0
    if live:
        bars = rnd.bars(pair, count)
        if int(bars["time"].iloc[0]) > state[0] and len(bars) >= count:
            return -1   # the window does not reach the newest bar synced: it is a gap, the Current worker fills the chunk and the History workers the rest
        with timed("calculation"):
            found = job.calculate(bars, state[0], None)
        db.write_result(job.source, symbol_id, tf_enum, found, last_update=int(bars["time"].iloc[-1]), defer=True)
        return len(found)
    bars = rnd.bars(pair, count)
    if int(bars["time"].iloc[0]) <= state[0] or len(bars) < count:   # the bars reach the newest bar synced (or the terminal has no more): no gap
        with timed("calculation"):
            found = job.calculate(bars, state[0], None)
        db.write_result(job.source, symbol_id, tf_enum, found, last_update=int(bars["time"].iloc[-1]), defer=True)
        return len(found)
    with timed("calculation"):
        found = job.calculate(bars, 0, None)
    first_time = int(bars["time"].iloc[min(job.context, len(bars) - 1)])
    missing = state[2] > state[1]   # a history that was not finished is missing too: the gap and what was before it become one piece, back to the first bar
    lost = (0, first_time) if missing else (state[0], first_time)
    db.write_result(job.source, symbol_id, tf_enum, found, last_update=int(bars["time"].iloc[-1]), lost=lost, defer=True)
    return len(found)


def calculate_older(rnd, pair, jobs):
    """One step back for all the jobs of a pair together, in what is missing (lost_from_time .. lost_to_time of Setting_Sync): the bars are asked to the terminal and written once,
    every job judges them. True when a step was made, False when there is nothing to do (nothing is missing), None when the terminal did not answer. What the step found is written
    before it returns: another worker may take the next step of this pair."""
    db = rnd.db
    symbol_id, symbol, tf_enum, tf_text = pair
    written_before = libdb.SPENT["rows"] + libdb.SPENT["marks"]
    states = {}
    for job in jobs:
        state = db.state(job.source, symbol_id, tf_enum)
        if state is not None and state[2] > state[1]:   # the first chunk is done, something is missing before it
            states[job] = state
    if not states:
        return False
    end = max(state[2] for state in states.values())   # the chunk ends before the youngest of the oldest bars judged: a job that went further back is skipped for it
    ask = HISTORY_STEP_BARS
    if all(state[1] > 0 for state in states.values()):   # a gap, not the whole history: the bars of the gap and the bars the jobs need before it
        ask = min(ask, int((end - min(state[1] for state in states.values())) // data.tf_seconds(tf_text)) + 1 + max(job.context for job in states))
    clock = time.perf_counter()
    bars = data.fetch_bars_before(symbol, tf_text, end, ask)
    if bars is None:
        return None   # the terminal did not answer: the next pass asks again
    spent_fetch = time.perf_counter() - clock
    _spent["terminal"] += spent_fetch
    if len(bars) == 0:
        for job in states:
            db.write_result(job.source, symbol_id, tf_enum, [], lost=(0, 0), defer=True)
        db.flush_results()
        print(f"{symbol} {tf_text}: the history is all there, back to {time.strftime('%Y-%m-%d %H:%M', time.gmtime(end))} ({len(states)} jobs)")
        return True
    spent_bars = db.write_bars(symbol_id, tf_enum, bars)
    start = int(bars["time"].iloc[0])
    done = len(bars) < ask   # fewer than asked: the first bar of the history is in it
    total = 0
    spent_calculate = spent_write = 0.0
    for job, state in states.items():
        mark_progress()
        if state[2] <= start:   # this job went back further than the chunk starts: nothing in it is new for it
            if done:
                db.write_result(job.source, symbol_id, tf_enum, [], lost=(0, 0), defer=True)
            continue
        judged = min(job.context, len(bars) - 1)
        first_time = min(int(bars["time"].iloc[judged]), state[2])
        part = bars
        if job.right:   # what is judged by the bars after it (a swing): the bars after the chunk, from the table or, when none is kept, from the terminal
            point = bars.attrs.get("point")
            after_time = int(bars["time"].iloc[-1]) + 1
            if libdb.store_bars():
                after = db.bars_after(symbol_id, tf_enum, after_time, job.right)
            else:
                after = data.fetch_bars_after(symbol, tf_text, after_time, job.right)
                if after is None:
                    continue   # the terminal did not answer: the job is judged again at the next pass (its state did not move)
            part = pd.concat([bars, after], ignore_index=True)
            part.attrs["point"] = point
        clock = time.perf_counter()
        found = job.calculate(part, 0, state[2])
        spent_calculate += time.perf_counter() - clock
        finished = done or first_time <= state[1]   # the first bar, or the end of the gap, is reached: nothing is missing any more
        db.write_result(job.source, symbol_id, tf_enum, found, lost=(0, 0) if finished else (state[1], first_time), defer=True)
        total += len(found)
    _spent["calculation"] += spent_calculate
    db.flush_results()
    spent_write = libdb.SPENT["rows"] + libdb.SPENT["marks"] - written_before   # what was written while the step went on (the rows wait until enough have gathered)
    print(f"{symbol} {tf_text}: back to {time.strftime('%Y-%m-%d %H:%M', time.gmtime(start))}, {total} found by {len(states)} jobs, {len(bars)} bars in {spent_fetch + spent_bars + spent_calculate + spent_write:.1f} s "
          f"(terminal {spent_fetch:.1f}, bars {spent_bars:.1f}, calculation {spent_calculate:.1f}, rows {spent_write:.1f})" + (" (the first bar)" if done else ""))
    return True


def count_locked(pair, label, error):
    """A write waited for the other writers longer than BUSY_MS and was refused: nothing was marked as done, the next pass makes it again. One line, not a traceback."""
    global _locked
    _locked += 1
    print(f"{pair[1]} {pair[3]} {label}: {error} (the next pass tries again)")


def worker_command(terminal, role, symbol_id=None):
    """The command of a worker: the Current one, the Live one (role "current", "live") or the History one of a symbol (role "history")."""
    command = [sys.executable, str(Path(__file__).resolve()), "--parent-pid", str(os.getpid())]
    command += ["--symbol-id", str(symbol_id)] if role == "history" else ["--" + role]
    if terminal:
        command += ["--terminal", terminal]
    return command


def run_parent(terminal):
    """The Python the EA starts: it writes the mark of life, reads the Market Watch and keeps a worker running for every symbol of ours."""
    global _timing_file
    _timing_file = libdb.debug_path("Python_Timing.txt")   # the milestones of the parent (OnInit complete, history complete) are in the file of the times too
    start_log("Python_Parent.txt")
    keep_awake()
    db = libdb.LibDatabase()
    db.ensure()
    while not db.tables_ready():
        print(f"the tables are not there yet: run the EA first (waiting {TABLES_WAIT_SECONDS:.0f} s)")
        time.sleep(TABLES_WAIT_SECONDS)
    seen = db.place_python_bridge()   # who holds the place now: the claim below succeeds only if nobody changed it since
    if db.alive_elsewhere_python_bridge():
        print("another Python is running already: this one stops")
        return
    stale = db.stale_pid_python_bridge()
    if stale and python_running(stale):
        silent = db.silent_python_bridge()
        if silent < libdb.setting_int("hung_ms") / 1000.0:
            print(f"the Python {stale} wrote nothing for {silent:.0f} s but still runs (busy, the history is loading): this one stops")
            return   # a busy Python is not ended: a new one would load the history again and be as busy
        print(f"the Python {stale} wrote nothing for {silent:.0f} s and still runs (hung): it is ended with its workers")
        subprocess.run(["taskkill", "/PID", str(stale), "/T", "/F"], capture_output=True, timeout=10)
    if not db.claim_python_bridge(seen):
        print("another Python took the place of the table first: this one stops")
        return
    arm_watchdog()
    global _beat_db
    _beat_db = db
    libdb.history_done_clear()
    libdb.jobs_changed()   # a file of the EA from before this Python: the Current worker starts with the jobs of now anyway
    workers = {}   # symbol_id -> the process of the history of the symbol, "current" -> the one of the first chunks, "live" -> the one of the new bars
    model = None   # what the Current worker was started for (the symbols, how many jobs): when it changes, the Current worker runs again
    all_asleep = False
    last_check = -WORKER_CHECK_SECONDS
    try:
        while True:
            mark_progress()
            if libdb.jobs_changed():   # the EA told it (a template or a pair came or went): the Current worker runs again now for the new jobs, not at the next check
                current = workers.get("current")
                if current is not None and current.poll() is None:
                    current.terminate()
                    current.wait(timeout=10)
                model = None
                last_check = -WORKER_CHECK_SECONDS
                print("the jobs changed (the EA told it): the Current worker runs again")
            now = time.monotonic()
            if now - last_check >= WORKER_CHECK_SECONDS:
                last_check = now
                # Paused: only the Current worker runs for now
                # for symbol_id, name in db.symbols():
                #     worker = workers.get(symbol_id)
                #     if worker is not None and worker.poll() is None:
                #         continue
                #     if worker is not None:
                #         print(f"{name}: its worker ended (code {worker.returncode}), a new one is started")
                #     workers[symbol_id] = subprocess.Popen(worker_command(terminal, "history", symbol_id))
                #     print(f"{name}: history worker started (process {workers[symbol_id].pid}), {len(workers)} workers")
                symbols_now = {symbol_id for symbol_id, _ in db.symbols()}
                asleep = bool(symbols_now) and symbols_now | {CURRENT_ID} <= libdb.history_done_ids()   # Current has made every first chunk too
                if asleep != all_asleep:
                    all_asleep = asleep
                    if asleep:
                        libdb.milestone_set("file_history_done")
                    log_timing(f"history complete: the Current worker and all the {len(symbols_now)} workers of the history are asleep, {time.monotonic() - _started:.0f} s after the start" if asleep else
                               "history: a worker of the history is awake again")
                try:
                    now_model = (frozenset(symbol_id for symbol_id, _ in db.symbols()), len(build_jobs(db)))
                except Exception:
                    now_model = model
                for role in ("current", "live"):   # History is paused (Update Note)
                    worker = workers.get(role)
                    if worker is None or worker.poll() is not None:
                        if role == "current" and worker is not None and worker.returncode == 0 and now_model == model:
                            continue   # the Current worker made every first chunk and ended: it runs again only when the symbols or the jobs change
                        if worker is not None:
                            print(f"{role}: its worker ended (code {worker.returncode}), a new one is started")
                        if role == "current":
                            model = now_model
                        workers[role] = subprocess.Popen(worker_command(terminal, role))
                        print(f"{role}: worker started (process {workers[role].pid}), {len(workers)} workers")
            time.sleep(BEAT_SECONDS)
    finally:
        for worker in workers.values():
            if worker.poll() is None:
                worker.terminate()
        try:
            db.release_python_bridge()   # the row is cleared when the place is still ours: the EA starts the next one without waiting
        except Exception:
            print(f"the place is not given back: {traceback.format_exc()}")


def run_worker(symbol_id, parent_pid):
    """The History worker of one symbol: one step back in the history of the next pair that has any left (the first chunk is the Current worker's), back to the first bar."""
    db = open_database()
    while not db.tables_ready():
        time.sleep(TABLES_WAIT_SECONDS)
    symbols = db.symbols()
    name = dict(symbols).get(symbol_id, str(symbol_id))
    global _timing_file
    _timing_file = libdb.debug_path("Python_Timing.txt")
    sys.stdout = LinePrefix(sys.stdout, f"[{name}] ")   # the console is shared with the other workers
    start_log(f"Python_{libdb.safe(name)}.txt")
    log_timing(f"{name}: worker of the parent {parent_pid} starts")
    libdb.history_done_set(symbol_id, False)
    arm_watchdog()
    last_check = time.monotonic()
    turn = 0   # the pair whose history goes back next
    was_busy = True
    finished = set()   # the pairs this worker found with no history left: not looked at again for a while (a new template or symbol can bring work)
    finished_at = time.monotonic()
    jobs_seen = -1
    while True:
        mark_progress()
        if time.monotonic() - last_check >= WORKER_CHECK_SECONDS:
            last_check = time.monotonic()
            if not db.parent_alive_python_bridge(parent_pid):
                print("the Python that started this one is gone: it stops")
                flush_pending()
                return
        busy = False
        rnd = Round(db)
        jobs = build_jobs(db)
        pairs = db.pairs(symbol_id)
        #--- One step back in the history of a pair that has any left: the pairs of this symbol first, then the pairs of the other symbols (a worker that has
        #--- none left helps). A pair is taken for one step (pair_turn): two workers are never on the same pair
        if len(jobs) != jobs_seen or time.monotonic() - finished_at >= FINISHED_FORGET_SECONDS:
            finished.clear()
            finished_at = time.monotonic()
            jobs_seen = len(jobs)
        others = sorted((pair for pair in db.pairs() if pair[0] != symbol_id), key=lambda pair: (data.tf_seconds(pair[3]), (pair[0] - symbol_id) % 1000003))   # the deepest TFs first
        candidates = [pairs[(turn + k) % len(pairs)] for k in range(len(pairs))] + others if pairs else others
        for pair in candidates:
            key = (pair[0], pair[2])
            if key in finished:
                continue
            mark_progress()
            try:
                with libdb.pair_turn(pair[0], pair[2]) as held:
                    if not held:
                        continue
                    stepped = calculate_older(rnd, pair, jobs)
                    if stepped:
                        if pair[0] == symbol_id:
                            turn = (pairs.index(pair) + 1) % len(pairs)
                        busy = True
                        break
                    if stepped is False:
                        finished.add(key)
            except sqlite3.OperationalError as error:
                count_locked(pair, "history", error)
            except Exception:
                print(f"{pair[1]} {pair[3]}: {traceback.format_exc()}")
        try:
            db.flush_due()   # what waits and is old is written
        except sqlite3.OperationalError as error:
            count_locked(("", "", 0, ""), "write", error)
        report(name)
        if busy:
            if not was_busy:
                libdb.history_done_set(symbol_id, False)
                log_timing(f"{name}: awake, the history of a pair is not all there")
            was_busy = True
        elif was_busy:
            was_busy = False
            flush_pending()   # the history is all there: the rest of what waited is written
            libdb.history_done_set(symbol_id, True)
            log_timing(f"{name}: history done, {time.monotonic() - _started:.0f} s after the start, going to sleep: " + ", ".join(f"{key} {seconds:.1f} s" for key, seconds in _spent.items()))
        time.sleep(BUSY_SECONDS if busy else (POLL_SECONDS if was_busy else SLEEP_SECONDS))


def run_current(parent_pid):
    """The Current worker: the newest bars of every pair (the first chunk, or what the machine missed while it was off), the pair of the chart first, then the other pairs
    of Setting_SymbolTF, then every other pair. What it finds for a pair is written at once for the first two kinds (the chart and the manager wait for it), the others gather
    the results. It runs once: it ends when a pass has nothing left (the parent starts it again when the symbols or the jobs change)."""
    db = open_database()
    while not db.tables_ready():
        time.sleep(TABLES_WAIT_SECONDS)
    global _timing_file
    _timing_file = libdb.debug_path("Python_Timing.txt")
    sys.stdout = LinePrefix(sys.stdout, "[current] ")
    start_log("Python_current.txt")
    log_timing(f"current: worker of the parent {parent_pid} starts")
    libdb.milestone_clear("file_current_symboltf")   # the Setting_SymbolTF milestone of a run before: the library waits for the one of this run
    libdb.milestone_set("file_current_start")
    libdb.urgent = True
    libdb.history_done_set(CURRENT_ID, False)
    arm_watchdog()
    last_check = time.monotonic()
    chart_told = False
    oninit_told = False
    while True:
        mark_progress()
        if time.monotonic() - last_check >= WORKER_CHECK_SECONDS:
            last_check = time.monotonic()
            if not db.parent_alive_python_bridge(parent_pid):
                print("the Python that started this one is gone: it stops")
                flush_pending()
                return
        failed = False   # a write was refused: the pass is made again
        written = libdb.SPENT["marks"]
        rnd = Round(db)
        jobs = build_jobs(db)
        try:
            chart = libdb.chart_pair()
        except (KeyError, sqlite3.OperationalError):
            chart = None   # the EA has not written the pair of the chart yet
        pairs = db.pairs()
        pairs.sort(key=lambda pair: 0 if chart == (pair[1], pair[2]) else 1 if (pair[0], pair[2]) in rnd.library else 2)
        for pair in pairs:
            first = chart == (pair[1], pair[2]) or (pair[0], pair[2]) in rnd.library
            try:
                asked = bars_needed(rnd, pair, jobs, CHUNK_BARS)
            except Exception:
                asked = CHUNK_BARS
            for job in jobs:
                mark_progress()
                try:
                    count = calculate_new(rnd, pair, job, False, asked)
                    if count > 0:
                        print(f"{pair[1]} {pair[3]} {job.label}: {count} found")
                except sqlite3.OperationalError as error:
                    failed = True
                    count_locked(pair, job.label, error)
                except Exception:
                    print(f"{pair[1]} {pair[3]} {job.label}: {traceback.format_exc()}")
            if first:
                try:
                    db.flush_results()   # the pair of the chart and the ones of the manager are in the database now, not when enough results have gathered
                except sqlite3.OperationalError as error:
                    failed = True
                    count_locked(pair, "write", error)
            if chart == (pair[1], pair[2]) and not chart_told:
                chart_told = True
                libdb.milestone_set("file_current_chart")
                log_timing(f"current: the chart pair {pair[1]} {pair[3]} is in the database, {time.monotonic() - _started:.0f} s after the start")
            if not first and not oninit_told:
                oninit_told = True
                libdb.milestone_set("file_current_symboltf")
                log_timing(f"OnInit complete: the newest bars of the chart pair and of the pairs of Setting_SymbolTF are in the database, {time.monotonic() - _started:.0f} s after the start. "
                           f"Now the others, then the history (a worker for each symbol) and the new bars (the live worker)")
        try:
            db.flush_results()
        except sqlite3.OperationalError as error:
            failed = True
            count_locked(("", "", 0, ""), "write", error)
        report("current")
        busy = failed or libdb.SPENT["marks"] != written   # something was marked: the next pass looks for what is left
        if not busy:
            if not chart_told:
                libdb.milestone_set("file_current_chart")   # the chart pair is not one of ours: nothing to wait for
            if not oninit_told:
                libdb.milestone_set("file_current_symboltf")   # no pair outside Setting_SymbolTF to wait for
            libdb.history_done_set(CURRENT_ID, True)
            log_timing(f"current: the newest bars of every pair are there, {time.monotonic() - _started:.0f} s after the start, it ends")
            libdb.milestone_set("file_current_done")
            return
        libdb.history_done_set(CURRENT_ID, False)
        time.sleep(SLEEP_SECONDS if failed else BUSY_SECONDS)


def run_live(parent_pid):
    """The new bars of the pairs that are not in Setting_SymbolTF (the Library does the others), for every symbol: what it finds is for later, nobody waits for it, so it
    gathers the results and stands in the line to write when enough have gathered."""
    db = open_database()
    while not db.tables_ready():
        time.sleep(TABLES_WAIT_SECONDS)
    global _timing_file
    _timing_file = libdb.debug_path("Python_Timing.txt")
    sys.stdout = LinePrefix(sys.stdout, "[live] ")
    start_log("Python_live.txt")
    log_timing(f"live: worker of the parent {parent_pid} starts")
    libdb.urgent = True
    arm_watchdog()
    last_check = time.monotonic()
    alone = False   # every worker of the history is asleep: nobody else writes, it writes what it finds at once
    seen = {}   # (symbol_id, tf_enum) -> the newest closed bar that was judged: nothing is asked to the database while it is the same
    pairs = db.pairs()   # asked again with the parent (WORKER_CHECK_SECONDS), not at each pass
    ticks = {}   # symbol -> NewTick (CNewTickObj of the Library): made at the start, as the series of the EA at OnInit
    for symbol in {pair[1] for pair in pairs}:
        ticks[symbol] = NewTick(symbol)
        ticks[symbol].is_new_tick()   # the first launch: the tick of now is kept
    while True:
        mark_progress()
        if time.monotonic() - last_check >= WORKER_CHECK_SECONDS:
            last_check = time.monotonic()
            if not db.parent_alive_python_bridge(parent_pid):
                print("the Python that started this one is gone: it stops")
                flush_pending()
                return
            pairs = db.pairs()
            symbols_now = {symbol_id for symbol_id, _ in db.symbols()}
            now_alone = bool(symbols_now) and symbols_now | {CURRENT_ID} <= libdb.history_done_ids()
            if now_alone != alone:
                alone = now_alone
                log_timing("live: all the workers of the history are asleep, it writes what it finds at once" if alone else
                           f"live: a worker of the history is awake, it gathers {libdb.setting_int('write_rows')} results before it writes")
        if CURRENT_ID not in libdb.history_done_ids():
            time.sleep(POLL_SECONDS)   # Current runs: Live goes on from where it finished (one writer for a pair at a time)
            continue
        ticked = set()   # the symbols with a new tick: only they can have a new bar (CBarTimeSeriesCollection::RefreshSeriesAllExceptCurrent)
        for symbol in {pair[1] for pair in pairs}:
            if symbol not in ticks:
                ticks[symbol] = NewTick(symbol)
            if ticks[symbol].is_new_tick():
                ticked.add(symbol)
        rnd = Round(db) if ticked else None   # no tick anywhere: nothing is asked to the database
        jobs = build_jobs(db) if ticked else []
        for pair in (pairs if ticked else []):
            if pair[1] not in ticked:
                continue   # no new tick: no new bar on any TF of the symbol (a closed market rests)
            if (pair[0], pair[2]) in rnd.library:
                continue   # a pair of Setting_SymbolTF: its new bars are the Library's, nothing is asked to the terminal or the database for it
            try:
                closed = rnd.last_closed(pair)
            except Exception:
                print(f"{pair[1]} {pair[3]}: {traceback.format_exc()}")
                continue
            key = (pair[0], pair[2])
            if closed is None or seen.get(key) == closed:
                continue
            ready = True   # every job found the first chunk of the pair
            try:
                asked = bars_needed(rnd, pair, jobs, REALTIME_BARS)
            except Exception:
                asked = REALTIME_BARS
            for job in jobs:
                mark_progress()
                try:
                    count = calculate_new(rnd, pair, job, True, asked)
                    if count < 0:
                        ready = False   # the worker of the symbol has not made the first chunk yet: the pair is looked at again
                    elif count:
                        print(f"{pair[1]} {pair[3]} {job.label}: {count} found")
                except sqlite3.OperationalError as error:
                    count_locked(pair, job.label, error)
                    ready = False
                except Exception:
                    print(f"{pair[1]} {pair[3]} {job.label}: {traceback.format_exc()}")
            if ready:
                seen[key] = closed
        try:
            if alone:
                db.flush_results()   # nobody waits in the line: what was found is written now
            else:
                db.flush_due()
        except sqlite3.OperationalError as error:
            count_locked(("", "", 0, ""), "write", error)
        report("live")
        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--terminal", default=None, help="path to terminal64.exe when several terminals are installed")
    parser.add_argument("--symbol-id", type=int, default=None, help="a History worker: the symbol (id of the table symbol_base) it goes back in; none, no --live and no --current = the parent that starts the workers")
    parser.add_argument("--current", action="store_true", help="the Current worker: the first chunk of every pair, the pair of the chart first")
    parser.add_argument("--live", action="store_true", help="the worker of the new bars of the pairs that are not in Setting_SymbolTF")
    parser.add_argument("--parent-pid", type=int, default=0, help="a worker: the process of the parent Python (the worker stops when it is gone)")
    args = parser.parse_args()   # what the EA decides (the rows of a turn, whether the bars are kept...) is in the table Setting_PythonBridge, not here
    libdb.progress = mark_progress   # the wait for the turn to write sets the watchdog again: it is not a hang
    disable_quick_edit()
    data.connect(args.terminal)
    print("connected to MT5")
    try:
        if args.current:
            run_current(args.parent_pid)
        elif args.live:
            run_live(args.parent_pid)
        elif args.symbol_id is not None:
            run_worker(args.symbol_id, args.parent_pid)
        else:
            run_parent(args.terminal)
    except KeyboardInterrupt:
        pass
    finally:
        flush_pending()
        data.disconnect()
        print("stopped")
