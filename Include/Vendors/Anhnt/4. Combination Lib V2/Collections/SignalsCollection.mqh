//+------------------------------------------------------------------+
//|                                           SignalsCollection.mqh  |
//| One CSignalBase-derived object per CIndicatorDE that supports a |
//| signal; this file only manages lifecycle and lookup.             |
//| m_list owns the signals; CSignalBase::m_indicator is borrowed:   |
//| call DeleteSignal() BEFORE deleting the indicator from           |
//| CIndicatorsCollection, or m_indicator dangles.                   |
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
     // The list as is (Type() == COLLECTION_SIGNALS_ID)
      CArrayObj    *GetList(void)             { return &this.m_list;         }
      int           DataTotal(void)     const { return this.m_list.Total();  }
     // Existing signal of this indicator, or a new registered one; NULL for types without a signal
      CSignalBase  *GetOrCreateSignal(CIndicatorDE *indicator);
     // Deletes the signal of this indicator - call BEFORE deleting the indicator
      void          DeleteSignal(CIndicatorDE *indicator);
     // Per signal: commit the just-closed bar on a new bar, then recompute bar 0 (a flip sends SIGNAL_EVENT_LIVE_FLIP)
      void          RefreshCurrentBar(void);
     // Same, only for the signals of 'symbol' (every OnTick)
      void          RefreshCurrentBar(const string symbol);
  };
#endif // CSIGNALSCOLLECTION_MQH_DECLARATION

#ifndef CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#define CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
  CSignalsCollection::CSignalsCollection(void)
   {
    // Tag the collection and its list with COLLECTION_SIGNALS_ID (DoEasy convention)
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
       // Default rule per indicator type:
       case IND_SAR:   signal = new CSignalSAR();                  break; // price side flips vs SAR dots
       case IND_MA:    signal = new CSignalMA();                   break; // slope of buffer 0
       case IND_AMA:   signal = new CSignalMA();                   break; // MA-family: slope of buffer 0
       case IND_RSI:   signal = new CSignalOscillator(70.0, 30.0); break; // OB/OS thresholds
       case IND_MACD:  signal = new CSignalTwoLineCross(0, 1);     break; // main(0) crosses signal(1)
       case IND_BANDS: signal = new CSignalBollinger();            break; // close vs MidBand; Upper/Lower crosses keep own histories
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
       // IND_ATR not wired: pure volatility has no direction (ATR(14) is auto-created on every series for StopLost)
       case IND_AD:        signal = new CSignalMA();                 break; // proxy: slope of cumulative line
       case IND_BWMFI:     signal = new CSignalMA();                 break; // proxy: slope of buffer 0
       case IND_GATOR:     signal = new CSignalZeroCross();          break; // proxy: upper histogram only
       case IND_FRACTALS:  signal = new CSignalFractals();           break; // Up=SELL, Down=BUY (reversal read)
       // IND_VOLUMES intentionally NOT wired - raw volume has no Buy/Sell polarity at all.
       default: return NULL; // not wired yet - table falls back to its own placeholder
      }
    if(signal == NULL) return NULL;
    signal.SetIndicator(indicator);
    // Backfill the flip history, capped at 500 bars (one-time cost per indicator)
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
       if(signal == NULL) continue;
       signal.CommitIfNewBar();
       signal.RefreshCurrent();
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
       if(indicator == NULL || indicator.Symbol() != symbol) continue;
       signal.CommitIfNewBar();
       signal.RefreshCurrent();
      }
   }
#endif // CSIGNALSCOLLECTION_MQH_IMPLEMENTATION

#endif // CSIGNALSCOLLECTION_MQH
