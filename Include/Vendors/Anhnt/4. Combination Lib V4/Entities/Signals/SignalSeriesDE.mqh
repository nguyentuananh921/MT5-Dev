//+------------------------------------------------------------------+
//|                                               SignalSeriesDE.mqh |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
//--- New in V4 (V2 kept the rows in m_hist_time / m_hist_dir of CSignalBase): CSignalSeriesDE, the signals of one template on one pair. As CBarSeriesDE with its
//--- CBarControl: the series holds the judge of its type (V2 GetOrCreateSignal: a child of CSignal) and judges the new bars itself (Calculate), keeps its rows
//--- (m_list_Table_SignalsCollection) and tells them (SERIES_EVENTS_SIGNAL). Live on RAM, saved on the DB: a row that was told waits in
//--- m_list_Pending_SignalsCollection until UpdateDataToDB writes it. The bars are the ones of CBarSeriesDE of the pair, the values the buffers of the indicator
//--- of the template in RAM (MT5 calculates it): CSignalsCollection gives both
#ifndef __SIGNALSERIESDE_MQH__
#define __SIGNALSERIESDE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Bases\BaseObjExt.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include "..\..\Collections\Settings\SyncManager.mqh"
 #include "..\..\Collections\Settings\IndicatorTemplateManager.mqh"
 #include "Signal.mqh"
 #include "Standard\SignalSAR.mqh"
 #include "Standard\SignalMA.mqh"
 #include "Standard\SignalOscillator.mqh"
 #include "Standard\SignalZeroCross.mqh"
 #include "Standard\SignalCrossover.mqh"
 #include "Standard\SignalBands.mqh"
 #include "Standard\SignalFractals.mqh"
 #include "Standard\SignalVolumes.mqh"
