"""One engine for every strategy (Concept.md: a strategy is how its events are combined), as the EA's CStrategyEngine (UseCases\\Strategies\\StrategyEngine.mqh).
The EA (CStrategyManager) writes the strategy: its slots with the params of their indicators (Setting_StrategyIndicator) and its conditions (Setting_StrategyCondition),
read by libdb.strategies(). Each condition row asks the rule of its slot for the event on each bar (RULES, one per CConditionJudge):
  signal           the basic signal of the slot: the flips of signals.directions (the rows of SignalsCollection the EA reads from its CSignal)
  last_fractal     the newest fractal, known 2 bars after its middle, looked back FRACTAL_BACK bars: down = BUY, up = SELL, a down one of the same bar wins
                   (from shift 3, not 2 as the source EA of Profitunity: why at CSetting_Profitunity, condition last_fractal)
  close_cross_jaw  the close crosses buffer 0 (the Jaw of Alligator): jaw[1] < close(1) && jaw[2] > close(2) = BUY, the other way = SELL
  rising           buffer 0 against the bar before: >= = BUY, < = SELL
  ma_cross         buffer 0 of the slot crosses buffer 0 of the slot SlowMA: fast > slow and fast before <= slow before = BUY, the other way = SELL
A bar with a value of a row not there (the warm-up) is not judged, as the EA (WRONG_VALUE). Entry: every entry row of a side holds (BUY first).
Exit: the other side is open (the entry of the bar counted) and every exit row of a side holds (an AO SELL closes every BUY)."""
import numpy as np

import indicators
import signals

FRACTAL_BACK = 500   # the bars looked back for the newest fractal (CONDITION_FRACTAL_BACK of ConditionLastFractal.mqh)
_not_known = set()   # the rules told once: no rule of that name, the row never holds (CStrategyEngine prints the same)


def _known(values):
    """A value there: not NaN (EMPTY_VALUE of MT5) and not 0 (CConditionJudge::Known)."""
    return ~np.isnan(values) & (values != 0.0)


def _previous(values):
    out = np.empty_like(values)
    out[0] = np.nan
    out[1:] = values[:-1]
    return out


def _side(buy, sell):
    return np.where(buy, signals.BUY, np.where(sell, signals.SELL, signals.NONE)).astype(np.int8)


def _signal(slot, buffers, bars, buffers_of=None):
    _, params = indicators.from_template(slot["type_name"], len(indicators.PARAM_KEYS[slot["type_name"]]), slot["params"] or "")
    levels = (slot["level_high"] or 0.0, slot["level_low"] or 0.0)
    side = signals.flips(signals.directions(slot["type_name"], buffers, bars, params, levels))
    return side, np.ones(len(side), dtype=bool)


def _last_fractal(slot, buffers, bars, buffers_of=None):
    upper, lower = _known(np.asarray(buffers[0], dtype=float)), _known(np.asarray(buffers[1], dtype=float))
    total = len(upper)
    side, newest, newest_side = np.zeros(total, dtype=np.int8), -1, signals.NONE
    for i in range(2, total):
        middle = i - 2
        if lower[middle]:
            newest, newest_side = middle, signals.BUY    # FRACTAL_DOWN
        elif upper[middle]:
            newest, newest_side = middle, signals.SELL   # FRACTAL_UP
        if newest >= 0 and middle - newest < FRACTAL_BACK:
            side[i] = newest_side
    return side, np.ones(total, dtype=bool)


def _close_cross_jaw(slot, buffers, bars, buffers_of=None):
    jaw, close = np.asarray(buffers[0], dtype=float), bars["close"].to_numpy(dtype=float)
    jaw_before, close_before = _previous(jaw), _previous(close)
    with np.errstate(invalid="ignore"):
        side = _side((jaw < close) & (jaw_before > close_before), (jaw > close) & (jaw_before < close_before))
    return side, _known(jaw) & _known(jaw_before)


def _rising(slot, buffers, bars, buffers_of=None):
    value = np.asarray(buffers[0], dtype=float)
    before = _previous(value)
    with np.errstate(invalid="ignore"):
        side = _side(value >= before, value < before)
    return side, ~np.isnan(value) & ~np.isnan(before)   # a value of 0 is a value


MA_CROSS_SLOW = "SlowMA"   # the slot the fast MA of a ma_cross row is compared with (CONDITION_MA_CROSS_SLOW of ConditionMACross.mqh)


