//+------------------------------------------------------------------+
//|                                                   MSA Test 1.mq5 |
//|                                               Gamuchirai Ndawana |
//|                    https://www.mql5.com/en/users/gamuchiraindawa |
//+------------------------------------------------------------------+
#property copyright "Gamuchirai Ndawana"
#property link      "https://www.mql5.com/en/users/gamuchiraindawa"
#property version   "1.00"

//+------------------------------------------------------------------+
//| ONNX Model                                                       |
//+------------------------------------------------------------------+
#resource "\\Files\\EURUSD NN MSA.onnx" as uchar onnx_buffer[];

//+------------------------------------------------------------------+
//| ONNX Parameters                                                  |
//+------------------------------------------------------------------+
double Z1[] = { 1.18932220e+00,  1.19077958e+00,  1.18786462e+00,  1.18931542e+00,
                1.18994040e+00,  1.18994674e+00,  4.94395259e+01, -4.99204879e-04,
                -5.00701302e-04, -4.97575935e-04, -4.98995739e-04, -4.70848300e-04,
                -4.70289373e-04, -1.84697724e-02
                };

double Z2[] = {1.09599015e-01, 1.09698934e-01, 1.09479324e-01, 1.09593123e-01,
               1.09413744e-01, 1.09419007e-01, 1.00452009e+01, 1.31269558e-02,
               1.31336302e-02, 1.31513465e-02, 1.31174740e-02, 6.88794916e-03,
               6.89036979e-03, 1.28550006e+01
              };

//+------------------------------------------------------------------+
//| System constants                                                 |
//+------------------------------------------------------------------+
#define MA_SHIFT         0
#define MA_TYPE          MODE_EMA
#define RSI_PRICE        PRICE_CLOSE
#define ONNX_INPUTS      14
#define ONNX_OUTPUTS     2
#define HORIZON 38

//+------------------------------------------------------------------+
//| User defined enumerator                                          |
//+------------------------------------------------------------------+
enum STRATEGY_MODE
  {
   MODE_ONE   = 0, //Voting Policy
   MODE_TWO   = 1, //RSI Buy & MA Sell
   MODE_THREE = 2  //MA Sell & RSI Buy
  };

//+------------------------------------------------------------------+
//| Strategy Parameters                                              |
//+------------------------------------------------------------------+
int             MA_PERIOD                       =        100;  //Moving Average Period
int             RSI_PERIOD                      =         24;  //RSI Period
ENUM_TIMEFRAMES STRATEGY_TIME_FRAME             =  PERIOD_H3;  //Strategy Timeframe
int             HOLDING_PERIOD                  =         38;  //Position Maturity Period
STRATEGY_MODE   USER_MODE                       =          0;  //Operation Mode For Our Strategy

//+------------------------------------------------------------------+
//| Dependencies                                                     |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <VolatilityDoctor\Time\Time.mqh>
#include <VolatilityDoctor\Trade\TradeInfo.mqh>
#include <VolatilityDoctor\Strategies\OpenCloseMACrossover.mqh>
#include <VolatilityDoctor\Strategies\RSIMidPoint.mqh>

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
//--- Custom Types
CTrade               Trade;
Time                 *TradeTime;
TradeInfo            *TradeInformation;
RSIMidPoint          *RSIMid;
OpenCloseMACrossover *MACross;
long                 onnx_model;
vectorf onnx_output;

//--- Our handlers for our indicators
int ma_handle,ma_o_handle,rsi_handle;

//--- Data structures to store the readings from our indicators
double ma_reading[],ma_o_reading[],rsi_reading[];

//--- System Types
int                  position_timer;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Create dynamic instances of our custom types
   TradeTime        = new Time(Symbol(),STRATEGY_TIME_FRAME);
   TradeInformation = new TradeInfo(Symbol(),STRATEGY_TIME_FRAME);
   MACross          = new OpenCloseMACrossover(Symbol(),STRATEGY_TIME_FRAME,MA_PERIOD,MA_SHIFT,MA_TYPE);
   RSIMid           = new RSIMidPoint(Symbol(),STRATEGY_TIME_FRAME,RSI_PERIOD,RSI_PRICE);
   onnx_model       = OnnxCreateFromBuffer(onnx_buffer,ONNX_DEFAULT);
   onnx_output      = vectorf::Zeros(ONNX_OUTPUTS);

//---Setup our technical indicators
   ma_handle        = iMA(_Symbol,STRATEGY_TIME_FRAME,MA_PERIOD,0,MA_TYPE,PRICE_CLOSE);
   ma_o_handle      = iMA(_Symbol,STRATEGY_TIME_FRAME,MA_PERIOD,0,MA_TYPE,PRICE_OPEN);
   rsi_handle       = iRSI(_Symbol,STRATEGY_TIME_FRAME,RSI_PERIOD,RSI_PRICE);
   if(onnx_model != INVALID_HANDLE)
     {
      Print("Preparing ONNX model");

      ulong input_shape[] = {1,ONNX_INPUTS};

      if(!OnnxSetInputShape(onnx_model,0,input_shape))
        {
         Print("Failed To Specify ONNX model input shape");
         return(INIT_FAILED);
        }

      ulong output_shape[] = {ONNX_OUTPUTS,1};

      if(!OnnxSetOutputShape(onnx_model,0,output_shape))
        {
         Print("Failed To Specify ONNX model output shape");
         return(INIT_FAILED);
        }
     }

