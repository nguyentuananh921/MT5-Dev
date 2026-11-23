import numpy as np
import pandas as pd

from indicators import atr as atr_indicator, sma

# Supply / demand zone lifecycle (Born -> Live -> Dead) as a pure function of the closed bars and the swings, like trendline.py.
# The idea and most of the rules come from Francis Nyoike Thumbi (mql5 articles 22666, 23079, 23346, 23547: CZone, TryCreateAutoZone,
# AnalyzeZoneCandidate, ResolvePendingInteractions, MonitorZoneLifecycle). What differs, on purpose:
#   - a zone is born when the bars say so (the swing is confirmed and the departure measured), not when the EA happens to run:
#     the original asks the current Bid/Ask whether a zone is valid and the current ATR for its size
#   - the ATR is the one of the bar being judged; the score only reads bars that exist at the birth of the zone (the original's
#     "symmetry" test reads bars of the future on the first scan and does not on a live tick, so it scores the same zone twice)
#   - the touch band is its own parameter (touch_atr); the original reuses the merge sensitivity, 1.5 ATR, as the width of the band
#   - break and bounce counters are CONSECUTIVE closes (the original never resets them, so scattered closes add up)
#   - a break is stamped with the bar that confirmed it, not with the clock (TimeCurrent)
#   - a touch that never resolves gives up (pending_bars), an untouched zone gets old (max_age_bars), one that ends up
#     max_distance_atr away from price is out of play (OBSOLETE)
#   - a ghost comes back after confirmed closes inside the zone, not after a single one
# Not here yet: zones drawn by the user, merging two zones into one (a new zone is simply not born near a living one)

KIND = "ZONE"
EVENT_COLUMNS = ["kind", "origin_time", "time", "event", "dir", "t1", "p1", "t2", "p2", "reason"]

DEFAULTS = {
    # what the user sets (the EA inputs)
    "enable": True,
    "min_score": 50,                 # 0-100: the quality a zone needs to be born
    "confirm_closes": 2,             # consecutive closes that confirm a break, a bounce or a revival
    "ghost_bars": 10,                # a broken zone that did not come back dies after this many bars
    "revive": True,                  # a ghost may come back
    "max_age_bars": 500,             # a zone dies of old age after this many bars
    # what stays in the code
    "atr_period": 14,
    "height_atr": 0.5,               # height of the zone
    "touch_atr": 0.25,               # a bar this close to the zone touches it
    "break_atr": 1.0,                # a close this many ATRs beyond the far edge breaks it
    "bounce_atr": 0.5,               # a close this many ATRs away from the near edge is a rejection
    "pending_bars": 20,              # a touch that has not resolved after this many bars goes back to ACTIVE
    "merge_atr": 1.5,                # no zone is born this close (in ATRs) to a living one
    "lookahead_bars": 3,             # bars after the swing is confirmed that measure how fast price left it
    "volume_bars": 14,               # bars of the moving average of the volume (the swing bar included, as the MA of the Volumes indicator)
    "weight_volume": 30,
    "weight_velocity": 40,
    "weight_symmetry": 30,
    "max_distance_atr": 30.0,        # ATRs between the zone and the close: a zone further away dies (OBSOLETE)
    "history_bars": 2000,            # only the zones born in the newest bars are built
}


def score_of(p, vol_ratio, departure_atr, extreme):
    """The quality of a zone, 0-100: the volume on the swing bar, how fast price left it, and whether it is a clean extreme."""
    w_volume, w_velocity, w_symmetry = int(p["weight_volume"]), int(p["weight_velocity"]), int(p["weight_symmetry"])
    if vol_ratio >= 2.0:
        volume = w_volume
    elif vol_ratio <= 0.5:
        volume = 0
    else:
        volume = int((vol_ratio - 0.5) / 1.5 * w_volume)
    if departure_atr >= 2.5:
        velocity = w_velocity
    elif departure_atr <= 0.5:
        velocity = 0
    else:
        velocity = int((departure_atr - 0.5) / 2.0 * w_velocity)
    symmetry = w_symmetry if extreme else w_symmetry // 2
    return max(0, min(100, volume + velocity + symmetry))


