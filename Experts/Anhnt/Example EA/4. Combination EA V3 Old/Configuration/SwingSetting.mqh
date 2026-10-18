//+------------------------------------------------------------------+
//|                                                  SwingSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __SWINGSETTING_MQH__
#define __SWINGSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\MarketStructureDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
//Inputs of the EA: the Swings
 input group "=== Swing Calculation==="
 input int    InpSwingStrength   = 5;       // Swing: Bars for detection
 input bool   InpSwingUseWick    = true;    // Swing: Use wicks
input group "=== Swing Visual===" 
 input bool   InpShowSwingHigh   = true ;   // Show the Swing Highs
 input bool   InpShowSwingLow    = true ;   // Show the Swing Lows
 input color  InpSwingHighColor   = clrRed;          // Swing High
 input color  InpSwingLowColor    = clrDodgerBlue;   // Swing Low
#ifndef CSWINGSETTING_MQH_DECLARATION
#define CSWINGSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The Swing settings of the EA. They are the inputs of the EA, so  |
 //| they are read-only here and change with the Inputs table: the    |
 //| detection ones go to Python (the init message), the Show ones    |
 //| decide what CSmartMoneySync draws                                |
 //+------------------------------------------------------------------+
 class CSwingSetting : public CBaseObj
  {
   public:
     int                     Strength(void)   const { return (InpSwingStrength<1 ? 1 : InpSwingStrength); }
     ENUM_SWING_PRICE_BASIS  PriceBasis(void) const { return (InpSwingUseWick ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY); }
     bool                    SignalShow(const ENUM_SWING_TYPE type) const;
   //--- The colour of a Swing: a High is marked above the candle, a Low below it
     color                   Colour(const ENUM_SWING_TYPE type) const { return (type==SWING_TYPE_LOW ? InpSwingLowColor : InpSwingHighColor); }
                             CSwingSetting(void) {}
  };
#endif // CSWINGSETTING_MQH_DECLARATION
#ifndef CSWINGSETTING_MQH_IMPLEMENTATION
#define CSWINGSETTING_MQH_IMPLEMENTATION
 bool CSwingSetting::SignalShow(const ENUM_SWING_TYPE type) const
  {
   return (type==SWING_TYPE_HIGH ? InpShowSwingHigh : type==SWING_TYPE_LOW ? InpShowSwingLow : false);
  }
#endif // CSWINGSETTING_MQH_IMPLEMENTATION
#endif // __SWINGSETTING_MQH__
