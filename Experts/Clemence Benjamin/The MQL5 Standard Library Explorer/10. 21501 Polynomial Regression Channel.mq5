//+------------------------------------------------------------------+
//|                                          PolynomialRegressionChannel.mq5 |
//|                                    Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plot Middle
#property indicator_label1  "Middle"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plot Upper
#property indicator_label2  "Upper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plot Lower
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- include the ALGLIB library
#include <Math\Alglib\alglib.mqh>

//--- input parameters
input int      InpDegree     = 2;           // Polynomial degree
input int      InpPeriod     = 20;          // Period (number of bars)
input double   InpDeviation  = 2.0;         // Channel deviation multiplier
input ENUM_APPLIED_PRICE InpPrice = PRICE_CLOSE; // Applied price

//--- indicator buffers
double         MiddleBuffer[];
double         UpperBuffer[];
double         LowerBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check parameters
   if(InpDegree < 1)
     {
      Print("Degree must be at least 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpPeriod < InpDegree+1)
     {
      Print("Period must be larger than degree");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpDeviation < 0)
     {
      Print("Deviation multiplier cannot be negative");
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- set indicator buffers
   SetIndexBuffer(0, MiddleBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, UpperBuffer,  INDICATOR_DATA);
   SetIndexBuffer(2, LowerBuffer,  INDICATOR_DATA);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- set plot labels
   PlotIndexSetString(0, PLOT_LABEL, "Middle ("+IntegerToString(InpDegree)+")");
   PlotIndexSetString(1, PLOT_LABEL, "Upper");
   PlotIndexSetString(2, PLOT_LABEL, "Lower");

//--- done
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
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
//--- check for minimum bars
   if(rates_total < InpPeriod)
      return(0);

//--- working arrays for ALGLIB
   double x[];
   double y[];
   ArrayResize(x, InpPeriod);
   ArrayResize(y, InpPeriod);

//--- determine start bar
   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;
   if(start < InpPeriod-1)
      start = InpPeriod-1;

//--- main loop
   for(int i = start; i < rates_total; i++)
     {
      //--- fill x and y arrays (x = 0 .. period-1, y = price values)
      for(int j = 0; j < InpPeriod; j++)
        {
         x[j] = j;  // use integer indices as regressor
         y[j] = GetPrice(InpPrice, open, high, low, close, i - InpPeriod + 1 + j);
        }

      //--- create ALGLIB objects for polynomial fit
      CBarycentricInterpolantShell p;
      CPolynomialFitReportShell rep;
      int info;

      //--- call polynomial fitting (degree = InpDegree => m = InpDegree+1)
      CAlglib::PolynomialFit(x, y, InpPeriod, InpDegree+1, info, p, rep);

      //--- if fitting succeeded, compute channel
      if(info > 0)
        {
         //--- compute fitted values for all points in the window
         double fitted[];
         ArrayResize(fitted, InpPeriod);
         double sum_sq = 0.0;

         for(int j = 0; j < InpPeriod; j++)
           {
            fitted[j] = CAlglib::BarycentricCalc(p, x[j]);
            double resid = y[j] - fitted[j];
            sum_sq += resid * resid;
           }

         //--- standard deviation of residuals
         double stddev = MathSqrt(sum_sq / (InpPeriod - InpDegree - 1));  // unbiased

         //--- value at the current point (x = InpPeriod-1)
         double middle = CAlglib::BarycentricCalc(p, InpPeriod-1);
         MiddleBuffer[i] = middle;
         UpperBuffer[i]  = middle + InpDeviation * stddev;
         LowerBuffer[i]  = middle - InpDeviation * stddev;
        }
      else
        {
         //--- fitting failed, copy previous values or set empty
         if(i > 0)
           {
            MiddleBuffer[i] = MiddleBuffer[i-1];
            UpperBuffer[i]  = UpperBuffer[i-1];
            LowerBuffer[i]  = LowerBuffer[i-1];
           }
         else
           {
            MiddleBuffer[i] = 0.0;
            UpperBuffer[i]  = 0.0;
            LowerBuffer[i]  = 0.0;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Helper function to get price based on ENUM_APPLIED_PRICE         |
//+------------------------------------------------------------------+
double GetPrice(ENUM_APPLIED_PRICE price_type,
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                int index)
  {
   switch(price_type)
     {
      case PRICE_CLOSE:
         return close[index];
      case PRICE_OPEN:
         return open[index];
      case PRICE_HIGH:
         return high[index];
      case PRICE_LOW:
         return low[index];
      case PRICE_MEDIAN:
         return (high[index] + low[index]) / 2.0;
      case PRICE_TYPICAL:
         return (high[index] + low[index] + close[index]) / 3.0;
      case PRICE_WEIGHTED:
         return (high[index] + low[index] + 2*close[index]) / 4.0;
      default:
         return close[index];
     }
  }
//+------------------------------------------------------------------+

