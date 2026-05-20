//+------------------------------------------------------------------+
//|                           BarPatternControlDarkCloudCover.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLDARKCLOUDCOVER_MQH__
#define __BARPATTERNCONTROLDARKCLOUDCOVER_MQH__
 #property strict    // Necessary for mql4
 #include "BarPatternControlPiercingLine.mqh"
 #include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternDarkCloudCover.mqh"

 //--- Mirror of Piercing Line: bar0 bullish, bar1 bearish, closes below midpoint bar0.
 #ifndef CBarPatternControlDarkCloudCover_MQH_DECLARATION
 #define CBarPatternControlDarkCloudCover_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Dark Cloud Cover control (2-candle bearish reversal)             |
  //+------------------------------------------------------------------+
  class CBarPatternControlDarkCloudCover : public CBarPatternControlPiercingLine
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_DARK_CLOUD_COVER + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
    public:
                              CBarPatternControlDarkCloudCover(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                               CArrayObj *list_series, CArrayObj *list_patterns,
                                                               const MqlParam &param[]);
   };
 #endif // CBarPatternControlDarkCloudCover_MQH_DECLARATION
 #ifndef CBarPatternControlDarkCloudCover_MQH_IMPLEMENTATION
 #define CBarPatternControlDarkCloudCover_MQH_IMPLEMENTATION
   CBarPatternControlDarkCloudCover::CBarPatternControlDarkCloudCover(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                       CArrayObj *list_series, CArrayObj *list_patterns,
                                                                       const MqlParam &param[]) :
    CBarPatternControlPiercingLine(symbol, timeframe, list_series, list_patterns, param)
    {
    }
   //+------------------------------------------------------------------+
   //| bar0: large bullish; bar1: bearish, closes below midpoint bar0   |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlDarkCloudCover::FindPattern(const datetime series_bar_time,
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

     //--- bar0: large bullish
      if(bar0.TypeBody() != BAR_BODY_TYPE_BULLISH)               return WRONG_VALUE;
      if(bar0.RatioBodyToCandleSize() < this.RatioBodyToCandleSizeValue()) return WRONG_VALUE;

     //--- bar1: bearish
      if(bar1.TypeBody() != BAR_BODY_TYPE_BEARISH)               return WRONG_VALUE;

     //--- bar1 opens at or above bar0's close (top of bullish body)
      if(bar1.Open() < bar0.Close())                             return WRONG_VALUE;

     //--- bar1 closes below bar0's midpoint: TopBody - body_range * penetration
     //    For bullish bar0: BottomBody = Open, TopBody = Close
      double body_range  = bar0.TopBody() - bar0.BottomBody();
      double max_close   = bar0.TopBody() - body_range * this.RatioSmallerShadowToCandleSizeValue()/100.0;
      if(bar1.Close() > max_close)                               return WRONG_VALUE;

     //--- Pattern found
      mother_bar_data.time        = bar0.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(bar0.High(), bar1.High());
      mother_bar_data.low         = MathMin(bar0.Low(),  bar1.Low());
      mother_bar_data.close       = bar1.Close();
      mother_bar_data.tick_volume = 2;
      return PATTERN_DIRECTION_BEARISH;
    }
   CBarPattern *CBarPatternControlDarkCloudCover::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                  const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternDarkCloudCover *obj = new CPatternDarkCloudCover(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION, this.RatioSmallerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   CArrayObj *CBarPatternControlDarkCloudCover::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                    EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                       EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_DARK_CLOUD_COVER,       EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                     EQUAL);
     }
 #endif // CBarPatternControlDarkCloudCover_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLDARKCLOUDCOVER_MQH__
