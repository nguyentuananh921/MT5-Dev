//+------------------------------------------------------------------+
//|                                             SmartMoneySetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __SMARTMONEYSETTING_MQH__
#define __SMARTMONEYSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\SwingDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\MarketStructureDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\CommonDELib.mqh>
 #include "JSONConfig.mqh"

#ifndef CSMARTMONEYSETTING_MQH_DECLARATION
#define CSMARTMONEYSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Smart Money setting: Swing Strength + price basis, and Show /    |
 //| Sound / Message per element: Swing High, Swing Low, BOS, CHoCH   |
 //+------------------------------------------------------------------+
 class CSmartMoneySetting : public CBaseObj
  {
    private:
     int                     m_strength;
     ENUM_SWING_PRICE_BASIS  m_price_basis;
     bool                    m_signal_show[4];   // 0=Swing High, 1=Swing Low, 2=BOS, 3=CHoCH
     bool                    m_sound_alert[4];
     bool                    m_message_alert[4];
     int                     Index(const ENUM_SWING_TYPE type) const { return (type == SWING_TYPE_HIGH) ? 0 : (type == SWING_TYPE_LOW) ? 1 : -1; }
     int                     Index(const ENUM_MARKET_STRUCTURE_TYPE type) const { return (type == MARKET_STRUCTURE_BOS) ? 2 : (type == MARKET_STRUCTURE_CHOCH) ? 3 : -1; }
    public:
                             CSmartMoneySetting(void);
   //--- Defaults first, then the "Swing_Alerts_Setting" key of Config_Setting.json: a missing file/section/key keeps the default
     bool                    OnInitEvent(void);
   //--- Value of the "Swing_Alerts_Setting" key; the caller places it in the file
     void                    BuildJsonSection(string &out_json) const;
   //--- Writes the "Swing_Alerts_Setting" key of Config_Setting.json, the other keys stay as they are
     bool                    Save(void);
     int                     Strength(void)   const { return m_strength;    }
     ENUM_SWING_PRICE_BASIS  PriceBasis(void) const { return m_price_basis; }
     bool                    Strength(const int n);
     bool                    PriceBasis(const ENUM_SWING_PRICE_BASIS basis);
   //--- Every Show flag (Swing High, Swing Low, BOS, CHoCH) is on
     bool                    AllShown(void) const;
     bool                    SignalShow(const ENUM_SWING_TYPE type)   const;
     bool                    SoundAlert(const ENUM_SWING_TYPE type)   const;
     bool                    MessageAlert(const ENUM_SWING_TYPE type) const;
     bool                    SignalShow(const ENUM_SWING_TYPE type, const bool v);
     bool                    SoundAlert(const ENUM_SWING_TYPE type, const bool v);
     bool                    MessageAlert(const ENUM_SWING_TYPE type, const bool v);
     bool                    SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type)   const;
     bool                    SoundAlert(const ENUM_MARKET_STRUCTURE_TYPE type)   const;
     bool                    MessageAlert(const ENUM_MARKET_STRUCTURE_TYPE type) const;
     bool                    SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type, const bool v);
     bool                    SoundAlert(const ENUM_MARKET_STRUCTURE_TYPE type, const bool v);
     bool                    MessageAlert(const ENUM_MARKET_STRUCTURE_TYPE type, const bool v);
  };
#endif // CSMARTMONEYSETTING_MQH_DECLARATION

