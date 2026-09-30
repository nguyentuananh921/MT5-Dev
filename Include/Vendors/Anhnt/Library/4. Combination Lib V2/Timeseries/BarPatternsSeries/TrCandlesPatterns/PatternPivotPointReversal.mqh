//+------------------------------------------------------------------+
//|                                 PatternPivotPointReversal.mqh    |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNPIVOTPOINTREVERSAL_MQH__
#define __PATTERNPIVOTPOINTREVERSAL_MQH__
 #include "..\BarPattern.mqh"
 #ifndef CPATTERNPIVOTPOINTREVERSAL_MQH_DECLARATION
 #define CPATTERNPIVOTPOINTREVERSAL_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Pivot Point Reversal pattern class (3-candle, middle is pivot)   |
  //+------------------------------------------------------------------+
  class CPatternPivotPointReversal : public CBarPattern
    {
      public:
                            CPatternPivotPointReversal(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                       MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNPIVOTPOINTREVERSAL_MQH_DECLARATION
  #ifndef CPATTERNPIVOTPOINTREVERSAL_MQH_IMPLEMENTATION
  #define CPATTERNPIVOTPOINTREVERSAL_MQH_IMPLEMENTATION
   CPatternPivotPointReversal::CPatternPivotPointReversal(const uint id, const string symbol,
                                                           const ENUM_TIMEFRAMES timeframe,
                                                           MqlRates &rates,
                                                           const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_PIVOT_POINT_REVERSAL, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Pivot Point Reversal");
      this.SetProperty(PATTERN_PROP_CANDLES, 3);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNPIVOTPOINTREVERSAL_MQH_IMPLEMENTATION
#endif // __PATTERNPIVOTPOINTREVERSAL_MQH__
