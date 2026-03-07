//+------------------------------------------------------------------+
//|                                              Pulse Trader EA.mq5 |
//|                                   Copyright 2026, MetaQuotes Ltd.|
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
//|               Price Action Analysis Toolkit Development          |
//|               Signal Pulse EA                                    |
//|               https://www.mql5.com/en/articles/16861             |
//+------------------------------------------------------------------+
#property copyright "Christian Benjamin"
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

// Input parameters
input ENUM_TIMEFRAMES Timeframe1 = PERIOD_M5; // M5 timeframe
input ENUM_TIMEFRAMES Timeframe2 = PERIOD_M15; // M15 timeframe
input ENUM_TIMEFRAMES Timeframe3 = PERIOD_M30;  // M30 timeframe
input int BB_Period = 20;                      // Bollinger Bands period
input double BB_Deviation = 2.0;               // Bollinger Bands deviation
input int K_Period = 14;                       // Stochastic %K period
input int D_Period = 3;                        // Stochastic %D period
input int Slowing = 3;                         // Stochastic slowing
input double SignalOffset = 10.0;              // Offset in points for signal arrow
input int TestBars = 10;                       // Number of bars after signal to test win condition
input double MinArrowDistance = 5.0;          // Minimum distance in points between arrows to avoid overlapping

// Signal tracking structure
struct SignalInfo
  {
   datetime          time;
   double            price;
   bool              isBuySignal;
  };

// Arrays to store signal information
datetime signalTimes[];
double signalPrices[];
bool signalBuySignals[];

//+------------------------------------------------------------------+
//| Retrieve Bollinger Band Levels                                   |
//+------------------------------------------------------------------+
bool GetBollingerBands(ENUM_TIMEFRAMES timeframe, double &upper, double &lower, double &middle)
  {
   int handle = iBands(Symbol(), timeframe, BB_Period, 0, BB_Deviation, PRICE_CLOSE);

   if(handle == INVALID_HANDLE)
     {
      Print("Error creating iBands for timeframe: ", timeframe);
      return false;
     }

   double upperBand[], middleBand[], lowerBand[];

   if(!CopyBuffer(handle, 1, 0, 1, upperBand) ||
      !CopyBuffer(handle, 0, 0, 1, middleBand) ||
      !CopyBuffer(handle, 2, 0, 1, lowerBand))
     {
      Print("Error copying iBands buffer for timeframe: ", timeframe);
      IndicatorRelease(handle);
      return false;
     }

   upper = upperBand[0];
   middle = middleBand[0];
   lower = lowerBand[0];

   IndicatorRelease(handle);
   return true;
  }

//+------------------------------------------------------------------+
//| Retrieve Stochastic Levels                                       |
//+------------------------------------------------------------------+
bool GetStochastic(ENUM_TIMEFRAMES timeframe, double &k_value, double &d_value)
  {
   int handle = iStochastic(Symbol(), timeframe, K_Period, D_Period, Slowing, MODE_SMA, STO_CLOSECLOSE);

   if(handle == INVALID_HANDLE)
     {
      Print("Error creating iStochastic for timeframe: ", timeframe);
      return false;
     }

   double kBuffer[], dBuffer[];

   if(!CopyBuffer(handle, 0, 0, 1, kBuffer) ||  // %K line
      !CopyBuffer(handle, 1, 0, 1, dBuffer))   // %D line
     {
      Print("Error copying iStochastic buffer for timeframe: ", timeframe);
      IndicatorRelease(handle);
      return false;
     }

   k_value = kBuffer[0];
   d_value = dBuffer[0];

   IndicatorRelease(handle);
   return true;
  }

