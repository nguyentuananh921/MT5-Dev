//+------------------------------------------------------------------+
//|                                   Bread and Butter Engine EA.mq5 |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"

//--- Define the EA version string shown in the startup log
#define EA_VERSION "1.00"

//--- Include the standard library for order execution
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum TradeDirection
  {
   TRADE_BOTH,        // Both directions
   TRADE_BUYS_ONLY,   // Bullish setups only (buys)
   TRADE_SELLS_ONLY   // Bearish setups only (sells)
  };

enum LotSizingMode
  {
   LOTS_FIXED,        // Fixed lot size
   LOTS_RISK_PERCENT  // Risk percent of balance (auto lot)
  };

enum StopLossMode
  {
   SL_AUTO,           // Structural: beyond the swept extreme + buffer
   SL_MANUAL          // Fixed distance from entry (points)
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "GENERAL"
input long           InpMagicNumber        = 1107;              // Magic number
input LotSizingMode  InpLotSizingMode      = LOTS_RISK_PERCENT; // Lot sizing mode
input double         InpFixedLots          = 0.01;              // Fixed lot (Fixed mode)
input double         InpRiskPercent        = 0.5;               // Risk per trade, percent of balance (Risk mode)
input TradeDirection InpTradeDirection     = TRADE_BOTH;        // Allowed trade direction
input bool           InpAllowMultiple      = false;             // Allow several open trades at once
input string         InpOrderComment       = "BB";              // Order comment

input group "STOP LOSS"
input StopLossMode   InpStopLossMode       = SL_AUTO;           // Stop-loss mode
input int            InpStopBufferPoints   = 50;                // Auto SL: buffer beyond the swept extreme (points)
input int            InpManualStopPoints   = 11000;             // Manual SL: fixed distance from entry (points; symbol-specific)

input group "TAKE PROFIT"
input double         InpRewardRiskRatio    = 1.0;               // Reward-to-risk ratio (TP = R:R x stop distance)

input group "TRAILING STOP"
input bool           InpUseTrailingStop    = false;             // Use trailing stop
input int            InpMinProfitPoints    = 1000;              // Minimum profit points to activate trailing
input int            InpTrailPoints        = 300;               // Trailing stop points

input group "PARTIAL CLOSE (OPTIONAL)"
input bool           InpUsePartialClose    = false;             // Bank a partial at the first target
input double         InpPartialAtRR        = 1.0;               // Partial target in R
input double         InpPartialPercent     = 50.0;              // Percent of the position to close at the partial

input group "DAILY BIAS (HIGHER-TIMEFRAME STRUCTURE)"
input ENUM_TIMEFRAMES InpBiasTimeframe     = PERIOD_H4;         // Higher-timeframe bias chart
input int            InpBiasSwingLookback  = 5;                 // Bias swing pivot lookback (bars each side)

input group "KILL ZONES (NEW YORK TIME)"
input int            InpBrokerGmtOffset    = 0;                 // Broker/server GMT offset (hours). New York EST/EDT handled automatically.
input bool           InpUseLondon          = true;              // Trade the London kill zone
input string         InpLondonStart        = "02:00";           // London start (NY time HH:MM)
input string         InpLondonEnd          = "05:00";           // London end (NY time HH:MM)
input bool           InpUseNewYork         = true;              // Trade the New York kill zone
input string         InpNewYorkStart       = "08:20";           // New York start (NY time HH:MM)
input string         InpNewYorkEnd         = "11:00";           // New York end (NY time HH:MM)
input bool           InpUseAsia            = false;             // Trade the Asia kill zone
input string         InpAsiaStart          = "19:00";           // Asia start (NY time HH:MM)
input string         InpAsiaEnd            = "22:00";           // Asia end (NY time HH:MM)

input group "SETUP (JUDAS SWEEP INTO PREMIUM / DISCOUNT)"
input bool           InpRequireSweep       = true;              // Require a liquidity sweep of the recent extreme
input int            InpSweepLookback      = 20;                // Bars (entry TF) for the swept high/low
input int            InpMinSessionBars     = 3;                 // Entry-TF bars into the session before a range is valid

input group "ENTRY (MARKET STRUCTURE SHIFT)"
input ENUM_TIMEFRAMES InpEntryTimeframe    = PERIOD_CURRENT;    // Entry / trigger timeframe (current chart TF)
input int            InpMssSwingLookback   = 3;                 // Entry swing pivot lookback (bars each side)
input int            InpMaxWaitBars        = 24;                // Max entry-TF bars to wait for the MSS, then disarm

input group "LOGGING"
input bool           InpShowLogs           = true;              // Print log messages to the Journal
input string         InpLogPrefix          = "BB> ";            // Log prefix

input group "VISUALS (CHART ONLY)"
input bool           InpDrawVisuals        = true;              // Draw setup structure on the chart
input bool           InpShowSwingMarkers   = true;              // Draw entry-TF swing markers
input int            InpMarkerSize         = 10;                // Sweep / BOS / entry marker size (Wingdings 3)
input color          InpBullColor          = clrDodgerBlue;     // Bullish setup color
input color          InpBearColor          = clrRed;            // Bearish setup color
input color          InpSessionColor       = clrSlateGray;      // Kill-zone box color
input color          InpEqColor            = clrGoldenrod;      // Equilibrium line color
input color          InpSweepColor         = clrMagenta;        // Liquidity-sweep marker color
input color          InpMssColor           = clrDarkViolet;     // MSS line color
input color          InpSwingHighColor     = clrDarkOrange;     // Swing-high marker color
input color          InpSwingLowColor      = clrDodgerBlue;     // Swing-low marker color
input color          InpBiasHighColor      = clrForestGreen;    // Bias swing-high level (break = bullish)
input color          InpBiasLowColor       = clrOrangeRed;      // Bias swing-low level (break = bearish)
input color          InpPremiumColor       = C'255,232,232';    // Premium zone tint (very light)
input color          InpDiscountColor      = C'230,240,255';    // Discount zone tint (very light)

//+------------------------------------------------------------------+
//| Per-ticket trade record for partial and trailing management      |
//+------------------------------------------------------------------+
struct TradeRecord
  {
   ulong  ticket;       // Store the position ticket
   bool   isBull;       // Mark true for a buy position
   double entryPrice;   // Store the fill price
   double initialStop;  // Store the initial stop price
   double riskDistance; // Store the entry-to-initial-stop distance
   bool   partialTaken; // Mark true once the partial is banked
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade   Trade;                        // Trade execution object
int      SymDigits;                    // Cached symbol digits
double   SymPoint;                     // Cached symbol point size

datetime g_lastEntryBar = 0;           // Last processed entry-TF bar time
datetime g_lastBiasBar  = 0;           // Last processed bias-TF bar time
int      g_bias         = 0;           // Current daily bias: +1 bull, -1 bear, 0 flat

//--- Bias-TF structure tracking
double   g_biasSwingHigh     = 0.0;    // Last confirmed bias-TF swing high
datetime g_biasSwingHighTime = 0;      // Time of the last bias swing high
double   g_biasSwingLow      = 0.0;    // Last confirmed bias-TF swing low
datetime g_biasSwingLowTime  = 0;      // Time of the last bias swing low

//--- Session (kill-zone) state
string   g_activeSession   = "";       // Active kill-zone name ("" when none)
datetime g_sessionStart    = 0;        // Server time the session became active
double   g_sessionHigh     = 0.0;      // Running session high
double   g_sessionLow      = 0.0;      // Running session low
int      g_sessionBarCount = 0;        // Entry-TF bars counted this session
bool     g_sessionTraded   = false;    // Flag a setup already fired this session

//--- Cached kill-zone windows in minutes since NY midnight (parsed once)
int      g_londonStart = 0, g_londonEnd = 0;   // London window bounds
int      g_nyStart     = 0, g_nyEnd     = 0;   // New York window bounds
int      g_asiaStart   = 0, g_asiaEnd   = 0;   // Asia window bounds

//--- Cached New York DST offset (recomputed once per day)
int      g_nyOffset    = -5;           // Current NY GMT offset in hours
int      g_nyOffsetDay = -1;           // Day-of-year the offset was resolved

//--- Entry-TF swing tracking for the MSS trigger
double   g_lastSwingHigh     = 0.0;    // Last confirmed entry-TF swing high
datetime g_lastSwingHighTime = 0;      // Time of the last entry swing high
double   g_lastSwingLow      = 0.0;    // Last confirmed entry-TF swing low
datetime g_lastSwingLowTime  = 0;      // Time of the last entry swing low

//--- Armed setup state
bool     g_armed        = false;       // True while waiting for the MSS trigger
int      g_setupDir     = 0;           // Armed direction: +1 buy, -1 sell
double   g_setupExtreme = 0.0;         // Swept extreme used as the stop anchor
double   g_mssLevel     = 0.0;         // Structure level whose break confirms entry
datetime g_armBarTime   = 0;           // Entry-TF bar time the setup was armed

TradeRecord g_trades[];                // Per-ticket trade records

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
bool IsNewEntryBar()
  {
//--- Read the current entry-TF bar time
   datetime t = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Report a new bar and store its time when it changes
   if(t != g_lastEntryBar) { g_lastEntryBar = t; return true; }
//--- Report no new bar
   return false;
  }

//+------------------------------------------------------------------+
//| Convert an HH:MM string to minutes since midnight                |
//+------------------------------------------------------------------+
int ParseHHMM(string hhmm)
  {
//--- Split the text on the colon separator
   string parts[];
   int n = StringSplit(hhmm, (ushort)':', parts);
//--- Fall back to zero on a malformed value
   if(n < 2) return 0;
//--- Parse the hour and minute components
   int hh = (int)StringToInteger(parts[0]);
   int mm = (int)StringToInteger(parts[1]);
//--- Combine into total minutes since midnight
   return (hh * 60 + mm);
  }

//+------------------------------------------------------------------+
//| Compute UTC time of the Nth Sunday of a month at a given hour    |
//+------------------------------------------------------------------+
datetime NthSundayUtc(int year, int month, int nth, int atHourUtc)
  {
//--- Build the first day of the month
   MqlDateTime t;
   t.year = year; t.mon = month; t.day = 1; t.hour = 0; t.min = 0; t.sec = 0;
   datetime first = StructToTime(t);
//--- Resolve the weekday of that first day
   TimeToStruct(first, t);
//--- Find the day-of-month of the first Sunday (0 = Sunday)
   int firstSunday = 1 + ((7 - t.day_of_week) % 7);
//--- Step forward to the requested Nth Sunday
   int day = firstSunday + (nth - 1) * 7;
//--- Build the final timestamp at the requested UTC hour
   MqlDateTime r;
   r.year = year; r.mon = month; r.day = day; r.hour = atHourUtc; r.min = 0; r.sec = 0;
   return StructToTime(r);
  }

//+------------------------------------------------------------------+
//| Resolve the New York GMT offset for a given UTC moment           |
//+------------------------------------------------------------------+
int NyGmtOffset(datetime utc)
  {
//--- Break the UTC moment into calendar fields
   MqlDateTime t; TimeToStruct(utc, t);
//--- Bound US DST: 2nd Sunday of March to 1st Sunday of November
   datetime dstStart = NthSundayUtc(t.year, 3, 2, 7);
   datetime dstEnd   = NthSundayUtc(t.year, 11, 1, 6);
//--- Return EDT inside the DST window
   if(utc >= dstStart && utc < dstEnd) return -4;
//--- Return EST outside the DST window
   return -5;
  }

//+------------------------------------------------------------------+
//| Get the current New York time as minutes since midnight          |
//+------------------------------------------------------------------+
int NyMinutesNow()
  {
//--- Convert server time to UTC using the broker offset
   datetime utc = TimeCurrent() - InpBrokerGmtOffset * 3600;
//--- Break UTC into fields to detect a day change
   MqlDateTime u; TimeToStruct(utc, u);
//--- Recompute the NY DST offset only once per day
   if(u.day_of_year != g_nyOffsetDay)
     {
      //--- Cache the day and its resolved offset
      g_nyOffsetDay = u.day_of_year;
      g_nyOffset    = NyGmtOffset(utc);
     }
//--- Shift UTC into New York time and return minutes of day
   MqlDateTime t; TimeToStruct(utc + g_nyOffset * 3600, t);
   return t.hour * 60 + t.min;
  }

//+------------------------------------------------------------------+
//| Test whether a minute-of-day sits inside a window                |
//+------------------------------------------------------------------+
bool InWindow(int now, int start, int end)
  {
//--- Handle a normal same-day window
   if(start <= end) return (now >= start && now < end);
//--- Handle a window that wraps past midnight
   return (now >= start || now < end);
  }

//+------------------------------------------------------------------+
//| Resolve the active kill zone for the current New York time       |
//+------------------------------------------------------------------+
string GetActiveSession()
  {
//--- Read the current New York minute of day
   int now = NyMinutesNow();
//--- Return London when enabled and inside its window
   if(InpUseLondon  && InWindow(now, g_londonStart, g_londonEnd)) return "LONDON";
//--- Return New York when enabled and inside its window
   if(InpUseNewYork && InWindow(now, g_nyStart,     g_nyEnd))     return "NEWYORK";
//--- Return Asia when enabled and inside its window
   if(InpUseAsia    && InWindow(now, g_asiaStart,   g_asiaEnd))   return "ASIA";
//--- Report no active kill zone
   return "";
  }

//+------------------------------------------------------------------+
//| Scan for the latest confirmed swing pivot on a timeframe         |
//+------------------------------------------------------------------+
bool ScanPivot(ENUM_TIMEFRAMES tf, int lookback, bool &isHigh, bool &isLow,
               double &hiPrice, double &loPrice, datetime &pivotTime)
  {
//--- Assume no pivot until proven
   isHigh = false; isLow = false;
//--- Clamp the lookback to at least one bar each side
   int lb = MathMax(1, lookback);
//--- Require enough history to test both sides
   if(iBars(_Symbol, tf) < lb * 2 + 2) return false;
//--- Center on the candidate bar with lb closed bars to its right
   int shift = lb + 1;
   pivotTime = iTime(_Symbol, tf, shift);
   hiPrice   = iHigh(_Symbol, tf, shift);
   loPrice   = iLow(_Symbol, tf, shift);
//--- Assume both a high and a low pivot until a neighbor breaks it
   bool hh = true, ll = true;
//--- Compare the candidate against lb bars on each side
   for(int j = 1; j <= lb; j++)
     {
      //--- Reject the high if any neighbor is at least as high
      if(iHigh(_Symbol, tf, shift - j) >= hiPrice || iHigh(_Symbol, tf, shift + j) >= hiPrice) hh = false;
      //--- Reject the low if any neighbor is at least as low
      if(iLow(_Symbol, tf, shift - j)  <= loPrice || iLow(_Symbol, tf, shift + j)  <= loPrice) ll = false;
     }
//--- Publish the pivot classification
   isHigh = hh; isLow = ll;
//--- Report whether either a high or low pivot formed
   return (hh || ll);
  }

//+------------------------------------------------------------------+
//| Check whether a trade direction is permitted                     |
//+------------------------------------------------------------------+
bool IsDirectionAllowed(bool isBull)
  {
//--- Allow everything when both directions are enabled
   if(InpTradeDirection == TRADE_BOTH) return true;
//--- Allow only buys in buys-only mode
   if(InpTradeDirection == TRADE_BUYS_ONLY) return isBull;
//--- Otherwise allow only sells
   return !isBull;
  }

//+------------------------------------------------------------------+
//| Convert risk percent and stop distance into a lot size           |
//+------------------------------------------------------------------+
double CalcLotsByRisk(double entry, double stop)
  {
//--- Derive the money to risk from the account balance
   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
//--- Measure the stop distance in points
   double stopPoints = MathAbs(entry - stop) / SymPoint;
//--- Abort on a zero stop distance
   if(stopPoints <= 0) return 0;
//--- Read the tick value and tick size for the symbol
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
//--- Abort on invalid tick metrics
   if(tickValue <= 0 || tickSize <= 0) return 0;
//--- Convert tick value into money per point
   double valuePerPoint = tickValue / tickSize * SymPoint;
//--- Abort on an invalid per-point value
   if(valuePerPoint <= 0) return 0;
//--- Size the position so the stop loss equals the risk money
   double lots = riskMoney / (stopPoints * valuePerPoint);
//--- Read the broker volume constraints
   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//--- Snap the lot size down to the volume step
   if(volStep > 0) lots = MathFloor(lots / volStep) * volStep;
//--- Clamp within limits and normalize to two decimals
   return NormalizeDouble(MathMax(volMin, MathMin(volMax, lots)), 2);
  }

//+------------------------------------------------------------------+
//| Resolve the lot size for a trade by the selected mode            |
//+------------------------------------------------------------------+
double ResolveLots(double entry, double stop)
  {
//--- Pick fixed lots or risk-based lots by the sizing mode
   double lots = (InpLotSizingMode == LOTS_FIXED) ? InpFixedLots : CalcLotsByRisk(entry, stop);
//--- Read the broker volume constraints
   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//--- Snap the lot size down to the volume step
   if(volStep > 0) lots = MathFloor(lots / volStep) * volStep;
//--- Clamp within the allowed range
   lots = MathMax(volMin, MathMin(volMax, lots));
//--- Normalize to two decimals
   return NormalizeDouble(lots, 2);
  }

//+------------------------------------------------------------------+
//| Find a trade record index by ticket                              |
//+------------------------------------------------------------------+
int FindTradeRecord(ulong ticket)
  {
//--- Scan the records for a matching ticket
   for(int i = 0; i < ArraySize(g_trades); i++)
      if(g_trades[i].ticket == ticket) return i;
//--- Report not found
   return -1;
  }

//+------------------------------------------------------------------+
//| Count this EA's open positions on the current symbol             |
//+------------------------------------------------------------------+
int CountOurPositions()
  {
//--- Start the running count at zero
   int count = 0;
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
      //--- Count this position as ours
      count++;
     }
//--- Return the total owned positions
   return count;
  }

//+------------------------------------------------------------------+
//| Append a new trade record for a freshly opened position          |
//+------------------------------------------------------------------+
void AddTradeRecord(ulong ticket, bool isBull, double entry, double stop)
  {
//--- Ignore an invalid or already-tracked ticket
   if(ticket == 0 || FindTradeRecord(ticket) >= 0) return;
//--- Grow the record array by one slot
   int n = ArraySize(g_trades);
   ArrayResize(g_trades, n + 1);
//--- Populate the new record from the fill details
   g_trades[n].ticket       = ticket;
   g_trades[n].isBull       = isBull;
   g_trades[n].entryPrice   = entry;
   g_trades[n].initialStop  = stop;
   g_trades[n].riskDistance = MathAbs(entry - stop);
   g_trades[n].partialTaken = false;
  }

//+------------------------------------------------------------------+
//| Drop records whose positions have closed                         |
//+------------------------------------------------------------------+
void PruneTradeRecords()
  {
//--- Walk records backward so removals stay safe
   for(int i = ArraySize(g_trades) - 1; i >= 0; i--)
      //--- Remove the record once its position no longer exists
      if(!PositionSelectByTicket(g_trades[i].ticket))
        {
         //--- Shift later records down over the gap
         for(int j = i; j < ArraySize(g_trades) - 1; j++) g_trades[j] = g_trades[j + 1];
         //--- Shrink the array by one slot
         ArrayResize(g_trades, ArraySize(g_trades) - 1);
        }
  }

//+------------------------------------------------------------------+
//| Adopt any of our open positions missing a record                 |
//+------------------------------------------------------------------+
void SyncTradeRecords()
  {
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
      //--- Skip positions already tracked
      if(FindTradeRecord(ticket) >= 0) continue;
      //--- Grow the record array by one slot
      int n = ArraySize(g_trades);
      ArrayResize(g_trades, n + 1);
      //--- Rebuild the record from live position data
      g_trades[n].ticket       = ticket;
      g_trades[n].isBull       = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      g_trades[n].entryPrice   = PositionGetDouble(POSITION_PRICE_OPEN);
      g_trades[n].initialStop  = PositionGetDouble(POSITION_SL);
      g_trades[n].riskDistance = MathAbs(g_trades[n].entryPrice - g_trades[n].initialStop);
      //--- Mark adopted positions as already partialed to avoid a surprise scale-out
      g_trades[n].partialTaken = true;
     }
  }

