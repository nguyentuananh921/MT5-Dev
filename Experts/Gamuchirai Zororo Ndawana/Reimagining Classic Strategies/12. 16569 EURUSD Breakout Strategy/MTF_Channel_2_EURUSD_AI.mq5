//+------------------------------------------------------------------+
//|                                                MTF Channel 2.mq5 |
//|                                        Gamuchirai Zororo Ndawana |
//|                          https://www.mql5.com/en/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Zororo Ndawana"
#property link      "https://www.mql5.com/en/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| ONNX Resources                                                   |
//+------------------------------------------------------------------+
#resource "\\Files\\eurusd_ma_5_model.onnx"         as const uchar eurusd_ma_5_buffer[];
#resource "\\Files\\eurusd_ma_60_model.onnx"        as const uchar eurusd_ma_60_buffer[];
#resource "\\Files\\eurusd_ma_5_height_model.onnx"  as const uchar eurusd_ma_5_height_buffer[];
#resource "\\Files\\eurusd_ma_60_height_model.onnx" as const uchar eurusd_ma_60_height_buffer[];

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
const  double atr_multiple = 30; //ATR Multiple

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input  group "Money Management"
input int lot_multiple    = 1;    //Lot Multiple


//+------------------------------------------------------------------+
//| Global varaibles                                                 |
//+------------------------------------------------------------------+
int     bias = 0;
int     state = 0;
int     confirmation = 0;
int     last_cross_over_state = 0;
int     atr_handler,ma_fast,ma_slow;
int     last_trade_state,current_state;
long    ma_5_model;
long    ma_60_model;
long    ma_5_height_model;
long    ma_60_height_model;
double  channel_high = 0;
double  channel_low  = 0;
double  o,h,l,c;
double  bias_level = 0;
double  vol,bid,ask,initial_sl;
double  atr[],ma_f[],ma_s[];
double  bo_h,bo_l;
vectorf ma_5_forecast = vectorf::Zeros(1);
vectorf ma_60_forecast = vectorf::Zeros(1);
vectorf ma_5_height_forecast = vectorf::Zeros(1);
vectorf ma_60_height_forecast = vectorf::Zeros(1);

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
//--- Free the resources we don't need
   IndicatorRelease(atr_handler);
   IndicatorRelease(ma_fast);
   IndicatorRelease(ma_slow);
   OnnxRelease(ma_5_model);
   OnnxRelease(ma_5_height_model);
   OnnxRelease(ma_60_model);
   OnnxRelease(ma_60_height_model);
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
      //--- Update
      update();
      //--- Get predictions
      model_predict();
      //--- If we have positions open
      if(PositionsTotal() > 0)
         manage_setup();
      if(PositionsTotal() == 0)
         find_setup();
     }
  }

//+---------------------------------------------------------------+
//| Update                                                        |
//+---------------------------------------------------------------+
void update(void)
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
  }
//+---------------------------------------------------------------+
//| Load our technical indicators and market data                 |
//+---------------------------------------------------------------+
void setup(void)
  {
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
   ma_fast      = iMA("EURUSD",PERIOD_CURRENT,ma_f_period,0,MODE_EMA,PRICE_CLOSE);
   ma_slow      = iMA("EURUSD",PERIOD_CURRENT,ma_s_period,0,MODE_EMA,PRICE_CLOSE);
//--- Setup our ONNX models
//--- Define our ONNX model
   ulong input_shape [] = {1,5};
   ulong output_shape [] = {1,1};

//--- Create the model
   ma_5_model = OnnxCreateFromBuffer(eurusd_ma_5_buffer,ONNX_DEFAULT);
   ma_60_model = OnnxCreateFromBuffer(eurusd_ma_60_buffer,ONNX_DEFAULT);
   ma_5_height_model = OnnxCreateFromBuffer(eurusd_ma_5_height_buffer,ONNX_DEFAULT);
   ma_60_height_model = OnnxCreateFromBuffer(eurusd_ma_60_height_buffer,ONNX_DEFAULT);

//--- Store our models in a list
   long onnx_models[] = {ma_5_model,ma_5_height_model,ma_60_model,ma_60_height_model};

//--- Loop over the models and set them up
   for(int i = 0; i < 4; i++)
     {
      if(onnx_models[i] == INVALID_HANDLE)
        {
         Comment("Failed to load AI module correctly: Invalid handle");
        }

      //--- Validate I/O
      if(!OnnxSetInputShape(onnx_models[i],0,input_shape))
        {
         Comment("Failed to set input shape correctly:  Wrong input shape ",GetLastError()," Actual shape: ",OnnxGetInputCount(ma_5_model));
        }

      if(!OnnxSetOutputShape(onnx_models[i],0,output_shape))
        {
         Comment("Failed to load AI module correctly: Wrong output shape ",GetLastError()," Actual shape: ",OnnxGetOutputCount(ma_5_model));
        }
     }
  }

