//+------------------------------------------------------------------+
//|                                                    Version 5.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| System resources                                                 |
//+------------------------------------------------------------------+
#resource "\\Files\\EURUSD D1 Iso 1 RandomForestRegressor.onnx" as const uchar onnx_buffer[];

//+------------------------------------------------------------------+
//| System constants                                                 |
//+------------------------------------------------------------------+
//--- Column Mean Values
const float Z1[] = { (float)1.18132371,  (float)1.18577335,  (float)1.17706596,  (float)1.1812953 ,  (float)1.20514458,
                     (float)1.18303579,  (float)1.16092701,  (float)48.60276562};
//--- Column Standard Deviation
const float Z2[] = { (float)0.09684736,  (float)0.09665192,  (float)0.09686825,  (float)0.09684589,  (float)0.09614994,
                     (float)0.09556366,  (float)0.09612185,  (float)11.10783131};

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
#define ONNX_INPUTS   8
#define ONNX_OUTPUTS  1

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int      bb_handler,rsi_handler,atr_handler;
double   bb_upper[],bb_mid[],bb_lower[],rsi[],atr[];
long     onnx_model;
vectorf  onnx_outputs;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//--- Set up the ONNX model
   onnx_model = OnnxCreateFromBuffer(onnx_buffer,ONNX_DATA_TYPE_FLOAT);

//--- Define the model I/O shapes
   ulong onnx_input_shape[] = {1,ONNX_INPUTS};
   ulong onnx_output_shape[] = {1,ONNX_OUTPUTS};
   
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
           
//--- Validate the ONNX model
   else
      if(!OnnxSetInputShape(onnx_model,0,onnx_input_shape))
        {
         Comment("Failed to define the ONNX model input shape: ",GetLastError());
         return(INIT_FAILED);
        }

      else
         if(!OnnxSetOutputShape(onnx_model,0,onnx_output_shape))
           {
            Comment("Failed to define the ONNX model output shape: ",GetLastError());
            return(INIT_FAILED);
           }

         else
            if(onnx_model == INVALID_HANDLE)
              {
               Comment("Error occured setting up the ONNX model: ",GetLastError());
               return(INIT_FAILED);
              }

            //--- Final settings
            else
              {
              //--- Initialize the ONNX model outputs with a zero
              onnx_outputs = vectorf::Zeros(ONNX_OUTPUTS);
              
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
   OnnxRelease(onnx_model);
   Comment("");
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
      
      //--- Prepare our ONNX model inputs
      vectorf onnx_inputs = {(float)iOpen(SYMBOL,TF_MAIN,SHIFT),
                             (float)iHigh(SYMBOL,TF_MAIN,SHIFT),
                             (float)iLow(SYMBOL,TF_MAIN,SHIFT),
                             (float)iClose(SYMBOL,TF_MAIN,SHIFT),
                             (float)bb_upper[0],
                             (float)bb_mid[0],
                             (float)bb_lower[0],
                             (float)rsi[0]};
      
      //--- Scale the model inputs appropriately
      for(int i = 0; i < ONNX_INPUTS;i++)
         {
            onnx_inputs[i] = ((onnx_inputs[i]-Z1[i])/Z2[i]);
         }
                  
      //--- Obtain a forecast from our ONNX model
      OnnxRun(onnx_model,ONNX_DATA_TYPE_FLOAT,onnx_inputs,onnx_outputs);
      Comment("EURUSD Model Forecast: ",onnx_outputs);

      //--- Update current price levels
      double close = iClose(SYMBOL,TF_MAIN,SHIFT);

      //--- If we have no open positions
      if(PositionsTotal() == 0)
        {
         //--- Check for our trading signal
         if(onnx_outputs[0] < 0.5)  
           {
            Trade.Sell(TradeHelper.MinVolume(),TradeHelper.GetSymbol(),TradeHelper.GetBid(),TradeHelper.GetBid() + (atr[0] * ATR_MULTIPLE),TradeHelper.GetBid() - (atr[0] * ATR_MULTIPLE),"");
           }

         else
            if(onnx_outputs[0] > 0.5)
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
#undef ONNX_INPUTS
#undef ONNX_OUTPUTS
//+------------------------------------------------------------------+