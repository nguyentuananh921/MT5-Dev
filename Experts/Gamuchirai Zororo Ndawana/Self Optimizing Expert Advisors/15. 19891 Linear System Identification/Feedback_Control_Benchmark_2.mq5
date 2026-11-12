//+------------------------------------------------------------------+
//|                                  Feedback Control Benchmark .mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| System constants                                                 |
//+------------------------------------------------------------------+
#define SYMBOL Symbol()
#define MA_PERIOD 42
#define MA_SHIFT 0
#define MA_MODE MODE_EMA
#define MA_APPLIED_PRICE PRICE_CLOSE
#define SYSTEM_TIME_FRAME PERIOD_D1
#define MIN_VOLUME SymbolInfoDouble(SYMBOL,SYMBOL_VOLUME_MIN)
#define OBSERVATIONS 90
#define FEATURES     7
#define MODEL_INPUTS 8  

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ma[],atr[];
double ask,bid,open,high,low,close,padding;
int    ma_handler,atr_handler,scenes;
bool   forecast;
matrix snapshots,b,X,y,U,S,VT,current_forecast;
vector s;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize the indicator
   ma_handler = iMA(SYMBOL,SYSTEM_TIME_FRAME,MA_PERIOD,MA_SHIFT,MA_MODE,MA_APPLIED_PRICE);
   atr_handler = iATR(SYMBOL,SYSTEM_TIME_FRAME,14);

