//+------------------------------------------------------------------+
//|                                          TimeseriesDELib.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#ifndef __TIMESERIES_DELIB_MQH__
#define __TIMESERIES_DELIB_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "CommonDELib.mqh"
 //+------------------------------------------------------------------+
 //| Return description of the line style                             |
 //+------------------------------------------------------------------+
 string LineStyleDescription(const ENUM_LINE_STYLE style)
  {
    return
        (
          style==STYLE_SOLID      ? CMessage::Text(MSG_LIB_TEXT_BUFFER_TEXT_STYLE_SOLID)      :
          style==STYLE_DASH       ? CMessage::Text(MSG_LIB_TEXT_BUFFER_TEXT_STYLE_DASH)       :
          style==STYLE_DOT        ? CMessage::Text(MSG_LIB_TEXT_BUFFER_TEXT_STYLE_DOT)        :
          style==STYLE_DASHDOT    ? CMessage::Text(MSG_LIB_TEXT_BUFFER_TEXT_STYLE_DASHDOT)    :
          style==STYLE_DASHDOTDOT ? CMessage::Text(MSG_LIB_TEXT_BUFFER_TEXT_STYLE_DASHDOTDOT) :
          "Unknown"
        );
  }
 //+------------------------------------------------------------------+
 //| Compare two MqlParam structures                                  |
 //+------------------------------------------------------------------+
 bool IsEqualMqlParams(MqlParam &struct1, MqlParam &struct2)
  {
    if(struct1.type != struct2.type)
        return false;
    switch(struct1.type)
      {
        case TYPE_BOOL    : case TYPE_CHAR : case TYPE_UCHAR : case TYPE_SHORT    : case TYPE_USHORT  :
        case TYPE_COLOR   : case TYPE_INT  : case TYPE_UINT  : case TYPE_DATETIME : case TYPE_LONG    :
        case TYPE_ULONG   : return(struct1.integer_value == struct2.integer_value);
        case TYPE_FLOAT   :
        case TYPE_DOUBLE  : return(NormalizeDouble(struct1.double_value - struct2.double_value, DBL_DIG) == 0);
        case TYPE_STRING  : return(struct1.string_value == struct2.string_value);
        default           : return false;
      }
  }
 //+------------------------------------------------------------------+
 //| Compare two MqlParam arrays element by element                   |
 //+------------------------------------------------------------------+
 bool IsEqualMqlParamArrays(MqlParam &array1[], MqlParam &array2[])
  {
    int total = ArraySize(array1);
    int size  = ArraySize(array2);
    if(total != size || total == 0 || size == 0)
        return false;
    for(int i = 0; i < total; i++)
      {
        if(!IsEqualMqlParams(array1[i], array2[i]))
            return false;
      }
    return true;
  }
 //+------------------------------------------------------------------+
 //| Return the number of candles for a given pattern type            |
 //+------------------------------------------------------------------+
 int CandlesForPatternType(const ENUM_PATTERN_TYPE type)
    {
      // Single Candlestick (1 bar) 8 pattern
      if(type==PATTERN_TYPE_SHOOTING_STAR || type==PATTERN_TYPE_HAMMER ||
        type==PATTERN_TYPE_INVERTED_HAMMER || type==PATTERN_TYPE_HANGING_MAN ||
        type==PATTERN_TYPE_DOJI || type==PATTERN_TYPE_DRAGONFLY_DOJI ||
        type==PATTERN_TYPE_GRAVESTONE_DOJI || type==PATTERN_TYPE_PIN_BAR)
          return 1;
      // Double Candlestick (2 bars) 9 pattern
      if(type==PATTERN_TYPE_HARAMI || type==PATTERN_TYPE_HARAMI_CROSS ||
        type==PATTERN_TYPE_TWEEZER || type==PATTERN_TYPE_PIERCING_LINE ||
        type==PATTERN_TYPE_DARK_CLOUD_COVER || type==PATTERN_TYPE_ENGULFING ||
        type==PATTERN_TYPE_OUTSIDE_BAR || type==PATTERN_TYPE_INSIDE_BAR ||
        type==PATTERN_TYPE_RAILS)
          return 2;
      return 3; // Triple (3 bars) 11 pattern
    }
 //+------------------------------------------------------------------+

#endif // __TIMESERIES_DELIB_MQH__
