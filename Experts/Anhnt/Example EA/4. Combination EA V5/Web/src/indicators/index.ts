//--- The buffers of a standard indicator (indicators.type_name, its params text of the table) from the indicators of TradeCanvas, in the order of MT5
//--- (Library\Python\indicators.py): the rules of src\signals read the same buffers as signals.py. Only the types a strategy reads so far are here.
import type { IndicatorConfig, IndicatorOutput, OHLCBar } from '@tradecanvas/commons';
import {
  AcceleratorOscillatorIndicator,
  AlligatorIndicator,
  AwesomeOscillatorIndicator,
  WilliamsFractalsIndicator,
} from '@tradecanvas/core';
import type { Buffers } from '../signals';

interface Standard {
  id: string;                                          // the TradeCanvas indicator: computed here, added to the chart with a strategy
  params: (p: string[]) => Record<string, number>;     // from the params text of the table
  make: () => { calculate(data: OHLCBar[], config: IndicatorConfig): IndicatorOutput };
  keys: string[];                                      // its output fields, in the order of the MT5 buffers
}

//--- The order of the params text: indicators.py PARAM_KEYS ("jaw_period", "jaw_shift", "teeth_period", "teeth_shift", "lips_period", "lips_shift", "method", "applied")
const STANDARD: Record<string, Standard> = {
  ALLIGATOR: {
    id: 'alligator',
    params: (p) => {
      if (p[6] !== 'SMMA' || p[7] !== 'MEDIAN') throw new Error(`Alligator ${p.join(',')}: TradeCanvas draws SMMA of MEDIAN only`);
      const [jaw, jawShift, teeth, teethShift, lips, lipsShift] = p.map(Number);
      return { jaw, jawShift, teeth, teethShift, lips, lipsShift };
    },
    make: () => new AlligatorIndicator(),
    keys: ['jaw', 'teeth', 'lips'],
  },
  AO: { id: 'ao', params: () => ({ fast: 5, slow: 34 }), make: () => new AwesomeOscillatorIndicator(), keys: ['value'] },
  AC: { id: 'ac', params: () => ({}), make: () => new AcceleratorOscillatorIndicator(), keys: ['value'] },
  FRACTALS: { id: 'fractals', params: () => ({ period: 2 }), make: () => new WilliamsFractalsIndicator(), keys: ['up', 'down'] },
};

function split(paramsText: string): string[] {
  return paramsText === '' ? [] : paramsText.split(',');
}

/** The TradeCanvas indicator of a type and its params, as the chart takes them (addIndicator); null: a type not asked for yet. */
export function standardIndicator(name: string, paramsText: string): { id: string; params: Record<string, number> } | null {
  const s = STANDARD[name];
  return s ? { id: s.id, params: s.params(split(paramsText)) } : null;
}

/** null: a type TradeCanvas is not asked for yet. */
export function compute(name: string, bars: OHLCBar[], paramsText: string): Buffers | null {
  const s = STANDARD[name];
  if (!s) return null;
  const output = s.make().calculate(bars, { id: s.id, instanceId: `strategy-${s.id}`, params: s.params(split(paramsText)) });
  return s.keys.map((key) => Array.from({ length: bars.length }, (_, i) => output.series?.[i]?.[key] ?? NaN));
}
