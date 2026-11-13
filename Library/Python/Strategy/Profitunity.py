"""Profitunity (Trading Chaos, Bill Williams) as its source EA: Allan Munene Mutiiria\\Automating Trading Strategies\\01. 16365 PROFITUNITY_tTRADING_CHAOS_BY_BILL_WILLIAMSd.mq5,
OnTick at a new bar. The EA (CSetting_Profitunity) writes the strategy: its slots and the params of their indicators (Setting_StrategyIndicator, libdb.strategies()).

calculate(): the entries and exits, decided on the bar that just closed (shift 1 of the source EA, the one before it shift 2):
  lastFractal_direction  the newest fractal, known 2 bars after its middle (indicators.fractals); a down one after an up one of the same bar wins (FRACTAL_DOWN is set last)
  isBreakdown_jaws_buy   jaws[1] < close(1) && jaws[2] > close(2)          (sell: the other way)
  ac_color               AC_COLOR_UP: AC(1) >= AC(2), as Accelerator.mq5    (AC_COLOR_DOWN: below)
  ao                     ao[1] > 0 && ao[2] < 0                              (sell: the other way)
  Buy: FRACTAL_DOWN, breakdown buy, AC up, AO crossed up; else Sell: FRACTAL_UP, breakdown sell, AC down, AO crossed down
  Then AO crossed down closes every Buy, else AO crossed up closes every Sell
"""
import numpy as np

import indicators

NAME = "Profitunity"   # Setting_Strategy.name (CSetting_Profitunity)
SLOTS = ("Fractals", "Alligator", "AO", "AC")   # Setting_StrategyIndicator.slot of its indicators
CONTEXT = 500   # the bars before a bar it needs: the indicators warm up (AO 34, Alligator 13 + 8) and a Buy opened before the bars judged can still close in them


def _buffers(strategy, slot, bars):
    """The buffers of a slot of the strategy, with its params (the strategy's, else the standard of the table indicators)."""
    row = next(s for s in strategy["slots"] if s["slot"] == slot)
    name = row["type_name"]
    _, params = indicators.from_template(name, len(indicators.PARAM_KEYS[name]), row["params"] or "")
    buffers, _ = indicators.compute(name, bars, params)
    return [np.asarray(b, dtype=float) for b in buffers]


def calculate(strategy, bars, since=0, until=None):
    """The entries and exits on the bars, a list of (bar time, "entry" or "exit", "BUY" or "SELL": the side opened or closed), of the bars with
    since < time (< until when it is given). The bars are closed: the newest one is shift 1 of the source EA."""
    upper, lower = _buffers(strategy, "Fractals", bars)
    jaw = _buffers(strategy, "Alligator", bars)[0]
    ao = _buffers(strategy, "AO", bars)[0]
    ac = _buffers(strategy, "AC", bars)[0]
    close = bars["close"].to_numpy(dtype=float)
    times = bars["time"].to_numpy()
    last_fractal = None   # FRACTAL_NEUTRAL
    buys = sells = 0      # the positions open (the EA opens one at each signal)
    out = []
    with np.errstate(invalid="ignore"):   # NaN compares as False: no signal while an indicator warms up
        for i in range(2, len(times)):
            if not np.isnan(upper[i - 2]):
                last_fractal = "UP"
            if not np.isnan(lower[i - 2]):
                last_fractal = "DOWN"
            breakdown_buy = jaw[i] < close[i] and jaw[i - 1] > close[i - 1]
            breakdown_sell = jaw[i] > close[i] and jaw[i - 1] < close[i - 1]
            ac_up, ac_down = ac[i] >= ac[i - 1], ac[i] < ac[i - 1]
            ao_up, ao_down = ao[i] > 0 and ao[i - 1] < 0, ao[i] < 0 and ao[i - 1] > 0
            moves = []
            if last_fractal == "DOWN" and breakdown_buy and ac_up and ao_up:
                moves.append(("entry", "BUY"))
                buys += 1
            elif last_fractal == "UP" and breakdown_sell and ac_down and ao_down:
                moves.append(("entry", "SELL"))
                sells += 1
            if ao_down and buys:
                moves.append(("exit", "BUY"))
                buys = 0
            elif ao_up and sells:
                moves.append(("exit", "SELL"))
                sells = 0
            if times[i] > since and (until is None or times[i] < until):
                out += [(int(times[i]), role, side) for role, side in moves]
    return out
