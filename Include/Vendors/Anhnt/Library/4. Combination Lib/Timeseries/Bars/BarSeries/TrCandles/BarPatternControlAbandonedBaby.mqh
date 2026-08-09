//+------------------------------------------------------------------+
//|                            BarPatternControlAbandonedBaby.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLABANDONEDBY_MQH__
#define __BARPATTERNCONTROLABANDONEDBY_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\TrCandlesPatterns\PatternAbandonedBaby.mqh"

 //--- Field reuse for Abandoned Baby (stored in base class protected fields):
 //    m_ratio_body_to_candle_size          → min body ratio for candles 1 & 3  (default 0.60)
 //    m_ratio_larger_shadow_to_candle_size → max body ratio for candle 2 (doji, default 0.10)
 #ifndef CBarPatternControlAbandonedBaby_MQH_DECLARATION
 #define CBarPatternControlAbandonedBaby_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Abandoned Baby control (3-candle, doji gapped on both sides)     |
  //+------------------------------------------------------------------+
  class CBarPatternControlAbandonedBaby : public CBarPatternControl
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
                                            return(time + PATTERN_TYPE_ABANDONED_BABY + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
        //--- Create object ID based on pattern search criteria
          virtual ulong                  CreateObjectID(void);

    public:
        //--- Parametric constructor
        //    param[0] int:    min body size in points for candles 1 and 3
        //    param[1] double: min body/candle ratio for candles 1 & 3  (large body,  default 0.60)
        //    param[2] double: max body/candle ratio for candle 2        (doji,        default 0.10)
                              CBarPatternControlAbandonedBaby(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                              CArrayObj *list_series, CArrayObj *list_patterns,
                                                              const MqlParam &param[]);
   };
 #endif // CBarPatternControlAbandonedBaby_MQH_DECLARATION
 #ifndef CBarPatternControlAbandonedBaby_MQH_IMPLEMENTATION
 #define CBarPatternControlAbandonedBaby_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlAbandonedBaby::CBarPatternControlAbandonedBaby(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                     CArrayObj *list_series, CArrayObj *list_patterns,
                                                                     const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_ABANDONED_BABY,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_DOJI_BODY;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID based on pattern search criteria                |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlAbandonedBaby::CreateObjectID(void)
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
   CBarPattern *CBarPatternControlAbandonedBaby::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternAbandonedBaby *obj = new CPatternAbandonedBaby(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Abandoned Baby pattern on 3 bars ending at time       |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlAbandonedBaby::FindPattern(const datetime series_bar_time,
                                                                         MqlRates &mother_bar_data) const
    {
     //--- Get all bars up to and including series_bar_time
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 3) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
     //--- candle 3 = confirmation (the bar at series_bar_time)
      CBar *bar2 = list.At(n - 1);
     //--- candle 2 = isolated doji (must gap on both sides)
      CBar *bar1 = list.At(n - 2);
     //--- candle 1 = first large candle
      CBar *bar0 = list.At(n - 3);
      if(bar2 == NULL || bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

      double minRatio  = this.RatioBodyToCandleSizeValue();
      double dojiRatio = this.RatioLargerShadowToCandleSizeValue();

     //--- Candle 2 must be a doji
      if(bar1.RatioBodyToCandleSize() > dojiRatio) return WRONG_VALUE;

     //--- Candles 1 and 3 must have large bodies
      if(bar0.RatioBodyToCandleSize() < minRatio) return WRONG_VALUE;
      if(bar2.RatioBodyToCandleSize() < minRatio) return WRONG_VALUE;

     //--- Check Bullish Abandoned Baby:
     //    bar0 bearish, doji gaps DOWN below bar0, bar2 bullish gaps UP above doji
      if(bar0.TypeBody() == BAR_BODY_TYPE_BEARISH &&
         bar2.TypeBody() == BAR_BODY_TYPE_BULLISH  &&
         bar1.High()     <  bar0.Low()             &&   // gap down: doji's high < bar0's low
         bar2.Low()      >  bar1.High())                // gap up:   bar2's low  > doji's high
        {
         mother_bar_data.time        = bar2.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
         mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
         mother_bar_data.close       = bar2.Close();
         mother_bar_data.tick_volume = 3;
         return PATTERN_DIRECTION_BULLISH;
        }

     //--- Check Bearish Abandoned Baby:
     //    bar0 bullish, doji gaps UP above bar0, bar2 bearish gaps DOWN below doji
      if(bar0.TypeBody() == BAR_BODY_TYPE_BULLISH &&
         bar2.TypeBody() == BAR_BODY_TYPE_BEARISH  &&
         bar1.Low()      >  bar0.High()            &&   // gap up:   doji's low  > bar0's high
         bar2.High()     <  bar1.Low())                 // gap down: bar2's high < doji's low
        {
         mother_bar_data.time        = bar2.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
         mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
         mother_bar_data.close       = bar2.Close();
         mother_bar_data.tick_volume = 3;
         return PATTERN_DIRECTION_BEARISH;
        }

      return WRONG_VALUE;
    }
   //+------------------------------------------------------------------+
   //| Return list of Abandoned Baby patterns for this object           |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlAbandonedBaby::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),               EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                  EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_ABANDONED_BABY,    EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                EQUAL);
     }
 #endif // CBarPatternControlAbandonedBaby_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLABANDONEDBY_MQH__
