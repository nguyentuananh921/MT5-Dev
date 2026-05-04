//+------------------------------------------------------------------+
//|                                              L1VwapDisplay.mq5   |
//|   Self-contained EA: computes L1 Trend Filter (H1) and session   |
//|   VWAP (+/- SD bands) internally and draws them on the chart.    |
//| https://www.mql5.com/en/code/72316                               |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property version   "1.02"
#property strict

#include <Trade\Trade.mqh>

input double           InpQtScale       = 1.0;           // Quick trader UI scale
input double           InpQtDefaultVol  = 0.10;          // Default volume if none stored
input ulong            InpQtMagicBase   = 777000;        // Base magic (+slot N >= 1)
input ulong            InpQtDeviation   = 20;            // Quick trader slippage (points)

input bool             InpSclEnable     = true;          // Custom scale indicator on/off
input int              InpSclPriceTicks = 12;            // Target number of price labels
input int              InpSclTimeTicks  = 10;            // Target number of time labels
input int              InpSclFontSize   = 11;            // Scale label font size
input int              InpSclRightPad   = 6;             // Right label inset (px from right edge)
input int              InpSclBottomPad  = 5;             // Bottom label inset (px from bottom edge)

//--- Tokyo Night palette
#define TN_BLUE_LINE    (color)C'122,162,247'  // #7aa2f7
#define TN_ORANGE_LINE  (color)C'255,158,100'  // #ff9e64
#define TN_COMMENT      (color)C'86,95,137'    // #565f89 (dim bands)
#define TN_YELLOW       (color)C'224,175,104'  // #e0af68
#define TN_CYAN         (color)C'125,207,255'  // #7dcfff
#define TN_PURPLE2      (color)C'157,124,216'  // #9d7cd8 (prev close)
#define TN_TEAL         (color)C'115,218,202'  // #73daca (today open)
#define TN_DARK3        (color)C'84,92,126'    // #545c7e (SD bands)

input ENUM_TIMEFRAMES  InpL1Timeframe   = PERIOD_H1;            // L1 timeframe
input int              InpL1Bars        = 320;                  // L1 bars to calculate
input double           InpL1Lambda      = 0.015;                // L1 lambda coefficient
input int              InpL1Width       = 2;

input ENUM_TIMEFRAMES  InpVwapAnchor    = PERIOD_D1;            // VWAP anchor period
input int              InpVwapBars      = 1440;                 // VWAP bars back to draw (chart TF)
input double           InpVwapDeviation = 2.0;                  // VWAP SD deviation
input int              InpVwapWidth     = 2;
input int              InpPrevCloseWidth= 2;
input int              InpOpenWidth     = 2;

//--- Tokyo Night line colors (hard-coded, not user inputs)
const color InpL1Color        = TN_BLUE_LINE;
const color InpVwapColor      = TN_ORANGE_LINE;
const color InpVwapBandColor  = TN_DARK3;
const color InpVwapBand5Color = TN_COMMENT;
const color InpVwapBand8Color = (color)C'65,72,104';  // TN_BORDER (defined later)
const color InpPrevCloseColor = TN_PURPLE2;
const color InpOpenColor      = TN_TEAL;

const string L1_PREFIX       = "L1TF_seg_";
const string VWAP_PREFIX     = "VWAP_seg_";
const string VWAP_UP_PREFIX  = "VWAPU_seg_";
const string VWAP_LO_PREFIX  = "VWAPL_seg_";
const string VWAP_UP5_PREFIX = "VWAPU5_seg_";
const string VWAP_LO5_PREFIX = "VWAPL5_seg_";
const string VWAP_UP8_PREFIX = "VWAPU8_seg_";
const string VWAP_LO8_PREFIX = "VWAPL8_seg_";
const double InpVwapDeviation5 = 5.0;
const double InpVwapDeviation8 = 8.0;
const string VWAP_PREV_NAME  = "VWAP_prev_close";
const string VWAP_OPEN_NAME  = "VWAP_today_open";

const string LBL_L1   = "L1QT_RLBL_L1";
const string LBL_VWAP = "L1QT_RLBL_VWAP";
const string LBL_VUP  = "L1QT_RLBL_VUP";
const string LBL_VLO  = "L1QT_RLBL_VLO";
const string LBL_VUP5 = "L1QT_RLBL_VUP5";
const string LBL_VLO5 = "L1QT_RLBL_VLO5";
const string LBL_VUP8 = "L1QT_RLBL_VUP8";
const string LBL_VLO8 = "L1QT_RLBL_VLO8";
const string LBL_PC   = "L1QT_RLBL_PC";
const string LBL_TO   = "L1QT_RLBL_TO";
const string LBL_MID  = "L1QT_RLBL_MID";

const string SCL_PREFIX_P = "L1QT_SCLP_";   // price-axis labels
const string SCL_PREFIX_T = "L1QT_SCLT_";   // time-axis labels
const string TR_PREFIX    = "L1QT_TR_";     // open-trade labels (left side)
const string TR_BTN_PREFIX= "L1QT_TRBTN_";  // close-button next to each trade label
const int    SCL_MAX_P    = 40;             // label pool size (price)
const int    SCL_MAX_T    = 40;             // label pool size (time)
const int    TR_MAX       = 32;             // label pool size (trades)

//--- SCL dirty-check state: last geometry + ranges seen; if unchanged, skip repaint
int      g_scl_last_w    = -1;
int      g_scl_last_h    = -1;
double   g_scl_last_pmin = 0.0;
double   g_scl_last_pmax = 0.0;
int      g_scl_last_fvb  = -1;
int      g_scl_last_wb   = -1;

//--- RecalcAll throttle (SCL timer beats fast, RecalcAll must not)
uint     g_last_recalc_ms = 0;
const uint RECALC_PERIOD_MS = 2000;   // ~2s (same as prior OnTimer cadence)

//--- SclDraw entry throttle: clamp peak repaint rate. Event floods
//--- (CHART_CHANGE, MOUSE_MOVE) used to fire SclDraw hundreds of
//--- times/sec; ~30 ms cap = ~33 Hz, smooth to the eye, cheap on CPU.
uint     g_scl_last_paint_ms = 0;
const uint SCL_MIN_PAINT_MS  = 30;

//--- Label-exists flags: avoid ObjectFind() in the hot path
bool     g_scl_p_exists[40];   // == SCL_MAX_P
bool     g_scl_t_exists[40];   // == SCL_MAX_T
bool     g_tr_exists[32];      // == TR_MAX
bool     g_tr_btn_exists[32];  // == TR_MAX

//--- Open-trade label hash: detects position open/close/modify so
//--- SclDraw's dirty check can force a repaint on trade events.
long     g_tr_last_hash = -1;

//--- 1-Hz force-refresh state: ensures PnL in the trade labels
//--- ticks forward even when nothing else on the chart changed.
uint     g_scl_last_s   = 0;

//--- Per-cluster ticket table: click on the close button of cluster N
//--- closes every ticket recorded in row N. Up to 16 tickets/cluster.
ulong    g_tr_cluster_tickets[32][16];
int      g_tr_cluster_count  [32];

//--- Cached chart geometry: only changes on CHART_CHANGE. Avoids
//--- hammering CHART_HEIGHT_IN_PIXELS / FIRST_VISIBLE_BAR / etc.
//--- on every mouse tick.
bool     g_scl_geom_dirty = true;
int      g_scl_cw  = 0;
int      g_scl_ch  = 0;
int      g_scl_cfvb = 0;
int      g_scl_cwb  = 0;
bool     g_scl_cmax = true;  // chart maximized? -> full scale vs compact

double g_l1_last = EMPTY_VALUE;

datetime g_last_h1_time = 0;
datetime g_last_m_time  = 0;

//--- Quick Trader UI -----------------------------------------------
#define TN_BG      (color)C'26,27,38'
#define TN_PANEL   (color)C'36,40,59'
#define TN_BORDER  (color)C'65,72,104'
#define TN_FG      (color)C'192,202,245'
#define TN_GREEN   (color)C'158,206,106'
#define TN_RED     (color)C'247,118,142'
#define TN_ORANGE  (color)C'255,158,100'
#define TN_PURPLE  (color)C'187,154,247' // #bb9af7

