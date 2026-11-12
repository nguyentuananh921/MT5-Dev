//+------------------------------------------------------------------+
//|                                                MTF Channel 2.mq5 |
//|                                        Gamuchirai Zororo Ndawana |
//|                          https://www.mql5.com/en/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Zororo Ndawana"
#property link      "https://www.mql5.com/en/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Library                                                          |
//+------------------------------------------------------------------+
#include  <Trade/Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
const  int ma_f_period = 5; //Slow MA
const  int ma_s_period = 60; //Slow MA

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input  group "Money Management"
input int lot_multiple = 5; //Lot Multiple
input int atr_multiple = 5; //ATR Multiple

//+------------------------------------------------------------------+
//| Global varaibles                                                 |
//+------------------------------------------------------------------+
double channel_high = 0;
double channel_low  = 0;
double o,h,l,c;
int    bias = 0;
double bias_level = 0;
int    confirmation = 0;
double vol,bid,ask,initial_sl;
int    atr_handler,ma_fast,ma_slow;
double atr[],ma_f[],ma_s[];
double bo_h,bo_l;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
   IndicatorRelease(atr_handler);
   IndicatorRelease(ma_fast);
   IndicatorRelease(ma_slow);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- If we have positions open
   if(PositionsTotal() > 0)
      manage_setup();

//--- Keep track of time
   static datetime timestamp;
   datetime time = iTime(Symbol(),PERIOD_CURRENT,0);
   if(timestamp != time)
     {
      //--- Time Stamp
      timestamp = time;
      if(PositionsTotal() == 0)
         find_setup();
     }
  }


//+---------------------------------------------------------------+
//| Load our technical indicators and market data                 |
//+---------------------------------------------------------------+
void setup(void)
  {
   channel_high = iHigh(Symbol(),PERIOD_M30,1);
   channel_low  = iLow(Symbol(),PERIOD_M30,1);
   vol = lot_multiple * SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   ObjectCreate(0,"Channel High",OBJ_HLINE,0,0,channel_high);
   ObjectCreate(0,"Channel Low",OBJ_HLINE,0,0,channel_low);
   atr_handler = iATR(Symbol(),PERIOD_CURRENT,14);
   ma_fast     = iMA(Symbol(),PERIOD_CURRENT,ma_f_period,0,MODE_EMA,PRICE_CLOSE);
   ma_slow     = iMA(Symbol(),PERIOD_CURRENT,ma_s_period,0,MODE_EMA,PRICE_CLOSE);
  }

//+---------------------------------------------------------------+
//| Update channel                                                |
//+---------------------------------------------------------------+
void update_channel(double new_high, double new_low)
  {
   channel_high = new_high;
   channel_low  = new_low;
   ObjectDelete(0,"Channel High");
   ObjectDelete(0,"Channel Low");
   ObjectCreate(0,"Channel High",OBJ_HLINE,0,0,channel_high);
   ObjectCreate(0,"Channel Low",OBJ_HLINE,0,0,channel_low);
  }

//+---------------------------------------------------------------+
//| Manage setup                                                  |
//+---------------------------------------------------------------+
void manage_setup(void)
  {
   bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   CopyBuffer(atr_handler,0,0,1,atr);
   Print("Managing Position");

   if(PositionSelect(Symbol()))
     {
      Print("Position Found");
      initial_sl = PositionGetDouble(POSITION_SL);
     }

   if(bias == 1)
     {
      Print("Position Buy");
      double new_sl = (ask - (atr[0] * atr_multiple));
      Print("Initial: ",initial_sl,"\nNew: ",new_sl);
      if(initial_sl < new_sl)
        {
         Trade.PositionModify(Symbol(),new_sl,0);
         Print("DONE");
        }
     }

   if(bias == -1)
     {
      Print("Position Sell");
      double new_sl = (bid + (atr[0] * atr_multiple));
      Print("Initial: ",initial_sl,"\nNew: ",new_sl);
      if(initial_sl > new_sl)
        {
         Trade.PositionModify(Symbol(),new_sl,0);
         Print("DONE");
        }
     }

  }

