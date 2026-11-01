//+------------------------------------------------------------------+
//|                                                 TickSeriesDE.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- TEMPORARY UNUSED (2026-10-31): nothing includes it. DoEasy made the tick series for the DOM; V1 / V2 never used it; ported to V4 it held the EA 70 s
//--- (649604 ticks of XAUUSD as objects). The Bid / Ask of a deal is CopyTicksRange of COrder::BidAskFromTicks, the pause of a symbol is CNewTickObj
//--- Change from DoEasy Objects\Ticks\TickSeries.mqh (V2 Timeseries\Ticks\TickSeries.mqh): renamed CTickSeries -> CTickSeriesDE (as CBarSeriesDE, CSignalSeriesDE)
//--- The ticks of one symbol, RAM only (MT5 keeps them: Readme "Live on RAM, Save on DB for no more calculation"). It owns the CNewTickObj of the symbol: its
//--- TICK_EVENT_PAUSE / RESUME go up (Event Rule). Methods come from DoEasy one by one when a class asks (no Print, no Select by property)
#ifndef __TICKSERIESDE_MQH__
#define __TICKSERIESDE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Bases\BaseObjExt.mqh"
 #include "..\Defines\TickDefines.mqh"
 #include "NewTickObj.mqh"
 #include "Tick.mqh"
#ifndef CTICKSERIESDE_MQH_DECLARATION
#define CTICKSERIESDE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| "Tick data series" class                                         |
 //+------------------------------------------------------------------+
 class CTickSeriesDE : public CBaseObjExt
  {
   private:
    string            m_symbol;                                    // Symbol
    ulong             m_last_time;                                 // Last tick time (0: the ticks of the days asked are not copied yet)
    uint              m_amount;                                    // Amount of applied tick series data
    uint              m_required;                                  // Required number of days for tick series data
    CArrayObj         m_list_ticks;                                // List of tick data (by time, oldest first)
    CNewTickObj       m_new_tick_obj;                              // "New tick" object
   //--- Create a new tick data object (added at the end: MT5 gives the ticks by time)
    CTick            *CreateNewTickObj(const MqlTick &tick);
   //--- The events of m_new_tick_obj go to the list of this object (the parent reads it)
    bool              RelayEvents(CBaseObjExt *child);
   public:
   //--- Return the list of tick data
    CArrayObj        *GetList(void)                                { return &this.m_list_ticks;       }
   //--- Return the object of tick data by (1) time in milliseconds (the last one of that time), (2) the last one in the list and (3) the list size
    CTick            *GetTick(const ulong time_msc);
    CTick            *GetLastTick(void)                            { return this.m_list_ticks.At(this.m_list_ticks.Total()-1); }
    int               DataTotal(void)                        const { return this.m_list_ticks.Total();       }
   //--- The comparison method for searching identical tick series objects by a symbol
    virtual int       Compare(const CObject *node,const int mode=0) const;
   //--- Constructors
                      CTickSeriesDE(void) : m_last_time(0),m_amount(0) { this.m_type=OBJECT_DE_TYPE_TICKSERIES; this.SetRequiredUsedDays(); }
                      CTickSeriesDE(const string symbol,const uint required=0);
   //--- Set (1) a symbol and (2) a number of used tick series data
    void              SetSymbol(const string symbol);
    void              SetRequiredUsedDays(const uint required=0);
   //--- Return (1) symbol, (2) number of used, (3) requested tick data and (4) the pause of the symbol (no tick for TICK_PAUSE_SECONDS)
    string            Symbol(void)                           const { return this.m_symbol;                   }
    ulong             AvailableUsedData(void)                const { return this.m_amount;                   }
    ulong             RequiredUsedDays(void)                 const { return this.m_required;                 }
    bool              IsPaused(void)                         const { return this.m_new_tick_obj.IsPaused();  }
   //--- (1) Create and (2) update the tick series list (DoEasy Refresh): true when ticks were added. Events: TICK_EVENT_PAUSE / RESUME
    int               Create(const uint required=0);
    bool              RefreshSeries(void);
  };
