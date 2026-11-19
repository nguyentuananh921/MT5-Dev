//+------------------------------------------------------------------+
//|                                              ConditionSignal.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Rule "signal": the basic signal of the slot on the bar, read from|
//| its CSignal (judged before by CSignalsCollection, never judged   |
//| again here). New in V5                                           |
//+------------------------------------------------------------------+
#ifndef __CONDITIONSIGNAL_MQH__
#define __CONDITIONSIGNAL_MQH__
 #include "ConditionJudge.mqh"
 class CConditionSignal : public CConditionJudge
  {
   public:
    virtual string    Rule(void) const { return "signal"; }
    virtual bool      Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const;
  };
 bool CConditionSignal::Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const
  {
   side=SIGNAL_DIRECTION_NONE;
   CSignal *signal=slots.Signal(slot);
   const datetime time=::iTime(symbol,timeframe,shift);
   if(signal==NULL || time==0 || signal.JudgedTo()<time)
      return false;   // the signal is not judged to the bar yet (OnChartEvent order of the EA: signals before strategies)
   side=signal.DirectionAt(time);
   return true;
  }
#endif // __CONDITIONSIGNAL_MQH__
