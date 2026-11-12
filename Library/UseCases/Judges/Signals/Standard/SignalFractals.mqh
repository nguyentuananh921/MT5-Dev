//+------------------------------------------------------------------+
//|                                               SignalFractals.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalFractals.mqh: the rule over the bars of the list (V4 CBarControl::DirectionFractals), CSignal reads the buffers
//--- Change from V4 Entities\Signals\Standard\SignalFractals.mqh: moved to UseCases\Judges\Signals\Standard, Directions(list) -> ComputeAt(index)
#ifndef __SIGNALFRACTALS_MQH__
#define __SIGNALFRACTALS_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| Fractals: known two bars after the middle bar, the signal is on  |
 //| that bar; an up fractal (a swing high) = Sell, a down one = Buy  |
 //+------------------------------------------------------------------+
 class CSignalFractals : public CSignalJudge
  {
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalFractals(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_FRACTALS; }
  };
 ENUM_SIGNAL_DIRECTION CSignalFractals::ComputeAt(const int index) const
  {
   bool upper=(index>=2 && ::MathIsValidNumber(this.Buf(0,index-2)));
   bool lower=(index>=2 && ::MathIsValidNumber(this.Buf(1,index-2)));
   return (lower && !upper ? SIGNAL_DIRECTION_BUY : (upper ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALFRACTALS_MQH__
