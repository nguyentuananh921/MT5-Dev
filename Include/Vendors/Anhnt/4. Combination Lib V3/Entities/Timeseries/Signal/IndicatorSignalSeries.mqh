//+------------------------------------------------------------------+
//|                                        IndicatorSignalSeries.mqh |
//| One direction change (BUY/SELL) of one indicator - pure data.    |
//| Compare/IsEqual for CArrayObj::Sort/Search/InsertSort. It knows  |
//| the timeframe it was found on: the EA holds every TF of a symbol |
//+------------------------------------------------------------------+
#ifndef __INDICATORSIGNALSERIES_MQH__
#define __INDICATORSIGNALSERIES_MQH__
 #include "..\..\Bases\BaseObj.mqh"
#ifndef CINDICATORSIGNALSERIES_MQH_DECLARATION
#define CINDICATORSIGNALSERIES_MQH_DECLARATION
 class CIndicatorSignalSeries : public CBaseObj
  {
   private:
     datetime                m_time;     // open time of the bar whose close flipped the direction
     bool                    m_is_buy;
     string                  m_label;    // which indicator and parameters, e.g. RSI(14,CLOSE) - the key Python sends
     bool                    m_neutral;  // no side (Inside Bar): no marker, only the candle information window lists it
     int                     m_template_index;   // position of its row in CIndicatorTemplateManager, -1 for a candle pattern
     ENUM_TIMEFRAMES         m_timeframe;        // the TF it was found on, PERIOD_CURRENT when nobody said
   public:
     datetime                Time(void)   const { return this.m_time;   }
     bool                    IsBuy(void)  const { return this.m_is_buy; }
     string                  Label(void)  const { return this.m_label;  }
     int                     TemplateIndex(void) const { return this.m_template_index; }
     ENUM_TIMEFRAMES         Timeframe(void) const { return this.m_timeframe; }
     bool                    IsNeutral(void) const { return this.m_neutral; }
     void                    Neutral(const bool v) { this.m_neutral=v; }
   //--- By time, then label, then timeframe: one entry per indicator, bar and TF
     virtual int             Compare(const CObject *node,const int mode=0) const;
                             CIndicatorSignalSeries(const datetime time,const bool is_buy,const string label,const int template_index=-1,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT);
  };
#endif // CINDICATORSIGNALSERIES_MQH_DECLARATION
#ifndef CINDICATORSIGNALSERIES_MQH_IMPLEMENTATION
#define CINDICATORSIGNALSERIES_MQH_IMPLEMENTATION
 CIndicatorSignalSeries::CIndicatorSignalSeries(const datetime time,const bool is_buy,const string label,const int template_index=-1,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT) : m_time(time),
                                                                                                           m_is_buy(is_buy),
                                                                                                           m_label(label),
                                                                                                           m_neutral(false),
                                                                                                           m_template_index(template_index),
                                                                                                           m_timeframe(timeframe)
  {
  }
 int CIndicatorSignalSeries::Compare(const CObject *node,const int mode=0) const
  {
   const CIndicatorSignalSeries *compared=node;
   if(this.m_time!=compared.m_time)
      return (this.m_time>compared.m_time ? 1 : -1);
   if(this.m_label!=compared.m_label)
      return (this.m_label>compared.m_label ? 1 : -1);
   if(this.m_timeframe==compared.m_timeframe)
      return 0;
   return (this.m_timeframe>compared.m_timeframe ? 1 : -1);
  }
#endif // CINDICATORSIGNALSERIES_MQH_IMPLEMENTATION
#endif // __INDICATORSIGNALSERIES_MQH__
