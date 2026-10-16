
//+------------------------------------------------------------------+
//|                                       lwOopsPatternIndicator.mq5 |
//|          Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian |
//|                          https://www.mql5.com/en/users/chachaian |
//|Larry Williams Market Secrets                                     |
//|17. Detecting Oops Signals Using a Custom Indicator               |
//|                     https://www.mql5.com/en/articles/21867       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"

//--- Indicator configuration
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Bullish signal plot
#property indicator_label1  "Bullish Oops Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSeaGreen
#property indicator_width1  2

//--- Bearish signal plot
#property indicator_label2  "Bearish Oops Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlack
#property indicator_width2  2

//--- Bullish signal plot
#property indicator_label1  "Bullish Oops Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSeaGreen
#property indicator_width1  2

//--- Bearish signal plot
#property indicator_label2  "Bearish Oops Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlack
#property indicator_width2  2

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "Oops Pattern Configurations"
input double minimumGapSizePoints = 500;
input int    maxGapValidityBars   = 4;

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double bullishSignalBuffer[];
double bearishSignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(minimumGapSizePoints < 0.0)
     {
      PrintFormat("Invalid minimum gap size: %.2f. The value cannot be negative.",
                  minimumGapSizePoints);
      return INIT_PARAMETERS_INCORRECT;
     }

   if(maxGapValidityBars < 0)
     {
      PrintFormat("Invalid maximum gap validity: %d. The value cannot be negative.",
                  maxGapValidityBars);
      return INIT_PARAMETERS_INCORRECT;
     }

   ResetLastError();

   if(!SetIndexBuffer(0, bullishSignalBuffer, INDICATOR_DATA))
     {
      PrintFormat("Failed to bind the bullish signal buffer. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   ResetLastError();

   if(!SetIndexBuffer(1, bearishSignalBuffer, INDICATOR_DATA))
     {
      PrintFormat("Failed to bind the bearish signal buffer. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   if(!InitializeArraysAsNonTimeSeries())
      return INIT_FAILED;

   ResetLastError();

   if(!PlotIndexSetInteger(0, PLOT_ARROW, 233))
     {
      PrintFormat("Failed to set the bullish arrow symbol. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   ResetLastError();

   if(!PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 20))
     {
      PrintFormat("Failed to set the bullish arrow shift. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   ResetLastError();

   if(!PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE))
     {
      PrintFormat("Failed to set the bullish plot empty value. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   ResetLastError();

   if(!PlotIndexSetInteger(1, PLOT_ARROW, 234))
     {
      PrintFormat("Failed to set the bearish arrow symbol. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   ResetLastError();

   if(!PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -20))
     {
      PrintFormat("Failed to set the bearish arrow shift. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   ResetLastError();

   if(!PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE))
     {
      PrintFormat("Failed to set the bearish plot empty value. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   ResetLastError();

   if(!IndicatorSetString(INDICATOR_SHORTNAME, "Oops Pattern Indicator"))
     {
      PrintFormat("Failed to set the indicator short name. Error: %d",
                  GetLastError());
      return INIT_FAILED;
     }

   if(!ConfigureChartAppearance())
      return INIT_FAILED;

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
//--- Ensure enough bars are available for comparison and updating
   if(rates_total < 3)
      return 0;

//--- Apply direct indexing to the incoming price arrays
   if(!InitializePriceArraysAsNonTimeSeries(open, high, low, close))
      return prev_calculated;

//--- Rebuild all signals on first launch or after a history reset;
//--- or when multiple new bars become available at once
   if(prev_calculated == 0 || prev_calculated > rates_total || rates_total - prev_calculated > 1)
     {
      ArrayInitialize(bullishSignalBuffer, EMPTY_VALUE);
      ArrayInitialize(bearishSignalBuffer, EMPTY_VALUE);

      MapHistoricalOopsSignals(rates_total, open, high, low, close);

      return rates_total;
     }

//--- Update only the latest completed bar when new data is added
   if(prev_calculated < rates_total)
      UpdateLatestOopsSignalOnNewBar(rates_total, open, high, low, close);

   return rates_total;
  }
  
//+------------------------------------------------------------------+
//| Sets indicator buffers to direct indexing                        |
//+------------------------------------------------------------------+
bool InitializeArraysAsNonTimeSeries()
  {
   ResetLastError();

   if(!ArraySetAsSeries(bullishSignalBuffer, false))
     {
      PrintFormat("Failed to set direct indexing for the bullish buffer. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ArraySetAsSeries(bearishSignalBuffer, false))
     {
      PrintFormat("Failed to set direct indexing for the bearish buffer. Error: %d",
                  GetLastError());
      return false;
     }

   return true;
  }
  
//+------------------------------------------------------------------+
//| Sets the price arrays to direct indexing                         |
//+------------------------------------------------------------------+
bool InitializePriceArraysAsNonTimeSeries(const double &open[],
                                          const double &high[],
                                          const double &low[],
                                          const double &close[])
  {
   ResetLastError();

   if(!ArraySetAsSeries(open, false))
     {
      PrintFormat("Failed to set direct indexing for the Open array. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ArraySetAsSeries(high, false))
     {
      PrintFormat("Failed to set direct indexing for the High array. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ArraySetAsSeries(low, false))
     {
      PrintFormat("Failed to set direct indexing for the Low array. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ArraySetAsSeries(close, false))
     {
      PrintFormat("Failed to set direct indexing for the Close array. Error: %d",
                  GetLastError());
      return false;
     }

   return true;
  }
  
//+------------------------------------------------------------------+
//| Returns true if the bar opens with a valid gap down              |
//+------------------------------------------------------------------+
bool IsGapDownAtIndex(const int i,
                      const double &open[],
                      const double &low[])
  {
//--- Index 0 has no previous bar for comparison
   if(i < 1)
      return false;

//--- Measure the distance from the current open to the previous low
   double currentOpen = open[i];
   double previousLow = low[i - 1];
   double gapSize     = previousLow - currentOpen;

//--- Accept only gaps that meet the configured minimum size
   return gapSize >= minimumGapSizePoints * _Point;
  }

//+------------------------------------------------------------------+
//| Returns true if the bar opens with a valid gap up                |
//+------------------------------------------------------------------+
bool IsGapUpAtIndex(const int i,
                    const double &open[],
                    const double &high[])
  {
//--- Index 0 has no previous bar for comparison
   if(i < 1)
      return false;

//--- Measure the distance from the previous high to the current open
   double currentOpen  = open[i];
   double previousHigh = high[i - 1];
   double gapSize      = currentOpen - previousHigh;

//--- Accept only gaps that meet the configured minimum size
   return gapSize >= minimumGapSizePoints * _Point;
  }
  
//+------------------------------------------------------------------+
//| Returns true if a bullish Oops signal exists at the index        |
//+------------------------------------------------------------------+
bool IsBullishOopsSignalAtIndex(const int i,
                                const double &open[],
                                const double &high[],
                                const double &low[],
                                const double &close[])
  {
//--- Index 0 has no previous bar for gap comparison
   if(i < 1)
      return false;

//--- Path 1: the gap-down bar fills the gap by its own close
   if(IsGapDownAtIndex(i, open, low))
     {
      double previousLow = low[i - 1];

      if(close[i] >= previousLow)
         return true;
     }

//--- Path 2: search recent bars for an earlier valid gap down
   int startGapIndex = MathMax(1, i - maxGapValidityBars);

   for(int j = startGapIndex; j < i; j++)
     {
      if(!IsGapDownAtIndex(j, open, low))
         continue;

      double previousLow = low[j - 1];

//--- The current bar must close back at or above the gap boundary
      if(close[i] < previousLow)
         continue;

//--- Reject the signal if the gap was already filled earlier
      bool alreadyFilledEarlier = false;

      for(int k = j; k < i; k++)
        {
         if(close[k] >= previousLow)
           {
            alreadyFilledEarlier = true;
            break;
           }
        }

      if(!alreadyFilledEarlier)
         return true;
     }

   return false;
  }
  
//+------------------------------------------------------------------+
//| Returns true if a bearish Oops signal exists at the index        |
//+------------------------------------------------------------------+
bool IsBearishOopsSignalAtIndex(const int i,
                                const double &open[],
                                const double &high[],
                                const double &low[],
                                const double &close[])
  {
//--- Index 0 has no previous bar for gap comparison
   if(i < 1)
      return false;

//--- Path 1: the gap-up bar fills the gap by its own close
   if(IsGapUpAtIndex(i, open, high))
     {
      double previousHigh = high[i - 1];

      if(close[i] <= previousHigh)
         return true;
     }

//--- Path 2: search recent bars for an earlier valid gap up
   int startGapIndex = MathMax(1, i - maxGapValidityBars);

   for(int j = startGapIndex; j < i; j++)
     {
      if(!IsGapUpAtIndex(j, open, high))
         continue;

      double previousHigh = high[j - 1];

//--- The current bar must close back at or below the gap boundary
      if(close[i] > previousHigh)
         continue;

//--- Reject the signal if the gap was already filled earlier
      bool alreadyFilledEarlier = false;

      for(int k = j; k < i; k++)
        {
         if(close[k] <= previousHigh)
           {
            alreadyFilledEarlier = true;
            break;
           }
        }

      if(!alreadyFilledEarlier)
         return true;
     }

   return false;
  }
  
//+------------------------------------------------------------------+
//| Maps all completed historical Oops signals                       |
//+------------------------------------------------------------------+
void MapHistoricalOopsSignals(const int rates_total,
                              const double &open[],
                              const double &high[],
                              const double &low[],
                              const double &close[])
  {
   if(rates_total < 3)
      return;

//--- Index 0 has no previous bar and cannot produce a signal
   bullishSignalBuffer[0] = EMPTY_VALUE;
   bearishSignalBuffer[0] = EMPTY_VALUE;

//--- Evaluate completed historical bars only
   for(int i = 1; i < rates_total - 1; i++)
     {
      bullishSignalBuffer[i] = EMPTY_VALUE;
      bearishSignalBuffer[i] = EMPTY_VALUE;

      if(IsBullishOopsSignalAtIndex(i, open, high, low, close))
         bullishSignalBuffer[i] = low[i] - (10 * _Point);

      if(IsBearishOopsSignalAtIndex(i, open, high, low, close))
         bearishSignalBuffer[i] = high[i] + (10 * _Point);
     }

//--- Keep the current forming bar empty
   int currentIndex = rates_total - 1;

   bullishSignalBuffer[currentIndex] = EMPTY_VALUE;
   bearishSignalBuffer[currentIndex] = EMPTY_VALUE;
  }
  
//+------------------------------------------------------------------+
//| Configures the chart appearance                                  |
//+------------------------------------------------------------------+
bool ConfigureChartAppearance()
  {
   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite))
     {
      PrintFormat("Failed to set the chart background color. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_SHOW_GRID, false))
     {
      PrintFormat("Failed to hide the chart grid. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_MODE, CHART_CANDLES))
     {
      PrintFormat("Failed to set the chart to candlestick mode. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack))
     {
      PrintFormat("Failed to set the chart foreground color. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrSeaGreen))
     {
      PrintFormat("Failed to set the bullish candle color. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlack))
     {
      PrintFormat("Failed to set the bearish candle color. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CHART_UP, clrSeaGreen))
     {
      PrintFormat("Failed to set the chart-up color. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack))
     {
      PrintFormat("Failed to set the chart-down color. Error: %d",
                  GetLastError());
      return false;
     }

   ResetLastError();
   ChartRedraw(0);

   int errorCode = GetLastError();

   if(errorCode != ERR_SUCCESS)
     {
      PrintFormat("Chart redraw reported an error. Error: %d", errorCode);
      return false;
     }

   return true;
  }
  
//+------------------------------------------------------------------+
//| Updates the signal on the latest completed bar                   |
//+------------------------------------------------------------------+
void UpdateLatestOopsSignalOnNewBar(const int rates_total,
                                    const double &open[],
                                    const double &high[],
                                    const double &low[],
                                    const double &close[])
  {
   if(rates_total < 3)
      return;

   int signalIndex  = rates_total - 2;
   int currentIndex = rates_total - 1;

//--- Clear the latest completed and current bars before recalculation
   bullishSignalBuffer[signalIndex]  = EMPTY_VALUE;
   bearishSignalBuffer[signalIndex]  = EMPTY_VALUE;
   bullishSignalBuffer[currentIndex] = EMPTY_VALUE;
   bearishSignalBuffer[currentIndex] = EMPTY_VALUE;

//--- Evaluate the latest completed bar using the established rules
   if(IsBullishOopsSignalAtIndex(signalIndex, open, high, low, close))
      bullishSignalBuffer[signalIndex] = low[signalIndex] - (10 * _Point);

   if(IsBearishOopsSignalAtIndex(signalIndex, open, high, low, close))
      bearishSignalBuffer[signalIndex] = high[signalIndex] + (10 * _Point);
  }
  
//+------------------------------------------------------------------+