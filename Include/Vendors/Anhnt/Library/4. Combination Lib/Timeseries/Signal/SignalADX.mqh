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

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalADX::CSignalADX(double min_adx)
   : m_min_adx(min_adx)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_ADX;
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
double CSignalADX::ComputeAt(int bar) const
  {
   double adx  = Buf(0, bar);
   double diP1 = Buf(1, bar);
   double diM1 = Buf(2, bar);
   double diP2 = Buf(1, bar + 1);
   double diM2 = Buf(2, bar + 1);
   if(adx  == EMPTY_VALUE || diP1 == EMPTY_VALUE ||
      diM1 == EMPTY_VALUE || diP2 == EMPTY_VALUE || diM2 == EMPTY_VALUE) return EMPTY_VALUE;
   if(m_min_adx > 0.0 && adx < m_min_adx) return EMPTY_VALUE;
   if(diP1 > diM1 && diP2 <= diM2) return SIGNAL_BUF_BUY;
   if(diP1 < diM1 && diP2 >= diM2) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_ADX_MQH__
