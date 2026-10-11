//+------------------------------------------------------------------+
//|                                             Candle Imbalance.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                     https://www.mql5.com/en/users/johnhlomohang/ |
//|Swing Extremes and Pullbacks                                      |
//|1. Developing a Multi-Timeframe Indicator                         |
//|                          https://www.mql5.com/en/articles/21330  |
//|2. Automating the Strategy with an Expert Advisor                 |
//|                          https://www.mql5.com/en/articles/21135  |
//|3. Defining Structural Validity Beyond Simple Highs/Lows          |
//|                          https://www.mql5.com/en/articles/21888  |
//|4. Dynamic Pullback Depth Using Volatility Models                 |
//|                          https://www.mql5.com/en/articles/22807  |
//|5. Filtering Weak Swings Using Candle Imbalance                   |
//|                          https://www.mql5.com/en/articles/23613  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/johnhlomohang/"
#property version   "1.00"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== Swing Detection ==="
input int      InpSwingLeft         = 3;       // Left bars for pivot
input int      InpSwingRight        = 3;       // Right bars for pivot confirmation
input int      InpMaxLegBars        = 60;      // Max bars allowed in one impulse leg

input group "=== Candle Imbalance Score ==="
input double   InpMinImbalanceScore = 55.0;    // Minimum score to accept a swing (0-100)
input double   InpWeightBody        = 1.0;     // Weight: body dominance
input double   InpWeightDirection   = 1.0;     // Weight: directional consistency
input double   InpWeightEfficiency  = 1.0;     // Weight: leg efficiency (net/gross travel)
input double   InpWeightFVG         = 1.0;     // Weight: FVG (imbalance gap) coverage

input group "=== Pullback Zone ==="
input double   InpZoneShallow       = 38.2;    // Shallow retracement bound (%)
input double   InpZoneDeep          = 79.0;    // Deep retracement bound (%)
input bool     InpFirstRetestOnly   = true;    // Invalidate after first clean retest

input group "=== Risk & Trade Management ==="
input double   InpLots              = 0.10;    // Fixed lot size
input double   InpRiskRewardRatio   = 2.0;     // Take profit = RR x stop distance
input int      InpATRPeriod         = 14;      // ATR period for SL buffer
input double   InpATRBufferMult     = 0.5;     // SL buffer = ATR x this multiplier
input int      InpMaxOpenTrades     = 1;       // Max simultaneous positions
input ulong    InpMagic             = 50505;   // Magic number

//--- Trailing stop mode
enum TRAIL_MODE
  {
   TRAIL_SWING,     // Trail behind confirmed swing points
   TRAIL_ATR,       // Chandelier-style ATR trail
   TRAIL_HYBRID     // Tightest of swing and ATR candidates
  };

input group "=== Trailing Stop ==="
input bool       InpUseTrailing          = true;         // Enable trailing stop
input TRAIL_MODE InpTrailMode            = TRAIL_HYBRID; // Trailing mode
input double     InpTrailATRMult         = 2.0;          // ATR multiplier for ATR trail
input double     InpTrailActivationRR    = 1.0;          // Start trailing after this R multiple
input bool       InpMoveToBreakeven      = true;         // Move SL to breakeven first
input double     InpBreakevenTriggerRR   = 1.0;          // Breakeven trigger (R multiple)
input int        InpBreakevenBufferPts   = 50;           // Breakeven buffer (points)

input group "=== Visualization ==="
input bool     InpDrawObjects       = true;    // Draw swings, legs and zones
input color    InpStrongBullColor   = clrLimeGreen;   // Strong bullish leg
input color    InpStrongBearColor   = clrOrangeRed;   // Strong bearish leg
input color    InpWeakColor         = clrDarkGray;    // Filtered weak swing
input color    InpZoneColor         = clrDodgerBlue;  // Pullback zone

//+------------------------------------------------------------------+
//| Swing point structure                                            |
//+------------------------------------------------------------------+
struct SwingPoint
  {
   datetime time;         // Bar time of the extreme
   double   price;        // Extreme price
   bool     isHigh;       // true = swing high, false = swing low
   double   score;        // Candle Imbalance Score of the leg into this swing
   bool     strong;       // Passed the imbalance filter
   datetime originTime;   // Time of the opposite swing that started the leg
   double   originPrice;  // Price of the opposite swing that started the leg
  };

