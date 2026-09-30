//+------------------------------------------------------------------+
//|                                           SignalsCollection.mqh  |
//| Owns exactly one CSignalBase-derived object per CIndicatorDE     |
//| that supports a signal (1-1). Reuses the existing CSignalXXX     |
//| classes from Timeseries/Signal as-is - this file only manages    |
//| their lifecycle/lookup, it does not duplicate calculation logic. |
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
#include "..\Entities\Bases\BaseObj.mqh"
#include "..\Timeseries\Signal\SignalSAR.mqh"
#include "..\Timeseries\Signal\SignalMA.mqh"
#include "..\Timeseries\Signal\SignalOscillator.mqh"
#include "..\Timeseries\Signal\SignalCrossover.mqh"
#include "..\Timeseries\Signal\SignalBands.mqh"
#include "..\Timeseries\Signal\SignalZeroCross.mqh"
#include "..\Timeseries\Signal\SignalADX.mqh"
#include "..\Timeseries\Signal\SignalFractals.mqh"

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
       // --- Wired 2026-09-17 (Anhnt: "Signal nào có sẵn mà chưa wire thì wire luôn") - classes
       // already existed with their own "Applies to" doc comments, just never referenced here.
       case IND_ADX:        signal = new CSignalADX();               break; // DI+/DI- cross
       case IND_ADXW:       signal = new CSignalADX();               break; // ADX-family: DI+/DI- cross
       case IND_STOCHASTIC: signal = new CSignalTwoLineCross(0, 1, 80.0, 20.0); break; // main/signal cross + OB/OS gate
       case IND_RVI:        signal = new CSignalTwoLineCross(0, 1);  break; // main/signal cross, no gate
       case IND_ALLIGATOR:  signal = new CSignalTwoLineCross(0, 2);  break; // Jaw(0) crosses Lips(2)
       case IND_AO:         signal = new CSignalZeroCross();         break; // zero-line cross
       case IND_AC:         signal = new CSignalZeroCross();         break; // zero-line cross
       case IND_FORCE:      signal = new CSignalZeroCross();         break; // zero-line cross
       case IND_MOMENTUM:   signal = new CSignalZeroCross(100.0);    break; // level-100 cross, not zero
       case IND_OSMA:       signal = new CSignalZeroCross();         break; // zero-line cross
       case IND_TRIX:       signal = new CSignalZeroCross();         break; // zero-line cross
       case IND_CHAIKIN:    signal = new CSignalZeroCross();         break; // zero-line cross
       case IND_OBV:        signal = new CSignalZeroCross();         break; // zero-line cross       
       case IND_ICHIMOKU:  signal = new CSignalTwoLineCross(0, 1);   break; // Tenkan(0) crosses Kijun(1)
       case IND_ENVELOPES: signal = new CSignalEnvelopes();          break; // close vs upper/lower band
       case IND_FRAMA:     signal = new CSignalMA();                 break; // MA-family: slope of buffer 0
       case IND_DEMA:      signal = new CSignalMA();                 break; // MA-family: slope of buffer 0
       case IND_TEMA:      signal = new CSignalMA();                 break; // MA-family: slope of buffer 0
       case IND_VIDYA:     signal = new CSignalMA();                 break; // MA-family: slope of buffer 0
       case IND_CCI:       signal = new CSignalOscillator(100.0, -100.0); break; // OB/OS thresholds
       case IND_DEMARKER:  signal = new CSignalOscillator(0.7, 0.3); break; // OB/OS thresholds
       case IND_WPR:       signal = new CSignalOscillator(-20.0, -80.0); break; // OB/OS thresholds (inverted scale)
       case IND_MFI:       signal = new CSignalOscillator(80.0, 20.0); break; // OB/OS thresholds
       case IND_BEARS:     signal = new CSignalZeroCross();          break; // zero-line cross
       case IND_BULLS:     signal = new CSignalZeroCross();          break; // zero-line cross
       // --- Approximate first-draft proxies - these 3 don't have a natural Buy/Sell convention;
       // slope/zero-cross is a loose stand-in, refine later if it doesn't feel right in practice.
       case IND_STDDEV:    signal = new CSignalMA();                 break; // proxy: rising/falling volatility
       // IND_ATR NOT wired (Anhnt, 2026-09-19) - pure volatility, no direction; a slope "Buy/Sell" was
       // meaningless noise in the log/bridge, and ATR(14) is auto-bootstrapped on every series for StopLost.
       case IND_AD:        signal = new CSignalMA();                 break; // proxy: slope of cumulative line
       case IND_BWMFI:     signal = new CSignalMA();                 break; // proxy: slope of buffer 0
       case IND_GATOR:     signal = new CSignalZeroCross();          break; // proxy: upper histogram only
       case IND_FRACTALS:  signal = new CSignalFractals();           break; // Up=SELL, Down=BUY (reversal read)
       // IND_VOLUMES intentionally NOT wired - raw volume has no Buy/Sell polarity at all.
       default: return NULL; // not wired yet - table falls back to its own placeholder
      }
    if(signal == NULL) return NULL;
    signal.SetIndicator(indicator);
    // Backfill flip history so chart arrows have something to show right away, not just from
    // the moment this Signal was created. Capped at 500 bars - a one-time cost per indicator.
    int bars_avail = (int)::Bars(indicator.Symbol(), indicator.Timeframe());
    signal.SyncHistory(bars_avail > 500 ? 500 : bars_avail);
    signal.SyncHistoryExtra(bars_avail > 500 ? 500 : bars_avail);

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
       if(signal != NULL) { signal.RefreshCurrent(); signal.RefreshCurrentExtra(); }
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
         { signal.RefreshCurrent(); signal.RefreshCurrentExtra(); }
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
         { signal.CommitClosedBar(); signal.CommitClosedBarExtra(); }
      }
   }
#endif // CSIGNALSCOLLECTION_MQH_IMPLEMENTATION

#endif // CSIGNALSCOLLECTION_MQH
