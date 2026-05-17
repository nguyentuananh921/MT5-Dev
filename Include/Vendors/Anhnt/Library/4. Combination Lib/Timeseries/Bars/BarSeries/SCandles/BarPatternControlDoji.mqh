//+------------------------------------------------------------------+
//|                                     BarPatternControlDoji.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLDOJI_MQH__
#define __BARPATTERNCONTROLDOJI_MQH__
 #property strict    // Necessary for mql4
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternDoji.mqh"

 //--- m_ratio_body_to_candle_size → max body ratio for doji (default 0.05)
 #ifndef CBarPatternControlDoji_MQH_DECLARATION
 #define CBarPatternControlDoji_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Doji control (1-candle indecision, open ≈ close)                 |
  //+------------------------------------------------------------------+
  class CBarPatternControlDoji : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_DOJI + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);
    public:
        //    param[0] int:    0 (not used)
        //    param[1] double: max body/candle ratio for doji    (default 0.05)
                              CBarPatternControlDoji(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                     CArrayObj *list_series, CArrayObj *list_patterns,
                                                     const MqlParam &param[]);
   };
 #endif // CBarPatternControlDoji_MQH_DECLARATION
 #ifndef CBarPatternControlDoji_MQH_IMPLEMENTATION
 #define CBarPatternControlDoji_MQH_IMPLEMENTATION
   CBarPatternControlDoji::CBarPatternControlDoji(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                   CArrayObj *list_series, CArrayObj *list_patterns,
                                                   const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_DOJI,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_DOJI_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = 0;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   ulong CBarPatternControlDoji::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue() * 100);
      long   res = 0;
      return this.UshortToLong(c1, 0, res);
     }
   CBarPattern *CBarPatternControlDoji::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                       const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternDoji *obj = new CPatternDoji(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                   bar.RatioBodyToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,         this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Doji: body ratio <= threshold                         |
   //| Direction: BULLISH if lower shadow >= upper, else BEARISH        |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlDoji::FindPattern(const datetime series_bar_time,
                                                               MqlRates &mother_bar_data) const
    {
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, series_bar_time, EQUAL);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE, this.RatioBodyToCandleSizeValue(), EQUAL_OR_LESS);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      CBar *bar = list.At(0);
      if(bar == NULL) return WRONG_VALUE;
      this.SetBarData(bar, mother_bar_data);
      return (bar.RatioLowerShadowToCandleSize() >= bar.RatioUpperShadowToCandleSize())
             ? PATTERN_DIRECTION_BULLISH
             : PATTERN_DIRECTION_BEARISH;
    }
   CArrayObj *CBarPatternControlDoji::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),     EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),        EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_DOJI,    EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),      EQUAL);
     }
 #endif // CBarPatternControlDoji_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLDOJI_MQH__
