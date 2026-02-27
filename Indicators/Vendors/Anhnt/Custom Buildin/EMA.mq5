//+------------------------------------------------------------------+
//|                EMA.mq5                                           |
//|                Visual EMA Indicator                              |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
//Declare properties
   //---- FAST EMA-0
      #property indicator_label1  "F-EMA"
      #property indicator_type1   DRAW_LINE
   //---- SLOW EMA-1
      #property indicator_label2  "S-EMA"
      #property indicator_type2   DRAW_LINE
   //---- LONG EMA-2
      #property indicator_label3  "L-EMA"    
      #property indicator_type3   DRAW_LINE

   //---- PRICE CROSS FAST EMA-3
      #property indicator_label4  "PF-BUY"
      #property indicator_type4   DRAW_ARROW
   //---- PRICE CROSS FAST EMA-4
      #property indicator_label5  "PF-SELL"
      #property indicator_type5   DRAW_ARROW

   //---- PRICE CROSS SLOW EMA-5
      #property indicator_label6  "PS-BUY"
      #property indicator_type6   DRAW_ARROW

   //---- PRICE CROSS SLOW EMA-6
      #property indicator_label7  "PS-SELL"
      #property indicator_type7   DRAW_ARROW

   //---- PRICE CROSS LONG EMA-7
      #property indicator_label8  "PL-BUY"
      #property indicator_type8   DRAW_ARROW

   //---- PRICE CROSS LONG EMA-8
      #property indicator_label9  "PL-SELL"
      #property indicator_type9   DRAW_ARROW

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

   input bool               inp_price_fast_buy_EMA_Show     = true;
   input bool               inp_price_fast_sell_EMA_Show    = true;
   input bool               inp_price_slow_buy_EMA_Show     = true;
   input bool               inp_price_slow_sell_EMA_Show    = true;
   input bool               inp_price_long_buy_EMA_Show     = true;
   input bool               inp_price_long_sell_EMA_Show   = true;

   input color              inp_fast_EMA_Color     = clrDarkViolet;
   input color              inp_slow_EMA_Color     = clrDarkViolet;
   input color              inp_long_EMA_Color     = clrDarkViolet;
   input color              inp_cross_up_color     = clrLime;
   input color              inp_cross_down_color   = clrRed;

   input ENUM_LINE_STYLE    inp_fast_EMA_Style  = STYLE_SOLID;
   input ENUM_LINE_STYLE    inp_slow_EMA_Style  = STYLE_DASHDOT;
   input ENUM_LINE_STYLE    inp_long_EMA_Style  = STYLE_DOT;
   input int                inp_EMA_Width       = 1;

// true  = update EMA only on closed bar
// false = realtime EMA (bar 0)
//input bool               inp_EMA_Update_OnClosedBar = true;

