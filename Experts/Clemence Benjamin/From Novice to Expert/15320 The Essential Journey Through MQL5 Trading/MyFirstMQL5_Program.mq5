//+------------------------------------------------------------------+
//|                                          MyFirstMQL5 Program.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Input parameters for customizing the text display
input color TextColor = clrRed;               // Color of the text
input int FontSize = 20;                      // Font size
input ENUM_ANCHOR_POINT AnchorCorner = ANCHOR_LEFT_UPPER; // Text anchor point
input int X_Offset = 10;                      // X offset
input int Y_Offset = 10;                      // Y offset

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   // Get the opening price of the current day
   double openPrice = iOpen(_Symbol, PERIOD_D1, 0);
   
   // Get the closing price of the current day
   double closePrice = iClose(_Symbol, PERIOD_D1, 0);
   
   // Determine the candle status
   string candleStatus = (closePrice >= openPrice) ? "Bullish" : "Bearish";
   
   // Display the candle status on the screen
   DisplayCandleStatus(candleStatus);
  }

//+------------------------------------------------------------------+
//| Function to display the candle status on the screen              |
//+------------------------------------------------------------------+
void DisplayCandleStatus(string status)
  {
   string objName = "CandleStatusText";
   
   if(ObjectFind(0, objName) < 0)
     {
      // Create the text object if it doesn't exist
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, AnchorCorner);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, X_Offset);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, Y_Offset);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, FontSize);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, TextColor);
     }
   
   // Update the text
   ObjectSetString(0, objName, OBJPROP_TEXT, "Day Candle: " + status);
  }
//+------------------------------------------------------------------+
