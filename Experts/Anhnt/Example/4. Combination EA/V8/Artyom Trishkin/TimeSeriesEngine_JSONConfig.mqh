//+------------------------------------------------------------------+
//|                                  TimeSeriesEngine_JSONConfig.mqh |
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_JSONCONFIG
#define CTIMESERIESENGINE_JSONCONFIG
 extern string g_ea_folder;  // From EA
 //+------------------------------------------------------------------+
 //| Tang 1: load the JSON indicator template and apply each entry to |
 //| every (symbol, timeframe) series that already exists. Called     |
 //| explicitly by the EA's OnInit - the EA orchestrates when/whether  |
 //| to (re)load, this engine only knows how to do it.                 |
 //+------------------------------------------------------------------+
 int CTimeSeriesEngine::LoadConfigurationFromJSON(const string filename)
  {    
    string full_path = g_ea_folder + "/" + filename;
    SJsonIndicatorEntry entries[];
    SJsonSymbolTF       symbols_tf[];
    if(!ParseIndicatorConfigFile(full_path, entries, symbols_tf))
      {
       Print("CTimeSeriesEngine::LoadConfigurationFromJSON > failed to read/parse ", filename);
       return -1;
      }
    // --- Cache Symbol/TF Buy/Sell for GUIPannel's GetLoadedSymbolTFSettings() - it seeds
    // --- m_table_indicator_SymbolTFSeting's checkboxes right after building the rows.
    int sf_total = ArraySize(symbols_tf);
    ArrayResize(m_loaded_sf_symbols, sf_total);
    ArrayResize(m_loaded_sf_tfs, sf_total);
    ArrayResize(m_loaded_sf_buy, sf_total);
    ArrayResize(m_loaded_sf_sell, sf_total);
    for(int s = 0; s < sf_total; s++)
      {
       m_loaded_sf_symbols[s] = symbols_tf[s].symbol;
       m_loaded_sf_tfs[s]     = symbols_tf[s].tf;
       m_loaded_sf_buy[s]     = symbols_tf[s].buy;
       m_loaded_sf_sell[s]    = symbols_tf[s].sell;
      }
    // --- Cache Indicator template Buy/Sell for GetLoadedTemplateSettings() - matched by
    // --- (type, params-as-text) since templates have no symbol/TF identity of their own.
    int tmpl_total = ArraySize(entries);
    ArrayResize(m_loaded_tmpl_type, tmpl_total);
    ArrayResize(m_loaded_tmpl_params_key, tmpl_total);
    ArrayResize(m_loaded_tmpl_buy, tmpl_total);
    ArrayResize(m_loaded_tmpl_sell, tmpl_total);
    ArrayResize(m_loaded_tmpl_sound, tmpl_total);
    ArrayResize(m_loaded_tmpl_message, tmpl_total);
    for(int e = 0; e < tmpl_total; e++)
     {
      string params_key = "";
      for(int p = 0; p < ArraySize(entries[e].params); p++)
        params_key += (p > 0 ? "," : "") + entries[e].params[p];
       m_loaded_tmpl_type[e]       = entries[e].type;
       m_loaded_tmpl_params_key[e] = params_key;
       m_loaded_tmpl_buy[e]        = entries[e].buy;
       m_loaded_tmpl_sell[e]       = entries[e].sell;
       m_loaded_tmpl_sound[e]      = entries[e].sound;
       m_loaded_tmpl_message[e]    = entries[e].message;
      }
    // --- Recreate every saved (symbol,TF) series FIRST, so the template loop below
    // --- (AddNewIndicatorToAllSeries, which only reaches series that already exist)
    // --- finds them and populates each one - no more manual re-visit-every-chart.
    int series_created = 0;
    for(int s = 0; s < ArraySize(symbols_tf); s++)
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
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    int applied = 0;
    int entries_total = ArraySize(entries);
    for(int e = 0; e < entries_total; e++)
      {
       bool type_found = false;
       ENUM_INDICATOR type = IND_CUSTOM;
       for(int c = 0; c < ArraySize(catalog); c++)
         {
          if(catalog[c].name == entries[e].type)
            {
             type = catalog[c].type;
             type_found = true;
             break;
            }
         }
       if(!type_found)
         {
          Print("CTimeSeriesEngine::LoadConfigurationFromJSON > unknown indicator type \"", entries[e].type, "\", skipped");
          continue;
         }

       SIndicatorParam schema[];
       int total = GetIndicatorParamSchema(type, schema);
       if(total == 0)
         {
          Print("CTimeSeriesEngine::LoadConfigurationFromJSON > \"", entries[e].type, "\" has no param schema yet, skipped");
          continue;
         }
       if(ArraySize(entries[e].params) < total)
         {
          Print("CTimeSeriesEngine::LoadConfigurationFromJSON > \"", entries[e].type, "\" needs ", total,
                " params, got ", ArraySize(entries[e].params), ", skipped");
          continue;
         }
       MqlParam params[];
       ArrayResize(params, total);
       bool param_error = false;
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
      Print("CTimeSeriesEngine::LoadConfigurationFromJSON > applied ", applied, "/", entries_total,
            " indicator(s), recreated ", series_created, "/", ArraySize(symbols_tf), " symbol/TF series from ", filename);
      return applied;
  }
 //+------------------------------------------------------------------+
 //| Tang 1: save current live indicator template to JSON file.       |
 //| Reads from m_IndicatorsCollection (Layer 1 data) using the same |
 //| reference trick as AddAllIndicatorsToNewSeries: all (sym,tf)     |
 //| pairs have identical indicator sets, so all.At(0) is the source. |
 //| Called by Layer 2 (GUIPannel) when user clicks Save button.      |
 //+------------------------------------------------------------------+
 bool CTimeSeriesEngine::SaveConfigurationToJSON(const string filename,
                                                 const string &symbols[], const string &tfs[],
                                                 const bool &buys[], const bool &sells[])
  {
   // Build full path: MQL5/Files/{EA_FOLDER}/{filename}    
    string full_path = g_ea_folder + "/" + filename;
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
   // Layer 1: Collect indicators template từ m_IndicatorsCollection
    int tmpl_total = 0;
    CIndicatorDE *tmpl_ptrs[];
    bool tmpl_buy[], tmpl_sell[], tmpl_sound[], tmpl_message[];
    CArrayObj *ind_list = m_IndicatorsCollection.GetList();
    if(ind_list == NULL) return false;
    if(ind_list.Total() > 0)
      {
       CIndicatorDE *ref_ind = ind_list.At(0);
       if(ref_ind != NULL)
         {
          string ref_sym = ref_ind.Symbol();
          ENUM_TIMEFRAMES ref_tf = ref_ind.Timeframe();
          CArrayObj *templates = m_IndicatorsCollection.GetListIndBySymbol(ref_sym);
          templates = CTimeseriesSelect::ByIndicatorProperty(templates, INDICATOR_PROP_TIMEFRAME, ref_tf, EQUAL);
          if(templates != NULL && templates.Total() > 0)
          {
            tmpl_total = templates.Total();
            ArrayResize(tmpl_ptrs,    tmpl_total);
            ArrayResize(tmpl_buy,     tmpl_total);
            ArrayResize(tmpl_sell,    tmpl_total);
            ArrayResize(tmpl_sound,   tmpl_total);
            ArrayResize(tmpl_message, tmpl_total);
            for(int i = 0; i < tmpl_total; i++)
              {
               tmpl_ptrs[i] = templates.At(i);
               tmpl_buy[i] = true;
               tmpl_sell[i] = true;
               tmpl_sound[i] = true;
               tmpl_message[i] = true;
              }
          }
         }
      }
   // Start building JSON
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    string json = "{\n \"symbols_tf\": [\n";
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
    json += "\n ],\n \"templates\": [\n";
    int saved = 0;
    for(int i = 0; i < tmpl_total; i++)
     {
       CIndicatorDE *ind = tmpl_ptrs[i];
       if(ind == NULL) continue;
       string cat_name = "";
       for(int c = 0; c < ArraySize(catalog); c++)
         if(catalog[c].type == ind.TypeIndicator()) { cat_name = catalog[c].name; break; }
       if(cat_name == "") continue;
       SIndicatorParam schema[];
       GetIndicatorParamSchema(ind.TypeIndicator(), schema);
       MqlParam params[];
       ind.GetMqlParams(params);
       if(saved > 0) json += ",\n";
       saved++;
       bool buy     = (i < ArraySize(tmpl_buy))     ? tmpl_buy[i]     : false;
       bool sell    = (i < ArraySize(tmpl_sell))    ? tmpl_sell[i]    : false;
       bool sound   = (i < ArraySize(tmpl_sound))   ? tmpl_sound[i]   : false;
       bool message = (i < ArraySize(tmpl_message)) ? tmpl_message[i] : false;
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
 //| Copies out the Symbol/TF Buy/Sell cached by the last              |
 //| LoadConfigurationFromJSON() call - GUIPannel calls this once,      |
 //| right after building m_table_indicator_SymbolTFSeting's rows, to   |
 //| seed its Buy/Sell checkboxes from the loaded JSON.                 |
 //+------------------------------------------------------------------+
 void CTimeSeriesEngine::GetLoadedSymbolTFSettings(string &symbols[], string &tfs[], bool &buys[], bool &sells[])
  {
   ArrayCopy(symbols, m_loaded_sf_symbols);
   ArrayCopy(tfs, m_loaded_sf_tfs);
   ArrayCopy(buys, m_loaded_sf_buy);
   ArrayCopy(sells, m_loaded_sf_sell);
  }
 void CTimeSeriesEngine::GetLoadedTemplateSettings(string &types[], string &param_keys[], bool &buys[], bool &sells[],
                                                     bool &sounds[], bool &messages[])
  {
      ArrayCopy(types, m_loaded_tmpl_type);
      ArrayCopy(param_keys, m_loaded_tmpl_params_key);
      ArrayCopy(buys, m_loaded_tmpl_buy);
      ArrayCopy(sells, m_loaded_tmpl_sell);
      ArrayCopy(sounds, m_loaded_tmpl_sound);
      ArrayCopy(messages, m_loaded_tmpl_message);
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
   // Build full path: MQL5/Files/{EA_FOLDER}/{filename}
    //string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
    string full_path = g_ea_folder + "/" + filename;   
   SJsonIndicatorEntry entries[];
   SJsonSymbolTF       symbols_tf[];
    if(!ParseIndicatorConfigFile(full_path, entries, symbols_tf))
     {
      Print("CTimeSeriesEngine::RemoveSymbolTFFromConfigJSON > failed to read/parse ", full_path);
      return false;
     }
    string json = "{\n \"symbols_tf\": [\n";
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
   json += "\n ],\n \"templates\": [\n";
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
