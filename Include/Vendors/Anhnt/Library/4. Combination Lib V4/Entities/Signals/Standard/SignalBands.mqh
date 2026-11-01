//+------------------------------------------------------------------+
//|                                                  SignalBands.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalBands.mqh: the rules over the bars of the list (V4 CBarControl::DirectionBands / DirectionEnvelopes), CSignal reads
//--- the buffers. The Upper / Lower crosses of V2 CSignalBollinger (their own histories) are not ported: one rule, one row per flip, as Python
#ifndef __SIGNALBANDS_MQH__
#define __SIGNALBANDS_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| Bollinger: the close above the middle band = Buy, below = Sell   |
 //+------------------------------------------------------------------+
 class CSignalBollinger : public CSignal
  {
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalBollinger(void) { this.m_type=OBJECT_DE_TYPE_SIGNAL_BOLLINGER; }
  };
 void CSignalBollinger::Directions(CArrayObj *list)
  {
   for(int i=0;i<list.Total();i++)
     {
      CBar *bar=list.At(i);
      double middle=this.m_buffer[0].value[i];
      this.m_direction[i]=(bar!=NULL && bar.Close()>middle ? SIGNAL_DIRECTION_BUY : (bar!=NULL && bar.Close()<middle ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
 //+------------------------------------------------------------------+
 //| Envelopes: closed below the lower band = Buy, above the upper    |
 //| band = Sell                                                      |
 //+------------------------------------------------------------------+
 class CSignalEnvelopes : public CSignal
  {
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalEnvelopes(void) { this.m_type=OBJECT_DE_TYPE_SIGNAL_ENVELOPES; }
  };
 void CSignalEnvelopes::Directions(CArrayObj *list)
  {
   for(int i=0;i<list.Total();i++)
     {
      CBar *bar=list.At(i);
      this.m_direction[i]=(bar!=NULL && bar.Close()<this.m_buffer[1].value[i] ? SIGNAL_DIRECTION_BUY : (bar!=NULL && bar.Close()>this.m_buffer[0].value[i] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALBANDS_MQH__
