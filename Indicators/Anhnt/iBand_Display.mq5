//This is MQL5\Indicators\Anhnt\iBand_Display.mq5
#ifndef __IBAND_DISPLAY_MQ5__
#define __IBAND_DISPLAY_MQ5__

#ifndef __IBAND_DISPLAY_MQ5_PROPERTIES_PART__
#define __IBAND_DISPLAY_MQ5_PROPERTIES_PART__
//==================================================
// Indicator properties
   #property indicator_chart_window
   #property indicator_buffers 3
   #property indicator_plots   3

   //--- plot Middle
   #property indicator_label1  "Middle"
   #property indicator_type1   DRAW_LINE

   //--- plot Upper
   #property indicator_label2  "Upper"
   #property indicator_type2   DRAW_LINE

   //--- plot Lower
   #property indicator_label3  "Lower"
   #property indicator_type3   DRAW_LINE
#endif // __IBAND_DISPLAY_MQ5_PROPERTIES_PART__

#ifndef __IBAND_DISPLAY_MQ5_INPUT_PART__
#define __IBAND_DISPLAY_MQ5_INPUT_PART__
//==================================================
// Input parameters
//==================================================
   input int      InpBBPeriod      = 14;
   input ENUM_APPLIED_PRICE inp_Applied_Price   = PRICE_MEDIAN;
   input double   InpBBDeviation   = 2.0;
   input int      InpBBShift       = 0;

   input color    InpMiddleColor   = clrYellow;
   input color    InpUpperColor    = clrYellow;
   input color    InpLowerColor    = clrYellow;

   input int      InpMiddleWidth   = 2;
   input int      InpUpperWidth    = 2;
   input int      InpLowerWidth    = 2;

   input bool inp_BB_Show_Upper   = true;
   input bool inp_BB_Show_Middle  = true;
   input bool inp_BB_Show_Lower   = true;

   input ENUM_LINE_STYLE InpMiddleStyle = STYLE_DOT;
   input ENUM_LINE_STYLE InpUpperStyle  = STYLE_DOT;
   input ENUM_LINE_STYLE InpLowerStyle  = STYLE_DOT;
#endif // __IBAND_DISPLAY_MQ5_INPUT_PART__

//==================================================
#include <Anhnt/Configuration/NamingConfiguration.mqh>
//==================================================
// Indicator buffers
//==================================================
double MiddleBuffer[];
double UpperBuffer[];
double LowerBuffer[];

//==================================================
// Global variables
//==================================================
int g_bb_handle = INVALID_HANDLE;

//https://www.mql5.com/en/docs/indicators/ibands

