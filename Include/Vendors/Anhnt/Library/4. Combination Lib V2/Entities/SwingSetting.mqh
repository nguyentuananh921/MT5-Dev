//+------------------------------------------------------------------+
//|                                                 SwingSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __SWINGSETTING_MQH__
#define __SWINGSETTING_MQH__
 #include "Defines\SwingDefines.mqh"

#ifndef CSWINGSETTING_MQH_DECLARATION
#define CSWINGSETTING_MQH_DECLARATION
 class CSwingSetting
  {
    private:
     int                     m_strength;
     ENUM_SWING_PRICE_BASIS  m_price_basis;
     bool                    m_signal_show[2];   // 0=High, 1=Low
     bool                    m_sound_alert[2];
     bool                    m_message_alert[2];
     int                     Index(const ENUM_SWING_TYPE type) const { return (type == SWING_TYPE_HIGH) ? 0 : (type == SWING_TYPE_LOW) ? 1 : -1; }
    public:
                             CSwingSetting(void);
     int                     Strength(void)   const { return m_strength;    }
     ENUM_SWING_PRICE_BASIS  PriceBasis(void) const { return m_price_basis; }
     bool                    Strength(const int n);
     bool                    PriceBasis(const ENUM_SWING_PRICE_BASIS basis);
     bool                    SignalShow(const ENUM_SWING_TYPE type)   const;
     bool                    SoundAlert(const ENUM_SWING_TYPE type)   const;
     bool                    MessageAlert(const ENUM_SWING_TYPE type) const;
     bool                    SignalShow(const ENUM_SWING_TYPE type, const bool v);
     bool                    SoundAlert(const ENUM_SWING_TYPE type, const bool v);
     bool                    MessageAlert(const ENUM_SWING_TYPE type, const bool v);
  };
#endif // CSWINGSETTING_MQH_DECLARATION

#ifndef CSWINGSETTING_MQH_IMPLEMENTATION
#define CSWINGSETTING_MQH_IMPLEMENTATION
 CSwingSetting::CSwingSetting(void) : m_strength(5), m_price_basis(SWING_PRICE_BASIS_WICK)
  {
   for(int i = 0; i < 2; i++)
    {
     m_signal_show[i]   = true;
     m_sound_alert[i]   = false;
     m_message_alert[i] = false;
    }
  }
 bool CSwingSetting::Strength(const int n)
  {
   int v = (n < 1) ? 1 : n;
   if(v == m_strength) return false;
   m_strength = v;
   return true;
  }
 bool CSwingSetting::PriceBasis(const ENUM_SWING_PRICE_BASIS basis)
  {
   if(basis == m_price_basis) return false;
   m_price_basis = basis;
   return true;
  }
 bool CSwingSetting::SignalShow(const ENUM_SWING_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_signal_show[i] : false;
  }
 bool CSwingSetting::SoundAlert(const ENUM_SWING_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_sound_alert[i] : false;
  }
 bool CSwingSetting::MessageAlert(const ENUM_SWING_TYPE type) const
  {
   int i = Index(type);
   return (i >= 0) ? m_message_alert[i] : false;
  }
 bool CSwingSetting::SignalShow(const ENUM_SWING_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_signal_show[i] == v) return false;
   m_signal_show[i] = v;
   return true;
  }
 bool CSwingSetting::SoundAlert(const ENUM_SWING_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_sound_alert[i] == v) return false;
   m_sound_alert[i] = v;
   return true;
  }
 bool CSwingSetting::MessageAlert(const ENUM_SWING_TYPE type, const bool v)
  {
   int i = Index(type);
   if(i < 0 || m_message_alert[i] == v) return false;
   m_message_alert[i] = v;
   return true;
  }
#endif // CSWINGSETTING_MQH_IMPLEMENTATION
#endif // __SWINGSETTING_MQH__
