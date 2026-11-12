import numpy as np
import pandas as pd


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
