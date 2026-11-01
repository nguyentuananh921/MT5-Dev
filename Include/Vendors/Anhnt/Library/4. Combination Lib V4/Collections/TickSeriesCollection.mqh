//+------------------------------------------------------------------+
//|                                         TickSeriesCollection.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- TEMPORARY UNUSED (2026-10-31): nothing includes it. DoEasy made the tick series for the DOM; V1 / V2 never used it; ported to V4 it held the EA 70 s
//--- (649604 ticks of XAUUSD as objects). The Bid / Ask of a deal is CopyTicksRange of COrder::BidAskFromTicks, the pause of a symbol is CNewTickObj
//--- Change from DoEasy Collections\TickSeriesCollection.mqh (V2 Collections\TickSeriesCollection.mqh): the name CTickSeriesCollection is kept; its series
//--- CTickSeries -> CTickSeriesDE, Refresh / RefreshExpectCurrent -> RefreshSeries / RefreshSeriesAllExceptCurrent (as CBarTimeSeriesCollection)
//--- The ticks of the symbols of Setting_SymbolTF, RAM only, no table (Readme "Live on RAM, Save on DB for no more calculation"). It holds the pause of a symbol
//--- (no tick for TICK_PAUSE_SECONDS: a closed market): TICK_EVENT_PAUSE / RESUME go to the chart, the other hands ask IsPaused (as CSyncManager::IsPythonDone)
#ifndef __TICKSERIESCOLLECTION_MQH__
#define __TICKSERIESCOLLECTION_MQH__
 #include "ListObj.mqh"
 #include "..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "..\Entities\Ticks\TickSeriesDE.mqh"
 #include "Settings\SymbolTFManager.mqh"
#ifndef CTICKSERIESCOLLECTION_MQH_DECLARATION
#define CTICKSERIESCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Collection of tick series symbols                                |
 //+------------------------------------------------------------------+
 class CTickSeriesCollection : public CBaseObjExt
  {
   private:
    CListObj          m_list;                                      // List of used symbol tick series (CTickSeriesDE), one for each symbol of Setting_SymbolTF
    CSymbolTFManager *m_SymbolTFManager;                           // the EA holds it: the symbols of the pairs the library keeps up to date
   //--- Return the tick series index by symbol name
    int               IndexTickSeries(const string symbol);
   //--- A symbol of Setting_SymbolTF (1) gets its tick series, (2) has no pair left: its tick series goes
    bool              AddSeries_TickSeriesCollection(const string symbol);
    bool              DeleteSeries_TickSeriesCollection(const string symbol);
   //--- The events of a tick series go to the chart once (the parent and the siblings hear them)
    void              SendEvents_TickSeriesCollection(CTickSeriesDE *tickseries);
   public:
   //--- Return the tick series collection list and the number of tick series in the list
    CArrayObj        *GetList(void)                                { return &this.m_list;        }
    int               DataTotal(void)                        const { return this.m_list.Total(); }
    void              SetSymbolTFManager(CSymbolTFManager *manager){ this.m_SymbolTFManager=manager; }
   //--- Return the pointer to the tick series object (1) by symbol and (2) by index in the list
    CTickSeriesDE    *GetTickseries(const string symbol);
    CTickSeriesDE    *GetTickseries(const int index)               { return this.m_list.At(index);}
   //--- Create a collection list: a tick series for each symbol of the pairs of Setting_SymbolTF (the ticks are copied at its first RefreshSeries)
    bool              CreateCollection(CSymbolTFManager *manager);
   //--- The symbol rests (TICK_EVENT_PAUSE until TICK_EVENT_RESUME): nothing new on it, its hands skip it
    bool              IsPaused(const string symbol);
   //--- A pair added or deleted (SYMBOLTF_MANAGER_EVENT_ADDED / DELETE): the tick series of its symbol is made or goes
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Update (1) a tick series of a specified symbol (OnTick), (2) all symbols (the tester) and (3) all symbols except the current one (OnTimer)
    void              RefreshSeries(const string symbol);
    void              RefreshSeries(void);
    void              RefreshSeriesAllExceptCurrent(void);
                      CTickSeriesCollection(void);
  };
