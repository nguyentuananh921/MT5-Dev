//+------------------------------------------------------------------+
//|                        Copyright 2025, Forex Algo-Trader, Allan. |
//|                                 "https://t.me/Forex_Algo_Trader" |
//+------------------------------------------------------------------+
#property copyright "Forex Algo-Trader, Allan"
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property description "This EA trades based on Trend Flat Momentum Strategy"
#property strict

#include <Trade\Trade.mqh> //--- Include the Trade library for order management.
CTrade obj_Trade; //--- Create an instance of the CTrade class to handle trading operations.

// Input parameters
input int    InpCCI36Period      = 36;              //--- CCI period 1
input int    InpCCI55Period      = 55;              //--- CCI period 2
input int    InpRSIPeriod        = 27;              //--- RSI period
input int    InpMAFastPeriod     = 11;              //--- Fast MA period
input int    InpMASlowPeriod     = 25;              //--- Slow MA period
input double InpRSIThreshold     = 58.0;            //--- RSI threshold for Buy signal (Sell uses 100 - Threshold)
input int    InpTakeProfitPoints = 300;             //--- Take profit in points
input double InpLotSize          = 0.1;             //--- Trade lot size

// Pivot parameters for detecting swing highs/lows
input int    PivotLeft  = 2;  //--- Number of bars to the left for pivot detection
input int    PivotRight = 2;  //--- Number of bars to the right for pivot detection

// Global indicator handles
int handleCCI36;  //--- Handle for the CCI indicator with period InpCCI36Period
int handleCCI55;  //--- Handle for the CCI indicator with period InpCCI55Period
int handleRSI;    //--- Handle for the RSI indicator with period InpRSIPeriod
int handleMA11;   //--- Handle for the fast moving average (MA) with period InpMAFastPeriod
int handleMA25;   //--- Handle for the slow moving average (MA) with period InpMASlowPeriod

// Global dynamic storage buffers
double ma11_buffer[];  //--- Dynamic array to store fast MA values
double ma25_buffer[];  //--- Dynamic array to store slow MA values
double rsi_buffer[];   //--- Dynamic array to store RSI values
double cci36_buffer[]; //--- Dynamic array to store CCI values (period 36)
double cci55_buffer[]; //--- Dynamic array to store CCI values (period 55)

// To detect a new bar
datetime lastBarTime = 0;  //--- Variable to store the time of the last processed bar

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   //--- Create CCI handle for period InpCCI36Period using the close price.
   handleCCI36 = iCCI(_Symbol, _Period, InpCCI36Period, PRICE_CLOSE); //--- Create the CCI36 indicator handle.
   if (handleCCI36 == INVALID_HANDLE) { //--- Check if the CCI36 handle is valid.
      Print("Error creating CCI36 handle"); //--- Print an error message if invalid.
      return (INIT_FAILED); //--- Return failure if handle creation failed.
   }
   
   //--- Create CCI handle for period InpCCI55Period using the close price.
   handleCCI55 = iCCI(_Symbol, _Period, InpCCI55Period, PRICE_CLOSE); //--- Create the CCI55 indicator handle.
   if (handleCCI55 == INVALID_HANDLE) { //--- Check if the CCI55 handle is valid.
      Print("Error creating CCI55 handle"); //--- Print an error message if invalid.
      return (INIT_FAILED); //--- Return failure if handle creation failed.
   }
   
   //--- Create RSI handle for period InpRSIPeriod using the close price.
   handleRSI = iRSI(_Symbol, _Period, InpRSIPeriod, PRICE_CLOSE); //--- Create the RSI indicator handle.
   if (handleRSI == INVALID_HANDLE) { //--- Check if the RSI handle is valid.
      Print("Error creating RSI handle"); //--- Print an error message if invalid.
      return (INIT_FAILED); //--- Return failure if handle creation failed.
   }
   
   //--- Create fast MA handle using MODE_SMMA on the median price with period InpMAFastPeriod.
   handleMA11 = iMA(_Symbol, _Period, InpMAFastPeriod, 0, MODE_SMMA, PRICE_MEDIAN); //--- Create the fast MA handle.
   if (handleMA11 == INVALID_HANDLE) { //--- Check if the fast MA handle is valid.
      Print("Error creating MA11 handle"); //--- Print an error message if invalid.
      return (INIT_FAILED); //--- Return failure if handle creation failed.
   }
   
   //--- Create slow MA handle using MODE_SMMA on the median price with period InpMASlowPeriod.
   handleMA25 = iMA(_Symbol, _Period, InpMASlowPeriod, 0, MODE_SMMA, PRICE_MEDIAN); //--- Create the slow MA handle.
   if (handleMA25 == INVALID_HANDLE) { //--- Check if the slow MA handle is valid.
      Print("Error creating MA25 handle"); //--- Print an error message if invalid.
      return (INIT_FAILED); //--- Return failure if handle creation failed.
   }
   
   //--- Set the dynamic arrays as time series (index 0 = most recent closed bar).
   ArraySetAsSeries(ma11_buffer, true); //--- Set ma11_buffer as a time series.
   ArraySetAsSeries(ma25_buffer, true); //--- Set ma25_buffer as a time series.
   ArraySetAsSeries(rsi_buffer, true);  //--- Set rsi_buffer as a time series.
   ArraySetAsSeries(cci36_buffer, true); //--- Set cci36_buffer as a time series.
   ArraySetAsSeries(cci55_buffer, true); //--- Set cci55_buffer as a time series.
   
   return (INIT_SUCCEEDED); //--- Return success after initialization.
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if (handleCCI36 != INVALID_HANDLE) { //--- If the CCI36 handle is valid,
      IndicatorRelease(handleCCI36); //--- release the CCI36 indicator.
   }
   if (handleCCI55 != INVALID_HANDLE) { //--- If the CCI55 handle is valid,
      IndicatorRelease(handleCCI55); //--- release the CCI55 indicator.
   }
   if (handleRSI != INVALID_HANDLE) { //--- If the RSI handle is valid,
      IndicatorRelease(handleRSI); //--- release the RSI indicator.
   }
   if (handleMA11 != INVALID_HANDLE) { //--- If the fast MA handle is valid,
      IndicatorRelease(handleMA11); //--- release the fast MA indicator.
   }
   if (handleMA25 != INVALID_HANDLE) { //--- If the slow MA handle is valid,
      IndicatorRelease(handleMA25); //--- release the slow MA indicator.
   }
}