string g_qt_prefix = "L1QT_";
string g_qt_buy    = "";
string g_qt_sell   = "";
string g_qt_edit   = "";
string g_qt_symlbl = "";
string g_qt_gvKey  = "";
double g_qt_volume = 0.10;
int    g_qt_slot   = 0;
ulong  g_qt_magic  = 0;
string g_qt_slotKey= "";
CTrade g_qt_trade;

union QtLongDouble { long lv; double dv; };

//+------------------------------------------------------------------+
double QtCidToDouble(long cid)  { QtLongDouble u; u.lv = cid; return u.dv; }
long   QtDoubleToCid(double dv) { QtLongDouble u; u.dv = dv; return u.lv; }

//+------------------------------------------------------------------+
int OnInit()
{
   //--- cleaner default: hide the built-in chart grid + volumes,
   //--- the ticker bar, and the one-click trading panel.
   ChartSetInteger(0, CHART_SHOW_GRID,        false);
   ChartSetInteger(0, CHART_SHOW_VOLUMES,     CHART_VOLUME_HIDE);
   ChartSetInteger(0, CHART_SHOW_TICKER,      false);
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK,   false);
   QtInit();
   SclInit();
   EventSetMillisecondTimer(80);   // fast beat for SCL repaints during drag/resize
   RecalcAll(true);
   g_last_recalc_ms = GetTickCount();
   SclDraw();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   SclDeinit();
   QtDeinit();
   long cid = ChartID();
   ObjectsDeleteAll(cid, L1_PREFIX,      0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_PREFIX,    0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_UP_PREFIX,  0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_LO_PREFIX,  0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_UP5_PREFIX, 0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_LO5_PREFIX, 0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_UP8_PREFIX, 0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_LO8_PREFIX, 0, OBJ_TREND);
   ObjectDelete(cid, VWAP_PREV_NAME);
   ObjectDelete(cid, VWAP_OPEN_NAME);
   ObjectDelete(cid, LBL_L1);
   ObjectDelete(cid, LBL_VWAP);
   ObjectDelete(cid, LBL_VUP);
   ObjectDelete(cid, LBL_VLO);
   ObjectDelete(cid, LBL_VUP5);
   ObjectDelete(cid, LBL_VLO5);
   ObjectDelete(cid, LBL_VUP8);
   ObjectDelete(cid, LBL_VLO8);
   ObjectDelete(cid, LBL_PC);
   ObjectDelete(cid, LBL_TO);
   ObjectDelete(cid, LBL_MID);
   ChartRedraw(cid);
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   QtOnChartEvent(id, lparam, dparam, sparam);
   //--- timeframe hotkeys: 1=M1 2=M5 3=M15 4=H1 5=H4 6=D1
   //---  ` (backtick) closes the chart
   if(id == CHARTEVENT_KEYDOWN)
   {
      if((int)lparam == 0xC0 || (int)lparam == '`')
      {
         ChartClose(0);
         return;
      }
      //--- A / D: zoom in / out (CHART_SCALE is 0..5)
      if((int)lparam == 'A' || (int)lparam == 'D')
      {
         int s = (int)ChartGetInteger(0, CHART_SCALE);
         s += ((int)lparam == 'A') ? 1 : -1;
         if(s < 0) s = 0;
         if(s > 5) s = 5;
         ChartSetInteger(0, CHART_SCALE, s);
         g_scl_geom_dirty = true;
         return;
      }
      //--- Q / E: cycle to previous / next chart tab
      if((int)lparam == 'Q' || (int)lparam == 'E')
      {
         long me = ChartID();
         long ids[];
         int  cnt = 0;
         long it = ChartFirst();
         while(it >= 0)
         {
            ArrayResize(ids, cnt + 1);
            ids[cnt++] = it;
            it = ChartNext(it);
         }
         int myIdx = -1;
         for(int i = 0; i < cnt; i++) if(ids[i] == me) { myIdx = i; break; }
         if(myIdx >= 0 && cnt > 1)
         {
            int tgt = ((int)lparam == 'Q') ? myIdx - 1 : myIdx + 1;
            if(tgt >= 0 && tgt < cnt)
               ChartSetInteger(ids[tgt], CHART_BRING_TO_TOP, 0, true);
         }
         return;
      }
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)-1;
      switch((int)lparam)
      {
         case '1': case 0x61: tf = PERIOD_M1;  break;
         case '2': case 0x62: tf = PERIOD_M5;  break;
         case '3': case 0x63: tf = PERIOD_M15; break;
         case '4': case 0x64: tf = PERIOD_H1;  break;
         case '5': case 0x65: tf = PERIOD_H4;  break;
         case '6': case 0x66: tf = PERIOD_D1;  break;
      }
      if(tf != (ENUM_TIMEFRAMES)-1 && tf != _Period)
      {
         ChartSetSymbolPeriod(0, _Symbol, tf);
         g_scl_geom_dirty = true;
      }
   }
   //--- Close-button click on a trade label: close every ticket in that cluster.
   if(id == CHARTEVENT_OBJECT_CLICK && StringFind(sparam, TR_BTN_PREFIX) == 0)
   {
      string tail = StringSubstr(sparam, StringLen(TR_BTN_PREFIX));
      int    idx  = (int)StringToInteger(tail);
      if(idx >= 0 && idx < TR_MAX)
      {
         int cnt = g_tr_cluster_count[idx];
         for(int k = 0; k < cnt; k++)
         {
            ulong tk = g_tr_cluster_tickets[idx][k];
            if(tk != 0) g_qt_trade.PositionClose(tk);
         }
      }
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      g_tr_last_hash   = -1;   // force label repaint
      g_scl_geom_dirty = true;
      SclDraw();
      return;
   }
   if(id == CHARTEVENT_CHART_CHANGE) { g_scl_geom_dirty = true; SclDraw(); }
   //--- MOUSE_MOVE makes the price-axis responsive while user drags the
   //--- vertical scale (CHART_CHANGE fires only at gesture end). The
   //--- dirty check in SclDraw() suppresses no-op repaints.
   if(id == CHARTEVENT_MOUSE_MOVE)   SclDraw();
}

//+------------------------------------------------------------------+
void OnTimer()
{
   //--- Fast beat (80 ms): SCL repaints when dirty, RecalcAll throttled to ~2 s
   SclDraw();
   uint now = GetTickCount();
   if(now - g_last_recalc_ms >= RECALC_PERIOD_MS)
   {
      RecalcAll(false);
      g_last_recalc_ms = now;
   }
}
void OnTick()   { RecalcAll(false); }

//+------------------------------------------------------------------+
void RecalcAll(bool force)
{
   datetime h1t[1], mt[1];
   if(CopyTime(_Symbol, InpL1Timeframe, 0, 1, h1t) > 0)
   {
      if(force || h1t[0] != g_last_h1_time)
      {
         DrawL1();
         g_last_h1_time = h1t[0];
      }
   }
   if(CopyTime(_Symbol, _Period, 0, 1, mt) > 0)
   {
      if(force || mt[0] != g_last_m_time)
      {
         DrawVwap();
         g_last_m_time = mt[0];
      }
   }
}

