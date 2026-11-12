import numpy as np
import pandas as pd

from indicators import atr as atr_indicator

# Trendline lifecycle (Born -> Live -> Dead) as a pure function of the closed bars and the swings, like swing.py and structure.py.
# The idea and most of the rules come from Francis Nyoike Thumbi (CTrendlineBuilder / CManagedTrendline, mql5 articles 23626 and 24253).
# What differs, on purpose:
#   - a line is replayed from its birth over the history, so a line found late already knows what price did to it
#   - the ATR is the one of the bar being judged, not the newest one
#   - when a swing is confirmed (swing 0) the lines are drawn from it to each of the n_swings - 1 swings of its side before it (a high to
#     the highs, a low to the lows), any slope, and only if the swings in between are on the right side of the line (below a
#     resistance, above a support). The lines are checked by the SWINGS: a new swing high above a resistance (a new swing low below a
#     support) breaks it, and a line whose first swing is out of the last n_swings swings is dropped. So the lines that are alive are
#     the near ones, at most n_swings - 1 of a side
#   - a support is only a support (the line over lows): a close below it is a break, never a "bounce" (the original decides the side from the touching bar)
#   - a line is dead when the market structure breaks against it and the close of that bar is beyond the line: a break up (see structure.py)
#     kills the resistances that are below that close, a break down the supports that are above it. A resistance of the old downtrend
#     that price went through does not come back; one that is still above the price is not touched
#   - a line is dead when a swing breaks it, or when it is dropped (its first swing is out of the window): no age, no distance, no waiting
#     time, no coming back, and the closes of price do not kill it (the original lets a broken line wait expiration bars and come back).
#     What price does to a line, touch and bounce, is still an event: it is information
#   - a line steeper than max_slope_atr is not a trendline
# The idea of which lines are drawn is the user's (the newest swing joined to the n_swings before it); the checks follow the series Price Action
# Analysis Toolkit Development by Christian Benjamin (mql5 articles 21226 and 21277): the swings must be big enough (min_swing_atr ATRs),
# the two anchors must have moved at least min_move_atr ATRs. What differs, on purpose: the ATR is the one of the bar being judged (the
# original takes the newest ATR for every swing), and a line has a lifecycle (the original redraws everything on every bar)
# Speed: only the swings of the window are looked at (numpy, never one pandas row at a time). A line is a small state that goes
# forward bar by bar (advance): a line that is dead is never looked at again, the Tracker keeps the living ones between two bars

KIND = "TRENDLINE"
EVENT_COLUMNS = ["kind", "origin_time", "time", "event", "dir", "t1", "p1", "t2", "p2", "reason"]

DEFAULTS = {
    # what the user sets (the EA inputs)
    "enable": True,
    "confirm_atr": 1.0,              # ATRs a close must be away from the line to bounce
    "confirm_closes": 2,             # consecutive closes that confirm a bounce
    "min_move_atr": 0.2,            # ATRs the second anchor must be above / below the first
    "n_swings": 50,                 # a new swing is joined to the n_swings - 1 swings of its side before it
    "min_swing_atr": 0.8,           # ATRs a swing must be big to be an anchor (0 = every swing; the series uses 0.8)
    # what stays in the code
    "atr_period": 14,
    "touch_atr_mult": 0.2,
    "min_bars_between": 5,           # bars between the two anchors (two swings of a side are 6 bars apart at least with strength 5)
    "max_slope_atr": 0.3,            # ATRs per bar: steeper lines are not built
    "history_bars": 2000,            # only the lines born in the newest bars are built
}


