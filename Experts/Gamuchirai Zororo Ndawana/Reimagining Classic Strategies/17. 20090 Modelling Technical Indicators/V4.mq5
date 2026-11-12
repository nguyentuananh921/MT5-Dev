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
#resource "\\Files\\EURUSD 2022-2025 R V4.onnx" as const uchar onnx_proto[];

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
//--- Our handlers for our indicators
int ma_handle,ma_o_handle,ma_h_handle,ma_l_handle;
//--- Data structures to store the readings from our indicators
double ma_reading[],ma_o_reading[],ma_h_reading[],ma_l_reading[];


#define MA_PERIOD 5
#define HORIZON 5
#define MA_TYPE MODE_SMA

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
//---Setup our technical indicators
   ma_handle   = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_CLOSE);
   ma_o_handle = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_OPEN);
   ma_h_handle = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_HIGH);
   ma_l_handle = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_LOW);


   if(!onnx_model.DefineOnnxInputShape(0,1,22))
     {
      Print("Failed to specify ONNX input shape");
      return(INIT_FAILED);
     }

   if(!onnx_model.DefineOnnxOutputShape(0,2,1))
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
         CopyBuffer(ma_handle,0,0,HORIZON*2,ma_reading);
         ArraySetAsSeries(ma_reading,true);
         CopyBuffer(ma_o_handle,0,0,HORIZON*2,ma_o_reading);
         ArraySetAsSeries(ma_o_reading,true);
         CopyBuffer(ma_h_handle,0,0,HORIZON*2,ma_h_reading);
         ArraySetAsSeries(ma_h_reading,true);
         CopyBuffer(ma_l_handle,0,0,HORIZON*2,ma_l_reading);
         ArraySetAsSeries(ma_l_reading,true);

         onnx_model.DefineInputValues(0,(float)  iOpen(Symbol(),PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(1,(float)  iHigh(Symbol(),PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(2,(float)  iLow(Symbol(),PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(3,(float)  iClose(Symbol(),PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(4,(float)  ma_o_reading[0]);
         onnx_model.DefineInputValues(5,(float)  ma_h_reading[0]);
         onnx_model.DefineInputValues(6,(float)  ma_l_reading[0]);
         onnx_model.DefineInputValues(7,(float)  ma_reading[0]);
         onnx_model.DefineInputValues(8,(float)  iOpen(_Symbol,PERIOD_CURRENT,0)   - iOpen(_Symbol,PERIOD_CURRENT,(0 + HORIZON)));
         onnx_model.DefineInputValues(9,(float)  iHigh(_Symbol,PERIOD_CURRENT,0)   - iHigh(_Symbol,PERIOD_CURRENT,(0 + HORIZON)));
         onnx_model.DefineInputValues(10,(float) iLow(_Symbol,PERIOD_CURRENT,0)    - iLow(_Symbol,PERIOD_CURRENT,(0 + HORIZON)));
         onnx_model.DefineInputValues(11,(float) iClose(_Symbol,PERIOD_CURRENT,0)  - iClose(_Symbol,PERIOD_CURRENT,(0 + HORIZON)));
         onnx_model.DefineInputValues(12,(float) ma_o_reading[0] - ma_o_reading[(0 + HORIZON)]);
         onnx_model.DefineInputValues(13,(float) ma_h_reading[0] - ma_h_reading[(0 + HORIZON)]);
         onnx_model.DefineInputValues(14,(float) ma_l_reading[0] - ma_l_reading[(0 + HORIZON)]);
         onnx_model.DefineInputValues(15,(float) ma_reading[0] - ma_reading[(0 + HORIZON)]);
         onnx_model.DefineInputValues(16,(float) iOpen(_Symbol,PERIOD_CURRENT,0)  - iClose(_Symbol,PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(17,(float) iHigh(_Symbol,PERIOD_CURRENT,0)   - iLow(_Symbol,PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(18,(float) iOpen(_Symbol,PERIOD_CURRENT,0) - iHigh(_Symbol,PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(19,(float) iOpen(_Symbol,PERIOD_CURRENT,0) - iLow(_Symbol,PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(20,(float) iClose(_Symbol,PERIOD_CURRENT,0) - iHigh(_Symbol,PERIOD_CURRENT,0));
         onnx_model.DefineInputValues(21,(float) iClose(_Symbol,PERIOD_CURRENT,0) - iLow(_Symbol,PERIOD_CURRENT,0));

         double padding = (atr[0]*1.5);

         if(onnx_model.Predict())
           {

            if(ma_reading[0]>ma_o_reading[0])
              {
               if(onnx_model.GetPrediction(1)  >  onnx_model.GetPrediction(0))
                 {
                  Trade.Buy(trade.MinVolume(),Symbol(),trade.GetAsk(),trade.GetBid()-padding,trade.GetBid()+padding,"");
                 }
              }

            if(ma_reading[0]<ma_o_reading[0])
              {
               if(onnx_model.GetPrediction(1) <  onnx_model.GetPrediction(0))
                 {
                  Trade.Sell(trade.MinVolume(),Symbol(),trade.GetBid(),trade.GetAsk()+padding,trade.GetAsk()-padding,"");
                 }
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
//+------------------------------------------------------------------+