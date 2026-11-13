//+------------------------------------------------------------------+
//|                                           StrategyCollection.mqh |
//|                                     Copyright 2026, Anhnt        |
//| The results of the strategies, as CSignalsCollection for the     |
//| templates: a CStrategyBase for each strategy on each pair of     |
//| Setting_SymbolTF: its rows of StrategyCollection read from DB    |
//| once (Python writes them), then each new bar judged on RAM by    |
//| the rule of the strategy (UseCases\Strategies). New in V5        |
//+------------------------------------------------------------------+
#ifndef __STRATEGYCOLLECTION_MQH__
#define __STRATEGYCOLLECTION_MQH__
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "..\Entities\Strategies\StrategyBase.mqh"
 #include "BarTimeSeriesCollection.mqh"
 #include "Settings\SyncManager.mqh"
 #include "Settings\SymbolTFManager.mqh"
 #include "Settings\StrategyManager.mqh"
 #include "IndicatorsCollection.mqh"
 #include "..\UseCases\Strategies\StrategyProfitunity.mqh"
#ifndef CSTRATEGYCOLLECTION_MQH_DECLARATION
#define CSTRATEGYCOLLECTION_MQH_DECLARATION
 class CStrategyCollection : public CBaseObj
  {
   private:
    CBarTimeSeriesCollection *m_BarTimeSeriesCollection;   // the EA holds it: the bars of a pair (the rows of them are read)
    CSymbolTFManager         *m_SymbolTFManager;           // the EA holds it: the pairs the library keeps (Setting_SymbolTF)
    CSyncManager             *m_SyncManager;               // the EA holds it: Python wrote its part
    CStrategyManager         *m_StrategyManager;           // the EA holds it: the strategies, the table StrategyCollection
    CIndicatorsCollection    *m_IndicatorsCollection;      // the EA holds it: the indicator of a slot on a pair, its values on RAM (the new bars are judged on them)
    CArrayObj                 m_list;                      // the strategies on the pairs (CStrategyBase, owned)
   //--- The CIndicatorDE of a slot of the strategy on the pair of the series (NULL: no template of its params yet)
    CIndicatorDE     *SlotIndicator(CStrategySetting *strategy,const string slot,CStrategyBase *series);
   //--- At a tick: the rule of the strategy looks at the series (its rule says when: Profitunity at a new closed bar of its tf, as isNewBar of the source EA),
   //--- each move stored and told (CStrategyBase::StoreRow). WRONG_VALUE: the values are not on RAM yet, the next tick tries again
    int               Calculate(CStrategyBase *series);
    int               FindIndex(const long strategy_id,const string symbol,const ENUM_TIMEFRAMES timeframe);
    CStrategyBase    *GetOrCreateSeries(const long strategy_id,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- Every strategy on (1) a pair, every pair; the series of a pair go
    void              CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              DeleteSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The rows of a series from_time to to_time go to RAM next to what is there. Returns the rows added (WRONG_VALUE: not read)
    int               ReadDataFromDB(CStrategyBase *series,const datetime from_time,const datetime to_time);
   public:
    void              SetBarTimeSeriesCollection(CBarTimeSeriesCollection *collection) { this.m_BarTimeSeriesCollection=collection; }
    void              SetSymbolTFManager(CSymbolTFManager *manager)                   { this.m_SymbolTFManager=manager; }
    void              SetSyncManager(CSyncManager *manager)                           { this.m_SyncManager=manager; }
    void              SetStrategyManager(CStrategyManager *manager)                   { this.m_StrategyManager=manager; }
    void              SetIndicatorsCollection(CIndicatorsCollection *collection)      { this.m_IndicatorsCollection=collection; }
   //--- A strategy on a pair (NULL: none): a row of Python goes to it (CStrategyBase::StoreRow)
    CStrategyBase    *GetSeries(const long strategy_id,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The strategies on the pairs: their rows on RAM are read by the views (CBarMarkerCollection)
    CArrayObj        *GetList(void)                                                    { return &this.m_list; }
   //--- Lifecycle: a series for every strategy on every pair (the rows come after Python: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
    bool              OnInitEvent(void);
   //--- A chart change (REASON_CHARTCHANGE): RAM keeps the rows of the bars of each series of the pairs only
    void              OnDeinitEvent(const int reason);
   //--- Python wrote its part (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), a pair was added or deleted
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Every strategy runs in realtime (as CSignalsCollection): (1) every symbol (tester), (2) a symbol (the chart's: OnTick), (3) every symbol but the chart's (OnTimer)
    void              RefreshSeries(void);
    void              RefreshSeries(const string symbol);
    void              RefreshSeriesAllExceptCurrent(void);
   //--- The rows of the bars of (1) every pair, (2) one pair go to RAM
    bool              ReadDataFromDB(void);
    bool              ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The rows of every strategy on a pair from_time to to_time go to RAM next to what is there (CBarMarkerCollection asks it). Returns the rows added
    int               ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time);
                      CStrategyCollection(void) : m_BarTimeSeriesCollection(NULL),m_SymbolTFManager(NULL),m_SyncManager(NULL),m_StrategyManager(NULL),m_IndicatorsCollection(NULL)
                                                  { this.m_object_type=COLLECTION_STRATEGY_ID; }
                     ~CStrategyCollection(void) {}
  };
#endif // CSTRATEGYCOLLECTION_MQH_DECLARATION
#ifndef CSTRATEGYCOLLECTION_MQH_IMPLEMENTATION
#define CSTRATEGYCOLLECTION_MQH_IMPLEMENTATION
 bool CStrategyCollection::OnInitEvent(void)
  {
   if(this.m_SymbolTFManager==NULL || this.m_StrategyManager==NULL)
      return false;
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.CreateSeries(symbols[i],timeframes[i]);
   return true;
  }
 void CStrategyCollection::OnDeinitEvent(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE || this.m_BarTimeSeriesCollection==NULL)
      return;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series==NULL)
         continue;
      CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(series.Symbol(),series.Timeframe());
      CBar *oldest=(bars!=NULL && bars.GetList().Total()>0 ? bars.GetList().At(0) : NULL);
      if(oldest!=NULL)
         series.DeleteRows(oldest.Time());
     }
  }
 int CStrategyCollection::FindIndex(const long strategy_id,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series!=NULL && series.StrategyId()==strategy_id && series.Symbol()==symbol && series.Timeframe()==timeframe)
         return i;
     }
   return -1;
  }
 CStrategyBase *CStrategyCollection::GetOrCreateSeries(const long strategy_id,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   int index=this.FindIndex(strategy_id,symbol,timeframe);
   if(index>=0)
      return this.m_list.At(index);
   CStrategyBase *series=new CStrategyBase();
   if(series==NULL)
      return NULL;
   series.SetKey(strategy_id,symbol,timeframe);
   if(!this.m_list.Add(series))
     {
      delete series;
      return NULL;
     }
   return series;
  }
 CStrategyBase *CStrategyCollection::GetSeries(const long strategy_id,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   const int index=this.FindIndex(strategy_id,symbol,timeframe);
   return (index>=0 ? this.m_list.At(index) : NULL);
  }
 void CStrategyCollection::CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   long ids[];
   int total=this.m_StrategyManager.Read_RAM(ids);
   for(int s=0;s<total;s++)
      this.GetOrCreateSeries(ids[s],symbol,timeframe);
  }
 void CStrategyCollection::DeleteSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series!=NULL && series.Symbol()==symbol && series.Timeframe()==timeframe)
         this.m_list.Delete(i);
     }
  }
 bool CStrategyCollection::ReadDataFromDB(void)
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
 bool CStrategyCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return false;
   CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(symbol,timeframe);
   CArrayObj *list_bars=(bars!=NULL ? bars.GetList() : NULL);
   if(list_bars==NULL || list_bars.Total()==0)
      return false;
   CBar *oldest=list_bars.At(0);
   CBar *newest=list_bars.At(list_bars.Total()-1);
   if(oldest==NULL || newest==NULL)
      return false;
   int made=0,loaded=0;
   bool done=true;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
         continue;
      made++;
      series.DeleteRows(newest.Time()+1);   // every row is read again
      int rows=this.ReadDataFromDB(series,oldest.Time(),newest.Time());
      done=(rows>=0 && done);
      loaded+=(rows>0 ? rows : 0);
     }
   ::Print("Complete ",__FUNCTION__," > ",symbol," ",::EnumToString(timeframe),": ",loaded," rows of StrategyCollection read for the ",made," strategies of the pair, on the ",
           list_bars.Total()," bars of the series");
   return done;
  }
 int CStrategyCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time)
  {
   if(this.m_SyncManager==NULL || !this.m_SyncManager.IsPythonDone())
      return 0;   // Python writes the pairs now: read after PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE
   int loaded=0;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series!=NULL && series.Symbol()==symbol && series.Timeframe()==timeframe)
         loaded+=::MathMax(this.ReadDataFromDB(series,from_time,to_time),0);
     }
   return loaded;
  }
 int CStrategyCollection::ReadDataFromDB(CStrategyBase *series,const datetime from_time,const datetime to_time)
  {
   if(series==NULL || this.m_StrategyManager==NULL)
      return WRONG_VALUE;
   long times[],sides[];
   string roles[];
   const int total=this.m_StrategyManager.ReadDataFromDB(series.Symbol(),series.Timeframe(),from_time,to_time,series.StrategyId(),times,roles,sides);
   if(total==WRONG_VALUE)
      return WRONG_VALUE;
   int loaded=0;
   for(int r=0;r<total;r++)
      if(series.AddRow((datetime)times[r],roles[r],(ENUM_SIGNAL_DIRECTION)sides[r]))   // a row there already is kept
         loaded++;
   return loaded;
  }
 CIndicatorDE *CStrategyCollection::SlotIndicator(CStrategySetting *strategy,const string slot,CStrategyBase *series)
  {
   CStrategyIndicatorSetting *row=strategy.Indicator(slot);
   string params_text;
   if(row==NULL || this.m_IndicatorsCollection==NULL || !this.m_StrategyManager.Read_RAM(row,params_text))
      return NULL;
   return this.m_IndicatorsCollection.GetIndicator((ENUM_INDICATOR)row.SourceId(),params_text,series.Symbol(),series.Timeframe());
  }
 int CStrategyCollection::Calculate(CStrategyBase *series)
  {
   CStrategySetting *strategy=(this.m_StrategyManager!=NULL ? this.m_StrategyManager.Read_RAM(series.StrategyId()) : NULL);
   if(strategy==NULL || this.m_SyncManager==NULL || !this.m_SyncManager.IsPythonDone())
      return 0;   // the history is read after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE): the positions open come from it
   ENUM_TIMEFRAMES timeframe=strategy.Timeframe();
   if(timeframe==PERIOD_CURRENT)
      timeframe=::Period();   // not set: the tf of the chart
   if(series.Timeframe()!=timeframe)
      return 0;   // the strategy computes its indicators and its entries on its own tf only
   const datetime bar=::iTime(series.Symbol(),series.Timeframe(),1);
   if(bar==0 || series.JudgedTo()==bar)
      return 0;   // Profitunity: no new closed bar of its tf since the last tick (isNewBar of the source EA)
   string roles[];
   ENUM_SIGNAL_DIRECTION sides[];
   int moves=0;
   if(strategy.Name()==PROFITUNITY_NAME)
     {
      CIndicatorDE *fractals=this.SlotIndicator(strategy,"Fractals",series),*alligator=this.SlotIndicator(strategy,"Alligator",series);
      CIndicatorDE *ao=this.SlotIndicator(strategy,"AO",series),*ac=this.SlotIndicator(strategy,"AC",series);
      CIndicatorDE *slots[4];
      slots[0]=fractals;
      slots[1]=alligator;
      slots[2]=ao;
      slots[3]=ac;
      for(int s=0;s<4;s++)
         if(slots[s]!=NULL)
            slots[s].GetSeriesData().Refresh();   // the bar that just closed with its last value (its new bar event may come after this tick)
      moves=CStrategyProfitunity::Calculate(fractals,alligator,ao,ac,series.Symbol(),series.Timeframe(),1,
                                            series.OpenTotal(SIGNAL_DIRECTION_BUY),series.OpenTotal(SIGNAL_DIRECTION_SELL),roles,sides);
     }
   if(moves==WRONG_VALUE)
      return WRONG_VALUE;   // not judged: the next tick tries again
   series.SetJudgedTo(bar);
   for(int i=0;i<moves;i++)
      series.StoreRow(bar,roles[i],sides[i],true);   // RAM only: Python saves the same row, its line of this bar is refused
   return moves;
  }
 void CStrategyCollection::RefreshSeries(void)
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series!=NULL)
         this.Calculate(series);
     }
  }
 void CStrategyCollection::RefreshSeries(const string symbol)
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series!=NULL && series.Symbol()==symbol)
         this.Calculate(series);
     }
  }
 void CStrategyCollection::RefreshSeriesAllExceptCurrent(void)
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CStrategyBase *series=this.m_list.At(i);
      if(series!=NULL && series.Symbol()!=::Symbol())
         this.Calculate(series);   // the chart's symbol runs in OnTick
     }
  }
 bool CStrategyCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- Python wrote the first chunk of every pair: the rows go to RAM again
   if(id==CHARTEVENT_CUSTOM+PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
      return this.ReadDataFromDB();
   //--- A pair: lparam = its TF, sparam = its symbol
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
     {
      this.CreateSeries(sparam,(ENUM_TIMEFRAMES)lparam);
      return true;
     }
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      this.DeleteSeries(sparam,(ENUM_TIMEFRAMES)lparam);
      return true;
     }
   return false;
  }
#endif // CSTRATEGYCOLLECTION_MQH_IMPLEMENTATION
#endif // __STRATEGYCOLLECTION_MQH__