def significant(arrays, swings, atr, p):
    """The swings that are big enough, of each side: (time, confirmed time, price, bar, bar that confirmed it), oldest first."""
    times, high, low, _close = arrays
    m = len(times)
    min_swing = float(p["min_swing_atr"])
    sw_type = swings["type"].to_numpy()
    out = {}
    for side in ("LOW", "HIGH"):
        mine = np.flatnonzero(sw_type == side)   # the swings of this side, oldest first
        s_time, s_confirmed, s_price = swings["time"].to_numpy()[mine], swings["confirmed_time"].to_numpy()[mine], swings["price"].to_numpy(dtype=float)[mine]
        bar = np.searchsorted(times, s_time)                                     # the bar of each swing
        known = np.minimum(np.searchsorted(times, s_confirmed), m - 1)           # the bar that confirmed it
        ok = (bar >= 2) & (bar + 2 < m)
        if min_swing > 0:   # the size of a swing: its extreme against the nearer of the two sides' own extremes, as the series does
            c = np.clip(bar, 2, m - 3)
            if side == "LOW":
                size = np.minimum(np.maximum(high[c - 1], high[c - 2]), np.maximum(high[c + 1], high[c + 2])) - low[c]
            else:
                size = high[c] - np.maximum(np.minimum(low[c - 1], low[c - 2]), np.minimum(low[c + 1], low[c + 2]))
            ok &= size >= min_swing * atr[known]
        keep = np.flatnonzero(ok)
        out[side] = (s_time[keep], s_confirmed[keep], s_price[keep], bar[keep], known[keep])
    return out


def find_lines(arrays, swings, atr, p, since=None):
    """[(dir, t1, p1, t2, p2, birth)]: when a swing is confirmed, the lines from it to each of the n_swings - 1 swings of its side before it:
    support lines (BUY) over lows, resistance lines (SELL) over highs, oldest birth first. The swings in between must be on the right
    side of the line (above a support, below a resistance). since = a time: only the lines born after it."""
    times, high, low, close = arrays
    m = len(times)
    first_time = times[max(0, m - int(p["history_bars"]))]
    min_move, min_bars, n_swings = float(p["min_move_atr"]), int(p["min_bars_between"]), max(2, int(p["n_swings"]))
    sig = significant(arrays, swings, atr, p)
    lines = []
    for side, direction in (("LOW", "BUY"), ("HIGH", "SELL")):
        up = direction == "BUY"
        s_time, s_confirmed, s_price, bar, known = sig[side]
        n = len(s_time)
        start = 1
        if since is not None:   # only the swings confirmed after it give lines that are born after it
            late = np.flatnonzero(s_confirmed > since)
            if not len(late):
                continue
            start = max(1, int(late[0]))
        for j in range(start, n):
            birth = int(s_confirmed[j])
            if (since is not None and birth <= since) or birth < first_time:
                continue
            for a in range(max(0, j - n_swings + 1), j):
                p1, p2, t1, t2 = float(s_price[a]), float(s_price[j]), int(s_time[a]), int(s_time[j])
                i1, i2 = int(bar[a]), int(bar[j])
                if t1 < times[0] or i2 - i1 < min_bars or abs(p2 - p1) < min_move * atr[known[j]]:
                    continue
                if atr[known[j]] > 0 and abs(p2 - p1) / (i2 - i1) > p["max_slope_atr"] * atr[known[j]]:
                    continue   # too steep to be a trendline
                between = np.arange(a + 1, j)   # the swings in between must be on the right side of the line
                if len(between):
                    on_line = p1 + (p2 - p1) * (s_time[between] - t1) / (t2 - t1)
                    if (np.any(s_price[between] < on_line) if up else np.any(s_price[between] > on_line)):
                        continue
                lines.append((direction, t1, p1, t2, p2, birth))
    lines.sort(key=lambda line: (line[5], line[3], line[1]))
    return lines


def life_end(direction, t1, p1, t2, p2, sig_side, n_swings, birth=0, breaks=None, ref=None):
    """(when, why) a line ends, going through the swings of its side: the first swing after its second swing that is above a resistance
    (below a support) breaks it, and when its first swing is out of the last n_swings swings it is dropped. (None, None) while it lives."""
    s_time, s_confirmed, s_price = sig_side[0], sig_side[1], sig_side[2]
    n = len(s_time)
    first = int(np.searchsorted(s_time, t1, side="left"))   # the first swing of the line
    dropped = first + n_swings                              # the swing that is the n_swings-th after it: the line leaves the window
    end, why = None, None
    if breaks is not None and len(breaks) and ref is not None:   # the first break of the structure after the line is known, with the close beyond the line
        later = breaks[int(np.searchsorted(breaks, birth, side="right")):]
        if len(later):
            at = np.minimum(np.searchsorted(ref[0], later), len(ref[0]) - 1)
            on_line = p1 + (p2 - p1) * (later - t1) / (t2 - t1)
            beyond = np.flatnonzero((ref[1][at] < on_line) if direction == "BUY" else (ref[1][at] > on_line))
            if len(beyond):
                end, why = int(later[beyond[0]]), "BROKEN"
    after = np.arange(int(np.searchsorted(s_time, t2, side="right")), min(n, dropped + 1))
    if len(after):
        on_line = p1 + (p2 - p1) * (s_time[after] - t1) / (t2 - t1)
        broken = np.flatnonzero((s_price[after] < on_line) if direction == "BUY" else (s_price[after] > on_line))
        if len(broken):
            moment = int(s_confirmed[after[broken[0]]])
            if end is None or moment < end:
                end, why = moment, "BROKEN"
    if dropped < n:
        left = int(s_confirmed[dropped])
        if end is None or left < end:
            end, why = left, "REPLACED"
    return end, why


