//+------------------------------------------------------------------+
//|                                            FlawedMACrossover.mq5 |
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
 input int    InpFastMA = 10;          // Fast MA period
 input int    inpSlowMA = 20;          // Slow MA period
 input double inpLotSize = 0.1;        // Fixed lot size
 input int    inpMagicNumber = 12345;  // EA Magic Number
 input bool   inpAllowHedging = false; // Allow opposing position (hedging)
 input int    inpATRPeriod = 14;       // ATR Period for Volatility Calculation
 input double inpATRMultiplier = 1.5;  // ATR Multiplier for Stop-Loss Distance
 input double inpTPRatio = 2.0;        // Take Profit Ratio
 input double inpMaxSpreadPips = 2.0;  // Maximum allowed spread
//--- Global Variables
 CTrade trade;
int fastHandle, slowHandle;
int atrHandle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Set the Magic Number for all trades
    trade.SetExpertMagicNumber(inpMagicNumber);
   //--- Initialize Handles
    fastHandle = iMA(_Symbol, _Period, InpFastMA, 0, MODE_SMA, PRICE_CLOSE);
    slowHandle = iMA(_Symbol, _Period, inpSlowMA, 0, MODE_SMA, PRICE_CLOSE);
    atrHandle = iATR(_Symbol, _Period, inpATRPeriod);
   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      return INIT_FAILED;
     }
   //--- Validate user inputs
    if(InpFastMA <= 0 || inpSlowMA <= 0)
     {
      Print("Moving Average periods must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }
    if(InpFastMA >= inpSlowMA)
     {
      Print("FastMA should be smaller than SlowMA.");
      return INIT_PARAMETERS_INCORRECT;
     }
    if(inpLotSize <= 0)
     {
      Print("Lot size must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

    if(inpATRPeriod <= 0 || inpATRMultiplier <= 0)
     {
      Print("ATR parameters must be greater than zero.");
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
    double ask = tick.ask;
    double bid = tick.bid;

   //--- Check Spread before trading
    if(!IsSpreadAcceptable())
      return;

   //--- Calculate the dynamic stop distance
    double stopDistance = atrValue * inpATRMultiplier;
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   //--- Check crossover on the latest closed bar (index 1) and execute trade
    if(fast[1] > slow[1] && fast[2] <= slow[2])
     {
      //--- Buy signal: Check if we can open a Buy position
      bool canOpenTrade = false;
      if(inpAllowHedging)
        {
         //--- Hedging is allowed: Only block Buys if there is already a Buy
         canOpenTrade = (CountOpenPositionsByDirection(1) == 0);
        }
      else
        {
         //--- Hedging is not allowed: Block trades if there is any open position
         canOpenTrade = (CountOpenPositions() == 0);
        }

      if(canOpenTrade)
        {
         double sl = NormalizeDouble(ask - stopDistance, digits);
         double tp = NormalizeDouble(ask + (stopDistance * inpTPRatio), digits);

         // Execute Buy trade and check result
         if(!trade.Buy(inpLotSize, _Symbol, 0.0, sl, tp, "Fixed EA Buy"))
           {
            PrintFormat("Buy failed. Retcode: %u (%s)",
                        trade.ResultRetcode(),
                        trade.ResultRetcodeDescription());
           }
        }
     }
    else
      if(fast[1] < slow[1] && fast[2] >= slow[2])
        {
         //--- Sell signal: Check if we can open a Sell position
         bool canOpenTrade = false;
         if(inpAllowHedging)
           {
            //--- Hedging is allowed: Only block Sells if there is already a Sell
            canOpenTrade = (CountOpenPositionsByDirection(-1) == 0);
           }
         else
           {
            //--- Hedging is not allowed: Block trades if there is any open position
            canOpenTrade = (CountOpenPositions() == 0);
           }

         if(canOpenTrade)
           {
            double sl = NormalizeDouble(bid + stopDistance, digits);
            double tp = NormalizeDouble(bid - (stopDistance * inpTPRatio), digits);

            // Execute Sell trade and check result
            if(!trade.Sell(inpLotSize, _Symbol, 0.0, sl, tp, "Fixed EA Sell"))
              {
               PrintFormat("Sell failed. Retcode: %u (%s)",
                           trade.ResultRetcode(),
                           trade.ResultRetcodeDescription());
              }
           }
        }
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
            PositionGetInteger(POSITION_MAGIC) == inpMagicNumber)
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
            PositionGetInteger(POSITION_MAGIC) == inpMagicNumber &&
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

   if(spreadPoints > inpMaxSpreadPips * 10.0)
     {
      PrintFormat("Spread too high: %.1f points (Maximum %.1f pips)",
                  spreadPoints,
                  inpMaxSpreadPips);
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
