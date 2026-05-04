#ifndef __PATTERNCONTROL_MQH__
#define __PATTERNCONTROL_MQH__
//+------------------------------------------------------------------+
//|                                              PatternControl.mqh |
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
#include "..\Patterns\Pattern.mqh"
//#include "..\..\Services\Select.mqh"
#include "..\Bars\Bar.mqh"

 #ifndef CPATTERNCONTROL_MQH_DECLARATION
 #define CPATTERNCONTROL_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Abstract pattern management class                                |
//+------------------------------------------------------------------+
 class CPatternControl : public CBaseObjExt
  {
   private:
    ENUM_TIMEFRAMES   m_timeframe;                                                // Pattern timeseries chart period
    string            m_symbol;                                                   // pattern timeseries symbol
    double            m_point;                                                    // Symbol Point
    bool              m_used;                                                     // Pattern use flag
    bool              m_drawing;                                                  // Flag for drawing the pattern icon on the chart
    //--- Handled pattern
    ENUM_PATTERN_TYPE m_type_pattern;                                             // Pattern type
   protected:
    //--- Candle proportions
    double            m_ratio_body_to_candle_size;                                // Percentage ratio of the candle body to the full size of the candle
    double            m_ratio_larger_shadow_to_candle_size;                       // Percentage ratio of the size of the larger shadow to the size of the candle
    double            m_ratio_smaller_shadow_to_candle_size;                      // Percentage ratio of the size of the smaller shadow to the size of the candle
    double            m_ratio_candle_sizes;                                       // Percentage of candle sizes
    uint              m_min_body_size;                                            // The minimum size of the candlestick body
    ulong             m_object_id;                                                // Unique object code based on pattern search criteria
    //--- List views
    CArrayObj        *m_list_series;                                              // Pointer to the timeseries list
    CArrayObj        *m_list_all_patterns;                                        // Pointer to the list of all patterns
    CPattern          m_pattern_instance;                                         // Pattern object for searching by property
    //--- Graph
    ulong             m_symbol_code;                                              // Chart symbol name as a number
    int               m_chart_scale;                                              // Chart scale
    int               m_chart_height_px;                                          // Height of the chart in pixels
    int               m_chart_width_px;                                           // Height of the chart in pixels
    double            m_chart_price_max;                                          // Chart maximum
    double            m_chart_price_min;                                          // Chart minimum

    //--- (1) Search for a pattern, return direction (or -1 if no pattern is found),
    //--- (2) create a pattern with a specified direction,
    //--- (3) create and return a unique pattern code,
    //--- (4) return the list of patterns managed by the object
    virtual ENUM_PATTERN_DIRECTION FindPattern(const datetime series_bar_time,MqlRates &mother_bar_data) const { return WRONG_VALUE;    }
    virtual CPattern *CreatePattern(const ENUM_PATTERN_DIRECTION direction,const uint id,CBar *bar){ return NULL;                       }
    virtual ulong     GetPatternCode(const ENUM_PATTERN_DIRECTION direction,const datetime time) const { return 0;                      }
    virtual CArrayObj*GetListPatterns(void)                                       { return NULL;                                        }

    //--- Create object ID based on pattern search criteria
    virtual ulong     CreateObjectID(void)                                        { return 0;                                           }

    //--- Write bar data to the structure
    void              SetBarData(CBar *bar,MqlRates &rates) const
                       {
                        if(bar==NULL)
                           return;
                        rates.open=bar.Open();
                        rates.high=bar.High();
                        rates.low=bar.Low();
                        rates.close=bar.Close();
                        rates.time=bar.Time();
                       }

                     CPatternControl(const string symbol,const ENUM_TIMEFRAMES timeframe,const ENUM_PATTERN_STATUS status,const ENUM_PATTERN_TYPE type,CArrayObj *list_series,CArrayObj *list_patterns,const MqlParam &param[]);

   public:
    MqlParam          PatternParams[];                                            // Array of pattern parameters
    //--- Return itself
    CPatternControl  *GetObject(void)                                             { return &this;                                       }
    //--- (1) Set and (2) return the pattern usage flag
    void              SetUsed(const bool flag)                                    { this.m_used=flag;                                   }
    bool              IsUsed(void)                                          const { return this.m_used;                                 }
    //--- (1) Set and (2) return the pattern drawing flag
    void              SetDrawing(const bool flag)                                 { this.m_drawing=flag;                                }
    bool              IsDrawing(void)                                       const { return this.m_drawing;                              }

    //--- Set the necessary percentage ratio of the candle body to the full size of the candle,
    //--- size of the (2) upper and (3) lower shadow to the candle size, (4) sizes of candles, (5) minimum size of the candle body
    void              SetRatioBodyToCandleSizeValue(const double value)           { this.m_ratio_body_to_candle_size=value;             }
    void              SetRatioLargerShadowToCandleSizeValue(const double value)   { this.m_ratio_larger_shadow_to_candle_size=value;    }
    void              SetRatioSmallerShadowToCandleSizeValue(const double value)  { this.m_ratio_smaller_shadow_to_candle_size=value;   }
    void              SetRatioCandleSizeValue(const double value)                 { this.m_ratio_candle_sizes=value;                    }
    void              SetMinBodySize(const uint value)                            { this.m_min_body_size=value;                         }
    //--- Return the necessary percentage ratio of the candle body to the full size of the candle,
    //--- size of the (2) upper and (3) lower shadow to the candle size, (4) sizes of candles, (5) minimum size of the candle body
    double            RatioBodyToCandleSizeValue(void)                      const { return this.m_ratio_body_to_candle_size;            }
    double            RatioLargerShadowToCandleSizeValue(void)              const { return this.m_ratio_larger_shadow_to_candle_size;   }
    double            RatioSmallerShadowToCandleSizeValue(void)             const { return this.m_ratio_smaller_shadow_to_candle_size;  }
    double            RatioCandleSizeValue(void)                            const { return this.m_ratio_candle_sizes;                   }
    int               MinBodySize(void)                                     const { return (int)this.m_min_body_size;                   }

    //--- Return object ID based on pattern search criteria
    virtual ulong     ObjectID(void)                                        const { return this.m_object_id;                            }

    //--- Return pattern (1) type, (2) timeframe, (3) symbol, (4) symbol Point, (5) symbol code
    ENUM_PATTERN_TYPE TypePattern(void)                                     const { return this.m_type_pattern;                         }
    ENUM_TIMEFRAMES   Timeframe(void)                                       const { return this.m_timeframe;                            }
    string            Symbol(void)                                          const { return this.m_symbol;                               }
    double            Point(void)                                           const { return this.m_point;                                }
    ulong             SymbolCode(void)                                      const { return this.m_symbol_code;                          }

    //--- Set the (1) chart scale, (2) height, (3) width in pixels, (4) high, (5) low
    void              SetChartScale(const int scale)                              { this.m_chart_scale=scale;                           }
    void              SetChartHeightInPixels(const int height)                    { this.m_chart_height_px=height;                      }
    void              SetChartWidthInPixels(const int width)                      { this.m_chart_width_px=width;                        }
    void              SetChartPriceMax(const double price)                        { this.m_chart_price_max=price;                       }
    void              SetChartPriceMin(const double price)                        { this.m_chart_price_min=price;                       }
    //--- Return the (1) chart scale, (2) height, (3) width in pixels, (4) high, (5) low
    int               ChartScale(void)                                      const { return this.m_chart_scale;                          }
    int               ChartHeightInPixels(void)                             const { return this.m_chart_height_px;                      }
    int               ChartWidthInPixels(void)                              const { return this.m_chart_width_px;                       }
    double            ChartPriceMax(void)                                   const { return this.m_chart_price_max;                      }
    double            ChartPriceMin(void)                                   const { return this.m_chart_price_min;                      }

    //--- Compare CPatternControl objects by all possible properties
    virtual int       Compare(const CObject *node,const int mode=0) const;

    //--- Search for patterns and add found ones to the list of all patterns
    virtual int       CreateAndRefreshPatternList(void);
    //--- Display patterns on the chart
    void              DrawPatterns(const bool redraw=false);
    //--- Redraw patterns on the chart with a new size
    void              RedrawPatterns(const bool redraw=false);

    //--- Protected parametric constructor
  };
