//+------------------------------------------------------------------+
//|                                       MarketStructureDefines.mqh |
//| Market structure definitions, one enum space for the whole       |
//| Smart Money group:                                               |
//|  - Swing High/Low (own enum space: ENUM_PATTERN_TYPE is a        |
//|    bit-flag set with no free bit left for two more flags in the  |
//|    `long` BAR_PROP_PATTERNS_TYPE storage)                        |
//|  - Market structure events (BOS / CHoCH)                         |
//|  - Lifecycle (Born -> Live -> Dead) of Trendline, Zone and       |
//|    Protected Level                                               |
//+------------------------------------------------------------------+
#ifndef __MARKET_STRUCTURE_DEFINES_MQH__
#define __MARKET_STRUCTURE_DEFINES_MQH__

//+------------------------------------------------------------------+
//| Swing type - High or Low                                         |
//+------------------------------------------------------------------+
enum ENUM_SWING_TYPE
 {
  SWING_TYPE_NONE = 0,                                     // Not a swing
  SWING_TYPE_HIGH,                                          // Swing High (local price maximum)
  SWING_TYPE_LOW,                                           // Swing Low (local price minimum)
 };
//+------------------------------------------------------------------+
//| Which price a Swing is measured from - wick (High/Low, classic)  |
//| or candle body (Open/Close, ignores wicks)                       |
//+------------------------------------------------------------------+
enum ENUM_SWING_PRICE_BASIS
 {
  SWING_PRICE_BASIS_WICK,                                  // High/Low (default)
  SWING_PRICE_BASIS_BODY,                                  // Open/Close
 };
//+------------------------------------------------------------------+
//| HH/LH/HL/LL classification vs the previous Swing of the SAME     |
//| type (High compared only to the last High, Low only to the last  |
//| Low) - Option, computed once at confirmation time.                |
//+------------------------------------------------------------------+
enum ENUM_SWING_STRUCTURE
 {
  SWING_STRUCTURE_NONE,                                    // No earlier same-type Swing to compare against yet
  SWING_STRUCTURE_HH,                                       // Higher High
  SWING_STRUCTURE_LH,                                       // Lower High
  SWING_STRUCTURE_HL,                                       // Higher Low
  SWING_STRUCTURE_LL,                                       // Lower Low
 };
//+------------------------------------------------------------------+
//| Swing integer properties                                         |
//+------------------------------------------------------------------+
enum ENUM_SWING_PROP_INTEGER
 {
  SWING_PROP_CODE = 0,                                     // Unique swing code (time+type+period+symbol) - Primary Key
  SWING_PROP_TIME,                                         // Pivot bar time - FK to CBar
  SWING_PROP_CONFIRMED_TIME,                               // Time the swing became confirmed (pivot time + strength periods)
  SWING_PROP_TYPE,                                         // ENUM_SWING_TYPE (High/Low)
  SWING_PROP_PERIOD,                                       // Timeframe
  SWING_PROP_STRENGTH,                                     // N (left/right bars) used to detect this swing
  SWING_PROP_PRICE_BASIS,                                  // ENUM_SWING_PRICE_BASIS used to detect this swing
  SWING_PROP_STRUCTURE,                                    // ENUM_SWING_STRUCTURE (HH/LH/HL/LL)
 };
#define SWING_PROP_INTEGER_TOTAL (8)                        // Total number of integer swing properties
#define SWING_PROP_INTEGER_SKIP  (0)                        // Number of swing properties not used in sorting
//+------------------------------------------------------------------+
//| Swing real properties                                            |
//+------------------------------------------------------------------+
enum ENUM_SWING_PROP_DOUBLE
 {
  SWING_PROP_PRICE = SWING_PROP_INTEGER_TOTAL,             // Swing High/Low price
 };
#define SWING_PROP_DOUBLE_TOTAL (1)                         // Total number of real swing properties
#define SWING_PROP_DOUBLE_SKIP  (0)                         // Number of swing properties not used in sorting
//+------------------------------------------------------------------+
//| Swing string properties                                          |
//+------------------------------------------------------------------+
enum ENUM_SWING_PROP_STRING
 {
  SWING_PROP_SYMBOL = (SWING_PROP_INTEGER_TOTAL+SWING_PROP_DOUBLE_TOTAL), // Swing symbol
 };
