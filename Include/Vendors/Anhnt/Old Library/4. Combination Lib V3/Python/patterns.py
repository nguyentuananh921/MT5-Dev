"""Candle patterns of the V2 library (CBarPatternControl*), shape only - no trend.

Every function takes the candles and returns one value per bar: BULLISH (1), BEARISH (-1), BOTH (2, Inside Bar) or NONE (0).
A pattern sits on its newest bar: prev(x, 1) is the bar before it, prev(x, 2) the one before that.
Ratios are in percent of the candle size (High - Low); a candle without range counts as 100 % for the body and both shadows.
"""
import numpy as np
import pandas as pd

BULLISH, BEARISH, NONE, BOTH = 1, -1, 0, 2

# PATTERN_DEF_* of BarPatternControl.mqh
SMALL_BODY = 35.0
DOJI_BODY = 5.0
SPINNING_TOP_BODY = 35.0
SPINNING_TOP_SHADOW = 25.0
MARUBOZU_BODY = 90.0
LONG_SHADOW = 55.0
SHORT_SHADOW = 10.0
DEEP_SHADOW = 70.0
PINBAR_MIN_BODY = 0.0
PINBAR_BODY = 30.0
PINBAR_LARGER_SHADOW = 60.0
PINBAR_SMALLER_SHADOW = 30.0
LARGE_BODY = 60.0
INNER_BODY = 30.0
PENETRATION = 50.0
SIMILARITY = 70.0
TWEEZER_POINTS = 5
OUTSIDE_BAR_RATIO_CANDLES = 50.0
OUTSIDE_BAR_RATIO_BODY = 50.0
PIVOT_RATIO_CANDLE_SIZE = 20.0
THREE_STARS_BODY = 10.0

class Candles:
    """Body and shadow ratios of every bar, as CBar calculates them."""

    def __init__(self, bars, point=0.0):
        self.point = point
        self.open = bars["open"].to_numpy(dtype=float)
        self.high = bars["high"].to_numpy(dtype=float)
        self.low = bars["low"].to_numpy(dtype=float)
        self.close = bars["close"].to_numpy(dtype=float)
        size = self.high - self.low
        body_high = np.maximum(self.open, self.close)
        body_low = np.minimum(self.open, self.close)
        self.size = size
        self.top, self.bottom = body_high, body_low
        self.bull, self.bear = self.close > self.open, self.close < self.open
        valid = size > 0
        with np.errstate(divide="ignore", invalid="ignore"):
            self.body = np.where(valid, (body_high - body_low) * 100.0 / size, 100.0)
            self.upper = np.where(valid, (self.high - body_high) * 100.0 / size, 100.0)
            self.lower = np.where(valid, (body_low - self.low) * 100.0 / size, 100.0)


def prev(values, steps):
    """The value `steps` bars earlier; the first bars have none (NaN, or False for flags)."""
    if values.dtype == bool:
        out = np.zeros(len(values), dtype=bool)
    else:
        out = np.full(len(values), np.nan)
    out[steps:] = values[:-steps]
    return out


def _direction(bullish, bearish):
    return np.where(bullish, BULLISH, np.where(bearish, BEARISH, NONE)).astype(np.int8)


def _hammer_shape(c):
    return (c.body <= SMALL_BODY) & (c.lower >= LONG_SHADOW) & (c.upper <= SHORT_SHADOW)


def _inverted_hammer_shape(c):
    return (c.body <= SMALL_BODY) & (c.upper >= LONG_SHADOW) & (c.lower <= SHORT_SHADOW)


def hammer(c):
    return _direction(_hammer_shape(c), False)


def hanging_man(c):
    return _direction(False, _hammer_shape(c))


def inverted_hammer(c):
    return _direction(_inverted_hammer_shape(c), False)


def shooting_star(c):
    return _direction(False, _inverted_hammer_shape(c))


def doji(c):
    shape = c.body <= DOJI_BODY
    return _direction(shape & (c.lower >= c.upper), shape & (c.lower < c.upper))   # the longer shadow breaks the tie


def dragonfly_doji(c):
    return _direction((c.body <= DOJI_BODY) & (c.lower >= DEEP_SHADOW) & (c.upper <= DOJI_BODY), False)


def gravestone_doji(c):
    return _direction(False, (c.body <= DOJI_BODY) & (c.upper >= DEEP_SHADOW) & (c.lower <= DOJI_BODY))


def spinning_top(c):
    shape = (c.body <= SPINNING_TOP_BODY) & (c.lower >= SPINNING_TOP_SHADOW) & (c.upper >= SPINNING_TOP_SHADOW)
    return _direction(shape & (c.lower >= c.upper), shape & (c.lower < c.upper))


