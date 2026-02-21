//+------------------------------------------------------------------+
//|                 HighLow3Candle.mq5                                |
//|                 High / Low of N candles                           |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//---- HIGH
#property indicator_label1  "HL3 High"
#property indicator_type1   DRAW_LINE

//---- LOW
#property indicator_label2  "HL3 Low"
#property indicator_type2   DRAW_LINE

//--------------------------------------------------
// Inputs (controlled by EA)
//--------------------------------------------------
input ENUM_APPLIED_PRICE inp_HighAppliedPrice = PRICE_HIGH;
input ENUM_APPLIED_PRICE inp_LowAppliedPrice  = PRICE_LOW;
input int                inp_LookbackBars     = 3;

input bool               inp_HL3_Show          = true;

input color              inp_HighLineColor    = clrDeepPink;
input color              inp_LowLineColor     = clrLime;

input int                inp_HighLow_Width    = 2;
input ENUM_LINE_STYLE    inp_HighLow_Style    = STYLE_DOT;

//--------------------------------------------------
// Buffers
//--------------------------------------------------
double g_high_buf[];
double g_low_buf[];

//+------------------------------------------------------------------+
//| Indicator initialization                                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_high_buf, INDICATOR_DATA);
   SetIndexBuffer(1, g_low_buf,  INDICATOR_DATA);

   ArraySetAsSeries(g_high_buf, true);
   ArraySetAsSeries(g_low_buf,  true);

   PlotIndexSetInteger(0, PLOT_LINE_COLOR, inp_HighLineColor);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, inp_HighLow_Style);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, inp_HighLow_Width);

   PlotIndexSetInteger(1, PLOT_LINE_COLOR, inp_LowLineColor);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, inp_HighLow_Style);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, inp_HighLow_Width);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Indicator calculation                                            |
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
   if(rates_total < inp_LookbackBars)
      return 0;

   for(int i = 0; i < rates_total; i++)
   {
      if(i + inp_LookbackBars > rates_total)
      {
         g_high_buf[i] = EMPTY_VALUE;
         g_low_buf[i]  = EMPTY_VALUE;
         continue;
      }

      double highest = high[i];
      double lowest  = low[i];

      for(int j = 0; j < inp_LookbackBars; j++)
      {
         highest = MathMax(highest, high[i + j]);
         lowest  = MathMin(lowest,  low[i + j]);
      }

      g_high_buf[i] = highest;
      g_low_buf[i]  = lowest;
   }

   //--- Show / Hide
   if(!inp_HL3_Show)
   {
      for(int i = 0; i < rates_total; i++)
      {
         g_high_buf[i] = EMPTY_VALUE;
         g_low_buf[i]  = EMPTY_VALUE;
      }
   }

   return rates_total;
}
