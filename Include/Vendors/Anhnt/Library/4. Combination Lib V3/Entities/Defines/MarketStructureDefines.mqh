//+------------------------------------------------------------------+
//|                                       MarketStructureDefines.mqh |
//| Market structure definitions, one enum space for the whole       |
//| Smart Money group:                                               |
//|  - Swing High/Low (own enum space: ENUM_PATTERN_TYPE is a        |
//|    bit-flag set with no free bit left for two more flags in the  |
//|    `long` BAR_PROP_PATTERNS_TYPE storage)                        |
//|  - Market structure events (BOS / CHoCH)                         |
//|  - Market State (3), Market Phase (4) and Move type             |
//|    (Impulse / Pullback)                                          |
//|  - Lifecycle (Born -> Live -> Dead) of Trendline, Zone and       |
//|    Protected Level                                               |
//+------------------------------------------------------------------+
#ifndef __MARKET_STRUCTURE_DEFINES_MQH__
#define __MARKET_STRUCTURE_DEFINES_MQH__
//Working with Swing
 //+------------------------------------------------------------------+
 //| Swing type - High or Low                                         |
 //+------------------------------------------------------------------+
 enum ENUM_SWING_TYPE
  {
   SWING_TYPE_NONE = 0,                                     // Not a swing
   SWING_TYPE_HIGH,                                         // Swing High (local price maximum)
   SWING_TYPE_LOW,                                          // Swing Low (local price minimum)
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
   SWING_STRUCTURE_HH,                                      // Higher High
   SWING_STRUCTURE_LH,                                      // Lower High
   SWING_STRUCTURE_HL,                                      // Higher Low
   SWING_STRUCTURE_LL,                                      // Lower Low
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
//Working with Market Structure
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
   MARKET_STRUCTURE_PROP_PHASE,                             // ENUM_MARKET_PHASE in force when it broke (Python decides it)
   MARKET_STRUCTURE_PROP_STRONG_TIME,                       // Time of the strong swing: where the move that broke the structure started (0 = none)
  };
 #define MARKET_STRUCTURE_PROP_INTEGER_TOTAL (8)             // Total number of integer properties
 #define MARKET_STRUCTURE_PROP_INTEGER_SKIP  (0)             // Number of properties not used in sorting
 //+------------------------------------------------------------------+
 //| Market structure real properties                                 |
 //+------------------------------------------------------------------+
 enum ENUM_MARKET_STRUCTURE_PROP_DOUBLE
  {
   MARKET_STRUCTURE_PROP_LEVEL = MARKET_STRUCTURE_PROP_INTEGER_TOTAL, // Price of the broken Swing (the weak level)
   MARKET_STRUCTURE_PROP_STRONG_PRICE,                      // Price of the strong swing
  };
 #define MARKET_STRUCTURE_PROP_DOUBLE_TOTAL (2)              // Total number of real properties
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
    SORT_BY_MARKET_STRUCTURE_PHASE,                          // Sort by Market Phase
   //--- Sort by real properties
    SORT_BY_MARKET_STRUCTURE_LEVEL = FIRST_MARKET_STRUCTURE_DBL_PROP, // Sort by broken level price
   //--- Sort by string properties
    SORT_BY_MARKET_STRUCTURE_SYMBOL = FIRST_MARKET_STRUCTURE_STR_PROP, // Sort by symbol
  };
