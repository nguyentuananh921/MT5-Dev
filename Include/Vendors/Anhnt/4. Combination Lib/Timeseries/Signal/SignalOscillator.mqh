//+------------------------------------------------------------------+
//|                                             SignalOscillator.mqh |
//|  Overbought/oversold threshold signal for oscillators.          |
//|  Applies to: RSI, CCI, DeMarker, WPR, MFI (all single-buffer). |
//|  Wilder-style EXIT-from-zone signal (Anhnt, 2026-09-19):        |
//|  BUY  = value crosses back UP through the oversold line         |
//|  SELL = value crosses back DOWN through the overbought line     |
//|  (entering the zone is NOT a signal - that fired "Buy" straight |
//|  into a falling market, which read as reversed.)                |
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
class CSignalOscillator : public CSignalBase
  {
private:
   double           m_overbought;
   double           m_oversold;

public:
                    CSignalOscillator(double overbought = 70.0, double oversold = 30.0);
   virtual          ~CSignalOscillator(void);

   void             SetThresholds(double overbought, double oversold);

   virtual double   ComputeAt(int bar) const;
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

#endif // __SIGNAL_OSCILLATOR_MQH__
