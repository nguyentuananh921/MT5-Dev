//+------------------------------------------------------------------+
//|                                  TimeSeriesEngine_CandleInfo.mqh |
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_CANDLEINFO_MQH
#define CTIMESERIESENGINE_CANDLEINFO_MQH
#include "TimeSeriesEngine.mqh"
#include "..\Services\SymbolTFManager.mqh"
#include "..\Services\IndicatorTemplateManager.mqh"
 //+------------------------------------------------------------------+
 //| Indicator flips, Patterns, Swings, BOS and CHoCH of every       |
 //| timeframe of the chart's Symbol inside [bar_time, next bar of the|
 //| chart), gated by the Buy/Sell settings. Time ascending, then TF  |
 //| ascending. row_source: 0 = Indicator, 1 = Pattern, 2 = Swing,    |
 //| 3 = Market Structure. Returns the number of rows                 |
 //+------------------------------------------------------------------+
 int CTimeSeriesEngine::GetCandleInfo(const datetime bar_time, string &row_label[], string &row_tf[],
                                      ENUM_SIGNAL_DIR &row_dir[], datetime &row_time[], int &row_source[])
  {
   ::ArrayResize(row_label,  0);
   ::ArrayResize(row_tf,     0);
   ::ArrayResize(row_dir,    0);
   ::ArrayResize(row_time,   0);
   ::ArrayResize(row_source, 0);
   if(m_SymbolTFManager == NULL || m_IndicatorTemplateManager == NULL)
      return 0;
   datetime next_bar_time = bar_time + ::PeriodSeconds();
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   //--- TFs ascending M1..MN1
    int order[];
    ::ArrayResize(order, series_total);
    for(int ti = 0; ti < series_total; ti++)
      order[ti] = ti;
    for(int a = 0; a < series_total - 1; a++)
      for(int b = a + 1; b < series_total; b++)
       {
        CBarSeriesDE *sa = series_list.At(order[a]);
        CBarSeriesDE *sb = series_list.At(order[b]);
        if(sa == NULL || sb == NULL) continue;
        if(IndexEnumTimeframe(sb.Timeframe()) < IndexEnumTimeframe(sa.Timeframe()))
         { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
       }
   int count = 0;
   CArrayObj *ind_list = m_IndicatorsCollection.GetList();   // filtered inline below - no Select per mouse move
   int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
   for(int ti = 0; ti < series_total; ti++)
    {
     CBarSeriesDE *s = series_list.At(order[ti]);
     if(s == NULL) continue;
     ENUM_TIMEFRAMES tf = s.Timeframe();
     string tf_text = TimeframeDescription(tf);
     CSymbolTFSetting *symtf_entry = m_SymbolTFManager.FindByIdentity(sym, tf);
     bool symtf_buy  = (symtf_entry != NULL) ? symtf_entry.BuySignal()  : false;
     bool symtf_sell = (symtf_entry != NULL) ? symtf_entry.SellSignal() : false;
     for(int ii = 0; ii < ind_total; ii++)
      {
       CIndicatorDE *ind = ind_list.At(ii);
       if(ind == NULL || ind.Symbol() != sym || ind.Timeframe() != tf) continue;
       ENUM_INDICATOR ind_type = ind.TypeIndicator();
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       CIndicatorSetting ind_label_setting;
       ind_label_setting.TypeEnum(ind_type);
       ind_label_setting.SetRawParams(ind_params);
       CIndicatorSetting *ind_entry = m_IndicatorTemplateManager.FindByIdentity(ind_type, ind_params);
       bool ind_buy  = (ind_entry != NULL) ? ind_entry.BuySignal()  : false;
       bool ind_sell = (ind_entry != NULL) ? ind_entry.SellSignal() : false;
       CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
       if(signal == NULL) continue;
       //--- BBands rows carry the line right after the indicator name: -MB / -UB / -LB
       string row_ind_label = ind_label_setting.DisplayLabel();
       string label_upper = "", label_lower = "";
       if(ind_type == IND_BANDS)
        {
         int cut = ::StringFind(row_ind_label, "  (");
         if(cut < 0) cut = ::StringLen(row_ind_label);
         string head = ::StringSubstr(row_ind_label, 0, cut);
         string tail = ::StringSubstr(row_ind_label, cut);
         label_upper   = head + "-UB" + tail;
         label_lower   = head + "-LB" + tail;
         row_ind_label = head + "-MB" + tail;
        }
       //--- History is oldest->newest: walk back, collect every flip inside the span
       for(int h = signal.HistoryTotal() - 1; h >= 0; h--)
        {
         datetime ht = signal.HistoryTime(h);
         if(ht >= next_bar_time) continue;
         if(ht < bar_time) break;
         ENUM_SIGNAL_DIR d = signal.HistoryDir(h);
         if(d == SIGNAL_BUY  && !(ind_buy  && symtf_buy))  continue;
         if(d == SIGNAL_SELL && !(ind_sell && symtf_sell)) continue;
         ::ArrayResize(row_label,  count + 1);
         ::ArrayResize(row_tf,     count + 1);
         ::ArrayResize(row_dir,    count + 1);
         ::ArrayResize(row_time,   count + 1);
         ::ArrayResize(row_source, count + 1);
         row_label[count]  = row_ind_label;
         row_tf[count]     = tf_text;
         row_dir[count]    = d;
         row_time[count]   = ht;
         row_source[count] = 0;
         count++;
        }
       //--- BBands: Upper/Lower line crosses too; Mid is the primary signal, already collected above
       if(ind_type == IND_BANDS)
        {
         CSignalBollinger *bb = (CSignalBollinger*)signal;
         for(int li = 0; li < 2; li++)
          {
           for(int h = bb.LineHistoryTotal(li) - 1; h >= 0; h--)
            {
             datetime ht = bb.LineHistoryTime(li, h);
             if(ht >= next_bar_time) continue;
             if(ht < bar_time) break;
             ENUM_SIGNAL_DIR ld = bb.LineHistoryDir(li, h);
             if(ld == SIGNAL_BUY  && !(ind_buy  && symtf_buy))  continue;
             if(ld == SIGNAL_SELL && !(ind_sell && symtf_sell)) continue;
             ::ArrayResize(row_label,  count + 1);
             ::ArrayResize(row_tf,     count + 1);
             ::ArrayResize(row_dir,    count + 1);
             ::ArrayResize(row_time,   count + 1);
             ::ArrayResize(row_source, count + 1);
             row_label[count]  = (li == BBAND_LINE_UPPER) ? label_upper : label_lower;
             row_tf[count]     = tf_text;
             row_dir[count]    = ld;
             row_time[count]   = ht;
             row_source[count] = 0;
             count++;
            }
          }
        }
      }
    }
   //--- Candle Patterns
    CArrayObj *all_patterns = m_BarTimeSeriesCollection.GetListAllPatterns();
    int pat_total = (all_patterns != NULL) ? all_patterns.Total() : 0;
    for(int p = 0; p < pat_total; p++)
     {
      CBarPattern *pat = all_patterns.At(p);
      if(pat == NULL || pat.Symbol() != sym) continue;
      datetime pt = pat.Time();
      if(pt < bar_time || pt >= next_bar_time) continue;
      ENUM_TIMEFRAMES ptf = pat.Timeframe();
      ENUM_PATTERN_DIRECTION pdir = pat.Direction();
      ENUM_SIGNAL_DIR dir = (pdir == PATTERN_DIRECTION_BULLISH) ? SIGNAL_BUY :
                           (pdir == PATTERN_DIRECTION_BEARISH) ? SIGNAL_SELL : SIGNAL_NONE;
      if(dir == SIGNAL_NONE) continue;
      CSymbolTFSetting *pat_symtf = m_SymbolTFManager.FindByIdentity(sym, ptf);
      bool pat_symtf_buy  = (pat_symtf != NULL) ? pat_symtf.BuySignal()  : false;
      bool pat_symtf_sell = (pat_symtf != NULL) ? pat_symtf.SellSignal() : false;
      if(dir == SIGNAL_BUY  && !(m_BarPatterns_Control.PatternSignalBuy(pat.TypePattern())  && pat_symtf_buy))  continue;
      if(dir == SIGNAL_SELL && !(m_BarPatterns_Control.PatternSignalSell(pat.TypePattern()) && pat_symtf_sell)) continue;
      uint candles = pat.Candles();
      string pat_name = pat.GetProperty(PATTERN_PROP_NAME);
      if(pat_name == "") pat_name = ::EnumToString(pat.TypePattern());
      ::ArrayResize(row_label,  count + 1);
      ::ArrayResize(row_tf,     count + 1);
      ::ArrayResize(row_dir,    count + 1);
      ::ArrayResize(row_time,   count + 1);
      ::ArrayResize(row_source, count + 1);
      row_label[count]  = ((candles > 0) ? "[" + ::IntegerToString(candles) + "B] " : "") + pat_name;
      row_tf[count]     = TimeframeDescription(ptf);
      row_dir[count]    = dir;
      row_time[count]   = pt;
      row_source[count] = 1;
      count++;
     }
   //--- Swings whose pivot bar is in the span
    CArrayObj *all_swings = m_BarTimeSeriesCollection.GetListAllSwings();
    int sw_total = (all_swings != NULL) ? all_swings.Total() : 0;
    for(int w = 0; w < sw_total; w++)
     {
      CBarSwingSeries *sw = all_swings.At(w);
      if(sw == NULL || sw.Symbol() != sym) continue;
      datetime st = sw.Time();
      if(st < bar_time || st >= next_bar_time) continue;
      if(!m_SwingSetting.SignalShow(sw.TypeSwing())) continue;
      ::ArrayResize(row_label,  count + 1);
      ::ArrayResize(row_tf,     count + 1);
      ::ArrayResize(row_dir,    count + 1);
      ::ArrayResize(row_time,   count + 1);
      ::ArrayResize(row_source, count + 1);
      int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      row_label[count]  = SwingTypeDescription(sw.TypeSwing()) + " (" + SwingStructureDescription(sw.Structure()) + ") " + DoubleToString(sw.Price(), digits);
      row_tf[count]     = TimeframeDescription(sw.Timeframe());
      row_dir[count]    = (sw.TypeSwing() == SWING_TYPE_LOW) ? SIGNAL_BUY : SIGNAL_SELL;
      row_time[count]   = st;
      row_source[count] = 2;
      count++;
     }
   //--- BOS / CHoCH whose break candle is in the span
    CArrayObj *all_structures = m_BarTimeSeriesCollection.GetListAllMarketStructures();
    int ms_total = (all_structures != NULL) ? all_structures.Total() : 0;
    for(int w = 0; w < ms_total; w++)
     {
      CMarketStructureSeries *ms = all_structures.At(w);
      if(ms == NULL || ms.Symbol() != sym) continue;
      datetime mt = ms.Time();
      if(mt < bar_time || mt >= next_bar_time) continue;
      ::ArrayResize(row_label,  count + 1);
      ::ArrayResize(row_tf,     count + 1);
      ::ArrayResize(row_dir,    count + 1);
      ::ArrayResize(row_time,   count + 1);
      ::ArrayResize(row_source, count + 1);
      int ms_digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      row_label[count]  = (ms.TypeStructure() == MARKET_STRUCTURE_BOS ? "BOS" : "CHoCH") + (ms.Direction() == SIGNAL_BUY ? " (up) " : " (down) ") + DoubleToString(ms.Level(), ms_digits);
      row_tf[count]     = TimeframeDescription(ms.Timeframe());
      row_dir[count]    = ms.Direction();
      row_time[count]   = mt;
      row_source[count] = 3;
      count++;
     }
   //--- Time ascending, then TF ascending
   for(int a = 0; a < count - 1; a++)
      for(int b = a + 1; b < count; b++)
       {
        bool need_swap = (row_time[b] < row_time[a]) ||
                         (row_time[b] == row_time[a] &&
                          IndexEnumTimeframe(TimestampByDescription(row_tf[b])) < IndexEnumTimeframe(TimestampByDescription(row_tf[a])));
        if(!need_swap) continue;
        string          lbl_ = row_label[a];  row_label[a]  = row_label[b];  row_label[b]  = lbl_;
        string          tf_  = row_tf[a];     row_tf[a]     = row_tf[b];     row_tf[b]     = tf_;
        ENUM_SIGNAL_DIR d_   = row_dir[a];    row_dir[a]    = row_dir[b];    row_dir[b]    = d_;
        datetime        tm_  = row_time[a];   row_time[a]   = row_time[b];   row_time[b]   = tm_;
        int             src_ = row_source[a]; row_source[a] = row_source[b]; row_source[b] = src_;
       }
   ::ArrayResize(row_label,  count);
   ::ArrayResize(row_tf,     count);
   ::ArrayResize(row_dir,    count);
   ::ArrayResize(row_time,   count);
   ::ArrayResize(row_source, count);
   return count;
  }
#endif // CTIMESERIESENGINE_CANDLEINFO_MQH
