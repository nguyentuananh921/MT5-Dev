//+------------------------------------------------------------------+
//|                                      Trend Constraint Expert.mq5 |
//|                                Copyright 2024, Clemence Benjamin |
//|             https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>  // Include the trade library

// Input parameters
input int    RSI_Period = 14;            // RSI period
input double RSI_Overbought = 70.0;      // RSI overbought level
input double RSI_Oversold = 30.0;        // RSI oversold level
input double Lots = 0.1;                 // Lot size
input double StopLoss = 100;             // Stop Loss in points
input double TakeProfit = 200;           // Take Profit in points
input double TrailingStop = 50;          // Trailing Stop in points

// Global variables
double rsi_value;
int rsi_handle;
CTrade trade;  // Declare an instance of the CTrade class

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Create an RSI indicator handle
   rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
   if (rsi_handle == INVALID_HANDLE)
     {
      Print("Failed to create RSI indicator handle");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Release the RSI indicator handle
   IndicatorRelease(rsi_handle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Determine current daily trend (bullish or bearish)
   double daily_open = iOpen(_Symbol, PERIOD_D1, 0);
   double daily_close = iClose(_Symbol, PERIOD_D1, 0);

   bool is_bullish = daily_close > daily_open;
   bool is_bearish = daily_close < daily_open;

   // Get the RSI value for the current bar
   double rsi_values[];
   if (CopyBuffer(rsi_handle, 0, 0, 1, rsi_values) <= 0)
     {
      Print("Failed to get RSI value");
      return;
     }
   rsi_value = rsi_values[0];

   // Close open positions if the trend changes
   for (int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if (PositionSelect(PositionGetSymbol(i)))  // Corrected usage
        {
         int position_type = PositionGetInteger(POSITION_TYPE);
         ulong ticket = PositionGetInteger(POSITION_TICKET);  // Get the position ticket

         if ((position_type == POSITION_TYPE_BUY && is_bearish) ||
             (position_type == POSITION_TYPE_SELL && is_bullish))
           {
            trade.PositionClose(ticket);  // Use the ulong variable directly
           }
        }
     }

   // Check for buy condition (bullish trend + RSI oversold)
   if (is_bullish && rsi_value < RSI_Oversold)
     {
      // No open positions? Place a buy order
      if (PositionsTotal() == 0)
        {
         double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double sl = price - StopLoss * _Point;
         double tp = price + TakeProfit * _Point;

         // Open a buy order
         trade.Buy(Lots, _Symbol, price, sl, tp, "TrendConstraintExpert Buy");
        }
     }

   // Check for sell condition (bearish trend + RSI overbought)
   if (is_bearish && rsi_value > RSI_Overbought)
     {
      // No open positions? Place a sell order
      if (PositionsTotal() == 0)
        {
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = price + StopLoss * _Point;
         double tp = price - TakeProfit * _Point;

         // Open a sell order
         trade.Sell(Lots, _Symbol, price, sl, tp, "TrendConstraintExpert Sell");
        }
     }

   // Apply trailing stop
   for (int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if (PositionSelect(PositionGetSymbol(i)))  // Corrected usage
        {
         double price = PositionGetDouble(POSITION_PRICE_OPEN);
         double stopLoss = PositionGetDouble(POSITION_SL);
         double current_price;

         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if (current_price - price > TrailingStop * _Point)
              {
               if (stopLoss < current_price - TrailingStop * _Point)
                 {
                  trade.PositionModify(PositionGetInteger(POSITION_TICKET), current_price - TrailingStop * _Point, PositionGetDouble(POSITION_TP));
                 }
              }
           }
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            current_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if (price - current_price > TrailingStop * _Point)
              {
               if (stopLoss > current_price + TrailingStop * _Point || stopLoss == 0)
                 {
                  trade.PositionModify(PositionGetInteger(POSITION_TICKET), current_price + TrailingStop * _Point, PositionGetDouble(POSITION_TP));
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
