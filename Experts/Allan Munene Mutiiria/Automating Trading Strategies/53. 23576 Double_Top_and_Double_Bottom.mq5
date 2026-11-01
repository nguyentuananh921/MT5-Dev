//+------------------------------------------------------------------+
//|                                 Double Top and Double Bottom.mq5 |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"

//--- Include the standard library for order execution
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum LotSizingMode
  {
   LOTS_FIXED,        // Fixed lot size
   LOTS_RISK_PERCENT  // Risk percent of balance (auto lot)
  };

enum TakeProfitMode
  {
   TP_MEASURED_MOVE,  // Project the pattern height from the neckline
   TP_REWARD_RISK     // Multiple of the stop distance
  };

enum SetupState
  {
   STATE_IDLE,        // No active pattern
   STATE_ARMED,       // Pattern found, waiting for the neckline break
   STATE_RETEST       // Break confirmed, waiting for the pullback
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "GENERAL"
input long            InpMagicNumber        = 1107;             // Magic number (unique ID for this EA)
input LotSizingMode   InpLotSizingMode      = LOTS_RISK_PERCENT; // Lot sizing mode
input double          InpFixedLots          = 0.01;             // Fixed lot
input double          InpRiskPercent        = 0.5;              // Risk per trade (percent of balance)
input string          InpOrderComment       = "DTB";            // Order comment

input group "PATTERN"
input ENUM_TIMEFRAMES InpEntryTimeframe     = PERIOD_CURRENT;   // Working timeframe
input int             InpSwingLength        = 5;                // Swing pivot length (bars each side)
input double          InpPeakTolerancePercent = 10.0;           // Max peak difference as percent of pattern height
input int             InpMinPatternBars     = 10;               // Minimum bars from first to second peak (0 = off)
input double          InpLegBalancePercent  = 50.0;             // Shorter leg as percent of longer leg, minimum (0 = off)
input bool            InpIncludeBreakLeg    = false;            // Fold the break leg into the balance test at breakout
input bool            InpRequirePriorTrend  = false;             // Require a prior trend into the pattern

input group "STOP LOSS"
input int             InpStopBufferPoints   = 3000;               // Buffer beyond the pattern extreme (points)
input int             InpMinStopPoints      = 0;                // Skip the trade if the stop is closer than this (points, 0 = off)

input group "TAKE PROFIT"
input TakeProfitMode  InpTakeProfitMode     = TP_MEASURED_MOVE; // Target mode
input double          InpRewardRiskRatio    = 1.0;              // Reward to risk ratio (R:R mode)

input group "ENTRY"
input bool            InpTradePullback      = false;             // Wait for the pullback to the neckline after the breakout
input int             InpMaxConfirmBars     = 50;               // Bars to wait for the neckline break
input int             InpMaxRetestBars      = 24;               // Bars to wait for the pullback

input group "TRAILING STOP"
input bool            InpUseTrailingStop    = true;            // Use trailing stop
input int             InpMinProfitPoints    = 1000;             // Minimum profit to activate trailing (points)
input int             InpTrailPoints        = 300;              // Trailing distance (points)

input group "LOGGING"
input bool            InpShowLogs           = true;             // Print messages to the Journal
input string          InpLogPrefix          = "DTB> ";          // Log prefix

input group "VISUALS"
input bool            InpDrawVisuals        = true;             // Draw patterns on the chart
input int             InpMarkerSize         = 10;               // Peak marker size (Wingdings 3)
input color           InpBullColor          = clrDodgerBlue;    // Double bottom color
input color           InpBearColor          = clrRed;           // Double top color
input color           InpNecklineColor      = clrGoldenrod;     // Neckline color
input color           InpTrendColor         = clrGray;          // Leading trend leg color

//+------------------------------------------------------------------+
//| Swing pivot point (high or low)                                  |
//+------------------------------------------------------------------+
struct SwingPoint
  {
   bool     isHigh;  // True for a swing high, false for a swing low
   double   price;   // Pivot price
   datetime time;    // Pivot bar time
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade   trade;                        // Trade execution object
int      symbolDigits;                 // Cached symbol digits
double   symbolPoint;                  // Cached symbol point size
datetime lastBarTime = 0;              // Last processed bar time

SwingPoint swings[];                   // Rolling buffer of detected swing pivots

//--- Pattern state machine
int        setupState           = STATE_IDLE; // Current setup stage
int        patternDirection     = 0;          // Pattern direction: -1 top, +1 bottom
double     necklineLevel        = 0.0;        // Neckline price
double     patternExtreme       = 0.0;        // Pattern high (top) or low (bottom)
datetime   peakOneTime          = 0;          // Time of the first peak
datetime   peakTwoTime          = 0;          // Time of the second peak
double     peakOnePrice         = 0.0;        // Price of the first peak
double     peakTwoPrice         = 0.0;        // Price of the second peak
datetime   necklineTime         = 0;          // Time of the neckline pivot
bool       hasLead              = false;      // True when a leading trend leg exists
datetime   leadTime             = 0;          // Time of the leading trend start
double     leadPrice            = 0.0;        // Price of the leading trend start
datetime   necklineStartTime    = 0;          // Time the neckline line starts drawing
datetime   lastPatternEndTime   = 0;          // Second-peak time of the last pattern
datetime   breakoutTime         = 0;          // Time of the neckline breakout bar
datetime   pullbackExtremeTime  = 0;          // Time of the pullback extreme
double     pullbackExtremePrice = 0.0;        // Price of the pullback extreme
int        barsInState          = 0;          // Bars elapsed in the current stage

//+------------------------------------------------------------------+
//| Print a prefixed message to the Journal                          |
//+------------------------------------------------------------------+
void Log(string message)
  {
//--- Print only when logging is enabled
   if(InpShowLogs) Print(InpLogPrefix + message);
  }

//+------------------------------------------------------------------+
//| Decide whether chart visuals may be drawn                        |
//+------------------------------------------------------------------+
bool VisualsAllowed()
  {
//--- Skip drawing during a non-visual backtest
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) return false;
//--- Otherwise honor the user visuals toggle
   return InpDrawVisuals;
  }

//+------------------------------------------------------------------+
//| Detect the open of a new bar                                     |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
//--- Read the current bar time
   datetime time = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Report a new bar and store its time when it changes
   if(time != lastBarTime) { lastBarTime = time; return true; }
//--- Report no new bar
   return false;
  }

