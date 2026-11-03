//+------------------------------------------------------------------+
//|                                                     SignalMA.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalMA.mqh: the rule over the bars of the list (V4 CBarControl::DirectionSlope), CSignal reads the buffers
#ifndef __SIGNALMA_MQH__
#define __SIGNALMA_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| A line that rises is Buy, one that falls is Sell (the moving      |
 //| averages; the others that have no direction of their own, as V2) |
 //+------------------------------------------------------------------+
 class CSignalMA : public CSignal
  {
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalMA(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_MA; }
  };
 void CSignalMA::Directions(CArrayObj *list)
  {
   for(int i=0;i<::ArraySize(this.m_direction);i++)
     {
      double value=this.m_buffer[0].value[i];
      double before=this.Previous(0,i);
      this.m_direction[i]=(value>before ? SIGNAL_DIRECTION_BUY : (value<before ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALMA_MQH__
