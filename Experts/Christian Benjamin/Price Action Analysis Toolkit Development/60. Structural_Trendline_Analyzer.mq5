//+------------------------------------------------------------------+
//|                                 Structural Trendline Analyzer.mq5|
//+------------------------------------------------------------------+
//|                     Price Action Analysis Toolkit Development    |
//|          Objective Swing-Based Trendlines for Structural Analysis|
//|                           https://www.mql5.com/en/users/lynnchris|
//|                           https://www.mql5.com/en/articles/21226 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.0"
#property strict

#include <ChartObjects\ChartObjectsArrows.mqh>

//--- Input parameters
input string SwingGroup = "==== SWING DETECTION ====";     // Swing Detection
input int    SwingLookback = 5;                            // Bars to check for swing points
input double MinSwingSize = 0.0003;                        // Minimum swing size
input bool   UseATRFiltering = true;                       // Use ATR for dynamic sizing
input bool   ShowSwingPoints = true;                       // Show swing point markers
input bool   ShowSwingLabels = false;                      // Show swing labels (H1, L1, etc.)

input string TrendlineGroup = "==== TRENDLINE SELECTION ===="; // Trendline Settings
input bool   DrawResistanceLine = true;                    // Draw most significant resistance
input bool   DrawSupportLine = true;                       // Draw most significant support
input bool   ExtendToRightEdge = true;                     // Extend lines to chart edge
input int    MinTouchPointsRequired = 2;                   // Min touches for significance

input string VisualGroup = "==== VISUAL SETTINGS ====";    // Visual Settings
input color  ResistanceColor = clrRed;                     // Resistance line color
input color  SupportColor = clrDodgerBlue;                 // Support line color
input color  SwingHighColor = clrGoldenrod;                // Swing high marker color
input color  SwingLowColor = clrMediumSeaGreen;            // Swing low marker color
input int    LineWidth = 2;                                // Line width
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID;             // Line style
input ENUM_ARROW_ANCHOR AnchorPoint = ANCHOR_BOTTOM;       // Swing point anchor

//--- Globals
string OBJECT_PREFIX = "TL_";
int    atrHandle = INVALID_HANDLE;
double currentATR = 0.0001;

//+------------------------------------------------------------------+
//| Utilities                                                        |
//+------------------------------------------------------------------+
int PeriodSecondsSafe()
  {
   int sec = PeriodSeconds(_Period);
   if(sec <= 0)
      sec = 60;
   return sec;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjectsByPrefix(const string prefix)
  {
// Delete in reverse order (safe while deleting)
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringLen(name) >= StringLen(prefix) && StringSubstr(name, 0, StringLen(prefix)) == prefix)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Structure for swing points                                       |
//+------------------------------------------------------------------+
struct SwingPoint
  {
   datetime          time;
   double            price;
   int               barIndex;   // index in rates[] (series: 0 newest)
   double            size;
   bool              isHigh;
   int               order;      // 1 = oldest, higher = newer (after AssignSwingOrder)
  };

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Clean Trendline Tool Initialized");
   Print("Features: 1-2 trendlines + swing points");

   if(UseATRFiltering)
      atrHandle = iATR(_Symbol, _Period, 14);

   DeleteObjectsByPrefix(OBJECT_PREFIX);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjectsByPrefix(OBJECT_PREFIX);

   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);

   Print("Trendline Tool Cleaned Up");
  }

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(_Symbol, _Period, 0);

   if(currentBarTime == lastBarTime && lastBarTime != 0)
      return;

   lastBarTime = currentBarTime;

   if(UseATRFiltering && atrHandle != INVALID_HANDLE)
     {
      double atrBuffer[1];
      if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) > 0)
         currentATR = atrBuffer[0];
     }

   DeleteObjectsByPrefix(OBJECT_PREFIX);
   DrawMostSignificantTrendlines();
  }

