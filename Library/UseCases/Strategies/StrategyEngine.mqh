//+------------------------------------------------------------------+
//|                                               StrategyEngine.mqh |
//|                                     Copyright 2026, Anhnt        |
//| One engine for every strategy (Concept.md: a strategy is how its |
//| events are combined): each row of Setting_StrategyCondition asks |
//| the judge of its rule for the event of its slot on the bar; the  |
//| moves come from the rows that hold, as Web conditionStrategy.    |
//| A row whose slot has its own tf is judged on the newest bar of   |
//| that tf closed when the bar of the pair closes (engine.py same)  |
//| New in V5 (was CStrategyProfitunity: one class per strategy)     |
//+------------------------------------------------------------------+
#ifndef __STRATEGYENGINE_MQH__
#define __STRATEGYENGINE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Entities\Settings\Strategy\StrategySetting.mqh"
 #include "..\..\Entities\Strategies\StrategyBase.mqh"   // STRATEGY_ROLE_ENTRY / _EXIT
 #include "Conditions\ConditionSignal.mqh"
 #include "Conditions\ConditionLastFractal.mqh"
 #include "Conditions\ConditionCloseCrossJaw.mqh"
 #include "Conditions\ConditionRising.mqh"
 #include "Conditions\ConditionMACross.mqh"
#ifndef CSTRATEGYENGINE_MQH_DECLARATION
#define CSTRATEGYENGINE_MQH_DECLARATION
 class CStrategyEngine : public CObject
  {
   private:
    CArrayObj         m_list_judge;   // one CConditionJudge per rule (owned): a new rule of any strategy is one more judge here
    CConditionJudge  *Judge(const string rule) const;
   //--- Every row of the role and the side has its event on that side (a role / side with no row never holds)
    bool              Holds(CStrategySetting *strategy,const ENUM_SIGNAL_DIRECTION &events[],const string role,const ENUM_SIGNAL_DIRECTION side) const;
   public:
                      CStrategyEngine(void);
                     ~CStrategyEngine(void) {}
   //--- The moves of the bar at the shift (1: the one that just closed): roles ("entry" / "exit") and sides (BUY / SELL: opened or closed).
   //--- buys / sells: the entries of the strategy open before it. Entry: every entry row of a side holds. Exit: every exit row of a side holds
   //--- and the other side is open (an AO SELL closes a BUY). Returns how many moves, WRONG_VALUE when a value is not on RAM yet
    int               Calculate(CStrategySetting *strategy,CStrategySlots *slots,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,
                                const int buys,const int sells,string &roles[],ENUM_SIGNAL_DIRECTION &sides[]) const;
  };
