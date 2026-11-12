//+------------------------------------------------------------------+
//|                                                 PendReqClose.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __PENDREQCLOSE_MQH__
#define __PENDREQCLOSE_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\PendRequest.mqh"
 #ifndef CPENDREQCLOSE_MQH_DECLARATION
 #define CPENDREQCLOSE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Pending request to close a position                              |
  //+------------------------------------------------------------------+
  class CPendReqClose : public CPendRequest
   {
    public:
     //--- Constructor
                     CPendReqClose(const uchar id,
                                   const double price,
                                   const ulong time,
                                   const MqlTradeRequest &request,
                                   const int retcode) : CPendRequest(PEND_REQ_STATUS_CLOSE,id,price,time,request,retcode)
                                   { this.m_type=OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_CLOSE; }
                                  
     //--- Supported deal properties (1) real, (2) integer
      virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property);
      virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property);
      virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_STRING property);
     //--- Return the flag indicating the pending request has completed its work
      virtual bool      IsCompleted(void) const;
     //--- Display a brief message with request data and (2) a short request name in the journal
      virtual void      PrintShort(const bool dash=false,const bool symbol=false);
      virtual string    Header(void);
   };
 #endif // CPENDREQCLOSE_MQH_DECLARATION
 #ifndef CPENDREQCLOSE_MQH_IMPLEMENTATION
 #define CPENDREQCLOSE_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CPendReqClose::SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property)
   {
    if(
      (this.GetProperty(PEND_REQ_PROP_TYPE)==PEND_REQ_TYPE_REQUEST   &&
       (property==PEND_REQ_PROP_RETCODE                              ||
        property==PEND_REQ_PROP_TIME_ACTIVATE                        ||
        property==PEND_REQ_PROP_WAITING                              ||
        property==PEND_REQ_PROP_CURRENT_ATTEMPT
       )
      )                                                              ||
      (
       property==PEND_REQ_PROP_MQL_REQ_POSITION_BY                   && 
       this.GetProperty(property)==0
      )                                                              ||
      property==PEND_REQ_PROP_MQL_REQ_ORDER                          ||
      property==PEND_REQ_PROP_MQL_REQ_EXPIRATION                     ||
      property==PEND_REQ_PROP_MQL_REQ_TYPE_TIME
     ) return false;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CPendReqClose::SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property)
   {
    if(property==PEND_REQ_PROP_MQL_REQ_STOPLIMIT ||
       property==PEND_REQ_PROP_ACTUAL_STOPLIMIT  || 
       property==PEND_REQ_PROP_MQL_REQ_SL        ||
       property==PEND_REQ_PROP_MQL_REQ_TP
      ) return false;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| string property, otherwise return 'false'                        |
  //+------------------------------------------------------------------+
  bool CPendReqClose::SupportProperty(ENUM_PEND_REQ_PROP_STRING property)
   {
    return true;
   }
  //+-----------------------------------------------------------------------+
  //| Return the flag indicating the pending request has completed its work |
  //+-----------------------------------------------------------------------+
  bool CPendReqClose::IsCompleted(void) const
   {
    return this.IsCompletedVolume();
   }
  //+------------------------------------------------------------------+
  //| Display a brief message with request data in the journal         |
  //+------------------------------------------------------------------+
  void CPendReqClose::PrintShort(const bool dash=false,const bool symbol=false)
   {
    string params=this.GetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME),this.m_digits_lot)+" "+
                 PositionTypeDescription((ENUM_POSITION_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE))+" #"+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION);
    string pos_by=(this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION_BY)>0 ? ", "+CMessage::Text(MSG_ORD_DEAL_OUT_BY)+" #"+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION_BY) : "");
    string price=CMessage::Text(MSG_LIB_TEXT_REQUEST_PRICE)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_PRICE_CREATE),this.m_digits);
    string time=this.IDDescription()+", "+CMessage::Text(MSG_LIB_TEXT_CREATED)+" "+TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE));
    string attempts=CMessage::Text(MSG_LIB_TEXT_ATTEMPTS)+" "+(string)this.GetProperty(PEND_REQ_PROP_TOTAL);
    string wait=CMessage::Text(MSG_LIB_TEXT_WAIT)+" "+::TimeToString(this.GetProperty(PEND_REQ_PROP_WAITING)/1000,TIME_SECONDS);
    string end=CMessage::Text(MSG_LIB_TEXT_END)+" "+
              TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE)+this.GetProperty(PEND_REQ_PROP_WAITING)*this.GetProperty(PEND_REQ_PROP_TOTAL));
    //---
    string message=CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_CLOSE)+": "+
    "\n- "+params+", "+price+pos_by+
    "\n- "+time+", "+attempts+", "+wait+", "+end;
    ::Print(message);
    this.PrintActivations();
   }
  //+------------------------------------------------------------------+
  //| Return the short request name                                    |
  //+------------------------------------------------------------------+
  string CPendReqClose::Header(void)
   {
    string type=PositionTypeDescription((ENUM_POSITION_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE));
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_CLOSE)+" "+type+" #"+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION)+", ID #"+(string)this.GetProperty(PEND_REQ_PROP_ID);
   }
 #endif // CPENDREQCLOSE_MQH_IMPLEMENTATION
#endif // __PENDREQCLOSE_MQH__