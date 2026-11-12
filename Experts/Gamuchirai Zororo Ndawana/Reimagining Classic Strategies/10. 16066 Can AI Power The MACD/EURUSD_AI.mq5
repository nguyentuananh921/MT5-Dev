//+--------------------------------------------------------------+
//| EURUSD AI                                                    |
//+--------------------------------------------------------------+
#property copyright "Gamuchirai Ndawana"
#property link "https://metaquotes.com/en/users/gamuchiraindawa"
#property version "2.1"
#property description "Supports M1"

//+--------------------------------------------------------------+
//| Resources we need                                            |
//+--------------------------------------------------------------+
#resource "\\Files\\EURUSD SVR M1.onnx" as const uchar onnx_buffer[];

//+--------------------------------------------------------------+
//| Libraries                                                    |
//+--------------------------------------------------------------+
#include  <Trade\Trade.mqh>
CTrade trade;

//+--------------------------------------------------------------+
//| Constants                                                    |
//+--------------------------------------------------------------+
const double  stop_percent = 1;
const int     ma_period_shift = 0;

//+--------------------------------------------------------------+
//| User inputs                                                  |
//+--------------------------------------------------------------+
input group "TAs"
input double atr_multiple =2.5;             //How wide should the stop loss be?
input int    atr_period = 200;              //ATR Period
input int    ma_period = 1000;              //Moving average period

input group "Risk"
input double risk_percentage= 0.02;         //Risk percentage (0.01 - 1)
input double profit_target = 1.0;           //Profit target

//+--------------------------------------------------------------+
//| Global variables                                             |
//+--------------------------------------------------------------+
double position_size = 2;
int lot_multiplier = 1;
bool  buy_break_even_setup = false;
bool  sell_break_even_setup = false;
double up_level = 0.03;
double down_level = -0.03;
double min_volume,max_volume_increase, volume_step, buy_stop_loss, sell_stop_loss,ask, bid,atr_stop,mid_point,risk_equity;
double take_profit = 0;
double close_price[3];
double moving_average_low_array[],close_average_reading[],moving_average_high_array[],atr_reading[];
long   min_distance,login;
int    ma_high,ma_low,atr,close_average;
bool   authorized = false;
double tick_value,average_market_move,margin,mid_point_height,channel_width,lot_step;
string currency,server;
bool all_closed =true;
long onnx_model;
vectorf onnx_output = vectorf::Zeros(1);
ENUM_ACCOUNT_TRADE_MODE account_type;

//+------------------------------------------------------------------+
//| On initialization                                                |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- Authorization
   if(!auth())
     {
      return(INIT_FAILED);
     }
     
//--- Load the ONNX model
if(!load_onnx())
   {
      return(INIT_FAILED);
   }

//--- Everything went fine
   else
     {
      load();      
      return(INIT_SUCCEEDED);
     }
  }

//+------------------------------------------------------------------+
//| On deinitialization                                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
      OnnxRelease(onnx_model);
  }

//+------------------------------------------------------------------+
//| On every tick                                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
//On Every Function Call
   update();
   static datetime time_stamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);
   Comment("AI Forecast: ",onnx_output[0]);

//On Every Candle
   if(time_stamp != time)
     {

      //Mark the candle
      time_stamp = time;

      OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,min_volume,ask,margin);
      calculate_lot_size();
      if(PositionsTotal() == 0)
        {
         check_signal();
        }
     }

//--- If we have positions, manage them.
   if(PositionsTotal() > 0)
     {
      check_atr_stop();
      check_profit();
     }
  }


//+------------------------------------------------------------------+
//| Check if we have any valid setups, and execute them              |
//+------------------------------------------------------------------+
void check_signal(void)
  {
  //--- Get a prediction from our model
  model_predict();
     if(onnx_output[0] > iClose(Symbol(),PERIOD_CURRENT,0))
      {
         if(above_channel())
           {
               check_buy();
           }
      }
      
      else
         if(below_channel())
           {
             if(onnx_output[0] < iClose(Symbol(),PERIOD_CURRENT,0))
               {
                  check_sell();
                }
           }
  }

//+------------------------------------------------------------------+
//| Update our global variables                                      |
//+------------------------------------------------------------------+
void update(void)
  {
//--- Important details that need to be updated everytick
   ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   buy_stop_loss = 0;
   sell_stop_loss = 0;
   check_price(3);
   CopyBuffer(ma_high,0,0,1,moving_average_high_array);
   CopyBuffer(ma_low,0,0,1,moving_average_low_array);
   CopyBuffer(atr,0,0,1,atr_reading);
   ArraySetAsSeries(moving_average_high_array,true);
   ArraySetAsSeries(moving_average_low_array,true);
   ArraySetAsSeries(atr_reading,true);
   risk_equity = AccountInfoDouble(ACCOUNT_BALANCE) * risk_percentage;
   atr_stop = (((min_distance + (atr_reading[0]* 1e5) * atr_multiple) * _Point));
   mid_point = (moving_average_high_array[0] + moving_average_low_array[0]) / 2;
   mid_point_height = close_price[0] - mid_point;
   channel_width = moving_average_high_array[0] - moving_average_low_array[0];
  }

