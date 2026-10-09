#ifndef __MARKETBOOKBUY_MQH__
#define __MARKETBOOKBUY_MQH__
//+------------------------------------------------------------------+
//|                                                MarketBookBuy.mqh |
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
 #ifndef CMARKETBOOKBUY_MQH_DECLARATION
 #define CMARKETBOOKBUY_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Buy order in DOM                                                 |
//+------------------------------------------------------------------+
class CMarketBookBuy : public CMarketBookOrd
  {
private:

public:
   //--- Constructor
                     CMarketBookBuy(const string symbol,const MqlBookInfo &book_info) :
                        CMarketBookOrd(MBOOK_ORD_STATUS_BUY,book_info,symbol) { this.m_type=OBJECT_DE_TYPE_BOOK_BUY; }
   //--- Supported order properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_INTEGER property);
//--- Return the object short name
   virtual string    Header(const bool symbol=false);
//--- Return the description of order type (ENUM_BOOK_TYPE)
   virtual string    TypeDescription(void);
  };
 #endif // CMARKETBOOKBUY_MQH_DECLARATION
 #ifndef CMARKETBOOKBUY_MQH_IMPLEMENTATION
 #define CMARKETBOOKBUY_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CMarketBookBuy::SupportProperty(ENUM_MBOOK_ORD_PROP_INTEGER property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CMarketBookBuy::SupportProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return the object short name                                     |
//+------------------------------------------------------------------+
string CMarketBookBuy::Header(const bool symbol=false)
  {
   return CMessage::Text(MSG_MBOOK_ORD_TYPE_BUY)+(symbol ? " \""+this.Symbol()+"\"" : "")+
          ": "+::DoubleToString(this.Price(),this.Digits())+" ["+::DoubleToString(this.VolumeReal(),2)+"]";
  }
//+------------------------------------------------------------------+
//| Return the description of order type                             |
//+------------------------------------------------------------------+
string CMarketBookBuy::TypeDescription(void)
  {
   return CMessage::Text(MSG_MBOOK_ORD_TYPE_BUY);
  }
//+------------------------------------------------------------------+

 #endif // CMARKETBOOKBUY_MQH_IMPLEMENTATION
#endif // __MARKETBOOKBUY_MQH__