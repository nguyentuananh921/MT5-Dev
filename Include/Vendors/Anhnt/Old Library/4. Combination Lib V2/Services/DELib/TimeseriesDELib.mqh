//+------------------------------------------------------------------+
//|                                           TimeseriesDELib.mqh    |
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
 #include "..\..\Entities\Defines\IndicatorPara.mqh"
 #include "..\..\Entities\Bar.mqh"
#include "..\..\Timeseries\BarPatternsSeries\BarPattern.mqh"
#include "..\..\Timeseries\SmartMoney\BarSwingSeries.mqh"

 struct SIndicatorCatalogItem
  {
   ENUM_INDICATOR        ind_type;  // CIndicatorDE's constructor param name for the same ENUM_INDICATOR
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
 //+------------------------------------------------------------------------+
 //| Map ENUM_INDICATOR_GROUP -> short lower display name - single source   |
 //| for PopulateIndicatorTree's tree labels AND SetIndicatorTableRow's     |
 //| Group column (previously 2 separate hardcoded string arrays)           |
 //+------------------------------------------------------------------------+
 string GetIndicatorGroupName(const ENUM_INDICATOR_GROUP group)
  {
   switch(group)
    {
     case INDICATOR_GROUP_TREND:      return "Trend";
     case INDICATOR_GROUP_OSCILLATOR: return "Oscillator";
     case INDICATOR_GROUP_VOLUMES:    return "Volumes";
     case INDICATOR_GROUP_ARROWS:     return "Arrows";
     default:                         return "Other";
    }
  }
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
 ENUM_INDICATOR_GROUP GetIndicatorGroupForType(const ENUM_INDICATOR type)
  {
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int c = 0; c < ArraySize(catalog); c++)
     if(catalog[c].ind_type == type) return catalog[c].group;
   return INDICATOR_GROUP_OSCILLATOR;
  }
 //--- Catalog display name (the JSON "m_indicator_type" key / table label), "" if not in the catalog
 string GetIndicatorNameForType(const ENUM_INDICATOR type)
  {
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int c = 0; c < ArraySize(catalog); c++)
     if(catalog[c].ind_type == type) return catalog[c].name;
   return "";
  }
 //+----------------------------------------------------------------------------+
 //|How many data buffers this indicator type allocates - required by           |
 //|CIndicatorsCollection::AddIndicatorToList() to actually register the created|
 //|indicator (without this, CreateIndicator() alone never adds it to m_list).  |
 //+----------------------------------------------------------------------------+
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
 //+----------------------------------------------------------------------------+
 //| Max param count across every standard indicator is 8 (Alligator/Gator:     |
 //| jaw/teeth/lips period+shift, method, price) - so the form/array must       |
 //| support at least 8 slots, not 4, to cover every type below.                |
 //+----------------------------------------------------------------------------+
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
//| CBar descriptions                                                |
//+------------------------------------------------------------------+
string BarBodyTypeDescription(const ENUM_BAR_BODY_TYPE type)
  {
   return
     (
      type==BAR_BODY_TYPE_BULLISH          ? CMessage::Text(MSG_LIB_TEXT_BAR_TYPE_BULLISH)          :
      type==BAR_BODY_TYPE_BEARISH          ? CMessage::Text(MSG_LIB_TEXT_BAR_TYPE_BEARISH)          :
      type==BAR_BODY_TYPE_CANDLE_ZERO_BODY ? CMessage::Text(MSG_LIB_TEXT_BAR_TYPE_CANDLE_ZERO_BODY) :
      CMessage::Text(MSG_LIB_TEXT_BAR_TYPE_NULL)
     );
  }
int BarIndex(CBar *bar,const ENUM_TIMEFRAMES timeframe)
  {
   return ::iBarShift(bar.Symbol(),(timeframe==PERIOD_CURRENT ? ::Period() : timeframe),bar.Time());
  }
string BarHeader(CBar *bar)
  {
   return
     (
      CMessage::Text(MSG_LIB_TEXT_BAR)+" \""+bar.Symbol()+"\" "+
      TimeframeDescription(bar.Timeframe())+"["+(string)BarIndex(bar,bar.Timeframe())+"]"
     );
  }
