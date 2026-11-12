//+------------------------------------------------------------------+
//|                                              SignalZeroCross.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalZeroCross.mqh: the rule over the bars of the list (V4 CBarControl::DirectionZeroCross), CSignal reads the buffers
//--- Change from V4 Entities\Signals\Standard\SignalZeroCross.mqh: moved to UseCases\Judges\Signals\Standard, Directions(list) -> ComputeAt(index)
#ifndef __SIGNALZEROCROSS_MQH__
#define __SIGNALZEROCROSS_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| Crossed the level upward = Buy, downward = Sell                  |
 //+------------------------------------------------------------------+
 class CSignalZeroCross : public CSignalJudge
  {
   private:
    double            m_level;
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalZeroCross(const double level=0.0) : m_level(level) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_ZEROCROSS; }
  };
 ENUM_SIGNAL_DIRECTION CSignalZeroCross::ComputeAt(const int index) const
  {
   double value=this.Buf(0,index);
   double before=this.Previous(0,index);
   return (value>this.m_level && before<=this.m_level ? SIGNAL_DIRECTION_BUY : (value<this.m_level && before>=this.m_level ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALZEROCROSS_MQH__
