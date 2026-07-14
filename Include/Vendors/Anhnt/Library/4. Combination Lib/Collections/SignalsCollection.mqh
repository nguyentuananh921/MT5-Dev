//+------------------------------------------------------------------+
//|                                           SignalsCollection.mqh  |
//| Owns exactly one CSignalBase-derived object per CIndicatorDE     |
//| that supports a signal (1-1). Reuses the existing CSignalXXX     |
//| classes from Timeseries/Signal as-is - this file only manages    |
//| their lifecycle/lookup, it does not duplicate calculation logic. |
//|                                                                  |
//| DoEasy-aligned (README 5d note): derives CBaseObj, stores the    |
//| signals in a CListObj tagged with COLLECTION_SIGNALS_ID so any   |
//| receiver of GetList() can verify the list identity via Type().   |
//|                                                                  |
//| Pointer ownership:                                                |
//|  - m_list (CSignalBase*)      : OWNED here - created in           |
//|    GetOrCreateSignal, freed by CListObj (FreeMode) in            |
//|    DeleteSignal / collection destruction.                         |
//|  - CSignalBase::m_indicator   : BORROWED - CIndicatorsCollection  |
//|    owns the CIndicatorDE objects. Whoever deletes an indicator    |
//|    there MUST call DeleteSignal() here FIRST, or the signal's     |
//|    m_indicator turns dangling.                                    |
//+------------------------------------------------------------------+
#ifndef CSIGNALSCOLLECTION_MQH
#define CSIGNALSCOLLECTION_MQH

#include "ListObj.mqh"
#include "..\Base\BaseObj.mqh"
#include "..\Timeseries\Signal\SignalSAR.mqh"
#include "..\Timeseries\Signal\SignalMA.mqh"
#include "..\Timeseries\Signal\SignalOscillator.mqh"
#include "..\Timeseries\Signal\SignalCrossover.mqh"
#include "..\Timeseries\Signal\SignalBands.mqh"

#ifndef CSIGNALSCOLLECTION_MQH_DECLARATION
#define CSIGNALSCOLLECTION_MQH_DECLARATION
 class CSignalsCollection : public CBaseObj
  {
    private:
      CListObj      m_list;                                   // OWNED signals (FreeMode deletes on removal)
      int           FindIndex(CIndicatorDE *indicator);
    public:
                    CSignalsCollection(void);
     // Return the signal collection list "as is" (list Type() == COLLECTION_SIGNALS_ID)
      CArrayObj    *GetList(void)             { return &this.m_list;         }
      int           DataTotal(void)     const { return this.m_list.Total();  }
     // Returns the existing signal for this indicator, or creates+registers one if the
     // indicator's type is supported. Returns NULL for types with no signal defined yet.
      CSignalBase  *GetOrCreateSignal(CIndicatorDE *indicator);
     // Deletes the signal bound to this indicator (if any) and unregisters it.
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
  CSignalsCollection::CSignalsCollection(void)
   {
    // DoEasy collection convention: tag both the collection object and its list with the
    // collection ID so consumers can verify what they received (CommonDefines "Collection list IDs")
    this.m_type = COLLECTION_SIGNALS_ID;
    this.m_list.Clear();
    this.m_list.Sort();
    this.m_list.Type(COLLECTION_SIGNALS_ID);
   }
  int CSignalsCollection::FindIndex(CIndicatorDE *indicator)
   {
    int total = m_list.Total();
    for(int i = 0; i < total; i++)
      {
       CSignalBase *signal = m_list.At(i);
       if(signal != NULL && signal.GetIndicator() == indicator) return i;
      }
    return -1;
   }
  CSignalBase *CSignalsCollection::GetOrCreateSignal(CIndicatorDE *indicator)
   {
    if(indicator == NULL) return NULL;
    int idx = FindIndex(indicator);
    if(idx >= 0) return m_list.At(idx);

    CSignalBase *signal = NULL;
    switch(indicator.TypeIndicator())
      {
       // First-draft rules (user-approved defaults, refine per type later - README 5f):
       case IND_SAR:   signal = new CSignalSAR();                  break; // price side flips vs SAR dots
       case IND_MA:    signal = new CSignalMA();                   break; // slope of buffer 0
       case IND_AMA:   signal = new CSignalMA();                   break; // MA-family: slope of buffer 0
       case IND_RSI:   signal = new CSignalOscillator(70.0, 30.0); break; // OB/OS thresholds
       case IND_MACD:  signal = new CSignalTwoLineCross(0, 1);     break; // main(0) crosses signal(1)
       case IND_BANDS: signal = new CSignalBollinger();            break; // close leaves upper/lower band
       default: return NULL; // not wired yet - table falls back to its own placeholder
      }
    if(signal == NULL) return NULL;
    signal.SetIndicator(indicator);
    // Backfill flip history so chart arrows have something to show right away, not just from
    // the moment this Signal was created. Capped at 500 bars - a one-time cost per indicator.
    int bars_avail = (int)::Bars(indicator.Symbol(), indicator.Timeframe());
    signal.SyncHistory(bars_avail > 500 ? 500 : bars_avail);

    if(!m_list.Add(signal))
      {
       delete signal;  // failed to register - do not leak the owned object
       return NULL;
      }
    return signal;
   }
  void CSignalsCollection::DeleteSignal(CIndicatorDE *indicator)
   {
    int idx = FindIndex(indicator);
    if(idx < 0) return;          // this indicator never had a signal - nothing to release
    m_list.Delete(idx);          // CListObj FreeMode -> deletes the OWNED signal object
   }
  void CSignalsCollection::RefreshCurrentBar(void)
   {
    int total = m_list.Total();
    for(int i = 0; i < total; i++)
      {
       CSignalBase *signal = m_list.At(i);
       if(signal != NULL) signal.RefreshCurrent();
      }
   }
  void CSignalsCollection::RefreshCurrentBar(const string symbol)
   {
    int total = m_list.Total();
    for(int i = 0; i < total; i++)
      {
       CSignalBase *signal = m_list.At(i);
       if(signal == NULL) continue;
       CIndicatorDE *indicator = signal.GetIndicator();  // BORROWED
       if(indicator != NULL && indicator.Symbol() == symbol)
          signal.RefreshCurrent();
      }
   }
  void CSignalsCollection::FreezeClosedBar(const string symbol, const ENUM_TIMEFRAMES tf)
   {
    int total = m_list.Total();
    for(int i = 0; i < total; i++)
      {
       CSignalBase *signal = m_list.At(i);
       if(signal == NULL) continue;
       CIndicatorDE *indicator = signal.GetIndicator();  // BORROWED
       if(indicator != NULL && indicator.Symbol() == symbol && indicator.Timeframe() == tf)
          signal.CommitClosedBar();
      }
   }
#endif // CSIGNALSCOLLECTION_MQH_IMPLEMENTATION

#endif // CSIGNALSCOLLECTION_MQH