//+------------------------------------------------------------------+
//| Function to find the most recent swing low (pivot low)           |
//+------------------------------------------------------------------+
double GetPivotLow(int left, int right) {
   MqlRates rates[]; //--- Declare an array to store rate data.
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, _Period, 0, 100, rates); //--- Copy the last 100 bars into the rates array.
   if (copied <= (left + right)) { //--- Check if sufficient data was copied.
      return (0); //--- Return 0 if there are not enough bars.
   }
   
   //--- Loop through the bars to find a pivot low.
   for (int i = left; i <= copied - right - 1; i++) {
      bool isPivot = true; //--- Assume the current bar is a pivot low.
      double currentLow = rates[i].low; //--- Get the low value of the current bar.
      for (int j = i - left; j <= i + right; j++) { //--- Loop through neighboring bars.
         if (j == i) { //--- Skip the current bar.
            continue;
         }
         if (rates[j].low <= currentLow) { //--- If any neighbor's low is lower or equal,
            isPivot = false; //--- then the current bar is not a pivot low.
            break;
         }
      }
      if (isPivot) { //--- If a pivot low is confirmed,
         return (currentLow); //--- return the low value of the pivot.
      }
   }
   return (0); //--- Return 0 if no pivot low is found.
}

//+------------------------------------------------------------------+
//| Function to find the most recent swing high (pivot high)         |
//+------------------------------------------------------------------+
double GetPivotHigh(int left, int right) {
   MqlRates rates[]; //--- Declare an array to store rate data.
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, _Period, 0, 100, rates); //--- Copy the last 100 bars into the rates array.
   if (copied <= (left + right)) { //--- Check if sufficient data was copied.
      return (0); //--- Return 0 if there are not enough bars.
   }
   
   //--- Loop through the bars to find a pivot high.
   for (int i = left; i <= copied - right - 1; i++) {
      bool isPivot = true; //--- Assume the current bar is a pivot high.
      double currentHigh = rates[i].high; //--- Get the high value of the current bar.
      for (int j = i - left; j <= i + right; j++) { //--- Loop through neighboring bars.
         if (j == i) { //--- Skip the current bar.
            continue;
         }
         if (rates[j].high >= currentHigh) { //--- If any neighbor's high is higher or equal,
            isPivot = false; //--- then the current bar is not a pivot high.
            break;
         }
      }
      if (isPivot) { //--- If a pivot high is confirmed,
         return (currentHigh); //--- return the high value of the pivot.
      }
   }
   return (0); //--- Return 0 if no pivot high is found.
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   //--- Get the time of the current bar.
   datetime currentBarTime = iTime(_Symbol, _Period, 0); //--- Retrieve the current bar's time.
   if (currentBarTime != lastBarTime) { //--- If a new bar has formed,
      lastBarTime = currentBarTime; //--- update lastBarTime with the current bar's time.
      OnNewBar(); //--- Process the new bar.
   }
}

