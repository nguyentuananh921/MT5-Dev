//+------------------------------------------------------------------+
//|                                             TimeseriesDefines.mqh
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __TIMESERIES_DEFINES_MQH__
#define __TIMESERIES_DEFINES_MQH__
#include "EventDefines.mqh"
//| Info for working with serial data                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bar type (candle body)                                           |
//+------------------------------------------------------------------+
enum ENUM_BAR_BODY_TYPE
  {
   BAR_BODY_TYPE_BULLISH,                                   // Bullish bar
   BAR_BODY_TYPE_BEARISH,                                   // Bearish bar
   BAR_BODY_TYPE_NULL,                                      // Zero bar
   BAR_BODY_TYPE_CANDLE_ZERO_BODY,                          // Candle with a zero body
  };
//+------------------------------------------------------------------+
//| Bar integer properties                                           |
//+------------------------------------------------------------------+
enum ENUM_BAR_PROP_INTEGER
    {
    BAR_PROP_TIME = 0,                                       // Bar period start time
    BAR_PROP_TYPE,                                           // Bar type (from the ENUM_BAR_BODY_TYPE enumeration)
    BAR_PROP_PERIOD,                                         // Bar period (timeframe)
    BAR_PROP_SPREAD,                                         // Bar spread
    BAR_PROP_VOLUME_TICK,                                    // Bar tick volume
    BAR_PROP_VOLUME_REAL,                                    // Bar exchange volume
    BAR_PROP_TIME_DAY_OF_YEAR,                               // Bar day serial number in a year
    BAR_PROP_TIME_YEAR,                                      // A year the bar belongs to
    BAR_PROP_TIME_MONTH,                                     // A month the bar belongs to
    BAR_PROP_TIME_DAY_OF_WEEK,                               // Bar week day
    BAR_PROP_TIME_DAY,                                       // Bar day of month (number)
    BAR_PROP_TIME_HOUR,                                      // Bar hour
    BAR_PROP_TIME_MINUTE,                                    // Bar minute
    BAR_PROP_PATTERNS_TYPE,                                  // Pattern types on the bar (pattern flags from the ENUM_PATTERN_TYPE enumeration)
  }; 
#define BAR_PROP_INTEGER_TOTAL (14)                         // Total number of integer bar properties
#define BAR_PROP_INTEGER_SKIP  (0)                          // Number of bar properties not used in sorting
//+------------------------------------------------------------------+
//| Real bar properties                                              |
//+------------------------------------------------------------------+
enum ENUM_BAR_PROP_DOUBLE
  {
    //--- bar data
      BAR_PROP_OPEN = BAR_PROP_INTEGER_TOTAL,                  // Bar open price
      BAR_PROP_HIGH,                                           // Highest price for the bar period
      BAR_PROP_LOW,                                            // Lowest price for the bar period
      BAR_PROP_CLOSE,                                          // Bar close price
    //--- candle data
      BAR_PROP_CANDLE_SIZE,                                    // Candle size
      BAR_PROP_CANDLE_SIZE_BODY,                               // Candle body size
      BAR_PROP_CANDLE_BODY_TOP,                                // Candle body top
      BAR_PROP_CANDLE_BODY_BOTTOM,                             // Candle body bottom
      BAR_PROP_CANDLE_SIZE_SHADOW_UP,                          // Candle upper wick size
      BAR_PROP_CANDLE_SIZE_SHADOW_DOWN,                        // Candle lower wick size
    //--- candle proportions
      BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      // Percentage ratio of the candle body to the full size of the candle
      BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              // Percentage ratio of the upper shadow size to the candle size
      BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              // Percentage ratio of the lower shadow size to the candle size
  }; 
#define BAR_PROP_DOUBLE_TOTAL  (13)                         // Total number of real bar properties
#define BAR_PROP_DOUBLE_SKIP   (0)                          // Number of bar properties not used in sorting
//+------------------------------------------------------------------+
//| Bar string properties                                            |
//+------------------------------------------------------------------+
enum ENUM_BAR_PROP_STRING
  {
   BAR_PROP_SYMBOL = (BAR_PROP_INTEGER_TOTAL+BAR_PROP_DOUBLE_TOTAL), // Bar symbol
  };
