//+------------------------------------------------------------------+
//|                                                 EventBaseObj.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//|--- Pure data. Mirrors: CEventBaseObj in BaseObj.mqh              |
//+------------------------------------------------------------------+
#ifndef __CEVENTBASEOBJ_MQH__
#define __CEVENTBASEOBJ_MQH__
#include <Object.mqh>


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
   void              Time(const long time)      { m_time=time;       }
   long              Time(void)       const     { return m_time;     }
   void              ChartID(const long id)     { m_chart_id=id;     }
   long              ChartID(void)    const     { return m_chart_id; }
   void              ID(const ushort id)        { m_event_id=id;     }
   ushort            ID(void)         const     { return m_event_id; }
   void              LParam(const long v)       { m_lparam=v;        }
   long              LParam(void)     const     { return m_lparam;   }
   void              DParam(const double v)     { m_dparam=v;        }
   double            DParam(void)     const     { return m_dparam;   }
   void              SParam(const string v)     { m_sparam=v;        }
   string            SParam(void)     const     { return m_sparam;   }
   
                     CEventBaseObj(const ushort event_id,
                                   const long   lparam,
                                   const double dparam,
                                   const string sparam)
                                   : m_chart_id(::ChartID())
                       {
                        m_event_id=event_id;
                        m_lparam  =lparam;
                        m_dparam  =dparam;
                        m_sparam  =sparam;
                       }

   virtual int       Compare(const CObject *node,const int mode=0) const
                       {
                        const CEventBaseObj *c=node;
                        return(ID()>c.ID()         ?  1 : ID()<c.ID()         ? -1 :
                               LParam()>c.LParam() ?  1 : LParam()<c.LParam() ? -1 :
                               DParam()>c.DParam() ?  1 : DParam()<c.DParam() ? -1 :
                               SParam()>c.SParam() ?  1 : SParam()<c.SParam() ? -1 : 0);
                       }
  };
#endif