//+------------------------------------------------------------------+
//| Core orchestration                                               |
//+------------------------------------------------------------------+
void DrawMostSignificantTrendlines()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);

   int bars = CopyRates(_Symbol, _Period, 0, 150, rates);
   if(bars < 50)
      return;

   SwingPoint significantHighs[10];
   SwingPoint significantLows[10];
   int highCount = 0, lowCount = 0;

   FindSignificantSwings(rates, bars, significantHighs, highCount, significantLows, lowCount);

   AssignSwingOrder(significantHighs, highCount);
   AssignSwingOrder(significantLows, lowCount);

   if(ShowSwingPoints)
      DrawSwingPoints(significantHighs, highCount, significantLows, lowCount);

// Resistance
   if(DrawResistanceLine && highCount >= 2)
     {
      SwingPoint a1, a2;
      int    touches = 0;
      double score   = 0.0;

      FindBestResistanceLine(significantHighs, highCount, rates, bars, a1, a2, touches, score);

      if(score > 50.0)
         DrawTrendline(a1, a2, true, touches, rates);
     }

// Support
   if(DrawSupportLine && lowCount >= 2)
     {
      SwingPoint a1, a2;
      int    touches = 0;
      double score   = 0.0;

      FindBestSupportLine(significantLows, lowCount, rates, bars, a1, a2, touches, score);

      if(score > 50.0)
         DrawTrendline(a1, a2, false, touches, rates);
     }
  }