//+------------------------------------------------------------------+
//| Function called on every new bar (bar close)                     |
//+------------------------------------------------------------------+
void OnNewBar() {
   
   //--- Resize the dynamic arrays to hold 2 values (last closed bar and the one before).
   ArrayResize(ma11_buffer, 2); //--- Resize ma11_buffer to 2 elements.
   ArrayResize(ma25_buffer, 2); //--- Resize ma25_buffer to 2 elements.
   ArrayResize(rsi_buffer, 2);  //--- Resize rsi_buffer to 2 elements.
   ArrayResize(cci36_buffer, 2); //--- Resize cci36_buffer to 2 elements.
   ArrayResize(cci55_buffer, 2); //--- Resize cci55_buffer to 2 elements.
   
   //--- Copy indicator values into the dynamic arrays.
   if (CopyBuffer(handleMA11, 0, 1, 2, ma11_buffer) != 2) { //--- Copy 2 values from the fast MA indicator.
      return; //--- Exit the function if copying fails.
   }
   if (CopyBuffer(handleMA25, 0, 1, 2, ma25_buffer) != 2) { //--- Copy 2 values from the slow MA indicator.
      return; //--- Exit the function if copying fails.
   }
   if (CopyBuffer(handleRSI, 0, 1, 2, rsi_buffer) != 2) { //--- Copy 2 values from the RSI indicator.
      return; //--- Exit the function if copying fails.
   }
   if (CopyBuffer(handleCCI36, 0, 1, 2, cci36_buffer) != 2) { //--- Copy 2 values from the CCI36 indicator.
      return; //--- Exit the function if copying fails.
   }
   if (CopyBuffer(handleCCI55, 0, 1, 2, cci55_buffer) != 2) { //--- Copy 2 values from the CCI55 indicator.
      return; //--- Exit the function if copying fails.
   }
   
   //--- For clarity, assign the values from the arrays.
   //--- Index 0: last closed bar, Index 1: bar before.
   double ma11_current   = ma11_buffer[0]; //--- Fast MA value for the last closed bar.
   double ma11_previous  = ma11_buffer[1]; //--- Fast MA value for the previous bar.
   double ma25_current   = ma25_buffer[0]; //--- Slow MA value for the last closed bar.
   double ma25_previous  = ma25_buffer[1]; //--- Slow MA value for the previous bar.
   double rsi_current    = rsi_buffer[0];  //--- RSI value for the last closed bar.
   double cci36_current  = cci36_buffer[0]; //--- CCI36 value for the last closed bar.
   double cci55_current  = cci55_buffer[0]; //--- CCI55 value for the last closed bar.
   
   //--- Check for Buy Conditions:
   bool maCrossoverBuy    = (ma11_previous < ma25_previous) && (ma11_current > ma25_current); //--- True if fast MA crosses above slow MA.
   bool rsiConditionBuy   = (rsi_current > InpRSIThreshold); //--- True if RSI is above the Buy threshold.
   bool cci36ConditionBuy = (cci36_current > 0); //--- True if CCI36 is positive.
   bool cci55ConditionBuy = (cci55_current > 0); //--- True if CCI55 is positive.
   
   if (maCrossoverBuy) { //--- If crossover for MA Buy is true...
      bool conditionsOk = true; //--- Initialize a flag to track if all conditions are met.
      
      //--- Check RSI condition for Buy.
      if (!rsiConditionBuy) { //--- If the RSI condition is not met...
         Print("Buy signal rejected: RSI condition not met. RSI=", rsi_current, " Threshold=", InpRSIThreshold); //--- Notify the user.
         conditionsOk = false; //--- Mark the conditions as not met.
      }
      //--- Check CCI36 condition for Buy.
      if (!cci36ConditionBuy) { //--- If the CCI36 condition is not met...
         Print("Buy signal rejected: CCI36 condition not met. CCI36=", cci36_current); //--- Notify the user.
         conditionsOk = false; //--- Mark the conditions as not met.
      }
      //--- Check CCI55 condition for Buy.
      if (!cci55ConditionBuy) { //--- If the CCI55 condition is not met...
         Print("Buy signal rejected: CCI55 condition not met. CCI55=", cci55_current); //--- Notify the user.
         conditionsOk = false; //--- Mark the conditions as not met.
      }
      
      if (conditionsOk) { //--- If all Buy conditions are met...
         //--- Get stop loss from previous swing low.
         double stopLoss = GetPivotLow(PivotLeft, PivotRight); //--- Use pivot low as the stop loss.
         if (stopLoss <= 0) { //--- If no valid pivot low is found...
            stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_BID); //--- Fallback to current bid price.
         }
         
         double entryPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK); //--- Determine entry price as current ask price.
         double tp         = entryPrice + InpTakeProfitPoints * _Point; //--- Calculate take profit based on fixed points.
         
         //--- Print the swing point (pivot low) used as stop loss.
         Print("Buy signal: Swing Low used as Stop Loss = ", stopLoss); //--- Notify the user of the pivot low used.
         
         if (obj_Trade.Buy(InpLotSize, NULL, entryPrice, stopLoss, tp, "Buy Order")) { //--- Attempt to open a Buy order.
            Print("Buy order opened at ", entryPrice); //--- Notify the user if the order is opened successfully.
         }
         else {
            Print("Buy order failed: ", obj_Trade.ResultRetcodeDescription()); //--- Notify the user if the order fails.
         }
         
         return; //--- Exit after processing a valid Buy signal.
      }
      else {
         Print("Buy signal not executed due to failed condition(s)."); //--- Notify the user if Buy conditions failed.
      }
   }
   
   //--- Check for Sell Conditions:
   bool maCrossoverSell    = (ma11_previous > ma25_previous) && (ma11_current < ma25_current); //--- True if fast MA crosses below slow MA.
   bool rsiConditionSell   = (rsi_current < (100.0 - InpRSIThreshold)); //--- True if RSI is below the Sell threshold.
   bool cci36ConditionSell = (cci36_current < 0); //--- True if CCI36 is negative.
   bool cci55ConditionSell = (cci55_current < 0); //--- True if CCI55 is negative.
   
   if (maCrossoverSell) { //--- If crossover for MA Sell is true...
      bool conditionsOk = true; //--- Initialize a flag to track if all conditions are met.
      
      //--- Check RSI condition for Sell.
      if (!rsiConditionSell) { //--- If the RSI condition is not met...
         Print("Sell signal rejected: RSI condition not met. RSI=", rsi_current, " Required below=", (100.0 - InpRSIThreshold)); //--- Notify the user.
         conditionsOk = false; //--- Mark the conditions as not met.
      }
      //--- Check CCI36 condition for Sell.
      if (!cci36ConditionSell) { //--- If the CCI36 condition is not met...
         Print("Sell signal rejected: CCI36 condition not met. CCI36=", cci36_current); //--- Notify the user.
         conditionsOk = false; //--- Mark the conditions as not met.
      }
      //--- Check CCI55 condition for Sell.
      if (!cci55ConditionSell) { //--- If the CCI55 condition is not met...
         Print("Sell signal rejected: CCI55 condition not met. CCI55=", cci55_current); //--- Notify the user.
         conditionsOk = false; //--- Mark the conditions as not met.
      }
      
      if (conditionsOk) { //--- If all Sell conditions are met...
         //--- Get stop loss from previous swing high.
         double stopLoss = GetPivotHigh(PivotLeft, PivotRight); //--- Use pivot high as the stop loss.
         if (stopLoss <= 0) { //--- If no valid pivot high is found...
            stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_ASK); //--- Fallback to current ask price.
         }
         
         double entryPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID); //--- Determine entry price as current bid price.
         double tp         = entryPrice - InpTakeProfitPoints * _Point; //--- Calculate take profit based on fixed points.
         
         //--- Print the swing point (pivot high) used as stop loss.
         Print("Sell signal: Swing High used as Stop Loss = ", stopLoss); //--- Notify the user of the pivot high used.
         
         if (obj_Trade.Sell(InpLotSize, NULL, entryPrice, stopLoss, tp, "Sell Order")) { //--- Attempt to open a Sell order.
            Print("Sell order opened at ", entryPrice); //--- Notify the user if the order is opened successfully.
         }
         else {
            Print("Sell order failed: ", obj_Trade.ResultRetcodeDescription()); //--- Notify the user if the order fails.
         }
         
         return; //--- Exit after processing a valid Sell signal.
      }
      else {
         Print("Sell signal not executed due to failed condition(s)."); //--- Notify the user if Sell conditions failed.
      }
   }
}
