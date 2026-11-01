//+------------------------------------------------------------------+
//|                                    Quasimodo (QM) Pattern EA.mq5 |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"

//--- Define the EA version string
#define EA_VERSION "1.00"

//--- Include the trade library
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
   TP_REWARD_RISK,    // Reward-to-risk multiple
   TP_STRUCTURE       // Structural broken-swing extreme
  };

enum TrailingMode
  {
   TRAIL_OFF,         // No trailing
   TRAIL_ATR,         // ATR distance behind price
   TRAIL_POINTS       // Fixed points behind price
  };

enum TradeDirection
  {
   TRADE_BOTH,        // Both directions
   TRADE_BUYS_ONLY,   // Bullish QM only (buys)
   TRADE_SELLS_ONLY   // Bearish QM only (sells)
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "GENERAL"
input long           InpMagicNumber           = 1107;              // Magic number (unique ID for this EA)
input string         InpOrderComment          = "QM";              // Order comment
input TradeDirection InpTradeDirection        = TRADE_BOTH;        // Allowed trade direction
input bool           InpAllowMultipleTrades   = false;             // Allow several open trades at once
input bool           InpShowLogs              = true;              // Print log messages to the Journal
input string         InpLogPrefix             = "QM> ";            // Log prefix

input group "RISK & POSITION SIZING"
input LotSizingMode  InpLotSizingMode         = LOTS_RISK_PERCENT; // Lot sizing mode
input double         InpFixedLots             = 0.01;              // Fixed lot (Fixed mode)
input double         InpRiskPercent           = 0.5;               // Risk per trade, percent of balance (Risk mode)

input group "SWING / PATTERN DETECTION"
input int            InpSwingLookback         = 5;                 // Swing pivot lookback (bars each side)
input int            InpEntryBufferPoints     = 0;                 // Points the close must clear beyond the QM line
input bool           InpWaitForRejectionClose = false;             // Wait for a confirmation close back through the QM line
input int            InpMaxWaitBars           = 30;                // Max bars to wait for the retrace, then cancel
input double         InpMinRewardRisk         = 1.0;               // Skip setups whose target reward-to-risk is below this
input bool           InpSkipSharedShoulder    = true;              // Skip a new setup that reuses the last Left Shoulder
input bool           InpRequirePriorTrend     = true;              // Require a prior trend into the pattern
input int            InpTrendPivots           = 2;                 // Swing pivots behind the Left Shoulder to confirm the trend

input group "STOP LOSS"
input int            InpStopBufferPoints      = 200;               // Buffer beyond the Head (points)
input bool           InpUseAtrStopFloor       = true;              // Widen the stop to an ATR floor if structural stop is tight
input int            InpAtrPeriod             = 14;                // ATR period (stop floor and ATR trail)
input double         InpAtrStopMultiplier     = 1.0;               // ATR multiple for the stop floor

input group "TAKE PROFIT"
input TakeProfitMode InpTakeProfitMode        = TP_REWARD_RISK;    // Take-profit mode
input double         InpRewardRiskRatio       = 2.0;               // Reward-to-risk ratio (RR mode)

input group "TRADE MANAGEMENT"
input bool           InpUseBreakeven          = true;              // Move stop to breakeven
input double         InpBreakevenAtRR         = 1.0;               // Profit in R before breakeven
input int            InpBreakevenLockPoints   = 50;                // Points locked beyond entry at breakeven
input TrailingMode   InpTrailingMode          = TRAIL_OFF;         // Trailing-stop method for the runner
input double         InpTrailStartRR          = 1.5;               // Profit in R before ATR trailing begins
input double         InpTrailAtrMultiplier    = 2.0;               // ATR multiple for the ATR trailing distance
input int            InpTrailLockPoints       = 1000;              // Points trail: min profit (points) locked once trailing begins
input int            InpTrailDistancePoints   = 300;               // Points trail: distance behind price (points)
input bool           InpUsePartialClose       = false;             // Bank a partial at the first target
input double         InpPartialAtRR           = 1.0;               // Partial target in R
input double         InpPartialPercent        = 50.0;              // Percent of the position to close at the partial

input group "CHART VISUALS"
input bool           InpDrawVisuals           = true;              // Draw QM structure (lines, levels, arrows)
input bool           InpShowSwingMarkers      = true;              // Draw labeled swing points (H/HH/LH, L/LL/HL)
input color          InpBullColor             = clrDodgerBlue;     // Bullish QM color
input color          InpBearColor             = clrRed;            // Bearish QM color
input color          InpQmLineColor           = clrDarkViolet;     // QM line (entry) color
input color          InpSwingHighColor        = clrDarkOrange;     // Swing-high marker color
input color          InpSwingLowColor         = clrDodgerBlue;     // Swing-low marker color
input color          InpTrendColor            = clrGray;           // Prior-trend connector color

//+------------------------------------------------------------------+
//| Swing pivot point                                                |
//+------------------------------------------------------------------+
struct SwingPivot
  {
   bool     isHigh; // True when the pivot is a swing high
   double   price;  // Pivot price
   datetime time;   // Pivot bar time
  };

//+------------------------------------------------------------------+
//| Armed QM setup awaiting the retrace                              |
//+------------------------------------------------------------------+
struct ArmedSetup
  {
   bool     isActive;      // True while the setup waits for entry
   bool     isBull;        // True for a bullish QM (buy)
   double   qmLinePrice;   // Shoulder price, the entry level (QM line)
   double   headPrice;     // Head price, the invalidation and stop anchor
   double   targetPrice;   // Structural target (broken swing extreme)
   double   legPrice;      // Broken leg level (for the BOS drawing)
   datetime shoulderTime;  // Left-shoulder bar time
   datetime legTime;       // Leg bar time
   datetime headTime;      // Head bar time
   datetime bosTime;       // Break-of-structure bar time
   double   shoulderPrice; // Left-shoulder price
   datetime armedTime;     // Bar time the setup was armed (expiry base)
   bool     lineBroken;    // True once price closed beyond the QM line (rejection step 1)
  };

//+------------------------------------------------------------------+
//| Per-ticket trade record                                          |
//+------------------------------------------------------------------+
struct TradeRecord
  {
   ulong  ticket;       // Position ticket
   bool   isBull;       // True for a buy
   double entryPrice;   // Fill price
   double initialStop;  // Initial stop price
   double riskDistance; // Distance between entry and the initial stop
   bool   partialTaken; // True once the partial has been banked
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade   Trade;                       // Trade execution object
int      SymDigits;                   // Symbol digits
double   SymPoint;                    // Symbol point size
int      AtrHandle = INVALID_HANDLE;  // ATR indicator handle
datetime g_lastBarTime = 0;           // Time of the last processed bar

SwingPivot g_pivots[];                // Alternating H/L zig-zag of confirmed pivots
int        g_maxPivots = 24;          // Max zig-zag pivots to retain

double   g_lastLabeledHigh = 0.0;     // Last labeled swing-high price
datetime g_lastLabeledHighTime = 0;   // Last labeled swing-high time
double   g_lastLabeledLow = 0.0;      // Last labeled swing-low price
datetime g_lastLabeledLowTime = 0;    // Last labeled swing-low time

ArmedSetup g_setup;                   // Current armed QM setup
datetime g_lastArmedBosTime = 0;      // Guard against re-arming the same pattern
datetime g_lastArmedShoulderTime = 0; // Guard against reusing the same Left Shoulder

TradeRecord g_trades[];               // Per-ticket trade records

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
   //--- Allow drawing otherwise
   return true;
  }

//+------------------------------------------------------------------+
//| Detect the open of a new bar                                     |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   //--- Read the current bar's open time
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   //--- Report a new bar when the open time advances
   if(currentBarTime != g_lastBarTime)
     {
      //--- Store the new bar time and signal a fresh bar
      g_lastBarTime = currentBarTime;
      return true;
     }
   //--- Same bar as before
   return false;
  }

