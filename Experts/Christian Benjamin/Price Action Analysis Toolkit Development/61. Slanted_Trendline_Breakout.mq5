//+------------------------------------------------------------------+
//|                                    Slanted Trendline Breakout.mq5|
//|                                   Copyright 2026, MetaQuotes Ltd.|
//|                           https://www.mql5.com/en/users/lynnchris|
//+------------------------------------------------------------------+
//|               Price Action Analysis Toolkit Development          |
//|Structural Slanted Trendline Breakouts with 3-Swing Validation      |
//|               https://www.mql5.com/en/articles/21277             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.0"
#property strict

//--- Input parameters
input string SwingGroup = "==== SWING DETECTION ====";     
input int    SwingLookback = 5;                            
input double MinSwingSize = 0.0003;                        
input bool   UseATRFiltering = true;                       
input bool   ShowSwingPoints = true;                       
input bool   ShowSwingLabels = false;                      

input string TrendlineGroup = "==== TRENDLINE SELECTION ===="; 
input bool   DrawResistanceLine = true;                    
input bool   DrawSupportLine = true;                       
input bool   ExtendToRightEdge = true;                     
input int    MinTouchPointsRequired = 3;                   

input string ConfirmGroup = "==== 3-SWING VALIDATION ====";
input double ThirdSwingToleranceATR = 0.15;                
input bool   RequireThirdSwingAfterAnchor2 = true;         

input string BreakoutGroup = "==== BREAKOUT SIGNALS ====";
input bool   EnableBreakoutSignals = true;                 
input bool   BreakoutUseClose = true;                     
input int    BreakoutBufferPoints = 5;                     
input bool   AlertOnBreakout = false;                     
input bool   PermanentArrows = true;                       
input int    ArrowSize = 2;                               
input color  BullArrowColor = clrLimeGreen;                
input color  BearArrowColor = clrRed;                      

input string VisualGroup = "==== VISUAL SETTINGS ====";    
input color  ResistanceColor = clrRed;                     
input color  SupportColor = clrDodgerBlue;                 
input color  SwingHighColor = clrGoldenrod;                
input color  SwingLowColor = clrMediumSeaGreen;            
input int    LineWidth = 2;                                
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID;             
input ENUM_ARROW_ANCHOR AnchorPoint = ANCHOR_BOTTOM;       

//--- Prefixes
string TL_PREFIX  = "TL3_";   
string SIG_PREFIX = "SIG_";   

//--- Globals
int    atrHandle = INVALID_HANDLE;
double currentATR = 0.0001;

//--- Breakout de-duplication (one arrow per closed bar per side)
datetime g_lastBuyBarTime  = 0;
datetime g_lastSellBarTime = 0;

//--- Structure to track breakouts for permanent arrows
struct BreakoutInfo
  {
   datetime          time;
   double            price;
   bool              isBullish;
   string            lineType;  // "RES" or "SUP"
   int               touchCount;
  };
BreakoutInfo breakoutsArray[];
int breakoutsCount = 0;

