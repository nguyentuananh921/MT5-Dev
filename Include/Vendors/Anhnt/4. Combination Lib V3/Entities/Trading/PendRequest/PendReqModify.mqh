//+------------------------------------------------------------------+
//|                                                PendReqModify.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __PENDREQMODIFY_MQH__
#define __PENDREQMODIFY_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\PendRequest.mqh"
 #ifndef CPENDREQMODIFY_MQH_DECLARATION
 #define CPENDREQMODIFY_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Pending request to modify pending order parameters               |
  //+------------------------------------------------------------------+
  class CPendReqModify : public CPendRequest
   {
    public:
     //--- Constructor
                     CPendReqModify(const uchar id,
                                    const double price,
                                    const ulong time,
                                    const MqlTradeRequest &request,
                                    const int retcode) : CPendRequest(PEND_REQ_STATUS_MODIFY,id,price,time,request,retcode)
                                      { this.m_type=OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_MODIFY; }
                                  
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
 #endif // CPENDREQMODIFY_MQH_DECLARATION
 #ifndef CPENDREQMODIFY_MQH_IMPLEMENTATION
 #define CPENDREQMODIFY_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CPendReqModify::SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property)
   {
    if(
      (this.GetProperty(PEND_REQ_PROP_TYPE)==PEND_REQ_TYPE_REQUEST   &&
       (property==PEND_REQ_PROP_RETCODE                              ||
        property==PEND_REQ_PROP_TIME_ACTIVATE                        ||
        property==PEND_REQ_PROP_WAITING                              ||
        property==PEND_REQ_PROP_CURRENT_ATTEMPT
       )
      )                                                              ||
      property==PEND_REQ_PROP_MQL_REQ_POSITION                       ||
      property==PEND_REQ_PROP_MQL_REQ_POSITION_BY                    ||
      property==PEND_REQ_PROP_MQL_REQ_DEVIATION
     ) return false;
     return true;
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CPendReqModify::SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property)
   {
    return(property==PEND_REQ_PROP_MQL_REQ_VOLUME ? false : true);
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| string property, otherwise return 'false'                        |
  //+------------------------------------------------------------------+
  bool CPendReqModify::SupportProperty(ENUM_PEND_REQ_PROP_STRING property)
   {
    return true;
   }
  //+------------------------------------------------------------------------+
  //| Return the flag indicating the pending request has completed its work  |
  //+------------------------------------------------------------------------+
  bool CPendReqModify::IsCompleted(void) const
   {
    bool res=true;
    res &= this.IsCompletedPrice();
    res &= this.IsCompletedStopLimit();
    res &= this.IsCompletedStopLoss();
    res &= this.IsCompletedTakeProfit();
    res &= this.IsCompletedTypeFilling();
    res &= this.IsCompletedTypeTime();
    res &= this.IsCompletedExpiration();
    return res;
   }
  //+------------------------------------------------------------------+
  //| Display a brief message with request data in the journal         |
  //+------------------------------------------------------------------+
  void CPendReqModify::PrintShort(const bool dash=false,const bool symbol=false)
   {
      string params=this.GetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME),this.m_digits_lot)+" "+
                    OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE))+" #"+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_ORDER);
      string price=CMessage::Text(MSG_LIB_TEXT_REQUEST_PRICE)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_PRICE),this.m_digits);
      string stoplimit=this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT)!=this.GetProperty(PEND_REQ_PROP_ACTUAL_STOPLIMIT) ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_STOPLIMIT)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT),this.m_digits) : "";
      string sl=this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL)!=this.GetProperty(PEND_REQ_PROP_ACTUAL_SL) ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_SL)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL),this.m_digits) : "";
      string tp=this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP)!=this.GetProperty(PEND_REQ_PROP_ACTUAL_TP) ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_TP)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP),this.m_digits) : "";
      string expiration=this.GetProperty(PEND_REQ_PROP_MQL_REQ_EXPIRATION)!=this.GetProperty(PEND_REQ_PROP_ACTUAL_EXPIRATION) ? this.MqlReqExpirationDescription() : "";
      string type_filling=this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_FILLING)!=this.GetProperty(PEND_REQ_PROP_ACTUAL_TYPE_FILLING) ? "\n- "+this.MqlReqTypeFillingDescription() : "";
      string type_time=this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_TIME)!=this.GetProperty(PEND_REQ_PROP_ACTUAL_TYPE_TIME) ? "\n- "+this.MqlReqTypeTimeDescription() : "";
      string time=this.IDDescription()+", "+CMessage::Text(MSG_LIB_TEXT_CREATED)+" "+TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE));
      string attempts=CMessage::Text(MSG_LIB_TEXT_ATTEMPTS)+" "+(string)this.GetProperty(PEND_REQ_PROP_TOTAL);
      string wait=CMessage::Text(MSG_LIB_TEXT_WAIT)+" "+::TimeToString(this.GetProperty(PEND_REQ_PROP_WAITING)/1000,TIME_SECONDS);
      string end=CMessage::Text(MSG_LIB_TEXT_END)+" "+TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE)+this.GetProperty(PEND_REQ_PROP_WAITING)*this.GetProperty(PEND_REQ_PROP_TOTAL));
      //---
      string message=CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_MODIFY)+": "+
                     "\n- "+params+", "+price+stoplimit+sl+tp+expiration+type_filling+type_time+
                     "\n- "+time+", "+attempts+", "+wait+", "+end;
      ::Print(message);
       this.PrintActivations();
   }
  //+------------------------------------------------------------------+
  //| Return the short request name                                    |
  //+------------------------------------------------------------------+
  string CPendReqModify::Header(void)
   {
     string type=OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE),true,false,false);
     return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_MODIFY)+type+", #"+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_ORDER)+" ID #"+(string)this.GetProperty(PEND_REQ_PROP_ID);
   }
  //+------------------------------------------------------------------+
 #endif // CPENDREQMODIFY_MQH_IMPLEMENTATION
#endif // __PENDREQMODIFY_MQH__