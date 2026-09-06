//+------------------------------------------------------------------+
//|                                        SymbolTFManager.mqh       |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for Symbol+TF rows -|
//| same pattern as CIndicatorTemplateManager, including its own      |
//| event chain (ADDED/DELETE) so both CGUIPannel (Table/TreeView     |
//| refresh) and EA (future Layer 1 series management) can react      |
//| independently, same split already established for indicators.    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------+
//| CSymbolTFManager - Center Point of Data (Single Source of Truth).                  |
//| Owns the CArrayObj list + "Symbols_TFs_List" JSON section.                         |
//+------------------------------------------------------------------------------------+
#ifndef CSYMBOLTFMANAGER_MQH
#define CSYMBOLTFMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include "SymbolTFSetting.mqh" 
 #include "JSONConfig.mqh" 
 #include "IndicatorTemplateManager.mqh"
 extern string g_ea_folder;  // From EA - same pattern IndicatorTemplateManager.mqh uses
 //+------------------------------------------------------------------------------------+
 //| Events CSymbolTFManager fires whenever Data genuinely changes - same principle as   |
 //| ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT (row-level only, no "type" grouping concept   |
 //| here).                                                                              |
 //+------------------------------------------------------------------------------------+
 enum ENUM_SYMBOLTF_MANAGER_EVENT
  {
   SYMBOLTF_MANAGER_EVENT_NO_EVENT = INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED + 1,
   SYMBOLTF_MANAGER_EVENT_ADDED,           // a (symbol,tf) row was genuinely added
   SYMBOLTF_MANAGER_EVENT_DELETE,          // a (symbol,tf) row was genuinely removed
   SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED, // GUI-side intent (e.g. navigate) - not a Data
                                           // mutation, no row involved - lparam=tf, sparam=symbol 
   SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED, // an existing row's Buy/Sell signal setting was
                                           // toggled - fired directly by CGUIPannel (no Manager
                                           // method needed, same style as GUIPANNEL_EVENT_
                                           // PATTERN_BUYSELL_CHANGED), no payload - EA's own
                                           // reaction (CSignalBridgeWriter::ResetSignalBridge)
                                           // does a full re-read, not a per-row lookup (Anhnt, 2026-08-28)
  };
#ifndef CSYMBOLTFMANAGER_MQH_DECLARATION
#define CSYMBOLTFMANAGER_MQH_DECLARATION
 class CSymbolTFManager : public CBaseObj
   {
     private:
       CArrayObj   m_list;   //List of CSymbolTFSetting* in Template       
       string          m_last_removed_symbol;
       ENUM_TIMEFRAMES m_last_removed_tf;       
       string          m_active_sym;
       ENUM_TIMEFRAMES m_active_tf;       
       bool            m_loaded_from_json;
       int         ReadSymbolTFEntry(const string &s, int pos, CSymbolTFSetting *&out_row);
       int         ReadSymbolTFEntryArray(const string &s, int pos);

     public:
                     CSymbolTFManager(void) : m_last_removed_symbol(""), m_last_removed_tf(PERIOD_CURRENT),
                                               m_active_sym(""), m_active_tf(PERIOD_CURRENT),
                                               m_loaded_from_json(false) {}
                    ~CSymbolTFManager(void) {}

      //--- Lifecycle - same convention as CIndicatorTemplateManager::OnInitEvent.
       bool                OnInitEvent(void);

       int                 Total(void)                                        const { return m_list.Total();   }
       CSymbolTFSetting   *At(const int index)                                const { return m_list.At(index); }

      //--- identity-based lookup - works in POINTERS, not array index
       CSymbolTFSetting   *FindByIdentity(const string sym, const ENUM_TIMEFRAMES tf) const;
       bool                Exists(const string sym, const ENUM_TIMEFRAMES tf)         const { return FindByIdentity(sym, tf) != NULL; }

      //--Add,Remove in Template base on Symbol+TF identity
       CSymbolTFSetting   *Add_SymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf);   // NULL if identity already exists
       bool                Delete_SymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf);      
       void                GetLastRemoved(string &out_symbol, ENUM_TIMEFRAMES &out_tf) const;
       void                NotifySettingChanged(const string sym, const ENUM_TIMEFRAMES tf);
      //--- JSON - reads/builds ONLY the "Symbols_TFs_List" section, does NOT FileOpen/write -
       bool                         LoadSymbolTFSettingFromJSON(const string full_path);
       void                         BuildJsonSection(string &out_json)          const;       
       bool                         SaveSymbolTFSettingToJSON(void);
       virtual void                 Print(const bool full_prop=false, const bool dash=false);
   };
