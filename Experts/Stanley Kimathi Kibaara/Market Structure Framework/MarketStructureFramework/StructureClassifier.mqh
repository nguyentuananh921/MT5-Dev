//+------------------------------------------------------------------+
//|                            StructureClassifier.mqh               |
//|                            Copyright 2026, MetaQuotes            |
//|                            https://www.mql5.com                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"

//+------------------------------------------------------------------+
//| Structure Classifier – Classifies a break as BOS or CHoCH        |
//+------------------------------------------------------------------+
class CStructureClassifier
  {
   public:
    ENUM_EVENT_TYPE   Classify(const SBreakEvent &breakEv,                                                               // the break event to classify
                              int trend,                                                                                // current trend: 1=bullish, -1=bearish, 0=neutral
                              ENUM_STRUCTURE_LEVEL level) const;                                                        // internal or external structure level
  };

//+------------------------------------------------------------------+
//| Classify a break event as BOS or CHoCH based on trend and level  |
//+------------------------------------------------------------------+
ENUM_EVENT_TYPE CStructureClassifier::Classify(const SBreakEvent &breakEv, int trend, ENUM_STRUCTURE_LEVEL level) const
  {
   bool isInternal = (level == LEVEL_INTERNAL); 
   //--- High break classification
   if(breakEv.isHighBreak)
     {
      if(trend == 1)                                                                                                    // bullish trend + high break → bullish continuation (BOS)
         return isInternal ? EVENT_INTERNAL_BOS_BULLISH : EVENT_EXTERNAL_BOS_BULLISH;
      else if(trend == -1)                                                                                              // bearish trend + high break → potential bullish reversal (CHoCH)
         return isInternal ? EVENT_INTERNAL_CHOCH_BULLISH : EVENT_EXTERNAL_CHOCH_BULLISH;
      else                                                                                                              // neutral trend → default to BOS (continuation assumption)
         return isInternal ? EVENT_INTERNAL_BOS_BULLISH : EVENT_EXTERNAL_BOS_BULLISH;
     }
   else                                                                                                                 // Low break classification
     {
      if(trend == -1)                                                                                                   // bearish trend + low break → bearish continuation (BOS)
         return isInternal ? EVENT_INTERNAL_BOS_BEARISH : EVENT_EXTERNAL_BOS_BEARISH;
      else if(trend == 1)                                                                                               // bullish trend + low break → potential bearish reversal (CHoCH)
         return isInternal ? EVENT_INTERNAL_CHOCH_BEARISH : EVENT_EXTERNAL_CHOCH_BEARISH;
      else                                                                                                              // neutral trend → default to BOS (continuation assumption)
         return isInternal ? EVENT_INTERNAL_BOS_BEARISH : EVENT_EXTERNAL_BOS_BEARISH;
     }
  }
//+------------------------------------------------------------------+