//+------------------------------------------------------------------+
//| L1 Trend Filter on H1 using vector<double>::L1TrendFilter        |
//+------------------------------------------------------------------+
void DrawL1()
{
   int n = InpL1Bars;
   double closes[];
   datetime times[];

   if(CopyClose(_Symbol, InpL1Timeframe, 0, n, closes) != n) return;
   if(CopyTime (_Symbol, InpL1Timeframe, 0, n, times ) != n) return;

   vector<double> data;
   data.Resize(n);
   for(int i = 0; i < n; i++) data[i] = closes[i];

   vector<double> filtered;
   filtered.Resize(n);
   if(!data.L1TrendFilter(InpL1Lambda, true, filtered)) return;

   g_l1_last = filtered[n - 1];

   long cid = ChartID();
   ObjectsDeleteAll(cid, L1_PREFIX, 0, OBJ_TREND);

   for(int i = 0; i < n - 1; i++)
   {
      double v1 = filtered[i];
      double v2 = filtered[i + 1];
      if(!MathIsValidNumber(v1) || !MathIsValidNumber(v2)) continue;

      string name = L1_PREFIX + IntegerToString(i);
      if(!ObjectCreate(cid, name, OBJ_TREND, 0, times[i], v1, times[i + 1], v2))
         continue;
      ObjectSetInteger(cid, name, OBJPROP_COLOR,      InpL1Color);
      ObjectSetInteger(cid, name, OBJPROP_WIDTH,      InpL1Width);
      ObjectSetInteger(cid, name, OBJPROP_STYLE,      STYLE_SOLID);
      ObjectSetInteger(cid, name, OBJPROP_RAY_RIGHT,  false);
      ObjectSetInteger(cid, name, OBJPROP_RAY_LEFT,   false);
      ObjectSetInteger(cid, name, OBJPROP_BACK,       true);
      ObjectSetInteger(cid, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(cid, name, OBJPROP_HIDDEN,     true);
   }
   ChartRedraw(cid);
}

//+------------------------------------------------------------------+
bool IsSessionBoundary(const datetime &time[], int i, ENUM_TIMEFRAMES anchor)
{
   if(i <= 0) return false;
   MqlDateTime t1, t2;
   TimeToStruct(time[i],     t1);
   TimeToStruct(time[i - 1], t2);
   if(anchor == PERIOD_D1  && t1.day != t2.day)              return true;
   if(anchor == PERIOD_W1  && t1.day_of_week < t2.day_of_week) return true;
   if(anchor == PERIOD_MN1 && t1.mon != t2.mon)              return true;
   return false;
}

//+------------------------------------------------------------------+
//| Session VWAP + SD bands on chart timeframe                       |
//+------------------------------------------------------------------+
void DrawVwap()
{
   if(PeriodSeconds(_Period) >= PeriodSeconds(InpVwapAnchor)) return;

   int n = InpVwapBars;
   datetime time[]; double high[], low[], close[]; long tvol[];
   if(CopyTime      (_Symbol, _Period, 0, n, time ) != n) return;
   if(CopyHigh      (_Symbol, _Period, 0, n, high ) != n) return;
   if(CopyLow       (_Symbol, _Period, 0, n, low  ) != n) return;
   if(CopyClose     (_Symbol, _Period, 0, n, close) != n) return;
   if(CopyTickVolume(_Symbol, _Period, 0, n, tvol ) != n) return;

   double vwap[], upper[], lower[], upper5[], lower5[], upper8[], lower8[], tp[];
   ArrayResize(vwap,  n);
   ArrayResize(upper, n);
   ArrayResize(lower, n);
   ArrayResize(upper5,n);
   ArrayResize(lower5,n);
   ArrayResize(upper8,n);
   ArrayResize(lower8,n);
   ArrayResize(tp,    n);

   double cum_vol = 0.0, cum_pv = 0.0;
   double prev_close_vwap   = EMPTY_VALUE;
   double today_open_vwap   = EMPTY_VALUE;
   datetime current_session_start = 0;

   for(int i = 0; i < n; i++)
   {
      bool new_session = (i == 0) || IsSessionBoundary(time, i, InpVwapAnchor);
      if(new_session)
      {
         if(i > 0) prev_close_vwap = vwap[i - 1];
         current_session_start = time[i];
         today_open_vwap = EMPTY_VALUE;
         cum_vol = 0.0; cum_pv = 0.0;
      }

      double t = (high[i] + low[i] + close[i]) / 3.0;
      double v = (double)tvol[i];

      cum_vol += v;
      cum_pv  += t * v;
      tp[i]    = t;
      vwap[i]  = (cum_vol > 0.0) ? cum_pv / cum_vol : t;
      if(today_open_vwap == EMPTY_VALUE) today_open_vwap = vwap[i];

      double variance = 0.0;
      int    count    = 0;
      for(int j = i; j >= 0; j--)
      {
         double d = tp[j] - vwap[i];
         variance += d * d;
         count++;
         if(j == 0) break;
         if(IsSessionBoundary(time, j, InpVwapAnchor)) break;
      }
      double sd = (count > 0) ? MathSqrt(variance / count) : 0.0;
      upper [i] = vwap[i] + sd * InpVwapDeviation;
      lower [i] = vwap[i] - sd * InpVwapDeviation;
      upper5[i] = vwap[i] + sd * InpVwapDeviation5;
      lower5[i] = vwap[i] - sd * InpVwapDeviation5;
      upper8[i] = vwap[i] + sd * InpVwapDeviation8;
      lower8[i] = vwap[i] - sd * InpVwapDeviation8;
   }

   long cid = ChartID();
   ObjectsDeleteAll(cid, VWAP_PREFIX,     0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_UP_PREFIX,  0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_LO_PREFIX,  0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_UP5_PREFIX, 0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_LO5_PREFIX, 0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_UP8_PREFIX, 0, OBJ_TREND);
   ObjectsDeleteAll(cid, VWAP_LO8_PREFIX, 0, OBJ_TREND);
   ObjectDelete(cid, VWAP_PREV_NAME);
   ObjectDelete(cid, VWAP_OPEN_NAME);

   for(int i = 0; i < n - 1; i++)
   {
      bool brk = IsSessionBoundary(time, i + 1, InpVwapAnchor);
      if(brk) continue;

      DrawSeg(cid, VWAP_PREFIX     + IntegerToString(i), time[i], vwap  [i], time[i + 1], vwap  [i + 1], InpVwapColor,      InpVwapWidth, STYLE_SOLID);
      DrawSeg(cid, VWAP_UP_PREFIX  + IntegerToString(i), time[i], upper [i], time[i + 1], upper [i + 1], InpVwapBandColor,  1,            STYLE_DASH);
      DrawSeg(cid, VWAP_LO_PREFIX  + IntegerToString(i), time[i], lower [i], time[i + 1], lower [i + 1], InpVwapBandColor,  1,            STYLE_DASH);
      DrawSeg(cid, VWAP_UP5_PREFIX + IntegerToString(i), time[i], upper5[i], time[i + 1], upper5[i + 1], InpVwapBand5Color, 1,            STYLE_DOT);
      DrawSeg(cid, VWAP_LO5_PREFIX + IntegerToString(i), time[i], lower5[i], time[i + 1], lower5[i + 1], InpVwapBand5Color, 1,            STYLE_DOT);
      DrawSeg(cid, VWAP_UP8_PREFIX + IntegerToString(i), time[i], upper8[i], time[i + 1], upper8[i + 1], InpVwapBand8Color, 1,            STYLE_DOT);
      DrawSeg(cid, VWAP_LO8_PREFIX + IntegerToString(i), time[i], lower8[i], time[i + 1], lower8[i + 1], InpVwapBand8Color, 1,            STYLE_DOT);
   }

   //--- previous session closing VWAP line, across current session
   if(prev_close_vwap != EMPTY_VALUE && current_session_start > 0)
   {
      DrawSeg(cid, VWAP_PREV_NAME,
              current_session_start, prev_close_vwap,
              time[n - 1],           prev_close_vwap,
              InpPrevCloseColor, InpPrevCloseWidth, STYLE_DASH);
   }

   //--- current session opening VWAP line, across current session
   if(today_open_vwap != EMPTY_VALUE && current_session_start > 0)
   {
      DrawSeg(cid, VWAP_OPEN_NAME,
              current_session_start, today_open_vwap,
              time[n - 1],           today_open_vwap,
              InpOpenColor, InpOpenWidth, STYLE_DASH);
   }

   //--- right-side price labels ---------------------------------------
   datetime t_lbl = time[n - 1] + 3 * PeriodSeconds(_Period);
   int d = (int)_Digits;

   QtRightLabel(LBL_VWAP, t_lbl, vwap  [n - 1], InpVwapColor,      DoubleToString(vwap  [n - 1], d));
   QtRightLabel(LBL_VUP,  t_lbl, upper [n - 1], InpVwapBandColor,  DoubleToString(upper [n - 1], d));
   QtRightLabel(LBL_VLO,  t_lbl, lower [n - 1], InpVwapBandColor,  DoubleToString(lower [n - 1], d));
   QtRightLabel(LBL_VUP5, t_lbl, upper5[n - 1], InpVwapBand5Color, DoubleToString(upper5[n - 1], d));
   QtRightLabel(LBL_VLO5, t_lbl, lower5[n - 1], InpVwapBand5Color, DoubleToString(lower5[n - 1], d));
   QtRightLabel(LBL_VUP8, t_lbl, upper8[n - 1], InpVwapBand8Color, DoubleToString(upper8[n - 1], d));
   QtRightLabel(LBL_VLO8, t_lbl, lower8[n - 1], InpVwapBand8Color, DoubleToString(lower8[n - 1], d));

   if(g_l1_last != EMPTY_VALUE)
      QtRightLabel(LBL_L1, t_lbl, g_l1_last, InpL1Color, DoubleToString(g_l1_last, d));

   double sd_now = (InpVwapDeviation > 0.0) ? (upper[n - 1] - vwap[n - 1]) / InpVwapDeviation : 0.0;
   bool   hasPC  = (prev_close_vwap != EMPTY_VALUE);
   bool   hasTO  = (today_open_vwap != EMPTY_VALUE);

   if(hasPC && hasTO && MathAbs(prev_close_vwap - today_open_vwap) <= sd_now)
   {
      ObjectDelete(cid, LBL_PC);
      ObjectDelete(cid, LBL_TO);
      double mid = 0.5 * (prev_close_vwap + today_open_vwap);
      QtRightLabel(LBL_MID, t_lbl, mid, InpOpenColor, DoubleToString(mid, d));
   }
   else
   {
      ObjectDelete(cid, LBL_MID);
      if(hasPC) QtRightLabel(LBL_PC, t_lbl, prev_close_vwap, InpPrevCloseColor, DoubleToString(prev_close_vwap, d));
      else      ObjectDelete(cid, LBL_PC);
      if(hasTO) QtRightLabel(LBL_TO, t_lbl, today_open_vwap, InpOpenColor,      DoubleToString(today_open_vwap, d));
      else      ObjectDelete(cid, LBL_TO);
   }

   ChartRedraw(cid);
}

//+------------------------------------------------------------------+
void QtRightLabel(const string name, datetime t, double price, color clr, const string text)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   ObjectMove(0, name, 0, t, price);
   ObjectSetString (0, name, OBJPROP_TEXT,       text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,     ANCHOR_LEFT);
   ObjectSetString (0, name, OBJPROP_FONT,       "Consolas");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   9);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
}

