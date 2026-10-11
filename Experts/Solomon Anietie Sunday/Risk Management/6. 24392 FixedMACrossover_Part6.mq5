//+------------------------------------------------------------------+
//|                                       FixedMACrossover_Part6.mq5 |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//|Risk Management                                                   |
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
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, soloharbinger"
#property link      "https://www.mql5.com/en/users/soloharbinger"
#property version   "1.00"
#include <Trade/Trade.mqh>
#include <PortfolioRisk.mqh>

//+------------------------------------------------------------------+
//| Risk model and execution enumerations                            |
//+------------------------------------------------------------------+
enum ENUM_RISK_MODE
  {
   RISK_PERCENT,        // Percentage of account
   RISK_FIXED_CASH,     // Fixed cash amount
   RISK_FIXED_LOT       // Fixed lot size
  };

enum ENUM_RISK_BASE
  {
   RISK_BASE_BALANCE,   // Account balance
   RISK_BASE_EQUITY     // Account equity
  };

enum ENUM_ENTRY_MODE
  {
   ENTRY_MARKET,        // Market order (immediate)
   ENTRY_LIMIT,         // Pending limit (pullback entry)
   ENTRY_STOP           // Pending stop (breakout entry)
  };

enum ENUM_OFFSET_MODE
  {
   OFFSET_ATR,          // ATR-based offset
   OFFSET_POINTS        // Fixed points offset
  };

//--- Input Parameters
input group "Trading Signal"
input int              FastMA = 10;                      // Fast MA period
input int              SlowMA = 20;                      // Slow MA period

input group "Risk Model"
input ENUM_RISK_MODE   RiskMode = RISK_PERCENT;          // How risk per trade is defined
input ENUM_RISK_BASE   RiskBase = RISK_BASE_BALANCE;     // Risk percentage measured against
input double           RiskPercent = 1.0;                // Risk per trade [%] (percent mode)
input double           FixedCashRisk = 100.0;            // Risk per trade [account currency] (cash mode)
input double           FixedLotSize = 0.10;              // Lot size (fixed-lot mode)
input bool             AllowMinLotOverRisk = true;       // Trade min lot even if it exceeds intended risk

input group "Trade Settings"
input bool             AllowHedging = false;             // Allow opposing position (hedging)
input int              ATRPeriod = 14;                   // ATR Period for Volatility Calculation
input double           ATRMultiplier = 1.5;              // ATR Multiplier for Stop-Loss Distance
input double           TPRatio = 2.0;                    // Take Profit Ratio
input double           MaxSpreadPips = 2.0;              // Maximum allowed spread

input group "Order Execution"
input ENUM_ENTRY_MODE  EntryMode = ENTRY_MARKET;         // Order type used to enter
input ENUM_OFFSET_MODE PendingOffsetMode = OFFSET_ATR;   // How the pending entry offset is measured
input double           PendingOffsetATR = 0.5;           // Pending offset as ATR multiple (ATR mode)
input int              PendingOffsetPoints = 150;        // Pending offset in points (points mode)
input int              PendingExpiryBars = 10;           // Delete untriggered pending after N bars [0 = never]

input group "Adaptive Risk (Drawdown)"
input bool             EnableAdaptiveRisk  = false;      // Reduce risk during drawdowns
input double           DDLevel             = 3.0;        // Drawdown % that triggers reduced risk
input double           RiskReductionFactor = 0.5;        // Adaptive risk multiplier when triggered [0.5 = half risk]
input bool             ApplyDrawdownToFixedLot = false;  // Also shrink the fixed lot during drawdowns

input group "Broker & Margin Safety"
input double           MaxMarginUsagePercent   = 50.0;   // Max % of free margin one new trade may use
input bool             EnableAdaptiveMarginCap = false;  // Scale the margin cap with account-wide margin level
input double           MarginLevelSafe         = 500.0;  // Margin safe level [%] full cap applies
input double           MarginLevelDanger       = 150.0;  // Margin caution level [%] new trades are blocked

input group "Basket Risk"
input bool             EnableBasketRisk = true;          // Measure and limit risk across all open positions
input int              MaxBasketPositions = 1;           // Max concurrent positions for this EA [1 = no stacking]
input double           MaxBasketLossPercent = 3.0;       // Close the whole basket if it loses this % [0 = off]
input ENUM_RISK_BASE   BasketLossBase = RISK_BASE_BALANCE; // Basket cut-loss measured against
input double           MaxBasketMarginPercent = 25.0;    // Max % of account equity this basket may tie up [0 = off]
input bool             EnableMAETracking = true;         // Track how far the basket goes against you
input int              MaxBasketHoldBars = 0;            // Close a losing basket after N bars [0 = off]

