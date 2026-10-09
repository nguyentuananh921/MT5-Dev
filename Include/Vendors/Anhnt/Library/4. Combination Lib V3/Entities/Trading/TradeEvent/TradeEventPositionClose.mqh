
//+------------------------------------------------------------------+
//|                                      TradeEventPositionClose.mqh |
//|                          Modify name from EventPositionClose.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/6211                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"

#ifndef CTRADEEVENTPOSITIONCLOSE_MQH
#define CTRADEEVENTPOSITIONCLOSE_MQH
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\TradeEvent.mqh"
 #ifndef CTRADEEVENTPOSITIONCLOSE_MQH_DECLARATION
 #define CTRADEEVENTPOSITIONCLOSE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Position closure event                                           |
  //+------------------------------------------------------------------+
  class CTradeEventPositionClose : public CTradeEvent
   {
    private:
     //--- Create and return a short event message
      string            EventsMessage(void);  
    public:
     //--- Constructor
                     CTradeEventPositionClose(const int event_code,const ulong ticket=0) : CTradeEvent(EVENT_STATUS_HISTORY_POSITION,event_code,ticket)
                       { this.m_type=OBJECT_DE_TYPE_EVENT_POSITION_CLOSE; }
     //--- Supported order properties (1) real, (2) integer
      virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
      virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
     //--- (1) Display a brief message about the event in the journal, (2) Send the event to the chart
      virtual void      PrintShort(void);
      virtual void      SendEvent(void);
   };
 #endif // CTRADEEVENTPOSITIONCLOSE_MQH_DECLARATION
 #ifndef CTRADEEVENTPOSITIONCLOSE_MQH_IMPLEMENTATION
 #define CTRADEEVENTPOSITIONCLOSE_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if the event supports the passed                   |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CTradeEventPositionClose::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
   {
    return true;
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if the event supports the passed                   |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CTradeEventPositionClose::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
   {
    return true;
   }
  //+------------------------------------------------------------------+
  //| Display a brief message about the event in the journal           |
  //+------------------------------------------------------------------+
  void CTradeEventPositionClose::PrintShort(void)
   {
    ::Print(this.EventsMessage());
   }
  //+------------------------------------------------------------------+
  //| Send the event to the chart                                      |
  //+------------------------------------------------------------------+
  void CTradeEventPositionClose::SendEvent(void)
   {
    this.PrintShort();
    ::EventChartCustom(this.m_chart_id_main,(ushort)this.m_trade_event,this.PositionID(),this.PriceClose(),this.Symbol());
   }
  //+------------------------------------------------------------------+
  //| Create and return a short event message                          |
  //+------------------------------------------------------------------+
  string CTradeEventPositionClose::EventsMessage(void)
   {
    //--- (1) header, (2) executed order volume, (3) executed position volume, (4) event price,
    //--- (5) StopLoss price, (6) TakeProfit price, (7) magic number, (6) profit in account currency, (7,8) closure message variants
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
     string close=CMessage::Text(MSG_LIB_TEXT_CLOSED)+" ";
     string in_pos="";
     //
      if(this.GetProperty(EVENT_PROP_TYPE_EVENT)>TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL)
       {
        close=CMessage::Text(MSG_LIB_TEXT_CLOSED_VOL)+" "+vol_ord;
        in_pos=" "+CMessage::Text(MSG_LIB_TEXT_IN)+" ";
       }
      string opposite=
       (
        this.IsPresentEventFlag(TRADE_EVENT_FLAG_BY_POS)   ? 
        " "+CMessage::Text(MSG_LIB_TEXT_CLOSED_BY)+" "+this.SymbolCloseBy()+" "+
        this.TypeOrderDealDescription()+" #"+(string)this.PositionByID()+(this.MagicCloseBy()> 0 ? "("+(string)this.MagicCloseBy()+")" : "")
                                                         : ""
       );
     //--- EURUSD: Closed 0.1 Sell #xx [0.2 SellLimit order #XX] at х.ххххх, sl х.ххххх, tp x.xxxxx, magic, profit xxxx
     string text=
       (
        this.Symbol()+" "+close+in_pos+this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
        opposite+ #ifdef __MQL5__ " ["+vol_ord+" "+ this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]" #else "" #endif +price+sl+tp+magic+profit
       );
     return head+text;
  }
 #endif // CTRADEEVENTPOSITIONCLOSE_MQH_IMPLEMENTATION
#endif // CTRADEEVENTPOSITIONCLOSE_MQH

