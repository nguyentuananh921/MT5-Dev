//--- Mirror of Library\Python\signals.py: the same rules, the same names, the same buffers (Sync Everywhere: a change in one is made in the other).
//--- directions(): one value per bar, BUY (1), SELL (-1) or NONE (0). flips(): the entries, a bar whose direction is not NONE and differs from the previous bar's.
//--- Only the rules a strategy reads so far are here; the others come with their strategies.
import type { OHLCBar } from '@tradecanvas/commons';

export const BUY = 1, SELL = -1, NONE = 0;
/** The buffers of an indicator in the order of MT5 (Library\Python\indicators.py), NaN where there is no value. */
export type Buffers = number[][];
export type Rule = (buffers: Buffers, bars: ReadonlyArray<OHLCBar>) => Int8Array;

function previous(values: number[]): number[] {
  return values.map((_, i) => (i === 0 ? NaN : values[i - 1]));
}

//--- NaN compares as false: NONE, as numpy
function direction(buy: boolean[], sell: boolean[]): Int8Array {
  return Int8Array.from(buy, (b, i) => (b ? BUY : sell[i] ? SELL : NONE));
}

export function zeroCross(level = 0): Rule {
  return (buffers) => {
    const value = buffers[0], before = previous(value);
    return direction(value.map((v, i) => v > level && before[i] <= level), value.map((v, i) => v < level && before[i] >= level));
  };
}

export function twoLineCross(mainBuffer: number, signalBuffer: number, overbought = 0, oversold = 0): Rule {
  return (buffers) => {
    const main = buffers[mainBuffer], signal = buffers[signalBuffer];
    const mainBefore = previous(main), signalBefore = previous(signal);
    let buy = main.map((m, i) => m > signal[i] && mainBefore[i] <= signalBefore[i]);
    let sell = main.map((m, i) => m < signal[i] && mainBefore[i] >= signalBefore[i]);
    if (overbought > 0 || oversold > 0) {   // a buy only from the oversold side, a sell only from the overbought side
      buy = buy.map((b, i) => b && main[i] <= oversold);
      sell = sell.map((s, i) => s && main[i] >= overbought);
    }
    return direction(buy, sell);
  };
}

//--- A fractal is known two bars after its middle bar: the signal is placed on that confirming bar. An up fractal = SELL, a down fractal = BUY
export const fractals: Rule = (buffers) => {
  const upper = buffers[0].map((v) => !Number.isNaN(v)), lower = buffers[1].map((v) => !Number.isNaN(v));
  const upperKnown = upper.map((_, i) => i >= 2 && upper[i - 2]);
  const lowerKnown = lower.map((_, i) => i >= 2 && lower[i - 2]);
  return direction(lowerKnown.map((l, i) => l && !upperKnown[i]), upperKnown);
};

export const RULES: Record<string, Rule> = {
  ALLIGATOR: twoLineCross(2, 0),   // Lips (2, fast) crosses Jaw (0, slow), Bill Williams
  AO: zeroCross(),
  AC: zeroCross(),
  FRACTALS: fractals,
};

/** The direction of each bar by the rule of the type (indicators.type_name); a type with no rule here: NONE on every bar. */
export function directions(name: string, buffers: Buffers, bars: ReadonlyArray<OHLCBar>): Int8Array {
  const rule = RULES[name];
  return rule ? rule(buffers, bars) : new Int8Array(bars.length);
}

export function flips(dir: Int8Array): Int8Array {
  return dir.map((d, i) => (d !== NONE && d !== (i === 0 ? d : dir[i - 1]) ? d : NONE));
}
