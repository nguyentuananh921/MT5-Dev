"""patterns.py: the candle patterns and the price action formations of Setting_BarInformation (the V2 library CBarPatternControl*), shape only, no trend.

Every rule takes the candles and the parameters of its type (Setting_BarSetup, the names of BarDefines.mqh) and returns one value per bar: BULLISH (1),
BEARISH (-1), BOTH (2, Inside Bar: no side) or NONE (0). A pattern sits on its newest bar: prev(x, 1) is the bar before it, prev(x, 2) the one before that.
Ratios are in percent of the candle size (High - Low); a candle without range counts as 100 % for the body and both shadows.
"""
import numpy as np

BULLISH, BEARISH, NONE, BOTH = 1, -1, 0, 2


class Candles:
    """Body and shadow ratios of every bar, as CBar calculates them."""

    def __init__(self, bars):
        self.point = float(bars.attrs.get("point") or 0.0)
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


def _hammer_shape(c, p):
    return (c.body <= p["body_max"]) & (c.lower >= p["lower_shadow_min"]) & (c.upper <= p["upper_shadow_max"])


def _inverted_hammer_shape(c, p):
    return (c.body <= p["body_max"]) & (c.upper >= p["upper_shadow_min"]) & (c.lower <= p["lower_shadow_max"])


def hammer(c, p):
    return _direction(_hammer_shape(c, p), False)


def hanging_man(c, p):
    return _direction(False, _hammer_shape(c, p))


def inverted_hammer(c, p):
    return _direction(_inverted_hammer_shape(c, p), False)


def shooting_star(c, p):
    return _direction(False, _inverted_hammer_shape(c, p))


def doji(c, p):
    shape = c.body <= p["body_max"]
    return _direction(shape & (c.lower >= c.upper), shape & (c.lower < c.upper))   # the longer shadow breaks the tie


def dragonfly_doji(c, p):
    return _direction((c.body <= p["body_max"]) & (c.lower >= p["lower_shadow_min"]) & (c.upper <= p["upper_shadow_max"]), False)


def gravestone_doji(c, p):
    return _direction(False, (c.body <= p["body_max"]) & (c.upper >= p["upper_shadow_min"]) & (c.lower <= p["lower_shadow_max"]))


def spinning_top(c, p):
    shape = (c.body <= p["body_max"]) & (c.lower >= p["shadow_min_each"]) & (c.upper >= p["shadow_min_each"])
    return _direction(shape & (c.lower >= c.upper), shape & (c.lower < c.upper))


def marubozu(c, p):
    shape = c.body >= p["body_min"]
    return _direction(shape & c.bull, shape & c.bear)


def pin_bar(c, p):
    body = c.body <= p["body_max"]
    bullish = body & (c.lower >= p["larger_shadow_min"]) & (c.upper <= p["smaller_shadow_max"])
    bearish = body & ~bullish & (c.upper >= p["larger_shadow_min"]) & (c.lower <= p["smaller_shadow_max"])   # bullish is checked first
    return _direction(bullish, bearish)


def _harami(c, p):
    shape = ((prev(c.body, 1) >= p["mother_body_min"]) & (c.body <= p["inner_body_max"])
             & ~(c.bottom < prev(c.bottom, 1)) & ~(c.top > prev(c.top, 1)))
    return _direction(shape & prev(c.bear, 1) & c.bull, shape & prev(c.bull, 1) & c.bear)


def harami(c, p):
    return _harami(c, p)


def harami_cross(c, p):
    return _harami(c, p)   # the same rule, its own inner_body_max (a doji)


def engulfing(c, p):
    shape = (c.body >= p["body_min"]) & ~(c.bottom > prev(c.bottom, 1)) & ~(c.top < prev(c.top, 1))
    return _direction(shape & prev(c.bear, 1) & c.bull, shape & prev(c.bull, 1) & c.bear)


def tweezer(c, p):
    tolerance = c.point * float(p["tolerance_points"])
    bottom = prev(c.bear, 1) & c.bull & (np.abs(prev(c.low, 1) - c.low) <= tolerance)
    top = prev(c.bull, 1) & c.bear & (np.abs(prev(c.high, 1) - c.high) <= tolerance)
    return _direction(bottom, top)


def piercing_line(c, p):
    body_range = prev(c.top, 1) - prev(c.bottom, 1)
    shape = prev(c.bear, 1) & (prev(c.body, 1) >= p["body_min"]) & c.bull & ~(c.open > prev(c.close, 1))
    return _direction(shape & ~(c.close < prev(c.bottom, 1) + body_range * p["penetration_min"] / 100.0), False)


