//+------------------------------------------------------------------+
//|                                       FixedMACrossover_Part7.mq5 |
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
#property description "The same EA as Part 6, with every risk control moved into the shared framework headers file. Install: copy the shared folder into MQL5/Include/ before compiling"
#property version     "1.00"

#include <SoloEA/TradeRisk.mqh>
#include <SoloEA/BasketRisk.mqh>
#include <SoloEA/PortfolioRisk.mqh>

//--- Input Parameters
input group "Trading Signal"
input int                  FastMA = 10;                      // Fast MA period
input int                  SlowMA = 20;                      // Slow MA period
input int                  ATRPeriod = 14;                   // ATR period for volatility
input double               MaxSpreadPips = 2.0;              // Maximum allowed spread

input group "Risk Model"
input ENUM_RISK_MODE       RiskMode = RISK_PERCENT;          // How risk per trade is defined
input ENUM_RISK_BASE       RiskBase = RISK_BASE_BALANCE;     // Risk percentage measured against
input double               RiskPercent = 1.0;                // Risk per trade [%] (percent mode)
input double               FixedCashRisk = 100.0;            // Risk per trade [account currency] (cash mode)
input double               FixedLotSize = 0.10;              // Lot size (fixed-lot mode)
input bool                 AllowMinLotOverRisk = true;       // Trade min lot even if it exceeds intended risk

input group "Stops and Targets"
input double               ATRMultiplier = 1.5;              // ATR multiplier for stop distance
input double               TPRatio = 2.0;                    // Take profit ratio
input bool                 AllowHedging = false;             // Allow opposing position

input group "Order Execution"
input ENUM_ENTRY_MODE      EntryMode = ENTRY_MARKET;         // Order type used to enter
input ENUM_OFFSET_MODE     PendingOffsetMode = OFFSET_ATR;   // How the pending offset is measured
input double               PendingOffsetATR = 0.5;           // Pending offset as ATR multiple
input int                  PendingOffsetPoints = 150;        // Pending offset in points
input int                  PendingExpiryBars = 10;           // Delete untriggered pending after N bars [0 = never]

input group "Adaptive Risk (Drawdown)"
input bool                 EnableAdaptiveRisk = false;       // Reduce risk during drawdowns
input double               DDLevel = 3.0;                    // Drawdown % that triggers reduced risk
input double               RiskReductionFactor = 0.5;        // Risk multiplier when triggered
input bool                 ApplyDrawdownToFixedLot = false;  // Also shrink the fixed lot

input group "Broker & Margin Safety"
input double               MaxMarginUsagePercent = 50.0;     // Max % of free margin one trade may use
input bool                 EnableAdaptiveMarginCap = false;  // Scale the cap with account margin level
input double               MarginLevelSafe = 500.0;          // Margin level [%] where the full cap applies
input double               MarginLevelDanger = 150.0;        // Margin level [%] where trades are blocked

input group "Basket Risk"
input bool                 EnableBasketRisk = true;          // Limit risk across this EA's positions
input int                  MaxBasketPositions = 1;           // Max concurrent positions [1 = no stacking]
input double               MaxBasketLossPercent = 3.0;       // Close the basket at this loss % [0 = off]
input ENUM_RISK_BASE       BasketLossBase = RISK_BASE_BALANCE; // Basket cut measured against
input double               MaxBasketMarginPercent = 25.0;    // Max % of equity the basket may tie up [0 = off]
input bool                 EnableMAETracking = true;         // Track adverse excursion
input int                  MaxBasketHoldBars = 0;            // Close a losing basket after N bars [0 = off]

input group "Portfolio Risk (account-wide)"
input bool                 EnablePortfolioRisk = true;       // Check account-wide limits before trading
input ENUM_PORTFOLIO_SCOPE PortfolioScope = PORTFOLIO_ACCOUNT_WIDE; // What counts as the portfolio
input string               ExtraPortfolioMagics = "";        // Extra magic numbers, comma-separated
input int                  MaxPortfolioPositions = 6;        // Max positions portfolio-wide [0 = off]
input int                  MaxPositionsPerSymbol = 2;        // Max positions on one symbol [0 = off]
input int                  MaxPortfolioSymbols = 4;          // Max distinct symbols at once [0 = off]
input double               MaxPortfolioMarginPercent = 40.0; // Max % of equity in margin [0 = off]
input double               MaxPortfolioLossPercent = 6.0;    // Block new trades past this loss % [0 = off]
input double               MaxNetCurrencyLots = 2.0;         // Max net lots per currency [0 = off]
input bool                 LogPortfolioSnapshot = false;     // Log the portfolio picture every bar

