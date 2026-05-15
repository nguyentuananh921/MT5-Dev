#ifndef __BARPATTERNCONTROLPINBAR_MQH__
#define __BARPATTERNCONTROLPINBAR_MQH__
//+------------------------------------------------------------------+
//|                                      BarPatternControlPinBar.mqh |
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
#include "..\..\BarSeriesPatterns\SCandlesPatterns\PatternPinBar.mqh"

  #ifndef CBarPatternControlPinBar_MQH_DECLARATION
  #define CBarPatternControlPinBar_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Pin Bar pattern control class                                    |
//+------------------------------------------------------------------+
  class CBarPatternControlPinBar : public CBarPatternControl
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
                                         return(time+PATTERN_TYPE_PIN_BAR+PATTERN_STATUS_PA+direction+this.Timeframe()+this.m_symbol_code);
                                       }
      virtual CArrayObj             *GetListPatterns(void);
      //--- Create object ID based on pattern search criteria
      virtual ulong                  CreateObjectID(void);

    public:
      //--- Parametric constructor
                                     CBarPatternControlPinBar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                              CArrayObj *list_series, CArrayObj *list_patterns,
                                                              const MqlParam &param[]) :
                                       CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_PIN_BAR, list_series, list_patterns, param)
                                         {
                                           this.m_min_body_size                          = (uint)this.PatternParams[0].integer_value;
                                           this.m_ratio_body_to_candle_size              = this.PatternParams[1].double_value;
                                           this.m_ratio_larger_shadow_to_candle_size     = this.PatternParams[2].double_value;
                                           this.m_ratio_smaller_shadow_to_candle_size    = this.PatternParams[3].double_value;
                                           this.m_ratio_candle_sizes                     = 0;
                                           this.m_object_id                              = this.CreateObjectID();
                                         }
    };
  #endif // CBarPatternControlPinBar_MQH_DECLARATION

  #ifndef CBarPatternControlPinBar_MQH_IMPLEMENTATION
  #define CBarPatternControlPinBar_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Create object ID based on pattern search criteria                |
//+------------------------------------------------------------------+
ulong CBarPatternControlPinBar::CreateObjectID(void)
  {
   ushort body    = (ushort)this.RatioBodyToCandleSizeValue() * 100;
   ushort larger  = (ushort)this.RatioLargerShadowToCandleSizeValue() * 100;
   ushort smaller = (ushort)this.RatioSmallerShadowToCandleSizeValue() * 100;
   long   res     = 0;
   this.UshortToLong(body,    0, res);
   this.UshortToLong(larger,  1, res);
   return this.UshortToLong(smaller, 2, res);
  }
//+------------------------------------------------------------------+
//| CBarPatternControlPinBar::Create a pattern with a specified dir  |
//+------------------------------------------------------------------+
CBarPattern *CBarPatternControlPinBar::CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar)
  {
   if(bar == NULL)
      return NULL;
   MqlRates rates = {0};
   this.SetBarData(bar, rates);
   CPatternPinBar *obj = new CPatternPinBar(id, this.Symbol(), this.Timeframe(), rates, direction);
   if(obj == NULL)
      return NULL;
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      bar.RatioBodyToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              bar.RatioLowerShadowToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              bar.RatioUpperShadowToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,            this.RatioBodyToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,   this.RatioLargerShadowToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,  this.RatioSmallerShadowToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID());
   return obj;
  }
//+------------------------------------------------------------------+
//| CBarPatternControlPinBar::Search for pattern                     |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CBarPatternControlPinBar::FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const
  {
   CArrayObj *list = CTimeseriesSelect::ByBarProperty(this.m_list_series, BAR_PROP_TIME, series_bar_time, EQUAL);
   if(list == NULL || list.Total() == 0)
      return WRONG_VALUE;
   list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE, this.RatioBodyToCandleSizeValue(), EQUAL_OR_LESS);
   list = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE, this.m_min_body_size, EQUAL_OR_MORE);
   if(list == NULL || list.Total() == 0)
      return WRONG_VALUE;
   //--- Define the bullish pattern
   CArrayObj *list_bullish = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE, this.RatioLargerShadowToCandleSizeValue(), EQUAL_OR_MORE);
   list_bullish            = CTimeseriesSelect::ByBarProperty(list_bullish, BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE, this.RatioSmallerShadowToCandleSizeValue(), EQUAL_OR_LESS);
   if(list_bullish != NULL && list_bullish.Total() > 0)
     {
      CBar *bar = list.At(list_bullish.Total() - 1);
      if(bar != NULL)
        {
         this.SetBarData(bar, mother_bar_data);
         return PATTERN_DIRECTION_BULLISH;
        }
     }
   //--- Define the bearish pattern
   CArrayObj *list_bearish = CTimeseriesSelect::ByBarProperty(list, BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE, this.RatioLargerShadowToCandleSizeValue(), EQUAL_OR_MORE);
   list_bearish            = CTimeseriesSelect::ByBarProperty(list_bearish, BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE, this.RatioSmallerShadowToCandleSizeValue(), EQUAL_OR_LESS);
   if(list_bearish != NULL && list_bearish.Total() > 0)
     {
      CBar *bar = list.At(list_bearish.Total() - 1);
      if(bar != NULL)
        {
         this.SetBarData(bar, mother_bar_data);
         return PATTERN_DIRECTION_BEARISH;
        }
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Return the list of patterns managed by the object                |
//+------------------------------------------------------------------+
CArrayObj *CBarPatternControlPinBar::GetListPatterns(void)
  {
   CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD, this.Timeframe(), EQUAL);
   list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL, this.Symbol(), EQUAL);
   list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE, PATTERN_TYPE_PIN_BAR, EQUAL);
   return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID(), EQUAL);
  }
  #endif // CBarPatternControlPinBar_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLPINBAR_MQH__
