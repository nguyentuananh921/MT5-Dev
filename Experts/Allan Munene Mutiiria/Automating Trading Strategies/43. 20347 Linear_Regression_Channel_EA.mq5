//+------------------------------------------------------------------+
//|                                 Linear Regression Channel EA.mq5 |
//|                           Copyright 2025, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade obj_Trade;                                                     //--- Trade object

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum TradeMode {                                                  // Define trade mode enum
   Normal,                                                        // Normal
   Inverse                                                        // Inverse
};

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input int      RegressionPeriod       = 100;                      // Period for regression calculation
input double   Deviations             = 2.0;                      // Standard deviation multiplier for channel
input double   MinSlopeThreshold      = 0.00001;                  // Min absolute slope to identify clear trend (low for detection)
input int      UpdateThresholdPercent = 30;                       // Update threshold in percent of channel width (e.g., 30 for 30%)
input double   ExtensionPercent       = 50.0;                     // Initial extension percent of channel length to the right
input TradeMode TradeDirection        = Normal;                   // Trade Mode
input double   Lots                   = 0.01;                     // Lot size
input int      StopLossPips           = 100;                       // Stop loss in pips
input int      TakeProfitPips         = 100;                      // Take profit in pips
input int      MaxBuys                = 2;                        // Maximum open buy positions
input int      MaxSells               = 2;                        // Maximum open sell positions
input int      MagicNumber            = 123456;                   // Magic number for positions
input int      Slippage               = 3;                        // Slippage

