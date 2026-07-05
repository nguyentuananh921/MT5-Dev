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
      CBarTimeSeriesCollection  m_BarTimeSeriesCollection;        // BarTimeseries collection
      CIndicatorsCollection     m_IndicatorsCollection; //Indicator collection
      CMBookSeriesCollection    m_MBookSeriesCollection;           // Collection of DOM series
      //CTickSeriesCollection     m_tick_series;         // Collection of tick series
      CBarPatternsControl       m_pattern_cfg;           // Pattern registry (applied to new TF series)
      SDataCalculate            m_last_data_calc;
      CTimeCounter              m_bg_counter;
    //Borrow      
      CSymbolsCollection        *m_symbol_collection;               // Symbol collection
    //For indicator
      int                       LoadIndicatorFromJSON(const string filename);
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
      Print("My Debug CTimeSeriesEngine::OnInitEvent ENTER symbol=", symbol, " period=", EnumToString(period));
      if(m_symbol_collection == NULL) return false;
      // Step 1: build collection (first init only)
       if(this.m_BarTimeSeriesCollection.GetList().Total() == 0)
         this.m_BarTimeSeriesCollection.CreateCollection(m_symbol_collection.GetList());
      // Step 2: guard — series already exists (CHARTCHANGE same TF)
       bool already_available = this.m_BarTimeSeriesCollection.IsAvailable(symbol, period);
       Print("My Debug CTimeSeriesEngine::OnInitEvent IsAvailable(", symbol, ",", EnumToString(period), ")=", already_available);
       if(already_available)
           return true;
      // Step 3: create the current chart's series
       bool created = this.m_BarTimeSeriesCollection.CreateSeries(symbol, period);
       Print("My Debug CTimeSeriesEngine::OnInitEvent CreateSeries=", created);
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
        //Debug  
         Print("My Debug CTimeSeriesEngine::OnInitEvent ind_list.Total()=", ind_total,
              " branch=", (ind_total == 0 ? "LoadIndicatorFromJSON" : "AddAllIndicatorsToNewSeries"));     
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
    Print("My Debug CTimeSeriesEngine::OnChartEvent CHARTEVENT_CHART_CHANGE BEGIN sym=", sym,
          " tf=", EnumToString(curr), " is_new_series=", is_new_series);
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
     return this.m_BarTimeSeriesCollection.IsEvent();           // true if any TF has a new bar
   }
  bool CTimeSeriesEngine::OnTimerEvent(void)
   {
    // SENSOR: detect any silent mutation of indicator Symbol property outside the known creation path.
     static string last_seen[10];
     static bool   sensor_init = false;
     CArrayObj *sensor_list = m_IndicatorsCollection.GetList();
     if(sensor_list != NULL)
      {
       int sensor_total = sensor_list.Total();
       if(!sensor_init) { for(int fi = 0; fi < 10; fi++) last_seen[fi] = ""; sensor_init = true; }
       for(int si = 0; si < sensor_total && si < 10; si++)
        {
         CIndicatorDE *sdbg = sensor_list.At(si);
         if(sdbg == NULL) continue;
         string cur_sym = sdbg.Symbol();
         if(last_seen[si] != "" && last_seen[si] != cur_sym)
           Print("My Debug SENSOR: all[", si, "] Symbol changed from '", last_seen[si], "' to '", cur_sym,
                 "' Handle=", sdbg.Handle(), " at OnTimerEvent, current chart Symbol()=", ::Symbol());
         last_seen[si] = cur_sym;
        }
      }

    if(!this.m_bg_counter.CheckTimeCounter()) return false;

    ulong t0 = ::GetMicrosecondCount();
    this.m_BarTimeSeriesCollection.RefreshAllExceptCurrent(this.m_last_data_calc);

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
       if(target_series == NULL)
        {
         Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries EXIT - no CBarSeriesDE for symbol=", symbol, " timeframe=", EnumToString(timeframe));
         return;
        }
       string safe_symbol = target_series.Symbol();
      Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries ENTER symbol=", safe_symbol, " timeframe=", EnumToString(timeframe));
      CArrayObj *all = m_IndicatorsCollection.GetList();
      if(all == NULL || all.Total() == 0)
       {
         Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries EXIT - m_IndicatorsCollection empty");
         return; // nothing in PureData yet - LoadIndicatorsFromJson seeds it first
       }
      Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries FULL DUMP all.Total()=", all.Total());
      for(int dd = 0; dd < all.Total(); dd++)
       {
        CIndicatorDE *dbg = all.At(dd);
        if(dbg == NULL) { Print("My Debug   all[", dd, "] = NULL"); continue; }
        Print("My Debug   all[", dd, "] Symbol=", dbg.Symbol(), " Timeframe=", EnumToString(dbg.Timeframe()),
              " ShortName=", dbg.ShortName(), " TypeIndicator=", EnumToString(dbg.TypeIndicator()),
              " Handle=", dbg.Handle());
       }
      // Pick the first entry as the reference: guaranteed to be a different (sym, tf)
      // because (symbol, timeframe) is freshly created and has no entries here yet.
       CIndicatorDE *ref_entry = all.At(0);
       if(ref_entry == NULL) return;
       string          ref_sym = ref_entry.Symbol();
       ENUM_TIMEFRAMES ref_tf  = ref_entry.Timeframe();
       Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries ref_sym=", ref_sym, " ref_tf=", EnumToString(ref_tf));

      // Retrieve the complete indicator set for the reference (sym, tf) - this list IS the template.
       CArrayObj *templates = m_IndicatorsCollection.GetListIndBySymbol(ref_sym);
       templates = CTimeseriesSelect::ByIndicatorProperty(templates, INDICATOR_PROP_TIMEFRAME, ref_tf, EQUAL);
       int templates_total = (templates != NULL) ? templates.Total() : 0;
       Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries templates.Total()=", templates_total);
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

         Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries about to CreateIndicator with symbol param=", safe_symbol, " (fn arg) type=", EnumToString(ind_type));
         CIndicatorDE * new_ind = m_IndicatorsCollection.CreateIndicator(ind_type, params, safe_symbol, target_series.Timeframe());
         if(new_ind == NULL) { failed_create++; continue; }
         Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries right after CreateIndicator: new_ind.Symbol()=", new_ind.Symbol(),
               " new_ind.ShortName()=", new_ind.ShortName(), " new_ind.Timeframe()=", EnumToString(new_ind.Timeframe()),
               " Handle=", new_ind.Handle());
         int add_result = m_IndicatorsCollection.AddIndicatorToList(new_ind, WRONG_VALUE, tmpl.BuffersTotal());
         Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries after AddIndicatorToList: new_ind.Symbol()=", new_ind.Symbol(),
               " handle=", add_result);
         created_count++;
        }
      Print("My Debug CTimeSeriesEngine::AddAllIndicatorsToNewSeries EXIT symbol=", symbol,
            " timeframe=", EnumToString(timeframe), " created=", created_count,
            " failed_create=", failed_create);
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
    //     CBarTimeSeriesDE *bartimeseries  = this.m_BarTimeSeriesCollection.GetTimeseries(symbol);
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
    //        CBarTimeSeriesDE *ts = this.m_BarTimeSeriesCollection.GetTimeseries(symbol);
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
    //        CArrayObj *list = this.m_BarTimeSeriesCollection.GetList();
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
  // //| exists in m_BarTimeSeriesCollection - regardless of which chart is active.|
  // //| Show/Hide on chart is a separate, display-only concern.          |
  // //+------------------------------------------------------------------+
  // void CTimeSeriesEngine::ScanAndApplyIndicators(void)
  //  {
  //     CArrayObj *sym_list = m_symbol_collection.GetList();
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
  //           CBarTimeSeriesDE *sym_bts = m_BarTimeSeriesCollection.GetTimeseries(sym_item != NULL ? sym_item.Name() : "");
  //           if(sym_bts != NULL && sym_bts.GetListSeries() != NULL)
  //              total_series_count += sym_bts.GetListSeries().Total();
  //        }
  //        if(chart_non_custom_count > 0 && total_series_count > 0 &&
  //           m_IndicatorsCollection.GetList().Total() == chart_non_custom_count * total_series_count)
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

  //              CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym_obj.Name());
  //              if(bts == NULL) continue;
  //              CArrayObj *series_list = bts.GetListSeries();
  //              if(series_list == NULL) continue;

  //              CArrayObj *by_sym      = m_IndicatorsCollection.GetListIndBySymbol(sym_obj.Name());
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

  //                 CIndicatorDE *new_ind = m_IndicatorsCollection.CreateIndicator(ind_type, params, sym_obj.Name(), target_tf);
  //                 if(new_ind != NULL)
  //                 {
  //                    new_ind.SetShortName(name);
  //                    m_IndicatorsCollection.GetList().Add(new_ind);
  //                 }
  //               }
  //            }
  //         }
  //      }
  //     Print("MyDebug CTimeSeriesEngine::ScanAndApplyIndicators END: Total IndicatorDE Objects list.Total()=",
  //           m_IndicatorsCollection.GetList().Total());
  //  }
#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
