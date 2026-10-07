//+------------------------------------------------------------------+
//|                                             TimeseriesDELib.mqh  |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __TIMESERIES_DELIB_MQH__
#define __TIMESERIES_DELIB_MQH__

#include "..\..\Entities\Defines\CommonDefines.mqh"
#include "..\Message\Message.mqh"
//+------------------------------------------------------------------+
//| Return the timeframe by its description                          |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TimestampByDescription(const string timeframe)
  {
    return
        (
          timeframe=="M1"  ? PERIOD_M1  :
          timeframe=="M2"  ? PERIOD_M2  :
          timeframe=="M3"  ? PERIOD_M3  :
          timeframe=="M4"  ? PERIOD_M4  :
          timeframe=="M5"  ? PERIOD_M5  :
          timeframe=="M6"  ? PERIOD_M6  :
          timeframe=="M10" ? PERIOD_M10 :
          timeframe=="M12" ? PERIOD_M12 :
          timeframe=="M15" ? PERIOD_M15 :
          timeframe=="M20" ? PERIOD_M20 :
          timeframe=="M30" ? PERIOD_M30 :
          timeframe=="H1"  ? PERIOD_H1  :
          timeframe=="H2"  ? PERIOD_H2  :
          timeframe=="H3"  ? PERIOD_H3  :
          timeframe=="H4"  ? PERIOD_H4  :
          timeframe=="H6"  ? PERIOD_H6  :
          timeframe=="H8"  ? PERIOD_H8  :
          timeframe=="H12" ? PERIOD_H12 :
          timeframe=="D1"  ? PERIOD_D1  :
          timeframe=="W1"  ? PERIOD_W1  :
          timeframe=="MN1" ? PERIOD_MN1 :
          PERIOD_CURRENT
        );
  }
//+------------------------------------------------------------------+
//| Return the timeframe index in the ENUM_TIMEFRAMES enumeration    |
//+------------------------------------------------------------------+
char IndexEnumTimeframe(ENUM_TIMEFRAMES timeframe)
  {
    int statement=(timeframe==PERIOD_CURRENT ? Period() : timeframe);
    switch(statement)
      {
        case PERIOD_M1  : return 1;
        case PERIOD_M2  : return 2;
        case PERIOD_M3  : return 3;
        case PERIOD_M4  : return 4;
        case PERIOD_M5  : return 5;
        case PERIOD_M6  : return 6;
        case PERIOD_M10 : return 7;
        case PERIOD_M12 : return 8;
        case PERIOD_M15 : return 9;
        case PERIOD_M20 : return 10;
        case PERIOD_M30 : return 11;
        case PERIOD_H1  : return 12;
        case PERIOD_H2  : return 13;
        case PERIOD_H3  : return 14;
        case PERIOD_H4  : return 15;
        case PERIOD_H6  : return 16;
        case PERIOD_H8  : return 17;
        case PERIOD_H12 : return 18;
        case PERIOD_D1  : return 19;
        case PERIOD_W1  : return 20;
        case PERIOD_MN1 : return 21;
        default         : Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TS_TEXT_UNKNOWN_TIMEFRAME)); return WRONG_VALUE;
      }
  }
//+------------------------------------------------------------------+
//| Return timeframe description                                     |
//+------------------------------------------------------------------+
string TimeframeDescription(const ENUM_TIMEFRAMES timeframe)
  {
    return StringSubstr(EnumToString((timeframe>PERIOD_CURRENT ? timeframe : (ENUM_TIMEFRAMES)Period())),7);
  } 

#endif //__TIMESERIES_DELIB_MQH__
