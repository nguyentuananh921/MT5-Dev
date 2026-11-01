//+------------------------------------------------------------------+
//|                                               IndicatorDELib.mqh |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//| The catalog of the indicators, the schema of their parameters    |
//| and the text of a parameter (by its value and back)              |
//+------------------------------------------------------------------+
#ifndef __INDICATOR_DELIB_MQH__
#define __INDICATOR_DELIB_MQH__
#include "..\..\Entities\Defines\IndicatorDefines.mqh"

 struct SIndicatorCatalogItem
  {
   ENUM_INDICATOR        ind_type;  // CIndicatorDE's constructor param name for the same ENUM_INDICATOR
   ENUM_INDICATOR_GROUP  group;
   string                name;
   int                   buffers;   // the buffers its signal reads (Volumes: 2, its moving average is buffer 1)
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
        {IND_SAR,        INDICATOR_GROUP_TREND,      "PSAR", 1},
        {IND_MA,         INDICATOR_GROUP_TREND,      "MA", 1},
        {IND_BANDS,      INDICATOR_GROUP_TREND,      "BBands", 1},
        {IND_ALLIGATOR,  INDICATOR_GROUP_TREND,      "Alligator", 3},
        {IND_ICHIMOKU,   INDICATOR_GROUP_TREND,      "Ichimoku", 2},
        {IND_ENVELOPES,  INDICATOR_GROUP_TREND,      "Envelopes", 2},
        {IND_FRAMA,      INDICATOR_GROUP_TREND,      "FRAMA", 1},
        {IND_AMA,        INDICATOR_GROUP_TREND,      "AMA", 1},
        {IND_DEMA,       INDICATOR_GROUP_TREND,      "DEMA", 1},
        {IND_TEMA,       INDICATOR_GROUP_TREND,      "TEMA", 1},
        {IND_VIDYA,      INDICATOR_GROUP_TREND,      "VIDYA", 1},
        {IND_ADX,        INDICATOR_GROUP_TREND,      "ADX", 3},
        {IND_ADXW,       INDICATOR_GROUP_TREND,      "ADX Wilder", 3},
        {IND_STDDEV,     INDICATOR_GROUP_TREND,      "StdDev", 1},

      // --- Oscillator
        {IND_RSI,        INDICATOR_GROUP_OSCILLATOR, "RSI", 1},
        {IND_MACD,       INDICATOR_GROUP_OSCILLATOR, "MACD", 2},
        {IND_STOCHASTIC, INDICATOR_GROUP_OSCILLATOR, "Stochastic Oscillator", 2},
        {IND_CCI,        INDICATOR_GROUP_OSCILLATOR, "CCI", 1},
        {IND_MOMENTUM,   INDICATOR_GROUP_OSCILLATOR, "Momentum", 1},
        {IND_DEMARKER,   INDICATOR_GROUP_OSCILLATOR, "DeMarker", 1},
        {IND_RVI,        INDICATOR_GROUP_OSCILLATOR, "Relative Vigor Index", 2},
        {IND_WPR,        INDICATOR_GROUP_OSCILLATOR, "Williams' Percent Range", 1},
        {IND_OSMA,       INDICATOR_GROUP_OSCILLATOR, "OsMA", 1},
        {IND_TRIX,       INDICATOR_GROUP_OSCILLATOR, "Triple Exponential Average", 1},
        {IND_ATR,        INDICATOR_GROUP_OSCILLATOR, "ATR", 1},
        {IND_FORCE,      INDICATOR_GROUP_OSCILLATOR, "Force Index", 1},
        {IND_AO,         INDICATOR_GROUP_OSCILLATOR, "Awesome Oscillator", 1},
        {IND_AC,         INDICATOR_GROUP_OSCILLATOR, "Accelerator Oscillator", 1},
        {IND_GATOR,      INDICATOR_GROUP_OSCILLATOR, "Gator Oscillator", 1},
        {IND_BEARS,      INDICATOR_GROUP_OSCILLATOR, "Bears Power", 1},
        {IND_BULLS,      INDICATOR_GROUP_OSCILLATOR, "Bulls Power", 1},
        {IND_CHAIKIN,    INDICATOR_GROUP_OSCILLATOR, "Chaikin Oscillator", 1},

      // --- Volumes
        {IND_OBV,        INDICATOR_GROUP_VOLUMES,    "On Balance Volume", 1},
        {IND_AD,         INDICATOR_GROUP_VOLUMES,    "Accumulation/Distribution", 1},
        {IND_MFI,        INDICATOR_GROUP_VOLUMES,    "Money Flow Index", 1},
        {IND_VOLUMES,    INDICATOR_GROUP_VOLUMES,    "Volumes", 2},
        {IND_BWMFI,      INDICATOR_GROUP_VOLUMES,    "Market Facilitation Index", 1},

      // --- Arrows
        {IND_FRACTALS,   INDICATOR_GROUP_ARROWS,     "Fractals", 2},
     };
   int total = ArraySize(indicator_list);
   ArrayResize(out, total);
   for(int i = 0; i < total; i++)
      out[i] = indicator_list[i];
  }

 //--- Catalog display name (the label of the table), "" if not in the catalog
 string GetIndicatorNameForType(const ENUM_INDICATOR type)
  {
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int c = 0; c < ArraySize(catalog); c++)
     if(catalog[c].ind_type == type) return catalog[c].name;
   return "";
  }

 //--- The group of a type by the catalog (an oscillator when it is not in it)
 ENUM_INDICATOR_GROUP GetIndicatorGroupForType(const ENUM_INDICATOR type)
  {
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int c = 0; c < ArraySize(catalog); c++)
     if(catalog[c].ind_type == type) return catalog[c].group;
   return INDICATOR_GROUP_OSCILLATOR;
  }

 //--- How many buffers the signal of a type reads, by the catalog (1 when it is not in it)
 int GetIndicatorBuffersForType(const ENUM_INDICATOR type)
  {
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int c = 0; c < ArraySize(catalog); c++)
     if(catalog[c].ind_type == type) return catalog[c].buffers;
   return 1;
  }

 //--- The short display name of a group: the Group column of the table and the labels of the tree
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
         I(1,"MA period",TYPE_INT,"20")   // the moving average drawn with it, and the signal is the volume against it
         E(2,"MA method","0",CALCULATION_METHOD_CHOICES)
         return 3;
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

