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
 // --- Layer 1 identity-only mirrors (Anhnt, 2026-08-16 - SeparateLayer_Plan.md): Buy/Sell/
 // --- Sound/Message are Layer 2 (CGUIPannel) concerns, NOT stored here anymore - Layer 1 only
 // --- keeps what it actually needs to recreate series/indicators (symbol+tf, type+params_key).
 struct SSymbolTF          { string symbol; string tf; };
 // renamed from SIndicatorTemplate (SynIndicatorPlan.md, 2026-08-17) - this struct identifies
 // ONE indicator (type+params, e.g. distinguishing 2 different PSAR or 3 different MA by their
 // Parameters) - it's the ARRAY (m_indicator_template[]) that represents "the Template" (the
 // whole set applied uniformly across every symbol/TF), not this single-entry struct.
 struct SIndicatorIdentity { string type; string params_key; };
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
      // --- Identity-only mirror of the last LoadConfigurationFromJSON() call's "Symbols_TFs_List"
      // --- (symbol+tf, no buy/sell - that's Layer 2's, see SeparateLayer_Plan.md).
       SSymbolTF                 m_symbol_tf[];
      // Identity-only mirror of "Indicator_Templates" (type+params_key, no buy/sell/sound/message). 
      // This IS a mirror of the real indicator templates living in m_IndicatorsCollection, not the source of truth itself.
       SIndicatorIdentity        m_indicator_template[];
    //Borrow
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection
    //For indicator ->Implementation in TimeSeriesEngine_JSONConfig.mqh      
      int                       LoadSymbolTFFromJSON(const string filename, SJsonSymbolTF &out_symbols_tf[]);
      int                       LoadIndicatorTemplateFromJSON(const string filename, SJsonIndicatorEntry &out_entries[]);
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
    // //Temporary debug: dump every indicator instance with its handle - identifies which
    // //object owns a handle reported broken by CSeriesDataInd::Refresh (err 4807 hunt)
    //   void                      PrintIndicatorsInventory(void);       
    //CTimeSeriesEngine Lifecycle ->Implementation in TimeSeriesEngine_Lifecycle.mqh
        bool  OnTimerEvent(void);        
        bool  OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period,
                           SJsonIndicatorEntry &out_entries[], SJsonSymbolTF &out_symbols_tf[]);
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
    // --- L1.Task1 (Delete), symmetric to AddNewIndicatorToAllSeries/L1.Task2 (SynIndicatorPlan.md,
    // --- "3 Layer Task breakdown", 2026-08-18) - removes the identity mirror entry + every
    // --- symbol/TF instance + its Signal. No chart/window knowledge here (same as Task2 never
    // --- touches the chart either) - caller (Layer 2) detaches any chart display FIRST.
        void                        RemoveIndicatorFromAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
    // --- Live m_indicator_template[] mirror (SynIndicatorPlan.md, 2026-08-17): identity-only
    // --- existence check + removal, keyed by the SAME (type_key, params_key) strings
    // --- BuildTemplateMatchKey() builds. AddNewIndicatorToAllSeries() is the sole ADD entry
    // --- point (writes internally, no separate public Add method needed - it's already a member).
        bool                        TemplateExists(const string type_key, const string params_key);
        void                        RemoveIndicatorTemplate(const string type_key, const string params_key);
        //bool                        SaveConfigurationToJSON(const string filename);
        // --- tmpl_setting[]: LIVE checkbox state from CGUIPannel's Indicator tab, passed straight
        // --- as m_indicator_template_setting[] (Anhnt, 2026-08-18: one SJsonIndicatorEntry array
        // --- instead of 6 parallel tmpl_type_key/params_key/buy/sell/sound/message arrays - the
        // --- struct already holds type+params[]+buy+sell+sound+message together, no need to
        // --- decompose it on the way in just to re-read the same fields on the way out). Matched
        // --- by (type,params) - SAME strings BuildTemplateMatchKey() builds - against the real
        // --- templates in m_IndicatorsCollection.
        bool                        SaveConfigurationToJSON(const string filename,
                                      const string &symbols[], const string &tfs[],
                                      const bool &buys[], const bool &sells[],
                                      SJsonIndicatorEntry &tmpl_setting[]);
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
