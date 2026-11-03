//+------------------------------------------------------------------+
//|                                                EA V4 SQLLite.mq5 |
//+------------------------------------------------------------------+
#property strict
#include "Configuration\EA Configuration.mqh"   // what the EA decides (the database), before the library
#include "GUIPannel\GUIPannel.mqh"
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\AccountsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\IndicatorTemplateManager.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\BarInformationManager.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\SyncManager.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\IndicatorsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\BarTimeSeriesCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\SignalsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\HistoryCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\MarketCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\TradeEventsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Trading\TradingControl.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\GraphElementsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V4\Services\DELib\DatabaseService.mqh> 
#include "Services\BarMarkerSync.mqh"
#include "Services\PythonBridge.mqh"
//--- The EA is the parent: it owns its children and the models, and passes the events down to them
CAccountsCollection m_AccountsCollection; // the accounts: the table accounts, the account of the terminal has its row
CSymbolsCollection m_SymbolsCollection;   // the symbols of this account, read from the database
CSymbolTFManager   m_SymbolTFManager;     // the pairs Symbol+TF, read from the database
CIndicatorTemplateManager m_IndicatorTemplateManager;   // the indicator templates, read from the database
CBarInformationManager m_BarInformationManager;   // the information of a bar (the candle patterns), read from the database
CSyncManager       m_SyncManager;         // what was synced and up to where (Setting_Sync): Python and the library mark it, the markers look at it
CIndicatorsCollection m_IndicatorsCollection;   // the indicator of each template on each pair of Setting_SymbolTF: the one handle the signals read and the chart shows
CBarTimeSeriesCollection m_BarTimeSeriesCollection;   // the bars of every symbol and timeframe: the series are added when a class asks for them
CSignalsCollection m_SignalsCollection;   // the signals of the indicator templates on the bars: the table SignalsCollection
CHistoryCollection m_HistoryCollection;   // the history of the terminal in RAM (GetList); the table Orders is its own: the lines it keeps are not written again
CMarketCollection  m_MarketCollection;    // the pending orders and the positions on the account: RAM only (GetList), never in the table Orders
CTradeEventsCollection m_TradeEventsCollection;   // the trading events of the account: each one is a line of the table TradeEvent
CTradingControl    m_TradingControl;      // the trading requests and the pending requests of them (RAM), on the lists of the collections (V1 CTradingEngine::m_trading_control)
CGraphElementsCollection m_GraphElementsCollection;   // the layer over the chart and the markers on it
CPythonBridge      m_PythonBridge;        // starts Python when it is not running: the tables are made before, Python only adds rows
CBarMarkerSync     m_BarMarkerSync;       // the View of the table BarTimeSeriesCollection: the markers of what Python found
CChartObj         *m_ChartObj=NULL;       // the chart the EA runs on
CGUIPannel         m_GUIPannel;
CDatabaseService *m_DatabaseService = NULL; //Prepare to replace DatabaseDELib
ulong              g_series_refresh_ms=0;  // when the bars of the chart were read last (EA_SERIES_REFRESH_MS)
ulong              g_trade_refresh_ms=0;   // when the history, the orders and the events were looked at last (EA_TRADE_REFRESH_MS)
ulong              g_history_until_ms=0;   // a trade happened: the history of the terminal is looked at until then (EA_HISTORY_WATCH_MS)
bool               g_trade_started=false;  // the first launch flag of TradeEventsControl (V1 m_is_first_start): the history, the orders and positions were looked at once, then only after a trade
ulong              g_debug_ms=0;            // MY DEBUG
bool               g_debug_first_timer=false; // MY DEBUG
//+------------------------------------------------------------------+
int OnInit()
  {
   Breadcrumb("OnInit: LibDatabase_Create");
   if(!LibDatabase_Create())   // no database file yet (first run, or the folder was deleted): make it before any class opens it
      return(INIT_FAILED);
   Breadcrumb("OnInit: DatabaseService_Create");
   // Build account key & open Account DB   
   string account_key =::AccountInfoString(ACCOUNT_COMPANY) + ::AccountInfoString(ACCOUNT_SERVER) + "_" + (string)::AccountInfoInteger(ACCOUNT_LOGIN);
   m_DatabaseService = new CDatabaseService("NewSQLite", "Accounts", account_key + ".sqlite3", account_key);
   if(m_DatabaseService == NULL || !m_DatabaseService.OnInitEvent())
     {
      if(m_DatabaseService != NULL)
        {
         delete m_DatabaseService;
         m_DatabaseService = NULL;
        }
      return INIT_FAILED;
     }
   //--- Every model writes its own table, after the tables it depends on: timeframes, accounts, then symbol_account, then Setting_SymbolTF
   if(m_ChartObj!=NULL)
      delete m_ChartObj;
   m_ChartObj=new CChartObj(::ChartID());   // the indicators the chart holds are read when it is made
   // makes Setting_IndicatorTemplate and the table timeframes (all the TFs of MT5, which Setting_SymbolTF refers to), the indicators of the chart are templates
    Breadcrumb("OnInit: m_IndicatorTemplateManager.OnInitEvent");
    m_IndicatorTemplateManager.SetDatabaseService(m_DatabaseService);
    if(!m_IndicatorTemplateManager.OnInitEvent(m_ChartObj))
      return INIT_FAILED;   
    
   // m_AccountsCollection  
    Breadcrumb("OnInit: m_AccountsCollection.OnInitEvent");
    m_AccountsCollection.OnInitEvent();
   // m_SymbolsCollection
    Breadcrumb("OnInit: m_SymbolsCollection.OnInitEvent");
    m_SymbolsCollection.OnInitEvent();
   // m_SymbolTFManager
    Breadcrumb("OnInit: m_SymbolTFManager.OnInitEvent");
    m_SymbolTFManager.OnInitEvent();
   // m_BarInformationManager
    Breadcrumb("OnInit: m_BarInformationManager.OnInitEvent");
    m_BarInformationManager.OnInitEvent();   // makes Setting_BarInformation and Setting_BarSetup, fills what every type of information is     
   // m_SyncManager
    Breadcrumb("OnInit: m_SyncManager.OnInitEvent");
    m_SyncManager.OnInitEvent();   // makes Setting_Sync: the collections move their old table of progress there when they open the file of the account
   // m_HistoryCollection + m_MarketCollection
    Breadcrumb("OnInit: m_HistoryCollection.OnInitEvent");
    m_HistoryCollection.SetSymbolsCollection(&m_SymbolsCollection);   // the owner of symbol_account: the id of a symbol
    m_HistoryCollection.SetSyncManager(&m_SyncManager);
    m_HistoryCollection.OnInitEvent();   // the table Orders is its own (the history only): made when not there, its lines read (which orders are written, the Bid / Ask of the deals)
    m_MarketCollection.SetSymbolsCollection(&m_SymbolsCollection);   // the pending orders and positions on the account: RAM only
    Breadcrumb("OnInit: m_TradeEventsCollection.OnInitEvent");
   // m_TradeEventsCollection
    m_TradeEventsCollection.SetSymbolsCollection(&m_SymbolsCollection);
    m_TradeEventsCollection.SetSyncManager(&m_SyncManager);
    m_TradeEventsCollection.OnInitEvent();   // opens the file of the account and makes the table TradeEvent (the events themselves are in RAM, V3)
   // m_TradingControl (DoEasy CEngine::CollectionOnInit)
    Breadcrumb("OnInit: m_TradingControl.OnInit");
    m_TradingControl.OnInit(m_AccountsCollection.GetCurrentAccount(),&m_SymbolsCollection,&m_MarketCollection,&m_HistoryCollection,&m_TradeEventsCollection);
   // m_IndicatorsCollection
    Breadcrumb("OnInit: m_IndicatorsCollection.OnInitEvent");
    m_IndicatorsCollection.SetSymbolTFManager(&m_SymbolTFManager);   // the pairs
    m_IndicatorsCollection.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);   // the templates
    m_IndicatorsCollection.SetDatabaseService(m_DatabaseService);
    m_IndicatorsCollection.OnInitEvent();   // every template on every pair: its handle
   // m_BarTimeSeriesCollection
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.SetSymbolsCollection");
    m_BarTimeSeriesCollection.SetSymbolsCollection(&m_SymbolsCollection);   // the owner of symbol_account: the id of a symbol 
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.SetSyncManager");
    m_BarTimeSeriesCollection.SetSyncManager(&m_SyncManager);
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.SetSymbolTFManager");
    m_BarTimeSeriesCollection.SetSymbolTFManager(&m_SymbolTFManager);   // the pairs the library keeps up to date after OnInit
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.SetBarInformationManager");
    m_BarTimeSeriesCollection.SetBarInformationManager(&m_BarInformationManager);   // the parameters of the types it finds
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.OnInitEvent");
    if(!m_BarTimeSeriesCollection.OnInitEvent())// opens the file of the account and makes its tables (the bars, what was found on them)
      {
        ::Print(__FUNCTION__," > failed to OnInitEvent BarTimeSeriesCollection");
        return INIT_FAILED;
       }
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.CreateCollection"); 
     //m_BarTimeSeriesCollection.CreateCollection(m_SymbolsCollection.GetList());   // one timeseries object for each symbol
     //Breadcrumb("OnInit: m_BarTimeSeriesCollection.CreateSeries");
     //m_BarTimeSeriesCollection.CreateSeries(::Symbol(),(ENUM_TIMEFRAMES)::Period());   // the bars of the chart: the others are added when a class asks for them
    if(!m_BarTimeSeriesCollection.CreateCollection(&m_SymbolTFManager))
      {
       ::Print(__FUNCTION__," > failed to create the BarTimeSeriesCollection");
       return INIT_FAILED;
      }
   // m_GraphElementsCollection
    Breadcrumb("OnInit: m_GraphElementsCollection.OnInit");
    m_GraphElementsCollection.OnInit();   // the layer is made before the panel windows, so they stack above it
   // m_SignalsCollection
    Breadcrumb("OnInit: m_SignalsCollection.SetBarTimeSeriesCollection");
    m_SignalsCollection.SetBarTimeSeriesCollection(&m_BarTimeSeriesCollection);   // the bars the signals are found on
    Breadcrumb("OnInit: m_SignalsCollection.SetSyncManager");
    m_SignalsCollection.SetSyncManager(&m_SyncManager);
    Breadcrumb("OnInit: m_SignalsCollection.SetSymbolTFManager");
    m_SignalsCollection.SetSymbolTFManager(&m_SymbolTFManager);   // the pairs the library keeps up to date after OnInit
    Breadcrumb("OnInit: m_SignalsCollection.SetIndicatorTemplateManager");
    m_SignalsCollection.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);   // the templates whose signals it finds
    m_SignalsCollection.SetIndicatorsCollection(&m_IndicatorsCollection);   // the indicator of a template on a pair: its values in RAM
    Breadcrumb("OnInit: m_SignalsCollection.OnInitEvent");
    m_SignalsCollection.OnInitEvent();   // makes the tables of the signals in the file of the account
   // m_PythonBridge
    Breadcrumb("OnInit: m_PythonBridge.OnInitEvent");
    m_PythonBridge.OnInitEvent();   // after every table is made: Python starts when it finds none running
    g_debug_ms=::GetTickCount64();   // MY DEBUG
   // m_BarMarkerSync
    Breadcrumb("OnInit: m_BarMarkerSync.OnInitEvent");
    m_BarMarkerSync.OnInitEvent(&m_GraphElementsCollection,&m_BarTimeSeriesCollection,&m_SignalsCollection,&m_BarInformationManager,&m_IndicatorTemplateManager);
    ::Print("MY DEBUG    OnInit: m_BarMarkerSync.OnInitEvent took ",::GetTickCount64()-g_debug_ms," ms");
    g_debug_ms=::GetTickCount64();   // MY DEBUG
   // m_GUIPannel
    Breadcrumb("OnInit: m_GUIPannel.SetSymbolsCollection");
    m_GUIPannel.SetSymbolsCollection(&m_SymbolsCollection);
    m_GUIPannel.SetHistoryCollection(&m_HistoryCollection);   // the tables of the Trade Manage window are read through it
    m_GUIPannel.SetAccountsCollection(&m_AccountsCollection);   // the balance of the status bar, the profit of the caption
    m_GUIPannel.SetMarketCollection(&m_MarketCollection);   // the numbers of the positions on the caption
    Breadcrumb("OnInit: m_GUIPannel.SetSymbolTFManager");
    m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);
    Breadcrumb("OnInit: m_GUIPannel.SetIndicatorTemplateManager");
    m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
    Breadcrumb("OnInit: m_GUIPannel.SetBarInformationManager");
    m_GUIPannel.SetBarInformationManager(&m_BarInformationManager);
    Breadcrumb("OnInit: m_GUIPannel.SetBarTimeSeriesCollection");
    m_GUIPannel.SetBarTimeSeriesCollection(&m_BarTimeSeriesCollection);   // the popup of a candle asks what was found on it
    Breadcrumb("OnInit: m_GUIPannel.SetSignalsCollection");
    m_GUIPannel.SetSignalsCollection(&m_SignalsCollection);
    Breadcrumb("OnInit: m_GUIPannel.SetGraphElementsCollection");
    m_GUIPannel.SetGraphElementsCollection(&m_GraphElementsCollection);   // and lights the box of the candle on its marker
    Breadcrumb("OnInit: m_GUIPannel.OnInit");
    if(!m_GUIPannel.OnInit(_UninitReason))
        return(INIT_FAILED);
    ::Print("MY DEBUG    OnInit: the m_GUIPannel setters and m_GUIPannel.OnInit took ",::GetTickCount64()-g_debug_ms," ms");
    g_debug_ms=::GetTickCount64();   // MY DEBUG: OnTimer tells how long after OnInit it came first
    g_debug_first_timer=true;        // MY DEBUG
   ::EventSetMillisecondTimer(EA_TIMER_MS);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   m_BarTimeSeriesCollection.SyncDataToDB();   // what the library found and has not written yet goes to the table, then its progress (not written: judged again next time)
   m_SignalsCollection.SyncDataToDB();         // the same for the signals of the indicator templates
   m_HistoryCollection.SyncDataToDB();         // the orders and deals of the history that have no line yet
   m_TradeEventsCollection.SyncDataToDB();     // the trading events that have no line yet
   m_PythonBridge.OnDeinitEvent(reason);   // the EA is closed: the row of Python is cleared, Python stops with its workers
   LibDatabase_GiveTurn();
   m_GUIPannel.OnDeinit(reason);
   m_BarMarkerSync.DeleteMarkers_BarTimeSeriesCollection();   // the markers and the box on the candle
   if(m_ChartObj!=NULL)
     {
      delete m_ChartObj;
      m_ChartObj=NULL;
     }
   if(m_DatabaseService != NULL)
    {
     delete m_DatabaseService;
     m_DatabaseService = NULL;
    }
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   m_AccountsCollection.RefreshAccount();   // the account follows the terminal (RAM); its events (balance, credit, permissions, terms) go to the chart
   //--- The series follow the ticks (DoEasy CEngine::OnTick): the chart's symbol; in the tester every symbol (no OnTimer there, as the DoEasy EAs)
   //--- The signals follow the series they are judged on (the newest closed bar is there now)
   if(::MQLInfoInteger(MQL_TESTER))
     {
      m_BarTimeSeriesCollection.RefreshSeries();
      m_SignalsCollection.RefreshSeries();
     }
   else
     {
      m_BarTimeSeriesCollection.RefreshSeries(::Symbol());
      m_SignalsCollection.RefreshSeries(::Symbol());
     }
   m_GUIPannel.OnTickEvent();
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(g_debug_first_timer)   // MY DEBUG
     {
      g_debug_first_timer=false;
      ::Print("MY DEBUG    OnTimer: the first call came ",::GetTickCount64()-g_debug_ms," ms after the end of OnInit");
     }
   ulong debug_timer_ms=::GetTickCount64();   // MY DEBUG
   Breadcrumb("OnTimer: m_SymbolsCollection.OnTimerEvent");
   m_SymbolsCollection.OnTimerEvent();   // the Market Watch, once a second (V3): a new symbol gets its line in symbol_account, its event goes to the chart
   Breadcrumb("OnTimer: m_GUIPannel.OnTimerEvent");
   m_GUIPannel.OnTimerEvent();   // the controls take their steps from it (the spin buttons)
   Breadcrumb("OnTimer: m_BarMarkerSync.ArrangeIfPending");
   m_BarMarkerSync.ArrangeIfPending();   // the chart moved or zoomed: the badges are placed again
   Breadcrumb("OnTimer: m_GraphElementsCollection.OnTimerEvent");
   m_GraphElementsCollection.OnTimerEvent();   // the markers: the layer is painted again when one asked
   //--- The history of the terminal goes to the table Orders: the past beat after beat from OnInit on, later only for a while after a trade
   //--- The history, the pending orders and positions and the events are written at the pace of the beat, like the other tables
   if(::GetTickCount64()-g_trade_refresh_ms>=EA_TRADE_REFRESH_MS)
    {
      g_trade_refresh_ms=::GetTickCount64();
      //--- The EA as CEngine (V1 CTradingEngine::TradeEventsControl): each trading event goes to the chart itself (CTradeEvent::SendEvent), the GUI hears it
      if(!g_trade_started || ::GetTickCount64()<g_history_until_ms)
        {
         Breadcrumb("OnTimer: TradeEventsControl");
         TradeEventsControl();
        }
      Breadcrumb("OnTimer: m_TradingControl.OnTimer");
      m_TradingControl.OnTimer();   // the list of pending requests (DoEasy CEngine::OnTimer)
    }
   //--- The bars of every series: a new bar sends SERIES_EVENT_NEW_BAR; the library judges the new bars of the pairs of Setting_SymbolTF and writes what it finds
   if(::GetTickCount64()-g_series_refresh_ms>=EA_SERIES_REFRESH_MS)
     {
      g_series_refresh_ms=::GetTickCount64();
      // Bar Time Series Collection: every series follows MT5, judges and writes its new bars itself; the events go to the chart (SERIES_EVENTS_NEW_BAR, SERIES_EVENTS_PATTERN)
       Breadcrumb("OnTimer: m_BarTimeSeriesCollection.RefreshSeriesAllExceptCurrent");
       if(!::MQLInfoInteger(MQL_TESTER))
          m_BarTimeSeriesCollection.RefreshSeriesAllExceptCurrent();   // the other symbols have no tick on this chart (DoEasy CEngine::OnTimer)
       Breadcrumb("OnTimer: m_BarTimeSeriesCollection.OnTimerEvent");
       m_BarTimeSeriesCollection.OnTimerEvent();   // a step of the delete of the rows of a type whose parameter changed (the table, every pair)
      // Signal Collection: the same rhythm as the series (the chart's symbol is in OnTick)
       Breadcrumb("OnTimer: m_SignalsCollection.RefreshSeriesAllExceptCurrent");
       if(!::MQLInfoInteger(MQL_TESTER))
          m_SignalsCollection.RefreshSeriesAllExceptCurrent();
       Breadcrumb("OnTimer: m_SignalsCollection.OnTimerEvent");
       m_SignalsCollection.OnTimerEvent();   // a step of the delete of the signals of a deleted template (the table, every pair)
      // Trade Event Collection
       m_TradeEventsCollection.SyncDataToDB();   // the events the database refused are written again
       Breadcrumb("OnTimer: m_PythonBridge.OnTimerEvent");
      m_PythonBridge.OnTimerEvent();    // Python that stopped is started again
      Breadcrumb("OnTimer: done");
     }
   LibDatabase_GiveTurn();   // a beat never ends holding the turn of the writes: the workers of Python write in the meantime
   if(::GetTickCount64()-debug_timer_ms>=1000)   // MY DEBUG: a beat that holds the thread of the EA for a second or more
      ::Print("MY DEBUG    OnTimer: this call took ",::GetTickCount64()-debug_timer_ms," ms");
  }
