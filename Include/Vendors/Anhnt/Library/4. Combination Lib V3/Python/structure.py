import pandas as pd

COLUMNS = ["type", "dir", "break_time", "swing_time", "level"]
def find_structures(bars, swings):
    times = bars["time"].tolist()
    closes = bars["close"].tolist()
    sw_confirmed = swings["confirmed_time"].tolist()
    sw_time = swings["time"].tolist()
    sw_price = swings["price"].tolist()
    sw_is_high = (swings["type"] == "HIGH").tolist()
    sw_structure = swings["structure"].tolist()
    high = None   # [price, pivot time, structure, used]
    low = None
    rows = []
    sp = 0
    n = len(sw_confirmed)
    for t, close in zip(times, closes):
        while sp < n and sw_confirmed[sp] <= t:   # a swing is a reference from its confirmation bar on
            ref = [sw_price[sp], sw_time[sp], sw_structure[sp], False]
            if sw_is_high[sp]:
                high = ref
            else:
                low = ref
            sp += 1
        if high is not None and not high[3] and close > high[0]:
            high[3] = True
            kind = "BOS" if high[2] == "HH" else "CHOCH" if high[2] == "LH" else None
            if kind:
                rows.append((kind, "BUY", t, high[1], high[0]))
        if low is not None and not low[3] and close < low[0]:
            low[3] = True
            kind = "BOS" if low[2] == "LL" else "CHOCH" if low[2] == "HL" else None
            if kind:
                rows.append((kind, "SELL", t, low[1], low[0]))
    return pd.DataFrame(rows, columns=COLUMNS)
