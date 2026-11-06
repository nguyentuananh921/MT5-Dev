//+------------------------------------------------------------------+
//|                                                   BarControl.mqh |
//| Change from V2 BarPatternsControl.mqh                            |
//+------------------------------------------------------------------+
#ifndef __BARCONTROL_MQH__
#define __BARCONTROL_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Bar\Bar.mqh"
 #include "..\Bar\BarPattern.mqh"
 #include "..\Bar\BarSwing.mqh"
 #include "..\Bar\BarBOS.mqh"
 #include "..\Bar\BarCHoCH.mqh"
 #include "..\Bases\BaseObjExt.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include "..\..\Services\DELib\CommonDELib.mqh"
 #include "..\..\Collections\Settings\SyncManager.mqh"
 #include "..\Defines\BarDefines.mqh"
 #include "..\..\Collections\Settings\BarInformationManager.mqh"
#ifndef CBARCONTROL_MQH_DECLARATION
#define CBARCONTROL_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Finds the information of the bars of a series                    |
 //+------------------------------------------------------------------+
 class CBarControl : public CBaseObjExt
  {
   private:
    CBarInformationManager *m_BarInformationManager;   // The EA holds it: the parameters of a type are read from it
    CBarPattern       m_pattern_instance;              // The judge of the candle patterns and the Momentum Candle (V2: CBarPatternControl::m_pattern_instance)
    CBarSwing         m_swing_instance;                // The judge of the swings (of the Swing High for BOS / CHoCH)
    CBarSwing         m_swing_low_instance;            // The judge of the Swing Low for BOS / CHoCH
    CBarBOS           m_bos_instance;                  // The judge of BOS
    CBarCHoCH         m_choch_instance;                // The judge of CHoCH
    long              m_row_time[];                    // What was found by the last scan: the open time of the bar and its side
    ENUM_SIGNAL_DIRECTION m_row_side[];
    CArrayObj        *m_list_series;                   // Not owned: the bars of the series, the oldest first (CBarSeriesDE::GetList(), V2: m_list_series)
    string            m_symbol;                        // The symbol and the timeframe of the series
    ENUM_TIMEFRAMES   m_timeframe;
    CBar              m_bar_tmp;                       // Bar object for search
    CArrayObj         m_list_Table_BarTimeSeriesCollection;   // The rows of the table BarTimeSeriesCollection of this pair (CBarPattern, CBarSwing; a CBar for a type only Python finds): only the bars the series holds
    CArrayObj         m_list_Pending_BarTimeSeriesCollection; // RAM only: the rows not in the table yet (FreeMode false: m_list_Table_BarTimeSeriesCollection owns them)
    datetime          m_judged_to;                     // RAM only: the newest closed bar every type of the pair is judged to (0: not judged yet)
    CSyncManager     *m_SyncManager;                   // The EA holds it: the progress of each type (Setting_Sync)
    long              m_sync_object;                   // The collection the rows are of (its m_type): sync_object of Setting_Sync
   //--- The bar of the series by its time
    CBar             *GetBar(const datetime time);
   //--- The judge of the type: the member of the class that finds it (NULL: a type only Python finds)
    CBar             *Judge(const ENUM_BAR_INFOR_TYPE type);
   //--- A row: the bar of the series with the type, its group (RAM only) and the side, made by the class of the type (NULL: the series has not the bar)
    CBar             *NewRow(CBar *bar,const long type,const long group,const long direction);
   public:
   //--- What the control needs to judge and to write: the bars of the series, the file of the account, the id of the symbol, the collection, the managers (CBarSeriesDE::SetDatabase)
    void              SetDatabase(CArrayObj *list_series,const string symbol,const ENUM_TIMEFRAMES timeframe,const long sync_object,
                                  CSyncManager *sync,CBarInformationManager *information);
    int               PendingTotal(void)                           const { return this.m_list_Pending_BarTimeSeriesCollection.Total(); }
    datetime          JudgedTo(void)                               const { return this.m_judged_to;   }
    void              SetJudgedTo(const datetime time)                   { this.m_judged_to=time;   }
   //--- The rows of the table of the bars the series holds go to RAM, the rows waiting to be written stay (once at the creation of the series, then when Python
   //--- tells it wrote more: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE). Event: SERIES_EVENTS_PATTERN_ALL
    bool              ReadDataFromDB(void);
   //--- The rows waiting go to the table, then their progress (rows first). True when nothing waits. No event: the view sees the same (the table UNION RAM)
    bool              UpdateDataToDB(void);
   //--- The new bars are judged for every type from its progress (Setting_Sync): only the bars after it. The rows go to RAM and wait to be written (UpdateDataToDB).
   //--- CBarSeriesDE::RefreshSeries calls it (V2: Refresh called UpdateAll of m_patterns_control). Event: the event of the type (EventOf) for each bar with a new row. True when RAM changed
    bool              Calculate(void);
   //--- The rows (1) older than the oldest bar of the series (a row waiting to be written stays), (2) of a type (its parameter changed: Event SERIES_EVENTS_PATTERN_ALL)
    void              DeleteRows(void);
    void              DeleteRows(const long type);
   //--- The rows found and not written yet, from_time to to_time (both in): the view reads the table UNION these. Returns how many
    int               PendingRows(const datetime from_time,const datetime to_time,long &types[],long &times[],long &sides[]) const;
   //--- What the markers of the pair show: the table UNION what waits in RAM, the types (type_infor, bar time, side) whose Buy / Sell ids are given, from_time to to_time
    int               ReadTypes(const datetime from_time,const datetime to_time,const long &buy_types[],const long &sell_types[],long &types[],long &times[],long &sides[]);
   //--- What was found on a bar: each type once, its sides (1 Buy, 2 Sell, as NewSidesOfBar), only the types told by the event. Returns how many types
    int               RowsOfBar(const datetime bar,const ushort event_id,long &types[],int &sides[]);
   //--- The event that tells a new row of the type: the one of the class that finds it (CBar::Event), SERIES_EVENTS_PATTERN for a type only Python finds
    ushort            EventOf(const ENUM_BAR_INFOR_TYPE type);
   //--- Does this class find the type (CBarPattern, CBarSwing, CBarBOS or CBarCHoCH does; the others are found by Python only, or not yet)
    bool              IsFound(const ENUM_BAR_INFOR_TYPE type) { return (this.Judge(type)!=NULL); }
   //--- The types this class finds, in the order of the enum: returns how many
    int               Types(ENUM_BAR_INFOR_TYPE &types[]);
   //--- The bars of the list after `since` (the open time of the newest bar already judged) and before the forming one are judged for a type, from the newest
   //--- one back. The rows found are asked with Rows(), RowTime() and RowSide(). Returns the number of rows
    int               Find(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since);
    int               Rows(void) const                 { return ::ArraySize(this.m_row_time);   }
    datetime          RowTime(const int row) const      { return (datetime)this.m_row_time[row]; }
    ENUM_SIGNAL_DIRECTION RowSide(const int row) const      { return this.m_row_side[row];           }
   //--- The rows as the two arrays the table is written from (the open time of the bar, its side)
    int               RowsTo(long &times[],long &sides[]) const;
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
   this.m_list_Pending_BarTimeSeriesCollection.FreeMode(false);
  }
 //+------------------------------------------------------------------+
 //| What the control needs to judge the bars and to write the rows    |
 //+------------------------------------------------------------------+
 void CBarControl::SetDatabase(CArrayObj *list_series,const string symbol,const ENUM_TIMEFRAMES timeframe,const long sync_object,
                              CSyncManager *sync,CBarInformationManager *information)
  {
   this.m_list_series=list_series;
   this.m_symbol=symbol;
   this.m_timeframe=timeframe;
   this.m_sync_object=sync_object;
   this.m_SyncManager=sync;
   this.m_BarInformationManager=information;
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
 CBar *CBarControl::Judge(const ENUM_BAR_INFOR_TYPE type)
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
 //| A row: what was found on the bar is of the class that finds it    |
 //| (a type only Python finds stays a CBar)                           |
 //+------------------------------------------------------------------+
 CBar *CBarControl::NewRow(CBar *bar,const long type,const long group,const long direction)
  {
   CBar *judge=this.Judge((ENUM_BAR_INFOR_TYPE)type);
   return (judge!=NULL ? judge.NewRow(bar,type,group,direction) : this.m_bar_tmp.NewRow(bar,type,group,direction));
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
 int CBarControl::RowsTo(long &times[],long &sides[]) const
  {
   int total=this.Rows();
   ::ArrayResize(times,total);
   ::ArrayResize(sides,total);
   for(int row=0;row<total;row++)
     {
      times[row]=(long)this.RowTime(row);
      sides[row]=(long)this.RowSide(row);
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| Judge the bars after `since` for a type: CBarControl gives the    |
 //| judge what it needs, the judge calculates (CBar::Calculate)       |
 //+------------------------------------------------------------------+
 int CBarControl::Find(const ENUM_BAR_INFOR_TYPE type,CArrayObj *list,const datetime since)
  {
   ::ArrayFree(this.m_row_time);
   ::ArrayFree(this.m_row_side);
   CBar *judge=this.Judge(type);
   if(list==NULL || list.Total()==0 || this.m_BarInformationManager==NULL || judge==NULL)
      return 0;
   CBar *newest=list.At(list.Total()-1);
   if(newest==NULL)
      return 0;
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
   return judge.Calculate(type,list,since,this.m_row_time,this.m_row_side);
  }
 //+------------------------------------------------------------------+
 //| The rows older than the oldest bar of the series go               |
 //+------------------------------------------------------------------+
 void CBarControl::DeleteRows(void)
  {
   CBar *oldest=this.m_list_series.At(0);
   if(oldest==NULL)
      return;
   const datetime first_time=oldest.Time();
   for(int i=this.m_list_Table_BarTimeSeriesCollection.Total()-1;i>=0;i--)
     {
      CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(i);
      if(row==NULL || row.Time()>=first_time)
         continue;
      bool pending=false;
      for(int k=0;k<this.m_list_Pending_BarTimeSeriesCollection.Total() && !pending;k++)
         pending=(this.m_list_Pending_BarTimeSeriesCollection.At(k)==row);
      if(!pending)
         this.m_list_Table_BarTimeSeriesCollection.Delete(i);
     }
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
   // New In V4 after implemenation CDatabaseService
   long read_types[],read_times[],read_sides[];
   int read_total=this.m_BarInformationManager.ReadDataFromDB(this.m_symbol,this.m_timeframe,oldest.Time(),newest.Time(),read_types,read_times,read_sides);
   if(read_total==WRONG_VALUE)
      return false;
   //--- The rows waiting to be written stay (they are not in the table yet), the others are read again
   for(int i=this.m_list_Table_BarTimeSeriesCollection.Total()-1;i>=0;i--)
     {
      CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(i);
      bool pending=false;
      for(int k=0;k<this.m_list_Pending_BarTimeSeriesCollection.Total() && !pending;k++)
         pending=(this.m_list_Pending_BarTimeSeriesCollection.At(k)==row);
      if(!pending)
         this.m_list_Table_BarTimeSeriesCollection.Delete(i);
     }
   int loaded=0;
   long asked_type=-1,asked_group=0;   // the group of the type asked last (the rows come in the order of type_infor)
   for(int r=0;r<read_total;r++)
     {
      long type=read_types[r],time=read_times[r],direction=read_sides[r];
      if(type!=asked_type)
        {
         asked_type=type;
         CBarInformationSetting *setting=(this.m_BarInformationManager!=NULL ? this.m_BarInformationManager.Read_RAM((ENUM_BAR_INFOR_TYPE)type) : NULL);
         asked_group=(setting!=NULL ? (long)setting.Group() : 0);
        }
      bool waiting=false;   // the same row waits to be written already (kept above)
      for(int k=0;k<this.m_list_Pending_BarTimeSeriesCollection.Total() && !waiting;k++)
        {
         CBar *row=this.m_list_Pending_BarTimeSeriesCollection.At(k);
         waiting=(row!=NULL && (long)row.Time()==time && row.GetProperty(BAR_PROP_INFOR_TYPE)==type && row.GetProperty(BAR_PROP_SIGNAL_DIRECTION)==direction);
        }
      if(waiting)
         continue;
      CBar *row=this.NewRow(this.GetBar((datetime)time),type,asked_group,direction);
      if(row==NULL)
         continue;
      if(!this.m_list_Table_BarTimeSeriesCollection.Add(row))
         delete row;
      else
         loaded++;
     }
   this.m_list_Table_BarTimeSeriesCollection.Sort(BAR_PROP_TIME);
   //--- What was loaded, said so that it is not read as a number of bars: a bar can have several rows (several types), or none
   int bars_with_rows=0;
   datetime previous=0;
   for(int i=0;i<this.m_list_Table_BarTimeSeriesCollection.Total();i++)
     {
      CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(i);
      if(row!=NULL && row.Time()!=previous)
        {
         bars_with_rows++;
         previous=row.Time();
        }
     }
   ::Print("Complete ",__FUNCTION__," > ",this.m_symbol," ",::EnumToString(this.m_timeframe),": ",loaded," rows of BarTimeSeriesCollection read on ",bars_with_rows," of the ",
           this.m_list_series.Total()," bars of the series (",::TimeToString(oldest.Time())," .. ",::TimeToString(newest.Time()),"), ",this.m_list_Pending_BarTimeSeriesCollection.Total()," rows waiting to be written kept");
   if(this.EventAdd((ushort)SERIES_EVENTS_PATTERN,SERIES_EVENTS_PATTERN_ALL,(double)this.m_timeframe,this.m_symbol))   // what the chart shows of the pair is made again
      this.SetEventFlag(true);
   return true;
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
   CBar *newest=(last_closed!=0 ? this.GetBar(last_closed) : NULL);
   if(newest==NULL || newest.Time()!=last_closed)
      return false;   // the series has not the newest closed bar yet (RefreshSeries adds it)
   long types[],last_bars[];
   this.m_SyncManager.Read_RAM(this.m_sync_object,this.m_symbol,this.m_timeframe,types,last_bars);
   ENUM_BAR_INFOR_TYPE found_types[];
   int found_total=this.Types(found_types);
   bool finished=true;        // every type of the pair is judged to the newest closed bar
   bool any_progress=false;   // a type of the pair has the row of progress of Python: the first chunk is there
   bool changed=false;        // a row or a mark is new in RAM
   long found_times[];        // the bars that got a new row and the event that tells each (EventOf): the view reads the table UNION RAM
   ushort found_events[];
   int debug_no_progress=0,debug_judged_before=0,debug_out_of_window=0,debug_judged=0,debug_rows=0;   // MY DEBUG
   for(int t=0;t<found_total;t++)
     {
      datetime since=0;
      bool has_progress=false;
      for(int k=0;k<::ArraySize(types);k++)
         if(types[k]==(long)found_types[t])
           {
            since=(datetime)last_bars[k];
            has_progress=true;
           }
      any_progress=any_progress || has_progress;
      if(!has_progress)
         debug_no_progress++;   // MY DEBUG
      else if(since>=last_closed)
         debug_judged_before++;   // MY DEBUG
      if(!has_progress || since>=last_closed)
         continue;   // no row of progress: the history of the start is Python's
      CBar *oldest=this.m_list_series.At(0);
      if(oldest==NULL || oldest.Time()>since)
        {
         debug_out_of_window++;   // MY DEBUG
         finished=false;   // what is missing is more than the series holds: Python fills it
         continue;
        }
      this.Find(found_types[t],this.m_list_series,since);
      long row_times[],row_sides[];
      this.RowsTo(row_times,row_sides);
      CBarInformationSetting *setting=(this.m_BarInformationManager!=NULL ? this.m_BarInformationManager.Read_RAM((ENUM_BAR_INFOR_TYPE)found_types[t]) : NULL);
      long group=(setting!=NULL ? (long)setting.Group() : 0);
      for(int i=0;i<::ArraySize(row_times);i++)
        {
         CBar *row=this.NewRow(this.GetBar((datetime)row_times[i]),(long)found_types[t],group,row_sides[i]);
         if(row==NULL)
            continue;
         if(!this.m_list_Table_BarTimeSeriesCollection.Add(row))
           {
            delete row;
            continue;
           }
         this.m_list_Pending_BarTimeSeriesCollection.Add(row);
         debug_rows++;   // MY DEBUG
        }
      this.m_SyncManager.Update_Sync_Setting(this.m_sync_object,(long)found_types[t],this.m_symbol,this.m_timeframe,last_closed,this.m_sync_object,true);
      const ushort event_id=this.EventOf(found_types[t]);
      for(int r=0;r<::ArraySize(row_times);r++)
        {
         bool there=false;
         for(int m=0;m<::ArraySize(found_times) && !there;m++)
            there=(found_times[m]==row_times[r] && found_events[m]==event_id);
         if(there)
            continue;
         int n=::ArraySize(found_times);
         ::ArrayResize(found_times,n+1);
         ::ArrayResize(found_events,n+1);
         found_times[n]=row_times[r];
         found_events[n]=event_id;
        }
      changed=true;
      debug_judged++;   // MY DEBUG
     }
   if(found_total>0 && !any_progress)
      finished=false;   // Python has not made the first chunk of any type of the pair: the timer looks again
   if(finished)
      this.m_judged_to=last_closed;
   //--- MY DEBUG once per pair, closed bar and outcome (the call repeats on each tick / beat while not finished)
   static string debug_keys[];
   string debug_pair=this.m_symbol+" "+::EnumToString(this.m_timeframe);
   string debug_key=debug_pair+" "+::TimeToString(last_closed)+" "+(finished ? "finished" : "not finished");
   int debug_index=-1;
   for(int k=0;k<::ArraySize(debug_keys);k++)
      if(::StringFind(debug_keys[k],debug_pair+" ")==0)
         debug_index=k;
   if(debug_index<0 || debug_keys[debug_index]!=debug_key)
     {
      if(debug_index<0)
        {
         debug_index=::ArraySize(debug_keys);
         ::ArrayResize(debug_keys,debug_index+1);
        }
      debug_keys[debug_index]=debug_key;
      string debug_text="MY DEBUG    CBarControl::Calculate: "+debug_pair+", closed bar "+::TimeToString(last_closed)+": "+
                        (string)debug_judged+" of the "+(string)found_total+" types judged now ("+(string)debug_rows+" rows on "+
                        (string)::ArraySize(found_times)+" bars), "+(string)debug_judged_before+" judged before, "+(string)debug_no_progress+
                        " without a progress row of Python, "+(string)debug_out_of_window+" missing more than the "+
                        (string)this.m_list_series.Total()+" bars of the series; "+(finished ? "finished" : "not finished: judged again next call");
      ::Print(debug_text);
     }
   //--- RAM changed: told (Event Rule), each kind by its own event (EventOf), the view reads the table UNION what waits in RAM
   const ushort events[]={(ushort)SERIES_EVENTS_PATTERN,(ushort)SERIES_EVENTS_SWING,(ushort)SERIES_EVENTS_BOS,(ushort)SERIES_EVENTS_CHOCH};
   for(int e=0;e<::ArraySize(events);e++)
     {
      long times[];
      for(int k=0;k<::ArraySize(found_times);k++)
         if(found_events[k]==events[e])
           {
            int n=::ArraySize(times);
            ::ArrayResize(times,n+1);
            times[n]=found_times[k];
           }
      if(::ArraySize(times)>SERIES_EVENTS_PATTERN_MAX)
        {
         ::ArrayResize(times,1);
         times[0]=SERIES_EVENTS_PATTERN_ALL;   // too many to tell one by one: the markers of the chart are made again
        }
      for(int k=0;k<::ArraySize(times);k++)
         if(this.EventAdd(events[e],times[k],(double)this.m_timeframe,this.m_symbol))
            this.SetEventFlag(true);
     }
   return changed;
  }
 //+------------------------------------------------------------------+
 //| The rows found and not written yet in a range of bars             |
 //+------------------------------------------------------------------+
 int CBarControl::PendingRows(const datetime from_time,const datetime to_time,long &types[],long &times[],long &sides[]) const
  {
   ::ArrayResize(types,0);
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   for(int i=0;i<this.m_list_Pending_BarTimeSeriesCollection.Total();i++)
     {
      CBar *row=this.m_list_Pending_BarTimeSeriesCollection.At(i);
      if(row==NULL || row.Time()<from_time || row.Time()>to_time)
         continue;
      int n=::ArraySize(types);
      ::ArrayResize(types,n+1);
      ::ArrayResize(times,n+1);
      ::ArrayResize(sides,n+1);
      types[n]=row.GetProperty(BAR_PROP_INFOR_TYPE);
      times[n]=(long)row.Time();
      sides[n]=row.GetProperty(BAR_PROP_SIGNAL_DIRECTION);
     }
   return ::ArraySize(types);
  }
 //+------------------------------------------------------------------+
 //| What the markers of the pair show: the table UNION RAM            |
 //+------------------------------------------------------------------+
 int CBarControl::ReadTypes(const datetime from_time,const datetime to_time,const long &buy_types[],const long &sell_types[],long &types[],long &times[],long &sides[])
  {
   ::ArrayResize(types,0);
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   // New In V4 after implemenation CDatabaseService
   if(this.m_BarInformationManager==NULL)
      return 0;
   int total=this.m_BarInformationManager.ReadDataFromDB(this.m_symbol,this.m_timeframe,from_time,to_time,buy_types,sell_types,types,times,sides);
   //--- UNION what was found and is not written yet (written when the pair is handed over, and at OnDeinit)
   long p_types[],p_times[],p_sides[];
   int pending=this.PendingRows(from_time,to_time,p_types,p_times,p_sides);
   for(int i=0;i<pending;i++)
     {
      bool asked=false;
      const bool buy=(p_sides[i]==(long)SIGNAL_DIRECTION_BUY);
      for(int k=0;k<(buy ? ::ArraySize(buy_types) : ::ArraySize(sell_types)) && !asked;k++)
         asked=((buy ? buy_types[k] : sell_types[k])==p_types[i]);
      bool there=false;
      for(int k=0;k<total && !there && asked;k++)
         there=(types[k]==p_types[i] && times[k]==p_times[i] && sides[k]==p_sides[i]);
      if(!asked || there)
         continue;
      ::ArrayResize(types,total+1);
      ::ArrayResize(times,total+1);
      ::ArrayResize(sides,total+1);
      types[total]=p_types[i];
      times[total]=p_times[i];
      sides[total]=p_sides[i];
      total++;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| What was found on a bar: each type once, with its sides           |
 //+------------------------------------------------------------------+
 ushort CBarControl::EventOf(const ENUM_BAR_INFOR_TYPE type)
  {
   CBar *judge=this.Judge(type);
   return (judge!=NULL ? judge.Event() : this.m_bar_tmp.Event());
  }
 int CBarControl::RowsOfBar(const datetime bar,const ushort event_id,long &types[],int &sides[])
  {
   ::ArrayResize(types,0);
   ::ArrayResize(sides,0);
   for(int i=0;i<this.m_list_Table_BarTimeSeriesCollection.Total();i++)
     {
      CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(i);
      if(row==NULL || row.Time()!=bar)
         continue;
      const long type=row.GetProperty(BAR_PROP_INFOR_TYPE);
      if(this.EventOf((ENUM_BAR_INFOR_TYPE)type)!=event_id)
         continue;
      int k=0;
      while(k<::ArraySize(types) && types[k]!=type)
         k++;
      if(k==::ArraySize(types))
        {
         ::ArrayResize(types,k+1);
         ::ArrayResize(sides,k+1);
         types[k]=type;
         sides[k]=0;
        }
      sides[k]|=(row.GetProperty(BAR_PROP_SIGNAL_DIRECTION)==SIGNAL_DIRECTION_BUY ? 1 : 2);
     }
   return ::ArraySize(types);
  }
 //+------------------------------------------------------------------+
 //| The rows of a type in RAM go                                      |
 //+------------------------------------------------------------------+
 void CBarControl::DeleteRows(const long type)
  {
   bool deleted=false;
   for(int k=this.m_list_Pending_BarTimeSeriesCollection.Total()-1;k>=0;k--)
     {
      CBar *row=this.m_list_Pending_BarTimeSeriesCollection.At(k);
      if(row!=NULL && row.GetProperty(BAR_PROP_INFOR_TYPE)==type)
         this.m_list_Pending_BarTimeSeriesCollection.Delete(k);   // FreeMode false: the bar goes from m_list_Table_BarTimeSeriesCollection below
     }
   for(int i=this.m_list_Table_BarTimeSeriesCollection.Total()-1;i>=0;i--)
     {
      CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(i);
      if(row!=NULL && row.GetProperty(BAR_PROP_INFOR_TYPE)==type)
        {
         this.m_list_Table_BarTimeSeriesCollection.Delete(i);
         deleted=true;
        }
     }
   if(deleted && this.EventAdd((ushort)SERIES_EVENTS_PATTERN,SERIES_EVENTS_PATTERN_ALL,(double)this.m_timeframe,this.m_symbol))
      this.SetEventFlag(true);
  }
 //+------------------------------------------------------------------+
 //| The rows waiting, then their progress go to the DB                |
 //+------------------------------------------------------------------+
 bool CBarControl::UpdateDataToDB(void)
  {
   if(this.m_BarInformationManager==NULL || this.m_SyncManager==NULL)
      return false;
   //--- The rows of one type are written together (one turn of the writes for each)
   while(this.m_list_Pending_BarTimeSeriesCollection.Total()>0)
     {
      CBar *first=this.m_list_Pending_BarTimeSeriesCollection.At(0);
      if(first==NULL)
        {
         this.m_list_Pending_BarTimeSeriesCollection.Delete(0);
         continue;
        }
      long type=first.GetProperty(BAR_PROP_INFOR_TYPE);
      long times[],sides[];
      int indexes[];
      for(int i=0;i<this.m_list_Pending_BarTimeSeriesCollection.Total();i++)
        {
         CBar *row=this.m_list_Pending_BarTimeSeriesCollection.At(i);
         if(row==NULL || row.GetProperty(BAR_PROP_INFOR_TYPE)!=type)
            continue;
         int n=::ArraySize(times);
         ::ArrayResize(times,n+1);
         ::ArrayResize(sides,n+1);
         ::ArrayResize(indexes,n+1);
         times[n]=(long)row.Time();
         sides[n]=row.GetProperty(BAR_PROP_SIGNAL_DIRECTION);
         indexes[n]=i;
        }
      if(!this.m_BarInformationManager.UpdateDataToDB(this.m_symbol,this.m_timeframe,type,times,sides))
         return false;   // the database is busy: what waits stays, the marks too (they go after their rows)
      for(int k=::ArraySize(indexes)-1;k>=0;k--)
         this.m_list_Pending_BarTimeSeriesCollection.Delete(indexes[k]);   // FreeMode false: the bar stays in m_list_Table_BarTimeSeriesCollection
     }
   //--- Nothing is told: what the view sees (the table UNION RAM) does not change by the write
   return this.m_SyncManager.UpdateDataToDB(this.m_sync_object,this.m_symbol,this.m_timeframe);
  }

#endif // CBARCONTROL_MQH_IMPLEMENTATION
#endif // __BARCONTROL_MQH__
