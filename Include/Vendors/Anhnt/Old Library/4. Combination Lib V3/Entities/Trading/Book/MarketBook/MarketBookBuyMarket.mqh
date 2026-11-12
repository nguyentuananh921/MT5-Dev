#ifndef __MARKETBOOKBUYMARKET_MQH__
#define __MARKETBOOKBUYMARKET_MQH__
//+------------------------------------------------------------------+
//|                                          MarketBookBuyMarket.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\MarketBookOrd.mqh"
 #ifndef CMARKETBOOKBUYMARKET_MQH_DECLARATION
 #define CMARKETBOOKBUYMARKET_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Buy order by Market in DOM                                       |
//+------------------------------------------------------------------+
class CMarketBookBuyMarket : public CMarketBookOrd
  {
private:

public:
   //--- Constructor
                     CMarketBookBuyMarket(const string symbol,const MqlBookInfo &book_info) :
                        CMarketBookOrd(MBOOK_ORD_STATUS_BUY,book_info,symbol) { this.m_type=OBJECT_DE_TYPE_BOOK_BUY_MARKET; }
   //--- Supported order properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_INTEGER property);
//--- Return the object short name
   virtual string    Header(const bool symbol=false);
//--- Return the description of order type (ENUM_BOOK_TYPE)
   virtual string    TypeDescription(void);
  };
 #endif // CMARKETBOOKBUYMARKET_MQH_DECLARATION
 #ifndef CMARKETBOOKBUYMARKET_MQH_IMPLEMENTATION
 #define CMARKETBOOKBUYMARKET_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CMarketBookBuyMarket::SupportProperty(ENUM_MBOOK_ORD_PROP_INTEGER property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CMarketBookBuyMarket::SupportProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return the object short name                                     |
//+------------------------------------------------------------------+
string CMarketBookBuyMarket::Header(const bool symbol=false)
  {
   return CMessage::Text(MSG_MBOOK_ORD_TYPE_BUY_MARKET)+(symbol ? " \""+this.Symbol()+"\"" : "")+
          ": "+::DoubleToString(this.Price(),this.Digits())+" ["+::DoubleToString(this.VolumeReal(),2)+"]";
  }
//+------------------------------------------------------------------+
//| Return the description of order type                             |
//+------------------------------------------------------------------+
string CMarketBookBuyMarket::TypeDescription(void)
  {
   return CMessage::Text(MSG_MBOOK_ORD_TYPE_BUY_MARKET);
  }
//+------------------------------------------------------------------+

 #endif // CMARKETBOOKBUYMARKET_MQH_IMPLEMENTATION
#endif // __MARKETBOOKBUYMARKET_MQH__