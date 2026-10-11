//+------------------------------------------------------------------+
//|                                  Ind_Volatility_Trailing.mq5     |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|          Link https://www.mql5.com/en/articles/23910             |
//+------------------------------------------------------------------+
#property copyright   "Open Source"
#property version     "2.10"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Long Trailing Stop (Diagnostic)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Short Trailing Stop (Diagnostic)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

input int    InpTRPeriod      = 14;   // Simple TR Period
input double InpTRMult        = 2.0;  // Volatility Multiplier

double BufferLong[];
double BufferShort[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufferLong, INDICATOR_DATA);
   SetIndexBuffer(1, BufferShort, INDICATOR_DATA);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpTRPeriod + 1);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpTRPeriod + 1);

   return INIT_SUCCEEDED;
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
   if(rates_total <= InpTRPeriod + 1) return 0;
   //--- Explicitly set chronological array indexing (bar 0 = oldest, bar N-1 = newest)
    ArraySetAsSeries(high, false);
    ArraySetAsSeries(low, false);
    ArraySetAsSeries(close, false);
    ArraySetAsSeries(BufferLong, false);
    ArraySetAsSeries(BufferShort, false);
   int start = (prev_calculated > InpTRPeriod + 1) ? prev_calculated - 1 : InpTRPeriod + 1;
   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      BufferLong[i]  = EMPTY_VALUE;
      BufferShort[i] = EMPTY_VALUE;
      //--- Calculate Simple TR over completed bars preceding bar i
      double tr_sum = 0.0;
      for(int k = 0; k < InpTRPeriod; k++)
        {
         int bar_idx = (i - 1) - k; 
         if(bar_idx <= 0) break;
         double h  = high[bar_idx];
         double l  = low[bar_idx];
         double pc = close[bar_idx - 1];
         double tr = MathMax(h - l, MathMax(MathAbs(h - pc), MathAbs(l - pc)));
         tr_sum += tr;
        }
      double tr_avg = tr_sum / InpTRPeriod;
      double offset = tr_avg * InpTRMult;
      //--- Diagnostic anchor: close price of completed bar (i - 1)
       double candidate_long  = close[i - 1] - offset;
       double candidate_short = close[i - 1] + offset;
      //--- Directional ratchet progression: Long lines can only advance upwards
       if(i > InpTRPeriod + 1 && BufferLong[i - 1] != EMPTY_VALUE && close[i - 1] > BufferLong[i - 1])
        {
         BufferLong[i] = MathMax(candidate_long, BufferLong[i - 1]);
        }
       else
        {
         BufferLong[i] = candidate_long;
        }
      //--- Directional ratchet progression: Short lines can only advance downwards
       if(i > InpTRPeriod + 1 && BufferShort[i - 1] != EMPTY_VALUE && close[i - 1] < BufferShort[i - 1])
        {
         BufferShort[i] = MathMin(candidate_short, BufferShort[i - 1]);
        }
       else
        {
         BufferShort[i] = candidate_short;
        }
     }

   return rates_total;
  }