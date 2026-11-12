import numpy as np
import pandas as pd

# Momentum candle: a candle whose body is bigger than `multiplier` times the biggest body of the `bars` candles before it. A candle up is a
# BUY momentum, a candle down a SELL one. Method 1 of the SMC demand / supply zones ("find a strong momentum candle"): the candle itself
# decides, nothing else (no ATR, no swing). Every momentum candle is one event (BORN) of the kind MOMENTUM, in the same rows as the
# trendlines and the zones, so it travels the same way: the EA marks the candle, supplydemand.py gives the zone of the candle before it

KIND = "MOMENTUM"
EVENT_COLUMNS = ["kind", "origin_time", "time", "event", "dir", "t1", "p1", "t2", "p2", "reason"]

DEFAULTS = {
    "multiplier": 2.0,        # the body must be bigger than this many times the biggest body before it
    "bars": 3,                # how many candles before it are looked at
    "history_bars": 2000,     # only the candles of the newest bars are reported
}


def find_bars(bars, p):
    """The bar indexes of the momentum candles, and the biggest body before each one (an array as long as the bars, nan where unknown)."""
    open_, close = bars["open"].to_numpy(dtype=float), bars["close"].to_numpy(dtype=float)
    body = np.abs(close - open_)
    n, count = len(body), max(1, int(p["bars"]))
    before = np.full(n, np.nan)
    if n > count:
        windows = np.lib.stride_tricks.sliding_window_view(body, count)   # windows[i] = body[i:i + count]
        before[count:] = windows[:n - count].max(axis=1)                    # the biggest of the `count` bodies before bar i
    with np.errstate(invalid="ignore"):
        hit = np.flatnonzero(body > float(p["multiplier"]) * before)
    return hit, before


def to_rows(bars, hit):
    times = bars["time"].to_numpy()
    open_, close = bars["open"].to_numpy(dtype=float), bars["close"].to_numpy(dtype=float)
    return [(KIND, int(times[i]), int(times[i]), "BORN", "BUY" if close[i] > open_[i] else "SELL",
             int(times[i]), float(open_[i]), int(times[i]), float(close[i]), "") for i in hit]


def to_frame(rows):
    if not rows:
        return pd.DataFrame(columns=EVENT_COLUMNS)
    return pd.DataFrame(rows, columns=EVENT_COLUMNS)


class Tracker:
    """The momentum candles of one pair: load gives all of the history window, update the ones the new bars bring."""

    def __init__(self, params=None):
        self.p = {**DEFAULTS, **(params or {})}

    def load(self, bars):
        if len(bars) < 2:
            return to_frame([])
        hit, _ = find_bars(bars, self.p)
        first = len(bars) - int(self.p["history_bars"])
        return to_frame(to_rows(bars, hit[hit >= max(0, first)]))

    def update(self, bars, since):
        """The events after the bar `since` (a time)."""
        if len(bars) < 2:
            return to_frame([])
        hit, _ = find_bars(bars, self.p)
        times = bars["time"].to_numpy()
        return to_frame(to_rows(bars, hit[times[hit] > since]))
