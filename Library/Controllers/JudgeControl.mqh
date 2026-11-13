//+------------------------------------------------------------------+
//|                                                 JudgeControl.mqh |
//| Controllers (Clean Architecture): a new closed bar is judged from |
//| the progress of a key, what is found is set on its entity and     |
//| told (Event Rule: the class that changes the data tells it, the   |
//| Automation Trading listens)                                       |
//+------------------------------------------------------------------+
//--- V5: the library judges the new bars on RAM only (fastest); Python saves to the database, its rows of the same bars are refused (AddRow / NewRow)
//--- New in V5: the steps that were written twice (V4 CBarControl::Calculate, CSignalSeriesDE::Calculate) are here once.
//--- CBarControl (bits on CBar) and CSignalsCollection (rows of CSignal) give what differs: the judge, what it needs, where a row goes
#ifndef __JUDGECONTROL_MQH__
#define __JUDGECONTROL_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Entities\Bar\Bar.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "..\UseCases\Judges\Judge.mqh"
 #include "..\Collections\Settings\SyncManager.mqh"
 #define JUDGE_NO_PROGRESS     (-2)   // JudgeNewBars: the key has no row of progress (Python has not made its first chunk)
 #define JUDGE_NOT_JUDGED      (-1)   // JudgeNewBars: not judged to the newest closed bar (the series, the source or Python is not ready: the next call tries again)
#ifndef CJUDGECONTROL_MQH_DECLARATION
#define CJUDGECONTROL_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The judging of the new bars of a key                              |
 //+------------------------------------------------------------------+
 class CJudgeControl : public CBaseObjExt
  {
   protected:
   //--- What a controller gives, by its target (the type for the bars, the index of the signal for the signals): (1) the judge, (2) what the judge
   //--- needs before it judges the bars after `since` (false: not ready), (3) a row found goes to its entity (false: it is there already, no event)
    virtual CJudge   *JudgeOf(const int target)                                              { return NULL;  }
    virtual bool      Prepare(const int target,CArrayObj *list,const datetime since)         { return true;  }
    virtual bool      StoreRow(const int target,const datetime time,const ENUM_SIGNAL_DIRECTION side) { return false; }
   //--- The bars of the list after the progress of the key (Setting_Sync in RAM) and before the forming one are judged; each new row goes to its entity and is told
   //--- by event_id: lparam = EventPack(bar time, key, side, judged at one new bar), dparam = the timeframe, sparam = text. The progress moves in RAM only (Python saves).
   //--- Returns the rows found, JUDGE_NO_PROGRESS, JUDGE_NOT_JUDGED; judged_to: the newest closed bar judged to
    int               JudgeNewBars(const int target,CSyncManager *sync,const long sync_object,const ENUM_BAR_INFOR_TYPE type,const long key,const string params,
                                   const string symbol,const ENUM_TIMEFRAMES timeframe,CArrayObj *list,const ushort event_id,const string text,datetime &judged_to);
  };
#endif // CJUDGECONTROL_MQH_DECLARATION
#ifndef CJUDGECONTROL_MQH_IMPLEMENTATION
#define CJUDGECONTROL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The new bars of a key are judged, set on the entity and told      |
 //+------------------------------------------------------------------+
 int CJudgeControl::JudgeNewBars(const int target,CSyncManager *sync,const long sync_object,const ENUM_BAR_INFOR_TYPE type,const long key,const string params,
                                 const string symbol,const ENUM_TIMEFRAMES timeframe,CArrayObj *list,const ushort event_id,const string text,datetime &judged_to)
  {
   CJudge *judge=this.JudgeOf(target);
   if(judge==NULL || sync==NULL || list==NULL || list.Total()==0)
      return JUDGE_NOT_JUDGED;
   if(!sync.IsPythonDone())
      return JUDGE_NOT_JUDGED;   // Python Current writes the pairs of Setting_SymbolTF now: one writer for a pair at a time
   const datetime last_closed=::iTime(symbol,timeframe,1);
   const datetime previous_closed=::iTime(symbol,timeframe,2);   // judged at one new bar: its rows are new (the Automation Trading acts on them)
   bool has_newest=false;
   for(int i=list.Total()-1;i>=0 && i>=list.Total()-2 && !has_newest;i--)
     {
      CBar *bar=list.At(i);
      has_newest=(bar!=NULL && bar.Time()==last_closed);
     }
   if(last_closed==0 || !has_newest)
      return JUDGE_NOT_JUDGED;   // the series has not the newest closed bar yet (CBarTimeSeriesCollection refreshes it first)
   if(judged_to==last_closed)
      return 0;
   datetime since=0;
   if(!sync.Read_RAM(sync_object,key,params,symbol,timeframe,since))
      return JUDGE_NO_PROGRESS;   // the history of the start is Python's
   if(since>=last_closed)
     {
      judged_to=last_closed;
      return 0;
     }
   CBar *oldest=list.At(0);
   if(oldest==NULL || oldest.Time()>since)
      return JUDGE_NOT_JUDGED;   // what is missing is more than the series holds: Python fills it
   if(!this.Prepare(target,list,since))
      return JUDGE_NOT_JUDGED;   // the judge has not what it needs yet (the values of the indicator in RAM)
   long times[];
   ENUM_SIGNAL_DIRECTION sides[];
   judge.Calculate(type,list,since,times,sides);
   long told[];
   for(int i=0;i<::ArraySize(times);i++)
      if(this.StoreRow(target,(datetime)times[i],sides[i]))   // RAM only: Python saves it
        {
         const int n=::ArraySize(told);
         ::ArrayResize(told,n+1);
         told[n]=this.EventPack((datetime)times[i],key,sides[i],since==previous_closed);
        }
   sync.Update_Sync_Setting(sync_object,key,symbol,timeframe,last_closed,sync_object,true,params);   // the mark stays in RAM
   judged_to=last_closed;
   //--- RAM changed: each new row told (Event Rule), with all the Automation Trading needs (no asking back)
   for(int k=0;k<::ArraySize(told);k++)
      this.EventSend(event_id,told[k],(double)timeframe,text);
   return ::ArraySize(told);
  }
#endif // CJUDGECONTROL_MQH_IMPLEMENTATION
#endif // __JUDGECONTROL_MQH__