//+------------------------------------------------------------------+
//| Read one indicator buffer value at a shift                       |
//+------------------------------------------------------------------+
double IndicatorValue(int handle, int buffer, int shift)
  {
   //--- Receive a single value from the buffer
   double values[];
   //--- Fail safe when the copy returns nothing
   if(CopyBuffer(handle, buffer, shift, 1, values) < 1) return EMPTY_VALUE;
   //--- Return the copied value
   return values[0];
  }

//+------------------------------------------------------------------+
//| Check whether a trade direction is permitted                     |
//+------------------------------------------------------------------+
bool IsDirectionAllowed(bool isBull)
  {
   //--- Allow both directions
   if(InpTradeDirection == TRADE_BOTH) return true;
   //--- Allow only buys
   if(InpTradeDirection == TRADE_BUYS_ONLY) return isBull;
   //--- Otherwise allow only sells
   return !isBull;
  }

//+------------------------------------------------------------------+
//| Convert risk percent and stop distance into a lot size           |
//+------------------------------------------------------------------+
double CalcLotsByRisk(double entry, double stop)
  {
   //--- Compute the money to risk from balance and risk percent
   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
   //--- Measure the stop distance in points
   double stopPoints = MathAbs(entry - stop) / SymPoint;
   //--- Abort on a zero stop distance
   if(stopPoints <= 0) return 0;
   //--- Read the tick value and tick size
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   //--- Abort on invalid tick metrics
   if(tickValue <= 0 || tickSize <= 0) return 0;
   //--- Derive the money value of one point per lot
   double valuePerPoint = tickValue / tickSize * SymPoint;
   //--- Abort on a zero point value
   if(valuePerPoint <= 0) return 0;
   //--- Size the position from risk money and stop value
   double lots = riskMoney / (stopPoints * valuePerPoint);
   //--- Read the broker volume constraints
   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   //--- Floor the lot to the volume step
   if(volStep > 0) lots = MathFloor(lots / volStep) * volStep;
   //--- Clamp to the allowed range and normalize
   return NormalizeDouble(MathMax(volMin, MathMin(volMax, lots)), 2);
  }

//+------------------------------------------------------------------+
//| Find a trade record index by ticket                             |
//+------------------------------------------------------------------+
int FindTradeRecord(ulong ticket)
  {
   //--- Scan every stored record
   for(int i = 0; i < ArraySize(g_trades); i++)
      //--- Return the index on a ticket match
      if(g_trades[i].ticket == ticket) return i;
   //--- Report not found
   return -1;
  }

//+------------------------------------------------------------------+
//| Count this EA's open positions on the symbol                     |
//+------------------------------------------------------------------+
int CountOurPositions()
  {
   //--- Start a running count
   int count = 0;
   //--- Walk the open positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      //--- Select the position by index
      ulong ticket = PositionGetTicket(i);
      //--- Skip on a failed select
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      //--- Skip foreign magic numbers
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      //--- Skip other symbols
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      //--- Count this position
      count++;
     }
   //--- Return the total
   return count;
  }

//+------------------------------------------------------------------+
//| Append a new trade record                                        |
//+------------------------------------------------------------------+
void AddTradeRecord(ulong ticket, bool isBull, double entry, double stop)
  {
   //--- Ignore an empty or already-tracked ticket
   if(ticket == 0 || FindTradeRecord(ticket) >= 0) return;
   //--- Grow the records array by one
   int n = ArraySize(g_trades);
   ArrayResize(g_trades, n + 1);
   //--- Populate the new record
   g_trades[n].ticket       = ticket;
   g_trades[n].isBull       = isBull;
   g_trades[n].entryPrice   = entry;
   g_trades[n].initialStop  = stop;
   g_trades[n].riskDistance = MathAbs(entry - stop);
   g_trades[n].partialTaken = false;
  }

//+------------------------------------------------------------------+
//| Drop records whose position has closed                           |
//+------------------------------------------------------------------+
void PruneTradeRecords()
  {
   //--- Walk the records from the back
   for(int i = ArraySize(g_trades) - 1; i >= 0; i--)
     {
      //--- Act when the position no longer exists
      if(!PositionSelectByTicket(g_trades[i].ticket))
        {
         //--- Shift later records down over the gap
         for(int j = i; j < ArraySize(g_trades) - 1; j++) g_trades[j] = g_trades[j + 1];
         //--- Shrink the array by one
         ArrayResize(g_trades, ArraySize(g_trades) - 1);
        }
     }
  }