//+------------------------------------------------------------------+
//| Test whether a fresh liquidity sweep of the extreme occurred     |
//+------------------------------------------------------------------+
bool SweepDone(bool forSell)
  {
//--- Treat the sweep as satisfied when the filter is off
   if(!InpRequireSweep) return true;
//--- Clamp the lookback to at least two bars
   int n = MathMax(2, InpSweepLookback);
//--- Require enough history for the lookback plus buffer
   if(iBars(_Symbol, InpEntryTimeframe) < n + 3) return false;
//--- For a sell, test a take-out of the prior N-bar high
   if(forSell)
     {
      //--- Locate the highest high across the prior window
      int idx = iHighest(_Symbol, InpEntryTimeframe, MODE_HIGH, n, 2);
      if(idx < 0) return false;
      //--- Confirm the last closed bar pushed above it
      return (iHigh(_Symbol, InpEntryTimeframe, 1) > iHigh(_Symbol, InpEntryTimeframe, idx));
     }
//--- For a buy, locate the lowest low across the prior window
   int idx2 = iLowest(_Symbol, InpEntryTimeframe, MODE_LOW, n, 2);
   if(idx2 < 0) return false;
//--- Confirm the last closed bar pushed below it
   return (iLow(_Symbol, InpEntryTimeframe, 1) < iLow(_Symbol, InpEntryTimeframe, idx2));
  }

