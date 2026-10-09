//+------------------------------------------------------------------+
//|                                               HistoryPending.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __HISTORYPENDING_MQH__
#define __HISTORYPENDING_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Order.mqh"
 #ifndef CHISTORYPENDING_MQH_DECLARATION
 #define CHISTORYPENDING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Removed pending order                                            |
 //+------------------------------------------------------------------+
 class CHistoryPending : public COrder
  {
   public:
     //--- Constructor
                     CHistoryPending(const ulong ticket) : COrder(ORDER_STATUS_HISTORY_PENDING,ticket) { this.m_type=OBJECT_DE_TYPE_HISTORY_ORDER_PENDING; }
     //--- Supported order properties (1) real, (2) integer
     virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
     virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
  };
 #endif // CHISTORYPENDING_MQH_DECLARATION
 #ifndef CHISTORYPENDING_MQH_IMPLEMENTATION
 #define CHISTORYPENDING_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Return 'true' if an order supports a passed property,            |
 //| otherwise return 'false'                                         |
 //+------------------------------------------------------------------+
 bool CHistoryPending::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_DEAL_ORDER_TICKET ||
      property==ORDER_PROP_DEAL_ENTRY        ||
      property==ORDER_PROP_TIME_UPDATE       ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_CLOSE_BY_SL       ||
      property==ORDER_PROP_CLOSE_BY_TP
     ) return false;
   return true;
  }
 //+------------------------------------------------------------------+
 //| Return 'true' if an order supports a passed property,            |
 //| otherwise return 'false'                                         |
 //+------------------------------------------------------------------+
 bool CHistoryPending::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
   if(property==ORDER_PROP_COMMISSION        ||
      property==ORDER_PROP_SWAP              ||
      property==ORDER_PROP_PROFIT            ||
      property==ORDER_PROP_PROFIT_FULL       ||
      property==ORDER_PROP_PRICE_CLOSE
      #ifdef __MQL5__                        ||
      property==ORDER_PROP_PRICE_STOP_LIMIT
      #endif 
     ) return false;
   return true;
  }
 #endif // CHISTORYPENDING_MQH_IMPLEMENTATION
#endif // __HISTORYPENDING_MQH__