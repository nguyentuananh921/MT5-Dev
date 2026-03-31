//+------------------------------------------------------------------+ 
//|                          Golden & Death Cross Strategy.mq5       |
//|                           Copyright 2024, Clemence Benjamin      |
//|        https://www.mql5.com/en/users/billionaire2024/seller      |
//+------------------------------------------------------------------+

#property copyright "Clemence Benjamin"
#property description "GOLDEN AND DEATH CROSS"
#property version "1.0"


//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include<Trade\Trade.mqh>;
CTrade trade;

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input double LotSize = 1.0;            // Trade volume (lots)
input int Slippage = 20;               // Slippage in points
input int TimerInterval = 1000;          // Timer interval in seconds
input double StopLossPips = 1500;        // Stop Loss in pips
input int FastEMAPeriod = 50;          // Fast EMA period (default 50)
input int SlowEMAPeriod = 200;         // Slow EMA period (default 200)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- create timer
   EventSetTimer(TimerInterval);
   
   //--- Check if there are enough bars to calculate the EMA
   if(Bars(_Symbol,PERIOD_CURRENT)<SlowEMAPeriod)
     {
      Print("Not enough bars for EMA calculation");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- delete timer
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
   bool hasPosition = PositionSelect(_Symbol);
   
   int fastEMAHandle = iMA(_Symbol, PERIOD_CURRENT, FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   int slowEMAHandle = iMA(_Symbol, PERIOD_CURRENT, SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);

   if(fastEMAHandle < 0 || slowEMAHandle < 0)
   {
      Print("Failed to create EMA handles. Error: ", GetLastError());
      return;
   }

   double fastEMAArray[], slowEMAArray[];
   if(CopyBuffer(fastEMAHandle, 0, 0, 2, fastEMAArray) <= 0 ||
      CopyBuffer(slowEMAHandle, 0, 0, 2, slowEMAArray) <= 0)
   {
      Print("Failed to copy EMA data. Error: ", GetLastError());
      return;
   }

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(!hasPosition)
   {
      if(fastEMAArray[0] > slowEMAArray[0] && fastEMAArray[1] <= slowEMAArray[1]) // Death Cross 
      {
         
         double sl = NormalizeDouble(ask + StopLossPips * point, _Digits);
         if(!trade.Sell(LotSize, _Symbol, ask, sl ))
            Print("Buy order error ", GetLastError());
         else
            Print("Buy order opened with TP ", " and SL ", StopLossPips, " pips");
      }
      else if(fastEMAArray[0] < slowEMAArray[0] && fastEMAArray[1] >= slowEMAArray[1]) // Golden Cross
      {
         
         double sl = NormalizeDouble(bid - StopLossPips * point, _Digits);
         if(!trade.Buy(LotSize, _Symbol, bid, sl ))
            Print("Sell order error ", GetLastError());
         else
            Print("Sell order opened with TP ",  " and SL ", StopLossPips, " pips");
      }
   }
   else
   {
     if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && fastEMAArray[0] < slowEMAArray[0]) ||
         (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && fastEMAArray[0] > slowEMAArray[0]))
    {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         if(!trade.PositionClose(ticket))
            Print("Failed to close position (Ticket: ", ticket, "). Error: ", GetLastError());
         else  
            Print("Position closed : ", ticket);
      }
   }
}

//+------------------------------------------------------------------+