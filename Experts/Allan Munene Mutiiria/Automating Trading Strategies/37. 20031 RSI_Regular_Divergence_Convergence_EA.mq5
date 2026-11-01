//+------------------------------------------------------------------+
//|                        RSI Regular Divergence Convergence EA.mq5 |
//|                           Copyright 2025, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "RSI Settings"
input int RSI_Period = 14;                          // RSI Period
input ENUM_APPLIED_PRICE RSI_Applied = PRICE_CLOSE; // RSI Applied Price

input group "Swing Settings"
input int Swing_Strength = 5;                       // Bars to confirm swing high/low
input int Min_Bars_Between = 5;                     // Min bars between swings for divergence
input int Max_Bars_Between = 50;                    // Max bars between swings for divergence
input double Tolerance = 0.1;                       // Tolerance for clean divergence check

input group "Trade Settings"
input double Lot_Size = 0.01;                       // Fixed Lot Size
input int Magic_Number = 123456789;                 // Magic Number
input double SL_Pips = 300.0;                       // Stop Loss in Pips (0 to disable)
input double TP_Pips = 300.0;                       // Take Profit in Pips (0 to disable)

input group "Trailing Stop Settings"
input bool Enable_Trailing_Stop = true;             // Enable Trailing Stop
input double Trailing_Stop_Pips = 30.0;             // Trailing Stop in Pips
input double Min_Profit_To_Trail_Pips = 50.0;       // Minimum Profit to Start Trailing in Pips

input group "Visualization"
input color Bull_Color = clrGreen;                  // Bullish Divergence Color
input color Bear_Color = clrRed;                    // Bearish Divergence Color
input color Swing_High_Color = clrRed;              // Color for Swing High Labels
input color Swing_Low_Color = clrGreen;             // Color for Swing Low Labels
input int Line_Width = 2;                           // Divergence Line Width
input ENUM_LINE_STYLE Line_Style = STYLE_SOLID;     // Divergence Line Style
input int Font_Size = 8;                            // Swing Point Font Size

//+------------------------------------------------------------------+
//| Indicator Handles and Trade Object                               |
//+------------------------------------------------------------------+
int RSI_Handle = INVALID_HANDLE;                   //--- RSI indicator handle
CTrade obj_Trade;                                  //--- Trade object for position management

//+------------------------------------------------------------------+
//| Swing Variables                                                  |
//+------------------------------------------------------------------+
double Last_High_Price = 0.0;                      //--- Last swing high price
datetime Last_High_Time = 0;                       //--- Last swing high time
double Prev_High_Price = 0.0;                      //--- Previous swing high price
datetime Prev_High_Time = 0;                       //--- Previous swing high time
double Last_Low_Price = 0.0;                       //--- Last swing low price
datetime Last_Low_Time = 0;                        //--- Last swing low time
double Prev_Low_Price = 0.0;                       //--- Previous swing low price
datetime Prev_Low_Time = 0;                        //--- Previous swing low time
double Last_High_RSI = 0.0;                        //--- Last swing high RSI value
double Prev_High_RSI = 0.0;                        //--- Previous swing high RSI value
double Last_Low_RSI = 0.0;                         //--- Last swing low RSI value
double Prev_Low_RSI = 0.0;                         //--- Previous swing low RSI value

//+------------------------------------------------------------------+
//| Expert Initialization Function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   RSI_Handle = iRSI(_Symbol, _Period, RSI_Period, RSI_Applied); //--- Create RSI indicator handle
   if (RSI_Handle == INVALID_HANDLE) {             //--- Check if RSI creation failed
      Print("Failed to create RSI indicator");     //--- Log error
      return(INIT_FAILED);                         //--- Return initialization failure
   }
   long chart_id = ChartID();                      //--- Get current chart ID
   string rsi_name = "RSI(" + IntegerToString(RSI_Period) + ")"; //--- Generate RSI indicator name
   int rsi_subwin = ChartWindowFind(chart_id, rsi_name); //--- Find RSI subwindow
   if (rsi_subwin == -1) {                         //--- Check if RSI subwindow not found
      if (!ChartIndicatorAdd(chart_id, 1, RSI_Handle)) { //--- Add RSI to chart subwindow
         Print("Failed to add RSI indicator to chart"); //--- Log error
      }
   }
   obj_Trade.SetExpertMagicNumber(Magic_Number);   //--- Set magic number for trade object
   Print("RSI Divergence EA initialized");         //--- Log initialization success
   return(INIT_SUCCEEDED);                         //--- Return initialization success
}

