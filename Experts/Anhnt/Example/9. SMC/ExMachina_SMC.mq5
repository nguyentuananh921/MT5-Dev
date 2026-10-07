//+------------------------------------------------------------------+
//|                                                ExMachina_SMC.mq5 |
//|                        Copyright 2026, ExMachina Trading Systems |
//|                       https://www.mql5.com/en/users/williammukam |
//| https://www.mql5.com/en/code/70826                              |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, ExMachina Trading Systems"
#property link        "https://www.mql5.com/en/users/williammukam"
#property version     "1.00"
#property description "ExMachina Smart Money Concepts v1.0"
#property description "BOS · CHoCH · Order Blocks · Fair Value Gaps"
#property description "EQH/EQL · Premium/Discount · Strong/Weak H/L"
#property description "Dashboard · Multi-channel alerts"
#property description "Precision before profit."
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property strict

//--- Plot 1: Trend color candles (optional)
#property indicator_label1  "SMC Open;SMC High;SMC Low;SMC Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLime,clrRed,clrGray
#property indicator_width1  1

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_SMC_MODE
{
   SMC_MODE_HISTORICAL = 0,  // Historical (show all)
   SMC_MODE_PRESENT    = 1   // Present (recent only)
};

enum ENUM_SMC_STYLE
{
   SMC_STYLE_COLORED    = 0, // Colored
   SMC_STYLE_MONO       = 1  // Monochrome
};

enum ENUM_STRUCTURE_FILTER
{
   SMC_STRUCT_ALL   = 0,     // All
   SMC_STRUCT_BOS   = 1,     // BOS only
   SMC_STRUCT_CHOCH = 2      // CHoCH only
};

enum ENUM_OB_MITIGATION
{
   OB_MIT_CLOSE   = 0,       // Close
   OB_MIT_HIGHLOW = 1        // High/Low
};

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
input group                      "══════ General ══════"
input ENUM_SMC_MODE              InpMode             = SMC_MODE_HISTORICAL;  // Mode
input ENUM_SMC_STYLE             InpStyle            = SMC_STYLE_COLORED;    // Style
input bool                       InpColorCandles     = false;                // Color Candles by Trend

input group                      "══════ Internal Structure ══════"
input bool                       InpShowInternal     = true;                 // Show Internal Structure
input ENUM_STRUCTURE_FILTER      InpInternalBullFilt = SMC_STRUCT_ALL;       // Bullish Filter
input ENUM_STRUCTURE_FILTER      InpInternalBearFilt = SMC_STRUCT_ALL;       // Bearish Filter
input int                        InpInternalLen      = 5;                    // Pivot Length
input bool                       InpInternalConflu   = false;                // Confluence Filter
input color                      InpInternalBullClr  = C'0,185,140';        // Bullish Color
input color                      InpInternalBearClr  = C'220,50,80';        // Bearish Color

input group                      "══════ Swing Structure ══════"
input bool                       InpShowSwing        = true;                 // Show Swing Structure
input ENUM_STRUCTURE_FILTER      InpSwingBullFilt    = SMC_STRUCT_ALL;       // Bullish Filter
input ENUM_STRUCTURE_FILTER      InpSwingBearFilt    = SMC_STRUCT_ALL;       // Bearish Filter
input int                        InpSwingLen         = 50;                   // Pivot Length
input bool                       InpShowSwingPts     = false;                // Show Swing Points (HH/HL/LH/LL)
input bool                       InpShowStrongWeak   = true;                 // Show Strong/Weak High/Low
input color                      InpSwingBullClr     = C'0,185,140';        // Bullish Color
input color                      InpSwingBearClr     = C'220,50,80';        // Bearish Color

input group                      "══════ Order Blocks ══════"
input bool                       InpShowInternalOB   = true;                 // Internal Order Blocks
input int                        InpInternalOBCount  = 5;                    // Max Internal OB Count
input bool                       InpShowSwingOB      = false;                // Swing Order Blocks
input int                        InpSwingOBCount     = 5;                    // Max Swing OB Count
input ENUM_OB_MITIGATION         InpOBMitigation     = OB_MIT_HIGHLOW;       // Mitigation Method
input color                      InpIntBullOBClr     = C'49,121,245';        // Internal Bullish OB
input color                      InpIntBearOBClr     = C'247,124,128';       // Internal Bearish OB
input color                      InpSwgBullOBClr     = C'24,72,204';         // Swing Bullish OB
input color                      InpSwgBearOBClr     = C'178,40,51';         // Swing Bearish OB

input group                      "══════ Equal Highs/Lows ══════"
input bool                       InpShowEQHL         = true;                 // Show Equal H/L
input double                     InpEQHLThreshold    = 0.1;                  // Threshold (0-0.5)

input group                      "══════ Fair Value Gaps ══════"
input bool                       InpShowFVG          = false;                // Show Fair Value Gaps
input bool                       InpFVGAutoThresh    = true;                 // Auto Threshold
input int                        InpFVGExtend        = 5;                    // Extend Bars
input color                      InpFVGBullClr       = C'0,255,104';        // Bullish FVG
input color                      InpFVGBearClr       = C'255,0,8';          // Bearish FVG

input group                      "══════ Premium/Discount ══════"
input bool                       InpShowPDZones      = false;                // Show Premium/Discount Zones

