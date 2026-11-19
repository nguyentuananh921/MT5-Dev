//+------------------------------------------------------------------+
//|                                         ConditionLastFractal.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Rule "last_fractal" (Profitunity lastFractal_direction): the     |
//| newest fractal, a state: down = BUY, up = SELL; a down one of the |
//| same bar wins. From CStrategyProfitunity::LastFractal. New in V5 |
//+------------------------------------------------------------------+
#ifndef __CONDITIONLASTFRACTAL_MQH__
#define __CONDITIONLASTFRACTAL_MQH__
 #include "ConditionJudge.mqh"
 #define CONDITION_FRACTAL_BACK   500   // the bars looked back for the newest fractal (Python Profitunity.CONTEXT)
 class CConditionLastFractal : public CConditionJudge
  {
   public:
    virtual string    Rule(void) const { return "last_fractal"; }
    virtual bool      Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const;
  };
 bool CConditionLastFractal::Direction(CStrategySlots *slots,const string slot,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,ENUM_SIGNAL_DIRECTION &side) const
  {
   side=SIGNAL_DIRECTION_NONE;
   CIndicatorDE *fractals=slots.Indicator(slot);
   if(fractals==NULL)
      return false;
   for(int middle=shift+2;middle<shift+2+CONDITION_FRACTAL_BACK;middle++)   // from shift 3 (shift 1 + 2), not 2 as the source EA: why at CSetting_Profitunity, condition last_fractal
     {
      const datetime time=::iTime(symbol,timeframe,middle);
      if(time==0)
         return true;   // no fractal in the bars: NONE
      if(Known(fractals.Value(1,time)))
        {
         side=SIGNAL_DIRECTION_BUY;    // FRACTAL_DOWN
         return true;
        }
      if(Known(fractals.Value(0,time)))
        {
         side=SIGNAL_DIRECTION_SELL;   // FRACTAL_UP
         return true;
        }
     }
   return true;
  }
#endif // __CONDITIONLASTFRACTAL_MQH__
