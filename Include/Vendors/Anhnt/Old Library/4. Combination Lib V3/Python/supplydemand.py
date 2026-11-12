import numpy as np
import pandas as pd

import momentum
import zone

# Supply and demand zones from the momentum candles (momentum.py), the three steps of the SMC method:
#   1. a momentum candle: a candle up gives a DEMAND zone (BUY), a candle down a SUPPLY zone (SELL)
#   2. the candle before it
#   3. the zone is the high-low of that candle, from that candle to the right
# The zone is born when the momentum candle closes, and from there it lives as every zone does (zone.advance: Born, Touched, Bounced,
# Broken, Resurrected, Dead); the rules of that life are the ones of zone.py with their defaults, only the birth is different.
# Its own kind (SUPPLYDEMAND), so that the EA draws it apart from the support / resistance zones of zone.py

KIND = "SUPPLYDEMAND"
EVENT_COLUMNS = zone.EVENT_COLUMNS


def candidates(bars, p, since_index=-1):
    """The zones the momentum candles give: dict(dir, price, top, bottom, swing_time, birth_time, report), oldest first.
    since_index = a bar index: only the zones born after that bar."""
    times = bars["time"].to_numpy()
    high, low = bars["high"].to_numpy(dtype=float), bars["low"].to_numpy(dtype=float)
    open_, close = bars["open"].to_numpy(dtype=float), bars["close"].to_numpy(dtype=float)
    hit, _ = momentum.find_bars(bars, p)
    hit = hit[(hit >= 1) & (hit > since_index)]
    first = max(0, len(times) - int(p["history_bars"]))
    found = []
    for i in hit:
        up = close[i] > open_[i]
        base = i - 1   # the candle before the momentum candle
        found.append({"dir": "BUY" if up else "SELL", "price": float(low[base] if up else high[base]), "top": float(high[base]),
                      "bottom": float(low[base]), "swing_time": int(times[base]), "birth_time": int(times[i]), "report": bool(i >= first)})
    return found


def as_kind(rows, kind=KIND):
    return [(kind,) + tuple(row[1:]) for row in rows]


class Tracker:
    """The supply and demand zones that are alive: load gives every event of the bars, update only the ones a new bar brings."""

    kind = KIND   # a subclass that gives other zones from the same candles (fvg.py) changes this and candidates()

    def __init__(self, params=None):
        self.p = {**momentum.DEFAULTS, **zone.DEFAULTS, **(params or {})}   # the zone ones are the defaults of zone.py: only the birth is different
        self.alive = []

    def candidates(self, bars, since_index=-1):
        return candidates(bars, self.p, since_index)

    def start(self, found, arrays, atr):
        rows = []
        for z in found:
            s = zone.new_state(z)
            events = zone.advance(s, arrays, atr, self.p)
            if not s["dead"]:
                self.alive.append(s)
            if s["report"]:
                rows.extend(events)
        return rows

    def arrays(self, bars):
        atr = np.nan_to_num(np.asarray(zone.atr_indicator(bars, {"period": self.p["atr_period"]})[0][0], dtype=float))
        return (bars["time"].to_numpy(), bars["high"].to_numpy(dtype=float), bars["low"].to_numpy(dtype=float),
                bars["close"].to_numpy(dtype=float), bars["tick_volume"].to_numpy(dtype=float)), atr

    def load(self, bars):
        """Every event of every zone of these bars (EVENT_COLUMNS), oldest first; the living zones are kept."""
        self.alive = []
        if len(bars) < 3:
            return zone.to_frame([])
        arrays, atr = self.arrays(bars)
        return zone.to_frame(as_kind(self.start(self.candidates(bars), arrays, atr), self.kind))

    def update(self, bars, since):
        """The events after the bar `since` (a time): the living zones go forward, the zones born after it start."""
        if len(bars) < 3:
            return zone.to_frame([])
        arrays, atr = self.arrays(bars)
        rows = []
        living, self.alive = self.alive, []
        for s in living:
            events = zone.advance(s, arrays, atr, self.p)
            if not s["dead"]:
                self.alive.append(s)
            if s["report"]:
                rows.extend(events)
        since_index = int(np.searchsorted(arrays[0], since, side="right")) - 1
        rows = as_kind(rows, self.kind)
        rows.extend(as_kind(self.start(self.candidates(bars, since_index), arrays, atr), self.kind))
        return zone.to_frame(rows)
