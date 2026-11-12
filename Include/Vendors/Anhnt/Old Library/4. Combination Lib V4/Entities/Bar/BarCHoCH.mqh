//+------------------------------------------------------------------+
//|                                                     BarCHoCH.mqh |
//+------------------------------------------------------------------+
//--- Change of Character: the bar whose close breaks a Swing High below the one before (LH, Buy) or a Swing Low above the one before (HL, Sell).
//--- Change from V2 MarketStructureSeries.mqh (CMarketStructureSeries : CBaseObj, one class for BOS and CHoCH, with the time and the price of the broken swing):
//--- a CBar now, the break bar is itself; the broken swing is a CBarSwing, found again by CBarSwing::FindBrokenHigh / FindBrokenLow (Python structure.py)
#ifndef __BARCHOCH_MQH__
#define __BARCHOCH_MQH__
 #include "Bar.mqh"
 #include "BarSwing.mqh"
#ifndef CBARCHOCH_MQH_DECLARATION
#define CBARCHOCH_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| A Change of Character found on a bar                              |
 //+------------------------------------------------------------------+
 class CBarCHoCH : public CBar
  {
   private:
    CBarSwing        *m_swing_high;          // The judge only: CBarControl holds it, set with the parameters of Swing High
    CBarSwing        *m_swing_low;           // The judge only: CBarControl holds it, set with the parameters of Swing Low
   public:
   //--- Does this class find the type
    static bool       IsFound(const ENUM_BAR_INFOR_TYPE type) { return (type==BAR_INFOR_TYPE_CHOCH); }
   //--- The judge: the judges of the swings (their bars and parameters are set by CBarControl)
    void              SetJudge(CBarSwing *swing_high,CBarSwing *swing_low);
   //--- The method of the type judges the bar at the index of the list of the judges (CBar::Calculate calls it)
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const;
   //--- The event of a new CHoCH, a row of this class
    virtual ushort    Event(void) const { return (ushort)SERIES_EVENTS_CHOCH; }
    virtual CBar     *NewRow(CBar *bar,const long type,const long group,const long direction) const { return new CBarCHoCH(bar,type,group,direction); }
   //--- Buy when the close breaks a LH, Sell when it breaks a HL (Buy first when it breaks both), SIGNAL_DIRECTION_NO_PATTERN when it does not
    ENUM_SIGNAL_DIRECTION FindCHoCH(const int index) const;
   //--- The judge, and a row: the break bar with the type, its group and the side found on it
                      CBarCHoCH(void) : m_swing_high(NULL),m_swing_low(NULL) { this.m_object_type=OBJECT_DE_TYPE_SERIES_CHOCH; }
                      CBarCHoCH(CBar *bar,const long type,const long group,const long direction);
  };
#endif // CBARCHOCH_MQH_DECLARATION
#ifndef CBARCHOCH_MQH_IMPLEMENTATION
#define CBARCHOCH_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| A row: the break bar joined with the type and the side            |
 //+------------------------------------------------------------------+
 CBarCHoCH::CBarCHoCH(CBar *bar,const long type,const long group,const long direction) : m_swing_high(NULL),m_swing_low(NULL)
  {
   this.SetBar(bar);
   this.m_object_type=OBJECT_DE_TYPE_SERIES_CHOCH;
   this.SetProperty(BAR_PROP_INFOR_GROUP,group);
   this.SetProperty(BAR_PROP_INFOR_TYPE,type);
   this.SetProperty(BAR_PROP_SIGNAL_DIRECTION,direction);
  }
 void CBarCHoCH::SetJudge(CBarSwing *swing_high,CBarSwing *swing_low)
  {
   this.m_swing_high=swing_high;
   this.m_swing_low=swing_low;
  }
 ENUM_SIGNAL_DIRECTION CBarCHoCH::Find(const ENUM_BAR_INFOR_TYPE type,const int index) const
  {
   if(type!=BAR_INFOR_TYPE_CHOCH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return this.FindCHoCH(index);
  }
 //+------------------------------------------------------------------+
 //| CHoCH: the broken swing goes against the trend (LH up, HL down)   |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarCHoCH::FindCHoCH(const int index) const
  {
   if(this.m_swing_high==NULL || this.m_swing_low==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   bool higher=false,lower=false;
   if(this.m_swing_high.FindBrokenHigh(index,higher) && !higher)
      return SIGNAL_DIRECTION_BUY;
   if(this.m_swing_low.FindBrokenLow(index,lower) && !lower)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
#endif // CBARCHOCH_MQH_IMPLEMENTATION
#endif // __BARCHOCH_MQH__
