//+------------------------------------------------------------------+
//|                                                    SignalADX.mqh |
//|  Signal for ADX / ADXW based on DI+/DI- crossover.             |
//|  Buffers: 0=ADX, 1=+DI, 2=-DI                                  |
//|  BUY  = +DI crosses above -DI                                   |
//|  SELL = +DI crosses below -DI                                   |
//|  NONE = no cross, or ADX < min_strength (trend too weak)        |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_ADX_MQH__
#define __SIGNAL_ADX_MQH__
#include "SignalBase.mqh"

//+------------------------------------------------------------------+
class CSignalADX : public CSignalBase
  {
private:
   double           m_min_adx;   // minimum ADX to generate signal (0 = no gate)

public:
                    CSignalADX(double min_adx = 0.0);
   virtual          ~CSignalADX(void);

   void             SetMinStrength(double min_adx);

   virtual void     Update(int bar = 1);
  };

//+------------------------------------------------------------------+
CSignalADX::CSignalADX(double min_adx)
   : m_min_adx(min_adx)
  {
  }

//+------------------------------------------------------------------+
CSignalADX::~CSignalADX(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalADX::SetMinStrength(double min_adx)
  {
   m_min_adx = min_adx;
  }

//+------------------------------------------------------------------+
//| Detect DI+/DI- crossover; gate by ADX strength if configured   |
//+------------------------------------------------------------------+
void CSignalADX::Update(int bar)
  {
   double adx  = Buf(0, bar);
   double diP1 = Buf(1, bar);
   double diM1 = Buf(2, bar);
   double diP2 = Buf(1, bar + 1);
   double diM2 = Buf(2, bar + 1);
   if(adx  == EMPTY_VALUE || diP1 == EMPTY_VALUE ||
      diM1 == EMPTY_VALUE || diP2 == EMPTY_VALUE || diM2 == EMPTY_VALUE)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   if(m_min_adx > 0.0 && adx < m_min_adx)
     {
      SetAt(bar, SIGNAL_NONE);
      return;
     }
   if(diP1 > diM1 && diP2 <= diM2)
      SetAt(bar, SIGNAL_BUY);
   else if(diP1 < diM1 && diP2 >= diM2)
      SetAt(bar, SIGNAL_SELL);
   else
      SetAt(bar, SIGNAL_NONE);
  }

#endif // __SIGNAL_ADX_MQH__
