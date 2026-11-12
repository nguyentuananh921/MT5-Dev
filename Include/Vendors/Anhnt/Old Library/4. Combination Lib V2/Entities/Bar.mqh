//+------------------------------------------------------------------+
//|                                                          Bar.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Introduction link https://www.mql5.com/en/articles/7594           |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Bar class                                                        |
//+------------------------------------------------------------------+
#ifndef __BAR_MQH__
#define __BAR_MQH__
#ifndef CBAR_MQH_DECLARATION
#define CBAR_MQH_DECLARATION  
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include Custom files                                             |
 //+------------------------------------------------------------------+
 #include "Bases\BaseObj.mqh"
 #include "Defines\BarDefines.mqh"
 #include "Defines\PatternDefines.mqh"
 class CBar : public CBaseObj
  {
   private: //Private variables
      MqlDateTime       m_dt_struct;                                 // Date structure
      int               m_digits;                                    // Symbol's digits value
      long              m_long_prop[BAR_PROP_INTEGER_TOTAL];         // Integer properties
      double            m_double_prop[BAR_PROP_DOUBLE_TOTAL];        // Real properties
      string            m_string_prop[BAR_PROP_STRING_TOTAL];        // String properties
   //Private methods
    //--- Return the index of the array the bar's (1) double and (2) string properties are located at
      int               IndexProp(ENUM_BAR_PROP_DOUBLE property)     const { return(int)property-BAR_PROP_INTEGER_TOTAL;                        }
      int               IndexProp(ENUM_BAR_PROP_STRING property)     const { return(int)property-BAR_PROP_INTEGER_TOTAL-BAR_PROP_DOUBLE_TOTAL;  }

    //--- Return the bar type (bullish/bearish/zero)
      ENUM_BAR_BODY_TYPE BodyType(void)                              const;
    //--- Calculate and return the size of (1) candle, (2) candle body,
    //--- (3) upper, (4) lower candle wick,
    //--- (5) candle body top and (6) bottom
      double            CandleSize(void)                             const { return(this.High()-this.Low());                                    }
      double            BodySize(void)                               const { return(this.BodyHigh()-this.BodyLow());                            }
      double            ShadowUpSize(void)                           const { return(this.High()-this.BodyHigh());                               }
      double            ShadowDownSize(void)                         const { return(this.BodyLow()-this.Low());                                 }
      double            BodyHigh(void)                               const { return ::fmax(this.Close(),this.Open());                           }
      double            BodyLow(void)                                const { return ::fmin(this.Close(),this.Open());                           }
      
    //--- Calculate and return the percentage ratio of the (1) candle body, (2) upper and (3) lower shadow size to the full candle size
      double            CandleRatioBodyToCandleSize(void)            const { return(this.CandleSize()>0 ? this.BodySize()*100.0/this.CandleSize()      : 100.0);  }
      double            CandleRatioUpperShadowToCandleSize(void)     const { return(this.CandleSize()>0 ? this.ShadowUpSize()*100.0/this.CandleSize()  : 100.0);  }
      double            CandleRatioLowerShadowToCandleSize(void)     const { return(this.CandleSize()>0 ? this.ShadowDownSize()*100.0/this.CandleSize(): 100.0);  }
      
    //--- Return the (1) year and (2) month the bar belongs to, (3) week day,
    //--- (4) bar serial number in a year, (5) day, (6) hour, (7) minute,
      int               TimeYear(void)                               const { return this.m_dt_struct.year;                                      }
      int               TimeMonth(void)                              const { return this.m_dt_struct.mon;                                       }
      int               TimeDayOfWeek(void)                          const { return this.m_dt_struct.day_of_week;                               }
      int               TimeDayOfYear(void)                          const { return this.m_dt_struct.day_of_year;                               }
      int               TimeDay(void)                                const { return this.m_dt_struct.day;                                       }
      int               TimeHour(void)                               const { return this.m_dt_struct.hour;                                      }
      int               TimeMinute(void)                             const { return this.m_dt_struct.min;                                       }

   public: //Public methods
    //--- Set bar's (1) integer, (2) real and (3) string properties
      void              SetProperty(ENUM_BAR_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                              }
      void              SetProperty(ENUM_BAR_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;            }
      void              SetProperty(ENUM_BAR_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;            }
    //--- Return (1) integer, (2) real and (3) string bar properties from the properties array
      long              GetProperty(ENUM_BAR_PROP_INTEGER property)  const { return this.m_long_prop[property];                                 }
      double            GetProperty(ENUM_BAR_PROP_DOUBLE property)   const { return this.m_double_prop[this.IndexProp(property)];               }
      string            GetProperty(ENUM_BAR_PROP_STRING property)   const { return this.m_string_prop[this.IndexProp(property)];               }

    //--- Return the flag of the bar supporting the property
      virtual bool      SupportProperty(ENUM_BAR_PROP_INTEGER property)    { return true; }
      virtual bool      SupportProperty(ENUM_BAR_PROP_DOUBLE property)     { return true; }
      virtual bool      SupportProperty(ENUM_BAR_PROP_STRING property)     { return true; }
    //--- Return itself
      CBar             *GetObject(void)                                    { return &this;}
    //--- Set (1) bar symbol, timeframe and time, (2) bar object parameters
      void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime time);
      void              SetProperties(const MqlRates &rates);
    //--- Add the pattern type on bar
      void              AddPatternType(const ENUM_PATTERN_TYPE pattern_type){ this.m_long_prop[BAR_PROP_PATTERNS_TYPE] |=pattern_type;          }

    //--- Compare CBar objects by all possible properties (for sorting the lists by a specified bar object property)
      virtual int       Compare(const CObject *node,const int mode=0) const;
    //--- Compare CBar objects by all properties (to search for equal bar objects)
      bool              IsEqual(CBar* compared_bar) const;
    //--- Constructors
                        CBar(){ this.m_type=OBJECT_DE_TYPE_SERIES_BAR; }
                        CBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const MqlRates &rates,const int digits);
                        
    //+------------------------------------------------------------------+ 
    //| Methods of simplified access to bar object properties            |
    //+------------------------------------------------------------------+
    //--- Return the (1) type, (2) period, (3) spread, (4) tick, (5) exchange volume,
    //--- (6) bar period start time, (7) year, (8) month the bar belongs to
    //--- (9) week number since the year start, (10) week number since the month start
    //--- (11) day, (12) hour, (13) minute
      ENUM_BAR_BODY_TYPE   TypeBody(void)         const { return (ENUM_BAR_BODY_TYPE)this.GetProperty(BAR_PROP_TYPE);  }
      ENUM_TIMEFRAMES      Timeframe(void)        const { return (ENUM_TIMEFRAMES)this.GetProperty(BAR_PROP_PERIOD);   }
      int                  Spread(void)           const { return (int)this.GetProperty(BAR_PROP_SPREAD);               }
      long                 VolumeTick(void)       const { return this.GetProperty(BAR_PROP_VOLUME_TICK);               }
      long                 VolumeReal(void)       const { return this.GetProperty(BAR_PROP_VOLUME_REAL);               }
      datetime             Time(void)             const { return (datetime)this.GetProperty(BAR_PROP_TIME);            }
      long                 Year(void)             const { return this.GetProperty(BAR_PROP_TIME_YEAR);                 }
      long                 Month(void)            const { return this.GetProperty(BAR_PROP_TIME_MONTH);                }
      long                 DayOfWeek(void)        const { return this.GetProperty(BAR_PROP_TIME_DAY_OF_WEEK);          }
      long                 DayOfYear(void)        const { return this.GetProperty(BAR_PROP_TIME_DAY_OF_YEAR);          }
      long                 Day(void)              const { return this.GetProperty(BAR_PROP_TIME_DAY);                  }
      long                 Hour(void)             const { return this.GetProperty(BAR_PROP_TIME_HOUR);                 }
      long                 Minute(void)           const { return this.GetProperty(BAR_PROP_TIME_MINUTE);               }

    //--- Return bar's (1) Open, (2) High, (3) Low, (4) Close price,
    //--- size of the (5) candle, (6) body, (7) candle top, (8) bottom,
    //--- size of the (9) candle upper, (10) lower wick
      double            Open(void)                                         const { return this.GetProperty(BAR_PROP_OPEN);                      }
      double            High(void)                                         const { return this.GetProperty(BAR_PROP_HIGH);                      }
      double            Low(void)                                          const { return this.GetProperty(BAR_PROP_LOW);                       }
      double            Close(void)                                        const { return this.GetProperty(BAR_PROP_CLOSE);                     }
      double            Size(void)                                         const { return this.GetProperty(BAR_PROP_CANDLE_SIZE);               }
      double            SizeBody(void)                                     const { return this.GetProperty(BAR_PROP_CANDLE_SIZE_BODY);          }
      double            TopBody(void)                                      const { return this.GetProperty(BAR_PROP_CANDLE_BODY_TOP);           }
      double            BottomBody(void)                                   const { return this.GetProperty(BAR_PROP_CANDLE_BODY_BOTTOM);        }
      double            SizeShadowUp(void)                                 const { return this.GetProperty(BAR_PROP_CANDLE_SIZE_SHADOW_UP);     }
      double            SizeShadowDown(void)                               const { return this.GetProperty(BAR_PROP_CANDLE_SIZE_SHADOW_DOWN);   }
      
    //--- Return the properties of the percentage ratio of the (1) candle body, (2) upper and (3) lower shadow size to the candle full size
      double            RatioBodyToCandleSize(void)                  const { return this.GetProperty(BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE);        }
      double            RatioUpperShadowToCandleSize(void)           const { return this.GetProperty(BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE);}
      double            RatioLowerShadowToCandleSize(void)           const { return this.GetProperty(BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE);}
      
    //--- Return bar symbol and symbol digits
      string            Symbol(void)                                       const { return this.GetProperty(BAR_PROP_SYMBOL);                    }
      int               Digits(void)                                       const { return this.m_digits;                                        }
    //--- Return the list of patterns on the bar in the passed array
      int               GetPatternsList(ulong &array[]);
  };
