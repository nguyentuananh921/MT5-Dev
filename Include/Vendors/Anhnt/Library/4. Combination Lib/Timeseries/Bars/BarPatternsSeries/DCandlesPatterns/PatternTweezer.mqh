//+------------------------------------------------------------------+
//|                                            PatternTweezer.mqh    |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNTWEEZER_MQH__
#define __PATTERNTWEEZER_MQH__
 #include "..\BarPattern.mqh"
 #ifndef CPATTERNTWEEZER_MQH_DECLARATION
 #define CPATTERNTWEEZER_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Tweezer pattern class (2-candle, matching High or Low)           |
  //+------------------------------------------------------------------+
  class CPatternTweezer : public CBarPattern
    {
      public:
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA);      }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_TWEEZER);   }
                            CPatternTweezer(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                            MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNTWEEZER_MQH_DECLARATION
  #ifndef CPATTERNTWEEZER_MQH_IMPLEMENTATION
  #define CPATTERNTWEEZER_MQH_IMPLEMENTATION
   CPatternTweezer::CPatternTweezer(const uint id, const string symbol,
                                     const ENUM_TIMEFRAMES timeframe,
                                     MqlRates &rates,
                                     const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_TWEEZER, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Tweezer");
      this.SetProperty(PATTERN_PROP_CANDLES, 2);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNTWEEZER_MQH_IMPLEMENTATION
#endif // __PATTERNTWEEZER_MQH__
