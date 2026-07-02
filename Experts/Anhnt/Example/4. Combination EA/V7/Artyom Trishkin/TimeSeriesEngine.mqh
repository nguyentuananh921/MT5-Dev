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
      CBarTimeSeriesCollection  m_bar_timeseries;        // BarTimeseries collection
      CIndicatorsCollection     m_indicators_timeseries; //Indicator collection
      CMBookSeriesCollection    m_book_series;           // Collection of DOM series
      //CTickSeriesCollection     m_tick_series;         // Collection of tick series

      CBarPatternsControl       m_pattern_cfg;           // Pattern registry (applied to new TF series)
      SDataCalculate            m_last_data_calc;

      CTimeCounter m_bg_counter;
    //Borrow
      CSymbolsCollection        *m_symbols;               // Symbol collection

    //For indicator

    public:
    //CTimeSeriesEngine Lifecycle
        bool  OnTimerEvent(void);
        bool  OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period);
        bool  OnTickEvent(const string symbol, SDataCalculate &data_calc);
        bool  OnChartEvent(const int id, const long& lparam,
                           const double& dparam, const string& sparam);
    // Gateway
          CBarTimeSeriesCollection    *GetTimeSeriesCollection(void)   { return &this.m_bar_timeseries; }
          void                        SetSymbolsCollection(CSymbolsCollection *symbols)   { m_symbols = symbols; }
          CIndicatorsCollection       *GetIndicatorsCollection()          { return &this.m_indicators_timeseries; }
          CMBookSeriesCollection      *GetBookSeries()                     { return &this.m_book_series; }
          //CTickSeriesCollection       *GetTickSeries()                      { return &this.m_tick_series; }
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
        void IndicatorApplyRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe);
        //void RefreshIndicatorsFromChart(const string symbol);
    // Tang 1: JSON template -> indicator series (EA orchestrates the call from OnInit)
        bool ApplyIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
        int  LoadIndicatorsFromJson(const string filename);
  };
