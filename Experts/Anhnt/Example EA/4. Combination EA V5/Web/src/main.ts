//--- Copied from tradecanvas demo\src\routes\embed\+page.svelte (mountWidget), Svelte shell removed
import { generateBars } from './sampleData';
import { overlayScale } from '@tradecanvas/chart';
import type { OHLCBar, OverlayPlugin, TimeFrame } from '@tradecanvas/chart';
import { attachStrategies } from './strategies/plugin';
import type { StrategyRow } from './strategies';

// Library\Python\server.py: the page comes from it, so it is where the page came from; under `npm run dev` (Vite) it is the port of the EA (PYTHON_PORT)
const SERVER = import.meta.env.DEV ? 'http://127.0.0.1:8765' : window.location.origin;
// Notation only: the unit of a name of the table timeframes as TradeCanvas writes it ('M15' <-> '15m', 'MN1' <-> '1M')
const UNIT_OF_MT5: Record<string, string> = { M: 'm', H: 'h', D: 'd', W: 'w', MN: 'M' };
const HISTORY_BARS = 5000;   // the bars of the first load (polls take 2): the strategies are backtested on all the bars the chart holds

function tcTimeframe(name: string): TimeFrame {
  const unit = name.replace(/\d+$/, '');
  return (name.slice(unit.length) + UNIT_OF_MT5[unit]) as TimeFrame;
}

function mt5Timeframe(tf: string): string {
  const unit = Object.keys(UNIT_OF_MT5).find((k) => UNIT_OF_MT5[k] === tf.slice(-1)) ?? '';
  return unit + tf.slice(0, -1);
}

async function getJson<T>(path: string): Promise<T> {
  const res = await fetch(`${SERVER}${path}`);
  if (!res.ok) throw new Error(`server.py ${res.status}: ${await res.text()}`);
  return res.json();
}

function getBars(symbol: string, tf: string, limit: number, before = 0): Promise<OHLCBar[]> {
  return getJson(`/bars?symbol=${symbol}&tf=${mt5Timeframe(tf)}&limit=${limit}${before ? `&before=${before}` : ''}`);
}

//--- V5: the bars Kronos foretells, pushed by server.py on its WebSocket (the lines the EA gets on its socket, V3), drawn faint after the newest bar.
//--- TradeCanvas has no series of future bars to give them to: an overlay plugin of its Plugin SDK (contract B, kept through 1.x) draws them
const SOCKET = SERVER.replace(/^http/, 'ws') + '/socket';   // the same port as the EA: one source, the same lines
const SOCKET_RETRY_MS = 2000;   // server.py gone (the EA closed, a new start): connect again
const WATCH_CHECK_MS = 500;     // the pair shown is looked at this often: a new one is told to server.py
const FORECAST_UP = 'rgba(38, 166, 154, 0.45)';
const FORECAST_DOWN = 'rgba(239, 83, 80, 0.45)';

let forecastBars: OHLCBar[] = [];   // the bars of the forecast of the pair shown

const forecastOverlay: OverlayPlugin = {
  descriptor: { id: 'kronos-forecast', name: 'Kronos forecast' },
  render(ctx, context) {
    if (forecastBars.length === 0) return;
    const s = overlayScale(context);
    const half = Math.max(1, s.barWidth / 2);
    const newest = context.data.length > 0 ? context.data[context.data.length - 1].time : 0;   // the forming bar: the chart has the real one
    for (const bar of forecastBars) {
      if (bar.time <= newest) continue;   // only the future is drawn (as the EA, CKronosForecastCollection)
      const x = s.timeToX(bar.time);
      const top = s.priceToY(Math.max(bar.open, bar.close));
      const bottom = s.priceToY(Math.min(bar.open, bar.close));
      ctx.fillStyle = ctx.strokeStyle = bar.close >= bar.open ? FORECAST_UP : FORECAST_DOWN;
      ctx.beginPath();
      ctx.moveTo(x, s.priceToY(bar.high));
      ctx.lineTo(x, s.priceToY(bar.low));
      ctx.stroke();
      ctx.fillRect(x - half, top, half * 2, Math.max(1, bottom - top));
    }
  },
};

