// Utilities/timeframe.mqh
#ifndef _TIMEFRAME_MQH_
#define _TIMEFRAME_MQH_
#include <Vendors/Anhnt/Configuration/EnumConfiguration.mqh>

//extern ENUM_TIMEFRAMES g_last_chart_tf;

string GetTimeframeShortName(const ENUM_TIMEFRAMES timeframe)
  {
    switch(timeframe)
      {
        case PERIOD_M1: return "M1";
        case PERIOD_M2: return "M2";
        case PERIOD_M3: return "M3";
        case PERIOD_M4: return "M4";
        case PERIOD_M5: return "M5";
        case PERIOD_M6: return "M6";
        case PERIOD_M10: return "M10";
        case PERIOD_M12: return "M12";
        case PERIOD_M15: return "M15";
        case PERIOD_M20: return "M20";
        case PERIOD_M30: return "M30";
        case PERIOD_H1: return "H1";
        case PERIOD_H2: return "H2";
        case PERIOD_H3: return "H3";
        case PERIOD_H4: return "H4";
        case PERIOD_H6: return "H6";
        case PERIOD_H8: return "H8";
        case PERIOD_H12: return "H12";
        case PERIOD_D1: return "D1";
        case PERIOD_W1: return "W1";
        case PERIOD_MN1: return "MN1";
        default: return "";
      }
  }
  
//   bool IsChartTimeframeChanged()
//    {
//       ENUM_TIMEFRAMES current_tf = (ENUM_TIMEFRAMES)_Period;
   
//       if(current_tf != g_last_chart_tf)
//       {
//          g_last_chart_tf = current_tf;
//          Print("TF check from IsChartTimeframeChanged | last=", GetTimeframeShortName(g_last_chart_tf),
//       " current=", GetTimeframeShortName(_Period));
//          return true;
//       }
//       return false;
//    }   
   
int GetTFIndex(const ENUM_TIMEFRAMES tf)
{
   for(int i = 0; i < g_num_supported_timeframes; i++)
   {
      if(g_supported_timeframes[i] == tf)
         return i;
   }
   return -1;
}   
#endif // _TIMEFRAME_MQH_
