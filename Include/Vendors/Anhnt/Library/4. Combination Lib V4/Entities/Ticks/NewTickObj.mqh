//+------------------------------------------------------------------+
//|                                                   NewTickObj.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//| Topic link https://www.mql5.com/en/articles/7695                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- Copy from DoEasy Objects\Ticks\NewTickObj.mqh (V2 Timeseries\Ticks\NewTickObj.mqh): the name CNewTickObj is kept
//--- Change from V2: base CBaseObj -> CBaseObjExt (events; m_tick is the one of CBaseObjExt). IsNewTick tells TICK_EVENT_PAUSE / TICK_EVENT_RESUME.
//--- Its owner is CBarTimeSeriesDE (as DoEasy CTimeSeriesDE::m_new_tick), one for each symbol
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __NEWTICKOBJ_MQH__
#define __NEWTICKOBJ_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Bases\BaseObjExt.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include "..\Defines\TickDefines.mqh"
 #ifndef CNEWTICKOBJ_MQH_DECLARATION
 #define CNEWTICKOBJ_MQH_DECLARATION
   //+------------------------------------------------------------------+
   //| "New tick" class                                                 |
   //+------------------------------------------------------------------+
   class CNewTickObj : public CBaseObjExt
   {
      private:
         MqlTick           m_tick_prev;                     // Structure of the current prices during the previous check
         string            m_symbol;                        // Object symbol
         bool              m_new_tick;                      // New tick flag
         bool              m_paused;                        // No tick for TICK_PAUSE_SECONDS (TICK_EVENT_PAUSE told, TICK_EVENT_RESUME at the next tick)
      public:
       //--- Set a symbol
         void              SetSymbol(const string symbol)   { this.m_symbol=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);  }
       //--- Return the new tick flag (the events of the call: TICK_EVENT_PAUSE, TICK_EVENT_RESUME)
         bool              IsNewTick(void);
         bool              IsPaused(void)             const { return this.m_paused; }
       //--- Update price data in the tick structure and set the "New tick" event flag if necessary
         void              Refresh(void)                    { this.m_new_tick=this.IsNewTick(); }
       //--- Constructors
                           CNewTickObj(void) : m_new_tick(false),m_paused(false) { this.m_object_type=OBJECT_DE_TYPE_NEW_TICK; ::ZeroMemory(this.m_tick_prev); }
                           CNewTickObj(const string symbol);
   };
 #endif // CNEWTICKOBJ_MQH_DECLARATION
 #ifndef CNEWTICKOBJ_MQH_IMPLEMENTATION
 #define CNEWTICKOBJ_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| CNewTickObj parametric constructor                               |
   //+------------------------------------------------------------------+
   CNewTickObj::CNewTickObj(const string symbol) : m_symbol(symbol),m_new_tick(false),m_paused(false)
    {
      this.m_object_type=OBJECT_DE_TYPE_NEW_TICK;
     //--- Reset the structures of the new and previous ticks
      ::ZeroMemory(this.m_tick);
      ::ZeroMemory(this.m_tick_prev);
     //--- If managed to get the current prices to the tick structure,
     //--- copy data of the obtained tick to the previous tick data and reset the first launch flag
      if(::SymbolInfoTick(this.m_symbol,this.m_tick))
      {
         this.m_tick_prev=this.m_tick;
         this.m_first_start=false;
      }
   }
   //+------------------------------------------------------------------+
   //| Return the new tick flag                                         |
   //+------------------------------------------------------------------+
   bool CNewTickObj::IsNewTick(void)
   {
      this.SetEventFlag(false);
      this.GetListEvents().Clear();
     //--- If failed to get the current prices to the tick structure, return 'false'
      if(!::SymbolInfoTick(this.m_symbol,this.m_tick))
         return false;
     //--- If this is the first launch, copy data of the obtained tick to the previous tick data
     //--- reset the first launch flag and return 'false'
      if(this.m_first_start)
      {
         this.m_tick_prev=this.m_tick;
         this.m_first_start=false;
         return false;
      }
     //--- If the time of a new tick is not equal to the time of a tick during the previous check -
     //--- copy data of the obtained tick to the previous tick data and return 'true'
      if(this.m_tick.time_msc!=this.m_tick_prev.time_msc)
      {
         this.m_tick_prev=this.m_tick;
         if(this.m_paused)
           {
            this.m_paused=false;   // the symbol ticks again: its hands go on
            if(this.EventAdd((ushort)TICK_EVENT_RESUME,this.m_tick.time_msc,this.m_tick.bid,this.m_symbol))
               this.SetEventFlag(true);
            ::Print("MY DEBUG    CNewTickObj::IsNewTick: ",this.m_symbol," ticks again (",::TimeToString(this.m_tick.time,TIME_DATE|TIME_SECONDS),"): TICK_EVENT_RESUME");
           }
         return true;
      }
     //--- No tick for TICK_PAUSE_SECONDS (the server time goes on): the symbol rests, told once
      if(!this.m_paused && (long)::TimeTradeServer()-(long)this.m_tick_prev.time>=TICK_PAUSE_SECONDS)
        {
         this.m_paused=true;
         if(this.EventAdd((ushort)TICK_EVENT_PAUSE,this.m_tick_prev.time_msc,this.m_tick_prev.bid,this.m_symbol))
            this.SetEventFlag(true);
         ::Print("MY DEBUG    CNewTickObj::IsNewTick: ",this.m_symbol," has no tick since ",::TimeToString(this.m_tick_prev.time,TIME_DATE|TIME_SECONDS),
                 " (",TICK_PAUSE_SECONDS," s at least): TICK_EVENT_PAUSE");
        }
     //--- In all other cases, return 'false'
      return false;
   }
   //+------------------------------------------------------------------+

 #endif // CNEWTICKOBJ_MQH_IMPLEMENTATION
#endif // __NEWTICKOBJ_MQH__