//+------------------------------------------------------------------+
//| Reset the armed setup state                                      |
//+------------------------------------------------------------------+
void Disarm(string reason)
  {
//--- Do nothing when no setup is armed
   if(!g_armed) return;
//--- Clear the armed flag
   g_armed = false;
//--- Log the disarm with its direction and reason
   Log((g_setupDir > 0 ? "Bullish" : "Bearish") + " setup disarmed: " + reason + ".");
  }

//+------------------------------------------------------------------+
//| Draw or update a horizontal trend-line level                     |
//+------------------------------------------------------------------+
void DrawHLevel(string name, datetime t1, datetime t2, double price, color clr, ENUM_LINE_STYLE style, int width)
  {
//--- Create the object on first use, otherwise move both anchors
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   else
     {
      //--- Move the left anchor
      ObjectMove(0, name, 0, t1, price);
      //--- Move the right anchor
      ObjectMove(0, name, 1, t2, price);
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
//--- Draw the line in the foreground
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }

//+------------------------------------------------------------------+
//| Draw or update a chart text label                                |
//+------------------------------------------------------------------+
void DrawText(string name, datetime t, double price, string text, color clr, ENUM_ANCHOR_POINT anchor)
  {
//--- Create and style the label on first use
   if(ObjectFind(0, name) < 0)
     {
      //--- Create the text object at the anchor point
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
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
   ObjectMove(0, name, 0, t, price);
  }

//+------------------------------------------------------------------+
//| Draw or update an outlined rectangle                             |
//+------------------------------------------------------------------+
void DrawRect(string name, datetime t1, double p1, datetime t2, double p2, color clr)
  {
//--- Create the rectangle on first use, otherwise move both corners
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   else
     {
      //--- Move the first corner
      ObjectMove(0, name, 0, t1, p1);
      //--- Move the second corner
      ObjectMove(0, name, 1, t2, p2);
     }
//--- Apply a solid outline in the given color
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
//--- Send the rectangle to the background without filling it
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_FILL, false);
//--- Make the object non-interactive and hidden from the list
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Draw or update a filled background rectangle                     |
//+------------------------------------------------------------------+
void DrawRectFill(string name, datetime t1, double p1, datetime t2, double p2, color clr)
  {
//--- Create the rectangle on first use, otherwise move both corners
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   else
     {
      //--- Move the first corner
      ObjectMove(0, name, 0, t1, p1);
      //--- Move the second corner
      ObjectMove(0, name, 1, t2, p2);
     }
//--- Apply a solid fill in the given color
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
//--- Send the fill to the background
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
//--- Make the object non-interactive and hidden from the list
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Draw or update an arrow object                                   |
//+------------------------------------------------------------------+
void DrawArrow(string name, datetime t, double price, int code, color clr, int anchor)
  {
//--- Create the arrow on first use, otherwise reposition it
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_ARROW, 0, t, price);
   else
      ObjectMove(0, name, 0, t, price);
//--- Set the arrow glyph code
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
//--- Apply the color and width
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
//--- Set the anchor point
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
//--- Make the object non-interactive and hidden from the list
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Draw a small up or down triangle marker                          |
//+------------------------------------------------------------------+
void DrawMarker(string name, datetime t, double price, bool up, color clr, int anchor)
  {
//--- Create the marker on first use, otherwise reposition it
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   else
      ObjectMove(0, name, 0, t, price);
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
//| Draw or refresh the active kill-zone box and equilibrium         |
//+------------------------------------------------------------------+
void DrawSessionBox()
  {
//--- Skip when visuals are off or no session is active
   if(!VisualsAllowed() || g_activeSession == "" || g_sessionStart == 0) return;
//--- Build a per-session id so the box persists across bars
   string id  = IntegerToString((int)g_sessionStart);
//--- Extend the right edge to the current time
   datetime t2 = TimeCurrent();
//--- Compute the equilibrium at the range midpoint
   double eq = (g_sessionHigh + g_sessionLow) / 2.0;
//--- Fill the premium (sell) zone above equilibrium
   DrawRectFill("BB_Prem_" + id, g_sessionStart, g_sessionHigh, t2, eq, InpPremiumColor);
//--- Fill the discount (buy) zone below equilibrium
   DrawRectFill("BB_Disc_" + id, g_sessionStart, eq, t2, g_sessionLow, InpDiscountColor);
//--- Outline the full session range
   DrawRect("BB_Sess_" + id, g_sessionStart, g_sessionHigh, t2, g_sessionLow, InpSessionColor);
//--- Label the session by name
   DrawText("BB_SessTxt_" + id, g_sessionStart, g_sessionHigh, " " + g_activeSession, InpSessionColor, ANCHOR_LOWER);
//--- Draw the dotted equilibrium line
   DrawHLevel("BB_EQ_" + id, g_sessionStart, t2, eq, InpEqColor, STYLE_DOT, 1);
//--- Label the equilibrium line
   DrawText("BB_EQTxt_" + id, t2, eq, " EQ", InpEqColor, ANCHOR_LEFT);
//--- Label the premium half
   DrawText("BB_PremTxt_" + id, t2, (g_sessionHigh + eq) / 2.0, "Premium ", InpBearColor, ANCHOR_RIGHT);
//--- Label the discount half
   DrawText("BB_DiscTxt_" + id, t2, (g_sessionLow + eq) / 2.0, "Discount ", InpBullColor, ANCHOR_RIGHT);
  }

//+------------------------------------------------------------------+
//| Draw the active higher-timeframe bias structure levels           |
//+------------------------------------------------------------------+
void DrawBiasStructure()
  {
//--- Skip when visuals are disabled
   if(!VisualsAllowed()) return;
//--- Anchor the level lines to the current entry-TF bar
   datetime now = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Draw the bias high whose break turns order flow bullish
   if(g_biasSwingHigh > 0 && g_biasSwingHighTime > 0)
     {
      //--- Draw the bias-high line
      DrawHLevel("BB_BiasHigh", g_biasSwingHighTime, now, g_biasSwingHigh, InpBiasHighColor, STYLE_SOLID, 1);
      //--- Label the bias-high line
      DrawText("BB_BiasHighTxt", now, g_biasSwingHigh, " Bias High", InpBiasHighColor, ANCHOR_LEFT);
     }
//--- Draw the bias low whose break turns order flow bearish
   if(g_biasSwingLow > 0 && g_biasSwingLowTime > 0)
     {
      //--- Draw the bias-low line
      DrawHLevel("BB_BiasLow", g_biasSwingLowTime, now, g_biasSwingLow, InpBiasLowColor, STYLE_SOLID, 1);
      //--- Label the bias-low line
      DrawText("BB_BiasLowTxt", now, g_biasSwingLow, " Bias Low", InpBiasLowColor, ANCHOR_LEFT);
     }
  }

//+------------------------------------------------------------------+
//| Draw or extend the MSS trigger line for the armed setup          |
//+------------------------------------------------------------------+
void DrawMssLine()
  {
//--- Skip when visuals are off or no setup is armed
   if(!VisualsAllowed() || !g_armed || g_mssLevel <= 0) return;
//--- Build a per-setup id from the arm bar time
   string id = IntegerToString((int)g_armBarTime);
//--- Extend the line to the current entry-TF bar
   datetime now = iTime(_Symbol, InpEntryTimeframe, 0);
//--- Draw the dash-dot MSS trigger line
   DrawHLevel("BB_MSS_" + id, g_armBarTime, now, g_mssLevel, InpMssColor, STYLE_DASHDOT, 1);
//--- Label the MSS line
   DrawText("BB_MSSTxt_" + id, now, g_mssLevel, " MSS", InpMssColor, ANCHOR_LEFT);
  }

//+------------------------------------------------------------------+
//| Draw the entry, stop and target levels with an entry arrow       |
//+------------------------------------------------------------------+
void DrawEntryLevels(bool isBull, datetime t, double entry, double stop, double takeProfit)
  {
//--- Skip when visuals are disabled
   if(!VisualsAllowed()) return;
//--- Build a per-entry id from the entry time
   string id = "BB_Ent_" + IntegerToString((int)t);
//--- Span the level lines a fixed number of bars to the right
   datetime t2 = t + (datetime)(PeriodSeconds(InpEntryTimeframe) * 30);
//--- Draw the entry line
   DrawHLevel(id + "_e",  t, t2, entry,      clrDodgerBlue, STYLE_SOLID, 2);
//--- Draw the stop-loss line
   DrawHLevel(id + "_sl", t, t2, stop,       C'220,60,60',  STYLE_DASH,  1);
//--- Draw the take-profit line
   DrawHLevel(id + "_tp", t, t2, takeProfit, C'0,200,80',   STYLE_DASH,  1);
//--- Read the trigger bar high and low for arrow placement
   double barHigh = iHigh(_Symbol, InpEntryTimeframe, 1);
   double barLow  = iLow(_Symbol, InpEntryTimeframe, 1);
//--- Draw the direction arrow at the trigger bar extreme
   DrawMarker(id + "_a", t, isBull ? barLow : barHigh, isBull,
              isBull ? InpBullColor : InpBearColor, isBull ? ANCHOR_UPPER : ANCHOR_LOWER);
  }

//+------------------------------------------------------------------+
//| Draw an entry-TF swing marker with its label                     |
//+------------------------------------------------------------------+
void DrawSwingMarker(bool isHigh, datetime t, double price, string label, color clr)
  {
//--- Skip when visuals or swing markers are disabled
   if(!VisualsAllowed() || !InpShowSwingMarkers) return;
//--- Build a unique tag for a high or low marker
   string tag = (isHigh ? "BB_SWH_" : "BB_SWL_") + IntegerToString((int)t);
//--- Place a dot on the pivot, above a high or below a low
   int dotAnchor = isHigh ? ANCHOR_BOTTOM : ANCHOR_TOP;
   DrawArrow(tag, t, price, 159, clr, dotAnchor);
//--- Anchor the label text opposite the dot side
   ENUM_ANCHOR_POINT txtAnchor = ANCHOR_LEFT_UPPER;
   if(isHigh) txtAnchor = ANCHOR_LEFT_LOWER;
//--- Draw the H/HH/LH or L/LL/HL label beside the dot
   DrawText(tag + "_t", t, price, label, clr, txtAnchor);
  }

//+------------------------------------------------------------------+
//| Update the higher-timeframe bias from market structure           |
//+------------------------------------------------------------------+
void UpdateBias()
  {
//--- Only recompute on a fresh bias-TF bar
   datetime bt = iTime(_Symbol, InpBiasTimeframe, 0);
   if(bt == g_lastBiasBar) return;
   g_lastBiasBar = bt;
//--- Refresh the latest bias-TF swing points
   bool isHigh, isLow; double hi, lo; datetime t;
   if(ScanPivot(InpBiasTimeframe, InpBiasSwingLookback, isHigh, isLow, hi, lo, t))
     {
      //--- Store a new swing high when found
      if(isHigh && t != g_biasSwingHighTime) { g_biasSwingHigh = hi; g_biasSwingHighTime = t; }
      //--- Store a new swing low when found
      if(isLow  && t != g_biasSwingLowTime)  { g_biasSwingLow  = lo; g_biasSwingLowTime  = t; }
     }
//--- Remember the prior bias to detect a change
   int prevBias = g_bias;
//--- Read the last closed bias-TF close
   double c1 = iClose(_Symbol, InpBiasTimeframe, 1);
//--- Turn bullish on a close above the last swing high
   if(g_biasSwingHigh > 0 && c1 > g_biasSwingHigh)      g_bias = 1;
//--- Turn bearish on a close below the last swing low
   else if(g_biasSwingLow > 0 && c1 < g_biasSwingLow)   g_bias = -1;
//--- Act only when the bias actually flips
   if(g_bias != prevBias)
     {
      //--- Log the new directional bias
      Log("Bias -> " + (g_bias > 0 ? "BULLISH" : (g_bias < 0 ? "BEARISH" : "NEUTRAL")));
      //--- Mark the break of structure on its broken swing level
      if(g_bias != 0 && VisualsAllowed())
        {
         //--- Select the broken level for the new bias
         bool bull = (g_bias > 0);
         double brokenLevel = bull ? g_biasSwingHigh : g_biasSwingLow;
         //--- Anchor the marker to the bar that broke structure
         datetime bosBar = iTime(_Symbol, InpBiasTimeframe, 1);
         string nm = "BB_BOS_" + IntegerToString((int)bosBar);
         color clr = bull ? InpBiasHighColor : InpBiasLowColor;
         //--- Draw the break-of-structure marker on its line
         DrawMarker(nm, bosBar, brokenLevel, bull, clr, bull ? ANCHOR_UPPER : ANCHOR_LOWER);
         //--- Anchor the label above a bullish break or below a bearish one
         ENUM_ANCHOR_POINT a = ANCHOR_LEFT_LOWER;
         if(bull) a = ANCHOR_LEFT_UPPER;
         //--- Label the break of structure
         DrawText(nm + "_t", bosBar, brokenLevel, bull ? " BULLISH BOS" : " BEARISH BOS", clr, a);
        }
     }
  }

//+------------------------------------------------------------------+
//| Detect the latest confirmed entry-TF swing high and low          |
//+------------------------------------------------------------------+
void DetectEntrySwings()
  {
//--- Scan for a fresh entry-TF pivot, else bail out
   bool isHigh, isLow; double hi, lo; datetime t;
   if(!ScanPivot(InpEntryTimeframe, InpMssSwingLookback, isHigh, isLow, hi, lo, t)) return;
//--- Handle a fresh swing high
   if(isHigh && t != g_lastSwingHighTime)
     {
      //--- Label it H, HH or LH against the previous high
      string label; color clr = InpSwingHighColor;
      if(g_lastSwingHigh <= 0)      label = "H";
      else if(hi > g_lastSwingHigh) label = "HH";
      else                        { label = "LH"; clr = InpSwingLowColor; }
      //--- Draw the swing-high marker
      DrawSwingMarker(true, t, hi, label, clr);
      //--- Store the new swing high
      g_lastSwingHigh = hi; g_lastSwingHighTime = t;
     }
//--- Handle a fresh swing low
   if(isLow && t != g_lastSwingLowTime)
     {
      //--- Label it L, LL or HL against the previous low
      string label; color clr = InpSwingLowColor;
      if(g_lastSwingLow <= 0)      label = "L";
      else if(lo < g_lastSwingLow)  label = "LL";
      else                       { label = "HL"; clr = InpSwingHighColor; }
      //--- Draw the swing-low marker
      DrawSwingMarker(false, t, lo, label, clr);
      //--- Store the new swing low
      g_lastSwingLow = lo; g_lastSwingLowTime = t;
     }
  }

//+------------------------------------------------------------------+
//| Try to arm a setup inside the active kill zone                   |
//+------------------------------------------------------------------+
void TryArm()
  {
//--- Require an active session, a bias, and no existing armed setup
   if(g_activeSession == "" || g_bias == 0 || g_armed || g_sessionTraded) return;
//--- Respect the single-trade limit unless multiples are allowed
   if(!InpAllowMultiple && CountOurPositions() > 0) return;
//--- Require enough session bars for a valid range
   if(g_sessionBarCount < InpMinSessionBars) return;
//--- Require a non-degenerate session range
   if(g_sessionHigh <= g_sessionLow) return;
//--- Compute the equilibrium and read the current bid
   double eq    = (g_sessionHigh + g_sessionLow) / 2.0;
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
//--- Bearish flow: fade a push into premium after a high sweep
   if(g_bias < 0 && IsDirectionAllowed(false))
     {
      //--- Arm only above equilibrium with a completed sweep
      if(price >= eq && SweepDone(true))
        {
         //--- Latch the armed bearish setup, MSS on a break below the last swing low
         g_armed        = true;
         g_setupDir     = -1;
         g_setupExtreme = g_sessionHigh;
         g_mssLevel     = g_lastSwingLow;
         g_armBarTime   = iTime(_Symbol, InpEntryTimeframe, 0);
         //--- Log the armed bearish setup
         Log("Bearish setup ARMED in " + g_activeSession + " | premium sweep done, waiting for MSS below " + DoubleToString(g_mssLevel, SymDigits));
         //--- Mark the swept high
         DrawMarker("BB_Sweep_" + IntegerToString((int)g_armBarTime), g_armBarTime, g_setupExtreme, false, InpSweepColor, ANCHOR_LOWER);
         //--- Label the swept high
         DrawText("BB_SweepTxt_" + IntegerToString((int)g_armBarTime), g_armBarTime, g_setupExtreme, " SWEEP", InpSweepColor, ANCHOR_LOWER);
         //--- Draw the pending MSS trigger line
         DrawMssLine();
        }
     }
//--- Bullish flow: fade a push into discount after a low sweep
   else if(g_bias > 0 && IsDirectionAllowed(true))
     {
      //--- Arm only below equilibrium with a completed sweep
      if(price <= eq && SweepDone(false))
        {
         //--- Latch the armed bullish setup, MSS on a break above the last swing high
         g_armed        = true;
         g_setupDir     = 1;
         g_setupExtreme = g_sessionLow;
         g_mssLevel     = g_lastSwingHigh;
         g_armBarTime   = iTime(_Symbol, InpEntryTimeframe, 0);
         //--- Log the armed bullish setup
         Log("Bullish setup ARMED in " + g_activeSession + " | discount sweep done, waiting for MSS above " + DoubleToString(g_mssLevel, SymDigits));
         //--- Mark the swept low
         DrawMarker("BB_Sweep_" + IntegerToString((int)g_armBarTime), g_armBarTime, g_setupExtreme, true, InpSweepColor, ANCHOR_UPPER);
         //--- Label the swept low
         DrawText("BB_SweepTxt_" + IntegerToString((int)g_armBarTime), g_armBarTime, g_setupExtreme, " SWEEP", InpSweepColor, ANCHOR_UPPER);
         //--- Draw the pending MSS trigger line
         DrawMssLine();
        }
     }
  }

//+------------------------------------------------------------------+
//| Size, build SL and TP, and open the trade                        |
//+------------------------------------------------------------------+
void OpenTrade(bool isBull)
  {
//--- Respect the single-trade limit unless multiples are allowed
   if(!InpAllowMultiple && CountOurPositions() > 0) return;
//--- Enter at the market on the correct side
   double entry = isBull ? NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymDigits)
                         : NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), SymDigits);
//--- Build the stop loss by the selected mode
   double stop;
   if(InpStopLossMode == SL_MANUAL)
     {
      //--- Manual: fixed point distance from entry
      double slDist = InpManualStopPoints * SymPoint;
      stop = isBull ? entry - slDist : entry + slDist;
     }
   else
     {
      //--- Auto: beyond the swept extreme by the buffer
      double buffer = InpStopBufferPoints * SymPoint;
      stop = isBull ? g_setupExtreme - buffer : g_setupExtreme + buffer;
     }
//--- Normalize the stop and measure the risk distance
   stop = NormalizeDouble(stop, SymDigits);
   double riskDistance = MathAbs(entry - stop);
//--- Abort on an invalid risk distance
   if(riskDistance <= 0) { Disarm("invalid risk distance"); return; }
//--- Set the take profit at the reward-to-risk multiple of the stop
   double takeProfit = NormalizeDouble(isBull ? entry + InpRewardRiskRatio * riskDistance
                                              : entry - InpRewardRiskRatio * riskDistance, SymDigits);
//--- Resolve the lot size for this trade
   double lots = ResolveLots(entry, stop);
//--- Abort on a lot sizing error
   if(lots <= 0) { Disarm("lot calc error"); return; }
//--- Send the market order on the correct side
   bool ok = isBull ? Trade.Buy(lots, _Symbol, entry, stop, takeProfit, InpOrderComment)
                    : Trade.Sell(lots, _Symbol, entry, stop, takeProfit, InpOrderComment);
//--- Record and annotate a successful fill
   if(ok)
     {
      //--- Track the new position for later management
      ulong ticket = Trade.ResultOrder();
      AddTradeRecord(ticket, isBull, entry, stop);
      //--- Lock the session to one trade
      g_sessionTraded = true;
      //--- Draw the entry, stop and target levels
      datetime now = iTime(_Symbol, InpEntryTimeframe, 0);
      DrawEntryLevels(isBull, now, entry, stop, takeProfit);
      //--- Log the fill with its resulting reward-to-risk
      double rr = MathAbs(takeProfit - entry) / riskDistance;
      Log((isBull ? "BUY" : "SELL") + " filled @ " + DoubleToString(entry, SymDigits) +
          "  SL=" + DoubleToString(stop, SymDigits) + "  TP=" + DoubleToString(takeProfit, SymDigits) +
          "  lots=" + DoubleToString(lots, 2) + "  (R:R " + DoubleToString(rr, 2) + ")");
     }
   else
      //--- Log the failure reason
      Log("Open failed: " + Trade.ResultRetcodeDescription());
//--- Clear the armed flag after the attempt
   g_armed = false;
  }

//+------------------------------------------------------------------+
//| While armed, update the trigger and check for the MSS entry      |
//+------------------------------------------------------------------+
void CheckArmedForEntry()
  {
//--- Do nothing when no setup is armed
   if(!g_armed) return;
//--- Disarm if the bearish bias no longer holds
   if(g_setupDir < 0 && g_bias >= 0) { Disarm("bias no longer bearish"); return; }
//--- Disarm if the bullish bias no longer holds
   if(g_setupDir > 0 && g_bias <= 0) { Disarm("bias no longer bullish"); return; }
//--- Disarm once the kill zone has ended
   if(g_activeSession == "")         { Disarm("kill zone ended"); return; }
//--- Disarm if the setup waited too long without a trigger
   int barsElapsed = iBarShift(_Symbol, InpEntryTimeframe, g_armBarTime);
   if(barsElapsed > InpMaxWaitBars) { Disarm("no MSS in time"); return; }
//--- Read the last closed entry-TF close
   double priorClose = iClose(_Symbol, InpEntryTimeframe, 1);
//--- Handle the armed bearish setup
   if(g_setupDir < 0)
     {
      //--- Track the swept high and refresh the MSS level
      g_setupExtreme = MathMax(g_setupExtreme, iHigh(_Symbol, InpEntryTimeframe, 1));
      if(g_lastSwingLow > 0) g_mssLevel = g_lastSwingLow;
      //--- Extend the MSS line
      DrawMssLine();
      //--- Enter short on a close below the structure level
      if(g_mssLevel > 0 && priorClose < g_mssLevel) OpenTrade(false);
     }
   else
     {
      //--- Track the swept low and refresh the MSS level
      g_setupExtreme = MathMin(g_setupExtreme, iLow(_Symbol, InpEntryTimeframe, 1));
      if(g_lastSwingHigh > 0) g_mssLevel = g_lastSwingHigh;
      //--- Extend the MSS line
      DrawMssLine();
      //--- Enter long on a close above the structure level
      if(g_mssLevel > 0 && priorClose > g_mssLevel) OpenTrade(true);
     }
  }

//+------------------------------------------------------------------+
//| Manage one open trade with optional partial and trailing         |
//+------------------------------------------------------------------+
void ManageOneTrade(ulong ticket)
  {
//--- Select the position and confirm it is ours on this symbol
   if(!PositionSelectByTicket(ticket)) return;
   if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) return;
   if(PositionGetString(POSITION_SYMBOL) != _Symbol) return;
//--- Read the core position fields
   bool   isBull      = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
   double entry       = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentStop = PositionGetDouble(POSITION_SL);
   double currentTP   = PositionGetDouble(POSITION_TP);
   double volume      = PositionGetDouble(POSITION_VOLUME);
//--- Recover the original risk distance from the record when available
   int    recIdx       = FindTradeRecord(ticket);
   double riskDistance = (recIdx >= 0 && g_trades[recIdx].riskDistance > 0)
                          ? g_trades[recIdx].riskDistance : MathAbs(entry - currentStop);
//--- Abort on a zero risk distance
   if(riskDistance <= 0) return;
//--- Read the current bid and ask
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
//--- Express open profit in R multiples
   double profitR = isBull ? (bid - entry) / riskDistance : (entry - ask) / riskDistance;
//--- Bank a one-time partial once the first R target is reached
   if(InpUsePartialClose && recIdx >= 0 && !g_trades[recIdx].partialTaken && profitR >= InpPartialAtRR)
     {
      //--- Read the volume constraints for the partial
      double volMin   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double volStep  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      //--- Compute the closable volume snapped to the step
      double closeVol = MathFloor((volume * InpPartialPercent / 100.0) / volStep) * volStep;
      closeVol = NormalizeDouble(closeVol, 2);
      //--- Close the partial only if both sides stay above the minimum
      if(closeVol >= volMin && (volume - closeVol) >= volMin)
         if(Trade.PositionClosePartial(ticket, closeVol))
            Log("Partial close " + DoubleToString(closeVol, 2) + " @ " + DoubleToString(profitR, 2) + "R");
      //--- Mark the partial as taken regardless of outcome
      g_trades[recIdx].partialTaken = true;
     }
//--- Trail the stop once past the minimum profit plus trail distance
   if(InpUseTrailingStop)
     {
      //--- Measure open profit in points
      double profitPoints = isBull ? (bid - entry) / SymPoint : (entry - ask) / SymPoint;
      //--- Activate trailing past the activation threshold
      if(profitPoints >= InpMinProfitPoints + InpTrailPoints)
        {
         //--- Compute the trailed stop behind price
         double newStop = isBull ? bid - InpTrailPoints * SymPoint : ask + InpTrailPoints * SymPoint;
         newStop = NormalizeDouble(newStop, SymDigits);
         //--- Move the stop only when it improves protection
         bool improves = isBull ? (newStop > currentStop) : (currentStop == 0 || newStop < currentStop);
         if(improves) Trade.PositionModify(ticket, newStop, currentTP);
        }
     }
  }

