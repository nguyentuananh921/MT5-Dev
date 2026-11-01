//+------------------------------------------------------------------+
//|                                    MeanReversionSizing_Part7.mq5 |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//+------------------------------------------------------------------+
//|Building Your Personal Expert Advisor                             |
//|1. From Fragile Script to Working EA                              |
//|                           https://www.mql5.com/en/articles/23429 |
//|2. Risk Management and Dynamic Lot Sizing                         |
//|                           https://www.mql5.com/en/articles/23638 |
//|3. Margin and Allowable Risk                                      |
//|                           https://www.mql5.com/en/articles/23897 |
//|4. Risk Models and Order Execution                                |
//|                           https://www.mql5.com/en/articles/21231 |
//|5. Basket Risk and Strategy-Specific Sizing                       |
//|                           https://www.mql5.com/en/articles/24331 |
//|6. Portfolio and Correlated Risk                                  |
//|                           https://www.mql5.com/en/articles/24392 |
//|7. Consolidating the Risk Framework                               |
//|                           https://www.mql5.com/en/articles/24477 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, soloharbinger"
#property link        "https://www.mql5.com/en/users/soloharbinger"
#property description "The mean-reversion demo, rebuilt on the risk framework. It trades a completely different idea from the series EA - reversion to a mean - and it sizes positions from a profit target instead of a risk budget."
#property version     "2.00"

#include <Trade/Trade.mqh>
#include <Risk Management/RiskTypes.mqh>
#include <Risk Management/BasketRisk.mqh>

//--- Input Parameters
input group "Mean Reversion Signal"
input int              BandsPeriod = 20;                  // Bollinger period (defines the mean)
input double           BandsDeviation = 2.0;              // Bollinger deviation
input int              MinExpectedMovePoints = 50;        // Skip signals with less room than this to the mean

input group "Target-Profit Sizing"
input double           TargetProfitPercent = 0.5;         // Profit target per leg [% of account]
input ENUM_RISK_BASE   SizeBase = RISK_BASE_BALANCE;      // Target measured against
input double           MaxLotCap = 5.0;                   // Absolute ceiling on volume [0 = off]

input group "Structural Stop (not the sizing input)"
input int              ATRPeriod = 14;                    // ATR period
input double           StopATRMultiplier = 3.0;           // Stop distance as ATR multiple
input double           MaxImpliedRiskPercent = 2.0;       // Cap the risk one leg's stop implies [0 = off]

input group "Basket: Averaging"
input int              MaxOpenPositions = 3;              // Max legs in one basket
input double           MinAddSpacingATR = 1.0;            // An add needs this many ATR beyond the basket's average entry [0 = off]

input group "Basket: Protection"
input double           MaxBasketLossPercent = 4.0;        // Close all if the basket loses this % [0 = off]
input double           MaxBasketMarginPercent = 30.0;     // Max % of equity the basket may tie up [0 = off]
input int              MaxBasketHoldBars = 0;             // Close a losing basket after N bars [0 = off]
input double           MaxSpreadPips = 2.0;               // Maximum allowed spread

input group "General"
input int              MagicNumber = 55221;               // EA Magic Number

//--- Basket protection comes straight from the framework, unchanged
CBasketRisk basket;
CTrade      trade;

int bandsHandle = INVALID_HANDLE;
int atrHandle   = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(MagicNumber);

//--- Buffer 0 is the middle line - the mean this EA trades toward
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

   if(MinAddSpacingATR < 0)
     {
      Print("Averaging spacing cannot be negative.");
      return INIT_PARAMETERS_INCORRECT;
     }

//--- The basket tier is configured the way the series EA configures it
   SBasketConfig basketCfg;
   basketCfg.SetDefaults();
   basketCfg.magic            = MagicNumber;
   basketCfg.enabled          = true;
   basketCfg.maxPositions     = MaxOpenPositions;
   basketCfg.maxLossPercent   = MaxBasketLossPercent;
   basketCfg.lossBase         = RISK_BASE_BALANCE;
   basketCfg.maxMarginPercent = MaxBasketMarginPercent;
   basketCfg.trackExcursion   = true;
   basketCfg.maxHoldBars      = MaxBasketHoldBars;

   if(!basket.Init(basketCfg))
      return INIT_PARAMETERS_INCORRECT;

