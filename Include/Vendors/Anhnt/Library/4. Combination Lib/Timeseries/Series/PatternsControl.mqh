#ifndef __PATTERNSCONTROL_MQH__
#define __PATTERNSCONTROL_MQH__
//+------------------------------------------------------------------+
//|                                              PatternsControl.mqh |
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
#include "PatternControlPinBar.mqh"
#include "PatternControlInsideBar.mqh"
#include "PatternControlOutsideBar.mqh"

 #ifndef CPATTERNSCONTROL_MQH_DECLARATION
 #define CPATTERNSCONTROL_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Pattern management class                                         |
//+------------------------------------------------------------------+
 class CPatternsControl : public CBaseObjExt
  {
   private:
    CArrayObj         m_list_controls;                                   // List of pattern management controllers
    CArrayObj        *m_list_series;                                     // Pointer to the timeseries list
    CArrayObj        *m_list_all_patterns;                               // Pointer to the list of all patterns
    //--- Timeseries data
    ENUM_TIMEFRAMES   m_timeframe;                                       // Timeseries timeframe
    string            m_symbol;                                          // Timeseries symbol

   protected:
    //--- Create an object for managing a specified pattern
    CPatternControl  *CreateObjControlPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[])
                       {
                        switch(pattern)
                          {
                           case PATTERN_TYPE_HARAMI               :  return NULL;
                           case PATTERN_TYPE_HARAMI_CROSS         :  return NULL;
                           case PATTERN_TYPE_TWEEZER              :  return NULL;
                           case PATTERN_TYPE_PIERCING_LINE        :  return NULL;
                           case PATTERN_TYPE_DARK_CLOUD_COVER     :  return NULL;
                           case PATTERN_TYPE_THREE_WHITE_SOLDIERS :  return NULL;
                           case PATTERN_TYPE_THREE_BLACK_CROWS    :  return NULL;
                           case PATTERN_TYPE_SHOOTING_STAR        :  return NULL;
                           case PATTERN_TYPE_HAMMER               :  return NULL;
                           case PATTERN_TYPE_INVERTED_HAMMER      :  return NULL;
                           case PATTERN_TYPE_HANGING_MAN          :  return NULL;
                           case PATTERN_TYPE_DOJI                 :  return NULL;
                           case PATTERN_TYPE_DRAGONFLY_DOJI       :  return NULL;
                           case PATTERN_TYPE_GRAVESTONE_DOJI      :  return NULL;
                           case PATTERN_TYPE_MORNING_STAR         :  return NULL;
                           case PATTERN_TYPE_MORNING_DOJI_STAR    :  return NULL;
                           case PATTERN_TYPE_EVENING_STAR         :  return NULL;
                           case PATTERN_TYPE_EVENING_DOJI_STAR    :  return NULL;
                           case PATTERN_TYPE_THREE_STARS          :  return NULL;
                           case PATTERN_TYPE_ABANDONED_BABY       :  return NULL;
                           case PATTERN_TYPE_PIVOT_POINT_REVERSAL :  return NULL;
                           case PATTERN_TYPE_OUTSIDE_BAR          :  return new CPatternControlOutsideBar(this.m_symbol,this.m_timeframe,this.m_list_series,this.m_list_all_patterns,param);
                           case PATTERN_TYPE_INSIDE_BAR           :  return new CPatternControlInsideBar(this.m_symbol,this.m_timeframe,this.m_list_series,this.m_list_all_patterns,param);
                           case PATTERN_TYPE_PIN_BAR              :  return new CPatternControlPinBar(this.m_symbol,this.m_timeframe,this.m_list_series,this.m_list_all_patterns,param);
                           case PATTERN_TYPE_RAILS                :  return NULL;
                           //---PATTERN_TYPE_NONE
                           default                                :  return NULL;
                          }
                       }
    //--- Return an object for managing a specified pattern
    CPatternControl  *GetObjControlPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[])
                       {
                        //--- In a loop through the list of control objects,
                        int total=this.m_list_controls.Total();
                        for(int i=0;i<total;i++)
                          {
                           //--- get the next object and
                           CPatternControl *obj=this.m_list_controls.At(i);
                           //--- if this is not a pattern control object, go to the next one
                           if(obj==NULL || obj.TypePattern()!=pattern)
                              continue;
                           //--- Check search conditions and return the result
                           if(IsEqualMqlParamArrays(obj.PatternParams,param))
                              return obj;
                          }
                        //--- Not found - return NULL
                        return NULL;
                       }

   public:
    //--- Return (1) timeframe, (2) timeseries symbol, (3) itself
    ENUM_TIMEFRAMES   Timeframe(void)                                       const { return this.m_timeframe; }
    string            Symbol(void)                                          const { return this.m_symbol;    }
    CPatternsControl *GetObject(void)                                             { return &this;            }

    //--- Search and update all active patterns
    void              RefreshAll(void)
                       {
                        //--- In a loop through the list of pattern control objects,
                        int total=this.m_list_controls.Total();
                        for(int i=0;i<total;i++)
                          {
                           //--- get the next control object
                           CPatternControl *obj=this.m_list_controls.At(i);
                           if(obj==NULL)
                              continue;

                           //--- if this is a tester and the current chart sizes are not set, or are not equal to the current ones - we try to get and set them
                           if(::MQLInfoInteger(MQL_TESTER))
                             {
                              long   int_value=0;
                              double dbl_value=0;
                              if(::ChartGetInteger(this.m_chart_id, CHART_SCALE, 0, int_value))
                                {
                                 if(obj.ChartScale()!=int_value)
                                    obj.SetChartScale((int)int_value);
                                }
                              if(::ChartGetInteger(this.m_chart_id, CHART_HEIGHT_IN_PIXELS, 0, int_value))
                                {
                                 if(obj.ChartHeightInPixels()!=int_value)
                                    obj.SetChartHeightInPixels((int)int_value);
                                }
                              if(::ChartGetInteger(this.m_chart_id, CHART_WIDTH_IN_PIXELS, 0, int_value))
                                {
                                 if(obj.ChartWidthInPixels()!=int_value)
                                    obj.SetChartWidthInPixels((int)int_value);
                                }
                              if(::ChartGetDouble(this.m_chart_id, CHART_PRICE_MAX, 0, dbl_value))
                                {
                                 if(obj.ChartPriceMax()!=dbl_value)
                                    obj.SetChartPriceMax(dbl_value);
                                }
                              if(::ChartGetDouble(this.m_chart_id, CHART_PRICE_MIN, 0, dbl_value))
                                {
                                 if(obj.ChartPriceMin()!=dbl_value)
                                    obj.SetChartPriceMin(dbl_value);
                                }
                             }

                           //--- search and create a new pattern
                           obj.CreateAndRefreshPatternList();
                          }
                       }

    //--- Set chart parameters for all pattern management objects
    void              SetChartPropertiesToPattCtrl(const double price_max,const double price_min,const int scale,const int height_px,const int width_px)
                       {
                        //--- In a loop through the list of pattern control objects,
                        int total=this.m_list_controls.Total();
                        for(int i=0;i<total;i++)
                          {
                           //--- get the next control object
                           CPatternControl *obj=this.m_list_controls.At(i);
                           if(obj==NULL)
                              continue;
                           //--- If the object is received, set the chart parameters
                           obj.SetChartHeightInPixels(height_px);
                           obj.SetChartWidthInPixels(width_px);
                           obj.SetChartScale(scale);
                           obj.SetChartPriceMax(price_max);
                           obj.SetChartPriceMin(price_min);
                          }
                       }

    //--- Set the flag for using the specified pattern and create a control object if it does not already exist
    void              SetUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const bool flag)
                       {
                        CPatternControl *obj=NULL;
                        //--- Get the pointer to the object for managing the specified pattern
                        obj=this.GetObjControlPattern(pattern,param);
                        //--- If the pointer is received (the object exists), set the use flag
                        if(obj!=NULL)
                           obj.SetUsed(flag);
                        //--- If there is no object and the flag is passed as 'true'
                        else if(flag)
                          {
                           //--- Create a new pattern management object
                           obj=this.CreateObjControlPattern(pattern,param);
                           if(obj==NULL)
                              return;
                           //--- Add pointer to the created object to the list
                           if(!this.m_list_controls.Add(obj))
                             {
                              delete obj;
                              return;
                             }
                           //--- Set the usage flag and pattern parameters to the control object
                           obj.SetUsed(flag);
                           obj.CreateAndRefreshPatternList();
                          }
                       }
    //--- Return the flag of using the specified pattern
    bool              IsUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[])
                       {
                        CPatternControl *obj=this.GetObjControlPattern(pattern,param);
                        return(obj!=NULL ? obj.IsUsed() : false);
                       }

    //--- Places marks of the specified pattern on the chart
    void              DrawPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const bool redraw=false)
                       {
                        CPatternControl *obj=GetObjControlPattern(pattern,param);
                        if(obj!=NULL)
                           obj.DrawPatterns(redraw);
                       }
    //--- Redraw the bitmap objects of the specified pattern on the chart
    void              RedrawPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const bool redraw=false)
                       {
                        CPatternControl *obj=GetObjControlPattern(pattern,param);
                        if(obj!=NULL)
                           obj.RedrawPatterns(redraw);
                       }
    //--- Constructor
                     CPatternsControl(const string symbol,const ENUM_TIMEFRAMES timeframe,CArrayObj *list_timeseries,CArrayObj *list_all_patterns);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPatternsControl::CPatternsControl(const string symbol,const ENUM_TIMEFRAMES timeframe,CArrayObj *list_timeseries,CArrayObj *list_all_patterns)
  {
   this.m_type=OBJECT_DE_TYPE_SERIES_PATTERNS_CONTROLLERS;
   this.m_symbol=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
   this.m_timeframe=(timeframe==PERIOD_CURRENT ? ::Period() : timeframe);
   this.m_list_series=list_timeseries;
   this.m_list_all_patterns=list_all_patterns;
  }
//+------------------------------------------------------------------+
 #endif // CPATTERNSCONTROL_MQH_DECLARATION

 #ifndef CPATTERNSCONTROL_MQH_IMPLEMENTATION
 #define CPATTERNSCONTROL_MQH_IMPLEMENTATION

 #endif // CPATTERNSCONTROL_MQH_IMPLEMENTATION
#endif // __PATTERNSCONTROL_MQH__
