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
input int    MagicNumber = 12345678;     // Magic number for this EA

// Global variables
double rsi_value;
int rsi_handle;
CTrade trade;  // Declare an instance of the CTrade class

// Variables for moving averages
double ma_short;
double ma_long;

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
   // Calculate moving averages
   ma_short = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
   ma_long  = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);

   // Determine trend direction
   bool is_uptrend = ma_short > ma_long;
   bool is_downtrend = ma_short < ma_long;

   // Get the RSI value for the current bar
   double rsi_values[];
   if (CopyBuffer(rsi_handle, 0, 0, 1, rsi_values) <= 0)
     {
      Print("Failed to get RSI value");
      return;
     }
   rsi_value = rsi_values[0];

   // Close open positions if the trend changes
   for (int i = 0; i < PositionsTotal(); i++) // Correct loop initialization
     {
      if (PositionGetSymbol(i) == _Symbol && PositionSelect(PositionGetSymbol(i)))  // Select position by symbol
        {
         long position_type = PositionGetInteger(POSITION_TYPE);
         long currentMagicNumber = PositionGetInteger(POSITION_MAGIC);
         ulong ticket = PositionGetInteger(POSITION_TICKET);

         if (currentMagicNumber == MagicNumber) // Ensure only this EA's orders are checked
           {
            if ((position_type == POSITION_TYPE_BUY && is_downtrend) ||
                (position_type == POSITION_TYPE_SELL && is_uptrend))
              {
               trade.PositionClose(ticket);
              }
           }
        }
     }

   // Check for buy condition (uptrend + RSI oversold)
   if (is_uptrend && rsi_value < RSI_Oversold)
     {
      // No open positions? Place a buy order
      bool open_position = false;

      for (int i = 0; i < PositionsTotal(); i++) // Correct loop initialization
        {
         if (PositionGetSymbol(i) == _Symbol && PositionSelect(PositionGetSymbol(i)))
           {
            long currentMagicNumber = PositionGetInteger(POSITION_MAGIC);

            if (currentMagicNumber == MagicNumber)
              {
               open_position = true;
               break;
              }
           }
        }

      if (!open_position)
        {
         double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double sl = price - StopLoss * _Point;
         double tp = price + TakeProfit * _Point;

         // Open a buy order
         if (trade.Buy(Lots, _Symbol, price, sl, tp, "TrendFollowing Buy"))
            Print("Buy order placed with Magic Number: ", MagicNumber);
         else
            Print("Error placing buy order: ", GetLastError());
        }
     }

   // Check for sell condition (downtrend + RSI overbought)
   if (is_downtrend && rsi_value > RSI_Overbought)
     {
      // No open positions? Place a sell order
      bool open_position = false;

      for (int i = 0; i < PositionsTotal(); i++) // Correct loop initialization
        {
         if (PositionGetSymbol(i) == _Symbol && PositionSelect(PositionGetSymbol(i)))
           {
            long currentMagicNumber = PositionGetInteger(POSITION_MAGIC);

            if (currentMagicNumber == MagicNumber)
              {
               open_position = true;
               break;
              }
           }
        }

      if (!open_position)
        {
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = price + StopLoss * _Point;
         double tp = price - TakeProfit * _Point;

         // Open a sell order
         if (trade.Sell(Lots, _Symbol, price, sl, tp, "TrendFollowing Sell"))
            Print("Sell order placed with Magic Number: ", MagicNumber);
         else
            Print("Error placing sell order: ", GetLastError());
        }
     }

   // Apply trailing stop
   for (int i = 0; i < PositionsTotal(); i++) // Correct loop initialization
     {
      if (PositionGetSymbol(i) == _Symbol && PositionSelect(PositionGetSymbol(i))) // Select position by symbol
        {
         long currentMagicNumber = PositionGetInteger(POSITION_MAGIC);

         if (currentMagicNumber == MagicNumber) // Apply trailing stop only to this EA's positions
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
  }
//+------------------------------------------------------------------+
