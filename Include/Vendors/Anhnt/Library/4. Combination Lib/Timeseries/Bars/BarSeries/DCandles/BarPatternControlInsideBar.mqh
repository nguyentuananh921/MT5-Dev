#ifndef __BARPATTERNCONTROLINSIDEBAR_MQH__
#define __BARPATTERNCONTROLINSIDEBAR_MQH__
//+------------------------------------------------------------------+
//|                                    BarPatternControlInsideBar.mqh|
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
#include "..\..\BarSeriesPatterns\DCandlesPatterns\PatternInsideBar.mqh"
 #ifndef CBarPatternControlInsideBar_MQH_DECLARATION
 #define CBarPatternControlInsideBar_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Inside Bar pattern control class                                 |
 //+------------------------------------------------------------------+
 class CBarPatternControlInsideBar : public CBarPatternControl
  {
    private:
     //--- Check and return the presence of a pattern on two adjacent bars
        bool                             CheckInsideBar(const CBar *bar1, const CBar *bar0) const;
        bool                             FindMotherBar(CArrayObj *list, MqlRates &rates) const;
    protected:
     //--- (1) Search for a pattern, return direction (or -1),
     //--- (2) create a pattern with a specified direction,
     //--- (3) create and return a unique pattern code
     //--- (4) return the list of patterns managed by the object
        virtual ENUM_PATTERN_DIRECTION   FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const;
        virtual CBarPattern             *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar);
        virtual ulong                    GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const;
        virtual CArrayObj               *GetListPatterns(void);
     //--- Create object ID based on pattern search criteria
        virtual ulong                    CreateObjectID(void);

    public:
     //--- Parametric constructor
                                         CBarPatternControlInsideBar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                                     CArrayObj *list_series, CArrayObj *list_patterns,
                                                                     const MqlParam &param[]);
  };
 #endif // CBarPatternControlInsideBar_MQH_DECLARATION
 #ifndef CBarPatternControlInsideBar_MQH_IMPLEMENTATION
 #define CBarPatternControlInsideBar_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Parametric constructor                                           |
 //+------------------------------------------------------------------+
 CBarPatternControlInsideBar::CBarPatternControlInsideBar(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                        CArrayObj *list_series, CArrayObj *list_patterns,
                                                        const MqlParam &param[]) :
  CBarPatternControl(symbol, timeframe, PATTERN_STATUS_PA, PATTERN_TYPE_INSIDE_BAR, list_series, list_patterns, param)
   {
     this.m_min_body_size                       = (ArraySize(this.PatternParams) > 0) ? (uint)this.PatternParams[0].integer_value : 0;
     this.m_ratio_body_to_candle_size           = 0;
     this.m_ratio_larger_shadow_to_candle_size  = 0;
     this.m_ratio_smaller_shadow_to_candle_size = 0;
     this.m_ratio_candle_sizes                  = 0;
     this.m_object_id                           = this.CreateObjectID();
   }
 //+------------------------------------------------------------------+
 //| Check and return the presence of a pattern on two adjacent bars   |
 //+------------------------------------------------------------------+
 bool CBarPatternControlInsideBar::CheckInsideBar(const CBar *bar1, const CBar *bar0) const
  {
   if(bar0 == NULL || bar1 == NULL) return false;
   return(bar0.High() < bar1.High() && bar0.Low() > bar1.Low());
  }
 //+------------------------------------------------------------------+
 //| Find mother bar for inside bar pattern                           |
 //+------------------------------------------------------------------+
 bool CBarPatternControlInsideBar::FindMotherBar(CArrayObj *list, MqlRates &rates) const
  {
   bool res = false;
   if(list == NULL) return false;
   for(int i = list.Total() - 2; i > 0; i--)
     {
      CBar *bar0 = list.At(i);
      CBar *bar1 = list.At(i - 1);
      if(bar0 == NULL || bar1 == NULL) return false;
      if(CheckInsideBar(bar1, bar0))
        {
         this.SetBarData(bar1, rates);
         res = true;
        }
      else
         break;
     }
   return res;
  }
 //+------------------------------------------------------------------+
 //| Get pattern code                                                  |
 //+------------------------------------------------------------------+
 ulong CBarPatternControlInsideBar::GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const
  {
   return(time+PATTERN_TYPE_INSIDE_BAR+PATTERN_STATUS_PA+PATTERN_DIRECTION_BOTH+this.Timeframe()+this.m_symbol_code);
  }
 //+------------------------------------------------------------------+
 //| Create object ID based on pattern search criteria                |
 //+------------------------------------------------------------------+
 ulong CBarPatternControlInsideBar::CreateObjectID(void)
  {
   return 0;
  }
 //+------------------------------------------------------------------+
 //| Create a pattern with the specified direction                    |
 //+------------------------------------------------------------------+
 CBarPattern *CBarPatternControlInsideBar::CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar)
  {
   if(bar == NULL) return NULL;
   MqlRates rates = {0};
   this.SetBarData(bar, rates);
   CPatternInsideBar *obj = new CPatternInsideBar(id, this.Symbol(), this.Timeframe(), rates, PATTERN_DIRECTION_BOTH);
   if(obj == NULL) return NULL;
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
 //| Search for pattern                                               |
 //+------------------------------------------------------------------+
 ENUM_PATTERN_DIRECTION CBarPatternControlInsideBar::FindPattern(const datetime series_bar_time, MqlRates &mother_bar_data) const
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
      if(!this.CheckInsideBar(bar_prev, bar_patt)) return WRONG_VALUE;
      if(!this.FindMotherBar(list, mother_bar_data))
         this.SetBarData(bar_prev, mother_bar_data);
      return PATTERN_DIRECTION_BOTH;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Return the list of patterns managed by the object                |
 //+------------------------------------------------------------------+
 CArrayObj *CBarPatternControlInsideBar::GetListPatterns(void)
  {
   CArrayObj *list = CTimeseriesSelect::ByPatternProperty(this.m_list_all_patterns, PATTERN_PROP_PERIOD, this.Timeframe(), EQUAL);
   list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_SYMBOL, this.Symbol(), EQUAL);
   list            = CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_TYPE, PATTERN_TYPE_INSIDE_BAR, EQUAL);
   return            CTimeseriesSelect::ByPatternProperty(list, PATTERN_PROP_CTRL_OBJ_ID, this.ObjectID(), EQUAL);
  }
 #endif // CBarPatternControlInsideBar_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROLINSIDEBAR_MQH__
