//+------------------------------------------------------------------+
//|                                            SignalsCollection.mqh |
//| Use m_account_key in CDatabaseService to Join 2 Database On RAM  |
//| Create table SignalsCollection  by CIndicatorsCollection         |
//| V5 No More Update table SignalsCollection in Account Database    |
//+------------------------------------------------------------------+
#ifndef __SIGNALSCOLLECTION_MQH__
#define __SIGNALSCOLLECTION_MQH__
 #include "..\Services\DELib\DatabaseService.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "BarTimeSeriesCollection.mqh"
 #include "IndicatorsCollection.mqh"
 #include "PendingPairs.mqh"
 #include "Settings\SyncManager.mqh"
 #include "Settings\IndicatorTemplateManager.mqh"
 //--- V5: as V2, the collection makes the CSignal of an indicator (GetOrCreateSignal): it knows the classes of the rules
 #include "..\Entities\Signals\Signal.mqh"                 // V5: the entity (the rows of a signal)
 #include "..\UseCases\Judges\Signals\SignalJudge.mqh"     // V5: the rule (use case)
 #include "..\Controllers\JudgeControl.mqh"                // V5: the judging of the new bars, once for the bars and the signals
 #include "..\UseCases\Judges\Signals\Standard\SignalSAR.mqh"
 #include "..\UseCases\Judges\Signals\Standard\SignalMA.mqh"
 #include "..\UseCases\Judges\Signals\Standard\SignalOscillator.mqh"
 #include "..\UseCases\Judges\Signals\Standard\SignalZeroCross.mqh"
 #include "..\UseCases\Judges\Signals\Standard\SignalCrossover.mqh"
 #include "..\UseCases\Judges\Signals\Standard\SignalBands.mqh"
 #include "..\UseCases\Judges\Signals\Standard\SignalFractals.mqh"
 #include "..\UseCases\Judges\Signals\Standard\SignalSourceMA.mqh"   // Change in V5: was SignalVolumes.mqh (CSignalVolumes)
