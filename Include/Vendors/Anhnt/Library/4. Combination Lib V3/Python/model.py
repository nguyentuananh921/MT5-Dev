import time

import pandas as pd

from data import fetch_closed_bars, fetch_last_closed_time
from structure import find_structures
from swing import find_swings

DEFAULT_STRENGTH = 5
DEFAULT_USE_WICK = True


class Model:
    def __init__(self):
        self.strength = DEFAULT_STRENGTH
        self.use_wick = DEFAULT_USE_WICK
        self.count = 0
        self.bars = {}      # (symbol, tf_text) -> closed bars
        self.swings = {}    # (symbol, tf_text) -> swings of those bars
        self.structures = {}    # (symbol, tf_text) -> BOS/CHoCH of those bars
        self.last_closed = {}   # (symbol, tf_text) -> time of the newest closed bar held

    def apply_config(self, pairs, strength=DEFAULT_STRENGTH, use_wick=DEFAULT_USE_WICK, count=0, on_pair=None):
        started = time.perf_counter()
        wanted = list(dict.fromkeys((str(s), str(tf)) for s, tf in pairs))
        rebuild = (strength, use_wick, count) != (self.strength, self.use_wick, self.count)
        self.strength, self.use_wick, self.count = strength, use_wick, count
        for key in [k for k in self.bars if k not in wanted]:
            del self.bars[key]
            del self.swings[key]
            del self.structures[key]
            del self.last_closed[key]
        report = []
        for symbol, tf_text in wanted:
            row = self.load_pair(symbol, tf_text, rebuild)
            report.append(row)
            if on_pair:
                on_pair(row)
        return {"total_ms": round((time.perf_counter() - started) * 1000, 1), "pairs": report}

    def load_pair(self, symbol, tf_text, rebuild):
        key = (symbol, tf_text)
        row = {"symbol": symbol, "tf": tf_text}
        if key in self.bars and not rebuild:
            row.update(cached=True, bars=len(self.bars[key]), swings=len(self.swings[key]),
                       structures=len(self.structures[key]))
            return row
        try:
            t0 = time.perf_counter()
            self.bars[key] = fetch_closed_bars(symbol, tf_text, self.count)
            t1 = time.perf_counter()
            self.swings[key] = find_swings(self.bars[key], self.strength, self.use_wick)
            t2 = time.perf_counter()
            self.structures[key] = find_structures(self.bars[key], self.swings[key])
            t3 = time.perf_counter()
        except Exception as error:
            self.bars.pop(key, None)
            self.swings.pop(key, None)
            self.structures.pop(key, None)
            self.last_closed.pop(key, None)
            row.update(error=str(error))
            return row
        self.last_closed[key] = int(self.bars[key]["time"].iloc[-1])
        row.update(cached=False, bars=len(self.bars[key]), swings=len(self.swings[key]), structures=len(self.structures[key]),
                   fetch_ms=round((t1 - t0) * 1000, 1), swing_ms=round((t2 - t1) * 1000, 1),
                   structure_ms=round((t3 - t2) * 1000, 1))
        return row

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

    def check_new_bars(self):
        found = []
        for key in list(self.bars):
            latest = fetch_last_closed_time(*key)
            if latest is None or latest <= self.last_closed[key]:
                continue
            old_swings = self.swings[key]
            old_structures = self.structures[key]
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
            self.bars[key], self.swings[key], self.structures[key] = bars, swings, structures
            self.last_closed[key] = int(bars["time"].iloc[-1])
            found.append((key, new_swings, new_structures))
        return found