//+------------------------------------------------------------------+
//| Adopt any of our open positions not yet tracked                  |
//+------------------------------------------------------------------+
void SyncTradeRecords()
  {
   //--- Walk the open positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      //--- Select the position by index
      ulong ticket = PositionGetTicket(i);
      //--- Skip on a failed select
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      //--- Skip foreign magic numbers
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      //--- Skip other symbols
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      //--- Skip already-tracked tickets
      if(FindTradeRecord(ticket) >= 0) continue;
      //--- Grow the records array by one
      int n = ArraySize(g_trades);
      ArrayResize(g_trades, n + 1);
      //--- Populate the adopted record from the live position
      g_trades[n].ticket       = ticket;
      g_trades[n].isBull       = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      g_trades[n].entryPrice   = PositionGetDouble(POSITION_PRICE_OPEN);
      g_trades[n].initialStop  = PositionGetDouble(POSITION_SL);
      g_trades[n].riskDistance = MathAbs(g_trades[n].entryPrice - g_trades[n].initialStop);
      //--- Mark adopted so no unintended partial fires
      g_trades[n].partialTaken = true;
     }
  }

//+------------------------------------------------------------------+
//| Push a confirmed pivot into the alternating zig-zag              |
//+------------------------------------------------------------------+
void AddPivotToZigZag(bool isHigh, double price, datetime time)
  {
   //--- Read the current pivot count
   int count = ArraySize(g_pivots);
   //--- Seed the very first pivot directly
   if(count == 0)
     {
      //--- Store the first pivot and return
      ArrayResize(g_pivots, 1);
      g_pivots[0].isHigh = isHigh;
      g_pivots[0].price  = price;
      g_pivots[0].time   = time;
      return;
     }
   //--- Merge when the new pivot repeats the last type
   if(g_pivots[count - 1].isHigh == isHigh)
     {
      //--- Keep only the more extreme of the two
      bool moreExtreme = isHigh ? (price > g_pivots[count - 1].price) : (price < g_pivots[count - 1].price);
      //--- Overwrite the last pivot when this one is more extreme
      if(moreExtreme)
        {
         //--- Replace price and time on the last pivot
         g_pivots[count - 1].price = price;
         g_pivots[count - 1].time  = time;
        }
      return;
     }
   //--- Append the alternating pivot
   ArrayResize(g_pivots, count + 1);
   g_pivots[count].isHigh = isHigh;
   g_pivots[count].price  = price;
   g_pivots[count].time   = time;
   //--- Cap the stored history
   if(ArraySize(g_pivots) > g_maxPivots)
     {
      //--- Compute how many old pivots to drop
      int drop = ArraySize(g_pivots) - g_maxPivots;
      //--- Shift the surviving pivots to the front
      for(int i = 0; i < ArraySize(g_pivots) - drop; i++) g_pivots[i] = g_pivots[i + drop];
      //--- Trim the array to the cap
      ArrayResize(g_pivots, g_maxPivots);
     }
  }

//+------------------------------------------------------------------+
//| Confirm a prior trend behind the Left Shoulder                   |
//+------------------------------------------------------------------+
bool IsPriorTrendConfirmed(bool isBull, int shoulderIndex)
  {
   //--- Pass when the trend filter is off
   if(!InpRequirePriorTrend) return true;
   //--- Pass when fewer than two pivots are requested
   if(InpTrendPivots < 2) return true;
   //--- Walk back this many pivots from the shoulder
   int oldestIndex = shoulderIndex - InpTrendPivots;
   //--- Fail when there is not enough history behind the shoulder
   if(oldestIndex < 0) return false;
   //--- Compare each same-type pair (two apart) up to the shoulder
   for(int i = oldestIndex; i + 2 <= shoulderIndex; i++)
     {
      //--- Read the earlier same-type pivot
      double earlier = g_pivots[i].price;
      //--- Read the later same-type pivot
      double later = g_pivots[i + 2].price;
      //--- Require ascending pivots for a prior uptrend (bearish QM)
      if(!isBull) { if(!(later > earlier)) return false; }
      //--- Require descending pivots for a prior downtrend (bullish QM)
      else        { if(!(later < earlier)) return false; }
     }
   //--- All compared pairs stair-stepped correctly
   return true;
  }

//+------------------------------------------------------------------+
//| Create or move a trend-line segment                              |
//+------------------------------------------------------------------+
void DrawTrendline(string name, datetime time1, double price1, datetime time2, double price2, color clr, ENUM_LINE_STYLE style, int width, bool ray = false)
  {
   //--- Create the object when missing
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2);
   //--- Otherwise reposition the existing object
   else
     {
      //--- Move both anchors of the line
      ObjectMove(0, name, 0, time1, price1);
      ObjectMove(0, name, 1, time2, price2);
     }
   //--- Apply color, style and width
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   //--- Set the ray flags
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   //--- Hide from selection and keep in the foreground
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }

//+------------------------------------------------------------------+
//| Draw a horizontal segment between two times                      |
//+------------------------------------------------------------------+
void DrawHLevel(string name, datetime time1, datetime time2, double price, color clr, ENUM_LINE_STYLE style, int width)
  {
   //--- Draw a flat trend line at a single price
   DrawTrendline(name, time1, price, time2, price, clr, style, width, false);
  }

