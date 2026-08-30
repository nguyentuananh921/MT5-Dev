//+------------------------------------------------------------------+
//|                                     IndicatorTemplateManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for indicator       |
//| templates. EA owns THIS class directly (Implementaion Plan\       |
//| ImplementaionClassForSetting.md muc 2b) - CGUIPannel only holds   |
//| a pointer, same pattern as CTimeSeriesEngine/CTradingEngine.      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------+
//| CIndicatorTemplateManager - Center Point of Data (Single Source of Truth).         |
//| Owns the CArrayObj list + "Indicator_Templates" JSON section.                      |
//+------------------------------------------------------------------------------------+
#ifndef CINDICATORTEMPLATEMANAGER_MQH
#define CINDICATORTEMPLATEMANAGER_MQH
#include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
 #include "IndicatorSetting.mqh"
 // Shared low-level JSON tokenizer (SkipSpace/ReadString/ReadBool/SkipValue) + whole-file
 // read/raw-section utilities - used by every Manager/loader (muc 4b, ImplementaionClassForSetting.md).
 // ReadRawNumber/ReadParamsArray are NOT shared - only Indicator_Templates has a "params"
 // array field, so those two live below, right next to ReadTemplateEntry (their one caller).
 #include "JSONConfig.mqh"
 #include <Vendors\Anhnt\Library\4. Combination Lib\Defines\EventDefines.mqh>
 extern string g_ea_folder;  // From EA - same pattern TimeSeriesEngine.mqh already uses
 // From EA (Anhnt, 2026-08-30) - shared coordination flag: set true right before the EA itself
 // calls m_ChartObjCollection.RemoveIndicatorFromChart() (reacting to OUR OWN Data change), so
 // the resulting native DEL event's defensive full-table rescan below can skip itself instead of
 // misreading other untouched rows as also gone (BugNote 2026-08-28, "Setting Window treo cung").
 // Still set from 2 other EA::OnChartEvent blocks not yet migrated (SETTING_CHANGED/DELETE), so
 // stays a plain extern global rather than becoming a class member of just this one Manager.
 extern bool g_suppress_del_rescan;
 //--- SignalMarkers.mq5's own identity - moved here from the EA (Anhnt, 2026-08-30) so
 //--- OnChartEvent() below can filter it out itself ("tay nao lo viec tay ay" - the EA just
 //--- broadcasts the raw CHART_OBJ_EVENT_CHART_WND_IND_ADD event, this Manager owns deciding
 //--- whether it's a real Template indicator or just its own infrastructure). Still visible to
 //--- the EA too (EnsureMarkerIndicatorAttached/RemoveMarkerIndicator use it) since this header
 //--- is #included before those functions are defined. ENUM_INDICATOR can't carry a custom
 //--- "SignalMarker" sub-type - MQL5 always reports IND_CUSTOM for every custom indicator - so
 //--- identity still has to come from a name/path substring match.
 #define SIGNALMARKERS_PROGRAM_PATH "Vendors\\Anhnt\\Custom Buildin\\SignalMarkers"
 #define SIGNALMARKERS_NAME_TAG     "SignalMarkers"   // substring - matches both the program path AND the runtime "SignalMarkers(<symbol>)" short name
 // --- Chains off BARPATTERN_CONTROL_EVENTS_NEXT_CODE, not WF_CONTROL_EVENTS_NEXT_CODE directly
 // --- (Anhnt, 2026-08-30) - CBarPatternControl (BarPatternControl.mqh, pulled in by
 // --- GUIPannel_Define.mqh BEFORE this file) now owns the first link off
 // --- WF_CONTROL_EVENTS_NEXT_CODE with its own event chain; chaining off ITS last value here
 // --- instead avoids both chains claiming the same starting number.
 enum ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT
  {
   INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT = BARPATTERN_CONTROL_EVENTS_NEXT_CODE,
   INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED,        // a row (type,params) was genuinely added
   INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE,       // a row (type,params) was genuinely removed
   INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_ADDED,   // first row of this type just appeared
   INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_DELETE,  // last row of this type just disappeared
   // --- Split from a single generic SETTING_CHANGED (Anhnt, 2026-08-30) - "tay nao lo viec tay
   // --- ay": each listener only cared about ONE specific field, but every toggle woke all of
   // --- them up regardless (redundant IsIndicatorShownOnChart() scan on a Buy/Sell/Alert toggle,
   // --- redundant full SignalBridge rebuild on a Show/Alert toggle). Sound/Message Alert toggles
   // --- fire neither - nothing currently listens for those (they're read live at alert-fire time
   // --- by CSignalLogger, not reactively).
   INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED,     // ShowOnChart flipped - lparam=index
   INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED,  // Buy or Sell signal flipped - lparam=index
  };
