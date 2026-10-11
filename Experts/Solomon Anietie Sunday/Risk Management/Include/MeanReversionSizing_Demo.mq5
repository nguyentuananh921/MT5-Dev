//+------------------------------------------------------------------+
//|                                     MeanReversionSizing_Demo.mq5 |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, soloharbinger"
#property link      "https://www.mql5.com/en/users/soloharbinger"
#property version   "1.10"
#property description "Companion demo for Building Your Own EA, Part 5 (Risk Mgmt IV)"
#include <Trade/Trade.mqh>

enum ENUM_SIZE_BASE
  {
   SIZE_BASE_BALANCE,   // Account balance
   SIZE_BASE_EQUITY     // Account equity
  };

//--- Input Parameters
input group "Mean Reversion Signal"
input int              BandsPeriod = 20;                 // Bollinger period (defines the mean)
input double           BandsDeviation = 2.0;             // Bollinger deviation
input int              MinExpectedMovePoints = 50;       // Skip signals with less room to mean

input group "Target-Profit Sizing"
input double           TargetProfitPercent = 0.05;       // Profit target per leg [% of account]
input ENUM_SIZE_BASE   SizeBase = SIZE_BASE_BALANCE;     // Target measured against
input double           MaxLotCap = 5.0;                  // Absolute ceiling on volume [0 = off]

input group "Structural Stop (not the sizing input)"
input int              ATRPeriod = 14;                   // ATR period
input double           StopATRMultiplier = 10.0;         // Stop distance as ATR multiple
input double           MaxImpliedRiskPercent = 2.0;      // Cap the risk one leg's stop implies [0 = off]

input group "Basket: Averaging"
input int              MaxOpenPositions = 3;             // Max legs in one basket
input double           MinAddSpacingATR = 1.0;           // An add needs this many ATR beyond the last entry [0 = off]
input double           MaxBasketImpliedRiskPercent = 4.0; // Cap the risk all legs imply together [0 = off]

input group "Basket: Exit and Protection"
input bool             UseBasketExit = true;             // With 2+ legs, exit at the weighted average entry
input double           BasketExitOffsetPips = 1.0;       // Pips beyond the weighted average entry, to cover costs
input double           MaxBasketLossPercent = 10.0;      // Close all if the basket loses this % [0 = off]
input double           MaxSpreadPips = 2.0;              // Maximum allowed spread

input group "General"
input int              MagicNumber = 55221;              // EA Magic Number

//+------------------------------------------------------------------+
//| Everything this EA holds, viewed as one position.                |
//+------------------------------------------------------------------+
struct SDemoBasket
  {
   int               positionCount;
   double            totalVolume;
   double            weightedEntry;    // Volume-weighted average entry price
   double            floatingPL;       // Profit + swap
   double            impliedRisk;      // What every leg's own stop would cost, added up
   int               direction;        // 1 = long, -1 = short, 0 = flat or two-sided
   double            extremeEntry;     // The entry furthest from the mean - the last add
  };

//--- Global Variables
CTrade trade;
int bandsHandle = INVALID_HANDLE;
int atrHandle   = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(MagicNumber);

