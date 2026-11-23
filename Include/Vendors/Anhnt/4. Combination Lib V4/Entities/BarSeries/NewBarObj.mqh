//+------------------------------------------------------------------+
//|                                                    NewBarObj.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- Does a new bar open on a symbol and timeframe: asked to the terminal (CopyTime), never given a time
#ifndef __NEWBAROBJ_MQH__
#define __NEWBAROBJ_MQH__
 #include "..\Bases\BaseObj.mqh"
#ifndef CNEWBAROBJ_MQH_DECLARATION
#define CNEWBAROBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| "New bar" object class                                           |
 //+------------------------------------------------------------------+
 class CNewBarObj : public CBaseObj
  {
   private:
    string            m_symbol;                                    // Symbol
    ENUM_TIMEFRAMES   m_timeframe;                                 // Timeframe
    datetime          m_new_bar_time;                              // New bar time for the auto time management
    datetime          m_prev_time;                                 // Previous time for the auto time management
    datetime          m_new_bar_time_manual;                       // New bar time for the manual time management
    datetime          m_prev_time_manual;                          // Previous time for the manual time management
    datetime          m_prev_new_bar_time;                         // Previous new bar time for the auto time management
    long              m_seconds_between;                           // Number of seconds between two "New bar" events
    int               m_bars_between;                              // Number of bars between two "New bar" events
   //--- The open time of the newest bar of the symbol and timeframe
    datetime          GetLastBarDate(void) const;
   public:
   //--- Set the (1) symbol and (2) timeframe
    void              SetSymbol(const string symbol)               { this.m_symbol=(symbol==NULL || symbol==""   ? ::Symbol() : symbol);                     }
    void              SetTimeframe(const ENUM_TIMEFRAMES timeframe){ this.m_timeframe=(timeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe); }
   //--- Save the new bar time during the manual time management
    void              SaveNewBarTime(void)                         { this.m_prev_time_manual=this.GetLastBarDate();                                          }
    string            Symbol(void)                           const { return this.m_symbol;             }
    ENUM_TIMEFRAMES   Timeframe(void)                        const { return this.m_timeframe;          }
    datetime          TimeNewBar(void)                       const { return this.m_new_bar_time;       }
    datetime          TimePrevNewBar(void)                   const { return this.m_prev_new_bar_time;  }
    long              SecondsBetweenNewBars(void)            const { return this.m_seconds_between;    }
    int               BarsBetweenNewBars(void)               const { return this.m_bars_between;       }
   //--- The new bar flag with the (1) auto and (2) manual time management
    bool              IsNewBar(void);
    bool              IsNewBarManual(void);
                      CNewBarObj(void) : m_symbol(::Symbol()),m_timeframe((ENUM_TIMEFRAMES)::Period()),m_prev_time(0),m_new_bar_time(0),
                                         m_prev_time_manual(0),m_new_bar_time_manual(0),m_prev_new_bar_time(0),m_seconds_between(0),m_bars_between(0) {}
  };
#endif // CNEWBAROBJ_MQH_DECLARATION
#ifndef CNEWBAROBJ_MQH_IMPLEMENTATION
#define CNEWBAROBJ_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Return the new bar opening flag                                  |
 //+------------------------------------------------------------------+
 bool CNewBarObj::IsNewBar(void)
  {
   datetime tm=this.GetLastBarDate();
   if(tm<=0)
      return false;
  //--- The first call: remember the bar, it is not a new one
   if(this.m_prev_time+this.m_new_bar_time==0)
     {
      this.m_new_bar_time=this.m_prev_time=tm;
      return false;
     }
  //--- The previous time is older than the newest bar: a new bar opened
   if(this.m_prev_time>0 && this.m_prev_time<tm)
     {
      this.m_prev_new_bar_time=this.m_prev_time;
      this.m_seconds_between=tm-this.m_prev_time;
      this.m_bars_between=int(this.m_seconds_between/::PeriodSeconds(this.m_timeframe));
      this.m_new_bar_time=this.m_prev_time=tm;
      return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| The new bar opening flag during the manual time management: it   |
 //| stays true until SaveNewBarTime() says the new bar was handled   |
 //+------------------------------------------------------------------+
 bool CNewBarObj::IsNewBarManual(void)
  {
   datetime tm=this.GetLastBarDate();
   if(tm<=0)
      return false;
   if(this.m_prev_time_manual+this.m_new_bar_time_manual==0)
     {
      this.m_new_bar_time_manual=this.m_prev_time_manual=tm;
      return false;
     }
   if(this.m_prev_time_manual>0 && this.m_prev_time_manual<tm)
     {
      this.m_new_bar_time_manual=tm;
      return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Return the open time of the newest bar                           |
 //+------------------------------------------------------------------+
 datetime CNewBarObj::GetLastBarDate(void) const
  {
   datetime array[1];
   return(::CopyTime(this.m_symbol,this.m_timeframe,0,1,array)==1 ? array[0] : 0);
  }
#endif // CNEWBAROBJ_MQH_IMPLEMENTATION
#endif // __NEWBAROBJ_MQH__
