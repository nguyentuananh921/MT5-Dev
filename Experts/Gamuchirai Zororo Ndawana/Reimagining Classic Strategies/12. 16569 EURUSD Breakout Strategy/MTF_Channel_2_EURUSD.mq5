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
const  int ma_f_period     = 5;  //Fast MA
const  int ma_s_period     = 60; //Slow MA
const  int wpr_period      = 10; //Williams Percent Range Period
const  double atr_multiple = 30;  //ATR Multiple

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input  group "Money Management"
input int lot_multiple    = 5; //Lot Multiple

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
int    last_trade_state,current_state;
int    eurgbp_willr, gbpusd_willr;
string symbols[] = {"EURGBP","GBPUSD"};

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
   IndicatorRelease(eurgbp_willr);
   IndicatorRelease(gbpusd_willr);
   IndicatorRelease(atr_handler);
   IndicatorRelease(ma_fast);
   IndicatorRelease(ma_slow);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Keep track of time
   static datetime timestamp;
   datetime time = iTime("EURUSD",PERIOD_CURRENT,0);
   if(timestamp != time)
     {
      //--- Time Stamp
      timestamp = time;
      //--- If we have positions open
      if(PositionsTotal() > 0)
         manage_setup();

      if(PositionsTotal() == 0)
         find_setup();
     }
  }

//+---------------------------------------------------------------+
//| Load our technical indicators and market data                 |
//+---------------------------------------------------------------+
void setup(void)
  {
//--- Select the symbols we need
   SymbolSelect("EURGBP",true);
   SymbolSelect("GBPUSD",true);
//--- Reset our last trade state
   last_trade_state = 0;
//--- Mark the current high and low
   channel_high = iHigh("EURUSD",PERIOD_M30,1);
   channel_low  = iLow("EURUSD",PERIOD_M30,1);
   ObjectCreate(0,"Channel High",OBJ_HLINE,0,0,channel_high);
   ObjectCreate(0,"Channel Low",OBJ_HLINE,0,0,channel_low);
//--- Our trading volums
   vol = lot_multiple * SymbolInfoDouble("EURUSD",SYMBOL_VOLUME_MIN);
//--- Our technical indicators
   atr_handler  = iATR("EURUSD",PERIOD_CURRENT,14);
   eurgbp_willr = iWPR(symbols[0],PERIOD_CURRENT,wpr_period);
   gbpusd_willr = iWPR(symbols[1],PERIOD_CURRENT,wpr_period);
   ma_fast      = iMA("EURUSD",PERIOD_CURRENT,ma_f_period,0,MODE_EMA,PRICE_CLOSE);
   ma_slow      = iMA("EURUSD",PERIOD_CURRENT,ma_s_period,0,MODE_EMA,PRICE_CLOSE);
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
   bid = SymbolInfoDouble("EURUSD",SYMBOL_BID);
   ask = SymbolInfoDouble("EURUSD",SYMBOL_ASK);
   CopyBuffer(atr_handler,0,0,1,atr);
   Print("Managing Position");

   if(PositionSelect("EURUSD"))
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
         Trade.PositionModify("EURUSD",new_sl,0);
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
         Trade.PositionModify("EURUSD",new_sl,0);
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
   o = iOpen("EURUSD",PERIOD_CURRENT,1);
   h = iHigh("EURUSD",PERIOD_CURRENT,1);
   l = iLow("EURUSD",PERIOD_CURRENT,1);
   c = iClose("EURUSD",PERIOD_CURRENT,1);
   bid = SymbolInfoDouble("EURUSD",SYMBOL_BID);
   ask = SymbolInfoDouble("EURUSD",SYMBOL_ASK);
   CopyBuffer(atr_handler,0,0,1,atr);
   CopyBuffer(ma_fast,0,0,1,ma_f);
   CopyBuffer(ma_slow,0,0,1,ma_s);

//--- Record our current state
   if(ma_f[0] > ma_s[0])
      current_state = 1;
   if(ma_f[0] < ma_s[0])
      current_state = -1;


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
   if((confirmation == 1) && (bias == 1) && (current_state != last_trade_state))
     {
      if(ma_f[0] > ma_s[0])
        {
         if(c > ma_f[0])
           {
            if(additional_confirmation(1))
              {
               Trade.Buy(vol,"EURUSD",ask,channel_low,0,"Volatility Doctor");
               initial_sl = channel_low;
               last_trade_state = 1;
              }
           }
        }
     }

   if((confirmation == 1) && (bias == -1)  && (current_state != last_trade_state))
     {
      if(ma_f[0] < ma_s[0])
        {
         if(c < ma_s[0])
           {
            if(additional_confirmation(-1))
              {
               Trade.Sell(vol,"EURUSD",bid,channel_high,0,"Volatility Doctor");
               initial_sl = channel_high;
               last_trade_state = -1;
              }
           }
        }
     }

//--- We will only reset the last trade state if the moving average state has crossed in the opposite direction
   if((PositionsTotal() == 0) && (current_state * last_trade_state != 0) && (current_state != last_trade_state))
      last_trade_state = 0;

   Comment("O: ",o,"\nH: ",h,"\nL: ",l,"\nC:",c,"\nC H: ",channel_high,"\nC L:",channel_low,"\nBias: ",bias,"\nBias Level: ",bias_level,"\nConfirmation: ",confirmation,"\nMA F: ",ma_f[0],"\nMA S: ",ma_s[0]);
  }

//+---------------------------------------------------------------+
//| Check for true strength                                       |
//+---------------------------------------------------------------+
bool additional_confirmation(int flag)
  {
//--- Do we have additional confirmation from our benchmark pairs?

//--- Record the average change in the EURGBP and GBPUSD Market
   vector eurgbp_willr_f = vector::Zeros(1);
   vector gbpusd_willr_f = vector::Zeros(1);

   eurgbp_willr_f.CopyIndicatorBuffer(eurgbp_willr,0,0,1);
   gbpusd_willr_f.CopyIndicatorBuffer(gbpusd_willr,0,0,1);

   if((flag == 1) && (eurgbp_willr_f[0] > -50) && (gbpusd_willr_f[0] < -50))
      return(true);
   if((flag == -1) && (eurgbp_willr_f[0] < -50) && (gbpusd_willr_f[0] > -50))
      return(true);

   Print("EURGBP WPR: ",eurgbp_willr_f[0],"\nGBPUSD WPR: ",gbpusd_willr_f[0]);
   return(false);
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
//update_channel(bo_h,bo_l);
   bias = 0;
   bias_level = 0;
   confirmation = 0;
   ObjectDelete(0,"Bias");
  }
//+------------------------------------------------------------------+