def dark_cloud_cover(c, p):
    body_range = prev(c.top, 1) - prev(c.bottom, 1)
    shape = prev(c.bull, 1) & (prev(c.body, 1) >= p["body_min"]) & c.bear & ~(c.open < prev(c.close, 1))
    return _direction(False, shape & ~(c.close > prev(c.top, 1) - body_range * p["penetration_min"] / 100.0))


def rails(c, p):
    body_before = np.abs(prev(c.open, 1) - prev(c.close, 1))
    body_now = np.abs(c.open - c.close)
    with np.errstate(divide="ignore", invalid="ignore"):
        similarity = np.minimum(body_before, body_now) / np.maximum(body_before, body_now)
    opposite = (prev(c.bull, 1) & c.bear) | (prev(c.bear, 1) & c.bull)
    shape = ((prev(c.body, 1) >= p["body_min"]) & (c.body >= p["body_min"]) & opposite
             & (body_before > 0) & (body_now > 0) & ~(similarity < p["similarity_min"] / 100.0))
    return _direction(shape & c.bull, shape & c.bear)   # the newest candle decides


def outside_bar(c, p):
    both_large = (c.body >= p["body_ratio"]) & (prev(c.body, 1) >= p["body_ratio"])
    opposite = (prev(c.bull, 1) & c.bear) | (prev(c.bear, 1) & c.bull)
    with np.errstate(divide="ignore", invalid="ignore"):
        ratio = np.where(c.size > 0, prev(c.size, 1) * 100.0 / c.size, 0.0)
    shape = (both_large & opposite & ~(ratio < p["candles_ratio"])
             & (prev(c.high, 1) <= c.high) & (prev(c.low, 1) >= c.low)
             & (prev(c.top, 1) < c.top) & (prev(c.bottom, 1) > c.bottom))
    return _direction(shape & c.bull, shape & c.bear)


def inside_bar(c, p):
    return np.where((c.high < prev(c.high, 1)) & (c.low > prev(c.low, 1)), BOTH, NONE).astype(np.int8)


def _star(c, p, bullish):
    body_range = prev(c.top, 2) - prev(c.bottom, 2)
    small_middle = prev(c.body, 1) <= p["middle_body_max"]
    if bullish:
        shape = prev(c.bear, 2) & (prev(c.body, 2) >= p["first_body_min"]) & small_middle & c.bull
        shape &= ~(c.close < prev(c.bottom, 2) + body_range * p["penetration_min"] / 100.0)
        return _direction(shape, False)
    shape = prev(c.bull, 2) & (prev(c.body, 2) >= p["first_body_min"]) & small_middle & c.bear
    shape &= ~(c.close > prev(c.top, 2) - body_range * p["penetration_min"] / 100.0)
    return _direction(False, shape)


def morning_star(c, p):
    return _star(c, p, True)


def morning_doji_star(c, p):
    return _star(c, p, True)   # the same rule, its own middle_body_max (a doji)


def evening_star(c, p):
    return _star(c, p, False)


def evening_doji_star(c, p):
    return _star(c, p, False)


def abandoned_baby(c, p):
    doji_between = prev(c.body, 1) <= p["middle_body_max"]
    large = (prev(c.body, 2) >= p["outer_body_min"]) & (c.body >= p["outer_body_min"])
    bullish = (doji_between & large & prev(c.bear, 2) & c.bull
               & (prev(c.high, 1) < prev(c.low, 2)) & (c.low > prev(c.high, 1)))
    bearish = (doji_between & large & prev(c.bull, 2) & c.bear
               & (prev(c.low, 1) > prev(c.high, 2)) & (c.high < prev(c.low, 1)))
    return _direction(bullish, bearish)


def pivot_point_reversal(c, p):
    middle_size = prev(c.size, 1)
    with np.errstate(divide="ignore", invalid="ignore"):
        low_vs_left = (prev(c.low, 2) - prev(c.low, 1)) / middle_size * 100.0
        low_vs_right = (c.low - prev(c.low, 1)) / middle_size * 100.0
        high_vs_left = (prev(c.high, 1) - prev(c.high, 2)) / middle_size * 100.0
        high_vs_right = (prev(c.high, 1) - c.high) / middle_size * 100.0
    valid = middle_size > 0
    bullish = valid & (low_vs_left >= p["protrude_min"]) & (low_vs_right >= p["protrude_min"])
    bearish = valid & ~bullish & (high_vs_left >= p["protrude_min"]) & (high_vs_right >= p["protrude_min"])
    return _direction(bullish, bearish)


