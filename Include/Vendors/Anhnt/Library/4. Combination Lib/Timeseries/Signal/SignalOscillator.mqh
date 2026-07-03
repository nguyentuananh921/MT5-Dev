//+------------------------------------------------------------------+
//|                                             SignalOscillator.mqh |
//|  Overbought/oversold threshold signal for oscillators.          |
//|  Applies to: RSI, CCI, DeMarker, WPR, MFI (all single-buffer). |
//|  BUY  = value < oversold threshold                              |
//|  SELL = value > overbought threshold                            |
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

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalOscillator::CSignalOscillator(double overbought, double oversold)
   : m_overbought(overbought),
     m_oversold(oversold)
  {
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
//| Compare value to thresholds and store result in buffer          |
//+------------------------------------------------------------------+
void CSignalOscillator::Update(int bar)
  {
   double v = Buf(0, bar);
   if(v == EMPTY_VALUE)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   if(v < m_oversold)
      SetAt(bar, SIGNAL_BUY);
   else if(v > m_overbought)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

#endif // __SIGNAL_OSCILLATOR_MQH__
