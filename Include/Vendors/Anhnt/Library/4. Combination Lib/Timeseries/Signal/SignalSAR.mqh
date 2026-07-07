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

   virtual double   ComputeAt(int bar) const;
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
//| Compare SAR to close at bar - pure math, no storage             |
//+------------------------------------------------------------------+
double CSignalSAR::ComputeAt(int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   double sar = Buf(0, bar);
   if(sar == EMPTY_VALUE) return EMPTY_VALUE;
   double close[1];
   if(::CopyClose(m_indicator.Symbol(), m_indicator.Timeframe(), bar, 1, close) != 1) return EMPTY_VALUE;
   if(sar < close[0]) return SIGNAL_BUF_BUY;
   if(sar > close[0]) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_SAR_MQH__
