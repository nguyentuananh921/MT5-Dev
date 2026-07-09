//+------------------------------------------------------------------+
//|                                           TimeSeriesEngine.mqh   |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//| Lib https://www.mql5.com/en/articles/14710                       |
//| Extracted from CEngine - bar/timeseries methods only.            |
//| Pure data facade over CBarTimeSeriesCollection.                  |
//+------------------------------------------------------------------+

#ifndef CTIMESERIESENGINE_MQH
#define CTIMESERIESENGINE_MQH
 //+------------------------------------------------------------------+
 //| Include Custom files                                                    |
 //+------------------------------------------------------------------+
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SymbolsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BookSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\TickSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SignalsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\TimeCounter.mqh>
 // Tang 1 (PureData) indicator metadata + JSON template loader - EA-local, not part of the shared Library
  #include "IndicatorCatalog.mqh"
  #include "IndicatorConfigLoader.mqh"
#ifndef CTIMESERIESENGINE_MQH_DECLARATION
#define CTIMESERIESENGINE_MQH_DECLARATION
 class CTimeSeriesEngine
  {
    private:
     //Owns
      CBarTimeSeriesCollection  m_BarTimeSeriesCollection;        // BarTimeseries collection
      CIndicatorsCollection     m_IndicatorsCollection;           //Indicator collection
      CMBookSeriesCollection    m_MBookSeriesCollection;          // Collection of DOM series
      //CTickSeriesCollection     m_tick_series;         // Collection of tick series
      CSignalsCollection        m_SignalsCollection;     // 1-1 CIndicatorDE<->CSignalXXX linkage (EA-local)
      CBarPatternsControl       m_pattern_cfg;           // Pattern registry (applied to new TF series)
      SDataCalculate            m_last_data_calc;
      CTimeCounter              m_bg_counter;
    //Borrow      
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection
    //For indicator
      int                       LoadIndicatorFromJSON(const string filename);
    //For Signal - freeze bar 1 of any (symbol,TF) that just got a SERIES_EVENTS_NEW_BAR event
    //this refresh cycle, read back from m_BarTimeSeriesCollection's own event list (never call
    //CBarSeriesDE::IsNewBar() directly here - that call is owned/consumed by the bar series itself)
      void                      ProcessNewBarSignalEvents(void);
    public:
    //CTimeSeriesEngine Lifecycle
        bool  OnTimerEvent(void);
        bool  OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period);
        bool  OnTickEvent(const string symbol, SDataCalculate &data_calc);
        bool  OnChartEvent(const int id, const long& lparam,
                           const double& dparam, const string& sparam);
    // Gateway
          CBarTimeSeriesCollection    *GetTimeSeriesCollection(void)                      { return &this.m_BarTimeSeriesCollection; }
          void                        SetSymbolsCollection(CSymbolsCollection *symbols)   { m_symbol_collection = symbols; }
          CIndicatorsCollection       *GetIndicatorsCollection()                          { return &this.m_IndicatorsCollection; }
          CMBookSeriesCollection      *GetBookSeries()                                    { return &this.m_MBookSeriesCollection; }
          CSignalsCollection          *GetSignalsCollection()                              { return &this.m_SignalsCollection; }
          //CTickSeriesCollection       *GetTickSeries()                                    { return &this.m_tick_series; }
    // Tang 1: JSON template <-> indicator series
        void                        AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe);
        bool                        AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
        bool                        SaveIndicatorToJSON(const string filename);
    // Pattern
        // void  RegisterAllPatterns(void);
        // void  RegisterPattern(const ENUM_PATTERN_TYPE type, MqlParam &param[])
        //                       { this.m_pattern_cfg.SetUsedPattern(type, param, true); }
        // bool  SeriesApplyPatternRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe);
        // bool  SeriesRefreshPatterns(const string symbol, const ENUM_TIMEFRAMES timeframe);
        // void  SeriesRefreshAllPatterns(void);
    // Indicator methods (parallel voi Pattern methods)
        //void ScanAndApplyIndicators(const string symbol, const ENUM_TIMEFRAMES tf);
        //void ScanAndApplyIndicators(void);
        
        //void RefreshIndicatorsFromChart(const string symbol);
    
  };
