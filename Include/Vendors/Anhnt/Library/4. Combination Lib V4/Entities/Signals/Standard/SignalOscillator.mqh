//+------------------------------------------------------------------+
//|                                             SignalOscillator.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalOscillator.mqh: the rule over the bars of the list (V4 CBarControl::DirectionOscillator), CSignal reads the buffers
#ifndef __SIGNALOSCILLATOR_MQH__
#define __SIGNALOSCILLATOR_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| Left the oversold zone upward = Buy, left the overbought zone     |
 //| downward = Sell (RSI, CCI, DeMarker, WPR, MFI)                    |
 //+------------------------------------------------------------------+
 class CSignalOscillator : public CSignal
  {
   private:
    double            m_overbought;
    double            m_oversold;
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalOscillator(const double overbought,const double oversold) : m_overbought(overbought),m_oversold(oversold) { this.m_type=OBJECT_DE_TYPE_SIGNAL_OSCILLATOR; }
  };
 void CSignalOscillator::Directions(CArrayObj *list)
  {
   for(int i=0;i<::ArraySize(this.m_direction);i++)
     {
      double value=this.m_buffer[0].value[i];
      double before=this.Previous(0,i);
      this.m_direction[i]=(before<=this.m_oversold && value>this.m_oversold ? SIGNAL_DIRECTION_BUY : (before>=this.m_overbought && value<this.m_overbought ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALOSCILLATOR_MQH__
