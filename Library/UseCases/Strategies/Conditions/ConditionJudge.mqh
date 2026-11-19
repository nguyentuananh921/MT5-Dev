//+------------------------------------------------------------------+
//|                                               ConditionJudge.mqh |
//|                                     Copyright 2026, Anhnt        |
//| The judge of a rule of Setting_StrategyCondition: the event of   |
//| a slot on a bar (Concept.md). One judge per rule, any strategy   |
//| uses it. CStrategyEngine combines them. New in V5                |
//+------------------------------------------------------------------+
#ifndef __CONDITIONJUDGE_MQH__
#define __CONDITIONJUDGE_MQH__
 #include "..\StrategySlots.mqh"
 class CConditionJudge : public CObject
  {
   protected:
    static bool       Known(const double value)          { return (value!=EMPTY_VALUE && value!=0.0 && ::MathIsValidNumber(value)); }
   public:
    virtual string    Rule(void) const                    { return ""; }   // Setting_StrategyCondition.rule
   //--- The side of the event of the slot on the bar at the shift (SIGNAL_DIRECTION_NONE: no event). False: a value is not on RAM yet
    virtual bool      Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const
                         { side=SIGNAL_DIRECTION_NONE; return false; }
  };
#endif // __CONDITIONJUDGE_MQH__