def _ma_cross(slot, buffers, bars, buffers_of=None):
    """FixedMACrossover_Part7 ReadSignal: fast[1] > slow[1] and fast[2] <= slow[2] = BUY, the other way = SELL."""
    slow_buffers = buffers_of(MA_CROSS_SLOW) if buffers_of is not None else None
    total = len(bars)
    if slow_buffers is None:
        return np.zeros(total, dtype=np.int8), np.zeros(total, dtype=bool)
    fast, slow = np.asarray(buffers[0], dtype=float), np.asarray(slow_buffers[0], dtype=float)
    fast_before, slow_before = _previous(fast), _previous(slow)
    with np.errstate(invalid="ignore"):
        side = _side((fast > slow) & (fast_before <= slow_before), (fast < slow) & (fast_before >= slow_before))
    return side, _known(fast) & _known(fast_before) & _known(slow) & _known(slow_before)


RULES = {"signal": _signal, "last_fractal": _last_fractal, "close_cross_jaw": _close_cross_jaw, "rising": _rising, "ma_cross": _ma_cross}   # Setting_StrategyCondition.rule


def _buffers(slot, bars):
    """The buffers of an indicator slot, with its params (the strategy's, else the standard of the table indicators)."""
    name = slot["type_name"]
    _, params = indicators.from_template(name, len(indicators.PARAM_KEYS[name]), slot["params"] or "")
    buffers, _ = indicators.compute(name, bars, params)
    return [np.asarray(b, dtype=float) for b in buffers]


def context(strategy):
    """The bars before a bar the strategy needs: its indicators warm up, a fractal is looked back FRACTAL_BACK bars, a position opened before the bars judged can still close in them."""
    out = FRACTAL_BACK
    for slot in strategy["slots"]:
        keys = indicators.PARAM_KEYS.get(slot["type_name"] or "")
        template = indicators.from_template(slot["type_name"], len(keys), slot["params"] or "") if keys else None
        if template is not None:
            out = max(out, indicators.context(template[1]))
    return out


def calculate(strategy, bars, since=0, until=None):
    """The entries and exits on the bars, a list of (bar time, "entry" or "exit", "BUY" or "SELL": the side opened or closed), of the bars with
    since < time (< until when it is given). The bars are closed: the newest one is shift 1."""
    slots = {slot["slot"]: slot for slot in strategy["slots"]}
    total = len(bars)
    buffers, rows = {}, []

    def buffers_of(name):
        """The buffers of another slot of the strategy (a rule on two slots, as ma_cross), None when it has none."""
        other = slots.get(name)
        if other is None or other["type_name"] is None:
            return None
        if name not in buffers:
            buffers[name] = _buffers(other, bars)
        return buffers[name]

    for row in strategy["conditions"]:
        rule, slot = RULES.get(row["rule"]), slots.get(row["slot"])
        if rule is None or slot is None or slot["type_name"] is None:
            key = (strategy["name"], row["rule"], row["slot"])
            if key not in _not_known:
                _not_known.add(key)
                print(f"{strategy['name']}: no rule {row['rule']} of the slot {row['slot']}: the row never holds")
            rows.append((row, np.zeros(total, dtype=np.int8), np.ones(total, dtype=bool)))
            continue
        if row["slot"] not in buffers:
            buffers[row["slot"]] = _buffers(slot, bars)
        side, ready = rule(slot, buffers[row["slot"]], bars, buffers_of)
        rows.append((row, side, ready))
    want = {"BUY": signals.BUY, "SELL": signals.SELL}

    def holds(role, side_text, i):
        mine = [side for row, side, _ in rows if row["role"] == role and row["signal_direction"] == side_text]
        return len(mine) > 0 and all(side[i] == want[side_text] for side in mine)

    ready = np.logical_and.reduce([r for _, _, r in rows]) if rows else np.zeros(total, dtype=bool)
    times = bars["time"].to_numpy()
    buys = sells = 0   # the entries open (an exit closes every one of its side)
    out = []
    for i in range(total):
        if not ready[i]:
            continue   # a value not there: the bar is not judged (CStrategyEngine::Calculate returns WRONG_VALUE)
        moves = []
        if holds("entry", "BUY", i):
            moves.append(("entry", "BUY"))
            buys += 1
        elif holds("entry", "SELL", i):
            moves.append(("entry", "SELL"))
            sells += 1
        if buys and holds("exit", "SELL", i):
            moves.append(("exit", "BUY"))
            buys = 0
        elif sells and holds("exit", "BUY", i):
            moves.append(("exit", "SELL"))
            sells = 0
        if times[i] > since and (until is None or times[i] < until):
            out += [(int(times[i]), role, side) for role, side in moves]
    return out
