//+------------------------------------------------------------------+
//|                                                  TickDefines.mqh |
//|Lib https://www.mql5.com/en/articles/14710                        |
//|     Defines for the ticks of a symbol (RAM only: MT5 keeps them) |
//+------------------------------------------------------------------+
//--- Change from V2 Entities\Defines\TimeseriesDefines.mqh and CommonDefines.mqh (DoEasy Defines.mqh): the tick part only
#ifndef __TICKDEFINES_MQH__
#define __TICKDEFINES_MQH__
 #include "CommonDefines.mqh"
 #define TICKSERIES_DEFAULT_DAYS_COUNT  (1)        // Required number of days for tick data in default series
 #define TICKSERIES_MAX_DATA_TOTAL      (200000)   // Maximum number of stored tick data of a single symbol
 #define TICK_PAUSE_SECONDS             (60)       // no tick for this long: the symbol rests (a closed market), its hands rest too (Python main.py TICK_PAUSE_SECONDS)
 enum ENUM_TICK_PROP_INTEGER
  {
   TICK_PROP_TIME_MSC = 0,                                  // Time of the last price update in milliseconds
   TICK_PROP_TIME,                                          // Time of the last update
   TICK_PROP_VOLUME,                                        // Volume for the current Last price
   TICK_PROP_FLAGS,                                         // Tick flags
  };
 #define TICK_PROP_INTEGER_TOTAL (4)
 enum ENUM_TICK_PROP_DOUBLE
  {
   TICK_PROP_BID = TICK_PROP_INTEGER_TOTAL,                 // Tick Bid price
   TICK_PROP_ASK,                                           // Tick Ask price
   TICK_PROP_LAST,                                          // Current price of the last trade (Last)
   TICK_PROP_VOLUME_REAL,                                   // Volume for the current Last price with greater accuracy
  };                                                        // no TICK_PROP_SPREAD (DoEasy): Ask - Bid of the tick is the one spread (CTick::Spread), not kept twice
 #define TICK_PROP_DOUBLE_TOTAL  (4)
 enum ENUM_TICK_PROP_STRING
  {
   TICK_PROP_SYMBOL = (TICK_PROP_INTEGER_TOTAL+TICK_PROP_DOUBLE_TOTAL), // Tick symbol
  };
 #define TICK_PROP_STRING_TOTAL  (1)
 //--- The lists of ticks are sorted by the time in milliseconds (the mode of Compare)
 enum ENUM_SORT_TICK_MODE
  {
   SORT_BY_TICK_TIME_MSC = 0,
  };
#endif // __TICKDEFINES_MQH__