#define SWING_PROP_STRING_TOTAL (1)                         // Total number of string swing properties
//+------------------------------------------------------------------+
//| Possible swing sorting criteria                                  |
//+------------------------------------------------------------------+
#define FIRST_SWING_DBL_PROP (SWING_PROP_INTEGER_TOTAL-SWING_PROP_INTEGER_SKIP)
#define FIRST_SWING_STR_PROP (SWING_PROP_INTEGER_TOTAL-SWING_PROP_INTEGER_SKIP+SWING_PROP_DOUBLE_TOTAL-SWING_PROP_DOUBLE_SKIP)
enum ENUM_SORT_SWING_MODE
 {
  //--- Sort by integer properties
   SORT_BY_SWING_CODE = 0,                                  // Sort by unique swing code
   SORT_BY_SWING_TIME,                                      // Sort by pivot bar time
   SORT_BY_SWING_CONFIRMED_TIME,                            // Sort by confirmation time
   SORT_BY_SWING_TYPE,                                      // Sort by swing type (High/Low)
   SORT_BY_SWING_PERIOD,                                    // Sort by timeframe
   SORT_BY_SWING_STRENGTH,                                  // Sort by strength (N) used to detect
   SORT_BY_SWING_PRICE_BASIS,                               // Sort by price basis (Wick/Body)
   SORT_BY_SWING_STRUCTURE,                                 // Sort by structure label (HH/LH/HL/LL)
  //--- Sort by real properties
   SORT_BY_SWING_PRICE = FIRST_SWING_DBL_PROP,              // Sort by swing price
  //--- Sort by string properties
   SORT_BY_SWING_SYMBOL = FIRST_SWING_STR_PROP,             // Sort by swing symbol
 };
//+------------------------------------------------------------------+
//| Market structure event: a candle closed beyond the reference     |
//| Swing - with the trend (BOS) or against it (CHoCH)               |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE_TYPE
 {
  MARKET_STRUCTURE_NONE = 0,                                // No event
  MARKET_STRUCTURE_BOS,                                     // Break of Structure (continuation)
  MARKET_STRUCTURE_CHOCH,                                   // Change of Character (reversal)
 };
//+------------------------------------------------------------------+
//| Market structure integer properties                              |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE_PROP_INTEGER
 {
  MARKET_STRUCTURE_PROP_CODE = 0,                          // Unique code (time+type+period+symbol) - Primary Key
  MARKET_STRUCTURE_PROP_TIME,                              // Time of the candle that closed beyond the Swing
  MARKET_STRUCTURE_PROP_TYPE,                              // ENUM_MARKET_STRUCTURE_TYPE (BOS/CHoCH)
  MARKET_STRUCTURE_PROP_DIRECTION,                         // ENUM_SIGNAL_DIR of the break (BUY = closed above, SELL = closed below)
  MARKET_STRUCTURE_PROP_PERIOD,                            // Timeframe
  MARKET_STRUCTURE_PROP_SWING_TIME,                        // Pivot time of the broken Swing
 };
#define MARKET_STRUCTURE_PROP_INTEGER_TOTAL (6)             // Total number of integer properties
#define MARKET_STRUCTURE_PROP_INTEGER_SKIP  (0)             // Number of properties not used in sorting
//+------------------------------------------------------------------+
//| Market structure real properties                                 |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE_PROP_DOUBLE
 {
  MARKET_STRUCTURE_PROP_LEVEL = MARKET_STRUCTURE_PROP_INTEGER_TOTAL, // Price of the broken Swing
 };
#define MARKET_STRUCTURE_PROP_DOUBLE_TOTAL (1)              // Total number of real properties
#define MARKET_STRUCTURE_PROP_DOUBLE_SKIP  (0)              // Number of properties not used in sorting
//+------------------------------------------------------------------+
//| Market structure string properties                               |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE_PROP_STRING
 {
  MARKET_STRUCTURE_PROP_SYMBOL = (MARKET_STRUCTURE_PROP_INTEGER_TOTAL+MARKET_STRUCTURE_PROP_DOUBLE_TOTAL), // Symbol
 };
