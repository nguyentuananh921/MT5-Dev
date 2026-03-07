//+------------------------------------------------------------------+
//|                                          ALGLIB_FilterDemo.mq5 |
//|                                    Copyright 2026, Clemence Benjamin|
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   10

//--- include ALGLIB (adjust path if needed)
//#include <Math/Alglib/alglib.mqh>
#include <Math/Alglib/alglib.mqh> 

//--- plot definitions
#property indicator_label1  "Close"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlack
#property indicator_width1  1

#property indicator_label2  "Baseline Fast EMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_width2  1

#property indicator_label3  "Baseline Slow EMA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_width3  1

#property indicator_label4  "SMA Filtered"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_width4  1

#property indicator_label5  "EMA Filtered"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDodgerBlue
#property indicator_width5  1

#property indicator_label6  "LRMA Filtered"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrange
#property indicator_width6  1

#property indicator_label7  "SSA Trend"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrMagenta
#property indicator_width7  1

#property indicator_label8  "Spline Derivative (scaled)"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBrown
#property indicator_width8  1

#property indicator_label9  "Baseline Crossover Signals"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrBlue
#property indicator_width9  1

#property indicator_label10 "Filtered Crossover Signals"
#property indicator_type10  DRAW_ARROW
#property indicator_color10 clrRed
#property indicator_width10 1

//--- input parameters
input int      FastMAPeriod   = 5;           // Fast MA period
input int      SlowMAPeriod   = 20;          // Slow MA period
input int      FilterWindow   = 14;          // Window for SMA/LRMA and EMA alpha (alpha=2/(period+1))
input int      SSAWindow       = 30;          // Window for SSA (must be < data length)
input int      SSARank         = 5;           // Number of SSA components to keep (rank)
input double   SplineDerivScale= 10.0;        // Scaling factor for spline derivative (for visibility)
input int      LookbackBars    = 500;         // Number of recent bars to process (speed optimization)

//--- indicator buffers
double closeBuffer[];
double baselineFastBuffer[];
double baselineSlowBuffer[];
double smaFilteredBuffer[];
double emaFilteredBuffer[];
double lrmaFilteredBuffer[];
double ssaTrendBuffer[];
double splineDerivBuffer[];
double baselineSignalBuffer[];
double filteredSignalBuffer[];

