//+------------------------------------------------------------------+
//|                                               SignalZeroCross.mqh|
//|  Zero-line (or level) cross signal for single-buffer indicators.|
//|  Applies to: AO, AC, Force, Momentum, OsMA, TRIX, Chaikin, OBV.|
//|  BUY  = value crosses above zero_level (neg → pos)             |
//|  SELL = value crosses below zero_level (pos → neg)             |
//|                                                                  |
//|  Note: Momentum uses level=100 instead of 0.                    |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_ZEROCROSS_MQH__
#define __SIGNAL_ZEROCROSS_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
class CSignalZeroCross : public CSignalBase
  {
private:
   double           m_zero_level;

public:
                    CSignalZeroCross(double zero_level = 0.0);
   virtual          ~CSignalZeroCross(void);

   void             SetZeroLevel(double level);

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalZeroCross::CSignalZeroCross(double zero_level)
   : m_zero_level(zero_level)
  {
  }

//+------------------------------------------------------------------+
CSignalZeroCross::~CSignalZeroCross(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalZeroCross::SetZeroLevel(double level)
  {
   m_zero_level = level;
  }

//+------------------------------------------------------------------+
//| Detect cross of zero_level between bar and bar+1 - pure math    |
//+------------------------------------------------------------------+
double CSignalZeroCross::ComputeAt(int bar) const
  {
   double v1 = Buf(0, bar);
   double v2 = Buf(0, bar + 1);
   if(v1 == EMPTY_VALUE || v2 == EMPTY_VALUE) return EMPTY_VALUE;
   if(v1 > m_zero_level && v2 <= m_zero_level) return SIGNAL_BUF_BUY;
   if(v1 < m_zero_level && v2 >= m_zero_level) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_ZEROCROSS_MQH__
