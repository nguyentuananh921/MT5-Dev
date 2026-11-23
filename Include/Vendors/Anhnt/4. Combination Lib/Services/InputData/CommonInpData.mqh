//+------------------------------------------------------------------+
//|                                             CommonInpData.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __COMMON_INP_DATA_MQH__
#define __COMMON_INP_DATA_MQH__
  #property copyright "Copyright 2020, MetaQuotes Software Corp."
  #property link      "https://mql5.com/en/users/artmedia70"
  //+------------------------------------------------------------------+
  //| Macro substitutions                                              |
  //+------------------------------------------------------------------+
  #define COMPILE_EN // Comment out the string for compilation in Russian
  //+------------------------------------------------------------------+
  //| Input enumerations                                               |
  //+------------------------------------------------------------------+
  #ifdef COMPILE_EN    
    //+------------------------------------------------------------------+
    //| "Yes" / "No"                                                     |
    //+------------------------------------------------------------------+
    enum ENUM_INPUT_YES_NO
      {
        INPUT_NO  = 0,               // No
        INPUT_YES = 1                // Yes
      };
    //+------------------------------------------------------------------+
    //| Modes of working with timeframes                                 |
    //+------------------------------------------------------------------+
    enum ENUM_TIMEFRAMES_MODE
      {
        TIMEFRAMES_MODE_CURRENT ,    // Work only with the current timeframe
        TIMEFRAMES_MODE_LIST    ,    // Work with a given list of timeframes
        TIMEFRAMES_MODE_ALL          // Work with a complete list of timeframes
      };
    //+------------------------------------------------------------------+
  #else
    //+------------------------------------------------------------------+
    //| "Yes" / "No"                                                     |
    //+------------------------------------------------------------------+
    enum ENUM_INPUT_YES_NO
      {
        INPUT_NO  = 0,               // Нет
        INPUT_YES = 1                // Да
      };
    //+------------------------------------------------------------------+
    //| Modes of working with timeframes                                 |
    //+------------------------------------------------------------------+
    enum ENUM_TIMEFRAMES_MODE
      {
        TIMEFRAMES_MODE_CURRENT ,    // Work with the current timeframe only
        TIMEFRAMES_MODE_LIST    ,    // Work with the specified timeframe list
        TIMEFRAMES_MODE_ALL          // Work with the full timeframe list
      };
    //+------------------------------------------------------------------+
  
  #endif // COMPILE_EN  

#endif // __COMMON_INP_DATA_MQH__