//--------------------------------------------------
// Buffers
//--------------------------------------------------
   double g_fast_ema_buf[];
   double g_slow_ema_buf[];
   double g_long_ema_buf[];

   double g_price_fast_buy_ema_buf[];
   double g_price_fast_sell_ema_buf[];

   double g_price_slow_buy_ema_buf[];
   double g_price_slow_sell_ema_buf[];

   double g_price_long_buy_ema_buf[];
   double g_price_long_sell_ema_buf[];
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
   //Setting index Buffer
      SetIndexBuffer(0, g_fast_ema_buf, INDICATOR_DATA);
      SetIndexBuffer(1, g_slow_ema_buf, INDICATOR_DATA);
      SetIndexBuffer(2, g_long_ema_buf, INDICATOR_DATA);

      SetIndexBuffer(3, g_price_fast_buy_ema_buf, INDICATOR_DATA);
      SetIndexBuffer(4, g_price_fast_sell_ema_buf, INDICATOR_DATA);

      SetIndexBuffer(5, g_price_slow_buy_ema_buf, INDICATOR_DATA);
      SetIndexBuffer(6, g_price_slow_sell_ema_buf, INDICATOR_DATA);

      SetIndexBuffer(7, g_price_long_buy_ema_buf, INDICATOR_DATA);
      SetIndexBuffer(8, g_price_long_sell_ema_buf, INDICATOR_DATA);
   
   //Array Index Buffer
      ArraySetAsSeries(g_fast_ema_buf, true);
      ArraySetAsSeries(g_slow_ema_buf, true);
      ArraySetAsSeries(g_long_ema_buf, true);
      ArraySetAsSeries(g_price_fast_buy_ema_buf, true);
      ArraySetAsSeries(g_price_fast_sell_ema_buf, true);
      ArraySetAsSeries(g_price_slow_buy_ema_buf, true);
      ArraySetAsSeries(g_price_slow_sell_ema_buf, true);
      ArraySetAsSeries(g_price_long_buy_ema_buf, true);
      ArraySetAsSeries(g_price_long_sell_ema_buf, true);   
   
   //--- EMA visibility No Change to Buffers, Plot based on input
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, inp_Fast_EMA_Show  ? DRAW_LINE : DRAW_NONE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, inp_Slow_EMA_Show  ? DRAW_LINE : DRAW_NONE);
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, inp_Long_EMA_Show ? DRAW_LINE : DRAW_NONE);
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, inp_price_fast_buy_EMA_Show  ? DRAW_ARROW : DRAW_NONE);
      PlotIndexSetInteger(4, PLOT_DRAW_TYPE, inp_price_fast_sell_EMA_Show ? DRAW_ARROW : DRAW_NONE);
      PlotIndexSetInteger(5, PLOT_DRAW_TYPE, inp_price_slow_buy_EMA_Show  ? DRAW_ARROW : DRAW_NONE);
      PlotIndexSetInteger(6, PLOT_DRAW_TYPE, inp_price_slow_sell_EMA_Show ? DRAW_ARROW : DRAW_NONE);
      PlotIndexSetInteger(7, PLOT_DRAW_TYPE, inp_price_long_buy_EMA_Show  ? DRAW_ARROW : DRAW_NONE);
      PlotIndexSetInteger(8, PLOT_DRAW_TYPE, inp_price_long_sell_EMA_Show ? DRAW_ARROW : DRAW_NONE);
   
   //Setting Plot Label
      PlotIndexSetString(0, PLOT_LABEL,
         SMT_PREFIX + SMT_EMA_NAME + "(" + (string)inp_Fast_EMA_Period + ")");
      PlotIndexSetString(3, PLOT_LABEL,
         SMT_PREFIX + "P-Up" + SMT_EMA_NAME + "(" + (string)inp_Fast_EMA_Period + ")");
      PlotIndexSetString(4, PLOT_LABEL,
         SMT_PREFIX + "P-Down" + SMT_EMA_NAME + "(" + (string)inp_Fast_EMA_Period + ")");
      PlotIndexSetString(1, PLOT_LABEL,
         SMT_PREFIX + SMT_EMA_NAME + "(" + (string)inp_Slow_EMA_Period + ")");
      PlotIndexSetString(5, PLOT_LABEL,
         SMT_PREFIX + "P-Up" + SMT_EMA_NAME + "(" + (string)inp_Slow_EMA_Period + ")");
      PlotIndexSetString(6, PLOT_LABEL,
         SMT_PREFIX + "P-Down" + SMT_EMA_NAME + "(" + (string)inp_Slow_EMA_Period + ")");
      PlotIndexSetString(2, PLOT_LABEL,
         SMT_PREFIX + SMT_EMA_NAME + "(" + (string)inp_Long_EMA_Period + ")");
      PlotIndexSetString(7, PLOT_LABEL,
         SMT_PREFIX + "P-Up" + SMT_EMA_NAME + "(" + (string)inp_Long_EMA_Period + ")");
      PlotIndexSetString(8, PLOT_LABEL,
         SMT_PREFIX + "P-Down" + SMT_EMA_NAME + "(" + (string)inp_Long_EMA_Period + ")");
   //Setting Indicator name   
      string short_name = SMT_PREFIX + SMT_EMA_NAME + "(" +
               (string)inp_Fast_EMA_Period + "," +
               (string)inp_Slow_EMA_Period + "," +
               (string)inp_Long_EMA_Period + ")";

      IndicatorSetString(INDICATOR_SHORTNAME, short_name);
      //IndicatorSetInteger(INDICATOR_DIGITS, 0); // Use chart digits _Digits
   //Styling
      //--- FAST EMA style
         PlotIndexSetInteger(0, PLOT_LINE_COLOR, inp_fast_EMA_Color);
         PlotIndexSetInteger(0, PLOT_LINE_STYLE, inp_fast_EMA_Style);
         PlotIndexSetInteger(0, PLOT_LINE_WIDTH, inp_EMA_Width);      

         PlotIndexSetInteger(3, PLOT_LINE_COLOR, inp_cross_up_color);
         PlotIndexSetInteger(3, PLOT_ARROW, 233);

         PlotIndexSetInteger(4, PLOT_LINE_COLOR, inp_cross_down_color); 
         PlotIndexSetInteger(4, PLOT_ARROW, 234);      
      //--- SLOW EMA style
         PlotIndexSetInteger(1, PLOT_LINE_COLOR, inp_slow_EMA_Color);
         PlotIndexSetInteger(1, PLOT_LINE_STYLE, inp_slow_EMA_Style);
         PlotIndexSetInteger(1, PLOT_LINE_WIDTH, inp_EMA_Width);

         PlotIndexSetInteger(5, PLOT_LINE_COLOR, inp_cross_up_color);         
         //PlotIndexSetInteger(5, PLOT_LINE_WIDTH, inp_EMA_Width);
         PlotIndexSetInteger(5, PLOT_ARROW, 233);
         
         PlotIndexSetInteger(6, PLOT_LINE_COLOR, inp_cross_down_color);         
         //PlotIndexSetInteger(6, PLOT_LINE_WIDTH, inp_EMA_Width);      
         PlotIndexSetInteger(6, PLOT_ARROW, 234); 
      //--- LONG EMA style
         PlotIndexSetInteger(2, PLOT_LINE_COLOR, inp_long_EMA_Color);
         PlotIndexSetInteger(2, PLOT_LINE_STYLE, inp_long_EMA_Style);
         PlotIndexSetInteger(2, PLOT_LINE_WIDTH, inp_EMA_Width); 

         PlotIndexSetInteger(7, PLOT_LINE_COLOR, inp_cross_up_color);         
         //PlotIndexSetInteger(7, PLOT_LINE_WIDTH, inp_EMA_Width);
         PlotIndexSetInteger(7, PLOT_ARROW, 233);
         
         PlotIndexSetInteger(8, PLOT_LINE_COLOR, inp_cross_down_color);         
         //PlotIndexSetInteger(8, PLOT_LINE_WIDTH, inp_EMA_Width);       
         PlotIndexSetInteger(8, PLOT_ARROW, 234);
      //Clear data
         PlotIndexSetDouble(0,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(1,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(2,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(3,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(4,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(5,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(6,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(7,   PLOT_EMPTY_VALUE, EMPTY_VALUE);
         PlotIndexSetDouble(8,   PLOT_EMPTY_VALUE, EMPTY_VALUE);         
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
   // int OnCalculate(const int rates_total,
   //                 const int prev_calculated,
   //                 const datetime &time[],
   //                 const double &open[],
   //                 const double &high[],
   //                 const double &low[],
   //                 const double &close[],
   //                 const long &tick_volume[],
   //                 const long &volume[],
   //                 const int &spread[])
   // {
   //    int min_rates = MathMax(inp_Fast_EMA_Period, inp_Slow_EMA_Period);
   //    if(rates_total < min_rates)
   //       return 0;
   //    //--- Copy EMA data
   //    if(CopyBuffer(g_fast_handle, 0, 0, rates_total, g_fast_ema_buf) <= 0)
   //       return prev_calculated;
   //    if(CopyBuffer(g_slow_handle, 0, 0, rates_total, g_slow_ema_buf) <= 0)
   //       return prev_calculated;
   //    if(CopyBuffer(g_long_handle, 0, 0, rates_total, g_long_ema_buf) <= 0)
   //       return prev_calculated;   
   //    return rates_total;
// }
// int OnCalculate(const int rates_total,
//                 const int prev_calculated,
//                 const datetime &time[],
//                 const double &open[],
//                 const double &high[],
//                 const double &low[],
//                 const double &close[],
//                 const long &tick_volume[],
//                 const long &volume[],
//                 const int &spread[])
// {
//    if(rates_total < inp_Long_EMA_Period)
//       return 0;
//    if (BarsCalculated(g_fast_handle) < rates_total ||BarsCalculated(g_slow_handle) < rates_total||BarsCalculated(g_long_handle) < rates_total)
//    {
//       Print("Before Calculate Chart TF = ",Period(),"Bar Calculate:=",BarsCalculated(g_fast_handle),"PreCalculate:",prev_calculated, "  rates_total=", rates_total);
//       return(prev_calculated);

//    } 
//    Print("After waiting Calculate Chart TF = ", Period()," PreCalculate=",prev_calculated, "  rates_total=", rates_total);
//    //--- Copy EMA data
//       if(CopyBuffer(g_fast_handle, 0, 0, rates_total, g_fast_ema_buf) <= 0)
//          return 0;

//       if(CopyBuffer(g_slow_handle, 0, 0, rates_total, g_slow_ema_buf) <= 0)
//          return 0;

//       if(CopyBuffer(g_long_handle, 0, 0, rates_total, g_long_ema_buf) <= 0)
//          return 0;
//       //Fixing EMA buffer direction
//          // ArraySetAsSeries(g_fast_ema_buf, true);
//          // ArraySetAsSeries(g_slow_ema_buf, true);
//          // ArraySetAsSeries(g_long_ema_buf, true);
//    //Clear data
//       ArrayInitialize(g_price_fast_buy_ema_buf,  EMPTY_VALUE);
//       ArrayInitialize(g_price_fast_sell_ema_buf, EMPTY_VALUE);
//       ArrayInitialize(g_price_slow_buy_ema_buf,  EMPTY_VALUE);
//       ArrayInitialize(g_price_slow_sell_ema_buf, EMPTY_VALUE);
//       ArrayInitialize(g_price_long_buy_ema_buf,  EMPTY_VALUE);
//       ArrayInitialize(g_price_long_sell_ema_buf, EMPTY_VALUE);      
//    //--- Scan all history bar
//    double offset = 20 * _Point;

//       int start = 0;

//       if(prev_calculated == 0)
//          start = 0;
//       else
//          start = prev_calculated - 1;  //Only Calculate Last Bar

//       //for(int index_candle = rates_total - 1; index_candle >= 1; index_candle--)
//       for(int index_candle=start;index_candle<rates_total; index_candle++)
//       {             
         
//          datetime candle_time = time[index_candle];
//          double close_value   = close[index_candle];
//          double open_value    = open[index_candle];
//          double high_value    = high[index_candle];
//          double low_value     = low[index_candle];
//          double ema_fast      = g_fast_ema_buf[index_candle];
//          double ema_slow      = g_slow_ema_buf[index_candle];
//          double ema_long      = g_long_ema_buf [index_candle];
//          //Cross up EMA fast
//             if(open_value <= ema_fast && close_value > ema_fast)
//                {
//                   g_price_fast_buy_ema_buf[index_candle]=low_value - offset;
//                   g_price_fast_sell_ema_buf[index_candle]=EMPTY_VALUE;                    
//                   //Print debug
//                      if(g_price_fast_sell_ema_buf[index_candle] == EMPTY_VALUE)
//                         Print("Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuyFastV: ",DoubleToString(g_price_fast_buy_ema_buf[index_candle],0),
//                               " SellFastV: EMPTY");                    
//                      else
//                         Print("Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuyFastV: ",DoubleToString(g_price_fast_buy_ema_buf[index_candle],0),
//                               " SellFastV: ",DoubleToString(g_price_fast_sell_ema_buf[index_candle],0));
//                }
//          //Cross Down EMA fast
//             if(close_value < ema_fast && open_value >= ema_fast)
//                {
//                   g_price_fast_buy_ema_buf[index_candle]=EMPTY_VALUE;
//                   g_price_fast_sell_ema_buf[index_candle]=high_value + offset;
//                   //Print debug
//                      if(g_price_fast_buy_ema_buf[index_candle] == EMPTY_VALUE)
//                         Print("Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuyFastV: EMPTY",
//                               " SellFastV: ",DoubleToString(g_price_fast_sell_ema_buf[index_candle],0));                    
//                      else
//                         Print(" Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuyFastV: ",DoubleToString(g_price_fast_buy_ema_buf[index_candle],0),
//                               " SellFastV: ",DoubleToString(g_price_fast_sell_ema_buf[index_candle],0));                 
//                }
//          //Cross up EMA Slow
//             if(open_value <= ema_slow && close_value > ema_slow)
//                {
//                   g_price_slow_buy_ema_buf[index_candle]=low_value - offset;
//                   g_price_slow_sell_ema_buf[index_candle]=EMPTY_VALUE;
                  
//                //Print debug
//                   if(g_price_slow_sell_ema_buf[index_candle] == EMPTY_VALUE)
//                         Print("Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuySlowV: ",DoubleToString(g_price_slow_buy_ema_buf[index_candle],0),
//                               " SellSlowV: EMPTY");                    
//                      else
//                         Print(" Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuyFastV: ",DoubleToString(g_price_fast_buy_ema_buf[index_candle],0),
//                               " SellFastV: ",DoubleToString(g_price_fast_sell_ema_buf[index_candle],0));              
//                }
//          //Cross Down EMA Slow
//             if(close_value < ema_slow && open_value >= ema_slow)
//                {
//                   g_price_slow_buy_ema_buf[index_candle]  = EMPTY_VALUE;
//                   g_price_slow_sell_ema_buf[index_candle] = high_value + offset; 
//                   //Print debug
//                   if(g_price_slow_buy_ema_buf[index_candle] == EMPTY_VALUE)
//                         Print("Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuySlowV: EMPTY",
//                               " SellSlowV:",DoubleToString(g_price_slow_sell_ema_buf[index_candle],0));                    
//                      else
//                         Print(" Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuySlowV: ",DoubleToString(g_price_slow_buy_ema_buf[index_candle],0),
//                               " SellSlowV: ",DoubleToString(g_price_slow_sell_ema_buf[index_candle],0)); 
//                } 
//           //Cross up EMA Long
//             if(open_value <= ema_long && close_value > ema_long)
//                {
//                   g_price_long_buy_ema_buf[index_candle]=low_value - offset;
//                   g_price_long_sell_ema_buf[index_candle]=EMPTY_VALUE;

//                   if(g_price_long_sell_ema_buf[index_candle] == EMPTY_VALUE)
//                         Print("Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_long,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuySlowV: ",DoubleToString(g_price_long_buy_ema_buf[index_candle],0),
//                               " SellSlowV: EMPTY");                    
//                      else
//                         Print(" Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " ELV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuySlowV: ",DoubleToString(g_price_long_buy_ema_buf[index_candle],0),
//                               " SellSlowV: ",DoubleToString(g_price_long_sell_ema_buf[index_candle],0));                                   
//                }
//          //Cross Down EMA Long
//             if(close_value < ema_long && open_value >= ema_long)
//                {  
//                   g_price_long_buy_ema_buf[index_candle] =EMPTY_VALUE;
//                   g_price_long_sell_ema_buf[index_candle]=high_value + offset;
//                   if(g_price_long_buy_ema_buf[index_candle] == EMPTY_VALUE)
//                         Print("Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " EFV: ",DoubleToString(ema_long,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuySlowV: EMPTY",
//                               " SellSlowV: ",DoubleToString(g_price_long_sell_ema_buf[index_candle],0));                    
//                      else
//                         Print(" Time: ",TimeToString(candle_time),
//                               " Offset: ",offset,
//                               " Index: ",index_candle,
//                               " ELV: ",DoubleToString(ema_fast,0),
//                               " O: ",DoubleToString(open_value,0),
//                               " C: ",DoubleToString(close_value,0),
//                               " BuySlowV: ",DoubleToString(g_price_long_buy_ema_buf[index_candle],0),
//                               " SellSlowV: ",DoubleToString(g_price_long_sell_ema_buf[index_candle],0));                   
//                } 
//                return rates_total;
//    }

//    //--- Clear Bar[0]
//       g_price_fast_buy_ema_buf[0]  = EMPTY_VALUE;
//       g_price_fast_sell_ema_buf[0] = EMPTY_VALUE;

//       g_price_slow_buy_ema_buf[0]  = EMPTY_VALUE;
//       g_price_slow_sell_ema_buf[0] = EMPTY_VALUE;

//       g_price_long_buy_ema_buf[0]  = EMPTY_VALUE;
//       g_price_long_sell_ema_buf[0] = EMPTY_VALUE;

//    return rates_total;
// }
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
//+------------------------------------------------------------------+
//| Detect price position vs EMA (single candle logic)               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void DetectPriceCrossSingleBar(int index,
                              const datetime &time[],
                              const double &high[],
                              const double &low[],
                              const double &open[],
                              const double &close[],                              
                              const double &ema_buf[],
                              double &buy_buf[],
                              double &sell_buf[])
{
   //Chat GPT add here for safety check
   if(index < 0)
      return;

   //Rest Buffer value
   buy_buf[index]  = EMPTY_VALUE;
   sell_buf[index] = EMPTY_VALUE;

   double ema_value   = ema_buf[index];

   //Chat GPT add here for EMA validity check
   if(ema_value == EMPTY_VALUE)
      return;
   
   
   datetime candle_time = time[index];
   double close_value = close[index];
   double open_value  = open[index];
   double high_value  = high[index];
   double low_value   = low[index];

   //Chat GPT add here for arrow offset outside candle body
   double offset = 20 * _Point;

   //--- Cross Up (single candle logic)
   if(open_value <= ema_value && close_value > ema_value)
   {
      //Chat GPT modify here for placing arrow below candle
      buy_buf[index]  = low_value - offset;
      sell_buf[index] = EMPTY_VALUE;
      //Print debug
      Print(" Time: ",TimeToString(candle_time),
            " Offset: ",offset,
            " Index: ",index,
            " Ema Value: ",ema_value,
            " Open Value: ",open_value,
            " Close Value: ",close_value,
            " Buy Buffer: ",buy_buf[index]);     

      return;
   }
   //--- Cross Down (single candle logic)
   if(close_value < ema_value && open_value >= ema_value)
   {
      //Chat GPT modify here for placing arrow above candle
      sell_buf[index] = high_value + offset;
      buy_buf[index]  = EMPTY_VALUE;
      Print(" Time: ",TimeToString(candle_time),
            " Offset: ",offset,
            " Index: ",index,
            " Ema Value: ",ema_value,
            " Open Value: ",open_value,
            " Close Value: ",close_value,
            " Sell Buffer: ",sell_buf[index]);        
      return;
   }
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
   //--- đủ bar chưa
   if(rates_total < inp_Long_EMA_Period)
      return 0;

   //--- chờ EMA handle sẵn sàng
   if(BarsCalculated(g_fast_handle) < rates_total ||
      BarsCalculated(g_slow_handle) < rates_total ||
      BarsCalculated(g_long_handle) < rates_total)
   {
      return prev_calculated;
   }
   Print("After waiting Calculate Chart TF = ", Period()," PreCalculate=",prev_calculated, "  rates_total=", rates_total);

   //--- copy EMA (copy full 1 lần, tối ưu sau)
   if(CopyBuffer(g_fast_handle, 0, 0, rates_total, g_fast_ema_buf) <= 0)
      return prev_calculated;

   if(CopyBuffer(g_slow_handle, 0, 0, rates_total, g_slow_ema_buf) <= 0)
      return prev_calculated;

   if(CopyBuffer(g_long_handle, 0, 0, rates_total, g_long_ema_buf) <= 0)
      return prev_calculated;

   //=========================================================
   // CALCULATE RANGE
   //=========================================================
   int start;

   // first load -> tính full history
   if(prev_calculated == 0)
   {
      start = rates_total - 2;  // cần i+1
   }
   else
   {
      // chỉ tính bar mới
      start = rates_total - prev_calculated;

      if(start > 2)
         start = 2;
   }

   if(start < 1)
      start = 1;

   //=========================================================
   // LOOP (series mode → đi ngược)
   //=========================================================
   for(int i = start; i >= 0; i--)
   {
      DetectPriceCrossSingleBar(
         i, time, high, low, open, close,
         g_fast_ema_buf,
         g_price_fast_buy_ema_buf,
         g_price_fast_sell_ema_buf
      );

      DetectPriceCrossSingleBar(
         i, time, high, low, open, close,
         g_slow_ema_buf,
         g_price_slow_buy_ema_buf,
         g_price_slow_sell_ema_buf
      );

      DetectPriceCrossSingleBar(
         i, time, high, low, open, close,
         g_long_ema_buf,
         g_price_long_buy_ema_buf,
         g_price_long_sell_ema_buf
      );
   }

   return rates_total;
}