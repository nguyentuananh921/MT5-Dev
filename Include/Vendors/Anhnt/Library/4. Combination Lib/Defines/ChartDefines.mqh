//+------------------------------------------------------------------+
//|                                               ChartDefines.mqh
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __CHART_DEFINES_MQH__
#define __CHART_DEFINES_MQH__
#include "EventDefines.mqh"
//+------------------------------------------------------------------+
//| Data for working with MQL5.com signals                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| MQL5 signal integer properties                                   |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_MQL5_PROP_INTEGER
  {
   SIGNAL_MQL5_PROP_TRADE_MODE = 0,                   // Account type
   SIGNAL_MQL5_PROP_DATE_PUBLISHED,                   // Signal publication date 
   SIGNAL_MQL5_PROP_DATE_STARTED,                     // Start date of signal monitoring
   SIGNAL_MQL5_PROP_DATE_UPDATED,                     // Date of the latest update of the signal trading statistics
   SIGNAL_MQL5_PROP_ID,                               // Signal ID
   SIGNAL_MQL5_PROP_LEVERAGE,                         // Trading account leverage
   SIGNAL_MQL5_PROP_PIPS,                             // Trading result in pips
   SIGNAL_MQL5_PROP_RATING,                           // Position in the signal rating
   SIGNAL_MQL5_PROP_SUBSCRIBERS,                      // Number of subscribers
   SIGNAL_MQL5_PROP_TRADES,                           // Number of trades
   SIGNAL_MQL5_PROP_SUBSCRIPTION_STATUS,              // Status of account subscription to a signal
  };
#define SIGNAL_MQL5_PROP_INTEGER_TOTAL (11)           // Total number of integer properties
#define SIGNAL_MQL5_PROP_INTEGER_SKIP  (0)            // Number of integer DOM properties not used in sorting
//+------------------------------------------------------------------+
//| MQL5 signal real properties                                      |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_MQL5_PROP_DOUBLE
  {
   SIGNAL_MQL5_PROP_BALANCE = SIGNAL_MQL5_PROP_INTEGER_TOTAL, // Account balance
   SIGNAL_MQL5_PROP_EQUITY,                           // Account equity
   SIGNAL_MQL5_PROP_GAIN,                             // Account growth in %
   SIGNAL_MQL5_PROP_MAX_DRAWDOWN,                     // Maximum drawdown
   SIGNAL_MQL5_PROP_PRICE,                            // Signal subscription price
   SIGNAL_MQL5_PROP_ROI,                              // Signal ROI (Return on Investment) in %
  };
#define SIGNAL_MQL5_PROP_DOUBLE_TOTAL  (6)            // Total number of real properties
#define SIGNAL_MQL5_PROP_DOUBLE_SKIP   (0)            // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| MQL5 signal string properties                                    |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_MQL5_PROP_STRING
  {
   SIGNAL_MQL5_PROP_AUTHOR_LOGIN = (SIGNAL_MQL5_PROP_INTEGER_TOTAL+SIGNAL_MQL5_PROP_DOUBLE_TOTAL), // Signal author login
   SIGNAL_MQL5_PROP_BROKER,                           // Broker (company) name
   SIGNAL_MQL5_PROP_BROKER_SERVER,                    // Broker server
   SIGNAL_MQL5_PROP_NAME,                             // Signal name
   SIGNAL_MQL5_PROP_CURRENCY,                         // Signal account currency
  };
