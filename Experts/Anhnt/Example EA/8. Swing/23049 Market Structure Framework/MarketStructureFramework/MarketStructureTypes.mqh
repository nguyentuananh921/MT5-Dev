//+------------------------------------------------------------------+
//|                             MarketStructureTypes.mqh             |
//|                             Copyright 2026, MetaQuotes           |
//|                             https://www.mql5.com                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_TYPE
  {
   EVENT_SWING_HIGH_CREATED,        // new swing high confirmed
   EVENT_SWING_LOW_CREATED,         // new swing low confirmed
   EVENT_INTERNAL_BOS_BULLISH,      // internal break of structure, bullish continuation
   EVENT_INTERNAL_BOS_BEARISH,      // internal break of structure, bearish continuation
   EVENT_EXTERNAL_BOS_BULLISH,      // external break of structure, bullish continuation
   EVENT_EXTERNAL_BOS_BEARISH,      // external break of structure, bearish continuation
   EVENT_INTERNAL_CHOCH_BULLISH,    // internal change of character, potential bullish reversal
   EVENT_INTERNAL_CHOCH_BEARISH,    // internal change of character, potential bearish reversal
   EVENT_EXTERNAL_CHOCH_BULLISH,    // external change of character, potential bullish reversal
   EVENT_EXTERNAL_CHOCH_BEARISH,    // external change of character, potential bearish reversal
   EVENT_STATE_CHANGED              // market state machine transitioned to a new state
  };

enum ENUM_MARKET_STATE
  {
   STATE_UNKNOWN,                   // initial state, insufficient data
   STATE_BULLISH,                   // market structurally bullish
   STATE_BEARISH,                   // market structurally bearish
   STATE_TRANSITION,                // potential reversal detected (CHoCH)
   STATE_RANGE                      // no clear directional trend (consolidation)
  };

enum ENUM_STRUCTURE_LEVEL
  {
   LEVEL_INTERNAL,                  // current chart timeframe structure
   LEVEL_EXTERNAL                   // higher timeframe structure
  };

enum ENUM_FRAMEWORK_STATUS
  {
   FS_OK = 0,                       // framework operating normally
   FS_WAITING_FOR_DATA,             // external data or ATR not yet ready
   FS_PARAMETER_ERROR,              // invalid input parameters
   FS_ATR_ERROR,                    // ATR indicator handle creation failed
   FS_COPY_ERROR                    // incomplete price data copy
  };

//+------------------------------------------------------------------+
//| Helper class – reference-based counter for event IDs             |
//+------------------------------------------------------------------+
class CEventIdCounter
  {
   public:
    long               value;                                 // current counter value
                     CEventIdCounter() { value = 1; }
    long                Next() { return value++; }            // return next unique ID and increment
    long                Current() const { return value - 1; } // last issued ID (does not increment)
  };

//+------------------------------------------------------------------+
//| Structure for events                                             |
//+------------------------------------------------------------------+
struct SStructureEvent
  {
   long               eventId;           // unique event identifier
   ENUM_EVENT_TYPE    type;              // kind of structural event
   datetime           time;              // bar time when event occurred
   double             price;             // price level associated with the event
   ENUM_STRUCTURE_LEVEL level;           // internal or external
   int                direction;         // 1 = bullish, -1 = bearish, 0 = neutral
   ENUM_MARKET_STATE  state;             // market state after the event (for state-change events)
   double             confidence;        // quality score 0–100
  };

//+------------------------------------------------------------------+
//| Swing point data (time-based)                                    |
//+------------------------------------------------------------------+
struct SSwingPoint
  {
   datetime          time;               // timestamp of the swing
   double            price;              // price at the swing extreme
   bool              isHigh;             // true = swing high, false = swing low
   double            confidence;         // heuristic quality score 0–100
  };

//+------------------------------------------------------------------+
//| Structure snapshot for consumer                                  |
//+------------------------------------------------------------------+
struct SStructureSnapshot
  {
   int               trend;              // current trend: 1 bullish, -1 bearish, 0 neutral
   double            protectedHigh;      // active protected high price (0 if none)
   datetime          highTime;           // time of the protected high
   bool              highValid;          // true if a protected high exists
   double            protectedLow;       // active protected low price (0 if none)
   datetime          lowTime;            // time of the protected low
   bool              lowValid;           // true if a protected low exists
   SSwingPoint       recentHighs[3];     // up to 3 most recent swing highs
   int               highCount;          // actual number of recent highs stored
   SSwingPoint       recentLows[3];      // up to 3 most recent swing lows
   int               lowCount;           // actual number of recent lows stored
  };

//+------------------------------------------------------------------+
//| Event signature for deduplication                                |
//+------------------------------------------------------------------+
struct EventSignature
  {
   ENUM_EVENT_TYPE      type;            // event type
   datetime             time;            // event time
   double               price;           // event price
   ENUM_STRUCTURE_LEVEL level;           // event structure level
  };

//+------------------------------------------------------------------+
//| Break event structure                                            |
//+------------------------------------------------------------------+
struct SBreakEvent
  {
   datetime          time;               // time of the bar that broke the level
   double            price;              // price of the broken level
   bool              isHighBreak;        // true = high break, false = low break
   bool              isCloseBeyond;      // true = bar closed beyond the level
   double            distanceATR;        // breakout distance measured in ATR multiples
  };

//+------------------------------------------------------------------+
//| Protected level structure                                        |
//+------------------------------------------------------------------+
struct SProtectedLevel
  {
   datetime          time;               // time of the swing that defines the level
   double            price;              // price of the level
   bool              isHigh;             // true = protected high, false = protected low
   bool              isValid;            // true = level is currently active (not yet broken)
  };
//+------------------------------------------------------------------+