//+------------------------------------------------------------------+
void DrawSeg(long cid, string name, datetime t1, double p1, datetime t2, double p2,
             color clr, int width, ENUM_LINE_STYLE style)
{
   if(!MathIsValidNumber(p1) || !MathIsValidNumber(p2)) return;
   if(!ObjectCreate(cid, name, OBJ_TREND, 0, t1, p1, t2, p2)) return;
   ObjectSetInteger(cid, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(cid, name, OBJPROP_WIDTH,      width);
   ObjectSetInteger(cid, name, OBJPROP_STYLE,      style);
   ObjectSetInteger(cid, name, OBJPROP_RAY_RIGHT,  false);
   ObjectSetInteger(cid, name, OBJPROP_RAY_LEFT,   false);
   ObjectSetInteger(cid, name, OBJPROP_BACK,       true);
   ObjectSetInteger(cid, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(cid, name, OBJPROP_HIDDEN,     true);
}

//+==================================================================+
//|                        Quick Trader Panel                        |
//+==================================================================+
void QtInit()
{
   g_qt_prefix = StringFormat("L1QT_%I64u_", ChartID());
   g_qt_buy    = g_qt_prefix+"BUY";
   g_qt_sell   = g_qt_prefix+"SELL";
   g_qt_edit   = g_qt_prefix+"VOL";
   g_qt_symlbl = g_qt_prefix+"SYM";
   g_qt_gvKey  = StringFormat("L1QT_VOL_%s", _Symbol);

   if(GlobalVariableCheck(g_qt_gvKey))
      g_qt_volume = GlobalVariableGet(g_qt_gvKey);
   else
      g_qt_volume = InpQtDefaultVol;
   g_qt_volume = QtNormalizeVolume(g_qt_volume);

   QtAcquireSlot();
   QtApplyChartColors();

   g_qt_trade.SetExpertMagicNumber(g_qt_magic);
   g_qt_trade.SetDeviationInPoints(InpQtDeviation);
   g_qt_trade.SetTypeFillingBySymbol(_Symbol);
   PrintFormat("L1QT: acquired magic slot %d -> magic=%I64u", g_qt_slot, g_qt_magic);

   QtBuildUI();
   ChartRedraw();
}

//+------------------------------------------------------------------+
void QtDeinit()
{
   GlobalVariableSet(g_qt_gvKey, g_qt_volume);
   QtReleaseSlot();
   ObjectsDeleteAll(0, g_qt_prefix);
}

//+------------------------------------------------------------------+
//| Is chart id currently open in this terminal?                     |
//+------------------------------------------------------------------+
bool QtChartIsOpen(long cid)
{
   long c = ChartFirst();
   while(c >= 0)
   {
      if(c == cid) return true;
      c = ChartNext(c);
   }
   return false;
}

//+------------------------------------------------------------------+
//| Acquire lowest-free slot number across terminal (auto magic)     |
//| Registry: GlobalVariableTemp("L1QT_SLOT_<n>") = owner ChartID    |
//+------------------------------------------------------------------+
void QtAcquireSlot()
{
   long   myCid = ChartID();
   double myVal = QtCidToDouble(myCid);

   for(int slot = 1; slot <= 4096; slot++)
   {
      string key = StringFormat("L1QT_SLOT_%d", slot);

      //--- Slot not yet created: create as temp (value 0) then atomically claim
      if(!GlobalVariableCheck(key))
      {
         GlobalVariableTemp(key); // idempotent; creates with 0.0 if missing
         if(GlobalVariableSetOnCondition(key, myVal, 0.0))
         {
            g_qt_slot    = slot;
            g_qt_slotKey = key;
            g_qt_magic   = InpQtMagicBase + (ulong)slot;
            return;
         }
         // someone else won the race; re-read owner below
      }

      //--- Already owned: by me, or stale (owner chart closed)
      double cur   = GlobalVariableGet(key);
      long   owner = QtDoubleToCid(cur);

      if(owner == myCid)
      {
         g_qt_slot    = slot;
         g_qt_slotKey = key;
         g_qt_magic   = InpQtMagicBase + (ulong)slot;
         return;
      }

      if(!QtChartIsOpen(owner))
      {
         if(GlobalVariableSetOnCondition(key, myVal, cur))
         {
            g_qt_slot    = slot;
            g_qt_slotKey = key;
            g_qt_magic   = InpQtMagicBase + (ulong)slot;
            return;
         }
      }
   }
   g_qt_slot    = 1;
   g_qt_slotKey = "";
   g_qt_magic   = InpQtMagicBase + 1;
}

//+------------------------------------------------------------------+
//| Apply Tokyo Night palette to the chart                           |
//+------------------------------------------------------------------+
void QtApplyChartColors()
{
   long cid = ChartID();
   ChartSetInteger(cid, CHART_COLOR_BACKGROUND, TN_BG);
   ChartSetInteger(cid, CHART_COLOR_FOREGROUND, TN_FG);
   ChartSetInteger(cid, CHART_COLOR_GRID,       TN_BORDER);

   ChartSetInteger(cid, CHART_COLOR_CHART_UP,   TN_FG);
   ChartSetInteger(cid, CHART_COLOR_CHART_DOWN, TN_FG);
   ChartSetInteger(cid, CHART_COLOR_CHART_LINE, TN_FG);
   ChartSetInteger(cid, CHART_COLOR_CANDLE_BULL,TN_FG);
   ChartSetInteger(cid, CHART_COLOR_CANDLE_BEAR,TN_FG);

   ChartSetInteger(cid, CHART_COLOR_VOLUME,     TN_COMMENT);

   ChartSetInteger(cid, CHART_COLOR_BID,        TN_CYAN);
   ChartSetInteger(cid, CHART_COLOR_ASK,        TN_ORANGE_LINE);
   ChartSetInteger(cid, CHART_COLOR_LAST,       TN_YELLOW);
   ChartSetInteger(cid, CHART_COLOR_STOP_LEVEL, TN_PURPLE);

   ChartSetInteger(cid, CHART_SHOW_BID_LINE, true);
   ChartSetInteger(cid, CHART_SHOW_ASK_LINE, true);
}

//+------------------------------------------------------------------+
void QtReleaseSlot()
{
   if(StringLen(g_qt_slotKey) == 0) return;
   if(GlobalVariableCheck(g_qt_slotKey))
   {
      long owner = QtDoubleToCid(GlobalVariableGet(g_qt_slotKey));
      if(owner == ChartID())
         GlobalVariableDel(g_qt_slotKey);
   }
   g_qt_slotKey = "";
}

//+------------------------------------------------------------------+
double QtNormalizeVolume(double vol)
{
   double vmin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double vstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(vstep <= 0) vstep = 0.01;
   if(vol < vmin) vol = vmin;
   if(vol > vmax) vol = vmax;
   vol = MathRound(vol / vstep) * vstep;
   int digits = 2;
   if(vstep >= 1.0) digits = 0;
   else if(vstep >= 0.1) digits = 1;
   return NormalizeDouble(vol, digits);
}

//+------------------------------------------------------------------+
string QtFormatVolume(double vol)
{
   double vstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int digits = 2;
   if(vstep >= 1.0) digits = 0;
   else if(vstep >= 0.1) digits = 1;
   return DoubleToString(vol, digits);
}

//+------------------------------------------------------------------+
void QtCreateButton(const string name, int x, int y, int w, int h,
                    const string text, color bg, color fg)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     h);
   ObjectSetString (0, name, OBJPROP_TEXT,      text);
   ObjectSetString (0, name, OBJPROP_FONT,      "Consolas");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  (int)MathMax(8, 11*InpQtScale));
   ObjectSetInteger(0, name, OBJPROP_COLOR,     fg);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,   bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, TN_BORDER);
   ObjectSetInteger(0, name, OBJPROP_BACK,      false);
   ObjectSetInteger(0, name, OBJPROP_STATE,     false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,    10);
}

