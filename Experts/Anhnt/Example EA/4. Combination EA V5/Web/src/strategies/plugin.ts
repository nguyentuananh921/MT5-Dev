//--- V5: a strategy of the table (GET /strategies) as an indicator of TradeCanvas: added from the picker (group "other", shown as Strategy) with the standard
//--- indicators of its slots (shown and hidden with it, as the article draws them), the params of its slots edited in its settings, its backtest (src\backtest)
//--- drawn on the chart: the table of the runs (bases + strategy), a check box a row, and the trades of the runs checked.
import { overlayScale } from '@tradecanvas/chart';
import type { Chart } from '@tradecanvas/chart';
import type { IndicatorConfig, IndicatorInputSpec, IndicatorPlugin, OHLCBar } from '@tradecanvas/commons';
import { backtest } from '../backtest';
import type { Run } from '../backtest';
import { standardIndicator } from '../indicators';
import type { StrategyRow } from './types';

const ID_PREFIX = 'strategy-';
const WIN = '#26a69a';
const LOSS = '#ef5350';
const RUN_COLOURS = ['#f5a623', '#4a90e2', '#bd10e0', '#7ed321', '#50e3c2', '#e94e77'];   // a run each, the strategy last: its marks and its check box
const TABLE_FONT = '11px monospace';
const TABLE_ROW_H = 16;
const TABLE_PAD = 6;
const TABLE_BG = 'rgba(20, 22, 28, 0.82)';
const TABLE_TEXT = '#d1d4dc';
const BOX = 9;    // a check box, px
const MARK = 6;   // half the size of an entry / exit mark, px
const MARK_EDGE = '#ffffff';
const MARK_FONT = 'bold 10px sans-serif';

interface Meta {
  instanceId: string;
  bars: OHLCBar[];
  runs: Run[];
  checked: boolean[];   // by run
}

interface TableBox {
  left: number;
  top: number;
  width: number;
  keys: string[];       // the input of each run, a row each under the header
  checked: boolean[];
}

const tables = new Map<string, TableBox>();   // by instance, as last drawn: a click on a row checks or unchecks its run

function inputKey(slot: string, key: string): string {
  return `${slot}_${key}`;
}

/** The input that checks a run: its trades on the chart. */
function tradesKey(run: string): string {
  return `trades_${run.replace(/\s+/g, '_')}`;
}

/** The params text of a slot: the DB's, its numbers as edited in the settings. */
function paramsText(strategy: StrategyRow, params: IndicatorConfig['params'], slot: string): string {
  const row = strategy.slots.find((s) => s.slot === slot);
  return (row?.params ?? '').split(',').map((text, i) => {
    const value = params[inputKey(slot, row?.param_keys[i] ?? '')];
    return value === undefined ? text : String(value);
  }).join(',');
}

/** The numeric params of the slots (the text ones, as SMMA / MEDIAN, stay the DB's): the inputs and their defaults. */
function slotInputs(strategy: StrategyRow) {
  const inputs: Record<string, IndicatorInputSpec> = {};
  const defaults: Record<string, number | boolean> = {};
  for (const slot of strategy.slots) {
    (slot.params ?? '').split(',').forEach((text, i) => {
      const key = slot.param_keys[i];
      const value = Number(text);
      if (key === undefined || text === '' || !Number.isFinite(value)) return;
      inputs[inputKey(slot.slot, key)] = { kind: Number.isInteger(value) ? 'int' : 'number', label: `${slot.slot} ${key}` };
      defaults[inputKey(slot.slot, key)] = value;
    });
  }
  return { inputs, defaults };
}

/** A check box a run, the strategy's checked: its trades drawn first. */
function runInputs(strategy: StrategyRow) {
  const inputs: Record<string, IndicatorInputSpec> = {};
  const defaults: Record<string, boolean> = {};
  const names = [...strategy.slots.filter((s) => s.type_name !== null).map((s) => `Base ${s.slot}`), strategy.name];
  for (const name of names) {
    inputs[tradesKey(name)] = { kind: 'boolean', label: `Trades of ${name}` };
    defaults[tradesKey(name)] = name === strategy.name;
  }
  return { inputs, defaults };
}

/** PnL of the closed trades only: metrics.totalReturn also marks the open position to the last close. */
function cells(run: Run): string[] {
  const m = run.result.metrics;
  const pnl = run.result.trades.reduce((sum, t) => sum + t.pnl, 0);
  const pf = Number.isFinite(m.profitFactor) ? m.profitFactor.toFixed(2) : '∞';
  return [run.name, String(m.trades), pnl.toFixed(2), `${(m.winRate * 100).toFixed(0)}%`, pf, m.maxDrawdown.toFixed(2)];
}

