//+------------------------------------------------------------------+
//|                                                Market Intent.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                     https://www.mql5.com/en/users/johnhlomohang/ |
//|Link                        https://www.mql5.com/en/articles/24184|
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/johnhlomohang/"
#property version   "1.00"
#property description "Market Intent Engine - fuses market structure, liquidity mapping and price behaviour"
#property description "into a single 0-100 intent score with WAIT / WATCH / ACTION decision states."
#property description "Set AutoTrade = false to use it purely as a visual indicator."

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define PFX               "MIE_"      // object name prefix

#define LBL_NONE          0
#define LBL_HH            1
#define LBL_HL            2
#define LBL_LH            3
#define LBL_LL            4

#define POOL_SWING        0
#define POOL_EQUAL        1
#define POOL_PDH          2
#define POOL_PDL          3
#define POOL_PWH          4
#define POOL_PWL          5

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_INTENT_STATE
  {
   STATE_WAIT         = 0,  // WAIT
   STATE_WATCH_LONG   = 1,  // WATCH LONG
   STATE_ACTION_LONG  = 2,  // ACTION LONG
   STATE_WATCH_SHORT  = 3,  // WATCH SHORT
   STATE_ACTION_SHORT = 4   // ACTION SHORT
  };

enum ENUM_ENTRY_MODE
  {
   ENTRY_MARKET_NOW  = 0,  // Market immediately on ACTION
   ENTRY_MARKET_ZONE = 1,  // Market when price trades into the zone
   ENTRY_LIMIT_ZONE  = 2   // Pending limit inside the zone
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== MASTER SWITCH ==="
input bool             InpAutoTrade          = false;        // AutoTrade (false = indicator only)

input group "=== TIMEFRAME CONTEXT ==="
input ENUM_TIMEFRAMES  InpMacroTF            = PERIOD_H4;    // Macro structure timeframe
input ENUM_TIMEFRAMES  InpPrimaryTF          = PERIOD_H1;    // Primary structure timeframe
input ENUM_TIMEFRAMES  InpSetupTF            = PERIOD_M15;   // Setup timeframe (liquidity / sweeps)
input ENUM_TIMEFRAMES  InpEntryTF            = PERIOD_M5;    // Entry timeframe (confirmation)
input int              InpBarsMacro          = 400;          // Bars to load - macro
input int              InpBarsPrimary        = 600;          // Bars to load - primary
input int              InpBarsSetup          = 900;          // Bars to load - setup
input int              InpBarsEntry          = 900;          // Bars to load - entry

input group "=== 1. MARKET STRUCTURE ENGINE ==="
input int              InpSwingDepthMacro    = 4;            // Swing depth - macro
input int              InpSwingDepthPrimary  = 4;            // Swing depth - primary
input int              InpSwingDepthSetup    = 3;            // Swing depth - setup
input int              InpSwingDepthEntry    = 3;            // Swing depth - entry
input int              InpEqLookback         = 200;          // Bars for premium/discount range

input group "=== 2. LIQUIDITY ENGINE ==="
input bool             InpUseSwingPools      = true;         // Use swing highs / lows as pools
input bool             InpUseEqualPools      = true;         // Detect equal highs / lows
input bool             InpUseDailyPools      = true;         // Previous day high / low
input bool             InpUseWeeklyPools     = true;         // Previous week high / low
input double           InpEqualTolATR        = 0.18;         // Equal-level tolerance (x ATR)
input double           InpMinPenetrationATR  = 0.05;         // Minimum sweep penetration (x ATR)
input int              InpSweepScanBars      = 60;           // Bars to scan for sweeps (setup TF)
input int              InpSweepValidBars     = 20;           // Sweep stays "fresh" for N setup bars
input int              InpSweepReactBars     = 6;            // Bars allowed for the reaction

input group "=== 3. PRICE BEHAVIOR ENGINE ==="
input int              InpATRPeriod          = 14;           // ATR period
input double           InpDispATRMult        = 1.30;         // Displacement: range >= ATR x
input double           InpDispBodyRatio      = 0.55;         // Displacement: body / range >=
input int              InpDispScanBars       = 25;           // Bars to scan for displacement
input double           InpRejWickRatio       = 0.45;         // Rejection: wick / range >=
input int              InpFVGScanBars        = 80;           // Bars to scan for FVGs
input double           InpMinFVGATR          = 0.15;         // Minimum FVG size (x ATR)
input double           InpMaxFVGFill         = 0.85;         // Discard FVG once filled beyond this

input group "=== 4. INTENT SCORING (weights sum to 100) ==="
input double           InpWHTF               = 20.0;         // Weight: HTF bias alignment
input double           InpWLiq               = 20.0;         // Weight: liquidity sweep
input double           InpWDisp              = 18.0;         // Weight: displacement
input double           InpWBOS               = 14.0;         // Weight: BOS / CHOCH
input double           InpWFVG               =  8.0;         // Weight: FVG present
input double           InpWRetest            =  8.0;         // Weight: FVG retest
input double           InpWReject            =  5.0;         // Weight: rejection
input double           InpWLoc               =  7.0;         // Weight: premium / discount location
input double           InpConflictWeight     = 0.30;         // Opposite-side penalty factor
input double           InpWatchScore         = 45.0;         // Score >= this -> WATCH
input double           InpActionScore        = 65.0;         // Score >= this -> ACTION

input group "=== 5. DECISION GATES ==="
input bool             InpRequireSweep       = true;         // ACTION requires a fresh liquidity sweep
input bool             InpRequireDisplacement= true;         // ACTION requires aligned displacement
input bool             InpRequireBOS         = true;         // ACTION requires aligned BOS / CHOCH
input bool             InpRequireFVG         = false;        // ACTION requires an unfilled FVG
input double           InpMinRR              = 1.50;         // Minimum reward / risk
input double           InpDefaultRR          = 2.00;         // RR used when no pool target exists
input double           InpSLBufferATR        = 0.35;         // Stop buffer beyond invalidation (x ATR)
input double           InpMinTPDistATR       = 1.00;         // Ignore targets closer than this

input group "=== 6. EXECUTION (only when AutoTrade = true) ==="
input ENUM_ENTRY_MODE  InpEntryMode          = ENTRY_MARKET_NOW; // Entry mode
input double           InpZoneEntryPct       = 50.0;         // Limit price inside zone (0=far,100=near)
input int              InpArmBars            = 8;            // Setup stays armed for N setup bars
input bool             InpOneTradePerSweep   = true;         // Only one trade per liquidity sweep
input bool             InpUseFixedLot        = false;        // Use a fixed lot size
input double           InpFixedLot           = 0.10;         // Fixed lot
input double           InpRiskPercent        = 1.0;          // Risk per trade (% of balance)
input int              InpMaxSpreadPoints    = 60;           // Maximum allowed spread (points)
input bool             InpUseSessionFilter   = false;        // Restrict trading hours
input int              InpSessionStartHour   = 7;            // Session start hour (server)
input int              InpSessionEndHour     = 20;           // Session end hour (server)
input long             InpMagic              = 20260819;     // Magic number
input int              InpSlippage           = 30;           // Deviation (points)

input group "=== 7. TRADE MANAGEMENT ==="
input bool             InpUseBreakEven       = true;         // Move to break-even
input double           InpBEatR              = 1.0;          // Break-even trigger (R multiple)
input int              InpBEOffsetPoints     = 20;           // Break-even offset (points)
input bool             InpUseTrail           = true;         // ATR trailing stop
input double           InpTrailStartR        = 1.5;          // Start trailing after (R multiple)
input double           InpTrailATRMult       = 2.0;          // Trailing distance (x ATR)
input bool             InpUsePartial         = true;         // Take partial profit at TP1
input double           InpPartialPct         = 50.0;         // Partial close percentage

input group "=== 8. VISUALIZATION ==="
input bool             InpShowPanel          = true;         // Show intent dashboard
input bool             InpShowStructure      = true;         // Show HH/HL/LH/LL + BOS/CHOCH
input bool             InpShowLiquidity      = true;         // Show liquidity pools
input bool             InpShowSweeps         = true;         // Show liquidity sweeps
input bool             InpShowFVG            = true;         // Show fair value gaps
input bool             InpShowBehavior       = true;         // Show displacement candles
input bool             InpShowPlan           = true;         // Show entry / SL / TP plan
input int              InpMaxSwingLabels     = 14;           // Max swing labels drawn
input int              InpMaxPoolsPerSide    = 6;            // Max pools drawn per side
input int              InpMaxFVGDraw         = 5;            // Max FVGs drawn
input int              InpPanelX             = 12;           // Panel X offset
input int              InpPanelY             = 22;           // Panel Y offset
input color            InpColBull            = clrDodgerBlue;// Bullish colour
input color            InpColBear            = clrTomato;    // Bearish colour
input color            InpColLiqBuy          = clrGold;      // Buy-side liquidity colour
input color            InpColLiqSell         = clrAqua;      // Sell-side liquidity colour
input color            InpColSwept           = clrDimGray;   // Swept pool colour
input color            InpColPanelBg         = C'18,20,26';  // Panel background
input color            InpColPanelText       = clrGainsboro; // Panel text

input group "=== 9. MISC ==="
input bool             InpAlerts             = true;         // Popup / push alerts on ACTION
input bool             InpDebugPrint         = false;        // Verbose journal output

//+------------------------------------------------------------------+
//| Data structures                                                  |
//+------------------------------------------------------------------+
struct SwingPoint
  {
   datetime          time;        // bar time of the swing
   double            price;       // swing price
   int               shift;       // series index in its source array
   int               confirmAt;   // series index where the swing becomes known
   bool              isHigh;      // true = swing high, false = swing low
   int               label;       // LBL_HH / LBL_HL / LBL_LH / LBL_LL
   bool              broken;      // a close has traded through it
   bool              swept;       // wick took it but close came back
  };

struct BreakEvent
  {
   datetime          fromTime;    // time of the swing that got broken
   double            level;       // the broken level
   datetime          breakTime;   // time of the breaking close
   int               dir;         // +1 up, -1 down
   bool              choch;       // true = change of character, false = BOS
  };

struct TFStruct
  {
   int               trend;         // +1 bullish, -1 bearish, 0 undefined
   double            lastHH, lastHL, lastLH, lastLL;
   double            protHigh, protLow;
   datetime          protHighTime, protLowTime;
   int               lastBreakDir;
   bool              lastBreakChoch;
   datetime          lastBreakTime;
   double            lastBreakLevel;
   int               lastBreakShift;
   double            rangeHigh, rangeLow;
  };

struct LiquidityPool
  {
   double            price;
   datetime          time;
   int               side;        // +1 buy-side (highs), -1 sell-side (lows)
   int               type;        // POOL_*
   int               touches;
   bool              swept;
   datetime          sweptTime;
   double            strength;    // 0..1
   string            tag;
  };

struct SweepEvent
  {
   bool              valid;
   int               side;          // +1 buy-side taken, -1 sell-side taken
   double            level;
   double            extreme;       // wick extreme of the sweep bar
   double            excursionPts;
   bool              closedBack;
   bool              displacement;
   bool              structBreak;
   datetime          time;
   int               barShift;      // setup-TF shift of the sweep bar
   int               reactionDir;
   string            tag;
  };

struct FVGZone
  {
   double            upper, lower;
   datetime          time;
   int               dir;         // +1 bullish, -1 bearish
   double            fillRatio;   // 0 = untouched, 1 = fully filled
   bool              tapped;
   int               shift;
  };

struct BehaviorState
  {
   int               dispDir;
   double            dispScore;
   double            dispHigh, dispLow;
   datetime          dispTime;
   int               dispShift;
   bool              dispValid;
   int               consecutive;
   double            bodyRatio;
   double            wickUpRatio, wickDnRatio;
   bool              rejectUp, rejectDown;   // rejectUp = bullish rejection (long lower wick)
   double            momentum;               // 0..1 display metric
  };

struct IntentResult
  {
   int               direction;
   double            score;
   double            bull, bear;
   double            cStructure, cLiquidity, cDisplacement, cMomentum, cLocation;
   ENUM_INTENT_STATE state;
   string            headline;
  };

struct TradePlan
  {
   bool              valid;
   int               dir;
   double            zoneLow, zoneHigh;
   double            entry;
   double            sl, tp1, tp2;
   double            rr;
   string            note;
  };

struct ArmedSetup
  {
   bool              armed;
   int               dir;
   double            zoneLow, zoneHigh;
   double            sl, tp1, tp2;
   datetime          armedTime;
   datetime          sweepTime;
   int               barsLeft;
   ulong             pendingTicket;
  };

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
CTrade         g_trade;

MqlRates       g_rMacro[], g_rPrim[], g_rSetup[], g_rEntry[];
int            g_nMacro = 0, g_nPrim = 0, g_nSetup = 0, g_nEntry = 0;

SwingPoint     g_swMacro[], g_swPrim[], g_swSetup[], g_swEntry[];
BreakEvent     g_evMacro[], g_evPrim[], g_evSetup[], g_evEntry[];
TFStruct       g_stMacro, g_stPrim, g_stSetup, g_stEntry;

LiquidityPool  g_pools[];
SweepEvent     g_sweep;
FVGZone        g_fvgs[];
BehaviorState  g_beh;
IntentResult   g_intent;
TradePlan      g_plan;
ArmedSetup     g_arm;

int            g_hATRSetup = INVALID_HANDLE;
int            g_hATREntry = INVALID_HANDLE;
double         g_atrSetup  = 0.0;
double         g_atrEntry  = 0.0;

datetime       g_lastEntryBar = 0;
datetime       g_lastSetupBar = 0;
datetime       g_lastTradedSweep = 0;
datetime       g_lastAlertTime = 0;

//--- open-position bookkeeping (single position by design)
ulong          g_posTicket   = 0;
double         g_posEntry    = 0.0;
double         g_posInitSL   = 0.0;
double         g_posRisk     = 0.0;
double         g_posTP1      = 0.0;
bool           g_posPartial  = false;
bool           g_posBE       = false;
double         g_plannedTP1  = 0.0;   // scale-out level handed to the next position
bool           g_firstRun    = true;

string         g_blockFull, g_blockEmpty;

//+------------------------------------------------------------------+
//| Small utilities                                                  |
//+------------------------------------------------------------------+
double Pt()    { return SymbolInfoDouble(_Symbol, SYMBOL_POINT); }
int    Dg()    { return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); }
double Ask()   { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
double Bid()   { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
string PriceS(double p) { return DoubleToString(p, Dg()); }

string Pad(string s, int len)
  {
   int n = StringLen(s);
   if(n >= len)
      return StringSubstr(s, 0, len);
   string out = s;
   for(int i = n; i < len; i++)
      out += " ";
   return out;
  }

string BarGauge(double frac, int cells)
  {
   if(frac < 0.0)
      frac = 0.0;
   if(frac > 1.0)
      frac = 1.0;
   int filled = (int)MathRound(frac * cells);
   string s = "";
   for(int i = 0; i < cells; i++)
      s += (i < filled ? g_blockFull : g_blockEmpty);
   return s;
  }

bool IsNewBar(ENUM_TIMEFRAMES tf, datetime &store)
  {
   datetime t = (datetime)SeriesInfoInteger(_Symbol, tf, SERIES_LASTBAR_DATE);
   if(t == 0)
      return false;
   if(t != store)
     {
      store = t;
      return true;
     }
   return false;
  }

double RecencyFactor(int shift, int validBars)
  {
   if(validBars <= 0)
      return 0.0;
   if(shift > validBars)
      return 0.0;
   double f = 1.0 - (double)shift / (double)validBars;
   return 0.45 + 0.55 * f;   // never collapses fully inside the window
  }

string TrendName(int t)
  {
   if(t > 0)
      return "BULLISH";
   if(t < 0)
      return "BEARISH";
   return "RANGE";
  }

string LabelName(int lbl)
  {
   switch(lbl)
     {
      case LBL_HH:
         return "HH";
      case LBL_HL:
         return "HL";
      case LBL_LH:
         return "LH";
      case LBL_LL:
         return "LL";
     }
   return "";
  }

string StateName(ENUM_INTENT_STATE s)
  {
   switch(s)
     {
      case STATE_WATCH_LONG:
         return "WATCH LONG";
      case STATE_ACTION_LONG:
         return "ACTION LONG";
      case STATE_WATCH_SHORT:
         return "WATCH SHORT";
      case STATE_ACTION_SHORT:
         return "ACTION SHORT";
     }
   return "WAIT";
  }

string TFName(ENUM_TIMEFRAMES tf)
  {
   string s = EnumToString(tf);          // "PERIOD_H4"
   if(StringSubstr(s, 0, 7) == "PERIOD_")
      s = StringSubstr(s, 7);            // "H4"
   return s;
  }

//+------------------------------------------------------------------+
//| STAGE 1 : structure engine                                       |
//+------------------------------------------------------------------+
void DetectSwings(const MqlRates &rates[], int n, int depth, SwingPoint &out[])
  {
   ArrayResize(out, 0);
   if(n < depth * 2 + 5)
      return;

   for(int i = n - depth - 1; i >= depth; i--)     // oldest -> newest
     {
      bool isHigh = true;
      bool isLow  = true;

      for(int k = 1; k <= depth; k++)
        {
         if(rates[i].high <= rates[i + k].high || rates[i].high <= rates[i - k].high)
            isHigh = false;
         if(rates[i].low  >= rates[i + k].low  || rates[i].low  >= rates[i - k].low)
            isLow = false;
         if(!isHigh && !isLow)
            break;
        }

      if(isHigh)
        {
         int sz = ArraySize(out);
         ArrayResize(out, sz + 1);
         out[sz].time      = rates[i].time;
         out[sz].price     = rates[i].high;
         out[sz].shift     = i;
         out[sz].confirmAt = i - depth;
         out[sz].isHigh    = true;
         out[sz].label     = LBL_NONE;
         out[sz].broken    = false;
         out[sz].swept     = false;
        }

      if(isLow)
        {
         int sz = ArraySize(out);
         ArrayResize(out, sz + 1);
         out[sz].time      = rates[i].time;
         out[sz].price     = rates[i].low;
         out[sz].shift     = i;
         out[sz].confirmAt = i - depth;
         out[sz].isHigh    = false;
         out[sz].label     = LBL_NONE;
         out[sz].broken    = false;
         out[sz].swept     = false;
        }
     }
  }

//+------------------------------------------------------------------+
//| Build Structure                                                  |
//+------------------------------------------------------------------+
void BuildStructure(const MqlRates &rates[], int n, SwingPoint &sw[],
                    TFStruct &st, BreakEvent &ev[])
  {
    /*
    Walk the bars chronologically, activate swings when they become  
    known, label them HH/HL/LH/LL, and register BOS / CHOCH events.*/

   ArrayResize(ev, 0);

   st.trend          = 0;
   st.lastHH = st.lastHL = st.lastLH = st.lastLL = 0.0;
   st.protHigh = st.protLow = 0.0;
   st.protHighTime = st.protLowTime = 0;
   st.lastBreakDir   = 0;
   st.lastBreakChoch = false;
   st.lastBreakTime  = 0;
   st.lastBreakLevel = 0.0;
   st.lastBreakShift = -1;

   int nsw = ArraySize(sw);
   if(nsw < 2 || n < 10)
      return;

   int    k        = 0;      // next swing waiting for activation
   double actHigh  = 0.0, actLow = 0.0;
   datetime actHighTime = 0, actLowTime = 0;
   int    actHighIdx = -1, actLowIdx = -1;
   double lastSwHigh = 0.0, lastSwLow = 0.0;

   for(int j = n - 1; j >= 0; j--)      // oldest -> newest
     {
      //--- activate every swing that becomes visible on this bar
      while(k < nsw && sw[k].confirmAt >= j)
        {
         if(sw[k].isHigh)
           {
            sw[k].label = (lastSwHigh > 0.0 && sw[k].price > lastSwHigh) ? LBL_HH : LBL_LH;
            lastSwHigh  = sw[k].price;
            actHigh     = sw[k].price;
            actHighTime = sw[k].time;
            actHighIdx  = k;

            //--- retro check: did price already close through it while unconfirmed?
            double maxClose = -DBL_MAX;
            for(int b = sw[k].shift - 1; b >= j; b--)
               if(rates[b].close > maxClose)
                  maxClose = rates[b].close;

            if(maxClose > actHigh)
              {
               RegisterBreak(ev, st, actHighTime, actHigh, rates[j].time, j, 1);
               sw[k].broken = true;
               if(actLow > 0.0)
                 { st.protLow = actLow; st.protLowTime = actLowTime; }
               actHigh = 0.0;
               actHighIdx = -1;
              }
           }
         else
           {
            sw[k].label = (lastSwLow > 0.0 && sw[k].price < lastSwLow) ? LBL_LL : LBL_HL;
            lastSwLow   = sw[k].price;
            actLow      = sw[k].price;
            actLowTime  = sw[k].time;
            actLowIdx   = k;

            double minClose = DBL_MAX;
            for(int b = sw[k].shift - 1; b >= j; b--)
               if(rates[b].close < minClose)
                  minClose = rates[b].close;

            if(minClose < actLow)
              {
               RegisterBreak(ev, st, actLowTime, actLow, rates[j].time, j, -1);
               sw[k].broken = true;
               if(actHigh > 0.0)
                 { st.protHigh = actHigh; st.protHighTime = actHighTime; }
               actLow = 0.0;
               actLowIdx = -1;
              }
           }
         k++;
        }

      //--- upside break of the active swing high
      if(actHigh > 0.0 && rates[j].close > actHigh)
        {
         RegisterBreak(ev, st, actHighTime, actHigh, rates[j].time, j, 1);
         if(actHighIdx >= 0)
            sw[actHighIdx].broken = true;
         if(actLow > 0.0)
           { st.protLow = actLow; st.protLowTime = actLowTime; }
         actHigh = 0.0;
         actHighIdx = -1;
        }
      //--- wick-only violation of the active swing high = a sweep
      else
         if(actHigh > 0.0 && rates[j].high > actHigh && rates[j].close < actHigh)
           {
            if(actHighIdx >= 0)
               sw[actHighIdx].swept = true;
           }

      //--- downside break of the active swing low
      if(actLow > 0.0 && rates[j].close < actLow)
        {
         RegisterBreak(ev, st, actLowTime, actLow, rates[j].time, j, -1);
         if(actLowIdx >= 0)
            sw[actLowIdx].broken = true;
         if(actHigh > 0.0)
           { st.protHigh = actHigh; st.protHighTime = actHighTime; }
         actLow = 0.0;
         actLowIdx = -1;
        }
      else
         if(actLow > 0.0 && rates[j].low < actLow && rates[j].close > actLow)
           {
            if(actLowIdx >= 0)
               sw[actLowIdx].swept = true;
           }
     }

//--- harvest the latest labelled prices
   for(int i = nsw - 1; i >= 0; i--)
     {
      if(sw[i].isHigh)
        {
         if(sw[i].label == LBL_HH && st.lastHH == 0.0)
            st.lastHH = sw[i].price;
         if(sw[i].label == LBL_LH && st.lastLH == 0.0)
            st.lastLH = sw[i].price;
        }
      else
        {
         if(sw[i].label == LBL_HL && st.lastHL == 0.0)
            st.lastHL = sw[i].price;
         if(sw[i].label == LBL_LL && st.lastLL == 0.0)
            st.lastLL = sw[i].price;
        }
     }

//--- premium / discount range
   int look = MathMin(n - 1, InpEqLookback);
   double hh = -DBL_MAX, ll = DBL_MAX;
   for(int i = 0; i <= look; i++)
     {
      if(rates[i].high > hh)
         hh = rates[i].high;
      if(rates[i].low  < ll)
         ll = rates[i].low;
     }
   st.rangeHigh = hh;
   st.rangeLow  = ll;
  }

//+------------------------------------------------------------------+
//| Register a structural break and flip the trend when needed       |
//+------------------------------------------------------------------+
void RegisterBreak(BreakEvent &ev[], TFStruct &st, datetime fromTime, double level,
                   datetime breakTime, int breakShift, int dir)
  {
   bool choch = (st.trend != 0 && st.trend != dir);

   int sz = ArraySize(ev);
   ArrayResize(ev, sz + 1);
   ev[sz].fromTime  = fromTime;
   ev[sz].level     = level;
   ev[sz].breakTime = breakTime;
   ev[sz].dir       = dir;
   ev[sz].choch     = choch;

   st.trend          = dir;
   st.lastBreakDir   = dir;
   st.lastBreakChoch = choch;
   st.lastBreakTime  = breakTime;
   st.lastBreakLevel = level;
   st.lastBreakShift = breakShift;
  }

//+------------------------------------------------------------------+
//| Analyze TimeFrames                                               |
//+------------------------------------------------------------------+
int AnalyzeTF(ENUM_TIMEFRAMES tf, int bars, int depth, MqlRates &rates[],
              SwingPoint &sw[], TFStruct &st, BreakEvent &ev[])
  {
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, tf, 0, bars, rates);
   if(copied < depth * 2 + 20)
      return 0;

   DetectSwings(rates, copied, depth, sw);
   BuildStructure(rates, copied, sw, st, ev);
   return copied;
  }

//+------------------------------------------------------------------+
//| STAGE 2 : liquidity engine                                       |
//+------------------------------------------------------------------+
void AddPool(double price, datetime time, int side, int type, string tag, double strength)
  {
   if(price <= 0.0)
      return;

   double tol = g_atrSetup * InpEqualTolATR;
   if(tol <= 0.0)
      tol = 10 * Pt();

//--- merge with an existing pool at the same level
   for(int i = 0; i < ArraySize(g_pools); i++)
     {
      if(g_pools[i].side != side)
         continue;
      if(MathAbs(g_pools[i].price - price) <= tol)
        {
         g_pools[i].touches++;
         if(time > g_pools[i].time)
            g_pools[i].time = time;
         //--- an equal-level cluster is stronger than a single swing
         g_pools[i].strength = MathMin(1.0, g_pools[i].strength + 0.22);
         if(InpUseEqualPools && g_pools[i].type == POOL_SWING)
           {
            g_pools[i].type = POOL_EQUAL;
            g_pools[i].tag  = (side > 0 ? "EQH" : "EQL");
           }
         return;
        }
     }

   int sz = ArraySize(g_pools);
   ArrayResize(g_pools, sz + 1);
   g_pools[sz].price     = price;
   g_pools[sz].time      = time;
   g_pools[sz].side      = side;
   g_pools[sz].type      = type;
   g_pools[sz].touches   = 1;
   g_pools[sz].swept     = false;
   g_pools[sz].sweptTime = 0;
   g_pools[sz].strength  = strength;
   g_pools[sz].tag       = tag;
  }

void BuildLiquidityMap()
  {
   ArrayResize(g_pools, 0);

//--- swing liquidity from the primary and setup timeframes
   if(InpUseSwingPools)
     {
      int added = 0;
      for(int i = ArraySize(g_swPrim) - 1; i >= 0 && added < 24; i--)
        {
         if(g_swPrim[i].broken)
            continue;
         AddPool(g_swPrim[i].price, g_swPrim[i].time,
                 g_swPrim[i].isHigh ? 1 : -1, POOL_SWING,
                 g_swPrim[i].isHigh ? "SWH" : "SWL", 0.45);
         added++;
        }

      added = 0;
      for(int i = ArraySize(g_swSetup) - 1; i >= 0 && added < 24; i--)
        {
         if(g_swSetup[i].broken)
            continue;
         AddPool(g_swSetup[i].price, g_swSetup[i].time,
                 g_swSetup[i].isHigh ? 1 : -1, POOL_SWING,
                 g_swSetup[i].isHigh ? "swh" : "swl", 0.30);
         added++;
        }
     }

//--- previous day / week extremes
   if(InpUseDailyPools)
     {
      double pdh = iHigh(_Symbol, PERIOD_D1, 1);
      double pdl = iLow(_Symbol, PERIOD_D1, 1);
      datetime pdt = iTime(_Symbol, PERIOD_D1, 1);
      if(pdh > 0.0)
         AddPool(pdh, pdt, 1, POOL_PDH, "PDH", 0.70);
      if(pdl > 0.0)
         AddPool(pdl, pdt, -1, POOL_PDL, "PDL", 0.70);
     }

   if(InpUseWeeklyPools)
     {
      double pwh = iHigh(_Symbol, PERIOD_W1, 1);
      double pwl = iLow(_Symbol, PERIOD_W1, 1);
      datetime pwt = iTime(_Symbol, PERIOD_W1, 1);
      if(pwh > 0.0)
         AddPool(pwh, pwt, 1, POOL_PWH, "PWH", 0.85);
      if(pwl > 0.0)
         AddPool(pwl, pwt, -1, POOL_PWL, "PWL", 0.85);
     }
  }

//+------------------------------------------------------------------+
//| Scan Sweeps                                                      |
//+------------------------------------------------------------------+
void ScanSweeps()
  {
   g_sweep.valid        = false;
   g_sweep.side         = 0;
   g_sweep.level        = 0.0;
   g_sweep.extreme      = 0.0;
   g_sweep.excursionPts = 0.0;
   g_sweep.closedBack   = false;
   g_sweep.displacement = false;
   g_sweep.structBreak  = false;
   g_sweep.time         = 0;
   g_sweep.barShift     = -1;
   g_sweep.reactionDir  = 0;
   g_sweep.tag          = "";

   if(g_nSetup < 20 || g_atrSetup <= 0.0)
      return;

   double minPen  = g_atrSetup * InpMinPenetrationATR;
   int    maxScan = MathMin(InpSweepScanBars, g_nSetup - 5);
   int    best    = -1;
   int    bestPool = -1;

   for(int j = 1; j <= maxScan; j++)
     {
      for(int p = 0; p < ArraySize(g_pools); p++)
        {
         if(g_pools[p].time >= g_rSetup[j].time)
            continue;

         if(g_pools[p].side > 0)
           {
            //--- buy-side liquidity above the market
            if(g_rSetup[j].high > g_pools[p].price + minPen &&
               g_rSetup[j].close < g_pools[p].price)
              {
               g_pools[p].swept     = true;
               g_pools[p].sweptTime = g_rSetup[j].time;
               if(best < 0 || j < best)
                 { best = j; bestPool = p; }
              }
           }
         else
           {
            //--- sell-side liquidity below the market
            if(g_rSetup[j].low < g_pools[p].price - minPen &&
               g_rSetup[j].close > g_pools[p].price)
              {
               g_pools[p].swept     = true;
               g_pools[p].sweptTime = g_rSetup[j].time;
               if(best < 0 || j < best)
                 { best = j; bestPool = p; }
              }
           }
        }
     }

   if(best < 0 || bestPool < 0)
      return;

   int j = best;
   int p = bestPool;

   g_sweep.valid      = true;
   g_sweep.side       = g_pools[p].side;
   g_sweep.level      = g_pools[p].price;
   g_sweep.extreme    = (g_pools[p].side > 0 ? g_rSetup[j].high : g_rSetup[j].low);
   g_sweep.closedBack = true;
   g_sweep.time       = g_rSetup[j].time;
   g_sweep.barShift   = j;
   g_sweep.tag        = g_pools[p].tag;
   g_sweep.excursionPts = MathAbs(g_sweep.extreme - g_sweep.level) / Pt();

//--- reaction: opposite displacement inside the allowed window
   int wanted = (g_sweep.side > 0 ? -1 : 1);
   for(int b = j; b >= MathMax(1, j - InpSweepReactBars); b--)
     {
      int    dir   = 0;
      double score = 0.0;
      if(IsDisplacementBar(g_rSetup, b, g_atrSetup, dir, score) && dir == wanted)
        {
         g_sweep.displacement = true;
         g_sweep.reactionDir  = dir;
         break;
        }
     }

//--- reaction: a structural break in the same direction after the sweep
   if(g_stSetup.lastBreakDir == wanted && g_stSetup.lastBreakTime >= g_sweep.time)
      g_sweep.structBreak = true;
   else
      if(g_stEntry.lastBreakDir == wanted && g_stEntry.lastBreakTime >= g_sweep.time)
         g_sweep.structBreak = true;
  }

//+------------------------------------------------------------------+
//| STAGE 3 : price behaviour engine                                 |
//+------------------------------------------------------------------+
bool IsDisplacementBar(const MqlRates &r[], int i, double atr, int &dir, double &score)
  {
   dir   = 0;
   score = 0.0;
   if(atr <= 0.0 || i < 0)
      return false;

   double range = r[i].high - r[i].low;
   if(range <= 0.0)
      return false;

   double body      = MathAbs(r[i].close - r[i].open);
   double bodyRatio = body / range;
   double rangeMult = range / atr;

   if(rangeMult < InpDispATRMult || bodyRatio < InpDispBodyRatio)
      return false;

   dir   = (r[i].close > r[i].open) ? 1 : -1;
   score = MathMin(1.0, 0.60 * MathMin(1.0, rangeMult / (InpDispATRMult * 2.0)) + 0.40 * bodyRatio);
   return true;
  }

//+------------------------------------------------------------------+
//| Analyze Behavior                                                 |
//+------------------------------------------------------------------+
void AnalyzeBehavior()
  {
   g_beh.dispValid   = false;
   g_beh.dispDir     = 0;
   g_beh.dispScore   = 0.0;
   g_beh.dispHigh    = 0.0;
   g_beh.dispLow     = 0.0;
   g_beh.dispTime    = 0;
   g_beh.dispShift   = -1;
   g_beh.consecutive = 0;
   g_beh.bodyRatio   = 0.0;
   g_beh.wickUpRatio = 0.0;
   g_beh.wickDnRatio = 0.0;
   g_beh.rejectUp    = false;
   g_beh.rejectDown  = false;
   g_beh.momentum    = 0.0;

   if(g_nSetup < 10 || g_atrSetup <= 0.0)
      return;

//--- most recent displacement leg on the setup timeframe
   int scan = MathMin(InpDispScanBars, g_nSetup - 3);
   for(int i = 1; i <= scan; i++)
     {
      int    dir   = 0;
      double score = 0.0;
      if(IsDisplacementBar(g_rSetup, i, g_atrSetup, dir, score))
        {
         g_beh.dispValid = true;
         g_beh.dispDir   = dir;
         g_beh.dispScore = score;
         g_beh.dispTime  = g_rSetup[i].time;
         g_beh.dispShift = i;

         //--- widen the leg over adjacent same-direction candles
         double hi = g_rSetup[i].high;
         double lo = g_rSetup[i].low;
         for(int k = i + 1; k <= MathMin(i + 3, g_nSetup - 1); k++)
           {
            bool same = (dir > 0) ? (g_rSetup[k].close > g_rSetup[k].open)
                        : (g_rSetup[k].close < g_rSetup[k].open);
            if(!same)
               break;
            hi = MathMax(hi, g_rSetup[k].high);
            lo = MathMin(lo, g_rSetup[k].low);
           }
         for(int k = i - 1; k >= 1; k--)
           {
            bool same = (dir > 0) ? (g_rSetup[k].close > g_rSetup[k].open)
                        : (g_rSetup[k].close < g_rSetup[k].open);
            if(!same)
               break;
            hi = MathMax(hi, g_rSetup[k].high);
            lo = MathMin(lo, g_rSetup[k].low);
           }
         g_beh.dispHigh = hi;
         g_beh.dispLow  = lo;
         break;
        }
     }

//--- consecutive directional candles (momentum proxy)
   if(g_nSetup > 6)
     {
      int dir = (g_rSetup[1].close > g_rSetup[1].open) ? 1 : -1;
      int cnt = 0;
      for(int i = 1; i <= 6; i++)
        {
         int d = (g_rSetup[i].close > g_rSetup[i].open) ? 1 : -1;
         if(d != dir)
            break;
         cnt++;
        }
      g_beh.consecutive = cnt * dir;
     }

//--- rejection profile of the last closed setup candle
   double range = g_rSetup[1].high - g_rSetup[1].low;
   if(range > 0.0)
     {
      double body   = MathAbs(g_rSetup[1].close - g_rSetup[1].open);
      double upWick = g_rSetup[1].high - MathMax(g_rSetup[1].close, g_rSetup[1].open);
      double dnWick = MathMin(g_rSetup[1].close, g_rSetup[1].open) - g_rSetup[1].low;

      g_beh.bodyRatio   = body / range;
      g_beh.wickUpRatio = upWick / range;
      g_beh.wickDnRatio = dnWick / range;

      g_beh.rejectUp   = (g_beh.wickDnRatio >= InpRejWickRatio &&
                          g_rSetup[1].close > g_rSetup[1].open);
      g_beh.rejectDown = (g_beh.wickUpRatio >= InpRejWickRatio &&
                          g_rSetup[1].close < g_rSetup[1].open);
     }

   double mom = 0.0;
   mom += 0.5 * MathMin(1.0, MathAbs((double)g_beh.consecutive) / 4.0);
   mom += 0.5 * g_beh.bodyRatio;
   g_beh.momentum = MathMin(1.0, mom);
  }

//+------------------------------------------------------------------+
//| Fair value gaps / imbalances on the setup timeframe              |
//+------------------------------------------------------------------+
void DetectFVGs()
  {
   ArrayResize(g_fvgs, 0);
   if(g_nSetup < 10 || g_atrSetup <= 0.0)
      return;

   double minSize = g_atrSetup * InpMinFVGATR;
   int    scan    = MathMin(InpFVGScanBars, g_nSetup - 4);

   for(int i = 1; i <= scan; i++)
     {
      double up = 0.0, lo = 0.0;
      int    dir = 0;

      if(g_rSetup[i].low > g_rSetup[i + 2].high)
        {
         dir = 1;
         lo  = g_rSetup[i + 2].high;
         up  = g_rSetup[i].low;
        }
      else
         if(g_rSetup[i].high < g_rSetup[i + 2].low)
           {
            dir = -1;
            lo  = g_rSetup[i].high;
            up  = g_rSetup[i + 2].low;
           }

      if(dir == 0)
         continue;
      if((up - lo) < minSize)
         continue;

      //--- how deeply has price traded back into the gap since it formed?
      double deepest = (dir > 0 ? up : lo);
      bool   tapped  = false;
      for(int b = i - 1; b >= 0; b--)
        {
         if(dir > 0)
           {
            if(g_rSetup[b].low <= up)
              { tapped = true; deepest = MathMin(deepest, g_rSetup[b].low); }
           }
         else
           {
            if(g_rSetup[b].high >= lo)
              { tapped = true; deepest = MathMax(deepest, g_rSetup[b].high); }
           }
        }

      double ratio = 0.0;
      double width = up - lo;
      if(width > 0.0)
         ratio = (dir > 0) ? (up - deepest) / width : (deepest - lo) / width;
      ratio = MathMax(0.0, MathMin(1.0, ratio));

      if(ratio > InpMaxFVGFill)
         continue;                                  // effectively consumed

      int sz = ArraySize(g_fvgs);
      ArrayResize(g_fvgs, sz + 1);
      g_fvgs[sz].upper     = up;
      g_fvgs[sz].lower     = lo;
      g_fvgs[sz].dir       = dir;
      g_fvgs[sz].time      = g_rSetup[i].time;
      g_fvgs[sz].fillRatio = ratio;
      g_fvgs[sz].tapped    = tapped;
      g_fvgs[sz].shift     = i;
     }
  }

//+------------------------------------------------------------------+
//| Most recent usable FVG in a given direction                      |
//+------------------------------------------------------------------+
int FindFVG(int dir)
  {
   int best = -1;
   for(int i = 0; i < ArraySize(g_fvgs); i++)
     {
      if(g_fvgs[i].dir != dir)
         continue;
      if(best < 0 || g_fvgs[i].shift < g_fvgs[best].shift)
         best = i;
     }
   return best;
  }

//+------------------------------------------------------------------+
//| STAGE 4 : intent scoring                                         |
//+------------------------------------------------------------------+
void ScoreIntent()
  {
   double bull = 0.0, bear = 0.0;
   double sStruct = 0.0, sLiq = 0.0, sDisp = 0.0, sLoc = 0.0;

//--- (a) higher timeframe bias 
   if(g_stMacro.trend > 0)
      bull += InpWHTF * 0.60;
   else
      if(g_stMacro.trend < 0)
         bear += InpWHTF * 0.60;

   if(g_stPrim.trend > 0)
      bull += InpWHTF * 0.40;
   else
      if(g_stPrim.trend < 0)
         bear += InpWHTF * 0.40;

//--- (b) liquidity 
   if(g_sweep.valid)
     {
      double rec = RecencyFactor(g_sweep.barShift, InpSweepValidBars);
      double q   = rec;
      if(g_sweep.displacement)
         q *= 1.00;
      else
         q *= 0.65;
      if(g_sweep.structBreak)
         q *= 1.00;
      else
         q *= 0.80;

      if(g_sweep.side < 0)
         bull += InpWLiq * q;    // sell-side taken -> bullish
      else
         bear += InpWLiq * q;    // buy-side taken  -> bearish

      sLiq = q;
     }

//--- (c) displacement 
   if(g_beh.dispValid)
     {
      double rec = RecencyFactor(g_beh.dispShift, InpDispScanBars);
      double q   = g_beh.dispScore * MathMax(0.5, rec);
      if(g_beh.dispDir > 0)
         bull += InpWDisp * q;
      else
         bear += InpWDisp * q;
      sDisp = q;
     }

//--- (d) BOS / CHOCH 
   if(g_stSetup.lastBreakDir > 0)
      bull += InpWBOS * 0.60;
   else
      if(g_stSetup.lastBreakDir < 0)
         bear += InpWBOS * 0.60;

   if(g_stEntry.lastBreakDir > 0)
      bull += InpWBOS * 0.40;
   else
      if(g_stEntry.lastBreakDir < 0)
         bear += InpWBOS * 0.40;

//--- (e) fair value gaps 
   int fBull = FindFVG(1);
   int fBear = FindFVG(-1);
   double px = Bid();

   if(fBull >= 0)
     {
      bull += InpWFVG;
      bool inside = (px <= g_fvgs[fBull].upper && px >= g_fvgs[fBull].lower);
      if(inside)
         bull += InpWRetest;
      else
         if(g_fvgs[fBull].fillRatio > 0.10)
            bull += InpWRetest * 0.55;
     }
   if(fBear >= 0)
     {
      bear += InpWFVG;
      bool inside = (px <= g_fvgs[fBear].upper && px >= g_fvgs[fBear].lower);
      if(inside)
         bear += InpWRetest;
      else
         if(g_fvgs[fBear].fillRatio > 0.10)
            bear += InpWRetest * 0.55;
     }

//--- (f) rejection 
   if(g_beh.rejectUp)
      bull += InpWReject;
   if(g_beh.rejectDown)
      bear += InpWReject;

//--- (g) premium / discount location 
   double rHigh = g_stPrim.rangeHigh;
   double rLow  = g_stPrim.rangeLow;
   if(rHigh > rLow)
     {
      double eq   = (rHigh + rLow) * 0.5;
      double half = (rHigh - rLow) * 0.5;
      double dev  = (px - eq) / half;                 // -1 = deep discount, +1 = deep premium
      dev = MathMax(-1.0, MathMin(1.0, dev));
      if(dev < 0.0)
         bull += InpWLoc * MathAbs(dev);
      else
         bear += InpWLoc * dev;
      sLoc = MathAbs(dev);
     }

//--- structural component for the gauge 
   double stAlign = 0.0;
   if(g_stMacro.trend != 0)
      stAlign += 0.34;
   if(g_stPrim.trend  != 0)
      stAlign += 0.33;
   if(g_stSetup.lastBreakDir != 0)
      stAlign += 0.33;
   sStruct = stAlign;

//--- resolve direction with a conflict penalty 
   double hi = MathMax(bull, bear);
   double lo = MathMin(bull, bear);
   double net = hi - InpConflictWeight * lo;
   if(net < 0.0)
      net = 0.0;
   if(net > 100.0)
      net = 100.0;

   g_intent.bull      = bull;
   g_intent.bear      = bear;
   g_intent.score     = net;
   g_intent.direction = (hi <= 0.0) ? 0 : ((bull >= bear) ? 1 : -1);

   g_intent.cStructure    = sStruct;
   g_intent.cLiquidity    = sLiq;
   g_intent.cDisplacement = sDisp;
   g_intent.cMomentum     = g_beh.momentum;
   g_intent.cLocation     = sLoc;

//--- decision gates 
   int d = g_intent.direction;
   bool gates = (d != 0);

   if(gates && InpRequireSweep)
      gates = (g_sweep.valid && g_sweep.side == -d &&
               g_sweep.barShift <= InpSweepValidBars);

   if(gates && InpRequireDisplacement)
      gates = (g_beh.dispValid && g_beh.dispDir == d);

   if(gates && InpRequireBOS)
      gates = (g_stSetup.lastBreakDir == d || g_stEntry.lastBreakDir == d);

   if(gates && InpRequireFVG)
      gates = (FindFVG(d) >= 0);

   if(g_intent.score >= InpActionScore && gates)
      g_intent.state = (d > 0) ? STATE_ACTION_LONG : STATE_ACTION_SHORT;
   else
      if(g_intent.score >= InpWatchScore && d != 0)
         g_intent.state = (d > 0) ? STATE_WATCH_LONG : STATE_WATCH_SHORT;
      else
         g_intent.state = STATE_WAIT;

//--- human-readable headline
   if(g_intent.score >= 86.0)
      g_intent.headline = "HIGH CONVICTION";
   else
      if(g_intent.score >= 71.0)
         g_intent.headline = "STRONG";
      else
         if(g_intent.score >= 51.0)
            g_intent.headline = "DEVELOPING";
         else
            if(g_intent.score >= 31.0)
               g_intent.headline = "WEAK";
            else
               g_intent.headline = "NO EDGE";
  }

//+------------------------------------------------------------------+
//| Nearest opposing liquidity target beyond a price                 |
//+------------------------------------------------------------------+
double FindTarget(int dir, double from, double minDist, double beyond)
  {
   double best = 0.0;
   for(int i = 0; i < ArraySize(g_pools); i++)
     {
      if(g_pools[i].swept)
         continue;
      if(dir > 0)
        {
         if(g_pools[i].side <= 0)
            continue;
         if(g_pools[i].price <= from + minDist)
            continue;
         if(beyond > 0.0 && g_pools[i].price <= beyond + minDist * 0.5)
            continue;
         if(best == 0.0 || g_pools[i].price < best)
            best = g_pools[i].price;
        }
      else
        {
         if(g_pools[i].side >= 0)
            continue;
         if(g_pools[i].price >= from - minDist)
            continue;
         if(beyond > 0.0 && g_pools[i].price >= beyond - minDist * 0.5)
            continue;
         if(best == 0.0 || g_pools[i].price > best)
            best = g_pools[i].price;
        }
     }
   return best;
  }

//+------------------------------------------------------------------+
//| STAGE 5 : trade plan                                             |
//+------------------------------------------------------------------+
void BuildPlan()
  {
   g_plan.valid = false;
   g_plan.dir   = 0;
   g_plan.note  = "";

   int d = g_intent.direction;
   if(d == 0 || g_intent.state == STATE_WAIT)
      return;

   double atr = (g_atrSetup > 0.0 ? g_atrSetup : g_atrEntry);
   if(atr <= 0.0)
      return;

   double zLow = 0.0, zHigh = 0.0;
   int f = FindFVG(d);

   if(f >= 0)
     {
      zLow  = g_fvgs[f].lower;
      zHigh = g_fvgs[f].upper;
      g_plan.note = "FVG zone";
     }
   else
      if(g_beh.dispValid && g_beh.dispDir == d && g_beh.dispHigh > g_beh.dispLow)
        {
         //--- optimal trade entry band of the displacement leg
         double legLow  = g_beh.dispLow;
         double legHigh = g_beh.dispHigh;
         double range   = legHigh - legLow;
         if(d > 0)
           {
            zHigh = legHigh - 0.62 * range;
            zLow  = legHigh - 0.79 * range;
           }
         else
           {
            zLow  = legLow + 0.62 * range;
            zHigh = legLow + 0.79 * range;
           }
         g_plan.note = "OTE band";
        }
      else
        {
         double px = (d > 0 ? Ask() : Bid());
         zLow  = px - atr * 0.25;
         zHigh = px + atr * 0.25;
         g_plan.note = "market band";
        }

   if(zHigh < zLow)
     {
      double t = zHigh;
      zHigh = zLow;
      zLow = t;
     }

//--- invalidation: beyond the sweep extreme / protected level 
   double inval = 0.0;
   if(d > 0)
     {
      inval = zLow;
      if(g_sweep.valid && g_sweep.side < 0 && g_sweep.extreme > 0.0)
         inval = MathMin(inval, g_sweep.extreme);
      if(g_stSetup.protLow > 0.0)
         inval = MathMin(inval, g_stSetup.protLow);
      if(g_beh.dispValid && g_beh.dispDir > 0)
         inval = MathMin(inval, g_beh.dispLow);
      g_plan.sl = inval - atr * InpSLBufferATR;
     }
   else
     {
      inval = zHigh;
      if(g_sweep.valid && g_sweep.side > 0 && g_sweep.extreme > 0.0)
         inval = MathMax(inval, g_sweep.extreme);
      if(g_stSetup.protHigh > 0.0)
         inval = MathMax(inval, g_stSetup.protHigh);
      if(g_beh.dispValid && g_beh.dispDir < 0)
         inval = MathMax(inval, g_beh.dispHigh);
      g_plan.sl = inval + atr * InpSLBufferATR;
     }

//--- reference entry 
   double entry;
   if(InpEntryMode == ENTRY_MARKET_NOW)
      entry = (d > 0 ? Ask() : Bid());
   else
     {
      double pct = MathMax(0.0, MathMin(100.0, InpZoneEntryPct)) / 100.0;
      entry = (d > 0) ? (zLow + (zHigh - zLow) * pct)
              : (zHigh - (zHigh - zLow) * pct);
     }

   double risk = MathAbs(entry - g_plan.sl);
   if(risk <= atr * 0.05)
      return;

//--- targets from the liquidity map 
   double minDist = atr * InpMinTPDistATR;
   double tp1 = FindTarget(d, entry, minDist, 0.0);
   if(tp1 == 0.0)
      tp1 = (d > 0) ? entry + risk * InpDefaultRR : entry - risk * InpDefaultRR;

   double tp2 = FindTarget(d, entry, minDist, tp1);
   if(tp2 == 0.0)
      tp2 = (d > 0) ? entry + risk * (InpDefaultRR + 1.0)
            : entry - risk * (InpDefaultRR + 1.0);

   g_plan.valid    = true;
   g_plan.dir      = d;
   g_plan.zoneLow  = zLow;
   g_plan.zoneHigh = zHigh;
   g_plan.entry    = entry;
   g_plan.tp1      = tp1;
   g_plan.tp2      = tp2;
   g_plan.rr       = MathAbs(tp1 - entry) / risk;
  }

//+------------------------------------------------------------------+
//| Master analysis pass                                             |
//+------------------------------------------------------------------+
bool RunAnalysis()
  {
//--- ATR values
   double buf[];
   ArraySetAsSeries(buf, true);
   if(g_hATRSetup != INVALID_HANDLE && CopyBuffer(g_hATRSetup, 0, 0, 3, buf) > 0)
      g_atrSetup = buf[0];
   if(g_hATREntry != INVALID_HANDLE && CopyBuffer(g_hATREntry, 0, 0, 3, buf) > 0)
      g_atrEntry = buf[0];

//--- structure on four timeframes
   g_nMacro = AnalyzeTF(InpMacroTF,   InpBarsMacro,   InpSwingDepthMacro,
                        g_rMacro, g_swMacro, g_stMacro, g_evMacro);
   g_nPrim  = AnalyzeTF(InpPrimaryTF, InpBarsPrimary, InpSwingDepthPrimary,
                        g_rPrim,  g_swPrim,  g_stPrim,  g_evPrim);
   g_nSetup = AnalyzeTF(InpSetupTF,   InpBarsSetup,   InpSwingDepthSetup,
                        g_rSetup, g_swSetup, g_stSetup, g_evSetup);
   g_nEntry = AnalyzeTF(InpEntryTF,   InpBarsEntry,   InpSwingDepthEntry,
                        g_rEntry, g_swEntry, g_stEntry, g_evEntry);

   if(g_nSetup == 0 || g_nPrim == 0)
      return false;

   BuildLiquidityMap();
   ScanSweeps();
   AnalyzeBehavior();
   DetectFVGs();
   ScoreIntent();
   BuildPlan();

   if(InpDebugPrint)
      PrintFormat("[MIE] %s | macro=%s prim=%s setup=%s | sweep=%s | disp=%d | score=%.1f | %s",
                  TFName(InpSetupTF), TrendName(g_stMacro.trend), TrendName(g_stPrim.trend),
                  TrendName(g_stSetup.trend), (g_sweep.valid ? g_sweep.tag : "none"),
                  g_beh.dispDir, g_intent.score, StateName(g_intent.state));

   return true;
  }

//+------------------------------------------------------------------+
//| Object helpers                                                   |
//+------------------------------------------------------------------+
void SetCommon(string name, color c, bool back = false, bool selectable = false)
  {
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_BACK, back);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
  }