//--- What a basket even is depends on the account type
   long marginMode = AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(marginMode == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      PrintFormat("Hedging account: this EA may hold up to %d separate legs.", MaxOpenPositions);
   else
      Print("Netting account: adds merge into one position, so the basket is a single netted leg.");

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
//| Is the current spread acceptable?                                |
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
//| May this signal add a leg to the legs already open?              |
//+------------------------------------------------------------------+
bool HasRoomToAdd(const int direction, const double entryPrice, const double atrValue)
  {
   SBasketState state;
   if(!basket.GetState(state) || state.positionCount == 0)
      return true;

//--- A signal against the open legs is refused, not hedged
   if(state.netDirection != 0 && state.netDirection != direction)
     {
      PrintFormat("Opposing signal while %d leg(s) are open. Signal skipped.", state.positionCount);
      return false;
     }

//--- Spacing, measured from the basket's average entry
   if(MinAddSpacingATR <= 0)
      return true;

   double required = atrValue * MinAddSpacingATR;
   double distance = (direction == 1)
                     ? state.weightedEntryPrice - entryPrice
                     : entryPrice - state.weightedEntryPrice;

   if(distance < required)
     {
      PrintFormat("Add is only %.1f points beyond the basket average, %.1f required. Skipped.",
                  distance / _Point, required / _Point);
      return false;
     }

   return true;
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

//--- Basket protection first, independent of any signal
   basket.Manage();

   if(BarsCalculated(bandsHandle) < 2 || BarsCalculated(atrHandle) < 1)
      return;

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

//--- Price closed outside a band, so the mean sits away from price
   int direction = 0;
   if(close[1] < lower[1])
      direction = 1;
   else
      if(close[1] > upper[1])
         direction = -1;

   if(direction == 0)
      return;

   OpenMeanReversionTrade(direction, middle[1], atr[0]);
  }

//+------------------------------------------------------------------+
//| Size from the distance to the mean, then open the trade.         |
//|   series EA:  risk budget   -> stop distance  -> volume          |
//|   this EA:    profit target -> expected move  -> volume          |
//+------------------------------------------------------------------+
void OpenMeanReversionTrade(const int direction, const double meanPrice, const double atrValue)
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double entryPrice = (direction == 1) ? tick.ask : tick.bid;

//--- Expected move: how far price must travel to reach the mean.
   double expectedMove = MathAbs(meanPrice - entryPrice);

//--- The target has to clear the broker's minimum distance as well
   double minStop       = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point)
                          + (tick.ask - tick.bid);
   double minTargetMove = MathMax(MinExpectedMovePoints * _Point, minStop);

   if(expectedMove < minTargetMove)
     {
      PrintFormat("Mean is only %.1f points away (minimum %.1f). Signal skipped.",
                  expectedMove / _Point, minTargetMove / _Point);
      return;
     }

   if(!HasRoomToAdd(direction, entryPrice, atrValue))
      return;

   double targetPrice = NormalizeDouble(meanPrice, digits);

//--- Structural stop. It guards against the mean never being reached.
   double stopDistance = atrValue * StopATRMultiplier;
   if(stopDistance < minStop)
      stopDistance = minStop;

   double stopLoss = (direction == 1)
                     ? NormalizeDouble(entryPrice - stopDistance, digits)
                     : NormalizeDouble(entryPrice + stopDistance, digits);

//--- Target-profit sizing, using the framework's shared conversion
   double sizeBaseValue = AccountValueByBase(SizeBase);
   double targetProfit  = sizeBaseValue * (TargetProfitPercent / 100.0);

   double lotSize = VolumeForMoneyAndDistance(_Symbol, targetProfit, expectedMove, false);
   if(lotSize <= 0)
      return;

   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(MaxLotCap > 0 && lotSize > MaxLotCap)
     {
      PrintFormat("Target-profit volume %.2f capped at %.2f.", lotSize, MaxLotCap);
      lotSize = FloorToVolumeStep(MaxLotCap, lotStep);
     }

//--- The risk this position implies is an output of the model.
   double riskPerLot = ValuePerLot(_Symbol, stopDistance);
   if(riskPerLot > 0 && MaxImpliedRiskPercent > 0)
     {
      double maxRiskAmount = sizeBaseValue * (MaxImpliedRiskPercent / 100.0);
      double affordable    = FloorToVolumeStep(maxRiskAmount / riskPerLot, lotStep);

      if(lotSize > affordable)
        {
         PrintFormat("Implied risk cap: volume %.2f would risk %.2f (%.2f%% of account). Reducing to %.2f.",
                     lotSize, lotSize * riskPerLot,
                     (lotSize * riskPerLot) / sizeBaseValue * 100.0, affordable);
         lotSize = affordable;
        }
     }

   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(lotSize < minLot)
     {
      PrintFormat("Computed volume %.4f is below the minimum lot %.2f. Trade skipped.", lotSize, minLot);
      return;
     }

//--- Basket tier decides whether this leg can join the others
   STradePlan plan;
   ZeroMemory(plan);
   plan.direction  = direction;
   plan.orderType  = (direction == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   plan.entryPrice = entryPrice;
   plan.lotSize    = lotSize;

   if(!basket.AcceptsNewTrade(plan))
      return;

   PrintFormat("%s | Lot: %.2f | Entry: %.*f | Mean target: %.*f (%.1f pts) | Stop: %.*f (%.1f pts) | Target profit: %.2f | Implied risk: %.2f",
               (direction == 1) ? "BUY" : "SELL", lotSize,
               digits, entryPrice, digits, targetPrice, expectedMove / _Point,
               digits, stopLoss, stopDistance / _Point,
               lotSize * ValuePerLot(_Symbol, expectedMove), lotSize * riskPerLot);

   bool sent = (direction == 1)
               ? trade.Buy(lotSize, _Symbol, 0.0, stopLoss, targetPrice, "MeanRev Buy")
               : trade.Sell(lotSize, _Symbol, 0.0, stopLoss, targetPrice, "MeanRev Sell");

   if(!sent)
      PrintFormat("Order failed. Retcode: %u (%s)",
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------+