//+------------------------------------------------------------------+
//| Create or update a text label                                    |
//+------------------------------------------------------------------+
void DrawText(string name, datetime time, double price, string text, color clr, ENUM_ANCHOR_POINT anchor)
  {
   //--- Create the label once with its font and flags
   if(ObjectFind(0, name) < 0)
     {
      //--- Build the text object
      ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   //--- Refresh the text, color and anchor
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   //--- Reposition the label
   ObjectMove(0, name, 0, time, price);
  }

//+------------------------------------------------------------------+
//| Draw one labeled swing marker (icon and text)                    |
//+------------------------------------------------------------------+
void DrawSwingMarker(bool isHigh, datetime time, double price, string label, color clr)
  {
   //--- Build unique object names for this pivot
   string tag      = (isHigh ? "QM_SWH_" : "QM_SWL_") + IntegerToString((int)time);
   string iconName = tag + "_i";
   string textName = tag + "_t";
   //--- Create the round marker icon once
   if(ObjectFind(0, iconName) < 0)
     {
      //--- Build the Wingdings marker
      ObjectCreate(0, iconName, OBJ_TEXT, 0, time, price);
      ObjectSetString(0, iconName, OBJPROP_FONT, "Wingdings");
      ObjectSetString(0, iconName, OBJPROP_TEXT, CharToString(174));
      ObjectSetInteger(0, iconName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, iconName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, iconName, OBJPROP_ANCHOR, isHigh ? ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, iconName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, iconName, OBJPROP_HIDDEN, true);
     }
   //--- Create the H/HH/LH or L/LL/HL text once
   if(ObjectFind(0, textName) < 0)
     {
      //--- Build the label text
      ObjectCreate(0, textName, OBJ_TEXT, 0, time, price);
      ObjectSetString(0, textName, OBJPROP_FONT, "Arial Bold");
      ObjectSetString(0, textName, OBJPROP_TEXT, label);
      ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, textName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, textName, OBJPROP_ANCHOR, isHigh ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, textName, OBJPROP_HIDDEN, true);
     }
   //--- Repaint the chart
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw the full QM structure for the armed setup                   |
//+------------------------------------------------------------------+
void DrawQMStructure()
  {
   //--- Skip when visuals are disabled
   if(!(InpDrawVisuals && VisualsAllowed())) return;
   //--- Pick the direction color and build the base object name
   color  clr  = g_setup.isBull ? InpBullColor : InpBearColor;
   string id   = IntegerToString((int)g_setup.bosTime);
   string base = "QM_STRUCT_" + id;
   //--- Draw the shoulder -> leg zig-zag leg
   DrawTrendline(base + "_l1", g_setup.shoulderTime, g_setup.shoulderPrice, g_setup.legTime, g_setup.legPrice, clr, STYLE_SOLID, 2);
   //--- Draw the leg -> head zig-zag leg
   DrawTrendline(base + "_l2", g_setup.legTime, g_setup.legPrice, g_setup.headTime, g_setup.headPrice, clr, STYLE_SOLID, 2);
   //--- Draw the head -> BOS zig-zag leg
   DrawTrendline(base + "_l3", g_setup.headTime, g_setup.headPrice, g_setup.bosTime, g_setup.targetPrice, clr, STYLE_SOLID, 2);
   //--- Draw the broken leg level (the BOS line)
   DrawHLevel(base + "_bosln", g_setup.legTime, g_setup.bosTime, g_setup.legPrice, clr, STYLE_DOT, 1);
   //--- Label the Left Shoulder
   DrawText(base + "_ls", g_setup.shoulderTime, g_setup.shoulderPrice, "Left Shoulder", clr, g_setup.isBull ? ANCHOR_UPPER : ANCHOR_LOWER);
   //--- Label the Head
   DrawText(base + "_head", g_setup.headTime, g_setup.headPrice, "Head", clr, g_setup.isBull ? ANCHOR_LOWER : ANCHOR_UPPER);
   //--- Label the Leg
   DrawText(base + "_leg", g_setup.legTime, g_setup.legPrice, g_setup.isBull ? "Leg high" : "Leg low", clr, g_setup.isBull ? ANCHOR_LOWER : ANCHOR_UPPER);
   //--- Label the Break of Structure
   DrawText(base + "_bos", g_setup.bosTime, g_setup.legPrice, " BOS", clr, g_setup.isBull ? ANCHOR_LOWER : ANCHOR_UPPER);
   //--- Compute the right edge of the QM line through the wait window
   datetime lineEnd = g_setup.bosTime + (datetime)(PeriodSeconds(_Period) * (InpMaxWaitBars + 5));
   //--- Draw the QM entry line at the shoulder level
   DrawHLevel(base + "_qml", g_setup.shoulderTime, lineEnd, g_setup.qmLinePrice, InpQmLineColor, STYLE_DASH, 1);
   //--- Label the QM entry line
   DrawText(base + "_qmltxt", lineEnd, g_setup.qmLinePrice, " QM line (entry)", InpQmLineColor, ANCHOR_LEFT);
   //--- Repaint the chart
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw the prior-trend connector behind the shoulder               |
//+------------------------------------------------------------------+
void DrawPriorTrend(int shoulderIndex, bool isBull, string baseName, color clr)
  {
   //--- Start the connector this many pivots behind the shoulder
   int startIndex = shoulderIndex - InpTrendPivots;
   //--- Abort when there is not enough history
   if(startIndex < 0) return;
   //--- Link each pivot up to the shoulder
   for(int i = startIndex; i < shoulderIndex; i++)
     {
      //--- Draw one connector segment
      string segName = baseName + "_trend" + IntegerToString(i);
      DrawTrendline(segName, g_pivots[i].time, g_pivots[i].price, g_pivots[i + 1].time, g_pivots[i + 1].price, clr, STYLE_DOT, 1);
     }
   //--- Anchor the label above a high or below a low
   ENUM_ANCHOR_POINT labelAnchor = g_pivots[startIndex].isHigh ? ANCHOR_LOWER : ANCHOR_UPPER;
   //--- Label the connector by trend direction
   DrawText(baseName + "_trendlbl", g_pivots[startIndex].time, g_pivots[startIndex].price, isBull ? "Downtrend" : "Uptrend", clr, labelAnchor);
   //--- Repaint the chart
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw entry, stop and target lines plus an entry arrow            |
//+------------------------------------------------------------------+
void DrawEntryLevels(bool isBull, datetime time, double entry, double stop, double takeProfit)
  {
   //--- Build the base name and the right edge of the levels
   string   id      = "QM_ENT_" + IntegerToString((int)time);
   datetime endTime = time + (datetime)(PeriodSeconds(_Period) * 30);
   //--- Draw the entry line
   DrawHLevel(id + "_e", time, endTime, entry, clrDodgerBlue, STYLE_SOLID, 2);
   //--- Draw the stop line
   DrawHLevel(id + "_sl", time, endTime, stop, C'220,60,60', STYLE_DASH, 1);
   //--- Draw the target line
   DrawHLevel(id + "_tp", time, endTime, takeProfit, C'0,200,80', STYLE_DASH, 1);
   //--- Read the just-closed bar extremes for arrow placement
   string arrowName = id + "_a";
   double barHigh   = iHigh(_Symbol, _Period, 1);
   double barLow    = iLow(_Symbol, _Period, 1);
   //--- Create the entry arrow once
   if(ObjectFind(0, arrowName) < 0)
     {
      //--- Build the direction arrow at the bar extreme
      ObjectCreate(0, arrowName, OBJ_ARROW, 0, time, isBull ? barLow : barHigh);
      ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, isBull ? 233 : 234);
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, isBull ? InpBullColor : InpBearColor);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 3);
      ObjectSetInteger(0, arrowName, OBJPROP_ANCHOR, isBull ? ANCHOR_TOP : ANCHOR_BOTTOM);
      ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, arrowName, OBJPROP_HIDDEN, true);
     }
   //--- Repaint the chart
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Cancel the armed setup but keep its drawing                      |
//+------------------------------------------------------------------+
void CancelArmedSetup(string reason)
  {
   //--- Ignore when no setup is active
   if(!g_setup.isActive) return;
   //--- Deactivate the setup
   g_setup.isActive = false;
   //--- Log the cancellation reason
   Log((g_setup.isBull ? "Bullish" : "Bearish") + " QM " + reason + ".");
  }

