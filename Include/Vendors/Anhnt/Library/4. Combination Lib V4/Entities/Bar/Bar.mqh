//+------------------------------------------------------------------+
//|                                                          Bar.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Introduction link https://www.mql5.com/en/articles/7594           |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- A bar of a timeseries: what the terminal says about it. No pattern flags: Python finds the patterns and the database holds them
#ifndef __BAR_MQH__
#define __BAR_MQH__
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\BarDefines.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include <Arrays\ArrayObj.mqh>
#ifndef CBAR_MQH_DECLARATION
#define CBAR_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Bar class                                                        |
 //+------------------------------------------------------------------+
 class CBar : public CBaseObj
  {
   private:
    MqlDateTime       m_dt_struct;                                 // Date structure
    int               m_digits;                                    // Symbol's digits value
    long              m_long_prop[BAR_PROP_INTEGER_TOTAL];         // Integer properties
    double            m_double_prop[BAR_PROP_DOUBLE_TOTAL];        // Real properties
    string            m_string_prop[BAR_PROP_STRING_TOTAL];        // String properties
   //--- Return the index of the array the (1) real and (2) string properties are located at
    int               IndexProp(ENUM_BAR_PROP_DOUBLE property)     const { return(int)property-BAR_PROP_INTEGER_TOTAL;                        }
    int               IndexProp(ENUM_BAR_PROP_STRING property)     const { return(int)property-BAR_PROP_INTEGER_TOTAL-BAR_PROP_DOUBLE_TOTAL;  }
   //--- The size of the candle, its body, shadows, and the top and bottom of the body
    double            CandleSize(void)                             const { return(this.High()-this.Low());                                    }
    double            BodySize(void)                               const { return(this.BodyHigh()-this.BodyLow());                            }
    double            ShadowUpSize(void)                           const { return(this.High()-this.BodyHigh());                               }
    double            ShadowDownSize(void)                         const { return(this.BodyLow()-this.Low());                                 }
    double            BodyHigh(void)                               const { return ::fmax(this.Close(),this.Open());                           }
    double            BodyLow(void)                                const { return ::fmin(this.Close(),this.Open());                           }
   //--- The percent of the candle size: the body, the upper and the lower shadow
    double            CandleRatioBodyToCandleSize(void)            const { return(this.CandleSize()>0 ? this.BodySize()*100.0/this.CandleSize()      : 100.0);  }
    double            CandleRatioUpperShadowToCandleSize(void)     const { return(this.CandleSize()>0 ? this.ShadowUpSize()*100.0/this.CandleSize()  : 100.0);  }
    double            CandleRatioLowerShadowToCandleSize(void)     const { return(this.CandleSize()>0 ? this.ShadowDownSize()*100.0/this.CandleSize(): 100.0);  }
   //--- The parts of the time of the bar
    int               TimeYear(void)                               const { return this.m_dt_struct.year;                                      }
    int               TimeMonth(void)                              const { return this.m_dt_struct.mon;                                       }
    int               TimeDayOfWeek(void)                          const { return this.m_dt_struct.day_of_week;                               }
    int               TimeDayOfYear(void)                          const { return this.m_dt_struct.day_of_year;                               }
    int               TimeDay(void)                                const { return this.m_dt_struct.day;                                       }
    int               TimeHour(void)                               const { return this.m_dt_struct.hour;                                      }
    int               TimeMinute(void)                             const { return this.m_dt_struct.min;                                       }
   protected:
   //--- Everything of a bar of the series is copied (a row of what was found on it: CBarPattern, CBarSwing)
    void              SetBar(CBar *bar);
   public:
   //--- Set the (1) integer, (2) real and (3) string properties
    void              SetProperty(ENUM_BAR_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                              }
    void              SetProperty(ENUM_BAR_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;            }
    void              SetProperty(ENUM_BAR_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;            }
   //--- Return the (1) integer, (2) real and (3) string properties
    long              GetProperty(ENUM_BAR_PROP_INTEGER property)  const { return this.m_long_prop[property];                                 }
    double            GetProperty(ENUM_BAR_PROP_DOUBLE property)   const { return this.m_double_prop[this.IndexProp(property)];               }
    string            GetProperty(ENUM_BAR_PROP_STRING property)   const { return this.m_string_prop[this.IndexProp(property)];               }
   //--- Set the (1) symbol, timeframe and time, (2) the parameters of the bar
    void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime time);
    void              SetProperties(const MqlRates &rates);
   //--- Compare the bars by a property (the list of bars is sorted by the time), (the Compare mode is the property)
    virtual int       Compare(const CObject *node,const int mode=0) const;
   //--- What a bar class finds: CBarPattern, CBarSwing, CBarBOS, CBarCHoCH override them (a CBar finds nothing: a type only Python finds).
   //--- (1) the side found on the bar at an index of the list of the judge, (2) how many bars before that bar its row is, (3) the event that tells a new row,
   //--- (4) a row of the class: the bar with the type, its group and the side
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const { return SIGNAL_DIRECTION_NO_PATTERN; }
    virtual int       Shift(void)                  const { return 0;                                    }
    virtual ushort    Event(void)                  const { return (ushort)SERIES_EVENTS_PATTERN;        }
    virtual CBar     *NewRow(CBar *bar,const long type,const long group,const long direction) const;
   //--- The bars of the list after `since` and before the forming one are judged for a type by Find, from the newest one back: the rows (bar time, side)
    int               Calculate(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since,long &times[],ENUM_SIGNAL_DIRECTION &sides[]) const;
   //--- Constructors
                      CBar(void)                                             { this.m_object_type=OBJECT_DE_TYPE_SERIES_BAR; }
                      CBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const MqlRates &rates,const int digits);
   //--- The properties of the bar
   // The bar type by its body (bullish / bearish / zero): from the open and the close, not kept (CBaseObj::Type() is the type of the object)
    ENUM_BAR_BODY_TYPE TypeBody(void)             const;
    ENUM_TIMEFRAMES   Timeframe(void)             const { return (ENUM_TIMEFRAMES)this.GetProperty(BAR_PROP_PERIOD);   }
    int               Spread(void)                const { return (int)this.GetProperty(BAR_PROP_SPREAD);               }
    long              VolumeTick(void)            const { return this.GetProperty(BAR_PROP_VOLUME_TICK);               }
    long              VolumeReal(void)            const { return this.GetProperty(BAR_PROP_VOLUME_REAL);               }
    datetime          Time(void)                  const { return (datetime)this.GetProperty(BAR_PROP_TIME);            }
    double            Open(void)                  const { return this.GetProperty(BAR_PROP_OPEN);                      }
    double            High(void)                  const { return this.GetProperty(BAR_PROP_HIGH);                      }
    double            Low(void)                   const { return this.GetProperty(BAR_PROP_LOW);                       }
    double            Close(void)                 const { return this.GetProperty(BAR_PROP_CLOSE);                     }
    double            Size(void)                  const { return this.GetProperty(BAR_PROP_CANDLE_SIZE);               }
    double            SizeBody(void)              const { return this.GetProperty(BAR_PROP_CANDLE_SIZE_BODY);          }
    double            TopBody(void)               const { return this.GetProperty(BAR_PROP_CANDLE_BODY_TOP);           }
    double            BottomBody(void)            const { return this.GetProperty(BAR_PROP_CANDLE_BODY_BOTTOM);        }
    double            SizeShadowUp(void)          const { return this.GetProperty(BAR_PROP_CANDLE_SIZE_SHADOW_UP);     }
    double            SizeShadowDown(void)        const { return this.GetProperty(BAR_PROP_CANDLE_SIZE_SHADOW_DOWN);   }
    double            RatioBodyToCandleSize(void) const { return this.GetProperty(BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE); }
    double            RatioUpperShadowToCandleSize(void) const { return this.GetProperty(BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE); }
    double            RatioLowerShadowToCandleSize(void) const { return this.GetProperty(BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE); }
    string            Symbol(void)                const { return this.GetProperty(BAR_PROP_SYMBOL);                    }
    int               Digits(void)                const { return this.m_digits;                                        } 
    //Add in V4: Sync with 2 new properties and Table in Database   
     ENUM_BAR_INFORMATION_GROUP InformationGroup(void) const {return (ENUM_BAR_INFORMATION_GROUP)this.GetProperty(BAR_PROP_INFOR_GROUP);}
     ENUM_BAR_INFOR_TYPE InformationType(void)    const {return (ENUM_BAR_INFOR_TYPE)this.GetProperty(BAR_PROP_INFOR_TYPE);}     ENUM_SIGNAL_DIRECTION InformationSide(void)    const {return (ENUM_SIGNAL_DIRECTION)this.GetProperty(BAR_PROP_SIGNAL_DIRECTION);}
  };