#define MARKET_STRUCTURE_PROP_STRING_TOTAL (1)              // Total number of string properties
//+------------------------------------------------------------------+
//| Possible market structure sorting criteria                       |
//+------------------------------------------------------------------+
#define FIRST_MARKET_STRUCTURE_DBL_PROP (MARKET_STRUCTURE_PROP_INTEGER_TOTAL-MARKET_STRUCTURE_PROP_INTEGER_SKIP)
#define FIRST_MARKET_STRUCTURE_STR_PROP (MARKET_STRUCTURE_PROP_INTEGER_TOTAL-MARKET_STRUCTURE_PROP_INTEGER_SKIP+MARKET_STRUCTURE_PROP_DOUBLE_TOTAL-MARKET_STRUCTURE_PROP_DOUBLE_SKIP)
enum ENUM_SORT_MARKET_STRUCTURE_MODE
 {
  //--- Sort by integer properties
   SORT_BY_MARKET_STRUCTURE_CODE = 0,                       // Sort by unique code
   SORT_BY_MARKET_STRUCTURE_TIME,                           // Sort by break candle time
   SORT_BY_MARKET_STRUCTURE_TYPE,                           // Sort by type (BOS/CHoCH)
   SORT_BY_MARKET_STRUCTURE_DIRECTION,                      // Sort by direction
   SORT_BY_MARKET_STRUCTURE_PERIOD,                         // Sort by timeframe
   SORT_BY_MARKET_STRUCTURE_SWING_TIME,                     // Sort by broken Swing pivot time
  //--- Sort by real properties
   SORT_BY_MARKET_STRUCTURE_LEVEL = FIRST_MARKET_STRUCTURE_DBL_PROP, // Sort by broken level price
  //--- Sort by string properties
   SORT_BY_MARKET_STRUCTURE_SYMBOL = FIRST_MARKET_STRUCTURE_STR_PROP, // Sort by symbol
 };
//+------------------------------------------------------------------+
//| Lifecycle: Born -> Live -> Dead. A Swing is NOT a lifecycle      |
//| object, it never changes once confirmed. The event codes sent    |
//| for these objects are in EventDefines.mqh (ENUM_LIFECYCLE_EVENT) |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Kind of object that goes through the lifecycle                   |
//+------------------------------------------------------------------+
enum ENUM_LIFECYCLE_OBJECT_KIND
 {
  LIFECYCLE_OBJECT_NONE = 0,                               // Not a lifecycle object
  LIFECYCLE_OBJECT_TRENDLINE,                              // Trendline
  LIFECYCLE_OBJECT_ZONE,                                   // Supply / Demand zone
  LIFECYCLE_OBJECT_PROTECTED_LEVEL,                        // Protected high / low
 };
//+------------------------------------------------------------------+
//| Where a lifecycle object was born                                |
//+------------------------------------------------------------------+
enum ENUM_LIFECYCLE_SOURCE
 {
  LIFECYCLE_SOURCE_AUTO = 0,                               // Detected automatically (Python)
  LIFECYCLE_SOURCE_USER,                                   // Drawn by the user
 };
//+------------------------------------------------------------------+
//| Why a lifecycle object died                                      |
//+------------------------------------------------------------------+
enum ENUM_LIFECYCLE_DEAD_REASON
 {
  LIFECYCLE_DEAD_NONE = 0,                                 // Not dead
  LIFECYCLE_DEAD_EXPIRED,                                  // Broken (ghost) for too long
  LIFECYCLE_DEAD_USER_DELETED,                             // Deleted by the user
  LIFECYCLE_DEAD_MERGED,                                   // Absorbed by another object
  LIFECYCLE_DEAD_OBSOLETE,                                 // Price had already passed it when it was found
 };
#endif // __MARKET_STRUCTURE_DEFINES_MQH__
