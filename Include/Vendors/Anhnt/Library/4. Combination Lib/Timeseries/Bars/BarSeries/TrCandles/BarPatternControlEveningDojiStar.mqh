//+------------------------------------------------------------------+
//|                            BarPatternControlEveningDojiStar.mqh  |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLEVENINGDOJISTAR_MQH__
#define __BARPATTERNCONTROLEVENINGDOJISTAR_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "BarPatternControlEveningStar.mqh"
 #include "..\..\BarSeriesPatterns\TrCandlesPatterns\PatternEveningDojiStar.mqh"

 //--- Inherits all detection logic from CBarPatternControlEveningStar.
 //--- Only param[2] should be set very small (e.g. 0.05) to require a real Doji.
 #ifndef CBarPatternControlEveningDojiStar_MQH_DECLARATION
 #define CBarPatternControlEveningDojiStar_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Evening Doji Star control — inherits FindPattern from EveningStar |
  //+------------------------------------------------------------------+
  class CBarPatternControlEveningDojiStar : public CBarPatternControlEveningStar
   {
    protected:
        //--- Override: create CPatternEveningDojiStar instead of CPatternEveningStar
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
        //--- Override: use PATTERN_TYPE_EVENING_DOJI_STAR in the unique code
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_EVENING_DOJI_STAR + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
        //--- Override: filter list by PATTERN_TYPE_EVENING_DOJI_STAR
          virtual CArrayObj             *GetListPatterns(void);

    public:
        //--- Parametric constructor (same params as EveningStar; set param[2] small for strict Doji)
        //    param[0] int:    min body size in points for candle 1
        //    param[1] double: min body/candle ratio for candle 1    (large bullish,  default 0.60)
        //    param[2] double: max body/candle ratio for candle 2    (Doji,           default 0.05)
        //    param[3] double: min penetration into candle 1 body    (candle 3,       default 0.50)
                              CBarPatternControlEveningDojiStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                CArrayObj *list_series, CArrayObj *list_patterns,
                                                                const MqlParam &param[]);
   };
 #endif // CBarPatternControlEveningDojiStar_MQH_DECLARATION
 #ifndef CBarPatternControlEveningDojiStar_MQH_IMPLEMENTATION
 #define CBarPatternControlEveningDojiStar_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlEveningDojiStar::CBarPatternControlEveningDojiStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                         CArrayObj *list_series, CArrayObj *list_patterns,
                                                                         const MqlParam &param[]) :
    CBarPatternControlEveningStar(symbol, timeframe, list_series, list_patterns, param)
    {
    }
   //+------------------------------------------------------------------+
   //| Create a CPatternEveningDojiStar object                          |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlEveningDojiStar::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                  const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternEveningDojiStar *obj = new CPatternEveningDojiStar(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioSmallerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Return the list of Evening Doji Star patterns                    |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlEveningDojiStar::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                    EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                       EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_EVENING_DOJI_STAR,      EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                     EQUAL);
     }
 #endif // CBarPatternControlEveningDojiStar_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLEVENINGDOJISTAR_MQH__
