#ifndef __HIGHLOW3CANDLE_HELPER_MQH__
#define __HIGHLOW3CANDLE_HELPER_MQH__

//This file contains helper functions to init / release / get data from HL3 indicator and draw it on chart

#include <Anhnt/Configuration/EnumConfiguration.mqh>
#include <Anhnt/Configuration/IndicatorConfiguration.mqh>
#include <Anhnt/Configuration/ColorConfiguration.mqh>

#include <Anhnt/Utilities/TimeFrame.mqh>

// DATA handles (for signal / compare)
int g_hl3_data_handles[];

//--------------------------------------------------
// Init DATA HL3 for all TF
//--------------------------------------------------
void InitHL3_DataSystem()
{
   ArrayResize(g_hl3_data_handles, g_num_supported_timeframes);
   for(int i = 0; i < g_num_supported_timeframes; i++)
   {
      g_hl3_data_handles[i] = iCustom(
         _Symbol,
         g_supported_timeframes[i],
         "Anhnt\\HighLow3Candle",
         inp_EA_HighAppliedPrice,
         inp_EA_LowAppliedPrice,
         inp_EA_HL3_LookbackBars,
         true //for data calculation not base on inp_EA_HL3_Show_Line (data only)
      );

      if(g_hl3_data_handles[i] == INVALID_HANDLE)
      {
         Print("From HL3 DATA ERROR | TF=", EnumToString(g_supported_timeframes[i]));
      }
   }
}

void ReleaseHL3System()
{
   for(int i = 0; i < ArraySize(g_hl3_data_handles); i++)
   {
      if(g_hl3_data_handles[i] != INVALID_HANDLE)
         IndicatorRelease(g_hl3_data_handles[i]);
   }
   
   //================ Remove HL3 chart objects =================
   for(int i = 0; i < g_num_supported_timeframes; i++)
   {
      ENUM_TIMEFRAMES tf = g_supported_timeframes[i];
      string tf_name = GetTimeframeShortName(tf);

      ObjectDelete(0, "HL3_H_" + tf_name);//Take care of name here,it must be same as DrawHL3Line function
      ObjectDelete(0, "HL3_L_" + tf_name);//Take care of name here,it must be same as DrawHL3Line function
   }
   ChartRedraw(0);
}
// Get HL3 values (DATA ONLY)
bool GetHL3_Value(int tf_index, double &high3, double &low3)
{
   static double last_high3[];
   static double last_low3[];

   //================ Validate index =================
   if(tf_index < 0 || tf_index >= ArraySize(g_hl3_data_handles))
      return false;

   int handle = g_hl3_data_handles[tf_index];
   if(handle == INVALID_HANDLE)
      return false;

   ENUM_TIMEFRAMES tf = g_supported_timeframes[tf_index];

   //================ Force history load =================
   int bars = Bars(_Symbol, tf);
   if(bars <= inp_EA_HL3_LookbackBars)
   {
      Print("Debug from GetHL3_Value ERROR | Not enough bars | TF=", EnumToString(tf),
            " | bars=", bars);
      return false;
   }

   //================ Init cache =================
   if(ArraySize(last_high3) != g_num_supported_timeframes)
   {
      ArrayResize(last_high3, g_num_supported_timeframes);
      ArrayResize(last_low3,  g_num_supported_timeframes);
      ArrayInitialize(last_high3, EMPTY_VALUE);
      ArrayInitialize(last_low3,  EMPTY_VALUE);
   }

   //================ Try copy buffer =================
   double bufHigh[1];
   double bufLow[1];
   ArraySetAsSeries(bufHigh, true);
   ArraySetAsSeries(bufLow, true);

   bool data_found = false;

   //Chat GPT add here: scan closed bars backward (market closed safe)
   int max_scan = MathMin(50, bars - 1);

   for(int shift = 1; shift <= max_scan; shift++)
   {
      if(CopyBuffer(handle, 0, shift, 1, bufHigh) <= 0)
         continue;

      if(CopyBuffer(handle, 1, shift, 1, bufLow) <= 0)
         continue;

      if(bufHigh[0] == EMPTY_VALUE || bufLow[0] == EMPTY_VALUE)
         continue;

      high3 = bufHigh[0];
      low3  = bufLow[0];

      //Chat GPT add here: cache last valid value
      last_high3[tf_index] = high3;
      last_low3[tf_index]  = low3;

      data_found = true;
      break;
   }

   //================ Fallback to cached =================
   if(!data_found)
   {
      if(last_high3[tf_index] != EMPTY_VALUE &&
         last_low3[tf_index]  != EMPTY_VALUE)
      {
         //Chat GPT add here: use cached HL3 when market closed
         high3 = last_high3[tf_index];
         low3  = last_low3[tf_index];
         return true;
      }

      return false;
   }

   // Print(
   //    "DEBUG from GetHL3_Value| TF=", EnumToString(tf),
   //    " | high3=", DoubleToString(high3, _Digits),
   //    " | low3=",  DoubleToString(low3,  _Digits)
   // );

   return true;
}