void MakeTrend(string name, datetime t1, double p1, datetime t2, double p2,
               color c, int width, ENUM_LINE_STYLE style, bool ray = false)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray);
   SetCommon(name, c);
  }

void MakeRect(string name, datetime t1, double p1, datetime t2, double p2,
              color c, bool fill)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_FILL, fill);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   SetCommon(name, c, true);
  }

void MakeText(string name, datetime t, double p, string txt, color c, int size = 8)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   SetCommon(name, c);
  }

void MakeLabel(string name, int x, int y, string txt, color c, int size = 8,
               string font = "Consolas")
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   SetCommon(name, c);
  }

//+------------------------------------------------------------------+
//| Chart layer                                                      |
//+------------------------------------------------------------------+
datetime FutureTime(int barsAhead)
  {
   return TimeCurrent() + (datetime)(PeriodSeconds(PERIOD_CURRENT) * barsAhead);
  }

void DrawStructureLayer()
  {
   ObjectsDeleteAll(0, PFX + "SW", -1, -1);
   ObjectsDeleteAll(0, PFX + "BK", -1, -1);
   if(!InpShowStructure)
      return;

//--- swing labels from the primary timeframe
   int drawn = 0;
   for(int i = ArraySize(g_swPrim) - 1; i >= 0 && drawn < InpMaxSwingLabels; i--)
     {
      if(g_swPrim[i].label == LBL_NONE)
         continue;
      color c = (g_swPrim[i].label == LBL_HH || g_swPrim[i].label == LBL_HL)
                ? InpColBull : InpColBear;
      double off = (g_atrSetup > 0.0 ? g_atrSetup * 0.5 : 10 * Pt());
      double p   = g_swPrim[i].price + (g_swPrim[i].isHigh ? off : -off);
      MakeText(PFX + "SW" + IntegerToString(i), g_swPrim[i].time, p,
               LabelName(g_swPrim[i].label), c, 8);
      drawn++;
     }

//--- last few BOS / CHOCH events on the primary and setup TFs
   DrawBreaks(g_evPrim, "P", 6, 2);
   DrawBreaks(g_evSetup, "S", 5, 1);
  }

