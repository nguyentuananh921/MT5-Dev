//+------------------------------------------------------------------+
//|                                                 PendReqPlace.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
 #ifndef __PENDREQPLACE_MQH__
 #define __PENDREQPLACE_MQH__
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "..\PendRequest.mqh"
  #ifndef CPENDREQPLACE_MQH_DECLARATION
 #define CPENDREQPLACE_MQH_DECLARATION
   //+------------------------------------------------------------------+
   //| Pending request to place a pending order                         |
   //+------------------------------------------------------------------+
   class CPendReqPlace : public CPendRequest
    {
     public:
      //--- Constructor
       CPendReqPlace(const uchar id,
                    const double price,
                    const ulong time,
                    const MqlTradeRequest &request,
                    const int retcode) : CPendRequest(PEND_REQ_STATUS_PLACE,id,price,time,request,retcode)
                                     { this.m_type=OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_PLACE; }
                                  
       //--- Supported deal properties (1) real, (2) integer
        virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property);
        virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property);
        virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_STRING property);
       //--- Display a brief message with request data and (2) a short request name in the journal
        virtual void      PrintShort(const bool dash=false,const bool symbol=false);
        virtual string    Header(void);
    };
 #endif // CPENDREQPLACE_MQH_DECLARATION
 #ifndef CPENDREQPLACE_MQH_IMPLEMENTATION
 #define CPENDREQPLACE_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Return 'true' if an order supports a passed                      |
   //| integer property, otherwise return 'false'                       |
   //+------------------------------------------------------------------+
   bool CPendReqPlace::SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property)
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
      property==PEND_REQ_PROP_MQL_REQ_DEVIATION
     ) return false;
     return true;
    }
   //+------------------------------------------------------------------+
   //| Return 'true' if an order supports a passed                      |
   //| real property, otherwise return 'false'                          |
   //+------------------------------------------------------------------+
   bool CPendReqPlace::SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property)
    {
     return true;
    }
   //+------------------------------------------------------------------+
   //| Return 'true' if an order supports a passed                      |
   //| string property, otherwise return 'false'                        |
   //+------------------------------------------------------------------+
   bool CPendReqPlace::SupportProperty(ENUM_PEND_REQ_PROP_STRING property)
    {
     return true;
    }
   //+------------------------------------------------------------------+
   //| Display a brief message with request data in the journal         |
   //+------------------------------------------------------------------+
   void CPendReqPlace::PrintShort(const bool dash=false,const bool symbol=false)
    {
     string params=this.GetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME),this.m_digits_lot)+" "+
                     OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE));
     string price=CMessage::Text(MSG_LIB_TEXT_REQUEST_PRICE)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_PRICE),this.m_digits);
     string stoplimit=this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT)>0 ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_STOPLIMIT)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT),this.m_digits) : "";
     string sl=this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL)>0 ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_SL)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL),this.m_digits) : "";
     string tp=this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP)>0 ? ", "+CMessage::Text(MSG_LIB_TEXT_REQUEST_TP)+" "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP),this.m_digits) : "";
     string expiration="\n- "+this.MqlReqExpirationDescription();
     string type_filling="\n- "+this.MqlReqTypeFillingDescription();
     string type_time="\n- "+this.MqlReqTypeTimeDescription();
     string time=this.IDDescription()+", "+CMessage::Text(MSG_LIB_TEXT_CREATED)+" "+TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE));
     string attempts=CMessage::Text(MSG_LIB_TEXT_ATTEMPTS)+" "+(string)this.GetProperty(PEND_REQ_PROP_TOTAL);
     string wait=CMessage::Text(MSG_LIB_TEXT_WAIT)+" "+::TimeToString(this.GetProperty(PEND_REQ_PROP_WAITING)/1000,TIME_SECONDS);
     string end=CMessage::Text(MSG_LIB_TEXT_END)+" "+
                  TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE)+this.GetProperty(PEND_REQ_PROP_WAITING)*this.GetProperty(PEND_REQ_PROP_TOTAL));
     //---
     string message=CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_PLACE)+": "+
     "\n- "+params+", "+price+stoplimit+sl+tp+expiration+type_filling+type_time+
     "\n- "+time+", "+attempts+", "+wait+", "+end;
     ::Print(message);
     this.PrintActivations();
    }
   //+------------------------------------------------------------------+
   //| Return the short request name                                    |
   //+------------------------------------------------------------------+
   string CPendReqPlace::Header(void)
    {
      string type=OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE),true,false,false);
      return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS_PLACE)+type+", ID #"+(string)this.GetProperty(PEND_REQ_PROP_ID);
    }
   //+------------------------------------------------------------------+
  #endif // CPENDREQPLACE_MQH_IMPLEMENTATION
 #endif // __PENDREQPLACE_MQH__