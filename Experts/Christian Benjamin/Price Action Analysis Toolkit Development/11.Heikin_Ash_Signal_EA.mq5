//+------------------------------------------------------------------+
//|                                        Heikin Ashi Signal EA.mq5 |
//|                                   Copyright 2026, MetaQuotes Ltd.|
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
//|               Price Action Analysis Toolkit Development          |
//|               Heikin Ashi Signal EA                              |
//|               https://www.mql5.com/en/articles/17021             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"
#property strict

//--- Input parameters
input int TrendCandles = 3;                 // Number of candles for trend detection
input double ShadowToBodyRatio = 1.5;       // Shadow-to-body ratio for reversal detection
input int ConsecutiveCandles = 2;           // Consecutive candles to confirm trend
input int RSI_Period = 14;                  // RSI Period
input double RSI_Buy_Threshold = 34.0;      // RSI level for buy confirmation
input double RSI_Sell_Threshold = 65.0;     // RSI level for sell confirmation
input color BuyArrowColor = clrGreen;       // Buy signal color
input color SellArrowColor = clrRed;        // Sell signal color

//--- Global variables
double haClose[], haOpen[], haHigh[], haLow[];
int rsiHandle;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(haClose, true);
   ArraySetAsSeries(haOpen, true);
   ArraySetAsSeries(haHigh, true);
   ArraySetAsSeries(haLow, true);

   if(Bars(_Symbol, _Period) < TrendCandles + 2)
     {
      Print("Not enough bars for initialization.");
      return INIT_FAILED;
     }

// Initialize RSI indicator
   rsiHandle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);
   if(rsiHandle == INVALID_HANDLE)
     {
      Print("Failed to create RSI indicator.");
      return INIT_FAILED;
     }

   Print("EA Initialized Successfully");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Bars(_Symbol, _Period) < TrendCandles + 2)
     {
      Print("Not enough bars for tick processing.");
      return;
     }

// Calculate Heikin-Ashi
   CalculateHeikinAshi();

// Get RSI Value
   double rsiValue;
   if(!GetRSIValue(rsiValue))
     {
      Print("Failed to retrieve RSI value.");
      return;
     }

// Detect potential reversals with RSI confirmation
   if(DetectReversal(true) && rsiValue < RSI_Buy_Threshold)  // Bullish reversal with RSI confirmation
     {
      DrawArrow("BuyArrow", iTime(NULL, 0, 0), SymbolInfoDouble(_Symbol, SYMBOL_BID), 233, BuyArrowColor);
      Print("Bullish Reversal Detected - RSI:", rsiValue);
     }
   else
      if(DetectReversal(false) && rsiValue > RSI_Sell_Threshold)  // Bearish reversal with RSI confirmation
        {
         DrawArrow("SellArrow", iTime(NULL, 0, 0), SymbolInfoDouble(_Symbol, SYMBOL_ASK), 234, SellArrowColor);
         Print("Bearish Reversal Detected - RSI:", rsiValue);
        }
  }

//+------------------------------------------------------------------+
//| Calculate Heikin-Ashi                                            |
//+------------------------------------------------------------------+
void CalculateHeikinAshi()
  {
   MqlRates rates[];
   int copied = CopyRates(_Symbol, _Period, 0, Bars(_Symbol, _Period), rates);

   if(copied < TrendCandles + 2)
     {
      Print("Failed to copy rates. Copied: ", copied);
      return;
     }

   ArraySetAsSeries(rates, true);

// Resize arrays to match the number of copied bars
   ArrayResize(haClose, copied);
   ArrayResize(haOpen, copied);
   ArrayResize(haHigh, copied);
   ArrayResize(haLow, copied);

// Calculate Heikin-Ashi
   for(int i = copied - 1; i >= 0; i--)
     {
      haClose[i] = (rates[i].open + rates[i].high + rates[i].low + rates[i].close) / 4.0;
      haOpen[i] = (i == copied - 1) ? (rates[i].open + rates[i].close) / 2.0 : (haOpen[i + 1] + haClose[i + 1]) / 2.0;
      haHigh[i] = MathMax(rates[i].high, MathMax(haOpen[i], haClose[i]));
      haLow[i] = MathMin(rates[i].low, MathMin(haOpen[i], haClose[i]));
     }

   Print("Heikin-Ashi Calculation Complete");
  }

//+------------------------------------------------------------------+
//| Detect Reversals with Trend Confirmation                         |
//+------------------------------------------------------------------+
bool DetectReversal(bool isBullish)
  {
   int direction = isBullish ? 1 : -1;

// Confirm trend location: Check for consecutive candles in the same direction
   int consecutive = 0;
   for(int i = 2; i <= TrendCandles + 1; i++)
     {
      if((haClose[i] > haClose[i + 1] && isBullish) || (haClose[i] < haClose[i + 1] && !isBullish))
         consecutive++;
      else
         break;
     }
   if(consecutive < ConsecutiveCandles)
      return false;

// Check for a strong reversal candlestick
   double body = MathAbs(haClose[1] - haOpen[1]);
   double shadow = (direction > 0) ? MathAbs(haLow[1] - haOpen[1]) : MathAbs(haHigh[1] - haOpen[1]);

// Avoid division by zero and confirm shadow-to-body ratio
   if(body == 0.0 || (shadow / body) < ShadowToBodyRatio)
      return false;

// Confirm the reversal with the next candlestick (opposite direction)
   return ((haClose[0] - haOpen[0]) * direction < 0);
  }

//+------------------------------------------------------------------+
//| Get RSI Value                                                    |
//+------------------------------------------------------------------+
bool GetRSIValue(double &rsiValue)
  {
   double rsiBuffer[];
   if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) > 0)
     {
      rsiValue = rsiBuffer[0];
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Draw Arrow                                                       |
//+------------------------------------------------------------------+
void DrawArrow(string name, datetime time, double price, int code, color clr)
  {
   name += "_" + IntegerToString(time);
   if(ObjectFind(0, name) != -1)
      ObjectDelete(0, name);

   if(ObjectCreate(0, name, OBJ_ARROW, 0, time, price))
     {
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      Print("Arrow Drawn: ", name, " at ", price);
     }
   else
     {
      Print("Failed to create arrow: ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
  }
//+------------------------------------------------------------------+
