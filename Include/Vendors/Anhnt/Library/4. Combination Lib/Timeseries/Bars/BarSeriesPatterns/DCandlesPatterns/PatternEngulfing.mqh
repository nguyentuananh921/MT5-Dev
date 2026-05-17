//+------------------------------------------------------------------+
//|                                           PatternEngulfing.mqh   |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
// Pure data only - GUI code removed.
// Base class changed: CPattern -> CBarPattern
#ifndef __PATTERNENGULFING_MQH__
#define __PATTERNENGULFING_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Pattern.mqh"

 #ifndef CPATTERNENGULFING_MQH_DECLARATION
 #define CPATTERNENGULFING_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Engulfing pattern class (2-candle reversal, body covers body)    |
  //+------------------------------------------------------------------+
  class CPatternEngulfing : public CBarPattern
    {
      public:
        //--- Return the flag of the pattern supporting the specified property
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
        //--- Return description of the pattern (1) status and (2) type
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA);        }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_ENGULFING);   }
        //--- Constructor
                            CPatternEngulfing(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                              MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNENGULFING_MQH_DECLARATION
  #ifndef CPATTERNENGULFING_MQH_IMPLEMENTATION
  #define CPATTERNENGULFING_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CPatternEngulfing::CPatternEngulfing(const uint id, const string symbol,
                                         const ENUM_TIMEFRAMES timeframe,
                                         MqlRates &rates,
                                         const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_ENGULFING, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Engulfing");
      this.SetProperty(PATTERN_PROP_CANDLES, 2);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNENGULFING_MQH_IMPLEMENTATION
#endif // __PATTERNENGULFING_MQH__