//+------------------------------------------------------------------+
//| Utilities                                                        |
//+------------------------------------------------------------------+
void DeleteObjectsByPrefix(const string prefix)
  {
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringLen(name) >= StringLen(prefix) && StringSubstr(name, 0, StringLen(prefix)) == prefix)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BreakoutBufferPrice()
  {
   return (double)BreakoutBufferPoints * _Point;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ThirdSwingTolerancePrice()
  {
   double tol = currentATR * ThirdSwingToleranceATR;
   if(tol < 3.0 * _Point)
      tol = 3.0 * _Point;
   return tol;
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
//| Initialize SwingPoint                                            |
//+------------------------------------------------------------------+
void InitSwingPoint(SwingPoint &sp, bool isHigh = true)
  {
   sp.time = 0;
   sp.price = 0.0;
   sp.barIndex = 0;
   sp.size = 0.0;
   sp.isHigh = isHigh;
   sp.order = 0;
  }

//+------------------------------------------------------------------+
//| Line math                                                        |
//+------------------------------------------------------------------+
double LinePriceAtTime(const SwingPoint &a, const SwingPoint &b, datetime t)
  {
   double dt = (double)(b.time - a.time);
   if(dt == 0.0)
      return a.price;
   double slope = (b.price - a.price) / dt;
   return a.price + slope * (double)(t - a.time);
  }

//+------------------------------------------------------------------+
//| 3rd swing confirmation check                                     |
//| For resistance: swing high should lie near line at its time       |
//| For support:   swing low should lie near line at its time         |
//+------------------------------------------------------------------+
bool ThirdSwingConfirms(const SwingPoint &a, const SwingPoint &b, const SwingPoint &c)
  {
   double lp = LinePriceAtTime(a, b, c.time);
   return (MathAbs(c.price - lp) <= ThirdSwingTolerancePrice());
  }

//+------------------------------------------------------------------+
//| Draw Permanent Arrow                                              |
//+------------------------------------------------------------------+
void DrawPermanentArrow(datetime time, double price, bool isBullish, string lineType, int touchCount)
  {
   string arrowName = SIG_PREFIX + lineType + "_" +
                      (isBullish ? "BUY_" : "SELL_") +
                      IntegerToString((int)time) + "_" +
                      IntegerToString(touchCount);

// Check if arrow already exists
   if(ObjectFind(0, arrowName) >= 0)
      return;

// Create arrow object
   if(!ObjectCreate(0, arrowName, OBJ_ARROW, 0, time, price))
     {
      Print("Failed to create arrow: ", GetLastError());
      return;
     }

// Set arrow properties
   ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, isBullish ? 233 : 234); // Up/Down arrows
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, isBullish ? BullArrowColor : BearArrowColor);
   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, ArrowSize);
   ObjectSetInteger(0, arrowName, OBJPROP_BACK, false);
   ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, arrowName, OBJPROP_HIDDEN, true);

// Add description
   string desc = lineType + " Breakout " +
                 (isBullish ? "BULLISH" : "BEARISH") +
                 " (" + IntegerToString(touchCount) + " touches)";
   ObjectSetString(0, arrowName, OBJPROP_TEXT, desc);

// Store breakout info
   if(breakoutsCount >= ArraySize(breakoutsArray))
      ArrayResize(breakoutsArray, breakoutsCount + 10);

   breakoutsArray[breakoutsCount].time = time;
   breakoutsArray[breakoutsCount].price = price;
   breakoutsArray[breakoutsCount].isBullish = isBullish;
   breakoutsArray[breakoutsCount].lineType = lineType;
   breakoutsArray[breakoutsCount].touchCount = touchCount;
   breakoutsCount++;
  }

//+------------------------------------------------------------------+
//| Redraw All Permanent Arrows                                       |
//+------------------------------------------------------------------+
void RedrawPermanentArrows()
  {
// Only draw permanent arrows if enabled
   if(!PermanentArrows)
      return;

   for(int i = 0; i < breakoutsCount; i++)
     {
      string arrowName = SIG_PREFIX + breakoutsArray[i].lineType + "_" +
                         (breakoutsArray[i].isBullish ? "BUY_" : "SELL_") +
                         IntegerToString((int)breakoutsArray[i].time) + "_" +
                         IntegerToString(breakoutsArray[i].touchCount);

      // Create or update arrow
      if(ObjectFind(0, arrowName) < 0)
        {
         if(ObjectCreate(0, arrowName, OBJ_ARROW, 0, breakoutsArray[i].time, breakoutsArray[i].price))
           {
            ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, breakoutsArray[i].isBullish ? 233 : 234);
            ObjectSetInteger(0, arrowName, OBJPROP_COLOR, breakoutsArray[i].isBullish ? BullArrowColor : BearArrowColor);
            ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, ArrowSize);
            ObjectSetInteger(0, arrowName, OBJPROP_BACK, false);
            ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, arrowName, OBJPROP_HIDDEN, true);

            string desc = breakoutsArray[i].lineType + " Breakout " +
                          (breakoutsArray[i].isBullish ? "BULLISH" : "BEARISH") +
                          " (" + IntegerToString(breakoutsArray[i].touchCount) + " touches)";
            ObjectSetString(0, arrowName, OBJPROP_TEXT, desc);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(UseATRFiltering)
      atrHandle = iATR(_Symbol, _Period, 14);

// Clean only dynamic objects (keep SIG_ arrows)
   DeleteObjectsByPrefix(TL_PREFIX);

// Initialize breakouts array
   ArrayResize(breakoutsArray, 100);
   breakoutsCount = 0;

   Print("FULL Trendline Analyzer initialized (3-swing validated + PERMANENT breakout arrows).");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Delete only dynamic objects, keep permanent arrows
   DeleteObjectsByPrefix(TL_PREFIX);

   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);

   Print("Deinit: dynamic objects removed, PERMANENT arrows preserved.");
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

