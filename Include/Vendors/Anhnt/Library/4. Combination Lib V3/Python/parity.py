"""Compare MT5 indicator buffers (exported by the 'Indicator Parity' script) with the Python calculation.

    python parity.py            # every parity_*.csv in MQL5\\Files\\Indicator Parity
    python parity.py --tail 500 # compare the last 500 exported bars only

It also writes signals_<IND>.csv next to the exports: the same columns for both sides and, as the last two columns,
the signal (flip) from the MT5 buffers and the signal from the Python buffers.
"""
import argparse
import glob
import os

import numpy as np
import pandas as pd
import MetaTrader5 as mt5

from data import connect, disconnect, fetch_closed_bars
from indicators import compute
from signals import directions, flips

FOLDER = "Indicator Parity"
NAMES = {1: "BUY", -1: "SELL", 0: ""}


def read_export(path):
    with open(path, encoding="utf-8") as handle:
        header = handle.readline().strip().lstrip("#")
    params = dict(item.split("=", 1) for item in header.split(";"))
    table = pd.read_csv(path, skiprows=1)
    return params, table


def report(name, label, mt5_values, py_values, price_scale):
    mask = ~(np.isnan(mt5_values) | np.isnan(py_values))
    if not mask.any():
        print(f"    {label:<34} no comparable bar")
        return
    diff = np.abs(mt5_values[mask] - py_values[mask])
    worst = int(np.argmax(diff))
    print(f"    {label:<34} bars {mask.sum():>5}  max {diff.max():.10g}  mean {diff.mean():.10g}  "
          f"max/price {diff.max() / price_scale:.2e}  (MT5 {mt5_values[mask][worst]:.8g} / Python {py_values[mask][worst]:.8g})")


def export_signals(folder, name, params, table, bars, rows, buffers):
    """Two signal columns on the same bars: the rule applied to the MT5 buffers, and the same rule applied to the Python buffers."""
    mt5_buffers = [table[f"b{i}"].to_numpy(dtype=float) for i in range(len(buffers))]
    mt5_bars = bars.iloc[rows].reset_index(drop=True)
    mt5_signal = flips(directions(name, mt5_buffers, mt5_bars, params))
    py_signal = flips(directions(name, [np.asarray(b, dtype=float) for b in buffers], bars, params))[rows]
    mt5_signal[:2] = py_signal[:2] = 0   # the MT5 side has no bar before the first exported one, so its first two bars cannot be judged
    out = pd.DataFrame({"time": mt5_bars["time"], "time_text": pd.to_datetime(mt5_bars["time"], unit="s").dt.strftime("%Y-%m-%d %H:%M"),
                        "open": mt5_bars["open"], "high": mt5_bars["high"], "low": mt5_bars["low"], "close": mt5_bars["close"]})
    for index in range(len(buffers)):
        out[f"mt5_b{index}"] = mt5_buffers[index]
    for index in range(len(buffers)):
        out[f"py_b{index}"] = np.asarray(buffers[index], dtype=float)[rows]
    out["signal_MT5"] = [NAMES[int(v)] for v in mt5_signal]
    out["signal_TALib"] = [NAMES[int(v)] for v in py_signal]
    path = os.path.join(folder, f"signals_{params.get('tag', name)}.csv")
    out.to_csv(path, index=False)
    different = int((mt5_signal != py_signal).sum())
    print(f"    signals: MT5 {int((mt5_signal != 0).sum())}, Python {int((py_signal != 0).sum())}, different bars {different}  -> {path}")
    for position in np.where(mt5_signal != py_signal)[0][:5]:
        print(f"      {out['time_text'].iloc[position]}  MT5 '{out['signal_MT5'].iloc[position]}'  Python '{out['signal_TALib'].iloc[position]}'")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tail", type=int, default=1000, help="compare only the newest N exported bars")
    parser.add_argument("--terminal", default=None)
    args = parser.parse_args()
    connect(args.terminal)
    try:
        folder = os.path.join(mt5.terminal_info().data_path, "MQL5", "Files", FOLDER)
        files = sorted(glob.glob(os.path.join(folder, "parity_*.csv")))
        if not files:
            print(f"no parity_*.csv in {folder} - run the 'Indicator Parity' script on a chart first")
            return
        bars_cache = {}
        for path in files:
            params, table = read_export(path)
            name, symbol, tf = params["ind"], params["symbol"], params["tf"]
            if (symbol, tf) not in bars_cache:
                bars_cache[(symbol, tf)] = fetch_closed_bars(symbol, tf)
            bars = bars_cache[(symbol, tf)]
            buffers, alternatives = compute(name, bars, params)
            by_time = pd.Series(np.arange(len(bars)), index=bars["time"].to_numpy())
            rows = by_time.reindex(table["time"].to_numpy()).to_numpy()
            if np.isnan(rows).any():
                print(f"{name}: {int(np.isnan(rows).sum())} exported bars are missing in the Python bars")
                continue
            rows = rows.astype(int)
            price_scale = float(np.nanmean(bars["close"].to_numpy(dtype=float)[rows[-args.tail:]]))
            print(f"{name} {symbol} {tf}  " + "  ".join(f"{k}={v}" for k, v in params.items() if k not in ("ind", "symbol", "tf")))
            for index in range(len(buffers)):
                mt5_values = table[f"b{index}"].to_numpy(dtype=float)[-args.tail:]
                report(name, f"buffer {index}", mt5_values, np.asarray(buffers[index], dtype=float)[rows[-args.tail:]], price_scale)
                for label, values in alternatives.get(index, []):
                    report(name, f"  alt: {label}", mt5_values, np.asarray(values, dtype=float)[rows[-args.tail:]], price_scale)
            export_signals(folder, name, params, table, bars, rows, buffers)
    finally:
        disconnect()


if __name__ == "__main__":
    main()