//Indicators
 //+------------------------------------------------------------------+
 //| Return volume description for calculation                        |
 //+------------------------------------------------------------------+
 string AppliedVolumeDescription(const ENUM_APPLIED_VOLUME volume)
  {
    return StringSubstr(EnumToString(volume),7);
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
 //| Return the text of the value of a parameter by the choices of its|
 //| schema: Applied Price / Method / Volume / Stoch price by         |
 //| description, numbers with `decimals`                              |
 //+------------------------------------------------------------------+
 //--- Change from V1 MqlParameterDescription(MqlParam): the value only, read by the schema of the type (SIndicatorParam::choices)
 string MqlParameterDescription(const MqlParam &param,const string choices,const int decimals)
  {
    if(choices == PRICE_CHOICES)
       return AppliedPriceDescription((ENUM_APPLIED_PRICE)param.integer_value);
    if(choices == CALCULATION_METHOD_CHOICES)
       return AveragingMethodDescription((ENUM_MA_METHOD)param.integer_value);
    if(choices == VOLUME_CHOICES)
       return AppliedVolumeDescription((ENUM_APPLIED_VOLUME)param.integer_value);
    if(choices == STOCH_PRICE_CHOICES)
       return StochPriceDescription((ENUM_STO_PRICE)param.integer_value);
    if(param.type == TYPE_DOUBLE)
       return DoubleToString(param.double_value, decimals);
    return IntegerToString((int)param.integer_value);
  }
 //+------------------------------------------------------------------+
 //| Return ENUM_APPLIED_PRICE from its description - unrecognized     |
 //| text falls back to Close.                                         |
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

 //+------------------------------------------------------------------+
 //| Compare two MqlParam structures                                  |
 //+------------------------------------------------------------------+
 bool IsEqualMqlParams(const MqlParam &struct1, const MqlParam &struct2)
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
 bool IsEqualMqlParamArrays(const MqlParam &array1[], const MqlParam &array2[])
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
#endif // __INDICATOR_DELIB_MQH__
