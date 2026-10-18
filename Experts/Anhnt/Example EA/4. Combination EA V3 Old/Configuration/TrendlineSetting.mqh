//+------------------------------------------------------------------+
//|                                              TrendlineSetting.mqh |
//+------------------------------------------------------------------+
#ifndef __TRENDLINESETTING_MQH__
#define __TRENDLINESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
//Inputs of the EA: the Trendline part of the Inputs table
 input group "=== Trendline: Calculation ==="
 input double InpTrendlineConfirmATR     = 1.0;    // ATRs beyond the line = a break
 input int    InpTrendlineConfirmCloses  = 2;      // Closes in a row to confirm
 input double InpTrendlineMinMoveATR     = 0.2;    // Min anchor move (ATR)
 input double InpTrendlineMinSwingATR    = 0.8;    // Min swing size (ATR, 0 = off)
 input int    InpTrendlineSwingsTried    = 50;     // Swings joined to a new swing
 input group "=== Trendline: Visual ==="
 input bool   InpTrendlineShowSupport    = false;   // Draw supports
 input bool   InpTrendlineShowResistance = false;   // Draw resistances
 input bool   InpTrendlineShowDead       = false;   // Draw dead lines (grey)
 input int    InpTrendlineMaxDead        = 20;     // Dead lines kept (0 = all)
 input int    InpTrendlineNearest        = 3;      // Living lines per side drawn solid (the nearest to the price)
 input color  InpTrendlineSupportColor    = clrDodgerBlue; // Support
 input color  InpTrendlineResistanceColor = clrRed;        // Resistance
 input color  InpTrendlineDeadColor       = clrGray;       // Dead line colour
#ifndef CTRENDLINESETTING_MQH_DECLARATION
#define CTRENDLINESETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The Trendline settings of the EA. They are the inputs of the EA, |
 //| so they are read-only here and change with the Inputs table:     |
 //| the calculation ones go to Python (Json, in the init message),   |
 //| the drawing ones are read by CLifecycleSync                      |
 //+------------------------------------------------------------------+
 class CTrendlineSetting : public CBaseObj
  {
   public:
   //--- What is drawn
     bool              ShowSupport(void)     const { return InpTrendlineShowSupport;    }
     bool              ShowResistance(void)  const { return InpTrendlineShowResistance; }
     bool              ShowDead(void)        const { return InpTrendlineShowDead;       }
     int               MaxDead(void)         const { return InpTrendlineMaxDead;        }
     int               Nearest(void)         const { return InpTrendlineNearest;        }
     color             SupportColor(void)    const { return InpTrendlineSupportColor;    }   // clrNONE = blue / red
     color             ResistanceColor(void) const { return InpTrendlineResistanceColor; }
     color             DeadColor(void)       const { return InpTrendlineDeadColor;       }
   //--- What Python calculates, as a JSON object
     string            Json(void) const;
                       CTrendlineSetting(void) {}
  };
#endif // CTRENDLINESETTING_MQH_DECLARATION
#ifndef CTRENDLINESETTING_MQH_IMPLEMENTATION
#define CTRENDLINESETTING_MQH_IMPLEMENTATION
 string CTrendlineSetting::Json(void) const
  {
   return ::StringFormat("{\"confirm_atr\":%.4f,\"confirm_closes\":%d,\"min_move_atr\":%.4f,\"min_swing_atr\":%.4f,\"n_swings\":%d}",
                         InpTrendlineConfirmATR,InpTrendlineConfirmCloses,
                         (InpTrendlineMinMoveATR<0.0 ? 0.0 : InpTrendlineMinMoveATR),(InpTrendlineMinSwingATR<0.0 ? 0.0 : InpTrendlineMinSwingATR),
                         (InpTrendlineSwingsTried<2 ? 2 : InpTrendlineSwingsTried));
  }
#endif // CTRENDLINESETTING_MQH_IMPLEMENTATION
#endif // __TRENDLINESETTING_MQH__
