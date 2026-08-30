//+------------------------------------------------------------------+
//|                                   TimeSeriesEngine_Lifecycle.mqh |
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_LIFECYCLE_MQH
#define CTIMESERIESENGINE_LIFECYCLE_MQH
#include "TimeSeriesEngine.mqh"
#include "..\Services\SymbolTFManager.mqh"   // CSymbolTFManager/CSymbolTFSetting - bulk-sync loop reads it LIVE
 //Life cycle management
 bool CTimeSeriesEngine::OnInitEvent(const string symbol, const ENUM_TIMEFRAMES period,
                                      CSymbolTFManager *manager, CIndicatorTemplateManager *templateManager)
  {
   if(m_symbol_collection == NULL) return false;

   // DOM setup - chay MOI lan goi (symbol cua chart co the doi qua tung reinit), tu guard
   // theo tung symbol qua m_dom_attempted[] - khong nam trong co init_complete ben duoi.
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

   // Bulk-sync - DUNG 1 LAN cho ca doi EA, khong lap lai moi lan REASON_CHARTCHANGE - sau
   // lan nay, Symbol+TF/Indicator moi hoan toan do 2 handler reactive lo (SYMBOLTF_MANAGER_
   // EVENT_ADDED/INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED o EA.mq5), khong quay lai day nua.
    if(!m_time_series_engine_init_complete)
     {
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
            // --- CBarPatternsControl already carries its own symbol/timeframe - self-register
            // --- directly instead of a separate SeriesApplyPatternRegistry() lookup (Anhnt, 2026-08-29).
            {
             CBarTimeSeriesDE *bts_s = this.m_BarTimeSeriesCollection.GetTimeseries(sym);
             CBarSeriesDE *s_obj = (bts_s != NULL) ? bts_s.GetSeries(tf) : NULL;
             CBarPatternsControl *ctrl_s = (s_obj != NULL) ? s_obj.GetPatternsCtrlObj() : NULL;
             if(ctrl_s != NULL) ctrl_s.RegisterAllKnownPatterns();
            }
            AddAllIndicatorsToNewSeries(sym, tf, templateManager);
           }
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
    // --- "tay nao lo viec tay ay" (Anhnt, 2026-08-30): moved out of EA::OnChartEvent's
    // --- INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED handler, which used to call
    // --- AddNewIndicatorToAllSeries() inline - that's purely this class's own Layer 1 business.
    // --- The other half of that same EA block (ShowIndicatorOnChart via m_ChartObjCollection)
    // --- stays in the EA - CChartObjCollection is a Library class and can't depend on
    // --- CIndicatorTemplateManager (EA-level), so that part can't be pushed down the same way.
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      if(templateManager == NULL) return false;
      CIndicatorSetting *entry = templateManager.At((int)lparam);
      if(entry == NULL) return false;
      ENUM_INDICATOR type = entry.TypeEnum();
      MqlParam params[];
      entry.GetRawParams(params);
      this.AddNewIndicatorToAllSeries(type, params);
      return true;
     }
    if(id != CHARTEVENT_CHART_CHANGE) return false;
    string sym          = ::Symbol();
    ENUM_TIMEFRAMES curr = (ENUM_TIMEFRAMES)::ChartPeriod(0);
    // --- "tay nao lo viec tay ay" (Anhnt, 2026-08-30): this handler used to only touch its own
    // --- Layer 1 Series, silently relying on OnInit()'s REASON_CHARTCHANGE reinit to register the
    // --- pair into SymbolTFManager elsewhere. But CHARTEVENT_CHART_CHANGE also fires for lighter
    // --- chart-state changes that never trigger a full reinit (e.g. switching focus between
    // --- already-open chart tabs) - in those cases nothing else was ensuring the Symbol+TF Settings
    // --- row exists, silently leaving Buy/Sell gated off (FindByIdentity returns NULL) despite
    // --- Layer 1 data being tracked. Registering here too is exactly Add_SymbolTFSetting's own
    // --- "NULL if identity already exists" idempotency doing the work - safe to call unconditionally.
    if(manager != NULL && !manager.Exists(sym, curr))
       manager.Add_SymbolTFSetting(sym, curr);
    // Step 1: Ensure series exists
    bool is_new_series = !this.m_BarTimeSeriesCollection.IsAvailable(sym, curr);
    if(is_new_series)
      {
        this.m_BarTimeSeriesCollection.CreateSeries(sym, curr);
        // Step 2: Apply the full Candle Pattern registry to the newly created series
        // (Anhnt, 2026-08-10: was commented out - new TFs switched to on the chart never
        // got pattern detection wired, same bug as the JSON-load path).
        // --- Inlined (Anhnt, 2026-08-29): CBarPatternsControl already carries its own
        // --- symbol/timeframe, so it can self-register directly - no need to look the series
        // --- back up via a separate SeriesApplyPatternRegistry() helper.
        {
         CBarTimeSeriesDE *bts = this.m_BarTimeSeriesCollection.GetTimeseries(sym);
         CBarSeriesDE *s = (bts != NULL) ? bts.GetSeries(curr) : NULL;
         CBarPatternsControl *ctrl = (s != NULL) ? s.GetPatternsCtrlObj() : NULL;
         if(ctrl != NULL) ctrl.RegisterAllKnownPatterns();
        }
        // Direction 2: replicate the already-established indicator template (from
        // CIndicatorTemplateManager, Single Source of Truth) into this brand new series
        this.AddAllIndicatorsToNewSeries(sym, curr, templateManager);
      }
    else
     {
      //this.ScanAndApplyIndicators();// Direction 1: detect newly-added indicator types on chart
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
