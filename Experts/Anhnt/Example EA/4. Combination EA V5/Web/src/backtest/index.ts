//--- V5: the backtest of a strategy of the table (GET /strategies) over the bars of the chart, by @tradecanvas/analytics. The strategy is run with each of
//--- its slots alone (its base) on the same bars and the same Backtester: one run each, to compare. Drawn by the strategy indicator (src\strategies\plugin.ts).
import { Backtester } from '@tradecanvas/analytics';
import type { BacktestResult } from '@tradecanvas/analytics';
import type { OHLCBar } from '@tradecanvas/commons';
import { compute } from '../indicators';
import { directions, flips } from '../signals';
import { baseStrategy } from '../strategies/base';
import { conditionStrategy } from '../strategies/conditions';
import type { Slot } from '../strategies/conditions';
import type { StrategyRow } from '../strategies/types';

const BACKTEST_CASH = 10_000;
const BACKTEST_SIZE = 1;   // units, not lots

export interface Run {
  name: string;
  result: BacktestResult;
}

/** The bases (one a slot, in the order of the table) then the strategy; paramsOf gives the params text of a slot (the DB's, or edited on the chart). */
export function backtest(bars: OHLCBar[], strategy: StrategyRow, paramsOf: (slot: string) => string): Run[] {
  const slots = new Map<string, Slot>();
  const runs: Run[] = [];
  for (const slot of strategy.slots) {
    if (slot.type_name === null) continue;
    const buffers = compute(slot.type_name, bars, paramsOf(slot.slot));
    if (buffers === null) {
      console.warn(`Backtest ${strategy.name}: ${slot.slot} (${slot.type_name}) is not asked of TradeCanvas yet`);
      continue;
    }
    const entries = flips(directions(slot.type_name, buffers, bars));
    slots.set(slot.slot, { entries, buffers });
    runs.push({ name: `Base ${slot.slot}`, result: new Backtester({ initialCash: BACKTEST_CASH }).run(bars, baseStrategy(entries, { size: BACKTEST_SIZE, tag: slot.slot })) });
  }
  runs.push({ name: strategy.name, result: new Backtester({ initialCash: BACKTEST_CASH }).run(bars, conditionStrategy(strategy, slots, bars, { size: BACKTEST_SIZE })) });
  return runs;
}
