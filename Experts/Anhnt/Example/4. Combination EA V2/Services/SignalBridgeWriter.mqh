//+------------------------------------------------------------------+
//|                                           SignalBridgeWriter.mqh |
//|                                     Copyright 2026, Anhnt        |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef __SIGNALBRIDGEWRITER_MQH__
#define __SIGNALBRIDGEWRITER_MQH__
 //Include
  #include <Arrays\ArrayObj.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\BarTimeSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\IndicatorsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SignalsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Indicators\IndicatorDE.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarPatternsControl\BarPatternsControl.mqh>
  #include "IndicatorTemplateManager.mqh"   // CIndicatorTemplateManager - EA-owned, read LIVE (no copy needed)
  #include "SymbolTFManager.mqh"            // CSymbolTFManager - EA-owned, read LIVE (no copy needed)
  #include "SignalBridgeRow.mqh"            // CSignalBridgeRow - 1 output row, held in a CArrayObj
  #include "SwingSettingJSON.mqh"
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarSwingSeries\BarSwing.mqh>
 //Define
  #define SIGNAL_BRIDGE_MAGIC 20260919   // plain define, no #ifndef - an earlier stale copy must be a compile error, not a silent win
  #define SIGNAL_BRIDGE_WRITER_EVENT_UPDATED 50000   // full rebuild wrote the file - indicator should reread now
  #define SIGNAL_BRIDGE_ROW_EVENT            50001   // one new row, carried in the event itself - no file involved

 #ifndef CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #define CSIGNALBRIDGEWRITER_MQH_DECLARATION
  class CSignalBridgeWriter : public CBaseObj
  {
    private:
     //Pointer from Layer 1, CTimeSeriesEngine hold
      CSignalsCollection          *m_SignalsCollection;              // 1-1 CIndicatorDE<->CSignalXXX linkage (EA-local)
      CIndicatorsCollection       *m_IndicatorsCollection;           //Indicator collection
      CBarTimeSeriesCollection    *m_BarTimeSeriesCollection;        //Timeseries collection         
      CIndicatorTemplateManager   *m_indicator_template_manager;
      CSymbolTFManager            *m_symbol_tf_manager;     
      CBarPatternsControl         *m_patterns_control;
      CSwingSetting               *m_swing_setting;

     // Per-Symbol watermark was 2 scalars (m_signal_bridge_symbol/m_signal_bridge_last_time),
     // so switching the active chart between 2+ already-tracked Symbols made EVERY switch look
     // "fresh" for whichever Symbol wasn't the last one written, forcing a full unconditional
     // rewrite even though nothing about that Symbol's own signal history had changed. Parallel
     // arrays let each Symbol keep its own watermark.
     // One shared watermark across Indicator+Pattern+Swing (pre-2026-09-22) let a newer
     // Indicator/Pattern row push the combined watermark past a Swing's ConfirmedTime() before
     // that Swing had ever actually been pushed - ConfirmedTime() is pivot time + N bars, so it's
     // structurally older than same-tick Signal/Pattern times. The incremental filter then saw
     // the Swing as already-covered and silently dropped it forever. Split into 3 independent
     // per-type watermarks so one type's progress can never mask another's (Anhnt/Claude, 2026-09-22).
      string                     m_bridge_wm_symbol[];
      datetime                   m_bridge_wm_time_indicator[];
      datetime                   m_bridge_wm_time_pattern[];
      datetime                   m_bridge_wm_time_swing[];
     int                        FindWatermarkIndex(const string sym);
     bool                       GetIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &raw_params[], bool &buy, bool &sell);
     bool                       GetSymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf, bool &buy, bool &sell);
     bool                       GetCandlePatternSetting(const ENUM_PATTERN_TYPE type, bool &buy, bool &sell);
     void                       AppendSignalBridgeFile(CArrayObj &rows, const string sym);
     void                       PushRowsAsEvents(CArrayObj &rows);

    public:
     CSignalBridgeWriter(void);
    ~CSignalBridgeWriter(void);

     void                       OnInitEvent(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars,
                                            CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr, CBarPatternsControl *patterns_ctrl,
                                            CSwingSetting *swing_setting);
     void                       BuildAndWriteSignalBridge(const bool force_full_rebuild = false);
     bool                       OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
  };
 #endif // CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #ifndef CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
 #define CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CSignalBridgeWriter::CSignalBridgeWriter(void)
    : m_SignalsCollection(NULL), m_IndicatorsCollection(NULL), m_BarTimeSeriesCollection(NULL),
      m_indicator_template_manager(NULL), m_symbol_tf_manager(NULL), m_patterns_control(NULL),
      m_swing_setting(NULL)
  {
  }
  //+------------------------------------------------------------------+
  //| FindWatermarkIndex - -1 if this Symbol has never been built yet   |
  //+------------------------------------------------------------------+
  int CSignalBridgeWriter::FindWatermarkIndex(const string sym)
   {
    for(int i = 0; i < ::ArraySize(m_bridge_wm_symbol); i++)
       if(m_bridge_wm_symbol[i] == sym) return i;
    return -1;
   }

  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CSignalBridgeWriter::~CSignalBridgeWriter(void)
   {
   }  
  void CSignalBridgeWriter::OnInitEvent(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars,
                                        CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr, CBarPatternsControl *patterns_ctrl,
                                        CSwingSetting *swing_setting)
   {
    m_SignalsCollection = signals;
    m_IndicatorsCollection = ind;
    m_BarTimeSeriesCollection = bars;
    m_indicator_template_manager = tmpl_mgr;
    m_symbol_tf_manager = symtf_mgr;
    m_patterns_control = patterns_ctrl;
    m_swing_setting = swing_setting;
   }
  //+------------------------------------------------------------------+
  //| GetIndicatorTemplateSetting - identity-only lookup against the LIVE        |
  //| CIndicatorTemplateManager (EA-owned Service layer).                |
  //+------------------------------------------------------------------+
  bool CSignalBridgeWriter::GetIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &raw_params[], bool &buy, bool &sell)
   {
    buy = false;
    sell = false;
    if(m_indicator_template_manager == NULL) return false;
    CIndicatorSetting *entry = m_indicator_template_manager.FindByIdentity(type, raw_params);
    if(entry == NULL) return false;
    buy  = entry.BuySignal();
    sell = entry.SellSignal();
    return true;
   }
  //+------------------------------------------------------------------+
  //| GetSymbolTFSetting - Symbol+TF-level gate, applies equally to         |
  //| Indicator- and Pattern-sourced signals on that (symbol,tf).       |
  //+------------------------------------------------------------------+
  bool CSignalBridgeWriter::GetSymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf, bool &buy, bool &sell)
   {
    buy = false;
    sell = false;
    if(m_symbol_tf_manager == NULL) return false;
    CSymbolTFSetting *entry = m_symbol_tf_manager.FindByIdentity(sym, tf);
    if(entry == NULL) return false;
    buy  = entry.BuySignal();
    sell = entry.SellSignal();
    return true;
   }
  //+------------------------------------------------------------------+
  //| GetCandlePatternSetting - identity-only lookup against the LIVE   |
  //| m_patterns_control (same registry CGUIPannel borrows), same        |
  //| pattern as GetIndicatorTemplateSetting/GetSymbolTFSetting above    |
  //| (Anhnt, 2026-08-29).                                                |
  //+------------------------------------------------------------------+
  bool CSignalBridgeWriter::GetCandlePatternSetting(const ENUM_PATTERN_TYPE type, bool &buy, bool &sell)
   {
    buy = false;
    sell = false;
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
  //| BuildAndWriteSignalBridge                                        |
  //+------------------------------------------------------------------+
  void CSignalBridgeWriter::BuildAndWriteSignalBridge(const bool force_full_rebuild)
   {
    if(m_SignalsCollection == NULL || m_IndicatorsCollection == NULL || m_BarTimeSeriesCollection == NULL)
      return;
    string sym = ::Symbol();
    int wm_idx = FindWatermarkIndex(sym);
    bool fresh = (wm_idx < 0);
    datetime prev_wm_indicator = fresh ? 0 : m_bridge_wm_time_indicator[wm_idx];
    datetime prev_wm_pattern   = fresh ? 0 : m_bridge_wm_time_pattern[wm_idx];
    datetime prev_wm_swing     = fresh ? 0 : m_bridge_wm_time_swing[wm_idx];

    CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
    CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
    int series_total = (series_list != NULL) ? series_list.Total() : 0;

    datetime newest_indicator = 0;
    for(int ti = 0; ti < series_total; ti++)
      {
       CBarSeriesDE *s = series_list.At(ti);
       if(s == NULL) continue;
       bool symtf_buy_wm, symtf_sell_wm;
       GetSymbolTFSetting(sym, s.Timeframe(), symtf_buy_wm, symtf_sell_wm);
       CArrayObj *ind_list = m_IndicatorsCollection.GetList();   // filtered inline below - no Select
       int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
       for(int ii = 0; ii < ind_total; ii++)
         {
          CIndicatorDE *ind = ind_list.At(ii);
          if(ind == NULL || ind.Symbol() != sym || ind.Timeframe() != s.Timeframe()) continue;
          MqlParam params[];
          ind.GetMqlParams(params);
          bool buy_on, sell_on;
          if(!GetIndicatorTemplateSetting(ind.TypeIndicator(), params, buy_on, sell_on)) continue;
          buy_on  = buy_on  && symtf_buy_wm;
          sell_on = sell_on && symtf_sell_wm;
          if(!buy_on && !sell_on) continue;
          CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
          if(signal == NULL) continue;
          int ht = signal.HistoryTotal();
          if(ht > 0)
           {
            datetime t = signal.HistoryTime(ht - 1);
            if(t > newest_indicator) newest_indicator = t;
           }
          if(ind.TypeIndicator() == IND_BANDS)
           {
            CSignalBollinger *bb = (CSignalBollinger*)signal;
            for(int li = 0; li < 3; li++)
              {
               int lt = bb.LineHistoryTotal(li);
               if(lt == 0) continue;
               datetime lts = bb.LineHistoryTime(li, lt - 1);
               if(lts > newest_indicator) newest_indicator = lts;
              }
           }
         }
      }
    datetime newest_pattern = 0;
    CArrayObj *all_patterns_wm = m_BarTimeSeriesCollection.GetListAllPatterns();
    if(all_patterns_wm != NULL)
     {
      int pat_total_wm = all_patterns_wm.Total();
      for(int p = 0; p < pat_total_wm; p++)
       {
        CBarPattern *pat_wm = all_patterns_wm.At(p);
        if(pat_wm == NULL || pat_wm.Symbol() != sym) continue;
        datetime pt = pat_wm.Time();
        if(pt > newest_pattern) newest_pattern = pt;
       }
     }
    // Swings: watermark on ConfirmedTime (pivot + N bars) - a freshly confirmed Swing has a pivot
    // Time() that is N bars OLD, so Time() alone could never move the watermark forward. Tracked
    // in its own watermark (not merged with Indicator/Pattern) - see the m_bridge_wm_time_swing[]
    // comment above for why a shared watermark silently dropped Swings.
    datetime newest_swing = 0;
    CArrayObj *all_swings_wm = m_BarTimeSeriesCollection.GetListAllSwings();
    if(all_swings_wm != NULL)
     {
      int sw_total_wm = all_swings_wm.Total();
      for(int w = 0; w < sw_total_wm; w++)
       {
        CBarSwing *sw_wm = all_swings_wm.At(w);
        if(sw_wm == NULL || sw_wm.Symbol() != sym) continue;
        datetime ct = sw_wm.ConfirmedTime();
        if(ct > newest_swing) newest_swing = ct;
       }
     }

    if(!fresh && !force_full_rebuild &&
       newest_indicator <= prev_wm_indicator && newest_pattern <= prev_wm_pattern && newest_swing <= prev_wm_swing)
       return;
    if(fresh)
     {
      wm_idx = ::ArraySize(m_bridge_wm_symbol);
      ::ArrayResize(m_bridge_wm_symbol, wm_idx + 1);
      ::ArrayResize(m_bridge_wm_time_indicator, wm_idx + 1);
      ::ArrayResize(m_bridge_wm_time_pattern, wm_idx + 1);
      ::ArrayResize(m_bridge_wm_time_swing, wm_idx + 1);
      m_bridge_wm_symbol[wm_idx] = sym;
     }
    bool do_full_rebuild = fresh || force_full_rebuild;
    datetime since_indicator = do_full_rebuild ? 0 : prev_wm_indicator;
    datetime since_pattern   = do_full_rebuild ? 0 : prev_wm_pattern;
    datetime since_swing     = do_full_rebuild ? 0 : prev_wm_swing;

    CArrayObj rows;
    rows.FreeMode(true); // owns the CSignalBridgeRow* it holds - deleted when rows goes out of scope
    for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *s = series_list.At(ti);
      if(s == NULL) continue;
      ENUM_TIMEFRAMES tf = s.Timeframe();
      bool symtf_buy, symtf_sell;
      GetSymbolTFSetting(sym, tf, symtf_buy, symtf_sell);
      CArrayObj *ind_list = m_IndicatorsCollection.GetList();   // filtered inline below - no Select
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
      for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *ind = ind_list.At(ii);
         if(ind == NULL || ind.Symbol() != sym || ind.Timeframe() != tf) continue;
         MqlParam params[];
         ind.GetMqlParams(params);
         bool buy_on, sell_on;
         if(!GetIndicatorTemplateSetting(ind.TypeIndicator(), params, buy_on, sell_on)) continue;
         buy_on  = buy_on  && symtf_buy;
         sell_on = sell_on && symtf_sell;
         if(!buy_on && !sell_on) continue;
         CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
         if(signal == NULL) continue;
         int hist_total = signal.HistoryTotal();
         for(int h = 0; h < hist_total; h++)
           {
            datetime h_time = signal.HistoryTime(h);
            if(h_time <= since_indicator) continue;
            ENUM_SIGNAL_DIR dir = signal.HistoryDir(h);
            if(dir == SIGNAL_NONE) continue;
            if(dir == SIGNAL_BUY  && !buy_on)  continue;
            if(dir == SIGNAL_SELL && !sell_on) continue;
            rows.Add(new CSignalBridgeRow(h_time, (int)tf, dir, 0)); // 0 = Indicator
           }
         if(ind.TypeIndicator() == IND_BANDS)
           {
            CSignalBollinger *bb = (CSignalBollinger*)signal;
            for(int li = 0; li < 3; li++)
              {
               if(li == BBAND_LINE_MID) continue;
               int line_total = bb.LineHistoryTotal(li);
               for(int h = 0; h < line_total; h++)
                 {
                  datetime lh_time = bb.LineHistoryTime(li, h);
                  if(lh_time <= since_indicator) continue;
                  ENUM_SIGNAL_DIR dir = bb.LineHistoryDir(li, h);
                  if(dir == SIGNAL_NONE) continue;
                  if(dir == SIGNAL_BUY  && !buy_on)  continue;
                  if(dir == SIGNAL_SELL && !sell_on) continue;
                  rows.Add(new CSignalBridgeRow(lh_time, (int)tf, dir, 0)); // 0 = Indicator
                 }
              }
           }
        }
     }
    CArrayObj *all_patterns = m_BarTimeSeriesCollection.GetListAllPatterns();
    if(all_patterns != NULL)
     {
      int pat_total = all_patterns.Total();
      for(int p = 0; p < pat_total; p++)
       {
        CBarPattern *pat = all_patterns.At(p);
        if(pat == NULL || pat.Symbol() != sym || pat.Time() <= since_pattern) continue;

        ENUM_PATTERN_DIRECTION pdir = pat.Direction();
        ENUM_SIGNAL_DIR pdir_signal = (pdir == PATTERN_DIRECTION_BULLISH) ? SIGNAL_BUY :
                                      (pdir == PATTERN_DIRECTION_BEARISH) ? SIGNAL_SELL : SIGNAL_NONE;
        if(pdir_signal == SIGNAL_NONE) continue;

        bool symtf_buy, symtf_sell;
        GetSymbolTFSetting(sym, pat.Timeframe(), symtf_buy, symtf_sell);
        bool pat_buy, pat_sell;
        if(!GetCandlePatternSetting(pat.TypePattern(), pat_buy, pat_sell)) continue;
        if(pdir_signal == SIGNAL_BUY  && !(pat_buy  && symtf_buy))  continue;
        if(pdir_signal == SIGNAL_SELL && !(pat_sell && symtf_sell)) continue;

        rows.Add(new CSignalBridgeRow(pat.Time(), (int)pat.Timeframe(), pdir_signal, 1)); // 1 = Pattern
       }
     }
    // Swings - gated ONLY by CSwingSetting's per-type Show toggle (no Symbol+TF Buy/Sell gate:
    // a Swing is a structure marker, not a trade signal). Filter on ConfirmedTime for the
    // incremental append, write the pivot Time() as the row time.
    CArrayObj *all_swings = m_BarTimeSeriesCollection.GetListAllSwings();
    if(all_swings != NULL && m_swing_setting != NULL)
     {
      int sw_total = all_swings.Total();
      for(int w = 0; w < sw_total; w++)
       {
        CBarSwing *sw = all_swings.At(w);
        if(sw == NULL || sw.Symbol() != sym || sw.ConfirmedTime() <= since_swing) continue;
        if(!m_swing_setting.SignalShow(sw.TypeSwing())) continue;
        ENUM_SIGNAL_DIR sdir = (sw.TypeSwing() == SWING_TYPE_LOW) ? SIGNAL_BUY : SIGNAL_SELL;
        rows.Add(new CSignalBridgeRow(sw.Time(), (int)sw.Timeframe(), sdir, 2, (int)sw.Structure())); // 2 = Swing, extra = HH/LH/HL/LL
       }
     }

    m_bridge_wm_time_indicator[wm_idx] = newest_indicator;
    m_bridge_wm_time_pattern[wm_idx]   = newest_pattern;
    m_bridge_wm_time_swing[wm_idx]     = newest_swing;
    if(do_full_rebuild)
      {       
       rows.Sort();
       AppendSignalBridgeFile(rows, sym);
       ::Print(__FUNCTION__, " > rebuilt ", rows.Total(), " signal row(s) to SignalBridge_", sym, ".dat");
       ::EventChartCustom(::ChartID(), (ushort)SIGNAL_BRIDGE_WRITER_EVENT_UPDATED, 0, 0, sym);   // raw id - MT5 itself adds CHARTEVENT_CUSTOM before delivery
      }
    else
      {
       //--- Common case (every new bar) - no file at all, each row rides straight in its own event.
       PushRowsAsEvents(rows);
       if(rows.Total() > 0)
          ::Print(__FUNCTION__, " > pushed ", rows.Total(), " signal row(s) directly for ", sym, " (no file)");
      }
   }
  bool CSignalBridgeWriter::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
   {
    //--- A Symbol+TF of another symbol never touches this chart's per-symbol bridge
    if((id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED || id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE) &&
       sparam != ::Symbol())
       return false;
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED ||
       id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED ||
       id == CHARTEVENT_CUSTOM + BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED ||
       id == CHARTEVENT_CUSTOM + SWING_SETTING_EVENT_CHANGED)
     {
      ::Print("MY DEBUG CSignalBridgeWriter::OnChartEvent: full rebuild by event=", id - CHARTEVENT_CUSTOM, " lparam=", lparam, " sparam=", sparam,
              " | ADDED=", INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED, " IND_BUYSELL=", INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED,
              " SYMTF_ADDED=", SYMBOLTF_MANAGER_EVENT_ADDED, " SYMTF_BUYSELL=", SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED,
              " PATTERN_BUYSELL=", BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED, " SWING=", SWING_SETTING_EVENT_CHANGED);
      BuildAndWriteSignalBridge(true);
      return true;
     }
    return false;
   }  
  //--- Full rewrite only now - the incremental append branch moved to PushRowsAsEvents (no file).
  void CSignalBridgeWriter::AppendSignalBridgeFile(CArrayObj &rows, const string sym)
    {
     string base_name  = "SignalBridge_" + sym;
     string final_name = this.GetFolderName() + "/" + base_name + ".dat";
     string tmp_name   = this.GetFolderName() + "/" + base_name + ".tmp";
     int fh = ::FileOpen(tmp_name, FILE_BIN|FILE_WRITE);
     if(fh == INVALID_HANDLE) return;
     int count = rows.Total();
     ::FileWriteInteger(fh, SIGNAL_BRIDGE_MAGIC, INT_VALUE);
     ::FileWriteLong(fh, (long)::TimeCurrent());
     ::FileWriteInteger(fh, count, INT_VALUE);
     for(int i = 0; i < count; i++)
       {
        CSignalBridgeRow *row = rows.At(i);
        if(row == NULL) continue;
        ::FileWriteLong(fh, (long)row.Time());
        ::FileWriteInteger(fh, row.TF(),                          INT_VALUE);
        ::FileWriteInteger(fh, (row.Dir() == SIGNAL_BUY) ? 1 : -1, INT_VALUE);
        ::FileWriteInteger(fh, row.Source(),                      INT_VALUE);
        ::FileWriteInteger(fh, row.Extra(),                       INT_VALUE);
       }
     ::FileClose(fh);
     ::FileMove(tmp_name, 0, final_name, FILE_REWRITE);
    }
  //--- Incremental path: no file at all - each row rides straight in its own CHARTEVENT_CUSTOM,
  //--- sparam packs "tf|dir|source|extra" (lparam already carries time). The indicator appends it
  //--- to its own g_rows_*[] directly - order doesn't matter, ComputeBar() linear-scans every row
  //--- per bar regardless of array order.
  void CSignalBridgeWriter::PushRowsAsEvents(CArrayObj &rows)
    {
     int count = rows.Total();
     for(int i = 0; i < count; i++)
       {
        CSignalBridgeRow *row = rows.At(i);
        if(row == NULL) continue;
        string payload = ::IntegerToString(row.TF()) + "|" +
                         ::IntegerToString((row.Dir() == SIGNAL_BUY) ? 1 : -1) + "|" +
                         ::IntegerToString(row.Source()) + "|" +
                         ::IntegerToString(row.Extra());
        ::EventChartCustom(::ChartID(), (ushort)SIGNAL_BRIDGE_ROW_EVENT, (long)row.Time(), 0, payload);   // raw id - MT5 itself adds CHARTEVENT_CUSTOM before delivery
       }
    }
 #endif // CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
#endif // __SIGNALBRIDGEWRITER_MQH__
