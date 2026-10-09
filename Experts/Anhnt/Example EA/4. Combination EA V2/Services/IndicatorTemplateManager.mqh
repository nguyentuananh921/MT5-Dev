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
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\ChartObjCollection.mqh>
 #include "IndicatorSetting.mqh" 
 #include "JSONConfig.mqh"
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Defines\EventDefines.mqh>
 extern bool g_suppress_del_rescan; 
 
 enum ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT
  {
   INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT = BARPATTERN_CONTROL_EVENTS_NEXT_CODE,
   INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED,            // a row (type,params) was genuinely added
   INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE,           // a row (type,params) was genuinely removed
   INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_ADDED,       // first row of this type just appeared
   INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_DELETE,      // last row of this type just disappeared   
   INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED,     // ShowOnChart flipped - lparam=index
   INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED,  // Buy or Sell signal flipped - lparam=index
  };
#ifndef CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#define CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
 class CIndicatorTemplateManager : public CBaseObj
  {
   private:
    CArrayObj          m_list;               //List of CIndicatorSetting* in Template
    ENUM_INDICATOR     m_last_removed_type;
    MqlParam           m_last_removed_params[];
    bool               m_loaded_from_json;
    int                ReadTemplateEntry(const string &s, int pos, CIndicatorSetting *&out_row);
    int                ReadTemplateEntryArray(const string &s, int pos);
    int                IndexOfIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
    bool               ExistsTypeInTemplate(const ENUM_INDICATOR type) const;   // true if ANY row of this type is present, regardless of params
    int                CompareRawParams(MqlParam &a[], MqlParam &b[]) const;
    int                FindInsertIndex(const ENUM_INDICATOR type, MqlParam &params[]) const;

   public:
                       CIndicatorTemplateManager(void) : m_last_removed_type(IND_CUSTOM), m_loaded_from_json(false) {}
                       ~CIndicatorTemplateManager(void) {}     
     bool              OnInitEvent(CChartObjCollection *chart_obj);      
     bool              OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam,
                                        CChartObjCollection *chart_obj);

     int                 Total(void)                                          const { return m_list.Total();   }
     CIndicatorSetting  *At(const int index)                                  const { return m_list.At(index); }
     //--- identity-based lookup - works in POINTERS, not array index 
     CIndicatorSetting  *FindByIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
     bool                Exists(const ENUM_INDICATOR type, MqlParam &params[])        const { return FindByIdentity(type, params) != NULL; }

    //--Add,Remove in Template base on indicator identity
     bool                AddIndicatorToIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[], const bool silent=false);   // false if identity already exists - RAW identity only, callers never need the row pointer (ADDED event's lparam+At(index) covers that)
     bool                DeleteIndicatorFromIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[]);
     bool                UpdateRow_IndicatorTemplateSetting_ShowColumn(const int index, const bool show);
     void                GetLastRemoved(ENUM_INDICATOR &type, MqlParam &out_params[]) const;
    //Working with JSON - own section only; the file is written by CGUIPannel::SaveAllSettingsToJSON
     bool                LoadIndicatorTemplateSettingFromJSON(const string full_path);
     void                BuildJsonSection(string &out_json) const;
     virtual void        Print(const bool full_prop=false, const bool dash=false);
  };