#ifndef CSIGNALSCOLLECTION_MQH_DECLARATION
#define CSIGNALSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The signals of the indicator templates, history and new bars     |
 //+------------------------------------------------------------------+
 //class CSignalsCollection : public CBaseObj
 class CSignalsCollection : public CJudgeControl
  {
   private:
    CBarTimeSeriesCollection *m_BarTimeSeriesCollection;   // the EA holds it: the bars the signals are found on, the id of a symbol
    CSymbolTFManager         *m_SymbolTFManager;           // the EA holds it: the pairs the library keeps up to date (Setting_SymbolTF)
    CSyncManager             *m_SyncManager;               // the EA holds it: what was synced and up to where (Setting_Sync)
    CIndicatorTemplateManager *m_IndicatorTemplateManager;   // the EA holds it: the templates whose signals are found
    CIndicatorsCollection *m_IndicatorsCollection;   // the EA holds it: the indicator of a template on a pair (type + params, never the handle): its buffers in RAM
    CArrayObj         m_list;                    // V2: the signals (CSignal, owned), one for each indicator (each template on each pair of Setting_SymbolTF)
    CArrayObj         m_list_judge;              // V5: the judge of each signal (CSignalJudge, owned), at the same index as its CSignal (an entity does not hold its rule)
    CPendingPairs     m_pending;                 // New in V5: the pairs whose new bar is not judged yet (RetryPending)
   //--- V5 (moved from CSignal, Interface Adapters): (1) the new bars of the list judged from the progress, the rows set on the signal, the events told,
   //--- (2) the rows of the bars of the list, (3) from_time to to_time go to RAM, (4) the newest bar synced of the template on the pair (Setting_Sync in RAM)
    //int               Calculate(CSignal *signal,CSignalJudge *judge,CArrayObj *list);
    int               Calculate(const int index,CArrayObj *list);   // V5: the signal at the index and its judge, by CJudgeControl::JudgeNewBars
    int               ReadDataFromDB(CSignal *signal,CArrayObj *list);
    int               ReadDataFromDB(CSignal *signal,const datetime from_time,const datetime to_time);
    bool              Progress(CSignal *signal,datetime &last_update);
   protected:
   //--- V5 CJudgeControl, the target is the index of the signal: (1) its judge, (2) its source refreshed and ready (the values of the bars from two before the
   //--- first one after `since`: the rules look two bars back at most), (3) a row set on the signal
    virtual CJudge   *JudgeOf(const int target)                                              { return this.m_list_judge.At(target); }
    virtual bool      Prepare(const int target,CArrayObj *list,const datetime since);
    virtual bool      StoreRow(const int target,const datetime time,const ENUM_SIGNAL_DIRECTION side);
   private:
   //--- The series of a template on a pair: (1) the one in the list, (2) made and added (its judge, the file of the account)
   //--- V2: the index of the signal of an indicator in the list (-1: none)
    int               FindIndex(CIndicatorDE *indicator);
   //--- V2: the signal of the indicator, or a new one added (its rule by the type, the managers); NULL for a type that is not a standard indicator
    CSignal          *GetOrCreateSignal(CIndicatorDE *indicator);
   //--- (1) every template on a pair, (2) a template on every pair (as CIndicatorsCollection)
    void              CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              CreateSeries(const ENUM_INDICATOR type,const string params_text);
   //--- The series of (1) a template, (2) a pair go
    void              DeleteSeries(const ENUM_INDICATOR type,const string params_text);
    void              DeleteSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The new bars of every pair of a symbol: each series of the pair judges itself, its events go out, what is new on the newest closed bar is told
   //--- (as CBarTimeSeriesCollection::RefreshTimeseries_). False when the call had its share of time
    bool              RefreshTimeseries(CBarTimeSeriesDE *timeseries,const ulong started);
   //--- New in V5: the signals of a pair judged up to its newest closed bar. False: not all of them (not ready, Python writes, the share of time is over)
    bool              JudgePair(const string symbol,const ENUM_TIMEFRAMES timeframe,const ulong started);
   public:
   //--- The signal of a template on a pair, by its key (NULL: none): a row of Python goes to it (CSignal::StoreRow)
    CSignal          *GetSeries(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              SetBarTimeSeriesCollection(CBarTimeSeriesCollection *collection) { this.m_BarTimeSeriesCollection=collection; }
   //--- The signals of the templates on the pairs (CSignal): their rows on RAM are read by the views (CBarMarkerCollection)
    CArrayObj        *GetList(void)                                                    { return &this.m_list;        }
    void              SetSymbolTFManager(CSymbolTFManager *manager)                   { this.m_SymbolTFManager=manager; }
    void              SetSyncManager(CSyncManager *manager)                           { this.m_SyncManager=manager; }
    void              SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
    void              SetIndicatorsCollection(CIndicatorsCollection *collection)      { this.m_IndicatorsCollection=collection; }   //--- Lifecycle: opens the file of the account and makes SignalsCollection (the flips: pair, type and params of the indicator, open time of the bar, side).
   //--- A table of progress of an EA before Setting_Sync is moved to it
    bool              OnInitEvent(void);
   //--- A chart change (REASON_CHARTCHANGE): RAM keeps the rows of the bars of each series of the pairs only, what a view read before them goes (it reads it again)
    void              OnDeinitEvent(const int reason);
   //--- Python wrote its part (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), a pair or a template was added or deleted
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Change in V5: the new bars are judged at SERIES_EVENTS_NEW_BAR (OnChartEvent), nothing is asked while nothing is new (a closed market: no tick, no bar, no event).
   //--- (1) every symbol: the tester only (no OnChartEvent there), after CBarTimeSeriesCollection::RefreshSeries; (2) OnTimer: the pairs that wait, a symbol that rests is skipped
    void              RefreshSeries(void);
    void              RetryPending(void);
   //--- The rows of the bars of (1) every pair, (2) one pair go to RAM, each series reads its own: after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE). Event: SERIES_EVENTS_SIGNAL ALL of the pair
    bool              ReadDataFromDB(void);
    bool              ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The rows of every series of a pair from_time to to_time go to RAM next to what is there (CBarMarkerCollection asks it). Returns the rows added
    int               ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time);
   //--- What waits in RAM goes to the table, then its marks (rows first): (1) every pair, (2) one pair. True when nothing waits
                      CSignalsCollection(void) : m_BarTimeSeriesCollection(NULL),m_SymbolTFManager(NULL),m_SyncManager(NULL),m_IndicatorTemplateManager(NULL),
                                                 m_IndicatorsCollection(NULL) { this.m_object_type=COLLECTION_SIGNALS_ID; }
                     ~CSignalsCollection(void) {}
  };
