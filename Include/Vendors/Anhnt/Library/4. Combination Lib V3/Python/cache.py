import hashlib
import os
import pickle
import zlib
from pathlib import Path

import numpy as np
import pandas as pd

# What Python calculated for a pair is kept on disk, so that the next start reads it instead of calculating it again (about 1.5 s a pair
# against about 0.1 s). A file is only used when it was made with the same settings and the same calculation code: the fingerprint says it.
# Only the slow part is kept (swings, structures, indicator signals, candle patterns); the lifecycle and the market condition are
# quick to calculate from them and depend on settings that are not in the fingerprint, so they are calculated again. The bars are NOT
# kept: they are the terminal's own, read from it again (about the time of reading them from the disk); the file only remembers the
# last bar it was made on. The numbers are kept in the smallest integer type and the file is compressed.

FORMAT = 2   # raise it when the shape of what is kept changes (or indicator_flips of model.py changes)
CALC_FILES = ("swing.py", "structure.py", "indicators.py", "signals.py", "patterns.py")
SOURCE = Path(__file__).resolve().parent
ENABLED = os.environ.get("MT5_PYTHON_CACHE", "").lower() != "off"   # the tests switch it off


def cache_dir():
    """MQL5\\Files\\EA LibV3\\Python Cache (where the EA keeps its own files); next to the code when this is not under an MQL5 folder."""
    if os.environ.get("MT5_PYTHON_CACHE"):
        return Path(os.environ["MT5_PYTHON_CACHE"])
    here = Path(__file__).absolute()
    for parent in here.parents:
        if parent.name.upper() == "MQL5":
            return parent / "Files" / "EA LibV3" / "Python Cache"
    return SOURCE / "cache"


def code_hash():
    digest = hashlib.sha1(str(FORMAT).encode())
    for name in CALC_FILES:
        digest.update((SOURCE / name).read_bytes())
    return digest.hexdigest()


def fingerprint(strength, use_wick, count, definitions):
    """What the kept results depend on: the swing settings, the indicators and their parameters, how many bars, the calculation code."""
    return hashlib.sha1(repr((strength, use_wick, count, definitions, code_hash())).encode()).hexdigest()


def file_of(key, variant=""):
    """A variant (a kind of Swing the EA asked for) has its own file; the one without a variant keeps the name it always had."""
    return cache_dir() / (f"{key[0]}_{key[1]}.pkz" if not variant else f"{key[0]}_{key[1]}__{variant}.pkz")


def narrow(series):
    """An integer column in the smallest integer type that holds all of it (the same numbers)."""
    if series.empty:
        return series
    low, high = int(series.min()), int(series.max())
    for kind in (np.uint8, np.int8, np.uint16, np.int16, np.uint32, np.int32):
        limits = np.iinfo(kind)
        if limits.min <= low and high <= limits.max:
            return series.astype(kind)
    return series


def pack(frame):
    """A frame with its text columns as categories (a label repeats thousands of times) and its integers narrow: smaller on disk, the types are kept."""
    types = frame.dtypes.to_dict()
    light = frame.copy()
    for name, kind in types.items():
        if kind == object or str(kind).startswith("string"):
            light[name] = light[name].astype("category")
        elif isinstance(kind, np.dtype) and kind.kind in "iu":
            light[name] = narrow(light[name])
    return light, types


def unpack(light, types):
    frame = light.copy()
    for name, kind in types.items():
        if str(frame[name].dtype) == "category" or frame[name].dtype != kind:
            frame[name] = frame[name].astype(kind)
    return frame


def write(key, fingerprint_text, parts, variant=""):
    """parts = {name: DataFrame, ...} and anything else picklable under other names; written aside and put in place whole."""
    if not ENABLED:
        return
    folder = cache_dir()
    folder.mkdir(parents=True, exist_ok=True)
    packed = {}
    for name, value in parts.items():
        packed[name] = ("frame",) + pack(value) + (dict(value.attrs),) if isinstance(value, pd.DataFrame) else ("value", value)
    target = file_of(key, variant)
    temporary = target.with_suffix(".tmp")
    raw = pickle.dumps({"fingerprint": fingerprint_text, "parts": packed}, protocol=pickle.HIGHEST_PROTOCOL)
    with open(temporary, "wb") as handle:
        handle.write(zlib.compress(raw, 1))   # level 1: a third of the time of the default for almost the same size
    os.replace(temporary, target)


def read(key, fingerprint_text, variant=""):
    """The parts kept for a pair, None when there is no file, it is of other settings or other code, or it cannot be read."""
    target = file_of(key, variant)
    if not ENABLED or not target.exists():
        return None
    try:
        with open(target, "rb") as handle:
            data = pickle.loads(zlib.decompress(handle.read()))
        if data.get("fingerprint") != fingerprint_text:
            return None
        parts = {}
        for name, item in data["parts"].items():
            if item[0] == "frame":
                frame = unpack(item[1], item[2])
                frame.attrs.update(item[3])
                parts[name] = frame
            else:
                parts[name] = item[1]
        return parts
    except Exception as error:
        print(f"cache of {key[0]} {key[1]} not used: {error}")
        return None