//--- handles for built-in iMA (for baseline)
int fastMAHandle, slowMAHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- set index buffers
   SetIndexBuffer(0, closeBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, baselineFastBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, baselineSlowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, smaFilteredBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, emaFilteredBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, lrmaFilteredBuffer, INDICATOR_DATA);
   SetIndexBuffer(6, ssaTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(7, splineDerivBuffer, INDICATOR_DATA);
   SetIndexBuffer(8, baselineSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(9, filteredSignalBuffer, INDICATOR_DATA);

   //--- set arrow codes (159 = small circle)
   PlotIndexSetInteger(8, PLOT_ARROW, 159);
   PlotIndexSetInteger(9, PLOT_ARROW, 159);
   PlotIndexSetDouble(8, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(9, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   //--- indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME, "ALGLIB Filter Demo (Optimized)");

   //--- get handles for baseline MAs
   fastMAHandle = iMA(_Symbol, _Period, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   slowMAHandle = iMA(_Symbol, _Period, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(fastMAHandle == INVALID_HANDLE || slowMAHandle == INVALID_HANDLE)
      return(INIT_FAILED);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(fastMAHandle != INVALID_HANDLE)  IndicatorRelease(fastMAHandle);
   if(slowMAHandle != INVALID_HANDLE)  IndicatorRelease(slowMAHandle);
}

//+------------------------------------------------------------------+
//| Helper to convert vector to CRowDouble and back after filter    |
//+------------------------------------------------------------------+
void ApplySMA(vector<double> &data, int window)
{
   CRowDouble row(data);
   CAlglib::FilterSMA(row, (int)data.Size(), window);
   data = row.ToVector();
}

void ApplyEMA(vector<double> &data, int window)
{
   double alpha = 2.0 / (window + 1.0);
   CRowDouble row(data);
   CAlglib::FilterEMA(row, (int)data.Size(), alpha);
   data = row.ToVector();
}

void ApplyLRMA(vector<double> &data, int window)
{
   CRowDouble row(data);
   CAlglib::FilterLRMA(row, (int)data.Size(), window);
   data = row.ToVector();
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
   //--- Determine the range of bars we need to process
   int startIdx = (rates_total > LookbackBars) ? rates_total - LookbackBars : 0;
   int len = rates_total - startIdx;

   //--- Need enough data for the longest period
   int maxPeriod = MathMax(SlowMAPeriod, MathMax(FilterWindow, SSAWindow));
   if(len < maxPeriod)
   {
      // Not enough bars in the lookback window – fill with EMPTY and return
      for(int i = startIdx; i < rates_total; i++)
      {
         smaFilteredBuffer[i] = EMPTY_VALUE;
         emaFilteredBuffer[i] = EMPTY_VALUE;
         lrmaFilteredBuffer[i] = EMPTY_VALUE;
         ssaTrendBuffer[i]    = EMPTY_VALUE;
         splineDerivBuffer[i] = EMPTY_VALUE;
      }
      ArrayInitialize(baselineSignalBuffer, EMPTY_VALUE);
      ArrayInitialize(filteredSignalBuffer, EMPTY_VALUE);
      return(rates_total);
   }

   //--- Copy close prices to buffer 0 (for plotting)
   for(int i = 0; i < rates_total; i++)
      closeBuffer[i] = close[i];

   //--- Get baseline MAs (they already cover all bars)
   if(CopyBuffer(fastMAHandle, 0, 0, rates_total, baselineFastBuffer) <= 0) return(0);
   if(CopyBuffer(slowMAHandle, 0, 0, rates_total, baselineSlowBuffer) <= 0) return(0);

   //--- Create a vector of close prices for the lookback window
   vector<double> vecClose(len);
   for(int i = 0; i < len; i++)
      vecClose[i] = close[startIdx + i];

   //--- 1) SMA Filter
   vector<double> vecSMA = vecClose;
   ApplySMA(vecSMA, FilterWindow);
   for(int i = 0; i < len; i++)
      smaFilteredBuffer[startIdx + i] = vecSMA[i];

   //--- 2) EMA Filter
   vector<double> vecEMA = vecClose;
   ApplyEMA(vecEMA, FilterWindow);
   for(int i = 0; i < len; i++)
      emaFilteredBuffer[startIdx + i] = vecEMA[i];

   //--- 3) LRMA Filter
   vector<double> vecLRMA = vecClose;
   ApplyLRMA(vecLRMA, FilterWindow);
   for(int i = 0; i < len; i++)
      lrmaFilteredBuffer[startIdx + i] = vecLRMA[i];

   //--- 4) SSA Trend
   CSSAModel ssa;
   CAlglib::SSACreate(ssa);
   CRowDouble priceRow(vecClose);                     // convert once
   CAlglib::SSAAddSequence(ssa, priceRow);
   CAlglib::SSASetAlgoTopKRealtime(ssa, SSARank);
   CAlglib::SSASetWindow(ssa, SSAWindow);
   CRowDouble trend, noise;
   CAlglib::SSAAnalyzeLast(ssa, len, trend, noise);

   if(trend.Size() == len)
   {
      vector<double> vecTrend = trend.ToVector();
      for(int i = 0; i < len; i++)
         ssaTrendBuffer[startIdx + i] = vecTrend[i];
   }
   else
   {
      for(int i = 0; i < len; i++)
         ssaTrendBuffer[startIdx + i] = EMPTY_VALUE;
   }

   //--- 5) Spline derivative
   // X axis = bar index within the lookback window (0..len-1)
   vector<double> xVec(len);
   for(int i = 0; i < len; i++) xVec[i] = i;

   vector<double> priceVec = priceRow.ToVector();   // already from vecClose

   double xArr[], priceArr[];
   ArrayResize(xArr, len);
   ArrayResize(priceArr, len);
   for(int i = 0; i < len; i++)
   {
      xArr[i] = xVec[i];
      priceArr[i] = priceVec[i];
   }

   CSpline1DInterpolantShell spline;
   CAlglib::Spline1DBuildCubic(xArr, priceArr, len, 0, 0.0, 0, 0.0, spline);

   for(int i = 0; i < len; i++)
   {
      double val, deriv, deriv2;
      CAlglib::Spline1DDiff(spline, i, val, deriv, deriv2);
      splineDerivBuffer[startIdx + i] = close[startIdx + i] + deriv * SplineDerivScale;
   }

   //--- 6) Crossover signals (only within lookback window)
   ArrayInitialize(baselineSignalBuffer, EMPTY_VALUE);
   ArrayInitialize(filteredSignalBuffer, EMPTY_VALUE);

   double alphaFast = 2.0 / (FastMAPeriod + 1.0);
   double alphaSlow = 2.0 / (SlowMAPeriod + 1.0);

   // For the filtered crossover, we need a fast and slow EMA of vecEMA.
   // We'll compute them recursively.
   vector<double> fastFilteredVec(len);
   vector<double> slowFilteredVec(len);

   if(len > 0)
   {
      fastFilteredVec[0] = vecEMA[0];
      slowFilteredVec[0] = vecEMA[0];
   }
   for(int i = 1; i < len; i++)
   {
      fastFilteredVec[i] = alphaFast * vecEMA[i] + (1 - alphaFast) * fastFilteredVec[i-1];
      slowFilteredVec[i] = alphaSlow * vecEMA[i] + (1 - alphaSlow) * slowFilteredVec[i-1];
   }

   // Scan for crossovers (need at least one previous bar)
   for(int i = 1; i < len; i++)
   {
      int idx = startIdx + i;

      // Baseline crossover signals (using the built‑in MA buffers)
      if(baselineFastBuffer[idx] > baselineSlowBuffer[idx] && baselineFastBuffer[idx-1] <= baselineSlowBuffer[idx-1])
         baselineSignalBuffer[idx] = low[idx] - 10 * _Point; // buy arrow below price
      if(baselineFastBuffer[idx] < baselineSlowBuffer[idx] && baselineFastBuffer[idx-1] >= baselineSlowBuffer[idx-1])
         baselineSignalBuffer[idx] = high[idx] + 10 * _Point; // sell arrow above price

      // Filtered crossover signals
      if(fastFilteredVec[i] > slowFilteredVec[i] && fastFilteredVec[i-1] <= slowFilteredVec[i-1])
         filteredSignalBuffer[idx] = low[idx] - 20 * _Point; // buy
      if(fastFilteredVec[i] < slowFilteredVec[i] && fastFilteredVec[i-1] >= slowFilteredVec[i-1])
         filteredSignalBuffer[idx] = high[idx] + 20 * _Point; // sell
   }

   //--- Fill any bars before the lookback window with EMPTY_VALUE for the filtered lines
   for(int i = 0; i < startIdx; i++)
   {
      smaFilteredBuffer[i] = EMPTY_VALUE;
      emaFilteredBuffer[i] = EMPTY_VALUE;
      lrmaFilteredBuffer[i] = EMPTY_VALUE;
      ssaTrendBuffer[i]    = EMPTY_VALUE;
      splineDerivBuffer[i] = EMPTY_VALUE;
   }

   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+