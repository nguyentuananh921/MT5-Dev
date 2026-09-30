//+------------------------------------------------------------------+
//|                                             SwingSettingJSON.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __SWINGSETTINGJSON_MQH__
#define __SWINGSETTINGJSON_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\SwingSetting.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\DELib\CommonDELib.mqh>
 #include "JSONConfig.mqh"
 #include "TradingSetupSettingManager.mqh"

 enum ENUM_SWING_SETTING_EVENT
  {
   SWING_SETTING_EVENT_NO_EVENT = TRADING_SETUP_MANAGER_EVENT_CHANGED + 1,
   SWING_SETTING_EVENT_CHANGED,   // Show toggle or Strength/PriceBasis changed - bridge must be rebuilt
  };

 //+------------------------------------------------------------------+
 //| Read "Swing_Alerts_Setting" - missing file/section/keys keep defaults |
 //+------------------------------------------------------------------+
 bool SwingSetting_LoadFromJSON(CSwingSetting &setting, const string folder)
  {
   string full_path = folder + "/Config_Setting.json";
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "") return false;
   string section = JSONConfig_ExtractRawSection(content, "Swing_Alerts_Setting");
   if(section == "") return false;
   int n = setting.Strength();
   if(JSONConfig_IntValue(section, "m_swing_strength", n))
      setting.Strength(n);
   bool use_wick = (setting.PriceBasis() == SWING_PRICE_BASIS_WICK);
   if(JSONConfig_BoolValue(section, "m_swing_use_wick", use_wick))
      setting.PriceBasis(use_wick ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY);
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   for(int i = 0; i < 2; i++)
    {
     string obj = JSONConfig_ExtractRawSection(section, SwingTypeDescription(types[i]));
     if(obj == "") continue;
     bool v = setting.SignalShow(types[i]);
     if(JSONConfig_BoolValue(obj, "m_swing_signal_show", v))   setting.SignalShow(types[i], v);
     v = setting.SoundAlert(types[i]);
     if(JSONConfig_BoolValue(obj, "m_swing_alert_sound", v))   setting.SoundAlert(types[i], v);
     v = setting.MessageAlert(types[i]);
     if(JSONConfig_BoolValue(obj, "m_swing_alert_message", v)) setting.MessageAlert(types[i], v);
    }
   return true;
  }
 //--- Value of the "Swing_Alerts_Setting" key - the caller places it in the file
 void SwingSetting_BuildJsonSection(const CSwingSetting &setting, string &out_json)
  {
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   out_json  = "{\n";
   out_json += "  \"m_swing_strength\": " + (string)setting.Strength() + ",\n";
   out_json += "  \"m_swing_use_wick\": " + (setting.PriceBasis() == SWING_PRICE_BASIS_WICK ? "true" : "false") + ",\n";
   for(int i = 0; i < 2; i++)
    {
     if(i > 0) out_json += ",\n";
     out_json += "  \"" + SwingTypeDescription(types[i]) + "\": { \"m_swing_signal_show\": " + (setting.SignalShow(types[i]) ? "true" : "false") +
                 ", \"m_swing_alert_sound\": "   + (setting.SoundAlert(types[i])   ? "true" : "false") +
                 ", \"m_swing_alert_message\": " + (setting.MessageAlert(types[i]) ? "true" : "false") + " }";
    }
   out_json += "\n }";
  }
#endif // __SWINGSETTINGJSON_MQH__
