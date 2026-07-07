//+------------------------------------------------------------------+
//|                                                     SignalMA.mqh |
//|  Slope-direction signal for MA-family indicators.               |
//|  Applies to: MA, AMA, DEMA, TEMA, FRAMA, VIDYA (buffer 0).     |
//|  BUY  = line rising  (buf[bar] > buf[bar+1])                    |
//|  SELL = line falling (buf[bar] < buf[bar+1])                    |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_MA_MQH__
#define __SIGNAL_MA_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
class CSignalMA : public CSignalBase
  {
public:
                    CSignalMA(void);
   virtual          ~CSignalMA(void);

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalMA::CSignalMA(void)
  {
  }

//+------------------------------------------------------------------+
CSignalMA::~CSignalMA(void)
  {
  }

//+------------------------------------------------------------------+
//| Compute slope signal at bar - pure math, no storage              |
//+------------------------------------------------------------------+
double CSignalMA::ComputeAt(int bar) const
  {
   double v1 = Buf(0, bar);
   double v2 = Buf(0, bar + 1);
   if(v1 == EMPTY_VALUE || v2 == EMPTY_VALUE) return EMPTY_VALUE;
   if(v1 > v2) return SIGNAL_BUF_BUY;
   if(v1 < v2) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_MA_MQH__