//+------------------------------------------------------------------+
//| Expert Deinitialization Function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if (RSI_Handle != INVALID_HANDLE) IndicatorRelease(RSI_Handle); //--- Release RSI handle if valid
   ObjectsDeleteAll(0, "DivLine_");                //--- Delete all divergence line objects
   ObjectsDeleteAll(0, "SwingHigh_");              //--- Delete all swing high objects
   ObjectsDeleteAll(0, "SwingLow_");               //--- Delete all swing low objects
   Print("RSI Divergence EA deinitialized");       //--- Log deinitialization
}

//+------------------------------------------------------------------+
//| Check for Swing High                                             |
//+------------------------------------------------------------------+
bool CheckSwingHigh(int bar, double& highs[]) {
   if (bar < Swing_Strength || bar + Swing_Strength >= ArraySize(highs)) return false; //--- Return false if bar index out of range for swing strength
   double current = highs[bar];                    //--- Get current high price
   for (int i = 1; i <= Swing_Strength; i++) {     //--- Iterate through adjacent bars
      if (highs[bar - i] >= current || highs[bar + i] >= current) return false; //--- Return false if not a swing high
   }
   return true;                                    //--- Return true if swing high
}

//+------------------------------------------------------------------+
//| Check for Swing Low                                              |
//+------------------------------------------------------------------+
bool CheckSwingLow(int bar, double& lows[]) {
   if (bar < Swing_Strength || bar + Swing_Strength >= ArraySize(lows)) return false; //--- Return false if bar index out of range for swing strength
   double current = lows[bar];                     //--- Get current low price
   for (int i = 1; i <= Swing_Strength; i++) {     //--- Iterate through adjacent bars
      if (lows[bar - i] <= current || lows[bar + i] <= current) return false; //--- Return false if not a swing low
   }
   return true;                                    //--- Return true if swing low
}

//+------------------------------------------------------------------+
//| Check for Clean Divergence                                       |
//+------------------------------------------------------------------+
bool CleanDivergence(double rsi1, double rsi2, int shift1, int shift2, double& rsi_data[], bool bearish) {
   if (shift1 <= shift2) return false;             //--- Return false if shifts invalid
   for (int b = shift2 + 1; b < shift1; b++) {    //--- Iterate between shifts
      double interp_factor = (double)(b - shift2) / (shift1 - shift2); //--- Calculate interpolation factor
      double interp_rsi = rsi2 + interp_factor * (rsi1 - rsi2); //--- Calculate interpolated RSI
      if (bearish) {                               //--- Check for bearish divergence
         if (rsi_data[b] > interp_rsi + Tolerance) return false; //--- Return false if RSI exceeds line plus tolerance
      } else {                                     //--- Check for bullish divergence
         if (rsi_data[b] < interp_rsi - Tolerance) return false; //--- Return false if RSI below line minus tolerance
      }
   }
   return true;                                    //--- Return true if divergence is clean
}

//+------------------------------------------------------------------+
//| Open Buy Position                                                |
//+------------------------------------------------------------------+
void OpenBuy() {
   double ask_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK); //--- Get current ask price
   double sl = (SL_Pips > 0) ? NormalizeDouble(ask_price - SL_Pips * _Point, _Digits) : 0; //--- Calculate stop loss if enabled
   double tp = (TP_Pips > 0) ? NormalizeDouble(ask_price + TP_Pips * _Point, _Digits) : 0; //--- Calculate take profit if enabled
   if (obj_Trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, Lot_Size, 0, sl, tp)) { //--- Attempt to open buy position
      Print("Buy trade opened on bullish divergence"); //--- Log buy trade open
   } else {                                        //--- Handle open failure
      Print("Failed to open Buy: ", obj_Trade.ResultRetcodeDescription()); //--- Log error
   }
}

//+------------------------------------------------------------------+
//| Open Sell Position                                               |
//+------------------------------------------------------------------+
void OpenSell() {
   double bid_price = SymbolInfoDouble(_Symbol, SYMBOL_BID); //--- Get current bid price
   double sl = (SL_Pips > 0) ? NormalizeDouble(bid_price + SL_Pips * _Point, _Digits) : 0; //--- Calculate stop loss if enabled
   double tp = (TP_Pips > 0) ? NormalizeDouble(bid_price - TP_Pips * _Point, _Digits) : 0; //--- Calculate take profit if enabled
   if (obj_Trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, Lot_Size, 0, sl, tp)) { //--- Attempt to open sell position
      Print("Sell trade opened on bearish divergence"); //--- Log sell trade open
   } else {                                        //--- Handle open failure
      Print("Failed to open Sell: ", obj_Trade.ResultRetcodeDescription()); //--- Log error
   }
}