def build_candidates(arrays, swings, atr, p, since_index=-1):
    """The zones the swings can give, oldest birth first: dict(dir, price, top, bottom, swing_time, birth, birth_time, score, report).
    since_index = a bar index: only the zones born after that bar (the ones a new bar can give)."""
    times, high, low, close, volume = arrays
    n = len(times)
    first_time = times[max(0, n - int(p["history_bars"]))]   # the zones born from here on are the ones that are reported
    # A zone born before that can still be alive and keep a new one from being born next to it: those are built too, and only
    # not reported, so that the window sliding by a bar does not change which zones are born inside it
    margin = int(p["max_age_bars"]) + int(p["ghost_bars"]) + 2 * int(p["pending_bars"])
    build_time = times[max(0, n - int(p["history_bars"]) - margin)]
    look = int(p["lookahead_bars"])
    volume_average = sma(volume, int(p["volume_bars"]))   # the MA of the volume, the same one the Volumes indicator draws
    sw_time = swings["time"].to_numpy()
    sw_type = swings["type"].to_numpy()
    sw_price = swings["price"].to_numpy(dtype=float)
    swing_bars = np.searchsorted(times, sw_time)
    confirmed_at = np.searchsorted(times, swings["confirmed_time"].to_numpy())
    births = confirmed_at + look   # the swing is confirmed and the departure is measured
    # the swings that can give a zone in the window, found for all of them at once; only those are looked at one by one
    possible = np.flatnonzero((births < n) & (births > since_index))
    possible = possible[(times[births[possible]] >= build_time) & (atr[births[possible]] > 0)]
    found = []
    for k in possible:
        swing_bar, confirmed, birth = int(swing_bars[k]), int(confirmed_at[k]), int(births[k])
        support = sw_type[k] == "LOW"
        price = float(sw_price[k])
        if close[birth] <= price if support else close[birth] >= price:
            continue   # price is already on the other side of it
        height = p["height_atr"] * atr[birth]
        top, bottom = (price + height, price) if support else (price, price - height)
        # volume of the swing bar (a closed bar) against the MA of the volume at that bar, which counts the swing bar itself
        reference = volume_average[swing_bar]
        vol_ratio = volume[swing_bar] / reference if reference > 0 else 1.0   # no MA yet (NaN) = no information = 1
        # how far price went from the swing bar, in ATRs, `look` bars later
        later = min(swing_bar + look, n - 1)
        departure = (close[later] - price) if support else (price - close[later])
        # the swing bar is the clean extreme of the bars around it (twice the bars that confirmed it) that exist at the birth
        macro = 2 * (confirmed - swing_bar)
        lo_i, hi_i = max(0, swing_bar - macro), min(birth, swing_bar + macro)
        if support:
            extreme = int((low[lo_i:hi_i + 1] <= low[swing_bar]).sum()) == 1
        else:
            extreme = int((high[lo_i:hi_i + 1] >= high[swing_bar]).sum()) == 1
        score = score_of(p, vol_ratio, departure / atr[birth], extreme)
        if score < int(p["min_score"]):
            continue
        found.append({"dir": "BUY" if support else "SELL", "price": price, "top": top, "bottom": bottom,
                      "swing_time": int(sw_time[k]), "birth": birth, "birth_time": int(times[birth]), "score": score,
                      "report": bool(times[birth] >= first_time)})
    return sorted(found, key=lambda z: (z["birth"], z["swing_time"]))


