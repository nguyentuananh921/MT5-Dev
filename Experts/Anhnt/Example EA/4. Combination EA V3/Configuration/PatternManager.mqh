//+------------------------------------------------------------------+
//|                                                 PatternManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the candle pattern settings: the list |
//| and the "Pattern_Alerts_Setting" key of Config_Setting.json      |
//| (V2 CBarPatternsControl without the calculation)                 |
//+------------------------------------------------------------------+
#ifndef CPATTERNMANAGER_MQH
#define CPATTERNMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\EventDefines.mqh>
 #include "PatternSetting.mqh"
 #include "JSONConfig.mqh"

#ifndef CPATTERNMANAGER_MQH_DECLARATION
#define CPATTERNMANAGER_MQH_DECLARATION
 class CPatternManager : public CBaseObj
  {
    private:
     CArrayObj          m_list;                // CPatternSetting*, in the order of the Python catalog once it arrived
     bool               m_loaded_from_json;
     int                IndexOf(const string name) const;
     CPatternSetting   *Add(const string name);
    public:
                        CPatternManager(void) : m_loaded_from_json(false) {}
                       ~CPatternManager(void) {}
   //--- Loads the "Pattern_Alerts_Setting" key of Config_Setting.json once: the names and flags it holds
     bool               OnInitEvent(void);
     int                Total(void)                    const { return m_list.Total();   }
     CPatternSetting   *At(const int index)            const { return m_list.At(index); }
     CPatternSetting   *Find(const string name)        const;
   //--- Buy / Sell flag of a pattern by name, false when it is unknown
     bool               PatternSignalBuy(const string name)  const;
     bool               PatternSignalSell(const string name) const;
   //--- Python catalog "name:candles:sides;name:candles:sides;...": sets the candle counts and the sides, adds the patterns the file did not have
   //--- and puts the list in the catalog order. Returns true when anything changed
     bool               SetCatalog(const string catalog);
   //--- The master switch: every pattern shows (or hides) its Buy and Sell markers
     void               SetAllBuySell(const bool on);
     bool               AllBuySell(void) const;
     bool               LoadFromJSON(const string full_path);
   //--- Value of the "Pattern_Alerts_Setting" key; the caller places it in the file
     void               BuildJsonSection(string &out_json) const;
   //--- Writes the "Pattern_Alerts_Setting" key of Config_Setting.json, the other keys stay as they are
     bool               Save(void);
     virtual void       Print(const bool full_prop=false,const bool dash=false);
  };
#endif // CPATTERNMANAGER_MQH_DECLARATION

