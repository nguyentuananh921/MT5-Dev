//+------------------------------------------------------------------+
//|  CommonDefines.mqh
//+------------------------------------------------------------------+
#ifndef __COMMONDEFINES_MQH__
#define __COMMONDEFINES_MQH__ 
 #include <Trade\Trade.mqh>   // ENUM_LOG_LEVELS of MT5 (LOG_LEVEL_NO, _ERRORS, _ALL): the same as ENUM_LOG_LEVEL of DoEasy above
 //+------------------------------------------------------------------+
 //| Base object event reasons (CBaseEvent)                           |
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
 //| List of library object types                                     |
 //+------------------------------------------------------------------+
 enum ENUM_OBJECT_DE_TYPE
  {
   //--- The program that is not of the library: it writes the same tables (Setting_Sync: sync_by)
    OBJECT_DE_TYPE_PYTHON,                                         // Python (the history and the pairs the library does not keep up to date)
   //--- Base objects
    OBJECT_DE_TYPE_BASE,                                           // CBaseObj Base object for all library objects
    OBJECT_DE_TYPE_BASE_EXT,                                       // CBaseObjExt Extended base object for all library objects
   //--- Chart
    OBJECT_DE_TYPE_CHART,                                          // "Chart" object type
    OBJECT_DE_TYPE_CHART_WND_IND,                                  // "Chart window indicator" object type
   //--- Trading information
    OBJECT_DE_TYPE_SYMBOL,                                         // "Symbol" object type
   //--- The data objects of the properties of a graphical object
    OBJECT_DE_TYPE_LONG,                                           // "Long type data" object type
    OBJECT_DE_TYPE_DOUBLE,                                         // "Double type data" object type
    OBJECT_DE_TYPE_STRING,                                         // "String type data" object type
    OBJECT_DE_TYPE_OBJECT,                                         // "Object type data" object type
   //--- Timeseries
    OBJECT_DE_TYPE_SERIES_BAR,                                     // "Bar" object type
    OBJECT_DE_TYPE_SERIES_PERIOD,                                  // "Period timeseries" object type
    OBJECT_DE_TYPE_SERIES_SYMBOL,                                  // "Symbol timeseries" object type
    OBJECT_DE_TYPE_SERIES_BAR_CONTROL,                             // "Control of the information of the bars of a series" object type
   //--- Trading
    OBJECT_DE_TYPE_ORDER_DEAL_POSITION,                            // "Order/Deal/Position" object type
    OBJECT_DE_TYPE_HISTORY_BALANCE,                                // "Historical balance operation" object type
    OBJECT_DE_TYPE_HISTORY_DEAL,                                   // "Historical deal" object type
    OBJECT_DE_TYPE_HISTORY_ORDER_MARKET,                           // "Historical market order" object type
    OBJECT_DE_TYPE_HISTORY_ORDER_PENDING,                          // "Historical removed pending order" object type
    OBJECT_DE_TYPE_MARKET_ORDER,                                   // "Market order" object type
    OBJECT_DE_TYPE_MARKET_PENDING,                                 // "Pending order" object type
    OBJECT_DE_TYPE_MARKET_POSITION,                                // "Market position" object type
    OBJECT_DE_TYPE_EVENT,                                          // "Event" object type
    OBJECT_DE_TYPE_EVENT_BALANCE,                                  // "Balance operation event" object type
    OBJECT_DE_TYPE_EVENT_MODIFY,                                   // "Pending order/position modification event" object type
    OBJECT_DE_TYPE_EVENT_ORDER_PLACED,                             // "Placing a pending order event" object type
    OBJECT_DE_TYPE_EVENT_ORDER_REMOVED,                            // "Pending order removal event" object type
    OBJECT_DE_TYPE_EVENT_POSITION_CLOSE,                           // "Position closure event" object type
    OBJECT_DE_TYPE_EVENT_POSITION_OPEN,                            // "Position opening event" object type
    OBJECT_DE_TYPE_ACCOUNT,                                        // "Account" object type (after the series: sync_by keeps the numbers before it)
    OBJECT_DE_TYPE_SERIES_PATTERN,                                 // "Bar pattern" object type (CBarPattern: a candle pattern or a Momentum Candle found on a bar)
    OBJECT_DE_TYPE_SERIES_SWING,                                   // "Swing" object type (CBarSwing: a swing point found on a bar)
    OBJECT_DE_TYPE_SERIES_BOS,                                     // "BOS" object type (CBarBOS: a Break of Structure found on a bar)
    OBJECT_DE_TYPE_SERIES_CHOCH,                                   // "CHoCH" object type (CBarCHoCH: a Change of Character found on a bar)
    OBJECT_DE_TYPE_INDICATOR,                                      // "Indicator" object type (CIndicatorDE: a template on a pair, its handle)
    OBJECT_DE_TYPE_IND_DATA,                                       // "Indicator data" object type (V1 CDataInd)
    OBJECT_DE_TYPE_IND_DATA_LIST,                                  // "Indicator data list" object type (V1 CSeriesDataInd)
    OBJECT_DE_TYPE_IND_AC,                                         // "Accelerator Oscillator indicator" object type
    OBJECT_DE_TYPE_IND_AD,                                         // "Accumulation/Distribution indicator" object type
    OBJECT_DE_TYPE_IND_ADX,                                        // "Average Directional Index indicator" object type
    OBJECT_DE_TYPE_IND_ADXW,                                       // "ADX indicator by Welles Wilder" object type
    OBJECT_DE_TYPE_IND_ALLIGATOR,                                  // "Alligator indicator" object type
    OBJECT_DE_TYPE_IND_AMA,                                        // "Adaptive Moving Average indicator" object type
    OBJECT_DE_TYPE_IND_AO,                                         // "Awesome Oscillator indicator" object type
    OBJECT_DE_TYPE_IND_ATR,                                        // "Average True Range" object type
    OBJECT_DE_TYPE_IND_BANDS,                                      // "Bollinger Bands indicator" object type
    OBJECT_DE_TYPE_IND_BEARS,                                      // "Bears Power indicator" object type
    OBJECT_DE_TYPE_IND_BULLS,                                      // "Bulls Power indicator" object type
    OBJECT_DE_TYPE_IND_BWMFI,                                      // "Market Facilitation Index indicator" object type
    OBJECT_DE_TYPE_IND_CCI,                                        // "Commodity Channel Index indicator" object type
    OBJECT_DE_TYPE_IND_CHAIKIN,                                    // "Chaikin Oscillator indicator" object type
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
    OBJECT_DE_TYPE_IND_TEMA,                                       // "Triple Exponential Moving Average indicator" object type
    OBJECT_DE_TYPE_IND_TRIX,                                       // "Triple Exponential Moving Averages Oscillator indicator" object type
    OBJECT_DE_TYPE_IND_VIDYA,                                      // "Variable Index Dynamic Average indicator" object type
    OBJECT_DE_TYPE_IND_VOLUMES,                                    // "Volumes indicator" object type
    OBJECT_DE_TYPE_IND_WPR,                                        // "Williams' Percent Range indicator" object type
   //--- Signals (V2 names): CSignal is a row, its children are the judges of the templates
    OBJECT_DE_TYPE_SIGNAL,                                         // "Signal" object type (CSignal: a flip of a template on a bar; ATR: no rule)
    OBJECT_DE_TYPE_SIGNAL_SERIES,                                  // "Signal series" object type (CSignalSeriesDE: the flips of a template on a pair)
    OBJECT_DE_TYPE_SIGNAL_SAR,                                     // "SAR signal" object type
    OBJECT_DE_TYPE_SIGNAL_MA,                                      // "MA slope signal" object type
    OBJECT_DE_TYPE_SIGNAL_OSCILLATOR,                              // "Oscillator OB/OS signal" object type
    OBJECT_DE_TYPE_SIGNAL_ZEROCROSS,                               // "Zero-line cross signal" object type
    OBJECT_DE_TYPE_SIGNAL_BOLLINGER,                               // "Bollinger bands signal" object type
    OBJECT_DE_TYPE_SIGNAL_ENVELOPES,                               // "Envelopes signal" object type
    OBJECT_DE_TYPE_SIGNAL_TWOLINECROSS,                            // "Two-line cross signal" object type
    OBJECT_DE_TYPE_SIGNAL_FRACTALS,                                // "Fractals reversal signal" object type
    OBJECT_DE_TYPE_SIGNAL_VOLUMES,                                 // "Volumes against their average signal" object type (new in V4)
   //--- Ticks
    OBJECT_DE_TYPE_NEW_TICK,                                       // "New tick" object type
    OBJECT_DE_TYPE_TICK,                                           // "Tick" object type (CTick, DoEasy CDataTick)
    OBJECT_DE_TYPE_TICKSERIES,                                     // "Tick data series" object type (CTickSeriesDE, DoEasy CTickSeries)
   //--- Graphics
    OBJECT_DE_TYPE_GBASE,                                          // Base object of all library graphical objects
    OBJECT_DE_TYPE_GELEMENTBASE,                                   // Base object of the GUI controls (CGElement)
   //GUI Control Elements
    //For Type of Windows
     OBJECT_DE_TYPE_GUICONTROL_WINDOW_MAIN,                         // "Main window" object type: its close button removes the program
     OBJECT_DE_TYPE_GUICONTROL_WINDOW_DIALOG,                       // "Dialog window" object type: its close button hides the window
     OBJECT_DE_TYPE_GUICONTROL_WINDOW_POPUP,                        // "Popup window" object type: no caption, hides when the cursor leaves
    //For Type of Separtor Line
     OBJECT_DE_TYPE_GUICONTROL_SEP_HORIZONTAL_LINE,                 // "Horizontal separate line" object type: dark on top, light below
     OBJECT_DE_TYPE_GUICONTROL_SEP_VERTICAL_LINE,                   // "Vertical separate line" object type: dark on the left, light on the right
    //For type of Menu Item 
     OBJECT_DE_TYPE_GUICONTROL_MENU_ITEM_SIMPLE,                    // "Simple menu item" object type
     OBJECT_DE_TYPE_GUICONTROL_MENU_ITEM_CHECKBOX,                  // "Menu item with a check box" object type
     OBJECT_DE_TYPE_GUICONTROL_MENU_ITEM_HAS_CONTEXT_MENU,          // "Menu item that opens a context menu" object type (right arrow)
   //--- Trading information (V3, added here: the numbers before stay the same)
    OBJECT_DE_TYPE_SYMBOL_COMMON,                                  // "Common group symbol" object type
    OBJECT_DE_TYPE_TRADE,                                          // "Trading object" object type
    OBJECT_DE_TYPE_PENDING_REQUEST,                                // "Pending trading request" object type
    OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_OPEN,                  // "Pending request to open a position" object type
    OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_CLOSE,                 // "Pending request to close a position" object type
    OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_SLTP,                  // "Pending request to modify position stop orders" object type
    OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_PLACE,                    // "Pending request to place a pending order" object type
    OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_REMOVE,                   // "Pending request to delete a pending order" object type
    OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_MODIFY,                   // "Pending request to modify pending order parameters" object type
   //--- Settings: a row of a table of a manager, in RAM (added here: the numbers before stay the same)
    OBJECT_DE_TYPE_SYMBOLTF_SETTING,                               // "Pair Symbol + TF setting" object type (CSymbolTFSetting: a row of Setting_SymbolTF)
    OBJECT_DE_TYPE_INDICATOR_SETTING,                              // "Indicator template setting" object type (V2 / V3 CIndicatorSetting: a row of Setting_IndicatorTemplate)
    OBJECT_DE_TYPE_BAR_INFORMATION_SETTING,                        // "Bar information setting" object type (V3 CPatternSetting: a row of Setting_BarInformation, its rows of Setting_BarSetup)
   //--- Standard graphical objects (keep last: values are OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_xxx)
    OBJECT_DE_TYPE_GSTD_OBJ,                                       // Standard graphical object
    OBJECT_DE_TYPE_GSTD_TREND              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TREND,            // "Trend line" object type
    OBJECT_DE_TYPE_GSTD_RECTANGLE          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE,        // "Rectangle" object type
    OBJECT_DE_TYPE_GSTD_TRIANGLE           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TRIANGLE,         // "Triangle" object type
    OBJECT_DE_TYPE_GSTD_TEXT               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TEXT,             // "Text" object type
    OBJECT_DE_TYPE_GSTD_RECTANGLE_LABEL    =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE_LABEL,  // "Rectangle label" object type
   //--- Collections (m_type of a collection). The numbers are stored in Setting_Sync (sync_object, sync_by) and mirrored in Python\libdb.py: never change them, keep them last
    COLLECTION_HISTORY_ID                  =  0x777A,                                         // CHistoryCollection: the historical orders and deals of the account
    COLLECTION_MARKET_ID                   =  0x777B,                                         // CMarketCollection: the pending orders and positions of the account
    COLLECTION_TRADE_EVENTS_ID             =  0x777C,                                         // CTradeEventsCollection: the trading events of the account
    COLLECTION_ACCOUNT_ID                  =  0x777D,                                         // CAccountsCollection: table accounts
    COLLECTION_SYMBOLS_ID                  =  0x777E,                                         // CSymbolsCollection: tables symbols, timeframes
    COLLECTION_SERIES_ID                   =  0x777F,                                         // CBarTimeSeriesCollection: tables BarSeriesDE, BarTimeSeriesCollection
    COLLECTION_SIGNALS_ID                  =  0x778A,                                         // CSignalsCollection: table SignalsCollection (the value of V2)
    COLLECTION_INDICATORS_ID               =  0x7782,                                         // CIndicatorsCollection: the handles of the templates on the pairs, no table (the value of V1)
    COLLECTION_TICKSERIES_ID               =  0x7784                                          // CTickSeriesCollection: the ticks of the symbols, RAM only, no table (the value of DoEasy)
  };
 //+------------------------------------------------------------------+
 //| The direction of a signal: column signal_direction of the tables |
 //| BarTimeSeriesCollection and SignalsCollection                    |
 //+------------------------------------------------------------------+
 enum ENUM_SIGNAL_DIRECTION
  {
   SIGNAL_DIRECTION_BUY,                                    // The Buy direction (up)
   SIGNAL_DIRECTION_SELL,                                   // The Sell direction (down)
   SIGNAL_DIRECTION_NONE,                                   // No direction (a rule that does not say a side on a bar), the markers do not draw it
  }; 
 //--- Timeseries parameters
  #define SERIES_DEFAULT_BARS_COUNT      (1000)                     // Required default amount of timeseries data
  #define PAUSE_FOR_SYNC_ATTEMPTS        (16)                       // Amount of pause milliseconds between synchronization attempts
  #define ATTEMPTS_FOR_SYNC              (5)                        // Number of attempts to receive synchronization with the server
 //--- Describe the function in a log text
  #define DFUN                           (__FUNCTION__+": ")        // "Function description"
  #define DFUN_ERR_LINE                  (__FUNCTION__+(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian" ? ", Page " : ", Line ")+(string)__LINE__+": ")
  #define END_TIME                       (D'31.12.3000 23:59:59')   // End date for account history data requests
 //--- Trading (V3 CommonDefines)
  #define TOTAL_TRADE_TRY                (5)                        // Default number of trading attempts
  #define CLR_MW_DEFAULT                 (0xFF000000)               // Default symbol background color in the Market Watch
  #define PENDING_REQUEST_ID_TYPE_ERR    (1)                        // Type of a pending request created based on the server return code
  #define PENDING_REQUEST_ID_TYPE_REQ    (2)                        // Type of a pending request created by request
 //+------------------------------------------------------------------+
 //| Search and sorting data (V3: the comparison of the activation    |
 //| criteria of a pending request)                                   |
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
 //--- Default font, control corner area
  #define DEF_FONT                       ("Calibri")                // Default font
  #define DEF_FONT_SIZE                  (10)                       // Default font size
  #define DEF_CONTROL_CORNER_AREA        (4)                        // Number of pixels defining the corner area to resize
  #define DEF_LINE_WIDTH                 (3)                        // Default width of a native line object (solid: a dash style needs width 1)
 //--- The timeframes of the library, shortest first: the one list, CIndicatorTemplateManager fills the table timeframes from it
 struct STimeframeItem
  {
   ENUM_TIMEFRAMES tf_enum;
   string          name;
  };
 STimeframeItem timeframe_list[] =
  {
   {PERIOD_M1,  "M1"},
   {PERIOD_M2,  "M2"},
   {PERIOD_M3,  "M3"},
   {PERIOD_M4,  "M4"},
   {PERIOD_M5,  "M5"},
   {PERIOD_M6,  "M6"},
   {PERIOD_M10, "M10"},
   {PERIOD_M12, "M12"},
   {PERIOD_M15, "M15"},
   {PERIOD_M20, "M20"},
   {PERIOD_M30, "M30"},
   {PERIOD_H1,  "H1"},
   {PERIOD_H2,  "H2"},
   {PERIOD_H3,  "H3"},
   {PERIOD_H4,  "H4"},
   {PERIOD_H6,  "H6"},
   {PERIOD_H8,  "H8"},
   {PERIOD_H12, "H12"},
   {PERIOD_D1,  "D1"},
   {PERIOD_W1,  "W1"},
   {PERIOD_MN1, "MN1"}
  };

#endif // __COMMONDEFINES_MQH__

