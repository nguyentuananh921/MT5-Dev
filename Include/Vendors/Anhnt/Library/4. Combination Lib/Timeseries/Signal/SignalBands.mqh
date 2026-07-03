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

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalBollinger::CSignalBollinger(void)
  {
  }

//+------------------------------------------------------------------+
CSignalBollinger::~CSignalBollinger(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalBollinger::Update(int bar)
  {
   if(m_ind == NULL)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   double upper = Buf(0, bar);
   double lower = Buf(1, bar);
   if(upper == EMPTY_VALUE || lower == EMPTY_VALUE)
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
   if(close[0] < lower)
      SetAt(bar, SIGNAL_BUY);
   else if(close[0] > upper)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

//+------------------------------------------------------------------+
//--- Envelopes: buffers 0=upper, 1=lower
//+------------------------------------------------------------------+
class CSignalEnvelopes : public CSignalBase
  {
public:
                    CSignalEnvelopes(void);
   virtual          ~CSignalEnvelopes(void);

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalEnvelopes::CSignalEnvelopes(void)
  {
  }

//+------------------------------------------------------------------+
CSignalEnvelopes::~CSignalEnvelopes(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalEnvelopes::Update(int bar)
  {
   if(m_ind == NULL)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   double upper = Buf(0, bar);
   double lower = Buf(1, bar);
   if(upper == EMPTY_VALUE || lower == EMPTY_VALUE)
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
   if(close[0] < lower)
      SetAt(bar, SIGNAL_BUY);
   else if(close[0] > upper)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

#endif // __SIGNAL_BANDS_MQH__
