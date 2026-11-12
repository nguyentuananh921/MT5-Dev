//+------------------------------------------------------------------+
//|                                             TradeEventModify.mqh |
//|                                 Modify name from EventModify.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/6211                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"


#ifndef CTRADEEVENTMODIFY_MQH
#define CTRADEEVENTMODIFY_MQH
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "..\TradeEvent.mqh"
 #ifndef CTRADEEVENTMODIFY_MQH_DECLARATION
 #define CTRADEEVENTMODIFY_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Pending order or position modification event                     |
  //+------------------------------------------------------------------+
  class CTradeEventModify : public CTradeEvent
   {
    private:
      double            m_price;                               // Price sent to an event
      //--- Create and return a short event message
      string            EventsMessage(void);
    public:
      //--- Constructor
         CTradeEventModify(const int event_code,const ulong ticket=0) : CTradeEvent(EVENT_STATUS_MODIFY,event_code,ticket),m_price(0)
         { this.m_type=OBJECT_DE_TYPE_EVENT_MODIFY; }
      //--- Supported order properties (1) real, (2) integer
      virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
      virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
      //--- (1) Display a brief message about the event in the journal, (2) Send the event to the chart
      virtual void      PrintShort(void);
      virtual void      SendEvent(void);
   };
 #endif // CTRADEEVENTMODIFY_MQH_DECLARATION
 #ifndef CTRADEEVENTMODIFY_MQH_IMPLEMENTATION
 #define CTRADEEVENTMODIFY_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if the event supports the passed                   |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CTradeEventModify::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
   {
      if(property==EVENT_PROP_TYPE_DEAL_EVENT         ||
         property==EVENT_PROP_TICKET_DEAL_EVENT       ||
         property==EVENT_PROP_TYPE_ORDER_POSITION     ||
         property==EVENT_PROP_TICKET_ORDER_POSITION   ||
         property==EVENT_PROP_POSITION_ID             ||
         property==EVENT_PROP_POSITION_BY_ID          ||
         property==EVENT_PROP_TIME_ORDER_POSITION
        ) return false;
      return true;
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if the event supports the passed                   |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CTradeEventModify::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
   {
      if(property==EVENT_PROP_PRICE_CLOSE             ||
         property==EVENT_PROP_PROFIT
      ) return false;
      return true;
   }
  //+------------------------------------------------------------------+
  //| Display a brief message about the event in the journal           |
  //+------------------------------------------------------------------+
  void CTradeEventModify::PrintShort(void)
   {
      ::Print(this.EventsMessage());
   }
  //+------------------------------------------------------------------+
  //| Send the event to the chart                                      |
  //+------------------------------------------------------------------+
  void CTradeEventModify::SendEvent(void)
   {
      this.PrintShort();
      ::EventChartCustom(this.m_chart_id_main,(ushort)this.m_trade_event,this.TicketOrderEvent(),this.m_price,this.Symbol());
   }
  //+------------------------------------------------------------------+
  //| Create and return a short event message                          |
  //+------------------------------------------------------------------+
  string CTradeEventModify::EventsMessage(void)
   {
     //--- (1) header, (2) magic number
      string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
      string magic_id=((this.GetPendReqID()>0 || this.GetGroupID1()>0 || this.GetGroupID2()>0) ? " ("+(string)this.GetMagicID()+")" : "");
      string group_id1=(this.GetGroupID1()>0 ? ", G1: "+(string)this.GetGroupID1() : "");
      string group_id2=(this.GetGroupID2()>0 ? ", G2: "+(string)this.GetGroupID2() : "");
      string pend_req_id=(this.GetPendReqID()>0 ? ", ID: "+(string)this.GetPendReqID() : "");
      string magic=(this.Magic()!=0 ? ", "+CMessage::Text(MSG_ORD_MAGIC)+" "+(string)this.Magic()+magic_id+group_id1+group_id2+pend_req_id : "");
      string text="";

     //--- Pending order price is modified
      if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE)
         {
            string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
            string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE)+": "+price+magic;
            this.m_price=this.PriceOpen();
         }
     //--- Pending order price and StopLoss are modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE_SL)
         {
            string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
            string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
            string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE)+": "+price+" "+CMessage::Text(MSG_LIB_TEXT_AND)+" StopLoss: "+sl+magic;
            this.m_price=this.PriceOpen();
         }
     //--- Pending order price and TakeProfit are modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE_TP)
         {
            string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
            string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
            string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE)+": "+price+" "+CMessage::Text(MSG_LIB_TEXT_AND)+" TakeProfit: "+tp+magic;
            this.m_price=this.PriceOpen();
         }
     //--- Pending order price, as well as its StopLoss and TakeProfit are modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE_SL_TP)
         {
            string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
            string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
            string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
            string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE)+": "+price+", StopLoss: "+sl+" "+CMessage::Text(MSG_LIB_TEXT_AND)+" TakeProfit: "+tp+magic;
            this.m_price=this.PriceOpen();
         }
     //--- Pending order StopLoss is modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_SL)
         {
            string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
            string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_ORDER_SL)+": "+sl+magic;
            this.m_price=this.PriceStopLoss();
         }
     //--- Pending order TakeProfit is modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_TP)
         {
            string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
            string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_ORDER_TP)+": "+tp+magic;
            this.m_price=this.PriceTakeProfit();
         }
     //--- Pending order StopLoss and TakeProfit are modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_SL_TP)
         {
            string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
            string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
            string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_ORDER_SL)+": "+sl+" "+CMessage::Text(MSG_LIB_TEXT_AND)+" TakeProfit: "+tp+magic;
            this.m_price=this.PriceOpen();
         }
     //--- Position StopLoss is modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_POSITION_SL)
         {
            string order=PositionTypeDescription(this.TypePositionCurrent())+" #"+(string)this.TicketPositionCurrent();
            string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_POSITION_SL)+": "+sl+magic;
            this.m_price=this.PriceStopLoss();
         }
     //--- Position TakeProfit is modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_POSITION_TP)
         {
            string order=PositionTypeDescription(this.TypePositionCurrent())+" #"+(string)this.TicketPositionCurrent();
            string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_POSITION_TP)+": "+tp+magic;
            this.m_price=this.PriceTakeProfit();
         }
     //--- Position StopLoss and TakeProfit are modified
      else if(this.TypeEvent()==TRADE_EVENT_MODIFY_POSITION_SL_TP)
         {
            string order=PositionTypeDescription(this.TypePositionCurrent())+" #"+(string)this.TicketPositionCurrent();
            string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
            string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
            text=order+": "+CMessage::Text(MSG_EVN_MODIFY_POSITION_SL)+": "+sl+" "+CMessage::Text(MSG_LIB_TEXT_AND)+" TakeProfit: "+tp+magic;
            this.m_price=this.PriceOpen();
         }
     return head+this.Symbol()+" "+text;
   }
  //+------------------------------------------------------------------+
 #endif // CTRADEEVENTMODIFY_MQH_IMPLEMENTATION
#endif // CTRADEEVENTMODIFY_MQH

