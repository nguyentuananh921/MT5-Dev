//+------------------------------------------------------------------+
//|                                  BarPatternControlThreeStars.mqh |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLTHREESTARS_MQH__
#define __BARPATTERNCONTROLTHREESTARS_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\TrCandlesPatterns\PatternThreeStars.mqh"

 //--- Field reuse for Three Stars (stored in base class protected fields):
 //    m_ratio_body_to_candle_size  → max body/candle ratio for doji detection (default 0.10)
 #ifndef CBarPatternControlThreeStars_MQH_DECLARATION
 #define CBarPatternControlThreeStars_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Three Stars control (3 consecutive doji — reversal signal)       |
  //+------------------------------------------------------------------+
  class CBarPatternControlThreeStars : public CBarPatternControl
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
                                            return(time + PATTERN_TYPE_THREE_STARS + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
        //--- Create object ID based on pattern search criteria
          virtual ulong                  CreateObjectID(void);

    public:
        //--- Parametric constructor
        //    param[0] int:    0 (not meaningful for doji)
        //    param[1] double: max body/candle ratio for doji detection    (default 0.10)
                              CBarPatternControlThreeStars(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                           CArrayObj *list_series, CArrayObj *list_patterns,
                                                           const MqlParam &param[]);
   };
 #endif // CBarPatternControlThreeStars_MQH_DECLARATION
 #ifndef CBarPatternControlThreeStars_MQH_IMPLEMENTATION
 #define CBarPatternControlThreeStars_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlThreeStars::CBarPatternControlThreeStars(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                               CArrayObj *list_series, CArrayObj *list_patterns,
                                                               const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_THREE_STARS,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size             = 0;
    this.m_ratio_body_to_candle_size = 0.10;
    this.m_ratio_larger_shadow_to_candle_size  = 0;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID based on pattern search criteria                |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlThreeStars::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue() * 100);
      long   res = 0;
      return this.UshortToLong(c1, 0, res);
     }
   //+------------------------------------------------------------------+
   //| Create a pattern object with the specified direction             |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlThreeStars::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                             const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternThreeStars *obj = new CPatternThreeStars(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION, this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Three Stars (3 doji) pattern ending at series_bar_time|
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlThreeStars::FindPattern(const datetime series_bar_time,
                                                                     MqlRates &mother_bar_data) const
    {
     //--- Get all bars up to and including series_bar_time
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 3) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
      CBar *bar2 = list.At(n - 1);
      CBar *bar1 = list.At(n - 2);
      CBar *bar0 = list.At(n - 3);
      if(bar2 == NULL || bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

     //--- All three must be near-doji (body ratio <= threshold)
      double maxRatio = this.RatioBodyToCandleSizeValue();
      if(bar0.RatioBodyToCandleSize() > maxRatio) return WRONG_VALUE;
      if(bar1.RatioBodyToCandleSize() > maxRatio) return WRONG_VALUE;
      if(bar2.RatioBodyToCandleSize() > maxRatio) return WRONG_VALUE;

     //--- Direction: bullish if bar2 close >= bar0 close (upward drift), bearish otherwise
      ENUM_PATTERN_DIRECTION dir = (bar2.Close() >= bar0.Close()) ? PATTERN_DIRECTION_BULLISH
                                                                   : PATTERN_DIRECTION_BEARISH;

     //--- Pattern found — set mother_bar_data to the full 3-candle range
      mother_bar_data.time        = bar0.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
      mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
      mother_bar_data.close       = bar2.Close();
      mother_bar_data.tick_volume = 3;
      return dir;
    }
   //+------------------------------------------------------------------+
   //| Return list of Three Stars patterns for this object              |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlThreeStars::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),              EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                 EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_THREE_STARS,      EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),               EQUAL);
     }
 #endif // CBarPatternControlThreeStars_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLTHREESTARS_MQH__