//+------------------------------------------------------------------+
//| Pullback setup state                                             |
//+------------------------------------------------------------------+
enum SETUP_STATE
  {
   SETUP_NONE,        // No armed setup
   SETUP_ARMED,       // Strong swing confirmed, waiting for pullback
   SETUP_IN_ZONE,     // Price has entered the retracement zone
   SETUP_DONE         // Traded or invalidated
  };

struct PullbackSetup
  {
   SETUP_STATE state;
   bool        bullish;      // true = buy pullback (anchored on strong swing HIGH)
   double      legHigh;      // Impulse leg extreme high
   double      legLow;       // Impulse leg extreme low
   double      zoneUpper;    // Pullback zone upper price
   double      zoneLower;    // Pullback zone lower price
   datetime    swingTime;    // Anchor swing time (unique id)
   bool        enteredZone;  // Price has touched the zone at least once
  };

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
CTrade        trade;
SwingPoint    g_swings[];          // Confirmed swings, newest at end
PullbackSetup g_setup;
datetime      g_lastBarTime = 0;
int           g_atrHandle   = INVALID_HANDLE;
double        g_initialRiskPoints = 0;   // Risk at entry, drives trailing activation

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(20);

   g_atrHandle = iATR(_Symbol, _Period, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create ATR handle");
      return INIT_FAILED;
     }

   ArrayResize(g_swings, 0);
   ResetSetup();

   if(InpZoneDeep <= InpZoneShallow)
     {
      Print("Invalid zone bounds: deep % must exceed shallow %");
      return INIT_PARAMETERS_INCORRECT;
     }

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   ObjectsDeleteAll(0, "SPB5_");
   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Trailing runs on every tick so exits stay responsive
   if(InpUseTrailing || InpMoveToBreakeven)
      ManageTrailing();

   if(!IsNewBar())
      return;

   DetectSwing();
   ManageSetup();
   UpdateDashboard();
  }

//+------------------------------------------------------------------+
//| New closed bar detector                                          |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime t = iTime(_Symbol, _Period, 0);
   if(t == g_lastBarTime)
      return false;
   g_lastBarTime = t;
   return true;
  }

//+------------------------------------------------------------------+
//| Detect a newly confirmed swing extreme                           |
//+------------------------------------------------------------------+
void DetectSwing()
  {
   // Candidate pivot bar: fully closed with InpSwingRight closed bars after it
   int c = InpSwingRight + 1;
   int need = c + InpSwingLeft + 1;
   if(Bars(_Symbol, _Period) < need + InpMaxLegBars)
      return;

   double candHigh = iHigh(_Symbol, _Period, c);
   double candLow  = iLow(_Symbol, _Period, c);
   datetime candTime = iTime(_Symbol, _Period, c);

   // Skip if this bar is already registered as a swing
   int total = ArraySize(g_swings);
   if(total > 0 && g_swings[total - 1].time == candTime)
      return;

   bool isHigh = true;
   bool isLow  = true;

   for(int k = 1; k <= InpSwingLeft; k++)
     {
      if(iHigh(_Symbol, _Period, c + k) >= candHigh) isHigh = false;
      if(iLow(_Symbol, _Period, c + k)  <= candLow)  isLow  = false;
     }
   for(int k = 1; k <= InpSwingRight; k++)
     {
      if(iHigh(_Symbol, _Period, c - k) >= candHigh) isHigh = false;
      if(iLow(_Symbol, _Period, c - k)  <= candLow)  isLow  = false;
     }

   if(!isHigh && !isLow)
      return;

   // Enforce alternation: a swing high must follow a swing low and vice versa.
   // If both fire on the same bar (rare), prefer the one that alternates.
   bool lastWasHigh = (total > 0) ? g_swings[total - 1].isHigh : false;
   bool takeHigh;

   if(isHigh && isLow)
      takeHigh = !lastWasHigh;
   else
      takeHigh = isHigh;

   if(total > 0 && takeHigh == lastWasHigh)
     {
      // Same-type swing in a row: keep the more extreme one, replace in place
      if(takeHigh && candHigh > g_swings[total - 1].price)
         ReplaceLastSwing(candTime, candHigh, true);
      else if(!takeHigh && candLow < g_swings[total - 1].price)
         ReplaceLastSwing(candTime, candLow, false);
      return;
     }

   RegisterSwing(candTime, takeHigh ? candHigh : candLow, takeHigh);
  }

