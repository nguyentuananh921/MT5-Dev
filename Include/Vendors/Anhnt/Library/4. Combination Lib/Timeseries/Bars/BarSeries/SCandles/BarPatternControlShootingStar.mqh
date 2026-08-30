//+------------------------------------------------------------------+
//|                              BarPatternControlShootingStar.mqh   |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLSHOOTINGSTAR_MQH__
#define __BARPATTERNCONTROLSHOOTINGSTAR_MQH__
 #property strict    // Necessary for mql4
 #include "BarPatternControlInvertedHammer.mqh"
 #include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternShootingStar.mqh"

 //--- Same shape as Inverted Hammer; only direction and pattern type differ.
 #ifndef CBarPatternControlShootingStar_MQH_DECLARATION
 #define CBarPatternControlShootingStar_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Shooting Star control — inherits InvertedHammer, returns BEARISH |
  //+------------------------------------------------------------------+
  class CBarPatternControlShootingStar : public CBarPatternControlInvertedHammer
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_SHOOTING_STAR + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
    public:
                              CBarPatternControlShootingStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                             CArrayObj *list_series, CArrayObj *list_patterns,
                                                             const MqlParam &param[]);
   };
 #endif // CBarPatternControlShootingStar_MQH_DECLARATION
 #ifndef CBarPatternControlShootingStar_MQH_IMPLEMENTATION
 #define CBarPatternControlShootingStar_MQH_IMPLEMENTATION
   CBarPatternControlShootingStar::CBarPatternControlShootingStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                   CArrayObj *list_series, CArrayObj *list_patterns,
                                                                   const MqlParam &param[]) :
    CBarPatternControlInvertedHammer(symbol, timeframe, list_series, list_patterns, param)
    {
     // --- CBarPatternControlInvertedHammer's own constructor hardcodes PATTERN_TYPE_INVERTED_HAMMER
     // --- - fix up this instance's real identity (Anhnt, 2026-08-29).
     this.SetTypePattern(PATTERN_TYPE_SHOOTING_STAR);
    }
   ENUM_PATTERN_DIRECTION CBarPatternControlShootingStar::FindPattern(const datetime series_bar_time,
                                                                        MqlRates &mother_bar_data) const
    {
      ENUM_PATTERN_DIRECTION dir = CBarPatternControlInvertedHammer::FindPattern(series_bar_time, mother_bar_data);
      return (dir == PATTERN_DIRECTION_BULLISH) ? PATTERN_DIRECTION_BEARISH : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
    }
   CBarPattern *CBarPatternControlShootingStar::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                               const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternShootingStar *obj = new CPatternShootingStar(id, this.Symbol(), this.Timeframe(), rates, direction);
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
   CArrayObj *CBarPatternControlShootingStar::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                   EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_SHOOTING_STAR,      EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                 EQUAL);
     }
 #endif // CBarPatternControlShootingStar_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLSHOOTINGSTAR_MQH__
