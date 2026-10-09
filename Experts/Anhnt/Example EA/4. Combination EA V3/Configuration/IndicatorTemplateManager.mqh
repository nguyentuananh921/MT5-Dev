//+------------------------------------------------------------------+
//|                                     IndicatorTemplateManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the indicator templates: the list     |
//| and the "Indicator_Templates" key of Config_Setting.json. Python |
//| calculates them, nothing is attached to the chart.               |
//+------------------------------------------------------------------+
#ifndef CINDICATORTEMPLATEMANAGER_MQH
#define CINDICATORTEMPLATEMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\EventDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Chart\ChartObj.mqh>
 #include "IndicatorSetting.mqh"
 #include "JSONConfig.mqh"

#ifndef CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#define CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
 class CIndicatorTemplateManager : public CBaseObj
  {
    private:
     CArrayObj          m_list;               // CIndicatorSetting*, sorted by catalog name then params
     bool               m_loaded_from_json;
     ENUM_INDICATOR     m_last_removed_type;     // identity of the row removed last: the EA detaches it from the chart after the event
     MqlParam           m_last_removed_params[];
     int                ReadTemplateEntry(const string &s, int pos, CIndicatorSetting *&out_row);
     int                ReadTemplateEntryArray(const string &s, int pos);
     int                IndexOfIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
     int                CompareRawParams(MqlParam &a[], MqlParam &b[]) const;
     int                FindInsertIndex(const ENUM_INDICATOR type, MqlParam &params[]) const;
    public:
                        CIndicatorTemplateManager(void) : m_loaded_from_json(false), m_last_removed_type(IND_CUSTOM) {}
                       ~CIndicatorTemplateManager(void) {}
   //--- Loads the "Indicator_Templates" key of Config_Setting.json once, then takes the indicators found on the chart
     bool               OnInitEvent(CChartObj *chart=NULL);
   //--- The chart side: an indicator added, changed or removed by hand; the identity comes from the chart object, no handle
     bool               OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart);
   //--- Toggle ShowOnChart of a row; fires INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED so the EA attaches / detaches it
     bool               UpdateRow_IndicatorTemplateSetting_ShowColumn(const int index, const bool show);
     void               GetLastRemoved(ENUM_INDICATOR &type, MqlParam &out_params[]) const;
     int                Total(void)                 const { return m_list.Total();   }
     CIndicatorSetting *At(const int index)         const { return m_list.At(index); }
     CIndicatorSetting *FindByIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
     bool               Exists(const ENUM_INDICATOR type, MqlParam &params[])        const { return FindByIdentity(type, params) != NULL; }
     bool               Exists(const ENUM_INDICATOR type) const;
   //--- The master switch: every indicator shows (or hides) its Buy and Sell markers; AllBuySell: every flag is on
     void               SetAllBuySell(const bool on);
     bool               AllBuySell(void) const;
   //--- false if the identity already exists / does not exist; fire INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED / _DELETE
     bool               AddIndicatorToIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[]);
     bool               DeleteIndicatorFromIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[]);
     bool               LoadIndicatorTemplateSettingFromJSON(const string full_path);
   //--- Value of the "Indicator_Templates" key; the caller places it in the file
     void               BuildJsonSection(string &out_json) const;
   //--- Writes the "Indicator_Templates" key of Config_Setting.json, the other keys stay as they are
     bool               Save(void);
     virtual void       Print(const bool full_prop=false, const bool dash=false);
  };
#endif // CINDICATORTEMPLATEMANAGER_MQH_DECLARATION