input group                      "══════ Alerts ══════"
input bool                       InpAlertPopup       = true;                 // Popup Alert
input bool                       InpAlertSound       = true;                 // Sound Alert
input bool                       InpAlertPush        = false;                // Push Notification
input bool                       InpAlertEmail       = false;                // Email Alert

input group                      "══════ Dashboard ══════"
input bool                       InpShowDash         = true;                 // Show Dashboard
input int                        InpDashX            = 20;                   // X Position
input int                        InpDashY            = 40;                   // Y Position
input int                        InpDashFS           = 9;                    // Font Size

//+------------------------------------------------------------------+
//| Constants                                                         |
//+------------------------------------------------------------------+
#define PREFIX        "EXSMC_"
#define FONT          "Consolas"
#define BULLISH       1
#define BEARISH       -1
#define NEUTRAL       0
#define MAX_OB        100
#define MAX_FVG       50

//+------------------------------------------------------------------+
//| Data Structures                                                   |
//+------------------------------------------------------------------+
struct SPivot
{
   double   level;
   double   lastLevel;
   bool     crossed;
   datetime barTime;
   int      barIndex;
};

struct SOrderBlock
{
   double   high;
   double   low;
   datetime barTime;
   int      bias;
   bool     active;
   string   boxName;
};

struct SFairValueGap
{
   double   top;
   double   bottom;
   int      bias;
   datetime barTime;
   bool     active;
   string   boxTopName;
   string   boxBotName;
};

struct STrailing
{
   double   top;
   double   bottom;
   datetime topTime;
   datetime bottomTime;
   datetime anchorTime;
   int      anchorIndex;
};

//+------------------------------------------------------------------+
//| Buffers                                                           |
//+------------------------------------------------------------------+
double g_bufOpen[];       // 0 - candle OHLC
double g_bufHigh[];       // 1
double g_bufLow[];        // 2
double g_bufClose[];      // 3
double g_bufCandleClr[];  // 4 - color index

//+------------------------------------------------------------------+
//| Globals                                                           |
//+------------------------------------------------------------------+
SPivot         g_swingHigh, g_swingLow;
SPivot         g_intHigh, g_intLow;
SPivot         g_eqHigh, g_eqLow;
STrailing      g_trailing;

SOrderBlock    g_intOB[];
SOrderBlock    g_swgOB[];
SFairValueGap  g_fvg[];

int            g_swingBias    = 0;
int            g_internalBias = 0;
int            g_objCount     = 0;
datetime       g_lastAlertTime = 0;
double         g_atr[];
int            g_atrHandle    = INVALID_HANDLE;
double         g_pointVal     = 0;

