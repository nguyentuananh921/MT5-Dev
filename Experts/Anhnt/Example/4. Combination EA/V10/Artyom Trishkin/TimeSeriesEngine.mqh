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
       string                    m_dom_attempted[];
       bool                      m_time_series_engine_init_complete;
    //Borrow
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection    
      void                      ProcessNewBarSignalEvents(void);    
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
                           CSymbolTFManager *manager, CIndicatorTemplateManager *templateManager);
     // Gateway
      CBarTimeSeriesCollection    *GetTimeSeriesCollection(void)                      { return &this.m_BarTimeSeriesCollection; }
      void                        SetSymbolsCollection(CSymbolsCollection *symbols)   { m_symbol_collection = symbols; }
      CIndicatorsCollection       *GetIndicatorsCollection()                          { return &this.m_IndicatorsCollection; }
      CMBookSeriesCollection      *GetBookSeries()                                    { return &this.m_MBookSeriesCollection; }
      CSignalsCollection          *GetSignalsCollection()                             { return &this.m_SignalsCollection; }
      //CTickSeriesCollection       *GetTickSeries()                                    { return &this.m_tick_series; }
      CBarPatternsControl         *GetPatternsControl()                               { return &m_BarPatterns_Control; }
    // Layer 1: AddAllIndicatorsToNewSeries reads CIndicatorTemplateManager directly (Single
    // Source of Truth, Layer 1 keeps no copy of its own, just a borrowed
        void                        AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                      CIndicatorTemplateManager *manager);
        bool                        AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);    
        void                        RemoveIndicatorFromAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
  };
#endif // CTIMESERIESENGINE_MQH_DECLARATION
#ifndef CTIMESERIESENGINE_MQH_IMPLEMENTATION
#define CTIMESERIESENGINE_MQH_IMPLEMENTATION
 #include "TimeSeriesEngine_Lifecycle.mqh"
 #include "TimeSeriesEngine_Indicator.mqh"
#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
