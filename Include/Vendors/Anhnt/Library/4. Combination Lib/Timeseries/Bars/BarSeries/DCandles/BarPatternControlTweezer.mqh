//+------------------------------------------------------------------+
//|                                  BarPatternControlTweezer.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLTWEEZER_MQH__
#define __BARPATTERNCONTROLTWEEZER_MQH__
 #property strict    // Necessary for mql4
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternTweezer.mqh"

 //--- Field reuse for Tweezer:
 //    m_min_body_size → max tolerance in POINTS for matching High or Low (default 5)
 #ifndef CBarPatternControlTweezer_MQH_DECLARATION
 #define CBarPatternControlTweezer_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Tweezer control (2-candle, matching High=Top/Bearish or Low=Bottom/Bullish)|
  //+------------------------------------------------------------------+
  class CBarPatternControlTweezer : public CBarPatternControl
   {
    protected:
          virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_TWEEZER + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
          virtual ulong                  CreateObjectID(void);
    public:
        //    param[0] int:    max tolerance in points for High/Low equality  (default 5)
                              CBarPatternControlTweezer(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                        CArrayObj *list_series, CArrayObj *list_patterns,
                                                        const MqlParam &param[]);
   };
 #endif // CBarPatternControlTweezer_MQH_DECLARATION
 #ifndef CBarPatternControlTweezer_MQH_IMPLEMENTATION
 #define CBarPatternControlTweezer_MQH_IMPLEMENTATION
   CBarPatternControlTweezer::CBarPatternControlTweezer(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                         CArrayObj *list_series, CArrayObj *list_patterns,
                                                         const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_TWEEZER,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size             = PATTERN_DEF_TWEEZER_PTS;
    this.m_ratio_body_to_candle_size           = 0;
    this.m_ratio_larger_shadow_to_candle_size  = 0;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   ulong CBarPatternControlTweezer::CreateObjectID(void)
     {
      long res = 0;
      return this.UshortToLong((ushort)this.m_min_body_size, 0, res);
     }
   CBarPattern *CBarPatternControlTweezer::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                          const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternTweezer *obj = new CPatternTweezer(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Tweezer: matching Lows (bullish) or Highs (bearish)  |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlTweezer::FindPattern(const datetime series_bar_time,
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

      double tolerance = this.Point() * (double)this.m_min_body_size;

     //--- Tweezer Bottom: matching Lows → BULLISH
      if(MathAbs(bar0.Low() - bar1.Low()) <= tolerance)
        {
         mother_bar_data.time        = bar0.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(bar0.High(), bar1.High());
         mother_bar_data.low         = MathMin(bar0.Low(),  bar1.Low());
         mother_bar_data.close       = bar1.Close();
         mother_bar_data.tick_volume = 2;
         return PATTERN_DIRECTION_BULLISH;
        }

     //--- Tweezer Top: matching Highs → BEARISH
      if(MathAbs(bar0.High() - bar1.High()) <= tolerance)
        {
         mother_bar_data.time        = bar0.Time();
         mother_bar_data.open        = bar0.Open();
         mother_bar_data.high        = MathMax(bar0.High(), bar1.High());
         mother_bar_data.low         = MathMin(bar0.Low(),  bar1.Low());
         mother_bar_data.close       = bar1.Close();
         mother_bar_data.tick_volume = 2;
         return PATTERN_DIRECTION_BEARISH;
        }

      return WRONG_VALUE;
    }
   CArrayObj *CBarPatternControlTweezer::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),         EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),            EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_TWEEZER,     EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),          EQUAL);
     }
 #endif // CBarPatternControlTweezer_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLTWEEZER_MQH__