//+------------------------------------------------------------------+
//| Replace the last stored swing with a more extreme same-type one  |
//+------------------------------------------------------------------+
void ReplaceLastSwing(datetime t, double price, bool isHigh)
  {
   int total = ArraySize(g_swings);
   if(total == 0)
      return;

   g_swings[total - 1].time  = t;
   g_swings[total - 1].price = price;
   g_swings[total - 1].isHigh = isHigh;

   // Re-score against its origin (previous opposite swing)
   if(total >= 2)
     {
      g_swings[total - 1].originTime  = g_swings[total - 2].time;
      g_swings[total - 1].originPrice = g_swings[total - 2].price;
      ScoreSwing(g_swings[total - 1]);
      DrawSwing(g_swings[total - 1]);
      ArmSetupFromSwing(g_swings[total - 1]);
     }
  }

//+------------------------------------------------------------------+
//| Register a new confirmed swing and score its impulse leg         |
//+------------------------------------------------------------------+
void RegisterSwing(datetime t, double price, bool isHigh)
  {
   int total = ArraySize(g_swings);
   ArrayResize(g_swings, total + 1);

   g_swings[total].time   = t;
   g_swings[total].price  = price;
   g_swings[total].isHigh = isHigh;
   g_swings[total].score  = 0.0;
   g_swings[total].strong = false;

   if(total >= 1)
     {
      g_swings[total].originTime  = g_swings[total - 1].time;
      g_swings[total].originPrice = g_swings[total - 1].price;
      ScoreSwing(g_swings[total]);
      DrawSwing(g_swings[total]);
      ArmSetupFromSwing(g_swings[total]);
     }
   else
     {
      g_swings[total].originTime  = 0;
      g_swings[total].originPrice = 0.0;
     }

   // Keep the buffer bounded
   if(ArraySize(g_swings) > 200)
     {
      for(int i = 0; i < ArraySize(g_swings) - 1; i++)
         g_swings[i] = g_swings[i + 1];
      ArrayResize(g_swings, ArraySize(g_swings) - 1);
     }
  }

//+------------------------------------------------------------------+
//| Candle Imbalance Score for the leg into a swing                  |
//+------------------------------------------------------------------+
void ScoreSwing(SwingPoint &sp)
  {
   int startShift = iBarShift(_Symbol, _Period, sp.originTime, true);
   int endShift   = iBarShift(_Symbol, _Period, sp.time, true);

   if(startShift < 0 || endShift < 0 || startShift <= endShift)
      return;

   int n = startShift - endShift;   // bars travelled in the leg
   if(n < 1 || n > InpMaxLegBars)
     {
      sp.score  = 0.0;
      sp.strong = false;
      return;
     }

   bool legUp = sp.isHigh;          // leg into a swing high is an up-leg
   double legHeight = MathAbs(sp.price - sp.originPrice);
   if(legHeight <= 0.0)
      return;

   // --- Component 1: Body dominance -------------------------------
   // Average body-to-range ratio across leg candles.
   double bodySum = 0.0;
   int    counted = 0;

   // --- Component 2: Directional consistency ----------------------
   int dirCount = 0;

   // --- Component 3: Leg efficiency (net travel / gross travel) ---
   double gross = 0.0;

   for(int s = startShift; s > endShift; s--)
     {
      double op = iOpen(_Symbol, _Period, s);
      double cl = iClose(_Symbol, _Period, s);
      double hi = iHigh(_Symbol, _Period, s);
      double lo = iLow(_Symbol, _Period, s);

      double range = hi - lo;
      if(range > 0.0)
        {
         bodySum += MathAbs(cl - op) / range;
         counted++;
        }

      if(legUp  && cl > op) dirCount++;
      if(!legUp && cl < op) dirCount++;

      if(s < startShift)
         gross += MathAbs(cl - iClose(_Symbol, _Period, s + 1));
     }

   double bodyDominance = (counted > 0) ? bodySum / counted : 0.0;
   double dirRatio      = (double)dirCount / (double)n;

   double net = MathAbs(iClose(_Symbol, _Period, endShift + 1) -
                        iClose(_Symbol, _Period, startShift));
   double efficiency = (gross > 0.0) ? MathMin(net / gross, 1.0) : 0.0;

   // --- Component 4: FVG (imbalance gap) coverage -----------------
   // Bullish FVG at bar m: low[m] > high[m+2]. Bearish: high[m] < low[m+2].
   double fvgTotal = 0.0;
   for(int m = endShift + 1; m <= startShift - 2; m++)
     {
      if(legUp)
        {
         double gap = iLow(_Symbol, _Period, m) - iHigh(_Symbol, _Period, m + 2);
         if(gap > 0.0) fvgTotal += gap;
        }
      else
        {
         double gap = iLow(_Symbol, _Period, m + 2) - iHigh(_Symbol, _Period, m);
         if(gap > 0.0) fvgTotal += gap;
        }
     }
   double fvgCoverage = MathMin(fvgTotal / legHeight, 1.0);

   // --- Composite score -------------------------------------------
   double wSum = InpWeightBody + InpWeightDirection +
                 InpWeightEfficiency + InpWeightFVG;
   if(wSum <= 0.0) wSum = 1.0;

   sp.score = 100.0 * (InpWeightBody       * bodyDominance +
                       InpWeightDirection  * dirRatio +
                       InpWeightEfficiency * efficiency +
                       InpWeightFVG        * fvgCoverage) / wSum;

   sp.strong = (sp.score >= InpMinImbalanceScore);

   PrintFormat("Swing %s @ %s | score=%.1f (body=%.2f dir=%.2f eff=%.2f fvg=%.2f) -> %s",
               sp.isHigh ? "HIGH" : "LOW",
               TimeToString(sp.time),
               sp.score, bodyDominance, dirRatio, efficiency, fvgCoverage,
               sp.strong ? "STRONG" : "WEAK (filtered)");
  }

