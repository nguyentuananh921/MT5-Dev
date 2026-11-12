"""data.py: the bars of the terminal through the MetaTrader5 package."""
import time
from datetime import datetime, timezone
import MetaTrader5 as mt5
import pandas as pd

import libdb   # the table timeframes

TF_UNIT_SECONDS = {"M": 60, "H": 3600, "D": 86400, "W": 604800, "MN": 2678400}   # a month: 31 days

HISTORY_RETRIES = 10
HISTORY_RETRY_SLEEP = 0.3
AFTER_WINDOW_SECONDS = 5 * 86400   # at least this long after a chunk: a weekend has no bars
# A broken link to the terminal fails every call with one of these codes: reconnect and call once more
LINK_ERRORS = (mt5.RES_E_INTERNAL_FAIL_SEND, mt5.RES_E_INTERNAL_FAIL_RECEIVE, mt5.RES_E_INTERNAL_FAIL_INIT,
               mt5.RES_E_INTERNAL_FAIL_CONNECT, mt5.RES_E_INTERNAL_FAIL_TIMEOUT)
RECONNECT_GAP = 5.0   # seconds between two reconnects
_terminal_path = None
_last_reconnect = 0.0


def link_lost():
    return mt5.last_error()[0] in LINK_ERRORS


def reconnect():
    """Open the link again; False when tried a moment ago or failed."""
    global _last_reconnect
    if time.monotonic() - _last_reconnect < RECONNECT_GAP:
        return False
    _last_reconnect = time.monotonic()
    mt5.shutdown()
    ok = mt5.initialize(_terminal_path) if _terminal_path else mt5.initialize()
    print("link to MT5 lost: reconnected" if ok else f"link to MT5 lost: reconnect failed {mt5.last_error()}")
    return bool(ok)


def with_link(call):
    """The call again after a reconnect when the link was lost."""
    def wrapper(*args, **kwargs):
        try:
            result = call(*args, **kwargs)
        except RuntimeError:
            if link_lost() and reconnect():
                return call(*args, **kwargs)
            raise
        if result is None and link_lost() and reconnect():
            return call(*args, **kwargs)
        return result
    wrapper.__name__ = call.__name__
    wrapper.__doc__ = call.__doc__
    return wrapper


def connect(path=None):
    global _terminal_path
    _terminal_path = path
    ok = mt5.initialize(path) if path else mt5.initialize()
    if not ok:
        raise RuntimeError(f"mt5.initialize failed: {mt5.last_error()}")


def disconnect():
    mt5.shutdown()


@with_link
def fetch_closed_bars(symbol, tf_text, count=0):
    """The newest `count` closed bars (0 = all the terminal keeps), oldest first."""
    select_symbol(symbol, tf_text)
    limit = mt5.terminal_info().maxbars - 1   # "Max bars in chart" or more is rejected
    want = min(count + 1, limit) if count > 0 else limit   # +1: the forming bar
    rates = ask_history(lambda: mt5.copy_rates_from_pos(symbol, libdb.timeframes()[tf_text], 0, want), lambda found: len(found) > 1)
    if rates is None or len(rates) < 2:
        raise RuntimeError(f"no rates for {symbol} {tf_text}: {mt5.last_error()}")
    df = pd.DataFrame(rates)
    df = df.iloc[:-1].reset_index(drop=True)   # last row is the forming bar
    df.attrs["point"] = symbol_point(symbol)   # Market Facilitation Index divides by it
    return df


def tf_seconds(tf_text):
    """The length of a bar of a TF in seconds."""
    unit = tf_text.rstrip("0123456789")
    return int(tf_text[len(unit):]) * TF_UNIT_SECONDS[unit]


@with_link
def fetch_last_closed_time(symbol, tf_text):
    """The open time of the newest closed bar."""
    rates = mt5.copy_rates_from_pos(symbol, libdb.timeframes()[tf_text], 0, 2)   # [last closed bar, forming bar]
    if rates is None or len(rates) < 2:
        return None
    return int(rates[0]["time"])


@with_link
def fetch_last_tick(symbol):
    """The last tick (time_msc, time, bid), as CNewTickObj."""
    tick = mt5.symbol_info_tick(symbol)
    if tick is None:
        return None
    return int(tick.time_msc), int(tick.time), float(tick.bid)


def select_symbol(symbol, tf_text):
    """The symbol in the Market Watch and a known TF."""
    if tf_text not in libdb.timeframes():
        raise ValueError(f"unknown timeframe {tf_text}")
    if not mt5.symbol_select(symbol, True):
        raise RuntimeError(f"symbol_select failed for {symbol}: {mt5.last_error()}")


def ask_history(ask, enough=None):
    """`ask()` again while the history syncs (or `enough` says no); None when no answer."""
    rates = None
    for _ in range(HISTORY_RETRIES):
        rates = ask()
        if rates is not None and (enough is None or enough(rates)):
            break
        if mt5.last_error()[0] == mt5.RES_E_INVALID_PARAMS:
            break   # retrying cannot fix this
        time.sleep(HISTORY_RETRY_SLEEP)   # history may still be syncing
    return rates


@with_link
def fetch_bars_before(symbol, tf_text, before_time, count):
    """The `count` closed bars older than `before_time`, oldest first; None when no answer."""
    select_symbol(symbol, tf_text)
    newest = datetime.fromtimestamp(before_time - 1, tz=timezone.utc)   # server time read as UTC
    rates = ask_history(lambda: mt5.copy_rates_from(symbol, libdb.timeframes()[tf_text], newest, count))
    if rates is None:
        return None
    df = pd.DataFrame(rates)
    df.attrs["point"] = symbol_point(symbol)
    return df


@with_link
def fetch_bars_after(symbol, tf_text, from_time, count):
    """The `count` bars from `from_time` on, oldest first (a swing is judged by them); None when no answer."""
    select_symbol(symbol, tf_text)
    first = datetime.fromtimestamp(from_time, tz=timezone.utc)
    last = datetime.fromtimestamp(from_time + max(count * tf_seconds(tf_text) * 3, AFTER_WINDOW_SECONDS), tz=timezone.utc)
    rates = ask_history(lambda: mt5.copy_rates_range(symbol, libdb.timeframes()[tf_text], first, last))
    if rates is None:
        return None
    return pd.DataFrame(rates).head(count)


_points = {}   # asked once per symbol


def symbol_point(symbol):
    if symbol not in _points:
        info = mt5.symbol_info(symbol)
        if info is None:
            return 0.0   # not kept: asked again next time
        _points[symbol] = float(info.point)
    return _points[symbol]
