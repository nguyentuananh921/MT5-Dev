//+------------------------------------------------------------------+
//|                                   TimeSeriesEngine_Indicator.mqh |
//+------------------------------------------------------------------+
//Function related to Indicator in Layer 1

#ifndef CTIMESERIESENGINE_INDICATOR_MQH
#define CTIMESERIESENGINE_INDICATOR_MQH
#include "TimeSeriesEngine.mqh"
CIndicatorDE *CTimeSeriesEngine::GetIndicatorByHandle(const int handle)
  {
   if(handle == INVALID_HANDLE) return NULL;
    CArrayObj *all = m_IndicatorsCollection.GetList();
    if(all == NULL) return NULL;
    for(int i = all.Total() - 1; i >= 0; i--)
      {
       CIndicatorDE *indicator = all.At(i);
       if(indicator != NULL && indicator.Handle() == handle) return indicator;
      }
    return NULL;
   }
  void CTimeSeriesEngine::ProcessNewBarSignalEvents(void)
   {
    CArrayObj *events = m_BarTimeSeriesCollection.GetListEvents();
    if(events == NULL) return;
    int total = events.Total();
    for(int i = 0; i < total; i++)
      {
       CEventBaseObj *ev = events.At(i);
       if(ev == NULL || ev.ID() != SERIES_EVENTS_NEW_BAR) continue;
       m_SignalsCollection.FreezeClosedBar(ev.SParam(), (ENUM_TIMEFRAMES)(int)ev.DParam());
      }
   }  
 //+------------------------------------------------------------------+
 //| Tang 1: apply one indicator type+params to every (symbol,        |
 //| timeframe) series that already exists right now. Called when     |
 //| user adds a new indicator via GUI (Layer 2 -> Layer 1 bridge).   |
 //| Properly registers each created indicator via AddIndicatorToList |
 //| (sets buffers_total + actually creates its data series) - the    |
 //| raw CreateIndicator() alone only allocates the handle/object and |
 //| never adds it to m_list, so GetListIndBySymbol() would never see |
 //| it and the object would leak.                                    |
 //+------------------------------------------------------------------+
  bool CTimeSeriesEngine::AddNewIndicatorToAllSeries(const ENUM_INDICATOR type, MqlParam &params[])
   {
    int buffers_total = GetIndicatorBuffersTotal(type);
    int mw_total = ::SymbolsTotal(true);
    bool created_any = false;
    for(int i = 0; i < mw_total; i++)
      {
       string sym_name = ::SymbolName(i, true);
       CBarTimeSeriesDE *bts  = m_BarTimeSeriesCollection.GetTimeseries(sym_name);
       CArrayObj        *list = (bts != NULL) ? bts.GetListSeries() : NULL;
       int tf_cnt = (list != NULL) ? list.Total() : 0;
       if(tf_cnt == 0) continue;
       for(int k = 0; k < tf_cnt; k++)
         {
          CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
          if(s == NULL) continue;
          // Source symbol from the CBarSeriesDE object itself (reliable, never observed to
          // drift) rather than sym_name (the loop variable from ::SymbolName()) - CIndicatorDE's
          // own Symbol() has been observed to silently drift when fed a string traced back to
          // a raw ::Symbol()/::SymbolName() call chain instead of a stable object's accessor.
          CIndicatorDE *indicator = m_IndicatorsCollection.CreateIndicator(type, params, s.Symbol(), s.Timeframe());
          if(indicator == NULL) continue;
          int handle = m_IndicatorsCollection.AddIndicatorToList(indicator, WRONG_VALUE, buffers_total);
          if(handle == INVALID_HANDLE) continue;
          created_any = true;
          // 'indicator' may be dangling here (deleted by AddIndicatorToList on duplicates) -
          // never touch it again; work with the canonical instance re-acquired by handle
          CIndicatorDE *canonical = GetIndicatorByHandle(handle);
          if(canonical != NULL)
             m_SignalsCollection.GetOrCreateSignal(canonical);
         }
      }
    return created_any;
   }
 //+------------------------------------------------------------------+
 //| Tang 1: new Series created -> copy ALL indicators from template. |
 //| When a (symbol, timeframe) series is freshly created, push every |
 //| indicator from the current live template (= JSON-loaded set +    |
 //| any runtime additions) into it.                                  |
 //| Uses all.At(0) as reference: invariant = all (sym,tf) pairs have |
 //| the same indicator set (template), so any entry is representative.|
 //+------------------------------------------------------------------+
  void CTimeSeriesEngine::AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
    // Source symbol/timeframe from the CBarSeriesDE object itself (m_BarTimeSeriesCollection),
    // not from the symbol/timeframe parameters (which trace back to a raw ::Symbol()/
    // ::Period() call chain in OnInit/OnChartEvent). CBarSeriesDE::Symbol() has never been
    // observed to drift; CIndicatorDE::Symbol() has, whenever it was fed a string sourced
    // from that raw call chain instead of a stable object's own accessor.
     if(!m_BarTimeSeriesCollection.IsAvailable(symbol, timeframe)) return;
     CBarSeriesDE *target_series = m_BarTimeSeriesCollection.GetSeries(symbol, timeframe);     
     string safe_symbol = target_series.Symbol();
     CArrayObj *all = m_IndicatorsCollection.GetList();
     if(all == NULL || all.Total() == 0)
        return; // nothing in PureData yet - LoadIndicatorsFromJson seeds it first
     // Pick the first entry as the reference: guaranteed to be a different (sym, tf)
     // because (symbol, timeframe) is freshly created and has no entries here yet.
      CIndicatorDE *ref_entry = all.At(0);
      if(ref_entry == NULL) return;
      string          ref_sym = ref_entry.Symbol();
      ENUM_TIMEFRAMES ref_tf  = ref_entry.Timeframe();
     // Retrieve the complete indicator set for the reference (sym, tf) - this list IS the template.
      CArrayObj *templates = m_IndicatorsCollection.GetListIndBySymbol(ref_sym);
      templates = CTimeseriesSelect::ByIndicatorProperty(templates, INDICATOR_PROP_TIMEFRAME, ref_tf, EQUAL);
      if(templates == NULL || templates.Total() == 0) return;
     // NOTE: no "does it already exist" guard here on purpose. The caller (OnInitEvent /
     // OnChartEvent) only reaches this function after confirming via m_BarTimeSeriesCollection.IsAvailable()
     // that (symbol, timeframe) is brand new, so every template entry below is guaranteed absent.
     // (A prior "belt-and-suspenders" existing-check used to live here, filtering by Symbol() -
     // it was removed because Symbol() was observed to read back the wrong value for previously
     // created indicators under investigation, which made the guard skip real creations.)
      int created_count = 0, failed_create = 0;
      for(int i = 0; i < templates.Total(); i++)
       {
        CIndicatorDE *tmpl = templates.At(i);
        if(tmpl == NULL) continue;

        ENUM_INDICATOR ind_type = tmpl.TypeIndicator();
        MqlParam       params[];
        tmpl.GetMqlParams(params);
        CIndicatorDE * new_ind = m_IndicatorsCollection.CreateIndicator(ind_type, params, safe_symbol, target_series.Timeframe());
        if(new_ind == NULL) { failed_create++; continue; }
        int add_result = m_IndicatorsCollection.AddIndicatorToList(new_ind, WRONG_VALUE, tmpl.BuffersTotal());
        if(add_result == INVALID_HANDLE) { failed_create++; continue; }
        // 'new_ind' may be dangling here (deleted by AddIndicatorToList on duplicates) -
        // never touch it again; work with the canonical instance re-acquired by handle
         CIndicatorDE *canonical = GetIndicatorByHandle(add_result);
         if(canonical != NULL)
            m_SignalsCollection.GetOrCreateSignal(canonical);
         created_count++;
      }
   } 
#endif // CTIMESERIESENGINE_INDICATOR_MQH
