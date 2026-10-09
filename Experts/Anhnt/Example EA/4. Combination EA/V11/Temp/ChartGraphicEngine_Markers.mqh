//+------------------------------------------------------------------+
//|                                   ChartGraphicEngine_Markers.mqh |
//| CChartGraphicEngine - lifecycle + marker drawing. The source walk |
//| and the per-bar shape/color rules are the ones CSignalBridgeWriter|
//| and SignalMarkers::ComputeBar used; only the output changed from |
//| "file row" to "chart object via CGraphElementsCollection".        |
//+------------------------------------------------------------------+
#ifndef CCHARTGRAPHICENGINE_MARKERS_MQH
#define CCHARTGRAPHICENGINE_MARKERS_MQH
#include "ChartGraphicEngine.mqh"
 //+------------------------------------------------------------------+
 //| CBarMarks                                                        |
 //+------------------------------------------------------------------+
 CBarMarks::CBarMarks(const datetime t)
  {
   time = t;
   ind_buy = ind_sell = pat_buy = pat_sell = own_buy = own_sell = 0;
   swing_low = swing_high = own_swing_low = own_swing_high = swing_low_struct = swing_high_struct = 0;
  }
 int CBarMarks::Compare(const CObject *node, const int mode = 0) const
  {
   const CBarMarks *other = node;
   return (time > other.time) ? 1 : (time < other.time) ? -1 : 0;
  } 
 void CChartGraphicEngine::SetMarkerStyle(const int &codes[], const color buy_clr, const color sell_clr, const color nonrelated_clr)
  {
   int n = MathMin(::ArraySize(codes), MARKER_SLOTS_TOTAL);
   for(int i = 0; i < n; i++) m_code[i] = codes[i];
   m_clr_buy        = buy_clr;
   m_clr_sell       = sell_clr;
   m_clr_nonrelated = nonrelated_clr;
   m_need_full_rebuild = true;
  } 
 //+------------------------------------------------------------------+
 //| Gates - identical to CSignalBridgeWriter                         |
 //+------------------------------------------------------------------+
 bool CChartGraphicEngine::GetIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &raw_params[], bool &buy, bool &sell)
  {
   buy = false; sell = false;
   if(m_indicator_template_manager == NULL) return false;
   CIndicatorSetting *entry = m_indicator_template_manager.FindByIdentity(type, raw_params);
   if(entry == NULL) return false;
   buy  = entry.BuySignal();
   sell = entry.SellSignal();
   return true;
  }
 bool CChartGraphicEngine::GetSymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf, bool &buy, bool &sell)
  {
   buy = false; sell = false;
   if(m_symbol_tf_manager == NULL) return false;
   CSymbolTFSetting *entry = m_symbol_tf_manager.FindByIdentity(sym, tf);
   if(entry == NULL) return false;
   buy  = entry.BuySignal();
   sell = entry.SellSignal();
   return true;
  }
 bool CChartGraphicEngine::GetCandlePatternSetting(const ENUM_PATTERN_TYPE type, bool &buy, bool &sell)
  {
   buy = false; sell = false;
   if(m_patterns_control == NULL) return false;
   CArrayObj *controls = m_patterns_control.GetListControls();
   int n = (controls != NULL) ? controls.Total() : 0;
   for(int i = 0; i < n; i++)
     {
      CBarPatternControl *c = controls.At(i);
      if(c == NULL || c.TypePattern() != type) continue;
      buy  = c.BuySignal();
      sell = c.SellSignal();
      return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Newest bar-open time across this symbol's series (any TF) - each  |
 //| CBarSeriesDE::Refresh() updates its own LastBarDate() and, in the |
 //| same new-bar gate, its patterns_control/swing_control right after|
 //| (BarSeriesDE.mqh); indicator signals commit off the same new-bar |
 //| detection via SERIES_EVENTS_NEW_BAR. One shared clock per series -|
 //| no need to walk indicators/signals/patterns/swings separately.   |
 //+------------------------------------------------------------------+
 datetime CChartGraphicEngine::NewestSourceTime(const string sym)
  {
   datetime newest = 0;
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *s = series_list.At(ti);
      if(s != NULL && s.LastBarDate() > newest) newest = s.LastBarDate();
     }
   return newest;
  }
 //+------------------------------------------------------------------+
 //| Chart bar (open time on the CHART's TF) a source time falls into  |
 //+------------------------------------------------------------------+
 datetime CChartGraphicEngine::ChartBarOf(const string sym, const ENUM_TIMEFRAMES chart_tf, const datetime t)
  {
   int shift = ::iBarShift(sym, chart_tf, t, false);
   if(shift < 0) return 0;
   return ::iTime(sym, chart_tf, shift);
  }
 //+------------------------------------------------------------------+
 //| Sorted lookup of a bar's CBarMarks (binary Search on time);       |
 //| 'add' creates it when absent, else NULL                           |
 //+------------------------------------------------------------------+
 CBarMarks *CChartGraphicEngine::FindOrAddMark(CArrayObj &marks, const datetime bar_time, const bool add)
  {
   if(bar_time == 0) return NULL;   // ChartBarOf() failed - no chart bar to hang objects on
   CBarMarks probe(bar_time);
   marks.Sort();
   int idx = marks.Search(&probe);
   if(idx >= 0) return marks.At(idx);
   if(!add) return NULL;
   CBarMarks *m = new CBarMarks(bar_time);
   if(!marks.InsertSort(m)) { delete m; return NULL; }
   return m;
  }
 //+------------------------------------------------------------------+
 //| Two passes over the sources: (A) which chart bars are touched by  |
 //| anything newer than 'since' (Swing: by ConfirmedTime, bar = pivot)|
 //| (B) full tally of EVERY gated row falling into those bars, so a  |
 //| redrawn bar is always complete, never "just the new rows".        |
 //+------------------------------------------------------------------+
 int CChartGraphicEngine::CollectBarMarks(const string sym, const datetime since, CArrayObj &marks)
  {
   marks.Clear();
   ENUM_TIMEFRAMES chart_tf = (ENUM_TIMEFRAMES)::Period();
   int own_tf = (int)chart_tf;
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   CArrayObj *all_patterns = m_BarTimeSeriesCollection.GetListAllPatterns();
   CArrayObj *all_swings   = m_BarTimeSeriesCollection.GetListAllSwings();
   int pat_total = (all_patterns != NULL) ? all_patterns.Total() : 0;
   int sw_total  = (all_swings   != NULL) ? all_swings.Total()   : 0;

   for(int pass = 0; pass < 2; pass++)
     {
      bool collect = (pass == 0);   // A: build the bar set   B: tally into it
      //--- Indicator signals
      for(int ti = 0; ti < series_total; ti++)
        {
         CBarSeriesDE *s = series_list.At(ti);
         if(s == NULL) continue;
         ENUM_TIMEFRAMES tf = s.Timeframe();
         bool symtf_buy, symtf_sell;
         GetSymbolTFSetting(sym, tf, symtf_buy, symtf_sell);
         CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
         ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
         int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
         for(int ii = 0; ii < ind_total; ii++)
           {
            CIndicatorDE *ind = ind_list.At(ii);
            if(ind == NULL) continue;
            MqlParam params[];
            ind.GetMqlParams(params);
            bool buy_on, sell_on;
            if(!GetIndicatorTemplateSetting(ind.TypeIndicator(), params, buy_on, sell_on)) continue;
            buy_on  = buy_on  && symtf_buy;
            sell_on = sell_on && symtf_sell;
            if(!buy_on && !sell_on) continue;
            CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
            if(signal == NULL) continue;
            //--- main history + (BBands) the 2 outer-line histories, same rows the bridge wrote
            for(int line = -1; line < 3; line++)
              {
               if(line >= 0 && (ind.TypeIndicator() != IND_BANDS || line == BBAND_LINE_MID)) continue;
               CSignalBollinger *bb = (line >= 0) ? (CSignalBollinger*)signal : NULL;
               int total = (line < 0) ? signal.HistoryTotal() : bb.LineHistoryTotal(line);
               for(int h = 0; h < total; h++)
                 {
                  datetime t = (line < 0) ? signal.HistoryTime(h) : bb.LineHistoryTime(line, h);
                  ENUM_SIGNAL_DIR dir = (line < 0) ? signal.HistoryDir(h) : bb.LineHistoryDir(line, h);
                  if(dir == SIGNAL_NONE) continue;
                  if(dir == SIGNAL_BUY  && !buy_on)  continue;
                  if(dir == SIGNAL_SELL && !sell_on) continue;
                  if(collect) { if(t >= since) FindOrAddMark(marks, ChartBarOf(sym, chart_tf, t), true); continue; }
                  CBarMarks *mk = FindOrAddMark(marks, ChartBarOf(sym, chart_tf, t), false);
                  if(mk == NULL) continue;
                  if(dir == SIGNAL_BUY) mk.ind_buy++; else mk.ind_sell++;
                  if((int)tf == own_tf) { if(dir == SIGNAL_BUY) mk.own_buy++; else mk.own_sell++; }
                 }
              }
           }
        }
      //--- Candle patterns
      for(int p = 0; p < pat_total; p++)
        {
         CBarPattern *pat = all_patterns.At(p);
         if(pat == NULL || pat.Symbol() != sym) continue;
         ENUM_PATTERN_DIRECTION pdir = pat.Direction();
         ENUM_SIGNAL_DIR dir = (pdir == PATTERN_DIRECTION_BULLISH) ? SIGNAL_BUY : (pdir == PATTERN_DIRECTION_BEARISH) ? SIGNAL_SELL : SIGNAL_NONE;
         if(dir == SIGNAL_NONE) continue;
         bool symtf_buy, symtf_sell, pat_buy, pat_sell;
         GetSymbolTFSetting(sym, pat.Timeframe(), symtf_buy, symtf_sell);
         if(!GetCandlePatternSetting(pat.TypePattern(), pat_buy, pat_sell)) continue;
         if(dir == SIGNAL_BUY  && !(pat_buy  && symtf_buy))  continue;
         if(dir == SIGNAL_SELL && !(pat_sell && symtf_sell)) continue;
         datetime t = pat.Time();
         if(collect) { if(t >= since) FindOrAddMark(marks, ChartBarOf(sym, chart_tf, t), true); continue; }
         CBarMarks *mk = FindOrAddMark(marks, ChartBarOf(sym, chart_tf, t), false);
         if(mk == NULL) continue;
         if(dir == SIGNAL_BUY) mk.pat_buy++; else mk.pat_sell++;
         if((int)pat.Timeframe() == own_tf) { if(dir == SIGNAL_BUY) mk.own_buy++; else mk.own_sell++; }
        }
      //--- Swings - gated only by CSwingSetting Show; bar = the PIVOT, newness = ConfirmedTime
      if(m_swing_setting != NULL)
       for(int w = 0; w < sw_total; w++)
        {
         CBarSwing *sw = all_swings.At(w);
         if(sw == NULL || sw.Symbol() != sym) continue;
         if(!m_swing_setting.SignalShow(sw.TypeSwing())) continue;
         if(collect)
           {
            if(sw.ConfirmedTime() >= since)
               FindOrAddMark(marks, ChartBarOf(sym, chart_tf, sw.Time()), true);
            continue;
           }
         CBarMarks *mk = FindOrAddMark(marks, ChartBarOf(sym, chart_tf, sw.Time()), false);
         if(mk == NULL) continue;
         bool own = ((int)sw.Timeframe() == own_tf);
         if(sw.TypeSwing() == SWING_TYPE_LOW)
           { mk.swing_low++;  if(own) mk.own_swing_low++;  if(own || mk.swing_low_struct  == 0) mk.swing_low_struct  = (int)sw.Structure(); }
         else
           { mk.swing_high++; if(own) mk.own_swing_high++; if(own || mk.swing_high_struct == 0) mk.swing_high_struct = (int)sw.Structure(); }
        }
     }
   // DEBUG-TEMP: remove once swing-gap investigation is closed
   if(m_swing_setting != NULL && sw_total > 0)
     {
      int marks_with_swing = 0;
      for(int mi = 0; mi < marks.Total(); mi++)
        {
         CBarMarks *m = marks.At(mi);
         if(m != NULL && (m.swing_low + m.swing_high) > 0) marks_with_swing++;
        }
      ::Print("MY DEBUG CChartGraphicEngine::CollectBarMarks: ", sym, " ", EnumToString(chart_tf),
              " sw_total(all symbols)=", sw_total, " marks_total=", marks.Total(),
              " marks_with_swing=", marks_with_swing);
     }
   return marks.Total();
  }
 //+------------------------------------------------------------------+
 //| Object naming: "<program>_SM_<bartime>_<kind>" - deterministic so |
 //| a redraw is delete + create; kinds: S signal, SL/SH swing arrow, |
 //| LL/LH swing structure label                                       |
 //+------------------------------------------------------------------+
 string CChartGraphicEngine::ObjName(const datetime bar_time, const string kind)
  {
   return "SM_" + (string)(long)bar_time + "_" + kind;
  }
 bool CChartGraphicEngine::CreateArrowMarker(const string name, const datetime t, const double price, const int code, const bool below, const color clr)
  {
   //--- ~7-13 ms per object, almost all inside CreateArrow (the CGStdArrowObj mirror reads every
   //--- property back from the chart) - hence the per-tick budget in DrawPending()
   if(!m_GraphCollection.CreateArrow(::ChartID(), name, 0, false, t, price, (uchar)code, below ? ANCHOR_TOP : ANCHOR_BOTTOM))
      return false;
   CGStdGraphObj *obj = m_GraphCollection.GetStdGraphObject(m_name_prefix + name, ::ChartID());
   if(obj == NULL) return false;
   obj.SetColor(clr);
   obj.SetFlagSelectable(false, false);
   obj.SetFlagHidden(true, false);      // keep the object list (Ctrl+B) free of hundreds of markers
   return true;
  }
 bool CChartGraphicEngine::CreateLabel(const string name, const datetime t, const double price, const string text, const bool above, const color clr)
  {
   if(!m_GraphCollection.CreateText(::ChartID(), name, 0, false, t, price, text, 8, above ? ANCHOR_LOWER : ANCHOR_UPPER, 0.0))
      return false;
   CGStdGraphObj *obj = m_GraphCollection.GetStdGraphObject(m_name_prefix + name, ::ChartID());
   if(obj == NULL) return false;
   obj.SetColor(clr);
   obj.SetFlagSelectable(false, false);
   obj.SetFlagHidden(true, false);
   obj.SetFlagBack(true, false);        // behind the chart - never paints over the GUI panels
   return true;
  }
 //+------------------------------------------------------------------+
 //| One bar -> up to 5 objects, exactly SignalMarkers::ComputeBar's   |
 //| rules: swing arrows 1.0x range off the wick (+0.8x for the label),|
 //| signal marker 0.5x range off, shape from the indicator/pattern   |
 //| mix, color from the OWN-TF rows only (gray = none on this TF).   |
 //+------------------------------------------------------------------+
 void CChartGraphicEngine::DrawBar(const CBarMarks &m)
  {
   string sym = ::Symbol();
   int shift = ::iBarShift(sym, PERIOD_CURRENT, m.time, true);
   if(shift < 0) return;
   double high = ::iHigh(sym, PERIOD_CURRENT, shift);
   double low  = ::iLow(sym, PERIOD_CURRENT, shift);
   double range = high - low;
   //--- Swings
   if(m.swing_low + m.swing_high > 0)
     {
      double swing_gap = range * 1.0;
      double label_gap = swing_gap * 0.8;
      if(m.swing_low > 0)
        {
         color clr = (m.own_swing_low > 0) ? m_clr_buy : m_clr_nonrelated;
         CreateArrowMarker(ObjName(m.time, "SL"), m.time, low - swing_gap, m_code[MARKER_SWING_LOW], true, clr);
         string text = (m.swing_low_struct != SWING_STRUCTURE_NONE) ? SwingStructureDescription((ENUM_SWING_STRUCTURE)m.swing_low_struct) : "";
         if(text != "") CreateLabel(ObjName(m.time, "LL"), m.time, low - swing_gap - label_gap, text, false, clr);
        }
      if(m.swing_high > 0)
        {
         color clr = (m.own_swing_high > 0) ? m_clr_sell : m_clr_nonrelated;
         CreateArrowMarker(ObjName(m.time, "SH"), m.time, high + swing_gap, m_code[MARKER_SWING_HIGH], false, clr);
         string text = (m.swing_high_struct != SWING_STRUCTURE_NONE) ? SwingStructureDescription((ENUM_SWING_STRUCTURE)m.swing_high_struct) : "";
         if(text != "") CreateLabel(ObjName(m.time, "LH"), m.time, high + swing_gap + label_gap, text, true, clr);
        }
     }
   //--- Signal marker
   int total_ind = m.ind_buy + m.ind_sell;
   int total_pat = m.pat_buy + m.pat_sell;
   if(total_ind + total_pat == 0) return;
   color clr = (m.own_buy + m.own_sell > 0) ? ((m.own_buy >= m.own_sell) ? m_clr_buy : m_clr_sell) : m_clr_nonrelated;
   double gap = range * 0.5;
   bool is_buy; int slot;
   if(total_ind > 0 && total_pat == 0)
     { is_buy = (m.ind_buy >= m.ind_sell); slot = (total_ind == 1) ? (is_buy ? MARKER_SINGLE_BUY : MARKER_SINGLE_SELL) : (is_buy ? MARKER_MULTI_BUY : MARKER_MULTI_SELL); }
   else if(total_ind == 0 && total_pat > 0)
     { is_buy = (m.pat_buy >= m.pat_sell); slot = is_buy ? MARKER_PATTERN_BUY : MARKER_PATTERN_SELL; }
   else
     { is_buy = (m.ind_buy + m.pat_buy >= m.ind_sell + m.pat_sell); slot = is_buy ? MARKER_COMBO_BUY : MARKER_COMBO_SELL; }
   CreateArrowMarker(ObjName(m.time, "S"), m.time, is_buy ? (low - gap) : (high + gap), m_code[slot], is_buy, clr);
  }
 //+------------------------------------------------------------------+
 //| Draw up to m_bars_per_tick queued bars; one ChartRedraw per tick. |
 //| Queue exhausted => reset, prune the window, report the total.     |
 //+------------------------------------------------------------------+
 void CChartGraphicEngine::DrawPending(void)
  {
   int total = m_pending.Total();
   if(m_pending_pos >= total) return;
   static ulong s_batch_us = 0;
   ulong t0 = ::GetMicrosecondCount();
   int stop = MathMin(total, m_pending_pos + m_bars_per_tick);
   m_GraphCollection.SetRedrawOnAdd(false);
   for(; m_pending_pos < stop; m_pending_pos++)
     {
      CBarMarks *m = m_pending.At(m_pending_pos);
      if(m == NULL) continue;
      DeleteBarObjects(m.time);
      DrawBar(m);
     }
   m_GraphCollection.SetRedrawOnAdd(true);
   ::ChartRedraw();
   s_batch_us += ::GetMicrosecondCount() - t0;
   if(m_pending_pos >= total)
     {
      ::Print(__FUNCTION__, " > drew ", total, " bar(s), objects=", m_GraphCollection.GetListGraphObj().Total(),
              ", draw time ", s_batch_us / 1000, " ms spread over ticks");
      s_batch_us = 0;
      m_pending.Clear();
      m_pending_pos = 0;
      PruneWindow();
     }
  }
 //+------------------------------------------------------------------+
 //| Delete every object of a (temporary, non-owning) selection list   |
 //| from the chart and the collection. Names are copied first: the   |
 //| selection holds pointers into the collection, which frees them.  |
 //+------------------------------------------------------------------+
 void CChartGraphicEngine::DeleteObjectsInList(CArrayObj *list)
  {
   int n = (list != NULL) ? list.Total() : 0;
   if(n == 0) return;
   string names[];
   ::ArrayResize(names, 0, n);
   for(int i = 0; i < n; i++)
     {
      CGStdGraphObj *obj = list.At(i);
      if(obj == NULL || obj.ChartID() != ::ChartID()) continue;
      if(::StringFind(obj.Name(), m_name_prefix + "SM_") != 0) continue;   // only our markers, never anything else the collection may hold
      int k = ::ArraySize(names);
      ::ArrayResize(names, k + 1);
      names[k] = obj.Name();
     }
   for(int i = 0; i < ::ArraySize(names); i++)
      m_GraphCollection.DeleteCreatedObj(::ChartID(), names[i]);
  }
 //--- Bar membership comes from the collection itself: every marker's pivot-0 time IS its chart bar
 void CChartGraphicEngine::DeleteBarObjects(const datetime bar_time)
  {
   DeleteObjectsInList(m_GraphCollection.GetList(GRAPH_OBJ_PROP_TIME, 0, (long)bar_time, EQUAL));
  }
 void CChartGraphicEngine::DeleteAllObjects(void)
  {
   DeleteObjectsInList(m_GraphCollection.GetListGraphObj());
   //--- Safety sweep: anything of ours the collection doesn't know (e.g. a previous run that never deinit'd)
   ::ObjectsDeleteAll(::ChartID(), m_name_prefix + "SM_");
  }
 //+------------------------------------------------------------------+
 //| Drop the objects of bars that slid out of the window             |
 //+------------------------------------------------------------------+
 void CChartGraphicEngine::PruneWindow(void)
  {
   if(m_GraphCollection.GetListGraphObj().Total() == 0) return;
   string sym = ::Symbol();
   int oldest_shift = MathMin(m_window_bars, ::Bars(sym, PERIOD_CURRENT) - 1);
   if(oldest_shift <= 0) return;
   datetime window_start = ::iTime(sym, PERIOD_CURRENT, oldest_shift);
   //--- The window edge only moves on a new chart bar - and every GetList() parks a temporary
   //--- CArrayObj in CommonListStorage that is never freed before deinit, so don't select per tick
   static datetime s_last_window_start = 0;
   if(window_start == s_last_window_start) return;
   s_last_window_start = window_start;
   DeleteObjectsInList(m_GraphCollection.GetList(GRAPH_OBJ_PROP_TIME, 0, (long)window_start, LESS));
  }
#endif // CCHARTGRAPHICENGINE_MARKERS_MQH