#define SIGNAL_MQL5_PROP_STRING_TOTAL  (5)            // Total number of string properties
//+------------------------------------------------------------------+
//| Possible sorting criteria of MQL5 signals                        |
//+------------------------------------------------------------------+
#define FIRST_SIGNAL_MQL5_DBL_PROP  (SIGNAL_MQL5_PROP_INTEGER_TOTAL-SIGNAL_MQL5_PROP_INTEGER_SKIP)
#define FIRST_SIGNAL_MQL5_STR_PROP  (SIGNAL_MQL5_PROP_INTEGER_TOTAL-SIGNAL_MQL5_PROP_INTEGER_SKIP+SIGNAL_MQL5_PROP_DOUBLE_TOTAL-SIGNAL_MQL5_PROP_DOUBLE_SKIP)
enum ENUM_SORT_SIGNAL_MQL5_MODE
  {
//--- Sort by integer properties
   SORT_BY_SIGNAL_MQL5_TRADE_MODE = 0,                // Sort by signal type
   SORT_BY_SIGNAL_MQL5_DATE_PUBLISHED,                // Sort by signal publication date 
   SORT_BY_SIGNAL_MQL5_DATE_STARTED,                  // Sort by signal monitoring start date
   SORT_BY_SIGNAL_MQL5_DATE_UPDATED,                  // Sort by date of the latest update of the signal trading statistics
   SORT_BY_SIGNAL_MQL5_ID,                            // Sort by signal ID
   SORT_BY_SIGNAL_MQL5_LEVERAGE,                      // Sort by trading account leverage
   SORT_BY_SIGNAL_MQL5_PIPS,                          // Sort by trading result in pips
   SORT_BY_SIGNAL_MQL5_RATING,                        // Sort by a position in the signal rating
   SORT_BY_SIGNAL_MQL5_SUBSCRIBERS,                   // Sort by the number of subscribers
   SORT_BY_SIGNAL_MQL5_TRADES,                        // Sort by the number of trades
   SORT_BY_SIGNAL_MQL5_SUBSCRIPTION_STATUS,           // Sort by the status of account subscription to a signal
//--- Sort by real properties
   SORT_BY_SIGNAL_MQL5_BALANCE = FIRST_SIGNAL_MQL5_DBL_PROP, // Sort by account balance
   SORT_BY_SIGNAL_MQL5_EQUITY,                        // Sort by account equity
   SORT_BY_SIGNAL_MQL5_GAIN,                          // Sort by account growth in %
   SORT_BY_SIGNAL_MQL5_MAX_DRAWDOWN,                  // Sort by maximum drawdown
   SORT_BY_SIGNAL_MQL5_PRICE,                         // Sort by signal subscription price
   SORT_BY_SIGNAL_MQL5_ROI,                           // Sort by ROI
//--- Sort by string properties
   SORT_BY_SIGNAL_MQL5_AUTHOR_LOGIN = FIRST_SIGNAL_MQL5_STR_PROP, // Sort by signal author login
   SORT_BY_SIGNAL_MQL5_BROKER,                        // Sort by broker (company) name
   SORT_BY_SIGNAL_MQL5_BROKER_SERVER,                 // Sort by broker server
   SORT_BY_SIGNAL_MQL5_NAME,                          // Sort by signal name
   SORT_BY_SIGNAL_MQL5_CURRENCY,                      // Sort by signal account currency
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Chart integer property                                           |
//+------------------------------------------------------------------+
enum ENUM_CHART_PROP_INTEGER
  {
   CHART_PROP_ID = 0,                                 // Chart ID
   CHART_PROP_TIMEFRAME,                              // Chart timeframe
   CHART_PROP_SHOW,                                   // Price chart drawing
   CHART_PROP_IS_OBJECT,                              // Chart object (OBJ_CHART) identification attribute
   CHART_PROP_BRING_TO_TOP,                           // Show chart above all others
   CHART_PROP_CONTEXT_MENU,                           // Enable/disable access to the context menu using the right click 
   CHART_PROP_CROSSHAIR_TOOL,                         // Enable/disable access to the Crosshair tool using the middle click
   CHART_PROP_MOUSE_SCROLL,                           // Scroll the chart horizontally using the left mouse button
   CHART_PROP_EVENT_MOUSE_WHEEL,                      // Send messages about mouse wheel events (CHARTEVENT_MOUSE_WHEEL) to all MQL5 programs on a chart
   CHART_PROP_EVENT_MOUSE_MOVE,                       // Send messages about mouse button click and movement events (CHARTEVENT_MOUSE_MOVE) to all MQL5 programs on a chart
   CHART_PROP_EVENT_OBJECT_CREATE,                    // Send messages about the graphical object creation event (CHARTEVENT_OBJECT_CREATE) to all MQL5 programs on a chart
   CHART_PROP_EVENT_OBJECT_DELETE,                    // Send messages about the graphical object destruction event (CHARTEVENT_OBJECT_DELETE) to all MQL5 programs on a chart
   CHART_PROP_MODE,                                   // Type of the chart (candlesticks, bars or line (ENUM_CHART_MODE))
   CHART_PROP_FOREGROUND,                             // Price chart in the foreground
   CHART_PROP_SHIFT,                                  // Mode of shift of the price chart from the right border
   CHART_PROP_AUTOSCROLL,                             // The mode of automatic shift to the right border of the chart
   CHART_PROP_KEYBOARD_CONTROL,                       // Allow managing the chart using a keyboard
   CHART_PROP_QUICK_NAVIGATION,                       // Allow the chart to intercept Space and Enter key strokes to activate the quick navigation bar
   CHART_PROP_SCALE,                                  // Scale
   CHART_PROP_SCALEFIX,                               // Fixed scale mode
   CHART_PROP_SCALEFIX_11,                            // 1:1 scale mode
   CHART_PROP_SCALE_PT_PER_BAR,                       // The mode of specifying the scale in points per bar
   CHART_PROP_SHOW_TICKER,                            // Display a symbol ticker in the upper left corner
   CHART_PROP_SHOW_OHLC,                              // Display OHLC values in the upper left corner
   CHART_PROP_SHOW_BID_LINE,                          // Display Bid value as a horizontal line on the chart
   CHART_PROP_SHOW_ASK_LINE,                          // Display Ask value as a horizontal line on a chart
   CHART_PROP_SHOW_LAST_LINE,                         // Display Last value as a horizontal line on a chart
   CHART_PROP_SHOW_PERIOD_SEP,                        // Display vertical separators between adjacent periods
   CHART_PROP_SHOW_GRID,                              // Display a grid on the chart
   CHART_PROP_SHOW_VOLUMES,                           // Display volumes on a chart
   CHART_PROP_SHOW_OBJECT_DESCR,                      // Display text descriptions of objects
   CHART_PROP_VISIBLE_BARS,                           // Number of bars on a chart that are available for display
   CHART_PROP_WINDOWS_TOTAL,                          // The total number of chart windows including indicator subwindows
   CHART_PROP_WINDOW_HANDLE,                          // Chart window handle
   CHART_PROP_FIRST_VISIBLE_BAR,                      // Number of the first visible bar on the chart
   CHART_PROP_WIDTH_IN_BARS,                          // Width of the chart in bars
   CHART_PROP_WIDTH_IN_PIXELS,                        // Width of the chart in pixels
   CHART_PROP_COLOR_BACKGROUND,                       // Color of background of the chart
   CHART_PROP_COLOR_FOREGROUND,                       // Color of axes, scale and OHLC line
   CHART_PROP_COLOR_GRID,                             // Grid color
   CHART_PROP_COLOR_VOLUME,                           // Color of volumes and position opening levels
   CHART_PROP_COLOR_CHART_UP,                         // Color for the up bar, shadows and body borders of bull candlesticks
   CHART_PROP_COLOR_CHART_DOWN,                       // Color of down bar, its shadow and border of body of the bullish candlestick
   CHART_PROP_COLOR_CHART_LINE,                       // Color of the chart line and the Doji candlesticks
   CHART_PROP_COLOR_CANDLE_BULL,                      // Color of body of a bullish candlestick
   CHART_PROP_COLOR_CANDLE_BEAR,                      // Color of body of a bearish candlestick
   CHART_PROP_COLOR_BID,                              // Color of the Bid price line
   CHART_PROP_COLOR_ASK,                              // Color of the Ask price line
   CHART_PROP_COLOR_LAST,                             // Color of the last performed deal's price line (Last)
   CHART_PROP_COLOR_STOP_LEVEL,                       // Color of stop order levels (Stop Loss and Take Profit)
   CHART_PROP_SHOW_TRADE_LEVELS,                      // Display trade levels on the chart (levels of open positions, Stop Loss, Take Profit and pending orders)
   CHART_PROP_DRAG_TRADE_LEVELS,                      // Enable the ability to drag trading levels on a chart using mouse
   CHART_PROP_SHOW_DATE_SCALE,                        // Display the time scale on a chart
   CHART_PROP_SHOW_PRICE_SCALE,                       // Display a price scale on a chart
   CHART_PROP_SHOW_ONE_CLICK,                         // Display the quick trading panel on the chart
   CHART_PROP_IS_MAXIMIZED,                           // Chart window maximized
   CHART_PROP_IS_MINIMIZED,                           // Chart window minimized
   CHART_PROP_IS_DOCKED,                              // Chart window docked
   CHART_PROP_FLOAT_LEFT,                             // Left coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_FLOAT_TOP,                              // Upper coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_FLOAT_RIGHT,                            // Right coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_FLOAT_BOTTOM,                           // Bottom coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_YDISTANCE,                              // Distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   CHART_PROP_HEIGHT_IN_PIXELS,                       // Height of the chart in pixels
   CHART_PROP_WINDOW_IND_HANDLE,                      // Indicator handle on the chart
   CHART_PROP_WINDOW_IND_INDEX,                       // Indicator index on the chart
  };
#define CHART_PROP_INTEGER_TOTAL (66)                 // Total number of integer properties
#define CHART_PROP_INTEGER_SKIP  (2)                  // Number of integer properties not used in sorting
//+------------------------------------------------------------------+
//| Chart real properties                                            |
//+------------------------------------------------------------------+
enum ENUM_CHART_PROP_DOUBLE
  {
   CHART_PROP_SHIFT_SIZE = CHART_PROP_INTEGER_TOTAL,  // Shift size of the zero bar from the right border in %
   CHART_PROP_FIXED_POSITION,                         // Chart fixed position from the left border in %
   CHART_PROP_FIXED_MAX,                              // Chart fixed maximum
   CHART_PROP_FIXED_MIN,                              // Chart fixed minimum
   CHART_PROP_POINTS_PER_BAR,                         // Scale in points per bar
   CHART_PROP_PRICE_MIN,                              // Chart minimum
   CHART_PROP_PRICE_MAX,                              // Chart maximum
  };
#define CHART_PROP_DOUBLE_TOTAL  (7)                  // Total number of real properties
#define CHART_PROP_DOUBLE_SKIP   (0)                  // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| Chart string properties                                          |
//+------------------------------------------------------------------+
enum ENUM_CHART_PROP_STRING
  {
   CHART_PROP_COMMENT = (CHART_PROP_INTEGER_TOTAL+CHART_PROP_DOUBLE_TOTAL), // Chart comment text
   CHART_PROP_EXPERT_NAME,                            // Name of an EA launched on the chart
   CHART_PROP_SCRIPT_NAME,                            // Name of a script launched on the chart
   CHART_PROP_INDICATOR_NAME,                         // Name of the indicator launched in the chart window
   CHART_PROP_SYMBOL,                                 // Chart symbol
  };
#define CHART_PROP_STRING_TOTAL  (5)                  // Total number of string properties
//+------------------------------------------------------------------+
//| Possible chart sorting criteria                                  |
//+------------------------------------------------------------------+
#define FIRST_CHART_DBL_PROP  (CHART_PROP_INTEGER_TOTAL-CHART_PROP_INTEGER_SKIP)
#define FIRST_CHART_STR_PROP  (CHART_PROP_INTEGER_TOTAL-CHART_PROP_INTEGER_SKIP+CHART_PROP_DOUBLE_TOTAL-CHART_PROP_DOUBLE_SKIP)
enum ENUM_SORT_CHART_MODE
  {
//--- Sort by integer properties
   SORT_BY_CHART_ID = 0,                              // Sort by chart ID
   SORT_BY_CHART_TIMEFRAME,                           // Sort by chart timeframe
   SORT_BY_CHART_SHOW,                                // Sort by the price chart drawing attribute
   SORT_BY_CHART_IS_OBJECT,                           // Sort by chart object (OBJ_CHART) identification attribute
   SORT_BY_CHART_BRING_TO_TOP,                        // Sort by the flag of displaying a chart above all others
   SORT_BY_CHART_CONTEXT_MENU,                        // Sort by the flag of enabling/disabling access to the context menu using the right click
   SORT_BY_CHART_CROSSHAIR_TOO,                       // Sort by the flag of enabling/disabling access to the Crosshair tool using the middle click
   SORT_BY_CHART_MOUSE_SCROLL,                        // Sort by the flag of scrolling the chart horizontally using the left mouse button
   SORT_BY_CHART_EVENT_MOUSE_WHEEL,                   // Sort by the flag of sending messages about mouse wheel events to all MQL5 programs on a chart
   SORT_BY_CHART_EVENT_MOUSE_MOVE,                    // Sort by the flag of sending messages about mouse button click and movement events to all MQL5 programs on a chart
   SORT_BY_CHART_EVENT_OBJECT_CREATE,                 // Sort by the flag of sending messages about the graphical object creation event to all MQL5 programs on a chart
   SORT_BY_CHART_EVENT_OBJECT_DELETE,                 // Sort by the flag of sending messages about the graphical object destruction event to all MQL5 programs on a chart
   SORT_BY_CHART_MODE,                                // Sort by chart type
   SORT_BY_CHART_FOREGROUND,                          // Sort by the "Price chart in the foreground" flag
   SORT_BY_CHART_SHIFT,                               // Sort by the "Mode of shift of the price chart from the right border" flag
   SORT_BY_CHART_AUTOSCROLL,                          // Sort by the "The mode of automatic shift to the right border of the chart" flag
   SORT_BY_CHART_KEYBOARD_CONTROL,                    // Sort by the flag allowing the chart management using a keyboard
   SORT_BY_CHART_QUICK_NAVIGATION,                    // Sort by the flag allowing the chart to intercept Space and Enter key strokes to activate the quick navigation bar
   SORT_BY_CHART_SCALE,                               // Sort by scale
   SORT_BY_CHART_SCALEFIX,                            // Sort by the fixed scale flag
   SORT_BY_CHART_SCALEFIX_11,                         // Sort by the 1:1 scale flag
   SORT_BY_CHART_SCALE_PT_PER_BAR,                    // Sort by the flag of specifying the scale in points per bar
   SORT_BY_CHART_SHOW_TICKER,                         // Sort by the flag displaying a symbol ticker in the upper left corner
   SORT_BY_CHART_SHOW_OHLC,                           // Sort by the flag displaying OHLC values in the upper left corner
   SORT_BY_CHART_SHOW_BID_LINE,                       // Sort by the flag displaying Bid value as a horizontal line on the chart
   SORT_BY_CHART_SHOW_ASK_LINE,                       // Sort by the flag displaying Ask value as a horizontal line on the chart
   SORT_BY_CHART_SHOW_LAST_LINE,                      // Sort by the flag displaying Last value as a horizontal line on the chart
   SORT_BY_CHART_SHOW_PERIOD_SEP,                     // Sort by the flag displaying vertical separators between adjacent periods
   SORT_BY_CHART_SHOW_GRID,                           // Sort by the flag of displaying a grid on the chart
   SORT_BY_CHART_SHOW_VOLUMES,                        // Sort by the mode of displaying volumes on a chart
   SORT_BY_CHART_SHOW_OBJECT_DESCR,                   // Sort by the flag of displaying object text descriptions
   SORT_BY_CHART_VISIBLE_BARS,                        // Sort by the number of bars on a chart that are available for display
   SORT_BY_CHART_WINDOWS_TOTAL,                       // Sort by the total number of chart windows including indicator subwindows
   SORT_BY_CHART_WINDOW_HANDLE,                       // Sort by the chart handle
   SORT_BY_CHART_FIRST_VISIBLE_BAR,                   // Sort by the number of the first visible bar on the chart
   SORT_BY_CHART_WIDTH_IN_BARS,                       // Sort by the width of the chart in bars
   SORT_BY_CHART_WIDTH_IN_PIXELS,                     // Sort by the width of the chart in pixels
   SORT_BY_CHART_COLOR_BACKGROUND,                    // Sort by the color of the chart background
   SORT_BY_CHART_COLOR_FOREGROUND,                    // Sort by color of axes, scale and OHLC line
   SORT_BY_CHART_COLOR_GRID,                          // Sort by grid color
   SORT_BY_CHART_COLOR_VOLUME,                        // Sort by the color of volumes and position opening levels
   SORT_BY_CHART_COLOR_CHART_UP,                      // Sort by the color for the up bar, shadows and body borders of bull candlesticks
   SORT_BY_CHART_COLOR_CHART_DOWN,                    // Sort by the color of down bar, its shadow and border of body of the bullish candlestick
   SORT_BY_CHART_COLOR_CHART_LINE,                    // Sort by the color of the chart line and the Doji candlesticks
   SORT_BY_CHART_COLOR_CANDLE_BULL,                   // Sort by the color of a bullish candlestick body
   SORT_BY_CHART_COLOR_CANDLE_BEAR,                   // Sort by the color of a bearish candlestick body
   SORT_BY_CHART_COLOR_BID,                           // Sort by the color of the Bid price line
   SORT_BY_CHART_COLOR_ASK,                           // Sort by the color of the Ask price line
   SORT_BY_CHART_COLOR_LAST,                          // Sort by the color of the last performed deal's price line (Last)
   SORT_BY_CHART_COLOR_STOP_LEVEL,                    // Sort by the color of stop order levels (Stop Loss and Take Profit)
   SORT_BY_CHART_SHOW_TRADE_LEVELS,                   // Sort by the flag of displaying trading levels on the chart
   SORT_BY_CHART_DRAG_TRADE_LEVELS,                   // Sort by the flag enabling the ability to drag trading levels on a chart using mouse
   SORT_BY_CHART_SHOW_DATE_SCALE,                     // Sort by the flag of displaying the time scale on the chart
   SORT_BY_CHART_SHOW_PRICE_SCALE,                    // Sort by the flag of displaying the price scale on the chart
   SORT_BY_CHART_SHOW_ONE_CLICK,                      // Sort by the flag of displaying the quick trading panel on the chart
   SORT_BY_CHART_IS_MAXIMIZED,                        // Sort by the "Chart window maximized" flag
   SORT_BY_CHART_IS_MINIMIZED,                        // Sort by the "Chart window minimized" flag
   SORT_BY_CHART_IS_DOCKED,                           // Sort by the "Chart window docked" flag
   SORT_BY_CHART_FLOAT_LEFT,                          // Sort by the left coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_FLOAT_TOP,                           // Sort by the upper coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_FLOAT_RIGHT,                         // Sort by the right coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_FLOAT_BOTTOM,                        // Sort by the bottom coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_YDISTANCE,                           // Sort by the distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   SORT_BY_CHART_HEIGHT_IN_PIXELS,                    // Sort by the height of the chart in pixels
//--- Sort by real properties
   SORT_BY_CHART_SHIFT_SIZE = FIRST_CHART_DBL_PROP,   // Sort by the shift size of the zero bar from the right border in %
   SORT_BY_CHART_FIXED_POSITION,                      // Sort by the chart fixed position from the left border in %
   SORT_BY_CHART_FIXED_MAX,                           // Sort by the fixed chart maximum
   SORT_BY_CHART_FIXED_MIN,                           // Sort by the fixed chart minimum
   SORT_BY_CHART_POINTS_PER_BAR,                      // Sort by the scale value in points per bar
   SORT_BY_CHART_PRICE_MIN,                           // Sort by the chart minimum
   SORT_BY_CHART_PRICE_MAX,                           // Sort by the chart maximum
//--- Sort by string properties
   SORT_BY_CHART_COMMENT = FIRST_CHART_STR_PROP,      // Sort by a comment text on the chart
   SORT_BY_CHART_EXPERT_NAME,                         // Sort by a name of an EA launched on the chart
   SORT_BY_CHART_SCRIPT_NAME,                         // Sort by a name of a script launched on the chart
   SORT_BY_CHART_INDICATOR_NAME,                      // Sort by a name of an indicator launched in the chart window
   SORT_BY_CHART_SYMBOL,                              // Sort by chart symbol
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for handling chart windows                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Chart window integer properties                                  |
//+------------------------------------------------------------------+
enum ENUM_CHART_WINDOW_PROP_INTEGER
  {
   CHART_WINDOW_PROP_ID = 0,                          // Chart ID
   CHART_WINDOW_PROP_WINDOW_NUM,                      // Chart window index
   CHART_WINDOW_PROP_YDISTANCE,                       // Distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   CHART_WINDOW_PROP_HEIGHT_IN_PIXELS,                // Height of the chart in pixels
   //--- for CWndInd
   CHART_WINDOW_PROP_WINDOW_IND_HANDLE,               // Indicator handle in the chart window
   CHART_WINDOW_PROP_WINDOW_IND_INDEX,                // Indicator index in the chart window
  };
#define CHART_WINDOW_PROP_INTEGER_TOTAL (6)           // Total number of integer properties
#define CHART_WINDOW_PROP_INTEGER_SKIP  (0)           // Number of integer DOM properties not used in sorting
//+------------------------------------------------------------------+
//| Chart window real properties                                     |
//+------------------------------------------------------------------+
enum ENUM_CHART_WINDOW_PROP_DOUBLE
  {
   CHART_WINDOW_PROP_PRICE_MIN = CHART_WINDOW_PROP_INTEGER_TOTAL, // Chart minimum
   CHART_WINDOW_PROP_PRICE_MAX,                       // Chart maximum
  };
#define CHART_WINDOW_PROP_DOUBLE_TOTAL  (2)           // Total number of real properties
#define CHART_WINDOW_PROP_DOUBLE_SKIP   (0)           // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| Chart window string properties                                   |
//+------------------------------------------------------------------+
enum ENUM_CHART_WINDOW_PROP_STRING
  {
   CHART_WINDOW_PROP_IND_NAME = (CHART_WINDOW_PROP_INTEGER_TOTAL+CHART_WINDOW_PROP_DOUBLE_TOTAL), // Name of the indicator launched in the window
   CHART_WINDOW_PROP_SYMBOL,                          // Chart symbol
  };
#define CHART_WINDOW_PROP_STRING_TOTAL  (2)           // Total number of string properties
//+------------------------------------------------------------------+
//| Possible criteria of sorting chart windows                       |
//+------------------------------------------------------------------+
#define FIRST_CHART_WINDOW_DBL_PROP  (CHART_WINDOW_PROP_INTEGER_TOTAL-CHART_WINDOW_PROP_INTEGER_SKIP)
#define FIRST_CHART_WINDOW_STR_PROP  (CHART_WINDOW_PROP_INTEGER_TOTAL-CHART_WINDOW_PROP_INTEGER_SKIP+CHART_WINDOW_PROP_DOUBLE_TOTAL-CHART_WINDOW_PROP_DOUBLE_SKIP)
enum ENUM_SORT_CHART_WINDOW_MODE
  {
//--- Sort by integer properties
   SORT_BY_CHART_WINDOW_ID = 0,                       // Sort by chart ID
   SORT_BY_CHART_WINDOW_NUM,                          // Sort by chart window index
   SORT_BY_CHART_WINDOW_YDISTANCE,                    // Sort by the distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   SORT_BY_CHART_WINDOW_HEIGHT_IN_PIXELS,             // Sort by the height of the chart in pixels
   SORT_BY_CHART_WINDOW_IND_HANDLE,                   // Sort by the indicator handle in the chart window
   SORT_BY_CHART_WINDOW_IND_INDEX,                    // Sort by the indicator index in the chart window
//--- Sort by real properties
   SORT_BY_CHART_WINDOW_PRICE_MIN = FIRST_CHART_WINDOW_DBL_PROP,  // Sort by chart window minimum
   SORT_BY_CHART_WINDOW_PRICE_MAX,                    // Sort by chart window maximum
//--- Sort by string properties
   SORT_BY_CHART_WINDOW_IND_NAME = FIRST_CHART_WINDOW_STR_PROP,   // Sort by name of an indicator launched in the window
   SORT_BY_CHART_WINDOW_SYMBOL,                       // Sort by chart symbol
  };
//+------------------------------------------------------------------+

#endif // __CHART_DEFINES_MQH__