void DrawHL3_Line(
   string tf_name,
   double high_value,
   double low_value,
   color  high_color,
   color  low_color,
   int    line_width,
   int    line_style
)
{
   string high_name = "HL3_H_" + tf_name;
   string low_name  = "HL3_L_" + tf_name;

   //================ HIGH =================
   if(ObjectFind(0, high_name) < 0)
   {
      ObjectCreate(0, high_name, OBJ_HLINE, 0, 0, high_value);
      ObjectSetInteger(0, high_name, OBJPROP_COLOR, high_color);
      ObjectSetInteger(0, high_name, OBJPROP_WIDTH, line_width);
      ObjectSetInteger(0, high_name, OBJPROP_STYLE, line_style);      
      ObjectSetInteger(0, high_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, high_name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   }
   else
   {
      ObjectSetDouble(0, high_name, OBJPROP_PRICE, high_value);
   }

   //================ LOW =================
   if(ObjectFind(0, low_name) < 0)
   {
      ObjectCreate(0, low_name, OBJ_HLINE, 0, 0, low_value);
      ObjectSetInteger(0, low_name, OBJPROP_COLOR, low_color);
      ObjectSetInteger(0, low_name, OBJPROP_WIDTH, line_width);
      ObjectSetInteger(0, low_name, OBJPROP_STYLE, line_style);
      ObjectSetInteger(0, low_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, low_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, low_name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   }
   else
   {
      ObjectSetDouble(0, low_name, OBJPROP_PRICE, low_value);
   }
}

void DrawHL3_AllTimeframes()
{   
   //Track how many TF successfully draw
   int draw_count = 0;

   for(int i = 0; i < g_num_supported_timeframes; i++)
   {
      double high3, low3;

      if(!GetHL3_Value(i, high3, low3))
      {
         //Chat GPT add here: Minimal debug to know which TF fails
         // Print("Debug from DrawHL3_AllTimeframes HL3 SKIP TF=", 
         //          EnumToString(g_supported_timeframes[i]),
         //          " | high3= ",
         //          DoubleToString(high3,_Digits),
         //          " | low3= ",
         //          DoubleToString(low3,_Digits) 
         //       );
         continue;
      }
      string tf_name = GetTimeframeShortName(g_supported_timeframes[i]);

      DrawHL3_Line(
         tf_name,
         high3,
         low3,
         inp_EA_HL3_High_Color,
         inp_EA_HL3_Low_Color,
         inp_EA_HL3_Width,
         inp_EA_HL3_Style
      );

      draw_count++;
   }
   //Single summary print instead of spam
   // Print("Debug from DrawHL3_AllTimeframes HL3 DRAW SUMMARY | total_draw= ", draw_count);
}

void UpdateHL3_Visual()
{
   //Chat GPT add here: If user disable HL3 → remove objects and stop drawing
   if(!inp_EA_HL3_Show_Line)
   {
      //Remove HL3 objects only (do NOT release data handles)
      for(int i = 0; i < g_num_supported_timeframes; i++)
      {
         ENUM_TIMEFRAMES tf = g_supported_timeframes[i];
         string tf_name = GetTimeframeShortName(tf);

         ObjectDelete(0, "HL3_H_" + tf_name);
         ObjectDelete(0, "HL3_L_" + tf_name);
      }

      ChartRedraw(0); //Chat GPT add here: Force refresh after delete
      return;
   }

   //Update HL3 lines for all supported TF
   DrawHL3_AllTimeframes();
}
void UpdateHL3_System()
{
   //Chat GPT add here: Remember init state to avoid recreating handles
   static bool hl3_initialized = false;

   //================ INIT DATA =================
   if(!hl3_initialized)
   {
      InitHL3_DataSystem();
      hl3_initialized = true;
   }
   //================ UPDATE VISUAL =================
   //Chat GPT add here: Always redraw HL3 lines (safe + lightweight)
   UpdateHL3_Visual();   
}
#endif __HIGHLOW3CANDLE_HELPER_MQH__