#ifndef CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#define CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
 class CIndicatorTemplateManager : public CBaseObj
   {
     private:
       CArrayObj   m_list;   //List of CIndicatorSetting* in Template
       bool        m_suppress_event;   // true while OnInitEvent()'s chart-scan bulk-loads - avoids an event storm
       // --- Snapshot of the identity just removed - captured BEFORE m_list.Delete() so a
       // --- DELETE listener can still recover (type,params) even though the row itself is
       // --- gone by the time the (async) event is actually dispatched. Same "Last X" snapshot
       // --- convention CChartWnd::GetLastAddedIndicator()/GetLastDeletedIndicator() already use.
       ENUM_INDICATOR m_last_removed_type;
       MqlParam       m_last_removed_params[];
       // --- true once LoadFromJSON() has run once for this object's lifetime - same guard
       // --- CSymbolTFManager::m_loaded_from_json uses. A chart's own Symbol/TF change
       // --- (REASON_CHARTCHANGE) makes MT5 call OnDeinit+OnInit again on the SAME already-
       // --- loaded EA module - m_list here survives that reinit in memory, same as m_gui_created
       // --- proved. Without this guard, OnInitEvent() below was calling LoadFromJSON() (which
       // --- does m_list.Clear()) on EVERY reinit - wiping any indicator template added/changed
       // --- during the session but not yet saved, every single time the user navigated to a
       // --- new chart/TF (Anhnt, 2026-08-26).
       bool           m_loaded_from_json;
       int         ReadTemplateEntry(const string &s, int pos, CIndicatorSetting *&out_row);
       int         ReadTemplateEntryArray(const string &s, int pos);
       int         IndexOfIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
       bool        ExistsTypeInTemplate(const ENUM_INDICATOR type) const;   // true if ANY row of this type is present, regardless of params

     public:
                     CIndicatorTemplateManager(void) : m_suppress_event(false), m_last_removed_type(IND_CUSTOM), m_loaded_from_json(false) {}
                    ~CIndicatorTemplateManager(void) {}

      //--- Lifecycle - same convention as CTimeSeriesEngine::OnInitEvent/CGUIPannel::OnInitEvent.
      //--- chart_obj MUST already be built (CChartObjCollection::CreateCollection() already ran) -
      //--- loads JSON first, THEN merges in whatever's actually attached on the chart right now
      //--- (order matters: LoadFromJSON does m_list.Clear(), so scanning first would be wiped).
       bool                OnInitEvent(CChartObjCollection *chart_obj);

      //--- "tay nao lo viec tay ay" (Anhnt, 2026-08-30): EA broadcasts every OnChartEvent here
      //--- unconditionally, this Manager filters for CHART_OBJ_EVENT_CHART_WND_IND_ADD/CHANGE
      //--- itself and owns the full reaction (resolve handle->type/params, skip if it's our own
      //--- SignalMarkers infrastructure indicator, otherwise mark an existing row Shown / add a
      //--- brand new one / swap old identity for new). chart_obj is needed for CHANGE only (to
      //--- resolve the indicator now occupying the changed slot) - same pointer OnInitEvent already
      //--- takes. Moved out of EA::OnChartEvent, which used to do all of this inline.
       bool                OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam,
                                        CChartObjCollection *chart_obj);

       int                 Total(void)                                          const { return m_list.Total();   }
       CIndicatorSetting  *At(const int index)                                  const { return m_list.At(index); }

      //--- identity-based lookup - works in POINTERS, not array index 
       CIndicatorSetting  *FindByIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
       bool                Exists(const ENUM_INDICATOR type, MqlParam &params[])        const { return FindByIdentity(type, params) != NULL; }

      //--Add,Remove in Template base on indicator identity
       bool                AddIndicatorToIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[]);   // false if identity already exists - RAW identity only, callers never need the row pointer (ADDED event's lparam+At(index) covers that)
       bool                DeleteIndicatorFromIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[]);

      //--- Data only - mutates an EXISTING row's ShowOnChart preference and fires
      //--- INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED so EA (owns ChartObjCollection) can
      //--- react by attaching/detaching the indicator on chart.
       bool                UpdateRow_IndicatorTemplateSetting_ShowColumn(const int index, const bool show);

      //--- Identity of the row most recently removed by Delete_IndicatorTemplateSetting()
      //--- (see m_last_removed_type/params) - a DELETE listener reads this instead of
      //--- looking the row up in m_list, since it's already gone by then.
       void                GetLastRemoved(ENUM_INDICATOR &type, MqlParam &out_params[]) const;

       //--- JSON - reads/builds ONLY the "Indicator_Templates" section, does NOT FileOpen/write -
       bool                         LoadIndicatorTemplateSettingFromJSON(const string full_path);
       void                         BuildJsonSection(string &out_json)                    const;
       //--- Full save - THIS Manager owns FileOpen/write for Config_Setting.json: reads the file
       //--- back first, carries every OTHER top-level section through unchanged (raw text), and
       //--- overwrites only "Indicator_Templates" with fresh BuildJsonSection() output.
       bool                         SaveIndicatorTemplateToJSON(void);
       virtual void                 Print(const bool full_prop=false, const bool dash=false);
   };
#endif // CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#ifndef CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#define CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
 //For working with JSON
  //| Load Config_Setting.json's "Indicator_Templates" section straight |
  //| into m_list - clears whatever was there first. Mirrors the        |
  //| top-level object loop IndicatorConfig_ParseText used to run,      |
  //| scoped to ONLY this Manager's own key (muc 4b).                   |
  //+------------------------------------------------------------------+
  bool CIndicatorTemplateManager::LoadIndicatorTemplateSettingFromJSON(const string full_path)
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
       if(key == "Indicator_Templates")
          pos = ReadTemplateEntryArray(clean, pos);
       else
          pos = JSONConfig_SkipValue(clean, pos);   // not this Manager's key - e.g. "Symbols_TFs_List"
       pos = JSONConfig_SkipSpace(clean, pos);
      }
     ::Print(__FUNCTION__, " > loaded ", m_list.Total(), " indicator template(s) from ", full_path);
     return true;
   }
  //+------------------------------------------------------------------+
  //| Indicator_Templates-specific tokenizer helpers - not shared with any other      |
  //| loader (SymbolTF/Marker/Sound/Pattern have no "params" array concept), so they  |
  //| live here rather than in the generic JSONConfig.mqh.                            |
  //+------------------------------------------------------------------+
  //--- read a bare number (as raw text) starting at pos, return pos after the number
  int IndicatorConfig_ReadRawNumber(const string &s, int pos, string &out)
   {
     int len = StringLen(s);
     int start = pos;
     while(pos < len)
       {
        ushort c = StringGetCharacter(s, pos);
        if((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.' || c == 'e' || c == 'E')
           pos++;
        else
           break;
       }
     out = StringSubstr(s, start, pos - start);
     return pos;
   }
  //--- read a "params" array whose elements are EITHER a bare number OR a "quoted
  //--- string" (enum choice text) - both stored as raw text in out[], the caller
  //--- (ReadTemplateEntry) decides how to interpret each element via the schema.
  int IndicatorConfig_ReadParamsArray(const string &s, int pos, string &out[])
   {
    ArrayResize(out, 0);
    pos = JSONConfig_SkipSpace(s, pos);
    if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[')
      return pos;
    pos++; // skip '['
    pos = JSONConfig_SkipSpace(s, pos);
    while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
     {
      string value;
      if(StringGetCharacter(s, pos) == '"')
        pos = JSONConfig_ReadString(s, pos, value);
      else
        pos = IndicatorConfig_ReadRawNumber(s, pos, value);
      int sz = ArraySize(out);
      ArrayResize(out, sz + 1);
      out[sz] = value;
      pos = JSONConfig_SkipSpace(s, pos);
     }
    if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']')
      pos++; // skip ']'
    return pos;
    }
  //+------------------------------------------------------------------+
  //| Parse one { "type": "...", "buy": ..., "params": [...] } object,  |
  //| resolve .type_enum/.raw_params via catalog+schema, return a fresh |
  //| row (NULL if the type is unknown or the schema/param count        |
  //| mismatches - same rejection rules LoadIndicatorTemplateSettingFromJSON |
  //| used before this moved here).                                      |
  //+------------------------------------------------------------------+
  int CIndicatorTemplateManager::ReadTemplateEntry(const string &s, int pos, CIndicatorSetting *&out_row)
   {
     out_row = NULL;
     pos = JSONConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{') return pos;
     pos++; // skip '{'
     pos = JSONConfig_SkipSpace(s, pos);

     string type_text = "";
     string params_text[];
     // --- "show" is never read from JSON - it's chart-live truth (re-synced by
     // --- OnInitEvent()'s own chart scan + the CHART_OBJ_EVENT_*
     // --- handlers in EA.mq5), not a persisted preference. Every row starts false here;
     // --- the chart scan re-truths it to true right after Load for whatever's actually attached.
     bool   buy = false, sell = false, sound = false, message = false;
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
      {
       string key;
       pos = JSONConfig_ReadString(s, pos, key);
       pos = JSONConfig_SkipSpace(s, pos);
       if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':') pos++;
       pos = JSONConfig_SkipSpace(s, pos);
       if(key == "m_indicator_type")
          pos = JSONConfig_ReadString(s, pos, type_text);
       else if(key == "m_indicator_params")
          pos = IndicatorConfig_ReadParamsArray(s, pos, params_text);
       else if(key == "m_buy_signal")
          pos = IndicatorConfig_ReadBool(s, pos, buy);
       else if(key == "m_sell_signal")
          pos = IndicatorConfig_ReadBool(s, pos, sell);
       else if(key == "m_sound_alert")
          pos = IndicatorConfig_ReadBool(s, pos, sound);
       else if(key == "m_message_alert")
          pos = IndicatorConfig_ReadBool(s, pos, message);
       else
          pos = JSONConfig_SkipValue(s, pos);   // unrecognized key (e.g. a leftover "show"/old-style name from an older save) - skip its value, keep pos in sync
       pos = JSONConfig_SkipSpace(s, pos);
      }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}') pos++;

     //--- Resolve .type_enum/.raw_params[] HERE (Layer 1 never touches JSON/text at all,
     //--- same invariant LoadIndicatorTemplateSettingFromJSON already upheld)
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     ENUM_INDICATOR type_enum = IND_CUSTOM;
     bool type_found = false;
     for(int c = 0; c < ArraySize(catalog); c++)
        if(catalog[c].name == type_text) { type_enum = catalog[c].ind_type; type_found = true; break; }
     if(!type_found)
      {
       ::Print(__FUNCTION__, " > unknown indicator type \"", type_text, "\", skipped");
       return pos;
      }
     SIndicatorParam schema[];
     int schema_total = GetIndicatorParamSchema(type_enum, schema);
     if(schema_total == 0 || ArraySize(params_text) < schema_total)
      {
       ::Print(__FUNCTION__, " > \"", type_text, "\" param count/schema mismatch, skipped");
       return pos;
      }
     MqlParam raw_params[];
     ArrayResize(raw_params, schema_total);
     for(int p = 0; p < schema_total; p++)
      {
       raw_params[p].type = schema[p].data_type;
       string raw = params_text[p];
       if(schema[p].choices != "")
        {
         if(schema[p].choices == PRICE_CHOICES)
            raw_params[p].integer_value = (long)AppliedPriceByDescription(raw);
         else if(schema[p].choices == CALCULATION_METHOD_CHOICES)
            raw_params[p].integer_value = (long)AveragingMethodByDescription(raw);
         else if(schema[p].choices == VOLUME_CHOICES)
            raw_params[p].integer_value = (long)AppliedVolumeByDescription(raw);
         else if(schema[p].choices == STOCH_PRICE_CHOICES)
            raw_params[p].integer_value = (long)StochPriceByDescription(raw);
         else
            raw_params[p].integer_value = (long)StringToInteger(raw); // back-compat
        }
       else if(schema[p].data_type == TYPE_DOUBLE)
          raw_params[p].double_value = StringToDouble(raw);
       else
          raw_params[p].integer_value = StringToInteger(raw);
      }
     // type_text/params_text (as parsed from JSON) were only needed transiently, to resolve
     // raw_params[] via the schema just above - no stored text field to fill anymore
     // (CIndicatorSetting derives both display/JSON text on demand from type_enum/raw_params).
     out_row = new CIndicatorSetting();
     out_row.TypeEnum(type_enum);
     out_row.SetRawParams(raw_params);
     out_row.BuySignal(buy);
     out_row.SellSignal(sell);
     out_row.SoundAlert(sound);
     out_row.MessageAlert(message);
     // Ctor defaults ShowOnChart to true - override to false here since a JSON-loaded row
     // is never actually attached to the chart yet; the post-Load chart scan re-truths it.
     out_row.ShowOnChart(false);
     return pos;
   }
  //+------------------------------------------------------------------+
  //| Parse the "Indicator_Templates" array, appending 1 row per entry  |
  //+------------------------------------------------------------------+
  int CIndicatorTemplateManager::ReadTemplateEntryArray(const string &s, int pos)
   {
     pos = JSONConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[') return pos;
     pos++; // skip '['
     pos = JSONConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
      {
       CIndicatorSetting *row = NULL;
       pos = ReadTemplateEntry(s, pos, row);
       if(row != NULL && !m_list.Add(row)) delete row;
       pos = JSONConfig_SkipSpace(s, pos);
      }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
     return pos;
   }
  //+------------------------------------------------------------------+
  //| Build ONLY the "Indicator_Templates": [...] text - caller (EA/    |
  //| CGUIPannel) still owns FileOpen/write + preserving the OTHER      |
  //| sections, same "each Save builds only its own section" rule       |
  //| CGUIPannel::SaveGUIConfigToJSON already follows.                  |
  //+------------------------------------------------------------------+
  void CIndicatorTemplateManager::BuildJsonSection(string &out_json) const
   {
     out_json = "[\n";
     int saved = 0;
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     for(int i = 0; i < m_list.Total(); i++)
      {
       CIndicatorSetting *row = m_list.At(i);
       if(row == NULL || row.TypeEnum() == IND_CUSTOM) continue;
       // Both texts derived on demand from raw identity - no stored text field on
       // CIndicatorSetting anymore (2026-08-28), same catalog-name lookup AddIndicatorToIndicatorTemplateSetting
       // used to do, same BuildIndicatorParamsText() DisplayLabel() already calls for the short form.
       string type_key = "";
       for(int c = 0; c < ArraySize(catalog); c++)
          if(catalog[c].ind_type == row.TypeEnum()) { type_key = catalog[c].name; break; }
       if(type_key == "") continue;
       MqlParam raw_params[];
       row.GetRawParams(raw_params);
       if(saved > 0) out_json += ",\n";
       saved++;
       // "show" is chart-live truth, never persisted - see ReadTemplateEntry's comment.
       out_json += "  { \"m_indicator_type\": \"" + type_key + "\", \"m_buy_signal\": " + (row.BuySignal() ? "true" : "false") +
                   ", \"m_sell_signal\": " + (row.SellSignal() ? "true" : "false") +
                   ", \"m_sound_alert\": " + (row.SoundAlert() ? "true" : "false") +
                   ", \"m_message_alert\": " + (row.MessageAlert() ? "true" : "false") + ", \"m_indicator_params\": [";
       string params_text[];
       BuildIndicatorParamsText(row.TypeEnum(), raw_params, params_text);
       for(int p = 0; p < ArraySize(params_text); p++)
        {
         if(p > 0) out_json += ", ";
         string raw = params_text[p];
         // --- Re-quote unless every char is one IndicatorConfig_ReadRawNumber() would have
         // --- consumed (digits/-/+/./e/E) - a bare number was never quoted in the original file.
         bool is_number = (StringLen(raw) > 0);
         for(int c = 0; c < StringLen(raw) && is_number; c++)
          {
           ushort ch = StringGetCharacter(raw, c);
           is_number = ((ch >= '0' && ch <= '9') || ch == '-' || ch == '+' || ch == '.' || ch == 'e' || ch == 'E');
          }
         out_json += is_number ? raw : ("\"" + raw + "\"");
        }
       out_json += "] }";
      }
     out_json += "\n ]";
   }
  //+------------------------------------------------------------------+
  //| Full save - owns FileOpen/write for Config_Setting.json. Reads the |
  //| file back first so "Symbols_TFs_List" (and any future section     |
  //| this Manager doesn't know about) survives untouched as raw text - |
  //| only "Indicator_Templates" gets overwritten with fresh data.       |
  //+------------------------------------------------------------------+
  bool CIndicatorTemplateManager::SaveIndicatorTemplateToJSON(void)
   {
     string full_path = g_ea_folder + "/Config_Setting.json";
     string existing = JSONConfig_ReadWholeFile(full_path);
     string symbols_tf     = JSONConfig_ExtractRawSection(existing, "Symbols_TFs_List");
     string markers        = JSONConfig_ExtractRawSection(existing, "Markers_Setting");
     string pattern_alerts = JSONConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");
     string sound_settings = JSONConfig_ExtractRawSection(existing, "Sound_Settings");
     string own_section;
     BuildJsonSection(own_section);
     string json = "{\n \"Symbols_TFs_List\": " + (symbols_tf == "" ? "[\n ]" : symbols_tf) +
                   ",\n \"Indicator_Templates\": " + own_section;
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
     ::Print(__FUNCTION__, " > saved ", m_list.Total(), " indicator template(s) to ", full_path);
     return true;
   }
 //For modify
 //+------------------------------------------------------------------+
 //| Identity-based lookup - returns the row itself, not an index      |
 //+------------------------------------------------------------------+ 
 CIndicatorSetting *CIndicatorTemplateManager::FindByIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CIndicatorSetting *row = m_list.At(i);
       if(row != NULL && row.MatchesIdentity(type, params)) return row;
      }
     return NULL;
   }
 //+------------------------------------------------------------------+
 //| Internal only - CArrayObj::Delete() takes an index, no delete-by- |
 //| pointer API exists in the Library. Not exposed publicly.          |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::IndexOfIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CIndicatorSetting *row = m_list.At(i);
       if(row != NULL && row.MatchesIdentity(type, params)) return i;
      }
     return -1;
   }
 //+------------------------------------------------------------------+
 //| True if ANY row of this type is present, regardless of params -   |
 //| used to detect the first/last row of a type (Type Added/Delete).  |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::ExistsTypeInTemplate(const ENUM_INDICATOR type) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CIndicatorSetting *row = m_list.At(i);
       if(row != NULL && row.TypeEnum() == type) return true;
      }
     return false;
   }
 //+------------------------------------------------------------------+
 //| Append a new row - Data only, false if the identity already exists|
 //| Returns bool, not the row pointer - matches the RAW-identity-only |
 //| convention (type, params[]) every caller already uses; a caller   |
 //| that needs the new row reads it back via the ADDED event's        |
 //| lparam+At(index), or FindByIdentity(type, params) directly.       |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::AddIndicatorToIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
   {
     if(Exists(type, params)) return false;
     bool is_new_type = !ExistsTypeInTemplate(type);   // check BEFORE insert - "first row of this type"

     // Raw identity only - CIndicatorSetting has no stored text fields anymore (2026-08-28):
     // DisplayLabel()/CIndicatorTemplateManager::BuildJsonSection derive both texts on demand
     // from TypeEnum()/GetRawParams(), so nothing to build/store here at all.
     CIndicatorSetting *row = new CIndicatorSetting();   // constructor defaults buy/sell/sound/message = true
     row.TypeEnum(type);
     row.SetRawParams(params);
     if(!m_list.Add(row))
      {
       delete row;
       return false;
      }
     if(!m_suppress_event)
      {
       // lparam = index of the row just inserted (m_list.Total()-1) - lets a
       // receiver do At(index) to get the exact (type, raw_params) that was Added,
       // no separate id/lookup mechanism needed.
       ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED, (long)(m_list.Total() - 1), 0.0, "");
       if(is_new_type)
          ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_ADDED, (long)type, 0.0, "");
      }
     return true;
   }
 //+------------------------------------------------------------------+
 //| Remove a row by identity - Data only                              |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::DeleteIndicatorFromIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
   {
     CIndicatorSetting *found = FindByIdentity(type, params);
     if(found == NULL)
      {
       ::Print(__FUNCTION__, " > rejected: no row for this identity");
       return false;
      }
     ::Print(__FUNCTION__, " > removing '", found.DisplayLabel(), "'");
     // Snapshot BEFORE deleting - see m_last_removed_type/params declaration comment.
     m_last_removed_type = type;
     ::ArrayResize(m_last_removed_params, ::ArraySize(params));
     for(int p = 0; p < ::ArraySize(params); p++)
        m_last_removed_params[p] = params[p];
     if(!m_list.Delete(IndexOfIdentity(type, params))) return false;   // FreeMode default true - deletes the CIndicatorSetting too

     if(!m_suppress_event)
      {
       ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE, (long)type, 0.0, "");
       if(!ExistsTypeInTemplate(type))   // check AFTER delete - "last row of this type just left"
          ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_DELETE, (long)type, 0.0, "");
      }
     return true;
   }
 //+------------------------------------------------------------------+
 //| Identity of the row most recently removed - see declaration.      |
 //+------------------------------------------------------------------+
 void CIndicatorTemplateManager::GetLastRemoved(ENUM_INDICATOR &type, MqlParam &out_params[]) const
   {
     type = m_last_removed_type;
     int total = ::ArraySize(m_last_removed_params);
     ::ArrayResize(out_params, total);
     for(int i = 0; i < total; i++)
        out_params[i] = m_last_removed_params[i];
   }
 //+------------------------------------------------------------------+
 //| Toggle an existing row's ShowOnChart preference - Data only, fires|
 //| SHOW_CHANGED so EA can attach/detach on chart in reaction.        |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::UpdateRow_IndicatorTemplateSetting_ShowColumn(const int index, const bool show)
   {
     CIndicatorSetting *row = m_list.At(index);
     if(row == NULL) return false;
     row.ShowOnChart(show);
     if(!m_suppress_event)
        ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED, (long)index, 0.0, "");
     return true;
   }
  //+------------------------------------------------------------------+
 //| Lifecycle - same convention as CTimeSeriesEngine::OnInitEvent/    |
 //| CGUIPannel::OnInitEvent. EA.mq5 calls this from its own OnInit(), |
 //| AFTER chart_obj's own CreateCollection() has already run. Loads   |
 //| JSON first (guarded - skips on a CHARTCHANGE reinit, see          |
 //| m_loaded_from_json declaration), THEN scans indicators actually   |
 //| on the chart and merges them in - ONLY considers indicators       |
 //| present in the Catalog (GetIndicatorCatalog); a line not in the   |
 //| Catalog (e.g. SignalMarkers - EA's own overlay, never part of the |
 //| Template) is skipped, never added to m_list. The scan runs on     |
 //| EVERY call (including reinit, unlike the JSON load) - re-truths   |
 //| Show against whatever's actually on THIS chart right now.         |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnInitEvent(CChartObjCollection *chart_obj)
  {
     bool ok = true;
     if(!m_loaded_from_json)   // skip on a CHARTCHANGE reinit - see m_loaded_from_json declaration
      {
       string full_path = g_ea_folder + "/Config_Setting.json";
       ok = LoadIndicatorTemplateSettingFromJSON(full_path);
       m_loaded_from_json = true;
      }

     if(chart_obj == NULL) return ok;
     CChartObj *chart = chart_obj.GetChart(::ChartID());
     if(chart == NULL) return ok;
     // --- Bulk load - suppress AddIndicatorToIndicatorTemplateSetting()'s per-row event storm, nothing is
     // --- listening this early in OnInit anyway (EA's own Set*() pointer wiring hasn't even run yet).
     m_suppress_event = true;
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     for(int win = 0; win < chart.WindowsTotal(); win++)
      {
       CChartWnd *wnd = chart.GetWindowByNum(win);
       if(wnd == NULL) continue;
       for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
         {
          CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
          ENUM_INDICATOR type; MqlParam params[];
          if(wnd_ind == NULL || !wnd_ind.GetIdentity(type, params)) continue;

          bool supported = false;
          for(int c = 0; c < ArraySize(catalog); c++)
             if(catalog[c].ind_type == type) { supported = true; break; }
          if(!supported) continue;   // not in Catalog - skip, never Add

          CIndicatorSetting *existing = FindByIdentity(type, params);
          if(existing != NULL)
             existing.ShowOnChart(true);   // already tracked - re-truth Show to match reality on chart
          else
             AddIndicatorToIndicatorTemplateSetting(type, params);   // new row - ctor already defaults ShowOnChart=true
         }
      }
     m_suppress_event = false;
     //Print Debug
       ::Print("MY DEBUG CIndicatorTemplateManager::OnInitEvent: Total=", m_list.Total());
       for(int dbg_i = 0; dbg_i < m_list.Total(); dbg_i++)
        {
         CIndicatorSetting *dbg_row = m_list.At(dbg_i);
         if(dbg_row != NULL)
            ::Print("MY DEBUG CIndicatorTemplateManager::OnInitEvent: [", dbg_i, "] ", dbg_row.DisplayLabel(), " ShowOnChart=", dbg_row.ShowOnChart());
        }
     return ok;
  }
 //+------------------------------------------------------------------+
 //| Handle events from the Chart Window indicator objects (manual     |
 //| changes) - moved from EA::OnChartEvent (Anhnt, 2026-08-30).       |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam,
                                              CChartObjCollection *chart_obj)
  {
    if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
     {
      int old_handle = (int)lparam;
      int win_num    = (int)dparam;
      int win_index  = (int)StringToInteger(sparam);
      //Print Debug
        ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: fired - old_handle=", old_handle, " win_num=", win_num, " win_index=", win_index);

      ENUM_INDICATOR old_type; MqlParam old_params[];
      if(::IndicatorParameters(old_handle, old_type, old_params) < 0)
       {
        //Print Debug
          ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: bail - IndicatorParameters(old_handle=", old_handle, ") failed, err=", ::GetLastError());
        return false;   //Get Old value
       }
      //Print Debug
        ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: old handle=", old_handle, " old_type=", EnumToString(old_type), " win_num=", win_num, " index=", win_index);

      CWndInd *new_ind = (chart_obj != NULL) ? chart_obj.GetIndicator(::ChartID(), win_num, win_index) : NULL;
      if(new_ind == NULL)
       {
        //Print Debug
          ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: bail - GetIndicator(win_num=", win_num, ", win_index=", win_index, ") returned NULL");
        return false;
       }
      //Print Debug
        ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: new name=", new_ind.Name(), " handle=", new_ind.Handle());

      ENUM_INDICATOR new_type; MqlParam new_params[];
      if(!new_ind.GetIdentity(new_type, new_params))
       {
        //Print Debug
          ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: bail - new_ind.GetIdentity() failed for name=", new_ind.Name());
        return false; //Get New value
       }

      // SignalMarkers.mq5 renames itself (IndicatorSetString(INDICATOR_SHORTNAME,...)) right
      // after EnsureMarkerIndicatorAttached()'s ChartIndicatorAdd() - Layer 3 catches that as a
      // CHANGE on the same handle (same bug class the ADD handler above already guards against,
      // just one event later - see BugNote 2026-08-28, "SignalMarkers rename -> CHANGE -> IND_CUSTOM
      // added to Template -> AddNewIndicatorToAllSeries(IND_CUSTOM) fails on every background
      // symbol"). Identify by NAME, not a blanket type==IND_CUSTOM skip, so a real custom
      // indicator we DO want tracked still passes through below.
      if(new_type == IND_CUSTOM && ::StringFind(new_ind.Name(), SIGNALMARKERS_NAME_TAG) >= 0)
       {
        //Print Debug
          ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: bail - handle=", old_handle, " is our own SignalMarkers, not a Template indicator");
        return false;
       }

      // --- Check TRUOC khi Remove: neu new_type/new_params da trung 1 identity KHAC
      // --- dang co san trong Template (vd user sua tham so indicator A trung het voi
      // --- indicator B da co), thi khong the Add duoc nua (Manager tu chan trung) -
      // --- neu cu Remove old truoc thi ket qua la MAT han A khoi Template ma khong co
      // --- gi thay the. Bail o day, giu nguyen old, khong dung gi ca.
      if(Exists(new_type, new_params))
       {
        //Print Debug
          ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: bail - new params trung 1 identity khac da co trong Template - bo qua, giu nguyen old");
        return false;
       }

      // Both fire their own INDICATOR_TEMPLATE_MANAGER_EVENT_* below - GUIPannel_Lifecycle.mqh
      // already reacts by calling InitializeTable_IndicatorTemplateSetting()/SyncTreeView_IndicatorTemplateSetting(),
      // no need to call them here too (and TYPE_ADDED/TYPE_DELETE correctly stay silent
      // when old_type == new_type, unlike the old unconditional Sync call).
      //Print Debug
        ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent CHANGE: -> Delete old_type=", EnumToString(old_type), " then Add new_type=", EnumToString(new_type));
      DeleteIndicatorFromIndicatorTemplateSetting(old_type, old_params); //Remove Old value
      AddIndicatorToIndicatorTemplateSetting(new_type, new_params); //Add New value
      return true;
     }
    if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_DEL)
     {
      //Print Debug
        ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent DEL: win_num=", (int)dparam);
      // EA itself just called RemoveIndicatorFromChart (Show-toggle/row-delete reacting to
      // OUR OWN Data change) - this native DEL is the expected side effect, not a surprise.
      // Skip the defensive rescan below entirely; see g_suppress_del_rescan declaration.
      if(g_suppress_del_rescan)
       {
        g_suppress_del_rescan = false;
        //Print Debug
          ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent DEL: self-triggered, skipping rescan");
        return true;
       }
      // Native DEL event doesn't say WHICH indicator was removed - live-scan every row against
      // real chart state and push the truth into ourselves. CGUIPannel now listens to
      // INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED itself to refresh its Table icon, no
      // direct call needed here.
      for(int row = 0; row < Total(); row++)
       {
        CIndicatorSetting *entry = At(row);
        if(entry == NULL) continue;
        MqlParam params[];
        entry.GetRawParams(params);
        bool shown = (chart_obj != NULL) ? chart_obj.IsIndicatorShownOnChart(::ChartID(), entry.TypeEnum(), params) : entry.ShowOnChart();
        if(shown != entry.ShowOnChart())
           UpdateRow_IndicatorTemplateSetting_ShowColumn(row, shown);
       }
      return true;
     }
    if(id != CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD) return false;
    int handle = (int)lparam;
    //Print Debug
      ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent ADD: fired - handle=", handle);
    ENUM_INDICATOR type; MqlParam params[];
    if(::IndicatorParameters(handle, type, params) < 0)
     {
      //Print Debug
        ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent ADD: bail - IndicatorParameters(handle=", handle, ") failed, err=", ::GetLastError());
      return false;
     }
    // SignalMarkers.mq5 is EA's own Layer-3 marker-display program (attached by
    // EnsureMarkerIndicatorAttached), NOT a Template indicator - its own ChartIndicatorAdd()
    // triggers this very ADD event via CChartObjCollection::Refresh()'s diff detection, so it
    // must be identified and excluded by NAME here, not by a blanket "type==IND_CUSTOM" skip -
    // a future custom indicator we DO want tracked in the Template would still need to pass
    // through below (Anhnt, 2026-08-28).
    if(type == IND_CUSTOM && ArraySize(params) > 0 && ::StringFind(params[0].string_value, SIGNALMARKERS_NAME_TAG) >= 0)
     {
      //Print Debug
        ::Print("MY DEBUG CIndicatorTemplateManager::OnChartEvent ADD: bail - handle=", handle, " is our own SignalMarkers, not a Template indicator");
      return false;
     }
    CIndicatorSetting *entry = FindByIdentity(type, params);
    if(entry != NULL)  //Add An Indicator exist in Indicator Template due to hide on Chart
     {
      // Go through this Manager's own setter (not a direct entry.ShowOnChart(true) mutation)
      // so it fires INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED - CGUIPannel listens to
      // that itself to refresh its Table icon, no need to call it here too.
      if(!entry.ShowOnChart())
       {
        for(int row = 0; row < Total(); row++)
         {
          CIndicatorSetting *e = At(row);
          if(e == entry)
           {
            UpdateRow_IndicatorTemplateSetting_ShowColumn(row, true);
            break;
           }
         }
       }
      return true;
     }
    // AddIndicatorToIndicatorTemplateSetting() below fires INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED
    // (+TYPE_ADDED if this is the first row of its type) - GUIPannel_Lifecycle.mqh already
    // reacts to those by calling InitializeTable_IndicatorTemplateSetting()/SyncTreeView_IndicatorTemplateSetting(),
    // no need to call them here too.
    AddIndicatorToIndicatorTemplateSetting(type, params);
    return true;
  }
 //+------------------------------------------------------------------+
 //| Debug dump - README Working Rule Print Debug format                |
 //+------------------------------------------------------------------+
 void CIndicatorTemplateManager::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print("CIndicatorTemplateManager::Print total=", m_list.Total());
     for(int i = 0; i < m_list.Total(); i++)
      {
       CIndicatorSetting *row = m_list.At(i);
       if(row != NULL) row.Print(full_prop, true);
      }
   }
#endif // CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#endif // CINDICATORTEMPLATEMANAGER_MQH