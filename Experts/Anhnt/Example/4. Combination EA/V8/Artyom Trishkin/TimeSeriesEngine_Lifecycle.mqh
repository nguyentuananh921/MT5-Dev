//+------------------------------------------------------------------+
//|                                   TimeSeriesEngine_Lifecycle.mqh |
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_LIFECYCLE_MQH
#define CTIMESERIESENGINE_LIFECYCLE_MQH
 //Life cycle management
 bool CTimeSeriesEngine::OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period)
  {
    if(m_symbol_collection == NULL) return false;
   // Step 1: build collection (first init only)
     if(this.m_BarTimeSeriesCollection.GetList().Total() == 0)
        this.m_BarTimeSeriesCollection.CreateCollection(m_symbol_collection.GetList());      
    // // For Candle Pattern Initialize pattern control      
    //   this.m_BarPatterns_Control.SetCollections(
    //     this.m_BarTimeSeriesCollection.GetList(),
    //     this.m_empty_patterns  
    //   );
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
   //For Candle Pattern
    RegisterAllCandlePatterns();
    SeriesApplyPatternRegistry(symbol, period);
   // Step 4: load indicators — AFTER CreateSeries, so series exists for Apply to find
   // Guard: only on first startup (no indicators yet). Skip on CHARTCHANGE re-init.
    CArrayObj * ind_list = m_IndicatorsCollection.GetList();
    int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
    if(ind_total == 0)
        LoadConfigurationFromJSON("Config_Setting.json");
    else
        AddAllIndicatorsToNewSeries(symbol, period);      // subsequent new series via CHARTCHANGE
    return true;
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
        // Step 2: Apply the full Candle Pattern registry to the newly created series
        // (Anhnt, 2026-08-10: was commented out - new TFs switched to on the chart never
        // got pattern detection wired, same bug as the JSON-load path).
        this.SeriesApplyPatternRegistry(sym, curr);
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
#endif // CTIMESERIESENGINE_LIFECYCLE_MQH
