//+------------------------------------------------------------------+
//|                                            Dynmc Pllbck Dpth.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                     https://www.mql5.com/en/users/johnhlomohang/ |
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



#include <Trade/Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input int             SwingLookback           = 5;       // Bars for swing detection
input double          DisplacementFactor      = 1.5;     // Impulse strength factor
input int             StructureHoldBars       = 3;       // Bars structure must hold
input int             ATR_Period              = 14;      // ATR calculation period
input int             ATR_AvgPeriod           = 50;      // ATR rolling average period
input double          RiskPercent             = 1.0;     // Risk per trade (%)
input int             StopLossPoints          = 2000;    // Fallback SL in points
input double          RiskRewardRatio         = 2.0;     // Risk:Reward ratio
input double          ATR_SL_Multiplier       = 1.5;     // ATR multiplier for dynamic SL
input double          PullbackMinDepth        = 0.25;    // Minimum pullback depth
input double          PullbackMaxDepth        = 0.65;    // Maximum pullback depth (structure valid)
input bool            RequireCompression      = true;    // Require ATR compression before entry
input bool            Visualize               = true;    // Show visualization

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum MarketState
  {
   ACCUMULATION,
   EXPANSION,
   DISTRIBUTION,
   REVERSAL
  };

enum VolatilityRegime
  {
   LOW_VOL,
   NORMAL_VOL,
   HIGH_VOL,
   EXTREME_VOL
  };

enum PullbackRegime
  {
   PULLBACK_AGGRESSIVE,   // 0.00 - 0.25  : Aggressive continuation / barely pulled back
   PULLBACK_HEALTHY,      // 0.25 - 0.50  : Ideal trend pullback
   PULLBACK_DEEP,         // 0.50 - 0.75  : Deep, still within structure
   PULLBACK_WEAK,         // 0.75 - 1.00  : Structural weakness
   PULLBACK_INVALID       // > 1.00       : Structure failure
  };

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct SwingPoint
  {
   datetime          time;
   double            price;
   bool              isHigh;
   bool              isValid;
   bool              isUsed;
   int               barIndex;
   double            candleSize;

   void              Reset()
     {
      time       = 0;
      price      = 0.0;
      isHigh     = true;
      isValid    = false;
      isUsed     = false;
      barIndex   = -1;
      candleSize = 0.0;
     }
  };

struct LiquidityZone
  {
   double            price;
   datetime          time;
   bool              taken;
   bool              isHigh;
   string            type;

   void              Reset()
     {
      price  = 0.0;
      time   = 0;
      taken  = false;
      isHigh = true;
      type   = "";
     }
  };

struct MarketStructure
  {
   double            lastHigh;
   double            lastLow;
   datetime          lastHighTime;
   datetime          lastLowTime;
   bool              bullish;
   MarketState       state;

   void              Reset()
     {
      lastHigh     = 0.0;
      lastLow      = 0.0;
      lastHighTime = 0;
      lastLowTime  = 0;
      bullish      = true;
      state        = ACCUMULATION;
     }
  };

//--- Pullback Model Structure
struct PullbackModel
  {
   //--- Impulse leg definition
   double            impulseStart;       // Price at impulse origin
   double            impulseEnd;         // Price at impulse peak/trough
   double            impulseSizePoints;  // Raw impulse size in points

   //--- Retracement measurement
   double            retracementPrice;   // Current pullback extreme
   double            retracementDepth;   // Normalized depth [0.0 - 1.0+]

   //--- Volatility context
   double            atrAtImpulse;       // ATR value when impulse occurred
   double            atrDuringPullback;  // ATR during the pullback phase
   double            normalizedDepth;    // retracementDistance / ATR

   //--- Regime classification
   bool              shallowPullback;    // depth < 0.25
   bool              healthyPullback;    // depth 0.25 - 0.50
   bool              deepPullback;       // depth 0.50 - 0.75
   bool              invalidPullback;    // depth > 1.0
   PullbackRegime    regime;

   //--- Efficiency metrics
   double            avgCounterCandleSize; // Average size of retracement candles
   double            overlapPercent;       // % of candles overlapping prior candle
   bool              momentumDecaying;     // Counter-trend momentum is fading

   //--- Compression signal
   bool              compressionDetected; // ATR contracted during pullback

   //--- Quality score
   double            pullbackScore;      // 0-10 quality metric

   //--- Direction
   bool              isBullish;          // Bullish impulse = true

   //--- Timing
   datetime          startTime;
   datetime          endTime;

   void              Reset()
     {
      impulseStart         = 0;
      impulseEnd           = 0;
      impulseSizePoints    = 0;
      retracementPrice     = 0;
      retracementDepth     = 0;
      atrAtImpulse         = 0;
      atrDuringPullback    = 0;
      normalizedDepth      = 0;
      shallowPullback      = false;
      healthyPullback      = false;
      deepPullback         = false;
      invalidPullback      = false;
      regime               = PULLBACK_INVALID;
      avgCounterCandleSize = 0;
      overlapPercent       = 0;
      momentumDecaying     = false;
      compressionDetected  = false;
      pullbackScore        = 0;
      isBullish            = true;
      startTime            = 0;
      endTime              = 0;
     }
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
SwingPoint         swingCandidates[];
SwingPoint         validSwings[];
LiquidityZone      liquidityZones[];
MarketStructure    marketStruct;
PullbackModel      pullbacks[];         // Pullback models array

int                atrHandle;
int                atrAvgHandle;        // Longer-period ATR for average
datetime           lastBarTime = 0;
double             avgCandleSize = 0;
double             currentATR    = 0;   // live ATR
double             avgATR        = 0;   // rolling ATR average
VolatilityRegime   currentVolRegime = NORMAL_VOL; // current vol regime

//--- Trade tracking
datetime           lastTradeTime  = 0;
double             lastTradePrice = 0;
int                lastTradeType  = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(swingCandidates, 0);
   ArrayResize(validSwings, 0);
   ArrayResize(liquidityZones, 0);
   ArrayResize(pullbacks, 0);

   marketStruct.Reset();

   atrHandle = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create ATR handle");
      return INIT_FAILED;
     }

   //--- Second ATR handle for longer rolling average
   atrAvgHandle = iATR(_Symbol, PERIOD_CURRENT, ATR_AvgPeriod);
   if(atrAvgHandle == INVALID_HANDLE)
     {
      Print("Failed to create ATR average handle");
      return INIT_FAILED;
     }

   DetectSwingCandidates();
   ValidateSwings();
   AnalyzePullbackDepth();       // NEW LAYER 2.5
   UpdateLiquidityZones();
   UpdateMarketState();

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
   if(atrAvgHandle != INVALID_HANDLE)
      IndicatorRelease(atrAvgHandle);

   if(Visualize)
     {
      ObjectsDeleteAll(0, "SF_");
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);

   if(currentBarTime != lastBarTime)
     {
      lastBarTime = currentBarTime;

      UpdateAvgCandleSize();
      UpdateATRValues();            // refresh ATR + regime

      DetectSwingCandidates();
      ValidateSwings();
      AnalyzePullbackDepth();       // NEW LAYER 2.5
      UpdateLiquidityZones();
      UpdateMarketState();
      CheckTradeConditions();

      if(Visualize)
         UpdateVisualization();
     }
  }

