//+------------------------------------------------------------------+
//|                                            Chart Projector.mq5   |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
//|               Price Action Analysis Toolkit Development          |
//|               1. Chart Projector                                 |
//|               https://www.mql5.com/en/articles/16014             |
//+------------------------------------------------------------------+
#property copyright   "Christian Benjamin"
#property link        "http://www.mql5.com"
#property description "Script to overlay yesterday's price action with ghost effect. Projected onto current day's chart and beyond"
#property indicator_chart_window
#property strict
#property script_show_inputs
                    
input color GhostColor = clrGray;        // Color for ghost effect (can be transparent)
input int LineStyle = STYLE_DOT;         // Line style for ghost candlesticks
input int LineWidth = 2;                 // Line width for ghost candlesticks
input bool ShowHighLow = true;           // Show high/low lines of yesterday
input int ShiftBars = 0;                 // Number of bars to shift ghost forward/backward
input int ProjectForwardBars = 100;      // Number of bars to project ghost pattern forward

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    DrawGhostCandles(); // Call the function to draw ghost candles
}

//+------------------------------------------------------------------+
//| Function to draw ghost candlesticks for yesterday                |
//+------------------------------------------------------------------+
void DrawGhostCandles()
{
    // Get the current timeframe (e.g., M1, M5)
    ENUM_TIMEFRAMES timeFrame = Period();
    
    // Get the start time of yesterday (daily timeframe)
    datetime yesterdayStart = iTime(_Symbol, PERIOD_D1, 1);
    datetime todayStart = iTime(_Symbol, PERIOD_D1, 0); // Start of today
    datetime todayEnd = todayStart + PeriodSeconds(PERIOD_D1); // Expected end of today (24 hours later)

    // Use iBarShift to get the index of yesterday's start bar on the current timeframe
    int startBarYesterday = iBarShift(_Symbol, timeFrame, yesterdayStart);
    int endBarYesterday = iBarShift(_Symbol, timeFrame, todayStart) - 1; // Last bar of yesterday

    if (startBarYesterday == -1 || endBarYesterday == -1)
    {
        Print("No data for yesterday.");
        return;
    }

    // Get the total number of bars for today
    int barsToday = Bars(_Symbol, timeFrame, todayStart, todayEnd);  // Bars from the start to the expected end of today

    // Loop through each bar of yesterday and project onto today, up to the expected close
    for (int i = 0; i < barsToday; i++)
    {
        // Calculate the corresponding bar from yesterday
        int yesterdayIndex = startBarYesterday - i % (endBarYesterday - startBarYesterday + 1);

        // Get the time, OHLC data for yesterday's bar
        datetime timeYesterday = iTime(_Symbol, timeFrame, yesterdayIndex);
        double openYesterday = iOpen(_Symbol, timeFrame, yesterdayIndex);
        double highYesterday = iHigh(_Symbol, timeFrame, yesterdayIndex);
        double lowYesterday = iLow(_Symbol, timeFrame, yesterdayIndex);
        double closeYesterday = iClose(_Symbol, timeFrame, yesterdayIndex);

        // Project this onto today's chart, applying the ShiftBars for forward/backward movement
        datetime projectedTime = todayStart + i * PeriodSeconds() + ShiftBars * PeriodSeconds();

        // Stop projection if we pass today's end time
        if (projectedTime >= todayEnd)
            break;

        // Draw the ghost candlestick for both current and projected bars
        DrawGhostBar(projectedTime, openYesterday, highYesterday, lowYesterday, closeYesterday);
    }

    // Optionally, draw horizontal lines for yesterday's high and low
    if (ShowHighLow)
    {
        // Get yesterday's high and low from the daily timeframe
        double yesterdayHigh = iHigh(_Symbol, PERIOD_D1, 1); // Yesterday's high
        double yesterdayLow = iLow(_Symbol, PERIOD_D1, 1);   // Yesterday's low

        DrawHorizontalLine("YesterdayHigh", yesterdayHigh);
        DrawHorizontalLine("YesterdayLow", yesterdayLow);
    }
}

//+------------------------------------------------------------------+
//| Function to draw ghost bars                                      |
//+------------------------------------------------------------------+
void DrawGhostBar(datetime time, double open, double high, double low, double close)
{
    // Create a line object for the high-low range (candlestick body)
    string lineName = "GhostLine" + IntegerToString(time);
    ObjectCreate(0, lineName, OBJ_TREND, 0, time, low, time, high);
    ObjectSetInteger(0, lineName, OBJPROP_COLOR, GhostColor);
    ObjectSetInteger(0, lineName, OBJPROP_STYLE, LineStyle);
    ObjectSetInteger(0, lineName, OBJPROP_WIDTH, LineWidth);

    // Create a rectangle for the open-close range (candlestick body)
    string ocName = "GhostOC" + IntegerToString(time);
    ObjectCreate(0, ocName, OBJ_RECTANGLE, 0, time, open, time + PeriodSeconds(), close);
    ObjectSetInteger(0, ocName, OBJPROP_COLOR, GhostColor);
    ObjectSetInteger(0, ocName, OBJPROP_STYLE, LineStyle);
    ObjectSetInteger(0, ocName, OBJPROP_WIDTH, LineWidth);
}

//+------------------------------------------------------------------+
//| Function to draw horizontal line for high/low                    |
//+------------------------------------------------------------------+
void DrawHorizontalLine(string name, double price)
{
    if (!ObjectCreate(0, name, OBJ_HLINE, 0, TimeCurrent(), price))
    {
        Print("Failed to create horizontal line.");
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, GhostColor);
    ObjectSetInteger(0, name, OBJPROP_STYLE, LineStyle);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, LineWidth);
}