//+------------------------------------------------------------------+
//| Check if the EA is allowed to be run                             |
//+------------------------------------------------------------------+
bool auth(void)
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Comment("Press Ctrl + E To Give The Robot Permission To Trade And Reload The Program");
      return(false);
     }

   else
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Comment("Reload The Program And Make Sure You Clicked Allow Algo Trading");
         return(false);
        }

   return(true);
  }

//+---------------------------------------------------------------------+
//| Load our needed variables                                           |
//+---------------------------------------------------------------------+
void load(void)
  {
//Account Info
   currency = AccountInfoString(ACCOUNT_CURRENCY);
   server = AccountInfoString(ACCOUNT_SERVER);
   login = AccountInfoInteger(ACCOUNT_LOGIN);

//Indicators
   atr = iATR(_Symbol,PERIOD_CURRENT,atr_period);
   ma_high = iMA(_Symbol,PERIOD_CURRENT,ma_period,ma_period_shift,MODE_EMA,PRICE_HIGH);
   ma_low = iMA(_Symbol,PERIOD_CURRENT,ma_period,ma_period_shift,MODE_EMA,PRICE_LOW);

//Market Information
   min_volume = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   max_volume_increase = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX) / SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   min_distance = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   tick_value = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_PROFIT) * min_volume;
   lot_step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   average_market_move = NormalizeDouble(10000 * tick_value,_Digits);

  }

//+------------------------------------------------------------------+
//| Load our ONNX model                                              |
//+------------------------------------------------------------------+
bool load_onnx(void)
   {
      onnx_model = OnnxCreateFromBuffer(onnx_buffer,ONNX_DEFAULT);
      ulong onnx_input [] = {1,4};
      ulong onnx_output[] = {1,1};
      if(!OnnxSetInputShape(onnx_model,0,onnx_input))
         {
            Comment("[INTERNAL ERROR] Failed to load AI modules. Relode the EA.");
            return(false);
         }
         
      if(!OnnxSetOutputShape(onnx_model,0,onnx_output))
         {
            Comment("[INTERNAL ERROR] Failed to load AI modules. Relode the EA.");
            return(false);
         }
         
     return(true);
   }

//+------------------------------------------------------------------+
//| Get a prediction from our model                                  |
//+------------------------------------------------------------------+
void model_predict(void)
   {
      vectorf onnx_inputs = {iOpen(Symbol(),PERIOD_CURRENT,0),iHigh(Symbol(),PERIOD_CURRENT,0),iLow(Symbol(),PERIOD_CURRENT,0),iClose(Symbol(),PERIOD_CURRENT,0)};
      OnnxRun(onnx_model,ONNX_DEFAULT,onnx_inputs,onnx_output);
   }

//+------------------------------------------------------------------+
//| Update the ATR stop loss                                         |
//+------------------------------------------------------------------+
void check_atr_stop()
  {

   for(int i = PositionsTotal() -1; i >= 0; i--)
     {

      string symbol = PositionGetSymbol(i);
      if(_Symbol == symbol)
        {

         ulong ticket = PositionGetInteger(POSITION_TICKET);
         double position_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double type = PositionGetInteger(POSITION_TYPE);
         double current_stop_loss = PositionGetDouble(POSITION_SL);

         if(type == POSITION_TYPE_BUY)
           {
            double atr_stop_loss = (ask - (atr_stop));
            double atr_take_profit = (ask + (atr_stop));

            if((current_stop_loss < atr_stop_loss) || (current_stop_loss == 0))
              {
               trade.PositionModify(ticket,atr_stop_loss,atr_take_profit);
              }
           }

         else
            if(type == POSITION_TYPE_SELL)
              {
               double atr_stop_loss = (bid + (atr_stop));
               double atr_take_profit = (bid - (atr_stop));
               if((current_stop_loss > atr_stop_loss) || (current_stop_loss == 0))
                 {
                  trade.PositionModify(ticket,atr_stop_loss,atr_take_profit);
                 }
              }
        }
     }
  }

//+------------------------------------------------------------------+
//| Open buy positions                                               |
//+------------------------------------------------------------------+
void check_buy()
  {
   if(PositionsTotal() == 0)
     {
      for(int i=0; i < position_size;i++)
        {
         trade.Buy(min_volume * lot_multiplier,_Symbol,ask,buy_stop_loss,0,"BUY");
         Print("Position: ",i," has been setup");
        }
     }
  }

//+------------------------------------------------------------------+
//| Open sell positions                                              |
//+------------------------------------------------------------------+
void check_sell()
  {
   if(PositionsTotal() == 0)
     {
      for(int i=0; i < position_size;i++)
        {
         trade.Sell(min_volume * lot_multiplier,_Symbol,bid,sell_stop_loss,0,"SELL");
         Print("Position: ",i," has been setup");
        }
     }
  }

