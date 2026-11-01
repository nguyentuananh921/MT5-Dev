//+------------------------------------------------------------------+
//|                                       BarTimeSeriesCollection.mqh |
//|  Change from TimeSeriesCollection.mqh                            |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
//--- The bars of every symbol and timeframe: collection > symbol > timeframe > bar. It OWNS two tables of the account (BarSeriesDE and BarTimeSeriesCollection; the signals
//--- of the indicators are CSignalsCollection's, what was synced and up to where is CSyncManager's): it opens the file and makes the tables, each CBarSeriesDE judges its
//--- new bars and writes its own rows (as SyncData of DoEasy), what shows them (CBarMarkerSync) asks here. After OnInit the library keeps the pairs of Setting_SymbolTF
//--- up to date, Python the others.
//--- Methods come from V2 one by one when a class asks
#ifndef __BARTIMESERIESCOLLECTION_MQH__
#define __BARTIMESERIESCOLLECTION_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Services\LibDatabase.mqh"
 #include "ListObj.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Entities\Trading\Symbol.mqh"
 #include "..\Entities\BarSeries\BarTimeSeriesDE.mqh"
 #include "..\Entities\BarSeries\BarControl.mqh"
 #include "SymbolsCollection.mqh"
 #include "Settings\SymbolTFManager.mqh"
 #include "Settings\SyncManager.mqh"
 #include "..\Services\DELib\CommonDELib.mqh"
 #define BAR_UPDATE_BUDGET_MS         40    // what a beat of the timer does at most: the rest is done at the next ones (EA_STORE_BARS: BarSeriesDE.mqh)