#endif // CSIGNALSCOLLECTION_MQH_DECLARATION
#ifndef CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#define CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The tables of the signals (the file Account of CDatabaseService).|
 //| The tables of an EA before the rename (IndicatorSignalSeries) are |
 //| renamed, their rows stay                                         |
 //+------------------------------------------------------------------+
 void CSignalsCollection::OnDeinitEvent(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE || this.m_BarTimeSeriesCollection==NULL)
      return;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CSignal *series=this.m_list.At(i);
      if(series==NULL)
         continue;
      CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(series.Symbol(),series.Timeframe());
      CBar *oldest=(bars!=NULL && bars.GetList().Total()>0 ? bars.GetList().At(0) : NULL);
      if(oldest!=NULL)
         series.DeleteRows(oldest.Time());
     }
  }
 bool CSignalsCollection::OnInitEvent(void)
  {
   //--- As CIndicatorsCollection: a series for every template on every pair. Its table is CIndicatorTemplateManager's, the rows go to RAM after Python (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE: ReadDataFromDB)
   if(this.m_SymbolTFManager==NULL || this.m_IndicatorTemplateManager==NULL)
      return false;
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.CreateSeries(symbols[i],timeframes[i]);
   return true;
  }
 //+------------------------------------------------------------------+
 //| V2: the index of the signal of an indicator                       |
 //+------------------------------------------------------------------+
 int CSignalsCollection::FindIndex(CIndicatorDE *indicator)
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CSignal *signal=this.m_list.At(i);
      //if(signal!=NULL && signal.GetIndicator()==indicator)
      if(signal!=NULL && indicator.IsOf(signal.TypeIndicator(),signal.ParamsText(),signal.Symbol(),signal.Timeframe()))   // V5: the key of the entity
         return i;
     }
   return -1;
  }
 //+------------------------------------------------------------------+
 //| V2: the signal of an indicator, or a new one (the rules of V4,    |
 //| Python signals.py; from CSignalSeriesDE::CreateSignal)            |
 //+------------------------------------------------------------------+
 CSignal *CSignalsCollection::GetOrCreateSignal(CIndicatorDE *indicator)
  {
   if(indicator==NULL)
      return NULL;   // the indicator of the template is not made on the pair
   int index=this.FindIndex(indicator);
   if(index>=0)
      return this.m_list.At(index);
   //--- V5: the rule of the type is a judge (UseCases), the signal is the entity (the rows): one of each, at the same index
   CSignalJudge *judge=NULL;
   double level_high=0.0,level_low=0.0;   // V5: the levels of the rule, from the one map that writes them to the table indicators for Python
   if(this.m_IndicatorTemplateManager!=NULL)
      this.m_IndicatorTemplateManager.Read_RAM(indicator.TypeIndicator(),level_high,level_low);
   if(indicator.SourceIndicator()!=NULL && this.m_IndicatorTemplateManager!=NULL && this.m_IndicatorTemplateManager.IsMovingAverage(indicator.TypeIndicator()))
      judge=new CSignalSourceMA();   // New in V5: an average on a source, the source against it (any other type on a source: its own rule below)
   else switch(indicator.TypeIndicator())
     {
      case IND_SAR:        judge=new CSignalSAR();                    break;
      case IND_MA:         judge=new CSignalMA();                     break;
      case IND_AMA:        judge=new CSignalMA();                     break;
      case IND_FRAMA:      judge=new CSignalMA();                     break;
      case IND_DEMA:       judge=new CSignalMA();                     break;
      case IND_TEMA:       judge=new CSignalMA();                     break;
      case IND_VIDYA:      judge=new CSignalMA();                     break;
      case IND_STDDEV:     judge=new CSignalMA();                     break;
      case IND_AD:         judge=new CSignalMA();                     break;
      case IND_BWMFI:      judge=new CSignalMA();                     break;
//      case IND_RSI:        judge=new CSignalOscillator(RSI_OVERBOUGHT,RSI_OVERSOLD);           break;
      case IND_RSI:        judge=new CSignalOscillator(level_high,level_low);           break;
//      case IND_CCI:        judge=new CSignalOscillator(CCI_OVERBOUGHT,CCI_OVERSOLD);           break;
      case IND_CCI:        judge=new CSignalOscillator(level_high,level_low);           break;
//      case IND_DEMARKER:   judge=new CSignalOscillator(DEMARKER_OVERBOUGHT,DEMARKER_OVERSOLD); break;
      case IND_DEMARKER:   judge=new CSignalOscillator(level_high,level_low); break;
//      case IND_WPR:        judge=new CSignalOscillator(WPR_OVERBOUGHT,WPR_OVERSOLD);           break;
      case IND_WPR:        judge=new CSignalOscillator(level_high,level_low);           break;
//      case IND_MFI:        judge=new CSignalOscillator(MFI_OVERBOUGHT,MFI_OVERSOLD);           break;
      case IND_MFI:        judge=new CSignalOscillator(level_high,level_low);           break;
      case IND_AO:         judge=new CSignalZeroCross();              break;
      case IND_AC:         judge=new CSignalZeroCross();              break;
      case IND_FORCE:      judge=new CSignalZeroCross();              break;
      case IND_OSMA:       judge=new CSignalZeroCross();              break;
      case IND_TRIX:       judge=new CSignalZeroCross();              break;
      case IND_CHAIKIN:    judge=new CSignalZeroCross();              break;
      case IND_OBV:        judge=new CSignalZeroCross();              break;
      case IND_BEARS:      judge=new CSignalZeroCross();              break;
      case IND_BULLS:      judge=new CSignalZeroCross();              break;
      case IND_GATOR:      judge=new CSignalZeroCross();              break;
//      case IND_MOMENTUM:   judge=new CSignalZeroCross(MOMENTUM_LEVEL); break;
      case IND_MOMENTUM:   judge=new CSignalZeroCross(level_high); break;
      case IND_MACD:       judge=new CSignalTwoLineCross(0,1);        break;
      case IND_ALLIGATOR:  judge=new CSignalTwoLineCross(0,2);        break;
//      case IND_STOCHASTIC: judge=new CSignalTwoLineCross(0,1,STOCHASTIC_OVERBOUGHT,STOCHASTIC_OVERSOLD); break;
      case IND_STOCHASTIC: judge=new CSignalTwoLineCross(0,1,level_high,level_low); break;
      case IND_RVI:        judge=new CSignalTwoLineCross(0,1);        break;
      case IND_ADX:        judge=new CSignalTwoLineCross(1,2);        break;
      case IND_ADXW:       judge=new CSignalTwoLineCross(1,2);        break;
      case IND_ICHIMOKU:   judge=new CSignalTwoLineCross(0,1);        break;
      case IND_BANDS:      judge=new CSignalBollinger();              break;
      case IND_ENVELOPES:  judge=new CSignalEnvelopes();              break;
      case IND_FRACTALS:   judge=new CSignalFractals();               break;
      case IND_VOLUMES:    judge=new CSignalMA();                     break;   // Change in V5: the slope (as AD); against its average: an MA on VOLUMES
      case IND_ATR:        judge=new CSignalJudge();                       break;   // no direction: never a signal
      default:             return NULL;   // not a standard indicator
     }
   if(judge==NULL)
      return NULL;
   CSignal *signal=new CSignal();
   if(signal==NULL)
     {
      delete judge;
      return NULL;
     }
   //signal.SetIndicator(indicator);   // bound once: 1-1
   //judge.SetIndicator(indicator);
   signal.SetKey(indicator.Symbol(),indicator.Timeframe(),indicator.TypeIndicator(),indicator.ParamsText());   // V5: the entity keeps its key (data)
   judge.SetSource(indicator);   // V5: the one link to the indicator, through the port (bound once: 1-1)
   if(indicator.SourceIndicator()!=NULL)
      judge.SetPriceBuffer(indicator.BuffersTotal()-1);   // New in V5: the input of an indicator on indicator is its last buffer (CIndicatorDE::SetSource), not the close
   if(!this.m_list.Add(signal))
     {
      delete signal;
      delete judge;
      return NULL;
     }
   if(!this.m_list_judge.Add(judge))
     {
      this.m_list.Delete(this.m_list.Total()-1);
      delete judge;
      return NULL;
     }
   return signal;
  }
 void CSignalsCollection::CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_INDICATOR types[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.Read_RAM(types,texts,buy,sell);
   for(int t=0;t<templates;t++)
      this.GetOrCreateSignal(this.m_IndicatorsCollection!=NULL ? this.m_IndicatorsCollection.GetIndicator(types[t],texts[t],symbol,timeframe) : NULL);
  }
 void CSignalsCollection::CreateSeries(const ENUM_INDICATOR type,const string params_text)
  {
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.GetOrCreateSignal(this.m_IndicatorsCollection!=NULL ? this.m_IndicatorsCollection.GetIndicator(type,params_text,symbols[i],timeframes[i]) : NULL);
  }
 void CSignalsCollection::DeleteSeries(const ENUM_INDICATOR type,const string params_text)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CSignal *series=this.m_list.At(i);
      if(series!=NULL && series.TypeIndicator()==type && series.ParamsText()==params_text)
        {
         this.m_list.Delete(i);
         this.m_list_judge.Delete(i);   // V5: its judge, at the same index
        }
     }
  }
 void CSignalsCollection::DeleteSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CSignal *series=this.m_list.At(i);
      if(series!=NULL && series.Symbol()==symbol && series.Timeframe()==timeframe)
        {
         this.m_list.Delete(i);
         this.m_list_judge.Delete(i);   // V5: its judge, at the same index
        }
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the bars of the pairs go to RAM                       |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::ReadDataFromDB(void)
  {
   if(this.m_SymbolTFManager==NULL)
      return false;
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   bool done=true;
   for(int i=0;i<pairs;i++)
      done=this.ReadDataFromDB(symbols[i],timeframes[i]) && done;
   return done;
  }
 bool CSignalsCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return false;
   CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(symbol,timeframe);
   CArrayObj *list_bars=(bars!=NULL ? bars.GetList() : NULL);
   if(list_bars==NULL || list_bars.Total()==0)
      return false;
   int made=0,loaded=0;
   bool done=true;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CSignal *series=this.m_list.At(i);
      if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe)
         continue;
      made++;
      int rows=this.ReadDataFromDB(series,list_bars);   // V5: the controller reads, the entity keeps the rows
      done=(rows>=0 && done);
      loaded+=(rows>0 ? rows : 0);
     }
   ::Print("Complete ",__FUNCTION__," > ",symbol," ",this.m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)timeframe),": ",loaded," rows of SignalsCollection read for the ",made," templates of the pair, on the ",
           list_bars.Total()," bars of the series");
   return done;
  }
 //+------------------------------------------------------------------+
 //| The new bars of the pairs: every symbol, a symbol, every symbol   |
 //| but the chart's (as CBarTimeSeriesCollection::RefreshSeries). A   |
 //| call does BAR_UPDATE_BUDGET_MS of it at most                      |
 //+------------------------------------------------------------------+
 void CSignalsCollection::RefreshSeries(void)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return;
   ulong started=::GetTickCount64();
   CArrayObj *list=this.m_BarTimeSeriesCollection.GetList();
   for(int i=0;i<list.Total();i++)
      if(!this.RefreshTimeseries(list.At(i),started))
         return;   // this call has had its share: the rest is done at the next ones
  }
 //+------------------------------------------------------------------+
 //| New in V5: OnTimer, only the pairs that wait (not ready at their  |
 //| SERIES_EVENTS_NEW_BAR, or Python wrote): a symbol that rests is   |
 //| skipped until it ticks again. Nothing waits: nothing is done      |
 //+------------------------------------------------------------------+
 void CSignalsCollection::RetryPending(void)
  {
   if(this.m_BarTimeSeriesCollection==NULL)
      return;
   ulong started=::GetTickCount64();
   for(int i=this.m_pending.Total()-1;i>=0;i--)
     {
      const string symbol=this.m_pending.Symbol(i);
      CBarTimeSeriesDE *timeseries=this.m_BarTimeSeriesCollection.GetTimeseries(symbol);
      if(timeseries==NULL)
        {
         this.m_pending.Delete(i);   // the pair is gone
         continue;
        }
      if(timeseries.IsPaused())
         continue;   // a closed market: it waits for its ticks
      if(::GetTickCount64()-started>BAR_UPDATE_BUDGET_MS)
         return;     // this beat has had its share
      if(this.JudgePair(symbol,this.m_pending.Timeframe(i),started))
         this.m_pending.Delete(i);
     }
  }
 //+------------------------------------------------------------------+
 //| The new bars of every pair of a symbol: each series of the pair   |
 //| judges itself (RAM only), its events go out                       |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::RefreshTimeseries(CBarTimeSeriesDE *timeseries,const ulong started)
  {
   if(timeseries==NULL || this.m_SyncManager==NULL || this.m_IndicatorsCollection==NULL)
      return true;
   if(!this.m_SyncManager.IsPythonDone())
      return false;   // Python Current writes the pairs of Setting_SymbolTF now: one writer for a pair at a time
   CArrayObj *list=timeseries.GetListSeries();
   for(int i=0;i<list.Total();i++)
     {
      CBarSeriesDE *bars=list.At(i);
      if(bars==NULL)
         continue;
      this.JudgePair(bars.Symbol(),bars.Timeframe(),started);   // not ready: the next call tries again
      if(::GetTickCount64()-started>BAR_UPDATE_BUDGET_MS)
         return false;   // this call has had its share: the rest is done at the next ones
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| New in V5 (the loop of RefreshTimeseries): every signal of the    |
 //| pair judged up to its newest closed bar. False: one is not        |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::JudgePair(const string symbol,const ENUM_TIMEFRAMES timeframe,const ulong started)
  {
   if(this.m_BarTimeSeriesCollection==NULL || this.m_SyncManager==NULL || this.m_IndicatorsCollection==NULL)
      return true;
   if(!this.m_SyncManager.IsPythonDone())
      return false;   // Python Current writes the pairs of Setting_SymbolTF now: one writer for a pair at a time
   CBarSeriesDE *bars=this.m_BarTimeSeriesCollection.GetSeries(symbol,timeframe);
   if(bars==NULL)
      return true;    // the pair is gone
   const datetime last_closed=::iTime(symbol,timeframe,1);
   if(last_closed==0)
      return false;
   bool done=true;
   for(int s=0;s<this.m_list.Total();s++)
     {
      CSignal *series=this.m_list.At(s);
      if(series==NULL || series.Symbol()!=symbol || series.Timeframe()!=timeframe || series.JudgedTo()==last_closed)
         continue;
      if(::GetTickCount64()-started>BAR_UPDATE_BUDGET_MS)
         return false;   // the share of time is over: the rest waits
      this.Calculate(s,bars.GetList());
      if(series.JudgedTo()!=last_closed)
         done=false;     // not ready (MT5 has not calculated the indicator yet): it waits
     }
   return done;
  }
 //+------------------------------------------------------------------+
 //| A pair or a template added or deleted, Python wrote more          |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- New in V5: a new bar of a pair (CBarSeriesDE: dparam = its TF, sparam = its symbol): its signals are judged now, what is not ready waits
   if(id==CHARTEVENT_CUSTOM+SERIES_EVENTS_NEW_BAR)
     {
      if(!this.JudgePair(sparam,(ENUM_TIMEFRAMES)(long)dparam,::GetTickCount64()))
         this.m_pending.Add(sparam,(ENUM_TIMEFRAMES)(long)dparam);
      return true;
     }
   //--- Python wrote the first chunk of every pair (CSyncManager has read its marks already): the series and the rows go to RAM again
   if(id==CHARTEVENT_CUSTOM+PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
     {
      bool done=this.ReadDataFromDB();
      //--- New in V5: the bars closed while Python wrote are judged at the next beats (RetryPending)
      string symbols[];
      ENUM_TIMEFRAMES timeframes[];
      int pairs=(this.m_SymbolTFManager!=NULL ? this.m_SymbolTFManager.Read_RAM(symbols,timeframes) : 0);
      for(int i=0;i<pairs;i++)
         this.m_pending.Add(symbols[i],timeframes[i]);
      return done;
     }
   //--- A pair: lparam = its TF, sparam = its symbol (CBarTimeSeriesCollection made its series already)
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
     {
      this.CreateSeries(sparam,(ENUM_TIMEFRAMES)lparam);   // its rows: Python runs again, then PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE
      return true;
     }
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      this.DeleteSeries(sparam,(ENUM_TIMEFRAMES)lparam);
      return true;
     }
   //--- A template was added: its series are made on every pair (they wait for the progress of Python)
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      this.CreateSeries((ENUM_INDICATOR)lparam,sparam);   // its rows: Python runs again, then PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE
      return true;
     }
   if(id!=CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      return false;
   this.DeleteSeries((ENUM_INDICATOR)lparam,sparam);   // its rows and its marks: the Current worker of Python (CPythonBridge tells it)
   ::Print("Complete ",__FUNCTION__," > the template ",::EnumToString((ENUM_INDICATOR)lparam)," (",sparam,") was deleted: Python deletes its signals");
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows of every series of a pair, from_time to to_time          |
 //+------------------------------------------------------------------+
 int CSignalsCollection::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time)
  {
   if(this.m_SyncManager==NULL || !this.m_SyncManager.IsPythonDone())
      return 0;   // Python writes the pairs now (as CBarControl::ReadDataFromDB): read after PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE
   int loaded=0;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CSignal *series=this.m_list.At(i);
      if(series!=NULL && series.Symbol()==symbol && series.Timeframe()==timeframe)
         loaded+=::MathMax(this.ReadDataFromDB(series,from_time,to_time),0);
     }
   return loaded;
  }
 //+------------------------------------------------------------------+
 //| V5 (moved from CSignal::ReadDataFromDB(list)): the rows of the    |
 //| bars of the list go to the signal                                 |
 //+------------------------------------------------------------------+
 int CSignalsCollection::ReadDataFromDB(CSignal *signal,CArrayObj *list)
  {
   if(signal==NULL || this.m_IndicatorTemplateManager==NULL || list==NULL || list.Total()==0)
      return -1;
   CBar *oldest=list.At(0);
   CBar *newest=list.At(list.Total()-1);
   if(oldest==NULL || newest==NULL)
      return -1;
   signal.DeleteRows(newest.Time()+1);   // every row is read again
   int loaded=this.ReadDataFromDB(signal,oldest.Time(),newest.Time());
   datetime last_update=0;
   signal.SetJudgedTo(this.Progress(signal,last_update) ? last_update : 0);   // judged to where the progress is: the next call judges the bars after it
   return loaded;
  }
 //+------------------------------------------------------------------+
 //| V5 (moved from CSignal::ReadDataFromDB(from,to)): the rows        |
 //| from_time to to_time go to the signal                             |
 //+------------------------------------------------------------------+
 int CSignalsCollection::ReadDataFromDB(CSignal *signal,const datetime from_time,const datetime to_time)
  {
   if(signal==NULL || this.m_IndicatorTemplateManager==NULL)
      return -1;
   long times[],sides[];
   const int total=this.m_IndicatorTemplateManager.ReadDataFromDB(signal.Symbol(),signal.Timeframe(),from_time,to_time,signal.TypeIndicator(),signal.ParamsText(),times,sides);
   if(total==WRONG_VALUE)
      return -1;
   int loaded=0;
   for(int r=0;r<total;r++)
      if(signal.AddRow((datetime)times[r],(ENUM_SIGNAL_DIRECTION)sides[r]))   // a row there already is kept (AddRow refuses the second)
         loaded++;
   return loaded;
  }
 //+------------------------------------------------------------------+
 //| V5 (moved from CSignal::Progress): the newest bar synced of the   |
 //| template on the pair                                              |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::Progress(CSignal *signal,datetime &last_update)
  {
   last_update=0;
   if(signal==NULL || this.m_SyncManager==NULL)
      return false;
   return this.m_SyncManager.Read_RAM(this.m_object_type,(long)signal.TypeIndicator(),signal.ParamsText(),signal.Symbol(),signal.Timeframe(),last_update);   // RAM
  }
 //+------------------------------------------------------------------+
 //| V5 (moved from CSignal::Calculate(list)): the new bars of the     |
 //| list are judged from the progress, the rows set on the signal     |
 //| (RAM only: Python saves), each one told (Working with Event)      |
 //+------------------------------------------------------------------+
