//+------------------------------------------------------------------+
//|                                 BreakDetector.mqh                |
//|                                 Copyright 2026, MetaQuotes       |
//|                                 https://www.mql5.com             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"

//+------------------------------------------------------------------+
//| Break Detector – checks whether a bar has broken a protected     |
//| high or a protected low and returns a full break event           |
//+------------------------------------------------------------------+
class CBreakDetector
  {
   public:
    bool              CheckBar(datetime barTime,                       // timestamp of the bar being checked
                              double   barHigh,                       // high of the bar
                              double   barLow,                        // low of the bar
                              double   barClose,                      // close of the bar
                              const SProtectedLevel &protHigh,        // current protected high (may be invalid)
                              const SProtectedLevel &protLow,         // current protected low (may be invalid)
                              double   atr,                           // current ATR value for normalization
                              SBreakEvent &outEvent) const;           // output structure filled when a break occurs
  };

//+------------------------------------------------------------------+
//| Check bar for a break of a protected high or low level           |
//+------------------------------------------------------------------+
bool CBreakDetector::CheckBar(datetime barTime,
                              double   barHigh,
                              double   barLow,
                              double   barClose,
                              const SProtectedLevel &protHigh,
                              const SProtectedLevel &protLow,
                              double   atr,
                              SBreakEvent &outEvent) const
  {
   //--- protected high exists and the bar's high exceeds it
   if(protHigh.isValid && barHigh > protHigh.price)
     {
      outEvent.time         = barTime;                                          // time of the break
      outEvent.price        = protHigh.price;                                   // the broken level's price
      outEvent.isHighBreak  = true;                                             // flag as a high break
      outEvent.isCloseBeyond = (barClose > protHigh.price);                     // true if the bar closed beyond the level
      outEvent.distanceATR  = (atr > 0) ? (barHigh - protHigh.price) / atr : 0; //break distance measured in ATR
      return true;                                                              // break detected
     }

   //--- protected low exists and the bar's low falls below it
   if(protLow.isValid && barLow < protLow.price)
     {
      outEvent.time         = barTime;
      outEvent.price        = protLow.price;
      outEvent.isHighBreak  = false;                                             // flag as a low break
      outEvent.isCloseBeyond = (barClose < protLow.price);                       // close beyond the level
      outEvent.distanceATR  = (atr > 0) ? (protLow.price - barLow) / atr : 0;
      return true;
     }

   return false;                                                                 // no break on this bar
  }
//+------------------------------------------------------------------+