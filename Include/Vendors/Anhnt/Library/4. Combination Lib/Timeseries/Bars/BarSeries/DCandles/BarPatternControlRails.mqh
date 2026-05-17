//+------------------------------------------------------------------+
//|                                   BarPatternControlRails.mqh     |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLRAILS_MQH__
#define __BARPATTERNCONTROLRAILS_MQH__
 #property strict    // Necessary for mql4
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternRails.mqh"

 //--- Field reuse for Rails:
 //    m_ratio_body_to_candle_size          → min body ratio for both candles     (default 0.60)
 //    m_ratio_larger_shadow_to_candle_size → min size similarity ratio            (default 0.70)
 //    Both candles must be opposite direction with approximately equal body sizes.
 #ifndef CBarPatternControlRails_MQH_DECLARATION
 #define CBarPatternControlRails_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Rails control (2 opposite large candles, similar body sizes)     |
  //+------------------------------------------------------------------+
  class CBarPatternControlRails : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_RAILS + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);
    public:
        //    param[0] int:    min body size in points
        //    param[1] double: min body/candle ratio for both candles     (default 0.60)
        //    param[2] double: min body size similarity (small/large ≥ ?) (default 0.70)
                              CBarPatternControlRails(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                      CArrayObj *list_series, CArrayObj *list_patterns,
                                                      const MqlParam &param[]);
   };
 #endif // CBarPatternControlRails_MQH_DECLARATION
 #ifndef CBarPatternControlRails_MQH_IMPLEMENTATION
 #define CBarPatternControlRails_MQH_IMPLEMENTATION
   CBarPatternControlRails::CBarPatternControlRails(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                     CArrayObj *list_series, CArrayObj *list_patterns,
                                                     const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_RAILS,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_SIMILARITY;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   ulong CBarPatternControlRails::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue()         * 100);
      ushort c2 = (ushort)(this.RatioLargerShadowToCandleSizeValue() * 100);
      long   res = 0;
      this.UshortToLong(c1, 0, res);
      return this.UshortToLong(c2, 1, res);
     }
   CBarPattern *CBarPatternControlRails::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                        const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternRails *obj = new CPatternRails(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Two opposite-direction candles with large, similar-sized bodies  |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlRails::FindPattern(const datetime series_bar_time,
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

      double minRatio      = this.RatioBodyToCandleSizeValue();
      double minSimilarity = this.RatioLargerShadowToCandleSizeValue();

     //--- Both candles must have large bodies
      if(bar0.RatioBodyToCandleSize() < minRatio) return WRONG_VALUE;
      if(bar1.RatioBodyToCandleSize() < minRatio) return WRONG_VALUE;

     //--- Candles must be opposite direction
      if(bar0.TypeBody() == bar1.TypeBody()) return WRONG_VALUE;

     //--- Bodies must be approximately equal size (similarity check)
      double body0 = MathAbs(bar0.Open() - bar0.Close());
      double body1 = MathAbs(bar1.Open() - bar1.Close());
      if(body0 <= 0 || body1 <= 0) return WRONG_VALUE;
      double similarity = MathMin(body0, body1) / MathMax(body0, body1);
      if(similarity < minSimilarity) return WRONG_VALUE;

     //--- Direction: bar1 (latest candle) determines the reversal signal
      ENUM_PATTERN_DIRECTION dir = (bar1.TypeBody() == BAR_BODY_TYPE_BULLISH)
                                   ? PATTERN_DIRECTION_BULLISH
                                   : PATTERN_DIRECTION_BEARISH;

      mother_bar_data.time        = bar0.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(bar0.High(), bar1.High());
      mother_bar_data.low         = MathMin(bar0.Low(),  bar1.Low());
      mother_bar_data.close       = bar1.Close();
      mother_bar_data.tick_volume = 2;
      return dir;
    }
   CArrayObj *CBarPatternControlRails::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),       EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),          EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_RAILS,     EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),        EQUAL);
     }
 #endif // CBarPatternControlRails_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLRAILS_MQH__