#define BAR_PROP_STRING_TOTAL  (1)                          // Total number of string bar properties
//+------------------------------------------------------------------+
//| Possible bar sorting criteria                                    |
//+------------------------------------------------------------------+
#define FIRST_BAR_DBL_PROP          (BAR_PROP_INTEGER_TOTAL-BAR_PROP_INTEGER_SKIP)
#define FIRST_BAR_STR_PROP          (BAR_PROP_INTEGER_TOTAL-BAR_PROP_INTEGER_SKIP+BAR_PROP_DOUBLE_TOTAL-BAR_PROP_DOUBLE_SKIP)
enum ENUM_SORT_BAR_MODE
 {
  //--- Sort by integer properties
    SORT_BY_BAR_TIME = 0,                                    // Sort by bar period start time
    SORT_BY_BAR_TYPE,                                        // Sort by bar type (from the ENUM_BAR_BODY_TYPE enumeration)
    SORT_BY_BAR_PERIOD,                                      // Sort by bar period (timeframe)
    SORT_BY_BAR_SPREAD,                                      // Sort by bar spread
    SORT_BY_BAR_VOLUME_TICK,                                 // Sort by bar tick volume
    SORT_BY_BAR_VOLUME_REAL,                                 // Sort by bar exchange volume
    SORT_BY_BAR_TIME_DAY_OF_YEAR,                            // Sort by bar day number in a year
    SORT_BY_BAR_TIME_YEAR,                                   // Sort by a year the bar belongs to
    SORT_BY_BAR_TIME_MONTH,                                  // Sort by a month the bar belongs to
    SORT_BY_BAR_TIME_DAY_OF_WEEK,                            // Sort by a bar week day
    SORT_BY_BAR_TIME_DAY,                                    // Sort by a bar day
    SORT_BY_BAR_TIME_HOUR,                                   // Sort by a bar hour
    SORT_BY_BAR_TIME_MINUTE,                                 // Sort by a bar minute
    SORT_BY_BAR_PATTERN_TYPE,                                // Sort by pattern types on the bar (pattern flags from the ENUM_PATTERN_TYPE enumeration)
  //--- Sort by real properties
    SORT_BY_BAR_OPEN = FIRST_BAR_DBL_PROP,                   // Sort by bar open price
    SORT_BY_BAR_HIGH,                                        // Sort by the highest price for the bar period
    SORT_BY_BAR_LOW,                                         // Sort by the lowest price for the bar period
    SORT_BY_BAR_CLOSE,                                       // Sort by a bar close price
    SORT_BY_BAR_CANDLE_SIZE,                                 // Sort by a candle price
    SORT_BY_BAR_CANDLE_SIZE_BODY,                            // Sort by a candle body size
    SORT_BY_BAR_CANDLE_BODY_TOP,                             // Sort by a candle body top
    SORT_BY_BAR_CANDLE_BODY_BOTTOM,                          // Sort by a candle body bottom
    SORT_BY_BAR_CANDLE_SIZE_SHADOW_UP,                       // Sort by candle upper wick size
    SORT_BY_BAR_CANDLE_SIZE_SHADOW_DOWN,                     // Sort by candle lower wick size
  //--- Sort by string properties
    SORT_BY_BAR_SYMBOL = FIRST_BAR_STR_PROP,                 // Sort by a bar symbol
 };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract pattern status                                          |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_STATUS
  {
   PATTERN_STATUS_JC,                                       // Candles
   PATTERN_STATUS_PA,                                       // Price Action formations
  };
//+------------------------------------------------------------------+
//| Pattern type by direction (buy/sell)                             |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_DIRECTION
  {
   PATTERN_DIRECTION_BULLISH,                               // Buy pattern
   PATTERN_DIRECTION_BEARISH,                               // Sell pattern
   PATTERN_DIRECTION_BOTH,                                  // Bidirectional pattern
  };
//+------------------------------------------------------------------+
//| Pattern type                                                     |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_TYPE
 {
  //--- Candle formations
    PATTERN_TYPE_NONE                =  0x0,                 // None
    //Single Candlestick Patterns
      PATTERN_TYPE_SHOOTING_STAR       =  0x80,                // Shooting Star
      PATTERN_TYPE_HAMMER              =  0x100,               // Hammer
      PATTERN_TYPE_INVERTED_HAMMER     =  0x200,               // Inverted Hammer
      PATTERN_TYPE_HANGING_MAN         =  0x400,               // Hanging Man
      PATTERN_TYPE_DOJI                =  0x800,               // Doji
      PATTERN_TYPE_DRAGONFLY_DOJI      =  0x1000,              // Dragonfly Doji
      PATTERN_TYPE_GRAVESTONE_DOJI     =  0x2000,              // Gravestone Doji
    //Double Candlestick Patterns
      PATTERN_TYPE_HARAMI              =  0x1,                 // Harami
      PATTERN_TYPE_HARAMI_CROSS        =  0x2,                 // Harami Cross
      PATTERN_TYPE_TWEEZER             =  0x4,                 // Tweezer
      PATTERN_TYPE_PIERCING_LINE       =  0x8,                 // Piercing Line
      PATTERN_TYPE_DARK_CLOUD_COVER    =  0x10,                // Dark Cloud Cover
      PATTERN_TYPE_ENGULFING           =  0x8000000,           // Engulfing  
    //Triple Candlestick Patterns
      PATTERN_TYPE_THREE_WHITE_SOLDIERS=  0x20,                // Three White Soldiers
      PATTERN_TYPE_THREE_BLACK_CROWS   =  0x40,                // Three Black Crows    
      PATTERN_TYPE_MORNING_STAR        =  0x4000,              // Morning Star
      PATTERN_TYPE_MORNING_DOJI_STAR   =  0x8000,              // Morning Doji Star
      PATTERN_TYPE_EVENING_STAR        =  0x10000,             // Evening Star
      PATTERN_TYPE_EVENING_DOJI_STAR   =  0x20000,             // Evening Doji Star
      PATTERN_TYPE_THREE_STARS         =  0x40000,             // Three Stars
      PATTERN_TYPE_ABANDONED_BABY      =  0x80000,             // Abandoned Baby      
      PATTERN_TYPE_THREE_INSIDE_UP     =  0x2000000,           // Three Inside Up
      PATTERN_TYPE_THREE_INSIDE_DOWN   =  0x4000000,           // Three Inside Down 
  //--- Price Action    
    //Single Price Action Candlestick Patterns
      PATTERN_TYPE_PIN_BAR             =  0x800000,            // Price Action Pin Bar
    //Double Price Action Candlestick Patterns
      PATTERN_TYPE_OUTSIDE_BAR         =  0x200000,            // Price Action Outside Bar
      PATTERN_TYPE_INSIDE_BAR          =  0x400000,            // Price Action Inside Bar    
      PATTERN_TYPE_RAILS               =  0x1000000,           // Price Action Rails
    //Triple PA (3 candles)
      PATTERN_TYPE_PIVOT_POINT_REVERSAL= 0x100000
   
 };
#define PATTERNS_TOTAL              (29)                    // Total number of patterns (including the missing one)
//+------------------------------------------------------------------+
//| Pattern integer properties                                       |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_PROP_INTEGER
  {
   PATTERN_PROP_CODE = 0,                                   // Unique pattern code (time + type + status + direction + timeframe + symbol)
   PATTERN_PROP_CTRL_OBJ_ID,                                // Pattern control object ID
   PATTERN_PROP_ID,                                         // Pattern ID
   PATTERN_PROP_TIME,                                       // Pattern defining bar time
   PATTERN_PROP_MOTHERBAR_TIME,                             // Pattern mother bar time
   PATTERN_PROP_STATUS,                                     // Pattern status (from the ENUM_PATTERN_STATUS enumeration)
   PATTERN_PROP_TYPE,                                       // Pattern type (from the ENUM_PATTERN_TYPE enumeration)
   PATTERN_PROP_DIRECTION,                                  // Pattern type by direction (from the ENUM_PATTERN_TYPE_DIRECTION enumeration)
   PATTERN_PROP_PERIOD,                                     // Pattern period (timeframe)
   PATTERN_PROP_CANDLES,                                    // Number of candles that make up the pattern
  }; 
#define PATTERN_PROP_INTEGER_TOTAL (10)                     // Total number of integer pattern properties
#define PATTERN_PROP_INTEGER_SKIP  (0)                      // Number of pattern properties not used in sorting
//+------------------------------------------------------------------+
//| Pattern real properties                                          |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_PROP_DOUBLE
  {
//--- bar data
   PATTERN_PROP_BAR_PRICE_OPEN = PATTERN_PROP_INTEGER_TOTAL,// Pattern defining bar Open price
   PATTERN_PROP_BAR_PRICE_HIGH,                             // Pattern defining bar High price
   PATTERN_PROP_BAR_PRICE_LOW,                              // Pattern defining bar Low price
   PATTERN_PROP_BAR_PRICE_CLOSE,                            // Pattern defining bar Close price
   PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE,                  // Percentage ratio of the candle body to the full size of the candle
   PATTERN_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,          // Percentage ratio of the upper shadow size to the candle size
   PATTERN_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,          // Percentage ratio of the lower shadow size to the candle size
   PATTERN_PROP_RATIO_CANDLE_SIZES,                         // Ratio of pattern candle sizes
   
   PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           // Defined criterion of the ratio of the candle body to the full candle size in %
   PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  // Defined criterion of the ratio of the maximum shadow to the candle size in %
   PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION, // Defined criterion of the ratio of the minimum shadow to the candle size in %
   PATTERN_PROP_RATIO_CANDLE_SIZES_CRITERION,               // Defined criterion for the ratio of pattern candle sizes
  }; 
#define PATTERN_PROP_DOUBLE_TOTAL   (12)                    // Total number of real pattern properties
#define PATTERN_PROP_DOUBLE_SKIP    (0)                     // Number of pattern properties not used in sorting
//+------------------------------------------------------------------+
//| Pattern string properties                                        |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_PROP_STRING
  {
   PATTERN_PROP_SYMBOL = (PATTERN_PROP_INTEGER_TOTAL+PATTERN_PROP_DOUBLE_TOTAL),  // Pattern symbol
   PATTERN_PROP_NAME,                                       // Pattern name
  };