#endif // CTICKSERIESDE_MQH_DECLARATION
#ifndef CTICKSERIESDE_MQH_IMPLEMENTATION
#define CTICKSERIESDE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Parametric constructor                                           |
 //+------------------------------------------------------------------+
 CTickSeriesDE::CTickSeriesDE(const string symbol,const uint required=0) : m_symbol(symbol),m_last_time(0),m_amount(0)
  {
   this.m_type=OBJECT_DE_TYPE_TICKSERIES;
   this.m_list_ticks.Clear();
   this.SetRequiredUsedDays(required);
   this.m_new_tick_obj.SetSymbol(this.m_symbol);
   this.m_new_tick_obj.Refresh();
  }
 int CTickSeriesDE::Compare(const CObject *node,const int mode=0) const
  {
   const CTickSeriesDE *compared_obj=node;
   return(this.Symbol()==compared_obj.Symbol() ? 0 : this.Symbol()>compared_obj.Symbol() ? 1 : -1);
  }
 //+------------------------------------------------------------------+
 //| Set a symbol                                                     |
 //+------------------------------------------------------------------+
 void CTickSeriesDE::SetSymbol(const string symbol)
  {
   if(this.m_symbol==symbol)
      return;
   this.m_symbol=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
   this.m_new_tick_obj.SetSymbol(this.m_symbol);
  }
 //+------------------------------------------------------------------+
 //| Set the number of required tick data                             |
 //+------------------------------------------------------------------+
 void CTickSeriesDE::SetRequiredUsedDays(const uint required=0)
  {
   this.m_required=(required<1 ? TICKSERIES_DEFAULT_DAYS_COUNT : required);
  }
 //+------------------------------------------------------------------+
 //| Create the series list of tick data                              |
 //+------------------------------------------------------------------+
 int CTickSeriesDE::Create(const uint required=0)
  {
   if(required>0)
      this.SetRequiredUsedDays(required);
   ulong debug_ms=::GetTickCount64();   // MY DEBUG
   MqlTick ticks_array[];
   this.m_list_ticks.Clear();
   this.m_last_time=0;
   ::ResetLastError();
   //--- The ticks from the start of the day m_required days back
   MqlDateTime date_str={};
   datetime date=::iTime(this.m_symbol,PERIOD_D1,this.m_required);
   ::TimeToStruct(date,date_str);
   date_str.hour=date_str.min=date_str.sec=0;
   date=::StructToTime(date_str);
   long date_from=(long)date*1000;
   if(date_from<1)
      date_from=1;
   //--- Change from DoEasy (CopyTicksRange from date_from, then every tick an object, then the oldest deleted: millions of ticks of a busy symbol held the EA
   //--- and GBs of RAM): the newest TICKSERIES_MAX_DATA_TOTAL ticks only (from=0), the ones before date_from are left out
   int copied=::CopyTicks(this.m_symbol,ticks_array,COPY_TICKS_ALL,0,TICKSERIES_MAX_DATA_TOTAL);
   if(copied<1)
     {
      ::Print(__FUNCTION__," > ",this.m_symbol,": no tick copied, error ",::GetLastError(),": asked again at the next call");
      return 0;
     }
   this.m_amount=(uint)copied;
   for(int i=0;i<copied;i++)
      if((long)ticks_array[i].time_msc>=date_from && this.CreateNewTickObj(ticks_array[i])!=NULL)
         this.m_last_time=ticks_array[i].time_msc;
   if(this.m_last_time==0 && copied>0)
      this.m_last_time=ticks_array[copied-1].time_msc;   // no tick of the days asked: the next ones come after the newest one
   ::Print("MY DEBUG    CTickSeriesDE::Create: ",this.m_symbol,": ",this.DataTotal()," ticks in RAM of the ",copied," copied from ",::TimeToString(date),
           " (",this.m_required," days, at most ",TICKSERIES_MAX_DATA_TOTAL,"), took ",::GetTickCount64()-debug_ms," ms");
   return this.DataTotal();
  }
 //+------------------------------------------------------------------+
 //| Update the tick series list: the ticks after the last one. The    |
 //| first call copies the days asked (DoEasy Create at OnInit; here   |
 //| at the first call, CopyTicksRange may wait for the server)        |
 //+------------------------------------------------------------------+
 bool CTickSeriesDE::RefreshSeries(void)
  {
   this.SetEventFlag(false);
   this.GetListEvents().Clear();
   const bool new_tick=this.m_new_tick_obj.IsNewTick();
   this.RelayEvents(&this.m_new_tick_obj);
   if(this.m_last_time==0)
      return(this.Create()>0);
   if(!new_tick)
      return false;
   MqlTick ticks_array[];
   int total=::CopyTicksRange(this.m_symbol,ticks_array,COPY_TICKS_ALL,this.m_last_time+1,0);
   int added=0;
   for(int i=0;i<total;i++)
     {
      if(this.CreateNewTickObj(ticks_array[i])==NULL)
         break;
      this.m_last_time=ticks_array[i].time_msc;
      added++;
     }
   //--- More than the maximum: the oldest go (DoEasy deleted Delete(j) for j<n, every second one, as the list moves up)
   if(this.DataTotal()>TICKSERIES_MAX_DATA_TOTAL)
      this.m_list_ticks.DeleteRange(0,this.DataTotal()-TICKSERIES_MAX_DATA_TOTAL-1);
   return(added>0);
  }
 //+------------------------------------------------------------------+
 //| Create a new tick data object                                    |
 //+------------------------------------------------------------------+
 CTick *CTickSeriesDE::CreateNewTickObj(const MqlTick &tick)
  {
   CTick *tick_obj=new CTick(this.m_symbol,tick);
   if(tick_obj==NULL)
      return NULL;
   if(!this.m_list_ticks.Add(tick_obj))
     {
      delete tick_obj;
      return NULL;
     }
   return tick_obj;
  }
 //+------------------------------------------------------------------+
 //| Return the last tick object of a time in milliseconds (the list   |
 //| is by time: binary search)                                        |
 //+------------------------------------------------------------------+
 CTick *CTickSeriesDE::GetTick(const ulong time_msc)
  {
   int low=0,high=this.m_list_ticks.Total()-1,found=WRONG_VALUE;
   while(low<=high)
     {
      int middle=(low+high)/2;
      CTick *tick=this.m_list_ticks.At(middle);
      if(tick==NULL)
         return NULL;
      if((ulong)tick.TimeMSC()<=time_msc)
        {
         if((ulong)tick.TimeMSC()==time_msc)
            found=middle;
         low=middle+1;
        }
      else
         high=middle-1;
     }
   return(found==WRONG_VALUE ? NULL : this.m_list_ticks.At(found));
  }
 //+------------------------------------------------------------------+
 //| The events of a child go to the list of this object               |
 //+------------------------------------------------------------------+
 bool CTickSeriesDE::RelayEvents(CBaseObjExt *child)
  {
   CArrayObj *events=(child!=NULL && child.IsEvent() ? child.GetListEvents() : NULL);
   for(int i=0;events!=NULL && i<events.Total();i++)
     {
      CEventBaseObj *event=events.At(i);
      if(event!=NULL && this.EventAdd((ushort)event.ID(),event.LParam(),event.DParam(),event.SParam()))
         this.SetEventFlag(true);
     }
   return this.IsEvent();
  }
#endif // CTICKSERIESDE_MQH_IMPLEMENTATION
#endif // __TICKSERIESDE_MQH__
