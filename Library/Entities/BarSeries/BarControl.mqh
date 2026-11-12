//+------------------------------------------------------------------+
//|                                                   BarControl.mqh |
//| Change from V2 BarPatternsControl.mqh                            |
//+------------------------------------------------------------------+
#ifndef __BARCONTROL_MQH__
#define __BARCONTROL_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Bar\Bar.mqh"
 #include "..\..\UseCases\Judges\BarPattern.mqh"
 #include "..\..\UseCases\Judges\BarSwing.mqh"
 #include "..\..\UseCases\Judges\BarBOS.mqh"
 #include "..\..\UseCases\Judges\BarCHoCH.mqh"
 #include "..\Bases\BaseObjExt.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include "..\..\Services\DELib\CommonDELib.mqh"
 #include "..\..\Collections\Settings\SyncManager.mqh"
 #include "..\Defines\BarDefines.mqh"
 #include "..\..\Collections\Settings\BarInformationManager.mqh"
 #include "..\..\Controllers\JudgeControl.mqh"   // V5: the judging of the new bars, once for the bars and the signals
#ifndef CBARCONTROL_MQH_DECLARATION
#define CBARCONTROL_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Finds the information of the bars of a series                    |
 //+------------------------------------------------------------------+
 //class CBarControl : public CBaseObjExt
 class CBarControl : public CJudgeControl
  {
   private:
    CBarInformationManager *m_BarInformationManager;   // The EA holds it: the parameters of a type are read from it
    CBarPattern       m_pattern_instance;              // The judge of the candle patterns and the Momentum Candle (V2: CBarPatternControl::m_pattern_instance)
    CBarSwing         m_swing_instance;                // The judge of the swings (of the Swing High for BOS / CHoCH)
    CBarSwing         m_swing_low_instance;            // The judge of the Swing Low for BOS / CHoCH
    CBarBOS           m_bos_instance;                  // The judge of BOS
    CBarCHoCH         m_choch_instance;                // The judge of CHoCH
    //long              m_row_time[];                    // What was found by the last scan: the open time of the bar and its side
    //ENUM_SIGNAL_DIRECTION m_row_side[];
    CArrayObj        *m_list_series;                   // Not owned: the bars of the series, the oldest first (CBarSeriesDE::GetList(), V2: m_list_series)
    string            m_symbol;                        // The symbol and the timeframe of the series
    ENUM_TIMEFRAMES   m_timeframe;
    CBar              m_bar_tmp;                       // Bar object for search
    //--- V5: the rows of the table are bits on the bars (CBar::AddPatternType): the bars of the series keep theirs, the bars before the series read for a view are here (one CBar each)
    CArrayObj         m_list_Table_BarTimeSeriesCollection;
    datetime          m_judged_to;                     // RAM only: the newest closed bar every type of the pair is judged to (0: not judged yet)
    CSyncManager     *m_SyncManager;                   // The EA holds it: the progress of each type (Setting_Sync)
    long              m_sync_object;                   // The collection the rows are of (its m_type): sync_object of Setting_Sync
   //--- The bar of the series by its time
    CBar             *GetBar(const datetime time);
   //--- The judge of the type: the member of the class that finds it (NULL: a type only Python finds)
    CJudge           *Judge(const ENUM_BAR_INFOR_TYPE type);
   //--- V5: a row is the type and its side set on the bar. True when the bar did not have it
    bool              NewRow(CBar *bar,const long type,const long direction);
   protected:
   //--- V5 CJudgeControl, the target is the type: (1) its judge, (2) its parameters set on the judge (from Find), (3) a row set on the bar of the series
    virtual CJudge   *JudgeOf(const int target)                                              { return this.Judge((ENUM_BAR_INFOR_TYPE)target); }
    virtual bool      Prepare(const int target,CArrayObj *list,const datetime since);
    virtual bool      StoreRow(const int target,const datetime time,const ENUM_SIGNAL_DIRECTION side) { return this.NewRow(this.GetBar(time),target,side); }
   public:
   //--- What the control needs to judge and to read (CBarSeriesDE gives them): the bars of the series, the pair, the collection the rows are of, the managers
    void              SetListSeries(CArrayObj *list)                                 { this.m_list_series=list;                 }
    void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe) { this.m_symbol=symbol; this.m_timeframe=timeframe; }
    void              SetSyncObject(const long sync_object)                          { this.m_sync_object=sync_object;          }
    void              SetSyncManager(CSyncManager *manager)                          { this.m_SyncManager=manager;              }
    void              SetBarInformationManager(CBarInformationManager *manager)      { this.m_BarInformationManager=manager;    }
   //--- V5: the bars before the series read for a view, sorted by the time (the bars of the series: CBarSeriesDE::GetList); the views read their bits (CBarMarkerCollection)
    CArrayObj        *GetList(void)                                      { return &this.m_list_Table_BarTimeSeriesCollection; }
    datetime          JudgedTo(void)                               const { return this.m_judged_to;   }
    void              SetJudgedTo(const datetime time)                   { this.m_judged_to=time;   }
   //--- The rows of the table of the bars the series holds go to RAM (once at the creation of the series, then when Python
   //--- tells it wrote more: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE). No event: the views draw at PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE, after it
    bool              ReadDataFromDB(void);
   //--- The rows of the table from_time to to_time go to RAM next to what is there (a row there already is not read twice). The bar of a row the series
   //--- does not hold comes from the chart (CBarMarkerCollection asks it: the chart shows older bars). Returns the rows added, WRONG_VALUE when the table is not read
    int               ReadDataFromDB(const datetime from_time,const datetime to_time);
   //--- The new bars are judged for every type from its progress (Setting_Sync): only the bars after it. The rows go to RAM only (V5: Python saves them).
   //--- CBarSeriesDE::RefreshSeries calls it (V2: Refresh called UpdateAll of m_patterns_control). Event: the event of the type (EventOf) for each bar with a new row. True when RAM changed
    bool              Calculate(void);
   //--- The rows of a type (its parameter changed: the views hear BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED)
    void              DeleteRows(const long type);
   //--- The bars before the time read for a view (the chart showed older bars) go. Returns how many went
    int               DeleteRows(const datetime before);
   //--- The event that tells a new row of the type: the one of the class that finds it (CJudge::Event), SERIES_EVENTS_PATTERN for a type only Python finds
    ushort            EventOf(const ENUM_BAR_INFOR_TYPE type);
   //--- Does this class find the type (CBarPattern, CBarSwing, CBarBOS or CBarCHoCH does; the others are found by Python only, or not yet)
    bool              IsFound(const ENUM_BAR_INFOR_TYPE type) { return (this.Judge(type)!=NULL); }
   //--- The types this class finds, in the order of the enum: returns how many
    int               Types(ENUM_BAR_INFOR_TYPE &types[]);
   //--- The bars of the list after `since` (the open time of the newest bar already judged) and before the forming one are judged for a type, from the newest
   //--- one back. The rows found are asked with Rows(), RowTime() and RowSide(). Returns the number of rows
    //int               Find(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since);
    //int               Rows(void) const                 { return ::ArraySize(this.m_row_time);   }
    //datetime          RowTime(const int row) const      { return (datetime)this.m_row_time[row]; }
    //ENUM_SIGNAL_DIRECTION RowSide(const int row) const      { return this.m_row_side[row];           }
   //--- The rows as the two arrays the table is written from (the open time of the bar, its side)
    //int               RowsTo(long &times[],long &sides[]) const;
                      CBarControl(void);
  };
