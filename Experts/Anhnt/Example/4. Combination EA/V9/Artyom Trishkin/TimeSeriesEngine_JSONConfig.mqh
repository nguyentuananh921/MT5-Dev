//+------------------------------------------------------------------+
//|                                  TimeSeriesEngine_JSONConfig.mqh |
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_JSONCONFIG
#define CTIMESERIESENGINE_JSONCONFIG
#include "TimeSeriesEngine.mqh"
 extern string g_ea_folder;  // From EA
 //+------------------------------------------------------------------+
 //| Tang 1: load "Symbols_TFs_List" and recreate every saved series. |
 //| Populates the identity-only m_symbol_tf[] mirror and hands the   |
 //| FULL parsed rows (incl. buy/sell) back via out_symbols_tf[] so   |
 //| Layer 2 (CGUIPannel) can pull its own settings out of them -     |
 //| Layer 1 never stores buy/sell itself (SeparateLayer_Plan.md).    |
 //| MUST run BEFORE LoadIndicatorTemplateFromJSON - that one attaches|
 //| indicators to the Series this creates.                           |
 //+------------------------------------------------------------------+
 int CTimeSeriesEngine::LoadSymbolTFFromJSON(const string filename, SJsonSymbolTF &out_symbols_tf[])
  {
    string full_path = g_ea_folder + "/" + filename;
    SJsonIndicatorEntry entries[];
    SJsonSymbolTF       symbols_tf[];
    if(!ParseIndicatorConfigFile(full_path, entries, symbols_tf))
      {
       Print("CTimeSeriesEngine::LoadSymbolTFFromJSON > failed to read/parse ", filename);
       return -1;
      }
    // --- ArrayCopy() can't be used here - structs holding string members aren't POD, MQL5's
    // --- built-in refuses them ("structures or classes containing objects are not allowed").
    // --- Manual copy instead, same loop also builds the identity-only m_symbol_tf[] mirror.
     int sf_total = ArraySize(symbols_tf);
     ArrayResize(out_symbols_tf, sf_total);
     ArrayResize(m_symbol_tf, sf_total);
     for(int s = 0; s < sf_total; s++)
      {
       out_symbols_tf[s] = symbols_tf[s];
       m_symbol_tf[s].symbol = symbols_tf[s].symbol;
       m_symbol_tf[s].tf     = symbols_tf[s].tf;
      }
    // --- Recreate every saved (symbol,TF) series.
    int series_created = 0;
    for(int s = 0; s < sf_total; s++)
      {
       string sym = symbols_tf[s].symbol;
       ENUM_TIMEFRAMES tf = TimestampByDescription(symbols_tf[s].tf);
       //EA attach to Symbol TF not in Config
       if(sym == "" || this.m_BarTimeSeriesCollection.IsAvailable(sym, tf)) continue;
       if(this.m_BarTimeSeriesCollection.CreateSeries(sym, tf))
         {
          series_created++;
          // --- Mirror of AddAllIndicatorsToNewSeries: a freshly created (symbol,TF) series
          // --- also needs the full Candle Pattern registry pushed to its own ctrl + an
          // --- initial RefreshAll(), otherwise it silently detects zero patterns forever
          // --- (Anhnt, 2026-08-10: only the EA's very first startup TF ever got this).
          this.SeriesApplyPatternRegistry(sym, tf);
         }
      }
    Print("CTimeSeriesEngine::LoadSymbolTFFromJSON > recreated ", series_created, "/", sf_total,
          " symbol/TF series from ", filename);
    return sf_total;
  }
 //+------------------------------------------------------------------+
 //| Layer 1: load "Indicator_Templates" and attach each entry to every 
 //| (symbol, timeframe) series that already exists - call AFTER LoadSymbolTFFromJSON 
 //| so those series exist. Populates the identity-only m_indicator_template[] mirror 
 //| and hands the FULL parsed rows (incl. buy/sell/sound/message) back 
 //| via out_entries[] so Layer 2 can pull its own settings out of them.                |
 //+------------------------------------------------------------------+
 int CTimeSeriesEngine::LoadIndicatorTemplateFromJSON(const string filename, SJsonIndicatorEntry &out_entries[])
  {
    string full_path = g_ea_folder + "/" + filename;
    SJsonIndicatorEntry entries[];
    SJsonSymbolTF       symbols_tf[];
    if(!ParseIndicatorConfigFile(full_path, entries, symbols_tf))
      {
       Print("CTimeSeriesEngine::LoadIndicatorTemplateFromJSON > failed to read/parse ", filename);
       return -1;
      }
    // --- ArrayCopy() can't be used here - structs holding a string/dynamic-array member
    // --- aren't POD, MQL5's built-in refuses them ("structures or classes containing objects
    // --- are not allowed"). Per-element struct assignment (=) works fine though.
    // --- Identity-only mirror: "Indicator_Templates" (type+params_key, no buy/sell/sound/
    // --- message). Matched by (type, params-as-text) since templates have no symbol/TF
    // --- identity of their own (README: every symbol/TF carries the same template set).
    int tmpl_total = ArraySize(entries);
    ArrayResize(out_entries, tmpl_total);
    // --- Direct m_indicator_template[] write REMOVED (SynIndicatorPlan.md, 2026-08-17): it's now
    // --- written by AddNewIndicatorToAllSeries() itself (called per-entry in the loop below),
    // --- the single entry point shared by GUI Add / Chart Import / JSON load - one write path
    // --- for all 3 sources instead of this JSON-only duplicate. Side benefit: entries that fail
    // --- type_found below (unknown type, skipped) no longer pre-allocate an empty slot here like
    // --- the old code did (ArrayResize(m_indicator_template, tmpl_total) sized for ALL entries
    // --- up front, including ones later skipped).
    for(int e = 0; e < tmpl_total; e++)
     {
      out_entries[e] = entries[e];
     }
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    int applied = 0;
    for(int e = 0; e < tmpl_total; e++)
     {
       bool type_found = false;
       ENUM_INDICATOR type = IND_CUSTOM;
       for(int c = 0; c < ArraySize(catalog); c++)
         {
          if(catalog[c].name == entries[e].type)
            {
             type = catalog[c].ind_type;
             type_found = true;
             break;
            }
         }
       if(!type_found)
         {
          Print("CTimeSeriesEngine::LoadIndicatorTemplateFromJSON > unknown indicator type \"", entries[e].type, "\", skipped");
          continue;
         }

       SIndicatorParam schema[];
       int total = GetIndicatorParamSchema(type, schema);
       if(total == 0)
         {
          Print("CTimeSeriesEngine::LoadIndicatorTemplateFromJSON > \"", entries[e].type, "\" has no param schema yet, skipped");
          continue;
         }
       if(ArraySize(entries[e].params) < total)
         {
          Print("CTimeSeriesEngine::LoadIndicatorTemplateFromJSON > \"", entries[e].type, "\" needs ", total,
                " params, got ", ArraySize(entries[e].params), ", skipped");
          continue;
         }
       MqlParam params[];
       ArrayResize(params, total);
       for(int i = 0; i < total; i++)
         {
          params[i].type = schema[i].data_type;
          string raw = entries[e].params[i];
          if(schema[i].choices != "")
            {
             // --- Enum-like param: raw is the choice TEXT (e.g. "EMA") saved by
             // --- SaveConfigurationToJSON - the matching CommonDELib.mqh XxxByDescription()
             // --- resolves it straight to the real MQL5 enum value, dispatched by
             // --- comparing schema[i].choices against the 4 known constants.
             if(schema[i].choices == PRICE_CHOICES)
                params[i].integer_value = (long)AppliedPriceByDescription(raw);
             else if(schema[i].choices == CALCULATION_METHOD_CHOICES)
                params[i].integer_value = (long)AveragingMethodByDescription(raw);
             else if(schema[i].choices == VOLUME_CHOICES)
                params[i].integer_value = (long)AppliedVolumeByDescription(raw);
             else if(schema[i].choices == STOCH_PRICE_CHOICES)
                params[i].integer_value = (long)StochPriceByDescription(raw);
             else
                params[i].integer_value = (long)StringToInteger(raw); // back-compat: old files stored a raw number
            }
          else if(schema[i].data_type == TYPE_DOUBLE)
             params[i].double_value = StringToDouble(raw);
          else
             params[i].integer_value = StringToInteger(raw);
         }
       if(AddNewIndicatorToAllSeries(type, params))
          applied++;
     }
      Print("CTimeSeriesEngine::LoadIndicatorTemplateFromJSON > applied ", applied, "/", tmpl_total,
            " indicator(s) from ", filename);
      return applied;
  }
 //+------------------------------------------------------------------+
 //| Tang 1: save current live indicator template to JSON file.       |
 //| Template list comes from the LIVE identity mirror                |
 //| m_indicator_template[] (canonical, instance-independent -        |
 //| SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18) - NOT  |
 //| the old "pick all.At(0) as an arbitrary reference instance and   |
 //| re-derive ITS (sym,TF) set" trick AddAllIndicatorsToNewSeries     |
 //| also used to use (both fixed together, same bug class).          |
 //| Called by Layer 2 (GUIPannel) when user clicks Save button.      |
 //+------------------------------------------------------------------+
 bool CTimeSeriesEngine::SaveConfigurationToJSON(const string filename,
                                                 const string &symbols[], const string &tfs[],
                                                 const bool &buys[], const bool &sells[],
                                                 SJsonIndicatorEntry &tmpl_setting[])
  {
   // Build full path: MQL5/Files/{EA_FOLDER}/{filename}    
    string full_path = g_ea_folder + "/" + filename;
   // Preserve the 3 sections owned by Layer 2 (CGUIPannel) - not this function's own section
     string existing        = IndicatorConfig_ReadWholeFile(full_path);
     string markers         = IndicatorConfig_ExtractRawSection(existing, "Markers_Setting");
     string pattern_alerts  = IndicatorConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");
     string sound_settings  = IndicatorConfig_ExtractRawSection(existing, "Sound_Settings");    
   //Read GUI Configuration
    int sf_total = ArraySize(symbols);
    string sf_symbols[], sf_tfs[];
    bool sf_buy[], sf_sell[];
    ArrayResize(sf_symbols, sf_total); ArrayResize(sf_tfs, sf_total);
    ArrayResize(sf_buy, sf_total);     ArrayResize(sf_sell, sf_total);
   for(int i = 0; i < sf_total; i++)
    {
     sf_symbols[i] = symbols[i];
     sf_tfs[i]     = tfs[i];
     sf_buy[i]     = buys[i];
     sf_sell[i]    = sells[i];
    }
   // --- Layer 1: enumerate templates from the LIVE identity mirror m_indicator_template[]
   // --- (SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18: the canonical,
   // --- chart-independent source added in Dot 2) instead of the old pattern of scanning
   // --- CIndicatorsCollection filtered by the CURRENT chart's own symbol/TF - that old scan
   // --- made the saved template SET silently depend on which chart happened to be "current",
   // --- and was the one remaining place still doing it that way. m_indicator_template[] only
   // --- stores the string (type_key,params_key) though, not typed MqlParam[] - so for each
   // --- identity we still search the FULL collection (any symbol/TF, not just the current
   // --- chart's) for ONE live instance to read GetMqlParams() from.
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    int tmpl_total = ArraySize(m_indicator_template);
    CIndicatorDE *tmpl_ptrs[];
    bool resolved_buy[], resolved_sell[], resolved_sound[], resolved_message[];
    ArrayResize(tmpl_ptrs,       tmpl_total);
    ArrayResize(resolved_buy,     tmpl_total);
    ArrayResize(resolved_sell,    tmpl_total);
    ArrayResize(resolved_sound,   tmpl_total);
    ArrayResize(resolved_message, tmpl_total);
    CArrayObj *ind_list = m_IndicatorsCollection.GetList();
    int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
    int key_total = ArraySize(tmpl_setting);
    for(int i = 0; i < tmpl_total; i++)
      {
       string want_type_key   = m_indicator_template[i].type;
       string want_params_key = m_indicator_template[i].params_key;
       // --- Representative instance for this identity - ANY symbol/TF works, params are
       // --- identical across all of them by the Template invariant.
        CIndicatorDE *found = NULL;
        for(int r = 0; r < ind_total; r++)
         {
          CIndicatorDE *cand = ind_list.At(r);
          if(cand == NULL) continue;
          string cand_type_key, cand_params_key;
          BuildTemplateMatchKey(cand, catalog, cand_type_key, cand_params_key);
          if(cand_type_key == want_type_key && cand_params_key == want_params_key) { found = cand; break; }
         }
        tmpl_ptrs[i] = found;
       // --- Match against tmpl_setting[] (== m_indicator_template_setting[] from CGUIPannel) -
       // --- .type IS the type_key already, .params[] joined by comma reproduces params_key,
       // --- same round-trip GetIndicatorForRow()/GetRowForIdentity() rely on everywhere else.
        int match = -1;
        for(int h = 0; h < key_total; h++)
         {
          if(tmpl_setting[h].type != want_type_key) continue;
          string h_params_key = "";
          for(int p = 0; p < ArraySize(tmpl_setting[h].params); p++)
             h_params_key += (p > 0 ? "," : "") + tmpl_setting[h].params[p];
          if(h_params_key == want_params_key) { match = h; break; }
         }
        resolved_buy[i]     = (match >= 0) ? tmpl_setting[match].buy     : false;
        resolved_sell[i]    = (match >= 0) ? tmpl_setting[match].sell    : false;
        resolved_sound[i]   = (match >= 0) ? tmpl_setting[match].sound   : false;
        resolved_message[i] = (match >= 0) ? tmpl_setting[match].message : false;
      }
   // Start building JSON
    string json = "{\n \"Symbols_TFs_List\": [\n";
    int sym_saved = 0;
   // Sort by symbol (alphabetical) then ascending IndexEnumTimeframe()
    int order[];
    ArrayResize(order, sf_total);
    for(int i = 0; i < sf_total; i++) order[i] = i;
    for(int a = 0; a < sf_total - 1; a++)
      for(int b = a + 1; b < sf_total; b++)
       {
        bool swap = false;
        if(sf_symbols[order[a]] > sf_symbols[order[b]])
          swap = true;
        else if(sf_symbols[order[a]] == sf_symbols[order[b]] &&
                IndexEnumTimeframe(TimestampByDescription(sf_tfs[order[b]])) < IndexEnumTimeframe(TimestampByDescription(sf_tfs[order[a]])))
          swap = true;
        if(swap)
         { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
       }  
    for(int i = 0; i < sf_total; i++)
     {
       int q = order[i];
       if(sf_symbols[q] == "") continue;
       if(sym_saved > 0) json += ",\n";
       sym_saved++;
       json += "  { \"symbol\": \"" + sf_symbols[q] + "\", \"tf\": \"" + sf_tfs[q] +
            "\", \"buy\": " + (sf_buy[q] ? "true" : "false") +
            ", \"sell\": " + (sf_sell[q] ? "true" : "false") + " }";
     }
    json += "\n ],\n \"Indicator_Templates\": [\n";
    int saved = 0;
    for(int i = 0; i < tmpl_total; i++)
     {
       CIndicatorDE *ind = tmpl_ptrs[i];
       if(ind == NULL) continue;
       string cat_name = "";
       for(int c = 0; c < ArraySize(catalog); c++)
         if(catalog[c].ind_type == ind.TypeIndicator()) { cat_name = catalog[c].name; break; }
       if(cat_name == "") continue;
       SIndicatorParam schema[];
       GetIndicatorParamSchema(ind.TypeIndicator(), schema);
       MqlParam params[];
       ind.GetMqlParams(params);
       if(saved > 0) json += ",\n";
       saved++;
       bool buy     = (i < ArraySize(resolved_buy))     ? resolved_buy[i]     : false;
       bool sell    = (i < ArraySize(resolved_sell))    ? resolved_sell[i]    : false;
       bool sound   = (i < ArraySize(resolved_sound))   ? resolved_sound[i]   : false;
       bool message = (i < ArraySize(resolved_message)) ? resolved_message[i] : false;
       json += "  { \"type\": \"" + cat_name + "\", \"buy\": " + (buy ? "true" : "false") +
            ", \"sell\": " + (sell ? "true" : "false") +
            ", \"sound\": " + (sound ? "true" : "false") +
            ", \"message\": " + (message ? "true" : "false") + ", \"params\": [";
       for(int p = 0; p < ArraySize(params); p++)
       {
         if(p > 0) json += ", ";
         string choices = (p < ArraySize(schema)) ? schema[p].choices : "";
         if(choices != "")
          {
           if(choices == PRICE_CHOICES)
             json += "\"" + AppliedPriceDescription((ENUM_APPLIED_PRICE)params[p].integer_value) + "\"";
           else if(choices == CALCULATION_METHOD_CHOICES)
             json += "\"" + AveragingMethodDescription((ENUM_MA_METHOD)params[p].integer_value) + "\"";
           else if(choices == VOLUME_CHOICES)
             json += "\"" + AppliedVolumeDescription((ENUM_APPLIED_VOLUME)params[p].integer_value) + "\"";
           else if(choices == STOCH_PRICE_CHOICES)
             json += "\"" + StochPriceDescription((ENUM_STO_PRICE)params[p].integer_value) + "\"";
          }
        else if(params[p].type == TYPE_DOUBLE)
          json += DoubleToString(params[p].double_value, 8);
        else
          json += IntegerToString((int)params[p].integer_value);
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
     {
      Print("CTimeSeriesEngine::SaveConfigurationToJSON > cannot open ", full_path, " for writing, err=", GetLastError());
      return false;
     }
    FileWriteString(fh, json);
    FileClose(fh);
    Print("CTimeSeriesEngine::SaveConfigurationToJSON > saved ", saved, " indicator(s), ", sym_saved, " symbol/TF series to ", full_path);
    return true;
  }
 //+------------------------------------------------------------------+
 //| Rewrites filename's "symbols_tf" array without the given          |
 //| (symbol,tf) pair - "templates" is re-serialized unchanged from     |
 //| the same parse. Called from the Symbol/TF setting table's delete   |
 //| icon: this session's live BarSeriesDE/indicators/signals for that  |
 //| pair keep running untouched (no Library removal method exists     |
 //| yet) - it simply won't be recreated on the NEXT EA attach/restart, |
 //| since it's gone from the saved config from this point on.         |
 //+------------------------------------------------------------------+
 bool CTimeSeriesEngine::RemoveSymbolTFFromConfigJSON(const string filename, const string symbol, const string tf_text)
  {   
   //string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
    string full_path = g_ea_folder + "/" + filename;   
   SJsonIndicatorEntry entries[];
   SJsonSymbolTF       symbols_tf[];
    if(!ParseIndicatorConfigFile(full_path, entries, symbols_tf))
     {
      Print("CTimeSeriesEngine::RemoveSymbolTFFromConfigJSON > failed to read/parse ", full_path);
      return false;
     }
    string json = "{\n \"Symbols_TFs_List\": [\n";
   bool first = true;
   for(int i = 0; i < ArraySize(symbols_tf); i++)
    {
     if(symbols_tf[i].symbol == symbol && symbols_tf[i].tf == tf_text)
      continue;   // the pair being removed
     if(!first) json += ",\n";
     first = false;
     json += "  { \"symbol\": \"" + symbols_tf[i].symbol + "\", \"tf\": \"" + symbols_tf[i].tf +
            "\", \"buy\": " + (symbols_tf[i].buy ? "true" : "false") +
            ", \"sell\": " + (symbols_tf[i].sell ? "true" : "false") + " }";
    }
   json += "\n ],\n \"Indicator_Templates\": [\n";
   first = true;
   for(int i = 0; i < ArraySize(entries); i++)
    {
     if(!first) json += ",\n";
     first = false;
     json += "  { \"type\": \"" + entries[i].type + "\", \"params\": [";
     for(int p = 0; p < ArraySize(entries[i].params); p++)
      {
       if(p > 0) json += ", ";
       string raw = entries[i].params[p];
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
   json += "\n}";  
   int fh = FileOpen(full_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(fh == INVALID_HANDLE)
    {
     Print("CTimeSeriesEngine::RemoveSymbolTFFromConfigJSON > cannot open ", full_path, " for writing, err=", GetLastError());
     return false;
    }
   FileWriteString(fh, json);
   FileClose(fh);
   Print("CTimeSeriesEngine::RemoveSymbolTFFromConfigJSON > removed ", symbol, " ", tf_text, " from ", full_path);
   return true;
  }

#endif // CTIMESERIESENGINE_JSONCONFIG