def new_state(z):
    """The state of a zone that has not seen a bar yet."""
    return {"dir": z["dir"], "price": z["price"], "top": z["top"], "bottom": z["bottom"], "swing_time": z["swing_time"],
            "birth": z["birth_time"], "report": z["report"], "born": False, "dead": False, "death_time": None,
            "state": "ACTIVE", "k": 1, "far_k": None, "far_checked": 0,
            "outside": 0, "rejections": 0, "pending": 0, "since_break": 0, "reclaims": 0}


def advance(s, arrays, atr, p):
    """The new events of one zone, going forward from where it stopped to the newest bar. s is changed; when it died, s["dead"]
    and s["death_time"] (the time of the bar) are set."""
    all_times, all_high, all_low, all_close, _volume = arrays
    top, bottom, support = s["top"], s["bottom"], s["dir"] == "BUY"
    birth_index = int(np.searchsorted(all_times, s["birth"]))
    # the bars from the birth on, indexed from 0 = the birth bar
    times, high, low, close, a = (x[birth_index:] for x in (all_times, all_high, all_low, all_close, atr))
    m = len(times)
    if m == 0 or times[0] != s["birth"]:
        s["dead"] = True   # its birth is not in the bars we hold any more
        return []
    birth, t1 = s["birth"], s["swing_time"]
    confirm = int(p["confirm_closes"])

    def row(index, event, reason=""):
        return (KIND, birth, int(times[index]), event, s["dir"], t1, top, t1, bottom, reason)

    if s["far_k"] is None and m > s["far_checked"]:   # price further from the zone than it is worth: the first bar where it happens
        lo = s["far_checked"]
        distance = np.maximum(np.maximum(bottom - close[lo:], close[lo:] - top), 0.0)
        far = (a[lo:] > 0) & (distance > p["max_distance_atr"] * a[lo:])
        if lo == 0:
            far[0] = False
        hits = np.flatnonzero(far)
        if len(hits):
            s["far_k"] = lo + int(hits[0])
        s["far_checked"] = m
    far_at = s["far_k"] if s["far_k"] is not None else m
    rows = []
    if not s["born"]:
        rows.append((KIND, birth, birth, "BORN", s["dir"], t1, top, t1, bottom, ""))
        s["born"] = True
    limit = int(p["max_age_bars"])
    state, i = s["state"], s["k"]
    outside, rejections, pending, since_break, reclaims = s["outside"], s["rejections"], s["pending"], s["since_break"], s["reclaims"]

    def die(index, reason):
        rows.append(row(index, "DEAD", reason))
        s["dead"], s["death_time"] = True, int(times[index])

    while i < m:
        if i >= far_at:
            die(i, "OBSOLETE")
            break
        if state == "ACTIVE":
            end = min(m, limit, far_at)
            if i >= end:   # the window of its age is over (the far case was handled above)
                die(i, "EXPIRED")
                break
            aura = a[i:end] * p["touch_atr"]
            hit = np.flatnonzero((low[i:end] <= top + aura) & (high[i:end] >= bottom - aura))
            if not len(hit):
                i = end
                continue
            i += int(hit[0])
            rows.append(row(i, "TOUCHED"))
            state, outside, rejections, pending = "PENDING", 0, 0, 0
            i += 1
        elif state == "PENDING":
            pending += 1
            beyond_by, away_by = a[i] * p["break_atr"], a[i] * p["bounce_atr"]
            if support:
                beyond, clear = close[i] < bottom - beyond_by, close[i] >= top + away_by
            else:
                beyond, clear = close[i] > top + beyond_by, close[i] <= bottom - away_by
            if beyond:
                outside, rejections = outside + 1, 0
            elif clear:
                rejections, outside = rejections + 1, 0
            else:
                outside = rejections = 0   # consecutive closes: anything else starts the count again
            if outside >= confirm:
                rows.append(row(i, "BROKEN"))
                state, since_break, reclaims = "GHOST", 0, 0
                i += 1
            elif rejections >= confirm:
                rows.append(row(i, "BOUNCED"))
                state = "ACTIVE"
                i += 2   # one bar of rest
            else:
                if pending >= int(p["pending_bars"]):
                    state = "ACTIVE"   # the touch never resolved
                i += 1
        else:   # GHOST: broken, still watched
            since_break += 1
            if p["revive"]:
                reclaims = reclaims + 1 if bottom <= close[i] <= top else 0
                if reclaims >= confirm:
                    rows.append(row(i, "RESURRECTED"))
                    state, since_break = "ACTIVE", 0
                    i += 1
                    continue
            if since_break >= int(p["ghost_bars"]):
                die(i, "EXPIRED")
                break
            i += 1
    s["state"], s["k"] = state, i
    s["outside"], s["rejections"], s["pending"], s["since_break"], s["reclaims"] = outside, rejections, pending, since_break, reclaims
    return rows


