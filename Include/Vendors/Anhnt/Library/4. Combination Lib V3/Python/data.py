import time
import MetaTrader5 as mt5
import pandas as pd

TIMEFRAMES = {
    "M1": mt5.TIMEFRAME_M1, "M2": mt5.TIMEFRAME_M2, "M3": mt5.TIMEFRAME_M3, "M4": mt5.TIMEFRAME_M4,
    "M5": mt5.TIMEFRAME_M5, "M6": mt5.TIMEFRAME_M6, "M10": mt5.TIMEFRAME_M10, "M12": mt5.TIMEFRAME_M12,
    "M15": mt5.TIMEFRAME_M15, "M20": mt5.TIMEFRAME_M20, "M30": mt5.TIMEFRAME_M30,
    "H1": mt5.TIMEFRAME_H1, "H2": mt5.TIMEFRAME_H2, "H3": mt5.TIMEFRAME_H3, "H4": mt5.TIMEFRAME_H4,
    "H6": mt5.TIMEFRAME_H6, "H8": mt5.TIMEFRAME_H8, "H12": mt5.TIMEFRAME_H12,
    "D1": mt5.TIMEFRAME_D1, "W1": mt5.TIMEFRAME_W1, "MN1": mt5.TIMEFRAME_MN1,
}

HISTORY_RETRIES = 10
HISTORY_RETRY_SLEEP = 0.3
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
    if tf_text not in TIMEFRAMES:
        raise ValueError(f"unknown timeframe {tf_text}")
    if not mt5.symbol_select(symbol, True):
        raise RuntimeError(f"symbol_select failed for {symbol}: {mt5.last_error()}")
    limit = mt5.terminal_info().maxbars - 1   # the terminal rejects a request of "Max bars in chart" bars or more
    want = min(count, limit) if count > 0 else limit   # 0 = everything the terminal keeps
    rates = None
    for _ in range(HISTORY_RETRIES):
        rates = mt5.copy_rates_from_pos(symbol, TIMEFRAMES[tf_text], 0, want)
        if rates is not None and len(rates) > 1:
            break
        if mt5.last_error()[0] == mt5.RES_E_INVALID_PARAMS:
            break   # retrying cannot fix this
        time.sleep(HISTORY_RETRY_SLEEP)   # history may still be syncing
    if rates is None or len(rates) < 2:
        raise RuntimeError(f"no rates for {symbol} {tf_text}: {mt5.last_error()}")
    df = pd.DataFrame(rates)
    df = df.iloc[:-1].reset_index(drop=True)   # last row is the forming bar
    df.attrs["point"] = symbol_point(symbol)
    return df

@with_link
def fetch_forming_bar(symbol, tf_text):
    rates = mt5.copy_rates_from_pos(symbol, TIMEFRAMES[tf_text], 0, 1)   # the bar that is still forming
    if rates is None or len(rates) < 1:
        return None
    return pd.DataFrame(rates)

@with_link
def fetch_last_closed_time(symbol, tf_text):
    rates = mt5.copy_rates_from_pos(symbol, TIMEFRAMES[tf_text], 0, 2)   # [last closed bar, forming bar]
    if rates is None or len(rates) < 2:
        return None
    return int(rates[0]["time"])

def symbol_point(symbol):
    info = mt5.symbol_info(symbol)
    return float(info.point) if info is not None else 0.0