def _three(c, p, bullish):
    """Three White Soldiers / Three Black Crows: large bodies, each opens inside the previous body and closes beyond its close."""
    kind = c.bull if bullish else c.bear
    large = (c.body >= p["body_min"]) & (prev(c.body, 1) >= p["body_min"]) & (prev(c.body, 2) >= p["body_min"])
    same = kind & prev(kind, 1) & prev(kind, 2)
    open_inside_1 = ~((prev(c.open, 1) < prev(c.bottom, 2)) | (prev(c.open, 1) > prev(c.top, 2)))
    open_inside_2 = ~((c.open < prev(c.bottom, 1)) | (c.open > prev(c.top, 1)))
    if bullish:
        beyond = ~(prev(c.close, 1) <= prev(c.close, 2)) & ~(c.close <= prev(c.close, 1))
    else:
        beyond = ~(prev(c.close, 1) >= prev(c.close, 2)) & ~(c.close >= prev(c.close, 1))
    return large & same & open_inside_1 & open_inside_2 & beyond


def three_white_soldiers(c, p):
    return _direction(_three(c, p, True), False)


def three_black_crows(c, p):
    return _direction(False, _three(c, p, False))


def three_inside_up(c, p):
    shape = (prev(c.bear, 2) & (prev(c.body, 2) >= p["first_body_min"])
             & prev(c.bull, 1) & (prev(c.body, 1) <= p["second_body_max"])
             & ~(prev(c.bottom, 1) < prev(c.bottom, 2)) & ~(prev(c.top, 1) > prev(c.top, 2))
             & c.bull & ~(c.close <= prev(c.close, 1)))
    return _direction(shape, False)


def three_inside_down(c, p):
    shape = (prev(c.bull, 2) & (prev(c.body, 2) >= p["first_body_min"])
             & prev(c.bear, 1) & (prev(c.body, 1) <= p["second_body_max"])
             & ~(prev(c.bottom, 1) < prev(c.bottom, 2)) & ~(prev(c.top, 1) > prev(c.top, 2))
             & c.bear & ~(c.close >= prev(c.close, 1)))
    return _direction(False, shape)


def three_stars(c, p):
    limit = p["doji_body_max"]
    shape = (c.body <= limit) & (prev(c.body, 1) <= limit) & (prev(c.body, 2) <= limit)
    return _direction(shape & (c.close >= prev(c.close, 2)), shape & (c.close < prev(c.close, 2)))


# The name of the type in Setting_BarInformation -> its rule. The database says the type_infor of a name
PATTERNS = {
    "Hammer": hammer, "Hanging Man": hanging_man, "Inverted Hammer": inverted_hammer, "Shooting Star": shooting_star,
    "Doji": doji, "Dragonfly doji": dragonfly_doji, "Gravestone Doji": gravestone_doji, "Spinning Top": spinning_top,
    "Marubozu": marubozu, "Pin Bar": pin_bar, "Harami": harami, "Harami Cross": harami_cross, "Engulfing": engulfing,
    "Tweezer": tweezer, "Piercing pattern": piercing_line, "Dark Cloud Cover": dark_cloud_cover, "Rails": rails,
    "Outside Bar": outside_bar, "Inside Bar": inside_bar, "Morning Star": morning_star, "Morning Doji Star": morning_doji_star,
    "Evening Star": evening_star, "Evening Doji Star": evening_doji_star, "Abandoned baby": abandoned_baby,
    "Pivot Point Reversal": pivot_point_reversal, "Three White Soldiers": three_white_soldiers, "Three Black Crows": three_black_crows,
    "Three Inside Up": three_inside_up, "Three Inside Down": three_inside_down, "Three stars": three_stars,
}

CONTEXT = 3   # the bars before a bar the rules look at: prev(x, 2) at most, one more for safety

_last = (None, None)   # the Candles of the last bars asked: the 30 rules of a pass share them


def candles_of(bars):
    global _last
    if _last[0] is not bars:
        _last = (bars, Candles(bars))
    return _last[1]


def calculate(name, bars, params, since=0, until=None):
    """The patterns of the type `name` on the bars with since < time (< until when it is given): a list of (bar time, "BUY", "SELL" or "NONE")."""
    found = PATTERNS[name](candles_of(bars), params)
    times = bars["time"].to_numpy()
    rows = []
    for i in np.flatnonzero(found):
        if times[i] > since and (until is None or times[i] < until):
            rows.append((int(times[i]), "BUY" if found[i] == BULLISH else "SELL" if found[i] == BEARISH else "NONE"))
    return rows
