//+------------------------------------------------------------------+
//|                             BarPatternControlThreeBlackCrows.mqh |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLTHREEBLACKCROWS_MQH__
#define __BARPATTERNCONTROLTHREEBLACKCROWS_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\TrCandlesPatterns\PatternThreeBlackCrows.mqh"

 //--- Field reuse for Three Black Crows (stored in base class protected fields):
 //    m_ratio_body_to_candle_size  → min body/candle ratio for all 3 candles (default 0.60)
 #ifndef CBarPatternControlThreeBlackCrows_MQH_DECLARATION
 #define CBarPatternControlThreeBlackCrows_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Three Black Crows control (3-candle bearish continuation)        |
  //+------------------------------------------------------------------+
  class CBarPatternControlThreeBlackCrows : public CBarPatternControl
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
                                            return(time + PATTERN_TYPE_THREE_BLACK_CROWS + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
        //--- Create object ID based on pattern search criteria
          virtual ulong                  CreateObjectID(void);

    public:
        //--- Parametric constructor
        //    param[0] int:    min body size in points for all 3 candles
        //    param[1] double: min body/candle ratio for all 3 candles    (default 0.60)
                              CBarPatternControlThreeBlackCrows(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                CArrayObj *list_series, CArrayObj *list_patterns,
                                                                const MqlParam &param[]);
   };
 #endif // CBarPatternControlThreeBlackCrows_MQH_DECLARATION
 #ifndef CBarPatternControlThreeBlackCrows_MQH_IMPLEMENTATION
 #define CBarPatternControlThreeBlackCrows_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlThreeBlackCrows::CBarPatternControlThreeBlackCrows(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                         CArrayObj *list_series, CArrayObj *list_patterns,
                                                                         const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_THREE_BLACK_CROWS,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size             = 0;
    this.m_ratio_body_to_candle_size = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = 0;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID based on pattern search criteria                |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlThreeBlackCrows::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue() * 100);
      long   res = 0;
      return this.UshortToLong(c1, 0, res);
     }
   //+------------------------------------------------------------------+
   //| Create a pattern object with the specified direction             |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlThreeBlackCrows::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                  const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternThreeBlackCrows *obj = new CPatternThreeBlackCrows(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION, this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Three Black Crows pattern ending at series_bar_time  |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlThreeBlackCrows::FindPattern(const datetime series_bar_time,
                                                                          MqlRates &mother_bar_data) const
    {
     //--- Get all bars up to and including series_bar_time
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 3) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
     //--- candle 3 = latest bearish
      CBar *bar2 = list.At(n - 1);
     //--- candle 2 = middle bearish
      CBar *bar1 = list.At(n - 2);
     //--- candle 1 = first bearish
      CBar *bar0 = list.At(n - 3);
      if(bar2 == NULL || bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

      double minRatio = this.RatioBodyToCandleSizeValue();

     //--- Condition 1: all three must be bearish with large bodies
      if(bar0.TypeBody() != BAR_BODY_TYPE_BEARISH) return WRONG_VALUE;
      if(bar1.TypeBody() != BAR_BODY_TYPE_BEARISH) return WRONG_VALUE;
      if(bar2.TypeBody() != BAR_BODY_TYPE_BEARISH) return WRONG_VALUE;
      if(bar0.RatioBodyToCandleSize() < minRatio)  return WRONG_VALUE;
      if(bar1.RatioBodyToCandleSize() < minRatio)  return WRONG_VALUE;
      if(bar2.RatioBodyToCandleSize() < minRatio)  return WRONG_VALUE;

     //--- Condition 2: bar1 opens within bar0's body and closes lower
     //    Bearish bar: BottomBody = Close, TopBody = Open
      if(bar1.Open() < bar0.BottomBody() || bar1.Open() > bar0.TopBody()) return WRONG_VALUE;
      if(bar1.Close() >= bar0.Close())                                     return WRONG_VALUE;

     //--- Condition 3: bar2 opens within bar1's body and closes lower
      if(bar2.Open() < bar1.BottomBody() || bar2.Open() > bar1.TopBody()) return WRONG_VALUE;
      if(bar2.Close() >= bar1.Close())                                     return WRONG_VALUE;

     //--- Pattern found — set mother_bar_data to the full 3-candle range
      mother_bar_data.time        = bar2.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
      mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
      mother_bar_data.close       = bar2.Close();
      mother_bar_data.tick_volume = 3;
      return PATTERN_DIRECTION_BEARISH;
    }
   //+------------------------------------------------------------------+
   //| Return list of Three Black Crows patterns for this object        |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlThreeBlackCrows::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                      EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                         EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_THREE_BLACK_CROWS,        EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                       EQUAL);
     }
 #endif // CBarPatternControlThreeBlackCrows_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLTHREEBLACKCROWS_MQH__
