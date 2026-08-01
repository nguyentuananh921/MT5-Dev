//+------------------------------------------------------------------+
//|                                           SignalBridgeWriter.mqh |
//|                                     Copyright 2026, Anhnt        |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef __SIGNALBRIDGEWRITER_MQH__
#define __SIGNALBRIDGEWRITER_MQH__

#include "..\TradingEngine\Indicators\IndicatorDE.mqh"
#include "..\TradingEngine\TimeSeriesEngine.mqh"
 #ifndef CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #define CSIGNALBRIDGEWRITER_MQH_DECLARATION
  class ITemplateBuySellProvider
   {
    public:
     virtual bool      TemplateBuySellFor(CIndicatorDE *ind, bool &buy, bool &sell) = 0;
   };

  class CSignalBridgeWriter
  {
    private:
     ITemplateBuySellProvider   *m_provider;
     CTimeSeriesEngine          *m_engine;
     CIndicatorsCollection      *m_indicators;
     CBarTimeSeriesCollection   *m_bars;
   
     string                     m_signal_bridge_symbol;
     datetime                   m_signal_bridge_last_time;

     void                       WriteSignalBridgeFile(const datetime &row_time[], const int &row_tf[], const int &row_dir[], const int count);

    public:
     CSignalBridgeWriter(void);
    ~CSignalBridgeWriter(void);
                              
     void                       Initialize(ITemplateBuySellProvider *provider, CTimeSeriesEngine *engine, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars);
     void                       BuildAndWriteSignalBridge(void);
     void                       ResetSignalBridge(void);
  };
 #endif // CSIGNALBRIDGEWRITER_MQH_DECLARATION
 #ifndef CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
 #define CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CSignalBridgeWriter::CSignalBridgeWriter(void)
   : m_provider(NULL), m_engine(NULL), m_indicators(NULL), m_bars(NULL),
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
  CSignalBridgeWriter::Initialize(ITemplateBuySellProvider *provider, CTimeSeriesEngine *engine, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars)
   {
    m_provider = provider;
    m_engine = engine;
    m_indicators = ind;
    m_bars = bars;
   }

  //+------------------------------------------------------------------+
  //| BuildAndWriteSignalBridge                                        |
  //+------------------------------------------------------------------+
  CSignalBridgeWriter::BuildAndWriteSignalBridge(void)
   {
    if(m_engine == NULL || m_indicators == NULL || m_bars == NULL || m_provider == NULL)
       return;

    string sym = ::Symbol();
    bool fresh = (sym != m_signal_bridge_symbol);

    CBarTimeSeriesDE *bts = m_bars.GetTimeseries(sym);
    CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
    int series_total = (series_list != NULL) ? series_list.Total() : 0;

    datetime newest_seen = 0;
    for(int ti = 0; ti < series_total; ti++)
      {
       CBarSeriesDE *s = series_list.At(ti);
       if(s == NULL) continue;
       CArrayObj *ind_list = m_indicators.GetListIndBySymbol(sym);
       ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, s.Timeframe(), EQUAL);
       int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
       for(int ii = 0; ii < ind_total; ii++)
         {
          CIndicatorDE *ind = ind_list.At(ii);
          if(ind == NULL) continue;
          bool buy_on, sell_on;
          if(!m_provider.TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
          CSignalBase *signal = m_engine.GetSignalsCollection().GetOrCreateSignal(ind);
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

    datetime row_time[]; int row_tf[]; int row_dir[];
    int count = 0;
    for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *s = series_list.At(ti);
      if(s == NULL) continue;
      ENUM_TIMEFRAMES tf = s.Timeframe();
      CArrayObj *ind_list = m_indicators.GetListIndBySymbol(sym);
      ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
      for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *ind = ind_list.At(ii);
         if(ind == NULL) continue;
         bool buy_on, sell_on;
         if(!m_provider.TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
         CSignalBase *signal = m_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(signal == NULL) continue;
         int hist_total = signal.HistoryTotal();
         for(int h = 0; h < hist_total; h++)
           {
            ENUM_SIGNAL_DIR dir = signal.HistoryDir(h);
            if(dir == SIGNAL_NONE) continue;
            if(dir == SIGNAL_BUY  && !buy_on)  continue;
            if(dir == SIGNAL_SELL && !sell_on) continue;
            ArrayResize(row_time, count + 1);
            ArrayResize(row_tf,   count + 1);
            ArrayResize(row_dir,  count + 1);
            row_time[count] = signal.HistoryTime(h);
            row_tf[count]   = (int)tf;
            row_dir[count]  = (dir == SIGNAL_BUY) ? 1 : -1;
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
                  ArrayResize(row_time, count + 1);
                  ArrayResize(row_tf,   count + 1);
                  ArrayResize(row_dir,  count + 1);
                  row_time[count] = bb.LineHistoryTime(li, h);
                  row_tf[count]   = (int)tf;
                  row_dir[count]  = (dir == SIGNAL_BUY) ? 1 : -1;
                  count++;
                 }
              }
           }
        }
     }

    for(int a = 0; a < count - 1; a++)
      for(int b = a + 1; b < count; b++)
         if(row_time[b] < row_time[a])
           {
            datetime tm_ = row_time[a]; row_time[a] = row_time[b]; row_time[b] = tm_;
            int      tf_ = row_tf[a];   row_tf[a]   = row_tf[b];   row_tf[b]   = tf_;
            int      d_  = row_dir[a];  row_dir[a]  = row_dir[b];  row_dir[b]  = d_;
           }

    WriteSignalBridgeFile(row_time, row_tf, row_dir, count);
    m_signal_bridge_last_time = newest_seen;
   }

  //+------------------------------------------------------------------+
  //| ResetSignalBridge                                                |
  //+------------------------------------------------------------------+
  CSignalBridgeWriter::ResetSignalBridge(void)
    {
     m_signal_bridge_last_time = 0;
     BuildAndWriteSignalBridge();
    }
  //+------------------------------------------------------------------+
  //| WriteSignalBridgeFile                                            |
  //+------------------------------------------------------------------+
  CSignalBridgeWriter::WriteSignalBridgeFile(const datetime &row_time[], const int &row_tf[], const int &row_dir[], const int count)
    {
     string final_name = "SignalBridge_" + m_signal_bridge_symbol + ".dat";
     string tmp_name    = "SignalBridge_" + m_signal_bridge_symbol + ".tmp";

     int fh = ::FileOpen(tmp_name, FILE_BIN|FILE_WRITE);
     if(fh == INVALID_HANDLE)
        return;

     // SIGNAL_BRIDGE_MAGIC is defined in SignalMarkers.mq5, we should define it here
     #define SIGNAL_BRIDGE_MAGIC 0x51674E79
     ::FileWriteInteger(fh, SIGNAL_BRIDGE_MAGIC, INT_VALUE);
     ::FileWriteLong(fh, (long)::TimeCurrent());
     ::FileWriteInteger(fh, count, INT_VALUE);
     for(int i = 0; i < count; i++)
       {
         ::FileWriteLong(fh, (long)row_time[i]);
      ::FileWriteInteger(fh, row_tf[i],  INT_VALUE);
      ::FileWriteInteger(fh, row_dir[i], INT_VALUE);
     }
   ::FileClose(fh);
   ::FileMove(tmp_name, 0, final_name, FILE_REWRITE);
  }
 #endif // CSIGNALBRIDGEWRITER_MQH_IMPLEMENTATION
#endif // __SIGNALBRIDGEWRITER_MQH__
