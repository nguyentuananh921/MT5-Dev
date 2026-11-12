//+------------------------------------------------------------------+
//|                                                     SignalMA.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalMA.mqh: the rule over the bars of the list (V4 CBarControl::DirectionSlope), CSignal reads the buffers
//--- Change from V4 Entities\Signals\Standard\SignalMA.mqh: moved to UseCases\Judges\Signals\Standard, Directions(list) -> ComputeAt(index)
#ifndef __SIGNALMA_MQH__
#define __SIGNALMA_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| A line that rises is Buy, one that falls is Sell (the moving      |
 //| averages; the others that have no direction of their own, as V2) |
 //+------------------------------------------------------------------+
 class CSignalMA : public CSignalJudge
  {
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalMA(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_MA; }
  };
 ENUM_SIGNAL_DIRECTION CSignalMA::ComputeAt(const int index) const
  {
   double value=this.Buf(0,index);
   double before=this.Previous(0,index);
   return (value>before ? SIGNAL_DIRECTION_BUY : (value<before ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALMA_MQH__
