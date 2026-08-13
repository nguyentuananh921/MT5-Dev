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
 extern string g_ea_folder;  // From EA
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
    //For indicator ->Implementation in TimeSeriesEngine_JSONConfig.mqh
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
        //bool                        SaveConfigurationToJSON(const string filename);
        bool                        SaveConfigurationToJSON(const string filename,
                                      const string &symbols[], const string &tfs[],
                                      const bool &buys[], const bool &sells[]);
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
#include "TimeSeriesEngine_Indicator.mqh"
 

#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