//+------------------------------------------------------------------+
//| NEW: Update ATR Values and Volatility Regime                     |
//+------------------------------------------------------------------+
void UpdateATRValues()
  {
   double atrBuf[];
   double atrAvgBuf[];
   ArraySetAsSeries(atrBuf,    true);
   ArraySetAsSeries(atrAvgBuf, true);

   if(CopyBuffer(atrHandle,    0, 0, 1, atrBuf)    > 0) currentATR = atrBuf[0];
   if(CopyBuffer(atrAvgHandle, 0, 0, 1, atrAvgBuf) > 0) avgATR     = atrAvgBuf[0];

   if(avgATR == 0) return;

   double ratio = currentATR / avgATR;

   if(ratio < 0.7)
      currentVolRegime = LOW_VOL;
   else if(ratio < 1.2)
      currentVolRegime = NORMAL_VOL;
   else if(ratio < 1.8)
      currentVolRegime = HIGH_VOL;
   else
      currentVolRegime = EXTREME_VOL;
  }

//+------------------------------------------------------------------+
//| NEW LAYER 2.5: Dynamic Pullback Depth Analysis                   |
//+------------------------------------------------------------------+
void AnalyzePullbackDepth()
  {
   ArrayResize(pullbacks, 0);
   int pbCount = 0;

   int swingCount = ArraySize(validSwings);
   if(swingCount < 3)
      return;

   //--- Pair consecutive swings into impulse legs
   //--- Bullish impulse: Low -> High
   //--- Bearish impulse: High -> Low
   for(int i = 0; i < swingCount - 2; i++)
     {
      SwingPoint a = validSwings[i];
      SwingPoint b = validSwings[i + 1];
      SwingPoint c = validSwings[i + 2]; // The pullback extreme

      bool bullishImpulse = (!a.isHigh && b.isHigh);
      bool bearishImpulse = (a.isHigh  && !b.isHigh);

      if(!bullishImpulse && !bearishImpulse)
         continue;

      PullbackModel pb;
      pb.Reset();
      pb.isBullish  = bullishImpulse;
      pb.startTime  = a.time;
      pb.endTime    = c.time;

      if(bullishImpulse)
        {
         pb.impulseStart = a.price;  // swing low
         pb.impulseEnd   = b.price;  // swing high
         pb.retracementPrice = c.price; // next swing low (pullback)
        }
      else
        {
         pb.impulseStart = a.price;  // swing high
         pb.impulseEnd   = b.price;  // swing low
         pb.retracementPrice = c.price; // next swing high (pullback)
        }

      pb.impulseSizePoints = MathAbs(pb.impulseEnd - pb.impulseStart) / _Point;

      //--- Skip negligible impulses
      if(pb.impulseSizePoints < 10)
         continue;

      //--- Calculate normalized retracement depth [0.0 - 1.0+]
      double impulseRange = MathAbs(pb.impulseEnd - pb.impulseStart);

      if(bullishImpulse)
         pb.retracementDepth = (pb.impulseEnd - pb.retracementPrice) / impulseRange;
      else
         pb.retracementDepth = (pb.retracementPrice - pb.impulseEnd) / impulseRange;

      //--- Clamp floor
      if(pb.retracementDepth < 0) pb.retracementDepth = 0;

      //--- ATR context at impulse
      pb.atrAtImpulse = currentATR;

      //--- Volatility-normalized depth: how many ATRs is the pullback?
      double retracementDistance = MathAbs(pb.impulseEnd - pb.retracementPrice);
      pb.normalizedDepth = (currentATR > 0) ? retracementDistance / currentATR : 0;

      //--- Adaptive depth thresholds based on vol regime
      double adaptiveMax = PullbackMaxDepth;
      double adaptiveMin = PullbackMinDepth;

      switch(currentVolRegime)
        {
         case LOW_VOL:
            //--- Low vol = expect tighter, shallower pullbacks
            adaptiveMax = PullbackMaxDepth - 0.10;
            adaptiveMin = PullbackMinDepth;
            break;
         case HIGH_VOL:
            //--- High vol = accept deeper pullbacks before invalidation
            adaptiveMax = PullbackMaxDepth + 0.10;
            adaptiveMin = PullbackMinDepth - 0.05;
            break;
         case EXTREME_VOL:
            adaptiveMax = PullbackMaxDepth + 0.15;
            adaptiveMin = PullbackMinDepth - 0.10;
            break;
         default:
            break;
        }

      //--- Classify pullback regime
      if(pb.retracementDepth < 0.25)
        {
         pb.shallowPullback = true;
         pb.regime = PULLBACK_AGGRESSIVE;
        }
      else if(pb.retracementDepth < 0.50)
        {
         pb.healthyPullback = true;
         pb.regime = PULLBACK_HEALTHY;
        }
      else if(pb.retracementDepth < 0.75)
        {
         pb.deepPullback = true;
         pb.regime = PULLBACK_DEEP;
        }
      else if(pb.retracementDepth < 1.0)
        {
         pb.regime = PULLBACK_WEAK;
        }
      else
        {
         pb.invalidPullback = true;
         pb.regime = PULLBACK_INVALID;
        }

      //--- Pullback efficiency analysis
      MeasurePullbackEfficiency(pb, i + 1);

      //--- Compression detection
      pb.compressionDetected = DetectVolatilityCompression(pb);

      //--- Score the pullback quality (0–10)
      pb.pullbackScore = ScorePullback(pb, adaptiveMin, adaptiveMax);

      ArrayResize(pullbacks, pbCount + 1);
      pullbacks[pbCount] = pb;
      pbCount++;
     }
  }