//--- Buffer 0 is the middle line - that is the mean this EA trades toward
   bandsHandle = iBands(_Symbol, _Period, BandsPeriod, 0, BandsDeviation, PRICE_CLOSE);
   atrHandle   = iATR(_Symbol, _Period, ATRPeriod);

   if(bandsHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create indicator handles.");
      return INIT_FAILED;
     }

   if(BandsPeriod <= 0 || BandsDeviation <= 0)
     {
      Print("Bollinger parameters must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(TargetProfitPercent <= 0)
     {
      Print("Target profit percent must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(ATRPeriod <= 0 || StopATRMultiplier <= 0)
     {
      Print("ATR parameters must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(MaxOpenPositions < 1)
     {
      Print("MaxOpenPositions must be at least 1.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(MinAddSpacingATR < 0 || BasketExitOffsetPips < 0)
     {
      Print("Averaging spacing and basket exit offset cannot be negative.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(MaxBasketLossPercent < 0 || MaxBasketLossPercent > 100 ||
      MaxBasketImpliedRiskPercent < 0 || MaxBasketImpliedRiskPercent > 100)
     {
      Print("Basket percentage limits must be between 0 and 100.");
      return INIT_PARAMETERS_INCORRECT;
     }

//--- What a basket even is depends on the account type
   long marginMode = AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(marginMode == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      PrintFormat("Hedging account: this EA may hold up to %d separate legs.", MaxOpenPositions);
   else
      Print("Note: this is not a hedging account. Same-direction entries build one position rather than several, so the basket never shows more than one leg, raising MaxOpenPositions has no effect, and the shared basket exit never engages.");

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(bandsHandle);
   IndicatorRelease(atrHandle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime == 0)
      return;

   static datetime lastProcessedBarTime = 0;
   if(currentBarTime == lastProcessedBarTime)
      return;
   lastProcessedBarTime = currentBarTime;

//--- Basket protection first, and independent of any signal
   ManageBasketRisk();

   if(BarsCalculated(bandsHandle) < 2 || BarsCalculated(atrHandle) < 1)
      return;

//--- Bollinger buffers: 0 = middle (the mean), 1 = upper, 2 = lower
   double middle[], upper[], lower[], atr[], close[];
   ArraySetAsSeries(middle, true);
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   ArraySetAsSeries(atr, true);
   ArraySetAsSeries(close, true);

   if(CopyBuffer(bandsHandle, 0, 0, 2, middle) < 2 ||
      CopyBuffer(bandsHandle, 1, 0, 2, upper)  < 2 ||
      CopyBuffer(bandsHandle, 2, 0, 2, lower)  < 2 ||
      CopyBuffer(atrHandle,   0, 0, 1, atr)    < 1 ||
      CopyClose(_Symbol, _Period, 0, 2, close) < 2)
     {
      Print("Failed to copy indicator or price data.");
      return;
     }

   if(atr[0] <= 0 || middle[1] <= 0)
      return;

   if(!IsSpreadAcceptable())
      return;

//--- Signal: price closed outside a band, so the mean sits away from price
   int direction = 0;
   if(close[1] < lower[1])
      direction = 1;
   else
      if(close[1] > upper[1])
         direction = -1;

   if(direction == 0)
      return;

//--- The mean is the target
   OpenMeanReversionTrade(direction, middle[1], atr[0]);
  }

//+------------------------------------------------------------------+
//| Check if current spread is acceptable                            |
//+------------------------------------------------------------------+
bool IsSpreadAcceptable()
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return false;

   double spreadPoints = (tick.ask - tick.bid) / _Point;
   if(spreadPoints > MaxSpreadPips * 10.0)
     {
      PrintFormat("Spread too high: %.1f points (Maximum %.1f pips)", spreadPoints, MaxSpreadPips);
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Round a volume DOWN to the broker's volume step                  |
//+------------------------------------------------------------------+
double FloorToVolumeStep(double volume, double lotStep)
  {
   if(lotStep <= 0)
      return volume;

   double steps  = NormalizeDouble(volume / lotStep, 8);
   double result = MathFloor(steps) * lotStep;

   int stepDigits = (int)MathMax(0, MathCeil(-MathLog10(lotStep)));
   return NormalizeDouble(result, stepDigits);
  }

//+------------------------------------------------------------------+
//| Monetary value of a price distance, for one lot                  |
//+------------------------------------------------------------------+
double ValuePerLot(double priceDistance)
  {
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   if(tickSize <= 0 || tickValue <= 0 || priceDistance <= 0)
      return 0.0;

   return (priceDistance / tickSize) * tickValue;
  }

//+------------------------------------------------------------------+
//| Aggregate every leg this EA holds into one view.                 |
//+------------------------------------------------------------------+
bool GetBasketView(SDemoBasket &basket)
  {
   ZeroMemory(basket);

   double weightedSum   = 0.0;
   double signedVolume  = 0.0;
   double lowestEntry   = 0.0;
   double highestEntry  = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue;

      double volume    = PositionGetDouble(POSITION_VOLUME);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double stopPrice = PositionGetDouble(POSITION_SL);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      basket.positionCount++;
      basket.totalVolume += volume;

      //--- Swap is part of what the basket has cost, so it belongs here
      basket.floatingPL += PositionGetDouble(POSITION_PROFIT)
                           + PositionGetDouble(POSITION_SWAP);

      weightedSum  += openPrice * volume;
      signedVolume += (posType == POSITION_TYPE_BUY) ? volume : -volume;

      //--- What this leg's own stop would cost if it were hit
      if(stopPrice > 0)
         basket.impliedRisk += ValuePerLot(MathAbs(openPrice - stopPrice)) * volume;

      if(lowestEntry == 0.0 || openPrice < lowestEntry)
         lowestEntry = openPrice;
      if(openPrice > highestEntry)
         highestEntry = openPrice;
     }

   if(basket.positionCount == 0)
      return false;

   if(basket.totalVolume > 0)
      basket.weightedEntry = weightedSum / basket.totalVolume;

   if(signedVolume > 0)
      basket.direction = 1;
   else
      if(signedVolume < 0)
         basket.direction = -1;

   basket.extremeEntry = (basket.direction == 1) ? lowestEntry : highestEntry;

   return true;
  }

//+------------------------------------------------------------------+
//| Close every position this EA holds                               |
//+------------------------------------------------------------------+
void CloseBasket(string reason)
  {
   PrintFormat("BASKET CLOSE | %s", reason);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue;

      if(!trade.PositionClose(ticket))
         PrintFormat("Failed to close position #%I64u. Retcode: %u (%s)",
                     ticket, trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Exit the whole basket at its volume-weighted average entry.      |
//+------------------------------------------------------------------+
bool ManageBasketExit(const SDemoBasket &basket)
  {
   if(!UseBasketExit || basket.positionCount < 2 || basket.direction == 0)
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return false;

   double offset = BasketExitOffsetPips * _Point * 10.0;
   double target = (basket.direction == 1)
                   ? basket.weightedEntry + offset
                   : basket.weightedEntry - offset;

   bool reached = (basket.direction == 1) ? (tick.bid >= target) : (tick.ask <= target);
   if(!reached)
      return false;

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   CloseBasket(StringFormat("Weighted average entry %.*f reached with offset (exit %.*f) across %d legs. Floating: %.2f",
                            digits, basket.weightedEntry, digits, target,
                            basket.positionCount, basket.floatingPL));
   return true;
  }

//+------------------------------------------------------------------+
//| Basket-level protection, evaluated once per bar.                 |
//+------------------------------------------------------------------+
void ManageBasketRisk()
  {
   SDemoBasket basket;
   if(!GetBasketView(basket))
      return;

//--- Aggregate loss cut, before anything else
   if(MaxBasketLossPercent > 0)
     {
      double maxLoss = AccountInfoDouble(ACCOUNT_BALANCE) * (MaxBasketLossPercent / 100.0);

      if(basket.floatingPL <= -maxLoss)
        {
         CloseBasket(StringFormat("Aggregate loss %.2f breached the %.1f%% limit (%.2f) across %d leg(s).",
                                  basket.floatingPL, MaxBasketLossPercent, maxLoss, basket.positionCount));
         return;
        }
     }

//--- Shared exit for an averaged basket
   ManageBasketExit(basket);
  }

//+------------------------------------------------------------------+
//| Should this signal be allowed to add a leg to the basket?        |
//+------------------------------------------------------------------+
bool IsAddAllowed(int direction, double entryPrice, double atrValue, const SDemoBasket &basket)
  {
   if(basket.positionCount == 0)
      return true;

//--- An opposing signal is refused rather than hedged
   if(basket.direction != 0 && basket.direction != direction)
     {
      PrintFormat("Opposing signal while %d %s leg(s) are open. Signal skipped.",
                  basket.positionCount, (basket.direction == 1) ? "long" : "short");
      return false;
     }

   if(basket.positionCount >= MaxOpenPositions)
     {
      PrintFormat("Basket full: %d of %d legs already open. Signal skipped.",
                  basket.positionCount, MaxOpenPositions);
      return false;
     }

//--- Spacing. Price closes outside a Bollinger band for several bars in a row
   double spacing = atrValue * MinAddSpacingATR;
   if(spacing > 0 && basket.extremeEntry > 0)
     {
      double advance = (direction == 1)
                       ? (basket.extremeEntry - entryPrice)
                       : (entryPrice - basket.extremeEntry);

      if(advance < spacing)
        {
         PrintFormat("Add rejected: price is %.1f points beyond the last entry, %.1f required.",
                     advance / _Point, spacing / _Point);
         return false;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Size from the distance to the mean, then open the trade.         |
//+------------------------------------------------------------------+
void OpenMeanReversionTrade(int direction, double meanPrice, double atrValue)
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double entryPrice = (direction == 1) ? tick.ask : tick.bid;

//--- The basket this trade would join decides whether it may exist, and how large
   SDemoBasket basket;
   GetBasketView(basket);

   if(!IsAddAllowed(direction, entryPrice, atrValue, basket))
      return;

//--- Expected move: how far price must travel to reach the mean.
   double expectedMove = MathAbs(meanPrice - entryPrice);

//--- The target has to clear the broker's minimum distance as well
   double brokerMinimum = ((double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point)
                          + (tick.ask - tick.bid);
   double minTargetDistance = MathMax(MinExpectedMovePoints * _Point, brokerMinimum);

   if(expectedMove < minTargetDistance)
     {
      PrintFormat("Mean is %.1f points away, %.1f required (strategy minimum %d, broker minimum %.1f). Signal skipped.",
                  expectedMove / _Point, minTargetDistance / _Point,
                  MinExpectedMovePoints, brokerMinimum / _Point);
      return;
     }

//--- The target is a price, not a ratio of the stop
   double targetPrice = NormalizeDouble(meanPrice, digits);

//--- Structural stop. It protects against the mean never being reached and doesn't define position size
   double stopDistance = atrValue * StopATRMultiplier;
   if(stopDistance < brokerMinimum)
      stopDistance = brokerMinimum;

   double stopLoss = (direction == 1)
                     ? NormalizeDouble(entryPrice - stopDistance, digits)
                     : NormalizeDouble(entryPrice + stopDistance, digits);

//--- Target-profit sizing
   double sizeBaseValue = (SizeBase == SIZE_BASE_EQUITY)
                          ? AccountInfoDouble(ACCOUNT_EQUITY)
                          : AccountInfoDouble(ACCOUNT_BALANCE);
   double targetProfit  = sizeBaseValue * (TargetProfitPercent / 100.0);

   double profitPerLot = ValuePerLot(expectedMove);
   if(profitPerLot <= 0)
     {
      Print("Cannot value the expected move. Trade skipped.");
      return;
     }

   double rawLot = targetProfit / profitPerLot;

   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(minLot <= 0 || lotStep <= 0)
      return;

   if(MaxLotCap > 0 && rawLot > MaxLotCap)
     {
      PrintFormat("Target-profit volume %.2f capped at %.2f.", rawLot, MaxLotCap);
      rawLot = MaxLotCap;
     }

   double lotSize = FloorToVolumeStep(MathMin(rawLot, maxLot), lotStep);

//--- The risk this position implies is an output of the model
   double riskPerLot = ValuePerLot(stopDistance);
   if(riskPerLot > 0 && MaxImpliedRiskPercent > 0)
     {
      double maxRiskAmount = sizeBaseValue * (MaxImpliedRiskPercent / 100.0);
      double affordableLot = FloorToVolumeStep(maxRiskAmount / riskPerLot, lotStep);

      if(lotSize > affordableLot)
        {
         PrintFormat("Implied risk cap: target-profit volume %.2f would risk %.2f (%.2f%% of account). Reducing to %.2f.",
                     lotSize, lotSize * riskPerLot,
                     (lotSize * riskPerLot) / sizeBaseValue * 100.0, affordableLot);
         lotSize = affordableLot;
        }
     }

   if(riskPerLot > 0 && MaxBasketImpliedRiskPercent > 0)
     {
      double basketCeiling = sizeBaseValue * (MaxBasketImpliedRiskPercent / 100.0);
      double headroom      = basketCeiling - basket.impliedRisk;

      if(headroom <= 0)
        {
         PrintFormat("Basket implied risk %.2f is already at the %.1f%% ceiling (%.2f). Trade skipped.",
                     basket.impliedRisk, MaxBasketImpliedRiskPercent, basketCeiling);
         return;
        }

      double affordableLot = FloorToVolumeStep(headroom / riskPerLot, lotStep);
      if(lotSize > affordableLot)
        {
         PrintFormat("Basket implied risk cap: %.2f already committed of %.2f allowed. Reducing %.2f to %.2f.",
                     basket.impliedRisk, basketCeiling, lotSize, affordableLot);
         lotSize = affordableLot;
        }
     }

   if(lotSize < minLot)
     {
      PrintFormat("Computed volume %.4f is below the minimum lot %.2f. Trade skipped.", lotSize, minLot);
      return;
     }

//--- Two lines rather than one very long one
   PrintFormat("%s leg %d/%d | Lot: %.2f | Entry: %.*f | Mean target: %.*f | Stop: %.*f",
               (direction == 1) ? "BUY" : "SELL",
               basket.positionCount + 1, MaxOpenPositions, lotSize,
               digits, entryPrice, digits, targetPrice, digits, stopLoss);

   PrintFormat("   Expected move: %.1f pts | Stop: %.1f pts | Target profit: %.2f | Implied risk: %.2f | Basket implied risk after this leg: %.2f",
               expectedMove / _Point, stopDistance / _Point,
               lotSize * profitPerLot, lotSize * riskPerLot,
               basket.impliedRisk + (lotSize * riskPerLot));

   bool sent = (direction == 1)
               ? trade.Buy(lotSize, _Symbol, 0.0, stopLoss, targetPrice, "MeanRev Buy")
               : trade.Sell(lotSize, _Symbol, 0.0, stopLoss, targetPrice, "MeanRev Sell");

   if(!sent)
      PrintFormat("Order failed. Retcode: %u (%s)",
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------+
