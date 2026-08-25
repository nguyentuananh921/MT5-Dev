//+------------------------------------------------------------------+
//|                                              SymbolTFSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Replaces struct SJsonSymbolTF (Anatoli Kazharski\JSONConfig.mqh) with a class -        |
//| same pattern as CIndicatorSetting/IndicatorSetting.mqh, far fewer fields.               |
//| 1 instance = 1 Symbol+TF pair (config row) - held in CSymbolTFManager's list.           |
//+------------------------------------------------------------------+
#ifndef __SYMBOLTFSETTING_MQH__
#define __SYMBOLTFSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Services\DELib\TimeseriesDELib.mqh>

 #ifndef CSYMBOLTFSETTING_MQH_DECLARATION
 #define CSYMBOLTFSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------------------------+
 //| CSymbolTFSetting - 1 Symbol+TF's config row, replaces struct SJsonSymbolTF.        |
 //| CBaseObj (not CBaseObjExt) - static config row, same as CIndicatorSetting.         |
 //+------------------------------------------------------------------------------------+
 class CSymbolTFSetting : public CBaseObj
   {
     private:
       string           m_symbol;      // IDENTITY - already canonical (::SymbolName()/::Symbol())
       ENUM_TIMEFRAMES  m_tf_enum;     // IDENTITY (raw) - never text, same principle as CIndicatorSetting.TypeEnum()
       bool             m_buy_signal;  // opt-in: count this Symbol+TF's Buy cross into the Signal Bridge
       bool             m_sell_signal; // opt-in: count this Symbol+TF's Sell cross into the Signal Bridge

     public:
                         CSymbolTFSetting(void);
                        ~CSymbolTFSetting(void) {}

      //--- identity (raw) - the ONLY thing used for matching, never text
       string            Symbol(void)                          const { return m_symbol;  }
       void              Symbol(const string sym)                     { m_symbol = sym;   }
       ENUM_TIMEFRAMES   TFEnum(void)                          const { return m_tf_enum; }
       void              TFEnum(const ENUM_TIMEFRAMES tf)             { m_tf_enum = tf;   }
       bool              MatchesIdentity(const string sym, const ENUM_TIMEFRAMES tf) const { return m_symbol == sym && m_tf_enum == tf; }

      //--- display text ("M1","H1",...) - derived on demand via the Library's own
      //--- TimeframeDescription(), no separate stored/text field needed (unlike
      //--- CIndicatorSetting's params, a TF has no schema/precision to preserve).
       string            TFText(void)                          const { return TimeframeDescription(m_tf_enum); }

      //--- toggles - mirror table columns 2/3 directly
       bool              BuySignal(void)      const { return m_buy_signal;  }
       void              BuySignal(const bool v)    { m_buy_signal = v;     }
       bool              SellSignal(void)     const { return m_sell_signal; }
       void              SellSignal(const bool v)   { m_sell_signal = v;    }

       virtual void      Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CSymbolTFSetting::CSymbolTFSetting(void) : m_tf_enum(PERIOD_CURRENT),
                                             m_buy_signal(true), m_sell_signal(true)
   {
     this.m_type = OBJECT_DE_TYPE_SYMBOLTF_SETTING;
   }
 //+------------------------------------------------------------------+
 //| Debug dump                                                        |
 //+------------------------------------------------------------------+
 void CSymbolTFSetting::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print((dash ? " - " : ""), "CSymbolTFSetting::Print symbol=", m_symbol, " tf=", TFText(),
             " buy=", m_buy_signal, " sell=", m_sell_signal);
   }
 #endif // CSYMBOLTFSETTING_MQH_DECLARATION
#endif // __SYMBOLTFSETTING_MQH__
