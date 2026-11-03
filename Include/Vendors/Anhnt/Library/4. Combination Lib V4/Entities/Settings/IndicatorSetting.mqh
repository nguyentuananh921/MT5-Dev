//+------------------------------------------------------------------+
//|                                             IndicatorSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 row of Setting_IndicatorTemplate (a template)     |
//+------------------------------------------------------------------+
//--- Change from V3 Entities\Settings\IndicatorSetting.mqh: the row of the table (id, the params as their saved text, display) instead of MqlParam
//--- (CIndicatorTemplateManager::ParamsFromText reads them); a setter that tells sends the event of the manager with the identity (type, params text)
#ifndef __INDICATORSETTING_MQH__
#define __INDICATORSETTING_MQH__
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\EventDefines.mqh"
#ifndef CINDICATORSETTING_MQH_DECLARATION
#define CINDICATORSETTING_MQH_DECLARATION
 class CIndicatorSetting : public CBaseObj
  {
    private:
     long            m_id;                  // the key of the template for the tables that point to it (its signals)
     ENUM_INDICATOR  m_type_enum;           // identity, together with m_params
     string          m_params;              // the params as the one text of the table
     string          m_display;             // the short text the user reads
     bool            m_buy_signal;
     bool            m_sell_signal;
     bool            m_sound_alert;
     bool            m_message_alert;
     bool            m_show_on_chart;       // the indicator is attached to the chart; the chart side can change it too
    public:
                     CIndicatorSetting(const long id,const ENUM_INDICATOR type,const string params,const string display);
                    ~CIndicatorSetting(void) {}
     long            ID(void)                       const { return m_id;            }
     ENUM_INDICATOR  TypeEnum(void)                 const { return m_type_enum;     }
     string          Params(void)                   const { return m_params;        }
     string          Display(void)                  const { return m_display;       }
   //--- Buy / Sell fire INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED when they change, Show fires _SHOW_CHANGED, unless notify is false
     bool            BuySignal(void)      const { return m_buy_signal;    }
     void            BuySignal(const bool v,const bool notify=true);
     bool            SellSignal(void)     const { return m_sell_signal;   }
     void            SellSignal(const bool v,const bool notify=true);
     bool            SoundAlert(void)     const { return m_sound_alert;   }
     void            SoundAlert(const bool v)   { m_sound_alert = v;      }
     bool            MessageAlert(void)   const { return m_message_alert; }
     void            MessageAlert(const bool v) { m_message_alert = v;    }
     bool            ShowOnChart(void)    const { return m_show_on_chart; }
     void            ShowOnChart(const bool v,const bool notify=true);
  };
#endif // CINDICATORSETTING_MQH_DECLARATION
#ifndef CINDICATORSETTING_MQH_IMPLEMENTATION
#define CINDICATORSETTING_MQH_IMPLEMENTATION
 CIndicatorSetting::CIndicatorSetting(const long id,const ENUM_INDICATOR type,const string params,const string display) : m_id(id),m_type_enum(type),m_params(params),m_display(display),
                                                                                                                           m_buy_signal(true),m_sell_signal(true),
                                                                                                                           m_sound_alert(true),m_message_alert(true),
                                                                                                                           m_show_on_chart(true)
  {
   this.m_object_type=OBJECT_DE_TYPE_INDICATOR_SETTING;
  }
 //--- The event: lparam = the type, sparam = the params of the template (the identity, never a position)
 void CIndicatorSetting::BuySignal(const bool v,const bool notify=true)
  {
   if(m_buy_signal == v)
      return;
   m_buy_signal = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED, (long)m_type_enum, 0.0, m_params);
  }
 void CIndicatorSetting::SellSignal(const bool v,const bool notify=true)
  {
   if(m_sell_signal == v)
      return;
   m_sell_signal = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED, (long)m_type_enum, 0.0, m_params);
  }
 void CIndicatorSetting::ShowOnChart(const bool v,const bool notify=true)
  {
   if(m_show_on_chart == v)
      return;
   m_show_on_chart = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED, (long)m_type_enum, 0.0, m_params);
  }
#endif // CINDICATORSETTING_MQH_IMPLEMENTATION
#endif // __INDICATORSETTING_MQH__
