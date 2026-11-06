//+------------------------------------------------------------------+
//|                                                  BarSeriesDE.mqh |
//|Change from SeriesDE.mqh                                          |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __BARSERIESDE_MQH__
#define __BARSERIESDE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Defines\CommonDefines.mqh"
 #include "..\Defines\BarDefines.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include "NewBarObj.mqh"
 #include "..\Bar\Bar.mqh"
 #include "BarControl.mqh"
 #include "..\Bases\BaseObjExt.mqh"
 #include "..\..\Services\DELib\CommonDELib.mqh"
 #include "..\..\Collections\Settings\SyncManager.mqh"
 #ifndef EA_STORE_BARS
  #define EA_STORE_BARS               (true) // the bars go to BarSeriesDE (the EA tells it in its Configuration: false = none is kept)
 #endif
#ifndef CBARSERIESDE_MQH_DECLARATION
#define CBARSERIESDE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Timeseries class                                                 |
 //+------------------------------------------------------------------+
 //class CBarSeriesDE : public CBaseObj
 class CBarSeriesDE : public CBaseObjExt
  {
   private:
    CBar              m_bar_tmp;                                         // Bar object for search
    ENUM_TIMEFRAMES   m_timeframe;                                       // Timeframe
    string            m_symbol;                                          // Symbol
    datetime          m_firstdate;                                       // The very first date by a period symbol at the moment
    datetime          m_lastbar_date;                                    // Time of opening the last bar by period symbol
    uint              m_amount;                                          // Amount of applied timeseries data
    uint              m_required;                                        // Required amount of applied timeseries data
    uint              m_bars;                                            // Number of bars in history by symbol and timeframe
    bool              m_sync;                                            // Synchronized data flag
    CArrayObj         m_list_Table_BarSeriesDE;                          // Timeseries list: the bars, the oldest first
    CNewBarObj        m_new_bar_obj;                                     // "New bar" object
    datetime          m_bars_in_table;                                   // RAM only: the newest closed bar whose bars are in the table BarSeriesDE
    CBarControl       m_BarControl;                                      // What is found on the bars of this series: it judges, keeps the rows and writes them (V2: m_patterns_control)
   //Add db in V4
    CBarInformationManager *m_BarInformationManager;                     // The EA holds it: its tables of the account
   //--- Set the very first date by a period symbol at the moment and the new time of opening the last bar by a period symbol
    void              SetServerDate(void);
   //--- The newest bar of the pair in BarSeriesDE (0: Python has not taken its first chunk yet), and the closed bars after from_time written there
    datetime          ReadNewestBar(void);
    bool              AddBars(const datetime from_time);
   public:
    CArrayObj        *GetList(void)                                      { return &m_list_Table_BarSeriesDE;         }
    CNewBarObj       *GetNewBarObj(void)                                 { return &this.m_new_bar_obj;    }
   //--- What is found on the bars (the rows, what waits, what the view reads): CBarControl (V2: GetPatternsCtrlObj)
    CBarControl      *GetBarControl(void)                                { return &this.m_BarControl;     }
   //--- What the series and its control need: the file of the account, the id of the symbol, the collection, the managers (CBarTimeSeriesCollection::CreateSeries)
    void              SetDatabase(const long sync_object,CSyncManager *sync,CBarInformationManager *information);
   //--- The rows of the table of the bars the series holds go to RAM (CBarControl::ReadDataFromDB: as Create for the bars of MT5, once at the creation,
   //--- then when Python tells it wrote more: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE). Event: SERIES_EVENTS_PATTERN_ALL
    bool              ReadDataFromDB(void);
   //--- The new closed bars go to BarSeriesDE, then the rows waiting and their progress (CBarControl::UpdateDataToDB). True when nothing waits.
   //--- When the pair is handed over to Python Live (it leaves Setting_SymbolTF) and at OnDeinit. No event: the view sees the same (the table UNION RAM)
    bool              UpdateDataToDB(void);
   //--- The events of the control go to the list of this object (the parent reads it): true when it has any
    bool              RelayEvents(void);
   //--- Set the (1) symbol, (2) timeframe, (3) symbol and timeframe
    void              SetSymbol(const string symbol,const bool set_server_date=false);
    void              SetTimeframe(const ENUM_TIMEFRAMES timeframe,const bool set_server_date=false);
    void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- Set the amount of applied timeseries data (0 = the default amount)
    bool              SetRequiredUsedData(const uint required,const uint rates_total);
    string            Symbol(void)                                          const { return this.m_symbol;                            }
    ENUM_TIMEFRAMES   Timeframe(void)                                       const { return this.m_timeframe;                         }
    ulong             AvailableUsedData(void)                               const { return this.m_amount;                            }
    ulong             RequiredUsedData(void)                                const { return this.m_required;                          }
    ulong             Bars(void)                                            const { return this.m_bars;                              }
    datetime          FirstDate(void)                                       const { return this.m_firstdate;                         }
    datetime          LastBarDate(void)                                     const { return this.m_lastbar_date;                      }
    int               DataTotal(void)                                       const { return this.m_list_Table_BarSeriesDE.Total();               }
    datetime          BarsInTable(void)                                     const { return this.m_bars_in_table;                     }
    void              SetBarsInTable(const datetime time)                         { this.m_bars_in_table=time;                       }
   //--- The "New bar" flag: true once for a new bar (Refresh adds the bar to the list first)
    bool              IsNewBar(void)                                              { return this.m_new_bar_obj.IsNewBar();            }
   //--- Return the bar object by (1) a real index in the list, (2) an index as in the timeseries, (3) time
    CBar             *GetBarByListIndex(const uint index);
    CBar             *GetBar(const uint index);
    CBar             *GetBar(const datetime time);
   //--- Synchronize the symbol and timeframe data with the server data
    bool              SyncData(const uint required);
   //--- (1) Create and (2) update the timeseries list
    int               Create(const uint required=0);    
    bool              RefreshSeries(void);
   //--- Comparison method to search for identical timeseries objects by timeframe
    virtual int       Compare(const CObject *node,const int mode=0) const;
                      CBarSeriesDE(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0);
  };