//+------------------------------------------------------------------+
void QtCreateEdit(const string name, int x, int y, int w, int h, const string text)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     h);
   ObjectSetString (0, name, OBJPROP_TEXT,      text);
   ObjectSetString (0, name, OBJPROP_FONT,      "Consolas");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  (int)MathMax(8, 11*InpQtScale));
   ObjectSetInteger(0, name, OBJPROP_COLOR,     TN_ORANGE);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,   TN_PANEL);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, TN_BORDER);
   ObjectSetInteger(0, name, OBJPROP_ALIGN,     ALIGN_CENTER);
   ObjectSetInteger(0, name, OBJPROP_READONLY,  false);
   ObjectSetInteger(0, name, OBJPROP_BACK,      false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,    10);
}

//+------------------------------------------------------------------+
void QtCreateSymbolLabel()
{
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int pad    = (int)MathMax(4, 6*InpQtScale);
   int fsize  = (int)MathMax(10, 16*InpQtScale);

   string symDisplay = _Symbol;
   int cashPos = StringFind(symDisplay, ".cash");
   if(cashPos >= 0 && cashPos == StringLen(symDisplay) - 5)
      symDisplay = StringSubstr(symDisplay, 0, cashPos);

   //--- OBJ_EDIT (opaque plate) instead of OBJ_LABEL to mask residue
   //--- pixels from the previously active chart during Q/E switching.
   int charW = (int)MathMax(8, fsize * 0.85);
   int w     = StringLen(symDisplay) * charW + 16;
   int h     = fsize + 10;

   //--- If an older OBJ_LABEL version exists, delete it so the new
   //--- OBJ_EDIT can take its name.
   if(ObjectFind(0, g_qt_symlbl) >= 0 &&
      (ENUM_OBJECT)ObjectGetInteger(0, g_qt_symlbl, OBJPROP_TYPE) != OBJ_EDIT)
      ObjectDelete(0, g_qt_symlbl);

   if(ObjectFind(0, g_qt_symlbl) < 0)
      ObjectCreate(0, g_qt_symlbl, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_CORNER,       CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_XDISTANCE,    chartW/2 - w/2);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_YDISTANCE,    pad);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_XSIZE,        w);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_YSIZE,        h);
   ObjectSetString (0, g_qt_symlbl, OBJPROP_TEXT,         symDisplay);
   ObjectSetString (0, g_qt_symlbl, OBJPROP_FONT,         "Consolas");
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_FONTSIZE,     fsize);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_ALIGN,        ALIGN_CENTER);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_READONLY,     true);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_COLOR,        TN_PURPLE);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_BGCOLOR,      TN_BG);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_BORDER_COLOR, TN_BG);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_BACK,         false);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_HIDDEN,       true);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, g_qt_symlbl, OBJPROP_ZORDER,       11);
}

//+------------------------------------------------------------------+
void QtBuildUI()
{
   int pad   = (int)MathMax(4, 6*InpQtScale);
   int btnW  = (int)(90*InpQtScale);
   int btnH  = (int)(46*InpQtScale);
   int editW = (int)(90*InpQtScale);

   int x0 = pad;
   int y0 = pad;

   int xBuy  = x0;
   int xEdit = xBuy + btnW + pad;
   int xSell = xEdit + editW + pad;

   QtCreateButton(g_qt_buy,  xBuy,  y0, btnW, btnH, "BUY",  TN_GREEN, TN_BG);
   QtCreateEdit  (g_qt_edit, xEdit, y0, editW, btnH, QtFormatVolume(g_qt_volume));
   QtCreateButton(g_qt_sell, xSell, y0, btnW, btnH, "SELL", TN_RED,   TN_BG);
   QtCreateSymbolLabel();
}

//+------------------------------------------------------------------+
void QtOnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      QtBuildUI();
      ChartRedraw();
      return;
   }

   if(id == CHARTEVENT_OBJECT_ENDEDIT && sparam == g_qt_edit)
   {
      string t = ObjectGetString(0, g_qt_edit, OBJPROP_TEXT);
      StringReplace(t, ",", ".");
      double v = StringToDouble(t);
      if(v <= 0.0) v = g_qt_volume;
      g_qt_volume = QtNormalizeVolume(v);
      GlobalVariableSet(g_qt_gvKey, g_qt_volume);
      ObjectSetString(0, g_qt_edit, OBJPROP_TEXT, QtFormatVolume(g_qt_volume));
      ChartRedraw();
      return;
   }

   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == g_qt_buy)
      {
         ObjectSetInteger(0, g_qt_buy, OBJPROP_STATE, false);
         QtDoTrade(true);
         ChartRedraw();
         return;
      }
      if(sparam == g_qt_sell)
      {
         ObjectSetInteger(0, g_qt_sell, OBJPROP_STATE, false);
         QtDoTrade(false);
         ChartRedraw();
         return;
      }
   }
}

//+------------------------------------------------------------------+
void QtDoTrade(bool isBuy)
{
   double vol = QtNormalizeVolume(g_qt_volume);
   if(vol <= 0.0)
   {
      Print("L1QT: invalid volume");
      return;
   }
   bool ok = isBuy
             ? g_qt_trade.Buy (vol, _Symbol, 0.0, 0.0, 0.0, "L1QT")
             : g_qt_trade.Sell(vol, _Symbol, 0.0, 0.0, 0.0, "L1QT");
   if(!ok)
      PrintFormat("L1QT: order failed ret=%u %s",
                  g_qt_trade.ResultRetcode(),
                  g_qt_trade.ResultRetcodeDescription());
}

