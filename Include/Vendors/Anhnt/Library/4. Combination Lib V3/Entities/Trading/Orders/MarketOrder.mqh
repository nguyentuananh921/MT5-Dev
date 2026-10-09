//+------------------------------------------------------------------+
//|                                                  MarketOrder.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/5724                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __MARKETORDER_MQH__
#define __MARKETORDER_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Order.mqh"
 #ifndef CMARKETORDER_MQH_DECLARATION
 #define CMARKETORDER_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Market order                                                     |
 //+------------------------------------------------------------------+
 class CMarketOrder : public COrder
  {
   public:
   //--- Constructor
                        CMarketOrder(const ulong ticket=0) : COrder(ORDER_STATUS_MARKET_ORDER,ticket) { this.m_type=OBJECT_DE_TYPE_MARKET_ORDER; }
   //--- Supported order properties (1) real, (2) integer
   virtual bool           SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
   virtual bool           SupportProperty(ENUM_ORDER_PROP_INTEGER property);
  };
 #endif // CMARKETORDER_MQH_DECLARATION
 #ifndef CMARKETORDER_MQH_IMPLEMENTATION
 #define CMARKETORDER_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CMarketOrder::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
   {
    if(property==ORDER_PROP_TIME_EXP          || 
      property==ORDER_PROP_DEAL_ENTRY        || 
      property==ORDER_PROP_TIME_UPDATE       || 
      property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_TIME_CLOSE        ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO
     ) return false;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CMarketOrder::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
   {
    if(property==ORDER_PROP_PROFIT            || 
      property==ORDER_PROP_PROFIT_FULL       || 
      property==ORDER_PROP_SWAP              || 
      property==ORDER_PROP_COMMISSION        ||
      property==ORDER_PROP_PRICE_CLOSE       ||
      property==ORDER_PROP_SL                ||
      property==ORDER_PROP_TP                ||
      property==ORDER_PROP_PRICE_STOP_LIMIT
     ) return false;
    return true;
   }
 #endif // CMARKETORDER_MQH_IMPLEMENTATION
#endif // __MARKETORDER_MQH__