//+------------------------------------------------------------------+
//|                                BarPatternControlMorningStar.mqh  |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLMORNINGSTAR_MQH__
#define __BARPATTERNCONTROLMORNINGSTAR_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\TrCandlesPatterns\PatternMorningStar.mqh"

 //--- Field reuse for Morning Star (stored in base class protected fields):
 //    m_ratio_body_to_candle_size           → min body ratio for candle 1 (large bearish, e.g. 0.60)
 //    m_ratio_larger_shadow_to_candle_size  → max body ratio for candle 2 (small/doji,   e.g. 0.30)
 //    m_ratio_smaller_shadow_to_candle_size → min penetration of candle 3 into candle 1  (e.g. 0.50)
 #ifndef CBarPatternControlMorningStar_MQH_DECLARATION
 #define CBarPatternControlMorningStar_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Morning Star pattern control class (3-candle bullish reversal)   |
  //+------------------------------------------------------------------+
  class CBarPatternControlMorningStar : public CBarPatternControl
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
                                            return(time + PATTERN_TYPE_MORNING_STAR + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
        //--- Create object ID based on pattern search criteria
          virtual ulong                  CreateObjectID(void);

    public:
        //--- Parametric constructor
        //    param[0] int:    min body size in points for candle 1
        //    param[1] double: min body/candle ratio for candle 1    (large bearish, default 0.60)
        //    param[2] double: max body/candle ratio for candle 2    (small body,    default 0.30)
        //    param[3] double: min penetration into candle 1 body    (candle 3,      default 0.50)
                              CBarPatternControlMorningStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                            CArrayObj *list_series, CArrayObj *list_patterns,
                                                            const MqlParam &param[]);
   };
 #endif // CBarPatternControlMorningStar_MQH_DECLARATION
 #ifndef CBarPatternControlMorningStar_MQH_IMPLEMENTATION
 #define CBarPatternControlMorningStar_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlMorningStar::CBarPatternControlMorningStar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                  CArrayObj *list_series, CArrayObj *list_patterns,
                                                                  const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_MORNING_STAR,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_INNER_BODY;
    this.m_ratio_smaller_shadow_to_candle_size = PATTERN_DEF_PENETRATION;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID based on pattern search criteria                |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlMorningStar::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue()          * 100);
      ushort c2 = (ushort)(this.RatioLargerShadowToCandleSizeValue()  * 100);
      ushort c3 = (ushort)(this.RatioSmallerShadowToCandleSizeValue() * 100);
      long   res = 0;
      this.UshortToLong(c1, 0, res);
      this.UshortToLong(c2, 1, res);
      return this.UshortToLong(c3, 2, res);
     }
   //+------------------------------------------------------------------+
   //| Create a pattern object with the specified direction             |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlMorningStar::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                 const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternMorningStar *obj = new CPatternMorningStar(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioSmallerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Morning Star on 3 consecutive bars ending at time     |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlMorningStar::FindPattern(const datetime series_bar_time,
                                                                        MqlRates &mother_bar_data) const
    {
     //--- Get all bars up to and including series_bar_time
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 3) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
     //--- candle 3 = bullish confirmation (the bar at series_bar_time)
      CBar *bar2 = list.At(n - 1);
     //--- candle 2 = small body / doji
      CBar *bar1 = list.At(n - 2);
     //--- candle 1 = large bearish
      CBar *bar0 = list.At(n - 3);
      if(bar2 == NULL || bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

     //--- Condition 1: candle 1 must be bearish with a large body
      if(bar0.TypeBody() != BAR_BODY_TYPE_BEARISH)                                  return WRONG_VALUE;
      if(bar0.RatioBodyToCandleSize() < this.RatioBodyToCandleSizeValue())          return WRONG_VALUE;

     //--- Condition 2: candle 2 must have a small body (any direction)
      if(bar1.RatioBodyToCandleSize() > this.RatioLargerShadowToCandleSizeValue())  return WRONG_VALUE;

     //--- Condition 3: candle 3 must be bullish
      if(bar2.TypeBody() != BAR_BODY_TYPE_BULLISH)                                  return WRONG_VALUE;

     //--- Condition 4: candle 3 must close at least N% into candle 1's body
     //    candle 1 is bearish → BottomBody = Close, TopBody = Open
      double body1_bottom = bar0.BottomBody();
      double body1_range  = bar0.TopBody() - body1_bottom;
      double min_close    = body1_bottom + body1_range * this.RatioSmallerShadowToCandleSizeValue();
      if(bar2.Close() < min_close)                                                   return WRONG_VALUE;

     //--- Pattern found — set mother_bar_data to the full 3-candle formation range
      mother_bar_data.time        = bar0.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
      mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
      mother_bar_data.close       = bar2.Close();
      mother_bar_data.tick_volume = 3;
      return PATTERN_DIRECTION_BULLISH;
    }
   //+------------------------------------------------------------------+
   //| Return the list of Morning Star patterns managed by this object  |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlMorningStar::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),              EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                 EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_MORNING_STAR,     EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),               EQUAL);
     }
 #endif // CBarPatternControlMorningStar_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLMORNINGSTAR_MQH__
