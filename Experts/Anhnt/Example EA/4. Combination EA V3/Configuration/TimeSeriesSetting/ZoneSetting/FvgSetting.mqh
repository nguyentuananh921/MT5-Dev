//+------------------------------------------------------------------+
//|                                                    FvgSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __FVGSETTING_MQH__
#define __FVGSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Fair value gap (FVG))
#ifndef CFVGSETTING_MQH_DECLARATION
#define CFVGSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The FVG settings of the EA. They are the inputs of the EA, so    |
 //| they are read-only here; they are read by CLifecycleSync (a      |
 //| bullish FVG is a Buy one, a bearish FVG a Sell one)              |
 //+------------------------------------------------------------------+
 class CFvgSetting : public CBaseObj
  {
   private:
     bool              m_show_bullish;   // the inputs at the start, the Smart Money tab changes them
     bool              m_show_bearish;
     bool              m_show_dead;
     int               m_max_dead;
     int               m_open_newest_bullish;   // the newest gaps shown from the start, the others are folded
     int               m_open_newest_bearish;
   public:
     bool              ShowBullish(void) const { return m_show_bullish; }
     void              ShowBullish(const bool on)                { m_show_bullish=on; }
     bool              ShowBearish(void) const { return m_show_bearish; }
     void              ShowBearish(const bool on)                { m_show_bearish=on; }
     bool              ShowDead(void)    const { return m_show_dead;    }
     void              ShowDead(const bool on)                   { m_show_dead=on;    }
     int               MaxDead(void)     const { return m_max_dead;     }
     void              MaxDead(const int count)                  { m_max_dead=(count<0 ? 0 : count); }
     int               OpenNewestBullish(void) const { return m_open_newest_bullish; }
     void              OpenNewestBullish(const int count)        { m_open_newest_bullish=(count<0 ? 0 : count); }
     int               OpenNewestBearish(void) const { return m_open_newest_bearish; }
     void              OpenNewestBearish(const int count)        { m_open_newest_bearish=(count<0 ? 0 : count); }
     color             BullishColor(void) const { return InpFvgBullishColor; }
     color             BearishColor(void) const { return InpFvgBearishColor; }
     color             DeadColor(void)    const { return InpFvgDeadColor;    }
                       CFvgSetting(void) : m_show_bullish(InpFvgShowBullish),m_show_bearish(InpFvgShowBearish),m_show_dead(InpFvgShowDead),m_max_dead(InpFvgMaxDead),m_open_newest_bullish(InpFvgOpenNewestBullish),m_open_newest_bearish(InpFvgOpenNewestBearish) {}
  };
#endif // CFVGSETTING_MQH_DECLARATION
#endif // __FVGSETTING_MQH__
