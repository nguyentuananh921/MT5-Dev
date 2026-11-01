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
//--- Live on RAM, saved on the DB: only the rows that were told wait in RAM, SyncDataToDB writes them when the pair is handed over (SYMBOLTF_MANAGER_EVENT_DELETE)
//--- and at OnDeinit; the view reads the table UNION what waits. Every hand starts after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
#ifndef __SIGNALSCOLLECTION_MQH__
#define __SIGNALSCOLLECTION_MQH__
 #include "..\Services\LibDatabase.mqh"
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
    int               m_db;                      // the file of the account: its tables are asked here, nothing is copied
    CBarTimeSeriesCollection *m_BarTimeSeriesCollection;   // the EA holds it: the bars the signals are found on, the id of a symbol
    CSymbolTFManager  *m_SymbolTFManager;        // the EA holds it: the pairs the library keeps up to date (Setting_SymbolTF)
    CSyncManager      *m_SyncManager;            // the EA holds it: what was synced and up to where (Setting_Sync)
    CIndicatorTemplateManager *m_IndicatorTemplateManager;   // the EA holds it: the templates whose signals are found
    CIndicatorsCollection *m_IndicatorsCollection;   // the EA holds it: the indicator of a template on a pair (type + params, never the handle): its buffers in RAM
    CArrayObj         m_list_series;             // the series (CSignalSeriesDE, owned): one for each template on each pair of Setting_SymbolTF
   //--- The series of a template on a pair: (1) the one in the list, (2) made and added (its judge, the file of the account)
    CSignalSeriesDE  *GetSeries(const long template_id,const string symbol,const ENUM_TIMEFRAMES timeframe);
    CSignalSeriesDE  *CreateSeries(const long template_id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe,const long symbol_id);
   //--- The series of (1) a template, (2) a pair go
    void              DeleteSeries(const long template_id);
    void              DeleteSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The events of a series go to the chart once (its list is emptied)
    void              SendEvents_SignalsCollection(CSignalSeriesDE *series);
   //--- The new bars of every pair of a symbol: each series of the pair judges itself, its events go out, what is new on the newest closed bar is told
   //--- (as CBarTimeSeriesCollection::RefreshTimeseries_). False when the call had its share of time
    bool              RefreshTimeseries_SignalsCollection(CBarTimeSeriesDE *timeseries,const ulong started);
   //--- A table of the old name becomes the one of the new name, its rows stay
    void              Rename_SignalsCollection(const string old_name,const string new_name);
   //--- A template that was deleted: its signals and its marks go (the ids wait here, a step at each beat: CSyncManager does the step)
    long              m_reset_ids[];
    void              Reset_SignalsCollection(const ulong started);
   //--- What is new on a pair at its newest closed bar is told once, for the templates whose alert is on (and when the pair has the alert on too)
    void              Alert_SignalsCollection(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &templates[],const int &sides[]);
   public:
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
   //--- The series of every template on (1) every pair, (2) one pair are made and the rows of the table of the bars go to RAM (the rows waiting stay): after Python
   //--- (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), a template or a pair added. Event: SERIES_EVENTS_SIGNAL ALL of the pair
    bool              SyncDataFromDB(void);
    bool              SyncDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- What waits in RAM goes to the table, then its marks (rows first): (1) every pair, (2) one pair. True when nothing waits
    bool              SyncDataToDB(void);
    bool              SyncDataToDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- What the markers of a pair show: the signals (bar time, side) of the templates whose Buy / Sell ids are given, from from_time to to_time (the table UNION RAM)
    int               Read_SignalsCollection(const long symbol_id,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,const long &buy_templates[],
                                             const long &sell_templates[],long &times[],long &sides[]);
   //--- What was found in a candle of the chart: the signals of the templates asked (the TF of the row, template id, open time of its bar, side) of the TFs asked
   //--- (the caller gives its pairs of Setting_SymbolTF), in the bars from from_time to before to_time, the longest TF first. Both sides: what the user shows on the chart
   //--- is not asked here. The table UNION RAM
    int               ReadCandle_SignalsCollection(const long symbol_id,const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_templates[],
                                                   long &tfs[],long &templates[],long &times[],long &sides[]);
                      CSignalsCollection(void) : m_db(INVALID_HANDLE),m_BarTimeSeriesCollection(NULL),m_SymbolTFManager(NULL),m_SyncManager(NULL),m_IndicatorTemplateManager(NULL),
                                                 m_IndicatorsCollection(NULL) { this.m_type=COLLECTION_SIGNALS_ID; }
                     ~CSignalsCollection(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
  };
