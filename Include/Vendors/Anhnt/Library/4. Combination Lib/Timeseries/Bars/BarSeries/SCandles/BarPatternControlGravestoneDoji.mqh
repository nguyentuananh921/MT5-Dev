//+------------------------------------------------------------------+
//|                           BarPatternControlGravestoneDoji.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLGRAVESTONEDOJI_MQH__
#define __BARPATTERNCONTROLGRAVESTONEDOJI_MQH__
 #property strict    // Necessary for mql4
 #include "BarPatternControlDoji.mqh"
 #include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternGravestoneDoji.mqh"

 //--- Inherits Doji (body check). Adds: long upper shadow, near-zero lower shadow.
 //    m_ratio_larger_shadow_to_candle_size → min upper shadow ratio (default 0.70)
 //    m_ratio_smaller_shadow_to_candle_size→ max lower shadow ratio (default 0.05)
 #ifndef CBarPatternControlGravestoneDoji_MQH_DECLARATION
 #define CBarPatternControlGravestoneDoji_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Gravestone Doji control (doji + long upper shadow)               |
  //+------------------------------------------------------------------+
  class CBarPatternControlGravestoneDoji : public CBarPatternControlDoji
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_GRAVESTONE_DOJI + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
    public:
        //    param[0] int:    0 (not used)
        //    param[1] double: max body ratio          (doji threshold,    default 0.05)
        //    param[2] double: min upper shadow ratio  (long upper shadow, default 0.70)
        //    param[3] double: max lower shadow ratio  (near-zero lower,   default 0.05)
                              CBarPatternControlGravestoneDoji(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                               CArrayObj *list_series, CArrayObj *list_patterns,
                                                               const MqlParam &param[]);
   };
 #endif // CBarPatternControlGravestoneDoji_MQH_DECLARATION
 #ifndef CBarPatternControlGravestoneDoji_MQH_IMPLEMENTATION
 #define CBarPatternControlGravestoneDoji_MQH_IMPLEMENTATION
   CBarPatternControlGravestoneDoji::CBarPatternControlGravestoneDoji(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                       CArrayObj *list_series, CArrayObj *list_patterns,
                                                                       const MqlParam &param[]) :
    CBarPatternControlDoji(symbol, timeframe, list_series, list_patterns, param)
    {
    // --- CBarPatternControlDoji's own constructor hardcodes PATTERN_TYPE_DOJI - fix up this
    // --- instance's real identity (Anhnt, 2026-08-29).
    this.SetTypePattern(PATTERN_TYPE_GRAVESTONE_DOJI);
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_DEEP_SHADOW;
    this.m_ratio_smaller_shadow_to_candle_size = PATTERN_DEF_DOJI_BODY;
    this.m_object_id = this.CreateObjectID();
    }
   ENUM_PATTERN_DIRECTION CBarPatternControlGravestoneDoji::FindPattern(const datetime series_bar_time,
                                                                          MqlRates &mother_bar_data) const
    {
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, series_bar_time, EQUAL);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,          this.RatioBodyToCandleSizeValue(),         EQUAL_OR_LESS);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,  this.RatioLargerShadowToCandleSizeValue(), EQUAL_OR_MORE);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,  this.RatioSmallerShadowToCandleSizeValue(),EQUAL_OR_LESS);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      CBar *bar = list.At(0);
      if(bar == NULL) return WRONG_VALUE;
      this.SetBarData(bar, mother_bar_data);
      return PATTERN_DIRECTION_BEARISH;
    }
   CBarPattern *CBarPatternControlGravestoneDoji::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                  const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternGravestoneDoji *obj = new CPatternGravestoneDoji(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      bar.RatioBodyToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              bar.RatioUpperShadowToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              bar.RatioLowerShadowToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioSmallerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   CArrayObj *CBarPatternControlGravestoneDoji::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                   EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                      EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_GRAVESTONE_DOJI,       EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                    EQUAL);
     }
 #endif // CBarPatternControlGravestoneDoji_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLGRAVESTONEDOJI_MQH__
