//+------------------------------------------------------------------+
//|                                               SignalCrossover.mqh|
//|  Two-line crossover signal for indicators with main+signal line.|
//|  Applies to: Stochastic, RVI, Alligator.                        |
//|                                                                  |
//|  CSignalTwoLineCross — generic: buf_main crosses buf_signal     |
//|    BUY:  main[bar] > sig[bar]  &&  main[bar+1] <= sig[bar+1]   |
//|    SELL: main[bar] < sig[bar]  &&  main[bar+1] >= sig[bar+1]   |
//|                                                                  |
//|  Usage:                                                          |
//|    Stochastic: SetBuffers(0, 1) + SetGate(80, 20)              |
//|    RVI:        SetBuffers(0, 1) (no gate)                       |
//|    Alligator:  SetBuffers(jaw_buf, lips_buf) — pick line pair   |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_CROSSOVER_MQH__
#define __SIGNAL_CROSSOVER_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
class CSignalTwoLineCross : public CSignalBase
  {
private:
   int              m_buf_main;
   int              m_buf_signal;
   double           m_overbought;   // 0 = gate disabled
   double           m_oversold;     // 0 = gate disabled

public:
                    CSignalTwoLineCross(int buf_main    = 0,
                                        int buf_signal  = 1,
                                        double overbought = 0.0,
                                        double oversold   = 0.0);
   virtual          ~CSignalTwoLineCross(void);

   void             SetBuffers(int main_buf, int signal_buf);
   void             SetGate(double overbought, double oversold);

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalTwoLineCross::CSignalTwoLineCross(int buf_main,
                                          int buf_signal,
                                          double overbought,
                                          double oversold)
   : m_buf_main(buf_main),
     m_buf_signal(buf_signal),
     m_overbought(overbought),
     m_oversold(oversold)
  {
  }

//+------------------------------------------------------------------+
CSignalTwoLineCross::~CSignalTwoLineCross(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalTwoLineCross::SetBuffers(int main_buf, int signal_buf)
  {
   m_buf_main   = main_buf;
   m_buf_signal = signal_buf;
  }

//+------------------------------------------------------------------+
void CSignalTwoLineCross::SetGate(double overbought, double oversold)
  {
   m_overbought = overbought;
   m_oversold   = oversold;
  }

//+------------------------------------------------------------------+
//| Detect crossover and apply optional OB/OS gate                  |
//+------------------------------------------------------------------+
void CSignalTwoLineCross::Update(int bar)
  {
   double m1 = Buf(m_buf_main,   bar);
   double s1 = Buf(m_buf_signal, bar);
   double m2 = Buf(m_buf_main,   bar + 1);
   double s2 = Buf(m_buf_signal, bar + 1);
   if(m1 == EMPTY_VALUE || s1 == EMPTY_VALUE ||
      m2 == EMPTY_VALUE || s2 == EMPTY_VALUE)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   bool buy_cross  = (m1 > s1 && m2 <= s2);
   bool sell_cross = (m1 < s1 && m2 >= s2);
   bool gate_on    = (m_overbought > 0.0 || m_oversold > 0.0);
   if(gate_on)
     {
      if(buy_cross  && m1 > m_oversold)    buy_cross  = false;
      if(sell_cross && m1 < m_overbought)  sell_cross = false;
     }
   if(buy_cross)
      SetAt(bar, SIGNAL_BUY);
   else if(sell_cross)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

#endif // __SIGNAL_CROSSOVER_MQH__
