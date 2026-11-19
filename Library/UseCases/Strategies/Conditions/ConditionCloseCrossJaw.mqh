//+------------------------------------------------------------------+
//|                                       ConditionCloseCrossJaw.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Rule "close_cross_jaw" (Profitunity isBreakdown_jaws_buy/_sell): |
//| the close crosses the Jaw (buffer 0 of Alligator) on the bar.    |
//| From CStrategyProfitunity::Calculate. New in V5                  |
//+------------------------------------------------------------------+
#ifndef __CONDITIONCLOSECROSSJAW_MQH__
#define __CONDITIONCLOSECROSSJAW_MQH__
 #include "ConditionJudge.mqh"
 class CConditionCloseCrossJaw : public CConditionJudge
  {
   public:
    virtual string    Rule(void) const { return "close_cross_jaw"; }
    virtual bool      Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const;
  };
 bool CConditionCloseCrossJaw::Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const
  {
   side=SIGNAL_DIRECTION_NONE;
   CIndicatorDE *alligator=slots.Indicator(slot);
   const datetime t1=::iTime(symbol,timeframe,shift),t2=::iTime(symbol,timeframe,shift+1);
   if(alligator==NULL || t1==0 || t2==0)
      return false;
   const double jaw1=alligator.Value(0,t1),jaw2=alligator.Value(0,t2);
   if(!Known(jaw1) || !Known(jaw2))
      return false;
   const double close1=::iClose(symbol,timeframe,shift),close2=::iClose(symbol,timeframe,shift+1);
   if(jaw1<close1 && jaw2>close2)
      side=SIGNAL_DIRECTION_BUY;
   else if(jaw1>close1 && jaw2<close2)
      side=SIGNAL_DIRECTION_SELL;
   return true;
  }
#endif // __CONDITIONCLOSECROSSJAW_MQH__