input group "Portfolio Risk (account-wide)"
input bool                 EnablePortfolioRisk = true;       // Check account-wide limits before trading
input ENUM_PORTFOLIO_SCOPE PortfolioScope = PORTFOLIO_ACCOUNT_WIDE; // What counts as the portfolio
input string               ExtraPortfolioMagics = "";        // Extra magic numbers, comma-separated (filtered scope)
input int                  MaxPortfolioPositions = 6;        // Max positions across the whole portfolio [0 = off]
input int                  MaxPositionsPerSymbol = 2;        // Max positions on any one symbol [0 = off]
input int                  MaxPortfolioSymbols = 4;          // Max distinct symbols traded at once [0 = off]
input double               MaxPortfolioMarginPercent = 40.0; // Max % of equity tied up in margin [0 = off]
input double               MaxPortfolioLossPercent = 6.0;    // Block new trades past this floating loss % [0 = off]
input double               MaxNetCurrencyLots = 2.0;         // Max net lots exposed to one currency [0 = off]
input bool                 LogPortfolioSnapshot = false;     // Log the portfolio picture every bar

input group "General"
input int              MagicNumber = 12345;              // EA Magic Number

//+------------------------------------------------------------------+
//| A fully-specified trade before anything is sent to the broker.   |
//+------------------------------------------------------------------+
struct STradePlan
  {
   int               direction;      // 1 = Buy, -1 = Sell
   ENUM_ORDER_TYPE   orderType;      // Concrete order type being sent
   bool              isPending;      // True for limit/stop entries
   double            entryPrice;     // Intended entry, not necessarily current price
   double            stopLoss;
   double            takeProfit;
   double            stopDistance;   // Derived from entryPrice and stopLoss
   double            lotSize;
   double            riskAmount;     // Intended monetary risk (0 in fixed-lot mode)
  };

//+------------------------------------------------------------------+
//| The state of every position this EA currently holds              |
//+------------------------------------------------------------------+
struct SBasketState
  {
   int               positionCount;
   double            totalVolume;
   double            weightedEntryPrice;  // Volume-weighted average entry
   double            floatingPL;          // Profit + swap + commission
   double            usedMargin;          // Computed, not read - see GetBasketState()
   int               netDirection;        // 1 = net long, -1 = net short, 0 = flat or balanced
   datetime          oldestOpenTime;
  };

//--- Global Variables
CTrade trade;
CPortfolioRisk portfolio;
int fastHandle, slowHandle;
int atrHandle;
double g_PeakEquity = 0.0;

//--- Basket tracking. In-memory only.
double g_BasketMaxAdverse = 0.0;    // Worst floating loss this basket has reached (positive number)
double g_BasketMaxFavour  = 0.0;    // Best floating profit this basket has reached
int    g_BasketPeakCount  = 0;      // Most positions this basket has held at once

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set the Magic Number for all trades
   trade.SetExpertMagicNumber(MagicNumber);

//--- Initialize Handles
   fastHandle = iMA(_Symbol, _Period, FastMA, 0, MODE_SMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, _Period, SlowMA, 0, MODE_SMA, PRICE_CLOSE);
   atrHandle = iATR(_Symbol, _Period, ATRPeriod);

   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      return INIT_FAILED;
     }

//--- Validate signal inputs
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