//+------------------------------------------------------------------+
//| Manage every tracked open trade                                  |
//+------------------------------------------------------------------+
void ManageOpenTrades()
  {
//--- Walk the records backward and manage each position
   for(int i = ArraySize(g_trades) - 1; i >= 0; i--)
      ManageOneTrade(g_trades[i].ticket);
  }

//+------------------------------------------------------------------+
//| Handle the day rollover and active-session lifecycle             |
//+------------------------------------------------------------------+
void UpdateSessionState()
  {
//--- Resolve which kill zone is active now
   string active = GetActiveSession();
//--- Track whether a new session just opened this bar
   bool justStarted = false;
//--- React only when the active session changes
   if(active != g_activeSession)
     {
      //--- Initialize state when entering a new session
      if(active != "")
        {
         //--- Stamp the session start time
         g_sessionStart      = TimeCurrent();
         //--- Seed the range with the first session bar
         g_sessionHigh       = iHigh(_Symbol, InpEntryTimeframe, 0);
         g_sessionLow        = iLow(_Symbol, InpEntryTimeframe, 0);
         //--- Reset the session counters and flags
         g_sessionBarCount   = 0;
         g_sessionTraded     = false;
         //--- Clear entry swings for a fresh session
         g_lastSwingHigh     = 0.0; g_lastSwingHighTime = 0;
         g_lastSwingLow      = 0.0; g_lastSwingLowTime  = 0;
         //--- Flag the fresh start and log it
         justStarted         = true;
         Log("Entered kill zone: " + active);
        }
      //--- Disarm any pending setup when the session ends
      else if(g_armed) Disarm("kill zone ended");
      //--- Store the new active session name
      g_activeSession = active;
     }
//--- Extend the range with the just-closed in-session bar
   if(g_activeSession != "" && !justStarted)
     {
      //--- Read the last closed bar range
      double hi = iHigh(_Symbol, InpEntryTimeframe, 1);
      double lo = iLow(_Symbol, InpEntryTimeframe, 1);
      //--- Push the session high up when exceeded
      if(hi > g_sessionHigh) g_sessionHigh = hi;
      //--- Push the session low down when exceeded
      if(lo < g_sessionLow)  g_sessionLow  = lo;
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Cache the symbol digits and point size
   SymDigits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   SymPoint  = _Point;
//--- Configure the trade object magic number and slippage
   Trade.SetExpertMagicNumber(InpMagicNumber);
   Trade.SetDeviationInPoints(20);
//--- Parse the kill-zone windows once to avoid per-bar work
   g_londonStart = ParseHHMM(InpLondonStart);  g_londonEnd = ParseHHMM(InpLondonEnd);
   g_nyStart     = ParseHHMM(InpNewYorkStart); g_nyEnd     = ParseHHMM(InpNewYorkEnd);
   g_asiaStart   = ParseHHMM(InpAsiaStart);    g_asiaEnd   = ParseHHMM(InpAsiaEnd);
//--- Force a DST offset recompute on first use
   g_nyOffsetDay = -1;
//--- Reset the trade records and setup state
   ArrayResize(g_trades, 0);
   g_armed         = false;
   g_activeSession = "";
//--- Adopt any of our positions already open
   SyncTradeRecords();
//--- Seed the bar-time guards
   g_lastEntryBar = iTime(_Symbol, InpEntryTimeframe, 0);
   g_lastBiasBar  = 0;
//--- Log a ready banner with the key settings
   Log("Bread & Butter Engine EA v" + EA_VERSION + " ready on " + _Symbol +
       " | entry " + EnumToString(InpEntryTimeframe) + " | bias " + EnumToString(InpBiasTimeframe) +
       " | Magic " + IntegerToString(InpMagicNumber));
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
      ObjectsDeleteAll(0, "BB_");
//--- Clear any chart comment
   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Run per-bar logic only on a new entry-TF bar
   if(IsNewEntryBar())
     {
      //--- Update the kill-zone session lifecycle
      UpdateSessionState();
      //--- Update the higher-timeframe bias (self-gates to bias bars)
      UpdateBias();
      //--- Do setup work only inside an active kill zone
      if(g_activeSession != "")
        {
         //--- Count another in-session bar
         g_sessionBarCount++;
         //--- Detect the latest entry-TF swings
         DetectEntrySwings();
         //--- Try to arm a setup on a sweep
         TryArm();
         //--- Check the armed setup for the MSS entry
         CheckArmedForEntry();
        }
      //--- Reconcile records only when positions may exist
      if(ArraySize(g_trades) > 0 || PositionsTotal() > 0)
        {
         //--- Drop closed positions then adopt untracked ones
         PruneTradeRecords();
         SyncTradeRecords();
        }
      //--- Draw only when visuals are shown
      if(VisualsAllowed())
        {
         //--- Draw the bias structure levels
         DrawBiasStructure();
         //--- Draw the session box while a session is active
         if(g_activeSession != "") DrawSessionBox();
         //--- Flush the chart updates
         ChartRedraw(0);
        }
     }
//--- Manage trades every tick only when trailing or partials are on
   if(InpUseTrailingStop || InpUsePartialClose) ManageOpenTrades();
  }
//+------------------------------------------------------------------+