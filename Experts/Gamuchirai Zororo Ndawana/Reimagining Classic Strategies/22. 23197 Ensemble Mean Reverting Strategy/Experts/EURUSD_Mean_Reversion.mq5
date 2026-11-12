//+------------------------------------------------------------------+
//|                                        EURUSD Mean Reversion.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| System resources                                                 |
//+------------------------------------------------------------------+
#resource "\\Files\\EURUSD Linear Regressor.onnx" as const uchar onnx_proto[];

//+------------------------------------------------------------------+
//| Library                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| System inputs                                                    |
//+------------------------------------------------------------------+
input group "Technical Indicators"
input(name="Moving Average Period") int MA_PERIOD = 12;
input(name="ATR Period") int ATR_PERIOD = 14;

input group "Time Frames"
input(name="Higher Time Frame") ENUM_TIMEFRAMES HIGHER_TIME_FRAME = PERIOD_W1;
input(name="Lower Time Frame") ENUM_TIMEFRAMES LOWER_TIME_FRAME = PERIOD_D1;

input group"Risk Management"
input(name="ATR Multiple") double ATR_MULTIPLE = 2;
input(name="Percentage Risk") double RISK = 0.01;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
const int magic_number = 2631;
int high_ma,low_ma,daily_high_ma,daily_low_ma,daily_open_ma,daily_close_ma,atr;
double high_ma_reading[],low_ma_reading[],daily_high_ma_reading[],daily_low_ma_reading[],daily_open_ma_reading[],daily_close_ma_reading[],atr_reading[];
double bid,ask,stop_width;
datetime current_timestamp;
vector daily_high,daily_low,daily_open,daily_close;
vectorf model_inputs,model_outputs;
long    model;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set magic number for the application
   Trade.SetExpertMagicNumber(magic_number);

//--- Initialize indicators and test the validty of handlers
   if(LoadIndicators())
     {
      //--- An error has occured
      Comment("Failed to load indicators correctly: ",GetLastError());
      return(INIT_FAILED);
     }

//--- All is fine
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Free up resources
   IndicatorRelease(high_ma);
   IndicatorRelease(low_ma);
   IndicatorRelease(daily_high_ma);
   IndicatorRelease(daily_low_ma);
   IndicatorRelease(daily_open_ma);
   IndicatorRelease(daily_close_ma);
   IndicatorRelease(atr);
   OnnxRelease(model);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Keep track of time
   current_timestamp = iTime(Symbol(),LOWER_TIME_FRAME,1);
   static datetime time_stamp;

