//+------------------------------------------------------------------+
//|                                          ASQ_CandleScanner.mq5   |
//|                        Copyright 2026, AlgoSphere Quant          |
//|                        https://www.mql5.com/en/users/robin2.0    |
//+------------------------------------------------------------------+
//| ASQ Candle Scanner v1.2 — Free, Open-Source Indicator            |
//|                                                                   |
//| On-chart candle analysis with structure tags, sentiment,          |
//| and trend arrows. Attaches to CLOSED candles (non-repaint).      |
//|                                                                   |
//| FEATURES:                                                         |
//| • Trend direction arrows (bullish/bearish/neutral)               |
//| • Structure tags: LQ (Liquidity Sweep), BOS (Break of            |
//|   Structure), FVG (Fair Value Gap), REV (Reversal), IB (Inside   |
//|   Bar)                                                            |
//| • Reversal detection: pin bar, engulfing candle                  |
//| • Inside bar identification                                       |
//| • Buyer vs seller sentiment percentage                            |
//| • Multi-candle lookback (tags on last N candles)                  |
//| • Momentum strength indicator                                     |
//| • Optional prediction bubble                                      |
//| • Clean mode (arrows only)                                        |
//| • Non-repaint: only analyzes fully closed candles                 |
//|                                                                   |
//| AlgoSphere Quant — Precision before profit.                      |
//| https://www.mql5.com/en/users/robin2.0                           |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, AlgoSphere Quant"
#property link        "https://www.mql5.com/en/users/robin2.0"
#property version     "1.20"
#property description "ASQ Candle Scanner v1.2 — Structure tags, sentiment, reversal detection, and trend arrows on closed candles."
#property description " "
#property description "Non-repaint. Detects Liquidity Sweeps, Break of Structure, Fair Value Gaps, Reversals (Pin Bar, Engulfing), Inside Bars."
#property description " "
#property description "Free and open-source by AlgoSphere Quant."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| INPUTS                                                            |
//+------------------------------------------------------------------+
input group "═══ Display ═══"
input bool InpCleanMode      = false;   // Clean Mode (arrows only)
input bool InpShowTags       = true;    // Show Structure Tags (LQ/BOS/FVG/REV/IB)
input bool InpShowSentiment  = true;    // Show Buyer/Seller Sentiment
input bool InpShowMomentum   = false;   // Show Momentum Strength
input bool InpShowPrediction = false;   // Show Prediction Bubble

input group "═══ Lookback ═══"
input int  InpLookback       = 5;       // Candles to Analyze (1-20)

//+------------------------------------------------------------------+
//| CONSTANTS                                                         |
//+------------------------------------------------------------------+
#define PFX      "ASQ_CS_"
#define FNT      "Consolas"

// Colors
#define CLR_BULL C'16,185,129'
#define CLR_BEAR C'239,68,68'
#define CLR_NEUT C'251,191,36'
#define CLR_FVG  C'120,80,220'
#define CLR_IB   C'80,160,255'
#define CLR_TAG  C'200,200,230'

//+------------------------------------------------------------------+
//| GLOBALS                                                           |
//+------------------------------------------------------------------+
datetime g_lastBar = 0;

int OnInit()
{
   EventSetMillisecondTimer(1000);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int r) { ObjectsDeleteAll(0, PFX); EventKillTimer(); }

int OnCalculate(const int rt, const int pc, const datetime &t[], const double &o[],
                const double &h[], const double &l[], const double &c[],
                const long &tv[], const long &v[], const int &sp[])
{
   Analyze(); return rt;
}

void OnTimer() { Analyze(); }

