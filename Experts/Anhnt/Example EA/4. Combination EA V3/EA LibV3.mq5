#property copyright "Copyright 2026, Anhnt"
#property link      "http://www.mql5.com"
#property version   "3.00"
 #include "Configuration\EA Configuration.mqh"

 int OnInit(void)
  {
   g_ea_init_done = false;
   m_SymbolsCollection.OnInitEvent();
   m_SymbolTFManager.OnInitEvent();
   m_SmartMoneySetting.OnInitEvent();
   if(m_ChartObj != NULL)
      delete m_ChartObj;
   m_ChartObj = new CChartObj(::ChartID());
   m_IndicatorTemplateManager.OnInitEvent(m_ChartObj);
   m_PatternManager.OnInitEvent();
   m_MarkerSetting.OnInitEvent();
   g_GraphElementsCollection.OnInit();
   m_SmartMoneySync.OnInitEvent(&g_GraphElementsCollection, &m_SmartMoneySetting, &m_MarkerSetting, &m_IndicatorTemplateManager, &m_PatternManager, m_PythonBridge.Swings(), m_PythonBridge.Structures(), m_PythonBridge.Signals(), m_PythonBridge.Patterns());
   m_PythonBridge.OnInitEvent(&m_SymbolTFManager, &m_SmartMoneySetting, &m_IndicatorTemplateManager, &m_PatternManager, &m_SmartMoneySync, &m_IndicatorsCollection);
   m_PythonBridge.Start();
   m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);
   m_GUIPannel.SetSmartMoneySetting(&m_SmartMoneySetting);
   m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
   m_GUIPannel.SetPatternManager(&m_PatternManager);
   m_GUIPannel.SetIndicatorsCollection(&m_IndicatorsCollection);
   m_GUIPannel.SetSymbolsCollection(&m_SymbolsCollection);
   m_GUIPannel.SetMarkerSetting(&m_MarkerSetting);
   m_GUIPannel.SetGraphElementsCollection(&g_GraphElementsCollection);
   if(!m_GUIPannel.OnInit(_UninitReason))
      return(INIT_FAILED);
   EventSetMillisecondTimer(16);
   g_ea_init_done = true;
   return(INIT_SUCCEEDED);
  }

 void OnDeinit(const int reason)
  {
   ulong d0 = ::GetMicrosecondCount();   //Print Debug
   EventKillTimer();
   m_GUIPannel.OnDeinit(reason);
   if(m_ChartObj != NULL)
     {
      delete m_ChartObj;
      m_ChartObj = NULL;
     }
   m_PythonBridge.Stop(reason == REASON_REMOVE);   // chart change/recompile: Python keeps running
   ulong d1 = ::GetMicrosecondCount();   //Print Debug
   int children = g_GraphElementsCollection.ChildrenTotal();   //Print Debug
   m_SmartMoneySync.DeleteMarkers();
   CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME), "EA", "OnDeinit", "MY DEBUG reason " + (string)reason + ", GUI+Python " + (string)((d1 - d0) / 1000) + " ms, DeleteMarkers " + (string)((::GetMicrosecondCount() - d1) / 1000) + " ms, children before " + (string)children);   //Print Debug
  }

 void OnTick(void)
  {
   m_PythonBridge.RequestPreTradeSymbolMonitor();   // the PreTradeSymbolMonitor table follows the forming bar
  }

 ulong g_dbg_mouse_n = 0, g_dbg_mouse_coll = 0, g_dbg_mouse_gui = 0, g_dbg_mouse_max = 0;   //Print Debug
 ulong g_dbg_timer_n = 0, g_dbg_timer_poll = 0, g_dbg_timer_gui = 0, g_dbg_timer_coll = 0, g_dbg_timer_max = 0, g_dbg_last_ms = 0;   //Print Debug
 void DebugFlush(void)   //Print Debug
  {
   if(::GetTickCount64() - g_dbg_last_ms < 2000) return;   //Print Debug
   g_dbg_last_ms = ::GetTickCount64();   //Print Debug
   if(g_dbg_mouse_n + g_dbg_timer_n == 0) return;   //Print Debug
   CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME), "EA", "DebugFlush", "MY DEBUG mouse n=" + (string)g_dbg_mouse_n + " collection us=" + (string)g_dbg_mouse_coll + " gui us=" + (string)g_dbg_mouse_gui + " max us=" + (string)g_dbg_mouse_max + " | timer n=" + (string)g_dbg_timer_n + " poll us=" + (string)g_dbg_timer_poll + " gui us=" + (string)g_dbg_timer_gui + " collection us=" + (string)g_dbg_timer_coll + " max us=" + (string)g_dbg_timer_max + " | invalidate=" + (string)g_dbg_invalidate_n + " children us=" + (string)g_dbg_c_children + " check us=" + (string)g_dbg_c_check + " redraw us=" + (string)g_dbg_c_redraw + " redraw n=" + (string)g_dbg_c_redraw_n + " bring n=" + (string)g_dbg_c_bring_n + " | readable us=" + (string)g_dbg_p_readable + " connected us=" + (string)g_dbg_p_connected + " n=" + (string)g_dbg_p_connected_n);   //Print Debug
   g_dbg_invalidate_n = g_dbg_c_children = g_dbg_c_check = g_dbg_c_redraw = g_dbg_c_redraw_n = g_dbg_p_readable = g_dbg_p_connected = g_dbg_p_connected_n = g_dbg_c_bring_n = 0;   //Print Debug
   g_dbg_mouse_n = g_dbg_mouse_coll = g_dbg_mouse_gui = g_dbg_mouse_max = 0;   //Print Debug
   g_dbg_timer_n = g_dbg_timer_poll = g_dbg_timer_gui = g_dbg_timer_coll = g_dbg_timer_max = 0;   //Print Debug
  }
 void OnTimer(void)
  {
   if(!g_ea_init_done) return;
   ulong d0 = ::GetMicrosecondCount();   //Print Debug
   m_SymbolsCollection.OnTimerEvent();
   static ulong chart_obj_refresh_ms = 0;   // indicators come and go rarely: no need to poll every 16 ms
   if(m_ChartObj != NULL && ::GetTickCount64() - chart_obj_refresh_ms >= 250)
     {
      chart_obj_refresh_ms = ::GetTickCount64();
      m_ChartObj.Refresh();
     }
   m_PythonBridge.Poll();
   ulong d1 = ::GetMicrosecondCount();   //Print Debug
   m_GUIPannel.OnTimerEvent();
   ulong d2 = ::GetMicrosecondCount();   //Print Debug
   g_GraphElementsCollection.OnTimerEvent();
   ulong d3 = ::GetMicrosecondCount();   //Print Debug
   g_dbg_timer_n++; g_dbg_timer_poll += d1 - d0; g_dbg_timer_gui += d2 - d1; g_dbg_timer_coll += d3 - d2; g_dbg_timer_max = MathMax(g_dbg_timer_max, d3 - d0);   //Print Debug
   DebugFlush();   //Print Debug
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
      bar_time = m_GUIPannel.BarTimeFromXY(x, y);
      if(bar_time != s_last_bar)   //Print Debug
         CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME), "EA", "OpenCandleInfo", "MY DEBUG shift hover x=" + (string)x + " y=" + (string)y + " bar=" + TimeToString(bar_time));   //Print Debug
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
   int count = m_PythonBridge.GetCandleInfo(bar_time, row_label, row_tf, row_dir, row_time, row_source);
   CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME), "EA", "OpenCandleInfo", "MY DEBUG by_marker=" + (string)by_marker + " bar=" + TimeToString(bar_time) + " rows=" + (string)count);   //Print Debug
   if(m_GUIPannel.RefreshWindow_CandleInfo(count, row_label, row_tf, row_dir, row_time, row_source))
     {
      m_GUIPannel.ShowWindow_CandleInfo(x, y, bar_time, by_marker);
      if(!by_marker)
         CCandleMarker::HighlightCandle(&g_GraphElementsCollection, bar_time);   // the marker route has its box already
     }
  }

 void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   ulong d0 = ::GetMicrosecondCount();   //Print Debug
   g_GraphElementsCollection.OnChartEvent(id, lparam, dparam, sparam);
   ulong d1 = ::GetMicrosecondCount();   //Print Debug
   if(id == CHARTEVENT_CHART_CHANGE)
      CCandleMarker::Arrange(&g_GraphElementsCollection);
   //--- The chart side of the Indicator tab: an indicator added, changed or removed by hand
   m_IndicatorTemplateManager.OnChartEvent(id, lparam, dparam, sparam, m_ChartObj);
   //--- A new row, or its Show flag: the indicator is attached to / detached from the chart
   if(m_ChartObj != NULL && id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      for(int t = 0; t < m_IndicatorTemplateManager.Total(); t++)
        {
         CIndicatorSetting *entry = m_IndicatorTemplateManager.At(t);
         if(entry == NULL || entry.TypeEnum() != (ENUM_INDICATOR)lparam || !entry.ShowOnChart())
            continue;
         MqlParam params[];
         entry.GetRawParams(params);
         if(!m_ChartObj.IsIndicatorShownOnChart(entry.TypeEnum(), params))
            m_ChartObj.ShowIndicatorOnChart(entry.TypeEnum(), params);
        }
     }
   if(m_ChartObj != NULL && id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
     {
      CIndicatorSetting *entry = m_IndicatorTemplateManager.At((int)lparam);
      if(entry != NULL)
        {
         MqlParam params[];
         entry.GetRawParams(params);
         bool shown = m_ChartObj.IsIndicatorShownOnChart(entry.TypeEnum(), params);
         if(entry.ShowOnChart() && !shown)
            m_ChartObj.ShowIndicatorOnChart(entry.TypeEnum(), params);
         else if(!entry.ShowOnChart() && shown)
            m_ChartObj.RemoveIndicatorFromChart(entry.TypeEnum(), params);
         ::ChartRedraw();
        }
     }
   if(m_ChartObj != NULL && id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      ENUM_INDICATOR type;
      MqlParam params[];
      m_IndicatorTemplateManager.GetLastRemoved(type, params);
      m_ChartObj.RemoveIndicatorFromChart(type, params);
      ::ChartRedraw();
     }
   //--- What Python calculates depends on the tracked pairs and on the Swing setting: tell it again
   if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED || id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE ||
      id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE ||
      id == CHARTEVENT_CUSTOM + GUIPANNEL_EVENT_SMARTMONEY_SETTING_CHANGED)
      m_PythonBridge.Reconfigure();
   //--- Marker colors saved, or the Buy / Sell flag of an indicator or a candle pattern changed: every marker is drawn again
   if(id == CHARTEVENT_CUSTOM + GUIPANNEL_EVENT_MARKER_SETTING_CHANGED || id == CHARTEVENT_CUSTOM + PATTERN_MANAGER_EVENT_BUYSELL_CHANGED ||
      id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED)
     {
      m_SmartMoneySync.DeleteMarkers();
      m_SmartMoneySync.Sync();
     }
   //--- A Symbol/TF picked in the panel: the chart goes there
   if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)
     {
      //--- sparam = "old|new" Symbol, lparam = old TF in the low 32 bits and the new TF in the high 32 bits (CSymbolTFManager::NotifySettingChanged)
      string symbols[];
      if(::StringSplit(sparam, '|', symbols) == 2)
         ::ChartSetSymbolPeriod(::ChartID(), symbols[1], (ENUM_TIMEFRAMES)(int)(lparam >> 32));
     }
   ulong d2 = ::GetMicrosecondCount();   //Print Debug
   OpenCandleInfo(id, lparam, dparam, sparam);
   m_GUIPannel.OnChartEvent(id, lparam, dparam, sparam);
   ulong d3 = ::GetMicrosecondCount();   //Print Debug
   if(id == CHARTEVENT_MOUSE_MOVE)   //Print Debug
     {   //Print Debug
      g_dbg_mouse_n++; g_dbg_mouse_coll += d1 - d0; g_dbg_mouse_gui += d3 - d2; g_dbg_mouse_max = MathMax(g_dbg_mouse_max, d3 - d0);   //Print Debug
     }   //Print Debug
  }
