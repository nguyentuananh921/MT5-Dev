//+------------------------------------------------------------------+
//|                EMA.mq5                              |
//|                Visual EMA Indicator                               |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//---- FAST EMA
#property indicator_label1  "F-EMA"
#property indicator_type1   DRAW_LINE

//---- SLOW EMA
#property indicator_label2  "S-EMA"
#property indicator_type2   DRAW_LINE
//---- LONG EMA
#property indicator_label3  "L-EMA"    
#property indicator_type3   DRAW_LINE

//--------------------------------------------------
#include <Vendors/Anhnt/Configuration/NamingConfiguration.mqh>
//--------------------------------------------------
// Inputs (controlled by EA)
//--------------------------------------------------
input int                inp_Fast_EMA_Period = 14;
input int                inp_Slow_EMA_Period = 26;
input int                inp_Long_EMA_Period = 50;
input ENUM_APPLIED_PRICE inp_Applied_Price   = PRICE_MEDIAN;

input bool               inp_Fast_EMA_Show   = true;
input bool               inp_Slow_EMA_Show   = true;
input bool               inp_Long_EMA_Show   = true;

input color              inp_fast_EMA_Color  = clrDarkViolet;
input color              inp_slow_EMA_Color  = clrDarkViolet;
input color              inp_long_EMA_Color  = clrDarkViolet;

input ENUM_LINE_STYLE    inp_fast_EMA_Style  = STYLE_SOLID;
input ENUM_LINE_STYLE    inp_slow_EMA_Style  = STYLE_DASHDOT;
input ENUM_LINE_STYLE    inp_long_EMA_Style  = STYLE_DOT;
input int                inp_EMA_Width       = 1;

// true  = update EMA only on closed bar
// false = realtime EMA (bar 0)
input bool               inp_EMA_Update_OnClosedBar = true;

//--------------------------------------------------
// Buffers
//--------------------------------------------------
double g_fast_ema_buf[];
double g_slow_ema_buf[];
double g_long_ema_buf[];

//--------------------------------------------------
// Handles
//--------------------------------------------------
int g_fast_handle = INVALID_HANDLE;
int g_slow_handle = INVALID_HANDLE;
int g_long_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Indicator initialization                                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_fast_ema_buf, INDICATOR_DATA);
   SetIndexBuffer(1, g_slow_ema_buf, INDICATOR_DATA);
   SetIndexBuffer(2, g_long_ema_buf, INDICATOR_DATA);

   ArraySetAsSeries(g_fast_ema_buf, true);
   ArraySetAsSeries(g_slow_ema_buf, true);
   ArraySetAsSeries(g_long_ema_buf, true);
   
   //--- EMA visibility No Change to Buffers, Plot based on input
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, inp_Fast_EMA_Show  ? DRAW_LINE : DRAW_NONE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, inp_Slow_EMA_Show  ? DRAW_LINE : DRAW_NONE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, inp_Long_EMA_Show ? DRAW_LINE : DRAW_NONE);
   
   PlotIndexSetString(0, PLOT_LABEL,
      SMT_PREFIX + SMT_EMA_NAME + "(" + (string)inp_Fast_EMA_Period + ")");

   PlotIndexSetString(1, PLOT_LABEL,
      SMT_PREFIX + SMT_EMA_NAME + "(" + (string)inp_Slow_EMA_Period + ")");

   PlotIndexSetString(2, PLOT_LABEL,
      SMT_PREFIX + SMT_EMA_NAME + "(" + (string)inp_Long_EMA_Period + ")");
   
   string short_name = SMT_PREFIX + SMT_EMA_NAME + "(" +
              (string)inp_Fast_EMA_Period + "," +
              (string)inp_Slow_EMA_Period + "," +
              (string)inp_Long_EMA_Period + ")";

   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   IndicatorSetInteger(INDICATOR_DIGITS, 0); // Use chart digits _Digits
   //--- FAST EMA style
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, inp_fast_EMA_Color);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, inp_fast_EMA_Style);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, inp_EMA_Width);

   //--- SLOW EMA style
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, inp_slow_EMA_Color);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, inp_slow_EMA_Style);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, inp_EMA_Width);

   //--- LONG EMA style
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, inp_long_EMA_Color);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, inp_long_EMA_Style);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, inp_EMA_Width);   
   
   //--- create EMA handles
   g_fast_handle = iMA(_Symbol, _Period, inp_Fast_EMA_Period, 0, MODE_EMA, inp_Applied_Price);
   g_slow_handle = iMA(_Symbol, _Period, inp_Slow_EMA_Period, 0, MODE_EMA, inp_Applied_Price);
   g_long_handle = iMA(_Symbol, _Period, inp_Long_EMA_Period, 0, MODE_EMA, inp_Applied_Price);

   if(g_fast_handle == INVALID_HANDLE || g_slow_handle == INVALID_HANDLE || g_long_handle == INVALID_HANDLE)
   {
      Print("Debug from EMA_Display Oninit: Failed to create EMA handles");
      return INIT_FAILED;
   }

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
   int min_rates = MathMax(inp_Fast_EMA_Period, inp_Slow_EMA_Period);
   if(rates_total < min_rates)
      return 0;

   //--- Copy EMA data
   if(CopyBuffer(g_fast_handle, 0, 0, rates_total, g_fast_ema_buf) <= 0)
      return prev_calculated;

   if(CopyBuffer(g_slow_handle, 0, 0, rates_total, g_slow_ema_buf) <= 0)
      return prev_calculated;
   if(CopyBuffer(g_long_handle, 0, 0, rates_total, g_long_ema_buf) <= 0)
      return prev_calculated;   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Indicator deinitialization                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_fast_handle != INVALID_HANDLE)
      IndicatorRelease(g_fast_handle);

   if(g_slow_handle != INVALID_HANDLE)
      IndicatorRelease(g_slow_handle);
   if(g_long_handle != INVALID_HANDLE)
      IndicatorRelease(g_long_handle);
}
