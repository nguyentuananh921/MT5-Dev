//+------------------------------------------------------------------+
//|                                               GUIPannel_Temp.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TEMP_MQH
#define CGUIPANNEL_TEMP_MQH  
 // --- Minimal "find an int value after a JSON key" scan - Config_Setting.json's "markers" section is only ever
 // --- machine-written by SaveMarkerSettings() above, so a full JSON parser is unwarranted.
 bool CGUIPannel::JsonIntValue(const string content, const string key, int &value)
  {
   int pos = ::StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
   int colon = ::StringFind(content, ":", pos);
   if(colon < 0) return false;
   int len = ::StringLen(content);
   int i = colon + 1;
   while(i < len && ::StringGetCharacter(content, i) == ' ') i++;
   int start = i;
   while(i < len)
    {
      ushort ch = ::StringGetCharacter(content, i);
      if((ch < '0' || ch > '9') && ch != '-') break;
      i++;
    }
   string num = ::StringSubstr(content, start, i - start);
   if(num == "") return false;
   value = (int)::StringToInteger(num);
   return true;
  }
 // --- Same idea as JsonIntValue but for a quoted string value - backslashes in Windows
 // --- paths are escaped ("\\") on write (SaveMarkerSettings) and un-escaped here on read.
 bool CGUIPannel::JsonStringValue(const string content, const string key, string &value)
  {
   int pos = ::StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
   int colon = ::StringFind(content, ":", pos);
   if(colon < 0) return false;
   int q1 = ::StringFind(content, "\"", colon + 1);
   if(q1 < 0) return false;
   int q2 = ::StringFind(content, "\"", q1 + 1);
   if(q2 < 0) return false;
   value = ::StringSubstr(content, q1 + 1, q2 - q1 - 1);
   ::StringReplace(value, "\\\\", "\\");
   return true;
  }
 // --- Attaches SignalMarkers.mq5 to this chart if not already running (checked by short
 // --- name, set via IndicatorSetString(INDICATOR_SHORTNAME,...) in the indicator's own
 // --- OnInit) - idempotent, safe to call defensively on every OnInitEvent branch, same
 // --- style as CTradingLevelBubble::EnsureCreated() being polled unconditionally.
 void CGUIPannel::EnsureMarkerIndicatorAttached(void)
  {
   int total = ::ChartIndicatorsTotal(m_chart_id, 0);
   for(int i = 0; i < total; i++)
      if(::StringFind(::ChartIndicatorName(m_chart_id, 0, i), "SignalMarkers") == 0)
         return; // already attached

   int h = ::iCustom(NULL, 0, "Vendors\\Anhnt\\Custom Buildin\\SignalMarkers",
                      m_marker_single_indicator_buy_code, m_marker_single_indicator_sell_code,
                      m_marker_multi_indicator_buy_code, m_marker_multi_indicator_sell_code,
                         m_marker_pattern_buy_code, m_marker_pattern_sell_code,
                         m_marker_buy_color, m_marker_sell_color, m_marker_nonrelated_color);
      if(h == INVALID_HANDLE)
        {
         ::Print(__FUNCTION__, " > iCustom(SignalMarkers) failed, error ", ::GetLastError());
         return;
        }
      if(!::ChartIndicatorAdd(m_chart_id, 0, h))
         ::Print(__FUNCTION__, " > ChartIndicatorAdd(SignalMarkers) failed, error ", ::GetLastError());
  }
    // --- "Refresh" button next to the sound-folder path: read the CURRENT text box value (the
    // --- user may have just typed a new folder), re-scan it, and rebuild both combos in place.
    void CGUIPannel::OnClickChangeSoundFolder(void)
     {
      //m_marker_sound_folder = m_edit_sound_folder.GetValue();

      string files[];
      ScanSoundFolder(files);
      int n_files = ArraySize(files);

      // --- Rebuilding() only replaces the ITEM CONTENT - it does NOT resize the dropdown's own
      // --- viewport (that's a one-time YSize() read at CreateComboBox() time, same trap as
      // --- CreateMarkerTabComboBox's own comment) - without redoing it here, a folder that grows
      // --- from a handful of files to 61 keeps the OLD tiny viewport, squeezing the scrollbar
      // --- thumb down to almost nothing (Anhnt, 2026-07-17: exactly this happened on Refresh).
      int list_h = 18 * n_files + 4;
      if(list_h > 300) list_h = 300;
      m_combo_buy_sound.GetListViewPointer().YSize(list_h);
      m_combo_sell_sound.GetListViewPointer().YSize(list_h);

      m_combo_buy_sound.GetListViewPointer().Rebuilding(n_files);
      m_combo_sell_sound.GetListViewPointer().Rebuilding(n_files);
      for(int i = 0; i < n_files; i++)
        {
         m_combo_buy_sound.SetValue(i, files[i]);
         m_combo_sell_sound.SetValue(i, files[i]);
        }
      m_combo_buy_sound.SelectItem(0);
      m_combo_sell_sound.SelectItem(0);
      m_combo_buy_sound.GetListViewPointer().Update(true);
      m_combo_sell_sound.GetListViewPointer().Update(true);
     }
    // --- Detaches SignalMarkers.mq5 if attached - ChartIndicatorAdd() makes it an independent
    // --- chart program, so removing THIS EA does NOT auto-detach it. Called from
    // --- ReattachSignalMarkersIndicator() (style change) AND from OnDeinitEvent on final removal.
    // --- BugNote 2026-07-18: "SignalMarkers survives Remove EA" - the old scan-by-
    // --- ChartIndicatorsTotal()/ChartIndicatorName() approach reads 0/garbage when called from
    // --- OnDeinit() while THIS chart's own program is mid-removal (confirmed empirically: the
    // --- native Indicators List dialog showed SignalMarkers very much still attached at the
    // --- exact moment our own scan reported total=0). SignalMarkers.mq5 sets its own short name
    // --- deterministically ("SignalMarkers(" + Symbol() + ")", see SignalMarkers.mq5 line ~102) -
    // --- delete by that known name directly instead of trusting the unreliable enumeration.
    // --- ChartIndicatorDelete() itself also reports a false/error return here (confirmed
    // --- error 4022) even though the deletion genuinely takes effect - another OnDeinit-timing
    // --- artifact, not a real failure, so the return value is intentionally not checked.
    void CGUIPannel::RemoveMarkerIndicator(void)
     {
      ::ChartIndicatorDelete(m_chart_id, 0, "SignalMarkers(" + ::Symbol() + ")");
     }
    // --- Detach + re-attach with the CURRENT m_marker_* values - MT5 has no live-input-update
    // --- API for a running indicator, so a style change means recreate it.
    void CGUIPannel::ReattachSignalMarkersIndicator(void)
     {
      RemoveMarkerIndicator();
      EnsureMarkerIndicatorAttached();
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
         m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Closed", cross_text);
         if(t > newest_committed) newest_committed = t;
        }
      if(newest_committed > wm)
         m_signal_logger.SetSignalLogWatermark(type_key, line_params_key, newest_committed);

      ENUM_SIGNAL_DIR live_dir = bb.LineCurrentSignal(line_idx);
      if(seeding)
        {
         last_seen[row] = live_dir; // baseline only, never fires on first sight
         return;
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
      m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Live", cross_text);
     }
#endif // CGUIPANNEL_TEMP_MQH
