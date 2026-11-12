//+------------------------------------------------------------------+
//|                                                    SignalSAR.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalSAR.mqh: the rule over the bars of the list (V4 CBarControl::DirectionSar), CSignal reads the buffers
//--- Change from V4 Entities\Signals\Standard\SignalSAR.mqh: moved to UseCases\Judges\Signals\Standard, Directions(list) -> ComputeAt(index)
#ifndef __SIGNALSAR_MQH__
#define __SIGNALSAR_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| Parabolic SAR: below the close = Buy (uptrend), above = Sell      |
 //+------------------------------------------------------------------+
 class CSignalSAR : public CSignalJudge
  {
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalSAR(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_SAR; }
  };
 ENUM_SIGNAL_DIRECTION CSignalSAR::ComputeAt(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   double value=this.Buf(0,index);
   return (bar!=NULL && value<bar.Close() ? SIGNAL_DIRECTION_BUY : (bar!=NULL && value>bar.Close() ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALSAR_MQH__
