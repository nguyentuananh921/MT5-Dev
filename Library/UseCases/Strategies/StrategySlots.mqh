//+------------------------------------------------------------------+
//|                                                StrategySlots.mqh |
//|                                     Copyright 2026, Anhnt        |
//| The port of a strategy to its slots on a pair: what the judges   |
//| of its conditions read (Concept.md: the sources of the events).  |
//| CStrategyPairSlots (Collections) implements it. New in V5        |
//+------------------------------------------------------------------+
#ifndef __STRATEGYSLOTS_MQH__
#define __STRATEGYSLOTS_MQH__
 #include <Object.mqh>
 #include "..\..\Entities\Indicators\IndicatorDE.mqh"
 #include "..\..\Entities\Signals\Signal.mqh"
 class CStrategySlots : public CObject
  {
   public:
   //--- The indicator of a slot (its values on RAM), its basic signal (rule "signal"): NULL when its template is not made yet
    virtual CIndicatorDE *Indicator(const string slot) { return NULL; }
    virtual CSignal      *Signal(const string slot)    { return NULL; }
  };
#endif // __STRATEGYSLOTS_MQH__