//+------------------------------------------------------------------+
//| Manage one open trade (partial, breakeven, trail)                |
//+------------------------------------------------------------------+
void ManageOneTrade(ulong ticket)
  {
   //--- Abort when the ticket cannot be selected
   if(!PositionSelectByTicket(ticket)) return;
   //--- Skip foreign magic numbers
   if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) return;
   //--- Skip other symbols
   if(PositionGetString(POSITION_SYMBOL) != _Symbol) return;
   //--- Read the position direction and prices
   ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   bool   isBull      = (posType == POSITION_TYPE_BUY);
   double entry       = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentStop = PositionGetDouble(POSITION_SL);
   double currentTP   = PositionGetDouble(POSITION_TP);
   double volume      = PositionGetDouble(POSITION_VOLUME);
   //--- Resolve the trade's initial risk distance
   int    recIdx       = FindTradeRecord(ticket);
   double riskDistance = (recIdx >= 0 && g_trades[recIdx].riskDistance > 0) ? g_trades[recIdx].riskDistance : MathAbs(entry - currentStop);
   //--- Abort on a zero risk distance
   if(riskDistance <= 0) return;
   //--- Read current prices and the profit in R
   double bid     = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask     = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double profitR = isBull ? (bid - entry) / riskDistance : (entry - ask) / riskDistance;
   //--- Read the ATR for ATR trailing
   double atr = IndicatorValue(AtrHandle, 0, 1);
   if(atr == EMPTY_VALUE) atr = 0.0;
   //--- Bank a partial at the first target
   if(InpUsePartialClose && recIdx >= 0 && !g_trades[recIdx].partialTaken && profitR >= InpPartialAtRR)
     {
      //--- Compute the volume to close on the partial
      double volMin   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double volStep  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double closeVol = MathFloor((volume * InpPartialPercent / 100.0) / volStep) * volStep;
      closeVol = NormalizeDouble(closeVol, 2);
      //--- Close the partial when both sides remain valid
      if(closeVol >= volMin && (volume - closeVol) >= volMin)
        {
         //--- Send the partial close and log it
         if(Trade.PositionClosePartial(ticket, closeVol))
            Log("Partial close " + DoubleToString(closeVol, 2) + " @ " + DoubleToString(profitR, 2) + "R");
        }
      //--- Mark the partial as taken
      g_trades[recIdx].partialTaken = true;
     }
   //--- Move the stop to breakeven once in profit
   if(InpUseBreakeven && profitR >= InpBreakevenAtRR)
     {
      //--- Compute the locked breakeven stop
      double lockDistance  = InpBreakevenLockPoints * SymPoint;
      double breakevenStop = NormalizeDouble(isBull ? entry + lockDistance : entry - lockDistance, SymDigits);
      //--- Only move the stop in the favorable direction
      bool improves = isBull ? (currentStop < breakevenStop) : (currentStop == 0 || currentStop > breakevenStop);
      //--- Apply the breakeven stop
      if(improves)
        {
         //--- Modify and adopt the new stop on success
         if(Trade.PositionModify(ticket, breakevenStop, currentTP)) currentStop = breakevenStop;
        }
     }
   //--- Trail the runner
   if(InpTrailingMode != TRAIL_OFF)
     {
      //--- Hold the candidate trailing stop
      double newStop = 0;
      //--- Points trail activates on locked profit, independent of breakeven
      if(InpTrailingMode == TRAIL_POINTS)
        {
         //--- Measure the open profit in points
         double profitPoints = isBull ? (bid - entry) / SymPoint : (entry - ask) / SymPoint;
         //--- Engage once profit clears the lock plus the trail distance
         if(profitPoints >= InpTrailLockPoints + InpTrailDistancePoints)
            newStop = isBull ? bid - InpTrailDistancePoints * SymPoint : ask + InpTrailDistancePoints * SymPoint;
        }
      //--- ATR trail engages after a profit-in-R threshold
      else if(InpTrailingMode == TRAIL_ATR && profitR >= InpTrailStartRR && atr > 0)
         newStop = isBull ? bid - InpTrailAtrMultiplier * atr : ask + InpTrailAtrMultiplier * atr;
      //--- Apply the trailing stop when set
      if(newStop > 0)
        {
         //--- Normalize the candidate stop
         newStop = NormalizeDouble(newStop, SymDigits);
         //--- Only move the stop in the favorable direction
         bool improves = isBull ? (newStop > currentStop) : (currentStop == 0 || newStop < currentStop);
         //--- Modify the position on improvement
         if(improves)
            Trade.PositionModify(ticket, newStop, currentTP);
        }
     }
  }

