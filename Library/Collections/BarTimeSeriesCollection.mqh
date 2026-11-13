//+------------------------------------------------------------------+
//| Symbol timeseries collection                                     |
//+------------------------------------------------------------------+
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
 #define BAR_UPDATE_BUDGET_MS         40    // what a beat of the timer does at most: the rest is done at the next ones
#ifndef CBARTIMESERIESCOLLECTION_MQH_DECLARATION
#define CBARTIMESERIESCOLLECTION_MQH_DECLARATION 
 class CBarTimeSeriesCollection : public CBaseObjExt
  {
   private:
    CListObj            m_list_timeseries;         // List of the symbol timeseries (CBarTimeSeriesDE), one for each symbol: each CBarSeriesDE keeps its rows (a CBar each) and judges its bars
    CSymbolTFManager    *m_SymbolTFManager;        // the EA holds it: the pairs the library keeps up to date (Setting_SymbolTF)
    CSyncManager        *m_SyncManager;            // the EA holds it: what was synced and up to where (Setting_Sync)
    CBarInformationManager *m_BarInformationManager;   // the EA holds it: the alerts of the types (sound_alert, message_alert); given to every ser now)
   //--- Return the timeseries index by symbol name
      int                     IndexTimeSeries(const string symbol);
   //--- Return oneself
    CBarTimeSeriesCollection  *GetObject(void)            { return &this;                     }
   //New in V4 Need V4 Working with Event follow Event Rule 
     void              RefreshTimeseries(CBarTimeSeriesDE *timeseries);
    //--- A pair of Setting_SymbolTF is (1) made (OnInit, SYMBOLTF_MANAGER_EVENT_ADDED): the library judges it, (2) taken away (SYMBOLTF_MANAGER_EVENT_DELETE): the library
    //--- stops, Python Live judges it from its progress (Setting_SymbolTF is what tells Python)
     bool              AddSeries_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe);
     bool              DeleteSeries_BarTimeSeriesCollection(const string symbol,const ENUM_TIMEFRAMES timeframe);
   public:
    //--- Return the timeseries list (public as in DoEasy CTimeSeriesCollection: CSignalsCollection walks the pairs in RAM)
     CArrayObj        *GetList(void)              { return &this.m_list_timeseries; }
    //Setting Pointer
     void              SetSymbolTFManager(CSymbolTFManager *manager)              { this.m_SymbolTFManager=manager;      }
     void              SetSyncManager(CSyncManager *manager)                      { this.m_SyncManager=manager;          }
     void              SetBarInformationManager(CBarInformationManager *manager)  { this.m_BarInformationManager=manager; }
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
     bool                     CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0);    
    // Lifecycle methods
     //--- (BarSeriesDE) do not change: only the rows of the type go, and its marks, then Python judges the type again
      bool                    OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     //--- Lifecycle: opens the file of the account (Accounts\<account key>.sqlite3) and makes its tables when they are not there:
     //--- BarTimeSeriesCollection (what Python found on the bars; the bars themselves are taken from the terminal, V5: none in the DB).
     //--- A table of progress of an EA before Setting_Sync is moved to it
      bool                    OnInitEvent(void);
    //--- A chart change (REASON_CHARTCHANGE): RAM keeps the rows of the bars of each series only, what a view read before them goes (it reads it again)
      void                    OnDeinitEvent(const int reason);
    //--- Set the history depth of (1) the specified timeseries of the specified symbol, (2) the specified timeseries of all symbols
    //--- (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      bool                    SetRequiredUsedData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);  
      bool                    SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool                    SetRequiredUsedData(const string symbol,const uint required=0,const int rates_total=0);
      bool                    SetRequiredUsedData(const uint required=0,const int rates_total=0);
    //--- The rows of the table go to RAM, as SyncData: (1) every pair, (2) one pair. Each CBarSeriesDE does its own (CBarSeriesDE::ReadDataFromDB)
      bool                    ReadDataFromDB(void);
      bool                    ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
    //Need check
   //--- The id of the symbol of ours a symbol of this account is (CSymbolsCollection)
   //--- Return the bar of a symbol and a timeframe (1) by index as in the timeseries (0 = newest), (2) by time
    CBar             *GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const int index);
    CBar             *GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar_time);
   //--- The "New bar" flag of a symbol and a timeframe (true once for a new bar)
    bool              IsNewBar(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The bars follow MT5 (each series tells its new bars; V5: Python judges them), as DoEasy CTimeSeriesCollection::Refresh: (1) a timeseries of a symbol,
   //--- (2) all timeseries of a symbol (OnTick), (3) all timeseries of all symbols (OnTick in the tester), (4) all except the current symbol (OnTimer)
    void              RefreshSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              RefreshSeries(const string symbol);
    void              RefreshSeries(void);
    void              RefreshSeriesAllExceptCurrent(void);
   //--- The rhythm of the EA: a step of the delete of the rows (the table, every pair) of a type whose parameter changed
    //void              OnTimerEvent(void);
                      CBarTimeSeriesCollection(void);
                     ~CBarTimeSeriesCollection(void) {}
  };
