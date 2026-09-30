//+------------------------------------------------------------------+
//|                                        Structural_Validation.mq5 |
//|                        GIT under Copyright 2025, MetaQuotes Ltd. |
//|                     https://www.mql5.com/en/users/johnhlomohang/ |
//+------------------------------------------------------------------+
#property copyright "GIT under Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/johnhlomohang/"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input int             SwingLookback       = 5;              // Bars for swing detection
input double          DisplacementFactor  = 1.5;            // Impulse strength factor
input int             StructureHoldBars   = 3;              // Bars structure must hold
input int             ATR_Period          = 14;             // ATR calculation period
input double          RiskPercent         = 1.0;            // Risk per trade (%)
input int             StopLossPoints      = 2000;           // Stop Loss in points
input double          RiskRewardRatio     = 2.0;            // Risk:Reward ratio
input bool            Visualize           = true;           // Show visualization

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
      time = 0;
      price = 0.0;
      isHigh = true;
      isValid = false;
      isUsed = false;
      barIndex = -1;
      candleSize = 0.0;
     }
  };

struct LiquidityZone
  {
   double            price;
   datetime          time;
   bool              taken;
   bool              isHigh;      // true = high liquidity, false = low liquidity
   string            type;        // "equal", "session", "untouched"

   void              Reset()
     {
      price = 0.0;
      time = 0;
      taken = false;
      isHigh = true;
      type = "";
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
      lastHigh = 0.0;
      lastLow = 0.0;
      lastHighTime = 0;
      lastLowTime = 0;
      bullish = true;
      state = ACCUMULATION;
     }
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
SwingPoint         swingCandidates[];
SwingPoint         validSwings[];
LiquidityZone      liquidityZones[];
MarketStructure    marketStruct;
int                atrHandle;
datetime           lastBarTime = 0;
datetime           lastSwingDetection = 0;
double             avgCandleSize = 0;

//--- Trade tracking
datetime           lastTradeTime = 0;
double             lastTradePrice = 0;
int                lastTradeType = 0;  // 1 = buy, -1 = sell
double             BID = SymbolInfoDouble(_Symbol,SYMBOL_BID);
double             ASK = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Initialize arrays
   ArrayResize(swingCandidates, 0);
   ArrayResize(validSwings, 0);
   ArrayResize(liquidityZones, 0);

   //--- Initialize market structure
   marketStruct.Reset();

   //--- Initialize ATR handle
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create ATR handle");
      return INIT_FAILED;
     }

   //--- Initial detection
   DetectSwingCandidates();
   ValidateSwings();
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

   //--- Process on new bar
   if(currentBarTime != lastBarTime)
     {
      lastBarTime = currentBarTime;

      //--- Update average candle size
      UpdateAvgCandleSize();

      //--- Layer 1: Detect new swing candidates
      DetectSwingCandidates();

      //--- Layer 2: Validate swings
      ValidateSwings();

      //--- Layer 3: Update liquidity zones
      UpdateLiquidityZones();

      //--- Layer 4: Update market state
      UpdateMarketState();

      //--- Layer 5: Check and execute trades
      CheckTradeConditions();

      //--- Visualization
      if(Visualize)
         UpdateVisualization();
     }
  }

