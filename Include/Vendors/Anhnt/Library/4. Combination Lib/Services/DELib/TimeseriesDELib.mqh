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
 #include "..\..\Defines\IndicatorPara.mqh" 
 struct SIndicatorCatalogItem
  {
   ENUM_INDICATOR        type;
   ENUM_INDICATOR_GROUP  group;
   string                name;
  };
struct SIndicatorParam
  {
   string        name;          // field label
   ENUM_DATATYPE data_type;     // TYPE_INT or TYPE_DOUBLE
   string        default_value; // shown pre-filled in the edit box (or selected by index in choices)
   string        choices;       // "|"-separated option text, e.g. "Close|Open|High" - empty = plain numeric edit box
  };
void GetIndicatorCatalog(SIndicatorCatalogItem &out[])
  {
   SIndicatorCatalogItem indicator_list[] =
     {
      // --- Trend
        {IND_SAR,        INDICATOR_GROUP_TREND,      "PSAR"},
        {IND_MA,         INDICATOR_GROUP_TREND,      "MA"},
        {IND_BANDS,      INDICATOR_GROUP_TREND,      "BBands"},
        {IND_ALLIGATOR,  INDICATOR_GROUP_TREND,      "Alligator"},
        {IND_ICHIMOKU,   INDICATOR_GROUP_TREND,      "Ichimoku"},
        {IND_ENVELOPES,  INDICATOR_GROUP_TREND,      "Envelopes"},
        {IND_FRAMA,      INDICATOR_GROUP_TREND,      "FRAMA"},
        {IND_AMA,        INDICATOR_GROUP_TREND,      "AMA"},
        {IND_DEMA,       INDICATOR_GROUP_TREND,      "DEMA"},
        {IND_TEMA,       INDICATOR_GROUP_TREND,      "TEMA"},
        {IND_VIDYA,      INDICATOR_GROUP_TREND,      "VIDYA"},
        {IND_ADX,        INDICATOR_GROUP_TREND,      "ADX"},
        {IND_ADXW,       INDICATOR_GROUP_TREND,      "ADX Wilder"},
        {IND_STDDEV,     INDICATOR_GROUP_TREND,      "StdDev"},

      // --- Oscillator
        {IND_RSI,        INDICATOR_GROUP_OSCILLATOR, "RSI"},
        {IND_MACD,       INDICATOR_GROUP_OSCILLATOR, "MACD"},
        {IND_STOCHASTIC, INDICATOR_GROUP_OSCILLATOR, "Stochastic Oscillator"},
        {IND_CCI,        INDICATOR_GROUP_OSCILLATOR, "CCI"},
        {IND_MOMENTUM,   INDICATOR_GROUP_OSCILLATOR, "Momentum"},
        {IND_DEMARKER,   INDICATOR_GROUP_OSCILLATOR, "DeMarker"},
        {IND_RVI,        INDICATOR_GROUP_OSCILLATOR, "Relative Vigor Index"},
        {IND_WPR,        INDICATOR_GROUP_OSCILLATOR, "Williams' Percent Range"},
        {IND_OSMA,       INDICATOR_GROUP_OSCILLATOR, "OsMA"},
        {IND_TRIX,       INDICATOR_GROUP_OSCILLATOR, "Triple Exponential Average"},
        {IND_ATR,        INDICATOR_GROUP_OSCILLATOR, "ATR"},
        {IND_FORCE,      INDICATOR_GROUP_OSCILLATOR, "Force Index"},
        {IND_AO,         INDICATOR_GROUP_OSCILLATOR, "Awesome Oscillator"},
        {IND_AC,         INDICATOR_GROUP_OSCILLATOR, "Accelerator Oscillator"},
        {IND_GATOR,      INDICATOR_GROUP_OSCILLATOR, "Gator Oscillator"},
        {IND_BEARS,      INDICATOR_GROUP_OSCILLATOR, "Bears Power"},
        {IND_BULLS,      INDICATOR_GROUP_OSCILLATOR, "Bulls Power"},
        {IND_CHAIKIN,    INDICATOR_GROUP_OSCILLATOR, "Chaikin Oscillator"},

      // --- Volumes
        {IND_OBV,        INDICATOR_GROUP_VOLUMES,    "On Balance Volume"},
        {IND_AD,         INDICATOR_GROUP_VOLUMES,    "Accumulation/Distribution"},
        {IND_MFI,        INDICATOR_GROUP_VOLUMES,    "Money Flow Index"},
        {IND_VOLUMES,    INDICATOR_GROUP_VOLUMES,    "Volumes"},
        {IND_BWMFI,      INDICATOR_GROUP_VOLUMES,    "Market Facilitation Index"},

      // --- Arrows
        {IND_FRACTALS,   INDICATOR_GROUP_ARROWS,     "Fractals"},
     };
   int total = ArraySize(indicator_list);
   ArrayResize(out, total);
   for(int i = 0; i < total; i++)
      out[i] = indicator_list[i];
  }
