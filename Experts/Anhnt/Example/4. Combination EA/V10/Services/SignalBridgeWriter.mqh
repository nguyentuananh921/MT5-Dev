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
#include "SignalBridgeRow.mqh"            // CSignalBridgeRow - 1 output row, held in a CArrayObj 

// SIGNAL_BRIDGE_MAGIC v2 (Anhnt, 2026-08-08): added source field (0=indicator, 1=pattern)
// File format: magic(int) + update(long) + count(int) + count×{time(long), tf(int), dir(int), source(int)}
#ifndef SIGNAL_BRIDGE_MAGIC
 #define SIGNAL_BRIDGE_MAGIC 20260808
#endif

 #ifndef CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #define CSIGNALBRIDGEWRITER_MQH_DECLARATION
  class CSignalBridgeWriter
  {
    private:
     //Pointer from Layer 1, CTimeSeriesEngine hold
      CSignalsCollection        *m_SignalsCollection;              // 1-1 CIndicatorDE<->CSignalXXX linkage (EA-local)
      CIndicatorsCollection     *m_IndicatorsCollection;           //Indicator collection
      CBarTimeSeriesCollection  *m_BarTimeSeriesCollection;        //Timeseries collection         
      CIndicatorTemplateManager *m_indicator_template_manager;
      CSymbolTFManager          *m_symbol_tf_manager;     
      CBarPatternsControl        *m_patterns_control;

     // Per-Symbol watermark was 2 scalars (m_signal_bridge_symbol/m_signal_bridge_last_time), 
     // so switching the active chart between 2+ already-tracked Symbols made EVERY switch look 
     // "fresh" for whichever Symbol wasn't the last one written, forcing a full unconditional 
     // rewrite even though nothing about that Symbol's own signal history had changed. Parallel 
     // arrays let each Symbol keep its own watermark.
      string                     m_bridge_wm_symbol[];
      datetime                   m_bridge_wm_time[];
     int                        FindWatermarkIndex(const string sym);
     bool                       GetIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &raw_params[], bool &buy, bool &sell);
     bool                       GetSymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf, bool &buy, bool &sell);
     bool                       GetCandlePatternSetting(const ENUM_PATTERN_TYPE type, bool &buy, bool &sell);
     void                       AppendSignalBridgeFile(CArrayObj &rows, const string sym, const bool full_rebuild);

    public:
     CSignalBridgeWriter(void);
    ~CSignalBridgeWriter(void);

     void                       OnInitEvent(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars,
                                            CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr, CBarPatternsControl *patterns_ctrl);
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
      m_indicator_template_manager(NULL), m_symbol_tf_manager(NULL), m_patterns_control(NULL)
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
                                        CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr, CBarPatternsControl *patterns_ctrl)
   {
    m_SignalsCollection = signals;
    m_IndicatorsCollection = ind;
    m_BarTimeSeriesCollection = bars;
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
  void CSignalBridgeWriter::BuildAndWriteSignalBridge(const bool force_full_rebuild)
   {
    if(m_SignalsCollection == NULL || m_IndicatorsCollection == NULL || m_BarTimeSeriesCollection == NULL)
      return;
    string sym = ::Symbol();
    int wm_idx = FindWatermarkIndex(sym);
    bool fresh = (wm_idx < 0);
    datetime prev_watermark = fresh ? 0 : m_bridge_wm_time[wm_idx];

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

    if(!fresh && !force_full_rebuild && newest_seen <= prev_watermark)
       return;
    if(fresh)
     {
      wm_idx = ::ArraySize(m_bridge_wm_symbol);
      ::ArrayResize(m_bridge_wm_symbol, wm_idx + 1);
      ::ArrayResize(m_bridge_wm_time, wm_idx + 1);
      m_bridge_wm_symbol[wm_idx] = sym;
     }
    bool do_full_rebuild = fresh || force_full_rebuild;
    datetime since_time = do_full_rebuild ? 0 : prev_watermark;

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
            datetime h_time = signal.HistoryTime(h);
            if(h_time <= since_time) continue;
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
                  if(lh_time <= since_time) continue;
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
        if(pat == NULL || pat.Symbol() != sym || pat.Time() <= since_time) continue;

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
    
    rows.Sort();
    AppendSignalBridgeFile(rows, sym, do_full_rebuild);
    m_bridge_wm_time[wm_idx] = newest_seen;
    ::Print(__FUNCTION__, do_full_rebuild ? " > rebuilt " : " > appended ", rows.Total(),
            " signal row(s) to SignalBridge_", sym, ".dat");
   }  
  bool CSignalBridgeWriter::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
   {
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED ||
       id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED ||
       id == CHARTEVENT_CUSTOM + BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED)
     {
      BuildAndWriteSignalBridge(true);
      return true;
     }
    return false;
   }  
  void CSignalBridgeWriter::AppendSignalBridgeFile(CArrayObj &rows, const string sym, const bool full_rebuild)
    {
     string base_name  = "SignalBridge_" + sym;
     string final_name = (g_ea_folder != "") ? (g_ea_folder + "/" + base_name + ".dat") : (base_name + ".dat");

     if(full_rebuild)
      {
       string tmp_name = (g_ea_folder != "") ? (g_ea_folder + "/" + base_name + ".tmp") : (base_name + ".tmp");
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
         }
       ::FileClose(fh);
       ::FileMove(tmp_name, 0, final_name, FILE_REWRITE);
       return;
      }

     int count_to_add = rows.Total();
     if(count_to_add == 0) return;
     int fh = ::FileOpen(final_name, FILE_BIN|FILE_READ|FILE_WRITE);
     if(fh == INVALID_HANDLE) { AppendSignalBridgeFile(rows, sym, true); return; }
     int magic = ::FileReadInteger(fh, INT_VALUE);
     if(magic != SIGNAL_BRIDGE_MAGIC) { ::FileClose(fh); AppendSignalBridgeFile(rows, sym, true); return; }
     ::FileReadLong(fh);                              // old update-time, unused
     int old_count = ::FileReadInteger(fh, INT_VALUE);
     ::FileSeek(fh, 0, SEEK_END);
     for(int i = 0; i < count_to_add; i++)
       {
        CSignalBridgeRow *row = rows.At(i);
        if(row == NULL) continue;
        ::FileWriteLong(fh, (long)row.Time());
        ::FileWriteInteger(fh, row.TF(),                          INT_VALUE);
        ::FileWriteInteger(fh, (row.Dir() == SIGNAL_BUY) ? 1 : -1, INT_VALUE);
        ::FileWriteInteger(fh, row.Source(),                      INT_VALUE);
       }
    //--- Patch the header in place - same 3 fields the full_rebuild branch writes, at offset 0.
     ::FileSeek(fh, 0, SEEK_SET);
     ::FileWriteInteger(fh, SIGNAL_BRIDGE_MAGIC, INT_VALUE);
     ::FileWriteLong(fh, (long)::TimeCurrent());
     ::FileWriteInteger(fh, old_count + count_to_add, INT_VALUE);
     ::FileClose(fh);
    }
 #endif // CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
#endif // __SIGNALBRIDGEWRITER_MQH__