string BarParameterDescription(CBar *bar)
  {
   int dg=(bar.Digits()>0 ? bar.Digits() : 1);
   return
     (
      ::TimeToString(bar.Time(),TIME_DATE|TIME_MINUTES|TIME_SECONDS)+", "+
      "O: "+::DoubleToString(bar.Open(),dg)+", "+
      "H: "+::DoubleToString(bar.High(),dg)+", "+
      "L: "+::DoubleToString(bar.Low(),dg)+", "+
      "C: "+::DoubleToString(bar.Close(),dg)+", "+
      "V: "+(string)bar.VolumeTick()+", "+
      (bar.VolumeReal()>0 ? "R: "+(string)bar.VolumeReal()+", " : "")+
      BarBodyTypeDescription(bar.TypeBody())
     );
  }
string BarPropertyDescription(CBar *bar,ENUM_BAR_PROP_INTEGER property)
  {
   string ns=": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED);
   bool   ok=bar.SupportProperty(property);
   return
     (
      property==BAR_PROP_TIME             ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME)+(ok ? ": "+::TimeToString(bar.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS) : ns) :
      property==BAR_PROP_TYPE             ? CMessage::Text(MSG_ORD_TYPE)+(ok ? ": "+BarBodyTypeDescription(bar.TypeBody()) : ns) :
      property==BAR_PROP_PERIOD           ? CMessage::Text(MSG_LIB_TEXT_BAR_PERIOD)+(ok ? ": "+TimeframeDescription(bar.Timeframe()) : ns) :
      property==BAR_PROP_SPREAD           ? CMessage::Text(MSG_LIB_TEXT_BAR_SPREAD)+(ok ? ": "+(string)bar.GetProperty(property) : ns) :
      property==BAR_PROP_VOLUME_TICK      ? CMessage::Text(MSG_LIB_TEXT_BAR_VOLUME_TICK)+(ok ? ": "+(string)bar.GetProperty(property) : ns) :
      property==BAR_PROP_VOLUME_REAL      ? CMessage::Text(MSG_LIB_TEXT_BAR_VOLUME_REAL)+(ok ? ": "+(string)bar.GetProperty(property) : ns) :
      property==BAR_PROP_TIME_YEAR        ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME_YEAR)+(ok ? ": "+(string)bar.Year() : ns) :
      property==BAR_PROP_TIME_MONTH       ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME_MONTH)+(ok ? ": "+MonthDescription((int)bar.Month()) : ns) :
      property==BAR_PROP_TIME_DAY_OF_YEAR ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME_DAY_OF_YEAR)+(ok ? ": "+::IntegerToString(bar.DayOfYear(),3,'0') : ns) :
      property==BAR_PROP_TIME_DAY_OF_WEEK ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME_DAY_OF_WEEK)+(ok ? ": "+DayOfWeekDescription((ENUM_DAY_OF_WEEK)bar.DayOfWeek()) : ns) :
      property==BAR_PROP_TIME_DAY         ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME_DAY)+(ok ? ": "+::IntegerToString(bar.Day(),2,'0') : ns) :
      property==BAR_PROP_TIME_HOUR        ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME_HOUR)+(ok ? ": "+::IntegerToString(bar.Hour(),2,'0') : ns) :
      property==BAR_PROP_TIME_MINUTE      ? CMessage::Text(MSG_LIB_TEXT_BAR_TIME_MINUTE)+(ok ? ": "+::IntegerToString(bar.Minute(),2,'0') : ns) :
      property==BAR_PROP_PATTERNS_TYPE    ? CMessage::Text(MSG_LIB_TEXT_BAR_PATTERNS_TYPE)+
                                            (!ok ? ns : ": "+(bar.GetProperty(property)==0 ? CMessage::Text(MSG_LIB_PROP_NOT_FOUND) : "\n"+PatternsInVarDescription(bar.GetProperty(property),true))) :
      ""
     );
  }