//+---------------------------------------------------------------+
//| Find Setup                                                    |
//+---------------------------------------------------------------+
void find_setup(void)
  {
//--- We are updating the system
   o = iOpen(Symbol(),PERIOD_CURRENT,1);
   h = iHigh(Symbol(),PERIOD_CURRENT,1);
   l = iLow(Symbol(),PERIOD_CURRENT,1);
   c = iClose(Symbol(),PERIOD_CURRENT,1);
   bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   CopyBuffer(atr_handler,0,0,1,atr);
   CopyBuffer(ma_fast,0,0,1,ma_f);
   CopyBuffer(ma_slow,0,0,1,ma_s);

//--- If we have no market bias
   if(bias == 0)
     {
      //--- Our bias is bullish
      if
      (
         (o > channel_high) &&
         (h > channel_high) &&
         (l > channel_high) &&
         (c > channel_high)
      )
        {
         bias = 1;
         bias_level = h;
         bo_h = h;
         bo_l = l;
         mark_bias(h);
        }

      //--- Our bias is bearish
      if
      (
         (o < channel_low) &&
         (h < channel_low) &&
         (l < channel_low) &&
         (c < channel_low)
      )
        {
         bias = -1;
         bias_level = l;
         bo_h = h;
         bo_l = l;
         mark_bias(l);
        }
     }

//--- Is our bias valid?
   if(bias != 0)
     {

      //--- Our bearish bias has been violated
      if
      (
         (o > channel_high) &&
         (h > channel_high) &&
         (l > channel_high) &&
         (c > channel_high) &&
         (bias == -1)
      )
        {
         forget_bias();
        }
      //--- Our bullish bias has been violated
      if
      (
         (o < channel_low) &&
         (h < channel_low) &&
         (l < channel_low) &&
         (c < channel_low) &&
         (bias == 1)
      )
        {
         forget_bias();
        }

      //--- Our bullish bias has been violated
      if
      (
         ((o < channel_high) && (c > channel_low))
      )
        {
         forget_bias();
        }

      //--- Check if we have confirmation
      if((confirmation == 0) && (bias != 0))
        {
         //--- Check if we are above the bias level
         if
         (
            (o > bias_level) &&
            (h > bias_level) &&
            (l > bias_level) &&
            (c > bias_level) &&
            (bias == 1)
         )
           {
            confirmation = 1;
           }

         //--- Check if we are below the bias level
         if
         (
            (o < bias_level) &&
            (h < bias_level) &&
            (l < bias_level) &&
            (c < bias_level) &&
            (bias == -1)
         )
           {
            confirmation = 1;
           }
        }
     }

//--- Check if our confirmation is still valid
   if(confirmation == 1)
     {
      //--- Our bias is bullish
      if(bias == 1)
        {
         //--- Confirmation is lost if we fall beneath the breakout level
         if
         (
            (o < bias_level) &&
            (h < bias_level) &&
            (l < bias_level) &&
            (c < bias_level)
         )
           {
            confirmation = 0;
           }
        }

      //--- Our bias is bearish
      if(bias == -1)
        {
         //--- Confirmation is lost if we rise above the breakout level
         if
         (
            (o > bias_level) &&
            (h > bias_level) &&
            (l > bias_level) &&
            (c > bias_level)
         )
           {
            confirmation = 0;
           }
        }
     }

//--- Do we have a setup?
   if((confirmation == 1) && (bias == 1))
     {
      if(ma_f[0] > ma_s[0])
        {
         if(c > ma_f[0])
           {
            Trade.Buy(vol,Symbol(),ask,channel_low,0,"Volatility Doctor AI");
            initial_sl = channel_low;
           }
        }
     }

   if((confirmation == 1) && (bias == -1))
     {
      if(ma_f[0] < ma_s[0])
        {
         if(c < ma_s[0])
           {
            Trade.Sell(vol,Symbol(),bid,channel_high,0,"Volatility Doctor AI");
            initial_sl = channel_high;
           }
        }
     }
   Comment("O: ",o,"\nH: ",h,"\nL: ",l,"\nC:",c,"\nC H: ",channel_high,"\nC L:",channel_low,"\nBias: ",bias,"\nBias Level: ",bias_level,"\nConfirmation: ",confirmation,"\nMA F: ",ma_f[0],"\nMA S: ",ma_s[0]);
  }

//+---------------------------------------------------------------+
//| Mark our bias levels                                          |
//+---------------------------------------------------------------+
void mark_bias(double f_level)
  {
   ObjectCreate(0,"Bias",OBJ_HLINE,0,0,f_level);
  }

//+---------------------------------------------------------------+
//| Forget our bias levels                                        |
//+---------------------------------------------------------------+
void forget_bias()
  {
   update_channel(bo_h,bo_l);
   bias = 0;
   bias_level = 0;
   confirmation = 0;
   ObjectDelete(0,"Bias");
  }
//+------------------------------------------------------------------+
