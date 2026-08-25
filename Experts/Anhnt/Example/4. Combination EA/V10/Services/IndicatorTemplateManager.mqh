//+------------------------------------------------------------------+
//|                                     IndicatorTemplateManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for indicator       |
//| templates. EA owns THIS class directly (Implementaion Plan\       |
//| ImplementaionClassForSetting.md muc 2b) - CGUIPannel only holds   |
//| a pointer, same pattern as CTimeSeriesEngine/CTradingEngine.      |
//+------------------------------------------------------------------+
#ifndef __INDICATORTEMPLATEMANAGER_MQH__
#define __INDICATORTEMPLATEMANAGER_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
 #include "IndicatorSetting.mqh"
 // Shared low-level JSON tokenizer (SkipSpace/ReadString/ReadRawNumber/ReadBool/SkipValue) +
 // whole-file read/raw-section utilities - stays here, used by Marker/PatternAlert loaders too
 // (muc 4b, ImplementaionClassForSetting.md). This file owns ONLY the "Indicator_Templates"
 // domain-specific entry parsing - no SJsonIndicatorEntry struct middleman.
 #include "..\Anatoli Kazharski\JSONConfig.mqh"
 #include <Vendors\Anhnt\Library\4. Combination Lib\Defines\EventDefines.mqh>
 extern string g_ea_folder;  // From EA - same pattern TimeSeriesEngine.mqh already uses
 #ifndef CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
 #define CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
 //+------------------------------------------------------------------------------------+
 //| Events CIndicatorTemplateManager fires whenever Data genuinely changes - anchored   |
 //| right after Trishkin's whole DoEasy event chain (WF_CONTROL_EVENTS_NEXT_CODE), no   |
 //| Library file touched. Added/Delete = row-level (Layer 1 listens, later). Type Added/|
 //| Type Delete = fired ALONGSIDE Added/Delete only when this is the first/last row of  |
 //| that ENUM_INDICATOR type (TreeView listens - Table listens to Added/Delete too).    |
 //+------------------------------------------------------------------------------------+
 enum ENUM_TEMPLATE_MANAGER_EVENT
  {
   TEMPLATE_MANAGER_EVENT_NO_EVENT = WF_CONTROL_EVENTS_NEXT_CODE,
   TEMPLATE_MANAGER_EVENT_ADDED,        // a row (type,params) was genuinely added
   TEMPLATE_MANAGER_EVENT_DELETE,       // a row (type,params) was genuinely removed
   TEMPLATE_MANAGER_EVENT_TYPE_ADDED,   // first row of this type just appeared
   TEMPLATE_MANAGER_EVENT_TYPE_DELETE,  // last row of this type just disappeared
   TEMPLATE_MANAGER_EVENT_SHOW_CHANGED, // an existing row's ShowOnChart preference was toggled
  };
 //+------------------------------------------------------------------------------------+
 //| CIndicatorTemplateManager - Center Point of Data (Single Source of Truth).         |
 //| Owns the CArrayObj list + "Indicator_Templates" JSON section.                      |
 //+------------------------------------------------------------------------------------+
 class CIndicatorTemplateManager : public CBaseObj
   {
     private:
       CArrayObj   m_list;   //List of CIndicatorSetting* in Template
       bool        m_suppress_event;   // true while ScanIndicatorOnChartOnInit() bulk-loads - avoids an event storm
       // --- Snapshot of the identity just removed - captured BEFORE m_list.Delete() so a
       // --- DELETE listener can still recover (type,params) even though the row itself is
       // --- gone by the time the (async) event is actually dispatched. Same "Last X" snapshot
       // --- convention CChartWnd::GetLastAddedIndicator()/GetLastDeletedIndicator() already use.
       ENUM_INDICATOR m_last_removed_type;
       MqlParam       m_last_removed_params[];
       int         ReadTemplateEntry(const string &s, int pos, CIndicatorSetting *&out_row);
       int         ReadTemplateEntryArray(const string &s, int pos);
       int         IndexOfIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
       bool        ExistsTypeInTemplate(const ENUM_INDICATOR type) const;   // true if ANY row of this type is present, regardless of params

     public:
                     CIndicatorTemplateManager(void) : m_suppress_event(false), m_last_removed_type(IND_CUSTOM) {}
                    ~CIndicatorTemplateManager(void) {}

      //--- Lifecycle - same convention as CTimeSeriesEngine::OnInitEvent/CGUIPannel::OnInitEvent.       
       bool                OnInitEvent(void);

       int                 Total(void)                                          const { return m_list.Total();   }
       CIndicatorSetting  *At(const int index)                                  const { return m_list.At(index); }

      //--- identity-based lookup - works in POINTERS, not array index 
       CIndicatorSetting  *FindByIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
       bool                Exists(const ENUM_INDICATOR type, MqlParam &params[])        const { return FindByIdentity(type, params) != NULL; }

      //--Add,Remove in Template base on indicator identity
       CIndicatorSetting  *Add(const ENUM_INDICATOR type, MqlParam &params[]);   // NULL if identity already exists
       bool                RemoveByIdentityFromTemplate(const ENUM_INDICATOR type, MqlParam &params[]);

      //--- Data only - mutates an EXISTING row's ShowOnChart preference and fires
      //--- TEMPLATE_MANAGER_EVENT_SHOW_CHANGED so EA (owns ChartObjCollection) can
      //--- react by attaching/detaching the indicator on chart.
       bool                SetShowOnChart(const int index, const bool show);

      //--- Identity of the row most recently removed by RemoveByIdentityFromTemplate()
      //--- (see m_last_removed_type/params) - a DELETE listener reads this instead of
      //--- looking the row up in m_list, since it's already gone by then.
       void                GetLastRemoved(ENUM_INDICATOR &type, MqlParam &out_params[]) const;

       //--- JSON - reads/builds ONLY the "Indicator_Templates" section, does NOT FileOpen/write -
       bool                         LoadFromJSON(const string full_path);       
       void                         BuildJsonSection(string &out_json)                    const;
       void                         ScanIndicatorOnChartOnInit(CChartObjCollection *chart_obj);
       virtual void                 Print(const bool full_prop=false, const bool dash=false);
   };
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
 //| Append a new row - Data only, NULL if the identity already exists |
 //+------------------------------------------------------------------+
 CIndicatorSetting *CIndicatorTemplateManager::Add(const ENUM_INDICATOR type, MqlParam &params[])
   {
     if(Exists(type, params)) return NULL;
     bool is_new_type = !ExistsTypeInTemplate(type);   // check BEFORE insert - "first row of this type"

     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     string type_key, params_key;
     BuildTemplateMatchKey(type, params, catalog, type_key, params_key);
     string params_text[];
     BuildIndicatorParamsText(type, params, params_text);

     CIndicatorSetting *row = new CIndicatorSetting();   // constructor defaults buy/sell/sound/message = true
     row.TypeText(type_key);
     row.SetParamsText(params_text);
     row.TypeEnum(type);
     row.SetRawParams(params);
     if(!m_list.Add(row))
      {
       delete row;
       return NULL;
      }
     if(!m_suppress_event)
      {
       // lparam = index of the row just inserted (m_list.Total()-1) - lets a
       // receiver do At(index) to get the exact (type, raw_params) that was Added,
       // no separate id/lookup mechanism needed.
       ::EventChartCustom(::ChartID(), (ushort)TEMPLATE_MANAGER_EVENT_ADDED, (long)(m_list.Total() - 1), 0.0, "");
       if(is_new_type)
          ::EventChartCustom(::ChartID(), (ushort)TEMPLATE_MANAGER_EVENT_TYPE_ADDED, (long)type, 0.0, "");
      }
     return row;
   }
 //+------------------------------------------------------------------+
 //| Remove a row by identity - Data only                              |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::RemoveByIdentityFromTemplate(const ENUM_INDICATOR type, MqlParam &params[])
   {
     CIndicatorSetting *found = FindByIdentity(type, params);
     if(found == NULL)
      {
       ::Print(__FUNCTION__, " > rejected: no row for this identity");
       return false;
      }
     ::Print(__FUNCTION__, " > removing '", found.TypeText(), "'");
     // Snapshot BEFORE deleting - see m_last_removed_type/params declaration comment.
     m_last_removed_type = type;
     ::ArrayResize(m_last_removed_params, ::ArraySize(params));
     for(int p = 0; p < ::ArraySize(params); p++)
        m_last_removed_params[p] = params[p];
     if(!m_list.Delete(IndexOfIdentity(type, params))) return false;   // FreeMode default true - deletes the CIndicatorSetting too

     if(!m_suppress_event)
      {
       ::EventChartCustom(::ChartID(), (ushort)TEMPLATE_MANAGER_EVENT_DELETE, (long)type, 0.0, "");
       if(!ExistsTypeInTemplate(type))   // check AFTER delete - "last row of this type just left"
          ::EventChartCustom(::ChartID(), (ushort)TEMPLATE_MANAGER_EVENT_TYPE_DELETE, (long)type, 0.0, "");
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
 bool CIndicatorTemplateManager::SetShowOnChart(const int index, const bool show)
   {
     CIndicatorSetting *row = m_list.At(index);
     if(row == NULL) return false;
     row.ShowOnChart(show);
     if(!m_suppress_event)
        ::EventChartCustom(::ChartID(), (ushort)TEMPLATE_MANAGER_EVENT_SHOW_CHANGED, (long)index, 0.0, "");
     return true;
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
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{') return pos;
     pos++; // skip '{'
     pos = IndicatorConfig_SkipSpace(s, pos);

     string type_text = "";
     string params_text[];
     // --- show defaults to false when the key is missing (old JSON, no "show" ever saved) -
     // --- so loading an old config file never silently pushes indicators onto the user's
     // --- real chart; false is the safe/conservative default for a brand-new preference field.
     bool   buy = false, sell = false, sound = false, message = false, show = false;
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != '}')
      {
       string key;
       pos = IndicatorConfig_ReadString(s, pos, key);
       pos = IndicatorConfig_SkipSpace(s, pos);
       if(pos < StringLen(s) && StringGetCharacter(s, pos) == ':') pos++;
       pos = IndicatorConfig_SkipSpace(s, pos);
       if(key == "type")
          pos = IndicatorConfig_ReadString(s, pos, type_text);
       else if(key == "params")
          pos = IndicatorConfig_ReadParamsArray(s, pos, params_text);
       else if(key == "buy")
          pos = IndicatorConfig_ReadBool(s, pos, buy);
       else if(key == "sell")
          pos = IndicatorConfig_ReadBool(s, pos, sell);
       else if(key == "sound")
          pos = IndicatorConfig_ReadBool(s, pos, sound);
       else if(key == "message")
          pos = IndicatorConfig_ReadBool(s, pos, message);
       else if(key == "show")
          pos = IndicatorConfig_ReadBool(s, pos, show);
       pos = IndicatorConfig_SkipSpace(s, pos);
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
     out_row = new CIndicatorSetting();
     out_row.TypeText(type_text);
     out_row.SetParamsText(params_text);
     out_row.TypeEnum(type_enum);
     out_row.SetRawParams(raw_params);
     out_row.BuySignal(buy);
     out_row.SellSignal(sell);
     out_row.SoundAlert(sound);
     out_row.MessageAlert(message);
     out_row.ShowOnChart(show);
     return pos;
   }
 //+------------------------------------------------------------------+
 //| Parse the "Indicator_Templates" array, appending 1 row per entry  |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::ReadTemplateEntryArray(const string &s, int pos)
   {
     pos = IndicatorConfig_SkipSpace(s, pos);
     if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[') return pos;
     pos++; // skip '['
     pos = IndicatorConfig_SkipSpace(s, pos);
     while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
      {
       CIndicatorSetting *row = NULL;
       pos = ReadTemplateEntry(s, pos, row);
       if(row != NULL && !m_list.Add(row)) delete row;
       pos = IndicatorConfig_SkipSpace(s, pos);
      }
     if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
     return pos;
   }
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as CTimeSeriesEngine::OnInitEvent/    |
 //| CGUIPannel::OnInitEvent. EA.mq5 calls this from its own OnInit()  |
 //| instead of building the path/calling LoadFromJSON() itself.       |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnInitEvent(void)
   {
     string full_path = g_ea_folder + "/Config_Setting.json";
     return LoadFromJSON(full_path);
   } 
 //+------------------------------------------------------------------+
 //| Load Config_Setting.json's "Indicator_Templates" section straight |
 //| into m_list - clears whatever was there first. Mirrors the        |
 //| top-level object loop IndicatorConfig_ParseText used to run,      |
 //| scoped to ONLY this Manager's own key (muc 4b).                   |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::LoadFromJSON(const string full_path)
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
       if(key == "Indicator_Templates")
          pos = ReadTemplateEntryArray(clean, pos);
       else
          pos = IndicatorConfig_SkipValue(clean, pos);   // not this Manager's key - e.g. "Symbols_TFs_List"
       pos = IndicatorConfig_SkipSpace(clean, pos);
      }
     ::Print(__FUNCTION__, " > loaded ", m_list.Total(), " indicator template(s) from ", full_path);
     return true;
   }
 //+------------------------------------------------------------------+
 //| Scan indicators on chart and update CIndicatorSetting objects -  |
 //| ONLY considers indicators present in the Catalog (GetIndicator-  |
 //| Catalog). A line not in the Catalog (e.g. SignalMarkers - EA's   |
 //| own overlay, never part of the Template) is skipped, never added |
 //| to m_list.                                                        |
 //+------------------------------------------------------------------+
 void CIndicatorTemplateManager::ScanIndicatorOnChartOnInit(CChartObjCollection *chart_obj)
  {
   if(chart_obj == NULL) return;
   CChartObj *chart = chart_obj.GetChart(::ChartID());
   if(chart == NULL) return;
   // --- Bulk load - suppress Add()'s per-row event storm, nothing is listening this early
   // --- in OnInit anyway (EA's own Set*() pointer wiring hasn't even run yet).
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
           Add(type, params);            // new row - ctor already defaults ShowOnChart=true
       }
    }
   m_suppress_event = false;
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
     for(int i = 0; i < m_list.Total(); i++)
      {
       CIndicatorSetting *row = m_list.At(i);
       if(row == NULL || row.TypeText() == "") continue;
       if(saved > 0) out_json += ",\n";
       saved++;
       out_json += "  { \"type\": \"" + row.TypeText() + "\", \"buy\": " + (row.BuySignal() ? "true" : "false") +
                   ", \"sell\": " + (row.SellSignal() ? "true" : "false") +
                   ", \"sound\": " + (row.SoundAlert() ? "true" : "false") +
                   ", \"message\": " + (row.MessageAlert() ? "true" : "false") +
                   ", \"show\": " + (row.ShowOnChart() ? "true" : "false") + ", \"params\": [";
       string params_text[];
       row.GetParamsText(params_text);
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
 #endif // CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#endif // __INDICATORTEMPLATEMANAGER_MQH__
