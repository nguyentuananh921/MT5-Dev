//+------------------------------------------------------------------+
//|                                               SignalSourceMA.mqh |
//+------------------------------------------------------------------+
//--- New in V5 (from SignalVolumes.mqh, the rule of V4 CBarControl::DirectionVolumes): the rule of every MA made on another indicator,
//--- Volumes against their average is one of them. Buffer 0: the MA, its last buffer: the source (CIndicatorDE::SetSource)
#ifndef __SIGNALSOURCEMA_MQH__
#define __SIGNALSOURCEMA_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| An MA on a source: the source above its MA = Buy, under it = Sell |
 //+------------------------------------------------------------------+
 class CSignalSourceMA : public CSignalJudge
  {
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalSourceMA(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_SOURCE_MA; }
  };
 ENUM_SIGNAL_DIRECTION CSignalSourceMA::ComputeAt(const int index) const
  {
   double average=this.Buf(0,index);
   double source=this.Buf(1,index);
   return (source>average ? SIGNAL_DIRECTION_BUY : (source<average ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALSOURCEMA_MQH__