string BarPropertyDescription(CBar *bar,ENUM_BAR_PROP_DOUBLE property)
  {
   int    dg=(bar.Digits()>0 ? bar.Digits() : 1);
   string ns=": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED);
   bool   ok=bar.SupportProperty(property);
   string v=": "+::DoubleToString(bar.GetProperty(property),dg);
   string pct=": "+::DoubleToString(bar.GetProperty(property),2)+"%";
   return
     (
      property==BAR_PROP_OPEN                             ? CMessage::Text(MSG_ORD_PRICE_OPEN)+(ok ? v : ns) :
      property==BAR_PROP_HIGH                             ? CMessage::Text(MSG_LIB_TEXT_BAR_HIGH)+(ok ? v : ns) :
      property==BAR_PROP_LOW                              ? CMessage::Text(MSG_LIB_TEXT_BAR_LOW)+(ok ? v : ns) :
      property==BAR_PROP_CLOSE                            ? CMessage::Text(MSG_ORD_PRICE_CLOSE)+(ok ? v : ns) :
      property==BAR_PROP_CANDLE_SIZE                      ? CMessage::Text(MSG_LIB_TEXT_BAR_CANDLE_SIZE)+(ok ? v : ns) :
      property==BAR_PROP_CANDLE_SIZE_BODY                 ? CMessage::Text(MSG_LIB_TEXT_BAR_CANDLE_SIZE_BODY)+(ok ? v : ns) :
      property==BAR_PROP_CANDLE_SIZE_SHADOW_UP            ? CMessage::Text(MSG_LIB_TEXT_BAR_CANDLE_SIZE_SHADOW_UP)+(ok ? v : ns) :
      property==BAR_PROP_CANDLE_SIZE_SHADOW_DOWN          ? CMessage::Text(MSG_LIB_TEXT_BAR_CANDLE_SIZE_SHADOW_DOWN)+(ok ? v : ns) :
      property==BAR_PROP_CANDLE_BODY_TOP                  ? CMessage::Text(MSG_LIB_TEXT_BAR_CANDLE_BODY_TOP)+(ok ? v : ns) :
      property==BAR_PROP_CANDLE_BODY_BOTTOM               ? CMessage::Text(MSG_LIB_TEXT_BAR_CANDLE_BODY_BOTTOM)+(ok ? v : ns) :
      property==BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE        ? CMessage::Text(MSG_LIB_TEXT_BAR_RATIO_BODY_TO_CANDLE_SIZE)+(ok ? pct : ns) :
      property==BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE? CMessage::Text(MSG_LIB_TEXT_BAR_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE)+(ok ? pct : ns) :
      property==BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE? CMessage::Text(MSG_LIB_TEXT_BAR_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE)+(ok ? pct : ns) :
      ""
     );
  }
string BarPropertyDescription(CBar *bar,ENUM_BAR_PROP_STRING property)
  {
   return(property==BAR_PROP_SYMBOL ? CMessage::Text(MSG_LIB_PROP_SYMBOL)+": \""+bar.GetProperty(property)+"\"" : "");
  }
void BarPrint(CBar *bar,const bool full_prop=false)
  {
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG)," (",BarHeader(bar),") =============");
   for(int i=0; i<BAR_PROP_INTEGER_TOTAL; i++)
     {
      ENUM_BAR_PROP_INTEGER prop=(ENUM_BAR_PROP_INTEGER)i;
      if(full_prop || bar.SupportProperty(prop)) ::Print(BarPropertyDescription(bar,prop));
     }
   ::Print("------");
   for(int i=BAR_PROP_INTEGER_TOTAL; i<BAR_PROP_INTEGER_TOTAL+BAR_PROP_DOUBLE_TOTAL; i++)
     {
      ENUM_BAR_PROP_DOUBLE prop=(ENUM_BAR_PROP_DOUBLE)i;
      if(full_prop || bar.SupportProperty(prop)) ::Print(BarPropertyDescription(bar,prop));
     }
   ::Print("------");
   for(int i=BAR_PROP_INTEGER_TOTAL+BAR_PROP_DOUBLE_TOTAL; i<BAR_PROP_INTEGER_TOTAL+BAR_PROP_DOUBLE_TOTAL+BAR_PROP_STRING_TOTAL; i++)
     {
      ENUM_BAR_PROP_STRING prop=(ENUM_BAR_PROP_STRING)i;
      if(full_prop || bar.SupportProperty(prop)) ::Print(BarPropertyDescription(bar,prop));
     }
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_END)," (",BarHeader(bar),") =============\n");
  }
void BarPrintShort(CBar *bar)
  {
   ::Print(BarHeader(bar),": ",BarParameterDescription(bar));
  }
void BarPatternTypeDescriptionPrint(CBar *bar,const bool dash=false)
  {
   ulong patt=bar.GetProperty(BAR_PROP_PATTERNS_TYPE);
   ::Print(CMessage::Text(MSG_LIB_TEXT_BAR_PATTERNS_TYPE),": ",(patt>0 ? "" : CMessage::Text(MSG_LIB_PROP_EMPTY)));
   if(patt>0)
      ::Print(PatternsInVarDescription(patt,dash));
  }
string PatternStatusDescription(const ENUM_PATTERN_STATUS status)
  {
   switch(status)
     {
      case PATTERN_STATUS_JC : return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_JC);
      case PATTERN_STATUS_PA : return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA);
      default                : return "Unknown";
     }
  }
