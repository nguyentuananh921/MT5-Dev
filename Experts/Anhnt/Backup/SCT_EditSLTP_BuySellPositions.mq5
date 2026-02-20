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
input double   SL_BuyPosition;
input double   TP_BuyPosition;
input double   SL_SellPosition;
input double   TP_SellPosition;

#include <Trade\Trade.mqh>
CTrade c_trade;

void OnStart()
  {
  
   // MODIFY SL AND TP OF BUY POSITIONS :
   for (int i=PositionsTotal()-1; i>=0; --i) {
      ulong ticket=PositionGetTicket(i);
		if (PositionGetSymbol(i)==Symbol() && PositionGetInteger(POSITION_TYPE)==0) {
			c_trade.PositionModify(ticket,SL_BuyPosition,TP_BuyPosition);
		}
	}

   // MODIFY SL AND TP OF SELL POSITIONS :
   for (int i=PositionsTotal()-1; i>=0; --i) {
      ulong ticket=PositionGetTicket(i);
		if (PositionGetSymbol(i)==Symbol() && PositionGetInteger(POSITION_TYPE)==1) {
			c_trade.PositionModify(ticket,SL_SellPosition,TP_SellPosition);
		}
   }
}