def marubozu(c):
    shape = c.body >= MARUBOZU_BODY
    return _direction(shape & c.bull, shape & c.bear)


def pin_bar(c):
    body = (c.body <= PINBAR_BODY) & (c.body >= PINBAR_MIN_BODY)
    bullish = body & (c.lower >= PINBAR_LARGER_SHADOW) & (c.upper <= PINBAR_SMALLER_SHADOW)
    bearish = body & ~bullish & (c.upper >= PINBAR_LARGER_SHADOW) & (c.lower <= PINBAR_SMALLER_SHADOW)   # bullish is checked first
    return _direction(bullish, bearish)


def _harami(c, inner_max):
    shape = ((prev(c.body, 1) >= LARGE_BODY) & (c.body <= inner_max)
             & ~(c.bottom < prev(c.bottom, 1)) & ~(c.top > prev(c.top, 1)))
    return _direction(shape & prev(c.bear, 1) & c.bull, shape & prev(c.bull, 1) & c.bear)


def harami(c):
    return _harami(c, INNER_BODY)


def harami_cross(c):
    return _harami(c, DOJI_BODY)


def engulfing(c):
    shape = (c.body >= LARGE_BODY) & ~(c.bottom > prev(c.bottom, 1)) & ~(c.top < prev(c.top, 1))
    return _direction(shape & prev(c.bear, 1) & c.bull, shape & prev(c.bull, 1) & c.bear)


def tweezer(c):
    tolerance = c.point * float(TWEEZER_POINTS)
    bottom = prev(c.bear, 1) & c.bull & (np.abs(prev(c.low, 1) - c.low) <= tolerance)
    top = prev(c.bull, 1) & c.bear & (np.abs(prev(c.high, 1) - c.high) <= tolerance)
    return _direction(bottom, top)


def piercing_line(c):
    body_range = prev(c.top, 1) - prev(c.bottom, 1)
    shape = prev(c.bear, 1) & (prev(c.body, 1) >= LARGE_BODY) & c.bull & ~(c.open > prev(c.close, 1))
    return _direction(shape & ~(c.close < prev(c.bottom, 1) + body_range * PENETRATION / 100.0), False)


def dark_cloud_cover(c):
    body_range = prev(c.top, 1) - prev(c.bottom, 1)
    shape = prev(c.bull, 1) & (prev(c.body, 1) >= LARGE_BODY) & c.bear & ~(c.open < prev(c.close, 1))
    return _direction(False, shape & ~(c.close > prev(c.top, 1) - body_range * PENETRATION / 100.0))


def rails(c):
    body_before = np.abs(prev(c.open, 1) - prev(c.close, 1))
    body_now = np.abs(c.open - c.close)
    with np.errstate(divide="ignore", invalid="ignore"):
        similarity = np.minimum(body_before, body_now) / np.maximum(body_before, body_now)
    opposite = (prev(c.bull, 1) & c.bear) | (prev(c.bear, 1) & c.bull)
    shape = ((prev(c.body, 1) >= LARGE_BODY) & (c.body >= LARGE_BODY) & opposite
             & (body_before > 0) & (body_now > 0) & ~(similarity < SIMILARITY / 100.0))
    return _direction(shape & c.bull, shape & c.bear)   # the newest candle decides


def outside_bar(c):
    both_large = (c.body >= OUTSIDE_BAR_RATIO_BODY) & (prev(c.body, 1) >= OUTSIDE_BAR_RATIO_BODY)
    opposite = (prev(c.bull, 1) & c.bear) | (prev(c.bear, 1) & c.bull)
    with np.errstate(divide="ignore", invalid="ignore"):
        ratio = np.where(c.size > 0, prev(c.size, 1) * 100.0 / c.size, 0.0)
    shape = (both_large & opposite & ~(ratio < OUTSIDE_BAR_RATIO_CANDLES)
             & (prev(c.high, 1) <= c.high) & (prev(c.low, 1) >= c.low)
             & (prev(c.top, 1) < c.top) & (prev(c.bottom, 1) > c.bottom))
    return _direction(shape & c.bull, shape & c.bear)


def inside_bar(c):
    return np.where((c.high < prev(c.high, 1)) & (c.low > prev(c.low, 1)), BOTH, NONE).astype(np.int8)


