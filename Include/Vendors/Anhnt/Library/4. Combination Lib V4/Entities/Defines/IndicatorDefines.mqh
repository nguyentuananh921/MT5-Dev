//+------------------------------------------------------------------+
//|                                            IndicatorDefines.mqh  |
//|     Defines for working with indicator parameters                |
//+------------------------------------------------------------------+
#ifndef __INDICATORDEFINES_MQH__
#define __INDICATORDEFINES_MQH__
//--- From V1 Defines\TimeseriesDefines.mqh: INDICATOR_PROP_HANDLE and IND_DATA_PROP_IND_HANDLE are not properties (an indicator is told by its type + params,
//--- never by the handle: the handle is CIndicatorDE's own, for CopyBuffer and IndicatorRelease only)
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
    INDICATOR_PROP_GROUP,                                    // Indicator group
    INDICATOR_PROP_ID,                                       // Indicator ID (the id of the template, Setting_IndicatorTemplate)
   };
  #define INDICATOR_PROP_INTEGER_TOTAL (5)                   // Total number of indicator integer properties
  #define INDICATOR_PROP_INTEGER_SKIP  (0)                   // Number of indicator properties not used in sorting
 //+------------------------------------------------------------------+
 //| Indicator real properties                                        |
 //+------------------------------------------------------------------+
  enum ENUM_INDICATOR_PROP_DOUBLE
   {
    INDICATOR_PROP_EMPTY_VALUE = INDICATOR_PROP_INTEGER_TOTAL,// Empty value for plotting where nothing will be drawn
   };
  #define INDICATOR_PROP_DOUBLE_TOTAL  (1)                   // Total number of real indicator properties
  #define INDICATOR_PROP_DOUBLE_SKIP   (0)                   // Number of indicator properties not used in sorting
 //+------------------------------------------------------------------+
 //| Indicator string properties                                      |
 //+------------------------------------------------------------------+
  enum ENUM_INDICATOR_PROP_STRING
   {
    INDICATOR_PROP_SYMBOL = (INDICATOR_PROP_INTEGER_TOTAL+INDICATOR_PROP_DOUBLE_TOTAL), // Indicator symbol
    INDICATOR_PROP_NAME,                                     // Indicator name
    INDICATOR_PROP_SHORTNAME,                                // Indicator short name
   };
  #define INDICATOR_PROP_STRING_TOTAL  (3)                   // Total number of indicator string properties
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
 //| Integer properties of indicator data                             |
 //+------------------------------------------------------------------+
  enum ENUM_IND_DATA_PROP_INTEGER
   {
    IND_DATA_PROP_TIME = 0,                                  // Start time of indicator data bar period
    IND_DATA_PROP_PERIOD,                                    // Indicator data period (timeframe)
    IND_DATA_PROP_INDICATOR_TYPE,                            // Indicator type
    IND_DATA_PROP_IND_BUFFER_NUM,                            // Indicator data buffer number
    IND_DATA_PROP_IND_ID,                                    // Indicator ID
   };
  #define IND_DATA_PROP_INTEGER_TOTAL (5)                    // Total number of indicator data integer properties
  #define IND_DATA_PROP_INTEGER_SKIP  (0)                    // Number of indicator data properties not used in sorting
 //+------------------------------------------------------------------+
 //| Indicator data real properties                                   |
 //+------------------------------------------------------------------+
  enum ENUM_IND_DATA_PROP_DOUBLE
   {
    IND_DATA_PROP_BUFFER_VALUE = IND_DATA_PROP_INTEGER_TOTAL,// Indicator data value
   };
  #define IND_DATA_PROP_DOUBLE_TOTAL  (1)                    // Total number of indicator data real properties
  #define IND_DATA_PROP_DOUBLE_SKIP   (0)                    // Number of indicator data properties not used in sorting
 //+------------------------------------------------------------------+
 //| Indicator data string properties                                 |
 //+------------------------------------------------------------------+
  enum ENUM_IND_DATA_PROP_STRING
   {
    IND_DATA_PROP_SYMBOL = (IND_DATA_PROP_INTEGER_TOTAL+IND_DATA_PROP_DOUBLE_TOTAL), // Indicator data symbol
    IND_DATA_PROP_IND_NAME,                                  // Indicator name
    IND_DATA_PROP_IND_SHORTNAME,                             // Indicator short name
   };
  #define IND_DATA_PROP_STRING_TOTAL  (3)                    // Total number of string properties of indicator data
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
   //--- Sort by real properties
    SORT_BY_IND_DATA_BUFFER_VALUE = FIRST_IND_DATA_DBL_PROP, // Sort by indicator data value
   //--- Sort by string properties
    SORT_BY_IND_DATA_SYMBOL = FIRST_IND_DATA_STR_PROP,       // Sort by indicator data symbol
    SORT_BY_IND_DATA_IND_NAME,                               // Sort by indicator name
    SORT_BY_IND_DATA_IND_SHORTNAME,                          // Sort by indicator short name
   };
  #define INDICATOR_PARAM_SLOTS_MAX 8
  //To Display on Combobox
   #define CALCULATION_METHOD_CHOICES "SMA|EMA|SMMA|LWMA"
   #define PRICE_CHOICES  "Close|Open|High|Low|Median|Typical|WClose"
   #define STOCH_PRICE_CHOICES "Low/High|Close/Close"
   #define VOLUME_CHOICES "Tick|Real"
#endif // __INDICATORDEFINES_MQH__
