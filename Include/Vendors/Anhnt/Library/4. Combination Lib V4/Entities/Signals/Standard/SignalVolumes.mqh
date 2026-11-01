//+------------------------------------------------------------------+
//|                                                SignalVolumes.mqh |
//+------------------------------------------------------------------+
//--- New in V4 (V2 had no Volumes signal): the rule of V4 CBarControl::DirectionVolumes, CSignal reads the buffers (buffer 1: the moving average of the volumes)
#ifndef __SIGNALVOLUMES_MQH__
#define __SIGNALVOLUMES_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| Volumes: above its own moving average = Buy, under it = Sell      |
 //| (the activity, not the direction of the price)                   |
 //+------------------------------------------------------------------+
 class CSignalVolumes : public CSignal
  {
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalVolumes(void) { this.m_type=OBJECT_DE_TYPE_SIGNAL_VOLUMES; }
  };
 void CSignalVolumes::Directions(CArrayObj *list)
  {
   for(int i=0;i<::ArraySize(this.m_direction);i++)
     {
      double volume=this.m_buffer[0].value[i];
      double average=this.m_buffer[1].value[i];
      this.m_direction[i]=(volume>average ? SIGNAL_DIRECTION_BUY : (volume<average ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALVOLUMES_MQH__