//+------------------------------------------------------------------+
//| Arm a pullback setup from a freshly scored swing                 |
//+------------------------------------------------------------------+
void ArmSetupFromSwing(const SwingPoint &sp)
  {
   // Weak swings never arm setups: this is the Part 5 filter in action.
   if(!sp.strong)
      return;

   ResetSetup();

   g_setup.state     = SETUP_ARMED;
   g_setup.bullish   = sp.isHigh;   // strong up-leg -> buy the pullback
   g_setup.swingTime = sp.time;
   g_setup.enteredZone = false;

   if(sp.isHigh)
     {
      g_setup.legHigh = sp.price;
      g_setup.legLow  = sp.originPrice;
     }
   else
     {
      g_setup.legHigh = sp.originPrice;
      g_setup.legLow  = sp.price;
     }

   double height = g_setup.legHigh - g_setup.legLow;

   if(g_setup.bullish)
     {
      g_setup.zoneUpper = g_setup.legHigh - height * (InpZoneShallow / 100.0);
      g_setup.zoneLower = g_setup.legHigh - height * (InpZoneDeep    / 100.0);
     }
   else
     {
      g_setup.zoneLower = g_setup.legLow + height * (InpZoneShallow / 100.0);
      g_setup.zoneUpper = g_setup.legLow + height * (InpZoneDeep    / 100.0);
     }

   DrawZone();
  }

//+------------------------------------------------------------------+
//| Manage the armed setup on each closed bar                        |
//+------------------------------------------------------------------+
void ManageSetup()
  {
   if(g_setup.state == SETUP_NONE || g_setup.state == SETUP_DONE)
      return;

   double closed = iClose(_Symbol, _Period, 1);
   double hi1    = iHigh(_Symbol, _Period, 1);
   double lo1    = iLow(_Symbol, _Period, 1);
   double op1    = iOpen(_Symbol, _Period, 1);

   // Hard invalidation: price closes beyond the leg origin (100% retrace)
   if(g_setup.bullish && closed < g_setup.legLow)   { Invalidate("full retrace"); return; }
   if(!g_setup.bullish && closed > g_setup.legHigh) { Invalidate("full retrace"); return; }

   bool inZone = (lo1 <= g_setup.zoneUpper && hi1 >= g_setup.zoneLower);

   if(g_setup.state == SETUP_ARMED)
     {
      if(inZone)
        {
         g_setup.state = SETUP_IN_ZONE;
         g_setup.enteredZone = true;
        }
      return;
     }

   // SETUP_IN_ZONE: look for the confirmation candle
   if(g_setup.state == SETUP_IN_ZONE)
     {
      // First-clean-retest-only: if price leaves the zone against us
      // without confirming, the setup is spent.
      if(InpFirstRetestOnly)
        {
         if(g_setup.bullish && closed < g_setup.zoneLower)  { Invalidate("zone break"); return; }
         if(!g_setup.bullish && closed > g_setup.zoneUpper) { Invalidate("zone break"); return; }
        }

      bool confirm = false;
      if(g_setup.bullish)
         confirm = (closed > op1) && (closed >= g_setup.zoneLower) && (closed <= g_setup.zoneUpper * 1.001);
      else
         confirm = (closed < op1) && (closed <= g_setup.zoneUpper) && (closed >= g_setup.zoneLower * 0.999);

      if(confirm)
        {
         if(OpenTrade())
            g_setup.state = SETUP_DONE;
        }
      else if(!inZone)
        {
         // Drifted out toward the extreme without confirming: re-arm and
         // allow a second touch only if first-retest-only is disabled.
         if(!InpFirstRetestOnly)
            g_setup.state = SETUP_ARMED;
        }
     }
  }