#endif // CTIMESERIESENGINE_MQH_DECLARATION
#ifndef CTIMESERIESENGINE_MQH_IMPLEMENTATION
#define CTIMESERIESENGINE_MQH_IMPLEMENTATION
 //Life cycle management
  bool CTimeSeriesEngine::OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period)
   {
      if(m_symbols == NULL) return false;
      // Guard: only build the collection on the very first init.
      // On REASON_CHARTCHANGE re-init, m_bar_timeseries must retain
      // series created in the previous session (e.g. M1) so that
      // switching TF doesn't wipe out previously tracked timeseries.
       if(this.m_bar_timeseries.GetList().Total() == 0)
          this.m_bar_timeseries.CreateCollection(m_symbols.GetList());
      //  if(this.m_tick_series.DataTotal() == 0)
      //     this.m_tick_series.CreateCollection(m_symbols.GetList());
      // Guard: series already in PureData - nothing to rebuild
       if(this.m_bar_timeseries.IsAvailable(symbol, period))
            return true;
       if(!this.m_bar_timeseries.CreateSeries(symbol, period)) return false;
       // For Tick series - load history only if this symbol hasn't been loaded yet
        //CTickSeries *ts = this.m_tick_series.GetTickseries(symbol);
        //if(ts != NULL && ts.DataTotal() == 0)
              //this.m_tick_series.CreateTickSeries(symbol);
      //For DOM (Book series) - create per-symbol containers once, subscribe current symbol only
        if(this.m_book_series.DataTotal() == 0)
              this.m_book_series.CreateCollection(m_symbols.GetList());
        CSymbol *book_sym = m_symbols.GetSymbolObjByName(symbol);
        if(book_sym != NULL)
              book_sym.BookAdd();
      //For Pattern
        // RegisterAllPatterns();
        // SeriesApplyPatternRegistry(symbol, period);
      //For Indicator - LoadIndicatorsFromJson (called explicitly by EA after this) seeds the
      //very first series; IndicatorApplyRegistry only matters once a template already exists,
      //so it's wired into OnChartEvent's is_new_series branch instead of here.
        // ScanAndApplyIndicators();
        return true;
   }
  bool CTimeSeriesEngine::OnChartEvent(const int id, const long& lparam,
                                const double& dparam, const string& sparam)
   {
    if(id != CHARTEVENT_CHART_CHANGE) return false;
    string sym          = ::Symbol();
    ENUM_TIMEFRAMES curr = (ENUM_TIMEFRAMES)::ChartPeriod(0);

    // Step 1: Ensure series exists
    bool is_new_series = !this.m_bar_timeseries.IsAvailable(sym, curr);
    if(is_new_series)
      {
        this.m_bar_timeseries.CreateSeries(sym, curr);
        // // Step 2: Apply patterns to the newly created series
        //  this.SeriesApplyPatternRegistry(sym, curr);
        // Direction 2: replicate the already-established indicator template (from JSON or
        // earlier symbols/TFs) into this brand new series
        this.IndicatorApplyRegistry(sym, curr);
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
    //this.m_bar_timeseries.Refresh(data_calc);       // ALL symbols, ALL TFs
    this.m_last_data_calc = data_calc;
    this.m_bar_timeseries.Refresh(symbol, data_calc); // Refresh only current chart symbol; CopyRates reads from local cache when synchronized
    this.m_book_series.Refresh(symbol, (long)::TimeCurrent() * 1000); // DOM snapshot for current symbol only
    //this.m_tick_series.Refresh(symbol);
    m_indicators_timeseries.SeriesRefreshBySymbol(symbol);
    return this.m_bar_timeseries.IsEvent();           // true if any TF has a new bar
   }
  bool CTimeSeriesEngine::OnTimerEvent(void)
   {
    if(!this.m_bg_counter.CheckTimeCounter()) return false;

    ulong t0 = ::GetMicrosecondCount();
    this.m_bar_timeseries.RefreshAllExceptCurrent(this.m_last_data_calc);

    ulong t1 = ::GetMicrosecondCount();
    m_indicators_timeseries.SeriesRefreshAllExceptSymbol(::Symbol());
    //this.m_tick_series.RefreshExpectCurrent();

    ulong t2 = ::GetMicrosecondCount();
    if(t2 - t0 > 1000)
       ::Print("PERF CTimeSeriesEngine::OnTimerEvent bars=", t1-t0, "us indicators+ticks=", t2-t1, "us");
    return false;
   }
 //+------------------------------------------------------------------+
 //| Tang 1: bootstrap - apply one indicator type+params to every     |
 //| (symbol, timeframe) series that already exists right now.        |
 //| Properly registers each created indicator via AddIndicatorToList |
 //| (sets buffers_total + actually creates its data series) - the    |
 //| raw CreateIndicator() alone only allocates the handle/object and |
 //| never adds it to m_list, so GetListIndBySymbol() would never see |
 //| it and the object would leak.                                    |
 //+------------------------------------------------------------------+
  bool CTimeSeriesEngine::ApplyIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[])
   {
    int buffers_total = GetIndicatorBuffersTotal(type);
    int mw_total = ::SymbolsTotal(true);
    bool created_any = false;
    for(int i = 0; i < mw_total; i++)
      {
       string sym_name = ::SymbolName(i, true);
       CBarTimeSeriesDE *bts  = m_bar_timeseries.GetTimeseries(sym_name);
       CArrayObj        *list = (bts != NULL) ? bts.GetListSeries() : NULL;
       int tf_cnt = (list != NULL) ? list.Total() : 0;
       if(tf_cnt == 0) continue;
       for(int k = 0; k < tf_cnt; k++)
         {
          CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
          if(s == NULL) continue;
          CIndicatorDE *indicator = m_indicators_timeseries.CreateIndicator(type, params, sym_name, s.Timeframe());
          if(indicator == NULL) continue;
          int handle = m_indicators_timeseries.AddIndicatorToList(indicator, WRONG_VALUE, buffers_total);
          if(handle != INVALID_HANDLE) created_any = true;
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
  int CTimeSeriesEngine::LoadIndicatorsFromJson(const string filename)
   {
      SJsonIndicatorEntry entries[];
      if(!ParseIndicatorConfigFile(filename, entries))
        {
         Print("CTimeSeriesEngine::LoadIndicatorsFromJson > failed to read/parse ", filename);
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
            Print("CTimeSeriesEngine::LoadIndicatorsFromJson > unknown indicator type \"", entries[e].type, "\", skipped");
            continue;
           }

         SIndicatorParam schema[];
         int total = GetIndicatorParamSchema(type, schema);
         if(total == 0)
           {
            Print("CTimeSeriesEngine::LoadIndicatorsFromJson > \"", entries[e].type, "\" has no param schema yet, skipped");
            continue;
           }
         if(ArraySize(entries[e].params) < total)
           {
            Print("CTimeSeriesEngine::LoadIndicatorsFromJson > \"", entries[e].type, "\" needs ", total,
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

         if(ApplyIndicatorToAllSeries(type, params))
            applied++;
        }
      Print("CTimeSeriesEngine::LoadIndicatorsFromJson > applied ", applied, "/", entries_total, " indicator(s) from ", filename);
      return applied;
   }
 //+------------------------------------------------------------------+
 //| Direction 2: PureData -> new Series                              |
 //| When a series (symbol, timeframe) is freshly created, push every |
 //| distinct indicator template already known in PureData into it -  |
 //| independent of what's currently shown on the active chart.       |
 //| The "registry" here is simply the indicator set already recorded |
 //| for one reference (symbol, timeframe) pair, since indicator      |
 //| types are loaded from JSON rather than pre-registered like       |
 //| patterns - same AddIndicatorToList registration as the bootstrap |
 //| above, copying buffers_total from the template instead of a      |
 //| catalog lookup.                                                   |
 //+------------------------------------------------------------------+
  void CTimeSeriesEngine::IndicatorApplyRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      CArrayObj *all = m_indicators_timeseries.GetList();
      if(all == NULL || all.Total() == 0) return; // nothing in PureData yet - LoadIndicatorsFromJson seeds it first

      // Pick the first entry as the reference: guaranteed to be a different (sym, tf)
      // because (symbol, timeframe) is freshly created and has no entries here yet.
      CIndicatorDE *ref_entry = all.At(0);
      if(ref_entry == NULL) return;
      string          ref_sym = ref_entry.Symbol();
      ENUM_TIMEFRAMES ref_tf  = ref_entry.Timeframe();

      // Retrieve the complete indicator set for the reference (sym, tf) - this list IS the template.
      CArrayObj *templates = m_indicators_timeseries.GetListIndBySymbol(ref_sym);
      templates = CTimeseriesSelect::ByIndicatorProperty(templates, INDICATOR_PROP_TIMEFRAME, ref_tf, EQUAL);
      if(templates == NULL || templates.Total() == 0) return;

      // Pre-fetch what already exists for (symbol, timeframe) - belt-and-suspenders guard.
      CArrayObj *existing = m_indicators_timeseries.GetListIndBySymbol(symbol);
      existing = CTimeseriesSelect::ByIndicatorProperty(existing, INDICATOR_PROP_TIMEFRAME, timeframe, EQUAL);

      for(int i = 0; i < templates.Total(); i++)
        {
         CIndicatorDE *tmpl = templates.At(i);
         if(tmpl == NULL) continue;

         string sname = tmpl.ShortName();
         bool exists = false;
         if(existing != NULL)
            for(int k = 0; k < existing.Total(); k++)
              {
               CIndicatorDE *ex = existing.At(k);
               if(ex != NULL && ex.ShortName() == sname) { exists = true; break; }
              }
         if(exists) continue;

         ENUM_INDICATOR ind_type = tmpl.TypeIndicator();
         MqlParam       params[];
         tmpl.GetMqlParams(params);

         CIndicatorDE *new_ind = m_indicators_timeseries.CreateIndicator(ind_type, params, symbol, timeframe);
         if(new_ind == NULL) continue;
         new_ind.SetShortName(sname);
         m_indicators_timeseries.AddIndicatorToList(new_ind, WRONG_VALUE, tmpl.BuffersTotal());
        }
   }
 //For pattern

 // Register all 25 pattern types into engine-level registry (m_pattern_cfg).
 // Must be called once before SeriesApplyPatternRegistry.
    //  void CTimeSeriesEngine::RegisterAllPatterns()
    //    {
    //      MqlParam p[];
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_HAMMER,               p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_HANGING_MAN,          p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_INVERTED_HAMMER,      p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_SHOOTING_STAR,        p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_DOJI,                 p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_DRAGONFLY_DOJI,       p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_GRAVESTONE_DOJI,      p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_HARAMI,               p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_HARAMI_CROSS,         p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_ENGULFING,            p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_TWEEZER,              p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_PIERCING_LINE,        p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_DARK_CLOUD_COVER,     p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_RAILS,                p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_MORNING_STAR,         p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_MORNING_DOJI_STAR,    p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_EVENING_STAR,         p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_EVENING_DOJI_STAR,    p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_THREE_WHITE_SOLDIERS, p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_THREE_BLACK_CROWS,    p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_THREE_STARS,          p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_THREE_INSIDE_UP,      p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_THREE_INSIDE_DOWN,    p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_ABANDONED_BABY,       p, true);
    //      this.m_pattern_cfg.SetUsedPattern(PATTERN_TYPE_PIVOT_POINT_REVERSAL, p, true);
    //    }
    //   // Push engine-level registry to each series-level ctrl, then trigger full scan.
    //   // Populates m_list_all_patterns with CBarPattern objects for all bars.
    //   bool CTimeSeriesEngine::SeriesApplyPatternRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe)
    //    {
    //     CBarTimeSeriesDE *bartimeseries  = this.m_bar_timeseries.GetTimeseries(symbol);
    //     CBarSeriesDE     *barseries = NULL;
    //     if(bartimeseries != NULL)
    //     {
    //         CArrayObj *barserieslist = bartimeseries.GetListSeries();
    //         for(int i = 0; i < barserieslist.Total(); i++)
    //         {
    //             CBarSeriesDE *s = barserieslist.At(i);
    //             if(s != NULL && s.Timeframe() == timeframe)
    //             { barseries = s; break; }
    //         }
    //     }
    //     CBarPatternsControl *ctrl = (barseries  != NULL ? barseries.GetPatternsCtrlObj()     : NULL);
    //     if(ctrl == NULL) return false;
    //     CArrayObj *reg = m_pattern_cfg.GetListControls();
    //     for(int i = 0; i < reg.Total(); i++)
    //       {
    //         CBarPatternControl *c = reg.At(i);
    //         if(c != NULL)
    //           ctrl.SetUsedPattern(c.TypePattern(), c.PatternParams, true);
    //       }
    //     ctrl.RefreshAll();
    //     return true;
    //    }
    //  //For Pattern Refresh
    //   bool CTimeSeriesEngine::SeriesRefreshPatterns(const string symbol, const ENUM_TIMEFRAMES timeframe)
    //    {
    //        CBarTimeSeriesDE *ts = this.m_bar_timeseries.GetTimeseries(symbol);
    //        if(ts == NULL) return false;
    //        CBarSeriesDE *series = ts.GetSeries(timeframe);
    //        if(series == NULL) return false;
    //        CBarPatternsControl *ctrl = series.GetPatternsCtrlObj();
    //        if(ctrl == NULL) return false;
    //        ctrl.RefreshAll();
    //        return true;
    //    }
    //   void CTimeSeriesEngine::SeriesRefreshAllPatterns(void)
    //     {
    //        CArrayObj *list = this.m_bar_timeseries.GetList();
    //        if(list == NULL) return;
    //        for(int i = 0; i < list.Total(); i++)
    //        {
    //        CBarTimeSeriesDE *ts = list.At(i);
    //        if(ts == NULL) continue;
    //        CArrayObj *series_list = ts.GetListSeries();
    //        if(series_list == NULL) continue;
    //        for(int j = 0; j < series_list.Total(); j++)
    //        {
    //               CBarSeriesDE *series = series_list.At(j);
    //               if(series == NULL) continue;
    //               CBarPatternsControl *ctrl = series.GetPatternsCtrlObj();
    //               if(ctrl != NULL) ctrl.RefreshAll();
    //        }
    //        }
    //     }
  // //+------------------------------------------------------------------+
  // //| Scan indicators currently attached to chart_id=0 and replicate   |
  // //| each one (PureData) across every (symbol, timeframe) series that |
  // //| exists in m_bar_timeseries - regardless of which chart is active.|
  // //| Show/Hide on chart is a separate, display-only concern.          |
  // //+------------------------------------------------------------------+
  // void CTimeSeriesEngine::ScanAndApplyIndicators(void)
  //  {
  //     CArrayObj *sym_list = m_symbols.GetList();
  //     if(sym_list == NULL) return;
  //     {
  //        int subwin_count = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
  //        int chart_non_custom_count = 0;
  //        for(int subwin = 0; subwin < subwin_count; subwin++)
  //        {
  //           int inds_in_subwin = ChartIndicatorsTotal(0, subwin);
  //           for(int ind_idx = 0; ind_idx < inds_in_subwin; ind_idx++)
  //           {
  //              string ind_name = ChartIndicatorName(0, subwin, ind_idx);
  //              if(ind_name == "") continue;
  //              int ind_handle = (int)ChartIndicatorGet(0, subwin, ind_name);
  //              if(ind_handle == INVALID_HANDLE) continue;
  //              ENUM_INDICATOR ind_enum_type; MqlParam ind_params[];
  //              if(IndicatorParameters(ind_handle, ind_enum_type, ind_params) > 0 &&
  //                 ind_enum_type != IND_CUSTOM) chart_non_custom_count++;
  //           }
  //        }
  //        if(chart_non_custom_count == 0) return; // no non-custom indicators on chart

  //        int total_series_count = 0;
  //        for(int sym_idx = 0; sym_idx < sym_list.Total(); sym_idx++)
  //        {
  //           CSymbol *sym_item = sym_list.At(sym_idx);
  //           CBarTimeSeriesDE *sym_bts = m_bar_timeseries.GetTimeseries(sym_item != NULL ? sym_item.Name() : "");
  //           if(sym_bts != NULL && sym_bts.GetListSeries() != NULL)
  //              total_series_count += sym_bts.GetListSeries().Total();
  //        }
  //        if(chart_non_custom_count > 0 && total_series_count > 0 &&
  //           m_indicators_timeseries.GetList().Total() == chart_non_custom_count * total_series_count)
  //           return; // all combinations already registered - nothing to do
  //     }
  //     int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
  //     for(int sub = 0; sub < subwindows; sub++)
  //      {
  //        int total = ChartIndicatorsTotal(0, sub);
  //        for(int i = 0; i < total; i++)
  //         {
  //           string name = ChartIndicatorName(0, sub, i);
  //           if(name == "") continue;

  //           int handle = (int)ChartIndicatorGet(0, sub, name);
  //           if(handle == INVALID_HANDLE) continue;

  //           ENUM_INDICATOR ind_type;
  //           MqlParam       params[];
  //           int ip = IndicatorParameters(handle, ind_type, params);
  //           if(ip <= 0)           continue;
  //           if(ind_type == IND_CUSTOM) continue;

  //           for(int s = 0; s < sym_list.Total(); s++)
  //            {
  //              CSymbol *sym_obj = sym_list.At(s);
  //              if(sym_obj == NULL) continue;

  //              CBarTimeSeriesDE *bts = m_bar_timeseries.GetTimeseries(sym_obj.Name());
  //              if(bts == NULL) continue;
  //              CArrayObj *series_list = bts.GetListSeries();
  //              if(series_list == NULL) continue;

  //              CArrayObj *by_sym      = m_indicators_timeseries.GetListIndBySymbol(sym_obj.Name());
  //              CArrayObj *by_sym_type = CTimeseriesSelect::ByIndicatorProperty(by_sym, INDICATOR_PROP_TYPE, ind_type, EQUAL);

  //              for(int j = 0; j < series_list.Total(); j++)
  //               {
  //                 CBarSeriesDE *ser = series_list.At(j);
  //                 if(ser == NULL) continue;
  //                 ENUM_TIMEFRAMES target_tf = ser.Timeframe();

  //                 CArrayObj *candidates = CTimeseriesSelect::ByIndicatorProperty(by_sym_type, INDICATOR_PROP_TIMEFRAME, target_tf, EQUAL);

  //                 bool exists = false;
  //                 if(candidates != NULL)
  //                    for(int k = 0; k < candidates.Total(); k++)
  //                    {
  //                       CIndicatorDE *existing = candidates.At(k);
  //                       if(existing != NULL && existing.ShortName() == name)
  //                          { exists = true; break; }
  //                    }
  //                 if(exists) continue;

  //                 CIndicatorDE *new_ind = m_indicators_timeseries.CreateIndicator(ind_type, params, sym_obj.Name(), target_tf);
  //                 if(new_ind != NULL)
  //                 {
  //                    new_ind.SetShortName(name);
  //                    m_indicators_timeseries.GetList().Add(new_ind);
  //                 }
  //               }
  //            }
  //         }
  //      }
  //     Print("MyDebug CTimeSeriesEngine::ScanAndApplyIndicators END: Total IndicatorDE Objects list.Total()=",
  //           m_indicators_timeseries.GetList().Total());
  //  }

#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
