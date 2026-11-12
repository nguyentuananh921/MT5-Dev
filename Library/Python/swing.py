"""swing.py: Swing High and Swing Low (the types Swing High / Swing Low of Setting_BarInformation). A swing is a bar whose high (or the top of its body,
price_basis) is higher than the `strength` bars on each side, or whose low (or the bottom of its body) is lower. It is known `strength` bars later: its
row is the bar of the swing, and `since` is compared with the bar that confirmed it (the row is not there before)."""
import numpy as np
import pandas as pd

import libdb

NAME_HIGH = "Swing High"
NAME_LOW = "Swing Low"
PARAM_STRENGTH = "swing_strength"   # BAR_PARAM_SWING_STRENGTH
PARAM_PRICE_BASIS = "price_basis"   # BAR_PARAM_PRICE_BASIS


def use_wick(params):
    """price_basis is High / Low (SWING_PRICE_BASIS_WICK, from the EA)."""
    return int(params[PARAM_PRICE_BASIS]) == libdb.setting_int("swing_price_basis_wick")


def context(params):
    """The bars a swing needs on each side."""
    return max(1, int(params[PARAM_STRENGTH]))


def swing_prices(df, use_wick):
    if use_wick:
        return df["high"], df["low"]
    return df[["open", "close"]].max(axis=1), df[["open", "close"]].min(axis=1)


def find_swings(df, strength, use_wick):
    hi, lo = swing_prices(df, use_wick)
    n = strength
    left_hi = hi.shift(1).rolling(n).max()
    right_hi = hi[::-1].shift(1).rolling(n).max()[::-1]
    left_lo = lo.shift(1).rolling(n).min()
    right_lo = lo[::-1].shift(1).rolling(n).min()[::-1]
    is_high = (hi > left_hi) & (hi > right_hi)   # NaN at the edges compares False, like the NULL check in V2
    is_low = (lo < left_lo) & (lo < right_lo)
    confirmed = df["time"].shift(-n)             # the bar `strength` periods after the pivot
    parts = []
    for kind, mask, price, names in (("HIGH", is_high, hi, ("HH", "LH")), ("LOW", is_low, lo, ("HL", "LL"))):
        sw = pd.DataFrame({"time": df["time"][mask],
                           "confirmed_time": confirmed[mask].astype("int64"),
                           "type": kind,
                           "price": price[mask]})
        prev = sw["price"].shift(1)              # previous swing of the same type
        sw["structure"] = np.where(prev.isna(), "NONE", np.where(sw["price"] > prev, names[0], names[1]))
        parts.append(sw)
    return pd.concat(parts).sort_values(["confirmed_time", "time"]).reset_index(drop=True)


def swings_of(bars, params):
    """Both kinds, from the parameters of a type (the same strength and basis for the two kinds of the pair of the types are not assumed: each type has its own)."""
    return find_swings(bars, context(params), use_wick(params))


def calculate(high, bars, params, since=0, until=None):
    """The swings of a kind: a list of (bar time, side), a High is a SELL side and a Low a BUY side. since: the confirming bar, until: the bar of the swing."""
    sw = swings_of(bars, params)
    sw = sw[sw["type"] == ("HIGH" if high else "LOW")]
    side = "SELL" if high else "BUY"
    return [(int(t), side) for t, c in zip(sw["time"], sw["confirmed_time"]) if c > since and (until is None or t < until)]
