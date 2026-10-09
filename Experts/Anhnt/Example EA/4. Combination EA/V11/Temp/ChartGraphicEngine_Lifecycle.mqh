//+------------------------------------------------------------------+
//|                                 ChartGraphicEngine_Lifecycle.mqh |
//+------------------------------------------------------------------+
#ifndef CCHARTGRAPHICENGINE_LIFECYCLE_MQH
#define CCHARTGRAPHICENGINE_LIFECYCLE_MQH
  #include "ChartGraphicEngine.mqh"
 #ifndef CCHARTGRAPHICENGINE_LIFECYCLE_MQH_IMPLEMENTATION
 #define CCHARTGRAPHICENGINE_LIFECYCLE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor / Destructor                                         |
 //+------------------------------------------------------------------+
 CChartGraphicEngine::CChartGraphicEngine(void)
   : m_SignalsCollection(NULL), m_IndicatorsCollection(NULL), m_BarTimeSeriesCollection(NULL),
     m_indicator_template_manager(NULL), m_symbol_tf_manager(NULL), m_patterns_control(NULL), m_swing_setting(NULL),
     m_clr_buy(clrLime), m_clr_sell(clrRed), m_clr_nonrelated(clrGray),
     m_window_bars(150), m_drawn_symbol(""), m_drawn_tf(PERIOD_CURRENT), m_watermark(0),
     m_need_full_rebuild(true), m_pending_pos(0), m_bars_per_tick(3)
  {
   //--- Defaults = the old SignalMarkers.mq5 inputs, overwritten by SetMarkerStyle() from the GUI
   int def[MARKER_SLOTS_TOTAL] = {233, 234, 217, 218, 67, 68, 225, 226, 234, 233};
   ::ArrayCopy(m_code, def);
   m_name_prefix = ::MQLInfoString(MQL_PROGRAM_NAME) + "_";
   m_pending.FreeMode(true);   // owns its CBarMarks
  }
 CChartGraphicEngine::~CChartGraphicEngine(void)
  {
  }
 //+------------------------------------------------------------------+
 //| Lifecycle                                                        |
 //+------------------------------------------------------------------+
 void CChartGraphicEngine::OnInitEvent(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars,
                                       CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr,
                                       CBarPatternsControl *patterns_ctrl, CSwingSetting *swing_setting)
  {
   m_SignalsCollection          = signals;
   m_IndicatorsCollection       = ind;
   m_BarTimeSeriesCollection    = bars;
   m_indicator_template_manager = tmpl_mgr;
   m_symbol_tf_manager          = symtf_mgr;
   m_patterns_control           = patterns_ctrl;
   m_swing_setting              = swing_setting;
   m_GraphCollection.CreateChartControlList();
   m_need_full_rebuild = true;
  }
  void CChartGraphicEngine::OnDeinitEvent(const int reason)
  {
   //--- Objects survive a TF change on purpose (the next timer sees m_drawn_tf != Period() and
   //--- rebuilds); a real detach must leave the chart clean.
   if(reason != REASON_CHARTCHANGE)
      DeleteAllObjects();
   m_GraphCollection.OnDeinit();
  }
 bool CChartGraphicEngine::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Native chart events are deliberately NOT forwarded to m_GraphCollection.OnChartEvent():
   //--- a click on any object it does not own (every GUI canvas) makes it assume a rename and
   //--- run FindMissingObj() = every collection object x every chart object via ObjectName()
   //--- (563 x 6,400 = minutes; the terminal killed the EA after 120 s). Markers need no
   //--- drag/rename tracking; Trendline will get its own, name-filtered handler.
   //--- Same triggers CSignalBridgeWriter rebuilt the whole file on - any gate/style change
   if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED ||
      id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE ||
      id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED ||
      id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED ||
      id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE ||
      id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED ||
      id == CHARTEVENT_CUSTOM + BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED ||
      id == CHARTEVENT_CUSTOM + SWING_SETTING_EVENT_CHANGED)
     {
      m_need_full_rebuild = true;
      return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Timer: rebuild when symbol/TF/style changed, else redraw only the |
 //| bars touched by sources newer than the watermark; prune the      |
 //| window; let the collection watch the chart about once a second.  |
 //+------------------------------------------------------------------+
 void CChartGraphicEngine::OnTimerEvent(void)
  {
   if(m_SignalsCollection == NULL || m_IndicatorsCollection == NULL || m_BarTimeSeriesCollection == NULL)
      return;
   string          sym = ::Symbol();
   ENUM_TIMEFRAMES tf  = (ENUM_TIMEFRAMES)::Period();
   if(sym != m_drawn_symbol || tf != m_drawn_tf)
      m_need_full_rebuild = true;

   //--- Still drawing a previous batch: spend this tick's budget on it and come back next tick.
   //--- Each object costs ~10 ms of chart API, so a 400-bar rebuild in one go froze the GUI for 10 s.
   if(IsDrawing() && !m_need_full_rebuild)
     {
      DrawPending();
      return;
     }
   datetime newest = NewestSourceTime(sym);
   if(m_need_full_rebuild || newest > m_watermark)
     {
      datetime since = m_watermark;
      if(m_need_full_rebuild)
        {
         m_pending.Clear();
         m_pending_pos = 0;
         DeleteAllObjects();
         m_drawn_symbol = sym;
         m_drawn_tf     = tf;
         int oldest_shift = MathMin(m_window_bars, ::Bars(sym, tf) - 1);
         datetime window_start = (oldest_shift > 0) ? ::iTime(sym, tf, oldest_shift) : 0;
         since = window_start - 1;   // CollectBarMarks takes "strictly newer than"
        }
      ulong t_collect = ::GetMicrosecondCount();
      CArrayObj marks;
      marks.FreeMode(false);   // ownership moves to m_pending below
      int n = CollectBarMarks(sym, since, marks);
      //--- Queue newest-first so the bars the user is looking at appear immediately
      for(int i = n - 1; i >= 0; i--) m_pending.Add(marks.At(i));
      m_watermark = newest;
      if(m_need_full_rebuild)
         ::Print(__FUNCTION__, " > rebuilding markers on ", n, " bar(s) for ", sym, " ", TimeframeDescription(tf),
                 " (collect ", (::GetMicrosecondCount() - t_collect) / 1000, " ms, ", m_bars_per_tick, " bar(s)/tick)");
      m_need_full_rebuild = false;
      DrawPending();
      return;
     }
   PruneWindow();
   //--- Deliberately NO m_GraphCollection.Refresh() here. It wraps every non-program object on the
   //--- chart into a CGStd*Obj - MT5's own "Show trade history" arrows/lines ("autotrade #...")
   //--- alone were 5,352 objects on XAUUSDm = 42 s frozen. Markers are created/deleted through the
   //--- collection API, so it already knows everything it owns. Revisit (with a name filter) only
   //--- when user-drawn objects have to be tracked, e.g. Trendline.
  }
 #endif // CCHARTGRAPHICENGINE_LIFECYCLE_MQH_IMPLEMENTATION
#endif // CCHARTGRAPHICENGINE_LIFECYCLE_MQH