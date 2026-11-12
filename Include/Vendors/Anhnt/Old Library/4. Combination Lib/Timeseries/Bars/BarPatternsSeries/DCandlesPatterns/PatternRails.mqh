//+------------------------------------------------------------------+
//|                                               PatternRails.mqh   |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNRAILS_MQH__
#define __PATTERNRAILS_MQH__
 #include "..\BarPattern.mqh"
 #ifndef CPATTERNRAILS_MQH_DECLARATION
 #define CPATTERNRAILS_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Rails pattern class (2 opposite large candles of similar size)   |
  //+------------------------------------------------------------------+
  class CPatternRails : public CBarPattern
    {
      public:
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA);   }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_RAILS);  }
                            CPatternRails(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                          MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNRAILS_MQH_DECLARATION
  #ifndef CPATTERNRAILS_MQH_IMPLEMENTATION
  #define CPATTERNRAILS_MQH_IMPLEMENTATION
   CPatternRails::CPatternRails(const uint id, const string symbol,
                                 const ENUM_TIMEFRAMES timeframe,
                                 MqlRates &rates,
                                 const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_RAILS, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Rails");
      this.SetProperty(PATTERN_PROP_CANDLES, 2);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNRAILS_MQH_IMPLEMENTATION
#endif // __PATTERNRAILS_MQH__
