//+------------------------------------------------------------------+
//|                                                SignalVolumes.mqh |
//+------------------------------------------------------------------+
//--- New in V4 (V2 had no Volumes signal): the rule of V4 CBarControl::DirectionVolumes, CSignal reads the buffers (buffer 1: the moving average of the volumes)
//--- Change from V4 Entities\Signals\Standard\SignalVolumes.mqh: moved to UseCases\Judges\Signals\Standard, Directions(list) -> ComputeAt(index)
#ifndef __SIGNALVOLUMES_MQH__
#define __SIGNALVOLUMES_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| Volumes: above its own moving average = Buy, under it = Sell      |
 //| (the activity, not the direction of the price)                   |
 //+------------------------------------------------------------------+
 class CSignalVolumes : public CSignalJudge
  {
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalVolumes(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_VOLUMES; }
  };
 ENUM_SIGNAL_DIRECTION CSignalVolumes::ComputeAt(const int index) const
  {
   double volume=this.Buf(0,index);
   double average=this.Buf(1,index);
   return (volume>average ? SIGNAL_DIRECTION_BUY : (volume<average ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALVOLUMES_MQH__
