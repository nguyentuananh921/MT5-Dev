//+------------------------------------------------------------------+
//|                                BarPatternControlHangingMan.mqh   |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLHANGINGMAN_MQH__
#define __BARPATTERNCONTROLHANGINGMAN_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "BarPatternControlHammer.mqh"
 #include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternHangingMan.mqh"

 //--- Same shape as Hammer; only direction and pattern type differ.
 #ifndef CBarPatternControlHangingMan_MQH_DECLARATION
 #define CBarPatternControlHangingMan_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Hanging Man control — inherits Hammer shape, returns BEARISH     |
  //+------------------------------------------------------------------+
  class CBarPatternControlHangingMan : public CBarPatternControlHammer
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_HANGING_MAN + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
    public:
                              CBarPatternControlHangingMan(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                           CArrayObj *list_series, CArrayObj *list_patterns,
                                                           const MqlParam &param[]);
   };
 #endif // CBarPatternControlHangingMan_MQH_DECLARATION
 #ifndef CBarPatternControlHangingMan_MQH_IMPLEMENTATION
 #define CBarPatternControlHangingMan_MQH_IMPLEMENTATION
   CBarPatternControlHangingMan::CBarPatternControlHangingMan(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                               CArrayObj *list_series, CArrayObj *list_patterns,
                                                               const MqlParam &param[]) :
    CBarPatternControlHammer(symbol, timeframe, list_series, list_patterns, param)
    {
    }
   //+------------------------------------------------------------------+
   //| Same shape as Hammer; return BEARISH                             |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlHangingMan::FindPattern(const datetime series_bar_time,
                                                                     MqlRates &mother_bar_data) const
    {
      ENUM_PATTERN_DIRECTION dir = CBarPatternControlHammer::FindPattern(series_bar_time, mother_bar_data);
      return (dir == PATTERN_DIRECTION_BULLISH) ? PATTERN_DIRECTION_BEARISH : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
    }
   CBarPattern *CBarPatternControlHangingMan::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                             const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternHangingMan *obj = new CPatternHangingMan(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      bar.RatioBodyToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              bar.RatioLowerShadowToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              bar.RatioUpperShadowToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioSmallerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   CArrayObj *CBarPatternControlHangingMan::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),            EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),               EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_HANGING_MAN,    EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),             EQUAL);
     }
 #endif // CBarPatternControlHangingMan_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLHANGINGMAN_MQH__