def new_state(line, serial=0):
    """The state of a line that has not seen a bar yet. Lines of a side that are born at the same bar (the swings of a new swing sees)
    have each its own origin, the birth plus a number of seconds: the origin is what names a line in the EA."""
    direction, t1, p1, t2, p2, birth = line
    return {"dir": direction, "t1": t1, "p1": p1, "t2": t2, "p2": p2, "birth": birth, "origin": birth + serial, "until": None, "why": None,
            "born": False, "dead": False, "state": "ACTIVE", "k": 1, "bounces": 0}


def advance(s, arrays, atr, p):
    """The new events of one line, going forward from where it stopped to the newest bar. s is changed; s["dead"] when it died.
    A line lives until a swing breaks it or it is dropped (s["until"], s["why"]); price only touches it and bounces off it."""
    all_times, all_high, all_low, all_close = arrays
    birth_index = int(np.searchsorted(all_times, s["birth"]))
    # the bars from the birth on, indexed from 0 = the birth bar
    times, high, low, close, a = (x[birth_index:] for x in (all_times, all_high, all_low, all_close, atr))
    m = len(times)
    if m == 0 or times[0] != s["birth"]:
        s["dead"] = True   # its birth is not in the bars we hold any more
        return []
    direction, t1, p1, t2, p2, birth = s["dir"], s["t1"], s["p1"], s["t2"], s["p2"], s["birth"]
    expected = p1 + (p2 - p1) / (t2 - t1) * (times - t1)
    diff = close - expected

    def row(index, event, reason=""):
        return (KIND, s["origin"], int(times[index]), event, direction, t1, p1, t2, p2, reason)

    rows = []
    if not s["born"]:
        rows.append((KIND, s["origin"], birth, "BORN", direction, t1, p1, t2, p2, ""))
        s["born"] = True
    confirm = int(p["confirm_closes"])
    state, i, bounces = s["state"], s["k"], s["bounces"]
    support = direction == "BUY"   # the side of the line is its direction, not where the touching bar happened to close
    signed = diff if support else -diff   # positive = on the side the line holds
    ended_at = int(np.searchsorted(times, s["until"])) if s["until"] is not None else m   # the bar where a swing ended it
    while i < m:
        if i >= ended_at:
            if s["why"] == "BROKEN":
                rows.append(row(i, "BROKEN"))
            rows.append(row(i, "DEAD", s["why"] or "REPLACED"))
            s["dead"] = True
            break
        if state == "ACTIVE":
            threshold = a[i:ended_at] * p["touch_atr_mult"]
            # a touch is a bar that reaches the line (its range holds the line) or ends near it
            near = ((low[i:ended_at] <= expected[i:ended_at]) & (expected[i:ended_at] <= high[i:ended_at])) | \
                   (np.abs(diff[i:ended_at]) <= threshold) | (np.abs(high[i:ended_at] - expected[i:ended_at]) <= threshold) | \
                   (np.abs(low[i:ended_at] - expected[i:ended_at]) <= threshold)
            hit = np.flatnonzero(near)
            if not len(hit):
                i = ended_at   # nothing touched it until the end of its life (or the newest bar)
                continue
            i += int(hit[0])
            rows.append(row(i, "TOUCHED"))
            state, bounces = "PENDING", 0
            i += 1
        else:   # PENDING: it waits for the bounce
            bounces = bounces + 1 if signed[i] >= a[i] * p["confirm_atr"] else 0
            if bounces >= confirm:
                rows.append(row(i, "BOUNCED"))
                state = "ACTIVE"
                i += 2   # one bar of rest, as in the original
            else:
                i += 1
    s["state"], s["k"], s["bounces"] = state, i, bounces
    return rows


