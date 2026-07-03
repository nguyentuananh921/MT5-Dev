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

   virtual void     Update(int bar = 1);
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
//| Compute slope signal at bar and store in buffer                 |
//+------------------------------------------------------------------+
void CSignalMA::Update(int bar)
  {
   double v1 = Buf(0, bar);
   double v2 = Buf(0, bar + 1);
   if(v1 == EMPTY_VALUE || v2 == EMPTY_VALUE)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   if(v1 > v2)
      SetAt(bar, SIGNAL_BUY);
   else if(v1 < v2)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

#endif // __SIGNAL_MA_MQH__
