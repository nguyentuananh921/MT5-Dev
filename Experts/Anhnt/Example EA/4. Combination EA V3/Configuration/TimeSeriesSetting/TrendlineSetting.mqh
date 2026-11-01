//+------------------------------------------------------------------+
//|                                              TrendlineSetting.mqh |
//+------------------------------------------------------------------+
#ifndef __TRENDLINESETTING_MQH__
#define __TRENDLINESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Trendline)
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
   private:
     bool              m_show_support;   // the inputs at the start, the Smart Money tab changes them
     bool              m_show_resistance;
     bool              m_show_dead;
     int               m_max_dead;
     int               m_nearest;
     double            m_confirm_atr;    // what Python calculates: the inputs at the start, the Smart Money tab changes them
     int               m_confirm_closes;
     double            m_min_move_atr;
     double            m_min_swing_atr;
     int               m_swings_tried;
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
     int               Nearest(void)         const { return m_nearest;         }
     void              Nearest(const int count)                  { m_nearest=(count<0 ? 0 : count);  }
     color             SupportColor(void)    const { return InpTrendlineSupportColor;    }   // clrNONE = blue / red
     color             ResistanceColor(void) const { return InpTrendlineResistanceColor; }
     color             DeadColor(void)       const { return InpTrendlineDeadColor;       }
   //--- What Python calculates
     double            ConfirmATR(void)      const { return m_confirm_atr;     }
     void              ConfirmATR(const double atr)              { m_confirm_atr=(atr<0.0 ? 0.0 : atr); }
     int               ConfirmCloses(void)   const { return m_confirm_closes;  }
     void              ConfirmCloses(const int closes)           { m_confirm_closes=(closes<1 ? 1 : closes); }
     double            MinMoveATR(void)      const { return m_min_move_atr;    }
     void              MinMoveATR(const double atr)              { m_min_move_atr=(atr<0.0 ? 0.0 : atr); }
     double            MinSwingATR(void)     const { return m_min_swing_atr;   }
     void              MinSwingATR(const double atr)             { m_min_swing_atr=(atr<0.0 ? 0.0 : atr); }
     int               SwingsTried(void)     const { return m_swings_tried;    }
     void              SwingsTried(const int swings)             { m_swings_tried=(swings<2 ? 2 : swings); }
   //--- What Python calculates, as a JSON object
     string            Json(void) const;
                       CTrendlineSetting(void) : m_show_support(false),m_show_resistance(false),m_show_dead(false),m_max_dead(20),m_nearest(3),
                                             m_confirm_atr(1.0),m_confirm_closes(2),m_min_move_atr(0.2),m_min_swing_atr(0.8),m_swings_tried(50) {}   // the values before the first Save of the Smart Money tab
  };
#endif // CTRENDLINESETTING_MQH_DECLARATION
#ifndef CTRENDLINESETTING_MQH_IMPLEMENTATION
#define CTRENDLINESETTING_MQH_IMPLEMENTATION
 string CTrendlineSetting::Json(void) const
  {
   return ::StringFormat("{\"confirm_atr\":%.4f,\"confirm_closes\":%d,\"min_move_atr\":%.4f,\"min_swing_atr\":%.4f,\"n_swings\":%d}",
                         this.ConfirmATR(),this.ConfirmCloses(),this.MinMoveATR(),this.MinSwingATR(),this.SwingsTried());
  }
#endif // CTRENDLINESETTING_MQH_IMPLEMENTATION
#endif // __TRENDLINESETTING_MQH__
