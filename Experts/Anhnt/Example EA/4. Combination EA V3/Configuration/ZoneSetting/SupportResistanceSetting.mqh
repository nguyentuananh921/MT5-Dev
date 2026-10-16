//+------------------------------------------------------------------+
//|                                       SupportResistanceSetting.mqh |
//+------------------------------------------------------------------+
#ifndef __SUPPORTRESISTANCESETTING_MQH__
#define __SUPPORTRESISTANCESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
//Inputs of the EA: the Support / Resistance zones (the ones of the swings; the supply / demand zones of the momentum candles are in SupplyDemandSetting.mqh)
 input group "=== Support / Resistance zone: Calculation ==="
 input int    InpSupportResistanceMinScore       = 50;     // Min quality score (0-100)
 input int    InpSupportResistanceConfirmCloses  = 2;      // Closes in a row to confirm
 input int    InpSupportResistanceGhostBars      = 10;     // Bars a broken zone waits
 input bool   InpSupportResistanceRevive         = true;   // Broken zone may come back
 input int    InpSupportResistanceMaxAgeBars     = 500;    // Bars a zone lives
 input int    InpSupportResistanceVolumeMABars   = 14;     // Volume MA bars (the volume of the swing against its MA)
 input group "=== Support / Resistance zone: Visual ==="
 input bool   InpSupportResistanceShowSupport    = false;   // Draw support zones
 input bool   InpSupportResistanceShowResistance = false;   // Draw resistance zones
 input bool   InpSupportResistanceShowDead       = false;   // Draw dead zones (grey)
 input int    InpSupportResistanceMaxDead        = 20;     // Dead zones kept (0 = all)
 input color  InpSupportResistanceSupportColor    = clrRoyalBlue;      // Support colour (None = blue / red)
 input color  InpSupportResistanceResistanceColor = clrDarkGoldenrod;  // Resistance colour (None = blue / red)
 input color  InpSupportResistanceDeadColor       = clrGray; // Dead zone colour
 input int    InpSupportResistanceOpenNewestSupport    = 3;  // Newest support zones shown from the start (the others are folded)
 input int    InpSupportResistanceOpenNewestResistance = 3;  // Newest resistance zones shown from the start (the others are folded)
#ifndef CSUPPORTRESISTANCESETTING_MQH_DECLARATION
#define CSUPPORTRESISTANCESETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The Support / Resistance zone settings of the EA. They are the   |
 //| inputs of the EA, so                                             |
 //| they are read-only here and change with the Inputs table: the    |
 //| calculation ones go to Python (Json, in the init message), the   |
 //| drawing ones are read by CLifecycleSync                          |
 //+------------------------------------------------------------------+
 class CSupportResistanceSetting : public CBaseObj
  {
   public:
   //--- What is drawn
     bool              ShowSupport(void)     const { return InpSupportResistanceShowSupport;    }
     bool              ShowResistance(void)  const { return InpSupportResistanceShowResistance; }
     bool              ShowDead(void)        const { return InpSupportResistanceShowDead;       }
     int               MaxDead(void)         const { return InpSupportResistanceMaxDead;        }
     int               OpenNewestSupport(void)    const { return InpSupportResistanceOpenNewestSupport;    }
     int               OpenNewestResistance(void) const { return InpSupportResistanceOpenNewestResistance; }
     color             SupportColor(void)    const { return InpSupportResistanceSupportColor;    }   // clrNONE = blue / red
     color             ResistanceColor(void) const { return InpSupportResistanceResistanceColor; }
     color             DeadColor(void)       const { return InpSupportResistanceDeadColor;       }
   //--- What Python calculates, as a JSON object
     string            Json(void) const;
                       CSupportResistanceSetting(void) {}
  };
#endif // CSUPPORTRESISTANCESETTING_MQH_DECLARATION
#ifndef CSUPPORTRESISTANCESETTING_MQH_IMPLEMENTATION
#define CSUPPORTRESISTANCESETTING_MQH_IMPLEMENTATION
 string CSupportResistanceSetting::Json(void) const
  {
   return ::StringFormat("{\"min_score\":%d,\"confirm_closes\":%d,\"ghost_bars\":%d,\"revive\":%s,\"max_age_bars\":%d,\"volume_bars\":%d}",
                         InpSupportResistanceMinScore,InpSupportResistanceConfirmCloses,InpSupportResistanceGhostBars,
                         (InpSupportResistanceRevive ? "true" : "false"),InpSupportResistanceMaxAgeBars,InpSupportResistanceVolumeMABars);
  }
#endif // CSUPPORTRESISTANCESETTING_MQH_IMPLEMENTATION
#endif // __SUPPORTRESISTANCESETTING_MQH__
