//+------------------------------------------------------------------+
//|                                              SignalsCollection.mqh |
//|  V2 name kept: the signals of the indicators, now with history   |
//+------------------------------------------------------------------+
//--- The signals of the indicator templates on the bars: the bar where the signal of a template changes to Buy or Sell. It OWNS one table of the account
//--- (SignalsCollection), apart from the ones of the bars (CBarTimeSeriesCollection); what was synced and up to where is CSyncManager's. As CBarTimeSeriesCollection:
//--- the collection holds the series (CSignalSeriesDE: one template on one pair), each series judges its new bars itself and tells its rows (SERIES_EVENTS_SIGNAL),
//--- the collection relays the events to the chart and tells the alert. MT5 calculates the indicator, the series reads its buffers in RAM (CIndicatorSeriesDE);
//--- Python signals.py says the same. What shows it (CBarMarkerSync) asks here. A template that is added is calculated from the start (Python the history, the library
//--- the new bars), the rows of a template that is deleted stay (its id is never given again; only the templates the user has are shown).
//--- Live on RAM, saved on the DB: only the rows that were told wait in RAM, UpdateDataToDB writes them when the pair is handed over (SYMBOLTF_MANAGER_EVENT_DELETE)
//--- and at OnDeinit; the view reads the table UNION what waits. Every hand starts after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
#ifndef __SIGNALSCOLLECTION_MQH__
#define __SIGNALSCOLLECTION_MQH__
 #include "..\Services\DELib\DatabaseService.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "BarTimeSeriesCollection.mqh"
 #include "IndicatorsCollection.mqh"
 #include "Settings\SyncManager.mqh"
 #include "Settings\IndicatorTemplateManager.mqh"
 #include "..\Entities\Signals\SignalSeriesDE.mqh"