#endif // CBARSERIESDE_MQH_DECLARATION
#ifndef CBARSERIESDE_MQH_IMPLEMENTATION
#define CBARSERIESDE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor (the specified symbol and timeframe)                 |
 //+------------------------------------------------------------------+
 CBarSeriesDE::CBarSeriesDE(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0) : m_timeframe(PERIOD_CURRENT),m_firstdate(0),m_lastbar_date(0),m_bars(0),m_amount(0),m_required(0),m_sync(false),m_bars_in_table(0),
                                                                                                    m_BarInformationManager(NULL)
  {
   this.m_object_type=OBJECT_DE_TYPE_SERIES_PERIOD;
   this.m_list_Table_BarSeriesDE.Clear();
   this.m_list_Table_BarSeriesDE.Sort(SORT_BY_BAR_TIME);
   this.SetSymbolPeriod(symbol,timeframe);
   this.m_sync=this.SetRequiredUsedData(required,0);
  }
 //+------------------------------------------------------------------+
 //| What the series needs to judge its bars and to write the rows     |
 //+------------------------------------------------------------------+
 void CBarSeriesDE::SetDatabase(const long sync_object,CSyncManager *sync,CBarInformationManager *information)
  {
   this.m_BarInformationManager=information;
   this.m_BarControl.SetDatabase(&this.m_list_Table_BarSeriesDE,this.m_symbol,this.m_timeframe,sync_object,sync,information);
  }
 //+------------------------------------------------------------------+
 //| The rows of the bars the series holds go to RAM: its control does |
 //| it (as SyncData of DoEasy goes down the chain), the series tells   |
 //+------------------------------------------------------------------+
 bool CBarSeriesDE::ReadDataFromDB(void)
  {
   const bool done=this.m_BarControl.ReadDataFromDB();
   this.RelayEvents();
   return done;
  }
 //+------------------------------------------------------------------+
 //| The events of the control go to the list of this object, once    |
 //| (the control's list is emptied: an event is told one time)       |
 //+------------------------------------------------------------------+
 bool CBarSeriesDE::RelayEvents(void)
  {
   CArrayObj *events=(this.m_BarControl.IsEvent() ? this.m_BarControl.GetListEvents() : NULL);
   for(int i=0;events!=NULL && i<events.Total();i++)
     {
      CEventBaseObj *event=events.At(i);
      if(event!=NULL && this.EventAdd((ushort)event.ID(),event.LParam(),event.DParam(),event.SParam()))
         this.SetEventFlag(true);
     }
   this.m_BarControl.GetListEvents().Clear();
   this.m_BarControl.SetEventFlag(false);
   return this.IsEvent();
  }
 //+------------------------------------------------------------------+
 //| The newest bar of the pair that BarSeriesDE holds                 |
 //+------------------------------------------------------------------+
 datetime CBarSeriesDE::ReadNewestBar(void)
  {
   // New In V4 after implemenation CDatabaseService
   return (this.m_BarInformationManager!=NULL ? this.m_BarInformationManager.ReadDataFromDB(this.m_symbol,this.m_timeframe) : 0);
  }
 //+------------------------------------------------------------------+
 //| The closed bars after from_time go to BarSeriesDE                 |
 //+------------------------------------------------------------------+
 bool CBarSeriesDE::AddBars(const datetime from_time)
  {
   if(this.m_list_Table_BarSeriesDE.Total()==0)
      return false;
   datetime forming=0;
   if(!::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_LASTBAR_DATE,forming))
      return false;
   // New In V4 after implemenation CDatabaseService
   MqlRates rates[];
   int digits=0;
   for(int i=0;i<this.m_list_Table_BarSeriesDE.Total();i++)
     {
      CBar *bar=this.m_list_Table_BarSeriesDE.At(i);
      if(bar==NULL || bar.Time()<=from_time || bar.Time()>=forming)
         continue;   // before what is there, or the forming bar
      int n=::ArraySize(rates);
      ::ArrayResize(rates,n+1,100);
      rates[n].time=bar.Time();
      rates[n].open=bar.Open();
      rates[n].high=bar.High();
      rates[n].low=bar.Low();
      rates[n].close=bar.Close();
      rates[n].tick_volume=bar.VolumeTick();
      rates[n].spread=bar.Spread();
      rates[n].real_volume=bar.VolumeReal();
      digits=bar.Digits();
     }
   return (this.m_BarInformationManager!=NULL && this.m_BarInformationManager.UpdateDataToDB(this.m_symbol,this.m_timeframe,rates,digits));
  }
 //+------------------------------------------------------------------+
 //| The new bars, the rows waiting, then their progress go to the DB  |
 //+------------------------------------------------------------------+
 bool CBarSeriesDE::UpdateDataToDB(void)
  {
   if(this.m_BarInformationManager==NULL)
      return false;
   //--- The new closed bars first. The bars of the start are Python's: only the bars after the newest one the table holds (none: Python has not made the first chunk)
   datetime last_closed=::iTime(this.m_symbol,this.m_timeframe,1);
   if(EA_STORE_BARS && last_closed!=0 && this.m_bars_in_table!=last_closed)
     {
      datetime in_table=this.ReadNewestBar();
      if(in_table!=0)
        {
         if(in_table>=last_closed || this.AddBars(in_table))
            this.m_bars_in_table=last_closed;
         else
            return false;   // the database is busy: the next call tries again
        }
     }
   //--- The rows waiting and their progress: the control's
   return this.m_BarControl.UpdateDataToDB();
  }
 int CBarSeriesDE::Compare(const CObject *node,const int mode=0) const
  {
   const CBarSeriesDE *compared_obj=node;
   return(this.Timeframe()>compared_obj.Timeframe() ? 1 : this.Timeframe()<compared_obj.Timeframe() ? -1 : 0);
  }
 void CBarSeriesDE::SetServerDate(void)
  {
   this.m_firstdate=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_FIRSTDATE);
   this.m_lastbar_date=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_LASTBAR_DATE);
  }
 void CBarSeriesDE::SetSymbol(const string symbol,const bool set_server_date=false)
  {
   if(this.m_symbol==symbol)
      return;
   this.m_symbol=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
   this.m_new_bar_obj.SetSymbol(this.m_symbol);
   if(set_server_date)
      this.SetServerDate();
  }
 void CBarSeriesDE::SetTimeframe(const ENUM_TIMEFRAMES timeframe,const bool set_server_date=false)
  {
   if(this.m_timeframe==timeframe)
      return;
   this.m_timeframe=(timeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe);
   this.m_new_bar_obj.SetTimeframe(this.m_timeframe);
   if(set_server_date)
      this.SetServerDate();
  }
 void CBarSeriesDE::SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.m_symbol==symbol && this.m_timeframe==timeframe)
      return;
   this.SetSymbol(symbol);
   this.SetTimeframe(timeframe,true);
  }
 //+------------------------------------------------------------------+
 //| Set the number of required data                                  |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
  //| Set the number of required data                                  |
  //+------------------------------------------------------------------+
  bool CBarSeriesDE::SetRequiredUsedData(const uint required,const uint rates_total)
    {
    this.m_required=(required<1 ? SERIES_DEFAULT_BARS_COUNT : required);
  //--- Launch downloading historical data
    if(this.m_program!=PROGRAM_INDICATOR || (this.m_program==PROGRAM_INDICATOR && (this.m_symbol!=::Symbol() || this.m_timeframe!=::Period())))
      {
        datetime array[1];
        ::CopyTime(this.m_symbol,this.m_timeframe,0,1,array);
      }
  //--- Set the number of available timeseries bars
    this.m_bars=(uint)
      (
        //--- If this is an indicator and the work is performed on the current symbol and timeframe,
        //--- add the rates_total value passed to the method,
        //--- otherwise, get the number from the environment
        this.m_program==PROGRAM_INDICATOR && 
        this.m_symbol==::Symbol() && this.m_timeframe==::Period() ? rates_total : 
        ::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_BARS_COUNT)
      );
  //--- If succeeded to set the number of available history bars, set the amount of data in the list:
    if(this.m_bars>0)
      {
        //--- if zero 'required' value is passed,
        //--- use either the default value (1000 bars) or the number of available history bars - the least one of them
        //--- if non-zero 'required' value is passed,
        //--- use either the 'required' value or the number of available history bars - the least one of them
        this.m_amount=(required==0 ? ::fmin(SERIES_DEFAULT_BARS_COUNT,this.m_bars) : ::fmin(required,this.m_bars));
        return true;
      }
    return false;
    }
 //+------------------------------------------------------------------+
 //| Synchronize the symbol and timeframe data with the server data   |
 //+------------------------------------------------------------------+
 bool CBarSeriesDE::SyncData(const uint required)
  {
   if(!this.m_available)
     {
      ::Print(DFUN,this.m_symbol," ",EnumToString(this.m_timeframe),": the timeseries is not used");
      return false;
     }
   this.m_sync=this.SetRequiredUsedData(required,0);
   if(this.m_sync)
      return true;
  //--- Not synchronized yet: ATTEMPTS_FOR_SYNC attempts, a pause of PAUSE_FOR_SYNC_ATTEMPTS ms between them
   for(int attempts=0; attempts<ATTEMPTS_FOR_SYNC && !::IsStopped(); attempts++)
     {
      if(::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_SYNCHRONIZED))
        {
         this.m_sync=this.SetRequiredUsedData(required,0);
         if(this.m_sync)
            break;
        }
      ::Sleep(PAUSE_FOR_SYNC_ATTEMPTS);
     }
   return this.m_sync;
  }
 //+------------------------------------------------------------------+
 //| Create the timeseries list                                       |
 //+------------------------------------------------------------------+
 int CBarSeriesDE::Create(const uint required=0)
  {
   if(this.m_amount==0)
     {
      ::Print(DFUN,this.m_symbol," ",EnumToString(this.m_timeframe),": set the amount of data first");
      return 0;
     }
   else if(required>0 && this.m_amount!=required && required<this.m_bars)
     {
      if(!this.SetRequiredUsedData(required,0))
         return 0;
     }
  //--- The rates[] array is a timeseries: the newest bar first
   MqlRates rates[];
   ::ArraySetAsSeries(rates,true);
   this.m_list_Table_BarSeriesDE.Clear();
   this.m_list_Table_BarSeriesDE.Sort(SORT_BY_BAR_TIME);
   ::ResetLastError();
   int copied=::CopyRates(this.m_symbol,this.m_timeframe,0,(uint)this.m_amount,rates);
   if(copied<1)
     {
      ::Print(DFUN,"no data of ",this.m_symbol," ",EnumToString(this.m_timeframe),", error ",::GetLastError());
      return 0;
     }
   const int digits=(int)::SymbolInfoInteger(this.m_symbol,SYMBOL_DIGITS);
   for(int i=0; i<copied; i++)
     {
      CBar *bar=new CBar(this.m_symbol,this.m_timeframe,rates[i],digits);
      if(bar==NULL)
         continue;
      if(!this.m_list_Table_BarSeriesDE.Add(bar))
        {
         ::Print(DFUN,"bar ",::TimeToString(rates[i].time)," not added, error ",::GetLastError());
         delete bar;
        }
     }
   this.m_list_Table_BarSeriesDE.Sort(SORT_BY_BAR_TIME);   // rates[] came the newest first and Add() drops the sort: the oldest first again
   return this.m_list_Table_BarSeriesDE.Total();
  }

 bool CBarSeriesDE::RefreshSeries(void)
  {
   this.SetEventFlag(false);
   this.GetListEvents().Clear();
   this.GetListEvents().Sort();   
   bool new_bar=false;
   if(!this.IsAvailable())
    return false;
   //--- The history is not synchronized with the server yet: skip this cycle, the next one retries
    if(!::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_SYNCHRONIZED))
      return false;
   this.m_list_Table_BarSeriesDE.Sort(SORT_BY_BAR_TIME);
   datetime own_bar0=::iTime(this.m_symbol,this.m_timeframe,0);
   if(own_bar0<=0)
      return false;   
   bool current_bar_added=false;
   int  bars_added=0;   // more than one: bars were skipped (V2 BarsBetweenNewBars, counted on the bars MT5 has, not on the time)
   if(this.m_new_bar_obj.IsNewBarManual())
    {
     int period_sec=::PeriodSeconds(this.m_timeframe);
     if(period_sec<=0)
         return false;
      // the list is sorted by time: the last one is the newest
      CBar *last_bar=NULL;
      int total=this.m_list_Table_BarSeriesDE.Total();
      if(total>0)
         last_bar=this.m_list_Table_BarSeriesDE.At(total-1);       
      if(last_bar!=NULL)
        {
         MqlRates fresh_check[1];
         if(::CopyRates(this.m_symbol,this.m_timeframe,1,1,fresh_check)==1 &&
            fresh_check[0].time==last_bar.Time())
            last_bar.SetProperties(fresh_check[0]);
        }
      //--- Every bar between the newest one held and bar 0 is added: the list has no gaps      
      datetime t=(last_bar!=NULL ? last_bar.Time() : own_bar0-period_sec);
      for(t+=period_sec; t<=own_bar0; t+=period_sec)
        {
         if(::iBarShift(this.m_symbol,this.m_timeframe,t,true)<0)
            continue;  // no bar opened at this time (market closed)
         MqlRates bar_rates[1];
         if(::CopyRates(this.m_symbol,this.m_timeframe,t,1,bar_rates)!=1 ||
            bar_rates[0].time!=t)
            continue;

         CBar *new_bar=new CBar(this.m_symbol,this.m_timeframe,bar_rates[0],
                                (int)::SymbolInfoInteger(this.m_symbol,SYMBOL_DIGITS));
         if(new_bar==NULL)
            continue;

         if(!this.m_list_Table_BarSeriesDE.InsertSort(new_bar))
           {
            delete new_bar;
            continue;
           }
         bars_added++;
         if(bar_rates[0].time==own_bar0)
            current_bar_added=true;

         if(this.m_list_Table_BarSeriesDE.Total()>(int)this.m_required)
            this.m_list_Table_BarSeriesDE.Delete(0);
        }
      this.SetServerDate();
      this.m_BarControl.DeleteRows();   // the oldest bars went (m_required): their rows go too
      new_bar=true;
     }
   int total=this.m_list_Table_BarSeriesDE.Total();
   if(total<1)
      return false;
   CBar *bar=this.m_list_Table_BarSeriesDE.At(total-1);
   if(bar==NULL || bar.Time()!=own_bar0)
      return false;
   if(!current_bar_added)
     {
      MqlRates current_bar[1];
      if(::CopyRates(this.m_symbol,this.m_timeframe,0,1,current_bar)!=1 ||
         current_bar[0].time!=bar.Time())
         return false;

      bar.SetProperties(current_bar[0]);
     }
   if(new_bar)
     {
      if(!this.EventAdd((ushort)SERIES_EVENTS_NEW_BAR,
                        (long)this.LastBarDate(),
                        (double)this.Timeframe(),
                        this.Symbol()))
        {
         ::Print(DFUN,"failed to add NewBar event for ",
                 this.Symbol()," ",EnumToString(this.Timeframe()));
         return false;
        }
      if(bars_added>1 && !this.EventAdd((ushort)SERIES_EVENTS_MISSING_BARS,bars_added,(double)this.Timeframe(),this.Symbol()))
         ::Print(DFUN,"failed to add MissingBars event for ",this.Symbol()," ",EnumToString(this.Timeframe()));

      this.SetEventFlag(true);
      this.m_new_bar_obj.SaveNewBarTime();
     }
   //--- The new bars (or the ones not judged yet: Python had not its first chunk) are judged: the rows stay in RAM (the view reads the table UNION RAM).
   //--- They are written when the pair is handed over (it leaves Setting_SymbolTF: Python Live goes on) and at OnDeinit
   if(this.m_BarInformationManager!=NULL && (new_bar || this.m_BarControl.JudgedTo()!=::iTime(this.m_symbol,this.m_timeframe,1)))
     {
      this.m_BarControl.Calculate();
      this.RelayEvents();
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Return the bar object by a real index in the list                |
 //+------------------------------------------------------------------+
 CBar *CBarSeriesDE::GetBarByListIndex(const uint index)
  {
   return this.m_list_Table_BarSeriesDE.At(index);
  }
 //+------------------------------------------------------------------+
 //| Return the bar object by index as in the timeseries (0 = newest) |
 //+------------------------------------------------------------------+
 CBar *CBarSeriesDE::GetBar(const uint index)
  {
   datetime time=::iTime(this.m_symbol,this.m_timeframe,index);
   if(time==0)
      return NULL;
   return this.GetBar(time);
  }
 //+------------------------------------------------------------------+
 //| Return the bar object by time in the timeseries                  |
 //+------------------------------------------------------------------+
 CBar *CBarSeriesDE::GetBar(const datetime time)
  {
   this.m_bar_tmp.SetSymbolPeriod(this.m_symbol,this.m_timeframe,time);
   this.m_list_Table_BarSeriesDE.Sort(SORT_BY_BAR_TIME);
   int index=this.m_list_Table_BarSeriesDE.Search(&this.m_bar_tmp);
   return this.m_list_Table_BarSeriesDE.At(index);
  }
#endif // CBARSERIESDE_MQH_IMPLEMENTATION
#endif // __BARSERIESDE_MQH__
