//+------------------------------------------------------------------+
//|                                   BarPatternControlHarami.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLHARAMI_MQH__
#define __BARPATTERNCONTROLHARAMI_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternHarami.mqh"

 //--- Field reuse for Harami (stored in base class protected fields):
 //    m_ratio_body_to_candle_size          → min body ratio for candle 1 (large, default 0.60)
 //    m_ratio_larger_shadow_to_candle_size → max body ratio for candle 2 (small, default 0.30)
 #ifndef CBarPatternControlHarami_MQH_DECLARATION
 #define CBarPatternControlHarami_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Harami control (2-candle reversal, bullish + bearish variants)   |
  //+------------------------------------------------------------------+
  class CBarPatternControlHarami : public CBarPatternControl
   {
    protected:
        //--- (1) Search for a pattern, return direction (or -1),
        //--- (2) create a pattern with a specified direction,
        //--- (3) create and return a unique pattern code
        //--- (4) return the list of patterns managed by the object
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_HARAMI + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
        //--- Create object ID based on pattern search criteria
          virtual ulong                  CreateObjectID(void);

    public:
        //--- Parametric constructor
        //    param[0] int:    min body size in points for candle 1
        //    param[1] double: min body/candle ratio for candle 1    (large mother candle, default 0.60)
        //    param[2] double: max body/candle ratio for candle 2    (small inner candle,  default 0.30)
                              CBarPatternControlHarami(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                       CArrayObj *list_series, CArrayObj *list_patterns,
                                                       const MqlParam &param[]);
   };
 #endif // CBarPatternControlHarami_MQH_DECLARATION
 #ifndef CBarPatternControlHarami_MQH_IMPLEMENTATION
 #define CBarPatternControlHarami_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlHarami::CBarPatternControlHarami(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                       CArrayObj *list_series, CArrayObj *list_patterns,
                                                       const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_HARAMI,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_INNER_BODY;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID based on pattern search criteria                |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlHarami::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue()         * 100);
      ushort c2 = (ushort)(this.RatioLargerShadowToCandleSizeValue() * 100);
      long   res = 0;
      this.UshortToLong(c1, 0, res);
      return this.UshortToLong(c2, 1, res);
     }
   //+------------------------------------------------------------------+
   //| Create a pattern object with the specified direction             |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlHarami::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                         const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternHarami *obj = new CPatternHarami(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Harami (bullish or bearish) on 2 bars ending at time  |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlHarami::FindPattern(const datetime series_bar_time,
                                                                  MqlRates &mother_bar_data) const
    {
     //--- Get all bars up to and including series_bar_time
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 2) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
     //--- candle 2 = small inner candle (the bar at series_bar_time)
      CBar *bar1 = list.At(n - 1);
     //--- candle 1 = large mother candle
      CBar *bar0 = list.At(n - 2);
      if(bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

      double minRatio = this.RatioBodyToCandleSizeValue();
      double maxRatio = this.RatioLargerShadowToCandleSizeValue();

     //--- Candle 1 must have a large body
      if(bar0.RatioBodyToCandleSize() < minRatio) return WRONG_VALUE;

     //--- Candle 2 must have a small body
      if(bar1.RatioBodyToCandleSize() > maxRatio) return WRONG_VALUE;

     //--- Candle 2 body must be entirely inside candle 1 body
     //    BottomBody() = MathMin(Open, Close), TopBody() = MathMax(Open, Close)
      if(bar1.BottomBody() < bar0.BottomBody()) return WRONG_VALUE;
      if(bar1.TopBody()    > bar0.TopBody())    return WRONG_VALUE;

     //--- Direction: candles must be opposite
      ENUM_PATTERN_DIRECTION dir = WRONG_VALUE;
      if(bar0.TypeBody() == BAR_BODY_TYPE_BEARISH && bar1.TypeBody() == BAR_BODY_TYPE_BULLISH)
            dir = PATTERN_DIRECTION_BULLISH;
      else if(bar0.TypeBody() == BAR_BODY_TYPE_BULLISH && bar1.TypeBody() == BAR_BODY_TYPE_BEARISH)
            dir = PATTERN_DIRECTION_BEARISH;
      if(dir == WRONG_VALUE) return WRONG_VALUE;

     //--- Pattern found — set mother_bar_data to the full 2-candle range
      mother_bar_data.time        = bar1.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(bar0.High(), bar1.High());
      mother_bar_data.low         = MathMin(bar0.Low(),  bar1.Low());
      mother_bar_data.close       = bar1.Close();
      mother_bar_data.tick_volume = 2;
      return dir;
    }
   //+------------------------------------------------------------------+
   //| Return list of Harami patterns managed by this object            |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlHarami::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),          EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),             EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_HARAMI,       EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),           EQUAL);
     }
 #endif // CBarPatternControlHarami_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLHARAMI_MQH__