//+------------------------------------------------------------------+
//| Measure pullback efficiency (candle overlap + momentum decay)    |
//+------------------------------------------------------------------+
void MeasurePullbackEfficiency(PullbackModel &pb, int impulseEndSwingIdx)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 80, rates);
   if(copied < 5) return;

   //--- Find bar index of impulse end
   int startBar = FindBarIndexByTime(validSwings[impulseEndSwingIdx].time);
   if(startBar < 0) return;

   double totalCounterSize = 0;
   int    overlapCount     = 0;
   int    candleCount      = 0;
   double lastCounterSize  = 0;

   //--- Scan up to 15 bars of pullback
   int scanBars = MathMin(startBar, 15);
   for(int i = 1; i <= scanBars; i++)
     {
      if(startBar - i < 0 || startBar - i >= copied) break;

      double candleBody = MathAbs(rates[startBar - i].close - rates[startBar - i].open);
      totalCounterSize += candleBody;

      //--- Check overlap with previous candle (sign of weak counter-trend)
      if(i > 1)
        {
         double prevHigh = rates[startBar - i + 1].high;
         double prevLow  = rates[startBar - i + 1].low;
         double curHigh  = rates[startBar - i].high;
         double curLow   = rates[startBar - i].low;
         if(curHigh < prevHigh && curLow > prevLow)
            overlapCount++;
        }

      //--- Momentum decay: compare early vs late pullback candle size
      if(i == 1) lastCounterSize = candleBody;
      candleCount++;
     }

   pb.avgCounterCandleSize = (candleCount > 0) ? totalCounterSize / candleCount : 0;
   pb.overlapPercent       = (candleCount > 1)  ? (double)overlapCount / (candleCount - 1) * 100.0 : 0;

   //--- Momentum is decaying if average counter candle is shrinking
   pb.momentumDecaying = (pb.avgCounterCandleSize > 0 &&
                          lastCounterSize < pb.avgCounterCandleSize * 0.7);
  }

//+------------------------------------------------------------------+
//| Detect volatility compression during pullback                    |
//+------------------------------------------------------------------+
bool DetectVolatilityCompression(PullbackModel &pb)
  {
   if(avgATR == 0) return false;

   //--- ATR has contracted below 80% of average during pullback
   return (currentATR < avgATR * 0.8);
  }

//+------------------------------------------------------------------+
//| Score pullback quality (0–10)                                    |
//+------------------------------------------------------------------+
double ScorePullback(PullbackModel &pb, double adaptiveMin, double adaptiveMax)
  {
   double score = 0;

   //--- Depth scoring
   if(pb.retracementDepth >= adaptiveMin && pb.retracementDepth <= adaptiveMax)
      score += 4.0;   // ideal zone
   else if(pb.retracementDepth < adaptiveMin)
      score += 2.0;   // too shallow, possible continuation but lower conviction
   else if(pb.retracementDepth > adaptiveMax && pb.retracementDepth < 1.0)
      score += 1.0;   // deep but not invalid
   //--- > 1.0 = 0 points

   //--- ATR-normalized depth bonus
   //--- 1-2 ATRs of pullback is ideal
   if(pb.normalizedDepth >= 0.8 && pb.normalizedDepth <= 2.0)
      score += 2.0;
   else if(pb.normalizedDepth > 2.0)
      score -= 1.0;  // over-extended

   //--- Efficiency bonus
   if(pb.overlapPercent > 50.0)
      score += 1.5;   // choppy/overlapping pullback = weak counter-trend
   if(pb.momentumDecaying)
      score += 1.0;   // fading counter-trend momentum

   //--- Compression bonus
   if(pb.compressionDetected)
      score += 1.5;   // volatility coil before expansion

   //--- Penalty for structural weakness
   if(pb.regime == PULLBACK_WEAK || pb.regime == PULLBACK_INVALID)
      score -= 3.0;

   return MathMax(0.0, MathMin(10.0, score));
  }

//+------------------------------------------------------------------+
//| Get best (most recent, highest scoring) pullback for direction   |
//+------------------------------------------------------------------+
bool GetBestPullback(bool bullish, PullbackModel &outPb)
  {
   int    bestIdx   = -1;
   double bestScore = -1;

   for(int i = 0; i < ArraySize(pullbacks); i++)
     {
      if(pullbacks[i].isBullish != bullish) continue;
      if(pullbacks[i].invalidPullback)      continue;
      if(pullbacks[i].pullbackScore > bestScore)
        {
         bestScore = pullbacks[i].pullbackScore;
         bestIdx   = i;
        }
     }

   if(bestIdx < 0) return false;
   outPb = pullbacks[bestIdx];
   return true;
  }

