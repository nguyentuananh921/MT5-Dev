import time

import numpy as np
import pandas as pd

from data import fetch_closed_bars, fetch_forming_bar, fetch_last_closed_time, symbol_point
from indicators import compute, from_template
from patterns import find_patterns
from signals import directions, flips
from structure import find_structures
from swing import find_swings

DEFAULT_STRENGTH = 5
DEFAULT_USE_WICK = True
SIGNAL_COLUMNS = ["time", "label", "dir", "template"]
LIVE_BARS = 3000   # the live state is calculated on the newest closed bars and the forming one


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
        self.last_closed = {}   # (symbol, tf_text) -> time of the newest closed bar held

    def apply_config(self, pairs, strength=DEFAULT_STRENGTH, use_wick=DEFAULT_USE_WICK, count=0, on_pair=None, indicators=None):
        started = time.perf_counter()
        wanted = list(dict.fromkeys((str(s), str(tf)) for s, tf in pairs))
        rows = indicators or []
        converted = [from_template(row) for row in rows]
        definitions = [item + (position,) for position, item in enumerate(converted) if item is not None]
        skipped = [str(row.get("m_indicator_type")) for row, item in zip(rows, converted) if item is None]
        rebuild = (strength, use_wick, count, definitions) != (self.strength, self.use_wick, self.count, self.definitions)
        self.strength, self.use_wick, self.count, self.definitions = strength, use_wick, count, definitions
        self.live.clear()
        self.live_stamp.clear()
        for key in [k for k in self.bars if k not in wanted]:
            del self.bars[key]
            del self.swings[key]
            del self.structures[key]
            del self.signals[key]
            del self.monitor[key]
            del self.patterns[key]
            del self.last_closed[key]
        report = []
        for symbol, tf_text in wanted:
            row = self.load_pair(symbol, tf_text, rebuild)
            report.append(row)
            if on_pair:
                on_pair(row)
        return {"total_ms": round((time.perf_counter() - started) * 1000, 1), "pairs": report, "skipped": skipped}

    def load_pair(self, symbol, tf_text, rebuild):
        key = (symbol, tf_text)
        row = {"symbol": symbol, "tf": tf_text}
        if key in self.bars and not rebuild:
            row.update(cached=True, bars=len(self.bars[key]), swings=len(self.swings[key]),
                       structures=len(self.structures[key]), signals=len(self.signals[key]),
                       patterns=len(self.patterns[key]))
            return row
        try:
            t0 = time.perf_counter()
            self.bars[key] = fetch_closed_bars(symbol, tf_text, self.count)
            t1 = time.perf_counter()
            self.swings[key] = find_swings(self.bars[key], self.strength, self.use_wick)
            t2 = time.perf_counter()
            self.structures[key] = find_structures(self.bars[key], self.swings[key])
            t3 = time.perf_counter()
            self.signals[key], self.monitor[key] = indicator_flips(self.bars[key], self.definitions)
            t4 = time.perf_counter()
            self.patterns[key] = find_patterns(self.bars[key], symbol_point(symbol))
            t5 = time.perf_counter()
        except Exception as error:
            self.bars.pop(key, None)
            self.swings.pop(key, None)
            self.structures.pop(key, None)
            self.signals.pop(key, None)
            self.monitor.pop(key, None)
            self.patterns.pop(key, None)
            self.last_closed.pop(key, None)
            row.update(error=str(error))
            return row
        self.last_closed[key] = int(self.bars[key]["time"].iloc[-1])
        row.update(cached=False, bars=len(self.bars[key]), swings=len(self.swings[key]), structures=len(self.structures[key]),
                   fetch_ms=round((t1 - t0) * 1000, 1), swing_ms=round((t2 - t1) * 1000, 1),
                   structure_ms=round((t3 - t2) * 1000, 1), signals=len(self.signals[key]),
                   signal_ms=round((t4 - t3) * 1000, 1), patterns=len(self.patterns[key]),
                   pattern_ms=round((t5 - t4) * 1000, 1))
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

    def pre_trade_symbol_monitor(self, symbol):
        """[(key, states)] of every loaded pair of the symbol: the live state, the closed-bar one until the first live calculation."""
        return [(key, self.live.get(key, self.monitor.get(key, []))) for key in self.bars if key[0] == symbol]

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

    def check_new_bars(self):
        found = []
        for key in list(self.bars):
            latest = fetch_last_closed_time(*key)
            if latest is None or latest <= self.last_closed[key]:
                continue
            old_last = self.last_closed[key]
            old_swings = self.swings[key]
            old_structures = self.structures[key]
            old_signals = self.signals[key]
            old_patterns = self.patterns[key]
            try:
                bars = fetch_closed_bars(key[0], key[1], self.count)
            except Exception:
                continue
            swings = find_swings(bars, self.strength, self.use_wick)
            structures = find_structures(bars, swings)
            new_swings = swings[~pd.MultiIndex.from_frame(swings[["type", "time"]]).isin(
                pd.MultiIndex.from_frame(old_swings[["type", "time"]]))]
            id_columns = ["type", "dir", "break_time", "swing_time"]
            new_structures = structures[~pd.MultiIndex.from_frame(structures[id_columns]).isin(
                pd.MultiIndex.from_frame(old_structures[id_columns]))]
            signals, monitor = indicator_flips(bars, self.definitions)
            new_signals = signals[~pd.MultiIndex.from_frame(signals[["label", "time"]]).isin(
                pd.MultiIndex.from_frame(old_signals[["label", "time"]]))]
            patterns = find_patterns(bars, symbol_point(key[0]))
            new_patterns = patterns[~pd.MultiIndex.from_frame(patterns[["label", "time"]]).isin(
                pd.MultiIndex.from_frame(old_patterns[["label", "time"]]))]
            # The window of bars slides by one bar, so the first bars change (indicator warm-up, swing lookback): only what lies
            # after the previously newest bar is new
            new_swings = new_swings[new_swings["confirmed_time"] > old_last]
            new_structures = new_structures[new_structures["break_time"] > old_last]
            new_signals = new_signals[new_signals["time"] > old_last]
            new_patterns = new_patterns[new_patterns["time"] > old_last]
            self.bars[key], self.swings[key], self.structures[key], self.signals[key] = bars, swings, structures, signals
            self.patterns[key] = patterns
            self.monitor[key] = monitor
            self.last_closed[key] = int(bars["time"].iloc[-1])
            found.append((key, new_swings, new_structures, new_signals, new_patterns))
        return found