//+------------------------------------------------------------------+
//| Check and Generate Signal                                        |
//+------------------------------------------------------------------+
void CheckAndGenerateSignal()
  {
   double upper1, lower1, middle1, close1;
   double upper2, lower2, middle2, close2;
   double upper3, lower3, middle3, close3;
   double k1, d1, k2, d2, k3, d3;

   if(!GetBollingerBands(Timeframe1, upper1, lower1, middle1) ||
      !GetBollingerBands(Timeframe2, upper2, lower2, middle2) ||
      !GetBollingerBands(Timeframe3, upper3, lower3, middle3))
     {
      Print("Error retrieving Bollinger Bands data.");
      return;
     }

   if(!GetStochastic(Timeframe1, k1, d1) ||
      !GetStochastic(Timeframe2, k2, d2) ||
      !GetStochastic(Timeframe3, k3, d3))
     {
      Print("Error retrieving Stochastic data.");
      return;
     }

// Retrieve the close prices
   close1 = iClose(Symbol(), Timeframe1, 0);
   close2 = iClose(Symbol(), Timeframe2, 0);
   close3 = iClose(Symbol(), Timeframe3, 0);

   bool buySignal = (close1 <= lower1 && close2 <= lower2 && close3 <= lower3) &&
                    (k1 < 25 && k2 < 25 && k3 < 25); // Oversold condition
   bool sellSignal = (close1 >= upper1 && close2 >= upper2 && close3 >= upper3) &&
                     (k1 > 80 && k2 > 80 && k3 > 80); // Overbought condition

// Check if an arrow already exists in the same region before placing a new one
   if(buySignal && !ArrowExists(close1))
     {
      Print("Buy signal detected on all timeframes with Stochastic confirmation!");

      string arrowName = "BuySignal" + IntegerToString(TimeCurrent());
      ObjectCreate(0, arrowName, OBJ_ARROW, 0, TimeCurrent(), close1);
      ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 241);
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrGreen);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);

      // Store signal data
      ArrayResize(signalTimes, ArraySize(signalTimes) + 1);
      ArrayResize(signalPrices, ArraySize(signalPrices) + 1);
      ArrayResize(signalBuySignals, ArraySize(signalBuySignals) + 1);

      signalTimes[ArraySize(signalTimes) - 1] = TimeCurrent();
      signalPrices[ArraySize(signalPrices) - 1] = close1;
      signalBuySignals[ArraySize(signalBuySignals) - 1] = true;
     }

   if(sellSignal && !ArrowExists(close1))
     {
      Print("Sell signal detected on all timeframes with Stochastic confirmation!");

      string arrowName = "SellSignal" + IntegerToString(TimeCurrent());
      ObjectCreate(0, arrowName, OBJ_ARROW, 0, TimeCurrent(), close1);
      ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 242);
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);

      // Store signal data
      ArrayResize(signalTimes, ArraySize(signalTimes) + 1);
      ArrayResize(signalPrices, ArraySize(signalPrices) + 1);
      ArrayResize(signalBuySignals, ArraySize(signalBuySignals) + 1);

      signalTimes[ArraySize(signalTimes) - 1] = TimeCurrent();
      signalPrices[ArraySize(signalPrices) - 1] = close1;
      signalBuySignals[ArraySize(signalBuySignals) - 1] = false;
     }
  }

//+------------------------------------------------------------------+
//| Check if an arrow already exists within the MinArrowDistance     |
//+------------------------------------------------------------------+
bool ArrowExists(double price)
  {
   for(int i = 0; i < ArraySize(signalPrices); i++)
     {
      if(MathAbs(signalPrices[i] - price) <= MinArrowDistance)
        {
         return true; // Arrow exists in the same price region
        }
     }
   return false; // No arrow exists in the same region
  }

//+------------------------------------------------------------------+
//| OnTick Event                                                     |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckAndGenerateSignal();
  }

//+------------------------------------------------------------------+
//| OnDeinit Function                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Clean up the objects
   long chart_id = 0;
   for(int i = ObjectsTotal(chart_id) - 1; i >= 0; i--)
     {
      string name = ObjectName(chart_id, i);
      if(StringFind(name, "Signal") != -1)
        {
         ObjectDelete(chart_id, name);
        }
     }

   Print("Multitimeframe Bollinger-Stochastic Analyzer deinitialized.");
  }
//+------------------------------------------------------------------+
