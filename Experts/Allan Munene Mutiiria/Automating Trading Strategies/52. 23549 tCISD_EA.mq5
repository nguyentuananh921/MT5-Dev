//+------------------------------------------------------------------+
//|                                                     tCISD EA.mq5 |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
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

enum EntryMode
  {
   ENTRY_RETEST,      // Enter on a retest of the tCISD level
   ENTRY_CONFIRM      // Enter on the confirmation close
  };

enum SetupState
  {
   STATE_IDLE,        // No active setup
   STATE_CONFIRM,     // Awaiting the confirmation close through the level
   STATE_RETEST       // Awaiting the retest of the level
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "GENERAL"
input long            MagicNumber = 1107;                        // Magic Number
input LotSizingMode   InpLotSizingMode      = LOTS_RISK_PERCENT; // Lot sizing mode
input double          InpFixedLots          = 0.01;             // Fixed lot
input double          InpRiskPercent        = 0.5;              // Risk per trade (percent of balance)
input string          InpOrderComment       = "tCISD";          // Order comment

input group "CORRELATED SYMBOL"
input string          InpCorrelatedSymbol   = "XAGUSDm";        // Correlated symbol for the SSMT

input group "QUARTERLY THEORY CYCLE"
input int             InpCycleMinutes       = 90;               // Cycle length in minutes (quarter = cycle / 4)
input int             InpBrokerGmtOffset    = 0;                // Broker GMT offset in hours (New York DST automatic)

input group "STOP LOSS"
input int             InpStopBufferPoints   = 300;               // Buffer beyond the SSMT extreme (points)
input int             InpMinStopPoints      = 3000;             // Skip the trade if the stop is closer than this (points)

input group "TAKE PROFIT"
input double          InpRewardRiskRatio    = 2.0;              // Reward to risk ratio

input group "ENTRY"
input ENUM_TIMEFRAMES InpEntryTimeframe     = PERIOD_CURRENT;   // Entry timeframe
input EntryMode       InpEntryMode          = ENTRY_CONFIRM;     // Enter on retest or on confirmation
input int             InpMaxConfirmBars     = 24;               // Bars to wait for the close-through
input int             InpMaxRetestBars      = 24;               // Bars to wait for the retest
input int             InpMaxScanBars        = 100;              // Bars to scan back for the opposing candle

input group "PROBABILITY FILTERS"
input bool            InpUse2StageSSMT      = false;            // Require the SSMT on the cycle above too
input bool            InpUseTrueOpen        = false;             // Bearish above / bullish below the Q2 True Open
input bool            InpUsePremiumDiscount = false;             // tCISD level in the correct half of the previous cycle

input group "TRAILING STOP"
input bool            InpUseTrailingStop    = true;            // Use trailing stop
input int             InpMinProfitPoints    = 1000;             // Minimum profit to activate trailing (points)
input int             InpTrailPoints        = 300;              // Trailing distance (points)

input group "LOGGING"
input bool            InpShowLogs           = true;             // Print messages to the Journal
input string          InpLogPrefix          = "tCISD> ";        // Log prefix

input group "VISUALS"
input bool            InpDrawVisuals        = true;             // Draw structure on the chart
input bool            InpDrawQuarters       = true;             // Draw quarter dividers and labels
input int             InpMarkerSize         = 10;               // Marker size (Wingdings 3)
input color           InpBullColor          = clrDodgerBlue;    // Bullish color
input color           InpBearColor          = clrRed;           // Bearish color
input color           InpQuarterColor       = clrSlateGray;     // Quarter divider and label color
input color           InpSsmtColor          = clrMagenta;       // SSMT marker color
input color           InpTcisdColor         = clrDarkViolet;    // tCISD level color

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade   trade;                        // Trade execution object
int      symbolDigits;                 // Cached symbol digits
double   symbolPoint;                  // Cached symbol point size
string   correlatedSymbol;             // Resolved correlated symbol name
bool     correlatedReady = false;      // True once the correlated symbol is selected
int      quarterSeconds  = 1350;       // Quarter length in seconds (cycle / 4)
datetime lastBarTime     = 0;          // Last processed entry-TF bar time

//--- Cached New York DST offset (recomputed once per day)
int      newYorkOffset    = -5;        // Current NY GMT offset in hours
int      newYorkOffsetDay = -1;        // Day-of-year the offset was resolved

//--- Quarter range tracking (current and previous quarter)
datetime quarterStart         = 0;     // Server start time of the current quarter
int      quarterOfCycle       = 0;     // Index of the quarter within its cycle (0-3)
bool     havePreviousQuarter  = false; // True once a previous quarter is stored
double   primaryQuarterHigh;           // Running primary quarter high
double   primaryQuarterLow;            // Running primary quarter low
double   correlatedQuarterHigh;        // Running correlated quarter high
double   correlatedQuarterLow;         // Running correlated quarter low
double   primaryPrevQuarterHigh;       // Primary previous-quarter high
double   primaryPrevQuarterLow;        // Primary previous-quarter low
double   correlatedPrevQuarterHigh;    // Correlated previous-quarter high
double   correlatedPrevQuarterLow;     // Correlated previous-quarter low

//--- Cycle range tracking (current and previous cycle)
datetime cycleStart           = 0;     // Server start time of the current cycle
bool     havePreviousCycle    = false; // True once a previous cycle is stored
double   primaryCycleHigh;             // Running primary cycle high
double   primaryCycleLow;              // Running primary cycle low
double   correlatedCycleHigh;          // Running correlated cycle high
double   correlatedCycleLow;           // Running correlated cycle low
double   primaryPrevCycleHigh;         // Primary previous-cycle high
double   primaryPrevCycleLow;          // Primary previous-cycle low
double   correlatedPrevCycleHigh;      // Correlated previous-cycle high
double   correlatedPrevCycleLow;       // Correlated previous-cycle low
double   trueOpen             = 0.0;   // Q2 open used as the cycle True Open

//--- Setup state machine
SetupState setupState     = STATE_IDLE; // Current setup stage
int        setupDirection = 0;          // Armed direction: +1 buy, -1 sell
datetime   ssmtTime       = 0;          // Bar time of the detected SSMT
double     ssmtExtreme    = 0.0;        // Swept extreme used as the stop anchor
double     tcisdLevel     = 0.0;        // tCISD level whose break confirms entry
int        barsInState    = 0;          // Bars elapsed in the current stage

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
//| Detect the open of a new entry-TF bar                            |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
//--- Read the current entry-TF bar time
   datetime time = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Report a new bar and store its time when it changes
   if(time != lastBarTime) { lastBarTime = time; return true; }
//--- Report no new bar
   return false;
  }

