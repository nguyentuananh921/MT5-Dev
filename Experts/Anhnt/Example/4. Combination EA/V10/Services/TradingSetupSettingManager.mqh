//+------------------------------------------------------------------+
//|                                   TradingSetupSettingManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for per-Symbol      |
//| StopLost+Trailing rows - same pattern as CSymbolTFManager/         |
//| CIndicatorTemplateManager. Kept in Services (EA-local) rather than |
//| the Library, since CTradingSetupSetting itself is EA-local too -   |
//| the Library's CTrading/CTradingControl never needs to know about   |
//| it directly.                                                        |
//+------------------------------------------------------------------+
#ifndef CTRADINGSETUPSETTINGMANAGER_MQH
#define CTRADINGSETUPSETTINGMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include "TradingSetupSetting.mqh"
 #include "SymbolTFManager.mqh"
 #include "JSONConfig.mqh"
 extern string g_ea_folder;  // From EA - same pattern SymbolTFManager.mqh/IndicatorTemplateManager.mqh use

 //+------------------------------------------------------------------------------------+
 //| Events CTradingSetupSettingManager fires whenever Data genuinely changes - same     |
 //| principle as ENUM_SYMBOLTF_MANAGER_EVENT. Chains off SymbolTFManager's own LAST     |
 //| value (SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED), not off any earlier one.            |
 //+------------------------------------------------------------------------------------+
 enum ENUM_TRADING_SETUP_MANAGER_EVENT
  {
   TRADING_SETUP_MANAGER_EVENT_NO_EVENT = SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED + 1,
   TRADING_SETUP_MANAGER_EVENT_ADDED,     // a Symbol's Trading Setup row was genuinely added
   TRADING_SETUP_MANAGER_EVENT_DELETE,    // a Symbol's Trading Setup row was genuinely removed
   TRADING_SETUP_MANAGER_EVENT_CHANGED,   // an existing row's StopLost/Trailing fields were edited+Saved
  };

