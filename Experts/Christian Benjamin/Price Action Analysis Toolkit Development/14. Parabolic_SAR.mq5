//+------------------------------------------------------------------+
//|                                            Parabolic SAR EA.mql5 |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
//|               Price Action Analysis Toolkit Development          |
//|               Parabolic Stop and Reverse Tool                    |
//|               https://www.mql5.com/en/articles/17234             |
//+------------------------------------------------------------------+
#property copyright "2025, Christian Benjamin"
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.0"
#property strict

// Input parameters for the Parabolic SAR indicator
input double SARStep    = 0.1;  // Acceleration factor for PSAR
input double SARMaximum = 1;    // Maximum acceleration for PSAR

// Input parameters for refining the signal based on PSAR dots
input int    MinConsecutiveDots = 2;   // Require at least 2 consecutive bars in one trend before reversal
input double MaxDotGapPercentage  = 1.0; // Maximum allowed gap between consecutive PSAR dots (% of current close)

// Input parameters for alerts and arrow drawing
input bool   EnableAlerts  = true;            // Enable popup alerts
input bool   EnableSound   = true;            // Enable sound alerts
input bool   EnableArrows  = true;            // Draw arrows on chart
input string BuyArrowSymbol  = "233";         // Wingdings up arrow (as string)
input string SellArrowSymbol = "234";         // Wingdings down arrow (as string)
input int    ArrowWidth    = 2;               // Arrow thickness
input double ArrowOffsetMultiplier = 5;        // Multiplier for arrow placement offset

// Global indicator handle for PSAR
int sarHandle = INVALID_HANDLE;

// Global variable to track last processed bar time
datetime lastBarTime = 0;

// Enumeration for signal types
enum SignalType
  {
   NO_SIGNAL,
   BUY_SIGNAL,
   SELL_SIGNAL
  };

// Global variables for pending signal mechanism
SignalType pendingSignal = NO_SIGNAL;
int        waitCount     = 0;        // Counts new closed bars since signal detection
double     pendingReversalLevel = 0.0; // Stores the PSAR value at signal detection

//+------------------------------------------------------------------+
//| DrawSignalArrow - Draws an arrow object on the chart             |
//+------------------------------------------------------------------+
void DrawSignalArrow(string prefix, datetime barTime, double price, color arrowColor, long arrowCode)
  {
   string arrowName = prefix + "_" + TimeToString(barTime, TIME_SECONDS);
// Remove existing object with the same name to prevent duplicates
   if(ObjectFind(0, arrowName) != -1)
      ObjectDelete(0, arrowName);

// Create arrow object
   if(ObjectCreate(0, arrowName, OBJ_ARROW, 0, barTime, price))
     {
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, arrowColor);
      ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, arrowCode);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, ArrowWidth);
     }
   else
     {
      Print("Failed to create arrow object: ", arrowName);
     }
  }

//+------------------------------------------------------------------+
//| CheckForSignal - Evaluates PSAR and price data to determine signal |
//+------------------------------------------------------------------+
SignalType CheckForSignal(const double &sarArray[], const double &openArray[], const double &closeArray[])
  {
// Mapping indices:
// Index 0: Last closed bar (current candidate)
// Index 1: Previous bar
// Index 2: Bar before previous

   double sar0 = sarArray[0], sar1 = sarArray[1], sar2 = sarArray[2];
   double open0 = openArray[0], close0 = closeArray[0];
   double open1 = openArray[1], close1 = closeArray[1];
   double open2 = openArray[2], close2 = closeArray[2];

// --- BUY Signal Conditions ---
// A BUY signal is generated when:
// 1. The current bar is bullish (close > open) and its PSAR is below the close price.
// 2. The previous two bars have their PSAR dots above their close prices, indicating a prior downtrend.
// 3. The gap between the previous PSAR dots is within an acceptable threshold.
   if((close0 > open0) && (sar0 < close0) &&
      (sar1 > close1) && (sar2 > close2))
     {
      int countBearish = 0;
      if(sar1 > close1)
         countBearish++;
      if(sar2 > close2)
         countBearish++;
      double dotGap = MathAbs(sar1 - sar2);
      double gapThreshold = (MaxDotGapPercentage / 100.0) * close0;
      if(countBearish >= MinConsecutiveDots && dotGap <= gapThreshold)
         return BUY_SIGNAL;
     }

// --- SELL Signal Conditions ---
// A SELL signal is generated when:
// 1. The current bar is bearish (close < open) and its PSAR is above the close price.
// 2. The previous two bars have their PSAR dots below their close prices, indicating a prior uptrend.
// 3. The gap between the previous PSAR dots is within an acceptable threshold.
   if((close0 < open0) && (sar0 > close0) &&
      (sar1 < close1) && (sar2 < close2))
     {
      int countBullish = 0;
      if(sar1 < close1)
         countBullish++;
      if(sar2 < close2)
         countBullish++;
      double dotGap = MathAbs(sar1 - sar2);
      double gapThreshold = (MaxDotGapPercentage / 100.0) * close0;
      if(countBullish >= MinConsecutiveDots && dotGap <= gapThreshold)
         return SELL_SIGNAL;
     }

   return NO_SIGNAL;
  }

