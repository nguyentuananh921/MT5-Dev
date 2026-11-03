//+------------------------------------------------------------------+
//|                                                       Signal.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
//--- Change from V2 Timeseries\Signal\SignalBase.mqh: renamed CSignalBase -> CSignal (the name of the layer as CBar). As CBar: a row (a flip of a template
//--- on a bar) and the base of the judges (the children: the rule of a type, V2 names). As the judges of CBar (CBar::Calculate) the judge only applies its rule:
//--- MT5 calculates the indicator, CIndicatorSeriesDE holds its buffers in RAM, the judge reads them by the time of each bar. The rows, the events and the
//--- database are the ones of CSignalSeriesDE (as CBarControl). The rules moved from V4 CBarControl::Direction*; Python signals.py says the same
#ifndef __SIGNAL_MQH__
#define __SIGNAL_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Bases\BaseObjExt.mqh"
 #include "..\Bar\Bar.mqh"
 #include "..\Indicators\IndicatorDE.mqh"
 #define RSI_OVERBOUGHT                   70.0                           // the zones of the oscillators (V2 CSignalOscillator, Python signals.py)
 #define RSI_OVERSOLD                     30.0
 #define CCI_OVERBOUGHT                   100.0
 #define CCI_OVERSOLD                     -100.0
 #define DEMARKER_OVERBOUGHT              0.7
 #define DEMARKER_OVERSOLD                0.3
 #define WPR_OVERBOUGHT                   -20.0
 #define WPR_OVERSOLD                     -80.0
 #define MFI_OVERBOUGHT                   80.0
 #define MFI_OVERSOLD                     20.0
 #define STOCHASTIC_OVERBOUGHT            80.0
 #define STOCHASTIC_OVERSOLD              20.0
 #define MOMENTUM_LEVEL                   100.0                          // the line the Momentum indicator crosses
#ifndef CSIGNAL_MQH_DECLARATION
#define CSIGNAL_MQH_DECLARATION
 struct SBarBuffer   // one buffer of an indicator, a value for each bar of the list judged (NaN where the indicator has none)
  {
   double            value[];
  };
 //+------------------------------------------------------------------+
 //| A flip of the signal of a template, and the base of the judges   |
 //+------------------------------------------------------------------+
 class CSignal : public CBaseObjExt
  {
   private:
    datetime          m_time;                         // A row: the open time of the bar
    ENUM_SIGNAL_DIRECTION m_signal_direction;         // A row: the side the signal flipped to
   //--- The buffers of the indicator over the bars of the list, by the time of each bar (false: a bar it has no value of is judged)
    bool              LoadBuffers(CIndicatorSeriesDE *data,CArrayObj *list,const int judged_from);
   protected:
    SBarBuffer        m_buffer[];                     // The judge: the buffers aligned with the bars of the list judged now
    ENUM_SIGNAL_DIRECTION m_direction[];              // The judge: the side of each bar by the rule (SIGNAL_DIRECTION_NONE: none)
    double            Previous(const int buffer,const int index) const;
   public:
   //--- The rule of the type, bar by bar (CSignal: ATR, no direction, never a signal)
    virtual void      Directions(CArrayObj *list) {}
   //--- A row
    datetime          Time(void)                    const { return this.m_time;            }
    ENUM_SIGNAL_DIRECTION SignalDirection(void)     const { return this.m_signal_direction;}
   //--- The judge (as CBar::Calculate): the bars of the list after `since` (the newest bar already judged) and before the forming one; a bar whose side is not
   //--- none and is not the one of the bar before is a row (row_time, row_side). The buffers are the ones of the indicator in RAM (refreshed first).
   //--- Returns the rows, -1 when the indicator has not the values of the bars yet
    int               Calculate(CIndicatorDE *indicator,CArrayObj *list,const datetime since,long &row_time[],long &row_side[]);
   //--- The rows by the time of their bar
    virtual int       Compare(const CObject *node,const int mode=0) const;
                      CSignal(void);
                      CSignal(const datetime time,const ENUM_SIGNAL_DIRECTION direction);
  };
