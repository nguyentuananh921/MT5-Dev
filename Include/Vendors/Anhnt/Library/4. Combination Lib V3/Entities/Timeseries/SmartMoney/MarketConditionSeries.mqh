//+------------------------------------------------------------------+
//|                                        MarketConditionSeries.mqh |
//| One change of the Market State / Market Phase of one timeframe - |
//| pure data, Python decided it from the Swings.                    |
//| Compare for CArrayObj::Sort/Search/InsertSort                    |
//+------------------------------------------------------------------+
#ifndef __MARKETCONDITIONSERIES_MQH__
#define __MARKETCONDITIONSERIES_MQH__
 #include "..\..\Bases\BaseObj.mqh"
 #include "..\..\Defines\MarketStructureDefines.mqh"
#ifndef CMARKETCONDITIONSERIES_MQH_DECLARATION
#define CMARKETCONDITIONSERIES_MQH_DECLARATION
 class CMarketConditionSeries : public CBaseObj
  {
   private:
     datetime                m_time;        // bar time at which the swing that brought the change was confirmed
     ENUM_TIMEFRAMES         m_timeframe;
     ENUM_MARKET_STATE       m_state;
     ENUM_MARKET_PHASE       m_phase;
   public:
     datetime                Time(void)      const { return this.m_time;      }
     ENUM_TIMEFRAMES         Timeframe(void) const { return this.m_timeframe; }
     ENUM_MARKET_STATE       State(void)     const { return this.m_state;     }
     ENUM_MARKET_PHASE       Phase(void)     const { return this.m_phase;     }
   //--- By time, then timeframe: one entry per change and TF
     virtual int             Compare(const CObject *node,const int mode=0) const;
                             CMarketConditionSeries(const datetime time,const ENUM_TIMEFRAMES timeframe,const ENUM_MARKET_STATE state,const ENUM_MARKET_PHASE phase);
  };
#endif // CMARKETCONDITIONSERIES_MQH_DECLARATION
#ifndef CMARKETCONDITIONSERIES_MQH_IMPLEMENTATION
#define CMARKETCONDITIONSERIES_MQH_IMPLEMENTATION
 CMarketConditionSeries::CMarketConditionSeries(const datetime time,const ENUM_TIMEFRAMES timeframe,const ENUM_MARKET_STATE state,const ENUM_MARKET_PHASE phase) : m_time(time),
                                                                                                                                                                  m_timeframe(timeframe),
                                                                                                                                                                  m_state(state),
                                                                                                                                                                  m_phase(phase)
  {
  }
 int CMarketConditionSeries::Compare(const CObject *node,const int mode=0) const
  {
   const CMarketConditionSeries *compared=node;
   if(this.m_time!=compared.m_time)
      return (this.m_time>compared.m_time ? 1 : -1);
   if(this.m_timeframe==compared.m_timeframe)
      return 0;
   return (this.m_timeframe>compared.m_timeframe ? 1 : -1);
  }
#endif // CMARKETCONDITIONSERIES_MQH_IMPLEMENTATION
#endif // __MARKETCONDITIONSERIES_MQH__
