//--- A strategy of the table: its conditions (Setting_StrategyCondition) on its slots, each row a rule:
//--- "signal": the standard signal of the slot (src\signals) at this bar; "last_signal": its newest standard signal;
//--- the rules of the strategy itself, on the buffers of the slot, as its source EA reads them (STRATEGY_RULES).
//--- entry: every row of a side holds -> that side opens (the other side is closed first). exit: every row of a direction holds -> the position of
//--- the other side closes (an AO SELL closes a BUY). stoploss / takeprofit: not read yet.
import type { StrategyFn, StrategyContext } from '@tradecanvas/analytics';
import { BUY, SELL, NONE } from '../signals';
import type { Buffers, Rule } from '../signals';
import type { OHLCBar } from '@tradecanvas/commons';
import type { StrategyConditionRow, StrategyRow } from './types';

export interface ConditionOptions {
  /** Position size (units, not cash). */
  size?: number;
}

export interface Slot {
  entries: Int8Array;   // the flips of its standard signal
  buffers: Buffers;
}

function lastSignals(entries: Int8Array): Int8Array {
  const out = new Int8Array(entries.length);
  for (let i = 0; i < entries.length; i++) out[i] = entries[i] !== NONE ? entries[i] : i > 0 ? out[i - 1] : NONE;
  return out;
}

//--- The rules of the strategies, by the name of the table (Setting_StrategyCondition.rule): the direction at each bar, from the buffers of the slot in MT5 order
const STRATEGY_RULES: Record<string, Rule> = {
  //--- Profitunity 01. 16365, isBreakdown_jaws_buy / _sell: the close crosses the Jaw (buffer 0) at this bar
  close_cross_jaw: ([jaw], bars) => Int8Array.from(bars, (bar, i) => {
    if (i === 0) return NONE;
    const before = bars[i - 1].close;
    if (jaw[i] < bar.close && jaw[i - 1] > before) return BUY;
    if (jaw[i] > bar.close && jaw[i - 1] < before) return SELL;
    return NONE;
  }),
  //--- Profitunity 01. 16365, ac_color: the colour of the AC (buffer 0) as Accelerator.mq5 gives it, green (AC >= the one before) = BUY, red = SELL
  color: ([ac], bars) => Int8Array.from(bars, (_, i) => (i === 0 || Number.isNaN(ac[i]) || Number.isNaN(ac[i - 1]) ? NONE : ac[i] >= ac[i - 1] ? BUY : SELL)),
  //--- Profitunity 01. 16365, lastFractal_direction: the newest fractal (known 2 bars after its middle, as src\signals), a down one = BUY, it wins over an up one
  last_fractal: ([upper, lower], bars) => {
    const out = new Int8Array(bars.length);
    for (let i = 0; i < bars.length; i++) {
      out[i] = i > 0 ? out[i - 1] : NONE;
      if (i < 2) continue;
      if (!Number.isNaN(upper[i - 2])) out[i] = SELL;
      if (!Number.isNaN(lower[i - 2])) out[i] = BUY;
    }
    return out;
  },
};

export function conditionStrategy(strategy: StrategyRow, slots: Map<string, Slot>, bars: ReadonlyArray<OHLCBar>, options: ConditionOptions = {}): StrategyFn {
  const size = options.size ?? 1;
  const tag = strategy.name;
  const value = (side: string) => (side === 'BUY' ? BUY : side === 'SELL' ? SELL : NONE);
  const series = new Map<string, Int8Array | undefined>();   // by slot and rule, made once
  const seriesOf = (row: StrategyConditionRow): Int8Array | undefined => {
    const key = `${row.slot}|${row.rule}`;
    if (series.has(key)) return series.get(key);
    const slot = slots.get(row.slot);
    const rule = STRATEGY_RULES[row.rule];
    const made = slot === undefined ? undefined
      : row.rule === 'signal' ? slot.entries
      : row.rule === 'last_signal' ? lastSignals(slot.entries)
      : rule ? rule(slot.buffers, bars) : undefined;
    if (made === undefined) console.warn(`${strategy.name}: rule ${row.rule} of ${row.slot} is not known`);
    series.set(key, made);
    return made;
  };

  const holds = (row: StrategyConditionRow, i: number): boolean => seriesOf(row)?.[i] === value(row.signal_direction);
  const all = (role: string, side: string, i: number): boolean => {
    const rows = strategy.conditions.filter((c) => c.role === role && c.signal_direction === side);
    return rows.length > 0 && rows.every((row) => holds(row, i));
  };

  return (ctx: StrategyContext) => {
    const i = ctx.index;
    let side = ctx.position?.side ?? null;
    if (side === 'long' && all('exit', 'SELL', i)) { ctx.close(tag); side = null; }
    else if (side === 'short' && all('exit', 'BUY', i)) { ctx.close(tag); side = null; }

    if (all('entry', 'BUY', i) && side !== 'long') {
      if (side === 'short') ctx.close(tag);
      ctx.placeOrder({ side: 'long', type: 'market', quantity: size, tag });
    } else if (all('entry', 'SELL', i) && side !== 'short') {
      if (side === 'long') ctx.close(tag);
      ctx.placeOrder({ side: 'short', type: 'market', quantity: size, tag });
    }
  };
}
