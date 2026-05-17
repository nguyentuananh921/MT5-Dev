//+------------------------------------------------------------------+
//|                                              PatternShootingStar.mqh    |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __PATTERNSHOOTINGSTAR_MQH__
#define __PATTERNSHOOTINGSTAR_MQH__
 #include "..\Pattern.mqh"
 #ifndef CSHOOTINGSTAR_MQH_DECLARATION
 #define CSHOOTINGSTAR_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Shooting Star (1-candle bearish reversal)                    |
  //+------------------------------------------------------------------+
  class CPatternShootingStar : public CBarPattern
    {
      public:
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA); }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_SHOOTING_STAR);                          }
                            CPatternShootingStar(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                   MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CSHOOTINGSTAR_MQH_DECLARATION
  #ifndef CSHOOTINGSTAR_MQH_IMPLEMENTATION
  #define CSHOOTINGSTAR_MQH_IMPLEMENTATION
   CPatternShootingStar::CPatternShootingStar(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                    MqlRates &rates, const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_SHOOTING_STAR, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "ShootingStar");
      this.SetProperty(PATTERN_PROP_CANDLES, 1);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CSHOOTINGSTAR_MQH_IMPLEMENTATION
#endif // __PATTERNSHOOTINGSTAR_MQH__
