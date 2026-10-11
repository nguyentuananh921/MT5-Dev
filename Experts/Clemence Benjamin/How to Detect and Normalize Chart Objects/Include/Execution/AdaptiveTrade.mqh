//+------------------------------------------------------------------+
//|                                              AdaptiveTrade.mqh  |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Structures.mqh"
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Executes adaptive trade - works for ANY instrument               |
//+------------------------------------------------------------------+
bool ExecuteAdaptiveTrade(TradeSignal &signal, double lotSize, int minStopPoints,
                          double slMultiplier, double tpMultiplier,
                          CTrade &trade, datetime &lastTradeTime, int tradeCooldown,
                          bool debug)
{
//--- Get instrument properties
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / point;
   
//--- Get current market prices
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
//--- Calculate minimum stop distance
   int stopPoints = MathMax(minStopPoints, 50);
   
//--- Increase for Boom/Crash indices
   if (StringFind(_Symbol, "Boom") >= 0 || StringFind(_Symbol, "Crash") >= 0)
   {
      stopPoints = MathMax(stopPoints, 150);
   }
   
   double minStopDistance = stopPoints * point;
   minStopDistance += spread * point * 2;
   
//--- Determine entry price
   bool isBuy = (signal.orderType == ORDER_TYPE_BUY);
   double entry = isBuy ? ask : bid;
   
//--- Calculate SL and TP
   double sl = 0;
   double tp = 0;
   
   if (isBuy)
   {
      sl = entry - minStopDistance * slMultiplier;
      tp = entry + minStopDistance * tpMultiplier;
      
      if (sl >= entry)
         sl = entry - minStopDistance * 2;
      if (tp <= entry)
         tp = entry + minStopDistance * 3;
   }
   else
   {
      sl = entry + minStopDistance * slMultiplier;
      tp = entry - minStopDistance * tpMultiplier;
      
      if (sl <= entry)
         sl = entry + minStopDistance * 2;
      if (tp >= entry)
         tp = entry - minStopDistance * 3;
   }
   
//--- Ensure valid prices
   if (sl <= 0)
      sl = entry * 0.95;
   if (tp <= 0)
      tp = entry * 1.05;
   
//--- Debug logging
   if (debug)
   {
      Print("=== ADAPTIVE STOPS ===");
      PrintFormat("Symbol: %s, Point: %.5f", _Symbol, point);
      PrintFormat("Min Stop Points: %d, Min Distance: %.5f", stopPoints, minStopDistance);
      PrintFormat("Entry: %.5f, SL: %.5f, TP: %.5f", entry, sl, tp);
      PrintFormat("SL Dist: %.0f pts, TP Dist: %.0f pts",
                  MathAbs(entry - sl) / point, MathAbs(entry - tp) / point);
      Print("=======================");
   }
   
//--- Place order
   bool result = false;
   string comment = signal.reason;
   
   if (isBuy)
   {
      result = trade.Buy(lotSize, _Symbol, entry, sl, tp, comment);
   }
   else
   {
      result = trade.Sell(lotSize, _Symbol, entry, sl, tp, comment);
   }
   
   if (result)
   {
      lastTradeTime = TimeCurrent();
      if (debug)
         Print("Trade executed. Ticket: ", trade.ResultOrder());
   }
   else
   {
      if (debug)
      {
         Print("Trade failed: ", trade.ResultRetcodeDescription());
         Print("Error code: ", trade.ResultRetcode());
      }
   }
   
   return result;
}