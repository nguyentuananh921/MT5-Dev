//+------------------------------------------------------------------+
//|                              BarPatternControlPiercingLine.mqh   |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLPIERCINGLINE_MQH__
#define __BARPATTERNCONTROLPIERCINGLINE_MQH__
 #property strict    // Necessary for mql4
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternPiercingLine.mqh"

 //--- Field reuse for Piercing Line:
 //    m_ratio_body_to_candle_size          → min body ratio for bar0 (large bearish, default 0.60)
 //    m_ratio_smaller_shadow_to_candle_size→ min penetration into bar0's body  (default 0.50)
 #ifndef CBarPatternControlPiercingLine_MQH_DECLARATION
 #define CBarPatternControlPiercingLine_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Piercing Line control (2-candle bullish reversal)                |
  //+------------------------------------------------------------------+
  class CBarPatternControlPiercingLine : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_PIERCING_LINE + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);
    public:
        //    param[0] int:    min body size in points for bar0
        //    param[1] double: min body/candle ratio for bar0     (large bearish,  default 0.60)
        //    param[2] double: min penetration into bar0's body   (default 0.50)
                              CBarPatternControlPiercingLine(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                             CArrayObj *list_series, CArrayObj *list_patterns,
                                                             const MqlParam &param[]);
   };
 #endif // CBarPatternControlPiercingLine_MQH_DECLARATION
 #ifndef CBarPatternControlPiercingLine_MQH_IMPLEMENTATION
 #define CBarPatternControlPiercingLine_MQH_IMPLEMENTATION
   CBarPatternControlPiercingLine::CBarPatternControlPiercingLine(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                   CArrayObj *list_series, CArrayObj *list_patterns,
                                                                   const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_PIERCING_LINE,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = 0;
    this.m_ratio_smaller_shadow_to_candle_size = PATTERN_DEF_PENETRATION;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   ulong CBarPatternControlPiercingLine::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue()          * 100);
      ushort c2 = (ushort)(this.RatioSmallerShadowToCandleSizeValue() * 100);
      long   res = 0;
      this.UshortToLong(c1, 0, res);
      return this.UshortToLong(c2, 1, res);
     }
   CBarPattern *CBarPatternControlPiercingLine::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                               const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternPiercingLine *obj = new CPatternPiercingLine(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION, this.RatioSmallerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| bar0: large bearish; bar1: bullish, closes above midpoint bar0   |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlPiercingLine::FindPattern(const datetime series_bar_time,
                                                                        MqlRates &mother_bar_data) const
    {
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 2) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
      CBar *bar1 = list.At(n - 1);
      CBar *bar0 = list.At(n - 2);
      if(bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

     //--- bar0: large bearish
      if(bar0.TypeBody() != BAR_BODY_TYPE_BEARISH)               return WRONG_VALUE;
      if(bar0.RatioBodyToCandleSize() < this.RatioBodyToCandleSizeValue()) return WRONG_VALUE;

     //--- bar1: bullish
      if(bar1.TypeBody() != BAR_BODY_TYPE_BULLISH)               return WRONG_VALUE;

     //--- bar1 opens at or below bar0's close (bottom of bearish body)
      if(bar1.Open() > bar0.Close())                             return WRONG_VALUE;

     //--- bar1 closes above bar0's midpoint: BottomBody + body_range * penetration
     //    For bearish bar0: BottomBody = Close, TopBody = Open
      double body_range  = bar0.TopBody() - bar0.BottomBody();
      double min_close   = bar0.BottomBody() + body_range * this.RatioSmallerShadowToCandleSizeValue()/100.0;
      if(bar1.Close() < min_close)                               return WRONG_VALUE;

     //--- Pattern found
      mother_bar_data.time        = bar1.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(bar0.High(), bar1.High());
      mother_bar_data.low         = MathMin(bar0.Low(),  bar1.Low());
      mother_bar_data.close       = bar1.Close();
      mother_bar_data.tick_volume = 2;
      return PATTERN_DIRECTION_BULLISH;
    }
   CArrayObj *CBarPatternControlPiercingLine::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                   EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_PIERCING_LINE,      EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                 EQUAL);
     }
 #endif // CBarPatternControlPiercingLine_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLPIERCINGLINE_MQH__