//--- Global variables
datetime lastBarTime    = 0;                                      //--- Last bar time
double   channelUpper, channelLower, channelMiddle;               //--- Channel levels
string   channelName    = "LRC_Channel";                          //--- Channel name
string   upperLabelName = "LRC_Upper_Label";                      //--- Upper label name
string   middleLabelName = "LRC_Middle_Label";                    //--- Middle label name
string   lowerLabelName = "LRC_Lower_Label";                      //--- Lower label name
bool     hasValidChannel = false;                                 //--- Valid channel flag
datetime fixedTimeOld   = 0;                                      //--- Fixed old time
double   slope_global   = 0, intercept_global = 0, stdDev_global = 0; //--- Global slope, intercept, stdDev
long     period_sec     = PeriodSeconds(_Period);                 //--- Period seconds
int      arrowCounter   = 0;                                      //--- Arrow counter
double   current_right_x = 0;                                     //--- Current right x

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   obj_Trade.SetExpertMagicNumber(MagicNumber);                       //--- Set magic number
   CreateChannelIfTrend();                                        //--- Initial try
   return(INIT_SUCCEEDED);                                        //--- Return success
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ChannelDelete(0, channelName);                                 //--- Delete channel
   ObjectDelete(0, upperLabelName);                               //--- Delete upper label
   ObjectDelete(0, middleLabelName);                              //--- Delete middle label
   ObjectDelete(0, lowerLabelName);                               //--- Delete lower label
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   // Check for new bar
   if (!IsNewBar()) return;                                       //--- Return if not new bar
   // Scan every bar if no channel
   if (!hasValidChannel) {                                        //--- Check no channel
      CreateChannelIfTrend();                                     //--- Create if trend
      if (!hasValidChannel) return;                               //--- Return if no channel
   }
   // Project values manually for completed bar (shift 1)
   datetime previousTime = iTime(_Symbol, _Period, 1);            //--- Get previous time
   int x = Bars(_Symbol, _Period, fixedTimeOld, previousTime) - 1; //--- Calc x
   channelMiddle = intercept_global + slope_global * x;           //--- Calc middle
   channelUpper = channelMiddle + Deviations * stdDev_global;     //--- Calc upper
   channelLower = channelMiddle - Deviations * stdDev_global;     //--- Calc lower
   // Project for shift 2
   datetime time2 = iTime(_Symbol, _Period, 2);                   //--- Get time 2
   if (time2 <= fixedTimeOld) return;                             //--- Return if invalid
   int x2 = Bars(_Symbol, _Period, fixedTimeOld, time2) - 1;      //--- Calc x2
   double middle2 = intercept_global + slope_global * x2;         //--- Calc middle2
   double upper2 = middle2 + Deviations * stdDev_global;          //--- Calc upper2
   double lower2 = middle2 - Deviations * stdDev_global;          //--- Calc lower2
   // Get closes
   double closePrevious = iClose(_Symbol, _Period, 1);            //--- Get close previous
   double close2 = iClose(_Symbol, _Period, 2);                   //--- Get close 2
   if (closePrevious == 0 || close2 == 0) return;                 //--- Return if invalid
   // Check if beyond end
   datetime current_time2 = (datetime)ObjectGetInteger(0, channelName + "_middle", OBJPROP_TIME, 1); //--- Get current time2
   if (previousTime > current_time2) {                            //--- Check beyond end
      Print("Bars beyond channel end: previousTime=" + TimeToString(previousTime) + ", current_time2=" + TimeToString(current_time2) + " - recreating channel"); //--- Log recreate
      CreateChannelIfTrend();                                     //--- Recreate channel
      return;                                                     //--- Return
   }
   // Check if breakout (deviation > threshold * width) for recreation
   double channelWidth = channelUpper - channelLower;             //--- Calc width
   double channelWidthPoints = channelWidth / _Point;             //--- Calc width points
   double updateThreshold = UpdateThresholdPercent / 100.0;       //--- Calc threshold
   double deviation = MathMax(closePrevious - channelUpper, channelLower - closePrevious); //--- Calc deviation
   double deviationPercent = (deviation / channelWidth) * 100;    //--- Calc percent
   if (deviation > updateThreshold * channelWidth) {              //--- Check breakout
      Print("Breakout detected - deviation: " + DoubleToString(deviation, _Digits) + " (" + DoubleToString(deviationPercent, 2) + "%), threshold: " + DoubleToString(updateThreshold * channelWidth, _Digits) + " (" + IntegerToString(UpdateThresholdPercent) + "%) - recreating channel"); //--- Log breakout
      CreateChannelIfTrend();                                     //--- Recreate channel
      return;                                                     //--- Return
   } else {                                                       //--- No breakout
      // Extend right by one bar if within
      datetime new_time2 = current_time2 + (datetime)period_sec;  //--- Calc new time2
      current_right_x += 1.0;                                     //--- Increment x
      double new_price_middle = intercept_global + slope_global * current_right_x; //--- Calc new middle
      double new_price_upper = new_price_middle + Deviations * stdDev_global; //--- Calc new upper
      double new_price_lower = new_price_middle - Deviations * stdDev_global; //--- Calc new lower
      // Move channels
      ObjectMove(0, channelName + "_um", 1, new_time2, new_price_upper); //--- Move um
      ObjectMove(0, channelName + "_ml", 1, new_time2, new_price_middle); //--- Move ml
      // Move trendlines
      ObjectMove(0, channelName + "_upper", 1, new_time2, new_price_upper); //--- Move upper
      ObjectMove(0, channelName + "_middle", 1, new_time2, new_price_middle); //--- Move middle
      ObjectMove(0, channelName + "_lower", 1, new_time2, new_price_lower); //--- Move lower
      UpdateLabels(new_time2);                                    //--- Update labels
      ChartRedraw(0);                                             //--- Redraw chart
   }
   // Count existing positions
   int buyCount = 0, sellCount = 0;                               //--- Init counts
   int total = PositionsTotal();                                  //--- Get total positions
   for (int i = total - 1; i >= 0; i--) {                         //--- Iterate reverse
      ulong ticket = PositionGetTicket(i);                        //--- Get ticket
      if (PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber) { //--- Check symbol magic
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy
            buyCount++;                                              //--- Increment buy
         } else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell
            sellCount++;                                             //--- Increment sell
         }
      }
   }
   // Close logic: Close all buys if crossed above middle, all sells if below
   if (closePrevious > channelMiddle) {                           //--- Check close above middle
      for (int i = PositionsTotal() - 1; i >= 0; i--) {           //--- Iterate reverse
         ulong ticket = PositionGetTicket(i);                     //--- Get ticket
         if (PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy
            obj_Trade.PositionClose(ticket, Slippage);                 //--- Close position
            Print("Closing Buy: Price " + DoubleToString(closePrevious, _Digits) + " crossed above middle channel " + DoubleToString(channelMiddle, _Digits)); //--- Log close
         }
      }
   }
   if (closePrevious < channelMiddle) {                           //--- Check close below middle
      for (int i = PositionsTotal() - 1; i >= 0; i--) {           //--- Iterate reverse
         ulong ticket = PositionGetTicket(i);                     //--- Get ticket
         if (PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell
            obj_Trade.PositionClose(ticket, Slippage);                 //--- Close position
            Print("Closing Sell: Price " + DoubleToString(closePrevious, _Digits) + " crossed below middle channel " + DoubleToString(channelMiddle, _Digits)); //--- Log close
         }
      }
   }
   // Open on clear breakout if room (with inverse option)
   bool buySignal = (close2 >= lower2) && (closePrevious < channelLower); //--- Buy signal
   bool sellSignal = (close2 <= upper2) && (closePrevious > channelUpper); //--- Sell signal
   if (TradeDirection == Inverse) {                               //--- Check inverse
      bool temp = buySignal;                                      //--- Temp buy
      buySignal = sellSignal;                                     //--- Swap buy
      sellSignal = temp;                                          //--- Swap sell
   }
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);            //--- Get ask
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);            //--- Get bid
   if (buySignal && buyCount < MaxBuys) {                         //--- Check buy signal
      // Buy
      double sl = (StopLossPips == 0) ? 0 : NormalizeDouble(ask - StopLossPips * _Point, _Digits); //--- Calc SL
      double tp = (TakeProfitPips == 0) ? 0 : NormalizeDouble(ask + TakeProfitPips * _Point, _Digits); //--- Calc TP
      if (obj_Trade.Buy(Lots, _Symbol, 0, sl, tp, "LRC Buy")) {      //--- Open buy
         Print("Buy signal: Price " + DoubleToString(closePrevious, _Digits) + " broke below lower channel from inside"); //--- Log signal
         DrawArrow(true, previousTime, closePrevious);            //--- Draw arrow
      } else {                                                    //--- Failed
         Print("Buy order failed: " + obj_Trade.ResultRetcodeDescription()); //--- Log failure
      }
   }
   if (sellSignal && sellCount < MaxSells) {                      //--- Check sell signal
      // Sell
      double sl = (StopLossPips == 0) ? 0 : NormalizeDouble(bid + StopLossPips * _Point, _Digits); //--- Calc SL
      double tp = (TakeProfitPips == 0) ? 0 : NormalizeDouble(bid - TakeProfitPips * _Point, _Digits); //--- Calc TP
      if (obj_Trade.Sell(Lots, _Symbol, 0, sl, tp, "LRC Sell")) {    //--- Open sell
         Print("Sell signal: Price " + DoubleToString(closePrevious, _Digits) + " broke above upper channel from inside"); //--- Log signal
         DrawArrow(false, previousTime, closePrevious);           //--- Draw arrow
      } else {                                                    //--- Failed
         Print("Sell order failed: " + obj_Trade.ResultRetcodeDescription()); //--- Log failure
      }
   }
}