#ifndef CSMARTMONEYSETTING_MQH_IMPLEMENTATION
#define CSMARTMONEYSETTING_MQH_IMPLEMENTATION
 CSmartMoneySetting::CSmartMoneySetting(void) : m_strength(5), m_price_basis(SWING_PRICE_BASIS_WICK)
  {
   for(int i = 0; i < 4; i++)
    {
     m_signal_show[i]   = true;
     m_sound_alert[i]   = false;
     m_message_alert[i] = false;
    }
  }
 bool CSmartMoneySetting::OnInitEvent(void)
  {
   string full_path = this.GetFolderName() + "/Config_Setting.json";
   string content = ::JSONConfig_ReadWholeFile(full_path);
   if(content == "")
      return false;
   string section = ::JSONConfig_ExtractRawSection(content, "Swing_Alerts_Setting");
   if(section == "")
      return false;
   int n = this.m_strength;
   if(::JSONConfig_IntValue(section, "m_swing_strength", n))
      this.Strength(n);
   bool use_wick = (this.m_price_basis == SWING_PRICE_BASIS_WICK);
   if(::JSONConfig_BoolValue(section, "m_swing_use_wick", use_wick))
      this.PriceBasis(use_wick ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY);
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   for(int i = 0; i < 2; i++)
     {
      string obj = ::JSONConfig_ExtractRawSection(section, SwingTypeDescription(types[i]));
      if(obj == "")
         continue;
      bool v = this.SignalShow(types[i]);
      if(::JSONConfig_BoolValue(obj, "m_swing_signal_show", v))   this.SignalShow(types[i], v);
      v = this.SoundAlert(types[i]);
      if(::JSONConfig_BoolValue(obj, "m_swing_alert_sound", v))   this.SoundAlert(types[i], v);
      v = this.MessageAlert(types[i]);
      if(::JSONConfig_BoolValue(obj, "m_swing_alert_message", v)) this.MessageAlert(types[i], v);
     }
   ENUM_MARKET_STRUCTURE_TYPE structures[2] = {MARKET_STRUCTURE_BOS, MARKET_STRUCTURE_CHOCH};
   for(int i = 0; i < 2; i++)
     {
      string obj = ::JSONConfig_ExtractRawSection(section, MarketStructureTypeDescription(structures[i]));
      if(obj == "")
         continue;
      bool v = this.SignalShow(structures[i]);
      if(::JSONConfig_BoolValue(obj, "m_swing_signal_show", v))   this.SignalShow(structures[i], v);
      v = this.SoundAlert(structures[i]);
      if(::JSONConfig_BoolValue(obj, "m_swing_alert_sound", v))   this.SoundAlert(structures[i], v);
      v = this.MessageAlert(structures[i]);
      if(::JSONConfig_BoolValue(obj, "m_swing_alert_message", v)) this.MessageAlert(structures[i], v);
     }
   return true;
  }
 void CSmartMoneySetting::BuildJsonSection(string &out_json) const
  {
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   out_json  = "{\n";
   out_json += "  \"m_swing_strength\": " + (string)this.m_strength + ",\n";
   out_json += "  \"m_swing_use_wick\": " + (this.m_price_basis == SWING_PRICE_BASIS_WICK ? "true" : "false") + ",\n";
   for(int i = 0; i < 2; i++)
     {
      if(i > 0)
         out_json += ",\n";
      out_json += "  \"" + SwingTypeDescription(types[i]) + "\": { \"m_swing_signal_show\": " + (this.SignalShow(types[i]) ? "true" : "false") +
                  ", \"m_swing_alert_sound\": "   + (this.SoundAlert(types[i])   ? "true" : "false") +
                  ", \"m_swing_alert_message\": " + (this.MessageAlert(types[i]) ? "true" : "false") + " }";
     }
   ENUM_MARKET_STRUCTURE_TYPE structures[2] = {MARKET_STRUCTURE_BOS, MARKET_STRUCTURE_CHOCH};
   for(int i = 0; i < 2; i++)
      out_json += ",\n  \"" + MarketStructureTypeDescription(structures[i]) + "\": { \"m_swing_signal_show\": " + (this.SignalShow(structures[i]) ? "true" : "false") +
                  ", \"m_swing_alert_sound\": "   + (this.SoundAlert(structures[i])   ? "true" : "false") +
                  ", \"m_swing_alert_message\": " + (this.MessageAlert(structures[i]) ? "true" : "false") + " }";
   out_json += "\n }";
  }
 bool CSmartMoneySetting::Save(void)
  {
   string value;
   this.BuildJsonSection(value);
   string full_path = this.GetFolderName() + "/Config_Setting.json";
   return ::JSONConfig_SaveSection(full_path, "Swing_Alerts_Setting", value);
  }
 bool CSmartMoneySetting::AllShown(void) const
  {
   for(int i = 0; i < 4; i++)
      if(!m_signal_show[i])
         return false;
   return true;
  }
 bool CSmartMoneySetting::Strength(const int n)
  {
   int v = (n < 1) ? 1 : n;
   if(v == m_strength) return false;
   m_strength = v;
   return true;
  }
 bool CSmartMoneySetting::PriceBasis(const ENUM_SWING_PRICE_BASIS basis)
  {
   if(basis == m_price_basis) return false;
   m_price_basis = basis;
   return true;
  }
 bool CSmartMoneySetting::SignalShow(const ENUM_SWING_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_signal_show[i] : false;
  }
 bool CSmartMoneySetting::SoundAlert(const ENUM_SWING_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_sound_alert[i] : false;
  }
 bool CSmartMoneySetting::MessageAlert(const ENUM_SWING_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_message_alert[i] : false;
  }
 bool CSmartMoneySetting::SignalShow(const ENUM_SWING_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_signal_show[i] == v) return false;
   m_signal_show[i] = v;
   return true;
  }
 bool CSmartMoneySetting::SoundAlert(const ENUM_SWING_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_sound_alert[i] == v) return false;
   m_sound_alert[i] = v;
   return true;
  }
 bool CSmartMoneySetting::MessageAlert(const ENUM_SWING_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_message_alert[i] == v) return false;
   m_message_alert[i] = v;
   return true;
  }
 bool CSmartMoneySetting::SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_signal_show[i] : false;
  }
 bool CSmartMoneySetting::SoundAlert(const ENUM_MARKET_STRUCTURE_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_sound_alert[i] : false;
  }
 bool CSmartMoneySetting::MessageAlert(const ENUM_MARKET_STRUCTURE_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_message_alert[i] : false;
  }
 bool CSmartMoneySetting::SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_signal_show[i] == v) return false;
   m_signal_show[i] = v;
   return true;
  }
 bool CSmartMoneySetting::SoundAlert(const ENUM_MARKET_STRUCTURE_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_sound_alert[i] == v) return false;
   m_sound_alert[i] = v;
   return true;
  }
 bool CSmartMoneySetting::MessageAlert(const ENUM_MARKET_STRUCTURE_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_message_alert[i] == v) return false;
   m_message_alert[i] = v;
   return true;
  }
#endif // CSMARTMONEYSETTING_MQH_IMPLEMENTATION
#endif // __SMARTMONEYSETTING_MQH__
