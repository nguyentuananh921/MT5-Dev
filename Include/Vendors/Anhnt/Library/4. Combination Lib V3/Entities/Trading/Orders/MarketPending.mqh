//+------------------------------------------------------------------+
//|                                                MarketPending.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __MARKETPENDING_MQH__
#define __MARKETPENDING_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Order.mqh"
 #ifndef CMARKETPENDING_MQH_DECLARATION
 #define CMARKETPENDING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Market pending order                                             |
 //+------------------------------------------------------------------+
 class CMarketPending : public COrder
  {
   public:
   //--- Constructor
                     CMarketPending(const ulong ticket=0) : COrder(ORDER_STATUS_MARKET_PENDING,ticket) { this.m_type=OBJECT_DE_TYPE_MARKET_PENDING; }
   //--- Supported order properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
  };
 #endif // CMARKETPENDING_MQH_DECLARATION
 #ifndef CMARKETPENDING_MQH_IMPLEMENTATION
 #define CMARKETPENDING_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| integer property, otherwise return 'false'                       |
  //+------------------------------------------------------------------+
  bool CMarketPending::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
   {
    if(
      property==ORDER_PROP_DEAL_ORDER_TICKET ||
      property==ORDER_PROP_DEAL_ENTRY        ||
      property==ORDER_PROP_TIME_UPDATE       ||
      property==ORDER_PROP_TIME_CLOSE        ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_CLOSE_BY_SL       ||
      property==ORDER_PROP_CLOSE_BY_TP
      ) return false;
     return true;
   }
  //+------------------------------------------------------------------+
  //| Return 'true' if an order supports a passed                      |
  //| real property, otherwise return 'false'                          |
  //+------------------------------------------------------------------+
  bool CMarketPending::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
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
 #endif // CMARKETPENDING_MQH_IMPLEMENTATION
#endif // __MARKETPENDING_MQH__