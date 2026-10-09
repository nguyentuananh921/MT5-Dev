//+------------------------------------------------------------------+
//|                                                 HistoryOrder.mqh |
//|Topic link: https://www.mql5.com/en/articles/5669                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __HISTORYORDER_MQH__
#define __HISTORYORDER_MQH__
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\Order.mqh"
 #ifndef CHISTORYORDER_MQH_DECLARATION
 #define CHISTORYORDER_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Historical market order                                          |
  //+------------------------------------------------------------------+
  class CHistoryOrder : public COrder
   {
    public:
     //--- Constructor
        CHistoryOrder(const ulong ticket) : COrder(ORDER_STATUS_HISTORY_ORDER,ticket) { this.m_type=OBJECT_DE_TYPE_HISTORY_ORDER_MARKET; }
     //--- Supported integer properties of an order
      virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
     //--- Supported real properties of an order
      virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
   };
 #endif // CHISTORYORDER_MQH_DECLARATION
 #ifndef CHISTORYORDER_MQH_IMPLEMENTATION
 #define CHISTORYORDER_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CHistoryOrder::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
    {
    if(property==ORDER_PROP_TIME_EXP          || 
       property==ORDER_PROP_DEAL_ENTRY        || 
       property==ORDER_PROP_TIME_UPDATE
      #ifdef __MQL5__                        ||
      property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_TIME_CLOSE        ||
      (
       this.TypeOrder()==ORDER_TYPE_CLOSE_BY && 
       property==ORDER_PROP_DIRECTION
      )
      #endif 
    ) return false;
    return true;
    }
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CHistoryOrder::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
   {
     if(
      #ifdef __MQL5__
      property==ORDER_PROP_PROFIT                  || 
      property==ORDER_PROP_PROFIT_FULL             || 
      property==ORDER_PROP_SWAP                    || 
      property==ORDER_PROP_COMMISSION              ||
      property==ORDER_PROP_PRICE_CLOSE             ||
      (
       property==ORDER_PROP_PRICE_STOP_LIMIT       && 
       (
        this.TypeOrder()<ORDER_TYPE_BUY_STOP_LIMIT || 
        this.TypeOrder()>ORDER_TYPE_SELL_STOP_LIMIT
       )
      )
      #else
      property==ORDER_PROP_PRICE_STOP_LIMIT        && 
      this.Status()==ORDER_STATUS_HISTORY_ORDER
      #endif 
     ) return false;
     return true;
   }
 #endif // CHISTORYORDER_MQH_IMPLEMENTATION
#endif // __HISTORYORDER_MQH__