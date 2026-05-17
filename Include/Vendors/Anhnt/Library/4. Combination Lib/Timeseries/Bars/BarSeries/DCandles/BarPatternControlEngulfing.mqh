//+------------------------------------------------------------------+
//|                                BarPatternControlEngulfing.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLENGULFING_MQH__
#define __BARPATTERNCONTROLENGULFING_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternEngulfing.mqh"

 //--- Field reuse for Engulfing (stored in base class protected fields):
 //    m_ratio_body_to_candle_size  → min body/candle ratio for candle 2 (engulfing, default 0.60)
 #ifndef CBarPatternControlEngulfing_MQH_DECLARATION
 #define CBarPatternControlEngulfing_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Engulfing control (2-candle reversal, bullish + bearish)         |
  //+------------------------------------------------------------------+
  class CBarPatternControlEngulfing : public CBarPatternControl
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
                                            return(time + PATTERN_TYPE_ENGULFING + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
        //--- Create object ID based on pattern search criteria
          virtual ulong                  CreateObjectID(void);

    public:
        //--- Parametric constructor
        //    param[0] int:    min body size in points for candle 2 (engulfing candle)
        //    param[1] double: min body/candle ratio for candle 2   (default 0.60)
                              CBarPatternControlEngulfing(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                          CArrayObj *list_series, CArrayObj *list_patterns,
                                                          const MqlParam &param[]);
   };
 #endif // CBarPatternControlEngulfing_MQH_DECLARATION
 #ifndef CBarPatternControlEngulfing_MQH_IMPLEMENTATION
 #define CBarPatternControlEngulfing_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlEngulfing::CBarPatternControlEngulfing(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                             CArrayObj *list_series, CArrayObj *list_patterns,
                                                             const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_ENGULFING,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = 0;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID based on pattern search criteria                |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlEngulfing::CreateObjectID(void)
     {
      ushort c1 = (ushort)(this.RatioBodyToCandleSizeValue() * 100);
      long   res = 0;
      return this.UshortToLong(c1, 0, res);
     }
   //+------------------------------------------------------------------+
   //| Create a pattern object with the specified direction             |
   //+------------------------------------------------------------------+
   CBarPattern *CBarPatternControlEngulfing::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                            const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternEngulfing *obj = new CPatternEngulfing(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION, this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Engulfing (bullish or bearish) on 2 bars ending at t  |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlEngulfing::FindPattern(const datetime series_bar_time,
                                                                     MqlRates &mother_bar_data) const
    {
     //--- Get all bars up to and including series_bar_time
      CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME,
                                                            series_bar_time, EQUAL_OR_LESS);
      if(list == NULL || list.Total() < 2) return WRONG_VALUE;
      list.Sort(SORT_BY_BAR_TIME);
      int n = list.Total();
     //--- candle 2 = engulfing candle (the bar at series_bar_time)
      CBar *bar1 = list.At(n - 1);
     //--- candle 1 = engulfed candle
      CBar *bar0 = list.At(n - 2);
      if(bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

     //--- Candle 2 must have a large body (the engulfing candle)
      if(bar1.RatioBodyToCandleSize() < this.RatioBodyToCandleSizeValue()) return WRONG_VALUE;

     //--- Candle 2 body must completely cover candle 1 body:
     //    bar1.BottomBody() <= bar0.BottomBody() AND bar1.TopBody() >= bar0.TopBody()
      if(bar1.BottomBody() > bar0.BottomBody()) return WRONG_VALUE;
      if(bar1.TopBody()    < bar0.TopBody())    return WRONG_VALUE;

     //--- Direction: candles must be opposite
      ENUM_PATTERN_DIRECTION dir = WRONG_VALUE;
      if(bar0.TypeBody() == BAR_BODY_TYPE_BEARISH && bar1.TypeBody() == BAR_BODY_TYPE_BULLISH)
            dir = PATTERN_DIRECTION_BULLISH;
      else if(bar0.TypeBody() == BAR_BODY_TYPE_BULLISH && bar1.TypeBody() == BAR_BODY_TYPE_BEARISH)
            dir = PATTERN_DIRECTION_BEARISH;
      if(dir == WRONG_VALUE) return WRONG_VALUE;

     //--- Pattern found
      mother_bar_data.time        = bar0.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(bar0.High(), bar1.High());
      mother_bar_data.low         = MathMin(bar0.Low(),  bar1.Low());
      mother_bar_data.close       = bar1.Close();
      mother_bar_data.tick_volume = 2;
      return dir;
    }
   //+------------------------------------------------------------------+
   //| Return list of Engulfing patterns managed by this object         |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlEngulfing::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),            EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),               EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_ENGULFING,      EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),             EQUAL);
     }
 #endif // CBarPatternControlEngulfing_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLENGULFING_MQH__
