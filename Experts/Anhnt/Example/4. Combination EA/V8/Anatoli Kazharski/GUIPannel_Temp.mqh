//+------------------------------------------------------------------+
//|                                               GUIPannel_Temp.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TEMP_MQH
#define CGUIPANNEL_TEMP_MQH
// --- Rewrites Config_Setting.json with a fresh "markers" section, carrying "symbols_tf"/
    // --- "templates" through UNCHANGED (raw text, not re-parsed/re-built) via
    // --- IndicatorConfig_ExtractRawSection - this function only owns "markers", so it must
    // --- never destroy the OTHER sections CTimeSeriesEngine owns, symmetric with how that
    // --- engine's own writers now preserve "markers" when THEY rewrite this same file.
    void CGUIPannel::SaveMarkerSettingsToJSON(void)
     {
      string existing   = IndicatorConfig_ReadWholeFile("Config_Setting.json");
      string symbols_tf = IndicatorConfig_ExtractRawSection(existing, "symbols_tf");
      string templates   = IndicatorConfig_ExtractRawSection(existing, "templates");

      string json = "{\n";
      if(symbols_tf != "") json += " \"symbols_tf\": " + symbols_tf + ",\n";
      if(templates  != "") json += " \"templates\": "  + templates  + ",\n";
      string buy_sound_esc  = m_marker_buy_sound_file;
      string sell_sound_esc = m_marker_sell_sound_file;
      string sound_folder_esc = m_marker_sound_folder;
      ::StringReplace(buy_sound_esc,  "\\", "\\\\");
      ::StringReplace(sell_sound_esc, "\\", "\\\\");
      ::StringReplace(sound_folder_esc, "\\", "\\\\");
      json += " \"markers\": { \"single_indicator_buy_arrow_code\": "  + (string)m_marker_single_indicator_buy_code +
              ", \"single_indicator_sell_arrow_code\": " + (string)m_marker_single_indicator_sell_code +
              ", \"multi_indicator_buy_arrow_code\": "   + (string)m_marker_multi_indicator_buy_code +
              ", \"multi_indicator_sell_arrow_code\": "  + (string)m_marker_multi_indicator_sell_code +
              ", \"pattern_buy_arrow_code\": "  + (string)m_marker_pattern_buy_code +     
              ", \"pattern_sell_arrow_code\": " + (string)m_marker_pattern_sell_code  +    
              ", \"combo_buy_arrow_code\": "    + (string)m_marker_combo_buy_code +       
              ", \"combo_sell_arrow_code\": "   + (string)m_marker_combo_sell_code +      
              ", \"buy_color\": "        + (string)(int)m_marker_buy_color +
              ", \"sell_color\": "       + (string)(int)m_marker_sell_color +
              ", \"nonrelated_color\": " + (string)(int)m_marker_nonrelated_color +
              ", \"buy_sound_file\": \""  + buy_sound_esc  + "\"" +
              ", \"sell_sound_file\": \"" + sell_sound_esc + "\"" +
              ", \"sound_folder\": \""    + sound_folder_esc + "\"" + " }\n}";

      int fh = ::FileOpen("Config_Setting.json", FILE_TXT|FILE_WRITE|FILE_ANSI);
      if(fh == INVALID_HANDLE) return;
      ::FileWriteString(fh, json);
      ::FileClose(fh);
     }   
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
#endif // CGUIPANNEL_TEMP_MQH