def _star(c, inner_max, bullish):
    body_range = prev(c.top, 2) - prev(c.bottom, 2)
    small_middle = prev(c.body, 1) <= inner_max
    if bullish:
        shape = prev(c.bear, 2) & (prev(c.body, 2) >= LARGE_BODY) & small_middle & c.bull
        shape &= ~(c.close < prev(c.bottom, 2) + body_range * PENETRATION / 100.0)
        return _direction(shape, False)
    shape = prev(c.bull, 2) & (prev(c.body, 2) >= LARGE_BODY) & small_middle & c.bear
    shape &= ~(c.close > prev(c.top, 2) - body_range * PENETRATION / 100.0)
    return _direction(False, shape)


def morning_star(c):
    return _star(c, INNER_BODY, True)


def morning_doji_star(c):
    return _star(c, DOJI_BODY, True)


def evening_star(c):
    return _star(c, INNER_BODY, False)


def evening_doji_star(c):
    return _star(c, DOJI_BODY, False)


def abandoned_baby(c):
    doji_between = prev(c.body, 1) <= DOJI_BODY
    large = (prev(c.body, 2) >= LARGE_BODY) & (c.body >= LARGE_BODY)
    bullish = (doji_between & large & prev(c.bear, 2) & c.bull
               & (prev(c.high, 1) < prev(c.low, 2)) & (c.low > prev(c.high, 1)))
    bearish = (doji_between & large & prev(c.bull, 2) & c.bear
               & (prev(c.low, 1) > prev(c.high, 2)) & (c.high < prev(c.low, 1)))
    return _direction(bullish, bearish)


def pivot_point_reversal(c):
    middle_size = prev(c.size, 1)
    with np.errstate(divide="ignore", invalid="ignore"):
        low_vs_left = (prev(c.low, 2) - prev(c.low, 1)) / middle_size * 100.0
        low_vs_right = (c.low - prev(c.low, 1)) / middle_size * 100.0
        high_vs_left = (prev(c.high, 1) - prev(c.high, 2)) / middle_size * 100.0
        high_vs_right = (prev(c.high, 1) - c.high) / middle_size * 100.0
    valid = middle_size > 0
    bullish = valid & (low_vs_left >= PIVOT_RATIO_CANDLE_SIZE) & (low_vs_right >= PIVOT_RATIO_CANDLE_SIZE)
    bearish = valid & ~bullish & (high_vs_left >= PIVOT_RATIO_CANDLE_SIZE) & (high_vs_right >= PIVOT_RATIO_CANDLE_SIZE)
    return _direction(bullish, bearish)


def _three(c, bullish):
    """Three White Soldiers / Three Black Crows: large bodies, each opens inside the previous body and closes beyond its close."""
    kind = c.bull if bullish else c.bear
    large = (c.body >= LARGE_BODY) & (prev(c.body, 1) >= LARGE_BODY) & (prev(c.body, 2) >= LARGE_BODY)
    same = kind & prev(kind, 1) & prev(kind, 2)
    open_inside_1 = ~((prev(c.open, 1) < prev(c.bottom, 2)) | (prev(c.open, 1) > prev(c.top, 2)))
    open_inside_2 = ~((c.open < prev(c.bottom, 1)) | (c.open > prev(c.top, 1)))
    if bullish:
        beyond = ~(prev(c.close, 1) <= prev(c.close, 2)) & ~(c.close <= prev(c.close, 1))
    else:
        beyond = ~(prev(c.close, 1) >= prev(c.close, 2)) & ~(c.close >= prev(c.close, 1))
    return large & same & open_inside_1 & open_inside_2 & beyond


def three_white_soldiers(c):
    return _direction(_three(c, True), False)


def three_black_crows(c):
    return _direction(False, _three(c, False))


def three_inside_up(c):
    shape = (prev(c.bear, 2) & (prev(c.body, 2) >= LARGE_BODY)
             & prev(c.bull, 1) & (prev(c.body, 1) <= INNER_BODY)
             & ~(prev(c.bottom, 1) < prev(c.bottom, 2)) & ~(prev(c.top, 1) > prev(c.top, 2))
             & c.bull & ~(c.close <= prev(c.close, 1)))
    return _direction(shape, False)


def three_inside_down(c):
    shape = (prev(c.bull, 2) & (prev(c.body, 2) >= LARGE_BODY)
             & prev(c.bear, 1) & (prev(c.body, 1) <= INNER_BODY)
             & ~(prev(c.bottom, 1) < prev(c.bottom, 2)) & ~(prev(c.top, 1) > prev(c.top, 2))
             & c.bear & ~(c.close >= prev(c.close, 1)))
    return _direction(False, shape)


def three_stars(c):
    shape = (c.body <= THREE_STARS_BODY) & (prev(c.body, 1) <= THREE_STARS_BODY) & (prev(c.body, 2) <= THREE_STARS_BODY)
    return _direction(shape & (c.close >= prev(c.close, 2)), shape & (c.close < prev(c.close, 2)))


