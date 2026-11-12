//+------------------------------------------------------------------+
//|                                             SignalOscillator.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalOscillator.mqh: the rule over the bars of the list (V4 CBarControl::DirectionOscillator), CSignal reads the buffers
//--- Change from V4 Entities\Signals\Standard\SignalOscillator.mqh: moved to UseCases\Judges\Signals\Standard, Directions(list) -> ComputeAt(index)
#ifndef __SIGNALOSCILLATOR_MQH__
#define __SIGNALOSCILLATOR_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| Left the oversold zone upward = Buy, left the overbought zone     |
 //| downward = Sell (RSI, CCI, DeMarker, WPR, MFI)                    |
 //+------------------------------------------------------------------+
 class CSignalOscillator : public CSignalJudge
  {
   private:
    double            m_overbought;
    double            m_oversold;
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalOscillator(const double overbought,const double oversold) : m_overbought(overbought),m_oversold(oversold) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_OSCILLATOR; }
  };
 ENUM_SIGNAL_DIRECTION CSignalOscillator::ComputeAt(const int index) const
  {
   double value=this.Buf(0,index);
   double before=this.Previous(0,index);
   return (before<=this.m_oversold && value>this.m_oversold ? SIGNAL_DIRECTION_BUY : (before>=this.m_overbought && value<this.m_overbought ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALOSCILLATOR_MQH__
