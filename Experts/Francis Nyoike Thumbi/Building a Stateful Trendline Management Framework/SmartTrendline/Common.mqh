//+------------------------------------------------------------------+
//|                                                       Common.mqh |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
//--- Every class owns one responsibility.
//--- If a method naturally belongs in another class, move it instead of increasing coupling.

//--- Preprocessor Constants (Required for Default Function Parameters in MQL5)
#define DEFAULT_TOUCH_PROXIMITY_PTS 5.0
#define DEFAULT_TRENDLINE_PREFIX    "TL_"
#define DEFAULT_TOUCH_ATR_MULT      0.2
#define DEFAULT_BOUNCE_ATR_MULT     0.5
#define DEFAULT_BREAK_ATR_MULT      0.3

//--- Trendline Lifecycle States
enum ENUM_TRENDLINE_STATE
  {
   TRENDLINE_STATE_UNKNOWN       = 0, // Initial uncalculated state
   TRENDLINE_STATE_ACTIVE        = 1, // Active line with price nearby (Untouched)
   TRENDLINE_STATE_TOUCH_PENDING = 2, // Price inside proximity band; waiting for resolution
   TRENDLINE_STATE_BOUNCED       = 3, // Confirmed rejection away from line by ATR threshold
   TRENDLINE_STATE_BROKEN        = 4, // Price closed beyond the line by ATR threshold
   TRENDLINE_STATE_RETESTED      = 5, // Price retesting broken line from opposite side
   TRENDLINE_STATE_EXPIRED       = 6  // Out of time range or manually flagged
  };

//--- Interaction/Breakout Types
enum ENUM_BREAKOUT_TYPE
  {
   BREAKOUT_NONE = 0,  // No breakout detected
   BREAKOUT_BULLISH,   // Price closed above line
   BREAKOUT_BEARISH    // Price closed below line
  };

//--- Pure 2D Coordinate Point (Pure Math Model)
struct Point2D
  {
   double            x; // Horizontal axis value (e.g., bar index or x-coordinate)
   double            y; // Vertical axis value (e.g., price level or y-coordinate)

                     Point2D() : x(0.0), y(0.0) {}
                     Point2D(double _x, double _y) : x(_x), y(_y) {}
  };

//--- Visual Style Profile
struct TrendlineStyle
  {
   color             clr;
   ENUM_LINE_STYLE   style;
   int               width;
   bool              ray_right;
  };

//--- Configuration Defaults (Avoids Magic Numbers)
namespace TrendlineDefaults
{
const string Prefix        = "TL_";     // Default prefix filter for manual objects
const double ProximityPts  = 5.0;       // Touch proximity tolerance in points

//--- Volatility Threshold Multipliers (ATR Multipliers for Pending Resolution)
const double TouchAtrMult   = 0.2;      // ATR distance tolerance to register TOUCH_PENDING
const double BounceAtrMult  = 0.5;      // Required ATR distance rejection to confirm BOUNCED
const double BreakAtrMult   = 0.3;      // Required ATR bar-close margin to confirm BROKEN

//--- State Colors
const color ActiveColor    = clrLime;   // Active line color
const color TouchedColor   = clrYellow; // Line color on touch (Pending)
const color BrokenColor    = clrRed;    // Broken line color
const color RetestedColor  = clrOrange; // Retested line color

//--- State Line Styles
const ENUM_LINE_STYLE ActiveStyle = STYLE_SOLID;
const ENUM_LINE_STYLE BrokenStyle = STYLE_DOT;

//--- Visual Widths
const int DefaultWidth     = 2;
}
//+------------------------------------------------------------------+

