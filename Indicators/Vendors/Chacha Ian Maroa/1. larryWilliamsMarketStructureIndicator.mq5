//+------------------------------------------------------------------+
//|                        larryWilliamsMarketStructureIndicator.mq5 |
//|                          https://www.mql5.com/en/users/chachaian |
//+------------------------------------------------------------------+
//                      Larry Williams Market Secrets                |
//                      1. Building a Swing Structure Indicator      |
//                      https://www.mql5.com/en/articles/20511       |
//+------------------------------------------------------------------+


#property copyright "Copyright 2025, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Custom Indicator specific directives                             |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_plots 6
#property indicator_buffers 6

#property indicator_color1 clrGreen
#property indicator_color2 clrBlack
#property indicator_color3 clrGreen
#property indicator_color4 clrBlack
#property indicator_color5 clrGreen
#property indicator_color6 clrBlack

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 2
#property indicator_width6 2

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double shortTermLows [];
double shortTermHighs[];

double intermediateTermLows [];
double intermediateTermHighs[];

double longTermLows [];
double longTermHighs[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   //--- To configure the chart's appearance
   if(!ConfigureChartAppearance()){
      Print("Error while configuring chart appearance", GetLastError());
      return INIT_FAILED;
   }

   //--- Bind arrays to indicator buffers
   SetIndexBuffer(0, shortTermLows,  INDICATOR_DATA);
   SetIndexBuffer(1, shortTermHighs, INDICATOR_DATA);
   
   SetIndexBuffer(2, intermediateTermLows,  INDICATOR_DATA);
   SetIndexBuffer(3, intermediateTermHighs, INDICATOR_DATA);
   
   SetIndexBuffer(4, longTermLows,  INDICATOR_DATA);
   SetIndexBuffer(5, longTermHighs, INDICATOR_DATA);
   
   //--- Configure Graphic Plots   
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 161);
   PlotIndexSetDouble (0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (0, PLOT_LABEL, "ShortTermLows");
   
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 161);
   PlotIndexSetDouble (1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (1, PLOT_LABEL, "ShortTermHighs");
   
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(2, PLOT_ARROW, 161);
   PlotIndexSetDouble (2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (2, PLOT_LABEL, "intermediateTermLows");
   
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(3, PLOT_ARROW, 161);
   PlotIndexSetDouble (3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (3, PLOT_LABEL, "IntermediateTermHighs");
   
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(4, PLOT_ARROW, 233);
   PlotIndexSetInteger(4, PLOT_ARROW_SHIFT, +30);
   PlotIndexSetDouble (4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (4, PLOT_LABEL, "LongTermHighs");
   
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(5, PLOT_ARROW, 234);
   PlotIndexSetInteger(5, PLOT_ARROW_SHIFT, -30);
   PlotIndexSetDouble (5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (5, PLOT_LABEL, "LongTermHighs");
   
   //--- General indicator configurations
   IndicatorSetString(INDICATOR_SHORTNAME, "Larry Williams Market Structure Indicator");

   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t  rates_total,
                const int32_t  prev_calculated,
                const datetime &time [],
                const double   &open [],
                const double   &high [],
                const double   &low  [],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int32_t  &spread[])
{
   //--- Start with clean buffers at first calculation
   if(prev_calculated == 0){
      ArrayInitialize(shortTermLows,  EMPTY_VALUE);
      ArrayInitialize(shortTermHighs, EMPTY_VALUE);
      ArrayInitialize(intermediateTermLows,  EMPTY_VALUE);
      ArrayInitialize(intermediateTermHighs, EMPTY_VALUE);
      ArrayInitialize(longTermLows,  EMPTY_VALUE);
      ArrayInitialize(longTermHighs, EMPTY_VALUE);
   }   
   //--- Recalculate structures only when a new bar is added
   if(prev_calculated < rates_total){
   
      ArrayInitialize(shortTermLows,  EMPTY_VALUE);
      ArrayInitialize(shortTermHighs, EMPTY_VALUE);
      ArrayInitialize(intermediateTermLows,  EMPTY_VALUE);
      ArrayInitialize(intermediateTermHighs, EMPTY_VALUE);
      ArrayInitialize(longTermLows,  EMPTY_VALUE);
      ArrayInitialize(longTermHighs, EMPTY_VALUE);
      
      for(int32_t i = 1; i < rates_total - 2; i++){
         //--- Identify a short-term low
         if(low[i] < low[i - 1] && low[i] < low[i + 1]){
            shortTermLows[i] = low[i];
         }         
         //--- Identify a short-term high
         if(high[i] > high[i - 1] && high[i] > high[i + 1]){
            shortTermHighs[i] = high[i];
         }
      }      
      BuildIntermediateLows(shortTermLows, rates_total, intermediateTermLows);
      BuildIntermediateHighs(shortTermHighs, rates_total, intermediateTermHighs);
      BuildIntermediateLows(intermediateTermLows, rates_total, longTermLows);
      BuildIntermediateHighs(intermediateTermHighs, rates_total, longTermHighs);
   }

   //--- Return total bars processed
   return(rates_total);
}


//--- UTILITY FUNCTIONS

//+------------------------------------------------------------------+
//| Build intermediate highs from short-term highs                   |
//+------------------------------------------------------------------+
void BuildIntermediateHighs(const double &shortHighs[], const int32_t rates_total, double &intermediateHighs[])
{
   // ensure target array sized
   if(ArraySize(intermediateHighs) != rates_total) ArrayResize(intermediateHighs, rates_total);

   // clear intermediate buffer
   for(int32_t i = 0; i < rates_total; ++i) intermediateHighs[i] = EMPTY_VALUE;

   // collect indices of short-term highs
   int SH_idx[];
   ArrayResize(SH_idx, 0);
   for(int32_t i = 0; i < rates_total; ++i)
   {
      if(shortHighs[i] != EMPTY_VALUE)
      {
         int newlen = ArraySize(SH_idx) + 1;
         ArrayResize(SH_idx, newlen);
         SH_idx[newlen - 1] = i;
      }
   }

   // compress: each short high with lower short highs on both sides becomes an intermediate high
   int count = ArraySize(SH_idx);
   if(count < 3) return; // need at least 3 short-highs for a middle one to qualify

   for(int k = 1; k < count - 1; ++k)
   {
      int prev_i = SH_idx[k - 1];
      int cur_i  = SH_idx[k];
      int next_i = SH_idx[k + 1];

      // strict comparison per Larry: current must be higher than neighbors
      if(shortHighs[cur_i] > shortHighs[prev_i] && shortHighs[cur_i] > shortHighs[next_i])
         intermediateHighs[cur_i] = shortHighs[cur_i];
   }
}


//+------------------------------------------------------------------+
//| Build intermediate lows from short-term lows                     |
//+------------------------------------------------------------------+
void BuildIntermediateLows(const double &shortLows[], const int32_t rates_total, double &intermediateLows[])
{
   if(ArraySize(intermediateLows) != rates_total) ArrayResize(intermediateLows, rates_total);

   for(int32_t i = 0; i < rates_total; ++i) intermediateLows[i] = EMPTY_VALUE;

   int SL_idx[];
   ArrayResize(SL_idx, 0);
   for(int32_t i = 0; i < rates_total; ++i)
   {
      if(shortLows[i] != EMPTY_VALUE)
      {
         int newlen = ArraySize(SL_idx) + 1;
         ArrayResize(SL_idx, newlen);
         SL_idx[newlen - 1] = i;
      }
   }

   int count = ArraySize(SL_idx);
   if(count < 3) return;

   for(int k = 1; k < count - 1; ++k)
   {
      int prev_i = SL_idx[k - 1];
      int cur_i  = SL_idx[k];
      int next_i = SL_idx[k + 1];

      // strict comparison: current low must be lower than neighbors
      if(shortLows[cur_i] < shortLows[prev_i] && shortLows[cur_i] < shortLows[next_i])
         intermediateLows[cur_i] = shortLows[cur_i];
   }
}


//+------------------------------------------------------------------+
//| This function configures the chart's appearance.                 |
//+------------------------------------------------------------------+
bool ConfigureChartAppearance()
{
   if(!ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite)){
      Print("Error while setting chart background, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_SHOW_GRID, false)){
      Print("Error while setting chart grid, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_MODE, CHART_CANDLES)){
      Print("Error while setting chart mode, ", GetLastError());
      return false;
   }

   if(!ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack)){
      Print("Error while setting chart foreground, ", GetLastError());
      return false;
   }

   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrSeaGreen)){
      Print("Error while setting bullish candles color, ", GetLastError());
      return false;
   }
      
   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlack)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_COLOR_CHART_UP, clrSeaGreen)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
