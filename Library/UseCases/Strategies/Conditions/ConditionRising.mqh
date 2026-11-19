//+------------------------------------------------------------------+
//|                                              ConditionRising.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Rule "rising": buffer 0 of the slot against the bar before,      |
//| >= = BUY, < = SELL (any indicator). Profitunity ac_color is this |
//| on AC: Accelerator.mq5 colours it green on >=. New in V5         |
//+------------------------------------------------------------------+
#ifndef __CONDITIONRISING_MQH__
#define __CONDITIONRISING_MQH__
 #include "ConditionJudge.mqh"
 class CConditionRising : public CConditionJudge
  {
   public:
    virtual string    Rule(void) const { return "rising"; }
    virtual bool      Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const;
  };
 bool CConditionRising::Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const
  {
   side=SIGNAL_DIRECTION_NONE;
   CIndicatorDE *indicator=slots.Indicator(slot);
   const datetime t1=::iTime(symbol,timeframe,shift),t2=::iTime(symbol,timeframe,shift+1);
   if(indicator==NULL || t1==0 || t2==0)
      return false;
   const double value1=indicator.Value(0,t1),value2=indicator.Value(0,t2);
   if(value1==EMPTY_VALUE || value2==EMPTY_VALUE)
      return false;   // a value of 0 is a value
   side=(value1>=value2 ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
   return true;
  }
#endif // __CONDITIONRISING_MQH__