//--- Prepare global variables
   forecast = false;
   snapshots = matrix::Zeros(FEATURES,OBSERVATIONS);
   scenes = -1;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release the indicator
   IndicatorRelease(ma_handler);
   IndicatorRelease(atr_handler);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check if a new candle has formed
   datetime current_time = iTime(Symbol(),SYSTEM_TIME_FRAME,0);
   static datetime time_stamp;

   if(current_time != time_stamp)
     {
      //--- Update the time
      time_stamp = current_time;
      scenes = scenes+1;

      //--- Check how many scenes have elapsed
      if(scenes == (OBSERVATIONS-1))
        {
         forecast   = true;
        }

      //--- If we have no open positions
      if(PositionsTotal()==0)
        {
         //--- Update indicator buffers
         CopyBuffer(ma_handler,0,1,1,ma);
                     CopyBuffer(atr_handler,0,0,1,atr);
            padding = atr[0] * 2;

         //--- Fetch current market prices
         ask = SymbolInfoDouble(SYMBOL,SYMBOL_ASK);
         bid = SymbolInfoDouble(SYMBOL,SYMBOL_BID);
         close = iClose(SYMBOL,SYSTEM_TIME_FRAME,1);

         //--- Do we need to forecast?
         if(!forecast)
           {
            //--- Check trading signal
            check_signal();
           }

         //--- We need a forecast
         else
            if(forecast)
              {
               model_forecast();
              }
        }

      //--- Take a snapshot
      if(!forecast)
         take_snapshot();

      //--- Otherwise, we have positions open
      else
        {
         //--- Let the model decide if we should close or hold our position
         if(forecast)
            model_forecast();

         //--- Otherwise record all observations on the performance of the application
         else
            if(!forecast)
               take_snapshot();
        }
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Check for our trading signal                                     |
//+------------------------------------------------------------------+
void check_signal(void)
  {
   if(PositionsTotal() == 0)
     {
      if(close > ma[0])
        {
         Trade.Buy(MIN_VOLUME,SYMBOL,ask,ask-padding,ask+padding);
        }

      if(close < ma[0])
        {
         Trade.Sell(MIN_VOLUME,SYMBOL,bid,ask+padding,ask-padding);
        }
     }
  }

//+------------------------------------------------------------------+
//| Obtain a forecast from our model                                 |
//+------------------------------------------------------------------+
void model_forecast(void)
  {

   Print(scenes);
   Print(snapshots);

//--- Create a copy of the current snapshots
   matrix temp;
   temp.Copy(snapshots);
   snapshots = matrix::Zeros(FEATURES,scenes+1);

   for(int i=0;i<FEATURES;i++)
     {
      snapshots.Row(temp.Row(i),i);
     }

//--- Attach the latest readings to the end
   take_snapshot();

//--- Obtain a forecast for our trading signal
//--- Define the model inputs and outputs

//--- Implement the inputs and outputs
   X = matrix::Zeros(FEATURES+1,scenes);
   y = matrix::Zeros(1,scenes);

//--- The first row is the intercept.
   X.Row(vector::Ones(scenes),0);

//--- Filling in the remaining rows
   for(int i =0; i<scenes;i++)
     {
      //--- Filling in the inputs
      X[1,i] = snapshots[0,i]; //Open
      X[2,i] = snapshots[1,i]; //High
      X[3,i] = snapshots[2,i]; //Low
      X[4,i] = snapshots[3,i]; //Close
      X[5,i] = snapshots[4,i]; //Moving average
      X[6,i] = snapshots[5,i]; //Account equity
      X[7,i] = snapshots[6,i]; //Account balance

      //--- Filling in the target
      y[0,i] = snapshots[6,i+1];//Future account balance
     }

   Print("Finished implementing the inputs and target: ");
   Print("Snapshots:\n",snapshots);
   Print("X:\n",X);
   Print("y:\n",y);

//--- Singular value decomposition
   X.SingularValueDecompositionDC(SVDZ_S,s,U,VT);

//--- Transform s to S, that is the vector to a diagonal matrix
   S = matrix::Zeros(s.Size(),s.Size());
   S.Diag(s,0);

//--- Done
   Print("U");
   Print(U);
   Print("S");
   Print(s);
   Print(S);
   Print("VT");
   Print(VT);

//--- Learn the system's coefficients

//--- Check if S is invertible
   if(S.Rank() != 0)
     {
      //--- Invert S
      matrix S_Inv = S.Inv();
      Print("S Inverse: ",S_Inv);

      //--- Obtain psuedo inverse solution
      b = VT.Transpose().MatMul(S_Inv);
      b = b.MatMul(U.Transpose());
      b = y.MatMul(b);

      //--- Prepare the current inputs
      matrix inputs = matrix::Ones(MODEL_INPUTS,1);
      for(int i=1;i<MODEL_INPUTS;i++)
        {
         inputs[i,0] = snapshots[i-1,scenes];
        }

      //--- Done
      Print("Coefficients:\n",b);
      Print("Inputs:\n",inputs);
      current_forecast = b.MatMul(inputs);
      Print("Forecast:\n",current_forecast[0,0]);

      //--- The next trade may be expected to be profitable
      if(current_forecast[0,0] > AccountInfoDouble(ACCOUNT_BALANCE))
        {
         //--- Feedback
         Print("Next trade expected to be profitable. Checking for trading singals.");
         //--- Check for our trading signal
         check_signal();
        }
        
        //--- Next trade may be expected to be unprofitable
        else
         {
            Print("Next trade expected to be unprofitable. Waiting for better market conditions");
         }
     }

//--- S is not invertible!
   else
     {
      //--- Error
      Print("[Critical Error] Singular values are not invertible.");
     }
  }

//+------------------------------------------------------------------+
//| Take a snapshot of the market                                    |
//+------------------------------------------------------------------+
void take_snapshot(void)
  {
//--- Record system state
   snapshots[0,scenes]=iOpen(SYMBOL,SYSTEM_TIME_FRAME,1); //Open
   snapshots[1,scenes]=iHigh(SYMBOL,SYSTEM_TIME_FRAME,1); //High
   snapshots[2,scenes]=iLow(SYMBOL,SYSTEM_TIME_FRAME,1);  //Low
   snapshots[3,scenes]=iClose(SYMBOL,SYSTEM_TIME_FRAME,1);//Close
   snapshots[4,scenes]=ma[0];                             //Moving average
   snapshots[5,scenes]=AccountInfoDouble(ACCOUNT_EQUITY); //Equity
   snapshots[6,scenes]=AccountInfoDouble(ACCOUNT_BALANCE);//Balance

   Print("Scene: ",scenes);
   Print(snapshots);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Undefine system constants                                        |
//+------------------------------------------------------------------+
#undef SYMBOL
#undef SYSTEM_TIME_FRAME
#undef MA_APPLIED_PRICE
#undef MA_MODE
#undef MA_SHIFT
#undef MIN_VOLUME
#undef MODEL_INPUTS
#undef FEATURES
#undef OBSERVATIONS
//+------------------------------------------------------------------+