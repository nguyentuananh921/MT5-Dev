//+------------------------------------------------------------------+
//|                                                  SignalBands.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalBands.mqh: the rules over the bars of the list (V4 CBarControl::DirectionBands / DirectionEnvelopes), CSignal reads
//--- the buffers. The Upper / Lower crosses of V2 CSignalBollinger (their own histories) are not ported: one rule, one row per flip, as Python
//--- Change from V4 Entities\Signals\Standard\SignalBands.mqh: moved to UseCases\Judges\Signals\Standard, Directions(list) -> ComputeAt(index)
#ifndef __SIGNALBANDS_MQH__
#define __SIGNALBANDS_MQH__
 #include "..\SignalJudge.mqh"
 //+------------------------------------------------------------------+
 //| Bollinger: the close above the middle band = Buy, below = Sell   |
 //+------------------------------------------------------------------+
 class CSignalBollinger : public CSignalJudge
  {
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalBollinger(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_BOLLINGER; }
  };
 ENUM_SIGNAL_DIRECTION CSignalBollinger::ComputeAt(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   double middle=this.Buf(0,index);
   return (bar!=NULL && bar.Close()>middle ? SIGNAL_DIRECTION_BUY : (bar!=NULL && bar.Close()<middle ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
 //+------------------------------------------------------------------+
 //| Envelopes: closed below the lower band = Buy, above the upper    |
 //| band = Sell                                                      |
 //+------------------------------------------------------------------+
 class CSignalEnvelopes : public CSignalJudge
  {
   public:
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const;
                      CSignalEnvelopes(void) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_ENVELOPES; }
  };
 ENUM_SIGNAL_DIRECTION CSignalEnvelopes::ComputeAt(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   return (bar!=NULL && bar.Close()<this.Buf(1,index) ? SIGNAL_DIRECTION_BUY : (bar!=NULL && bar.Close()>this.Buf(0,index) ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
  }
#endif // __SIGNALBANDS_MQH__