//+------------------------------------------------------------------+
//| Main analysis                                                     |
//+------------------------------------------------------------------+
void Analyze()
{
   datetime bar = iTime(_Symbol, _Period, 1);
   if(bar == g_lastBar) return;
   g_lastBar = bar;

   ObjectsDeleteAll(0, PFX);

   // ATR for spacing
   double atr = 0;
   int hATR = iATR(_Symbol, _Period, 14);
   if(hATR != INVALID_HANDLE)
   {
      double buf[1];
      if(CopyBuffer(hATR, 0, 1, 1, buf) == 1) atr = buf[0];
      IndicatorRelease(hATR);
   }
   if(atr == 0) atr = (iHigh(_Symbol, _Period, 1) - iLow(_Symbol, _Period, 1)) * 2;

   int lookback = MathMax(1, MathMin(20, InpLookback));

   for(int b = 1; b <= lookback; b++)
   {
      AnalyzeCandle(b, atr);
   }

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Analyze a single candle                                           |
//+------------------------------------------------------------------+
void AnalyzeCandle(int b, double atr)
{
   double op = iOpen(_Symbol, _Period, b),  hi = iHigh(_Symbol, _Period, b);
   double lo = iLow(_Symbol, _Period, b),   cl = iClose(_Symbol, _Period, b);
   double pOp = iOpen(_Symbol, _Period, b+1), pH = iHigh(_Symbol, _Period, b+1);
   double pL = iLow(_Symbol, _Period, b+1),   pCl = iClose(_Symbol, _Period, b+1);
   double body = MathAbs(cl - op), range = hi - lo;
   datetime time = iTime(_Symbol, _Period, b);
   string pfx = PFX + IntegerToString(b) + "_";

   if(range <= 0) return;

   // Trend
   int trend = 0;
   if(cl > pCl * 1.0001) trend = 1;
   else if(cl < pCl * 0.9999) trend = -1;

   double bodyRatio = body / range;

   // ═══ Detect structure tag ═══
   string tag = "";
   color tagClr = CLR_NEUT;

   // Inside Bar: current high/low within previous high/low
   if(hi <= pH && lo >= pL)
   {
      tag = "IB";
      tagClr = CLR_IB;
   }
   // Reversal: Pin Bar (long wick, small body)
   else if(bodyRatio < 0.3 && range > 0)
   {
      double upperWick = hi - MathMax(op, cl);
      double lowerWick = MathMin(op, cl) - lo;
      if(lowerWick > body * 2 && trend <= 0)
      {
         tag = "REV";  // Bullish pin bar
         tagClr = CLR_BULL;
      }
      else if(upperWick > body * 2 && trend >= 0)
      {
         tag = "REV";  // Bearish pin bar
         tagClr = CLR_BEAR;
      }
   }
   // Reversal: Engulfing
   else if(body > MathAbs(pCl - pOp) * 1.3 && bodyRatio > 0.6)
   {
      if(cl > op && pCl < pOp && cl > pH && op < pL)
      {
         tag = "REV";  // Bullish engulfing
         tagClr = CLR_BULL;
      }
      else if(cl < op && pCl > pOp && cl < pL && op > pH)
      {
         tag = "REV";  // Bearish engulfing
         tagClr = CLR_BEAR;
      }
   }

   // Liquidity sweep (wick beyond prev H/L but close inside)
   if(tag == "")
   {
      if(hi > pH && cl < pH) { tag = "LQ"; tagClr = CLR_BEAR; }
      else if(lo < pL && cl > pL) { tag = "LQ"; tagClr = CLR_BULL; }
   }

   // Break of structure
   if(tag == "")
   {
      if(cl > pH && bodyRatio > 0.6) { tag = "BOS"; tagClr = CLR_BULL; }
      else if(cl < pL && bodyRatio > 0.6) { tag = "BOS"; tagClr = CLR_BEAR; }
   }

   // Fair value gap (gap between candle b and candle b+2)
   if(tag == "" && b + 2 < Bars(_Symbol, _Period))
   {
      double c2H = iHigh(_Symbol, _Period, b+2), c2L = iLow(_Symbol, _Period, b+2);
      if(lo > c2H) { tag = "FVG"; tagClr = CLR_FVG; }
      else if(hi < c2L) { tag = "FVG"; tagClr = CLR_FVG; }
   }

   // Sentiment
   double bullP = cl - lo, bearP = hi - cl, total = bullP + bearP;
   double buyersPct = (total > 0) ? bullP / total * 100 : 50;

   // ═══ Draw ═══

   // 1. Trend arrow
   color aClr = (trend > 0) ? CLR_BULL : (trend < 0 ? CLR_BEAR : CLR_NEUT);
   int aCode = (trend > 0) ? 233 : (trend < 0 ? 234 : 232);
   double aPrice = (trend >= 0) ? hi + atr * 0.15 : lo - atr * 0.15;
   int aWidth = (b == 1) ? 2 : 1;  // Latest candle gets bigger arrow
   DrawArrow(pfx + "ARR", time, aPrice, aCode, aClr, aWidth);

   if(InpCleanMode) return;

   // 2. Structure tag
   if(InpShowTags && tag != "")
   {
      int tagSize = (b == 1) ? 8 : 7;
      DrawText(pfx + "TAG", time, hi + atr * 0.35, tag, tagClr, tagSize);
   }

   // 3. Sentiment (only on latest candle to avoid clutter)
   if(InpShowSentiment && b == 1)
   {
      string sent = "B:" + DoubleToString(buyersPct, 0) + "% S:" + DoubleToString(100-buyersPct, 0) + "%";
      color sClr = (buyersPct > 60) ? CLR_BULL : (buyersPct < 40 ? CLR_BEAR : CLR_NEUT);
      DrawText(pfx + "SENT", time, lo - atr * 0.25, sent, sClr, 7);
   }

   // 4. Momentum strength (only on latest candle)
   if(InpShowMomentum && b == 1)
   {
      string momStr = "";
      if(bodyRatio > 0.8) momStr = "STRONG";
      else if(bodyRatio > 0.5) momStr = "MODERATE";
      else if(bodyRatio > 0.3) momStr = "WEAK";
      else momStr = "INDECISIVE";

      color momClr = (bodyRatio > 0.6) ? aClr : CLR_NEUT;
      DrawText(pfx + "MOM", time, lo - atr * 0.45, momStr, momClr, 7);
   }

   // 5. Prediction (only on latest candle)
   if(InpShowPrediction && b == 1)
   {
      double prob = 50 + bodyRatio * 20;
      if(tag == "BOS") prob += 10;
      if(tag == "REV") prob += 8;
      if(prob > 80) prob = 80;
      string dir = (trend > 0) ? "UP" : (trend < 0 ? "DN" : "--");
      color pClr = (trend > 0) ? CLR_BULL : (trend < 0 ? CLR_BEAR : CLR_NEUT);
      DrawText(pfx + "PRED", time, lo - atr * 0.65,
               "Next:" + dir + " " + DoubleToString(prob, 0) + "%", pClr, 7);
   }
}

//+------------------------------------------------------------------+
//| Drawing helpers                                                   |
//+------------------------------------------------------------------+
void DrawArrow(string name, datetime time, double price, int code, color clr, int width)
{
   ObjectCreate(0, name, OBJ_ARROW, 0, time, price);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

void DrawText(string name, datetime time, double price, string text, color clr, int sz)
{
   ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, FNT);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sz);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}
//+------------------------------------------------------------------+
