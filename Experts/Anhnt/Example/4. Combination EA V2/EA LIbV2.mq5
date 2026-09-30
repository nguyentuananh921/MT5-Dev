#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link "http://www.mql5.com"
#property version "2.00"
 //Include and declare properties 
  #include "Artyom Trishkin\TradingEngine.mqh"
   CTradingEngine m_tradingEngine;
  #include "Artyom Trishkin\TimeSeriesEngine.mqh"
   CTimeSeriesEngine m_timeSeriesEngine;
  #include "Services\IndicatorTemplateManager.mqh"
   CIndicatorTemplateManager  m_IndicatorTemplateManager;
  #include "Services\SymbolTFManager.mqh"
   CSymbolTFManager  m_SymbolTFManager;
  #include "Services\TradingSetupSettingManager.mqh"
   CTradingSetupSettingManager  m_TradingSetupManager;
  #include "Services\SignalBridgeWriter.mqh"
   CSignalBridgeWriter  m_signalBridgeWriter;
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\ChartObjCollection.mqh>
   CChartObjCollection  m_ChartObjCollection;
  #include "Anatoli Kazharski\GUIPannel.mqh"

   CGUIPannel m_GUIPannel;
   CGraphElementsCollection m_GraphElementsCollection;
   bool g_ea_init_done = false;
   bool g_suppress_del_rescan = false;
 int OnInit(void)
   {
      g_ea_init_done = false;
      g_suppress_del_rescan = false;
        m_tradingEngine.OnInitEvent();
        m_ChartObjCollection.CreateCollection();
        m_IndicatorTemplateManager.OnInitEvent(&m_ChartObjCollection);
        m_SymbolTFManager.OnInitEvent();
        m_TradingSetupManager.OnInitEvent();
        m_timeSeriesEngine.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
        m_timeSeriesEngine.OnInitEvent(::Symbol(), (ENUM_TIMEFRAMES)::Period(), &m_SymbolTFManager, &m_IndicatorTemplateManager);
        m_tradingEngine.SetIndicatorsCollection(m_timeSeriesEngine.GetIndicatorsCollection());
        m_tradingEngine.SetBarTimeSeriesCollection(m_timeSeriesEngine.GetTimeSeriesCollection());
        m_tradingEngine.SetTradingSetupManager(&m_TradingSetupManager);
        m_signalBridgeWriter.OnInitEvent(m_timeSeriesEngine.GetSignalsCollection(),
                                         m_timeSeriesEngine.GetIndicatorsCollection(),
                                         m_timeSeriesEngine.GetTimeSeriesCollection(),
                                         &m_IndicatorTemplateManager, &m_SymbolTFManager,
                                         m_timeSeriesEngine.GetPatternsControl(),
                                         m_timeSeriesEngine.GetSwingSetting());
        //AttachMarkerIndicatorToChart();   // moved below m_GUIPannel.OnInitEvent: needs the loaded marker settings
        m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
        m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);
        m_GUIPannel.SetTradingSetupManager(&m_TradingSetupManager);
        m_GUIPannel.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
        m_GUIPannel.SetTimeSeriesCollection(m_timeSeriesEngine.GetTimeSeriesCollection());
        m_GUIPannel.SetIndicatorsCollection(m_timeSeriesEngine.GetIndicatorsCollection());
        m_GUIPannel.SetSignalsCollection(m_timeSeriesEngine.GetSignalsCollection());
        m_GUIPannel.SetPatternsControl(m_timeSeriesEngine.GetPatternsControl());
        m_GUIPannel.SetSwingSetting(m_timeSeriesEngine.GetSwingSetting());
        m_GUIPannel.SetMarketCollection(m_tradingEngine.GetMarketCollection());
        m_GUIPannel.SetAccountsCollection(m_tradingEngine.GetAccountsCollection());
        m_GUIPannel.SetTradingControl(m_tradingEngine.GetTradingControl());
        m_GUIPannel.SetChartObjCollection(&m_ChartObjCollection);
        m_GUIPannel.SetGraphElementsCollection(&m_GraphElementsCollection);
        m_GUIPannel.SetTradingEngine(&m_tradingEngine);
        //--- Before the panel registers its windows: the bubbles stack below them
        m_GraphElementsCollection.CreateTradingLevelBubbles(::ChartID(), m_tradingEngine.GetMarketCollection(), m_tradingEngine.GetTradingControl());
        m_GUIPannel.OnInitEvent(_UninitReason);
        //--- Per-symbol watermark: full build only for a symbol never built, else no-op/increment; no chart series yet = wait for SYMTF_ADDED
        if(m_timeSeriesEngine.GetTimeSeriesCollection().IsAvailable(::Symbol(), (ENUM_TIMEFRAMES)::Period()))
           m_signalBridgeWriter.BuildAndWriteSignalBridge();
        AttachMarkerIndicatorToChart();
      EventSetMillisecondTimer(16);
      g_ea_init_done = true;
      return (INIT_SUCCEEDED);
   }

 void OnDeinit(const int reason)
  {
    m_GUIPannel.OnDeinitEvent(reason);
    if(reason != REASON_CHARTCHANGE)
       ::ChartIndicatorDelete(::ChartID(), 0, SIGNALMARKERS_NAME_TAG + "(" + ::Symbol() + ")");
  }

 void OnTick(void)
  {
    m_tradingEngine.OnTickEvent();
      SDataCalculate data_calc;
      MqlRates rates[1];
      if(::CopyRates(Symbol(), PERIOD_CURRENT, 0, 1, rates) == 1)
      {
          data_calc.rates         = rates[0];
          data_calc.rates_total   = ::Bars(Symbol(), PERIOD_CURRENT);
      }
    bool any_new_bar = m_timeSeriesEngine.OnTickEvent(Symbol(), data_calc);
    if(any_new_bar)
       m_signalBridgeWriter.BuildAndWriteSignalBridge();
    m_GUIPannel.OnTickEvent();
  }

 void OnTimer(void)
  {
    if(!g_ea_init_done) return;
    m_ChartObjCollection.Refresh();
    m_timeSeriesEngine.OnTimerEvent();
    //m_signalBridgeWriter.BuildAndWriteSignalBridge();
    m_GUIPannel.OnTimerEvent();
    m_GraphElementsCollection.OnTimer();
  }

 void OnTrade(void)
  {
    m_tradingEngine.OnTickEvent();
    m_GUIPannel.OnTradeEvent();
  }

 void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam)
  {
    if(MQLInfoInteger(MQL_TESTER)) return;
    m_timeSeriesEngine.OnChartEvent(id, lparam, dparam, sparam, &m_SymbolTFManager, &m_IndicatorTemplateManager);
    m_IndicatorTemplateManager.OnChartEvent(id, lparam, dparam, sparam, &m_ChartObjCollection);
    m_signalBridgeWriter.OnChartEvent(id, lparam, dparam, sparam);
    m_GraphElementsCollection.OnChartEvent(id, lparam, dparam, sparam);   // before the panel: chart-anchored elements move first
    m_GUIPannel.OnEvent(id, lparam, dparam, sparam);
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      ENUM_INDICATOR type = (ENUM_INDICATOR)lparam;
      int tmpl_total = m_IndicatorTemplateManager.Total();
      for(int t = 0; t < tmpl_total; t++)
       {
        CIndicatorSetting *entry = m_IndicatorTemplateManager.At(t);
        if(entry == NULL || entry.TypeEnum() != type || !entry.ShowOnChart()) continue;
        MqlParam params[];
        entry.GetRawParams(params);
        if(!m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params))
           m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
       }
      return;
     }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
      {
       CIndicatorSetting *entry = m_IndicatorTemplateManager.At((int)lparam);
       if(entry == NULL) return;
       ENUM_INDICATOR type = entry.TypeEnum();
       MqlParam params[];
       entry.GetRawParams(params);
       bool shown = m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params);
       if(entry.ShowOnChart() && !shown)
        {
         m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
        }
       else if(!entry.ShowOnChart() && shown)
        {
         g_suppress_del_rescan = true;
         m_ChartObjCollection.RemoveIndicatorFromChart(::ChartID(), type, params);
        }
       ChartRedraw();
       return;
      }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      {
       ENUM_INDICATOR type; MqlParam params[];
       m_IndicatorTemplateManager.GetLastRemoved(type, params);
       g_suppress_del_rescan = true;
       m_ChartObjCollection.RemoveIndicatorFromChart(::ChartID(), type, params);
       ChartRedraw();
       return;
      }
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED)
      {
       if(sparam == "") return;
       m_ChartObjCollection.SetActiveChartSymbolTF(::ChartID(), sparam, (ENUM_TIMEFRAMES)lparam);
       return;
      }
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)
      {
       string parts[];
       int split_total = StringSplit(sparam, '|', parts);
       if(split_total != 2) return;
       ENUM_TIMEFRAMES new_tf = (ENUM_TIMEFRAMES)(int)(lparam >> 32);
       m_ChartObjCollection.SetActiveChartSymbolTF(::ChartID(), parts[1], new_tf);
       return;
      }
     //--- iCustom inputs are fixed at creation: a new marker style means remove + re-attach
     if(id == CHARTEVENT_CUSTOM + GUIPANNEL_EVENT_MARKER_SETTING_CHANGED)
      {
       ::ChartIndicatorDelete(::ChartID(), 0, SIGNALMARKERS_NAME_TAG + "(" + ::Symbol() + ")");
       m_signalBridgeWriter.BuildAndWriteSignalBridge(true);   // the new instance only reads the file, rows pushed since the last write live nowhere else
       AttachMarkerIndicatorToChart();
       ::ChartRedraw();
       return;
      }
  }

 double OnTester(void)
  {
    return true;
  }
 void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
  }

 void AttachMarkerIndicatorToChart(void)
  {
    //--- Native names, not the polled CChartWnd list: right after a ChartIndicatorDelete that list is still stale
    int ind_total = ::ChartIndicatorsTotal(::ChartID(), 0);
    for(int i = 0; i < ind_total; i++)
       if(::StringFind(::ChartIndicatorName(::ChartID(), 0, i), SIGNALMARKERS_NAME_TAG) == 0)
          return;
    int   single_buy, single_sell, multi_buy, multi_sell, pattern_buy, pattern_sell, combo_buy, combo_sell;
    int   swing_high, swing_low;
    color buy_clr, sell_clr, nonrelated_clr;
    m_GUIPannel.GetMarkerSettings(single_buy, single_sell, multi_buy, multi_sell,
                                  pattern_buy, pattern_sell, combo_buy, combo_sell,
                                  swing_high, swing_low,
                                  buy_clr, sell_clr, nonrelated_clr);
    //--- Positional: must match SignalMarkers.mq5's input order
    int h = ::iCustom(NULL, 0, SIGNALMARKERS_PROGRAM_PATH,
                      single_buy, single_sell, multi_buy, multi_sell,
                      pattern_buy, pattern_sell, combo_buy, combo_sell,
                      swing_high, swing_low,
                      buy_clr, sell_clr, nonrelated_clr,
                      m_signalBridgeWriter.GetFolderName());
    if(h == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > iCustom(SignalMarkers) failed, error ", ::GetLastError());
      return;
     }
    if(!::ChartIndicatorAdd(::ChartID(), 0, h))
      ::Print(__FUNCTION__, " > ChartIndicatorAdd(SignalMarkers) failed, error ", ::GetLastError());
  }
