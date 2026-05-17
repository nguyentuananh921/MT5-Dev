//+------------------------------------------------------------------+
//|                            BarPatternControlInvertedHammer.mqh   |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLINVERTEDHAMMER_MQH__
#define __BARPATTERNCONTROLINVERTEDHAMMER_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternInvertedHammer.mqh"

 //--- Field reuse for Inverted Hammer:
 //    m_ratio_body_to_candle_size          → max body ratio        (small body,        default 0.35)
 //    m_ratio_larger_shadow_to_candle_size → min upper shadow ratio (long upper shadow, default 0.55)
 //    m_ratio_smaller_shadow_to_candle_size→ max lower shadow ratio (short lower shadow,default 0.10)
 #ifndef CBarPatternControlInvertedHammer_MQH_DECLARATION
 #define CBarPatternControlInvertedHammer_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Inverted Hammer control (1-candle bullish, long upper shadow)    |
  //+------------------------------------------------------------------+
  class CBarPatternControlInvertedHammer : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_INVERTED_HAMMER + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);
    public:
        //    param[0] int:    min body size in points
        //    param[1] double: max body/candle ratio          (small body,         default 0.35)
        //    param[2] double: min upper shadow/candle ratio  (long upper shadow,  default 0.55)
        //    param[3] double: max lower shadow/candle ratio  (short lower shadow, default 0.10)
                              CBarPatternControlInvertedHammer(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                               CArrayObj *list_series, CArrayObj *list_patterns,
                                                               const MqlParam &param[]);
   };
 #endif // CBarPatternControlInvertedHammer_MQH_DECLARATION
 #ifndef CBarPatternControlInvertedHammer_MQH_IMPLEMENTATION
 #define CBarPatternControlInvertedHammer_MQH_IMPLEMENTATION
   CBarPatternControlInvertedHammer::CBarPatternControlInvertedHammer(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                       CArrayObj *list_series, CArrayObj *list_patterns,
                                                                       const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_INVERTED_HAMMER,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_SMALL_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_LONG_SHADOW;
    this.m_ratio_smaller_shadow_to_candle_size = PATTERN_DEF_SHORT_SHADOW;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   ulong CBarPatternControlInvertedHammer::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue()          * 100);
      ushort c2 = (ushort)(this.RatioLargerShadowToCandleSizeValue()  * 100);
      ushort c3 = (ushort)(this.RatioSmallerShadowToCandleSizeValue() * 100);
      long   res = 0;
      this.UshortToLong(c1, 0, res);
      this.UshortToLong(c2, 1, res);
      return this.UshortToLong(c3, 2, res);
     }
   CBarPattern *CBarPatternControlInvertedHammer::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                 const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternInvertedHammer *obj = new CPatternInvertedHammer(id, this.Symbol(), this.Timeframe(), rates, direction);
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
   //+------------------------------------------------------------------+
   //| Search for Inverted Hammer: small body, long upper, short lower  |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlInvertedHammer::FindPattern(const datetime series_bar_time,
                                                                          MqlRates &mother_bar_data) const
    {
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, series_bar_time, EQUAL);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
     //--- Small body
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE, this.RatioBodyToCandleSizeValue(), EQUAL_OR_LESS);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
     //--- Long upper shadow
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE, this.RatioLargerShadowToCandleSizeValue(), EQUAL_OR_MORE);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
     //--- Short lower shadow
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE, this.RatioSmallerShadowToCandleSizeValue(), EQUAL_OR_LESS);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      CBar *bar = list.At(0);
      if(bar == NULL) return WRONG_VALUE;
      this.SetBarData(bar, mother_bar_data);
      return PATTERN_DIRECTION_BULLISH;
    }
   CArrayObj *CBarPatternControlInvertedHammer::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                   EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                      EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_INVERTED_HAMMER,       EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                    EQUAL);
     }
 #endif // CBarPatternControlInvertedHammer_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLINVERTEDHAMMER_MQH__
