//+------------------------------------------------------------------+
//|                                         EURGBP Stochastic AI.mq5 |
//|                                        Gamuchirai Zororo Ndawana |
//|                          https://www.mql5.com/en/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Zororo Ndawana"
#property link      "https://www.mql5.com/en/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double vol,bid,ask;

//+------------------------------------------------------------------+
//| Technical indicator handlers                                     |
//+------------------------------------------------------------------+
int slow_ma_handler,fast_ma_handler,stochastic_handler,atr_handler;
double slow_ma[],fast_ma[],stochastic[],atr[];

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
const int slow_period = 60;
const int fast_period = 20;
const int atr_period = 14;

//+------------------------------------------------------------------+
//| User inputs                                                      |
//+------------------------------------------------------------------+
input group "Money Management"
input int lot_multiple = 5; //Lot size

input group "Risk Management"
input int atr_multiple = 5; //Stop Loss Width

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Setup our technical indicators and fetch market data
   setup();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(fast_ma_handler);
   IndicatorRelease(slow_ma_handler);
   IndicatorRelease(atr_handler);
   IndicatorRelease(stochastic_handler);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Fetch updated quotes
   update();

//--- If we have no open positions, check for a setup
   if(PositionsTotal() == 0)
     {
      find_setup();
     }
  }

//+------------------------------------------------------------------+
//| Setup technical market data                                      |
//+------------------------------------------------------------------+
void setup(void)
  {
//--- Setup our indicators
   slow_ma_handler    = iMA("EURGBP",PERIOD_D1,slow_period,0,MODE_EMA,PRICE_CLOSE);
   fast_ma_handler    = iMA("EURGBP",PERIOD_D1,fast_period,0,MODE_EMA,PRICE_CLOSE);
   stochastic_handler = iStochastic("EURGBP",PERIOD_D1,5,3,3,MODE_EMA,STO_CLOSECLOSE);
   atr_handler        = iATR("EURGBP",PERIOD_D1,atr_period);
//--- Fetch market data
   vol = lot_multiple * SymbolInfoDouble("EURGBP",SYMBOL_VOLUME_MIN);
  }

//+------------------------------------------------------------------+
//| Fetch updated market data                                        |
//+------------------------------------------------------------------+
void update(void)
  {
//--- Update our market prices
   bid = SymbolInfoDouble("EURGBP",SYMBOL_BID);
   ask = SymbolInfoDouble("EURGBP",SYMBOL_ASK);
//--- Copy indicator buffers
   CopyBuffer(atr_handler,0,0,1,atr);
   CopyBuffer(slow_ma_handler,0,0,1,slow_ma);
   CopyBuffer(fast_ma_handler,0,0,1,fast_ma);
   CopyBuffer(stochastic_handler,0,0,1,stochastic);
  }

//+------------------------------------------------------------------+
//| Check if we have an oppurtunity to trade                         |
//+------------------------------------------------------------------+
void find_setup(void)
  {
//--- Can we buy?
   if((fast_ma[0] > slow_ma[0]) && (stochastic[0] > 80))
     {
      Trade.Buy(vol,"EURGBP",ask,(ask - (atr[0] * atr_multiple)),(ask + (atr[0] * atr_multiple)),"EURGBP");
     }

//--- Can we sell?
   if((fast_ma[0] < slow_ma[0]) && (stochastic[0] < 20))
     {
      Trade.Sell(vol,"EURGBP",bid,(bid + (atr[0] * atr_multiple)),(bid - (atr[0] * atr_multiple)),"EURGBP");
     }
  }
//+------------------------------------------------------------------+
