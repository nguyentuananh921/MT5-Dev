//+------------------------------------------------------------------+
//|                                               MarketBookSell.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link https://www.mql5.com/en/articles/9850                        |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __MARKETBOOKSELL_MQH__
#define __MARKETBOOKSELL_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\MarketBookOrd.mqh"
 #ifndef CMARKETBOOKSELL_MQH_DECLARATION
 #define CMARKETBOOKSELL_MQH_DECLARATION
 //+------------------------------------------------------------------+
//| Sell order in DOM                                                |
//+------------------------------------------------------------------+
class CMarketBookSell : public CMarketBookOrd
  {
private:

public:
   //--- Constructor
                     CMarketBookSell(const string symbol,const MqlBookInfo &book_info) :
                        CMarketBookOrd(MBOOK_ORD_STATUS_SELL,book_info,symbol) { this.m_type=OBJECT_DE_TYPE_BOOK_SELL; }
   //--- Supported order properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_INTEGER property);
//--- Return the object short name
   virtual string    Header(const bool symbol=false);
//--- Return the description of order type (ENUM_BOOK_TYPE)
   virtual string    TypeDescription(void);
  };
 #endif // CMARKETBOOKSELL_MQH_DECLARATION
 #ifndef CMARKETBOOKSELL_MQH_IMPLEMENTATION
 #define CMARKETBOOKSELL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CMarketBookSell::SupportProperty(ENUM_MBOOK_ORD_PROP_INTEGER property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CMarketBookSell::SupportProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return the object short name                                     |
//+------------------------------------------------------------------+
string CMarketBookSell::Header(const bool symbol=false)
  {
   return CMessage::Text(MSG_MBOOK_ORD_TYPE_SELL)+(symbol ? " \""+this.Symbol()+"\"" : "")+
          ": "+::DoubleToString(this.Price(),this.Digits())+" ["+::DoubleToString(this.VolumeReal(),2)+"]";
  }
//+------------------------------------------------------------------+
//| Return the description of order type                             |
//+------------------------------------------------------------------+
string CMarketBookSell::TypeDescription(void)
  {
   return CMessage::Text(MSG_MBOOK_ORD_TYPE_SELL);
  }
//+------------------------------------------------------------------+

 #endif // CMARKETBOOKSELL_MQH_IMPLEMENTATION
#endif // __MARKETBOOKSELL_MQH__