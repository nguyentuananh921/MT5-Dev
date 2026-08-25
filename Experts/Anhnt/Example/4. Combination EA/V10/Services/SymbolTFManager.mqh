//+------------------------------------------------------------------+
//|                                        SymbolTFManager.mqh       |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for Symbol+TF rows -|
//| same pattern as CIndicatorTemplateManager, much simpler: no chart-|
//| attach concept (a Symbol+TF pair has nothing equivalent to Show/  |
//| Hide on chart), so no event chain either - nothing currently      |
//| reacts to a Symbol+TF Add/Remove the way GUI reacts to indicator  |
//| Add/Remove (GUIPannel_TabSettingSymbolTF.mqh's own comment: Delete|
//| here only takes effect in JSON, the running EA's live series stay |
//| until restart). Add an event chain later if/when a real listener  |
//| needs one - not invented ahead of need.                           |
//+------------------------------------------------------------------+
#ifndef __SYMBOLTFMANAGER_MQH__
#define __SYMBOLTFMANAGER_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include "SymbolTFSetting.mqh"
 // Shared low-level JSON tokenizer (SkipSpace/ReadString/ReadBool/SkipValue) - stays in
 // JSONConfig.mqh, reused here same as IndicatorTemplateManager.mqh does. This file owns
 // ONLY the "Symbols_TFs_List" domain-specific entry parsing - no SJsonSymbolTF struct
 // middleman (same "no struct middleman" principle IndicatorTemplateManager.mqh follows).
 #include "..\Anatoli Kazharski\JSONConfig.mqh"
 extern string g_ea_folder;  // From EA - same pattern IndicatorTemplateManager.mqh uses
 #ifndef CSYMBOLTFMANAGER_MQH_DECLARATION
 #define CSYMBOLTFMANAGER_MQH_DECLARATION
 //+------------------------------------------------------------------------------------+
 //| CSymbolTFManager - Center Point of Data (Single Source of Truth).                  |
 //| Owns the CArrayObj list + "Symbols_TFs_List" JSON section.                         |
 //+------------------------------------------------------------------------------------+
 class CSymbolTFManager : public CBaseObj
   {
     private:
       CArrayObj   m_list;   //List of CSymbolTFSetting* in Template
       int         ReadSymbolTFEntry(const string &s, int pos, CSymbolTFSetting *&out_row);
       int         ReadSymbolTFEntryArray(const string &s, int pos);
       int         IndexOfIdentity(const string sym, const ENUM_TIMEFRAMES tf) const;

     public:
                     CSymbolTFManager(void) {}
                    ~CSymbolTFManager(void) {}

      //--- Lifecycle - same convention as CIndicatorTemplateManager::OnInitEvent.
       bool                OnInitEvent(void);

       int                 Total(void)                                        const { return m_list.Total();   }
       CSymbolTFSetting   *At(const int index)                                const { return m_list.At(index); }

      //--- identity-based lookup - works in POINTERS, not array index
       CSymbolTFSetting   *FindByIdentity(const string sym, const ENUM_TIMEFRAMES tf) const;
       bool                Exists(const string sym, const ENUM_TIMEFRAMES tf)         const { return FindByIdentity(sym, tf) != NULL; }

      //--Add,Remove in Template base on Symbol+TF identity
       CSymbolTFSetting   *Add(const string sym, const ENUM_TIMEFRAMES tf, const bool buy = true, const bool sell = true);   // NULL if identity already exists
       bool                RemoveByIdentity(const string sym, const ENUM_TIMEFRAMES tf);

       //--- JSON - reads/builds ONLY the "Symbols_TFs_List" section, does NOT FileOpen/write -
       bool                         LoadFromJSON(const string full_path);
       void                         BuildJsonSection(string &out_json)          const;
       virtual void                 Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| Identity-based lookup - returns the row itself, not an index      |
 //+------------------------------------------------------------------+
 CSymbolTFSetting *CSymbolTFManager::FindByIdentity(const string sym, const ENUM_TIMEFRAMES tf) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CSymbolTFSetting *row = m_list.At(i);
       if(row != NULL && row.MatchesIdentity(sym, tf)) return row;
      }
     return NULL;
   }
 //+------------------------------------------------------------------+
 //| Internal only - CArrayObj::Delete() takes an index, no delete-by- |
 //| pointer API exists in the Library. Not exposed publicly.          |
 //+------------------------------------------------------------------+
 int CSymbolTFManager::IndexOfIdentity(const string sym, const ENUM_TIMEFRAMES tf) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CSymbolTFSetting *row = m_list.At(i);
       if(row != NULL && row.MatchesIdentity(sym, tf)) return i;
      }
     return -1;
   }
 //+------------------------------------------------------------------+
 //| Append a new row - Data only, NULL if the identity already exists |
 //+------------------------------------------------------------------+
 CSymbolTFSetting *CSymbolTFManager::Add(const string sym, const ENUM_TIMEFRAMES tf, const bool buy = true, const bool sell = true)
   {
     if(Exists(sym, tf)) return NULL;
     CSymbolTFSetting *row = new CSymbolTFSetting();
     row.Symbol(sym);
     row.TFEnum(tf);
     row.BuySignal(buy);
     row.SellSignal(sell);
     if(!m_list.Add(row))
      {
       delete row;
       return NULL;
      }
     return row;
   }
 //+------------------------------------------------------------------+
 //| Remove a row by identity - Data only                              |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::RemoveByIdentity(const string sym, const ENUM_TIMEFRAMES tf)
   {
     int idx = IndexOfIdentity(sym, tf);
     if(idx < 0)
      {
       ::Print(__FUNCTION__, " > rejected: no row for this identity");
       return false;
      }
     return m_list.Delete(idx);   // FreeMode default true - deletes the CSymbolTFSetting too
   }
 //+------------------------------------------------------------------+
 //| Parse one { "symbol": "...", "tf": "...", "buy": ..., "sell": ... } |
 //| object straight into a fresh CSymbolTFSetting - malformed/empty     |
 //| symbol slot skipped, same as the old struct-array loader did.       |
 //+------------------------------------------------------------------+
 int CSymbolTFManager::ReadSymbolTFEntry(const string &s, int pos, CSymbolTFSetting *&out_row)
   {
     out_row = NULL;
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{') return pos;
     pos++; // skip '{'
     pos = IndicatorConfig_SkipSpace(s, pos);

     string symbol = "", tf_text = "";
     bool   buy = true, sell = true;
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
      {
       string key;
       pos = IndicatorConfig_ReadString(s, pos, key);
       pos = IndicatorConfig_SkipSpace(s, pos);
       if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':') pos++;
       pos = IndicatorConfig_SkipSpace(s, pos);
       if(key == "symbol")
          pos = IndicatorConfig_ReadString(s, pos, symbol);
       else if(key == "tf")
          pos = IndicatorConfig_ReadString(s, pos, tf_text);
       else if(key == "buy")
          pos = IndicatorConfig_ReadBool(s, pos, buy);
       else if(key == "sell")
          pos = IndicatorConfig_ReadBool(s, pos, sell);
       pos = IndicatorConfig_SkipSpace(s, pos);
      }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}') pos++;

     if(symbol == "") return pos;   // malformed/empty slot - skip

     out_row = new CSymbolTFSetting();
     out_row.Symbol(symbol);
     out_row.TFEnum(TimestampByDescription(tf_text));
     out_row.BuySignal(buy);
     out_row.SellSignal(sell);
     return pos;
   }
 //+------------------------------------------------------------------+
 //| Parse the "Symbols_TFs_List" array, appending 1 row per entry     |
 //+------------------------------------------------------------------+
 int CSymbolTFManager::ReadSymbolTFEntryArray(const string &s, int pos)
   {
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[') return pos;
     pos++; // skip '['
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
      {
       CSymbolTFSetting *row = NULL;
       pos = ReadSymbolTFEntry(s, pos, row);
       if(row != NULL && !m_list.Add(row)) delete row;
       pos = IndicatorConfig_SkipSpace(s, pos);
      }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
     return pos;
   }
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as CIndicatorTemplateManager::        |
 //| OnInitEvent. EA.mq5 calls this from its own OnInit().             |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::OnInitEvent(void)
   {
     string full_path = g_ea_folder + "/Config_Setting.json";
     bool ok = LoadFromJSON(full_path);
     string cur_sym = ::Symbol();
     ENUM_TIMEFRAMES cur_tf = (ENUM_TIMEFRAMES)::Period();
     if(!Exists(cur_sym, cur_tf))
       Add(cur_sym, cur_tf, true, true);
     return ok;
   }
 //+------------------------------------------------------------------+
 //| Load Config_Setting.json's "Symbols_TFs_List" section straight    |
 //| into m_list - clears whatever was there first.                    |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::LoadFromJSON(const string full_path)
   {
     string content = IndicatorConfig_ReadWholeFile(full_path);
     if(content == "") return false;
     string clean = IndicatorConfig_StripComments(content);
     m_list.Clear();

     int pos = IndicatorConfig_SkipSpace(clean, 0);
     if(pos >= StringLen(clean) || StringGetCharacter(clean, pos) != '{')
      {
       ::Print(__FUNCTION__, " > top-level JSON must be an object");
       return false;
      }
     pos++; // skip '{'
     pos = IndicatorConfig_SkipSpace(clean, pos);
     while(pos < StringLen(clean) && StringGetCharacter(clean, pos) != '}')
      {
       string key;
       pos = IndicatorConfig_ReadString(clean, pos, key);
       pos = IndicatorConfig_SkipSpace(clean, pos);
       if(pos < StringLen(clean) && StringGetCharacter(clean, pos) == ':') pos++;
       pos = IndicatorConfig_SkipSpace(clean, pos);
       if(key == "Symbols_TFs_List")
          pos = ReadSymbolTFEntryArray(clean, pos);
       else
          pos = IndicatorConfig_SkipValue(clean, pos);   // not this Manager's key - e.g. "Indicator_Templates"
       pos = IndicatorConfig_SkipSpace(clean, pos);
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
       out_json += "  { \"symbol\": \"" + row.Symbol() + "\", \"tf\": \"" + row.TFText() +
                   "\", \"buy\": " + (row.BuySignal() ? "true" : "false") +
                   ", \"sell\": " + (row.SellSignal() ? "true" : "false") + " }";
      }
     out_json += "\n ]";
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
 #endif // CSYMBOLTFMANAGER_MQH_DECLARATION
#endif // __SYMBOLTFMANAGER_MQH__
