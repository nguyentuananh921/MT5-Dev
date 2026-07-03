//+------------------------------------------------------------------+
//|                                                    SignalSAR.mqh |
//|  Signal for Parabolic SAR: compare SAR value vs bar close.      |
//|  BUY  = SAR below close (uptrend)                               |
//|  SELL = SAR above close (downtrend)                             |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_SAR_MQH__
#define __SIGNAL_SAR_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
class CSignalSAR : public CSignalBase
  {
public:
                    CSignalSAR(void);
   virtual          ~CSignalSAR(void);

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalSAR::CSignalSAR(void)
  {
  }

//+------------------------------------------------------------------+
CSignalSAR::~CSignalSAR(void)
  {
  }

//+------------------------------------------------------------------+
//| Compare SAR to close at bar and store in buffer                 |
//+------------------------------------------------------------------+
void CSignalSAR::Update(int bar)
  {
   if(m_ind == NULL)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   double sar = Buf(0, bar);
   if(sar == EMPTY_VALUE)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   double close[1];
   if(::CopyClose(m_ind.Symbol(), m_ind.Timeframe(), bar, 1, close) != 1)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   if(sar < close[0])
      SetAt(bar, SIGNAL_BUY);
   else if(sar > close[0])
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

#endif // __SIGNAL_SAR_MQH__
