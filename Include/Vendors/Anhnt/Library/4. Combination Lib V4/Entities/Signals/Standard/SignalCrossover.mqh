//+------------------------------------------------------------------+
//|                                              SignalCrossover.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalCrossover.mqh: the rule over the bars of the list (V4 CBarControl::DirectionTwoLines), CSignal reads the buffers.
//--- V2 CSignalMACDLineCross and CSignalADX are this rule with their lines (MACD 0/1, ADX 1/2): not ported
#ifndef __SIGNALCROSSOVER_MQH__
#define __SIGNALCROSSOVER_MQH__
 #include "..\Signal.mqh"
 //+------------------------------------------------------------------+
 //| The main line crossed the signal line upward = Buy, downward =   |
 //| Sell (MACD, ADX +DI / -DI, Alligator, Stochastic, RVI, Ichimoku); |
 //| with a zone, a Buy only from the oversold side, a Sell only from |
 //| the overbought one                                               |
 //+------------------------------------------------------------------+
 class CSignalTwoLineCross : public CSignal
  {
   private:
    int               m_main;
    int               m_signal;
    double            m_overbought;
    double            m_oversold;
   public:
    virtual void      Directions(CArrayObj *list);
                      CSignalTwoLineCross(const int main,const int signal,const double overbought=0.0,const double oversold=0.0) :
                         m_main(main),m_signal(signal),m_overbought(overbought),m_oversold(oversold) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL_TWOLINECROSS; }
  };
 void CSignalTwoLineCross::Directions(CArrayObj *list)
  {
   for(int i=0;i<::ArraySize(this.m_direction);i++)
     {
      double line=this.m_buffer[this.m_main].value[i];
      double other=this.m_buffer[this.m_signal].value[i];
      bool buy=(line>other && this.Previous(this.m_main,i)<=this.Previous(this.m_signal,i));
      bool sell=(line<other && this.Previous(this.m_main,i)>=this.Previous(this.m_signal,i));
      if(this.m_overbought>0.0 || this.m_oversold>0.0)
        {
         buy=(buy && line<=this.m_oversold);
         sell=(sell && line>=this.m_overbought);
        }
      this.m_direction[i]=(buy ? SIGNAL_DIRECTION_BUY : (sell ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
     }
  }
#endif // __SIGNALCROSSOVER_MQH__