//+------------------------------------------------------------------+
//| Compute UTC time of the Nth Sunday of a month at a given hour    |
//+------------------------------------------------------------------+
datetime NthSundayUtc(int year, int month, int nth, int hourUtc)
  {
//--- Build the first day of the month
   MqlDateTime start;
   start.year = year; start.mon = month; start.day = 1; start.hour = 0; start.min = 0; start.sec = 0;
   datetime firstOfMonth = StructToTime(start);
//--- Resolve the weekday of that first day
   TimeToStruct(firstOfMonth, start);
//--- Find the day-of-month of the first Sunday (0 = Sunday)
   int firstSunday = 1 + ((7 - start.day_of_week) % 7);
//--- Step forward to the requested Nth Sunday
   int day = firstSunday + (nth - 1) * 7;
//--- Build the final timestamp at the requested UTC hour
   MqlDateTime result;
   result.year = year; result.mon = month; result.day = day; result.hour = hourUtc; result.min = 0; result.sec = 0;
   return StructToTime(result);
  }

//+------------------------------------------------------------------+
//| Resolve the New York GMT offset for a given UTC moment           |
//+------------------------------------------------------------------+
int NewYorkGmtOffset(datetime utc)
  {
//--- Break the UTC moment into calendar fields
   MqlDateTime parts; TimeToStruct(utc, parts);
//--- Bound US DST: 2nd Sunday of March to 1st Sunday of November
   datetime daylightStart = NthSundayUtc(parts.year, 3, 2, 7);
   datetime daylightEnd   = NthSundayUtc(parts.year, 11, 1, 6);
//--- Return EDT inside the DST window
   if(utc >= daylightStart && utc < daylightEnd) return -4;
//--- Return EST outside the DST window
   return -5;
  }

