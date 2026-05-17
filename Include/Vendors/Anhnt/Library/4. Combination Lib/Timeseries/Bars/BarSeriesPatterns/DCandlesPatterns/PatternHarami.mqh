//+------------------------------------------------------------------+
//|                                               PatternHarami.mqh  |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
// Pure data only - GUI code removed.
// Base class changed: CPattern -> CBarPattern
#ifndef __PATTERNHARAMI_MQH__
#define __PATTERNHARAMI_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Pattern.mqh"

 #ifndef CPATTERNHARAMI_MQH_DECLARATION
 #define CPATTERNHARAMI_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Harami pattern class (2-candle reversal, body inside body)       |
  //+------------------------------------------------------------------+
  class CPatternHarami : public CBarPattern
    {
      public:
        //--- Return the flag of the pattern supporting the specified property
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
        //--- Return description of the pattern (1) status and (2) type
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA);    }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_HARAMI);  }
        //--- Constructor
                            CPatternHarami(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                           MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNHARAMI_MQH_DECLARATION
  #ifndef CPATTERNHARAMI_MQH_IMPLEMENTATION
  #define CPATTERNHARAMI_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CPatternHarami::CPatternHarami(const uint id, const string symbol,
                                   const ENUM_TIMEFRAMES timeframe,
                                   MqlRates &rates,
                                   const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_HARAMI, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Harami");
      this.SetProperty(PATTERN_PROP_CANDLES, 2);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNHARAMI_MQH_IMPLEMENTATION
#endif // __PATTERNHARAMI_MQH__
