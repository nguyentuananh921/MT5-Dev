//--- Enumeration of position properties
enum ENUM_POSITION_PROPERTIES
  {
   P_TOTAL_DEALS     = 0,
   P_SYMBOL          = 1,
   P_MAGIC           = 2,
   P_COMMENT         = 3,
   P_SWAP            = 4,
   P_COMMISSION      = 5,
   P_PRICE_FIRST_DEAL= 6,
   P_PRICE_OPEN      = 7,
   P_PRICE_CURRENT   = 8,
   P_PRICE_LAST_DEAL = 9,
   P_MONEY_PROFIT    = 10,
   P_POINTS_PROFIT   = 11,
   P_VOLUME          = 12,
   P_INITIAL_VOLUME  = 13,
   P_SL              = 14,
   P_TP              = 15,
   P_TIME            = 16,
   P_DURATION        = 17,
   P_ID              = 18,
   P_TYPE            = 19,
   P_ALL             = 20
  };
//--- Enumeration of symbol properties
enum ENUM_SYMBOL_PROPERTIES
  {
   S_DIGITS          = 0,
   S_SPREAD          = 1,
   S_STOPSLEVEL      = 2,
   S_POINT           = 3,
   S_ASK             = 4,
   S_BID             = 5,
   S_VOLUME_MIN      = 6,
   S_VOLUME_MAX      = 7,
   S_VOLUME_LIMIT    = 8,
   S_VOLUME_STEP     = 9,
   S_FILTER          = 10,
   S_UP_LEVEL        = 11,
   S_DOWN_LEVEL      = 12,
   S_EXECUTION_MODE  = 13,
   S_ALL             = 14
  };
//--- Enumeration of deal properties
enum ENUM_DEAL_PROPERTIES
  {
   D_SYMBOL     = 0, // Symbol
   D_COMMENT    = 1, // Comment
   D_TYPE       = 2, // Type
   D_ENTRY      = 3, // Direction
   D_PRICE      = 4, // Price
   D_PROFIT     = 5, // Profit/Loss
   D_VOLUME     = 6, // Volume
   D_SWAP       = 7, // Swap
   D_COMMISSION = 8, // Commission
   D_TIME       = 9, // Time
   D_ALL        = 10 // All of the above deal properties
  };
//--- Position duration
enum ENUM_POSITION_DURATION
  {
   DAYS     = 0, // Days
   HOURS    = 1, // Hours
   MINUTES  = 2, // Minutes
   SECONDS  = 3  // Seconds
  };
//--- Sounds
enum ENUM_SOUNDS
  {
   SOUND_ERROR             =0,   // Error
   SOUND_OPEN_POSITION     = 1,  // Position opening/position volume increase/pending order triggering
   SOUND_ADJUST_ORDER      = 2,  // Stop Loss/Take Profit/pending order setting
   SOUND_CLOSE_WITH_PROFIT = 3,  // Position closing at profit
   SOUND_CLOSE_WITH_LOSS   = 4   // Position closing at loss
  };
//+------------------------------------------------------------------+
