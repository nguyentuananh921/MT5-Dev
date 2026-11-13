//+------------------------------------------------------------------+
//|                                                EA V4 SQLLite.mq5 |
//+------------------------------------------------------------------+
#property strict
#include "Configuration\EA Configuration.mqh"   // what the EA decides (the database), before the library
#include "GUIPannel\GUIPannel.mqh"
#include <Combination Lib V5\Collections\AccountsCollection.mqh>
#include <Combination Lib V5\Collections\Settings\IndicatorTemplateManager.mqh>
#include <Combination Lib V5\Collections\Settings\BarInformationManager.mqh>
#include <Combination Lib V5\Collections\Settings\StrategyManager.mqh>
#include <Combination Lib V5\Collections\Settings\SyncManager.mqh>
#include <Combination Lib V5\Collections\IndicatorsCollection.mqh>
#include <Combination Lib V5\Collections\BarTimeSeriesCollection.mqh>
#include <Combination Lib V5\Collections\SignalsCollection.mqh>
#include <Combination Lib V5\Collections\StrategyCollection.mqh>
#include <Combination Lib V5\Collections\HistoryCollection.mqh>
#include <Combination Lib V5\Collections\MarketCollection.mqh>
#include <Combination Lib V5\Collections\TradeEventsCollection.mqh>
#include <Combination Lib V5\Trading\TradingControl.mqh>
#include <Combination Lib V5\Collections\GraphElementsCollection.mqh>
#include <Combination Lib V5\Services\DELib\DatabaseService.mqh> 
#include <Combination Lib V5\Collections\BarMarkerCollection.mqh>
#include "Services\PythonBridge.mqh"
//--- The EA is the parent: it owns its children and the models, and passes the events down to them
CAccountsCollection m_AccountsCollection; // the accounts: the table accounts, the account of the terminal has its row
CSymbolsCollection m_SymbolsCollection;   // the symbols of this account, read from the database
CSymbolTFManager   m_SymbolTFManager;     // the pairs Symbol+TF, read from the database
CIndicatorTemplateManager m_IndicatorTemplateManager;   // the indicator templates, read from the database
CBarInformationManager m_BarInformationManager;   // the information of a bar (the candle patterns), read from the database
CStrategyManager   m_StrategyManager;     // V5: the strategies (Setting_Strategy*): their indicators, conditions and parameters
CSyncManager       m_SyncManager;         // what was synced and up to where (Setting_Sync): Python and the library mark it, the markers look at it
CIndicatorsCollection m_IndicatorsCollection;   // the indicator of each template on each pair of Setting_SymbolTF: the one handle the signals read and the chart shows
CBarTimeSeriesCollection m_BarTimeSeriesCollection;   // the bars of every symbol and timeframe: the series are added when a class asks for them
CSignalsCollection m_SignalsCollection;   // the signals of the indicator templates on the bars: the table SignalsCollection
CStrategyCollection m_StrategyCollection; // V5: the entries and exits of the strategies on the pairs: the table StrategyCollection
CHistoryCollection m_HistoryCollection;   // the history of the terminal in RAM (GetList); the table Orders is its own: the lines it keeps are not written again
CMarketCollection  m_MarketCollection;    // the pending orders and the positions on the account: RAM only (GetList), never in the table Orders
CTradeEventsCollection m_TradeEventsCollection;   // the trading events of the account: each one is a line of the table TradeEvent
CTradingControl    m_TradingControl;      // the trading requests and the pending requests of them (RAM), on the lists of the collections (V1 CTradingEngine::m_trading_control)
CGraphElementsCollection m_GraphElementsCollection;   // the layer over the chart and the markers on it
CPythonBridge      m_PythonBridge;        // starts Python when it is not running: the tables are made before, Python only adds rows
CBarMarkerCollection m_BarMarkerCollection;   // the markers of what was found on the candles of the chart (BarTimeSeriesCollection, SignalsCollection)
CKronosForecastCollection m_KronosForecastCollection;   // V5: the bars Kronos foretells for the chart pair, pushed by server.py on the socket of m_PythonBridge
CChartObj         *m_ChartObj=NULL;       // the chart the EA runs on
CGUIPannel         m_GUIPannel;
CDatabaseService *m_DatabaseService = NULL;
ulong              g_series_refresh_ms=0;  // when the bars of the chart were read last (EA_SERIES_REFRESH_MS)
ulong              g_trade_refresh_ms=0;   // when the history, the orders and the events were looked at last (EA_TRADE_REFRESH_MS)
//+------------------------------------------------------------------+
int OnInit()
  {
   Breadcrumb("OnInit: DatabaseService_Create");
   // Build account key & open Account DB   
   string account_key =::AccountInfoString(ACCOUNT_COMPANY) + ::AccountInfoString(ACCOUNT_SERVER) + "_" + (string)::AccountInfoInteger(ACCOUNT_LOGIN);
   if(m_DatabaseService == NULL)   // a chart change keeps it (OnDeinit): its databases stay open (CDatabaseService::OnInitEvent, m_first_start)
      m_DatabaseService = new CDatabaseService("Database", "Accounts", account_key + ".sqlite3", account_key);
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
   if(m_ChartObj==NULL)   // a chart change keeps it (OnDeinit): CChartObj::OnInitEvent reads the view of the new TF
      m_ChartObj=new CChartObj(::ChartID());
   // makes Setting_IndicatorTemplate and the table timeframes (all the TFs of MT5, which Setting_SymbolTF refers to)
    Breadcrumb("OnInit: m_IndicatorTemplateManager.OnInitEvent");
    m_IndicatorTemplateManager.SetDatabaseService(m_DatabaseService);
    if(!m_IndicatorTemplateManager.OnInitEvent())
      return INIT_FAILED;   
    Breadcrumb("OnInit: m_ChartObj.OnInitEvent");
    m_ChartObj.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
    if(!m_ChartObj.OnInitEvent())
      return INIT_FAILED;    
   // m_AccountsCollection  
    Breadcrumb("OnInit: m_AccountsCollection.OnInitEvent");
    m_AccountsCollection.SetDatabaseService(m_DatabaseService);
    m_AccountsCollection.OnInitEvent();
   // m_SymbolTFManager: the center, before m_SymbolsCollection (which reads the symbols from its RAM)
    Breadcrumb("OnInit: m_SymbolTFManager.OnInitEvent");
    m_SymbolTFManager.SetDatabaseService(m_DatabaseService);
    m_SymbolTFManager.OnInitEvent();
   // m_SymbolsCollection
    Breadcrumb("OnInit: m_SymbolsCollection.OnInitEvent");
    m_SymbolsCollection.SetSymbolTFManager(&m_SymbolTFManager);   // the center: every work with the database goes through it
    m_SymbolsCollection.OnInitEvent();
   // m_BarInformationManager
    Breadcrumb("OnInit: m_BarInformationManager.OnInitEvent");
    m_BarInformationManager.SetDatabaseService(m_DatabaseService);
    m_BarInformationManager.OnInitEvent();   // makes Setting_BarInformation and Setting_BarSetup, fills what every type of information is
   // m_StrategyManager
    Breadcrumb("OnInit: m_StrategyManager.OnInitEvent");
    m_StrategyManager.SetDatabaseService(m_DatabaseService);
    m_StrategyManager.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);   // the templates of its indicator slots: made when a strategy is ON
    m_StrategyManager.SetBarInformationManager(&m_BarInformationManager);
    m_StrategyManager.OnInitEvent();   // makes Setting_Strategy*, writes the catalog (CSetting_Profitunity ...), reads them to RAM
   // m_SyncManager
    Breadcrumb("OnInit: m_SyncManager.OnInitEvent");
    m_SyncManager.SetDatabaseService(m_DatabaseService);
    m_SyncManager.OnInitEvent();   // makes Setting_Sync: the collections move their old table of progress there when they open the file of the account
   // m_HistoryCollection + m_MarketCollection
    Breadcrumb("OnInit: m_HistoryCollection.OnInitEvent");
    m_HistoryCollection.SetSymbolsCollection(&m_SymbolsCollection);   // the owner of symbol_account: the id of a symbol
    m_HistoryCollection.SetSymbolTFManager(&m_SymbolTFManager);       // the id of a symbol
    m_HistoryCollection.OnInitEvent();   // the table Orders is its own (the history only): made when not there, its lines read (which orders are written, the Bid / Ask of the deals)
    m_MarketCollection.SetSymbolsCollection(&m_SymbolsCollection);   // the pending orders and positions on the account: RAM only
    m_MarketCollection.SetSymbolTFManager(&m_SymbolTFManager);       // the id of a symbol
    Breadcrumb("OnInit: m_TradeEventsCollection.OnInitEvent");
   // m_TradeEventsCollection
    m_TradeEventsCollection.SetSymbolsCollection(&m_SymbolsCollection);
    m_TradeEventsCollection.SetSymbolTFManager(&m_SymbolTFManager);       // the id of a symbol
    m_TradeEventsCollection.OnInitEvent();   // opens the file of the account and makes the table TradeEvent (the events themselves are in RAM, V3)
    Breadcrumb("OnInit: m_MarketCollection.RefreshMarket");
    m_MarketCollection.RefreshMarket();     // the first call loads the list: no event
    Breadcrumb("OnInit: m_HistoryCollection.RefreshHistory");
    m_HistoryCollection.RefreshHistory();   // the first call loads the past: no event
   // m_TradingControl (DoEasy CEngine::CollectionOnInit)
    Breadcrumb("OnInit: m_TradingControl.OnInit");
    m_TradingControl.OnInit(m_AccountsCollection.GetCurrentAccount(),&m_SymbolsCollection,&m_MarketCollection,&m_HistoryCollection,&m_TradeEventsCollection);
   // m_IndicatorsCollection (its series copy the buffers of MT5 on RAM, nothing in the database)
    Breadcrumb("OnInit: m_IndicatorsCollection.OnInitEvent");
    m_IndicatorsCollection.SetSymbolTFManager(&m_SymbolTFManager);   // the pairs
    m_IndicatorsCollection.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);   // the templates
    if(!m_IndicatorsCollection.OnInitEvent())
      {
       ::Print(__FUNCTION__," > failed to OnInitEvent IndicatorsCollection");
       return INIT_FAILED;
      }
   // m_BarTimeSeriesCollection
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.SetSyncManager");
    m_BarTimeSeriesCollection.SetSyncManager(&m_SyncManager);
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.SetSymbolTFManager");
    m_BarTimeSeriesCollection.SetSymbolTFManager(&m_SymbolTFManager);   // the pairs the library keeps up to date after OnInit
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.SetBarInformationManager");
    m_BarTimeSeriesCollection.SetBarInformationManager(&m_BarInformationManager);   // the parameters of the types it finds
    Breadcrumb("OnInit: m_BarTimeSeriesCollection.OnInitEvent");
    if(!m_BarTimeSeriesCollection.OnInitEvent())   // a series for every pair of Setting_SymbolTF
      {
        ::Print(__FUNCTION__," > failed to OnInitEvent BarTimeSeriesCollection");
        return INIT_FAILED;
       }
   // m_GraphElementsCollection
    Breadcrumb("OnInit: m_GraphElementsCollection.OnInitEvent");
    m_GraphElementsCollection.OnInitEvent();   // the layer is made before the panel windows, so they stack above it
   // m_SignalsCollection
    Breadcrumb("OnInit: m_SignalsCollection.SetBarTimeSeriesCollection");
    m_SignalsCollection.SetBarTimeSeriesCollection(&m_BarTimeSeriesCollection);   // the bars the signals are found on
    Breadcrumb("OnInit: m_SignalsCollection.SetSyncManager");
    m_SignalsCollection.SetSyncManager(&m_SyncManager);
    Breadcrumb("OnInit: m_SignalsCollection.SetSymbolTFManager");
    m_SignalsCollection.SetSymbolTFManager(&m_SymbolTFManager);   // the pairs the library keeps up to date after OnInit
    Breadcrumb("OnInit: m_SignalsCollection.SetIndicatorTemplateManager");
    m_SignalsCollection.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);   // the templates whose signals it finds
    m_SignalsCollection.SetIndicatorsCollection(&m_IndicatorsCollection);   // the indicator of a template on a pair: its values in RAM (the new bars are judged on them)
    Breadcrumb("OnInit: m_SignalsCollection.OnInitEvent");
    m_SignalsCollection.OnInitEvent();   // a series for every template on every pair
   // m_StrategyCollection
    Breadcrumb("OnInit: m_StrategyCollection.OnInitEvent");
    m_StrategyCollection.SetBarTimeSeriesCollection(&m_BarTimeSeriesCollection);
    m_StrategyCollection.SetSyncManager(&m_SyncManager);
    m_StrategyCollection.SetSymbolTFManager(&m_SymbolTFManager);
    m_StrategyCollection.SetStrategyManager(&m_StrategyManager);   // the strategies, the table StrategyCollection
    m_StrategyCollection.SetIndicatorsCollection(&m_IndicatorsCollection);   // the values of the slots on RAM: the new bars are judged on them
    m_StrategyCollection.OnInitEvent();   // a series for every strategy on every pair
   // m_PythonBridge
    Breadcrumb("OnInit: m_PythonBridge.OnInitEvent");
    m_PythonBridge.SetDatabaseService(m_DatabaseService);
    m_PythonBridge.SetKronosForecastCollection(&m_KronosForecastCollection);   // the lines of the forecast of the chart pair go to it
    m_PythonBridge.SetSymbolTFManager(&m_SymbolTFManager);   // the pairs told to server.py (watch), the names of the table timeframes
    m_PythonBridge.SetBarTimeSeriesCollection(&m_BarTimeSeriesCollection);   // the rows Python found on the bars go to it, it tells them
    m_PythonBridge.SetSignalsCollection(&m_SignalsCollection);   // the rows of the signals of the templates go to it, it tells them
    m_PythonBridge.SetStrategyCollection(&m_StrategyCollection);   // the entries and exits of the strategies go to it, it tells them
    m_PythonBridge.OnInitEvent();   // after every table is made: Python starts when it finds none running
   // m_BarMarkerCollection
    Breadcrumb("OnInit: m_BarMarkerCollection.OnInitEvent");
    m_BarMarkerCollection.SetChartObj(m_ChartObj);
    m_BarMarkerCollection.SetGraphElementsCollection(&m_GraphElementsCollection);
    m_BarMarkerCollection.SetBarTimeSeriesCollection(&m_BarTimeSeriesCollection);
    m_BarMarkerCollection.SetSignalsCollection(&m_SignalsCollection);
    m_BarMarkerCollection.SetSymbolTFManager(&m_SymbolTFManager);
    m_BarMarkerCollection.SetBarInformationManager(&m_BarInformationManager);   // given to the markers: they decide what they show
    m_BarMarkerCollection.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
    m_BarMarkerCollection.SetStrategyCollection(&m_StrategyCollection);   // the entries of the strategies
    m_BarMarkerCollection.SetStrategyManager(&m_StrategyManager);         // show_on_chart of each strategy
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
    Breadcrumb("OnInit: m_GUIPannel.SetStrategyManager");
    m_GUIPannel.SetStrategyManager(&m_StrategyManager);   // the strategies of the Strategy tab
    Breadcrumb("OnInit: m_GUIPannel.SetBarMarkerCollection");
    m_GUIPannel.SetBarMarkerCollection(&m_BarMarkerCollection);   // the popup of a candle reads what was found on it (RAM)
    Breadcrumb("OnInit: m_GUIPannel.SetGraphElementsCollection");
    m_GUIPannel.SetGraphElementsCollection(&m_GraphElementsCollection);   // and lights the box of the candle on its marker
    Breadcrumb("OnInit: m_GUIPannel.OnInit");
    if(!m_GUIPannel.OnInit(_UninitReason))
        return(INIT_FAILED);
   ::EventSetMillisecondTimer(EA_TIMER_MS);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   //--- Every reason: the markers and the box on the candle go (a chart change: the new TF has other candles, its first CHARTEVENT_CHART_CHANGE draws them).
   //--- Each child looks at the reason itself
   m_BarMarkerCollection.DeleteMarkers();
   m_KronosForecastCollection.DeleteBars();   // a chart change: the forecast of the new pair comes when it is watched (OnInit)
   m_BarTimeSeriesCollection.OnDeinitEvent(reason);   // a chart change: the rows read for the view of the old TF go (read again when it comes back)
   m_SignalsCollection.OnDeinitEvent(reason);
   m_StrategyCollection.OnDeinitEvent(reason);
   m_PythonBridge.OnDeinitEvent(reason);   // the EA is closed: the row of Python is cleared, Python stops with its workers
   m_GUIPannel.OnDeinit(reason);
   //--- A chart change (or new inputs): the EA starts again at once with the same account. Every object stays, RAM keeps what was judged
   if(reason==REASON_CHARTCHANGE || reason==REASON_PARAMETERS)
      return;
   //--- V5 Calculation Rule: only Python saves to DB, the library judges on RAM only: nothing waits to be written
   if(m_ChartObj!=NULL)
     {
      delete m_ChartObj;
      m_ChartObj=NULL;
     }
   m_AccountsCollection.UpdateDataToDB();   // while m_DatabaseService is still alive
   if(m_DatabaseService != NULL)
    {
     delete m_DatabaseService;
     m_DatabaseService = NULL;
    }
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   if(m_ChartObj!=NULL && !m_ChartObj.IsAvailable())   // the chart is changing
      return;
   m_AccountsCollection.RefreshAccount();   // the account follows the terminal (RAM); its events (balance, credit, permissions, terms) go to the chart
   //--- The series follow the ticks (DoEasy CEngine::OnTick): the chart's symbol; in the tester every symbol (no OnTimer there, as the DoEasy EAs)
   //--- The signals follow the series they are judged on (the newest closed bar is there now). V5: judged on RAM only, Python saves; its rows of the same bars are refused
   if(::MQLInfoInteger(MQL_TESTER))
     {
      m_BarTimeSeriesCollection.RefreshSeries();
      m_SignalsCollection.RefreshSeries();
      m_StrategyCollection.RefreshSeries();
     }
   else
     {
      m_BarTimeSeriesCollection.RefreshSeries(::Symbol());
      m_SignalsCollection.RefreshSeries(::Symbol());
      m_StrategyCollection.RefreshSeries(::Symbol());   // every strategy runs in realtime: its rule says what a tick does (Profitunity: a new closed bar of its tf)
     }
   m_GUIPannel.OnTickEvent();
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(m_ChartObj!=NULL && !m_ChartObj.IsAvailable())   // the chart is changing
      return;
   Breadcrumb("OnTimer: m_SymbolsCollection.OnTimerEvent");
   m_SymbolsCollection.OnTimerEvent();   // the Market Watch, once a second (V3): a new symbol gets its line in symbol_account, its event goes to the chart
   Breadcrumb("OnTimer: m_GUIPannel.OnTimerEvent");
   m_GUIPannel.OnTimerEvent();   // the controls take their steps from it (the spin buttons)
   Breadcrumb("OnTimer: m_GraphElementsCollection.OnTimerEvent");
   m_GraphElementsCollection.OnTimerEvent();   // the markers: the layer is painted again when one asked
   //--- The history of the terminal goes to the table Orders: the past beat after beat from OnInit on, later only for a while after a trade
   //--- The history, the pending orders and positions and the events are written at the pace of the beat, like the other tables
   if(::GetTickCount64()-g_trade_refresh_ms>=EA_TRADE_REFRESH_MS)
    {
      g_trade_refresh_ms=::GetTickCount64();
      Breadcrumb("OnTimer: m_TradingControl.OnTimer");
      m_TradingControl.OnTimer();   // the list of pending requests (DoEasy CEngine::OnTimer)
    }
   //--- The bars of every series: a new bar sends SERIES_EVENT_NEW_BAR; the library judges the new bars of the pairs of Setting_SymbolTF on RAM (Python saves them)
   if(::GetTickCount64()-g_series_refresh_ms>=EA_SERIES_REFRESH_MS)
     {
      g_series_refresh_ms=::GetTickCount64();
      // Bar Time Series Collection: every series follows MT5 and judges its new bars on RAM; the events go to the chart (SERIES_EVENTS_NEW_BAR, SERIES_EVENTS_PATTERN)
       Breadcrumb("OnTimer: m_BarTimeSeriesCollection.RefreshSeriesAllExceptCurrent");
       if(!::MQLInfoInteger(MQL_TESTER))
          m_BarTimeSeriesCollection.RefreshSeriesAllExceptCurrent();   // the other symbols have no tick on this chart (DoEasy CEngine::OnTimer)
       //Breadcrumb("OnTimer: m_BarTimeSeriesCollection.OnTimerEvent");
       //m_BarTimeSeriesCollection.OnTimerEvent();   // a step of the delete of the rows of a type whose parameter changed (the table, every pair)
      // Signal Collection: the same rhythm as the series (the chart's symbol is in OnTick)
       Breadcrumb("OnTimer: m_SignalsCollection.RefreshSeriesAllExceptCurrent");
       if(!::MQLInfoInteger(MQL_TESTER))
          m_SignalsCollection.RefreshSeriesAllExceptCurrent();
      // Strategy Collection: the other symbols have no tick on this chart
       Breadcrumb("OnTimer: m_StrategyCollection.RefreshSeriesAllExceptCurrent");
       if(!::MQLInfoInteger(MQL_TESTER))
          m_StrategyCollection.RefreshSeriesAllExceptCurrent();
       Breadcrumb("OnTimer: m_PythonBridge.OnTimerEvent");
      m_PythonBridge.OnTimerEvent();    // Python that stopped is started again
      Breadcrumb("OnTimer: done");
     }
  }
