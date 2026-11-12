//+------------------------------------------------------------------+
//|                                             SignalOscillator.mqh |
//|  Overbought/oversold threshold signal for oscillators.          |
//|  Applies to: RSI, CCI, DeMarker, WPR, MFI (all single-buffer). |
//|  Base history (BUY/SELL): exit from a zone - cross up through   |
//|  oversold = BUY, cross down through overbought = SELL.           |
//|  Cross history (CrossXxx): every cross of either level, both     |
//|  directions, one entry per cross, for zone-change tracking.      |
//|                                                                  |
//|  Default thresholds per indicator:                               |
//|    RSI:      overbought=70,   oversold=30                        |
//|    CCI:      overbought=100,  oversold=-100                      |
//|    DeMarker: overbought=0.7,  oversold=0.3                       |
//|    WPR:      overbought=-20,  oversold=-80                       |
//|    MFI:      overbought=80,   oversold=20                        |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_OSCILLATOR_MQH__
#define __SIGNAL_OSCILLATOR_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
enum ENUM_OSC_CROSS
  {
   OSC_CROSS_OVERSOLD_UP,      // from <= oversold to > oversold
   OSC_CROSS_OVERSOLD_DOWN,    // from > oversold to <= oversold
   OSC_CROSS_OVERBOUGHT_UP,    // from < overbought to >= overbought
   OSC_CROSS_OVERBOUGHT_DOWN   // from >= overbought to < overbought
  };

//+------------------------------------------------------------------+
class CSignalOscillator : public CSignalBase
  {
private:
   double           m_overbought;
   double           m_oversold;
   CArrayLong       m_cross_time;   // datetime of each level cross
   CArrayInt        m_cross_kind;   // ENUM_OSC_CROSS of each level cross

   int              CrossesAt(int bar) const;   // bitmask of 1<<ENUM_OSC_CROSS
   void             AppendCrosses(datetime t, int mask);

public:
                    CSignalOscillator(double overbought = 70.0, double oversold = 30.0);
   virtual          ~CSignalOscillator(void);

   void             SetThresholds(double overbought, double oversold);

   virtual double   ComputeAt(int bar) const;

   int              CrossTotal(void)      const { return m_cross_time.Total(); }
   datetime         CrossTime(int index)  const;
   ENUM_OSC_CROSS   CrossKind(int index)  const;

   virtual void     CommitClosedBarExtra(void);
   virtual void     SyncHistoryExtra(int total_bars);
  };

//+------------------------------------------------------------------+
CSignalOscillator::CSignalOscillator(double overbought, double oversold)
   : m_overbought(overbought),
     m_oversold(oversold)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_OSCILLATOR;
  }

//+------------------------------------------------------------------+
CSignalOscillator::~CSignalOscillator(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalOscillator::SetThresholds(double overbought, double oversold)
  {
   m_overbought = overbought;
   m_oversold   = oversold;
  }

//+------------------------------------------------------------------+
//| Exit-from-zone cross between bar+1 and bar - pure math, no       |
//| storage. Returns a value only ON the crossing bar, so CSignalBase |
//| records exactly one flip per zone exit.                           |
//+------------------------------------------------------------------+
double CSignalOscillator::ComputeAt(int bar) const
  {
   double v    = Buf(0, bar);
   double prev = Buf(0, bar + 1);
   if(v == EMPTY_VALUE || prev == EMPTY_VALUE) return EMPTY_VALUE;
   if(prev <= m_oversold   && v > m_oversold)   return SIGNAL_BUF_BUY;    // left the oversold zone upward
   if(prev >= m_overbought && v < m_overbought) return SIGNAL_BUF_SELL;   // left the overbought zone downward
   return EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//| Level crosses between bar+1 and bar; each level is tested alone, |
//| so one jump over both levels gives two events.                   |
//+------------------------------------------------------------------+
int CSignalOscillator::CrossesAt(int bar) const
  {
   double v    = Buf(0, bar);
   double prev = Buf(0, bar + 1);
   if(v == EMPTY_VALUE || prev == EMPTY_VALUE) return 0;
   int mask = 0;
   if(prev <= m_oversold   && v >  m_oversold)   mask |= (1 << OSC_CROSS_OVERSOLD_UP);
   if(prev >  m_oversold   && v <= m_oversold)   mask |= (1 << OSC_CROSS_OVERSOLD_DOWN);
   if(prev <  m_overbought && v >= m_overbought) mask |= (1 << OSC_CROSS_OVERBOUGHT_UP);
   if(prev >= m_overbought && v <  m_overbought) mask |= (1 << OSC_CROSS_OVERBOUGHT_DOWN);
   return mask;
  }

//+------------------------------------------------------------------+
void CSignalOscillator::AppendCrosses(datetime t, int mask)
  {
   for(int k = 0; k < 4; k++)
      if((mask & (1 << k)) != 0)
        {
         m_cross_time.Add((long)t);
         m_cross_kind.Add(k);
        }
  }

//+------------------------------------------------------------------+
void CSignalOscillator::CommitClosedBarExtra(void)
  {
   if(m_indicator == NULL) return;
   datetime t[1];
   if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), 1, 1, t) != 1) return;
   int total = m_cross_time.Total();
   if(total > 0 && m_cross_time.At(total - 1) >= t[0]) return; // already committed
   AppendCrosses(t[0], CrossesAt(1));
  }

//+------------------------------------------------------------------+
void CSignalOscillator::SyncHistoryExtra(int total_bars)
  {
   if(m_indicator == NULL || total_bars <= 1) return;
   for(int shift = total_bars - 1; shift >= 1; shift--)
     {
      int mask = CrossesAt(shift);
      if(mask == 0) continue;
      datetime t[1];
      if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), shift, 1, t) != 1) continue;
      AppendCrosses(t[0], mask);
     }
  }

//+------------------------------------------------------------------+
datetime CSignalOscillator::CrossTime(int index) const
  {
   if(index < 0 || index >= m_cross_time.Total()) return 0;
   return (datetime)m_cross_time.At(index);
  }

//+------------------------------------------------------------------+
ENUM_OSC_CROSS CSignalOscillator::CrossKind(int index) const
  {
   if(index < 0 || index >= m_cross_kind.Total()) return OSC_CROSS_OVERSOLD_UP;
   return (ENUM_OSC_CROSS)m_cross_kind.At(index);
  }

#endif // __SIGNAL_OSCILLATOR_MQH__
