//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
/*
#include "DataSND.mqh"
#include "DataIMG.mqh"
#include "Data.mqh"
*/
#include <Vendors/Anhnt/CFramework/Defines/Defines.mqh>
#include <Vendors/Anhnt/CFramework/Old/DataSND.mqh>
#include <Vendors/Anhnt/CFramework/Old/DataIMG.mqh>
#include <Vendors/Anhnt/CFramework/Old/Data.mqh>
#ifdef __MQL4__
#include "ToMQL4.mqh"
#endif 
//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of library object types                                     |
//+------------------------------------------------------------------+
enum ENUM_OBJECT_DE_TYPE
  {
//--- Graphics
   OBJECT_DE_TYPE_GBASE =  COLLECTION_ID_LIST_END+1,              // "Base object of all library graphical objects" object type
   OBJECT_DE_TYPE_GELEMENT,                                       // "Graphical element" object type
   OBJECT_DE_TYPE_GFORM,                                          // "Form" object type
   OBJECT_DE_TYPE_GFORM_CONTROL,                                  // "Form for managing pivot points of graphical object" object type
   OBJECT_DE_TYPE_GSHADOW,                                        // "Shadow" object type
   OBJECT_DE_TYPE_GGLARE,                                         // Glare object type
   //--- WinForms
   OBJECT_DE_TYPE_GWF_BASE,                                       // WinForms Base object type (base abstract WinForms object)
   OBJECT_DE_TYPE_GWF_CONTAINER,                                  // WinForms container object type
   OBJECT_DE_TYPE_GWF_COMMON,                                     // WinForms standard control object type
   OBJECT_DE_TYPE_GWF_HELPER,                                     // WinForms auxiliary control object type
//--- Animation
   OBJECT_DE_TYPE_GFRAME,                                         // "Single animation frame" object type
   OBJECT_DE_TYPE_GFRAME_TEXT,                                    // "Single text animation frame" object type
   OBJECT_DE_TYPE_GFRAME_QUAD,                                    // "Single rectangular animation frame" object type
   OBJECT_DE_TYPE_GFRAME_GEOMETRY,                                // "Single geometric animation frame" object type
   OBJECT_DE_TYPE_GANIMATIONS,                                    // "Animations" object type
//--- Managing graphical objects
   OBJECT_DE_TYPE_GELEMENT_CONTROL,                               // "Managing graphical objects" object type
//--- Standard graphical objects
   OBJECT_DE_TYPE_GSTD_OBJ,                                       // "Standard graphical object" object type
   OBJECT_DE_TYPE_GSTD_VLINE              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_VLINE,            // "Vertical line" object type
   OBJECT_DE_TYPE_GSTD_HLINE              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_HLINE,            // "Horizontal line" object type
   OBJECT_DE_TYPE_GSTD_TREND              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TREND,            // "Trend line" object type
   OBJECT_DE_TYPE_GSTD_TRENDBYANGLE       =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TRENDBYANGLE,     // "Trend line by angle" object type
   OBJECT_DE_TYPE_GSTD_CYCLES             =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_CYCLES,           // "Cyclic lines" object type
   OBJECT_DE_TYPE_GSTD_ARROWED_LINE       =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROWED_LINE,     // "Arrowed line" object type
   OBJECT_DE_TYPE_GSTD_CHANNEL            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_CHANNEL,          // "Equidistant channel" object type
   OBJECT_DE_TYPE_GSTD_STDDEVCHANNEL      =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_STDDEVCHANNEL,    // "Standard deviation channel" object type
   OBJECT_DE_TYPE_GSTD_REGRESSION         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_REGRESSION,       // "Linear regression channel" object type
   OBJECT_DE_TYPE_GSTD_PITCHFORK          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_PITCHFORK,        // "Andrews' pitchfork" object type
   OBJECT_DE_TYPE_GSTD_GANNLINE           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_GANNLINE,         // "Gann line" object type
   OBJECT_DE_TYPE_GSTD_GANNFAN            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_GANNFAN,          // "Gann fan" object type
   OBJECT_DE_TYPE_GSTD_GANNGRID           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_GANNGRID,         // "Gann grid" object type
   OBJECT_DE_TYPE_GSTD_FIBO               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBO,             // "Fibo levels" object type
   OBJECT_DE_TYPE_GSTD_FIBOTIMES          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOTIMES,        // "Fibo time zones" object type
   OBJECT_DE_TYPE_GSTD_FIBOFAN            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOFAN,          // "Fibo fan" object type
   OBJECT_DE_TYPE_GSTD_FIBOARC            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOARC,          // "Fibo arcs" object type
   OBJECT_DE_TYPE_GSTD_FIBOCHANNEL        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOCHANNEL,      // "Fibo channel" object type
   OBJECT_DE_TYPE_GSTD_EXPANSION          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_EXPANSION,        // "Fibo expansion" object type
   OBJECT_DE_TYPE_GSTD_ELLIOTWAVE5        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ELLIOTWAVE5,      // "Elliott 5 waves" object type
   OBJECT_DE_TYPE_GSTD_ELLIOTWAVE3        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ELLIOTWAVE3,      // "Elliott 3 waves" object type
   OBJECT_DE_TYPE_GSTD_RECTANGLE          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE,        // "Rectangle" object type
   OBJECT_DE_TYPE_GSTD_TRIANGLE           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TRIANGLE,         // "Triangle" object type
   OBJECT_DE_TYPE_GSTD_ELLIPSE            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ELLIPSE,          // "Ellipse" object type
   OBJECT_DE_TYPE_GSTD_ARROW_THUMB_UP     =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_THUMB_UP,   // "Thumb up" object type
   OBJECT_DE_TYPE_GSTD_ARROW_THUMB_DOWN   =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_THUMB_DOWN, // "Thumb down" object type
   OBJECT_DE_TYPE_GSTD_ARROW_UP           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_UP,         // "Arrow up" object type
   OBJECT_DE_TYPE_GSTD_ARROW_DOWN         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_DOWN,       // "Arrow down" object type
   OBJECT_DE_TYPE_GSTD_ARROW_STOP         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_STOP,       // "Stop sign" object type
   OBJECT_DE_TYPE_GSTD_ARROW_CHECK        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_CHECK,      // "Check mark" object type
   OBJECT_DE_TYPE_GSTD_ARROW_LEFT_PRICE   =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_LEFT_PRICE, // "Left price label" object type
   OBJECT_DE_TYPE_GSTD_ARROW_RIGHT_PRICE  =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_RIGHT_PRICE,// "Right price label" object type
   OBJECT_DE_TYPE_GSTD_ARROW_BUY          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_BUY,        // "Buy" object type
   OBJECT_DE_TYPE_GSTD_ARROW_SELL         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_SELL,       // "Sell" object type
   OBJECT_DE_TYPE_GSTD_ARROW              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW,            // "Arrow" object type
   OBJECT_DE_TYPE_GSTD_TEXT               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TEXT,             // "Text" object type
   OBJECT_DE_TYPE_GSTD_LABEL              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_LABEL,            // "Text label" object type
   OBJECT_DE_TYPE_GSTD_BUTTON             =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_BUTTON,           // "Button" object type
   OBJECT_DE_TYPE_GSTD_CHART              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_CHART,            // "Chart" object type
   OBJECT_DE_TYPE_GSTD_BITMAP             =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_BITMAP,           // "Bitmap" object type
   OBJECT_DE_TYPE_GSTD_BITMAP_LABEL       =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_BITMAP_LABEL,     // "Bitmap label" object type
   OBJECT_DE_TYPE_GSTD_EDIT               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_EDIT,             // "Edit" object type
   OBJECT_DE_TYPE_GSTD_EVENT              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_EVENT,            // "Event object which corresponds to an event in Economic Calendar" object type
   OBJECT_DE_TYPE_GSTD_RECTANGLE_LABEL    =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE_LABEL,  // "Event object which corresponds to an event in Economic Calendar" object type
   
//--- Objects
   OBJECT_DE_TYPE_BASE  =  OBJECT_DE_TYPE_GSTD_RECTANGLE_LABEL+1, // Base object for all library objects
   OBJECT_DE_TYPE_BASE_EXT,                                       // Extended base object for all library objects
   
   OBJECT_DE_TYPE_ACCOUNT,                                        // "Account" object type
   OBJECT_DE_TYPE_BOOK_ORDER,                                     // "Book order" object type
   OBJECT_DE_TYPE_BOOK_BUY,                                       // "Book buy order" object type
   OBJECT_DE_TYPE_BOOK_BUY_MARKET,                                // "Book buy order at market price" object type
   OBJECT_DE_TYPE_BOOK_SELL,                                      // "Book sell order" object type
   OBJECT_DE_TYPE_BOOK_SELL_MARKET,                               // "Book sell order at market price" object type
   OBJECT_DE_TYPE_BOOK_SNAPSHOT,                                  // "Book snapshot" object type
   OBJECT_DE_TYPE_BOOK_SERIES,                                    // "Book snapshot series" object type
   
   OBJECT_DE_TYPE_CHART,                                          // "Chart" object type
   OBJECT_DE_TYPE_CHART_WND,                                      // "Chart window" object type
   OBJECT_DE_TYPE_CHART_WND_IND,                                  // "Chart window indicator" object type
   
   OBJECT_DE_TYPE_EVENT,                                          // "Event" object type
   OBJECT_DE_TYPE_EVENT_BALANCE,                                  // "Balance operation event" object type
   OBJECT_DE_TYPE_EVENT_MODIFY,                                   // "Pending order/position modification event" object type
   OBJECT_DE_TYPE_EVENT_ORDER_PLASED,                             // "Placing a pending order event" object type
   OBJECT_DE_TYPE_EVENT_ORDER_REMOVED,                            // "Pending order removal event" object type
   OBJECT_DE_TYPE_EVENT_POSITION_CLOSE,                           // "Position closure event" object type
   OBJECT_DE_TYPE_EVENT_POSITION_OPEN,                            // "Position opening event" object type
   
   OBJECT_DE_TYPE_IND_BUFFER,                                     // "Indicator buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_ARROW,                               // "Arrow rendering buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_BAR,                                 // "Bar buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_CALCULATE,                           // "Calculated buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_CANDLE,                              // "Candle buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_FILLING,                             // "Filling buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_HISTOGRAMM,                          // "Histogram buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_HISTOGRAMM2,                         // "Histogram 2 buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_LINE,                                // "Line buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_SECTION,                             // "Section buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_ZIGZAG,                              // "Zigzag buffer" object type
   OBJECT_DE_TYPE_INDICATOR,                                      // "Indicator" object type
   OBJECT_DE_TYPE_IND_DATA,                                       // "Indicator data" object type
   OBJECT_DE_TYPE_IND_DATA_LIST,                                  // "Indicator data list" object type
   
   OBJECT_DE_TYPE_IND_AC,                                         // "Accelerator Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_AD,                                         // "Accumulation/Distribution indicator" object type
   OBJECT_DE_TYPE_IND_ADX,                                        // "Average Directional Index indicator" object type
   OBJECT_DE_TYPE_IND_ADXW,                                       // "ADX indicator by Welles Wilder" object type
   OBJECT_DE_TYPE_IND_ALLIGATOR,                                  // "Alligator indicator" object type
   OBJECT_DE_TYPE_IND_AMA,                                        // "Adaptive Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_AO,                                         // "Awesome Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_ATR,                                        // "Average True Range" object type
   OBJECT_DE_TYPE_IND_BANDS,                                      // "Bollinger Bands® indicator" object type
   OBJECT_DE_TYPE_IND_BEARS,                                      // "Bears Power indicator" object type
   OBJECT_DE_TYPE_IND_BULLS,                                      // "Bulls Power indicator" object type
   OBJECT_DE_TYPE_IND_BWMFI,                                      // "Market Facilitation Index indicator" object type
   OBJECT_DE_TYPE_IND_CCI,                                        // "Commodity Channel Index indicator" object type
   OBJECT_DE_TYPE_IND_CHAIKIN,                                    // "Chaikin Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_CUSTOM,                                     // "Custom indicator" object type
   OBJECT_DE_TYPE_IND_DEMA,                                       // "Double Exponential Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_DEMARKER,                                   // "DeMarker indicator" object type
   OBJECT_DE_TYPE_IND_ENVELOPES,                                  // "Envelopes indicator" object type
   OBJECT_DE_TYPE_IND_FORCE,                                      // "Force Index indicator" object type
   OBJECT_DE_TYPE_IND_FRACTALS,                                   // "Fractals indicator" object type
   OBJECT_DE_TYPE_IND_FRAMA,                                      // "Fractal Adaptive Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_GATOR,                                      // "Gator Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_ICHIMOKU,                                   // "Ichimoku Kinko Hyo indicator" object type
   OBJECT_DE_TYPE_IND_MA,                                         // "Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_MACD,                                       // "Moving Average Convergence/Divergence indicator" object type
   OBJECT_DE_TYPE_IND_MFI,                                        // "Money Flow Index indicator" object type
   OBJECT_DE_TYPE_IND_MOMENTUM,                                   // "Momentum indicator" object type
   OBJECT_DE_TYPE_IND_OBV,                                        // "On Balance Volume indicator" object type
   OBJECT_DE_TYPE_IND_OSMA,                                       // "Moving Average of Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_RSI,                                        // "Relative Strength Index indicator" object type
   OBJECT_DE_TYPE_IND_RVI,                                        // "Relative Vigor Index indicator" object type
   OBJECT_DE_TYPE_IND_SAR,                                        // "Parabolic SAR indicator" object type
   OBJECT_DE_TYPE_IND_STDEV,                                      // "Standard Deviation indicator" object type
   OBJECT_DE_TYPE_IND_STOCH,                                      // "Stochastic Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_TEMA,                                       // "Triple Exponential Moving Average indicator" object
   OBJECT_DE_TYPE_IND_TRIX,                                       // "Triple Exponential Moving Averages Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_VIDYA,                                      // "Variable Index Dynamic Average indicator" object type
   OBJECT_DE_TYPE_IND_VOLUMES,                                    // "Volumes indicator" object type
   OBJECT_DE_TYPE_IND_WPR,                                        // "Williams' Percent Range indicator" object type
   
   OBJECT_DE_TYPE_MQL5_SIGNAL,                                    // "mql5 signal" object type
   
   OBJECT_DE_TYPE_ORDER_DEAL_POSITION,                            // "Order/Deal/Position" object type
   OBJECT_DE_TYPE_HISTORY_BALANCE,                                // "Historical balance operation" object type
   OBJECT_DE_TYPE_HISTORY_DEAL,                                   // "Historical deal" object type
   OBJECT_DE_TYPE_HISTORY_ORDER_MARKET,                           // "Historical market order" object type
   OBJECT_DE_TYPE_HISTORY_ORDER_PENDING,                          // "Historical removed pending order" object type
   OBJECT_DE_TYPE_MARKET_ORDER,                                   // "Market order" object type
   OBJECT_DE_TYPE_MARKET_PENDING,                                 // "Pending order" object type
   OBJECT_DE_TYPE_MARKET_POSITION,                                // "Market position" object type
   
   OBJECT_DE_TYPE_PENDING_REQUEST,                                // "Pending trading request" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_OPEN,                  // "Pending request to open a position" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_CLOSE,                 // "Pending request to close a position" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_SLTP,                  // "Pending request to modify position stop orders" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_PLACE,                    // "Pending request to place a pending order" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_REMOVE,                   // "Pending request to delete a pending order" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_MODIFY,                   // "Pending request to modify pending order parameters" object type
   
   OBJECT_DE_TYPE_SERIES_BAR,                                     // "Bar" object type
   OBJECT_DE_TYPE_SERIES_PERIOD,                                  // "Period timeseries" object type
   OBJECT_DE_TYPE_SERIES_SYMBOL,                                  // "Symbol timeseries" object type
   
   OBJECT_DE_TYPE_SERIES_PATTERN,                                 // "Pattern" object type
   OBJECT_DE_TYPE_SERIES_PATTERN_CONTROL,                         // "Pattern management" object type
   OBJECT_DE_TYPE_SERIES_PATTERNS_CONTROLLERS,                    // "Patterns management" object type
   
   OBJECT_DE_TYPE_SYMBOL,                                         // "Symbol" object type
   OBJECT_DE_TYPE_SYMBOL_BONDS,                                   // "Bond symbol" object type
   OBJECT_DE_TYPE_SYMBOL_CFD,                                     // "CFD (contract for difference) symbol" object type
   OBJECT_DE_TYPE_SYMBOL_COLLATERAL,                              // "Non-tradable asset symbol" object type" object type
   OBJECT_DE_TYPE_SYMBOL_COMMODITY,                               // "Commodity symbol" object type
   OBJECT_DE_TYPE_SYMBOL_COMMON,                                  // "Common group symbol" object type
   OBJECT_DE_TYPE_SYMBOL_CRYPTO,                                  // "Cryptocurrency symbol" object type
   OBJECT_DE_TYPE_SYMBOL_CUSTOM,                                  // "Custom symbol" object type
   OBJECT_DE_TYPE_SYMBOL_EXCHANGE,                                // "Exchange symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FUTURES,                                 // "Futures symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX,                                      // "Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_EXOTIC,                               // "Exotic Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_MAJOR,                                // "Major Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_MINOR,                                // "Minor Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_RUB,                                  // "RUB Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_INDEX,                                   // "Index symbol" object type
   OBJECT_DE_TYPE_SYMBOL_INDICATIVE,                              // "Indicative symbol" object type
   OBJECT_DE_TYPE_SYMBOL_METALL,                                  // "Metal symbol" object type
   OBJECT_DE_TYPE_SYMBOL_OPTION,                                  // "Option symbol" object type
   OBJECT_DE_TYPE_SYMBOL_STOCKS,                                  // "Stock symbol" object type
   
   OBJECT_DE_TYPE_TICK,                                           // "Tick" object type
   OBJECT_DE_TYPE_NEW_TICK,                                       // "New tick" object type
   OBJECT_DE_TYPE_TICKSERIES,                                     // "Tick data series" object type
   
   OBJECT_DE_TYPE_TRADE,                                          // "Trading object" object type
   
   OBJECT_DE_TYPE_LONG,                                           // "Long type data" object type
   OBJECT_DE_TYPE_DOUBLE,                                         // "Double type data" object type
   OBJECT_DE_TYPE_STRING,                                         // "String type data" object type
   OBJECT_DE_TYPE_OBJECT,                                         // "Object type data" object type
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
//+------------------------------------------------------------------+
//| Possible options of selecting by time                            |
//+------------------------------------------------------------------+
enum ENUM_SELECT_BY_TIME
  {
   SELECT_BY_TIME_OPEN,                                     // By open time (in milliseconds)
   SELECT_BY_TIME_CLOSE,                                    // By close time (in milliseconds)
  };
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
//| Data for working with orders                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract order type (status)                                     |
//+------------------------------------------------------------------+
enum ENUM_ORDER_STATUS
  {
   ORDER_STATUS_MARKET_PENDING,                             // Market pending order
   ORDER_STATUS_MARKET_ORDER,                               // Market order
   ORDER_STATUS_MARKET_POSITION,                            // Market position
   ORDER_STATUS_HISTORY_ORDER,                              // History market order
   ORDER_STATUS_HISTORY_PENDING,                            // Removed pending order
   ORDER_STATUS_BALANCE,                                    // Balance operation
   ORDER_STATUS_DEAL,                                       // Deal
   ORDER_STATUS_UNKNOWN                                     // Unknown status
  };
//+------------------------------------------------------------------+
//| Order, deal, position integer properties                         |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_INTEGER
  {
   ORDER_PROP_TICKET = 0,                                   // Order ticket
   ORDER_PROP_MAGIC,                                        // Real order magic number
   ORDER_PROP_TIME_OPEN,                                    // Open time in milliseconds (MQL5 Deal time)
   ORDER_PROP_TIME_CLOSE,                                   // Close time in milliseconds (MQL5 Execution or removal time - ORDER_TIME_DONE)
   ORDER_PROP_TIME_EXP,                                     // Order expiration date (for pending orders)
   ORDER_PROP_TYPE_FILLING,                                 // Type of execution by remainder
   ORDER_PROP_TYPE_TIME,                                    // Order lifetime
   ORDER_PROP_STATUS,                                       // Order status (from the ENUM_ORDER_STATUS enumeration)
   ORDER_PROP_TYPE,                                         // Order/deal type
   ORDER_PROP_REASON,                                       // Deal/order/position reason or source
   ORDER_PROP_STATE,                                        // Order status (from the ENUM_ORDER_STATE enumeration)
   ORDER_PROP_POSITION_ID,                                  // Position ID
   ORDER_PROP_POSITION_BY_ID,                               // Opposite position ID
   ORDER_PROP_DEAL_ORDER_TICKET,                            // Ticket of the order that triggered a deal
   ORDER_PROP_DEAL_ENTRY,                                   // Deal direction – IN, OUT or IN/OUT
   ORDER_PROP_TIME_UPDATE,                                  // Position change time in milliseconds
   ORDER_PROP_TICKET_FROM,                                  // Parent order ticket
   ORDER_PROP_TICKET_TO,                                    // Derived order ticket
   ORDER_PROP_PROFIT_PT,                                    // Profit in points
   ORDER_PROP_CLOSE_BY_SL,                                  // Flag of closing by StopLoss
   ORDER_PROP_CLOSE_BY_TP,                                  // Flag of closing by TakeProfit
   ORDER_PROP_MAGIC_ID,                                     // Order's "magic number" ID
   ORDER_PROP_GROUP_ID1,                                    // First order/position group ID
   ORDER_PROP_GROUP_ID2,                                    // Second order/position group ID
   ORDER_PROP_PEND_REQ_ID,                                  // Pending request ID
   ORDER_PROP_DIRECTION,                                    // Direction (Buy, Sell)
  }; 
#define ORDER_PROP_INTEGER_TOTAL    (26)                    // Total number of integer properties
#define ORDER_PROP_INTEGER_SKIP     (0)                     // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Order, deal, position real properties                            |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_DOUBLE
  {
   ORDER_PROP_PRICE_OPEN = ORDER_PROP_INTEGER_TOTAL,        // Open price (MQL5 deal price)
   ORDER_PROP_PRICE_CLOSE,                                  // Close price
   ORDER_PROP_SL,                                           // StopLoss price
   ORDER_PROP_TP,                                           // TaleProfit price
   ORDER_PROP_FEE,                                          // Deal fee (DEAL_FEE from ENUM_DEAL_PROPERTY_DOUBLE)
   ORDER_PROP_PROFIT,                                       // Profit
   ORDER_PROP_COMMISSION,                                   // Commission
   ORDER_PROP_SWAP,                                         // Swap
   ORDER_PROP_VOLUME,                                       // Volume
   ORDER_PROP_VOLUME_CURRENT,                               // Unexecuted volume
   ORDER_PROP_PROFIT_FULL,                                  // Profit+commission+swap
   ORDER_PROP_PRICE_STOP_LIMIT,                             // Limit order price when StopLimit order is activated
  };
#define ORDER_PROP_DOUBLE_TOTAL     (12)                    // Total number of real properties
//+------------------------------------------------------------------+
//| Order, deal, position string properties                          |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_STRING
  {
   ORDER_PROP_SYMBOL = (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL), // Order symbol
   ORDER_PROP_COMMENT,                                      // Order comment
   ORDER_PROP_COMMENT_EXT,                                  // Order custom comment
   ORDER_PROP_EXT_ID                                        // Order ID in an external trading system
  };
#define ORDER_PROP_STRING_TOTAL     (4)                     // Total number of string properties
//+------------------------------------------------------------------+
//| Possible criteria of sorting orders and deals                    |
//+------------------------------------------------------------------+
#define FIRST_ORD_DBL_PROP          (ORDER_PROP_INTEGER_TOTAL-ORDER_PROP_INTEGER_SKIP)
#define FIRST_ORD_STR_PROP          (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL-ORDER_PROP_INTEGER_SKIP)
enum ENUM_SORT_ORDERS_MODE
  {
//--- Sort by integer properties
   SORT_BY_ORDER_TICKET = 0,                                // Sort by an order ticket
   SORT_BY_ORDER_MAGIC,                                     // Sort by an order magic number
   SORT_BY_ORDER_TIME_OPEN,                                 // Sort by an order open time in milliseconds
   SORT_BY_ORDER_TIME_CLOSE,                                // Sort by an order close time in milliseconds
   SORT_BY_ORDER_TIME_EXP,                                  // Sort by an order expiration date
   SORT_BY_ORDER_TYPE_FILLING,                              // Sort by execution type by remainder
   SORT_BY_ORDER_TYPE_TIME,                                 // Sort by order lifetime
   SORT_BY_ORDER_STATUS,                                    // Sort by an order status (market order/pending order/deal/balance and credit operation)
   SORT_BY_ORDER_TYPE,                                      // Sort by an order type
   SORT_BY_ORDER_REASON,                                    // Sort by a deal/order/position reason/source
   SORT_BY_ORDER_STATE,                                     // Sort by an order status
   SORT_BY_ORDER_POSITION_ID,                               // Sort by a position ID
   SORT_BY_ORDER_POSITION_BY_ID,                            // Sort by an opposite position ID
   SORT_BY_ORDER_DEAL_ORDER,                                // Sort by the order a deal is based on
   SORT_BY_ORDER_DEAL_ENTRY,                                // Sort by a deal direction – IN, OUT or IN/OUT
   SORT_BY_ORDER_TIME_UPDATE,                               // Sort by position change time in seconds
   SORT_BY_ORDER_TICKET_FROM,                               // Sort by a parent order ticket
   SORT_BY_ORDER_TICKET_TO,                                 // Sort by a derived order ticket
   SORT_BY_ORDER_PROFIT_PT,                                 // Sort by order profit in points
   SORT_BY_ORDER_CLOSE_BY_SL,                               // Sort by the flag of closing an order by StopLoss
   SORT_BY_ORDER_CLOSE_BY_TP,                               // Sort by the flag of closing an order by TakeProfit
   SORT_BY_ORDER_MAGIC_ID,                                  // Sort by an order/position "magic number" ID
   SORT_BY_ORDER_GROUP_ID1,                                 // Sort by the first order/position group ID
   SORT_BY_ORDER_GROUP_ID2,                                 // Sort by the second order/position group ID
   SORT_BY_ORDER_PEND_REQ_ID,                               // Sort by a pending request ID
   SORT_BY_ORDER_DIRECTION,                                 // Sort by direction (Buy, Sell)
//--- Sort by real properties
   SORT_BY_ORDER_PRICE_OPEN = FIRST_ORD_DBL_PROP,           // Sort by open price
   SORT_BY_ORDER_PRICE_CLOSE,                               // Sort by close price
   SORT_BY_ORDER_SL,                                        // Sort by StopLoss price
   SORT_BY_ORDER_TP,                                        // Sort by TakeProfit price
   SORT_BY_ORDER_FEE,                                       // Sort by deal fee
   SORT_BY_ORDER_PROFIT,                                    // Sort by profit
   SORT_BY_ORDER_COMMISSION,                                // Sort by commission
   SORT_BY_ORDER_SWAP,                                      // Sort by swap
   SORT_BY_ORDER_VOLUME,                                    // Sort by volume
   SORT_BY_ORDER_VOLUME_CURRENT,                            // Sort by unexecuted volume
   SORT_BY_ORDER_PROFIT_FULL,                               // Sort by profit+commission+swap
   SORT_BY_ORDER_PRICE_STOP_LIMIT,                          // Sort by Limit order when StopLimit order is activated
//--- Sort by string properties
   SORT_BY_ORDER_SYMBOL = FIRST_ORD_STR_PROP,               // Sort by symbol
   SORT_BY_ORDER_COMMENT,                                   // Sort by comment
   SORT_BY_ORDER_COMMENT_EXT,                               // Sort by custom comment
   SORT_BY_ORDER_EXT_ID                                     // Sort by order ID in an external trading system
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with account events                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of trading event flags on the account                       |
//+------------------------------------------------------------------+
enum ENUM_TRADE_EVENT_FLAGS
  {
   TRADE_EVENT_FLAG_NO_EVENT        =  0x0,                 // No event
   TRADE_EVENT_FLAG_ORDER_PLASED    =  0x1,                 // Pending order placed
   TRADE_EVENT_FLAG_ORDER_REMOVED   =  0x2,                 // Pending order removed
   TRADE_EVENT_FLAG_ORDER_ACTIVATED =  0x4,                 // Pending order activated by price
   TRADE_EVENT_FLAG_POSITION_OPENED =  0x8,                 // Position opened
   TRADE_EVENT_FLAG_POSITION_CHANGED=  0x10,                // Position changed
   TRADE_EVENT_FLAG_POSITION_REVERSE=  0x20,                // Position reversal
   TRADE_EVENT_FLAG_POSITION_CLOSED =  0x40,                // Position closed
   TRADE_EVENT_FLAG_ACCOUNT_BALANCE =  0x80,                // Balance operation (clarified by a deal type)
   TRADE_EVENT_FLAG_PARTIAL         =  0x100,               // Partial execution
   TRADE_EVENT_FLAG_BY_POS          =  0x200,               // Executed by opposite position
   TRADE_EVENT_FLAG_PRICE           =  0x400,               // Modify the placement price
   TRADE_EVENT_FLAG_SL              =  0x800,               // Executed by StopLoss
   TRADE_EVENT_FLAG_TP              =  0x1000,              // Executed by TakeProfit
   TRADE_EVENT_FLAG_ORDER_MODIFY    =  0x2000,              // Modify an order
   TRADE_EVENT_FLAG_POSITION_MODIFY =  0x4000,              // Modify a position
  };
//+------------------------------------------------------------------+
//| List of possible trading events on the account                   |
//+------------------------------------------------------------------+
enum ENUM_TRADE_EVENT
  {
//--- (new constants cannot be removed or added below)
   TRADE_EVENT_NO_EVENT = 0,                                // No trading event
   TRADE_EVENT_PENDING_ORDER_PLASED,                        // Pending order placed
   TRADE_EVENT_PENDING_ORDER_REMOVED,                       // Pending order removed
//--- enumeration members matching the ENUM_DEAL_TYPE enumeration members
//--- (constant order below should not be changed, no constants should be added/deleted)
   TRADE_EVENT_ACCOUNT_CREDIT = DEAL_TYPE_CREDIT,           // Charging credit (3)
   TRADE_EVENT_ACCOUNT_CHARGE,                              // Additional charges
   TRADE_EVENT_ACCOUNT_CORRECTION,                          // Correcting entry
   TRADE_EVENT_ACCOUNT_BONUS,                               // Charging bonuses
   TRADE_EVENT_ACCOUNT_COMISSION,                           // Additional commissions
   TRADE_EVENT_ACCOUNT_COMISSION_DAILY,                     // Commission charged at the end of a day
   TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY,                   // Commission charged at the end of a month
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY,               // Agent commission charged at the end of a trading day
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY,             // Agent commission charged at the end of a month
   TRADE_EVENT_ACCOUNT_INTEREST,                            // Accrual of interest on free funds
   TRADE_EVENT_BUY_CANCELLED,                               // Canceled buy deal
   TRADE_EVENT_SELL_CANCELLED,                              // Canceled sell deal
   TRADE_EVENT_DIVIDENT,                                    // Accrual of dividends
   TRADE_EVENT_DIVIDENT_FRANKED,                            // Accrual of franked dividend
   TRADE_EVENT_TAX                        = DEAL_TAX,       // Tax accrual
//--- constants related to the DEAL_TYPE_BALANCE deal type from the DEAL_TYPE_BALANCE enumeration
   TRADE_EVENT_ACCOUNT_BALANCE_REFILL     = DEAL_TAX+1,     // Replenishing account balance
   TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL = DEAL_TAX+2,     // Withdrawing funds from an account
//--- Remaining possible trading events
//--- (constant order below can be changed, constants can be added/deleted)
   TRADE_EVENT_PENDING_ORDER_ACTIVATED    = DEAL_TAX+3,     // Pending order activated by price
   TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL,             // Pending order partially activated by price
   TRADE_EVENT_POSITION_OPENED,                             // Position opened
   TRADE_EVENT_POSITION_OPENED_PARTIAL,                     // Position opened partially
   TRADE_EVENT_POSITION_CLOSED,                             // Position closed
   TRADE_EVENT_POSITION_CLOSED_BY_POS,                      // Position closed by an opposite one
   TRADE_EVENT_POSITION_CLOSED_BY_SL,                       // Position closed by StopLoss
   TRADE_EVENT_POSITION_CLOSED_BY_TP,                       // Position closed by TakeProfit
   TRADE_EVENT_POSITION_REVERSED_BY_MARKET,                 // Position reversal by a new deal (netting)
   TRADE_EVENT_POSITION_REVERSED_BY_PENDING,                // Position reversal by activating a pending order (netting)
   TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL,         // Position reversal by partial market order execution (netting)
   TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL,        // Position reversal by activating a pending order (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET,               // Added volume to a position by a new deal (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL,       // Added volume to a position by partial execution of a market order (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING,              // Added volume to a position by activating a pending order (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL,      // Added volume to a position by partial activation of a pending order (netting)
   TRADE_EVENT_POSITION_CLOSED_PARTIAL,                     // Position closed partially
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS,              // Position partially closed by an opposite one
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL,               // Position closed partially by StopLoss
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP,               // Position closed partially by TakeProfit
   TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER,                  // StopLimit order activation
   TRADE_EVENT_MODIFY_ORDER_PRICE,                          // Changing order price
   TRADE_EVENT_MODIFY_ORDER_PRICE_SL,                       // Changing order and StopLoss price 
   TRADE_EVENT_MODIFY_ORDER_PRICE_TP,                       // Changing order and TakeProfit price
   TRADE_EVENT_MODIFY_ORDER_PRICE_SL_TP,                    // Changing order, StopLoss and TakeProfit price
   TRADE_EVENT_MODIFY_ORDER_SL_TP,                          // Changing order's StopLoss and TakeProfit price
   TRADE_EVENT_MODIFY_ORDER_SL,                             // Changing order's StopLoss
   TRADE_EVENT_MODIFY_ORDER_TP,                             // Changing order's TakeProfit
   TRADE_EVENT_MODIFY_POSITION_SL_TP,                       // Changing position's StopLoss and TakeProfit
   TRADE_EVENT_MODIFY_POSITION_SL,                          // Change position's StopLoss
   TRADE_EVENT_MODIFY_POSITION_TP,                          // Change position's TakeProfit
  };
#define TRADE_EVENTS_NEXT_CODE   (TRADE_EVENT_MODIFY_POSITION_TP+1)  // The code of the next event after the last trading event code
//+------------------------------------------------------------------+
//| Event status                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_STATUS
  {
   EVENT_STATUS_MARKET_POSITION,                            // Market position event (opening, partial opening, partial closing, adding volume, reversal)
   EVENT_STATUS_MARKET_PENDING,                             // Market pending order event (placing)
   EVENT_STATUS_HISTORY_PENDING,                            // Historical pending order event (removal)
   EVENT_STATUS_HISTORY_POSITION,                           // Historical position event (closing)
   EVENT_STATUS_BALANCE,                                    // Balance operation event (accruing balance, withdrawing funds and events from the ENUM_DEAL_TYPE enumeration)
   EVENT_STATUS_MODIFY                                      // Order/position modification event
  };
//+------------------------------------------------------------------+
//| Event reason                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_REASON
  {
   EVENT_REASON_REVERSE,                                    // Position reversal (netting)
   EVENT_REASON_REVERSE_PARTIALLY,                          // Position reversal by partial request execution (netting)
   EVENT_REASON_REVERSE_BY_PENDING,                         // Position reversal by pending order activation (netting)
   EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY,               // Position reversal in case of a pending order partial execution (netting)
//--- All constants related to a position reversal should be located in the above list
   EVENT_REASON_ACTIVATED_PENDING,                          // Pending order activation
   EVENT_REASON_ACTIVATED_PENDING_PARTIALLY,                // Pending order partial activation
   EVENT_REASON_STOPLIMIT_TRIGGERED,                        // StopLimit order activation
   EVENT_REASON_MODIFY,                                     // Modification
   EVENT_REASON_CANCEL,                                     // Cancelation
   EVENT_REASON_EXPIRED,                                    // Order expiration
   EVENT_REASON_DONE,                                       // Request executed in full
   EVENT_REASON_DONE_PARTIALLY,                             // Request executed partially
   EVENT_REASON_VOLUME_ADD,                                 // Add volume to a position (netting)
   EVENT_REASON_VOLUME_ADD_PARTIALLY,                       // Add volume to a position by a partial request execution (netting)
   EVENT_REASON_VOLUME_ADD_BY_PENDING,                      // Add volume to a position when a pending order is activated (netting)
   EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY,            // Add volume to a position when a pending order is partially executed (netting)
   EVENT_REASON_DONE_SL,                                    // Closing by StopLoss
   EVENT_REASON_DONE_SL_PARTIALLY,                          // Partial closing by StopLoss
   EVENT_REASON_DONE_TP,                                    // Closing by TakeProfit
   EVENT_REASON_DONE_TP_PARTIALLY,                          // Partial closing by TakeProfit
   EVENT_REASON_DONE_BY_POS,                                // Closing by an opposite position
   EVENT_REASON_DONE_PARTIALLY_BY_POS,                      // Partial closing by an opposite position
   EVENT_REASON_DONE_BY_POS_PARTIALLY,                      // Closing an opposite position by a partial volume
   EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY,            // Partial closing of an opposite position by a partial volume
//--- Constants related to DEAL_TYPE_BALANCE deal type from the ENUM_DEAL_TYPE enumeration
   EVENT_REASON_BALANCE_REFILL,                             // Refilling the balance
   EVENT_REASON_BALANCE_WITHDRAWAL,                         // Withdrawing funds from the account
//--- List of constants is relevant to TRADE_EVENT_ACCOUNT_CREDIT from the ENUM_TRADE_EVENT enumeration and shifted to +13 relative to ENUM_DEAL_TYPE (EVENT_REASON_ACCOUNT_CREDIT-3)
   EVENT_REASON_ACCOUNT_CREDIT,                             // Accruing credit
   EVENT_REASON_ACCOUNT_CHARGE,                             // Additional charges
   EVENT_REASON_ACCOUNT_CORRECTION,                         // Correcting entry
   EVENT_REASON_ACCOUNT_BONUS,                              // Accruing bonuses
   EVENT_REASON_ACCOUNT_COMISSION,                          // Additional commissions
   EVENT_REASON_ACCOUNT_COMISSION_DAILY,                    // Commission charged at the end of a trading day
   EVENT_REASON_ACCOUNT_COMISSION_MONTHLY,                  // Commission charged at the end of a trading month
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY,              // Agent commission charged at the end of a trading day
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY,            // Agent commission charged at the end of a month
   EVENT_REASON_ACCOUNT_INTEREST,                           // Accruing interest on free funds
   EVENT_REASON_BUY_CANCELLED,                              // Canceled buy deal
   EVENT_REASON_SELL_CANCELLED,                             // Canceled sell deal
   EVENT_REASON_DIVIDENT,                                   // Accruing dividends
   EVENT_REASON_DIVIDENT_FRANKED,                           // Accruing franked dividends
   EVENT_REASON_TAX                                         // Tax
  };
#define REASON_EVENT_SHIFT    (EVENT_REASON_ACCOUNT_CREDIT-3)
//+------------------------------------------------------------------+
//| Event's integer properties                                       |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_INTEGER
  {
   EVENT_PROP_TYPE_EVENT = 0,                               // Account trading event type (from the ENUM_TRADE_EVENT enumeration)
   EVENT_PROP_TIME_EVENT,                                   // Event time in milliseconds
   EVENT_PROP_STATUS_EVENT,                                 // Event status (from the ENUM_EVENT_STATUS enumeration)
   EVENT_PROP_REASON_EVENT,                                 // Event reason (from the ENUM_EVENT_REASON enumeration)
   //---
   EVENT_PROP_TYPE_DEAL_EVENT,                              // Deal event type
   EVENT_PROP_TICKET_DEAL_EVENT,                            // Deal event ticket
   EVENT_PROP_TYPE_ORDER_EVENT,                             // Type of the order, based on which a deal event is opened (the last position order)
   EVENT_PROP_TICKET_ORDER_EVENT,                           // Ticket of the order, based on which a deal event is opened (the last position order)
   //---
   EVENT_PROP_TIME_ORDER_POSITION,                          // Time of the order, based on which the first position deal is opened (the first position order on a hedge account)
   EVENT_PROP_TYPE_ORDER_POSITION,                          // Type of the order, based on which the first position deal is opened (the first position order on a hedge account)
   EVENT_PROP_TICKET_ORDER_POSITION,                        // Ticket of the order, based on which the first position deal is opened (the first position order on a hedge account)
   EVENT_PROP_POSITION_ID,                                  // Position ID
   //---
   EVENT_PROP_POSITION_BY_ID,                               // Opposite position ID
   EVENT_PROP_MAGIC_ORDER,                                  // Order/deal/position magic number
   EVENT_PROP_MAGIC_BY_ID,                                  // Opposite position magic number
   //---
   EVENT_PROP_TYPE_ORD_POS_BEFORE,                          // Position type before changing the direction
   EVENT_PROP_TICKET_ORD_POS_BEFORE,                        // Position order ticket before changing direction
   EVENT_PROP_TYPE_ORD_POS_CURRENT,                         // Current position type
   EVENT_PROP_TICKET_ORD_POS_CURRENT,                       // Current position order ticket
  }; 
#define EVENT_PROP_INTEGER_TOTAL (19)                       // Total number of integer event properties
#define EVENT_PROP_INTEGER_SKIP  (4)                        // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Event's real properties                                          |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_DOUBLE
  {
   EVENT_PROP_PRICE_EVENT = EVENT_PROP_INTEGER_TOTAL,       // Price an event occurred at
   EVENT_PROP_PRICE_OPEN,                                   // Order/deal/position open price
   EVENT_PROP_PRICE_CLOSE,                                  // Order/deal/position close price
   EVENT_PROP_PRICE_SL,                                     // StopLoss order/deal/position price
   EVENT_PROP_PRICE_TP,                                     // TakeProfit Order/deal/position
   EVENT_PROP_VOLUME_ORDER_INITIAL,                         // Requested order volume
   EVENT_PROP_VOLUME_ORDER_EXECUTED,                        // Executed order volume
   EVENT_PROP_VOLUME_ORDER_CURRENT,                         // Remaining (unexecuted) order volume
   EVENT_PROP_VOLUME_POSITION_EXECUTED,                     // Current executed position volume after a deal
   EVENT_PROP_PROFIT,                                       // Profit
   //---
   EVENT_PROP_PRICE_OPEN_BEFORE,                            // Order price before modification
   EVENT_PROP_PRICE_SL_BEFORE,                              // StopLoss price before modification
   EVENT_PROP_PRICE_TP_BEFORE,                              // TakeProfit price before modification
   EVENT_PROP_PRICE_EVENT_ASK,                              // Ask price during an event
   EVENT_PROP_PRICE_EVENT_BID,                              // Bid price during an event
  };
#define EVENT_PROP_DOUBLE_TOTAL  (15)                       // Total number of event's real properties
#define EVENT_PROP_DOUBLE_SKIP   (5)                        // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Event's string properties                                        |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_STRING
  {
   EVENT_PROP_SYMBOL = (EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_DOUBLE_TOTAL), // Order symbol
   EVENT_PROP_SYMBOL_BY_ID                                  // Opposite position symbol
  };
#define EVENT_PROP_STRING_TOTAL     (2)                     // Total number of event's string properties
//+------------------------------------------------------------------+
//| Possible event sorting criteria                                  |
//+------------------------------------------------------------------+
#define FIRST_EVN_DBL_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP)
#define FIRST_EVN_STR_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP+EVENT_PROP_DOUBLE_TOTAL-EVENT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_EVENTS_MODE
  {
//--- Sort by integer properties
   SORT_BY_EVENT_TYPE_EVENT = 0,                            // Sort by event type
   SORT_BY_EVENT_TIME_EVENT,                                // Sort by event time
   SORT_BY_EVENT_STATUS_EVENT,                              // Sort by event status (from the ENUM_EVENT_STATUS enumeration)
   SORT_BY_EVENT_REASON_EVENT,                              // Sort by event reason (from the ENUM_EVENT_REASON enumeration)
   SORT_BY_EVENT_TYPE_DEAL_EVENT,                           // Sort by deal event type
   SORT_BY_EVENT_TICKET_DEAL_EVENT,                         // Sort by deal event ticket
   SORT_BY_EVENT_TYPE_ORDER_EVENT,                          // Sort by type of an order, based on which a deal event is opened (the last position order)
   SORT_BY_EVENT_TICKET_ORDER_EVENT,                        // Sort by a ticket of an order, based on which a deal event is opened (the last position order)
   SORT_BY_EVENT_TIME_ORDER_POSITION,                       // Sort by time of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_TYPE_ORDER_POSITION,                       // Sort by type of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_TICKET_ORDER_POSITION,                     // Sort by a ticket of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_POSITION_ID,                               // Sort by position ID
   SORT_BY_EVENT_POSITION_BY_ID,                            // Sort by opposite position ID
   SORT_BY_EVENT_MAGIC_ORDER,                               // Sort by order/deal/position magic number
   SORT_BY_EVENT_MAGIC_BY_ID,                               // Sort by an opposite position magic number
//--- Sort by real properties
   SORT_BY_EVENT_PRICE_EVENT = FIRST_EVN_DBL_PROP,          // Sort by a price an event occurred at
   SORT_BY_EVENT_PRICE_OPEN,                                // Sort by position open price
   SORT_BY_EVENT_PRICE_CLOSE,                               // Sort by position close price
   SORT_BY_EVENT_PRICE_SL,                                  // Sort by position StopLoss price
   SORT_BY_EVENT_PRICE_TP,                                  // Sort by position TakeProfit price
   SORT_BY_EVENT_VOLUME_ORDER_INITIAL,                      // Sort by initial volume
   SORT_BY_EVENT_VOLUME_ORDER_EXECUTED,                     // Sort by the current volume
   SORT_BY_EVENT_VOLUME_ORDER_CURRENT,                      // Sort by remaining volume
   SORT_BY_EVENT_VOLUME_POSITION_EXECUTED,                  // Sort by the current executed position volume after a deal
   SORT_BY_EVENT_PROFIT,   // Sort by profit
//--- Sort by string properties
   SORT_BY_EVENT_SYMBOL = FIRST_EVN_STR_PROP,               // Sort by order/position/deal symbol
   SORT_BY_EVENT_SYMBOL_BY_ID                               // Sort by an opposite position symbol
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with accounts                                   |
//+------------------------------------------------------------------+
#define ACCOUNT_EVENTS_NEXT_CODE       (TRADE_EVENTS_NEXT_CODE+1) // The code of the next event after the last account event code
//+------------------------------------------------------------------+
//| Account integer properties                                       |
//+------------------------------------------------------------------+
enum ENUM_ACCOUNT_PROP_INTEGER
  {
   ACCOUNT_PROP_LOGIN,                                      // Account number
   ACCOUNT_PROP_TRADE_MODE,                                 // Trading account type
   ACCOUNT_PROP_LEVERAGE,                                   // Leverage
   ACCOUNT_PROP_LIMIT_ORDERS,                               // Maximum allowed number of active pending orders
   ACCOUNT_PROP_MARGIN_SO_MODE,                             // Mode of setting the minimum available margin level
   ACCOUNT_PROP_TRADE_ALLOWED,                              // Permission to trade for the current account from the server side
   ACCOUNT_PROP_TRADE_EXPERT,                               // Permission to trade for an EA from the server side
   ACCOUNT_PROP_MARGIN_MODE,                                // Margin calculation mode
   ACCOUNT_PROP_CURRENCY_DIGITS,                            // Number of digits for an account currency necessary for accurate display of trading results
   ACCOUNT_PROP_SERVER_TYPE,                                // Trade server type (MetaTrader 5, MetaTrader 4)
   ACCOUNT_PROP_FIFO_CLOSE,                                 // Flag of a position closure by FIFO rule only
   ACCOUNT_PROP_HEDGE_ALLOWED                               // Permission to open opposite positions and set pending orders
  };
#define ACCOUNT_PROP_INTEGER_TOTAL    (12)                  // Total number of integer properties
#define ACCOUNT_PROP_INTEGER_SKIP     (0)                   // Number of integer account properties not used in sorting
//+------------------------------------------------------------------+
//| Account real properties                                          |
//+------------------------------------------------------------------+
enum ENUM_ACCOUNT_PROP_DOUBLE
  {
   ACCOUNT_PROP_BALANCE = ACCOUNT_PROP_INTEGER_TOTAL,       // Account balance in a deposit currency
   ACCOUNT_PROP_CREDIT,                                     // Credit in a deposit currency
   ACCOUNT_PROP_PROFIT,                                     // Current profit on an account in the account currency
   ACCOUNT_PROP_EQUITY,                                     // Equity on an account in the deposit currency
   ACCOUNT_PROP_MARGIN,                                     // Reserved margin on an account in the deposit currency
   ACCOUNT_PROP_MARGIN_FREE,                                // Free funds available for opening a position on an account in the deposit currency
   ACCOUNT_PROP_MARGIN_LEVEL,                               // Margin level on an account in %
   ACCOUNT_PROP_MARGIN_SO_CALL,                             // Margin Call level
   ACCOUNT_PROP_MARGIN_SO_SO,                               // Stop Out level
   ACCOUNT_PROP_MARGIN_INITIAL,                             // Funds reserved on an account to ensure a guarantee amount for all pending orders 
   ACCOUNT_PROP_MARGIN_MAINTENANCE,                         // Funds reserved on an account to ensure a minimum amount for all open positions
   ACCOUNT_PROP_ASSETS,                                     // Current assets on an account
   ACCOUNT_PROP_LIABILITIES,                                // Current liabilities on an account
   ACCOUNT_PROP_COMMISSION_BLOCKED                          // Current sum of blocked commissions on an account
  };
#define ACCOUNT_PROP_DOUBLE_TOTAL     (14)                  // Total number of account real properties
#define ACCOUNT_PROP_DOUBLE_SKIP      (0)                   // Number of real account properties not used in sorting
//+------------------------------------------------------------------+
//| Account string properties                                        |
//+------------------------------------------------------------------+
enum ENUM_ACCOUNT_PROP_STRING
  {
   ACCOUNT_PROP_NAME = (ACCOUNT_PROP_INTEGER_TOTAL+ACCOUNT_PROP_DOUBLE_TOTAL), // Client name
   ACCOUNT_PROP_SERVER,                                     // Trade server name
   ACCOUNT_PROP_CURRENCY,                                   // Deposit currency
   ACCOUNT_PROP_COMPANY                                     // Name of a company serving an account
  };
#define ACCOUNT_PROP_STRING_TOTAL     (4)                   // Total number of account string properties
#define ACCOUNT_PROP_STRING_SKIP      (0)                   // Number of string account properties not used in sorting
//+------------------------------------------------------------------+
//| Possible account sorting criteria                                |
//+------------------------------------------------------------------+
#define FIRST_ACC_DBL_PROP            (ACCOUNT_PROP_INTEGER_TOTAL-ACCOUNT_PROP_INTEGER_SKIP)
#define FIRST_ACC_STR_PROP            (ACCOUNT_PROP_INTEGER_TOTAL-ACCOUNT_PROP_INTEGER_SKIP+ACCOUNT_PROP_DOUBLE_TOTAL-ACCOUNT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_ACCOUNT_MODE
  {
//--- Sort by integer properties
   SORT_BY_ACCOUNT_LOGIN = 0,                               // Sort by account number
   SORT_BY_ACCOUNT_TRADE_MODE,                              // Sort by trading account type
   SORT_BY_ACCOUNT_LEVERAGE,                                // Sort by leverage
   SORT_BY_ACCOUNT_LIMIT_ORDERS,                            // Sort by maximum acceptable number of existing pending orders
   SORT_BY_ACCOUNT_MARGIN_SO_MODE,                          // Sort by mode for setting the minimum acceptable margin level
   SORT_BY_ACCOUNT_TRADE_ALLOWED,                           // Sort by permission to trade for the current account
   SORT_BY_ACCOUNT_TRADE_EXPERT,                            // Sort by permission to trade for an EA
   SORT_BY_ACCOUNT_MARGIN_MODE,                             // Sort by margin calculation mode
   SORT_BY_ACCOUNT_CURRENCY_DIGITS,                         // Sort by number of digits for an account currency
   SORT_BY_ACCOUNT_SERVER_TYPE,                             // Sort by trade server type (MetaTrader 5, MetaTrader 4)
   SORT_BY_ACCOUNT_FIFO_CLOSE,                              // Sort by the flag of a position closure by FIFO rule only
   SORT_BY_ACCOUNT_HEDGE_ALLOWED,                           // Sort by permission to open opposite positions and set pending orders
//--- Sort by real properties
   SORT_BY_ACCOUNT_BALANCE = FIRST_ACC_DBL_PROP,            // Sort by an account balance in the deposit currency
   SORT_BY_ACCOUNT_CREDIT,                                  // Sort by credit in a deposit currency
   SORT_BY_ACCOUNT_PROFIT,                                  // Sort by the current profit on an account in the deposit currency
   SORT_BY_ACCOUNT_EQUITY,                                  // Sort by an account equity in the deposit currency
   SORT_BY_ACCOUNT_MARGIN,                                  // Sort by an account reserved margin in the deposit currency
   SORT_BY_ACCOUNT_MARGIN_FREE,                             // Sort by account free funds available for opening a position in the deposit currency
   SORT_BY_ACCOUNT_MARGIN_LEVEL,                            // Sort by account margin level in %
   SORT_BY_ACCOUNT_MARGIN_SO_CALL,                          // Sort by margin level requiring depositing funds to an account (Margin Call)
   SORT_BY_ACCOUNT_MARGIN_SO_SO,                            // Sort by margin level, at which the most loss-making position is closed (Stop Out)
   SORT_BY_ACCOUNT_MARGIN_INITIAL,                          // Sort by funds reserved on an account to ensure a guarantee amount for all pending orders 
   SORT_BY_ACCOUNT_MARGIN_MAINTENANCE,                      // Sort by funds reserved on an account to ensure a minimum amount for all open positions
   SORT_BY_ACCOUNT_ASSETS,                                  // Sort by the amount of the current assets on an account
   SORT_BY_ACCOUNT_LIABILITIES,                             // Sort by the current liabilities on an account
   SORT_BY_ACCOUNT_COMMISSION_BLOCKED,                      // Sort by the current amount of blocked commissions on an account
//--- Sort by string properties
   SORT_BY_ACCOUNT_NAME = FIRST_ACC_STR_PROP,               // Sort by a client name
   SORT_BY_ACCOUNT_SERVER,                                  // Sort by a trade server name
   SORT_BY_ACCOUNT_CURRENCY,                                // Sort by a deposit currency
   SORT_BY_ACCOUNT_COMPANY                                  // Sort by a name of a company serving an account
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with symbols                                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of possible symbol events in the Market Watch window        |
//+------------------------------------------------------------------+
enum ENUM_MW_EVENT
  {
   MARKET_WATCH_EVENT_NO_EVENT = ACCOUNT_EVENTS_NEXT_CODE,  // No event
   MARKET_WATCH_EVENT_SYMBOL_ADD,                           // Adding a symbol to the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_DEL,                           // Removing a symbol from the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_SORT,                          // Sorting symbols in the Market Watch window
  };
#define SYMBOL_EVENTS_NEXT_CODE  (MARKET_WATCH_EVENT_SYMBOL_SORT+1)  // The code of the next event after the last symbol event code
//+------------------------------------------------------------------+
//| Abstract symbol type (status)                                    |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_STATUS
  {
   SYMBOL_STATUS_FX,                                        // Forex symbol
   SYMBOL_STATUS_FX_MAJOR,                                  // Major Forex symbol
   SYMBOL_STATUS_FX_MINOR,                                  // Minor Forex symbol
   SYMBOL_STATUS_FX_EXOTIC,                                 // Exotic Forex symbol
   SYMBOL_STATUS_FX_RUB,                                    // Forex symbol/RUR
   SYMBOL_STATUS_METAL,                                     // Metal
   SYMBOL_STATUS_INDEX,                                     // Index
   SYMBOL_STATUS_INDICATIVE,                                // Indicative
   SYMBOL_STATUS_CRYPTO,                                    // Cryptocurrency symbol
   SYMBOL_STATUS_COMMODITY,                                 // Commodity symbol
   SYMBOL_STATUS_EXCHANGE,                                  // Exchange symbol
   SYMBOL_STATUS_FUTURES,                                   // Futures
   SYMBOL_STATUS_CFD,                                       // CFD
   SYMBOL_STATUS_STOCKS,                                    // Stock
   SYMBOL_STATUS_BONDS,                                     // Bond
   SYMBOL_STATUS_OPTION,                                    // Option
   SYMBOL_STATUS_COLLATERAL,                                // Non-tradable asset
   SYMBOL_STATUS_CUSTOM,                                    // Custom symbol
   SYMBOL_STATUS_COMMON                                     // General category
  };
//+------------------------------------------------------------------+
//| Symbol integer properties                                        |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_PROP_INTEGER
  {
   SYMBOL_PROP_STATUS = 0,                                  // Symbol status
   SYMBOL_PROP_INDEX_MW,                                    // Symbol index in the Market Watch window
   SYMBOL_PROP_SECTOR,                                      // Economy sector the asset belongs to
   SYMBOL_PROP_INDUSTRY,                                    // Industry or the economy branch the symbol belongs to
   SYMBOL_PROP_CUSTOM,                                      // Custom symbol flag
   SYMBOL_PROP_CHART_MODE,                                  // The price type used for generating bars – Bid or Last (from the ENUM_SYMBOL_CHART_MODE enumeration)
   SYMBOL_PROP_EXIST,                                       // Flag indicating that the symbol under this name exists
   SYMBOL_PROP_SELECT,                                      // An indication that the symbol is selected in Market Watch
   SYMBOL_PROP_VISIBLE,                                     // An indication that the symbol is displayed in Market Watch
   SYMBOL_PROP_SESSION_DEALS,                               // The number of deals in the current session 
   SYMBOL_PROP_SESSION_BUY_ORDERS,                          // The total number of Buy orders at the moment
   SYMBOL_PROP_SESSION_SELL_ORDERS,                         // The total number of Sell orders at the moment
   SYMBOL_PROP_VOLUME,                                      // Last deal volume
   SYMBOL_PROP_VOLUMEHIGH,                                  // Maximum volume within a day
   SYMBOL_PROP_VOLUMELOW,                                   // Minimum volume within a day
   SYMBOL_PROP_TIME,                                        // Latest quote time
   SYMBOL_PROP_TIME_MSC,                                    // Time of the last quote in milliseconds
   SYMBOL_PROP_DIGITS,                                      // Number of decimal places
   SYMBOL_PROP_DIGITS_LOTS,                                 // Number of decimal places for a lot
   SYMBOL_PROP_SPREAD,                                      // Spread in points
   SYMBOL_PROP_SPREAD_FLOAT,                                // Floating spread flag
   SYMBOL_PROP_TICKS_BOOKDEPTH,                             // Maximum number of orders displayed in the Depth of Market
   SYMBOL_PROP_BOOKDEPTH_STATE,                             // Flag of subscription to DOM
   SYMBOL_PROP_TRADE_CALC_MODE,                             // Contract price calculation method (from the ENUM_SYMBOL_CALC_MODE enumeration)
   SYMBOL_PROP_TRADE_MODE,                                  // Order execution type (from the ENUM_SYMBOL_TRADE_MODE enumeration)
   SYMBOL_PROP_START_TIME,                                  // Symbol trading start date (usually used for futures)
   SYMBOL_PROP_EXPIRATION_TIME,                             // Symbol trading end date (usually used for futures)
   SYMBOL_PROP_TRADE_STOPS_LEVEL,                           // Minimum distance in points from the current close price for setting Stop orders
   SYMBOL_PROP_TRADE_FREEZE_LEVEL,                          // Freeze distance for trading operations (in points)
   SYMBOL_PROP_TRADE_EXEMODE,                               // Deal execution mode (from the ENUM_SYMBOL_TRADE_EXECUTION enumeration)
   SYMBOL_PROP_SWAP_MODE,                                   // Swap calculation model (from the ENUM_SYMBOL_SWAP_MODE enumeration)
   SYMBOL_PROP_SWAP_ROLLOVER3DAYS,                          // Triple-day swap (from the ENUM_DAY_OF_WEEK enumeration)
   SYMBOL_PROP_MARGIN_HEDGED_USE_LEG,                       // Calculating hedging margin using the larger leg (Buy or Sell)
   SYMBOL_PROP_EXPIRATION_MODE,                             // Flags of allowed order expiration modes
   SYMBOL_PROP_FILLING_MODE,                                // Flags of allowed order filling modes
   SYMBOL_PROP_ORDER_MODE,                                  // The flags of allowed order types
   SYMBOL_PROP_ORDER_GTC_MODE,                              // Expiration of Stop Loss and Take Profit orders if SYMBOL_EXPIRATION_MODE=SYMBOL_EXPIRATION_GTC (from the ENUM_SYMBOL_ORDER_GTC_MODE enumeration)
   SYMBOL_PROP_OPTION_MODE,                                 // Option type (from the ENUM_SYMBOL_OPTION_MODE enumeration)
   SYMBOL_PROP_OPTION_RIGHT,                                // Option right (Call/Put) (from the ENUM_SYMBOL_OPTION_RIGHT enumeration)
   SYMBOL_PROP_SUBSCRIPTION_DELAY,                          // Delay for quotes passed by symbol for instruments working on subscription basis
   //--- skipped property
   SYMBOL_PROP_BACKGROUND_COLOR                             // The color of the background used for the symbol in Market Watch
  }; 
#define SYMBOL_PROP_INTEGER_TOTAL    (41)                   // Total number of integer properties
#define SYMBOL_PROP_INTEGER_SKIP     (1)                    // Number of symbol integer properties not used in sorting
//+------------------------------------------------------------------+
//| Symbol real properties                                           |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_PROP_DOUBLE
  {
   SYMBOL_PROP_BID = SYMBOL_PROP_INTEGER_TOTAL,             // Bid - the best price at which a symbol can be sold
   SYMBOL_PROP_BIDHIGH,                                     // The highest Bid price of the day
   SYMBOL_PROP_BIDLOW,                                      // The lowest Bid price of the day
   SYMBOL_PROP_ASK,                                         // Ask - best price, at which an instrument can be bought
   SYMBOL_PROP_ASKHIGH,                                     // The highest Ask price of the day
   SYMBOL_PROP_ASKLOW,                                      // The lowest Ask price of the day
   SYMBOL_PROP_LAST,                                        // The price at which the last deal was executed
   SYMBOL_PROP_LASTHIGH,                                    // The highest Last price of the day
   SYMBOL_PROP_LASTLOW,                                     // The lowest Last price of the day
   SYMBOL_PROP_VOLUME_REAL,                                 // Volume of the day
   SYMBOL_PROP_VOLUMEHIGH_REAL,                             // Maximum volume within a day
   SYMBOL_PROP_VOLUMELOW_REAL,                              // Minimum volume within a day
   SYMBOL_PROP_OPTION_STRIKE,                               // Option execution price
   SYMBOL_PROP_POINT,                                       // One point value
   SYMBOL_PROP_TRADE_TICK_VALUE,                            // SYMBOL_TRADE_TICK_VALUE_PROFIT value
   SYMBOL_PROP_TRADE_TICK_VALUE_PROFIT,                     // Calculated tick value for a winning position
   SYMBOL_PROP_TRADE_TICK_VALUE_LOSS,                       // Calculated tick value for a losing position
   SYMBOL_PROP_TRADE_TICK_SIZE,                             // Minimal price change
   SYMBOL_PROP_TRADE_CONTRACT_SIZE,                         // Trade contract size
   SYMBOL_PROP_TRADE_ACCRUED_INTEREST,                      // Accrued interest
   SYMBOL_PROP_TRADE_FACE_VALUE,                            // Face value – initial bond value set by an issuer
   SYMBOL_PROP_TRADE_LIQUIDITY_RATE,                        // Liquidity rate – the share of an asset that can be used for a margin
   SYMBOL_PROP_VOLUME_MIN,                                  // Minimum volume for a deal
   SYMBOL_PROP_VOLUME_MAX,                                  // Maximum volume for a deal
   SYMBOL_PROP_VOLUME_STEP,                                 // Minimum volume change step for deal execution
   SYMBOL_PROP_VOLUME_LIMIT,                                // The maximum allowed total volume of an open position and pending orders in one direction (either buy or sell)
   SYMBOL_PROP_SWAP_LONG,                                   // Long swap value
   SYMBOL_PROP_SWAP_SHORT,                                  // Short swap value
   SYMBOL_PROP_MARGIN_INITIAL,                              // Initial margin
   SYMBOL_PROP_MARGIN_MAINTENANCE,                          // Maintenance margin for an instrument
   SYMBOL_PROP_MARGIN_LONG_INITIAL,                         // Initial margin requirement applicable to long positions
   SYMBOL_PROP_MARGIN_BUY_STOP_INITIAL,                     // Initial margin requirement applicable to BuyStop orders
   SYMBOL_PROP_MARGIN_BUY_LIMIT_INITIAL,                    // Initial margin requirement applicable to BuyLimit orders
   SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_INITIAL,                // Initial margin requirement applicable to BuyStopLimit orders
   SYMBOL_PROP_MARGIN_LONG_MAINTENANCE,                     // Maintenance margin requirement applicable to long positions
   SYMBOL_PROP_MARGIN_BUY_STOP_MAINTENANCE,                 // Maintenance margin requirement applicable to BuyStop orders
   SYMBOL_PROP_MARGIN_BUY_LIMIT_MAINTENANCE,                // Maintenance margin requirement applicable to BuyLimit orders
   SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE,            // Maintenance margin requirement applicable to BuyStopLimit orders
   SYMBOL_PROP_MARGIN_SHORT_INITIAL,                        // Initial margin requirement applicable to short positions
   SYMBOL_PROP_MARGIN_SELL_STOP_INITIAL,                    // Initial margin requirement applicable to SellStop orders
   SYMBOL_PROP_MARGIN_SELL_LIMIT_INITIAL,                   // Initial margin requirement applicable to SellLimit orders
   SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_INITIAL,               // Initial margin requirement applicable to SellStopLimit orders
   SYMBOL_PROP_MARGIN_SHORT_MAINTENANCE,                    // Maintenance margin requirement applicable to short positions
   SYMBOL_PROP_MARGIN_SELL_STOP_MAINTENANCE,                // Maintenance margin requirement applicable to SellStop orders
   SYMBOL_PROP_MARGIN_SELL_LIMIT_MAINTENANCE,               // Maintenance margin requirement applicable to SellLimit orders
   SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE,           // Maintenance margin requirement applicable to SellStopLimit orders
   SYMBOL_PROP_SESSION_VOLUME,                              // The total volume of deals in the current session
   SYMBOL_PROP_SESSION_TURNOVER,                            // The total turnover in the current session
   SYMBOL_PROP_SESSION_INTEREST,                            // The total volume of open positions
   SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME,                   // The total volume of Buy orders at the moment
   SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME,                  // The total volume of Sell orders at the moment
   SYMBOL_PROP_SESSION_OPEN,                                // Open price of the session
   SYMBOL_PROP_SESSION_CLOSE,                               // Close price of the session
   SYMBOL_PROP_SESSION_AW,                                  // The average weighted price of the session
   SYMBOL_PROP_SESSION_PRICE_SETTLEMENT,                    // The settlement price of the current session
   SYMBOL_PROP_SESSION_PRICE_LIMIT_MIN,                     // Minimum allowable price value for the session 
   SYMBOL_PROP_SESSION_PRICE_LIMIT_MAX,                     // Maximum allowable price value for the session
   SYMBOL_PROP_MARGIN_HEDGED,                               // Size of a contract or margin for one lot of hedged positions (oppositely directed positions at one symbol).
   SYMBOL_PROP_PRICE_CHANGE,                                // Change of the current price relative to the end of the previous trading day in %
   SYMBOL_PROP_PRICE_VOLATILITY,                            // Price volatility in %
   SYMBOL_PROP_PRICE_THEORETICAL,                           // Theoretical option price
   SYMBOL_PROP_PRICE_DELTA,                                 // Option/warrant delta. Shows the value the option price changes by, when the underlying asset price changes by 1
   SYMBOL_PROP_PRICE_THETA,                                 // Option/warrant theta. Number of points the option price is to lose every day due to a temporary breakup, i.e. when the expiration date approaches
   SYMBOL_PROP_PRICE_GAMMA,                                 // Option/warrant gamma. Shows the change rate of delta – how quickly or slowly the option premium changes
   SYMBOL_PROP_PRICE_VEGA,                                  // Option/warrant vega. Shows the number of points the option price changes by when the volatility changes by 1%
   SYMBOL_PROP_PRICE_RHO,                                   // Option/warrant rho. Reflects the sensitivity of the theoretical option price to the interest rate changing by 1%
   SYMBOL_PROP_PRICE_OMEGA,                                 // Option/warrant omega. Option elasticity – a relative percentage change of the option price by the percentage change of the underlying asset price
   SYMBOL_PROP_PRICE_SENSITIVITY,                           // Option/warrant sensitivity.  Shows by how many points the price of the option's underlying asset should change so that the price of the option changes by one point
   SYMBOL_PROP_SWAP_SUNDAY,                                 // Swap accrual ratio (Sunday)
   SYMBOL_PROP_SWAP_MONDAY,                                 // Swap accrual ratio (Monday)
   SYMBOL_PROP_SWAP_TUESDAY,                                // Swap accrual ratio (Tuesday)
   SYMBOL_PROP_SWAP_WEDNESDAY,                              // Swap accrual ratio (Wednesday)
   SYMBOL_PROP_SWAP_THURSDAY,                               // Swap accrual ratio (Thursday)
   SYMBOL_PROP_SWAP_FRIDAY,                                 // Swap accrual ratio (Friday)
   SYMBOL_PROP_SWAP_SATURDAY,                               // Swap accrual ratio (Saturday)
  };
#define SYMBOL_PROP_DOUBLE_TOTAL     (75)                   // Total number of real properties
#define SYMBOL_PROP_DOUBLE_SKIP      (0)                    // Number of real symbol properties not used in sorting
//+------------------------------------------------------------------+
//| Symbol string properties                                         |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_PROP_STRING
  {
   SYMBOL_PROP_NAME = (SYMBOL_PROP_INTEGER_TOTAL+SYMBOL_PROP_DOUBLE_TOTAL),   // Symbol name
   SYMBOL_PROP_BASIS,                                       // The name of the underlaying asset for a derivative symbol
   SYMBOL_PROP_CURRENCY_BASE,                               // Instrument base currency
   SYMBOL_PROP_CURRENCY_PROFIT,                             // Profit currency
   SYMBOL_PROP_CURRENCY_MARGIN,                             // Margin currency
   SYMBOL_PROP_BANK,                                        // The source of the current quote
   SYMBOL_PROP_DESCRIPTION,                                 // String description of a symbol
   SYMBOL_PROP_FORMULA,                                     // The formula used for custom symbol pricing
   SYMBOL_PROP_ISIN,                                        // The name of a trading symbol in the international system of securities identification numbers (ISIN)
   SYMBOL_PROP_PAGE,                                        // The web page containing symbol information
   SYMBOL_PROP_PATH,                                        // Location in the symbol tree
   SYMBOL_PROP_CATEGORY,                                    // Symbol category
   SYMBOL_PROP_EXCHANGE,                                    // Name of an exchange a symbol is traded on
   SYMBOL_PROP_COUNTRY,                                     // Country the trading instrument belongs to
   SYMBOL_PROP_SECTOR_NAME,                                 // Economy sector the trading instrument belongs to
   SYMBOL_PROP_INDUSTRY_NAME,                               // Economy or industry branch the trading instrument belongs to
  };
#define SYMBOL_PROP_STRING_TOTAL     (16)                   // Total number of string properties
//+------------------------------------------------------------------+
//| Possible symbol sorting criteria                                 |
//+------------------------------------------------------------------+
#define FIRST_SYM_DBL_PROP          (SYMBOL_PROP_INTEGER_TOTAL-SYMBOL_PROP_INTEGER_SKIP)
#define FIRST_SYM_STR_PROP          (SYMBOL_PROP_INTEGER_TOTAL-SYMBOL_PROP_INTEGER_SKIP+SYMBOL_PROP_DOUBLE_TOTAL-SYMBOL_PROP_DOUBLE_SKIP)
enum ENUM_SORT_SYMBOLS_MODE
  {
//--- Sort by integer properties
   SORT_BY_SYMBOL_STATUS = 0,                               // Sort by symbol status
   SORT_BY_SYMBOL_INDEX_MW,                                 // Sort by index in the Market Watch window
   SORT_BY_SYMBOL_SECTOR,                                   // Sort by economic sector
   SORT_BY_SYMBOL_INDUSTRY,                                 // Sort by industry or economy sector
   SORT_BY_SYMBOL_CUSTOM,                                   // Sort by custom symbol property
   SORT_BY_SYMBOL_CHART_MODE,                               // Sort by price type for constructing bars – Bid or Last (from the ENUM_SYMBOL_CHART_MODE enumeration)
   SORT_BY_SYMBOL_EXIST,                                    // Sort by the flag that a symbol with such a name exists
   SORT_BY_SYMBOL_SELECT,                                   // Sort by the flag indicating that a symbol is selected in Market Watch
   SORT_BY_SYMBOL_VISIBLE,                                  // Sort by the flag indicating that a selected symbol is displayed in Market Watch
   SORT_BY_SYMBOL_SESSION_DEALS,                            // Sort by the number of deals in the current session 
   SORT_BY_SYMBOL_SESSION_BUY_ORDERS,                       // Sort by the total number of current buy orders
   SORT_BY_SYMBOL_SESSION_SELL_ORDERS,                      // Sort by the total number of current sell orders
   SORT_BY_SYMBOL_VOLUME,                                   // Sort by last deal volume
   SORT_BY_SYMBOL_VOLUMEHIGH,                               // Sort by maximum volume for a day
   SORT_BY_SYMBOL_VOLUMELOW,                                // Sort by minimum volume for a day
   SORT_BY_SYMBOL_TIME,                                     // Sort by the last quote time
   SORT_BY_SYMBOL_TIME_MSC,                                 // Sort by the last quote time in milliseconds
   SORT_BY_SYMBOL_DIGITS,                                   // Sort by a number of decimal places
   SORT_BY_SYMBOL_DIGITS_LOT,                               // Sort by a number of decimal places in a lot
   SORT_BY_SYMBOL_SPREAD,                                   // Sort by spread in points
   SORT_BY_SYMBOL_SPREAD_FLOAT,                             // Sort by floating spread
   SORT_BY_SYMBOL_TICKS_BOOKDEPTH,                          // Sort by a maximum number of requests displayed in the market depth
   SORT_BY_SYMBOL_BOOKDEPTH_STATE,                          // Sort by the DOM subscription flag
   SORT_BY_SYMBOL_TRADE_CALC_MODE,                          // Sort by contract price calculation method (from the ENUM_SYMBOL_CALC_MODE enumeration)
   SORT_BY_SYMBOL_TRADE_MODE,                               // Sort by order execution type (from the ENUM_SYMBOL_TRADE_MODE enumeration)
   SORT_BY_SYMBOL_START_TIME,                               // Sort by an instrument trading start date (usually used for futures)
   SORT_BY_SYMBOL_EXPIRATION_TIME,                          // Sort by an instrument trading end date (usually used for futures)
   SORT_BY_SYMBOL_TRADE_STOPS_LEVEL,                        // Sort by the minimum indent from the current close price (in points) for setting Stop orders
   SORT_BY_SYMBOL_TRADE_FREEZE_LEVEL,                       // Sort by trade operation freeze distance (in points)
   SORT_BY_SYMBOL_TRADE_EXEMODE,                            // Sort by trade execution mode (from the ENUM_SYMBOL_TRADE_EXECUTION enumeration)
   SORT_BY_SYMBOL_SWAP_MODE,                                // Sort by swap calculation model (from the ENUM_SYMBOL_SWAP_MODE enumeration)
   SORT_BY_SYMBOL_SWAP_ROLLOVER3DAYS,                       // Sort by week day for accruing a triple swap (from the ENUM_DAY_OF_WEEK enumeration)
   SORT_BY_SYMBOL_MARGIN_HEDGED_USE_LEG,                    // Sort by the calculation mode of a hedged margin using the larger leg (Buy or Sell)
   SORT_BY_SYMBOL_EXPIRATION_MODE,                          // Sort by flags of allowed order expiration modes
   SORT_BY_SYMBOL_FILLING_MODE,                             // Sort by flags of allowed order filling modes
   SORT_BY_SYMBOL_ORDER_MODE,                               // Sort by flags of allowed order types
   SORT_BY_SYMBOL_ORDER_GTC_MODE,                           // Sort by StopLoss and TakeProfit orders lifetime
   SORT_BY_SYMBOL_OPTION_MODE,                              // Sort by option type (from the ENUM_SYMBOL_OPTION_MODE enumeration)
   SORT_BY_SYMBOL_OPTION_RIGHT,                             // Sort by option right (Call/Put) (from the ENUM_SYMBOL_OPTION_RIGHT enumeration)
   SORT_BY_SYMBOL_SUBSCRIPTION_DELAY,                       // Sort by delay for quotes passed by symbol for instruments working on subscription basis
//--- Sort by real properties
   SORT_BY_SYMBOL_BID = FIRST_SYM_DBL_PROP,                 // Sort by Bid
   SORT_BY_SYMBOL_BIDHIGH,                                  // Sort by maximum Bid for a day
   SORT_BY_SYMBOL_BIDLOW,                                   // Sort by minimum Bid for a day
   SORT_BY_SYMBOL_ASK,                                      // Sort by Ask
   SORT_BY_SYMBOL_ASKHIGH,                                  // Sort by maximum Ask for a day
   SORT_BY_SYMBOL_ASKLOW,                                   // Sort by minimum Ask for a day
   SORT_BY_SYMBOL_LAST,                                     // Sort by the last deal price
   SORT_BY_SYMBOL_LASTHIGH,                                 // Sort by maximum Last for a day
   SORT_BY_SYMBOL_LASTLOW,                                  // Sort by minimum Last for a day
   SORT_BY_SYMBOL_VOLUME_REAL,                              // Sort by Volume for a day
   SORT_BY_SYMBOL_VOLUMEHIGH_REAL,                          // Sort by maximum Volume for a day
   SORT_BY_SYMBOL_VOLUMELOW_REAL,                           // Sort by minimum Volume for a day
   SORT_BY_SYMBOL_OPTION_STRIKE,                            // Sort by an option execution price
   SORT_BY_SYMBOL_POINT,                                    // Sort by a single point value
   SORT_BY_SYMBOL_TRADE_TICK_VALUE,                         // Sort by SYMBOL_TRADE_TICK_VALUE_PROFIT value
   SORT_BY_SYMBOL_TRADE_TICK_VALUE_PROFIT,                  // Sort by a calculated tick price for a profitable position
   SORT_BY_SYMBOL_TRADE_TICK_VALUE_LOSS,                    // Sort by a calculated tick price for a loss-making position
   SORT_BY_SYMBOL_TRADE_TICK_SIZE,                          // Sort by a minimum price change
   SORT_BY_SYMBOL_TRADE_CONTRACT_SIZE,                      // Sort by a trading contract size
   SORT_BY_SYMBOL_TRADE_ACCRUED_INTEREST,                   // Sort by accrued interest
   SORT_BY_SYMBOL_TRADE_FACE_VALUE,                         // Sort by face value
   SORT_BY_SYMBOL_TRADE_LIQUIDITY_RATE,                     // Sort by liquidity rate
   SORT_BY_SYMBOL_VOLUME_MIN,                               // Sort by a minimum volume for performing a deal
   SORT_BY_SYMBOL_VOLUME_MAX,                               // Sort by a maximum volume for performing a deal
   SORT_BY_SYMBOL_VOLUME_STEP,                              // Sort by a minimum volume change step for deal execution
   SORT_BY_SYMBOL_VOLUME_LIMIT,                             // Sort by a maximum allowed aggregate volume of an open position and pending orders in one direction
   SORT_BY_SYMBOL_SWAP_LONG,                                // Sort by a long swap value
   SORT_BY_SYMBOL_SWAP_SHORT,                               // Sort by a short swap value
   SORT_BY_SYMBOL_MARGIN_INITIAL,                           // Sort by an initial margin
   SORT_BY_SYMBOL_MARGIN_MAINTENANCE,                       // Sort by a maintenance margin for an instrument
   SORT_BY_SYMBOL_MARGIN_LONG_INITIAL,                      // Sort by initial margin requirement applicable to Long orders
   SORT_BY_SYMBOL_MARGIN_BUY_STOP_INITIAL,                  // Sort by initial margin requirement applicable to BuyStop orders
   SORT_BY_SYMBOL_MARGIN_BUY_LIMIT_INITIAL,                 // Sort by initial margin requirement applicable to BuyLimit orders
   SORT_BY_SYMBOL_MARGIN_BUY_STOPLIMIT_INITIAL,             // Sort by initial margin requirement applicable to BuyStopLimit orders
   SORT_BY_SYMBOL_MARGIN_LONG_MAINTENANCE,                  // Sort by maintenance margin requirement applicable to Long orders
   SORT_BY_SYMBOL_MARGIN_BUY_STOP_MAINTENANCE,              // Sort by maintenance margin requirement applicable to BuyStop orders
   SORT_BY_SYMBOL_MARGIN_BUY_LIMIT_MAINTENANCE,             // Sort by maintenance margin requirement applicable to BuyLimit orders
   SORT_BY_SYMBOL_MARGIN_BUY_STOPLIMIT_MAINTENANCE,         // Sort by maintenance margin requirement applicable to BuyStopLimit orders
   SORT_BY_SYMBOL_MARGIN_SHORT_INITIAL,                     // Sort by initial margin requirement applicable to Short orders
   SORT_BY_SYMBOL_MARGIN_SELL_STOP_INITIAL,                 // Sort by initial margin requirement applicable to SellStop orders
   SORT_BY_SYMBOL_MARGIN_SELL_LIMIT_INITIAL,                // Sort by initial margin requirement applicable to SellLimit orders
   SORT_BY_SYMBOL_MARGIN_SELL_STOPLIMIT_INITIAL,            // Sort by initial margin requirement applicable to SellStopLimit orders
   SORT_BY_SYMBOL_MARGIN_SHORT_MAINTENANCE,                 // Sort by maintenance margin requirement applicable to Short orders
   SORT_BY_SYMBOL_MARGIN_SELL_STOP_MAINTENANCE,             // Sort by maintenance margin requirement applicable to SellStop orders
   SORT_BY_SYMBOL_MARGIN_SELL_LIMIT_MAINTENANCE,            // Sort by maintenance margin requirement applicable to SellLimit orders
   SORT_BY_SYMBOL_MARGIN_SELL_STOPLIMIT_MAINTENANCE,        // Sort by maintenance margin requirement applicable to SellStopLimit orders
   SORT_BY_SYMBOL_SESSION_VOLUME,                           // Sort by summary volume of the current session deals
   SORT_BY_SYMBOL_SESSION_TURNOVER,                         // Sort by the summary turnover of the current session
   SORT_BY_SYMBOL_SESSION_INTEREST,                         // Sort by the summary open interest
   SORT_BY_SYMBOL_SESSION_BUY_ORDERS_VOLUME,                // Sort by the current volume of Buy orders
   SORT_BY_SYMBOL_SESSION_SELL_ORDERS_VOLUME,               // Sort by the current volume of Sell orders
   SORT_BY_SYMBOL_SESSION_OPEN,                             // Sort by an Open price of the current session
   SORT_BY_SYMBOL_SESSION_CLOSE,                            // Sort by a Close price of the current session
   SORT_BY_SYMBOL_SESSION_AW,                               // Sort by an average weighted price of the current session
   SORT_BY_SYMBOL_SESSION_PRICE_SETTLEMENT,                 // Sort by a settlement price of the current session
   SORT_BY_SYMBOL_SESSION_PRICE_LIMIT_MIN,                  // Sort by a minimum price of the current session 
   SORT_BY_SYMBOL_SESSION_PRICE_LIMIT_MAX,                  // Sort by a maximum price of the current session
   SORT_BY_SYMBOL_MARGIN_HEDGED,                            // Sort by a contract size or a margin value per one lot of hedged positions
   SORT_BY_SYMBOL_PRICE_CHANGE,                             // Sort by change of the current price relative to the end of the previous trading day
   SORT_BY_SYMBOL_PRICE_VOLATILITY,                         // Sort by price volatility in %
   SORT_BY_SYMBOL_PRICE_THEORETICAL,                        // Sort by theoretical option price
   SORT_BY_SYMBOL_PRICE_DELTA,                              // Sort by option/warrant delta
   SORT_BY_SYMBOL_PRICE_THETA,                              // Sort by option/warrant theta
   SORT_BY_SYMBOL_PRICE_GAMMA,                              // Sort by option/warrant gamma
   SORT_BY_SYMBOL_PRICE_VEGA,                               // Sort by option/warrant vega
   SORT_BY_SYMBOL_PRICE_RHO,                                // Sort by option/warrant rho
   SORT_BY_SYMBOL_PRICE_OMEGA,                              // Sort by option/warrant omega
   SORT_BY_SYMBOL_PRICE_SENSITIVITY,                        // Sort by option/warrant sensitivity
   SORT_BY_SYMBOL_SWAP_SUNDAY,                              // Sort by swap accrual ratio (Sunday)
   SORT_BY_SYMBOL_SWAP_MONDAY,                              // Sort by swap accrual ratio (Monday)
   SORT_BY_SYMBOL_SWAP_TUESDAY,                             // Sort by swap accrual ratio (Tuesday)
   SORT_BY_SYMBOL_SWAP_WEDNESDAY,                           // Sort by swap accrual ratio (Wednesday)
   SORT_BY_SYMBOL_SWAP_THURSDAY,                            // Sort by swap accrual ratio (Thursday)
   SORT_BY_SYMBOL_SWAP_FRIDAY,                              // Sort by swap accrual ratio (Friday)
   SORT_BY_SYMBOL_SWAP_SATURDAY,                            // Sort by swap accrual ratio (Saturday)
//--- Sort by string properties
   SORT_BY_SYMBOL_NAME = FIRST_SYM_STR_PROP,                // Sort by a symbol name
   SORT_BY_SYMBOL_BASIS,                                    // Sort by an underlying asset of a derivative
   SORT_BY_SYMBOL_CURRENCY_BASE,                            // Sort by a base currency of a symbol
   SORT_BY_SYMBOL_CURRENCY_PROFIT,                          // Sort by a profit currency
   SORT_BY_SYMBOL_CURRENCY_MARGIN,                          // Sort by a margin currency
   SORT_BY_SYMBOL_BANK,                                     // Sort by a feeder of the current quote
   SORT_BY_SYMBOL_DESCRIPTION,                              // Sort by a symbol string description
   SORT_BY_SYMBOL_FORMULA,                                  // Sort by the formula used for custom symbol pricing
   SORT_BY_SYMBOL_ISIN,                                     // Sort by the name of a symbol in the ISIN system
   SORT_BY_SYMBOL_PAGE,                                     // Sort by an address of the web page containing symbol information
   SORT_BY_SYMBOL_PATH,                                     // Sort by a path in the symbol tree
   SORT_BY_SYMBOL_CATEGORY,                                 // Sort by a symbol category
   SORT_BY_SYMBOL_EXCHANGE,                                 // Sort by a name of an exchange a symbol is traded on
   SORT_BY_SYMBOL_COUNTRY,                                  // Sort by country the trading instrument belongs to
   SORT_BY_SYMBOL_SECTOR_NAME,                              // Sort by economy sector the trading instrument belongs to
   SORT_BY_SYMBOL_INDUSTRY_NAME,                            // Sort by economy or industry branch the trading instrument belongs to
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with program resource data                      |
//+------------------------------------------------------------------+
enum ENUM_FILE_TYPE
  {
   FILE_TYPE_WAV,                                           // wav file
   FILE_TYPE_BMP,                                           // bmp file
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with trading classes                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| EA behavior when handling errors                                 |
//+------------------------------------------------------------------+
enum ENUM_ERROR_HANDLING_BEHAVIOR
  {
   ERROR_HANDLING_BEHAVIOR_BREAK,                           // Abort trading attempt
   ERROR_HANDLING_BEHAVIOR_CORRECT,                         // Correct invalid parameters
  };
//+------------------------------------------------------------------+
//| Flags indicating the trading request error handling methods      |
//+------------------------------------------------------------------+
enum ENUM_TRADE_REQUEST_ERR_FLAGS
  {
   TRADE_REQUEST_ERR_FLAG_NO_ERROR                 =  0x0,  // No error
   TRADE_REQUEST_ERR_FLAG_FATAL_ERROR              =  0x1,  // Disable trading for an EA (critical error) - exit
   TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR             =  0x2,  // Library internal error - exit
   TRADE_REQUEST_ERR_FLAG_ERROR_IN_LIST            =  0x4,  // Error in the list - handle (ENUM_ERROR_CODE_PROCESSING_METHOD)
   TRADE_REQUEST_ERR_FLAG_PRICE_ERROR              =  0x8,  // Placement price error
   TRADE_REQUEST_ERR_FLAG_LIMIT_ERROR              =  0x10, // Limit order price error
  };
//+------------------------------------------------------------------+
//| The methods of handling errors and server return codes           |
//+------------------------------------------------------------------+
enum ENUM_ERROR_CODE_PROCESSING_METHOD
  {
   ERROR_CODE_PROCESSING_METHOD_OK,                         // No error
   ERROR_CODE_PROCESSING_METHOD_DISABLE,                    // Disable trading for the EA
   ERROR_CODE_PROCESSING_METHOD_EXIT,                       // Exit the trading method
   ERROR_CODE_PROCESSING_METHOD_CORRECT,                    // Correct trading request parameters and repeat
   ERROR_CODE_PROCESSING_METHOD_REFRESH,                    // Update data and repeat
   ERROR_CODE_PROCESSING_METHOD_WAIT,                       // Wait and repeat
  };
//+------------------------------------------------------------------+
//| Types of performed operations                                    |
//+------------------------------------------------------------------+
enum ENUM_ACTION_TYPE
  {
   ACTION_TYPE_BUY               =  ORDER_TYPE_BUY,               // Open Buy
   ACTION_TYPE_SELL              =  ORDER_TYPE_SELL,              // Open Sell
   ACTION_TYPE_BUY_LIMIT         =  ORDER_TYPE_BUY_LIMIT,         // Place BuyLimit
   ACTION_TYPE_SELL_LIMIT        =  ORDER_TYPE_SELL_LIMIT,        // Place SellLimit
   ACTION_TYPE_BUY_STOP          =  ORDER_TYPE_BUY_STOP,          // Place BuyStop
   ACTION_TYPE_SELL_STOP         =  ORDER_TYPE_SELL_STOP,         // Place SellStop
   ACTION_TYPE_BUY_STOP_LIMIT    =  ORDER_TYPE_BUY_STOP_LIMIT,    // Place BuyStopLimit
   ACTION_TYPE_SELL_STOP_LIMIT   =  ORDER_TYPE_SELL_STOP_LIMIT,   // Place SellStopLimit
   ACTION_TYPE_CLOSE_BY          =  ORDER_TYPE_CLOSE_BY,          // Close a position by an opposite one
   ACTION_TYPE_CLOSE             =  ACTION_TYPE_CLOSE_BY+3,       // Close/remove
   ACTION_TYPE_MODIFY            =  ACTION_TYPE_CLOSE_BY+4,       // Modify
  };
//+------------------------------------------------------------------+
//| Sound setting mode                                               |
//+------------------------------------------------------------------+
enum ENUM_MODE_SET_SOUND
  {
   MODE_SET_SOUND_OPEN,                                     // Opening/placing sound setting mode
   MODE_SET_SOUND_CLOSE,                                    // Closing/removal sound setting mode
   MODE_SET_SOUND_MODIFY_SL,                                // StopLoss modification sound setting mode
   MODE_SET_SOUND_MODIFY_TP,                                // TakeProfit modification sound setting mode
   MODE_SET_SOUND_MODIFY_PRICE,                             // Placing price modification sound setting mode
   MODE_SET_SOUND_ERROR_OPEN,                               // Opening/placing error sound setting mode
   MODE_SET_SOUND_ERROR_CLOSE,                              // Closing/removal error sound setting mode
   MODE_SET_SOUND_ERROR_MODIFY_SL,                          // StopLoss modification error sound setting mode
   MODE_SET_SOUND_ERROR_MODIFY_TP,                          // TakeProfit modification error sound setting mode
   MODE_SET_SOUND_ERROR_MODIFY_PRICE,                       // Placing price modification error sound setting mode
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with pending trading requests                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Pending request status                                           |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_STATUS
  {
   PEND_REQ_STATUS_OPEN,                                    // Pending request to open a market position
   PEND_REQ_STATUS_CLOSE,                                   // Pending request to close a position
   PEND_REQ_STATUS_SLTP,                                    // Pending request to modify open position stop orders
   PEND_REQ_STATUS_PLACE,                                   // Pending request to place a pending order
   PEND_REQ_STATUS_REMOVE,                                  // Pending request to delete a pending order
   PEND_REQ_STATUS_MODIFY                                   // Pending request to modify a placed pending order
  };
//+------------------------------------------------------------------+
//| Pending request type                                             |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_TYPE
  {
   PEND_REQ_TYPE_ERROR=PENDING_REQUEST_ID_TYPE_ERR,         // Pending request created based on the return code or error
   PEND_REQ_TYPE_REQUEST=PENDING_REQUEST_ID_TYPE_REQ,       // Pending request created by request
  };
//+------------------------------------------------------------------+
//| Pending request activation source                                |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_ACTIVATION_SOURCE
  {
   PEND_REQ_ACTIVATION_SOURCE_ACCOUNT,                      // Pending request activated by account data
   PEND_REQ_ACTIVATION_SOURCE_SYMBOL,                       // Pending request activated by symbol data
   PEND_REQ_ACTIVATION_SOURCE_EVENT,                        // Pending request activated by trading event data
  };
//+------------------------------------------------------------------+
//| Integer properties of a pending trading request                  |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_PROP_INTEGER
  {
   PEND_REQ_PROP_STATUS = 0,                                // Trading request status (from the ENUM_PEND_REQ_STATUS enumeration)
   PEND_REQ_PROP_TYPE,                                      // Trading request type (from the ENUM_PEND_REQ_TYPE enumeration)
   PEND_REQ_PROP_ID,                                        // Trading request ID
   PEND_REQ_PROP_RETCODE,                                   // Result a request is based on
   PEND_REQ_PROP_TIME_CREATE,                               // Request creation time
   PEND_REQ_PROP_TIME_ACTIVATE,                             // Next attempt activation time
   PEND_REQ_PROP_WAITING,                                   // Waiting time between requests
   PEND_REQ_PROP_CURRENT_ATTEMPT,                           // Current attempt index
   PEND_REQ_PROP_TOTAL,                                     // Number of attempts
   PEND_REQ_PROP_ACTUAL_TYPE_FILLING,                       // Actual order filling type
   PEND_REQ_PROP_ACTUAL_TYPE_TIME,                          // Actual order expiration type
   PEND_REQ_PROP_ACTUAL_EXPIRATION,                         // Actual order lifetime
   //--- MqlTradeRequest
   PEND_REQ_PROP_MQL_REQ_ACTION,                            // Type of a performed action in the request structure
   PEND_REQ_PROP_MQL_REQ_TYPE,                              // Order type in the request structure
   PEND_REQ_PROP_MQL_REQ_MAGIC,                             // EA stamp (magic number ID) in the request structure
   PEND_REQ_PROP_MQL_REQ_ORDER,                             // Order ticket in the request structure
   PEND_REQ_PROP_MQL_REQ_POSITION,                          // Position ticket in the request structure
   PEND_REQ_PROP_MQL_REQ_POSITION_BY,                       // Opposite position ticket in the request structure
   PEND_REQ_PROP_MQL_REQ_DEVIATION,                         // Maximum acceptable deviation from a requested price in the request structure
   PEND_REQ_PROP_MQL_REQ_EXPIRATION,                        // Order expiration time (for ORDER_TIME_SPECIFIED type orders) in the request structure
   PEND_REQ_PROP_MQL_REQ_TYPE_FILLING,                      // Order filling type in the request structure
   PEND_REQ_PROP_MQL_REQ_TYPE_TIME,                         // Order lifetime type in the request structure
  }; 
#define PEND_REQ_PROP_INTEGER_TOTAL (22)                    // Total number of integer event properties
#define PEND_REQ_PROP_INTEGER_SKIP  (0)                     // Number of request properties not used in sorting
//+------------------------------------------------------------------+
//| Real properties of a pending trading request                     |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_PROP_DOUBLE
  {
   PEND_REQ_PROP_PRICE_CREATE = PEND_REQ_PROP_INTEGER_TOTAL,// Price at the moment of a request generation
   PEND_REQ_PROP_ACTUAL_VOLUME,                             // Actual volume
   PEND_REQ_PROP_ACTUAL_PRICE,                              // Actual order price
   PEND_REQ_PROP_ACTUAL_STOPLIMIT,                          // Actual stoplimit order price
   PEND_REQ_PROP_ACTUAL_SL,                                 // Actual stoploss order price
   PEND_REQ_PROP_ACTUAL_TP,                                 // Actual takeprofit order price
   //--- MqlTradeRequest
   PEND_REQ_PROP_MQL_REQ_VOLUME,                            // Requested volume of a deal in lots in the request structure
   PEND_REQ_PROP_MQL_REQ_PRICE,                             // Price in the request structure
   PEND_REQ_PROP_MQL_REQ_STOPLIMIT,                         // StopLimit level in the request structure
   PEND_REQ_PROP_MQL_REQ_SL,                                // Stop Loss level in the request structure
   PEND_REQ_PROP_MQL_REQ_TP,                                // Take Profit level in the request structure
  };
#define PEND_REQ_PROP_DOUBLE_TOTAL  (11)                    // Total number of event's real properties
#define PEND_REQ_PROP_DOUBLE_SKIP   (0)                     // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| String properties of a pending trading request                   |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_PROP_STRING
  {
   //--- MqlTradeRequest
   PEND_REQ_PROP_MQL_REQ_SYMBOL = (PEND_REQ_PROP_INTEGER_TOTAL+PEND_REQ_PROP_DOUBLE_TOTAL),  // Trading instrument name in the request structure
   PEND_REQ_PROP_MQL_REQ_COMMENT                            // Order comment in the request structure
  };
#define PEND_REQ_PROP_STRING_TOTAL  (2)                     // Total number of event's string properties
//+------------------------------------------------------------------+
//| Possible pending request sorting criteria                        |
//+------------------------------------------------------------------+
#define FIRST_PREQ_DBL_PROP         (PEND_REQ_PROP_INTEGER_TOTAL-PEND_REQ_PROP_INTEGER_SKIP)
#define FIRST_PREQ_STR_PROP         (PEND_REQ_PROP_INTEGER_TOTAL-PEND_REQ_PROP_INTEGER_SKIP+PEND_REQ_PROP_DOUBLE_TOTAL-PEND_REQ_PROP_DOUBLE_SKIP)
enum ENUM_SORT_PEND_REQ_MODE
  {
//--- Sort by integer properties
   SORT_BY_PEND_REQ_STATUS = 0,                             // Sort by a trading request status (from the ENUM_PEND_REQ_STATUS enumeration)
   SORT_BY_PEND_REQ_TYPE,                                   // Sort by a trading request type (from the ENUM_PEND_REQ_TYPE enumeration)
   SORT_BY_PEND_REQ_ID,                                     // Sort by a trading request ID
   SORT_BY_PEND_REQ_RETCODE,                                // Sort by a result a request is based on
   SORT_BY_PEND_REQ_TIME_CREATE,                            // Sort by a request generation time
   SORT_BY_PEND_REQ_TIME_ACTIVATE,                          // Sort by next attempt activation time
   SORT_BY_PEND_REQ_WAITING,                                // Sort by a waiting time between requests
   SORT_BY_PEND_REQ_CURENT,                                 // Sort by the current attempt index
   SORT_BY_PEND_REQ_TOTAL,                                  // Sort by a number of attempts
   SORT_BY_PEND_REQ_ACTUAL_TYPE_FILLING,                    // Sort by actual order filling type
   SORT_BY_PEND_REQ_ACTUAL_TYPE_TIME,                       // Sort by actual order expiration type
   SORT_BY_PEND_REQ_ACTUAL_EXPIRATION,                      // Sort by actual order lifetime
   //--- MqlTradeRequest
   SORT_BY_PEND_REQ_MQL_REQ_ACTION,                         // Sort by a type of a performed action in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_TYPE,                           // Sort by an order type in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_MAGIC,                          // Sort by an EA stamp (magic number ID) in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_ORDER,                          // Sort by an order ticket in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_POSITION,                       // Sort by a position ticket in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_POSITION_BY,                    // Sort by an opposite position ticket in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_DEVIATION,                      // Sort by a maximum acceptable deviation from a requested price in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_EXPIRATION,                     // Sort by an order expiration time (for ORDER_TIME_SPECIFIED type orders) in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_TYPE_FILLING,                   // Sort by an order filling type in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_TYPE_TIME,                      // Sort by order lifetime type in the request structure
//--- Sort by real properties
   SORT_BY_PEND_REQ_PRICE_CREATE = FIRST_PREQ_DBL_PROP,     // Sort by a price at the moment of a request generation
   SORT_BY_PEND_REQ_ACTUAL_VOLUME,                          // Sort by actual volume
   SORT_BY_PEND_REQ_ACTUAL_PRICE,                           // Sort by actual order price
   SORT_BY_PEND_REQ_ACTUAL_STOPLIMIT,                       // Sort by actual stoplimit order price
   SORT_BY_PEND_REQ_ACTUAL_SL,                              // Sort by actual stoploss order price
   SORT_BY_PEND_REQ_ACTUAL_TP,                              // Sort by actual takeprofit order price
   //--- MqlTradeRequest
   SORT_BY_PEND_REQ_MQL_REQ_VOLUME,                         // Sort by a requested volume of a deal in lots in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_PRICE,                          // Sort by a price in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_STOPLIMIT,                      // Sort by StopLimit order level in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_SL,                             // Sort by StopLoss order level in the request structure
   SORT_BY_PEND_REQ_MQL_REQ_TP,                             // Sort by TakeProfit order level in the request structure
//--- Sort by string properties
   //--- MqlTradeRequest
   SORT_BY_PEND_REQ_MQL_SYMBOL = FIRST_PREQ_STR_PROP,       // Sort by a trading instrument name in the request structure
   SORT_BY_PEND_REQ_MQL_COMMENT                             // Sort by an order comment in the request structure
  };
//+------------------------------------------------------------------+
//| Possible criteria for activating requests by account properties  |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_ACTIVATE_BY_ACCOUNT_PROP
  {
   //--- long
   PEND_REQ_ACTIVATE_BY_ACCOUNT_EMPTY                    =  MSG_LIB_PROP_NOT_SET,                     // Value not set
   PEND_REQ_ACTIVATE_BY_ACCOUNT_LEVERAGE                 =  MSG_ACC_PROP_LEVERAGE,                    // Activate by a provided leverage
   PEND_REQ_ACTIVATE_BY_ACCOUNT_LIMIT_ORDERS             =  MSG_ACC_PROP_LIMIT_ORDERS,                // Activate by a maximum allowed number of active pending orders
   PEND_REQ_ACTIVATE_BY_ACCOUNT_TRADE_ALLOWED            =  MSG_ACC_PROP_TRADE_ALLOWED,               // Activate by the permission to trade for the current account from the server side
   PEND_REQ_ACTIVATE_BY_ACCOUNT_TRADE_EXPERT             =  MSG_ACC_PROP_TRADE_EXPERT,                // Activate by the permission to trade for an EA from the server side
   //--- double
   PEND_REQ_ACTIVATE_BY_ACCOUNT_BALANCE                  =  MSG_ACC_PROP_BALANCE,                     // Activate by an account balance in the deposit currency
   PEND_REQ_ACTIVATE_BY_ACCOUNT_CREDIT                   =  MSG_ACC_PROP_CREDIT,                      // Activate by credit in a deposit currency
   PEND_REQ_ACTIVATE_BY_ACCOUNT_PROFIT                   =  MSG_ACC_PROP_PROFIT,                      // Activate by the current profit on the account in the deposit currency
   PEND_REQ_ACTIVATE_BY_ACCOUNT_EQUITY                   =  MSG_ACC_PROP_EQUITY,                      // Sort by an account equity in the deposit currency
   PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN                   =  MSG_ACC_PROP_MARGIN,                      // Activate by an account reserved margin in the deposit currency
   PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_FREE              =  MSG_ACC_PROP_MARGIN_FREE,                 // Activate by account free funds available for opening a position in the deposit currency
   PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_LEVEL             =  MSG_ACC_PROP_MARGIN_LEVEL,                // Activate by account margin level in %
   PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_INITIAL           =  MSG_ACC_PROP_MARGIN_INITIAL,              // Activate by funds reserved on an account to ensure a guarantee amount for all pending orders
   PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_MAINTENANCE       =  MSG_ACC_PROP_MARGIN_MAINTENANCE,          // Activate by funds reserved on an account to ensure a minimum amount for all open positions
   PEND_REQ_ACTIVATE_BY_ACCOUNT_ASSETS                   =  MSG_ACC_PROP_ASSETS,                      // Activate by the current assets on the account
   PEND_REQ_ACTIVATE_BY_ACCOUNT_LIABILITIES              =  MSG_ACC_PROP_LIABILITIES,                 // Activate by the current liabilities on the account
   PEND_REQ_ACTIVATE_BY_ACCOUNT_COMMISSION_BLOCKED       =  MSG_ACC_PROP_COMMISSION_BLOCKED           // Activate by the current amount of blocked commissions on the account
  };
//+------------------------------------------------------------------+
//| Possible criteria for activating requests by symbol properties   |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_ACTIVATE_BY_SYMBOL_PROP
  {
   PEND_REQ_ACTIVATE_BY_SYMBOL_EMPTY                     =  MSG_LIB_PROP_NOT_SET,                     // Value not set
   //--- double
   PEND_REQ_ACTIVATE_BY_SYMBOL_BID                       =  MSG_LIB_PROP_BID,                         // Activate by Bid - the best price at which a symbol can be sold
   PEND_REQ_ACTIVATE_BY_SYMBOL_ASK                       =  MSG_LIB_PROP_ASK,                         // Activate by Ask - best price, at which an instrument can be bought
   PEND_REQ_ACTIVATE_BY_SYMBOL_LAST                      =  MSG_LIB_PROP_LAST,                        // Activate by the last deal price
   //--- long
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_DEALS             =  MSG_SYM_PROP_SESSION_DEALS,               // Activate by number of deals in the current session
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_BUY_ORDERS        =  MSG_SYM_PROP_SESSION_BUY_ORDERS,          // Activate by number of Buy orders at the moment
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_SELL_ORDERS       =  MSG_SYM_PROP_SESSION_SELL_ORDERS,         // Activate by number of Sell orders at the moment
   PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUME                    =  MSG_SYM_PROP_VOLUME,                      // Activate by the last deal volume
   PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMEHIGH                =  MSG_SYM_PROP_VOLUMEHIGH,                  // Activate by maximum Volume per day
   PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMELOW                 =  MSG_SYM_PROP_VOLUMELOW,                   // Activate by minimum Volume per day
   PEND_REQ_ACTIVATE_BY_SYMBOL_TIME                      =  MSG_SYM_PROP_TIME,                        // Activate by the last quote time
   PEND_REQ_ACTIVATE_BY_SYMBOL_SPREAD                    =  MSG_SYM_PROP_SPREAD,                      // Activate by spread in points
   PEND_REQ_ACTIVATE_BY_SYMBOL_START_TIME                =  MSG_SYM_PROP_START_TIME,                  // Activate by an instrument trading start date (usually used for futures)
   PEND_REQ_ACTIVATE_BY_SYMBOL_EXPIRATION_TIME           =  MSG_SYM_PROP_EXPIRATION_TIME,             // Activate by an instrument trading completion date (usually used for futures)
   PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_STOPS_LEVEL         =  MSG_SYM_PROP_TRADE_STOPS_LEVEL,           // Activate by the minimum indent from the current close price (in points) for setting Stop orders
   PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_FREEZE_LEVEL        =  MSG_SYM_PROP_TRADE_FREEZE_LEVEL,          // Activate by trade operation freeze distance (in points)
   //--- double
   PEND_REQ_ACTIVATE_BY_SYMBOL_BIDHIGH                   =  MSG_SYM_PROP_BIDHIGH,                     // Activate by a maximum Bid of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_BIDLOW                    =  MSG_SYM_PROP_BIDLOW,                      // Activate by a minimum Bid of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_ASKHIGH                   =  MSG_SYM_PROP_ASKHIGH,                     // Activate by a maximum Ask of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_ASKLOW                    =  MSG_SYM_PROP_ASKLOW,                      // Activate by a minimum Ask of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_LASTHIGH                  =  MSG_SYM_PROP_LASTHIGH,                    // Activate by the maximum Last of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_LASTLOW                   =  MSG_SYM_PROP_LASTLOW,                     // Activate by the minimum Last of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUME_REAL               =  MSG_SYM_PROP_VOLUME_REAL,                 // Activate by Volume of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMEHIGH_REAL           =  MSG_SYM_PROP_VOLUMEHIGH_REAL,             // Activate by a maximum Volume of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMELOW_REAL            =  MSG_SYM_PROP_VOLUMELOW_REAL,              // Activate by a minimum Volume of the day
   PEND_REQ_ACTIVATE_BY_SYMBOL_OPTION_STRIKE             =  MSG_SYM_PROP_OPTION_STRIKE,               // Activate by an option execution price
   PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_ACCRUED_INTEREST    =  MSG_SYM_PROP_TRADE_ACCRUED_INTEREST,      // Activate by an accrued interest
   PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_FACE_VALUE          =  MSG_SYM_PROP_TRADE_FACE_VALUE,            // Activate by a face value – initial bond value set by an issuer
   PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_LIQUIDITY_RATE      =  MSG_SYM_PROP_TRADE_LIQUIDITY_RATE,        // Activate by a liquidity rate – the share of an asset that can be used for a margin
   PEND_REQ_ACTIVATE_BY_SYMBOL_SWAP_LONG                 =  MSG_SYM_PROP_SWAP_LONG,                   // Activate by a long swap value
   PEND_REQ_ACTIVATE_BY_SYMBOL_SWAP_SHORT                =  MSG_SYM_PROP_SWAP_SHORT,                  // Activate by a short swap value
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_VOLUME            =  MSG_SYM_PROP_SESSION_VOLUME,              // Activate by a summary volume of the current session deals
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_TURNOVER          =  MSG_SYM_PROP_SESSION_TURNOVER,            // Activate by a summary turnover of the current session
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_INTEREST          =  MSG_SYM_PROP_SESSION_INTEREST,            // Activate by a summary open interest
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_BUY_ORDERS_VOLUME =  MSG_SYM_PROP_SESSION_BUY_ORDERS_VOLUME,   // Activate by the current volume of Buy orders
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_SELL_ORDERS_VOLUME=  MSG_SYM_PROP_SESSION_SELL_ORDERS_VOLUME,  // Activate by the current volume of Sell orders
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_OPEN              =  MSG_SYM_PROP_SESSION_OPEN,                // Activate by an open price of the current session
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_CLOSE             =  MSG_SYM_PROP_SESSION_CLOSE,               // Activate by a close price of the current session
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_AW                =  MSG_SYM_PROP_SESSION_AW,                  // Activate by an average weighted session price
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_SETTLEMENT  =  MSG_SYM_PROP_SESSION_PRICE_SETTLEMENT,    // Activate by a settlement price of the current session
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_LIMIT_MIN   =  MSG_SYM_PROP_SESSION_PRICE_LIMIT_MIN,     // Activate by a minimum session price 
   PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_LIMIT_MAX   =  MSG_SYM_PROP_SESSION_PRICE_LIMIT_MAX,     // Activate by a maximum session price
  };
//+------------------------------------------------------------------+
//| Possible criteria for activating requests by events              |
//+------------------------------------------------------------------+

enum ENUM_PEND_REQ_ACTIVATE_BY_EVENT
  {
   PEND_REQ_ACTIVATE_BY_EVENT_EMPTY                               =  MSG_LIB_PROP_NOT_SET,                        // Value not set
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_OPENED                     =  MSG_EVN_STATUS_MARKET_POSITION,              // Position opened
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED                     =  MSG_EVN_STATUS_HISTORY_POSITION,             // Position closed
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_PLASED                =  MSG_EVN_PENDING_ORDER_PLASED,                // Pending order placed
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_REMOVED               =  MSG_EVN_PENDING_ORDER_REMOVED,               // Pending order removed
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CREDIT                      =  MSG_EVN_ACCOUNT_CREDIT,                      // Accruing credit (3)
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CHARGE                      =  MSG_EVN_ACCOUNT_CHARGE,                      // Additional charges
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CORRECTION                  =  MSG_EVN_ACCOUNT_CORRECTION,                  // Correcting entry
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BONUS                       =  MSG_EVN_ACCOUNT_BONUS,                       // Charging bonuses
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION                   =  MSG_EVN_ACCOUNT_COMISSION,                   // Additional commissions
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_DAILY             =  MSG_EVN_ACCOUNT_COMISSION_DAILY,             // Commission charged at the end of a day
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_MONTHLY           =  MSG_EVN_ACCOUNT_COMISSION_MONTHLY,           // Commission charged at the end of a trading month
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_AGENT_DAILY       =  MSG_EVN_ACCOUNT_COMISSION_AGENT_DAILY,       // Agent commission charged at the end of a trading day
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY     =  MSG_EVN_ACCOUNT_COMISSION_AGENT_MONTHLY,     // Agent commission charged at the end of a month
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_INTEREST                    =  MSG_EVN_ACCOUNT_INTEREST,                    // Accruing interest on free funds
   PEND_REQ_ACTIVATE_BY_EVENT_BUY_CANCELLED                       =  MSG_EVN_BUY_CANCELLED,                       // Canceled buy deal
   PEND_REQ_ACTIVATE_BY_EVENT_SELL_CANCELLED                      =  MSG_EVN_SELL_CANCELLED,                      // Canceled sell deal
   PEND_REQ_ACTIVATE_BY_EVENT_DIVIDENT                            =  MSG_EVN_DIVIDENT,                            // Accruing dividends
   PEND_REQ_ACTIVATE_BY_EVENT_DIVIDENT_FRANKED                    =  MSG_EVN_DIVIDENT_FRANKED,                    // Accrual of franked dividend
   PEND_REQ_ACTIVATE_BY_EVENT_TAX                                 =  MSG_EVN_TAX,                                 // Tax accrual
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BALANCE_REFILL              =  MSG_EVN_BALANCE_REFILL,                      // Replenishing account balance
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BALANCE_WITHDRAWAL          =  MSG_EVN_BALANCE_WITHDRAWAL,                  // Withdrawing funds from an account
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_ACTIVATED             =  MSG_EVN_ACTIVATED_PENDING,                   // Pending order activated by price
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL     =  MSG_EVN_ACTIVATED_PENDING_PARTIALLY,         // Pending order partially activated by price
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_OPENED_PARTIAL             =  MSG_EVN_POSITION_OPENED_PARTIALLY,           // Position opened partially
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL             =  MSG_EVN_POSITION_CLOSED_PARTIALLY,           // Position closed partially
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_POS              =  MSG_EVN_POSITION_CLOSED_BY_POS,              // Position closed by an opposite one
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_POS      =  MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_POS,    // Position partially closed by an opposite one
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_SL               =  MSG_EVN_POSITION_CLOSED_BY_SL,               // Position closed by StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_TP               =  MSG_EVN_POSITION_CLOSED_BY_TP,               // Position closed by TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_SL       =  MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_SL,     // Position closed partially by StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_TP       =  MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_TP,     // Position closed partially by TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_MARKET         =  MSG_EVN_POSITION_REVERSED_BY_MARKET,         // Position reversal by a new deal (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_PENDING        =  MSG_EVN_POSITION_REVERSED_BY_PENDING,        // Position reversal by activating a pending order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL =  MSG_EVN_POSITION_REVERSE_PARTIALLY,          // Position reversal by partial market order execution (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOLUME_ADD_BY_MARKET       =  MSG_EVN_POSITION_VOLUME_ADD_BY_MARKET,       // Added volume to a position by a new deal (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOLUME_ADD_BY_PENDING      =  MSG_EVN_POSITION_VOLUME_ADD_BY_PENDING,      // Added volume to a position by activating a pending order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE                  =  MSG_EVN_MODIFY_ORDER_PRICE,                  // Changing order price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_SL               =  MSG_EVN_MODIFY_ORDER_PRICE_SL,               // Changing order and StopLoss price 
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_TP               =  MSG_EVN_MODIFY_ORDER_PRICE_TP,               // Changing order and TakeProfit price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_SL_TP            =  MSG_EVN_MODIFY_ORDER_PRICE_SL_TP,            // Changing order, StopLoss and TakeProfit price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_SL_TP                  =  MSG_EVN_MODIFY_ORDER_SL_TP,                  // Changing order's StopLoss and TakeProfit price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_SL                     =  MSG_EVN_MODIFY_ORDER_SL,                     // Changing order's StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_TP                     =  MSG_EVN_MODIFY_ORDER_TP,                     // Changing order's TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_SL_TP               =  MSG_EVN_MODIFY_POSITION_SL_TP,               // Changing position's StopLoss and TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_SL                  =  MSG_EVN_MODIFY_POSITION_SL,                  // Change position's StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_TP                  =  MSG_EVN_MODIFY_POSITION_TP,                  // Changing position's TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOL_ADD_BY_MARKET_PARTIAL  =  MSG_EVN_REASON_ADD_PARTIALLY,                // Added volume to a position by partial execution of a market order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOL_ADD_BY_PENDING_PARTIAL =  MSG_EVN_REASON_ADD_BY_PENDING_PARTIALLY,     // Added volume to a position by partial activation of a pending order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_TRIGGERED_STOP_LIMIT_ORDER          =  MSG_EVN_REASON_STOPLIMIT_TRIGGERED,          // StopLimit order activation
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL=  MSG_EVN_REASON_REVERSE_BY_PENDING_PARTIALLY, // Position reversal by activating a pending order (netting)
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Info for working with serial data                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bar type (candle body)                                           |
//+------------------------------------------------------------------+
enum ENUM_BAR_BODY_TYPE
  {
   BAR_BODY_TYPE_BULLISH,                                   // Bullish bar
   BAR_BODY_TYPE_BEARISH,                                   // Bearish bar
   BAR_BODY_TYPE_NULL,                                      // Zero bar
   BAR_BODY_TYPE_CANDLE_ZERO_BODY,                          // Candle with a zero body
  };
//+------------------------------------------------------------------+
//| Bar integer properties                                           |
//+------------------------------------------------------------------+
enum ENUM_BAR_PROP_INTEGER
  {
   BAR_PROP_TIME = 0,                                       // Bar period start time
   BAR_PROP_TYPE,                                           // Bar type (from the ENUM_BAR_BODY_TYPE enumeration)
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
  }; 
#define BAR_PROP_INTEGER_TOTAL (13)                         // Total number of integer bar properties
#define BAR_PROP_INTEGER_SKIP  (0)                          // Number of bar properties not used in sorting
//+------------------------------------------------------------------+
//| Real bar properties                                              |
//+------------------------------------------------------------------+
enum ENUM_BAR_PROP_DOUBLE
  {
//--- bar data
   BAR_PROP_OPEN = BAR_PROP_INTEGER_TOTAL,                  // Bar open price
   BAR_PROP_HIGH,                                           // Highest price for the bar period
   BAR_PROP_LOW,                                            // Lowest price for the bar period
   BAR_PROP_CLOSE,                                          // Bar close price
//--- candle data
   BAR_PROP_CANDLE_SIZE,                                    // Candle size
   BAR_PROP_CANDLE_SIZE_BODY,                               // Candle body size
   BAR_PROP_CANDLE_BODY_TOP,                                // Candle body top
   BAR_PROP_CANDLE_BODY_BOTTOM,                             // Candle body bottom
   BAR_PROP_CANDLE_SIZE_SHADOW_UP,                          // Candle upper wick size
   BAR_PROP_CANDLE_SIZE_SHADOW_DOWN,                        // Candle lower wick size
//--- candle proportions
   BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE,                      // Percentage ratio of the candle body to the full size of the candle
   BAR_PROP_RATIO_UPPER_SHADOW_TO_CANDLE_SIZE,              // Percentage ratio of the upper shadow size to the candle size
   BAR_PROP_RATIO_LOWER_SHADOW_TO_CANDLE_SIZE,              // Percentage ratio of the lower shadow size to the candle size
  }; 
#define BAR_PROP_DOUBLE_TOTAL  (13)                         // Total number of real bar properties
#define BAR_PROP_DOUBLE_SKIP   (0)                          // Number of bar properties not used in sorting
//+------------------------------------------------------------------+
//| Bar string properties                                            |
//+------------------------------------------------------------------+
enum ENUM_BAR_PROP_STRING
  {
   BAR_PROP_SYMBOL = (BAR_PROP_INTEGER_TOTAL+BAR_PROP_DOUBLE_TOTAL), // Bar symbol
  };
#define BAR_PROP_STRING_TOTAL  (1)                          // Total number of string bar properties
//+------------------------------------------------------------------+
//| Possible bar sorting criteria                                    |
//+------------------------------------------------------------------+
#define FIRST_BAR_DBL_PROP          (BAR_PROP_INTEGER_TOTAL-BAR_PROP_INTEGER_SKIP)
#define FIRST_BAR_STR_PROP          (BAR_PROP_INTEGER_TOTAL-BAR_PROP_INTEGER_SKIP+BAR_PROP_DOUBLE_TOTAL-BAR_PROP_DOUBLE_SKIP)
enum ENUM_SORT_BAR_MODE
  {
//--- Sort by integer properties
   SORT_BY_BAR_TIME = 0,                                    // Sort by bar period start time
   SORT_BY_BAR_TYPE,                                        // Sort by bar type (from the ENUM_BAR_BODY_TYPE enumeration)
   SORT_BY_BAR_PERIOD,                                      // Sort by bar period (timeframe)
   SORT_BY_BAR_SPREAD,                                      // Sort by bar spread
   SORT_BY_BAR_VOLUME_TICK,                                 // Sort by bar tick volume
   SORT_BY_BAR_VOLUME_REAL,                                 // Sort by bar exchange volume
   SORT_BY_BAR_TIME_DAY_OF_YEAR,                            // Sort by bar day number in a year
   SORT_BY_BAR_TIME_YEAR,                                   // Sort by a year the bar belongs to
   SORT_BY_BAR_TIME_MONTH,                                  // Sort by a month the bar belongs to
   SORT_BY_BAR_TIME_DAY_OF_WEEK,                            // Sort by a bar week day
   SORT_BY_BAR_TIME_DAY,                                    // Sort by a bar day
   SORT_BY_BAR_TIME_HOUR,                                   // Sort by a bar hour
   SORT_BY_BAR_TIME_MINUTE,                                 // Sort by a bar minute
//--- Sort by real properties
   SORT_BY_BAR_OPEN = FIRST_BAR_DBL_PROP,                   // Sort by bar open price
   SORT_BY_BAR_HIGH,                                        // Sort by the highest price for the bar period
   SORT_BY_BAR_LOW,                                         // Sort by the lowest price for the bar period
   SORT_BY_BAR_CLOSE,                                       // Sort by a bar close price
   SORT_BY_BAR_CANDLE_SIZE,                                 // Sort by a candle price
   SORT_BY_BAR_CANDLE_SIZE_BODY,                            // Sort by a candle body size
   SORT_BY_BAR_CANDLE_BODY_TOP,                             // Sort by a candle body top
   SORT_BY_BAR_CANDLE_BODY_BOTTOM,                          // Sort by a candle body bottom
   SORT_BY_BAR_CANDLE_SIZE_SHADOW_UP,                       // Sort by candle upper wick size
   SORT_BY_BAR_CANDLE_SIZE_SHADOW_DOWN,                     // Sort by candle lower wick size
//--- Sort by string properties
   SORT_BY_BAR_SYMBOL = FIRST_BAR_STR_PROP,                 // Sort by a bar symbol
  };
//+------------------------------------------------------------------+
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
  };
//+------------------------------------------------------------------+
//| Pattern type                                                     |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_TYPE
  {
//--- Candle formations
   PATTERN_TYPE_HARAMI              =  0x0,                 // Harami
   PATTERN_TYPE_HARAMI_CROSS        =  0x1,                 // Harami Cross
   PATTERN_TYPE_TWEEZER             =  0x2,                 // Tweezer
   PATTERN_TYPE_PIERCING_LINE       =  0x4,                 // Piercing Line
   PATTERN_TYPE_DARK_CLOUD_COVER    =  0x8,                 // Dark Cloud Cover
   PATTERN_TYPE_THREE_WHITE_SOLDIERS=  0x10,                // Three White Soldiers
   PATTERN_TYPE_THREE_BLACK_CROWS   =  0x20,                // Three Black Crows
   PATTERN_TYPE_SHOOTING_STAR       =  0x40,                // Shooting Star
   PATTERN_TYPE_HAMMER              =  0x80,                // Hammer
   PATTERN_TYPE_INVERTED_HAMMER     =  0x100,               // Inverted Hammer
   PATTERN_TYPE_HANGING_MAN         =  0x200,               // Hanging Man
   PATTERN_TYPE_DOJI                =  0x400,               // Doji
   PATTERN_TYPE_DRAGONFLY_DOJI      =  0x800,               // Dragonfly Doji
   PATTERN_TYPE_GRAVESTONE_DOJI     =  0x1000,              // Gravestone Doji
   PATTERN_TYPE_MORNING_STAR        =  0x2000,              // Morning Star
   PATTERN_TYPE_MORNING_DOJI_STAR   =  0x4000,              // Morning Doji Star
   PATTERN_TYPE_EVENING_STAR        =  0x8000,              // Evening Star
   PATTERN_TYPE_EVENING_DOJI_STAR   =  0x10000,             // Evening Doji Star
   PATTERN_TYPE_THREE_STARS         =  0x20000,             // Three Stars
   PATTERN_TYPE_ABANDONED_BABY      =  0x40000,             // Abandoned Baby
//--- Price Action
   PATTERN_TYPE_PIVOT_POINT_REVERSAL=  0x80000,             // Price Action Reversal Pattern
   PATTERN_TYPE_OUTSIDE_BAR         =  0x100000,            // Price Action Outside Bar
   PATTERN_TYPE_INSIDE_BAR          =  0x200000,            // Price Action Inside Bar
   PATTERN_TYPE_PIN_BAR             =  0x400000,            // Price Action Pin Bar
   PATTERN_TYPE_RAILS               =  0x800000,            // Price Action Rails
  };
//+------------------------------------------------------------------+
//| Pattern integer properties                                       |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_PROP_INTEGER
  {
   PATTERN_PROP_CODE = 0,                                   // Unique pattern code (time + type + status + direction + timeframe)
   PATTERN_PROP_CTRL_OBJ_ID,                                // Pattern control object ID
   PATTERN_PROP_ID,                                         // Pattern ID
   PATTERN_PROP_TIME,                                       // Pattern defining bar time
   PATTERN_PROP_STATUS,                                     // Pattern status (from the ENUM_PATTERN_STATUS enumeration)
   PATTERN_PROP_TYPE,                                       // Pattern type (from the ENUM_PATTERN_TYPE enumeration)
   PATTERN_PROP_DIRECTION,                                  // Pattern type by direction (from the ENUM_PATTERN_TYPE_DIRECTION enumeration)
   PATTERN_PROP_PERIOD,                                     // Pattern period (timeframe)
   PATTERN_PROP_CANDLES,                                    // Number of candles that make up the pattern
  }; 
#define PATTERN_PROP_INTEGER_TOTAL (9)                      // Total number of integer pattern properties
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
   PATTERN_PROP_RATIO_BODY_TO_CANDLE_SIZE_CRITERION,           // Defined criterion of the ratio of the candle body to the full candle size in %
   PATTERN_PROP_RATIO_LARGER_SHADOW_TO_CANDLE_SIZE_CRITERION,  // Defined criterion of the ratio of the maximum shadow to the candle size in %
   PATTERN_PROP_RATIO_SMALLER_SHADOW_TO_CANDLE_SIZE_CRITERION, // Defined criterion of the ratio of the minimum shadow to the candle size in %
  }; 
#define PATTERN_PROP_DOUBLE_TOTAL   (10)                    // Total number of real pattern properties
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
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of possible timeseries events                               |
//+------------------------------------------------------------------+
enum ENUM_SERIES_EVENT
  {
   SERIES_EVENTS_NO_EVENT = SYMBOL_EVENTS_NEXT_CODE,        // No event
   SERIES_EVENTS_NEW_BAR,                                   // "New bar" event
   SERIES_EVENTS_MISSING_BARS,                              // "Bars skipped" event
   SERIES_EVENTS_PATTERN,                                   // "Pattern" event
  };
#define SERIES_EVENTS_NEXT_CODE  (SERIES_EVENTS_PATTERN+1)  // Code of the next event after the "Bars skipped" event
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with indicator buffers                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract buffer status (by drawing style)                        |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_STATUS
  {
   BUFFER_STATUS_NONE,                                      // No drawing
   BUFFER_STATUS_FILLING,                                   // Color filling between two levels (MQL5)
   BUFFER_STATUS_LINE,                                      // Line
   BUFFER_STATUS_HISTOGRAM,                                 // Histogram from the zero line
   BUFFER_STATUS_ARROW,                                     // Drawing with arrows
   BUFFER_STATUS_SECTION,                                   // Section
   BUFFER_STATUS_HISTOGRAM2,                                // Histogram on two indicator buffers
   BUFFER_STATUS_ZIGZAG,                                    // Zigzag style
   BUFFER_STATUS_BARS,                                      // Display as bars (MQL5)
   BUFFER_STATUS_CANDLES,                                   // Display as candles (MQL5)
  };
//+------------------------------------------------------------------+
//| Buffer type                                                      |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_TYPE
  {
   BUFFER_TYPE_CALCULATE,                                   // Calculated buffer
   BUFFER_TYPE_DATA,                                        // Colored data buffer
  };
//+------------------------------------------------------------------+
//| Values of indicator lines in enumeration                         |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_LINE_MODE
  {
   INDICATOR_LINE_MODE_MAIN         =  0,                   // Main line
   INDICATOR_LINE_MODE_SIGNAL       =  1,                   // Signal line
   INDICATOR_LINE_MODE_UPPER        =  0,                   // Upper line
   INDICATOR_LINE_MODE_LOWER        =  1,                   // Lower line
   INDICATOR_LINE_MODE_MIDDLE       =  2,                   // Middle line
   INDICATOR_LINE_MODE_JAWS         =  0,                   // Jaws line
   INDICATOR_LINE_MODE_TEETH        =  1,                   // Teeth line
   INDICATOR_LINE_MODE_LIPS         =  2,                   // Lips line
   INDICATOR_LINE_MODE_DI_PLUS      =  1,                   // +DI line
   INDICATOR_LINE_MODE_DI_MINUS     =  2,                   // -DI line
   INDICATOR_LINE_MODE_TENKAN_SEN   =  0,                   // Tenkan-sen line
   INDICATOR_LINE_MODE_KIJUN_SEN    =  1,                   // Kijun-sen line
   INDICATOR_LINE_MODE_SENKOU_SPANA =  2,                   // Senkou Span A line
   INDICATOR_LINE_MODE_SENKOU_SPANB =  3,                   // Senkou Span B line
   INDICATOR_LINE_MODE_CHIKOU_SPAN  =  4,                   // Chikou Span line
   INDICATOR_LINE_MODE_ADDITIONAL   =  5,                   // Additional line
  };
//+------------------------------------------------------------------+
//| Enumeration of indicator lines                                   |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_LINE
  {
   INDICATOR_LINE_MAIN,                                     // Main line
   INDICATOR_LINE_SIGNAL,                                   // Signal line
   INDICATOR_LINE_UPPER,                                    // Upper line
   INDICATOR_LINE_LOWER,                                    // Lower line
   INDICATOR_LINE_MIDDLE,                                   // Middle line
   INDICATOR_LINE_JAWS,                                     // Jaws line
   INDICATOR_LINE_TEETH,                                    // Teeth line
   INDICATOR_LINE_LIPS,                                     // Lips line
   INDICATOR_LINE_DI_PLUS,                                  // +DI line
   INDICATOR_LINE_DI_MINUS,                                 // -DI line
   INDICATOR_LINE_TENKAN_SEN,                               // Tenkan-sen line
   INDICATOR_LINE_KIJUN_SEN,                                // Kijun-sen line
   INDICATOR_LINE_SENKOU_SPANA,                             // Senkou Span A line
   INDICATOR_LINE_SENKOU_SPANB,                             // Senkou Span B line
   INDICATOR_LINE_CHIKOU_SPAN,                              // Chikou Span line
   INDICATOR_LINE_ADDITIONAL,                               // Additional line
  };
//+------------------------------------------------------------------+
//| Buffer integer properties                                        |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_PROP_INTEGER
  {
   BUFFER_PROP_INDEX_PLOT = 0,                              // Plotted buffer serial number
   BUFFER_PROP_STATUS,                                      // Buffer status (by drawing style) from the ENUM_BUFFER_STATUS enumeration
   BUFFER_PROP_TYPE,                                        // Buffer type (from the ENUM_BUFFER_TYPE enumeration)
   BUFFER_PROP_TIMEFRAME,                                   // Buffer period data (timeframe)
   BUFFER_PROP_ACTIVE,                                      // Buffer usage flag
   BUFFER_PROP_DRAW_TYPE,                                   // Graphical construction type (from the ENUM_DRAW_TYPE enumeration)
   BUFFER_PROP_ARROW_CODE,                                  // Arrow code for DRAW_ARROW style
   BUFFER_PROP_ARROW_SHIFT,                                 // The vertical shift of the arrows for DRAW_ARROW style
   BUFFER_PROP_LINE_STYLE,                                  // Line style
   BUFFER_PROP_LINE_WIDTH,                                  // Line width
   BUFFER_PROP_DRAW_BEGIN,                                  // The number of initial bars that are not drawn and values in DataWindow
   BUFFER_PROP_SHOW_DATA,                                   // Flag of displaying construction values in DataWindow
   BUFFER_PROP_SHIFT,                                       // Indicator graphical construction shift by time axis in bars
   BUFFER_PROP_COLOR_INDEXES,                               // Number of colors
   BUFFER_PROP_COLOR,                                       // Drawing color
   BUFFER_PROP_INDEX_BASE,                                  // Base data buffer index
   BUFFER_PROP_INDEX_NEXT_BASE,                             // Index of the array to be assigned as the next indicator buffer
   BUFFER_PROP_INDEX_NEXT_PLOT,                             // Index of the next drawn buffer
   BUFFER_PROP_ID,                                          // ID of multiple buffers of a single indicator
   BUFFER_PROP_IND_LINE_MODE,                               // Indicator line
   BUFFER_PROP_IND_HANDLE,                                  // Handle of an indicator using a buffer
   BUFFER_PROP_IND_TYPE,                                    // Type of an indicator using a buffer
   BUFFER_PROP_IND_LINE_ADDITIONAL_NUM,                     // Number of indicator additional line
   BUFFER_PROP_NUM_DATAS,                                   // Number of data buffers
   BUFFER_PROP_INDEX_COLOR,                                 // Color buffer index
  }; 
#define BUFFER_PROP_INTEGER_TOTAL (25)                      // Total number of integer bar properties
#define BUFFER_PROP_INTEGER_SKIP  (2)                       // Number of buffer properties not used in sorting
//+------------------------------------------------------------------+
//| Buffer real properties                                           |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_PROP_DOUBLE
  {
   BUFFER_PROP_EMPTY_VALUE = BUFFER_PROP_INTEGER_TOTAL,     // Empty value for plotting where nothing will be drawn
  }; 
#define BUFFER_PROP_DOUBLE_TOTAL  (1)                       // Total number of real buffer properties
#define BUFFER_PROP_DOUBLE_SKIP   (0)                       // Number of buffer properties not used in sorting
//+------------------------------------------------------------------+
//| Buffer string properties                                         |
//+------------------------------------------------------------------+
enum ENUM_BUFFER_PROP_STRING
  {
   BUFFER_PROP_SYMBOL = (BUFFER_PROP_INTEGER_TOTAL+BUFFER_PROP_DOUBLE_TOTAL), // Buffer symbol
   BUFFER_PROP_LABEL,                                       // Name of the graphical indicator series displayed in DataWindow
   BUFFER_PROP_IND_NAME,                                    // Name of an indicator using a buffer
   BUFFER_PROP_IND_NAME_SHORT,                              // Short name of an indicator using a buffer
  };
#define BUFFER_PROP_STRING_TOTAL  (4)                       // Total number of string buffer properties
//+------------------------------------------------------------------+
//| Possible buffer sorting criteria                                 |
//+------------------------------------------------------------------+
#define FIRST_BUFFER_DBL_PROP          (BUFFER_PROP_INTEGER_TOTAL-BUFFER_PROP_INTEGER_SKIP)
#define FIRST_BUFFER_STR_PROP          (BUFFER_PROP_INTEGER_TOTAL-BUFFER_PROP_INTEGER_SKIP+BUFFER_PROP_DOUBLE_TOTAL-BUFFER_PROP_DOUBLE_SKIP)
enum ENUM_SORT_BUFFER_MODE
  {
//--- Sort by integer properties
   SORT_BY_BUFFER_INDEX_PLOT = 0,                           // Sort by the plotted buffer serial number
   SORT_BY_BUFFER_STATUS,                                   // Sort by buffer drawing style (status) from the ENUM_BUFFER_STATUS enumeration
   SORT_BY_BUFFER_TYPE,                                     // Sort by buffer type (from the ENUM_BUFFER_TYPE enumeration)
   SORT_BY_BUFFER_TIMEFRAME,                                // Sort by the buffer data period (timeframe)
   SORT_BY_BUFFER_ACTIVE,                                   // Sort by the buffer usage flag
   SORT_BY_BUFFER_DRAW_TYPE,                                // Sort by graphical construction type (from the ENUM_DRAW_TYPE enumeration)
   SORT_BY_BUFFER_ARROW_CODE,                               // Sort by the arrow code for DRAW_ARROW style
   SORT_BY_BUFFER_ARROW_SHIFT,                              // Sort by the vertical shift of the arrows for DRAW_ARROW style
   SORT_BY_BUFFER_LINE_STYLE,                               // Sort by the line style
   SORT_BY_BUFFER_LINE_WIDTH,                               // Sort by the line width
   SORT_BY_BUFFER_DRAW_BEGIN,                               // Sort by the number of initial bars that are not drawn and values in DataWindow
   SORT_BY_BUFFER_SHOW_DATA,                                // Sort by the flag of displaying construction values in DataWindow
   SORT_BY_BUFFER_SHIFT,                                    // Sort by the indicator graphical construction shift by time axis in bars
   SORT_BY_BUFFER_COLOR_INDEXES,                            // Sort by a number of attempts
   SORT_BY_BUFFER_COLOR,                                    // Sort by the drawing color
   SORT_BY_BUFFER_INDEX_BASE,                               // Sort by the basic data buffer index
   SORT_BY_BUFFER_INDEX_NEXT_BASE,                          // Sort by the index of the array to be assigned as the next indicator buffer
   SORT_BY_BUFFER_INDEX_NEXT_PLOT,                          // Sort by the index of the next drawn buffer
   SORT_BY_BUFFER_ID,                                       // Sort by ID of multiple buffers of a single indicator
   SORT_BY_BUFFER_IND_LINE_MODE,                            // Sort by the indicator line
   SORT_BY_BUFFER_IND_HANDLE,                               // Sort by handle of an indicator using a buffer
   SORT_BY_BUFFER_IND_TYPE,                                 // Sort by type of an indicator using a buffer
   SORT_BY_BUFFER_IND_LINE_ADDITIONAL_NUM,                  // Sort by number of additional indicator line
//--- Sort by real properties
   SORT_BY_BUFFER_EMPTY_VALUE = FIRST_BUFFER_DBL_PROP,      // Sort by the empty value for plotting where nothing will be drawn
//--- Sort by string properties
   SORT_BY_BUFFER_SYMBOL = FIRST_BUFFER_STR_PROP,           // Sort by the buffer symbol
   SORT_BY_BUFFER_LABEL,                                    // Sort by the name of the graphical indicator series displayed in DataWindow
   SORT_BY_BUFFER_IND_NAME,                                 // Sort by name of an indicator using a buffer
   SORT_BY_BUFFER_IND_NAME_SHORT,                           // Sort by a short name of an indicator using a buffer
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with indicators                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract indicator status                                        |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_STATUS
  {
   INDICATOR_STATUS_STANDARD,                               // Standard indicator
   INDICATOR_STATUS_CUSTOM,                                 // Custom indicator
  };
//+------------------------------------------------------------------+
//| Indicator group                                                  |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_GROUP
  {
   INDICATOR_GROUP_TREND,                                   // Trend indicator
   INDICATOR_GROUP_OSCILLATOR,                              // Oscillator
   INDICATOR_GROUP_VOLUMES,                                 // Volumes
   INDICATOR_GROUP_ARROWS,                                  // Arrow indicator
   INDICATOR_GROUP_ANY,                                     // Any indicator
  };
//+------------------------------------------------------------------+
//| Indicator integer properties                                     |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_INTEGER
  {
   INDICATOR_PROP_STATUS = 0,                               // Indicator status (from enumeration ENUM_INDICATOR_STATUS)
   INDICATOR_PROP_TYPE,                                     // Indicator type (from enumeration ENUM_INDICATOR)
   INDICATOR_PROP_TIMEFRAME,                                // Indicator timeframe
   INDICATOR_PROP_HANDLE,                                   // Indicator handle
   INDICATOR_PROP_GROUP,                                    // Indicator group
   INDICATOR_PROP_ID,                                       // Indicator ID
  }; 
#define INDICATOR_PROP_INTEGER_TOTAL (6)                    // Total number of indicator integer properties
#define INDICATOR_PROP_INTEGER_SKIP  (0)                    // Number of indicator properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator real properties                                        |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_DOUBLE
  {
   INDICATOR_PROP_EMPTY_VALUE = INDICATOR_PROP_INTEGER_TOTAL,// Empty value for plotting where nothing will be drawn
  }; 
#define INDICATOR_PROP_DOUBLE_TOTAL  (1)                    // Total number of real indicator properties
#define INDICATOR_PROP_DOUBLE_SKIP   (0)                    // Number of indicator properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator string properties                                      |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_STRING
  {
   INDICATOR_PROP_SYMBOL = (INDICATOR_PROP_INTEGER_TOTAL+INDICATOR_PROP_DOUBLE_TOTAL), // Indicator symbol
   INDICATOR_PROP_NAME,                                     // Indicator name
   INDICATOR_PROP_SHORTNAME,                                // Indicator short name
  };
#define INDICATOR_PROP_STRING_TOTAL  (3)                    // Total number of indicator string properties
//+------------------------------------------------------------------+
//| Possible indicator sorting criteria                              |
//+------------------------------------------------------------------+
#define FIRST_INDICATOR_DBL_PROP          (INDICATOR_PROP_INTEGER_TOTAL-INDICATOR_PROP_INTEGER_SKIP)
#define FIRST_INDICATOR_STR_PROP          (INDICATOR_PROP_INTEGER_TOTAL-INDICATOR_PROP_INTEGER_SKIP+INDICATOR_PROP_DOUBLE_TOTAL-INDICATOR_PROP_DOUBLE_SKIP)
enum ENUM_SORT_INDICATOR_MODE
  {
//--- Sort by integer properties
   SORT_BY_INDICATOR_INDEX_STATUS = 0,                      // Sort by indicator status
   SORT_BY_INDICATOR_TYPE,                                  // Sort by indicator type
   SORT_BY_INDICATOR_TIMEFRAME,                             // Sort by indicator timeframe
   SORT_BY_INDICATOR_HANDLE,                                // Sort by indicator handle
   SORT_BY_INDICATOR_GROUP,                                 // Sort by indicator group
   SORT_BY_INDICATOR_ID,                                    // Sort by indicator ID
//--- Sort by real properties
   SORT_BY_INDICATOR_EMPTY_VALUE = FIRST_INDICATOR_DBL_PROP,// Sort by the empty value for plotting where nothing will be drawn
//--- Sort by string properties
   SORT_BY_INDICATOR_SYMBOL = FIRST_INDICATOR_STR_PROP,     // Sort by indicator symbol
   SORT_BY_INDICATOR_NAME,                                  // Sort by indicator name
   SORT_BY_INDICATOR_SHORTNAME,                             // Sort by indicator short name
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with indicator data                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Integer properties of indicator data                             |
//+------------------------------------------------------------------+
enum ENUM_IND_DATA_PROP_INTEGER
  {
   IND_DATA_PROP_TIME = 0,                                  // Start time of indicator data bar period
   IND_DATA_PROP_PERIOD,                                    // Indicator data period (timeframe)
   IND_DATA_PROP_INDICATOR_TYPE,                            // Indicator type
   IND_DATA_PROP_IND_BUFFER_NUM,                            // Indicator data buffer number
   IND_DATA_PROP_IND_ID,                                    // Indicator ID
   IND_DATA_PROP_IND_HANDLE,                                // Indicator handle
  }; 
#define IND_DATA_PROP_INTEGER_TOTAL (6)                     // Total number of indicator data integer properties
#define IND_DATA_PROP_INTEGER_SKIP  (0)                     // Number of indicator data properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator data real properties                                   |
//+------------------------------------------------------------------+
enum ENUM_IND_DATA_PROP_DOUBLE
  {
//--- bar data
   IND_DATA_PROP_BUFFER_VALUE = IND_DATA_PROP_INTEGER_TOTAL,// Indicator data value
  }; 
#define IND_DATA_PROP_DOUBLE_TOTAL  (1)                     // Total number of indicator data real properties
#define IND_DATA_PROP_DOUBLE_SKIP   (0)                     // Number of indicator data properties not used in sorting
//+------------------------------------------------------------------+
//| Indicator data string properties                                 |
//+------------------------------------------------------------------+
enum ENUM_IND_DATA_PROP_STRING
  {
   IND_DATA_PROP_SYMBOL = (IND_DATA_PROP_INTEGER_TOTAL+IND_DATA_PROP_DOUBLE_TOTAL), // Indicator data symbol
   IND_DATA_PROP_IND_NAME,                                  // Indicator name
   IND_DATA_PROP_IND_SHORTNAME,                             // Indicator short name
  };
#define IND_DATA_PROP_STRING_TOTAL  (3)                     // Total number of string properties of indicator data
//+------------------------------------------------------------------+
//| Possible criteria for indicator data sorting                     |
//+------------------------------------------------------------------+
#define FIRST_IND_DATA_DBL_PROP          (IND_DATA_PROP_INTEGER_TOTAL-IND_DATA_PROP_INTEGER_SKIP)
#define FIRST_IND_DATA_STR_PROP          (IND_DATA_PROP_INTEGER_TOTAL-IND_DATA_PROP_INTEGER_SKIP+IND_DATA_PROP_DOUBLE_TOTAL-IND_DATA_PROP_DOUBLE_SKIP)
enum ENUM_SORT_IND_DATA_MODE
  {
//--- Sort by integer properties
   SORT_BY_IND_DATA_TIME = 0,                               // Sort by bar period start time of indicator data
   SORT_BY_IND_DATA_PERIOD,                                 // Sort by indicator data period (timeframe)
   SORT_BY_IND_DATA_INDICATOR_TYPE,                         // Sort by indicator type
   SORT_BY_IND_DATA_IND_BUFFER_NUM,                         // Sort by indicator data buffer number
   SORT_BY_IND_DATA_IND_ID,                                 // Sort by indicator ID
   SORT_BY_IND_DATA_IND_HANDLE,                             // Sort by indicator handle
//--- Sort by real properties
   SORT_BY_IND_DATA_BUFFER_VALUE = FIRST_IND_DATA_DBL_PROP, // Sort by indicator data value
//--- Sort by string properties
   SORT_BY_IND_DATA_SYMBOL = FIRST_IND_DATA_STR_PROP,       // Sort by indicator data symbol
   SORT_BY_IND_DATA_IND_NAME,                               // Sort by indicator name
   SORT_BY_IND_DATA_IND_SHORTNAME,                          // Sort by indicator short name
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with tick data                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Integer tick properties                                          |
//+------------------------------------------------------------------+
enum ENUM_TICK_PROP_INTEGER
  {
   TICK_PROP_TIME_MSC = 0,                                  // Time of the last price update in milliseconds
   TICK_PROP_TIME,                                          // Time of the last update
   TICK_PROP_VOLUME,                                        // Volume for the current Last price
   TICK_PROP_FLAGS,                                         // Tick flags
  }; 
#define TICK_PROP_INTEGER_TOTAL (4)                         // Total number of tick integer properties
#define TICK_PROP_INTEGER_SKIP  (0)                         // Number of tick properties not used in sorting
//+------------------------------------------------------------------+
//| Real tick properties                                             |
//+------------------------------------------------------------------+
enum ENUM_TICK_PROP_DOUBLE
  {
   TICK_PROP_BID = TICK_PROP_INTEGER_TOTAL,                 // Tick Bid price
   TICK_PROP_ASK,                                           // Tick Ask price
   TICK_PROP_LAST,                                          // Current price of the last trade (Last)
   TICK_PROP_VOLUME_REAL,                                   // Volume for the current Last price with greater accuracy
   TICK_PROP_SPREAD,                                        // Tick spread (Ask - Bid)
  }; 
#define TICK_PROP_DOUBLE_TOTAL  (5)                         // Total number of real tick properties
#define TICK_PROP_DOUBLE_SKIP   (0)                         // Number of tick properties not used in sorting
//+------------------------------------------------------------------+
//| String tick properties                                           |
//+------------------------------------------------------------------+
enum ENUM_TICK_PROP_STRING
  {
   TICK_PROP_SYMBOL = (TICK_PROP_INTEGER_TOTAL+TICK_PROP_DOUBLE_TOTAL), // Tick symbol
  };
#define TICK_PROP_STRING_TOTAL  (1)                         // Total number of string tick properties
//+------------------------------------------------------------------+
//| Possible tick sorting criteria                                   |
//+------------------------------------------------------------------+
#define FIRST_TICK_DBL_PROP          (TICK_PROP_INTEGER_TOTAL-TICK_PROP_INTEGER_SKIP)
#define FIRST_TICK_STR_PROP          (TICK_PROP_INTEGER_TOTAL-TICK_PROP_INTEGER_SKIP+TICK_PROP_DOUBLE_TOTAL-TICK_PROP_DOUBLE_SKIP)
enum ENUM_SORT_TICK_MODE
  {
//--- Sort by integer properties
   SORT_BY_TICK_TIME_MSC = 0,                               // Sort by the time of the last price update in milliseconds
   SORT_BY_TICK_TIME,                                       // Sort by the time of the last price update
   SORT_BY_TICK_VOLUME,                                     // Sort by volume for the current Last price
   SORT_BY_TICK_FLAGS,                                      // Sort by tick flags
//--- Sort by real properties
   SORT_BY_TICK_BID = FIRST_TICK_DBL_PROP,                  // Sort by tick Bid price
   SORT_BY_TICK_ASK,                                        // Sort by tick Ask price
   SORT_BY_TICK_LAST,                                       // Sort by current price of the last trade (Last)
   SORT_BY_TICK_VOLUME_REAL,                                // Sort by volume for the current Last price with greater accuracy
   SORT_BY_TICK_SPREAD,                                     // Sort by tick spread
//--- Sort by string properties
   SORT_BY_TICK_SYMBOL = FIRST_TICK_STR_PROP,               // Sort by tick symbol
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with DOM                                        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of possible DOM events                                      |
//+------------------------------------------------------------------+
#define MBOOK_ORD_EVENTS_NEXT_CODE  (SERIES_EVENTS_NEXT_CODE+1)   // The code of the next event after the last DOM event code
//+------------------------------------------------------------------+
//| Abstract DOM type (status)                                       |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_STATUS
  {
   MBOOK_ORD_STATUS_BUY,                              // Buy side
   MBOOK_ORD_STATUS_SELL,                             // Sell side
  };
//+------------------------------------------------------------------+
//| Integer properties of DOM order                                  |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_PROP_INTEGER
  {
   MBOOK_ORD_PROP_STATUS = 0,                         // Order status
   MBOOK_ORD_PROP_TYPE,                               // Order type
   MBOOK_ORD_PROP_VOLUME,                             // Order volume
   MBOOK_ORD_PROP_TIME_MSC,                           // Time of making a DOM snapshot in milliseconds
  }; 
#define MBOOK_ORD_PROP_INTEGER_TOTAL (4)              // Total number of integer properties
#define MBOOK_ORD_PROP_INTEGER_SKIP  (0)              // Number of integer DOM properties not used in sorting
//+------------------------------------------------------------------+
//| Real properties of DOM order                                     |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_PROP_DOUBLE
  {
   MBOOK_ORD_PROP_PRICE = MBOOK_ORD_PROP_INTEGER_TOTAL, // Order price
   MBOOK_ORD_PROP_VOLUME_REAL,                        // Extended accuracy order volume
  };
#define MBOOK_ORD_PROP_DOUBLE_TOTAL  (2)              // Total number of real properties
#define MBOOK_ORD_PROP_DOUBLE_SKIP   (0)              // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| String properties of DOM order                                   |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_PROP_STRING
  {
   MBOOK_ORD_PROP_SYMBOL = (MBOOK_ORD_PROP_INTEGER_TOTAL+MBOOK_ORD_PROP_DOUBLE_TOTAL), // Order symbol name
  };
#define MBOOK_ORD_PROP_STRING_TOTAL  (1)              // Total number of string properties
//+------------------------------------------------------------------+
//| Possible sorting criteria of DOM orders                          |
//+------------------------------------------------------------------+
#define FIRST_MB_DBL_PROP  (MBOOK_ORD_PROP_INTEGER_TOTAL-MBOOK_ORD_PROP_INTEGER_SKIP)
#define FIRST_MB_STR_PROP  (MBOOK_ORD_PROP_INTEGER_TOTAL-MBOOK_ORD_PROP_INTEGER_SKIP+MBOOK_ORD_PROP_DOUBLE_TOTAL-MBOOK_ORD_PROP_DOUBLE_SKIP)
enum ENUM_SORT_MBOOK_ORD_MODE
  {
//--- Sort by integer properties
   SORT_BY_MBOOK_ORD_STATUS = 0,                      // Sort by order status
   SORT_BY_MBOOK_ORD_TYPE,                            // Sort by order type
   SORT_BY_MBOOK_ORD_VOLUME,                          // Sort by order volume
   SORT_BY_MBOOK_ORD_TIME_MSC,                        // Sort by time of making a DOM snapshot in milliseconds
//--- Sort by real properties
   SORT_BY_MBOOK_ORD_PRICE = FIRST_MB_DBL_PROP,       // Sort by order price
   SORT_BY_MBOOK_ORD_VOLUME_REAL,                     // Sort by extended accuracy order volume
//--- Sort by string properties
   SORT_BY_MBOOK_ORD_SYMBOL = FIRST_MB_STR_PROP,      // Sort by symbol name
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with MQL5.com signals                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| The list of possible signal events                               |
//+------------------------------------------------------------------+
#define SIGNAL_MQL5_EVENTS_NEXT_CODE  (MBOOK_ORD_EVENTS_NEXT_CODE+1)   // The code of the next event after the last signal event code
//+------------------------------------------------------------------+
//| MQL5 signal integer properties                                   |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_MQL5_PROP_INTEGER
  {
   SIGNAL_MQL5_PROP_TRADE_MODE = 0,                   // Account type
   SIGNAL_MQL5_PROP_DATE_PUBLISHED,                   // Signal publication date 
   SIGNAL_MQL5_PROP_DATE_STARTED,                     // Start date of signal monitoring
   SIGNAL_MQL5_PROP_DATE_UPDATED,                     // Date of the latest update of the signal trading statistics
   SIGNAL_MQL5_PROP_ID,                               // Signal ID
   SIGNAL_MQL5_PROP_LEVERAGE,                         // Trading account leverage
   SIGNAL_MQL5_PROP_PIPS,                             // Trading result in pips
   SIGNAL_MQL5_PROP_RATING,                           // Position in the signal rating
   SIGNAL_MQL5_PROP_SUBSCRIBERS,                      // Number of subscribers
   SIGNAL_MQL5_PROP_TRADES,                           // Number of trades
   SIGNAL_MQL5_PROP_SUBSCRIPTION_STATUS,              // Status of account subscription to a signal
  };
#define SIGNAL_MQL5_PROP_INTEGER_TOTAL (11)           // Total number of integer properties
#define SIGNAL_MQL5_PROP_INTEGER_SKIP  (0)            // Number of integer DOM properties not used in sorting
//+------------------------------------------------------------------+
//| MQL5 signal real properties                                      |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_MQL5_PROP_DOUBLE
  {
   SIGNAL_MQL5_PROP_BALANCE = SIGNAL_MQL5_PROP_INTEGER_TOTAL, // Account balance
   SIGNAL_MQL5_PROP_EQUITY,                           // Account equity
   SIGNAL_MQL5_PROP_GAIN,                             // Account growth in %
   SIGNAL_MQL5_PROP_MAX_DRAWDOWN,                     // Maximum drawdown
   SIGNAL_MQL5_PROP_PRICE,                            // Signal subscription price
   SIGNAL_MQL5_PROP_ROI,                              // Signal ROI (Return on Investment) in %
  };
#define SIGNAL_MQL5_PROP_DOUBLE_TOTAL  (6)            // Total number of real properties
#define SIGNAL_MQL5_PROP_DOUBLE_SKIP   (0)            // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| MQL5 signal string properties                                    |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_MQL5_PROP_STRING
  {
   SIGNAL_MQL5_PROP_AUTHOR_LOGIN = (SIGNAL_MQL5_PROP_INTEGER_TOTAL+SIGNAL_MQL5_PROP_DOUBLE_TOTAL), // Signal author login
   SIGNAL_MQL5_PROP_BROKER,                           // Broker (company) name
   SIGNAL_MQL5_PROP_BROKER_SERVER,                    // Broker server
   SIGNAL_MQL5_PROP_NAME,                             // Signal name
   SIGNAL_MQL5_PROP_CURRENCY,                         // Signal account currency
  };
#define SIGNAL_MQL5_PROP_STRING_TOTAL  (5)            // Total number of string properties
//+------------------------------------------------------------------+
//| Possible sorting criteria of MQL5 signals                        |
//+------------------------------------------------------------------+
#define FIRST_SIGNAL_MQL5_DBL_PROP  (SIGNAL_MQL5_PROP_INTEGER_TOTAL-SIGNAL_MQL5_PROP_INTEGER_SKIP)
#define FIRST_SIGNAL_MQL5_STR_PROP  (SIGNAL_MQL5_PROP_INTEGER_TOTAL-SIGNAL_MQL5_PROP_INTEGER_SKIP+SIGNAL_MQL5_PROP_DOUBLE_TOTAL-SIGNAL_MQL5_PROP_DOUBLE_SKIP)
enum ENUM_SORT_SIGNAL_MQL5_MODE
  {
//--- Sort by integer properties
   SORT_BY_SIGNAL_MQL5_TRADE_MODE = 0,                // Sort by signal type
   SORT_BY_SIGNAL_MQL5_DATE_PUBLISHED,                // Sort by signal publication date 
   SORT_BY_SIGNAL_MQL5_DATE_STARTED,                  // Sort by signal monitoring start date
   SORT_BY_SIGNAL_MQL5_DATE_UPDATED,                  // Sort by date of the latest update of the signal trading statistics
   SORT_BY_SIGNAL_MQL5_ID,                            // Sort by signal ID
   SORT_BY_SIGNAL_MQL5_LEVERAGE,                      // Sort by trading account leverage
   SORT_BY_SIGNAL_MQL5_PIPS,                          // Sort by trading result in pips
   SORT_BY_SIGNAL_MQL5_RATING,                        // Sort by a position in the signal rating
   SORT_BY_SIGNAL_MQL5_SUBSCRIBERS,                   // Sort by the number of subscribers
   SORT_BY_SIGNAL_MQL5_TRADES,                        // Sort by the number of trades
   SORT_BY_SIGNAL_MQL5_SUBSCRIPTION_STATUS,           // Sort by the status of account subscription to a signal
//--- Sort by real properties
   SORT_BY_SIGNAL_MQL5_BALANCE = FIRST_SIGNAL_MQL5_DBL_PROP, // Sort by account balance
   SORT_BY_SIGNAL_MQL5_EQUITY,                        // Sort by account equity
   SORT_BY_SIGNAL_MQL5_GAIN,                          // Sort by account growth in %
   SORT_BY_SIGNAL_MQL5_MAX_DRAWDOWN,                  // Sort by maximum drawdown
   SORT_BY_SIGNAL_MQL5_PRICE,                         // Sort by signal subscription price
   SORT_BY_SIGNAL_MQL5_ROI,                           // Sort by ROI
//--- Sort by string properties
   SORT_BY_SIGNAL_MQL5_AUTHOR_LOGIN = FIRST_SIGNAL_MQL5_STR_PROP, // Sort by signal author login
   SORT_BY_SIGNAL_MQL5_BROKER,                        // Sort by broker (company) name
   SORT_BY_SIGNAL_MQL5_BROKER_SERVER,                 // Sort by broker server
   SORT_BY_SIGNAL_MQL5_NAME,                          // Sort by signal name
   SORT_BY_SIGNAL_MQL5_CURRENCY,                      // Sort by signal account currency
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with charts                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of possible chart events                                    |
//+------------------------------------------------------------------+
enum ENUM_CHART_OBJ_EVENT
  {
   CHART_OBJ_EVENT_NO_EVENT = SIGNAL_MQL5_EVENTS_NEXT_CODE, // No event
   CHART_OBJ_EVENT_CHART_OPEN,                        // "New chart opening" event
   CHART_OBJ_EVENT_CHART_CLOSE,                       // "Chart closure" event
   CHART_OBJ_EVENT_CHART_SYMB_CHANGE,                 // "Chart symbol changed" event
   CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE,              // "Chart symbol and timeframe changed" event
   CHART_OBJ_EVENT_CHART_TF_CHANGE,                   // "Chart timeframe changed" event
   CHART_OBJ_EVENT_CHART_WND_ADD,                     // "Adding a new window on the chart" event
   CHART_OBJ_EVENT_CHART_WND_DEL,                     // "Removing a window from the chart" event
   CHART_OBJ_EVENT_CHART_WND_IND_ADD,                 // "Adding a new indicator to the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_DEL,                 // "Removing an indicator from the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_CHANGE,              // "Changing indicator parameters in the chart window" event
  };
#define CHART_OBJ_EVENTS_NEXT_CODE  (CHART_OBJ_EVENT_CHART_WND_IND_CHANGE+1)  // The code of the next event after the last chart event code
//+------------------------------------------------------------------+
//| Chart integer property                                           |
//+------------------------------------------------------------------+
enum ENUM_CHART_PROP_INTEGER
  {
   CHART_PROP_ID = 0,                                 // Chart ID
   CHART_PROP_TIMEFRAME,                              // Chart timeframe
   CHART_PROP_SHOW,                                   // Price chart drawing
   CHART_PROP_IS_OBJECT,                              // Chart object (OBJ_CHART) identification attribute
   CHART_PROP_BRING_TO_TOP,                           // Show chart above all others
   CHART_PROP_CONTEXT_MENU,                           // Enable/disable access to the context menu using the right click 
   CHART_PROP_CROSSHAIR_TOOL,                         // Enable/disable access to the Crosshair tool using the middle click
   CHART_PROP_MOUSE_SCROLL,                           // Scroll the chart horizontally using the left mouse button
   CHART_PROP_EVENT_MOUSE_WHEEL,                      // Send messages about mouse wheel events (CHARTEVENT_MOUSE_WHEEL) to all MQL5 programs on a chart
   CHART_PROP_EVENT_MOUSE_MOVE,                       // Send messages about mouse button click and movement events (CHARTEVENT_MOUSE_MOVE) to all MQL5 programs on a chart
   CHART_PROP_EVENT_OBJECT_CREATE,                    // Send messages about the graphical object creation event (CHARTEVENT_OBJECT_CREATE) to all MQL5 programs on a chart
   CHART_PROP_EVENT_OBJECT_DELETE,                    // Send messages about the graphical object destruction event (CHARTEVENT_OBJECT_DELETE) to all MQL5 programs on a chart
   CHART_PROP_MODE,                                   // Type of the chart (candlesticks, bars or line (ENUM_CHART_MODE))
   CHART_PROP_FOREGROUND,                             // Price chart in the foreground
   CHART_PROP_SHIFT,                                  // Mode of shift of the price chart from the right border
   CHART_PROP_AUTOSCROLL,                             // The mode of automatic shift to the right border of the chart
   CHART_PROP_KEYBOARD_CONTROL,                       // Allow managing the chart using a keyboard
   CHART_PROP_QUICK_NAVIGATION,                       // Allow the chart to intercept Space and Enter key strokes to activate the quick navigation bar
   CHART_PROP_SCALE,                                  // Scale
   CHART_PROP_SCALEFIX,                               // Fixed scale mode
   CHART_PROP_SCALEFIX_11,                            // 1:1 scale mode
   CHART_PROP_SCALE_PT_PER_BAR,                       // The mode of specifying the scale in points per bar
   CHART_PROP_SHOW_TICKER,                            // Display a symbol ticker in the upper left corner
   CHART_PROP_SHOW_OHLC,                              // Display OHLC values in the upper left corner
   CHART_PROP_SHOW_BID_LINE,                          // Display Bid value as a horizontal line on the chart
   CHART_PROP_SHOW_ASK_LINE,                          // Display Ask value as a horizontal line on a chart
   CHART_PROP_SHOW_LAST_LINE,                         // Display Last value as a horizontal line on a chart
   CHART_PROP_SHOW_PERIOD_SEP,                        // Display vertical separators between adjacent periods
   CHART_PROP_SHOW_GRID,                              // Display a grid on the chart
   CHART_PROP_SHOW_VOLUMES,                           // Display volumes on a chart
   CHART_PROP_SHOW_OBJECT_DESCR,                      // Display text descriptions of objects
   CHART_PROP_VISIBLE_BARS,                           // Number of bars on a chart that are available for display
   CHART_PROP_WINDOWS_TOTAL,                          // The total number of chart windows including indicator subwindows
   CHART_PROP_WINDOW_HANDLE,                          // Chart window handle
   CHART_PROP_FIRST_VISIBLE_BAR,                      // Number of the first visible bar on the chart
   CHART_PROP_WIDTH_IN_BARS,                          // Width of the chart in bars
   CHART_PROP_WIDTH_IN_PIXELS,                        // Width of the chart in pixels
   CHART_PROP_COLOR_BACKGROUND,                       // Color of background of the chart
   CHART_PROP_COLOR_FOREGROUND,                       // Color of axes, scale and OHLC line
   CHART_PROP_COLOR_GRID,                             // Grid color
   CHART_PROP_COLOR_VOLUME,                           // Color of volumes and position opening levels
   CHART_PROP_COLOR_CHART_UP,                         // Color for the up bar, shadows and body borders of bull candlesticks
   CHART_PROP_COLOR_CHART_DOWN,                       // Color of down bar, its shadow and border of body of the bullish candlestick
   CHART_PROP_COLOR_CHART_LINE,                       // Color of the chart line and the Doji candlesticks
   CHART_PROP_COLOR_CANDLE_BULL,                      // Color of body of a bullish candlestick
   CHART_PROP_COLOR_CANDLE_BEAR,                      // Color of body of a bearish candlestick
   CHART_PROP_COLOR_BID,                              // Color of the Bid price line
   CHART_PROP_COLOR_ASK,                              // Color of the Ask price line
   CHART_PROP_COLOR_LAST,                             // Color of the last performed deal's price line (Last)
   CHART_PROP_COLOR_STOP_LEVEL,                       // Color of stop order levels (Stop Loss and Take Profit)
   CHART_PROP_SHOW_TRADE_LEVELS,                      // Display trade levels on the chart (levels of open positions, Stop Loss, Take Profit and pending orders)
   CHART_PROP_DRAG_TRADE_LEVELS,                      // Enable the ability to drag trading levels on a chart using mouse
   CHART_PROP_SHOW_DATE_SCALE,                        // Display the time scale on a chart
   CHART_PROP_SHOW_PRICE_SCALE,                       // Display a price scale on a chart
   CHART_PROP_SHOW_ONE_CLICK,                         // Display the quick trading panel on the chart
   CHART_PROP_IS_MAXIMIZED,                           // Chart window maximized
   CHART_PROP_IS_MINIMIZED,                           // Chart window minimized
   CHART_PROP_IS_DOCKED,                              // Chart window docked
   CHART_PROP_FLOAT_LEFT,                             // Left coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_FLOAT_TOP,                              // Upper coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_FLOAT_RIGHT,                            // Right coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_FLOAT_BOTTOM,                           // Bottom coordinate of the undocked chart window relative to the virtual screen
   CHART_PROP_YDISTANCE,                              // Distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   CHART_PROP_HEIGHT_IN_PIXELS,                       // Height of the chart in pixels
   CHART_PROP_WINDOW_IND_HANDLE,                      // Indicator handle on the chart
   CHART_PROP_WINDOW_IND_INDEX,                       // Indicator index on the chart
  };
#define CHART_PROP_INTEGER_TOTAL (66)                 // Total number of integer properties
#define CHART_PROP_INTEGER_SKIP  (2)                  // Number of integer properties not used in sorting
//+------------------------------------------------------------------+
//| Chart real properties                                            |
//+------------------------------------------------------------------+
enum ENUM_CHART_PROP_DOUBLE
  {
   CHART_PROP_SHIFT_SIZE = CHART_PROP_INTEGER_TOTAL,  // Shift size of the zero bar from the right border in %
   CHART_PROP_FIXED_POSITION,                         // Chart fixed position from the left border in %
   CHART_PROP_FIXED_MAX,                              // Chart fixed maximum
   CHART_PROP_FIXED_MIN,                              // Chart fixed minimum
   CHART_PROP_POINTS_PER_BAR,                         // Scale in points per bar
   CHART_PROP_PRICE_MIN,                              // Chart minimum
   CHART_PROP_PRICE_MAX,                              // Chart maximum
  };
#define CHART_PROP_DOUBLE_TOTAL  (7)                  // Total number of real properties
#define CHART_PROP_DOUBLE_SKIP   (0)                  // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| Chart string properties                                          |
//+------------------------------------------------------------------+
enum ENUM_CHART_PROP_STRING
  {
   CHART_PROP_COMMENT = (CHART_PROP_INTEGER_TOTAL+CHART_PROP_DOUBLE_TOTAL), // Chart comment text
   CHART_PROP_EXPERT_NAME,                            // Name of an EA launched on the chart
   CHART_PROP_SCRIPT_NAME,                            // Name of a script launched on the chart
   CHART_PROP_INDICATOR_NAME,                         // Name of the indicator launched in the chart window
   CHART_PROP_SYMBOL,                                 // Chart symbol
  };
#define CHART_PROP_STRING_TOTAL  (5)                  // Total number of string properties
//+------------------------------------------------------------------+
//| Possible chart sorting criteria                                  |
//+------------------------------------------------------------------+
#define FIRST_CHART_DBL_PROP  (CHART_PROP_INTEGER_TOTAL-CHART_PROP_INTEGER_SKIP)
#define FIRST_CHART_STR_PROP  (CHART_PROP_INTEGER_TOTAL-CHART_PROP_INTEGER_SKIP+CHART_PROP_DOUBLE_TOTAL-CHART_PROP_DOUBLE_SKIP)
enum ENUM_SORT_CHART_MODE
  {
//--- Sort by integer properties
   SORT_BY_CHART_ID = 0,                              // Sort by chart ID
   SORT_BY_CHART_TIMEFRAME,                           // Sort by chart timeframe
   SORT_BY_CHART_SHOW,                                // Sort by the price chart drawing attribute
   SORT_BY_CHART_IS_OBJECT,                           // Sort by chart object (OBJ_CHART) identification attribute
   SORT_BY_CHART_BRING_TO_TOP,                        // Sort by the flag of displaying a chart above all others
   SORT_BY_CHART_CONTEXT_MENU,                        // Sort by the flag of enabling/disabling access to the context menu using the right click
   SORT_BY_CHART_CROSSHAIR_TOO,                       // Sort by the flag of enabling/disabling access to the Crosshair tool using the middle click
   SORT_BY_CHART_MOUSE_SCROLL,                        // Sort by the flag of scrolling the chart horizontally using the left mouse button
   SORT_BY_CHART_EVENT_MOUSE_WHEEL,                   // Sort by the flag of sending messages about mouse wheel events to all MQL5 programs on a chart
   SORT_BY_CHART_EVENT_MOUSE_MOVE,                    // Sort by the flag of sending messages about mouse button click and movement events to all MQL5 programs on a chart
   SORT_BY_CHART_EVENT_OBJECT_CREATE,                 // Sort by the flag of sending messages about the graphical object creation event to all MQL5 programs on a chart
   SORT_BY_CHART_EVENT_OBJECT_DELETE,                 // Sort by the flag of sending messages about the graphical object destruction event to all MQL5 programs on a chart
   SORT_BY_CHART_MODE,                                // Sort by chart type
   SORT_BY_CHART_FOREGROUND,                          // Sort by the "Price chart in the foreground" flag
   SORT_BY_CHART_SHIFT,                               // Sort by the "Mode of shift of the price chart from the right border" flag
   SORT_BY_CHART_AUTOSCROLL,                          // Sort by the "The mode of automatic shift to the right border of the chart" flag
   SORT_BY_CHART_KEYBOARD_CONTROL,                    // Sort by the flag allowing the chart management using a keyboard
   SORT_BY_CHART_QUICK_NAVIGATION,                    // Sort by the flag allowing the chart to intercept Space and Enter key strokes to activate the quick navigation bar
   SORT_BY_CHART_SCALE,                               // Sort by scale
   SORT_BY_CHART_SCALEFIX,                            // Sort by the fixed scale flag
   SORT_BY_CHART_SCALEFIX_11,                         // Sort by the 1:1 scale flag
   SORT_BY_CHART_SCALE_PT_PER_BAR,                    // Sort by the flag of specifying the scale in points per bar
   SORT_BY_CHART_SHOW_TICKER,                         // Sort by the flag displaying a symbol ticker in the upper left corner
   SORT_BY_CHART_SHOW_OHLC,                           // Sort by the flag displaying OHLC values in the upper left corner
   SORT_BY_CHART_SHOW_BID_LINE,                       // Sort by the flag displaying Bid value as a horizontal line on the chart
   SORT_BY_CHART_SHOW_ASK_LINE,                       // Sort by the flag displaying Ask value as a horizontal line on the chart
   SORT_BY_CHART_SHOW_LAST_LINE,                      // Sort by the flag displaying Last value as a horizontal line on the chart
   SORT_BY_CHART_SHOW_PERIOD_SEP,                     // Sort by the flag displaying vertical separators between adjacent periods
   SORT_BY_CHART_SHOW_GRID,                           // Sort by the flag of displaying a grid on the chart
   SORT_BY_CHART_SHOW_VOLUMES,                        // Sort by the mode of displaying volumes on a chart
   SORT_BY_CHART_SHOW_OBJECT_DESCR,                   // Sort by the flag of displaying object text descriptions
   SORT_BY_CHART_VISIBLE_BARS,                        // Sort by the number of bars on a chart that are available for display
   SORT_BY_CHART_WINDOWS_TOTAL,                       // Sort by the total number of chart windows including indicator subwindows
   SORT_BY_CHART_WINDOW_HANDLE,                       // Sort by the chart handle
   SORT_BY_CHART_FIRST_VISIBLE_BAR,                   // Sort by the number of the first visible bar on the chart
   SORT_BY_CHART_WIDTH_IN_BARS,                       // Sort by the width of the chart in bars
   SORT_BY_CHART_WIDTH_IN_PIXELS,                     // Sort by the width of the chart in pixels
   SORT_BY_CHART_COLOR_BACKGROUND,                    // Sort by the color of the chart background
   SORT_BY_CHART_COLOR_FOREGROUND,                    // Sort by color of axes, scale and OHLC line
   SORT_BY_CHART_COLOR_GRID,                          // Sort by grid color
   SORT_BY_CHART_COLOR_VOLUME,                        // Sort by the color of volumes and position opening levels
   SORT_BY_CHART_COLOR_CHART_UP,                      // Sort by the color for the up bar, shadows and body borders of bull candlesticks
   SORT_BY_CHART_COLOR_CHART_DOWN,                    // Sort by the color of down bar, its shadow and border of body of the bullish candlestick
   SORT_BY_CHART_COLOR_CHART_LINE,                    // Sort by the color of the chart line and the Doji candlesticks
   SORT_BY_CHART_COLOR_CANDLE_BULL,                   // Sort by the color of a bullish candlestick body
   SORT_BY_CHART_COLOR_CANDLE_BEAR,                   // Sort by the color of a bearish candlestick body
   SORT_BY_CHART_COLOR_BID,                           // Sort by the color of the Bid price line
   SORT_BY_CHART_COLOR_ASK,                           // Sort by the color of the Ask price line
   SORT_BY_CHART_COLOR_LAST,                          // Sort by the color of the last performed deal's price line (Last)
   SORT_BY_CHART_COLOR_STOP_LEVEL,                    // Sort by the color of stop order levels (Stop Loss and Take Profit)
   SORT_BY_CHART_SHOW_TRADE_LEVELS,                   // Sort by the flag of displaying trading levels on the chart
   SORT_BY_CHART_DRAG_TRADE_LEVELS,                   // Sort by the flag enabling the ability to drag trading levels on a chart using mouse
   SORT_BY_CHART_SHOW_DATE_SCALE,                     // Sort by the flag of displaying the time scale on the chart
   SORT_BY_CHART_SHOW_PRICE_SCALE,                    // Sort by the flag of displaying the price scale on the chart
   SORT_BY_CHART_SHOW_ONE_CLICK,                      // Sort by the flag of displaying the quick trading panel on the chart
   SORT_BY_CHART_IS_MAXIMIZED,                        // Sort by the "Chart window maximized" flag
   SORT_BY_CHART_IS_MINIMIZED,                        // Sort by the "Chart window minimized" flag
   SORT_BY_CHART_IS_DOCKED,                           // Sort by the "Chart window docked" flag
   SORT_BY_CHART_FLOAT_LEFT,                          // Sort by the left coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_FLOAT_TOP,                           // Sort by the upper coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_FLOAT_RIGHT,                         // Sort by the right coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_FLOAT_BOTTOM,                        // Sort by the bottom coordinate of the undocked chart window relative to the virtual screen
   SORT_BY_CHART_YDISTANCE,                           // Sort by the distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   SORT_BY_CHART_HEIGHT_IN_PIXELS,                    // Sort by the height of the chart in pixels
//--- Sort by real properties
   SORT_BY_CHART_SHIFT_SIZE = FIRST_CHART_DBL_PROP,   // Sort by the shift size of the zero bar from the right border in %
   SORT_BY_CHART_FIXED_POSITION,                      // Sort by the chart fixed position from the left border in %
   SORT_BY_CHART_FIXED_MAX,                           // Sort by the fixed chart maximum
   SORT_BY_CHART_FIXED_MIN,                           // Sort by the fixed chart minimum
   SORT_BY_CHART_POINTS_PER_BAR,                      // Sort by the scale value in points per bar
   SORT_BY_CHART_PRICE_MIN,                           // Sort by the chart minimum
   SORT_BY_CHART_PRICE_MAX,                           // Sort by the chart maximum
//--- Sort by string properties
   SORT_BY_CHART_COMMENT = FIRST_CHART_STR_PROP,      // Sort by a comment text on the chart
   SORT_BY_CHART_EXPERT_NAME,                         // Sort by a name of an EA launched on the chart
   SORT_BY_CHART_SCRIPT_NAME,                         // Sort by a name of a script launched on the chart
   SORT_BY_CHART_INDICATOR_NAME,                      // Sort by a name of an indicator launched in the chart window
   SORT_BY_CHART_SYMBOL,                              // Sort by chart symbol
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for handling chart windows                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Chart window integer properties                                  |
//+------------------------------------------------------------------+
enum ENUM_CHART_WINDOW_PROP_INTEGER
  {
   CHART_WINDOW_PROP_ID = 0,                          // Chart ID
   CHART_WINDOW_PROP_WINDOW_NUM,                      // Chart window index
   CHART_WINDOW_PROP_YDISTANCE,                       // Distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   CHART_WINDOW_PROP_HEIGHT_IN_PIXELS,                // Height of the chart in pixels
   //--- for CWndInd
   CHART_WINDOW_PROP_WINDOW_IND_HANDLE,               // Indicator handle in the chart window
   CHART_WINDOW_PROP_WINDOW_IND_INDEX,                // Indicator index in the chart window
  };
#define CHART_WINDOW_PROP_INTEGER_TOTAL (6)           // Total number of integer properties
#define CHART_WINDOW_PROP_INTEGER_SKIP  (0)           // Number of integer DOM properties not used in sorting
//+------------------------------------------------------------------+
//| Chart window real properties                                     |
//+------------------------------------------------------------------+
enum ENUM_CHART_WINDOW_PROP_DOUBLE
  {
   CHART_WINDOW_PROP_PRICE_MIN = CHART_WINDOW_PROP_INTEGER_TOTAL, // Chart minimum
   CHART_WINDOW_PROP_PRICE_MAX,                       // Chart maximum
  };
#define CHART_WINDOW_PROP_DOUBLE_TOTAL  (2)           // Total number of real properties
#define CHART_WINDOW_PROP_DOUBLE_SKIP   (0)           // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| Chart window string properties                                   |
//+------------------------------------------------------------------+
enum ENUM_CHART_WINDOW_PROP_STRING
  {
   CHART_WINDOW_PROP_IND_NAME = (CHART_WINDOW_PROP_INTEGER_TOTAL+CHART_WINDOW_PROP_DOUBLE_TOTAL), // Name of the indicator launched in the window
   CHART_WINDOW_PROP_SYMBOL,                          // Chart symbol
  };
#define CHART_WINDOW_PROP_STRING_TOTAL  (2)           // Total number of string properties
//+------------------------------------------------------------------+
//| Possible criteria of sorting chart windows                       |
//+------------------------------------------------------------------+
#define FIRST_CHART_WINDOW_DBL_PROP  (CHART_WINDOW_PROP_INTEGER_TOTAL-CHART_WINDOW_PROP_INTEGER_SKIP)
#define FIRST_CHART_WINDOW_STR_PROP  (CHART_WINDOW_PROP_INTEGER_TOTAL-CHART_WINDOW_PROP_INTEGER_SKIP+CHART_WINDOW_PROP_DOUBLE_TOTAL-CHART_WINDOW_PROP_DOUBLE_SKIP)
enum ENUM_SORT_CHART_WINDOW_MODE
  {
//--- Sort by integer properties
   SORT_BY_CHART_WINDOW_ID = 0,                       // Sort by chart ID
   SORT_BY_CHART_WINDOW_NUM,                          // Sort by chart window index
   SORT_BY_CHART_WINDOW_YDISTANCE,                    // Sort by the distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   SORT_BY_CHART_WINDOW_HEIGHT_IN_PIXELS,             // Sort by the height of the chart in pixels
   SORT_BY_CHART_WINDOW_IND_HANDLE,                   // Sort by the indicator handle in the chart window
   SORT_BY_CHART_WINDOW_IND_INDEX,                    // Sort by the indicator index in the chart window
//--- Sort by real properties
   SORT_BY_CHART_WINDOW_PRICE_MIN = FIRST_CHART_WINDOW_DBL_PROP,  // Sort by chart window minimum
   SORT_BY_CHART_WINDOW_PRICE_MAX,                    // Sort by chart window maximum
//--- Sort by string properties
   SORT_BY_CHART_WINDOW_IND_NAME = FIRST_CHART_WINDOW_STR_PROP,   // Sort by name of an indicator launched in the window
   SORT_BY_CHART_WINDOW_SYMBOL,                       // Sort by chart symbol
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with mouse                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| The list of possible mouse buttons, Shift and Ctrl keys states   |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_BUTT_KEY_STATE
  {
   MOUSE_BUTT_KEY_STATE_NONE              = 0,        // Nothing is clicked
//--- Mouse buttons
   MOUSE_BUTT_KEY_STATE_LEFT              = 1,        // The left mouse button is clicked
   MOUSE_BUTT_KEY_STATE_RIGHT             = 2,        // The right mouse button is clicked
   MOUSE_BUTT_KEY_STATE_MIDDLE            = 16,       // The middle mouse button is clicked
   MOUSE_BUTT_KEY_STATE_WHELL             = 128,      // Scrolling the mouse wheel
   MOUSE_BUTT_KEY_STATE_X1                = 32,       // The first additional mouse button is clicked
   MOUSE_BUTT_KEY_STATE_X2                = 64,       // The second additional mouse button is clicked
   MOUSE_BUTT_KEY_STATE_LEFT_RIGHT        = 3,        // The left and right mouse buttons clicked
//--- Keyboard keys
   MOUSE_BUTT_KEY_STATE_SHIFT             = 4,        // Shift is being held
   MOUSE_BUTT_KEY_STATE_CTRL              = 8,        // Ctrl is being held
   MOUSE_BUTT_KEY_STATE_CTRL_CHIFT        = 12,       // Ctrl and Shift are being held
//--- Left mouse button combinations
   MOUSE_BUTT_KEY_STATE_LEFT_WHELL        = 129,      // The left mouse button is clicked and the wheel is being scrolled
   MOUSE_BUTT_KEY_STATE_LEFT_SHIFT        = 5,        // The left mouse button is clicked and Shift is being held
   MOUSE_BUTT_KEY_STATE_LEFT_CTRL         = 9,        // The left mouse button is clicked and Ctrl is being held
   MOUSE_BUTT_KEY_STATE_LEFT_CTRL_CHIFT   = 13,       // The left mouse button is clicked, Ctrl and Shift are being held
//--- Right mouse button combinations
   MOUSE_BUTT_KEY_STATE_RIGHT_WHELL       = 130,      // The right mouse button is clicked and the wheel is being scrolled
   MOUSE_BUTT_KEY_STATE_RIGHT_SHIFT       = 6,        // The right mouse button is clicked and Shift is being held
   MOUSE_BUTT_KEY_STATE_RIGHT_CTRL        = 10,       // The right mouse button is clicked and Ctrl is being held
   MOUSE_BUTT_KEY_STATE_RIGHT_CTRL_CHIFT  = 14,       // The right mouse button is clicked, Ctrl and Shift are being held
//--- Middle mouse button combinations
   MOUSE_BUTT_KEY_STATE_MIDDLE_WHEEL      = 144,      // The middle mouse button is clicked and the wheel is being scrolled
   MOUSE_BUTT_KEY_STATE_MIDDLE_SHIFT      = 20,       // The middle mouse button is clicked and Shift is being held
   MOUSE_BUTT_KEY_STATE_MIDDLE_CTRL       = 24,       // The middle mouse button is clicked and Ctrl is being held
   MOUSE_BUTT_KEY_STATE_MIDDLE_CTRL_CHIFT = 28,       // The middle mouse button is clicked, Ctrl and Shift are being held
  };
//+------------------------------------------------------------------+
//| The list of possible mouse states relative to the form           |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_FORM_STATE
  {
   MOUSE_FORM_STATE_NONE = 0,                         // Undefined state
//--- Outside the form
   MOUSE_FORM_STATE_OUTSIDE_FORM_NOT_PRESSED,         // The cursor is outside the form, the mouse buttons are not clicked
   MOUSE_FORM_STATE_OUTSIDE_FORM_PRESSED,             // The cursor is outside the form, any mouse button is clicked
   MOUSE_FORM_STATE_OUTSIDE_FORM_WHEEL,               // The cursor is outside the form, the mouse wheel is being scrolled
//--- Within the form
   MOUSE_FORM_STATE_INSIDE_FORM_NOT_PRESSED,          // The cursor is inside the form, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_FORM_PRESSED,              // The cursor is inside the form, any mouse button is clicked
   MOUSE_FORM_STATE_INSIDE_FORM_WHEEL,                // The cursor is inside the form, the mouse wheel is being scrolled
//--- Within the window header area
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_NOT_PRESSED,   // The cursor is inside the active area, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_PRESSED,       // The cursor is inside the active area,  any mouse button is clicked
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_WHEEL,         // The cursor is inside the active area, the mouse wheel is being scrolled
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_RELEASED,      // The cursor is inside the active area, left mouse button is released
   
//--- Within the window scrolling area to the right
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_NOT_PRESSED,// The cursor is within the window scrolling area to the right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_PRESSED,    // The cursor is within the window scrolling area to the right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_WHEEL,      // The cursor is within the window scrolling area to the right, the mouse wheel is being scrolled
//--- Within the window scrolling area at the bottom
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_NOT_PRESSED,// The cursor is within the window scrolling area at the bottom, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_PRESSED,   // The cursor is within the window scrolling area at the bottom, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_WHEEL,     // The cursor is within the window scrolling area at the bottom, the mouse wheel is being scrolled

//--- Within the window resizing area at the top
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_NOT_PRESSED,  // The cursor is within the window resizing area at the top, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_PRESSED,      // The cursor is within the window resizing area at the top, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_WHEEL,        // The cursor is within the window resizing area at the top, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_AREA_PRESSED,   // The cursor is within the window resizing area at the bottom, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_AREA_WHEEL,     // The cursor is within the window resizing area at the bottom, the mouse wheel is being scrolled
//--- Within the window resizing area to the left
   MOUSE_FORM_STATE_INSIDE_RESIZE_LEFT_AREA_NOT_PRESSED, // The cursor is within the window resizing area to the left, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_LEFT_AREA_PRESSED,     // The cursor is within the window resizing area to the left, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_LEFT_AREA_WHEEL,       // The cursor is within the window resizing area to the left, the mouse wheel is being scrolled
//--- Within the window resizing area to the right
   MOUSE_FORM_STATE_INSIDE_RESIZE_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area to the right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_RIGHT_AREA_PRESSED,    // The cursor is within the window resizing area to the right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_RIGHT_AREA_WHEEL,      // The cursor is within the window resizing area to the right, the mouse wheel is being scrolled
//--- Within the window resizing area to the top-left
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_LEFT_AREA_NOT_PRESSED,   // The cursor is within the window resizing area at the top-left, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_LEFT_AREA_PRESSED,       // The cursor is within the window resizing area at the top-left, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_LEFT_AREA_WHEEL,         // The cursor is within the window resizing area at the top-left, the mouse wheel is being scrolled
//--- Within the window resizing area to the top-right
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_RIGHT_AREA_NOT_PRESSED,  // The cursor is within the window resizing area at the top-right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_RIGHT_AREA_PRESSED,      // The cursor is within the window resizing area at the top-right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_RIGHT_AREA_WHEEL,        // The cursor is within the window resizing area at the top-right, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom left
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_LEFT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-left, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_LEFT_AREA_PRESSED,    // The cursor is within the window resizing area at the bottom-left, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_LEFT_AREA_WHEEL,      // The cursor is within the window resizing area at the bottom-left, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom-right
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_PRESSED,   // The cursor is within the window resizing area at the bottom-right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_WHEEL,     // The cursor is within the window resizing area at the bottom-right, the mouse wheel is being scrolled
   
//--- Within the control area
   MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_NOT_PRESSED,  // The cursor is within the control area, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_PRESSED,      // The cursor is within the control area, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_WHEEL,        // The cursor is within the control area, the mouse wheel is being scrolled
  };
//+------------------------------------------------------------------+
//| List of possible mouse events                                    |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_EVENT
  {
   MOUSE_EVENT_NO_EVENT = CHART_OBJ_EVENTS_NEXT_CODE, // No event
//---
   MOUSE_EVENT_OUTSIDE_FORM_NOT_PRESSED,              // The cursor is outside the form, the mouse buttons are not clicked
   MOUSE_EVENT_OUTSIDE_FORM_PRESSED,                  // The cursor is outside the form, the mouse button (any) is clicked
   MOUSE_EVENT_OUTSIDE_FORM_WHEEL,                    // The cursor is outside the form, the mouse wheel is being scrolled
//--- Within the form
   MOUSE_EVENT_INSIDE_FORM_NOT_PRESSED,               // The cursor is inside the form, no mouse buttons are clicked
   MOUSE_EVENT_INSIDE_FORM_PRESSED,                   // The cursor is inside the form, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_FORM_WHEEL,                     // The cursor is inside the form, the mouse wheel is being scrolled
//--- Within the window active area
   MOUSE_EVENT_INSIDE_ACTIVE_AREA_NOT_PRESSED,        // The cursor is inside the active area, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_ACTIVE_AREA_PRESSED,            // The cursor is inside the active area, any mouse button is clicked
   MOUSE_EVENT_INSIDE_ACTIVE_AREA_WHEEL,              // The cursor is inside the active area, the mouse wheel is being scrolled
   MOUSE_EVENT_INSIDE_ACTIVE_AREA_RELEASED,           // The cursor is inside the active area, left mouse button is released
//--- Within the window scrolling area to the right
   MOUSE_EVENT_INSIDE_SCROLL_AREA_RIGHT_NOT_PRESSED,  // The cursor is within the window scrolling area to the right, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_SCROLL_AREA_RIGHT_PRESSED,      // The cursor is within the window scrolling area to the right, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_SCROLL_AREA_RIGHT_WHEEL,        // The cursor is within the window scrolling area to the right, the mouse wheel is being scrolled
//--- Within the window scrolling area at the bottom
   MOUSE_EVENT_INSIDE_SCROLL_AREA_BOTTOM_NOT_PRESSED, // The cursor is within the window scrolling area at the bottom, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_SCROLL_AREA_BOTTOM_PRESSED,     // The cursor is within the window scrolling area at the bottom, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_SCROLL_AREA_BOTTOM_WHEEL,       // The cursor is within the window scrolling area at the bottom, the mouse wheel is being scrolled

//--- Within the window resizing area at the top
   MOUSE_EVENT_INSIDE_RESIZE_TOP_AREA_NOT_PRESSED,    // The cursor is within the window resizing area at the top, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_TOP_AREA_PRESSED,        // The cursor is within the window resizing area at the top, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_TOP_AREA_WHEEL,          // The cursor is within the window resizing area at the top, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_AREA_NOT_PRESSED, // The cursor is within the window resizing area at the bottom, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_AREA_PRESSED,     // The cursor is within the window resizing area at the bottom, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_AREA_WHEEL,       // The cursor is within the window resizing area at the bottom, the mouse wheel is being scrolled
//--- Within the window resizing area to the left
   MOUSE_EVENT_INSIDE_RESIZE_LEFT_AREA_NOT_PRESSED,   // The cursor is within the window resizing area to the left, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_LEFT_AREA_PRESSED,       // The cursor is within the window resizing area to the left, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_LEFT_AREA_WHEEL,         // The cursor is within the window resizing area to the left, the mouse wheel is being scrolled
//--- Within the window resizing area to the right
   MOUSE_EVENT_INSIDE_RESIZE_RIGHT_AREA_NOT_PRESSED,  // The cursor is within the window resizing area to the right, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_RIGHT_AREA_PRESSED,      // The cursor is within the window resizing area to the right, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_RIGHT_AREA_WHEEL,        // The cursor is within the window resizing area to the right, the mouse wheel is being scrolled
//--- Within the window resizing area to the top-left
   MOUSE_EVENT_INSIDE_RESIZE_TOP_LEFT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the top-left, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_TOP_LEFT_AREA_PRESSED,   // The cursor is within the window resizing area at the top-left, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_TOP_LEFT_AREA_WHEEL,     // The cursor is within the window resizing area at the top-left, the mouse wheel is being scrolled
//--- Within the window resizing area to the top-right
   MOUSE_EVENT_INSIDE_RESIZE_TOP_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the top-right, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_TOP_RIGHT_AREA_PRESSED,  // The cursor is within the window resizing area at the top-right, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_TOP_RIGHT_AREA_WHEEL,    // The cursor is within the window resizing area at the top-right, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom left
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_LEFT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-left, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_LEFT_AREA_PRESSED,// The cursor is within the window resizing area at the bottom-left, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_LEFT_AREA_WHEEL,  // The cursor is within the window resizing area at the bottom-left, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom-right
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-right, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_PRESSED,// The cursor is within the window resizing area at the bottom-right, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_WHEEL, // The cursor is within the window resizing area at the bottom-right, the mouse wheel is being scrolled
//--- Within the control area
   MOUSE_EVENT_INSIDE_CONTROL_AREA_NOT_PRESSED,       // The cursor is within the control area, the mouse buttons are not clicked
   MOUSE_EVENT_INSIDE_CONTROL_AREA_PRESSED,           // The cursor is within the control area, the mouse button (any) is clicked
   MOUSE_EVENT_INSIDE_CONTROL_AREA_WHEEL,             // The cursor is within the control area, the mouse wheel is being scrolled
  };
#define MOUSE_EVENT_NEXT_CODE  (MOUSE_EVENT_INSIDE_CONTROL_AREA_WHEEL+1)   // The code of the next event after the last mouse event code
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for handling graphical elements                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of possible graphical object events                         |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_EVENT
  {
   GRAPH_OBJ_EVENT_NO_EVENT = MOUSE_EVENT_NEXT_CODE,  // No event
   GRAPH_OBJ_EVENT_CREATE,                            // "Creating a new graphical object" event
   GRAPH_OBJ_EVENT_CHANGE,                            // "Changing graphical object properties" event
   GRAPH_OBJ_EVENT_RENAME,                            // "Renaming graphical object" event
   GRAPH_OBJ_EVENT_DELETE,                            // "Removing graphical object" event
   GRAPH_OBJ_EVENT_DEL_CHART,                         // "Removing a graphical object together with the chart window" event
  };
#define GRAPH_OBJ_EVENTS_NEXT_CODE  (GRAPH_OBJ_EVENT_DEL_CHART+1) // The code of the next event after the last graphical object event code
//+------------------------------------------------------------------+
//| List of anchoring methods                                        |
//| (horizontal and vertical text alignment)                         |
//+------------------------------------------------------------------+
enum ENUM_FRAME_ANCHOR
  {
   FRAME_ANCHOR_LEFT_TOP       =  0,                  // Frame anchor point at the upper left corner of the bounding rectangle
   FRAME_ANCHOR_CENTER_TOP     =  1,                  // Frame anchor point at the top center side of the bounding rectangle
   FRAME_ANCHOR_RIGHT_TOP      =  2,                  // Frame anchor point at the upper right corner of the bounding rectangle
   FRAME_ANCHOR_LEFT_CENTER    =  4,                  // Frame anchor point at the center of the left side of the bounding rectangle
   FRAME_ANCHOR_CENTER         =  5,                  // Frame anchor point at the center of the bounding rectangle
   FRAME_ANCHOR_RIGHT_CENTER   =  6,                  // Frame anchor point at the center of the right side of the bounding rectangle
   FRAME_ANCHOR_LEFT_BOTTOM    =  8,                  // Frame anchor point at the lower left corner of the bounding rectangle
   FRAME_ANCHOR_CENTER_BOTTOM  =  9,                  // Frame anchor point at the bottom center side of the bounding rectangle
   FRAME_ANCHOR_RIGHT_BOTTOM   =  10,                 // Frame anchor point at the lower right corner of the bounding rectangle
  };
//+------------------------------------------------------------------+
//| List of graphical objects affiliations                           |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_BELONG
  {
   GRAPH_OBJ_BELONG_PROGRAM,                          // Graphical object belongs to a program
   GRAPH_OBJ_BELONG_NO_PROGRAM,                       // Graphical object does not belong to a program
  };
//+------------------------------------------------------------------+
//| The list of graphical element types                              |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_ELEMENT_TYPE
  {
   GRAPH_ELEMENT_TYPE_STANDARD,                       // Standard graphical object
   GRAPH_ELEMENT_TYPE_STANDARD_EXTENDED,              // Extended standard graphical object
   GRAPH_ELEMENT_TYPE_SHADOW_OBJ,                     // Shadow object
   GRAPH_ELEMENT_TYPE_ELEMENT,                        // Element
   GRAPH_ELEMENT_TYPE_FORM,                           // Form
   GRAPH_ELEMENT_TYPE_WINDOW,                         // Window
   //--- WinForms
   GRAPH_ELEMENT_TYPE_WF_UNDERLAY,                    // Panel object underlay
   GRAPH_ELEMENT_TYPE_WF_BASE,                        // Windows Forms Base
   //--- 'Container' object types are to be set below
   GRAPH_ELEMENT_TYPE_WF_CONTAINER,                   // Windows Forms container base object
   GRAPH_ELEMENT_TYPE_WF_PANEL,                       // Windows Forms Panel
   GRAPH_ELEMENT_TYPE_WF_GROUPBOX,                    // Windows Forms GroupBox
   GRAPH_ELEMENT_TYPE_WF_TAB_CONTROL,                 // Windows Forms TabControl
   GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER,             // Windows Forms SplitContainer
   //--- 'Standard control' object types are to be set below
   GRAPH_ELEMENT_TYPE_WF_COMMON_BASE,                 // Windows Forms base standard control
   GRAPH_ELEMENT_TYPE_WF_LABEL,                       // Windows Forms Label
   GRAPH_ELEMENT_TYPE_WF_BUTTON,                      // Windows Forms Button
   GRAPH_ELEMENT_TYPE_WF_CHECKBOX,                    // Windows Forms CheckBox
   GRAPH_ELEMENT_TYPE_WF_RADIOBUTTON,                 // Windows Forms RadioButton
   GRAPH_ELEMENT_TYPE_WF_ELEMENTS_LIST_BOX,           // Base list object of Windows Forms elements
   GRAPH_ELEMENT_TYPE_WF_LIST_BOX,                    // Windows Forms ListBox
   GRAPH_ELEMENT_TYPE_WF_CHECKED_LIST_BOX,            // Windows Forms CheckedListBox
   GRAPH_ELEMENT_TYPE_WF_BUTTON_LIST_BOX,             // Windows Forms ButtonListBox
   GRAPH_ELEMENT_TYPE_WF_TOOLTIP,                     // Windows Forms ToolTip
   GRAPH_ELEMENT_TYPE_WF_PROGRESS_BAR,                // Windows Forms ProgressBar
   //--- Auxiliary elements of WinForms objects
   GRAPH_ELEMENT_TYPE_WF_LIST_BOX_ITEM,               // Windows Forms ListBoxItem
   GRAPH_ELEMENT_TYPE_WF_TAB_HEADER,                  // Windows Forms TabHeader
   GRAPH_ELEMENT_TYPE_WF_TAB_FIELD,                   // Windows Forms TabField
   GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER_PANEL,       // Windows Forms SplitContainerPanel
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON,                // Windows Forms ArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_UP,             // Windows Forms UpArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_DOWN,           // Windows Forms DownArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_LEFT,           // Windows Forms LeftArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_RIGHT,          // Windows Forms RightArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_UD_BOX,        // Windows Forms UpDownArrowButtonsBox
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_LR_BOX,        // Windows Forms LeftRightArrowButtonsBox
   GRAPH_ELEMENT_TYPE_WF_SPLITTER,                    // Windows Forms Splitter
   GRAPH_ELEMENT_TYPE_WF_HINT_BASE,                   // Windows Forms HintBase
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_LEFT,              // Windows Forms HintMoveLeft
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_RIGHT,             // Windows Forms HintMoveRight
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_UP,                // Windows Forms HintMoveUp
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_DOWN,              // Windows Forms HintMoveDown
   GRAPH_ELEMENT_TYPE_WF_BAR_PROGRESS_BAR,            // Windows Forms BarProgressBar
   GRAPH_ELEMENT_TYPE_WF_GLARE_OBJ,                   // Glare object
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_THUMB,            // Windows Forms ScrollBarThumb
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR,                  // Windows Forms ScrollBar
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_HORIZONTAL,       // Windows Forms ScrollBarHorizontal
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_VERTICAL,         // Windows Forms ScrollBarVertical
  };
//+------------------------------------------------------------------+
//| Graphical object species                                         |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_SPECIES
  {
   GRAPH_OBJ_SPECIES_LINES,                             // Lines
   GRAPH_OBJ_SPECIES_CHANNELS,                          // Channels
   GRAPH_OBJ_SPECIES_GANN,                              // Gann
   GRAPH_OBJ_SPECIES_FIBO,                              // Fibo
   GRAPH_OBJ_SPECIES_ELLIOTT,                           // Elliott
   GRAPH_OBJ_SPECIES_SHAPES,                            // Shapes
   GRAPH_OBJ_SPECIES_ARROWS,                            // Arrows
   GRAPH_OBJ_SPECIES_GRAPHICAL,                         // Graphical objects
  };
//+------------------------------------------------------------------+
//| Integer properties of a standard graphical object                |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_PROP_INTEGER
  {
   //--- Additional properties
   GRAPH_OBJ_PROP_ID = 0,                             // Object ID
   GRAPH_OBJ_PROP_BASE_ID,                            // Base object ID
   GRAPH_OBJ_PROP_TYPE,                               // Graphical object type (ENUM_OBJECT)
   GRAPH_OBJ_PROP_ELEMENT_TYPE,                       // Graphical element type (ENUM_GRAPH_ELEMENT_TYPE)
   GRAPH_OBJ_PROP_SPECIES,                            // Graphical object species (ENUM_GRAPH_OBJ_SPECIES)
   GRAPH_OBJ_PROP_BELONG,                             // Graphical object affiliation
   GRAPH_OBJ_PROP_CHART_ID,                           // Chart ID
   GRAPH_OBJ_PROP_WND_NUM,                            // Chart subwindow index
   GRAPH_OBJ_PROP_NUM,                                // Object index in the list
   GRAPH_OBJ_PROP_CHANGE_HISTORY,                     // Flag of storing the change history
   GRAPH_OBJ_PROP_GROUP,                              // Group of objects the graphical object belongs to
   //--- Common properties of all graphical objects
   GRAPH_OBJ_PROP_CREATETIME,                         // Object creation time
   GRAPH_OBJ_PROP_TIMEFRAMES,                         // Object visibility on timeframes
   GRAPH_OBJ_PROP_BACK,                               // Background object
   GRAPH_OBJ_PROP_ZORDER,                             // Priority of a graphical object for receiving the event of clicking on a chart
   GRAPH_OBJ_PROP_HIDDEN,                             // Disable displaying the name of a graphical object in the terminal object list
   GRAPH_OBJ_PROP_SELECTED,                           // Object selection
   GRAPH_OBJ_PROP_SELECTABLE,                         // Object availability
//--- Properties belonging to different graphical objects
   GRAPH_OBJ_PROP_TIME,                               // Time coordinate
   GRAPH_OBJ_PROP_COLOR,                              // Color
   GRAPH_OBJ_PROP_STYLE,                              // Style
   GRAPH_OBJ_PROP_WIDTH,                              // Line width
   GRAPH_OBJ_PROP_FILL,                               // Object color filling
   GRAPH_OBJ_PROP_READONLY,                           // Ability to edit text in the Edit object
   GRAPH_OBJ_PROP_LEVELS,                             // Number of levels
   GRAPH_OBJ_PROP_LEVELCOLOR,                         // Level line color
   GRAPH_OBJ_PROP_LEVELSTYLE,                         // Level line style
   GRAPH_OBJ_PROP_LEVELWIDTH,                         // Level line width
   GRAPH_OBJ_PROP_ALIGN,                              // Horizontal text alignment in the Edit object (OBJ_EDIT)
   GRAPH_OBJ_PROP_FONTSIZE,                           // Font size
   GRAPH_OBJ_PROP_RAY_LEFT,                           // Ray goes to the left
   GRAPH_OBJ_PROP_RAY_RIGHT,                          // Ray goes to the right
   GRAPH_OBJ_PROP_RAY,                                // Vertical line goes through all windows of a chart
   GRAPH_OBJ_PROP_ELLIPSE,                            // Display the full ellipse of the Fibonacci Arc object
   GRAPH_OBJ_PROP_ARROWCODE,                          // Arrow code for the "Arrow" object
   GRAPH_OBJ_PROP_ANCHOR,                             // Position of the binding point of the graphical object
   GRAPH_OBJ_PROP_XDISTANCE,                          // Distance from the base corner along the X axis in pixels
   GRAPH_OBJ_PROP_YDISTANCE,                          // Distance from the base corner along the Y axis in pixels
   GRAPH_OBJ_PROP_DIRECTION,                          // Gann object trend
   GRAPH_OBJ_PROP_DEGREE,                             // Elliott wave marking level
   GRAPH_OBJ_PROP_DRAWLINES,                          // Display lines for Elliott wave marking
   GRAPH_OBJ_PROP_STATE,                              // Button state (pressed/released)
   GRAPH_OBJ_PROP_CHART_OBJ_CHART_ID,                 // Chart object ID (OBJ_CHART).
   GRAPH_OBJ_PROP_CHART_OBJ_PERIOD,                   // Chart object period
   GRAPH_OBJ_PROP_CHART_OBJ_DATE_SCALE,               // Time scale display flag for the Chart object
   GRAPH_OBJ_PROP_CHART_OBJ_PRICE_SCALE,              // Price scale display flag for the Chart object
   GRAPH_OBJ_PROP_CHART_OBJ_CHART_SCALE,              // Chart object scale
   GRAPH_OBJ_PROP_XSIZE,                              // Object width along the X axis in pixels.
   GRAPH_OBJ_PROP_YSIZE,                              // Object height along the Y axis in pixels.
   GRAPH_OBJ_PROP_XOFFSET,                            // X coordinate of the upper-left corner of the visibility area.
   GRAPH_OBJ_PROP_YOFFSET,                            // Y coordinate of the upper-left corner of the visibility area.
   GRAPH_OBJ_PROP_BGCOLOR,                            // Background color for OBJ_EDIT, OBJ_BUTTON, OBJ_RECTANGLE_LABEL
   GRAPH_OBJ_PROP_CORNER,                             // Chart corner for binding a graphical object
   GRAPH_OBJ_PROP_BORDER_TYPE,                        // Border type for "Rectangle border"
   GRAPH_OBJ_PROP_BORDER_COLOR,                       // Border color for OBJ_EDIT and OBJ_BUTTON
  };
#define GRAPH_OBJ_PROP_INTEGER_TOTAL (55)             // Total number of integer properties
#define GRAPH_OBJ_PROP_INTEGER_SKIP  (0)              // Number of integer properties not used in sorting
//+------------------------------------------------------------------+
//| Real properties of a standard graphical object                   |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_PROP_DOUBLE
  {
   GRAPH_OBJ_PROP_PRICE = GRAPH_OBJ_PROP_INTEGER_TOTAL,// Price coordinate
   GRAPH_OBJ_PROP_LEVELVALUE,                         // Level value
   GRAPH_OBJ_PROP_SCALE,                              // Scale (property of Gann objects and Fibonacci Arcs objects)
   GRAPH_OBJ_PROP_ANGLE,                              // Angle
   GRAPH_OBJ_PROP_DEVIATION,                          // Deviation of the standard deviation channel
  };
#define GRAPH_OBJ_PROP_DOUBLE_TOTAL  (5)              // Total number of real properties
#define GRAPH_OBJ_PROP_DOUBLE_SKIP   (0)              // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| String properties of a standard graphical object                 |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_PROP_STRING
  {
   GRAPH_OBJ_PROP_NAME = (GRAPH_OBJ_PROP_INTEGER_TOTAL+GRAPH_OBJ_PROP_DOUBLE_TOTAL), // Object name
   GRAPH_OBJ_PROP_BASE_NAME,                          // Base object name
   GRAPH_OBJ_PROP_TEXT,                               // Object description (text contained in the object)
   GRAPH_OBJ_PROP_TOOLTIP,                            // Tooltip text
   GRAPH_OBJ_PROP_LEVELTEXT,                          // Level description
   GRAPH_OBJ_PROP_FONT,                               // Font
   GRAPH_OBJ_PROP_BMPFILE,                            // BMP file name for the "Bitmap Level" object
   GRAPH_OBJ_PROP_CHART_OBJ_SYMBOL,                   // Symbol for the Chart object 
  };
#define GRAPH_OBJ_PROP_STRING_TOTAL  (8)              // Total number of string properties
//+------------------------------------------------------------------+
//| Possible sorting criteria of graphical objects                   |
//+------------------------------------------------------------------+
#define FIRST_GRAPH_OBJ_DBL_PROP  (GRAPH_OBJ_PROP_INTEGER_TOTAL-GRAPH_OBJ_PROP_INTEGER_SKIP)
#define FIRST_GRAPH_OBJ_STR_PROP  (GRAPH_OBJ_PROP_INTEGER_TOTAL-GRAPH_OBJ_PROP_INTEGER_SKIP+GRAPH_OBJ_PROP_DOUBLE_TOTAL-GRAPH_OBJ_PROP_DOUBLE_SKIP)
enum ENUM_SORT_GRAPH_OBJ_MODE
  {
//--- Sort by integer properties
   SORT_BY_GRAPH_OBJ_ID = 0,                          // Sort by object ID
   SORT_BY_GRAPH_OBJ_BASE_ID,                         // Sort by base object ID
   SORT_BY_GRAPH_OBJ_TYPE,                            // Sort by object type
   SORT_BY_GRAPH_OBJ_ELEMENT_TYPE,                    // Sort by graphical element type
   SORT_BY_GRAPH_OBJ_SPECIES,                         // Sort by a graphical object species
   SORT_BY_GRAPH_OBJ_BELONG,                          // Sort by a graphical element affiliation
   SORT_BY_GRAPH_OBJ_CHART_ID,                        // Sort by chart ID
   SORT_BY_GRAPH_OBJ_WND_NUM,                         // Sort by chart subwindow index
   SORT_BY_GRAPH_OBJ_NUM,                             // Sort by object index in the list
   SORT_BY_GRAPH_OBJ_CHANGE_HISTORY,                  // Sort by the flag of storing the change history
   SORT_BY_GRAPH_OBJ_GROUP,                           // Sort by the group of objects the graphical object belongs to
   SORT_BY_GRAPH_OBJ_CREATETIME,                      // Sort by object creation time
   SORT_BY_GRAPH_OBJ_TIMEFRAMES,                      // Sort by object visibility on timeframes
   SORT_BY_GRAPH_OBJ_BACK,                            // Sort by the "Background object" property
   SORT_BY_GRAPH_OBJ_ZORDER,                          // Sort by the priority of a graphical object for receiving the event of clicking on a chart
   SORT_BY_GRAPH_OBJ_HIDDEN,                          // Sort by a disabling display of the name of a graphical object in the terminal object list
   SORT_BY_GRAPH_OBJ_SELECTED,                        // Sort by the "Object selection" property
   SORT_BY_GRAPH_OBJ_SELECTABLE,                      // Sort by the "Object availability" property
   SORT_BY_GRAPH_OBJ_TIME,                            // Sort by time coordinate
   SORT_BY_GRAPH_OBJ_COLOR,                           // Sort by color
   SORT_BY_GRAPH_OBJ_STYLE,                           // Sort by style
   SORT_BY_GRAPH_OBJ_WIDTH,                           // Sort by line width
   SORT_BY_GRAPH_OBJ_FILL,                            // Sort by the "Object color filling" property
   SORT_BY_GRAPH_OBJ_READONLY,                        // Sort by the ability to edit text in the Edit object
   SORT_BY_GRAPH_OBJ_LEVELS,                          // Sort by number of levels
   SORT_BY_GRAPH_OBJ_LEVELCOLOR,                      // Sort by line level color
   SORT_BY_GRAPH_OBJ_LEVELSTYLE,                      // Sort by line level style
   SORT_BY_GRAPH_OBJ_LEVELWIDTH,                      // Sort by line level width
   SORT_BY_GRAPH_OBJ_ALIGN,                           // Sort by the "Horizontal text alignment in the Entry field" property
   SORT_BY_GRAPH_OBJ_FONTSIZE,                        // Sort by font size
   SORT_BY_GRAPH_OBJ_RAY_LEFT,                        // Sort by "Ray goes to the left" property
   SORT_BY_GRAPH_OBJ_RAY_RIGHT,                       // Sort by "Ray goes to the right" property
   SORT_BY_GRAPH_OBJ_RAY,                             // Sort by the "Vertical line goes through all windows of a chart" property
   SORT_BY_GRAPH_OBJ_ELLIPSE,                         // Sort by the "Display the full ellipse of the Fibonacci Arc object" property
   SORT_BY_GRAPH_OBJ_ARROWCODE,                       // Sort by an arrow code for the Arrow object
   SORT_BY_GRAPH_OBJ_ANCHOR,                          // Sort by the position of a binding point of a graphical object
   SORT_BY_GRAPH_OBJ_XDISTANCE,                       // Sort by a distance from the base corner along the X axis in pixels
   SORT_BY_GRAPH_OBJ_YDISTANCE,                       // Sort by a distance from the base corner along the Y axis in pixels
   SORT_BY_GRAPH_OBJ_DIRECTION,                       // Sort by the "Gann object trend" property
   SORT_BY_GRAPH_OBJ_DEGREE,                          // Sort by the "Elliott wave marking level" property
   SORT_BY_GRAPH_OBJ_DRAWLINES,                       // Sort by the "Display lines for Elliott wave marking" property
   SORT_BY_GRAPH_OBJ_STATE,                           // Sort by button state (pressed/released)
   SORT_BY_GRAPH_OBJ_OBJ_CHART_ID,                    // Sort by Chart object ID
   SORT_BY_GRAPH_OBJ_CHART_OBJ_PERIOD,                // Sort by Chart object period
   SORT_BY_GRAPH_OBJ_CHART_OBJ_DATE_SCALE,            // Sort by time scale display flag for the Chart object
   SORT_BY_GRAPH_OBJ_CHART_OBJ_PRICE_SCALE,           // Sort by price scale display flag for the Chart object
   SORT_BY_GRAPH_OBJ_CHART_OBJ_CHART_SCALE,           // Sort by Chart object scale
   SORT_BY_GRAPH_OBJ_XSIZE,                           // Sort by Object width along the X axis in pixels
   SORT_BY_GRAPH_OBJ_YSIZE,                           // Sort by object height along the Y axis in pixels
   SORT_BY_GRAPH_OBJ_XOFFSET,                         // Sort by X coordinate of the upper-left corner of the visibility area
   SORT_BY_GRAPH_OBJ_YOFFSET,                         // Sort by Y coordinate of the upper-left corner of the visibility area
   SORT_BY_GRAPH_OBJ_BGCOLOR,                         // Sort by background color for OBJ_EDIT, OBJ_BUTTON and OBJ_RECTANGLE_LABEL
   SORT_BY_GRAPH_OBJ_CORNER,                          // Sort by chart corner for binding a graphical object
   SORT_BY_GRAPH_OBJ_BORDER_TYPE,                     // Sort by border type for the "Rectangle border" object
   SORT_BY_GRAPH_OBJ_BORDER_COLOR,                    // Sort by frame color for the OBJ_EDIT and OBJ_BUTTON objects
//--- Sort by real properties
   SORT_BY_GRAPH_OBJ_PRICE = FIRST_GRAPH_OBJ_DBL_PROP,// Sort by price coordinate
   SORT_BY_GRAPH_OBJ_LEVELVALUE,                      // Sort by level value
   SORT_BY_GRAPH_OBJ_SCALE,                           // Sort by scale (property of Gann objects and Fibonacci Arcs objects)
   SORT_BY_GRAPH_OBJ_ANGLE,                           // Sort by angle
   SORT_BY_GRAPH_OBJ_DEVIATION,                       // Sort by a deviation of the standard deviation channel
//--- Sort by string properties
   SORT_BY_GRAPH_OBJ_NAME = FIRST_GRAPH_OBJ_STR_PROP, // Sort by object name
   SORT_BY_GRAPH_OBJ_BASE_NAME,                       // Sort by base object name
   SORT_BY_GRAPH_OBJ_TEXT,                            // Sort by object description
   SORT_BY_GRAPH_OBJ_TOOLTIP,                         // Sort by tooltip text
   SORT_BY_GRAPH_OBJ_LEVELTEXT,                       // Sort by level description
   SORT_BY_GRAPH_OBJ_FONT,                            // Sort by font
   SORT_BY_GRAPH_OBJ_BMPFILE,                         // Sort by BMP file name for the "Bitmap Level" object
   SORT_BY_GRAPH_OBJ_CHART_OBJ_SYMBOL,                // Sort by Chart object period symbol 
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of possible WinForms control events                         |
//+------------------------------------------------------------------+
enum ENUM_WF_CONTROL_EVENT
  {
   WF_CONTROL_EVENT_NO_EVENT = GRAPH_OBJ_EVENTS_NEXT_CODE,// No event
   WF_CONTROL_EVENT_CLICK,                            // "Click on the control" event
   WF_CONTROL_EVENT_CLICK_CANCEL,                     // "Canceling the click on the control" event
   WF_CONTROL_EVENT_MOVING,                           // "Control relocation" event
   WF_CONTROL_EVENT_STOP_MOVING,                      // "Control relocation stop" event
   WF_CONTROL_EVENT_TAB_SELECT,                       // "TabControl tab selection" event
   WF_CONTROL_EVENT_CLICK_SCROLL_LEFT,                // "Clicking the control left button" event
   WF_CONTROL_EVENT_CLICK_SCROLL_RIGHT,               // "Clicking the control right button" event
   WF_CONTROL_EVENT_CLICK_SCROLL_UP,                  // "Clicking the control up button" event
   WF_CONTROL_EVENT_CLICK_SCROLL_DOWN,                // "Clicking the control down button" event
  };
#define WF_CONTROL_EVENTS_NEXT_CODE (WF_CONTROL_EVENT_CLICK_SCROLL_DOWN+1)  // The code of the next event after the last graphical element event code
//+------------------------------------------------------------------+
//| Mode of automatic interface element resizing                     |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_AUTO_SIZE_MODE
  {
   CANV_ELEMENT_AUTO_SIZE_MODE_GROW,                  // Increase only
   CANV_ELEMENT_AUTO_SIZE_MODE_GROW_SHRINK,           // Increase and decrease
  };
//+------------------------------------------------------------------+
//| Control borders bound to the container                           |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_DOCK_MODE
  {
   CANV_ELEMENT_DOCK_MODE_NONE,                       // Attached to the specified coordinates, size does not change
   CANV_ELEMENT_DOCK_MODE_TOP,                        // Attaching to the top and stretching along the container width
   CANV_ELEMENT_DOCK_MODE_BOTTOM,                     // Attaching to the bottom and stretching along the container width
   CANV_ELEMENT_DOCK_MODE_LEFT,                       // Attaching to the left and stretching along the container height
   CANV_ELEMENT_DOCK_MODE_RIGHT,                      // Attaching to the right and stretching along the container height
   CANV_ELEMENT_DOCK_MODE_FILL,                       // Stretching along the entire container width and height
  };
//+------------------------------------------------------------------+
//| Control flag status                                              |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_CHEK_STATE
  {
   CANV_ELEMENT_CHEK_STATE_UNCHECKED,                 // Unchecked
   CANV_ELEMENT_CHEK_STATE_CHECKED,                   // Checked
   CANV_ELEMENT_CHEK_STATE_INDETERMINATE,             // Undefined
  };
//+------------------------------------------------------------------+
//| Location of an object inside a control                           |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_ALIGNMENT
  {
   CANV_ELEMENT_ALIGNMENT_TOP,                        // Top
   CANV_ELEMENT_ALIGNMENT_BOTTOM,                     // Bottom
   CANV_ELEMENT_ALIGNMENT_LEFT,                       // Left
   CANV_ELEMENT_ALIGNMENT_RIGHT,                      // Right
  };
//+------------------------------------------------------------------+
//| Tab size setting mode                                            |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_TAB_SIZE_MODE
  {
   CANV_ELEMENT_TAB_SIZE_MODE_NORMAL,                 // By tab header width
   CANV_ELEMENT_TAB_SIZE_MODE_FIXED,                  // Fixed size
   CANV_ELEMENT_TAB_SIZE_MODE_FILL,                   // By TabControl width
  };
//+------------------------------------------------------------------+
//| Panel index in Split Container,                                  |
//| which saves the size when the container size is changed          |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL
  {
   CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL_NONE,     // None
   CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL_1,        // Panel1
   CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL_2,        // Panel2
  };
//+------------------------------------------------------------------+
//| Separator location in Split Container                            |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_SPLITTER_ORIENTATION
  {
   CANV_ELEMENT_SPLITTER_ORIENTATION_VERTICAL,        // Vertical
   CANV_ELEMENT_SPLITTER_ORIENTATION_HORISONTAL,      // Horizontal
  };
//+------------------------------------------------------------------+
//| The list of predefined icons                                     |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_TOOLTIP_ICON
  {
   CANV_ELEMENT_TOOLTIP_ICON_NONE,                    // None
   CANV_ELEMENT_TOOLTIP_ICON_INFO,                    // Info
   CANV_ELEMENT_TOOLTIP_ICON_WARNING,                 // Warning
   CANV_ELEMENT_TOOLTIP_ICON_ERROR,                   // Error
   CANV_ELEMENT_TOOLTIP_ICON_USER,                    // User
  };
//+------------------------------------------------------------------+
//| List of control display states                                   |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_DISPLAY_STATE
  {
   CANV_ELEMENT_DISPLAY_STATE_NORMAL,                 // Normal
   CANV_ELEMENT_DISPLAY_STATE_WAITING_FADE_IN,        // Wait for fading in
   CANV_ELEMENT_DISPLAY_STATE_PROCESS_FADE_IN,        // Fading in
   CANV_ELEMENT_DISPLAY_STATE_COMPLETED_FADE_IN,      // Fading in end
   CANV_ELEMENT_DISPLAY_STATE_WAITING_FADE_OUT,       // Wait for fading out
   CANV_ELEMENT_DISPLAY_STATE_PROCESS_FADE_OUT,       // Fading out
   CANV_ELEMENT_DISPLAY_STATE_COMPLETED_FADE_OUT,     // Fading out end
   CANV_ELEMENT_DISPLAY_STATE_COMPLETED,              // Complete processing
  };
//+------------------------------------------------------------------+
//| List of ProgressBar element styles                               |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROGRESS_BAR_STYLE
  {
   CANV_ELEMENT_PROGRESS_BAR_STYLE_BLOCKS,            // Segmented blocks
   CANV_ELEMENT_PROGRESS_BAR_STYLE_CONTINUOUS,        // Continuous bar
   CANV_ELEMENT_PROGRESS_BAR_STYLE_MARQUEE,           // Continuous scrolling
  };
//+------------------------------------------------------------------+
//| List of visual effect styles                                     |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_VISUAL_EFF_STYLE
  {
   CANV_ELEMENT_VISUAL_EFF_STYLE_RECTANGLE,           // Rectangle
   CANV_ELEMENT_VISUAL_EFF_STYLE_PARALLELOGRAMM,      // Parallelogram
  };
//+------------------------------------------------------------------+
//| Integer properties of the graphical element on the canvas        |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROP_INTEGER
  {
   CANV_ELEMENT_PROP_ID = 0,                          // Element ID
   CANV_ELEMENT_PROP_TYPE,                            // Graphical element type
   CANV_ELEMENT_PROP_BELONG,                          // Graphical element affiliation
   CANV_ELEMENT_PROP_NUM,                             // Element index in the list
   CANV_ELEMENT_PROP_CHART_ID,                        // Chart ID
   CANV_ELEMENT_PROP_WND_NUM,                         // Chart subwindow index
   CANV_ELEMENT_PROP_COORD_X,                         // Element X coordinate on the chart
   CANV_ELEMENT_PROP_COORD_Y,                         // Element Y coordinate on the chart
   CANV_ELEMENT_PROP_WIDTH,                           // Element width
   CANV_ELEMENT_PROP_HEIGHT,                          // Element height
   CANV_ELEMENT_PROP_RIGHT,                           // Element right border
   CANV_ELEMENT_PROP_BOTTOM,                          // Element bottom border
   CANV_ELEMENT_PROP_ACT_SHIFT_LEFT,                  // Active area offset from the left edge of the element
   CANV_ELEMENT_PROP_ACT_SHIFT_TOP,                   // Active area offset from the upper edge of the element
   CANV_ELEMENT_PROP_ACT_SHIFT_RIGHT,                 // Active area offset from the right edge of the element
   CANV_ELEMENT_PROP_ACT_SHIFT_BOTTOM,                // Active area offset from the bottom edge of the element
   CANV_ELEMENT_PROP_MOVABLE,                         // Element moveability flag
   CANV_ELEMENT_PROP_ACTIVE,                          // Element activity flag
   CANV_ELEMENT_PROP_INTERACTION,                     // Flag of interaction with the outside environment
   CANV_ELEMENT_PROP_COORD_ACT_X,                     // X coordinate of the element active area
   CANV_ELEMENT_PROP_COORD_ACT_Y,                     // Y coordinate of the element active area
   CANV_ELEMENT_PROP_ACT_RIGHT,                       // Right border of the element active area
   CANV_ELEMENT_PROP_ACT_BOTTOM,                      // Bottom border of the element active area
   CANV_ELEMENT_PROP_VISIBLE_AREA_X,                  // Visibility scope X coordinate
   CANV_ELEMENT_PROP_VISIBLE_AREA_Y,                  // Visibility scope Y coordinate
   CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH,              // Visibility scope width
   CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT,             // Visibility scope height
   CANV_ELEMENT_PROP_CONTROL_AREA_X,                  // Control area X coordinate
   CANV_ELEMENT_PROP_CONTROL_AREA_Y,                  // Control area Y coordinate
   CANV_ELEMENT_PROP_CONTROL_AREA_WIDTH,              // Control area width
   CANV_ELEMENT_PROP_CONTROL_AREA_HEIGHT,             // Control area height
   CANV_ELEMENT_PROP_SCROLL_AREA_X_RIGHT,             // Right scroll area X coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_Y_RIGHT,             // Right scroll area Y coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_RIGHT,         // Right scroll area width
   CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_RIGHT,        // Right scroll area height
   CANV_ELEMENT_PROP_SCROLL_AREA_X_BOTTOM,            // Bottom scroll area X coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_Y_BOTTOM,            // Bottom scroll area Y coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_BOTTOM,        // Bottom scroll area width
   CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_BOTTOM,       // Bottom scroll area height
   CANV_ELEMENT_PROP_BORDER_LEFT_AREA_WIDTH,          // Left edge area width
   CANV_ELEMENT_PROP_BORDER_BOTTOM_AREA_WIDTH,        // Bottom edge area width
   CANV_ELEMENT_PROP_BORDER_RIGHT_AREA_WIDTH,         // Right edge area width
   CANV_ELEMENT_PROP_BORDER_TOP_AREA_WIDTH,           // Upper edge area width
   CANV_ELEMENT_PROP_DISPLAYED,                       // Non-hidden control display flag
   CANV_ELEMENT_PROP_DISPLAY_STATE,                   // Control display state
   CANV_ELEMENT_PROP_DISPLAY_DURATION,                // Control display duration
   CANV_ELEMENT_PROP_GROUP,                           // Group the graphical element belongs to
   CANV_ELEMENT_PROP_ZORDER,                          // Priority of a graphical object for receiving the event of clicking on a chart
   CANV_ELEMENT_PROP_ENABLED,                         // Element availability flag
   CANV_ELEMENT_PROP_RESIZABLE,                       // Resizable element flag
   CANV_ELEMENT_PROP_FORE_COLOR,                      // Default text color for all control objects
   CANV_ELEMENT_PROP_FORE_COLOR_OPACITY,              // Default text color opacity for all control objects
   CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_DOWN,           // Default control text color when clicking on the control
   CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_OVER,           // Default control text color when hovering the mouse over the control
   CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON,             // Text color of the control which is on
   CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_DOWN,  // Default control text color when clicking on the control which is on
   CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_OVER,  // Default control text color when hovering the mouse over the control which is on
   CANV_ELEMENT_PROP_BACKGROUND_COLOR,                // Control background color
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_OPACITY,        // Opacity of control background color
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN,     // Control background color when clicking on the control
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER,     // Control background color when hovering the mouse over the control
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON,       // Background color of the control which is on
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_DOWN,// Control background color when clicking on the control which is on
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_OVER,// Control background color when hovering the mouse over control which is on
   CANV_ELEMENT_PROP_BOLD_TYPE,                       // Font width type
   CANV_ELEMENT_PROP_BORDER_STYLE,                    // Control frame style
   CANV_ELEMENT_PROP_BORDER_SIZE_TOP,                 // Control frame top size
   CANV_ELEMENT_PROP_BORDER_SIZE_BOTTOM,              // Control frame bottom size
   CANV_ELEMENT_PROP_BORDER_SIZE_LEFT,                // Control frame left size
   CANV_ELEMENT_PROP_BORDER_SIZE_RIGHT,               // Control frame right size
   CANV_ELEMENT_PROP_BORDER_COLOR,                    // Control frame color
   CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_DOWN,         // Control frame color when clicking on the control
   CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_OVER,         // Control frame color when hovering the mouse over the control
   CANV_ELEMENT_PROP_AUTOSIZE,                        // Flag of the element auto resizing depending on the content
   CANV_ELEMENT_PROP_AUTOSIZE_MODE,                   // Mode of the element auto resizing depending on the content
   CANV_ELEMENT_PROP_AUTOSCROLL,                      // Auto scrollbar flag
   CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_W,             // Width of the field inside the element during auto scrolling
   CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_H,             // Height of the field inside the element during auto scrolling
   CANV_ELEMENT_PROP_DOCK_MODE,                       // Mode of binding control borders to the container
   CANV_ELEMENT_PROP_MARGIN_TOP,                      // Top margin between the fields of this and another control
   CANV_ELEMENT_PROP_MARGIN_BOTTOM,                   // Bottom margin between the fields of this and another control
   CANV_ELEMENT_PROP_MARGIN_LEFT,                     // Left margin between the fields of this and another control
   CANV_ELEMENT_PROP_MARGIN_RIGHT,                    // Right margin between the fields of this and another control
   CANV_ELEMENT_PROP_PADDING_TOP,                     // Top margin inside the control
   CANV_ELEMENT_PROP_PADDING_BOTTOM,                  // Bottom margin inside the control
   CANV_ELEMENT_PROP_PADDING_LEFT,                    // Left margin inside the control
   CANV_ELEMENT_PROP_PADDING_RIGHT,                   // Right margin inside the control
   CANV_ELEMENT_PROP_TEXT_ALIGN,                      // Text position within text label boundaries
   CANV_ELEMENT_PROP_CHECK_ALIGN,                     // Position of the checkbox within control borders
   CANV_ELEMENT_PROP_CHECKED,                         // Control checkbox status
   CANV_ELEMENT_PROP_CHECK_STATE,                     // Status of a control having a checkbox
   CANV_ELEMENT_PROP_AUTOCHECK,                       // Auto change flag status when it is selected
   CANV_ELEMENT_PROP_BUTTON_TOGGLE,                   // Toggle flag of the control featuring a button
   CANV_ELEMENT_PROP_BUTTON_GROUP,                    // Button group flag
   CANV_ELEMENT_PROP_BUTTON_STATE,                    // Status of the Toggle control featuring a button
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR,          // Color of control checkbox background
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_OPACITY,  // Opacity of the control checkbox background color
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_DOWN,// Color of control checkbox background when clicking on the control
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_OVER,// Color of control checkbox background when hovering the mouse over the control
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR,                // Color of control checkbox frame
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR_OPACITY,        // Opacity of the control checkbox frame color
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_DOWN,     // Color of control checkbox frame when clicking on the control
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_OVER,     // Color of control checkbox frame when hovering the mouse over the control
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR,                // Color of control checkbox
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_OPACITY,        // Opacity of the control checkbox color
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_DOWN,     // Color of control checkbox when clicking on the control
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_OVER,     // Color of control checkbox when hovering the mouse over the control
   CANV_ELEMENT_PROP_LIST_BOX_MULTI_COLUMN,           // Horizontal display of columns in the ListBox control
   CANV_ELEMENT_PROP_LIST_BOX_COLUMN_WIDTH,           // Width of each ListBox control column
   CANV_ELEMENT_PROP_TAB_MULTILINE,                   // Several lines of tabs in TabControl
   CANV_ELEMENT_PROP_TAB_ALIGNMENT,                   // Location of tabs inside the control
   CANV_ELEMENT_PROP_TAB_SIZE_MODE,                   // Tab size setting mode
   CANV_ELEMENT_PROP_TAB_PAGE_NUMBER,                 // Tab index number
   CANV_ELEMENT_PROP_TAB_PAGE_ROW,                    // Tab row index
   CANV_ELEMENT_PROP_TAB_PAGE_COLUMN,                 // Tab column index
   CANV_ELEMENT_PROP_ALIGNMENT,                       // Location of an object inside the control
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_FIXED_PANEL,     // Panel that retains its size when the container is resized
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_FIXED,  // Separator moveability flag
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_DISTANCE,// Distance from edge to separator
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_WIDTH,  // Separator width
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_ORIENTATION,// Separator location
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_COLLAPSED,// Flag for collapsed panel 1
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_MIN_SIZE, // Panel 1 minimum size
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_COLLAPSED,// Flag for collapsed panel 1
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_MIN_SIZE, // Panel 2 minimum size
   CANV_ELEMENT_PROP_TOOLTIP_INITIAL_DELAY,           // Tooltip display delay
   CANV_ELEMENT_PROP_TOOLTIP_AUTO_POP_DELAY,          // Tooltip display duration
   CANV_ELEMENT_PROP_TOOLTIP_RESHOW_DELAY,            // One element new tooltip display delay
   CANV_ELEMENT_PROP_TOOLTIP_SHOW_ALWAYS,             // Display a tooltip in inactive window
   CANV_ELEMENT_PROP_TOOLTIP_ICON,                    // Icon displayed in tooltip
   CANV_ELEMENT_PROP_TOOLTIP_IS_BALLOON,              // Tooltip in the form of a "cloud"
   CANV_ELEMENT_PROP_TOOLTIP_USE_FADING,              // Fade when showing/hiding a tooltip
   CANV_ELEMENT_PROP_PROGRESS_BAR_MAXIMUM,            // The upper bound of the range ProgressBar operates in
   CANV_ELEMENT_PROP_PROGRESS_BAR_MINIMUM,            // The lower bound of the range ProgressBar operates in
   CANV_ELEMENT_PROP_PROGRESS_BAR_STEP,               // ProgressBar increment needed to redraw it
   CANV_ELEMENT_PROP_PROGRESS_BAR_STYLE,              // ProgressBar style
   CANV_ELEMENT_PROP_PROGRESS_BAR_VALUE,              // Current ProgressBar value from Min to Max
   CANV_ELEMENT_PROP_PROGRESS_BAR_MARQUEE_ANIM_SPEED, // Progress bar animation speed in case of Marquee style
   CANV_ELEMENT_PROP_BUTTON_ARROW_SIZE,               // Size of the arrow drawn on the button
  };
#define CANV_ELEMENT_PROP_INTEGER_TOTAL (140)         // Total number of integer properties
#define CANV_ELEMENT_PROP_INTEGER_SKIP  (0)           // Number of integer properties not used in sorting
//+------------------------------------------------------------------+
//| Real properties of the graphical element on the canvas           |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROP_DOUBLE
  {
   CANV_ELEMENT_PROP_DUMMY = CANV_ELEMENT_PROP_INTEGER_TOTAL, // DBL stub
  };
#define CANV_ELEMENT_PROP_DOUBLE_TOTAL  (1)           // Total number of real properties
#define CANV_ELEMENT_PROP_DOUBLE_SKIP   (1)           // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| String properties of the graphical element on the canvas         |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROP_STRING
  {
   CANV_ELEMENT_PROP_NAME_OBJ = (CANV_ELEMENT_PROP_INTEGER_TOTAL+CANV_ELEMENT_PROP_DOUBLE_TOTAL), // Graphical element object name
   CANV_ELEMENT_PROP_NAME_RES,                        // Graphical resource name
   CANV_ELEMENT_PROP_TEXT,                            // Graphical element text
   CANV_ELEMENT_PROP_DESCRIPTION,                     // Graphical element description
   CANV_ELEMENT_PROP_TOOLTIP_TITLE,                   // Element tooltip title
   CANV_ELEMENT_PROP_TOOLTIP_TEXT,                    // Element tooltip text
  };
#define CANV_ELEMENT_PROP_STRING_TOTAL  (6)           // Total number of string properties
//+------------------------------------------------------------------+
//| Possible sorting criteria of graphical elements on the canvas    |
//+------------------------------------------------------------------+
#define FIRST_CANV_ELEMENT_DBL_PROP  (CANV_ELEMENT_PROP_INTEGER_TOTAL-CANV_ELEMENT_PROP_INTEGER_SKIP)
#define FIRST_CANV_ELEMENT_STR_PROP  (CANV_ELEMENT_PROP_INTEGER_TOTAL-CANV_ELEMENT_PROP_INTEGER_SKIP+CANV_ELEMENT_PROP_DOUBLE_TOTAL-CANV_ELEMENT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_CANV_ELEMENT_MODE
  {
//--- Sort by integer properties
   SORT_BY_CANV_ELEMENT_ID = 0,                       // Sort by element ID
   SORT_BY_CANV_ELEMENT_TYPE,                         // Sort by graphical element type
   SORT_BY_CANV_ELEMENT_BELONG,                       // Sort by a graphical element affiliation
   SORT_BY_CANV_ELEMENT_NUM,                          // Sort by form index in the list
   SORT_BY_CANV_ELEMENT_CHART_ID,                     // Sort by chart ID
   SORT_BY_CANV_ELEMENT_WND_NUM,                      // Sort by chart window index
   SORT_BY_CANV_ELEMENT_COORD_X,                      // Sort by the element X coordinate on the chart
   SORT_BY_CANV_ELEMENT_COORD_Y,                      // Sort by the element Y coordinate on the chart
   SORT_BY_CANV_ELEMENT_WIDTH,                        // Sort by the element width
   SORT_BY_CANV_ELEMENT_HEIGHT,                       // Sort by the element height
   SORT_BY_CANV_ELEMENT_RIGHT,                        // Sort by the element right border
   SORT_BY_CANV_ELEMENT_BOTTOM,                       // Sort by the element bottom border
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_LEFT,               // Sort by the active area offset from the left edge of the element
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_TOP,                // Sort by the active area offset from the top edge of the element
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_RIGHT,              // Sort by the active area offset from the right edge of the element
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_BOTTOM,             // Sort by the active area offset from the bottom edge of the element
   SORT_BY_CANV_ELEMENT_MOVABLE,                      // Sort by the element moveability flag
   SORT_BY_CANV_ELEMENT_ACTIVE,                       // Sort by the element activity flag
   SORT_BY_CANV_ELEMENT_INTERACTION,                  // Sort by the flag of interaction with the outside environment
   SORT_BY_CANV_ELEMENT_COORD_ACT_X,                  // Sort by X coordinate of the element active area
   SORT_BY_CANV_ELEMENT_COORD_ACT_Y,                  // Sort by Y coordinate of the element active area
   SORT_BY_CANV_ELEMENT_ACT_RIGHT,                    // Sort by the right border of the element active area
   SORT_BY_CANV_ELEMENT_ACT_BOTTOM,                   // Sort by the bottom border of the element active area
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_X,               // Sort by visibility scope X coordinate
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_Y,               // Sort by visibility scope Y coordinate
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_WIDTH,           // Sort by visibility scope width
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_HEIGHT,          // Sort by visibility scope height
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_X,               // Sort by control area X coordinate
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_Y,               // Sort by control area Y coordinate
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_WIDTH,           // Sort by control area width
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_HEIGHT,          // Sort by control area height
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_X_RIGHT,          // Sort by right scroll area X coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_Y_RIGHT,          // Sort by right scroll area Y coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_WIDTH_RIGHT,      // Sort by right scroll area width
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_HEIGHT_RIGHT,     // Sort by right scroll area height
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_X_BOTTOM,         // Sort by bottom scroll area X coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_Y_BOTTOM,         // Sort by bottom scroll area Y coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_WIDTH_BOTTOM,     // Sort by bottom scroll area width
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_HEIGHT_BOTTOM,    // Sort by bottom scroll area height
   SORT_BY_CANV_ELEMENT_BORDER_LEFT_AREA_WIDTH,       // Sort by left edge area width
   SORT_BY_CANV_ELEMENT_BORDER_BOTTOM_AREA_WIDTH,     // Sort by bottom edge area width
   SORT_BY_CANV_ELEMENT_BORDER_RIGHT_AREA_WIDTH,      // Sort by right edge area width
   SORT_BY_CANV_ELEMENT_BORDER_TOP_AREA_WIDTH,        // Sort by upper edge area width
   SORT_BY_CANV_ELEMENT_DISPLAYED,                    // Sort by non-hidden control display flag
   SORT_BY_CANV_ELEMENT_DISPLAY_STATE,                // Sort by control display state
   SORT_BY_CANV_ELEMENT_DISPLAY_DURATION,             // Sort by control display duration
   SORT_BY_CANV_ELEMENT_GROUP,                        // Sort by a group the graphical element belongs to
   SORT_BY_CANV_ELEMENT_ZORDER,                       // Sort by the priority of a graphical object for receiving the event of clicking on a chart
   SORT_BY_CANV_ELEMENT_ENABLED,                      // Sort by the element availability flag
   SORT_BY_CANV_ELEMENT_RESIZABLE,                    // Sort by resizable element flag
   SORT_BY_CANV_ELEMENT_FORE_COLOR,                   // Sort by default text color for all control objects
   SORT_BY_CANV_ELEMENT_FORE_COLOR_OPACITY,           // Sort by default text color opacity for all control objects
   SORT_BY_CANV_ELEMENT_FORE_COLOR_MOUSE_DOWN,        // Sort by control text color when clicking on the control
   SORT_BY_CANV_ELEMENT_FORE_COLOR_MOUSE_OVER,        // Sort by control text color when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_FORE_COLOR_STATE_ON,          // Sort by control text color when the control is on
   SORT_BY_CANV_ELEMENT_FORE_COLOR_STATE_ON_MOUSE_DOWN,// Sort by the default control text color when clicking on the control while it is on
   SORT_BY_CANV_ELEMENT_FORE_COLOR_STATE_ON_MOUSE_OVER,// Sort by the default control text color when hovering the mouse over the control while it is on
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR,             // Sort by control background text color
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_OPACITY,     // Sort by control background color opacity
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_MOUSE_DOWN,  // Sort by control background text color when clicking on the control
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_MOUSE_OVER,  // Sort by control background text color when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_STATE_ON,    // Sort by control background color when the control is on
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_STATE_ON_MOUSE_DOWN,// Sort by control background color when clicking on the control while it is on
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_STATE_ON_MOUSE_OVER,// Sort by control background color when hovering the mouse over the control while it is on
   SORT_BY_CANV_ELEMENT_BOLD_TYPE,                    // Sort by font width type
   SORT_BY_CANV_ELEMENT_BORDER_STYLE,                 // Sort by control frame style
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_TOP,              // Sort by control frame top size
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_BOTTOM,           // Sort by control frame bottom size
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_LEFT,             // Sort by control frame left size
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_RIGHT,            // Sort by control frame right size
   SORT_BY_CANV_ELEMENT_BORDER_COLOR,                 // Sort by control frame color
   SORT_BY_CANV_ELEMENT_BORDER_COLOR_MOUSE_DOWN,      // Sort by control frame color when clicking on the control
   SORT_BY_CANV_ELEMENT_BORDER_COLOR_MOUSE_OVER,      // Sort by control frame color when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_AUTOSIZE,                     // Sort by the flag of the element auto resizing depending on the content
   SORT_BY_CANV_ELEMENT_AUTOSIZE_MODE,                // Sort by the mode of the control auto resizing depending on the content
   SORT_BY_CANV_ELEMENT_AUTOSCROLL,                   // Sort by auto scrollbar flag
   SORT_BY_CANV_ELEMENT_AUTOSCROLL_MARGIN_W,          // Sort by width of the field inside the element during auto scrolling
   SORT_BY_CANV_ELEMENT_AUTOSCROLL_MARGIN_H, // Sort by height of the field inside the element during auto scrolling
   SORT_BY_CANV_ELEMENT_DOCK_MODE,                    // Sort by mode of binding control borders to the container
   SORT_BY_CANV_ELEMENT_MARGIN_TOP,                   // Sort by top margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_MARGIN_BOTTOM,                // Sort by bottom margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_MARGIN_LEFT,                  // Sort by left margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_MARGIN_RIGHT,                 // Sort by right margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_PADDING_TOP,                  // Sort by top margin inside the control
   SORT_BY_CANV_ELEMENT_PADDING_BOTTOM,               // Sort by bottom margin inside the control
   SORT_BY_CANV_ELEMENT_PADDING_LEFT,                 // Sort by left margin inside the control
   SORT_BY_CANV_ELEMENT_PADDING_RIGHT,                // Sort by right margin inside the control
   SORT_BY_CANV_ELEMENT_TEXT_ALIGN,                   // Sort by text position within text label boundaries
   SORT_BY_CANV_ELEMENT_CHECK_ALIGN,                  // Sort by position of the checkbox within control borders
   SORT_BY_CANV_ELEMENT_CHECKED,                      // Sort by control checkbox status
   SORT_BY_CANV_ELEMENT_CHECK_STATE,                  // Sort by status of a control having a checkbox
   SORT_BY_CANV_ELEMENT_AUTOCHECK,                    // Sort by auto change flag status when it is selected
   SORT_BY_CANV_ELEMENT_BUTTON_TOGGLE,                // Sort by the Toggle flag of the control featuring a button
   SORT_BY_CANV_ELEMENT_BUTTON_GROUP,                 // Sort by button group flag
   SORT_BY_CANV_ELEMENT_BUTTON_STATE,                 // Sort by the status of the Toggle control featuring a button
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR,       // Sort by color of control checkbox background
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR_OPACITY,   // Sort by opacity of control checkbox background color
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR_MOUSE_DOWN,// Sort by color of control checkbox background when clicking on the control
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR_MOUSE_OVER,// Sort by color of control checkbox background when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR,             // Sort by color of control checkbox frame
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR_OPACITY,     // Sort by opacity of control checkbox frame color
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR_MOUSE_DOWN,  // Sort by color of control checkbox frame when clicking on the control
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR_MOUSE_OVER,  // Sort by color of control checkbox frame when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR,             // Sort by color of control checkbox
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR_OPACITY,     // Sort by opacity of control checkbox color
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR_MOUSE_DOWN,  // Sort by color of control checkbox when clicking on the control
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR_MOUSE_OVER,  // Sort by color of control checkbox when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_LIST_BOX_MULTI_COLUMN,        // Sort by horizontal column display flag in the ListBox control
   SORT_BY_CANV_ELEMENT_LIST_BOX_COLUMN_WIDTH,        // Sort by the width of each ListBox control column
   SORT_BY_CANV_ELEMENT_TAB_MULTILINE,                // Sort by the flag of several rows of tabs in TabControl
   SORT_BY_CANV_ELEMENT_TAB_ALIGNMENT,                // Sort by the location of tabs inside the control
   SORT_BY_CANV_ELEMENT_TAB_SIZE_MODE,                // Sort by the mode of setting the tab size
   SORT_BY_CANV_ELEMENT_TAB_PAGE_NUMBER,              // Sort by the tab index number
   SORT_BY_CANV_ELEMENT_TAB_PAGE_ROW,                 // Sort by tab row index
   SORT_BY_CANV_ELEMENT_TAB_PAGE_COLUMN,              // Sort by tab column index
   SORT_BY_CANV_ELEMENT_ALIGNMENT,                    // Sort by the location of the object inside the control
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL,     // Sort by the panel that retains its size when the container is resized
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_FIXED,  // Sort by the separator moveability flag
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_DISTANCE,// Sort by distance from edge to separator
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_WIDTH,  // Sort by separator width
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_ORIENTATION,// Sort by separator location
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL1_COLLAPSED,// Sort by flag for collapsed panel 1
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL1_MIN_SIZE, // Sort by panel 1 minimum size
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL2_COLLAPSED,// Sort by flag for collapsed panel 1
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL2_MIN_SIZE, // Sort by panel 2 minimum size
   SORT_BY_CANV_ELEMENT_TOOLTIP_INITIAL_DELAY,        // Sort by tooltip display delay
   SORT_BY_CANV_ELEMENT_TOOLTIP_AUTO_POP_DELAY,       // Sort by tooltip display duration
   SORT_BY_CANV_ELEMENT_TOOLTIP_RESHOW_DELAY,         // Sort by one element new tooltip display delay
   SORT_BY_CANV_ELEMENT_TOOLTIP_SHOW_ALWAYS,          // Sort by a tooltip in inactive window
   SORT_BY_CANV_ELEMENT_TOOLTIP_ICON,                 // Sort by icon displayed in a tooltip
   SORT_BY_CANV_ELEMENT_TOOLTIP_IS_BALLOON,           // Sort by a cloud tooltip flag
   SORT_BY_CANV_ELEMENT_TOOLTIP_USE_FADING,           // Sort by the flag of fading when showing/hiding a tooltip
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_MAXIMUM,         // Sort by the upper bound of the range ProgressBar operates in
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_MINIMUM,         // Sort by the lower bound of the range ProgressBar operates in
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_STEP,            // Sort by ProgressBar increment needed to redraw it
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_STYLE,           // Sort by ProgressBar style
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_VALUE,           // Sort by the current ProgressBar value from Min to Max
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_MARQUEE_ANIM_SPEED, // Sort by progress bar animation speed in case of Marquee style
   SORT_BY_CANV_ELEMENT_BUTTON_ARROW_SIZE,            // Sort by the size of the arrow drawn on the button
//--- Sort by real properties

//--- Sort by string properties
   SORT_BY_CANV_ELEMENT_NAME_OBJ = FIRST_CANV_ELEMENT_STR_PROP,// Sort by an element object name
   SORT_BY_CANV_ELEMENT_NAME_RES,                     // Sort by the graphical resource name
   SORT_BY_CANV_ELEMENT_TEXT,                         // Sort by graphical element text
   SORT_BY_CANV_ELEMENT_DESCRIPTION,                  // Sort by graphical element description
   SORT_BY_CANV_ELEMENT_TOOLTIP_HEADER,               // Sort by Tooltip header for an element
   SORT_BY_CANV_ELEMENT_TOOLTIP_TEXT,                 // Sort by Tooltip text for an element
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with graphical element animation                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of animation frame types                                    |
//+------------------------------------------------------------------+
enum ENUM_ANIMATION_FRAME_TYPE
  {
   ANIMATION_FRAME_TYPE_TEXT,                         // Text animation frame
   ANIMATION_FRAME_TYPE_QUAD,                         // Rectangular animation frame
   ANIMATION_FRAME_TYPE_GEOMETRY,                     // Square animation frame of geometric shapes
  };
//+------------------------------------------------------------------+
//| List of drawn shape types                                        |
//+------------------------------------------------------------------+
enum ENUM_FIGURE_TYPE
  {
   FIGURE_TYPE_PIXEL,                                 // Pixel
   FIGURE_TYPE_PIXEL_AA,                              // Pixel with antialiasing
   
   FIGURE_TYPE_LINE_VERTICAL,                         // Vertical line
   FIGURE_TYPE_LINE_VERTICAL_THICK,                   // Vertical segment of a freehand line having a specified width using antialiasing algorithm
   
   FIGURE_TYPE_LINE_HORIZONTAL,                       // Horizontal line
   FIGURE_TYPE_LINE_HORIZONTAL_THICK,                 // Horizontal segment of a freehand line having a specified width using antialiasing algorithm
   
   FIGURE_TYPE_LINE,                                  // Arbitrary line
   FIGURE_TYPE_LINE_AA,                               // Line with antialiasing
   FIGURE_TYPE_LINE_WU,                               // Line with WU smoothing
   FIGURE_TYPE_LINE_THICK,                            // Segment of a freehand line having a specified width using antialiasing algorithm
   
   FIGURE_TYPE_POLYLINE,                              // Polyline
   FIGURE_TYPE_POLYLINE_AA,                           // Polyline with antialiasing
   FIGURE_TYPE_POLYLINE_WU,                           // Polyline with WU smoothing
   FIGURE_TYPE_POLYLINE_SMOOTH,                       // Polyline with a specified width using two smoothing algorithms
   FIGURE_TYPE_POLYLINE_THICK,                        // Polyline with a specified width using a smoothing algorithm    
   
   FIGURE_TYPE_POLYGON,                               // Polygon
   FIGURE_TYPE_POLYGON_FILL,                          // Filled polygon
   FIGURE_TYPE_POLYGON_AA,                            // Polygon with antialiasing
   FIGURE_TYPE_POLYGON_WU,                            // Polygon with WU smoothing
   FIGURE_TYPE_POLYGON_SMOOTH,                        // Polygon with a specified width using two smoothing algorithms
   FIGURE_TYPE_POLYGON_THICK,                         // Polygon with a specified width using a smoothing algorithm
   
   FIGURE_TYPE_RECTANGLE,                             // Rectangle
   FIGURE_TYPE_RECTANGLE_FILL,                        // Filled rectangle
   
   FIGURE_TYPE_CIRCLE,                                // Circle
   FIGURE_TYPE_CIRCLE_FILL,                           // Filled circle
   FIGURE_TYPE_CIRCLE_AA,                             // Circle with antialiasing
   FIGURE_TYPE_CIRCLE_WU,                             // Circle with WU smoothing
   
   FIGURE_TYPE_TRIANGLE,                              // Triangle
   FIGURE_TYPE_TRIANGLE_FILL,                         // Filled triangle
   FIGURE_TYPE_TRIANGLE_AA,                           // Triangle with antialiasing
   FIGURE_TYPE_TRIANGLE_WU,                           // Triangle with WU smoothing
   
   FIGURE_TYPE_ELLIPSE,                               // Ellipse
   FIGURE_TYPE_ELLIPSE_FILL,                          // Filled ellipse
   FIGURE_TYPE_ELLIPSE_AA,                            // Ellipse with antialiasing
   FIGURE_TYPE_ELLIPSE_WU,                            // Ellipse with WU smoothing
   
   FIGURE_TYPE_ARC,                                   // Ellipse arc
   FIGURE_TYPE_PIE,                                   // Ellipse sector
   
   FIGURE_TYPE_FILL,                                  // Filled area
   
  };
//+------------------------------------------------------------------+
//| Font style list                                                  |
//+------------------------------------------------------------------+
enum ENUM_FONT_STYLE
  {
   FONT_STYLE_NORMAL=0,                               // Normal
   FONT_STYLE_ITALIC=FONT_ITALIC,                     // Italic
   FONT_STYLE_UNDERLINE=FONT_UNDERLINE,               // Underline
   FONT_STYLE_STRIKEOUT=FONT_STRIKEOUT                // Strikeout
  };
//+------------------------------------------------------------------+
//| Font width type list                                             |
//+------------------------------------------------------------------+
enum ENUM_FW_TYPE
  {
   FW_TYPE_DONTCARE=FW_DONTCARE,
   FW_TYPE_THIN=FW_THIN,
   FW_TYPE_EXTRALIGHT=FW_EXTRALIGHT,
   FW_TYPE_ULTRALIGHT=FW_ULTRALIGHT,
   FW_TYPE_LIGHT=FW_LIGHT,
   FW_TYPE_NORMAL=FW_NORMAL,
   FW_TYPE_REGULAR=FW_REGULAR,
   FW_TYPE_MEDIUM=FW_MEDIUM,
   FW_TYPE_SEMIBOLD=FW_SEMIBOLD,
   FW_TYPE_DEMIBOLD=FW_DEMIBOLD,
   FW_TYPE_BOLD=FW_BOLD,
   FW_TYPE_EXTRABOLD=FW_EXTRABOLD,
   FW_TYPE_ULTRABOLD=FW_ULTRABOLD,
   FW_TYPE_HEAVY=FW_HEAVY,
   FW_TYPE_BLACK=FW_BLACK
  };
//+------------------------------------------------------------------+
//New add due to table model
// Enumeration of table object types
enum ENUM_TABLE_OBJECT_TYPE         //ENUM_OBJECT_TYPE
  {
   OBJECT_TYPE_TABLE_CELL=10000,    // Table cell
   OBJECT_TYPE_TABLE_ROW,           // Table row
   OBJECT_TYPE_TABLE_MODEL,         // Table model
   OBJECT_TYPE_COLUMN_CAPTION,      // Table column caption
   OBJECT_TYPE_TABLE_HEADER,        // Table header
   OBJECT_TYPE_TABLE,               // Table
   OBJECT_TYPE_TABLE_BY_PARAM,      // Table built from parameter array data
  };

// Table cell comparison modes
enum ENUM_TABLE_CELL_COMPARE_MODE   //ENUM_CELL_COMPARE_MODE
  {
   CELL_COMPARE_MODE_COL,           // Compare by column number
   CELL_COMPARE_MODE_ROW,           // Compare by row number
   CELL_COMPARE_MODE_ROW_COL,       // Compare by row and column
  };
