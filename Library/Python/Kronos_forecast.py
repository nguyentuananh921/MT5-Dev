"""Kronos_forecast.py: the next bars of a pair, foretold by Kronos (Library\\Kronos, a clone of shiyu-coder/Kronos, never edited).
run(): every pair in the order of Current, the chart first (server.py runs it). Not in the database yet: the table is made by the EA later. Run alone to try one pair:
python Kronos_forecast.py --database "EA V5 SQLLite\\Database\\EA V5 SQLLite_Common.sqlite3" --symbol XAUUSD --tf M15 --bars 24"""
import argparse
import os
import sqlite3
import sys
import threading
import time
from pathlib import Path

import pandas as pd

import data
import libdb

KRONOS_FOLDER = Path(__file__).resolve().parent.parent / "Kronos"


def load_kronos():
    """Its package is named `model` (kronos.py imports `model.module`), like our model.py: taken in under that name, then ours is put back."""
    ours = sys.modules.pop("model", None)
    sys.path.insert(0, str(KRONOS_FOLDER))
    try:
        import model as kronos_model
        return kronos_model.Kronos, kronos_model.KronosPredictor, kronos_model.KronosTokenizer
    finally:
        sys.path.remove(str(KRONOS_FOLDER))
        for name in [n for n in sys.modules if n == "model" or n.startswith("model.")]:
            del sys.modules[name]
        if ours is not None:
            sys.modules["model"] = ours


Kronos, KronosPredictor, KronosTokenizer = load_kronos()

MODEL = "NeoQuasar/Kronos-small"
TOKENIZER = "NeoQuasar/Kronos-Tokenizer-base"
MAX_CONTEXT = 512   # the most bars Kronos-small reads
FORECAST_BARS = 24  # the bars foretold after the newest closed one
IDLE_SECONDS = 1.0  # run(): every pair is foretold: look again this much later
_predictor = None   # loaded once: a load takes seconds
_predictor_lock = threading.Lock()   # server.py loads it at start while a forecast may already ask for it


def predictor():
    global _predictor
    with _predictor_lock:
        if _predictor is None:
            _predictor = KronosPredictor(Kronos.from_pretrained(MODEL), KronosTokenizer.from_pretrained(TOKENIZER), max_context=MAX_CONTEXT)
    return _predictor


def forecast(symbol, tf_text, bars, lookback=MAX_CONTEXT):
    """The `bars` bars after the newest closed one: DataFrame time (s), open, high, low, close, volume, oldest first."""
    return forecast_of(data.fetch_closed_bars(symbol, tf_text, lookback), tf_text, bars)


def forecast_of(df, tf_text, bars, model=None):
    """As forecast, from closed bars already read (data.fetch_closed_bars): server.py reads them under its lock of the terminal, Kronos runs without it.
    The times go on one TF step at a time (a weekend is not skipped). `model`: another KronosPredictor (Kronos_finetune.py --evaluate), else the one of MODEL."""
    x_df = pd.DataFrame({"open": df["open"], "high": df["high"], "low": df["low"], "close": df["close"], "volume": df["tick_volume"].astype(float)})
    x_time = pd.to_datetime(df["time"], unit="s")
    step = data.tf_seconds(tf_text)
    last = int(df["time"].iloc[-1])
    y_time = pd.Series(pd.to_datetime([last + step * (i + 1) for i in range(bars)], unit="s"))
    pred = (model or predictor()).predict(df=x_df, x_timestamp=x_time, y_timestamp=y_time, pred_len=bars, T=1.0, top_p=0.9, sample_count=1, verbose=False)
    pred = pred.reset_index(drop=True)
    pred.insert(0, "time", [last + step * (i + 1) for i in range(bars)])
    return pred[["time", "open", "high", "low", "close", "volume"]]


def run(db, terminal, kept_from, store, bars=FORECAST_BARS):
    """Forever: every pair, in the order of Current (db.pairs_in_order: the chart, Setting_SymbolTF, every other), the first one whose newest closed bar is newer than
    its forecast is foretold, then the list is gone through again from the top: a new bar of the chart pair always goes first.
    terminal: the lock of the terminal (one call of the MetaTrader5 package at a time); kept_from(symbol, tf_text): the closed bar (s) of the kept forecast, or None;
    store(symbol, tf_text, from_time, pred): where a forecast goes (server.py: RAM, later the database)."""
    failed = {}   # (symbol, tf_text) -> the closed bar a forecast failed at: not tried again before the next bar
    while True:
        try:
            chart = libdb.chart_pair()
        except (KeyError, sqlite3.OperationalError):
            chart = None   # the EA has not written the pair of the chart yet
        found = None
        pairs = db.pairs_in_order(chart, db.library_pairs())
        for place, (symbol, tf_enum, tf_text) in enumerate(pairs, 1):
            with terminal:
                last = data.fetch_last_closed_time(symbol, tf_text)
            if last is not None and kept_from(symbol, tf_text) != last and failed.get((symbol, tf_text)) != last:
                found = (symbol, tf_text, last, place)
                break
        if found is None:
            time.sleep(IDLE_SECONDS)
            continue
        symbol, tf_text, last, place = found
        try:
            started = time.perf_counter()
            with terminal:
                df = data.fetch_closed_bars(symbol, tf_text, MAX_CONTEXT)
            store(symbol, tf_text, int(df["time"].iloc[-1]), forecast_of(df, tf_text, bars))
            print(f"Kronos_forecast.py: {symbol} {tf_text} foretold ({bars} bars) in {time.perf_counter() - started:.1f} s, pair {place} of {len(pairs)} in the order of Current", flush=True)
        except Exception as error:   # one pair that fails does not stop the others
            print(f"Kronos_forecast.py: forecast of {symbol} {tf_text} failed: {error!r}", flush=True)
            failed[(symbol, tf_text)] = last


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--terminal", default=None, help="path to terminal64.exe when several terminals are installed")
    parser.add_argument("--database", default=None, help="the file the accounts share, under MQL5\\Files (as main.py): its table timeframes")
    parser.add_argument("--symbol", default="XAUUSD")
    parser.add_argument("--tf", default="M15", help="a name of the table timeframes")
    parser.add_argument("--bars", type=int, default=24, help="how many bars to foretell")
    args = parser.parse_args()
    if args.database:
        os.environ["LIBDB_FILE"] = args.database
    data.connect(args.terminal)
    try:
        started = time.perf_counter()
        predictor()
        loaded = time.perf_counter()
        pred = forecast(args.symbol, args.tf, args.bars)
        done = time.perf_counter()
        print(f"Kronos_forecast.py: {args.bars} bars of {args.symbol} {args.tf} after {MAX_CONTEXT} closed bars, model {MODEL} on {predictor().device}: "
              f"load {loaded - started:.1f} s, forecast {done - loaded:.1f} s")
        pred["time"] = pd.to_datetime(pred["time"], unit="s")
        print(pred.to_string(index=False))
    finally:
        data.disconnect()


if __name__ == "__main__":
    main()