//+------------------------------------------------------------------+
//| Find significant swing points                                    |
//+------------------------------------------------------------------+
void FindSignificantSwings(const MqlRates &rates[], int totalBars,
                           SwingPoint &highs[], int &highCount,
                           SwingPoint &lows[], int &lowCount)
  {
   highCount = 0;
   lowCount  = 0;

   double minSize = UseATRFiltering ? (currentATR * 0.8) : MinSwingSize;

   for(int i = SwingLookback; i < totalBars - SwingLookback; i++)
     {
      // Swing high
      bool isSwingHigh = true;
      double currentHigh = rates[i].high;

      for(int j = 1; j <= SwingLookback; j++)
        {
         if(rates[i-j].high >= currentHigh || rates[i+j].high >= currentHigh)
           {
            isSwingHigh = false;
            break;
           }
        }

      if(isSwingHigh)
        {
         double leftLow  = MathMin(rates[i-1].low, rates[i-2].low);
         double rightLow = MathMin(rates[i+1].low, rates[i+2].low);
         double swingSize = currentHigh - MathMax(leftLow, rightLow);

         if(swingSize >= minSize && highCount < 10)
           {
            highs[highCount].time     = rates[i].time;
            highs[highCount].price    = currentHigh;
            highs[highCount].barIndex = i;
            highs[highCount].size     = swingSize;
            highs[highCount].isHigh   = true;
            highs[highCount].order    = highCount + 1;
            highCount++;
           }
        }

      // Swing low
      bool isSwingLow = true;
      double currentLow = rates[i].low;

      for(int j = 1; j <= SwingLookback; j++)
        {
         if(rates[i-j].low <= currentLow || rates[i+j].low <= currentLow)
           {
            isSwingLow = false;
            break;
           }
        }

      if(isSwingLow)
        {
         double leftHigh  = MathMax(rates[i-1].high, rates[i-2].high);
         double rightHigh = MathMax(rates[i+1].high, rates[i+2].high);
         double swingSize = MathMin(leftHigh, rightHigh) - currentLow;

         if(swingSize >= minSize && lowCount < 10)
           {
            lows[lowCount].time     = rates[i].time;
            lows[lowCount].price    = currentLow;
            lows[lowCount].barIndex = i;
            lows[lowCount].size     = swingSize;
            lows[lowCount].isHigh   = false;
            lows[lowCount].order    = lowCount + 1;
            lowCount++;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Assign order to swings (1=oldest, higher=newer)                  |
//+------------------------------------------------------------------+
void AssignSwingOrder(SwingPoint &swings[], int count)
  {
   if(count <= 0)
      return;

// sort by time ascending (oldest -> newest)
   for(int i = 0; i < count-1; i++)
     {
      for(int j = i+1; j < count; j++)
        {
         if(swings[i].time > swings[j].time)
           {
            SwingPoint tmp = swings[i];
            swings[i] = swings[j];
            swings[j] = tmp;
           }
        }
     }

   for(int i = 0; i < count; i++)
      swings[i].order = i + 1;
  }

//+------------------------------------------------------------------+
//| Draw swing points on chart                                       |
//+------------------------------------------------------------------+
void DrawSwingPoints(const SwingPoint &highs[], int highCount,
                     const SwingPoint &lows[], int lowCount)
  {
// Highs
   for(int i = 0; i < highCount; i++)
     {
      string pointName = OBJECT_PREFIX + "H_" + IntegerToString(highs[i].order);

      if(ObjectFind(0, pointName) < 0)
         ObjectCreate(0, pointName, OBJ_ARROW_THUMB_DOWN, 0, highs[i].time, highs[i].price);
      else
         ObjectMove(0, pointName, 0, highs[i].time, highs[i].price);

      ObjectSetInteger(0, pointName, OBJPROP_COLOR,  SwingHighColor);
      ObjectSetInteger(0, pointName, OBJPROP_WIDTH,  2);
      ObjectSetInteger(0, pointName, OBJPROP_ANCHOR, AnchorPoint);
      ObjectSetInteger(0, pointName, OBJPROP_BACK,   false);

      if(ShowSwingLabels)
        {
         string labelName = pointName + "_LABEL";
         string labelText = "H" + IntegerToString(highs[i].order);

         double labelPrice = highs[i].price + (currentATR * 0.05);

         if(ObjectFind(0, labelName) < 0)
            ObjectCreate(0, labelName, OBJ_TEXT, 0, highs[i].time, labelPrice);
         else
            ObjectMove(0, labelName, 0, highs[i].time, labelPrice);

         ObjectSetString(0,  labelName, OBJPROP_TEXT,     labelText);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR,    SwingHighColor);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, labelName, OBJPROP_BACK,     false);
        }
     }

// Lows
   for(int i = 0; i < lowCount; i++)
     {
      string pointName = OBJECT_PREFIX + "L_" + IntegerToString(lows[i].order);

      if(ObjectFind(0, pointName) < 0)
         ObjectCreate(0, pointName, OBJ_ARROW_THUMB_UP, 0, lows[i].time, lows[i].price);
      else
         ObjectMove(0, pointName, 0, lows[i].time, lows[i].price);

      ObjectSetInteger(0, pointName, OBJPROP_COLOR,  SwingLowColor);
      ObjectSetInteger(0, pointName, OBJPROP_WIDTH,  2);
      ObjectSetInteger(0, pointName, OBJPROP_ANCHOR, AnchorPoint);
      ObjectSetInteger(0, pointName, OBJPROP_BACK,   false);

      if(ShowSwingLabels)
        {
         string labelName = pointName + "_LABEL";
         string labelText = "L" + IntegerToString(lows[i].order);

         double labelPrice = lows[i].price - (currentATR * 0.05);

         if(ObjectFind(0, labelName) < 0)
            ObjectCreate(0, labelName, OBJ_TEXT, 0, lows[i].time, labelPrice);
         else
            ObjectMove(0, labelName, 0, lows[i].time, labelPrice);

         ObjectSetString(0,  labelName, OBJPROP_TEXT,     labelText);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR,    SwingLowColor);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, labelName, OBJPROP_BACK,     false);
        }
     }
  }

