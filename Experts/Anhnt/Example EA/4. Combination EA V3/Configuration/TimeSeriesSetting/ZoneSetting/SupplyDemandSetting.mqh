//+------------------------------------------------------------------+
//|                                            SupplyDemandSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __SUPPLYDEMANDSETTING_MQH__
#define __SUPPLYDEMANDSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Supply / Demand zone)
#ifndef CSUPPLYDEMANDSETTING_MQH_DECLARATION
#define CSUPPLYDEMANDSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The supply / demand zone settings of the EA. They are the inputs |
 //| of the EA, so they are read-only here; they are read by          |
 //| CLifecycleSync (a Demand zone is a Buy one, a Supply zone a Sell)|
 //+------------------------------------------------------------------+
 class CSupplyDemandSetting : public CBaseObj
  {
   private:
     bool              m_show_demand;    // the inputs at the start, the Smart Money tab changes them
     bool              m_show_supply;
     bool              m_show_dead;
     int               m_max_dead;
     int               m_open_newest_demand;   // the newest zones shown from the start, the others are folded
     int               m_open_newest_supply;
   public:
     bool              ShowDemand(void) const { return m_show_demand; }
     void              ShowDemand(const bool on)                 { m_show_demand=on; }
     bool              ShowSupply(void) const { return m_show_supply; }
     void              ShowSupply(const bool on)                 { m_show_supply=on; }
     bool              ShowDead(void)   const { return m_show_dead;   }
     void              ShowDead(const bool on)                   { m_show_dead=on;   }
     int               MaxDead(void)    const { return m_max_dead;    }
     void              MaxDead(const int count)                  { m_max_dead=(count<0 ? 0 : count); }
     int               OpenNewestDemand(void) const { return m_open_newest_demand; }
     void              OpenNewestDemand(const int count)         { m_open_newest_demand=(count<0 ? 0 : count); }
     int               OpenNewestSupply(void) const { return m_open_newest_supply; }
     void              OpenNewestSupply(const int count)         { m_open_newest_supply=(count<0 ? 0 : count); }
     color             DemandColor(void) const { return InpSupplyDemandDemandColor; }
     color             SupplyColor(void) const { return InpSupplyDemandSupplyColor; }
     color             DeadColor(void)   const { return InpSupplyDemandDeadColor;   }
                       CSupplyDemandSetting(void) : m_show_demand(InpSupplyDemandShowDemand),m_show_supply(InpSupplyDemandShowSupply),m_show_dead(InpSupplyDemandShowDead),m_max_dead(InpSupplyDemandMaxDead),m_open_newest_demand(InpSupplyDemandOpenNewestDemand),m_open_newest_supply(InpSupplyDemandOpenNewestSupply) {}
  };
#endif // CSUPPLYDEMANDSETTING_MQH_DECLARATION
#endif // __SUPPLYDEMANDSETTING_MQH__
