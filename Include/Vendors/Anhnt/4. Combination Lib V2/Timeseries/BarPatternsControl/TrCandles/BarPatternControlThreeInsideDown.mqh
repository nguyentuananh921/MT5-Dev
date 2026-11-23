//+------------------------------------------------------------------+
//|                          BarPatternControlThreeInsideDown.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __BARPATTERNCONTROLTHREEINSIDEDOWN_MQH__
#define __BARPATTERNCONTROLTHREEINSIDEDOWN_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPatternControl.mqh"
 #include "..\..\BarPatternsSeries\TrCandlesPatterns\PatternThreeInsideDown.mqh"

 //--- Field reuse for Three Inside Down (stored in base class protected fields):
 //    m_ratio_body_to_candle_size          → min body ratio for candle 1 (large bullish, default 0.60)
 //    m_ratio_larger_shadow_to_candle_size → max body ratio for candle 2 (small harami,  default 0.30)
 #ifndef CBarPatternControlThreeInsideDown_MQH_DECLARATION
 #define CBarPatternControlThreeInsideDown_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Three Inside Down control (Bearish Harami + bearish confirmation)|
  //+------------------------------------------------------------------+
  class CBarPatternControlThreeInsideDown : public CBarPatternControl
   {
    protected:
        //--- Pattern search, creation, code and managed-pattern list
          virtual ENUM_PATTERN_DIRECTION FindPattern(const int index, MqlRates &mother_bar_data) const;
          virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
          virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
                                          {
                                            return(time + PATTERN_TYPE_THREE_INSIDE_DOWN + PATTERN_STATUS_PA +
                                                    direction + this.Timeframe() + this.m_symbol_code);
                                          }
          virtual CArrayObj             *GetListPatterns(void);
        //--- Create object ID based on pattern search criteria
          virtual ulong                  CreateObjectID(void);

    public:
        //--- Parametric constructor
        //    param[0] int:    min body size in points for candle 1
        //    param[1] double: min body/candle ratio for candle 1    (large bullish,  default 0.60)
        //    param[2] double: max body/candle ratio for candle 2    (small harami,   default 0.30)
                              CBarPatternControlThreeInsideDown(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                CArrayObj *list_series, CArrayObj *list_patterns,
                                                                const MqlParam &param[]);
   };
 #endif // CBarPatternControlThreeInsideDown_MQH_DECLARATION
 #ifndef CBarPatternControlThreeInsideDown_MQH_IMPLEMENTATION
 #define CBarPatternControlThreeInsideDown_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CBarPatternControlThreeInsideDown::CBarPatternControlThreeInsideDown(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                         CArrayObj *list_series, CArrayObj *list_patterns,
                                                                         const MqlParam &param[]) :
    CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_THREE_INSIDE_DOWN,
                       list_series, list_patterns, param)
    {
    this.m_min_body_size                       = 0;
    this.m_ratio_body_to_candle_size           = PATTERN_DEF_LARGE_BODY;
    this.m_ratio_larger_shadow_to_candle_size  = PATTERN_DEF_INNER_BODY;
    this.m_ratio_smaller_shadow_to_candle_size = 0;
    this.m_ratio_candle_sizes                  = 0;
    this.m_object_id                           = this.CreateObjectID();
    }
   //+------------------------------------------------------------------+
   //| Create object ID based on pattern search criteria                |
   //+------------------------------------------------------------------+
   ulong CBarPatternControlThreeInsideDown::CreateObjectID(void)
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
   CBarPattern *CBarPatternControlThreeInsideDown::CreatePattern(const ENUM_PATTERN_DIRECTION direction,
                                                                  const uint id, CBar *bar)
     {
      if(bar == NULL) return NULL;
      MqlRates rates = {0};
      this.SetBarData(bar, rates);
      CPatternThreeInsideDown *obj = new CPatternThreeInsideDown(id, this.Symbol(), this.Timeframe(), rates, direction);
      if(obj == NULL) return NULL;
      obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           this.RatioBodyToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioLargerShadowToCandleSizeValue());
      obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
      return obj;
     }
   //+------------------------------------------------------------------+
   //| Search for Three Inside Down ending at index           |
   //+------------------------------------------------------------------+
   ENUM_PATTERN_DIRECTION CBarPatternControlThreeInsideDown::FindPattern(const int index,
                                                                           MqlRates &mother_bar_data) const
    {
      if(index < 2) return WRONG_VALUE;
     //--- candle 3 = bearish confirmation
      CBar *bar2 = this.m_list_series.At(index);
     //--- candle 2 = small bearish harami
      CBar *bar1 = this.m_list_series.At(index - 1);
     //--- candle 1 = large bullish mother candle
      CBar *bar0 = this.m_list_series.At(index - 2);
      if(bar2 == NULL || bar1 == NULL || bar0 == NULL) return WRONG_VALUE;

      double minRatio = this.RatioBodyToCandleSizeValue();
      double maxRatio = this.RatioLargerShadowToCandleSizeValue();

     //--- Candle 1: large bullish body
      if(bar0.TypeBody() != BAR_BODY_TYPE_BULLISH)         return WRONG_VALUE;
      if(bar0.RatioBodyToCandleSize() < minRatio)          return WRONG_VALUE;

     //--- Candle 2: small bearish body, inside candle 1's body (Bearish Harami)
      if(bar1.TypeBody() != BAR_BODY_TYPE_BEARISH)         return WRONG_VALUE;
      if(bar1.RatioBodyToCandleSize() > maxRatio)          return WRONG_VALUE;
      if(bar1.BottomBody() < bar0.BottomBody())            return WRONG_VALUE;
      if(bar1.TopBody()    > bar0.TopBody())               return WRONG_VALUE;

     //--- Candle 3: bearish confirmation, closes below candle 2's close
      if(bar2.TypeBody() != BAR_BODY_TYPE_BEARISH)         return WRONG_VALUE;
      if(bar2.Close()    >= bar1.Close())                  return WRONG_VALUE;

     //--- Pattern found
      mother_bar_data.time        = bar2.Time();
      mother_bar_data.open        = bar0.Open();
      mother_bar_data.high        = MathMax(MathMax(bar0.High(), bar1.High()), bar2.High());
      mother_bar_data.low         = MathMin(MathMin(bar0.Low(),  bar1.Low()),  bar2.Low());
      mother_bar_data.close       = bar2.Close();
      mother_bar_data.tick_volume = 3;
      return PATTERN_DIRECTION_BEARISH;
    }
   //+------------------------------------------------------------------+
   //| Return list of Three Inside Down patterns for this object        |
   //+------------------------------------------------------------------+
   CArrayObj *CBarPatternControlThreeInsideDown::GetListPatterns(void)
     {
      CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD,    this.Timeframe(),                     EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL,                        this.Symbol(),                        EQUAL);
      list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE,                          PATTERN_TYPE_THREE_INSIDE_DOWN,       EQUAL);
      return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID,                   this.ObjectID(),                      EQUAL);
     }
 #endif // CBarPatternControlThreeInsideDown_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLTHREEINSIDEDOWN_MQH__
