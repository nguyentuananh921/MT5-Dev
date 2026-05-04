#ifndef __PATTERNCONTROLINSIDEBAR_MQH__
#define __PATTERNCONTROLINSIDEBAR_MQH__
//+------------------------------------------------------------------+
//|                                              PatternControlInsideBar.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "PatternControl.mqh"

 #ifndef CPATTERNCONTROLINSIDEBAR_MQH_DECLARATION
 #define CPATTERNCONTROLINSIDEBAR_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Inside Bar pattern control class                                 |
//+------------------------------------------------------------------+
 class CPatternControlInsideBar : public CPatternControl
  {
   private:
    //--- Check and return the presence of a pattern on two adjacent bars
    bool              CheckInsideBar(const CBar *bar1,const CBar *bar0) const
                       {
                        //--- If empty bar objects are passed, return 'false'
                        if(bar0==NULL || bar1==NULL)
                           return false;
                        //--- Return the fact that the bar on the right is completely within the dimensions of the bar on the left
                        return(bar0.High()<bar1.High() && bar0.Low()>bar1.Low());
                       }
    bool              FindMotherBar(CArrayObj *list,MqlRates &rates) const
                       {
                        bool res=false;
                        if(list==NULL)
                           return false;
                        //--- In a loop through the list, starting from the bar to the left of the base one
                        for(int i=list.Total()-2;i>0;i--)
                          {
                           //--- Get the pointers to two consecutive bars
                           CBar *bar0=list.At(i);
                           CBar *bar1=list.At(i-1);
                           if(bar0==NULL || bar1==NULL)
                              return false;
                           //--- If the obtained bars represent a pattern,
                           if(CheckInsideBar(bar1,bar0))
                             {
                              //--- set mother bar data to the MqlRates variable and set 'res' to 'true'
                              this.SetBarData(bar1,rates);
                              res=true;
                             }
                           //--- If there is no pattern, interrupt the loop
                           else
                              break;
                          }
                        //--- return result
                        return res;
                       }
   protected:
    //--- (1) Search for a pattern, return direction (or -1),
    //--- (2) create a pattern with a specified direction,
    //--- (3) create and return a unique pattern code
    //--- (4) return the list of patterns managed by the object
    virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time,MqlRates &mother_bar_data) const;
    virtual CPattern *CreatePattern(const ENUM_PATTERN_DIRECTION direction,const uint id,CBar *bar);
    virtual ulong     GetPatternCode(const ENUM_PATTERN_DIRECTION direction,const datetime time) const
                       {
                        //--- unique pattern code = candle opening time + type + status + pattern direction + timeframe + timeseries symbol
                        return(time+PATTERN_TYPE_INSIDE_BAR+PATTERN_STATUS_PA+PATTERN_DIRECTION_BOTH+this.Timeframe()+this.m_symbol_code);
                       }
    virtual CArrayObj*GetListPatterns(void);
    //--- Create object ID based on pattern search criteria
    virtual ulong     CreateObjectID(void);

   public:
    //--- Parametric constructor
                     CPatternControlInsideBar(const string symbol,const ENUM_TIMEFRAMES timeframe,
                                              CArrayObj *list_series,CArrayObj *list_patterns,const MqlParam &param[]) :
                        CPatternControl(symbol,timeframe,PATTERN_STATUS_PA,PATTERN_TYPE_INSIDE_BAR,list_series,list_patterns,param)
                       {
                        this.m_min_body_size=(uint)this.PatternParams[0].integer_value;
                        this.m_ratio_body_to_candle_size=0;
                        this.m_ratio_larger_shadow_to_candle_size=0;
                        this.m_ratio_smaller_shadow_to_candle_size=0;
                        this.m_ratio_candle_sizes=0;
                        this.m_object_id=this.CreateObjectID();
                       }
  };
 #endif // CPATTERNCONTROLINSIDEBAR_MQH_DECLARATION

 #ifndef CPATTERNCONTROLINSIDEBAR_MQH_IMPLEMENTATION
 #define CPATTERNCONTROLINSIDEBAR_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Create object ID based on pattern search criteria                |
