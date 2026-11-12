//+------------------------------------------------------------------+
//|                                                         UB 2.mq5 |
//|                                               Gamuchirai Ndawana |
//|                    https://www.mql5.com/en/users/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Ndawana"
#property link      "https://www.mql5.com/en/users/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double last_high,last_low;
string h,l;
bool rest;
int atr_handler;
double atr[];

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   h="high";
   l="low";
   rest = false;
   atr_handler = iATR(Symbol(),PERIOD_H8,4*14);
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(atr_handler);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   datetime cd = iTime(Symbol(),PERIOD_D1,0);
   static datetime ds;

   if(cd != ds)
     {
      ds = cd;
      last_high = iHigh(Symbol(),PERIOD_D1,1);
      last_low = iLow(Symbol(),PERIOD_D1,1);

      if((rest==true) && (PositionsTotal() == 0))
         rest = false;

      Comment("Last High: ",last_high,"\nLast Low: ",last_low);

      ObjectDelete(0,l);
      ObjectDelete(0,h);

      ObjectCreate(0,h,OBJ_HLINE,0,0,last_high);
      ObjectCreate(0,l,OBJ_HLINE,0,0,last_low);
      CopyBuffer(atr_handler,0,0,1,atr);
     }

   datetime ch = iTime(Symbol(),PERIOD_H1,0);
   static datetime hs;

   if(ch != hs)
     {
      hs = ch;
      double bid,ask,close,padding;

      close = iClose(Symbol(),PERIOD_H1,0);
      ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
      padding = atr[0] * 2;

      if(rest == false)
        {
         if(PositionsTotal() == 0)
           {

            if(close<last_low)
               Trade.Buy(0.01,Symbol(),ask,(bid-(padding)),last_high);

            else
               if(close>last_high)
                  Trade.Sell(0.01,Symbol(),bid,(ask+(padding)),last_low);

            rest = true;
           }
        }
     }
  }
//+------------------------------------------------------------------+