/** The forecasts of the pair shown: watch|<symbol>|<tf> out, forecast|... lines in; at forecast_end the bars go to `show` ([] for none: another pair). */
function followForecasts(shown: () => string, show: (bars: OHLCBar[]) => void) {
  let socket: WebSocket | null = null;
  let watching = '';
  let gathering: OHLCBar[] = [];
  const watch = () => {
    const key = shown();
    if (key === watching) return;
    watching = key;
    gathering = [];
    show([]);   // another pair: the forecast of the old one goes
    if (socket?.readyState === WebSocket.OPEN) socket.send(`watch|${key}\n`);
  };
  const open = () => {
    socket = new WebSocket(SOCKET);
    socket.onopen = () => { watching = ''; watch(); };
    socket.onclose = () => setTimeout(open, SOCKET_RETRY_MS);
    socket.onmessage = (event) => {
      for (const line of String(event.data).split('\n')) {
        const part = line.split('|');
        if (`${part[1]}|${part[2]}` !== watching) continue;   // a line of a pair no longer shown
        if (part[0] === 'forecast' && part.length === 10) {
          gathering.push({ time: Number(part[4]) * 1000, open: Number(part[5]), high: Number(part[6]), low: Number(part[7]), close: Number(part[8]), volume: Number(part[9]) });
        } else if (part[0] === 'forecast_end') {
          show(gathering);
          gathering = [];
        }
      }
    };
  };
  open();
  setInterval(watch, WATCH_CHECK_MS);
}

//--- V5: what the user chose last, kept in this browser for the next visit (the URL wins over it)
const THEME_KEY = 'tcw:theme';           // dark / light
const SYMBOL_KEY = 'tcw:symbol';
const TIMEFRAME_KEY = 'tcw:timeframe';   // as TradeCanvas writes it ('15m')

function remembered(key: string): string | null {
  try { return localStorage.getItem(key); } catch { return null; }
}

function remember(key: string, value: string | undefined) {
  try { if (value) localStorage.setItem(key, value); } catch { /* not kept: the default next time */ }
}

function themeOf(host: HTMLDivElement): string | undefined {
  // The widget marks its mode on its root (ChartWidgetGrid reads it the same way)
  return host.querySelector<HTMLElement>('.tcw-root')?.dataset.tcwTheme;
}

let widget: { destroy?: () => void } | null = null;

