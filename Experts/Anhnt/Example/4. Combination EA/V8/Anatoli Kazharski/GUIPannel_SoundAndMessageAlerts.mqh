//+------------------------------------------------------------------+
//|                           GUIPannel_SoundAndMessageAlerts.mqh    |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
#define CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH 
 // --- CLOSED bar (HistoryTime/HistoryDir): never Sound/Message - the chart Marker already
 // --- shows these visually. Only appended to Signal_Log.csv (status "Closed"), gated by a
 // --- per-template watermark (m_wm_*, persisted to Signal_Log_Watermark_<SYMBOL>_<TF>.json)
 // --- so a restart's SyncHistory backfill catches up the CSV without ever duplicating a row
 // --- already on disk, and without ever making noise for old history.
 // --- LIVE bar 0 (GetCurrentSignal): the still-forming bar can flip back and forth several
 // --- times before it closes - each REAL change (vs m_live_signal_last_seen[row]) fires
 // --- Sound+Message+CSV (status "Live") immediately with TimeCurrent(), since there's no
 // --- fixed bar time yet. Runs every OnTimerEvent tick - cheap, no file I/O unless something
 // --- actually changed.
 void CGUIPannel::CheckIndicatorAlerts(void)
  {
   if(m_time_series_engine == NULL) return;
   int rows = ArraySize(m_table_indicator_ptrs);
   if(rows == 0) return;
   if(!m_signal_log_watermarks_loaded)
    {
      m_signal_logger.LoadSignalLogWatermarks();
      m_signal_log_watermarks_loaded = true;
    }
   int prev_size = ArraySize(m_live_signal_last_seen);
   bool seeding = (prev_size != rows); // new rows just appeared - seed their baseline, don't fire
   if(seeding)
    {
      ArrayResize(m_live_signal_last_seen, rows);
      ArrayResize(m_upper_last_seen, rows);
      ArrayResize(m_lower_last_seen, rows);
    }
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int row = 0; row < rows; row++)
    {
     CIndicatorDE *ind = m_table_indicator_ptrs[row];
     if(ind == NULL) continue;
     CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
     if(signal == NULL) continue;

     bool sound_on   = ((int)m_table_indicator_template.SelectedImageIndex(5, row) == 0);
     bool message_on = ((int)m_table_indicator_template.SelectedImageIndex(6, row) == 0);
     if(!sound_on && !message_on) continue;

     string label   = BuildIndicatorLabel(ind, catalog);
     string tf_text = TimeframeDescription(ind.Timeframe());
     int digits = (int)::SymbolInfoInteger(ind.Symbol(), SYMBOL_DIGITS);
     string type_key, params_key;
     BuildTemplateMatchKey(ind, catalog, type_key, params_key);
     //--- BBands-only: Upper/Lower lines, each backed by CSignalBollinger's OWN real
     //--- persisted history (Layer 1) - safe downcast, ind.TypeIndicator()==IND_BANDS
     //--- already confirms `signal` really is a CSignalBollinger instance. Mid is NOT
     //--- processed here (Anhnt, 2026-07-19): it's now the primary signal itself (see
     //--- CSignalBollinger::ComputeAt), handled by the generic closed-bar/live-bar block
     //--- below like any other indicator - processing it here too would double-fire it.
      if(message_on && ind.TypeIndicator() == IND_BANDS)
       {
        CSignalBollinger *bb = (CSignalBollinger*)signal;
        ProcessBandLine(row, bb, BBAND_LINE_UPPER, "Upper", m_upper_last_seen, seeding, type_key, params_key, label, tf_text, digits);
        ProcessBandLine(row, bb, BBAND_LINE_LOWER, "Lower", m_lower_last_seen, seeding, type_key, params_key, label, tf_text, digits);
       }
     //--- Closed-bar path: log-only catch-up of every committed flip newer than the
     //--- persisted per-template watermark - never Sound/Message.
      datetime wm = m_signal_logger.GetSignalLogWatermark(type_key, params_key);
      int total = signal.HistoryTotal();
      datetime newest_committed = wm;
      for(int idx = 0; idx < total; idx++)
       {
        datetime t = signal.HistoryTime(idx);
        if(t <= wm) continue;
        ENUM_SIGNAL_DIR hdir = signal.HistoryDir(idx);
        string dir_text = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
        // --- BBands' own primary signal IS the MidBand cross now (Anhnt, 2026-07-19) -
        // --- name it explicitly so this row can't be confused with the Upper/Lower
        // --- line-cross rows (ProcessBandLine, below) which use the same "Buy"/"Sell" text.
        string cross_text = (ind.TypeIndicator() == IND_BANDS)
                              ? ((hdir == SIGNAL_BUY) ? "Cross Up MidBand" : "Cross Down MidBand") : "";
        string time_text = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
        // --- Bar already closed - look up ITS OWN Close, not the current live price
        // --- (Anhnt, 2026-07-17): map flip_time back to a shift via iBarShift.
        int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
        double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
        string price_text = ::DoubleToString(price, digits);
        m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Closed", cross_text);
        if(t > newest_committed) newest_committed = t;
       }
      if(newest_committed > wm)
        m_signal_logger.SetSignalLogWatermark(type_key, params_key, newest_committed);
     //--- Live bar-0 path: fire Sound+Message+CSV on every real direction change.
      ENUM_SIGNAL_DIR live_dir = signal.GetCurrentSignal();
      if(seeding)
        {
        // --- Upper/Lower baselines already seeded by ProcessBandLine above; Mid is this
        // --- very signal (see CSignalBollinger::ComputeAt), seeded right here.
        m_live_signal_last_seen[row] = live_dir; // baseline only, never fires on first sight
        continue;
        }
      if(live_dir == m_live_signal_last_seen[row]) continue;
      m_live_signal_last_seen[row] = live_dir;
      if(live_dir == SIGNAL_NONE) continue; // dropped to no-signal - not alert-worthy itself

      bool is_buy = (live_dir == SIGNAL_BUY);
      if(sound_on)
       {
        // --- Deliberately native ::PlaySound(), NOT CMessage::PlaySound() (Anhnt,
        // --- 2026-07-17 - confirmed by reading Message.mqh): that wrapper unconditionally
        // --- prepends "\Files\" to any filename that isn't one of its own built-in SND_*
        // --- constants, no matter what we pass it - so it can NEVER reach a file sitting in
        // --- MQL5\Sounds\ (only MQL5\Files\...\ - a different sandbox from FileFindFirst/
        // --- FileOpen, which only reach MQL5\Files\ - see the Sound-picker combobox's own
        // --- ScanSoundFolder). The chosen .wav needs to physically exist in MQL5\Sounds\
        // --- (copied once, not auto-synced) - native ::PlaySound(bare filename) resolves
        // --- against that folder directly, with no wrapper in the way.
          string file = is_buy ? m_marker_buy_sound_file : m_marker_sell_sound_file;
          if(file != "")
            ::PlaySound(file);
       }
      if(message_on)
       {
        // --- Field order Time;Live/Closed;TF;Indicator;Signal (Anhnt, 2026-07-17) - ";"
        // --- delimited so pasting Journal lines straight into Excel auto-splits into columns,
        // --- same convention as Signal_Log.csv's own sep=; fix. Closed bars never reach this
        // --- branch at all (log-only, see the loop above) - every message printed here IS a
        // --- Live bar-0 event, hence the literal "Live" in the 2nd field.
          string dir_text  = is_buy ? "Buy" : "Sell";
        // --- Same MidBand naming as the closed-bar loop above (Anhnt, 2026-07-19).
          string cross_text = (ind.TypeIndicator() == IND_BANDS)
                              ? (is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
          string time_text = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
        // --- Bar 0 hasn't closed yet - treat the CURRENT price as its "Close" (Anhnt, 2026-07-17).
          double price = ::iClose(ind.Symbol(), ind.Timeframe(), 0);
          string price_text = ::DoubleToString(price, digits);
          CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
          m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Live", cross_text);
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

    string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
    int debug_handle = FileOpen(ea_folder + "/CheckCandlePatternAlerts_Debug.log", FILE_WRITE | FILE_TXT | FILE_ANSI);
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
         // Compare with last state (2D array [tf_index][pattern_index])
          if(current != m_candle_pattern_last_seen[index])
           {
            if(current != WRONG_VALUE)
             {
              // New pattern formed on bar 0
               bool is_bullish = (current == PATTERN_DIRECTION_BULLISH);
               if(sound_on)
                {
                 string sound_file = is_bullish ? m_marker_buy_sound_file : m_marker_sell_sound_file;
                 if(sound_file != "")
                  ::PlaySound(sound_file);
                }
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
#endif // CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