//+==================================================================+
//|                   Custom Scale Indicator (SCL)                   |
//|                                                                  |
//| Overwrites MT5's native price/time axes. Keeps the gutter space  |
//| by setting CHART_COLOR_FOREGROUND = CLR_NONE (native scale labels |
//| vanish, pixel space remains). Draws its own big round-number     |
//| labels in their place. Redraws on CHART_CHANGE + OnTimer.        |
//|                                                                  |
//| v1: static strips locked to right/bottom edges. v2 hook points:  |
//|     SclDraw() is idempotent + reads CHART_WIDTH/HEIGHT each call, |
//|     so a later drag/resize layer just needs to mutate the strip  |
//|     width/height state and call SclDraw().                       |
//+==================================================================+
void SclInit()
{
   if(!InpSclEnable) return;
   long cid = ChartID();
   //--- Hide native scale text but keep the gutter pixel space.
   //--- This is what the user asked for: foreground = none.
   ChartSetInteger(cid, CHART_COLOR_FOREGROUND, CLR_NONE);
   ChartSetInteger(cid, CHART_SHOW_PRICE_SCALE, true);
   ChartSetInteger(cid, CHART_SHOW_DATE_SCALE,  true);
   //--- Need live mouse-move events so the price labels repaint
   //--- smoothly while the user drags the vertical scale.
   //--- CHART_CHANGE alone fires only at gesture end.
   ChartSetInteger(cid, CHART_EVENT_MOUSE_MOVE, true);
}

//+------------------------------------------------------------------+
void SclDeinit()
{
   long cid = ChartID();
   ObjectsDeleteAll(cid, SCL_PREFIX_P);
   ObjectsDeleteAll(cid, SCL_PREFIX_T);
   ObjectsDeleteAll(cid, TR_PREFIX);
   ObjectsDeleteAll(cid, TR_BTN_PREFIX);
   ArrayInitialize(g_scl_p_exists,  false);
   ArrayInitialize(g_scl_t_exists,  false);
   ArrayInitialize(g_tr_exists,     false);
   ArrayInitialize(g_tr_btn_exists, false);
   ArrayInitialize(g_tr_cluster_count, 0);
   g_tr_last_hash = -1;
   //--- Restore foreground color so the chart is usable without the EA
   ChartSetInteger(cid, CHART_COLOR_FOREGROUND, TN_FG);
   ChartRedraw(cid);
}

//+------------------------------------------------------------------+
//| Nice-number step: snap raw step to { 1, 2, 2.5, 5 } x 10^k       |
//+------------------------------------------------------------------+
double SclNiceStep(double raw)
{
   if(raw <= 0.0) return 1.0;
   double exp10 = MathFloor(MathLog10(raw));
   double pow10 = MathPow(10.0, exp10);
   double f     = raw / pow10; // in [1, 10)
   double nice;
   if(f < 1.5)      nice = 1.0;
   else if(f < 3.0) nice = 2.0;
   else if(f < 4.0) nice = 2.5;
   else if(f < 7.0) nice = 5.0;
   else             nice = 10.0;
   return nice * pow10;
}

//+------------------------------------------------------------------+
//| Time-axis nice step in seconds, bucketed to avoid ugly intervals |
//+------------------------------------------------------------------+
long SclNiceTimeStep(long rawSec)
{
   static long buckets[] = {
      60, 120, 300, 600, 900, 1800,                    // 1..30 min
      3600, 7200, 10800, 14400, 21600, 43200,          // 1..12 h
      86400, 172800, 604800, 1209600, 2592000          // 1d..1mo
   };
   int n = ArraySize(buckets);
   for(int i = 0; i < n; i++)
      if(buckets[i] >= rawSec) return buckets[i];
   return buckets[n - 1];
}

//+------------------------------------------------------------------+
int SclDigitsForStep(double step)
{
   if(step >= 1.0) return 0;
   int d = (int)MathMax(0.0, MathCeil(-MathLog10(step)));
   if(d > 8) d = 8;
   return d;
}

//+------------------------------------------------------------------+
//| Create-or-update an OBJ_LABEL (pixel-anchored to a chart corner) |
//| existsFlag: pointer-style via reference, avoids ObjectFind() in  |
//| the hot path (ObjectFind was ~12% of CPU in profiling).          |
//+------------------------------------------------------------------+
void SclLabel(const string name, int corner, int anchor,
              int x, int y, const string text, color clr, int fsize,
              bool &existsFlag)
{
   if(!existsFlag)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetString (0, name, OBJPROP_FONT,         "Consolas");
      ObjectSetInteger(0, name, OBJPROP_BACK,         false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
      ObjectSetInteger(0, name, OBJPROP_ZORDER,       5);
      existsFlag = true;
   }
   ObjectSetInteger(0, name, OBJPROP_CORNER,       corner);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,       anchor);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,    x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,    y);
   ObjectSetString (0, name, OBJPROP_TEXT,         text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,     fsize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,        clr);
}

//+------------------------------------------------------------------+
//| Park unused labels offscreen, driven by exists flags - no ObjectFind
//+------------------------------------------------------------------+
void SclHide(const string prefix, bool &flags[], int fromIdx, int toIdx)
{
   for(int i = fromIdx; i < toIdx; i++)
   {
      if(!flags[i]) continue;
      string n = prefix + IntegerToString(i);
      ObjectSetInteger(0, n, OBJPROP_YDISTANCE, -10000); // park offscreen
   }
}

