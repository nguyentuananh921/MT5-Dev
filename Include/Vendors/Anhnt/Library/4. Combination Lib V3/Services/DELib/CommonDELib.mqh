//+------------------------------------------------------------------+
//|                                             CommonDELib.mqh      |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __COMMON_DELIB_MQH__
#define __COMMON_DELIB_MQH__
 #include "..\..\Entities\Defines\CommonDefines.mqh"
 #include "..\..\Entities\Defines\MarketStructureDefines.mqh"
 #include "..\Message\Message.mqh" 
 //+------------------------------------------------------------------+
 //| Return time with milliseconds                                    |
 //+------------------------------------------------------------------+
 string TimeMSCtoString(const long time_msc, int flags=TIME_DATE|TIME_MINUTES|TIME_SECONDS)
  {
    return TimeToString(time_msc/1000,flags)+"."+IntegerToString(time_msc%1000,3,'0');
  }
 //Compare  
  //+------------------------------------------------------------------+
  //| Return the comparison type description                           |
  //+------------------------------------------------------------------+
  string ComparisonTypeDescription(const ENUM_COMPARER_TYPE type)
   {
    switch((int)type)
      {
        case EQUAL         : return " == ";
        case MORE          : return " > ";
        case LESS          : return " < ";
        case EQUAL_OR_MORE : return " >= ";
        case EQUAL_OR_LESS : return " <= ";
        default            : return " != ";
      }
   }
// Date time
 //+------------------------------------------------------------------+
 //| Return week day names                                            |
 //+------------------------------------------------------------------+
 string DayOfWeekDescription(const ENUM_DAY_OF_WEEK day_of_week)
  {
    return
        (
          day_of_week==SUNDAY    ? CMessage::Text(MSG_LIB_TEXT_SUNDAY)    :
          day_of_week==MONDAY    ? CMessage::Text(MSG_LIB_TEXT_MONDAY)    :
          day_of_week==TUESDAY   ? CMessage::Text(MSG_LIB_TEXT_TUESDAY)   :
          day_of_week==WEDNESDAY ? CMessage::Text(MSG_LIB_TEXT_WEDNESDAY) :
          day_of_week==THURSDAY  ? CMessage::Text(MSG_LIB_TEXT_THURSDAY)  :
          day_of_week==FRIDAY    ? CMessage::Text(MSG_LIB_TEXT_FRIDAY)    :
          day_of_week==SATURDAY  ? CMessage::Text(MSG_LIB_TEXT_SATURDAY)  :
          EnumToString(day_of_week)
        );
  }
#endif // __COMMON_DELIB_MQH__