//+------------------------------------------------------------------+
void OnTrade()
  {
   if(m_ChartObj!=NULL && !m_ChartObj.IsAvailable())   // the chart is changing
      return;
   m_MarketCollection.RefreshMarket();
   m_HistoryCollection.RefreshHistory();
   CArrayObj *list_changes=m_MarketCollection.GetListChanges();
   if(m_HistoryCollection.IsEvent() || m_MarketCollection.IsEvent() || (list_changes!=NULL && list_changes.Total()>0))
      m_TradeEventsCollection.Refresh(m_HistoryCollection.GetList(),m_MarketCollection.GetList(),list_changes,m_MarketCollection.GetListControl(),m_HistoryCollection.IsEvent(),
                                      m_MarketCollection.IsEvent(),m_HistoryCollection.NewOrders(),m_MarketCollection.NewPendingOrders(),m_MarketCollection.NewPositions(),
                                      m_HistoryCollection.NewDeals(),m_MarketCollection.ChangedVolumeValue());
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
   if(m_ChartObj!=NULL && !m_ChartObj.IsAvailable())   // the chart is changing
      return;
   if(m_ChartObj!=NULL)
      m_ChartObj.OnChartEvent(id,lparam,dparam,sparam);   // the chart changed: its indicators are compared; the terminal made the objects of a trade: the panel goes back on top
   if(id>=CHARTEVENT_CUSTOM)
      Breadcrumb("OnChartEvent: custom "+(string)(id-CHARTEVENT_CUSTOM)+" "+sparam);   // MY DEBUG: the events of the controls and of the managers, not the mouse
   m_SyncManager.OnChartEvent(id,lparam,dparam,sparam);   // Python wrote more marks: RAM first, the collections read it next; a parameter changed: its marks go
   m_PythonBridge.OnChartEvent(id,lparam,dparam,sparam);   // a template or a pair came or went: Python calculates its history at once
   m_GUIPannel.OnChartEvent(id,lparam,dparam,sparam);
   m_TradingControl.OnChartEvent(id,lparam,dparam,sparam);   // the panel asked to close every position (emergency)
   m_GraphElementsCollection.OnChartEvent(id,lparam,dparam,sparam);   // the layer follows the chart, the markers hear the mouse
   //--- V2 CSignalsCollection: DeleteSignal BEFORE the indicator: the judge of a CSignal holds its CIndicatorDE (1-1), so a pair or a template deleted: the signals go
   //--- first; added: the indicators are made first, then their signals
   const bool deleted=(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE);
   if(deleted)
      m_SignalsCollection.OnChartEvent(id,lparam,dparam,sparam);
   m_IndicatorsCollection.OnChartEvent(id,lparam,dparam,sparam);   // a pair or a template added or deleted: its indicators are made or go
   m_BarTimeSeriesCollection.OnChartEvent(id,lparam,dparam,sparam);   // a parameter of a type changed: its rows on RAM go
   if(!deleted)
      m_SignalsCollection.OnChartEvent(id,lparam,dparam,sparam);   // a template or a pair added: their signals are made on the indicators
   m_StrategyCollection.OnChartEvent(id,lparam,dparam,sparam);  // before the markers: the rows are on RAM when they are drawn
   m_BarMarkerCollection.OnChartEvent(id,lparam,dparam,sparam);   //--- A pair picked in the panel: the manager moves the chart itself
   m_KronosForecastCollection.OnChartEvent(id,lparam,dparam,sparam);   // a new bar of the chart pair: the bars foretold it reached go
   m_SymbolTFManager.OnChartEvent(id,lparam,dparam,sparam,m_ChartObj);
  }
