//+------------------------------------------------------------------+
//|                                 TradingEngine_MultiModule.mqh    |
//| Implementation of function using in multi module Trading Engine  |
//+------------------------------------------------------------------+
#include "TradingEngine.mqh"
#ifndef CTRADINGENGINE_MULTIMODULE_MQH
#define CTRADINGENGINE_MULTIMODULE_MQH
//For profit calculation
 double CTradingEngine::SumFloatingProfit(CArrayObj *list)
  {
   if(list == NULL) return 0;
   double total = 0;
   for(int i = 0; i < list.Total(); i++)
    {
     CMarketPosition *pos = (CMarketPosition*)list.At(i);
     if(pos != NULL) total += pos.Profit();
  }
   return total;
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfit(void)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfit(const string symbol)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfit(ENUM_POSITION_TYPE dir)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfit(const string symbol, ENUM_POSITION_TYPE dir)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfitAt(const string symbol, ENUM_POSITION_TYPE dir,
                                        double target_price)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
   if(list == NULL) return 0;
   double total = 0;
   for(int i = 0; i < list.Total(); i++)
    {
     CMarketPosition *pos = (CMarketPosition*)list.At(i);
     if(pos == NULL) continue;
     double p = 0;
     if(OrderCalcProfit((ENUM_ORDER_TYPE)dir, symbol,
                            pos.Volume(), pos.PriceOpen(), target_price, p))
      total += p;
    }
   return total;
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfitAt(const string symbol, double price)
  {
   return CalcProfitAt(symbol, POSITION_TYPE_BUY,  price)
     + CalcProfitAt(symbol, POSITION_TYPE_SELL, price);
  }  
#endif // CTRADINGENGINE_MULTIMODULE_MQH
