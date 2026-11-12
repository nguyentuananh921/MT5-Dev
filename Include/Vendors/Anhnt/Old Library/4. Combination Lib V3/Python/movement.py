import numpy as np
import pandas as pd

from indicators import atr as atr_indicator

# Impulse and Pullback: the legs between the swings, as a pure function of the swings and the Market State, like condition.py.
# A leg runs from one swing to the next of the OTHER side: the swings are made to alternate first (two highs in a row: the higher one
#   stays, two lows in a row: the lower one stays; enforcing the alternation is part 5 of "Swing Extremes and Pullbacks" by Hlomohang
#   John Borotho, mql5 article 23613). A swing can still be replaced by a more extreme one of its side until the opposite side shows,
#   so a leg is only given when the swing that ends it is final: when the next swing of the other side is confirmed.
# Impulse = a leg with the trend of the Market State, Pullback = a leg against it, none in a RANGE (the move types of the article
#   23852 by Francis Nyoike Thumbi, with the trend taken from our Market State instead of the label of the last swing).
# Retracement = the leg against the leg before it (not capped at 100 %, as that article does: a leg that goes through the whole
#   leg before it is not the same as one that stops at its end). The classes of the depth are the ones of part 4 (mql5 article 22807).
# The Tracker keeps the swing that is still open and the last leg: a new swing is one step, the history is not read again

VERSION = 1   # raise it when the rules, or what the Tracker keeps, change: what the disk kept of it is not used any more
EVENT_COLUMNS = ["time", "start_time", "start_price", "end_time", "end_price", "dir", "move", "length_atr", "bars", "retracement", "depth"]

IMPULSE, PULLBACK, NONE = "IMPULSE", "PULLBACK", "NONE"
# depth classes of a pullback by its retracement, upper limits: aggressive < 0.25 <= healthy < 0.5 <= deep < 0.75 <= weak < 1 <= invalid
DEPTH_LIMITS = ((0.25, "AGGRESSIVE"), (0.5, "HEALTHY"), (0.75, "DEEP"), (1.0, "WEAK"))
DEFAULTS = {"atr_period": 14}


def depth_of(retracement):
    for limit, name in DEPTH_LIMITS:
        if retracement < limit:
            return name
    return "INVALID"


class Tracker:
    """The legs of one pair: load gives every leg, update only the ones new swings close."""

    def __init__(self, params=None):
        self.p = {**DEFAULTS, **(params or {})}
        self.reset()

    def reset(self):
        self.open = None        # the newest swing: (type, time, price), it may still be replaced
        self.start = None       # the final swing before it
        self.previous = 0.0     # length (price) of the leg before the last one

    def feed(self, bars, swings, conditions):
        """Go through swings (oldest confirmation first); returns the rows of the legs they close."""
        rows = []
        if swings.empty:
            return rows
        times = bars["time"].to_numpy()
        atr = np.nan_to_num(np.asarray(atr_indicator(bars, {"period": self.p["atr_period"]})[0][0], dtype=float))
        state_times = conditions["time"].to_numpy() if not conditions.empty else np.array([], dtype="int64")
        state_names = conditions["state"].to_numpy() if not conditions.empty else np.array([])
        for confirmed, kind, moment, price in zip(swings["confirmed_time"].to_numpy(), swings["type"].to_numpy(),
                                                   swings["time"].to_numpy(), swings["price"].to_numpy(dtype=float)):
            if self.open is None:
                self.open = (kind, int(moment), price)
                continue
            if kind == self.open[0]:   # the same side again: the more extreme one stays
                if (price > self.open[2]) if kind == "HIGH" else (price < self.open[2]):
                    self.open = (kind, int(moment), price)
                continue
            # the other side: the open swing is final, the leg that ends in it is complete
            if self.start is not None:
                rows.append(self.leg(self.start, self.open, int(confirmed), times, atr, state_times, state_names))
            self.start = self.open
            self.open = (kind, int(moment), price)
        return rows

    def leg(self, start, end, known, times, atr, state_times, state_names):
        """The row of the leg start -> end, given when `known` (the confirmation of the swing after it)."""
        length = abs(end[2] - start[2])
        up = end[0] == "HIGH"   # by the side of the swing that ends it: after a gap a high can lie under the low before it
        at = min(int(np.searchsorted(times, end[1])), len(atr) - 1)
        scale = atr[at]
        # the state when the leg ended: the newest change at or before the confirmation of its last swing
        found = int(np.searchsorted(state_times, known, side="right")) - 1
        state = state_names[found] if found >= 0 else "NONE"
        move = NONE
        if state == "UPTREND":
            move = IMPULSE if up else PULLBACK
        elif state == "DOWNTREND":
            move = IMPULSE if not up else PULLBACK
        retracement = length / self.previous if self.previous > 0 else 0.0
        depth = depth_of(retracement) if move == PULLBACK else NONE
        self.previous = length
        return (known, start[1], start[2], end[1], end[2], "BUY" if up else "SELL", move,
                round(length / scale, 4) if scale > 0 else 0.0,
                int(np.searchsorted(times, end[1])) - int(np.searchsorted(times, start[1])), round(retracement, 4), depth)

    def load(self, bars, swings, conditions):
        self.reset()
        return to_frame(self.feed(bars, swings, conditions))

    def update(self, bars, swings, since, conditions):
        if swings is None or swings.empty:
            return to_frame([])
        return to_frame(self.feed(bars, swings[swings["confirmed_time"] > since], conditions))


def to_frame(rows):
    frame = pd.DataFrame(rows, columns=EVENT_COLUMNS)
    return frame.astype({"time": "int64", "start_time": "int64", "end_time": "int64"})


def find_movements(bars, swings, conditions, params=None):
    return Tracker(params).load(bars, swings, conditions)