//+------------------------------------------------------------------+
//| Manage every tracked open trade                                  |
//+------------------------------------------------------------------+
void ManageOpenTrades()
  {
   //--- Manage each tracked ticket from the back
   for(int i = ArraySize(g_trades) - 1; i >= 0; i--)
      ManageOneTrade(g_trades[i].ticket);
  }

//+------------------------------------------------------------------+
//| Size, build SL/TP, validate and open the QM trade                |
//+------------------------------------------------------------------+
void OpenTrade(bool isBull, double entryLevel)
  {
   //--- Respect the one-at-a-time rule
   if(!InpAllowMultipleTrades && CountOurPositions() > 0) return;
   //--- Convert the stop buffer to price and read the ATR floor
   double stopBuffer = InpStopBufferPoints * SymPoint;
   double atr        = (InpUseAtrStopFloor ? IndicatorValue(AtrHandle, 0, 1) : 0.0);
   if(atr == EMPTY_VALUE) atr = 0.0;
   //--- Declare the order working values
   double entry, stop, takeProfit;
   ENUM_ORDER_TYPE    orderType;
   ENUM_POSITION_TYPE posType;
   //--- Build a buy order
   if(isBull)
     {
      //--- Price the buy at the ask
      entry = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymDigits);
      //--- Set the structural stop below the head
      double structStop = g_setup.headPrice - stopBuffer;
      //--- Set the ATR-floor stop below entry
      double atrStop = (atr > 0) ? entry - InpAtrStopMultiplier * atr : structStop;
      //--- Take the wider (further) of the two stops
      stop = MathMin(structStop, atrStop);
      //--- Tag the order and position types
      orderType = ORDER_TYPE_BUY;
      posType   = POSITION_TYPE_BUY;
     }
   //--- Build a sell order
   else
     {
      //--- Price the sell at the bid
      entry = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), SymDigits);
      //--- Set the structural stop above the head
      double structStop = g_setup.headPrice + stopBuffer;
      //--- Set the ATR-floor stop above entry
      double atrStop = (atr > 0) ? entry + InpAtrStopMultiplier * atr : structStop;
      //--- Take the wider (further) of the two stops
      stop = MathMax(structStop, atrStop);
      //--- Tag the order and position types
      orderType = ORDER_TYPE_SELL;
      posType   = POSITION_TYPE_SELL;
     }
   //--- Normalize the stop price
   stop = NormalizeDouble(stop, SymDigits);
   //--- Measure the risk distance
   double riskDistance = MathAbs(entry - stop);
   //--- Cancel on an invalid risk distance
   if(riskDistance <= 0) { CancelArmedSetup("invalid risk distance"); return; }
   //--- Build the take-profit from R:R
   if(InpTakeProfitMode == TP_REWARD_RISK)
      takeProfit = isBull ? entry + InpRewardRiskRatio * riskDistance : entry - InpRewardRiskRatio * riskDistance;
   //--- Otherwise use the structural target
   else
      takeProfit = g_setup.targetPrice;
   //--- Normalize the take-profit price
   takeProfit = NormalizeDouble(takeProfit, SymDigits);
   //--- Measure the reward distance
   double rewardDistance = MathAbs(takeProfit - entry);
   //--- Reject setups below the minimum reward-to-risk
   if(riskDistance > 0 && (rewardDistance / riskDistance) < InpMinRewardRisk)
     {
      //--- Cancel and report the shortfall
      CancelArmedSetup("R:R " + DoubleToString(rewardDistance / riskDistance, 2) + " below minimum " + DoubleToString(InpMinRewardRisk, 2));
      return;
     }
   //--- Size the position by the selected mode
   double lots    = (InpLotSizingMode == LOTS_FIXED) ? InpFixedLots : CalcLotsByRisk(entry, stop);
   //--- Read the broker volume constraints
   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   //--- Floor the lot to the volume step
   if(volStep > 0) lots = MathFloor(lots / volStep) * volStep;
   //--- Clamp and normalize the lot
   lots = MathMax(volMin, MathMin(volMax, lots));
   lots = NormalizeDouble(lots, 2);
   //--- Cancel on a lot calculation error
   if(lots <= 0) { CancelArmedSetup("lot calc error"); return; }
   //--- Send the market order
   if(Trade.PositionOpen(_Symbol, orderType, lots, entry, stop, takeProfit, InpOrderComment))
     {
      //--- Track the new trade
      ulong ticket = Trade.ResultOrder();
      AddTradeRecord(ticket, isBull, entry, stop);
      //--- Read the current bar time for drawing
      datetime now = iTime(_Symbol, _Period, 0);
      //--- Draw the completed retracement and entry levels
      if(InpDrawVisuals && VisualsAllowed())
        {
         //--- Connect the BOS extreme to the entry point
         color  clr         = isBull ? InpBullColor : InpBearColor;
         string retraceName = "QM_STRUCT_" + IntegerToString((int)g_setup.bosTime) + "_retr";
         DrawTrendline(retraceName, g_setup.bosTime, g_setup.targetPrice, now, entry, clr, STYLE_DOT, 1);
         //--- Draw the entry, stop and target levels
         DrawEntryLevels(isBull, now, entry, stop, takeProfit);
        }
      //--- Log the fill details
      Log((isBull ? "BUY" : "SELL") + " filled @ " + DoubleToString(entry, SymDigits) + "  SL=" + DoubleToString(stop, SymDigits) + "  TP=" + DoubleToString(takeProfit, SymDigits) + "  lots=" + DoubleToString(lots, 2) + "  (R:R " + DoubleToString(rewardDistance / riskDistance, 2) + ")");
     }
   //--- Report a failed open
   else
      Log("Open failed: " + Trade.ResultRetcodeDescription());
   //--- Consume the armed setup while leaving its drawing in place
   g_setup.isActive = false;
  }

