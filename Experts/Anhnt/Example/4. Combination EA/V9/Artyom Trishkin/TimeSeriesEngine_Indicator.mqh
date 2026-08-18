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
       if(ev == NULL) continue;
       if(ev.ID() != SERIES_EVENTS_NEW_BAR) continue;
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
    // --- Register this template in the identity-only live mirror (SynIndicatorPlan.md,
    // --- 2026-08-17) - single write point covering ALL 3 sources that reach this function
    // --- (GUI Add / Chart Import / JSON load), guarded so a duplicate call (shouldn't normally
    // --- happen - callers already dedup before this) can't accumulate a repeated entry.
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     string type_key, params_key;
     BuildTemplateMatchKey(type, params, catalog, type_key, params_key);
     if(!TemplateExists(type_key, params_key))
      {
       int tn = ArraySize(m_indicator_template);
       ArrayResize(m_indicator_template, tn + 1);
       m_indicator_template[tn].type       = type_key;
       m_indicator_template[tn].params_key = params_key;
      }

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
 //| L1.Task1 (Delete), symmetric to AddNewIndicatorToAllSeries/L1.Task2 above       |
 //| (SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18). Previously this    |
 //| loop lived directly inside CGUIPannel::OnClickRemoveIndicator (Layer 2 file    |
 //| reaching into CIndicatorsCollection itself) - Layer 1 now owns its own writes, |
 //| same as Add already did. No chart/window knowledge here at all (matches       |
 //| AddNewIndicatorToAllSeries never touching the chart either) - the caller       |
 //| (Layer 2) is responsible for detaching any chart display FIRST, before this    |
 //| runs, via DetachIndicatorFromChart.                                            |
 //+------------------------------------------------------------------+
  void CTimeSeriesEngine::RemoveIndicatorFromAllSeries(const ENUM_INDICATOR type, MqlParam &params[])
   {
    // --- Remove from the live identity-only mirror first - same key-building
    // --- AddNewIndicatorToAllSeries uses at its own top.
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     string type_key, params_key;
     BuildTemplateMatchKey(type, params, catalog, type_key, params_key);
     RemoveIndicatorTemplate(type_key, params_key);

    CArrayObj *list = m_IndicatorsCollection.GetList();
    if(list == NULL) return;
    for(int i = list.Total() - 1; i >= 0; i--)
      {
       // indicator is BORROWED (CIndicatorsCollection owns it via 'list' FreeMode)
        CIndicatorDE *indicator = list.At(i);
        if(indicator == NULL || indicator.TypeIndicator() != type) continue;
       // --- Same template = same type + same params, regardless of symbol/TF
        MqlParam inst_params[];
        indicator.GetMqlParams(inst_params);
        if(!IsEqualMqlParamArrays(inst_params, params)) continue;
       // --- Release the Signal FIRST: CSignalsCollection borrows this indicator's
       // --- pointer (m_indicator_list[] + the signal's own m_indicator), so deleting
       // --- the indicator before its signal would leave both dangling.
        m_SignalsCollection.DeleteSignal(indicator);
        list.Delete(i);   // CArrayObj FreeMode -> ~CIndicatorDE -> IndicatorRelease(handle)
      }
   }
 //+------------------------------------------------------------------+
 //| Live m_indicator_template[] mirror - existence check (SynIndicatorPlan.md, 2026-08-17). |
 //| Replaces the old approach of checking CIndicatorsCollection.m_list (every symbol/TF     |
 //| instance, e.g. 35 entries for 2 symbols x avg 3.5 TF x 5 templates) with checking this   |
 //| identity-only mirror instead (just the 5 templates in that example) - Template identity  |
 //| is symbol/TF-invariant, so the old approach re-checked the same comparison many times   |
 //| for nothing.                                                                              |
 //+------------------------------------------------------------------+
  bool CTimeSeriesEngine::TemplateExists(const string type_key, const string params_key)
   {
    for(int i = 0; i < ArraySize(m_indicator_template); i++)
      if(m_indicator_template[i].type == type_key && m_indicator_template[i].params_key == params_key)
         return true;
    return false;
   }
 //+------------------------------------------------------------------+
 //| Removes 1 entry from the live m_indicator_template[] mirror by (type_key, params_key). |
 //| Called from CGUIPannel::OnClickRemoveIndicator() - the only place a whole template     |
 //| (all symbol/TF instances) gets deleted from CIndicatorsCollection.                       |
 //+------------------------------------------------------------------+
  void CTimeSeriesEngine::RemoveIndicatorTemplate(const string type_key, const string params_key)
   {
    for(int i = 0; i < ArraySize(m_indicator_template); i++)
      if(m_indicator_template[i].type == type_key && m_indicator_template[i].params_key == params_key)
       {
        int last = ArraySize(m_indicator_template) - 1;
        for(int r = i; r < last; r++)
           m_indicator_template[r] = m_indicator_template[r + 1];
        ArrayResize(m_indicator_template, last);
        return;
       }
   }
 //+------------------------------------------------------------------+
 //| Tang 1: new Series created -> copy ALL indicators from template. |
 //| When a (symbol, timeframe) series is freshly created, push every |
 //| indicator from the current live template (= JSON-loaded set +    |
 //| any runtime additions) into it.                                  |
 //| SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18: template|
 //| set comes from the LIVE identity mirror m_indicator_template[]   |
 //| (canonical, instance-independent) - NOT from picking all.At(0) as |
 //| an arbitrary "reference" instance and re-deriving ITS (sym,TF)    |
 //| template set (old pattern - fragile ordering assumption, and the |
 //| exact bug class just found/fixed in SaveConfigurationToJSON).     |
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
     int tmpl_total = ArraySize(m_indicator_template);
     if(tmpl_total == 0) return; // nothing in PureData yet - LoadIndicatorsFromJson seeds it first
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     CArrayObj *all = m_IndicatorsCollection.GetList();
     int all_total = (all != NULL) ? all.Total() : 0;
     // NOTE: no "does it already exist" guard here on purpose. The caller (OnInitEvent /
     // OnChartEvent) only reaches this function after confirming via m_BarTimeSeriesCollection.IsAvailable()
     // that (symbol, timeframe) is brand new, so every template entry below is guaranteed absent.
     // (A prior "belt-and-suspenders" existing-check used to live here, filtering by Symbol() -
     // it was removed because Symbol() was observed to read back the wrong value for previously
     // created indicators under investigation, which made the guard skip real creations.)
      int created_count = 0, failed_create = 0;
      for(int i = 0; i < tmpl_total; i++)
       {
        string want_type_key   = m_indicator_template[i].type;
        string want_params_key = m_indicator_template[i].params_key;
        // --- Representative instance for this identity - ANY existing symbol/TF works, params
        // --- are identical across all of them by the Template invariant.
         CIndicatorDE *tmpl = NULL;
         for(int r = 0; r < all_total; r++)
          {
           CIndicatorDE *cand = all.At(r);
           if(cand == NULL) continue;
           string cand_type_key, cand_params_key;
           BuildTemplateMatchKey(cand, catalog, cand_type_key, cand_params_key);
           if(cand_type_key == want_type_key && cand_params_key == want_params_key) { tmpl = cand; break; }
          }
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
