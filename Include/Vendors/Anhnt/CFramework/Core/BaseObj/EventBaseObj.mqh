//+------------------------------------------------------------------+
//|                                                 EventBaseObj.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>

/*
#include "..\Services\DELib.mqh"
#include "..\Objects\Graph\GraphElmControl.mqh"
*/
#include <Vendors/Anhnt/CFramework/Old/Services/DELib.mqh>
#include <Vendors/Anhnt/CFramework/Core/BaseGraph/GraphElmControl.mqh>
//+------------------------------------------------------------------+
//| Base object event class for all library objects                  |
//+------------------------------------------------------------------+
class CEventBaseObj : public CObject
  {
private:
   long              m_time;
   long              m_chart_id;
   ushort            m_event_id;
   long              m_lparam;
   double            m_dparam;
   string            m_sparam;
public:
   void              Time(const long time)               { this.m_time=time;           }
   long              Time(void)                    const { return this.m_time;         }
   void              ChartID(const long chart_id)        { this.m_chart_id=chart_id;   }
   long              ChartID(void)                 const { return this.m_chart_id;     }
   void              ID(const ushort id)                 { this.m_event_id=id;         }
   ushort            ID(void)                      const { return this.m_event_id;     }
   void              LParam(const long lparam)           { this.m_lparam=lparam;       }
   long              LParam(void)                  const { return this.m_lparam;       }
   void              DParam(const double dparam)         { this.m_dparam=dparam;       }
   double            DParam(void)                  const { return this.m_dparam;       }
   void              SParam(const string sparam)         { this.m_sparam=sparam;       }
   string            SParam(void)                  const { return this.m_sparam;       }
   
//--- Constructor
                     CEventBaseObj(const ushort event_id,const long lparam,const double dparam,const string sparam) : m_chart_id(::ChartID()) 
                       { 
                        this.m_event_id=event_id;
                        this.m_lparam=lparam;
                        this.m_dparam=dparam;
                        this.m_sparam=sparam;
                       }
//--- Comparison method to search for identical event objects
   virtual int       Compare(const CObject *node,const int mode=0) const 
                       {   
                        const CEventBaseObj *compared=node;
                        return
                          (
                           this.ID()>compared.ID()          ?  1  :
                           this.ID()<compared.ID()          ? -1  :
                           this.LParam()>compared.LParam()  ?  1  :
                           this.LParam()<compared.LParam()  ? -1  :
                           this.DParam()>compared.DParam()  ?  1  :
                           this.DParam()<compared.DParam()  ? -1  :
                           this.SParam()>compared.SParam()  ?  1  :
                           this.SParam()<compared.SParam()  ? -1  :  0
                          );
                       } 
  };
//+------------------------------------------------------------------+
//| Library object's base event class                                |
//+------------------------------------------------------------------+
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