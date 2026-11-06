//+------------------------------------------------------------------+
//|                                              BarTimeSeriesDE.mqh |
//|Change from TimeSeriesDE.mqh                                      |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __BARTIMESERIESDE_MQH__
#define __BARTIMESERIESDE_MQH__
 #include "BarSeriesDE.mqh"
 #include "..\Ticks\NewTickObj.mqh"
 #define BAR_CANDLE_ROWS_MAX          500   // what the information window of a candle reads at most (a day has 1440 minutes: the window is not a table of the history)
#ifndef CBARTIMESERIESDE_MQH_DECLARATION
#define CBARTIMESERIESDE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Symbol timeseries class                                          |
 //+------------------------------------------------------------------+
 //class CBarTimeSeriesDE : public CBaseObj
 class CBarTimeSeriesDE : public CBaseObjExt
  {
   private:
    string            m_symbol;                // Timeseries symbol
    CArrayObj         m_list_series;           // List of timeseries by timeframes
    CBarInformationManager *m_BarInformationManager;   // The EA holds it: the TFs of the symbol that have no series are read from its table
    CNewTickObj       m_new_tick;              // "New tick" object (DoEasy CTimeSeriesDE): no tick for TICK_PAUSE_SECONDS, the symbol rests
    //--- Return (1) the timeframe index in the list and (2) the timeframe by the list index
     int IndexTimeframe(const ENUM_TIMEFRAMES timeframe);
   public:
    CArrayObj        *GetListSeries(void)                       { return &this.m_list_series; }
   //--- Return the timeseries of a timeframe (NULL when it is not added)
    CBarSeriesDE     *GetSeries(const ENUM_TIMEFRAMES timeframe);
   //--- Set (1) symbol, (2) timeframe, (3) symbol and timeframe, (4) amount of applied timeseries data
    void              SetSymbol(const string symbol,const bool set_server_date=false);
    void              SetTimeframe(const ENUM_TIMEFRAMES timeframe,const bool set_server_date=false);
    void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe);
    bool              SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe, const uint required = 0, const int rates_total = 0);
    string            Symbol(void)                        const { return this.m_symbol; }
   //--- (1) The new tick flag (DoEasy CTimeSeriesDE): it reads the tick and keeps it, so a second call before the next tick returns false; the events of
   //--- m_new_tick (TICK_EVENT_PAUSE / RESUME) go to the list of this object. (2) The symbol rests (no tick for TICK_PAUSE_SECONDS: a closed market)
    bool              IsNewTick(void);
    bool              IsPaused(void)                      const { return this.m_new_tick.IsPaused(); }
   //--- Add the timeseries of a timeframe to the list (true when it is there), synchronize it with the server and create its bars
    bool              AddSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0);
    bool              SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0);
    bool              CreateSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0);
   //--- The rows of the table between RAM and the database, as SyncData: (1) one timeframe, (2) every timeframe. Each CBarSeriesDE does its own
    bool              ReadDataFromDB(const ENUM_TIMEFRAMES timeframe);
    bool              ReadDataFromDB(void);
    bool              UpdateDataToDB(void);
   //--- The series of a timeframe goes (its pair left Setting_SymbolTF: Python Live judges it from now): what waits is written first. True when it is gone
    bool              DeleteSeries(const ENUM_TIMEFRAMES timeframe);
    int               SeriesTotal(void)                   const { return this.m_list_series.Total(); }
   //--- The events of (1) a child (a series, m_new_tick), (2) every series go to the list of this object (the parent reads it): true when it has any
    bool              RelayEvents(CBaseObjExt *child);
    bool              RelayEvents(void);
   //--- The file of the account and the id of the symbol (CBarTimeSeriesCollection::AddSeries_)
    void              SetDatabase(CBarInformationManager *information) { this.m_BarInformationManager=information; }
   //--- What was found in a candle of the chart: the types asked (the TF of the row, type_infor, open time of its bar, side) of the TFs asked (the caller gives
   //--- its pairs of Setting_SymbolTF), from_time to before to_time, the longest TF first: the table UNION what the series of those TFs found and have not written
    int               ReadCandle(const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_types[],
                                                 long &tfs[],long &types[],long &times[],long &sides[]);
   //--- Update the timeseries of a timeframe: true when a new bar was added
    bool              RefreshSeries(const ENUM_TIMEFRAMES timeframe);
   //--- Compare the CBarTimeSeriesDE objects (by symbol)
    virtual int       Compare(const CObject *node,const int mode=0) const;
                      CBarTimeSeriesDE(const string symbol);
  };
