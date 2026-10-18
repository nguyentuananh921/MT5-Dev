//+------------------------------------------------------------------+
//|                                          MomentumCandleSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __MOMENTUMCANDLESETTING_MQH__
#define __MOMENTUMCANDLESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
//Inputs of the EA: the momentum candles (a body bigger than a multiple of the biggest body before it)
 input group "=== Momentum candle: Calculation ==="
 input int    InpMomentumCandleBars       = 3;     // Candles before it
 input double InpMomentumCandleMultiplier = 2.0;   // Body bigger than biggest body before 
 input group "=== Momentum candle: Visual ==="
 input bool   InpMomentumCandleShow       = true;  // Show the momentum candle markers
 input color  InpMomentumCandleBuyColor   = clrDodgerBlue;    // Momentum candle up colour
 input color  InpMomentumCandleSellColor  = clrRed;  // Momentum candle down colour
#ifndef CMOMENTUMCANDLESETTING_MQH_DECLARATION
#define CMOMENTUMCANDLESETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The momentum candle settings of the EA. They are the inputs of   |
 //| the EA, so they are read-only here: the calculation ones go to   |
 //| Python (Json, in the init message; the supply / demand zones use |
 //| them too), the visual ones are read by CSmartMoneySync           |
 //+------------------------------------------------------------------+
 class CMomentumCandleSetting : public CBaseObj
  {
   public:
     bool              Show(void)       const { return InpMomentumCandleShow;      }
     color             BuyColor(void)   const { return InpMomentumCandleBuyColor;  }
     color             SellColor(void)  const { return InpMomentumCandleSellColor; }
   //--- What Python calculates, as a JSON object
     string            Json(void) const;
                       CMomentumCandleSetting(void) {}
  };
#endif // CMOMENTUMCANDLESETTING_MQH_DECLARATION
#ifndef CMOMENTUMCANDLESETTING_MQH_IMPLEMENTATION
#define CMOMENTUMCANDLESETTING_MQH_IMPLEMENTATION
 string CMomentumCandleSetting::Json(void) const
  {
   return ::StringFormat("{\"multiplier\":%.4f,\"bars\":%d}",(InpMomentumCandleMultiplier<0.0 ? 0.0 : InpMomentumCandleMultiplier),(InpMomentumCandleBars<1 ? 1 : InpMomentumCandleBars));
  }
#endif // CMOMENTUMCANDLESETTING_MQH_IMPLEMENTATION
#endif // __MOMENTUMCANDLESETTING_MQH__
