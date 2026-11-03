//+------------------------------------------------------------------+
//|                                              SymbolTFSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 row of Setting_SymbolTF (a pair of this account)  |
//+------------------------------------------------------------------+
//--- Change from V3 Entities\Settings\SymbolTFSetting.mqh (the file is gone, libdb.py still names it): made again on the model of CIndicatorSetting
#ifndef __SYMBOLTFSETTING_MQH__
#define __SYMBOLTFSETTING_MQH__
 #include "..\Bases\BaseObj.mqh"
#ifndef CSYMBOLTFSETTING_MQH_DECLARATION
#define CSYMBOLTFSETTING_MQH_DECLARATION
 class CSymbolTFSetting : public CBaseObj
  {
    private:
     long            m_symbol_id;           // the id of the symbol of ours (symbol_base)
     string          m_symbol;              // the name this account gives it (symbols)
     ENUM_TIMEFRAMES m_timeframe;
     bool            m_buy_signal;
     bool            m_sell_signal;
     bool            m_sound_alert;
     bool            m_message_alert;
    public:
                     CSymbolTFSetting(const long symbol_id,const string symbol,const ENUM_TIMEFRAMES timeframe);
                    ~CSymbolTFSetting(void) {}
     long            SymbolID(void)              const { return m_symbol_id;     }
     string          Symbol(void)                const { return m_symbol;        }
     ENUM_TIMEFRAMES Timeframe(void)             const { return m_timeframe;     }
     bool            BuySignal(void)             const { return m_buy_signal;    }
     void            BuySignal(const bool v)           { m_buy_signal = v;       }
     bool            SellSignal(void)            const { return m_sell_signal;   }
     void            SellSignal(const bool v)          { m_sell_signal = v;      }
     bool            SoundAlert(void)            const { return m_sound_alert;   }
     void            SoundAlert(const bool v)          { m_sound_alert = v;      }
     bool            MessageAlert(void)          const { return m_message_alert; }
     void            MessageAlert(const bool v)        { m_message_alert = v;    }
  };
#endif // CSYMBOLTFSETTING_MQH_DECLARATION
#ifndef CSYMBOLTFSETTING_MQH_IMPLEMENTATION
#define CSYMBOLTFSETTING_MQH_IMPLEMENTATION
 CSymbolTFSetting::CSymbolTFSetting(const long symbol_id,const string symbol,const ENUM_TIMEFRAMES timeframe) : m_symbol_id(symbol_id),m_symbol(symbol),m_timeframe(timeframe),
                                                                                                              m_buy_signal(true),m_sell_signal(true),m_sound_alert(true),m_message_alert(true)
  {
   this.m_object_type=OBJECT_DE_TYPE_SYMBOLTF_SETTING;
  }
#endif // CSYMBOLTFSETTING_MQH_IMPLEMENTATION
#endif // __SYMBOLTFSETTING_MQH__
