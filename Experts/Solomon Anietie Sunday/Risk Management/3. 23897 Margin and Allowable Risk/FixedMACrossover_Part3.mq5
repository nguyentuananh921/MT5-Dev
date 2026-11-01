//+------------------------------------------------------------------+
//|                                             FixedMACrossover.mq5 |
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
#property copyright "Copyright 2026, soloharbinger"
#property link      "https://www.mql5.com/en/users/soloharbinger"
#property version   "1.00"
#include <Trade/Trade.mqh>

//--- Input Parameters
input group "Trading Signal"
input int    InpFastMA = 10;                         // Fast MA period
input int    InpSlowMA = 20;                         // Slow MA period

input group "Trade & Risk Settings"
input double InpRiskPercent = 1.0;                   // Risk per trade [%]
input bool   InpAllowHedging = false;                // Allow opposing position (hedging)
input int    InpATRPeriod = 14;                      // ATR Period for Volatility Calculation
input double InpATRMultiplier = 1.5;                 // ATR Multiplier for Stop-Loss Distance
input double InpTPRatio = 2.0;                       // Take Profit Ratio
input double InpMaxSpreadPips = 2.0;                 // Maximum allowed spread

input group "Adaptive Risk (Drawdown)"
input bool   InpEnableAdaptiveRisk  = false;         // Reduce risk during drawdowns
input double InpDDLevel             = 3.0;           // Drawdown % that triggers reduced risk
input double InpRiskReductionFactor = 0.5;           // Adaptive risk multiplier when triggered [0.5 = half risk]

input group "Broker & Margin Safety"
input double InpMaxMarginUsagePercent   = 50.0;      // Max % of free margin one new trade may use
input bool   InpEnableAdaptiveMarginCap = false;     // Scale the margin cap with account-wide margin level
input double InpMarginLevelSafe         = 500.0;     // Margin safe level [%] full cap applies
input double InpMarginLevelDanger       = 150.0;     // Margin caution level [%] new trades are blocked

input group "General"
input int    InpMagicNumber = 12345;                 // EA Magic Number


//--- Global Variables
CTrade trade;
int fastMaHandle, slowMaHandle;
int atrIndicatorHandle;
double g_peakEquity = 0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set the Magic Number for all trades
   trade.SetExpertInpMagicNumber(InpMagicNumber);

//--- Initialize Handles
   fastMaHandle = iMA(_Symbol, _Period, InpFastMA, 0, MODE_SMA, PRICE_CLOSE);
   slowMaHandle = iMA(_Symbol, _Period, InpSlowMA, 0, MODE_SMA, PRICE_CLOSE);
   atrIndicatorHandle = iATR(_Symbol, _Period, InpATRPeriod);

   if(fastMaHandle == INVALID_HANDLE || slowMaHandle == INVALID_HANDLE || atrIndicatorHandle == INVALID_HANDLE)
     {
      return INIT_FAILED;
     }

