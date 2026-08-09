//+------------------------------------------------------------------+
//|                                           SignalBridgeWriter.mqh |
//|                                     Copyright 2026, Anhnt        |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef __SIGNALBRIDGEWRITER_MQH__
#define __SIGNALBRIDGEWRITER_MQH__

//#include "..\TradingEngine\Indicators\IndicatorDE.mqh"
#include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SignalsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Indicators\IndicatorDE.mqh>
//#include "..\TradingEngine\TimeSeriesEngine.mqh"
 #ifndef CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #define CSIGNALBRIDGEWRITER_MQH_DECLARATION
  class CSignalBridgeWriter
  {
    private:
     //Pointer from Layer 1, CTimeSeriesEngine hold      
     CSignalsCollection        *m_SignalsCollection;     // 1-1 CIndicatorDE<->CSignalXXX linkage (EA-local)     
     CIndicatorsCollection     *m_IndicatorsCollection;           //Indicator collection
     CIndicatorDE              *m_template_ptrs[];     
     CBarTimeSeriesCollection  *m_BarTimeSeriesCollection;          //Timeseries collection
    
     static string              m_bridge_folder;  // ← Static property (scoped to class)
    //Seting from CGUIPannel base on Selection on Checkbox 
     bool                       m_template_buy[];
     bool                       m_template_sell[]; 
         
     string                     m_signal_bridge_symbol;
     datetime                   m_signal_bridge_last_time;
     
     bool                       TemplateBuySellFor(CIndicatorDE *ind, bool &buy, bool &sell);
     void                       WriteSignalBridgeFile(const datetime &row_time[], const int &row_tf[], const int &row_dir[], const int &row_source[], const int count);     

    public:
     CSignalBridgeWriter(void);
    ~CSignalBridgeWriter(void);
                              
     void                       Initialize(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars);
     void                       SetTemplateBuySell(CIndicatorDE *&tmpl_ptrs[], bool &tmpl_buy[], bool &tmpl_sell[]);
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
      m_signal_bridge_symbol(""), m_signal_bridge_last_time(0)
  {
    ArrayResize(m_template_ptrs, 0);
    ArrayResize(m_template_buy, 0);
    ArrayResize(m_template_sell, 0);
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
  
  void CSignalBridgeWriter::SetTemplateBuySell(CIndicatorDE *&tmpl_ptrs[], bool &tmpl_buy[], bool &tmpl_sell[])
   {
    ArrayCopy(m_template_ptrs, tmpl_ptrs);
    ArrayCopy(m_template_buy, tmpl_buy);
    ArrayCopy(m_template_sell, tmpl_sell);
   }
  bool CSignalBridgeWriter::TemplateBuySellFor(CIndicatorDE *ind, bool &buy, bool &sell)
   {
    buy = false;
    sell = false;
    if(ind == NULL) return false;

    ENUM_INDICATOR type = ind.TypeIndicator();
    MqlParam params[];
    ind.GetMqlParams(params);

    for(int row = 0; row < ArraySize(m_template_ptrs); row++)
    {
      CIndicatorDE *row_ind = m_template_ptrs[row];
      if(row_ind == NULL || row_ind.TypeIndicator() != type) continue;

      MqlParam row_params[];
      row_ind.GetMqlParams(row_params);
      if(!IsEqualMqlParamArrays(params, row_params)) continue;

      buy  = ((int)m_template_buy[row] != 0);
      sell = ((int)m_template_sell[row] != 0);
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
       CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
       ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, s.Timeframe(), EQUAL);
       int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
       for(int ii = 0; ii < ind_total; ii++)
         {
          CIndicatorDE *ind = ind_list.At(ii);
          if(ind == NULL) continue;
          bool buy_on, sell_on;
          //if(!m_provider.TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
          if(!TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
          //CSignalBase *signal = m_engine.GetSignalsCollection().GetOrCreateSignal(ind);
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

    if(!fresh && newest_seen <= m_signal_bridge_last_time)
       return;
    m_signal_bridge_symbol = sym;

    datetime row_time[]; int row_tf[]; int row_dir[]; int row_source[];
    int count = 0;
    for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *s = series_list.At(ti);
      if(s == NULL) continue;
      ENUM_TIMEFRAMES tf = s.Timeframe();
      CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
      for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *ind = ind_list.At(ii);
         if(ind == NULL) continue;
         bool buy_on, sell_on;
         //if(!m_provider.TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
         //CSignalBase *signal = m_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(!TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
         CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
         if(signal == NULL) continue;
         int hist_total = signal.HistoryTotal();
         for(int h = 0; h < hist_total; h++)
           {
            ENUM_SIGNAL_DIR dir = signal.HistoryDir(h);
            if(dir == SIGNAL_NONE) continue;
            if(dir == SIGNAL_BUY  && !buy_on)  continue;
            if(dir == SIGNAL_SELL && !sell_on) continue;
            ArrayResize(row_time,   count + 1);
            ArrayResize(row_tf,     count + 1);
            ArrayResize(row_dir,    count + 1);
            ArrayResize(row_source, count + 1);
            row_time[count]   = signal.HistoryTime(h);
            row_tf[count]     = (int)tf;
            row_dir[count]    = (dir == SIGNAL_BUY) ? 1 : -1;
            row_source[count] = 0; // Indicator
            count++;
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
                  ArrayResize(row_time,   count + 1);
                  ArrayResize(row_tf,     count + 1);
                  ArrayResize(row_dir,    count + 1);
                  ArrayResize(row_source, count + 1);
                  row_time[count]   = bb.LineHistoryTime(li, h);
                  row_tf[count]     = (int)tf;
                  row_dir[count]    = (dir == SIGNAL_BUY) ? 1 : -1;
                  row_source[count] = 0; // Indicator
                  count++;
                 }
              }
           }
        }
     }

    // Phase 2b: Collect pattern signals (Anhnt, 2026-08-08) - same format as indicator signals
    // Only closed bars: GetListAllPatterns() returns patterns from CBarSeriesDE.AddPatterns(),
    // which only adds completed bars' patterns. Live bar 0 patterns excluded automatically.
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

        ArrayResize(row_time,   count + 1);
        ArrayResize(row_tf,     count + 1);
        ArrayResize(row_dir,    count + 1);
        ArrayResize(row_source, count + 1);
        row_time[count]   = pat.Time();
        row_tf[count]     = (int)pat.Timeframe();
        row_dir[count]    = (pdir_signal == SIGNAL_BUY) ? 1 : -1;
        row_source[count] = 1; // Pattern
        count++;
       }
     }

    for(int a = 0; a < count - 1; a++)
      for(int b = a + 1; b < count; b++)
         if(row_time[b] < row_time[a])
           {
            datetime tm_ = row_time[a]; row_time[a] = row_time[b]; row_time[b] = tm_;
            int      tf_ = row_tf[a];   row_tf[a]   = row_tf[b];   row_tf[b]   = tf_;
            int      d_  = row_dir[a];  row_dir[a]  = row_dir[b];  row_dir[b]  = d_;
            int      src_ = row_source[a]; row_source[a] = row_source[b]; row_source[b] = src_;
           }

    WriteSignalBridgeFile(row_time, row_tf, row_dir, row_source, count);
    m_signal_bridge_last_time = newest_seen;
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
  void CSignalBridgeWriter::WriteSignalBridgeFile(const datetime &row_time[], const int &row_tf[], const int &row_dir[], const int &row_source[], const int count)
    {
      string base_name   = "SignalBridge_" + m_signal_bridge_symbol;
      string final_name = (m_bridge_folder != "") ? (m_bridge_folder + "/" + base_name + ".dat") : (base_name + ".dat");
      string tmp_name   = (m_bridge_folder != "") ? (m_bridge_folder + "/" + base_name + ".tmp") : (base_name + ".tmp");
     int fh = ::FileOpen(tmp_name, FILE_BIN|FILE_WRITE);
     if(fh == INVALID_HANDLE)
        return;

     // SIGNAL_BRIDGE_MAGIC v2 (Anhnt, 2026-08-08): added source field (0=indicator, 1=pattern)
     // File format: magic(int) + update(long) + count(int) + count×{time(long), tf(int), dir(int), source(int)}
     #ifndef SIGNAL_BRIDGE_MAGIC
      #define SIGNAL_BRIDGE_MAGIC 20260808
     #endif
     ::FileWriteInteger(fh, SIGNAL_BRIDGE_MAGIC, INT_VALUE);
     ::FileWriteLong(fh, (long)::TimeCurrent());
     ::FileWriteInteger(fh, count, INT_VALUE);
     for(int i = 0; i < count; i++)
       {
         ::FileWriteLong(fh, (long)row_time[i]);
         ::FileWriteInteger(fh, row_tf[i],     INT_VALUE);
         ::FileWriteInteger(fh, row_dir[i],    INT_VALUE);
         ::FileWriteInteger(fh, row_source[i], INT_VALUE);
       }
     ::FileClose(fh);
     ::FileMove(tmp_name, 0, final_name, FILE_REWRITE);
    }
 #endif // CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
#endif // __SIGNALBRIDGEWRITER_MQH__
