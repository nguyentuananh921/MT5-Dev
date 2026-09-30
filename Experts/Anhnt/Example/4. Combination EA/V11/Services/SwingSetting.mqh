//+------------------------------------------------------------------+
//|                                                 SwingSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| EA-wide Swing config - ONE value set shared by every Symbol+TF:  |
//|  - Strength N + Wick/Body (CBarSwingControl keeps a per-series   |
//|    copy; the owner pushes these into it)                          |
//|  - Show / Sound / Message toggles per Swing type (High, Low)      |
//| Owned by CTimeSeriesEngine (plain member, like m_BarPatterns_    |
//| Control); CGUIPannel only borrows a pointer. Owns its own JSON   |
//| section, same as CSymbolTFManager / CIndicatorTemplateManager.   |
//+------------------------------------------------------------------+
#ifndef __SWINGSETTING_MQH__
#define __SWINGSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib\Defines\SwingDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Services\DELib\CommonDELib.mqh>
 #include "JSONConfig.mqh"
 #include "TradingSetupSettingManager.mqh"   // event-code chain only
 extern string g_ea_folder;  // From EA - same pattern SymbolTFManager.mqh uses

 // Chains off TRADING_SETUP_MANAGER's LAST value - same rule as every other Service enum.
 enum ENUM_SWING_SETTING_EVENT
  {
   SWING_SETTING_EVENT_NO_EVENT = TRADING_SETUP_MANAGER_EVENT_CHANGED + 1,
   SWING_SETTING_EVENT_CHANGED,   // Show toggle or Strength/PriceBasis changed - bridge must be rebuilt
  };

 class CSwingSetting
  {
    private:
     int                     m_strength;         // N - bars required each side of a pivot
     ENUM_SWING_PRICE_BASIS  m_price_basis;      // Wick (High/Low) or Body (Open/Close)
     bool                    m_signal_show[2];   // index 0=High, 1=Low - gate for writing to SignalBridge
     bool                    m_sound_alert[2];
     bool                    m_message_alert[2];
     int                     Index(const ENUM_SWING_TYPE type) const { return (type == SWING_TYPE_HIGH) ? 0 : (type == SWING_TYPE_LOW) ? 1 : -1; }
    public:
                             CSwingSetting(void);
     //--- Detection params
     int                     Strength(void)   const { return m_strength; }
     void                    Strength(const int n)  { m_strength = (n < 1) ? 1 : n; }
     ENUM_SWING_PRICE_BASIS  PriceBasis(void) const { return m_price_basis; }
     void                    PriceBasis(const ENUM_SWING_PRICE_BASIS basis) { m_price_basis = basis; }
     //--- Per-type toggles
     bool                    SignalShow(const ENUM_SWING_TYPE type)   const { int i = Index(type); return (i >= 0) ? m_signal_show[i]   : false; }
     bool                    SoundAlert(const ENUM_SWING_TYPE type)   const { int i = Index(type); return (i >= 0) ? m_sound_alert[i]   : false; }
     bool                    MessageAlert(const ENUM_SWING_TYPE type) const { int i = Index(type); return (i >= 0) ? m_message_alert[i] : false; }
     void                    SignalShow(const ENUM_SWING_TYPE type, const bool v);
     void                    SoundAlert(const ENUM_SWING_TYPE type, const bool v)   { int i = Index(type); if(i >= 0) m_sound_alert[i]   = v; }
     void                    MessageAlert(const ENUM_SWING_TYPE type, const bool v) { int i = Index(type); if(i >= 0) m_message_alert[i] = v; }
     //--- Fired by the owner after a Strength/PriceBasis change has been applied to every series
     void                    NotifyChanged(void) { ::EventChartCustom(::ChartID(), (ushort)SWING_SETTING_EVENT_CHANGED, 0, 0.0, ""); }
     //--- JSON - "Swing_Alerts_Setting" section of Config_Setting.json. Writing the file itself is
     //--- CGUIPannel::SaveAllSettingsToJSON's job (every Save button rewrites the whole file from live values).
     bool                    LoadFromJSON(void);
     void                    BuildJsonSection(string &out_json) const;
  };
 //+------------------------------------------------------------------+
 CSwingSetting::CSwingSetting(void) : m_strength(5), m_price_basis(SWING_PRICE_BASIS_WICK)
  {
   for(int i = 0; i < 2; i++)
    {
     m_signal_show[i]   = true;
     m_sound_alert[i]   = false;
     m_message_alert[i] = false;
    }
  }
 //+------------------------------------------------------------------+
 //| Show gate setter - dirty-checks and fires SWING_SETTING_EVENT_    |
 //| CHANGED so CSignalBridgeWriter rebuilds (mirrors CBarPatternControl|
 //| ::BuySignal firing BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED).     |
 //+------------------------------------------------------------------+
 void CSwingSetting::SignalShow(const ENUM_SWING_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_signal_show[i] == v) return;
   m_signal_show[i] = v;
   NotifyChanged();
  }
 //+------------------------------------------------------------------+
 //| Read own section - missing file/section/keys leave the defaults. |
 //+------------------------------------------------------------------+
 bool CSwingSetting::LoadFromJSON(void)
  {
   string full_path = g_ea_folder + "/Config_Setting.json";
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "") return false;
   string section = JSONConfig_ExtractRawSection(content, "Swing_Alerts_Setting");
   if(section == "") return false;
   int n = m_strength;
   if(JSONConfig_IntValue(section, "m_swing_strength", n)) Strength(n);
   bool use_wick = (m_price_basis == SWING_PRICE_BASIS_WICK);
   if(JSONConfig_BoolValue(section, "m_swing_use_wick", use_wick))
      m_price_basis = use_wick ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY;
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   for(int i = 0; i < 2; i++)
    {
     string obj = JSONConfig_ExtractRawSection(section, SwingTypeDescription(types[i]));
     if(obj == "") continue;
     JSONConfig_BoolValue(obj, "m_swing_signal_show",   m_signal_show[i]);
     JSONConfig_BoolValue(obj, "m_swing_alert_sound",   m_sound_alert[i]);
     JSONConfig_BoolValue(obj, "m_swing_alert_message", m_message_alert[i]);
    }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Own section text only (the value of the "Swing_Alerts_Setting"   |
 //| key) - the caller decides where it goes in the file.             |
 //+------------------------------------------------------------------+
 void CSwingSetting::BuildJsonSection(string &out_json) const
  {
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   out_json  = "{\n";
   out_json += "  \"m_swing_strength\": " + (string)m_strength + ",\n";
   out_json += "  \"m_swing_use_wick\": " + (m_price_basis == SWING_PRICE_BASIS_WICK ? "true" : "false") + ",\n";
   for(int i = 0; i < 2; i++)
    {
     if(i > 0) out_json += ",\n";
     out_json += "  \"" + SwingTypeDescription(types[i]) + "\": { \"m_swing_signal_show\": " + (m_signal_show[i] ? "true" : "false") +
                 ", \"m_swing_alert_sound\": "   + (m_sound_alert[i]   ? "true" : "false") +
                 ", \"m_swing_alert_message\": " + (m_message_alert[i] ? "true" : "false") + " }";
    }
   out_json += "\n }";
  }
#endif // __SWINGSETTING_MQH__