#endif // CBARTIMESERIESCOLLECTION_MQH_DECLARATION
#ifndef CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
#define CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
 CBarTimeSeriesCollection::CBarTimeSeriesCollection(void)
  : m_BarInformationManager(NULL),
    m_SymbolTFManager(NULL),
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
 //| A series for every pair of Setting_SymbolTF. Its tables are       |
 //| CBarInformationManager's                                          |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::OnDeinitEvent(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE)
      return;
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      CArrayObj *list=(timeseries!=NULL ? timeseries.GetListSeries() : NULL);
      for(int j=0;list!=NULL && j<list.Total();j++)
        {
         CBarSeriesDE *series=list.At(j);
         CBar *oldest=(series!=NULL && series.GetList().Total()>0 ? series.GetList().At(0) : NULL);
         if(oldest!=NULL)
            series.GetBarControl().DeleteRows(oldest.Time());
        }
     }
  }
 bool CBarTimeSeriesCollection::OnInitEvent(void)
  {
   if(this.m_SymbolTFManager==NULL)
      return false;

   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int total=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   if(total==0)
      return false;
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
   if(series!=NULL)   // it judges and writes its own rows
     {
      series.SetSyncObject(this.m_object_type);
      series.SetSyncManager(this.m_SyncManager);
      series.SetBarInformationManager(this.m_BarInformationManager);
     }
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
 //| The bars of every series follow MT5 (RAM): the series tells a new|
 //| bar itself, SERIES_EVENTS_NEW_BAR: lparam the open time of the   |
 //| newest bar, dparam the TF, sparam the symbol. Then it judges its |
 //| new bars (V2: CBarSeriesDE::Refresh did)                         |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::RefreshSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries!=NULL)
      timeseries.RefreshSeries(timeframe);
  }
 void CBarTimeSeriesCollection::RefreshSeries(void)
  {
   for(int i=0;i<this.m_list_timeseries.Total();i++)
      this.RefreshTimeseries(this.m_list_timeseries.At(i));
  }
 void CBarTimeSeriesCollection::RefreshSeries(const string symbol)
  {
   this.RefreshTimeseries(this.GetTimeseries(symbol));
  }
 void CBarTimeSeriesCollection::RefreshSeriesAllExceptCurrent(void)
  {
   for(int i=0;i<this.m_list_timeseries.Total();i++)
     {
      CBarTimeSeriesDE *timeseries=this.m_list_timeseries.At(i);
      //--- The chart's symbol follows its ticks (OnTick); a symbol with no new tick has no new bar (a closed market): skipped (DoEasy RefreshAllExceptCurrent)
      if(timeseries==NULL || timeseries.Symbol()==::Symbol())
         continue;
      if(timeseries.IsNewTick())
         this.RefreshTimeseries(timeseries);
     }
  }
 //+------------------------------------------------------------------+
 //| Every series of a symbol follows MT5                              |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesCollection::RefreshTimeseries(CBarTimeSeriesDE *timeseries)
  {
   CArrayObj *list=(timeseries!=NULL ? timeseries.GetListSeries() : NULL);
   for(int j=0;list!=NULL && j<list.Total();j++)
     {
      CBarSeriesDE *series=list.At(j);
      if(series!=NULL)
         timeseries.RefreshSeries(series.Timeframe());   // the series tells its new bars itself
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
     }
   return done;
  }
 bool CBarTimeSeriesCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
   if(timeseries==NULL)
      return false;
   return timeseries.ReadDataFromDB(timeframe);
  }
 //+------------------------------------------------------------------+
 //| A parameter of a type changed: the series drop its rows in RAM    |
 //| (each tells it). CSyncManager drops its marks, Python its rows    |
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
         if(series!=NULL)
            series.GetBarControl().DeleteRows(lparam);
        }
     }
   ::Print("Complete ",__FUNCTION__," > the parameter of the type ",lparam," changed: its rows on RAM are gone, the bars stay");
   return true;
  } 
#endif // CBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
#endif // __BARTIMESERIESCOLLECTION_MQH__
