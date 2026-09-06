//+------------------------------------------------------------------+
//|                           GUIPannel_SoundAndMessageAlerts.mqh    |
//+------------------------------------------------------------------+
//Bug Note: Sound in folder C:\Program Files\MetaTrader 5\Sounds
#ifndef CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
#define CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
 #include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Check and play sound when a new bar opens on any timeframe       |
 //+------------------------------------------------------------------+
 void CGUIPannel::PlaySoundCloseBar(void)
  {
    if(m_BarTimeSeriesCollection.IsEvent())
      ::PlaySound("NewBar.wav");
  }
 //PlaySound for Live only for Close Bar only Play NewBar.wav
 void CGUIPannel::PlaySoundForDirection(const bool is_buy)
  {
   string file = is_buy ? m_marker_buy_sound_file : m_marker_sell_sound_file;
   if(file == "") return;
   ::PlaySound(file);
  } 
 void CGUIPannel::CheckIndicatorAlerts(void)
  {
   if(m_timeSeriesEngine == NULL || m_BarTimeSeriesCollection == NULL ||
      m_indicator_template_manager == NULL || m_SymbolTFManager == NULL) return;
   int rows = m_indicator_template_manager.Total();
   if(rows == 0) return;   
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   if(series_total == 0) return;
   int total_slots = series_total * rows;
   int prev_size = ArraySize(m_live_signal_last_seen);
   bool seeding = (prev_size != total_slots); // TF/row grid just changed shape - seed, don't fire
   if(seeding)
     {
       ArrayResize(m_live_signal_last_seen, total_slots);
       ArrayResize(m_upper_last_seen, total_slots);
       ArrayResize(m_lower_last_seen, total_slots);
     }
   for(int ti = 0; ti < series_total; ti++)
    {
      CBarSeriesDE *s = series_list.At(ti);
      if(s == NULL) continue;
      ENUM_TIMEFRAMES tf = s.Timeframe();
      string tf_text = TimeframeDescription(tf);

      // --- Symbol+TF-level Buy/Sell gate, computed once per TF.
       CSymbolTFSetting *symtf_entry = m_SymbolTFManager.FindByIdentity(sym, tf);
       bool symtf_buy  = (symtf_entry != NULL) ? symtf_entry.BuySignal()  : false;
       bool symtf_sell = (symtf_entry != NULL) ? symtf_entry.SellSignal() : false;

      CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;

      for(int row = 0; row < rows; row++)
       {
        CIndicatorSetting *entry = m_indicator_template_manager.At(row);
        if(entry == NULL) continue;
        // --- Sound/Message opt-in read straight off the Manager row (kept current by
        // --- OnClickToggleSoundAlert/MessageAlert), not a stale duplicate array.
         bool sound_on   = entry.SoundAlert();
         bool message_on = entry.MessageAlert();
         if(!sound_on && !message_on) continue;

        MqlParam raw_params[];
        entry.GetRawParams(raw_params);
        if(ArraySize(raw_params) == 0) continue;

        // --- Find THIS TF's own instance of the template row - RAW compare
        // --- (type_enum/raw_params), same identity convention as everywhere else.
         CIndicatorDE *ind = NULL;
         for(int ii = 0; ii < ind_total; ii++)
          {
           CIndicatorDE *cand = ind_list.At(ii);
           if(cand == NULL || cand.TypeIndicator() != entry.TypeEnum()) continue;
           MqlParam cand_params[];
           cand.GetMqlParams(cand_params);
           if(IsEqualMqlParamArrays(cand_params, raw_params)) { ind = cand; break; }
          }
         if(ind == NULL) continue; // not created on this TF yet (background sync still catching up)

        CSignalBase *signal = m_timeSeriesEngine.GetSignalsCollection().GetOrCreateSignal(ind);
        // --- NULL here just means this indicator type has no CSignalXxx wired yet in
        // --- GetOrCreateSignal (e.g. ATR) - known, permanent.
        if(signal == NULL) continue;

        int index = ti * rows + row;
        string label = entry.DisplayLabel();
        int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
        // --- Watermark key: type_key = TypeEnum text, params_key = DisplayLabel() - already
        // --- unique per raw_params combo at GUI-configurable precision, no need for a separate
        // --- BuildIndicatorParamsText call just for this (Anhnt, 2026-08-28).
         string type_key = EnumToString(entry.TypeEnum());
        // --- TF-qualify the watermark key - a template is shared across every tracked TF, but
        // --- each TF's own flip history must never share a watermark record with another TF's.
         string wm_params_key = label + "|" + tf_text;

        //--- BBands-only: also surface the Upper/Lower line-cross histories - same source
        //--- BuildAndWriteSignalBridge reads. Mid is NOT processed here: it IS the primary
        //--- signal now (CSignalBollinger::ComputeAt), already collected by the generic
        //--- signal.HistoryDir() loop below - including it here too would duplicate every Mid cross.
        if(message_on && ind.TypeIndicator() == IND_BANDS)
         {
          CSignalBollinger *bb = (CSignalBollinger*)signal;
          ProcessBandLine(index, bb, BBAND_LINE_UPPER, "Upper", m_upper_last_seen, seeding, type_key, wm_params_key,
                           label, tf_text, digits, entry.BuySignal(), entry.SellSignal(), symtf_buy, symtf_sell);
          ProcessBandLine(index, bb, BBAND_LINE_LOWER, "Lower", m_lower_last_seen, seeding, type_key, wm_params_key,
                           label, tf_text, digits, entry.BuySignal(), entry.SellSignal(), symtf_buy, symtf_sell);
         }
        //--- Closed-bar path: catch-up of every committed flip newer than the persisted
        //--- per-template-per-TF watermark - fires Sound+Message+CSV same as Live.
         datetime wm = m_signal_logger.GetSignalLogWatermark(type_key, wm_params_key);
         int total = signal.HistoryTotal();
         if(wm == 0)
          {
           // --- Never watermarked before (key never matched a saved entry, or truly first
           // --- run) - seed silently to the newest known flip instead of replaying the whole
           // --- history as a synchronous flood of file writes/alerts. Anhnt, 2026-08-29.
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
             // --- Watermark always advances past everything in range, regardless of the gate
             // --- below - so re-enabling Buy/Sell later never retroactively floods old flips.
             if(t > newest_committed) newest_committed = t;

             ENUM_SIGNAL_DIR hdir = signal.HistoryDir(idx);
             if(hdir == SIGNAL_BUY  && !(entry.BuySignal()  && symtf_buy))  continue;
             if(hdir == SIGNAL_SELL && !(entry.SellSignal() && symtf_sell)) continue;
             if(hdir == SIGNAL_NONE) continue;

             bool cb_is_buy = (hdir == SIGNAL_BUY);
             string dir_text = cb_is_buy ? "Buy" : "Sell";
             // --- BBands' own primary signal IS the MidBand cross now - name it explicitly so
             // --- this row can't be confused with the Upper/Lower line-cross rows above.
             string cross_text = (ind.TypeIndicator() == IND_BANDS)
                                   ? (cb_is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
             string time_text = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
             int shift = ::iBarShift(sym, tf, t, false);
             double price = (shift >= 0) ? ::iClose(sym, tf, shift) : 0.0;
             string price_text = ::DoubleToString(price, digits);
             m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "CloseBar", dir_text, label, price_text, cross_text);
             if(message_on)
               CMessage::Out(time_text + ";CloseBar;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
            }
           if(newest_committed > wm)
             m_signal_logger.SetSignalLogWatermark(type_key, wm_params_key, newest_committed);
          }

        //--- Live bar-0 path: fire Sound+Message+CSV on every real direction change.
         ENUM_SIGNAL_DIR live_dir = signal.GetCurrentSignal();
         if(seeding)
          {
           // --- Baseline = last CloseBar direction (not live_dir) so a real flip that happened
           // --- while the EA was detached still fires on the very next tick's normal compare
           // --- below. No CloseBar history yet - fall back to live_dir.
            int hist_total = signal.HistoryTotal();
            m_live_signal_last_seen[index] = (hist_total > 0) ? signal.HistoryDir(hist_total - 1) : live_dir;
            continue; // still silent on this very tick
          }
         if(live_dir == m_live_signal_last_seen[index]) continue;
         m_live_signal_last_seen[index] = live_dir;
         if(live_dir == SIGNAL_NONE) continue; // dropped to no-signal - not alert-worthy itself

         bool is_buy = (live_dir == SIGNAL_BUY);
         if(is_buy  && !(entry.BuySignal()  && symtf_buy))  continue;
         if(!is_buy && !(entry.SellSignal() && symtf_sell)) continue;

         if(sound_on)
          {
           // --- Deliberately native ::PlaySound() (via PlaySoundForDirection), NOT CMessage::PlaySound()
           // --- - that wrapper unconditionally prepends "\Files\" to any filename that isn't one
           // --- of its own built-in SND_* constants. Bare filename only resolves against
           // --- TERMINAL_PATH\Sounds\ (install dir) - NOT MQL5\Sounds\, NOT MQL5\Files\Sounds\.
             PlaySoundForDirection(is_buy);
          }
         if(message_on)
          {
           string dir_text  = is_buy ? "Buy" : "Sell";
           string cross_text = (ind.TypeIndicator() == IND_BANDS)
                               ? (is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
           string time_text = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
           // --- Bar 0 hasn't closed yet - treat the CURRENT price as its "Close".
           double price = ::iClose(sym, tf, 0);
           string price_text = ::DoubleToString(price, digits);
           CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
           m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "Live", dir_text, label, price_text, cross_text);
          }
       }
    }
  }
 //+------------------------------------------------------------------+
 //| Sound/Message/CSV for Candle Patterns - Buy/Sell/Sound/Message    |
 //| opt-in read straight off each row's CBarPatternControl (Single    |
 //| Source of Truth, via PatternControlAt()) - plus the same          |
 //| Symbol+TF-level gate via m_SymbolTFManager (Anhnt, 2026-08-29).    |
 //+------------------------------------------------------------------+
 void CGUIPannel::CheckCandlePatternAlerts(void)
  {
   if(m_BarPatterns_Control == NULL || m_BarTimeSeriesCollection == NULL || m_SymbolTFManager == NULL) return;
   MqlRates bar_0_temp;
   ::ZeroMemory(bar_0_temp);
   bar_0_temp.open  = ::iOpen(::Symbol(), ::Period(), 0);
   bar_0_temp.high  = ::iHigh(::Symbol(), ::Period(), 0);
   bar_0_temp.low   = ::iLow(::Symbol(), ::Period(), 0);
   bar_0_temp.close = ::iClose(::Symbol(), ::Period(), 0);
   bar_0_temp.time  = ::iTime(::Symbol(), ::Period(), 0);

   CArrayObj *pattern_controls = m_BarPatterns_Control.GetListControls();
   int pattern_count = (pattern_controls != NULL) ? pattern_controls.Total() : 0;
   if(pattern_count == 0) return;
   string sym = ::Symbol();
   // Get all timeframes for current symbol
    CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
    CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
    int series_total = (series_list != NULL) ? series_list.Total() : 0;
    if(series_total == 0) return;
    // Ensure array has enough capacity - will grow as needed
     int min_required_size = series_total * pattern_count;
     if(min_required_size > 0 && ArraySize(m_candle_pattern_last_seen) < min_required_size)
      {
       ArrayResize(m_candle_pattern_last_seen, min_required_size);
       for(int i = 0; i < min_required_size; i++)
         m_candle_pattern_last_seen[i] = (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      }
   // Detect new bar on each TF of current symbol - reset pattern state for that TF
    for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *bar_series_check = series_list.At(ti);
      if(bar_series_check == NULL) continue;
      if(bar_series_check.IsNewBar(::TimeCurrent()))
       {
        // New bar detected on this TF - reset pattern state for this TF only
        for(int row = 0; row < pattern_count; row++)
         {
          int index = ti * pattern_count + row;
          m_candle_pattern_last_seen[index] = (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
         }
       }
     }   
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
        // --- Symbol+TF-level Buy/Sell gate, computed once per TF.
         CSymbolTFSetting *symtf_cb = m_SymbolTFManager.FindByIdentity(sym, tf_cb);
         bool symtf_buy_cb  = (symtf_cb != NULL) ? symtf_cb.BuySignal()  : false;
         bool symtf_sell_cb = (symtf_cb != NULL) ? symtf_cb.SellSignal() : false;

        for(int row = 0; row < pattern_count; row++)
         {
          CBarPatternControl *ctrl_cb = PatternControlAt(row);
          ENUM_PATTERN_TYPE pattern_cb = (ctrl_cb != NULL) ? ctrl_cb.TypePattern() : PATTERN_TYPE_NONE;
          bool sound_on_cb   = (ctrl_cb != NULL) ? ctrl_cb.SoundAlert()   : false;
          bool message_on_cb = (ctrl_cb != NULL) ? ctrl_cb.MessageAlert() : false;
          if(!sound_on_cb && !message_on_cb) continue;

          string wm_type_key_cb   = "Pattern_" + EnumToString(pattern_cb);
          datetime wm_cb = m_signal_logger.GetSignalLogWatermark(wm_type_key_cb, tf_text_cb);
          if(wm_cb == 0)
           {
            // --- Never watermarked before - seed silently to the newest known pattern hit
            // --- instead of replaying the whole history as a flood. Anhnt, 2026-08-29.
             datetime seed_cb = 0;
             for(int p = 0; p < all_patterns_total_cb; p++)
              {
               CBarPattern *pat_seed_cb = all_patterns_cb.At(p);
               if(pat_seed_cb == NULL) continue;
               if(pat_seed_cb.Symbol() != sym || pat_seed_cb.Timeframe() != tf_cb || pat_seed_cb.TypePattern() != pattern_cb) continue;
               datetime pt_seed_cb = pat_seed_cb.Time();
               if(pt_seed_cb > seed_cb) seed_cb = pt_seed_cb;
              }
             if(seed_cb == 0) seed_cb = ::TimeCurrent();
             m_signal_logger.SetSignalLogWatermark(wm_type_key_cb, tf_text_cb, seed_cb);
           }
          else
           {
           datetime newest_committed_cb = wm_cb;

           for(int p = 0; p < all_patterns_total_cb; p++)
            {
             CBarPattern *pat_cb = all_patterns_cb.At(p);
             if(pat_cb == NULL) continue;
             if(pat_cb.Symbol() != sym || pat_cb.Timeframe() != tf_cb || pat_cb.TypePattern() != pattern_cb) continue;
             datetime pt_cb = pat_cb.Time();
             if(pt_cb <= wm_cb) continue;

             ENUM_PATTERN_DIRECTION pdir_cb = pat_cb.Direction();
             // Only BULLISH/BEARISH map to a Buy/Sell row (matches SignalBridgeWriter's own
             // filter) - BOTH/anything else isn't a directional alert, skip but still advance
             // the watermark so it doesn't get re-checked forever.
             if(pdir_cb != PATTERN_DIRECTION_BULLISH && pdir_cb != PATTERN_DIRECTION_BEARISH)
               { if(pt_cb > newest_committed_cb) newest_committed_cb = pt_cb; continue; }
             if(pt_cb > newest_committed_cb) newest_committed_cb = pt_cb;

             bool is_buy_cb = (pdir_cb == PATTERN_DIRECTION_BULLISH);
             // --- Buy/Sell + Symbol+TF gate - watermark already advanced above regardless.
             if(is_buy_cb  && !(PatternSignalBuy(pattern_cb)  && symtf_buy_cb))  continue;
             if(!is_buy_cb && !(PatternSignalSell(pattern_cb) && symtf_sell_cb)) continue;

             string dir_text_cb = is_buy_cb ? "Buy" : "Sell";
             uint candles_cb = pat_cb.Candles();
             string pat_name_cb = pat_cb.GetProperty(PATTERN_PROP_NAME);
             if(pat_name_cb == "") pat_name_cb = EnumToString(pat_cb.TypePattern());
             string name_cb = (candles_cb > 0 ? "[" + IntegerToString(candles_cb) + "B] " : "") + pat_name_cb;
             string time_text_cb = ::TimeToString(pt_cb, TIME_DATE|TIME_MINUTES);
             int shift_cb = ::iBarShift(sym, tf_cb, pt_cb, false);
             double price_cb = (shift_cb >= 0) ? ::iClose(sym, tf_cb, shift_cb) : 0.0;
             int digits_cb = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
             string price_text_cb = ::DoubleToString(price_cb, digits_cb);

             m_signal_logger.WriteSignalLogRow(time_text_cb, "Candle", tf_text_cb, "CloseBar", dir_text_cb, name_cb, price_text_cb, "");
             if(message_on_cb)
               CMessage::Out(time_text_cb + ";CloseBar;" + tf_text_cb + ";" + name_cb + ";" + dir_text_cb);
            }
           if(newest_committed_cb > wm_cb)
             m_signal_logger.SetSignalLogWatermark(wm_type_key_cb, tf_text_cb, newest_committed_cb);
           }
         }
       }
     }
   // Iterate each timeframe - LIVE bar 0
    for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *bar_series = series_list.At(ti);
      if(bar_series == NULL) continue;
      ENUM_TIMEFRAMES tf = bar_series.Timeframe();

      // Get pattern manager for this bar series (contains all pattern controllers)
      CBarPatternsControl *patterns_manager = bar_series.GetPatternsCtrlObj();
      if(patterns_manager == NULL) continue;

      CArrayObj *pattern_controls = patterns_manager.GetListControls();
      if(pattern_controls == NULL || pattern_controls.Total() == 0) continue;

      // --- Symbol+TF-level Buy/Sell gate, computed once per TF.
       CSymbolTFSetting *symtf_live = m_SymbolTFManager.FindByIdentity(sym, tf);
       bool symtf_buy_live  = (symtf_live != NULL) ? symtf_live.BuySignal()  : false;
       bool symtf_sell_live = (symtf_live != NULL) ? symtf_live.SellSignal() : false;

      // Iterate each pattern type
       for(int row = 0; row < pattern_count; row++)
        {
         CBarPatternControl *ctrl_live = PatternControlAt(row);
         ENUM_PATTERN_TYPE pattern = (ctrl_live != NULL) ? ctrl_live.TypePattern() : PATTERN_TYPE_NONE;
         bool sound_on   = (ctrl_live != NULL) ? ctrl_live.SoundAlert()   : false;
         bool message_on = (ctrl_live != NULL) ? ctrl_live.MessageAlert() : false;
         if(!sound_on && !message_on) continue;
        // Detect pattern on live bar 0 for this timeframe
         ENUM_PATTERN_DIRECTION current = DetectPatternOnBar0(pattern, tf, bar_0_temp);
         int index = ti * pattern_count + row;  // flatten index
        // Ensure array can hold this index - grow on-the-fly if needed
         if(index >= ArraySize(m_candle_pattern_last_seen))
           ArrayResize(m_candle_pattern_last_seen, index + 1);
        // Compare with last state (2D array [tf_index][pattern_index])
         if(current != m_candle_pattern_last_seen[index])
          {
           if(current != WRONG_VALUE)
            {
             bool is_bullish = (current == PATTERN_DIRECTION_BULLISH);
             // --- Buy/Sell + Symbol+TF gate.
             bool dir_ok = is_bullish ? (PatternSignalBuy(pattern)  && symtf_buy_live)
                                       : (PatternSignalSell(pattern) && symtf_sell_live);
             if(dir_ok)
              {
               if(sound_on)
                 PlaySoundForDirection(is_bullish);
               if(message_on)
                {
                 string dir_text = is_bullish ? "Buy" : "Sell";
                 string pattern_name = PatternTypeDescription(pattern);
                 string tf_text = TimeframeDescription(tf);
                 string time_text = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
                 // Candles() reads straight off the Control object (CBarPatternControl seeds it
                 // from its own constructor now) - same source the Candle Pattern table's "No"
                 // column already uses, no separate classification call (Anhnt, 2026-08-29).
                 int candle_count = (ctrl_live != NULL) ? (int)ctrl_live.Candles() : 0;
                 CMessage::Out(time_text + " - " + pattern_name + " " + dir_text + " (" + (string)candle_count + " candle" + (candle_count > 1 ? "s" : "") + ") " + tf_text);
                }
              }
            }
           m_candle_pattern_last_seen[index] = current;
          }
        }
     }
  }
 // Check pattern criteria directly from OHLC (for live bar 0)
 ENUM_PATTERN_DIRECTION CGUIPannel::CheckPatternLive(ENUM_PATTERN_TYPE pattern_type, MqlRates &rates, CBarPatternControl *ctrl)
  {
    if(rates.high == rates.low || ctrl == NULL) return WRONG_VALUE;
    double body = MathAbs(rates.close - rates.open);
    double candle = rates.high - rates.low;
    double lower_shadow = (rates.open > rates.close) ? (rates.open - rates.low) : (rates.close - rates.low);
    double upper_shadow = (rates.open > rates.close) ? (rates.high - rates.close) : (rates.high - rates.open);
    double body_ratio = body / candle;
    double lower_ratio = lower_shadow / candle;
    double upper_ratio = upper_shadow / candle;

    bool is_bullish = (rates.close > rates.open);

    // Pattern detection constants (from PatternControl.mqh, convert % to decimal)
    const double SMALL_BODY      = PATTERN_DEF_SMALL_BODY / 100.0;           // 0.35
    const double LARGE_BODY      = PATTERN_DEF_LARGE_BODY / 100.0;           // 0.60
    const double DOJI_BODY       = PATTERN_DEF_DOJI_BODY / 100.0;            // 0.05
    const double INNER_BODY      = PATTERN_DEF_INNER_BODY / 100.0;           // 0.30
    const double LONG_SHADOW     = PATTERN_DEF_LONG_SHADOW / 100.0;          // 0.55
    const double SHORT_SHADOW    = PATTERN_DEF_SHORT_SHADOW / 100.0;         // 0.10
    const double DEEP_SHADOW     = PATTERN_DEF_DEEP_SHADOW / 100.0;          // 0.70
    const double PENETRATION     = PATTERN_DEF_PENETRATION / 100.0;          // 0.50
    const double SIMILARITY      = PATTERN_DEF_SIMILARITY / 100.0;           // 0.70

    switch(pattern_type) {
      case PATTERN_TYPE_HAMMER:
        if(body_ratio < SMALL_BODY && lower_ratio > LONG_SHADOW && upper_ratio < SHORT_SHADOW)
          return is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH;
        break;
      case PATTERN_TYPE_HANGING_MAN:
        if(body_ratio < SMALL_BODY && lower_ratio > LONG_SHADOW && upper_ratio < SHORT_SHADOW)
          return is_bullish ? PATTERN_DIRECTION_BEARISH : PATTERN_DIRECTION_BULLISH;
        break;
      case PATTERN_TYPE_INVERTED_HAMMER:
        if(body_ratio < SMALL_BODY && upper_ratio > LONG_SHADOW && lower_ratio < SHORT_SHADOW)
          return is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH;
        break;
      case PATTERN_TYPE_SHOOTING_STAR:
        if(body_ratio < SMALL_BODY && upper_ratio > LONG_SHADOW && lower_ratio < SHORT_SHADOW)
          return is_bullish ? PATTERN_DIRECTION_BEARISH : PATTERN_DIRECTION_BULLISH;
        break;
      case PATTERN_TYPE_DOJI:
        if(body_ratio < DOJI_BODY && lower_ratio > PENETRATION && upper_ratio > PENETRATION)
          return PATTERN_DIRECTION_BULLISH;
        break;
      case PATTERN_TYPE_DRAGONFLY_DOJI:
        if(body_ratio < DOJI_BODY && lower_ratio > DEEP_SHADOW && upper_ratio < SHORT_SHADOW)
          return PATTERN_DIRECTION_BULLISH;
        break;
      case PATTERN_TYPE_GRAVESTONE_DOJI:
        if(body_ratio < DOJI_BODY && upper_ratio > DEEP_SHADOW && lower_ratio < SHORT_SHADOW)
          return PATTERN_DIRECTION_BEARISH;
        break;
      case PATTERN_TYPE_HARAMI:
        return (body_ratio > INNER_BODY && body_ratio < LARGE_BODY) ? (is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH) : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      case PATTERN_TYPE_HARAMI_CROSS:
        return (body_ratio < DOJI_BODY) ? (is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH) : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      case PATTERN_TYPE_ENGULFING:
        return (body_ratio > PENETRATION) ? (is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH) : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      case PATTERN_TYPE_TWEEZER:
        return (lower_ratio < SHORT_SHADOW && upper_ratio < SHORT_SHADOW) ? (is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH) : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      case PATTERN_TYPE_PIERCING_LINE:
        return (body_ratio > LARGE_BODY && lower_ratio < SHORT_SHADOW) ? PATTERN_DIRECTION_BULLISH : WRONG_VALUE;
      case PATTERN_TYPE_DARK_CLOUD_COVER:
        return (body_ratio > LARGE_BODY && upper_ratio < SHORT_SHADOW) ? PATTERN_DIRECTION_BEARISH : WRONG_VALUE;
      case PATTERN_TYPE_RAILS:
        return (body_ratio > SIMILARITY) ? (is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH) : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      case PATTERN_TYPE_MORNING_STAR:
        return (body_ratio > INNER_BODY && lower_ratio > PENETRATION) ? PATTERN_DIRECTION_BULLISH : WRONG_VALUE;
      case PATTERN_TYPE_MORNING_DOJI_STAR:
        return (body_ratio < DOJI_BODY) ? PATTERN_DIRECTION_BULLISH : WRONG_VALUE;
      case PATTERN_TYPE_EVENING_STAR:
        return (body_ratio > INNER_BODY && upper_ratio > PENETRATION) ? PATTERN_DIRECTION_BEARISH : WRONG_VALUE;
      case PATTERN_TYPE_EVENING_DOJI_STAR:
        return (body_ratio < DOJI_BODY) ? PATTERN_DIRECTION_BEARISH : WRONG_VALUE;
      case PATTERN_TYPE_THREE_WHITE_SOLDIERS:
        return PATTERN_DIRECTION_BULLISH;
      case PATTERN_TYPE_THREE_BLACK_CROWS:
        return PATTERN_DIRECTION_BEARISH;
      case PATTERN_TYPE_THREE_STARS:
        return (body_ratio < SHORT_SHADOW) ? PATTERN_DIRECTION_BULLISH : WRONG_VALUE;
      case PATTERN_TYPE_THREE_INSIDE_UP:
        return PATTERN_DIRECTION_BULLISH;
      case PATTERN_TYPE_THREE_INSIDE_DOWN:
        return PATTERN_DIRECTION_BEARISH;
      case PATTERN_TYPE_ABANDONED_BABY:
        return (body_ratio < DOJI_BODY) ? PATTERN_DIRECTION_BULLISH : WRONG_VALUE;
      case PATTERN_TYPE_PIVOT_POINT_REVERSAL:
        return (body_ratio > SMALL_BODY) ? (is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH) : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      case PATTERN_TYPE_OUTSIDE_BAR:
        return (rates.high > rates.high && rates.low < rates.low) ? (is_bullish ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH) : (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
      case PATTERN_TYPE_INSIDE_BAR:
        return (rates.high < rates.high && rates.low > rates.low) ? PATTERN_DIRECTION_BULLISH : WRONG_VALUE;
      case PATTERN_TYPE_PIN_BAR:
        if(body_ratio < (PATTERN_DEF_PINBAR_RATIO_BODY / 100.0) && (lower_ratio > (PATTERN_DEF_PINBAR_LARGER_SHADOW / 100.0) || upper_ratio > (PATTERN_DEF_PINBAR_LARGER_SHADOW / 100.0)))
          return (lower_ratio > upper_ratio) ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH;
        break;
    }
    return (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
  }
 // Detect pattern on live bar 0 - treat as closed bar with current OHLC + closed bars -1, -2 from series
 ENUM_PATTERN_DIRECTION CGUIPannel::DetectPatternOnBar0(ENUM_PATTERN_TYPE pattern_type, ENUM_TIMEFRAMES tf, MqlRates &bar_0_temp)
  {
   // Get pattern control for this pattern type and symbol/TF
    CArrayObj *controls = m_BarPatterns_Control.GetListControls();
    if(controls == NULL) return (ENUM_PATTERN_DIRECTION)WRONG_VALUE;

    for(int i = 0; i < controls.Total(); i++)
     {
        CBarPatternControl *ctrl = controls.At(i);
        if(ctrl == NULL) continue;
        if(ctrl.TypePattern() == pattern_type && ctrl.Symbol() == ::Symbol() && ctrl.Timeframe() == tf)
        {
          // FindPattern() will auto-fetch bars -1, -2 from series history + use bar_0_temp
          ENUM_PATTERN_DIRECTION result = ctrl.FindPattern(bar_0_temp.time, (MqlRates&)bar_0_temp);
          return result;
        }
     }
    return (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
  } 
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
     // --- Never watermarked before - seed silently to the newest known line-cross instead of
     // --- replaying the whole history as a flood. Anhnt, 2026-08-29.
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
        // --- Same 2-layer Buy/Sell gate as the primary signal - watermark already advanced above.
        if(hdir == SIGNAL_BUY  && !(buy_on  && symtf_buy))  continue;
        if(hdir == SIGNAL_SELL && !(sell_on && symtf_sell)) continue;
        if(hdir == SIGNAL_NONE) continue;
        string dir_text   = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
        string cross_text = (hdir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
        string time_text  = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
        int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
        double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
        string price_text = ::DoubleToString(price, digits);
        m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "CloseBar", dir_text, label, price_text, cross_text);
        // --- No Sound here (deliberate scoped-down decision, matches the Live block below) - only
        // --- Message+CSV fire for CloseBar too.
        CMessage::Out(time_text + ";CloseBar;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
      }
     if(newest_committed > wm)
        m_signal_logger.SetSignalLogWatermark(type_key, line_params_key, newest_committed);
    }

   ENUM_SIGNAL_DIR live_dir = bb.LineCurrentSignal(line_idx);
   if(seeding)
    {
      // --- Baseline = last CloseBar direction of THIS line, not live_dir, so a flip during
      // --- Detach still fires on the next tick's normal compare below.
      int line_hist_total = bb.LineHistoryTotal(line_idx);
      last_seen[row] = (line_hist_total > 0) ? bb.LineHistoryDir(line_idx, line_hist_total - 1) : live_dir;
      return; // still silent on this very tick
    }
   if(live_dir == last_seen[row]) return; // no change
   last_seen[row] = live_dir;
   if(live_dir == SIGNAL_NONE) return; // dropped to exactly-on-the-line - not report-worthy itself

   bool is_buy_line = (live_dir == SIGNAL_BUY);
   if(is_buy_line  && !(buy_on  && symtf_buy))  return;
   if(!is_buy_line && !(sell_on && symtf_sell)) return;

   // --- Same Time;Live;TF;Indicator;Signal shape as the primary message, plus a 6th
   // --- ";"-delimited field naming which line/direction triggered it.
   string dir_text   = (live_dir == SIGNAL_BUY) ? "Buy" : "Sell";
   string cross_text = (live_dir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
   string time_text  = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
   double price = ::iClose(ind.Symbol(), ind.Timeframe(), 0);
   string price_text = ::DoubleToString(price, digits);
   CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
   m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "Live", dir_text, label, price_text, cross_text);
  }
#endif // CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
