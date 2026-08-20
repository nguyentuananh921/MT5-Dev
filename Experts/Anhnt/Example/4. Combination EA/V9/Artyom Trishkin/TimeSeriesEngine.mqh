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
  #include "..\Anatoli Kazharski\JSONConfig.mqh"
#ifndef CTIMESERIESENGINE_MQH_DECLARATION
#define CTIMESERIESENGINE_MQH_DECLARATION
 extern string g_ea_folder;  // From EA
 // --- Symbol/TF identity (symbol+tf) no longer has its own mirror here (SynIndicatorPlan.md,
 // --- "Action" Step 1, 2026-08-18 - same treatment as the Indicator-Template merge below):
 // --- CGUIPannel::m_symbol_tf_Setting[] (SJsonSymbolTF - already a superset: symbol+tf+buy+sell)
 // --- is the ONE live array. It was write-only here (LoadSymbolTFFromJSON populated it, nothing
 // --- in Layer 1 ever read it back) - genuinely redundant, not just chart-scoped like the
 // --- Indicator-Template case.
 // --- Indicator-Template identity (type+params) no longer has its own mirror here
 // --- (SynIndicatorPlan.md, "Action" Step 1, 2026-08-18): CGUIPannel::m_indicator_template_setting[]
 // --- (SJsonIndicatorEntry - already a superset: type+params[]+buy+sell+sound+message) is now the
 // --- ONE live array, owned by Layer 2. Layer 1 never keeps its own copy - every method below that
 // --- used to read/write m_indicator_template[] now takes m_indicator_template_setting[] as a
 // --- reference parameter instead, matching the pattern SaveConfigurationToJSON already used.
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
       SDataCalculate            m_last_data_calc;
       CTimeCounter              m_bg_counter;
      // Symbols already given ONE BookAdd() attempt this run, success or fail - BookdepthSubscription()
      // alone can't tell "never tried" from "tried and the broker refused" (both read false), so a
      // symbol with no DOM support on this server would retry (and fail) forever on every new TF
      // switch without this - see DOM setup in OnInitEvent.
       string                    m_dom_attempted[];
    //Borrow
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection
    //For Signal - freeze bar 1 of any (symbol,TF) that just got a SERIES_EVENTS_NEW_BAR event
    //this refresh cycle, read back from m_BarTimeSeriesCollection's own event list (never call
    //CBarSeriesDE::IsNewBar() directly here - that call is owned/consumed by the bar series itself)
      void                      ProcessNewBarSignalEvents(void);
    //Internal-only (README.md muc 7.b: Layer 2 never calls this - it reads its own Data instead,
    //via GetIndicatorForRow). AddIndicatorToList DELETES the passed object when an equal one is
    //already in the collection and silently switches to the canonical instance, so the caller's
    //pointer may be dangling after it returns. Always re-acquire by handle via this helper
    //before handing the indicator to CSignalsCollection.
      CIndicatorDE             *GetIndicatorByHandle(const int handle);
    public:
    //CTimeSeriesEngine Lifecycle ->Implementation in TimeSeriesEngine_Lifecycle.mqh
        bool  OnTimerEvent(void);        
        bool  OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period);        
        bool  OnTickEvent(const string symbol, SDataCalculate &data_calc);
        bool  OnChartEvent(const int id, const long& lparam,
                           const double& dparam, const string& sparam,
                           SJsonIndicatorEntry &m_indicator_template_setting[]);
    // Gateway
          CBarTimeSeriesCollection    *GetTimeSeriesCollection(void)                      { return &this.m_BarTimeSeriesCollection; }
          void                        SetSymbolsCollection(CSymbolsCollection *symbols)   { m_symbol_collection = symbols; }
          CIndicatorsCollection       *GetIndicatorsCollection()                          { return &this.m_IndicatorsCollection; }
          CMBookSeriesCollection      *GetBookSeries()                                    { return &this.m_MBookSeriesCollection; }
          CSignalsCollection          *GetSignalsCollection()                             { return &this.m_SignalsCollection; }
          //CTickSeriesCollection       *GetTickSeries()                                    { return &this.m_tick_series; }
          CBarPatternsControl         *GetPatternsControl()                               { return &m_BarPatterns_Control; }
    //Applies a parsed "Symbols_TFs_List" implementation in TimeSeriesEngine_SymbolTF.mqh    
        void  ApplySymbolTFSetting(SJsonSymbolTF &m_symbol_tf_Setting[]);
    // Layer 1: AddAllIndicatorsToNewSeries READS m_indicator_template_setting[] (CGUIPannel's array, passed by reference 
    // Layer 1 keeps no copy of its own). AddNewIndicatorToAllSeries/RemoveIndicatorFromAllSeries are purely mechanical now.
    // CGUIPannel is the only one that touches m_indicator_template_setting[] during Live (checks existence itself via
    // IsIndicatorInTemplateSetting BEFORE calling Add, and RefreshTableIndicator() re-syncs the
    // array from the live indicator list AFTER either call) - Layer 1 does the instance
    // create/delete only, no array involved.
        void                        AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                      SJsonIndicatorEntry &m_indicator_template_setting[]);
        bool                        AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);    
        void                        RemoveIndicatorFromAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
    // Layer 2 query: handle of the live indicator matching (symbol,tf,type,params), or
    // INVALID_HANDLE if none exists yet - lets Layer 2 ask for a handle without holding/
    // dereferencing a live CIndicatorDE* (README.md muc 7.b).
        int                         GetIndicatorHandle(const string symbol, const ENUM_TIMEFRAMES tf,
                                      const ENUM_INDICATOR type, MqlParam &params[]);
    // For Candle Pattern at Layer 1
        void                        RegisterAllCandlePatterns(void);        
        bool                        SeriesApplyPatternRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe);
  };
#endif // CTIMESERIESENGINE_MQH_DECLARATION
#ifndef CTIMESERIESENGINE_MQH_IMPLEMENTATION
#define CTIMESERIESENGINE_MQH_IMPLEMENTATION
 #include "TimeSeriesEngine_Lifecycle.mqh"
 #include "TimeSeriesEngine_SymbolTF.mqh"
 #include "TimeSeriesEngine_CandlePattern.mqh" 
 #include "TimeSeriesEngine_Indicator.mqh"
#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
