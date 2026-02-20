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

   //--- initialize with first closed bar
   double valHigh = GetAppliedPrice(inp_HighAppliedPrice, 1,
                                    open, high, low, close);
   double valLow  = GetAppliedPrice(inp_LowAppliedPrice, 1,
                                    open, high, low, close);

   //--- find High / Low by applied price
   for(int i = 2; i <= inp_LookbackBars; i++)
     {
      double ph = GetAppliedPrice(inp_HighAppliedPrice, i,
                                  open, high, low, close);
      double pl = GetAppliedPrice(inp_LowAppliedPrice,  i,
                                  open, high, low, close);

      if(ph > valHigh) valHigh = ph;
      if(pl < valLow)  valLow  = pl;
     }

   //--- draw horizontal lines
   for(int i = 0; i < rates_total; i++)
     {
      HighBuffer[i] = valHigh;
      LowBuffer[i]  = valLow;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