//--- Validate user inputs
   if(InpFastMA <= 0 || InpSlowMA <= 0)
     {
      Print("Moving Average periods must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpFastMA >= InpSlowMA)
     {
      Print("InpFastMA should be smaller than InpSlowMA.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpRiskPercent <= 0)
     {
      Print("Risk per trade must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpATRPeriod <= 0 || InpATRMultiplier <= 0)
     {
      Print("ATR parameters must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpMaxMarginUsagePercent <= 0 || InpMaxMarginUsagePercent > 100)
     {
      Print("InpMaxMarginUsagePercent must be between 0 and 100.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpEnableAdaptiveMarginCap && InpMarginLevelSafe <= InpMarginLevelDanger)
     {
      Print("InpMarginLevelSafe must be greater than InpMarginLevelDanger.");
      return INIT_PARAMETERS_INCORRECT;
     }
//--- EA initialization successful
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Deinitialize indicator
   IndicatorRelease(fastMaHandle);
   IndicatorRelease(slowMaHandle);
   IndicatorRelease(atrIndicatorHandle);
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

//--- Ensure indicators are ready
   if(BarsCalculated(fastMaHandle) < 3 ||
      BarsCalculated(slowMaHandle) < 3 ||
      BarsCalculated(atrIndicatorHandle) < 1)
     {
      Print("Indicators are not ready yet.");
      return;
     }

//--- Populate the MA buffer
   double fast[], slow[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   int fastCopied = CopyBuffer(fastMaHandle, 0, 0, 3, fast);
   int slowCopied = CopyBuffer(slowMaHandle, 0, 0, 3, slow);

//--- Validate that we have enough MA data
   if(fastCopied < 3 || slowCopied < 3)
     {
      Print("Failed to get enough Moving Average Data");
      return;
     }

//--- Populate the ATR
   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   if(CopyBuffer(atrIndicatorHandle, 0, 0, 1, atrArray) < 1)
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
   double ask = tick.ask;
   double bid = tick.bid;

//--- Check Spread before trading
   if(!IsSpreadAcceptable())
      return;

//--- Calculate the dynamic stop distance
   double stopDistance = atrValue * InpATRMultiplier;

//--- Validate minimum stop distance
   double minStopDistance = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   if(stopDistance < minStopDistance)
     {
      Print("Stop distance too tight. Adjusting from ", stopDistance, " to ", minStopDistance);
      stopDistance = minStopDistance;
     }

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

//--- Check crossover on the latest closed bar (index 1) and execute trade
   if(fast[1] > slow[1] && fast[2] <= slow[2])
      OpenPosition(1, ask, stopDistance, digits);
   else
      if(fast[1] < slow[1] && fast[2] >= slow[2])
         OpenPosition(-1, bid, stopDistance, digits);
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
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
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
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
            PositionGetInteger(POSITION_TYPE) == posType)
           {
            count++;
           }
        }
     }
   return count;
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

   if(spreadPoints > InpMaxSpreadPips * 10.0)
     {
      PrintFormat("Spread too high: %.1f points (Maximum %.1f pips)",
                  spreadPoints,
                  InpMaxSpreadPips);
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Calculate lot size from account risk and stop distance           |
//+------------------------------------------------------------------+
double CalculateLotSize(double stopDistance)
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (GetAdaptiveInpRiskPercent() / 100.0);

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

//--- Confine and round to the broker's volume rules
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   double lotSize = riskAmount / monetaryRiskPerLot;
   lotSize = MathMax(minLot, MathMin(lotSize, maxLot));
   lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;

   return lotSize;
  }


//+------------------------------------------------------------------+
//| Return the risk percent to use, adjusted for drawdown            |
//+------------------------------------------------------------------+
double GetAdaptiveInpRiskPercent()
  {
   if(!InpEnableAdaptiveRisk)
      return InpRiskPercent;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

//--- Initialize or update the peak
   if(g_peakEquity == 0.0 || equity > g_peakEquity)
      g_peakEquity = equity;

//--- Calculate current drawdown from peak
   double drawdownPercent = 0.0;
   if(g_peakEquity > 0.0)
      drawdownPercent = (g_peakEquity - equity) / g_peakEquity * 100.0;

   PrintFormat("Adaptive Risk | Drawdown: %.2f%% | Risk Used: %.2f%%",
               drawdownPercent,
               (drawdownPercent >= InpDDLevel) ? InpRiskPercent * InpRiskReductionFactor : InpRiskPercent);

   if(drawdownPercent >= InpDDLevel)
      return InpRiskPercent * InpRiskReductionFactor;

   return InpRiskPercent;
  }

//+------------------------------------------------------------------+
//| Return the margin-usage cap [%] this trade may consume.          |
//+------------------------------------------------------------------+
double GetMarginUsageCap()
  {
   if(!InpEnableAdaptiveMarginCap)
      return InpMaxMarginUsagePercent;

//--- No margin currently used anywhere on the account (flat)
   double marginUsed = AccountInfoDouble(ACCOUNT_MARGIN);
   if(marginUsed <= 0.0)
      return InpMaxMarginUsagePercent;

   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   
//--- Account-wide margin level already stressed - block new exposure
   if(marginLevel <= InpMarginLevelDanger)
     {
      PrintFormat("Adaptive Margin Cap | Margin Level: %.1f%% at/below danger threshold (%.1f%%).",
                  marginLevel, InpMarginLevelDanger);
      return 0.0;
     }

//--- Margin level healthy - full cap applies
   if(marginLevel >= InpMarginLevelSafe)
      return InpMaxMarginUsagePercent;

//--- Scale linearly between the danger and safe thresholds
   double ratio = (marginLevel - InpMarginLevelDanger) / (InpMarginLevelSafe - InpMarginLevelDanger);
   double cap = InpMaxMarginUsagePercent * ratio;

   PrintFormat("Adaptive Margin Cap | Margin Level: %.1f%% | Cap Scaled To: %.1f%% (baseline %.1f%%)",
               marginLevel, cap, InpMaxMarginUsagePercent);

   return cap;
  }

//+------------------------------------------------------------------+
//| Cap the risk-based lot size to the account's free margin         |
//+------------------------------------------------------------------+
double ValidateMarginForLot(ENUM_ORDER_TYPE orderType, double lotSize, double price)
  {
//--- Margin required for a single lot
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

   double maxAffordableLot = MathFloor((allowedMargin / marginPerLot) / lotStep) * lotStep;

   if(maxAffordableLot < minLot)
     {
      //--- Leverage and contract size aren't used in the calculation but only for logging
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
//| Final pre-trade validation gate.                                 |
//+------------------------------------------------------------------+
bool PassesPreTradeValidation(int direction, double stopDistance, double price, double &validatedLotSize)
  {
   validatedLotSize = 0.0;

//--- Position awareness check, same rule as Part 1
   bool canOpenTrade = false;
   if(InpAllowHedging)
      canOpenTrade = (CountOpenPositionsByDirection(direction) == 0);
   else
      canOpenTrade = (CountOpenPositions() == 0);

   if(!canOpenTrade)
      return false;

//--- Lot size from the validated stop distance
   double lotSize = CalculateLotSize(stopDistance);
   if(lotSize <= 0)
     {
      Print("Calculated lot size is invalid. Trade skipped.");
      return false;
     }

//--- Cap the lot to what free margin can safely support
   ENUM_ORDER_TYPE orderType = (direction == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   lotSize = ValidateMarginForLot(orderType, lotSize, price);
   if(lotSize <= 0)
     {
      Print("Trade skipped: insufficient free margin to safely open a position.");
      return false;
     }

   validatedLotSize = lotSize;
   return true;
  }

//+------------------------------------------------------------------+
//| Size, validate, and open a trade in the given direction          |
//| direction: 1 = Buy, -1 = Sell                                    |
//+------------------------------------------------------------------+
void OpenPosition(int direction, double price, double stopDistance, int digits)
  {
   double lotSize = 0.0;
   if(!PassesPreTradeValidation(direction, stopDistance, price, lotSize))
      return;

//--- SL/TP and execution, direction-specific
   double sl, tp;
   if(direction == 1)
     {
      sl = NormalizeDouble(price - stopDistance, digits);
      tp = NormalizeDouble(price + (stopDistance * InpTPRatio), digits);
      if(!trade.Buy(lotSize, _Symbol, 0.0, sl, tp, "Fixed EA Buy"))
         PrintFormat("Buy failed. Retcode: %u (%s)", trade.ResultRetcode(),
                     trade.ResultRetcodeDescription());
     }
   else
     {
      sl = NormalizeDouble(price + stopDistance, digits);
      tp = NormalizeDouble(price - (stopDistance * InpTPRatio), digits);
      if(!trade.Sell(lotSize, _Symbol, 0.0, sl, tp, "Fixed EA Sell"))
         PrintFormat("Sell failed. Retcode: %u (%s)", trade.ResultRetcode(),
                     trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
