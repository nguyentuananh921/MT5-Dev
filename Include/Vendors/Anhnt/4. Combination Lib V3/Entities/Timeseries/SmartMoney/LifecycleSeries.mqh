//+------------------------------------------------------------------+
//|                                              LifecycleSeries.mqh |
//| One lifecycle event (Born/Touched/.../Dead) of a Trendline, Zone |
//| or Protected Level - pure data, no GUI. Same shape as            |
//| CMarketStructureSeries (CBaseObj + property arrays +             |
//| Compare/IsEqual for CArrayObj::Sort/Search/InsertSort).          |
//| 1 instance = 1 event of 1 object. What is drawn (CZoneTagBox, ...)  |
//| is decided by the class that reads these records.                |
//+------------------------------------------------------------------+
#ifndef __LIFECYCLESERIES_MQH__
#define __LIFECYCLESERIES_MQH__
 #include "..\..\Bases\BaseObj.mqh"
 #include "..\..\Defines\MarketStructureDefines.mqh"
 #include "..\..\Defines\EventDefines.mqh"
#ifndef CLIFECYCLESERIES_MQH_DECLARATION
#define CLIFECYCLESERIES_MQH_DECLARATION
 class CLifecycleSeries : public CBaseObj
  {
   private:
     long      m_long_prop[LIFECYCLE_PROP_INTEGER_TOTAL];                      // Integer properties
     double    m_double_prop[LIFECYCLE_PROP_DOUBLE_TOTAL];                     // Real properties
     string    m_string_prop[LIFECYCLE_PROP_STRING_TOTAL];                     // String properties
     int       IndexProp(ENUM_LIFECYCLE_PROP_DOUBLE property) const { return (int)property-LIFECYCLE_PROP_INTEGER_TOTAL; }
     int       IndexProp(ENUM_LIFECYCLE_PROP_STRING property) const { return (int)property-LIFECYCLE_PROP_INTEGER_TOTAL-LIFECYCLE_PROP_DOUBLE_TOTAL; }
     ulong     MakeCode(const ENUM_LIFECYCLE_EVENT event,const ENUM_LIFECYCLE_OBJECT_KIND kind,const string symbol,
                        const ENUM_TIMEFRAMES timeframe,const ENUM_SIGNAL_DIR direction,const datetime origin_time,const datetime time) const;
   public:
   //--- Set (1) integer, (2) real and (3) string properties
     void      SetProperty(ENUM_LIFECYCLE_PROP_INTEGER property,long value)    { this.m_long_prop[property]=value;                       }
     void      SetProperty(ENUM_LIFECYCLE_PROP_DOUBLE  property,double value)  { this.m_double_prop[this.IndexProp(property)]=value;     }
     void      SetProperty(ENUM_LIFECYCLE_PROP_STRING  property,string value)  { this.m_string_prop[this.IndexProp(property)]=value;     }
   //--- Return (1) integer, (2) real and (3) string properties
     long      GetProperty(ENUM_LIFECYCLE_PROP_INTEGER property) const { return this.m_long_prop[property];                       }
     double    GetProperty(ENUM_LIFECYCLE_PROP_DOUBLE  property) const { return this.m_double_prop[this.IndexProp(property)];     }
     string    GetProperty(ENUM_LIFECYCLE_PROP_STRING  property) const { return this.m_string_prop[this.IndexProp(property)];     }
   //--- Return itself
     CLifecycleSeries *GetObject(void) { return &this; }
   //--- Compare by a specified property (for CArrayObj::Sort/Search/InsertSort)
     virtual int Compare(const CObject *node,const int mode=0) const;
   //--- Compare by ALL properties
     bool      IsEqual(CLifecycleSeries *compared_obj) const;
   //--- Constructors/Destructor
               CLifecycleSeries(void) { this.m_type=OBJECT_DE_TYPE_SERIES_LIFECYCLE; }
               CLifecycleSeries(const ENUM_LIFECYCLE_EVENT event,const ENUM_LIFECYCLE_OBJECT_KIND kind,
                                const string symbol,const ENUM_TIMEFRAMES timeframe,
                                const datetime origin_time,const datetime time,const ENUM_SIGNAL_DIR direction,
                                const datetime time_a,const double price_a,const datetime time_b,const double price_b,
                                const ENUM_LIFECYCLE_SOURCE source=LIFECYCLE_SOURCE_AUTO,
                                const ENUM_LIFECYCLE_DEAD_REASON dead_reason=LIFECYCLE_DEAD_NONE);
              ~CLifecycleSeries(void) {}
   //--- Return (1) event, (2) object kind, (3) timeframe, (4) unique code, (5) event time, (6) birth time of the object,
   //--- (7) direction, (8) source, (9) reason of death, (10) first anchor, (11) second anchor, (12) upper and (13) lower price, (14) symbol
     ENUM_LIFECYCLE_EVENT        Event(void)      const { return (ENUM_LIFECYCLE_EVENT)this.GetProperty(LIFECYCLE_PROP_EVENT);                }
     ENUM_LIFECYCLE_OBJECT_KIND  Kind(void)       const { return (ENUM_LIFECYCLE_OBJECT_KIND)this.GetProperty(LIFECYCLE_PROP_KIND);          }
     ENUM_TIMEFRAMES             Timeframe(void)  const { return (ENUM_TIMEFRAMES)this.GetProperty(LIFECYCLE_PROP_PERIOD);                    }
     ulong                       Code(void)       const { return (ulong)this.GetProperty(LIFECYCLE_PROP_CODE);                               }
     datetime                    Time(void)       const { return (datetime)this.GetProperty(LIFECYCLE_PROP_TIME);                            }
     datetime                    OriginTime(void) const { return (datetime)this.GetProperty(LIFECYCLE_PROP_ORIGIN_TIME);                     }
     ENUM_SIGNAL_DIR             Direction(void)  const { return (ENUM_SIGNAL_DIR)this.GetProperty(LIFECYCLE_PROP_DIRECTION);                 }
     ENUM_LIFECYCLE_SOURCE       Source(void)     const { return (ENUM_LIFECYCLE_SOURCE)this.GetProperty(LIFECYCLE_PROP_SOURCE);             }
     ENUM_LIFECYCLE_DEAD_REASON  DeadReason(void) const { return (ENUM_LIFECYCLE_DEAD_REASON)this.GetProperty(LIFECYCLE_PROP_DEAD_REASON);    }
     datetime                    TimeA(void)      const { return (datetime)this.GetProperty(LIFECYCLE_PROP_ANCHOR_A_TIME);                   }
     double                      PriceA(void)     const { return this.GetProperty(LIFECYCLE_PROP_ANCHOR_A_PRICE);                            }
     datetime                    TimeB(void)      const { return (datetime)this.GetProperty(LIFECYCLE_PROP_ANCHOR_B_TIME);                   }
     double                      PriceB(void)     const { return this.GetProperty(LIFECYCLE_PROP_ANCHOR_B_PRICE);                            }
     double                      Top(void)        const { return ::MathMax(this.PriceA(),this.PriceB());                                     }
     double                      Bottom(void)     const { return ::MathMin(this.PriceA(),this.PriceB());                                     }
     string                      Symbol(void)     const { return this.GetProperty(LIFECYCLE_PROP_SYMBOL);                                    }
   //--- Return the key of the object this event belongs to: kind + symbol + timeframe + direction + birth time (the name the listeners look for)
     string                      ObjectKey(void)  const;
  };
