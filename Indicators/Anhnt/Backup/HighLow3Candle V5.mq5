//+------------------------------------------------------------------+
//|                                               HighLow3Candle.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//This file is in MQL5\Indicators\Anhnt\HighLow3Candle.mq5
#property indicator_chart_window
#property indicator_plots 2
#property indicator_buffers 2

//---- Plot 1: High
#property indicator_label1 "HL3 High"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrDeepPink      // Color
#property indicator_style1 STYLE_SOLID      // Style
#property indicator_width1 2                // Width
//---- Plot 2: Low
#property indicator_label2 "HL3 Low"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrLime           // Color
#property indicator_style2 STYLE_SOLID       // Style
#property indicator_width2 2                 // Width

//Include
#include <Anhnt/Utilities/PriceUtilities.mqh>

//--- input parameters
input ENUM_APPLIED_PRICE inp_HighAppliedPrice = PRICE_HIGH;
input ENUM_APPLIED_PRICE inp_LowAppliedPrice  = PRICE_LOW;
input int                inp_LookbackBars     = 3;

//--- indicator buffers
double HighBuffer[];
double LowBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, HighBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, LowBuffer,  INDICATOR_DATA);

   ArraySetAsSeries(HighBuffer, true); // Match price series
   ArraySetAsSeries(LowBuffer,  true); // Match price series
   //Set here to Tell MT5 from which bar indicator is allowed to draw
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, inp_LookbackBars);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, inp_LookbackBars);
   
   //Set Color and Style
   
    

   // Chat GPT add here:
   // Do NOT set color / style / width here
   // This allows user to customize them in Visualization tab (like Bollinger Bands)

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total <= inp_LookbackBars)
      return 0;

  // Always recalculate on new tick to keep the level updated
   int start_bar = 1; // use closed candles only

   int indexHigh = start_bar;
   int indexLow  = start_bar;
   double maxPrice = GetAppliedPrice(inp_HighAppliedPrice, start_bar,
                                     open, high, low, close);
   double minPrice = GetAppliedPrice(inp_LowAppliedPrice, start_bar,
                                     open, high, low, close);

   // Find the candle index with highest / lowest applied price
   for(int i = start_bar + 1; i < start_bar + inp_LookbackBars; i++)
     {
      double ph = GetAppliedPrice(inp_HighAppliedPrice, i,
                                  open, high, low, close);
      double pl = GetAppliedPrice(inp_LowAppliedPrice,  i,
                                  open, high, low, close);

      if(ph > maxPrice)
        {
         maxPrice = ph;
         indexHigh = i;
        }

      if(pl < minPrice)
        {
         minPrice = pl;
         indexLow = i;
        }
     }
   
   // Draw horizontal levels based on the winning candles
   for(int i = 0; i < rates_total; i++)
     {
      HighBuffer[i] = maxPrice;
      LowBuffer[i]  = minPrice;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
