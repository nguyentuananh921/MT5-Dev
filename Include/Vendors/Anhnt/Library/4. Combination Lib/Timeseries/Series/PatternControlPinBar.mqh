#ifndef __PATTERNCONTROLPINBAR_MQH__
#define __PATTERNCONTROLPINBAR_MQH__
//+------------------------------------------------------------------+
//|                                              PatternControlPinBar.mqh |
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

 #ifndef CPATTERNCONTROLPINBAR_MQH_DECLARATION
 #define CPATTERNCONTROLPINBAR_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Pin Bar pattern control class                                    |
//+------------------------------------------------------------------+
 class CPatternControlPinBar : public CPatternControl
  {
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
                        return(time+PATTERN_TYPE_PIN_BAR+PATTERN_STATUS_PA+direction+this.Timeframe()+this.m_symbol_code);
                       }
    virtual CArrayObj*GetListPatterns(void);
    //--- Create object ID based on pattern search criteria
    virtual ulong     CreateObjectID(void);

   public:
    //--- Parametric constructor
                     CPatternControlPinBar(const string symbol,const ENUM_TIMEFRAMES timeframe,
                                           CArrayObj *list_series,CArrayObj *list_patterns,
                                           const MqlParam &param[]) :
                        CPatternControl(symbol,timeframe,PATTERN_STATUS_PA,PATTERN_TYPE_PIN_BAR,list_series,list_patterns,param)
                       {
                        this.m_min_body_size=(uint)this.PatternParams[0].integer_value;
                        this.m_ratio_body_to_candle_size=this.PatternParams[1].double_value;
                        this.m_ratio_larger_shadow_to_candle_size=this.PatternParams[2].double_value;
                        this.m_ratio_smaller_shadow_to_candle_size=this.PatternParams[3].double_value;
                        this.m_ratio_candle_sizes=0;
                        this.m_object_id=this.CreateObjectID();
                       }
  };
 #endif // CPATTERNCONTROLPINBAR_MQH_DECLARATION

 #ifndef CPATTERNCONTROLPINBAR_MQH_IMPLEMENTATION
 #define CPATTERNCONTROLPINBAR_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Create object ID based on pattern search criteria                |
//+------------------------------------------------------------------+
ulong CPatternControlPinBar::CreateObjectID(void)
  {
   ushort body=(ushort)this.RatioBodyToCandleSizeValue()*100;
   ushort larger=(ushort)this.RatioLargerShadowToCandleSizeValue()*100;
   ushort smaller=(ushort)this.RatioSmallerShadowToCandleSizeValue()*100;
   long res=0;
   this.UshortToLong(body,0,res);
   this.UshortToLong(larger,1,res);
   return this.UshortToLong(smaller,2,res);
  }
//+-------------------------------------------------------------------+
//| CPatternControlPinBar::Create a pattern with a specified direction|
//+-------------------------------------------------------------------+
CPattern *CPatternControlPinBar::CreatePattern(const ENUM_PATTERN_DIRECTION direction,const uint id,CBar *bar)
  {
//--- If invalid indicator is passed to the bar object, return NULL
   if(bar==NULL)
      return NULL;
//--- Fill the MqlRates structure with bar data
   MqlRates rates={0};
   this.SetBarData(bar,rates);
//--- Create a new Pin Bar pattern
   CPatternPinBar *obj=new CPatternPinBar(id,this.Symbol(),this.Timeframe(),rates,direction);
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
//| CPatternControlPinBar::Search for pattern                        |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CPatternControlPinBar::FindPattern(const datetime series_bar_time,MqlRates &mother_bar_data) const
  {
//--- Get data for one bar by time
   CArrayObj *list=CSelect::ByBarProperty(this.m_list_series,BAR_PROP_TIME,series_bar_time,EQUAL);
//--- If the list is empty, return -1
   if(list==NULL || list.Total()==0)
      return WRONG_VALUE;
//--- he size of the candle body should be less than or equal to RatioBodyToCandleSizeValue() (default 30%) of the entire candle size,
//--- in this case, the body size should not be less than min_body_size
   list=CSelect::ByBarProperty(list,BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,this.RatioBodyToCandleSizeValue(),EQUAL_OR_LESS);
   list=CSelect::ByBarProperty(list,BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,this.m_min_body_size,EQUAL_OR_MORE);
//--- If the list is empty - there are no patterns, return -1
   if(list==NULL || list.Total()==0)
      return WRONG_VALUE;
      
//--- Define the bullish pattern
//--- The lower shadow should be equal to or greater than RatioLargerShadowToCandleSizeValue() (default 60%) of the entire candle size
   CArrayObj *list_bullish=CSelect::ByBarProperty(list,BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,this.RatioLargerShadowToCandleSizeValue(),EQUAL_OR_MORE);
//--- The upper shadow should be less than or equal to RatioSmallerShadowToCandleSizeValue() (default 30%) of the entire candle size
   list_bullish=CSelect::ByBarProperty(list_bullish,BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,this.RatioSmallerShadowToCandleSizeValue(),EQUAL_OR_LESS);
//--- If a pattern is found on the bar
   if(list_bullish!=NULL && list_bullish.Total()>0)
     {
      CBar *bar=list.At(list_bullish.Total()-1);
      if(bar!=NULL)
        {
         this.SetBarData(bar,mother_bar_data);
         return PATTERN_DIRECTION_BULLISH;
        }
     }

//--- Define the bearish pattern
//--- The upper shadow should be equal to or greater than RatioLargerShadowToCandleSizeValue() (default 60%) of the entire candle size
   CArrayObj *list_bearish=CSelect::ByBarProperty(list,BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,this.RatioLargerShadowToCandleSizeValue(),EQUAL_OR_MORE);
//--- The lower shadow should be less than or equal to RatioSmallerShadowToCandleSizeValue() (default 30%) of the entire candle size
   list_bearish=CSelect::ByBarProperty(list_bearish,BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,this.RatioSmallerShadowToCandleSizeValue(),EQUAL_OR_LESS);
//--- If a pattern is found on the bar
   if(list_bearish!=NULL && list_bearish.Total()>0)
     {
      CBar *bar=list.At(list_bearish.Total()-1);
      if(bar!=NULL)
        {
         this.SetBarData(bar,mother_bar_data);
         return PATTERN_DIRECTION_BEARISH;
        }
     }
//--- No patterns found - return -1
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| return the list of patterns managed by the object                |
//+------------------------------------------------------------------+
CArrayObj *CPatternControlPinBar::GetListPatterns(void)
  {
   CArrayObj *list=CSelect::ByPatternProperty(this.m_list_all_patterns,PATTERN_PROP_PERIOD,this.Timeframe(),EQUAL);
   list=CSelect::ByPatternProperty(list,PATTERN_PROP_SYMBOL,this.Symbol(),EQUAL);
   list=CSelect::ByPatternProperty(list,PATTERN_PROP_TYPE,PATTERN_TYPE_PIN_BAR,EQUAL);
   return CSelect::ByPatternProperty(list,PATTERN_PROP_CTRL_OBJ_ID,this.ObjectID(),EQUAL);
  }
//+------------------------------------------------------------------+
 #endif // CPATTERNCONTROLPINBAR_MQH_IMPLEMENTATION
#endif // __PATTERNCONTROLPINBAR_MQH__
