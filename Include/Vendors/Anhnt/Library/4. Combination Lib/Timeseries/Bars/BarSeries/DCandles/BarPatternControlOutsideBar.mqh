#ifndef __BARPATTERNCONTROLOUTSIDEBAR_MQH__
#define __BARPATTERNCONTROLOUTSIDEBAR_MQH__
//+------------------------------------------------------------------+
//|                                   BarPatternControlOutsideBar.mqh|
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|                          https://mql5.com/en/users/artmedia70    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\BarPatternControl.mqh"
#include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternOutsideBar.mqh"

  #ifndef CBarPatternControlOutsideBar_MQH_DECLARATION
  #define CBarPatternControlOutsideBar_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Outside Bar pattern management class                             |
//+------------------------------------------------------------------+
  class CBarPatternControlOutsideBar : public CBarPatternControl
    {
private:
      //--- Return the ratio of nearby candles for the specified bar
      double                         GetRatioCandles(const CBar *bar) const;
      //--- Check proportions of candle body to candle size
      bool                           CheckProportions(const CBar *bar) const;
      //--- Check and return the presence of a pattern on two adjacent bars
      bool                           CheckOutsideBar(const CBar *bar1, const CBar *bar0) const;

protected:
      //--- (1) Search for a pattern, return direction (or -1),
      //--- (2) create a pattern with a specified direction,
      //--- (3) create and return a unique pattern code
      //--- (4) return the list of patterns managed by the object
      virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
      virtual CBarPattern           *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
      virtual ulong                  GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const;
      virtual CArrayObj             *GetListPatterns(void);
      //--- Create object ID based on pattern search criteria
      virtual ulong                  CreateObjectID(void);

public:
      //--- Parametric constructor
                                     CBarPatternControlOutsideBar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                  CArrayObj *list_series, CArrayObj *list_patterns,
                                                                  const MqlParam &param[]);
    };
  #endif // CBarPatternControlOutsideBar_MQH_DECLARATION

  #ifndef CBarPatternControlOutsideBar_MQH_IMPLEMENTATION
  #define CBarPatternControlOutsideBar_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Parametric constructor                                           |
//+------------------------------------------------------------------+
CBarPatternControlOutsideBar::CBarPatternControlOutsideBar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                           CArrayObj *list_series, CArrayObj *list_patterns,
                                                           const MqlParam &param[]) :
  CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_OUTSIDE_BAR, list_series, list_patterns, param)
  {
   int param_size = ArraySize(this.PatternParams);
   this.m_min_body_size             = (param_size > 0) ? (uint)this.PatternParams[0].integer_value : 0;
   this.m_ratio_candle_sizes        = (param_size > 1) ? this.PatternParams[1].double_value : 0;
   this.m_ratio_body_to_candle_size = (param_size > 2) ? this.PatternParams[2].double_value : 0;
   this.m_object_id                 = this.CreateObjectID();
  }
//+------------------------------------------------------------------+
//| Return the ratio of nearby candles for the specified bar          |
//+------------------------------------------------------------------+
double CBarPatternControlOutsideBar::GetRatioCandles(const CBar *bar) const
  {
   if(bar == NULL) return 0;
   CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, bar.Time(), LESS);
   if(list == NULL || list.Total() == 0) return 0;
   list.Sort(SORT_BY_BAR_TIME);
   CBar *bar1 = list.At(list.Total() - 1);
   if(bar1 == NULL) return 0;
   return(bar.Size() > 0 ? bar1.Size() * 100.0 / bar.Size() : 0.0);
  }
//+------------------------------------------------------------------+
//| Check proportions of candle body to candle size                  |
//+------------------------------------------------------------------+
bool CBarPatternControlOutsideBar::CheckProportions(const CBar *bar) const
  {
   return(bar.RatioBodyToCandleSize() >= this.RatioBodyToCandleSizeValue());
  }
