//+------------------------------------------------------------------+
//|                                             CommonDELib.mqh      |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __COMMON_DELIB_MQH__
#define __COMMON_DELIB_MQH__
 #include "..\..\Entities\Defines\CommonDefines.mqh"
 #include "..\..\Entities\Defines\MarketStructureDefines.mqh"
 #include "..\..\Entities\Defines\SwingDefines.mqh"
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
//Smart Money Concept  
 //+------------------------------------------------------------------+
 //| Return swing type description - plain literal, not routed through |
 //| CMessage (only 2 fixed labels, not worth a localization entry).   |
 //+------------------------------------------------------------------+
 string SwingTypeDescription(const ENUM_SWING_TYPE type)
  {
    switch(type)
      {
        case SWING_TYPE_HIGH : return "Swing High";
        case SWING_TYPE_LOW  : return "Swing Low";
        default               : return "None";
      }
  } 
 //+------------------------------------------------------------------+
 //| Return market structure event (BOS / CHoCH) description          |
 //+------------------------------------------------------------------+
 string MarketStructureTypeDescription(const ENUM_MARKET_STRUCTURE_TYPE type)
  {
    switch(type)
      {
        case MARKET_STRUCTURE_BOS   : return "BOS";
        case MARKET_STRUCTURE_CHOCH : return "CHoCH";
        default                      : return "None";
      }
  }
 //+------------------------------------------------------------------+
 //| Return swing structure (HH/LH/HL/LL) description                 |
 //+------------------------------------------------------------------+
 string SwingStructureDescription(const ENUM_SWING_STRUCTURE structure)
  {
    switch(structure)
      {
        case SWING_STRUCTURE_HH : return "HH";
        case SWING_STRUCTURE_LH : return "LH";
        case SWING_STRUCTURE_HL : return "HL";
        case SWING_STRUCTURE_LL : return "LL";
        default                  : return "-";
      }
  }
//Indicators
 //+------------------------------------------------------------------+
 //| Return volume description for calculation                        |
 //+------------------------------------------------------------------+
 string AppliedVolumeDescription(const ENUM_APPLIED_VOLUME volume)
  {
    return StringSubstr(EnumToString(volume),7);
  }
 //+------------------------------------------------------------------+
 //| Return indicator type description                                |
 //+------------------------------------------------------------------+
 string IndicatorTypeDescription(const ENUM_INDICATOR indicator)
  {
    return StringSubstr(EnumToString(indicator),4);
  }
 //+------------------------------------------------------------------+
 //| Return averaging method description                              |
 //+------------------------------------------------------------------+
 string AveragingMethodDescription(const ENUM_MA_METHOD method)
  {
    return StringSubstr(EnumToString(method),5);
  }
 //+------------------------------------------------------------------+
 //| Return applied price description                                 |
 //+------------------------------------------------------------------+
 string AppliedPriceDescription(const ENUM_APPLIED_PRICE price)
  {
    return StringSubstr(EnumToString(price),6);
  }
 //+------------------------------------------------------------------+
 //| Return stochastic price calculation description                  |
 //+------------------------------------------------------------------+
 string StochPriceDescription(const ENUM_STO_PRICE price)
  {
    return StringSubstr(EnumToString(price),4);
  }
 //+------------------------------------------------------------------+
 //| Return ENUM_APPLIED_PRICE from its description (mirrors           |
 //| TimestampByDescription) - unrecognized text falls back to Close.  |
 //+------------------------------------------------------------------+
 ENUM_APPLIED_PRICE AppliedPriceByDescription(const string description)
  {
    string d = description;
    StringToUpper(d);
    return
        (
          d=="CLOSE"                ? PRICE_CLOSE    :
          d=="OPEN"                 ? PRICE_OPEN     :
          d=="HIGH"                 ? PRICE_HIGH     :
          d=="LOW"                  ? PRICE_LOW      :
          d=="MEDIAN"               ? PRICE_MEDIAN   :
          d=="TYPICAL"              ? PRICE_TYPICAL  :
          (d=="WEIGHTED" || d=="WCLOSE") ? PRICE_WEIGHTED : // "WClose" = this EA's own short label
          PRICE_CLOSE
        );
  }
 //+------------------------------------------------------------------+
 //| Return ENUM_MA_METHOD from its description                       |
 //+------------------------------------------------------------------+
 ENUM_MA_METHOD AveragingMethodByDescription(const string description)
  {
    string d = description;
    StringToUpper(d);
    return
        (
          d=="SMA"  ? MODE_SMA  :
          d=="EMA"  ? MODE_EMA  :
          d=="SMMA" ? MODE_SMMA :
          d=="LWMA" ? MODE_LWMA :
          MODE_SMA
        );
  }
 //+------------------------------------------------------------------+
 //| Return ENUM_APPLIED_VOLUME from its description                  |
 //+------------------------------------------------------------------+
 ENUM_APPLIED_VOLUME AppliedVolumeByDescription(const string description)
  {
    string d = description;
    StringToUpper(d);
    return
        (
          d=="TICK" ? VOLUME_TICK :
          d=="REAL" ? VOLUME_REAL :
          VOLUME_TICK
        );
  }
 //+------------------------------------------------------------------+
 //| Return ENUM_STO_PRICE from its description - accepts both the raw |
 //| EnumToString style ("LOWHIGH") and this EA's own combo label      |
 //| style ("Low/High") so either source parses correctly.             |
 //+------------------------------------------------------------------+
 ENUM_STO_PRICE StochPriceByDescription(const string description)
  {
    string d = description;
    StringToUpper(d);
    return
        (
          (d=="LOWHIGH"    || d=="LOW/HIGH")    ? STO_LOWHIGH    :
          (d=="CLOSECLOSE" || d=="CLOSE/CLOSE") ? STO_CLOSECLOSE :
          STO_LOWHIGH
        );
  } 
#endif // __COMMON_DELIB_MQH__