//+------------------------------------------------------------------+
//| Check if new bar has opened                                      |
//+------------------------------------------------------------------+
bool IsNewBar() {
   datetime currentBarTime = iTime(_Symbol, _Period, 0);          //--- Get current time
   if (currentBarTime != lastBarTime) {                           //--- Check new
      lastBarTime = currentBarTime;                               //--- Update last
      return true;                                                //--- Return true
   }
   return false;                                                  //--- Return false
}

//+------------------------------------------------------------------+
//| Create channel if clear trend                                    |
//+------------------------------------------------------------------+
void CreateChannelIfTrend() {
   if (Bars(_Symbol, _Period) < RegressionPeriod + 1) return;     //--- Return if insufficient bars
   double closeArray[];                                           //--- Close array
   ArraySetAsSeries(closeArray, true);                            //--- Set as series
   if (CopyClose(_Symbol, _Period, 1, RegressionPeriod, closeArray) != RegressionPeriod) return; //--- Copy close or return
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;               //--- Init sums
   int n = RegressionPeriod;                                      //--- Set n
   for (int i = 0; i < n; i++) {                                  //--- Iterate
      double x = (double)(n - 1 - i);                             //--- Calc x
      double y = closeArray[i];                                   //--- Get y
      sumX += x;                                                  //--- Add x
      sumY += y;                                                  //--- Add y
      sumXY += x * y;                                             //--- Add xy
      sumX2 += x * x;                                             //--- Add x2
   }
   double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX); //--- Calc slope
   // Check for clear trend
   if (MathAbs(slope) < MinSlopeThreshold) {                      //--- Check no trend
      hasValidChannel = false;                                    //--- Reset channel
      ChannelDelete(0, channelName);                              //--- Delete channel
      ObjectDelete(0, upperLabelName);                            //--- Delete upper label
      ObjectDelete(0, middleLabelName);                           //--- Delete middle label
      ObjectDelete(0, lowerLabelName);                            //--- Delete lower label
      return;                                                     //--- Return
   }
   double intercept = (sumY - slope * sumX) / n;                  //--- Calc intercept
   // Calculate stdDev
   double sumRes2 = 0;                                            //--- Init res2 sum
   for (int i = 0; i < n; i++) {                                  //--- Iterate
      double x = (double)(n - 1 - i);                             //--- Calc x
      double predicted = intercept + slope * x;                   //--- Calc predicted
      double res = closeArray[i] - predicted;                     //--- Calc res
      sumRes2 += res * res;                                       //--- Add res2
   }
   double variance = sumRes2 / (n - 2);                           //--- Calc variance
   double stdDev = MathSqrt(variance);                            //--- Calc stdDev
   // Store for projection
   slope_global = slope;                                          //--- Set global slope
   intercept_global = intercept;                                  //--- Set global intercept
   stdDev_global = stdDev;                                        //--- Set global stdDev
   // Fixed anchors with initial extension (future time2)
   fixedTimeOld = iTime(_Symbol, _Period, RegressionPeriod);      //--- Set old time
   datetime fixedTimeNew = iTime(_Symbol, _Period, 1);            //--- Set new time
   long channel_sec = fixedTimeNew - fixedTimeOld;                //--- Calc channel sec
   long extension_sec = (long)(channel_sec * (ExtensionPercent / 100.0)); //--- Calc extension
   datetime time_extended = fixedTimeNew + (datetime)extension_sec; //--- Calc extended time
   current_right_x = (double)(time_extended - fixedTimeOld) / period_sec; //--- Calc right x
   // Delete old and create new
   ChannelDelete(0, channelName);                                 //--- Delete channel
   if (!ChannelCreate(0, channelName, 0, fixedTimeOld, time_extended)) return; //--- Create channel or return
   hasValidChannel = true;                                        //--- Set valid channel
   double channelWidth = 2 * Deviations * stdDev_global;          //--- Calc width
   double channelWidthPoints = channelWidth / _Point;             //--- Calc width points
   Print("Channel created: slope=" + DoubleToString(slope, 8) + ", range=" + DoubleToString(channelWidth, _Digits) + " (" + DoubleToString(channelWidthPoints, 0) + " points), times: " + TimeToString(fixedTimeOld) + " to " + TimeToString(time_extended)); //--- Log channel
   UpdateLabels(time_extended);                                   //--- Update labels
   ChartRedraw(0);                                                //--- Redraw chart
}