//+------------------------------------------------------------------+
//| Main draw: called on CHART_CHANGE and from OnTimer               |
//+------------------------------------------------------------------+
void SclDraw()
{
   if(!InpSclEnable) return;

   //--- Entry throttle: cheapest first check. Collapses event floods.
   uint nowMs = GetTickCount();
   if(nowMs - g_scl_last_paint_ms < SCL_MIN_PAINT_MS) return;
   g_scl_last_paint_ms = nowMs;

   long   cid = ChartID();
   //--- Geometry is cached and refreshed only on CHART_CHANGE. Skips
   //--- 4 ChartGetInteger IPC roundtrips per MOUSE_MOVE (was ~22% CPU).
   if(g_scl_geom_dirty)
   {
      g_scl_cw   = (int)ChartGetInteger(cid, CHART_WIDTH_IN_PIXELS);
      g_scl_ch   = (int)ChartGetInteger(cid, CHART_HEIGHT_IN_PIXELS, 0);
      g_scl_cfvb = (int)ChartGetInteger(cid, CHART_FIRST_VISIBLE_BAR);
      g_scl_cwb  = (int)ChartGetInteger(cid, CHART_WIDTH_IN_BARS);
      g_scl_cmax = (bool)ChartGetInteger(cid, CHART_IS_MAXIMIZED);
      g_scl_geom_dirty = false;
   }
   int    w   = g_scl_cw;
   int    h   = g_scl_ch;
   int    fvb = g_scl_cfvb;
   int    wb  = g_scl_cwb;
   bool   tiled = !g_scl_cmax;
   //--- Price range still polled every paint: changes during vertical
   //--- scale drag WITHOUT CHART_CHANGE firing.
   double pmin = ChartGetDouble(cid, CHART_PRICE_MIN, 0);
   double pmax = ChartGetDouble(cid, CHART_PRICE_MAX, 0);
   if(w <= 0 || h <= 0 || pmax <= pmin) return;

   //--- Position-list hash: includes ticket + price + volume so any
   //--- open/close/partial-close/modify forces a repaint.
   long trHash = TrComputeHash();

   //--- 1-Hz pulse so PnL text ticks even when everything else is idle
   uint curS = nowMs / 1000;

   //--- Dirty check: skip repaint if nothing visible changed AND the
   //--- PnL second marker is still the same. Keeps the 80 ms timer
   //--- cheap while the chart is idle.
   if(w    == g_scl_last_w    && h   == g_scl_last_h   &&
      pmin == g_scl_last_pmin && pmax == g_scl_last_pmax &&
      fvb  == g_scl_last_fvb  && wb  == g_scl_last_wb   &&
      trHash == g_tr_last_hash && curS == g_scl_last_s)
      return;
   g_scl_last_w = w; g_scl_last_h = h;
   g_scl_last_pmin = pmin; g_scl_last_pmax = pmax;
   g_scl_last_fvb  = fvb;  g_scl_last_wb   = wb;
   g_tr_last_hash  = trHash;
   g_scl_last_s    = curS;

   //--- -------- PRICE AXIS (right strip) --------------------------
   double prange   = pmax - pmin;
   double invRange = 1.0 / prange;
   int    pdig     = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int    pUsed    = 0;

   if(tiled)
   {
      //--- Compact mode: 5 fixed anchors (top, q3, mid, q1, bottom)
      double pts[5];
      pts[0] = pmax;                        // top
      pts[1] = pmin + 0.75 * prange;        // between top and mid
      pts[2] = pmin + 0.5  * prange;        // mid
      pts[3] = pmin + 0.25 * prange;        // between bottom and mid
      pts[4] = pmin;                        // bottom
      for(int i = 0; i < 5 && pUsed < SCL_MAX_P; i++, pUsed++)
      {
         int yPix = (int)((pmax - pts[i]) * invRange * h);
         //--- nudge top/bottom labels inward so the text isn't clipped
         if(i == 0)        yPix += InpSclFontSize;
         else if(i == 4)   yPix -= InpSclFontSize;
         string nm = SCL_PREFIX_P + IntegerToString(pUsed);
         SclLabel(nm, CORNER_RIGHT_UPPER, ANCHOR_RIGHT,
                  InpSclRightPad, yPix,
                  DoubleToString(pts[i], pdig),
                  TN_FG, InpSclFontSize,
                  g_scl_p_exists[pUsed]);
      }
   }
   else
   {
      //--- Full mode: nice-stepped round numbers
      int    ptarget = MathMax(3, InpSclPriceTicks);
      double pstep   = SclNiceStep(prange / ptarget);
      pdig           = SclDigitsForStep(pstep);
      double pstart  = MathCeil(pmin / pstep) * pstep;
      for(double p = pstart; p <= pmax + pstep*0.5 && pUsed < SCL_MAX_P; p += pstep, pUsed++)
      {
         int yPix = (int)((pmax - p) * invRange * h);
         if(yPix < 0 || yPix > h) continue;
         string nm = SCL_PREFIX_P + IntegerToString(pUsed);
         SclLabel(nm, CORNER_RIGHT_UPPER, ANCHOR_RIGHT,
                  InpSclRightPad, yPix,
                  DoubleToString(p, pdig),
                  TN_FG, InpSclFontSize,
                  g_scl_p_exists[pUsed]);
      }
   }
   SclHide(SCL_PREFIX_P, g_scl_p_exists, pUsed, SCL_MAX_P);

   //--- -------- OPEN-TRADE LABELS (left side at entry price) ------
   TrDrawLabels(h, pmin, invRange);

   //--- -------- TIME AXIS (bottom strip) --------------------------
   if(fvb < 0 || wb <= 1) return;

   int lastBar  = fvb - wb + 1;
   if(lastBar < 0) lastBar = 0;

   //--- fvb is the OLDEST visible bar (leftmost), lastBar the NEWEST (rightmost)
   datetime tLeft[1], tRight[1];
   if(CopyTime(_Symbol, _Period, fvb,     1, tLeft ) != 1) return;
   if(CopyTime(_Symbol, _Period, lastBar, 1, tRight) != 1) return;
   datetime tFrom = tLeft[0], tTo = tRight[0];
   if(tFrom >= tTo) return;

   //--- Compact mode: just left, middle, right. No stepping, no overlap check.
   if(tiled)
   {
      int midBar = (fvb + lastBar) / 2;
      datetime tMidArr[1];
      datetime tMid = (datetime)((long)tFrom + ((long)tTo - (long)tFrom) / 2);
      if(CopyTime(_Symbol, _Period, midBar, 1, tMidArr) == 1) tMid = tMidArr[0];

      datetime tStamps[3]; tStamps[0] = tFrom; tStamps[1] = tMid; tStamps[2] = tTo;
      int tUsedC = 0;
      for(int i = 0; i < 3 && tUsedC < SCL_MAX_T; i++, tUsedC++)
      {
         int xPix = 0, yPix = 0;
         if(!ChartTimePriceToXY(cid, 0, tStamps[i], pmin, xPix, yPix)) continue;
         //--- nudge ends inward so text isn't clipped
         if(i == 0) xPix += 20;
         if(i == 2) xPix -= 20;
         string nm = SCL_PREFIX_T + IntegerToString(tUsedC);
         SclLabel(nm, CORNER_LEFT_LOWER, ANCHOR_LOWER,
                  xPix, InpSclBottomPad,
                  "", TN_FG, InpSclFontSize,
                  g_scl_t_exists[tUsedC]);
         MqlDateTime mt; TimeToStruct(tStamps[i], mt);
         //--- same rule as full mode: date only on the 00:00 tick, time otherwise
         string shown;
         if(mt.hour == 0 && mt.min == 0)
            shown = StringFormat("%02d.%02d", mt.day, mt.mon);
         else
            shown = StringFormat("%02d:%02d", mt.hour, mt.min);
         ObjectSetString(0, nm, OBJPROP_TEXT, shown);
      }
      SclHide(SCL_PREFIX_T, g_scl_t_exists, tUsedC, SCL_MAX_T);
      ChartRedraw(cid);
      return;
   }

   long tspan   = (long)(tTo - tFrom);
   int  ttarget = MathMax(3, InpSclTimeTicks);
   long tstep   = SclNiceTimeStep(tspan / ttarget);
   if(tstep <= 0) tstep = 60;

   //--- align first tick to step boundary
   long tstart = ((long)tFrom / tstep) * tstep;
   if(tstart < (long)tFrom) tstart += tstep;

   //--- label format scales with step
   string fmt;
   if(tstep >= 86400)      fmt = "dd.MM";
   else if(tstep >= 3600)  fmt = "dd HH:00";
   else                    fmt = "HH:mm";

   //--- Minimum pixel spacing between two adjacent time labels.
   //--- Prevents overlap at session gaps (e.g. 00:00 and 01:00 projecting
   //--- to nearly the same X when there are no bars between them).
   const int MIN_LABEL_GAP_PX = 40;
   int lastXPlaced = -100000;

   int tUsed = 0;
   for(long ts = tstart; ts <= (long)tTo; ts += tstep)
   {
      if(tUsed >= SCL_MAX_T) break;
      datetime dt = (datetime)ts;
      int xPix = 0, yPix = 0;
      if(!ChartTimePriceToXY(cid, 0, dt, pmin, xPix, yPix)) continue;
      if(xPix < 0 || xPix > w) continue;
      if(xPix - lastXPlaced < MIN_LABEL_GAP_PX) continue;
      lastXPlaced = xPix;

      string nm = SCL_PREFIX_T + IntegerToString(tUsed);
      tUsed++;
      //--- ANCHOR_LOWER: text's bottom edge sits at the anchor point.
      //--- With CORNER_LEFT_LOWER, YDISTANCE is the distance from the
      //--- bottom of the chart to the bottom of the text -> changing
      //--- InpSclBottomPad clearly moves the label up/down.
      SclLabel(nm, CORNER_LEFT_LOWER, ANCHOR_LOWER,
               xPix, InpSclBottomPad,
               TimeToString(dt, TIME_DATE|TIME_MINUTES),
               TN_FG, InpSclFontSize,
               g_scl_t_exists[tUsed - 1]);

      //--- shorten label: date only on the 00:00 tick, time otherwise
      MqlDateTime mt; TimeToStruct(dt, mt);
      string shown;
      if(tstep >= 86400)
         shown = StringFormat("%02d.%02d", mt.day, mt.mon);
      else if(mt.hour == 0 && mt.min == 0)
         shown = StringFormat("%02d.%02d", mt.day, mt.mon);
      else
         shown = StringFormat("%02d:%02d", mt.hour, mt.min);
      ObjectSetString(0, nm, OBJPROP_TEXT, shown);
   }
   SclHide(SCL_PREFIX_T, g_scl_t_exists, tUsed, SCL_MAX_T);

   ChartRedraw(cid);
}

