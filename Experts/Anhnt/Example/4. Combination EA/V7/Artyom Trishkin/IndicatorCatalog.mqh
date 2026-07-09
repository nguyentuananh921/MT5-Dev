//+------------------------------------------------------------------+
//|                                            IndicatorCatalog.mqh   |
//| Pure indicator metadata - which ENUM_INDICATOR types exist, what |
//| group they belong to, what params they need. Tang 1 (PureData)  |
//| knowledge: shared by CTimeSeriesEngine (creates indicators) and  |
//| CGUIPannel (renders the Add-indicator form), so it lives here as |
//| free functions instead of being owned by either class.           |
//+------------------------------------------------------------------+
#ifndef __INDICATORCATALOG_MQH__
#define __INDICATORCATALOG_MQH__
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

// Shared enum-like option lists, reused across many indicator types below.
#define PRICE_CHOICES  "Close|Open|High|Low|Median|Typical|WClose"
#define METHOD_CHOICES "SMA|EMA|SMMA|LWMA"
#define VOLUME_CHOICES "Tick|Real"
#define STOCH_PRICE_CHOICES "Low/High|Close/Close"
void GetIndicatorCatalog(SIndicatorCatalogItem &out[])
  {
   SIndicatorCatalogItem list[] =
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
   int total = ArraySize(list);
   ArrayResize(out, total);
   for(int i = 0; i < total; i++)
      out[i] = list[i];
  }

// --- Named param-slot indices for GetIndicatorGuiLayout() (Tang 2 GUI layer).
// --- Values MUST mirror the index order in GetIndicatorParamSchema() for the
// --- same type - co-located here so a schema reorder forces a review of the
// --- matching enum in the same file.
 enum ENUM_MA_PARAM            { MA_PERIOD = 0, MA_SHIFT, MA_METHOD, MA_APPLIED_PRICE };  // shape also shared by IND_STDDEV
 enum ENUM_ICHIMOKU_PARAM      { ICHIMOKU_TENKAN = 0, ICHIMOKU_KIJUN, ICHIMOKU_SENKOU_B };
 enum ENUM_SAR_PARAM           { SAR_STEP = 0, SAR_MAXIMUM };
 enum ENUM_BANDS_PARAM         { BANDS_PERIOD = 0, BANDS_SHIFT, BANDS_DEVIATION, BANDS_APPLIED_PRICE };
// --- Jaw/Teeth/Lips period+shift pairs + Method + Applied Price - identical
// --- 8-param shape for both Alligator and Gator Oscillator.
 enum ENUM_JAW_TEETH_LIPS_PARAM
  {
   JTL_JAW_PERIOD = 0, JTL_JAW_SHIFT, JTL_TEETH_PERIOD, JTL_TEETH_SHIFT,
   JTL_LIPS_PERIOD, JTL_LIPS_SHIFT, JTL_METHOD, JTL_APPLIED_PRICE
  };
 enum ENUM_ENVELOPES_PARAM      
  { 
    ENVELOPES_PERIOD = 0, ENVELOPES_SHIFT,ENVELOPES_METHOD, 
    ENVELOPES_APPLIED_PRICE, ENVELOPES_DEVIATION_PCT 
   };
// --- Period + Shift + Applied Price - shape shared by FRAMA, DEMA, TEMA.
 enum ENUM_PERIOD_SHIFT_PRICE_PARAM { PSP_PERIOD = 0, PSP_SHIFT, PSP_APPLIED_PRICE };
 enum ENUM_AMA_PARAM           { AMA_PERIOD = 0, AMA_FAST_EMA_PERIOD, AMA_SLOW_EMA_PERIOD, AMA_SHIFT, AMA_APPLIED_PRICE };
 enum ENUM_VIDYA_PARAM         { VIDYA_CMO_PERIOD = 0, VIDYA_EMA_PERIOD, VIDYA_SHIFT, VIDYA_APPLIED_PRICE };
// --- Period + Applied Price - shape shared by RSI, CCI, Momentum.
 enum ENUM_PERIOD_PRICE_PARAM  { PP_PERIOD = 0, PP_APPLIED_PRICE };
// --- Fast/Slow EMA + Signal + Applied Price - shape shared by MACD, OsMA.
 enum ENUM_EMA_SIGNAL_PRICE_PARAM { ESP_FAST_EMA = 0, ESP_SLOW_EMA, ESP_SIGNAL, ESP_APPLIED_PRICE };
 enum ENUM_STOCHASTIC_PARAM    { STOCH_K_PERIOD = 0, STOCH_D_PERIOD, STOCH_SLOWING, STOCH_METHOD, STOCH_PRICE_FIELD };
 enum ENUM_FORCE_PARAM         { FORCE_PERIOD = 0, FORCE_METHOD, FORCE_APPLIED_VOLUME };
 enum ENUM_CHAIKIN_PARAM       { CHAIKIN_FAST_MA_PERIOD = 0, CHAIKIN_SLOW_MA_PERIOD, CHAIKIN_METHOD, CHAIKIN_APPLIED_VOLUME };

