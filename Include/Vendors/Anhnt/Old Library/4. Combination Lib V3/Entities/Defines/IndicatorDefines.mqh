//+------------------------------------------------------------------+
//|                                              IndicatorDefines.mqh |
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//| Only what a CIndicatorDE holds when Python calculates: the       |
//| identity of the indicator and the state of its newest closed bar |
//+------------------------------------------------------------------+
#ifndef __INDICATOR_DEFINES_MQH__
#define __INDICATOR_DEFINES_MQH__
#include "CommonDefines.mqh"
//+------------------------------------------------------------------+
//| Indicator integer properties                                     |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_INTEGER
  {
   INDICATOR_PROP_TYPE = 0,                           // Indicator type (ENUM_INDICATOR)
   INDICATOR_PROP_TIMEFRAME,                          // Indicator timeframe
   INDICATOR_PROP_ID,                                 // Indicator ID in the collection
   INDICATOR_PROP_SIGNAL_DIR,                         // Direction of the last signal (ENUM_SIGNAL_DIR)
  };
#define INDICATOR_PROP_INTEGER_TOTAL (4)              // Total number of integer properties
//+------------------------------------------------------------------+
//| Indicator real properties                                        |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_DOUBLE
  {
   INDICATOR_PROP_VALUE = INDICATOR_PROP_INTEGER_TOTAL, // Value of buffer 0 on the newest closed bar (EMPTY_VALUE: none)
   INDICATOR_PROP_PREVIOUS,                           // The same on the bar before
  };
#define INDICATOR_PROP_DOUBLE_TOTAL  (2)              // Total number of real properties
//+------------------------------------------------------------------+
//| Indicator string properties                                      |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_PROP_STRING
  {
   INDICATOR_PROP_SYMBOL = (INDICATOR_PROP_INTEGER_TOTAL+INDICATOR_PROP_DOUBLE_TOTAL), // Indicator symbol
  };
#define INDICATOR_PROP_STRING_TOTAL  (1)              // Total number of string properties
#endif // __INDICATOR_DEFINES_MQH__
