//+------------------------------------------------------------------+
//|                                         EURGBP Stochastic AI.mq5 |
//|                                        Gamuchirai Zororo Ndawana |
//|                          https://www.mql5.com/en/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Zororo Ndawana"
#property link      "https://www.mql5.com/en/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Load the AI Modules                                              |
//+------------------------------------------------------------------+
#resource "\\Files\\EURGBP MA.onnx" as  const uchar ma_onnx_buffer[];
#resource "\\Files\\EURGBP ATR.onnx" as  const uchar atr_onnx_buffer[];
#resource "\\Files\\EURGBP Stoch.onnx" as  const uchar stoch_onnx_buffer[];

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double vol,bid,ask;
long atr_model,ma_model,stoch_model;
vectorf atr_forecast = vectorf::Zeros(1),ma_forecast = vectorf::Zeros(1),stoch_forecast = vectorf::Zeros(1);
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

   Comment("Loaded Succesfully!");
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
   OnnxRelease(atr_model);
   OnnxRelease(ma_model);
   OnnxRelease(stoch_model);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Fetch updated quotes
   update();

//--- Only on new candles
   static datetime time_stamp;
   datetime current_time = iTime(_Symbol,PERIOD_M5,0);
   if(time_stamp != current_time)
     {
      time_stamp = current_time;
      //--- If we have no open positions, check for a setup
      if(PositionsTotal() == 0)
        {
         find_setup();
        }
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

//--- Create our onnx models
   atr_model   = OnnxCreateFromBuffer(atr_onnx_buffer,ONNX_DEFAULT);
   ma_model    = OnnxCreateFromBuffer(ma_onnx_buffer,ONNX_DEFAULT);
   stoch_model = OnnxCreateFromBuffer(stoch_onnx_buffer,ONNX_DEFAULT);

//--- Validate our models
   if(atr_model == INVALID_HANDLE || ma_model == INVALID_HANDLE || stoch_model == INVALID_HANDLE)
     {
      Comment("[ERROR] Failed to load AI modules: ",GetLastError());
     }

//--- Set the sizes of our ONNX models
   ulong atr_input_shape[]  = {1,1};
   ulong ma_input_shape[]   = {1,2};
   ulong sto_input_shape[]  = {1,3};

   if(!(OnnxSetInputShape(atr_model,0,atr_input_shape)) || !(OnnxSetInputShape(ma_model,0,ma_input_shape)) || !(OnnxSetInputShape(stoch_model,0,sto_input_shape)))
     {
      Comment("[ERROR] Failed to load AI modules: ",GetLastError());
     }

   ulong output_shape[] = {1,1};

   if(!(OnnxSetOutputShape(atr_model,0,output_shape)) || !(OnnxSetOutputShape(ma_model,0,output_shape)) || !(OnnxSetOutputShape(stoch_model,0,output_shape)))
     {
      Comment("[ERROR] Failed to load AI modules: ",GetLastError());
     }
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
//--- Predict future ATR values
   vectorf atr_model_input = vectorf::Zeros(1);
   atr_model_input[0] = (float) atr[0];

//--- Predicting future price using the stochastic oscilator
   vectorf sto_model_input = vectorf::Zeros(3);

   if(stochastic[0] > 80)
     {
      sto_model_input[0] = 1;
      sto_model_input[1] = 0;
      sto_model_input[2] = 0;
     }

   else
      if(stochastic[0] < 20)
        {
         sto_model_input[0] = 0;
         sto_model_input[1] = 1;
         sto_model_input[2] = 0;
        }

      else
        {
         sto_model_input[0] = 0;
         sto_model_input[1] = 0;
         sto_model_input[2] = 1;
        }

//--- Finally prepare the moving average forecast
   vectorf ma_inputs = vectorf::Zeros(2);
   if(fast_ma[0] > slow_ma[0])
     {
      ma_inputs[0] = 1;
      ma_inputs[1] = 0;
     }

   else
     {
      ma_inputs[0] = 0;
      ma_inputs[1] = 1;
     }

   OnnxRun(stoch_model,ONNX_DEFAULT,sto_model_input,stoch_forecast);
   OnnxRun(atr_model,ONNX_DEFAULT,atr_model_input,atr_forecast);
   OnnxRun(ma_model,ONNX_DEFAULT,ma_inputs,ma_forecast);

   Comment("ATR Forecast: ",atr_forecast[0],"\nStochastic Forecast: ",stoch_forecast[0],"\nMA Forecast: ",ma_forecast[0]);

//--- Can we buy?
   if((ma_forecast[0] > 0) && (stoch_forecast[0] > 0))
     {
      Trade.Buy(vol,"EURGBP",ask,(ask - (atr[0] * atr_multiple)),(ask + (atr_forecast[0] * atr_multiple)),"EURGBP");
     }

//--- Can we sell?
   if((ma_forecast[0] < 0) && (stoch_forecast[0] < 0))
     {
      Trade.Sell(vol,"EURGBP",bid,(bid + (atr[0] * atr_multiple)),(bid - (atr_forecast[0] * atr_multiple)),"EURGBP");
     }
  }
//+------------------------------------------------------------------+