#endif // CBARTIMESERIESDE_MQH_DECLARATION
#ifndef CBARTIMESERIESDE_MQH_IMPLEMENTATION
#define CBARTIMESERIESDE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CBarTimeSeriesDE::CBarTimeSeriesDE(const string symbol) : m_symbol(symbol==NULL || symbol=="" ? ::Symbol() : symbol),m_BarInformationManager(NULL)
  {
   this.m_object_type=OBJECT_DE_TYPE_SERIES_SYMBOL;
   this.m_list_series.Clear();
   this.m_new_tick.SetSymbol(this.m_symbol);
   this.m_new_tick.Refresh();
  }
 //+------------------------------------------------------------------+
 //| What was found in a candle: the table UNION RAM, the TFs asked    |
 //+------------------------------------------------------------------+
 int CBarTimeSeriesDE::ReadCandle(const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_types[],
                                                 long &tfs[],long &types[],long &times[],long &sides[])
  {
   ::ArrayResize(tfs,0);
   ::ArrayResize(types,0);
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   // New In V4 after implemenation CDatabaseService
   if(this.m_BarInformationManager==NULL)
      return 0;
   int total=this.m_BarInformationManager.ReadDataFromDB(this.m_symbol,asked_tfs,from_time,to_time,asked_types,BAR_CANDLE_ROWS_MAX,tfs,types,times,sides);
   //--- UNION what the series of the TFs asked found and have not written yet
   for(int j=0;j<this.m_list_series.Total() && total<BAR_CANDLE_ROWS_MAX;j++)
     {
      CBarSeriesDE *series=this.m_list_series.At(j);
      if(series==NULL)
         continue;
      bool tf_asked=false;
      for(int k=0;k<::ArraySize(asked_tfs) && !tf_asked;k++)
         tf_asked=(asked_tfs[k]==(long)series.Timeframe());
      if(!tf_asked)
         continue;
      long p_types[],p_times[],p_sides[];
      int pending=series.GetBarControl().PendingRows(from_time,to_time-1,p_types,p_times,p_sides);   // to_time is out
      for(int p=0;p<pending && total<BAR_CANDLE_ROWS_MAX;p++)
        {
         bool asked=false;
         for(int k=0;k<::ArraySize(asked_types) && !asked;k++)
            asked=(asked_types[k]==p_types[p]);
         bool there=false;
         for(int k=0;k<total && !there && asked;k++)
            there=(tfs[k]==(long)series.Timeframe() && types[k]==p_types[p] && times[k]==p_times[p] && sides[k]==p_sides[p]);
         if(!asked || there)
            continue;
         ::ArrayResize(tfs,total+1);
         ::ArrayResize(types,total+1);
         ::ArrayResize(times,total+1);
         ::ArrayResize(sides,total+1);
         tfs[total]=(long)series.Timeframe();
         types[total]=p_types[p];
         times[total]=p_times[p];
         sides[total]=p_sides[p];
         total++;
        }
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| Return the timeframe index in the list                           |
 //+------------------------------------------------------------------+
 int CBarTimeSeriesDE::IndexTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_TIMEFRAMES tf=(timeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe);
   for(int i=0; i<this.m_list_series.Total(); i++)
     {
      CBarSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.Timeframe()==tf)
         return i;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Set a history depth of a specified timeseries                    |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Set a history depth of a specified timeseries                    |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe, const uint required = 0, const int rates_total = 0)
  {
   if (this.m_symbol == NULL)
   {
      ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_TS_TEXT_FIRST_SET_SYMBOL));
      return false;
   }
   CBarSeriesDE* series_obj = this.m_list_series.At(this.IndexTimeframe(timeframe));
   return series_obj.SetRequiredUsedData(required, rates_total);
  }
 int CBarTimeSeriesDE::Compare(const CObject *node,const int mode=0) const
  {
   const CBarTimeSeriesDE *compared_obj=node;
   return(this.Symbol()>compared_obj.Symbol() ? 1 : this.Symbol()<compared_obj.Symbol() ? -1 : 0);
  }
 //+------------------------------------------------------------------+
 //| Return the timeseries of a timeframe                             |
 //+------------------------------------------------------------------+
 CBarSeriesDE *CBarTimeSeriesDE::GetSeries(const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_TIMEFRAMES tf=(timeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe);
   for(int i=0; i<this.m_list_series.Total(); i++)
     {
      CBarSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.Timeframe()==tf)
         return series;
     }
   return NULL;
  }
 //+------------------------------------------------------------------+
 //| Add the timeseries of a timeframe to the list                    |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::AddSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0)
  {
   if(this.GetSeries(timeframe)!=NULL)
      return true;   // it is there already
   CBarSeriesDE *series=new CBarSeriesDE(this.m_symbol,timeframe,required);
   if(series==NULL)
      return false;
   if(!this.m_list_series.Add(series))
     {
      delete series;
      return false;
     }
   series.SetAvailable(true);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Synchronize the timeseries of a timeframe with the server        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0)
  {
   CBarSeriesDE *series=this.GetSeries(timeframe);
   if(series==NULL)
     {
      ::Print(DFUN,"no timeseries ",this.m_symbol," ",EnumToString(timeframe));
      return false;
     }
   return series.SyncData(required);
  }
 //+------------------------------------------------------------------+
 //| The rows of the table of one timeframe, of every timeframe        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::ReadDataFromDB(const ENUM_TIMEFRAMES timeframe)
  {
   CBarSeriesDE *series=this.GetSeries(timeframe);
   const bool done=(series!=NULL && series.ReadDataFromDB());
   this.RelayEvents(series);
   return done;
  }
 bool CBarTimeSeriesDE::ReadDataFromDB(void)
  {
   bool done=true;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CBarSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL)
         done=series.ReadDataFromDB() && done;
     }
   this.RelayEvents();
   return done;
  }
 bool CBarTimeSeriesDE::UpdateDataToDB(void)
  {
   bool done=true;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CBarSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL)
         done=series.UpdateDataToDB() && done;
     }
   this.RelayEvents();
   return done;
  }
 //+------------------------------------------------------------------+
 //| Create the bars of the timeseries of a timeframe                 |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::CreateSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0)
  {
   CBarSeriesDE *series=this.GetSeries(timeframe);
   if(series==NULL)
     {
      ::Print(DFUN,"no timeseries ",this.m_symbol," ",EnumToString(timeframe));
      return false;
     }
   if(series.RequiredUsedData()==0)
     {
      ::Print(DFUN,"set the amount of data of ",this.m_symbol," ",EnumToString(timeframe)," first");
      return false;
     }
   if(series.Create(required)<=0)
      return false;
   //--- As Create takes the bars from MT5 once, ReadDataFromDB takes the rows of the table of those bars once: a pair added after Python did its part. Before it
   //--- (OnInit) nothing is read: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE reads every pair
   series.ReadDataFromDB();
   this.RelayEvents(series);
   return true;
  }
 bool CBarTimeSeriesDE::RefreshSeries(const ENUM_TIMEFRAMES timeframe)
  {
   this.SetEventFlag(false);
   this.GetListEvents().Clear();
   this.GetListEvents().Sort();

   CBarSeriesDE *series=this.GetSeries(timeframe);
   if(series==NULL || series.DataTotal()==0 || !series.IsAvailable())
      return false;
   if(!series.RefreshSeries())
      return false;
   this.RelayEvents(series);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The series of a timeframe goes: what waits is written first       |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::DeleteSeries(const ENUM_TIMEFRAMES timeframe)
  {
   int index=this.IndexTimeframe(timeframe);
   CBarSeriesDE *series=this.m_list_series.At(index);
   if(series==NULL)
      return false;
   if(!series.UpdateDataToDB())
      ::Print(DFUN,this.m_symbol," ",EnumToString(timeframe),": what waited was not written (the database is busy): Python judges these bars again");
   this.RelayEvents(series);
   return this.m_list_series.Delete(index);
  }
 //+------------------------------------------------------------------+
 //| The events of a series (of every series) go to the list of this   |
 //| object (an event that is there already is not added again)        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::RelayEvents(CBaseObjExt *child)
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
 //+------------------------------------------------------------------+
 //| A new tick of the symbol; its pause / resume go up               |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::IsNewTick(void)
  {
   this.SetEventFlag(false);
   this.GetListEvents().Clear();
   const bool new_tick=this.m_new_tick.IsNewTick();
   this.RelayEvents(&this.m_new_tick);
   return new_tick;
  }
 bool CBarTimeSeriesDE::RelayEvents(void)
  {
   for(int i=0;i<this.m_list_series.Total();i++)
      this.RelayEvents(this.m_list_series.At(i));
   return this.IsEvent();
  }

#endif // CBARTIMESERIESDE_MQH_IMPLEMENTATION
#endif // __BARTIMESERIESDE_MQH__
