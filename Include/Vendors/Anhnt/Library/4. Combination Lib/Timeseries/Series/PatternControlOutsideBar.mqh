#ifndef __PATTERNCONTROLOUTSIDEBAR_MQH__
#define __PATTERNCONTROLOUTSIDEBAR_MQH__
//+------------------------------------------------------------------+
//|                                              PatternControlOutsideBar.mqh |
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

 #ifndef CPATTERNCONTROLOUTSIDEBAR_MQH_DECLARATION
 #define CPATTERNCONTROLOUTSIDEBAR_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Outside Bar pattern management class                             |
//+------------------------------------------------------------------+
 class CPatternControlOutsideBar : public CPatternControl
  {
   private:
    //--- Return the ratio of nearby candles for the specified bar
    double            GetRatioCandles(const CBar *bar)  const
                       {
                        //--- If an empty object is passed, return 0
                        if(bar==NULL)
                           return 0;
                        //--- Get a list of bars with a time less than that passed to the method
                        CArrayObj *list=CSelect::ByBarProperty(this.m_list_series,BAR_PROP_TIME,bar.Time(),LESS);
                        if(list==NULL || list.Total()==0)
                           return 0;
                        //--- Set the flag of sorting by bar time for the list and
                        list.Sort(SORT_BY_BAR_TIME);
                        //--- get the pointer to the last bar in the list (closest to the one passed to the method)
                        CBar *bar1=list.At(list.Total()-1);
                        if(bar1==NULL)
                           return 0;
                        //--- Return the ratio of the sizes of one bar to another
                        return(bar.Size()>0 ? bar1.Size()*100.0/bar.Size() : 0.0);
                       }
    //--- Check and return the flag of compliance with the ratio of the candle body to its size relative to the specified value
    bool              CheckProportions(const CBar *bar) const { return(bar.RatioBodyToCandleSize()>=this.RatioBodyToCandleSizeValue());  }

    //--- Check and return the presence of a pattern on two adjacent bars
    bool              CheckOutsideBar(const CBar *bar1,const CBar *bar0) const
                       {
                        //--- If empty bar objects are passed, or their types in direction are neither bullish nor bearish, or are the same - return 'false'
                        if(bar0==NULL || bar1==NULL || 
                           bar0.TypeBody()==BAR_BODY_TYPE_NULL || bar1.TypeBody()==BAR_BODY_TYPE_NULL ||
                           bar0.TypeBody()==BAR_BODY_TYPE_CANDLE_ZERO_BODY || bar1.TypeBody()==BAR_BODY_TYPE_CANDLE_ZERO_BODY ||
                           bar0.TypeBody()==bar1.TypeBody())
                           return false;
                        //--- Calculate the ratio of the specified candles and, if it is less than the specified one, return 'false'
                        double ratio=(bar0.Size()>0 ? bar1.Size()*100.0/bar0.Size() : 0.0);
                        if(ratio<this.RatioCandleSizeValue())
                           return false;
                        //--- Return the fact that the bar body on the right completely covers the dimensions of the bar body on the left,
                        //--- and the shadows of the bars are either equal, or the shadows of the bar on the right overlap the shadows of the bar on the left
                        return(bar1.High()<=bar0.High() && bar1.Low()>=bar0.Low() && bar1.TopBody()<bar0.TopBody() && bar1.BottomBody()>bar0.BottomBody());
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
                        return(time+PATTERN_TYPE_OUTSIDE_BAR+PATTERN_STATUS_PA+direction+this.Timeframe()+this.m_symbol_code);
                       }
    virtual CArrayObj*GetListPatterns(void);
    //--- Create object ID based on pattern search criteria
    virtual ulong     CreateObjectID(void);

   public:
    //--- Parametric constructor
                     CPatternControlOutsideBar(const string symbol,const ENUM_TIMEFRAMES timeframe,
                                               CArrayObj *list_series,CArrayObj *list_patterns,
                                               const MqlParam &param[]) :
                        CPatternControl(symbol,timeframe,PATTERN_STATUS_PA,PATTERN_TYPE_OUTSIDE_BAR,list_series,list_patterns,param)
                       {
                        this.m_min_body_size=(uint)this.PatternParams[0].integer_value;      // Minimum size of pattern candles
                        this.m_ratio_candle_sizes=this.PatternParams[1].double_value;        // Percentage ratio of the size of the engulfing color to the size of the engulfed one
                        this.m_ratio_body_to_candle_size=this.PatternParams[2].double_value; // Percentage of full size to candle body size
                        this.m_object_id=this.CreateObjectID();
                       }
  };
 #endif // CPATTERNCONTROLOUTSIDEBAR_MQH_DECLARATION

 #ifndef CPATTERNCONTROLOUTSIDEBAR_MQH_IMPLEMENTATION
 #define CPATTERNCONTROLOUTSIDEBAR_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Create object ID based on pattern search criteria                |
