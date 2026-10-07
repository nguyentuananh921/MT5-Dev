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


def connect(path=None):
    ok = mt5.initialize(path) if path else mt5.initialize()
    if not ok:
        raise RuntimeError(f"mt5.initialize failed: {mt5.last_error()}")


def disconnect():
    mt5.shutdown()


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
    return df.iloc[:-1].reset_index(drop=True)   # last row is the forming bar


def fetch_last_closed_time(symbol, tf_text):
    rates = mt5.copy_rates_from_pos(symbol, TIMEFRAMES[tf_text], 0, 2)   # [last closed bar, forming bar]
    if rates is None or len(rates) < 2:
        return None
    return int(rates[0]["time"])
