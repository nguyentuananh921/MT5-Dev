//+------------------------------------------------------------------+
//|                                                   Trend Constraint Expert.mq5   |
//|                                Copyright 2024, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.0"
#property description "An Expert based on the buffer6 and buffer7 of Trend Constraint V1.09"

//--- Input parameters for the EA
input double Lots = 0.1;          // Lot size
input int Slippage = 3;           // Slippage
input double StopLoss = 50;       // Stop Loss in points
input double TakeProfit = 100;    // Take Profit in points
input int MagicNumber = 123456;   // Magic number for orders

//--- Indicator handle
int indicator_handle;
double Buffer6[];
double Buffer7[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Get the indicator handle
   indicator_handle = iCustom(Symbol(), PERIOD_CURRENT, "Trend Constraint V1.09");
   if (indicator_handle < 0)
     {
      Print("Failed to get the indicator handle. Error: ", GetLastError());
      return(INIT_FAILED);
     }

   //--- Set the buffer arrays as series
   ArraySetAsSeries(Buffer6, true);
   ArraySetAsSeries(Buffer7, true);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- Release the indicator handle
   IndicatorRelease(indicator_handle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Check if there is already an open position with the same MagicNumber
   if (PositionSelect(Symbol()))
     {
      if (PositionGetInteger(POSITION_MAGIC) == MagicNumber)
        {
         return; // Exit OnTick if there's an open position with the same MagicNumber
        }
     }

   //--- Calculate the indicator
   if (CopyBuffer(indicator_handle, 5, 0, 2, Buffer6) <= 0 || CopyBuffer(indicator_handle, 6, 0, 2, Buffer7) <= 0)
     {
      Print("Failed to copy buffer values. Error: ", GetLastError());
      return;
     }

   //--- Check for a buy signal
   if (Buffer7[0] != EMPTY_VALUE)
     {
      double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      double sl = NormalizeDouble(ask - StopLoss * _Point, _Digits);
      double tp = NormalizeDouble(ask + TakeProfit * _Point, _Digits);

      //--- Prepare the buy order request
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      ZeroMemory(result);

      request.action = TRADE_ACTION_DEAL;
      request.symbol = Symbol();
      request.volume = Lots;
      request.type = ORDER_TYPE_BUY;
      request.price = ask;
      request.sl = sl;
      request.tp = tp;
      request.deviation = Slippage;
      request.magic = MagicNumber;
      request.comment = "Buy Order";

      //--- Send the buy order
      if (!OrderSend(request, result))
        {
         Print("Error opening buy order: ", result.retcode);
        }
      else
        {
         Print("Buy order opened successfully! Ticket: ", result.order);
        }
     }

   //--- Check for a sell signal
   if (Buffer6[0] != EMPTY_VALUE)
     {
      double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      double sl = NormalizeDouble(bid + StopLoss * _Point, _Digits);
      double tp = NormalizeDouble(bid - TakeProfit * _Point, _Digits);

      //--- Prepare the sell order request
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      ZeroMemory(result);

      request.action = TRADE_ACTION_DEAL;
      request.symbol = Symbol();
      request.volume = Lots;
      request.type = ORDER_TYPE_SELL;
      request.price = bid;
      request.sl = sl;
      request.tp = tp;
      request.deviation = Slippage;
      request.magic = MagicNumber;
      request.comment = "Sell Order";

      //--- Send the sell order
      if (!OrderSend(request, result))
        {
         Print("Error opening sell order: ", result.retcode);
        }
      else
        {
         Print("Sell order opened successfully! Ticket: ", result.order);
        }
     }
  }

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   //--- Handle trade events if necessary
  }

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   double ret = 0.0;
   //--- Custom calculations for strategy tester
   return (ret);
  }

//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
   //--- Initialization for the strategy tester
  }

//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
   //--- Code executed after each pass in optimization
  }

//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
   //--- Cleanup after tester runs
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   //--- Handle chart events here
  }
//+------------------------------------------------------------------+
