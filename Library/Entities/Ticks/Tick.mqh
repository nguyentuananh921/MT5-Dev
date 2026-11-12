//+------------------------------------------------------------------+
//|                                                         Tick.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- TEMPORARY UNUSED (2026-10-31): nothing includes it. DoEasy made the tick series for the DOM; V1 / V2 never used it; ported to V4 it held the EA 70 s
//--- (649604 ticks of XAUUSD as objects). The Bid / Ask of a deal is CopyTicksRange of COrder::BidAskFromTicks, the pause of a symbol is CNewTickObj
//--- Change from DoEasy Objects\Ticks\DataTick.mqh (V2 Timeseries\Ticks\DataTick.mqh): renamed CDataTick -> CTick (the name of the layer as CBar, CSignal)
//--- A tick of a symbol, as MT5 gives it: RAM only (MT5 keeps the ticks, the database does not). No Print and no descriptions (as V4 CBar)
#ifndef __TICK_MQH__
#define __TICK_MQH__
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\TickDefines.mqh"
#ifndef CTICK_MQH_DECLARATION
#define CTICK_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| "Tick" class                                                     |
 //+------------------------------------------------------------------+
 class CTick : public CBaseObj
  {
   private:
    int               m_digits;                                    // Symbol's digits value
    long              m_long_prop[TICK_PROP_INTEGER_TOTAL];        // Integer properties
    double            m_double_prop[TICK_PROP_DOUBLE_TOTAL];       // Real properties
    string            m_string_prop[TICK_PROP_STRING_TOTAL];       // String properties
   //--- Return the index of the array the tick's (1) double and (2) string properties are actually located at
    int               IndexProp(ENUM_TICK_PROP_DOUBLE property)    const { return(int)property-TICK_PROP_INTEGER_TOTAL;                         }
    int               IndexProp(ENUM_TICK_PROP_STRING property)    const { return(int)property-TICK_PROP_INTEGER_TOTAL-TICK_PROP_DOUBLE_TOTAL;  }
   public:
   //--- Set tick's (1) integer, (2) real and (3) string property
    void              SetProperty(ENUM_TICK_PROP_INTEGER property,long value)  { this.m_long_prop[property]=value;                    }
    void              SetProperty(ENUM_TICK_PROP_DOUBLE property,double value) { this.m_double_prop[this.IndexProp(property)]=value;  }
    void              SetProperty(ENUM_TICK_PROP_STRING property,string value) { this.m_string_prop[this.IndexProp(property)]=value;  }
   //--- Return tick's (1) integer, (2) real and (3) string property from the properties array
    long              GetProperty(ENUM_TICK_PROP_INTEGER property) const { return this.m_long_prop[property];                           }
    double            GetProperty(ENUM_TICK_PROP_DOUBLE property)  const { return this.m_double_prop[this.IndexProp(property)];         }
    string            GetProperty(ENUM_TICK_PROP_STRING property)  const { return this.m_string_prop[this.IndexProp(property)];         }
   //--- Compare the ticks by a property (the list of ticks is sorted by the time in milliseconds), (the Compare mode is the property)
    virtual int       Compare(const CObject *node,const int mode=0) const;
   //--- Constructors
                      CTick(void)                                   { this.m_type=OBJECT_DE_TYPE_TICK; }
                      CTick(const string symbol,const MqlTick &tick);
   //--- Return tick's (1) Time, (2) time in milliseconds, (3) volume, (4) flags
    datetime          Time(void)                  const { return (datetime)this.GetProperty(TICK_PROP_TIME);           }
    long              TimeMSC(void)               const { return this.GetProperty(TICK_PROP_TIME_MSC);                 }
    long              Volume(void)                const { return this.GetProperty(TICK_PROP_VOLUME);                   }
    uint              Flags(void)                 const { return (uint)this.GetProperty(TICK_PROP_FLAGS);              }
   //--- Return tick's (1) Bid, (2) Ask, (3) Last price, (4) volume with greater accuracy, (5) spread of the tick (Ask - Bid: the one spread of the symbol now)
    double            Bid(void)                   const { return this.GetProperty(TICK_PROP_BID);                      }
    double            Ask(void)                   const { return this.GetProperty(TICK_PROP_ASK);                      }
    double            Last(void)                  const { return this.GetProperty(TICK_PROP_LAST);                     }
    double            VolumeReal(void)            const { return this.GetProperty(TICK_PROP_VOLUME_REAL);              }
    double            Spread(void)                const { return this.Ask()-this.Bid();                                }
    int               Digits(void)                const { return this.m_digits;                                        }
   //--- Return tick symbol
    string            Symbol(void)                const { return this.GetProperty(TICK_PROP_SYMBOL);                   }
   //--- Return bar (1) time, (2) index on the specified timeframe the tick time falls into
    datetime          TimeBar(const ENUM_TIMEFRAMES timeframe) const { return ::iTime(this.Symbol(),timeframe,this.Index(timeframe));                                    }
    int               Index(const ENUM_TIMEFRAMES timeframe)   const { return ::iBarShift(this.Symbol(),(timeframe==PERIOD_CURRENT ? ::Period() : timeframe),this.Time()); }
   //--- Return the flag of (1) Bid, (2) Ask, (3) Last price change, (4) volume change; (5) buy and (6) sell deal
    bool              IsChangeBid(void)           const { return((this.Flags() & TICK_FLAG_BID)==TICK_FLAG_BID);       }
    bool              IsChangeAsk(void)           const { return((this.Flags() & TICK_FLAG_ASK)==TICK_FLAG_ASK);       }
    bool              IsChangeLast(void)          const { return((this.Flags() & TICK_FLAG_LAST)==TICK_FLAG_LAST);     }
    bool              IsChangeVolume(void)        const { return((this.Flags() & TICK_FLAG_VOLUME)==TICK_FLAG_VOLUME); }
    bool              IsChangeBuy(void)           const { return((this.Flags() & TICK_FLAG_BUY)==TICK_FLAG_BUY);       }
    bool              IsChangeSell(void)          const { return((this.Flags() & TICK_FLAG_SELL)==TICK_FLAG_SELL);     }
  };
