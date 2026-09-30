//+------------------------------------------------------------------+
//|                           GUIPannel_SoundAndMessageAlerts.mqh    |
//| Sound / Message / CSV alerts for Indicator, Pattern and Swing     |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
#define CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
 #include "GUIPannel.mqh" 
 //--- Native ::PlaySound resolves a bare file name against TERMINAL_PATH\Sounds\ only
 void CGUIPannel::PlaySoundForDirection(const bool is_buy)
  {
   if(is_buy ? !m_buy_sound_enabled : !m_sell_sound_enabled) return;
   string file = is_buy ? m_marker_buy_sound_file : m_marker_sell_sound_file;
   if(file == "") return;
   ::PlaySound(file);
  }
 //+------------------------------------------------------------------+
 //| Indicator alerts: closed-bar catch-up (watermark) + live bar 0   |
 //+------------------------------------------------------------------+
 void CGUIPannel::CheckIndicatorAlerts(void)
  {
   if(m_SignalsCollection == NULL || m_BarTimeSeriesCollection == NULL || m_IndicatorsCollection == NULL ||
      m_indicator_template_manager == NULL || m_SymbolTFManager == NULL) return;
   int rows = m_indicator_template_manager.Total();
   if(rows == 0) return;
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   if(series_total == 0) return;
   int total_slots = series_total * rows;
   bool seeding = (::ArraySize(m_live_signal_last_seen) != total_slots);   // TF/row grid changed shape: seed, don't fire
   if(seeding)
    {
     ::ArrayResize(m_live_signal_last_seen, total_slots);
     ::ArrayResize(m_upper_last_seen, total_slots);
     ::ArrayResize(m_lower_last_seen, total_slots);
    }
   CArrayObj *ind_list = m_IndicatorsCollection.GetList();   // filtered inline below - no Select per tick
   int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
   int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
   for(int ti = 0; ti < series_total; ti++)
    {
     CBarSeriesDE *s = series_list.At(ti);
     if(s == NULL) continue;
     ENUM_TIMEFRAMES tf = s.Timeframe();
     string tf_text = TimeframeDescription(tf);
     CSymbolTFSetting *symtf_entry = m_SymbolTFManager.FindByIdentity(sym, tf);
     bool symtf_buy  = (symtf_entry != NULL) ? symtf_entry.BuySignal()  : false;
     bool symtf_sell = (symtf_entry != NULL) ? symtf_entry.SellSignal() : false;
     for(int row = 0; row < rows; row++)
      {
       CIndicatorSetting *entry = m_indicator_template_manager.At(row);
       if(entry == NULL) continue;
       bool sound_on   = entry.SoundAlert();
       bool message_on = entry.MessageAlert();
       if(!sound_on && !message_on) continue;
       MqlParam raw_params[];
       entry.GetRawParams(raw_params);
       if(::ArraySize(raw_params) == 0) continue;
       //--- This TF's own instance of the template row (RAW identity)
       CIndicatorDE *ind = NULL;
       for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *cand = ind_list.At(ii);
         if(cand == NULL || cand.Symbol() != sym || cand.Timeframe() != tf || cand.TypeIndicator() != entry.TypeEnum()) continue;
         MqlParam cand_params[];
         cand.GetMqlParams(cand_params);
         if(IsEqualMqlParamArrays(cand_params, raw_params)) { ind = cand; break; }
        }
       if(ind == NULL) continue;
       CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
       if(signal == NULL) continue;   // no CSignalXxx wired for this type yet
       int index = ti * rows + row;
       string label = entry.DisplayLabel();
       string type_key = ::EnumToString(entry.TypeEnum());
       string wm_params_key = label + "|" + tf_text;   // TF-qualified: each TF keeps its own watermark
       //--- BBands Upper/Lower line crosses; Mid is the primary signal handled below
       if(message_on && ind.TypeIndicator() == IND_BANDS)
        {
         CSignalBollinger *bb = (CSignalBollinger*)signal;
         ProcessBandLine(index, bb, BBAND_LINE_UPPER, "Upper", m_upper_last_seen, seeding, type_key, wm_params_key,
                         label, tf_text, digits, entry.BuySignal(), entry.SellSignal(), symtf_buy, symtf_sell);
         ProcessBandLine(index, bb, BBAND_LINE_LOWER, "Lower", m_lower_last_seen, seeding, type_key, wm_params_key,
                         label, tf_text, digits, entry.BuySignal(), entry.SellSignal(), symtf_buy, symtf_sell);
        }
       //--- Closed bars: every committed flip newer than the watermark
       datetime wm = m_signal_logger.GetSignalLogWatermark(type_key, wm_params_key);
       int total = signal.HistoryTotal();
       if(wm == 0)
        {
         //--- Never watermarked: seed silently to the newest flip, no history replay
         datetime seed = 0;
         for(int idx = 0; idx < total; idx++)
           {
            datetime t = signal.HistoryTime(idx);
            if(t > seed) seed = t;
           }
         if(seed == 0) seed = ::TimeCurrent();
         m_signal_logger.SetSignalLogWatermark(type_key, wm_params_key, seed);
        }
       else
        {
         datetime newest_committed = wm;
         for(int idx = 0; idx < total; idx++)
          {
           datetime t = signal.HistoryTime(idx);
           if(t <= wm) continue;
           if(t > newest_committed) newest_committed = t;   // advances even past gated flips
           ENUM_SIGNAL_DIR hdir = signal.HistoryDir(idx);
           if(hdir == SIGNAL_NONE) continue;
           if(hdir == SIGNAL_BUY  && !(entry.BuySignal()  && symtf_buy))  continue;
           if(hdir == SIGNAL_SELL && !(entry.SellSignal() && symtf_sell)) continue;
           bool cb_is_buy = (hdir == SIGNAL_BUY);
           string dir_text = cb_is_buy ? "Buy" : "Sell";
           string cross_text = (ind.TypeIndicator() == IND_BANDS) ? (cb_is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
           string time_text = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
           int shift = ::iBarShift(sym, tf, t, false);
           double price = (shift >= 0) ? ::iClose(sym, tf, shift) : 0.0;
           string price_text = ::DoubleToString(price, digits);
           if(signal.Type() == OBJECT_DE_TYPE_SIGNAL_OSCILLATOR && shift >= 0)
              cross_text = "Value " + ::DoubleToString(ind.GetDataBuffer(0, shift), 2);
           m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "CloseBar", dir_text, label, price_text, cross_text);
           if(message_on)
              CMessage::Out(time_text + ";CloseBar;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
          }
         if(newest_committed > wm)
            m_signal_logger.SetSignalLogWatermark(type_key, wm_params_key, newest_committed);
        }
       //--- Live bar 0: Sound + Message + CSV on every real direction change
       ENUM_SIGNAL_DIR live_dir = signal.GetCurrentSignal();
       if(seeding)
        {
         //--- Baseline = last closed-bar direction, so a flip made while detached still fires next tick
         int hist_total = signal.HistoryTotal();
         m_live_signal_last_seen[index] = (hist_total > 0) ? signal.HistoryDir(hist_total - 1) : live_dir;
         continue;
        }
       if(live_dir == m_live_signal_last_seen[index]) continue;
       m_live_signal_last_seen[index] = live_dir;
       if(live_dir == SIGNAL_NONE) continue;
       bool is_buy = (live_dir == SIGNAL_BUY);
       if(is_buy  && !(entry.BuySignal()  && symtf_buy))  continue;
       if(!is_buy && !(entry.SellSignal() && symtf_sell)) continue;
       if(sound_on)
          PlaySoundForDirection(is_buy);
       if(message_on)
        {
         string dir_text   = is_buy ? "Buy" : "Sell";
         string cross_text = (ind.TypeIndicator() == IND_BANDS) ? (is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
         if(signal.Type() == OBJECT_DE_TYPE_SIGNAL_OSCILLATOR)
            cross_text = "Value " + ::DoubleToString(ind.GetDataBuffer(0, 0), 2);
         string time_text  = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
         string price_text = ::DoubleToString(::iClose(sym, tf, 0), digits);   // bar 0 not closed: current price
         CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
         m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "Live", dir_text, label, price_text, cross_text);
        }
      }
    }
  }
 //+------------------------------------------------------------------+
 //| Candle Pattern alerts: closed-bar watermark + live bar 0          |
 //+------------------------------------------------------------------+
 void CGUIPannel::CheckCandlePatternAlerts(void)
  {
   if(m_BarPatterns_Control == NULL || m_BarTimeSeriesCollection == NULL || m_SymbolTFManager == NULL) return;
   CArrayObj *pattern_controls = m_BarPatterns_Control.GetListControls();
   int pattern_count = (pattern_controls != NULL) ? pattern_controls.Total() : 0;
   if(pattern_count == 0) return;
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   if(series_total == 0) return;
   int min_required_size = series_total * pattern_count;
   if(::ArraySize(m_candle_pattern_last_seen) < min_required_size)
    {
     int old_size = ::ArraySize(m_candle_pattern_last_seen);
     ::ArrayResize(m_candle_pattern_last_seen, min_required_size);
     ::ArrayResize(m_candle_pattern_last_bar, min_required_size);
     for(int i = old_size; i < min_required_size; i++)
      {
       m_candle_pattern_last_seen[i] = (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
       m_candle_pattern_last_bar[i]  = 0;
      }
    }   
   //--- Closed bars
   CArrayObj *all_patterns_cb = m_BarTimeSeriesCollection.GetListAllPatterns();
   if(all_patterns_cb != NULL)
    {
     int all_patterns_total_cb = all_patterns_cb.Total();
     for(int ti = 0; ti < series_total; ti++)
      {
       CBarSeriesDE *bar_series_cb = series_list.At(ti);
       if(bar_series_cb == NULL) continue;
       ENUM_TIMEFRAMES tf_cb = bar_series_cb.Timeframe();
       string tf_text_cb = TimeframeDescription(tf_cb);
       CSymbolTFSetting *symtf_cb = m_SymbolTFManager.FindByIdentity(sym, tf_cb);
       bool symtf_buy_cb  = (symtf_cb != NULL) ? symtf_cb.BuySignal()  : false;
       bool symtf_sell_cb = (symtf_cb != NULL) ? symtf_cb.SellSignal() : false;
       for(int row = 0; row < pattern_count; row++)
        {
         CBarPatternControl *ctrl_cb = PatternControlAt(row);
         if(ctrl_cb == NULL) continue;
         ENUM_PATTERN_TYPE pattern_cb = ctrl_cb.TypePattern();
         bool sound_on_cb   = ctrl_cb.SoundAlert();
         bool message_on_cb = ctrl_cb.MessageAlert();
         if(!sound_on_cb && !message_on_cb) continue;
         string wm_type_key_cb = "Pattern_" + ::EnumToString(pattern_cb);
         datetime wm_cb = m_signal_logger.GetSignalLogWatermark(wm_type_key_cb, tf_text_cb);
         if(wm_cb == 0)
          {
           datetime seed_cb = 0;
           for(int p = 0; p < all_patterns_total_cb; p++)
            {
             CBarPattern *pat_seed_cb = all_patterns_cb.At(p);
             if(pat_seed_cb == NULL || pat_seed_cb.Symbol() != sym || pat_seed_cb.Timeframe() != tf_cb || pat_seed_cb.TypePattern() != pattern_cb) continue;
             if(pat_seed_cb.Time() > seed_cb) seed_cb = pat_seed_cb.Time();
            }
           if(seed_cb == 0) seed_cb = ::TimeCurrent();
           m_signal_logger.SetSignalLogWatermark(wm_type_key_cb, tf_text_cb, seed_cb);
           continue;
          }
         datetime newest_committed_cb = wm_cb;
         for(int p = 0; p < all_patterns_total_cb; p++)
          {
           CBarPattern *pat_cb = all_patterns_cb.At(p);
           if(pat_cb == NULL || pat_cb.Symbol() != sym || pat_cb.Timeframe() != tf_cb || pat_cb.TypePattern() != pattern_cb) continue;
           datetime pt_cb = pat_cb.Time();
           if(pt_cb <= wm_cb) continue;
           if(pt_cb > newest_committed_cb) newest_committed_cb = pt_cb;
           ENUM_PATTERN_DIRECTION pdir_cb = pat_cb.Direction();
           if(pdir_cb != PATTERN_DIRECTION_BULLISH && pdir_cb != PATTERN_DIRECTION_BEARISH) continue;
           bool is_buy_cb = (pdir_cb == PATTERN_DIRECTION_BULLISH);
           if(is_buy_cb  && !(PatternSignalBuy(pattern_cb)  && symtf_buy_cb))  continue;
           if(!is_buy_cb && !(PatternSignalSell(pattern_cb) && symtf_sell_cb)) continue;
           string dir_text_cb = is_buy_cb ? "Buy" : "Sell";
           uint candles_cb = pat_cb.Candles();
           string pat_name_cb = pat_cb.GetProperty(PATTERN_PROP_NAME);
           if(pat_name_cb == "") pat_name_cb = ::EnumToString(pat_cb.TypePattern());
           string name_cb = (candles_cb > 0 ? "[" + ::IntegerToString(candles_cb) + "B] " : "") + pat_name_cb;
           string time_text_cb = ::TimeToString(pt_cb, TIME_DATE|TIME_MINUTES);
           int shift_cb = ::iBarShift(sym, tf_cb, pt_cb, false);
           double price_cb = (shift_cb >= 0) ? ::iClose(sym, tf_cb, shift_cb) : 0.0;
           string price_text_cb = ::DoubleToString(price_cb, (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS));
           m_signal_logger.WriteSignalLogRow(time_text_cb, "Candle", tf_text_cb, "CloseBar", dir_text_cb, name_cb, price_text_cb, "");
           if(message_on_cb)
              CMessage::Out(time_text_cb + ";CloseBar;" + tf_text_cb + ";" + name_cb + ";" + dir_text_cb);
          }
         if(newest_committed_cb > wm_cb)
            m_signal_logger.SetSignalLogWatermark(wm_type_key_cb, tf_text_cb, newest_committed_cb);
        }
      }
    }
   //--- Live bar 0
   for(int ti = 0; ti < series_total; ti++)
    {
     CBarSeriesDE *bar_series = series_list.At(ti);
     if(bar_series == NULL) continue;
     ENUM_TIMEFRAMES tf = bar_series.Timeframe();
     CSymbolTFSetting *symtf_live = m_SymbolTFManager.FindByIdentity(sym, tf);
     bool symtf_buy_live  = (symtf_live != NULL) ? symtf_live.BuySignal()  : false;
     bool symtf_sell_live = (symtf_live != NULL) ? symtf_live.SellSignal() : false;
     for(int row = 0; row < pattern_count; row++)
      {
       CBarPatternControl *ctrl_live = PatternControlAt(row);
       if(ctrl_live == NULL) continue;
       ENUM_PATTERN_TYPE pattern = ctrl_live.TypePattern();
       bool sound_on   = ctrl_live.SoundAlert();
       bool message_on = ctrl_live.MessageAlert();
       if(!sound_on && !message_on) continue;
       ENUM_PATTERN_DIRECTION current = DetectPatternOnBar0(pattern, bar_series);
       if(current == WRONG_VALUE) continue;
       int index = ti * pattern_count + row;
       //--- Once per direction per bar: a pattern flickering on the forming bar alerts only once
       datetime bar0_time = ::iTime(sym, tf, 0);
       if(current == m_candle_pattern_last_seen[index] && m_candle_pattern_last_bar[index] == bar0_time) continue;
       m_candle_pattern_last_seen[index] = current;
       m_candle_pattern_last_bar[index]  = bar0_time;
       bool is_bullish = (current == PATTERN_DIRECTION_BULLISH);
       bool dir_ok = is_bullish ? (PatternSignalBuy(pattern)  && symtf_buy_live)
                                : (PatternSignalSell(pattern) && symtf_sell_live);
       if(!dir_ok) continue;
       if(sound_on)
          PlaySoundForDirection(is_bullish);
       if(message_on)
        {
         //--- Same Time;Live;TF;Name;Dir shape as the indicator Live line
         int    candle_count = (int)ctrl_live.Candles();
         string name_live    = (candle_count > 0 ? "[" + ::IntegerToString(candle_count) + "B] " : "") + PatternTypeDescription(pattern);
         string dir_live     = is_bullish ? "Buy" : "Sell";
         string tf_live      = TimeframeDescription(tf);
         string time_live    = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
         string price_live   = ::DoubleToString(::iClose(sym, tf, 0), (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS));
         CMessage::Out(time_live + ";Live;" + tf_live + ";" + name_live + ";" + dir_live);
         m_signal_logger.WriteSignalLogRow(time_live, "Candle", tf_live, "Live", dir_live, name_live, price_live, "");
        }
      }
    }
  }
 //+------------------------------------------------------------------+
 //| Swing alerts: closed-bar only, watermark on ConfirmedTime         |
 //+------------------------------------------------------------------+
 void CGUIPannel::CheckSwingAlerts(void)
  {
   if(m_SwingSetting == NULL || m_BarTimeSeriesCollection == NULL) return;
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   CArrayObj *all_swings = m_BarTimeSeriesCollection.GetListAllSwings();
   int swings_total = (all_swings != NULL) ? all_swings.Total() : 0;
   if(series_total == 0 || swings_total == 0) return;
   int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   for(int ti = 0; ti < series_total; ti++)
    {
     CBarSeriesDE *bar_series = series_list.At(ti);
     if(bar_series == NULL) continue;
     ENUM_TIMEFRAMES tf = bar_series.Timeframe();
     string tf_text = TimeframeDescription(tf);
     for(int t = 0; t < 2; t++)
      {
       ENUM_SWING_TYPE type = types[t];
       bool sound_on   = m_SwingSetting.SoundAlert(type);
       bool message_on = m_SwingSetting.MessageAlert(type);
       if(!sound_on && !message_on) continue;
       string wm_key = "Swing_" + ::EnumToString(type);
       datetime wm = m_signal_logger.GetSignalLogWatermark(wm_key, tf_text);
       if(wm == 0)
        {
         datetime seed = 0;
         for(int s = 0; s < swings_total; s++)
          {
           CBarSwing *sw = all_swings.At(s);
           if(sw == NULL || sw.Symbol() != sym || sw.Timeframe() != tf || sw.TypeSwing() != type) continue;
           if(sw.ConfirmedTime() > seed) seed = sw.ConfirmedTime();
          }
         if(seed == 0) seed = ::TimeCurrent();
         m_signal_logger.SetSignalLogWatermark(wm_key, tf_text, seed);
         continue;
        }
       datetime newest = wm;
       for(int s = 0; s < swings_total; s++)
        {
         CBarSwing *sw = all_swings.At(s);
         if(sw == NULL || sw.Symbol() != sym || sw.Timeframe() != tf || sw.TypeSwing() != type) continue;
         datetime ct = sw.ConfirmedTime();
         if(ct <= wm) continue;
         if(ct > newest) newest = ct;
         string type_text  = (type == SWING_TYPE_HIGH) ? "High" : "Low";
         string name       = SwingTypeDescription(type) + " (" + SwingStructureDescription(sw.Structure()) + ")";
         string time_text  = ::TimeToString(sw.Time(), TIME_DATE|TIME_MINUTES);   // pivot bar, where the marker sits
         string price_text = ::DoubleToString(sw.Price(), digits);
         m_signal_logger.WriteSignalLogRow(time_text, "Swing", tf_text, "CloseBar", type_text, name, price_text, "");
         if(sound_on)
            PlaySoundForDirection(type == SWING_TYPE_LOW);   // Low -> buy sound, High -> sell sound
         if(message_on)
            CMessage::Out(time_text + ";CloseBar;" + tf_text + ";" + name + ";" + price_text);
        }
       if(newest > wm)
          m_signal_logger.SetSignalLogWatermark(wm_key, tf_text, newest);
      }
    }
  }
 //+------------------------------------------------------------------+
 //| Pattern on live bar 0 of one series: its own control, index of   |
 //| bar 0 in the time-sorted series list                             |
 //+------------------------------------------------------------------+
 ENUM_PATTERN_DIRECTION CGUIPannel::DetectPatternOnBar0(const ENUM_PATTERN_TYPE pattern_type, CBarSeriesDE *series)
  {
   if(series == NULL) return (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
   CBarPatternsControl *patterns_manager = series.GetPatternsCtrlObj();
   CArrayObj *controls = (patterns_manager != NULL) ? patterns_manager.GetListControls() : NULL;
   CArrayObj *bars = series.GetList();
   if(controls == NULL || bars == NULL || bars.Total() == 0) return (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
   int bar0_index = bars.Total() - 1;
   CBar *bar0 = bars.At(bar0_index);
   if(bar0 == NULL || bar0.Time() != ::iTime(series.Symbol(), series.Timeframe(), 0)) return (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
   for(int i = 0; i < controls.Total(); i++)
    {
     CBarPatternControl *ctrl = controls.At(i);
     if(ctrl == NULL || ctrl.TypePattern() != pattern_type) continue;
     MqlRates mother_bar_data = {};
     return ctrl.FindPattern(bar0_index, mother_bar_data);
    }
   return (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| One BBands line (Upper/Lower): closed-bar watermark + live flip,  |
 //| Message + CSV only (no Sound)                                     |
 //+------------------------------------------------------------------+
 void CGUIPannel::ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name,
                                  ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key,
                                  const string label, const string tf_text, const int digits,
                                  const bool buy_on, const bool sell_on, const bool symtf_buy, const bool symtf_sell)
  {
   CIndicatorDE *ind = bb.GetIndicator();
   if(ind == NULL) return;
   string line_params_key = params_key + "|" + line_name;
   datetime wm = m_signal_logger.GetSignalLogWatermark(type_key, line_params_key);
   int total = bb.LineHistoryTotal(line_idx);
   if(wm == 0)
    {
     datetime seed = 0;
     for(int idx = 0; idx < total; idx++)
      {
       datetime t = bb.LineHistoryTime(line_idx, idx);
       if(t > seed) seed = t;
      }
     if(seed == 0) seed = ::TimeCurrent();
     m_signal_logger.SetSignalLogWatermark(type_key, line_params_key, seed);
    }
   else
    {
     datetime newest_committed = wm;
     for(int idx = 0; idx < total; idx++)
      {
       datetime t = bb.LineHistoryTime(line_idx, idx);
       if(t <= wm) continue;
       if(t > newest_committed) newest_committed = t;
       ENUM_SIGNAL_DIR hdir = bb.LineHistoryDir(line_idx, idx);
       if(hdir == SIGNAL_NONE) continue;
       if(hdir == SIGNAL_BUY  && !(buy_on  && symtf_buy))  continue;
       if(hdir == SIGNAL_SELL && !(sell_on && symtf_sell)) continue;
       string dir_text   = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
       string cross_text = (hdir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
       string time_text  = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
       int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
       double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
       string price_text = ::DoubleToString(price, digits);
       m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "CloseBar", dir_text, label, price_text, cross_text);
       CMessage::Out(time_text + ";CloseBar;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
      }
     if(newest_committed > wm)
        m_signal_logger.SetSignalLogWatermark(type_key, line_params_key, newest_committed);
    }
   ENUM_SIGNAL_DIR live_dir = bb.LineCurrentSignal(line_idx);
   if(seeding)
    {
     int line_hist_total = bb.LineHistoryTotal(line_idx);
     last_seen[row] = (line_hist_total > 0) ? bb.LineHistoryDir(line_idx, line_hist_total - 1) : live_dir;
     return;
    }
   if(live_dir == last_seen[row]) return;
   last_seen[row] = live_dir;
   if(live_dir == SIGNAL_NONE) return;
   bool is_buy_line = (live_dir == SIGNAL_BUY);
   if(is_buy_line  && !(buy_on  && symtf_buy))  return;
   if(!is_buy_line && !(sell_on && symtf_sell)) return;
   string dir_text   = is_buy_line ? "Buy" : "Sell";
   string cross_text = is_buy_line ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
   string time_text  = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
   string price_text = ::DoubleToString(::iClose(ind.Symbol(), ind.Timeframe(), 0), digits);
   CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
   m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "Live", dir_text, label, price_text, cross_text);
  }
#endif // CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
