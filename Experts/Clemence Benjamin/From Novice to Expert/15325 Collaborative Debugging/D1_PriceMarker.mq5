//+------------------------------------------------------------------+
//|                                               D1 PriceMarker.mq5 |
//|                                Copyright 2024, Clemence Benjamin |
//|             https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.00"
#property strict


// Function to create a price line with a label
void CreatePriceLine(string name, double price, color clr, string label)
{
    // Create a horizontal line
    if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
    {
        Print("Failed to create line: ", GetLastError());
        return;
    }
    
    // Set line properties
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);

    // Create a label for the price
    string labelName = name + "_label";
    if(!ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0))
    {
        Print("Failed to create label: ", GetLastError());
        return;
    }

    // Set label properties
    ObjectSetInteger(0, labelName, OBJPROP_XSIZE, 70);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, price); // Position label at the price level
    ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 5);
    
    // Set the text of the label
    ObjectSetString(0, labelName, OBJPROP_TEXT, label + ": " + DoubleToString(price, 2));
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
void OnInit()
{
    // Get the previous D1 candle's open, high, low, and close prices
    datetime prevCandleTime = iTime(NULL, PERIOD_D1, 1);
    double openPrice = iOpen(NULL, PERIOD_D1, 1);
    double highPrice = iHigh(NULL, PERIOD_D1, 1);
    double lowPrice = iLow(NULL, PERIOD_D1, 1);
    double closePrice = iClose(NULL, PERIOD_D1, 1);

    // Draw labeled price lines for open, high, low, and close prices
    CreatePriceLine("PrevCandle_Open", openPrice, clrBlue, "Open");
    CreatePriceLine("PrevCandle_High", highPrice, clrRed, "High");
    CreatePriceLine("PrevCandle_Low", lowPrice, clrGreen, "Low");
    CreatePriceLine("PrevCandle_Close", closePrice, clrOrange, "Close");
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Remove the drawn price lines and labels upon indicator deinitialization
    ObjectDelete(0, "PrevCandle_Open");
    ObjectDelete(0, "PrevCandle_High");
    ObjectDelete(0, "PrevCandle_Low");
    ObjectDelete(0, "PrevCandle_Close");
    ObjectDelete(0, "PrevCandle_Open_label");
    ObjectDelete(0, "PrevCandle_High_label");
    ObjectDelete(0, "PrevCandle_Low_label");
    ObjectDelete(0, "PrevCandle_Close_label");
}

//+------------------------------------------------------------------+