#endif // CLIFECYCLESERIES_MQH_DECLARATION
#ifndef CLIFECYCLESERIES_MQH_IMPLEMENTATION
#define CLIFECYCLESERIES_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Unique code (Primary Key) of the record. Each field is mixed in  |
 //| (FNV-1a style) instead of added up: a sum would give the same    |
 //| code to two objects born one bar apart with events one bar apart |
 //+------------------------------------------------------------------+
 ulong CLifecycleSeries::MakeCode(const ENUM_LIFECYCLE_EVENT event,const ENUM_LIFECYCLE_OBJECT_KIND kind,const string symbol,
                                  const ENUM_TIMEFRAMES timeframe,const ENUM_SIGNAL_DIR direction,const datetime origin_time,const datetime time) const
  {
   const ulong prime=1099511628211;
   ulong code=0xCBF29CE484222325;
   code=(code^(ulong)origin_time)*prime;
   code=(code^(ulong)time)*prime;
   code=(code^(ulong)event)*prime;
   code=(code^(ulong)kind)*prime;
   code=(code^(ulong)direction)*prime;
   code=(code^(ulong)timeframe)*prime;
   for(int i=0;i<(int)StringLen(symbol);i++)
      code=(code^(ulong)StringGetCharacter(symbol,i))*prime;
   return code;
  }
 //+------------------------------------------------------------------+
 //| Parametric constructor                                           |
 //+------------------------------------------------------------------+
 CLifecycleSeries::CLifecycleSeries(const ENUM_LIFECYCLE_EVENT event,const ENUM_LIFECYCLE_OBJECT_KIND kind,
                                    const string symbol,const ENUM_TIMEFRAMES timeframe,
                                    const datetime origin_time,const datetime time,const ENUM_SIGNAL_DIR direction,
                                    const datetime time_a,const double price_a,const datetime time_b,const double price_b,
                                    const ENUM_LIFECYCLE_SOURCE source,
                                    const ENUM_LIFECYCLE_DEAD_REASON dead_reason)
  {
   this.m_type=OBJECT_DE_TYPE_SERIES_LIFECYCLE;
   this.SetProperty(LIFECYCLE_PROP_CODE,        (long)this.MakeCode(event,kind,symbol,timeframe,direction,origin_time,time));
   this.SetProperty(LIFECYCLE_PROP_TIME,        time);
   this.SetProperty(LIFECYCLE_PROP_EVENT,       event);
   this.SetProperty(LIFECYCLE_PROP_KIND,        kind);
   this.SetProperty(LIFECYCLE_PROP_ORIGIN_TIME, origin_time);
   this.SetProperty(LIFECYCLE_PROP_PERIOD,      timeframe);
   this.SetProperty(LIFECYCLE_PROP_DIRECTION,   direction);
   this.SetProperty(LIFECYCLE_PROP_SOURCE,      source);
   this.SetProperty(LIFECYCLE_PROP_DEAD_REASON, dead_reason);
   this.SetProperty(LIFECYCLE_PROP_ANCHOR_A_TIME,  time_a);
   this.SetProperty(LIFECYCLE_PROP_ANCHOR_B_TIME,  time_b);
   this.SetProperty(LIFECYCLE_PROP_ANCHOR_A_PRICE, price_a);
   this.SetProperty(LIFECYCLE_PROP_ANCHOR_B_PRICE, price_b);
   this.SetProperty(LIFECYCLE_PROP_SYMBOL,      symbol);
  }
 //+------------------------------------------------------------------+
 //| Compare with another object by the specified property            |
 //+------------------------------------------------------------------+
 int CLifecycleSeries::Compare(const CObject *node,const int mode=0) const
  {
   const CLifecycleSeries *obj_compared=node;
   if(mode<LIFECYCLE_PROP_INTEGER_TOTAL)
     {
      long value_compared=obj_compared.GetProperty((ENUM_LIFECYCLE_PROP_INTEGER)mode);
      long value_current =this.GetProperty((ENUM_LIFECYCLE_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   else if(mode<LIFECYCLE_PROP_DOUBLE_TOTAL+LIFECYCLE_PROP_INTEGER_TOTAL)
     {
      double value_compared=obj_compared.GetProperty((ENUM_LIFECYCLE_PROP_DOUBLE)mode);
      double value_current =this.GetProperty((ENUM_LIFECYCLE_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   else if(mode<LIFECYCLE_PROP_DOUBLE_TOTAL+LIFECYCLE_PROP_INTEGER_TOTAL+LIFECYCLE_PROP_STRING_TOTAL)
     {
      string value_compared=obj_compared.GetProperty((ENUM_LIFECYCLE_PROP_STRING)mode);
      string value_current =this.GetProperty((ENUM_LIFECYCLE_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
 //+------------------------------------------------------------------+
 //| Compare with another object by ALL properties                    |
 //+------------------------------------------------------------------+
 bool CLifecycleSeries::IsEqual(CLifecycleSeries *compared_obj) const
  {
   int begin=0,end=LIFECYCLE_PROP_INTEGER_TOTAL;
   for(int i=begin;i<end;i++)
     {
      ENUM_LIFECYCLE_PROP_INTEGER prop=(ENUM_LIFECYCLE_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
   begin=end; end+=LIFECYCLE_PROP_DOUBLE_TOTAL;
   for(int i=begin;i<end;i++)
     {
      ENUM_LIFECYCLE_PROP_DOUBLE prop=(ENUM_LIFECYCLE_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
   begin=end; end+=LIFECYCLE_PROP_STRING_TOTAL;
   for(int i=begin;i<end;i++)
     {
      ENUM_LIFECYCLE_PROP_STRING prop=(ENUM_LIFECYCLE_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Key of the object this event belongs to                          |
 //+------------------------------------------------------------------+
 string CLifecycleSeries::ObjectKey(void) const
  {
   return ::StringFormat("%d_%s_%d_%d_%I64d",(int)this.Kind(),this.Symbol(),(int)this.Timeframe(),(int)this.Direction(),(long)this.OriginTime());
  }
#endif // CLIFECYCLESERIES_MQH_IMPLEMENTATION
#endif // __LIFECYCLESERIES_MQH__
