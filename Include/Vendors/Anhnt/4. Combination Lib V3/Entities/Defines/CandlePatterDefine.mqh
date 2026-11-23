//+------------------------------------------------------------------+
//|                                             BarPatternDefines.mqh|
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __BARPATTERNDEFINES_MQH__
#define __BARPATTERNDEFINES_MQH__
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
   
    PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,        // Defined criterion of the ratio of the candle body to the full candle size in %
    PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,// Defined criterion of the ratio of the maximum shadow to the candle size in %
    PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION,// Defined criterion of the ratio of the minimum shadow to the candle size in %
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
#endif // __BARPATTERNDEFINES_MQH__
