//+------------------------------------------------------------------+
//|                                       PatternThreeBlackCrows.mqh |
//|                           Copyright 2023, MetaQuotes Ltd.        |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict    // Necessary for mql4
// Pure data only - GUI code removed.
// Base class changed: CPattern -> CBarPattern
#ifndef __PATTERNTHREEBLACKCROWS_MQH__
#define __PATTERNTHREEBLACKCROWS_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\BarPattern.mqh"

 #ifndef CPATTERNTHREEBLACKCROWS_MQH_DECLARATION
 #define CPATTERNTHREEBLACKCROWS_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Three Black Crows pattern class (3-candle bearish continuation)  |
  //+------------------------------------------------------------------+
  class CPatternThreeBlackCrows : public CBarPattern
    {
      public:
        //--- Return the flag of the pattern supporting the specified property
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_INTEGER property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property) { return true; }
          virtual bool      SupportProperty(ENUM_PATTERN_PROP_STRING  property) { return true; }
        //--- Return description of the pattern (1) status and (2) type
          virtual string    StatusDescription(void) const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_STATUS_PA);               }
          virtual string    TypeDescription(void)   const { return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_THREE_BLACK_CROWS);  }
        //--- Constructor
                            CPatternThreeBlackCrows(const uint id, const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                    MqlRates &rates, const ENUM_PATTERN_DIRECTION direct);
    };
  #endif // CPATTERNTHREEBLACKCROWS_MQH_DECLARATION
  #ifndef CPATTERNTHREEBLACKCROWS_MQH_IMPLEMENTATION
  #define CPATTERNTHREEBLACKCROWS_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CPatternThreeBlackCrows::CPatternThreeBlackCrows(const uint id, const string symbol,
                                                    const ENUM_TIMEFRAMES timeframe,
                                                    MqlRates &rates,
                                                    const ENUM_PATTERN_DIRECTION direct) :
    CBarPattern(PATTERN_STATUS_PA, PATTERN_TYPE_THREE_BLACK_CROWS, id, direct, symbol, timeframe, rates)
    {
      this.SetProperty(PATTERN_PROP_NAME,    "Three Black Crows");
      this.SetProperty(PATTERN_PROP_CANDLES, 3);
      this.m_bars_formation = (int)this.GetProperty(PATTERN_PROP_CANDLES);
    }
  #endif // CPATTERNTHREEBLACKCROWS_MQH_IMPLEMENTATION
#endif // __PATTERNTHREEBLACKCROWS_MQH__