#ifndef CPATTERNMANAGER_MQH_IMPLEMENTATION
#define CPATTERNMANAGER_MQH_IMPLEMENTATION
 int CPatternManager::IndexOf(const string name) const
  {
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row != NULL && row.Name() == name)
         return i;
     }
   return WRONG_VALUE;
  }
 CPatternSetting *CPatternManager::Find(const string name) const
  {
   int i = IndexOf(name);
   return (i >= 0) ? m_list.At(i) : NULL;
  }
 CPatternSetting *CPatternManager::Add(const string name)
  {
   CPatternSetting *row = new CPatternSetting(name);
   if(!m_list.Add(row))
     {
      delete row;
      return NULL;
     }
   return row;
  }
 bool CPatternManager::PatternSignalBuy(const string name) const
  {
   CPatternSetting *row = Find(name);
   return (row != NULL && row.BuySignal());
  }
 bool CPatternManager::PatternSignalSell(const string name) const
  {
   CPatternSetting *row = Find(name);
   return (row != NULL && row.SellSignal());
  }
 bool CPatternManager::SetCatalog(const string catalog)
  {
   string items[];
   int n = ::StringSplit(catalog, ';', items);
   bool changed = false;
   CArrayObj ordered;
   ordered.FreeMode(false);
   for(int i = 0; i < n; i++)
     {
      string parts[];
      int fields = ::StringSplit(items[i], ':', parts);
      if(fields < 2)
         continue;
      CPatternSetting *row = Find(parts[0]);
      if(row == NULL)
        {
         row = Add(parts[0]);
         changed = true;
        }
      if(row == NULL)
         continue;
      uint candles = (uint)::StringToInteger(parts[1]);
      if(row.Candles() != candles)
        {
         row.Candles(candles);
         changed = true;
        }
      if(fields == 3)
        {
         bool had_buy = row.HasBuy(), had_sell = row.HasSell();
         row.Sides(parts[2]);
         changed |= (had_buy != row.HasBuy() || had_sell != row.HasSell());
        }
      ordered.Add(row);
     }
   //--- A pattern of the file that Python does not know stays at the end
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      bool listed = false;
      for(int k = 0; k < ordered.Total() && !listed; k++)
         listed = (ordered.At(k) == row);
      if(row != NULL && !listed)
         ordered.Add(row);
     }
   bool same_order = (ordered.Total() == m_list.Total());
   for(int i = 0; i < ordered.Total() && same_order; i++)
      same_order = (ordered.At(i) == m_list.At(i));
   if(!same_order)
     {
      m_list.FreeMode(false);
      m_list.Clear();
      for(int i = 0; i < ordered.Total(); i++)
         m_list.Add(ordered.At(i));
      m_list.FreeMode(true);
      changed = true;
     }
   return changed;
  }
 void CPatternManager::SetAllBuySell(const bool on)
  {
   bool changed = false;
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row == NULL)
         continue;
      //--- A side the pattern never has stays as it is
      bool buy_changed = (row.HasBuy() && row.BuySignal() != on);
      bool sell_changed = (row.HasSell() && row.SellSignal() != on);
      changed |= (buy_changed || sell_changed);
      if(row.HasBuy())
         row.BuySignal(on, false);
      if(row.HasSell())
         row.SellSignal(on, false);
     }
   if(changed)
      ::EventChartCustom(::ChartID(), (ushort)PATTERN_MANAGER_EVENT_BUYSELL_CHANGED, 0, 0.0, "");
  }
 bool CPatternManager::AllBuySell(void) const
  {
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row != NULL && ((row.HasBuy() && !row.BuySignal()) || (row.HasSell() && !row.SellSignal())))
         return false;
     }
   return true;
  }
 bool CPatternManager::LoadFromJSON(const string full_path)
  {
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "")
      return false;
   string clean = JSONConfig_StripComments(content);
   string section = JSONConfig_ExtractRawSection(clean, "Pattern_Alerts_Setting");
   if(section == "")
      return false;
   m_list.Clear();
   int pos = JSONConfig_SkipSpace(section, 0);
   if(pos >= ::StringLen(section) || ::StringGetCharacter(section, pos) != '{')
      return false;
   pos = JSONConfig_SkipSpace(section, pos + 1);
   while(pos < ::StringLen(section) && ::StringGetCharacter(section, pos) != '}')
     {
      string name;
      pos = JSONConfig_ReadString(section, pos, name);
      pos = JSONConfig_SkipSpace(section, pos);
      if(pos < ::StringLen(section) && ::StringGetCharacter(section, pos) == ':')
         pos++;
      pos = JSONConfig_SkipSpace(section, pos);
      int end = JSONConfig_SkipValue(section, pos);
      string obj = ::StringSubstr(section, pos, end - pos);
      pos = JSONConfig_SkipSpace(section, end);
      if(name == "" || Find(name) != NULL)
         continue;
      CPatternSetting *row = Add(name);
      if(row == NULL)
         continue;
      bool v = row.BuySignal();
      if(JSONConfig_BoolValue(obj, "m_pattern_signal_buy", v))    row.BuySignal(v, false);
      v = row.SellSignal();
      if(JSONConfig_BoolValue(obj, "m_pattern_signal_sell", v))   row.SellSignal(v, false);
      v = row.SoundAlert();
      if(JSONConfig_BoolValue(obj, "m_pattern_alert_sound", v))   row.SoundAlert(v);
      v = row.MessageAlert();
      if(JSONConfig_BoolValue(obj, "m_pattern_alert_message", v)) row.MessageAlert(v);
     }
   ::Print("Complete ", __FUNCTION__, " > loaded ", m_list.Total(), " candle pattern(s) from ", full_path);
   return true;
  }
 void CPatternManager::BuildJsonSection(string &out_json) const
  {
   out_json = "{\n";
   int written = 0;
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row == NULL)
         continue;
      if(written > 0)
         out_json += ",\n";
      written++;
      out_json += "  \"" + row.Name() + "\": { \"m_pattern_signal_buy\": " + (row.BuySignal() ? "true" : "false") +
                  ", \"m_pattern_signal_sell\": " + (row.SellSignal() ? "true" : "false") +
                  ", \"m_pattern_alert_sound\": " + (row.SoundAlert() ? "true" : "false") +
                  ", \"m_pattern_alert_message\": " + (row.MessageAlert() ? "true" : "false") + " }";
     }
   out_json += "\n }";
  }
 bool CPatternManager::Save(void)
  {
   string value;
   this.BuildJsonSection(value);
   string full_path = this.GetFolderName() + "/Config_Setting.json";
   return ::JSONConfig_SaveSection(full_path, "Pattern_Alerts_Setting", value);
  }
 bool CPatternManager::OnInitEvent(void)
  {
   if(m_loaded_from_json)
      return true;   // a chart-change re-init keeps what the user already changed
   m_loaded_from_json = true;
   return LoadFromJSON(this.GetFolderName() + "/Config_Setting.json");
  }
 void CPatternManager::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("CPatternManager::Print total=", m_list.Total());
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row != NULL)
         row.Print(full_prop, true);
     }
  }
#endif // CPATTERNMANAGER_MQH_IMPLEMENTATION
#endif // CPATTERNMANAGER_MQH
