//+------------------------------------------------------------------+
//|                                  Feedback Control Benchmark .mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| System constants                                                 |
//+------------------------------------------------------------------+
#define SYMBOL Symbol()
#define MA_SHIFT 0
#define MA_MODE MODE_EMA
#define MA_APPLIED_PRICE PRICE_CLOSE
#define SYSTEM_TIME_FRAME PERIOD_D1
#define MIN_VOLUME SymbolInfoDouble(SYMBOL,SYMBOL_VOLUME_MIN)

//+------------------------------------------------------------------+
//| Tuning parameters                                                |
//+------------------------------------------------------------------+
input group "Technical Indicators"
input int  MA_PERIOD = 10;//Moving average period

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ma[],atr[];
double ask,bid,open,high,low,close,padding;
int    ma_handler,atr_handler;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize the indicator
   ma_handler = iMA(SYMBOL,SYSTEM_TIME_FRAME,MA_PERIOD,MA_SHIFT,MA_MODE,MA_APPLIED_PRICE);
   atr_handler = iATR(SYMBOL,SYSTEM_TIME_FRAME,14);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release the indicator
   IndicatorRelease(ma_handler);
   IndicatorRelease(atr_handler);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check if a new candle has formed
   datetime current_time = iTime(Symbol(),SYSTEM_TIME_FRAME,0);
   static datetime time_stamp;

   if(current_time != time_stamp)
     {
      //--- Update the time
      time_stamp = current_time;

      //--- If we have no open positions
      if(PositionsTotal()==0)
        {
         //--- Update indicator buffers
         CopyBuffer(ma_handler,0,1,1,ma);
         CopyBuffer(atr_handler,0,0,1,atr);
         padding = atr[0] * 2;

         //--- Fetch current market prices
         ask = SymbolInfoDouble(SYMBOL,SYMBOL_ASK);
         bid = SymbolInfoDouble(SYMBOL,SYMBOL_BID);
         close = iClose(SYMBOL,SYSTEM_TIME_FRAME,0);

         //--- Check trading signal
         if(close > ma[0])
            Trade.Buy(MIN_VOLUME,SYMBOL,ask,ask-padding,ask+padding);

         if(close < ma[0])
            Trade.Sell(MIN_VOLUME,SYMBOL,bid,ask+padding,ask-padding);
        }
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Undefine system constants                                        |
//+------------------------------------------------------------------+
#undef SYMBOL
#undef SYSTEM_TIME_FRAME
#undef MA_APPLIED_PRICE
#undef MA_MODE
#undef MA_SHIFT
#undef MIN_VOLUME
//+------------------------------------------------------------------+