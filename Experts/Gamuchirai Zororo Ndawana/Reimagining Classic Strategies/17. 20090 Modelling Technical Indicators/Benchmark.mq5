//+------------------------------------------------------------------+
//|                                                    Benchmark.mq5 |
//|                                               Gamuchirai Ndawana |
//|                    https://www.mql5.com/en/users/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Ndawana"
#property link      "https://www.mql5.com/en/users/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| System resources                                                 |
//+------------------------------------------------------------------+
#resource "\\Files\\EURUSD 2022-2025 LR.onnx" as const uchar onnx_proto[];

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <VolatilityDoctor\Time\Time.mqh>
#include <VolatilityDoctor\ONNX\ONNXFloat.mqh>
#include <VolatilityDoctor\Trade\TradeInfo.mqh>

CTrade    Trade;
Time      *time;
TradeInfo *trade;
ONNXFloat *onnx_model;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int atr_handler;
double atr[];
float prediction;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   onnx_model = new ONNXFloat(onnx_proto);
   trade      = new TradeInfo(Symbol(),PERIOD_CURRENT);
   time       = new Time(Symbol(),PERIOD_D1);
   atr_handler = iATR(Symbol(),PERIOD_CURRENT,14);

   if(!onnx_model.DefineOnnxInputShape(0,1,4))
     {
      Print("Failed to specify ONNX input shape");
      return(INIT_FAILED);
     }

   if(!onnx_model.DefineOnnxOutputShape(0,1,1))
     {
      Print("Failed to specify ONNX output shape");
      return(INIT_FAILED);
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete onnx_model;
   delete time;
   delete trade;
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(time.NewCandle())
     {
      if(PositionsTotal()==0)
        {
         CopyBuffer(atr_handler,0,0,1,atr);
         onnx_model.DefineInputValues(0,(float) iOpen(Symbol(),PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(1,(float) iHigh(Symbol(),PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(2,(float) iLow(Symbol(),PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(3,(float) iClose(Symbol(),PERIOD_CURRENT,0));
         double padding = (atr[0]*1.5);

         if(onnx_model.Predict())
           {
            prediction = onnx_model.GetPrediction(0);
            Print("Onnx Prediction:\n",prediction);

            if(prediction > iClose(Symbol(),PERIOD_CURRENT,0))
              {
               Trade.Buy(trade.MinVolume(),Symbol(),trade.GetAsk(),trade.GetBid()-padding,trade.GetBid()+padding,"");
              }

            if(prediction < iClose(Symbol(),PERIOD_CURRENT,0))
              {
               Trade.Sell(trade.MinVolume(),Symbol(),trade.GetBid(),trade.GetAsk()+padding,trade.GetAsk()-padding,"");
              }
           }
         else
           {
            Print("Failed to obtain a prediction from our model: ",GetLastError());
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+