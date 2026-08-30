//+------------------------------------------------------------------+
//|                                           SignalBridgeWriter.mqh |
//|                                     Copyright 2026, Anhnt        |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef __SIGNALBRIDGEWRITER_MQH__
#define __SIGNALBRIDGEWRITER_MQH__

#include <Arrays\ArrayObj.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SignalsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Indicators\IndicatorDE.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>
#include "IndicatorTemplateManager.mqh"   // CIndicatorTemplateManager - EA-owned, read LIVE (no copy needed)
#include "SymbolTFManager.mqh"            // CSymbolTFManager - EA-owned, read LIVE (no copy needed)
#include "SignalBridgeRow.mqh"            // CSignalBridgeRow - 1 output row, held in a CArrayObj (Anhnt, 2026-08-29)
 #ifndef CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #define CSIGNALBRIDGEWRITER_MQH_DECLARATION
  class CSignalBridgeWriter
  {
    private:
     //Pointer from Layer 1, CTimeSeriesEngine hold
     CSignalsCollection        *m_SignalsCollection;     // 1-1 CIndicatorDE<->CSignalXXX linkage (EA-local)
     CIndicatorsCollection     *m_IndicatorsCollection;           //Indicator collection
     CBarTimeSeriesCollection  *m_BarTimeSeriesCollection;          //Timeseries collection

     // --- Both EA-owned Service-layer Managers (not GUI) - safe to hold LIVE pointers, any
     // --- change the user makes is visible here immediately, no copy/event plumbing needed
     // --- (Anhnt, 2026-08-26).
     CIndicatorTemplateManager *m_indicator_template_manager;
     CSymbolTFManager          *m_symbol_tf_manager;

     // --- Candle Pattern Buy/Sell now lives on CBarPatternControl itself (same registry
     // --- CGUIPannel borrows via SetPatternsControl()) - read LIVE, same as the 2 Managers
     // --- above, no more EA-pushed snapshot (Anhnt, 2026-08-29).
     CBarPatternsControl        *m_patterns_control;

     static string              m_bridge_folder;  // ← Static property (scoped to class)

     string                     m_signal_bridge_symbol;
     datetime                   m_signal_bridge_last_time;

     // --- Identity-only (type, raw_params) - no live CIndicatorDE* needed, matches the RAW-match
     // --- convention already established across the codebase (SynIndicatorPlan.md).
     bool                       GetIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &raw_params[], bool &buy, bool &sell);
     bool                       GetSymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf, bool &buy, bool &sell);
     bool                       GetCandlePatternSetting(const ENUM_PATTERN_TYPE type, bool &buy, bool &sell);
     void                       WriteSignalBridgeFile(CArrayObj &rows);

    public:
     CSignalBridgeWriter(void);
    ~CSignalBridgeWriter(void);

     void                       Initialize(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars);
     void                       SetManagers(CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr, CBarPatternsControl *patterns_ctrl);
     void                       BuildAndWriteSignalBridge(void);
     void                       ResetSignalBridge(void);
     static void                SetFolder(const string folder) { m_bridge_folder = folder; }
  };
 #endif // CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #ifndef CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
 #define CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  string CSignalBridgeWriter::m_bridge_folder = "";
  CSignalBridgeWriter::CSignalBridgeWriter(void)
    : m_SignalsCollection(NULL), m_IndicatorsCollection(NULL), m_BarTimeSeriesCollection(NULL),
      m_indicator_template_manager(NULL), m_symbol_tf_manager(NULL), m_patterns_control(NULL),
      m_signal_bridge_symbol(""), m_signal_bridge_last_time(0)
  {
  }

  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CSignalBridgeWriter::~CSignalBridgeWriter(void)
   {
   }

  //+------------------------------------------------------------------+
  //| Initialize                                                       |
  //+------------------------------------------------------------------+
  void CSignalBridgeWriter::Initialize(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars)
   {
    m_SignalsCollection = signals;
    m_IndicatorsCollection = ind;
    m_BarTimeSeriesCollection = bars;
   }
  //+------------------------------------------------------------------+
  //| SetManagers                                                      |
  //+------------------------------------------------------------------+
  void CSignalBridgeWriter::SetManagers(CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr, CBarPatternsControl *patterns_ctrl)
   {
    m_indicator_template_manager = tmpl_mgr;
    m_symbol_tf_manager = symtf_mgr;
    m_patterns_control = patterns_ctrl;
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
  void CSignalBridgeWriter::BuildAndWriteSignalBridge(void)
   {
    if(m_SignalsCollection == NULL || m_IndicatorsCollection == NULL || m_BarTimeSeriesCollection == NULL)
      return;
    string sym = ::Symbol();
    bool fresh = (sym != m_signal_bridge_symbol);

    CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
    CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
    int series_total = (series_list != NULL) ? series_list.Total() : 0;

    datetime newest_seen = 0;
    for(int ti = 0; ti < series_total; ti++)
      {
       CBarSeriesDE *s = series_list.At(ti);
       if(s == NULL) continue;
       bool symtf_buy_wm, symtf_sell_wm;
       GetSymbolTFSetting(sym, s.Timeframe(), symtf_buy_wm, symtf_sell_wm);
       CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
       ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, s.Timeframe(), EQUAL);
       int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
       for(int ii = 0; ii < ind_total; ii++)
         {
          CIndicatorDE *ind = ind_list.At(ii);
          if(ind == NULL) continue;
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
            if(t > newest_seen) newest_seen = t;
           }
          if(ind.TypeIndicator() == IND_BANDS)
           {
            CSignalBollinger *bb = (CSignalBollinger*)signal;
            for(int li = 0; li < 3; li++)
              {
               int lt = bb.LineHistoryTotal(li);
               if(lt == 0) continue;
               datetime lts = bb.LineHistoryTime(li, lt - 1);
               if(lts > newest_seen) newest_seen = lts;
              }
           }
         }
      }

    // Fix (2026-08-10): newest_seen above only scanned indicator/BBand signal history, so a
    // NEW PATTERN with no accompanying new indicator signal never advanced the watermark - the
    // early-return below then skipped writing the bridge, and the pattern marker only showed up
    // after a re-attach reset m_signal_bridge_symbol (forcing fresh=true). Patterns must also
    // count toward newest_seen. See FeatureNote/UpdateCandlePattern.md.
    CArrayObj *all_patterns_wm = m_BarTimeSeriesCollection.GetListAllPatterns();
    if(all_patterns_wm != NULL)
     {
      int pat_total_wm = all_patterns_wm.Total();
      for(int p = 0; p < pat_total_wm; p++)
       {
        CBarPattern *pat_wm = all_patterns_wm.At(p);
        if(pat_wm == NULL || pat_wm.Symbol() != sym) continue;
        datetime pt = pat_wm.Time();
        if(pt > newest_seen) newest_seen = pt;
       }
     }

    if(!fresh && newest_seen <= m_signal_bridge_last_time)
       return;
    m_signal_bridge_symbol = sym;

    CArrayObj rows;
    rows.FreeMode(true); // owns the CSignalBridgeRow* it holds - deleted when rows goes out of scope
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
         int hist_total = signal.HistoryTotal();
         for(int h = 0; h < hist_total; h++)
           {
            ENUM_SIGNAL_DIR dir = signal.HistoryDir(h);
            if(dir == SIGNAL_NONE) continue;
            if(dir == SIGNAL_BUY  && !buy_on)  continue;
            if(dir == SIGNAL_SELL && !sell_on) continue;
            rows.Add(new CSignalBridgeRow(signal.HistoryTime(h), (int)tf, dir, 0)); // 0 = Indicator
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
                  ENUM_SIGNAL_DIR dir = bb.LineHistoryDir(li, h);
                  if(dir == SIGNAL_NONE) continue;
                  if(dir == SIGNAL_BUY  && !buy_on)  continue;
                  if(dir == SIGNAL_SELL && !sell_on) continue;
                  rows.Add(new CSignalBridgeRow(bb.LineHistoryTime(li, h), (int)tf, dir, 0)); // 0 = Indicator
                 }
              }
           }
        }
     }

    // Phase 2b: Collect pattern signals (Anhnt, 2026-08-08) - same format as indicator signals
    // Only closed bars: GetListAllPatterns() returns patterns from CBarSeriesDE.AddPatterns(),
    // which only adds completed bars' patterns. Live bar 0 patterns excluded automatically.
    // Phase 2c (Anhnt, 2026-08-26): now gated the same 2-layer way as Indicator signals -
    // SymbolTF(sym,pat.Timeframe()) AND GetCandlePatternSetting(pat.TypePattern()), both must allow
    // the signal's own direction.
    CArrayObj *all_patterns = m_BarTimeSeriesCollection.GetListAllPatterns();
    if(all_patterns != NULL)
     {
      int pat_total = all_patterns.Total();
      for(int p = 0; p < pat_total; p++)
       {
        CBarPattern *pat = all_patterns.At(p);
        if(pat == NULL || pat.Symbol() != sym) continue;

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

    // --- Was a hand-rolled O(n^2) bubble sort over 4 parallel arrays - with thousands of
    // --- accumulated historical rows (and ResetSignalBridge() forcing a FULL rebuild on every
    // --- single Buy/Sell/Show toggle in the Symbol+TF/Indicator/Candle Pattern tabs), that was
    // --- millions of comparisons run synchronously on the UI thread - the real cause of the
    // --- EA freezing solid on any settings change. CArrayObj::Sort() uses CSignalBridgeRow's own
    // --- Compare() (quicksort, O(n log n)) instead (Anhnt, 2026-08-29).
    rows.Sort();

    WriteSignalBridgeFile(rows);
    m_signal_bridge_last_time = newest_seen;
    // --- Rebuild is only slow enough to notice right after a Buy/Sell/Show toggle - this
    // --- confirms in the Experts log exactly when the new bridge file is ready, so the user
    // --- isn't left guessing whether SignalMarkers has caught up yet (Anhnt, 2026-08-29).
    ::Print(__FUNCTION__, " > wrote ", rows.Total(), " signal row(s) to SignalBridge_", sym, ".dat");
   }

  //+------------------------------------------------------------------+
  //| ResetSignalBridge                                                |
  //+------------------------------------------------------------------+
  void CSignalBridgeWriter::ResetSignalBridge(void)
    {
     m_signal_bridge_last_time = 0;
     BuildAndWriteSignalBridge();
    }
  //+------------------------------------------------------------------+
  //| WriteSignalBridgeFile                                            |
  //+------------------------------------------------------------------+
  void CSignalBridgeWriter::WriteSignalBridgeFile(CArrayObj &rows)
    {
      string base_name   = "SignalBridge_" + m_signal_bridge_symbol;
      string final_name = (m_bridge_folder != "") ? (m_bridge_folder + "/" + base_name + ".dat") : (base_name + ".dat");
      string tmp_name   = (m_bridge_folder != "") ? (m_bridge_folder + "/" + base_name + ".tmp") : (base_name + ".tmp");
     int fh = ::FileOpen(tmp_name, FILE_BIN|FILE_WRITE);
     if(fh == INVALID_HANDLE)
        return;

     // SIGNAL_BRIDGE_MAGIC v2 (Anhnt, 2026-08-08): added source field (0=indicator, 1=pattern)
     // File format: magic(int) + update(long) + count(int) + count×{time(long), tf(int), dir(int), source(int)}
     // - unchanged by the CArrayObj refactor (Anhnt, 2026-08-29), only the in-memory build path did.
     #ifndef SIGNAL_BRIDGE_MAGIC
      #define SIGNAL_BRIDGE_MAGIC 20260808
     #endif
     int count = rows.Total();
     ::FileWriteInteger(fh, SIGNAL_BRIDGE_MAGIC, INT_VALUE);
     ::FileWriteLong(fh, (long)::TimeCurrent());
     ::FileWriteInteger(fh, count, INT_VALUE);
     for(int i = 0; i < count; i++)
       {
         CSignalBridgeRow *row = rows.At(i);
         if(row == NULL) continue;
         ::FileWriteLong(fh, (long)row.Time());
         ::FileWriteInteger(fh, row.TF(),                             INT_VALUE);
         ::FileWriteInteger(fh, (row.Dir() == SIGNAL_BUY) ? 1 : -1,    INT_VALUE);
         ::FileWriteInteger(fh, row.Source(),                         INT_VALUE);
       }
     ::FileClose(fh);
     ::FileMove(tmp_name, 0, final_name, FILE_REWRITE);
    }
 #endif // CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
#endif // __SIGNALBRIDGEWRITER_MQH__
