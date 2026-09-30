//+------------------------------------------------------------------+
//|                                               SignalFractals.mqh |
//|  Signal for Fractals (buf 0=Upper, 1=Lower, EMPTY_VALUE on most  |
//|  bars - a native fractal buffer only holds a price on the bar it |
//|  confirms, always 2 bars after the actual swing high/low).       |
//|                                                                  |
//|  Classic reversal reading: an Up Fractal marks a confirmed swing |
//|  high (SELL), a Down Fractal marks a confirmed swing low (BUY).  |
//|  Presence-based, not a cross/threshold - unlike every other      |
//|  Signal class here, no bar+1 comparison is needed.                |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_FRACTALS_MQH__
#define __SIGNAL_FRACTALS_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
class CSignalFractals : public CSignalBase
  {
public:
                    CSignalFractals(void);
   virtual          ~CSignalFractals(void);

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalFractals::CSignalFractals(void)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_FRACTALS;
  }

//+------------------------------------------------------------------+
CSignalFractals::~CSignalFractals(void)
  {
  }

//+------------------------------------------------------------------+
//| Up Fractal present -> SELL (confirmed swing high);               |
//| Down Fractal present -> BUY (confirmed swing low)                |
//+------------------------------------------------------------------+
double CSignalFractals::ComputeAt(int bar) const
  {
   double up   = Buf(0, bar);
   double down = Buf(1, bar);
   if(up   != EMPTY_VALUE) return SIGNAL_BUF_SELL;
   if(down != EMPTY_VALUE) return SIGNAL_BUF_BUY;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_FRACTALS_MQH__