// Redraw dynamic objects each new bar; keep SIG_ arrows
   DeleteObjectsByPrefix(TL_PREFIX);
   DrawMostSignificantTrendlines();

// Redraw all permanent arrows
   RedrawPermanentArrows();
  }

//+------------------------------------------------------------------+
//| Core orchestration                                               |
//+------------------------------------------------------------------+
void DrawMostSignificantTrendlines()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);

   int bars = CopyRates(_Symbol, _Period, 0, 200, rates);
   if(bars < 70)
      return;

   SwingPoint significantHighs[10];
   SwingPoint significantLows[10];
   int highCount = 0, lowCount = 0;

   FindSignificantSwings(rates, bars, significantHighs, highCount, significantLows, lowCount);

   AssignSwingOrder(significantHighs, highCount);
   AssignSwingOrder(significantLows, lowCount);

   if(ShowSwingPoints)
      DrawSwingPoints(significantHighs, highCount, significantLows, lowCount);

// Initialize anchors safely
   SwingPoint r1, r2, r3, s1, s2, s3;
   InitSwingPoint(r1, true);
   InitSwingPoint(r2, true);
   InitSwingPoint(r3, true);
   InitSwingPoint(s1, false);
   InitSwingPoint(s2, false);
   InitSwingPoint(s3, false);

// Resistance (3-swing validated)
   bool haveRes = false;
   int    resTouches = 0;
   double resScore   = 0.0;

   if(DrawResistanceLine && highCount >= 3)
     {
      FindBestResistanceLine3(significantHighs, highCount, rates, bars, r1, r2, r3, resTouches, resScore);
      if(resScore > 50.0)
        {
         haveRes = true;
         DrawTrendline3(r1, r2, r3, true, resTouches);
        }
     }

// Support (3-swing validated)
   bool haveSup = false;
   int    supTouches = 0;
   double supScore   = 0.0;

   if(DrawSupportLine && lowCount >= 3)
     {
      FindBestSupportLine3(significantLows, lowCount, rates, bars, s1, s2, s3, supTouches, supScore);
      if(supScore > 50.0)
        {
         haveSup = true;
         DrawTrendline3(s1, s2, s3, false, supTouches);
        }
     }

