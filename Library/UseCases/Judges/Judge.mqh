//+------------------------------------------------------------------+
//|                                                        Judge.mqh |
//| Use Cases (Clean Architecture): the business rules that judge the |
//| bars. The entity CBar only keeps what was found on it             |
//+------------------------------------------------------------------+
//--- Change from V4 Entities\Bar\Bar.mqh: Find, Shift, Event, Calculate moved out of CBar into CJudge
#ifndef __JUDGE_MQH__
#define __JUDGE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Bar\Bar.mqh"
 #include "..\..\Entities\Defines\BarDefines.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
#ifndef CJUDGE_MQH_DECLARATION
#define CJUDGE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The judge of the bars: CBarPattern, CBarSwing, CBarBOS, CBarCHoCH |
 //+------------------------------------------------------------------+
 class CJudge : public CBaseObj
  {
   public:
   //--- What a judge finds: CBarPattern, CBarSwing, CBarBOS, CBarCHoCH override them (a CJudge finds nothing: a type only Python finds).
   //--- (1) the side found on the bar at an index of the list of the judge, (2) how many bars before that bar its row is, (3) the event that tells a new row.
   //--- Change in V5: Shift(type,index) (was Shift()): one judge finds types whose row is on a different bar (CBarPattern: a candle on itself, a pivot pattern on its last pivot)
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const { return SIGNAL_DIRECTION_NO_PATTERN; }
    virtual int       Shift(const ENUM_BAR_INFOR_TYPE type,const int index) const { return 0;           }
    virtual ushort    Event(void)                  const { return (ushort)SERIES_EVENTS_PATTERN;        }
   //--- The bars of the list after `since` and before the forming one are judged for a type by Find, from the newest one back: the rows (bar time, side)
    int               Calculate(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since,long &times[],ENUM_SIGNAL_DIRECTION &sides[]) const;
  };
#endif // CJUDGE_MQH_DECLARATION
#ifndef CJUDGE_MQH_IMPLEMENTATION
#define CJUDGE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The bars after `since` judged by Find, from the newest closed one |
 //| back. The row of a swing is on its pivot bar, Shift() bars before |
 //| the bar that confirms it                                          |
 //+------------------------------------------------------------------+
 int CJudge::Calculate(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since,long &times[],ENUM_SIGNAL_DIRECTION &sides[]) const
  {
   ::ArrayFree(times);
   ::ArrayFree(sides);
   if(list==NULL || list.Total()==0)
      return 0;
   CBar *newest=list.At(list.Total()-1);
   datetime forming=0;
   if(newest==NULL || !::SeriesInfoInteger(newest.Symbol(),newest.Timeframe(),SERIES_LASTBAR_DATE,forming))
      return 0;
   for(int i=list.Total()-1;i>=0;i--)
     {
      CBar *bar=list.At(i);
      if(bar==NULL || bar.Time()>=forming)
         continue;   // the forming bar is not judged
      if(bar.Time()<=since)
         break;
      ENUM_SIGNAL_DIRECTION side=this.Find(type,i);
      if(side==SIGNAL_DIRECTION_NO_PATTERN)
         continue;
      CBar *row_bar=list.At(i-this.Shift(type,i));
      if(row_bar==NULL)
         continue;
      int total=::ArraySize(times);
      ::ArrayResize(times,total+1);
      ::ArrayResize(sides,total+1);
      times[total]=(long)row_bar.Time();
      sides[total]=side;
     }
   return ::ArraySize(times);
  }
#endif // CJUDGE_MQH_IMPLEMENTATION
#endif // __JUDGE_MQH__
