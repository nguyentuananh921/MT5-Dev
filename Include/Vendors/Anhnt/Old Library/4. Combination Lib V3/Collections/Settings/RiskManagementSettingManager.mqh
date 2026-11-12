//+------------------------------------------------------------------+
//|                                 RiskManagementSettingManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for the StopLost +  |
//| Trailing setting, the same for every Symbol - same pattern as     |
//| CSymbolTFManager / CIndicatorTemplateManager.                     |
//+------------------------------------------------------------------+
#ifndef CRISKMANAGEMENTSETTINGMANAGER_MQH
#define CRISKMANAGEMENTSETTINGMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Settings\RiskManagementSetting.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\SymbolTFManager.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\JSONConfig.mqh>

#ifndef CRISKMANAGEMENTSETTINGMANAGER_MQH_DECLARATION
#define CRISKMANAGEMENTSETTINGMANAGER_MQH_DECLARATION
 class CRiskManagementSettingManager : public CBaseObj
   {
     private:
       CRiskManagementSetting m_setting;      // the StopLost + Trailing setting, the same for every Symbol
       bool        m_loaded_from_json;
       bool        m_use_risk;             // the risk of a new trade: the EA hands over its inputs in OnInit (SetRisk)
       double      m_risk_percent;
       bool        m_use_rrr;              // the take profit of a new trade is put by the Risk Reward Ratio
       ENUM_RISK_REWARD_RATIO m_rrr;        // the take profit of a new trade is at this multiple of its stop distance
      //--- Global Trailing-by-Value bar shift
       int         m_trail_data_rates_index;
      //Working with JSON
       int         ReadRiskManagementEntry(const string &s, int pos);
       int         ReadRiskManagementEntryArray(const string &s, int pos);
       int         ReadMqlParamArray(const string &s, int pos, MqlParam &out[]);
       void        BuildMqlParamArrayJson(MqlParam &params[], string &out_json) const;

     public:
                     CRiskManagementSettingManager(void) : m_loaded_from_json(false),
                                                          m_use_risk(false), m_risk_percent(5.0), m_use_rrr(true), m_rrr(ONE_TO_TWO),
                                                          m_trail_data_rates_index(2) {}
                    ~CRiskManagementSettingManager(void) {}
      //--- Lifecycle - same convention as CSymbolTFManager::OnInitEvent/CIndicatorTemplateManager::OnInitEvent.
       bool                    OnInitEvent(void);

      //--- The setting itself: the controls read it and edit it, NotifySettingChanged tells the others
       CRiskManagementSetting   *Setting(void)                              { return ::GetPointer(m_setting); }
       void                    NotifySettingChanged(void);
      //--- The risk of a new trade: global, the same for every Symbol; the EA gives its inputs at the start
       void                    SetRisk(const bool use,const double percent) { m_use_risk = use; m_risk_percent = percent; }
       bool                    UseRiskPerNewTrade(void)             const { return m_use_risk; }
       double                  RiskPerNewTrade(void)                const { return (m_risk_percent>0.0 ? m_risk_percent : 0.0); }
      //--- The Risk Reward Ratio of a new trade: global too
       bool                    UseRiskRewardRatio(void)             const { return m_use_rrr; }
       void                    UseRiskRewardRatio(const bool use)         { m_use_rrr = use; }
       ENUM_RISK_REWARD_RATIO  RiskRewardRatio(void)                const { return m_rrr; }
       void                    RiskRewardRatio(const ENUM_RISK_REWARD_RATIO ratio) { m_rrr = ratio; }
      //--- Global Trailing-by-Value bar shift
       int                     TrailingDataRatesIndex(void)         const { return m_trail_data_rates_index; }
       void                    TrailingDataRatesIndex(const int shift)    { m_trail_data_rates_index = shift; }

      //--- JSON - reads/builds the "Trading_Risk_Setting" key. A file of the first layout (one row for each Symbol in "StopLost_Setting"
      //--- and "Trailing_DataRatesIndex") gives its first row. SaveToJSON() writes the new key, the other keys of the file stay as they are.
       bool                    LoadRiskManagementSettingFromJSON(const string full_path);
       void                    BuildJsonSection(string &out_json)   const;
       bool                    SaveToJSON(void);

       virtual void            Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| The setting was edited and saved                                 |
 //+------------------------------------------------------------------+
 void CRiskManagementSettingManager::NotifySettingChanged(void)
   {
     ::EventChartCustom(::ChartID(), (ushort)RISK_MANAGEMENT_MANAGER_EVENT_CHANGED, 0, 0.0, "");
   }
 bool CRiskManagementSettingManager::OnInitEvent(void)
   {
     if(m_loaded_from_json) return true;   // skip on a CHARTCHANGE reinit
     string full_path = this.GetFolderName() + CONFIG_SETTING_FILE;
     bool ok = LoadRiskManagementSettingFromJSON(full_path);
     m_loaded_from_json = true;
     return ok;
   }
 //+------------------------------------------------------------------+
 //| Writes the "Trading_Risk_Setting" key of Config_Setting.json, the |
 //| other keys stay as they are                                       |
 //+------------------------------------------------------------------+
 bool CRiskManagementSettingManager::SaveToJSON(void)
  {
   string value;
   this.BuildJsonSection(value);
   string full_path = this.GetFolderName() + CONFIG_SETTING_FILE;
   return ::JSONConfig_SaveSection(full_path, "Trading_Risk_Setting", value);
  }
 int CRiskManagementSettingManager::ReadMqlParamArray(const string &s, int pos, MqlParam &out[])
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
 int CRiskManagementSettingManager::ReadRiskManagementEntry(const string &s, int pos)
  {
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '{') return pos;
   pos++; // skip '{'
   pos = JSONConfig_SkipSpace(s, pos);
   string ind_tf_text = "", ind_type_text = "", num_text;
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
     if(key == "m_sl_active")
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
     else if(key == "m_trail_data_rates_index")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); m_trail_data_rates_index = (int)StringToInteger(num_text); }
     else if(key == "m_use_risk")
      pos = IndicatorConfig_ReadBool(s, pos, m_use_risk);
     else if(key == "m_risk_percent")
      { pos = JSONConfig_ReadRawNumber(s, pos, num_text); m_risk_percent = StringToDouble(num_text); }
     else if(key == "m_use_rrr")
      pos = IndicatorConfig_ReadBool(s, pos, m_use_rrr);
     else if(key == "m_rrr")
      {
       pos = JSONConfig_ReadRawNumber(s, pos, num_text);
       int ratio = (int)StringToInteger(num_text);
       m_rrr = (ratio >= 0 && ratio < RISK_REWARD_RATIOS_TOTAL) ? (ENUM_RISK_REWARD_RATIO)ratio : ONE_TO_TWO;
      }
     else
      pos = JSONConfig_SkipValue(s, pos);   // unrecognized key
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == '}') pos++;
   m_setting.StopLostActive(sl_active);
   m_setting.StopLostMode((ENUM_STOPLOST_TRAILING_MODE)sl_mode);
   m_setting.StopLostFixedMultiplier(sl_fixed_mult);
   if(ind_type_text == "ATR")
    {
     m_setting.StopLostIndTF(TimestampByDescription(ind_tf_text));
     m_setting.StopLostIndType(IND_ATR);
     MqlParam p[1];
     p[0].type          = TYPE_INT;
     p[0].integer_value = sl_ind_period;
     m_setting.SetStopLostIndParams(p);
     m_setting.StopLostIndMultiplier(sl_ind_mult);
    }
   m_setting.TrailingActive(trail_active);
   m_setting.TrailingMode((ENUM_STOPLOST_TRAILING_MODE)trail_mode);
   m_setting.TrailingOffsetPts(trail_offset);
   m_setting.TrailingStartPts(trail_start);
   m_setting.TrailingStepPts(trail_step);
   if(trail_ind_type != WRONG_VALUE)
    {
     m_setting.TrailingIndTF(TimestampByDescription(trail_ind_tf_text));
     m_setting.TrailingIndType(trail_ind_type);
     m_setting.SetTrailingIndParams(trail_ind_params);
    }
   return pos;
  }
 //+------------------------------------------------------------------+
 //| A file of the first layout: an array with one row for each Symbol;|
 //| the first row is the setting of every Symbol now                  |
 //+------------------------------------------------------------------+
 int CRiskManagementSettingManager::ReadRiskManagementEntryArray(const string &s, int pos)
  {
   pos = JSONConfig_SkipSpace(s, pos);
   if(pos >= StringLen(s) || StringGetCharacter(s, pos) != '[') return pos;
   pos++; // skip '['
   pos = JSONConfig_SkipSpace(s, pos);
   bool first = true;
   while(pos < StringLen(s) && StringGetCharacter(s, pos) != ']')
    {
     if(first)
      {
       pos = ReadRiskManagementEntry(s, pos);
       first = false;
      }
     else
        pos = JSONConfig_SkipValue(s, pos);
     pos = JSONConfig_SkipSpace(s, pos);
    }
   if(pos < StringLen(s) && StringGetCharacter(s, pos) == ']') pos++;
   return pos;
  }
 //+------------------------------------------------------------------+
 //| Load the setting: "Trading_Risk_Setting", else the first row of   |
 //| the first layout ("StopLost_Setting" + "Trailing_DataRatesIndex") |
 //+------------------------------------------------------------------+
 bool CRiskManagementSettingManager::LoadRiskManagementSettingFromJSON(const string full_path)
  {
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "") return false;
   string clean = JSONConfig_StripComments(content);
   int pos = JSONConfig_SkipSpace(clean, 0);
   if(pos >= StringLen(clean) || StringGetCharacter(clean, pos) != '{')
    {
     ::Print(__FUNCTION__, " > top-level JSON must be an object");
     return false;
    }
   pos++; // skip '{'
   pos = JSONConfig_SkipSpace(clean, pos);
   bool found_new = false, found_old = false;
   int  old_pos = -1, old_rates_pos = -1;
   while(pos < StringLen(clean) && StringGetCharacter(clean, pos) != '}')
    {
     string key;
     pos = JSONConfig_ReadString(clean, pos, key);
     pos = JSONConfig_SkipSpace(clean, pos);
     if(pos < StringLen(clean) && StringGetCharacter(clean, pos) == ':') pos++;
     pos = JSONConfig_SkipSpace(clean, pos);
     if(key == "Trading_Risk_Setting")
      { pos = ReadRiskManagementEntry(clean, pos); found_new = true; }
     else if(key == "StopLost_Setting")
      { old_pos = pos; pos = JSONConfig_SkipValue(clean, pos); found_old = true; }
     else if(key == "Trailing_DataRatesIndex")
      { old_rates_pos = pos; pos = JSONConfig_SkipValue(clean, pos); }
     else
      pos = JSONConfig_SkipValue(clean, pos);   // not this Manager's key
     pos = JSONConfig_SkipSpace(clean, pos);
    }
   if(!found_new && found_old)
    {
     ReadRiskManagementEntryArray(clean, old_pos);
     if(old_rates_pos >= 0)
      { string num_text; JSONConfig_ReadRawNumber(clean, old_rates_pos, num_text); m_trail_data_rates_index = (int)StringToInteger(num_text); }
    }
   ::Print(__FUNCTION__, " > ", found_new ? "loaded the setting from " : found_old ? "took the first row of the first layout from " : "no setting in ", full_path);
   return true;
  }
 void CRiskManagementSettingManager::BuildJsonSection(string &out_json) const
  {
   bool has_ind = (m_setting.StopLostIndType() == IND_ATR);
   string ind_tf_text = has_ind ? TimeframeDescription(m_setting.StopLostIndTF()) : "";
   int    ind_period   = 14;
   if(has_ind)
    {
     MqlParam p[];
     m_setting.GetStopLostIndParams(p);
     if(::ArraySize(p) > 0) ind_period = (int)p[0].integer_value;
    }
   MqlParam trail_ind_params[];
   m_setting.GetTrailingIndParams(trail_ind_params);
   bool trail_has_ind = (m_setting.TrailingIndType() != WRONG_VALUE && ::ArraySize(trail_ind_params) > 0);
   string trail_ind_json;
   BuildMqlParamArrayJson(trail_ind_params, trail_ind_json);
   out_json = "{ \"m_sl_active\": " + (m_setting.StopLostActive() ? "true" : "false") +
              ", \"m_sl_mode\": " + (string)(int)m_setting.StopLostMode() +
              ", \"m_sl_fixed_mult\": " + ::DoubleToString(m_setting.StopLostFixedMultiplier(), 4) +
              ", \"m_sl_ind_type\": \"" + (has_ind ? "ATR" : "") + "\"" +
              ", \"m_sl_ind_tf\": \"" + ind_tf_text + "\"" +
              ", \"m_sl_ind_period\": " + (string)ind_period +
              ", \"m_sl_ind_multiplier\": " + ::DoubleToString(m_setting.StopLostIndMultiplier(), 4) +
              ", \"m_trail_active\": " + (m_setting.TrailingActive() ? "true" : "false") +
              ", \"m_trail_mode\": " + (string)(int)m_setting.TrailingMode() +
              ", \"m_trail_offset_pts\": " + (string)m_setting.TrailingOffsetPts() +
              ", \"m_trail_start_pts\": " + (string)m_setting.TrailingStartPts() +
              ", \"m_trail_step_pts\": " + (string)m_setting.TrailingStepPts() +
              ", \"m_trail_ind_tf\": \"" + (trail_has_ind ? TimeframeDescription(m_setting.TrailingIndTF()) : "") + "\"" +
              ", \"m_trail_ind_type\": " + (string)(trail_has_ind ? (int)m_setting.TrailingIndType() : (int)WRONG_VALUE) +
              ", \"m_trail_ind_params\": " + trail_ind_json +
              ", \"m_trail_data_rates_index\": " + (string)m_trail_data_rates_index +
              ", \"m_use_risk\": " + (m_use_risk ? "true" : "false") +
              ", \"m_risk_percent\": " + ::DoubleToString(m_risk_percent, 2) +
              ", \"m_use_rrr\": " + (m_use_rrr ? "true" : "false") +
              ", \"m_rrr\": " + (string)(int)m_rrr + " }";
  }
 void CRiskManagementSettingManager::BuildMqlParamArrayJson(MqlParam &params[], string &out_json) const
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
 void CRiskManagementSettingManager::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print("CRiskManagementSettingManager::Print");
     m_setting.Print(full_prop, true);
   }
#endif // CRISKMANAGEMENTSETTINGMANAGER_MQH_DECLARATION
#endif // CRISKMANAGEMENTSETTINGMANAGER_MQH