def replay(line, arrays, atr, p):
    """The events of one line, from its birth to its death (or to the newest bar)."""
    return advance(new_state(line), arrays, atr, p)


def to_frame(rows):
    if not rows:
        return pd.DataFrame(columns=EVENT_COLUMNS)
    return pd.DataFrame(rows, columns=EVENT_COLUMNS).sort_values(["time", "origin_time"], kind="stable").reset_index(drop=True)


class Tracker:
    """The trendlines that are alive: load gives every event of the bars, update only the ones a new bar brings."""

    def __init__(self, params=None):
        self.p = {**DEFAULTS, **(params or {})}
        self.alive = []

    def arrays(self, bars):
        atr = np.nan_to_num(np.asarray(atr_indicator(bars, {"period": self.p["atr_period"]})[0][0], dtype=float))
        return (bars["time"].to_numpy(), bars["high"].to_numpy(dtype=float), bars["low"].to_numpy(dtype=float),
                bars["close"].to_numpy(dtype=float)), atr

    @staticmethod
    def break_times(structures):
        """The times of the breaks of the market structure: up (they kill the resistances = SELL lines) and down (the supports = BUY lines)."""
        if structures is None or len(structures) == 0:
            return {"SELL": np.empty(0, dtype=np.int64), "BUY": np.empty(0, dtype=np.int64)}
        times = structures["break_time"].to_numpy(dtype=np.int64)
        up = structures["dir"].to_numpy() == "BUY"
        return {"SELL": np.sort(times[up]), "BUY": np.sort(times[~up])}

    def run(self, lines, arrays, atr, sig, breaks):
        rows, serial = [], {}
        for line in lines:
            n = serial[(line[0], line[5])] = serial.get((line[0], line[5]), -1) + 1   # the lines of a side born at the same bar are numbered
            s = new_state(line, n)
            s["until"], s["why"] = life_end(line[0], line[1], line[2], line[3], line[4], sig["LOW" if line[0] == "BUY" else "HIGH"], int(self.p["n_swings"]), line[5], breaks[line[0]], (arrays[0], arrays[3]))
            rows.extend(advance(s, arrays, atr, self.p))
            if not s["dead"]:
                self.alive.append(s)
        return rows

    def load(self, bars, swings, structures=None):
        """Every event of every trendline of these bars (EVENT_COLUMNS), oldest first; the living lines are kept."""
        self.alive = []
        if not self.p["enable"] or len(bars) < 3 or swings is None or swings.empty:
            return to_frame([])
        arrays, atr = self.arrays(bars)
        return to_frame(self.run(find_lines(arrays, swings, atr, self.p), arrays, atr, significant(arrays, swings, atr, self.p), self.break_times(structures)))

    def update(self, bars, swings, since, structures=None):
        """The events after the bar `since` (a time): the living lines go forward, the lines born after it start."""
        if not self.p["enable"] or len(bars) < 3 or swings is None or swings.empty:
            return to_frame([])
        arrays, atr = self.arrays(bars)
        rows = []
        sig = significant(arrays, swings, atr, self.p)
        breaks = self.break_times(structures)
        living, self.alive = self.alive, []
        for s in living:
            if s["until"] is None:   # the swings that came since may end it
                s["until"], s["why"] = life_end(s["dir"], s["t1"], s["p1"], s["t2"], s["p2"], sig["LOW" if s["dir"] == "BUY" else "HIGH"], int(self.p["n_swings"]), s["birth"], breaks[s["dir"]], (arrays[0], arrays[3]))
            rows.extend(advance(s, arrays, atr, self.p))
            if not s["dead"]:
                self.alive.append(s)
        rows.extend(self.run(find_lines(arrays, swings, atr, self.p, since), arrays, atr, sig, breaks))
        return to_frame(rows)


def find_trendlines(bars, swings, params=None):
    """Every event of every trendline: one row per event (EVENT_COLUMNS), oldest first."""
    return Tracker(params).load(bars, swings)
