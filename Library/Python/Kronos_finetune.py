"""Kronos_finetune.py: finetune Kronos (tokenizer, then predictor) on the bars of MT5 (data.py), with the finetune_csv pipeline of Library\\Kronos as it is
(train_tokenizer, train_model, CustomKlineDataset): only the CSV read of its dataset is replaced by the bars of the terminal. Kronos is not edited.
The models go to MQL5\\Files\\<program>\\Kronos\\<symbol>_<tf> (next to the Debug folder of the EA); Kronos_forecast.py does not use them yet.
Trial: python Kronos_finetune.py --database "EA V5 SQLLite\\Database\\EA V5 SQLLite_Common.sqlite3" --symbol XAUUSD --tf M15 --bars 3000 --epochs 1"""
import argparse
import os
import sys
import time
from pathlib import Path
from types import SimpleNamespace

import pandas as pd
import torch

import data
import libdb
import Kronos_forecast   # first: its load_kronos takes the package `model` of Kronos in and out again, the names of the models are its own

KRONOS_FOLDER = Path(__file__).resolve().parent.parent / "Kronos"
#--- The pipeline imports `model` (the package of Kronos, not our model.py, which this script never imports) and its own modules by name
sys.path[:0] = [str(KRONOS_FOLDER), str(KRONOS_FOLDER / "finetune_csv")]
import finetune_base_model   # noqa: E402
import finetune_tokenizer    # noqa: E402
from model import Kronos, KronosPredictor, KronosTokenizer   # noqa: E402

_bars = None   # the closed bars of the pair, read once before the datasets are made


class MT5KlineDataset(finetune_base_model.CustomKlineDataset):
    """CustomKlineDataset of finetune_csv with the bars of MT5 instead of pd.read_csv; its split, windows and normalisation are kept."""
    def _load_and_preprocess_data(self):
        df = _bars
        self.timestamps = pd.to_datetime(df["time"], unit="s").reset_index(drop=True)
        frame = pd.DataFrame({"open": df["open"], "high": df["high"], "low": df["low"], "close": df["close"],
                              "volume": df["tick_volume"].astype(float)}).reset_index(drop=True)
        frame["amount"] = frame["volume"] * frame[["open", "high", "low", "close"]].mean(axis=1)   # MT5 has none: as KronosPredictor.predict fills it
        frame["minute"] = self.timestamps.dt.minute
        frame["hour"] = self.timestamps.dt.hour
        frame["weekday"] = self.timestamps.dt.weekday
        frame["day"] = self.timestamps.dt.day
        frame["month"] = self.timestamps.dt.month
        self.data = frame[self.feature_list + self.time_feature_list]
        print(f"MT5 bars: {self.timestamps.min()} to {self.timestamps.max()}, {len(frame)} bars")


#--- Both trainings make their datasets by this name
finetune_base_model.CustomKlineDataset = MT5KlineDataset
finetune_tokenizer.CustomKlineDataset = MT5KlineDataset