//+------------------------------------------------------------------+
//| Arm a detected QM and draw its structure                         |
//+------------------------------------------------------------------+
void ArmSetup(bool isBull, const SwingPivot &shoulder, const SwingPivot &leg, const SwingPivot &head, const SwingPivot &bos, int shoulderIndex)
  {
   //--- Respect the one-at-a-time rule
   if(!InpAllowMultipleTrades && CountOurPositions() > 0) return;
   //--- Activate the setup and store its direction
   g_setup.isActive      = true;
   g_setup.isBull        = isBull;
   //--- Store the QM line and entry level at the shoulder
   g_setup.qmLinePrice   = shoulder.price;
   g_setup.shoulderPrice = shoulder.price;
   //--- Store the head, target and leg levels
   g_setup.headPrice     = head.price;
   g_setup.targetPrice   = bos.price;
   g_setup.legPrice      = leg.price;
   //--- Store the pivot times
   g_setup.shoulderTime  = shoulder.time;
   g_setup.legTime       = leg.time;
   g_setup.headTime      = head.time;
   g_setup.bosTime       = bos.time;
   //--- Stamp the arming bar time and reset the rejection flag
   g_setup.armedTime     = iTime(_Symbol, _Period, 0);
   g_setup.lineBroken    = false;
   //--- Remember this pattern to avoid re-arming it
   g_lastArmedBosTime      = bos.time;
   g_lastArmedShoulderTime = shoulder.time;
   //--- Draw the QM structure
   DrawQMStructure();
   //--- Draw the prior-trend connector when required
   if(InpRequirePriorTrend && InpDrawVisuals && VisualsAllowed())
      DrawPriorTrend(shoulderIndex, isBull, "QM_STRUCT_" + IntegerToString((int)bos.time), InpTrendColor);
   //--- Log the armed setup
   Log((isBull ? "BULLISH" : "BEARISH") + " QM armed | QM line=" + DoubleToString(g_setup.qmLinePrice, SymDigits) + "  Head=" + DoubleToString(g_setup.headPrice, SymDigits) + "  Target=" + DoubleToString(g_setup.targetPrice, SymDigits) + "  -> waiting for the retrace to the QM line.");
  }

//+------------------------------------------------------------------+
//| Test the last four pivots for a QM pattern                       |
//+------------------------------------------------------------------+
void CheckForQMPattern()
  {
   //--- Need at least four pivots to test
   int count = ArraySize(g_pivots);
   if(count < 4) return;
   //--- Read the last four pivots as shoulder, leg, head and BOS
   SwingPivot shoulder = g_pivots[count - 4];
   SwingPivot leg      = g_pivots[count - 3];
   SwingPivot head     = g_pivots[count - 2];
   SwingPivot bos      = g_pivots[count - 1];
   //--- Test a bearish QM: H, L, H, L
   if(shoulder.isHigh && !leg.isHigh && head.isHigh && !bos.isHigh)
     {
      //--- Require Head>Shoulder, Leg<Shoulder and BOS<Leg
      if(head.price > shoulder.price && leg.price < shoulder.price && bos.price < leg.price)
        {
         //--- Arm when fresh, allowed, not shoulder-shared and trend-confirmed
         if(bos.time != g_lastArmedBosTime && IsDirectionAllowed(false) && (!InpSkipSharedShoulder || shoulder.time != g_lastArmedShoulderTime) && IsPriorTrendConfirmed(false, count - 4))
            ArmSetup(false, shoulder, leg, head, bos, count - 4);
        }
      //--- Stop after handling the bearish shape
      return;
     }
   //--- Test a bullish QM: L, H, L, H
   if(!shoulder.isHigh && leg.isHigh && !head.isHigh && bos.isHigh)
     {
      //--- Require Head<Shoulder, Leg>Shoulder and BOS>Leg
      if(head.price < shoulder.price && leg.price > shoulder.price && bos.price > leg.price)
        {
         //--- Arm when fresh, allowed, not shoulder-shared and trend-confirmed
         if(bos.time != g_lastArmedBosTime && IsDirectionAllowed(true) && (!InpSkipSharedShoulder || shoulder.time != g_lastArmedShoulderTime) && IsPriorTrendConfirmed(true, count - 4))
            ArmSetup(true, shoulder, leg, head, bos, count - 4);
        }
     }
  }

//+------------------------------------------------------------------+
//| Confirm entry on the just-closed bar (index 1)                   |
//+------------------------------------------------------------------+
void CheckArmedSetupForEntry()
  {
   //--- Read the prior closed bar and the entry buffer
   double priorClose = iClose(_Symbol, _Period, 1);
   double buffer     = InpEntryBufferPoints * SymPoint;
   //--- Cancel when the wait window has expired
   int barsElapsed = iBarShift(_Symbol, _Period, g_setup.armedTime);
   if(barsElapsed > InpMaxWaitBars) { CancelArmedSetup("expired (no retrace in time)"); return; }
   //--- Respect the one-at-a-time rule
   if(!InpAllowMultipleTrades && CountOurPositions() > 0) return;
   //--- Handle a bullish setup
   if(g_setup.isBull)
     {
      //--- Invalidate when the close breaks below the head
      if(priorClose < g_setup.headPrice) { CancelArmedSetup("invalidated (Head broken on close)"); return; }
      //--- Enter directly on a close beyond the line
      if(!InpWaitForRejectionClose)
        {
         //--- Buy when the close is at or below the QM line
         if(priorClose <= g_setup.qmLinePrice - buffer) OpenTrade(true, g_setup.qmLinePrice);
        }
      //--- Otherwise require a rejection back through the line
      else
        {
         //--- Stage 1: mark the break once the close pierces below the line
         if(!g_setup.lineBroken)
           {
            //--- Record the downward break
            if(priorClose <= g_setup.qmLinePrice) g_setup.lineBroken = true;
           }
         //--- Stage 2: buy when a later close returns above the line
         else if(priorClose >= g_setup.qmLinePrice + buffer)
            OpenTrade(true, g_setup.qmLinePrice);
        }
     }
   //--- Handle a bearish setup
   else
     {
      //--- Invalidate when the close breaks above the head
      if(priorClose > g_setup.headPrice) { CancelArmedSetup("invalidated (Head broken on close)"); return; }
      //--- Enter directly on a close beyond the line
      if(!InpWaitForRejectionClose)
        {
         //--- Sell when the close is at or above the QM line
         if(priorClose >= g_setup.qmLinePrice + buffer) OpenTrade(false, g_setup.qmLinePrice);
        }
      //--- Otherwise require a rejection back through the line
      else
        {
         //--- Stage 1: mark the break once the close pierces above the line
         if(!g_setup.lineBroken)
           {
            //--- Record the upward break
            if(priorClose >= g_setup.qmLinePrice) g_setup.lineBroken = true;
           }
         //--- Stage 2: sell when a later close returns below the line
         else if(priorClose <= g_setup.qmLinePrice - buffer)
            OpenTrade(false, g_setup.qmLinePrice);
        }
     }
  }

