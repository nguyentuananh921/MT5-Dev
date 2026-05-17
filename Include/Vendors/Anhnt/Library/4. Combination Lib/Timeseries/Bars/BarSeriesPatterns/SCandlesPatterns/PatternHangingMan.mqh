//+------------------------------------------------------------------+
//|                                              PatternHangingMan.mqh    |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNHANGINGMAN_MQH__
#define __PATTERNHANGINGMAN_MQH__
 #include "..\Pattern.mqh"
 #ifndef CHANGINGMAN_MQH_DECLARATION
 #define CHANGINGMAN_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Hanging Man (1-candle bearish reversal)                    |
  //+------------------------------------------------------------------+
  class CPatternHangingMan : public CBarPattern
    {
      public:
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA); }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_HANGING_MAN);                          }
                            CPatternHangingMan(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                   MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CHANGINGMAN_MQH_DECLARATION
  #ifndef CHANGINGMAN_MQH_IMPLEMENTATION
  #define CHANGINGMAN_MQH_IMPLEMENTATION
   CPatternHangingMan::CPatternHangingMan(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                    MqlRates &rates, const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_HANGING_MAN, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "HangingMan");
      this.SetProperty(PATTERN_PROP_CANDLES, 1);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CHANGINGMAN_MQH_IMPLEMENTATION
#endif // __PATTERNHANGINGMAN_MQH__
