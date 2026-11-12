//+------------------------------------------------------------------+
//|                                                DBB Benchmark.mq5 |
//|                                               Gamuchirai Ndawana |
//|                    https://www.mql5.com/en/users/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Ndawana"
#property link      "https://www.mql5.com/en/users/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| System definitions                                               |
//+------------------------------------------------------------------+
#define BB_PERIOD   20
#define BB_SHIFT    0
#define ATR_PERIOD  14
#define ATR_PADDING 2
#define BB_SD_1     2
#define BB_SD_2     1
#define TF_1        PERIOD_D1

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int    bb_handler,bb_handler_2,atr_handler;
double bb_reading_u[],bb_reading_m[],bb_reading_l[],bb_reading_u_2[],bb_reading_m_2[],bb_reading_l_2[],atr_reading[];
double padding,close;

//+------------------------------------------------------------------+
//| Library                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <VolatilityDoctor\Trade\TradeInfo.mqh>

CTrade    Trade;
TradeInfo *TradeInfoHandler;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Setup our technical indicators
   bb_handler       = iBands(Symbol(),TF_1,BB_PERIOD,BB_SHIFT,BB_SD_1,PRICE_CLOSE);
   bb_handler_2     = iBands(Symbol(),TF_1,BB_PERIOD,BB_SHIFT,BB_SD_2,PRICE_CLOSE);
   atr_handler      = iATR(Symbol(),TF_1,ATR_PERIOD);
   TradeInfoHandler = new TradeInfo(Symbol(),TF_1);
//---
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release the indicators we are no longer using
   IndicatorRelease(bb_handler);
   IndicatorRelease(bb_handler_2);
   IndicatorRelease(atr_handler);
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Keep track of time
   static datetime timestamp;
   datetime current_time = iTime(Symbol(),TF_1,0);

   if(timestamp != current_time)
     {
      //--- Update indicator readings
      CopyBuffer(bb_handler,0,0,1,bb_reading_m);
      CopyBuffer(bb_handler,1,0,1,bb_reading_u);
      CopyBuffer(bb_handler,2,0,1,bb_reading_l);
      CopyBuffer(bb_handler_2,0,0,1,bb_reading_m_2);
      CopyBuffer(bb_handler_2,1,0,1,bb_reading_u_2);
      CopyBuffer(bb_handler_2,2,0,1,bb_reading_l_2);
      CopyBuffer(atr_handler,0,0,1,atr_reading);

      //--- Get updated market readings
      close = iClose(Symbol(),TF_1,0);
      padding = atr_reading[0] * 2;

      //--- If we have no open positions
      if(PositionsTotal() == 0)
        {
         if(close > bb_reading_u[0])
            Trade.Sell(TradeInfoHandler.MinVolume(),Symbol(),TradeInfoHandler.GetBid(),TradeInfoHandler.GetAsk()+padding,TradeInfoHandler.GetAsk()-padding);

         else
            if(close < bb_reading_l[0])
               Trade.Buy(TradeInfoHandler.MinVolume(),Symbol(),TradeInfoHandler.GetAsk(),TradeInfoHandler.GetBid()-padding,TradeInfoHandler.GetBid()+padding);
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Undefine system definitions                                      |
//+------------------------------------------------------------------+
#undef BB_PERIOD
#undef BB_SD_1
#undef BB_SD_2
#undef BB_SHIFT
#undef ATR_PADDING
#undef ATR_PERIOD
#undef TF_1
//+------------------------------------------------------------------+
