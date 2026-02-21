//+------------------------------------------------------------------+
//|                                          Hammer&ShootingStar.mq5 |
//|                                   Copyright 2025, Metaquotes Ltd |
//|                                            https://www.mql5.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Metaquotes Ltd"
#property link      "https://www.mql5.com/"
#property version   "1.00"
#property indicator_chart_window

//--- Include the library
#include <infinity_candlestick_pattern.mqh>

//--- Indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_ARROW
#property indicator_color1 0x0000FF
#property indicator_label1 "Sell "

#property indicator_type2 DRAW_ARROW
#property indicator_color2 0xFF0000
#property indicator_label2 "Buy "

//--- Indicator buffers and variables
double Buffer1[];
double Buffer2[];
double Open[];
double High[];
double Low[];
double Close[];
double atr[];
int atrHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 242);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_ARROW, 241);

   // Create ATR handle
   atrHandle = iATR(_Symbol, _Period, 14);
   if (atrHandle == INVALID_HANDLE)
   {
      Print("Failed to create ATR handle");
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   // Copy price data and ATR
   if (CopyOpen(Symbol(), PERIOD_CURRENT, 0, rates_total, Open) <= 0) return(rates_total);
   ArraySetAsSeries(Open, true);
   if (CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High, true);
   if (CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0) return(rates_total);
   ArraySetAsSeries(Low, true);
   if (CopyClose(Symbol(), PERIOD_CURRENT, 0, rates_total, Close) <= 0) return(rates_total);
   ArraySetAsSeries(Close, true);
   if (CopyBuffer(atrHandle, 0, 0, rates_total, atr) <= 0) return(rates_total);
   ArraySetAsSeries(atr, true);

   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);

   // Main loop
   for (int i = rates_total-2; i >= 0; i--)
   {
      // Sell Supply (Shooting Star)
      if (IsShootingStar(Open, High, Low, Close, atr, i))
         Buffer1[i] = High[i]; // Arrow at high
      else
         Buffer1[i] = EMPTY_VALUE;

      // Buy Supply (Hammer)
      if (IsHammer(Open, High, Low, Close, atr, i))
         Buffer2[i] = Low[i]; // Arrow at low
      else
         Buffer2[i] = EMPTY_VALUE;
   }
   return(rates_total);
}