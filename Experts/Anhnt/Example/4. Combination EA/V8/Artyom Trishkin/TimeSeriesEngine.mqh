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
       CBarPatternsControl       m_BarPatterns_Control;   // Pattern registry (applied to new TF series) m_pattern_cfg 
       //CArrayObj                 *m_empty_patterns;        // For pattern control initialization
       SDataCalculate            m_last_data_calc;
       CTimeCounter              m_bg_counter;
      // Symbols already given ONE BookAdd() attempt this run, success or fail - BookdepthSubscription()
      // alone can't tell "never tried" from "tried and the broker refused" (both read false), so a
      // symbol with no DOM support on this server would retry (and fail) forever on every new TF
      // switch without this - see DOM setup in OnInitEvent.
       string                    m_dom_attempted[];
      // --- Symbol/TF Buy/Sell cached from the last LoadConfigurationFromJSON() call - GUIPannel
      // --- reads these via GetLoadedSymbolTFSettings() to seed m_table_indicator_SymbolTFSeting's
      // --- checkboxes right after it builds the rows from m_BarTimeSeriesCollection.
       string                    m_loaded_sf_symbols[];
       string                    m_loaded_sf_tfs[];
       bool                      m_loaded_sf_buy[];
       bool                      m_loaded_sf_sell[];
      // --- Indicator template Buy/Sell cached from the last LoadConfigurationFromJSON() call -
      // --- GUIPannel reads these via GetLoadedTemplateSettings() to seed m_table_indicator's
      // --- checkboxes right after RefreshIndicatorTable() rebuilds m_table_indicator_ptrs[].
      // --- Matched by (type, params-as-text) - templates have no symbol/TF identity of their
      // --- own (README: every symbol/TF carries the same template set).
       string                    m_loaded_tmpl_type[];
       string                    m_loaded_tmpl_params_key[];
       bool                      m_loaded_tmpl_buy[];
       bool                      m_loaded_tmpl_sell[];
       bool                      m_loaded_tmpl_sound[];   // per-template alert-sound opt-in (2026-07-17)
       bool                      m_loaded_tmpl_message[]; // per-template Journal-message opt-in
    //Borrow
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection
    //For indicator
      int                       LoadConfigurationFromJSON(const string filename);
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
    //CTimeSeriesEngine Lifecycle ->Implementation in TimeSeriesEngine_Lifecycle.mqh
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
          CSignalsCollection          *GetSignalsCollection()                             { return &this.m_SignalsCollection; }
          //CTickSeriesCollection       *GetTickSeries()                                    { return &this.m_tick_series; }
          CBarPatternsControl         *GetPatternsControl()                               { return &m_BarPatterns_Control; }
    // Tang 1: JSON template <-> indicator series
        void                        AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe);
        bool                        AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
        bool                        SaveConfigurationToJSON(const string filename);
        void                        GetLoadedSymbolTFSettings(string &symbols[], string &tfs[], bool &buys[], bool &sells[]);
        void                        GetLoadedTemplateSettings(string &types[], string &param_keys[], bool &buys[], bool &sells[],
                                                                bool &sounds[], bool &messages[]);
        bool                        RemoveSymbolTFFromConfigJSON(const string filename, const string symbol, const string tf_text);
    // For Candle Pattern at Layer 1
        void  RegisterAllCandlePatterns(void);
        // void  RegisterPattern(const ENUM_PATTERN_TYPE type, MqlParam &param[])
        //                       { this.m_pattern_cfg.SetUsedPattern(type, param, true); }
        bool  SeriesApplyPatternRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe);
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
#include "TimeSeriesEngine_Lifecycle.mqh"
#include "TimeSeriesEngine_JSONConfig.mqh"
#include "TimeSeriesEngine_CandlePattern.mqh" 
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