void DrawBreaks(const BreakEvent &ev[], string tag, int maxDraw, int width)
  {
   int n = ArraySize(ev);
   int start = MathMax(0, n - maxDraw);
   for(int i = start; i < n; i++)
     {
      color c = (ev[i].dir > 0 ? InpColBull : InpColBear);
      string nm = PFX + "BK" + tag + IntegerToString(i);
      MakeTrend(nm, ev[i].fromTime, ev[i].level, ev[i].breakTime, ev[i].level,
                c, width, (ev[i].choch ? STYLE_DASH : STYLE_SOLID));
      MakeText(nm + "t", ev[i].breakTime, ev[i].level,
               (ev[i].choch ? "CHOCH" : "BOS"), c, 7);
     }
  }

void DrawLiquidityLayer()
  {
   ObjectsDeleteAll(0, PFX + "LQ", -1, -1);
   if(!InpShowLiquidity)
      return;

   datetime tEnd = FutureTime(12);
   int upDrawn = 0, dnDrawn = 0;

   for(int i = 0; i < ArraySize(g_pools); i++)
     {
      if(g_pools[i].side > 0 && upDrawn >= InpMaxPoolsPerSide)
         continue;
      if(g_pools[i].side < 0 && dnDrawn >= InpMaxPoolsPerSide)
         continue;

      color c;
      if(g_pools[i].swept)
         c = InpColSwept;
      else
         c = (g_pools[i].side > 0 ? InpColLiqBuy : InpColLiqSell);

      int w = (g_pools[i].type == POOL_PWH || g_pools[i].type == POOL_PWL) ? 2 : 1;
      if(g_pools[i].type == POOL_EQUAL)
         w = 2;

      string nm = PFX + "LQ" + IntegerToString(i);
      MakeTrend(nm, g_pools[i].time, g_pools[i].price, tEnd, g_pools[i].price,
                c, w, (g_pools[i].swept ? STYLE_DOT : STYLE_SOLID));

      string txt = g_pools[i].tag;
      if(g_pools[i].touches > 1)
         txt += " x" + IntegerToString(g_pools[i].touches);
      if(g_pools[i].swept)
         txt += " (swept)";
      MakeText(nm + "t", tEnd, g_pools[i].price, txt, c, 7);

      if(g_pools[i].side > 0)
         upDrawn++;
      else
         dnDrawn++;
     }

//--- highlight the active sweep
   ObjectsDeleteAll(0, PFX + "SWP", -1, -1);
   if(InpShowSweeps && g_sweep.valid)
     {
      color c = (g_sweep.side > 0 ? InpColBear : InpColBull);
      string nm = PFX + "SWP0";
      MakeTrend(nm, g_sweep.time, g_sweep.level, g_sweep.time, g_sweep.extreme,
                c, 3, STYLE_SOLID);
      string lab = StringFormat("SWEEP %s %.0fp%s%s",
                                (g_sweep.side > 0 ? "BSL" : "SSL"),
                                g_sweep.excursionPts,
                                (g_sweep.displacement ? " +DISP" : ""),
                                (g_sweep.structBreak ? " +BOS" : ""));
      MakeText(nm + "t", g_sweep.time, g_sweep.extreme, lab, c, 7);
     }
  }