//+------------------------------------------------------------------+
//| Close all buy positions                                          |
//+------------------------------------------------------------------+
void close_buy()
  {
   ulong ticket;
   int type;
   if(PositionsTotal() > 0)
     {
      for(int i = 0; i < PositionsTotal();i++)
        {
         if(PositionGetSymbol(i) == _Symbol)
           {
            ticket = PositionGetTicket(i);
            type = (int)PositionGetInteger(POSITION_TYPE);
            if(type == POSITION_TYPE_BUY)
              {
               trade.PositionClose(ticket);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Close all sell positions                                         |
//+------------------------------------------------------------------+
void close_sell()
  {
   ulong ticket;
   int type;
   if(PositionsTotal() > 0)
     {
      for(int i = 0; i < PositionsTotal();i++)
        {
         if(PositionGetSymbol(i) == _Symbol)
           {
            ticket = PositionGetTicket(i);
            type = (int)PositionGetInteger(POSITION_TYPE);
            if(type == POSITION_TYPE_SELL)
              {
               trade.PositionClose(ticket);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Get the last 3 quotes                                            |
//+------------------------------------------------------------------+
void check_price(int candles)
  {
   for(int i = 0; i < candles;i++)
     {
      close_price[i] = iClose(_Symbol,PERIOD_CURRENT,i);
     }
  }


//+------------------------------------------------------------------+
//| Are we completely above the MA?                                  |
//+------------------------------------------------------------------+
bool above_channel()
  {
   return (((close_price[0] - moving_average_high_array[0] > 0)) && ((close_price[0] - moving_average_low_array[0]) > 0));
  }

//+------------------------------------------------------------------+
//| Are we completely below the MA?                                  |
//+------------------------------------------------------------------+
bool below_channel()
  {
   return(((close_price[0] - moving_average_high_array[0]) < 0) && ((close_price[0] - moving_average_low_array[0]) < 0));
  }

//+------------------------------------------------------------------+
//| Return true if we are beneath the low                            |
//+------------------------------------------------------------------+
bool broke_low()
  {
   return ((close_price[0] - moving_average_low_array[0]) < 0);
  }

//+------------------------------------------------------------------+
//| Return true if we are above the high                             |
//+------------------------------------------------------------------+
bool broke_high()
  {
   return((close_price[0] - moving_average_high_array[0]) > 0);
  }

//+------------------------------------------------------------------+
//| Close all positions we have                                      |
//+------------------------------------------------------------------+
void close_all()
  {
   if(PositionsTotal() > 0)
     {
      ulong ticket;
      for(int i =0;i < PositionsTotal();i++)
        {
         ticket = PositionGetTicket(i);
         trade.PositionClose(ticket);
        }
     }
  }

//+------------------------------------------------------------------+
//| Calculate the lot size to be used                                |
//+------------------------------------------------------------------+
void calculate_lot_size()
  {
//--- This is the total percentage of the account we're willing to part with for margin, or to keep a position open in other words.
   Print("Risk Equity: ",risk_equity);

//--- Now that we're ready to part with a discrete amount for margin, how many positions can we afford under the current lot size?
//--- By default we always start from minimum lot
   position_size = risk_equity / margin;

//--- We need to keep the number of positions lower than 10
   if(position_size > 10)
     {
      //--- How many times is it greater than 10?
      int estimated_lot_size = (int)  MathFloor(position_size / 10);
      position_size = risk_equity / (margin * estimated_lot_size);
      Print("Position Size After Dividing By margin at new estimated lot size: ",position_size);
      int estimated_position_size = position_size;
      //--- Can we increase the lot size this many times?
      if(estimated_lot_size < max_volume_increase)
        {
         Print("Est Lot Size: ",estimated_lot_size," Position Size: ",estimated_position_size);
         lot_multiplier = estimated_lot_size;
         position_size = estimated_position_size;
        }
     }
  }

//--- This function will help us keep track of which side we need to enter the market
void close_all_and_enter()
  {

   if(PositionSelect(Symbol()))
     {
      // Determine the type of position
      check_signal();
     }
   else
     {
      Print("No open position found.");
     }
  }

//+------------------------------------------------------------------+
//| Chekc if we have reached our profit target                       |
//+------------------------------------------------------------------+
void check_profit()
  {
   double current_profit = (AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE)) / PositionsTotal();
   if(current_profit > profit_target)
     {
      close_all_and_enter();
     }

   if((current_profit * PositionsTotal()) < (risk_equity * -1))
     {
      Comment("We've breached our risk equity, consider closing all positions");
     }
  }

//+------------------------------------------------------------------+
//| Close all losing trades                                          |
//+------------------------------------------------------------------+
void close_profitable_trades()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionSelectByTicket(PositionGetTicket(i)))
        {
         if(PositionGetDouble(POSITION_PROFIT)>profit_target)
           {
            ulong ticket;
            ticket = PositionGetTicket(i);
            trade.PositionClose(ticket);
           }
        }
     }
  }
//+------------------------------------------------------------------+
