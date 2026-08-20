//+------------------------------------------------------------------+
//|                                    TimeSeriesEngine_SymbolTF.mqh |
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_SYMBOLTF
#define CTIMESERIESENGINE_SYMBOLTF
#include "TimeSeriesEngine.mqh"
 extern string g_ea_folder;  // From EA
 //+------------------------------------------------------------------+
 //| Layer 1: Create a Series for every entry in an already-parsed    |
 //| m_symbol_tf_Setting[] (CGUIPannel::LoadSymbolTFSettingFromJSON    |
 //| parses the file and hands this array in).                        |
 //| MUST run BEFORE AddAllIndicatorsToNewSeries (TimeSeriesEngine_    |
 //| Indicator.mqh) - LoadIndicatorTemplateSettingFromJSON calls that  |
 //| once per Series created here, to attach indicators to it.        |
 //+------------------------------------------------------------------+
 void CTimeSeriesEngine::ApplySymbolTFSetting(SJsonSymbolTF &m_symbol_tf_Setting[])
  {
    int sf_total = ArraySize(m_symbol_tf_Setting);
    int series_created = 0;
    for(int s = 0; s < sf_total; s++)
      {
       string sym = m_symbol_tf_Setting[s].symbol;
       ENUM_TIMEFRAMES tf = TimestampByDescription(m_symbol_tf_Setting[s].tf);
       // --- sym == "": skip malformed/empty slot. IsAvailable(): CreateSeries/AddSeries already
       // --- no-ops safely on a duplicate (Library-verified), so this isn't load-bearing for
       // --- correctness - kept for symmetry with OnInitEvent's own IsAvailable guard convention.
       if(sym == "" || this.m_BarTimeSeriesCollection.IsAvailable(sym, tf)) continue;
       if(this.m_BarTimeSeriesCollection.CreateSeries(sym, tf))
          {
           series_created++;        
           this.SeriesApplyPatternRegistry(sym, tf);
          }
      }
    Print("CTimeSeriesEngine::ApplySymbolTFSetting > recreated ", series_created, "/", sf_total, " symbol/TF series");
  } 
#endif // CTIMESERIESENGINE_JSONCONFIG