//+------------------------------------------------------------------+
//| OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_bufOpen,      INDICATOR_DATA);
   SetIndexBuffer(1, g_bufHigh,      INDICATOR_DATA);
   SetIndexBuffer(2, g_bufLow,       INDICATOR_DATA);
   SetIndexBuffer(3, g_bufClose,     INDICATOR_DATA);
   SetIndexBuffer(4, g_bufCandleClr, INDICATOR_COLOR_INDEX);

   if(InpColorCandles)
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);
   else
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpSwingBullClr);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpSwingBearClr);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, C'90,95,110');

   g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 200);
   if(g_atrHandle == INVALID_HANDLE)
      return(INIT_FAILED);

   g_pointVal = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   InitPivot(g_swingHigh); InitPivot(g_swingLow);
   InitPivot(g_intHigh);   InitPivot(g_intLow);
   InitPivot(g_eqHigh);    InitPivot(g_eqLow);

   ArrayResize(g_intOB, 0, MAX_OB);
   ArrayResize(g_swgOB, 0, MAX_OB);
   ArrayResize(g_fvg,   0, MAX_FVG);

   g_trailing.top = 0;
   g_trailing.bottom = DBL_MAX;

   IndicatorSetString(INDICATOR_SHORTNAME, "ExMachina SMC v1.0");

   if(InpShowDash) DashCreate();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PREFIX);
   if(g_atrHandle != INVALID_HANDLE) IndicatorRelease(g_atrHandle);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| OnCalculate                                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < MathMax(InpSwingLen, InpInternalLen) * 2 + 5)
      return(0);

   if(CopyBuffer(g_atrHandle, 0, 0, rates_total, g_atr) <= 0)
      return(0);

   int start = (prev_calculated == 0) ? MathMax(InpSwingLen, InpInternalLen) * 2 + 1 : prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
   {
      //--- Color candles
      if(InpColorCandles)
      {
         g_bufOpen[i]  = open[i];
         g_bufHigh[i]  = high[i];
         g_bufLow[i]   = low[i];
         g_bufClose[i] = close[i];
         g_bufCandleClr[i] = (g_internalBias == BULLISH) ? 0.0 :
                             (g_internalBias == BEARISH) ? 1.0 : 2.0;
      }

      //--- Detect pivots
      DetectPivots(i, InpSwingLen, high, low, time, false);
      DetectPivots(i, InpInternalLen, high, low, time, true);

      //--- Detect structure (BOS/CHoCH)
      if(InpShowInternal || InpShowInternalOB || InpColorCandles)
         DetectStructure(i, close, open, high, low, time, true);

      if(InpShowSwing || InpShowSwingOB || InpShowStrongWeak)
         DetectStructure(i, close, open, high, low, time, false);

      //--- Mitigate OBs
      if(InpShowInternalOB) MitigateOB(g_intOB, close[i], high[i], low[i]);
      if(InpShowSwingOB)    MitigateOB(g_swgOB, close[i], high[i], low[i]);

      //--- FVGs
      if(InpShowFVG && i >= 2)
         DetectFVG(i, high, low, close, open, time);

      //--- Trailing
      if(InpShowStrongWeak || InpShowPDZones)
         UpdateTrailing(high[i], low[i], time[i]);
   }

   //--- Draw dynamic objects on last bar
   if(rates_total > 0)
   {
      datetime lastTime = time[rates_total - 1];
      if(InpShowInternalOB) DrawOrderBlocks(g_intOB, InpInternalOBCount, true,  lastTime);
      if(InpShowSwingOB)    DrawOrderBlocks(g_swgOB, InpSwingOBCount,    false, lastTime);
      if(InpShowFVG)        DrawFVGs(lastTime);
      if(InpShowStrongWeak) DrawStrongWeak(lastTime);
      if(InpShowPDZones)    DrawPDZones(lastTime);
      if(InpShowDash)       DashUpdate();
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Initialize pivot                                                  |
//+------------------------------------------------------------------+
void InitPivot(SPivot &p)
{
   p.level = 0; p.lastLevel = 0; p.crossed = false;
   p.barTime = 0; p.barIndex = 0;
}

void SetPivotHigh(SPivot &p, const double val, const datetime t, const int idx)
{
   p.lastLevel = p.level;
   p.level = val; p.crossed = false;
   p.barTime = t; p.barIndex = idx;
}

void SetPivotLow(SPivot &p, const double val, const datetime t, const int idx)
{
   p.lastLevel = p.level;
   p.level = val; p.crossed = false;
   p.barTime = t; p.barIndex = idx;
}

//+------------------------------------------------------------------+
//| Detect pivot highs and lows                                       |
//+------------------------------------------------------------------+
void DetectPivots(const int i, const int len,
                  const double &high[], const double &low[],
                  const datetime &time[], const bool internal)
{
   if(i < len * 2)
      return;

   int lb = i - len; // lookback bar

   //--- Pivot High check
   bool isHigh = true;
   for(int j = 1; j <= len; j++)
   {
      if(high[lb - j] > high[lb] || high[lb + j] > high[lb])
      { isHigh = false; break; }
   }

   //--- Pivot Low check
   bool isLow = true;
   for(int j = 1; j <= len; j++)
   {
      if(low[lb - j] < low[lb] || low[lb + j] < low[lb])
      { isLow = false; break; }
   }

   if(isHigh)
   {
      //--- EQH detection before updating pivot
      if(!internal && InpShowEQHL && g_eqHigh.level > 0)
      {
         double atr = (g_atr[lb] > 0) ? g_atr[lb] : g_pointVal * 100;
         if(MathAbs(g_eqHigh.level - high[lb]) < InpEQHLThreshold * atr)
            DrawEqualHL(g_eqHigh, high[lb], time[lb], lb, true);
      }

      //--- Update EQ pivot
      if(!internal)
      {
         g_eqHigh.lastLevel = g_eqHigh.level;
         g_eqHigh.level = high[lb]; g_eqHigh.barTime = time[lb]; g_eqHigh.barIndex = lb;
      }

      //--- Update main pivot (internal or swing)
      if(internal)
         SetPivotHigh(g_intHigh, high[lb], time[lb], lb);
      else
      {
         SetPivotHigh(g_swingHigh, high[lb], time[lb], lb);
         g_trailing.top = high[lb]; g_trailing.topTime = time[lb];
         g_trailing.anchorTime = time[lb]; g_trailing.anchorIndex = lb;
      }

      //--- Swing point label
      if(!internal && InpShowSwingPts)
      {
         double prev = g_swingHigh.lastLevel;
         string tag = (high[lb] > prev && prev > 0) ? "HH" : "LH";
         DrawSmcLabel(time[lb], high[lb], tag, GetBearColor(false), true);
      }
   }

   if(isLow)
   {
      //--- EQL detection
      if(!internal && InpShowEQHL && g_eqLow.level > 0)
      {
         double atr = (g_atr[lb] > 0) ? g_atr[lb] : g_pointVal * 100;
         if(MathAbs(g_eqLow.level - low[lb]) < InpEQHLThreshold * atr)
            DrawEqualHL(g_eqLow, low[lb], time[lb], lb, false);
      }

      if(!internal)
      {
         g_eqLow.lastLevel = g_eqLow.level;
         g_eqLow.level = low[lb]; g_eqLow.barTime = time[lb]; g_eqLow.barIndex = lb;
      }

      if(internal)
         SetPivotLow(g_intLow, low[lb], time[lb], lb);
      else
      {
         SetPivotLow(g_swingLow, low[lb], time[lb], lb);
         g_trailing.bottom = low[lb]; g_trailing.bottomTime = time[lb];
         g_trailing.anchorTime = time[lb]; g_trailing.anchorIndex = lb;
      }

      if(!internal && InpShowSwingPts)
      {
         double prev = g_swingLow.lastLevel;
         string tag = (low[lb] < prev && prev > 0) ? "LL" : "HL";
         DrawSmcLabel(time[lb], low[lb], tag, GetBullColor(false), false);
      }
   }
}

//+------------------------------------------------------------------+
//| Detect BOS / CHoCH structure breaks                               |
//+------------------------------------------------------------------+
void DetectStructure(const int i,
                     const double &close[], const double &open[],
                     const double &high[], const double &low[],
                     const datetime &time[], const bool internal)
{
   //--- Confluence filter for internal
   bool bullBar = true, bearBar = true;
   if(internal && InpInternalConflu)
   {
      double bodyTop = MathMax(close[i], open[i]);
      double bodyBot = MathMin(close[i], open[i]);
      bullBar = (high[i] - bodyTop) > (bodyBot - low[i]);
      bearBar = (high[i] - bodyTop) < (bodyBot - low[i]);
   }

   //--- Read the relevant pivot levels
   double highLevel, lowLevel;
   bool   highCrossed, lowCrossed;
   datetime highTime, lowTime;
   int    highIdx, lowIdx, curBias;

   if(internal)
   {
      highLevel = g_intHigh.level;  highCrossed = g_intHigh.crossed;
      highTime  = g_intHigh.barTime; highIdx    = g_intHigh.barIndex;
      lowLevel  = g_intLow.level;   lowCrossed  = g_intLow.crossed;
      lowTime   = g_intLow.barTime;  lowIdx     = g_intLow.barIndex;
      curBias   = g_internalBias;
   }
   else
   {
      highLevel = g_swingHigh.level;  highCrossed = g_swingHigh.crossed;
      highTime  = g_swingHigh.barTime; highIdx    = g_swingHigh.barIndex;
      lowLevel  = g_swingLow.level;   lowCrossed  = g_swingLow.crossed;
      lowTime   = g_swingLow.barTime;  lowIdx     = g_swingLow.barIndex;
      curBias   = g_swingBias;
   }

   bool extraBull = internal ? (g_intHigh.level != g_swingHigh.level && bullBar) : true;
   bool extraBear = internal ? (g_intLow.level  != g_swingLow.level  && bearBar) : true;

   //--- Bullish break: close above pivot high
   if(highLevel > 0 && close[i] > highLevel && !highCrossed && extraBull)
   {
      string tag = (curBias == BEARISH) ? "CHoCH" : "BOS";

      //--- Mark crossed
      if(internal) g_intHigh.crossed = true;
      else         g_swingHigh.crossed = true;

      //--- Update bias
      if(internal) g_internalBias = BULLISH;
      else         g_swingBias = BULLISH;

      ENUM_STRUCTURE_FILTER filt = internal ? InpInternalBullFilt : InpSwingBullFilt;
      bool show = internal ? InpShowInternal : InpShowSwing;
      bool pass = (filt == SMC_STRUCT_ALL) ||
                  (filt == SMC_STRUCT_BOS   && tag == "BOS") ||
                  (filt == SMC_STRUCT_CHOCH  && tag == "CHoCH");

      if(show && pass)
      {
         SPivot tmpPivot;
         tmpPivot.level = highLevel; tmpPivot.barTime = highTime; tmpPivot.barIndex = highIdx;
         DrawStructureLine(tmpPivot, tag, GetBullColor(internal), internal, time[i]);
      }

      if((internal && InpShowInternalOB) || (!internal && InpShowSwingOB))
      {
         SPivot tmpPivot;
         tmpPivot.level = highLevel; tmpPivot.barTime = highTime; tmpPivot.barIndex = highIdx;
         StoreOrderBlock(tmpPivot, internal, BULLISH, high, low, time);
      }

      FireAlert(tag, "Bullish", internal, time[i]);
   }

   //--- Bearish break: close below pivot low
   if(lowLevel > 0 && close[i] < lowLevel && !lowCrossed && extraBear)
   {
      string tag = (curBias == BULLISH) ? "CHoCH" : "BOS";

      if(internal) g_intLow.crossed = true;
      else         g_swingLow.crossed = true;

      if(internal) g_internalBias = BEARISH;
      else         g_swingBias = BEARISH;

      ENUM_STRUCTURE_FILTER filt = internal ? InpInternalBearFilt : InpSwingBearFilt;
      bool show = internal ? InpShowInternal : InpShowSwing;
      bool pass = (filt == SMC_STRUCT_ALL) ||
                  (filt == SMC_STRUCT_BOS   && tag == "BOS") ||
                  (filt == SMC_STRUCT_CHOCH  && tag == "CHoCH");

      if(show && pass)
      {
         SPivot tmpPivot;
         tmpPivot.level = lowLevel; tmpPivot.barTime = lowTime; tmpPivot.barIndex = lowIdx;
         DrawStructureLine(tmpPivot, tag, GetBearColor(internal), internal, time[i]);
      }

      if((internal && InpShowInternalOB) || (!internal && InpShowSwingOB))
      {
         SPivot tmpPivot;
         tmpPivot.level = lowLevel; tmpPivot.barTime = lowTime; tmpPivot.barIndex = lowIdx;
         StoreOrderBlock(tmpPivot, internal, BEARISH, high, low, time);
      }

      FireAlert(tag, "Bearish", internal, time[i]);
   }
}

//+------------------------------------------------------------------+
//| Store order block at structure break                              |
//+------------------------------------------------------------------+
void StoreOrderBlock(const SPivot &pivot, const bool internal,
                     const int bias,
                     const double &high[], const double &low[],
                     const datetime &time[])
{
   if(pivot.barIndex <= 0) return;

   int startIdx = pivot.barIndex;
   int endIdx   = MathMin(ArraySize(high) - 1, startIdx + 50);
   int bestIdx  = startIdx;

   if(bias == BEARISH)
   {
      double maxH = high[startIdx];
      for(int j = startIdx + 1; j <= endIdx; j++)
         if(high[j] > maxH) { maxH = high[j]; bestIdx = j; }
   }
   else
   {
      double minL = low[startIdx];
      for(int j = startIdx + 1; j <= endIdx; j++)
         if(low[j] < minL) { minL = low[j]; bestIdx = j; }
   }

   SOrderBlock ob;
   ob.high    = high[bestIdx];
   ob.low     = low[bestIdx];
   ob.barTime = time[bestIdx];
   ob.bias    = bias;
   ob.active  = true;
   ob.boxName = PREFIX + "OB_" + (internal ? "I" : "S") + "_" +
                IntegerToString((long)time[bestIdx]);

   if(internal)
   {
      int sz = ArraySize(g_intOB);
      ArrayResize(g_intOB, sz + 1);
      g_intOB[sz] = ob;
      if(ArraySize(g_intOB) > MAX_OB) ArrayRemove(g_intOB, 0, 1);
   }
   else
   {
      int sz = ArraySize(g_swgOB);
      ArrayResize(g_swgOB, sz + 1);
      g_swgOB[sz] = ob;
      if(ArraySize(g_swgOB) > MAX_OB) ArrayRemove(g_swgOB, 0, 1);
   }
}

//+------------------------------------------------------------------+
//| Mitigate order blocks                                             |
//+------------------------------------------------------------------+
void MitigateOB(SOrderBlock &arr[],
                const double closeP, const double highP, const double lowP)
{
   double bullSrc = (InpOBMitigation == OB_MIT_CLOSE) ? closeP : lowP;
   double bearSrc = (InpOBMitigation == OB_MIT_CLOSE) ? closeP : highP;

   for(int j = ArraySize(arr) - 1; j >= 0; j--)
   {
      if(!arr[j].active) continue;

      if(arr[j].bias == BEARISH && bearSrc > arr[j].high)
      { arr[j].active = false; ObjectDelete(0, arr[j].boxName); }
      else if(arr[j].bias == BULLISH && bullSrc < arr[j].low)
      { arr[j].active = false; ObjectDelete(0, arr[j].boxName); }
   }
}

//+------------------------------------------------------------------+
//| Detect Fair Value Gaps                                            |
//+------------------------------------------------------------------+
void DetectFVG(const int i,
               const double &high[], const double &low[],
               const double &close[], const double &open[],
               const datetime &time[])
{
   //--- Bullish FVG: gap between low[i] and high[i-2]
   if(low[i] > high[i-2])
   {
      double bodyPct = MathAbs(close[i-1] - open[i-1]) /
                       (open[i-1] != 0 ? MathAbs(open[i-1]) : 1.0) * 100.0;
      if(!InpFVGAutoThresh || bodyPct > 0.05)
      {
         SFairValueGap fvg;
         fvg.top = low[i]; fvg.bottom = high[i-2];
         fvg.bias = BULLISH; fvg.barTime = time[i-1]; fvg.active = true;
         fvg.boxTopName = PREFIX + "FVG_BT_" + IntegerToString((long)time[i-1]);
         fvg.boxBotName = PREFIX + "FVG_BB_" + IntegerToString((long)time[i-1]);
         int sz = ArraySize(g_fvg);
         ArrayResize(g_fvg, sz + 1);
         g_fvg[sz] = fvg;
         if(ArraySize(g_fvg) > MAX_FVG) ArrayRemove(g_fvg, 0, 1);
      }
   }

   //--- Bearish FVG: gap between low[i-2] and high[i]
   if(high[i] < low[i-2])
   {
      double bodyPct = MathAbs(close[i-1] - open[i-1]) /
                       (open[i-1] != 0 ? MathAbs(open[i-1]) : 1.0) * 100.0;
      if(!InpFVGAutoThresh || bodyPct > 0.05)
      {
         SFairValueGap fvg;
         fvg.top = low[i-2]; fvg.bottom = high[i];
         fvg.bias = BEARISH; fvg.barTime = time[i-1]; fvg.active = true;
         fvg.boxTopName = PREFIX + "FVG_ST_" + IntegerToString((long)time[i-1]);
         fvg.boxBotName = PREFIX + "FVG_SB_" + IntegerToString((long)time[i-1]);
         int sz = ArraySize(g_fvg);
         ArrayResize(g_fvg, sz + 1);
         g_fvg[sz] = fvg;
         if(ArraySize(g_fvg) > MAX_FVG) ArrayRemove(g_fvg, 0, 1);
      }
   }

   //--- Mitigate existing FVGs
   for(int j = ArraySize(g_fvg) - 1; j >= 0; j--)
   {
      if(!g_fvg[j].active) continue;
      if(g_fvg[j].bias == BULLISH && low[i] < g_fvg[j].bottom)
      { g_fvg[j].active = false; ObjectDelete(0, g_fvg[j].boxTopName); ObjectDelete(0, g_fvg[j].boxBotName); }
      else if(g_fvg[j].bias == BEARISH && high[i] > g_fvg[j].top)
      { g_fvg[j].active = false; ObjectDelete(0, g_fvg[j].boxTopName); ObjectDelete(0, g_fvg[j].boxBotName); }
   }
}

//+------------------------------------------------------------------+
//| Update trailing extremes                                          |
//+------------------------------------------------------------------+
void UpdateTrailing(const double h, const double l, const datetime t)
{
   if(h > g_trailing.top || g_trailing.top == 0)
   { g_trailing.top = h; g_trailing.topTime = t; }
   if(l < g_trailing.bottom || g_trailing.bottom == DBL_MAX)
   { g_trailing.bottom = l; g_trailing.bottomTime = t; }
}

//+------------------------------------------------------------------+
//| Draw structure line + label (BOS/CHoCH)                           |
//+------------------------------------------------------------------+
void DrawStructureLine(const SPivot &pivot, const string tag,
                       const color clr, const bool internal,
                       const datetime currentTime)
{
   if(InpMode == SMC_MODE_PRESENT)
      CleanOldObjects("STR_");

   string sfx       = IntegerToString(g_objCount++);
   string lineName  = PREFIX + "STR_L_" + sfx;
   string labelName = PREFIX + "STR_T_" + sfx;

   ObjectCreate(0, lineName, OBJ_TREND, 0,
                pivot.barTime, pivot.level, currentTime, pivot.level);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, internal ? STYLE_DASH : STYLE_SOLID);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);

   datetime midTime = (datetime)(((long)pivot.barTime + (long)currentTime) / 2);
   ObjectCreate(0, labelName, OBJ_TEXT, 0, midTime, pivot.level);
   ObjectSetString(0,  labelName, OBJPROP_TEXT, tag);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0,  labelName, OBJPROP_FONT, FONT);
   ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LOWER);
   ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Draw label (HH/HL/LH/LL)                                         |
