//+------------------------------------------------------------------+
//|                                                   BarDefines.mqh |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __ENTITIES_BARDEFINES_MQH__
#define __ENTITIES_BARDEFINES_MQH__
 enum ENUM_BAR_BODY_TYPE
  {
   BAR_BODY_TYPE_BULLISH,                                   // Bullish bar
   BAR_BODY_TYPE_BEARISH,                                   // Bearish bar
   BAR_BODY_TYPE_NULL,                                      // Zero bar
   BAR_BODY_TYPE_CANDLE_ZERO_BODY,                          // Candle with a zero body
  };

 enum ENUM_BAR_PROP_INTEGER
  {
   BAR_PROP_TIME = 0,                                       // Bar period start time
   BAR_PROP_TYPE,                                           // Bar type (ENUM_BAR_BODY_TYPE)
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
   BAR_PROP_PATTERNS_TYPE,                                  // Pattern flags on the bar (ENUM_PATTERN_TYPE)
  };
 #define BAR_PROP_INTEGER_TOTAL (14)
 #define BAR_PROP_INTEGER_SKIP  (0)

 enum ENUM_BAR_PROP_DOUBLE
  {
   BAR_PROP_OPEN = BAR_PROP_INTEGER_TOTAL,                  // Bar open price
   BAR_PROP_HIGH,                                           // Highest price for the bar period
   BAR_PROP_LOW,                                            // Lowest price for the bar period
   BAR_PROP_CLOSE,                                          // Bar close price
   BAR_PROP_CANDLE_SIZE,                                    // Candle size
   BAR_PROP_CANDLE_SIZE_BODY,                               // Candle body size
   BAR_PROP_CANDLE_BODY_TOP,                                // Candle body top
   BAR_PROP_CANDLE_BODY_BOTTOM,                             // Candle body bottom
   BAR_PROP_CANDLE_SIZE_SHADOW_UP,                          // Candle upper wick size
   BAR_PROP_CANDLE_SIZE_SHADOW_DOWN,                        // Candle lower wick size
   BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      // Body to candle size, %
   BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              // Upper shadow to candle size, %
   BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              // Lower shadow to candle size, %
  };
 #define BAR_PROP_DOUBLE_TOTAL  (13)
 #define BAR_PROP_DOUBLE_SKIP   (0)

 enum ENUM_BAR_PROP_STRING
  {
   BAR_PROP_SYMBOL = (BAR_PROP_INTEGER_TOTAL+BAR_PROP_DOUBLE_TOTAL), // Bar symbol
  };
 #define BAR_PROP_STRING_TOTAL  (1)

 #define FIRST_BAR_DBL_PROP          (BAR_PROP_INTEGER_TOTAL-BAR_PROP_INTEGER_SKIP)
 #define FIRST_BAR_STR_PROP          (BAR_PROP_INTEGER_TOTAL-BAR_PROP_INTEGER_SKIP+BAR_PROP_DOUBLE_TOTAL-BAR_PROP_DOUBLE_SKIP)
 enum ENUM_SORT_BAR_MODE
  {
   SORT_BY_BAR_TIME = 0,
   SORT_BY_BAR_TYPE,
   SORT_BY_BAR_PERIOD,
   SORT_BY_BAR_SPREAD,
   SORT_BY_BAR_VOLUME_TICK,
   SORT_BY_BAR_VOLUME_REAL,
   SORT_BY_BAR_TIME_DAY_OF_YEAR,
   SORT_BY_BAR_TIME_YEAR,
   SORT_BY_BAR_TIME_MONTH,
   SORT_BY_BAR_TIME_DAY_OF_WEEK,
   SORT_BY_BAR_TIME_DAY,
   SORT_BY_BAR_TIME_HOUR,
   SORT_BY_BAR_TIME_MINUTE,
   SORT_BY_BAR_PATTERN_TYPE,
   SORT_BY_BAR_OPEN = FIRST_BAR_DBL_PROP,
   SORT_BY_BAR_HIGH,
   SORT_BY_BAR_LOW,
   SORT_BY_BAR_CLOSE,
   SORT_BY_BAR_CANDLE_SIZE,
   SORT_BY_BAR_CANDLE_SIZE_BODY,
   SORT_BY_BAR_CANDLE_BODY_TOP,
   SORT_BY_BAR_CANDLE_BODY_BOTTOM,
   SORT_BY_BAR_CANDLE_SIZE_SHADOW_UP,
   SORT_BY_BAR_CANDLE_SIZE_SHADOW_DOWN,
   SORT_BY_BAR_SYMBOL = FIRST_BAR_STR_PROP,
  };
#endif // __ENTITIES_BARDEFINES_MQH__