//--- Validate only the risk input the selected mode actually uses
   if(RiskMode == RISK_PERCENT && RiskPercent <= 0)
     {
      Print("Risk per trade [%] must be greater than zero in percentage mode.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(RiskMode == RISK_FIXED_CASH && FixedCashRisk <= 0)
     {
      Print("Fixed cash risk must be greater than zero in cash mode.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(RiskMode == RISK_FIXED_LOT && FixedLotSize <= 0)
     {
      Print("Fixed lot size must be greater than zero in fixed-lot mode.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(ATRPeriod <= 0 || ATRMultiplier <= 0)
     {
      Print("ATR parameters must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(TPRatio <= 0)
     {
      Print("Take Profit ratio must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

//--- Validate pending-order inputs only when a pending entry is selected
   if(EntryMode != ENTRY_MARKET)
     {
      if(PendingOffsetMode == OFFSET_ATR && PendingOffsetATR <= 0)
        {
         Print("Pending offset (ATR multiple) must be greater than zero.");
         return INIT_PARAMETERS_INCORRECT;
        }

      if(PendingOffsetMode == OFFSET_POINTS && PendingOffsetPoints <= 0)
        {
         Print("Pending offset (points) must be greater than zero.");
         return INIT_PARAMETERS_INCORRECT;
        }

      if(PendingExpiryBars < 0)
        {
         Print("Pending expiry bars cannot be negative.");
         return INIT_PARAMETERS_INCORRECT;
        }
     }

   if(MaxMarginUsagePercent <= 0 || MaxMarginUsagePercent > 100)
     {
      Print("MaxMarginUsagePercent must be between 0 and 100.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(EnableAdaptiveMarginCap && MarginLevelSafe <= MarginLevelDanger)
     {
      Print("MarginLevelSafe must be greater than MarginLevelDanger.");
      return INIT_PARAMETERS_INCORRECT;
     }

//--- Validate basket inputs
   if(EnableBasketRisk)
     {
      if(MaxBasketPositions < 1)
        {
         Print("MaxBasketPositions must be at least 1.");
         return INIT_PARAMETERS_INCORRECT;
        }

      if(MaxBasketLossPercent < 0 || MaxBasketLossPercent > 100)
        {
         Print("MaxBasketLossPercent must be between 0 and 100.");
         return INIT_PARAMETERS_INCORRECT;
        }

      if(MaxBasketMarginPercent < 0 || MaxBasketMarginPercent > 100)
        {
         Print("MaxBasketMarginPercent must be between 0 and 100.");
         return INIT_PARAMETERS_INCORRECT;
        }

      if(AllowHedging && MaxBasketPositions < 2)
         Print("Note: AllowHedging is on but MaxBasketPositions is 1, so an opposing position can never be opened.");
     }

//--- Configure the shared portfolio view
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
         Print("Portfolio scope is magic-filtered but no extra magic numbers were listed, so only this EA is counted.");
     }
//--- EA initialization successful
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Register the other EAs that share this account's risk budget.    |
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
//--- Deinitialize indicator
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
   IndicatorRelease(atrHandle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Get the opening time of the current bar
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime == 0)
      return;

//--- Static variable to remember the last bar we processed
   static datetime lastProcessedBarTime = 0;

//--- If this bar has already been processed, exit immediately
   if(currentBarTime == lastProcessedBarTime)
      return;

//--- Mark this bar as processed
   lastProcessedBarTime = currentBarTime;

//--- Housekeeping runs every new bar, whether or not a signal appears.
   ManagePendingOrders();
   ManageBasketRisk();

   if(EnablePortfolioRisk && LogPortfolioSnapshot)
      portfolio.PrintSnapshot();

//--- Ensure indicators are ready
   if(BarsCalculated(fastHandle) < 3 ||
      BarsCalculated(slowHandle) < 3 ||
      BarsCalculated(atrHandle) < 1)
     {
      Print("Indicators are not ready yet.");
      return;
     }

//--- Populate the MA buffer
   double fast[], slow[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   int fastCopied = CopyBuffer(fastHandle, 0, 0, 3, fast);
   int slowCopied = CopyBuffer(slowHandle, 0, 0, 3, slow);

//--- Validate that we have enough MA data
   if(fastCopied < 3 || slowCopied < 3)
     {
      Print("Failed to get enough Moving Average Data");
      return;
     }

//--- Populate the ATR
   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   if(CopyBuffer(atrHandle, 0, 0, 1, atrArray) < 1)
     {
      Print("Failed to get ATR data");
      return;
     }
   double atrValue = atrArray[0];

//--- Validate that we have a valid ATR value
   if(atrValue <= 0)
     {
      Print("Invalid ATR value: ", atrValue);
      return;
     }

//--- Retrieve market prices
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
     {
      Print("Failed to obtain market prices.");
      return;
     }

//--- Check Spread before trading
   if(!IsSpreadAcceptable())
      return;

//--- Identify the signal on the latest closed bar (index 1)
   int direction = 0;
   if(fast[1] > slow[1] && fast[2] <= slow[2])
      direction = 1;
   else
      if(fast[1] < slow[1] && fast[2] >= slow[2])
         direction = -1;

   if(direction == 0)
      return;

//--- Plan, validate, then execute - three separate responsibilities
   STradePlan plan;
   if(!BuildTradePlan(direction, atrValue, tick, plan))
      return;

   if(!ValidateTradePlan(plan, tick))
      return;

   ExecuteTradePlan(plan);
  }

//+------------------------------------------------------------------+
//| Count total open positions for this EA                           |
//+------------------------------------------------------------------+
int CountOpenPositions()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == MagicNumber)
           {
            count++;
           }
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Count open positions by direction (1 = Buy, -1 = Sell)           |
//+------------------------------------------------------------------+
int CountOpenPositionsByDirection(int direction)
  {
   int count = 0;
   ENUM_POSITION_TYPE posType = (direction == 1) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetInteger(POSITION_TYPE) == posType)
           {
            count++;
           }
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Translate any order type into its trade direction                |
//+------------------------------------------------------------------+
int OrderTypeDirection(ENUM_ORDER_TYPE orderType)
  {
   switch(orderType)
     {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_STOP_LIMIT:
         return 1;
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_STOP_LIMIT:
         return -1;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//| Reduce any order type to the market order it becomes once filled |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE MarketOrderTypeOf(ENUM_ORDER_TYPE orderType)
  {
   return (OrderTypeDirection(orderType) == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
  }

//+------------------------------------------------------------------+
//| Count this EA's pending orders on the current symbol             |
//+------------------------------------------------------------------+
int CountPendingOrders()
  {
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
         OrderGetInteger(ORDER_MAGIC) == MagicNumber)
        {
         count++;
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Count this EA's pending orders in one direction                  |
//+------------------------------------------------------------------+
int CountPendingOrdersByDirection(int direction)
  {
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol ||
         OrderGetInteger(ORDER_MAGIC) != MagicNumber)
         continue;

      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(OrderTypeDirection(orderType) == direction)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Delete this EA's pending orders that never triggered.            |
//+------------------------------------------------------------------+
void ManagePendingOrders()
  {
   if(PendingExpiryBars <= 0)
      return;

   int barSeconds = PeriodSeconds(_Period);
   if(barSeconds <= 0)
      return;

   datetime now = TimeCurrent();

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol ||
         OrderGetInteger(ORDER_MAGIC) != MagicNumber)
         continue;

      datetime setupTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      if(setupTime <= 0 || now <= setupTime)
         continue;

      int barsElapsed = (int)((now - setupTime) / barSeconds);
      if(barsElapsed < PendingExpiryBars)
         continue;

      if(trade.OrderDelete(ticket))
         PrintFormat("Pending order #%I64u expired after %d bars (limit %d). Deleted.",
                     ticket, barsElapsed, PendingExpiryBars);
      else
         PrintFormat("Failed to delete expired pending order #%I64u. Retcode: %u (%s)",
                     ticket, trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
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
      PrintFormat("Spread too high: %.1f points (Maximum %.1f pips)",
                  spreadPoints,
                  MaxSpreadPips);
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Return the drawdown-based risk factor [1.0 = no reduction].      |
//+------------------------------------------------------------------+
double GetDrawdownRiskFactor()
  {
   if(!EnableAdaptiveRisk)
      return 1.0;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

//--- Initialize or update the peak
   if(g_PeakEquity == 0.0 || equity > g_PeakEquity)
      g_PeakEquity = equity;

//--- Calculate current drawdown from peak
   double drawdownPercent = 0.0;
   if(g_PeakEquity > 0.0)
      drawdownPercent = (g_PeakEquity - equity) / g_PeakEquity * 100.0;

   if(drawdownPercent >= DDLevel)
     {
      PrintFormat("Adaptive Risk | Drawdown: %.2f%% >= %.2f%% | Risk scaled by %.2f",
                  drawdownPercent, DDLevel, RiskReductionFactor);
      return RiskReductionFactor;
     }

   return 1.0;
  }

//+------------------------------------------------------------------+
//| Return the monetary amount to risk on this trade.                |
//+------------------------------------------------------------------+
double GetRiskAmount()
  {
   double riskAmount = 0.0;

   if(RiskMode == RISK_FIXED_CASH)
     {
      riskAmount = FixedCashRisk;
     }
   else
     {
      //--- Balance ignores open floating P/L; equity includes it
      double riskBaseValue = (RiskBase == RISK_BASE_EQUITY)
                             ? AccountInfoDouble(ACCOUNT_EQUITY)
                             : AccountInfoDouble(ACCOUNT_BALANCE);
      riskAmount = riskBaseValue * (RiskPercent / 100.0);
     }

//--- Drawdown reduction scales the final amount
   return riskAmount * GetDrawdownRiskFactor();
  }

//+------------------------------------------------------------------+
//| Round a volume down to the broker's volume step.                 |
//+------------------------------------------------------------------+
double FloorToVolumeStep(double volume, double lotStep)
  {
   if(lotStep <= 0)
      return volume;

   double steps  = NormalizeDouble(volume / lotStep, 8);
   double result = MathFloor(steps) * lotStep;

//--- Match the step's own precision so the value sent to the broker is clean
   int stepDigits = (int)MathMax(0, MathCeil(-MathLog10(lotStep)));
   return NormalizeDouble(result, stepDigits);
  }

//+------------------------------------------------------------------+
//| Calculate lot size for the given stop distance and risk amount.  |
//+------------------------------------------------------------------+
double CalculateLotSize(double stopDistance, double riskAmount)
  {
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(minLot <= 0 || lotStep <= 0)
     {
      Print("Invalid broker volume specification. Cannot calculate lot size.");
      return 0.0;
     }

   double rawLot = 0.0;

   if(RiskMode == RISK_FIXED_LOT)
     {
      //--- The trader dictates the volume; risk becomes an outcome
      rawLot = FixedLotSize;

      if(EnableAdaptiveRisk && ApplyDrawdownToFixedLot)
        {
         double ddFactor = GetDrawdownRiskFactor();
         if(ddFactor < 1.0)
           {
            PrintFormat("Fixed lot %.2f scaled by drawdown factor %.2f.", rawLot, ddFactor);
            rawLot *= ddFactor;
           }
        }
     }
   else
     {
      if(stopDistance <= 0)
        {
         Print("Stop distance is zero. Cannot calculate lot size.");
         return 0.0;
        }

      double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

      if(tickSize <= 0 || tickValue <= 0)
        {
         Print("Invalid tick size or tick value. Cannot calculate lot size.");
         return 0.0;
        }

      double monetaryRiskPerLot = (stopDistance / tickSize) * tickValue;
      if(monetaryRiskPerLot <= 0)
        {
         Print("Monetary risk per lot is zero. Cannot calculate lot size.");
         return 0.0;
        }

      if(riskAmount <= 0)
        {
         Print("Risk amount is zero. Cannot calculate lot size.");
         return 0.0;
        }

      rawLot = riskAmount / monetaryRiskPerLot;
     }

//--- Round down to the broker's volume step
   double lotSize = FloorToVolumeStep(rawLot, lotStep);

   if(lotSize > maxLot)
      lotSize = FloorToVolumeStep(maxLot, lotStep);

//--- Below the minimum tradable volume the intended risk is unreachable
   if(lotSize < minLot)
     {
      if(!AllowMinLotOverRisk)
        {
         PrintFormat("Risk-correct volume (%.4f) is below the minimum lot (%.2f). Trade skipped to avoid over-risking.",
                     rawLot, minLot);
         return 0.0;
        }

      PrintFormat("Caution: risk-correct volume (%.4f) is below the minimum lot (%.2f). Trading %.2f - actual risk will EXCEED the intended amount.",
                  rawLot, minLot, minLot);
      lotSize = minLot;
     }

   return lotSize;
  }

//+------------------------------------------------------------------+
//| Return the margin-usage cap [%] this trade may consume.          |
//+------------------------------------------------------------------+
double GetMarginUsageCap()
  {
   if(!EnableAdaptiveMarginCap)
      return MaxMarginUsagePercent;

//--- No margin currently used anywhere on the account (flat)
   double marginUsed = AccountInfoDouble(ACCOUNT_MARGIN);
   if(marginUsed <= 0.0)
      return MaxMarginUsagePercent;

   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

//--- Account-wide margin level already stressed - block new exposure
   if(marginLevel <= MarginLevelDanger)
     {
      PrintFormat("Adaptive Margin Cap | Margin Level: %.1f%% at/below danger threshold (%.1f%%). New trades blocked.",
                  marginLevel, MarginLevelDanger);
      return 0.0;
     }

//--- Margin level healthy - full cap applies
   if(marginLevel >= MarginLevelSafe)
      return MaxMarginUsagePercent;

//--- Scale linearly between the danger and safe thresholds
   double ratio = (marginLevel - MarginLevelDanger) / (MarginLevelSafe - MarginLevelDanger);
   double cap = MaxMarginUsagePercent * ratio;

   PrintFormat("Adaptive Margin Cap | Margin Level: %.1f%% | Cap Scaled To: %.1f%% (baseline %.1f%%)",
               marginLevel, cap, MaxMarginUsagePercent);

   return cap;
  }

//+------------------------------------------------------------------+
//| Cap the risk-based lot size to the account's free margin         |
//+------------------------------------------------------------------+
double ValidateMarginForLot(ENUM_ORDER_TYPE orderType, double lotSize, double price)
  {
//--- Margin required for a single lot; market-order margin scales
//--- linearly with volume, so this is enough to size any lot from
   double marginPerLot = 0.0;
   ResetLastError();
   if(!OrderCalcMargin(orderType, _Symbol, 1.0, price, marginPerLot) || marginPerLot <= 0.0)
     {
      PrintFormat("%s: OrderCalcMargin() failed. Error %d", __FUNCTION__, GetLastError());
      return 0.0;
     }

   double marginCapPercent = GetMarginUsageCap();
   if(marginCapPercent <= 0.0)
     {
      Print("Margin check: account margin level is too low for new exposure. Trade skipped.");
      return 0.0;
     }

   double freeMargin    = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double usedMargin    = AccountInfoDouble(ACCOUNT_MARGIN);
   double allowedMargin = freeMargin * (marginCapPercent / 100.0);

   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   double maxAffordableLot = FloorToVolumeStep(allowedMargin / marginPerLot, lotStep);

   if(maxAffordableLot < minLot)
     {
      //--- Leverage and contract size aren't used in the calculation directly
      long   leverage     = AccountInfoInteger(ACCOUNT_LEVERAGE);
      double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      PrintFormat("Margin check: cannot safely support even the minimum lot (%.2f).", minLot);
      PrintFormat("Free: %.2f | Used: %.2f | Leverage: 1:%d | Contract Size: %.0f. Trade skipped.",
                  freeMargin, usedMargin, (int)leverage, contractSize);
      return 0.0;
     }

   if(lotSize > maxAffordableLot)
     {
      PrintFormat("Margin check: risk-based lot %.2f exceeds the %.1f%% margin-usage cap.", lotSize, marginCapPercent);
      PrintFormat("Free: %.2f | Used: %.2f | %.2f lots affordable. Reducing to %.2f.",
                  freeMargin, usedMargin, maxAffordableLot, maxAffordableLot);
      return maxAffordableLot;
     }
   return lotSize;
  }

//+------------------------------------------------------------------+
//| Resolve the concrete order type from direction and entry mode    |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE ResolveOrderType(int direction)
  {
   if(direction == 1)
     {
      switch(EntryMode)
        {
         case ENTRY_LIMIT:
            return ORDER_TYPE_BUY_LIMIT;
         case ENTRY_STOP:
            return ORDER_TYPE_BUY_STOP;
         default:
            return ORDER_TYPE_BUY;
        }
     }

   switch(EntryMode)
     {
      case ENTRY_LIMIT:
         return ORDER_TYPE_SELL_LIMIT;
      case ENTRY_STOP:
         return ORDER_TYPE_SELL_STOP;
      default:
         return ORDER_TYPE_SELL;
     }
  }

//+------------------------------------------------------------------+
//| Distance a pending entry sits away from the current market       |
//+------------------------------------------------------------------+
double GetPendingOffset(double atrValue)
  {
   if(PendingOffsetMode == OFFSET_POINTS)
      return PendingOffsetPoints * _Point;

   return atrValue * PendingOffsetATR;
  }

//+------------------------------------------------------------------+
//| The price this trade actually intends to enter at.               |
//+------------------------------------------------------------------+
double ResolveEntryPrice(ENUM_ORDER_TYPE orderType, double atrValue, const MqlTick &tick)
  {
   double offset = GetPendingOffset(atrValue);

   switch(orderType)
     {
      //--- Buys are filled at Ask, sells at Bid
      case ORDER_TYPE_BUY:
         return tick.ask;
      case ORDER_TYPE_SELL:
         return tick.bid;

      //--- Limit orders wait for a better price than the market offers now
      case ORDER_TYPE_BUY_LIMIT:
         return tick.ask - offset;
      case ORDER_TYPE_SELL_LIMIT:
         return tick.bid + offset;

      //--- Stop orders wait for the market to move further in the signal's direction
      case ORDER_TYPE_BUY_STOP:
         return tick.ask + offset;
      case ORDER_TYPE_SELL_STOP:
         return tick.bid - offset;
     }

   return 0.0;
  }

//+------------------------------------------------------------------+
//| Smallest stop distance the broker will accept, measured from     |
//| the entry price.                                                 |
//+------------------------------------------------------------------+
double GetMinStopDistance(const MqlTick &tick)
  {
   double stopsLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double spread     = tick.ask - tick.bid;

   if(spread < 0)
      spread = 0;

   return stopsLevel + spread;
  }

//+------------------------------------------------------------------+
//| A pending entry must sit far enough from the current price       |
//+------------------------------------------------------------------+
bool IsPendingDistanceValid(const STradePlan &plan, const MqlTick &tick)
  {
   double stopsLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double distance   = 0.0;

   switch(plan.orderType)
     {
      case ORDER_TYPE_BUY_LIMIT:
         distance = tick.ask - plan.entryPrice;
         break;
      case ORDER_TYPE_SELL_LIMIT:
         distance = plan.entryPrice - tick.bid;
         break;
      case ORDER_TYPE_BUY_STOP:
         distance = plan.entryPrice - tick.ask;
         break;
      case ORDER_TYPE_SELL_STOP:
         distance = tick.bid - plan.entryPrice;
         break;
      default:
         return true;
     }

   if(distance < stopsLevel)
     {
      PrintFormat("Pending entry sits %.1f points from market, broker minimum is %.1f. Trade skipped.",
                  distance / _Point, stopsLevel / _Point);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Build a complete trade plan: intended entry, stops, and volume.  |
//+------------------------------------------------------------------+
bool BuildTradePlan(int direction, double atrValue, const MqlTick &tick, STradePlan &plan)
  {
   ZeroMemory(plan);

   plan.direction = direction;
   plan.orderType = ResolveOrderType(direction);
   plan.isPending = (EntryMode != ENTRY_MARKET);

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

//--- Everything below is anchored to the intended entry
   plan.entryPrice = ResolveEntryPrice(plan.orderType, atrValue, tick);
   if(plan.entryPrice <= 0)
     {
      Print("Failed to resolve an entry price. Trade skipped.");
      return false;
     }
   plan.entryPrice = NormalizeDouble(plan.entryPrice, digits);

//--- Volatility-based stop distance, widened if the broker demands it
   double stopDistance = atrValue * ATRMultiplier;
   double minStop      = GetMinStopDistance(tick);

   if(stopDistance < minStop)
     {
      PrintFormat("Stop distance %.1f points is below the broker minimum %.1f (stops level + spread). Widening.",
                  stopDistance / _Point, minStop / _Point);
      stopDistance = minStop;
     }

//--- Stops and targets measured from the intended entry
   if(direction == 1)
     {
      plan.stopLoss   = NormalizeDouble(plan.entryPrice - stopDistance, digits);
      plan.takeProfit = NormalizeDouble(plan.entryPrice + (stopDistance * TPRatio), digits);
     }
   else
     {
      plan.stopLoss   = NormalizeDouble(plan.entryPrice + stopDistance, digits);
      plan.takeProfit = NormalizeDouble(plan.entryPrice - (stopDistance * TPRatio), digits);
     }

//--- Re-derive the sizing distance from the plan's own entry and stop.
   plan.stopDistance = MathAbs(plan.entryPrice - plan.stopLoss);
   if(plan.stopDistance <= 0)
     {
      Print("Entry and stop resolved to the same price. Trade skipped.");
      return false;
     }

   plan.riskAmount = (RiskMode == RISK_FIXED_LOT) ? 0.0 : GetRiskAmount();
   plan.lotSize    = CalculateLotSize(plan.stopDistance, plan.riskAmount);

   if(plan.lotSize <= 0)
     {
      Print("Position sizing produced no tradable volume. Trade skipped.");
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Aggregate every position this EA holds into a single view.       |
//+------------------------------------------------------------------+
bool GetBasketState(SBasketState &basket)
  {
   ZeroMemory(basket);

   double weightedEntrySum = 0.0;
   double signedVolume     = 0.0;

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
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      basket.positionCount++;
      basket.totalVolume += volume;

      //--- Floating P/L must include the carrying costs, not just price movement
      basket.floatingPL += PositionGetDouble(POSITION_PROFIT)
                           + PositionGetDouble(POSITION_SWAP);

      weightedEntrySum += openPrice * volume;
      signedVolume     += (posType == POSITION_TYPE_BUY) ? volume : -volume;

      //--- No POSITION_MARGIN exists, so price this leg as if opening it now
      double legMargin = 0.0;
      ENUM_ORDER_TYPE asOrder = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      if(OrderCalcMargin(asOrder, _Symbol, volume, openPrice, legMargin))
         basket.usedMargin += legMargin;

      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(basket.oldestOpenTime == 0 || openTime < basket.oldestOpenTime)
         basket.oldestOpenTime = openTime;
     }

   if(basket.positionCount == 0)
      return false;

   if(basket.totalVolume > 0)
      basket.weightedEntryPrice = weightedEntrySum / basket.totalVolume;

//--- Net direction
   if(signedVolume > 0)
      basket.netDirection = 1;
   else
      if(signedVolume < 0)
         basket.netDirection = -1;

   return true;
  }

//+------------------------------------------------------------------+
//| Close every position this EA holds, and report why               |
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

//--- Any pending order belonging to this basket is now orphaned intent
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol ||
         OrderGetInteger(ORDER_MAGIC) != MagicNumber)
         continue;

      if(!trade.OrderDelete(ticket))
         PrintFormat("Failed to delete pending order #%I64u. Retcode: %u (%s)",
                     ticket, trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Reset the running basket statistics once the basket is flat      |
//+------------------------------------------------------------------+
void ResetBasketTracking()
  {
   if(g_BasketPeakCount > 0)
      PrintFormat("Basket closed | Peak positions: %d | Max adverse excursion: %.2f | Max favourable: %.2f",
                  g_BasketPeakCount, g_BasketMaxAdverse, g_BasketMaxFavour);

   g_BasketMaxAdverse = 0.0;
   g_BasketMaxFavour  = 0.0;
   g_BasketPeakCount  = 0;
  }

//+------------------------------------------------------------------+
//| Track how far the basket travels against and in favour of us.    |
//+------------------------------------------------------------------+
void UpdateBasketExcursion(const SBasketState &basket)
  {
   if(!EnableMAETracking)
      return;

   if(basket.positionCount > g_BasketPeakCount)
      g_BasketPeakCount = basket.positionCount;

   if(basket.floatingPL < 0 && MathAbs(basket.floatingPL) > g_BasketMaxAdverse)
      g_BasketMaxAdverse = MathAbs(basket.floatingPL);

   if(basket.floatingPL > g_BasketMaxFavour)
      g_BasketMaxFavour = basket.floatingPL;
  }

//+------------------------------------------------------------------+
//| Basket-level protection, evaluated once per bar.                 |
//+------------------------------------------------------------------+
void ManageBasketRisk()
  {
   if(!EnableBasketRisk)
      return;

   SBasketState basket;
   if(!GetBasketState(basket))
     {
      //--- Flat: report what the closed basket did, then start clean
      ResetBasketTracking();
      return;
     }

   UpdateBasketExcursion(basket);

//--- Aggregate loss cut. The individual stops are still in place
   if(MaxBasketLossPercent > 0)
     {
      double lossBase = (BasketLossBase == RISK_BASE_EQUITY)
                        ? AccountInfoDouble(ACCOUNT_EQUITY)
                        : AccountInfoDouble(ACCOUNT_BALANCE);
      double maxLoss = lossBase * (MaxBasketLossPercent / 100.0);

      if(basket.floatingPL <= -maxLoss)
        {
         CloseBasket(StringFormat("Aggregate loss %.2f breached the %.1f%% limit (%.2f) across %d position(s).",
                                  basket.floatingPL, MaxBasketLossPercent, maxLoss, basket.positionCount));
         ResetBasketTracking();
         return;
        }
     }

//--- Time stop.
   if(MaxBasketHoldBars > 0 && basket.floatingPL < 0 && basket.oldestOpenTime > 0)
     {
      int barSeconds = PeriodSeconds(_Period);
      if(barSeconds > 0)
        {
         int barsHeld = (int)((TimeCurrent() - basket.oldestOpenTime) / barSeconds);
         if(barsHeld >= MaxBasketHoldBars)
           {
            CloseBasket(StringFormat("Held %d bars while losing %.2f (limit %d bars).",
                                     barsHeld, basket.floatingPL, MaxBasketHoldBars));
            ResetBasketTracking();
            return;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Would adding this trade push the basket past its limits?         |
//+------------------------------------------------------------------+
bool IsBasketAcceptingNewTrade(const STradePlan &plan)
  {
   if(!EnableBasketRisk)
      return true;

   SBasketState basket;
   bool hasBasket = GetBasketState(basket);

//--- Position count ceiling, counting pending orders as committed intent
   int committed = (hasBasket ? basket.positionCount : 0) + CountPendingOrders();
   if(committed >= MaxBasketPositions)
     {
      PrintFormat("Basket full: %d position(s)/order(s) already committed, limit is %d. Trade skipped.",
                  committed, MaxBasketPositions);
      return false;
     }

//--- Aggregate margin ceiling for this EA's basket
   if(MaxBasketMarginPercent > 0)
     {
      double newLegMargin = 0.0;
      if(!OrderCalcMargin(MarketOrderTypeOf(plan.orderType), _Symbol,
                          plan.lotSize, plan.entryPrice, newLegMargin))
        {
         PrintFormat("%s: OrderCalcMargin() failed. Error %d", __FUNCTION__, GetLastError());
         return false;
        }

      double projectedMargin = (hasBasket ? basket.usedMargin : 0.0) + newLegMargin;
      double equity          = AccountInfoDouble(ACCOUNT_EQUITY);
      double marginCeiling   = equity * (MaxBasketMarginPercent / 100.0);

      if(equity > 0 && projectedMargin > marginCeiling)
        {
         PrintFormat("Basket margin ceiling: this trade would tie up %.2f of %.2f allowed (%.1f%% of equity). Trade skipped.",
                     projectedMargin, marginCeiling, MaxBasketMarginPercent);
         return false;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Final pre-trade validation gate.                                 |
//+------------------------------------------------------------------+
bool ValidateTradePlan(STradePlan &plan, const MqlTick &tick)
  {
//--- Exposure awareness now covers pending orders too
   if(AllowHedging)
     {
      if(CountOpenPositionsByDirection(plan.direction) > 0 ||
         CountPendingOrdersByDirection(plan.direction) > 0)
         return false;
     }
   else
     {
      if(CountOpenPositions() > 0 || CountPendingOrders() > 0)
         return false;
     }

   if(!IsBasketAcceptingNewTrade(plan))
      return false;

   if(EnablePortfolioRisk)
     {
      string blockReason = "";
      if(!portfolio.CanOpenPosition(_Symbol, MarketOrderTypeOf(plan.orderType),
                                    plan.lotSize, plan.entryPrice, blockReason))
        {
         PrintFormat("Portfolio limit: %s. Trade skipped.", blockReason);
         return false;
        }
     }

//--- A pending entry too close to market is rejected by the server
   if(plan.isPending && !IsPendingDistanceValid(plan, tick))
      return false;

//--- Margin is priced for the position this order will become
   double marginCheckedLot = ValidateMarginForLot(MarketOrderTypeOf(plan.orderType),
                             plan.lotSize,
                             plan.entryPrice);
   if(marginCheckedLot <= 0)
     {
      Print("Trade skipped: insufficient free margin to safely open a position.");
      return false;
     }

   plan.lotSize = marginCheckedLot;
   return true;
  }

//+------------------------------------------------------------------+
//| Send the validated plan to the broker.                           |
//+------------------------------------------------------------------+
bool ExecuteTradePlan(const STradePlan &plan)
  {
   string comment = (plan.direction == 1) ? "MA Cross Buy" : "MA Cross Sell";
   bool   sent    = false;

   switch(plan.orderType)
     {
      case ORDER_TYPE_BUY:
         sent = trade.Buy(plan.lotSize, _Symbol, 0.0, plan.stopLoss, plan.takeProfit, comment);
         break;
      case ORDER_TYPE_SELL:
         sent = trade.Sell(plan.lotSize, _Symbol, 0.0, plan.stopLoss, plan.takeProfit, comment);
         break;
      case ORDER_TYPE_BUY_LIMIT:
         sent = trade.BuyLimit(plan.lotSize, plan.entryPrice, _Symbol, plan.stopLoss, plan.takeProfit,
                               ORDER_TIME_GTC, 0, comment);
         break;
      case ORDER_TYPE_SELL_LIMIT:
         sent = trade.SellLimit(plan.lotSize, plan.entryPrice, _Symbol, plan.stopLoss, plan.takeProfit,
                                ORDER_TIME_GTC, 0, comment);
         break;
      case ORDER_TYPE_BUY_STOP:
         sent = trade.BuyStop(plan.lotSize, plan.entryPrice, _Symbol, plan.stopLoss, plan.takeProfit,
                              ORDER_TIME_GTC, 0, comment);
         break;
      case ORDER_TYPE_SELL_STOP:
         sent = trade.SellStop(plan.lotSize, plan.entryPrice, _Symbol, plan.stopLoss, plan.takeProfit,
                               ORDER_TIME_GTC, 0, comment);
         break;
      default:
         Print("Unsupported order type in trade plan. Nothing sent.");
         return false;
     }

   if(!sent)
     {
      PrintFormat("%s failed. Retcode: %u (%s)",
                  EnumToString(plan.orderType), trade.ResultRetcode(), trade.ResultRetcodeDescription());
      return false;
     }

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

//--- Fixed-lot mode has no intended risk to report; printing 0.00 there
   string riskText = (plan.riskAmount > 0.0)
                     ? StringFormat("%.2f", plan.riskAmount)
                     : "n/a (fixed lot)";

   PrintFormat("%s placed | Lot: %.2f | Entry: %.*f | SL: %.*f | TP: %.*f | Stop: %.1f pts | Intended risk: %s",
               EnumToString(plan.orderType), plan.lotSize,
               digits, plan.entryPrice, digits, plan.stopLoss, digits, plan.takeProfit,
               plan.stopDistance / _Point, riskText);

   return true;
  }
//+------------------------------------------------------------------+
