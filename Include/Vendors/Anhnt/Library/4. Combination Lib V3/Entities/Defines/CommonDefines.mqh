//+------------------------------------------------------------------+
//|                                               CommonDefines.mqh  |
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __COMMON_DEFINES_MQH__
#define __COMMON_DEFINES_MQH__
//+------------------------------------------------------------------+
  //| Macro substitutions                                              |
  //+------------------------------------------------------------------+
  //--- Symbol parameters
   #define CLR_MW_DEFAULT                 (0xFF000000)               // Default symbol background color in the Market Watch
 //--- Collection list IDs (only the collections V3 has; the values are the V2 ones)
  //--- Parameters of the DOM snapshot series
  #define MBOOKSERIES_DEFAULT_DAYS_COUNT (1)                        // The default required number of days for DOM snapshots in the series
  #define MBOOKSERIES_MAX_DATA_TOTAL     (200000)                   // Maximum number of stored DOM snapshots of a single symbol
  #define PENDING_REQUEST_ID_TYPE_ERR    (1)                        // Type of a pending request created based on the server return code
  #define PENDING_REQUEST_ID_TYPE_REQ    (2)                        // Type of a pending request created by request
  #define COLLECTION_ACCOUNT_ID          (0x777D)                   // Account collection list ID
  #define COLLECTION_SYMBOLS_ID          (0x777E)                   // Symbol collection list ID

  #define COLLECTION_CHARTS_ID           (0x7787)                   // Chart collection list ID
  #define COLLECTION_INDICATORS_ID       (0x7782)                   // Indicator collection list ID
  //--- Describe the function with the error line number
   #define DFUN_ERR_LINE                  (__FUNCTION__+(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian" ? ", Page " : ", Line ")+(string)__LINE__+": ")
   #define DFUN                           (__FUNCTION__+": ")        // "Function description"
   #define END_TIME                       (D'31.12.3000 23:59:59')   // End date for account history data requests
  //--- Default font, control corner area
   #define DEF_FONT                                      ("Calibri")          // Default font
   #define DEF_FONT_SIZE                                 (10)                  // Default font size
   #define DEF_CONTROL_CORNER_AREA                       (4)                  // Number of pixels defining the corner area to resize
  //Lines
   #define DEF_LINE_WIDTH                                (3)                  // Default width of a native line object (solid: a dash style needs width 1)
   