// How many data buffers this indicator type allocates - required by
// CIndicatorsCollection::AddIndicatorToList() to actually register the created
// indicator (without this, CreateIndicator() alone never adds it to m_list).
int GetIndicatorBuffersTotal(const ENUM_INDICATOR type)
  {
   switch(type)
     {
      // --- Trend
      case IND_SAR:        return 1;
      case IND_MA:         return 1;
      case IND_BANDS:      return 3;   // base, upper, lower
      case IND_ALLIGATOR:  return 3;   // jaw, teeth, lips
      case IND_ICHIMOKU:   return 5;   // tenkan, kijun, senkou A/B, chikou
      case IND_ENVELOPES:  return 3;   // base, upper, lower
      case IND_FRAMA:      return 1;
      case IND_AMA:        return 1;
      case IND_DEMA:       return 1;
      case IND_TEMA:       return 1;
      case IND_VIDYA:      return 1;
      case IND_ADX:        return 3;   // main, +DI, -DI
      case IND_ADXW:       return 3;
      case IND_STDDEV:     return 1;
      // --- Oscillator
      case IND_RSI:        return 1;
      case IND_MACD:       return 2;   // main, signal
      case IND_STOCHASTIC: return 2;   // main, signal
      case IND_CCI:        return 1;
      case IND_MOMENTUM:   return 1;
      case IND_DEMARKER:   return 1;
      case IND_RVI:        return 2;   // main, signal
      case IND_WPR:        return 1;
      case IND_OSMA:       return 1;
      case IND_TRIX:       return 1;
      case IND_ATR:        return 1;
      case IND_FORCE:      return 1;
      case IND_AO:         return 1;
      case IND_AC:         return 1;
      case IND_GATOR:      return 4;   // upper, lower + 2 color/histogram buffers
      case IND_BEARS:      return 1;
      case IND_BULLS:      return 1;
      case IND_CHAIKIN:    return 1;
      // --- Volumes
      case IND_OBV:        return 1;
      case IND_AD:         return 1;
      case IND_MFI:        return 1;
      case IND_VOLUMES:    return 1;
      case IND_BWMFI:      return 2;   // value + color index
      // --- Arrows
      case IND_FRACTALS:   return 2;   // upper, lower
      default:             return 1;
     }
  } 
 // --- Max param count across every standard indicator is 8 (Alligator/Gator:
 // --- jaw/teeth/lips period+shift, method, price) - so the form/array must
 // --- support at least 8 slots, not 4, to cover every type below.
 
 int GetIndicatorParamSchema(const ENUM_INDICATOR type, SIndicatorParam &out[])
  {
   ArrayResize(out, INDICATOR_PARAM_SLOTS_MAX);
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      out[i].name = "";
      out[i].data_type = TYPE_DOUBLE;
      out[i].default_value = "";
      out[i].choices = "";
     }
   // --- I = plain numeric field (text edit box). E = enum field (combo box;
   // --- dv is the DEFAULT SELECTED ROW in ch, purely a UI preselect concern -
   // --- unrelated to what value actually gets stored, see the note above
   // --- SIndicatorParam for how enum-choice values are resolved).
   #define I(idx,nm,tp,dv)     out[idx].name=nm; out[idx].data_type=tp;      out[idx].default_value=dv;
   #define E(idx,nm,dv,ch)     out[idx].name=nm; out[idx].data_type=TYPE_INT; out[idx].default_value=dv; out[idx].choices=ch;
   switch(type)
     {
      // --- Trend ---------------------------------------------------------
      case IND_SAR:
         I(0,"Step",TYPE_DOUBLE,"0.02") I(1,"Maximum",TYPE_DOUBLE,"0.2")
         return 2;
      case IND_MA:
         I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
         E(2,"Method","1",CALCULATION_METHOD_CHOICES) E(3,"Applied Price","0",PRICE_CHOICES)
         return 4;
      case IND_BANDS:
         I(0,"Period",TYPE_INT,"20") I(1,"Shift",TYPE_INT,"0")
         I(2,"Deviation",TYPE_DOUBLE,"2.0")
         E(3,"Applied Price","0",PRICE_CHOICES)
         return 4;
      case IND_ALLIGATOR:
         I(0,"Jaw Period",TYPE_INT,"13")  I(1,"Jaw Shift",TYPE_INT,"8")
         I(2,"Teeth Period",TYPE_INT,"8") I(3,"Teeth Shift",TYPE_INT,"5")
         I(4,"Lips Period",TYPE_INT,"5")  I(5,"Lips Shift",TYPE_INT,"3")
         E(6,"Method","2",CALCULATION_METHOD_CHOICES) E(7,"Applied Price","4",PRICE_CHOICES)
         return 8;
      case IND_ICHIMOKU:
         I(0,"Tenkan-sen",TYPE_INT,"9") I(1,"Kijun-sen",TYPE_INT,"26")
         I(2,"Senkou Span B",TYPE_INT,"52")
         return 3;
      case IND_ENVELOPES:
         I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
         E(2,"Method","0",CALCULATION_METHOD_CHOICES) E(3,"Applied Price","0",PRICE_CHOICES)
         I(4,"Deviation %",TYPE_DOUBLE,"0.1")
         return 5;
      case IND_FRAMA:
         I(0,"Period",TYPE_INT,"14") 
         I(1,"Shift",TYPE_INT,"0")
         E(2,"Applied Price","0",PRICE_CHOICES)
         return 3;
      case IND_AMA:
         I(0,"AMA Period",TYPE_INT,"9") 
         I(1,"Fast EMA Period",TYPE_INT,"2")
         I(2,"Slow EMA Period",TYPE_INT,"30") 
         I(3,"Shift",TYPE_INT,"0")
         E(4,"Applied Price","0",PRICE_CHOICES)
         return 5;
      case IND_DEMA:
         I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
         E(2,"Applied Price","0",PRICE_CHOICES)
         return 3;
      case IND_TEMA:
         I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
         E(2,"Applied Price","0",PRICE_CHOICES)
         return 3;
      case IND_VIDYA:
         I(0,"CMO Period",TYPE_INT,"9") I(1,"EMA Period",TYPE_INT,"12")
         I(2,"Shift",TYPE_INT,"0") E(3,"Applied Price","0",PRICE_CHOICES)
         return 4;
      case IND_ADX:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_ADXW:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_STDDEV:
         I(0,"Period",TYPE_INT,"20") 
         I(1,"Shift",TYPE_INT,"0")
         E(2,"Method","0",CALCULATION_METHOD_CHOICES) 
         E(3,"Applied Price","0",PRICE_CHOICES)
         return 4;

     // --- Oscillator ------------------------------------------------------
      case IND_RSI:
         I(0,"Period",TYPE_INT,"14") E(1,"Applied Price","0",PRICE_CHOICES)
         return 2;
      case IND_MACD:
         I(0,"Fast EMA Period",TYPE_INT,"12") I(1,"Slow EMA Period",TYPE_INT,"26")
         I(2,"Signal Period",TYPE_INT,"9") E(3,"Applied Price","0",PRICE_CHOICES)
         return 4;
      case IND_STOCHASTIC:
         I(0,"%K Period",TYPE_INT,"5") 
         I(1,"%D Period",TYPE_INT,"3")
         I(2,"Slowing",TYPE_INT,"3") 
         E(3,"Method","0",CALCULATION_METHOD_CHOICES)
         E(4,"Price Field","0",STOCH_PRICE_CHOICES)
         return 5;
      case IND_CCI:
         I(0,"Period",TYPE_INT,"14") 
         E(1,"Applied Price","5",PRICE_CHOICES)
         return 2;
      case IND_MOMENTUM:
         I(0,"Period",TYPE_INT,"14") 
         E(1,"Applied Price","0",PRICE_CHOICES)
         return 2;
      case IND_DEMARKER:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_RVI:
         I(0,"Period",TYPE_INT,"10")
         return 1;
      case IND_WPR:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_OSMA:
         I(0,"Fast EMA Period",TYPE_INT,"12") 
         I(1,"Slow EMA Period",TYPE_INT,"26")
         I(2,"Signal Period",TYPE_INT,"9") 
         E(3,"Applied Price","0",PRICE_CHOICES)
         return 4;
      case IND_TRIX:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_ATR:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_FORCE:
         I(0,"Period",TYPE_INT,"13") 
         E(1,"Method","1",CALCULATION_METHOD_CHOICES)
         E(2,"Applied Volume","0",VOLUME_CHOICES)
         return 3;
      case IND_AO:
         return 0;
      case IND_AC:
         return 0;
      case IND_GATOR:
         I(0,"Jaw Period",TYPE_INT,"13")  
         I(1,"Jaw Shift",TYPE_INT,"8")
         I(2,"Teeth Period",TYPE_INT,"8") 
         I(3,"Teeth Shift",TYPE_INT,"5")
         I(4,"Lips Period",TYPE_INT,"5")  
         I(5,"Lips Shift",TYPE_INT,"3")
         E(6,"Method","2",CALCULATION_METHOD_CHOICES) 
         E(7,"Applied Price","4",PRICE_CHOICES)
         return 8;
      case IND_BEARS:
         I(0,"Period",TYPE_INT,"13")
         return 1;
      case IND_BULLS:
         I(0,"Period",TYPE_INT,"13")
         return 1;
      case IND_CHAIKIN:
         I(0,"Fast MA Period",TYPE_INT,"3") 
         I(1,"Slow MA Period",TYPE_INT,"10")
         E(2,"Method","1",CALCULATION_METHOD_CHOICES) 
         E(3,"Applied Volume","0",VOLUME_CHOICES)
         return 4;

      // --- Volumes ---------------------------------------------------------
      case IND_OBV:
         E(0,"Applied Volume","0",VOLUME_CHOICES)
         return 1;
      case IND_AD:
         E(0,"Applied Volume","0",VOLUME_CHOICES)
         return 1;
      case IND_MFI:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_VOLUMES:
         E(0,"Applied Volume","0",VOLUME_CHOICES)
         return 1;
      case IND_BWMFI:
         return 0;

      // --- Arrows ----------------------------------------------------------
      case IND_FRACTALS:
         return 0;

      default:
         return 0;
     }
   #undef I
   #undef E
  } 
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
    if(total != size)
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
 //| Return ENUM_INDICATOR from indicator shortname on chart          |
 //+------------------------------------------------------------------+
 ENUM_INDICATOR ShortNameToIndicatorType(const string shortname)
  {
    if(StringFind(shortname, "Moving Average") >= 0) return IND_MA;
    if(StringFind(shortname, "Bollinger")      >= 0) return IND_BANDS;
    if(StringFind(shortname, "Bands")          >= 0) return IND_BANDS;
    if(StringFind(shortname, "MACD")           >= 0) return IND_MACD;
    if(StringFind(shortname, "RSI")            >= 0) return IND_RSI;
    if(StringFind(shortname, "Stochastic")     >= 0) return IND_STOCHASTIC;
    if(StringFind(shortname, "ATR")            >= 0) return IND_ATR;
    if(StringFind(shortname, "CCI")            >= 0) return IND_CCI;
    if(StringFind(shortname, "ADX")            >= 0) return IND_ADX;
    if(StringFind(shortname, "Ichimoku")       >= 0) return IND_ICHIMOKU;
    if(StringFind(shortname, "Envelopes")      >= 0) return IND_ENVELOPES;
    if(StringFind(shortname, "Momentum")       >= 0) return IND_MOMENTUM;
    if(StringFind(shortname, "Force")          >= 0) return IND_FORCE;
    // ... thêm dần khi cần
    return IND_CUSTOM;  // unknown = skip for now
  }
 //+------------------------------------------------------------------+

#endif // __TIMESERIES_DELIB_MQH__
