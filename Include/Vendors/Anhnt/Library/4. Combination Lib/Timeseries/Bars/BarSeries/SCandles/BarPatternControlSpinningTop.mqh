//+------------------------------------------------------------------+
//|                              BarPatternControlSpinningTop.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLSPINNINGTOP_MQH__
#define __BARPATTERNCONTROLSPINNINGTOP_MQH__
 #property strict    // Necessary for mql4
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternSpinningTop.mqh"

 //--- Field reuse for Spinning Top (stored in base class protected fields):
 //    m_ratio_body_to_candle_size          → max body ratio               (small body, default PATTERN_DEF_SPINNING_TOP_BODY)
 //    m_ratio_larger_shadow_to_candle_size → min ratio EACH shadow needs  (both roughly balanced, default PATTERN_DEF_SPINNING_TOP_SHADOW)
 //    m_ratio_smaller_shadow_to_candle_size unused (no larger/smaller distinction here - both shadows use the same min threshold)
 #ifndef CBarPatternControlSpinningTop_MQH_DECLARATION
 #define CBarPatternControlSpinningTop_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Spinning Top control (1-candle indecision)                       |
  //+------------------------------------------------------------------+
  class CBarPatternControlSpinningTop : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_SPINNING_TOP + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);

    public:
        //    param[0] int:    min body size in points
        //    param[1] double: max body/candle ratio               (small body,          default 35.0)
        //    param[2] double: min ratio EACH shadow must reach    (both must be long,   default 25.0)
                              CBarPatternControlSpinningTop(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                            CArrayObj *list_series, CArrayObj *list_patterns,
                                                            const MqlParam &param[]);
   };
 #endif // CBarPatternControlSpinningTop_MQH_DECLARATION
 #ifndef CBarPatternControlSpinningTop_MQH_IMPLEMENTATION
 #define CBarPatternControlSpinningTop_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlSpinningTop::CBarPatternControlSpinningTop(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                       CArrayObj *list_series, CArrayObj *list_patterns,
                                                       const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_SPINNING_TOP,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_SPINNING_TOP_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_SPINNING_TOP_SHADOW;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID                                                 |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlSpinningTop::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue()          * 100);
      ushort c2 = (ushort)(this.RatioLargerShadowToCandleSizeValue()  * 100);
      long   res = 0;
      this.UshortToLong(c1, 0, res);
      return this.UshortToLong(c2, 1, res);
     }
   //+------------------------------------------------------------------+
   //| Create pattern object                                            |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlSpinningTop::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                         const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternSpinningTop *obj = new CPatternSpinningTop(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      bar.RatioBodyToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              bar.RatioLowerShadowToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              bar.RatioUpperShadowToCandleSize());
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Spinning Top: small body, BOTH shadows long           |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlSpinningTop::FindPattern(const datetime series_bar_time,
                                                                  MqlRates &mother_bar_data) const
    {
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, series_bar_time, EQUAL);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
     //--- Small body
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE, this.RatioBodyToCandleSizeValue(), EQUAL_OR_LESS);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
     //--- Lower shadow must reach the min ratio
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE, this.RatioLargerShadowToCandleSizeValue(), EQUAL_OR_MORE);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
     //--- Upper shadow must ALSO reach the min ratio (both roughly balanced, unlike Hammer's one-sided shadow)
      list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE, this.RatioLargerShadowToCandleSizeValue(), EQUAL_OR_MORE);
      if(list == NULL || list.Total() == 0) return WRONG_VALUE;
      CBar *bar = list.At(0);
      if(bar == NULL) return WRONG_VALUE;
      this.SetBarData(bar, mother_bar_data);
     //--- Indecision candle - no inherent direction from the shape alone; break the tie the same
     //--- way Doji does (whichever shadow is longer), so it stays alert-capable like every other
     //--- pattern here instead of silently never firing under PATTERN_DIRECTION_BOTH.
      return (bar.RatioLowerShadowToCandleSize() >= bar.RatioUpperShadowToCandleSize())
             ? PATTERN_DIRECTION_BULLISH
             : PATTERN_DIRECTION_BEARISH;
    }
   //+------------------------------------------------------------------+
   //| Return list of Spinning Top patterns                             |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlSpinningTop::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),        EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),           EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_SPINNING_TOP, EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),         EQUAL);
     }
 #endif // CBarPatternControlSpinningTop_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLSPINNINGTOP_MQH__