// Breakouts (CROSS logic for slanted lines)
   if(EnableBreakoutSignals)
      CheckBreakouts(rates, haveRes, r1, r2, resTouches, haveSup, s1, s2, supTouches);
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
      string pointName = TL_PREFIX + "H_" + IntegerToString(highs[i].order);

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
      string pointName = TL_PREFIX + "L_" + IntegerToString(lows[i].order);

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
//| Find best resistance line (descending highs) + 3rd swing confirm  |
//+------------------------------------------------------------------+
void FindBestResistanceLine3(const SwingPoint &highs[], int highCount,
                             const MqlRates &rates[], int totalBars,
                             SwingPoint &bestAnchor1, SwingPoint &bestAnchor2, SwingPoint &bestAnchor3,
                             int &bestTouchCount, double &bestScore)
  {
   bestScore = 0.0;
   bestTouchCount = 0;

// Initialize best anchors
   InitSwingPoint(bestAnchor1, true);
   InitSwingPoint(bestAnchor2, true);
   InitSwingPoint(bestAnchor3, true);

   if(highCount < 3)
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
         // Resistance must be descending: older high > newer high
         if(!(pts[a].price > pts[b].price))
            continue;

         int idxOld = pts[a].barIndex;
         int idxNew = pts[b].barIndex;
         if(idxOld <= idxNew) // older has larger index in series
            continue;

         double timeDiff = (double)(pts[b].time - pts[a].time);
         if(timeDiff <= 0)
            continue;

         double priceDiff = pts[b].price - pts[a].price;
         if(MathAbs(priceDiff) < (currentATR * 0.20))
            continue;

         double slope = priceDiff / timeDiff;

         // Count touches between anchors (original logic)
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

         // --- 3rd swing confirmation (must be a swing high near the line)
         bool haveThird = false;
         SwingPoint third;
         // Initialize third variable
         InitSwingPoint(third, true);

         for(int c = 0; c < highCount; c++)
           {
            if(c == a || c == b)
               continue;

            // Require third swing newer than anchor2 (recommended)
            if(RequireThirdSwingAfterAnchor2 && !(pts[c].time > pts[b].time))
               continue;

            // keep descending structure if possible (optional but sensible)
            // third should not violate "highs stepping down"
            if(!(pts[b].price > pts[c].price))
               continue;

            if(ThirdSwingConfirms(pts[a], pts[b], pts[c]))
              {
               haveThird = true;
               third = pts[c];
               break;
              }
           }

         if(!haveThird)
            continue;

         double score = touchCount * 25.0;

         if(touchCount > 2)
           {
            double avgDev = totalDeviation / (touchCount - 2);
            score -= (avgDev * 20.0);
           }

         // Bonus for recency (prefer lines anchored closer to current time)
         double recencyBonus = (1.0 - (double)idxNew / (double)totalBars) * 30.0;
         score += recencyBonus;

         // Small bonus for having a confirmed 3rd swing (stability)
         score += 15.0;

         if(score > bestScore && touchCount >= MinTouchPointsRequired)
           {
            bestScore = score;
            bestTouchCount = touchCount;
            bestAnchor1 = pts[a];
            bestAnchor2 = pts[b];
            bestAnchor3 = third;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Find best support line (ascending lows) + 3rd swing confirm       |
//+------------------------------------------------------------------+
void FindBestSupportLine3(const SwingPoint &lows[], int lowCount,
                          const MqlRates &rates[], int totalBars,
                          SwingPoint &bestAnchor1, SwingPoint &bestAnchor2, SwingPoint &bestAnchor3,
                          int &bestTouchCount, double &bestScore)
  {
   bestScore = 0.0;
   bestTouchCount = 0;

// Initialize best anchors
   InitSwingPoint(bestAnchor1, false);
   InitSwingPoint(bestAnchor2, false);
   InitSwingPoint(bestAnchor3, false);

   if(lowCount < 3)
      return;

// copy & sort by time ascending
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
         // Support must be ascending: older low < newer low
         if(!(pts[a].price < pts[b].price))
            continue;

         int idxOld = pts[a].barIndex;
         int idxNew = pts[b].barIndex;
         if(idxOld <= idxNew)
            continue;

         double timeDiff = (double)(pts[b].time - pts[a].time);
         if(timeDiff <= 0)
            continue;

         double priceDiff = pts[b].price - pts[a].price;
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

         // 3rd swing confirmation (must be a swing low near the line)
         bool haveThird = false;
         SwingPoint third;
         // Initialize third variable
         InitSwingPoint(third, false);

         for(int c = 0; c < lowCount; c++)
           {
            if(c == a || c == b)
               continue;

            if(RequireThirdSwingAfterAnchor2 && !(pts[c].time > pts[b].time))
               continue;

            // maintain stepping up lows if possible
            if(!(pts[b].price < pts[c].price))
               continue;

            if(ThirdSwingConfirms(pts[a], pts[b], pts[c]))
              {
               haveThird = true;
               third = pts[c];
               break;
              }
           }

         if(!haveThird)
            continue;

         double score = touchCount * 25.0;

         if(touchCount > 2)
           {
            double avgDev = totalDeviation / (touchCount - 2);
            score -= (avgDev * 20.0);
           }

         double recencyBonus = (1.0 - (double)idxNew / (double)totalBars) * 30.0;
         score += recencyBonus;

         score += 15.0; // 3rd swing stability

         if(score > bestScore && touchCount >= MinTouchPointsRequired)
           {
            bestScore = score;
            bestTouchCount = touchCount;
            bestAnchor1 = pts[a];
            bestAnchor2 = pts[b];
            bestAnchor3 = third;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw trendline + label (3-swing validated)                        |
//+------------------------------------------------------------------+
void DrawTrendline3(const SwingPoint &anchor1, const SwingPoint &anchor2, const SwingPoint &anchor3,
                    bool isResistance, int touchCount)
  {
   string lineName  = TL_PREFIX + (isResistance ? "RESISTANCE" : "SUPPORT");
   string labelName = TL_PREFIX + (isResistance ? "RES_LABEL"   : "SUP_LABEL");

   if(anchor2.time <= anchor1.time)
      return;

   if(ObjectFind(0, lineName) < 0)
      ObjectCreate(0, lineName, OBJ_TREND, 0, anchor1.time, anchor1.price, anchor2.time, anchor2.price);
   else
     {
      ObjectMove(0, lineName, 0, anchor1.time, anchor1.price);
      ObjectMove(0, lineName, 1, anchor2.time, anchor2.price);
     }

   color lineColor = isResistance ? ResistanceColor : SupportColor;

   ObjectSetInteger(0, lineName, OBJPROP_COLOR,     lineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH,     LineWidth);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE,     LineStyle);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, ExtendToRightEdge);
   ObjectSetInteger(0, lineName, OBJPROP_BACK,      false);

// Label near 3rd swing
   string labelText = (isResistance ? "R" : "S") + " 3pt (" + IntegerToString(touchCount) + ")";
   double pad = currentATR * 0.10;
   double labelPrice = anchor3.price + (isResistance ? -pad : +pad);

   if(ObjectFind(0, labelName) < 0)
      ObjectCreate(0, labelName, OBJ_TEXT, 0, anchor3.time, labelPrice);
   else
      ObjectMove(0, labelName, 0, anchor3.time, labelPrice);

   ObjectSetString(0,  labelName, OBJPROP_TEXT,     labelText);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR,    lineColor);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, labelName, OBJPROP_BACK,     false);
  }

