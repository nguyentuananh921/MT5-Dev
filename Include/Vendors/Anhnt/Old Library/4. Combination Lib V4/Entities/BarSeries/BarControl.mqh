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
   //--- What the control needs to judge and to write (CBarSeriesDE gives them): the bars of the series, the pair, the collection the rows are of, the managers
    void              SetListSeries(CArrayObj *list)                                 { this.m_list_series=list;                 }
    void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe) { this.m_symbol=symbol; this.m_timeframe=timeframe; }
    void              SetSyncObject(const long sync_object)                          { this.m_sync_object=sync_object;          }
    void              SetSyncManager(CSyncManager *manager)                          { this.m_SyncManager=manager;              }
    void              SetBarInformationManager(CBarInformationManager *manager)      { this.m_BarInformationManager=manager;    }
    int               PendingTotal(void)                           const { return this.m_list_Pending_BarTimeSeriesCollection.Total(); }
   //--- The rows of the table on RAM (written or not), sorted by the time of the bar: the views read them (CBarMarkerCollection)
    CArrayObj        *GetList(void)                                      { return &this.m_list_Table_BarTimeSeriesCollection; }
    datetime          JudgedTo(void)                               const { return this.m_judged_to;   }
    void              SetJudgedTo(const datetime time)                   { this.m_judged_to=time;   }
   //--- The rows of the table of the bars the series holds go to RAM, the rows waiting to be written stay (once at the creation of the series, then when Python
   //--- tells it wrote more: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE). No event: the views draw at PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE, after it
    bool              ReadDataFromDB(void);
   //--- The rows of the table from_time to to_time go to RAM next to what is there (a row there already is not read twice). The bar of a row the series
   //--- does not hold comes from the chart (CBarMarkerCollection asks it: the chart shows older bars). Returns the rows added, WRONG_VALUE when the table is not read
    int               ReadDataFromDB(const datetime from_time,const datetime to_time);
   //--- The rows waiting go to the table, then their progress (rows first). True when nothing waits. No event: the view sees the same (the table UNION RAM)
    bool              UpdateDataToDB(void);
   //--- The new bars are judged for every type from its progress (Setting_Sync): only the bars after it. The rows go to RAM and wait to be written (UpdateDataToDB).
   //--- CBarSeriesDE::RefreshSeries calls it (V2: Refresh called UpdateAll of m_patterns_control). Event: the event of the type (EventOf) for each bar with a new row. True when RAM changed
    bool              Calculate(void);
   //--- The rows of a type (its parameter changed: the views hear BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED)
    void              DeleteRows(const long type);
   //--- The rows of the table before the time (read for a view: the chart showed older bars), the ones waiting to be written stay. Returns how many went
    int               DeleteRows(const datetime before);
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
   int loaded=this.ReadDataFromDB(oldest.Time(),newest.Time());
   if(loaded==WRONG_VALUE)
      return false;
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
   this.m_list_Table_BarTimeSeriesCollection.Sort(BAR_PROP_TIME);   // a row there already is found by its time (the new rows go in after the loop)
   CArrayObj added;
   added.FreeMode(false);
   long asked_type=-1,asked_group=0;   // the group of the type asked last (the rows come in the order of type_infor)
   for(int r=0;r<read_total;r++)
     {
      long type=read_types[r],time=read_times[r],direction=read_sides[r];
      if(type!=asked_type)
        {
         asked_type=type;
         CBarInformationSetting *setting=this.m_BarInformationManager.Read_RAM((ENUM_BAR_INFOR_TYPE)type);
         asked_group=(setting!=NULL ? (long)setting.Group() : 0);
        }
      bool there=false;
      this.m_bar_tmp.SetSymbolPeriod(this.m_symbol,this.m_timeframe,(datetime)time);
      int at=this.m_list_Table_BarTimeSeriesCollection.Search(&this.m_bar_tmp);
      for(int k=at;k>=0 && k<this.m_list_Table_BarTimeSeriesCollection.Total() && !there;k--)
        {
         CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(k);
         if(row==NULL || (long)row.Time()!=time)
            break;
         there=(row.GetProperty(BAR_PROP_INFOR_TYPE)==type && row.GetProperty(BAR_PROP_SIGNAL_DIRECTION)==direction);
        }
      for(int k=at+1;at>=0 && k<this.m_list_Table_BarTimeSeriesCollection.Total() && !there;k++)
        {
         CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(k);
         if(row==NULL || (long)row.Time()!=time)
            break;
         there=(row.GetProperty(BAR_PROP_INFOR_TYPE)==type && row.GetProperty(BAR_PROP_SIGNAL_DIRECTION)==direction);
        }
      if(there)
         continue;
      CBar *row=NULL;
      CBar *bar=this.GetBar((datetime)time);
      if(bar!=NULL)
         row=this.NewRow(bar,type,asked_group,direction);
      else
        {
         MqlRates rates[1];   // a bar the series does not hold: the chart has it
         if(::CopyRates(this.m_symbol,this.m_timeframe,(datetime)time,1,rates)==1 && (long)rates[0].time==time)
           {
            CBar chart_bar(this.m_symbol,this.m_timeframe,rates[0],digits);
            row=this.NewRow(&chart_bar,type,asked_group,direction);
           }
        }
      if(row!=NULL)
         added.Add(row);
     }
   int loaded=0;
   for(int i=0;i<added.Total();i++)
     {
      CBar *row=added.At(i);
      if(this.m_list_Table_BarTimeSeriesCollection.Add(row))
         loaded++;
      else
         delete row;
     }
   this.m_list_Table_BarTimeSeriesCollection.Sort(BAR_PROP_TIME);
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
   const datetime previous_closed=::iTime(this.m_symbol,this.m_timeframe,2);   // a type marked here judges one new bar: its rows are new
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
   long told_params[];        // each row added and the event that tells it
   ushort told_events[];
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
      if(!has_progress || since>=last_closed)
         continue;   // no row of progress: the history of the start is Python's
      CBar *oldest=this.m_list_series.At(0);
      if(oldest==NULL || oldest.Time()>since)
        {
         finished=false;   // what is missing is more than the series holds: Python fills it
         continue;
        }
      this.Find(found_types[t],this.m_list_series,since);
      long row_times[],row_sides[];
      this.RowsTo(row_times,row_sides);
      CBarInformationSetting *setting=(this.m_BarInformationManager!=NULL ? this.m_BarInformationManager.Read_RAM((ENUM_BAR_INFOR_TYPE)found_types[t]) : NULL);
      long group=(setting!=NULL ? (long)setting.Group() : 0);
      const ushort event_id=this.EventOf(found_types[t]);
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
         int told=::ArraySize(told_events);
         ::ArrayResize(told_events,told+1);
         ::ArrayResize(told_params,told+1);
         told_events[told]=event_id;
         told_params[told]=this.EventPack((datetime)row_times[i],(long)found_types[t],(ENUM_SIGNAL_DIRECTION)row_sides[i],since==previous_closed);
        }
      this.m_SyncManager.Update_Sync_Setting(this.m_sync_object,(long)found_types[t],this.m_symbol,this.m_timeframe,last_closed,this.m_sync_object,true);
      changed=true;
     }
   if(found_total>0 && !any_progress)
      finished=false;   // Python has not made the first chunk of any type of the pair: the timer looks again
   if(finished)
      this.m_judged_to=last_closed;
   //--- RAM changed: told (Event Rule), each kind by its own event (EventOf), each row with what it is; the view reads the table UNION what waits in RAM
   const ushort events[]={(ushort)SERIES_EVENTS_PATTERN,(ushort)SERIES_EVENTS_SWING,(ushort)SERIES_EVENTS_BOS,(ushort)SERIES_EVENTS_CHOCH};
   for(int e=0;e<::ArraySize(events);e++)
     {
      int told_total=0;
      for(int k=0;k<::ArraySize(told_events);k++)
         if(told_events[k]==events[e])
            told_total++;
      for(int k=0;k<::ArraySize(told_events);k++)
         if(told_events[k]==events[e])
            this.EventSend(events[e],told_params[k],(double)this.m_timeframe,this.EventPackText(this.m_symbol));
     }
   return changed;
  }
 //+------------------------------------------------------------------+
 //| The event of a type                                               |
 //+------------------------------------------------------------------+
 ushort CBarControl::EventOf(const ENUM_BAR_INFOR_TYPE type)
  {
   CBar *judge=this.Judge(type);
   return (judge!=NULL ? judge.Event() : this.m_bar_tmp.Event());
  }
 //+------------------------------------------------------------------+
 //| The rows before a time in RAM go (the ones waiting stay)          |
 //+------------------------------------------------------------------+
 int CBarControl::DeleteRows(const datetime before)
  {
   int deleted=0;
   for(int i=this.m_list_Table_BarTimeSeriesCollection.Total()-1;i>=0;i--)
     {
      CBar *row=this.m_list_Table_BarTimeSeriesCollection.At(i);
      if(row==NULL || row.Time()>=before)
         continue;
      bool pending=false;
      for(int k=0;k<this.m_list_Pending_BarTimeSeriesCollection.Total() && !pending;k++)
         pending=(this.m_list_Pending_BarTimeSeriesCollection.At(k)==row);
      if(pending)
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
