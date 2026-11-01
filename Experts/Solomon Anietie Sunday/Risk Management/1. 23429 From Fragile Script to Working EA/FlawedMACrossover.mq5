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
 input int    inpFastMA = 10;    // Fast MA period
 input int    inpSlowMA = 20;    // Slow MA period
 input double inpLotSize = 0.1;  // Fixed lot size
 input int    inpStopLoss = 200; // Fixed stop loss in points
 input int    inpTakeProfit = 400; // Fixed take profit in points
//--- Global Variables
 CTrade trade;
 int fastHandle, slowHandle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Initialize Handles
    fastHandle = iMA(_Symbol, _Period, inpFastMA, 0, MODE_SMA, PRICE_CLOSE);
    slowHandle = iMA(_Symbol, _Period, inpSlowMA, 0, MODE_SMA, PRICE_CLOSE);
    if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE)
     {
      return INIT_FAILED;
     }
   //--- EA initialization successful
    return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- Deiniatialize indicator
    IndicatorRelease(fastHandle);
    IndicatorRelease(slowHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Populate arrays for both fast and slow indicators
    double fast[], slow[];
    ArraySetAsSeries(fast, true);
    ArraySetAsSeries(slow, true);
    CopyBuffer(fastHandle, 0, 0, 3, fast);
    CopyBuffer(slowHandle, 0, 0, 3, slow);

   //--- Check crossover on the latest closed bar (index 1) and execute trade
    if(fast[1] > slow[1] && fast[2] <= slow[2])
     {
      // Buy signal
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl = ask - inpStopLoss * _Point;
      double tp = ask + inpTakeProfit * _Point;
      trade.Buy(inpLotSize, _Symbol, 0.0, sl, tp, "Flawed Buy");
     }
    else
      if(fast[1] < slow[1] && fast[2] >= slow[2])
        {
         // Sell signal
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = bid + inpStopLoss * _Point;
         double tp = bid - inpTakeProfit * _Point;
         trade.Sell(inpLotSize, _Symbol, 0.0, sl, tp, "Flawed Sell");
        }
  }
//+------------------------------------------------------------------+