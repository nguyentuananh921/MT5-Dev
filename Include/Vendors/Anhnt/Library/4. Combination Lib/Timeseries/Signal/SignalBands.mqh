//+------------------------------------------------------------------+
//|                                                  SignalBands.mqh |
//|  Signal for band-type indicators: price vs upper/lower band.    |
//|                                                                  |
//|  CSignalBollinger  (Bollinger Bands: buf 0=upper, 1=lower, 2=mid)
//|    BUY:  close[bar] < lower band                                |
//|    SELL: close[bar] > upper band                                |
//|                                                                  |
//|  CSignalEnvelopes  (Envelopes: buf 0=upper, 1=lower)            |
//|    Same logic as Bollinger.                                      |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_BANDS_MQH__
#define __SIGNAL_BANDS_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
//--- Bollinger Bands: buffers 0=upper, 1=lower, 2=middle
//+------------------------------------------------------------------+
class CSignalBollinger : public CSignalBase
  {
public:
                    CSignalBollinger(void);
   virtual          ~CSignalBollinger(void);

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalBollinger::CSignalBollinger(void)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_BOLLINGER;
  }

//+------------------------------------------------------------------+
CSignalBollinger::~CSignalBollinger(void)
  {
  }

//+------------------------------------------------------------------+
double CSignalBollinger::ComputeAt(int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   double upper = Buf(0, bar);
   double lower = Buf(1, bar);
   if(upper == EMPTY_VALUE || lower == EMPTY_VALUE) return EMPTY_VALUE;
   double close[1];
   if(::CopyClose(m_indicator.Symbol(), m_indicator.Timeframe(), bar, 1, close) != 1) return EMPTY_VALUE;
   if(close[0] < lower) return SIGNAL_BUF_BUY;
   if(close[0] > upper) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//--- Envelopes: buffers 0=upper, 1=lower
//+------------------------------------------------------------------+
class CSignalEnvelopes : public CSignalBase
  {
public:
                    CSignalEnvelopes(void);
   virtual          ~CSignalEnvelopes(void);

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalEnvelopes::CSignalEnvelopes(void)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_ENVELOPES;
  }

//+------------------------------------------------------------------+
CSignalEnvelopes::~CSignalEnvelopes(void)
  {
  }

//+------------------------------------------------------------------+
double CSignalEnvelopes::ComputeAt(int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   double upper = Buf(0, bar);
   double lower = Buf(1, bar);
   if(upper == EMPTY_VALUE || lower == EMPTY_VALUE) return EMPTY_VALUE;
   double close[1];
   if(::CopyClose(m_indicator.Symbol(), m_indicator.Timeframe(), bar, 1, close) != 1) return EMPTY_VALUE;
   if(close[0] < lower) return SIGNAL_BUF_BUY;
   if(close[0] > upper) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_BANDS_MQH__