void DrawFVGLayer()
  {
   ObjectsDeleteAll(0, PFX + "FVG", -1, -1);
   if(!InpShowFVG)
      return;

   datetime tEnd = FutureTime(6);
   int drawn = 0;
   for(int i = 0; i < ArraySize(g_fvgs) && drawn < InpMaxFVGDraw; i++)
     {
      color c = (g_fvgs[i].dir > 0 ? InpColBull : InpColBear);
      string nm = PFX + "FVG" + IntegerToString(i);
      MakeRect(nm, g_fvgs[i].time, g_fvgs[i].lower, tEnd, g_fvgs[i].upper, c, true);
      drawn++;
     }
  }

void DrawBehaviorLayer()
  {
   ObjectsDeleteAll(0, PFX + "DSP", -1, -1);
   if(!InpShowBehavior || !g_beh.dispValid)
      return;

   color c = (g_beh.dispDir > 0 ? InpColBull : InpColBear);
   double p = (g_beh.dispDir > 0 ? g_beh.dispLow : g_beh.dispHigh);
   double off = (g_atrSetup > 0.0 ? g_atrSetup * 0.35 : 8 * Pt());
   MakeText(PFX + "DSP0", g_beh.dispTime, p + (g_beh.dispDir > 0 ? -off : off),
            StringFormat("DISP %.0f%%", g_beh.dispScore * 100.0), c, 7);
   MakeTrend(PFX + "DSP1", g_beh.dispTime, g_beh.dispLow, g_beh.dispTime, g_beh.dispHigh,
             c, 4, STYLE_SOLID);
  }