#endif // CTIMESERIESENGINE_MQH_DECLARATION
#ifndef CTIMESERIESENGINE_MQH_IMPLEMENTATION
#define CTIMESERIESENGINE_MQH_IMPLEMENTATION
 //Life cycle management
  bool CTimeSeriesEngine::OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period)
   {
      if(m_symbol_collection == NULL) return false;
      // Step 1: build collection (first init only)
       if(this.m_BarTimeSeriesCollection.GetList().Total() == 0)
         this.m_BarTimeSeriesCollection.CreateCollection(m_symbol_collection.GetList());
      // Step 2: guard — series already exists (CHARTCHANGE same TF)
       bool already_available = this.m_BarTimeSeriesCollection.IsAvailable(symbol, period);
       if(already_available)
           return true;
      // Step 3: create the current chart's series
       bool created = this.m_BarTimeSeriesCollection.CreateSeries(symbol, period);
       if(!created) return false;
      // DOM setup
        if(this.m_MBookSeriesCollection.DataTotal() == 0)
          this.m_MBookSeriesCollection.CreateCollection(m_symbol_collection.GetList());
        CSymbol *book_sym = m_symbol_collection.GetSymbolObjByName(symbol);
        if(book_sym != NULL) book_sym.BookAdd();
      // Step 4: load indicators — AFTER CreateSeries, so series exists for Apply to find
      // Guard: only on first startup (no indicators yet). Skip on CHARTCHANGE re-init.
        CArrayObj * ind_list = m_IndicatorsCollection.GetList();
        int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
        if(ind_total == 0)
          LoadIndicatorFromJSON("indicators_config.json");                   
        else
          AddAllIndicatorsToNewSeries(symbol, period);      // subsequent new series via CHARTCHANGE   
        return true;
        
      //For Pattern
        // RegisterAllPatterns();
        // SeriesApplyPatternRegistry(symbol, period);
      //For Indicator - LoadIndicatorFromJSON already called in the Total()==0 block above.
      //AddAllIndicatorsToNewSeries wired into OnChartEvent's is_new_series branch.
        // ScanAndApplyIndicators();
   }
  bool CTimeSeriesEngine::OnChartEvent(const int id, const long& lparam,
                                const double& dparam, const string& sparam)
   {
    if(id != CHARTEVENT_CHART_CHANGE) return false;
    string sym          = ::Symbol();
    ENUM_TIMEFRAMES curr = (ENUM_TIMEFRAMES)::ChartPeriod(0);

    // Step 1: Ensure series exists
    bool is_new_series = !this.m_BarTimeSeriesCollection.IsAvailable(sym, curr);
    if(is_new_series)
      {
        this.m_BarTimeSeriesCollection.CreateSeries(sym, curr);
        // // Step 2: Apply patterns to the newly created series
        //  this.SeriesApplyPatternRegistry(sym, curr);
        // Direction 2: replicate the already-established indicator template (from JSON or
        // earlier symbols/TFs) into this brand new series
        this.AddAllIndicatorsToNewSeries(sym, curr);
      }
    else
     {
      //this.ScanAndApplyIndicators();// Direction 1: detect newly-added indicator types on chart
     }
    // Case 2: old series - patterns already in m_list_all_patterns, skip rescan
    return is_new_series;
   }
  bool CTimeSeriesEngine::OnTickEvent(const string symbol, SDataCalculate &data_calc)
   {
    //this.m_BarTimeSeriesCollection.Refresh(data_calc);       // ALL symbols, ALL TFs
     this.m_last_data_calc = data_calc;
     this.m_BarTimeSeriesCollection.Refresh(symbol, data_calc); // Refresh only current chart symbol; CopyRates reads from local cache when synchronized
     this.m_MBookSeriesCollection.Refresh(symbol, (long)::TimeCurrent() * 1000); // DOM snapshot for current symbol only
    //this.m_tick_series.Refresh(symbol);
     m_IndicatorsCollection.SeriesRefreshBySymbol(symbol);
     m_SignalsCollection.RefreshCurrentBar(symbol); // current chart symbol only - stays live every tick, not just every timer tick
     ProcessNewBarSignalEvents(); // freeze bar 1 for any (symbol,TF) whose bar just closed this tick
     return this.m_BarTimeSeriesCollection.IsEvent();           // true if any TF has a new bar
   }
  void CTimeSeriesEngine::ProcessNewBarSignalEvents(void)
   {
    CArrayObj *events = m_BarTimeSeriesCollection.GetListEvents();
    if(events == NULL) return;
    int total = events.Total();
    for(int i = 0; i < total; i++)
      {
       CEventBaseObj *ev = events.At(i);
       if(ev == NULL || ev.ID() != SERIES_EVENTS_NEW_BAR) continue;
       m_SignalsCollection.FreezeClosedBar(ev.SParam(), (ENUM_TIMEFRAMES)(int)ev.DParam());
      }
   }
  bool CTimeSeriesEngine::OnTimerEvent(void)
   {
    m_SignalsCollection.RefreshCurrentBar(); // recompute bar 0 for every tracked signal - "current direction" must never be stale

    if(!this.m_bg_counter.CheckTimeCounter()) return false;

    ulong t0 = ::GetMicrosecondCount();
    this.m_BarTimeSeriesCollection.RefreshAllExceptCurrent(this.m_last_data_calc);
    ProcessNewBarSignalEvents(); // freeze bar 1 for any (symbol,TF), other than the chart's own, whose bar just closed

    ulong t1 = ::GetMicrosecondCount();
    m_IndicatorsCollection.SeriesRefreshAllExceptSymbol(::Symbol());
    //this.m_tick_series.RefreshExpectCurrent();

    ulong t2 = ::GetMicrosecondCount();
    // if(t2 - t0 > 1000)
    //    ::Print("PERF CTimeSeriesEngine::OnTimerEvent bars=", t1-t0, "us indicators+ticks=", t2-t1, "us");
    return false;
   }
 //+------------------------------------------------------------------+
 //| Tang 1: apply one indicator type+params to every (symbol,        |
 //| timeframe) series that already exists right now. Called when     |
 //| user adds a new indicator via GUI (Layer 2 -> Layer 1 bridge).   |
 //| Properly registers each created indicator via AddIndicatorToList |
 //| (sets buffers_total + actually creates its data series) - the    |
 //| raw CreateIndicator() alone only allocates the handle/object and |
 //| never adds it to m_list, so GetListIndBySymbol() would never see |
 //| it and the object would leak.                                    |
 //+------------------------------------------------------------------+
  bool CTimeSeriesEngine::AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[])
   {
    int buffers_total = GetIndicatorBuffersTotal(type);
    int mw_total = ::SymbolsTotal(true);
    bool created_any = false;
    for(int i = 0; i < mw_total; i++)
      {
       string sym_name = ::SymbolName(i, true);
       CBarTimeSeriesDE *bts  = m_BarTimeSeriesCollection.GetTimeseries(sym_name);
       CArrayObj        *list = (bts != NULL) ? bts.GetListSeries() : NULL;
       int tf_cnt = (list != NULL) ? list.Total() : 0;
       if(tf_cnt == 0) continue;
       for(int k = 0; k < tf_cnt; k++)
         {
          CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
          if(s == NULL) continue;
          // Source symbol from the CBarSeriesDE object itself (reliable, never observed to
          // drift) rather than sym_name (the loop variable from ::SymbolName()) - CIndicatorDE's
          // own Symbol() has been observed to silently drift when fed a string traced back to
          // a raw ::Symbol()/::SymbolName() call chain instead of a stable object's accessor.
          CIndicatorDE *indicator = m_IndicatorsCollection.CreateIndicator(type, params, s.Symbol(), s.Timeframe());
          if(indicator == NULL) continue;
          int handle = m_IndicatorsCollection.AddIndicatorToList(indicator, WRONG_VALUE, buffers_total);
          if(handle != INVALID_HANDLE) { created_any = true; m_SignalsCollection.GetOrCreateSignal(indicator); }
         }
      }
    return created_any;
   }
 //+------------------------------------------------------------------+
 //| Tang 1: load the JSON indicator template and apply each entry to |
 //| every (symbol, timeframe) series that already exists. Called     |
 //| explicitly by the EA's OnInit - the EA orchestrates when/whether  |
 //| to (re)load, this engine only knows how to do it.                 |
 //+------------------------------------------------------------------+
  int CTimeSeriesEngine::LoadIndicatorFromJSON(const string filename)
   {
      SJsonIndicatorEntry entries[];
      if(!ParseIndicatorConfigFile(filename, entries))
        {
         Print("CTimeSeriesEngine::LoadIndicatorFromJSON > failed to read/parse ", filename);
         return -1;
        }
      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);

      int applied = 0;
      int entries_total = ArraySize(entries);
      for(int e = 0; e < entries_total; e++)
        {
         bool type_found = false;
         ENUM_INDICATOR type = IND_CUSTOM;
         for(int c = 0; c < ArraySize(catalog); c++)
           {
            if(catalog[c].name == entries[e].type)
              {
               type = catalog[c].type;
               type_found = true;
               break;
              }
           }
         if(!type_found)
           {
            Print("CTimeSeriesEngine::LoadIndicatorFromJSON > unknown indicator type \"", entries[e].type, "\", skipped");
            continue;
           }

         SIndicatorParam schema[];
         int total = GetIndicatorParamSchema(type, schema);
         if(total == 0)
           {
            Print("CTimeSeriesEngine::LoadIndicatorFromJSON > \"", entries[e].type, "\" has no param schema yet, skipped");
            continue;
           }
         if(ArraySize(entries[e].params) < total)
           {
            Print("CTimeSeriesEngine::LoadIndicatorFromJSON > \"", entries[e].type, "\" needs ", total,
                  " params, got ", ArraySize(entries[e].params), ", skipped");
            continue;
           }

         MqlParam params[];
         ArrayResize(params, total);
         for(int i = 0; i < total; i++)
           {
            params[i].type = schema[i].data_type;
            if(schema[i].data_type == TYPE_DOUBLE)
               params[i].double_value = entries[e].params[i];
            else
               params[i].integer_value = (long)entries[e].params[i];
           }

         if(AddNewIndicatorToAllSeries(type, params))
            applied++;
        }
      Print("CTimeSeriesEngine::LoadIndicatorFromJSON > applied ", applied, "/", entries_total, " indicator(s) from ", filename);
      return applied;
   }
 //+------------------------------------------------------------------+
 //| Tang 1: new Series created -> copy ALL indicators from template. |
 //| When a (symbol, timeframe) series is freshly created, push every |
 //| indicator from the current live template (= JSON-loaded set +    |
 //| any runtime additions) into it.                                  |
 //| Uses all.At(0) as reference: invariant = all (sym,tf) pairs have |
 //| the same indicator set (template), so any entry is representative.|
 //+------------------------------------------------------------------+
  void CTimeSeriesEngine::AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      // Source symbol/timeframe from the CBarSeriesDE object itself (m_BarTimeSeriesCollection),
      // not from the symbol/timeframe parameters (which trace back to a raw ::Symbol()/
      // ::Period() call chain in OnInit/OnChartEvent). CBarSeriesDE::Symbol() has never been
      // observed to drift; CIndicatorDE::Symbol() has, whenever it was fed a string sourced
      // from that raw call chain instead of a stable object's own accessor.
       CBarSeriesDE *target_series = m_BarTimeSeriesCollection.GetSeries(symbol, timeframe);
       if(target_series == NULL) return;
       string safe_symbol = target_series.Symbol();
      CArrayObj *all = m_IndicatorsCollection.GetList();
      if(all == NULL || all.Total() == 0)
         return; // nothing in PureData yet - LoadIndicatorsFromJson seeds it first

      // Pick the first entry as the reference: guaranteed to be a different (sym, tf)
      // because (symbol, timeframe) is freshly created and has no entries here yet.
       CIndicatorDE *ref_entry = all.At(0);
       if(ref_entry == NULL) return;
       string          ref_sym = ref_entry.Symbol();
       ENUM_TIMEFRAMES ref_tf  = ref_entry.Timeframe();

      // Retrieve the complete indicator set for the reference (sym, tf) - this list IS the template.
       CArrayObj *templates = m_IndicatorsCollection.GetListIndBySymbol(ref_sym);
       templates = CTimeseriesSelect::ByIndicatorProperty(templates, INDICATOR_PROP_TIMEFRAME, ref_tf, EQUAL);
       if(templates == NULL || templates.Total() == 0) return;

      // NOTE: no "does it already exist" guard here on purpose. The caller (OnInitEvent /
      // OnChartEvent) only reaches this function after confirming via m_BarTimeSeriesCollection.IsAvailable()
      // that (symbol, timeframe) is brand new, so every template entry below is guaranteed absent.
      // (A prior "belt-and-suspenders" existing-check used to live here, filtering by Symbol() -
      // it was removed because Symbol() was observed to read back the wrong value for previously
      // created indicators under investigation, which made the guard skip real creations.)

       int created_count = 0, failed_create = 0;
       for(int i = 0; i < templates.Total(); i++)
        {
          CIndicatorDE *tmpl = templates.At(i);
          if(tmpl == NULL) continue;

          ENUM_INDICATOR ind_type = tmpl.TypeIndicator();
          MqlParam       params[];
          tmpl.GetMqlParams(params);

         CIndicatorDE * new_ind = m_IndicatorsCollection.CreateIndicator(ind_type, params, safe_symbol, target_series.Timeframe());
         if(new_ind == NULL) { failed_create++; continue; }
         int add_result = m_IndicatorsCollection.AddIndicatorToList(new_ind, WRONG_VALUE, tmpl.BuffersTotal());
         if(add_result != INVALID_HANDLE) m_SignalsCollection.GetOrCreateSignal(new_ind);
         created_count++;
        }
   }
 //+------------------------------------------------------------------+
 //| Tang 1: save current live indicator template to JSON file.       |
 //| Reads from m_IndicatorsCollection (Layer 1 data) using the same |
 //| reference trick as AddAllIndicatorsToNewSeries: all (sym,tf)     |
 //| pairs have identical indicator sets, so all.At(0) is the source. |
 //| Called by Layer 2 (GUIPannel) when user clicks Save button.      |
 //+------------------------------------------------------------------+
  bool CTimeSeriesEngine::SaveIndicatorToJSON(const string filename)
   {
      CArrayObj *all = m_IndicatorsCollection.GetList();
      if(all == NULL || all.Total() == 0)
        {
         Print("CTimeSeriesEngine::SaveIndicatorToJSON > no indicators in collection");
         return false;
        }
      CIndicatorDE *ref_entry = all.At(0);
      if(ref_entry == NULL) return false;
      string          ref_sym = ref_entry.Symbol();
      ENUM_TIMEFRAMES ref_tf  = ref_entry.Timeframe();
      CArrayObj *templates = m_IndicatorsCollection.GetListIndBySymbol(ref_sym);
      templates = CTimeseriesSelect::ByIndicatorProperty(templates, INDICATOR_PROP_TIMEFRAME, ref_tf, EQUAL);
      if(templates == NULL || templates.Total() == 0) return false;
      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);
      string json = "[\n";
      int saved = 0;
      for(int i = 0; i < templates.Total(); i++)
        {
         CIndicatorDE *ind = templates.At(i);
         if(ind == NULL) continue;
         string cat_name = "";
         for(int c = 0; c < ArraySize(catalog); c++)
            if(catalog[c].type == ind.TypeIndicator()) { cat_name = catalog[c].name; break; }
         if(cat_name == "") continue;
         MqlParam params[];
         ind.GetMqlParams(params);
         if(saved > 0) json += ",\n";
         saved++;
         json += "  { \"type\": \"" + cat_name + "\", \"params\": [";
         for(int p = 0; p < ArraySize(params); p++)
           {
            if(p > 0) json += ", ";
            if(params[p].type == TYPE_DOUBLE)
               json += DoubleToString(params[p].double_value, 8);
            else
               json += IntegerToString((int)params[p].integer_value);
           }
         json += "] }";
        }
      json += "\n]";
      int fh = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(fh == INVALID_HANDLE)
        {
         Print("CTimeSeriesEngine::SaveIndicatorToJSON > cannot open ", filename, " for writing, err=", GetLastError());
         return false;
        }
      FileWriteString(fh, json);
      FileClose(fh);
      Print("CTimeSeriesEngine::SaveIndicatorToJSON > saved ", saved, " indicator(s) to ", filename);
      return true;
   } 
#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
