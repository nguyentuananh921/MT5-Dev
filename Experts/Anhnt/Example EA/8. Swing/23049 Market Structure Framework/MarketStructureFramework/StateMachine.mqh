//+------------------------------------------------------------------+
//|                                  StateMachine.mqh                |
//|                                  Copyright 2026, MetaQuotes      |
//|                                  https://www.mql5.com            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"
#include "EventBus.mqh"

//+------------------------------------------------------------------+
//| Market state machine – consumes break events and trend updates   |
//+------------------------------------------------------------------+
class CMarketStateMachine
  {
private:
   ENUM_MARKET_STATE    m_currentState;                                                      // current market state (BULLISH, BEARISH, TRANSITION, RANGE, UNKNOWN)
   CEventBus           *m_eventBus;                                                          // pointer to the central event bus for publishing state changes

   void                SetState(ENUM_MARKET_STATE newState, const SStructureEvent &trigger); // transition to a new state and publish a STATE_CHANGED event

public:
                     CMarketStateMachine();
   void                Init(CEventBus *bus);                                                 // reset the machine and attach to the event bus
   void                ProcessBreakEvent(const SStructureEvent &event, int trend);           // evaluate a new break event and possibly change state
   void                UpdateTrend(int trend);                                               // adjust the state based solely on trend (used when no break events exist)
   ENUM_MARKET_STATE   GetState() const { return m_currentState; }                           // current state
  };

//+------------------------------------------------------------------+
//| Constructor – sets initial state to UNKNOWN, event bus to NULL   |
//+------------------------------------------------------------------+
CMarketStateMachine::CMarketStateMachine()
  {
   m_currentState=STATE_UNKNOWN;                                                             // start with no determined state
   m_eventBus=NULL;                                                                          // bus will be assigned during Init()
  }

//+------------------------------------------------------------------+
//| Initialize state machine with event bus, reset to UNKNOWN        |
//+------------------------------------------------------------------+
void CMarketStateMachine::Init(CEventBus *bus)
  {
   m_eventBus=bus;                                                                          // store the bus pointer
   m_currentState=STATE_UNKNOWN;                                                            // reset to initial state
  }

//+------------------------------------------------------------------+
//| Transition to a new market state and publish a state-change event|
//+------------------------------------------------------------------+
void CMarketStateMachine::SetState(ENUM_MARKET_STATE newState, const SStructureEvent &trigger)
  {
   if(newState == m_currentState)
      return;                                                                              // no change needed

   m_currentState = newState;                                                              // update the internal state

   //--- construct a STATE_CHANGED event from the trigger's context
   SStructureEvent ev;
   ev.eventId = 0;                                                                         // state-change events do not require a unique ID
   ev.type = EVENT_STATE_CHANGED;
   ev.time = trigger.time;
   ev.price = trigger.price;
   ev.level = trigger.level;
   ev.direction = 0;                                                                       // direction is neutral for state transitions
   ev.state = m_currentState;                                                              // record the new state
   ev.confidence = 100;                                                                    // state transitions are always certain
   if(m_eventBus)
      m_eventBus.Publish(ev);                                                              // notify all consumers
  }

//+------------------------------------------------------------------+
//| ProcessBreakEvent – handle a structural break, update state      |
//| The machine uses the break type and current trend to decide      |
//| whether to enter BULLISH, BEARISH, or TRANSITION.                |
//+------------------------------------------------------------------+
void CMarketStateMachine::ProcessBreakEvent(const SStructureEvent &event, int trend)
  {
   //--- ignore non-break events
   if(event.type != EVENT_INTERNAL_BOS_BULLISH && event.type != EVENT_EXTERNAL_BOS_BULLISH &&
      event.type != EVENT_INTERNAL_BOS_BEARISH && event.type != EVENT_EXTERNAL_BOS_BEARISH &&
      event.type != EVENT_INTERNAL_CHOCH_BULLISH && event.type != EVENT_EXTERNAL_CHOCH_BULLISH &&
      event.type != EVENT_INTERNAL_CHOCH_BEARISH && event.type != EVENT_EXTERNAL_CHOCH_BEARISH)
      return;

   //--- determine if the event is a CHoCH (change of character)
   bool isChoch = (event.type == EVENT_INTERNAL_CHOCH_BULLISH || event.type == EVENT_EXTERNAL_CHOCH_BULLISH ||
                   event.type == EVENT_INTERNAL_CHOCH_BEARISH || event.type == EVENT_EXTERNAL_CHOCH_BEARISH);

   if(isChoch)
     {
      SetState(STATE_TRANSITION, event);                                                    // any CHoCH pushes the state to TRANSITION
      return;
     }

   //--- it's a BOS event; determine direction
   bool breakBullish = (event.type == EVENT_INTERNAL_BOS_BULLISH || event.type == EVENT_EXTERNAL_BOS_BULLISH);

   //--- if the current state is ambiguous, adopt the BOS direction immediately
   if(m_currentState == STATE_UNKNOWN || m_currentState == STATE_TRANSITION || m_currentState == STATE_RANGE)
     {
      SetState(breakBullish ? STATE_BULLISH : STATE_BEARISH, event);
      return;
     }

   //--- if the BOS agrees with the current state, no change is needed
   if(breakBullish && m_currentState == STATE_BULLISH)
      return;
   if(!breakBullish && m_currentState == STATE_BEARISH)
      return;

   //--- conflicting BOS: change state only if the trend also supports the reversal
   if(breakBullish && m_currentState == STATE_BEARISH && trend == 1)
     {
      SetState(STATE_BULLISH, event);
      return;
     }
   if(!breakBullish && m_currentState == STATE_BULLISH && trend == -1)
     {
      SetState(STATE_BEARISH, event);
      return;
     }
  }

//+------------------------------------------------------------------+
//| Update market state from trend (used when no break events exist) |
//| If the trend is flat, move to RANGE. Otherwise, set the state    |
//| according to the trend direction if the machine is uncertain.    |
//+------------------------------------------------------------------+
void CMarketStateMachine::UpdateTrend(int trend)
  {
   if(trend == 0)
     {
      //--- flat trend → force RANGE state if currently uncertain
      if(m_currentState == STATE_UNKNOWN || m_currentState == STATE_TRANSITION)
        {
         SStructureEvent dummy;
         dummy.time = TimeCurrent();
         dummy.price = 0;
         dummy.level = LEVEL_EXTERNAL;                                 // level is not critical for trend-only state changes
         SetState(STATE_RANGE, dummy);
        }
      return;
     }

   //--- directional trend: if the machine is in an uncertain state, align with trend
   if(m_currentState == STATE_UNKNOWN || m_currentState == STATE_TRANSITION || m_currentState == STATE_RANGE)
     {
      SStructureEvent dummy;
      dummy.time = TimeCurrent();
      dummy.price = 0;
      dummy.level = LEVEL_EXTERNAL;
      SetState(trend == 1 ? STATE_BULLISH : STATE_BEARISH, dummy);
     }
  }
//+------------------------------------------------------------------+