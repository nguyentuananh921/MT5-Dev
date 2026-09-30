//+------------------------------------------------------------------+
//|                                   TimeSeriesEngine_Lifecycle.mqh |
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_LIFECYCLE_MQH
#define CTIMESERIESENGINE_LIFECYCLE_MQH
#include "TimeSeriesEngine.mqh"
#include "..\Services\SymbolTFManager.mqh"   // CSymbolTFManager/CSymbolTFSetting - bulk-sync loop reads it LIVE 
 bool CTimeSeriesEngine::OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period,
                                      CSymbolTFManager *manager, CIndicatorTemplateManager *templateManager)
 {
  if(m_symbol_collection == NULL) return false;
  if(!m_time_series_engine_init_complete)
   {
    SwingSetting_LoadFromJSON(this.m_SwingSetting, manager != NULL ? manager.GetFolderName() : ::MQLInfoString(MQL_PROGRAM_NAME));   // before any series exists
    this.m_BarTimeSeriesCollection.CreateCollection(m_symbol_collection.GetList());
    this.m_BarPatterns_Control.RegisterAllKnownPatterns();
    if(manager != NULL)
     {
      int sf_total = manager.Total();
      for(int s = 0; s < sf_total; s++)
       {
        CSymbolTFSetting *entry = manager.At(s);
        if(entry == NULL) continue;
        string sym = entry.Symbol();
        ENUM_TIMEFRAMES tf = entry.TFEnum();
        if(sym == "" || this.m_BarTimeSeriesCollection.IsAvailable(sym, tf)) continue;
        if(this.m_BarTimeSeriesCollection.CreateSeries(sym, tf))
         {
          CBarTimeSeriesDE *bts_s = this.m_BarTimeSeriesCollection.GetTimeseries(sym);
          CBarSeriesDE *s_obj = (bts_s != NULL) ? bts_s.GetSeries(tf) : NULL;
          CBarPatternsControl *ctrl_s = (s_obj != NULL) ? s_obj.GetPatternsCtrlObj() : NULL;
          if(ctrl_s != NULL) ctrl_s.RegisterAllKnownPatterns();
          CBarSwingControl *swing_ctrl_s = (s_obj != NULL) ? s_obj.GetSwingCtrlObj() : NULL;
          if(swing_ctrl_s != NULL)
           {
            swing_ctrl_s.SetSwingSetting(&this.m_SwingSetting);
            swing_ctrl_s.InitSwingList();
           }
         }
         AddAllIndicatorsToNewSeries(sym, tf, templateManager);
        }
       }
      m_time_series_engine_init_complete = true;
     }
    return true;
 }
bool CTimeSeriesEngine::OnChartEvent(const int id, const long& lparam,
                                const double& dparam, const string& sparam,
                                CSymbolTFManager *manager, CIndicatorTemplateManager *templateManager)
 {    
  if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
   {
    if(templateManager == NULL) return false;    
    ENUM_INDICATOR type = (ENUM_INDICATOR)lparam;
    int tmpl_total = templateManager.Total();
    for(int t = 0; t < tmpl_total; t++)
     {
      CIndicatorSetting *entry = templateManager.At(t);
      if(entry == NULL || entry.TypeEnum() != type) continue;
      MqlParam params[];
      entry.GetRawParams(params);
      this.AddNewIndicatorToAllSeries(type, params);
     }
    return true;
   }
  if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
   {
    if(templateManager == NULL) return false;    
    ENUM_INDICATOR type; MqlParam params[];
    templateManager.GetLastRemoved(type, params);
    this.RemoveIndicatorFromAllSeries(type, params);
    return true;
   }
  if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE)
   {
    if(manager == NULL) return false;
    string removed_sym;
    ENUM_TIMEFRAMES removed_tf;
    manager.GetLastRemoved(removed_sym, removed_tf);
    this.RemoveSymbolTF(removed_sym, removed_tf);
    return true;
   }
  if(id != CHARTEVENT_CHART_CHANGE) return false;
  string sym          = ::Symbol();
  ENUM_TIMEFRAMES curr = (ENUM_TIMEFRAMES)::ChartPeriod(0);
  if(manager != NULL && !manager.Exists(sym, curr))
    manager.Add_SymbolTFSetting(sym, curr);
    // Step 1: Ensure series exists
    bool is_new_series = !this.m_BarTimeSeriesCollection.IsAvailable(sym, curr);
    if(is_new_series)
     {
      this.m_BarTimeSeriesCollection.CreateSeries(sym, curr);
      // Step 2: Apply the full Candle Pattern registry to the newly created series      
      {
       CBarTimeSeriesDE *bts = this.m_BarTimeSeriesCollection.GetTimeseries(sym);
       CBarSeriesDE *s = (bts != NULL) ? bts.GetSeries(curr) : NULL;
       CBarPatternsControl *ctrl = (s != NULL) ? s.GetPatternsCtrlObj() : NULL;
       if(ctrl != NULL) ctrl.RegisterAllKnownPatterns();
       CBarSwingControl *swing_ctrl = (s != NULL) ? s.GetSwingCtrlObj() : NULL;
       if(swing_ctrl != NULL)
        {
         swing_ctrl.SetSwingSetting(&this.m_SwingSetting);
         swing_ctrl.InitSwingList();
        }
      }
      // CIndicatorTemplateManager, Single Source of Truth) into this brand new series
       this.AddAllIndicatorsToNewSeries(sym, curr, templateManager);
     }
    else
     {
      
     }
    // Case 2: old series - patterns already in m_list_all_patterns, skip rescan
    return is_new_series;
 }
 bool CTimeSeriesEngine::OnTickEvent(const string symbol, SDataCalculate &data_calc)
  {
    //this.m_BarTimeSeriesCollection.Refresh(data_calc);       // ALL symbols, ALL TFs
     this.m_last_data_calc = data_calc;
     this.m_BarTimeSeriesCollection.Refresh(symbol, data_calc); // Refresh only current chart symbol; CopyRates reads from local cache when synchronized
    //this.m_tick_series.Refresh(symbol);
     m_IndicatorsCollection.SeriesRefreshBySymbol(symbol);
     m_SignalsCollection.RefreshCurrentBar(symbol); // current chart symbol only - stays live every tick, not just every timer tick
     ProcessNewBarSignalEvents(); // freeze bar 1 for any (symbol,TF) whose bar just closed this tick
     return this.m_BarTimeSeriesCollection.IsEvent();           // true if any TF has a new bar
  }
 bool CTimeSeriesEngine::OnTimerEvent(void)
  {
    m_SignalsCollection.RefreshCurrentBar(); // recompute bar 0 for every tracked signal - "current direction" must never be stale

    if(!this.m_bg_counter.CheckTimeCounter()) return false;

    ulong t0 = ::GetMicrosecondCount();
    this.m_BarTimeSeriesCollection.RefreshAllExceptCurrent(this.m_last_data_calc);
    ProcessNewBarSignalEvents(); // freeze bar 1 for any (symbol,TF), other than the chart's own, whose bar just closed

    ulong t1 = ::GetMicrosecondCount();
    m_IndicatorsCollection.SeriesRefreshAllExceptSymbol(::Symbol());
    //this.m_tick_series.RefreshExpectCurrent();

    ulong t2 = ::GetMicrosecondCount();
    // if(t2 - t0 > 1000)
    //    ::Print("PERF CTimeSeriesEngine::OnTimerEvent bars=", t1-t0, "us indicators+ticks=", t2-t1, "us");
    return false;
 }
#endif // CTIMESERIESENGINE_LIFECYCLE_MQH
