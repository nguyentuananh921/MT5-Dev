import numpy as np

import momentum
import supplydemand

# Fair value gap (FVG) of a momentum candle, the picture of the SMC course: three candles in a row, the middle one is the momentum candle
# (momentum.py). A gap that the other two candles leave open inside its range:
#   - bullish: the low of the third candle is above the high of the first one, the gap is [high of the first, low of the third]
#   - bearish: the high of the third candle is below the low of the first one, the gap is [high of the third, low of the first]
# The gap is known when the third candle closes, one candle after the momentum candle. Its edge touches the demand zone (bullish: the top
# of the candle before the momentum candle) or the supply zone (bearish), see supplydemand.py. A bullish gap acts as a support, a bearish
# one as a resistance, and it lives as every zone does (zone.advance): touched = price came back into it, broken = it was filled through
# Its own kind (FVG), so that the EA draws it apart from the other zones

KIND = "FVG"
EVENT_COLUMNS = supplydemand.EVENT_COLUMNS


def candidates(bars, p, since_index=-1):
    """The gaps of the momentum candles, oldest first: dict(dir, price, top, bottom, swing_time, birth_time, report).
    since_index = a bar index: only the gaps known after that bar."""
    times = bars["time"].to_numpy()
    high, low = bars["high"].to_numpy(dtype=float), bars["low"].to_numpy(dtype=float)
    hit, _ = momentum.find_bars(bars, p)
    n = len(times)
    hit = hit[(hit >= 1) & (hit < n - 1) & (hit + 1 > since_index)]   # the third candle must exist and be new
    first = max(0, n - int(p["history_bars"]))
    found = []
    for i in hit:
        if low[i + 1] > high[i - 1]:
            direction, top, bottom = "BUY", float(low[i + 1]), float(high[i - 1])
        elif high[i + 1] < low[i - 1]:
            direction, top, bottom = "SELL", float(low[i - 1]), float(high[i + 1])
        else:
            continue
        found.append({"dir": direction, "price": bottom if direction == "BUY" else top, "top": top, "bottom": bottom,
                      "swing_time": int(times[i]), "birth_time": int(times[i + 1]), "report": bool(i + 1 >= first)})
    return found


class Tracker(supplydemand.Tracker):
    """The gaps that are alive: load gives every event of the bars, update only the ones a new bar brings."""
    kind = KIND

    def candidates(self, bars, since_index=-1):
        return candidates(bars, self.p, since_index)