//Working with Market State, Market Phase and Move type
 //+------------------------------------------------------------------+
 //| Three questions about the market, three enums: where is it now   |
 //| (State), which stage of the cycle (Phase), what is the last move |
 //| doing (Move type). Python decides them from the Swings; the EA   |
 //| only holds and shows them                                        |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Market State: the 3 main market conditions                       |
 //|                            https://www.mql5.com/en/articles/23049|
 //+------------------------------------------------------------------+
 enum ENUM_MARKET_STATE
  {
   MARKET_STATE_NONE = 0,                                   // Not known yet (too few Swings)
   MARKET_STATE_UPTREND,                                    // Higher highs and higher lows
   MARKET_STATE_DOWNTREND,                                  // Lower highs and lower lows
   MARKET_STATE_RANGE,                                      // Rangebound / Sideway: neither of the two
  };
 //+------------------------------------------------------------------+
 //| Market Phase: the 4 recurring market cycles. It follows from the |
 //| Market State and the trend that came before it               |
 //+------------------------------------------------------------------+
 enum ENUM_MARKET_PHASE
  {
   MARKET_PHASE_NONE = 0,                                   // Not known yet
   MARKET_PHASE_ACCUMULATION,                               // Range after a downtrend
   MARKET_PHASE_MARKUP,                                     // Uptrend
   MARKET_PHASE_DISTRIBUTION,                               // Range after an uptrend
   MARKET_PHASE_MARKDOWN,                                   // Downtrend
  };
 //+------------------------------------------------------------------+
 //| Move type: a move between two Swings, judged against the trend   |
 //+------------------------------------------------------------------+
 enum ENUM_MOVE_TYPE
  {
   MOVE_TYPE_NONE = 0,                                      // Not known (no trend to judge against)
   MOVE_TYPE_IMPULSE,                                       // Moves with the trend
   MOVE_TYPE_PULLBACK,                                      // Moves against the trend (retracement)
  };
 //+------------------------------------------------------------------+
 //| How deep a Pullback is, against the leg before it                |
 //|4. Dynamic Pullback Depth Using Volatility Models                 |
 //|                          https://www.mql5.com/en/articles/22807  |
 //+------------------------------------------------------------------+
 enum ENUM_PULLBACK_DEPTH
  {
   PULLBACK_DEPTH_NONE = 0,                                 // Not a pullback
   PULLBACK_DEPTH_AGGRESSIVE,                               // Under 0.25: it barely pulled back
   PULLBACK_DEPTH_HEALTHY,                                  // 0.25 to 0.5
   PULLBACK_DEPTH_DEEP,                                     // 0.5 to 0.75, still inside the structure
   PULLBACK_DEPTH_WEAK,                                     // 0.75 to 1: the structure is weak
   PULLBACK_DEPTH_INVALID,                                  // 1 or more: it went through the leg before it
  };