//+------------------------------------------------------------------+
//| Check trading events (V1 CTradingEngine::TradeEventsControl)      |
//+------------------------------------------------------------------+
void TradeEventsControl(void)
  {
   //--- Initialize trading events' flags
    m_TradeEventsCollection.SetEventFlag(false);
   //--- Update the lists
    m_MarketCollection.RefreshMarket();
    m_HistoryCollection.RefreshHistory();
   //--- First launch actions
    if(!g_trade_started)
      {
       g_trade_started=true;
       return;
      }
   //--- Check the changes in the market status and account history
    bool is_market_trade_event=m_MarketCollection.IsTradeEvent();
    bool is_history_trade_event=m_HistoryCollection.IsTradeEvent();
   //--- If there is any event, send the lists, the flags and the number of new orders and deals to the event collection, and update it
    CArrayObj *list_changes=m_MarketCollection.GetListChanges();
    int change_total=(list_changes!=NULL ? list_changes.Total() : 0);
    if(is_history_trade_event || is_market_trade_event || change_total>0)
       m_TradeEventsCollection.Refresh(m_HistoryCollection.GetList(),m_MarketCollection.GetList(),list_changes,m_MarketCollection.GetListControl(),is_history_trade_event,
                                       is_market_trade_event,m_HistoryCollection.NewOrders(),m_MarketCollection.NewPendingOrders(),m_MarketCollection.NewPositions(),
                                       m_HistoryCollection.NewDeals(),m_MarketCollection.ChangedVolumeValue());
  }