#endif // CSIGNALSCOLLECTION_MQH_DECLARATION
#ifndef CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#define CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The tables of the signals (the file of LibDatabase_AccountFile).  |
 //| The tables of an EA before the rename (IndicatorSignalSeries) are |
 //| renamed, their rows stay                                         |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::OnInitEvent(void)
  {
   if(m_db != INVALID_HANDLE)
      return true;   // a CHARTCHANGE reinit keeps the database open
   m_db = LibDatabase_OpenAccount(DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
   if(m_db == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the database ", LibDatabase_AccountFile(), " is not opened, error ", ::GetLastError());
     return false;
    }
   ::DatabaseExecute(m_db, "PRAGMA busy_timeout="+(string)LIB_DATABASE_BUSY_MS);
   ::DatabaseExecute(m_db, "PRAGMA journal_mode=WAL");
   this.Rename_SignalsCollection("IndicatorSignalSeries","SignalsCollection");
   this.Rename_SignalsCollection("Sync_IndicatorSignalSeries","Sync_SignalsCollection");
   const bool table_was_there=LibDatabase_TableExists(m_db,"SignalsCollection");
   //--- The older column side is renamed: the rows stay
   if(LibDatabase_ColumnExists(m_db,"SignalsCollection","side"))
      ::DatabaseExecute(m_db, "ALTER TABLE SignalsCollection RENAME COLUMN side TO signal_direction");
   if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS SignalsCollection (symbol_id INTEGER NOT NULL, tf_enum INTEGER NOT NULL, "
                               "template_id INTEGER NOT NULL, bar_time INTEGER NOT NULL, signal_direction INTEGER NOT NULL, "
                               "PRIMARY KEY (symbol_id, tf_enum, template_id, bar_time, signal_direction)) WITHOUT ROWID"))
    {
     ::Print(__FUNCTION__, " > the table SignalsCollection is not made, error ", ::GetLastError());
     return false;
    }
   //--- The table was not there (deleted, or the file is new): what was marked as synced for it is not true any more, Python makes the first chunk again
   if(!table_was_there && this.m_SyncManager!=NULL)
      this.m_SyncManager.ResetObject_SyncManager(this.m_type);
   if(this.m_SyncManager!=NULL)
      this.m_SyncManager.Import_SyncManager(m_db,"Sync_SignalsCollection","template_id",this.m_type);
   ::Print("Complete ", __FUNCTION__, " > ", LibDatabase_AccountFile(), " opened");
   return true;   // the series and their rows go to RAM after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE: SyncDataFromDB)
  }
 //+------------------------------------------------------------------+
 //| A table of the old name becomes the table of the new one: the    |
 //| rows stay (nothing is copied or deleted), only when the new one  |
 //| is not there yet                                                 |
 //+------------------------------------------------------------------+
 void CSignalsCollection::Rename_SignalsCollection(const string old_name,const string new_name)
  {
   int request=::DatabasePrepare(m_db,"SELECT (SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '"+old_name+"'), "
                                      "(SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '"+new_name+"')");
   if(request==INVALID_HANDLE)
      return;
   long has_old=0,has_new=0;
   if(::DatabaseRead(request))
     {
      ::DatabaseColumnLong(request,0,has_old);
      ::DatabaseColumnLong(request,1,has_new);
     }
   ::DatabaseFinalize(request);
   if(has_old==1 && has_new==0 && !::DatabaseExecute(m_db,"ALTER TABLE "+old_name+" RENAME TO "+new_name))
      ::Print("MY DEBUG    CSignalsCollection::Rename_SignalsCollection the table ",old_name," is not renamed, error ",::GetLastError());
  }
 //+------------------------------------------------------------------+
 //| The series of a template on a pair                                |
 //+------------------------------------------------------------------+
 CSignalSeriesDE *CSignalsCollection::GetSeries(const long template_id,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.IsOf(template_id,symbol,timeframe))
         return series;
     }
   return NULL;
  }
 CSignalSeriesDE *CSignalsCollection::CreateSeries(const long template_id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe,
                                                   const long symbol_id)
  {
   CSignalSeriesDE *series=this.GetSeries(template_id,symbol,timeframe);
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
   series.SetDatabase(m_db,symbol_id,this.m_type,this.m_SyncManager);   // it judges and writes its own rows
   return series;
  }
 void CSignalsCollection::DeleteSeries(const long template_id)
  {
   for(int i=this.m_list_series.Total()-1;i>=0;i--)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.TemplateID()==template_id)
         this.m_list_series.Delete(i);
     }
  }
 void CSignalsCollection::DeleteSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=this.m_list_series.Total()-1;i>=0;i--)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.Symbol()==symbol && series.Timeframe()==timeframe)
         this.m_list_series.Delete(i);
     }
  }
 //+------------------------------------------------------------------+
 //| The series of every template on the pairs and their rows go to    |
 //| RAM (the templates are asked here, never on a tick)               |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::SyncDataFromDB(void)
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
            done=this.SyncDataFromDB(series.Symbol(),series.Timeframe()) && done;
        }
     }
   return done;
  }
 bool CSignalsCollection::SyncDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(m_db==INVALID_HANDLE || this.m_BarTimeSeriesCollection==NULL || this.m_IndicatorTemplateManager==NULL || this.m_SyncManager==NULL)
      return false;
   if(!this.m_SyncManager.IsPythonDone())
      return false;   // Python has not done its part of the pairs yet: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE reads it
   CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(symbol,timeframe);
   long symbol_id=(bars!=NULL ? bars.SymbolID() : 0);
   if(bars==NULL || symbol_id==0)
      return false;
   long ids[];
   ENUM_INDICATOR kinds[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.TemplateIds(ids,kinds,texts,buy,sell);
   int made=0,loaded=0;
   for(int t=0;t<templates;t++)
     {
      CSignalSeriesDE *series=this.CreateSeries(ids[t],kinds[t],texts[t],symbol,timeframe,symbol_id);
      if(series==NULL)
         continue;
      made++;
      int rows=series.SyncDataFromDB(bars.GetList());
      loaded+=(rows>0 ? rows : 0);
     }
   ::Print("Complete ",__FUNCTION__," > ",symbol," ",this.m_SymbolTFManager.TimeframeName(timeframe),": ",loaded," rows of SignalsCollection read for the ",made," templates of the pair, on the ",
           bars.GetList().Total()," bars of the series");
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
      if(!this.RefreshTimeseries_SignalsCollection(list.At(i),started))
         return;   // this call has had its share: the rest is done at the next ones
  }
 void CSignalsCollection::RefreshSeries(const string symbol)
  {
   if(this.m_BarTimeSeriesCollection!=NULL)
      this.RefreshTimeseries_SignalsCollection(this.m_BarTimeSeriesCollection.GetTimeseries(symbol),::GetTickCount64());
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
      if(!this.RefreshTimeseries_SignalsCollection(timeseries,started))
         return;
     }
  }
 //+------------------------------------------------------------------+
 //| The rhythm of the EA: what waits from the beats before            |
 //+------------------------------------------------------------------+
 void CSignalsCollection::OnTimerEvent(void)
  {
   if(m_db==INVALID_HANDLE || this.m_SyncManager==NULL)
      return;
   this.Reset_SignalsCollection(::GetTickCount64());   // a template that was deleted: a step of its signals in the table, every pair
  }
 //+------------------------------------------------------------------+
 //| The new bars of every pair of a symbol: each series of the pair   |
 //| judges itself (RAM only), its events go out                       |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::RefreshTimeseries_SignalsCollection(CBarTimeSeriesDE *timeseries,const ulong started)
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
         CIndicatorDE *indicator=this.m_IndicatorsCollection.GetIndicator(series.TypeIndicator(),series.ParamsText(),symbol,timeframe);
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
         this.SendEvents_SignalsCollection(series);   // RAM changed: the rows are told (SERIES_EVENTS_SIGNAL), the view reads the table UNION RAM
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
         this.Alert_SignalsCollection(symbol,timeframe,last_closed,alert_ids,alert_sides);
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
      return this.SyncDataFromDB();
   //--- A pair: lparam = its TF, sparam = its symbol (CBarTimeSeriesCollection made its series already)
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
      return this.SyncDataFromDB(sparam,(ENUM_TIMEFRAMES)lparam);
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      if(!this.SyncDataToDB(sparam,(ENUM_TIMEFRAMES)lparam))   // handed over to Python Live: what waits is written first
         ::Print(__FUNCTION__," > ",sparam," ",this.m_SymbolTFManager.TimeframeName((ENUM_TIMEFRAMES)lparam),": what waited was not written (the database is busy): Python judges these bars again");
      this.DeleteSeries(sparam,(ENUM_TIMEFRAMES)lparam);
      return true;
     }
   //--- A template was added: its series are made on every pair (they wait for the progress of Python)
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
      return this.SyncDataFromDB();
   if(id!=CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE || dparam<=0)
      return false;
   long template_id=(long)dparam;
   this.DeleteSeries(template_id);
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
 bool CSignalsCollection::SyncDataToDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(m_db==INVALID_HANDLE || this.m_SyncManager==NULL || this.m_BarTimeSeriesCollection==NULL)
      return false;
   long symbol_id=this.m_BarTimeSeriesCollection.SymbolID(symbol);
   if(symbol_id==0)
      return false;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
         continue;
      if(!series.SyncDataToDB())
         return false;   // the database is busy: what waits stays, the marks too (they go after their rows)
     }
   return this.m_SyncManager.SyncDataToDB(this.m_type,symbol_id,timeframe);
  }
 bool CSignalsCollection::SyncDataToDB(void)
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
      done=this.SyncDataToDB(series.Symbol(),series.Timeframe()) && done;
     }
   return done;
  }
 //+------------------------------------------------------------------+
 //| The events of a series go to the chart once                       |
 //+------------------------------------------------------------------+
 void CSignalsCollection::SendEvents_SignalsCollection(CSignalSeriesDE *series)
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
 void CSignalsCollection::Reset_SignalsCollection(const ulong started)
  {
   while(::ArraySize(this.m_reset_ids)>0)
     {
      if(!this.m_SyncManager.ResetStep_SyncManager(m_db,"SignalsCollection","template_id",this.m_type,this.m_reset_ids[0],started,BAR_UPDATE_BUDGET_MS))
         return;
      ::Print("Complete ",__FUNCTION__," > the signals and the marks of the template ",this.m_reset_ids[0]," are gone");
      ::ArrayRemove(this.m_reset_ids,0,1);
     }
  }
 //+------------------------------------------------------------------+
 //| The alert of the signals found on a pair: a template tells when   |
 //| its alert is on and the pair has the same alert on; one line      |
 //+------------------------------------------------------------------+
 void CSignalsCollection::Alert_SignalsCollection(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &templates[],const int &sides[])
  {
   if(this.m_IndicatorTemplateManager==NULL || this.m_SymbolTFManager==NULL)
      return;
   const bool pair_sound=this.m_SymbolTFManager.SoundAlert(symbol,timeframe);
   const bool pair_message=this.m_SymbolTFManager.MessageAlert(symbol,timeframe);
   if(!pair_sound && !pair_message)
      return;
   long alert_ids[];
   string alert_names[];
   bool template_sound[],template_message[];
   int total=this.m_IndicatorTemplateManager.AlertTemplates(alert_ids,alert_names,template_sound,template_message);
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
   AlertNewOnPair(symbol,this.m_SymbolTFManager.TimeframeName(timeframe),bar,names,told,sound,message);
  }
 //+------------------------------------------------------------------+
 //| The signals of the indicator templates the markers show          |
 //+------------------------------------------------------------------+
 int CSignalsCollection::Read_SignalsCollection(const long symbol_id,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,const long &buy_templates[],
                                                const long &sell_templates[],long &times[],long &sides[])
  {
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   if(m_db==INVALID_HANDLE)
      return 0;
   int request=::DatabasePrepare(m_db,"SELECT bar_time, signal_direction FROM SignalsCollection WHERE symbol_id = "+(string)symbol_id+" AND tf_enum = "+(string)(int)timeframe+
                                      " AND bar_time >= "+(string)(long)from_time+" AND bar_time <= "+(string)(long)to_time+" AND ((signal_direction = "+(string)(int)SIGNAL_DIRECTION_BUY+" AND template_id IN ("+LibDatabase_InList(buy_templates)+")) OR "
                                      "(signal_direction = "+(string)(int)SIGNAL_DIRECTION_SELL+" AND template_id IN ("+LibDatabase_InList(sell_templates)+")))");
   if(request==INVALID_HANDLE)
      return 0;
   int total=0;
   while(::DatabaseRead(request))
     {
      ::ArrayResize(times,total+1);
      ::ArrayResize(sides,total+1);
      ::DatabaseColumnLong(request,0,times[total]);
      ::DatabaseColumnLong(request,1,sides[total]);
      total++;
     }
   ::DatabaseFinalize(request);
   //--- UNION what was found and is not written yet (the series of the pair, the templates asked for the side)
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || series.Timeframe()!=timeframe || this.m_BarTimeSeriesCollection==NULL || this.m_BarTimeSeriesCollection.SymbolID(series.Symbol())!=symbol_id)
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
 int CSignalsCollection::ReadCandle_SignalsCollection(const long symbol_id,const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_templates[],
                                                      long &tfs[],long &templates[],long &times[],long &sides[])
  {
   ::ArrayResize(tfs,0);
   ::ArrayResize(templates,0);
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   if(m_db==INVALID_HANDLE)
      return 0;
   int request=::DatabasePrepare(m_db,"SELECT tf_enum, template_id, bar_time, signal_direction FROM SignalsCollection WHERE symbol_id = "+(string)symbol_id+" AND tf_enum IN ("+LibDatabase_InList(asked_tfs)+
                                      ") AND template_id IN ("+LibDatabase_InList(asked_templates)+") AND bar_time >= "+(string)(long)from_time+" AND bar_time < "+(string)(long)to_time+
                                      " ORDER BY tf_enum DESC, bar_time LIMIT "+(string)BAR_CANDLE_ROWS_MAX);
   if(request==INVALID_HANDLE)
     {
      ::Print("MY DEBUG    CSignalsCollection::ReadCandle_SignalsCollection the query is not accepted, error ",::GetLastError());
      return 0;
     }
   int total=0;
   while(::DatabaseRead(request))
     {
      long tf=0,template_id=0,time=0,side=0;
      ::DatabaseColumnLong(request,0,tf);
      ::DatabaseColumnLong(request,1,template_id);
      ::DatabaseColumnLong(request,2,time);
      ::DatabaseColumnLong(request,3,side);
      ::ArrayResize(tfs,total+1);
      ::ArrayResize(templates,total+1);
      ::ArrayResize(times,total+1);
      ::ArrayResize(sides,total+1);
      tfs[total]=tf;
      templates[total]=template_id;
      times[total]=time;
      sides[total]=side;
      total++;
     }
   ::DatabaseFinalize(request);
   //--- UNION what was found and is not written yet, each row in its place (the longest TF first, then the time)
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || this.m_BarTimeSeriesCollection==NULL || this.m_BarTimeSeriesCollection.SymbolID(series.Symbol())!=symbol_id)
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