#endif // CSIGNAL_MQH_DECLARATION
#ifndef CSIGNAL_MQH_IMPLEMENTATION
#define CSIGNAL_MQH_IMPLEMENTATION
 CSignal::CSignal(void) : m_time(0),m_signal_direction(SIGNAL_DIRECTION_NONE)
  {
   this.m_object_type=OBJECT_DE_TYPE_SIGNAL;
  }
 CSignal::CSignal(const datetime time,const ENUM_SIGNAL_DIRECTION direction) : m_time(time),m_signal_direction(direction)
  {
   this.m_object_type=OBJECT_DE_TYPE_SIGNAL;
  }
 int CSignal::Compare(const CObject *node,const int mode=0) const
  {
   const CSignal *compared=node;
   return (this.m_time>compared.Time() ? 1 : (this.m_time<compared.Time() ? -1 : 0));
  }
 //+------------------------------------------------------------------+
 //| The value of a buffer at the bar before the index (NaN for the    |
 //| first bar)                                                       |
 //+------------------------------------------------------------------+
 double CSignal::Previous(const int buffer,const int index) const
  {
   return (index>0 ? this.m_buffer[buffer].value[index-1] : ::MathSqrt(-1.0));
  }
 //+------------------------------------------------------------------+
 //| The buffers over the bars of the list, by time (NaN where the     |
 //| indicator has none); every bar from two before the first bar      |
 //| judged must have its values in RAM                                |
 //+------------------------------------------------------------------+
 bool CSignal::LoadBuffers(CIndicatorSeriesDE *data,CArrayObj *list,const int judged_from)
  {
   int count=data.IndBuffersTotal();
   ::ArrayResize(this.m_buffer,count);
   for(int b=0;b<count;b++)
     {
      ::ArrayResize(this.m_buffer[b].value,list.Total());
      for(int i=0;i<list.Total();i++)
        {
         CBar *bar=list.At(i);
         CIndicatorData *value=(bar!=NULL ? data.GetIndDataByTime(b,bar.Time()) : NULL);
         if(value==NULL && i>=judged_from-2)
            return false;   // RAM has not this bar yet (the rules look two bars back at most: Fractals)
         double number=(value!=NULL ? value.BufferValue() : EMPTY_VALUE);
         this.m_buffer[b].value[i]=(number==EMPTY_VALUE || !::MathIsValidNumber(number) ? ::MathSqrt(-1.0) : number);   // NaN: every comparison with it is false, as in numpy
        }
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The flips of the signal after `since`                             |
 //+------------------------------------------------------------------+
 int CSignal::Calculate(CIndicatorDE *indicator,CArrayObj *list,const datetime since,long &row_time[],long &row_side[])
  {
   ::ArrayFree(row_time);
   ::ArrayFree(row_side);
   if(indicator==NULL || list==NULL || list.Total()<2)
      return 0;
   datetime forming=0;
   if(!::SeriesInfoInteger(indicator.Symbol(),indicator.Timeframe(),SERIES_LASTBAR_DATE,forming))
      return 0;
   //--- The first bar to judge: the oldest after `since`
   int judged_from=list.Total();
   for(int i=list.Total()-1;i>=0;i--)
     {
      CBar *bar=list.At(i);
      if(bar==NULL || bar.Time()<=since)
         break;
      judged_from=i;
     }
   CIndicatorSeriesDE *data=indicator.GetSeriesData();
   data.Refresh();   // the bars up to now, the one that just closed with its last value
   if(!this.LoadBuffers(data,list,judged_from))
      return -1;
   ::ArrayResize(this.m_direction,list.Total());
   ::ArrayInitialize(this.m_direction,SIGNAL_DIRECTION_NONE);
   this.Directions(list);
   for(int i=list.Total()-1;i>=1 && i>=judged_from;i--)
     {
      CBar *bar=list.At(i);
      if(bar==NULL || bar.Time()>=forming)
         continue;   // the forming bar is not judged
      if(this.m_direction[i]==SIGNAL_DIRECTION_NONE || this.m_direction[i]==this.m_direction[i-1])
         continue;   // not a change of the signal
      int total=::ArraySize(row_time);
      ::ArrayResize(row_time,total+1);
      ::ArrayResize(row_side,total+1);
      row_time[total]=(long)bar.Time();
      row_side[total]=(long)this.m_direction[i];
     }
   return ::ArraySize(row_time);
  }
#endif // CSIGNAL_MQH_IMPLEMENTATION
#endif // __SIGNAL_MQH__
