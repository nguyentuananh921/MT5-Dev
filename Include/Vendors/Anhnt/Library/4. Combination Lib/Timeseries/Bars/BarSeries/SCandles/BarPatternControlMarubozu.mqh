//+------------------------------------------------------------------+
//|                                  BarPatternControlMarubozu.mqh   |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLMARUBOZU_MQH__
#define __BARPATTERNCONTROLMARUBOZU_MQH__
 #property strict    // Necessary for mql4
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternMarubozu.mqh"

 //--- Field reuse for Marubozu (stored in base class protected fields):
 //    m_ratio_body_to_candle_size → min body ratio (default PATTERN_DEF_MARUBOZU_BODY) - little/no shadow either side
 #ifndef CBarPatternControlMarubozu_MQH_DECLARATION
 #define CBarPatternControlMarubozu_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Marubozu control (1-candle, full-body continuation/strength)     |
  //+------------------------------------------------------------------+
  class CBarPatternControlMarubozu : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_MARUBOZU + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);

    public:
        //    param[0] int:    min body size in points
        //    param[1] double: min body/candle ratio    (large/full body, default 90.0)
                              CBarPatternControlMarubozu(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                         CArrayObj *list_series, CArrayObj *list_patterns,
                                                         const MqlParam &param[]);
   };
 #endif // CBarPatternControlMarubozu_MQH_DECLARATION
 #ifndef CBarPatternControlMarubozu_MQH_IMPLEMENTATION
 #define CBarPatternControlMarubozu_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlMarubozu::CBarPatternControlMarubozu(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                       CArrayObj *list_series, CArrayObj *list_patterns,
                                                       const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_MARUBOZU,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_MARUBOZU_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = 0;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID                                                 |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlMarubozu::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue() * 100);
      long   res = 0;
      return this.UshortToLong(c1, 0, res);
     }
   //+------------------------------------------------------------------+
   //| Create pattern object                                            |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlMarubozu::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                         const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternMarubozu *obj = new CPatternMarubozu(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      bar.RatioBodyToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Marubozu: large body, little/no shadow either side.   |
   //| Direction follows the candle's own color (unlike Hammer/Doji     |
   //| variants, a full body IS the directional signal here).           |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlMarubozu::FindPattern(const datetime series_bar_time,
                                                                  MqlRates &mother_bar_data) const
    {
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, series_bar_time, EQUAL);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
     //--- Large/full body
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE, this.RatioBodyToCandleSizeValue(), EQUAL_OR_MORE);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      CBar *bar = list.At(0);
      if(bar == NULL) return WRONG_VALUE;
      this.SetBarData(bar, mother_bar_data);
      if(bar.TypeBody() == BAR_BODY_TYPE_BULLISH) return PATTERN_DIRECTION_BULLISH;
      if(bar.TypeBody() == BAR_BODY_TYPE_BEARISH) return PATTERN_DIRECTION_BEARISH;
      return WRONG_VALUE;
    }
   //+------------------------------------------------------------------+
   //| Return list of Marubozu patterns                                 |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlMarubozu::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),      EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),         EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_MARUBOZU, EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),       EQUAL);
     }
 #endif // CBarPatternControlMarubozu_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLMARUBOZU_MQH__
