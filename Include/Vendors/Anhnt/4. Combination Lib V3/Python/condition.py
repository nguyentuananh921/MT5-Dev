import numpy as np
import pandas as pd

# Market State and Market Phase as a pure function of the breaks (BOS / CHoCH) of the swings, like swing.py and structure.py.
# One source only: the breaks. A swing gives a level, a break is the close beyond the newest swing of a side by at least min_step_atr
#   ATRs (structure.py finds them). Each break is judged against the one BEFORE it, as in the textbook picture of structure:
#     a break in the same direction as the one before = BOS (the move goes on)        -> UPTREND (up) / DOWNTREND (down)
#     a break in the opposite direction            = CHoCH (the character changed)  -> RANGE
#   so the State is a trend only when two breaks in a row go the same way, and a market whose breaks go up, down, up, down (a CHoCH
#   after a CHoCH, no BOS between) is a RANGE: the sideways part of that picture. The first break has none before it: it is a BOS.
#   Stanley Kimathi Kibaara's CMarketStateMachine (mql5 article 23049, ProcessBreakEvent) goes to a doubt state (STATE_TRANSITION) on a
#   CHoCH and takes the direction of the next BOS; we have three States, so the doubt is RANGE. He also asks the trend of the swings to
#   agree before a BOS against the State changes it, which kept the State in a trend that was over: not here
#   The idea of the min step is ours: without it a rise of 0.2 points on XAUUSD M1 made an uptrend of a market that was going sideways
# Phase (4 recurring market cycles) follows from the State and the trend that came before it:
#   UPTREND = MARKUP, DOWNTREND = MARKDOWN, RANGE after a downtrend = ACCUMULATION, RANGE after an uptrend = DISTRIBUTION
# The Tracker keeps what it needs (the State, the direction of the last break and the kind each break got): a new break is one step, the history is not read again

VERSION = 5   # raise it when the rules, or what the Tracker keeps, change: what the disk kept of it is not used any more
EVENT_COLUMNS = ["time", "state", "phase"]

DEFAULTS = {
    "min_step_atr": 0.3,    # ATRs the close must be beyond the level of a swing to break it
    "atr_period": 14,
}

UPTREND, DOWNTREND, RANGE, NONE = "UPTREND", "DOWNTREND", "RANGE", "NONE"
MARKUP, MARKDOWN, ACCUMULATION, DISTRIBUTION = "MARKUP", "MARKDOWN", "ACCUMULATION", "DISTRIBUTION"
BOS, CHOCH = "BOS", "CHOCH"


def settings(overrides=None):
    """The settings of the market condition: the defaults with what the EA sent."""
    return {**DEFAULTS, **(overrides or {})}


class Tracker:
    """The market condition of one pair: load gives every change of State / Phase, update only the ones new breaks bring."""

    def __init__(self, params=None):
        self.p = settings(params)
        self.reset()

    def reset(self):
        self.state, self.phase = NONE, NONE
        self.last_trend = None
        self.last_break = None   # the direction (BUY / SELL) of the break before the one being judged
        self.kinds = {}   # (break time, direction) -> BOS / CHOCH: the kind each break got from the State of its time

    def phase_of(self, state):
        if state == UPTREND:
            return MARKUP
        if state == DOWNTREND:
            return MARKDOWN
        if self.last_trend == DOWNTREND:
            return ACCUMULATION
        if self.last_trend == UPTREND:
            return DISTRIBUTION
        return NONE   # a range with no trend before it: no cycle to name yet

    def on_break(self, rows, moment, direction):
        """One break at moment (direction BUY = the price broke upwards): its kind, and the State that follows."""
        up = (direction == "BUY")
        against = (self.last_break is not None and direction != self.last_break)   # the opposite of the break before it
        self.last_break = direction
        self.kinds[(int(moment), direction)] = CHOCH if against else BOS
        state = RANGE if against else UPTREND if up else DOWNTREND
        if state == self.state:
            return
        if state in (UPTREND, DOWNTREND):
            self.last_trend = state
        self.state, self.phase = state, self.phase_of(state)
        rows.append((int(moment), self.state, self.phase))

    def feed(self, structures):
        """Go through the breaks (oldest first); returns the rows where the State or the Phase changed."""
        rows = []
        if structures is None or structures.empty:
            return rows
        for moment, direction in zip(structures["break_time"].to_numpy(), structures["dir"].to_numpy()):
            self.on_break(rows, moment, direction)
        return rows

    def load(self, structures):
        """Every change of State / Phase of these breaks (EVENT_COLUMNS), oldest first."""
        self.reset()
        return to_frame(self.feed(structures))

    def update(self, structures, since):
        """The changes the breaks that came after `since` (a time) bring."""
        if structures is None or structures.empty:
            return to_frame([])
        return to_frame(self.feed(structures[structures["break_time"] > since]))

    def classify(self, structures, everything=False):
        """The structures with their type, the kind each break got (BOS / CHoCH). Only the ones that are still BREAK,
        or all of them (everything) when they were classified with other settings."""
        if structures is None or structures.empty:
            return structures
        out = structures.copy()
        kind = np.array([self.kinds.get((int(t), d), BOS) for t, d in zip(out["break_time"].to_numpy(), out["dir"].to_numpy())], dtype=object)
        todo = np.ones(len(out), dtype=bool) if everything else (out["type"].to_numpy() == "BREAK")
        out["type"] = np.where(todo, kind, out["type"].to_numpy())
        return out


def to_frame(rows):
    return pd.DataFrame(rows, columns=EVENT_COLUMNS).astype({"time": "int64"})   # an empty frame keeps the type, joining it keeps the rest


def find_conditions(structures, params=None):
    """Every change of State / Phase: one row per change (EVENT_COLUMNS), oldest first."""
    return Tracker(params).load(structures)