#ifndef CBARTIMESERIESCOLLECTION_MQH_DECLARATION
#define CBARTIMESERIESCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Symbol timeseries collection                                     |
 //+------------------------------------------------------------------+
 class CBarTimeSeriesCollection : public CBaseObjExt
  {
   private:
    int                 m_db;                      // the file of the account: its tables are asked here, nothing is copied
    //CArrayObj           m_list_timeseries;       // List of the symbol timeseries (CBarTimeSeriesDE), one for each symbol
    CListObj            m_list_timeseries;         // List of the symbol timeseries (CBarTimeSeriesDE), one for each symbol: each CBarSeriesDE keeps its rows (a CBar each) and judges its bars
    CSymbolsCollection  *m_SymbolsCollection;      // the EA holds it: the id of a symbol (symbol_account)
    CSymbolTFManager    *m_SymbolTFManager;        // the EA holds it: the pairs the library keeps up to date (Setting_SymbolTF)
    CSyncManager        *m_SyncManager;            // the EA holds it: what was synced and up to where (Setting_Sync)
    CBarInformationManager *m_BarInformationManager;   // the EA holds it: the alerts of the types (sound_alert, message_alert); given to every series
    // Need check here
     long                m_reset_types[];           // the types whose parameter changed, waiting to be judged again: their rows go a step at each beat, then their marks (the first one is the one that goes now)
   //--- Return the timeseries index by symbol name
      int                     IndexTimeSeries(const string symbol);
   //--- Return oneself
    CBarTimeSeriesCollection  *GetObject(void)            { return &this;                     }
   //New method in V4 Need check 
    //--- A step of the delete of the rows of the first type that waits (CSyncManager does it: one pair at a time, the mark of a pair goes when it has no row left)
     void              Reset_BarTimeSeriesCollection(const ulong started);
    //--- What is new on a pair at its newest closed bar is told once, for the types whose alert is on (and when the pair has the alert on too)
     void              Alert_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &types[],const int &sides[]);
    //--- The events of the series of a symbol go to the chart once (the parent and the siblings hear them). SERIES_EVENTS_PATTERN of the newest closed bar: its alert goes
     void              SendEvents_BarTimeSeriesCollection(CBarTimeSeriesDE *timeseries);
    //--- Every series of a symbol follows MT5, then its events go to the chart
     void              RefreshTimeseries_BarTimeSeriesCollection(CBarTimeSeriesDE *timeseries);
    //--- A pair of Setting_SymbolTF is (1) made (OnInit, SYMBOLTF_MANAGER_EVENT_ADDED): the library judges it, (2) taken away (SYMBOLTF_MANAGER_EVENT_DELETE): the library
    //--- stops, Python Live judges it from its progress (Setting_SymbolTF is what tells Python)
     bool              AddSeries_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe);
     bool              DeleteSeries_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe);
   public:
    //--- Return the timeseries list (public as in DoEasy CTimeSeriesCollection: CSignalsCollection walks the pairs in RAM)
     CArrayObj        *GetList(void)              { return &this.m_list_timeseries; }
    //Setting Pointer
     void              SetSymbolsCollection(CSymbolsCollection *collection)       { this.m_SymbolsCollection=collection; }
     void              SetSymbolTFManager(CSymbolTFManager *manager)              { this.m_SymbolTFManager=manager;      }
     void              SetSyncManager(CSyncManager *manager)                      { this.m_SyncManager=manager;          }
     void              SetBarInformationManager(CBarInformationManager *manager)  { this.m_BarInformationManager=manager; }
    //--- Create the list: one timeseries object for each symbol of the list (no timeframe is added yet)
     //bool              CreateCollection(const CArrayObj *list_symbols);
     bool              CreateCollection(CSymbolTFManager *manager);   
    //--- Return the timeseries object of (1) a symbol, (2) a symbol and a timeframe
     CBarTimeSeriesDE *GetTimeseries(const string symbol);     CBarSeriesDE     *GetSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
    //--- Set the flag of using (1) the specified timeseries of the specified symbol, (2) the specified timeseries of all symbols
    //--- (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      void                    SetAvailable(const string symbol,const ENUM_TIMEFRAMES timeframe,const bool flag=true);     
      void                    SetAvailable(const ENUM_TIMEFRAMES timeframe,const bool flag=true);
      void                    SetAvailable(const string symbol,const bool flag=true);
      void                    SetAvailable(const bool flag=true);
    //--- Get the flag of using (1) the specified timeseries of the specified symbol, (2) the specified timeseries of all symbols
    //--- (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      bool                    IsAvailable(const string symbol,const ENUM_TIMEFRAMES timeframe);    
      bool                    IsAvailable(const ENUM_TIMEFRAMES timeframe);
      bool                    IsAvailable(const string symbol);
      bool                    IsAvailable(void);
    //--- Add the timeseries of a symbol and a timeframe, synchronize it with the server and create its bars (the history depth: required, 0 = the default)
     bool              CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0);    
    // Lifecycle methods
     //--- (BarSeriesDE) do not change: only the rows of the type go, and its marks, then Python judges the type again
      bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     //--- Lifecycle: opens the file of the account (Accounts\<account key>.sqlite3) and makes its tables when they are not there:
     //--- BarSeriesDE (the bars Python took from the terminal, all it can: the data of the machine learning), BarTimeSeriesCollection (what Python found on
     //--- the bars). A table of progress of an EA before Setting_Sync is moved to it
      bool              OnInitEvent(void);
    //--- Set the history depth of (1) the specified timeseries of the specified symbol, (2) the specified timeseries of all symbols
    //--- (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      bool              SetRequiredUsedData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);  
      bool              SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool              SetRequiredUsedData(const string symbol,const uint required=0,const int rates_total=0);
      bool              SetRequiredUsedData(const uint required=0,const int rates_total=0);
    //--- Return the flag of data synchronization with the server data of the (1) specified timeseries of the specified symbol,
    //--- (2) the specified timeseries of all symbols, (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      bool                    SyncData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool                    SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool                    SyncData(const string symbol,const uint required=0,const int rates_total=0);
      bool                    SyncData(const uint required=0,const int rates_total=0);
    //--- The rows of the table between RAM and the database, as SyncData: (1) every pair, (2) one pair. Each CBarSeriesDE does its own (CBarSeriesDE::SyncDataFromDB, SyncDataToDB)
      bool                    SyncDataFromDB(void);
      bool                    SyncDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
      bool                    SyncDataToDB(void);
    //Need check
   //--- The id of the symbol of ours a symbol of this account is (CSymbolsCollection)
    long              SymbolID(const string symbol) const { return(this.m_SymbolsCollection!=NULL ? this.m_SymbolsCollection.SymbolID(symbol) : 0); }
   //--- Return the bar of a symbol and a timeframe (1) by index as in the timeseries (0 = newest), (2) by time
    CBar             *GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const int index);
    CBar             *GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar_time);
   //--- The "New bar" flag of a symbol and a timeframe (true once for a new bar)
    bool              IsNewBar(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The bars follow MT5 (each series judges its new bars and tells them), as DoEasy CTimeSeriesCollection::Refresh: (1) a timeseries of a symbol,
   //--- (2) all timeseries of a symbol (OnTick), (3) all timeseries of all symbols (OnTick in the tester), (4) all except the current symbol (OnTimer)
    void              RefreshSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              RefreshSeries(const string symbol);
    void              RefreshSeries(void);
    void              RefreshSeriesAllExceptCurrent(void);
   //--- The rhythm of the EA: a step of the delete of the rows (the table, every pair) of a type whose parameter changed
    void              OnTimerEvent(void);
                      //CBarTimeSeriesCollection(void) : m_db(INVALID_HANDLE),m_BarInformationManager(NULL),m_SymbolsCollection(NULL),m_SymbolTFManager(NULL),m_SyncManager(NULL) { this.m_type=COLLECTION_SERIES_ID; this.m_list_timeseries.Clear(); }
                      CBarTimeSeriesCollection(void);
                     ~CBarTimeSeriesCollection(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
  };
#endif // CBARTIMESERIESCOLLECTION_MQH_DECLARATION
#ifndef CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
#define CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
 CBarTimeSeriesCollection::CBarTimeSeriesCollection(void)
  : m_db(INVALID_HANDLE),
    m_BarInformationManager(NULL),
    m_SymbolsCollection(NULL),
    m_SymbolTFManager(NULL),
    m_SyncManager(NULL)
  {
   this.m_type=COLLECTION_SERIES_ID;
   this.m_list_timeseries.Clear();
   this.m_list_timeseries.Type(COLLECTION_SERIES_ID);
  }
 //+------------------------------------------------------------------+
 //| Return the timeseries index by symbol name                       |
 //+------------------------------------------------------------------+
 int CBarTimeSeriesCollection::IndexTimeSeries(const string symbol)
  {
   string name=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
   for(int i=0; i<this.m_list_timeseries.Total(); i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      if(timeseries!=NULL && timeseries.Symbol()==name)
         return i;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| The tables of the account (the file of LibDatabase_AccountFile):  |
 //| what the broker gives is not the same for every account, so the   |
 //| bars and what Python found on them are not in the file the        |
 //| accounts share. No foreign keys: they cannot cross two files      |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::OnInitEvent(void)
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
   //--- BarTimeSeriesCollection: what Python found on the bars. Python writes it, the EA reads it to draw. One row for what happens at one bar (a pattern,
   //--- a momentum candle, a swing, a break...): the pair, the type, the open time of the bar and its side (the Buy or the Sell side of the type)
   const bool table_was_there=LibDatabase_TableExists(m_db,"BarTimeSeriesCollection");
   //--- The older column side is renamed: the rows stay
   if(LibDatabase_ColumnExists(m_db,"BarTimeSeriesCollection","side"))
      ::DatabaseExecute(m_db, "ALTER TABLE BarTimeSeriesCollection RENAME COLUMN side TO signal_direction");
   if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS BarTimeSeriesCollection (symbol_id INTEGER NOT NULL, tf_enum INTEGER NOT NULL, "
                               "type_infor INTEGER NOT NULL, bar_time INTEGER NOT NULL, signal_direction INTEGER NOT NULL, "
                               "PRIMARY KEY (symbol_id, tf_enum, type_infor, bar_time, signal_direction)) WITHOUT ROWID"))
    {
     ::Print(__FUNCTION__, " > the table BarTimeSeriesCollection is not made, error ", ::GetLastError());
     return false;
    }
   //--- BarSeriesDE: Python writes it (the library only adds the bars after the newest one it holds). One row for a closed bar of a pair (the properties of CBar)
   const bool bars_were_there=LibDatabase_TableExists(m_db,"BarSeriesDE");
   if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS BarSeriesDE (symbol_id INTEGER NOT NULL, tf_enum INTEGER NOT NULL, "
                               "bar_time INTEGER NOT NULL, open REAL NOT NULL, high REAL NOT NULL, low REAL NOT NULL, close REAL NOT NULL, tick_volume INTEGER NOT NULL, "
                               "spread INTEGER NOT NULL, real_volume INTEGER NOT NULL, PRIMARY KEY (symbol_id, tf_enum, bar_time)) WITHOUT ROWID"))
    {
     ::Print(__FUNCTION__, " > the table BarSeriesDE is not made, error ", ::GetLastError());
     return false;
    }
   //--- One of the two tables was not there (deleted, or the file is new): what was marked as synced is not true any more, Python makes the first chunk again
   if((!table_was_there || !bars_were_there) && this.m_SyncManager!=NULL)
      this.m_SyncManager.ResetObject_SyncManager(this.m_type);   //--- The progress of an EA before Setting_Sync: moved there (the file of the accounts), the old table goes
   if(this.m_SyncManager!=NULL)
      this.m_SyncManager.Import_SyncManager(m_db,"Sync_BarTimeSeriesCollection","type_infor",this.m_type);
   ::Print("Complete ", __FUNCTION__, " > ", LibDatabase_AccountFile(), " opened");
   return true;
  }
 //+------------------------------------------------------------------+
 //| Create the symbol timeseries collection list                     |
 //+------------------------------------------------------------------+
   //  bool CBarTimeSeriesCollection::CreateCollection(const CArrayObj *list_symbols)
   //   {
   //    if(list_symbols==NULL)
   //       return false;
   //    this.m_list_timeseries.Clear();
   //    for(int i=0; i<list_symbols.Total(); i++)
   //      {
   //       CSymbol *symbol_obj=list_symbols.At(i);
   //       if(symbol_obj==NULL || this.GetTimeseries(symbol_obj.Name())!=NULL)
   //          continue;   // none, or this symbol is there already
   //       CBarTimeSeriesDE *timeseries=new CBarTimeSeriesDE(symbol_obj.Name());
   //       if(timeseries==NULL)
   //          continue;
   //       if(!this.m_list_timeseries.Add(timeseries))
   //          delete timeseries;
   //      }
   //    return this.m_list_timeseries.Total()>0;
   //   }

 // Cretion CreateCollection SymbolTFManagerfrom  
 bool CBarTimeSeriesCollection::CreateCollection(CSymbolTFManager *manager)
  {
   if(manager==NULL)
      return false;

   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int total=manager.Pairs(symbols,timeframes);
   if(total==0)
      return false;

   //--- The series that are there stay (a chart change runs OnInit again): their rows, their progress and the handles of their CBarControl are kept, only new pairs are made.
   //--- A pair that left Setting_SymbolTF while the EA was away goes
   bool complete=true;
   for(int i=0;i<total;i++)
      complete=this.AddSeries_BarTimeSeriesCollection(symbols[i],timeframes[i]) && complete;
   for(int i=this.m_list_timeseries.Total()-1;i>=0;i--)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      CArrayObj *list=(timeseries!=NULL ? timeseries.GetListSeries() : NULL);
      for(int j=(list!=NULL ? list.Total()-1 : -1);j>=0;j--)
        {
         CBarSeriesDE *series=list.At(j);
         bool kept=false;
         for(int k=0;series!=NULL && k<total && !kept;k++)
            kept=(symbols[k]==series.Symbol() && timeframes[k]==series.Timeframe());
         if(series!=NULL && !kept)
            this.DeleteSeries_BarTimeSeriesCollection(series.Symbol(),series.Timeframe());
        }
     }
   return complete;
  }
 //+------------------------------------------------------------------+
 //| A pair of Setting_SymbolTF is made: the library judges it         |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::AddSeries_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.GetSeries(symbol,timeframe)!=NULL)
      return true;
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries==NULL)
     {
      timeseries=new CBarTimeSeriesDE(symbol);
      if(timeseries==NULL || !this.m_list_timeseries.Add(timeseries))
        {
         delete timeseries;
         return false;
        }
      timeseries.SetDatabase(m_db,this.SymbolID(symbol));   // it reads the table for the TFs of the symbol that have no series (ReadCandle_)
     }
   return this.CreateSeries(symbol,timeframe);
  }
 //+------------------------------------------------------------------+
 //| A pair left Setting_SymbolTF: the library stops judging it        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::DeleteSeries_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   int index=this.IndexTimeSeries(symbol);
   CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(index);
   if(timeseries==NULL || !timeseries.DeleteSeries(timeframe))
      return false;
   this.SendEvents_BarTimeSeriesCollection(timeseries);
   if(timeseries.SeriesTotal()==0)
      this.m_list_timeseries.Delete(index);   // the symbol has no pair of Setting_SymbolTF any more
   ::Print("Complete ",__FUNCTION__," > ",symbol," ",::EnumToString(timeframe)," left Setting_SymbolTF: the library stops, Python Live judges it from its progress");
   return true;
  }
 //+------------------------------------------------------------------+
 //| Return the timeseries object of the specified symbol             |
 //+------------------------------------------------------------------+
 CBarTimeSeriesDE *CBarTimeSeriesCollection::GetTimeseries(const string symbol)
  {
   int index=this.IndexTimeSeries(symbol);
   return(index==WRONG_VALUE ? NULL : this.m_list_timeseries.At(index));
  }
 //+------------------------------------------------------------------+
 //| Return the timeseries object of the specified symbol/period      |
 //+------------------------------------------------------------------+
 CBarSeriesDE *CBarTimeSeriesCollection::GetSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   return(timeseries!=NULL ? timeseries.GetSeries(timeframe) : NULL);
  }
 //+------------------------------------------------------------------+
 //| Add, synchronize and create the timeseries of a symbol/period    |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0)
  {
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries==NULL)
     {
      ::Print(DFUN,"no symbol ",symbol," in the collection");
      return false;
     }
   if(!timeseries.AddSeries(timeframe,required) || !timeseries.SyncData(timeframe,required))
      return false;
   CBarSeriesDE *series=timeseries.GetSeries(timeframe);
   if(series!=NULL)
      series.SetDatabase(m_db,this.SymbolID(symbol),this.m_type,this.m_SyncManager,this.m_BarInformationManager);   // it judges and writes its own rows
   return timeseries.CreateSeries(timeframe,required);
  }
 // Set SetAvailable
 void CBarTimeSeriesCollection::SetAvailable(const string symbol,const ENUM_TIMEFRAMES timeframe,const bool flag=true)
  {
   CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
   if(series!=NULL)
      series.SetAvailable(flag);
  } 
 //+------------------------------------------------------------------+
 //|Set the flag of using the specified timeseries of all symbols     |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::SetAvailable(const ENUM_TIMEFRAMES timeframe,const bool flag=true)
  {
   int total=this.m_list_timeseries.Total();
   for(int i=0;i<total;i++)
    {
     CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
     if(timeseries==NULL)
        continue;
     CBarSeriesDE *series=timeseries.GetSeries(timeframe);
     if(series==NULL)
        continue;
     series.SetAvailable(flag);
    }
  }
 //+------------------------------------------------------------------+
 //|Set the flag of using all timeseries of the specified symbol      |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::SetAvailable(const string symbol,const bool flag=true)
  {
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries==NULL)
      return;
   CArrayObj *list=timeseries.GetListSeries();
   if(list==NULL)
      return;
   int total=list.Total();
   for(int i=0;i<total;i++)
    {
     CBarSeriesDE *series=list.At(i);
     if(series==NULL)
        continue;
     series.SetAvailable(flag);
    }
  }
 //+------------------------------------------------------------------+
 //| Set the flag of using all timeseries of all symbols              |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::SetAvailable(const bool flag=true)
  {
   int total=this.m_list_timeseries.Total();
   for(int i=0;i<total;i++)
    {
     CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
     if(timeseries==NULL)
        continue;
     CArrayObj *list=timeseries.GetListSeries();
     if(list==NULL)
        continue;
     int total_series=list.Total();
     for(int j=0;j<total_series;j++)
      {
       CBarSeriesDE *series=list.At(j);
       if(series==NULL)
          continue;
       series.SetAvailable(flag);
      }
    }
  }
 //+--------------------------------------------------------------------------+
 //|Set the history depth for the specified timeseries of the specified symbol|
 //+--------------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::SetRequiredUsedData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
  {
   CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
   if(series==NULL)
         return false;
      return series.SetRequiredUsedData(required,rates_total);
   }
 //+------------------------------------------------------------------+
 //| Set the history depth of the specified timeseries of all symbols |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
  {
   bool res=true;
   int total=this.m_list_timeseries.Total();
   for(int i=0;i<total;i++)
    {
     CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
     if(timeseries==NULL)
      continue;
     CBarSeriesDE *series=timeseries.GetSeries(timeframe);
     if(series==NULL)
      continue;
     res &=series.SetRequiredUsedData(required,rates_total);
    }
   return res;
  }
 //+------------------------------------------------------------------+
 //| Set the history depth for all timeseries of the specified symbol |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::SetRequiredUsedData(const string symbol,const uint required=0,const int rates_total=0)
  {
   bool res=true;
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries==NULL)
      return false;
   CArrayObj *list=timeseries.GetListSeries();
   if(list==NULL)
      return false;
   int total=list.Total();
   for(int i=0;i<total;i++)
    {
     CBarSeriesDE *series=list.At(i);
     if(series==NULL)
      continue;
     res &=series.SetRequiredUsedData(required,rates_total);
    }
   return res;
  }
 //+------------------------------------------------------------------+
 //| Set the history depth for all timeseries of all symbols          |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::SetRequiredUsedData(const uint required=0,const int rates_total=0)
  {
   bool res=true;
   int total=this.m_list_timeseries.Total();
   for(int i=0;i<total;i++)
    {
     CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
     if(timeseries==NULL)
      continue;
     CArrayObj *list=timeseries.GetListSeries();
     if(list==NULL)
      continue;
     int total_series=list.Total();
     for(int j=0;j<total_series;j++)
     {
      CBarSeriesDE *series=list.At(j);
      if(series==NULL)
       continue;
      res &=series.SetRequiredUsedData(required,rates_total);
     }
    }
   return res;
  }
 //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for a specified timeseries of a specified symbol                 |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return false;
      return series.SyncData(required);
   }
  //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for a specified timeseries of all symbols                        |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
   {
      bool res=true;
      int total=this.m_list_timeseries.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
         if(timeseries==NULL)
            continue;
         CBarSeriesDE *series=timeseries.GetSeries(timeframe);
         if(series==NULL)
            continue;
         res &=series.SyncData(required);
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for all timeseries of a specified symbol                         |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const string symbol,const uint required=0,const int rates_total=0)
   {
      bool res=true;
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return false;
      CArrayObj *list=timeseries.GetListSeries();
      if(list==NULL)
         return false;
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         CBarSeriesDE *series=list.At(i);
         if(series==NULL)
            continue;
         res &=series.SyncData(required);
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for all timeseries of all symbols                                |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const uint required=0,const int rates_total=0)
   {
      bool res=true;
      int total=this.m_list_timeseries.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
         if(timeseries==NULL)
            continue;
         CArrayObj *list=timeseries.GetListSeries();
         if(list==NULL)
            continue;
         int total_series=list.Total();
         for(int j=0;j<total_series;j++)
         {
            CBarSeriesDE *series=list.At(j);
            if(series==NULL)
               continue;
            res &=series.SyncData(required);
         }
      }
      return res;
   }
 // Get IsAvailable match with V4
 bool CBarTimeSeriesCollection::IsAvailable(const string symbol,
                                           const ENUM_TIMEFRAMES timeframe)
  {
   if(this.m_SymbolTFManager==NULL)
     {
      ::Print(__FUNCTION__," > SymbolTFManager is NULL");
      return false;
     }

   string name=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
   return this.m_SymbolTFManager.Exists(name,timeframe);
  }  
  //+------------------------------------------------------------------+
  //| Return the flag of using the specified timeseries of all symbols |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsAvailable(const ENUM_TIMEFRAMES timeframe)
   {
      bool res=true;
      int total=this.m_list_timeseries.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
         if(timeseries==NULL)
            continue;
         CBarSeriesDE *series=timeseries.GetSeries(timeframe);
         if(series==NULL)
            continue;
         res &=series.IsAvailable();
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of using all timeseries of the specified symbol  |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsAvailable(const string symbol)
   {
      bool res=true;
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return false;
      CArrayObj *list=timeseries.GetListSeries();
      if(list==NULL)
         return false;
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         CBarSeriesDE *series=list.At(i);
         if(series==NULL)
            continue;
         res &=series.IsAvailable();
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of using all timeseries of all symbols           |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsAvailable(void)
   {
      bool res=true;
      int total=this.m_list_timeseries.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
         if(timeseries==NULL)
            continue;
         CArrayObj *list=timeseries.GetListSeries();
         if(list==NULL)
            continue;
         int total_series=list.Total();
         for(int j=0;j<total_series;j++)
         {
            CBarSeriesDE *series=list.At(j);
            if(series==NULL)
               continue;
            res &=series.IsAvailable();
         }
      }
      return res;
   }
 CBar *CBarTimeSeriesCollection::GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const int index)
  {
   CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
   return(series!=NULL ? series.GetBar((uint)index) : NULL);
  }
 CBar *CBarTimeSeriesCollection::GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar_time)
  {
   CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
   return(series!=NULL ? series.GetBar(bar_time) : NULL);
  }
 bool CBarTimeSeriesCollection::IsNewBar(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
   return(series!=NULL ? series.IsNewBar() : false);
  }
   //  void CBarTimeSeriesCollection::Refresh(const string symbol,const ENUM_TIMEFRAMES timeframe)
   //   {
   //    CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   //    //if(timeseries==NULL || !timeseries.Refresh(timeframe))
   //    if(timeseries==NULL || !timeseries.RefreshSeries(timeframe))
   //       return;
   //    CBarSeriesDE *series=timeseries.GetSeries(timeframe);
   //    if(series==NULL)
   //       return;
   //    ::EventChartCustom(::ChartID(),(ushort)SERIES_EVENT_NEW_BAR,(long)series.LastBarDate(),(double)series.Timeframe(),series.Symbol());
   //    this.m_is_event=this.EventAdd((ushort)SERIES_EVENT_NEW_BAR,(long)series.LastBarDate(),(double)series.Timeframe(),series.Symbol());   // the same event stays in the list of the object (GetListEvents) until the next beat
   //   }
 //+------------------------------------------------------------------+
 //| The bars of every series follow MT5 (RAM): a new bar of a series |
 //| goes up the chain (CBarSeriesDE > CBarTimeSeriesDE > collection) |
 //| and is told to the chart, SERIES_EVENTS_NEW_BAR: lparam the open |
 //| time of the newest bar, dparam the TF, sparam the symbol. Then   |
 //| the series judges its new bars (V2: CBarSeriesDE::Refresh did)   |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::RefreshSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   this.m_list_events.Clear();
   this.m_is_event=false;
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries!=NULL && timeseries.RefreshSeries(timeframe))
      this.SendEvents_BarTimeSeriesCollection(timeseries);
  }
 void CBarTimeSeriesCollection::RefreshSeries(void)
  {
   this.m_list_events.Clear();   // the events of the call before are gone
   this.m_is_event=false;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
      this.RefreshTimeseries_BarTimeSeriesCollection(this.m_list_timeseries.At(i));
  }
 void CBarTimeSeriesCollection::RefreshSeries(const string symbol)
  {
   this.m_list_events.Clear();
   this.m_is_event=false;
   this.RefreshTimeseries_BarTimeSeriesCollection(this.GetTimeseries(symbol));
  }
 void CBarTimeSeriesCollection::RefreshSeriesAllExceptCurrent(void)
  {
   this.m_list_events.Clear();
   this.m_is_event=false;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      //--- The chart's symbol follows its ticks (OnTick); a symbol with no new tick has no new bar (a closed market): skipped (DoEasy RefreshAllExceptCurrent)
      if(timeseries==NULL || timeseries.Symbol()==::Symbol())
         continue;
      const bool new_tick=timeseries.IsNewTick();
      this.SendEvents_BarTimeSeriesCollection(timeseries);   // TICK_EVENT_PAUSE / RESUME: the other hands of the symbol rest or go on
      if(new_tick)
         this.RefreshTimeseries_BarTimeSeriesCollection(timeseries);
     }
  }
 //+------------------------------------------------------------------+
 //| Every series of a symbol follows MT5, then its events go out      |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::RefreshTimeseries_BarTimeSeriesCollection(CBarTimeSeriesDE *timeseries)
  {
   CArrayObj *list=(timeseries!=NULL ? timeseries.GetListSeries() : NULL);
   for(int j=0;list!=NULL && j<list.Total();j++)
     {
      CBarSeriesDE *series=list.At(j);
      if(series!=NULL && timeseries.RefreshSeries(series.Timeframe()))   // the series judges its new bars itself
         this.SendEvents_BarTimeSeriesCollection(timeseries);
     }
  }
 //+------------------------------------------------------------------+
 //| The events of the series of a symbol go to the chart once         |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::SendEvents_BarTimeSeriesCollection(CBarTimeSeriesDE *timeseries)
  {
   CArrayObj *events=(timeseries!=NULL && timeseries.IsEvent() ? timeseries.GetListEvents() : NULL);
   for(int e=0;events!=NULL && e<events.Total();e++)
     {
      CEventBaseObj *event=events.At(e);
      if(event==NULL || !this.EventAdd((ushort)event.ID(),event.LParam(),event.DParam(),event.SParam()))
         continue;   // told already
      this.m_is_event=true;
      ::EventChartCustom(::ChartID(),(ushort)event.ID(),event.LParam(),event.DParam(),event.SParam());   // the parent and the siblings hear it
      //--- Something new was found on the newest closed bar, or a new swing (its pivot is swing_strength bars before the bar that confirms it): its alert (what was found on it is the series')
      CBarSeriesDE *series=timeseries.GetSeries((ENUM_TIMEFRAMES)(long)event.DParam());
      const datetime bar=(datetime)event.LParam();
      const ushort id=(ushort)event.ID();
      const bool swings=(id==SERIES_EVENTS_SWING);
      if((id!=SERIES_EVENTS_PATTERN && id!=SERIES_EVENTS_BOS && id!=SERIES_EVENTS_CHOCH && !swings) || series==NULL || bar==SERIES_EVENTS_PATTERN_ALL ||
         (!swings && bar!=::iTime(series.Symbol(),series.Timeframe(),1)))
         continue;
      long types[];
      int  sides[];
      if(series.GetBarControl().RowsOfBar(bar,id,types,sides)>0)
         this.Alert_BarTimeSeriesCollection(series.Symbol(),series.Timeframe(),bar,types,sides);
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the table to RAM: every pair, one pair (each series   |
 //| does its own, as SyncData)                                        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::SyncDataFromDB(void)
  {
   bool done=true;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      if(timeseries==NULL)
         continue;
      done=timeseries.SyncDataFromDB() && done;
      this.SendEvents_BarTimeSeriesCollection(timeseries);
     }
   return done;
  }
 bool CBarTimeSeriesCollection::SyncDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries==NULL)
      return false;
   const bool done=timeseries.SyncDataFromDB(timeframe);
   this.SendEvents_BarTimeSeriesCollection(timeseries);
   return done;
  }
 //+------------------------------------------------------------------+
 //| What waits in RAM goes to the database (each series does its own) |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::SyncDataToDB(void)
  {
   bool done=true;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      if(timeseries==NULL)
         continue;
      done=timeseries.SyncDataToDB() && done;
      this.SendEvents_BarTimeSeriesCollection(timeseries);
     }
   return done;
  }
 //+------------------------------------------------------------------+
 //| The library judges the new bars of the pairs of Setting_SymbolTF |
 //| (the first chunk of a pair that has no progress yet too). A beat |
 //| of the timer does BAR_UPDATE_BUDGET_MS of it at most              |
 //+------------------------------------------------------------------+
      //  void CBarTimeSeriesCollection::UpdateTable_BarTimeSeriesCollection(void)
      //   {
      //    if(m_db==INVALID_HANDLE || this.m_SymbolsCollection==NULL || this.m_SymbolTFManager==NULL || this.m_SyncManager==NULL)
      //       return;
      //    ulong started=::GetTickCount64();
      //    this.Reset_BarTimeSeriesCollection(started);
      //    string symbols[];
      //    ENUM_TIMEFRAMES timeframes[];
      //    int total=this.m_SymbolTFManager.Pairs(symbols,timeframes);
      //    ENUM_BAR_INFOR_TYPE found_types[];
      //    int found_total=this.m_BarControl.Types(found_types);
      //    for(int i=0;i<total;i++)
      //      {
      //       datetime last_closed=::iTime(symbols[i],timeframes[i],1);
      //       if(last_closed==0)
      //          continue;
      //       //--- The same newest closed bar as the last time: nothing to judge, nothing is asked to the table
      //       string key=symbols[i]+" "+(string)(int)timeframes[i];
      //       int slot=-1;
      //       for(int k=0;k<::ArraySize(this.m_pair_key) && slot<0;k++)
      //          if(this.m_pair_key[k]==key)
      //             slot=k;
      //       if(slot>=0 && this.m_pair_done[slot]==last_closed)
      //          continue;
      //       long symbol_id=this.SymbolID(symbols[i]);
      //       if(symbol_id==0)
      //          continue;
      //       if(this.GetSeries(symbols[i],timeframes[i])==NULL && !this.CreateSeries(symbols[i],timeframes[i]))
      //          continue;
      //       CBarSeriesDE *series=this.GetSeries(symbols[i],timeframes[i]);
      //       CBar *newest=(series!=NULL ? series.GetBar((uint)1) : NULL);
      //       if(newest==NULL || newest.Time()!=last_closed)
      //          continue;   // the series has not the newest closed bar yet (Refresh adds it)
      //       if(slot<0)
      //         {
      //          slot=::ArraySize(this.m_pair_key);
      //          ::ArrayResize(this.m_pair_key,slot+1);
      //          ::ArrayResize(this.m_pair_done,slot+1);
      //          ::ArrayResize(this.m_pair_bars,slot+1);
      //          this.m_pair_key[slot]=key;
      //          this.m_pair_done[slot]=0;
      //          this.m_pair_bars[slot]=0;
      //         }
      //       bool finished=true;   // every type of the pair is judged to the newest closed bar
      //       bool any_progress=false;   // a type of the pair has the row of progress of Python: the first chunk is there
      //       long found_times[];   // the candles that got something new for the pair in this beat: each one is told (SERIES_EVENT_PATTERN)
      //       long alert_types[];   // the types that found something on the newest closed bar, and the sides (1 Buy, 2 Sell)
      //       int  alert_sides[];
      //       //--- The bars first (what is judged is on them), then the types of information. The bars of the start are Python's: the library writes only the new ones,
      //       //--- the bars after the newest one the table holds (no bar in the table: Python has not made the first chunk of the pair yet, the library waits for it).
      //       //--- EA_STORE_BARS false: no bar is kept, the progress of Setting_Sync below tells that Python made the first chunk
      //       if(EA_STORE_BARS && this.m_pair_bars[slot]!=last_closed)
      //         {
      //          datetime in_table=this.ReadNewestBar_BarTimeSeriesCollection(symbol_id,timeframes[i]);
      //          if(in_table==0)
      //             finished=false;
      //          else if(in_table>=last_closed)
      //             this.m_pair_bars[slot]=last_closed;   // the table has the newest closed bar already
      //          else if(this.AddBars_BarTimeSeriesCollection(symbol_id,timeframes[i],series.GetList(),in_table))
      //             this.m_pair_bars[slot]=last_closed;
      //          else
      //             finished=false;   // the database is busy (Python writes): the next beat tries again
      //         }
      //       long types[],last_bars[];
      //       this.m_SyncManager.Ranges_SyncManager(this.m_type,symbol_id,timeframes[i],types,last_bars);
      //       for(int t=0;t<found_total && finished;t++)
      //         {
      //          if(::GetTickCount64()-started>BAR_UPDATE_BUDGET_MS)
      //            {
      //             finished=false;
      //             break;
      //            }
      //          datetime since=0;
      //          bool has_progress=false;
      //          for(int k=0;k<::ArraySize(types);k++)
      //             if(types[k]==(long)found_types[t])
      //               {
      //                since=(datetime)last_bars[k];
      //                has_progress=true;
      //               }
      //          any_progress=any_progress || has_progress;
      //          if(!has_progress || since>=last_closed)
      //             continue;   // no row of progress: the history of the start is Python's, the library goes on from where it stopped
      //          CBar *oldest=series.GetList().At(0);
      //          if(oldest==NULL || oldest.Time()>since)
      //            {
      //             finished=false;   // what is missing is more than the series holds: Python fills it (it is behind), the next beat looks again
      //             continue;
      //            }
      //          this.m_BarControl.Find(found_types[t],series.GetList(),since);
      //          long row_times[],row_sides[];
      //          this.m_BarControl.RowsTo(row_times,row_sides);
      //          if(!this.AddRows_BarTimeSeriesCollection((long)found_types[t],symbols[i],symbol_id,timeframes[i],last_closed))
      //             finished=false;
      //          else
      //            {
      //             AddFoundTimes(found_times,row_times);
      //             int bits=NewSidesOfBar(row_times,row_sides,last_closed,(long)SIGNAL_DIRECTION_BUY);   // written: what is new on the newest bar can be told
      //             if(bits!=0)
      //               {
      //                int n=::ArraySize(alert_types);
      //                ::ArrayResize(alert_types,n+1);
      //                ::ArrayResize(alert_sides,n+1);
      //                alert_types[n]=(long)found_types[t];
      //                alert_sides[n]=bits;
      //               }
      //            }
      //         }
      //       if(found_total>0 && !any_progress)
      //          finished=false;   // Python has not made the first chunk of any type of the pair: the library looks again at the next beat, it does not wait for the next bar
      //       if(finished && any_progress && this.m_pair_done[slot]==0)
      //         {
      //          ::ArrayResize(found_times,1);
      //          found_times[0]=SERIES_EVENTS_PATTERN_ALL;   // the library takes the pair over from Python (the Current worker): the markers of the chart are made once
      //         }
      //       if(::ArraySize(found_times)>SERIES_EVENTS_PATTERN_MAX)
      //         {
      //          ::ArrayResize(found_times,1);
      //          found_times[0]=SERIES_EVENTS_PATTERN_ALL;   // too many to tell one by one: the markers of the chart are made again
      //         }
      //       for(int k=0;k<::ArraySize(found_times);k++)
      //         {
      //          ::EventChartCustom(::ChartID(),(ushort)SERIES_EVENTS_PATTERN,found_times[k],(double)timeframes[i],symbols[i]);
      //          this.m_is_event=this.EventAdd((ushort)SERIES_EVENTS_PATTERN,found_times[k],(double)timeframes[i],symbols[i]) || this.m_is_event;
      //         }
      //       if(::ArraySize(alert_types)>0)
      //          this.Alert_BarTimeSeriesCollection(symbols[i],timeframes[i],last_closed,alert_types,alert_sides);
      //       if(finished)
      //          this.m_pair_done[slot]=last_closed;
      //       if(::GetTickCount64()-started>BAR_UPDATE_BUDGET_MS)
      //          return;   // this beat has had its share: the rest is done at the next ones
      //      }
      //   }
 //+------------------------------------------------------------------+
 //| The rhythm of the EA: what waits from the beats before            |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::OnTimerEvent(void)
  {
   if(m_db==INVALID_HANDLE || this.m_SyncManager==NULL)
      return;
   this.Reset_BarTimeSeriesCollection(::GetTickCount64());   // a type whose parameter changed (SETUP_CHANGED): a step of its rows in the table, every pair
  }
 //+------------------------------------------------------------------+
 //| A parameter of a type changed: the series drop its rows in RAM    |
 //| (each tells it), the rows in the table wait to be deleted         |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- Setting_SymbolTF changed (CSymbolTFManager told it, lparam the TF, sparam the symbol): who judges the pair changes with it
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
      return this.AddSeries_BarTimeSeriesCollection(sparam,(ENUM_TIMEFRAMES)lparam);
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
      return this.DeleteSeries_BarTimeSeriesCollection(sparam,(ENUM_TIMEFRAMES)lparam);
   //--- Python wrote the first chunk of every pair of Setting_SymbolTF (CPythonBridge told it): what is in the table goes to RAM
   if(id==CHARTEVENT_CUSTOM+PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
      return this.SyncDataFromDB();
   if(id!=CHARTEVENT_CUSTOM+BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED)
      return false;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      CArrayObj *list=(timeseries!=NULL ? timeseries.GetListSeries() : NULL);
      for(int j=0;list!=NULL && j<list.Total();j++)
        {
         CBarSeriesDE *series=list.At(j);
         if(series==NULL)
            continue;
         series.GetBarControl().DeleteRows(lparam);
         series.RelayEvents();
        }
      if(timeseries!=NULL && timeseries.RelayEvents())
         this.SendEvents_BarTimeSeriesCollection(timeseries);
     }
   for(int k=0;k<::ArraySize(this.m_reset_types);k++)
      if(this.m_reset_types[k]==lparam)
         return true;   // it waits already: nothing was judged again yet, it will be judged with the newest value
   ::ArrayResize(this.m_reset_types,::ArraySize(this.m_reset_types)+1);
   this.m_reset_types[::ArraySize(this.m_reset_types)-1]=lparam;
   ::Print("Complete ",__FUNCTION__," > the parameter of the type ",lparam," changed: its rows are judged again, the bars stay");
   return true;
  }
 //+------------------------------------------------------------------+
 //| A step of the delete of the rows of the type that waits: the pair |
 //| is the first one that has the mark of the type (CSyncManager)     |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::Reset_BarTimeSeriesCollection(const ulong started)
  {
   while(::ArraySize(this.m_reset_types)>0)
     {
      if(!this.m_SyncManager.ResetStep_SyncManager(m_db,"BarTimeSeriesCollection","type_infor",this.m_type,this.m_reset_types[0],started,BAR_UPDATE_BUDGET_MS))
         return;
      ::Print("Complete ",__FUNCTION__," > the rows and the marks of the type ",this.m_reset_types[0]," are gone: Python judges it again");
      ::ArrayRemove(this.m_reset_types,0,1);
     }
  }
 //+------------------------------------------------------------------+
 //| The alert of what is new on a pair: a type tells when its alert   |
 //| is on and the pair has the same alert on (Setting_SymbolTF); one  |
 //| line for all of them                                              |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::Alert_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &types[],const int &sides[])
  {
   if(this.m_BarInformationManager==NULL || this.m_SymbolTFManager==NULL)
      return;
   const bool pair_sound=this.m_SymbolTFManager.SoundAlert(symbol,timeframe);
   const bool pair_message=this.m_SymbolTFManager.MessageAlert(symbol,timeframe);
   if(!pair_sound && !pair_message)
      return;
   long alert_types[];
   string alert_names[];
   bool type_sound[],type_message[];
   int total=this.m_BarInformationManager.AlertTypes(alert_types,alert_names,type_sound,type_message);
   string names[];
   int told[];
   bool sound=false,message=false;
   for(int i=0;i<::ArraySize(types);i++)
      for(int k=0;k<total;k++)
         if(alert_types[k]==types[i])
           {
            bool by_sound=(type_sound[k] && pair_sound),by_message=(type_message[k] && pair_message);
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
#endif // CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
#endif // __BARTIMESERIESCOLLECTION_MQH__
