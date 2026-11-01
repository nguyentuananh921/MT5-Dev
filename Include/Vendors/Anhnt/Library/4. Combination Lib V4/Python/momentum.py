"""momentum.py: the Momentum Candle. A candle whose body is bigger than `multiplier` times the biggest body of the `bars` candles before it.
A candle up is a BUY momentum, a candle down a SELL one. Method 1 of the SMC demand / supply zones: the candle itself decides, nothing else
(no ATR, no swing). The type is Momentum Candle of Setting_BarInformation, its parameters are in Setting_BarSetup (names of BarDefines.mqh)."""
import numpy as np

NAME = "Momentum Candle"              # Setting_BarInformation.name: the database says the type_infor of it
PARAM_MULTIPLIER = "body_multiplier"  # BAR_PARAM_BODY_MULTIPLIER
PARAM_BARS_BEFORE = "bars_before"     # BAR_PARAM_BARS_BEFORE


def context(params):
    """How many bars before a bar are needed to judge it: the oldest bars of a chunk of bars have not so many, they are not judged."""
    return max(1, int(params[PARAM_BARS_BEFORE]))


def find_bars(bars, multiplier, count):
    """The bar indexes of the momentum candles."""
    open_, close = bars["open"].to_numpy(dtype=float), bars["close"].to_numpy(dtype=float)
    body = np.abs(close - open_)
    n, count = len(body), max(1, int(count))
    before = np.full(n, np.nan)
    if n > count:
        windows = np.lib.stride_tricks.sliding_window_view(body, count)   # windows[i] = body[i:i + count]
        before[count:] = windows[:n - count].max(axis=1)                    # the biggest of the `count` bodies before bar i
    with np.errstate(invalid="ignore"):
        return np.flatnonzero(body > float(multiplier) * before)


def calculate(bars, params, since=0, until=None):
    """The momentum candles of the bars with since < time (< until when it is given): a list of (bar time, side) with side BUY or SELL."""
    if len(bars) < 2:
        return []
    hit = find_bars(bars, params[PARAM_MULTIPLIER], params[PARAM_BARS_BEFORE])
    times = bars["time"].to_numpy()
    open_, close = bars["open"].to_numpy(dtype=float), bars["close"].to_numpy(dtype=float)
    return [(int(times[i]), "BUY" if close[i] > open_[i] else "SELL") for i in hit
            if times[i] > since and (until is None or times[i] < until)]
