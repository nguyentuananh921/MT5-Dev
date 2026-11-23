//+------------------------------------------------------------------+
//|                                                    BaseEvent.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Timeseries in DoEasy library                                     |
//| Lib link            https://www.mql5.com/en/articles/8787        |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Base object event class for all library objects                  |
//+------------------------------------------------------------------+
#ifndef __BASEEVENT_MQH__
#define __BASEEVENT_MQH__
#include <Arrays\ArrayObj.mqh>
#include "..\Services\DELib.mqh"
 class CBaseEvent : public CObject
  {
   private:
    ENUM_BASE_EVENT_REASON  m_reason;
    int                     m_event_id;
    double                  m_value;
    public:
    ENUM_BASE_EVENT_REASON  Reason(void)   const { return this.m_reason;    }
    int                     ID(void)       const { return this.m_event_id;  }
    double                  Value(void)    const { return this.m_value;     }
    //--- Constructor
                            CBaseEvent(const int event_id,const ENUM_BASE_EVENT_REASON reason,const double value) : m_reason(reason),
                                                                                                                    m_event_id(event_id),
                                                                                                                    m_value(value){}
    //--- Comparison method to search for identical event objects
    virtual int             Compare(const CObject *node,const int mode=0) const 
                                {   
                                const CBaseEvent *compared=node;
                                return
                                (
                                    this.Reason()>compared.Reason()  ?  1  :
                                    this.Reason()<compared.Reason()  ? -1  :
                                    this.ID()>compared.ID()          ?  1  :
                                    this.ID()<compared.ID()          ? -1  : 0
                                );
                                } 
  };
#endif // __BASEEVENT_MQH__

