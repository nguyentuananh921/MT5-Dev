//+------------------------------------------------------------------+
//|                                              StrategySetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 row of Setting_Strategy and its rows of           |
//| Setting_StrategyIndicator (its slots) and                        |
//| Setting_StrategyCondition (its conditions)                       |
//| New in V5, as CBarInformationSetting                             |
//+------------------------------------------------------------------+
#ifndef __STRATEGYSETTING_MQH__
#define __STRATEGYSETTING_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "StrategyIndicatorSetting.mqh"
 #include "StrategyConditionSetting.mqh"
 #include "..\..\Defines\EventDefines.mqh"
#ifndef CSTRATEGYSETTING_MQH_DECLARATION
#define CSTRATEGYSETTING_MQH_DECLARATION
 class CStrategySetting : public CBaseObj
  {
    private:
     long                       m_strategy_id;     // identity
     string                     m_reference;       // a note to find where it comes from (the article, the EA)
     //--- No tf of its own: each slot has its tf (PERIOD_CURRENT: the Period it is judged / drawn / traded on)
     //--- New in V5: three flags, each its own meaning. trading_enabled: On in trading (the user). available: every slot has its source (a template of its params:
     //--- another strategy or the user may have made them, so available is not On). show_on_chart: only the drawing. Python calculates what is available,
     //--- the EA judges live what is available and (trading_enabled or shown), the trading takes the entries of what is trading_enabled
     bool                       m_enabled_trading; // Setting_Strategy.trading_enabled
     bool                       m_slots_available; // Setting_Strategy.available (m_available is the one of CBaseObj: the chart)
     bool                       m_show_on_chart;   // its entries are drawn on the chart (CBarMarker)
     CArrayObj                  m_list_indicator;  // CStrategyIndicatorSetting, in the order of the table
     CArrayObj                  m_list_condition;  // CStrategyConditionSetting
    public:
                                CStrategySetting(const long strategy_id,const string name,const string reference);
                               ~CStrategySetting(void) {}
     long                       StrategyId(void)      const { return m_strategy_id;   }
     string                     Name(void)            const { return m_name;          }
     string                     Reference(void)       const { return m_reference;     }
   //--- show_on_chart fires STRATEGY_MANAGER_EVENT_SHOW_CHANGED when it changes, unless notify is false
     bool                       ShowOnChart(void)     const { return m_show_on_chart; }
     void                       ShowOnChart(const bool on,const bool notify=true);
   //--- New in V5: trading_enabled fires STRATEGY_MANAGER_EVENT_ENABLED_CHANGED, available STRATEGY_MANAGER_EVENT_AVAILABLE_CHANGED when they change, unless notify is false
     bool                       EnabledTrading(void)  const { return m_enabled_trading; }
     void                       EnabledTrading(const bool on,const bool notify=true);
     bool                       SlotsAvailable(void)  const { return m_slots_available; }
     void                       SlotsAvailable(const bool on,const bool notify=true);
   //--- New in V5: the EA judges it live (CStrategyCollection): its slots are there and the user trades or watches it
     bool                       IsLive(void)          const { return m_slots_available && (m_enabled_trading || m_show_on_chart); }
   //--- The slots and the conditions: (1) one more, (2) how many, (3) one of them
     bool                       AddIndicator(const string slot,const ENUM_OBJECT_DE_TYPE collection,const long source_id,const ENUM_TIMEFRAMES tf,const string params);
     bool                       AddCondition(const string role,const ENUM_SIGNAL_DIRECTION signal_direction,const string slot,const string rule);
     int                        IndicatorsTotal(void) const { return m_list_indicator.Total(); }
     int                        ConditionsTotal(void) const { return m_list_condition.Total(); }
     CStrategyIndicatorSetting *Indicator(const int index) const { return m_list_indicator.At(index); }
     CStrategyIndicatorSetting *Indicator(const string slot) const;   // by its name (NULL: none)
     CStrategyConditionSetting *Condition(const int index) const { return m_list_condition.At(index); }
  };
#endif // CSTRATEGYSETTING_MQH_DECLARATION
#ifndef CSTRATEGYSETTING_MQH_IMPLEMENTATION
#define CSTRATEGYSETTING_MQH_IMPLEMENTATION
 CStrategySetting::CStrategySetting(const long strategy_id,const string name,const string reference) :
                                    m_strategy_id(strategy_id),m_reference(reference),m_enabled_trading(false),m_slots_available(false),m_show_on_chart(false)
  {
   this.m_object_type=OBJECT_DE_TYPE_STRATEGY_SETTING;
   this.m_name=name;   // the name Python, the Web and the user call it
  }
 //--- The event: lparam = the strategy_id
 void CStrategySetting::ShowOnChart(const bool on,const bool notify=true)
  {
   if(m_show_on_chart == on)
      return;
   m_show_on_chart = on;
   if(notify)
      this.EventSend((ushort)STRATEGY_MANAGER_EVENT_SHOW_CHANGED, m_strategy_id, 0.0, "");
  }
 void CStrategySetting::EnabledTrading(const bool on,const bool notify=true)
  {
   if(m_enabled_trading == on)
      return;
   m_enabled_trading = on;
   if(notify)
      this.EventSend((ushort)STRATEGY_MANAGER_EVENT_ENABLED_CHANGED, m_strategy_id, 0.0, "");
  }
 void CStrategySetting::SlotsAvailable(const bool on,const bool notify=true)
  {
   if(m_slots_available == on)
      return;
   m_slots_available = on;
   if(notify)
      this.EventSend((ushort)STRATEGY_MANAGER_EVENT_AVAILABLE_CHANGED, m_strategy_id, 0.0, "");
  }
 bool CStrategySetting::AddIndicator(const string slot,const ENUM_OBJECT_DE_TYPE collection,const long source_id,const ENUM_TIMEFRAMES tf,const string params)
  {
   CStrategyIndicatorSetting *row = new CStrategyIndicatorSetting(slot, collection, source_id, tf, params);
   if(row == NULL)
      return false;
   if(!m_list_indicator.Add(row))
     {
      delete row;
      return false;
     }
   return true;
  }
 CStrategyIndicatorSetting *CStrategySetting::Indicator(const string slot) const
  {
   for(int i = 0; i < m_list_indicator.Total(); i++)
     {
      CStrategyIndicatorSetting *row = m_list_indicator.At(i);
      if(row != NULL && row.Slot() == slot)
         return row;
     }
   return NULL;
  }
 bool CStrategySetting::AddCondition(const string role,const ENUM_SIGNAL_DIRECTION signal_direction,const string slot,const string rule)
  {
   CStrategyConditionSetting *row = new CStrategyConditionSetting(role, signal_direction, slot, rule);
   if(row == NULL)
      return false;
   if(!m_list_condition.Add(row))
     {
      delete row;
      return false;
     }
   return true;
  }
#endif // CSTRATEGYSETTING_MQH_IMPLEMENTATION
#endif // __STRATEGYSETTING_MQH__
