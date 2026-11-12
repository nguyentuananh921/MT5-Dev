//+------------------------------------------------------------------+
//|                                        Stochastic Strategy 3.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int      stoch_handler,atr_handler;
double   stoch_main_reading[],stoch_signal_reading[],atr_reading[];
double   bid,ask;
vector   high,low;

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
//--- Setup our technical indicators
atr_handler    = iATR(Symbol(),PERIOD_D1,14);
stoch_handler  = iStochastic(Symbol(),PERIOD_D1,5,3,3,MODE_SMA,STO_LOWHIGH);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Keep track of the time
datetime        current_time   = iTime(Symbol(),PERIOD_D1,0);
static datetime time_stamp;
   
   if(current_time != time_stamp)
      {
         //--- Update the time
         time_stamp = current_time;
         
         //--- Update our technical indicators
         CopyBuffer(stoch_handler,0,0,1,stoch_main_reading);
         CopyBuffer(stoch_handler,1,0,1,stoch_signal_reading);
         CopyBuffer(atr_handler,0,0,1,atr_reading);
         ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
         bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
         
         //--- Calculate the middle of the trading range
         high.CopyRates(Symbol(),PERIOD_D1,COPY_RATES_HIGH,0,90);
         low.CopyRates(Symbol(),PERIOD_D1,COPY_RATES_LOW,0,90);
         double mid = ((high.Mean() + low.Mean())/2);
         
         //--- Trading rules
         if(PositionsTotal() == 0)
            {
               if((stoch_main_reading[0] > 80) && (iClose(Symbol(),PERIOD_D1,0) > mid)) Trade.Buy(0.01,Symbol(),ask,(ask - (atr_reading[0]*2)),(ask + (atr_reading[0]*2)));
               
               if((stoch_main_reading[0] < 20) && (iClose(Symbol(),PERIOD_D1,0) < mid)) Trade.Sell(0.01,Symbol(),bid,(bid + (atr_reading[0]*2)),(bid - (atr_reading[0]*2)));
            }
      }
   
  }
//+------------------------------------------------------------------+