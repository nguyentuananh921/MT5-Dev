"""data.py: the bars of the terminal, asked through the MetaTrader5 package. Only what main.py asks for comes from Lib V3."""
import time
from datetime import datetime, timezone
import MetaTrader5 as mt5
import pandas as pd

TIMEFRAMES = {
    "M1": mt5.TIMEFRAME_M1, "M2": mt5.TIMEFRAME_M2, "M3": mt5.TIMEFRAME_M3, "M4": mt5.TIMEFRAME_M4,
    "M5": mt5.TIMEFRAME_M5, "M6": mt5.TIMEFRAME_M6, "M10": mt5.TIMEFRAME_M10, "M12": mt5.TIMEFRAME_M12,
    "M15": mt5.TIMEFRAME_M15, "M20": mt5.TIMEFRAME_M20, "M30": mt5.TIMEFRAME_M30,
    "H1": mt5.TIMEFRAME_H1, "H2": mt5.TIMEFRAME_H2, "H3": mt5.TIMEFRAME_H3, "H4": mt5.TIMEFRAME_H4,
    "H6": mt5.TIMEFRAME_H6, "H8": mt5.TIMEFRAME_H8, "H12": mt5.TIMEFRAME_H12,
    "D1": mt5.TIMEFRAME_D1, "W1": mt5.TIMEFRAME_W1, "MN1": mt5.TIMEFRAME_MN1,
}   # the names are the ones of the table timeframes of the database

TF_UNIT_SECONDS = {"M": 60, "H": 3600, "D": 86400, "W": 604800, "MN": 2678400}   # the letters of a TF name (a month is the longest one: 31 days)

HISTORY_RETRIES = 10
HISTORY_RETRY_SLEEP = 0.3
AFTER_WINDOW_SECONDS = 5 * 86400   # the time asked for the bars after a chunk is at least this long: a weekend has none
# The link between this process and the terminal can break while both run (the terminal was busy or restarted): every call then
# fails with one of these codes and nothing brings it back. A call that fails like that opens the link again and is made once more
LINK_ERRORS = (mt5.RES_E_INTERNAL_FAIL_SEND, mt5.RES_E_INTERNAL_FAIL_RECEIVE, mt5.RES_E_INTERNAL_FAIL_INIT,
               mt5.RES_E_INTERNAL_FAIL_CONNECT, mt5.RES_E_INTERNAL_FAIL_TIMEOUT)
RECONNECT_GAP = 5.0   # seconds: no reconnecting storm while the terminal is down
_terminal_path = None
_last_reconnect = 0.0


def link_lost():
    return mt5.last_error()[0] in LINK_ERRORS


def reconnect():
    """Open the link to the terminal again; False when it was tried a moment ago or did not work."""
    global _last_reconnect
    if time.monotonic() - _last_reconnect < RECONNECT_GAP:
        return False
    _last_reconnect = time.monotonic()
    mt5.shutdown()
    ok = mt5.initialize(_terminal_path) if _terminal_path else mt5.initialize()
    print("link to MT5 lost: reconnected" if ok else f"link to MT5 lost: reconnect failed {mt5.last_error()}")
    return bool(ok)


def with_link(call):
    """The call again after reconnecting, when it failed because the link is gone."""
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
    """The newest `count` closed bars (0 = everything the terminal keeps), the oldest first; the forming bar is not in it."""
    select_symbol(symbol, tf_text)
    limit = mt5.terminal_info().maxbars - 1   # the terminal rejects a request of "Max bars in chart" bars or more
    want = min(count + 1, limit) if count > 0 else limit   # one more: the forming bar is not given back, so `count` closed bars come when the terminal has them
    rates = ask_history(lambda: mt5.copy_rates_from_pos(symbol, TIMEFRAMES[tf_text], 0, want), lambda found: len(found) > 1)
    if rates is None or len(rates) < 2:
        raise RuntimeError(f"no rates for {symbol} {tf_text}: {mt5.last_error()}")
    df = pd.DataFrame(rates)
    df = df.iloc[:-1].reset_index(drop=True)   # last row is the forming bar
    df.attrs["point"] = symbol_point(symbol)   # some indicators divide by the point (Market Facilitation Index)
    return df


def tf_seconds(tf_text):
    """The length of a bar of a TF in seconds (a month: 31 days)."""
    unit = tf_text.rstrip("0123456789")
    return int(tf_text[len(unit):]) * TF_UNIT_SECONDS[unit]


@with_link
def fetch_last_closed_time(symbol, tf_text):
    """The open time of the newest closed bar: asked before the bars, a new bar is the only reason to calculate again."""
    rates = mt5.copy_rates_from_pos(symbol, TIMEFRAMES[tf_text], 0, 2)   # [last closed bar, forming bar]
    if rates is None or len(rates) < 2:
        return None
    return int(rates[0]["time"])


@with_link
def fetch_last_tick(symbol):
    """The last tick of the symbol (time_msc, time, bid), as SymbolInfoTick of CNewTickObj: a bar closes only when a tick opens the next one."""
    tick = mt5.symbol_info_tick(symbol)
    if tick is None:
        return None
    return int(tick.time_msc), int(tick.time), float(tick.bid)


def select_symbol(symbol, tf_text):
    """The symbol is in the Market Watch and the TF is one we know: what every request of bars starts with."""
    if tf_text not in TIMEFRAMES:
        raise ValueError(f"unknown timeframe {tf_text}")
    if not mt5.symbol_select(symbol, True):
        raise RuntimeError(f"symbol_select failed for {symbol}: {mt5.last_error()}")


def ask_history(ask, enough=None):
    """The rates `ask()` gives, asked again while the history may still be syncing (and while enough(rates), when it is given, says they are not what is needed);
    None when the terminal did not answer."""
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
    """The `count` closed bars older than the bar opened at `before_time`, the oldest first. Fewer (or none) when the terminal has no more of them;
    None when the terminal did not answer."""
    select_symbol(symbol, tf_text)
    newest = datetime.fromtimestamp(before_time - 1, tz=timezone.utc)   # the time of a bar is the one of the server read as UTC
    rates = ask_history(lambda: mt5.copy_rates_from(symbol, TIMEFRAMES[tf_text], newest, count))
    if rates is None:
        return None
    df = pd.DataFrame(rates)
    df.attrs["point"] = symbol_point(symbol)
    return df


@with_link
def fetch_bars_after(symbol, tf_text, from_time, count):
    """The `count` bars from the bar opened at `from_time` on, the oldest first: what a swing is judged by, after a chunk of the history, when the bars are not kept in
    the database. Fewer when the terminal has no more of them; None when the terminal did not answer."""
    select_symbol(symbol, tf_text)
    first = datetime.fromtimestamp(from_time, tz=timezone.utc)
    last = datetime.fromtimestamp(from_time + max(count * tf_seconds(tf_text) * 3, AFTER_WINDOW_SECONDS), tz=timezone.utc)
    rates = ask_history(lambda: mt5.copy_rates_range(symbol, TIMEFRAMES[tf_text], first, last))
    if rates is None:
        return None
    return pd.DataFrame(rates).head(count)


_points = {}   # the point of a symbol does not change while the process lives: the terminal is asked once for each symbol


def symbol_point(symbol):
    if symbol not in _points:
        info = mt5.symbol_info(symbol)
        if info is None:
            return 0.0   # not kept: asked again next time
        _points[symbol] = float(info.point)
    return _points[symbol]