//+------------------------------------------------------------------+
//| Convert risk percent and stop distance into a lot size           |
//+------------------------------------------------------------------+
double LotsByRisk(double entry, double stop)
  {
//--- Derive the money to risk from the account balance
   double riskMoney  = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
//--- Measure the stop distance in points
   double stopPoints = MathAbs(entry - stop) / symbolPoint;
//--- Abort on a zero stop distance
   if(stopPoints <= 0) return 0;
//--- Read the tick value and tick size for the symbol
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
//--- Abort on invalid tick metrics
   if(tickValue <= 0 || tickSize <= 0) return 0;
//--- Convert tick value into money per point
   double valuePerPoint = tickValue / tickSize * symbolPoint;
//--- Abort on an invalid per-point value
   if(valuePerPoint <= 0) return 0;
//--- Size the position so the stop loss equals the risk money
   double lots = riskMoney / (stopPoints * valuePerPoint);
//--- Read the broker volume constraints
   double volumeMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volumeMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//--- Snap the lot size down to the volume step
   if(volumeStep > 0) lots = MathFloor(lots / volumeStep) * volumeStep;
//--- Clamp within limits and normalize to two decimals
   return NormalizeDouble(MathMax(volumeMin, MathMin(volumeMax, lots)), 2);
  }

//+------------------------------------------------------------------+
//| Resolve the lot size for a trade by the selected mode            |
//+------------------------------------------------------------------+
double ResolveLots(double entry, double stop)
  {
//--- Pick fixed lots or risk-based lots by the sizing mode
   double lots = (InpLotSizingMode == LOTS_FIXED) ? InpFixedLots : LotsByRisk(entry, stop);
//--- Read the broker volume constraints
   double volumeMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volumeMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//--- Snap the lot size down to the volume step
   if(volumeStep > 0) lots = MathFloor(lots / volumeStep) * volumeStep;
//--- Clamp within limits and normalize to two decimals
   return NormalizeDouble(MathMax(volumeMin, MathMin(volumeMax, lots)), 2);
  }