//+------------------------------------------------------------------+
//| CPatternControl::Protected parametric constructor                |
//+------------------------------------------------------------------+
CPatternControl::CPatternControl(const string symbol,const ENUM_TIMEFRAMES timeframe,const ENUM_PATTERN_STATUS status,const ENUM_PATTERN_TYPE type,CArrayObj *list_series,CArrayObj *list_patterns,const MqlParam &param[]) :
  m_used(true),m_drawing(true)
  {
   this.m_type=OBJECT_DE_TYPE_SERIES_PATTERN_CONTROL;
   this.m_type_pattern=type;
   this.m_symbol=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
   this.m_timeframe=(timeframe==PERIOD_CURRENT ? ::Period() : timeframe);
   this.m_point=::SymbolInfoDouble(this.m_symbol,SYMBOL_POINT);
   this.m_object_id=0;
   this.m_list_series=list_series;
   this.m_list_all_patterns=list_patterns;
   for(int i=0;i<(int)this.m_symbol.Length();i++)
      this.m_symbol_code+=this.m_symbol.GetChar(i);
   this.m_chart_scale=(int)::ChartGetInteger(this.m_chart_id,CHART_SCALE);
   this.m_chart_height_px=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS);
   this.m_chart_width_px=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
   this.m_chart_price_max=::ChartGetDouble(this.m_chart_id,CHART_PRICE_MAX);
   this.m_chart_price_min=::ChartGetDouble(this.m_chart_id,CHART_PRICE_MIN);

