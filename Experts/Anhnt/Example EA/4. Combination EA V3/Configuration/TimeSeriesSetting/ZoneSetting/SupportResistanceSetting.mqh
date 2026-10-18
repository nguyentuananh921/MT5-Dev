//+------------------------------------------------------------------+
//|                                       SupportResistanceSetting.mqh |
//+------------------------------------------------------------------+
#ifndef __SUPPORTRESISTANCESETTING_MQH__
#define __SUPPORTRESISTANCESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Support / Resistance zone)
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
   private:
     bool              m_show_support;   // the inputs at the start, the Smart Money tab changes them
     bool              m_show_resistance;
     bool              m_show_dead;
     int               m_max_dead;
     int               m_open_newest_support;   // the newest zones shown from the start, the others are folded
     int               m_open_newest_resistance;
     int               m_min_score;      // what Python calculates: the inputs at the start, the Smart Money tab changes them
     int               m_confirm_closes;
     int               m_ghost_bars;
     bool              m_revive;
     int               m_max_age_bars;
     int               m_volume_bars;
   public:
   //--- What is drawn
     bool              ShowSupport(void)     const { return m_show_support;    }
     void              ShowSupport(const bool on)                { m_show_support=on;    }
     bool              ShowResistance(void)  const { return m_show_resistance; }
     void              ShowResistance(const bool on)             { m_show_resistance=on; }
     bool              ShowDead(void)        const { return m_show_dead;       }
     void              ShowDead(const bool on)                   { m_show_dead=on;       }
     int               MaxDead(void)         const { return m_max_dead;        }
     void              MaxDead(const int count)                  { m_max_dead=(count<0 ? 0 : count); }
     int               OpenNewestSupport(void)    const { return m_open_newest_support;    }
     void              OpenNewestSupport(const int count)        { m_open_newest_support=(count<0 ? 0 : count);    }
     int               OpenNewestResistance(void) const { return m_open_newest_resistance; }
     void              OpenNewestResistance(const int count)     { m_open_newest_resistance=(count<0 ? 0 : count); }
     color             SupportColor(void)    const { return InpSupportResistanceSupportColor;    }   // clrNONE = blue / red
     color             ResistanceColor(void) const { return InpSupportResistanceResistanceColor; }
     color             DeadColor(void)       const { return InpSupportResistanceDeadColor;       }
   //--- What Python calculates
     int               MinScore(void)        const { return m_min_score;       }
     void              MinScore(const int score)                 { m_min_score=(score<0 ? 0 : (score>100 ? 100 : score)); }
     int               ConfirmCloses(void)   const { return m_confirm_closes;  }
     void              ConfirmCloses(const int closes)           { m_confirm_closes=(closes<1 ? 1 : closes); }
     int               GhostBars(void)       const { return m_ghost_bars;      }
     void              GhostBars(const int bars)                 { m_ghost_bars=(bars<0 ? 0 : bars); }
     bool              Revive(void)          const { return m_revive;          }
     void              Revive(const bool on)                     { m_revive=on; }
     int               MaxAgeBars(void)      const { return m_max_age_bars;    }
     void              MaxAgeBars(const int bars)                { m_max_age_bars=(bars<1 ? 1 : bars); }
     int               VolumeMABars(void)    const { return m_volume_bars;     }
     void              VolumeMABars(const int bars)              { m_volume_bars=(bars<1 ? 1 : bars); }
   //--- What Python calculates, as a JSON object
     string            Json(void) const;
                       CSupportResistanceSetting(void) : m_show_support(InpSupportResistanceShowSupport),m_show_resistance(InpSupportResistanceShowResistance),m_show_dead(InpSupportResistanceShowDead),m_max_dead(InpSupportResistanceMaxDead),
                                                         m_open_newest_support(InpSupportResistanceOpenNewestSupport),m_open_newest_resistance(InpSupportResistanceOpenNewestResistance),
                                                         m_min_score(InpSupportResistanceMinScore),m_confirm_closes(InpSupportResistanceConfirmCloses),m_ghost_bars(InpSupportResistanceGhostBars),m_revive(InpSupportResistanceRevive),m_max_age_bars(InpSupportResistanceMaxAgeBars),m_volume_bars(InpSupportResistanceVolumeMABars) {}
  };
#endif // CSUPPORTRESISTANCESETTING_MQH_DECLARATION
#ifndef CSUPPORTRESISTANCESETTING_MQH_IMPLEMENTATION
#define CSUPPORTRESISTANCESETTING_MQH_IMPLEMENTATION
 string CSupportResistanceSetting::Json(void) const
  {
   return ::StringFormat("{\"min_score\":%d,\"confirm_closes\":%d,\"ghost_bars\":%d,\"revive\":%s,\"max_age_bars\":%d,\"volume_bars\":%d}",
                         this.MinScore(),this.ConfirmCloses(),this.GhostBars(),(this.Revive() ? "true" : "false"),this.MaxAgeBars(),this.VolumeMABars());
  }
#endif // CSUPPORTRESISTANCESETTING_MQH_IMPLEMENTATION
#endif // __SUPPORTRESISTANCESETTING_MQH__