//+------------------------------------------------------------------+
//| Create Linear Regression Channel using channels for fill and trendlines for lines |
//+------------------------------------------------------------------+
bool ChannelCreate(const long chart_ID, const string name, const int sub_window, datetime time1, datetime time2) {
   double price1_middle = intercept_global;                       //--- Price1 middle
   double price2_middle = intercept_global + slope_global * current_right_x; //--- Price2 middle
   double price1_upper = price1_middle + Deviations * stdDev_global; //--- Price1 upper
   double price2_upper = price2_middle + Deviations * stdDev_global; //--- Price2 upper
   double price1_lower = price1_middle - Deviations * stdDev_global; //--- Price1 lower
   double price2_lower = price2_middle - Deviations * stdDev_global; //--- Price2 lower
   // Upper-middle fill channel
   string um_name = name + "_um";                                 //--- UM name
   if (!ObjectCreate(chart_ID, um_name, OBJ_CHANNEL, sub_window, time1, price1_upper, time2, price2_upper, time1, price1_middle)) { //--- Create UM channel
      Print(__FUNCTION__, ": failed to create upper-middle channel! Error code = ", GetLastError()); //--- Log error
      return(false);                                              //--- Return failure
   }
   ObjectSetInteger(chart_ID, um_name, OBJPROP_COLOR, clrPink);   //--- Set color
   ObjectSetInteger(chart_ID, um_name, OBJPROP_STYLE, STYLE_SOLID); //--- Set style
   ObjectSetInteger(chart_ID, um_name, OBJPROP_WIDTH, 1);         //--- Set width
   ObjectSetInteger(chart_ID, um_name, OBJPROP_FILL, true);       //--- Set fill
   ObjectSetInteger(chart_ID, um_name, OBJPROP_BACK, true);       //--- Set back
   ObjectSetInteger(chart_ID, um_name, OBJPROP_SELECTABLE, true); //--- Set selectable
   ObjectSetInteger(chart_ID, um_name, OBJPROP_SELECTED, false);  //--- Set not selected
   ObjectSetInteger(chart_ID, um_name, OBJPROP_RAY_RIGHT, false); //--- Set no ray
   ObjectSetInteger(chart_ID, um_name, OBJPROP_HIDDEN, false);    //--- Set not hidden
   ObjectSetInteger(chart_ID, um_name, OBJPROP_ZORDER, 0);        //--- Set zorder
   // Middle-lower fill channel
   string ml_name = name + "_ml";                                 //--- ML name
   if (!ObjectCreate(chart_ID, ml_name, OBJ_CHANNEL, sub_window, time1, price1_middle, time2, price2_middle, time1, price1_lower)) { //--- Create ML channel
      Print(__FUNCTION__, ": failed to create middle-lower channel! Error code = ", GetLastError()); //--- Log error
      return(false);                                              //--- Return failure
   }
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_COLOR, clrLightGreen); //--- Set color
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_STYLE, STYLE_SOLID); //--- Set style
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_WIDTH, 1);         //--- Set width
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_FILL, true);       //--- Set fill
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_BACK, true);       //--- Set back
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_SELECTABLE, true); //--- Set selectable
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_SELECTED, false);  //--- Set not selected
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_RAY_RIGHT, false); //--- Set no ray
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_HIDDEN, false);    //--- Set not hidden
   ObjectSetInteger(chart_ID, ml_name, OBJPROP_ZORDER, 0);        //--- Set zorder
   // Upper trendline
   string upper_name = name + "_upper";                           //--- Upper name
   if (!ObjectCreate(chart_ID, upper_name, OBJ_TREND, sub_window, time1, price1_upper, time2, price2_upper)) { //--- Create upper trend
      Print(__FUNCTION__, ": failed to create upper trendline! Error code = ", GetLastError()); //--- Log error
      return(false);                                              //--- Return failure
   }
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_COLOR, clrRed); //--- Set color
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_STYLE, STYLE_SOLID); //--- Set style
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_WIDTH, 1);      //--- Set width
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_BACK, false);   //--- Set foreground
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_SELECTABLE, true); //--- Set selectable
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_SELECTED, false); //--- Set not selected
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_RAY_RIGHT, false); //--- Set no ray
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_HIDDEN, false); //--- Set not hidden
   ObjectSetInteger(chart_ID, upper_name, OBJPROP_ZORDER, 1);     //--- Set zorder
   // Middle trendline
   string middle_name = name + "_middle";                         //--- Middle name
   if (!ObjectCreate(chart_ID, middle_name, OBJ_TREND, sub_window, time1, price1_middle, time2, price2_middle)) { //--- Create middle trend
      Print(__FUNCTION__, ": failed to create middle trendline! Error code = ", GetLastError()); //--- Log error
      return(false);                                              //--- Return failure
   }
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_COLOR, clrBlue); //--- Set color
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_STYLE, STYLE_SOLID); //--- Set style
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_WIDTH, 1);     //--- Set width
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_BACK, false);  //--- Set foreground
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_SELECTABLE, true); //--- Set selectable
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_SELECTED, false); //--- Set not selected
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_RAY_RIGHT, false); //--- Set no ray
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_HIDDEN, false); //--- Set not hidden
   ObjectSetInteger(chart_ID, middle_name, OBJPROP_ZORDER, 1);    //--- Set zorder
   // Lower trendline
   string lower_name = name + "_lower";                           //--- Lower name
   if (!ObjectCreate(chart_ID, lower_name, OBJ_TREND, sub_window, time1, price1_lower, time2, price2_lower)) { //--- Create lower trend
      Print(__FUNCTION__, ": failed to create lower trendline! Error code = ", GetLastError()); //--- Log error
      return(false);                                              //--- Return failure
   }
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_COLOR, clrGreen); //--- Set color
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_STYLE, STYLE_SOLID); //--- Set style
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_WIDTH, 1);      //--- Set width
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_BACK, false);   //--- Set foreground
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_SELECTABLE, true); //--- Set selectable
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_SELECTED, false); //--- Set not selected
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_RAY_RIGHT, false); //--- Set no ray
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_HIDDEN, false); //--- Set not hidden
   ObjectSetInteger(chart_ID, lower_name, OBJPROP_ZORDER, 1);     //--- Set zorder
   return(true);                                                  //--- Return success
}

