//+------------------------------------------------------------------+
//|                         Inducement Mitigation Block Strategy.mq5 |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"

#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+

// Define modes for how many times an OB can be traded
enum TradeMode
  {
   TradeOnce,       // Trade Once: enter only one trade per OB
   LimitedTrades,   // Limited Trades: enter up to a fixed number of trades per OB
   UnlimitedTrades  // Unlimited Trades: no restriction on trades per OB
  };

// Define the mitigation state of an FVG or OB zone
enum FVGState
  {
   Normal,   // Normal: zone has not been mitigated yet
   Mitigated // Mitigated: price has swept through the zone
  };

// Define available trailing stop strategies
enum TrailingTypeEnum
  {
   Trailing_None   = 0, // None: no trailing stop applied
   Trailing_RR     = 1, // RR-Based: trail stop by risk:reward multiples
   Trailing_Points = 2  // Points-Based: trail stop by fixed pip distance
  };

// Define whether to allow trading on already-mitigated OBs
enum TradeMitigatedOBs
  {
   DoNotTradeMitigated, // Skip Mitigated: ignore OBs that have been mitigated
   TradeMitigated       // Allow Mitigated: still trade OBs after mitigation
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== EA GENERAL SETTINGS ==="
input ENUM_TIMEFRAMES   higher_tf              = PERIOD_H4;             // Higher Timeframe for Trend
input ENUM_TIMEFRAMES   trade_tf               = PERIOD_CURRENT;        // Trading Timeframe for OB/FVG
input int               swing_strength         = 5;                     // Swing Point Strength in Bars
input double            risk_percent           = 0.1;                   // Risk Percentage per Trade (0.1%)
input int               sl_offset_pts          = 10;                    // SL Offset Points
input double            rr_ratio               = 4.0;                   // Risk:Reward Ratio
input int               minPts                 = 10;                   // Minimum Gap Size in Points
input int               FVG_Rec_Ext_Bars       = 10;                    // FVG Extension Bars
input int               OB_Rec_Ext_Bars        = 300;                    // OB Extension Bars
input int               inducement_ext_bars    = 10;                    // Inducement Trendline Extension Bars
input int               minIndDepthPts         = 20;                    // Minimum Inducement Depth in Points
input bool              prt                    = true;                  // Print Statements
input long              magic_number           = 123456789;             // Magic Number
input bool              ignoreOverlaps         = true;                  // Ignore new zones that overlap existing ones
input TradeMode         tradeMode              = TradeOnce;             // Mode for trading OBs
input int               maxTradesPerOB         = 2;                     // Maximum trades per OB for LimitedTrades
input int               maxZones               = 50;                    // Maximum OBs to track in array
input TrailingTypeEnum  TrailingType           = Trailing_RR;         // Trailing Stop Type
input double            Trailing_Stop_Pips     = 30.0;                  // Trailing Stop in Pips (for Points type)
input double            Min_Profit_To_Trail_Pips = 50.0;               // Min Profit to Start Trailing in Pips
input color             def_clr_up             = clrBlue;               // Swing High Color
input color             def_clr_down           = clrRed;                // Swing Low Color
input int               object_code            = 77;                    // Object Code for Swing Points
input int               width                  = 2;                     // Line Width
input TradeMitigatedOBs tradeMitigated         = TradeMitigated;   // Trade Mitigated OBs
input int               OBRangeCandles         = 7;                     // Number of Candles for Consolidation Range
input double            OBMaxDeviation         = 50.0;                  // Max Deviation in Points for Equal Highs/Lows
input int               OBWaitBars             = 3;                     // Wait Bars for Impulse Confirmation
input double            OBImpulseThreshold     = 1.0;                   // Impulse Threshold as Multiplier of Range
input bool              VisualizeLevels        = true;                  // Visualize SL/TP Levels on Chart

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+

// Store price and bar index together for range analysis
struct PriceIndex
  {
   double price; // Store the price level
   int    index; // Store the bar index
  };

// Store trade ticket, initial risk, and trailing level for RR trailing
struct TradeInfo
  {
   ulong  ticket;      // Store open position ticket
   double orig_risk;   // Store initial risk distance in price
   int    trail_level; // Store current RR trailing level reached
  };

// Store all metadata and state for a single Order Block zone
struct OBZone
  {
   string    name;        // Store the chart object name of the OB rectangle
   datetime  startTime;   // Store the time of the OB candle
   datetime  origEndTime; // Store the calculated expiry time of the OB
   datetime  mitTime;     // Store the time mitigation occurred (0 if not mitigated)
   datetime  fvgTime;     // Store the time of the associated FVG candle
   bool      signal;      // Store whether a trade signal has ever occurred
   bool      mit;         // Store whether the OB has been mitigated
   bool      origUp;      // Store whether the OB is bullish (true) or bearish (false)
   int       tradeCount;  // Store how many times this OB has been traded
   FVGState  state;       // Store the current mitigation state enum value
   bool      newSignal;   // Store whether a fresh signal occurred on this bar
   bool      valid;       // Store whether BOS and inducement have been confirmed
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade   obj_Trade;                      // Trade execution object
long     chart_id          = -1;         // Higher timeframe chart ID (-1 means not open)
int      current_trend     = 0;          // Current trend direction: 1=up, -1=down, 0=none
int      current_font_size = 10;         // Dynamic font size updated by chart scale
string   fvg_names[];                    // Store names of all FVG rectangle objects
OBZone   obs[];                          // Store all tracked Order Block zones
TradeInfo trades[];                      // Store RR trailing data for open positions

//--- Define chart object name prefixes
#define FVG_Prefix    "FVG REC "  // Prefix for FVG rectangle objects
#define OB_Prefix     "OB REC "   // Prefix for OB rectangle objects
#define BOS_Prefix    "BOS_"      // Prefix for BOS line objects
#define IND_Prefix    "IND_"      // Prefix for inducement trendline objects

//--- Define zone colors per direction and state
#define CLR_UP        clrGreen   // Active bullish zone color
#define CLR_DOWN      clrRed     // Active bearish zone color
#define CLR_MIT_UP    clrPurple  // Mitigated bullish zone color
#define CLR_MIT_DOWN  clrOrange  // Mitigated bearish zone color

//+------------------------------------------------------------------+
//| Get color based on state and direction                           |
//+------------------------------------------------------------------+
color GetZoneColor(bool isUp, FVGState currentState)
  {
   //--- Return bullish or bearish active color for normal state
   if (currentState == Normal)    return isUp ? CLR_UP   : CLR_DOWN;
   //--- Return bullish or bearish mitigated color for mitigated state
   if (currentState == Mitigated) return isUp ? CLR_MIT_UP : CLR_MIT_DOWN;
   //--- Return no color as fallback
   return clrNONE;
  }

//+------------------------------------------------------------------+
//| Print OBs for debugging                                          |
//+------------------------------------------------------------------+
void PrintOBs()
  {
   //--- Skip if printing is disabled
   if (!prt) return;
   //--- Print total count of tracked OBs
   Print("Current OBs count: ", ArraySize(obs));
   //--- Iterate and print each OB's key properties
   for (int i = 0; i < ArraySize(obs); i++)
     {
      Print("OB ", i, ": ", obs[i].name,
            " state=",      EnumToString(obs[i].state),
            " mit=",        obs[i].mit,
            " tradeCount=", obs[i].tradeCount,
            " newSignal=",  obs[i].newSignal,
            " valid=",      obs[i].valid,
            " endTime=",    TimeToString(obs[i].origEndTime));
     }
  }

//+------------------------------------------------------------------+
//| Draw trend label on main chart                                   |
//+------------------------------------------------------------------+
void DrawTrendLabel()
  {
   //--- Define the label object name
   string trendObj  = "EA_TrendLabel";
   //--- Build the trend text based on current direction
   string trendText = (current_trend ==  1) ? "UPTREND"   :
                      (current_trend == -1) ? "DOWNTREND" : "NO TREND";
   //--- Choose display color matching the trend direction
   color  trendClr  = (current_trend ==  1) ? clrLimeGreen :
                      (current_trend == -1) ? clrRed       : clrGray;
   //--- Create the label if it does not already exist
   if (ObjectFind(0, trendObj) < 0)
      ObjectCreate(0, trendObj, OBJ_LABEL, 0, 0, 0);
   //--- Position the label in the upper-left corner of the chart
   ObjectSetInteger(0, trendObj, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, trendObj, OBJPROP_XDISTANCE, 12);
   ObjectSetInteger(0, trendObj, OBJPROP_YDISTANCE, 30);
   //--- Set label text, color, font, and size
   ObjectSetString (0, trendObj, OBJPROP_TEXT,      "H4 Trend: " + trendText);
   ObjectSetInteger(0, trendObj, OBJPROP_COLOR,     trendClr);
   ObjectSetInteger(0, trendObj, OBJPROP_FONTSIZE,  14);
   ObjectSetString (0, trendObj, OBJPROP_FONT,      "Arial Bold");
   //--- Refresh the chart to display the updated label
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Update font sizes based on chart scale                           |
//+------------------------------------------------------------------+
void UpdateFontSizes()
  {
   long scale = 0;
   //--- Read the current chart zoom scale level
   if (ChartGetInteger(0, CHART_SCALE, 0, scale))
     {
      //--- Compute new font size proportional to scale
      current_font_size = (int)(7 + scale * 0.7);
      //--- Clamp font size to a minimum of 6
      if (current_font_size < 6)  current_font_size = 6;
      //--- Clamp font size to a maximum of 15
      if (current_font_size > 15) current_font_size = 15;
      //--- Iterate all chart objects and update text font sizes
      for (int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
        {
         string name = ObjectName(0, i, -1, -1);
         //--- Apply new font size only to text objects
         if (ObjectGetInteger(0, name, OBJPROP_TYPE) == OBJ_TEXT)
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, current_font_size);
        }
      //--- Refresh the chart after updating all text objects
      ChartRedraw(0);
     }
  }

//+------------------------------------------------------------------+
//| Create label for a zone rectangle                                |
//+------------------------------------------------------------------+
void CreateLabel(string zoneName, datetime time, double price)
  {
   //--- Build the label object name from the zone name
   string lblName = zoneName + "_Label";
   //--- Create a text object at the midpoint of the zone
   ObjectCreate(0, lblName, OBJ_TEXT, 0, time, price);
   //--- Center the anchor point of the label
   ObjectSetInteger(0, lblName, OBJPROP_ANCHOR,   ANCHOR_CENTER);
   //--- Set label color to black for readability on zone fill
   ObjectSetInteger(0, lblName, OBJPROP_COLOR,    clrBlack);
   //--- Apply the current dynamic font size
   ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, current_font_size);
   //--- Populate the label text based on zone state
   UpdateLabelText(lblName, zoneName);
  }

//+------------------------------------------------------------------+
//| Update label position                                            |
//+------------------------------------------------------------------+
void UpdateLabel(string zoneName, datetime time, double price)
  {
   //--- Build the label object name
   string lblName = zoneName + "_Label";
   //--- Update only if the label object already exists
   if (ObjectFind(0, lblName) >= 0)
     {
      //--- Move the label to the new time position
      ObjectSetInteger(0, lblName, OBJPROP_TIME,    0, time);
      //--- Move the label to the new price position
      ObjectSetDouble (0, lblName, OBJPROP_PRICE,   0, price);
      //--- Sync the font size with the current dynamic value
      ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, current_font_size);
      //--- Refresh the label text to reflect any state changes
      UpdateLabelText(lblName, zoneName);
     }
  }

//+------------------------------------------------------------------+
//| Update label text based on zone state                            |
//+------------------------------------------------------------------+
void UpdateLabelText(string lblName, string zoneName)
  {
   //--- Initialise text and tracking variables
   string   text     = "";
   int      tradeCnt = 0;
   FVGState state    = Normal;
   bool     origUp   = false;
   //--- Search OB array for a matching zone and extract its properties
   for (int idx = 0; idx < ArraySize(obs); idx++)
     {
      if (obs[idx].name == zoneName)
        {
         tradeCnt = obs[idx].tradeCount;
         state    = obs[idx].state;
         origUp   = obs[idx].origUp;
         break;
        }
     }
   //--- Build FVG label text from zone color when it is an FVG object
   if (StringFind(zoneName, FVG_Prefix) >= 0)
     {
      color zoneClr   = (color)ObjectGetInteger(0, zoneName, OBJPROP_COLOR);
      bool  isBullish = (zoneClr == CLR_UP);
      text = isBullish ? "Bullish FVG" : "Bearish FVG";
     }
   else
     {
      //--- Assign OB direction label based on state
      if      (state == Normal)    text = origUp ? "Bullish OB" : "Bearish OB";
      else if (state == Mitigated) text = origUp ? "Mitigated Bullish OB" : "Mitigated Bearish OB";
      //--- Append trade count if at least one trade has been taken
      if (tradeCnt > 0) text += " (Traded " + IntegerToString(tradeCnt) + " times)";
     }
   //--- Write the constructed text to the chart label object
   ObjectSetString(0, lblName, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//| Create Rectangle zone on chart                                   |
//+------------------------------------------------------------------+
void CreateRec(string objName, datetime time1, double price1, datetime time2, double price2, color clr)
  {
   //--- Sync font size before drawing
   UpdateFontSizes();
   //--- Create the rectangle object spanning time and price boundaries
   ObjectCreate(0, objName, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
   //--- Determine if this object is an FVG by checking its name prefix
   bool isFVG = StringFind(objName, FVG_Prefix) >= 0;
   //--- FVGs are unfilled outlines; OBs are solid filled rectangles
   ObjectSetInteger(0, objName, OBJPROP_FILL,  isFVG ? false : true);
   //--- FVGs use a thicker border; OBs use a thinner border
   ObjectSetInteger(0, objName, OBJPROP_WIDTH,  isFVG ? 2 : 1);
   //--- Apply the provided zone color
   ObjectSetInteger(0, objName, OBJPROP_COLOR,  clr);
   //--- Keep the rectangle in the foreground layer
   ObjectSetInteger(0, objName, OBJPROP_BACK,   false);
   //--- Compute midpoint time and price for label placement
   datetime midTime  = time1 + (time2 - time1) / 2;
   double   midPrice = (price1 + price2) / 2;
   //--- Create the descriptive text label at the zone midpoint
   CreateLabel(objName, midTime, midPrice);
   //--- Refresh the chart to render the new rectangle and label
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Update Rectangle zone on chart                                   |
//+------------------------------------------------------------------+
void UpdateRec(string objName, datetime time1, double price1, datetime time2, double price2, color clr)
  {
   //--- Sync font size before updating
   UpdateFontSizes();
   //--- Update only if the rectangle object already exists on the chart
   if (ObjectFind(0, objName) >= 0)
     {
      //--- Update the start time anchor of the rectangle
      ObjectSetInteger(0, objName, OBJPROP_TIME,  0, time1);
      //--- Update the start price anchor of the rectangle
      ObjectSetDouble (0, objName, OBJPROP_PRICE, 0, price1);
      //--- Update the end time anchor of the rectangle
      ObjectSetInteger(0, objName, OBJPROP_TIME,  1, time2);
      //--- Update the end price anchor of the rectangle
      ObjectSetDouble (0, objName, OBJPROP_PRICE, 1, price2);
      //--- Apply the updated zone color (e.g., after mitigation)
      ObjectSetInteger(0, objName, OBJPROP_COLOR,    clr);
      //--- Recompute midpoint for label repositioning
      datetime midTime  = time1 + (time2 - time1) / 2;
      double   midPrice = (price1 + price2) / 2;
      //--- Move the label to the updated midpoint
      UpdateLabel(objName, midTime, midPrice);
      //--- Refresh the chart to show the updated rectangle
      ChartRedraw(0);
     }
  }

//+------------------------------------------------------------------+
//| Draw swing point arrow and BoS text on target chart              |
//+------------------------------------------------------------------+
void drawSwingPoint(string objName, datetime time, double price, int arrCode, color clr, int direction, long cid = 0)
  {
   //--- Skip creation if the arrow object already exists on the target chart
   if (ObjectFind(cid, objName) >= 0) return;
   //--- Create the arrow object at the swing price and time
   ObjectCreate(cid, objName, OBJ_ARROW, 0, time, price);
   //--- Set the arrow glyph code
   ObjectSetInteger(cid, objName, OBJPROP_ARROWCODE, arrCode);
   //--- Apply the directional color to the arrow
   ObjectSetInteger(cid, objName, OBJPROP_COLOR,     clr);
   //--- Set the font size for the arrow (shared with text objects)
   ObjectSetInteger(cid, objName, OBJPROP_FONTSIZE,  current_font_size);
   //--- Anchor arrow above the bar for upward-pointing swings
   if (direction > 0) ObjectSetInteger(cid, objName, OBJPROP_ANCHOR, ANCHOR_TOP);
   //--- Anchor arrow below the bar for downward-pointing swings
   if (direction < 0) ObjectSetInteger(cid, objName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   //--- Build the companion BoS label object name
   string txt          = " BoS";
   string objNameDescr = objName + txt;
   //--- Create the descriptive text label at the same time and price
   ObjectCreate(cid, objNameDescr, OBJ_TEXT, 0, time, price);
   //--- Apply color and font size to the text label
   ObjectSetInteger(cid, objNameDescr, OBJPROP_COLOR,    clr);
   ObjectSetInteger(cid, objNameDescr, OBJPROP_FONTSIZE, current_font_size);
   //--- Position text above the bar for upward swings
   if (direction > 0)
     {
      ObjectSetInteger(cid, objNameDescr, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString (cid, objNameDescr, OBJPROP_TEXT,   " " + txt);
     }
   //--- Position text below the bar for downward swings
   if (direction < 0)
     {
      ObjectSetInteger(cid, objNameDescr, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetString (cid, objNameDescr, OBJPROP_TEXT,   " " + txt);
     }
   //--- Refresh the main chart only when drawing on it
   if (cid == 0) ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw break level arrowed line on main chart                      |
//+------------------------------------------------------------------+
void drawBreakLevel(string objName, datetime time1, double price1, datetime time2, double price2, color clr, int direction)
  {
   //--- Skip if the break level line already exists
   if (ObjectFind(0, objName) >= 0) return;
   //--- Create a horizontal arrowed line from swing time to break time
   ObjectCreate(0, objName, OBJ_ARROWED_LINE, 0, time1, price1, time2, price2);
   //--- Explicitly set both anchor time and price points
   ObjectSetInteger(0, objName, OBJPROP_TIME,  0, time1);
   ObjectSetDouble (0, objName, OBJPROP_PRICE, 0, price1);
   ObjectSetInteger(0, objName, OBJPROP_TIME,  1, time2);
   ObjectSetDouble (0, objName, OBJPROP_PRICE, 1, price2);
   //--- Apply color and width to the line
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, width);
   //--- Build the companion "Break" text label name
   string txt          = " Break ";
   string objNameDescr = objName + txt;
   //--- Create the text label at the end point of the break line
   ObjectCreate(0, objNameDescr, OBJ_TEXT, 0, time2, price2);
   //--- Apply color and font size to the break label
   ObjectSetInteger(0, objNameDescr, OBJPROP_COLOR,    clr);
   ObjectSetInteger(0, objNameDescr, OBJPROP_FONTSIZE, current_font_size);
   //--- Anchor above for downward-facing breaks
   if (direction > 0)
     {
      ObjectSetInteger(0, objNameDescr, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetString (0, objNameDescr, OBJPROP_TEXT,   " " + txt);
     }
   //--- Anchor below for upward-facing breaks
   if (direction < 0)
     {
      ObjectSetInteger(0, objNameDescr, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
      ObjectSetString (0, objNameDescr, OBJPROP_TEXT,   " " + txt);
     }
   //--- Refresh the chart to show the new break level
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw dotted horizontal trend line for entry/SL/TP visualization |
//+------------------------------------------------------------------+
void DrawDottedLine(string name, datetime t1, double p, datetime t2, color lineColor)
  {
   //--- Skip if the line already exists on the chart
   if (ObjectFind(0, name) >= 0) return;
   //--- Create a horizontal trend line between the two time points
   ObjectCreate(0, name, OBJ_TREND, 0, t1, p, t2, p);
   //--- Apply the specified color to the line
   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   //--- Use a dotted style to distinguish it from structural lines
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   //--- Set line width to 1 pixel
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   //--- Refresh the chart to display the new dotted line
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw anchored text label for trade level annotation              |
//+------------------------------------------------------------------+
void DrawTextEx(string name, string text, datetime t, double p, color cl, bool isHigh)
  {
   //--- Skip if the text object already exists
   if (ObjectFind(0, name) >= 0) return;
   //--- Create a text object at the specified time and price
   ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   //--- Set the display text content
   ObjectSetString (0, name, OBJPROP_TEXT,     text);
   //--- Apply the specified color
   ObjectSetInteger(0, name, OBJPROP_COLOR,    cl);
   //--- Apply the current dynamic font size
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, current_font_size);
   //--- Use bold Arial for clear readability
   ObjectSetString (0, name, OBJPROP_FONT,     "Arial Bold");
   //--- Anchor below the price for swing highs, above for swing lows
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,   isHigh ? ANCHOR_BOTTOM : ANCHOR_TOP);
   //--- Center the text horizontally around the anchor time
   ObjectSetInteger(0, name, OBJPROP_ALIGN,    ALIGN_CENTER);
   //--- Refresh the chart to render the new label
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Draw mitigation icon arrow on the OB zone                        |
//+------------------------------------------------------------------+
void DrawMitIcon(string zoneNAME, datetime mitTime, double zoneHigh, double zoneLow, bool isUp)
  {
   //--- Build the mitigation icon object name
   string iconName  = zoneNAME + "_MitIcon";
   //--- Place the icon at the near edge of the zone relative to direction
   double iconPrice = isUp ? zoneLow : zoneHigh;
   //--- Create the arrow icon at the mitigation time and price
   ObjectCreate(0, iconName, OBJ_ARROW, 0, mitTime, iconPrice);
   //--- Use arrow code 251 as the mitigation marker glyph
   ObjectSetInteger(0, iconName, OBJPROP_ARROWCODE, 251);
   //--- Apply blue color for mitigation icons
   ObjectSetInteger(0, iconName, OBJPROP_COLOR,     clrBlue);
   //--- Anchor above the price for bullish zones, below for bearish
   ObjectSetInteger(0, iconName, OBJPROP_ANCHOR,    isUp ? ANCHOR_TOP : ANCHOR_BOTTOM);
   //--- Refresh the chart to display the icon
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Check if bar at index is a valid swing high                      |
//+------------------------------------------------------------------+
bool isSwingHigh(int curr_bar, ENUM_TIMEFRAMES tf, int length)
  {
   //--- Reject if not enough bars exist on either side
   if (curr_bar < length || curr_bar + length >= iBars(_Symbol, tf)) return false;
   //--- Verify the candidate bar is strictly the highest in the window
   for (int j = 1; j <= length; j++)
     {
      //--- Fail if a newer bar within length is higher or equal
      if (iHigh(_Symbol, tf, curr_bar) <= iHigh(_Symbol, tf, curr_bar - j)) return false;
      //--- Fail if an older bar within length is higher
      if (iHigh(_Symbol, tf, curr_bar) <  iHigh(_Symbol, tf, curr_bar + j)) return false;
     }
   //--- Confirm this bar qualifies as a swing high
   return true;
  }

//+------------------------------------------------------------------+
//| Check if bar at index is a valid swing low                       |
//+------------------------------------------------------------------+
bool isSwingLow(int curr_bar, ENUM_TIMEFRAMES tf, int length)
  {
   //--- Reject if not enough bars exist on either side
   if (curr_bar < length || curr_bar + length >= iBars(_Symbol, tf)) return false;
   //--- Verify the candidate bar is strictly the lowest in the window
   for (int j = 1; j <= length; j++)
     {
      //--- Fail if a newer bar within length is lower or equal
      if (iLow(_Symbol, tf, curr_bar) >= iLow(_Symbol, tf, curr_bar - j)) return false;
      //--- Fail if an older bar within length is lower
      if (iLow(_Symbol, tf, curr_bar) >  iLow(_Symbol, tf, curr_bar + j)) return false;
     }
   //--- Confirm this bar qualifies as a swing low
   return true;
  }

//+------------------------------------------------------------------+
//| Check consolidation by equal highs and lows across range         |
//+------------------------------------------------------------------+
bool IsConsolidationEqualHighsAndLows(int rangeCandles, double maxDeviation, int startingIndex, ENUM_TIMEFRAMES tf)
  {
   //--- Compare adjacent bar highs and lows across the full consolidation range
   for (int i = startingIndex; i < startingIndex + rangeCandles - 1; i++)
     {
      //--- Reject if adjacent highs differ by more than the allowed deviation
      if (MathAbs(iHigh(_Symbol, tf, i) - iHigh(_Symbol, tf, i + 1)) > maxDeviation * _Point) return false;
      //--- Reject if adjacent lows differ by more than the allowed deviation
      if (MathAbs(iLow (_Symbol, tf, i) - iLow (_Symbol, tf, i + 1)) > maxDeviation * _Point) return false;
     }
   //--- Confirm range qualifies as a consolidation zone
   return true;
  }

//+------------------------------------------------------------------+
//| Get highest high price and bar index within range                |
//+------------------------------------------------------------------+
void GetHighestHigh(int rangeCandles, int startingIndex, PriceIndex &highestHighRef, ENUM_TIMEFRAMES tf)
  {
   //--- Seed with the first bar in the range
   highestHighRef.price = iHigh(_Symbol, tf, startingIndex);
   highestHighRef.index = startingIndex;
   //--- Scan remaining bars and update if a higher high is found
   for (int i = startingIndex + 1; i < startingIndex + rangeCandles; i++)
     {
      if (iHigh(_Symbol, tf, i) > highestHighRef.price)
        {
         //--- Update the reference with the new highest high
         highestHighRef.price = iHigh(_Symbol, tf, i);
         highestHighRef.index = i;
        }
     }
  }

//+------------------------------------------------------------------+
//| Get lowest low price and bar index within range                  |
//+------------------------------------------------------------------+
void GetLowestLow(int rangeCandles, int startingIndex, PriceIndex &lowestLowRef, ENUM_TIMEFRAMES tf)
  {
   //--- Seed with the first bar in the range
   lowestLowRef.price = iLow(_Symbol, tf, startingIndex);
   lowestLowRef.index = startingIndex;
   //--- Scan remaining bars and update if a lower low is found
   for (int i = startingIndex + 1; i < startingIndex + rangeCandles; i++)
     {
      if (iLow(_Symbol, tf, i) < lowestLowRef.price)
        {
         //--- Update the reference with the new lowest low
         lowestLowRef.price = iLow(_Symbol, tf, i);
         lowestLowRef.index = i;
        }
     }
  }

//+------------------------------------------------------------------+
//| Detect and create OB zone with FVG in impulsive area             |
//+------------------------------------------------------------------+
void DetectAndCreateZone(int i, ENUM_TIMEFRAMES tf)
  {
   //--- Skip detection if no trend has been established
   if (current_trend == 0) return;
   //--- Set the consolidation range to start one bar after the signal bar
   int consol_start_index = i + 1;
   //--- Ensure enough bars exist for the full consolidation range
   if (consol_start_index + OBRangeCandles - 1 >= iBars(_Symbol, tf)) return;
   //--- Validate the consolidation range with equal highs and lows check
   if (IsConsolidationEqualHighsAndLows(OBRangeCandles, OBMaxDeviation, consol_start_index, tf))
     {
      //--- Find the highest high and lowest low within the consolidation
      PriceIndex hh, ll;
      GetHighestHigh(OBRangeCandles, consol_start_index, hh, tf);
      GetLowestLow  (OBRangeCandles, consol_start_index, ll, tf);
      double breakout_close = iClose(_Symbol, tf, i);
      //--- Determine if price broke out bullishly above the consolidation high
      bool   breakout_up    = (current_trend ==  1) && breakout_close > hh.price;
      //--- Determine if price broke out bearishly below the consolidation low
      bool   breakout_down  = (current_trend == -1) && breakout_close < ll.price;
      //--- Proceed only if a valid directional breakout occurred
      if (breakout_up || breakout_down)
        {
         //--- Calculate the consolidation range height
         double range_val  = hh.price - ll.price;
         //--- Apply the impulse multiplier threshold to the range
         double threshold  = range_val * OBImpulseThreshold;
         bool   impulsive  = false;
         int    impulse_start_bar = -1;
         //--- Search the next few bars for an impulsive extension past the threshold
         for (int k = 1; k <= OBWaitBars; k++)
           {
            int    impulse_shift = i - k;
            if (impulse_shift < 0) break;
            double c = iClose(_Symbol, tf, impulse_shift);
            //--- Confirm bullish impulse if close exceeds high plus threshold
            if (breakout_up   && c >= hh.price + threshold)
              {
               impulsive        = true;
               impulse_start_bar = impulse_shift;
               break;
              }
            //--- Confirm bearish impulse if close falls below low minus threshold
            else if (breakout_down && c <= ll.price - threshold)
              {
               impulsive        = true;
               impulse_start_bar = impulse_shift;
               break;
              }
           }
         //--- Continue only if an impulsive move was confirmed
         if (impulsive)
           {
            //--- Set FVG direction flags based on breakout direction
            bool     FVG_UP    = breakout_up;
            bool     FVG_DOWN  = breakout_down;
            bool     fvg_found = false;
            datetime fvg_time  = 0;
            double   fvg_price1 = 0, fvg_price2 = 0;
            //--- Scan from breakout bar to impulse bar looking for a valid FVG gap
            for (int f = i; f >= impulse_start_bar; f--)
              {
               double low0  = iLow (_Symbol, tf, f);
               double high2 = iHigh(_Symbol, tf, f + 2);
               //--- Compute the gap between bar[f] low and bar[f+2] high (bullish gap)
               double gap_L0_H2 = NormalizeDouble((low0 - high2) / _Point, _Digits);
               double high0 = iHigh(_Symbol, tf, f);
               double low2  = iLow (_Symbol, tf, f + 2);
               //--- Compute the gap between bar[f+2] low and bar[f] high (bearish gap)
               double gap_H0_L2 = NormalizeDouble((low2 - high0) / _Point, _Digits);
               //--- Validate and record a bullish FVG if gap exceeds minimum points
               if (FVG_UP && low0 > high2 && gap_L0_H2 > minPts)
                 {
                  fvg_time   = iTime(_Symbol, tf, f + 1);
                  fvg_price1 = high2;
                  fvg_price2 = low0;
                  fvg_found  = true;
                  break;
                 }
               //--- Validate and record a bearish FVG if gap exceeds minimum points
               else if (FVG_DOWN && low2 > high0 && gap_H0_L2 > minPts)
                 {
                  fvg_time   = iTime(_Symbol, tf, f + 1);
                  fvg_price1 = high0;
                  fvg_price2 = low2;
                  fvg_found  = true;
                  break;
                 }
              }
            //--- Proceed only if an FVG was successfully found
            if (fvg_found)
              {
               //--- Normalise FVG boundaries to low/high order
               double newLow  = MathMin(fvg_price1, fvg_price2);
               double newHigh = MathMax(fvg_price1, fvg_price2);
               bool   fvg_overlaps = false;
               //--- Check new FVG against all existing FVGs for overlap
               if (ignoreOverlaps)
                 {
                  for (int ex = 0; ex < ArraySize(fvg_names); ex++)
                    {
                     double exLow  = ObjectGetDouble(0, fvg_names[ex], OBJPROP_PRICE, 0);
                     double exHigh = ObjectGetDouble(0, fvg_names[ex], OBJPROP_PRICE, 1);
                     //--- Sort existing zone bounds
                     exLow  = MathMin(exLow, exHigh);
                     exHigh = MathMax(exLow, exHigh);
                     //--- Check if the new FVG overlaps with the existing one
                     if (MathMax(newLow, exLow) < MathMin(newHigh, exHigh))
                       {
                        fvg_overlaps = true;
                        if (prt) Print("Historical: Skipping overlapping FVG at ", TimeToString(fvg_time));
                        break;
                       }
                    }
                 }
               //--- Abort if this FVG overlaps an existing one
               if (fvg_overlaps) return;
               //--- Use the first consolidation candle as the OB candle reference
               int      last_consol_index = consol_start_index;
               datetime obTime  = iTime (_Symbol, tf, last_consol_index);
               double   obLow   = iLow  (_Symbol, tf, last_consol_index);
               double   obHigh  = iHigh (_Symbol, tf, last_consol_index);
               bool     is_opposing = false;
               //--- Check that OB candle is bearish (opposing) for a bullish breakout
               if (breakout_up   && iOpen(_Symbol, tf, last_consol_index) > iClose(_Symbol, tf, last_consol_index))
                  is_opposing = true;
               //--- Check that OB candle is bullish (opposing) for a bearish breakout
               if (breakout_down && iOpen(_Symbol, tf, last_consol_index) < iClose(_Symbol, tf, last_consol_index))
                  is_opposing = true;
               //--- Reject if the consolidation candle is not opposing
               if (!is_opposing)
                 {
                  if (prt) Print("Skipping OB creation: Last consolidation candle not opposing at ", TimeToString(obTime));
                  return;
                 }
               //--- Normalise OB boundaries to low/high order
               double obNewLow  = MathMin(obLow, obHigh);
               double obNewHigh = MathMax(obLow, obHigh);
               bool   ob_overlaps = false;
               //--- Check new OB against all existing OBs for overlap
               if (ignoreOverlaps)
                 {
                  for (int ex = 0; ex < ArraySize(obs); ex++)
                    {
                     double exLow  = ObjectGetDouble(0, obs[ex].name, OBJPROP_PRICE, 0);
                     double exHigh = ObjectGetDouble(0, obs[ex].name, OBJPROP_PRICE, 1);
                     //--- Sort existing OB bounds
                     exLow  = MathMin(exLow, exHigh);
                     exHigh = MathMax(exLow, exHigh);
                     //--- Check if the new OB overlaps with the existing one
                     if (MathMax(obNewLow, exLow) < MathMin(obNewHigh, exHigh))
                       {
                        ob_overlaps = true;
                        if (prt) Print("Historical: Skipping overlapping OB at ", TimeToString(obTime));
                        break;
                       }
                    }
                 }
               //--- Abort if this OB overlaps an existing one
               if (ob_overlaps) return;
               //--- Build the FVG object name from its timestamp
               string   fvgNAME    = FVG_Prefix + "(" + TimeToString(fvg_time) + ")";
               color    fvgClr     = FVG_UP ? CLR_UP : CLR_DOWN;
               //--- Calculate the FVG rectangle end time based on extension bars
               datetime fvgEndTime = fvg_time + PeriodSeconds(tf) * FVG_Rec_Ext_Bars;
               //--- Draw the FVG rectangle on the chart
               CreateRec(fvgNAME, fvg_time, fvg_price1, fvgEndTime, fvg_price2, fvgClr);
               //--- Register the FVG name in the tracking array
               int fvg_size = ArraySize(fvg_names);
               ArrayResize(fvg_names, fvg_size + 1);
               fvg_names[fvg_size] = fvgNAME;
               if (prt) Print("Historical FVG created: ", fvgNAME);
               //--- Build the OB object name from its timestamp
               string   obNAME   = OB_Prefix + "(" + TimeToString(obTime) + ")";
               color    obClr    = FVG_UP ? CLR_UP : CLR_DOWN;
               //--- Calculate the OB rectangle end time based on extension bars
               datetime obEndTime = obTime + PeriodSeconds(tf) * OB_Rec_Ext_Bars;
               //--- Draw the OB rectangle on the chart
               CreateRec(obNAME, obTime, obLow, obEndTime, obHigh, obClr);
               //--- Evict the oldest OB if the storage array is at capacity
               int ob_size = ArraySize(obs);
               if (ob_size >= maxZones)
                 {
                  if (prt) Print("Historical: Max OBs reached, removing oldest.");
                  ArrayRemove(obs, 0, 1);
                  PrintOBs();
                 }
               //--- Append the new OB entry to the storage array
               ArrayResize(obs, ob_size + 1);
               obs[ob_size].name        = obNAME;
               obs[ob_size].startTime   = obTime;
               obs[ob_size].origEndTime = obEndTime;
               obs[ob_size].mitTime     = 0;
               obs[ob_size].fvgTime     = fvg_time;
               obs[ob_size].signal      = false;
               obs[ob_size].mit         = false;
               obs[ob_size].origUp      = FVG_UP;
               obs[ob_size].tradeCount  = 0;
               obs[ob_size].state       = Normal;
               obs[ob_size].newSignal   = false;
               obs[ob_size].valid       = false;
               if (prt) Print("Historical OB created: ", obNAME, " origUp=", FVG_UP, " endTime=", TimeToString(obEndTime));
               PrintOBs();
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Process historical mitigation and signal state for one OB        |
//+------------------------------------------------------------------+
void ProcessHistoricalState(int idx, ENUM_TIMEFRAMES tf)
  {
   //--- Retrieve the OB's stored name and time references
   string   obNAME    = obs[idx].name;
   datetime timeSTART = obs[idx].startTime;
   datetime endTime   = obs[idx].origEndTime;
   //--- Retrieve and normalise OB price boundaries from the chart object
   double   obLow  = MathMin(ObjectGetDouble(0, obNAME, OBJPROP_PRICE, 0), ObjectGetDouble(0, obNAME, OBJPROP_PRICE, 1));
   double   obHigh = MathMax(ObjectGetDouble(0, obNAME, OBJPROP_PRICE, 0), ObjectGetDouble(0, obNAME, OBJPROP_PRICE, 1));
   //--- Convert OB start time to a bar index on the trading timeframe
   int      obBar  = iBarShift(_Symbol, tf, timeSTART);
   if (obBar < 0) return;
   //--- Initialise mitigation and signal state flags
   bool     isMit  = false, isSig = false;
   datetime mitTime = 0;
   //--- Iterate bars from just before the OB candle toward the present
   for (int k = obBar - 1; k >= 0; k--)
     {
      double barLow   = iLow  (_Symbol, tf, k);
      double barHigh  = iHigh (_Symbol, tf, k);
      double barClose = iClose(_Symbol, tf, k);
      //--- Check for mitigation: price broke past the far edge of the OB
      if (!isMit)
        {
         bool breakFar = (obs[idx].origUp && barLow < obLow) || (!obs[idx].origUp && barHigh > obHigh);
         if (breakFar)
           {
            isMit   = true;
            mitTime = iTime(_Symbol, tf, k);
            if (prt) Print("Historical Mitigated: ", obNAME, " at time=", TimeToString(mitTime));
           }
        }
      //--- Check for trade signal: previous close inside zone, current close outside
      if ((!isMit || tradeMitigated == TradeMitigated) && !isSig && k >= 1)
        {
         double close2   = iClose(_Symbol, tf, k + 1);
         double close1   = barClose;
         //--- Previous bar closed inside the OB
         bool   inside2  = (close2 >= obLow && close2 <= obHigh);
         //--- Current bar closed outside the OB in the trend direction
         bool   outside1 = obs[idx].origUp ? (close1 > obHigh) : (close1 < obLow);
         if (inside2 && outside1) isSig = true;
        }
     }
   //--- Commit the computed mitigation and signal flags to the OB record
   obs[idx].mit      = isMit;
   obs[idx].signal   = isSig;
   obs[idx].mitTime  = mitTime;
   obs[idx].state    = isMit ? Mitigated : Normal;
   obs[idx].newSignal = false;
   //--- Retrieve the appropriate color for the current OB state
   color currentClr = GetZoneColor(obs[idx].origUp, obs[idx].state);
   //--- Redraw the OB rectangle with the updated color
   UpdateRec(obs[idx].name, obs[idx].startTime, obLow, obs[idx].origEndTime, obHigh, currentClr);
   //--- Draw the mitigation icon if the zone was mitigated
   if (mitTime > 0) DrawMitIcon(obs[idx].name, mitTime, obHigh, obLow, obs[idx].origUp);
  }

//+------------------------------------------------------------------+
//| Check for BOS and inducement, draw objects if confirmed          |
//+------------------------------------------------------------------+
bool HasBOSAndInducement(int idx, ENUM_TIMEFRAMES stf)
  {
   //--- Extract OB time references and direction
   datetime obTime  = obs[idx].startTime;
   datetime endTime = obs[idx].origEndTime;
   datetime fvgTime = obs[idx].fvgTime;
   bool     isBearish = !obs[idx].origUp;
   //--- Convert OB and FVG times to bar indices
   int ob_bar  = iBarShift(_Symbol, stf, obTime);
   int fvg_bar = iBarShift(_Symbol, stf, fvgTime);
   if (ob_bar < 0 || fvg_bar < 0) return false;
   //--- Retrieve OB price boundaries from bar data
   double   obLow    = MathMin(iLow(_Symbol, stf, ob_bar), iHigh(_Symbol, stf, ob_bar));
   double   obHigh   = MathMax(iLow(_Symbol, stf, ob_bar), iHigh(_Symbol, stf, ob_bar));
   //--- Initialise swing search result variables
   double   swing_ext  = 0.0;
   datetime swing_time = 0;
   int      swing_bar  = -1;
   //--- Search bars after the FVG for the first valid swing that lies outside the OB
   for (int k = fvg_bar - 1; k >= 0; k--)
     {
      datetime bar_time = iTime(_Symbol, stf, k);
      //--- Stop scanning once we pass the OB expiry time
      if (bar_time > endTime) break;
      //--- Check for swing low in bearish context, swing high in bullish
      bool is_swing = isBearish ? isSwingLow(k, stf, swing_strength) : isSwingHigh(k, stf, swing_strength);
      if (is_swing)
        {
         double temp_swing_ext = isBearish ? iLow(_Symbol, stf, k) : iHigh(_Symbol, stf, k);
         //--- Skip swings that fall within the OB price range
         if (temp_swing_ext >= obLow && temp_swing_ext <= obHigh) continue;
         //--- Record this as the reference swing for BOS detection
         swing_ext  = temp_swing_ext;
         swing_time = bar_time;
         swing_bar  = k;
         break;
        }
     }
   //--- Abort if no qualifying swing was found after the FVG
   if (swing_ext == 0.0)
     {
      if (prt) Print("No swing found after FVG for: ", obs[idx].name);
      return false;
     }
   //--- Initialise BOS break search variables
   datetime break_time = 0;
   int      break_bar  = -1;
   //--- Search bars after the swing for a bar that closes past the swing level
   for (int k = swing_bar - 1; k >= 0; k--)
     {
      datetime bar_time  = iTime (_Symbol, stf, k);
      //--- Stop scanning once we pass the OB expiry time
      if (bar_time > endTime) break;
      double   bar_low   = iLow  (_Symbol, stf, k);
      double   bar_high  = iHigh (_Symbol, stf, k);
      double   bar_close = iClose(_Symbol, stf, k);
      //--- Confirm a bearish BOS if both low and close are below the swing low
      bool     broken = isBearish
                        ? (bar_low < swing_ext && bar_close < swing_ext)
                        : (bar_high > swing_ext && bar_close > swing_ext);
      if (broken)
        {
         break_time = bar_time;
         break_bar  = k;
         break;
        }
     }
   //--- Abort if no break of structure was confirmed
   if (break_bar == -1)
     {
      if (prt) Print("No BOS break found for OB: ", obs[idx].name);
      return false;
     }
   //--- Build and draw the BOS swing arrow and horizontal break level
   string bos_name = BOS_Prefix + TimeToString(obTime);
   color  bos_clr  = isBearish ? def_clr_down : def_clr_up;
   int    bos_dir  = isBearish ? 1 : -1;
   drawSwingPoint(TimeToString(swing_time), swing_time, swing_ext, object_code, bos_clr, bos_dir, 0);
   drawBreakLevel(bos_name, swing_time, swing_ext, break_time, swing_ext, bos_clr, bos_dir);
   if (prt) Print("BOS detected and drawn for OB: ", obs[idx].name);
   //--- Calculate the reduced strength for inducement swing detection
   int    ind_strength = MathMax(swing_strength / 2, 1);
   bool   found_ind    = false;
   datetime ind_time   = 0;
   double   ind_ext    = 0.0;
   //--- Search between the swing bar and the break bar for an inducement swing
   for (int m = swing_bar - 1; m >= break_bar; m--)
     {
      //--- Check for inducement swing in the opposing direction of the BOS
      bool is_ind_swing = isBearish ? isSwingHigh(m, stf, ind_strength) : isSwingLow(m, stf, ind_strength);
      if (is_ind_swing)
        {
         double temp_ind_ext = isBearish ? iHigh(_Symbol, stf, m) : iLow(_Symbol, stf, m);
         //--- Skip inducements that fall within the OB price range
         if (temp_ind_ext >= obLow && temp_ind_ext <= obHigh) continue;
         //--- Compute the depth of the inducement from the swing level
         double depth = MathAbs(temp_ind_ext - swing_ext) / _Point;
         //--- Accept only inducements deeper than the minimum threshold
         if (depth > minIndDepthPts)
           {
            ind_time  = iTime(_Symbol, stf, m);
            ind_ext   = temp_ind_ext;
            found_ind = true;
           }
        }
     }
   //--- Abort if no valid inducement was found between swing and break
   if (!found_ind)
     {
      if (prt) Print("No significant/non-overlapping inducement found for OB: ", obs[idx].name);
      return false;
     }
   //--- Calculate the end time for the inducement trendline display
   datetime ind_end  = ind_time + PeriodSeconds(stf) * inducement_ext_bars;
   //--- Build the inducement trendline and label object names
   string   ind_name = IND_Prefix + TimeToString(obTime);
   //--- Draw a horizontal dashed trendline at the inducement level
   ObjectCreate(0, ind_name, OBJ_TREND, 0, ind_time, ind_ext, ind_end, ind_ext);
   ObjectSetInteger(0, ind_name, OBJPROP_COLOR,     bos_clr);
   ObjectSetInteger(0, ind_name, OBJPROP_STYLE,     STYLE_DASH);
   ObjectSetInteger(0, ind_name, OBJPROP_WIDTH,     1);
   ObjectSetInteger(0, ind_name, OBJPROP_RAY_RIGHT, false);
   //--- Create the "Inducement" text label above or below the trendline
   string lbl = ind_name + "_label";
   ObjectCreate(0, lbl, OBJ_TEXT, 0, ind_time, ind_ext);
   ObjectSetString (0, lbl, OBJPROP_TEXT,     "Inducement");
   ObjectSetInteger(0, lbl, OBJPROP_COLOR,    bos_clr);
   ObjectSetInteger(0, lbl, OBJPROP_FONTSIZE, current_font_size);
   //--- Anchor text below the line for bearish inducements, above for bullish
   ObjectSetInteger(0, lbl, OBJPROP_ANCHOR,   isBearish ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
   if (prt) Print("Inducement detected and drawn for OB: ", obs[idx].name);
   return true;
  }

//+------------------------------------------------------------------+
//| Update trend direction from higher timeframe swing analysis      |
//+------------------------------------------------------------------+
void UpdateTrend()
  {
   //--- Retrieve the total number of bars on the higher timeframe
   int bars = iBars(_Symbol, higher_tf);
   double curr_swing_high = -1.0, curr_swing_low = -1.0;
   int    new_trend = 0;
   //--- Clear all objects on the H4 chart when it is open
   if (chart_id > 0) ObjectsDeleteAll(chart_id, -1, -1);
   //--- Iterate from oldest to newest bar looking for swing highs and lows
   for (int i = bars - swing_strength - 1; i >= swing_strength; i--)
     {
      //--- Detect swing high: current bar must be strictly highest in window
      bool isHigh = true;
      for (int j = 1; j <= swing_strength; j++)
        {
         if (iHigh(_Symbol, higher_tf, i) <= iHigh(_Symbol, higher_tf, i + j)) isHigh = false;
         if (iHigh(_Symbol, higher_tf, i) <= iHigh(_Symbol, higher_tf, i - j)) isHigh = false;
        }
      if (isHigh)
        {
         double new_high = iHigh(_Symbol, higher_tf, i);
         //--- Label as HH (higher high) or LH (lower high) relative to last swing high
         string label = (curr_swing_high < 0) ? "H" : (new_high > curr_swing_high ? "HH" : "LH");
         color  clr   = (label == "HH") ? clrBlue : clrRed;
         //--- Draw the swing label on the H4 chart if it is open
         if (chart_id > 0)
            drawSwingPoint(TimeToString(iTime(_Symbol, higher_tf, i)),
                           iTime(_Symbol, higher_tf, i), new_high, 174, clr, -1, chart_id);
         //--- Update trend to bullish on higher high confirmation
         if (label == "HH")   new_trend =  1;
         //--- Update trend to bearish on lower high confirmation
         else if (label == "LH") new_trend = -1;
         curr_swing_high = new_high;
        }
      //--- Detect swing low: current bar must be strictly lowest in window
      bool isLow = true;
      for (int j = 1; j <= swing_strength; j++)
        {
         if (iLow(_Symbol, higher_tf, i) >= iLow(_Symbol, higher_tf, i + j)) isLow = false;
         if (iLow(_Symbol, higher_tf, i) >= iLow(_Symbol, higher_tf, i - j)) isLow = false;
        }
      if (isLow)
        {
         double new_low = iLow(_Symbol, higher_tf, i);
         //--- Label as LL (lower low) or HL (higher low) relative to last swing low
         string label = (curr_swing_low < 0) ? "L" : (new_low < curr_swing_low ? "LL" : "HL");
         color  clr   = (label == "HL") ? clrBlue : clrRed;
         //--- Draw the swing label on the H4 chart if it is open
         if (chart_id > 0)
            drawSwingPoint(TimeToString(iTime(_Symbol, higher_tf, i)),
                           iTime(_Symbol, higher_tf, i), new_low, 174, clr, 1, chart_id);
         //--- Update trend to bullish on higher low confirmation
         if (label == "HL")   new_trend =  1;
         //--- Update trend to bearish on lower low confirmation
         else if (label == "LL") new_trend = -1;
         curr_swing_low = new_low;
        }
     }
   //--- Commit the determined trend direction to the global variable
   current_trend = new_trend;
   //--- Render the updated trend label on the main chart
   DrawTrendLabel();
   //--- Refresh the higher timeframe chart after redrawing swings
   if (chart_id > 0) ChartRedraw(chart_id);
  }

//+------------------------------------------------------------------+
//| Handle RR-based trailing stop for all open positions             |
//+------------------------------------------------------------------+
void HandleRRTrailing()
  {
   double point = _Point;
   double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   //--- Iterate all tracked trades in reverse for safe removal
   for (int i = ArraySize(trades) - 1; i >= 0; i--)
     {
      //--- Remove the entry if the position no longer exists
      if (!PositionSelectByTicket(trades[i].ticket))
        {
         ArrayRemove(trades, i, 1);
         continue;
        }
      //--- Skip positions on other symbols
      if (PositionGetString (POSITION_SYMBOL) != _Symbol)      continue;
      //--- Skip positions opened by other EAs
      if (PositionGetInteger(POSITION_MAGIC)  != magic_number) continue;
      //--- Read current position details
      double entry  = PositionGetDouble (POSITION_PRICE_OPEN);
      double sl     = PositionGetDouble (POSITION_SL);
      double tp     = PositionGetDouble (POSITION_TP);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      //--- Compute current profit distance from entry in price terms
      double profit_dist = (type == POSITION_TYPE_BUY) ? (bid - entry) : (entry - ask);
      double orig_risk   = trades[i].orig_risk;
      int    level       = trades[i].trail_level;
      //--- Advance trailing level while profit exceeds the next RR threshold
      while (profit_dist >= (level + 1) * orig_risk)
        {
         //--- Compute the new SL at the current RR level from entry
         double new_sl = (type == POSITION_TYPE_BUY)
                         ? NormalizeDouble(entry + level * orig_risk, _Digits)
                         : NormalizeDouble(entry - level * orig_risk, _Digits);
         //--- Read broker stop and freeze levels to enforce minimum distance
         long   stop_level   = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
         long   freeze_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
         double min_dist     = MathMax(stop_level, freeze_level) * point;
         //--- Clamp the buy SL so it does not violate the minimum stop distance
         if (type == POSITION_TYPE_BUY)
           {
            double min_sl = bid - min_dist;
            if (new_sl > min_sl) new_sl = min_sl;
           }
         else
           {
            //--- Clamp the sell SL so it does not violate the minimum stop distance
            double max_sl = ask + min_dist;
            if (new_sl < max_sl) new_sl = max_sl;
           }
         //--- Skip if the new SL matches the current SL (no change needed)
         if (new_sl == sl) break;
         //--- Apply the trailing SL modification to the broker
         if (obj_Trade.PositionModify(trades[i].ticket, new_sl, tp))
           {
            sl = new_sl;
            trades[i].trail_level++;
           }
         else break;
         level = trades[i].trail_level;
        }
     }
  }

//+------------------------------------------------------------------+
//| Apply fixed points trailing stop to all open positions           |
//+------------------------------------------------------------------+
void ApplyPointsTrailing()
  {
   double point = _Point;
   //--- Iterate all open positions in reverse for safe modification
   for (int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if (PositionGetTicket(i) > 0)
        {
         //--- Filter by symbol and magic number to target only this EA's trades
         if (PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic_number)
           {
            double sl        = PositionGetDouble(POSITION_SL);
            double tp        = PositionGetDouble(POSITION_TP);
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            ulong  ticket    = PositionGetInteger(POSITION_TICKET);
            //--- Handle buy position trailing
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               //--- Compute new SL below current bid by the trailing distance
               double newSL = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - Trailing_Stop_Pips * point, _Digits);
               //--- Move SL only if it improves and profit threshold is met
               if (newSL > sl && SymbolInfoDouble(_Symbol, SYMBOL_BID) - openPrice > Min_Profit_To_Trail_Pips * point)
                  obj_Trade.PositionModify(ticket, newSL, tp);
              }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               //--- Compute new SL above current ask by the trailing distance
               double newSL = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + Trailing_Stop_Pips * point, _Digits);
               //--- Move SL only if it improves and profit threshold is met
               if (newSL < sl && openPrice - SymbolInfoDouble(_Symbol, SYMBOL_ASK) > Min_Profit_To_Trail_Pips * point)
                  obj_Trade.PositionModify(ticket, newSL, tp);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Detect new OB zones on recent bars                               |
//+------------------------------------------------------------------+
void DetectNewZones(ENUM_TIMEFRAMES tf)
  {
   //--- Skip detection when no trend direction is defined
   if (current_trend == 0) return;
   //--- Scan the last 50 confirmed bars for new OB formations
   for (int i = 50; i >= 1; i--)
      DetectAndCreateZone(i, tf);
  }

//+------------------------------------------------------------------+
//| Update mitigation and signal states for all tracked OBs          |
//+------------------------------------------------------------------+
void UpdateOBs(ENUM_TIMEFRAMES tf)
  {
   //--- Read the last two confirmed bar closes and boundaries
   double   prevClose  = iClose(_Symbol, tf, 1);
   double   close2     = iClose(_Symbol, tf, 2);
   double   prevLow    = iLow  (_Symbol, tf, 1);
   double   prevHigh   = iHigh (_Symbol, tf, 1);
   datetime curBarTime = iTime (_Symbol, tf, 1);
   bool     removed    = false;
   //--- Iterate OBs in reverse to allow safe in-place removal
   for (int j = ArraySize(obs) - 1; j >= 0; j--)
     {
      //--- Remove OB entries whose chart objects have been deleted externally
      if (ObjectFind(0, obs[j].name) < 0)
        {
         if (prt) Print("Update: Removed non-existent OB from storage: ", obs[j].name);
         ArrayRemove(obs, j, 1);
         removed = true;
         continue;
        }
      //--- Read the current OB price boundaries from the chart object
      double obLow  = MathMin(ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 0), ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 1));
      double obHigh = MathMax(ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 0), ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 1));
      //--- Validate unconfirmed OBs by checking for BOS and inducement now
      if (!obs[j].valid && !obs[j].mit)
        {
         if (HasBOSAndInducement(j, tf))
           {
            obs[j].valid = true;
            if (prt) Print("OB validated with BOS/Inducement: ", obs[j].name);
           }
        }
      //--- Check for mitigation on the last confirmed bar
      if (!obs[j].mit)
        {
         bool breakFar = (obs[j].origUp && prevLow < obLow) || (!obs[j].origUp && prevHigh > obHigh);
         if (breakFar)
           {
            //--- Mark OB as mitigated and record the mitigation bar time
            obs[j].mit     = true;
            obs[j].mitTime = curBarTime;
            obs[j].state   = Mitigated;
            if (prt) Print("Mitigated OB: ", obs[j].name, " at time=", TimeToString(curBarTime));
            //--- Redraw the OB rectangle with the mitigated color
            color mitClr = GetZoneColor(obs[j].origUp, obs[j].state);
            UpdateRec(obs[j].name, obs[j].startTime, obLow, obs[j].origEndTime, obHigh, mitClr);
            //--- Place the mitigation icon on the chart
            DrawMitIcon(obs[j].name, curBarTime, obHigh, obLow, obs[j].origUp);
           }
        }
      //--- Check for a new trade signal on valid OBs that allow it
      if ((!obs[j].mit || tradeMitigated == TradeMitigated) && obs[j].valid)
        {
         //--- Bar two closes ago was inside the OB
         bool inside2  = (close2 >= obLow && close2 <= obHigh);
         //--- Previous bar closed outside the OB in the expected breakout direction
         bool outside1 = obs[j].origUp ? (prevClose > obHigh) : (prevClose < obLow);
         if (inside2 && outside1)
           {
            //--- Flag a new tradeable signal for this OB
            obs[j].newSignal = true;
            obs[j].signal    = true;
            if (prt) Print("Signal (tap) on OB: ", obs[j].name, " at time=", TimeToString(curBarTime));
           }
        }
     }
   //--- Log OB array state after any removals
   if (removed) PrintOBs();
  }

//+------------------------------------------------------------------+
//| Execute trades on OBs that carry a new signal                    |
//+------------------------------------------------------------------+
void TradeOnOBs()
  {
   //--- Retrieve current market prices
   double Ask     = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   double Bid     = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   //--- Retrieve account and symbol parameters for lot sizing
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double min_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lot_step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   //--- Resolve the trading timeframe
   ENUM_TIMEFRAMES use_tf    = (trade_tf == PERIOD_CURRENT) ? _Period : trade_tf;
   datetime        curBarTime = iTime(_Symbol, use_tf, 0);
   //--- Iterate all tracked OBs looking for actionable signals
   for (int j = 0; j < ArraySize(obs); j++)
     {
      //--- Skip OBs without a fresh signal, not validated, or blocked by settings
      if (!obs[j].newSignal || (obs[j].mitTime != 0 && tradeMitigated != TradeMitigated) || !obs[j].valid) continue;
      //--- Enforce the TradeOnce limit
      if (tradeMode == TradeOnce     && obs[j].tradeCount >= 1)             { obs[j].newSignal = false; continue; }
      //--- Enforce the LimitedTrades count limit
      if (tradeMode == LimitedTrades && obs[j].tradeCount >= maxTradesPerOB) { obs[j].newSignal = false; continue; }
      //--- Read OB price boundaries for entry and SL calculation
      double obLow  = MathMin(ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 0), ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 1));
      double obHigh = MathMax(ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 0), ObjectGetDouble(0, obs[j].name, OBJPROP_PRICE, 1));
      //--- Set entry at ask for buys, bid for sells
      double entry  = obs[j].origUp ? Ask : Bid;
      //--- Set SL below the OB for buys, above for sells, with an offset buffer
      double sl     = obs[j].origUp
                      ? NormalizeDouble(obLow  - sl_offset_pts * _Point, _Digits)
                      : NormalizeDouble(obHigh + sl_offset_pts * _Point, _Digits);
      double risk_dist = MathAbs(entry - sl);
      if (risk_dist <= 0) continue;
      //--- Compute risk in points for lot sizing
      double points      = risk_dist / _Point;
      double risk_amount = balance * (risk_percent / 100.0);
      //--- Calculate the lot size that risks exactly the target amount
      double lot_size    = risk_amount / (points * tick_value);
      //--- Round to lot step and clamp within broker limits
      lot_size = MathMin(MathMax(MathRound(lot_size / lot_step) * lot_step, min_lot), max_lot);
      if (lot_size < min_lot) continue;
      //--- Compute TP based on the risk distance and RR ratio
      double tp = obs[j].origUp
                  ? NormalizeDouble(entry + risk_dist * rr_ratio, _Digits)
                  : NormalizeDouble(entry - risk_dist * rr_ratio, _Digits);
      bool result = false;
      //--- Place a buy market order for bullish OBs
      if (obs[j].origUp)
        {
         if (prt) Print("BULLISH OB TRADE SIGNAL For ", obs[j].name, " at ", Bid, " Lot: ", lot_size);
         result = obj_Trade.Buy(lot_size, _Symbol, Ask, sl, tp, "OB Buy");
        }
      else
        {
         //--- Place a sell market order for bearish OBs
         if (prt) Print("BEARISH OB TRADE SIGNAL For ", obs[j].name, " at ", Ask, " Lot: ", lot_size);
         result = obj_Trade.Sell(lot_size, _Symbol, Bid, sl, tp, "OB Sell");
        }
      //--- Process post-trade bookkeeping if the order was accepted
      if (result && obj_Trade.ResultRetcode() == TRADE_RETCODE_DONE)
        {
         ulong ticket = obj_Trade.ResultOrder();
         //--- Register the trade for RR trailing if that mode is active
         if (TrailingType == Trailing_RR)
           {
            int tsize = ArraySize(trades);
            ArrayResize(trades, tsize + 1);
            trades[tsize].ticket      = ticket;
            trades[tsize].orig_risk   = risk_dist;
            trades[tsize].trail_level = 0;
           }
         //--- Increment trade count and clear the fresh signal flag
         obs[j].tradeCount++;
         obs[j].newSignal = false;
         if (prt) Print("Trade executed on ", obs[j].name, ", tradeCount now=", obs[j].tradeCount);
         //--- Update the zone label to reflect the new trade count
         double   midPrice = (obLow + obHigh) / 2;
         datetime midTime  = obs[j].startTime + (obs[j].origEndTime - obs[j].startTime) / 2;
         UpdateLabel(obs[j].name, midTime, midPrice);
         //--- Draw entry, SL, and TP level lines on the chart if enabled
         if (VisualizeLevels)
           {
            datetime drawStart  = curBarTime;
            datetime drawEnd    = drawStart + PeriodSeconds(use_tf) * 5;
            datetime labelTime  = drawEnd + PeriodSeconds(use_tf) / 2;
            bool     isBuy      = obs[j].origUp;
            double   sign       = isBuy ? 1.0 : -1.0;
            //--- Draw and label the entry level
            DrawDottedLine(obs[j].name + "_Entry",       drawStart, entry, drawEnd, clrMagenta);
            DrawTextEx    (obs[j].name + "_Entry_label", "Entry",   labelTime, entry, clrMagenta, isBuy);
            //--- Draw and label the stop loss level
            DrawDottedLine(obs[j].name + "_SL",       drawStart, sl, drawEnd, clrRed);
            DrawTextEx    (obs[j].name + "_SL_label", "SL",       labelTime, sl, clrRed, !isBuy);
            //--- Define a set of green shades for progressive TP levels
            color tpColors[4] = {clrForestGreen, clrGreen, clrDarkGreen, clrLime};
            int   maxLevels   = (int)rr_ratio;
            //--- Draw and label each TP level up to the full RR ratio
            for (int lev = 1; lev <= maxLevels; lev++)
              {
               double lev_p   = entry + sign * risk_dist * lev;
               color  c       = (lev - 1 < 4) ? tpColors[lev - 1] : clrLime;
               //--- Label the final level as FullTP, intermediate levels as TP1, TP2, etc.
               string levName = (lev == maxLevels) ? "FullTP" : "TP" + IntegerToString(lev);
               DrawDottedLine(obs[j].name + "_" + levName,           drawStart, lev_p, drawEnd, c);
               DrawTextEx    (obs[j].name + "_" + levName + "_label", levName,   labelTime, lev_p, c, isBuy);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Remove expired OBs from the tracking array (keep chart objects)  |
//+------------------------------------------------------------------+
void CleanupExpiredOBs(datetime curBarTime)
  {
   bool removed = false;
   //--- Iterate in reverse to safely remove expired entries
   for (int j = ArraySize(obs) - 1; j >= 0; j--)
     {
      //--- Remove from array once the current bar has passed the OB expiry
      if (curBarTime > obs[j].origEndTime)
        {
         if (prt) Print("Expired OB removed from storage (kept on chart): ", obs[j].name, " endTime=", TimeToString(obs[j].origEndTime));
         ArrayRemove(obs, j, 1);
         removed = true;
        }
     }
   //--- Log the updated OB list after any removals
   if (removed) PrintOBs();
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //--- Assign the magic number to the trade object for order identification
   obj_Trade.SetExpertMagicNumber(magic_number);
   //--- Open a separate chart on the higher timeframe for swing visualization
   chart_id = ChartOpen(_Symbol, higher_tf);
   if (chart_id <= 0)
      Print("Failed to open higher TF chart (possibly in tester). Proceeding without visuals.");
   //--- Remove all previously drawn zone objects from the main chart
   ObjectsDeleteAll(0, FVG_Prefix);
   ObjectsDeleteAll(0, OB_Prefix);
   ObjectsDeleteAll(0, BOS_Prefix);
   ObjectsDeleteAll(0, IND_Prefix);
   //--- Remove the trend label left by any previous EA run
   ObjectDelete(0, "EA_TrendLabel");
   //--- Reset all tracking arrays to empty
   ArrayResize(obs,       0);
   ArrayResize(fvg_names, 0);
   ArrayResize(trades,    0);
   if (prt) Print("Initializing: Deleted all existing objects and reset arrays.");
   //--- Analyse the higher timeframe to establish the initial trend direction
   UpdateTrend();
   //--- Resolve the actual trading timeframe
   ENUM_TIMEFRAMES use_tf    = (trade_tf == PERIOD_CURRENT) ? _Period : trade_tf;
   int             visibleBars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   //--- Scan all visible bars historically to build the initial OB map
   for (int i = visibleBars - 3; i >= 0; i--)
      DetectAndCreateZone(i, use_tf);
   //--- Replay historical price action to set mitigation and signal states
   for (int j = 0; j < ArraySize(obs); j++)
      ProcessHistoricalState(j, use_tf);
   //--- Mark OBs that already have confirmed BOS and inducement as valid
   for (int j = 0; j < ArraySize(obs); j++)
     {
      if (!obs[j].mit && HasBOSAndInducement(j, use_tf))
         obs[j].valid = true;
     }
   //--- Log the full initial OB array
   PrintOBs();
   //--- Sync label font sizes to the current chart scale
   UpdateFontSizes();
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //--- Delete all OB rectangle objects and associated labels and icons
   for (int i = 0; i < ArraySize(obs); i++)
     {
      ObjectDelete(0, obs[i].name);
      ObjectDelete(0, obs[i].name + "_Label");
      ObjectDelete(0, obs[i].name + "_MitIcon");
     }
   //--- Delete all FVG rectangle objects
   for (int i = 0; i < ArraySize(fvg_names); i++)
      ObjectDelete(0, fvg_names[i]);
   //--- Delete all BOS, inducement, and OB prefixed objects
   ObjectsDeleteAll(0, BOS_Prefix);
   ObjectsDeleteAll(0, IND_Prefix);
   ObjectsDeleteAll(0, OB_Prefix);
   //--- Remove the trend label from the main chart
   ObjectDelete(0, "EA_TrendLabel");
   //--- Release all dynamic arrays
   ArrayResize(obs,       0);
   ArrayResize(fvg_names, 0);
   ArrayResize(trades,    0);
   //--- Close the higher timeframe chart if it was opened by this EA
   if (chart_id > 0) { ChartClose(chart_id); chart_id = -1; }
   //--- Refresh the main chart after cleanup
   ChartRedraw(0);
   if (prt) Print("Deinit: Deleted all objects, reset arrays, closed higher TF chart if open.");
//---
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //--- Run RR trailing logic if that mode is active and positions are open
   if (TrailingType == Trailing_RR     && PositionsTotal() > 0) HandleRRTrailing();
   //--- Run points trailing logic if that mode is active and positions are open
   if (TrailingType == Trailing_Points && PositionsTotal() > 0) ApplyPointsTrailing();
   //--- Check for a new bar on the higher timeframe and refresh the trend
   static datetime lastHigherBarTime = 0;
   datetime curHigherBarTime = iTime(_Symbol, higher_tf, 0);
   if (curHigherBarTime != lastHigherBarTime)
     {
      lastHigherBarTime = curHigherBarTime;
      UpdateTrend();
     }
   //--- Resolve the trading timeframe for bar detection
   ENUM_TIMEFRAMES use_tf = (trade_tf == PERIOD_CURRENT) ? _Period : trade_tf;
   //--- Detect a new bar on the trading timeframe
   static datetime lastBarTime = 0;
   datetime curBarTime = iTime(_Symbol, use_tf, 0);
   bool newBar = (curBarTime != lastBarTime);
   //--- Skip all zone logic if this is not a new bar
   if (!newBar) return;
   lastBarTime = curBarTime;
   //--- Scan for newly formed OB zones
   DetectNewZones(use_tf);
   //--- Update mitigation and signal states for all tracked OBs
   UpdateOBs(use_tf);
   //--- Execute trades on OBs carrying fresh signals
   TradeOnOBs();
   //--- Remove OBs that have passed their expiry time
   CleanupExpiredOBs(curBarTime);
//---
  }

//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Respond to chart scale or size changes by updating all font sizes
   if (id == CHARTEVENT_CHART_CHANGE) UpdateFontSizes();
  }
//+------------------------------------------------------------------+