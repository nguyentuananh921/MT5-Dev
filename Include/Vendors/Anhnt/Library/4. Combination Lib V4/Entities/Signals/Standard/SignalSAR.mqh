//+------------------------------------------------------------------+
//|                                                    SignalSAR.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalSAR.mqh: the rule over the bars of the list (V4 CBarControl::DirectionSar), CSignal reads the buffers
#ifndef __SIGNALSAR_MQH__
#define __SIGNALSAR_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| Parabolic SAR: below the close = Buy (uptrend), above = Sell      |
 //+------------------------------------------------------------------+
 class CSignalSAR : public CSignal
  {
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalSAR(void) { this.m_type=OBJECT_DE_TYPE_SIGNAL_SAR; }
  };
 void CSignalSAR::Directions(CArrayObj *list)
  {
   for(int i=0;i<list.Total();i++)
     {
      CBar *bar=list.At(i);
      double value=this.m_buffer[0].value[i];
      this.m_direction[i]=(bar!=NULL && value<bar.Close() ? SIGNAL_DIRECTION_BUY : (bar!=NULL && value>bar.Close() ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALSAR_MQH__
