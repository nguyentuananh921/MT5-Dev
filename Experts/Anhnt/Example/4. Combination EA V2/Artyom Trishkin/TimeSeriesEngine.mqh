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
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\BarTimeSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SymbolsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\IndicatorsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SignalsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarPatternsControl\BarPatternsControl.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\DELib\TimeseriesDELib.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\TimeCounter.mqh>
  #include "..\Services\SwingSettingJSON.mqh"
#ifndef CTIMESERIESENGINE_MQH_DECLARATION
#define CTIMESERIESENGINE_MQH_DECLARATION
 class CSymbolTFManager;
 class CIndicatorTemplateManager;
 class CIndicatorSetting;
 class CTimeSeriesEngine
  {
    private:
     //Owns      
       CBarTimeSeriesCollection  m_BarTimeSeriesCollection;        // BarTimeseries collection
       CIndicatorsCollection     m_IndicatorsCollection;           //Indicator collection
       CSignalsCollection        m_SignalsCollection;     // 1-1 CIndicatorDE<->CSignalXXX linkage (EA-local)
       CBarPatternsControl       m_BarPatterns_Control;   // Pattern registry (applied to new TF series) m_pattern_cfg
       CSwingSetting             m_SwingSetting;          // EA-wide Swing N + Wick/Body (applied to new TF series, CGUIPannel borrows a pointer)
       SDataCalculate            m_last_data_calc;
       CTimeCounter              m_bg_counter;      
       bool                      m_time_series_engine_init_complete;
    //Borrow
      CSymbolsCollection        *m_symbol_collection;    // Symbol collection    
      void                      ProcessNewBarSignalEvents(void);    
      CIndicatorDE              *GetIndicatorByIdentity(const string symbol, const ENUM_TIMEFRAMES tf,
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
      CSignalsCollection          *GetSignalsCollection()                             { return &this.m_SignalsCollection; }
      CBarPatternsControl         *GetPatternsControl()                               { return &m_BarPatterns_Control; }
      CSwingSetting               *GetSwingSetting()                                  { return &m_SwingSetting; }
    // Layer 1: AddAllIndicatorsToNewSeries reads CIndicatorTemplateManager directly (Single
    // Source of Truth, Layer 1 keeps no copy of its own, just a borrowed
        void                        AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                      CIndicatorTemplateManager *manager);
        bool                        AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);    
        void                        RemoveIndicatorFromAllSeries(const ENUM_INDICATOR type, MqlParam &params[]);
        void                        RemoveSymbolTF(const string symbol, const ENUM_TIMEFRAMES timeframe);
  };
#endif // CTIMESERIESENGINE_MQH_DECLARATION
#ifndef CTIMESERIESENGINE_MQH_IMPLEMENTATION
#define CTIMESERIESENGINE_MQH_IMPLEMENTATION
 #include "TimeSeriesEngine_Lifecycle.mqh"
 #include "TimeSeriesEngine_Indicator.mqh"
#endif // CTIMESERIESENGINE_MQH_IMPLEMENTATION
#endif // CTIMESERIESENGINE_MQH
