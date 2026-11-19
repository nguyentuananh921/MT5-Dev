//+------------------------------------------------------------------+
//|                                            ConditionMACross.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Rule "ma_cross" (Solomon Anietie Sunday, Risk Management Part 7, |
//| FixedMACrossover_Part7 ReadSignal): the MA of the slot crosses   |
//| the MA of the slot "SlowMA" on the bar. New in V5                |
//+------------------------------------------------------------------+
#ifndef __CONDITIONMACROSS_MQH__
#define __CONDITIONMACROSS_MQH__
 #include "ConditionJudge.mqh"
 #define CONDITION_MA_CROSS_SLOW  "SlowMA"   // the slot the fast MA of the row is compared with
 class CConditionMACross : public CConditionJudge
  {
   public:
    virtual string    Rule(void) const { return "ma_cross"; }
    virtual bool      Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const;
  };
 bool CConditionMACross::Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const
  {
   side=SIGNAL_DIRECTION_NONE;
   CIndicatorDE *fast=slots.Indicator(slot);
   CIndicatorDE *slow=slots.Indicator(CONDITION_MA_CROSS_SLOW);
   const datetime t1=::iTime(symbol,timeframe,shift),t2=::iTime(symbol,timeframe,shift+1);
   if(fast==NULL || slow==NULL || t1==0 || t2==0)
      return false;
   const double fast1=fast.Value(0,t1),fast2=fast.Value(0,t2),slow1=slow.Value(0,t1),slow2=slow.Value(0,t2);
   if(!Known(fast1) || !Known(fast2) || !Known(slow1) || !Known(slow2))
      return false;
   if(fast1>slow1 && fast2<=slow2)
      side=SIGNAL_DIRECTION_BUY;
   else if(fast1<slow1 && fast2>=slow2)
      side=SIGNAL_DIRECTION_SELL;
   return true;
  }
#endif // __CONDITIONMACROSS_MQH__
