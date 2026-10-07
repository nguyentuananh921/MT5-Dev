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
  #include "Services\MarkerSetting.mqh"
   CMarkerSetting  m_MarkerSetting;
  #include "Services\TradingSetupSettingManager.mqh"
   CTradingSetupSettingManager  m_TradingSetupManager;
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\ChartObjCollection.mqh>
   CChartObjCollection  m_ChartObjCollection;
  #include "Anatoli Kazharski\GUIPannel.mqh"
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Graph\Composite\TradingLevelBubble.mqh>
  #include "Services\CandleMarkerSync.mqh"
   CCandleMarkerSync m_CandleMarkerSync;

   CGUIPannel m_GUIPannel;
   CGraphElementsCollection m_GraphElementsCollection;
   bool g_ea_init_done = false;
   bool g_suppress_del_rescan = false;
   bool g_orig_chart_shift = true;   // chart shift before the bubbles took over
 int OnInit(void)
   {
      g_ea_init_done = false;
      g_suppress_del_rescan = false;
        m_tradingEngine.OnInitEvent();
        m_ChartObjCollection.CreateCollection();
        m_IndicatorTemplateManager.OnInitEvent(&m_ChartObjCollection);
        m_SymbolTFManager.OnInitEvent();
        m_TradingSetupManager.OnInitEvent();
        m_MarkerSetting.OnInitEvent();
        m_timeSeriesEngine.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
        m_timeSeriesEngine.OnInitEvent(::Symbol(), (ENUM_TIMEFRAMES)::Period(), &m_SymbolTFManager, &m_IndicatorTemplateManager);
        m_tradingEngine.SetIndicatorsCollection(m_timeSeriesEngine.GetIndicatorsCollection());
        m_tradingEngine.SetBarTimeSeriesCollection(m_timeSeriesEngine.GetTimeSeriesCollection());
        m_tradingEngine.SetTradingSetupManager(&m_TradingSetupManager);
        m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
        m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);
        m_GUIPannel.SetTradingSetupManager(&m_TradingSetupManager);
        m_GUIPannel.SetMarkerSetting(&m_MarkerSetting);
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
        //--- The bubbles replace the native SL/TP lines; the right shift leaves room for them
        ::ChartSetInteger(::ChartID(), CHART_SHOW_TRADE_LEVELS, false);
        g_orig_chart_shift = (bool)::ChartGetInteger(::ChartID(), CHART_SHIFT);
        ::ChartSetInteger(::ChartID(), CHART_SHIFT, true);
        for(int b = 0; b < BUBBLE_TOTAL; b++)
         {
          CTradingLevelBubble *bubble = new CTradingLevelBubble();
          if(bubble != NULL && bubble.Create(::ChartID(), 0, (ENUM_BUBBLE_TYPE)b) && m_GraphElementsCollection.AddChild(bubble))
            {
             bubble.SetSources(m_tradingEngine.GetMarketCollection());
             bubble.Refresh();
            }
          else
             delete bubble;
         }
        //--- The marker badges are created before the panel windows, so the windows stack above them
        m_CandleMarkerSync.OnInitEvent(m_timeSeriesEngine.GetSignalsCollection(), m_timeSeriesEngine.GetIndicatorsCollection(),
                                       m_timeSeriesEngine.GetTimeSeriesCollection(), &m_IndicatorTemplateManager, &m_SymbolTFManager,
                                       m_timeSeriesEngine.GetPatternsControl(), m_timeSeriesEngine.GetSwingSetting(),
                                       &m_MarkerSetting, &m_GraphElementsCollection);
        m_CandleMarkerSync.Sync(true);   // globals survive a chart change: old markers and watermarks are those of the previous symbol/TF
        m_GraphElementsCollection.OnInit();
        m_GUIPannel.OnInit(_UninitReason);
      EventSetMillisecondTimer(16);
      g_ea_init_done = true;
      return (INIT_SUCCEEDED);
   }

 void OnDeinit(const int reason)
  {
    m_GUIPannel.OnDeinit(reason);
    //--- Give the chart back its native SL/TP lines
    ::ChartSetInteger(::ChartID(), CHART_SHOW_TRADE_LEVELS, true);
    ::ChartSetInteger(::ChartID(), CHART_SHIFT, g_orig_chart_shift);
    ::ChartSetInteger(::ChartID(), CHART_AUTOSCROLL, true);
  }

 void OnTick(void)
  {
    //Print Debug
        PERF_BEGIN
        ulong perf_start=perf_t0;
    m_tradingEngine.OnTickEvent();
    //Print Debug
        PERF_LAP("OnTick.tradingEngine")
      SDataCalculate data_calc;
      MqlRates rates[1];
      if(::CopyRates(Symbol(), PERIOD_CURRENT, 0, 1, rates) == 1)
      {
          data_calc.rates         = rates[0];
          data_calc.rates_total   = ::Bars(Symbol(), PERIOD_CURRENT);
      }
    //Print Debug
        PERF_LAP("OnTick.copyRates")
    bool any_new_bar = m_timeSeriesEngine.OnTickEvent(Symbol(), data_calc);
    //Print Debug
        PERF_LAP("OnTick.timeSeriesEngine")
    if(any_new_bar)
       m_CandleMarkerSync.Sync();
    //Print Debug
        PERF_LAP("OnTick.markerSync")
    m_GUIPannel.OnTick(any_new_bar);
    //Print Debug
        PERF_LAP("OnTick.GUIPannel")
    //Print Debug
        g_perf.Add("OnTick.total",::GetMicrosecondCount()-perf_start);
  }

 void OnTimer(void)
  {
    if(!g_ea_init_done) return;
    //Print Debug
        PERF_BEGIN
        ulong perf_start=perf_t0;
    static ulong chart_obj_refresh_ms=0;   // chart open/close and indicator add/remove are rare: no need to poll every timer tick
    if(::GetTickCount64()-chart_obj_refresh_ms>=250)
      {
       chart_obj_refresh_ms=::GetTickCount64();
       m_ChartObjCollection.Refresh();
      }
    //Print Debug
        PERF_LAP("OnTimer.chartObjRefresh")
    m_timeSeriesEngine.OnTimerEvent();    
    //Print Debug
        PERF_LAP("OnTimer.timeSeriesEngine")
    m_GUIPannel.OnTimerEvent();
    //Print Debug
        PERF_LAP("OnTimer.GUIPannel")
    m_GraphElementsCollection.OnTimerEvent();
    //Print Debug
        PERF_LAP("OnTimer.graphElements")
    //Print Debug
        g_perf.Add("OnTimer.total",::GetMicrosecondCount()-perf_start);
        g_perf.Dump(::MQLInfoString(MQL_PROGRAM_NAME));
  }

 void OnTrade(void)
  {
    m_tradingEngine.OnTradeEvent();
    m_GUIPannel.OnTrade();
  }

 void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam)
  {
    if(MQLInfoInteger(MQL_TESTER)) return;
    //Print Debug
        string perf_ev = "OnChartEvent." + (id == CHARTEVENT_MOUSE_MOVE ? "mouse" : (id == CHARTEVENT_CHART_CHANGE ? "chartChange" : "other")) + ".";
        PERF_BEGIN
        ulong perf_start=perf_t0;
    m_timeSeriesEngine.OnChartEvent(id, lparam, dparam, sparam, &m_SymbolTFManager, &m_IndicatorTemplateManager);
    //Print Debug
        PERF_LAP(perf_ev+"timeSeriesEngine")
    m_IndicatorTemplateManager.OnChartEvent(id, lparam, dparam, sparam, &m_ChartObjCollection);
    //Print Debug
        PERF_LAP(perf_ev+"indicatorTemplateManager")
    m_CandleMarkerSync.OnChartEvent(id, lparam, dparam, sparam);   // a Buy/Sell gate or the Swing setting changed: markers restart
    //Print Debug
        PERF_LAP(perf_ev+"markerSync")
    m_GraphElementsCollection.OnChartEvent(id, lparam, dparam, sparam);   // before the panel: chart-anchored elements move first
    //Print Debug
        PERF_LAP(perf_ev+"graphElements")
    if(id == CHARTEVENT_CHART_CHANGE)
       CCandleMarker::Arrange(&m_GraphElementsCollection);                // zoom/scroll changes which badges overlap
    //Print Debug
        PERF_LAP(perf_ev+"arrange")
    if(CCandleMarker::ConsumeRaiseRequest())
       m_GraphElementsCollection.BringToTopAllCanvElm();                  // a badge was shown again: the panel windows go back on top now
    //Print Debug
        PERF_LAP(perf_ev+"raise")
    m_tradingEngine.OnChartEvent(id, lparam, dparam, sparam);
    //Print Debug
        PERF_LAP(perf_ev+"tradingEngine")
    OpenCandleInfo(id, lparam, dparam, sparam);
    //Print Debug
        PERF_LAP(perf_ev+"openCandleInfo")
    m_GUIPannel.OnChartEvent(id, lparam, dparam, sparam);
    //Print Debug
        PERF_LAP(perf_ev+"GUIPannel")
    //Print Debug
        g_perf.Add(perf_ev+"total",::GetMicrosecondCount()-perf_start);
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
     //--- The marker colors changed: every CCandleMarker is redrawn
     if(id == CHARTEVENT_CUSTOM + GUIPANNEL_EVENT_MARKER_SETTING_CHANGED)
      {
       m_CandleMarkerSync.Sync(true);   // the Buy/Sell colors may have changed
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

 //--- Candle information popup: opens on Shift + hover on a candle or on the cursor entering a CCandleMarker badge; the panel closes it
 void OpenCandleInfo(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   static datetime s_last_bar = 0;   // candle already handled while Shift stays down
   datetime bar_time = 0;
   int x = 0, y = 0;
   bool by_marker = (id == CHARTEVENT_CUSTOM + ON_CANDLE_MARKER_ENTER);
   if(by_marker)
    {
     bar_time = (datetime)lparam;
     y = (int)dparam;
    }
   else if(id == CHARTEVENT_MOUSE_MOVE)
    {
     x = (int)lparam;
     y = (int)dparam;
     if(m_GUIPannel.IsWindow_CandleInfoVisible())
        return;
     bool shift = ((((int)::StringToInteger(sparam)) & MOUSE_BUTT_KEY_STATE_SHIFT) != 0);
     if(!shift || m_GUIPannel.MouseOverAnyGUIWindow(x, y))
      {
       s_last_bar = 0;
       return;
      }
     CChartObj *chart_obj = m_ChartObjCollection.GetChart(::ChartID());
     if(chart_obj == NULL)
        return;
     bar_time = chart_obj.GetBarTimeFromXY(x, y);
     if(bar_time == 0 || bar_time == s_last_bar)
        return;
     s_last_bar = bar_time;
    }
   else
      return;
   string          row_label[], row_tf[];
   ENUM_SIGNAL_DIR row_dir[];
   datetime        row_time[];
   int             row_source[];
   int count = m_timeSeriesEngine.GetCandleInfo(bar_time, row_label, row_tf, row_dir, row_time, row_source);
   if(m_GUIPannel.RefreshWindow_CandleInfo(count, row_label, row_tf, row_dir, row_time, row_source))
      m_GUIPannel.ShowWindow_CandleInfo(x, y, bar_time, by_marker);
  }