def replay(z, arrays, atr, p):
    """(events, state) of one zone from its birth to its death or to the newest bar."""
    s = new_state(z)
    return advance(s, arrays, atr, p), s


def to_frame(rows):
    if not rows:
        return pd.DataFrame(columns=EVENT_COLUMNS)
    return pd.DataFrame(rows, columns=EVENT_COLUMNS).sort_values(["time", "origin_time"], kind="stable").reset_index(drop=True)


class Tracker:
    """The zones that are alive: load gives every event of the bars, update only the ones a new bar brings."""

    def __init__(self, params=None):
        self.p = {**DEFAULTS, **(params or {})}
        self.alive = []

    def arrays(self, bars):
        atr = np.nan_to_num(np.asarray(atr_indicator(bars, {"period": self.p["atr_period"]})[0][0], dtype=float))
        return (bars["time"].to_numpy(), bars["high"].to_numpy(dtype=float), bars["low"].to_numpy(dtype=float),
                bars["close"].to_numpy(dtype=float), bars["tick_volume"].to_numpy(dtype=float)), atr

    def born(self, candidates, arrays, atr, blockers):
        """Start the zones that no living zone is next to, oldest first. blockers = [(price, death time or None)] of the zones
        that may still keep one from being born; every zone that starts is added to it."""
        rows = []
        for z in candidates:
            near = self.p["merge_atr"] * atr[z["birth"]]
            if any((died is None or died > z["birth_time"]) and abs(price - z["price"]) < near for price, died in blockers):
                continue   # a living zone is already there
            s = new_state(z)
            events = advance(s, arrays, atr, self.p)
            blockers.append((s["price"], s["death_time"]))
            if not s["dead"]:
                self.alive.append(s)
            if s["report"]:
                rows.extend(events)
        return rows

    def load(self, bars, swings):
        """Every event of every zone of these bars (EVENT_COLUMNS), oldest first; the living zones are kept."""
        self.alive = []
        if not self.p["enable"] or len(bars) < 3 or swings is None or swings.empty:
            return to_frame([])
        arrays, atr = self.arrays(bars)
        return to_frame(self.born(build_candidates(arrays, swings, atr, self.p), arrays, atr, []))

    def update(self, bars, swings, since):
        """The events after the bar `since` (a time): the living zones go forward, the zones born after it start."""
        if not self.p["enable"] or len(bars) < 3 or swings is None or swings.empty:
            return to_frame([])
        arrays, atr = self.arrays(bars)
        rows, blockers = [], []
        living, self.alive = self.alive, []
        for s in living:
            events = advance(s, arrays, atr, self.p)
            blockers.append((s["price"], s["death_time"]))
            if not s["dead"]:
                self.alive.append(s)
            if s["report"]:
                rows.extend(events)
        since_index = int(np.searchsorted(arrays[0], since, side="right")) - 1
        rows.extend(self.born(build_candidates(arrays, swings, atr, self.p, since_index), arrays, atr, blockers))
        return to_frame(rows)


def find_zones(bars, swings, params=None):
    """Every event of every zone: one row per event (EVENT_COLUMNS), oldest first."""
    return Tracker(params).load(bars, swings)
