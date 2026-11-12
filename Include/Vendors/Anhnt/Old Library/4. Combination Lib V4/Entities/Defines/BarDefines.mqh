//+------------------------------------------------------------------+
//|                                                   BarDefines.mqh |
//|Lib https://www.mql5.com/en/articles/14710                        |
//|     Defines for the information of a bar: candle patterns,       |
//|     momentum candle, swing, BOS, CHoCH                           |
//+------------------------------------------------------------------+
#ifndef __BARDEFINES_MQH__
#define __BARDEFINES_MQH__
 #include "CommonDefines.mqh"
  #define SIGNAL_DIRECTION_NO_PATTERN              ((ENUM_SIGNAL_DIRECTION)WRONG_VALUE)   // what a rule returns when the bar is not the pattern (CBarPattern, CBarSwing)
//+------------------------------------------------------------------+
 //| The default value of the parameters of a type: the number the     |
 //| row of Setting_BarSetup gets when it is new (percent of the range |
 //| of the candle; points for the tweezer). From Lib V2               |
 //| BarPatternControl.mqh, here is the only place                     |
 //+------------------------------------------------------------------+
  #define PATTERN_DEF_LARGE_BODY                   60.0   // min body ratio: "large" candle (Morning Star bar0, Harami bar0, etc.)
  #define PATTERN_DEF_SMALL_BODY                   35.0   // max body ratio: "small" candle (Hammer, InvertedHammer, Spinning Top)
  #define PATTERN_DEF_DOJI_BODY                    5.0    // max body ratio: Doji (and Doji variants), the short shadow of Dragonfly / Gravestone
  #define PATTERN_DEF_SPINNING_TOP_SHADOW          25.0   // min ratio EACH shadow must reach: Spinning Top
  #define PATTERN_DEF_MARUBOZU_BODY                90.0   // min body ratio: Marubozu
  #define PATTERN_DEF_INNER_BODY                   30.0   // max body ratio: inner candle (Harami bar1, Three Inside bar1, the star of Morning / Evening Star)
  #define PATTERN_DEF_LONG_SHADOW                  55.0   // min shadow ratio: long shadow (Hammer lower, InvertedHammer upper)
  #define PATTERN_DEF_SHORT_SHADOW                 10.0   // max shadow ratio: short shadow (opposite side of Hammer)
  #define PATTERN_DEF_DEEP_SHADOW                  70.0   // min shadow ratio: very long shadow (Dragonfly / Gravestone Doji)
  #define PATTERN_DEF_PENETRATION                  50.0   // min penetration into body (Morning Star bar2, Piercing Line bar1)
  #define PATTERN_DEF_SIMILARITY                   70.0   // min body size similarity ratio (Rails)
  #define PATTERN_DEF_TWEEZER_PTS                  5.0    // max High/Low difference in points (Tweezer)
  #define PATTERN_DEF_THREE_STARS_DOJI_BODY        10.0   // max body ratio of the doji of Three Stars
  #define PATTERN_DEF_OUTSIDE_BAR_RATIO_CANDLES    50.0   // OutsideBar
  #define PATTERN_DEF_OUTSIDE_BAR_RATIO_BODY       50.0   // OutsideBar
  #define PATTERN_DEF_PINBAR_RATIO_BODY            30.0   // PinBar: max body ratio
  #define PATTERN_DEF_PINBAR_LARGER_SHADOW         60.0   // PinBar: min larger shadow ratio
  #define PATTERN_DEF_PINBAR_SMALLER_SHADOW        30.0   // PinBar: max smaller shadow ratio
  #define PATTERN_DEF_PPR_RATIO_CANDLE_SIZE        20.0   // PivotPointReversal: min % of bar1's own High-Low range
 //For momentum candle
  #define MOMENTUM_DEF_MULTIPLIER                  2.0    // Momentum Candle: the body is more than this times the biggest body of the candles before it
  #define MOMENTUM_DEF_BARS                        3.0    // Momentum Candle: how many candles before it are compared
  #define SWING_DEF_STRENGTH                       5.0    // Swing: how many candles each side must be lower (high) / higher (low) than it
  #define SWING_DEF_PRICE_BASIS                    (double)SWING_PRICE_BASIS_WICK   // Swing: the price it is found on
  #define STRUCTURE_LOOKBACK                       300    // BOS / CHoCH: the swing before the broken one is confirmed at most this many bars back (Python reads it: structure_lookback)
 //+------------------------------------------------------------------+
 //| The names of the parameters of a type (column param of           |
 //| Setting_BarSetup): the values are percent of the range of the    |
 //| candle (points for the tolerance)                                |
 //+------------------------------------------------------------------+
  #define BAR_PARAM_BODY_MAX            "body_max"
  #define BAR_PARAM_BODY_MIN            "body_min"
  #define BAR_PARAM_LOWER_SHADOW_MIN    "lower_shadow_min"
  #define BAR_PARAM_LOWER_SHADOW_MAX    "lower_shadow_max"
  #define BAR_PARAM_UPPER_SHADOW_MIN    "upper_shadow_min"
  #define BAR_PARAM_UPPER_SHADOW_MAX    "upper_shadow_max"
  #define BAR_PARAM_SHADOW_MIN_EACH     "shadow_min_each"
  #define BAR_PARAM_MOTHER_BODY_MIN     "mother_body_min"
  #define BAR_PARAM_INNER_BODY_MAX      "inner_body_max"
  #define BAR_PARAM_TOLERANCE_POINTS    "tolerance_points"
  #define BAR_PARAM_PENETRATION_MIN     "penetration_min"
  #define BAR_PARAM_FIRST_BODY_MIN      "first_body_min"
  #define BAR_PARAM_MIDDLE_BODY_MAX     "middle_body_max"
  #define BAR_PARAM_OUTER_BODY_MIN      "outer_body_min"
  #define BAR_PARAM_SECOND_BODY_MAX     "second_body_max"
  #define BAR_PARAM_DOJI_BODY_MAX       "doji_body_max"
  #define BAR_PARAM_SIMILARITY_MIN      "similarity_min"
  #define BAR_PARAM_LARGER_SHADOW_MIN   "larger_shadow_min"
  #define BAR_PARAM_SMALLER_SHADOW_MAX  "smaller_shadow_max"
  #define BAR_PARAM_CANDLES_RATIO       "candles_ratio"
  #define BAR_PARAM_BODY_RATIO          "body_ratio"
  #define BAR_PARAM_PROTRUDE_MIN        "protrude_min"
  #define BAR_PARAM_BODY_MULTIPLIER     "body_multiplier"
  #define BAR_PARAM_BARS_BEFORE         "bars_before"
  #define BAR_PARAM_SWING_STRENGTH      "swing_strength"
  #define BAR_PARAM_PRICE_BASIS         "price_basis"
 //+------------------------------------------------------------------+
 //| The group of an information of a bar (column group_infor)        |
 //+------------------------------------------------------------------+
 enum ENUM_BAR_INFORMATION_GROUP
  {
   BAR_INFORMATION_JAPANESE_CANDLE,                                       // Candles
   BAR_INFORMATION_PRICE_ACTION_CANDLE,                                       // Price Action formations
   BAR_INFORMATION_SMART_MONEY,                                               // Smart Money: momentum candle, swing, BOS, CHoCH...
   BAR_INFORMATION_SIGNAL,                                                    // The signal of an indicator template (not in Setting_BarInformation)
  };
 #define BAR_INFORMATION_GROUP_TOTAL  (3)                           // Number of the groups of Setting_BarInformation: one switch of the Candle tab for each (BAR_INFORMATION_SIGNAL is after them)
 //+------------------------------------------------------------------+
 //| The kind of an information of a bar (column type_infor). A plain |
 //| integer, not a bit mask: the database is the key, the numbers    |
 //| come in ranges, one for each group (100 candles, 200 price action)|
 //+------------------------------------------------------------------+
 enum ENUM_BAR_INFOR_TYPE
  {
  //--- Candles (BAR_INFORMATION_JAPANESE_CANDLE)
   BAR_INFOR_TYPE_HAMMER = 101,                             // Hammer
   BAR_INFOR_TYPE_HANGING_MAN,                              // Hanging Man
   BAR_INFOR_TYPE_INVERTED_HAMMER,                          // Inverted Hammer
   BAR_INFOR_TYPE_SHOOTING_STAR,                            // Shooting Star
   BAR_INFOR_TYPE_DOJI,                                     // Doji
   BAR_INFOR_TYPE_DRAGONFLY_DOJI,                           // Dragonfly doji
   BAR_INFOR_TYPE_GRAVESTONE_DOJI,                          // Gravestone Doji
   BAR_INFOR_TYPE_SPINNING_TOP,                             // Spinning Top
   BAR_INFOR_TYPE_MARUBOZU,                                 // Marubozu
   BAR_INFOR_TYPE_HARAMI,                                   // Harami
   BAR_INFOR_TYPE_HARAMI_CROSS,                             // Harami Cross
   BAR_INFOR_TYPE_ENGULFING,                                // Engulfing
   BAR_INFOR_TYPE_TWEEZER,                                  // Tweezer
   BAR_INFOR_TYPE_PIERCING_PATTERN,                         // Piercing pattern
   BAR_INFOR_TYPE_DARK_CLOUD_COVER,                         // Dark Cloud Cover
   BAR_INFOR_TYPE_MORNING_STAR,                             // Morning Star
   BAR_INFOR_TYPE_MORNING_DOJI_STAR,                        // Morning Doji Star
   BAR_INFOR_TYPE_EVENING_STAR,                             // Evening Star
   BAR_INFOR_TYPE_EVENING_DOJI_STAR,                        // Evening Doji Star
   BAR_INFOR_TYPE_ABANDONED_BABY,                           // Abandoned baby
   BAR_INFOR_TYPE_THREE_WHITE_SOLDIERS,                     // Three White Soldiers
   BAR_INFOR_TYPE_THREE_BLACK_CROWS,                        // Three Black Crows
   BAR_INFOR_TYPE_THREE_INSIDE_UP,                          // Three Inside Up
   BAR_INFOR_TYPE_THREE_INSIDE_DOWN,                        // Three Inside Down
   BAR_INFOR_TYPE_THREE_STARS,                              // Three stars
  //--- Price Action (BAR_INFORMATION_PRICE_ACTION_CANDLE)
   BAR_INFOR_TYPE_PIN_BAR = 201,                            // Pin Bar
   BAR_INFOR_TYPE_RAILS,                                    // Rails
   BAR_INFOR_TYPE_OUTSIDE_BAR,                              // Outside Bar
   BAR_INFOR_TYPE_INSIDE_BAR,                               // Inside Bar
   BAR_INFOR_TYPE_PIVOT_POINT_REVERSAL,                     // Pivot Point Reversal
  //--- Smart Money (BAR_INFORMATION_SMART_MONEY)
   BAR_INFOR_TYPE_MOMENTUM_CANDLE = 301,                    // Momentum Candle
   BAR_INFOR_TYPE_SWING_HIGH,                               // Swing High (the Sell side)
   BAR_INFOR_TYPE_SWING_LOW,                                // Swing Low (the Buy side)
   BAR_INFOR_TYPE_BOS,                                      // Break of Structure (Buy: up, Sell: down)
   BAR_INFOR_TYPE_CHOCH,                                    // Change of Character (Buy: up, Sell: down)
  //--- Zones, FVG, trendlines and legs are not types: the View builds them in RAM from these rows (FVG, Supply/Demand: the Momentum Candle row)
  };
 //+------------------------------------------------------------------+
 //| The price a swing is found on (the value of the parameter         |
 //| price_basis of a swing type). From Lib V2 SwingDefines.mqh        |
 //+------------------------------------------------------------------+
 enum ENUM_SWING_PRICE_BASIS
  {
   SWING_PRICE_BASIS_WICK,                                  // High / Low (default)
   SWING_PRICE_BASIS_BODY,                                  // Open / Close
  };
 
 //+------------------------------------------------------------------+
 //| The bar of a timeseries (CBar): its properties                    |
 //+------------------------------------------------------------------+
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
   BAR_PROP_PERIOD,                                         // Bar period (timeframe)
   BAR_PROP_SPREAD,                                         // Bar spread MT5 SYMBOL_SPREAD
   //V4 add here for infomation calculation at Bar
    BAR_PROP_INFOR_GROUP,                                   // Group of Infomation ENUM_BAR_INFORMATION_GROUP: RAM only, from the type (CBarInformationManager::Group), not a column
    BAR_PROP_INFOR_TYPE,                                    // Type of Information at Bar ENUM_BAR_INFOR_TYPE (column type_infor)
    BAR_PROP_SIGNAL_DIRECTION,                              // Side of Bar ENUM_SIGNAL_DIRECTION (column signal_direction)
   BAR_PROP_VOLUME_TICK,                                    // Bar tick volume
   BAR_PROP_VOLUME_REAL,                                    // Bar exchange volume
   BAR_PROP_TIME_DAY_OF_YEAR,                               // Bar day serial number in a year
   BAR_PROP_TIME_YEAR,                                      // A year the bar belongs to
   BAR_PROP_TIME_MONTH,                                     // A month the bar belongs to
   BAR_PROP_TIME_DAY_OF_WEEK,                               // Bar week day
   BAR_PROP_TIME_DAY,                                       // Bar day of month (number)
   BAR_PROP_TIME_HOUR,                                      // Bar hour
   BAR_PROP_TIME_MINUTE,                                    // Bar minute
  };
 #define BAR_PROP_INTEGER_TOTAL (15)
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
 enum ENUM_BAR_PROP_STRING
  {
   BAR_PROP_SYMBOL = (BAR_PROP_INTEGER_TOTAL+BAR_PROP_DOUBLE_TOTAL), // Bar symbol
  };
 #define BAR_PROP_STRING_TOTAL  (1)
 //--- The lists of bars are sorted by the time of the bar (the mode of Compare)
 enum ENUM_SORT_BAR_MODE
  {
   SORT_BY_BAR_TIME = 0,
  };
#endif // __BARDEFINES_MQH__
