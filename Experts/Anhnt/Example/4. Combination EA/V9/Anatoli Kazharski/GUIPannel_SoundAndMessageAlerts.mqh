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
 //Every TF Share the same Template in Layer 1 similar to Template on Chart.
 //Alert change in Direction in Every Indicator + TF at Live
 void CGUIPannel::CheckIndicatorAlerts(void)
  {
   if(m_time_series_engine == NULL || m_BarTimeSeriesCollection == NULL) return;
   // --- SynIndicatorPlan.md, Dot 3d, 2026-08-18: row count + identity now come from the live
   // --- m_indicator_template_setting[] (Layer 2's own source of truth) instead of m_table_indicator_ptrs[].
   int rows = ArraySize(m_indicator_template_setting);
   if(rows == 0) return;
   if(!m_signal_log_watermarks_loaded)
    {
      m_signal_logger.LoadSignalLogWatermarks();
      m_signal_log_watermarks_loaded = true;
    }   
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   if(series_total == 0) return;

   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   // --- Precompute each template row's TEXT key once - shared by every TF below. NOT used for
   // --- matching anymore (that's RAW type_enum/raw_params now) - this is display-text only,
   // --- for the watermark key (CSignalLogger persists to a JSON file - genuinely needs text)
   // --- and the debug Print.
    string tmpl_type_key[], tmpl_params_key[];
    ArrayResize(tmpl_type_key, rows);
    ArrayResize(tmpl_params_key, rows);
    for(int row = 0; row < rows; row++)
     {
      tmpl_type_key[row] = m_indicator_template_setting[row].type;
      string pk = "";
      for(int p = 0; p < ArraySize(m_indicator_template_setting[row].params); p++)
         pk += (p > 0 ? "," : "") + m_indicator_template_setting[row].params[p];
      tmpl_params_key[row] = pk;
     }
   // --- Flattened per-(TF,template) state - mirrors CheckCandlePatternAlerts's own
   // --- ti*pattern_count+row indexing.
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
      CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;

      for(int row = 0; row < rows; row++)
       {
        if(tmpl_type_key[row] == "") continue;
        // --- SynIndicatorPlan.md, Dot 3d, 2026-08-18: read the checkbox state from the live
        // --- setting record (kept current by OnClickToggleSoundAlert/MessageAlert) instead of
        // --- re-reading the CTable icon each call - same data, one source of truth.
        bool sound_on   = m_indicator_template_setting[row].sound;
        bool message_on = m_indicator_template_setting[row].message;
        if(!sound_on && !message_on) continue;

        // --- Find THIS TF's own instance of the template (row) - RAW compare
        // --- (type_enum/raw_params), tmpl_type_key/tmpl_params_key below are TEXT kept
        // --- only for the watermark key/debug log, not used for matching anymore.
        CIndicatorDE *ind = NULL;
        for(int ii = 0; ii < ind_total; ii++)
         {
          CIndicatorDE *cand = ind_list.At(ii);
          if(cand == NULL || cand.TypeIndicator() != m_indicator_template_setting[row].type_enum) continue;
          MqlParam cand_params[];
          cand.GetMqlParams(cand_params);
          if(IsEqualMqlParamArrays(cand_params, m_indicator_template_setting[row].raw_params)) { ind = cand; break; }
         }
        if(ind == NULL)
         {
          ::Print("MY DEBUG CGUIPannel::CheckIndicatorAlerts: no match row=", row, " type=", tmpl_type_key[row],
                  " params=", tmpl_params_key[row], " tf=", tf_text);
          continue;
         }
        CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
        // --- NULL here just means this indicator type has no CSignalXxx wired yet in
        // --- GetOrCreateSignal (e.g. ATR) - known, permanent, not worth logging every tick
        // --- (Anhnt, 2026-08-16: used to print unconditionally, flooded the log).
        if(signal == NULL) continue;

        int index = ti * rows + row;
        MqlParam label_params[];
        ind.GetMqlParams(label_params);
        string label   = BuildIndicatorTextLabel(ind.TypeIndicator(), label_params, catalog);
        int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
       // --- TF-qualify the watermark key - a template is shared across every tracked TF, but
       // --- each TF's own flip history must never share a watermark record with another TF's
       // --- (Anhnt, 2026-08-10: used to be type+params only, which only ever worked because
       // --- this method used to check just the chart's own TF).
        string wm_params_key = tmpl_params_key[row] + "|" + tf_text;
       //--- BBands-only: Upper/Lower lines, each backed by CSignalBollinger's OWN real
       //--- persisted history (Layer 1) - safe downcast, ind.TypeIndicator()==IND_BANDS
       //--- already confirms `signal` really is a CSignalBollinger instance. Mid is NOT
       //--- processed here (Anhnt, 2026-07-19): it's now the primary signal itself (see
       //--- CSignalBollinger::ComputeAt), handled by the generic closed-bar/live-bar block
       //--- below like any other indicator - processing it here too would double-fire it.
        if(message_on && ind.TypeIndicator() == IND_BANDS)
         {
          CSignalBollinger *bb = (CSignalBollinger*)signal;
          ProcessBandLine(index, bb, BBAND_LINE_UPPER, "Upper", m_upper_last_seen, seeding, tmpl_type_key[row], wm_params_key, label, tf_text, digits);
          ProcessBandLine(index, bb, BBAND_LINE_LOWER, "Lower", m_lower_last_seen, seeding, tmpl_type_key[row], wm_params_key, label, tf_text, digits);
         }
       //--- Closed-bar path: catch-up of every committed flip newer than the persisted
       //--- per-template-per-TF watermark - fires Sound+Message+CSV same as Live (Anhnt, 2026-08-10).
        datetime wm = m_signal_logger.GetSignalLogWatermark(tmpl_type_key[row], wm_params_key);
        int total = signal.HistoryTotal();
        // --- Throttled: only print when HistoryTotal for THIS (row,TF) actually changes,
        // --- instead of every tick - was flooding the log (Anhnt, 2026-08-16).
        static int dbg_last_total[];
        if(ArraySize(dbg_last_total) != rows * series_total)
         {
          ArrayResize(dbg_last_total, rows * series_total);
          ArrayInitialize(dbg_last_total, -1); // shape changed (or first run) - re-print every slot once
         }
        if(dbg_last_total[index] != total)
         {
          dbg_last_total[index] = total;
          ::Print("MY DEBUG CGUIPannel::CheckIndicatorAlerts: tf=", tf_text, " label=", label, " handle=", ind.Handle(),
                  " HistoryTotal=", total, " watermark=", ::TimeToString(wm, TIME_DATE|TIME_SECONDS),
                  " last_closed_bar_time=", ::TimeToString(::iTime(sym, tf, 1), TIME_DATE|TIME_SECONDS));
         }
        datetime newest_committed = wm;
        for(int idx = 0; idx < total; idx++)
         {
          datetime t = signal.HistoryTime(idx);
          if(t <= wm) continue;
          ENUM_SIGNAL_DIR hdir = signal.HistoryDir(idx);
          bool cb_is_buy = (hdir == SIGNAL_BUY);
          string dir_text = cb_is_buy ? "Buy" : "Sell";
          // --- BBands' own primary signal IS the MidBand cross now (Anhnt, 2026-07-19) -
          // --- name it explicitly so this row can't be confused with the Upper/Lower
          // --- line-cross rows (ProcessBandLine, below) which use the same "Buy"/"Sell" text.
          string cross_text = (ind.TypeIndicator() == IND_BANDS)
                                ? (cb_is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
          string time_text = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
          // --- Bar already closed - look up ITS OWN Close, not the current live price
          // --- (Anhnt, 2026-07-17): map flip_time back to a shift via iBarShift.
          int shift = ::iBarShift(sym, tf, t, false);
          double price = (shift >= 0) ? ::iClose(sym, tf, shift) : 0.0;
          string price_text = ::DoubleToString(price, digits);
          m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "CloseBar", dir_text, label, price_text, cross_text);
          if(message_on)
            CMessage::Out(time_text + ";CloseBar;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
          if(t > newest_committed) newest_committed = t;
         }
        if(newest_committed > wm)
          m_signal_logger.SetSignalLogWatermark(tmpl_type_key[row], wm_params_key, newest_committed);
       //--- Live bar-0 path: fire Sound+Message+CSV on every real direction change.
        ENUM_SIGNAL_DIR live_dir = signal.GetCurrentSignal();
        if(seeding)
          {
          // --- Upper/Lower baselines already seeded by ProcessBandLine above; Mid is this
          // --- very signal (see CSignalBollinger::ComputeAt), seeded right here.
          // --- Baseline = last CloseBar direction (not live_dir) so a real flip that happened
          // --- while the EA was detached still fires on the very next tick's normal compare
          // --- below - no special "fire during seeding" branch needed (Anhnt, 2026-08-16).
          // --- No CloseBar history yet (brand new symbol/indicator) - nothing to seed from,
          // --- fall back to live_dir like before.
          int hist_total = signal.HistoryTotal();
          m_live_signal_last_seen[index] = (hist_total > 0) ? signal.HistoryDir(hist_total - 1) : live_dir;
          continue; // still silent on this very tick - matches "chỉ nạp mem, không bắn gì" (Anhnt)
          }
        if(live_dir == m_live_signal_last_seen[index]) continue;
        m_live_signal_last_seen[index] = live_dir;
        if(live_dir == SIGNAL_NONE) continue; // dropped to no-signal - not alert-worthy itself

        bool is_buy = (live_dir == SIGNAL_BUY);
        if(sound_on)
         {
          // --- Deliberately native ::PlaySound() (via PlaySoundForDirection), NOT CMessage::PlaySound()
          // --- (Anhnt, 2026-07-17 - confirmed by reading Message.mqh): that wrapper
          // --- unconditionally prepends "\Files\" to any filename that isn't one of its own
          // --- built-in SND_* constants, no matter what we pass it.
          // --- Bare filename only resolves against TERMINAL_PATH\Sounds\ (install dir, e.g.
          // --- C:\Program Files\MetaTrader 5\Sounds\) - NOT MQL5\Sounds\, NOT MQL5\Files\Sounds\
          // --- (confirmed 2026-08-13, see FeatureNote/SoundBugNote.md). Any new .wav must be
          // --- copied there manually or it fails silently with GetLastError()=5019.
            PlaySoundForDirection(is_buy);
         }
        if(message_on)
         {
          // --- Field order Time;Live/CloseBar;TF;Indicator;Signal (Anhnt, 2026-07-17) - ";"
          // --- delimited so pasting Journal lines straight into Excel auto-splits into columns,
          // --- same convention as Signal_Log_<SYMBOL>.csv's own sep=; fix.
            string dir_text  = is_buy ? "Buy" : "Sell";
          // --- Same MidBand naming as the closed-bar loop above (Anhnt, 2026-07-19).
            string cross_text = (ind.TypeIndicator() == IND_BANDS)
                                ? (is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
            string time_text = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
          // --- Bar 0 hasn't closed yet - treat the CURRENT price as its "Close" (Anhnt, 2026-07-17).
            double price = ::iClose(sym, tf, 0);
            string price_text = ::DoubleToString(price, digits);
            CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
            m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "Live", dir_text, label, price_text, cross_text);
         }
       }
     }
  }
 void CGUIPannel::CheckCandlePatternAlerts(void)
  {
   MqlRates bar_0_temp;
   ::ZeroMemory(bar_0_temp);
   bar_0_temp.open = ::iOpen(::Symbol(), ::Period(), 0);
   bar_0_temp.high = ::iHigh(::Symbol(), ::Period(), 0);
   bar_0_temp.low = ::iLow(::Symbol(), ::Period(), 0);
   bar_0_temp.close = ::iClose(::Symbol(), ::Period(), 0);
   bar_0_temp.time = ::iTime(::Symbol(), ::Period(), 0);

    //string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
    int debug_handle = FileOpen(g_ea_folder + "/CheckCandlePatternAlerts_Debug.log", FILE_WRITE | FILE_TXT | FILE_ANSI);
    string timestamp = ::TimeToString(::TimeCurrent(), TIME_SECONDS);

    if(debug_handle != INVALID_HANDLE) FileWrite(debug_handle, "[" + timestamp + "] CGUIPannel::CheckCandlePatternAlerts START\n");
    if(debug_handle != INVALID_HANDLE) FileWrite(debug_handle, "[" + timestamp + "] m_BarPatterns_Control = " + (string)(m_BarPatterns_Control != NULL ? "OK" : "NULL") + "\n");
    if(debug_handle != INVALID_HANDLE) FileWrite(debug_handle, "[" + timestamp + "] m_BarTimeSeriesCollection = " + (string)(m_BarTimeSeriesCollection != NULL ? "OK" : "NULL") + "\n");

    if(m_BarPatterns_Control == NULL || m_BarTimeSeriesCollection == NULL)
     {
        if(debug_handle != INVALID_HANDLE) FileWrite(debug_handle, "[" + timestamp + "] Early return - NULL pointers!\n");
        if(debug_handle != INVALID_HANDLE) FileClose(debug_handle);
         return;
     }
    int pattern_count = ArraySize(m_pattern_types);
    if(debug_handle != INVALID_HANDLE) FileWrite(debug_handle, "[" + timestamp + "] pattern_count = " + (string)pattern_count + "\n");
    if(pattern_count == 0)
     {
        if(debug_handle != INVALID_HANDLE) FileClose(debug_handle);
        return;
     }
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
     // --- CloseBar direction-change tracker (Anhnt, 2026-08-11) - separate from
     // --- m_candle_pattern_last_seen above (that one is Live-only, reset every new bar); this
     // --- one persists across bars, same grow-only sizing/indexing.
      if(min_required_size > 0 && ArraySize(m_candle_pattern_closebar_last_dir) < min_required_size)
       {
        ArrayResize(m_candle_pattern_closebar_last_dir, min_required_size);
        for(int i = 0; i < min_required_size; i++)
          m_candle_pattern_closebar_last_dir[i] = (ENUM_PATTERN_DIRECTION)WRONG_VALUE;
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
    // --- CLOSED bar path (Anhnt, 2026-08-10): fires Sound+Message+CSV (status "CloseBar",
    // --- source "Candle") for every committed pattern newer than a per-(pattern type, TF)
    // --- watermark - same shape as CheckIndicatorAlerts's own Closed-bar loop. Reads directly
    // --- from m_BarTimeSeriesCollection.GetListAllPatterns() (Layer 1's real per-series data,
    // --- same source CSignalBridgeWriter/the CandleInfo popup already use), NOT through
    // --- m_BarPatterns_Control/DetectPatternOnBar0 - that pair is still the separate, paused
    // --- Live bar-0 bug (see FeatureNote/UpdateCandlePattern.md "Bug Live") and is untouched here.
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

         for(int row = 0; row < pattern_count; row++)
          {
           ENUM_PATTERN_TYPE pattern_cb = m_pattern_types[row];
           bool sound_on_cb   = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(3, row) == 0);
           bool message_on_cb = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(4, row) == 0);
           if(!sound_on_cb && !message_on_cb) continue;

           string wm_type_key_cb   = "Pattern_" + EnumToString(pattern_cb);
           datetime wm_cb = m_signal_logger.GetSignalLogWatermark(wm_type_key_cb, tf_text_cb);
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
             bool is_buy_cb = (pdir_cb == PATTERN_DIRECTION_BULLISH);
             // --- m_candle_pattern_closebar_last_dir kept updated even though CloseBar no longer
             // --- gates Sound on it (Anhnt, 2026-08-14: CloseBar Sound is just "NewBar.wav" via
             // --- PlaySoundCloseBar now, no longer per-flip) - state still maintained in case a
             // --- future feature needs "did this (pattern type, TF) actually flip on CloseBar".
             int index_cb = ti * pattern_count + row;
             m_candle_pattern_closebar_last_dir[index_cb] = pdir_cb;
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

             if(pt_cb > newest_committed_cb) newest_committed_cb = pt_cb;
            }
           if(newest_committed_cb > wm_cb)
             m_signal_logger.SetSignalLogWatermark(wm_type_key_cb, tf_text_cb, newest_committed_cb);
          }
        }
      }
    // Iterate each timeframe
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

       // Iterate each pattern type
        for(int row = 0; row < pattern_count; row++)
         {
          ENUM_PATTERN_TYPE pattern = m_pattern_types[row];
          // Check Sound alert enabled (col 3, image index 0 = ON)
           bool sound_on = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(3, row) == 0);
          // Check Message alert enabled (col 4)
           bool message_on = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(4, row) == 0);
           if(!sound_on && !message_on) continue;
         // Detect pattern on live bar 0 for this timeframe
          ENUM_PATTERN_DIRECTION current = DetectPatternOnBar0(pattern, tf, bar_0_temp);
          int index = ti * pattern_count + row;  // ← flatten index
         // Ensure array can hold this index - grow on-the-fly if needed
          if(index >= ArraySize(m_candle_pattern_last_seen))
            ArrayResize(m_candle_pattern_last_seen, index + 1);
         // Compare with last state (2D array [tf_index][pattern_index])
          if(current != m_candle_pattern_last_seen[index])
           {
            if(current != WRONG_VALUE)
             {
              // New pattern formed on bar 0
               bool is_bullish = (current == PATTERN_DIRECTION_BULLISH);
               if(sound_on)
                 PlaySoundForDirection(is_bullish);
               if(message_on)
                {
                 string dir_text = is_bullish ? "Buy" : "Sell";
                 string pattern_name = m_pattern_display_names[row];
                 string tf_text = TimeframeDescription(tf);
                 string time_text = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);

                 // Get candle count from pattern type (static mapping for live bar detection)
                 int candle_count = GetPatternCandleCount(pattern);

                 CMessage::Out(time_text + " - " + pattern_name + " " + dir_text + " (" + (string)candle_count + " candle" + (candle_count > 1 ? "s" : "") + ") " + tf_text);
               }

             }
            m_candle_pattern_last_seen[index] = current;
           }
           if(debug_handle != INVALID_HANDLE) FileWrite(debug_handle, "[" + timestamp + "] pattern detected: current=" + (string)current + " last=" + (string)m_candle_pattern_last_seen[index] + "\n");
         }
      }
    if(debug_handle != INVALID_HANDLE) FileClose(debug_handle);
  }
 // Get candle count for pattern type (static mapping)
 int CGUIPannel::GetPatternCandleCount(ENUM_PATTERN_TYPE pattern_type)
  {
   // Single-candle patterns
   if(pattern_type == PATTERN_TYPE_HAMMER ||
      pattern_type == PATTERN_TYPE_HANGING_MAN ||
      pattern_type == PATTERN_TYPE_INVERTED_HAMMER ||
      pattern_type == PATTERN_TYPE_SHOOTING_STAR ||
      pattern_type == PATTERN_TYPE_DOJI ||
      pattern_type == PATTERN_TYPE_DRAGONFLY_DOJI ||
      pattern_type == PATTERN_TYPE_GRAVESTONE_DOJI ||
      pattern_type == PATTERN_TYPE_PIN_BAR)
    return 1;

   // 2-candle patterns
   if(pattern_type == PATTERN_TYPE_HARAMI ||
      pattern_type == PATTERN_TYPE_HARAMI_CROSS ||
      pattern_type == PATTERN_TYPE_ENGULFING ||
      pattern_type == PATTERN_TYPE_TWEEZER ||
      pattern_type == PATTERN_TYPE_PIERCING_LINE ||
      pattern_type == PATTERN_TYPE_DARK_CLOUD_COVER ||
      pattern_type == PATTERN_TYPE_RAILS ||
      pattern_type == PATTERN_TYPE_INSIDE_BAR ||
      pattern_type == PATTERN_TYPE_OUTSIDE_BAR)
    return 2;

   // 3-candle patterns (default)
   return 3;
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
 // --- BBands-only (Anhnt, 2026-07-17): processes ONE line's REAL persisted history from
 // --- CSignalBollinger (Layer 1) - Closed-bar catch-up mirrors the primary signal's own loop
 // --- exactly (log-only, watermark keyed by params_key+"|"+line_name so it never collides
 // --- with the primary signal's own watermark entry), then a Live-bar check (transient
 // --- last_seen[] vs LineCurrentSignal()) fires Message+CSV (deliberately no Sound, matching
 // --- the earlier scoped-down decision) on every real change.
 void CGUIPannel::ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name, ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key, const string label, const string tf_text, const int digits)
  {
   CIndicatorDE *ind = bb.GetIndicator();
   if(ind == NULL) return;
   string line_params_key = params_key + "|" + line_name;

   datetime wm = m_signal_logger.GetSignalLogWatermark(type_key, line_params_key);
   int total = bb.LineHistoryTotal(line_idx);
   datetime newest_committed = wm;
   for(int idx = 0; idx < total; idx++)
    {
      datetime t = bb.LineHistoryTime(line_idx, idx);
      if(t <= wm) continue;
      ENUM_SIGNAL_DIR hdir = bb.LineHistoryDir(line_idx, idx);
      string dir_text   = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
      string cross_text = (hdir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
      string time_text  = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
      int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
      double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
      string price_text = ::DoubleToString(price, digits);
      m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "CloseBar", dir_text, label, price_text, cross_text);
      // --- No Sound here (deliberate scoped-down decision, matches the Live block below) - only
      // --- Message+CSV now fire for CloseBar too (Anhnt, 2026-08-10).
      CMessage::Out(time_text + ";CloseBar;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
      if(t > newest_committed) newest_committed = t;
    }
   if(newest_committed > wm)
      m_signal_logger.SetSignalLogWatermark(type_key, line_params_key, newest_committed);

   ENUM_SIGNAL_DIR live_dir = bb.LineCurrentSignal(line_idx);
   if(seeding)
    {
      // --- Same reasoning as CheckIndicatorAlerts' own seeding block (Anhnt, 2026-08-16):
      // --- baseline = last CloseBar direction of THIS line, not live_dir, so a flip during
      // --- Detach still fires on the next tick's normal compare below.
      int line_hist_total = bb.LineHistoryTotal(line_idx);
      last_seen[row] = (line_hist_total > 0) ? bb.LineHistoryDir(line_idx, line_hist_total - 1) : live_dir;
      return; // still silent on this very tick
    }
   if(live_dir == last_seen[row]) return; // no change
   last_seen[row] = live_dir;
   if(live_dir == SIGNAL_NONE) return; // dropped to exactly-on-the-line - not report-worthy itself

   // --- Same Time;Live;TF;Indicator;Signal shape as the primary message, plus a 6th
   // --- ";"-delimited field naming which line/direction triggered it (Anhnt, 2026-07-17:
   // --- "viết ra Journal như nào thì cũng viết ra Signal_Log.csv y như thế").
   string dir_text   = (live_dir == SIGNAL_BUY) ? "Buy" : "Sell";
   string cross_text = (live_dir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
   string time_text  = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
   double price = ::iClose(ind.Symbol(), ind.Timeframe(), 0);
   string price_text = ::DoubleToString(price, digits);
   CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
   m_signal_logger.WriteSignalLogRow(time_text, "Indicator", tf_text, "Live", dir_text, label, price_text, cross_text);
  }
#endif // CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
