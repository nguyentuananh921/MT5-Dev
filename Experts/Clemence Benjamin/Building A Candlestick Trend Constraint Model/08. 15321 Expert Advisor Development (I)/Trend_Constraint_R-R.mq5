//+------------------------------------------------------------------+
//|                                        Trend Constraint R-R.mq5  |
//|                                                  Script program  |
//+------------------------------------------------------------------+
#property strict
#property script_show_inputs
#property copyright "2024 Clemence Benjamin"
#property version "1.00"
#property link "https://www.mql5.com/en/users/billionaire2024/seller"
#property description "A script program for drawing risk and rewars rectangles based on Moving Averaage crossover."



//--- input parameters
input int FastMAPeriod = 14;
input int SlowMAPeriod = 50;
input double RiskHeightPoints = 5000.0; // Default height of the risk rectangle in points
input double RewardHeightPoints = 15000.0; // Default height of the reward rectangle in points
input color RiskColor = clrIndianRed; // Default risk color
input color RewardColor = clrSpringGreen; // Default reward color
input int MaxBars = 500; // Maximum bars to process
input int RectangleWidth = 10; // Width of the rectangle in bars
input bool FillRectangles = true; // Option to fill rectangles
input int FillTransparency = 128; // Transparency level (0-255), 128 is 50% transparency

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
  //--- delete existing rectangles and lines
  DeleteExistingObjects();

  //--- declare and initialize variables
  int i, limit;
  double FastMA[], SlowMA[];
  double closePrice, riskLevel, rewardLevel;

  //--- calculate moving averages
  if (iMA(NULL, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE) < 0 || iMA(NULL, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE) < 0)
  {
    Print("Error in calculating moving averages.");
    return;
  }

  ArraySetAsSeries(FastMA, true);
  ArraySetAsSeries(SlowMA, true);

  CopyBuffer(iMA(NULL, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE), 0, 0, MaxBars, FastMA);
  CopyBuffer(iMA(NULL, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE), 0, 0, MaxBars, SlowMA);

  limit = MathMin(ArraySize(FastMA), ArraySize(SlowMA));

  for (i = 1; i < limit - 1; i++)
  {
    //--- check for crossover
    if (FastMA[i] > SlowMA[i] && FastMA[i - 1] <= SlowMA[i - 1])
    {
      //--- long position entry point (bullish crossover)
      closePrice = iClose(NULL, 0, i);
      riskLevel = closePrice + RiskHeightPoints * Point();
      rewardLevel = closePrice - RewardHeightPoints * Point();

      //--- draw risk rectangle
      DrawRectangle("Risk_" + IntegerToString(i), i, closePrice, i - RectangleWidth, riskLevel, RiskColor);

      //--- draw reward rectangle
      DrawRectangle("Reward_" + IntegerToString(i), i, closePrice, i - RectangleWidth, rewardLevel, RewardColor);

      //--- draw entry, stop loss, and take profit lines
      DrawPriceLine("Entry_" + IntegerToString(i), i, closePrice, clrBlue, "Entry: " + DoubleToString(closePrice, _Digits));
      DrawPriceLine("StopLoss_" + IntegerToString(i), i, riskLevel, clrRed, "Stop Loss: " + DoubleToString(riskLevel, _Digits));
      DrawPriceLine("TakeProfit_" + IntegerToString(i), i, rewardLevel, clrGreen, "Take Profit: " + DoubleToString(rewardLevel, _Digits));
    }
    else if (FastMA[i] < SlowMA[i] && FastMA[i - 1] >= SlowMA[i - 1])
    {
      //--- short position entry point (bearish crossover)
      closePrice = iClose(NULL, 0, i);
      riskLevel = closePrice - RiskHeightPoints * Point();
      rewardLevel = closePrice + RewardHeightPoints * Point();

      //--- draw risk rectangle
      DrawRectangle("Risk_" + IntegerToString(i), i, closePrice, i - RectangleWidth, riskLevel, RiskColor);

      //--- draw reward rectangle
      DrawRectangle("Reward_" + IntegerToString(i), i, closePrice, i - RectangleWidth, rewardLevel, RewardColor);

      //--- draw entry, stop loss, and take profit lines
      DrawPriceLine("Entry_" + IntegerToString(i), i, closePrice, clrBlue, "Entry: " + DoubleToString(closePrice, _Digits));
      DrawPriceLine("StopLoss_" + IntegerToString(i), i, riskLevel, clrRed, "Stop Loss: " + DoubleToString(riskLevel, _Digits));
      DrawPriceLine("TakeProfit_" + IntegerToString(i), i, rewardLevel, clrGreen, "Take Profit: " + DoubleToString(rewardLevel, _Digits));
    }
  }
}