def evaluate(symbol, tf_text, windows, save):
    """How right Kronos is, the model of Hugging Face against the finetuned one, on bars already known: for each window, MAX_CONTEXT closed bars in,
    FORECAST_BARS foretold, set against the bars that came. Naive: the last close held (no forecast). Direction: the side of the last bar foretold is the side it went."""
    targets = 600   # the newest bars the forecasts are checked on: the validation part of a trial on 3000 bars, and what came after it
    bars = data.fetch_closed_bars(symbol, tf_text, Kronos_forecast.MAX_CONTEXT + targets).reset_index(drop=True)
    n = Kronos_forecast.FORECAST_BARS
    first, last = Kronos_forecast.MAX_CONTEXT, len(bars) - n
    starts = sorted({first + (last - first) * k // max(1, windows - 1) for k in range(windows)})
    models = {"Hugging Face": Kronos_forecast.predictor(),
              "finetuned": KronosPredictor(Kronos.from_pretrained(str(save / "basemodel" / "best_model")),
                                           KronosTokenizer.from_pretrained(str(save / "tokenizer" / "best_model")), max_context=Kronos_forecast.MAX_CONTEXT)}
    errors = {name: [] for name in models}
    hits = {name: 0 for name in models}
    naive, moves = [], []
    started = time.perf_counter()
    for k, start in enumerate(starts):
        history = bars.iloc[start - Kronos_forecast.MAX_CONTEXT:start].reset_index(drop=True)
        actual = bars["close"].iloc[start:start + n].to_numpy()
        last_close = float(history["close"].iloc[-1])
        naive.append(float(abs(actual - last_close).mean()))
        moves.append(abs(float(actual[-1]) - last_close))
        for name, model in models.items():
            torch.manual_seed(k)   # the same draw for both models on a window
            foretold = Kronos_forecast.forecast_of(history, tf_text, n, model)["close"].to_numpy()
            errors[name].append(float(abs(foretold - actual).mean()))
            hits[name] += int((foretold[-1] - last_close) * (actual[-1] - last_close) > 0)
        print(f"window {k + 1} of {len(starts)} ({pd.to_datetime(int(bars['time'].iloc[start]), unit='s')}): "
              + ", ".join(f"{name} {errors[name][-1]:.2f}" for name in models) + f", naive {naive[-1]:.2f}", flush=True)
    print(f"Kronos_finetune.py --evaluate: {symbol} {tf_text}, {len(starts)} windows of {n} bars on the newest {targets} bars, {time.perf_counter() - started:.0f} s", flush=True)
    print(f"  mean move of the close over {n} bars: {sum(moves) / len(moves):.2f}", flush=True)
    print(f"  naive (last close held): mean error {sum(naive) / len(naive):.2f}", flush=True)
    for name in models:
        print(f"  {name}: mean error {sum(errors[name]) / len(errors[name]):.2f}, direction right {hits[name]} of {len(starts)} ({100 * hits[name] / len(starts):.0f}%)", flush=True)


def main():
    global _bars
    parser = argparse.ArgumentParser()
    parser.add_argument("--terminal", default=None, help="path to terminal64.exe when several terminals are installed")
    parser.add_argument("--database", default=None, help="the file the accounts share, under MQL5\\Files (as main.py)")
    parser.add_argument("--symbol", default="XAUUSD")
    parser.add_argument("--tf", default="M15", help="a name of the table timeframes")
    parser.add_argument("--bars", type=int, default=3000, help="closed bars of the pair to learn from (the newest)")
    parser.add_argument("--epochs", type=int, default=1, help="epochs of the tokenizer and of the predictor")
    parser.add_argument("--batch", type=int, default=8)
    parser.add_argument("--val", type=float, default=0.2, help="part of the bars kept for validation (it needs at least lookback + predict + 1 bars)")
    parser.add_argument("--threads", type=int, default=max(1, (os.cpu_count() or 2) // 2), help="CPU threads of torch: the rest stays for the EA and its workers")
    parser.add_argument("--evaluate", action="store_true", help="no training: how right the model of Hugging Face and the finetuned one are on known bars")
    parser.add_argument("--windows", type=int, default=20, help="--evaluate: the forecasts checked")
    args = parser.parse_args()
    if args.database:
        os.environ["LIBDB_FILE"] = args.database
    torch.set_num_threads(args.threads)
    data.connect(args.terminal)
    try:
        save = libdb.database_path().parent.parent / "Kronos" / f"{args.symbol}_{args.tf}"
        if args.evaluate:
            evaluate(args.symbol, args.tf, args.windows, save)
            return
        _bars = data.fetch_closed_bars(args.symbol, args.tf, args.bars)
        config = SimpleNamespace(
            data_path="MT5", lookback_window=Kronos_forecast.MAX_CONTEXT, predict_window=Kronos_forecast.FORECAST_BARS, clip=5.0, seed=42,
            train_ratio=1.0 - args.val, val_ratio=args.val, test_ratio=0.0, batch_size=args.batch, num_workers=0, log_interval=10,
            tokenizer_epochs=args.epochs, basemodel_epochs=args.epochs, tokenizer_learning_rate=2e-4, predictor_learning_rate=4e-5,
            adam_beta1=0.9, adam_beta2=0.95, adam_weight_decay=0.1, accumulation_steps=1, use_comet=False)   # the defaults of CustomFinetuneConfig
        device = torch.device("cpu")
        started = time.perf_counter()

        logger = finetune_tokenizer.setup_logging(f"{args.symbol}_{args.tf}", str(save / "logs"))
        finetune_tokenizer.set_seed(config.seed)
        tokenizer = KronosTokenizer.from_pretrained(Kronos_forecast.TOKENIZER).to(device)
        loss = finetune_tokenizer.train_tokenizer(tokenizer, device, config, str(save / "tokenizer"), logger)
        tokenizer_done = time.perf_counter()
        print(f"Kronos_finetune.py: tokenizer of {args.symbol} {args.tf} done in {(tokenizer_done - started) / 60:.1f} min, validation loss {loss:.4f}", flush=True)

        logger = finetune_base_model.setup_logging(f"{args.symbol}_{args.tf}", str(save / "logs"))
        tokenizer = KronosTokenizer.from_pretrained(str(save / "tokenizer" / "best_model")).to(device)
        model = Kronos.from_pretrained(Kronos_forecast.MODEL).to(device)
        loss = finetune_base_model.train_model(model, tokenizer, device, config, str(save / "basemodel"), logger)
        print(f"Kronos_finetune.py: predictor of {args.symbol} {args.tf} done in {(time.perf_counter() - tokenizer_done) / 60:.1f} min, validation loss {loss:.4f}; "
              f"{args.bars} bars, {args.epochs} epoch(s), {args.threads} threads; models in {save}", flush=True)
    finally:
        data.disconnect()


if __name__ == "__main__":
    main()
