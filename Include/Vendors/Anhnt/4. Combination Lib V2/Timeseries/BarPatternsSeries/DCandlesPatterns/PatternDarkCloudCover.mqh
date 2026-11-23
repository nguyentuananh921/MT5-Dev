//+------------------------------------------------------------------+
//|                                      PatternDarkCloudCover.mqh   |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNDARKCLOUDCOVER_MQH__
#define __PATTERNDARKCLOUDCOVER_MQH__
 #include "..\BarPattern.mqh"
 #ifndef CPATTERNDARKCLOUDCOVER_MQH_DECLARATION
 #define CPATTERNDARKCLOUDCOVER_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Dark Cloud Cover pattern class (2-candle bearish reversal)       |
  //+------------------------------------------------------------------+
  class CPatternDarkCloudCover : public CBarPattern
    {
      public:
                            CPatternDarkCloudCover(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                   MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNDARKCLOUDCOVER_MQH_DECLARATION
  #ifndef CPATTERNDARKCLOUDCOVER_MQH_IMPLEMENTATION
  #define CPATTERNDARKCLOUDCOVER_MQH_IMPLEMENTATION
   CPatternDarkCloudCover::CPatternDarkCloudCover(const uint id, const string symbol,
                                                   const ENUM_TIMEFRAMES timeframe,
                                                   MqlRates &rates,
                                                   const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_DARK_CLOUD_COVER, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Dark Cloud Cover");
      this.SetProperty(PATTERN_PROP_CANDLES, 2);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNDARKCLOUDCOVER_MQH_IMPLEMENTATION
#endif // __PATTERNDARKCLOUDCOVER_MQH__