void DrawPlanLayer()
  {
   ObjectsDeleteAll(0, PFX + "PL", -1, -1);
   if(!InpShowPlan || !g_plan.valid)
      return;

   datetime t1 = TimeCurrent() - (datetime)(PeriodSeconds(PERIOD_CURRENT) * 4);
   datetime t2 = FutureTime(18);
   color c = (g_plan.dir > 0 ? InpColBull : InpColBear);

   MakeRect(PFX + "PLzone", t1, g_plan.zoneLow, t2, g_plan.zoneHigh, c, true);
   MakeText(PFX + "PLzt", t2, (g_plan.zoneLow + g_plan.zoneHigh) * 0.5, "ENTRY", c, 7);

   MakeTrend(PFX + "PLsl", t1, g_plan.sl, t2, g_plan.sl, clrRed, 1, STYLE_DASH);
   MakeText(PFX + "PLslt", t2, g_plan.sl, "INVALIDATION " + PriceS(g_plan.sl), clrRed, 7);

   MakeTrend(PFX + "PLtp1", t1, g_plan.tp1, t2, g_plan.tp1, clrLimeGreen, 1, STYLE_DASH);
   MakeText(PFX + "PLtp1t", t2, g_plan.tp1, "TP1 " + PriceS(g_plan.tp1), clrLimeGreen, 7);

   MakeTrend(PFX + "PLtp2", t1, g_plan.tp2, t2, g_plan.tp2, clrSeaGreen, 1, STYLE_DOT);
   MakeText(PFX + "PLtp2t", t2, g_plan.tp2, "TP2 " + PriceS(g_plan.tp2), clrSeaGreen, 7);
  }