input group "General"
input int                  MagicNumber = 12345;              // EA Magic Number

//--- The three tiers of risk: the trade, the basket, the account
CTradeRisk      risk;
CBasketRisk     basket;
CPortfolioRisk  portfolio;

//--- Strategy state
int fastHandle = INVALID_HANDLE;
int slowHandle = INVALID_HANDLE;
int atrHandle  = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Strategy inputs are checked here
   if(FastMA <= 0 || SlowMA <= 0)
     {
      Print("Moving Average periods must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(FastMA >= SlowMA)
     {
      Print("FastMA should be smaller than SlowMA.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(ATRPeriod <= 0)
     {
      Print("ATR period must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   fastHandle = iMA(_Symbol, _Period, FastMA, 0, MODE_SMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, _Period, SlowMA, 0, MODE_SMA, PRICE_CLOSE);
   atrHandle  = iATR(_Symbol, _Period, ATRPeriod);

   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create indicator handles.");
      return INIT_FAILED;
     }

//--- Tier one: the trade.
   SRiskConfig riskCfg;
   riskCfg.SetDefaults();
   riskCfg.magic                   = MagicNumber;
   riskCfg.riskMode                = RiskMode;
   riskCfg.riskBase                = RiskBase;
   riskCfg.riskPercent             = RiskPercent;
   riskCfg.fixedCashRisk           = FixedCashRisk;
   riskCfg.fixedLotSize            = FixedLotSize;
   riskCfg.allowMinLotOverRisk     = AllowMinLotOverRisk;
   riskCfg.enableDrawdownScaling   = EnableAdaptiveRisk;
   riskCfg.drawdownTrigger         = DDLevel;
   riskCfg.drawdownFactor          = RiskReductionFactor;
   riskCfg.applyDrawdownToFixedLot = ApplyDrawdownToFixedLot;
   riskCfg.stopATRMultiplier       = ATRMultiplier;
   riskCfg.tpRatio                 = TPRatio;
   riskCfg.entryMode               = EntryMode;
   riskCfg.offsetMode              = PendingOffsetMode;
   riskCfg.pendingOffsetATR        = PendingOffsetATR;
   riskCfg.pendingOffsetPoints     = PendingOffsetPoints;
   riskCfg.pendingExpiryBars       = PendingExpiryBars;
   riskCfg.maxMarginUsagePercent   = MaxMarginUsagePercent;
   riskCfg.enableAdaptiveMarginCap = EnableAdaptiveMarginCap;
   riskCfg.marginLevelSafe         = MarginLevelSafe;
   riskCfg.marginLevelDanger       = MarginLevelDanger;
   riskCfg.allowHedging            = AllowHedging;

   if(!risk.Init(riskCfg))
      return INIT_PARAMETERS_INCORRECT;

//--- Tier two: the basket
   SBasketConfig basketCfg;
   basketCfg.SetDefaults();
   basketCfg.magic            = MagicNumber;
   basketCfg.enabled          = EnableBasketRisk;
   basketCfg.maxPositions     = MaxBasketPositions;
   basketCfg.maxLossPercent   = MaxBasketLossPercent;
   basketCfg.lossBase         = BasketLossBase;
   basketCfg.maxMarginPercent = MaxBasketMarginPercent;
   basketCfg.trackExcursion   = EnableMAETracking;
   basketCfg.maxHoldBars      = MaxBasketHoldBars;

   if(!basket.Init(basketCfg))
      return INIT_PARAMETERS_INCORRECT;

//--- Not an error, but the two settings contradict each other
   if(EnableBasketRisk && AllowHedging && MaxBasketPositions < 2)
      Print("Note: AllowHedging is on but MaxBasketPositions is 1, so an opposing position can never be opened.");

//--- Tier three: the account
   if(EnablePortfolioRisk)
     {
      portfolio.SetScope(PortfolioScope);
      portfolio.RegisterMagic(MagicNumber);
      RegisterExtraMagics();

      portfolio.SetPositionLimits(MaxPortfolioPositions, MaxPositionsPerSymbol, MaxPortfolioSymbols);
      portfolio.SetMarginLimit(MaxPortfolioMarginPercent);
      portfolio.SetLossLimit(MaxPortfolioLossPercent);
      portfolio.SetCurrencyLimit(MaxNetCurrencyLots);

      if(PortfolioScope == PORTFOLIO_MAGIC_FILTERED && ExtraPortfolioMagics == "")
         Print("Note: portfolio scope is magic-filtered but no extra magic numbers were listed, so only this EA is counted.");
     }

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Register the other EAs sharing this account's risk budget        |
//+------------------------------------------------------------------+
void RegisterExtraMagics()
  {
   if(ExtraPortfolioMagics == "")
      return;

   string parts[];
   int count = StringSplit(ExtraPortfolioMagics, StringGetCharacter(",", 0), parts);

   for(int i = 0; i < count; i++)
     {
      string trimmed = parts[i];
      StringTrimLeft(trimmed);
      StringTrimRight(trimmed);

      if(trimmed == "")
         continue;

      long magic = StringToInteger(trimmed);
      if(magic <= 0)
        {
         PrintFormat("Ignoring invalid magic number '%s' in ExtraPortfolioMagics.", trimmed);
         continue;
        }

      portfolio.RegisterMagic(magic);
      PrintFormat("Portfolio now also tracks magic %I64d.", magic);
     }
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
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
//| Read the crossover on the latest closed bar.                     |
//| Returns 1 for a buy signal, -1 for a sell, 0 for nothing.        |
//+------------------------------------------------------------------+
int ReadSignal(double &atrValue)
  {
   atrValue = 0.0;

   if(BarsCalculated(fastHandle) < 3 ||
      BarsCalculated(slowHandle) < 3 ||
      BarsCalculated(atrHandle) < 1)
     {
      Print("Indicators are not ready yet.");
      return 0;
     }

   double fast[], slow[], atr[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   ArraySetAsSeries(atr, true);

   if(CopyBuffer(fastHandle, 0, 0, 3, fast) < 3 ||
      CopyBuffer(slowHandle, 0, 0, 3, slow) < 3 ||
      CopyBuffer(atrHandle,  0, 0, 1, atr)  < 1)
     {
      Print("Failed to copy indicator data.");
      return 0;
     }

   if(atr[0] <= 0)
     {
      Print("Invalid ATR value: ", atr[0]);
      return 0;
     }

   atrValue = atr[0];

   if(fast[1] > slow[1] && fast[2] <= slow[2])
      return 1;

   if(fast[1] < slow[1] && fast[2] >= slow[2])
      return -1;

   return 0;
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- One decision per bar
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime == 0)
      return;

   static datetime lastProcessedBarTime = 0;
   if(currentBarTime == lastProcessedBarTime)
      return;
   lastProcessedBarTime = currentBarTime;

//--- Housekeeping runs every bar, before and regardless of any signal.
   risk.ManagePendingOrders();
   basket.Manage();

   if(EnablePortfolioRisk && LogPortfolioSnapshot)
      portfolio.PrintSnapshot();

   if(!IsSpreadAcceptable())
      return;

//--- The strategy: the only part of this file that is about trading
   double atrValue = 0.0;
   int direction = ReadSignal(atrValue);
   if(direction == 0)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

//--- Plan the trade, then pass it through all three scopes of risk in widening order.
   STradePlan plan;
   if(!risk.BuildPlan(direction, atrValue, tick, plan))
      return;

   if(!risk.ValidatePlan(plan, tick))
      return;

   if(!basket.AcceptsNewTrade(plan, risk.CountPendingOrders()))
      return;

   if(EnablePortfolioRisk)
     {
      string blockReason = "";
      if(!portfolio.CanOpenPosition(_Symbol, MarketOrderTypeOf(plan.orderType),
                                    plan.lotSize, plan.entryPrice, blockReason))
        {
         PrintFormat("Portfolio limit: %s. Trade skipped.", blockReason);
         return;
        }
     }

   risk.ExecutePlan(plan);
  }
//+------------------------------------------------------------------+