//+------------------------------------------------------------------+
//| Resolve the New York offset once per day and cache it            |
//+------------------------------------------------------------------+
int NewYorkOffsetCached(datetime utc)
  {
//--- Break UTC into fields to detect a day change
   MqlDateTime parts; TimeToStruct(utc, parts);
//--- Recompute the offset only when the day changes
   if(parts.day_of_year != newYorkOffsetDay)
     {
      //--- Cache the day and its resolved offset
      newYorkOffsetDay = parts.day_of_year;
      newYorkOffset    = NewYorkGmtOffset(utc);
     }
//--- Return the cached offset
   return newYorkOffset;
  }

//+------------------------------------------------------------------+
//| Map a server bar time to its quarter and cycle boundaries        |
//+------------------------------------------------------------------+
void QuarterOf(datetime barServer, datetime &outQuarterStart, int &outQuarterOfCycle, datetime &outCycleStart)
  {
//--- Convert server time to UTC then to New York time
   datetime utc     = barServer - InpBrokerGmtOffset * 3600;
   int      offset  = NewYorkOffsetCached(utc);
   datetime newYork = utc + offset * 3600;
//--- Break New York time into fields
   MqlDateTime parts; TimeToStruct(newYork, parts);
//--- Seconds elapsed since New York midnight
   int secondsOfDay      = parts.hour * 3600 + parts.min * 60 + parts.sec;
//--- Seconds since the 18:00 NY daily anchor
   int secondsSinceAnchor = ((secondsOfDay - 18 * 3600) % 86400 + 86400) % 86400;
//--- Index of the current quarter from the anchor
   int quarterIndex      = secondsSinceAnchor / quarterSeconds;
//--- Position of the quarter within its 4-quarter cycle
   outQuarterOfCycle     = quarterIndex % 4;
//--- Full cycle length in seconds
   int cycleLength       = quarterSeconds * 4;
//--- Seconds into the current quarter and cycle
   int intoQuarter       = secondsSinceAnchor - quarterIndex * quarterSeconds;
   int intoCycle         = secondsSinceAnchor % cycleLength;
//--- Quarter and cycle start in New York time
   datetime quarterStartNewYork = newYork - intoQuarter;
   datetime cycleStartNewYork   = newYork - intoCycle;
//--- Convert the boundaries back to server time
   outQuarterStart = quarterStartNewYork - offset * 3600 + InpBrokerGmtOffset * 3600;
   outCycleStart   = cycleStartNewYork   - offset * 3600 + InpBrokerGmtOffset * 3600;
  }