function colourOf(meta: Meta, run: number): string {
  return run === meta.runs.length - 1 ? RUN_COLOURS[0] : RUN_COLOURS[1 + (run % (RUN_COLOURS.length - 1))];
}

/** At the top right of the prices, left of the tools of the chart: a check box, then the run and its statistics. */
function drawTable(ctx: CanvasRenderingContext2D, meta: Meta, right: number, top: number) {
  const rows = [[`${meta.bars.length} bars`, 'Trades', 'PnL', 'Win', 'PF', 'Max DD'], ...meta.runs.map(cells)];
  ctx.font = TABLE_FONT;
  const widths = rows[0].map((_, c) => Math.max(...rows.map((r) => ctx.measureText(r[c]).width)) + TABLE_PAD * 2);
  widths[0] += BOX + TABLE_PAD;
  const width = widths.reduce((a, b) => a + b, 0);
  const left = right - width;
  tables.set(meta.instanceId, { left, top, width, keys: meta.runs.map((r) => tradesKey(r.name)), checked: meta.checked });
  ctx.fillStyle = TABLE_BG;
  ctx.fillRect(left, top, width, rows.length * TABLE_ROW_H + TABLE_PAD);
  ctx.textBaseline = 'middle';
  rows.forEach((row, r) => {
    let x = left;
    const y = top + TABLE_PAD / 2 + r * TABLE_ROW_H + TABLE_ROW_H / 2;
    if (r > 0) {
      const colour = colourOf(meta, r - 1);
      ctx.strokeStyle = ctx.fillStyle = colour;
      ctx.lineWidth = 1;
      if (meta.checked[r - 1]) ctx.fillRect(x + TABLE_PAD, y - BOX / 2, BOX, BOX);
      else ctx.strokeRect(x + TABLE_PAD + 0.5, y - BOX / 2 + 0.5, BOX - 1, BOX - 1);
    }
    row.forEach((text, c) => {
      ctx.fillStyle = r > 0 && c === 2 ? (Number(text) >= 0 ? WIN : LOSS) : TABLE_TEXT;
      ctx.textAlign = c === 0 ? 'left' : 'right';
      ctx.fillText(text, c === 0 ? x + TABLE_PAD + (r > 0 ? BOX + TABLE_PAD : 0) : x + widths[c] - TABLE_PAD, y);
      x += widths[c];
    });
  });
}

/** An entry: an arrow B (long) or S (short), the exit: a cross, in the colour of the run; joined by a dashed line, green won, red lost. */
function drawTrades(ctx: CanvasRenderingContext2D, meta: Meta, s: ReturnType<typeof overlayScale>) {
  meta.runs.forEach((run, r) => {
    if (!meta.checked[r]) return;
    const colour = colourOf(meta, r);
    for (const t of run.result.trades) {
      const x0 = s.timeToX(t.entryTime);
      const y0 = s.priceToY(t.entryPrice);
      const x1 = s.timeToX(t.exitTime);
      const y1 = s.priceToY(t.exitPrice);
      ctx.strokeStyle = t.pnl >= 0 ? WIN : LOSS;
      ctx.setLineDash([4, 3]);
      ctx.beginPath();
      ctx.moveTo(x0, y0);
      ctx.lineTo(x1, y1);
      ctx.stroke();
      ctx.setLineDash([]);
      //--- The entry: an arrow up under the price (B) or down over it (S)
      const up = t.side === 'long' ? 1 : -1;
      const tipY = y0 + up * 2;
      const baseY = tipY + up * MARK * 2;
      ctx.fillStyle = colour;
      ctx.strokeStyle = MARK_EDGE;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(x0, tipY);
      ctx.lineTo(x0 - MARK, baseY);
      ctx.lineTo(x0 + MARK, baseY);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();
      ctx.font = MARK_FONT;
      ctx.textAlign = 'center';
      ctx.textBaseline = up > 0 ? 'top' : 'bottom';
      ctx.fillText(up > 0 ? 'B' : 'S', x0, baseY + up * 2);
      //--- The exit: a cross at its price
      ctx.strokeStyle = colour;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(x1 - MARK + 1, y1 - MARK + 1);
      ctx.lineTo(x1 + MARK - 1, y1 + MARK - 1);
      ctx.moveTo(x1 + MARK - 1, y1 - MARK + 1);
      ctx.lineTo(x1 - MARK + 1, y1 + MARK - 1);
      ctx.stroke();
      ctx.lineWidth = 1;
    }
  });
}