//+------------------------------------------------------------------+
//| Delete the channel                                               |
//+------------------------------------------------------------------+
bool ChannelDelete(const long chart_ID, const string name) {
   bool success = true;                                           //--- Init success
   if (!ObjectDelete(chart_ID, name + "_um")) {                   //--- Delete um
      Print(__FUNCTION__, ": failed to delete um! Error code = ", GetLastError()); //--- Log error
      success = false;                                            //--- Set failure
   }
   if (!ObjectDelete(chart_ID, name + "_ml")) {                   //--- Delete ml
      Print(__FUNCTION__, ": failed to delete ml! Error code = ", GetLastError()); //--- Log error
      success = false;                                            //--- Set failure
   }
   if (!ObjectDelete(chart_ID, name + "_upper")) {                //--- Delete upper
      Print(__FUNCTION__, ": failed to delete upper! Error code = ", GetLastError()); //--- Log error
      success = false;                                            //--- Set failure
   }
   if (!ObjectDelete(chart_ID, name + "_middle")) {               //--- Delete middle
      Print(__FUNCTION__, ": failed to delete middle! Error code = ", GetLastError()); //--- Log error
      success = false;                                            //--- Set failure
   }
   if (!ObjectDelete(chart_ID, name + "_lower")) {                //--- Delete lower
      Print(__FUNCTION__, ": failed to delete lower! Error code = ", GetLastError()); //--- Log error
      success = false;                                            //--- Set failure
   }
   return(success);                                               //--- Return success
}