//+------------------------------------------------------------------+
//| Breakout check (CROSS logic for slanted lines)                    |
//+------------------------------------------------------------------+
void CheckBreakouts(const MqlRates &rates[],
                    bool haveRes, const SwingPoint &resA, const SwingPoint &resB, int resTouches,
                    bool haveSup, const SwingPoint &supA, const SwingPoint &supB, int supTouches)
  {
// Need at least 2 closed candles
   datetime t1 = rates[1].time; // last closed
   datetime t2 = rates[2].time; // previous closed
   double buf = BreakoutBufferPrice();

// Bullish breakout: cross ABOVE resistance
   if(haveRes)
     {
      double line1 = LinePriceAtTime(resA, resB, t1);
      double line2 = LinePriceAtTime(resA, resB, t2);

      double p1 = BreakoutUseClose ? rates[1].close : rates[1].high;
      double p2 = BreakoutUseClose ? rates[2].close : rates[2].high;

      bool crossedUp = (p2 <= line2 + buf) && (p1 > line1 + buf);

      if(crossedUp && t1 != g_lastBuyBarTime)
        {
         g_lastBuyBarTime = t1;

         // Draw permanent arrow for resistance breakout
         double arrowPrice = rates[1].low - currentATR * 0.15;
         if(PermanentArrows)
            DrawPermanentArrow(t1, arrowPrice, true, "RES", resTouches);

         if(AlertOnBreakout)
            Alert(_Symbol, " ", EnumToString(_Period), ": BUY breakout above resistance");
        }
     }

// Bearish breakout: cross BELOW support
   if(haveSup)
     {
      double line1 = LinePriceAtTime(supA, supB, t1);
      double line2 = LinePriceAtTime(supA, supB, t2);

      double p1 = BreakoutUseClose ? rates[1].close : rates[1].low;
      double p2 = BreakoutUseClose ? rates[2].close : rates[2].low;

      bool crossedDown = (p2 >= line2 - buf) && (p1 < line1 - buf);

      if(crossedDown && t1 != g_lastSellBarTime)
        {
         g_lastSellBarTime = t1;

         // Draw permanent arrow for support breakout
         double arrowPrice = rates[1].high + currentATR * 0.15;
         if(PermanentArrows)
            DrawPermanentArrow(t1, arrowPrice, false, "SUP", supTouches);

         if(AlertOnBreakout)
            Alert(_Symbol, " ", EnumToString(_Period), ": SELL breakout below support");
        }
     }
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
// Optional manual refresh / hotkey logic if needed
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
