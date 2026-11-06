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
    long              m_template_id;                  // The template (Setting_IndicatorTemplate): its id, type and params
    ENUM_INDICATOR    m_ind_type;
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
    void              SetSeries(const long template_id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- What the series needs to judge and to write: the file of the account, the id of the symbol, the collection, the manager (CSignalsCollection::CreateSeries)
    void              SetDatabase(CIndicatorTemplateManager *manager,const long sync_object,CSyncManager *sync);
    long              TemplateID(void)              const { return this.m_template_id;     }
    ENUM_INDICATOR    TypeIndicator(void)           const { return this.m_ind_type;        }
    string            ParamsText(void)              const { return this.m_params_text;     }
    string            Symbol(void)                  const { return this.m_symbol;          }
    ENUM_TIMEFRAMES   Timeframe(void)               const { return this.m_timeframe;       }
    bool              IsOf(const long template_id,const string symbol,const ENUM_TIMEFRAMES timeframe) const
                         { return (this.m_template_id==template_id && this.m_symbol==symbol && this.m_timeframe==timeframe); }
    bool              IsFound(void)                 const { return (this.m_judge!=NULL);   }
    CArrayObj        *GetList(void)                       { return &this.m_list_Table_SignalsCollection; }
    int               PendingTotal(void)            const { return this.m_list_Pending_SignalsCollection.Total(); }
    datetime          JudgedTo(void)                const { return this.m_judged_to;       }
    void              SetJudgedTo(const datetime time)    { this.m_judged_to=time;         }
   //--- The rows of the table CSignalsCollection read for this template (times, sides) go to RAM, the rows waiting to be written stay (once after Python, then when Python tells it wrote more).
   //--- Returns the rows read, -1 when the table is not asked
    int               ReadDataFromDB(CArrayObj *list,const long &times[],const long &sides[]);
   //--- The rows waiting go to the table (the marks are the ones of the pair: CSignalsCollection::UpdateDataToDB writes them after the rows of every template).
   //--- True when nothing waits. No event: the view sees the same (the table UNION RAM)
    bool              UpdateDataToDB(void);
   //--- The new bars of the list (the bars of the pair) are judged from the progress of the template (Setting_Sync in RAM): only the bars after it. The rows go to
   //--- RAM and wait to be written. Event: SERIES_EVENTS_SIGNAL for each bar with a new row. Returns the rows found, -1 when the template is not judged to the newest
   //--- closed bar (no progress row of Python, more is missing than the series holds, the indicator has not the values in RAM yet: the next call tries again)
    int               Calculate(CIndicatorDE *indicator,CArrayObj *list);
   //--- The rows older than the oldest bar of the list go (a row waiting to be written stays)
    void              DeleteRows(CArrayObj *list);
   //--- The rows found and not written yet, from_time to to_time (both in): the view reads the table UNION these. Returns how many
    int               PendingRows(const datetime from_time,const datetime to_time,long &times[],long &sides[]) const;
   //--- What was found on a bar: its sides (1 Buy, 2 Sell, as NewSidesOfBar), 0 when nothing
    int               RowsOfBar(const datetime bar) const;
                      CSignalSeriesDE(void);
                     ~CSignalSeriesDE(void) { if(this.m_judge!=NULL) delete this.m_judge; }
  };