async function mountWidget(host: HTMLDivElement) {

    const params = new URLSearchParams(window.location.search);
    const timeframe = (params.get('timeframe') ?? remembered(TIMEFRAME_KEY) ?? '15m') as
      | '1m' | '5m' | '15m' | '1h' | '4h' | '1d';
    const theme = (params.get('theme') ?? remembered(THEME_KEY)) === 'light' ? 'light' : 'dark';
    const chartType = params.get('chartType') as
      | undefined
      | 'candlestick' | 'line' | 'area' | 'bar' | 'heikinAshi' | 'equivolume';
    const indicators = params.get('indicators')?.split(',').filter(Boolean) ?? [];
    const trading = params.get('trading') === 'true';
    const watchlist = params.get('watchlist') === 'true';
    const locale = params.get('locale') ?? undefined;
    // `?ui=studio` / `terminal` / `capsule` / `desk`: the widget in that look (Print without it).
    const uiParam = params.get('ui');
    const ui = uiParam === 'terminal' || uiParam === 'capsule' || uiParam === 'desk' || uiParam === 'studio' || uiParam === 'print' ? uiParam : undefined;
    const numberLocale = params.get('numberLocale') ?? undefined;
    // `?latency=1500` delays every history request — shows the loading veil
    // a slow network gets on symbol/timeframe switches.
    const latency = Math.max(0, Number(params.get('latency')) || 0);
    // `?bars=200000` loads that many generated 1m bars instead of Binance;
    // timeframe switches then resample locally (no network).
    const staticBars = Math.max(0, Math.floor(Number(params.get('bars')) || 0));
    // V5: the list of the symbol button: the symbols of the account (GET /symbols, table symbols), not DEFAULT_SYMBOLS of TradeCanvas (Binance)
    const symbols = staticBars ? undefined : await getJson<string[]>('/symbols').catch((err) => { console.warn('GET /symbols', err); return undefined; });
    const chosen = remembered(SYMBOL_KEY);
    // V5: the URL, else the one the user chose last while it is still a symbol of the EA, else the first one
    const symbol = params.get('symbol') ?? (chosen && (!symbols?.length || symbols.includes(chosen)) ? chosen : symbols?.[0]) ?? 'XAUUSD';

    try {
      const { ChartWidget } = await import('@tradecanvas/chart/widget');
      const { PollingAdapter } = await import('@tradecanvas/chart');

      let adapter: InstanceType<typeof PollingAdapter> | undefined;
      if (!staticBars) {
        //--- V5: the bars of MT5 from Library\Python\server.py instead of Binance
        adapter = new PollingAdapter({
          name: 'mt5',
          supportedTimeframes: (await getJson<string[]>('/timeframes')).map(tcTimeframe),   // the table timeframes; the chart builds the others
          fetchBars: (s, tf, limit) => getBars(s, tf, limit),
          fetchHistoryBefore: (s, tf, before, limit) => getBars(s, tf, limit, before),
          intervalMs: 1000,
        });
        if (latency > 0) {
          const fetchHistory = adapter.fetchHistory.bind(adapter);
          adapter.fetchHistory = async (...args) => {
            await new Promise((r) => setTimeout(r, latency));
            return fetchHistory(...args);
          };
        }
      }

      const instance = new ChartWidget(host, {
        symbol,
        ...(symbols?.length ? { symbols } : {}),
        timeframe,
        theme,
        adapter,
        historyLimit: HISTORY_BARS,
        trading,
        watchlist,
        locale,
        messages: { 'indicatorCategory.other': 'Strategy' },   // V5: no built-in is in "other": only the strategies of the table
        ...(ui ? { ui } : {}),
        // ChartWidget takes the starting chart type through chartOptions.
        chartOptions: {
          ...(numberLocale ? { numberLocale } : {}),
          ...(chartType ? { chartType } : {}),
        },
        onReady: (chart) => {
          for (const id of indicators) {
            chart.addIndicator(id, {});
          }
          chart.on('themeChange', () => remember(THEME_KEY, themeOf(host)));   // V5: kept for the next visit
          chart.on('timeframeChange', () => remember(TIMEFRAME_KEY, instance.getTimeframe()));
          if (!staticBars) {
            chart.plugins.register({ kind: 'overlay', plugin: forecastOverlay });   // V5: Kronos
            followForecasts(() => `${instance.getSymbol()}|${mt5Timeframe(instance.getTimeframe())}`, (bars) => {
              forecastBars = bars;   // [] for another pair: the old one is not drawn on it
              chart.requestRender();
            });
          }
          if (!staticBars) {   // V5: the strategies of the table, each an indicator of the picker
            getJson<StrategyRow[]>('/strategies')
              .then((strategies) => attachStrategies(chart, strategies))
              .catch((err) => console.warn('GET /strategies', err));
          }
        },
        onSymbolChange: (sym) => {
          remember(SYMBOL_KEY, sym);   // V5: kept for the next visit
          if (staticBars) instance.setData(generateBars(staticBars, sym));
        },
      });
      widget = instance;
      if (staticBars) instance.setData(generateBars(staticBars, symbol));
      // Dev-only handle for profiling the live widget from the console.
      if (import.meta.env.DEV) (window as unknown as { __tcWidget: unknown }).__tcWidget = widget;
    } catch (err) {
      if (host) {
        host.innerHTML = `<div style="padding:24px;color:#a1a1aa;font-family:monospace;">Failed to load widget: ${String(err)}</div>`;
      }
    }
}

void mountWidget(document.getElementById('chart') as HTMLDivElement);