// int CSignalsCollection::Calculate(CSignal *signal,CSignalJudge *judge,CArrayObj *list)
//  {
//   if(signal==NULL || judge==NULL || this.m_SyncManager==NULL || list==NULL || list.Total()==0)
//      return -1;
//   if(!this.m_SyncManager.IsPythonDone())
//      return -1;   // Python Current writes the pairs of Setting_SymbolTF now: one writer for a pair at a time
//   const string symbol=signal.Symbol();
//   const ENUM_TIMEFRAMES timeframe=signal.Timeframe();
//   datetime last_closed=::iTime(symbol,timeframe,1);
//   const datetime previous_closed=::iTime(symbol,timeframe,2);   // marked here: one new bar is judged, its rows are new
//   CBar *newest=(list.Total()>1 ? list.At(list.Total()-2) : NULL);
//   if(last_closed==0 || newest==NULL || newest.Time()!=last_closed)
//      return -1;   // the series has not the newest closed bar yet (CBarTimeSeriesCollection refreshes it first)
//   if(signal.JudgedTo()==last_closed)
//      return 0;
//   datetime since=0;
//   if(!this.Progress(signal,since))
//      return -1;   // no row of progress: the history of the start is Python's
//   if(since>=last_closed)
//     {
//      signal.SetJudgedTo(last_closed);
//      return 0;
//     }
//   CBar *oldest=list.At(0);
//   if(oldest==NULL || oldest.Time()>since)
//      return -1;   // what is missing is more than the series holds: Python fills it
//   long row_times[];
//   ENUM_SIGNAL_DIRECTION row_sides[];
//   if(!judge.SetJudge(list,since))
//      return -1;   // the indicator has not the values of the bars in RAM yet
//   judge.Calculate((ENUM_BAR_INFOR_TYPE)WRONG_VALUE,list,since,row_times,row_sides);   // a signal has no type of bar information
//   long told_params[];
//   for(int i=0;i<::ArraySize(row_times);i++)
//      if(signal.AddRow((datetime)row_times[i],row_sides[i]))   // RAM only, Python saves it
//        {
//         int n=::ArraySize(told_params);
//         ::ArrayResize(told_params,n+1);
//         told_params[n]=this.EventPack((datetime)row_times[i],(long)signal.TypeIndicator(),row_sides[i],since==previous_closed);
//        }
//   this.m_SyncManager.Update_Sync_Setting(this.m_object_type,(long)signal.TypeIndicator(),symbol,timeframe,last_closed,this.m_object_type,true,signal.ParamsText());   // the mark stays in RAM
//   signal.SetJudgedTo(last_closed);
//   //--- RAM changed: told (Working with Event), each row by its own event with its bar; sparam: the symbol;the params of the template
//   const string text=symbol+";"+signal.ParamsText();
//   for(int k=0;k<::ArraySize(told_params);k++)
//      this.EventSend((ushort)SERIES_EVENTS_SIGNAL,told_params[k],(double)timeframe,text);
//   return ::ArraySize(row_times);
//  }
 //+------------------------------------------------------------------+
 //| V5: the new bars of the signal at the index, judged by            |
 //| CJudgeControl::JudgeNewBars (the steps shared with the bars)      |
 //+------------------------------------------------------------------+
 int CSignalsCollection::Calculate(const int index,CArrayObj *list)
  {
   CSignal *signal=this.m_list.At(index);
   if(signal==NULL)
      return JUDGE_NOT_JUDGED;
   datetime judged=signal.JudgedTo();
   const string text=signal.Symbol()+";"+signal.ParamsText();   // sparam: the symbol;the params of the template
   const int rows=this.JudgeNewBars(index,this.m_SyncManager,this.m_object_type,(ENUM_BAR_INFOR_TYPE)WRONG_VALUE,(long)signal.TypeIndicator(),signal.ParamsText(),
                                    signal.Symbol(),signal.Timeframe(),list,(ushort)SERIES_EVENTS_SIGNAL,text,judged);   // a signal has no type of bar information
   signal.SetJudgedTo(judged);
   return rows;
  }
 //+------------------------------------------------------------------+
 //| V5: the source of the judge refreshed (MT5) and ready from two    |
 //| bars before the first one after `since`                           |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::Prepare(const int target,CArrayObj *list,const datetime since)
  {
   CSignalJudge *judge=this.m_list_judge.At(target);
   CSource *source=(judge!=NULL ? judge.Source() : NULL);
   if(source==NULL || list==NULL)
      return false;
   source.Refresh();   // the bars up to now, the one that just closed with its last value
   int judged_from=list.Total();
   for(int i=list.Total()-1;i>=0;i--)
     {
      CBar *bar=list.At(i);
      if(bar==NULL || bar.Time()<=since)
         break;
      judged_from=i;
     }
   for(int i=(int)::fmax(0,judged_from-2);i<list.Total();i++)
     {
      CBar *bar=list.At(i);
      if(bar==NULL || !source.IsReady(bar.Time()))
         return false;   // RAM has not this bar yet
     }
   judge.SetJudge(list);
   return true;
  }
 //+------------------------------------------------------------------+
 //| V5: a row found goes to the signal at the index                   |
 //+------------------------------------------------------------------+
 bool CSignalsCollection::StoreRow(const int target,const datetime time,const ENUM_SIGNAL_DIRECTION side)
  {
   CSignal *signal=this.m_list.At(target);
   return (signal!=NULL && signal.AddRow(time,side));
  }
 //+------------------------------------------------------------------+
 //| V5: the signal of a template on a pair, by its key (CPythonBridge)|
 //+------------------------------------------------------------------+
 CSignal *CSignalsCollection::GetSeries(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CSignal *signal=this.m_list.At(i);
      if(signal!=NULL && signal.TypeIndicator()==type && signal.ParamsText()==params_text && signal.Symbol()==symbol && signal.Timeframe()==timeframe)
         return signal;
     }
   return NULL;
  }
#endif // CSIGNALSCOLLECTION_MQH_IMPLEMENTATION
#endif // __SIGNALSCOLLECTION_MQH__
