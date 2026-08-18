//+------------------------------------------------------------------+
//|                                         GUIPannel_JSONConfig.mqh |
//|      Implementation of JSON config and save setting of GUI Pannel|
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_JSONCONFIG_MQH
#define CGUIPANNEL_JSONCONFIG_MQH
 #include "GUIPannel.mqh"
 // --- Layer 2 takes ownership of buy/sell/sound/message straight from what Layer 1 just
 // --- parsed (SeparateLayer_Plan.md, Cách B) - simple copy, Layer 1 already did the real
 // --- work (parsing + identity mirror + series/indicator creation).
 void CGUIPannel::SetLoadedIndicatorSettings(SJsonIndicatorEntry &entries[], SJsonSymbolTF &symbols_tf[])
  {
   // --- ArrayCopy() can't be used here - structs holding a string/dynamic-array member
   // --- aren't POD, MQL5's built-in refuses them ("structures or classes containing objects
   // --- are not allowed"). Per-element struct assignment (=) works fine though.
   int tmpl_total = ArraySize(entries);
   ArrayResize(m_indicator_template_setting, tmpl_total);
   for(int i = 0; i < tmpl_total; i++)
      m_indicator_template_setting[i] = entries[i];
   int sf_total = ArraySize(symbols_tf);
   ArrayResize(m_symbol_tf_Setting, sf_total);
   for(int i = 0; i < sf_total; i++)
      m_symbol_tf_Setting[i] = symbols_tf[i];
  }
 //Helper for OnClickSaveIndicators() and OnClickSaveSymbolTF() and
 // --- Shared by OnClickSaveIndicators() and OnClickSaveSymbolTF(): builds the Buy/Sell/Sound/
 // --- Message lookup arrays from the live checkbox state (SymbolTF table + Indicator table)
 // --- and hands them to CTimeSeriesEngine::SaveConfigurationToJSON, which merges them into
 // --- each entry of Config_Setting.json.
 void CGUIPannel::SaveGUIConfigToJSON(void)
  {
    if(m_time_series_engine == NULL) return;
     ::Print(__FUNCTION__, " > Starting save config");
    // Layer 2 reads its own live checkbox state (both tables), hands it to Layer 1 to write -
    // replaces the old hardcode-true bug for templates (SeparateLayer_Plan.md, 2026-08-16).
     string symbols[], tfs[];
     bool buys[], sells[];
     BuildSymbolTFBuySellArrays(symbols, tfs, buys, sells);
    // --- Pass m_indicator_template_setting[] straight through (Anhnt, 2026-08-18) - already the
    // --- live source of truth (kept current by SetIndicatorTableRow/OnClickToggle*), and already
    // --- the exact SJsonIndicatorEntry shape SaveConfigurationToJSON needs - no reason to
    // --- decompose it into 6 parallel arrays just to re-assemble the same fields on the other side.
     bool result1 = m_time_series_engine.SaveConfigurationToJSON("Config_Setting.json", symbols, tfs, buys, sells,
                                                                  m_indicator_template_setting);
     //::Print(__FUNCTION__, " > SaveConfigurationToJSON: ", (result1 ? "OK" : "FAILED"));
    // Layer 2: Pattern Alert Config (Sound/Message checkboxes)
     SavePatternAlertConfigToJSON();
     //::Print(__FUNCTION__, " > SavePatternAlertConfigToJSON: OK");    
    // Layer 2: Marker Settings (8 icon codes)
     SaveMarkerSettingsToJSON();
      //::Print(__FUNCTION__, " > SaveMarkerSettingsToJSON: OK");
  }  
 void CGUIPannel::SavePatternAlertConfigToJSON(void)
  {   
    string full_path = g_ea_folder + "/Config_Setting.json";
   // Preserve existing sections from Config_Setting.json
    string existing   = IndicatorConfig_ReadWholeFile(full_path);
    string symbols_tf = IndicatorConfig_ExtractRawSection(existing, "Symbols_TFs_List");
    string templates  = IndicatorConfig_ExtractRawSection(existing, "Indicator_Templates");
    string markers    = IndicatorConfig_ExtractRawSection(existing, "Markers_Setting");

    string json = "{\n";
    if(symbols_tf != "") json += " \"Symbols_TFs_List\": " + symbols_tf + ",\n";
    if(templates  != "") json += " \"Indicator_Templates\": "  + templates  + ",\n";
    if(markers    != "") json += " \"Markers_Setting\": "    + markers    + ",\n";
   // Each pattern type has one Sound + Message alert setting that applies to both BUY and SELL
    int pattern_count = ArraySize(m_pattern_types);
    json += " \"Pattern_Alerts_Setting\": {\n";
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
    string full_path = g_ea_folder + "/Config_Setting.json";
    // //Debug
    //  Print("DEBUG:CGUIPannel::SaveMarkerSettingsToJSON g_ea_folder=", g_ea_folder);      // ← ADD THIS
    //  Print("DEBUG: CGUIPannel::SaveMarkerSettingsToJSONfull_path=", full_path);          // ← ADD THIS

    string existing   = IndicatorConfig_ReadWholeFile(full_path);
    string symbols_tf = IndicatorConfig_ExtractRawSection(existing, "Symbols_TFs_List");
    string templates  = IndicatorConfig_ExtractRawSection(existing, "Indicator_Templates");
    string pattern_alerts = IndicatorConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");

    string json = "{\n";
    if(symbols_tf != "") json += " \"Symbols_TFs_List\": " + symbols_tf + ",\n";
    if(templates  != "") json += " \"Indicator_Templates\": "  + templates  + ",\n";
    if(pattern_alerts != "") json += " \"Pattern_Alerts_Setting\": " + pattern_alerts + ",\n";
  
    string buy_sound_esc  = m_marker_buy_sound_file;
    string sell_sound_esc = m_marker_sell_sound_file;
    // string sound_folder_esc = m_marker_sound_folder;
    ::StringReplace(buy_sound_esc,  "\\", "\\\\");
    ::StringReplace(sell_sound_esc, "\\", "\\\\");
    // ::StringReplace(sound_folder_esc, "\\", "\\\\");
  
    // --- Human-readable labels (Anhnt, 2026-08-15), not raw Wingdings codes/color ints - e.g.
    // --- "83 Bomb" / "Dodger Blue" instead of "83" / "65280" - matches exactly what the combo
    // --- shows (ArrowLabelForCode/ColorLabelForValue look up the SAME GetMarker*Choices catalogs).
    json += " \"Markers_Setting\": {\n" +
        "  \"single_indicator_buy_arrow_code\": \""  + ArrowLabelForCode(m_marker_single_indicator_buy_code) + "\",\n" +
        "  \"single_indicator_sell_arrow_code\": \"" + ArrowLabelForCode(m_marker_single_indicator_sell_code) + "\",\n" +
        "  \"multi_indicator_buy_arrow_code\": \""   + ArrowLabelForCode(m_marker_multi_indicator_buy_code) + "\",\n" +
        "  \"multi_indicator_sell_arrow_code\": \""  + ArrowLabelForCode(m_marker_multi_indicator_sell_code) + "\",\n" +
        "  \"pattern_buy_arrow_code\": \""  + ArrowLabelForCode(m_marker_pattern_buy_code) + "\",\n" +
        "  \"pattern_sell_arrow_code\": \"" + ArrowLabelForCode(m_marker_pattern_sell_code) + "\",\n" +
        "  \"combo_buy_arrow_code\": \""    + ArrowLabelForCode(m_marker_combo_buy_code) + "\",\n" +
        "  \"combo_sell_arrow_code\": \""   + ArrowLabelForCode(m_marker_combo_sell_code) + "\",\n" +
        "  \"buy_color\": \""        + ColorLabelForValue(m_marker_buy_color) + "\",\n" +
        "  \"sell_color\": \""       + ColorLabelForValue(m_marker_sell_color) + "\",\n" +
        "  \"nonrelated_color\": \"" + ColorLabelForValue(m_marker_nonrelated_color) + "\"\n" +
        " },\n" +
        " \"Sound_Settings\": {\n" +
        "  \"buy_sound_file\": \""  + buy_sound_esc  + "\",\n" +
        "  \"sell_sound_file\": \"" + sell_sound_esc + "\"\n" +
        // "  \"sound_folder\": \""    + sound_folder_esc + "\"\n" +
        " }\n}";

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
 // --- Loads the "markers" section of Config_Setting.json - the SAME single file
 // --- CTimeSeriesEngine::SaveConfigurationToJSON/LoadConfigurationFromJSON already use for
 // --- "symbols_tf"/"templates" (Anhnt, 2026-07-17: one file for everything, not scattered
 // --- across separate files). Always sets sane defaults first so a missing/partial file
 // --- (or a file that simply has no "markers" key yet) still leaves the EA in a working state.
 void CGUIPannel::LoadMarkerSettingsFromJSON(void)
  {
   //For default value reference at https://www.mql5.com/en/docs/constants/objectconstants/wingdings
   //Marker for indicator
    m_marker_single_indicator_buy_code  = 217;
    m_marker_single_indicator_sell_code = 218;
    m_marker_multi_indicator_buy_code   = 67;   // Thumb Up
    m_marker_multi_indicator_sell_code  = 68;   // Thumb Down
   //Marker for Pattern
    m_marker_pattern_buy_code  = 39;   //Candle
    m_marker_pattern_sell_code = 39;   //Candle
   //Marker for Combo
    m_marker_combo_buy_code    = 83;  // Bomb
    m_marker_combo_sell_code   = 83;  // Bomb
   //For default color
    m_marker_buy_color        = clrLime;
    m_marker_sell_color       = clrRed;
    m_marker_nonrelated_color = clrGray;
   //For sound
    m_marker_buy_sound_file   = "";
    m_marker_sell_sound_file  = "";
    // m_marker_sound_folder     = "Sounds";
   //For Config_Setting.json
    //string content = IndicatorConfig_ReadWholeFile("Config_Setting.json");
    string full_path = g_ea_folder + "/Config_Setting.json";
    string content = IndicatorConfig_ReadWholeFile(full_path);
    if(content == "") return;
    // --- Read back the human-readable labels SaveMarkerSettingsToJSON now writes ("83 Bomb",
    // --- "Dodger Blue") - reverse-lookup via ArrowCodeForLabel/ColorForLabel against the SAME
    // --- GetMarker*Choices catalogs, falling back to the default already set above if the
    // --- label is missing/unrecognized (e.g. older JSON, or a hand-edited typo).
    string sv;
    if(::JsonStringValue(content, "single_indicator_buy_arrow_code",  sv)) m_marker_single_indicator_buy_code  = ArrowCodeForLabel(sv, m_marker_single_indicator_buy_code);
    if(::JsonStringValue(content, "single_indicator_sell_arrow_code", sv)) m_marker_single_indicator_sell_code = ArrowCodeForLabel(sv, m_marker_single_indicator_sell_code);
    if(::JsonStringValue(content, "multi_indicator_buy_arrow_code",   sv)) m_marker_multi_indicator_buy_code   = ArrowCodeForLabel(sv, m_marker_multi_indicator_buy_code);
    if(::JsonStringValue(content, "multi_indicator_sell_arrow_code",  sv)) m_marker_multi_indicator_sell_code  = ArrowCodeForLabel(sv, m_marker_multi_indicator_sell_code);
    if(::JsonStringValue(content, "pattern_buy_arrow_code",  sv)) m_marker_pattern_buy_code  = ArrowCodeForLabel(sv, m_marker_pattern_buy_code);
    if(::JsonStringValue(content, "pattern_sell_arrow_code", sv)) m_marker_pattern_sell_code = ArrowCodeForLabel(sv, m_marker_pattern_sell_code);
    if(::JsonStringValue(content, "combo_buy_arrow_code",    sv)) m_marker_combo_buy_code    = ArrowCodeForLabel(sv, m_marker_combo_buy_code);
    if(::JsonStringValue(content, "combo_sell_arrow_code",   sv)) m_marker_combo_sell_code   = ArrowCodeForLabel(sv, m_marker_combo_sell_code);
    if(::JsonStringValue(content, "buy_color",        sv)) m_marker_buy_color        = ColorForLabel(sv, m_marker_buy_color);
    if(::JsonStringValue(content, "sell_color",       sv)) m_marker_sell_color       = ColorForLabel(sv, m_marker_sell_color);
    if(::JsonStringValue(content, "nonrelated_color", sv)) m_marker_nonrelated_color = ColorForLabel(sv, m_marker_nonrelated_color);
    if(::JsonStringValue(content, "buy_sound_file",  sv)) m_marker_buy_sound_file  = sv;
    if(::JsonStringValue(content, "sell_sound_file", sv)) m_marker_sell_sound_file = sv;
    //if(::JsonStringValue(content, "sound_folder",    sv)) m_marker_sound_folder    = sv;
  }
 void CGUIPannel::LoadPatternAlertConfigFromJSON(void)
  {
    //string content = IndicatorConfig_ReadWholeFile("Config_Setting.json");
    string full_path = g_ea_folder + "/Config_Setting.json";    
    string content = IndicatorConfig_ReadWholeFile(full_path);
    if(content == "") return;
    string pattern_alerts_section = IndicatorConfig_ExtractRawSection(content, "Pattern_Alerts_Setting");
    if(pattern_alerts_section == "") return;
    int pattern_count = ArraySize(m_pattern_types);
    for(int i = 0; i < pattern_count; i++)
     {
      string pattern_name = m_pattern_display_names[i];
      int pos = StringFind(pattern_alerts_section, "\"" + pattern_name + "\"");
      if(pos < 0) continue;
      int brace = StringFind(pattern_alerts_section, "{", pos);
      if(brace < 0) continue;
      int close_brace = StringFind(pattern_alerts_section, "}", brace);
      if(close_brace < 0) continue;
      string pattern_obj = StringSubstr(pattern_alerts_section, brace, close_brace - brace + 1);
      bool sound_enabled = false;
      bool message_enabled = false;
      if(::JsonBoolValue(pattern_obj, "sound", sound_enabled))
        {
          m_table_CandlePatternsSetting.ChangeImage(3, i, sound_enabled ? 0 : 1);
        }
      if(::JsonBoolValue(pattern_obj, "message", message_enabled))
        {
          m_table_CandlePatternsSetting.ChangeImage(4, i, message_enabled ? 0 : 1);
        }
     }
  }

#endif // CGUIPANNEL_JSONCONFIG_MQH