//+------------------------------------------------------------------+
//| LAYER 1: Raw Swing Detection                                     |
//+------------------------------------------------------------------+
void DetectSwingCandidates()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates);

   if(copied < SwingLookback * 2 + 1)
      return;

   //--- Clear old candidates (keep only last 50 bars)
   int newCount = 0;
   SwingPoint tempCandidates[];
   ArrayResize(tempCandidates, 0);

   for(int i = SwingLookback; i < copied - SwingLookback; i++)
     {
      bool isSwingHigh = true;
      bool isSwingLow = true;

      //--- Check swing high
      for(int j = 1; j <= SwingLookback; j++)
        {
         if(rates[i].high <= rates[i-j].high || rates[i].high <= rates[i+j].high)
            isSwingHigh = false;

         if(rates[i].low >= rates[i-j].low || rates[i].low >= rates[i+j].low)
            isSwingLow = false;
        }

      //--- Add swing high candidate
      if(isSwingHigh)
        {
         SwingPoint sp;
         sp.Reset();
         sp.time = rates[i].time;
         sp.price = rates[i].high;
         sp.isHigh = true;
         sp.barIndex = i;
         sp.candleSize = (rates[i].high - rates[i].low) / _Point;

         ArrayResize(tempCandidates, newCount + 1);
         tempCandidates[newCount] = sp;
         newCount++;
        }

      //--- Add swing low candidate
      if(isSwingLow)
        {
         SwingPoint sp;
         sp.Reset();
         sp.time = rates[i].time;
         sp.price = rates[i].low;
         sp.isHigh = false;
         sp.barIndex = i;
         sp.candleSize = (rates[i].high - rates[i].low) / _Point;

         ArrayResize(tempCandidates, newCount + 1);
         tempCandidates[newCount] = sp;
         newCount++;
        }
     }

   //--- Update global candidates array
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

   if(ArraySize(rates) < StructureHoldBars + 1)
      return;

   //--- Reset validation for all candidates
   for(int i = 0; i < ArraySize(swingCandidates); i++)
      swingCandidates[i].isValid = false;

   //--- Clear valid swings array
   ArrayResize(validSwings, 0);
   int validCount = 0;

   for(int i = 0; i < ArraySize(swingCandidates); i++)
     {
      bool isValid = false;

      //--- Validation A: Break of Structure (BoS)
      if(CheckBreakOfStructure(swingCandidates[i], rates))
         isValid = true;

      //--- Validation B: Displacement (Impulse Strength)
      if(CheckDisplacement(swingCandidates[i], rates))
         isValid = true;

      //--- Validation C: Liquidity Sweep
      if(CheckLiquiditySweep(swingCandidates[i], rates))
         isValid = true;

      //--- Validation D: Time-Based Respect
      if(CheckTimeRespect(swingCandidates[i], rates))
         isValid = true;

      if(isValid)
        {
         swingCandidates[i].isValid = true;

         //--- Add to valid swings
         ArrayResize(validSwings, validCount + 1);
         validSwings[validCount] = swingCandidates[i];
         validCount++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Validation A: Break of Structure                                 |
//+------------------------------------------------------------------+
bool CheckBreakOfStructure(SwingPoint &sp, MqlRates &rates[])
  {
   if(sp.isHigh)
     {
      //--- Find previous valid high
      double prevHigh = 0;
      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(validSwings[i].isHigh && validSwings[i].time < sp.time)
           {
            if(prevHigh == 0 || validSwings[i].price > prevHigh)
               prevHigh = validSwings[i].price;
           }
        }
     }
   else
     {
      //--- Find previous valid low
      double prevLow = 0;
      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(!validSwings[i].isHigh && validSwings[i].time < sp.time)
           {
            if(prevLow == 0 || validSwings[i].price < prevLow)
               prevLow = validSwings[i].price;
           }
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Validation B: Displacement (Impulse Strength)                    |
//+------------------------------------------------------------------+
bool CheckDisplacement(SwingPoint &sp, MqlRates &rates[])
  {
   if(avgCandleSize == 0)
      return false;

   double impulseSize = sp.candleSize;
   return (impulseSize > avgCandleSize * DisplacementFactor);
  }

//+------------------------------------------------------------------+
//| Validation C: Liquidity Sweep                                    |
//+------------------------------------------------------------------+
bool CheckLiquiditySweep(SwingPoint &sp, MqlRates &rates[])
  {
   int barIndex = FindBarIndexByTime(sp.time);
   if(barIndex < 0 || barIndex >= ArraySize(rates))
      return false;

   if(sp.isHigh)
     {
      //--- Check if price wicked above previous high and closed below
      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(validSwings[i].isHigh && validSwings[i].time < sp.time)
           {
            double prevHigh = validSwings[i].price;
            if(rates[barIndex].high > prevHigh && rates[barIndex].close < prevHigh)
               return true;
           }
        }
     }
   else
     {
      //--- Check if price wicked below previous low and closed above
      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(!validSwings[i].isHigh && validSwings[i].time < sp.time)
           {
            double prevLow = validSwings[i].price;
            if(rates[barIndex].low < prevLow && rates[barIndex].close > prevLow)
               return true;
           }
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Validation D: Time-Based Respect                                 |
//+------------------------------------------------------------------+
bool CheckTimeRespect(SwingPoint &sp, MqlRates &rates[])
  {
   int barIndex = FindBarIndexByTime(sp.time);
   if(barIndex < 0 || barIndex + StructureHoldBars >= ArraySize(rates))
      return false;

   if(sp.isHigh)
     {
      //--- Structure must hold for X bars (price stays below swing high)
      for(int i = 1; i <= StructureHoldBars; i++)
        {
         if(rates[barIndex + i].high > sp.price)
            return false;
        }
      return true;
     }
   else
     {
      //--- Structure must hold for X bars (price stays above swing low)
      for(int i = 1; i <= StructureHoldBars; i++)
        {
         if(rates[barIndex + i].low < sp.price)
            return false;
        }
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

   if(ArraySize(rates) < 50)
      return;

   //--- Clear old liquidity zones
   ArrayResize(liquidityZones, 0);
   int zoneCount = 0;

   //--- Detect equal highs/lows (double tops/bottoms)
   for(int i = 0; i < ArraySize(validSwings) - 1; i++)
     {
      for(int j = i + 1; j < ArraySize(validSwings); j++)
        {
         double priceDiff = MathAbs(validSwings[i].price - validSwings[j].price);
         if(priceDiff < _Point * 10 && validSwings[i].isHigh == validSwings[j].isHigh)
           {
            LiquidityZone zone;
            zone.Reset();
            zone.price = validSwings[i].price;
            zone.time = validSwings[i].time;
            zone.isHigh = validSwings[i].isHigh;
            zone.type = "equal";
            zone.taken = CheckIfLiquidityTaken(zone, rates);

            ArrayResize(liquidityZones, zoneCount + 1);
            liquidityZones[zoneCount] = zone;
            zoneCount++;
            break;
           }
        }
     }

   //--- Add untouched swing points as liquidity
   for(int i = 0; i < ArraySize(validSwings); i++)
     {
      if(!validSwings[i].isUsed)
        {
         LiquidityZone zone;
         zone.Reset();
         zone.price = validSwings[i].price;
         zone.time = validSwings[i].time;
         zone.isHigh = validSwings[i].isHigh;
         zone.type = "untouched";
         zone.taken = CheckIfLiquidityTaken(zone, rates);

         ArrayResize(liquidityZones, zoneCount + 1);
         liquidityZones[zoneCount] = zone;
         zoneCount++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Check if liquidity zone has been taken                           |
//+------------------------------------------------------------------+
bool CheckIfLiquidityTaken(LiquidityZone &zone, MqlRates &rates[])
  {
   for(int i = 0; i < ArraySize(rates); i++)
     {
      if(zone.isHigh && rates[i].high > zone.price)
         return true;
      if(!zone.isHigh && rates[i].low < zone.price)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| LAYER 4: Structural State Machine                                |
//+------------------------------------------------------------------+
void UpdateMarketState()
  {
   if(ArraySize(validSwings) < 2)
      return;

   //--- Get last two valid swings
   SwingPoint lastSwing = validSwings[ArraySize(validSwings) - 1];
   SwingPoint prevSwing = validSwings[ArraySize(validSwings) - 2];

   //--- Update last high/low
   if(lastSwing.isHigh && lastSwing.price > marketStruct.lastHigh)
     {
      marketStruct.lastHigh = lastSwing.price;
      marketStruct.lastHighTime = lastSwing.time;
     }
   if(!lastSwing.isHigh && (marketStruct.lastLow == 0 || lastSwing.price < marketStruct.lastLow))
     {
      marketStruct.lastLow = lastSwing.price;
      marketStruct.lastLowTime = lastSwing.time;
     }

   //--- Determine trend based on higher highs and higher lows
   bool higherHigh = false;
   bool higherLow = false;

   for(int i = 0; i < ArraySize(validSwings); i++)
     {
      if(validSwings[i].isHigh && validSwings[i].price > marketStruct.lastHigh)
         higherHigh = true;
      if(!validSwings[i].isHigh && validSwings[i].price > marketStruct.lastLow)
         higherLow = true;
     }

   marketStruct.bullish = (higherHigh && higherLow);

   //--- State transition logic
   MarketState prevState = marketStruct.state;

   //--- Check for liquidity sweep failure (potential reversal)
   bool liquiditySweepFailed = CheckLiquiditySweepFailure();

   switch(marketStruct.state)
     {
      case ACCUMULATION:
         if(marketStruct.bullish)
            marketStruct.state = EXPANSION;
         else
            if(!marketStruct.bullish && ArraySize(validSwings) > 5)
               marketStruct.state = DISTRIBUTION;
         break;

      case EXPANSION:
         if(!marketStruct.bullish)
            marketStruct.state = DISTRIBUTION;
         else
            if(liquiditySweepFailed)
               marketStruct.state = REVERSAL;
         break;

      case DISTRIBUTION:
         if(marketStruct.bullish)
            marketStruct.state = ACCUMULATION;
         else
            if(liquiditySweepFailed)
               marketStruct.state = REVERSAL;
         break;

      case REVERSAL:
         if(marketStruct.bullish && prevState == EXPANSION)
            marketStruct.state = ACCUMULATION;
         else
            if(!marketStruct.bullish && prevState == DISTRIBUTION)
               marketStruct.state = ACCUMULATION;
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

   if(ArraySize(rates) < 5)
      return false;

   //--- Check if price swept a high and reversed
   for(int i = 0; i < ArraySize(liquidityZones); i++)
     {
      if(liquidityZones[i].isHigh && !liquidityZones[i].taken)
        {
         if(rates[0].high > liquidityZones[i].price && rates[0].close < liquidityZones[i].price)
            return true;
        }
      if(!liquidityZones[i].isHigh && !liquidityZones[i].taken)
        {
         if(rates[0].low < liquidityZones[i].price && rates[0].close > liquidityZones[i].price)
            return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| LAYER 5: Execution Engine                                        |
//+------------------------------------------------------------------+
void CheckTradeConditions()
  {
   //--- Check if already in a position
   if(PositionSelect(_Symbol))
     {
      //--- Check if we should trail stop or manage position
      ManageOpenPosition();
      return;
     }

   //--- Avoid trading too frequently
   if(TimeCurrent() - lastTradeTime < PeriodSeconds(PERIOD_CURRENT) * 3)
      return;

   MqlRates current[];
   ArraySetAsSeries(current, true);
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, current);

   if(ArraySize(current) < 2)
      return;

   //--- Get last validated swing
   if(ArraySize(validSwings) == 0)
      return;

   SwingPoint lastValidSwing = validSwings[ArraySize(validSwings) - 1];

   //--- Buy conditions
   if(CheckBuyConditions(lastValidSwing, current))
     {
      ExecuteTrade(ORDER_TYPE_BUY);
      lastTradeTime = TimeCurrent();
      lastTradeType = 1;
     }
   //--- Sell conditions
   else
      if(CheckSellConditions(lastValidSwing, current))
        {
         ExecuteTrade(ORDER_TYPE_SELL);
         lastTradeTime = TimeCurrent();
         lastTradeType = -1;
        }
  }

//+------------------------------------------------------------------+
//| Check Buy Conditions                                             |
//+------------------------------------------------------------------+
bool CheckBuyConditions(SwingPoint &lastSwing, MqlRates &rates[])
  {
   //--- Must be a valid low
   if(lastSwing.isHigh || !lastSwing.isValid)
      return false;

   //--- Condition 1: Valid higher low
   double previousLow = 0;
   for(int i = 0; i < ArraySize(validSwings) - 1; i++)
     {
      if(!validSwings[i].isHigh && validSwings[i].price < lastSwing.price)
        {
         if(previousLow == 0 || validSwings[i].price > previousLow)
            previousLow = validSwings[i].price;
        }
     }

   bool higherLow = (previousLow > 0 && lastSwing.price > previousLow);

   //--- Condition 2: Liquidity sweep below
   bool liquiditySweep = false;
   for(int i = 0; i < ArraySize(liquidityZones); i++)
     {
      if(!liquidityZones[i].isHigh && !liquidityZones[i].taken)
        {
         if(rates[0].low < liquidityZones[i].price && rates[0].close > liquidityZones[i].price)
           {
            liquiditySweep = true;
            break;
           }
        }
     }

   //--- Condition 3: Bullish displacement
   bool bullishDisplacement = false;
   if(ArraySize(rates) >= 2)
     {
      double candleSize = (rates[0].close - rates[0].open) / _Point;
      if(candleSize > avgCandleSize * DisplacementFactor)
         bullishDisplacement = true;
     }

   //--- Condition 4: Market state should be bullish or accumulation
   bool goodState = (marketStruct.state == EXPANSION || marketStruct.state == ACCUMULATION);

   return (higherLow || liquiditySweep || bullishDisplacement) && goodState;
  }

//+------------------------------------------------------------------+
//| Check Sell Conditions                                            |
//+------------------------------------------------------------------+
bool CheckSellConditions(SwingPoint &lastSwing, MqlRates &rates[])
  {
   //--- Must be a valid high
   if(!lastSwing.isHigh || !lastSwing.isValid)
      return false;

   //--- Condition 1: Valid lower high
   double previousHigh = 0;
   for(int i = 0; i < ArraySize(validSwings) - 1; i++)
     {
      if(validSwings[i].isHigh && validSwings[i].price > lastSwing.price)
        {
         if(previousHigh == 0 || validSwings[i].price < previousHigh)
            previousHigh = validSwings[i].price;
        }
     }

   bool lowerHigh = (previousHigh > 0 && lastSwing.price < previousHigh);

   //--- Condition 2: Liquidity sweep above
   bool liquiditySweep = false;
   for(int i = 0; i < ArraySize(liquidityZones); i++)
     {
      if(liquidityZones[i].isHigh && !liquidityZones[i].taken)
        {
         if(rates[0].high > liquidityZones[i].price && rates[0].close < liquidityZones[i].price)
           {
            liquiditySweep = true;
            break;
           }
        }
     }

   //--- Condition 3: Bearish displacement
   bool bearishDisplacement = false;
   if(ArraySize(rates) >= 2)
     {
      double candleSize = (rates[0].open - rates[0].close) / _Point;
      if(candleSize > avgCandleSize * DisplacementFactor)
         bearishDisplacement = true;
     }

   //--- Condition 4: Market state should be bearish or distribution
   bool goodState = (marketStruct.state == DISTRIBUTION || marketStruct.state == REVERSAL);

   return (lowerHigh || liquiditySweep || bearishDisplacement) && goodState;
  }

//+------------------------------------------------------------------+
//| Execute Trade                                                    |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE tradeType)
  {
   double price = (tradeType == ORDER_TYPE_BUY) ?
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);

   //--- Calculate stop loss based on validated structure
   double sl = CalculateStopLoss(tradeType);
   if(sl == 0)
      return;

   //--- Calculate take profit based on risk:reward
   double riskPoints = MathAbs(price - sl) / _Point;
   double tpPoints = riskPoints * RiskRewardRatio;
   double tp = (tradeType == ORDER_TYPE_BUY) ?
               price + tpPoints * _Point :
               price - tpPoints * _Point;

   //--- Normalize prices
   price = NormalizeDouble(price, _Digits);
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);

   //--- Calculate lot size
   double volume = CalculateLotSize(price, sl);

   //--- Execute trade
   string comment = StringFormat("SF_%s", (tradeType == ORDER_TYPE_BUY) ? "BUY" : "SELL");
   bool success = trade.PositionOpen(_Symbol, tradeType, volume, price, sl, tp, comment);

   if(success)
     {
      lastTradePrice = price;
      Print(StringFormat("Trade Opened: %s | Price: %.5f | SL: %.5f | TP: %.5f | Lots: %.2f",
                         (tradeType == ORDER_TYPE_BUY) ? "BUY" : "SELL", price, sl, tp, volume));

      //--- Mark used swings
      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(MathAbs(validSwings[i].price - price) < _Point * 10)
            validSwings[i].isUsed = true;
        }
     }
   else
     {
      Print("Trade failed: ", trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Calculate Stop Loss Based on Validated Structure                 |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE tradeType)
  {
   if(ArraySize(validSwings) < 1)
      return 0;

   if(tradeType == ORDER_TYPE_BUY)
     {
      //--- Find nearest valid low below current price
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double nearestLow = 0;

      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(!validSwings[i].isHigh && validSwings[i].price < currentPrice)
           {
            if(nearestLow == 0 || validSwings[i].price > nearestLow)
               nearestLow = validSwings[i].price;
           }
        }

      if(nearestLow > 0)
        {
         double buffer = _Point * 10;
         return nearestLow - buffer;
        }
     }
   else
     {
      //--- Find nearest valid high above current price
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double nearestHigh = 0;

      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(validSwings[i].isHigh && validSwings[i].price > currentPrice)
           {
            if(nearestHigh == 0 || validSwings[i].price < nearestHigh)
               nearestHigh = validSwings[i].price;
           }
        }

      if(nearestHigh > 0)
        {
         double buffer = _Point * 10;
         return nearestHigh + buffer;
        }
     }

   //--- Fallback to fixed stop loss
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double currentPrice = (tradeType == ORDER_TYPE_BUY) ?
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(tradeType == ORDER_TYPE_BUY)
      return currentPrice - (StopLossPoints * point);
   else
      return currentPrice + (StopLossPoints * point);
  }

//+------------------------------------------------------------------+
//| Manage Open Position (Trailing/Exit Logic)                       |
//+------------------------------------------------------------------+
void ManageOpenPosition()
  {
   if(!PositionSelect(_Symbol))
      return;

   double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   int type = (int)PositionGetInteger(POSITION_TYPE);

   //--- Check if we should trail stop to next structure level
   if(type == POSITION_TYPE_BUY)
     {
      //--- Look for higher lows to trail stop
      for(int i = 0; i < ArraySize(validSwings); i++)
        {
         if(!validSwings[i].isHigh && validSwings[i].price > openPrice &&
            validSwings[i].price < currentPrice)
           {
            double newSL = validSwings[i].price - _Point * 5;
            if(newSL > PositionGetDouble(POSITION_SL))
              {
               trade.PositionModify(_Symbol, newSL, PositionGetDouble(POSITION_TP));
               Print(StringFormat("Trailing SL to %.5f", newSL));
              }
           }
        }
     }
   else
      if(type == POSITION_TYPE_SELL)
        {
         //--- Look for lower highs to trail stop
         for(int i = 0; i < ArraySize(validSwings); i++)
           {
            if(validSwings[i].isHigh && validSwings[i].price < openPrice &&
               validSwings[i].price > currentPrice)
              {
               double newSL = validSwings[i].price + _Point * 5;
               if(newSL < PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0)
                 {
                  trade.PositionModify(_Symbol, newSL, PositionGetDouble(POSITION_TP));
                  Print(StringFormat("Trailing SL to %.5f", newSL));
                 }
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
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   if(tickValue == 0 || pointValue == 0)
      return 0.01;

   double riskPoints = MathAbs(entry - sl) / pointValue;
   double lots = riskAmount / (riskPoints * tickValue * pointValue / tickSize);

   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lots = MathFloor(lots / lotStep) * lotStep;

   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   return MathMax(minLot, MathMin(lots, maxLot));
  }

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
void UpdateAvgCandleSize()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 50, rates);

   if(copied < 20)
      return;

   double totalSize = 0;
   for(int i = 0; i < copied; i++)
      totalSize += (rates[i].high - rates[i].low) / _Point;

   avgCandleSize = totalSize / copied;
  }

//+------------------------------------------------------------------+
//|  Find Bar Index by Time                                          |
//+------------------------------------------------------------------+
int FindBarIndexByTime(datetime targetTime)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates);

   for(int i = 0; i < copied; i++)
     {
      if(rates[i].time == targetTime)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Visualization Functions                                          |
//+------------------------------------------------------------------+
void UpdateVisualization()
  {
   ObjectsDeleteAll(0, "SF_");

   //--- Draw valid swings (green for highs, red for lows)
   for(int i = 0; i < ArraySize(validSwings); i++)
     {
      color clr = validSwings[i].isHigh ? clrGreen : clrRed;
      string prefix = validSwings[i].isHigh ? "ValidHigh" : "ValidLow";
      string name = StringFormat("SF_%s_%d", prefix, validSwings[i].time);

      ObjectCreate(0, name, OBJ_ARROW, 0, validSwings[i].time, validSwings[i].price);
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, validSwings[i].isHigh ? 218 : 217);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
     }

   //--- Draw invalid swings (gray)
   for(int i = 0; i < ArraySize(swingCandidates); i++)
     {
      if(!swingCandidates[i].isValid)
        {
         string name = StringFormat("SF_Invalid_%d", swingCandidates[i].time);
         ObjectCreate(0, name, OBJ_ARROW, 0, swingCandidates[i].time, swingCandidates[i].price);
         ObjectSetInteger(0, name, OBJPROP_ARROWCODE, swingCandidates[i].isHigh ? 218 : 217);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrGray);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
        }
     }

   //--- Draw liquidity zones as rectangles
   for(int i = 0; i < ArraySize(liquidityZones); i++)
     {
      if(!liquidityZones[i].taken)
        {
         string name = StringFormat("SF_Liq_%d", i);
         datetime timeNow = TimeCurrent();
         datetime timeStart = timeNow - PeriodSeconds(PERIOD_CURRENT) * 10;
         datetime timeEnd = timeNow;

         color zoneClr = liquidityZones[i].isHigh ? clrOrange : clrLightBlue;

         ObjectCreate(0, name, OBJ_RECTANGLE, 0, timeStart,
                      liquidityZones[i].price + _Point * 5, timeEnd,
                      liquidityZones[i].price - _Point * 5);
         ObjectSetInteger(0, name, OBJPROP_COLOR, zoneClr);
         ObjectSetInteger(0, name, OBJPROP_FILL, true);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
        }
     }

   //--- Draw market state label
   string stateText = "Market State: ";
   switch(marketStruct.state)
     {
      case ACCUMULATION:
         stateText += "ACCUMULATION";
         break;
      case EXPANSION:
         stateText += "EXPANSION (BULLISH)";
         break;
      case DISTRIBUTION:
         stateText += "DISTRIBUTION";
         break;
      case REVERSAL:
         stateText += "REVERSAL";
         break;
     }

   CreateLabel("State", stateText, 10, 20, clrWhite);
   CreateLabel("Trend", StringFormat("Trend: %s", marketStruct.bullish ? "BULLISH" : "BEARISH"),
               10, 40, marketStruct.bullish ? clrLime : clrRed);
   CreateLabel("ValidSwings", StringFormat("Valid Swings: %d", ArraySize(validSwings)),
               10, 60, clrYellow);
  }

//+------------------------------------------------------------------+
//|  Create Lable                                                    |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr)
  {
   string objName = "SF_" + name;
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
  }

//+------------------------------------------------------------------+
//|  Get Current ATR                                                 |
//+------------------------------------------------------------------+
double GetCurrentATR()
  {
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(atrHandle, 0, 0, 1, atr) <= 0)
      return 0;
   return atr[0];
  }
//+------------------------------------------------------------------+
