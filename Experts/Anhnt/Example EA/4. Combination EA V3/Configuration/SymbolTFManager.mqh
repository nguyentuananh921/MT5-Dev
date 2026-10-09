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
 #include "SymbolTFSetting.mqh" 
 #include "JSONConfig.mqh"
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\EventDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\TimeseriesDELib.mqh>  
 //#include "IndicatorTemplateManager.mqh" 
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
       //Private Method 
       int             ReadSymbolTFEntry(const string &s, int pos, CSymbolTFSetting *&out_row);
       int             ReadSymbolTFEntryArray(const string &s, int pos);
       int             FindInsertIndex(const string sym, const ENUM_TIMEFRAMES tf) const;

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
      //--- JSON - reads/builds ONLY the "Symbols_TFs_List" section; the file itself is written by
      //--- CGUIPannel::SaveAllSettingsToJSON (every Save rewrites the whole file from live values)
       bool                LoadSymbolTFSettingFromJSON(const string full_path);
       void                BuildJsonSection(string &out_json)          const;
       bool                Save(void);
       virtual void        Print(const bool full_prop=false, const bool dash=false);
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
     if(row != NULL && !::SymbolInfoInteger(row.Symbol(), SYMBOL_EXIST))
      {
       ::Print(__FUNCTION__, " > skipped ", row.Symbol(), " ", row.TFText(), ": symbol does not exist on this server");
       delete row;
       row = NULL;
      }
     if(row != NULL)
      {
       // Insert sorted here too (not just Add_SymbolTFSetting) - self-heals m_list's Symbol-grouped/
       // TF-ascending invariant even if Config_Setting.json was ever hand-edited out of order
       int insert_at = FindInsertIndex(row.Symbol(), row.TFEnum());
       bool inserted = (insert_at >= m_list.Total()) ? m_list.Add(row) : m_list.Insert(row, insert_at);
       if(!inserted) delete row;
      }
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
   ::Print("Complete ", __FUNCTION__, " > loaded ", m_list.Total(), " symbol/TF pair(s) from ", full_path);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Writes the "Symbols_TFs_List" key of Config_Setting.json, the     |
 //| other keys stay as they are                                       |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Save(void)
  {
   string value;
   this.BuildJsonSection(value);
   string full_path = this.GetFolderName() + "/Config_Setting.json";
   return ::JSONConfig_SaveSection(full_path, "Symbols_TFs_List", value);
  }
 //+------------------------------------------------------------------+
 //| Build ONLY the "Symbols_TFs_List": [...] text - caller still owns |
 //| FileOpen/write + preserving the OTHER sections, same "each Save   |
 //| builds only its own section" rule the Indicator side follows.     |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::BuildJsonSection(string &out_json) const
  {
   //--- m_list is already Symbol-grouped/TF-ascending (Add_SymbolTFSetting inserts at its sorted
   //--- position directly, via FindInsertIndex) - just walk it in order, no local re-sort needed
    int total = m_list.Total();
   out_json = "[\n";
   int saved = 0;
   for(int oi = 0; oi < total; oi++)
    {
     CSymbolTFSetting *row = m_list.At(oi);
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
 //| Insert position for (sym,tf) that keeps m_list itself Symbol-grouped
 //| (each Symbol's own block stays together, in the order that Symbol
 //| first appeared) then TF-ascending within each group - same rule
 //| every consumer (JSON save, Monitor table, ...) used to re-sort for
 //| itself. Sorting m_list ONCE here means none of them need to anymore
 //+------------------------------------------------------------------+
 int CSymbolTFManager::FindInsertIndex(const string sym, const ENUM_TIMEFRAMES tf) const
  {
   bool in_group = false;
   for(int i = 0; i < m_list.Total(); i++)
    {
     CSymbolTFSetting *existing = m_list.At(i);
     if(existing == NULL) continue;
     if(existing.Symbol() != sym)
      {
       if(in_group) return i;   // just passed this Symbol's own block - insert here
       continue;
      }
     in_group = true;
     if(IndexEnumTimeframe(tf) < IndexEnumTimeframe(existing.TFEnum())) return i;
    }
   return m_list.Total();   // new Symbol (own block appended at the end) or fits after the last TF of an existing block
  }
 //+------------------------------------------------------------------+
 //| Insert a new row at its sorted position - Data only, NULL if the  |
 //| identity already exists.                                          |
 //+------------------------------------------------------------------+
 CSymbolTFSetting *CSymbolTFManager::Add_SymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf)
  {
   if(Exists(sym, tf))
    {
     return NULL;
    }
   if(!::SymbolInfoInteger(sym, SYMBOL_EXIST))
    {
     ::Print(__FUNCTION__, " > rejected ", sym, ": symbol does not exist on this server");
     return NULL;
    }
   CSymbolTFSetting *row = new CSymbolTFSetting();   // constructor already defaults buy/sell to true
   row.Symbol(sym);
   row.TFEnum(tf);
   int insert_at = FindInsertIndex(sym, tf);
   bool inserted = (insert_at >= m_list.Total()) ? m_list.Add(row) : m_list.Insert(row, insert_at);
   if(!inserted)
    {
     delete row;
     return NULL;
    }
   m_active_sym = sym;   // this row becomes the active pair too - keeps a later
   m_active_tf  = tf;    // NotifySettingChanged()'s "old" lookup accurate
   // --- Identity (symbol via sparam, TF via lparam), NOT insert_at - EventChartCustom is queued/
   // async, and a sorted Insert() (unlike a plain Add()) can shift this row's position before the
   // event is dequeued if another row gets added in between; an index captured now can go stale by
   // the time a listener reads it. Passing identity directly is immune to that.
   ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_ADDED, (long)tf, 0.0, sym);
   return row;
  }
 //+------------------------------------------------------------------+
 //| Remove a row by identity - Data only                              |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Delete_SymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf)
  {
   if(sym == ::Symbol() && tf == (ENUM_TIMEFRAMES)::Period())
    {
     ::Print(__FUNCTION__, " > rejected: ", sym, " ", EnumToString(tf), " is this chart's own pair");
     return false;
    }
   for(int i = 0; i < m_list.Total(); i++)
    {
     CSymbolTFSetting *row = m_list.At(i);
     if(row == NULL || row.Symbol() != sym || row.TFEnum() != tf) continue;
     // Snapshot BEFORE deleting - see m_last_removed_symbol/tf declaration comment.
      m_last_removed_symbol = sym;
      m_last_removed_tf     = tf;
      if(!m_list.Delete(i)) return false;   // FreeMode default true - deletes the CSymbolTFSetting too
      ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_DELETE, (long)tf, 0.0, sym);
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
       string full_path = this.GetFolderName() + "/Config_Setting.json";
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