//--- fill in the array of parameters with data from the array passed to constructor
   int count=::ArrayResize(this.PatternParams,::ArraySize(param));
   for(int i=0;i<count;i++)
     {
      this.PatternParams[i].type         = param[i].type;
      this.PatternParams[i].double_value = param[i].double_value;
      this.PatternParams[i].integer_value= param[i].integer_value;
      this.PatternParams[i].string_value = param[i].string_value;
     }
  }
 #endif // CPATTERNCONTROL_MQH_DECLARATION

 #ifndef CPATTERNCONTROL_MQH_IMPLEMENTATION
 #define CPATTERNCONTROL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Compare CPatternControl objects                                  |
//+------------------------------------------------------------------+
int CPatternControl::Compare(const CObject *node,const int mode=0) const
  {
   const CPatternControl *obj_compared=node;
   return
     (
      this.SymbolCode()    >  obj_compared.SymbolCode()  ||
      this.Timeframe()     >  obj_compared.Timeframe()   || 
      this.TypePattern()   >  obj_compared.TypePattern() || 
      this.ObjectID()      >  obj_compared.ObjectID()     ?  1 :
      
      this.SymbolCode()    <  obj_compared.SymbolCode()  ||
      this.Timeframe()     <  obj_compared.Timeframe()   || 
      this.TypePattern()   <  obj_compared.TypePattern() || 
      this.ObjectID()      <  obj_compared.ObjectID()     ? -1 :
      0
     );
  }