//+------------------------------------------------------------------+
int OnInit()
   {
      //==================================================
      // Set buffers
      //==================================================
      SetIndexBuffer(BASE_LINE,  MiddleBuffer, INDICATOR_DATA);
      SetIndexBuffer(UPPER_BAND, UpperBuffer,  INDICATOR_DATA);
      SetIndexBuffer(LOWER_BAND, LowerBuffer,  INDICATOR_DATA);

      ArraySetAsSeries(MiddleBuffer, true);
      ArraySetAsSeries(UpperBuffer,  true);
      ArraySetAsSeries(LowerBuffer,  true);   

      //==================================================   
      // Apply INPUT values to plots (runtime-safe way)
      //==================================================
      PlotIndexSetInteger(BASE_LINE,  PLOT_LINE_COLOR, InpMiddleColor);
      PlotIndexSetInteger(UPPER_BAND, PLOT_LINE_COLOR, InpUpperColor);
      PlotIndexSetInteger(LOWER_BAND, PLOT_LINE_COLOR, InpLowerColor);

      PlotIndexSetInteger(BASE_LINE,  PLOT_LINE_STYLE, InpMiddleStyle);
      PlotIndexSetInteger(UPPER_BAND, PLOT_LINE_STYLE, InpUpperStyle);
      PlotIndexSetInteger(LOWER_BAND, PLOT_LINE_STYLE, InpLowerStyle);

      PlotIndexSetInteger(BASE_LINE,  PLOT_LINE_WIDTH, InpMiddleWidth);
      PlotIndexSetInteger(UPPER_BAND, PLOT_LINE_WIDTH, InpUpperWidth);
      PlotIndexSetInteger(LOWER_BAND, PLOT_LINE_WIDTH, InpLowerWidth);   
      //New added
      PlotIndexSetDouble(BASE_LINE,  PLOT_EMPTY_VALUE, EMPTY_VALUE);
      PlotIndexSetDouble(UPPER_BAND, PLOT_EMPTY_VALUE, EMPTY_VALUE);
      PlotIndexSetDouble(LOWER_BAND, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      //SETTING BARS TO START PLOTTING
      //https://www.mql5.com/en/articles/17096
      PlotIndexSetInteger(BASE_LINE, PLOT_DRAW_BEGIN, InpBBPeriod);
      PlotIndexSetInteger(UPPER_BAND, PLOT_DRAW_BEGIN, InpBBPeriod);
      PlotIndexSetInteger(LOWER_BAND, PLOT_DRAW_BEGIN, InpBBPeriod);

      PlotIndexSetInteger(
            BASE_LINE,
            PLOT_DRAW_TYPE,
            inp_BB_Show_Middle ? DRAW_LINE : DRAW_NONE
      );

      PlotIndexSetInteger(
            UPPER_BAND,
            PLOT_DRAW_TYPE,
            inp_BB_Show_Upper ? DRAW_LINE : DRAW_NONE
      );

      PlotIndexSetInteger(
            LOWER_BAND,
            PLOT_DRAW_TYPE,
            inp_BB_Show_Lower ? DRAW_LINE : DRAW_NONE
      );
      PlotIndexSetString(BASE_LINE, PLOT_LABEL,
         SMT_PREFIX + SMT_BB_NAME + "(" + "Middle" + ")");
      PlotIndexSetString(UPPER_BAND, PLOT_LABEL,
         SMT_PREFIX + SMT_BB_NAME + "(" + "Upper" + ")");
      PlotIndexSetString(LOWER_BAND, PLOT_LABEL,
         SMT_PREFIX + SMT_BB_NAME + "(" + "Lower" + ")");


      IndicatorSetInteger(INDICATOR_DIGITS, 0); // Use chart digits _Digits

      string short_name = SMT_PREFIX + SMT_BB_NAME +
                  "(" + (string)InpBBPeriod + "," +
                  DoubleToString(InpBBDeviation, 1) + ")";  
      
      
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);
      //==================================================
      // Create iBands handle
      //==================================================
      g_bb_handle = iBands(
         _Symbol,
         _Period,
         InpBBPeriod,
         InpBBShift,
         InpBBDeviation,
         inp_Applied_Price
      );
      if(g_bb_handle == INVALID_HANDLE)
      {
         Print("From Indicator iBand_Display INIT FAILED. Unable to create iBands handle. GetLastError = ", GetLastError());
         return INIT_FAILED;
      }
      ChartRedraw();   
      Print("From Indicator iBand_Display INIT SUCCESS");
      return INIT_SUCCEEDED;
   }
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,
   const int prev_calculated,
   const datetime &time[],
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const long &tick_volume[],
   const long &volume[],
   const int &spread[]
)
   {
      //https://www.mql5.com/en/docs/indicators/ibands
      if(rates_total <= InpBBPeriod)   // Not enough bars to calculate the indicator
         return 0;
      int calculated = BarsCalculated(g_bb_handle);//--- wait until iBands is ready
      if(calculated <= InpBBPeriod)
         return prev_calculated; 
         int to_copy = MathMin(calculated, rates_total);
         // Print("DEBUG from OnCalculate in Indicator After Waiting BarsCalculated | Symbol=", _Symbol,
         //       " | Period=", _Period);
         // Print(" | BarsCalculated(iBands)=", calculated,
         //       " | Number of Bar in Chart= ",Bars(_Symbol,_Period));  

      //--- This block is executed when the indicator is initially attached to a chart
      if(prev_calculated == 0)
      {
         ArrayInitialize(MiddleBuffer, EMPTY_VALUE);
         ArrayInitialize(UpperBuffer,  EMPTY_VALUE);
         ArrayInitialize(LowerBuffer,  EMPTY_VALUE);
         //Copy all available data at once
         CopyBuffer(g_bb_handle, BASE_LINE,  0, to_copy, MiddleBuffer);
         CopyBuffer(g_bb_handle, UPPER_BAND, 0, to_copy, UpperBuffer);
         CopyBuffer(g_bb_handle, LOWER_BAND, 0, to_copy, LowerBuffer);      

         // Print("DEBUG from OnCalculate First Initial | Symbol=", _Symbol,
         //       " | Period=", _Period,
         //       " | BarsCalculated(iBands)=", calculated);
         return rates_total;    
      }   
      //--- This block is executed on every new bar open
      if(prev_calculated != rates_total && prev_calculated != 0)
      {   
      // NEXT RUNS:
      // Only update the newest bar (index 0).
      // Do NOT shift arrays manually (series handles it).
      //==================================================
         double tmp[1];
         if(CopyBuffer(g_bb_handle, BASE_LINE, 0, 1, tmp) > 0)
         MiddleBuffer[0] = tmp[0];

         if(CopyBuffer(g_bb_handle, UPPER_BAND, 0, 1, tmp) > 0)
            UpperBuffer[0] = tmp[0];

         if(CopyBuffer(g_bb_handle, LOWER_BAND, 0, 1, tmp) > 0)
            LowerBuffer[0] = tmp[0];
         // Print("DEBUG from OnCalculate New Bar Detected | Symbol=", _Symbol,
         //       " | Period=", _Period,
         //       " | prev_calculated=", prev_calculated,
         //       " | rates_total=", rates_total);
         
         return rates_total;      
      }  
      return rates_total;
   }
//+------------------------------------------------------------------+

bool FillArraysFromBuffers(
   double &base_values  [],   // MiddleBuffer
   double &upper_values [],   // UpperBuffer
   double &lower_values [],   // LowerBuffer
   int shift,                 // shift = 0 → realtime
   int ind_handle,
   int amount
)
   {
      // NOTE:
      // Currently not used.
      // Kept for future helper / EA logic as planned.

      ResetLastError();
      if(CopyBuffer(ind_handle, BASE_LINE,  -shift, amount, base_values) < 0)
         return false;
      if(CopyBuffer(ind_handle, UPPER_BAND, -shift, amount, upper_values) < 0)
         return false;
      if(CopyBuffer(ind_handle, LOWER_BAND, -shift, amount, lower_values) < 0)
         return false;
      return true;
   }
#endif // __IBAND_DISPLAY_MQ5__



