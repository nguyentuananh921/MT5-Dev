//+------------------------------------------------------------------+
//|                                              SignalZeroCross.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalZeroCross.mqh: the rule over the bars of the list (V4 CBarControl::DirectionZeroCross), CSignal reads the buffers
#ifndef __SIGNALZEROCROSS_MQH__
#define __SIGNALZEROCROSS_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| Crossed the level upward = Buy, downward = Sell                  |
 //+------------------------------------------------------------------+
 class CSignalZeroCross : public CSignal
  {
   private:
    double            m_level;
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalZeroCross(const double level=0.0) : m_level(level) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_ZEROCROSS; }
  };
 void CSignalZeroCross::Directions(CArrayObj *list)
  {
   for(int i=0;i<::ArraySize(this.m_direction);i++)
     {
      double value=this.m_buffer[0].value[i];
      double before=this.Previous(0,i);
      this.m_direction[i]=(value>this.m_level && before<=this.m_level ? SIGNAL_DIRECTION_BUY : (value<this.m_level && before>=this.m_level ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALZEROCROSS_MQH__