//+------------------------------------------------------------------+
//| Close All Positions                                              |
//+------------------------------------------------------------------+
void CloseAll() {
   for (int p = PositionsTotal() - 1; p >= 0; p--) { //--- Iterate through positions in reverse
      if (PositionGetTicket(p) > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic_Number) { //--- Check position details
         obj_Trade.PositionClose(PositionGetTicket(p)); //--- Close position
      }
   }
}

//+------------------------------------------------------------------+
//| Apply Trailing Stop to Positions                                 |
//+------------------------------------------------------------------+
void ApplyTrailingStop() {
   double point = _Point;                         //--- Get symbol point value
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions in reverse
      if (PositionGetTicket(i) > 0) {             //--- Check valid ticket
         if (PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic_Number) { //--- Check symbol and magic
            double sl = PositionGetDouble(POSITION_SL); //--- Get current stop loss
            double tp = PositionGetDouble(POSITION_TP); //--- Get current take profit
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Get open price
            ulong ticket = PositionGetInteger(POSITION_TICKET); //--- Get position ticket
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
               double newSL = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - Trailing_Stop_Pips * point, _Digits); //--- Calculate new stop loss
               if (newSL > sl && SymbolInfoDouble(_Symbol, SYMBOL_BID) - openPrice > Min_Profit_To_Trail_Pips * point) { //--- Check trailing conditions
                  obj_Trade.PositionModify(ticket, newSL, tp); //--- Modify position with new stop loss
               }
            } else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
               double newSL = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + Trailing_Stop_Pips * point, _Digits); //--- Calculate new stop loss
               if (newSL < sl && openPrice - SymbolInfoDouble(_Symbol, SYMBOL_ASK) > Min_Profit_To_Trail_Pips * point) { //--- Check trailing conditions
                  obj_Trade.PositionModify(ticket, newSL, tp); //--- Modify position with new stop loss
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   
   if (Enable_Trailing_Stop && PositionsTotal() > 0) {               //--- Check if trailing stop enabled
      ApplyTrailingStop();                   //--- Apply trailing stop to positions
   }
   
   static datetime last_time = 0;                //--- Store last processed time
   datetime current_time = iTime(_Symbol, _Period, 0); //--- Get current bar time
   if (current_time == last_time) return;        //--- Exit if bar not new
   last_time = current_time;                     //--- Update last time
   int data_size = 200;                          //--- Set data size for analysis
   double high_data[], low_data[], rsi_data[];   //--- Declare arrays for high, low, RSI data
   datetime time_data[];                         //--- Declare array for time data
   CopyHigh(_Symbol, _Period, 0, data_size, high_data); //--- Copy high prices
   CopyLow(_Symbol, _Period, 0, data_size, low_data); //--- Copy low prices
   CopyTime(_Symbol, _Period, 0, data_size, time_data); //--- Copy time values
   CopyBuffer(RSI_Handle, 0, 0, data_size, rsi_data); //--- Copy RSI values
   ArraySetAsSeries(high_data, true);            //--- Set high data as series
   ArraySetAsSeries(low_data, true);             //--- Set low data as series
   ArraySetAsSeries(time_data, true);            //--- Set time data as series
   ArraySetAsSeries(rsi_data, true);             //--- Set RSI data as series
   long chart_id = ChartID();                    //--- Get current chart ID
   // Find latest swing high
   int last_high_bar = -1, prev_high_bar = -1;   //--- Initialize swing high bars
   for (int b = 1; b < data_size - Swing_Strength; b++) { //--- Iterate through bars
      if (CheckSwingHigh(b, high_data)) {        //--- Check for swing high
         if (last_high_bar == -1) {              //--- Check if first swing high
            last_high_bar = b;                   //--- Set last high bar
         } else {                                //--- Second swing high found
            prev_high_bar = b;                   //--- Set previous high bar
            break;                               //--- Exit loop
         }
      }
   }
   if (last_high_bar > 0 && time_data[last_high_bar] > Last_High_Time) { //--- Check new swing high
      Prev_High_Price = Last_High_Price;         //--- Update previous high price
      Prev_High_Time = Last_High_Time;           //--- Update previous high time
      Last_High_Price = high_data[last_high_bar]; //--- Set last high price
      Last_High_Time = time_data[last_high_bar]; //--- Set last high time
      Prev_High_RSI = Last_High_RSI;             //--- Update previous high RSI
      Last_High_RSI = rsi_data[last_high_bar];   //--- Set last high RSI
      string high_type = "H";                    //--- Set default high type
      if (Prev_High_Price > 0.0) {               //--- Check if previous high exists
         high_type = (Last_High_Price > Prev_High_Price) ? "HH" : "LH"; //--- Set high type
      }
      bool higher_high = Last_High_Price > Prev_High_Price; //--- Check for higher high
      bool lower_rsi_high = Last_High_RSI < Prev_High_RSI; //--- Check for lower RSI high
      int bars_diff = prev_high_bar - last_high_bar; //--- Calculate bars between highs
      bool bear_div = false;                     //--- Initialize bearish divergence flag
      if (Prev_High_Price > 0.0 && higher_high && lower_rsi_high && bars_diff >= Min_Bars_Between && bars_diff <= Max_Bars_Between) { //--- Check bearish divergence conditions
         if (CleanDivergence(Prev_High_RSI, Last_High_RSI, prev_high_bar, last_high_bar, rsi_data, true)) { //--- Check clean divergence
            bear_div = true;                    //--- Set bearish divergence flag
            // Bearish divergence detected - Sell signal
            CloseAll();                         //--- Close all open positions
            OpenSell();                         //--- Open sell position
            // Draw divergence lines
            string line_name = "DivLine_Bear_" + TimeToString(Last_High_Time); //--- Set divergence line name
            ObjectCreate(chart_id, line_name, OBJ_TREND, 0, Prev_High_Time, Prev_High_Price, Last_High_Time, Last_High_Price); //--- Create trend line for price divergence
            ObjectSetInteger(chart_id, line_name, OBJPROP_COLOR, Bear_Color); //--- Set line color
            ObjectSetInteger(chart_id, line_name, OBJPROP_WIDTH, Line_Width); //--- Set line width
            ObjectSetInteger(chart_id, line_name, OBJPROP_STYLE, Line_Style); //--- Set line style
            ObjectSetInteger(chart_id, line_name, OBJPROP_RAY, false); //--- Disable ray
            ObjectSetInteger(chart_id, line_name, OBJPROP_BACK, false); //--- Set to foreground
            int rsi_window = ChartWindowFind(chart_id, "RSI(" + IntegerToString(RSI_Period) + ")"); //--- Find RSI subwindow
            if (rsi_window != -1) {              //--- Check if RSI subwindow found
               string rsi_line = "DivLine_RSI_Bear_" + TimeToString(Last_High_Time); //--- Set RSI divergence line name
               ObjectCreate(chart_id, rsi_line, OBJ_TREND, rsi_window, Prev_High_Time, Prev_High_RSI, Last_High_Time, Last_High_RSI); //--- Create trend line for RSI divergence
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_COLOR, Bear_Color); //--- Set line color
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_WIDTH, Line_Width); //--- Set line width
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_STYLE, Line_Style); //--- Set line style
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_RAY, false); //--- Disable ray
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_BACK, false); //--- Set to foreground
            }
         }
      }
      // Draw swing label
      string swing_name = "SwingHigh_" + TimeToString(Last_High_Time); //--- Set swing high label name
      if (ObjectFind(chart_id, swing_name) < 0) { //--- Check if label exists
         ObjectCreate(chart_id, swing_name, OBJ_TEXT, 0, Last_High_Time, Last_High_Price); //--- Create swing high label
         ObjectSetString(chart_id, swing_name, OBJPROP_TEXT, " " + high_type + (bear_div ? " Bear Div" : "")); //--- Set label text
         ObjectSetInteger(chart_id, swing_name, OBJPROP_COLOR, Swing_High_Color); //--- Set label color
         ObjectSetInteger(chart_id, swing_name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); //--- Set label anchor
         ObjectSetInteger(chart_id, swing_name, OBJPROP_FONTSIZE, Font_Size); //--- Set label font size
      }
      ChartRedraw(chart_id);                    //--- Redraw chart
   }
   // Find latest swing low
   int last_low_bar = -1, prev_low_bar = -1; //--- Initialize swing low bars
   for (int b = 1; b < data_size - Swing_Strength; b++) { //--- Iterate through bars
      if (CheckSwingLow(b, low_data)) {      //--- Check for swing low
         if (last_low_bar == -1) {           //--- Check if first swing low
            last_low_bar = b;                //--- Set last low bar
         } else {                            //--- Second swing low found
            prev_low_bar = b;                //--- Set previous low bar
            break;                           //--- Exit loop
         }
      }
   }
   if (last_low_bar > 0 && time_data[last_low_bar] > Last_Low_Time) { //--- Check new swing low
      Prev_Low_Price = Last_Low_Price;       //--- Update previous low price
      Prev_Low_Time = Last_Low_Time;         //--- Update previous low time
      Last_Low_Price = low_data[last_low_bar]; //--- Set last low price
      Last_Low_Time = time_data[last_low_bar]; //--- Set last low time
      Prev_Low_RSI = Last_Low_RSI;           //--- Update previous low RSI
      Last_Low_RSI = rsi_data[last_low_bar]; //--- Set last low RSI
      string low_type = "L";                 //--- Set default low type
      if (Prev_Low_Price > 0.0) {            //--- Check if previous low exists
         low_type = (Last_Low_Price < Prev_Low_Price) ? "LL" : "HL"; //--- Set low type
      }
      bool lower_low = Last_Low_Price < Prev_Low_Price; //--- Check for lower low
      bool higher_rsi_low = Last_Low_RSI > Prev_Low_RSI; //--- Check for higher RSI low
      int bars_diff = prev_low_bar - last_low_bar; //--- Calculate bars between lows
      bool bull_div = false;                 //--- Initialize bullish divergence flag
      if (Prev_Low_Price > 0.0 && lower_low && higher_rsi_low && bars_diff >= Min_Bars_Between && bars_diff <= Max_Bars_Between) { //--- Check bullish divergence conditions
         if (CleanDivergence(Prev_Low_RSI, Last_Low_RSI, prev_low_bar, last_low_bar, rsi_data, false)) { //--- Check clean divergence
            bull_div = true;                 //--- Set bullish divergence flag
            // Bullish divergence detected - Buy signal
            CloseAll();                      //--- Close all open positions
            OpenBuy();                       //--- Open buy position
            // Draw divergence lines
            string line_name = "DivLine_Bull_" + TimeToString(Last_Low_Time); //--- Set divergence line name
            ObjectCreate(chart_id, line_name, OBJ_TREND, 0, Prev_Low_Time, Prev_Low_Price, Last_Low_Time, Last_Low_Price); //--- Create trend line for price divergence
            ObjectSetInteger(chart_id, line_name, OBJPROP_COLOR, Bull_Color); //--- Set line color
            ObjectSetInteger(chart_id, line_name, OBJPROP_WIDTH, Line_Width); //--- Set line width
            ObjectSetInteger(chart_id, line_name, OBJPROP_STYLE, Line_Style); //--- Set line style
            ObjectSetInteger(chart_id, line_name, OBJPROP_RAY, false); //--- Disable ray
            ObjectSetInteger(chart_id, line_name, OBJPROP_BACK, false); //--- Set to foreground
            int rsi_window = ChartWindowFind(chart_id, "RSI(" + IntegerToString(RSI_Period) + ")"); //--- Find RSI subwindow
            if (rsi_window != -1) {          //--- Check if RSI subwindow found
               string rsi_line = "DivLine_RSI_Bull_" + TimeToString(Last_Low_Time); //--- Set RSI divergence line name
               ObjectCreate(chart_id, rsi_line, OBJ_TREND, rsi_window, Prev_Low_Time, Prev_Low_RSI, Last_Low_Time, Last_Low_RSI); //--- Create trend line for RSI divergence
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_COLOR, Bull_Color); //--- Set line color
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_WIDTH, Line_Width); //--- Set line width
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_STYLE, Line_Style); //--- Set line style
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_RAY, false); //--- Disable ray
               ObjectSetInteger(chart_id, rsi_line, OBJPROP_BACK, false); //--- Set to foreground
            }
         }
      }
      // Draw swing label
      string swing_name = "SwingLow_" + TimeToString(Last_Low_Time); //--- Set swing low label name
      if (ObjectFind(chart_id, swing_name) < 0) { //--- Check if label exists
         ObjectCreate(chart_id, swing_name, OBJ_TEXT, 0, Last_Low_Time, Last_Low_Price); //--- Create swing low label
         ObjectSetString(chart_id, swing_name, OBJPROP_TEXT, " " + low_type + (bull_div ? " Bull Div" : "")); //--- Set label text
         ObjectSetInteger(chart_id, swing_name, OBJPROP_COLOR, Swing_Low_Color); //--- Set label color
         ObjectSetInteger(chart_id, swing_name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); //--- Set label anchor
         ObjectSetInteger(chart_id, swing_name, OBJPROP_FONTSIZE, Font_Size); //--- Set label font size
      }
      ChartRedraw(chart_id);                 //--- Redraw chart
   }
}

//+------------------------------------------------------------------+