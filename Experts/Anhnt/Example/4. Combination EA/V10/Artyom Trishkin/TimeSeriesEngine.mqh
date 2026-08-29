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
  #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\DELib\TimeseriesDELib.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\TimeCounter.mqh>
#ifndef CTIMESERIESENGINE_MQH_DECLARATION
#define CTIMESERIESENGINE_MQH_DECLARATION
 extern string g_ea_folder;  // From EA 
 class CSymbolTFManager;
 class CIndicatorTemplateManager;
 class CIndicatorSetting;
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
      // true after OnInitEvent()'s bulk Symbol+TF/Indicator sync has run once - NOT a "whole
      // Layer 1" flag (CTradingEngine has its own separate lifecycle), scoped to THIS class only.
      // Same "only really do this once" convention as CSymbolTFManager/CIndicatorTemplateManager's
      // own m_loaded_from_json - every REASON_CHARTCHANGE reinit calls OnInitEvent again, but the
      // bulk-sync must NOT re-run each time; new Symbol+TF/Indicator rows after this point arrive
      // via SYMBOLTF_MANAGER_EVENT_ADDED/INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED instead (Anhnt, 2026-08-28).
       bool                      m_time_series_engine_init_complete;
    //Borrow
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection
    //For Signal - freeze bar 1 of any (symbol,TF) that just got a SERIES_EVENTS_NEW_BAR event
    //this refresh cycle, read back from m_BarTimeSeriesCollection's own event list (never call
    //CBarSeriesDE::IsNewBar() directly here - that call is owned/consumed by the bar series itself)
      void                      ProcessNewBarSignalEvents(void);
    //Internal-only (README.md muc 7.b: Layer 2 never calls this - it reads its own Data instead,
    //via GetIndicatorForRow). AddIndicatorToList DELETES the passed object when an equal one is
    //already in the collection and silently switches to the canonical instance, so the caller's
    //pointer may be dangling after it returns. Always re-acquire by (type,params,symbol,tf)
    //IDENTITY via this helper before handing the indicator to CSignalsCollection - NOT by raw
    //handle number (GetIndicatorByHandle, V9 leftover, removed 2026-08-28): MQL5 handles are
    //program-wide slots that get REUSED after release (see project's own 4807-hunt finding), so
    //a linear scan matching on the numeric handle risks returning a stale, unrelated instance
    //whose old handle value just got recycled - identity match can never collide like that.
      CIndicatorDE             *GetIndicatorByIdentity(const string symbol, const ENUM_TIMEFRAMES tf,
                                  const ENUM_INDICATOR type, MqlParam &params[]);
    public:
    //CTimeSeriesEngine Lifecycle ->Implementation in TimeSeriesEngine_Lifecycle.mqh
        bool  OnTimerEvent(void);        
        bool  OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period,
                          CSymbolTFManager *manager, CIndicatorTemplateManager *templateManager);
        bool  OnTickEvent(const string symbol, SDataCalculate &data_calc);
        bool  OnChartEvent(const int id, const long& lparam,
                           const double& dparam, const string& sparam,
                           CIndicatorTemplateManager *manager);
    // Gateway
          CBarTimeSeriesCollection    *GetTimeSeriesCollection(void)                      { return &this.m_BarTimeSeriesCollection; }
          void                        SetSymbolsCollection(CSymbolsCollection *symbols)   { m_symbol_collection = symbols; }
          CIndicatorsCollection       *GetIndicatorsCollection()                          { return &this.m_IndicatorsCollection; }
          CMBookSeriesCollection      *GetBookSeries()                                    { return &this.m_MBookSeriesCollection; }
          CSignalsCollection          *GetSignalsCollection()                             { return &this.m_SignalsCollection; }
          //CTickSeriesCollection       *GetTickSeries()                                    { return &this.m_tick_series; }
          CBarPatternsControl         *GetPatternsControl()                               { return &m_BarPatterns_Control; }
    // Layer 1: AddAllIndicatorsToNewSeries reads CIndicatorTemplateManager directly (Single
    // Source of Truth, Anhnt 2026-08-27) - Layer 1 keeps no copy of its own, just a borrowed
    // pointer for the duration of this one call. AddNewIndicatorToAllSeries/RemoveIndicatorFromAllSeries
    // remain purely mechanical (type+params only, no Manager needed there).
        void                        AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                      CIndicatorTemplateManager *manager);
        bool                        AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);    
        void                        RemoveIndicatorFromAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
    // Layer 2 query: handle of the live indicator matching (symbol,tf,type,params), or
    // INVALID_HANDLE if none exists yet - lets Layer 2 ask for a handle without holding/
    // dereferencing a live CIndicatorDE* (README.md muc 7.b).
        int                         GetIndicatorHandle(const string symbol, const ENUM_TIMEFRAMES tf,
                                      const ENUM_INDICATOR type, MqlParam &params[]);
    // For Candle Pattern at Layer 1               
        bool                        SeriesApplyPatternRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe);
  };
#endif // CTIMESERIESENGINE_MQH_DECLARATION
#ifndef CTIMESERIESENGINE_MQH_IMPLEMENTATION
#define CTIMESERIESENGINE_MQH_IMPLEMENTATION
 #include "TimeSeriesEngine_Lifecycle.mqh"
 #include "TimeSeriesEngine_CandlePattern.mqh"
 #include "TimeSeriesEngine_Indicator.mqh"
#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