//+------------------------------------------------------------------+
//| Find best resistance line (descending highs)                     |
//+------------------------------------------------------------------+
void FindBestResistanceLine(const SwingPoint &highs[], int highCount,
                            const MqlRates &rates[], int totalBars,
                            SwingPoint &bestAnchor1, SwingPoint &bestAnchor2,
                            int &bestTouchCount, double &bestScore)
  {
   bestScore = 0.0;
   bestTouchCount = 0;

   if(highCount < 2)
      return;

// copy & sort by time ascending (oldest->newest)
   SwingPoint pts[];
   ArrayResize(pts, highCount);
   for(int i=0;i<highCount;i++)
      pts[i]=highs[i];

   for(int i = 0; i < highCount-1; i++)
      for(int j = i+1; j < highCount; j++)
         if(pts[i].time > pts[j].time)
           { SwingPoint t=pts[i]; pts[i]=pts[j]; pts[j]=t; }

   for(int a = 0; a < highCount-1; a++)
     {
      for(int b = a+1; b < highCount; b++)
        {
         // RESISTANCE must be descending: older high > newer high
         if(!(pts[a].price > pts[b].price))
            continue;

         int idxOld = pts[a].barIndex; // older bar -> larger index in series
         int idxNew = pts[b].barIndex; // newer bar -> smaller index in series
         if(idxOld <= idxNew)
            continue;

         double timeDiff = (double)(pts[b].time - pts[a].time);
         if(timeDiff <= 0)
            continue;

         double priceDiff = pts[b].price - pts[a].price;
         // optional quality filter: ignore weak/flat line (price change too small)
         if(MathAbs(priceDiff) < (currentATR * 0.20))
            continue;

         double slope = priceDiff / timeDiff;

         int    touchCount = 2;
         double totalDeviation = 0.0;

         for(int k = idxNew + 1; k < idxOld; k++)
           {
            double candleRange = rates[k].high - rates[k].low;
            if(candleRange <= _Point)
               continue;

            double linePrice = pts[a].price + (slope * (rates[k].time - pts[a].time));

            double deviation = (rates[k].high - linePrice) / candleRange;

            if(deviation < 0.2 && deviation > -0.3)
              {
               touchCount++;
               totalDeviation += MathAbs(deviation);
              }
           }

         double score = touchCount * 25.0;

         if(touchCount > 2)
           {
            double avgDev = totalDeviation / (touchCount - 2);
            score -= (avgDev * 20.0);
           }

         // Bonus for recency (prefer lines anchored closer to current time)
         // idxNew small => more recent => larger bonus
         double recencyBonus = (1.0 - (double)idxNew / (double)totalBars) * 30.0;
         score += recencyBonus;

         if(score > bestScore && touchCount >= MinTouchPointsRequired)
           {
            bestScore = score;
            bestTouchCount = touchCount;
            bestAnchor1 = pts[a]; // older
            bestAnchor2 = pts[b]; // newer
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Find best support line (ascending lows)                          |
//+------------------------------------------------------------------+
void FindBestSupportLine(const SwingPoint &lows[], int lowCount,
                         const MqlRates &rates[], int totalBars,
                         SwingPoint &bestAnchor1, SwingPoint &bestAnchor2,
                         int &bestTouchCount, double &bestScore)
  {
   bestScore = 0.0;
   bestTouchCount = 0;

   if(lowCount < 2)
      return;

// copy & sort by time ascending (oldest->newest)
   SwingPoint pts[];
   ArrayResize(pts, lowCount);
   for(int i=0;i<lowCount;i++)
      pts[i]=lows[i];

   for(int i = 0; i < lowCount-1; i++)
      for(int j = i+1; j < lowCount; j++)
         if(pts[i].time > pts[j].time)
           { SwingPoint t=pts[i]; pts[i]=pts[j]; pts[j]=t; }

   for(int a = 0; a < lowCount-1; a++)
     {
      for(int b = a+1; b < lowCount; b++)
        {
         // SUPPORT must be ascending: older low < newer low
         if(!(pts[a].price < pts[b].price))
            continue;

         int idxOld = pts[a].barIndex; // older -> larger index
         int idxNew = pts[b].barIndex; // newer -> smaller index
         if(idxOld <= idxNew)
            continue;

         double timeDiff = (double)(pts[b].time - pts[a].time);
         if(timeDiff <= 0)
            continue;

         double priceDiff = pts[b].price - pts[a].price;
         // optional quality filter: ignore weak/flat line (price change too small)
         if(MathAbs(priceDiff) < (currentATR * 0.20))
            continue;

         double slope = priceDiff / timeDiff;

         int    touchCount = 2;
         double totalDeviation = 0.0;

         for(int k = idxNew + 1; k < idxOld; k++)
           {
            double candleRange = rates[k].high - rates[k].low;
            if(candleRange <= _Point)
               continue;

            double linePrice = pts[a].price + (slope * (rates[k].time - pts[a].time));

            double deviation = (linePrice - rates[k].low) / candleRange;

            if(deviation < 0.2 && deviation > -0.3)
              {
               touchCount++;
               totalDeviation += MathAbs(deviation);
              }
           }

         double score = touchCount * 25.0;

         if(touchCount > 2)
           {
            double avgDev = totalDeviation / (touchCount - 2);
            score -= (avgDev * 20.0);
           }

         double recencyBonus = (1.0 - (double)idxNew / (double)totalBars) * 30.0;
         score += recencyBonus;

         if(score > bestScore && touchCount >= MinTouchPointsRequired)
           {
            bestScore = score;
            bestTouchCount = touchCount;
            bestAnchor1 = pts[a]; // older
            bestAnchor2 = pts[b]; // newer
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw a single clean trendline                                    |
//+------------------------------------------------------------------+
void DrawTrendline(const SwingPoint &anchor1, const SwingPoint &anchor2,
                   bool isResistance, int touchCount,
                   const MqlRates &rates[])
  {
   string lineName  = OBJECT_PREFIX + (isResistance ? "RESISTANCE" : "SUPPORT");
   string labelName = OBJECT_PREFIX + (isResistance ? "RES_LABEL"   : "SUP_LABEL");

   datetime time1 = anchor1.time;
   double   price1 = anchor1.price;
   datetime time2 = anchor2.time;
   double   price2 = anchor2.price;

   if(time2 <= time1)
      return;

// For clean & deterministic visuals, anchor the second point at the latest bar time.
// Ray-right handles extension. This prevents backtest drift.
   datetime endTime  = rates[0].time;
   double   endPrice = price2;

   if(ObjectFind(0, lineName) < 0)
      ObjectCreate(0, lineName, OBJ_TREND, 0, time1, price1, time2, price2);
   else
     {
      ObjectMove(0, lineName, 0, time1, price1);
      ObjectMove(0, lineName, 1, time2, price2);
     }

   color lineColor = isResistance ? ResistanceColor : SupportColor;

   ObjectSetInteger(0, lineName, OBJPROP_COLOR,  lineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH,  LineWidth);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE,  LineStyle);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, ExtendToRightEdge);
   ObjectSetInteger(0, lineName, OBJPROP_BACK,   false);

// Label text
   string labelText = (isResistance ? "R" : "S") + " (" + IntegerToString(touchCount) + ")";

   datetime labelTime = anchor2.time;
   double labelPrice  = anchor2.price;

   double pad = currentATR * 0.10;
   if(isResistance)
      labelPrice -= pad;
   else
      labelPrice += pad;

   if(ObjectFind(0, labelName) < 0)
      ObjectCreate(0, labelName, OBJ_TEXT, 0, labelTime, labelPrice);
   else
      ObjectMove(0, labelName, 0, labelTime, labelPrice);

   ObjectSetString(0,  labelName, OBJPROP_TEXT,     labelText);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR,    lineColor);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, labelName, OBJPROP_BACK,     false);
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
// Optional: Add manual refresh / hotkey logic if needed
  }
//+------------------------------------------------------------------+