//+------------------------------------------------------------------+
void OnTrade()
  {
   g_history_until_ms=::GetTickCount64()+EA_HISTORY_WATCH_MS;
   m_GUIPannel.OnTradeEvent();
  }
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   m_GUIPannel.OnTradeTransaction(trans);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(m_ChartObj!=NULL)
      m_ChartObj.OnChartEvent(id,lparam,dparam,sparam);   // the chart changed: its indicators are compared; the terminal made the objects of a trade: the panel goes back on top
   if(id>=CHARTEVENT_CUSTOM)
      Breadcrumb("OnChartEvent: custom "+(string)(id-CHARTEVENT_CUSTOM)+" "+sparam);   // MY DEBUG: the events of the controls and of the managers, not the mouse
   m_SyncManager.OnChartEvent(id,lparam,dparam,sparam);   // Python wrote more marks: RAM first, the collections read it next
   m_PythonBridge.OnChartEvent(id,lparam,dparam,sparam);   // a template or a pair came or went: Python calculates its history at once
   m_GUIPannel.OnChartEvent(id,lparam,dparam,sparam);
   m_GraphElementsCollection.OnChartEvent(id,lparam,dparam,sparam);   // the layer follows the chart, the markers hear the mouse
   m_IndicatorsCollection.OnChartEvent(id,lparam,dparam,sparam);   // a pair or a template added or deleted: its indicators are made or go
   m_BarTimeSeriesCollection.OnChartEvent(id,lparam,dparam,sparam);   // a parameter of a type changed: its rows are judged again
   m_SignalsCollection.OnChartEvent(id,lparam,dparam,sparam);   // a template was deleted: its signals go
   m_BarMarkerSync.OnChartEvent(id,lparam,dparam,sparam);   //--- A pair picked in the panel: the manager moves the chart itself
   m_SymbolTFManager.OnChartEvent(id,lparam,dparam,sparam,m_ChartObj);
   //--- A template added, shown, hidden or deleted: the chart follows
   m_IndicatorTemplateManager.OnChartEvent(id,lparam,dparam,sparam,m_ChartObj);
  }