//Working with Lifecycle
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
   LIFECYCLE_OBJECT_NONE = 0,                             // Not a lifecycle object
   LIFECYCLE_OBJECT_TRENDLINE,                            // Trendline
   LIFECYCLE_OBJECT_ZONE,                                 // Supply / Demand zone
   LIFECYCLE_OBJECT_PROTECTED_LEVEL,                      // Protected high / low
   LIFECYCLE_OBJECT_MOMENTUM,                             // Momentum candle (an event only: it is born and stays)
   LIFECYCLE_OBJECT_SUPPLYDEMAND,                         // Supply / Demand zone of a momentum candle
   LIFECYCLE_OBJECT_FVG,                                  // Fair value gap of a momentum candle
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
   LIFECYCLE_DEAD_BROKEN,                                   // Price broke it
   LIFECYCLE_DEAD_REPLACED,                                 // The lines of a newer swing took its place
  };
 //+------------------------------------------------------------------+
 //| Lifecycle event integer properties. One record = one event of    |
 //| one object; the object is told by kind+symbol+period+direction+  |
 //| origin time. Geometry = two anchors (time, price), as the native |
 //| trend line and rectangle have                                    |
 //+------------------------------------------------------------------+
 enum ENUM_LIFECYCLE_PROP_INTEGER
  {
   LIFECYCLE_PROP_CODE = 0,                                 // Unique code of the record (event+object+time) - Primary Key
   LIFECYCLE_PROP_TIME,                                     // Bar time of the event
   LIFECYCLE_PROP_EVENT,                                    // ENUM_LIFECYCLE_EVENT
   LIFECYCLE_PROP_KIND,                                     // ENUM_LIFECYCLE_OBJECT_KIND
   LIFECYCLE_PROP_ORIGIN_TIME,                              // Time the object was born
   LIFECYCLE_PROP_PERIOD,                                   // Timeframe
   LIFECYCLE_PROP_DIRECTION,                                // ENUM_SIGNAL_DIR: BUY = support (below price), SELL = resistance (above price)
   LIFECYCLE_PROP_SOURCE,                                   // ENUM_LIFECYCLE_SOURCE (meaningful on BORN)
   LIFECYCLE_PROP_DEAD_REASON,                              // ENUM_LIFECYCLE_DEAD_REASON (meaningful on DEAD)
   LIFECYCLE_PROP_ANCHOR_A_TIME,                            // Time of the first anchor (trendline: first point, zone: left edge)
   LIFECYCLE_PROP_ANCHOR_B_TIME,                            // Time of the second anchor (trendline: second point, zone: right edge)
  };
 #define LIFECYCLE_PROP_INTEGER_TOTAL (11)                   // Total number of integer properties
 #define LIFECYCLE_PROP_INTEGER_SKIP  (0)                    // Number of properties not used in sorting
 //+------------------------------------------------------------------+
 //| Lifecycle event real properties                                  |
 //+------------------------------------------------------------------+
 enum ENUM_LIFECYCLE_PROP_DOUBLE
  {
   LIFECYCLE_PROP_ANCHOR_A_PRICE = LIFECYCLE_PROP_INTEGER_TOTAL, // Price of the first anchor (zone: top)
   LIFECYCLE_PROP_ANCHOR_B_PRICE,                           // Price of the second anchor (zone: bottom)
  };
 #define LIFECYCLE_PROP_DOUBLE_TOTAL (2)                     // Total number of real properties
 #define LIFECYCLE_PROP_DOUBLE_SKIP  (0)                     // Number of properties not used in sorting
 //+------------------------------------------------------------------+
 //| Lifecycle event string properties                                |
 //+------------------------------------------------------------------+
 enum ENUM_LIFECYCLE_PROP_STRING
  {
   LIFECYCLE_PROP_SYMBOL = (LIFECYCLE_PROP_INTEGER_TOTAL+LIFECYCLE_PROP_DOUBLE_TOTAL), // Symbol
  };
 #define LIFECYCLE_PROP_STRING_TOTAL (1)                     // Total number of string properties
 //+------------------------------------------------------------------+
 //| Possible lifecycle event sorting criteria                        |
 //+------------------------------------------------------------------+
 #define FIRST_LIFECYCLE_DBL_PROP (LIFECYCLE_PROP_INTEGER_TOTAL-LIFECYCLE_PROP_INTEGER_SKIP)
 #define FIRST_LIFECYCLE_STR_PROP (LIFECYCLE_PROP_INTEGER_TOTAL-LIFECYCLE_PROP_INTEGER_SKIP+LIFECYCLE_PROP_DOUBLE_TOTAL-LIFECYCLE_PROP_DOUBLE_SKIP)
 enum ENUM_SORT_LIFECYCLE_MODE
  {
   //--- Sort by integer properties
    SORT_BY_LIFECYCLE_CODE = 0,                              // Sort by unique code
    SORT_BY_LIFECYCLE_TIME,                                  // Sort by event time
    SORT_BY_LIFECYCLE_EVENT,                                 // Sort by event
    SORT_BY_LIFECYCLE_KIND,                                  // Sort by object kind
    SORT_BY_LIFECYCLE_ORIGIN_TIME,                           // Sort by birth time of the object
    SORT_BY_LIFECYCLE_PERIOD,                                // Sort by timeframe
    SORT_BY_LIFECYCLE_DIRECTION,                             // Sort by direction
    SORT_BY_LIFECYCLE_SOURCE,                                // Sort by source (auto/user)
    SORT_BY_LIFECYCLE_DEAD_REASON,                           // Sort by reason of death
    SORT_BY_LIFECYCLE_ANCHOR_A_TIME,                         // Sort by time of the first anchor
    SORT_BY_LIFECYCLE_ANCHOR_B_TIME,                         // Sort by time of the second anchor
   //--- Sort by real properties
    SORT_BY_LIFECYCLE_ANCHOR_A_PRICE = FIRST_LIFECYCLE_DBL_PROP, // Sort by price of the first anchor
    SORT_BY_LIFECYCLE_ANCHOR_B_PRICE,                        // Sort by price of the second anchor
   //--- Sort by string properties
    SORT_BY_LIFECYCLE_SYMBOL = FIRST_LIFECYCLE_STR_PROP,     // Sort by symbol
  };
#endif // __MARKET_STRUCTURE_DEFINES_MQH__