#endif // CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#ifndef CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#define CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
 //For working with JSON 
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
        pos = JSONConfig_ReadRawNumber(s, pos, value);
      int sz = ArraySize(out);
      ArrayResize(out, sz + 1);
      out[sz] = value;
      pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']')
      pos++; // skip ']'
   return pos;
  } 
 int CIndicatorTemplateManager::ReadTemplateEntry(const string &s, int pos, CIndicatorSetting *&out_row)
  {
   out_row = NULL;
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{') return pos;
   pos++; // skip '{'
   pos = JSONConfig_SkipSpace(s, pos);
   string type_text = "";
   string params_text[];   
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
   out_row.TypeEnum(type_enum);
   out_row.SetRawParams(raw_params);
   out_row.BuySignal(buy);
   out_row.SellSignal(sell);
   out_row.SoundAlert(sound);
   out_row.MessageAlert(message);   
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
     if(row != NULL)
      {
       // Insert sorted here too (not just AddIndicatorToIndicatorTemplateSetting) - self-heals
       // m_list's type/params-sorted invariant even if Config_Setting.json was ever hand-edited
       // out of order.
       MqlParam row_params[];
       row.GetRawParams(row_params);
       int insert_at = FindInsertIndex(row.TypeEnum(), row_params);
       bool inserted = (insert_at >= m_list.Total()) ? m_list.Add(row) : m_list.Insert(row, insert_at);
       if(!inserted) delete row;
      }
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
   return pos;
  } 
 void CIndicatorTemplateManager::BuildJsonSection(string &out_json) const
  {
   out_json = "[\n";
   int saved = 0;
   for(int i = 0; i < m_list.Total(); i++)
    {
     CIndicatorSetting *row = m_list.At(i);
     if(row == NULL || row.TypeEnum() == IND_CUSTOM) continue;
     string type_key = GetIndicatorNameForType(row.TypeEnum());
     if(type_key == "") continue;
     if(saved > 0) out_json += ",\n";
     saved++;
     // "show" is chart-live truth, never persisted.
     out_json += "  { \"m_indicator_type\": \"" + type_key + "\", \"m_buy_signal\": " + (row.BuySignal() ? "true" : "false") +
                 ", \"m_sell_signal\": " + (row.SellSignal() ? "true" : "false") +
                 ", \"m_sound_alert\": " + (row.SoundAlert() ? "true" : "false") +
                 ", \"m_message_alert\": " + (row.MessageAlert() ? "true" : "false") + ", \"m_indicator_params\": [";
     string params_text[];
     row.JSONParamsText(params_text);
     for(int p = 0; p < ArraySize(params_text); p++)
      {
       if(p > 0) out_json += ", ";
       string raw = params_text[p];
       // --- Re-quote unless every char is one JSONConfig_ReadRawNumber() would have
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
 //For modify
 //+------------------------------------------------------------------+
 //| Identity-based lookup - returns the row itself, not an index      |
 //+------------------------------------------------------------------+ 
 CIndicatorSetting *CIndicatorTemplateManager::FindByIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CIndicatorSetting *row = m_list.At(i);
       if(row == NULL || row.TypeEnum() != type) continue;
       MqlParam raw[];
       row.GetRawParams(raw);
       if(IsEqualMqlParamArrays(raw, params)) return row;
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
       if(row == NULL || row.TypeEnum() != type) continue;
       MqlParam raw[];
       row.GetRawParams(raw);
       if(IsEqualMqlParamArrays(raw, params)) return i;
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
 //| -1 if params A sorts before B, +1 if after, 0 if equal - element- |
 //| by-element, comparing numeric fields BY VALUE (not text), so e.g. |
 //| a Period of 10 correctly sorts after 9, not before it the way a   |
 //| naive string compare would ("10" < "9" lexicographically).        |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::CompareRawParams(MqlParam &a[], MqlParam &b[]) const
  {
    int na = ::ArraySize(a), nb = ::ArraySize(b);
    int n = (na < nb) ? na : nb;
    for(int i = 0; i < n; i++)
     {
      if(a[i].type == TYPE_DOUBLE || b[i].type == TYPE_DOUBLE)
       {
        double da = (a[i].type == TYPE_DOUBLE) ? a[i].double_value : (double)a[i].integer_value;
        double db = (b[i].type == TYPE_DOUBLE) ? b[i].double_value : (double)b[i].integer_value;
        if(da < db) return -1;
        if(da > db) return 1;
       }
      else if(a[i].type == TYPE_STRING || b[i].type == TYPE_STRING)
       {
        if(a[i].string_value < b[i].string_value) return -1;
        if(a[i].string_value > b[i].string_value) return 1;
       }
      else
       {
        if(a[i].integer_value < b[i].integer_value) return -1;
        if(a[i].integer_value > b[i].integer_value) return 1;
       }
     }
    if(na < nb) return -1;
    if(na > nb) return 1;
    return 0;
  }
 //+------------------------------------------------------------------+
 //| Insert position that keeps m_list sorted by catalog display name  |
 //| (what the table shows - ENUM_INDICATOR's numeric order is not     |
 //| alphabetical), then by m_raw_params within the same type. Sorting |
 //| m_list here means no consumer needs its own re-sort, same         |
 //| principle as CSymbolTFManager::FindInsertIndex.                   |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::FindInsertIndex(const ENUM_INDICATOR type, MqlParam &params[]) const
  {
    string name = GetIndicatorNameForType(type);
    for(int i = 0; i < m_list.Total(); i++)
     {
      CIndicatorSetting *existing = m_list.At(i);
      if(existing == NULL) continue;
      if(existing.TypeEnum() != type)
       {
        int cmp = StringCompare(name, GetIndicatorNameForType(existing.TypeEnum()), false);
        if(cmp < 0) return i;
        if(cmp > 0) continue;
        // same display name, different enum (should not happen) - fall back to enum code
        if((int)type < (int)existing.TypeEnum()) return i;
        continue;
       }
      MqlParam existing_params[];
      existing.GetRawParams(existing_params);
      if(CompareRawParams(params, existing_params) < 0) return i;
     }
    return m_list.Total();
  }
 bool CIndicatorTemplateManager::AddIndicatorToIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[], const bool silent=false)
   {
     if(Exists(type, params)) return false;
     bool is_new_type = !ExistsTypeInTemplate(type);   // check BEFORE insert - "first row of this type"
     CIndicatorSetting *row = new CIndicatorSetting();   // constructor defaults buy/sell/sound/message = true
     row.TypeEnum(type);
     row.SetRawParams(params);
     int insert_at = FindInsertIndex(type, params);
     bool inserted = (insert_at >= m_list.Total()) ? m_list.Add(row) : m_list.Insert(row, insert_at);
     if(!inserted)
      {
       delete row;
       return false;
      }
     if(!silent)
      {
       ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED, (long)type, 0.0, "");
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

     ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE, (long)type, 0.0, "");
     if(!ExistsTypeInTemplate(type))   // check AFTER delete - "last row of this type just left"
        ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_DELETE, (long)type, 0.0, "");
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
     ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED, (long)index, 0.0, "");
     return true;
   } 
 bool CIndicatorTemplateManager::OnInitEvent(CChartObjCollection *chart_obj)
  {
     bool ok = true;
     if(!m_loaded_from_json)   // skip on a CHARTCHANGE reinit - see m_loaded_from_json declaration
      {
       string full_path = this.GetFolderName() + "/Config_Setting.json";
       ok = LoadIndicatorTemplateSettingFromJSON(full_path);
       m_loaded_from_json = true;
       // --- Bootstrap ATR(14), hidden: StopLost's SL_MODE_INDICATOR needs a live ATR(14) instance
       // and the GUI's ATR-choice list is empty without one. Silent (no ADDED event) - the
       // Engine's own init creates the instances for every series right after this.
       MqlParam atr14_params[1];
       atr14_params[0].type          = TYPE_INT;
       atr14_params[0].integer_value = 14;
       if(!Exists(IND_ATR, atr14_params))
        {
         AddIndicatorToIndicatorTemplateSetting(IND_ATR, atr14_params, true);
         CIndicatorSetting *atr14_entry = FindByIdentity(IND_ATR, atr14_params);
         if(atr14_entry != NULL) atr14_entry.ShowOnChart(false);
        }
      }

     if(chart_obj == NULL) return ok;
     CChartObj *chart = chart_obj.GetChart(::ChartID());
     if(chart == NULL) return ok;     
     for(int win = 0; win < chart.WindowsTotal(); win++)
      {
       CChartWnd *wnd = chart.GetWindowByNum(win);
       if(wnd == NULL) continue;
       for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
         {
          CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
          ENUM_INDICATOR type; MqlParam params[];
          if(wnd_ind == NULL || !wnd_ind.GetIdentity(type, params)) continue;

          if(GetIndicatorNameForType(type) == "") continue;   // not in Catalog - skip, never Add

          CIndicatorSetting *existing = FindByIdentity(type, params);
          if(existing != NULL)
             existing.ShowOnChart(true);   // already tracked - re-truth Show to match reality on chart
          else
             AddIndicatorToIndicatorTemplateSetting(type, params, true);   // new row - ctor already defaults ShowOnChart=true
         }
      }
     return ok;
  }
 //+------------------------------------------------------------------+
 //| Handle events from the Chart Window indicator objects (manual     |
 //| changes).                                                         |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam,
                                              CChartObjCollection *chart_obj)
  {
    if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
     {
      int old_handle = (int)lparam;
      int win_num    = (int)dparam;
      int win_index  = (int)StringToInteger(sparam);

      ENUM_INDICATOR old_type; MqlParam old_params[];
      if(::IndicatorParameters(old_handle, old_type, old_params) < 0)
       {
        return false;   //Get Old value
       }

      CWndInd *new_ind = (chart_obj != NULL) ? chart_obj.GetIndicator(::ChartID(), win_num, win_index) : NULL;
      if(new_ind == NULL)
       {
        return false;
       }

      ENUM_INDICATOR new_type; MqlParam new_params[];
      if(!new_ind.GetIdentity(new_type, new_params))
       {
        return false; //Get New value
       }

      if(Exists(new_type, new_params))
       {
        return false;
       }      
      DeleteIndicatorFromIndicatorTemplateSetting(old_type, old_params); //Remove Old value
      AddIndicatorToIndicatorTemplateSetting(new_type, new_params); //Add New value
      return true;
     }
    if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_DEL)
     {      
      if(g_suppress_del_rescan)
       {
        g_suppress_del_rescan = false;
        return true;
       }      
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
    ENUM_INDICATOR type; MqlParam params[];
    if(::IndicatorParameters(handle, type, params) < 0)
     {
      return false;
     }
    CIndicatorSetting *entry = FindByIdentity(type, params);
    if(entry != NULL)  //Add An Indicator exist in Indicator Template due to hide on Chart
     {      
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