//+------------------------------------------------------------------+
ulong CPatternControlInsideBar::CreateObjectID(void)
  {
   return 0;
  }
//+-----------------------------------------------------------------------+
//|CPatternControlInsideBar::Create a pattern with the specified direction|
//+-----------------------------------------------------------------------+
CPattern *CPatternControlInsideBar::CreatePattern(const ENUM_PATTERN_DIRECTION direction,const uint id,CBar *bar)
  {
//--- If invalid indicator is passed to the bar object, return NULL
   if(bar==NULL)
      return NULL;
//--- Fill the MqlRates structure with bar data
   MqlRates rates={0};
   this.SetBarData(bar,rates);
//--- Create a new Inside Bar pattern
   CPatternInsideBar *obj=new CPatternInsideBar(id,this.Symbol(),this.Timeframe(),rates,PATTERN_DIRECTION_BOTH);
   if(obj==NULL)
      return NULL;
//--- set the proportions of the candle the pattern was found on to the properties of the created pattern object
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,bar.RatioBodyToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,bar.RatioLowerShadowToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,bar.RatioUpperShadowToCandleSize());
//--- set the search criteria of the candle the pattern was found on to the properties of the created pattern object
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,this.RatioBodyToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,this.RatioLargerShadowToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,this.RatioSmallerShadowToCandleSizeValue());
//--- Set the control object ID to the pattern object
   obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID,this.ObjectID());
//--- Return the pointer to a created object
   return obj;
  }
//+------------------------------------------------------------------+
//| CPatternControlInsideBar::Search for pattern                     |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CPatternControlInsideBar::FindPattern(const datetime series_bar_time,MqlRates &mother_bar_data) const
  {
//--- Get bar data up to and including the specified time
   CArrayObj *list=CSelect::ByBarProperty(this.m_list_series,BAR_PROP_TIME,series_bar_time,EQUAL_OR_LESS);
//--- If the list is empty, return -1
   if(list==NULL || list.Total()==0)
      return WRONG_VALUE;
//--- Sort the list by bar opening time
   list.Sort(SORT_BY_BAR_TIME);
//--- Get the latest bar from the list (base bar)
   CBar *bar_patt=list.At(list.Total()-1);
   if(bar_patt==NULL)
      return WRONG_VALUE;
//--- In the loop from the next bar (mother),
   for(int i=list.Total()-2;i>=0;i--)
     {
      CBar *bar_prev=list.At(i);
      if(bar_prev==NULL)
         return WRONG_VALUE;
      //--- check that the resulting two bars are a pattern. If not, return -1
      if(!this.CheckInsideBar(bar_prev,bar_patt))
         return WRONG_VALUE;
      //--- If the pattern is found at the previous step, look for nested patterns.
      //--- The leftmost bar will be the mother bar for the entire chain of nested patterns
      //--- If the found pattern does not have nested ones, then its mother bar will be the current cycle bar (to the left of the base one)
      if(!this.FindMotherBar(list,mother_bar_data))
         this.SetBarData(bar_prev,mother_bar_data);
//--- Return the pattern direction (bidirectional)
      return PATTERN_DIRECTION_BOTH;
     }
//--- No patterns found - return -1
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| return the list of patterns managed by the object                |
//+------------------------------------------------------------------+
CArrayObj *CPatternControlInsideBar::GetListPatterns(void)
  {
   CArrayObj *list=CSelect::ByPatternProperty(this.m_list_all_patterns,PATTERN_PROP_PERIOD,this.Timeframe(),EQUAL);
   list=CSelect::ByPatternProperty(list,PATTERN_PROP_SYMBOL,this.Symbol(),EQUAL);
   list=CSelect::ByPatternProperty(list,PATTERN_PROP_TYPE,PATTERN_TYPE_INSIDE_BAR,EQUAL);
   return CSelect::ByPatternProperty(list,PATTERN_PROP_CTRL_OBJ_ID,this.ObjectID(),EQUAL);
  }
//+------------------------------------------------------------------+
 #endif // CPATTERNCONTROLINSIDEBAR_MQH_IMPLEMENTATION
#endif // __PATTERNCONTROLINSIDEBAR_MQH__