//+------------------------------------------------------------------+
void DrawSmcLabel(const datetime t, const double price,
                  const string tag, const color clr, const bool above)
{
   string name = PREFIX + "LBL_" + IntegerToString(g_objCount++);
   ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   ObjectSetString(0,  name, OBJPROP_TEXT, tag);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
   ObjectSetString(0,  name, OBJPROP_FONT, FONT);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, above ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Draw Equal High/Low                                               |
//+------------------------------------------------------------------+
void DrawEqualHL(const SPivot &pivot, const double level,
                 const datetime t, const int idx, const bool isHigh)
{
   string sfx = IntegerToString(g_objCount++);
   color  clr = isHigh ? GetBearColor(false) : GetBullColor(false);
   string tag = isHigh ? "EQH" : "EQL";

   string ln = PREFIX + "EQ_L_" + sfx;
   ObjectCreate(0, ln, OBJ_TREND, 0, pivot.barTime, pivot.level, t, level);
   ObjectSetInteger(0, ln, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, ln, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, ln, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, ln, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, ln, OBJPROP_BACK, true);
   ObjectSetInteger(0, ln, OBJPROP_SELECTABLE, false);

   datetime mt = (datetime)(((long)pivot.barTime + (long)t) / 2);
   string lb = PREFIX + "EQ_T_" + sfx;
   ObjectCreate(0, lb, OBJ_TEXT, 0, mt, level);
   ObjectSetString(0,  lb, OBJPROP_TEXT, tag);
   ObjectSetInteger(0, lb, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, lb, OBJPROP_FONTSIZE, 7);
   ObjectSetString(0,  lb, OBJPROP_FONT, FONT);
   ObjectSetInteger(0, lb, OBJPROP_ANCHOR, isHigh ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0, lb, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Draw order blocks                                                 |
//+------------------------------------------------------------------+
void DrawOrderBlocks(SOrderBlock &arr[], const int maxCount,
                     const bool internal, const datetime lastTime)
{
   int drawn = 0;
   for(int j = ArraySize(arr) - 1; j >= 0 && drawn < maxCount; j--)
   {
      if(!arr[j].active) continue;

      color obClr;
      if(InpStyle == SMC_STYLE_MONO)
         obClr = (arr[j].bias == BEARISH) ? C'93,96,107' : C'178,181,190';
      else if(internal)
         obClr = (arr[j].bias == BEARISH) ? InpIntBearOBClr : InpIntBullOBClr;
      else
         obClr = (arr[j].bias == BEARISH) ? InpSwgBearOBClr : InpSwgBullOBClr;

      string name = arr[j].boxName;
      if(ObjectFind(0, name) < 0)
      {
         ObjectCreate(0, name, OBJ_RECTANGLE, 0,
                      arr[j].barTime, arr[j].high, lastTime, arr[j].low);
         ObjectSetInteger(0, name, OBJPROP_COLOR, obClr);
         ObjectSetInteger(0, name, OBJPROP_FILL, true);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      }
      else
         ObjectSetInteger(0, name, OBJPROP_TIME, 1, lastTime);

      drawn++;
   }
}

//+------------------------------------------------------------------+
//| Draw Fair Value Gaps                                              |
//+------------------------------------------------------------------+
void DrawFVGs(const datetime lastTime)
{
   for(int j = 0; j < ArraySize(g_fvg); j++)
   {
      if(!g_fvg[j].active) continue;

      color clr = (g_fvg[j].bias == BULLISH) ?
                  (InpStyle == SMC_STYLE_MONO ? C'178,181,190' : InpFVGBullClr) :
                  (InpStyle == SMC_STYLE_MONO ? C'93,96,107'   : InpFVGBearClr);

      double mid = (g_fvg[j].top + g_fvg[j].bottom) / 2.0;

      if(ObjectFind(0, g_fvg[j].boxTopName) < 0)
      {
         ObjectCreate(0, g_fvg[j].boxTopName, OBJ_RECTANGLE, 0,
                      g_fvg[j].barTime, g_fvg[j].top, lastTime, mid);
         ObjectSetInteger(0, g_fvg[j].boxTopName, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, g_fvg[j].boxTopName, OBJPROP_FILL, true);
         ObjectSetInteger(0, g_fvg[j].boxTopName, OBJPROP_BACK, true);
         ObjectSetInteger(0, g_fvg[j].boxTopName, OBJPROP_SELECTABLE, false);
      }

      if(ObjectFind(0, g_fvg[j].boxBotName) < 0)
      {
         ObjectCreate(0, g_fvg[j].boxBotName, OBJ_RECTANGLE, 0,
                      g_fvg[j].barTime, mid, lastTime, g_fvg[j].bottom);
         ObjectSetInteger(0, g_fvg[j].boxBotName, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, g_fvg[j].boxBotName, OBJPROP_FILL, true);
         ObjectSetInteger(0, g_fvg[j].boxBotName, OBJPROP_BACK, true);
         ObjectSetInteger(0, g_fvg[j].boxBotName, OBJPROP_SELECTABLE, false);
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Strong/Weak High/Low                                         |
//+------------------------------------------------------------------+
void DrawStrongWeak(const datetime lastTime)
{
   datetime rt = lastTime + PeriodSeconds() * 20;
   string topTag = (g_swingBias == BEARISH) ? "Strong High" : "Weak High";
   string botTag = (g_swingBias == BULLISH) ? "Strong Low"  : "Weak Low";
   color  topClr = GetBearColor(false);
   color  botClr = GetBullColor(false);

   DrawOrMoveLine(PREFIX + "SW_TL", g_trailing.topTime,    g_trailing.top,    rt, topClr);
   DrawOrMoveText(PREFIX + "SW_TT", rt, g_trailing.top,    "  " + topTag, topClr, ANCHOR_LEFT);
   DrawOrMoveLine(PREFIX + "SW_BL", g_trailing.bottomTime, g_trailing.bottom, rt, botClr);
   DrawOrMoveText(PREFIX + "SW_BT", rt, g_trailing.bottom, "  " + botTag, botClr, ANCHOR_LEFT);
}

//+------------------------------------------------------------------+
//| Draw Premium/Discount zones                                       |
//+------------------------------------------------------------------+
void DrawPDZones(const datetime lastTime)
{
   if(g_trailing.top <= 0 || g_trailing.bottom >= DBL_MAX) return;

   double range = g_trailing.top - g_trailing.bottom;
   double eq    = (g_trailing.top + g_trailing.bottom) / 2.0;

   color premClr = (InpStyle == SMC_STYLE_MONO) ? C'93,96,107'   : C'220,50,80';
   color discClr = (InpStyle == SMC_STYLE_MONO) ? C'178,181,190'  : C'0,185,140';

   DrawZoneBox("PD_PREM", g_trailing.anchorTime, g_trailing.top,
               lastTime, g_trailing.top - 0.05 * range, premClr);
   DrawZoneBox("PD_EQ",   g_trailing.anchorTime, eq + 0.025 * range,
               lastTime, eq - 0.025 * range, C'135,139,148');
   DrawZoneBox("PD_DISC", g_trailing.anchorTime, g_trailing.bottom + 0.05 * range,
               lastTime, g_trailing.bottom, discClr);
}

//+------------------------------------------------------------------+
//| Helper: draw or move a trendline                                  |
//+------------------------------------------------------------------+
void DrawOrMoveLine(const string name, const datetime t1, const double p,
                    const datetime t2, const color clr)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p, t2, p);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else
   {
      ObjectMove(0, name, 0, t1, p);
      ObjectMove(0, name, 1, t2, p);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   }
}

//+------------------------------------------------------------------+
//| Helper: draw or move a text label                                 |
//+------------------------------------------------------------------+
void DrawOrMoveText(const string name, const datetime t, const double p,
                    const string text, const color clr, const int anchor)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
      ObjectSetString(0,  name, OBJPROP_FONT, FONT);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   ObjectSetString(0,  name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectMove(0, name, 0, t, p);
}

//+------------------------------------------------------------------+
//| Helper: draw zone rectangle                                       |
//+------------------------------------------------------------------+
void DrawZoneBox(const string id, const datetime t1, const double p1,
                 const datetime t2, const double p2, const color clr)
{
   string name = PREFIX + id;
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else
   {
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
   }
}

//+------------------------------------------------------------------+
//| Color helpers                                                     |
//+------------------------------------------------------------------+
color GetBullColor(const bool internal)
{
   if(InpStyle == SMC_STYLE_MONO) return C'178,181,190';
   return internal ? InpInternalBullClr : InpSwingBullClr;
}

color GetBearColor(const bool internal)
{
   if(InpStyle == SMC_STYLE_MONO) return C'93,96,107';
   return internal ? InpInternalBearClr : InpSwingBearClr;
}

//+------------------------------------------------------------------+
//| Clean old objects by prefix                                       |
//+------------------------------------------------------------------+
void CleanOldObjects(const string pattern)
{
   string full = PREFIX + pattern;
   for(int j = ObjectsTotal(0, 0, -1) - 1; j >= 0; j--)
   {
      string name = ObjectName(0, j, 0, -1);
      if(StringFind(name, full) == 0)
         ObjectDelete(0, name);
   }
}

//+------------------------------------------------------------------+
//| Fire alert                                                        |
//+------------------------------------------------------------------+
void FireAlert(const string tag, const string direction,
               const bool internal, const datetime barTime)
{
   if(barTime <= g_lastAlertTime) return;

   string scope = internal ? "Internal" : "Swing";
   string msg = "ExMachina SMC | " + _Symbol + " " +
                EnumToString(_Period) + " | " +
                scope + " " + direction + " " + tag;

   if(InpAlertPopup)  Alert(msg);
   if(InpAlertSound)  PlaySound("alert.wav");
   if(InpAlertPush)   SendNotification(msg);
   if(InpAlertEmail)  SendMail("ExMachina SMC Alert", msg);
   Print(msg);

   g_lastAlertTime = barTime;
}

//+------------------------------------------------------------------+
//| Dashboard — Create                                                |
//+------------------------------------------------------------------+
void DashCreate()
{
   string bg = PREFIX + "DASH_BG";
   ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, InpDashX);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, InpDashY);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, 250);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, 10);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'8,10,18');
   ObjectSetInteger(0, bg, OBJPROP_BORDER_COLOR, C'30,34,46');
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);

   int x0 = InpDashX + 12, y0 = InpDashY + 10;
   int fs = InpDashFS, lh = fs + 9, xV = InpDashX + 145;

   DL("Title",   x0, y0, "EXMACHINA SMC", C'90,180,220', fs + 1);
   y0 += lh + 2;
   DL("Sep1",    x0, y0, "──────────────────────────────", C'30,34,46', fs - 2);
   y0 += lh - 3;

   DL("SwBLbl",  x0, y0, "Swing Bias:",   C'90,95,110', fs);
   DL("SwBVal",  xV, y0, "---",           C'160,168,180', fs);
   y0 += lh;
   DL("IntBLbl", x0, y0, "Internal Bias:",C'90,95,110', fs);
   DL("IntBVal", xV, y0, "---",           C'160,168,180', fs);
   y0 += lh;
   DL("IntOBLbl",x0, y0, "Int OBs:",      C'90,95,110', fs);
   DL("IntOBVal",xV, y0, "---",           C'160,168,180', fs);
   y0 += lh;
   DL("SwgOBLbl",x0, y0, "Swing OBs:",   C'90,95,110', fs);
   DL("SwgOBVal",xV, y0, "---",           C'160,168,180', fs);
   y0 += lh;
   DL("FVGLbl",  x0, y0, "Active FVGs:", C'90,95,110', fs);
   DL("FVGVal",  xV, y0, "---",           C'160,168,180', fs);
   y0 += lh;
   DL("LastLbl", x0, y0, "Last Signal:", C'90,95,110', fs);
   DL("LastVal", xV, y0, "---",           C'160,168,180', fs);
   y0 += lh + 2;

   DL("Sep2",    x0, y0, "──────────────────────────────", C'30,34,46', fs - 2);
   y0 += lh - 3;
   DL("Brand",   x0, y0, "Precision before profit",        C'55,60,75', fs - 2);

   ObjectSetInteger(0, bg, OBJPROP_YSIZE, (y0 + lh + 2) - InpDashY);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Dashboard — Update                                                |