//+------------------------------------------------------------------+
//| Invalidate the current setup                                     |
//+------------------------------------------------------------------+
void Invalidate(const string reason)
  {
   PrintFormat("Setup invalidated (%s): %s anchor @ %s",
               reason,
               g_setup.bullish ? "bullish" : "bearish",
               TimeToString(g_setup.swingTime));
   g_setup.state = SETUP_DONE;
   if(InpDrawObjects)
      ObjectDelete(0, "SPB5_ZONE");
  }

//+------------------------------------------------------------------+
//| Open the pullback trade                                          |
//+------------------------------------------------------------------+
bool OpenTrade()
  {
   if(CountOpenPositions() >= InpMaxOpenTrades)
      return false;

   double atr[1];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, atr) != 1)
      return false;
   double buffer = atr[0] * InpATRBufferMult;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double sl, tp, entry;
   bool ok = false;

   if(g_setup.bullish)
     {
      entry = ask;
      sl = NormalizeDouble(g_setup.legLow - buffer, digits);
      double dist = entry - sl;
      if(dist <= 0.0) return false;
      tp = NormalizeDouble(entry + dist * InpRiskRewardRatio, digits);
      ok = trade.Buy(InpLots, _Symbol, 0.0, sl, tp, "SPB5 buy pullback");
     }
   else
     {
      entry = bid;
      sl = NormalizeDouble(g_setup.legHigh + buffer, digits);
      double dist = sl - entry;
      if(dist <= 0.0) return false;
      tp = NormalizeDouble(entry - dist * InpRiskRewardRatio, digits);
      ok = trade.Sell(InpLots, _Symbol, 0.0, sl, tp, "SPB5 sell pullback");
     }

   if(ok)
     {
      //--- Anchor for trailing activation (R-multiple measurement)
      double riskDist = g_setup.bullish ? (entry - sl) : (sl - entry);
      g_initialRiskPoints = riskDist / _Point;
      PrintFormat("Opened %s | SL=%.5f TP=%.5f | Risk=%.0f pts",
                  g_setup.bullish ? "BUY" : "SELL", sl, tp, g_initialRiskPoints);
     }
   else
      PrintFormat("Trade failed: %d - %s", trade.ResultRetcode(), trade.ResultRetcodeDescription());

   return ok;
  }