//+------------------------------------------------------------------+
//| LAYER 1: Raw Swing Detection                                     |
//+------------------------------------------------------------------+
void DetectSwingCandidates()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates);

   if(copied < SwingLookback * 2 + 1) return;

   SwingPoint tempCandidates[];
   ArrayResize(tempCandidates, 0);
   int newCount = 0;

   for(int i = SwingLookback; i < copied - SwingLookback; i++)
     {
      bool isSwingHigh = true;
      bool isSwingLow  = true;

      for(int j = 1; j <= SwingLookback; j++)
        {
         if(rates[i].high <= rates[i-j].high || rates[i].high <= rates[i+j].high) isSwingHigh = false;
         if(rates[i].low  >= rates[i-j].low  || rates[i].low  >= rates[i+j].low)  isSwingLow  = false;
        }

      if(isSwingHigh)
        {
         SwingPoint sp; sp.Reset();
         sp.time       = rates[i].time;
         sp.price      = rates[i].high;
         sp.isHigh     = true;
         sp.barIndex   = i;
         sp.candleSize = (rates[i].high - rates[i].low) / _Point;
         ArrayResize(tempCandidates, newCount + 1);
         tempCandidates[newCount++] = sp;
        }

      if(isSwingLow)
        {
         SwingPoint sp; sp.Reset();
         sp.time       = rates[i].time;
         sp.price      = rates[i].low;
         sp.isHigh     = false;
         sp.barIndex   = i;
         sp.candleSize = (rates[i].high - rates[i].low) / _Point;
         ArrayResize(tempCandidates, newCount + 1);
         tempCandidates[newCount++] = sp;
        }
     }

   ArrayResize(swingCandidates, newCount);
   for(int i = 0; i < newCount; i++)
      swingCandidates[i] = tempCandidates[i];
  }

//+------------------------------------------------------------------+
//| LAYER 2: Structural Validation Engine                            |
//+------------------------------------------------------------------+
void ValidateSwings()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 50, rates);

   if(ArraySize(rates) < StructureHoldBars + 1) return;

   for(int i = 0; i < ArraySize(swingCandidates); i++)
      swingCandidates[i].isValid = false;

   ArrayResize(validSwings, 0);
   int validCount = 0;

   for(int i = 0; i < ArraySize(swingCandidates); i++)
     {
      bool isValid = false;
      if(CheckBreakOfStructure(swingCandidates[i], rates)) isValid = true;
      if(CheckDisplacement(swingCandidates[i], rates))     isValid = true;
      if(CheckLiquiditySweep(swingCandidates[i], rates))   isValid = true;
      if(CheckTimeRespect(swingCandidates[i], rates))      isValid = true;

      if(isValid)
        {
         swingCandidates[i].isValid = true;
         ArrayResize(validSwings, validCount + 1);
         validSwings[validCount++] = swingCandidates[i];
        }
     }
  }

//+------------------------------------------------------------------+
//| Validation A: Break of Structure                                 |
//+------------------------------------------------------------------+
bool CheckBreakOfStructure(SwingPoint &sp, MqlRates &rates[])
{
   double extreme = 0;
   if(sp.isHigh)
     {
      for(int i = 0; i < ArraySize(validSwings); i++)
         if(validSwings[i].isHigh && validSwings[i].time < sp.time)
            if(extreme == 0 || validSwings[i].price > extreme)
               extreme = validSwings[i].price;
      return (extreme > 0 && sp.price > extreme);
     }
   else
     {
      for(int i = 0; i < ArraySize(validSwings); i++)
         if(!validSwings[i].isHigh && validSwings[i].time < sp.time)
            if(extreme == 0 || validSwings[i].price < extreme)
               extreme = validSwings[i].price;
      return (extreme > 0 && sp.price < extreme);
     }
}
//+------------------------------------------------------------------+
//| Validation B: Displacement                                       |
//+------------------------------------------------------------------+
bool CheckDisplacement(SwingPoint &sp, MqlRates &rates[])
  {
   if(avgCandleSize == 0) return false;
   return (sp.candleSize > avgCandleSize * DisplacementFactor);
  }

//+------------------------------------------------------------------+
//| Validation C: Liquidity Sweep                                    |
//+------------------------------------------------------------------+
bool CheckLiquiditySweep(SwingPoint &sp, MqlRates &rates[])
  {
   int barIndex = FindBarIndexByTime(sp.time);
   if(barIndex < 0 || barIndex >= ArraySize(rates)) return false;

   if(sp.isHigh)
     {
      for(int i = 0; i < ArraySize(validSwings); i++)
         if(validSwings[i].isHigh && validSwings[i].time < sp.time)
            if(rates[barIndex].high > validSwings[i].price && rates[barIndex].close < validSwings[i].price)
               return true;
     }
   else
     {
      for(int i = 0; i < ArraySize(validSwings); i++)
         if(!validSwings[i].isHigh && validSwings[i].time < sp.time)
            if(rates[barIndex].low < validSwings[i].price && rates[barIndex].close > validSwings[i].price)
               return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Validation D: Time-Based Respect                                 |
//+------------------------------------------------------------------+
bool CheckTimeRespect(SwingPoint &sp, MqlRates &rates[])
{
   int barIndex = FindBarIndexByTime(sp.time);
   //--- If not enough bars ahead, we cannot confirm, so accept the swing
   if(barIndex < 0 || barIndex + StructureHoldBars >= ArraySize(rates))
      return true;

   if(sp.isHigh)
     {
      for(int i = 1; i <= StructureHoldBars; i++)
         if(rates[barIndex + i].high > sp.price) return false;
      return true;
     }
   else
     {
      for(int i = 1; i <= StructureHoldBars; i++)
         if(rates[barIndex + i].low < sp.price) return false;
      return true;
     }
}
//+------------------------------------------------------------------+
//| LAYER 3: Liquidity Interaction Layer                             |
//+------------------------------------------------------------------+
void UpdateLiquidityZones()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates);
   if(ArraySize(rates) < 50) return;

   ArrayResize(liquidityZones, 0);
   int zoneCount = 0;

   for(int i = 0; i < ArraySize(validSwings) - 1; i++)
      for(int j = i + 1; j < ArraySize(validSwings); j++)
        {
         double priceDiff = MathAbs(validSwings[i].price - validSwings[j].price);
         if(priceDiff < _Point * 10 && validSwings[i].isHigh == validSwings[j].isHigh)
           {
            LiquidityZone zone; zone.Reset();
            zone.price  = validSwings[i].price;
            zone.time   = validSwings[i].time;
            zone.isHigh = validSwings[i].isHigh;
            zone.type   = "equal";
            zone.taken  = CheckIfLiquidityTaken(zone, rates);
            ArrayResize(liquidityZones, zoneCount + 1);
            liquidityZones[zoneCount++] = zone;
            break;
           }
        }

   for(int i = 0; i < ArraySize(validSwings); i++)
      if(!validSwings[i].isUsed)
        {
         LiquidityZone zone; zone.Reset();
         zone.price  = validSwings[i].price;
         zone.time   = validSwings[i].time;
         zone.isHigh = validSwings[i].isHigh;
         zone.type   = "untouched";
         zone.taken  = CheckIfLiquidityTaken(zone, rates);
         ArrayResize(liquidityZones, zoneCount + 1);
         liquidityZones[zoneCount++] = zone;
        }
  }