//+------------------------------------------------------------------+
//| Dashboard                                                        |
//+------------------------------------------------------------------+
void DrawPanel()
  {
   if(!InpShowPanel)
     {
      ObjectsDeleteAll(0, PFX + "PN", -1, -1);
      return;
     }

   int x = InpPanelX;
   int y = InpPanelY;
   int rowH = 15;
   int rows = 22;
   int w = 330;
   int h = rows * rowH + 16;

   string bg = PFX + "PNbg";
   if(ObjectFind(0, bg) < 0)
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, x - 6);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, y - 8);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, InpColPanelBg);
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, clrDimGray);
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);

   int r = 0;
   color dirCol = (g_intent.direction > 0 ? InpColBull :
                   (g_intent.direction < 0 ? InpColBear : clrSilver));

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             "      MARKET INTENT ENGINE", clrWhite, 9);
   r++;
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             "--------------------------------------", clrDimGray, 8);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Symbol", 15) + _Symbol + "  " + TFName(InpSetupTF),
             InpColPanelText, 8);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Macro " + TFName(InpMacroTF), 15) + TrendName(g_stMacro.trend),
             (g_stMacro.trend > 0 ? InpColBull : (g_stMacro.trend < 0 ? InpColBear : clrSilver)),
             8);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Primary " + TFName(InpPrimaryTF), 15) + TrendName(g_stPrim.trend),
             (g_stPrim.trend > 0 ? InpColBull : (g_stPrim.trend < 0 ? InpColBear : clrSilver)),
             8);
   r++;

   string strTxt = "n/a";
   if(g_stPrim.trend > 0)
      strTxt = "HH -> HL";
   else
      if(g_stPrim.trend < 0)
         strTxt = "LL -> LH";
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Structure", 15) + strTxt, InpColPanelText, 8);
   r++;

   string liqTxt = "none fresh";
   color  liqCol = clrSilver;
   if(g_sweep.valid)
     {
      liqTxt = (g_sweep.side > 0 ? "BUY-SIDE SWEPT" : "SELL-SIDE SWEPT");
      liqTxt += " (" + g_sweep.tag + ")";
      liqCol = (g_sweep.side > 0 ? InpColBear : InpColBull);
     }
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Liquidity", 15) + liqTxt, liqCol, 8);
   r++;

   string dispTxt = "none";
   color  dispCol = clrSilver;
   if(g_beh.dispValid)
     {
      dispTxt = (g_beh.dispDir > 0 ? "BULLISH " : "BEARISH ");
      dispTxt += (g_beh.dispScore > 0.75 ? "STRONG" : (g_beh.dispScore > 0.5 ? "MODERATE" : "MILD"));
      dispCol = (g_beh.dispDir > 0 ? InpColBull : InpColBear);
     }
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Displacement", 15) + dispTxt, dispCol, 8);
   r++;

   int fB = FindFVG(1), fS = FindFVG(-1);
   string fvgTxt = "none";
   if(fB >= 0 && fS >= 0)
      fvgTxt = "BULL + BEAR";
   else
      if(fB >= 0)
         fvgTxt = StringFormat("BULLISH (%.0f%% filled)", g_fvgs[fB].fillRatio * 100.0);
      else
         if(fS >= 0)
            fvgTxt = StringFormat("BEARISH (%.0f%% filled)", g_fvgs[fS].fillRatio * 100.0);
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("FVG", 15) + fvgTxt, InpColPanelText, 8);
   r++;

   string bosTxt = "none";
   color  bosCol = clrSilver;
   if(g_stSetup.lastBreakDir != 0)
     {
      bosTxt = (g_stSetup.lastBreakDir > 0 ? "BULLISH " : "BEARISH ");
      bosTxt += (g_stSetup.lastBreakChoch ? "CHOCH" : "BOS");
      bosCol = (g_stSetup.lastBreakDir > 0 ? InpColBull : InpColBear);
     }
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("LTF structure", 15) + bosTxt, bosCol, 8);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             "--------------------------------------", clrDimGray, 8);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Structure", 14) + BarGauge(g_intent.cStructure, 10), dirCol, 8);
   r++;
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Liquidity", 14) + BarGauge(g_intent.cLiquidity, 10), dirCol, 8);
   r++;
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Displacement", 14) + BarGauge(g_intent.cDisplacement, 10), dirCol, 8);
   r++;
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Momentum", 14) + BarGauge(g_intent.cMomentum, 10), dirCol, 8);
   r++;
   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             Pad("Location", 14) + BarGauge(g_intent.cLocation, 10), dirCol, 8);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             "--------------------------------------", clrDimGray, 8);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             StringFormat("INTENT  %s  %.0f / 100  [%s]",
                          (g_intent.direction > 0 ? "BULLISH" :
                           (g_intent.direction < 0 ? "BEARISH" : "NEUTRAL")),
                          g_intent.score, g_intent.headline),
             dirCol, 9);
   r++;

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             "STATE   " + StateName(g_intent.state),
             (g_intent.state == STATE_ACTION_LONG ? InpColBull :
              (g_intent.state == STATE_ACTION_SHORT ? InpColBear : clrSilver)), 9);
   r++;

   if(g_plan.valid)
     {
      MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
                StringFormat("Zone  %s - %s  (%s)",
                             PriceS(g_plan.zoneLow), PriceS(g_plan.zoneHigh), g_plan.note),
                InpColPanelText, 8);
      r++;
      MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
                StringFormat("SL %s  TP1 %s  RR %.2f",
                             PriceS(g_plan.sl), PriceS(g_plan.tp1), g_plan.rr),
                InpColPanelText, 8);
      r++;
     }
   else
     {
      MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
                "Zone  -", InpColPanelText, 8);
      r++;
      MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
                "SL -  TP1 -  RR -", InpColPanelText, 8);
      r++;
     }

   MakeLabel(PFX + "PN" + IntegerToString(r), x, y + rowH * r,
             "AutoTrade  " + (InpAutoTrade ? "ON (executing)" : "OFF (visual only)"),
             (InpAutoTrade ? clrOrange : clrSilver), 8);
   r++;

   for(int i = r; i < rows; i++)
      MakeLabel(PFX + "PN" + IntegerToString(i), x, y + rowH * i, "", clrBlack, 8);
  }