//+------------------------------------------------------------------+
//| IsNewBar - Determines if a new closed bar is available           |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime times[];
   if(CopyTime(_Symbol, _Period, 1, 1, times) <= 0)
     {
      Print("Failed to retrieve bar time in IsNewBar().");
      return false;
     }
   if(times[0] != lastBarTime)
     {
      lastBarTime = times[0];
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Create the built-in Parabolic SAR indicator handle
   sarHandle = iSAR(_Symbol, _Period, SARStep, SARMaximum);
   if(sarHandle == INVALID_HANDLE)
     {
      Print("Error creating PSAR handle");
      return INIT_FAILED;
     }
   Print("SAR EA initialized successfully.");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(sarHandle != INVALID_HANDLE)
      IndicatorRelease(sarHandle);

// Remove all arrow objects from the current chart window
   ObjectsDeleteAll(0, (int)OBJ_ARROW, 0);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Process only once per new closed bar
   if(!IsNewBar())
      return;

// Retrieve the last 4 PSAR values (we require at least 3 values)
   double sarArray[4];
   if(CopyBuffer(sarHandle, 0, 1, 4, sarArray) < 3)
     {
      Print("Failed to retrieve PSAR data.");
      return;
     }

// Retrieve the last 4 bars' price data (Open and Close)
   double openArray[4], closeArray[4];
   if(CopyOpen(_Symbol, _Period, 1, 4, openArray) < 3 ||
      CopyClose(_Symbol, _Period, 1, 4, closeArray) < 3)
     {
      Print("Failed to retrieve price data.");
      return;
     }

// --- Pending Signal Logic ---
// If a signal is pending, we wait for additional candle(s) to see if the price action confirms a reversal.
   if(pendingSignal != NO_SIGNAL)
     {
      waitCount++; // Increment waiting counter with each new closed candle

      if(pendingSignal == BUY_SIGNAL)
        {
         // For a pending BUY signal, if price falls at or below the reversal level,
         // the reversal is confirmed and the pending signal is cleared.
         if(closeArray[0] <= pendingReversalLevel)
           {
            Print("Reversal level reached for BUY signal. Close here.");
            if(EnableAlerts)
               Alert("Close here for BUY signal on ", _Symbol, " at price ", DoubleToString(closeArray[0], _Digits));
            if(EnableSound)
               PlaySound("alert.wav");
            pendingSignal = NO_SIGNAL;
            waitCount = 0;
           }
         else
            if(waitCount >= 3)
              {
               // If the reversal level is not reached within 3 candles,
               // then issue a warning that the signal might be false.
               Print("Warning: Possible fake BUY signal - reversal not confirmed in 3 candles.");
               if(EnableAlerts)
                  Alert("Warning: Possible fake BUY signal on ", _Symbol);
               pendingSignal = NO_SIGNAL;
               waitCount = 0;
              }
        }
      else
         if(pendingSignal == SELL_SIGNAL)
           {
            // For a pending SELL signal, if price rises at or above the reversal level,
            // the reversal is confirmed and the pending signal is cleared.
            if(closeArray[0] >= pendingReversalLevel)
              {
               Print("Reversal level reached for SELL signal. Close here.");
               if(EnableAlerts)
                  Alert("Close here for SELL signal on ", _Symbol, " at price ", DoubleToString(closeArray[0], _Digits));
               if(EnableSound)
                  PlaySound("alert.wav");
               pendingSignal = NO_SIGNAL;
               waitCount = 0;
              }
            else
               if(waitCount >= 3)
                 {
                  // If the reversal level is not reached within 3 candles,
                  // then issue a warning that the signal might be false.
                  Print("Warning: Possible fake SELL signal - reversal not confirmed in 3 candles.");
                  if(EnableAlerts)
                     Alert("Warning: Possible fake SELL signal on ", _Symbol);
                  pendingSignal = NO_SIGNAL;
                  waitCount = 0;
                 }
           }
      // Exit OnTick() as we are processing a pending signal
      return;
     }

// --- Signal Detection ---
// Check for a new reversal signal based on the current and previous bars.
   SignalType newSignal = CheckForSignal(sarArray, openArray, closeArray);
   if(newSignal != NO_SIGNAL)
     {
      // Set the new pending signal, reset wait counter, and define reversal level.
      pendingSignal = newSignal;
      waitCount = 0;
      pendingReversalLevel = sarArray[0]; // Use current PSAR value as the reversal level

      // For BUY signal: Draw an arrow and alert immediately,
      // then wait for confirmation (up to 3 candles).
      if(newSignal == BUY_SIGNAL)
        {
         Print("Buy signal detected on ", TimeToString(lastBarTime, TIME_DATE|TIME_SECONDS),
               ". Waiting for reversal confirmation (up to 3 candles).");
         if(EnableAlerts)
            Alert("Buy signal detected on ", _Symbol, " at price ", DoubleToString(closeArray[0], _Digits));
         if(EnableArrows)
           {
            double lowVal[];
            if(CopyLow(_Symbol, _Period, 1, 1, lowVal) > 0)
              {
               double offset = _Point * ArrowOffsetMultiplier;
               DrawSignalArrow("BuyArrow", lastBarTime, lowVal[0] - offset, clrGreen, StringToInteger(BuyArrowSymbol));
              }
            else
               Print("Failed to retrieve low price for arrow placement.");
           }
        }
      // For SELL signal: Draw an arrow and alert immediately,
      // then wait for confirmation (up to 3 candles).
      else
         if(newSignal == SELL_SIGNAL)
           {
            Print("Sell signal detected on ", TimeToString(lastBarTime, TIME_DATE|TIME_SECONDS),
                  ". Waiting for reversal confirmation (up to 3 candles).");
            if(EnableAlerts)
               Alert("Sell signal detected on ", _Symbol, " at price ", DoubleToString(closeArray[0], _Digits));
            if(EnableArrows)
              {
               double highVal[];
               if(CopyHigh(_Symbol, _Period, 1, 1, highVal) > 0)
                 {
                  double offset = _Point * ArrowOffsetMultiplier;
                  DrawSignalArrow("SellArrow", lastBarTime, highVal[0] + offset, clrRed, StringToInteger(SellArrowSymbol));
                 }
               else
                  Print("Failed to retrieve high price for arrow placement.");
              }
           }
     }
  }
//+------------------------------------------------------------------+