//+------------------------------------------------------------------+
//| Check if liquidity zone has been taken                           |
//+------------------------------------------------------------------+
bool CheckIfLiquidityTaken(LiquidityZone &zone, MqlRates &rates[])
  {
   for(int i = 0; i < ArraySize(rates); i++)
     {
      if(zone.isHigh  && rates[i].high > zone.price) return true;
      if(!zone.isHigh && rates[i].low  < zone.price) return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| LAYER 4: Structural State Machine                                |
//+------------------------------------------------------------------+
void UpdateMarketState()
  {
   if(ArraySize(validSwings) < 2) return;

   SwingPoint lastSwing = validSwings[ArraySize(validSwings) - 1];

   if(lastSwing.isHigh && lastSwing.price > marketStruct.lastHigh)
     {
      marketStruct.lastHigh     = lastSwing.price;
      marketStruct.lastHighTime = lastSwing.time;
     }
   if(!lastSwing.isHigh && (marketStruct.lastLow == 0 || lastSwing.price < marketStruct.lastLow))
     {
      marketStruct.lastLow     = lastSwing.price;
      marketStruct.lastLowTime = lastSwing.time;
     }

   bool higherHigh = false;
   bool higherLow  = false;
   for(int i = 0; i < ArraySize(validSwings); i++)
     {
      if(validSwings[i].isHigh  && validSwings[i].price > marketStruct.lastHigh) higherHigh = true;
      if(!validSwings[i].isHigh && validSwings[i].price > marketStruct.lastLow)  higherLow  = true;
     }
   marketStruct.bullish = (higherHigh && higherLow);

   bool liquiditySweepFailed = CheckLiquiditySweepFailure();

   switch(marketStruct.state)
     {
      case ACCUMULATION:
         if(marketStruct.bullish)  marketStruct.state = EXPANSION;
         else if(ArraySize(validSwings) > 5) marketStruct.state = DISTRIBUTION;
         break;
      case EXPANSION:
         if(!marketStruct.bullish) marketStruct.state = DISTRIBUTION;
         else if(liquiditySweepFailed) marketStruct.state = REVERSAL;
         break;
      case DISTRIBUTION:
         if(marketStruct.bullish)  marketStruct.state = ACCUMULATION;
         else if(liquiditySweepFailed) marketStruct.state = REVERSAL;
         break;
      case REVERSAL:
         if(marketStruct.bullish)  marketStruct.state = ACCUMULATION;
         else if(!marketStruct.bullish) marketStruct.state = ACCUMULATION;
         break;
     }
  }

//+------------------------------------------------------------------+
//| Check liquidity sweep failure                                    |
//+------------------------------------------------------------------+
bool CheckLiquiditySweepFailure()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 10, rates);
   if(ArraySize(rates) < 5) return false;

   for(int i = 0; i < ArraySize(liquidityZones); i++)
     {
      if(liquidityZones[i].isHigh && !liquidityZones[i].taken)
         if(rates[0].high > liquidityZones[i].price && rates[0].close < liquidityZones[i].price)
            return true;
      if(!liquidityZones[i].isHigh && !liquidityZones[i].taken)
         if(rates[0].low < liquidityZones[i].price && rates[0].close > liquidityZones[i].price)
            return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| LAYER 5: Execution Engine (Pullback-Upgraded)                    |
//+------------------------------------------------------------------+
void CheckTradeConditions()
  {
   if(PositionSelect(_Symbol))
     {
      ManageOpenPosition();
      return;
     }

   if(TimeCurrent() - lastTradeTime < PeriodSeconds(PERIOD_CURRENT) * 3)
      return;

   MqlRates current[];
   ArraySetAsSeries(current, true);
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, current);
   if(ArraySize(current) < 2) return;
   if(ArraySize(validSwings) == 0) return;

   SwingPoint lastValidSwing = validSwings[ArraySize(validSwings) - 1];

   if(CheckBuyConditions(lastValidSwing, current))
     {
      ExecuteTrade(ORDER_TYPE_BUY);
      lastTradeTime = TimeCurrent();
      lastTradeType = 1;
     }
   else if(CheckSellConditions(lastValidSwing, current))
     {
      ExecuteTrade(ORDER_TYPE_SELL);
      lastTradeTime = TimeCurrent();
      lastTradeType = -1;
     }
  }

//+------------------------------------------------------------------+
//| NEW: Check Buy Conditions (Pullback-Aware)                       |
//+------------------------------------------------------------------+
bool CheckBuyConditions(SwingPoint &lastSwing, MqlRates &rates[])
  {
   if(lastSwing.isHigh || !lastSwing.isValid) return false;

   //--- Market state filter
   bool goodState = (marketStruct.state == EXPANSION || marketStruct.state == ACCUMULATION);
   if(!goodState) return false;

   //--- Layer 2.5 gate: require a high-quality bullish pullback
   PullbackModel bestPb;
   bool hasPullback = GetBestPullback(true, bestPb);

   if(!hasPullback) return false;
   if(bestPb.invalidPullback) return false;
   if(bestPb.pullbackScore < 4.0) return false;          // Minimum quality threshold

   //--- Require pullback within healthy or deep zone (not way too shallow or broken)
   if(bestPb.retracementDepth < PullbackMinDepth) return false;

   //--- Adaptive max depth
   double adaptiveMax = PullbackMaxDepth;
   if(currentVolRegime == HIGH_VOL)    adaptiveMax += 0.10;
   if(currentVolRegime == EXTREME_VOL) adaptiveMax += 0.15;
   if(bestPb.retracementDepth > adaptiveMax) return false;

   //--- Compression gate (optional)
   if(RequireCompression && !bestPb.compressionDetected) return false;

   //--- Liquidity sweep below (confirming)
   bool liquiditySweep = false;
   for(int i = 0; i < ArraySize(liquidityZones); i++)
      if(!liquidityZones[i].isHigh && !liquidityZones[i].taken)
         if(rates[0].low < liquidityZones[i].price && rates[0].close > liquidityZones[i].price)
           { liquiditySweep = true; break; }

   //--- Bullish displacement return candle
   bool bullishDisplacement = false;
   if(ArraySize(rates) >= 2)
     {
      double candleSize = (rates[0].close - rates[0].open) / _Point;
      if(candleSize > avgCandleSize * DisplacementFactor)
         bullishDisplacement = true;
     }

   return (liquiditySweep || bullishDisplacement);
  }

//+------------------------------------------------------------------+
//| NEW: Check Sell Conditions (Pullback-Aware)                      |
//+------------------------------------------------------------------+
bool CheckSellConditions(SwingPoint &lastSwing, MqlRates &rates[])
  {
   if(!lastSwing.isHigh || !lastSwing.isValid) return false;

   bool goodState = (marketStruct.state == DISTRIBUTION || marketStruct.state == REVERSAL);
   if(!goodState) return false;

   PullbackModel bestPb;
   bool hasPullback = GetBestPullback(false, bestPb);

   if(!hasPullback) return false;
   if(bestPb.invalidPullback) return false;
   if(bestPb.pullbackScore < 4.0) return false;

   if(bestPb.retracementDepth < PullbackMinDepth) return false;

   double adaptiveMax = PullbackMaxDepth;
   if(currentVolRegime == HIGH_VOL)    adaptiveMax += 0.10;
   if(currentVolRegime == EXTREME_VOL) adaptiveMax += 0.15;
   if(bestPb.retracementDepth > adaptiveMax) return false;

   if(RequireCompression && !bestPb.compressionDetected) return false;

   bool liquiditySweep = false;
   for(int i = 0; i < ArraySize(liquidityZones); i++)
      if(liquidityZones[i].isHigh && !liquidityZones[i].taken)
         if(rates[0].high > liquidityZones[i].price && rates[0].close < liquidityZones[i].price)
           { liquiditySweep = true; break; }

   bool bearishDisplacement = false;
   if(ArraySize(rates) >= 2)
     {
      double candleSize = (rates[0].open - rates[0].close) / _Point;
      if(candleSize > avgCandleSize * DisplacementFactor)
         bearishDisplacement = true;
     }

   return (liquiditySweep || bearishDisplacement);
  }

//+------------------------------------------------------------------+
//| Execute Trade                                                    |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE tradeType)
  {
   double price = (tradeType == ORDER_TYPE_BUY) ?
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double sl = CalculateStopLoss(tradeType);
   if(sl == 0) return;

   double riskPoints = MathAbs(price - sl) / _Point;
   double tpPoints   = riskPoints * RiskRewardRatio;
   double tp = (tradeType == ORDER_TYPE_BUY) ?
               price + tpPoints * _Point :
               price - tpPoints * _Point;

   price = NormalizeDouble(price, _Digits);
   sl    = NormalizeDouble(sl,    _Digits);
   tp    = NormalizeDouble(tp,    _Digits);

   double volume = CalculateLotSize(price, sl);

   string comment = StringFormat("SF_%s_PB", (tradeType == ORDER_TYPE_BUY) ? "BUY" : "SELL");
   bool success = trade.PositionOpen(_Symbol, tradeType, volume, price, sl, tp, comment);

   if(success)
     {
      lastTradePrice = price;
      string volLabel = "";
      switch(currentVolRegime)
        {
         case LOW_VOL:     volLabel = "LOW";     break;
         case NORMAL_VOL:  volLabel = "NORMAL";  break;
         case HIGH_VOL:    volLabel = "HIGH";    break;
         case EXTREME_VOL: volLabel = "EXTREME"; break;
        }
      Print(StringFormat("Trade: %s | Price: %.5f | SL: %.5f | TP: %.5f | Lots: %.2f | VolRegime: %s",
                         (tradeType == ORDER_TYPE_BUY) ? "BUY" : "SELL",
                         price, sl, tp, volume, volLabel));

      for(int i = 0; i < ArraySize(validSwings); i++)
         if(MathAbs(validSwings[i].price - price) < _Point * 10)
            validSwings[i].isUsed = true;
     }
   else
      Print("Trade failed: ", trade.ResultRetcodeDescription());
  }

//+------------------------------------------------------------------+
//| NEW: ATR-Dynamic Stop Loss                                       |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE tradeType)
  {
   double atr = (currentATR > 0) ? currentATR : GetCurrentATR();

   if(tradeType == ORDER_TYPE_BUY)
     {
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double nearestLow   = 0;

      for(int i = 0; i < ArraySize(validSwings); i++)
         if(!validSwings[i].isHigh && validSwings[i].price < currentPrice)
            if(nearestLow == 0 || validSwings[i].price > nearestLow)
               nearestLow = validSwings[i].price;

      if(nearestLow > 0)
        {
         //--- Swing-based SL with ATR buffer
         double buffer = atr * ATR_SL_Multiplier * 0.3;
         return NormalizeDouble(nearestLow - buffer, _Digits);
        }
     }
   else
     {
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double nearestHigh  = 0;

      for(int i = 0; i < ArraySize(validSwings); i++)
         if(validSwings[i].isHigh && validSwings[i].price > currentPrice)
            if(nearestHigh == 0 || validSwings[i].price < nearestHigh)
               nearestHigh = validSwings[i].price;

      if(nearestHigh > 0)
        {
         double buffer = atr * ATR_SL_Multiplier * 0.3;
         return NormalizeDouble(nearestHigh + buffer, _Digits);
        }
     }

   //--- Fallback: pure ATR-based SL
   double currentPrice = (tradeType == ORDER_TYPE_BUY) ?
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(atr > 0)
      return (tradeType == ORDER_TYPE_BUY) ?
             currentPrice - atr * ATR_SL_Multiplier :
             currentPrice + atr * ATR_SL_Multiplier;

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return (tradeType == ORDER_TYPE_BUY) ?
          currentPrice - StopLossPoints * point :
          currentPrice + StopLossPoints * point;
  }

//+------------------------------------------------------------------+
//| Manage Open Position (ATR-Dynamic Trailing)                      |
//+------------------------------------------------------------------+
void ManageOpenPosition()
  {
   if(!PositionSelect(_Symbol)) return;

   double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
   double openPrice    = PositionGetDouble(POSITION_PRICE_OPEN);
   int    type         = (int)PositionGetInteger(POSITION_TYPE);
   double atr          = (currentATR > 0) ? currentATR : GetCurrentATR();

   if(type == POSITION_TYPE_BUY)
     {
      for(int i = 0; i < ArraySize(validSwings); i++)
         if(!validSwings[i].isHigh && validSwings[i].price > openPrice &&
            validSwings[i].price < currentPrice)
           {
            double newSL = validSwings[i].price - atr * ATR_SL_Multiplier * 0.3;
            if(newSL > PositionGetDouble(POSITION_SL))
              {
               trade.PositionModify(_Symbol, NormalizeDouble(newSL, _Digits),
                                    PositionGetDouble(POSITION_TP));
               Print(StringFormat("Trail SL -> %.5f (ATR buf: %.5f)", newSL, atr));
              }
           }
     }
   else if(type == POSITION_TYPE_SELL)
     {
      for(int i = 0; i < ArraySize(validSwings); i++)
         if(validSwings[i].isHigh && validSwings[i].price < openPrice &&
            validSwings[i].price > currentPrice)
           {
            double newSL = validSwings[i].price + atr * ATR_SL_Multiplier * 0.3;
            if(newSL < PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0)
              {
               trade.PositionModify(_Symbol, NormalizeDouble(newSL, _Digits),
                                    PositionGetDouble(POSITION_TP));
               Print(StringFormat("Trail SL -> %.5f (ATR buf: %.5f)", newSL, atr));
              }
           }
     }
  }

//+------------------------------------------------------------------+
//| Calculate Lot Size                                               |
//+------------------------------------------------------------------+
double CalculateLotSize(double entry, double sl)
  {
   double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (RiskPercent / 100.0);
   double tickSize   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   if(tickValue == 0 || pointValue == 0) return 0.01;

   double riskPoints = MathAbs(entry - sl) / pointValue;
   double lots = riskAmount / (riskPoints * tickValue * pointValue / tickSize);

   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lots = MathFloor(lots / lotStep) * lotStep;

   return MathMax(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
                  MathMin(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)));
  }

