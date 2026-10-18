//+------------------------------------------------------------------+
//|                                                    FvgSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __FVGSETTING_MQH__
#define __FVGSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
//Inputs of the EA: the fair value gaps (FVG) of the momentum candles (what Python calculates is in MomentumCandleSetting.mqh)
 input group "=== Fair value gap (FVG): Visual ==="
 input bool   InpFvgShowBullish   = true;    // Draw bullish FVG
 input bool   InpFvgShowBearish   = true;    // Draw bearish FVG
 input bool   InpFvgShowDead      = false;   // Draw FVG that are filled (grey)
 input int    InpFvgMaxDead       = 5;       // Filled FVG kept (0 = all)
 input color  InpFvgBullishColor  = clrTeal;           // Bullish FVG outline colour (a blue green, next to the green of the demand zone it touches)
 input color  InpFvgBearishColor  = clrMediumVioletRed; // Bearish FVG outline colour (a magenta, next to the red of the supply zone it touches)
 input color  InpFvgDeadColor     = clrGray;        // Filled FVG colour
 input int    InpFvgOpenNewestBullish = 3;          // Newest bullish FVG shown from the start (the others are folded)
 input int    InpFvgOpenNewestBearish = 3;          // Newest bearish FVG shown from the start (the others are folded)
#ifndef CFVGSETTING_MQH_DECLARATION
#define CFVGSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The FVG settings of the EA. They are the inputs of the EA, so    |
 //| they are read-only here; they are read by CLifecycleSync (a      |
 //| bullish FVG is a Buy one, a bearish FVG a Sell one)              |
 //+------------------------------------------------------------------+
 class CFvgSetting : public CBaseObj
  {
   public:
     bool              ShowBullish(void) const { return InpFvgShowBullish; }
     bool              ShowBearish(void) const { return InpFvgShowBearish; }
     bool              ShowDead(void)    const { return InpFvgShowDead;    }
     int               MaxDead(void)     const { return InpFvgMaxDead;     }
     int               OpenNewestBullish(void) const { return InpFvgOpenNewestBullish; }
     int               OpenNewestBearish(void) const { return InpFvgOpenNewestBearish; }
     color             BullishColor(void) const { return InpFvgBullishColor; }
     color             BearishColor(void) const { return InpFvgBearishColor; }
     color             DeadColor(void)    const { return InpFvgDeadColor;    }
                       CFvgSetting(void) {}
  };
#endif // CFVGSETTING_MQH_DECLARATION
#endif // __FVGSETTING_MQH__
