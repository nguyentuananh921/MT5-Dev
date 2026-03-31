//My_D1_candlestatus.mql5
//Author: Clemence Benjamin
//Link: https://www.mql5.com/en/users/billionaire2024/seller
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.00"
#property script_show_inputs
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   //--- Get the opening and closing prices of the current D1 candle
   double openPrice = iOpen(NULL, PERIOD_D1, 0);
   double closePrice = iClose(NULL, PERIOD_D1, 0);
   
   //--- Determine if the candle is bullish or bearish
   string candleStatus;
   if(closePrice > openPrice)
     {
      candleStatus = " D1 candle is bullish.";
     }
   else if(closePrice < openPrice)
     {
      candleStatus = " D1 candle is bearish.";
     }
   else
     {
      candleStatus = " D1 candle is neutral.";// when open price is equal to close price
     
     }
   
   //--- Print the status on the chart
   Comment(candleStatus);
   
   //--- Also print the status in the Experts tab for logging
   Print(candleStatus);
  }
//+------------------------------------------------------------------+

