//+------------------------------------------------------------------+
//|                                                SCT_EDITSLTP2.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//--- input parameters
input double   SL_BuyStopOrder;
input double   TP_BuyStopOrder;
input double   SL_SellStopOrder;
input double   TP_SellStopOrder;

#include <Trade\Trade.mqh>
CTrade c_trade;

void OnStart()
  {
  
   // MODIFY SL AND TP OF BUY STOP ORDERS
   for (int j=OrdersTotal()-1; j>=0; --j) {
      ulong ticket=OrderGetTicket(j);
      if (OrderGetString(ORDER_SYMBOL)==Symbol() && OrderGetInteger(ORDER_TYPE)==4) 
      {
      
         c_trade.OrderModify(ticket,OrderGetDouble(ORDER_PRICE_OPEN),SL_BuyStopOrder,TP_BuyStopOrder,ORDER_TIME_DAY,0);
         c_trade.OrderModify(ticket,OrderGetDouble(ORDER_PRICE_OPEN),SL_BuyStopOrder,TP_BuyStopOrder,ORDER_TIME_DAY,0);
      }
	}
   
   // MODIFY SL AND TP OF SELL STOP ORDERS
   for (int j=OrdersTotal()-1; j>=0; --j) {
      ulong ticket=OrderGetTicket(j);
      if (OrderGetString(ORDER_SYMBOL)==Symbol() && OrderGetInteger(ORDER_TYPE)==5) {
         c_trade.OrderModify(ticket,OrderGetDouble(ORDER_PRICE_OPEN),SL_SellStopOrder,TP_SellStopOrder,ORDER_TIME_DAY,0);
      }
	}
}