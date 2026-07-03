//+------------------------------------------------------------------+
//|                                                   SignalMACD.mqh |
//|  Two signal modes for MACD (buf 0 = MACD line, buf 1 = signal). |
//|                                                                  |
//|  CSignalMACDLineCross  — MACD line crosses Signal line          |
//|    BUY:  MACD[bar] > Signal[bar]  &&  MACD[bar+1] <= Signal[bar+1]
//|    SELL: MACD[bar] < Signal[bar]  &&  MACD[bar+1] >= Signal[bar+1]
//|                                                                  |
//|  CSignalMACDZeroCross  — MACD line crosses zero                 |
//|    BUY:  MACD[bar] > 0  &&  MACD[bar+1] <= 0                   |
//|    SELL: MACD[bar] < 0  &&  MACD[bar+1] >= 0                   |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_MACD_MQH__
#define __SIGNAL_MACD_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
//--- MACD line vs Signal line crossover
//+------------------------------------------------------------------+
class CSignalMACDLineCross : public CSignalBase
  {
public:
                    CSignalMACDLineCross(void);
   virtual          ~CSignalMACDLineCross(void);

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalMACDLineCross::CSignalMACDLineCross(void)
  {
  }

//+------------------------------------------------------------------+
CSignalMACDLineCross::~CSignalMACDLineCross(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalMACDLineCross::Update(int bar)
  {
   double macd1 = Buf(0, bar);
   double sig1  = Buf(1, bar);
   double macd2 = Buf(0, bar + 1);
   double sig2  = Buf(1, bar + 1);
   if(macd1 == EMPTY_VALUE || sig1 == EMPTY_VALUE ||
      macd2 == EMPTY_VALUE || sig2 == EMPTY_VALUE)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   if(macd1 > sig1 && macd2 <= sig2)
      SetAt(bar, SIGNAL_BUY);
   else if(macd1 < sig1 && macd2 >= sig2)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

//+------------------------------------------------------------------+
//--- MACD line crosses zero
//+------------------------------------------------------------------+
class CSignalMACDZeroCross : public CSignalBase
  {
public:
                    CSignalMACDZeroCross(void);
   virtual          ~CSignalMACDZeroCross(void);

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalMACDZeroCross::CSignalMACDZeroCross(void)
  {
  }

//+------------------------------------------------------------------+
CSignalMACDZeroCross::~CSignalMACDZeroCross(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalMACDZeroCross::Update(int bar)
  {
   double v1 = Buf(0, bar);
   double v2 = Buf(0, bar + 1);
   if(v1 == EMPTY_VALUE || v2 == EMPTY_VALUE)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   if(v1 > 0.0 && v2 <= 0.0)
      SetAt(bar, SIGNAL_BUY);
   else if(v1 < 0.0 && v2 >= 0.0)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

#endif // __SIGNAL_MACD_MQH__
