//+------------------------------------------------------------------+
//|                                       PatternSpinningTop.mqh    |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNSPINNINGTOP_MQH__
#define __PATTERNSPINNINGTOP_MQH__
 #include "..\BarPattern.mqh"
 #ifndef CSPINNINGTOP_MQH_DECLARATION
 #define CSPINNINGTOP_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Spinning Top (1-candle indecision: small body, both shadows long) |
  //+------------------------------------------------------------------+
  class CPatternSpinningTop : public CBarPattern
    {
      public:
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA); }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_SPINNING_TOP);              }
                            CPatternSpinningTop(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                   MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CSPINNINGTOP_MQH_DECLARATION
  #ifndef CSPINNINGTOP_MQH_IMPLEMENTATION
  #define CSPINNINGTOP_MQH_IMPLEMENTATION
   CPatternSpinningTop::CPatternSpinningTop(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                    MqlRates &rates, const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_SPINNING_TOP, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Spinning Top");
      this.SetProperty(PATTERN_PROP_CANDLES, 1);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CSPINNINGTOP_MQH_IMPLEMENTATION
#endif // __PATTERNSPINNINGTOP_MQH__
