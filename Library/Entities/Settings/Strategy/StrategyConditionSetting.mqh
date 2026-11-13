//+------------------------------------------------------------------+
//|                                     StrategyConditionSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 row of Setting_StrategyCondition (a condition of  |
//| a strategy on one of its slots)                                  |
//| New in V5                                                        |
//+------------------------------------------------------------------+
#ifndef __STRATEGYCONDITIONSETTING_MQH__
#define __STRATEGYCONDITIONSETTING_MQH__
 #include "..\..\Bases\BaseObj.mqh"
 #include "..\..\Defines\CommonDefines.mqh"
#ifndef CSTRATEGYCONDITIONSETTING_MQH_DECLARATION
#define CSTRATEGYCONDITIONSETTING_MQH_DECLARATION
 class CStrategyConditionSetting : public CBaseObj
  {
    private:
     string                     m_role;              // "entry", "exit", "stoploss", "takeprofit"
     ENUM_SIGNAL_DIRECTION      m_signal_direction;  // exit: the direction that closes the other side
     string                     m_slot;
     string                     m_rule;              // "signal" / "last_signal": the standard signal of the slot (signals.py); else a rule of the strategy, as its source EA (Web conditions.ts)
    public:
                                CStrategyConditionSetting(const string role,const ENUM_SIGNAL_DIRECTION signal_direction,const string slot,const string rule);
                               ~CStrategyConditionSetting(void) {}
     string                     Role(void)            const { return m_role;             }
     ENUM_SIGNAL_DIRECTION      SignalDirection(void) const { return m_signal_direction; }
     string                     Slot(void)            const { return m_slot;             }
     string                     Rule(void)            const { return m_rule;             }
  };
#endif // CSTRATEGYCONDITIONSETTING_MQH_DECLARATION
#ifndef CSTRATEGYCONDITIONSETTING_MQH_IMPLEMENTATION
#define CSTRATEGYCONDITIONSETTING_MQH_IMPLEMENTATION
 CStrategyConditionSetting::CStrategyConditionSetting(const string role,const ENUM_SIGNAL_DIRECTION signal_direction,const string slot,const string rule) :
                                                      m_role(role),m_signal_direction(signal_direction),m_slot(slot),m_rule(rule)
  {
   this.m_object_type=OBJECT_DE_TYPE_STRATEGY_CONDITION_SETTING;
  }
#endif // CSTRATEGYCONDITIONSETTING_MQH_IMPLEMENTATION
#endif // __STRATEGYCONDITIONSETTING_MQH__
