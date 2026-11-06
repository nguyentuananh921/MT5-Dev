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
 #include "..\Services\DELib\DatabaseService.mqh"
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
   CDatabaseService   *m_CDatabaseService;        // The EA holds it
    CListObj            m_list_timeseries;         // List of the symbol timeseries (CBarTimeSeriesDE), one for each symbol: each CBarSeriesDE keeps its rows (a CBar each) and judges its bars
    CSymbolsCollection  *m_SymbolsCollection;      // the EA holds it: the id of a symbol (symbols)
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
     void              Reset(const ulong started);
    //--- What is new on a pair at its newest closed bar is told once, for the types whose alert is on (and when the pair has the alert on too)
     void              AlertOnPair(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &types[],const int &sides[]);
    //--- The events of the series of a symbol go to the chart once (the parent and the siblings hear them). SERIES_EVENTS_PATTERN of the newest closed bar: its alert goes
     void              SendEvents(CBarTimeSeriesDE *timeseries);
    //--- Every series of a symbol follows MT5, then its events go to the chart
     void              RefreshTimeseries(CBarTimeSeriesDE *timeseries);
    //--- A pair of Setting_SymbolTF is (1) made (OnInit, SYMBOLTF_MANAGER_EVENT_ADDED): the library judges it, (2) taken away (SYMBOLTF_MANAGER_EVENT_DELETE): the library
    //--- stops, Python Live judges it from its progress (Setting_SymbolTF is what tells Python)
     bool              Create_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe);
     bool              Delete_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe);
   public:
    //--- Return the timeseries list (public as in DoEasy CTimeSeriesCollection: CSignalsCollection walks the pairs in RAM)
     CArrayObj        *GetList(void)              { return &this.m_list_timeseries; }
    //Setting Pointer
     void              SetDatabaseService(CDatabaseService *databaseService)      { this.m_CDatabaseService=databaseService; }
     void              SetSymbolsCollection(CSymbolsCollection *collection)       { this.m_SymbolsCollection=collection; }
     void              SetSymbolTFManager(CSymbolTFManager *manager)              { this.m_SymbolTFManager=manager;      }
     void              SetSyncManager(CSyncManager *manager)                      { this.m_SyncManager=manager;          }
     void              SetBarInformationManager(CBarInformationManager *manager)  { this.m_BarInformationManager=manager; }
    //--- Create the list: one timeseries object for each symbol of the list (no timeframe is added yet)
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
    //--- The rows of the table between RAM and the database, as SyncData: (1) every pair, (2) one pair. Each CBarSeriesDE does its own (CBarSeriesDE::ReadDataFromDB, UpdateDataToDB)
      bool                    ReadDataFromDB(void);
      bool                    ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
      bool                    UpdateDataToDB(void);
    //Need check
   //--- The id of the symbol of ours a symbol of this account is (CSymbolsCollection)
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
                      CBarTimeSeriesCollection(void);
                     ~CBarTimeSeriesCollection(void) {}
  };
