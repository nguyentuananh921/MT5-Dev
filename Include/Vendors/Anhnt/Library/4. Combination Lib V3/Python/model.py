import time

import numpy as np
import pandas as pd

from data import fetch_closed_bars, fetch_forming_bar, fetch_last_closed_time, symbol_point
from indicators import compute, from_template
from patterns import find_patterns
from signals import directions, flips
from structure import find_structures
from swing import find_swings
import cache
import condition
import movement
import trendline
import fvg
import momentum
import supplydemand
import zone
from trendline import find_trendlines
from zone import find_zones

DEFAULT_STRENGTH = 5
DEFAULT_USE_WICK = True
SIGNAL_COLUMNS = ["time", "label", "dir", "template"]
LIVE_BARS = 3000   # the live state is calculated on the newest closed bars and the forming one
# A new bar is not a reason to calculate everything again: the newest bars are fetched and calculated, what lies before the warm-up
# of that window stays as it was. The window must be long enough for the slowest indicator to settle and for the swings and
# structures to find their reference (both only look back to the last swing)
CACHE_SAVE_PERIOD = 600   # seconds: a pair with new bars is written to the disk again after this long
TAIL_FETCH_BARS = 3500   # closed bars fetched when a new one appears
TAIL_BARS = 3500         # the newest bars everything is calculated on
TAIL_KEEP_BARS = 1500    # from the start of that window, the results are not taken: its indicators are still warming up
LIFECYCLE_MARGIN_BARS = 1500   # bars before the ones the lifecycle reports on, so that what was born earlier is known


def indicator_state(template, buffers, direction):
    """(template, value of the last bar, value of the bar before, last direction) of one indicator."""
    values = np.asarray(buffers[0], dtype=float)
    given = np.nonzero(direction)[0]
    return (template, values[-1], values[-2] if len(values) > 1 else np.nan,
            "BUY" if len(given) and direction[given[-1]] > 0 else "SELL" if len(given) else "NONE")


def indicator_flips(bars, definitions):
    """Every direction change (BUY/SELL) of every indicator in definitions, oldest first, and the state each one ends in."""
    frames, states = [], []
    for label, name, params, template in definitions:
        buffers, _ = compute(name, bars, params)
        direction = directions(name, buffers, bars, params)
        flip = flips(direction)
        at = np.nonzero(flip)[0]
        frames.append(pd.DataFrame({"time": bars["time"].to_numpy()[at], "label": label,
                                    "dir": np.where(flip[at] > 0, "BUY", "SELL"), "template": template}))
        states.append(indicator_state(template, buffers, direction))
    if not frames:
        return pd.DataFrame(columns=SIGNAL_COLUMNS), states
    return pd.concat(frames, ignore_index=True).sort_values(["time", "label"]).reset_index(drop=True), states


def indicator_states(bars, definitions):
    """The state of every indicator on the last bar only: no history of flips."""
    states = []
    for label, name, params, template in definitions:
        buffers, _ = compute(name, bars, params)
        states.append(indicator_state(template, buffers, directions(name, buffers, bars, params)))
    return states


def fill_phase(structures, conditions):
    """The BOS / CHoCH rows that have no Phase yet get the one in force at their break: the newest change at or before it."""
    out = structures.copy()
    if "phase" not in out:
        out["phase"] = None
    missing = out["phase"].isna().to_numpy()
    if not missing.any():
        return out
    phase = np.full(len(out), "NONE", dtype=object)
    if not conditions.empty:
        at = np.searchsorted(conditions["time"].to_numpy(), out["break_time"].to_numpy(), side="right") - 1
        phase = np.where(at >= 0, conditions["phase"].to_numpy(dtype=object)[np.maximum(at, 0)], "NONE")
    out["phase"] = np.where(missing, phase, out["phase"].to_numpy(dtype=object))
    return out


