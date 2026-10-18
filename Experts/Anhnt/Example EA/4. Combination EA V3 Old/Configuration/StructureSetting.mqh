//+------------------------------------------------------------------+
//|                                              StructureSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __STRUCTURESETTING_MQH__
#define __STRUCTURESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\MarketStructureDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
//Inputs of the EA: the breaks of the market structure
 input group "=== Market Structure: Visual ==="
 input bool   InpShowBOS         = true ;               // Show the BoS
 input bool   InpShowCHoCH       = true ;               // Show the CHoCH
 input color  InpStructureBuyColor  = clrDodgerBlue;    // BOS / CHoCH up
 input color  InpStructureSellColor = clrRed;           // BOS / CHoCH down
#ifndef CSTRUCTURESETTING_MQH_DECLARATION
#define CSTRUCTURESETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The BOS / CHoCH settings of the EA. They are the inputs of the   |
 //| EA, so they are read-only here and change with the Inputs table: |
 //| the Show ones decide what CSmartMoneySync draws                  |
 //+------------------------------------------------------------------+
 class CStructureSetting : public CBaseObj
  {
   public:
     bool                    SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type) const;
   //--- The colour of a break: up (Buy) or down (Sell)
     color                   BuyColor(void)  const { return InpStructureBuyColor;  }
     color                   SellColor(void) const { return InpStructureSellColor; }
                             CStructureSetting(void) {}
  };
#endif // CSTRUCTURESETTING_MQH_DECLARATION
#ifndef CSTRUCTURESETTING_MQH_IMPLEMENTATION
#define CSTRUCTURESETTING_MQH_IMPLEMENTATION
 bool CStructureSetting::SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type) const
  {
   return (type==MARKET_STRUCTURE_BOS ? InpShowBOS : type==MARKET_STRUCTURE_CHOCH ? InpShowCHoCH : false);
  }
#endif // CSTRUCTURESETTING_MQH_IMPLEMENTATION
#endif // __STRUCTURESETTING_MQH__