#endif // CBAR_MQH_DECLARATION
#ifndef CBAR_MQH_IMPLEMENTATION
#define CBAR_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CBar::CBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const MqlRates &rates,const int digits)
  {
   this.m_type=OBJECT_DE_TYPE_SERIES_BAR;
   this.m_digits=digits;
   this.SetSymbolPeriod(symbol,timeframe,rates.time);
    if(!::TimeToStruct(rates.time,this.m_dt_struct))
     {
      this.m_global_error=ERR_INVALID_DATETIME;
      MqlRates err={0};
      err.time=rates.time;
      this.SetProperties(err);
      return;
     }
   this.SetProperties(rates);
  }
 //+------------------------------------------------------------------+
 //| Compare CBar objects with each other by the specified property   |
 //+------------------------------------------------------------------+
 int CBar::Compare(const CObject *node,const int mode=0) const
  {
   const CBar *bar_compared=node;
   //--- compare integer properties of two bars
    if(mode<BAR_PROP_INTEGER_TOTAL)
     {
      long value_compared=bar_compared.GetProperty((ENUM_BAR_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_BAR_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   //--- compare real properties of two bars
    else if(mode<BAR_PROP_DOUBLE_TOTAL+BAR_PROP_INTEGER_TOTAL)
     {
      double value_compared=bar_compared.GetProperty((ENUM_BAR_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_BAR_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   //--- compare string properties of two bars
    else if(mode<BAR_PROP_DOUBLE_TOTAL+BAR_PROP_INTEGER_TOTAL+BAR_PROP_STRING_TOTAL)
     {
      string value_compared=bar_compared.GetProperty((ENUM_BAR_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_BAR_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
 //+------------------------------------------------------------------+
 //| Compare CBar objects by all properties                           |
 //+------------------------------------------------------------------+
 bool CBar::IsEqual(CBar *compared_bar) const
  {
   int begin=0, end=BAR_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_BAR_PROP_INTEGER prop=(ENUM_BAR_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_bar.GetProperty(prop)) return false; 
     }
   begin=end; end+=BAR_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_BAR_PROP_DOUBLE prop=(ENUM_BAR_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_bar.GetProperty(prop)) return false; 
     }
   begin=end; end+=BAR_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_BAR_PROP_STRING prop=(ENUM_BAR_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_bar.GetProperty(prop)) return false; 
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set bar symbol, timeframe and time                               |
 //+------------------------------------------------------------------+
 void CBar::SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime time)
  {
   this.SetProperty(BAR_PROP_TIME,time);
   this.SetProperty(BAR_PROP_SYMBOL,symbol);
   this.SetProperty(BAR_PROP_PERIOD,timeframe);
  }
 //+------------------------------------------------------------------+
 //| Set bar object parameters                                        |
 //+------------------------------------------------------------------+
 void CBar::SetProperties(const MqlRates &rates)
  {
    this.SetProperty(BAR_PROP_SPREAD,rates.spread);
    this.SetProperty(BAR_PROP_VOLUME_TICK,rates.tick_volume);
    this.SetProperty(BAR_PROP_VOLUME_REAL,rates.real_volume);
    this.SetProperty(BAR_PROP_TIME,rates.time);
    this.SetProperty(BAR_PROP_TIME_YEAR,this.TimeYear());
    this.SetProperty(BAR_PROP_TIME_MONTH,this.TimeMonth());
    this.SetProperty(BAR_PROP_TIME_DAY_OF_YEAR,this.TimeDayOfYear());
    this.SetProperty(BAR_PROP_TIME_DAY_OF_WEEK,this.TimeDayOfWeek());
    this.SetProperty(BAR_PROP_TIME_DAY,this.TimeDay());
    this.SetProperty(BAR_PROP_TIME_HOUR,this.TimeHour());
    this.SetProperty(BAR_PROP_TIME_MINUTE,this.TimeMinute());
   //---
    this.SetProperty(BAR_PROP_OPEN,rates.open);
    this.SetProperty(BAR_PROP_HIGH,rates.high);
    this.SetProperty(BAR_PROP_LOW,rates.low);
    this.SetProperty(BAR_PROP_CLOSE,rates.close);
    this.SetProperty(BAR_PROP_CANDLE_SIZE,this.CandleSize());
    this.SetProperty(BAR_PROP_CANDLE_SIZE_BODY,this.BodySize());
    this.SetProperty(BAR_PROP_CANDLE_BODY_TOP,this.BodyHigh());
    this.SetProperty(BAR_PROP_CANDLE_BODY_BOTTOM,this.BodyLow());
    this.SetProperty(BAR_PROP_CANDLE_SIZE_SHADOW_UP,this.ShadowUpSize());
    this.SetProperty(BAR_PROP_CANDLE_SIZE_SHADOW_DOWN,this.ShadowDownSize());
   //---
    this.SetProperty(BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,this.CandleRatioBodyToCandleSize());
    this.SetProperty(BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,this.CandleRatioUpperShadowToCandleSize());
    this.SetProperty(BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,this.CandleRatioLowerShadowToCandleSize());
    this.SetProperty(BAR_PROP_PATTERNS_TYPE,0);
    this.SetProperty(BAR_PROP_TYPE,this.BodyType());
   //--- Set the object type to the object of the graphical object management class
   //See https://www.mql5.com/en/articles/9751
   //this.m_graph_elm.SetTypeNode(this.m_type);  
  }
//+------------------------------------------------------------------+
//| Return the list of patterns in the passed array                  |
//+------------------------------------------------------------------+
int CBar::GetPatternsList(ulong &array[])
  {
   return ListPatternsInVar(this.GetProperty(BAR_PROP_PATTERNS_TYPE),array);
  }
//+------------------------------------------------------------------+
//| Return the bar type (bullish/bearish/zero)                       |
//+------------------------------------------------------------------+
ENUM_BAR_BODY_TYPE CBar::BodyType(void) const
  {
   return
     (
      this.Close()>this.Open() ? BAR_BODY_TYPE_BULLISH : 
      this.Close()<this.Open() ? BAR_BODY_TYPE_BEARISH : 
      (this.ShadowUpSize()+this.ShadowDownSize()==0 ? BAR_BODY_TYPE_NULL : BAR_BODY_TYPE_CANDLE_ZERO_BODY)
     );
  }
//+------------------------------------------------------------------+
#endif // CBAR_MQH_IMPLEMENTATION
#endif // __BAR_MQH__
