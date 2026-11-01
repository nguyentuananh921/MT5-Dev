//+------------------------------------------------------------------+
//|                                                  SwingSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __SWINGSETTING_MQH__
#define __SWINGSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\MarketStructureDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Swing)
#ifndef CSWINGSETTING_MQH_DECLARATION
#define CSWINGSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The Swing settings of the EA. They start as the inputs of the EA  |
 //| and the Smart Money tab changes them while it runs: the detection |
 //| ones go to Python (the init message), the Show ones decide what   |
 //| CSmartMoneySync draws                                             |
 //+------------------------------------------------------------------+
 class CSwingSetting : public CBaseObj
  {
   private:
     int                     m_strength;      // candles on each side of a Swing
     bool                    m_use_wick;      // the Swing is found on the wicks (else on the bodies)
     bool                    m_show_high;     // the Swing Highs are drawn
     bool                    m_show_low;      // the Swing Lows are drawn
   public:
     int                     Strength(void)   const { return (m_strength<1 ? 1 : m_strength); }
     void                    Strength(const int bars)                  { m_strength=bars; }
     ENUM_SWING_PRICE_BASIS  PriceBasis(void) const { return (m_use_wick ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY); }
     void                    UseWick(const bool on)                    { m_use_wick=on; }
     bool                    SignalShow(const ENUM_SWING_TYPE type) const;
     void                    SignalShow(const ENUM_SWING_TYPE type,const bool show);
   //--- The colour of a Swing: a High is marked above the candle, a Low below it
     color                   Colour(const ENUM_SWING_TYPE type) const { return (type==SWING_TYPE_LOW ? InpSwingLowColor : InpSwingHighColor); }
                             CSwingSetting(void) : m_strength(5),m_use_wick(true),m_show_high(true),m_show_low(true) {}   // the values before the first Save of the Smart Money tab
  };
#endif // CSWINGSETTING_MQH_DECLARATION
#ifndef CSWINGSETTING_MQH_IMPLEMENTATION
#define CSWINGSETTING_MQH_IMPLEMENTATION
 bool CSwingSetting::SignalShow(const ENUM_SWING_TYPE type) const
  {
   return (type==SWING_TYPE_HIGH ? m_show_high : type==SWING_TYPE_LOW ? m_show_low : false);
  }
 void CSwingSetting::SignalShow(const ENUM_SWING_TYPE type,const bool show)
  {
   if(type==SWING_TYPE_HIGH)
      m_show_high=show;
   else if(type==SWING_TYPE_LOW)
      m_show_low=show;
  }
#endif // CSWINGSETTING_MQH_IMPLEMENTATION
#endif // __SWINGSETTING_MQH__
