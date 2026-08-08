//+------------------------------------------------------------------+
//|                                         GUIPannel_JSONConfig.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_JSONCONFIG_MQH
#define CGUIPANNEL_JSONCONFIG_MQH
 //Helper for OnClickSaveIndicators() and OnClickSaveSymbolTF() and  
 // --- Shared by OnClickSaveIndicators() and OnClickSaveSymbolTF(): builds the Buy/Sell
 // --- lookup arrays from m_table_indicator_SymbolTFSeting and hands them to
 // --- CTimeSeriesEngine::SaveConfigurationToJSON, which merges them into each "symbols_tf"
 // --- entry of indicators_config.json.
 void CGUIPannel::SaveGUIConfigToJSON(void)
  {
    if(m_time_series_engine == NULL) return;
    
    ::Print(__FUNCTION__, " > Starting save config");
    
    // Layer 1: Indicator + SymbolTF settings (Layer 1 tự collect data)
    bool result1 = m_time_series_engine.SaveConfigurationToJSON("Config_Setting.json");
    ::Print(__FUNCTION__, " > SaveConfigurationToJSON: ", (result1 ? "OK" : "FAILED"));
    
    // Layer 2: Pattern Alert Config (Sound/Message checkboxes)
    SavePatternAlertConfigToJSON();
    ::Print(__FUNCTION__, " > SavePatternAlertConfigToJSON: OK");
    
    // Layer 2: Marker Settings (8 icon codes)
    SaveMarkerSettingsToJSON();
    ::Print(__FUNCTION__, " > SaveMarkerSettingsToJSON: OK");
  }  
 void CGUIPannel::SavePatternAlertConfigToJSON(void)
  {
   // Build full file path: MQL5/Files/{EA_FOLDER}/Config_Setting.json
    string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
    string full_path = ea_folder + "/Config_Setting.json";
   // Preserve existing sections from Config_Setting.json
    string existing   = IndicatorConfig_ReadWholeFile(full_path);
    string symbols_tf = IndicatorConfig_ExtractRawSection(existing, "symbols_tf");
    string templates  = IndicatorConfig_ExtractRawSection(existing, "templates");
    string markers    = IndicatorConfig_ExtractRawSection(existing, "markers");

    string json = "{\n";
    if(symbols_tf != "") json += " \"symbols_tf\": " + symbols_tf + ",\n";
    if(templates  != "") json += " \"templates\": "  + templates  + ",\n";
    if(markers    != "") json += " \"markers\": "    + markers    + ",\n";
  
   // Build "pattern_alerts" section - Global settings (not symbol/TF specific)
   // Each pattern type has one Sound + Message alert setting that applies to both BUY and SELL
    int pattern_count = ArraySize(m_pattern_types);
    json += " \"pattern_alerts\": {\n";
    for(int i = 0; i < pattern_count; i++)
    {
     if(i > 0) json += ",\n";
     string pattern_name = m_pattern_display_names[i];
     bool sound_enabled   = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(3, i) == 0);  // col 3 = Sound checkbox
     bool message_enabled = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(4, i) == 0);  // col 4 = Message checkbox
     json += "  \"" + pattern_name + "\": { \"sound\": " + (sound_enabled ? "true" : "false") +
             ", \"message\": " + (message_enabled ? "true" : "false") + " }";
    }
   json += "\n }\n}";
    int fh = FileOpen(full_path, FILE_TXT | FILE_WRITE | FILE_ANSI);
    if(fh == INVALID_HANDLE)
     {
      Print("CGUIPannel::SavePatternAlertConfigToJSON > cannot open ", full_path, " for writing, err=", GetLastError());
      return;
     }
    FileWriteString(fh, json);
    FileClose(fh);
    Print("CGUIPannel::SavePatternAlertConfigToJSON > saved pattern alert settings to ", full_path);
  }
 void CGUIPannel::SaveMarkerSettingsToJSON(void)
  {
    string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
    string full_path = ea_folder + "/Config_Setting.json";

    string existing   = IndicatorConfig_ReadWholeFile(full_path);
    string symbols_tf = IndicatorConfig_ExtractRawSection(existing, "symbols_tf");
    string templates  = IndicatorConfig_ExtractRawSection(existing, "templates");
    string pattern_alerts = IndicatorConfig_ExtractRawSection(existing, "pattern_alerts");

    string json = "{\n";
    if(symbols_tf != "") json += " \"symbols_tf\": " + symbols_tf + ",\n";
    if(templates  != "") json += " \"templates\": "  + templates  + ",\n";
    if(pattern_alerts != "") json += " \"pattern_alerts\": " + pattern_alerts + ",\n";
  
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
  
    int fh = FileOpen(full_path, FILE_TXT | FILE_WRITE | FILE_ANSI);
    if(fh == INVALID_HANDLE)
    {
        Print("CGUIPannel::SaveMarkerSettingsToJSON > cannot open ", full_path, " for writing, err=", GetLastError());
        return;
    }
    FileWriteString(fh, json);
    FileClose(fh);
    Print("CGUIPannel::SaveMarkerSettingsToJSON > saved marker settings to ", full_path);
  }

#endif // CGUIPANNEL_JSONCONFIG_MQH
