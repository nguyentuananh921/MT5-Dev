//+------------------------------------------------------------------+
//|                                                  CGBaseEvent.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Graphical object event class                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef CCGBASEEVENT_MQH
#define CCGBASEEVENT_MQH
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 //#include "..\..\Services\DELib.mqh"
 #include <Graphics\Graphic.mqh>
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 //#include "..\..\Services\DELib.mqh"
 #include <Graphics\Graphic.mqh>
#ifndef CCGBASEEVENT_MQH_DECLARATION
#define CCGBASEEVENT_MQH_DECLARATION
class CGBaseEvent : public CObject
  {
   private:
      ushort            m_id;
      long              m_lparam;
      double            m_dparam;
      string            m_sparam;
   public:
      void              ID(ushort id)                          { this.m_id=id;         }
      ushort            ID(void)                         const { return this.m_id;     }
      void              LParam(const long value)               { this.m_lparam=value;  }
      long              Lparam(void)                     const { return this.m_lparam; }
      void              DParam(const double value)             { this.m_dparam=value;  }
      double            Dparam(void)                     const { return this.m_dparam; }
      void              SParam(const string value)             { this.m_sparam=value;  }
      string            Sparam(void)                     const { return this.m_sparam; }
      bool              Send(const long chart_id)
                        {
                           ::ResetLastError();
                           return ::EventChartCustom(chart_id,m_id,m_lparam,m_dparam,m_sparam);
                        }
                     CGBaseEvent (const ushort event_id,const long lparam,const double dparam,const string sparam) : 
                           m_id(event_id),m_lparam(lparam),m_dparam(dparam),m_sparam(sparam){}
                     ~CGBaseEvent (void){}
  };
#endif // CCGBASEEVENT_MQH_DECLARATION
#ifndef CCGBASEEVENT_MQH_IMPLEMENTATION
#define CCGBASEEVENT_MQH_IMPLEMENTATION

#endif // CCGBASEEVENT_MQH_IMPLEMENTATION
#endif // CCGBASEEVENT_MQH