//+------------------------------------------------------------------+
//| Helper: Update Average Candle Size                               |
//+------------------------------------------------------------------+
void UpdateAvgCandleSize()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 50, rates);
   if(copied < 20) return;

   double totalSize = 0;
   for(int i = 0; i < copied; i++)
      totalSize += (rates[i].high - rates[i].low) / _Point;
   avgCandleSize = totalSize / copied;
  }

//+------------------------------------------------------------------+
//| Helper: Find Bar Index by Time                                   |
//+------------------------------------------------------------------+
int FindBarIndexByTime(datetime targetTime)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates);
   for(int i = 0; i < copied; i++)
      if(rates[i].time == targetTime) return i;
   return -1;
  }

//+------------------------------------------------------------------+
//| Helper: Get Current ATR                                          |
//+------------------------------------------------------------------+
double GetCurrentATR()
  {
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(atrHandle, 0, 0, 1, atr) <= 0) return 0;
   return atr[0];
  }

//+------------------------------------------------------------------+
//| Helper: Pullback regime to readable string                       |
//+------------------------------------------------------------------+
string PullbackRegimeToString(PullbackRegime r)
  {
   switch(r)
     {
      case PULLBACK_AGGRESSIVE: return "AGGRESSIVE";
      case PULLBACK_HEALTHY:    return "HEALTHY";
      case PULLBACK_DEEP:       return "DEEP";
      case PULLBACK_WEAK:       return "WEAK";
      case PULLBACK_INVALID:    return "INVALID";
     }
   return "UNKNOWN";
  }

