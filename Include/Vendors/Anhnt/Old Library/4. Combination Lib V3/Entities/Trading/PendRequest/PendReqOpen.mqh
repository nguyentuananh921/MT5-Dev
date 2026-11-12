//+------------------------------------------------------------------+
//|                                                  PendReqOpen.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __PENDREQOPEN_MQH__
#define __PENDREQOPEN_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\PendRequest.mqh"
 #ifndef CPENDREQOPEN_MQH_DECLARATION
 #define CPENDREQOPEN_MQH_DECLARATION
   //+------------------------------------------------------------------+
   //| Pending request for opening a position                           |
   //+------------------------------------------------------------------+
   class CPendReqOpen : public CPendRequest
    {
     public:
        //--- Constructor
                     CPendReqOpen(const uchar id,
                                  const double price,
                                  const ulong time,
                                  const MqlTradeRequest &request,
                                  const int retcode) : CPendRequest(PEND_REQ_STATUS_OPEN,id,price,time,request,retcode)
                                    { this.m_type=OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_OPEN; }
                                  
        //--- Supported deal properties (1) real, (2) integer
          virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property);
          virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property);
          virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_STRING property);
        //--- Display a brief message with request data and (2) a short request name in the journal
          virtual void      PrintShort(const bool dash=false,const bool symbol=false);
          virtual string    Header(void);
    };
  #endif // CPENDREQOPEN_MQH_DECLARATION
 #ifndef CPENDREQOPEN_MQH_IMPLEMENTATION
 #define CPENDREQOPEN_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Return 'true' if an order supports a passed                      |
   //| integer property, otherwise return 'false'                       |
   //+------------------------------------------------------------------+
   bool CPendReqOpen::SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property)
    {
      if(
       (this.GetProperty(PEND_REQ_PROP_TYPE)==PEND_REQ_TYPE_REQUEST   &&
       (property==PEND_REQ_PROP_RETCODE                              ||
        property==PEND_REQ_PROP_TIME_ACTIVATE                        ||
        property==PEND_REQ_PROP_WAITING                              ||
        property==PEND_REQ_PROP_CURRENT_ATTEMPT
       )
       )                                                              ||
        property==PEND_REQ_PROP_MQL_REQ_ORDER                          ||
        property==PEND_REQ_PROP_MQL_REQ_POSITION                       ||
        property==PEND_REQ_PROP_MQL_REQ_POSITION_BY                    ||
        property==PEND_REQ_PROP_MQL_REQ_EXPIRATION                     ||
        property==PEND_REQ_PROP_MQL_REQ_TYPE_TIME
      ) return false;
      return true;
    }
   //+------------------------------------------------------------------+
   //| Return 'true' if an order supports a passed                      |
   //| real property, otherwise return 'false'                          |
   //+------------------------------------------------------------------+
   bool CPendReqOpen::SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property)
    {
     return(property==PEND_REQ_PROP_MQL_REQ_STOPLIMIT || property==PEND_REQ_PROP_ACTUAL_STOPLIMIT ? false : true);
    }
   //+------------------------------------------------------------------+
   //| Return 'true' if an order supports a passed                      |
   //| string property, otherwise return 'false'                        |
   //+------------------------------------------------------------------+
   bool CPendReqOpen::SupportProperty(ENUM_PEND_REQ_PROP_STRING property)
    {
     return true;
    }
   //+------------------------------------------------------------------+
   //| Display a brief message with request data in the journal         |
   //+------------------------------------------------------------------+
   void CPendReqOpen::PrintShort(const bool dash=false,const bool symbol=false)
    {
     string params=this.GetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME),this.m_digits_lot)+" "+
                   OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE));
     string price=CMessage::Text(MSG_LIB_TEXT_REQUEST_PRICE)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_PRICE),this.m_digits);
     string sl=this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL)>0 ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_SL)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL),this.m_digits) : "";
     string tp=this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP)>0 ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_TP)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP),this.m_digits) : "";
     string time=this.IDDescription()+", "+CMessage::Text(MSG_LIB_TEXT_CREATED)+" "+TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE));
     string attempts=CMessage::Text(MSG_LIB_TEXT_ATTEMPTS)+" "+(string)this.GetProperty(PEND_REQ_PROP_TOTAL);
     string wait=CMessage::Text(MSG_LIB_TEXT_WAIT)+" "+::TimeToString(this.GetProperty(PEND_REQ_PROP_WAITING)/1000,TIME_SECONDS);
     string end=CMessage::Text(MSG_LIB_TEXT_END)+" "+
                   TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE)+this.GetProperty(PEND_REQ_PROP_WAITING)*this.GetProperty(PEND_REQ_PROP_TOTAL));
     //---
      string message=CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_OPEN)+": "+
      "\n- "+params+", "+price+sl+tp+
      "\n- "+time+", "+attempts+", "+wait+", "+end;
      ::Print(message);
      this.PrintActivations();
    }
   //+------------------------------------------------------------------+
   //| Return the short request name                                    |
   //+------------------------------------------------------------------+
   string CPendReqOpen::Header(void)
    {
     string type=PositionTypeDescription((ENUM_POSITION_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE));
     return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_OPEN)+" "+type+", ID #"+(string)this.GetProperty(PEND_REQ_PROP_ID);
    } 
 #endif // CPENDREQOPEN_MQH_IMPLEMENTATION
#endif // __PENDREQOPEN_MQH__