def fill_strength(structures, swings):
    """Every break gets its strong level: the swing the move that broke the structure started from, the last swing of the other side
    that was confirmed at or before the break (a break up: the swing low, a break down: the swing high). The level that was broken
    (swing_time, level) is the weak one. strong_time is 0 when there was no such swing."""
    out = structures.copy()
    out["strong_time"] = np.zeros(len(out), dtype=np.int64)
    out["strong_price"] = np.zeros(len(out), dtype=float)
    if out.empty or swings is None or swings.empty:
        return out
    for side, direction in (("LOW", "BUY"), ("HIGH", "SELL")):
        mine = swings[swings["type"] == side]
        rows = (out["dir"] == direction).to_numpy()
        if mine.empty or not rows.any():
            continue
        at = np.searchsorted(mine["confirmed_time"].to_numpy(), out["break_time"].to_numpy()[rows], side="right") - 1
        found = np.maximum(at, 0)
        out.loc[rows, "strong_time"] = np.where(at >= 0, mine["time"].to_numpy(dtype=np.int64)[found], 0)
        out.loc[rows, "strong_price"] = np.where(at >= 0, mine["price"].to_numpy(dtype=float)[found], 0.0)
    return out


def merge_tail(old, fresh, column, cut):
    """The rows of old before cut, then the rows of fresh from cut on: fresh was calculated on a window that started a while earlier."""
    return pd.concat([old[old[column] < cut], fresh[fresh[column] >= cut]], ignore_index=True)


LIFECYCLE_COLUMNS = ["kind", "origin_time", "time", "event", "dir", "t1", "p1", "t2", "p2", "reason"]


def lifecycle_events(bars, swings, trendline_params, zone_params):
    """The events (Born ... Dead) of every trendline and every zone of these bars, oldest first."""
    frames = [frame for frame in (find_trendlines(bars, swings, trendline_params), find_zones(bars, swings, zone_params)) if not frame.empty]
    if not frames:
        return pd.DataFrame(columns=LIFECYCLE_COLUMNS)
    return pd.concat(frames, ignore_index=True).sort_values(["time", "origin_time"], kind="stable").reset_index(drop=True)


def join_events(frames):
    frames = [frame for frame in frames if not frame.empty]
    if not frames:
        return pd.DataFrame(columns=LIFECYCLE_COLUMNS)
    return pd.concat(frames, ignore_index=True).sort_values(["time", "origin_time"], kind="stable").reset_index(drop=True)


class LifecycleTracker:
    """The trendlines and zones of one pair. load gives every event of the bars held (only the lines born in the history window
    are reported); update gives the events one new bar brings: the living ones go forward, a dead one is never looked at again."""

    def __init__(self, trendline_params, zone_params, momentum_params=None):
        self.trendline = trendline.Tracker(trendline_params)
        self.zone = zone.Tracker(zone_params)
        self.momentum = momentum.Tracker(momentum_params)
        self.supplydemand = supplydemand.Tracker(momentum_params)
        self.fvg = fvg.Tracker(momentum_params)
        self.history = max(int(self.trendline.p["history_bars"]), int(self.zone.p["history_bars"]), int(self.momentum.p["history_bars"]))

    def load(self, bars, swings, structures=None):
        window = bars.iloc[max(0, len(bars) - self.history - LIFECYCLE_MARGIN_BARS):].reset_index(drop=True)
        window.attrs["point"] = bars.attrs.get("point")
        swings = swings[swings["time"] >= int(window["time"].iloc[0])].reset_index(drop=True)
        return join_events([self.trendline.load(window, swings, structures), self.zone.load(window, swings),
                            self.momentum.load(window), self.supplydemand.load(window), self.fvg.load(window)])

    def update(self, window, swings, since, structures=None):
        """window = the newest bars (long enough to hold the living lines and the swings that start new ones), since = the newest bar before the new ones."""
        swings = swings[swings["time"] >= int(window["time"].iloc[0])].reset_index(drop=True)
        return join_events([self.trendline.update(window, swings, since, structures), self.zone.update(window, swings, since),
                            self.momentum.update(window, since), self.supplydemand.update(window, since), self.fvg.update(window, since)])