//+------------------------------------------------------------------+
ulong CPatternControlOutsideBar::CreateObjectID(void)
  {
   ushort bodies=(ushort)this.RatioCandleSizeValue()*100;
   ushort body=(ushort)this.RatioBodyToCandleSizeValue()*100;
   long  res=0;
   this.UshortToLong(bodies,0,res);
   return this.UshortToLong(body,1,res);
  }
//+------------------------------------------------------------------+
//| Create a pattern with a specified direction                      |
//+------------------------------------------------------------------+
CPattern *CPatternControlOutsideBar::CreatePattern(const ENUM_PATTERN_DIRECTION direction,const uint id,CBar *bar)
  {
//--- If invalid indicator is passed to the bar object, return NULL
   if(bar==NULL)
      return NULL;
//--- Fill the MqlRates structure with bar data
   MqlRates rates={0};
   this.SetBarData(bar,rates);
//--- Create a new Outside Bar pattern
   CPatternOutsideBar *obj=new CPatternOutsideBar(id,this.Symbol(),this.Timeframe(),rates,direction);
   if(obj==NULL)
      return NULL;
//--- set the proportions of the candle the pattern was found on to the properties of the created pattern object
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,bar.RatioBodyToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,bar.RatioLowerShadowToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,bar.RatioUpperShadowToCandleSize());
   obj.SetProperty(PATTERN_PROP_RATIO_CANDLE_SIZES,this.GetRatioCandles(bar));
//--- set the search criteria of the candle the pattern was found on to the properties of the created pattern object
   obj.SetProperty(PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,this.RatioBodyToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,this.RatioLargerShadowToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,this.RatioSmallerShadowToCandleSizeValue());
   obj.SetProperty(PATTERN_PROP_RATIO_CANDLE_SIZES_CRITERION,this.RatioCandleSizeValue());
//--- Set the control object ID to the pattern object
   obj.SetProperty(PATTERN_PROP_CTRL_OBJ_ID,this.ObjectID());
//--- Return the pointer to a created object
   return obj;
  }
//+------------------------------------------------------------------+
//| CPatternControlOutsideBar::Search for pattern                    |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CPatternControlOutsideBar::FindPattern(const datetime series_bar_time,MqlRates &mother_bar_data) const
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
      //--- Get the "mother" bar
      CBar *bar_prev=list.At(i);
      if(bar_prev==NULL)
         return WRONG_VALUE;
      //--- If the proportions of the bars do not match the pattern, return -1
      if(!this.CheckProportions(bar_patt) || !this.CheckProportions(bar_prev))
         return WRONG_VALUE;
      //--- check that the resulting two bars are a pattern. If not, return -1
      if(!this.CheckOutsideBar(bar_prev,bar_patt))
         return WRONG_VALUE;
      //--- Set the "mother" bar data
      this.SetBarData(bar_prev,mother_bar_data);
      //--- If the pattern is found at the previous step, determine and return its direction
      if(bar_patt.TypeBody()==BAR_BODY_TYPE_BULLISH)
         return PATTERN_DIRECTION_BULLISH;
      if(bar_patt.TypeBody()==BAR_BODY_TYPE_BEARISH)
         return PATTERN_DIRECTION_BEARISH;
     }
//--- No patterns found - return -1
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| return the list of patterns managed by the object                |
//+------------------------------------------------------------------+
CArrayObj *CPatternControlOutsideBar::GetListPatterns(void)
  {
   CArrayObj *list=CSelect::ByPatternProperty(this.m_list_all_patterns,PATTERN_PROP_PERIOD,this.Timeframe(),EQUAL);
   list=CSelect::ByPatternProperty(list,PATTERN_PROP_SYMBOL,this.Symbol(),EQUAL);
   list=CSelect::ByPatternProperty(list,PATTERN_PROP_TYPE,PATTERN_TYPE_OUTSIDE_BAR,EQUAL);
   return CSelect::ByPatternProperty(list,PATTERN_PROP_CTRL_OBJ_ID,this.ObjectID(),EQUAL);
  }
//+------------------------------------------------------------------+
 #endif // CPATTERNCONTROLOUTSIDEBAR_MQH_IMPLEMENTATION
#endif // __PATTERNCONTROLOUTSIDEBAR_MQH__
