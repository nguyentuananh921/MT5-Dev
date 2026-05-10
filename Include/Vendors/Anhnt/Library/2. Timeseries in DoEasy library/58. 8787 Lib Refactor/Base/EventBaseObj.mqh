//+------------------------------------------------------------------+
//|                                                 EventBaseObj.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Timeseries in DoEasy library                                     |
//| Lib link            https://www.mql5.com/en/articles/8787        |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Base object event class for all library objects                  |
//+------------------------------------------------------------------+
#ifndef __EVENTBASEOBJ_MQH__
#define __EVENTBASEOBJ_MQH__
#include <Arrays\ArrayObj.mqh>
#include "..\Services\DELib.mqh"
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
#endif // __EVENTBASEOBJ_MQH__