#endif // CBARCONTROL_MQH_DECLARATION
#ifndef CBARCONTROL_MQH_IMPLEMENTATION
#define CBARCONTROL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CBarControl::CBarControl(void) : m_BarInformationManager(NULL),m_list_series(NULL),m_symbol(NULL),m_timeframe(PERIOD_CURRENT),m_judged_to(0),
                                 m_SyncManager(NULL),m_sync_object(0)
  {
   this.m_object_type=OBJECT_DE_TYPE_SERIES_BAR_CONTROL;
  }
 //+------------------------------------------------------------------+
 //| The bar of the series by its time                                |
 //+------------------------------------------------------------------+
 CBar *CBarControl::GetBar(const datetime time)
  {
   if(this.m_list_series==NULL)
      return NULL;
   this.m_bar_tmp.SetSymbolPeriod(this.m_symbol,this.m_timeframe,time);
   this.m_list_series.Sort(SORT_BY_BAR_TIME);
   return this.m_list_series.At(this.m_list_series.Search(&this.m_bar_tmp));
  }
 //+------------------------------------------------------------------+
 //| The judge of the type: the class that finds it                    |
 //+------------------------------------------------------------------+
 CJudge *CBarControl::Judge(const ENUM_BAR_INFOR_TYPE type)
  {
   if(CBarSwing::IsFound(type))
      return &this.m_swing_instance;
   if(CBarBOS::IsFound(type))
      return &this.m_bos_instance;
   if(CBarCHoCH::IsFound(type))
      return &this.m_choch_instance;
   if(CBarPattern::IsFound(type))
      return &this.m_pattern_instance;
   return NULL;
  }
 //+------------------------------------------------------------------+
 //| V5: a row is the type and its side set on the bar                 |
 //+------------------------------------------------------------------+
 bool CBarControl::NewRow(CBar *bar,const long type,const long direction)
  {
   if(bar==NULL)
      return false;
   if(bar.InformationSide((ENUM_BAR_INFOR_TYPE)type)==(ENUM_SIGNAL_DIRECTION)direction)
      return false;   // the bar has it already
   bar.AddPatternType((ENUM_BAR_INFOR_TYPE)type,(ENUM_SIGNAL_DIRECTION)direction);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Every type this class finds                                      |
 //+------------------------------------------------------------------+
 int CBarControl::Types(ENUM_BAR_INFOR_TYPE &types[])
  {
   ::ArrayResize(types,0);
   for(int type=BAR_INFOR_TYPE_HAMMER;type<=BAR_INFOR_TYPE_CHOCH;type++)
      if(this.IsFound((ENUM_BAR_INFOR_TYPE)type))
        {
         int total=::ArraySize(types);
         ::ArrayResize(types,total+1);
         types[total]=(ENUM_BAR_INFOR_TYPE)type;
        }
   return ::ArraySize(types);
  }
 //+------------------------------------------------------------------+
 //| The rows of the last scan as the arrays the table is written from|
 //+------------------------------------------------------------------+
// int CBarControl::RowsTo(long &times[],long &sides[]) const
//  {
//   int total=this.Rows();
//   ::ArrayResize(times,total);
//   ::ArrayResize(sides,total);
//   for(int row=0;row<total;row++)
//     {
//      times[row]=(long)this.RowTime(row);
//      sides[row]=(long)this.RowSide(row);
//     }
//   return total;
//  }
 //+------------------------------------------------------------------+
 //| Judge the bars after `since` for a type: CBarControl gives the    |
 //| judge what it needs, the judge calculates (CJudge::Calculate)     |
 //+------------------------------------------------------------------+
// int CBarControl::Find(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since)
//  {
//   ::ArrayFree(this.m_row_time);
//   ::ArrayFree(this.m_row_side);
//   CJudge *judge=this.Judge(type);
//   if(list==NULL || list.Total()==0 || this.m_BarInformationManager==NULL || judge==NULL)
//      return 0;
//   CBar *newest=list.At(list.Total()-1);
//   if(newest==NULL)
//      return 0;
 //--- V5 (from Find): the judge of the type gets what it needs; CJudgeControl::JudgeNewBars calculates
 bool CBarControl::Prepare(const int target,CArrayObj *list,const datetime since)
  {
   const ENUM_BAR_INFOR_TYPE type=(ENUM_BAR_INFOR_TYPE)target;
   if(list==NULL || list.Total()==0 || this.m_BarInformationManager==NULL || this.Judge(type)==NULL)
      return false;
   CBar *newest=list.At(list.Total()-1);
   if(newest==NULL)
      return false;
   string names[],displays[];
   double values[];
   if(CBarBOS::IsFound(type) || CBarCHoCH::IsFound(type))
     {
      //--- BOS / CHoCH have no parameters: the swings they break are the ones of Swing High and Swing Low (their parameters)
      string low_names[];
      double low_values[];
      this.m_BarInformationManager.Read_RAM(BAR_INFOR_TYPE_SWING_HIGH,names,displays,values);
      this.m_BarInformationManager.Read_RAM(BAR_INFOR_TYPE_SWING_LOW,low_names,displays,low_values);
      this.m_swing_instance.SetJudge(list,names,values);
      this.m_swing_low_instance.SetJudge(list,low_names,low_values);
      this.m_bos_instance.SetJudge(&this.m_swing_instance,&this.m_swing_low_instance);
      this.m_choch_instance.SetJudge(&this.m_swing_instance,&this.m_swing_low_instance);
     }
   else
     {
      this.m_BarInformationManager.Read_RAM(type,names,displays,values);
      if(CBarSwing::IsFound(type))
         this.m_swing_instance.SetJudge(list,names,values);
      else
         this.m_pattern_instance.SetJudge(list,::SymbolInfoDouble(newest.Symbol(),SYMBOL_POINT),names,values);
     }
   //return judge.Calculate(type,list,since,this.m_row_time,this.m_row_side);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows of the bars the series holds go to RAM                   |
 //+------------------------------------------------------------------+
 bool CBarControl::ReadDataFromDB(void)
  {
   if(this.m_BarInformationManager==NULL || this.m_list_series==NULL || this.m_list_series.Total()==0)
      return false;
   if(this.m_SyncManager==NULL || !this.m_SyncManager.IsPythonDone())
      return false;   // Python has not done its part of the pairs yet: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE reads it
   CBar *oldest=this.m_list_series.At(0);
   CBar *newest=this.m_list_series.At(this.m_list_series.Total()-1);
   if(oldest==NULL || newest==NULL)
      return false;
   //--- V5: the bits of every bar are read again
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CBar *bar=this.m_list_series.At(i);
      if(bar==NULL)
         continue;
      bar.SetProperty(BAR_PROP_INFORMATION_CANDLE,0);
      bar.SetProperty(BAR_PROP_INFORMATION_SMART_MONEY,0);
     }
   this.m_list_Table_BarTimeSeriesCollection.Clear();
   int loaded=this.ReadDataFromDB(oldest.Time(),newest.Time());
   if(loaded==WRONG_VALUE)
      return false;
   //--- What was loaded, said so that it is not read as a number of bars: a bar can have several rows (several types), or none
   int bars_with_rows=0;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CBar *bar=this.m_list_series.At(i);
      if(bar!=NULL && (bar.GetProperty(BAR_PROP_INFORMATION_CANDLE)!=0 || bar.GetProperty(BAR_PROP_INFORMATION_SMART_MONEY)!=0))
         bars_with_rows++;
     }
   ::Print("Complete ",__FUNCTION__," > ",this.m_symbol," ",::EnumToString(this.m_timeframe),": ",loaded," rows of BarTimeSeriesCollection read on ",bars_with_rows," of the ",
           this.m_list_series.Total()," bars of the series (",::TimeToString(oldest.Time())," .. ",::TimeToString(newest.Time()),")");
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows of the table from_time to to_time go to RAM              |
 //+------------------------------------------------------------------+
 int CBarControl::ReadDataFromDB(const datetime from_time,const datetime to_time)
  {
   if(this.m_BarInformationManager==NULL || this.m_SyncManager==NULL || !this.m_SyncManager.IsPythonDone())
      return 0;
   long read_types[],read_times[],read_sides[];
   int read_total=this.m_BarInformationManager.ReadDataFromDB(this.m_symbol,this.m_timeframe,from_time,to_time,read_types,read_times,read_sides);
   if(read_total==WRONG_VALUE)
      return WRONG_VALUE;
   const int digits=(int)::SymbolInfoInteger(this.m_symbol,SYMBOL_DIGITS);
   //--- V5: each row is set on its bar: the bar of the series, else the bar before the series read already, else a new one from the chart
   this.m_list_Table_BarTimeSeriesCollection.Sort(SORT_BY_BAR_TIME);
   int loaded=0;
   for(int r=0;r<read_total;r++)
     {
      const long type=read_types[r],time=read_times[r],direction=read_sides[r];
      CBar *bar=this.GetBar((datetime)time);
      if(bar==NULL)
        {
         this.m_bar_tmp.SetSymbolPeriod(this.m_symbol,this.m_timeframe,(datetime)time);
         bar=this.m_list_Table_BarTimeSeriesCollection.At(this.m_list_Table_BarTimeSeriesCollection.Search(&this.m_bar_tmp));
        }
      if(bar==NULL)
        {
         MqlRates rates[1];   // a bar the series does not hold: the chart has it
         if(::CopyRates(this.m_symbol,this.m_timeframe,(datetime)time,1,rates)==1 && (long)rates[0].time==time)
           {
            bar=new CBar(this.m_symbol,this.m_timeframe,rates[0],digits);
            if(bar!=NULL && !this.m_list_Table_BarTimeSeriesCollection.InsertSort(bar))
              {
               delete bar;
               bar=NULL;
              }
           }
        }
      if(this.NewRow(bar,type,direction))
         loaded++;
     }
   return loaded;
  }
 //+------------------------------------------------------------------+
 //| The new bars of the series are judged for every type              |
 //+------------------------------------------------------------------+
 bool CBarControl::Calculate(void)
  {
   if(this.m_BarInformationManager==NULL || this.m_SyncManager==NULL)
      return false;
   if(!this.m_SyncManager.IsPythonDone())
      return false;   // Python Current writes the pairs of Setting_SymbolTF now: one writer for a pair at a time
   datetime last_closed=::iTime(this.m_symbol,this.m_timeframe,1);
   //const datetime previous_closed=::iTime(this.m_symbol,this.m_timeframe,2);   // a type marked here judges one new bar: its rows are new
   CBar *newest=(last_closed!=0 ? this.GetBar(last_closed) : NULL);
   if(newest==NULL || newest.Time()!=last_closed)
      return false;   // the series has not the newest closed bar yet (RefreshSeries adds it)
//   long types[],last_bars[];
//   this.m_SyncManager.Read_RAM(this.m_sync_object,this.m_symbol,this.m_timeframe,types,last_bars);
//   ENUM_BAR_INFOR_TYPE found_types[];
//   int found_total=this.Types(found_types);
//   bool finished=true;        // every type of the pair is judged to the newest closed bar
//   bool any_progress=false;   // a type of the pair has the row of progress of Python: the first chunk is there
//   bool changed=false;        // a row or a mark is new in RAM
//   long told_params[];        // each row added and the event that tells it
//   ushort told_events[];
//   for(int t=0;t<found_total;t++)
//     {
//      datetime since=0;
//      bool has_progress=false;
//      for(int k=0;k<::ArraySize(types);k++)
//         if(types[k]==(long)found_types[t])
//           {
//            since=(datetime)last_bars[k];
//            has_progress=true;
//           }
//      any_progress=any_progress || has_progress;
//      if(!has_progress || since>=last_closed)
//         continue;   // no row of progress: the history of the start is Python's
//      CBar *oldest=this.m_list_series.At(0);
//      if(oldest==NULL || oldest.Time()>since)
//        {
//         finished=false;   // what is missing is more than the series holds: Python fills it
//         continue;
//        }
//      this.Find(found_types[t],this.m_list_series,since);
//      long row_times[],row_sides[];
//      this.RowsTo(row_times,row_sides);
//      const ushort event_id=this.EventOf(found_types[t]);
//      for(int i=0;i<::ArraySize(row_times);i++)
//        {
//         //--- V5: the row is set on the bar of the series (RAM only: Python saves it)
//         if(!this.NewRow(this.GetBar((datetime)row_times[i]),(long)found_types[t],row_sides[i]))
//            continue;
//         int told=::ArraySize(told_events);
//         ::ArrayResize(told_events,told+1);
//         ::ArrayResize(told_params,told+1);
//         told_events[told]=event_id;
//         told_params[told]=this.EventPack((datetime)row_times[i],(long)found_types[t],(ENUM_SIGNAL_DIRECTION)row_sides[i],since==previous_closed);
//        }
//      this.m_SyncManager.Update_Sync_Setting(this.m_sync_object,(long)found_types[t],this.m_symbol,this.m_timeframe,last_closed,this.m_sync_object,true);
//      changed=true;
//     }
//   if(found_total>0 && !any_progress)
//      finished=false;   // Python has not made the first chunk of any type of the pair: the timer looks again
//   if(finished)
//      this.m_judged_to=last_closed;
//   //--- RAM changed: told (Event Rule), each kind by its own event (EventOf), each row with what it is
//   const ushort events[]={(ushort)SERIES_EVENTS_PATTERN,(ushort)SERIES_EVENTS_SWING,(ushort)SERIES_EVENTS_BOS,(ushort)SERIES_EVENTS_CHOCH};
//   for(int e=0;e<::ArraySize(events);e++)
//     {
//      int told_total=0;
//      for(int k=0;k<::ArraySize(told_events);k++)
//         if(told_events[k]==events[e])
//            told_total++;
//      for(int k=0;k<::ArraySize(told_events);k++)
//         if(told_events[k]==events[e])
//            this.EventSend(events[e],told_params[k],(double)this.m_timeframe,this.EventPackText(this.m_symbol));
//     }
//   return changed;
   //--- V5: each type is judged by CJudgeControl::JudgeNewBars (the steps shared with the signals): its rows set on the bars, each told by its event
   ENUM_BAR_INFOR_TYPE found_types[];
   int found_total=this.Types(found_types);
   bool finished=true;        // every type of the pair is judged to the newest closed bar
   bool any_progress=false;   // a type of the pair has the row of progress of Python: the first chunk is there
   bool changed=false;        // a row is new in RAM
   const string text=this.EventPackText(this.m_symbol);
   for(int t=0;t<found_total;t++)
     {
      datetime judged=0;   // the bars keep one mark for the pair (m_judged_to)
      const int rows=this.JudgeNewBars((int)found_types[t],this.m_SyncManager,this.m_sync_object,found_types[t],(long)found_types[t],"",
                                       this.m_symbol,this.m_timeframe,this.m_list_series,this.EventOf(found_types[t]),text,judged);
      if(rows==JUDGE_NO_PROGRESS)
         continue;   // no row of progress: the history of the start is Python's
      any_progress=true;
      if(rows==JUDGE_NOT_JUDGED)
         finished=false;   // what is missing is more than the series holds: Python fills it
      else if(rows>0)
         changed=true;
     }
   if(found_total>0 && !any_progress)
      finished=false;   // Python has not made the first chunk of any type of the pair: the timer looks again
   if(finished)
      this.m_judged_to=last_closed;
   return changed;
  }
 //+------------------------------------------------------------------+
 //| The event of a type                                               |
 //+------------------------------------------------------------------+
 ushort CBarControl::EventOf(const ENUM_BAR_INFOR_TYPE type)
  {
   CJudge *judge=this.Judge(type);
   return (judge!=NULL ? judge.Event() : (ushort)SERIES_EVENTS_PATTERN);   // a type only Python finds: the event of CJudge
  }
 //+------------------------------------------------------------------+
 //| The bars before a time read for a view go                         |
 //+------------------------------------------------------------------+
 int CBarControl::DeleteRows(const datetime before)
  {
   int deleted=0;
   for(int i=this.m_list_Table_BarTimeSeriesCollection.Total()-1;i>=0;i--)
     {
      CBar *bar=this.m_list_Table_BarTimeSeriesCollection.At(i);
      if(bar==NULL || bar.Time()>=before)
         continue;
      this.m_list_Table_BarTimeSeriesCollection.Delete(i);
      deleted++;
     }
   return deleted;
  }
 //+------------------------------------------------------------------+
 //| The rows of a type in RAM go                                      |
 //+------------------------------------------------------------------+
 void CBarControl::DeleteRows(const long type)
  {
   //--- V5: the type goes from every bar (of the series and before it)
   for(int i=0;this.m_list_series!=NULL && i<this.m_list_series.Total();i++)
      this.NewRow(this.m_list_series.At(i),type,SIGNAL_DIRECTION_NO_PATTERN);
   for(int i=0;i<this.m_list_Table_BarTimeSeriesCollection.Total();i++)
      this.NewRow(this.m_list_Table_BarTimeSeriesCollection.At(i),type,SIGNAL_DIRECTION_NO_PATTERN);
  }
#endif // CBARCONTROL_MQH_IMPLEMENTATION
#endif // __BARCONTROL_MQH__