#endif // CBARTIMESERIESCOLLECTION_MQH_DECLARATION
#ifndef CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
#define CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
 CBarTimeSeriesCollection::CBarTimeSeriesCollection(void)
  : m_BarInformationManager(NULL),
    m_SymbolsCollection(NULL),
    m_SymbolTFManager(NULL),
    m_CDatabaseService(NULL),
    m_SyncManager(NULL)
  {
   this.m_object_type=COLLECTION_SERIES_ID;
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
 //| The tables of the account (the file Account of CDatabaseService):|
 //| what the broker gives is not the same for every account, so the   |
 //| bars and what Python found on them are not in the file the        |
 //| accounts share. No foreign keys: they cannot cross two files      |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::OnInitEvent(void)
  {
   // New In V4 after implemenation CDatabaseService
   return true;   // its tables are CBarInformationManager's
  }
 //+------------------------------------------------------------------+
 //| Cretion CreateCollection SymbolTFManagerfrom                     |
 //+------------------------------------------------------------------+  
 bool CBarTimeSeriesCollection::CreateCollection(CSymbolTFManager *manager)
  {
   if(manager==NULL)
      return false;

   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int total=manager.Read_RAM(symbols,timeframes);
   if(total==0)
      return false;

   //--- The series that are there stay (a chart change runs OnInit again): their rows, their progress and the handles of their CBarControl are kept, only new pairs are made.
   //--- A pair that left Setting_SymbolTF while the EA was away goes
   bool complete=true;
   for(int i=0;i<total;i++)
      complete=this.Create_RAM(symbols[i],timeframes[i]) && complete;
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
            this.Delete_RAM(series.Symbol(),series.Timeframe());
        }
     }
   return complete;
  }
 //+------------------------------------------------------------------+
 //| A pair of Setting_SymbolTF is made: the library judges it         |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::Create_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe)
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
      timeseries.SetDatabase(this.m_BarInformationManager);   // it reads the table for the TFs of the symbol that have no series (ReadCandle_)
     }
   return this.CreateSeries(symbol,timeframe);
  }
 //+------------------------------------------------------------------+
 //| A pair left Setting_SymbolTF: the library stops judging it        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::Delete_RAM(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   int index=this.IndexTimeSeries(symbol);
   CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(index);
   if(timeseries==NULL || !timeseries.DeleteSeries(timeframe))
      return false;
   this.SendEvents(timeseries);
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
      series.SetDatabase(this.m_object_type,this.m_SyncManager,this.m_BarInformationManager);   // it judges and writes its own rows
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
   return (this.m_SymbolTFManager.Read_RAM(name,timeframe)!=NULL);
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
      this.SendEvents(timeseries);
  }
 void CBarTimeSeriesCollection::RefreshSeries(void)
  {
   this.m_list_events.Clear();   // the events of the call before are gone
   this.m_is_event=false;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
      this.RefreshTimeseries(this.m_list_timeseries.At(i));
  }
 void CBarTimeSeriesCollection::RefreshSeries(const string symbol)
  {
   this.m_list_events.Clear();
   this.m_is_event=false;
   this.RefreshTimeseries(this.GetTimeseries(symbol));
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
      this.SendEvents(timeseries);   // TICK_EVENT_PAUSE / RESUME: the other hands of the symbol rest or go on
      if(new_tick)
         this.RefreshTimeseries(timeseries);
     }
  }
 //+------------------------------------------------------------------+
 //| Every series of a symbol follows MT5, then its events go out      |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::RefreshTimeseries(CBarTimeSeriesDE *timeseries)
  {
   CArrayObj *list=(timeseries!=NULL ? timeseries.GetListSeries() : NULL);
   for(int j=0;list!=NULL && j<list.Total();j++)
     {
      CBarSeriesDE *series=list.At(j);
      if(series!=NULL && timeseries.RefreshSeries(series.Timeframe()))   // the series judges its new bars itself
         this.SendEvents(timeseries);
     }
  }
 //+------------------------------------------------------------------+
 //| The events of the series of a symbol go to the chart once         |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::SendEvents(CBarTimeSeriesDE *timeseries)
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
         this.AlertOnPair(series.Symbol(),series.Timeframe(),bar,types,sides);
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the table to RAM: every pair, one pair (each series   |
 //| does its own, as SyncData)                                        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::ReadDataFromDB(void)
  {
   bool done=true;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      if(timeseries==NULL)
         continue;
      done=timeseries.ReadDataFromDB() && done;
      this.SendEvents(timeseries);
     }
   return done;
  }
 bool CBarTimeSeriesCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries==NULL)
      return false;
   const bool done=timeseries.ReadDataFromDB(timeframe);
   this.SendEvents(timeseries);
   return done;
  }
 //+------------------------------------------------------------------+
 //| What waits in RAM goes to the database (each series does its own) |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::UpdateDataToDB(void)
  {
   bool done=true;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      if(timeseries==NULL)
         continue;
      done=timeseries.UpdateDataToDB() && done;
      this.SendEvents(timeseries);
     }
   return done;
  }
 //+------------------------------------------------------------------+
 //| The rhythm of the EA: what waits from the beats before            |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::OnTimerEvent(void)
  {
   if(this.m_SyncManager==NULL)
      return;
   this.Reset(::GetTickCount64());   // a type whose parameter changed (SETUP_CHANGED): a step of its rows in the table, every pair
  }
 //+------------------------------------------------------------------+
 //| A parameter of a type changed: the series drop its rows in RAM    |
 //| (each tells it), the rows in the table wait to be deleted         |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- Setting_SymbolTF changed (CSymbolTFManager told it, lparam the TF, sparam the symbol): who judges the pair changes with it
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
      return this.Create_RAM(sparam,(ENUM_TIMEFRAMES)lparam);
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
      return this.Delete_RAM(sparam,(ENUM_TIMEFRAMES)lparam);
   //--- Python wrote the first chunk of every pair of Setting_SymbolTF (CPythonBridge told it): what is in the table goes to RAM
   if(id==CHARTEVENT_CUSTOM+PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
      return this.ReadDataFromDB();
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
         this.SendEvents(timeseries);
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
 void CBarTimeSeriesCollection::Reset(const ulong started)
  {
   while(::ArraySize(this.m_reset_types)>0)
     {
      if(!this.m_SyncManager.ResetStep("BarTimeSeriesCollection","type_infor",this.m_object_type,this.m_reset_types[0],started,BAR_UPDATE_BUDGET_MS))
         return;
      ::Print("Complete ",__FUNCTION__," > the rows and the marks of the type ",this.m_reset_types[0]," are gone: Python judges it again");
      ::ArrayRemove(this.m_reset_types,0,1);
      if(::ArraySize(this.m_reset_types)==0)
         ::EventChartCustom(::ChartID(),(ushort)BAR_INFORMATION_MANAGER_EVENT_RESET_DONE,0,0.0,"");   // nothing left to delete: CPythonBridge tells the Current worker
     }
  }
 //+------------------------------------------------------------------+
 //| The alert of what is new on a pair: a type tells when its alert   |
 //| is on and the pair has the same alert on (Setting_SymbolTF); one  |
 //| line for all of them                                              |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::AlertOnPair(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar,const long &types[],const int &sides[])
  {
   if(this.m_BarInformationManager==NULL || this.m_SymbolTFManager==NULL)
      return;
   const bool pair_sound=this.m_SymbolTFManager.Read_RAM(symbol,timeframe,"sound_alert");
   const bool pair_message=this.m_SymbolTFManager.Read_RAM(symbol,timeframe,"message_alert");
   if(!pair_sound && !pair_message)
      return;
   long alert_types[];
   string alert_names[];
   bool type_sound[],type_message[];
   int total=this.m_BarInformationManager.Read_RAM(alert_types,alert_names,type_sound,type_message);
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
   AlertNewOnPair(symbol,this.m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)timeframe),bar,names,told,sound,message);
  }
#endif // CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
#endif // __BARTIMESERIESCOLLECTION_MQH__
