//+------------------------------------------------------------------+
//+                                        TradeEventBalanceOperation|
//|                       Modify name from EventBalanceOperation.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/6211                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"

#ifndef CCTRADEEVENTBALANCEOPERATION_MQH
#define CCTRADEEVENTBALANCEOPERATION_MQH
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "..\TradeEvent.mqh"
 #ifndef CCTRADEEVENTBALANCEOPERATION_MQH_DECLARATION
 #define CCTRADEEVENTBALANCEOPERATION_MQH_DECLARATION
 //+------------------------------------------------------------------+
   //| Balance operation event                                          |
   //+------------------------------------------------------------------+
   class CTradeEventBalanceOperation : public CTradeEvent
    {
      public:
       //--- Constructor
                        CTradeEventBalanceOperation(const int event_code,const ulong ticket=0) : CTradeEvent(EVENT_STATUS_BALANCE,event_code,ticket)
                       { this.m_type=OBJECT_DE_TYPE_EVENT_BALANCE; }
       //--- Supported order properties (1) real, (2) integer
        virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
        virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
        virtual bool      SupportProperty(ENUM_EVENT_PROP_STRING property);
       //--- (1) Display a brief message about the event in the journal, (2) Send the event to the chart
        virtual void      PrintShort(void);
        virtual void      SendEvent(void);
    };
 #endif // CCTRADEEVENTBALANCEOPERATION_MQH_DECLARATION
 #ifndef CCTRADEEVENTBALANCEOPERATION_MQH_IMPLEMENTATION
 #define CCTRADEEVENTBALANCEOPERATION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
   //| Return 'true' if the event supports the passed                   |
   //| integer property, otherwise return 'false'                       |
   //+------------------------------------------------------------------+
   bool CTradeEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
     {
      if(property==EVENT_PROP_TYPE_ORDER_EVENT        ||
         property==EVENT_PROP_TYPE_ORDER_POSITION     ||
         property==EVENT_PROP_TICKET_ORDER_EVENT      ||
         property==EVENT_PROP_TICKET_ORDER_POSITION   ||
         property==EVENT_PROP_POSITION_ID             ||
         property==EVENT_PROP_POSITION_BY_ID          ||
         property==EVENT_PROP_POSITION_ID             ||
         property==EVENT_PROP_MAGIC_ORDER             ||
         property==EVENT_PROP_TIME_ORDER_POSITION
        ) return false;
      return true;
     }
   //+------------------------------------------------------------------+
   //| Return 'true' if the event supports the passed                   |
   //| real property, otherwise return 'false'                          |
   //+------------------------------------------------------------------+
   bool CTradeEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
     {
      return(property==EVENT_PROP_PROFIT ? true : false);
     }
   //+------------------------------------------------------------------+
   //| Return 'true' if the event supports the passed                   |
   //| string property, otherwise return 'false'                        |
   //+------------------------------------------------------------------+
   bool CTradeEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_STRING property)
     {
      return false;
     }
   //+------------------------------------------------------------------+
   //| Display a brief message about the event in the journal           |
   //+------------------------------------------------------------------+
   void CTradeEventBalanceOperation::PrintShort(void)
     {
      string head="- "+this.StatusDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
      ::Print(head+this.TypeEventDescription()+": "+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY));
     }
   //+------------------------------------------------------------------+
   //| Send the event to the chart                                      |
   //+------------------------------------------------------------------+
   void CTradeEventBalanceOperation::SendEvent(void)
     {
      this.PrintShort();
      ::EventChartCustom(this.m_chart_id_main,(ushort)this.m_trade_event,this.TypeEvent(),this.Profit(),::AccountInfoString(ACCOUNT_CURRENCY));
     }
 #endif // CCTRADEEVENTBALANCEOPERATION_MQH_IMPLEMENTATION
#endif // CCTRADEEVENTBALANCEOPERATION_MQH