//+------------------------------------------------------------------+
//| Count open positions owned by this EA                            |
//+------------------------------------------------------------------+
int CountOpenPositions()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Trailing Stop Module                                             |
//| Sequence per tick, per EA-owned position:                        |
//|   1. Breakeven move once profit >= BreakevenTriggerRR x risk     |
//|   2. Trailing (if enabled) once profit >= ActivationRR x risk    |
//|      - TRAIL_SWING : behind confirmed swing points + ATR buffer  |
//|      - TRAIL_ATR   : chandelier trail at price -/+ ATR x mult    |
//|      - TRAIL_HYBRID: tightest (most protective) of the two       |
//|   SL only ever moves in the trade's favor.                       |
//+------------------------------------------------------------------+
void ManageTrailing()
  {
   double atr[1];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, atr) != 1)
      return;
   if(atr[0] <= 0)
      return;

   double buffer = atr[0] * InpATRBufferMult;
   double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;

      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double curSL     = PositionGetDouble(POSITION_SL);
      double curTP     = PositionGetDouble(POSITION_TP);
      long   type      = PositionGetInteger(POSITION_TYPE);

      //--- Risk anchor: entry risk if known, ATR proxy otherwise
      //--- (proxy covers EA restarts mid-position)
      double riskPts = (g_initialRiskPoints > 0) ? g_initialRiskPoints
                                                 : atr[0] * InpTrailATRMult / _Point;
      if(riskPts <= 0) continue;

      if(type == POSITION_TYPE_BUY)
        {
         double profitPts = (bid - openPrice) / _Point;

         //--- Step 1: Breakeven
         if(InpMoveToBreakeven && profitPts >= InpBreakevenTriggerRR * riskPts)
           {
            double be = NormalizeDouble(openPrice + InpBreakevenBufferPts * _Point, digits);
            if(curSL < be && be < bid)
              {
               if(trade.PositionModify(ticket, be, curTP))
                 {
                  curSL = be;
                  PrintFormat("Breakeven SL -> %.5f (#%I64u)", be, ticket);
                 }
              }
           }

         //--- Step 2: Trailing
         if(!InpUseTrailing) continue;
         if(profitPts < InpTrailActivationRR * riskPts) continue;

         double swingSL = 0.0;
         if(InpTrailMode == TRAIL_SWING || InpTrailMode == TRAIL_HYBRID)
           {
            //--- Highest confirmed swing low between entry and current price
            for(int s = 0; s < ArraySize(g_swings); s++)
               if(!g_swings[s].isHigh &&
                  g_swings[s].price > openPrice &&
                  g_swings[s].price < bid)
                  if(g_swings[s].price > swingSL)
                     swingSL = g_swings[s].price;

            if(swingSL > 0.0)
               swingSL -= buffer;
           }

         double atrSL = 0.0;
         if(InpTrailMode == TRAIL_ATR || InpTrailMode == TRAIL_HYBRID)
            atrSL = bid - atr[0] * InpTrailATRMult;

         //--- Tightest = highest candidate for a buy
         double newSL = NormalizeDouble(MathMax(swingSL, atrSL), digits);

         if(newSL > 0.0 && newSL > curSL + _Point && newSL < bid)
           {
            if(trade.PositionModify(ticket, newSL, curTP))
               PrintFormat("Trail SL -> %.5f (#%I64u | mode: %s)",
                           newSL, ticket, TrailModeToString(InpTrailMode));
           }
        }
      else if(type == POSITION_TYPE_SELL)
        {
         double profitPts = (openPrice - ask) / _Point;

         //--- Step 1: Breakeven
         if(InpMoveToBreakeven && profitPts >= InpBreakevenTriggerRR * riskPts)
           {
            double be = NormalizeDouble(openPrice - InpBreakevenBufferPts * _Point, digits);
            if((curSL > be || curSL == 0.0) && be > ask)
              {
               if(trade.PositionModify(ticket, be, curTP))
                 {
                  curSL = be;
                  PrintFormat("Breakeven SL -> %.5f (#%I64u)", be, ticket);
                 }
              }
           }

         //--- Step 2: Trailing
         if(!InpUseTrailing) continue;
         if(profitPts < InpTrailActivationRR * riskPts) continue;

         double swingSL = 0.0;
         if(InpTrailMode == TRAIL_SWING || InpTrailMode == TRAIL_HYBRID)
           {
            //--- Lowest confirmed swing high between entry and current price
            for(int s = 0; s < ArraySize(g_swings); s++)
               if(g_swings[s].isHigh &&
                  g_swings[s].price < openPrice &&
                  g_swings[s].price > ask)
                  if(swingSL == 0.0 || g_swings[s].price < swingSL)
                     swingSL = g_swings[s].price;

            if(swingSL > 0.0)
               swingSL += buffer;
           }

         double atrSL = 0.0;
         if(InpTrailMode == TRAIL_ATR || InpTrailMode == TRAIL_HYBRID)
            atrSL = ask + atr[0] * InpTrailATRMult;

         //--- Tightest = lowest candidate for a sell
         double newSL = 0.0;
         if(swingSL > 0.0 && atrSL > 0.0) newSL = MathMin(swingSL, atrSL);
         else if(swingSL > 0.0)           newSL = swingSL;
         else                             newSL = atrSL;
         newSL = NormalizeDouble(newSL, digits);

         if(newSL > 0.0 && (curSL == 0.0 || newSL < curSL - _Point) && newSL > ask)
           {
            if(trade.PositionModify(ticket, newSL, curTP))
               PrintFormat("Trail SL -> %.5f (#%I64u | mode: %s)",
                           newSL, ticket, TrailModeToString(InpTrailMode));
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Helper: Trailing mode to string                                  |
//+------------------------------------------------------------------+
string TrailModeToString(TRAIL_MODE m)
  {
   switch(m)
     {
      case TRAIL_SWING:  return "SWING";
      case TRAIL_ATR:    return "ATR";
      case TRAIL_HYBRID: return "HYBRID";
     }
   return "UNKNOWN";
  }

//+------------------------------------------------------------------+
//| Draw a scored swing (leg line + label)                           |
//+------------------------------------------------------------------+
void DrawSwing(const SwingPoint &sp)
  {
   if(!InpDrawObjects)
      return;

   string id = "SPB5_LEG_" + TimeToString(sp.time, TIME_DATE | TIME_MINUTES);
   color clr = sp.strong ? (sp.isHigh ? InpStrongBullColor : InpStrongBearColor)
                         : InpWeakColor;

   ObjectDelete(0, id);
   ObjectCreate(0, id, OBJ_TREND, 0, sp.originTime, sp.originPrice, sp.time, sp.price);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, id, OBJPROP_WIDTH, sp.strong ? 2 : 1);
   ObjectSetInteger(0, id, OBJPROP_STYLE, sp.strong ? STYLE_SOLID : STYLE_DOT);
   ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);

   string lbl = "SPB5_LBL_" + TimeToString(sp.time, TIME_DATE | TIME_MINUTES);
   ObjectDelete(0, lbl);
   ObjectCreate(0, lbl, OBJ_TEXT, 0, sp.time, sp.price);
   ObjectSetString(0, lbl, OBJPROP_TEXT, StringFormat("%.0f", sp.score));
   ObjectSetInteger(0, lbl, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, lbl, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, lbl, OBJPROP_ANCHOR, sp.isHigh ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0, lbl, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Draw the active pullback zone                                    |
//+------------------------------------------------------------------+
void DrawZone()
  {
   if(!InpDrawObjects)
      return;

   string id = "SPB5_ZONE";
   ObjectDelete(0, id);
   datetime t1 = g_setup.swingTime;
   datetime t2 = TimeCurrent() + PeriodSeconds(_Period) * 30;

   ObjectCreate(0, id, OBJ_RECTANGLE, 0, t1, g_setup.zoneUpper, t2, g_setup.zoneLower);
   ObjectSetInteger(0, id, OBJPROP_COLOR, InpZoneColor);
   ObjectSetInteger(0, id, OBJPROP_FILL, true);
   ObjectSetInteger(0, id, OBJPROP_BACK, true);
   ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Reset setup state                                                |
//+------------------------------------------------------------------+
void ResetSetup()
  {
   g_setup.state       = SETUP_NONE;
   g_setup.bullish     = false;
   g_setup.legHigh     = 0.0;
   g_setup.legLow      = 0.0;
   g_setup.zoneUpper   = 0.0;
   g_setup.zoneLower   = 0.0;
   g_setup.swingTime   = 0;
   g_setup.enteredZone = false;
  }

//+------------------------------------------------------------------+
//| Chart comment dashboard                                          |
//+------------------------------------------------------------------+
void UpdateDashboard()
  {
   int total  = ArraySize(g_swings);
   int strong = 0, weak = 0;
   for(int i = 0; i < total; i++)
     {
      if(g_swings[i].originTime == 0) continue;
      if(g_swings[i].strong) strong++;
      else weak++;
     }

   string state = "NONE";
   switch(g_setup.state)
     {
      case SETUP_ARMED:   state = "ARMED (" + (g_setup.bullish ? "BUY" : "SELL") + ")"; break;
      case SETUP_IN_ZONE: state = "IN ZONE (" + (g_setup.bullish ? "BUY" : "SELL") + ")"; break;
      case SETUP_DONE:    state = "DONE"; break;
     }

   Comment(StringFormat(
      "Swing Pullback Part 5 - Candle Imbalance Filter\n" +
      "Swings scored: %d | Strong: %d | Weak filtered: %d\n" +
      "Min score: %.1f | Setup: %s\n" +
      "Trailing: %s | BE: %s\n" +
      "Open positions: %d / %d",
      strong + weak, strong, weak,
      InpMinImbalanceScore, state,
      InpUseTrailing ? TrailModeToString(InpTrailMode) : "OFF",
      InpMoveToBreakeven ? "ON" : "OFF",
      CountOpenPositions(), InpMaxOpenTrades));
  }
//+------------------------------------------------------------------+