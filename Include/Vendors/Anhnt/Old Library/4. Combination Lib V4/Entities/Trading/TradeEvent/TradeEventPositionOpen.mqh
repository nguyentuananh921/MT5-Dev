
//+------------------------------------------------------------------+
//|                                       TradeEventPositionOpen.mqh |
//|                           Modify name from EventPositionOpen.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/6211                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Traing Trade Event Position opening                              |
//+------------------------------------------------------------------+
#ifndef CTRADEEVENTPOSITIONOPEN_MQH
#define CTRADEEVENTPOSITIONOPEN_MQH
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\TradeEvent.mqh"
 #ifndef CTRADEEVENTPOSITIONOPEN_MQH_DECLARATION
 #define CTRADEEVENTPOSITIONOPEN_MQH_DECLARATION
 class CTradeEventPositionOpen : public CTradeEvent
  {
   private:
    //--- Create and return a short event message
    string            EventsMessage(void);  
   public:
    //--- Constructor
    CTradeEventPositionOpen(const int event_code,const ulong ticket=0) : CTradeEvent(EVENT_STATUS_MARKET_POSITION,event_code,ticket)
    { this.m_type=OBJECT_DE_TYPE_EVENT_POSITION_OPEN; }
    //--- Supported order properties (1) real, (2) integer
     virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
     virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
    //--- (1) Display a brief message about the event in the journal, (2) Send the event to the chart
     virtual void      PrintShort(void);
     virtual void      SendEvent(void);
  };
 #endif // CTRADEEVENTPOSITIONOPEN_MQH_DECLARATION
 #ifndef CTRADEEVENTPOSITIONOPEN_MQH_IMPLEMENTATION
 #define CTRADEEVENTPOSITIONOPEN_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if the event supports the passed                   |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CTradeEventPositionOpen::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
   {
    return(property==EVENT_PROP_POSITION_BY_ID ? false : true);
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if the event supports the passed                   |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CTradeEventPositionOpen::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
   {
    if(property==EVENT_PROP_PRICE_CLOSE ||
       property==EVENT_PROP_PROFIT
     ) return false;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Display a brief message about the event in the journal           |
  //+------------------------------------------------------------------+
  void CTradeEventPositionOpen::PrintShort(void)
   {
    ::Print(this.EventsMessage());
   }
  //+------------------------------------------------------------------+
  //| Send the event to the chart                                      |
  //+------------------------------------------------------------------+
  void CTradeEventPositionOpen::SendEvent(void)
   {
    this.PrintShort();
    ::EventChartCustom(this.m_chart_id_main,(ushort)this.m_trade_event,this.PositionID(),this.PriceOpen(),this.Symbol());
   }
  //+------------------------------------------------------------------+
  //| Create and return a short event message                          |
  //+------------------------------------------------------------------+
  string CTradeEventPositionOpen::EventsMessage(void)
   {
   //--- (1) header, (2) executed order volume, (3) executed position volume, (4) event price,
   //--- (5) StopLoss price, (6) TakeProfit price, (7) magic number, (6) profit in account currency
    string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
    string vol_ord=::DoubleToString(this.VolumeOrderExecuted(),DigitsLots(this.Symbol()));
    string vol_pos=::DoubleToString(this.VolumePositionExecuted(),DigitsLots(this.Symbol()));
    string price=" "+CMessage::Text(MSG_LIB_TEXT_AT_PRICE)+" "+::DoubleToString(this.PriceEvent(),this.m_digits);
    string sl=(this.PriceStopLoss()>0 ? ", sl "+ ::DoubleToString(this.PriceStopLoss(),this.m_digits) : "");
    string tp=(this.PriceTakeProfit()>0 ? ", tp "+ ::DoubleToString(this.PriceTakeProfit(),this.m_digits) : "");
    string magic_id=((this.GetPendReqID()>0 || this.GetGroupID1()>0 || this.GetGroupID2()>0) ? " ("+(string)this.GetMagicID()+")" : "");
    string group_id1=(this.GetGroupID1()>0 ? ", G1: "+(string)this.GetGroupID1() : "");
    string group_id2=(this.GetGroupID2()>0 ? ", G2: "+(string)this.GetGroupID2() : "");
    string pend_req_id=(this.GetPendReqID()>0 ? ", ID: "+(string)this.GetPendReqID() : "");
    string magic=(this.Magic()!=0 ? ", "+CMessage::Text(MSG_ORD_MAGIC)+" "+(string)this.Magic()+magic_id+group_id1+group_id2+pend_req_id : "");
    string profit=", "+CMessage::Text(MSG_LIB_PROP_PROFIT)+" "+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   //---
    string text="";
   //--- Position reversal
    if(this.GetProperty(EVENT_PROP_REASON_EVENT)<EVENT_REASON_ACTIVATED_PENDING)
     {
      //--- EURUSD: Buy #xx changed to 0.1 Sell #xx (0.2 SellLimit order #XX) at х.ххххх, sl х.ххххх, tp x.xxxxx, magic, profit xxxx
      text=
        (
         this.Symbol()+" "+
         this.TypePositionPreviousDescription()+" #"+(string)this.TicketPositionPrevious()+
         " "+CMessage::Text(MSG_LIB_TEXT_TURNED_TO)+" "+vol_pos+" "+this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
         " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic+profit
        );
     }
    else
     {
      //--- Add volume
      if(this.GetProperty(EVENT_PROP_TICKET_ORDER_EVENT)!=this.GetProperty(EVENT_PROP_POSITION_ID))
        {
         //--- EURUSD: Added 0.1 to Buy #xx (BuyLimit order #XX) at х.ххххх, magic
         text=
           (
            this.Symbol()+" "+
            CMessage::Text(MSG_LIB_TEXT_ADDED)+" "+vol_ord+" "+CMessage::Text(MSG_LIB_TEXT_TO)+" "+
            this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
            " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+magic
           );
        }
      //--- Open a position
      else
        {
         //--- EURUSD: Opened 0.1 Buy #xx (BuyLimit order #XX) at х.ххххх, sl х.ххххх, tp x.xxxxx, magic
         text=
           (
            this.Symbol()+" "+
            CMessage::Text(MSG_LIB_TEXT_OPENED)+" "+vol_pos+" "+
            this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
            " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic
           );
        }
     }
    return head+text;
   }
 #endif // CTRADEEVENTPOSITIONOPEN_MQH_IMPLEMENTATION
#endif // CTRADEEVENTPOSITIONOPEN_MQH