//+------------------------------------------------------------------+
//|                                            SignalsCollection.mqh |
//| Use m_account_key in CDatabaseService to Join 2 Database On RAM  |
//| Create table SignalsCollection  by CIndicatorsCollection         |
//| Update table SignalsCollection in Account Database               |
//+------------------------------------------------------------------+
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
    CBarTimeSeriesCollection *m_BarTimeSeriesCollection;   // the EA holds it: the bars the signals are found on, the id of a symbol
    CSymbolTFManager         *m_SymbolTFManager;           // the EA holds it: the pairs the library keeps up to date (Setting_SymbolTF)
    CSyncManager             *m_SyncManager;               // the EA holds it: what was synced and up to where (Setting_Sync)
    CIndicatorTemplateManager *m_IndicatorTemplateManager;   // the EA holds it: the templates whose signals are found
    CIndicatorsCollection *m_IndicatorsCollection;   // the EA holds it: the indicator of a template on a pair (type + params, never the handle): its buffers in RAM
    CArrayObj         m_list_series;             // the series (CSignalSeriesDE, owned): one for each template on each pair of Setting_SymbolTF
   //--- The series of a template on a pair: (1) the one in the list, (2) made and added (its judge, the file of the account)
    CSignalSeriesDE  *Read_RAM(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
    CSignalSeriesDE  *Create_RAM(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- (1) every template on a pair, (2) a template on every pair (as CIndicatorsCollection)
    void              Create_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              Create_RAM(const ENUM_INDICATOR type,const string params_text);
   //--- The series of (1) a template, (2) a pair go
    void              Delete_RAM(const ENUM_INDICATOR type,const string params_text);
    void              Delete_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The new bars of every pair of a symbol: each series of the pair judges itself, its events go out, what is new on the newest closed bar is told
   //--- (as CBarTimeSeriesCollection::RefreshTimeseries_). False when the call had its share of time
    bool              RefreshTimeseries(CBarTimeSeriesDE *timeseries,const ulong started);
   public:
    void              SetBarTimeSeriesCollection(CBarTimeSeriesCollection *collection) { this.m_BarTimeSeriesCollection=collection; }
   //--- The series of the templates on the pairs (CSignalSeriesDE): their rows on RAM are read by the views (CBarMarkerCollection)
    CArrayObj        *GetList(void)                                                    { return &this.m_list_series; }
    void              SetSymbolTFManager(CSymbolTFManager *manager)                   { this.m_SymbolTFManager=manager; }
    void              SetSyncManager(CSyncManager *manager)                           { this.m_SyncManager=manager; }
    void              SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
    void              SetIndicatorsCollection(CIndicatorsCollection *collection)      { this.m_IndicatorsCollection=collection; }   //--- Lifecycle: opens the file of the account and makes SignalsCollection (the flips: pair, type and params of the indicator, open time of the bar, side).
   //--- A table of progress of an EA before Setting_Sync is moved to it
    bool              OnInitEvent(void);
   //--- A chart change (REASON_CHARTCHANGE): RAM keeps the rows of the bars of each series of the pairs only, what a view read before them goes (it reads it again)
    void              OnDeinitEvent(const int reason);
   //--- Python wrote its part (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), a pair or a template was added or deleted
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- The new bars of the pairs of Setting_SymbolTF (the series of CBarTimeSeriesCollection), each series judges itself: the rows and the marks wait in RAM.
   //--- As CBarTimeSeriesCollection: (1) every symbol (tester), (2) a symbol (the chart's: OnTick), (3) every symbol but the chart's (OnTimer). Called after the same
   //--- Refresh of CBarTimeSeriesCollection: the bars have the newest closed one
    void              RefreshSeries(void);
    void              RefreshSeries(const string symbol);
    void              RefreshSeriesAllExceptCurrent(void);
   //--- The rows of the bars of (1) every pair, (2) one pair go to RAM, each series reads its own: after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE). Event: SERIES_EVENTS_SIGNAL ALL of the pair
    bool              ReadDataFromDB(void);
    bool              ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The rows of every series of a pair from_time to to_time go to RAM next to what is there (CBarMarkerCollection asks it). Returns the rows added
    int               ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time);
   //--- What waits in RAM goes to the table, then its marks (rows first): (1) every pair, (2) one pair. True when nothing waits
    bool              UpdateDataToDB(void);
    bool              UpdateDataToDB(const string symbol,const ENUM_TIMEFRAMES timeframe); 
                      CSignalsCollection(void) : m_BarTimeSeriesCollection(NULL),m_SymbolTFManager(NULL),m_SyncManager(NULL),m_IndicatorTemplateManager(NULL),
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
 void CSignalsCollection::OnDeinitEvent(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE || this.m_BarTimeSeriesCollection==NULL)
      return;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL)
         continue;
      CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(series.Symbol(),series.Timeframe());
      CBar *oldest=(bars!=NULL && bars.GetList().Total()>0 ? bars.GetList().At(0) : NULL);
      if(oldest!=NULL)
         series.DeleteRows(oldest.Time());
     }
  }
 bool CSignalsCollection::OnInitEvent(void)
  {
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
 CSignalSeriesDE *CSignalsCollection::Read_RAM(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.IsOf(type,params_text,symbol,timeframe))
         return series;
     }
   return NULL;
  }
 CSignalSeriesDE *CSignalsCollection::Create_RAM(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CSignalSeriesDE *series=this.Read_RAM(type,params_text,symbol,timeframe);
   if(series!=NULL)
      return series;
   series=new CSignalSeriesDE();
   if(series==NULL)
      return NULL;
   series.SetSeries(type,params_text,symbol,timeframe);
   if(!series.IsFound() || !this.m_list_series.Add(series))
     {
      delete series;   // not a standard indicator: no judge
      return NULL;
     }
   series.SetIndicatorTemplateManager(this.m_IndicatorTemplateManager);   // it judges and writes its own rows
   series.SetSyncObject(this.m_object_type);
   series.SetSyncManager(this.m_SyncManager);
   return series;
  }
 void CSignalsCollection::Create_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_INDICATOR types[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.Read_RAM(types,texts,buy,sell);
   for(int t=0;t<templates;t++)
      this.Create_RAM(types[t],texts[t],symbol,timeframe);
  }
 void CSignalsCollection::Create_RAM(const ENUM_INDICATOR type,const string params_text)
  {
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.Create_RAM(type,params_text,symbols[i],timeframes[i]);
  }
 void CSignalsCollection::Delete_RAM(const ENUM_INDICATOR type,const string params_text)
  {
   for(int i=this.m_list_series.Total()-1;i>=0;i--)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.TypeIndicator()==type && series.ParamsText()==params_text)
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
   if(this.m_SymbolTFManager==NULL)
      return false;
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   bool done=true;
   for(int i=0;i<pairs;i++)
      done=this.ReadDataFromDB(symbols[i],timeframes[i]) && done;
   return done;
  }
 bool CSignalsCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return false;
   CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(symbol,timeframe);
   CArrayObj *list_bars=(bars!=NULL ? bars.GetList() : NULL);
   if(list_bars==NULL || list_bars.Total()==0)
      return false;
   int made=0,loaded=0;
   bool done=true;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
         continue;
      made++;
      int rows=series.ReadDataFromDB(list_bars);
      done=(rows>=0 && done);
      loaded+=(rows>0 ? rows : 0);
     }
   ::Print("Complete ",__FUNCTION__," > ",symbol," ",this.m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)timeframe),": ",loaded," rows of SignalsCollection read for the ",made," templates of the pair, on the ",
           list_bars.Total()," bars of the series");
   return done;
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
      bool budget=false;   // this call has had its share: the rest of the pair is judged at the next ones
      for(int s=0;s<this.m_list_series.Total();s++)
        {
         CSignalSeriesDE *series=this.m_list_series.At(s);
         if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
            continue;
         if(series.JudgedTo()==last_closed)
            continue;   // each tick comes here: nothing to judge
         if(::GetTickCount64()-started>BAR_UPDATE_BUDGET_MS)
           {
            budget=true;
            break;
           }
         CIndicatorDE *indicator=this.m_IndicatorsCollection.Read_RAM(series.TypeIndicator(),series.ParamsText(),symbol,timeframe);
         series.Calculate(indicator,bars.GetList());   // not ready: the next call tries again
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
      this.Create_RAM(sparam,(ENUM_TIMEFRAMES)lparam);   // its rows: Python runs again, then PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE
      return true;
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
      this.Create_RAM((ENUM_INDICATOR)lparam,sparam);   // its rows: Python runs again, then PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE
      return true;
     }
   if(id!=CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      return false;
   this.Delete_RAM((ENUM_INDICATOR)lparam,sparam);   // its rows and its marks: the Current worker of Python (CPythonBridge tells it)
   ::Print("Complete ",__FUNCTION__," > the template ",::EnumToString((ENUM_INDICATOR)lparam)," (",sparam,") was deleted: Python deletes its signals");
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
   if(this.m_SymbolTFManager==NULL)
      return false;
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   bool done=true;
   for(int i=0;i<pairs;i++)
      done=this.UpdateDataToDB(symbols[i],timeframes[i]) && done;
   return done;
  }
 //+------------------------------------------------------------------+
 //| The rows of every series of a pair, from_time to to_time          |
 //+------------------------------------------------------------------+
 int CSignalsCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time)
  {
   if(this.m_SyncManager==NULL || !this.m_SyncManager.IsPythonDone())
      return 0;   // Python writes the pairs now (as CBarControl::ReadDataFromDB): read after PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE
   int loaded=0;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CSignalSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.Symbol()==symbol && series.Timeframe()==timeframe)
         loaded+=::MathMax(series.ReadDataFromDB(from_time,to_time),0);
     }
   return loaded;
  }
 //+------------------------------------------------------------------+
 //| The signals on RAM of the series of the pair                     |
 //+------------------------------------------------------------------+
#endif // CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#endif // __SIGNALSCOLLECTION_MQH__