#ifndef CSIGNALSCOLLECTION_MQH_DECLARATION
#define CSIGNALSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The signals of the indicator templates, history and new bars     |
 //+------------------------------------------------------------------+
 class CSignalsCollection : public CBaseObj
  {
   private:
   CDatabaseService *m_CDatabaseService;        // The EA holds it
    CBarTimeSeriesCollection *m_BarTimeSeriesCollection;   // the EA holds it: the bars the signals are found on, the id of a symbol
    CSymbolTFManager  *m_SymbolTFManager;        // the EA holds it: the pairs the library keeps up to date (Setting_SymbolTF)
    CSyncManager      *m_SyncManager;            // the EA holds it: what was synced and up to where (Setting_Sync)
    CIndicatorTemplateManager *m_IndicatorTemplateManager;   // the EA holds it: the templates whose signals are found
    CIndicatorsCollection *m_IndicatorsCollection;   // the EA holds it: the indicator of a template on a pair (type + params, never the handle): its buffers in RAM
    CArrayObj         m_list_series;             // the series (CSignalSeriesDE, owned): one for each template on each pair of Setting_SymbolTF
   //--- The series of a template on a pair: (1) the one in the list, (2) made and added (its judge, the file of the account)
    CSignalSeriesDE  *Read_RAM(const long template_id,const string symbol,const ENUM_TIMEFRAMES timeframe);
    CSignalSeriesDE  *Create_RAM(const long template_id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- (1) every template on a pair, (2) a template on every pair (as CIndicatorsCollection)
    void              Create_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              Create_RAM(const ENUM_INDICATOR type,const string params_text);
   //--- The series of (1) a template, (2) a pair go
    void              Delete_RAM(const long template_id);
    void              Delete_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The events of a series go to the chart once (its list is emptied)
    void              SendEvents(CSignalSeriesDE *series);
   //--- The new bars of every pair of a symbol: each series of the pair judges itself, its events go out, what is new on the newest closed bar is told
   //--- (as CBarTimeSeriesCollection::RefreshTimeseries_). False when the call had its share of time
    bool              RefreshTimeseries(CBarTimeSeriesDE *timeseries,const ulong started);
   //--- A template that was deleted: its signals and its marks go (the ids wait here, a step at each beat: CSyncManager does the step)
    long              m_reset_ids[];
    void              Reset(const ulong started);
   //--- What is new on a pair at its newest closed bar is told once, for the templates whose alert is on (and when the pair has the alert on too)
    void              AlertOnPair(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &templates[],const int &sides[]);
   public:
    void              SetDatabaseService(CDatabaseService *databaseService)           { this.m_CDatabaseService=databaseService; }
   void              SetBarTimeSeriesCollection(CBarTimeSeriesCollection *collection) { this.m_BarTimeSeriesCollection=collection; }
    void              SetSymbolTFManager(CSymbolTFManager *manager)                   { this.m_SymbolTFManager=manager; }
    void              SetSyncManager(CSyncManager *manager)                           { this.m_SyncManager=manager; }
    void              SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
    void              SetIndicatorsCollection(CIndicatorsCollection *collection)      { this.m_IndicatorsCollection=collection; }   //--- Lifecycle: opens the file of the account and makes SignalsCollection (the flips: pair, template id, open time of the bar, side). template_id is the id of the row
   //--- of Setting_IndicatorTemplate, never given again. A table of progress of an EA before Setting_Sync is moved to it
    bool              OnInitEvent(void);
   //--- Python wrote its part (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), a pair or a template was added or deleted
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- The rhythm of the EA: a step of the delete of the signals of a deleted template (the table)
    void              OnTimerEvent(void);
   //--- The new bars of the pairs of Setting_SymbolTF (the series of CBarTimeSeriesCollection), each series judges itself: the rows and the marks wait in RAM.
   //--- As CBarTimeSeriesCollection: (1) every symbol (tester), (2) a symbol (the chart's: OnTick), (3) every symbol but the chart's (OnTimer). Called after the same
   //--- Refresh of CBarTimeSeriesCollection: the bars have the newest closed one
    void              RefreshSeries(void);
    void              RefreshSeries(const string symbol);
    void              RefreshSeriesAllExceptCurrent(void);
   //--- The rows of the table of the bars of (1) every pair, (2) one pair go to RAM, one query for a pair (the rows waiting stay): after Python
   //--- (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), a template or a pair added. Event: SERIES_EVENTS_SIGNAL ALL of the pair
    bool              ReadDataFromDB(void);
    bool              ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- What waits in RAM goes to the table, then its marks (rows first): (1) every pair, (2) one pair. True when nothing waits
    bool              UpdateDataToDB(void);
    bool              UpdateDataToDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- What the markers of a pair show: the signals (bar time, side) of the templates whose Buy / Sell ids are given, from from_time to to_time (the table UNION RAM)
    int               ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,const long &buy_templates[],
                                             const long &sell_templates[],long &times[],long &sides[]);
   //--- What was found in a candle of the chart: the signals of the templates asked (the TF of the row, template id, open time of its bar, side) of the TFs asked
   //--- (the caller gives its pairs of Setting_SymbolTF), in the bars from from_time to before to_time, the longest TF first. Both sides: what the user shows on the chart
   //--- is not asked here. The table UNION RAM
    int               ReadDataFromDB(const string symbol,const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_templates[],
                                                   long &tfs[],long &templates[],long &times[],long &sides[]);
                      CSignalsCollection(void) : m_CDatabaseService(NULL),m_BarTimeSeriesCollection(NULL),m_SymbolTFManager(NULL),m_SyncManager(NULL),m_IndicatorTemplateManager(NULL),
                                                 m_IndicatorsCollection(NULL) { this.m_object_type=COLLECTION_SIGNALS_ID; }
                     ~CSignalsCollection(void) {}
  };
