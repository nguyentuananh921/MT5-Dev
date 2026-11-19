//+------------------------------------------------------------------+
//|                                                  SignalJudge.mqh |
//| Use Cases (Clean Architecture): the rule of the signal of an     |
//| indicator. The rows are the entity CSignal's                     |
//+------------------------------------------------------------------+
//--- Split from UseCases\Judges\Signals\Signal.mqh (CSignal : CJudge, rule + rows + DB + events): the rule only, as V2 CSignalBase
//--- (m_indicator, Buf, ComputeAt) on CJudge (the loop of the bars). CSignalsCollection makes one for each CSignal and calls it
#ifndef __SIGNALJUDGE_MQH__
#define __SIGNALJUDGE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Judge.mqh"
 //#include "..\..\..\Entities\Indicators\IndicatorDE.mqh"
 #include "..\Source.mqh"   // V5: the judge reads its values through the port, it never knows the indicator 
#ifndef CSIGNALJUDGE_MQH_DECLARATION
#define CSIGNALJUDGE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The judge of the signal of a template (V2 CSignalBase)            |
 //+------------------------------------------------------------------+
 class CSignalJudge : public CJudge
  {
   private:    
    CSource          *m_source;                       // V5: the values it reads (the port; CIndicatorDE implements it, CIndicatorsCollection owns it): the one link of the signal to its indicator
    int               m_price_buffer;                 // New in V5: the buffer of the input of an indicator on indicator (its source), WRONG_VALUE: the input is the price
   protected:
    CArrayObj        *m_list;                         // The judge only: the bars judged (CBar, the oldest first), the series holds them
   //--- New in V5: what the rule compares with its bands: the close of the bar, or the source of an indicator on indicator (Bands on RSI: the RSI)
    double            Price(const int index) const;
   // V2 CSignalBase::Buf: the value of a buffer at the bar of the index, from the source (CSource::Value by the time of the bar); NaN where it has none
    double            Buf(const int buffer,const int index) const;
    double            Previous(const int buffer,const int index) const;
   public:
   // V2 CSignalBase::ComputeAt: the side of the bar at the index by the rule of the type (CSignalJudge: ATR, no direction)
    virtual ENUM_SIGNAL_DIRECTION ComputeAt(const int index) const { return SIGNAL_DIRECTION_NONE; }
   //--- A flip (CJudge::Calculate calls it): the side of the bar when it is not none and not the one of the bar before
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const;
   // V2 CSignalBase::SetIndicator: bound once (CSignalsCollection::GetOrCreateSignal)    
    void              SetSource(CSource *source)          { this.m_source=source;        }   // V5: from SetIndicator, the port
    CSource          *Source(void)                  const { return this.m_source;        }
   //--- (from V4 LoadBuffers) the bars to judge, the buffers refreshed; false when RAM has not the values from two bars before the first bar after `since`
    //bool              SetJudge(CArrayObj *list,const datetime since);
   //--- V5: the bars to judge (the controller refreshed the source and saw it ready: CSignalsCollection::Prepare)
    void              SetJudge(CArrayObj *list)           { this.m_list=list;            }
    void              SetPriceBuffer(const int buffer)    { this.m_price_buffer=buffer;  }   // New in V5: CSignalsCollection, the last buffer of an indicator on indicator
                      //CSignalJudge(void) : m_indicator(NULL),m_list(NULL) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL; }
                      CSignalJudge(void) : m_source(NULL),m_price_buffer(WRONG_VALUE),m_list(NULL) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL; }
  };
#endif // CSIGNALJUDGE_MQH_DECLARATION
#ifndef CSIGNALJUDGE_MQH_IMPLEMENTATION
#define CSIGNALJUDGE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| V2 CSignalBase::Buf: the value of a buffer at the bar of the index|
 //| (NaN: none, as numpy: every comparison with it is false)          |
 //+------------------------------------------------------------------+
 double CSignalJudge::Buf(const int buffer,const int index) const
  {
   //if(this.m_indicator==NULL || this.m_list==NULL || index<0 || index>=this.m_list.Total())
   if(this.m_source==NULL || this.m_list==NULL || index<0 || index>=this.m_list.Total())
      return ::MathSqrt(-1.0);
   CBar *bar=this.m_list.At(index);
   //double number=(bar!=NULL ? this.m_indicator.GetSeriesData().BufferValue(buffer,bar.Time()) : EMPTY_VALUE);
   double number=(bar!=NULL ? this.m_source.Value(buffer,bar.Time()) : EMPTY_VALUE);
   return (number==EMPTY_VALUE || !::MathIsValidNumber(number) ? ::MathSqrt(-1.0) : number);
  }
 //+------------------------------------------------------------------+
 //| The value of a buffer at the bar before the index (NaN for the    |
 //| first bar)                                                       |
 //+------------------------------------------------------------------+
 double CSignalJudge::Previous(const int buffer,const int index) const
  {
   return this.Buf(buffer,index-1);
  }
 double CSignalJudge::Price(const int index) const
  {
   if(this.m_price_buffer!=WRONG_VALUE)
      return this.Buf(this.m_price_buffer,index);
   CBar *bar=(this.m_list!=NULL && index>=0 && index<this.m_list.Total() ? this.m_list.At(index) : NULL);
   return (bar!=NULL ? bar.Close() : ::MathSqrt(-1.0));   // NaN: no side, as Buf
  }
 //+------------------------------------------------------------------+
 //| A flip of the signal on the bar at the index                      |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CSignalJudge::Find(const ENUM_BAR_INFOR_TYPE type,const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const ENUM_SIGNAL_DIRECTION side=this.ComputeAt(index);
   if(side==SIGNAL_DIRECTION_NONE || side==this.ComputeAt(index-1))
      return SIGNAL_DIRECTION_NO_PATTERN;   // not a change of the signal
   return side;
  } 
#endif // CSIGNALJUDGE_MQH_IMPLEMENTATION
#endif // __SIGNALJUDGE_MQH__