#ifndef CTRADINGSETUPSETTINGMANAGER_MQH_DECLARATION
#define CTRADINGSETUPSETTINGMANAGER_MQH_DECLARATION
 class CTradingSetupSettingManager : public CBaseObj
   {
     private:
       CArrayObj   m_list;                 // list of CTradingSetupSetting*
       string      m_last_removed_symbol;
       bool        m_loaded_from_json;
      //--- Global Trailing-by-Value bar shift
       int         m_trail_data_rates_index;
      //Working with JSON
       int         ReadTradingSetupEntry(const string &s, int pos, CTradingSetupSetting *&out_row);
       int         ReadTradingSetupEntryArray(const string &s, int pos);
       int         ReadMqlParamArray(const string &s, int pos, MqlParam &out[]);
       void        BuildMqlParamArrayJson(MqlParam &params[], string &out_json) const;

     public:
                     CTradingSetupSettingManager(void) : m_last_removed_symbol(""), m_loaded_from_json(false),
                                                          m_trail_data_rates_index(2) {}
                    ~CTradingSetupSettingManager(void) {}
      //--- Lifecycle - same convention as CSymbolTFManager::OnInitEvent/CIndicatorTemplateManager::OnInitEvent.
       bool                    OnInitEvent(void);

       int                     Total(void)                          const { return m_list.Total();   }
       CTradingSetupSetting   *At(const int index)                  const { return m_list.At(index); }

      //--- identity-based lookup - works in POINTERS, not array index
       CTradingSetupSetting   *FindByIdentity(const string symbol)   const;
       bool                    Exists(const string symbol)           const { return FindByIdentity(symbol) != NULL; }

      //--- Add/Remove based on Symbol identity
       CTradingSetupSetting   *Add_TradingSetupSetting(const string symbol);   // NULL if identity already exists
       bool                    Delete_TradingSetupSetting(const string symbol);
       void                    GetLastRemoved(string &out_symbol)     const;
       void                    NotifySettingChanged(const string symbol);

      //--- Global Trailing-by-Value bar shift (EA-wide, not per-Symbol) - see member comment
       int                     TrailingDataRatesIndex(void)         const { return m_trail_data_rates_index; }
       void                    TrailingDataRatesIndex(const int shift)    { m_trail_data_rates_index = shift; }

      //--- JSON - reads/builds ONLY the "StopLost_Setting" + "Trailing_DataRatesIndex" sections, does NOT FileOpen/write except
      //--- in SaveTradingSetupSettingToJSON (which also preserves every OTHER top-level section,
      //--- same "each Save builds only its own section, other Managers' full-rewrite Saves learn to
      //--- preserve it too" rule as CSymbolTFManager/CIndicatorTemplateManager).
       bool                    LoadTradingSetupSettingFromJSON(const string full_path);
       void                    BuildJsonSection(string &out_json)   const;
       bool                    SaveTradingSetupSettingToJSON(void);

       virtual void            Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| Identity-based lookup - returns the row itself, not an index      |
 //+------------------------------------------------------------------+
 CTradingSetupSetting *CTradingSetupSettingManager::FindByIdentity(const string symbol) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CTradingSetupSetting *row = m_list.At(i);
       if(row != NULL && row.Symbol() == symbol) return row;
      }
     return NULL;
   }
 //+------------------------------------------------------------------+
 //| Append a new row - Data only, NULL if the identity already exists |
 //+------------------------------------------------------------------+
 CTradingSetupSetting *CTradingSetupSettingManager::Add_TradingSetupSetting(const string symbol)
  {
   if(Exists(symbol))
    {
     return NULL;
    }
   CTradingSetupSetting *row = new CTradingSetupSetting();   // constructor already defaults SL/Trailing fields
   row.Symbol(symbol);
   if(!m_list.Add(row))
    {
     delete row;
     return NULL;
    }
   ::EventChartCustom(::ChartID(), (ushort)TRADING_SETUP_MANAGER_EVENT_ADDED, (long)(m_list.Total() - 1), 0.0, symbol);
   return row;
  }
 //+------------------------------------------------------------------+
 //| Remove a row by identity - Data only                              |
 //+------------------------------------------------------------------+
 bool CTradingSetupSettingManager::Delete_TradingSetupSetting(const string symbol)
  {
   for(int i = 0; i < m_list.Total(); i++)
    {
     CTradingSetupSetting *row = m_list.At(i);
     if(row == NULL || row.Symbol() != symbol) continue;
     m_last_removed_symbol = symbol;
     if(!m_list.Delete(i)) return false;   // FreeMode default true - deletes the CTradingSetupSetting too
     ::EventChartCustom(::ChartID(), (ushort)TRADING_SETUP_MANAGER_EVENT_DELETE, 0, 0.0, symbol);
     return true;
    }
   ::Print(__FUNCTION__, " > rejected: no row for this identity");
   return false;
  }
 //+------------------------------------------------------------------+
 //| Identity of the row most recently removed - see declaration.      |
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::GetLastRemoved(string &out_symbol) const
   {
     out_symbol = m_last_removed_symbol;
   }
 //+------------------------------------------------------------------+
 //| An existing row's fields were edited+Saved - no Add/Remove.       |
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::NotifySettingChanged(const string symbol)
   {
     ::EventChartCustom(::ChartID(), (ushort)TRADING_SETUP_MANAGER_EVENT_CHANGED, 0, 0.0, symbol);
   }
 //+------------------------------------------------------------------+
 //| Lifecycle. EA.mq5 calls this from its own OnInit() - same         |
 //| convention as CSymbolTFManager::OnInitEvent. No "ensure current   |
 //| chart's Symbol exists" step here (unlike SymbolTF) - rows are     |
 //| created lazily, only once the user actually opens+Saves the       |
 //| StopLost form for a Symbol.                                       |
 //+------------------------------------------------------------------+
 bool CTradingSetupSettingManager::OnInitEvent(void)
   {
     if(m_loaded_from_json) return true;   // skip on a CHARTCHANGE reinit
     string full_path = g_ea_folder + "/Config_Setting.json";
     bool ok = LoadTradingSetupSettingFromJSON(full_path);
     m_loaded_from_json = true;
     return ok;
   }
 //+------------------------------------------------------------------+
 //| Read a "trail_ind_params" array of {"type":N,"i":longval,"d":dblval}
 //| objects - the RESOLVED MqlParam struct fields, written straight from
 //| a live CIndicatorDE's own GetMqlParams() (see BuildJsonSection). No
 //| schema/catalog needed to decode (unlike Indicator_Templates' own
 //| human-authored param text) - Trailing's Indicator side isn't
 //| restricted to one type+param-count like StopLost's ATR-only case
 //| (PSAR has 2 double params, MA/MACD have their own shapes), so this
 //| just round-trips whatever the source MqlParam[] actually was.
 //+------------------------------------------------------------------+
 int CTradingSetupSettingManager::ReadMqlParamArray(const string &s, int pos, MqlParam &out[])
  {
   ::ArrayResize(out, 0);
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[') return pos;
   pos++; // skip '['
   pos = JSONConfig_SkipSpace(s, pos);
   while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
    {
     if(StringGetCharacter(s, pos) != '{') { pos = JSONConfig_SkipValue(s, pos); pos = JSONConfig_SkipSpace(s, pos); continue; }
     pos++; // skip '{'
     pos = JSONConfig_SkipSpace(s, pos);
     int type_code = 0; long ival = 0; double dval = 0;
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
      {
       string key; string num_text;
       pos = JSONConfig_ReadString(s, pos, key);
       pos = JSONConfig_SkipSpace(s, pos);
       if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':') pos++;
       pos = JSONConfig_SkipSpace(s, pos);
       if(key == "type") { pos = JSONConfig_ReadRawNumber(s, pos, num_text); type_code = (int)StringToInteger(num_text); }
       else if(key == "i") { pos = JSONConfig_ReadRawNumber(s, pos, num_text); ival = StringToInteger(num_text); }
       else if(key == "d") { pos = JSONConfig_ReadRawNumber(s, pos, num_text); dval = StringToDouble(num_text); }
       else pos = JSONConfig_SkipValue(s, pos);
       pos = JSONConfig_SkipSpace(s, pos);
      }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}') pos++;
     int sz = ::ArraySize(out);
     ::ArrayResize(out, sz + 1);
     out[sz].type = (ENUM_DATATYPE)type_code;
     out[sz].integer_value = ival;
     out[sz].double_value  = dval;
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
   return pos;
  }
 //+------------------------------------------------------------------+
 //| Parse one { "m_symbol": "...", ... } object into a fresh row.     |
 //| StopLost's Indicator side is ATR-only in this codebase's current   |
 //| UI - any other "m_sl_ind_type" text is silently ignored (row keeps |
 //| whatever default the constructor set). Trailing's Indicator side   |
 //| is generic (see ReadMqlParamArray above).                          |
 //+------------------------------------------------------------------+
 int CTradingSetupSettingManager::ReadTradingSetupEntry(const string &s, int pos, CTradingSetupSetting *&out_row)
  {
   out_row = NULL;
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{') return pos;
   pos++; // skip '{'
   pos = JSONConfig_SkipSpace(s, pos);
   string symbol = "", ind_tf_text = "", ind_type_text = "", num_text;
   bool   sl_active = false;
   int    sl_mode = 0;
   double sl_fixed_mult = 1.0, sl_ind_mult = 1.0;
   int    sl_ind_period = 14;
   bool   trail_active = false;
   int    trail_mode = 0;
   int    trail_offset = 0, trail_start = 0, trail_step = 0;
   string trail_ind_tf_text = "";
   ENUM_INDICATOR trail_ind_type = WRONG_VALUE;
   MqlParam trail_ind_params[];
   while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
    {
     string key;
     pos = JSONConfig_ReadString(s, pos, key);
     pos = JSONConfig_SkipSpace(s, pos);
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':') pos++;
     pos = JSONConfig_SkipSpace(s, pos);
     if(key == "m_symbol")
      pos = JSONConfig_ReadString(s, pos, symbol);
     else if(key == "m_sl_active")
      pos = IndicatorConfig_ReadBool(s, pos, sl_active);
     else if(key == "m_sl_mode")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); sl_mode = (int)StringToInteger(num_text); }
     else if(key == "m_sl_fixed_mult")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); sl_fixed_mult = StringToDouble(num_text); }
     else if(key == "m_sl_ind_tf")
      pos = JSONConfig_ReadString(s, pos, ind_tf_text);
     else if(key == "m_sl_ind_type")
      pos = JSONConfig_ReadString(s, pos, ind_type_text);
     else if(key == "m_sl_ind_period")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); sl_ind_period = (int)StringToInteger(num_text); }
     else if(key == "m_sl_ind_multiplier")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); sl_ind_mult = StringToDouble(num_text); }
     else if(key == "m_trail_active")
      pos = IndicatorConfig_ReadBool(s, pos, trail_active);
     else if(key == "m_trail_mode")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); trail_mode = (int)StringToInteger(num_text); }
     else if(key == "m_trail_offset_pts")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); trail_offset = (int)StringToInteger(num_text); }
     else if(key == "m_trail_start_pts")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); trail_start = (int)StringToInteger(num_text); }
     else if(key == "m_trail_step_pts")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); trail_step = (int)StringToInteger(num_text); }
     else if(key == "m_trail_ind_tf")
      pos = JSONConfig_ReadString(s, pos, trail_ind_tf_text);
     else if(key == "m_trail_ind_type")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); trail_ind_type = (ENUM_INDICATOR)StringToInteger(num_text); }
     else if(key == "m_trail_ind_params")
      pos = ReadMqlParamArray(s, pos, trail_ind_params);
     else
      pos = JSONConfig_SkipValue(s, pos);   // unrecognized key
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}') pos++;
   if(symbol == "") return pos;   // malformed/empty slot - skip
   out_row = new CTradingSetupSetting();
   out_row.Symbol(symbol);
   out_row.StopLostActive(sl_active);
   out_row.StopLostMode((ENUM_STOPLOST_TRAILING_MODE)sl_mode);
   out_row.StopLostFixedMultiplier(sl_fixed_mult);
   if(ind_type_text == "ATR")
    {
     out_row.StopLostIndTF(TimestampByDescription(ind_tf_text));
     out_row.StopLostIndType(IND_ATR);
     MqlParam p[1];
     p[0].type          = TYPE_INT;
     p[0].integer_value = sl_ind_period;
     out_row.SetStopLostIndParams(p);
     out_row.StopLostIndMultiplier(sl_ind_mult);
    }
   out_row.TrailingActive(trail_active);
   out_row.TrailingMode((ENUM_STOPLOST_TRAILING_MODE)trail_mode);
   out_row.TrailingOffsetPts(trail_offset);
   out_row.TrailingStartPts(trail_start);
   out_row.TrailingStepPts(trail_step);
   if(trail_ind_type != WRONG_VALUE)
    {
     out_row.TrailingIndTF(TimestampByDescription(trail_ind_tf_text));
     out_row.TrailingIndType(trail_ind_type);
     out_row.SetTrailingIndParams(trail_ind_params);
    }
   return pos;
  }
 //+------------------------------------------------------------------+
 //| Parse the "StopLost_Setting" array, appending 1 row per entry     |
 //+------------------------------------------------------------------+
 int CTradingSetupSettingManager::ReadTradingSetupEntryArray(const string &s, int pos)
  {
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[') return pos;
   pos++; // skip '['
   pos = JSONConfig_SkipSpace(s, pos);
   while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
    {
     CTradingSetupSetting *row = NULL;
     pos = ReadTradingSetupEntry(s, pos, row);
     if(row != NULL && !m_list.Add(row)) delete row;
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
   return pos;
  }
 //+------------------------------------------------------------------+
 //| Load Config_Setting.json's "StopLost_Setting" section straight    |
 //| into m_list - clears whatever was there first.                    |
 //+------------------------------------------------------------------+
 bool CTradingSetupSettingManager::LoadTradingSetupSettingFromJSON(const string full_path)
  {
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "") return false;
   string clean = JSONConfig_StripComments(content);
   m_list.Clear();
   int pos = JSONConfig_SkipSpace(clean, 0);
   if(pos >= StringLen(clean) || StringGetCharacter(clean, pos) != '{')
    {
     ::Print(__FUNCTION__, " > top-level JSON must be an object");
     return false;
    }
   pos++; // skip '{'
   pos = JSONConfig_SkipSpace(clean, pos);
   while(pos < StringLen(clean) && StringGetCharacter(clean, pos) != '}')
    {
     string key;
     pos = JSONConfig_ReadString(clean, pos, key);
     pos = JSONConfig_SkipSpace(clean, pos);
     if(pos < StringLen(clean) && StringGetCharacter(clean, pos) == ':') pos++;
     pos = JSONConfig_SkipSpace(clean, pos);
     if(key == "StopLost_Setting")
      pos = ReadTradingSetupEntryArray(clean, pos);
     else if(key == "Trailing_DataRatesIndex")
      { string num_text; pos = JSONConfig_ReadRawNumber(clean, pos, num_text); m_trail_data_rates_index = (int)StringToInteger(num_text); }
     else
      pos = JSONConfig_SkipValue(clean, pos);   // not this Manager's key
     pos = JSONConfig_SkipSpace(clean, pos);
    }
   ::Print(__FUNCTION__, " > loaded ", m_list.Total(), " StopLost setting row(s) from ", full_path);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Build ONLY the "StopLost_Setting": [...] text - caller still owns |
 //| FileOpen/write + preserving the OTHER sections, same "each Save   |
 //| builds only its own section" rule the other Managers follow. Each |
 //| row carries BOTH StopLost and Trailing fields together (one row = |
 //| one Symbol's whole CTradingSetupSetting, matching the class shape).|
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::BuildJsonSection(string &out_json) const
  {
   out_json = "[\n";
   int saved = 0;
   for(int i = 0; i < m_list.Total(); i++)
    {
     CTradingSetupSetting *row = m_list.At(i);
     if(row == NULL || row.Symbol() == "") continue;
     if(saved > 0) out_json += ",\n";
     saved++;
     bool has_ind = (row.StopLostIndType() == IND_ATR);
     string ind_tf_text = has_ind ? TimeframeDescription(row.StopLostIndTF()) : "";
     int    ind_period   = 14;
     if(has_ind)
      {
       MqlParam p[];
       row.GetStopLostIndParams(p);
       if(::ArraySize(p) > 0) ind_period = (int)p[0].integer_value;
      }
     MqlParam trail_ind_params[];
     row.GetTrailingIndParams(trail_ind_params);
     bool trail_has_ind = (row.TrailingIndType() != WRONG_VALUE && ::ArraySize(trail_ind_params) > 0);
     string trail_ind_json;
     BuildMqlParamArrayJson(trail_ind_params, trail_ind_json);

     out_json += "  { \"m_symbol\": \"" + row.Symbol() + "\", \"m_sl_active\": " + (row.StopLostActive() ? "true" : "false") +
                 ", \"m_sl_mode\": " + (string)(int)row.StopLostMode() +
                 ", \"m_sl_fixed_mult\": " + ::DoubleToString(row.StopLostFixedMultiplier(), 4) +
                 ", \"m_sl_ind_type\": \"" + (has_ind ? "ATR" : "") + "\"" +
                 ", \"m_sl_ind_tf\": \"" + ind_tf_text + "\"" +
                 ", \"m_sl_ind_period\": " + (string)ind_period +
                 ", \"m_sl_ind_multiplier\": " + ::DoubleToString(row.StopLostIndMultiplier(), 4) +
                 ", \"m_trail_active\": " + (row.TrailingActive() ? "true" : "false") +
                 ", \"m_trail_mode\": " + (string)(int)row.TrailingMode() +
                 ", \"m_trail_offset_pts\": " + (string)row.TrailingOffsetPts() +
                 ", \"m_trail_start_pts\": " + (string)row.TrailingStartPts() +
                 ", \"m_trail_step_pts\": " + (string)row.TrailingStepPts() +
                 ", \"m_trail_ind_tf\": \"" + (trail_has_ind ? TimeframeDescription(row.TrailingIndTF()) : "") + "\"" +
                 ", \"m_trail_ind_type\": " + (string)(trail_has_ind ? (int)row.TrailingIndType() : (int)WRONG_VALUE) +
                 ", \"m_trail_ind_params\": " + trail_ind_json + " }";
    }
   out_json += "\n ]";
  }
 //+------------------------------------------------------------------+
 //| Write a MqlParam[] as [{"type":N,"i":longval,"d":dblval}, ...] -   |
 //| see ReadMqlParamArray for why this stores resolved struct fields   |
 //| directly instead of the schema-driven human text IndicatorTemplate |
 //| uses.                                                              |
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::BuildMqlParamArrayJson(MqlParam &params[], string &out_json) const
  {
   out_json = "[";
   int total = ::ArraySize(params);
   for(int i = 0; i < total; i++)
    {
     if(i > 0) out_json += ", ";
     out_json += "{\"type\": " + (string)(int)params[i].type +
                 ", \"i\": " + (string)params[i].integer_value +
                 ", \"d\": " + ::DoubleToString(params[i].double_value, 8) + "}";
    }
   out_json += "]";
  }
 //+------------------------------------------------------------------+
 //| Full save - owns FileOpen/write for Config_Setting.json. Reads the |
 //| file back first so every OTHER known section survives untouched   |
 //| as raw text - only "StopLost_Setting" gets overwritten with fresh |
 //| data. Every OTHER Manager's own full-rewrite Save must likewise   |
 //| learn to extract+preserve "StopLost_Setting" now that it exists.  |
 //+------------------------------------------------------------------+
 bool CTradingSetupSettingManager::SaveTradingSetupSettingToJSON(void)
  {
   string full_path = g_ea_folder + "/Config_Setting.json";
   string existing = JSONConfig_ReadWholeFile(full_path);
   string symbols_tf     = JSONConfig_ExtractRawSection(existing, "Symbols_TFs_List");
   string indicator_templates = JSONConfig_ExtractRawSection(existing, "Indicator_Templates");
   string markers        = JSONConfig_ExtractRawSection(existing, "Markers_Setting");
   string pattern_alerts = JSONConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");
   string sound_settings = JSONConfig_ExtractRawSection(existing, "Sound_Settings");
   string own_section;
   BuildJsonSection(own_section);
   string json = "{\n \"StopLost_Setting\": " + own_section +
                 ",\n \"Trailing_DataRatesIndex\": " + (string)m_trail_data_rates_index;
   if(symbols_tf != "")         json += ",\n \"Symbols_TFs_List\": " + symbols_tf;
   if(indicator_templates != "") json += ",\n \"Indicator_Templates\": " + indicator_templates;
   if(markers != "")            json += ",\n \"Markers_Setting\": " + markers;
   if(pattern_alerts != "")     json += ",\n \"Pattern_Alerts_Setting\": " + pattern_alerts;
   if(sound_settings != "")     json += ",\n \"Sound_Settings\": " + sound_settings;
   json += "\n}\n";
   int fh = ::FileOpen(full_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(fh == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > cannot open ", full_path, " for writing, err=", ::GetLastError());
     return false;
    }
   ::FileWriteString(fh, json);
   ::FileClose(fh);
   ::Print(__FUNCTION__, " > saved ", m_list.Total(), " StopLost setting row(s) to ", full_path);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Debug dump - README Working Rule Print Debug format                |
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print("CTradingSetupSettingManager::Print total=", m_list.Total());
     for(int i = 0; i < m_list.Total(); i++)
      {
       CTradingSetupSetting *row = m_list.At(i);
       if(row != NULL) row.Print(full_prop, true);
      }
   }
#endif // CTRADINGSETUPSETTINGMANAGER_MQH_DECLARATION
#endif // CTRADINGSETUPSETTINGMANAGER_MQH
