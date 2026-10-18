//+------------------------------------------------------------------+
//|                                            SupplyDemandSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __SUPPLYDEMANDSETTING_MQH__
#define __SUPPLYDEMANDSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
//Inputs of the EA: the supply and demand zones of the momentum candles (what Python calculates is in MomentumSetting.mqh)
 input group "=== Supply / Demand zones: Visual ==="
 input bool   InpSupplyDemandShowDemand = true;   // Draw demand zones
 input bool   InpSupplyDemandShowSupply = true;   // Draw supply zones
 input bool   InpSupplyDemandShowDead   = true;   // Draw dead zones (grey)
 input int    InpSupplyDemandMaxDead    = 20;     // Dead zones kept (0 = all)
 input color  InpSupplyDemandDemandColor = clrLimeGreen;   // Demand colour
 input color  InpSupplyDemandSupplyColor = clrTomato;          // Supply colour
 input color  InpSupplyDemandDeadColor   = clrGray;             // Dead zone colour
 input int    InpSupplyDemandOpenNewestDemand = 3;           // Newest demand zones shown from the start (the others are folded)
 input int    InpSupplyDemandOpenNewestSupply = 3;           // Newest supply zones shown from the start (the others are folded)
#ifndef CSUPPLYDEMANDSETTING_MQH_DECLARATION
#define CSUPPLYDEMANDSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The supply / demand zone settings of the EA. They are the inputs |
 //| of the EA, so they are read-only here; they are read by          |
 //| CLifecycleSync (a Demand zone is a Buy one, a Supply zone a Sell)|
 //+------------------------------------------------------------------+
 class CSupplyDemandSetting : public CBaseObj
  {
   public:
     bool              ShowDemand(void) const { return InpSupplyDemandShowDemand; }
     bool              ShowSupply(void) const { return InpSupplyDemandShowSupply; }
     bool              ShowDead(void)   const { return InpSupplyDemandShowDead;   }
     int               MaxDead(void)    const { return InpSupplyDemandMaxDead;    }
     int               OpenNewestDemand(void) const { return InpSupplyDemandOpenNewestDemand; }
     int               OpenNewestSupply(void) const { return InpSupplyDemandOpenNewestSupply; }
     color             DemandColor(void) const { return InpSupplyDemandDemandColor; }
     color             SupplyColor(void) const { return InpSupplyDemandSupplyColor; }
     color             DeadColor(void)   const { return InpSupplyDemandDeadColor;   }
                       CSupplyDemandSetting(void) {}
  };
#endif // CSUPPLYDEMANDSETTING_MQH_DECLARATION
#endif // __SUPPLYDEMANDSETTING_MQH__