function strategyPlugin(strategy: StrategyRow): IndicatorPlugin {
  const slots = slotInputs(strategy);
  const runs = runInputs(strategy);
  const lastRun = new Map<string, { key: string; runs: Run[] }>();   // by instance: run again only on a new closed bar or new params
  return {
    descriptor: {
      id: `${ID_PREFIX}${strategy.strategy_id}`,
      name: strategy.name,
      shortName: strategy.name,
      placement: 'overlay',
      category: 'other',
      defaultConfig: { ...runs.defaults, ...slots.defaults },
      inputs: { ...runs.inputs, ...slots.inputs },
    },
    calculate(data, config) {
      const bars = data.slice(0, -1);   // closed bars: the forming one would move the runs at every tick
      const params = Object.fromEntries(Object.entries(config.params).filter(([k]) => !k.startsWith('trades_')));
      const key = `${bars.length}|${bars[bars.length - 1]?.time}|${JSON.stringify(params)}`;   // the runs checked do not change the runs
      const cached = lastRun.get(config.instanceId);
      const result = cached?.key === key ? cached.runs : backtest(bars, strategy, (slot) => paramsText(strategy, config.params, slot));
      lastRun.set(config.instanceId, { key, runs: result });
      const checked = result.map((r) => config.params[tradesKey(r.name)] === true);
      return { values: new Map(), meta: { instanceId: config.instanceId, bars, runs: result, checked } satisfies Meta };
    },
    render(ctx, output, viewport) {
      const meta = output.meta as Meta | undefined;
      if (!meta || meta.runs.length === 0) return;
      ctx.save();
      drawTrades(ctx, meta, overlayScale({ viewport, data: meta.bars }));
      drawTable(ctx, meta, viewport.chartRect.x + viewport.chartRect.width - TABLE_PAD, viewport.chartRect.y + TABLE_PAD);
      ctx.restore();
    },
  };
}

/** The strategies on the chart: each in the picker; added, with the standard indicators of its slots, which follow its params, its eye and its removal. */
export function attachStrategies(chart: Chart, strategies: StrategyRow[]) {
  const byId = new Map(strategies.map((s) => [`${ID_PREFIX}${s.strategy_id}`, s]));
  const standards = new Map<string, string[]>();   // the instances of the standard indicators, by strategy instance
  const paramsOf = (instanceId: string) => chart.getActiveIndicators().find((i) => i.instanceId === instanceId);
  strategies.forEach((s) => chart.registerIndicator(strategyPlugin(s)));

  chart.on('indicatorAdd', ({ payload }) => {
    const strategy = byId.get(payload.id);
    const active = paramsOf(payload.instanceId);
    if (!strategy || !active || standards.has(payload.instanceId)) return;
    const added: string[] = [];
    for (const slot of strategy.slots) {
      if (slot.type_name === null) continue;
      const standard = standardIndicator(slot.type_name, paramsText(strategy, active.params as IndicatorConfig['params'], slot.slot));
      const instanceId = standard ? chart.addIndicator(standard.id, standard.params) : null;
      if (instanceId) added.push(instanceId);
    }
    standards.set(payload.instanceId, added);
  });

  chart.on('indicatorChange', ({ payload }) => {
    const added = standards.get(payload.instanceId);
    const active = paramsOf(payload.instanceId);
    const strategy = active && byId.get(active.id);
    if (!added || !active || !strategy) return;
    if (payload.change === 'visible') added.forEach((id) => chart.setIndicatorVisible(id, active.visible));
    if (payload.change !== 'params') return;
    let i = 0;
    for (const slot of strategy.slots) {
      if (slot.type_name === null) continue;
      const standard = standardIndicator(slot.type_name, paramsText(strategy, active.params as IndicatorConfig['params'], slot.slot));
      if (standard && added[i] !== undefined) chart.updateIndicator(added[i], standard.params);
      if (standard) i++;
    }
  });

  chart.on('indicatorRemove', ({ payload }) => {
    tables.delete(payload.instanceId);
    standards.get(payload.instanceId)?.forEach((id) => chart.removeIndicator(id));
    standards.delete(payload.instanceId);
  });

  chart.on('click', ({ payload }) => {   // a row of a strategy table: its trades on the chart or off, its check box in the settings too
    for (const [instanceId, box] of tables) {
      if (payload.x < box.left || payload.x > box.left + box.width || !paramsOf(instanceId)?.visible) continue;   // hidden: no table drawn
      const row = Math.floor((payload.y - box.top - TABLE_PAD / 2) / TABLE_ROW_H) - 1;   // -1: the header
      if (row >= 0 && row < box.keys.length) return chart.updateIndicator(instanceId, { [box.keys[row]]: !box.checked[row] });
    }
  });
}
