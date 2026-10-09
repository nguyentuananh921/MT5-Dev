//+------------------------------------------------------------------+
//|                                                PatternSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 candle pattern: its Buy / Sell / Sound / Message  |
//| flags (V2 CBarPatternControl without the calculation: Python     |
//| finds the patterns, this only says what to show and alert)       |
//+------------------------------------------------------------------+
#ifndef __PATTERNSETTING_MQH__
#define __PATTERNSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\EventDefines.mqh>

#ifndef CPATTERNSETTING_MQH_DECLARATION
#define CPATTERNSETTING_MQH_DECLARATION
 class CPatternSetting : public CBaseObj
  {
    private:
     uint              m_candles;             // candles of the formation, 0 until Python sends the catalog
     bool              m_has_buy;             // the pattern can be a Buy / a Sell: both until Python sends the catalog
     bool              m_has_sell;
     bool              m_buy_signal;          // show the Buy markers of this pattern
     bool              m_sell_signal;         // show the Sell markers of this pattern
     bool              m_sound_alert;
     bool              m_message_alert;
    public:
                       CPatternSetting(const string name);
                      ~CPatternSetting(void) {}
     string            Name(void)            const { return m_name;          }
     uint              Candles(void)         const { return m_candles;       }
     void              Candles(const uint n)       { m_candles = n;          }
   //--- Sides the pattern can have, "B" / "S" / "BS" / "" as Python sends them
     bool              HasBuy(void)          const { return m_has_buy;       }
     bool              HasSell(void)         const { return m_has_sell;      }
     void              Sides(const string sides)   { m_has_buy = (::StringFind(sides, "B") >= 0); m_has_sell = (::StringFind(sides, "S") >= 0); }
   //--- Buy / Sell fire PATTERN_MANAGER_EVENT_BUYSELL_CHANGED when they change, unless notify is false
     bool              BuySignal(void)       const { return m_buy_signal;    }
     void              BuySignal(const bool v,const bool notify=true);
     bool              SellSignal(void)      const { return m_sell_signal;   }
     void              SellSignal(const bool v,const bool notify=true);
     bool              SoundAlert(void)      const { return m_sound_alert;   }
     void              SoundAlert(const bool v)    { m_sound_alert = v;      }
     bool              MessageAlert(void)    const { return m_message_alert; }
     void              MessageAlert(const bool v)  { m_message_alert = v;    }
     virtual void      Print(const bool full_prop=false,const bool dash=false);
  };
#endif // CPATTERNSETTING_MQH_DECLARATION

#ifndef CPATTERNSETTING_MQH_IMPLEMENTATION
#define CPATTERNSETTING_MQH_IMPLEMENTATION
 CPatternSetting::CPatternSetting(const string name) : m_candles(0), m_has_buy(true), m_has_sell(true),
                                                       m_buy_signal(true), m_sell_signal(true),
                                                       m_sound_alert(true), m_message_alert(true)
  {
   this.m_type = OBJECT_DE_TYPE_PATTERN_SETTING;
   this.m_name = name;   // identity: the pattern name Python sends and "Pattern_Alerts_Setting" uses
  }
 void CPatternSetting::BuySignal(const bool v,const bool notify=true)
  {
   if(m_buy_signal == v)
      return;
   m_buy_signal = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)PATTERN_MANAGER_EVENT_BUYSELL_CHANGED, 0, 0.0, m_name);
  }
 void CPatternSetting::SellSignal(const bool v,const bool notify=true)
  {
   if(m_sell_signal == v)
      return;
   m_sell_signal = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)PATTERN_MANAGER_EVENT_BUYSELL_CHANGED, 0, 0.0, m_name);
  }
 void CPatternSetting::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print((dash ? " - " : ""), "CPatternSetting::Print ", m_name, " candles=", m_candles, " buy=", m_buy_signal,
           " sell=", m_sell_signal, " sound=", m_sound_alert, " message=", m_message_alert);
  }
#endif // CPATTERNSETTING_MQH_IMPLEMENTATION
#endif // __PATTERNSETTING_MQH__