//+------------------------------------------------------------------+
//| Function to delete existing rectangles and lines                 |
//+------------------------------------------------------------------+
void DeleteExistingObjects()
{
  int totalObjects = ObjectsTotal(0, 0, -1);
  for (int i = totalObjects - 1; i >= 0; i--)
  {
    string name = ObjectName(0, i, 0, -1);
    if (StringFind(name, "Risk_") >= 0 || StringFind(name, "Reward_") >= 0 ||
        StringFind(name, "Entry_") >= 0 || StringFind(name, "StopLoss_") >= 0 ||
        StringFind(name, "TakeProfit_") >= 0)
    {
      ObjectDelete(0, name);
    }
  }
}

//+------------------------------------------------------------------+
//| Function to draw rectangles                                      |
//+------------------------------------------------------------------+
void DrawRectangle(string name, int startBar, double startPrice, int endBar, double endPrice, color rectColor)
{
  if (ObjectFind(0, name) >= 0)
    ObjectDelete(0, name);

  datetime startTime = iTime(NULL, 0, startBar);
  datetime endTime = (endBar < 0) ? (TimeCurrent() + (PeriodSeconds() * (-endBar))) : iTime(NULL, 0, endBar);

  if (!ObjectCreate(0, name, OBJ_RECTANGLE, 0, startTime, startPrice, endTime, endPrice))
    Print("Failed to create rectangle: ", name);

  // Set the color with transparency (alpha value)
  int alphaValue = FillTransparency; // Adjust transparency level (0-255)
  color fillColor = rectColor & 0x00FFFFFF | (alphaValue << 24); // Combine alpha with RGB

  ObjectSetInteger(0, name, OBJPROP_COLOR, rectColor);
  ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
  ObjectSetInteger(0, name, OBJPROP_BACK, true); // Set to background

  if (FillRectangles)
  {
    ObjectSetInteger(0, name, OBJPROP_COLOR, fillColor); // Fill color with transparency
  }
  else
  {
    ObjectSetInteger(0, name, OBJPROP_COLOR, rectColor & 0x00FFFFFF); // No fill color
  }
}

//+------------------------------------------------------------------+
//| Function to draw price lines                                     |
//+------------------------------------------------------------------+
void DrawPriceLine(string name, int barIndex, double price, color lineColor, string labelText)
{
  datetime time = iTime(NULL, 0, barIndex);
  datetime endTime = (barIndex - 2 * RectangleWidth < 0) ? (TimeCurrent() + (PeriodSeconds() * (-barIndex - 2 * RectangleWidth))) : iTime(NULL, 0, barIndex - 2 * RectangleWidth); // Extend line to the right

  if (!ObjectCreate(0, name, OBJ_TREND, 0, time, price, endTime, price))
    Print("Failed to create price line: ", name);

  ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
  ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
  ObjectSetInteger(0, name, OBJPROP_BACK, true); // Set to background

  // Create text label
  string labelName = name + "_Label";
  if (ObjectFind(0, labelName) >= 0)
    ObjectDelete(0, labelName);

  if (!ObjectCreate(0, labelName, OBJ_TEXT, 0, endTime, price))
    Print("Failed to create label: ", labelName);

  ObjectSetInteger(0, labelName, OBJPROP_COLOR, lineColor);
  ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT);
  ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
  ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
  ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
  ObjectSetInteger(0, labelName, OBJPROP_XOFFSET, 5);
  ObjectSetInteger(0, labelName, OBJPROP_YOFFSET, 0);
}
