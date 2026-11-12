//+------------------------------------------------------------------+
//|                                               Stochastic AI.mq5  |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#resource "\\Files\\EURUSD Stochastic GBR AI.onnx" as const uchar onnx_proto[];

//+------------------------------------------------------------------+
//| Technical Indicators                                             |
//+------------------------------------------------------------------+
int      atr_handler,stoch_handler;
double   atr_reading[],stoch_main[],stoch_signal[];
double   stoch_o,stoch_h,stoch_l;
vector   high,low,open,close;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double  ask,bid;
vectorf model_inputs,model_outputs;
long    model;

//+------------------------------------------------------------------+
//| System Definitions                                               |
//+------------------------------------------------------------------+
#define MODEL_INPUT_SHAPE  10
#define MODEL_OUTPUT_SHAPE 1

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
//--- Setup our indicators
   atr_handler     = iATR("EURUSD",PERIOD_D1,14);
   stoch_handler   = iStochastic(Symbol(),PERIOD_CURRENT,5,3,3,MODE_EMA,STO_LOWHIGH);
   stoch_o = 22.69153;
   stoch_h = 98.551023;
   stoch_l = 1.372058;

//--- Setup the ONNX model
   model = OnnxCreateFromBuffer(onnx_proto,ONNX_DATA_TYPE_FLOAT);

//--- Define the model parameter shape
   ulong input_shape[] = {1,MODEL_INPUT_SHAPE};
   ulong output_shape[] = {1,MODEL_OUTPUT_SHAPE};

   if(!OnnxSetInputShape(model,0,input_shape))
     {
      Print("ONNX Model Error: Incorrect Input Shape ",GetLastError());
      return(INIT_FAILED);
     }

   if(!OnnxSetOutputShape(model,0,output_shape))
     {
      Print("ONNX Model Error: Incorrect Output Shape ",GetLastError());
      return(INIT_FAILED);
     }

   model_inputs = vectorf::Zeros(MODEL_INPUT_SHAPE);
   model_outputs = vectorf::Zeros(MODEL_OUTPUT_SHAPE);

   if(model != INVALID_HANDLE)
     {
      return(INIT_SUCCEEDED);
     }

//---
   return(INIT_FAILED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Free up memory we are no longer using when the application is off
   IndicatorRelease(atr_handler);
   OnnxRelease(model);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- When price levels change

   datetime current_time = iTime("EURUSD",PERIOD_D1,0);
   static datetime  time_stamp;

//--- Update the time
   if(current_time != time_stamp)
     {
     
      time_stamp = current_time;

      //--- Calculate the middle of the trading range produced over the last business cycle
      high.CopyRates(Symbol(),PERIOD_D1,COPY_RATES_HIGH,0,90);
      low.CopyRates(Symbol(),PERIOD_D1,COPY_RATES_LOW,0,90);
      double mid = ((high.Mean() + low.Mean())/2);

      //--- Calculate the current trend on the lower time frame
      open.CopyRates(Symbol(),PERIOD_H1,COPY_RATES_OPEN,0,12);
      close.CopyRates(Symbol(),PERIOD_H1,COPY_RATES_CLOSE,0,12);

      //--- Fetch indicator current readings
      CopyBuffer(atr_handler,0,0,1,atr_reading);
      CopyBuffer(stoch_handler,0,0,1,stoch_main);
      CopyBuffer(stoch_handler,1,0,1,stoch_signal);

      //--- Setting model inputs
      stoch_h = (stoch_h < stoch_main[0]) ? stoch_main[0] : stoch_h;
      stoch_l = (stoch_l > stoch_main[0]) ? stoch_main[0] : stoch_l;

      model_inputs[0] = (float)(stoch_main[0] - stoch_signal[0]);
      model_inputs[1] = (float)(((stoch_main[0] + stoch_signal[0])/2));
      model_inputs[2] = (float)((stoch_main[0] - 80));
      model_inputs[3] = (float)((stoch_main[0] - 20));
      model_inputs[4] = (float)(stoch_o);
      model_inputs[5] = (float)(stoch_h);
      model_inputs[6] = (float)(stoch_l);
      model_inputs[7] = (float)(stoch_o - stoch_main[0]);
      model_inputs[8] = (float)(stoch_h - stoch_main[0]);
      model_inputs[9] = (float)(stoch_l - stoch_main[0]);

      ask = SymbolInfoDouble("EURUSD",SYMBOL_ASK);
      bid = SymbolInfoDouble("EURUSD",SYMBOL_BID);

      //--- If we have no open positions
      if(PositionsTotal() == 0)
        {

         if(!(OnnxRun(model,ONNX_DATA_TYPE_FLOAT,model_inputs,model_outputs)))
           {
            Comment("Failed to obtain a forecast from our model: ",GetLastError());
           }

         else
           {
            Comment("Forecast: ",model_outputs);

            //--- Trading rules
            if((model_outputs[0] > stoch_main[0]) && (stoch_main[0] > 80) && (iClose(Symbol(),PERIOD_D1,0) > mid) && (open.Mean() < close.Mean()))
              {
               //--- Buy signal
               Trade.Buy(0.01,"EURUSD",ask,ask-(atr_reading[0] * 2),ask+(atr_reading[0] * 2),"");
              }

            else
               if((model_outputs[0] < stoch_main[0]) && (stoch_main[0] < 20) && (iClose(Symbol(),PERIOD_D1,0) < mid) && (open.Mean() > close.Mean()))
                 {
                  //--- Sell signal
                  Trade.Sell(0.01,"EURUSD",bid,bid+(atr_reading[0] * 2),bid-(atr_reading[0] * 2),"");
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+

#undef MODEL_INPUT_SHAPE
#undef MODEL_OUTPUT_SHAPE
//+------------------------------------------------------------------+