string PatternDirectionDescription(const ENUM_PATTERN_DIRECTION direction)
  {
   switch(direction)
     {
      case PATTERN_DIRECTION_BULLISH : return CMessage::Text(MSG_LIB_TEXT_PATTERN_BULLISH);
      case PATTERN_DIRECTION_BEARISH : return CMessage::Text(MSG_LIB_TEXT_PATTERN_BEARISH);
      case PATTERN_DIRECTION_BOTH    : return CMessage::Text(MSG_LIB_TEXT_PATTERN_BOTH);
      default                        : return "Unknown";
     }
  }
string BarPatternHeader(CBarPattern *pattern)
  {
   return(PatternStatusDescription(pattern.Status())+" "+PatternTypeDescription(pattern.TypePattern()));
  }
string BarPatternPropertyDescription(CBarPattern *pattern,ENUM_PATTERN_PROP_INTEGER property)
  {
   string ns=": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED);
   bool   ok=pattern.SupportProperty(property);
   return
     (
      property==PATTERN_PROP_CODE           ? CMessage::Text(MSG_LIB_TEXT_PATTERN_CODE)+(ok ? ": "+(string)pattern.GetProperty(property) : ns) :
      property==PATTERN_PROP_TIME           ? CMessage::Text(MSG_LIB_TEXT_PATTERN_TIME)+(ok ? ": "+::TimeToString(pattern.GetProperty(property),TIME_DATE|TIME_MINUTES) : ns) :
      property==PATTERN_PROP_MOTHERBAR_TIME ? CMessage::Text(MSG_LIB_TEXT_PATTERN_MOTHERBAR_TIME)+(ok ? ": "+::TimeToString(pattern.GetProperty(property),TIME_DATE|TIME_MINUTES) : ns) :
      property==PATTERN_PROP_STATUS         ? CMessage::Text(MSG_ORD_STATUS)+(ok ? ": "+PatternStatusDescription(pattern.Status()) : ns) :
      property==PATTERN_PROP_TYPE           ? CMessage::Text(MSG_ORD_TYPE)+(ok ? ": "+PatternTypeDescription(pattern.TypePattern()) : ns) :
      property==PATTERN_PROP_ID             ? CMessage::Text(MSG_LIB_TEXT_PATTERN_ID)+(ok ? ": "+(string)pattern.GetProperty(property) : ns) :
      property==PATTERN_PROP_CTRL_OBJ_ID    ? CMessage::Text(MSG_LIB_TEXT_PATTERN_CTRL_OBJ_ID)+(ok ? ": "+(string)pattern.GetProperty(property) : ns) :
      property==PATTERN_PROP_DIRECTION      ? CMessage::Text(MSG_LIB_TEXT_PATTERN_DIRECTION)+(ok ? ": "+PatternDirectionDescription(pattern.Direction()) : ns) :
      property==PATTERN_PROP_PERIOD         ? CMessage::Text(MSG_LIB_TEXT_BAR_PERIOD)+(ok ? ": "+TimeframeDescription(pattern.Timeframe()) : ns) :
      property==PATTERN_PROP_CANDLES        ? CMessage::Text(MSG_LIB_TEXT_PATTERN_CANDLES)+(ok ? ": "+(string)pattern.GetProperty(property) : ns) :
      ""
     );
  }
string BarPatternPropertyDescription(CBarPattern *pattern,ENUM_PATTERN_PROP_DOUBLE property)
  {
   int    dg=(int)::SymbolInfoInteger(pattern.Symbol(),SYMBOL_DIGITS);
   if(dg<=0) dg=1;
   string ns=": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED);
   bool   ok=pattern.SupportProperty(property);
   string v=": "+::DoubleToString(pattern.GetProperty(property),dg);
   string r=": "+::DoubleToString(pattern.GetProperty(property),2);
   return
     (
      property==PATTERN_PROP_BAR_PRICE_OPEN                                ? CMessage::Text(MSG_LIB_TEXT_PATTERN_BAR_PRICE_OPEN)+(ok ? v : ns) :
      property==PATTERN_PROP_BAR_PRICE_HIGH                                ? CMessage::Text(MSG_LIB_TEXT_PATTERN_BAR_PRICE_HIGH)+(ok ? v : ns) :
      property==PATTERN_PROP_BAR_PRICE_LOW                                 ? CMessage::Text(MSG_LIB_TEXT_PATTERN_BAR_PRICE_LOW)+(ok ? v : ns) :
      property==PATTERN_PROP_BAR_PRICE_CLOSE                               ? CMessage::Text(MSG_LIB_TEXT_PATTERN_BAR_PRICE_CLOSE)+(ok ? v : ns) :
      property==PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE                     ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_BODY_TO_CANDLE_SIZE)+(ok ? r : ns) :
      property==PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE             ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE)+(ok ? r : ns) :
      property==PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE             ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE)+(ok ? r : ns) :
      property==PATTERN_PROP_RATIO_CANDLE_SIZES                            ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_CANDLE_SIZES)+(ok ? r : ns) :
      property==PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION           ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_BODY_TO_CANDLE_SIZE_CRIT)+(ok ? r : ns) :
      property==PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION  ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRIT)+(ok ? r : ns) :
      property==PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRIT)+(ok ? r : ns) :
      property==PATTERN_PROP_RATIO_CANDLE_SIZES_CRITERION                  ? CMessage::Text(MSG_LIB_TEXT_PATTERN_RATIO_CANDLE_SIZES_CRITERION)+(ok ? r : ns) :
      ""
     );
  }
