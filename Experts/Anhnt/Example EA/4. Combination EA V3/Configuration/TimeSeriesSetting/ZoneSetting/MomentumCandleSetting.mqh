//+------------------------------------------------------------------+
//|                                          MomentumCandleSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef __MOMENTUMCANDLESETTING_MQH__
#define __MOMENTUMCANDLESETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Momentum candle)
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
   private:
     int               m_bars;           // the inputs at the start, the Smart Money tab changes them
     double            m_multiplier;
     bool              m_show;           // the markers are drawn: the toggle of its section in the Smart Money tab
   public:
     int               Bars(void)       const { return (m_bars<1 ? 1 : m_bars); }
     void              Bars(const int count)                     { m_bars=count; }
     double            Multiplier(void) const { return (m_multiplier<0.0 ? 0.0 : m_multiplier); }
     void              Multiplier(const double value)            { m_multiplier=value; }
     bool              Show(void)       const { return m_show;      }
     void              Show(const bool on)                       { m_show=on; }
     color             BuyColor(void)   const { return InpMomentumCandleBuyColor;  }
     color             SellColor(void)  const { return InpMomentumCandleSellColor; }
   //--- What Python calculates, as a JSON object
     string            Json(void) const;
                       CMomentumCandleSetting(void) : m_bars(InpMomentumCandleBars),m_multiplier(InpMomentumCandleMultiplier),m_show(InpMomentumCandleShow) {}
  };
#endif // CMOMENTUMCANDLESETTING_MQH_DECLARATION
#ifndef CMOMENTUMCANDLESETTING_MQH_IMPLEMENTATION
#define CMOMENTUMCANDLESETTING_MQH_IMPLEMENTATION
 string CMomentumCandleSetting::Json(void) const
  {
   return ::StringFormat("{\"multiplier\":%.4f,\"bars\":%d}",this.Multiplier(),this.Bars());
  }
#endif // CMOMENTUMCANDLESETTING_MQH_IMPLEMENTATION
#endif // __MOMENTUMCANDLESETTING_MQH__