void DrawAll()
  {
   DrawStructureLayer();
   DrawLiquidityLayer();
   DrawFVGLayer();
   DrawBehaviorLayer();
   DrawPlanLayer();
   DrawPanel();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Execution layer                                                  |
//+------------------------------------------------------------------+
bool HasOpenPosition()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == InpMagic)
         return true;
     }
   return false;
  }

bool HasPendingOrder()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(t == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
         OrderGetInteger(ORDER_MAGIC) == InpMagic)
         return true;
     }
   return false;
  }

void DeletePendingOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(t == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
         OrderGetInteger(ORDER_MAGIC) == InpMagic)
         g_trade.OrderDelete(t);
     }
  }

//+------------------------------------------------------------------+
//|  Calculate Lots                                                  |
//+------------------------------------------------------------------+
double CalcLots(double entry, double sl)
  {
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(InpUseFixedLot)
     {
      double f = MathMax(minLot, MathMin(maxLot, InpFixedLot));
      return NormalizeDouble(MathFloor(f / lotStep) * lotStep, 2);
     }

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double slDist    = MathAbs(entry - sl);

   if(tickValue <= 0.0 || tickSize <= 0.0 || slDist <= 0.0)
      return minLot;

   double riskMoney  = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
   double lossPerLot = (slDist / tickSize) * tickValue;
   if(lossPerLot <= 0.0)
      return minLot;

   double lots = riskMoney / lossPerLot;
   lots = MathFloor(lots / lotStep) * lotStep;
   lots = MathMax(minLot, MathMin(maxLot, lots));
   return NormalizeDouble(lots, 2);
  }

bool SpreadOK()
  {
   long sp = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   return (sp <= InpMaxSpreadPoints);
  }

bool SessionOK()
  {
   if(!InpUseSessionFilter)
      return true;
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(InpSessionStartHour <= InpSessionEndHour)
      return (dt.hour >= InpSessionStartHour && dt.hour < InpSessionEndHour);
   return (dt.hour >= InpSessionStartHour || dt.hour < InpSessionEndHour);
  }

double SanitizeSL(int dir, double entry, double sl)
  {
   long   stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist    = (stopsLevel + 5) * Pt();

   if(dir > 0)
     {
      if(entry - sl < minDist)
         sl = entry - minDist;
     }
   else
     {
      if(sl - entry < minDist)
         sl = entry + minDist;
     }
   return NormalizeDouble(sl, Dg());
  }

void OpenMarket(int dir, double sl, double tp)
  {
   double entry = (dir > 0 ? Ask() : Bid());
   sl = SanitizeSL(dir, entry, sl);

   double lots = CalcLots(entry, sl);
   if(lots <= 0.0)
      return;

   string cmt = StringFormat("MIE %s %.0f", (dir > 0 ? "L" : "S"), g_intent.score);
   bool ok;
   if(dir > 0)
      ok = g_trade.Buy(lots, _Symbol, 0.0, sl, NormalizeDouble(tp, Dg()), cmt);
   else
      ok = g_trade.Sell(lots, _Symbol, 0.0, sl, NormalizeDouble(tp, Dg()), cmt);

   if(ok)
     {
      g_lastTradedSweep = g_sweep.time;
      g_arm.armed = false;
      if(InpDebugPrint)
         PrintFormat("[MIE] opened %s lots=%.2f sl=%s tp=%s score=%.0f",
                     (dir > 0 ? "BUY" : "SELL"), lots, PriceS(sl), PriceS(tp), g_intent.score);
     }
   else
      PrintFormat("[MIE] order failed: %d %s", g_trade.ResultRetcode(),
                  g_trade.ResultRetcodeDescription());
  }

//+------------------------------------------------------------------+
//|  Pending Orders                                                  |
//+------------------------------------------------------------------+
void PlaceLimit(int dir, double price, double sl, double tp)
  {
   price = NormalizeDouble(price, Dg());
   sl    = SanitizeSL(dir, price, sl);

   double lots = CalcLots(price, sl);
   if(lots <= 0.0)
      return;

   long   stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist    = (stopsLevel + 5) * Pt();

//--- a limit must sit on the correct side of the market
   if(dir > 0 && price > Ask() - minDist)
     { OpenMarket(dir, sl, tp); return; }
   if(dir < 0 && price < Bid() + minDist)
     { OpenMarket(dir, sl, tp); return; }

   string cmt = StringFormat("MIE %s %.0f", (dir > 0 ? "L" : "S"), g_intent.score);
   bool ok;
   if(dir > 0)
      ok = g_trade.BuyLimit(lots, price, _Symbol, sl, NormalizeDouble(tp, Dg()),
                            ORDER_TIME_GTC, 0, cmt);
   else
      ok = g_trade.SellLimit(lots, price, _Symbol, sl, NormalizeDouble(tp, Dg()),
                             ORDER_TIME_GTC, 0, cmt);

   if(ok)
     {
      g_lastTradedSweep = g_sweep.time;
      if(InpDebugPrint)
         PrintFormat("[MIE] limit placed %s @ %s", (dir > 0 ? "BUY" : "SELL"), PriceS(price));
     }
  }