#endif // CTICKSERIESCOLLECTION_MQH_DECLARATION
#ifndef CTICKSERIESCOLLECTION_MQH_IMPLEMENTATION
#define CTICKSERIESCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CTickSeriesCollection::CTickSeriesCollection(void) : m_SymbolTFManager(NULL)
  {
   this.m_type=COLLECTION_TICKSERIES_ID;
   this.m_list.Clear();
   this.m_list.Sort();
   this.m_list.Type(COLLECTION_TICKSERIES_ID);
  }
 //+------------------------------------------------------------------+
 //| Create a collection list of symbol tick series                   |
 //+------------------------------------------------------------------+
 bool CTickSeriesCollection::CreateCollection(CSymbolTFManager *manager)
  {
   if(manager==NULL)
      return false;
   this.m_SymbolTFManager=manager;
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int total=manager.Pairs(symbols,timeframes);
   //--- The series that are there stay (a chart change runs OnInit again): only a new symbol gets one, a symbol with no pair left goes
   bool complete=true;
   for(int i=0;i<total;i++)
      complete=this.AddSeries_TickSeriesCollection(symbols[i]) && complete;
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CTickSeriesDE *tickseries=this.m_list.At(i);
      bool kept=false;
      for(int k=0;tickseries!=NULL && k<total && !kept;k++)
         kept=(symbols[k]==tickseries.Symbol());
      if(tickseries!=NULL && !kept)
         this.DeleteSeries_TickSeriesCollection(tickseries.Symbol());
     }
   return complete;
  }
 //+------------------------------------------------------------------+
 //| A symbol of Setting_SymbolTF gets its tick series                 |
 //+------------------------------------------------------------------+
 bool CTickSeriesCollection::AddSeries_TickSeriesCollection(const string symbol)
  {
   if(this.GetTickseries(symbol)!=NULL)
      return true;
   CTickSeriesDE *tickseries=new CTickSeriesDE(symbol);
   if(tickseries==NULL)
      return false;
   this.m_list.Sort();
   if(!this.m_list.InsertSort(tickseries))
     {
      delete tickseries;
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| A symbol has no pair of Setting_SymbolTF left: its ticks go       |
 //+------------------------------------------------------------------+
 bool CTickSeriesCollection::DeleteSeries_TickSeriesCollection(const string symbol)
  {
   int index=this.IndexTickSeries(symbol);
   if(index==WRONG_VALUE)
      return false;
   return this.m_list.Delete(index);
  }
 //+------------------------------------------------------------------+
 //| Return the tick series index by symbol name                      |
 //+------------------------------------------------------------------+
 int CTickSeriesCollection::IndexTickSeries(const string symbol)
  {
   CTickSeriesDE *obj=new CTickSeriesDE();   // the key of the search: no tick is asked to MT5 for it
   if(obj==NULL)
      return WRONG_VALUE;
   obj.SetSymbol(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
   this.m_list.Sort();
   int index=this.m_list.Search(obj);
   delete obj;
   return index;
  }
 //+------------------------------------------------------------------+
 //| Return the object of tick series of a specified symbol           |
 //+------------------------------------------------------------------+
 CTickSeriesDE *CTickSeriesCollection::GetTickseries(const string symbol)
  {
   int index=this.IndexTickSeries(symbol);
   return(index==WRONG_VALUE ? NULL : this.m_list.At(index));
  }
 //+------------------------------------------------------------------+
 //| The symbol rests                                                  |
 //+------------------------------------------------------------------+
 bool CTickSeriesCollection::IsPaused(const string symbol)
  {
   CTickSeriesDE *tickseries=this.GetTickseries(symbol);
   return(tickseries!=NULL && tickseries.IsPaused());
  }
 //+------------------------------------------------------------------+
 //| A pair added or deleted: the tick series of its symbol            |
 //+------------------------------------------------------------------+
 bool CTickSeriesCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- lparam = the TF of the pair, sparam = its symbol
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
      return this.AddSeries_TickSeriesCollection(sparam);
   if(id!=CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE || this.m_SymbolTFManager==NULL)
      return false;
   ENUM_TIMEFRAMES tfs[];
   if(this.m_SymbolTFManager.TimeframesOf(sparam,tfs)>0)
      return false;   // the symbol has other pairs: its ticks stay
   return this.DeleteSeries_TickSeriesCollection(sparam);
  }
 //+------------------------------------------------------------------+
 //| Update a tick series of a specified symbol                       |
 //+------------------------------------------------------------------+
 void CTickSeriesCollection::RefreshSeries(const string symbol)
  {
   this.m_list_events.Clear();
   this.m_is_event=false;
   CTickSeriesDE *tickseries=this.GetTickseries(symbol);
   if(tickseries==NULL)
      return;
   tickseries.RefreshSeries();
   this.SendEvents_TickSeriesCollection(tickseries);
  }
 //+------------------------------------------------------------------+
 //| Update tick series of all symbols                                |
 //+------------------------------------------------------------------+
 void CTickSeriesCollection::RefreshSeries(void)
  {
   this.m_list_events.Clear();
   this.m_is_event=false;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CTickSeriesDE *tickseries=this.m_list.At(i);
      if(tickseries==NULL)
         continue;
      tickseries.RefreshSeries();
      this.SendEvents_TickSeriesCollection(tickseries);
     }
  }
 //+------------------------------------------------------------------+
 //| Update tick series of all symbols except the current one         |
 //+------------------------------------------------------------------+
 void CTickSeriesCollection::RefreshSeriesAllExceptCurrent(void)
  {
   this.m_list_events.Clear();
   this.m_is_event=false;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CTickSeriesDE *tickseries=this.m_list.At(i);
      if(tickseries==NULL || tickseries.Symbol()==::Symbol())
         continue;   // the chart's symbol follows its ticks (OnTick)
      tickseries.RefreshSeries();
      this.SendEvents_TickSeriesCollection(tickseries);
     }
  }
 //+------------------------------------------------------------------+
 //| The events of a tick series go to the chart once                  |
 //+------------------------------------------------------------------+
 void CTickSeriesCollection::SendEvents_TickSeriesCollection(CTickSeriesDE *tickseries)
  {
   CArrayObj *events=(tickseries!=NULL && tickseries.IsEvent() ? tickseries.GetListEvents() : NULL);
   for(int e=0;events!=NULL && e<events.Total();e++)
     {
      CEventBaseObj *event=events.At(e);
      if(event==NULL || !this.EventAdd((ushort)event.ID(),event.LParam(),event.DParam(),event.SParam()))
         continue;   // told already
      this.m_is_event=true;
      ::EventChartCustom(::ChartID(),(ushort)event.ID(),event.LParam(),event.DParam(),event.SParam());   // the parent and the siblings hear it
     }
  }
#endif // CTICKSERIESCOLLECTION_MQH_IMPLEMENTATION
#endif // __TICKSERIESCOLLECTION_MQH__
