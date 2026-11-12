//+------------------------------------------------------------------+
//|                                               Channel And MA.mq5 |
//|                                        Gamuchirai Zororo Ndawana |
//|                          https://www.mql5.com/en/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Zororo Ndawana"
#property link      "https://www.mql5.com/en/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| This version off the application is mean reverting               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| System constants                                                 |
//+------------------------------------------------------------------+
#define TF_1           PERIOD_D1 //--- Our main time frame
#define TF_2           PERIOD_H1 //--- Our lower time frame
#define ATR_PERIOD     14        //--- The period for our ATR
#define ATR_MULTIPLE   3         //--- How wide should our stops be?
#define VOL            0.01         //--- Trading volume

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int    trade;
int    ma_f_handler,ma_s_handler,atr_handler;
double ma_f[],ma_s[],atr[];
double bid,ask;
double o,h,l,c;
double original_sl;

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
//--- Setup
   setup();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release our indicators
   release();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Update system variables
   update();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Setup our system                                                 |
//+------------------------------------------------------------------+
void setup(void)
  {
   atr_handler  = iATR(Symbol(),TF_1,ATR_PERIOD);

   ma_f_handler = iMA(Symbol(),TF_1,10,0,MODE_EMA,PRICE_CLOSE);
   ma_s_handler = iMA(Symbol(),TF_1,60,0,MODE_EMA,PRICE_CLOSE);
  }

//+------------------------------------------------------------------+
//| Release variables we do not need                                 |
//+------------------------------------------------------------------+
void release(void)
  {
   IndicatorRelease(atr_handler);
   IndicatorRelease(ma_f_handler);
   IndicatorRelease(ma_s_handler);
  }

//+------------------------------------------------------------------+
//| Update system variables                                          |
//+------------------------------------------------------------------+
void update(void)
  {
//--- Update the system
   static datetime time_stamp;
   datetime current_time = iTime(Symbol(),TF_2,0);
   if(current_time != time_stamp)
     {
      time_stamp = current_time;

      CopyBuffer(atr_handler,0,0,1,atr);
      CopyBuffer(ma_s_handler,0,0,1,ma_s);
      CopyBuffer(ma_f_handler,0,0,1,ma_f);

      o  = iOpen(Symbol(),TF_1,0);
      h  = iHigh(Symbol(),TF_1,0);
      l  = iLow(Symbol(),TF_1,0);
      c  = iClose(Symbol(),TF_1,0);
      bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
      ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);

      if(PositionsTotal() == 0)
         find_position();
      if(PositionsTotal() > 0)
         manage_position();
     }
  }

//+------------------------------------------------------------------+
//| Find a position                                                  |
//+------------------------------------------------------------------+
void find_position(void)
  {

   if((ma_s[0] > ma_f[0]))
     {
      Trade.Sell(VOL,Symbol(),bid,0,0,"");
      trade = -1;
     }

   if((ma_s[0] < ma_f[0]))
     {
      Trade.Buy(VOL,Symbol(),ask,0,0,"");
      trade = 1;
     }
  }

//+------------------------------------------------------------------+
//| Manage our positions                                             |
//+------------------------------------------------------------------+
void manage_position(void)
  {
//--- Select the position
   if(PositionSelect(Symbol()))
     {
      //--- Get ready to update the SL/TP
      double initial_sl  = PositionGetDouble(POSITION_SL);
      double initial_tp  = PositionGetDouble(POSITION_TP);
      //--- Calculate the average ATR move
      vector atr_mean;
      atr_mean.CopyIndicatorBuffer(atr_handler,0,0,90);
      double buy_sl      = (ask - ((ATR_MULTIPLE * atr[0]) + atr_mean.Mean()));
      double sell_sl     = (bid + ((ATR_MULTIPLE * atr[0]) + atr_mean.Mean()));
      double buy_tp      = (ask + ((ATR_MULTIPLE * 0.5 * atr[0]) + atr_mean.Mean()));
      double sell_tp     = (bid - ((ATR_MULTIPLE * 0.5 * atr[0]) + atr_mean.Mean()));
      double new_sl      = ((trade == 1) && (initial_sl <  buy_sl)) ? (buy_sl) : ((trade == -1) && (initial_sl > sell_sl)) ? (sell_sl) : (initial_sl);
      double new_tp      = ((trade == 1) && (initial_tp <  buy_tp)) ? (buy_tp) : ((trade == -1) && (initial_tp > sell_tp)) ? (sell_tp) : (initial_tp);

      if(initial_sl == 0 && initial_tp == 0)
        {
         if(trade == 1)
           {
            original_sl = buy_sl;
            Trade.PositionModify(Symbol(),buy_sl,buy_tp);
           }

         if(trade == -1)
           {
            original_sl = sell_sl;
            Trade.PositionModify(Symbol(),sell_sl,sell_tp);
           }

        }
      //--- Update the position
      else
         if((initial_sl * initial_tp) != 0)
           {
            Trade.PositionModify(Symbol(),new_sl,new_tp);
           }
     }
  }
//+------------------------------------------------------------------+