#endif // CTICK_MQH_DECLARATION
#ifndef CTICK_MQH_IMPLEMENTATION
#define CTICK_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Parametric constructor                                           |
 //+------------------------------------------------------------------+
 CTick::CTick(const string symbol,const MqlTick &tick)
  {
   this.m_type=OBJECT_DE_TYPE_TICK;
   this.m_digits=(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   this.SetProperty(TICK_PROP_TIME,tick.time);
   this.SetProperty(TICK_PROP_TIME_MSC,tick.time_msc);
   this.SetProperty(TICK_PROP_VOLUME,tick.volume);
   this.SetProperty(TICK_PROP_FLAGS,tick.flags);
   this.SetProperty(TICK_PROP_BID,tick.bid);
   this.SetProperty(TICK_PROP_ASK,tick.ask);
   this.SetProperty(TICK_PROP_LAST,tick.last);
   this.SetProperty(TICK_PROP_VOLUME_REAL,tick.volume_real);
   this.SetProperty(TICK_PROP_SYMBOL,(symbol==NULL || symbol=="" ? ::Symbol() : symbol));
  }
 //+------------------------------------------------------------------+
 //| Compare the ticks by the property of the mode (a property of the |
 //| enum: integer, real, then string)                                |
 //+------------------------------------------------------------------+
 int CTick::Compare(const CObject *node,const int mode=0) const
  {
   const CTick *tick_compared=node;
   if(mode<TICK_PROP_INTEGER_TOTAL)
     {
      long value_compared=tick_compared.GetProperty((ENUM_TICK_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_TICK_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   else if(mode<TICK_PROP_DOUBLE_TOTAL+TICK_PROP_INTEGER_TOTAL)
     {
      double value_compared=tick_compared.GetProperty((ENUM_TICK_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_TICK_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   else if(mode<TICK_PROP_DOUBLE_TOTAL+TICK_PROP_INTEGER_TOTAL+TICK_PROP_STRING_TOTAL)
     {
      string value_compared=tick_compared.GetProperty((ENUM_TICK_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_TICK_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
#endif // CTICK_MQH_IMPLEMENTATION
#endif // __TICK_MQH__
