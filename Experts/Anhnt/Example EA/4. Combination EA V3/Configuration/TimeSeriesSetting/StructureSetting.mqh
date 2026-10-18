//+------------------------------------------------------------------+
//|                                              StructureSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __STRUCTURESETTING_MQH__
#define __STRUCTURESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\MarketStructureDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Market structure (BOS / CHoCH))
#ifndef CSTRUCTURESETTING_MQH_DECLARATION
#define CSTRUCTURESETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The BOS / CHoCH settings of the EA. They are the inputs of the   |
 //| EA, so they are read-only here and change with the Inputs table: |
 //| the Show ones decide what CSmartMoneySync draws                  |
 //+------------------------------------------------------------------+
 class CStructureSetting : public CBaseObj
  {
   private:
     bool                    m_show_bos;      // the BoS are drawn: the input at the start, the Smart Money tab changes it
     bool                    m_show_choch;    // the CHoCH are drawn
   public:
     bool                    SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type) const;
     void                    SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type,const bool show);
   //--- The colour of a break: up (Buy) or down (Sell)
     color                   BuyColor(void)  const { return InpStructureBuyColor;  }
     color                   SellColor(void) const { return InpStructureSellColor; }
                             CStructureSetting(void) : m_show_bos(InpShowBOS),m_show_choch(InpShowCHoCH) {}
  };
#endif // CSTRUCTURESETTING_MQH_DECLARATION
#ifndef CSTRUCTURESETTING_MQH_IMPLEMENTATION
#define CSTRUCTURESETTING_MQH_IMPLEMENTATION
 bool CStructureSetting::SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type) const
  {
   return (type==MARKET_STRUCTURE_BOS ? m_show_bos : type==MARKET_STRUCTURE_CHOCH ? m_show_choch : false);
  }
 void CStructureSetting::SignalShow(const ENUM_MARKET_STRUCTURE_TYPE type,const bool show)
  {
   if(type==MARKET_STRUCTURE_BOS)
      m_show_bos=show;
   else if(type==MARKET_STRUCTURE_CHOCH)
      m_show_choch=show;
  }
#endif // CSTRUCTURESETTING_MQH_IMPLEMENTATION
#endif // __STRUCTURESETTING_MQH__
