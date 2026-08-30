//+------------------------------------------------------------------+
//|                             BarPatternControlMorningDojiStar.mqh |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLMORNINGDOJISTAR_MQH__
#define __BARPATTERNCONTROLMORNINGDOJISTAR_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "BarPatternControlMorningStar.mqh"
 #include "..\..\BarSeriesPatterns\TrCandlesPatterns\PatternMorningDojiStar.mqh"

 //--- Inherits all detection logic from CBarPatternControlMorningStar.
 //--- Only param[2] should be set very small (e.g. 0.05) to require a real Doji.
 #ifndef CBarPatternControlMorningDojiStar_MQH_DECLARATION
 #define CBarPatternControlMorningDojiStar_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Morning Doji Star control — inherits FindPattern from MorningStar |
  //+------------------------------------------------------------------+
  class CBarPatternControlMorningDojiStar : public CBarPatternControlMorningStar
   {
    protected:
        //--- Override: create CPatternMorningDojiStar instead of CPatternMorningStar
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
        //--- Override: use PATTERN_TYPE_MORNING_DOJI_STAR in the unique code
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_MORNING_DOJI_STAR + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
        //--- Override: filter list by PATTERN_TYPE_MORNING_DOJI_STAR
          virtual CArrayObj             *GetListPatterns(void);

    public:
        //--- Parametric constructor (same params as MorningStar; set param[2] small for strict Doji)
        //    param[0] int:    min body size in points for candle 1
        //    param[1] double: min body/candle ratio for candle 1    (large bearish, default 0.60)
        //    param[2] double: max body/candle ratio for candle 2    (Doji,          default 0.05)
        //    param[3] double: min penetration into candle 1 body    (candle 3,      default 0.50)
                              CBarPatternControlMorningDojiStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                CArrayObj *list_series, CArrayObj *list_patterns,
                                                                const MqlParam &param[]);
   };
 #endif // CBarPatternControlMorningDojiStar_MQH_DECLARATION
 #ifndef CBarPatternControlMorningDojiStar_MQH_IMPLEMENTATION
 #define CBarPatternControlMorningDojiStar_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlMorningDojiStar::CBarPatternControlMorningDojiStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                         CArrayObj *list_series, CArrayObj *list_patterns,
                                                                         const MqlParam &param[]) :
    CBarPatternControlMorningStar(symbol, timeframe, list_series, list_patterns, param)
    {
    // --- CBarPatternControlMorningStar's own constructor hardcodes PATTERN_TYPE_MORNING_STAR
    // --- - fix up this instance's real identity (Anhnt, 2026-08-29).
    this.SetTypePattern(PATTERN_TYPE_MORNING_DOJI_STAR);
    this.m_ratio_larger_shadow_to_candle_size = PATTERN_DEF_DOJI_BODY;
    this.m_object_id                          = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create a CPatternMorningDojiStar object                          |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlMorningDojiStar::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                  const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternMorningDojiStar *obj = new CPatternMorningDojiStar(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioSmallerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Return the list of Morning Doji Star patterns                    |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlMorningDojiStar::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                   EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                      EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_MORNING_DOJI_STAR,     EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                    EQUAL);
     }
 #endif // CBarPatternControlMorningDojiStar_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLMORNINGDOJISTAR_MQH__
