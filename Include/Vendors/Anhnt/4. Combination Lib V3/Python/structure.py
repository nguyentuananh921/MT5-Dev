import numpy as np
import pandas as pd

from indicators import atr as atr_indicator

# A break is found here, by the close and the level of the newest swing of a side: the close must be at least min_step_atr ATRs beyond
#   the level (a smaller one is not a break, the level stays). Which kind it is, BOS or CHoCH, and what it does to the Market State is
#   not decided here but by condition.Tracker (the State before the break): until then its type is BREAK. The label of the swing
#   (HH / LH ...) is not used: it only compares the swing with the one before it, not with the State
COLUMNS = ["type", "dir", "break_time", "swing_time", "level"]
RAW = "BREAK"


def find_structures(bars, swings, min_step_atr=0.3, atr_period=14):
    times = bars["time"].tolist()
    closes = bars["close"].tolist()
    atr = np.nan_to_num(np.asarray(atr_indicator(bars, {"period": atr_period})[0][0], dtype=float)).tolist()
    sw_confirmed = swings["confirmed_time"].tolist()
    sw_time = swings["time"].tolist()
    sw_price = swings["price"].tolist()
    sw_is_high = (swings["type"] == "HIGH").tolist()
    sw_structure = swings["structure"].tolist()
    high = None   # [price, swing time, structure, used]
    low = None
    rows = []
    sp = 0
    n = len(sw_confirmed)
    for t, close, a in zip(times, closes, atr):
        while sp < n and sw_confirmed[sp] <= t:   # a swing is a reference from its confirmation bar on
            ref = [sw_price[sp], sw_time[sp], sw_structure[sp], False]
            if sw_is_high[sp]:
                high = ref
            else:
                low = ref
            sp += 1
        step = min_step_atr * a
        if high is not None and not high[3] and close > high[0] + step:
            high[3] = True
            if high[2] != "NONE":
                rows.append((RAW, "BUY", t, high[1], high[0]))
        if low is not None and not low[3] and close < low[0] - step:
            low[3] = True
            if low[2] != "NONE":
                rows.append((RAW, "SELL", t, low[1], low[0]))
    return pd.DataFrame(rows, columns=COLUMNS)