#endif // CSTRATEGYENGINE_MQH_DECLARATION
#ifndef CSTRATEGYENGINE_MQH_IMPLEMENTATION
#define CSTRATEGYENGINE_MQH_IMPLEMENTATION
 CStrategyEngine::CStrategyEngine(void)
  {
   this.m_list_judge.Add(new CConditionSignal());
   this.m_list_judge.Add(new CConditionLastFractal());
   this.m_list_judge.Add(new CConditionCloseCrossJaw());
   this.m_list_judge.Add(new CConditionRising());
   this.m_list_judge.Add(new CConditionMACross());
  }
 CConditionJudge *CStrategyEngine::Judge(const string rule) const
  {
   for(int i=0;i<this.m_list_judge.Total();i++)
     {
      CConditionJudge *judge=this.m_list_judge.At(i);
      if(judge!=NULL && judge.Rule()==rule)
         return judge;
     }
   return NULL;
  }
 bool CStrategyEngine::Holds(CStrategySetting *strategy,const ENUM_SIGNAL_DIRECTION &events[],const string role,const ENUM_SIGNAL_DIRECTION side) const
  {
   int rows=0;
   for(int c=0;c<strategy.ConditionsTotal();c++)
     {
      CStrategyConditionSetting *row=strategy.Condition(c);
      if(row==NULL || row.Role()!=role || row.SignalDirection()!=side)
         continue;
      if(events[c]!=side)
         return false;
      rows++;
     }
   return (rows>0);
  }
 int CStrategyEngine::Calculate(CStrategySetting *strategy,CStrategySlots *slots,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift,
                                const int buys,const int sells,string &roles[],ENUM_SIGNAL_DIRECTION &sides[]) const
  {
   ::ArrayResize(roles,0);
   ::ArrayResize(sides,0);
   if(strategy==NULL || slots==NULL)
      return WRONG_VALUE;
   //--- Every event first: one not on RAM yet and the bar waits (RetryPending), whatever side it is for
   const int total=strategy.ConditionsTotal();
   ENUM_SIGNAL_DIRECTION events[];
   ::ArrayResize(events,total);
   for(int c=0;c<total;c++)
     {
      events[c]=SIGNAL_DIRECTION_NONE;
      CStrategyConditionSetting *row=strategy.Condition(c);
      CConditionJudge *judge=(row!=NULL ? this.Judge(row.Rule()) : NULL);
      if(judge==NULL)
        {
         if(row!=NULL)
            ::Print(__FUNCTION__," > ",strategy.Name(),": no judge of the rule ",row.Rule()," (",row.Slot(),"): the row never holds");
         continue;
        }
      //--- A slot on another tf (Concepts.md, TF của Slot): its newest bar closed when the bar of the pair closes, no look-ahead
      ENUM_TIMEFRAMES row_tf=timeframe;
      int row_shift=shift;
      CStrategyIndicatorSetting *source=strategy.Indicator(row.Slot());
      if(source!=NULL && source.Timeframe()!=PERIOD_CURRENT && source.Timeframe()!=timeframe)
        {
         const datetime bar=::iTime(symbol,timeframe,shift);
         row_tf=source.Timeframe();
         const datetime closed=bar+::PeriodSeconds(timeframe);
         row_shift=(bar>0 ? ::iBarShift(symbol,row_tf,closed-1,false) : WRONG_VALUE);
         if(row_shift>=0 && ::iTime(symbol,row_tf,row_shift)+::PeriodSeconds(row_tf)>closed)
            row_shift++;   // that bar still forms then: the one before
         if(row_shift<0)
            return WRONG_VALUE;   // the bars of the tf of the slot are not there yet
        }
      if(!judge.Direction(slots,row.Slot(),symbol,row_tf,row_shift,events[c]))
         return WRONG_VALUE;
     }
   string role[4];
   ENUM_SIGNAL_DIRECTION side[4];
   int moves=0;
   if(this.Holds(strategy,events,STRATEGY_ROLE_ENTRY,SIGNAL_DIRECTION_BUY))
     {
      role[moves]=STRATEGY_ROLE_ENTRY;
      side[moves++]=SIGNAL_DIRECTION_BUY;
     }
   else if(this.Holds(strategy,events,STRATEGY_ROLE_ENTRY,SIGNAL_DIRECTION_SELL))
     {
      role[moves]=STRATEGY_ROLE_ENTRY;
      side[moves++]=SIGNAL_DIRECTION_SELL;
     }
   const int open_buys=buys+(moves>0 && side[0]==SIGNAL_DIRECTION_BUY ? 1 : 0);
   const int open_sells=sells+(moves>0 && side[0]==SIGNAL_DIRECTION_SELL ? 1 : 0);
   if(open_buys>0 && this.Holds(strategy,events,STRATEGY_ROLE_EXIT,SIGNAL_DIRECTION_SELL))
     {
      role[moves]=STRATEGY_ROLE_EXIT;
      side[moves++]=SIGNAL_DIRECTION_BUY;    // the side closed
     }
   else if(open_sells>0 && this.Holds(strategy,events,STRATEGY_ROLE_EXIT,SIGNAL_DIRECTION_BUY))
     {
      role[moves]=STRATEGY_ROLE_EXIT;
      side[moves++]=SIGNAL_DIRECTION_SELL;
     }
   ::ArrayResize(roles,moves);
   ::ArrayResize(sides,moves);
   for(int i=0;i<moves;i++)
     {
      roles[i]=role[i];
      sides[i]=side[i];
     }
   return moves;
  }
#endif // CSTRATEGYENGINE_MQH_IMPLEMENTATION
#endif // __STRATEGYENGINE_MQH__
