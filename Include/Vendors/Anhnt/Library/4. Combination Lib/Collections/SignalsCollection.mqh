//+------------------------------------------------------------------+
//|                                           SignalsCollection.mqh  |
//| Owns exactly one CSignalBase-derived object per CIndicatorDE     |
//| that supports a signal (1-1, mirrors how CBarSeriesDE owns its   |
//| own m_patterns_control). Reuses the existing CSignalXXX classes  |
//| from Timeseries/Signal as-is - this file only manages their      |
//| lifecycle/lookup, it does not duplicate their calculation logic. |
//|                                                                  |
//| Pointer ownership:                                                |
//|  - m_signal_list[]    : OWNED here - created in GetOrCreateSignal,|
//|                         deleted in DeleteSignal / destructor.     |
//|  - m_indicator_list[] : BORROWED - CIndicatorsCollection owns the |
//|                         CIndicatorDE objects. Whoever deletes an  |
//|                         indicator there MUST call DeleteSignal()  |
//|                         here FIRST, or m_indicator_list[] and the |
//|                         signal's own m_indicator turn dangling.   |
//+------------------------------------------------------------------+
#ifndef CSIGNALSCOLLECTION_MQH
#define CSIGNALSCOLLECTION_MQH

#include "..\Timeseries\Signal\SignalSAR.mqh"
#include "..\Timeseries\Signal\SignalMA.mqh"

#ifndef CSIGNALSCOLLECTION_MQH_DECLARATION
#define CSIGNALSCOLLECTION_MQH_DECLARATION
 class CSignalsCollection
  {
    private:
     // parallel arrays: m_indicator_list[i]'s signal lives in m_signal_list[i]
      CIndicatorDE *m_indicator_list[];   // BORROWED - owned by CIndicatorsCollection
      CSignalBase  *m_signal_list[];      // OWNED here - deleted in DeleteSignal/destructor
      int           FindIndex(CIndicatorDE *indicator);
    public:
                    ~CSignalsCollection(void);
     // Returns the existing signal for this indicator, or creates+registers one if the
     // indicator's type is supported. Returns NULL for types with no signal defined yet.
      CSignalBase  *GetOrCreateSignal(CIndicatorDE *indicator);
     // Deletes the signal bound to this indicator (if any) and unregisters the pair.
     // MUST be called BEFORE the indicator itself is deleted from CIndicatorsCollection.
      void          DeleteSignal(CIndicatorDE *indicator);
     // Recompute bar 0 (the still-forming current bar) for every tracked signal - call this
     // on every timer tick so the "current" direction never repaints a stale value.
      void          RefreshCurrentBar(void);
     // Same, but only for signals whose indicator belongs to 'symbol' - call this on every
     // OnTick (mirrors CIndicatorsCollection::SeriesRefreshBySymbol's per-tick scoping) so the
     // chart's own symbol feels truly live between timer ticks, without recomputing every
     // other tracked symbol's signal on every single tick.
      void          RefreshCurrentBar(const string symbol);
     // Freeze bar 1 (the bar that JUST closed) to its one final value for every signal whose
     // indicator matches (symbol, timeframe). Call this once per (symbol,timeframe) new-bar
     // event - never call every tick, since bar 1 is a settled historical fact, not a live one.
      void          FreezeClosedBar(const string symbol, const ENUM_TIMEFRAMES tf);
  };
#endif // CSIGNALSCOLLECTION_MQH_DECLARATION

#ifndef CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#define CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
  CSignalsCollection::~CSignalsCollection(void)
   {
    int total = ArraySize(m_signal_list);
    for(int i = 0; i < total; i++)
      if(m_signal_list[i] != NULL) delete m_signal_list[i];
   }
  int CSignalsCollection::FindIndex(CIndicatorDE *indicator)
   {
    int total = ArraySize(m_indicator_list);
    for(int i = 0; i < total; i++)
      if(m_indicator_list[i] == indicator) return i;
    return -1;
   }
  CSignalBase *CSignalsCollection::GetOrCreateSignal(CIndicatorDE *indicator)
   {
    if(indicator == NULL) return NULL;
    int idx = FindIndex(indicator);
    if(idx >= 0) return m_signal_list[idx];

    CSignalBase *signal = NULL;
    switch(indicator.TypeIndicator())
      {
       case IND_SAR: signal = new CSignalSAR(); break;
       case IND_MA:  signal = new CSignalMA();  break;
       default: return NULL; // not wired yet - table falls back to its own placeholder
      }
    if(signal == NULL) return NULL;
    signal.SetIndicator(indicator);
    // Backfill flip history so chart arrows have something to show right away, not just from
    // the moment this Signal was created. Capped at 500 bars - a one-time cost per indicator.
    int bars_avail = (int)::Bars(indicator.Symbol(), indicator.Timeframe());
    signal.SyncHistory(bars_avail > 500 ? 500 : bars_avail);

    int total = ArraySize(m_indicator_list);
    ArrayResize(m_indicator_list, total + 1);
    ArrayResize(m_signal_list, total + 1);
    m_indicator_list[total] = indicator;
    m_signal_list[total]    = signal;
    return signal;
   }
  void CSignalsCollection::DeleteSignal(CIndicatorDE *indicator)
   {
    int idx = FindIndex(indicator);
    if(idx < 0) return; // this indicator never had a signal - nothing to release
    if(m_signal_list[idx] != NULL)
       delete m_signal_list[idx]; // owned here
    // compact both parallel arrays - keep them index-aligned
    int total = ArraySize(m_indicator_list);
    for(int i = idx; i < total - 1; i++)
      {
       m_indicator_list[i] = m_indicator_list[i + 1];
       m_signal_list[i]    = m_signal_list[i + 1];
      }
    ArrayResize(m_indicator_list, total - 1);
    ArrayResize(m_signal_list, total - 1);
   }
  void CSignalsCollection::RefreshCurrentBar(void)
   {
    int total = ArraySize(m_signal_list);
    for(int i = 0; i < total; i++)
      if(m_signal_list[i] != NULL) m_signal_list[i].RefreshCurrent();
   }
  void CSignalsCollection::RefreshCurrentBar(const string symbol)
   {
    int total = ArraySize(m_signal_list);
    for(int i = 0; i < total; i++)
      if(m_signal_list[i] != NULL && m_indicator_list[i] != NULL && m_indicator_list[i].Symbol() == symbol)
         m_signal_list[i].RefreshCurrent();
   }
  void CSignalsCollection::FreezeClosedBar(const string symbol, const ENUM_TIMEFRAMES tf)
   {
    int total = ArraySize(m_signal_list);
    for(int i = 0; i < total; i++)
      if(m_signal_list[i] != NULL && m_indicator_list[i] != NULL &&
         m_indicator_list[i].Symbol() == symbol && m_indicator_list[i].Timeframe() == tf)
         m_signal_list[i].CommitClosedBar();
   }
#endif // CSIGNALSCOLLECTION_MQH_IMPLEMENTATION

#endif // CSIGNALSCOLLECTION_MQH