string BarPatternPropertyDescription(CBarPattern *pattern,ENUM_PATTERN_PROP_STRING property)
  {
   string ns=": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED);
   bool   ok=pattern.SupportProperty(property);
   return
     (
      property==PATTERN_PROP_SYMBOL ? CMessage::Text(MSG_LIB_PROP_SYMBOL)+(ok ? ": "+pattern.GetProperty(property) : ns) :
      property==PATTERN_PROP_NAME   ? CMessage::Text(MSG_LIB_TEXT_PATTERN_NAME)+(ok ? ": "+pattern.GetProperty(property) : ns) :
      ""
     );
  }
void BarPatternPrint(CBarPattern *pattern,const bool full_prop=false)
  {
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG)," (",BarPatternHeader(pattern),") =============");
   for(int i=0; i<PATTERN_PROP_INTEGER_TOTAL; i++)
     {
      ENUM_PATTERN_PROP_INTEGER prop=(ENUM_PATTERN_PROP_INTEGER)i;
      if(full_prop || pattern.SupportProperty(prop)) ::Print(BarPatternPropertyDescription(pattern,prop));
     }
   ::Print("------");
   for(int i=PATTERN_PROP_INTEGER_TOTAL; i<PATTERN_PROP_INTEGER_TOTAL+PATTERN_PROP_DOUBLE_TOTAL; i++)
     {
      ENUM_PATTERN_PROP_DOUBLE prop=(ENUM_PATTERN_PROP_DOUBLE)i;
      if(full_prop || pattern.SupportProperty(prop)) ::Print(BarPatternPropertyDescription(pattern,prop));
     }
   ::Print("------");
   for(int i=PATTERN_PROP_INTEGER_TOTAL+PATTERN_PROP_DOUBLE_TOTAL; i<PATTERN_PROP_INTEGER_TOTAL+PATTERN_PROP_DOUBLE_TOTAL+PATTERN_PROP_STRING_TOTAL; i++)
     {
      ENUM_PATTERN_PROP_STRING prop=(ENUM_PATTERN_PROP_STRING)i;
      if(full_prop || pattern.SupportProperty(prop)) ::Print(BarPatternPropertyDescription(pattern,prop));
     }
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_END)," (",BarPatternHeader(pattern),") =============\n");
  }
void BarPatternPrintShort(CBarPattern *pattern,const bool dash=false)
  {
   ::Print(BarPatternHeader(pattern),":\n",(dash ? " - " : ""),pattern.Symbol(),", ",TimeframeDescription(pattern.Timeframe())," ",
           ::TimeToString(pattern.Time()),", ",PatternDirectionDescription(pattern.Direction()));
  }
void BarSwingPrint(CBarSwingSeries *swing,const bool dash=false)
  {
   ::Print((dash ? " - " : ""),swing.Symbol()," ",TimeframeDescription(swing.Timeframe()),
           " ",SwingTypeDescription(swing.TypeSwing())," (",SwingStructureDescription(swing.Structure()),")",
           " price=",::DoubleToString(swing.Price(),(int)::SymbolInfoInteger(swing.Symbol(),SYMBOL_DIGITS)),
           " time=",::TimeToString(swing.Time(),TIME_DATE|TIME_MINUTES),
           " confirmed=",::TimeToString(swing.ConfirmedTime(),TIME_DATE|TIME_MINUTES),
           " strength=",swing.Strength());
  }
#endif // __TIMESERIES_DELIB_MQH__