#ifndef CSIGNALSERIESDE_MQH_DECLARATION
#define CSIGNALSERIESDE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The signals of a template on a symbol and timeframe              |
 //+------------------------------------------------------------------+
 class CSignalSeriesDE : public CBaseObjExt
  {
   private:
    ENUM_INDICATOR    m_ind_type;                     // The indicator: its type and params
    string            m_params_text;
    string            m_symbol;                       // The pair
    ENUM_TIMEFRAMES   m_timeframe;
    CSignal          *m_judge;                        // The judge of the type (owned, V2 GetOrCreateSignal): NULL for a type that is not a standard indicator
    CArrayObj         m_list_Table_SignalsCollection;     // The rows of the table SignalsCollection of the bars of the series (CSignal), the oldest first
    CArrayObj         m_list_Pending_SignalsCollection;   // RAM only: the rows not in the table yet (FreeMode false: m_list_Table_SignalsCollection owns them)
    datetime          m_judged_to;                    // RAM only: the newest closed bar the template is judged to (0: not judged yet)
    CIndicatorTemplateManager *m_IndicatorTemplateManager;   // The EA holds it: the table SignalsCollection
    long              m_sync_object;                  // The collection the rows are of (its m_type): sync_object of Setting_Sync
    CSyncManager     *m_SyncManager;                  // The EA holds it: the progress of the template (Setting_Sync, RAM)
   //--- The judge of the type (V2 GetOrCreateSignal: the class of its type), NULL for a type that is not a standard indicator
    CSignal          *CreateSignal(const ENUM_INDICATOR type);
   //--- A row goes in its place; found now (pending) it waits to be written (false: the bar has a row already, the row is deleted)
    bool              AddRow(CSignal *row,const bool pending);
   //--- The newest bar synced of the template on the pair (Setting_Sync in RAM): false when it has no row of progress (Python has not made its first chunk)
    bool              Progress(datetime &last_update);
   public:
   //--- The template on the pair: its judge is made
    void              SetSeries(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- What the series needs to judge and to write (CSignalsCollection::CreateSeries): the manager, the collection the rows are of
    void              SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
    void              SetSyncObject(const long sync_object)                           { this.m_sync_object=sync_object;          }
    void              SetSyncManager(CSyncManager *manager)                           { this.m_SyncManager=manager;              }
    ENUM_INDICATOR    TypeIndicator(void)           const { return this.m_ind_type;        }
    string            ParamsText(void)              const { return this.m_params_text;     }
    string            Symbol(void)                  const { return this.m_symbol;          }
    ENUM_TIMEFRAMES   Timeframe(void)               const { return this.m_timeframe;       }
    bool              IsOf(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe) const
                         { return (this.m_ind_type==type && this.m_params_text==params_text && this.m_symbol==symbol && this.m_timeframe==timeframe); }
    bool              IsFound(void)                 const { return (this.m_judge!=NULL);   }
    CArrayObj        *GetList(void)                       { return &this.m_list_Table_SignalsCollection; }
    int               PendingTotal(void)            const { return this.m_list_Pending_SignalsCollection.Total(); }
   //--- The rows before the time (read for a view: the chart showed older bars), the ones waiting to be written stay. Returns how many went
    int               DeleteRows(const datetime before);
    datetime          JudgedTo(void)                const { return this.m_judged_to;       }
    void              SetJudgedTo(const datetime time)    { this.m_judged_to=time;         }
   //--- The rows of this template on the bars of the list go to RAM, the rows waiting to be written stay. Returns the rows read, -1 when the table is not read
    int               ReadDataFromDB(CArrayObj *list);
   //--- The rows of this template from_time to to_time go to RAM next to what is there (CBarMarkerCollection asks it: the chart shows older bars). Returns the rows added, -1 when the table is not read
    int               ReadDataFromDB(const datetime from_time,const datetime to_time);
   //--- The rows waiting go to the table (the marks are the ones of the pair: CSignalsCollection::UpdateDataToDB writes them after the rows of every template).
   //--- True when nothing waits. No event: the view sees the same (the table UNION RAM)
    bool              UpdateDataToDB(void);
   //--- The new bars of the list (the bars of the pair) are judged from the progress of the template (Setting_Sync in RAM): only the bars after it. The rows go to
   //--- RAM and wait to be written. Event: SERIES_EVENTS_SIGNAL for each bar with a new row. Returns the rows found, -1 when the template is not judged to the newest
   //--- closed bar (no progress row of Python, more is missing than the series holds, the indicator has not the values in RAM yet: the next call tries again)
    int               Calculate(CIndicatorDE *indicator,CArrayObj *list);
   //--- The event of a row tells the template by its type (the key) and the column params
    virtual string    EventPackText(const string symbol) const { return symbol+";"+this.m_params_text; }
                      CSignalSeriesDE(void);
                     ~CSignalSeriesDE(void) { if(this.m_judge!=NULL) delete this.m_judge; }
  };
#endif // CSIGNALSERIESDE_MQH_DECLARATION
#ifndef CSIGNALSERIESDE_MQH_IMPLEMENTATION
#define CSIGNALSERIESDE_MQH_IMPLEMENTATION
 CSignalSeriesDE::CSignalSeriesDE(void) : m_ind_type(IND_AC),m_timeframe(PERIOD_CURRENT),m_judge(NULL),m_judged_to(0),
                                          m_IndicatorTemplateManager(NULL),m_sync_object(0),m_SyncManager(NULL)
  {
   this.m_object_type=OBJECT_DE_TYPE_SIGNAL_SERIES;
   this.m_list_Table_SignalsCollection.Sort();
   this.m_list_Pending_SignalsCollection.FreeMode(false);
  }
 void CSignalSeriesDE::SetSeries(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   this.m_ind_type=type;
   this.m_params_text=params_text;
   this.m_symbol=symbol;
   this.m_timeframe=timeframe;
   this.m_judged_to=0;
   this.m_list_Pending_SignalsCollection.Clear();
   this.m_list_Table_SignalsCollection.Clear();
   if(this.m_judge!=NULL)
      delete this.m_judge;
   this.m_judge=this.CreateSignal(type);
  }
 //+------------------------------------------------------------------+
 //| The judge of the type (V2 GetOrCreateSignal): the rules of V4     |
 //| (Python signals.py), ATR has none (CSignal: never a signal)       |
 //+------------------------------------------------------------------+
 CSignal *CSignalSeriesDE::CreateSignal(const ENUM_INDICATOR type)
  {
   switch(type)
     {
      case IND_SAR:        return new CSignalSAR();
      case IND_MA:         return new CSignalMA();
      case IND_AMA:        return new CSignalMA();
      case IND_FRAMA:      return new CSignalMA();
      case IND_DEMA:       return new CSignalMA();
      case IND_TEMA:       return new CSignalMA();
      case IND_VIDYA:      return new CSignalMA();
      case IND_STDDEV:     return new CSignalMA();
      case IND_AD:         return new CSignalMA();
      case IND_BWMFI:      return new CSignalMA();
      case IND_RSI:        return new CSignalOscillator(RSI_OVERBOUGHT,RSI_OVERSOLD);
      case IND_CCI:        return new CSignalOscillator(CCI_OVERBOUGHT,CCI_OVERSOLD);
      case IND_DEMARKER:   return new CSignalOscillator(DEMARKER_OVERBOUGHT,DEMARKER_OVERSOLD);
      case IND_WPR:        return new CSignalOscillator(WPR_OVERBOUGHT,WPR_OVERSOLD);
      case IND_MFI:        return new CSignalOscillator(MFI_OVERBOUGHT,MFI_OVERSOLD);
      case IND_AO:         return new CSignalZeroCross();
      case IND_AC:         return new CSignalZeroCross();
      case IND_FORCE:      return new CSignalZeroCross();
      case IND_OSMA:       return new CSignalZeroCross();
      case IND_TRIX:       return new CSignalZeroCross();
      case IND_CHAIKIN:    return new CSignalZeroCross();
      case IND_OBV:        return new CSignalZeroCross();
      case IND_BEARS:      return new CSignalZeroCross();
      case IND_BULLS:      return new CSignalZeroCross();
      case IND_GATOR:      return new CSignalZeroCross();
      case IND_MOMENTUM:   return new CSignalZeroCross(MOMENTUM_LEVEL);
      case IND_MACD:       return new CSignalTwoLineCross(0,1);
      case IND_ALLIGATOR:  return new CSignalTwoLineCross(0,2);
      case IND_STOCHASTIC: return new CSignalTwoLineCross(0,1,STOCHASTIC_OVERBOUGHT,STOCHASTIC_OVERSOLD);
      case IND_RVI:        return new CSignalTwoLineCross(0,1);
      case IND_ADX:        return new CSignalTwoLineCross(1,2);
      case IND_ADXW:       return new CSignalTwoLineCross(1,2);
      case IND_ICHIMOKU:   return new CSignalTwoLineCross(0,1);
      case IND_BANDS:      return new CSignalBollinger();
      case IND_ENVELOPES:  return new CSignalEnvelopes();
      case IND_FRACTALS:   return new CSignalFractals();
      case IND_VOLUMES:    return new CSignalVolumes();
      case IND_ATR:        return new CSignal();
      default:             return NULL;   // not a standard indicator
     }
  }
 int CSignalSeriesDE::DeleteRows(const datetime before)
  {
   int deleted=0;
   for(int i=this.m_list_Table_SignalsCollection.Total()-1;i>=0;i--)
     {
      CSignal *row=this.m_list_Table_SignalsCollection.At(i);
      if(row==NULL || row.Time()>=before)
         continue;
      bool pending=false;
      for(int k=0;k<this.m_list_Pending_SignalsCollection.Total() && !pending;k++)
         pending=(this.m_list_Pending_SignalsCollection.At(k)==row);
      if(pending)
         continue;
      this.m_list_Table_SignalsCollection.Delete(i);
      deleted++;
     }
   return deleted;
  }
 bool CSignalSeriesDE::AddRow(CSignal *row,const bool pending)
  {
   if(row==NULL)
      return false;
   if(this.m_list_Table_SignalsCollection.Search(row)>=0 || !this.m_list_Table_SignalsCollection.InsertSort(row))
     {
      delete row;
      return false;
     }
   if(pending)
      this.m_list_Pending_SignalsCollection.Add(row);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows of the bars of the list go to RAM                        |
 //+------------------------------------------------------------------+
 int CSignalSeriesDE::ReadDataFromDB(CArrayObj *list)
  {
   if(this.m_IndicatorTemplateManager==NULL || list==NULL || list.Total()==0)
      return -1;
   CBar *oldest=list.At(0);
   CBar *newest=list.At(list.Total()-1);
   if(oldest==NULL || newest==NULL)
      return -1;
   //--- The rows waiting to be written stay (they are not in the table yet), the others are read again
   for(int i=this.m_list_Table_SignalsCollection.Total()-1;i>=0;i--)
     {
      bool pending=false;
      for(int k=0;k<this.m_list_Pending_SignalsCollection.Total() && !pending;k++)
         pending=(this.m_list_Pending_SignalsCollection.At(k)==this.m_list_Table_SignalsCollection.At(i));
      if(!pending)
         this.m_list_Table_SignalsCollection.Delete(i);
     }
   int loaded=this.ReadDataFromDB(oldest.Time(),newest.Time());
   datetime last_update=0;
   this.m_judged_to=(this.Progress(last_update) ? last_update : 0);   // judged to where the progress is: the next call judges the bars after it
   return loaded;
  }
 //+------------------------------------------------------------------+
 //| The rows of this template from_time to to_time go to RAM          |
 //+------------------------------------------------------------------+
 int CSignalSeriesDE::ReadDataFromDB(const datetime from_time,const datetime to_time)
  {
   if(this.m_IndicatorTemplateManager==NULL)
      return -1;
   long times[],sides[];
   const int total=this.m_IndicatorTemplateManager.ReadDataFromDB(this.m_symbol,this.m_timeframe,from_time,to_time,this.m_ind_type,this.m_params_text,times,sides);
   if(total==WRONG_VALUE)
      return -1;
   int loaded=0;
   for(int r=0;r<total;r++)
      if(this.AddRow(new CSignal((datetime)times[r],(ENUM_SIGNAL_DIRECTION)sides[r]),false))   // a row there already is kept (AddRow refuses the second)
         loaded++;
   return loaded;
  }
 //+------------------------------------------------------------------+
 //| The newest bar synced of the template on the pair                 |
 //+------------------------------------------------------------------+
 bool CSignalSeriesDE::Progress(datetime &last_update)
  {
   last_update=0;
   if(this.m_SyncManager==NULL)
      return false;
   return this.m_SyncManager.Read_RAM(this.m_sync_object,(long)this.m_ind_type,this.m_params_text,this.m_symbol,this.m_timeframe,last_update);   // RAM
  }
 //+------------------------------------------------------------------+
 //| The new bars of the list are judged from the progress             |
 //+------------------------------------------------------------------+
 int CSignalSeriesDE::Calculate(CIndicatorDE *indicator,CArrayObj *list)
  {
   if(this.m_judge==NULL || this.m_SyncManager==NULL || list==NULL || list.Total()==0)
      return -1;
   if(!this.m_SyncManager.IsPythonDone())
      return -1;   // Python Current writes the pairs of Setting_SymbolTF now: one writer for a pair at a time
   datetime last_closed=::iTime(this.m_symbol,this.m_timeframe,1);
   const datetime previous_closed=::iTime(this.m_symbol,this.m_timeframe,2);   // marked here: one new bar is judged, its rows are new
   CBar *newest=(list.Total()>1 ? list.At(list.Total()-2) : NULL);
   if(last_closed==0 || newest==NULL || newest.Time()!=last_closed)
      return -1;   // the series has not the newest closed bar yet (CBarTimeSeriesCollection refreshes it first)
   if(this.m_judged_to==last_closed)
      return 0;
   datetime since=0;
   if(!this.Progress(since))
      return -1;   // no row of progress: the history of the start is Python's
   if(since>=last_closed)
     {
      this.m_judged_to=last_closed;
      return 0;
     }
   CBar *oldest=list.At(0);
   if(oldest==NULL || oldest.Time()>since)
      return -1;   // what is missing is more than the series holds: Python fills it
   if(indicator==NULL)
      return -1;   // the indicator of the template is not made on the pair yet: nothing is marked as judged
   long row_times[],row_sides[];
   if(this.m_judge.Calculate(indicator,list,since,row_times,row_sides)<0)
      return -1;   // the indicator has not the values of the bars in RAM yet
   long told_params[];
   for(int i=0;i<::ArraySize(row_times);i++)
      if(this.AddRow(new CSignal((datetime)row_times[i],(ENUM_SIGNAL_DIRECTION)row_sides[i]),true))
        {
         int n=::ArraySize(told_params);
         ::ArrayResize(told_params,n+1);
         told_params[n]=this.EventPack((datetime)row_times[i],(long)this.m_ind_type,(ENUM_SIGNAL_DIRECTION)row_sides[i],since==previous_closed);
        }
   this.m_SyncManager.Update_Sync_Setting(this.m_sync_object,(long)this.m_ind_type,this.m_symbol,this.m_timeframe,last_closed,this.m_sync_object,true,this.m_params_text);   // the mark waits in RAM with the rows
   this.m_judged_to=last_closed;
   //--- RAM changed: told (Event Rule), each row by its own event with its bar
   for(int k=0;k<::ArraySize(told_params);k++)
      this.EventSend((ushort)SERIES_EVENTS_SIGNAL,told_params[k],(double)this.m_timeframe,this.EventPackText(this.m_symbol));
   return ::ArraySize(row_times);
  }
 //+------------------------------------------------------------------+
 //| The rows waiting go to the DB                                    |
 //+------------------------------------------------------------------+
 bool CSignalSeriesDE::UpdateDataToDB(void)
  {
   if(this.m_list_Pending_SignalsCollection.Total()==0)
      return true;
   if(this.m_IndicatorTemplateManager==NULL)
      return false;
   long times[],sides[];
   ::ArrayResize(times,this.m_list_Pending_SignalsCollection.Total());
   ::ArrayResize(sides,this.m_list_Pending_SignalsCollection.Total());
   for(int i=0;i<this.m_list_Pending_SignalsCollection.Total();i++)
     {
      CSignal *row=this.m_list_Pending_SignalsCollection.At(i);
      times[i]=(row!=NULL ? (long)row.Time() : 0);
      sides[i]=(row!=NULL ? (long)row.SignalDirection() : (long)SIGNAL_DIRECTION_NONE);
     }
   if(!this.m_IndicatorTemplateManager.UpdateDataToDB(this.m_symbol,this.m_timeframe,this.m_ind_type,this.m_params_text,times,sides))
      return false;   // the database is busy: what waits stays
   this.m_list_Pending_SignalsCollection.Clear();   // FreeMode false: the rows stay in m_list_Table_SignalsCollection
   return true;
  }
#endif // CSIGNALSERIESDE_MQH_IMPLEMENTATION
#endif // __SIGNALSERIESDE_MQH__