class Model:
    def __init__(self):
        self.strength = DEFAULT_STRENGTH
        self.use_wick = DEFAULT_USE_WICK
        self.count = 0
        self.definitions = []   # (label, name, params, template) of the indicators Python calculates; template = position of the row the EA sent
        self.bars = {}      # (symbol, tf_text) -> closed bars
        self.swings = {}    # (symbol, tf_text) -> swings of those bars
        self.structures = {}    # (symbol, tf_text) -> BOS/CHoCH of those bars
        self.signals = {}       # (symbol, tf_text) -> indicator signal flips of those bars
        self.monitor = {}       # (symbol, tf_text) -> state of every indicator on the newest closed bar (indicator_flips)
        self.live = {}          # (symbol, tf_text) -> the same on the forming bar, kept fresh by refresh_live
        self.live_stamp = {}    # (symbol, tf_text) -> the forming bar the live state was calculated on
        self.patterns = {}      # (symbol, tf_text) -> candle patterns of those bars
        self.lifecycle = {}     # (symbol, tf_text) -> lifecycle events (Born ... Dead) of the trendlines of those bars
        self.trackers = {}      # (symbol, tf_text) -> LifecycleTracker: the lines and zones that are still alive
        self.conditions = {}    # (symbol, tf_text) -> every change of Market State / Phase
        self.condition_trackers = {}   # (symbol, tf_text) -> condition.Tracker: where the market is now
        self.movements = {}     # (symbol, tf_text) -> every leg between the swings (Impulse / Pullback)
        self.movement_trackers = {}    # (symbol, tf_text) -> movement.Tracker: the swing that is still open
        self.trendline_params = {}   # overrides of trendline.DEFAULTS
        self.zone_params = {}        # overrides of zone.DEFAULTS
        self.momentum_params = {}    # overrides of momentum.DEFAULTS (the supply / demand zones use them too)
        self.condition_params = {}   # overrides of condition.DEFAULTS
        self.last_closed = {}   # (symbol, tf_text) -> time of the newest closed bar held
        self.fingerprint = ""    # what the kept results must have been made with (cache.fingerprint)
        self.dirty = set()      # the pairs that have new bars since their file was written
        self.saved_at = {}      # (symbol, tf_text) -> when its file was written
        self.queue = []         # the pairs that are calculated but not loaded yet: load_next takes them one by one while nobody asks for anything

    def drop_pair(self, key):
        for store in (self.bars, self.swings, self.structures, self.signals, self.monitor, self.patterns, self.lifecycle, self.trackers,
                      self.conditions, self.condition_trackers, self.movements, self.movement_trackers, self.last_closed):
            store.pop(key, None)
        self.dirty.discard(key)
        self.saved_at.pop(key, None)

    def apply_config(self, pairs, strength=DEFAULT_STRENGTH, use_wick=DEFAULT_USE_WICK, count=0, on_pair=None, indicators=None, trendline=None, zone=None, market_condition=None, priority=None, momentum=None):
        """pairs = everything Python calculates. priority = the pairs the EA shows: loaded now, the answer waits for them. The rest is
        loaded one by one afterwards (load_next), so that a pair the EA asks for later is already there."""
        started = time.perf_counter()
        wanted = list(dict.fromkeys((str(s), str(tf)) for s, tf in pairs))
        rows = indicators or []
        converted = [from_template(row) for row in rows]
        definitions = [item + (position,) for position, item in enumerate(converted) if item is not None]
        skipped = [str(row.get("m_indicator_type")) for row, item in zip(rows, converted) if item is None]
        trendline = dict(trendline or {})
        zone = dict(zone or {})
        market_condition = dict(market_condition or {})
        momentum_params = dict(momentum or {})
        rebuild = (strength, use_wick, count, definitions, trendline, zone, market_condition, momentum_params) != \
                  (self.strength, self.use_wick, self.count, self.definitions, self.trendline_params, self.zone_params, self.condition_params, self.momentum_params)
        self.strength, self.use_wick, self.count, self.definitions = strength, use_wick, count, definitions
        self.trendline_params = trendline
        self.zone_params = zone
        self.momentum_params = momentum_params
        self.condition_params = market_condition
        self.fingerprint = cache.fingerprint(strength, use_wick, count, definitions)
        self.live.clear()
        self.live_stamp.clear()
        for key in [k for k in self.bars if rebuild or k not in wanted]:   # new settings: what was calculated with the old ones goes
            self.drop_pair(key)
        first = set((str(s), str(tf)) for s, tf in (pairs if priority is None else priority))
        self.queue = [k for k in wanted if k not in first and k not in self.bars]
        report = []
        for symbol, tf_text in wanted:
            if (symbol, tf_text) not in first:
                continue
            row = self.load_pair(symbol, tf_text, False)
            report.append(row)
            if on_pair:
                on_pair(row)
        return {"total_ms": round((time.perf_counter() - started) * 1000, 1), "pairs": report, "skipped": skipped}

    def load_next(self):
        """Load the next pair of the queue: its row (error = why not), None when there is nothing left to load."""
        while self.queue:
            key = self.queue.pop(0)
            if key not in self.bars:
                return self.load_pair(key[0], key[1], False)
        return None

    def load_pair(self, symbol, tf_text, rebuild):
        key = (symbol, tf_text)
        row = {"symbol": symbol, "tf": tf_text}
        if key in self.bars and not rebuild:
            row.update(cached=True, bars=len(self.bars[key]), swings=len(self.swings[key]),
                       structures=len(self.structures[key]), signals=len(self.signals[key]),
                       patterns=len(self.patterns[key]), lifecycle=len(self.lifecycle[key]), conditions=len(self.conditions[key]))
            return row
        kept = cache.read(key, self.fingerprint)
        if kept is not None:   # made by an earlier run with the same settings and code: read it, calculate only the bars that came since
            started = time.perf_counter()
            try:
                self.adopt(key, kept)
                self.update_pair(key)
            except Exception as error:
                print(f"cache of {symbol} {tf_text} not used: {error}")
                self.drop_pair(key)
            else:
                row.update(cached=False, from_disk=True, bars=len(self.bars[key]), swings=len(self.swings[key]),
                           structures=len(self.structures[key]), signals=len(self.signals[key]), patterns=len(self.patterns[key]),
                           lifecycle=len(self.lifecycle[key]), conditions=len(self.conditions[key]),
                           disk_ms=round((time.perf_counter() - started) * 1000, 1))
                return row
        try:
            t0 = time.perf_counter()
            self.bars[key] = fetch_closed_bars(symbol, tf_text, self.count)
            t1 = time.perf_counter()
            self.swings[key] = find_swings(self.bars[key], self.strength, self.use_wick)
            t2 = time.perf_counter()
            self.structures[key] = self.structures_of(self.bars[key], self.swings[key])
            t3 = time.perf_counter()
            self.signals[key], self.monitor[key] = indicator_flips(self.bars[key], self.definitions)
            t4 = time.perf_counter()
            self.patterns[key] = find_patterns(self.bars[key], symbol_point(symbol))
            t5 = time.perf_counter()
            self.trackers[key] = LifecycleTracker(self.trendline_params, self.zone_params, self.momentum_params)
            self.lifecycle[key] = self.trackers[key].load(self.bars[key], self.swings[key], self.structures[key])
            self.condition_trackers[key] = condition.Tracker(self.condition_params)
            self.conditions[key] = self.condition_trackers[key].load(self.structures[key])
            self.structures[key] = fill_strength(fill_phase(self.condition_trackers[key].classify(self.structures[key], True), self.conditions[key]), self.swings[key])
            self.movement_trackers[key] = movement.Tracker()
            self.movements[key] = self.movement_trackers[key].load(self.bars[key], self.swings[key], self.conditions[key])
            t6 = time.perf_counter()
        except Exception as error:
            self.bars.pop(key, None)
            self.swings.pop(key, None)
            self.structures.pop(key, None)
            self.signals.pop(key, None)
            self.monitor.pop(key, None)
            self.patterns.pop(key, None)
            self.lifecycle.pop(key, None)
            self.trackers.pop(key, None)
            self.conditions.pop(key, None)
            self.condition_trackers.pop(key, None)
            self.movements.pop(key, None)
            self.movement_trackers.pop(key, None)
            self.last_closed.pop(key, None)
            row.update(error=str(error))
            return row
        self.last_closed[key] = int(self.bars[key]["time"].iloc[-1])
        self.write_cache(key)
        row.update(cached=False, bars=len(self.bars[key]), swings=len(self.swings[key]), structures=len(self.structures[key]),
                   fetch_ms=round((t1 - t0) * 1000, 1), swing_ms=round((t2 - t1) * 1000, 1),
                   structure_ms=round((t3 - t2) * 1000, 1), signals=len(self.signals[key]),
                   signal_ms=round((t4 - t3) * 1000, 1), patterns=len(self.patterns[key]),
                   pattern_ms=round((t5 - t4) * 1000, 1), lifecycle=len(self.lifecycle[key]),
                   lifecycle_ms=round((t6 - t5) * 1000, 1))
        return row

    def refresh_live(self):
        """Calculate the state on the forming bar of every loaded pair whose forming bar changed since the last time."""
        for key in list(self.bars):
            forming = fetch_forming_bar(*key)
            if forming is None:
                continue
            bar = forming.iloc[0]
            stamp = (int(bar["time"]), float(bar["high"]), float(bar["low"]), float(bar["close"]), int(bar["tick_volume"]))
            if self.live_stamp.get(key) == stamp:
                continue
            frame = pd.concat([self.bars[key].tail(LIVE_BARS), forming], ignore_index=True)
            frame.attrs["point"] = self.bars[key].attrs.get("point")
            try:
                self.live[key] = indicator_states(frame, self.definitions)
                self.live_stamp[key] = stamp
            except Exception as error:
                print(f"live state of {key} failed: {error}")

    def pre_trade_symbol_monitor(self):
        """[(key, states)] of every loaded pair: the live state, the closed-bar one until the first live calculation."""
        return [(key, self.live.get(key, self.monitor.get(key, []))) for key in self.bars]

    def keys_of(self, symbol):
        """The loaded pairs of a symbol: (symbol, tf_text), in the order they were loaded."""
        return [key for key in self.bars if key[0] == symbol]

    def time_of_bar(self, key, count):
        """The time of the bar `count` bars before the newest closed one of a pair (the first bar when it holds fewer)."""
        bars = self.bars[key]
        return int(bars["time"].iloc[max(0, len(bars) - count)])

    def swings_since(self, symbol, tf_text, from_time):
        swings = self.swings.get((symbol, tf_text))
        if swings is None:
            return None
        return swings[swings["time"] >= from_time]

    def structures_since(self, symbol, tf_text, from_time):
        structures = self.structures.get((symbol, tf_text))
        if structures is None:
            return None
        return structures[structures["break_time"] >= from_time]

    def signals_since(self, symbol, tf_text, from_time):
        signals = self.signals.get((symbol, tf_text))
        if signals is None:
            return None
        return signals[signals["time"] >= from_time]

    def patterns_since(self, symbol, tf_text, from_time):
        patterns = self.patterns.get((symbol, tf_text))
        if patterns is None:
            return None
        return patterns[patterns["time"] >= from_time]

    def conditions_since(self, symbol, tf_text, from_time):
        """The changes of Market State / Phase from a time on, and the one in force at that time (the last one before it)."""
        events = self.conditions.get((symbol, tf_text))
        if events is None:
            return None
        before = events[events["time"] < from_time].tail(1)
        return pd.concat([before, events[events["time"] >= from_time]], ignore_index=True)

    def movements_since(self, symbol, tf_text, from_time):
        """The legs from a time on, and the last one before it: a slow TF (H4) may have no leg in the window, its table row still shows the last."""
        events = self.movements.get((symbol, tf_text))
        if events is None:
            return None
        before = events[events["time"] < from_time].tail(1)
        return pd.concat([before, events[events["time"] >= from_time]], ignore_index=True)

    def lifecycle_since(self, symbol, tf_text, from_time):
        events = self.lifecycle.get((symbol, tf_text))
        if events is None:
            return None
        return events[events["time"] >= from_time]

    def extend_bars(self, key, latest):
        """(bars, cut): the closed bars up to latest and the time from which results are taken (0 = all, calculated from scratch)."""
        old = self.bars[key]
        fetched = fetch_closed_bars(key[0], key[1], TAIL_FETCH_BARS)
        if int(fetched["time"].iloc[0]) > self.last_closed[key] or len(old) < TAIL_BARS:
            return fetch_closed_bars(key[0], key[1], self.count), 0   # a hole between what is held and what was fetched
        bars = pd.concat([old[old["time"] < int(fetched["time"].iloc[0])], fetched], ignore_index=True)
        if self.count > 0:
            bars = bars.iloc[-self.count:].reset_index(drop=True)
        bars.attrs["point"] = old.attrs.get("point")
        return bars, int(bars["time"].iloc[len(bars) - TAIL_BARS + TAIL_KEEP_BARS])

    def update_pair(self, key):
        """Bring a pair up to the newest closed bar: (key, the new swings, structures, signals, patterns, lifecycle events, conditions),
        None when it has no new bar."""
        latest = fetch_last_closed_time(*key)
        if latest is None or latest <= self.last_closed[key]:
            return None
        old_last = self.last_closed[key]
        old_swings = self.swings[key]
        old_structures = self.structures[key]
        old_signals = self.signals[key]
        old_patterns = self.patterns[key]
        try:
            bars, cut = self.extend_bars(key, latest)
        except Exception:
            return None
        # Everything is calculated on the newest bars only (the whole history when there was a hole); the older results stay
        window = bars.iloc[max(0, len(bars) - TAIL_BARS):].reset_index(drop=True)
        window.attrs["point"] = bars.attrs.get("point")
        swings = find_swings(window, self.strength, self.use_wick)
        structures = self.structures_of(window, swings)
        signals, monitor = indicator_flips(window, self.definitions)
        patterns = find_patterns(window, symbol_point(key[0]))
        if cut:
            swings = merge_tail(old_swings, swings, "time", cut)
            structures = merge_tail(old_structures, structures, "break_time", cut)
            signals = merge_tail(old_signals, signals, "time", cut)
            patterns = merge_tail(old_patterns, patterns, "time", cut)
        conditions_tracker = self.condition_trackers.get(key)
        fresh = not (cut and conditions_tracker is not None)   # the Tracker goes through all the swings again: all the breaks are classified again
        if cut and conditions_tracker is not None:
            new_conditions = conditions_tracker.update(structures, old_last)
            conditions = pd.concat([self.conditions[key], new_conditions], ignore_index=True)
        else:
            conditions_tracker = self.condition_trackers[key] = condition.Tracker(self.condition_params)
            conditions = conditions_tracker.load(structures)
            new_conditions = conditions[conditions["time"] > old_last]
        structures = fill_strength(fill_phase(conditions_tracker.classify(structures, fresh), conditions), swings)   # BOS / CHoCH by the State, the Phase of the break and its strong level
        movement_tracker = self.movement_trackers.get(key)
        if cut and movement_tracker is not None:   # the swing that is open goes on, the legs that are closed stay
            new_movements = movement_tracker.update(window, swings, old_last, conditions)
            movements = pd.concat([self.movements[key], new_movements], ignore_index=True)
        else:
            movement_tracker = self.movement_trackers[key] = movement.Tracker()
            movements = movement_tracker.load(bars, swings, conditions)
            new_movements = movements[movements["time"] > old_last]
        # What lies after the previously newest bar is new: nothing the old results held can be there
        new_swings = swings[swings["confirmed_time"] > old_last]
        new_structures = structures[structures["break_time"] > old_last]
        new_signals = signals[signals["time"] > old_last]
        new_patterns = patterns[patterns["time"] > old_last]
        tracker = self.trackers.get(key)
        if cut and tracker is not None:   # the living lines go forward, the dead ones are not looked at again
            new_lifecycle = tracker.update(window, swings, old_last, structures)
            lifecycle = join_events([self.lifecycle[key], new_lifecycle])
        else:
            tracker = self.trackers[key] = LifecycleTracker(self.trendline_params, self.zone_params, self.momentum_params)
            lifecycle = tracker.load(bars, swings, structures)
            new_lifecycle = lifecycle[lifecycle["time"] > old_last]
        self.bars[key], self.swings[key], self.structures[key], self.signals[key] = bars, swings, structures, signals
        self.patterns[key] = patterns
        self.lifecycle[key] = lifecycle
        self.conditions[key] = conditions
        self.movements[key] = movements
        self.monitor[key] = monitor
        self.last_closed[key] = int(bars["time"].iloc[-1])
        self.dirty.add(key)   # what is on disk is older now
        return (key, new_swings, new_structures, new_signals, new_patterns, new_lifecycle, new_conditions, new_movements)

    def check_new_bars(self):
        found = []
        for key in list(self.bars):
            result = self.update_pair(key)
            if result is not None:
                found.append(result)
        return found

    def adopt(self, key, kept):
        """Take what the disk kept for a pair; the lifecycle and the market condition are calculated from it."""
        bars = kept["bars"]
        bars.attrs["point"] = kept["point"]
        self.bars[key], self.swings[key], self.signals[key] = bars, kept["swings"], kept["signals"]
        self.patterns[key], self.monitor[key] = kept["patterns"], kept["monitor"]
        self.trackers[key] = LifecycleTracker(self.trendline_params, self.zone_params, self.momentum_params)
        same = (kept.get("derived_key") == self.derived_key())
        structures = kept["structures"] if same else self.structures_of(bars, self.swings[key])   # the breaks depend on the min step
        self.lifecycle[key] = self.trackers[key].load(bars, self.swings[key], structures)
        if same:   # the market condition and the legs of the same rules: kept, tracker states too
            self.condition_trackers[key] = condition.Tracker(self.condition_params)
            self.condition_trackers[key].__dict__.update(kept["condition_state"])
            self.conditions[key] = kept["conditions"]
            self.movement_trackers[key] = movement.Tracker()
            self.movement_trackers[key].__dict__.update(kept["movement_state"])
            self.movements[key] = kept["movements"]
        else:
            self.condition_trackers[key] = condition.Tracker(self.condition_params)
            self.conditions[key] = self.condition_trackers[key].load(structures)
            self.movement_trackers[key] = movement.Tracker()
            self.movements[key] = self.movement_trackers[key].load(bars, self.swings[key], self.conditions[key])
        self.structures[key] = fill_strength(fill_phase(self.condition_trackers[key].classify(structures, not same), self.conditions[key]), self.swings[key])
        self.last_closed[key] = int(bars["time"].iloc[-1])
        self.saved_at[key] = time.monotonic()
        if not same:   # the file lacks the market condition and the legs of these settings: written again soon
            self.dirty.add(key)
            self.saved_at[key] = 0.0

    def structures_of(self, bars, swings):
        """The breaks of these swings (type BREAK), with the min step of the Market State."""
        settings = condition.settings(self.condition_params)
        return find_structures(bars, swings, float(settings["min_step_atr"]), int(settings["atr_period"]))

    def derived_key(self):
        """What the kept market condition and legs were made with: their settings and the version of their rules."""
        return repr((self.condition_params, condition.VERSION, movement.VERSION))

    def write_cache(self, key):
        try:
            cache.write(key, self.fingerprint, {"bars": self.bars[key], "swings": self.swings[key],
                                                "structures": self.structures[key].drop(columns=["phase", "strong_time", "strong_price"], errors="ignore"),
                                                "signals": self.signals[key], "patterns": self.patterns[key], "monitor": self.monitor[key],
                                                "point": self.bars[key].attrs.get("point"),
                                                "conditions": self.conditions[key], "movements": self.movements[key],
                                                "condition_state": {k: v for k, v in vars(self.condition_trackers[key]).items() if k != "p"},
                                                "movement_state": {k: v for k, v in vars(self.movement_trackers[key]).items() if k != "p"},
                                                "derived_key": self.derived_key()})
            self.saved_at[key] = time.monotonic()
            self.dirty.discard(key)
        except Exception as error:
            print(f"cache of {key[0]} {key[1]} not written: {error}")

    def save_dirty(self, period=CACHE_SAVE_PERIOD):
        """Write one pair whose file is older than `period` seconds and that has new bars: the key, None when there is none."""
        now = time.monotonic()
        for key in list(self.dirty):
            if key in self.bars and now - self.saved_at.get(key, 0.0) >= period:
                self.write_cache(key)
                return key
        return None

    def save_all(self):
        for key in list(self.dirty):
            if key in self.bars:
                self.write_cache(key)
