//+------------------------------------------------------------------+
//|                                               SignalFractals.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalFractals.mqh: the rule over the bars of the list (V4 CBarControl::DirectionFractals), CSignal reads the buffers
#ifndef __SIGNALFRACTALS_MQH__
#define __SIGNALFRACTALS_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| Fractals: known two bars after the middle bar, the signal is on  |
 //| that bar; an up fractal (a swing high) = Sell, a down one = Buy  |
 //+------------------------------------------------------------------+
 class CSignalFractals : public CSignal
  {
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalFractals(void) { this.m_type=OBJECT_DE_TYPE_SIGNAL_FRACTALS; }
  };
 void CSignalFractals::Directions(CArrayObj *list)
  {
   for(int i=0;i<::ArraySize(this.m_direction);i++)
     {
      bool upper=(i>=2 && ::MathIsValidNumber(this.m_buffer[0].value[i-2]));
      bool lower=(i>=2 && ::MathIsValidNumber(this.m_buffer[1].value[i-2]));
      this.m_direction[i]=(lower && !upper ? SIGNAL_DIRECTION_BUY : (upper ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALFRACTALS_MQH__