#endif // CSIGNALSERIESDE_MQH_DECLARATION
#ifndef CSIGNALSERIESDE_MQH_IMPLEMENTATION
#define CSIGNALSERIESDE_MQH_IMPLEMENTATION
 CSignalSeriesDE::CSignalSeriesDE(void) : m_template_id(0),m_ind_type(IND_AC),m_timeframe(PERIOD_CURRENT),m_judge(NULL),m_judged_to(0),
                                          m_IndicatorTemplateManager(NULL),m_sync_object(0),m_SyncManager(NULL)
  {
   this.m_object_type=OBJECT_DE_TYPE_SIGNAL_SERIES;
   this.m_list_Table_SignalsCollection.Sort();
   this.m_list_Pending_SignalsCollection.FreeMode(false);
  }
 void CSignalSeriesDE::SetSeries(const long template_id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   this.m_template_id=template_id;
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
 void CSignalSeriesDE::SetDatabase(CIndicatorTemplateManager *manager,const long sync_object,CSyncManager *sync)
  {
   this.m_IndicatorTemplateManager=manager;
   this.m_sync_object=sync_object;
   this.m_SyncManager=sync;
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
      case IND_ADX:        return new CSignalTwoLineCross(1,2);
      case IND_ADXW:       return new CSignalTwoLineCross(1,2);
      case IND_ALLIGATOR:  return new CSignalTwoLineCross(0,2);
      case IND_STOCHASTIC: return new CSignalTwoLineCross(0,1,STOCHASTIC_OVERBOUGHT,STOCHASTIC_OVERSOLD);
      case IND_RVI:        return new CSignalTwoLineCross(0,1);
      case IND_ICHIMOKU:   return new CSignalTwoLineCross(0,1);
      case IND_BANDS:      return new CSignalBollinger();
      case IND_ENVELOPES:  return new CSignalEnvelopes();
      case IND_FRACTALS:   return new CSignalFractals();
      case IND_VOLUMES:    return new CSignalVolumes();
      case IND_ATR:        return new CSignal();
      default:             return NULL;   // not a standard indicator
     }
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
 //| The rows older than the oldest bar of the list go                 |
 //+------------------------------------------------------------------+
 void CSignalSeriesDE::DeleteRows(CArrayObj *list)
  {
   CBar *oldest=(list!=NULL ? list.At(0) : NULL);
   if(oldest==NULL)
      return;
   for(int i=this.m_list_Table_SignalsCollection.Total()-1;i>=0;i--)
     {
      CSignal *row=this.m_list_Table_SignalsCollection.At(i);
      if(row==NULL || row.Time()>=oldest.Time())
         continue;
      bool pending=false;
      for(int k=0;k<this.m_list_Pending_SignalsCollection.Total() && !pending;k++)
         pending=(this.m_list_Pending_SignalsCollection.At(k)==row);
      if(!pending)
         this.m_list_Table_SignalsCollection.Delete(i);
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the bars of the list go to RAM                        |
 //+------------------------------------------------------------------+
 int CSignalSeriesDE::ReadDataFromDB(CArrayObj *list,const long &times[],const long &sides[])
  {
   if(list==NULL || list.Total()==0)
      return -1;
   // New In V4 after implemenation CDatabaseService
   //--- The rows waiting to be written stay (they are not in the table yet), the others are read again
   for(int i=this.m_list_Table_SignalsCollection.Total()-1;i>=0;i--)
     {
      bool pending=false;
      for(int k=0;k<this.m_list_Pending_SignalsCollection.Total() && !pending;k++)
         pending=(this.m_list_Pending_SignalsCollection.At(k)==this.m_list_Table_SignalsCollection.At(i));
      if(!pending)
         this.m_list_Table_SignalsCollection.Delete(i);
     }
   int loaded=0;
   for(int r=0;r<::ArraySize(times);r++)
      if(this.AddRow(new CSignal((datetime)times[r],(ENUM_SIGNAL_DIRECTION)sides[r]),false))   // a row waiting on the same bar is kept (AddRow refuses the second)
         loaded++;
   datetime last_update=0;
   this.m_judged_to=(this.Progress(last_update) ? last_update : 0);   // judged to where the progress is: the next call judges the bars after it
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
   long keys[],last_bars[];
   this.m_SyncManager.Read_RAM(this.m_sync_object,this.m_symbol,this.m_timeframe,keys,last_bars);   // RAM
   for(int k=0;k<::ArraySize(keys);k++)
      if(keys[k]==this.m_template_id)
        {
         last_update=(datetime)last_bars[k];
         return true;
        }
   return false;
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
   this.DeleteRows(list);
   long found_times[];
   for(int i=0;i<::ArraySize(row_times);i++)
      if(this.AddRow(new CSignal((datetime)row_times[i],(ENUM_SIGNAL_DIRECTION)row_sides[i]),true))
        {
         int n=::ArraySize(found_times);
         ::ArrayResize(found_times,n+1);
         found_times[n]=row_times[i];
        }
   this.m_SyncManager.Update_Sync_Setting(this.m_sync_object,this.m_template_id,this.m_symbol,this.m_timeframe,last_closed,this.m_sync_object,true);   // the mark waits in RAM with the rows
   this.m_judged_to=last_closed;
   //--- RAM changed: told (Event Rule), the view reads the table UNION what waits in RAM
   if(::ArraySize(found_times)>SERIES_EVENTS_PATTERN_MAX)
     {
      ::ArrayResize(found_times,1);
      found_times[0]=SERIES_EVENTS_PATTERN_ALL;   // too many to tell one by one: the markers of the chart are made again
     }
   for(int k=0;k<::ArraySize(found_times);k++)
      if(this.EventAdd((ushort)SERIES_EVENTS_SIGNAL,found_times[k],(double)this.m_timeframe,this.m_symbol))
         this.SetEventFlag(true);
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
   if(!this.m_IndicatorTemplateManager.UpdateDataToDB(this.m_symbol,this.m_timeframe,this.m_template_id,times,sides))
      return false;   // the database is busy: what waits stays
   this.m_list_Pending_SignalsCollection.Clear();   // FreeMode false: the rows stay in m_list_Table_SignalsCollection
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows found and not written yet in a range of bars             |
 //+------------------------------------------------------------------+
 int CSignalSeriesDE::PendingRows(const datetime from_time,const datetime to_time,long &times[],long &sides[]) const
  {
   ::ArrayResize(times,0);
   ::ArrayResize(sides,0);
   for(int i=0;i<this.m_list_Pending_SignalsCollection.Total();i++)
     {
      CSignal *row=this.m_list_Pending_SignalsCollection.At(i);
      if(row==NULL || row.Time()<from_time || row.Time()>to_time)
         continue;
      int n=::ArraySize(times);
      ::ArrayResize(times,n+1);
      ::ArrayResize(sides,n+1);
      times[n]=(long)row.Time();
      sides[n]=(long)row.SignalDirection();
     }
   return ::ArraySize(times);
  }
 //+------------------------------------------------------------------+
 //| What was found on a bar: its sides                                |
 //+------------------------------------------------------------------+
 int CSignalSeriesDE::RowsOfBar(const datetime bar) const
  {
   int sides=0;
   for(int i=this.m_list_Table_SignalsCollection.Total()-1;i>=0;i--)
     {
      CSignal *row=this.m_list_Table_SignalsCollection.At(i);
      if(row==NULL || row.Time()<bar)
         break;   // the oldest first: nothing older is on the bar
      if(row.Time()==bar)
         sides|=(row.SignalDirection()==SIGNAL_DIRECTION_BUY ? 1 : 2);
     }
   return sides;
  }
#endif // CSIGNALSERIESDE_MQH_IMPLEMENTATION
#endif // __SIGNALSERIESDE_MQH__