//+------------------------------------------------------------------+
//| Check and return the presence of a pattern on two adjacent bars   |
//+------------------------------------------------------------------+
bool CBarPatternControlOutsideBar::CheckOutsideBar(const CBar *bar1, const CBar *bar0) const
  {
   if(bar0 == NULL || bar1 == NULL ||
      bar0.TypeBody() == BAR_BODY_TYPE_NULL         || bar1.TypeBody() == BAR_BODY_TYPE_NULL         ||
      bar0.TypeBody() == BAR_BODY_TYPE_CANDLE_ZERO_BODY || bar1.TypeBody() == BAR_BODY_TYPE_CANDLE_ZERO_BODY ||
      bar0.TypeBody() == bar1.TypeBody())
      return false;
   double ratio = (bar0.Size() > 0 ? bar1.Size() * 100.0 / bar0.Size() : 0.0);
   if(ratio < this.RatioCandleSizeValue()) return false;
   return(bar1.High() <= bar0.High() && bar1.Low() >= bar0.Low() &&
          bar1.TopBody() < bar0.TopBody() && bar1.BottomBody() > bar0.BottomBody());
  }
//+------------------------------------------------------------------+
//| Get pattern code                                                  |
//+------------------------------------------------------------------+
ulong CBarPatternControlOutsideBar::GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
  {
   return(time+PATTERN_TYPE_OUTSIDE_BAR+PATTERN_STATUS_PA+direction+this.Timeframe()+this.m_symbol_code);
  }
//+------------------------------------------------------------------+
//| Create object ID based on pattern search criteria                |
//+------------------------------------------------------------------+
ulong CBarPatternControlOutsideBar::CreateObjectID(void)
  {
   ushort bodies = (ushort)this.RatioCandleSizeValue() * 100;
   ushort body   = (ushort)this.RatioBodyToCandleSizeValue() * 100;
   long   res    = 0;
   this.UshortToLong(bodies, 0, res);
   return this.UshortToLong(body, 1, res);
  }
//+------------------------------------------------------------------+
//| Create a pattern with a specified direction                      |
//+------------------------------------------------------------------+
CBarPattern *CBarPatternControlOutsideBar::CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar)
  {
   if(bar == NULL) return NULL;
   MqlRates rates = {0};
   this.SetBarData(bar, rates);
   CPatternOutsideBar *obj = new CPatternOutsideBar(id, this.Symbol(), this.Timeframe(), rates, direction);
   if(obj == NULL) return NULL;
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      bar.RatioBodyToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              bar.RatioLowerShadowToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              bar.RatioUpperShadowToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_CANDLE_SIZES,                             this.GetRatioCandles(bar));
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioSmallerShadowToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_CANDLE_SIZES_CRITERION,                   this.RatioCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
   return obj;
  }
//+------------------------------------------------------------------+
//| CBarPatternControlOutsideBar::Search for pattern                 |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CBarPatternControlOutsideBar::FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const
  {
   CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, series_bar_time, EQUAL_OR_LESS);
   if(list == NULL || list.Total() == 0) return WRONG_VALUE;
   list.Sort(SORT_BY_BAR_TIME);
   CBar *bar_patt = list.At(list.Total() - 1);
   if(bar_patt == NULL) return WRONG_VALUE;
   for(int i = list.Total() - 2; i >= 0; i--)
     {
      CBar *bar_prev = list.At(i);
      if(bar_prev == NULL) return WRONG_VALUE;
      if(!this.CheckProportions(bar_patt) || !this.CheckProportions(bar_prev)) return WRONG_VALUE;
      if(!this.CheckOutsideBar(bar_prev, bar_patt)) return WRONG_VALUE;
      this.SetBarData(bar_prev, mother_bar_data);
      if(bar_patt.TypeBody() == BAR_BODY_TYPE_BULLISH) return PATTERN_DIRECTION_BULLISH;
      if(bar_patt.TypeBody() == BAR_BODY_TYPE_BEARISH) return PATTERN_DIRECTION_BEARISH;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Return the list of patterns managed by the object                |
//+------------------------------------------------------------------+
CArrayObj *CBarPatternControlOutsideBar::GetListPatterns(void)
  {
   CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD, this.Timeframe(), EQUAL);
   list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL, this.Symbol(), EQUAL);
   list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE, PATTERN_TYPE_OUTSIDE_BAR, EQUAL);
   return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID(), EQUAL);
  }
  #endif // CBarPatternControlOutsideBar_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLOUTSIDEBAR_MQH__
