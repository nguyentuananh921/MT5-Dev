//+------------------------------------------------------------------+
//|                                                 BaseEvent.mqh    |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __CBASEEVENT_MQH__
#define __CBASEEVENT_MQH__
#include <Object.mqh>
#include "..\Defines\CommonDefines.mqh"

#ifndef CBASEEVENT_MQH_DECLARATION
#define CBASEEVENT_MQH_DECLARATION
 class CBaseEvent : public CObject
  {
   private:
    ENUM_BASE_EVENT_REASON  m_reason;
    int                     m_event_id;
    double                  m_value;
   public:
    ENUM_BASE_EVENT_REASON  Reason(void) const { return m_reason;   }
    int                     ID(void)     const { return m_event_id; }
    double                  Value(void)  const { return m_value;    }
    CBaseEvent(const int                    event_id,
               const ENUM_BASE_EVENT_REASON reason,
               const double                 value)
                              : m_reason(reason),
                                m_event_id(event_id),
                                m_value(value) {}

    virtual int             Compare(const CObject *node,const int mode=0) const;
  };
#endif // CBASEEVENT_MQH_DECLARATION

#ifndef CBASEEVENT_MQH_IMPLEMENTATION
#define CBASEEVENT_MQH_IMPLEMENTATION
 int CBaseEvent::Compare(const CObject *node,const int mode=0) const
  {
   const CBaseEvent *c=node;
   return(Reason()>c.Reason() ?  1 : Reason()<c.Reason() ? -1 :
          ID()>c.ID()         ?  1 : ID()<c.ID()         ? -1 : 0);
  }
#endif // CBASEEVENT_MQH_IMPLEMENTATION
#endif // __CBASEEVENT_MQH__