#ifndef CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#define CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
 int IndicatorConfig_ReadParamsArray(const string &s, int pos, string &out[])
  {
   ::ArrayResize(out, 0);
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= ::StringLen(s) || ::StringGetCharacter(s, pos) != '[')
      return pos;
   pos++;
   pos = JSONConfig_SkipSpace(s, pos);
   while(pos < ::StringLen(s) && ::StringGetCharacter(s, pos) != ']')
    {
     string value;
     if(::StringGetCharacter(s, pos) == '"')
        pos = JSONConfig_ReadString(s, pos, value);
     else
        pos = JSONConfig_ReadRawNumber(s, pos, value);
     int sz = ::ArraySize(out);
     ::ArrayResize(out, sz + 1);
     out[sz] = value;
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < ::StringLen(s) && ::StringGetCharacter(s, pos) == ']')
      pos++;
   return pos;
  }
 int CIndicatorTemplateManager::ReadTemplateEntry(const string &s, int pos, CIndicatorSetting *&out_row)
  {
   out_row = NULL;
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= ::StringLen(s) || ::StringGetCharacter(s, pos) != '{')
      return pos;
   pos++;
   pos = JSONConfig_SkipSpace(s, pos);
   string type_text = "";
   string params_text[];
   bool   buy = false, sell = false, sound = false, message = false;
   while(pos < ::StringLen(s) && ::StringGetCharacter(s, pos) != '}')
    {
     string key;
     pos = JSONConfig_ReadString(s, pos, key);
     pos = JSONConfig_SkipSpace(s, pos);
     if(pos < ::StringLen(s) && ::StringGetCharacter(s, pos) == ':')
        pos++;
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
        pos = JSONConfig_SkipValue(s, pos);
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < ::StringLen(s) && ::StringGetCharacter(s, pos) == '}')
      pos++;
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   ENUM_INDICATOR type_enum = IND_CUSTOM;
   bool type_found = false;
   for(int c = 0; c < ::ArraySize(catalog) && !type_found; c++)
      if(catalog[c].name == type_text)
        {
         type_enum = catalog[c].ind_type;
         type_found = true;
        }
   if(!type_found)
    {
     ::Print(__FUNCTION__, " > unknown indicator type \"", type_text, "\", skipped");
     return pos;
    }
   SIndicatorParam schema[];
   int schema_total = GetIndicatorParamSchema(type_enum, schema);
   if(::ArraySize(params_text) < schema_total)   // a type without parameters (AO, AC, BW MFI, Fractals) has none to read
    {
     ::Print(__FUNCTION__, " > \"", type_text, "\" param count/schema mismatch, skipped");
     return pos;
    }
   MqlParam raw_params[];
   ::ArrayResize(raw_params, schema_total);
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
          raw_params[p].integer_value = (long)::StringToInteger(raw);
      }
     else if(schema[p].data_type == TYPE_DOUBLE)
        raw_params[p].double_value = ::StringToDouble(raw);
     else
        raw_params[p].integer_value = ::StringToInteger(raw);
    }
   out_row = new CIndicatorSetting();
   out_row.TypeEnum(type_enum);
   out_row.SetRawParams(raw_params);
   out_row.BuySignal(buy);
   out_row.SellSignal(sell);
   out_row.SoundAlert(sound);
   out_row.MessageAlert(message);
   out_row.ShowOnChart(false);   // true only after the scan of the chart finds it there
   return pos;
  }
 int CIndicatorTemplateManager::ReadTemplateEntryArray(const string &s, int pos)
  {
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= ::StringLen(s) || ::StringGetCharacter(s, pos) != '[')
      return pos;
   pos++;
   pos = JSONConfig_SkipSpace(s, pos);
   while(pos < ::StringLen(s) && ::StringGetCharacter(s, pos) != ']')
    {
     CIndicatorSetting *row = NULL;
     pos = ReadTemplateEntry(s, pos, row);
     if(row != NULL)
      {
       //--- Inserted sorted: the order survives a hand-edited file
       MqlParam row_params[];
       row.GetRawParams(row_params);
       int insert_at = FindInsertIndex(row.TypeEnum(), row_params);
       bool inserted = (insert_at >= m_list.Total()) ? m_list.Add(row) : m_list.Insert(row, insert_at);
       if(!inserted)
          delete row;
      }
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < ::StringLen(s) && ::StringGetCharacter(s, pos) == ']')
      pos++;
   return pos;
  }
 bool CIndicatorTemplateManager::LoadIndicatorTemplateSettingFromJSON(const string full_path)
  {
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "")
      return false;
   string clean = JSONConfig_StripComments(content);
   string section = JSONConfig_ExtractRawSection(clean, "Indicator_Templates");
   m_list.Clear();
   if(section == "")
      return false;
   ReadTemplateEntryArray(section, 0);
   ::Print("Complete ", __FUNCTION__, " > loaded ", m_list.Total(), " indicator template(s) from ", full_path);
   return true;
  }
 void CIndicatorTemplateManager::BuildJsonSection(string &out_json) const
  {
   out_json = "[\n";
   int saved = 0;
   for(int i = 0; i < m_list.Total(); i++)
    {
     CIndicatorSetting *row = m_list.At(i);
     if(row == NULL || row.TypeEnum() == IND_CUSTOM)
        continue;
     string type_key = GetIndicatorNameForType(row.TypeEnum());
     if(type_key == "")
        continue;
     if(saved > 0)
        out_json += ",\n";
     saved++;
     out_json += "  { \"m_indicator_type\": \"" + type_key + "\", \"m_buy_signal\": " + (row.BuySignal() ? "true" : "false") +
                 ", \"m_sell_signal\": " + (row.SellSignal() ? "true" : "false") +
                 ", \"m_sound_alert\": " + (row.SoundAlert() ? "true" : "false") +
                 ", \"m_message_alert\": " + (row.MessageAlert() ? "true" : "false") + ", \"m_indicator_params\": [";
     string params_text[];
     row.JSONParamsText(params_text);
     for(int p = 0; p < ::ArraySize(params_text); p++)
      {
       if(p > 0)
          out_json += ", ";
       string raw = params_text[p];
       //--- A number stays bare, anything else (Applied Price, Method...) is quoted
       bool is_number = (::StringLen(raw) > 0);
       for(int c = 0; c < ::StringLen(raw) && is_number; c++)
        {
         ushort ch = ::StringGetCharacter(raw, c);
         is_number = ((ch >= '0' && ch <= '9') || ch == '-' || ch == '+' || ch == '.' || ch == 'e' || ch == 'E');
        }
       out_json += is_number ? raw : ("\"" + raw + "\"");
      }
     out_json += "] }";
    }
   out_json += "\n ]";
  }
 bool CIndicatorTemplateManager::Save(void)
  {
   string value;
   this.BuildJsonSection(value);
   string full_path = this.GetFolderName() + "/Config_Setting.json";
   return ::JSONConfig_SaveSection(full_path, "Indicator_Templates", value);
  }
 CIndicatorSetting *CIndicatorTemplateManager::FindByIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const
  {
   int i = IndexOfIdentity(type, params);
   return (i >= 0) ? m_list.At(i) : NULL;
  }
 int CIndicatorTemplateManager::IndexOfIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const
  {
   for(int i = 0; i < m_list.Total(); i++)
    {
     CIndicatorSetting *row = m_list.At(i);
     if(row == NULL || row.TypeEnum() != type)
        continue;
     MqlParam raw[];
     row.GetRawParams(raw);
     if(IsEqualMqlParamArrays(raw, params))
        return i;
    }
   return -1;
  }
 bool CIndicatorTemplateManager::Exists(const ENUM_INDICATOR type) const
  {
   for(int i = 0; i < m_list.Total(); i++)
     {
      CIndicatorSetting *row = m_list.At(i);
      if(row != NULL && row.TypeEnum() == type)
         return true;
     }
   return false;
  }
 //--- -1 if A sorts before B, +1 after, 0 equal; numbers compare by value ("10" after "9")
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
 //--- Keeps m_list sorted by catalog name (what the table shows), then by params within one type
 int CIndicatorTemplateManager::FindInsertIndex(const ENUM_INDICATOR type, MqlParam &params[]) const
  {
   string name = GetIndicatorNameForType(type);
   for(int i = 0; i < m_list.Total(); i++)
    {
     CIndicatorSetting *existing = m_list.At(i);
     if(existing == NULL)
        continue;
     if(existing.TypeEnum() != type)
      {
       int cmp = ::StringCompare(name, GetIndicatorNameForType(existing.TypeEnum()), false);
       if(cmp < 0) return i;
       if(cmp > 0) continue;
       if((int)type < (int)existing.TypeEnum()) return i;
       continue;
      }
     MqlParam existing_params[];
     existing.GetRawParams(existing_params);
     if(CompareRawParams(params, existing_params) < 0)
        return i;
    }
   return m_list.Total();
  }
 bool CIndicatorTemplateManager::AddIndicatorToIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
  {
   if(Exists(type, params))
      return false;
   CIndicatorSetting *row = new CIndicatorSetting();
   row.TypeEnum(type);
   row.SetRawParams(params);
   int insert_at = FindInsertIndex(type, params);
   bool inserted = (insert_at >= m_list.Total()) ? m_list.Add(row) : m_list.Insert(row, insert_at);
   if(!inserted)
    {
     delete row;
     return false;
    }
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED, (long)type, 0.0, "");
   return true;
  }
 bool CIndicatorTemplateManager::DeleteIndicatorFromIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
  {
   int index = IndexOfIdentity(type, params);
   if(index < 0)
    {
     ::Print(__FUNCTION__, " > rejected: no row for this identity");
     return false;
    }
   m_last_removed_type = type;
   ::ArrayResize(m_last_removed_params, ::ArraySize(params));
   for(int p = 0; p < ::ArraySize(params); p++)
      m_last_removed_params[p] = params[p];
   if(!m_list.Delete(index))
      return false;
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE, (long)type, 0.0, "");
   return true;
  }
 void CIndicatorTemplateManager::SetAllBuySell(const bool on)
  {
   bool changed = false;
   for(int i = 0; i < m_list.Total(); i++)
     {
      CIndicatorSetting *row = m_list.At(i);
      if(row == NULL)
         continue;
      changed |= (row.BuySignal() != on || row.SellSignal() != on);
      row.BuySignal(on, false);
      row.SellSignal(on, false);
     }
   if(changed)
      ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED, (long)WRONG_VALUE, 0.0, "");
  }
 bool CIndicatorTemplateManager::AllBuySell(void) const
  {
   for(int i = 0; i < m_list.Total(); i++)
     {
      CIndicatorSetting *row = m_list.At(i);
      if(row != NULL && !(row.BuySignal() && row.SellSignal()))
         return false;
     }
   return true;
  }
 bool CIndicatorTemplateManager::OnInitEvent(CChartObj *chart=NULL)
  {
   bool ok = true;
   if(!m_loaded_from_json)   // a chart-change re-init keeps what the user already changed
    {
     m_loaded_from_json = true;
     ok = LoadIndicatorTemplateSettingFromJSON(this.GetFolderName() + "/Config_Setting.json");
    }
   if(chart == NULL)
      return ok;
   CArrayObj *on_chart = chart.GetList();
   for(int i = on_chart.Total() - 1; i >= 0; i--)
    {
     CWndInd *ind = on_chart.At(i);
     ENUM_INDICATOR type;
     MqlParam params[];
     if(ind == NULL || !ind.GetIdentity(type, params))
        continue;
     if(GetIndicatorNameForType(type) == "")
        continue;   // not in the catalog: never a row
     CIndicatorSetting *existing = FindByIdentity(type, params);
     if(existing != NULL)
        existing.ShowOnChart(true);   // already tracked: Show follows what the chart really holds
     else
        AddIndicatorToIndicatorTemplateSetting(type, params);   // new row, Show on by default
    }
   return ok;
  }
 bool CIndicatorTemplateManager::UpdateRow_IndicatorTemplateSetting_ShowColumn(const int index, const bool show)
  {
   CIndicatorSetting *row = m_list.At(index);
   if(row == NULL)
      return false;
   row.ShowOnChart(show);
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED, (long)index, 0.0, "");
   return true;
  }
 void CIndicatorTemplateManager::GetLastRemoved(ENUM_INDICATOR &type, MqlParam &out_params[]) const
  {
   type = m_last_removed_type;
   int total = ::ArraySize(m_last_removed_params);
   ::ArrayResize(out_params, total);
   for(int i = 0; i < total; i++)
      out_params[i] = m_last_removed_params[i];
  }
 //--- lparam = index in the chart window, dparam = chart window, sparam = indicator short name (CChartObj::SendEvent)
 bool CIndicatorTemplateManager::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart)
  {
   if(chart == NULL)
      return false;
   if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
    {
     //--- the chart object kept the old type and parameters; the indicator in that place now is the new one
     CWndInd *old_ind = chart.GetLastChangedIndicator();
     CWndInd *new_ind = chart.GetIndicator((int)dparam, (int)lparam);
     ENUM_INDICATOR old_type, new_type;
     MqlParam old_params[], new_params[];
     if(old_ind == NULL || new_ind == NULL || !old_ind.GetIdentity(old_type, old_params) || !new_ind.GetIdentity(new_type, new_params))
        return false;
     if(Exists(new_type, new_params))
        return false;
     DeleteIndicatorFromIndicatorTemplateSetting(old_type, old_params);
     if(GetIndicatorNameForType(new_type) != "")
        AddIndicatorToIndicatorTemplateSetting(new_type, new_params);
     return true;
    }
   if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_DEL)
    {
     //--- an indicator left the chart: every row takes Show from what the chart holds now (a row removed by the user is gone already)
     for(int row = 0; row < Total(); row++)
      {
       CIndicatorSetting *entry = At(row);
       if(entry == NULL)
          continue;
       MqlParam params[];
       entry.GetRawParams(params);
       bool shown = chart.IsIndicatorShownOnChart(entry.TypeEnum(), params);
       if(shown != entry.ShowOnChart())
          UpdateRow_IndicatorTemplateSetting_ShowColumn(row, shown);
      }
     return true;
    }
   if(id != CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD)
      return false;
   CWndInd *ind = chart.GetIndicator((int)dparam, (int)lparam);
   if(ind == NULL || ind.Name() != sparam)
      ind = chart.GetLastAddedIndicator();   // several events queued: the indexes moved
   ENUM_INDICATOR type;
   MqlParam params[];
   if(ind == NULL || !ind.GetIdentity(type, params) || GetIndicatorNameForType(type) == "")
      return false;
   CIndicatorSetting *entry = FindByIdentity(type, params);
   if(entry == NULL)
    {
     AddIndicatorToIndicatorTemplateSetting(type, params);
     return true;
    }
   //--- a row that was hidden from the chart: the user put the indicator back by hand
   if(!entry.ShowOnChart())
    {
     for(int row = 0; row < Total(); row++)
        if(At(row) == entry)
         {
          UpdateRow_IndicatorTemplateSetting_ShowColumn(row, true);
          break;
         }
    }
   return true;
  }
 void CIndicatorTemplateManager::Print(const bool full_prop=false, const bool dash=false)
  {
   ::Print("CIndicatorTemplateManager::Print total=", m_list.Total());
   for(int i = 0; i < m_list.Total(); i++)
     {
      CIndicatorSetting *row = m_list.At(i);
      if(row != NULL)
         row.Print(full_prop, true);
     }
  }
#endif // CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#endif // CINDICATORTEMPLATEMANAGER_MQH