// --- Max param count across every standard indicator is 8 (Alligator/Gator:
// --- jaw/teeth/lips period+shift, method, price) - so the form/array must
// --- support at least 8 slots, not 4, to cover every type below.
#define INDICATOR_PARAM_SLOTS_MAX 8
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
   // --- dv is the DEFAULT SELECTED INDEX into ch, not a raw number to type).
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
         E(2,"Method","1",METHOD_CHOICES) E(3,"Applied Price","0",PRICE_CHOICES)
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
         E(6,"Method","2",METHOD_CHOICES) E(7,"Applied Price","4",PRICE_CHOICES)
         return 8;
      case IND_ICHIMOKU:
         I(0,"Tenkan-sen",TYPE_INT,"9") I(1,"Kijun-sen",TYPE_INT,"26")
         I(2,"Senkou Span B",TYPE_INT,"52")
         return 3;
      case IND_ENVELOPES:
         I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
         E(2,"Method","0",METHOD_CHOICES) E(3,"Applied Price","0",PRICE_CHOICES)
         I(4,"Deviation %",TYPE_DOUBLE,"0.1")
         return 5;
      case IND_FRAMA:
         I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
         E(2,"Applied Price","0",PRICE_CHOICES)
         return 3;
      case IND_AMA:
         I(0,"AMA Period",TYPE_INT,"9") I(1,"Fast EMA Period",TYPE_INT,"2")
         I(2,"Slow EMA Period",TYPE_INT,"30") I(3,"Shift",TYPE_INT,"0")
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
         I(0,"Period",TYPE_INT,"20") I(1,"Shift",TYPE_INT,"0")
         E(2,"Method","0",METHOD_CHOICES) E(3,"Applied Price","0",PRICE_CHOICES)
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
         I(0,"%K Period",TYPE_INT,"5") I(1,"%D Period",TYPE_INT,"3")
         I(2,"Slowing",TYPE_INT,"3") E(3,"Method","0",METHOD_CHOICES)
         E(4,"Price Field","0",STOCH_PRICE_CHOICES)
         return 5;
      case IND_CCI:
         I(0,"Period",TYPE_INT,"14") E(1,"Applied Price","5",PRICE_CHOICES)
         return 2;
      case IND_MOMENTUM:
         I(0,"Period",TYPE_INT,"14") E(1,"Applied Price","0",PRICE_CHOICES)
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
         I(0,"Fast EMA Period",TYPE_INT,"12") I(1,"Slow EMA Period",TYPE_INT,"26")
         I(2,"Signal Period",TYPE_INT,"9") E(3,"Applied Price","0",PRICE_CHOICES)
         return 4;
      case IND_TRIX:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_ATR:
         I(0,"Period",TYPE_INT,"14")
         return 1;
      case IND_FORCE:
         I(0,"Period",TYPE_INT,"13") E(1,"Method","1",METHOD_CHOICES)
         E(2,"Applied Volume","0",VOLUME_CHOICES)
         return 3;
      case IND_AO:
         return 0;
      case IND_AC:
         return 0;
      case IND_GATOR:
         I(0,"Jaw Period",TYPE_INT,"13")  I(1,"Jaw Shift",TYPE_INT,"8")
         I(2,"Teeth Period",TYPE_INT,"8") I(3,"Teeth Shift",TYPE_INT,"5")
         I(4,"Lips Period",TYPE_INT,"5")  I(5,"Lips Shift",TYPE_INT,"3")
         E(6,"Method","2",METHOD_CHOICES) E(7,"Applied Price","4",PRICE_CHOICES)
         return 8;
      case IND_BEARS:
         I(0,"Period",TYPE_INT,"13")
         return 1;
      case IND_BULLS:
         I(0,"Period",TYPE_INT,"13")
         return 1;
      case IND_CHAIKIN:
         I(0,"Fast MA Period",TYPE_INT,"3") I(1,"Slow MA Period",TYPE_INT,"10")
         E(2,"Method","1",METHOD_CHOICES) E(3,"Applied Volume","0",VOLUME_CHOICES)
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
// Builds a compact, human-readable label for the indicator table: short catalog
// name + decoded params (named, not bare positional numbers). Falls back to a
// generic "(value, value, ...)" dump for types that don't have a custom case yet.
string FormatIndicatorLabel(const ENUM_INDICATOR type, const string &short_name, MqlParam &params[])
  {
   switch(type)
     {
      case IND_SAR:
         if(ArraySize(params) < 2) break;
         return short_name + "  Step=" + DoubleToString(params[0].double_value, 2) +
                ", Max=" + DoubleToString(params[1].double_value, 2);
      case IND_MA:
        {
         if(ArraySize(params) < 4) break;
         string methods[4] = {"SMA", "EMA", "SMMA", "LWMA"};
         string prices[7]  = {"Close", "Open", "High", "Low", "Median", "Typical", "WClose"};
         int m = (int)params[2].integer_value;
         int p = (int)params[3].integer_value;
         string mname = (m >= 0 && m < 4) ? methods[m] : "?";
         string pname = (p >= 0 && p < 7) ? prices[p] : "?";
         return short_name + "  Period=" + IntegerToString((int)params[0].integer_value) +
                ", Method=" + mname + ", Price=" + pname +
                ", Shift=" + IntegerToString((int)params[1].integer_value);
        }
      default:
         break;
     }
   // --- Fallback: generic positional dump for types without a custom case above yet
   string values = "";
   for(int i = 0; i < ArraySize(params); i++)
     {
      if(i > 0) values += ", ";
      values += (params[i].type == TYPE_DOUBLE)
                 ? DoubleToString(params[i].double_value, 2)
                 : IntegerToString((int)params[i].integer_value);
     }
   return short_name + (values != "" ? "  (" + values + ")" : "");
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

#endif // __INDICATORCATALOG_MQH__