#endif // CBAR_MQH_DECLARATION
#ifndef CBAR_MQH_IMPLEMENTATION
#define CBAR_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CBar::CBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const MqlRates &rates,const int digits)
  {
   this.m_object_type=OBJECT_DE_TYPE_SERIES_BAR;
   this.m_digits=digits;
   //--- A bar of MT5 has no information: a row of the table sets them (CBarTimeSeriesCollection::NewRow_BarTimeSeriesCollection)
   this.SetProperty(BAR_PROP_INFOR_GROUP,0);
   this.SetProperty(BAR_PROP_INFOR_TYPE,0);
   this.SetProperty(BAR_PROP_SIGNAL_DIRECTION,SIGNAL_DIRECTION_NONE);
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
 //| Everything of a bar of the series is copied                      |
 //+------------------------------------------------------------------+
 void CBar::SetBar(CBar *bar)
  {
   if(bar==NULL)
      return;
   this.m_digits=bar.m_digits;
   this.m_dt_struct=bar.m_dt_struct;
   ::ArrayCopy(this.m_long_prop,bar.m_long_prop);
   ::ArrayCopy(this.m_double_prop,bar.m_double_prop);
   ::ArrayCopy(this.m_string_prop,bar.m_string_prop);
  }
 //+------------------------------------------------------------------+
 //| A row of a type only Python finds: a copy of the bar with the     |
 //| type, its group and the side                                      |
 //+------------------------------------------------------------------+
 CBar *CBar::NewRow(CBar *bar,const long type,const long group,const long direction) const
  {
   if(bar==NULL)
      return NULL;
   CBar *row=new CBar();
   if(row==NULL)
      return NULL;
   row.SetBar(bar);
   row.SetProperty(BAR_PROP_INFOR_GROUP,group);
   row.SetProperty(BAR_PROP_INFOR_TYPE,type);
   row.SetProperty(BAR_PROP_SIGNAL_DIRECTION,direction);
   return row;
  }
 //+------------------------------------------------------------------+
 //| The bars after `since` judged by Find, from the newest closed one |
 //| back. The row of a swing is on its pivot bar, Shift() bars before |
 //| the bar that confirms it                                          |
 //+------------------------------------------------------------------+
 int CBar::Calculate(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since,long &times[],ENUM_SIGNAL_DIRECTION &sides[]) const
  {
   ::ArrayFree(times);
   ::ArrayFree(sides);
   if(list==NULL || list.Total()==0)
      return 0;
   CBar *newest=list.At(list.Total()-1);
   datetime forming=0;
   if(newest==NULL || !::SeriesInfoInteger(newest.Symbol(),newest.Timeframe(),SERIES_LASTBAR_DATE,forming))
      return 0;
   const int shift=this.Shift();
   for(int i=list.Total()-1;i>=0;i--)
     {
      CBar *bar=list.At(i);
      if(bar==NULL || bar.Time()>=forming)
         continue;   // the forming bar is not judged
      if(bar.Time()<=since)
         break;
      ENUM_SIGNAL_DIRECTION side=this.Find(type,i);
      if(side==SIGNAL_DIRECTION_NO_PATTERN)
         continue;
      CBar *row_bar=list.At(i-shift);
      if(row_bar==NULL)
         continue;
      int total=::ArraySize(times);
      ::ArrayResize(times,total+1);
      ::ArrayResize(sides,total+1);
      times[total]=(long)row_bar.Time();
      sides[total]=side;
     }
   return ::ArraySize(times);
  }
 //+------------------------------------------------------------------+
 //| Compare the bars by the property of the mode (a property of the  |
 //| enum: integer, real, then string)                                |
 //+------------------------------------------------------------------+
 int CBar::Compare(const CObject *node,const int mode=0) const
  {
   const CBar *bar_compared=node;
   if(mode<BAR_PROP_INTEGER_TOTAL)
     {
      long value_compared=bar_compared.GetProperty((ENUM_BAR_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_BAR_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   else if(mode<BAR_PROP_DOUBLE_TOTAL+BAR_PROP_INTEGER_TOTAL)
     {
      double value_compared=bar_compared.GetProperty((ENUM_BAR_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_BAR_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   else if(mode<BAR_PROP_DOUBLE_TOTAL+BAR_PROP_INTEGER_TOTAL+BAR_PROP_STRING_TOTAL)
     {
      string value_compared=bar_compared.GetProperty((ENUM_BAR_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_BAR_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
 //+------------------------------------------------------------------+
 //| Set the symbol, timeframe and time                               |
 //+------------------------------------------------------------------+
 void CBar::SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime time)
  {
   this.SetProperty(BAR_PROP_TIME,time);
   this.SetProperty(BAR_PROP_SYMBOL,symbol);
   this.SetProperty(BAR_PROP_PERIOD,timeframe);
  }
 //+------------------------------------------------------------------+
 //| Set the parameters of the bar                                    |
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
   this.SetProperty(BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,this.CandleRatioBodyToCandleSize());
   this.SetProperty(BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,this.CandleRatioUpperShadowToCandleSize());
   this.SetProperty(BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,this.CandleRatioLowerShadowToCandleSize());
  }
 //+------------------------------------------------------------------+
 //| Return the bar type (bullish / bearish / zero)                   |
 //+------------------------------------------------------------------+
 ENUM_BAR_BODY_TYPE CBar::TypeBody(void) const
  {
   return
     (
      this.Close()>this.Open() ? BAR_BODY_TYPE_BULLISH :
      this.Close()<this.Open() ? BAR_BODY_TYPE_BEARISH :
      (this.ShadowUpSize()+this.ShadowDownSize()==0 ? BAR_BODY_TYPE_NULL : BAR_BODY_TYPE_CANDLE_ZERO_BODY)
     );
  }
#endif // CBAR_MQH_IMPLEMENTATION
#endif // __BAR_MQH__