//+------------------------------------------------------------------+
//| Helper: Vol regime to string                                     |
//+------------------------------------------------------------------+
string VolRegimeToString(VolatilityRegime r)
  {
   switch(r)
     {
      case LOW_VOL:     return "LOW";
      case NORMAL_VOL:  return "NORMAL";
      case HIGH_VOL:    return "HIGH";
      case EXTREME_VOL: return "EXTREME";
     }
   return "UNKNOWN";
  }

//+------------------------------------------------------------------+
//| Visualization                                                    |
//+------------------------------------------------------------------+
void UpdateVisualization()
  {
   ObjectsDeleteAll(0, "SF_");

   //--- Valid swings
   for(int i = 0; i < ArraySize(validSwings); i++)
     {
      color  clr    = validSwings[i].isHigh ? clrGreen : clrRed;
      string prefix = validSwings[i].isHigh ? "ValidHigh" : "ValidLow";
      string name   = StringFormat("SF_%s_%d", prefix, validSwings[i].time);
      ObjectCreate(0, name, OBJ_ARROW, 0, validSwings[i].time, validSwings[i].price);
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, validSwings[i].isHigh ? 218 : 217);
      ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  10);
     }

   //--- Invalid swing candidates (gray)
   for(int i = 0; i < ArraySize(swingCandidates); i++)
      if(!swingCandidates[i].isValid)
        {
         string name = StringFormat("SF_Invalid_%d", swingCandidates[i].time);
         ObjectCreate(0, name, OBJ_ARROW, 0, swingCandidates[i].time, swingCandidates[i].price);
         ObjectSetInteger(0, name, OBJPROP_ARROWCODE, swingCandidates[i].isHigh ? 218 : 217);
         ObjectSetInteger(0, name, OBJPROP_COLOR,     clrGray);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  10);
        }

   //--- NEW: Draw pullback retracement zones (30%, 50%, 70% levels)
   for(int i = 0; i < ArraySize(pullbacks); i++)
     {
      PullbackModel pb = pullbacks[i];
      if(pb.impulseSizePoints < 10) continue;

      double impulseRange = MathAbs(pb.impulseEnd - pb.impulseStart);
      double level30, level50, level70;

      if(pb.isBullish)
        {
         level30 = pb.impulseEnd - impulseRange * 0.30;
         level50 = pb.impulseEnd - impulseRange * 0.50;
         level70 = pb.impulseEnd - impulseRange * 0.70;
        }
      else
        {
         level30 = pb.impulseEnd + impulseRange * 0.30;
         level50 = pb.impulseEnd + impulseRange * 0.50;
         level70 = pb.impulseEnd + impulseRange * 0.70;
        }

      datetime tStart = pb.startTime;
      datetime tEnd   = pb.endTime;
      if(tEnd <= tStart) tEnd = tStart + PeriodSeconds(PERIOD_CURRENT) * 20;

      //--- 30%-50% zone: green (healthy)
      string nameGreen = StringFormat("SF_PB_Green_%d", i);
      ObjectCreate(0, nameGreen, OBJ_RECTANGLE, 0,
                   tStart, (pb.isBullish ? level50 : level30),
                   tEnd,   (pb.isBullish ? level30 : level50));
      ObjectSetInteger(0, nameGreen, OBJPROP_COLOR, clrDarkGreen);
      ObjectSetInteger(0, nameGreen, OBJPROP_FILL,  true);
      ObjectSetInteger(0, nameGreen, OBJPROP_BACK,  true);

      //--- 50%-70% zone: yellow (deep)
      string nameYellow = StringFormat("SF_PB_Yellow_%d", i);
      ObjectCreate(0, nameYellow, OBJ_RECTANGLE, 0,
                   tStart, (pb.isBullish ? level70 : level50),
                   tEnd,   (pb.isBullish ? level50 : level70));
      ObjectSetInteger(0, nameYellow, OBJPROP_COLOR, clrDarkKhaki);
      ObjectSetInteger(0, nameYellow, OBJPROP_FILL,  true);
      ObjectSetInteger(0, nameYellow, OBJPROP_BACK,  true);

      //--- Score label
      string scoreLabel = StringFormat("SF_Score_%d", i);
      ObjectCreate(0, scoreLabel, OBJ_TEXT, 0, tStart, pb.impulseEnd);
      ObjectSetString(0, scoreLabel, OBJPROP_TEXT,
                      StringFormat("PB:%.2f | %s | Sc:%.1f%s",
                                   pb.retracementDepth,
                                   PullbackRegimeToString(pb.regime),
                                   pb.pullbackScore,
                                   pb.compressionDetected ? " [COMP]" : ""));
      ObjectSetInteger(0, scoreLabel, OBJPROP_COLOR,    clrCyan);
      ObjectSetInteger(0, scoreLabel, OBJPROP_FONTSIZE, 8);
     }

   //--- Liquidity zones
   for(int i = 0; i < ArraySize(liquidityZones); i++)
      if(!liquidityZones[i].taken)
        {
         string name     = StringFormat("SF_Liq_%d", i);
         datetime tNow   = TimeCurrent();
         datetime tStart = tNow - PeriodSeconds(PERIOD_CURRENT) * 10;
         color zoneClr   = liquidityZones[i].isHigh ? clrOrange : clrLightBlue;
         ObjectCreate(0, name, OBJ_RECTANGLE, 0,
                      tStart, liquidityZones[i].price + _Point * 5,
                      tNow,   liquidityZones[i].price - _Point * 5);
         ObjectSetInteger(0, name, OBJPROP_COLOR, zoneClr);
         ObjectSetInteger(0, name, OBJPROP_FILL,  true);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
        }

   //--- HUD labels
   string stateText = "State: ";
   switch(marketStruct.state)
     {
      case ACCUMULATION: stateText += "ACCUMULATION"; break;
      case EXPANSION:    stateText += "EXPANSION";    break;
      case DISTRIBUTION: stateText += "DISTRIBUTION"; break;
      case REVERSAL:     stateText += "REVERSAL";     break;
     }

   CreateLabel("State",      stateText, 10, 20, clrWhite);
   CreateLabel("Trend",      StringFormat("Trend: %s", marketStruct.bullish ? "BULLISH" : "BEARISH"),
               10, 40, marketStruct.bullish ? clrLime : clrRed);
   CreateLabel("VolRegime",  StringFormat("Vol Regime: %s (ATR: %.5f | Avg: %.5f)",
               VolRegimeToString(currentVolRegime), currentATR, avgATR),
               10, 60, clrYellow);
   CreateLabel("ValidSwings",StringFormat("Valid Swings: %d | Pullbacks: %d",
               ArraySize(validSwings), ArraySize(pullbacks)),
               10, 80, clrCyan);

   //--- Best pullback info
   PullbackModel bestBull, bestBear;
   bool hasBull = GetBestPullback(true,  bestBull);
   bool hasBear = GetBestPullback(false, bestBear);

   if(hasBull)
      CreateLabel("BestBull", StringFormat("Bull PB: %.2f | %s | Score: %.1f%s%s",
                  bestBull.retracementDepth,
                  PullbackRegimeToString(bestBull.regime),
                  bestBull.pullbackScore,
                  bestBull.compressionDetected ? " COMP" : "",
                  bestBull.momentumDecaying    ? " DECAY" : ""),
                  10, 100, clrLimeGreen);

   if(hasBear)
      CreateLabel("BestBear", StringFormat("Bear PB: %.2f | %s | Score: %.1f%s%s",
                  bestBear.retracementDepth,
                  PullbackRegimeToString(bestBear.regime),
                  bestBear.pullbackScore,
                  bestBear.compressionDetected ? " COMP" : "",
                  bestBear.momentumDecaying    ? " DECAY" : ""),
                  10, 120, clrOrangeRed);

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Create Label helper                                              |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr)
  {
   string objName = "SF_" + name;
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0,  objName, OBJPROP_TEXT,      text);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE,  10);
  }
//+------------------------------------------------------------------+