#endif // CSIGNALSCOLLECTION_MQH_DECLARATION
#ifndef CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#define CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The tables of the signals (the file Account of CDatabaseService).|
 //| The tables of an EA before the rename (IndicatorSignalSeries) are |
 //| renamed, their rows stay                                         |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::OnInitEvent(void)
  {
   // New In V4 after implemenation CDatabaseService
   //--- As CIndicatorsCollection: a series for every template on every pair. Its table is CIndicatorTemplateManager's, the rows go to RAM after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE: ReadDataFromDB)
   if(this.m_SymbolTFManager==NULL || this.m_IndicatorTemplateManager==NULL)
      return false;
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.Create_RAM(symbols[i],timeframes[i]);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The series of a template on a pair                                |
 //+------------------------------------------------------------------+
 CSignalSeriesDE *CSignalsCollection::Read_RAM(const long template_id,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.IsOf(template_id,symbol,timeframe))
         return series;
     }
   return NULL;
  }
 CSignalSeriesDE *CSignalsCollection::Create_RAM(const long template_id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CSignalSeriesDE *series=this.Read_RAM(template_id,symbol,timeframe);
   if(series!=NULL)
      return series;
   series=new CSignalSeriesDE();
   if(series==NULL)
      return NULL;
   series.SetSeries(template_id,type,params_text,symbol,timeframe);
   if(!series.IsFound() || !this.m_list_series.Add(series))
     {
      delete series;   // not a standard indicator: no judge
      return NULL;
     }
   series.SetDatabase(this.m_IndicatorTemplateManager,this.m_object_type,this.m_SyncManager);   // it judges and writes its own rows
   return series;
  }
 void CSignalsCollection::Create_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   long ids[];
   ENUM_INDICATOR types[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.Read_RAM(ids,types,texts,buy,sell);
   for(int t=0;t<templates;t++)
      this.Create_RAM(ids[t],types[t],texts[t],symbol,timeframe);
  }
 void CSignalsCollection::Create_RAM(const ENUM_INDICATOR type,const string params_text)
  {
   long ids[];
   ENUM_INDICATOR types[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.Read_RAM(ids,types,texts,buy,sell);
   long id=0;
   for(int t=0;t<templates;t++)
      if(types[t]==type && texts[t]==params_text)
         id=ids[t];
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.Create_RAM(id,type,params_text,symbols[i],timeframes[i]);
  }
 void CSignalsCollection::Delete_RAM(const long template_id)
  {
   for(int i=this.m_list_series.Total()-1;i>=0;i--)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.TemplateID()==template_id)
         this.m_list_series.Delete(i);
     }
  }
 void CSignalsCollection::Delete_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=this.m_list_series.Total()-1;i>=0;i--)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.Symbol()==symbol && series.Timeframe()==timeframe)
         this.m_list_series.Delete(i);
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the bars of the pairs go to RAM                       |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::ReadDataFromDB(void)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return false;
   bool done=true;
   CArrayObj *list=this.m_BarTimeSeriesCollection.GetList();
   for(int i=0;i<list.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=list.At(i);
      CArrayObj *list_series=(timeseries!=NULL ? timeseries.GetListSeries() : NULL);
      for(int j=0;list_series!=NULL && j<list_series.Total();j++)
        {
         CBarSeriesDE *series=list_series.At(j);
         if(series!=NULL)
            done=this.ReadDataFromDB(series.Symbol(),series.Timeframe()) && done;
        }
     }
   return done;
  }
 bool CSignalsCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.m_BarTimeSeriesCollection==NULL || this.m_IndicatorTemplateManager==NULL || this.m_SyncManager==NULL)
      return false;
   if(!this.m_SyncManager.IsPythonDone())
      return false;   // Python has not done its part of the pairs yet: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE reads it
   CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(symbol,timeframe);
   CArrayObj *list_bars=(bars!=NULL ? bars.GetList() : NULL);
   if(list_bars==NULL || list_bars.Total()==0)
      return false;
   CBar *oldest=list_bars.At(0);
   CBar *newest=list_bars.At(list_bars.Total()-1);
   if(oldest==NULL || newest==NULL)
      return false;
   long templates[],times[],sides[];
   int total=this.m_IndicatorTemplateManager.ReadDataFromDB(symbol,timeframe,oldest.Time(),newest.Time(),templates,times,sides);
   if(total==WRONG_VALUE)
      return false;
   int made=0,loaded=0;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
         continue;
      long series_times[],series_sides[];
      int n=0;
      for(int r=0;r<total;r++)
         if(templates[r]==series.TemplateID())
           {
            ::ArrayResize(series_times,n+1,256);
            ::ArrayResize(series_sides,n+1,256);
            series_times[n]=times[r];
            series_sides[n]=sides[r];
            n++;
           }
      made++;
      int rows=series.ReadDataFromDB(list_bars,series_times,series_sides);
      loaded+=(rows>0 ? rows : 0);
     }
   ::Print("Complete ",__FUNCTION__," > ",symbol," ",this.m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)timeframe),": ",loaded," rows of SignalsCollection read for the ",made," templates of the pair, on the ",
           list_bars.Total()," bars of the series");
   ::EventChartCustom(::ChartID(),(ushort)SERIES_EVENTS_SIGNAL,SERIES_EVENTS_PATTERN_ALL,(double)timeframe,symbol);   // what the chart shows of the pair is made again
   return true;
  }
 //+------------------------------------------------------------------+
 //| The new bars of the pairs: every symbol, a symbol, every symbol   |
 //| but the chart's (as CBarTimeSeriesCollection::RefreshSeries). A   |
 //| call does BAR_UPDATE_BUDGET_MS of it at most                      |
 //+------------------------------------------------------------------+
 void CSignalsCollection::RefreshSeries(void)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return;
   ulong started=::GetTickCount64();
   CArrayObj *list=this.m_BarTimeSeriesCollection.GetList();
   for(int i=0;i<list.Total();i++)
      if(!this.RefreshTimeseries(list.At(i),started))
         return;   // this call has had its share: the rest is done at the next ones
  }
 void CSignalsCollection::RefreshSeries(const string symbol)
  {
   if(this.m_BarTimeSeriesCollection!=NULL)
      this.RefreshTimeseries(this.m_BarTimeSeriesCollection.GetTimeseries(symbol),::GetTickCount64());
  }
 void CSignalsCollection::RefreshSeriesAllExceptCurrent(void)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return;
   ulong started=::GetTickCount64();
   CArrayObj *list=this.m_BarTimeSeriesCollection.GetList();
   for(int i=0;i<list.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=list.At(i);
      if(timeseries==NULL || timeseries.Symbol()==::Symbol())
         continue;   // the chart's symbol follows its ticks (OnTick)
      if(timeseries.IsPaused())
         continue;   // the symbol rests (TICK_EVENT_PAUSE): no new bar to judge
      if(!this.RefreshTimeseries(timeseries,started))
         return;
     }
  }
 //+------------------------------------------------------------------+
 //| The rhythm of the EA: what waits from the beats before            |
 //+------------------------------------------------------------------+
 void CSignalsCollection::OnTimerEvent(void)
  {
   if(this.m_SyncManager==NULL)
      return;
   this.Reset(::GetTickCount64());   // a template that was deleted: a step of its signals in the table, every pair
  }
 //+------------------------------------------------------------------+
 //| The new bars of every pair of a symbol: each series of the pair   |
 //| judges itself (RAM only), its events go out                       |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::RefreshTimeseries(CBarTimeSeriesDE *timeseries,const ulong started)
  {
   if(timeseries==NULL || this.m_SyncManager==NULL || this.m_IndicatorsCollection==NULL)
      return true;
   if(!this.m_SyncManager.IsPythonDone())
      return false;   // Python Current writes the pairs of Setting_SymbolTF now: one writer for a pair at a time
   CArrayObj *list=timeseries.GetListSeries();
   for(int i=0;i<list.Total();i++)
     {
      CBarSeriesDE *bars=list.At(i);
      if(bars==NULL)
         continue;
      const string symbol=bars.Symbol();
      const ENUM_TIMEFRAMES timeframe=bars.Timeframe();
      datetime last_closed=::iTime(symbol,timeframe,1);
      if(last_closed==0)
         continue;
      int judged=0,judged_before=0,not_ready=0,rows=0,total=0;   // MY DEBUG
      bool budget=false;   // this call has had its share: the rest of the pair is judged at the next ones
      long alert_ids[];   // the templates whose signal was found on the newest closed bar, and the sides (1 Buy, 2 Sell)
      int  alert_sides[];
      for(int s=0;s<this.m_list_series.Total();s++)
        {
         CSignalSeriesDE *series=this.m_list_series.At(s);
         if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
            continue;
         total++;
         if(series.JudgedTo()==last_closed)
           {
            judged_before++;   // each tick comes here: nothing to judge
            continue;
           }
         if(::GetTickCount64()-started>BAR_UPDATE_BUDGET_MS)
           {
            budget=true;
            break;
           }
         CIndicatorDE *indicator=this.m_IndicatorsCollection.Read_RAM(series.TypeIndicator(),series.ParamsText(),symbol,timeframe);
         int found=series.Calculate(indicator,bars.GetList());
         if(found<0)
           {
            not_ready++;   // the next call tries again
            continue;
           }
         judged++;
         rows+=found;
         if(!series.IsEvent())
            continue;
         this.SendEvents(series);   // RAM changed: the rows are told (SERIES_EVENTS_SIGNAL), the view reads the table UNION RAM
         int bits=series.RowsOfBar(last_closed);   // what is new on the newest bar can be told
         if(bits!=0)
           {
            int n=::ArraySize(alert_ids);
            ::ArrayResize(alert_ids,n+1);
            ::ArrayResize(alert_sides,n+1);
            alert_ids[n]=series.TemplateID();
            alert_sides[n]=bits;
           }
        }
      if(::ArraySize(alert_ids)>0)
         this.AlertOnPair(symbol,timeframe,last_closed,alert_ids,alert_sides);
      if(total==0)
         continue;
      //--- MY DEBUG once per pair, closed bar and outcome (the call repeats on each tick / beat while a series is not ready)
      static string debug_keys[];
      string debug_pair=symbol+" "+::EnumToString(timeframe);
      string debug_outcome=(budget ? "not finished: the budget of the call is used, the rest next call" : not_ready==0 ? "finished" : "not finished: judged again next call");
      string debug_key=debug_pair+" "+::TimeToString(last_closed)+" "+debug_outcome;
      int debug_index=-1;
      for(int k=0;k<::ArraySize(debug_keys);k++)
         if(::StringFind(debug_keys[k],debug_pair+" ")==0)
            debug_index=k;
      if(debug_index<0 || debug_keys[debug_index]!=debug_key)
        {
         if(debug_index<0)
           {
            debug_index=::ArraySize(debug_keys);
            ::ArrayResize(debug_keys,debug_index+1);
           }
         debug_keys[debug_index]=debug_key;
         ::Print("MY DEBUG    CSignalsCollection::RefreshSeries: ",debug_pair,", closed bar ",::TimeToString(last_closed),": ",judged," of the ",total," templates judged now (",rows,
                 " rows), ",judged_before," judged before, ",not_ready," not ready (no progress row of Python, more missing than the series, or no values of the indicator in RAM); ",
                 debug_outcome);
        }
      if(budget)
         return false;   // this call has had its share: the rest is done at the next ones
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| A pair or a template added or deleted, Python wrote more          |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- Python wrote the first chunk of every pair (CSyncManager has read its marks already): the series and the rows go to RAM again
   if(id==CHARTEVENT_CUSTOM+PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
      return this.ReadDataFromDB();
   //--- A pair: lparam = its TF, sparam = its symbol (CBarTimeSeriesCollection made its series already)
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
     {
      this.Create_RAM(sparam,(ENUM_TIMEFRAMES)lparam);
      return this.ReadDataFromDB(sparam,(ENUM_TIMEFRAMES)lparam);
     }
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      if(!this.UpdateDataToDB(sparam,(ENUM_TIMEFRAMES)lparam))   // handed over to Python Live: what waits is written first
         ::Print(__FUNCTION__," > ",sparam," ",this.m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)lparam),": what waited was not written (the database is busy): Python judges these bars again");
      this.Delete_RAM(sparam,(ENUM_TIMEFRAMES)lparam);
      return true;
     }
   //--- A template was added: its series are made on every pair (they wait for the progress of Python)
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      this.Create_RAM((ENUM_INDICATOR)lparam,sparam);
      return this.ReadDataFromDB();
     }
   if(id!=CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE || dparam<=0)
      return false;
   long template_id=(long)dparam;
   this.Delete_RAM(template_id);
   for(int k=0;k<::ArraySize(this.m_reset_ids);k++)
      if(this.m_reset_ids[k]==template_id)
         return true;
   ::ArrayResize(this.m_reset_ids,::ArraySize(this.m_reset_ids)+1);
   this.m_reset_ids[::ArraySize(this.m_reset_ids)-1]=template_id;
   ::Print("Complete ",__FUNCTION__," > the template ",template_id," was deleted: its signals go");
   return true;
  }
 //+------------------------------------------------------------------+
 //| What waits in RAM goes to the DB: the rows of every series of the |
 //| pair, then the marks of the pair                                  |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::UpdateDataToDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.m_SyncManager==NULL || this.m_BarTimeSeriesCollection==NULL)
      return false;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
         continue;
      if(!series.UpdateDataToDB())
         return false;   // the database is busy: what waits stays, the marks too (they go after their rows)
     }
   return this.m_SyncManager.UpdateDataToDB(this.m_object_type,symbol,timeframe);
  }
 bool CSignalsCollection::UpdateDataToDB(void)
  {
   bool done=true;
   string done_keys[];   // the pairs written already
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL)
         continue;
      string key=series.Symbol()+" "+(string)(int)series.Timeframe();
      bool there=false;
      for(int k=0;k<::ArraySize(done_keys) && !there;k++)
         there=(done_keys[k]==key);
      if(there)
         continue;
      ::ArrayResize(done_keys,::ArraySize(done_keys)+1);
      done_keys[::ArraySize(done_keys)-1]=key;
      done=this.UpdateDataToDB(series.Symbol(),series.Timeframe()) && done;
     }
   return done;
  }
 //+------------------------------------------------------------------+
 //| The events of a series go to the chart once                       |
 //+------------------------------------------------------------------+
 void CSignalsCollection::SendEvents(CSignalSeriesDE *series)
  {
   CArrayObj *events=(series!=NULL && series.IsEvent() ? series.GetListEvents() : NULL);
   for(int i=0;events!=NULL && i<events.Total();i++)
     {
      CEventBaseObj *event=events.At(i);
      if(event!=NULL)
         ::EventChartCustom(::ChartID(),(ushort)event.ID(),event.LParam(),event.DParam(),event.SParam());   // the parent and the siblings hear it
     }
   if(series!=NULL)
     {
      series.GetListEvents().Clear();
      series.SetEventFlag(false);
     }
  }
 //+------------------------------------------------------------------+
 //| A step of the delete of the signals of the first template waiting |
 //+------------------------------------------------------------------+
 void CSignalsCollection::Reset(const ulong started)
  {
   while(::ArraySize(this.m_reset_ids)>0)
     {
      if(!this.m_SyncManager.ResetStep("SignalsCollection","template_id",this.m_object_type,this.m_reset_ids[0],started,BAR_UPDATE_BUDGET_MS))
         return;
      ::Print("Complete ",__FUNCTION__," > the signals and the marks of the template ",this.m_reset_ids[0]," are gone");
      ::ArrayRemove(this.m_reset_ids,0,1);
     }
  }
 //+------------------------------------------------------------------+
 //| The alert of the signals found on a pair: a template tells when   |
 //| its alert is on and the pair has the same alert on; one line      |
 //+------------------------------------------------------------------+
 void CSignalsCollection::AlertOnPair(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &templates[],const int &sides[])
  {
   if(this.m_IndicatorTemplateManager==NULL || this.m_SymbolTFManager==NULL)
      return;
   const bool pair_sound=this.m_SymbolTFManager.Read_RAM(symbol,timeframe,"sound_alert");
   const bool pair_message=this.m_SymbolTFManager.Read_RAM(symbol,timeframe,"message_alert");
   if(!pair_sound && !pair_message)
      return;
   long alert_ids[];
   string alert_names[];
   bool template_sound[],template_message[];
   int total=this.m_IndicatorTemplateManager.Read_RAM(alert_ids,alert_names,template_sound,template_message);
   string names[];
   int told[];
   bool sound=false,message=false;
   for(int i=0;i<::ArraySize(templates);i++)
      for(int k=0;k<total;k++)
         if(alert_ids[k]==templates[i])
           {
            bool by_sound=(template_sound[k] && pair_sound),by_message=(template_message[k] && pair_message);
            if(!by_sound && !by_message)
               continue;
            sound=(sound || by_sound);
            message=(message || by_message);
            int n=::ArraySize(names);
            ::ArrayResize(names,n+1);
            ::ArrayResize(told,n+1);
            names[n]=alert_names[k];
            told[n]=sides[i];
           }
   AlertNewOnPair(symbol,this.m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)timeframe),bar,names,told,sound,message);
  }
 //+------------------------------------------------------------------+
 //| The signals of the indicator templates the markers show          |
 //+------------------------------------------------------------------+
 int CSignalsCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,const long &buy_templates[],
                                                const long &sell_templates[],long &times[],long &sides[])
  {
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   // New In V4 after implemenation CDatabaseService
   if(this.m_IndicatorTemplateManager==NULL)
      return 0;
   int total=this.m_IndicatorTemplateManager.ReadDataFromDB(symbol,timeframe,from_time,to_time,buy_templates,sell_templates,times,sides);
   //--- UNION what was found and is not written yet (the series of the pair, the templates asked for the side)
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || series.Timeframe()!=timeframe || series.Symbol()!=symbol)
         continue;
      long p_times[],p_sides[];
      int pending=series.PendingRows(from_time,to_time,p_times,p_sides);
      for(int p=0;p<pending;p++)
        {
         const bool buy=(p_sides[p]==(long)SIGNAL_DIRECTION_BUY);
         bool asked=false;
         for(int k=0;k<(buy ? ::ArraySize(buy_templates) : ::ArraySize(sell_templates)) && !asked;k++)
            asked=((buy ? buy_templates[k] : sell_templates[k])==series.TemplateID());
         bool there=false;
         for(int k=0;k<total && !there && asked;k++)
            there=(times[k]==p_times[p] && sides[k]==p_sides[p]);
         if(!asked || there)
            continue;
         ::ArrayResize(times,total+1);
         ::ArrayResize(sides,total+1);
         times[total]=p_times[p];
         sides[total]=p_sides[p];
         total++;
        }
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The signals found in a candle, the TFs asked                      |
 //+------------------------------------------------------------------+
 int CSignalsCollection::ReadDataFromDB(const string symbol,const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_templates[],
                                                      long &tfs[],long &templates[],long &times[],long &sides[])
  {
   ::ArrayResize(tfs,0);
   ::ArrayResize(templates,0);
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   // New In V4 after implemenation CDatabaseService
   if(this.m_IndicatorTemplateManager==NULL)
      return 0;
   int total=this.m_IndicatorTemplateManager.ReadDataFromDB(symbol,asked_tfs,from_time,to_time,asked_templates,BAR_CANDLE_ROWS_MAX,tfs,templates,times,sides);
   //--- UNION what was found and is not written yet, each row in its place (the longest TF first, then the time)
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || series.Symbol()!=symbol)
         continue;
      bool tf_asked=false,template_asked=false;
      for(int k=0;k<::ArraySize(asked_tfs) && !tf_asked;k++)
         tf_asked=(asked_tfs[k]==(long)series.Timeframe());
      for(int k=0;k<::ArraySize(asked_templates) && !template_asked;k++)
         template_asked=(asked_templates[k]==series.TemplateID());
      if(!tf_asked || !template_asked)
         continue;
      long p_times[],p_sides[];
      int pending=series.PendingRows(from_time,to_time-1,p_times,p_sides);
      for(int p=0;p<pending;p++)
        {
         bool there=false;
         for(int k=0;k<total && !there;k++)
            there=(tfs[k]==(long)series.Timeframe() && templates[k]==series.TemplateID() && times[k]==p_times[p] && sides[k]==p_sides[p]);
         if(there)
            continue;
         int at=total;   // the place of the row: after the rows of a longer TF, and of the same TF at the same time or before
         while(at>0 && (tfs[at-1]<(long)series.Timeframe() || (tfs[at-1]==(long)series.Timeframe() && times[at-1]>p_times[p])))
            at--;
         ::ArrayResize(tfs,total+1);
         ::ArrayResize(templates,total+1);
         ::ArrayResize(times,total+1);
         ::ArrayResize(sides,total+1);
         for(int k=total;k>at;k--)
           {
            tfs[k]=tfs[k-1];
            templates[k]=templates[k-1];
            times[k]=times[k-1];
            sides[k]=sides[k-1];
           }
         tfs[at]=(long)series.Timeframe();
         templates[at]=series.TemplateID();
         times[at]=p_times[p];
         sides[at]=p_sides[p];
         total++;
        }
     }
   return total;
  }
#endif // CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#endif // __SIGNALSCOLLECTION_MQH__
