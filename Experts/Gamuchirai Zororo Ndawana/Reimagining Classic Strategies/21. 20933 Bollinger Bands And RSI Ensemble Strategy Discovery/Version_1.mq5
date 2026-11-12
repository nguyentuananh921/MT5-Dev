//+------------------------------------------------------------------+
//|                                                    Version 1.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <VolatilityDoctor/Trade/TradeInfo.mqh>
CTrade Trade;
TradeInfo *TradeHelper;

//+------------------------------------------------------------------+
//| System definitions                                               |
//+------------------------------------------------------------------+
#define ATR_PERIOD    14
#define ATR_MULTIPLE  2
#define BB_PERIOD     30
#define BB_SD         2
#define BB_PRICE      PRICE_CLOSE
#define RSI_PERIOD    15
#define RSI_PRICE     PRICE_CLOSE
#define RSI_LEVEL_MAX 70
#define RSI_LEVEL_MIN 30
#define SYMBOL        "EURUSD"
#define TF_MAIN       PERIOD_D1
#define TF_TRADING    PERIOD_H4
#define SHIFT         0

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int      bb_handler,rsi_handler,atr_handler;
double   bb_upper[],bb_mid[],bb_lower[],rsi[],atr[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Setup the technical indicators
   bb_handler  = iBands(SYMBOL,TF_MAIN,BB_PERIOD,SHIFT,BB_SD,BB_PRICE);
   rsi_handler = iRSI(SYMBOL,TF_MAIN,RSI_PERIOD,RSI_PRICE);
   atr_handler = iATR(SYMBOL,TF_MAIN,ATR_PERIOD);

//--- Validate the indicators were setup correctly
   if(bb_handler == INVALID_HANDLE)
     {
      //--- Failed to sertup the Bollinger Bands
      Comment("Failed to setup the Bollinger Bands Indicator: ",GetLastError());
      return(INIT_FAILED);
     }

   else
      if(rsi_handler == INVALID_HANDLE)
        {
         //--- Failed to setup the RSI indicator
         Comment("Failed to setup the RSI Indicator: ",GetLastError());
         return(INIT_FAILED);
        }

      else
         if(atr_handler == INVALID_HANDLE)
           {
            //--- Failed to setup the ATR indicator
            Comment("Failed to setup the ATR Indicator: ",GetLastError());
            return(INIT_FAILED);
           }

         else
           {
            //--- User defined types
            TradeHelper = new TradeInfo(SYMBOL,TF_MAIN);

            //--- Good news: no errors
            return(INIT_SUCCEEDED);

           }
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release the indicators
   IndicatorRelease(bb_handler);
   IndicatorRelease(rsi_handler);
   IndicatorRelease(atr_handler);
   delete TradeHelper;
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Keep track of the time
   static datetime time_stamp;
   datetime time_current = iTime(SYMBOL,TF_TRADING,0);

//--- Check if a new candle has formed
   if(time_stamp != time_current)
     {
      //--- Update the time
      time_stamp = time_current;

      //--- Update our indicator readings
      CopyBuffer(bb_handler,0,0,1,bb_mid);
      CopyBuffer(bb_handler,1,0,1,bb_upper);
      CopyBuffer(bb_handler,2,0,1,bb_lower);
      CopyBuffer(rsi_handler,0,0,1,rsi);
      CopyBuffer(atr_handler,0,0,1,atr);


      //--- Update current price levels
      double close = iClose(SYMBOL,TF_MAIN,SHIFT);

      //--- If we have no open positions
      if(PositionsTotal() == 0)
        {
         //--- Check for our trading signal
         if((close > bb_upper[0]) && (rsi[0] > RSI_LEVEL_MAX))
           {
            Trade.Sell(TradeHelper.MinVolume(),TradeHelper.GetSymbol(),TradeHelper.GetBid(),TradeHelper.GetBid() + (atr[0] * ATR_MULTIPLE),TradeHelper.GetBid() - (atr[0] * ATR_MULTIPLE),"");
           }

         else
            if((close < bb_lower[0]) && (rsi[0] < RSI_LEVEL_MIN))
              {
               Trade.Buy(TradeHelper.MinVolume(),TradeHelper.GetSymbol(),TradeHelper.GetAsk(),TradeHelper.GetAsk() - (atr[0] * ATR_MULTIPLE),TradeHelper.GetAsk() + (atr[0] * ATR_MULTIPLE),"");
              }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Undefine system constants                                        |
//+------------------------------------------------------------------+
#undef ATR_PERIOD
#undef ATR_MULTIPLE
#undef BB_PERIOD
#undef BB_SD
#undef BB_PRICE
#undef RSI_PERIOD
#undef RSI_PRICE
#undef SYMBOL
#undef TF_MAIN
#undef SHIFT
#undef TF_TRADING
//+------------------------------------------------------------------+