//+------------------------------------------------------------------+
//|                                       MarketStructureDefines.mqh |
//| Market Structure events (BOS / CHoCH) - own enum space, same     |
//| shape as SwingDefines.mqh.                                       |
//+------------------------------------------------------------------+
#ifndef __MARKET_STRUCTURE_DEFINES_MQH__
#define __MARKET_STRUCTURE_DEFINES_MQH__
#include "TimeseriesDefines.mqh"

//+------------------------------------------------------------------+
//| Market structure event: a candle closed beyond the reference     |
//| Swing - with the trend (BOS) or against it (CHoCH)               |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE_TYPE
 {
  MARKET_STRUCTURE_NONE = 0,                               // No event
  MARKET_STRUCTURE_BOS,                                     // Break of Structure (continuation)
  MARKET_STRUCTURE_CHOCH,                                   // Change of Character (reversal)
 };
//+------------------------------------------------------------------+
//| Market structure integer properties                              |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE_PROP_INTEGER
 {
  MARKET_STRUCTURE_PROP_CODE = 0,                          // Unique code (time+type+period+symbol) - Primary Key
  MARKET_STRUCTURE_PROP_TIME,                              // Time of the candle that closed beyond the Swing - FK to CBar
  MARKET_STRUCTURE_PROP_TYPE,                              // ENUM_MARKET_STRUCTURE_TYPE (BOS/CHoCH)
  MARKET_STRUCTURE_PROP_DIRECTION,                         // ENUM_SIGNAL_DIR of the break (BUY = closed above, SELL = closed below)
  MARKET_STRUCTURE_PROP_PERIOD,                            // Timeframe
  MARKET_STRUCTURE_PROP_SWING_TIME,                        // Pivot time of the broken Swing - FK to CBarSwingSeries
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
#endif // __MARKET_STRUCTURE_DEFINES_MQH__