//+------------------------------------------------------------------+
//| Get a prediction from our model                                  |
//+------------------------------------------------------------------+
void model_predict(void)
  {
   //--- Moving average inputs
   float  a = (float) ma_f[0];
   float  b = (float) ma_s[0];

   //--- Price quotes
   float op = (float) iOpen("EURUSD",PERIOD_H1,0);
   float hi = (float) iHigh("EURUSD",PERIOD_H1,0);
   float lo = (float) iLow("EURUSD",PERIOD_H1,0);
   float cl = (float) iClose("EURUSD",PERIOD_H1,0);

   //--- ONNX inputs
   vectorf fast_inputs = {op,hi,lo,cl,a};
   vectorf slow_inputs = {op,hi,lo,cl,b};

   Print("Fast inputs: ",fast_inputs);
   Print("Slow inputs: ",slow_inputs);

   //--- Inference
   OnnxRun(ma_5_model,ONNX_DATA_TYPE_FLOAT,fast_inputs,ma_5_forecast);
   OnnxRun(ma_5_height_model,ONNX_DATA_TYPE_FLOAT,fast_inputs,ma_5_height_forecast);
   OnnxRun(ma_60_model,ONNX_DEFAULT,slow_inputs,ma_60_forecast);
   OnnxRun(ma_60_height_model,ONNX_DATA_TYPE_FLOAT,fast_inputs,ma_60_height_forecast);
  }


//+---------------------------------------------------------------+
//| Update channel                                                |
//+---------------------------------------------------------------+
void update_channel(double new_high, double new_low)
  {
   //--- Move the channel to the last breakout
   channel_high = new_high;
   channel_low  = new_low;
   //--- Delete the old break out
   ObjectDelete(0,"Channel High");
   ObjectDelete(0,"Channel Low");
   //--- Mark the new breakout
   ObjectCreate(0,"Channel High",OBJ_HLINE,0,0,channel_high);
   ObjectCreate(0,"Channel Low",OBJ_HLINE,0,0,channel_low);
  }

//+---------------------------------------------------------------+
//| Manage setup                                                  |
//+---------------------------------------------------------------+
void manage_setup(void)
  {
   Print("Managing Position");
   //--- Check if the position exists
   if(PositionSelect("EURUSD"))
     {
      Print("Position Found");
      initial_sl = PositionGetDouble(POSITION_SL);
     }

   //--- Was our last trade a buy?
   if(last_trade_state == 1)
     {
      Print("Position Buy");
      double new_sl = (ask - (atr[0] * atr_multiple));
      Print("Initial: ",initial_sl,"\nNew: ",new_sl);
      if((initial_sl < new_sl) || (initial_sl == 0))
        {
         Trade.PositionModify("EURUSD",new_sl,0);
         Print("DONE");
        }
     }

   if(last_trade_state == -1)
     {
      Print("Position Sell");
      double new_sl = (bid + (atr[0] * atr_multiple));
      Print("Initial: ",initial_sl,"\nNew: ",new_sl);
      if((initial_sl > new_sl) || (initial_sl == 0))
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
   if(valid_setup())
     {
      //--- Both models are forecasting rising prices
      if((c < (ma_60_forecast[0] + ma_60_height_forecast[0])) && (c < (ma_5_forecast[0] + ma_5_height_forecast[0])))
        {
         if(last_trade_state != 1)
           {
            Trade.Buy(vol,"EURUSD",ask,0,0,"Volatility Doctor");
            initial_sl = channel_low;
            last_trade_state = 1;
            last_cross_over_state = current_state;
           }
        }

      //--- Both models are forecasting falling prices
      if((c > (ma_60_forecast[0] + ma_60_height_forecast[0])) && (c > (ma_5_forecast[0] + ma_5_height_forecast[0])))
        {
         if(last_trade_state != -1)
           {
            Trade.Sell(vol,"EURUSD",bid,0,0,"Volatility Doctor");
            initial_sl = channel_high;
            last_trade_state = -1;
            last_cross_over_state = current_state;
           }
        }
     }

//--- We will only reset the last trade state if the moving average state has crossed in the opposite direction
   if((PositionsTotal() == 0) && (current_state * last_cross_over_state != 0) && (current_state != last_cross_over_state))
      last_cross_over_state = 0;

   double ma_5_f  = (ma_5_forecast[0] + ma_5_height_forecast[0]);
   double ma_60_f = (ma_60_forecast[0] + ma_60_height_forecast[0]);

   Comment("MA 5 Forecast: ",ma_5_f,"\nMA 60 Forecast: ",ma_60_f,"\nLast Cross: ",last_cross_over_state,"\nO: ",o,"\nH: ",h,"\nL: ",l,"\nC:",c,"\nC H: ",channel_high,"\nC L:",channel_low,"\nBias: ",bias,"\nBias Level: ",bias_level,"\nConfirmation: ",confirmation,"\nMA F: ",ma_f[0],"\nMA S: ",ma_s[0],"\nLast Trade: ",last_trade_state);
  }



//+---------------------------------------------------------------+
//| Do we have a valid setup?                                     |
//+---------------------------------------------------------------+
bool valid_setup(void)
  {
   return(((confirmation == 1) && (bias == -1)  && (current_state != last_cross_over_state)) || ((confirmation == 1) && (bias == 1) && (current_state != last_cross_over_state)));
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
