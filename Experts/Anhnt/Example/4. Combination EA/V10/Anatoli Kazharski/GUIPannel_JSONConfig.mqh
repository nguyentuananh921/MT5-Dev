//+------------------------------------------------------------------+
//|                                         GUIPannel_JSONConfig.mqh |
//|Implementation of JSON config and save setting of GUI Pannel      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_JSONCONFIG_MQH
#define CGUIPANNEL_JSONCONFIG_MQH
 #include "GUIPannel.mqh" 
 void CGUIPannel::LoadSymbolTFSettingFromJSON(void)
  {
   if(m_time_series_engine == NULL) return;
   ::Print(__FUNCTION__, " > Starting load config");
   string full_path = g_ea_folder + "/Config_Setting.json";
   SJsonIndicatorEntry entries[];
   SJsonSymbolTF       symbols_tf[];
   if(!ParseIndicatorConfigFile(full_path, entries, symbols_tf))
    {
     ::Print(__FUNCTION__, " > failed to read/parse ", full_path);
     return;
    }
   // --- ArrayCopy() can't be used here - structs holding a string/dynamic-array member aren't
   // --- POD, MQL5's built-in refuses them. Per-element struct assignment (=) works fine though.
    int sf_total = ArraySize(symbols_tf);
    ArrayResize(m_symbol_tf_Setting, sf_total);
    for(int i = 0; i < sf_total; i++)
       m_symbol_tf_Setting[i] = symbols_tf[i];
   // --- CTimeSeriesEngine::OnInitEvent (called right before this) unconditionally creates the
   // --- CURRENT chart's own Series regardless of whether it's in the JSON - if the EA is attached
   // --- to a Symbol/TF never saved before, m_symbol_tf_Setting[] would be permanently missing it
   // --- otherwise: m_chart_obj_collection's baseline snapshot (taken later in OnInitEvent) already
   // --- reflects this symbol/TF as "existing", so OnEvent's CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE
   // --- self-registration never fires for it. Self-register here too, same as OnEvent does.
    string cur_sym = _Symbol;
    string cur_tf  = TimeframeDescription(_Period);
    bool cur_found = false;
    for(int i = 0; i < ArraySize(m_symbol_tf_Setting); i++)
      if(m_symbol_tf_Setting[i].symbol == cur_sym && m_symbol_tf_Setting[i].tf == cur_tf) { cur_found = true; break; }
    if(!cur_found)
     {
      int n = ArraySize(m_symbol_tf_Setting);
      ArrayResize(m_symbol_tf_Setting, n + 1);
      m_symbol_tf_Setting[n].symbol = cur_sym;
      m_symbol_tf_Setting[n].tf     = cur_tf;
      m_symbol_tf_Setting[n].buy    = true;
      m_symbol_tf_Setting[n].sell   = true;
     }
   m_time_series_engine.ApplySymbolTFSetting(m_symbol_tf_Setting);
  }
 //+----------------------------------------------------------------------------+
 //| Loads Config_Setting.json's "Indicator_Templates" section into             |
 //| m_indicator_template_setting[], resolving .type_enum/.raw_params[]         |
 //| here (Layer 1 never touches JSON/text at all), then hands the array        |
 //| to Layer 1 (CTimeSeriesEngine::AddAllIndicatorsToNewSeries) once per       |
 //| (symbol,TF) Series already created by LoadSymbolTFSettingFromJSON -        |
 //| MUST run after it.                                                         |
 //| Called ONCE from the top of CGUIPannel::OnInitEvent (EA's OnInit).         |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::LoadIndicatorTemplateSettingFromJSON(void)
  {
   if(m_time_series_engine == NULL) return;
   string full_path = g_ea_folder + "/Config_Setting.json";
   SJsonIndicatorEntry entries[];
   SJsonSymbolTF       symbols_tf[];
   if(!ParseIndicatorConfigFile(full_path, entries, symbols_tf))
    {
     ::Print(__FUNCTION__, " > failed to read/parse ", full_path);
     return;
    }
    int tmpl_total = ArraySize(entries);
    ArrayResize(m_indicator_template_setting, tmpl_total);
    // --- m_settings_cache_state[] (per-row "Show" column dirty-check cache) is NOT resized here -
    // --- SyncTable_IndicatorTemplateSetting() self-heals its own size on next use, so no caller needs
    // --- to remember keeping it in lockstep (see that function's own comment).
    for(int i = 0; i < tmpl_total; i++)
       m_indicator_template_setting[i] = entries[i];
   // --- CTimeSeriesEngine does NOT work with JSON/text at all (Anhnt, 2026-08-19) - Layer 2 resolves
   // --- .type_enum/.raw_params[] HERE, before handing the array to Layer 1, so
   // --- AddAllIndicatorsToNewSeries below just reads them directly, no catalog/schema on its side.
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    for(int i = 0; i < tmpl_total; i++)
     {
      bool type_found = false;
      m_indicator_template_setting[i].type_enum = IND_CUSTOM;
      for(int c = 0; c < ArraySize(catalog); c++)
       {
        if(catalog[c].name == m_indicator_template_setting[i].type)
         {
          m_indicator_template_setting[i].type_enum = catalog[c].ind_type;
          type_found = true;
          break;
         }
       }
      if(!type_found)
       {
        ::Print(__FUNCTION__, " > unknown indicator type \"", m_indicator_template_setting[i].type, "\", skipped");
        continue;
       }
      SIndicatorParam schema[];
      int schema_total = GetIndicatorParamSchema(m_indicator_template_setting[i].type_enum, schema);
      if(schema_total == 0 || ArraySize(m_indicator_template_setting[i].params) < schema_total)
       {
        ::Print(__FUNCTION__, " > \"", m_indicator_template_setting[i].type, "\" param count/schema mismatch, skipped");
        continue;
       }
      ArrayResize(m_indicator_template_setting[i].raw_params, schema_total);
      for(int p = 0; p < schema_total; p++)
       {
        m_indicator_template_setting[i].raw_params[p].type = schema[p].data_type;
        string raw = m_indicator_template_setting[i].params[p];
        if(schema[p].choices != "")
         {
          // --- Enum-like param: raw is the choice TEXT (e.g. "EMA") saved by SaveGUIConfigToJSON -
          // --- the matching CommonDELib.mqh XxxByDescription() resolves it to the real MQL5 enum
          // --- value, dispatched by comparing schema[p].choices against the 4 known constants.
          if(schema[p].choices == PRICE_CHOICES)
             m_indicator_template_setting[i].raw_params[p].integer_value = (long)AppliedPriceByDescription(raw);
          else if(schema[p].choices == CALCULATION_METHOD_CHOICES)
             m_indicator_template_setting[i].raw_params[p].integer_value = (long)AveragingMethodByDescription(raw);
          else if(schema[p].choices == VOLUME_CHOICES)
             m_indicator_template_setting[i].raw_params[p].integer_value = (long)AppliedVolumeByDescription(raw);
          else if(schema[p].choices == STOCH_PRICE_CHOICES)
             m_indicator_template_setting[i].raw_params[p].integer_value = (long)StochPriceByDescription(raw);
          else
             m_indicator_template_setting[i].raw_params[p].integer_value = (long)StringToInteger(raw); // back-compat
         }
        else if(schema[p].data_type == TYPE_DOUBLE)
           m_indicator_template_setting[i].raw_params[p].double_value = StringToDouble(raw);
        else
           m_indicator_template_setting[i].raw_params[p].integer_value = StringToInteger(raw);
       }
     }
   // --- PureData-only (Anhnt, 2026-08-20): this function's job ends at populating
   // --- m_indicator_template_setting[] (.type_enum/.raw_params[] included). Layer 1 create used
   // --- to run right here per-series, but startup also needs InitializeIndicatorTemplateManagerOnInit() to merge in
   // --- any hand-attached-while-EA-was-off indicator FIRST - so the single AddAllIndicatorsToNewSeries
   // --- pass now runs once, after BOTH sources are merged, from OnInitEvent (GUIPannel_Lifecycle.mqh).
  }
 //+----------------------------------------------------------------------------+
 //| Loads the "Markers_Setting"/"Sound_Settings" sections of                   |
 //| Config_Setting.json. Always sets sane defaults first so a                  |
 //| missing/partial file (or one with no "Markers_Setting" key yet)            |
 //| still leaves the EA in a working state.                                    |
 //+----------------------------------------------------------------------------+
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
 //+----------------------------------------------------------------------------+
 //| Loads the "Pattern_Alerts_Setting" section of Config_Setting.json          |
 //| into the Candle Pattern tab's Sound/Message checkboxes.                    |
 //+----------------------------------------------------------------------------+
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
 //+----------------------------------------------------------------------------+
 //| Writes Config_Setting.json's "Symbols_TFs_List" + "Indicator_Templates"    |
 //| sections straight from CGUIPannel's own m_symbol_tf_Setting[]/             |
 //| m_indicator_template_setting[] - no Layer 1 read needed, Layer 2           |
 //| already holds both arrays. Preserves the 3 sections owned by the           |
 //| other Save methods below (raw text round-trip) before overwriting          |
 //| the whole file.                                                            |
 //+----------------------------------------------------------------------------+
 // --- .params[] is already schema-formatted TEXT (built once by
 // --- BuildIndicatorParamsText when the row was set) - no need to re-resolve a live CIndicatorDE
 // --- instance just to re-derive the same text. Numeric-vs-text quoting decided by a
 // --- character-scan heuristic (digits/-/+/./e/E = number, else re-quote as text).
 // --- Used to live in CTimeSeriesEngine::SaveConfigurationToJSON (deleted) - moved here since
 // --- every input it needs is already Layer 2's own data.
 void CGUIPannel::SaveGUIConfigToJSON(void)
  {
    ::Print(__FUNCTION__, " > Starting save config");
    string full_path = g_ea_folder + "/Config_Setting.json";
   // Preserve the 3 sections owned elsewhere in Layer 2 - not this function's own section
    string existing        = IndicatorConfig_ReadWholeFile(full_path);
    string markers         = IndicatorConfig_ExtractRawSection(existing, "Markers_Setting");
    string pattern_alerts  = IndicatorConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");
    string sound_settings  = IndicatorConfig_ExtractRawSection(existing, "Sound_Settings");
   // Sort m_symbol_tf_Setting[] by symbol (alphabetical) then ascending IndexEnumTimeframe()
    int sf_total = ArraySize(m_symbol_tf_Setting);
    int order[];
    ArrayResize(order, sf_total);
    for(int i = 0; i < sf_total; i++) order[i] = i;
    for(int a = 0; a < sf_total - 1; a++)
      for(int b = a + 1; b < sf_total; b++)
       {
        bool swap = false;
        if(m_symbol_tf_Setting[order[a]].symbol > m_symbol_tf_Setting[order[b]].symbol)
          swap = true;
        else if(m_symbol_tf_Setting[order[a]].symbol == m_symbol_tf_Setting[order[b]].symbol &&
                IndexEnumTimeframe(TimestampByDescription(m_symbol_tf_Setting[order[b]].tf)) < IndexEnumTimeframe(TimestampByDescription(m_symbol_tf_Setting[order[a]].tf)))
          swap = true;
        if(swap)
         { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
       }
    string json = "{\n \"Symbols_TFs_List\": [\n";
    int sym_saved = 0;
    for(int i = 0; i < sf_total; i++)
     {
      int q = order[i];
      if(m_symbol_tf_Setting[q].symbol == "") continue;
      if(sym_saved > 0) json += ",\n";
      sym_saved++;
      json += "  { \"symbol\": \"" + m_symbol_tf_Setting[q].symbol + "\", \"tf\": \"" + m_symbol_tf_Setting[q].tf +
           "\", \"buy\": " + (m_symbol_tf_Setting[q].buy ? "true" : "false") +
           ", \"sell\": " + (m_symbol_tf_Setting[q].sell ? "true" : "false") + " }";
     }
    json += "\n ],\n \"Indicator_Templates\": [\n";
    int saved = 0;
    int tmpl_total = ArraySize(m_indicator_template_setting);
    for(int i = 0; i < tmpl_total; i++)
     {
      if(m_indicator_template_setting[i].type == "") continue;
      if(saved > 0) json += ",\n";
      saved++;
      json += "  { \"type\": \"" + m_indicator_template_setting[i].type + "\", \"buy\": " +
           (m_indicator_template_setting[i].buy ? "true" : "false") +
           ", \"sell\": " + (m_indicator_template_setting[i].sell ? "true" : "false") +
           ", \"sound\": " + (m_indicator_template_setting[i].sound ? "true" : "false") +
           ", \"message\": " + (m_indicator_template_setting[i].message ? "true" : "false") + ", \"params\": [";
      int p_total = ArraySize(m_indicator_template_setting[i].params);
      for(int p = 0; p < p_total; p++)
       {
        if(p > 0) json += ", ";
        string raw = m_indicator_template_setting[i].params[p];
        // --- Re-quote unless every char is one IndicatorConfig_ReadRawNumber() would have
        // --- consumed (digits/-/+/./e/E) - a bare number was never quoted in the original file.
         bool is_number = (StringLen(raw) > 0);
         for(int c = 0; c < StringLen(raw) && is_number; c++)
          {
           ushort ch = StringGetCharacter(raw, c);
           is_number = ((ch >= '0' && ch <= '9') || ch == '-' || ch == '+' || ch == '.' || ch == 'e' || ch == 'E');
          }
         json += is_number ? raw : ("\"" + raw + "\"");
       }
      json += "] }";
     }
    json += "\n ]";
    if(markers != "")        json += ",\n \"Markers_Setting\": " + markers;
    if(pattern_alerts != "") json += ",\n \"Pattern_Alerts_Setting\": " + pattern_alerts;
    if(sound_settings != "") json += ",\n \"Sound_Settings\": " + sound_settings;
    json += "\n}";
    int fh = FileOpen(full_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
    if(fh == INVALID_HANDLE)
      Print(__FUNCTION__, " > cannot open ", full_path, " for writing, err=", GetLastError());
    else
     {
      FileWriteString(fh, json);
      FileClose(fh);
      Print(__FUNCTION__, " > saved ", saved, " indicator(s), ", sym_saved, " symbol/TF series to ", full_path);
     }
    // Layer 2: Pattern Alert Config (Sound/Message checkboxes)
     SavePatternAlertConfigToJSON();
    // Layer 2: Marker Settings (8 icon codes)
     SaveMarkerSettingsToJSON();
  }
 //+----------------------------------------------------------------------------+
 //| Writes the "Pattern_Alerts_Setting" section of Config_Setting.json,        |
 //| preserving the other sections owned elsewhere.                             |
 //+----------------------------------------------------------------------------+
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
 //+----------------------------------------------------------------------------+
 //| Writes the "Markers_Setting"/"Sound_Settings" sections of                  |
 //| Config_Setting.json, preserving the other sections owned elsewhere.        |
 //+----------------------------------------------------------------------------+
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

#endif // CGUIPANNEL_JSONCONFIG_MQH