//+------------------------------------------------------------------+
//| Read the correlated symbol high and low at a bar time            |
//+------------------------------------------------------------------+
bool CorrelatedHighLow(datetime barTime, double &high, double &low)
  {
//--- Fail when the correlated symbol is unavailable
   if(!correlatedReady) return false;
//--- Map the bar time to a shift on the correlated series
   int shift = iBarShift(correlatedSymbol, InpEntryTimeframe, barTime, false);
   if(shift < 0) return false;
//--- Read the high and low at that shift
   high = iHigh(correlatedSymbol, InpEntryTimeframe, shift);
   low  = iLow(correlatedSymbol, InpEntryTimeframe, shift);
//--- Report success only on valid prices
   return (high > 0 && low > 0);
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
//| Draw or update a horizontal trend-line level                     |
//+------------------------------------------------------------------+
void DrawLevel(string name, datetime time1, datetime time2, double price, color clr, ENUM_LINE_STYLE style, int width)
  {
//--- Create the object on first use, otherwise move both anchors
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price);
   else
     {
      //--- Move the left anchor
      ObjectMove(0, name, 0, time1, price);
      //--- Move the right anchor
      ObjectMove(0, name, 1, time2, price);
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
//| Draw or update a dotted vertical line                            |
//+------------------------------------------------------------------+
void DrawVerticalLine(string name, datetime time, color clr)
  {
//--- Create the line on first use, otherwise reposition it
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_VLINE, 0, time, 0);
   else
      ObjectMove(0, name, 0, time, 0);
//--- Apply a dotted style in the given color
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
//--- Send the line to the background
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
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
   string id = "TC_Ent_" + IntegerToString((int)time);
//--- Span the level lines a fixed number of bars to the right
   datetime endTime = time + (datetime)(PeriodSeconds(InpEntryTimeframe) * 30);
//--- Draw the entry line
   DrawLevel(id + "_e",  time, endTime, entry,      clrDodgerBlue, STYLE_SOLID, 2);
//--- Draw the stop-loss line
   DrawLevel(id + "_sl", time, endTime, stop,       C'220,60,60',  STYLE_DASH,  1);
//--- Draw the take-profit line
   DrawLevel(id + "_tp", time, endTime, takeProfit, C'0,200,80',   STYLE_DASH,  1);
//--- Read the trigger bar high and low for arrow placement
   double barHigh = iHigh(_Symbol, InpEntryTimeframe, 1);
   double barLow  = iLow(_Symbol, InpEntryTimeframe, 1);
//--- Draw the direction arrow at the trigger bar extreme
   DrawMarker(id + "_a", time, isBull ? barLow : barHigh, isBull, isBull ? InpBullColor : InpBearColor,
              isBull ? ANCHOR_UPPER : ANCHOR_LOWER);
  }

//+------------------------------------------------------------------+
//| Find the opposing candle open that defines the tCISD level       |
//+------------------------------------------------------------------+
double FindTcisdLevel(bool bearish)
  {
//--- Bound the scan to available history
   int limit = MathMin(InpMaxScanBars, iBars(_Symbol, InpEntryTimeframe) - 1);
//--- Walk back searching for the first opposing candle
   for(int shift = 1; shift <= limit; shift++)
     {
      //--- Read the candle open and close
      double openPrice  = iOpen(_Symbol, InpEntryTimeframe, shift);
      double closePrice = iClose(_Symbol, InpEntryTimeframe, shift);
      //--- Bearish setup: return the open of the last up candle
      if(bearish && closePrice > openPrice) return openPrice;
      //--- Bullish setup: return the open of the last down candle
      if(!bearish && closePrice < openPrice) return openPrice;
     }
//--- Report none found
   return 0;
  }

//+------------------------------------------------------------------+
//| Reset the setup state machine to idle                            |
//+------------------------------------------------------------------+
void ResetSetup(string reason)
  {
//--- Log the reset with its direction and reason when active
   if(setupState != STATE_IDLE)
      Log((setupDirection > 0 ? "Bullish" : "Bearish") + " tCISD setup reset: " + reason + ".");
//--- Clear the state, direction and bar counter
   setupState = STATE_IDLE;
   setupDirection = 0;
   barsInState = 0;
  }

//+------------------------------------------------------------------+
//| Track the quarterly and cyclic high/low ranges on each bar       |
//+------------------------------------------------------------------+
void UpdateCycles()
  {
//--- Read the just-closed primary bar time and prices
   datetime barTime = iTime(_Symbol, InpEntryTimeframe, 1);
   double primaryHigh = iHigh(_Symbol, InpEntryTimeframe, 1);
   double primaryLow  = iLow(_Symbol, InpEntryTimeframe, 1);
   double primaryOpen = iOpen(_Symbol, InpEntryTimeframe, 1);
//--- Read the matching correlated bar high and low
   double correlatedHigh = 0, correlatedLow = 0;
   bool haveCorrelated = CorrelatedHighLow(barTime, correlatedHigh, correlatedLow);
//--- Resolve which quarter and cycle this bar belongs to
   datetime newQuarterStart, newCycleStart; int newQuarterOfCycle;
   QuarterOf(barTime, newQuarterStart, newQuarterOfCycle, newCycleStart);
//--- Handle a change of cycle
   if(newCycleStart != cycleStart)
     {
      //--- Archive the finished cycle range as the previous cycle
      if(cycleStart != 0)
        {
         //--- Save the primary previous-cycle high and low
         primaryPrevCycleHigh = primaryCycleHigh; primaryPrevCycleLow = primaryCycleLow;
         //--- Save the correlated previous-cycle high and low
         correlatedPrevCycleHigh = correlatedCycleHigh; correlatedPrevCycleLow = correlatedCycleLow;
         //--- Mark a previous cycle as available
         havePreviousCycle = true;
        }
      //--- Start a new cycle seeded with this bar
      cycleStart = newCycleStart;
      primaryCycleHigh = primaryHigh; primaryCycleLow = primaryLow;
      correlatedCycleHigh = (haveCorrelated ? correlatedHigh : 0); correlatedCycleLow = (haveCorrelated ? correlatedLow : 0);
      //--- Clear the True Open for the fresh cycle
      trueOpen = 0.0;
     }
   else
     {
      //--- Extend the running cycle range with this bar
      if(primaryHigh > primaryCycleHigh) primaryCycleHigh = primaryHigh;
      if(primaryLow < primaryCycleLow) primaryCycleLow = primaryLow;
      //--- Extend the correlated cycle range when data exists
      if(haveCorrelated)
        {
         //--- Push the correlated cycle high up when exceeded
         if(correlatedCycleHigh == 0 || correlatedHigh > correlatedCycleHigh) correlatedCycleHigh = correlatedHigh;
         //--- Push the correlated cycle low down when exceeded
         if(correlatedCycleLow == 0 || correlatedLow < correlatedCycleLow) correlatedCycleLow = correlatedLow;
        }
     }
//--- Handle a change of quarter
   if(newQuarterStart != quarterStart)
     {
      //--- Archive the finished quarter range as the previous quarter
      if(quarterStart != 0)
        {
         //--- Save the primary previous-quarter high and low
         primaryPrevQuarterHigh = primaryQuarterHigh; primaryPrevQuarterLow = primaryQuarterLow;
         //--- Save the correlated previous-quarter high and low
         correlatedPrevQuarterHigh = correlatedQuarterHigh; correlatedPrevQuarterLow = correlatedQuarterLow;
         //--- Mark a previous quarter as available
         havePreviousQuarter = true;
        }
      //--- Start a new quarter seeded with this bar
      quarterStart = newQuarterStart;
      quarterOfCycle = newQuarterOfCycle;
      primaryQuarterHigh = primaryHigh; primaryQuarterLow = primaryLow;
      correlatedQuarterHigh = (haveCorrelated ? correlatedHigh : 0); correlatedQuarterLow = (haveCorrelated ? correlatedLow : 0);
      //--- Capture the Q2 open as the cycle True Open
      if(newQuarterOfCycle == 1) trueOpen = primaryOpen;
      //--- Draw the quarter divider, label and True Open line
      if(VisualsAllowed() && InpDrawQuarters)
        {
         //--- Draw the quarter divider and its label
         string quarterId = IntegerToString((int)newQuarterStart);
         DrawVerticalLine("TC_QDiv_" + quarterId, newQuarterStart, InpQuarterColor);
         DrawLabel("TC_QLbl_" + quarterId, newQuarterStart, primaryHigh, " Q" + IntegerToString(newQuarterOfCycle + 1), InpQuarterColor, ANCHOR_LEFT_LOWER);
         //--- Draw the True Open line once it is set
         if(trueOpen > 0)
           {
            //--- Draw and label the True Open across the cycle
            string cycleId = IntegerToString((int)cycleStart);
            DrawLevel("TC_TO_" + cycleId, cycleStart, barTime, trueOpen, InpQuarterColor, STYLE_DOT, 1);
            DrawLabel("TC_TOt_" + cycleId, barTime, trueOpen, " True Open", InpQuarterColor, ANCHOR_LEFT);
           }
        }
     }
   else
     {
      //--- Extend the running quarter range with this bar
      if(primaryHigh > primaryQuarterHigh) primaryQuarterHigh = primaryHigh;
      if(primaryLow < primaryQuarterLow) primaryQuarterLow = primaryLow;
      //--- Extend the correlated quarter range when data exists
      if(haveCorrelated)
        {
         //--- Push the correlated quarter high up when exceeded
         if(correlatedQuarterHigh == 0 || correlatedHigh > correlatedQuarterHigh) correlatedQuarterHigh = correlatedHigh;
         //--- Push the correlated quarter low down when exceeded
         if(correlatedQuarterLow == 0 || correlatedLow < correlatedQuarterLow) correlatedQuarterLow = correlatedLow;
        }
     }
  }

//+------------------------------------------------------------------+
//| Filter by the Q2 True Open bias                                  |
//+------------------------------------------------------------------+
bool PassTrueOpen(int direction, double level)
  {
//--- Pass when the filter is disabled
   if(!InpUseTrueOpen) return true;
//--- Pass when no True Open is set yet
   if(trueOpen <= 0) return true;
//--- Require the level on the correct side of the True Open
   return (direction < 0) ? (level > trueOpen) : (level < trueOpen);
  }

//+------------------------------------------------------------------+
//| Filter by premium/discount half of the previous cycle            |
//+------------------------------------------------------------------+
bool PassPremiumDiscount(int direction, double level)
  {
//--- Pass when the filter is disabled
   if(!InpUsePremiumDiscount) return true;
//--- Pass when no valid previous cycle range exists
   if(!havePreviousCycle || primaryPrevCycleHigh <= primaryPrevCycleLow) return true;
//--- Compute the previous-cycle midpoint
   double midpoint = (primaryPrevCycleHigh + primaryPrevCycleLow) / 2.0;
//--- Require the level in the premium (sell) or discount (buy) half
   return (direction < 0) ? (level > midpoint) : (level < midpoint);
  }

//+------------------------------------------------------------------+
//| Filter by an SSMT on the cycle above the quarter                 |
//+------------------------------------------------------------------+
bool PassTwoStageSSMT(int direction)
  {
//--- Pass when the filter is disabled
   if(!InpUse2StageSSMT) return true;
//--- Fail when the cycle data needed is unavailable
   if(!havePreviousCycle || correlatedCycleHigh == 0 || correlatedPrevCycleHigh == 0) return false;
//--- Bearish: require a divergence on the cycle highs
   if(direction < 0)
      return ((primaryCycleHigh > primaryPrevCycleHigh) != (correlatedCycleHigh > correlatedPrevCycleHigh));
//--- Bullish: require a divergence on the cycle lows
   return ((primaryCycleLow < primaryPrevCycleLow) != (correlatedCycleLow < correlatedPrevCycleLow));
  }

//+------------------------------------------------------------------+
//| Combine all probability filters for a direction and level        |
//+------------------------------------------------------------------+
bool PassFilters(int direction, double level)
  {
//--- Pass only when every enabled filter passes
   return PassTwoStageSSMT(direction) && PassTrueOpen(direction, level) && PassPremiumDiscount(direction, level);
  }

//+------------------------------------------------------------------+
//| Detect an SSMT divergence and arm the setup                      |
//+------------------------------------------------------------------+
void DetectSSMT()
  {
//--- Only look for a new SSMT while idle
   if(setupState != STATE_IDLE) return;
//--- Require a previous quarter and a ready correlated symbol
   if(!havePreviousQuarter || !correlatedReady) return;
//--- Require valid correlated quarter data
   if(correlatedQuarterHigh == 0 || correlatedPrevQuarterHigh == 0) return;
//--- Flag which side each symbol swept versus its previous quarter
   bool primarySweptHigh   = (primaryQuarterHigh > primaryPrevQuarterHigh);
   bool correlatedSweptHigh = (correlatedQuarterHigh > correlatedPrevQuarterHigh);
   bool primarySweptLow    = (primaryQuarterLow < primaryPrevQuarterLow);
   bool correlatedSweptLow  = (correlatedQuarterLow < correlatedPrevQuarterLow);
//--- Anchor markers to the just-closed bar
   datetime barTime = iTime(_Symbol, InpEntryTimeframe, 1);
//--- Bearish SSMT: only one symbol swept its high
   if(primarySweptHigh != correlatedSweptHigh)
     {
      //--- Locate the bearish tCISD level from an up candle
      double level = FindTcisdLevel(true);
      //--- Arm the bearish setup when the level passes the filters
      if(level > 0 && PassFilters(-1, level))
        {
         //--- Latch the armed bearish setup awaiting a close below
         setupDirection = -1; ssmtTime = barTime; ssmtExtreme = primaryQuarterHigh; tcisdLevel = level;
         setupState = STATE_CONFIRM; barsInState = 0;
         //--- Log the bearish SSMT
         Log("Bearish SSMT (highs) | tCISD level " + DoubleToString(level, symbolDigits) + " | waiting for close below");
         //--- Mark and label the swept high
         if(VisualsAllowed())
           {
            //--- Draw the SSMT marker and label at the swept high
            string id = IntegerToString((int)barTime);
            DrawMarker("TC_SSMT_" + id, barTime, ssmtExtreme, false, InpSsmtColor, ANCHOR_LOWER);
            DrawLabel("TC_SSMTt_" + id, barTime, ssmtExtreme, " SSMT", InpSsmtColor, ANCHOR_LOWER);
           }
        }
      //--- Stop after handling the high-side case
      return;
     }
//--- Bullish SSMT: only one symbol swept its low
   if(primarySweptLow != correlatedSweptLow)
     {
      //--- Locate the bullish tCISD level from a down candle
      double level = FindTcisdLevel(false);
      //--- Arm the bullish setup when the level passes the filters
      if(level > 0 && PassFilters(1, level))
        {
         //--- Latch the armed bullish setup awaiting a close above
         setupDirection = 1; ssmtTime = barTime; ssmtExtreme = primaryQuarterLow; tcisdLevel = level;
         setupState = STATE_CONFIRM; barsInState = 0;
         //--- Log the bullish SSMT
         Log("Bullish SSMT (lows) | tCISD level " + DoubleToString(level, symbolDigits) + " | waiting for close above");
         //--- Mark and label the swept low
         if(VisualsAllowed())
           {
            //--- Draw the SSMT marker and label at the swept low
            string id = IntegerToString((int)barTime);
            DrawMarker("TC_SSMT_" + id, barTime, ssmtExtreme, true, InpSsmtColor, ANCHOR_UPPER);
            DrawLabel("TC_SSMTt_" + id, barTime, ssmtExtreme, " SSMT", InpSsmtColor, ANCHOR_UPPER);
           }
        }
     }
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
//--- Place the stop beyond the swept SSMT extreme
   double stop = isBull ? ssmtExtreme - buffer : ssmtExtreme + buffer;
//--- Reject the trade when the stop is closer than the minimum
   if(MathAbs(entry - stop) / symbolPoint < InpMinStopPoints) { ResetSetup("stop below minimum"); return; }
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
//--- Set the take profit at the reward-to-risk multiple of the stop
   double takeProfit = isBull ? entry + InpRewardRiskRatio * riskDistance
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
//| Advance the setup through confirmation and retest to entry       |
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
//--- Confirmation stage: wait for the close through the level
   if(setupState == STATE_CONFIRM)
     {
      //--- Reset if both symbols resolved the bearish divergence
      if(setupDirection < 0 && primaryQuarterHigh > primaryPrevQuarterHigh && correlatedQuarterHigh > correlatedPrevQuarterHigh) { ResetSetup("SSMT resolved (both swept highs)"); return; }
      //--- Reset if both symbols resolved the bullish divergence
      if(setupDirection > 0 && primaryQuarterLow < primaryPrevQuarterLow && correlatedQuarterLow < correlatedPrevQuarterLow) { ResetSetup("SSMT resolved (both swept lows)"); return; }
      //--- Reset if the close-through never arrived in time
      if(barsInState > InpMaxConfirmBars) { ResetSetup("no close-through in time"); return; }
      //--- Test for a confirming close through the tCISD level
      bool confirmed = (setupDirection < 0) ? (closePrice < tcisdLevel) : (closePrice > tcisdLevel);
      //--- Handle a confirmed close
      if(confirmed)
        {
         //--- Anchor the confirmed level line to the current bar
         datetime now = iTime(_Symbol, InpEntryTimeframe, 0);
         //--- Draw the confirmed tCISD level and label
         if(VisualsAllowed())
           {
            //--- Draw the tCISD level line and its label
            string id = IntegerToString((int)ssmtTime);
            DrawLevel("TC_Lvl_" + id, ssmtTime, now, tcisdLevel, InpTcisdColor, STYLE_DASHDOT, 1);
            DrawLabel("TC_Lvlt_" + id, now, tcisdLevel, (setupDirection < 0 ? " -tCISD" : " +tCISD"), InpTcisdColor, ANCHOR_LEFT);
           }
         //--- Log the confirmation
         Log((setupDirection < 0 ? "Bearish" : "Bullish") + " tCISD confirmed at " + DoubleToString(tcisdLevel, symbolDigits));
         //--- Enter immediately in confirm mode, else await the retest
         if(InpEntryMode == ENTRY_CONFIRM) { OpenTrade(setupDirection > 0); return; }
         setupState = STATE_RETEST; barsInState = 0;
        }
      //--- Stop after the confirmation stage
      return;
     }
//--- Retest stage: wait for price to return to the level
   if(setupState == STATE_RETEST)
     {
      //--- Reset if the SSMT high is violated before the retest
      if(setupDirection < 0 && highPrice > ssmtExtreme) { ResetSetup("SSMT high violated before retest"); return; }
      //--- Reset if the SSMT low is violated before the retest
      if(setupDirection > 0 && lowPrice < ssmtExtreme) { ResetSetup("SSMT low violated before retest"); return; }
      //--- Reset if the retest never arrived in time
      if(barsInState > InpMaxRetestBars) { ResetSetup("no retest in time"); return; }
      //--- Enter short on a retest up into the level
      if(setupDirection < 0 && highPrice >= tcisdLevel) OpenTrade(false);
      //--- Enter long on a retest down into the level
      else if(setupDirection > 0 && lowPrice <= tcisdLevel) OpenTrade(true);
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
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
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
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(20);
//--- Derive the quarter length from the cycle length
   quarterSeconds = MathMax(60, (InpCycleMinutes * 60) / 4);
//--- Select the correlated symbol for the SSMT
   correlatedSymbol = InpCorrelatedSymbol;
   correlatedReady = SymbolSelect(correlatedSymbol, true);
//--- Warn when the correlated symbol is unavailable
   if(!correlatedReady)
      Log("WARNING: correlated symbol '" + correlatedSymbol + "' could not be selected - SSMT disabled until it is available.");
//--- Reset the setup state
   setupState = STATE_IDLE; setupDirection = 0;
//--- Reset the quarter tracking state
   quarterStart = 0; havePreviousQuarter = false;
//--- Reset the cycle tracking state
   cycleStart = 0; havePreviousCycle = false; trueOpen = 0.0;
//--- Force a DST offset recompute on first use
   newYorkOffsetDay = -1;
//--- Seed the bar-time guard
   lastBarTime = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Log a ready banner with the key settings
   Log("tCISD EA ready on " + _Symbol + " vs " + correlatedSymbol +
       " | cycle " + IntegerToString(InpCycleMinutes) + "m | Magic " + IntegerToString(MagicNumber));
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
      ObjectsDeleteAll(0, "TC_");
//--- Clear any chart comment
   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Run per-bar logic only on a new entry-TF bar
   if(IsNewBar())
     {
      //--- Update the quarter and cycle ranges
      UpdateCycles();
      //--- Look for a new SSMT divergence
      DetectSSMT();
      //--- Advance any armed setup toward entry
      ProgressSetup();
      //--- Flush chart updates when visuals are shown
      if(VisualsAllowed()) ChartRedraw(0);
     }
//--- Trail open positions every tick
   ManageTrailing();
  }
//+------------------------------------------------------------------+