//--- Check if a new candle has formed
   if(time_stamp != current_timestamp)
     {
      //--- Update time stamp
      time_stamp = current_timestamp;

      //--- Copy updated prices and indicator buffers
      if(UpdatePrices())
        {
         //--- Check if we have open positions
         if(TradeExists())
           {
            //--- Manage the open position
            ManagePosition();
           }

         //--- We have no open trades
         else
           {
            //--- Check for entry signal
            CheckTradingSignal();
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if we can update our stop levels                           |
//+------------------------------------------------------------------+
void ManagePosition(void)
  {
//--- Select the position
   if(PositionSelect(Symbol()))
     {
      //--- Check the magic number of the position
      if(PositionGetInteger(POSITION_MAGIC) == magic_number)
        {
         //--- Store current SL & TP
         double current_sl,current_tp,new_sl,new_tp;
         current_sl = PositionGetDouble(POSITION_SL);
         current_tp = PositionGetDouble(POSITION_TP);

         //--- Check the position type
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            new_sl = (bid-stop_width)>current_sl?bid-stop_width:current_sl;
            new_tp = (bid+stop_width)>current_tp?bid+stop_width:current_tp;
           }

         //--- Our position is a sell order
         else
           {
            new_sl = (bid+stop_width)<current_sl?ask+stop_width:current_sl;
            new_tp = (bid-stop_width)<current_tp?ask-stop_width:current_tp;
           }

         //--- Check if the position needs modification
         if(new_sl != current_sl)
           {
            Trade.PositionModify(Symbol(),new_sl,new_tp);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Check if our trading signal has formed                           |
//+------------------------------------------------------------------+
void CheckTradingSignal(void)
  {
//--- Long entry conditions
   if((daily_close[0] < low_ma_reading[0]) && (daily_open_ma_reading[0] < daily_close_ma_reading[0]) && (model_outputs[0] > 1))
     {
      //--- Validate the trade was executed
      if(!Trade.Buy(RISK,Symbol(),ask,bid - stop_width,bid + stop_width,""))
        {
         //--- Something went wrong
         Print("Failed to execute buy trade: ",Trade.ResultRetcode()," ",Trade.ResultRetcodeDescription());
        }
     }


//--- Short entry conditions
   else
      if((daily_close[0] > high_ma_reading[0]) && (daily_open_ma_reading[0] > daily_close_ma_reading[0]) && (model_outputs[0] < 1))
        {
         //--- Check if the trade was executed
         if(!Trade.Sell(RISK,Symbol(),bid,ask + stop_width,ask - stop_width,""))
           {
            //--- Something went wrong
            Print("Failed to execute sell trade: ",Trade.ResultRetcode()," ",Trade.ResultRetcodeDescription());
           }
        }
  }

//+------------------------------------------------------------------+
//| Setup Our Technical Indicators                                   |
//+------------------------------------------------------------------+
bool LoadIndicators(void)
  {
//--- Load the required indicators
   high_ma = iMA(Symbol(),HIGHER_TIME_FRAME,MA_PERIOD,0,MODE_EMA,PRICE_HIGH);
   low_ma = iMA(Symbol(),HIGHER_TIME_FRAME,MA_PERIOD,0,MODE_EMA,PRICE_LOW);
   daily_high_ma = iMA(Symbol(),LOWER_TIME_FRAME,MA_PERIOD,0,MODE_EMA,PRICE_HIGH);
   daily_low_ma = iMA(Symbol(),LOWER_TIME_FRAME,MA_PERIOD,0,MODE_EMA,PRICE_LOW);
   daily_close_ma = iMA(Symbol(),LOWER_TIME_FRAME,MA_PERIOD,0,MODE_EMA,PRICE_CLOSE);
   daily_open_ma = iMA(Symbol(),LOWER_TIME_FRAME,MA_PERIOD,0,MODE_EMA,PRICE_OPEN);
   atr = iATR(Symbol(),LOWER_TIME_FRAME,ATR_PERIOD);

//--- Setup the ONNX model
   model = OnnxCreateFromBuffer(onnx_proto,ONNX_DATA_TYPE_FLOAT);

//--- Define the model parameter shape
   ulong input_shape[] = {1,4};
   ulong output_shape[] = {1,1};

   OnnxSetInputShape(model,0,input_shape);
   OnnxSetOutputShape(model,0,output_shape);

//--- Initialize model inputs and outputs
   model_inputs = vectorf::Zeros(4);
   model_outputs = vectorf::Zeros(1);

//--- This function will return true if one of the indicators failed to load
   return((model == INVALID_HANDLE)||(high_ma == INVALID_HANDLE)||(low_ma == INVALID_HANDLE)||(atr == INVALID_HANDLE)||(daily_close_ma == INVALID_HANDLE)||(daily_open_ma == INVALID_HANDLE)||(daily_high_ma == INVALID_HANDLE)||(daily_low_ma == INVALID_HANDLE));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if we have already placed a trade                          |
//+------------------------------------------------------------------+
bool TradeExists(void)
  {
//--- Get trades for the current symbol
   if(PositionSelect(Symbol()))
     {
      //--- Check the magic number
      if(PositionGetInteger(POSITION_MAGIC) == magic_number)
        {
         //--- We have a position that is still open
         return(true);
        }
     }
//--- We have no open positions
   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Update our prices and indicator buffers                          |
//+------------------------------------------------------------------+
bool UpdatePrices(void)
  {
//---- Copy udated indicator reading to buffer
//--- High MA indicator
   if(CopyBuffer(high_ma,0,1,12,high_ma_reading) <= 0)
     {
      //--- Failed to read in the moving average high indicator
      Print("Failed to read the weekly moving average high indicator buffer: ",GetLastError());
      return(false);
     }
//--- Low MA indicator
   if(CopyBuffer(low_ma,0,1,12,low_ma_reading) <= 0)
     {
      //--- Failed to read in the moving average low indicator
      Print("Failed to read the weekly moving average low indicator buffer: ",GetLastError());
      return(false);
     }
//--- Daily High MA indicator
   if(CopyBuffer(daily_high_ma,0,1,1,daily_high_ma_reading) <= 0)
     {
      //--- Failed to read in the daily moving average high indicator
      Print("Failed to read the daily moving average high indicator buffer: ",GetLastError());
      return(false);
     }
//--- Daily Low MA indicator
   if(CopyBuffer(daily_low_ma,0,1,1,daily_low_ma_reading) <= 0)
     {
      //--- Failed to read in the daily moving average low indicator
      Print("Failed to read the daily moving average low indicator buffer: ",GetLastError());
      return(false);
     }
//--- Daily Open MA indicator
   if(CopyBuffer(daily_open_ma,0,1,1,daily_open_ma_reading) <= 0)
     {
      //--- Failed to read in the daily moving average open indicator
      Print("Failed to read the daily moving average open indicator buffer: ",GetLastError());
      return(false);
     }
//--- Daily Close MA indicator
   if(CopyBuffer(daily_close_ma,0,1,1,daily_close_ma_reading) <= 0)
     {
      //--- Failed to read in the daily moving average close indicator
      Print("Failed to read the daily moving average close indicator buffer: ",GetLastError());
      return(false);
     }
//--- ATR indicator
   if(CopyBuffer(atr,0,1,1,atr_reading) <= 0)
     {
      //--- Failed to read in the ATR indicator
      Print("Failed to read the daily ATR indicator buffer: ",GetLastError());
      return(false);
     }

//--- Set the moving average buffer as series
   if(!ArraySetAsSeries(high_ma_reading,true))
     {
      //--- We failed to set the high moving average buffer as series
      Print("An error occured when organizing the high moving average buffer: ",GetLastError());
      return(false);
     }

   if(!ArraySetAsSeries(low_ma_reading,true))
     {
      //--- We failed to set the low moving average buffer as series
      Print("An error occured when organizing the low moving average buffer: ",GetLastError());
      return(false);
     }

//--- Keep track of current bid & ask prices
   if(!SymbolInfoDouble(Symbol(),SYMBOL_BID,bid))
      {
         //--- An error occured reading the bid price
         Print("An error occured reading the bid price: ",GetLastError());
         return(false);
      }
   if(!SymbolInfoDouble(Symbol(),SYMBOL_ASK,ask))
       {
         //--- An error occured reading the ask price
         Print("An error occured reading the ask price: ",GetLastError());
         return(false);
      }

//--- Copy historical price levels to vector
//--- High
   if(!daily_high.CopyRates(Symbol(),LOWER_TIME_FRAME,COPY_RATES_HIGH,1,30))
     {
      //--- Failed to copy the historical daily high price
      Print("Failed to copy the historical daily high price to vector: ",GetLastError());
      return(false);
     }
//--- Low
   if(!daily_low.CopyRates(Symbol(),LOWER_TIME_FRAME,COPY_RATES_LOW,1,30))
     {
      //--- Failed to copy the historical daily low price
      Print("Failed to copy the historical daily low price to vector: ",GetLastError());
      return(false);
     }
//--- Open
   if(!daily_open.CopyRates(Symbol(),LOWER_TIME_FRAME,COPY_RATES_OPEN,1,30))
     {
      //--- Failed to copy the historical daily open price
      Print("Failed to copy the historical daily open price to vector: ",GetLastError());
      return(false);
     }
//--- Close
   if(!daily_close.CopyRates(Symbol(),LOWER_TIME_FRAME,COPY_RATES_CLOSE,1,30))
     {
      //--- Failed to copy the historical daily close price
      Print("Failed to copy the historical daily close price to vector: ",GetLastError());
      return(false);
     }

//--- Prepare ONNX model inputs
   model_inputs[0] = (float)iOpen("EURUSD",PERIOD_D1,0);
   model_inputs[1] = (float)iHigh("EURUSD",PERIOD_D1,0);
   model_inputs[2] = (float)iLow("EURUSD",PERIOD_D1,0);
   model_inputs[3] = (float)iClose("EURUSD",PERIOD_D1,0);

//--- Obtain ONNX model forecast
   if(!(OnnxRun(model,ONNX_DATA_TYPE_FLOAT,model_inputs,model_outputs)))
     {
      Comment("Failed to obtain a forecast from our model: ",GetLastError());
     }

   else
     {
      Comment("Forecast: ",model_outputs);
     }

//--- Calculate the new stop levels
   stop_width = NormalizeDouble(((atr_reading[0] * ATR_MULTIPLE) + (SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL) * _Point)),_Digits);

//--- Everything went fine
   return(true);
  }
//+------------------------------------------------------------------+