//+------------------------------------------------------------------+
//| Execute Trades                                                   |
//+------------------------------------------------------------------+
void TryExecute()
  {
   if(!InpAutoTrade)
      return;
   if(HasOpenPosition())
      return;
   if(!SessionOK() || !SpreadOK())
      return;

   bool isAction = (g_intent.state == STATE_ACTION_LONG ||
                    g_intent.state == STATE_ACTION_SHORT);

//--- arm a fresh setup 
   if(isAction && g_plan.valid && g_plan.rr >= InpMinRR)
     {
      bool sameSweep = (InpOneTradePerSweep && g_sweep.valid &&
                        g_sweep.time == g_lastTradedSweep);

      //--- the broker-side TP sits at TP2 when we intend to scale out at TP1
      double tpOrder = (InpUsePartial ? g_plan.tp2 : g_plan.tp1);

      if(!sameSweep)
        {
         if(InpEntryMode == ENTRY_MARKET_NOW)
           {
            if(!HasPendingOrder())
              {
               g_plannedTP1 = g_plan.tp1;
               OpenMarket(g_plan.dir, g_plan.sl, tpOrder);
              }
            return;
           }

         if(InpEntryMode == ENTRY_LIMIT_ZONE)
           {
            if(!HasPendingOrder())
              {
               g_plannedTP1 = g_plan.tp1;
               PlaceLimit(g_plan.dir, g_plan.entry, g_plan.sl, tpOrder);
               g_arm.armed     = true;
               g_arm.dir       = g_plan.dir;
               g_arm.armedTime = TimeCurrent();
               g_arm.sweepTime = g_sweep.time;
               g_arm.barsLeft  = InpArmBars;
              }
            return;
           }

         //--- ENTRY_MARKET_ZONE : remember the setup and wait for the tap
         if(!g_arm.armed || g_arm.dir != g_plan.dir)
           {
            g_arm.armed     = true;
            g_arm.dir       = g_plan.dir;
            g_arm.zoneLow   = g_plan.zoneLow;
            g_arm.zoneHigh  = g_plan.zoneHigh;
            g_arm.sl        = g_plan.sl;
            g_arm.tp1       = g_plan.tp1;
            g_arm.tp2       = g_plan.tp2;
            g_arm.armedTime = TimeCurrent();
            g_arm.sweepTime = g_sweep.time;
            g_arm.barsLeft  = InpArmBars;
           }
        }
     }

//--- trigger an armed zone setup 
   if(g_arm.armed && InpEntryMode == ENTRY_MARKET_ZONE)
     {
      double px = (g_arm.dir > 0 ? Ask() : Bid());
      if(px <= g_arm.zoneHigh && px >= g_arm.zoneLow)
        {
         g_plannedTP1 = g_arm.tp1;
         OpenMarket(g_arm.dir, g_arm.sl, (InpUsePartial ? g_arm.tp2 : g_arm.tp1));
         g_arm.armed = false;
        }
     }
  }

//+------------------------------------------------------------------+
//|  Expire Armed Setups                                             |
//+------------------------------------------------------------------+
void ExpireArmedSetup()
  {
   if(!g_arm.armed)
      return;

   g_arm.barsLeft--;
   if(g_arm.barsLeft <= 0)
     {
      g_arm.armed = false;
      if(InpEntryMode == ENTRY_LIMIT_ZONE)
         DeletePendingOrders();
      if(InpDebugPrint)
         Print("[MIE] armed setup expired");
     }
  }

//+------------------------------------------------------------------+
//| Trade management                                                 |
//+------------------------------------------------------------------+
void SyncPosition()
  {
   ulong found = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == InpMagic)
        {
         found = t;
         break;
        }
     }

   if(found == 0)
     {
      g_posTicket  = 0;
      g_posPartial = false;
      g_posBE      = false;
      return;
     }

   if(found != g_posTicket)
     {
      //--- new position detected: capture its initial risk
      g_posTicket  = found;
      g_posEntry   = PositionGetDouble(POSITION_PRICE_OPEN);
      g_posInitSL  = PositionGetDouble(POSITION_SL);
      g_posTP1     = (g_plannedTP1 > 0.0 ? g_plannedTP1 : PositionGetDouble(POSITION_TP));
      g_posRisk    = MathAbs(g_posEntry - g_posInitSL);
      g_posPartial = false;
      g_posBE      = false;
     }
  }

//+------------------------------------------------------------------+
//|  Manage Positions                                                |
//+------------------------------------------------------------------+
void ManagePosition()
  {
   SyncPosition();
   if(g_posTicket == 0 || g_posRisk <= 0.0)
      return;

   if(!PositionSelectByTicket(g_posTicket))
      return;

   long   type   = PositionGetInteger(POSITION_TYPE);
   double sl     = PositionGetDouble(POSITION_SL);
   double tp     = PositionGetDouble(POSITION_TP);
   double vol    = PositionGetDouble(POSITION_VOLUME);
   int    dir    = (type == POSITION_TYPE_BUY ? 1 : -1);
   double px     = (dir > 0 ? Bid() : Ask());
   double rNow   = (dir > 0 ? (px - g_posEntry) : (g_posEntry - px)) / g_posRisk;

   double newSL = sl;

//--- break-even 
   if(InpUseBreakEven && !g_posBE && rNow >= InpBEatR)
     {
      double be = g_posEntry + dir * InpBEOffsetPoints * Pt();
      if((dir > 0 && be > newSL) || (dir < 0 && (newSL == 0.0 || be < newSL)))
        {
         newSL   = be;
         g_posBE = true;
        }
     }

//--- ATR trailing 
   if(InpUseTrail && rNow >= InpTrailStartR && g_atrEntry > 0.0)
     {
      double trail = px - dir * g_atrEntry * InpTrailATRMult;
      if((dir > 0 && trail > newSL) || (dir < 0 && (newSL == 0.0 || trail < newSL)))
         newSL = trail;
     }

   if(MathAbs(newSL - sl) > Pt())
     {
      newSL = NormalizeDouble(newSL, Dg());
      g_trade.PositionModify(g_posTicket, newSL, tp);
     }

//--- partial at TP1 
   if(InpUsePartial && !g_posPartial && g_posTP1 > 0.0)
     {
      bool hit = (dir > 0 ? (px >= g_posTP1 - g_atrEntry * 0.1)
                  : (px <= g_posTP1 + g_atrEntry * 0.1));
      if(hit)
        {
         double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
         double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
         double part    = MathFloor((vol * InpPartialPct / 100.0) / lotStep) * lotStep;
         if(part >= minLot && (vol - part) >= minLot)
           {
            if(g_trade.PositionClosePartial(g_posTicket, part))
               g_posPartial = true;
           }
         else
            g_posPartial = true;   // nothing sensible to scale out of
        }
     }
  }

//+------------------------------------------------------------------+
//| Alerts                                                           |
//+------------------------------------------------------------------+
void FireAlert()
  {
   if(!InpAlerts)
      return;
   if(g_intent.state != STATE_ACTION_LONG && g_intent.state != STATE_ACTION_SHORT)
      return;
   if(g_lastAlertTime == g_lastSetupBar)
      return;

   g_lastAlertTime = g_lastSetupBar;

   string msg = StringFormat("%s %s | %s | Liquidity: %s | Score: %.0f | %s",
                             _Symbol, TFName(InpSetupTF),
                             StateName(g_intent.state),
                             (g_sweep.valid ? (g_sweep.side > 0 ? "buy-side swept"
                                   : "sell-side swept")
                              : "none"),
                             g_intent.score,
                             (g_plan.valid ? StringFormat("RR %.2f", g_plan.rr) : "no plan"));
   Alert(msg);
  }

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_blockFull  = ShortToString(0x2588);   // full block
   g_blockEmpty = ShortToString(0x2591);   // light shade

   g_trade.SetExpertMagicNumber((ulong)InpMagic);
   g_trade.SetDeviationInPoints(InpSlippage);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   g_trade.SetAsyncMode(false);

   g_hATRSetup = iATR(_Symbol, InpSetupTF, InpATRPeriod);
   g_hATREntry = iATR(_Symbol, InpEntryTF, InpATRPeriod);
   if(g_hATRSetup == INVALID_HANDLE || g_hATREntry == INVALID_HANDLE)
     {
      Print("[MIE] failed to create ATR handles");
      return INIT_FAILED;
     }

   ArraySetAsSeries(g_rMacro, true);
   ArraySetAsSeries(g_rPrim,  true);
   ArraySetAsSeries(g_rSetup, true);
   ArraySetAsSeries(g_rEntry, true);

   g_arm.armed = false;
   g_intent.state = STATE_WAIT;
   g_plan.valid = false;

   EventSetTimer(2);

   Print("[MIE] Market Intent Engine started. AutoTrade = ",
         (InpAutoTrade ? "ON" : "OFF"));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX, -1, -1);
   ChartRedraw(0);

   if(g_hATRSetup != INVALID_HANDLE)
      IndicatorRelease(g_hATRSetup);
   if(g_hATREntry != INVALID_HANDLE)
      IndicatorRelease(g_hATREntry);
  }

//+------------------------------------------------------------------+
//| Timer - keeps the dashboard alive between ticks                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(InpShowPanel)
     {
      DrawPanel();
      ChartRedraw(0);
     }
  }

//+------------------------------------------------------------------+
//| Main tick handler                                                |
//+------------------------------------------------------------------+
void OnTick()
  {
   bool newEntryBar = IsNewBar(InpEntryTF, g_lastEntryBar);
   bool newSetupBar = IsNewBar(InpSetupTF, g_lastSetupBar);

   if(newSetupBar)
      ExpireArmedSetup();

   if(newEntryBar || g_firstRun)
     {
      if(RunAnalysis())
        {
         g_firstRun = false;
         DrawAll();
         FireAlert();
        }
     }

   ManagePosition();
   TryExecute();
  }
//+------------------------------------------------------------------+
