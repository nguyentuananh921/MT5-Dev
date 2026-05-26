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
 //    m_min_body_size → min points the middle bar must protrude beyond neighbours (default 0)
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
        //    param[0] int: min points the pivot bar must protrude beyond its neighbours (default 0)
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
      this.m_min_body_size                       = 0;
      this.m_ratio_body_to_candle_size           = 0;
      this.m_ratio_larger_shadow_to_candle_size  = 0;
      this.m_ratio_smaller_shadow_to_candle_size = 0;
      this.m_ratio_candle_sizes                  = 0;
      this.m_object_id                           = this.CreateObjectID();
    }
   ulong CBarPatternControlPivotPointReversal::CreateObjectID(void)
     {
      long res = 0;
      return this.UshortToLong((ushort)this.m_min_body_size, 0, res);
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

      double protrusion = this.Point() * (double)this.m_min_body_size;

     //--- Bullish PPR: bar1 has the lowest Low (local pivot low)
      if(bar1.Low() < bar0.Low() - protrusion &&
         bar1.Low() < bar2.Low() - protrusion)
        {
         mother_bar_data.time        = bar0.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
         mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
         mother_bar_data.close       = bar2.Close();
         mother_bar_data.tick_volume = 3;
         return PATTERN_DIRECTION_BULLISH;
        }

     //--- Bearish PPR: bar1 has the highest High (local pivot high)
      if(bar1.High() > bar0.High() + protrusion &&
         bar1.High() > bar2.High() + protrusion)
        {
         mother_bar_data.time        = bar0.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
         mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
         mother_bar_data.close       = bar2.Close();
         mother_bar_data.tick_volume = 3;
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