//+------------------------------------------------------------------+
//| TrEdit: OBJ_EDIT label with solid background. Gives the trade     |
//| labels a readable plate regardless of what's painted behind.      |
//+------------------------------------------------------------------+
void TrEdit(const string name, int x, int y, const string text,
            color clr, int fsize, bool &existsFlag)
{
   //--- rough width from char count; Consolas is monospaced so this
   //--- sizes accurately enough for the trade-label line.
   int charW = (int)MathMax(7, fsize * 0.85);
   int w     = StringLen(text) * charW + 16;
   int h     = fsize + 10;

   if(!existsFlag)
   {
      ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
      ObjectSetString (0, name, OBJPROP_FONT,         "Consolas");
      ObjectSetInteger(0, name, OBJPROP_CORNER,       CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_ALIGN,        ALIGN_LEFT);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR,      TN_PANEL);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, TN_BORDER);
      ObjectSetInteger(0, name, OBJPROP_READONLY,     true);
      ObjectSetInteger(0, name, OBJPROP_BACK,         false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER,       5);
      existsFlag = true;
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     h);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  fsize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetString (0, name, OBJPROP_TEXT,      text);
}

//+------------------------------------------------------------------+
//| TrComputeHash: cheap fingerprint of open positions on _Symbol.   |
//| Lets SclDraw force a repaint when any trade event changes the    |
//| picture (open, close, partial close, volume edit).               |
//+------------------------------------------------------------------+
long TrComputeHash()
{
   long hash = 0;
   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      double p = PositionGetDouble(POSITION_PRICE_OPEN);
      double v = PositionGetDouble(POSITION_VOLUME);
      hash = hash*1315423911L
           + (long)tk
           + (long)(p*1e5)
           + (long)(v*1e2);
   }
   return hash;
}

//+------------------------------------------------------------------+
//| TrDrawLabels: one label per open position at its entry price,    |
//| anchored to the left edge. Overlapping entries (within the font  |
//| height) are merged into one label with summed volume.            |
//+------------------------------------------------------------------+
void TrDrawLabels(int h, double pmin, double invRange)
{
   if(!InpSclEnable) return;

   double prices[];
   double vols[];
   double pnls[];
   ulong  tickets[];
   int    n = 0;
   int    total = PositionsTotal();
   ArrayResize(prices,  total);
   ArrayResize(vols,    total);
   ArrayResize(pnls,    total);
   ArrayResize(tickets, total);
   for(int i = 0; i < total; i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      //--- signed volume: +vol for BUY, -vol for SELL.
      double v = PositionGetDouble(POSITION_VOLUME);
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         v = -v;
      //--- total floating PnL including swap + commission
      double pnl = PositionGetDouble(POSITION_PROFIT)
                 + PositionGetDouble(POSITION_SWAP)
                 + PositionGetDouble(POSITION_COMMISSION);
      prices [n] = PositionGetDouble(POSITION_PRICE_OPEN);
      vols   [n] = v;
      pnls   [n] = pnl;
      tickets[n] = tk;
      n++;
   }

   //--- Sort by price descending (top of chart first). Insertion sort,
   //--- n is typically small for a single symbol.
   for(int i = 1; i < n; i++)
   {
      double pk = prices[i]; double vk = vols[i]; double lk = pnls[i];
      ulong  tk = tickets[i];
      int j = i - 1;
      while(j >= 0 && prices[j] < pk)
      {
         prices [j+1] = prices [j];
         vols   [j+1] = vols   [j];
         pnls   [j+1] = pnls   [j];
         tickets[j+1] = tickets[j];
         j--;
      }
      prices[j+1] = pk; vols[j+1] = vk; pnls[j+1] = lk; tickets[j+1] = tk;
   }

   //--- Overlap merge + placement
   int    digits    = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   const int MERGE_PX = InpSclFontSize + 4;
   int    plateH    = InpSclFontSize + 10;
   int    placed    = 0;
   int    lastY     = -100000;

   //--- layout constants for the close button
   const int BTN_W  = 22;
   const int BTN_H  = plateH;

   ArrayInitialize(g_tr_cluster_count, 0);

   for(int i = 0; i < n && placed < TR_MAX; i++)
   {
      int yPix = (int)((g_scl_last_pmax - prices[i]) * invRange * h);
      if(yPix < 0 || yPix > h) continue;

      //--- merge subsequent entries projecting to the same y band
      double mergedVol   = vols[i];
      double mergedPnl   = pnls[i];
      double mergedPrice = prices[i];
      int    cIdx        = 0;
      g_tr_cluster_tickets[placed][cIdx++] = tickets[i];
      while(i + 1 < n && cIdx < 16)
      {
         int yNext = (int)((g_scl_last_pmax - prices[i+1]) * invRange * h);
         if(MathAbs(yNext - yPix) > MERGE_PX) break;
         i++;
         mergedVol += vols[i];
         mergedPnl += pnls[i];
         g_tr_cluster_tickets[placed][cIdx++] = tickets[i];
      }
      g_tr_cluster_count[placed] = cIdx;

      if(MathAbs(yPix - lastY) < MERGE_PX) continue;
      lastY = yPix;

      string nm  = TR_PREFIX + IntegerToString(placed);
      //--- fixed-width fields: right-aligned vol (7) and pnl (10) so
      //--- every cluster label has identical width regardless of sign
      //--- or magnitude. Consolas is monospace so char count == px.
      string txt = StringFormat("%s  %+7.2f  %+10.2f",
                                DoubleToString(mergedPrice, digits),
                                mergedVol, mergedPnl);
      //--- PnL-driven color: green when up, red when down, orange flat
      color plateClr = TN_ORANGE;
      if(mergedPnl > 0.0) plateClr = TN_GREEN;
      else if(mergedPnl < 0.0) plateClr = TN_RED;

      TrEdit(nm, 4, yPix - plateH/2, txt,
             plateClr, InpSclFontSize, g_tr_exists[placed]);

      //--- close-button sits immediately to the right of the plate
      int charW    = (int)MathMax(7, InpSclFontSize * 0.85);
      int plateW   = StringLen(txt) * charW + 16;
      string bnm   = TR_BTN_PREFIX + IntegerToString(placed);
      TrCloseButton(bnm, 4 + plateW + 2, yPix - BTN_H/2,
                    BTN_W, BTN_H, g_tr_btn_exists[placed]);

      placed++;
   }

   SclHide(TR_PREFIX,     g_tr_exists,     placed, TR_MAX);
   SclHide(TR_BTN_PREFIX, g_tr_btn_exists, placed, TR_MAX);
}

//+------------------------------------------------------------------+
//| TrCloseButton: small OBJ_BUTTON paired with each trade label.    |
//+------------------------------------------------------------------+
void TrCloseButton(const string name, int x, int y, int w, int h,
                   bool &existsFlag)
{
   if(!existsFlag)
   {
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
      ObjectSetString (0, name, OBJPROP_FONT,         "Consolas");
      ObjectSetString (0, name, OBJPROP_TEXT,         "x");
      ObjectSetInteger(0, name, OBJPROP_CORNER,       CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_COLOR,        TN_FG);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR,      TN_PANEL);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, TN_BORDER);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE,     InpSclFontSize);
      ObjectSetInteger(0, name, OBJPROP_BACK,         false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
      ObjectSetInteger(0, name, OBJPROP_ZORDER,       11);
      ObjectSetInteger(0, name, OBJPROP_STATE,        false);
      existsFlag = true;
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     h);
   ObjectSetInteger(0, name, OBJPROP_STATE,     false);
}
//+------------------------------------------------------------------+
