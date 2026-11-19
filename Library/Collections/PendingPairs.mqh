//+------------------------------------------------------------------+
//|                                                 PendingPairs.mqh |
//+------------------------------------------------------------------+
//--- New in V5: the pairs whose new bar is not judged yet (CSignalsCollection, CStrategyCollection). The judging follows SERIES_EVENTS_NEW_BAR;
//--- what is not ready then (MT5 has not calculated the indicator, Python writes) waits here and OnTimer tries it again, a symbol that rests is skipped
#ifndef __PENDINGPAIRS_MQH__
#define __PENDINGPAIRS_MQH__
 #include <Arrays\ArrayString.mqh>
#ifndef CPENDINGPAIRS_MQH_DECLARATION
#define CPENDINGPAIRS_MQH_DECLARATION
 class CPendingPairs
  {
   private:
    CArrayString      m_list_pairs;              // "symbol;tf", one each
    string            Key(const string symbol,const ENUM_TIMEFRAMES timeframe) const { return symbol+";"+(string)(int)timeframe; }
   public:
    void              Add(const string symbol,const ENUM_TIMEFRAMES timeframe);
    int               Total(void)                                     const { return this.m_list_pairs.Total(); }
    string            Symbol(const int index)                         const;
    ENUM_TIMEFRAMES   Timeframe(const int index)                      const;
    void              Delete(const int index)                               { this.m_list_pairs.Delete(index);  }
  };
#endif // CPENDINGPAIRS_MQH_DECLARATION
#ifndef CPENDINGPAIRS_MQH_IMPLEMENTATION
#define CPENDINGPAIRS_MQH_IMPLEMENTATION
 void CPendingPairs::Add(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   const string key=this.Key(symbol,timeframe);
   for(int i=0;i<this.m_list_pairs.Total();i++)
      if(this.m_list_pairs.At(i)==key)
         return;
   this.m_list_pairs.Add(key);
  }
 string CPendingPairs::Symbol(const int index) const
  {
   string parts[];
   return(::StringSplit(this.m_list_pairs.At(index),';',parts)==2 ? parts[0] : "");
  }
 ENUM_TIMEFRAMES CPendingPairs::Timeframe(const int index) const
  {
   string parts[];
   return(::StringSplit(this.m_list_pairs.At(index),';',parts)==2 ? (ENUM_TIMEFRAMES)(int)::StringToInteger(parts[1]) : PERIOD_CURRENT);
  }
#endif // CPENDINGPAIRS_MQH_IMPLEMENTATION
#endif // __PENDINGPAIRS_MQH__