# name = the key of "Pattern_Alerts_Setting" in Config_Setting.json
PATTERNS = {
    "Hammer": hammer,
    "Hanging Man": hanging_man,
    "Inverted Hammer": inverted_hammer,
    "Shooting Star": shooting_star,
    "Doji": doji,
    "Dragonfly doji": dragonfly_doji,
    "Gravestone Doji": gravestone_doji,
    "Spinning Top": spinning_top,
    "Marubozu": marubozu,
    "Pin Bar": pin_bar,
    "Harami": harami,
    "Harami Cross": harami_cross,
    "Engulfing": engulfing,
    "Tweezer": tweezer,
    "Piercing pattern": piercing_line,
    "Dark Cloud Cover": dark_cloud_cover,
    "Rails": rails,
    "Outside Bar": outside_bar,
    "Inside Bar": inside_bar,
    "Morning Star": morning_star,
    "Morning Doji Star": morning_doji_star,
    "Evening Star": evening_star,
    "Evening Doji Star": evening_doji_star,
    "Abandoned baby": abandoned_baby,
    "Pivot Point Reversal": pivot_point_reversal,
    "Three White Soldiers": three_white_soldiers,
    "Three Black Crows": three_black_crows,
    "Three Inside Up": three_inside_up,
    "Three Inside Down": three_inside_down,
    "Three stars": three_stars,
}

#: Candles each pattern is made of (CBarPattern PATTERN_PROP_CANDLES of V2), in the order of PATTERNS
CANDLES = {
    "Hammer": 1, "Hanging Man": 1, "Inverted Hammer": 1, "Shooting Star": 1, "Doji": 1, "Dragonfly doji": 1,
    "Gravestone Doji": 1, "Spinning Top": 1, "Marubozu": 1, "Pin Bar": 1,
    "Harami": 2, "Harami Cross": 2, "Engulfing": 2, "Tweezer": 2, "Piercing pattern": 2, "Dark Cloud Cover": 2,
    "Rails": 2, "Outside Bar": 2, "Inside Bar": 2,
    "Morning Star": 3, "Morning Doji Star": 3, "Evening Star": 3, "Evening Doji Star": 3, "Abandoned baby": 3,
    "Pivot Point Reversal": 3, "Three White Soldiers": 3, "Three Black Crows": 3, "Three Inside Up": 3,
    "Three Inside Down": 3, "Three stars": 3,
}
assert list(CANDLES) == list(PATTERNS), "CANDLES must list the same patterns as PATTERNS, in the same order"

#: Sides each pattern can have: B = Buy, S = Sell, empty = none (Inside Bar has no side). Checked against the found patterns of 4 charts (400k bars)
DIRECTIONS = {
    "Hammer": "B", "Hanging Man": "S", "Inverted Hammer": "B", "Shooting Star": "S", "Doji": "BS", "Dragonfly doji": "B",
    "Gravestone Doji": "S", "Spinning Top": "BS", "Marubozu": "BS", "Pin Bar": "BS",
    "Harami": "BS", "Harami Cross": "BS", "Engulfing": "BS", "Tweezer": "BS", "Piercing pattern": "B", "Dark Cloud Cover": "S",
    "Rails": "BS", "Outside Bar": "BS", "Inside Bar": "",
    "Morning Star": "B", "Morning Doji Star": "B", "Evening Star": "S", "Evening Doji Star": "S", "Abandoned baby": "BS",
    "Pivot Point Reversal": "BS", "Three White Soldiers": "B", "Three Black Crows": "S", "Three Inside Up": "B",
    "Three Inside Down": "S", "Three stars": "BS",
}
assert list(DIRECTIONS) == list(PATTERNS), "DIRECTIONS must list the same patterns as PATTERNS, in the same order"

COLUMNS = ["time", "label", "dir"]


def find_patterns(bars, point=0.0):
    """Every pattern found on the closed bars, oldest first: time, name, BUY (bullish) / SELL (bearish) / BOTH (Inside Bar)."""
    candles = Candles(bars, point)
    times = bars["time"].to_numpy()
    frames = []
    for name, rule in PATTERNS.items():
        found = rule(candles)
        at = np.nonzero(found)[0]
        direction = np.select([found[at] == BULLISH, found[at] == BEARISH], ["BUY", "SELL"], "BOTH")
        frames.append(pd.DataFrame({"time": times[at], "label": name, "dir": direction}))
    return pd.concat(frames, ignore_index=True).sort_values(["time", "label"]).reset_index(drop=True)
