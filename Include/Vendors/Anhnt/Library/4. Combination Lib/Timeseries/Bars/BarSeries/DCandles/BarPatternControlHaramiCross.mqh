//+------------------------------------------------------------------+
//|                               BarPatternControlHaramiCross.mqh   |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLHARAMICROSS_MQH__
#define __BARPATTERNCONTROLHARAMICROSS_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "BarPatternControlHarami.mqh"
 #include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternHaramiCross.mqh"

 //--- Inherits all detection logic from CBarPatternControlHarami.
 //--- Only param[2] should be set very small (e.g. 0.05) to require a real Doji.
 #ifndef CBarPatternControlHaramiCross_MQH_DECLARATION
 #define CBarPatternControlHaramiCross_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Harami Cross control — inherits FindPattern from Harami          |
  //+------------------------------------------------------------------+
  class CBarPatternControlHaramiCross : public CBarPatternControlHarami
   {
    protected:
        //--- Override: create CPatternHaramiCross instead of CPatternHarami
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
        //--- Override: use PATTERN_TYPE_HARAMI_CROSS in the unique code
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_HARAMI_CROSS + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
        //--- Override: filter list by PATTERN_TYPE_HARAMI_CROSS
          virtual CArrayObj             *GetListPatterns(void);

    public:
        //--- Parametric constructor (same params as Harami; set param[2] small for strict Doji)
        //    param[0] int:    min body size in points for candle 1
        //    param[1] double: min body/candle ratio for candle 1    (large mother candle, default 0.60)
        //    param[2] double: max body/candle ratio for candle 2    (Doji,                default 0.05)
                              CBarPatternControlHaramiCross(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                            CArrayObj *list_series, CArrayObj *list_patterns,
                                                            const MqlParam &param[]);
   };
 #endif // CBarPatternControlHaramiCross_MQH_DECLARATION
 #ifndef CBarPatternControlHaramiCross_MQH_IMPLEMENTATION
 #define CBarPatternControlHaramiCross_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlHaramiCross::CBarPatternControlHaramiCross(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                  CArrayObj *list_series, CArrayObj *list_patterns,
                                                                  const MqlParam &param[]) :
    CBarPatternControlHarami(symbol, timeframe, list_series, list_patterns, param)
    {
    // --- CBarPatternControlHarami's own constructor hardcodes PATTERN_TYPE_HARAMI - fix up this
    // --- instance's real identity (Anhnt, 2026-08-29).
    this.SetTypePattern(PATTERN_TYPE_HARAMI_CROSS);
    this.m_ratio_larger_shadow_to_candle_size = PATTERN_DEF_DOJI_BODY;
    this.m_object_id                          = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create a CPatternHaramiCross object                              |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlHaramiCross::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                              const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternHaramiCross *obj = new CPatternHaramiCross(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Return the list of Harami Cross patterns                         |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlHaramiCross::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),              EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                 EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_HARAMI_CROSS,     EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),               EQUAL);
     }
 #endif // CBarPatternControlHaramiCross_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLHARAMICROSS_MQH__
