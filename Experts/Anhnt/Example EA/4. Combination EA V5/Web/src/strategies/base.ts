//--- A base: one slot alone, traded on its own signal (src\signals flips), as @tradecanvas/analytics smaCross: a signal opens its side,
//--- the opposite signal closes it and opens the other
import type { StrategyFn, StrategyContext } from '@tradecanvas/analytics';
import { BUY, SELL } from '../signals';

export interface BaseOptions {
  /** Position size (units, not cash). */
  size?: number;
  tag?: string;
}

export function baseStrategy(entries: Int8Array, options: BaseOptions = {}): StrategyFn {
  const size = options.size ?? 1;
  const tag = options.tag ?? 'base';
  return (ctx: StrategyContext) => {
    const signal = entries[ctx.index];
    if (signal === BUY && ctx.position?.side !== 'long') {
      if (ctx.position) ctx.close(tag);
      ctx.placeOrder({ side: 'long', type: 'market', quantity: size, tag });
    } else if (signal === SELL && ctx.position?.side !== 'short') {
      if (ctx.position) ctx.close(tag);
      ctx.placeOrder({ side: 'short', type: 'market', quantity: size, tag });
    }
  };
}
