//+------------------------------------------------------------------+
//|                                   TimeSeriesEngine_Indicator.mqh |
//+------------------------------------------------------------------+
//Function related to Indicator in Layer 1

#ifndef CTIMESERIESENGINE_INDICATOR_MQH
#define CTIMESERIESENGINE_INDICATOR_MQH
#include "TimeSeriesEngine.mqh"
#include "..\Services\IndicatorTemplateManager.mqh"   // CIndicatorTemplateManager - AddAllIndicatorsToNewSeries reads it LIVE 
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
      CIndicatorDE *indicator = m_IndicatorsCollection.CreateIndicator(type, params, s.Symbol(), s.Timeframe());
      if(indicator == NULL) continue;
      int handle = m_IndicatorsCollection.AddIndicatorToList(indicator, WRONG_VALUE, buffers_total);
      if(handle == INVALID_HANDLE) continue;
      created_any = true;
      // 'indicator' may be dangling here (AddIndicatorToList deletes it on a duplicate) -
      // never touch it again; re-acquire the canonical instance by IDENTITY (Anhnt, 2026-08-28).
      CIndicatorDE *canonical = GetIndicatorByIdentity(s.Symbol(), s.Timeframe(), type, params);
      if(canonical != NULL)
      m_SignalsCollection.GetOrCreateSignal(canonical);
     }
    }
    return created_any;
  } 
 void CTimeSeriesEngine::RemoveIndicatorFromAllSeries(const ENUM_INDICATOR type, MqlParam &params[])
  {
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
 void CTimeSeriesEngine::AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                      CIndicatorTemplateManager *manager)
  {    
   if(manager == NULL) return;
   if(!m_BarTimeSeriesCollection.IsAvailable(symbol, timeframe)) return;
   CBarSeriesDE *target_series = m_BarTimeSeriesCollection.GetSeries(symbol, timeframe);
   string safe_symbol = target_series.Symbol();
   int tmpl_total = manager.Total();
   if(tmpl_total == 0) return; // nothing tracked yet
   int created_count = 0, failed_create = 0, skipped_no_raw = 0;
   for(int i = 0; i < tmpl_total; i++)
    {
     CIndicatorSetting *entry = manager.At(i);
     if(entry == NULL) continue;
     MqlParam raw_params[];
     entry.GetRawParams(raw_params);
     if(ArraySize(raw_params) == 0) { skipped_no_raw++; continue; }
     int buffers_total = GetIndicatorBuffersTotal(entry.TypeEnum());
     CIndicatorDE *new_ind = m_IndicatorsCollection.CreateIndicator(entry.TypeEnum(), raw_params,
                                                                     safe_symbol, target_series.Timeframe());
     if(new_ind == NULL) { failed_create++; continue; }
     int add_result = m_IndicatorsCollection.AddIndicatorToList(new_ind, WRONG_VALUE, buffers_total);
     if(add_result == INVALID_HANDLE) { failed_create++; continue; }
     // 'new_ind' may be dangling here (deleted by AddIndicatorToList on duplicates) -
     CIndicatorDE *canonical = GetIndicatorByIdentity(safe_symbol, target_series.Timeframe(), entry.TypeEnum(), raw_params);
     if(canonical != NULL)
            m_SignalsCollection.GetOrCreateSignal(canonical);
         created_count++;
    }
    Print("CTimeSeriesEngine::AddAllIndicatorsToNewSeries > created ", created_count, "/", tmpl_total,
            " for ", safe_symbol, " ", EnumToString(target_series.Timeframe()),
            skipped_no_raw > 0 ? (" (" + IntegerToString(skipped_no_raw) + " skipped: no raw_params)") : "");
  }
 //+------------------------------------------------------------------+
 //| Re-acquire a just-added-or-deduped indicator by its RAW identity  |
 //| (symbol, tf, type, params) - NOT by handle (V9 leftover, removed  |
 //| 2026-08-28, see declaration comment in TimeSeriesEngine.mqh).     |
 //+------------------------------------------------------------------+
 CIndicatorDE *CTimeSeriesEngine::GetIndicatorByIdentity(const string symbol, const ENUM_TIMEFRAMES tf,
                                                          const ENUM_INDICATOR type, MqlParam &params[])
  {
   CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(symbol);
   ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
   int total = (ind_list != NULL) ? ind_list.Total() : 0;
   for(int i = 0; i < total; i++)
     {
      CIndicatorDE *ind = ind_list.At(i);
      if(ind == NULL || ind.TypeIndicator() != type) continue;
      MqlParam ind_params[];
      ind.GetMqlParams(ind_params);
      if(IsEqualMqlParamArrays(ind_params, params)) return ind;
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
#endif // CTIMESERIESENGINE_INDICATOR_MQH