#endif // CSYMBOLTFMANAGER_MQH_DECLARATION
#ifndef CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
#define CSYMBOLTFMANAGER_MQH_IMPLEMENTATION 
 int CSymbolTFManager::ReadSymbolTFEntry(const string &s, int pos, CSymbolTFSetting *&out_row)
  {
   out_row = NULL;
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{') return pos;
   pos++; // skip '{'
   pos = JSONConfig_SkipSpace(s, pos);
   string symbol = "", tf_text = "";
   bool   buy = true, sell = true, sound = true, message = true;
   while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
    {
     string key;
     pos = JSONConfig_ReadString(s, pos, key);
     pos = JSONConfig_SkipSpace(s, pos);
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':') pos++;
      pos = JSONConfig_SkipSpace(s, pos);
     if(key == "m_symbol")
      pos = JSONConfig_ReadString(s, pos, symbol);
     else if(key == "tf_text") 
      pos = JSONConfig_ReadString(s, pos, tf_text);
     else if(key == "m_buy_signal")
      pos = IndicatorConfig_ReadBool(s, pos, buy);
     else if(key == "m_sell_signal")
      pos = IndicatorConfig_ReadBool(s, pos, sell);
     else if(key == "m_sound_alert")
      pos = IndicatorConfig_ReadBool(s, pos, sound);
     else if(key == "m_message_alert")
      pos = IndicatorConfig_ReadBool(s, pos, message);
     else
      pos = JSONConfig_SkipValue(s, pos);   // unrecognized key - skip its value, keep pos in sync
      pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}') pos++;
   if(symbol == "") return pos;   // malformed/empty slot - skip
   out_row = new CSymbolTFSetting();
   out_row.Symbol(symbol);
   out_row.TFEnum(TimestampByDescription(tf_text));
   out_row.BuySignal(buy);
   out_row.SellSignal(sell);
   out_row.SoundAlert(sound);
   out_row.MessageAlert(message);
     return pos;
  }
 //+------------------------------------------------------------------+
 //| Parse the "Symbols_TFs_List" array, appending 1 row per entry     |
 //+------------------------------------------------------------------+
 int CSymbolTFManager::ReadSymbolTFEntryArray(const string &s, int pos)
  {
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[') return pos;
   pos++; // skip '['
   pos = JSONConfig_SkipSpace(s, pos);
   while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
    {
     CSymbolTFSetting *row = NULL;
     pos = ReadSymbolTFEntry(s, pos, row);
     if(row != NULL && !m_list.Add(row)) delete row;
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
   return pos;
  }
 //+------------------------------------------------------------------+
 //| Load Config_Setting.json's "Symbols_TFs_List" section straight    |
 //| into m_list - clears whatever was there first.                    |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::LoadSymbolTFSettingFromJSON(const string full_path)
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
     if(key == "Symbols_TFs_List")
      pos = ReadSymbolTFEntryArray(clean, pos);
     else
      pos = JSONConfig_SkipValue(clean, pos);   // not this Manager's key - e.g. "Indicator_Templates"
     pos = JSONConfig_SkipSpace(clean, pos);
    }
   ::Print(__FUNCTION__, " > loaded ", m_list.Total(), " symbol/TF pair(s) from ", full_path);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Build ONLY the "Symbols_TFs_List": [...] text - caller still owns |
 //| FileOpen/write + preserving the OTHER sections, same "each Save   |
 //| builds only its own section" rule the Indicator side follows.     |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::BuildJsonSection(string &out_json) const
  {
   out_json = "[\n";
   int saved = 0;
   for(int i = 0; i < m_list.Total(); i++)
    {
     CSymbolTFSetting *row = m_list.At(i);
     if(row == NULL || row.Symbol() == "") continue;
     if(saved > 0) out_json += ",\n";
     saved++;
     out_json += "  { \"m_symbol\": \"" + row.Symbol() + "\", \"tf_text\": \"" + row.TFText() +
                 "\", \"m_buy_signal\": " + (row.BuySignal() ? "true" : "false") +
                 ", \"m_sell_signal\": " + (row.SellSignal() ? "true" : "false") +
                 ", \"m_sound_alert\": " + (row.SoundAlert() ? "true" : "false") +
                 ", \"m_message_alert\": " + (row.MessageAlert() ? "true" : "false") + " }";
    }
   out_json += "\n ]";
  }
 //+------------------------------------------------------------------+
 //| Full save - owns FileOpen/write for Config_Setting.json. Reads the |
 //| file back first so "Indicator_Templates" (and any future section  |
 //| this Manager doesn't know about) survives untouched as raw text - |
 //| only "Symbols_TFs_List" gets overwritten with fresh data.          |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::SaveSymbolTFSettingToJSON(void)
  {
   string full_path = g_ea_folder + "/Config_Setting.json";
   string existing = JSONConfig_ReadWholeFile(full_path);
   string indicator_templates = JSONConfig_ExtractRawSection(existing, "Indicator_Templates");
   string markers        = JSONConfig_ExtractRawSection(existing, "Markers_Setting");
   string pattern_alerts = JSONConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");
   string sound_settings = JSONConfig_ExtractRawSection(existing, "Sound_Settings");
   string own_section;
   BuildJsonSection(own_section);
   string json = "{\n \"Symbols_TFs_List\": " + own_section +
                 ",\n \"Indicator_Templates\": " + (indicator_templates == "" ? "[\n ]" : indicator_templates);
   if(markers != "")        json += ",\n \"Markers_Setting\": " + markers;
   if(pattern_alerts != "") json += ",\n \"Pattern_Alerts_Setting\": " + pattern_alerts;
   if(sound_settings != "") json += ",\n \"Sound_Settings\": " + sound_settings;
   json += "\n}\n";
   int fh = ::FileOpen(full_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(fh == INVALID_HANDLE)
    {
    ::Print(__FUNCTION__, " > cannot open ", full_path, " for writing, err=", ::GetLastError());
    return false;
   }
   ::FileWriteString(fh, json);
   ::FileClose(fh);
     ::Print(__FUNCTION__, " > saved ", m_list.Total(), " symbol/TF pair(s) to ", full_path);
     return true;
  } 
 //+------------------------------------------------------------------+
 //| Identity-based lookup - returns the row itself, not an index      |
 //+------------------------------------------------------------------+
 CSymbolTFSetting *CSymbolTFManager::FindByIdentity(const string sym, const ENUM_TIMEFRAMES tf) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CSymbolTFSetting *row = m_list.At(i);
       if(row != NULL && row.Symbol() == sym && row.TFEnum() == tf) return row;
      }
     return NULL;
   }
 //+------------------------------------------------------------------+
 //| Append a new row - Data only, NULL if the identity already exists |
 //+------------------------------------------------------------------+
 CSymbolTFSetting *CSymbolTFManager::Add_SymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf)
  {
   if(Exists(sym, tf))
    {
     ::Print("MY DEBUG CSymbolTFManager::Add_SymbolTFSetting: rejected, already exists ", sym, " ", EnumToString(tf));
     return NULL;
    }
   CSymbolTFSetting *row = new CSymbolTFSetting();   // constructor already defaults buy/sell to true
   row.Symbol(sym);
   row.TFEnum(tf);
   if(!m_list.Add(row))
    {
     delete row;
     return NULL;
    }
   ::Print("MY DEBUG CSymbolTFManager::Add_SymbolTFSetting: added ", sym, " ", EnumToString(tf),
           " at index=", m_list.Total() - 1, " - firing SYMBOLTF_MANAGER_EVENT_ADDED");
   m_active_sym = sym;   // this row becomes the active pair too - keeps a later
   m_active_tf  = tf;    // NotifySettingChanged()'s "old" lookup accurate
   ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_ADDED, (long)(m_list.Total() - 1), 0.0, "");
   return row;
  }
 //+------------------------------------------------------------------+
 //| Remove a row by identity - Data only                              |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Delete_SymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf)
  {
   for(int i = 0; i < m_list.Total(); i++)
    {
     CSymbolTFSetting *row = m_list.At(i);
     if(row == NULL || row.Symbol() != sym || row.TFEnum() != tf) continue;
     // Snapshot BEFORE deleting - see m_last_removed_symbol/tf declaration comment.
      m_last_removed_symbol = sym;
      m_last_removed_tf     = tf;
      if(!m_list.Delete(i)) return false;   // FreeMode default true - deletes the CSymbolTFSetting too
      ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_DELETE, 0, 0.0, "");
     return true;
    }
   ::Print(__FUNCTION__, " > rejected: no row for this identity");
   return false;
  }
 //+------------------------------------------------------------------+
 //| Identity of the row most recently removed - see declaration.      |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::GetLastRemoved(string &out_symbol, ENUM_TIMEFRAMES &out_tf) const
   {
     out_symbol = m_last_removed_symbol;
     out_tf     = m_last_removed_tf;
   }
 //+------------------------------------------------------------------+
 //| No row Add/Delete - see declaration comment.                      |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::NotifySettingChanged(const string sym, const ENUM_TIMEFRAMES tf)
   {
     string old_sym = m_active_sym;
     ENUM_TIMEFRAMES old_tf = m_active_tf;
     m_active_sym = sym;
     m_active_tf  = tf;
     // Pack both pairs into the event payload - old_tf in the low 32 bits, new_tf in the high
     // 32 bits of lparam; "old_sym|new_sym" in sparam. Any listener that needs more than
     // identity just calls FindByIdentity(sym, tf) itself once it has these 4 values.
     long packed_tf = ((long)tf << 32) | ((long)old_tf & 0xFFFFFFFF);
     string packed_sym = old_sym + "|" + sym;
     ::Print("MY DEBUG CSymbolTFManager::NotifySettingChanged: old_sym=", old_sym, " old_tf=", EnumToString(old_tf),
             " new_sym=", sym, " new_tf=", EnumToString(tf), " packed_sym=", packed_sym, " packed_tf=", packed_tf);
     ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED, packed_tf, 0.0, packed_sym);
   }
 
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as CIndicatorTemplateManager::        |
 //| OnInitEvent. EA.mq5 calls this from its own OnInit().             |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::OnInitEvent(void)
   {
     bool ok = true;
     if(!m_loaded_from_json)   // skip on a CHARTCHANGE reinit - see m_loaded_from_json declaration
      {
       string full_path = g_ea_folder + "/Config_Setting.json";
       ok = LoadSymbolTFSettingFromJSON(full_path);
       m_loaded_from_json = true;
      }
     string cur_sym = ::Symbol();
     ENUM_TIMEFRAMES cur_tf = (ENUM_TIMEFRAMES)::Period();
     if(!Exists(cur_sym, cur_tf))
       Add_SymbolTFSetting(cur_sym, cur_tf);   // also sets active pair, see there
     else
      {
       // already tracked - still need m_active_sym/tf accurate after this reinit, no event
       // needed (no row changed)
       m_active_sym = cur_sym;
       m_active_tf  = cur_tf;
      }
     return ok;
   }
 
 //+------------------------------------------------------------------+
 //| Debug dump - README Working Rule Print Debug format                |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print("CSymbolTFManager::Print total=", m_list.Total());
     for(int i = 0; i < m_list.Total(); i++)
      {
       CSymbolTFSetting *row = m_list.At(i);
       if(row != NULL) row.Print(full_prop, true);
      }
   }
#endif // CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
#endif // CSYMBOLTFMANAGER_MQH

