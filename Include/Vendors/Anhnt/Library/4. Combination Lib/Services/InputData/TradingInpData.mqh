//+------------------------------------------------------------------+
//|                                            TradingInpData.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __TRADING_INPDATA_MQH__
#define __TRADING_INPDATA_MQH__

#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "CommonInpData.mqh"
  //+------------------------------------------------------------------+
  //| Input enumerations                                               |
  //+------------------------------------------------------------------+
#ifdef COMPILE_EN
  #ifndef CTRADING_INPDATA_MQH_DECLARATION
  #define CTRADING_INPDATA_MQH_DECLARATION
    //+------------------------------------------------------------------+
    //| Modes of working with symbols                                    |
    //+------------------------------------------------------------------+
    enum ENUM_SYMBOLS_MODE
      {
        SYMBOLS_MODE_CURRENT      ,  // Work only with the current Symbol
        SYMBOLS_MODE_DEFINES      ,  // Work with a given list of Symbols
        SYMBOLS_MODE_MARKET_WATCH ,  // Work with Symbols from the "Market Watch" window
        SYMBOLS_MODE_ALL             // Work with a complete list of Symbols
      };
    //+------------------------------------------------------------------+
  #endif // CTRADING_INPDATA_MQH_DECLARATION
//+------------------------------------------------------------------+
#else
  #ifndef CTRADING_INPDATA_MQH_DECLARATION
  #define CTRADING_INPDATA_MQH_DECLARATION
    //+------------------------------------------------------------------+
    //| Modes of working with symbols                                    |
    //+------------------------------------------------------------------+
    enum ENUM_SYMBOLS_MODE
      {
        SYMBOLS_MODE_CURRENT      ,  // Work with the current symbol only
        SYMBOLS_MODE_DEFINES      ,  // Work with the specified symbol list
        SYMBOLS_MODE_MARKET_WATCH ,  // Work with the Market Watch window symbols
        SYMBOLS_MODE_ALL             // Work with the full symbol list
      };
    //+------------------------------------------------------------------+
  #endif // CTRADING_INPDATA_MQH_DECLARATION
#endif // COMPILE_EN

  #ifndef CTRADING_INPDATA_MQH_IMPLEMENTATION
  #define CTRADING_INPDATA_MQH_IMPLEMENTATION
    //+------------------------------------------------------------------+
  #endif // CTRADING_INPDATA_MQH_IMPLEMENTATION

#endif // __TRADING_INPDATA_MQH__