//+------------------------------------------------------------------+
//| Draw or update a trend-line segment                              |
//+------------------------------------------------------------------+
void DrawTrend(string name, datetime t1, double p1, datetime t2, double p2, color clr, ENUM_LINE_STYLE style, int width)
  {
//--- Create the object on first use, otherwise move both anchors
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   else
     {
      //--- Move the first anchor
      ObjectMove(0, name, 0, t1, p1);
      //--- Move the second anchor
      ObjectMove(0, name, 1, t2, p2);
     }
//--- Apply the line color, style and width
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
//--- Keep the line as a segment, not a ray
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
//--- Make the object non-interactive and hidden from the list
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Draw or update a chart text label                                |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr, ENUM_ANCHOR_POINT anchor)
  {
//--- Create and style the label on first use
   if(ObjectFind(0, name) < 0)
     {
      //--- Create the text object at the anchor point
      ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
      //--- Set the font family and size
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
      //--- Make the label non-interactive and hidden from the list
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
//--- Refresh the label text, color and anchor
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
//--- Reposition the label
   ObjectMove(0, name, 0, time, price);
  }

//+------------------------------------------------------------------+
//| Draw a small up or down triangle marker                          |
//+------------------------------------------------------------------+
void DrawMarker(string name, datetime time, double price, bool up, color clr, int anchor)
  {
//--- Create the marker on first use, otherwise reposition it
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   else
      ObjectMove(0, name, 0, time, price);
//--- Use the Wingdings 3 font for triangle glyphs
   ObjectSetString(0, name, OBJPROP_FONT, "Wingdings 3");
//--- Scale the glyph by the marker size input
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpMarkerSize);
//--- Choose an up or down triangle glyph
   ObjectSetString(0, name, OBJPROP_TEXT, up ? "p" : "q");
//--- Apply the color and anchor
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
//--- Make the object non-interactive and hidden from the list
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Draw the entry, stop and target levels with an entry arrow       |
//+------------------------------------------------------------------+
void DrawTradeLevels(bool isBull, datetime time, double entry, double stop, double takeProfit)
  {
//--- Skip when visuals are disabled
   if(!VisualsAllowed()) return;
//--- Build a per-entry id from the entry time
   string id = "DTB_Ent_" + IntegerToString((int)time);
//--- Span the level lines a fixed number of bars to the right
   datetime endTime = time + (datetime)(PeriodSeconds(InpEntryTimeframe) * 30);
//--- Draw the entry line
   DrawTrend(id + "_e",  time, entry, endTime, entry,      clrDodgerBlue, STYLE_SOLID, 2);
//--- Draw the stop-loss line
   DrawTrend(id + "_sl", time, stop,  endTime, stop,       C'220,60,60',  STYLE_DASH,  1);
//--- Draw the take-profit line
   DrawTrend(id + "_tp", time, takeProfit, endTime, takeProfit, C'0,200,80', STYLE_DASH, 1);
//--- Read the trigger bar high and low for arrow placement
   double barHigh = iHigh(_Symbol, InpEntryTimeframe, 1);
   double barLow  = iLow(_Symbol, InpEntryTimeframe, 1);
//--- Draw the direction arrow at the trigger bar extreme
   DrawMarker(id + "_a", time, isBull ? barLow : barHigh, isBull, isBull ? InpBullColor : InpBearColor,
              isBull ? ANCHOR_UPPER : ANCHOR_LOWER);
  }

//+------------------------------------------------------------------+
//| Draw the full double top or bottom pattern                       |
//+------------------------------------------------------------------+
void DrawPattern()
  {
//--- Skip when visuals are disabled
   if(!VisualsAllowed()) return;
//--- Build a per-pattern id from the second peak time
   string id = IntegerToString((int)peakTwoTime);
//--- Pick the color and orientation for the pattern side
   color patternColor = (patternDirection < 0) ? InpBearColor : InpBullColor;
   bool topPattern = (patternDirection < 0);
//--- Extend drawing to the current bar
   datetime now = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Draw the leading trend leg when present
   if(hasLead)
      DrawTrend("DTB_Lead_" + id, leadTime, leadPrice, peakOneTime, peakOnePrice, InpTrendColor, STYLE_DOT, 1);
//--- Draw the first leg from peak one to the neckline
   DrawTrend("DTB_LegA_" + id, peakOneTime, peakOnePrice, necklineTime, necklineLevel, patternColor, STYLE_SOLID, 2);
//--- Draw the second leg from the neckline to peak two
   DrawTrend("DTB_LegB_" + id, necklineTime, necklineLevel, peakTwoTime, peakTwoPrice, patternColor, STYLE_SOLID, 2);
//--- Draw the horizontal neckline
   DrawTrend("DTB_Neck_" + id, necklineStartTime, necklineLevel, now, necklineLevel, InpNecklineColor, STYLE_DASH, 1);
//--- Label the neckline
   DrawLabel("DTB_Neckt_" + id, necklineStartTime, necklineLevel, " Neckline", InpNecklineColor,
             topPattern ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
//--- Mark the first peak
   DrawMarker("DTB_P1_" + id, peakOneTime, peakOnePrice, !topPattern, patternColor, topPattern ? ANCHOR_LOWER : ANCHOR_UPPER);
//--- Mark the second peak
   DrawMarker("DTB_P2_" + id, peakTwoTime, peakTwoPrice, !topPattern, patternColor, topPattern ? ANCHOR_LOWER : ANCHOR_UPPER);
//--- Mark the neckline pivot
   DrawMarker("DTB_N_"  + id, necklineTime, necklineLevel, topPattern, InpNecklineColor, topPattern ? ANCHOR_UPPER : ANCHOR_LOWER);
//--- Label the first peak
   DrawLabel("DTB_P1t_" + id, peakOneTime, peakOnePrice, topPattern ? " First Top" : " First Bottom",
             patternColor, topPattern ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
//--- Label the second peak
   DrawLabel("DTB_P2t_" + id, peakTwoTime, peakTwoPrice, topPattern ? " Second Top" : " Second Bottom",
             patternColor, topPattern ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
  }

//+------------------------------------------------------------------+
//| Extend the neckline line to the current bar                      |
//+------------------------------------------------------------------+
void ExtendNeckline()
  {
//--- Skip when visuals are disabled
   if(!VisualsAllowed()) return;
//--- Build the per-pattern id and current bar time
   string id = IntegerToString((int)peakTwoTime);
   datetime now = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Redraw the neckline out to the current bar
   DrawTrend("DTB_Neck_" + id, necklineStartTime, necklineLevel, now, necklineLevel, InpNecklineColor, STYLE_DASH, 1);
  }

//+------------------------------------------------------------------+
//| Draw the pullback path back to the neckline                      |
//+------------------------------------------------------------------+
void DrawPullback()
  {
//--- Skip when visuals are disabled
   if(!VisualsAllowed()) return;
//--- Build the per-pattern id and the touch bar time
   string id = IntegerToString((int)peakTwoTime);
   datetime touchTime = iTime(_Symbol, InpEntryTimeframe, 1);
//--- Pick the pattern color
   color patternColor = (patternDirection < 0) ? InpBearColor : InpBullColor;
//--- Draw the leg from the breakout to the pullback extreme
   DrawTrend("DTB_PBa_" + id, breakoutTime, necklineLevel, pullbackExtremeTime, pullbackExtremePrice, patternColor, STYLE_DASH, 1);
//--- Draw the leg from the pullback extreme back to the neckline
   DrawTrend("DTB_PBb_" + id, pullbackExtremeTime, pullbackExtremePrice, touchTime, necklineLevel, patternColor, STYLE_DASH, 1);
//--- Label the pullback
   DrawLabel("DTB_PBt_" + id, touchTime, necklineLevel, " Pullback", patternColor,
             patternDirection < 0 ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
  }

//+------------------------------------------------------------------+
//| Append a swing pivot and cap the rolling buffer                  |
//+------------------------------------------------------------------+
void AddSwing(bool isHigh, double price, datetime time)
  {
//--- Skip if this exact pivot is already stored
   int n = ArraySize(swings);
   for(int i = 0; i < n; i++)
      if(swings[i].time == time && swings[i].isHigh == isHigh) return;
//--- Append the new pivot
   ArrayResize(swings, n + 1);
   swings[n].isHigh = isHigh; swings[n].price = price; swings[n].time = time;
//--- Drop the oldest pivot once the buffer exceeds 80 entries
   if(ArraySize(swings) > 80)
     {
      //--- Shift entries down over the gap and shrink the array
      for(int i = 0; i < ArraySize(swings) - 1; i++) swings[i] = swings[i + 1];
      ArrayResize(swings, ArraySize(swings) - 1);
     }
  }

//+------------------------------------------------------------------+
//| Detect a confirmed swing high or low and store it                |
//+------------------------------------------------------------------+
void DetectSwings()
  {
//--- Center on the candidate bar with length bars each side
   int length = InpSwingLength;
   int candidate = length + 1;
//--- Require enough history to test both sides
   if(iBars(_Symbol, InpEntryTimeframe) < 2 * length + 2) return;
//--- Read the candidate bar high and low
   double candidateHigh = iHigh(_Symbol, InpEntryTimeframe, candidate);
   double candidateLow  = iLow(_Symbol, InpEntryTimeframe, candidate);
//--- Assume both a high and a low pivot until a neighbor breaks it
   bool isHigh = true, isLow = true;
//--- Compare the candidate against length bars on each side
   for(int k = 1; k <= length; k++)
     {
      //--- Reject the high candidate when a neighboring bar breaks it
      if(iHigh(_Symbol, InpEntryTimeframe, candidate - k) >= candidateHigh ||
         iHigh(_Symbol, InpEntryTimeframe, candidate + k) >  candidateHigh) isHigh = false;
      //--- Reject the low candidate when a neighboring bar breaks it
      if(iLow(_Symbol, InpEntryTimeframe, candidate - k) <= candidateLow ||
         iLow(_Symbol, InpEntryTimeframe, candidate + k) <  candidateLow) isLow = false;
     }
//--- Store the confirmed pivot(s)
   datetime candidateTime = iTime(_Symbol, InpEntryTimeframe, candidate);
   if(isHigh) AddSwing(true, candidateHigh, candidateTime);
   if(isLow)  AddSwing(false, candidateLow, candidateTime);
  }

//+------------------------------------------------------------------+
//| Store a detected pattern and arm it for the neckline break       |
//+------------------------------------------------------------------+
void ArmPattern(int direction, double neckline, datetime neckTime, double extreme, datetime t1, double p1, datetime t2, double p2, bool lead, datetime lTime, double lPrice)
  {
//--- Store the pattern direction
   patternDirection = direction;
//--- Store the neckline level and its pivot time
   necklineLevel = neckline; necklineTime = neckTime;
//--- Store the pattern extreme used as the stop anchor
   patternExtreme = extreme;
//--- Store the two peak times and prices
   peakOneTime = t1; peakOnePrice = p1;
   peakTwoTime = t2; peakTwoPrice = p2;
//--- Store the leading trend leg details
   hasLead = lead; leadTime = lTime; leadPrice = lPrice;
//--- Remember this pattern's second peak as the last pattern end
   lastPatternEndTime = t2;
//--- Default the neckline drawing to start at the first peak
   necklineStartTime = t1;
//--- Move the neckline start onto the leading leg where it crosses
   if(hasLead && MathAbs(p1 - lPrice) > 0)
     {
      //--- Interpolate the crossing point along the leading leg
      double ratio = (neckline - lPrice) / (p1 - lPrice);
      if(ratio > 0 && ratio < 1)
         necklineStartTime = lTime + (datetime)((double)(t1 - lTime) * ratio);
     }
//--- Arm the setup and reset the bar counter
   setupState = STATE_ARMED; barsInState = 0;
//--- Log the armed pattern
   Log((direction < 0 ? "Double top" : "Double bottom") + " armed | neckline " +
       DoubleToString(neckline, symbolDigits) + " | waiting for the break");
//--- Draw the pattern
   DrawPattern();
  }

//+------------------------------------------------------------------+
//| Search the recent swings for a double top or bottom              |
//+------------------------------------------------------------------+
void TryDetectPattern()
  {
//--- Only search while idle
   if(setupState != STATE_IDLE) return;
//--- Require at least three swings to form a pattern
   int n = ArraySize(swings);
   if(n < 3) return;
//--- Take the most recent swing as the second peak
   SwingPoint latest = swings[n - 1];
//--- Convert the peak tolerance percent to a fraction
   double tolerance = InpPeakTolerancePercent / 100.0;
//--- Double top: the latest swing is a high
   if(latest.isHigh)
     {
      //--- Find the previous swing high before the latest
      int priorHigh = -1;
      for(int i = n - 2; i >= 0; i--) if(swings[i].isHigh) { priorHigh = i; break; }
      if(priorHigh < 0) return;
      //--- Reject overlap with the previous pattern
      if(swings[priorHigh].time < lastPatternEndTime) return;
      //--- Take the lowest low between the two highs as the neckline
      double neckline = 0; datetime neckTime = 0; bool found = false;
      for(int i = priorHigh + 1; i < n - 1; i++)
         if(!swings[i].isHigh && (!found || swings[i].price < neckline)) { neckline = swings[i].price; neckTime = swings[i].time; found = true; }
      if(!found) return;
      //--- Measure the pattern height above the neckline
      double peak1 = swings[priorHigh].price, peak2 = latest.price;
      double height = (peak1 + peak2) / 2.0 - neckline;
      if(height <= 0) return;
      //--- Reject when the two peaks differ by more than the tolerance
      if(MathAbs(peak1 - peak2) > tolerance * height) return;
      //--- Resolve the bar shifts of the two peaks and the neckline
      int shiftPeakOne = iBarShift(_Symbol, InpEntryTimeframe, swings[priorHigh].time, false);
      int shiftNeck    = iBarShift(_Symbol, InpEntryTimeframe, neckTime, false);
      int shiftPeakTwo = iBarShift(_Symbol, InpEntryTimeframe, latest.time, false);
      //--- Reject when the two peaks are too close together
      if(InpMinPatternBars > 0 && (shiftPeakOne - shiftPeakTwo) < InpMinPatternBars) return;
      //--- Reject when the two legs are too unbalanced
      if(InpLegBalancePercent > 0)
        {
         //--- Measure the two legs in bars
         double legA = (double)(shiftPeakOne - shiftNeck);
         double legB = (double)(shiftNeck - shiftPeakTwo);
         if(legA <= 0 || legB <= 0) return;
         //--- Require the shorter leg to meet the balance percent
         if(100.0 * MathMin(legA, legB) / MathMax(legA, legB) < InpLegBalancePercent) return;
        }
      //--- Find a leading low before the first peak for the trend leg
      bool lead = false; datetime lTime = 0; double lPrice = 0;
      for(int i = priorHigh - 1; i >= 0; i--) if(!swings[i].isHigh) { lead = true; lTime = swings[i].time; lPrice = swings[i].price; break; }
      //--- Require a prior downtrend into the pattern when enabled
      if(InpRequirePriorTrend && (!lead || lPrice >= neckline)) return;
      //--- Arm the double top
      ArmPattern(-1, neckline, neckTime, MathMax(peak1, peak2), swings[priorHigh].time, peak1, latest.time, peak2, lead, lTime, lPrice);
     }
//--- Double bottom: the latest swing is a low
   else
     {
      //--- Find the previous swing low before the latest
      int priorLow = -1;
      for(int i = n - 2; i >= 0; i--) if(!swings[i].isHigh) { priorLow = i; break; }
      if(priorLow < 0) return;
      //--- Reject overlap with the previous pattern
      if(swings[priorLow].time < lastPatternEndTime) return;
      //--- Take the highest high between the two lows as the neckline
      double neckline = 0; datetime neckTime = 0; bool found = false;
      for(int i = priorLow + 1; i < n - 1; i++)
         if(swings[i].isHigh && (!found || swings[i].price > neckline)) { neckline = swings[i].price; neckTime = swings[i].time; found = true; }
      if(!found) return;
      //--- Measure the pattern height below the neckline
      double trough1 = swings[priorLow].price, trough2 = latest.price;
      double height = neckline - (trough1 + trough2) / 2.0;
      if(height <= 0) return;
      //--- Reject when the two troughs differ by more than the tolerance
      if(MathAbs(trough1 - trough2) > tolerance * height) return;
      //--- Resolve the bar shifts of the two troughs and the neckline
      int shiftTroughOne = iBarShift(_Symbol, InpEntryTimeframe, swings[priorLow].time, false);
      int shiftNeck      = iBarShift(_Symbol, InpEntryTimeframe, neckTime, false);
      int shiftTroughTwo = iBarShift(_Symbol, InpEntryTimeframe, latest.time, false);
      //--- Reject when the two troughs are too close together
      if(InpMinPatternBars > 0 && (shiftTroughOne - shiftTroughTwo) < InpMinPatternBars) return;
      //--- Reject when the two legs are too unbalanced
      if(InpLegBalancePercent > 0)
        {
         //--- Measure the two legs in bars
         double legA = (double)(shiftTroughOne - shiftNeck);
         double legB = (double)(shiftNeck - shiftTroughTwo);
         if(legA <= 0 || legB <= 0) return;
         //--- Require the shorter leg to meet the balance percent
         if(100.0 * MathMin(legA, legB) / MathMax(legA, legB) < InpLegBalancePercent) return;
        }
      //--- Find a leading high before the first trough for the trend leg
      bool lead = false; datetime lTime = 0; double lPrice = 0;
      for(int i = priorLow - 1; i >= 0; i--) if(swings[i].isHigh) { lead = true; lTime = swings[i].time; lPrice = swings[i].price; break; }
      //--- Require a prior uptrend into the pattern when enabled
      if(InpRequirePriorTrend && (!lead || lPrice <= neckline)) return;
      //--- Arm the double bottom
      ArmPattern(1, neckline, neckTime, MathMin(trough1, trough2), swings[priorLow].time, trough1, latest.time, trough2, lead, lTime, lPrice);
     }
  }

//+------------------------------------------------------------------+
//| Reset the setup state machine to idle                            |
//+------------------------------------------------------------------+
void ResetSetup(string reason)
  {
//--- Log the reset with its direction and reason when active
   if(setupState != STATE_IDLE)
      Log((patternDirection < 0 ? "Double top" : "Double bottom") + " reset: " + reason + ".");
//--- Clear the state, direction and bar counter
   setupState = STATE_IDLE;
   patternDirection = 0;
   barsInState = 0;
  }

//+------------------------------------------------------------------+
//| Size, build SL and TP, and open the trade                        |
//+------------------------------------------------------------------+
void OpenTrade(bool isBull)
  {
//--- Compute the stop buffer in price
   double buffer = InpStopBufferPoints * symbolPoint;
//--- Enter at the market on the correct side
   double entry = isBull ? NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), symbolDigits)
                         : NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), symbolDigits);
//--- Place the stop beyond the pattern extreme
   double stop = isBull ? patternExtreme - buffer : patternExtreme + buffer;
//--- Reject the trade when the stop is closer than the minimum
   if(InpMinStopPoints > 0 && MathAbs(entry - stop) / symbolPoint < InpMinStopPoints)
     { ResetSetup("stop below minimum"); return; }
//--- Read the broker minimum stop distance (stops level or spread)
   long   stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   long   spread     = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double minPoints  = (double)MathMax(stopsLevel, spread);
   if(minPoints < 1) minPoints = 1;
//--- Convert the minimum distance to price
   double minDistance = minPoints * symbolPoint;
//--- Push the stop out to the broker minimum when too tight
   if(isBull) { if(entry - stop < minDistance) stop = entry - minDistance; }
   else       { if(stop - entry < minDistance) stop = entry + minDistance; }
//--- Normalize the stop and measure the risk distance
   stop = NormalizeDouble(stop, symbolDigits);
   double riskDistance = MathAbs(entry - stop);
//--- Abort on an invalid risk distance
   if(riskDistance <= 0) { ResetSetup("invalid risk distance"); return; }
//--- Measure the pattern height for the measured-move target
   double height = MathAbs(patternExtreme - necklineLevel);
//--- Build the take profit by the selected mode
   double takeProfit;
   if(InpTakeProfitMode == TP_MEASURED_MOVE)
      //--- Measured move: project the height from the neckline
      takeProfit = isBull ? necklineLevel + height : necklineLevel - height;
   else
      //--- Reward-to-risk: multiple of the stop distance
      takeProfit = isBull ? entry + InpRewardRiskRatio * riskDistance
                          : entry - InpRewardRiskRatio * riskDistance;
//--- Push the target out to the broker minimum when too tight
   if(isBull) { if(takeProfit - entry < minDistance) takeProfit = entry + minDistance; }
   else       { if(entry - takeProfit < minDistance) takeProfit = entry - minDistance; }
//--- Normalize the target
   takeProfit = NormalizeDouble(takeProfit, symbolDigits);
//--- Resolve the lot size for this trade
   double lots = ResolveLots(entry, stop);
//--- Abort on a lot sizing error
   if(lots <= 0) { ResetSetup("lot calc error"); return; }
//--- Send the market order on the correct side
   bool ok = isBull ? trade.Buy(lots, _Symbol, entry, stop, takeProfit, InpOrderComment)
                    : trade.Sell(lots, _Symbol, entry, stop, takeProfit, InpOrderComment);
//--- Annotate and log a successful fill
   if(ok)
     {
      //--- Draw the entry, stop and target levels
      datetime now = iTime(_Symbol, InpEntryTimeframe, 0);
      DrawTradeLevels(isBull, now, entry, stop, takeProfit);
      //--- Log the fill details
      Log((isBull ? "BUY" : "SELL") + " filled @ " + DoubleToString(entry, symbolDigits) +
          "  SL=" + DoubleToString(stop, symbolDigits) + "  TP=" + DoubleToString(takeProfit, symbolDigits) +
          "  lots=" + DoubleToString(lots, 2));
     }
   else
      //--- Log the failure reason
      Log("Open failed: " + trade.ResultRetcodeDescription());
//--- Reset the setup after the attempt
   ResetSetup("filled");
  }

//+------------------------------------------------------------------+
//| Test the three legs including the break leg for balance          |
//+------------------------------------------------------------------+
bool BreakLegBalanced()
  {
//--- Resolve the bar shifts of the two peaks and the neckline
   int shiftPeakOne = iBarShift(_Symbol, InpEntryTimeframe, peakOneTime, false);
   int shiftNeck    = iBarShift(_Symbol, InpEntryTimeframe, necklineTime, false);
   int shiftPeakTwo = iBarShift(_Symbol, InpEntryTimeframe, peakTwoTime, false);
//--- Measure the three legs in bars, including the break leg to now
   double legA = (double)(shiftPeakOne - shiftNeck);
   double legB = (double)(shiftNeck - shiftPeakTwo);
   double legC = (double)(shiftPeakTwo - 1);
//--- Fail on any non-positive leg
   if(legA <= 0 || legB <= 0 || legC <= 0) return false;
//--- Compare the shortest and longest legs
   double shortest = MathMin(legA, MathMin(legB, legC));
   double longest  = MathMax(legA, MathMax(legB, legC));
//--- Pass when the shortest leg meets the balance percent
   return (100.0 * shortest / longest >= InpLegBalancePercent);
  }

//+------------------------------------------------------------------+
//| Advance the setup through the break and pullback to entry        |
//+------------------------------------------------------------------+
void ProgressSetup()
  {
//--- Do nothing while idle
   if(setupState == STATE_IDLE) return;
//--- Count another bar in the current state
   barsInState++;
//--- Read the just-closed bar close, high and low
   double closePrice = iClose(_Symbol, InpEntryTimeframe, 1);
   double highPrice  = iHigh(_Symbol, InpEntryTimeframe, 1);
   double lowPrice   = iLow(_Symbol, InpEntryTimeframe, 1);
//--- Armed stage: wait for the neckline break
   if(setupState == STATE_ARMED)
     {
      //--- Reset if price broke through the pattern extreme first
      if(patternDirection < 0 && highPrice > patternExtreme) { ResetSetup("price broke above the pattern"); return; }
      if(patternDirection > 0 && lowPrice < patternExtreme) { ResetSetup("price broke below the pattern"); return; }
      //--- Reset if the neckline break never arrived in time
      if(barsInState > InpMaxConfirmBars) { ResetSetup("no neckline break in time"); return; }
      //--- Keep the neckline extended to the current bar
      ExtendNeckline();
      //--- Test for a close through the neckline
      bool confirmed = (patternDirection < 0) ? (closePrice < necklineLevel) : (closePrice > necklineLevel);
      //--- Handle a confirmed break
      if(confirmed)
        {
         //--- Optionally reject when the break leg fails the balance test
         if(InpIncludeBreakLeg && InpLegBalancePercent > 0 && !BreakLegBalanced())
           { ResetSetup("break leg fails balance"); return; }
         //--- Log the confirmed break
         Log((patternDirection < 0 ? "Double top" : "Double bottom") + " confirmed: neckline broken at " +
             DoubleToString(necklineLevel, symbolDigits));
         //--- Record the breakout bar time
         breakoutTime = iTime(_Symbol, InpEntryTimeframe, 1);
         //--- Draw the breakout leg and label
         if(VisualsAllowed())
           {
            //--- Draw the leg from peak two to the breakout
            string bid = IntegerToString((int)peakTwoTime);
            color bcolor = (patternDirection < 0) ? InpBearColor : InpBullColor;
            DrawTrend("DTB_Break_" + bid, peakTwoTime, peakTwoPrice, breakoutTime, necklineLevel, bcolor, STYLE_SOLID, 2);
            DrawLabel("DTB_Breakt_" + bid, breakoutTime, necklineLevel, " Breakout", bcolor,
                      patternDirection < 0 ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
           }
         //--- Enter immediately unless a pullback is required
         if(!InpTradePullback) { OpenTrade(patternDirection > 0); return; }
         //--- Seed the pullback extreme and wait for the retest
         pullbackExtremeTime  = breakoutTime;
         pullbackExtremePrice = (patternDirection < 0) ? lowPrice : highPrice;
         setupState = STATE_RETEST; barsInState = 0;
        }
      //--- Stop after the armed stage
      return;
     }
//--- Retest stage: wait for the pullback to the neckline
   if(setupState == STATE_RETEST)
     {
      //--- Reset if the pattern extreme is violated before the pullback
      if(patternDirection < 0 && highPrice > patternExtreme) { ResetSetup("pattern extreme violated before pullback"); return; }
      if(patternDirection > 0 && lowPrice < patternExtreme) { ResetSetup("pattern extreme violated before pullback"); return; }
      //--- Reset if the pullback never arrived in time
      if(barsInState > InpMaxRetestBars) { ResetSetup("no pullback in time"); return; }
      //--- Keep the neckline extended to the current bar
      ExtendNeckline();
      //--- Track the deepest pullback extreme for a top
      if(patternDirection < 0 && lowPrice < pullbackExtremePrice)
        { pullbackExtremePrice = lowPrice; pullbackExtremeTime = iTime(_Symbol, InpEntryTimeframe, 1); }
      //--- Track the highest pullback extreme for a bottom
      if(patternDirection > 0 && highPrice > pullbackExtremePrice)
        { pullbackExtremePrice = highPrice; pullbackExtremeTime = iTime(_Symbol, InpEntryTimeframe, 1); }
      //--- Enter short once price pulls back up to the neckline
      if(patternDirection < 0 && highPrice >= necklineLevel) { DrawPullback(); OpenTrade(false); }
      //--- Enter long once price pulls back down to the neckline
      else if(patternDirection > 0 && lowPrice <= necklineLevel) { DrawPullback(); OpenTrade(true); }
     }
  }

//+------------------------------------------------------------------+
//| Trail the stop on this EA's open positions                       |
//+------------------------------------------------------------------+
void ManageTrailing()
  {
//--- Do nothing when trailing is disabled
   if(!InpUseTrailingStop) return;
//--- Walk every open position from last to first
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      //--- Select the position by its ticket
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      //--- Skip positions from another EA
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      //--- Skip positions on another symbol
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      //--- Read the position side, entry, stop and target
      bool   isBull  = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      double entry   = PositionGetDouble(POSITION_PRICE_OPEN);
      double curStop = PositionGetDouble(POSITION_SL);
      double curTP   = PositionGetDouble(POSITION_TP);
      //--- Read the current bid and ask
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      //--- Measure open profit in points
      double profitPoints = isBull ? (bid - entry) / symbolPoint : (entry - ask) / symbolPoint;
      //--- Trail only past the activation threshold
      if(profitPoints >= InpMinProfitPoints + InpTrailPoints)
        {
         //--- Compute the trailed stop behind price
         double newStop = isBull ? bid - InpTrailPoints * symbolPoint : ask + InpTrailPoints * symbolPoint;
         newStop = NormalizeDouble(newStop, symbolDigits);
         //--- Move the stop only when it improves protection
         bool improves = isBull ? (newStop > curStop) : (curStop == 0 || newStop < curStop);
         if(improves) trade.PositionModify(ticket, newStop, curTP);
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Cache the symbol digits and point size
   symbolDigits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   symbolPoint  = _Point;
//--- Configure the trade object magic number and slippage
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(20);
//--- Clear the swing buffer
   ArrayResize(swings, 0);
//--- Reset the setup state
   setupState = STATE_IDLE; patternDirection = 0;
//--- Reset the pattern history anchors
   lastPatternEndTime = 0; necklineStartTime = 0;
//--- Seed the bar-time guard
   lastBarTime = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Log a ready banner with the key settings
   Log("Double Top and Double Bottom EA ready on " + _Symbol + " | Magic " + IntegerToString(InpMagicNumber));
//--- Report successful initialization
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete our chart objects on a real removal or chart close
   if(reason == REASON_REMOVE || reason == REASON_CHARTCLOSE || reason == REASON_CLOSE)
      ObjectsDeleteAll(0, "DTB_");
//--- Clear any chart comment
   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Run per-bar logic only on a new bar
   if(IsNewBar())
     {
      //--- Detect new swing pivots
      DetectSwings();
      //--- Try to detect and arm a pattern
      TryDetectPattern();
      //--- Advance any armed setup toward entry
      ProgressSetup();
      //--- Flush chart updates when visuals are shown
      if(VisualsAllowed()) ChartRedraw(0);
     }
//--- Trail open positions every tick
   ManageTrailing();
  }
//+------------------------------------------------------------------+