//--- Everything was fine
   Print("Successfully loaded all components for our Expert Advisor");
   return(INIT_SUCCEEDED);
  }
//--- End of OnInit Scope

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete the dynamic objects
   delete TradeTime;
   delete TradeInformation;
   delete MACross;
   delete RSIMid;
   OnnxRelease(onnx_model);
   IndicatorRelease(ma_handle);
   IndicatorRelease(ma_o_handle);
   IndicatorRelease(rsi_handle);
  }
//--- End of Deinit Scope

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check if a new daily candle has formed
   if(TradeTime.NewCandle())
     {
      //--- Update strategy
      Update();

      //--- If we have no open positions
      if(PositionsTotal() == 0)
        {
         //--- Reset the position timer
         position_timer = 0;

         //--- Check for a trading signal
         CheckSignal();
        }

      //--- Otherwise
      else
        {
         //--- The position has reached maturity
         if(position_timer == HOLDING_PERIOD)
            Trade.PositionClose(Symbol());
         //--- Otherwise keep holding
         else
            position_timer++;
        }
     }
  }
//--- End of OnTick Scope

//+------------------------------------------------------------------+
//| Update our technical indicators                                  |
//+------------------------------------------------------------------+
void Update(void)
  {
   int fetch = (HORIZON * 2);

//--- Update the strategy
   RSIMid.Update();
   MACross.Update();

//---Set the values as series
   CopyBuffer(ma_handle,0,0,fetch,ma_reading);
   ArraySetAsSeries(ma_reading,true);
   CopyBuffer(ma_o_handle,0,0,fetch,ma_o_reading);
   ArraySetAsSeries(ma_o_reading,true);
   CopyBuffer(rsi_handle,0,0,fetch,rsi_reading);
   ArraySetAsSeries(rsi_reading,true);
  }
//--- End of Update Scope

//+------------------------------------------------------------------+
//| Get A Prediction from our ONNX model                             |
//+------------------------------------------------------------------+
void OnnxPredict(void)
  {
   vectorf   input_variables =
     {
      iOpen(_Symbol,STRATEGY_TIME_FRAME,0),
      iHigh(_Symbol,STRATEGY_TIME_FRAME,0),
      iLow(_Symbol,STRATEGY_TIME_FRAME,0),
      iClose(_Symbol,STRATEGY_TIME_FRAME,0),
      ma_reading[0],
      ma_o_reading[0],
      rsi_reading[0],
      iOpen(_Symbol,STRATEGY_TIME_FRAME,0)   - iOpen(_Symbol,STRATEGY_TIME_FRAME,(0 + HORIZON)),
      iHigh(_Symbol,STRATEGY_TIME_FRAME,0)   - iHigh(_Symbol,STRATEGY_TIME_FRAME,(0 + HORIZON)),
      iLow(_Symbol,STRATEGY_TIME_FRAME,0)    - iLow(_Symbol,STRATEGY_TIME_FRAME,(0 + HORIZON)),
      iClose(_Symbol,STRATEGY_TIME_FRAME,0)  - iClose(_Symbol,STRATEGY_TIME_FRAME,(0 + HORIZON)),
      ma_reading[0] - ma_reading[(0 + HORIZON)],
      ma_o_reading[0] - ma_o_reading[(0 + HORIZON)],
      rsi_reading[0] - rsi_reading[(0 + HORIZON)]
     };

   for(int i = 0; i < ONNX_INPUTS;i++)
     {
      input_variables[i] = ((input_variables[i] - Z1[i])/ Z2[i]);
     }

   OnnxRun(onnx_model,ONNX_DEFAULT,input_variables,onnx_output);
  }

//+------------------------------------------------------------------+
//| Check for a trading signal using our cross-over strategy         |
//+------------------------------------------------------------------+
void CheckSignal(void)
  {

   OnnxPredict();

//--- MA Strategy is profitable
   if((onnx_output[0] > 0.5) && (onnx_output[1] < 0.5))
     {
      //--- Long positions when the close moving average is above the open
      if(MACross.BuySignal())
        {
         Trade.Buy(TradeInformation.MinVolume(),Symbol(),TradeInformation.GetAsk(),0,0,"");
         return;
        }

      //--- Otherwise short
      else
         if(MACross.SellSignal())
           {
            Trade.Sell(TradeInformation.MinVolume(),Symbol(),TradeInformation.GetBid(),0,0,"");
            return;
           }
     }

//--- RSI strategy is profitable
   else
      if((onnx_output[0] < 0.5) && (onnx_output[1] > 0.5))
        {

         if(RSIMid.BuySignal())
           {
            Trade.Buy(TradeInformation.MinVolume(),Symbol(),TradeInformation.GetAsk(),0,0,"");
            return;
           }

         //--- Otherwise short
         else
            if(MACross.SellSignal())
              {
               Trade.Sell(TradeInformation.MinVolume(),Symbol(),TradeInformation.GetBid(),0,0,"");
               return;
              }
        }
  }
//--- End of CheckSignal Scope

//+------------------------------------------------------------------+
//| Undefine system constants                                        |
//+------------------------------------------------------------------+
#undef MA_SHIFT
#undef RSI_PRICE
#undef MA_TYPE
#undef ONNX_INPUTS
#undef ONNX_OUTPUTS
#undef HORIZON
//+------------------------------------------------------------------+