//+------------------------------------------------------------------+
void DashUpdate()
{
   string swB = (g_swingBias == BULLISH) ? "▲ BULLISH" :
                (g_swingBias == BEARISH) ? "▼ BEARISH" : "— NEUTRAL";
   color swC  = (g_swingBias == BULLISH) ? InpSwingBullClr :
                (g_swingBias == BEARISH) ? InpSwingBearClr : C'90,95,110';
   DS("SwBVal", swB, swC);

   string intB = (g_internalBias == BULLISH) ? "▲ BULLISH" :
                 (g_internalBias == BEARISH) ? "▼ BEARISH" : "— NEUTRAL";
   color intC  = (g_internalBias == BULLISH) ? InpInternalBullClr :
                 (g_internalBias == BEARISH) ? InpInternalBearClr : C'90,95,110';
   DS("IntBVal", intB, intC);

   int iOB = 0;
   for(int j = 0; j < ArraySize(g_intOB); j++) if(g_intOB[j].active) iOB++;
   DS("IntOBVal", IntegerToString(iOB) + " active", C'160,168,180');

   int sOB = 0;
   for(int j = 0; j < ArraySize(g_swgOB); j++) if(g_swgOB[j].active) sOB++;
   DS("SwgOBVal", IntegerToString(sOB) + " active", C'160,168,180');

   int fvgA = 0;
   for(int j = 0; j < ArraySize(g_fvg); j++) if(g_fvg[j].active) fvgA++;
   DS("FVGVal", IntegerToString(fvgA) + " active", C'160,168,180');

   string lastSig = "None"; color lastClr = C'90,95,110';
   if(g_swingBias == BULLISH)      { lastSig = "Bullish"; lastClr = InpSwingBullClr; }
   else if(g_swingBias == BEARISH) { lastSig = "Bearish"; lastClr = InpSwingBearClr; }
   DS("LastVal", lastSig, lastClr);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Dashboard helpers                                                 |
//+------------------------------------------------------------------+
void DL(const string id, const int x, const int y,
        const string text, const color clr, const int fontSize)
{
   string name = PREFIX + "DASH_" + id;
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0,  name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0,  name, OBJPROP_FONT, FONT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

void DS(const string id, const string text, const color clr)
{
   string name = PREFIX + "DASH_" + id;
   ObjectSetString(0,  name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}
//+------------------------------------------------------------------+