//+------------------------------------------------------------------+
 //|  Logging level                                                   |
 //+------------------------------------------------------------------+
 enum ENUM_LOG_LEVEL
  {
   LOG_LEVEL_NO_MSG,                                        // Logging disabled
   LOG_LEVEL_ERROR_MSG,                                     // Errors only
   LOG_LEVEL_ALL_MSG                                        // Full logging
  };

 //+------------------------------------------------------------------+
 //| Signal direction                                                 |
 //+------------------------------------------------------------------+
 enum ENUM_SIGNAL_DIR
  {
   SIGNAL_NONE =  0,                                        // No signal
   SIGNAL_BUY  =  1,                                        // Buy
   SIGNAL_SELL = -1                                         // Sell
  };

  //+------------------------------------------------------------------+
 //| List of library object types                                     |
 //+------------------------------------------------------------------+
 enum ENUM_OBJECT_DE_TYPE
  {
   //--- Base objects
    OBJECT_DE_TYPE_BASE,                                           // Base object for all library objects
    OBJECT_DE_TYPE_BASE_EXT,                                       // Extended base object for all library objects
    // Pure Data
      OBJECT_DE_TYPE_SYMBOLTF_SETTING,                                // "Symbol+TF config row (CSymbolTFSetting)" object type
      OBJECT_DE_TYPE_PATTERN_SETTING,                                 // "Candle pattern config row (CPatternSetting)" object type
      OBJECT_DE_TYPE_INDICATOR_SETTING,                               // "Indicator template config row (CIndicatorSetting)" object type
    // Time Serries
      OBJECT_DE_TYPE_SERIES_SWING,                                   // "Swing point" object type
      OBJECT_DE_TYPE_SERIES_MARKET_STRUCTURE,                        // "Market structure event" object type
    // Data units
      OBJECT_DE_TYPE_LONG,                                           // "Long type data" object type
      OBJECT_DE_TYPE_DOUBLE,                                         // "Double type data" object type
      OBJECT_DE_TYPE_STRING,                                         // "String type data" object type
      OBJECT_DE_TYPE_OBJECT,                                         // "Object type data" object type
   //--- Graphics
    OBJECT_DE_TYPE_GBASE,                                          // Base object of all library graphical objects
   //--- Standard graphical objects (keep last: values are OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_xxx)
    OBJECT_DE_TYPE_GSTD_OBJ,                                       // Standard graphical object
    OBJECT_DE_TYPE_GSTD_TREND              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TREND,            // "Trend line" object type
    OBJECT_DE_TYPE_GSTD_RECTANGLE          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE,        // "Rectangle" object type
    OBJECT_DE_TYPE_GSTD_TRIANGLE           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TRIANGLE,         // "Triangle" object type
    OBJECT_DE_TYPE_GSTD_TEXT               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TEXT,             // "Text" object type
    OBJECT_DE_TYPE_GSTD_RECTANGLE_LABEL    =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE_LABEL,  // "Rectangle label" object type
   //Trading information
   //Symbol
     OBJECT_DE_TYPE_SYMBOL,                                                                   // "Symbol" object type
     OBJECT_DE_TYPE_SYMBOL_COMMON,                                  // "Common group symbol" object type
     OBJECT_DE_TYPE_TRADE,                                          // "Trading object" object type
   //Account
     OBJECT_DE_TYPE_ACCOUNT,                                        // "Account" object type
   //Order
     OBJECT_DE_TYPE_ORDER_DEAL_POSITION,                            // "Order/Deal/Position" object type
    //Order History
     OBJECT_DE_TYPE_HISTORY_BALANCE,                                // "Historical balance operation" object type
     OBJECT_DE_TYPE_HISTORY_DEAL,                                   // "Historical deal" object type
     OBJECT_DE_TYPE_HISTORY_ORDER_MARKET,                           // "Historical market order" object type
     OBJECT_DE_TYPE_HISTORY_ORDER_PENDING,                          // "Historical removed pending order" object type
    //Market Order
     OBJECT_DE_TYPE_MARKET_ORDER,                                   // "Market order" object type
     OBJECT_DE_TYPE_MARKET_PENDING,                                 // "Pending order" object type
     OBJECT_DE_TYPE_MARKET_POSITION,                                // "Market position" object type
     OBJECT_DE_TYPE_BOOK_ORDER,                                     // "Book order" object type
    //Book Order
     OBJECT_DE_TYPE_BOOK_BUY,                                       // "Book buy order" object type
     OBJECT_DE_TYPE_BOOK_BUY_MARKET,                                // "Book buy order at market price" object type
     OBJECT_DE_TYPE_BOOK_SELL,                                      // "Book sell order" object type
     OBJECT_DE_TYPE_BOOK_SELL_MARKET,                               // "Book sell order at market price" object type
     OBJECT_DE_TYPE_BOOK_SNAPSHOT,                                  // "Book snapshot" object type
     OBJECT_DE_TYPE_BOOK_SERIES,                                    // "Book snapshot series" object type
    //Pending Request
     OBJECT_DE_TYPE_PENDING_REQUEST,                                // "Pending trading request" object type
     OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_OPEN,                  // "Pending request to open a position" object type
     OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_CLOSE,                 // "Pending request to close a position" object type
     OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_SLTP,                  // "Pending request to modify position stop orders" object type
     OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_PLACE,                    // "Pending request to place a pending order" object type
     OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_REMOVE,                   // "Pending request to delete a pending order" object type
     OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_MODIFY,                   // "Pending request to modify pending order parameters" object type
    //Trading Event
     OBJECT_DE_TYPE_EVENT,                                          // "Event" object type
     OBJECT_DE_TYPE_EVENT_BALANCE,                                  // "Balance operation event" object type
     OBJECT_DE_TYPE_EVENT_MODIFY,                                   // "Pending order/position modification event" object type
     OBJECT_DE_TYPE_EVENT_ORDER_PLASED,                             // "Placing a pending order event" object type
     OBJECT_DE_TYPE_EVENT_ORDER_REMOVED,                            // "Pending order removal event" object type
     OBJECT_DE_TYPE_EVENT_POSITION_CLOSE,                           // "Position closure event" object type
     OBJECT_DE_TYPE_EVENT_POSITION_OPEN,                            // "Position opening event" object type
     OBJECT_DE_TYPE_EVENT_POSITION_REOPEN,                        // "Position reopening event" object type
   // Indicator
     OBJECT_DE_TYPE_INDICATOR,                                      // "Indicator" object type
     OBJECT_DE_TYPE_INDICATOR_GRAPH,                                // "Indicator graph" object type
   //Chart
     OBJECT_DE_TYPE_CHART,                                          // "Chart" object type
     OBJECT_DE_TYPE_CHART_WND_IND,                                  // "Chart window indicator" object type
  };
 //+------------------------------------------------------------------+
 //| Possible event reasons of the object library base object         |
 //+------------------------------------------------------------------+
 enum ENUM_BASE_EVENT_REASON
  {
   BASE_EVENT_REASON_INC,                                   // Increase in the object property value
   BASE_EVENT_REASON_DEC,                                   // Decrease in the object property value
   BASE_EVENT_REASON_MORE_THEN,                             // Object property value exceeds the control value
   BASE_EVENT_REASON_LESS_THEN,                             // Object property value is less than the control value
   BASE_EVENT_REASON_EQUALS                                 // Object property value is equal to the control value
  };
 //+------------------------------------------------------------------+
 //| List of flags of possible order and position change options      |
 //+------------------------------------------------------------------+
 enum ENUM_CHANGE_TYPE_FLAGS
  {
   CHANGE_TYPE_FLAG_NO_CHANGE    =  0x0,                    // No changes
   CHANGE_TYPE_FLAG_TYPE         =  0x1,                    // Order type change
   CHANGE_TYPE_FLAG_PRICE        =  0x2,                    // Price change
   CHANGE_TYPE_FLAG_STOP         =  0x4,                    // StopLoss change
   CHANGE_TYPE_FLAG_TAKE         =  0x8,                    // TakeProfit change
   CHANGE_TYPE_FLAG_ORDER        =  0x10                    // Order properties change flag
  };
 //+------------------------------------------------------------------+
 //| Possible order and position change options                       |
 //+------------------------------------------------------------------+
 enum ENUM_CHANGE_TYPE
  {
   CHANGE_TYPE_NO_CHANGE,                                   // No changes
   CHANGE_TYPE_ORDER_TYPE,                                  // Order type change
   CHANGE_TYPE_ORDER_PRICE,                                 // Order price change
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS,                       // Order and StopLoss price change 
   CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT,                     // Order and TakeProfit price change
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT,           // Order, StopLoss and TakeProfit price change
   CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT,                 // StopLoss and TakeProfit change
   CHANGE_TYPE_ORDER_STOP_LOSS,                             // Order's StopLoss change
   CHANGE_TYPE_ORDER_TAKE_PROFIT,                           // Order's TakeProfit change
   CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT,              // Change position's StopLoss and TakeProfit
   CHANGE_TYPE_POSITION_STOP_LOSS,                          // Change position's StopLoss
   CHANGE_TYPE_POSITION_TAKE_PROFIT,                        // Change position's TakeProfit
  };
 //+------------------------------------------------------------------+
 //| Search and sorting data                                          |
 //+------------------------------------------------------------------+
 enum ENUM_COMPARER_TYPE
  {
   EQUAL,                                                   // Equal
   MORE,                                                    // More
   LESS,                                                    // Less
   NO_EQUAL,                                                // Not equal
   EQUAL_OR_MORE,                                           // Equal or more
   EQUAL_OR_LESS                                            // Equal or less
  };
#endif // __COMMON_DEFINES_MQH__

