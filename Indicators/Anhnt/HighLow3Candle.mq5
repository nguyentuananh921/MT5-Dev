//+------------------------------------------------------------------+
//| Indicators\Anhnt\HighLow3Candle.mq5                                               |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "HL3 High"
#property indicator_type1   DRAW_LINE

#property indicator_label2  "HL3 Low"
#property indicator_type2   DRAW_LINE

//--------------------------------------------------
// Inputs
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
#include <Anhnt/Utilities/PriceUtilities.mqh>
#include <Anhnt/Configuration/NamingConfiguration.mqh>
double g_high_buf[];
double g_low_buf[];

//+------------------------------------------------------------------+
int OnInit()
{
   ChartSetInteger(0, CHART_SHOW_VOLUMES, false);
   SetIndexBuffer(0, g_high_buf, INDICATOR_DATA);
   SetIndexBuffer(1, g_low_buf,  INDICATOR_DATA);
   ArraySetAsSeries(g_high_buf,true);
   ArraySetAsSeries(g_low_buf,true);

   ArrayInitialize(g_high_buf,EMPTY_VALUE);
   ArrayInitialize(g_low_buf, EMPTY_VALUE);
   
   // Add Here to set Plot Draw Type

   // Show or Hide plots based on inp_HL3_Show
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,inp_HL3_Show? DRAW_LINE : DRAW_NONE)  ;
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,inp_HL3_Show? DRAW_LINE : DRAW_NONE)  ;
   
   PlotIndexSetInteger(0, PLOT_SHOW_DATA, true);
   PlotIndexSetInteger(1, PLOT_SHOW_DATA, true);
   
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,inp_HighLineColor);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,inp_HighLow_Width);
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,inp_HighLow_Style);

   PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,inp_LowLineColor);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,inp_HighLow_Width);
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,inp_HighLow_Style);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);   
   string short_name = SMT_PREFIX + SMT_HL3_NAME + "(" +
              (string)inp_LookbackBars + ")";

   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   IndicatorSetInteger(INDICATOR_DIGITS, 0); // Use chart digits _Digits
   PlotIndexSetString(0, PLOT_LABEL,
      SMT_PREFIX + SMT_HL3_NAME + "(" + "High" + ")");
      
   PlotIndexSetString(1, PLOT_LABEL,
      SMT_PREFIX + SMT_HL3_NAME + "(" + "Low" + ")");
   ArrayInitialize(g_high_buf,EMPTY_VALUE);
   ArrayInitialize(g_low_buf, EMPTY_VALUE);

   return INIT_SUCCEEDED;
}
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
   //Remember to set arrays as series
   ArraySetAsSeries(open,  true);
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time,  true);
   //--- Only recalc when a NEW bar appears
   if(prev_calculated > 0 && rates_total == prev_calculated)
      return rates_total;

   // if(!inp_HL3_Show)
   // {
   //    ArrayInitialize(g_high_buf,EMPTY_VALUE);
   //    ArrayInitialize(g_low_buf, EMPTY_VALUE);
   //    return rates_total;
   // }
   int max_index = MathMin(inp_LookbackBars, rates_total - 1);
   //--- Initialize with the first CLOSED candle (index = 1)
   //This is the base value for Max/Min comparison
   double high_value = GetAppliedPrice(inp_HighAppliedPrice,1,open,high,low,close);
   double low_value  = GetAppliedPrice(inp_LowAppliedPrice ,1,open,high,low,close);   

   // Print("Debug Init Value | index=1 | high_value=", high_value,
   //       " | low_value=", low_value); // Chat GPT add here
   for(int i=2;i<=max_index;i++)
   {
       double applied_high = GetAppliedPrice(inp_HighAppliedPrice,i,open,high,low,close);
      double applied_low  = GetAppliedPrice(inp_LowAppliedPrice ,i,open,high,low,close);      
      high_value = MathMax(high_value, applied_high);
      low_value  = MathMin(low_value , applied_low );

      // Print("DEBUG INSTANCE For Loop | Symbol=", _Symbol,
      // " | Period=", _Period,
      // " | Time[1]=", TimeToString(time[1], TIME_DATE|TIME_MINUTES),
      // " | high_value=", high_value,
      // " | low_value=", low_value);
   };
   // Final debug
   // Print("DEBUG RESULT | Symbol=", _Symbol,
   //       " TF=", EnumToString(_Period),
   //       " High3=", high_value,
   //       " Low3=", low_value);
      ArrayInitialize(g_high_buf,EMPTY_VALUE);
      ArrayInitialize(g_low_buf, EMPTY_VALUE);      
      //--- Draw short horizontal segment (bars 0..Lookback)
      for(int i=0;i<=rates_total-1;i++)
      {
         g_high_buf[i] = high_value;
         g_low_buf[i]  = low_value;
      }
      return rates_total;
}