//+------------------------------------------------------------------+
//| Draw arrow on chart for signal                                   |
//+------------------------------------------------------------------+
void DrawArrow(bool isBuy, datetime time, double price) {
   string name = "SignalArrow_" + IntegerToString(arrowCounter++); //--- Arrow name
   ObjectCreate(0, name, OBJ_ARROW, 0, time, price);              //--- Create arrow
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, isBuy ? 233 : 234); //--- Set code
   ObjectSetInteger(0, name, OBJPROP_COLOR, isBuy ? clrGreen : clrRed); //--- Set color
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);                   //--- Set width
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, isBuy ? ANCHOR_TOP : ANCHOR_BOTTOM); //--- Set anchor
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);          //--- Set not selectable
   ChartRedraw(0);                                                //--- Redraw chart
}

//+------------------------------------------------------------------+
//| Update channel labels                                            |
//+------------------------------------------------------------------+
void UpdateLabels(datetime labelTime) {
   double label_x = (double)(labelTime - fixedTimeOld) / period_sec; //--- Calc label x
   double middlePrice = intercept_global + slope_global * label_x; //--- Calc middle
   double upperPrice = middlePrice + Deviations * stdDev_global;  //--- Calc upper
   double lowerPrice = middlePrice - Deviations * stdDev_global;  //--- Calc lower
   // Upper label
   if (ObjectFind(0, upperLabelName) < 0) {                       //--- Check no upper label
      ObjectCreate(0, upperLabelName, OBJ_TEXT, 0, labelTime, upperPrice); //--- Create upper label
   } else {                                                       //--- Exists
      ObjectMove(0, upperLabelName, 0, labelTime, upperPrice);   //--- Move upper label
   }
   ObjectSetString(0, upperLabelName, OBJPROP_TEXT, "Upper Channel"); //--- Set text
   ObjectSetInteger(0, upperLabelName, OBJPROP_COLOR, clrRed);    //--- Set color
   ObjectSetInteger(0, upperLabelName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); //--- Set anchor
   ObjectSetInteger(0, upperLabelName, OBJPROP_SELECTABLE, false); //--- Set not selectable
   // Middle label
   if (ObjectFind(0, middleLabelName) < 0) {                      //--- Check no middle label
      ObjectCreate(0, middleLabelName, OBJ_TEXT, 0, labelTime, middlePrice); //--- Create middle label
   } else {                                                       //--- Exists
      ObjectMove(0, middleLabelName, 0, labelTime, middlePrice); //--- Move middle label
   }
   ObjectSetString(0, middleLabelName, OBJPROP_TEXT, "Middle Channel"); //--- Set text
   ObjectSetInteger(0, middleLabelName, OBJPROP_COLOR, clrBlue);  //--- Set color
   ObjectSetInteger(0, middleLabelName, OBJPROP_ANCHOR, ANCHOR_LEFT); //--- Set anchor
   ObjectSetInteger(0, middleLabelName, OBJPROP_SELECTABLE, false); //--- Set not selectable
   // Lower label
   if (ObjectFind(0, lowerLabelName) < 0) {                       //--- Check no lower label
      ObjectCreate(0, lowerLabelName, OBJ_TEXT, 0, labelTime, lowerPrice); //--- Create lower label
   } else {                                                       //--- Exists
      ObjectMove(0, lowerLabelName, 0, labelTime, lowerPrice);   //--- Move lower label
   }
   ObjectSetString(0, lowerLabelName, OBJPROP_TEXT, "Lower Channel"); //--- Set text
   ObjectSetInteger(0, lowerLabelName, OBJPROP_COLOR, clrGreen);  //--- Set color
   ObjectSetInteger(0, lowerLabelName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); //--- Set anchor
   ObjectSetInteger(0, lowerLabelName, OBJPROP_SELECTABLE, false); //--- Set not selectable
   ChartRedraw(0);                                                //--- Redraw chart
}
//+------------------------------------------------------------------+