//+------------------------------------------------------------------+
//|                                         PatternPiercingLine.mqh  |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNPIERCINGLINE_MQH__
#define __PATTERNPIERCINGLINE_MQH__
 #include "..\Pattern.mqh"
 #ifndef CPATTERNPIERCINGLINE_MQH_DECLARATION
 #define CPATTERNPIERCINGLINE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Piercing Line pattern class (2-candle bullish reversal)          |
  //+------------------------------------------------------------------+
  class CPatternPiercingLine : public CBarPattern
    {
      public:
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA);           }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_PIERCING_LINE);  }
                            CPatternPiercingLine(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                 MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNPIERCINGLINE_MQH_DECLARATION
  #ifndef CPATTERNPIERCINGLINE_MQH_IMPLEMENTATION
  #define CPATTERNPIERCINGLINE_MQH_IMPLEMENTATION
   CPatternPiercingLine::CPatternPiercingLine(const uint id, const string symbol,
                                               const ENUM_TIMEFRAMES timeframe,
                                               MqlRates &rates,
                                               const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_PIERCING_LINE, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Piercing Line");
      this.SetProperty(PATTERN_PROP_CANDLES, 2);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNPIERCINGLINE_MQH_IMPLEMENTATION
#endif // __PATTERNPIERCINGLINE_MQH__
