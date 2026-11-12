//+------------------------------------------------------------------+
//|                                                       BarBOS.mqh |
//+------------------------------------------------------------------+
//--- Break of Structure: the bar whose close breaks a Swing High above the one before (HH, Buy) or a Swing Low below the one before (LL, Sell).
//--- Change from V2 MarketStructureSeries.mqh (CMarketStructureSeries : CBaseObj, one class for BOS and CHoCH, with the time and the price of the broken swing):
//--- a CBar now, the break bar is itself; the broken swing is a CBarSwing, found again by CBarSwing::FindBrokenHigh / FindBrokenLow (Python structure.py)
//--- Change from V4 Entities\Bar\BarBOS.mqh: moved to UseCases\Judges, CBarBOS : CBar -> CBarBOS : CJudge (no row, no copy of the bar)
#ifndef __BARBOS_MQH__
#define __BARBOS_MQH__
 #include "Judge.mqh"
 #include "BarSwing.mqh"
#ifndef CBARBOS_MQH_DECLARATION
#define CBARBOS_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| A Break of Structure found on a bar                               |
 //+------------------------------------------------------------------+
 class CBarBOS : public CJudge
  {
   private:
    CBarSwing        *m_swing_high;          // The judge only: CBarControl holds it, set with the parameters of Swing High
    CBarSwing        *m_swing_low;           // The judge only: CBarControl holds it, set with the parameters of Swing Low
   public:
   //--- Does this class find the type
    static bool       IsFound(const ENUM_BAR_INFOR_TYPE type) { return (type==BAR_INFOR_TYPE_BOS); }
   //--- The judge: the judges of the swings (their bars and parameters are set by CBarControl)
    void              SetJudge(CBarSwing *swing_high,CBarSwing *swing_low);
   //--- The method of the type judges the bar at the index of the list of the judges (CJudge::Calculate calls it)
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const;
   //--- The event of a new BOS
    virtual ushort    Event(void) const { return (ushort)SERIES_EVENTS_BOS; }
   //--- Buy when the close breaks a HH, Sell when it breaks a LL (Buy first when it breaks both), SIGNAL_DIRECTION_NO_PATTERN when it does not
    ENUM_SIGNAL_DIRECTION FindBOS(const int index) const;
   //--- The judge
                      CBarBOS(void) : m_swing_high(NULL),m_swing_low(NULL) { this.m_object_type=OBJECT_DE_TYPE_SERIES_BOS; }
  };
#endif // CBARBOS_MQH_DECLARATION
#ifndef CBARBOS_MQH_IMPLEMENTATION
#define CBARBOS_MQH_IMPLEMENTATION
 void CBarBOS::SetJudge(CBarSwing *swing_high,CBarSwing *swing_low)
  {
   this.m_swing_high=swing_high;
   this.m_swing_low=swing_low;
  }
 ENUM_SIGNAL_DIRECTION CBarBOS::Find(const ENUM_BAR_INFOR_TYPE type,const int index) const
  {
   if(type!=BAR_INFOR_TYPE_BOS)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return this.FindBOS(index);
  }
 //+------------------------------------------------------------------+
 //| BOS: the broken swing goes with the trend (HH up, LL down)        |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarBOS::FindBOS(const int index) const
  {
   if(this.m_swing_high==NULL || this.m_swing_low==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   bool higher=false,lower=false;
   if(this.m_swing_high.FindBrokenHigh(index,higher) && higher)
      return SIGNAL_DIRECTION_BUY;
   if(this.m_swing_low.FindBrokenLow(index,lower) && lower)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
#endif // CBARBOS_MQH_IMPLEMENTATION
#endif // __BARBOS_MQH__
