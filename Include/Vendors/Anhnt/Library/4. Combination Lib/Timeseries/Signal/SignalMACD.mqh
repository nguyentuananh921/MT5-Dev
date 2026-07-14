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

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalMACDLineCross::CSignalMACDLineCross(void)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_MACD_LINECROSS;
  }

//+------------------------------------------------------------------+
CSignalMACDLineCross::~CSignalMACDLineCross(void)
  {
  }

//+------------------------------------------------------------------+
double CSignalMACDLineCross::ComputeAt(int bar) const
  {
   double macd1 = Buf(0, bar);
   double sig1  = Buf(1, bar);
   double macd2 = Buf(0, bar + 1);
   double sig2  = Buf(1, bar + 1);
   if(macd1 == EMPTY_VALUE || sig1 == EMPTY_VALUE ||
      macd2 == EMPTY_VALUE || sig2 == EMPTY_VALUE) return EMPTY_VALUE;
   if(macd1 > sig1 && macd2 <= sig2) return SIGNAL_BUF_BUY;
   if(macd1 < sig1 && macd2 >= sig2) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//--- MACD line crosses zero
//+------------------------------------------------------------------+
class CSignalMACDZeroCross : public CSignalBase
  {
public:
                    CSignalMACDZeroCross(void);
   virtual          ~CSignalMACDZeroCross(void);

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalMACDZeroCross::CSignalMACDZeroCross(void)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_MACD_ZEROCROSS;
  }

//+------------------------------------------------------------------+
CSignalMACDZeroCross::~CSignalMACDZeroCross(void)
  {
  }

//+------------------------------------------------------------------+
double CSignalMACDZeroCross::ComputeAt(int bar) const
  {
   double v1 = Buf(0, bar);
   double v2 = Buf(0, bar + 1);
   if(v1 == EMPTY_VALUE || v2 == EMPTY_VALUE) return EMPTY_VALUE;
   if(v1 > 0.0 && v2 <= 0.0) return SIGNAL_BUF_BUY;
   if(v1 < 0.0 && v2 >= 0.0) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_MACD_MQH__
