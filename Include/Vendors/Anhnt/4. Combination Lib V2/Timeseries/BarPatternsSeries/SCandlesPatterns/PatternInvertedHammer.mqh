//+------------------------------------------------------------------+
//|                                              PatternInvertedHammer.mqh    |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNINVERTEDHAMMER_MQH__
#define __PATTERNINVERTEDHAMMER_MQH__
 #include "..\BarPattern.mqh"
 #ifndef CINVERTEDHAMMER_MQH_DECLARATION
 #define CINVERTEDHAMMER_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Inverted Hammer (1-candle bullish)                    |
  //+------------------------------------------------------------------+
  class CPatternInvertedHammer : public CBarPattern
    {
      public:
                            CPatternInvertedHammer(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                   MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CINVERTEDHAMMER_MQH_DECLARATION
  #ifndef CINVERTEDHAMMER_MQH_IMPLEMENTATION
  #define CINVERTEDHAMMER_MQH_IMPLEMENTATION
   CPatternInvertedHammer::CPatternInvertedHammer(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                    MqlRates &rates, const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_INVERTED_HAMMER, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "InvertedHammer");
      this.SetProperty(PATTERN_PROP_CANDLES, 1);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CINVERTEDHAMMER_MQH_IMPLEMENTATION
#endif // __PATTERNINVERTEDHAMMER_MQH__