//+------------------------------------------------------------------+
//| Detect a confirmed swing pivot and feed the zig-zag              |
//+------------------------------------------------------------------+
void DetectSwingPivot()
  {
   //--- Clamp the lookback to at least one bar
   int lookback = InpSwingLookback;
   if(lookback < 1) lookback = 1;
   //--- Need enough bars for a centered pivot
   if(iBars(_Symbol, _Period) < lookback * 2 + 2) return;
   //--- Read the candidate pivot bar (lookback closed bars to its right)
   int      pivotShift = lookback + 1;
   datetime pivotTime  = iTime(_Symbol, _Period, pivotShift);
   double   pivotHigh  = iHigh(_Symbol, _Period, pivotShift);
   double   pivotLow   = iLow(_Symbol, _Period, pivotShift);
   //--- Assume both a high and a low until disproven
   bool isHigh = true, isLow = true;
   //--- Compare the candidate against bars on each side
   for(int j = 1; j <= lookback; j++)
     {
      //--- Reject the high if any neighbor is higher or equal
      if(iHigh(_Symbol, _Period, pivotShift - j) >= pivotHigh || iHigh(_Symbol, _Period, pivotShift + j) >= pivotHigh) isHigh = false;
      //--- Reject the low if any neighbor is lower or equal
      if(iLow(_Symbol, _Period, pivotShift - j) <= pivotLow || iLow(_Symbol, _Period, pivotShift + j) <= pivotLow) isLow = false;
     }
   //--- Handle a confirmed swing high
   if(isHigh && pivotTime != g_lastLabeledHighTime)
     {
      //--- Choose the H / HH / LH label and color
      string label; color clr = InpSwingHighColor;
      if(g_lastLabeledHigh <= 0) label = "H";
      else if(pivotHigh > g_lastLabeledHigh) label = "HH";
      else { label = "LH"; clr = InpSwingLowColor; }
      //--- Draw the swing marker when visuals are on
      if(InpShowSwingMarkers && InpDrawVisuals && VisualsAllowed()) DrawSwingMarker(true, pivotTime, pivotHigh, label, clr);
      //--- Remember this high and push it into the zig-zag
      g_lastLabeledHigh = pivotHigh;
      g_lastLabeledHighTime = pivotTime;
      AddPivotToZigZag(true, pivotHigh, pivotTime);
      //--- Re-test the pattern with the new pivot
      CheckForQMPattern();
     }
   //--- Handle a confirmed swing low
   if(isLow && pivotTime != g_lastLabeledLowTime)
     {
      //--- Choose the L / LL / HL label and color
      string label; color clr = InpSwingLowColor;
      if(g_lastLabeledLow <= 0) label = "L";
      else if(pivotLow < g_lastLabeledLow) label = "LL";
      else { label = "HL"; clr = InpSwingHighColor; }
      //--- Draw the swing marker when visuals are on
      if(InpShowSwingMarkers && InpDrawVisuals && VisualsAllowed()) DrawSwingMarker(false, pivotTime, pivotLow, label, clr);
      //--- Remember this low and push it into the zig-zag
      g_lastLabeledLow = pivotLow;
      g_lastLabeledLowTime = pivotTime;
      AddPivotToZigZag(false, pivotLow, pivotTime);
      //--- Re-test the pattern with the new pivot
      CheckForQMPattern();
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
   //--- Configure the trade object
   Trade.SetExpertMagicNumber(InpMagicNumber);
   Trade.SetDeviationInPoints(20);
   //--- Create the ATR handle
   AtrHandle = iATR(_Symbol, _Period, InpAtrPeriod);
   //--- Fail init when the handle is invalid
   if(AtrHandle == INVALID_HANDLE)
     {
      //--- Report the failure and abort init
      Log("ERROR: failed to create the ATR handle.");
      return INIT_FAILED;
     }
   //--- Reset the pivot and trade arrays and clear the setup
   ArrayResize(g_pivots, 0);
   ArrayResize(g_trades, 0);
   g_setup.isActive = false;
   //--- Adopt any of our positions already open
   SyncTradeRecords();
   //--- Seed the last-bar time
   g_lastBarTime = iTime(_Symbol, _Period, 0);
   //--- Announce readiness
   Log("Quasimodo Pattern EA v" + EA_VERSION + " ready on " + _Symbol + " (" + EnumToString((ENUM_TIMEFRAMES)_Period) + ")  | Magic " + IntegerToString(InpMagicNumber));
   //--- Report a successful init
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- Release the ATR handle
   if(AtrHandle != INVALID_HANDLE) IndicatorRelease(AtrHandle);
   //--- Clear drawings only on a real removal or chart close
   if(reason == REASON_REMOVE || reason == REASON_CHARTCLOSE || reason == REASON_CLOSE)
      ObjectsDeleteAll(0, "QM_");
   //--- Clear any chart comment
   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Run per-bar work once on a fresh bar
   if(IsNewBar())
     {
      //--- Detect swings, test the pattern and confirm any entry
      DetectSwingPivot();
      CheckForQMPattern();
      if(g_setup.isActive) CheckArmedSetupForEntry();
     }
   //--- Maintain the trade records every tick
   PruneTradeRecords();
   SyncTradeRecords();
   //--- Manage open trades every tick
   ManageOpenTrades();
  }
//+------------------------------------------------------------------+