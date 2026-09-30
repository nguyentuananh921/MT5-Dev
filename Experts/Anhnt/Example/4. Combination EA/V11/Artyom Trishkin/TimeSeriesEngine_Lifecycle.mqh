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
  if(this.m_MBookSeriesCollection.DataTotal() == 0)
       this.m_MBookSeriesCollection.CreateCollection(m_symbol_collection.GetList());
  bool dom_already_attempted = false;
  for(int di = 0; di < ArraySize(m_dom_attempted); di++)
    if(m_dom_attempted[di] == symbol) { dom_already_attempted = true; break; }
  if(!dom_already_attempted)
   {
      CSymbol *book_sym = m_symbol_collection.GetSymbolObjByName(symbol);
      if(book_sym != NULL && book_sym.TicksBookdepth() > 0) book_sym.BookAdd();
      int dom_n = ArraySize(m_dom_attempted);
      ArrayResize(m_dom_attempted, dom_n + 1);
      m_dom_attempted[dom_n] = symbol;
   }   
  if(!m_time_series_engine_init_complete)
   {
    this.m_SwingSetting.LoadFromJSON();   // before any series exists - each new CBarSwingControl copies from it
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
            swing_ctrl_s.Strength(this.m_SwingSetting.Strength());
            swing_ctrl_s.PriceBasis(this.m_SwingSetting.PriceBasis());
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
    // --- Layer 1 owns the instances: the row is already gone from the Manager, so take its
    // identity from the pre-delete snapshot and drop every (symbol,tf) instance + Signal + handle.
    // Chart-line removal stays with the EA (CChartObjCollection).
    ENUM_INDICATOR type; MqlParam params[];
    templateManager.GetLastRemoved(type, params);
    this.RemoveIndicatorFromAllSeries(type, params);
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
         swing_ctrl.Strength(this.m_SwingSetting.Strength());
         swing_ctrl.PriceBasis(this.m_SwingSetting.PriceBasis());
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
     this.m_MBookSeriesCollection.Refresh(symbol, (long)::TimeCurrent() * 1000); // DOM snapshot for current symbol only
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
