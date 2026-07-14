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
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\DELib\TimeseriesDELib.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\TimeCounter.mqh>
 // Tang 1 (PureData) indicator metadata + JSON template loader - EA-local, not part of the shared Library  
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
      // Symbols already given ONE BookAdd() attempt this run, success or fail - BookdepthSubscription()
      // alone can't tell "never tried" from "tried and the broker refused" (both read false), so a
      // symbol with no DOM support on this server would retry (and fail) forever on every new TF
      // switch without this - see DOM setup in OnInitEvent.
      string                    m_dom_attempted[];
    //Borrow      
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection
    //For indicator
      int                       LoadIndicatorFromJSON(const string filename);
    //For Signal - freeze bar 1 of any (symbol,TF) that just got a SERIES_EVENTS_NEW_BAR event
    //this refresh cycle, read back from m_BarTimeSeriesCollection's own event list (never call
    //CBarSeriesDE::IsNewBar() directly here - that call is owned/consumed by the bar series itself)
      void                      ProcessNewBarSignalEvents(void);
    public:
    //For Signal - AddIndicatorToList DELETES the passed object when an equal one is already
    //in the collection and silently switches to the canonical instance, so the caller's
    //pointer may be dangling after it returns. Always re-acquire by handle via this helper
    //before handing the indicator to CSignalsCollection.
    //Also the ownership test for chart scans: a chart line whose ChartIndicatorGet slot
    //matches an instance here belongs to Layer 1 - that slot must NEVER be released.
      CIndicatorDE             *GetIndicatorByHandle(const int handle);
    //Temporary debug: dump every indicator instance with its handle - identifies which
    //object owns a handle reported broken by CSeriesDataInd::Refresh (err 4807 hunt)
      void                      PrintIndicatorsInventory(void);       
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
      // DOM setup - ONE BookAdd() attempt per symbol per run, and only for symbols that can
      // actually support it. TicksBookdepth() wraps native SYMBOL_TICKS_BOOKDEPTH, which MT5
      // documents as zero for symbols with no Depth of Market at all (many CFDs, e.g. XAUUSDm
      // on this broker) - skip those entirely instead of calling BookAdd() and logging a
      // failure every time. For symbols that DO support it, BookdepthSubscription() alone
      // still can't gate retries (reads false both for "never tried" and "tried, refused"),
      // so m_dom_attempted tracks "already asked this run" regardless of outcome.
        if(this.m_MBookSeriesCollection.DataTotal() == 0)
          this.m_MBookSeriesCollection.CreateCollection(m_symbol_collection.GetList());
        bool dom_already_attempted = false;
        for(int di = 0; di < ArraySize(m_dom_attempted); di++)
           if(m_dom_attempted[di] == symbol) { dom_already_attempted = true; break; }
        if(!dom_already_attempted)
          {
           CSymbol *book_sym = m_symbol_collection.GetSymbolObjByName(symbol);
           if(book_sym != NULL && book_sym.TicksBookdepth() > 0) book_sym.BookAdd();
           int dom_n = ArraySize(m_dom_attempted);
           ArrayResize(m_dom_attempted, dom_n + 1);
           m_dom_attempted[dom_n] = symbol;
          }
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
  CIndicatorDE *CTimeSeriesEngine::GetIndicatorByHandle(const int handle)
   {
    if(handle == INVALID_HANDLE) return NULL;
    CArrayObj *all = m_IndicatorsCollection.GetList();
    if(all == NULL) return NULL;
    for(int i = all.Total() - 1; i >= 0; i--)
      {
       CIndicatorDE *indicator = all.At(i);
       if(indicator != NULL && indicator.Handle() == handle) return indicator;
      }
    return NULL;
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
          if(handle == INVALID_HANDLE) continue;
          created_any = true;
          // 'indicator' may be dangling here (deleted by AddIndicatorToList on duplicates) -
          // never touch it again; work with the canonical instance re-acquired by handle
          CIndicatorDE *canonical = GetIndicatorByHandle(handle);
          if(canonical != NULL)
             m_SignalsCollection.GetOrCreateSignal(canonical);
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
      SJsonSymbolTF       symbols_tf[];
      if(!ParseIndicatorConfigFile(filename, entries, symbols_tf))
        {
         Print("CTimeSeriesEngine::LoadIndicatorFromJSON > failed to read/parse ", filename);
         return -1;
        }
      // --- Recreate every saved (symbol,TF) series FIRST, so the template loop below
      // --- (AddNewIndicatorToAllSeries, which only reaches series that already exist)
      // --- finds them and populates each one - no more manual re-visit-every-chart.
      int series_created = 0;
      for(int s = 0; s < ArraySize(symbols_tf); s++)
        {
         string sym = symbols_tf[s].symbol;
         ENUM_TIMEFRAMES tf = TimestampByDescription(symbols_tf[s].tf);
         if(sym == "" || this.m_BarTimeSeriesCollection.IsAvailable(sym, tf)) continue;
         if(this.m_BarTimeSeriesCollection.CreateSeries(sym, tf)) series_created++;
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
         bool param_error = false;
         for(int i = 0; i < total; i++)
           {
            params[i].type = schema[i].data_type;
            string raw = entries[e].params[i];
            if(schema[i].choices != "")
              {
               // --- Enum-like param: raw is the choice TEXT (e.g. "EMA") saved by
               // --- SaveIndicatorToJSON - the matching CommonDELib.mqh XxxByDescription()
               // --- resolves it straight to the real MQL5 enum value, dispatched by
               // --- comparing schema[i].choices against the 4 known constants.
               if(schema[i].choices == PRICE_CHOICES)
                  params[i].integer_value = (long)AppliedPriceByDescription(raw);
               else if(schema[i].choices == CALCULATION_METHOD_CHOICES)
                  params[i].integer_value = (long)AveragingMethodByDescription(raw);
               else if(schema[i].choices == VOLUME_CHOICES)
                  params[i].integer_value = (long)AppliedVolumeByDescription(raw);
               else if(schema[i].choices == STOCH_PRICE_CHOICES)
                  params[i].integer_value = (long)StochPriceByDescription(raw);
               else
                  params[i].integer_value = (long)StringToInteger(raw); // back-compat: old files stored a raw number
              }
            else if(schema[i].data_type == TYPE_DOUBLE)
               params[i].double_value = StringToDouble(raw);
            else
               params[i].integer_value = StringToInteger(raw);
           }

         if(AddNewIndicatorToAllSeries(type, params))
            applied++;
        }
      Print("CTimeSeriesEngine::LoadIndicatorFromJSON > applied ", applied, "/", entries_total,
            " indicator(s), recreated ", series_created, "/", ArraySize(symbols_tf), " symbol/TF series from ", filename);
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
         if(add_result == INVALID_HANDLE) { failed_create++; continue; }
         // 'new_ind' may be dangling here (deleted by AddIndicatorToList on duplicates) -
         // never touch it again; work with the canonical instance re-acquired by handle
         CIndicatorDE *canonical = GetIndicatorByHandle(add_result);
         if(canonical != NULL)
            m_SignalsCollection.GetOrCreateSignal(canonical);
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

      // --- "symbols_tf": every (symbol,TF) series that currently exists in Layer 1 -
      // --- so next EA attach can recreate them without the user re-visiting each chart.
      string json = "{\n \"symbols_tf\": [\n";
      int sym_saved = 0;
      CArrayObj *sym_containers = m_BarTimeSeriesCollection.GetList();
      int sym_total = (sym_containers != NULL) ? sym_containers.Total() : 0;
      for(int si = 0; si < sym_total; si++)
        {
         CBarTimeSeriesDE *bts = sym_containers.At(si);
         if(bts == NULL) continue;
         CArrayObj *series_list = bts.GetListSeries();
         int series_total = (series_list != NULL) ? series_list.Total() : 0;
         for(int ti = 0; ti < series_total; ti++)
           {
            CBarSeriesDE *s = series_list.At(ti);
            if(s == NULL) continue;
            if(sym_saved > 0) json += ",\n";
            sym_saved++;
            json += "  { \"symbol\": \"" + s.Symbol() + "\", \"tf\": \"" + TimeframeDescription(s.Timeframe()) + "\" }";
           }
        }
      json += "\n ],\n \"templates\": [\n";

      int saved = 0;
      for(int i = 0; i < templates.Total(); i++)
        {
         CIndicatorDE *ind = templates.At(i);
         if(ind == NULL) continue;
         string cat_name = "";
         for(int c = 0; c < ArraySize(catalog); c++)
            if(catalog[c].type == ind.TypeIndicator()) { cat_name = catalog[c].name; break; }
         if(cat_name == "") continue;

         SIndicatorParam schema[];
         GetIndicatorParamSchema(ind.TypeIndicator(), schema);
         MqlParam params[];
         ind.GetMqlParams(params);
         if(saved > 0) json += ",\n";
         saved++;
         json += "  { \"type\": \"" + cat_name + "\", \"params\": [";
         for(int p = 0; p < ArraySize(params); p++)
           {
            if(p > 0) json += ", ";
            string choices = (p < ArraySize(schema)) ? schema[p].choices : "";
            if(choices != "")
              {
               // --- Enum-like param: write the CHOICE TEXT (e.g. "EMA") via the matching
               // --- CommonDELib.mqh XxxDescription() - stored integer_value is always the
               // --- real MQL5 enum value, so no index/offset math is needed at all.
               if(choices == PRICE_CHOICES)
                  json += "\"" + AppliedPriceDescription((ENUM_APPLIED_PRICE)params[p].integer_value) + "\"";
               else if(choices == CALCULATION_METHOD_CHOICES)
                  json += "\"" + AveragingMethodDescription((ENUM_MA_METHOD)params[p].integer_value) + "\"";
               else if(choices == VOLUME_CHOICES)
                  json += "\"" + AppliedVolumeDescription((ENUM_APPLIED_VOLUME)params[p].integer_value) + "\"";
               else if(choices == STOCH_PRICE_CHOICES)
                  json += "\"" + StochPriceDescription((ENUM_STO_PRICE)params[p].integer_value) + "\"";
              }
            else if(params[p].type == TYPE_DOUBLE)
               json += DoubleToString(params[p].double_value, 8);
            else
               json += IntegerToString((int)params[p].integer_value);
           }
         json += "] }";
        }
      json += "\n ]\n}";
      int fh = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(fh == INVALID_HANDLE)
        {
         Print("CTimeSeriesEngine::SaveIndicatorToJSON > cannot open ", filename, " for writing, err=", GetLastError());
         return false;
        }
      FileWriteString(fh, json);
      FileClose(fh);
      Print("CTimeSeriesEngine::SaveIndicatorToJSON > saved ", saved, " indicator(s), ", sym_saved, " symbol/TF series to ", filename);
      return true;
   } 
 //Temporary debug: dump every indicator instance with its handle - identifies which
 //object owns a handle reported broken by CSeriesDataInd::Refresh (err 4807 hunt)
 void CTimeSeriesEngine::PrintIndicatorsInventory(void)
    {
      CArrayObj *all = m_IndicatorsCollection.GetList();
      if(all == NULL) return;
      ::Print("=== Indicators inventory: ", all.Total(), " instance(s) ===");
      for(int i = 0; i < all.Total(); i++)
        {
        CIndicatorDE *indicator = all.At(i);
        if(indicator == NULL) continue;
        ::Print("INV[", i, "] handle=", indicator.Handle(), " ", indicator.Symbol(), " ",
                TimeframeDescription(indicator.Timeframe()), " ", indicator.ShortName());
        }
    }
#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
