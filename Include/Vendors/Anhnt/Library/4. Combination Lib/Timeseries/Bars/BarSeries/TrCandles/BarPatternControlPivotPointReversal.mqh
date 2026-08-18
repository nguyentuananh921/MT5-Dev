//+------------------------------------------------------------------+
//|                       BarPatternControlPivotPointReversal.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLPIVOTPOINTREVERSAL_MQH__
#define __BARPATTERNCONTROLPIVOTPOINTREVERSAL_MQH__
 #property strict    // Necessary for mql4
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\TrCandlesPatterns\PatternPivotPointReversal.mqh"

 //--- Pivot Point Reversal: 3 bars where the middle bar has the lowest Low (bullish)
 //    or the highest High (bearish) compared to bars on either side.
 //    m_ratio_candle_sizes → min % of bar1's OWN High-Low range it must protrude beyond EACH
 //    neighbour (default 0 = any protrusion counts, was the bug - see BugNote_PivotPointReversalThreshold.md).
 //    Switched from absolute-point threshold (m_min_body_size) to this ratio (Anhnt, 2026-08-15):
 //    a fixed point count doesn't scale across symbols/TFs with very different volatility, while
 //    "% of bar1's own size" answers the same question a human eye asks - does this pivot look
 //    obviously bigger than its neighbours, or is it noise.
 #ifndef CBarPatternControlPivotPointReversal_MQH_DECLARATION
 #define CBarPatternControlPivotPointReversal_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Pivot Point Reversal control (3-candle, middle bar is pivot)     |
  //+------------------------------------------------------------------+
  class CBarPatternControlPivotPointReversal : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_PIVOT_POINT_REVERSAL + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);
    public:
        //    param[0] double: min % of bar1's own High-Low range it must protrude beyond EACH neighbour (default 0)
                              CBarPatternControlPivotPointReversal(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                   CArrayObj *list_series, CArrayObj *list_patterns,
                                                                   const MqlParam &param[]);
   };
 #endif // CBarPatternControlPivotPointReversal_MQH_DECLARATION
 #ifndef CBarPatternControlPivotPointReversal_MQH_IMPLEMENTATION
 #define CBarPatternControlPivotPointReversal_MQH_IMPLEMENTATION
   CBarPatternControlPivotPointReversal::CBarPatternControlPivotPointReversal(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                               CArrayObj *list_series, CArrayObj *list_patterns,
                                                                               const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_PIVOT_POINT_REVERSAL,
                       list_series, list_patterns, param)
    {
      int param_size = ArraySize(this.PatternParams);
      this.m_min_body_size                       = 0;   // unused for PPR since 2026-08-15 - see m_ratio_candle_sizes above
      this.m_ratio_body_to_candle_size           = 0;
      this.m_ratio_larger_shadow_to_candle_size  = 0;
      this.m_ratio_smaller_shadow_to_candle_size = 0;
      this.m_ratio_candle_sizes                  = (param_size > 0) ? this.PatternParams[0].double_value : 0;
      this.m_object_id                           = this.CreateObjectID();
    }
   ulong CBarPatternControlPivotPointReversal::CreateObjectID(void)
     {
      long res = 0;
      return this.UshortToLong((ushort)(this.m_ratio_candle_sizes * 100), 0, res);
     }
   CBarPattern *CBarPatternControlPivotPointReversal::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                     const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternPivotPointReversal *obj = new CPatternPivotPointReversal(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Middle bar (bar1) must have the lowest Low or highest High       |
   //| compared to bar0 (earliest) and bar2 (latest/series_bar_time)   |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlPivotPointReversal::FindPattern(const datetime series_bar_time,
                                                                              MqlRates &mother_bar_data) const
    {
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 3) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
      CBar *bar2 = list.At(n - 1);   // confirmation bar (series_bar_time)
      CBar *bar1 = list.At(n - 2);   // pivot candidate (middle)
      CBar *bar0 = list.At(n - 3);   // left reference bar
      if(bar2 == NULL || bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

      double bar1_size = bar1.High() - bar1.Low();
      if(bar1_size <= 0) return WRONG_VALUE;   // zero-range bar1 (all 4 OHLC equal) - no meaningful ratio
      double min_ratio = this.RatioCandleSizeValue();   // % of bar1's OWN High-Low range

     //--- Bullish PPR: bar1's Low must protrude below EACH neighbour by >= min_ratio% of bar1's own range
      double low_ratio_vs_bar0 = (bar0.Low() - bar1.Low()) / bar1_size * 100.0;
      double low_ratio_vs_bar2 = (bar2.Low() - bar1.Low()) / bar1_size * 100.0;
      if(low_ratio_vs_bar0 >= min_ratio && low_ratio_vs_bar2 >= min_ratio)
       {
         mother_bar_data.time        = bar2.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
         mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
         mother_bar_data.close       = bar2.Close();
         mother_bar_data.tick_volume = 3;
        //  // MY DEBUG CBarPatternControlPivotPointReversal::FindPattern: dump bar0/bar1/bar2 to verify pivot visually
        //  ::Print("MY DEBUG CBarPatternControlPivotPointReversal::FindPattern(Bullish): min_ratio=", min_ratio, "%",
        //          " | bar0 t=", ::TimeToString(bar0.Time(), TIME_DATE|TIME_MINUTES),
        //          " O=", bar0.Open(), " H=", bar0.High(), " L=", bar0.Low(), " C=", bar0.Close(),
        //          " | bar1 t=", ::TimeToString(bar1.Time(), TIME_DATE|TIME_MINUTES),
        //          " O=", bar1.Open(), " H=", bar1.High(), " L=", bar1.Low(), " C=", bar1.Close(),
        //          " | bar2 t=", ::TimeToString(bar2.Time(), TIME_DATE|TIME_MINUTES),
        //          " O=", bar2.Open(), " H=", bar2.High(), " L=", bar2.Low(), " C=", bar2.Close(),
        //          " | ratio_vs_bar0=", low_ratio_vs_bar0, "% ratio_vs_bar2=", low_ratio_vs_bar2, "%");
         return PATTERN_DIRECTION_BULLISH;
       }

     //--- Bearish PPR: bar1's High must protrude above EACH neighbour by >= min_ratio% of bar1's own range
      double high_ratio_vs_bar0 = (bar1.High() - bar0.High()) / bar1_size * 100.0;
      double high_ratio_vs_bar2 = (bar1.High() - bar2.High()) / bar1_size * 100.0;
      if(high_ratio_vs_bar0 >= min_ratio && high_ratio_vs_bar2 >= min_ratio)
       {
         mother_bar_data.time        = bar2.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
         mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
         mother_bar_data.close       = bar2.Close();
         mother_bar_data.tick_volume = 3;
        //  // MY DEBUG CBarPatternControlPivotPointReversal::FindPattern: dump bar0/bar1/bar2 to verify pivot visually
        //  ::Print("MY DEBUG CBarPatternControlPivotPointReversal::FindPattern(Bearish): min_ratio=", min_ratio, "%",
        //          " | bar0 t=", ::TimeToString(bar0.Time(), TIME_DATE|TIME_MINUTES),
        //          " O=", bar0.Open(), " H=", bar0.High(), " L=", bar0.Low(), " C=", bar0.Close(),
        //          " | bar1 t=", ::TimeToString(bar1.Time(), TIME_DATE|TIME_MINUTES),
        //          " O=", bar1.Open(), " H=", bar1.High(), " L=", bar1.Low(), " C=", bar1.Close(),
        //          " | bar2 t=", ::TimeToString(bar2.Time(), TIME_DATE|TIME_MINUTES),
        //          " O=", bar2.Open(), " H=", bar2.High(), " L=", bar2.Low(), " C=", bar2.Close(),
        //          " | ratio_vs_bar0=", high_ratio_vs_bar0, "% ratio_vs_bar2=", high_ratio_vs_bar2, "%");
         return PATTERN_DIRECTION_BEARISH;
       }

      return WRONG_VALUE;
    }
   CArrayObj *CBarPatternControlPivotPointReversal::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                       EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                          EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_PIVOT_POINT_REVERSAL,      EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                        EQUAL);
     }
 #endif // CBarPatternControlPivotPointReversal_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLPIVOTPOINTREVERSAL_MQH__