#define PATTERN_PROP_STRING_TOTAL   (2)                     // Total number of pattern string properties
//+------------------------------------------------------------------+
//| Possible pattern sorting criteria                                |
//+------------------------------------------------------------------+
#define FIRST_PATTERN_DBL_PROP      (PATTERN_PROP_INTEGER_TOTAL-PATTERN_PROP_INTEGER_SKIP)
#define FIRST_PATTERN_STR_PROP      (PATTERN_PROP_INTEGER_TOTAL-PATTERN_PROP_INTEGER_SKIP+PATTERN_PROP_DOUBLE_TOTAL-PATTERN_PROP_DOUBLE_SKIP)
enum ENUM_SORT_PATTERN_MODE
  {
    //--- Sort by integer properties
      SORT_BY_PATTERN_CODE = 0,                                // Sort by unique pattern code (time + type + status + direction + timeframe)
      SORT_BY_PATTERN_CTRL_OBJ_ID,                             // Sort by pattern control object ID
      SORT_BY_PATTERN_ID,                                      // Sort by pattern ID
      SORT_BY_PATTERN_TIME,                                    // Sort by pattern defining bar time
      SORT_BY_PATTERN_MOTHERBAR_TIME,                          // Sort by pattern mother bar time
      SORT_BY_PATTERN_STATUS,                                  // Sort by pattern status (from the ENUM_PATTERN_STATUS enumeration)
      SORT_BY_PATTERN_TYPE,                                    // Sort by pattern type (from the ENUM_PATTERN_TYPE enumeration)
      SORT_BY_PATTERN_DIRECTION,                               // Sort by pattern type based on direction (from the ENUM_PATTERN_TYPE_DIRECTION enumeration)
      SORT_BY_PATTERN_PERIOD,                                  // Sort by pattern period (timeframe)
      SORT_BY_PATTERN_CANDLES,                                 // Sort by the number of candles that make up the pattern
      
    //--- Sort by real properties
      SORT_BY_PATTERN_BAR_PRICE_OPEN = FIRST_PATTERN_DBL_PROP, // Sort by pattern defining bar Open price
      SORT_BY_PATTERN_BAR_PRICE_HIGH,                          // Sort by pattern defining bar High price
      SORT_BY_PATTERN_BAR_PRICE_LOW,                           // Sort by pattern defining bar Low price
      SORT_BY_PATTERN_BAR_PRICE_CLOSE,                         // Sort by pattern defining bar Close price
      SORT_BY_PATTERN_RATIO_BODY_TO_CANDLE_SIZE,               // Sort by percentage ratio of the candle body to the full size of the candle
      SORT_BY_PATTERN_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,       // Sort by percentage ratio of the upper shadow size to the candle size
      SORT_BY_PATTERN_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,       // Sort by percentage ratio of the lower shadow size to the candle size
      SORT_BY_PATTERN_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           // Sort by defined criterion of the ratio of the candle body to the full candle size in %
      SORT_BY_PATTERN_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  // Sort by  defined criterion of the ratio of the maximum shadow to the candle size in %
      SORT_BY_PATTERN_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION, // Sort by  defined criterion of the ratio of the minimum shadow to the candle size in %
      
    //--- Sort by string properties
      SORT_BY_PATTERN_SYMBOL = FIRST_BAR_STR_PROP,             // Sort by a pattern symbol
      SORT_BY_PATTERN_NAME,                                    // Sort by pattern name
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with indicator buffers                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract buffer status (by drawing style)                        |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_STATUS
  {
   BUFFER_STATUS_NONE,                                      // No drawing
   BUFFER_STATUS_FILLING,                                   // Color filling between two levels (MQL5)
   BUFFER_STATUS_LINE,                                      // Line
   BUFFER_STATUS_HISTOGRAM,                                 // Histogram from the zero line
   BUFFER_STATUS_ARROW,                                     // Drawing with arrows
   BUFFER_STATUS_SECTION,                                   // Section
   BUFFER_STATUS_HISTOGRAM2,                                // Histogram on two indicator buffers
   BUFFER_STATUS_ZIGZAG,                                    // Zigzag style
   BUFFER_STATUS_BARS,                                      // Display as bars (MQL5)
   BUFFER_STATUS_CANDLES,                                   // Display as candles (MQL5)
  };
//+------------------------------------------------------------------+
//| Buffer type                                                      |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_TYPE
  {
   BUFFER_TYPE_CALCULATE,                                   // Calculated buffer
   BUFFER_TYPE_DATA,                                        // Colored data buffer
  };
//+------------------------------------------------------------------+
//| Values of indicator lines in enumeration                         |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_LINE_MODE
  {
   INDICATOR_LINE_MODE_MAIN         =  0,                   // Main line
   INDICATOR_LINE_MODE_SIGNAL       =  1,                   // Signal line
   INDICATOR_LINE_MODE_UPPER        =  0,                   // Upper line
   INDICATOR_LINE_MODE_LOWER        =  1,                   // Lower line
   INDICATOR_LINE_MODE_MIDDLE       =  2,                   // Middle line
   INDICATOR_LINE_MODE_JAWS         =  0,                   // Jaws line
   INDICATOR_LINE_MODE_TEETH        =  1,                   // Teeth line
   INDICATOR_LINE_MODE_LIPS         =  2,                   // Lips line
   INDICATOR_LINE_MODE_DI_PLUS      =  1,                   // +DI line
   INDICATOR_LINE_MODE_DI_MINUS     =  2,                   // -DI line
   INDICATOR_LINE_MODE_TENKAN_SEN   =  0,                   // Tenkan-sen line
   INDICATOR_LINE_MODE_KIJUN_SEN    =  1,                   // Kijun-sen line
   INDICATOR_LINE_MODE_SENKOU_SPANA =  2,                   // Senkou Span A line
   INDICATOR_LINE_MODE_SENKOU_SPANB =  3,                   // Senkou Span B line
   INDICATOR_LINE_MODE_CHIKOU_SPAN  =  4,                   // Chikou Span line
   INDICATOR_LINE_MODE_ADDITIONAL   =  5,                   // Additional line
  };
//+------------------------------------------------------------------+
//| Enumeration of indicator lines                                   |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_LINE
  {
   INDICATOR_LINE_MAIN,                                     // Main line
   INDICATOR_LINE_SIGNAL,                                   // Signal line
   INDICATOR_LINE_UPPER,                                    // Upper line
   INDICATOR_LINE_LOWER,                                    // Lower line
   INDICATOR_LINE_MIDDLE,                                   // Middle line
   INDICATOR_LINE_JAWS,                                     // Jaws line
   INDICATOR_LINE_TEETH,                                    // Teeth line
   INDICATOR_LINE_LIPS,                                     // Lips line
   INDICATOR_LINE_DI_PLUS,                                  // +DI line
   INDICATOR_LINE_DI_MINUS,                                 // -DI line
   INDICATOR_LINE_TENKAN_SEN,                               // Tenkan-sen line
   INDICATOR_LINE_KIJUN_SEN,                                // Kijun-sen line
   INDICATOR_LINE_SENKOU_SPANA,                             // Senkou Span A line
   INDICATOR_LINE_SENKOU_SPANB,                             // Senkou Span B line
   INDICATOR_LINE_CHIKOU_SPAN,                              // Chikou Span line
   INDICATOR_LINE_ADDITIONAL,                               // Additional line
  };
//+------------------------------------------------------------------+
//| Buffer integer properties                                        |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_PROP_INTEGER
  {
   BUFFER_PROP_INDEX_PLOT = 0,                              // Plotted buffer serial number
   BUFFER_PROP_STATUS,                                      // Buffer status (by drawing style) from the ENUM_BUFFER_STATUS enumeration
   BUFFER_PROP_TYPE,                                        // Buffer type (from the ENUM_BUFFER_TYPE enumeration)
   BUFFER_PROP_TIMEFRAME,                                   // Buffer period data (timeframe)
   BUFFER_PROP_ACTIVE,                                      // Buffer usage flag
   BUFFER_PROP_DRAW_TYPE,                                   // Graphical construction type (from the ENUM_DRAW_TYPE enumeration)
   BUFFER_PROP_ARROW_CODE,                                  // Arrow code for DRAW_ARROW style
   BUFFER_PROP_ARROW_SHIFT,                                 // The vertical shift of the arrows for DRAW_ARROW style
   BUFFER_PROP_LINE_STYLE,                                  // Line style
   BUFFER_PROP_LINE_WIDTH,                                  // Line width
   BUFFER_PROP_DRAW_BEGIN,                                  // The number of initial bars that are not drawn and values in DataWindow
   BUFFER_PROP_SHOW_DATA,                                   // Flag of displaying construction values in DataWindow
   BUFFER_PROP_SHIFT,                                       // Indicator graphical construction shift by time axis in bars
   BUFFER_PROP_COLOR_INDEXES,                               // Number of colors
   BUFFER_PROP_COLOR,                                       // Drawing color
   BUFFER_PROP_INDEX_BASE,                                  // Base data buffer index
   BUFFER_PROP_INDEX_NEXT_BASE,                             // Index of the array to be assigned as the next indicator buffer
   BUFFER_PROP_INDEX_NEXT_PLOT,                             // Index of the next drawn buffer
   BUFFER_PROP_ID,                                          // ID of multiple buffers of a single indicator
   BUFFER_PROP_IND_LINE_MODE,                               // Indicator line
   BUFFER_PROP_IND_HANDLE,                                  // Handle of an indicator using a buffer
   BUFFER_PROP_IND_TYPE,                                    // Type of an indicator using a buffer
   BUFFER_PROP_IND_LINE_ADDITIONAL_NUM,                     // Number of indicator additional line
   BUFFER_PROP_NUM_DATAS,                                   // Number of data buffers
   BUFFER_PROP_INDEX_COLOR,                                 // Color buffer index
  }; 
#define BUFFER_PROP_INTEGER_TOTAL (25)                      // Total number of integer bar properties
#define BUFFER_PROP_INTEGER_SKIP  (2)                       // Number of buffer properties not used in sorting
//+------------------------------------------------------------------+
//| Buffer real properties                                           |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_PROP_DOUBLE
  {
   BUFFER_PROP_EMPTY_VALUE = BUFFER_PROP_INTEGER_TOTAL,     // Empty value for plotting where nothing will be drawn
  }; 
#define BUFFER_PROP_DOUBLE_TOTAL  (1)                       // Total number of real buffer properties
#define BUFFER_PROP_DOUBLE_SKIP   (0)                       // Number of buffer properties not used in sorting
//+------------------------------------------------------------------+
//| Buffer string properties                                         |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_PROP_STRING
  {
   BUFFER_PROP_SYMBOL = (BUFFER_PROP_INTEGER_TOTAL+BUFFER_PROP_DOUBLE_TOTAL), // Buffer symbol
   BUFFER_PROP_LABEL,                                       // Name of the graphical indicator series displayed in DataWindow
   BUFFER_PROP_IND_NAME,                                    // Name of an indicator using a buffer
   BUFFER_PROP_IND_NAME_SHORT,                              // Short name of an indicator using a buffer
  };
#define BUFFER_PROP_STRING_TOTAL  (4)                       // Total number of string buffer properties
//+------------------------------------------------------------------+
//| Possible buffer sorting criteria                                 |
//+------------------------------------------------------------------+
#define FIRST_BUFFER_DBL_PROP          (BUFFER_PROP_INTEGER_TOTAL-BUFFER_PROP_INTEGER_SKIP)
#define FIRST_BUFFER_STR_PROP          (BUFFER_PROP_INTEGER_TOTAL-BUFFER_PROP_INTEGER_SKIP+BUFFER_PROP_DOUBLE_TOTAL-BUFFER_PROP_DOUBLE_SKIP)
enum ENUM_SORT_BUFFER_MODE
  {
   //--- Sort by integer properties
    SORT_BY_BUFFER_INDEX_PLOT = 0,                           // Sort by the plotted buffer serial number
    SORT_BY_BUFFER_STATUS,                                   // Sort by buffer drawing style (status) from the ENUM_BUFFER_STATUS enumeration
    SORT_BY_BUFFER_TYPE,                                     // Sort by buffer type (from the ENUM_BUFFER_TYPE enumeration)
    SORT_BY_BUFFER_TIMEFRAME,                                // Sort by the buffer data period (timeframe)
    SORT_BY_BUFFER_ACTIVE,                                   // Sort by the buffer usage flag
    SORT_BY_BUFFER_DRAW_TYPE,                                // Sort by graphical construction type (from the ENUM_DRAW_TYPE enumeration)
    SORT_BY_BUFFER_ARROW_CODE,                               // Sort by the arrow code for DRAW_ARROW style
    SORT_BY_BUFFER_ARROW_SHIFT,                              // Sort by the vertical shift of the arrows for DRAW_ARROW style
    SORT_BY_BUFFER_LINE_STYLE,                               // Sort by the line style
   SORT_BY_BUFFER_LINE_WIDTH,                               // Sort by the line width
   SORT_BY_BUFFER_DRAW_BEGIN,                               // Sort by the number of initial bars that are not drawn and values in DataWindow
   SORT_BY_BUFFER_SHOW_DATA,                                // Sort by the flag of displaying construction values in DataWindow
   SORT_BY_BUFFER_SHIFT,                                    // Sort by the indicator graphical construction shift by time axis in bars
   SORT_BY_BUFFER_COLOR_INDEXES,                            // Sort by a number of attempts
   SORT_BY_BUFFER_COLOR,                                    // Sort by the drawing color
   SORT_BY_BUFFER_INDEX_BASE,                               // Sort by the basic data buffer index
   SORT_BY_BUFFER_INDEX_NEXT_BASE,                          // Sort by the index of the array to be assigned as the next indicator buffer
   SORT_BY_BUFFER_INDEX_NEXT_PLOT,                          // Sort by the index of the next drawn buffer
   SORT_BY_BUFFER_ID,                                       // Sort by ID of multiple buffers of a single indicator
   SORT_BY_BUFFER_IND_LINE_MODE,                            // Sort by the indicator line
   SORT_BY_BUFFER_IND_HANDLE,                               // Sort by handle of an indicator using a buffer
   SORT_BY_BUFFER_IND_TYPE,                                 // Sort by type of an indicator using a buffer
   SORT_BY_BUFFER_IND_LINE_ADDITIONAL_NUM,                  // Sort by number of additional indicator line
//--- Sort by real properties
   SORT_BY_BUFFER_EMPTY_VALUE = FIRST_BUFFER_DBL_PROP,      // Sort by the empty value for plotting where nothing will be drawn
//--- Sort by string properties
   SORT_BY_BUFFER_SYMBOL = FIRST_BUFFER_STR_PROP,           // Sort by the buffer symbol
   SORT_BY_BUFFER_LABEL,                                    // Sort by the name of the graphical indicator series displayed in DataWindow
   SORT_BY_BUFFER_IND_NAME,                                 // Sort by name of an indicator using a buffer
   SORT_BY_BUFFER_IND_NAME_SHORT,                           // Sort by a short name of an indicator using a buffer
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with indicators                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract indicator status                                        |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_STATUS
  {
   INDICATOR_STATUS_STANDARD,                               // Standard indicator
   INDICATOR_STATUS_CUSTOM,                                 // Custom indicator
  };
//+------------------------------------------------------------------+
//| Indicator group                                                  |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_GROUP
  {
   INDICATOR_GROUP_TREND,                                   // Trend indicator
   INDICATOR_GROUP_OSCILLATOR,                              // Oscillator
   INDICATOR_GROUP_VOLUMES,                                 // Volumes
   INDICATOR_GROUP_ARROWS,                                  // Arrow indicator
   INDICATOR_GROUP_ANY,                                     // Any indicator
  };
//+------------------------------------------------------------------+
//| Indicator integer properties                                     |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_INTEGER
  {
   INDICATOR_PROP_STATUS = 0,                               // Indicator status (from enumeration ENUM_INDICATOR_STATUS)
   INDICATOR_PROP_TYPE,                                     // Indicator type (from enumeration ENUM_INDICATOR)
   INDICATOR_PROP_TIMEFRAME,                                // Indicator timeframe
   INDICATOR_PROP_HANDLE,                                   // Indicator handle
   INDICATOR_PROP_GROUP,                                    // Indicator group
   INDICATOR_PROP_ID,                                       // Indicator ID
  }; 
#define INDICATOR_PROP_INTEGER_TOTAL (6)                    // Total number of indicator integer properties
#define INDICATOR_PROP_INTEGER_SKIP  (0)                    // Number of indicator properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator real properties                                        |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_DOUBLE
  {
   INDICATOR_PROP_EMPTY_VALUE = INDICATOR_PROP_INTEGER_TOTAL,// Empty value for plotting where nothing will be drawn
  }; 
#define INDICATOR_PROP_DOUBLE_TOTAL  (1)                    // Total number of real indicator properties
#define INDICATOR_PROP_DOUBLE_SKIP   (0)                    // Number of indicator properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator string properties                                      |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_STRING
  {
   INDICATOR_PROP_SYMBOL = (INDICATOR_PROP_INTEGER_TOTAL+INDICATOR_PROP_DOUBLE_TOTAL), // Indicator symbol
   INDICATOR_PROP_NAME,                                     // Indicator name
   INDICATOR_PROP_SHORTNAME,                                // Indicator short name
  };
#define INDICATOR_PROP_STRING_TOTAL  (3)                    // Total number of indicator string properties
//+------------------------------------------------------------------+
//| Possible indicator sorting criteria                              |
//+------------------------------------------------------------------+
#define FIRST_INDICATOR_DBL_PROP          (INDICATOR_PROP_INTEGER_TOTAL-INDICATOR_PROP_INTEGER_SKIP)
#define FIRST_INDICATOR_STR_PROP          (INDICATOR_PROP_INTEGER_TOTAL-INDICATOR_PROP_INTEGER_SKIP+INDICATOR_PROP_DOUBLE_TOTAL-INDICATOR_PROP_DOUBLE_SKIP)
enum ENUM_SORT_INDICATOR_MODE
 {
   //--- Sort by integer properties
    SORT_BY_INDICATOR_INDEX_STATUS = 0,                      // Sort by indicator status
    SORT_BY_INDICATOR_TYPE,                                  // Sort by indicator type
    SORT_BY_INDICATOR_TIMEFRAME,                             // Sort by indicator timeframe
    SORT_BY_INDICATOR_HANDLE,                                // Sort by indicator handle
    SORT_BY_INDICATOR_GROUP,                                 // Sort by indicator group
    SORT_BY_INDICATOR_ID,                                    // Sort by indicator ID
   //--- Sort by real properties
    SORT_BY_INDICATOR_EMPTY_VALUE = FIRST_INDICATOR_DBL_PROP,// Sort by the empty value for plotting where nothing will be drawn
   //--- Sort by string properties
    SORT_BY_INDICATOR_SYMBOL = FIRST_INDICATOR_STR_PROP,     // Sort by indicator symbol
    SORT_BY_INDICATOR_NAME,                                  // Sort by indicator name
    SORT_BY_INDICATOR_SHORTNAME,                             // Sort by indicator short name
 };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with indicator data                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Integer properties of indicator data                             |
//+------------------------------------------------------------------+
enum ENUM_IND_DATA_PROP_INTEGER
  {
   IND_DATA_PROP_TIME = 0,                                  // Start time of indicator data bar period
   IND_DATA_PROP_PERIOD,                                    // Indicator data period (timeframe)
   IND_DATA_PROP_INDICATOR_TYPE,                            // Indicator type
   IND_DATA_PROP_IND_BUFFER_NUM,                            // Indicator data buffer number
   IND_DATA_PROP_IND_ID,                                    // Indicator ID
   IND_DATA_PROP_IND_HANDLE,                                // Indicator handle
  }; 
#define IND_DATA_PROP_INTEGER_TOTAL (6)                     // Total number of indicator data integer properties
#define IND_DATA_PROP_INTEGER_SKIP  (0)                     // Number of indicator data properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator data real properties                                   |
//+------------------------------------------------------------------+
enum ENUM_IND_DATA_PROP_DOUBLE
  {
//--- bar data
   IND_DATA_PROP_BUFFER_VALUE = IND_DATA_PROP_INTEGER_TOTAL,// Indicator data value
  }; 
#define IND_DATA_PROP_DOUBLE_TOTAL  (1)                     // Total number of indicator data real properties
#define IND_DATA_PROP_DOUBLE_SKIP   (0)                     // Number of indicator data properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator data string properties                                 |
//+------------------------------------------------------------------+
enum ENUM_IND_DATA_PROP_STRING
  {
   IND_DATA_PROP_SYMBOL = (IND_DATA_PROP_INTEGER_TOTAL+IND_DATA_PROP_DOUBLE_TOTAL), // Indicator data symbol
   IND_DATA_PROP_IND_NAME,                                  // Indicator name
   IND_DATA_PROP_IND_SHORTNAME,                             // Indicator short name
  };
#define IND_DATA_PROP_STRING_TOTAL  (3)                     // Total number of string properties of indicator data
//+------------------------------------------------------------------+
//| Possible criteria for indicator data sorting                     |
//+------------------------------------------------------------------+
#define FIRST_IND_DATA_DBL_PROP          (IND_DATA_PROP_INTEGER_TOTAL-IND_DATA_PROP_INTEGER_SKIP)
#define FIRST_IND_DATA_STR_PROP          (IND_DATA_PROP_INTEGER_TOTAL-IND_DATA_PROP_INTEGER_SKIP+IND_DATA_PROP_DOUBLE_TOTAL-IND_DATA_PROP_DOUBLE_SKIP)
enum ENUM_SORT_IND_DATA_MODE
  {
   //--- Sort by integer properties
    SORT_BY_IND_DATA_TIME = 0,                               // Sort by bar period start time of indicator data
    SORT_BY_IND_DATA_PERIOD,                                 // Sort by indicator data period (timeframe)
    SORT_BY_IND_DATA_INDICATOR_TYPE,                         // Sort by indicator type
    SORT_BY_IND_DATA_IND_BUFFER_NUM,                         // Sort by indicator data buffer number
    SORT_BY_IND_DATA_IND_ID,                                 // Sort by indicator ID
    SORT_BY_IND_DATA_IND_HANDLE,                             // Sort by indicator handle
   //--- Sort by real properties
    SORT_BY_IND_DATA_BUFFER_VALUE = FIRST_IND_DATA_DBL_PROP, // Sort by indicator data value
   //--- Sort by string properties
    SORT_BY_IND_DATA_SYMBOL = FIRST_IND_DATA_STR_PROP,       // Sort by indicator data symbol
    SORT_BY_IND_DATA_IND_NAME,                               // Sort by indicator name
    SORT_BY_IND_DATA_IND_SHORTNAME,                          // Sort by indicator short name
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with tick data                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Integer tick properties                                          |
//+------------------------------------------------------------------+
enum ENUM_TICK_PROP_INTEGER
  {
   TICK_PROP_TIME_MSC = 0,                                  // Time of the last price update in milliseconds
   TICK_PROP_TIME,                                          // Time of the last update
   TICK_PROP_VOLUME,                                        // Volume for the current Last price
   TICK_PROP_FLAGS,                                         // Tick flags
  }; 
#define TICK_PROP_INTEGER_TOTAL (4)                         // Total number of tick integer properties
#define TICK_PROP_INTEGER_SKIP  (0)                         // Number of tick properties not used in sorting
//+------------------------------------------------------------------+
//| Real tick properties                                             |
//+------------------------------------------------------------------+
enum ENUM_TICK_PROP_DOUBLE
  {
   TICK_PROP_BID = TICK_PROP_INTEGER_TOTAL,                 // Tick Bid price
   TICK_PROP_ASK,                                           // Tick Ask price
   TICK_PROP_LAST,                                          // Current price of the last trade (Last)
   TICK_PROP_VOLUME_REAL,                                   // Volume for the current Last price with greater accuracy
   TICK_PROP_SPREAD,                                        // Tick spread (Ask - Bid)
  }; 
#define TICK_PROP_DOUBLE_TOTAL  (5)                         // Total number of real tick properties
#define TICK_PROP_DOUBLE_SKIP   (0)                         // Number of tick properties not used in sorting
//+------------------------------------------------------------------+
//| String tick properties                                           |
//+------------------------------------------------------------------+
enum ENUM_TICK_PROP_STRING
  {
   TICK_PROP_SYMBOL = (TICK_PROP_INTEGER_TOTAL+TICK_PROP_DOUBLE_TOTAL), // Tick symbol
  };
#define TICK_PROP_STRING_TOTAL  (1)                         // Total number of string tick properties
//+------------------------------------------------------------------+
//| Possible tick sorting criteria                                   |
//+------------------------------------------------------------------+
#define FIRST_TICK_DBL_PROP          (TICK_PROP_INTEGER_TOTAL-TICK_PROP_INTEGER_SKIP)
#define FIRST_TICK_STR_PROP          (TICK_PROP_INTEGER_TOTAL-TICK_PROP_INTEGER_SKIP+TICK_PROP_DOUBLE_TOTAL-TICK_PROP_DOUBLE_SKIP)
enum ENUM_SORT_TICK_MODE
  {
//--- Sort by integer properties
   SORT_BY_TICK_TIME_MSC = 0,                               // Sort by the time of the last price update in milliseconds
   SORT_BY_TICK_TIME,                                       // Sort by the time of the last price update
   SORT_BY_TICK_VOLUME,                                     // Sort by volume for the current Last price
   SORT_BY_TICK_FLAGS,                                      // Sort by tick flags
//--- Sort by real properties
   SORT_BY_TICK_BID = FIRST_TICK_DBL_PROP,                  // Sort by tick Bid price
   SORT_BY_TICK_ASK,                                        // Sort by tick Ask price
   SORT_BY_TICK_LAST,                                       // Sort by current price of the last trade (Last)
   SORT_BY_TICK_VOLUME_REAL,                                // Sort by volume for the current Last price with greater accuracy
   SORT_BY_TICK_SPREAD,                                     // Sort by tick spread
//--- Sort by string properties
   SORT_BY_TICK_SYMBOL = FIRST_TICK_STR_PROP,               // Sort by tick symbol
  };
//+------------------------------------------------------------------+
#endif // __TIMESERIES_DEFINES_MQH__