//+------------------------------------------------------------------+
//|                                              PatternGravestoneDoji.mqh    |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNGRAVESTONEDOJI_MQH__
#define __PATTERNGRAVESTONEDOJI_MQH__
 #include "..\Pattern.mqh"
 #ifndef CGRAVESTONEDOJI_MQH_DECLARATION
 #define CGRAVESTONEDOJI_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Gravestone Doji (1-candle bearish)                    |
  //+------------------------------------------------------------------+
  class CPatternGravestoneDoji : public CBarPattern
    {
      public:
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA); }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_GRAVESTONE_DOJI);                          }
                            CPatternGravestoneDoji(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                   MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CGRAVESTONEDOJI_MQH_DECLARATION
  #ifndef CGRAVESTONEDOJI_MQH_IMPLEMENTATION
  #define CGRAVESTONEDOJI_MQH_IMPLEMENTATION
   CPatternGravestoneDoji::CPatternGravestoneDoji(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                    MqlRates &rates, const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_GRAVESTONE_DOJI, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "GravestoneDoji");
      this.SetProperty(PATTERN_PROP_CANDLES, 1);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CGRAVESTONEDOJI_MQH_IMPLEMENTATION
#endif // __PATTERNGRAVESTONEDOJI_MQH__