//+------------------------------------------------------------------+
//| CPatternControl::Search for patterns and add                     |
//| found ones to the list of all patterns                           |
//+------------------------------------------------------------------+
int CPatternControl::CreateAndRefreshPatternList(void)
  {
//--- If not used, leave
   if(!this.m_used)
      return 0;
//--- Reset the timeseries event flag and clear the list of all timeseries pattern events
   this.m_is_event=false;
   this.m_list_events.Clear();
//--- Get the opening date of the last (current) bar
   datetime time_open=0;
   if(!::SeriesInfoInteger(this.Symbol(),this.Timeframe(),SERIES_LASTBAR_DATE,time_open))
      return 0;
      
//--- Get a list of all bars in the timeseries except the current one
   CArrayObj *list=CSelect::ByBarProperty(this.m_list_series,BAR_PROP_TIME,time_open,LESS);
   if(list==NULL || list.Total()==0)
      return 0;
//--- "Mother" bar data structure
   MqlRates pattern_mother_bar_data={};
//--- Sort the resulting list by bar opening time
   list.Sort(SORT_BY_BAR_TIME);
//--- In a loop from the latest bar,
   for(int i=list.Total()-1;i>=0;i--)
     {
      //--- get the next bar object from the list
      CBar *bar=list.At(i);
      if(bar==NULL)
         continue;
      //--- look for a pattern relative to the received bar
      ENUM_PATTERN_DIRECTION direction=this.FindPattern(bar.Time(),pattern_mother_bar_data);
      //--- If there is no pattern, go to the next bar
      if(direction==WRONG_VALUE)
         continue;
         
      //--- Pattern found on the current bar of the loop
      //--- unique pattern code = candle opening time + type + status + pattern direction + timeframe + timeseries symbol
      ulong code=this.GetPatternCode(direction,bar.Time());
      //--- Set the pattern code to the sample
      this.m_pattern_instance.SetProperty(PATTERN_PROP_CODE,code);
      //--- Sort the list of all patterns by the unique pattern code
      this.m_list_all_patterns.Sort(SORT_BY_PATTERN_CODE);
      //--- search for a pattern in the list using a unique code
      int index=this.m_list_all_patterns.Search(&this.m_pattern_instance);
      //--- If there is no pattern equal to the sample in the list of all patterns
      if(index==WRONG_VALUE)
        {
         //--- Create the pattern object
         CPattern *pattern=this.CreatePattern(direction,this.m_list_all_patterns.Total(),bar);
         if(pattern==NULL)
            continue;
         //--- Sort the list of all patterns by time and insert the pattern into the list by its time
         this.m_list_all_patterns.Sort(SORT_BY_PATTERN_TIME);
         if(!this.m_list_all_patterns.InsertSort(pattern))
           {
            delete pattern;
            continue;
           }
         //--- Add the pattern type to the list of pattern types of the bar object
         bar.AddPatternType(pattern.TypePattern());
         //--- Add the pointer to the bar the pattern object is found on, together with the mother bar data
         pattern.SetPatternBar(bar);
         pattern.SetMotherBarData(pattern_mother_bar_data);
         
         //--- set the chart data to the pattern object
         pattern.SetChartHeightInPixels(this.m_chart_height_px);
         pattern.SetChartWidthInPixels(this.m_chart_width_px);
         pattern.SetChartScale(this.m_chart_scale);
         pattern.SetChartPriceMax(this.m_chart_price_max);
         pattern.SetChartPriceMin(this.m_chart_price_min);
         //--- If the drawing flag is set, draw the pattern label on the chart
         if(this.m_drawing)
            pattern.Draw(false);
         //--- Get the time of the penultimate bar in the collection list (timeseries bar with index 1)
         datetime time_prev=time_open-::PeriodSeconds(this.Timeframe());
         //--- If the current bar in the loop is the bar with index 1 in the timeseries, create and send a message
         if(bar.Time()==time_prev)
           {
            // Here is where the message is created and sent
           }
        }
     }
//--- Sort the list of all patterns by time and return the total number of patterns in the list
   this.m_list_all_patterns.Sort(SORT_BY_PATTERN_TIME);
   return m_list_all_patterns.Total();
  }
//+------------------------------------------------------------------+
//| Display pattern labels on the chart                              |
//+------------------------------------------------------------------+
void CPatternControl::DrawPatterns(const bool redraw=false)
  {
//--- Get a list of patterns controlled by the control object
   CArrayObj *list=this.GetListPatterns();
   if(list==NULL || list.Total()==0)
      return;
//--- Sort the obtained list by pattern time
   list.Sort(SORT_BY_PATTERN_TIME);
//--- In a loop from the latest pattern,
   for(int i=list.Total()-1;i>=0;i--)
     {
      //--- get the next pattern object
      CPattern *obj=list.At(i);
      if(obj==NULL)
         continue;
      //--- Display the pattern label on the chart
      obj.Draw(false);
     }
//--- At the end of the cycle, redraw the chart if the flag is set
   if(redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+-------------------------------------------------------------------+
//|Redraw patterns on a chart with a new size of the bitmap object    |
//+-------------------------------------------------------------------+
void CPatternControl::RedrawPatterns(const bool redraw=false)
  {
//--- Get a list of patterns controlled by the control object
   CArrayObj *list=this.GetListPatterns();
   if(list==NULL || list.Total()==0)
      return;
//--- Sort the obtained list by pattern time
   list.Sort(SORT_BY_PATTERN_TIME);
//--- In a loop from the latest pattern,
   for(int i=list.Total()-1;i>=0;i--)
     {
      //--- get the next pattern object
      CPattern *obj=list.At(i);
      if(obj==NULL)
         continue;
      //--- Redraw the pattern bitmap object on the chart
      obj.Redraw(false);
     }
//--- At the end of the cycle, redraw the chart if the flag is set
   if(redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
 #endif // CPATTERNCONTROL_MQH_IMPLEMENTATION
#endif // __PATTERNCONTROL_MQH__
