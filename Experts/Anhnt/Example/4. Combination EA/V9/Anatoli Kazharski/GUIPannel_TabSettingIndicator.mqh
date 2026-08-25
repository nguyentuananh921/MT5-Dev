//+------------------------------------------------------------------+
//|                                GUIPannel_TabSettingIndicator.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGINDICATOR_MQH
#define CGUIPANNEL_TABSETTINGINDICATOR_MQH
#include "GUIPannel.mqh" 

 //Update Setting
 //+------------------------------------------------------------------------------------+
 //| True when (type,params) already exists as a row in m_indicator_template_setting[] -|
 //| RAW compare (.type_enum/.raw_params[]), same style TemplateBuySellFor already uses.|
 //| Text (.type/.params[]) is display-only, for the table - never the comparison key.  |
 //+------------------------------------------------------------------------------------+
 bool CGUIPannel::IsIndicatorInTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
  {
   for(int row = 0; row < ArraySize(m_indicator_template_setting); row++)
    {
     if(m_indicator_template_setting[row].type_enum != type) continue;
     if(IsEqualMqlParamArrays(m_indicator_template_setting[row].raw_params, params)) return true;
    }
   return false;
  }
 //+------------------------------------------------------------------------------------+
 //| True when the CURRENT chart displays a line matching (type,params) - scans every   |
 //| Layer 3 line directly, RAW compare (no CIndicatorDE instance, no text key needed). |
 //+------------------------------------------------------------------------------------+
 bool CGUIPannel::IsIndicatorShownOnChart(const ENUM_INDICATOR type, MqlParam &params[])
  {
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return false;
    for(int win = 0; win < chart.WindowsTotal(); win++)
    {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
        {
        CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
        if(wnd_ind == NULL) continue;
        ENUM_INDICATOR line_type;
        MqlParam line_params[];
        if(IndicatorParameters(wnd_ind.Handle(), line_type, line_params) < 0) continue;
        if(line_type == type && IsEqualMqlParamArrays(line_params, params))
           return true;
        }
    }
    return false;
  }
 //+------------------------------------------------------------------------------------+
 //| Identity-based Delete, symmetric to AddIndicatorToTemplateSetting() above. Removes  |
 //| ONE row from m_indicator_template_setting[] (Single Source of Truth). Mutates       |
 //| m_indicator_template_setting[]/PureData ONLY - Layer 1 delete, Layer 3 detach, view |
 //| resync are ALL the caller's job now (OnClickRemoveIndicator / SynIndicatorOnChart), |
 //| same split AddIndicatorToTemplateSetting() already uses. Does NOT touch the JSON    |
 //| file - persisting the removal so it doesn't come back on next EA restart is still   |
 //| open, deferred.                                                                     |
 //+------------------------------------------------------------------------------------+
 void CGUIPannel::RemoveIndicatorFromTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
  {
   int tmpl_total = ArraySize(m_indicator_template_setting);
   // --- Find the row first (need its index before we can shift anything) - inlined here since
   // --- this is the only caller left, no need for a separate GetRowForIdentity() method.
    int row = -1;
    for(int i = 0; i < tmpl_total; i++)
      if(m_indicator_template_setting[i].type_enum == type &&
         IsEqualMqlParamArrays(m_indicator_template_setting[i].raw_params, params))
        { row = i; break; }
   if(row < 0) { ::Print(__FUNCTION__, " > rejected: no table row for this identity"); return; }
   //--- Audit line: template removals are destructive and reachable from several paths
   //--- (X icon, SynIndicatorOnChart's CHANGE branch) - always log who goes and from which row
    ::Print(__FUNCTION__, " > row=", row, " '", m_indicator_template_setting[row].type, "'");
    for(int i = row; i < tmpl_total - 1; i++)
       m_indicator_template_setting[i] = m_indicator_template_setting[i + 1];
    ArrayResize(m_indicator_template_setting, tmpl_total - 1);
  }
 //+------------------------------------------------------------------------------------+
 //| Identity-based Add, symmetric to RemoveIndicatorFromTemplateSetting() - appends    |
 //| ONE new row to m_indicator_template_setting[] (Single Source of Truth), text+RAW   |
 //| both filled. Mutates m_indicator_template_setting[]/PureData ONLY - existence-     |
 //| check, Layer 1 create, Layer 3 show, view resync are the caller's job (see         |
 //| OnClickAddIndicatorBtn / SynIndicatorOnChart) - "Layer 2 decides, Layer 1 obeys":   |
 //| Data changes first, caller commands Layer 1 to catch up AFTER, same order          |
 //| RemoveIndicatorFromTemplateSetting() already uses.                                 |
 //+------------------------------------------------------------------------------------+
 void CGUIPannel::AddIndicatorToTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
  {
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   string type_key, params_key;   // DISPLAY TEXT only, for the table/JSON - not an identity key
   BuildTemplateMatchKey(type, params, catalog, type_key, params_key);
   int new_row = ArraySize(m_indicator_template_setting);
   ArrayResize(m_indicator_template_setting, new_row + 1);
   m_indicator_template_setting[new_row].type = type_key;
   string params_text[];
   BuildIndicatorParamsText(type, params, params_text);
   ArrayResize(m_indicator_template_setting[new_row].params, ArraySize(params_text));
   for(int p = 0; p < ArraySize(params_text); p++)
      m_indicator_template_setting[new_row].params[p] = params_text[p];
   m_indicator_template_setting[new_row].type_enum = type;
   ArrayResize(m_indicator_template_setting[new_row].raw_params, ArraySize(params));
   for(int p = 0; p < ArraySize(params); p++)
      m_indicator_template_setting[new_row].raw_params[p] = params[p];
   m_indicator_template_setting[new_row].buy     = true;
   m_indicator_template_setting[new_row].sell    = true;
   m_indicator_template_setting[new_row].sound   = true;
   m_indicator_template_setting[new_row].message = true;
  }
 //+-------------------------------------------------------------------------+  
 //| "Add" button click handler — converts text fields to MqlParam[]         |  
 //| Called after any ShowTabElements() that overrides our Hide()            |  
 //+-------------------------------------------------------------------------+
 void CGUIPannel::OnClickAddIndicatorBtn(void)
   {      
    SIndicatorParam schema[];
    int total = GetIndicatorParamSchema(m_current_param_type, schema);      
    if(total == 0) return;
    MqlParam params[];
    ArrayResize(params, total);
    for(int i = 0; i < total; i++)
     {
      params[i].type = schema[i].data_type;
      if(schema[i].choices != "")
       {
        // --- Enum param: read back the SELECTED TEXT, then let the Library's own
        // --- Xxx-ByDescription() (CommonDELib.mqh) resolve it to the real MQL5
        // --- enum value - no combo-row/native-value arithmetic anywhere.
         string parts[];
         int n = ::StringSplit(schema[i].choices, '|', parts);
         int sel = (int)m_param_combo[i].GetListViewPointer().SelectedItemIndex();
         string sel_text = (sel >= 0 && sel < n) ? parts[sel] : "";
         if(schema[i].choices == PRICE_CHOICES)
            params[i].integer_value = (long)AppliedPriceByDescription(sel_text);
         else if(schema[i].choices == CALCULATION_METHOD_CHOICES)
            params[i].integer_value = (long)AveragingMethodByDescription(sel_text);
         else if(schema[i].choices == VOLUME_CHOICES)
            params[i].integer_value = (long)AppliedVolumeByDescription(sel_text);
         else if(schema[i].choices == STOCH_PRICE_CHOICES)
            params[i].integer_value = (long)StochPriceByDescription(sel_text);
       }
      else if(schema[i].data_type == TYPE_DOUBLE)
       {
        params[i].double_value = StringToDouble(m_param_edits[i].GetValue());
       }
      else
       {
        params[i].integer_value = (long)StringToInteger(m_param_edits[i].GetValue());
       }      
     }
    // --- Existence-check on Data first (AddIndicatorToTemplateSetting no longer does this itself).
     if(IsIndicatorInTemplateSetting(m_current_param_type, params))
      {
       ::Print(__FUNCTION__, " > rejected: this template already exists");
       return;
      }
    // --- "Layer 2 decides, Layer 1 obeys": Data changes FIRST (Single Source of Truth), Layer 1
    // --- commands AFTER to catch up - same order RemoveIndicatorFromTemplateSetting() already uses.
     AddIndicatorToTemplateSetting(m_current_param_type, params);
     if(m_time_series_engine != NULL)
        m_time_series_engine.AddNewIndicatorToAllSeries(m_current_param_type, params);
    // --- Show on the current chart immediately - BEFORE RefreshTableIndicator() below so this
    // --- row's first paint of the Show column already reads correct, not stale-Hidden.
     if(m_time_series_engine != NULL)
      {
       int handle = m_time_series_engine.GetIndicatorHandle(::Symbol(), (ENUM_TIMEFRAMES)::ChartPeriod(0),
                      m_current_param_type, params);
       if(handle != INVALID_HANDLE)
        {
         int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
         ENUM_INDICATOR_GROUP group = GetIndicatorGroupForType(m_current_param_type);
         int sub_window = (group == INDICATOR_GROUP_TREND) ? 0 : subwindows;
         ::Print("MY DEBUG CGUIPannel::OnClickAddIndicatorBtn: ChartIndicatorAdd handle=", handle);
         ChartIndicatorAdd(0, sub_window, handle);
        }
      }
     SyncIndicatorTreeViewIcons();
     RefreshTableIndicator();
    // --- Refresh the Bridge's own template copy so this new row's default buy/sell=true
    // --- is actually recognized by TemplateBuySellFor on the very next tick, not just after some
    // --- later checkbox toggle happens to call this (same fix as RemoveIndicatorFromTemplateSetting).
     SyncIndicatorTemplateSettingToBridge();
     ChartRedraw();
   }
 //+-----------------------------------------------------------------------------+
 //| Layer 2/3 concern (chart display) - takes RAW (type,params) identity        |
 //| straight from Data, no CIndicatorDE/Layer 1 instance needed. Matched by     |
 //| type+params (via IndicatorParameters on each line), not by name - two       |
 //| instances of the same type with different params can share the same        |
 //| native chart-assigned name.                                                  |
 //| Detaches every chart line currently representing this identity. Shared by  |
 //| the per-row Hide toggle, per-row Remove, and OnDeinitEvent's full sweep.    |
 //+-----------------------------------------------------------------------------+
 void CGUIPannel::RemoveIndicatorFromChart(const ENUM_INDICATOR type, MqlParam &params[])
  {
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) { Print("MY DEBUG CGUIPannel::RemoveIndicatorFromChart: chart=NULL for ChartID=", ::ChartID()); return; }
    int debug_deleted = 0;
    for(int win = chart.WindowsTotal() - 1; win >= 0; win--)
     {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int i = wnd.IndicatorsTotal() - 1; i >= 0; i--)
       {
        CWndInd *wnd_ind = wnd.GetIndicatorByIndex(i);
        if(wnd_ind == NULL) continue;
        ENUM_INDICATOR line_type;
        MqlParam line_params[];
        if(IndicatorParameters(wnd_ind.Handle(), line_type, line_params) < 0) continue;
        if(line_type == type && IsEqualMqlParamArrays(line_params, params))
          {
           Print("MY DEBUG CGUIPannel::RemoveIndicatorFromChart: deleting win=", win, " name='", wnd_ind.Name(), "' line_handle=", wnd_ind.Handle());
           ChartIndicatorDelete(0, win, wnd_ind.Name());
           debug_deleted++;
          }
       }
     }
    Print("MY DEBUG CGUIPannel::RemoveIndicatorFromChart: windows=", chart.WindowsTotal(), " deleted=", debug_deleted);
  }
 //+------------------------------------------------------------------------------------+
 //| Startup-only: no single ADD event to key off of at OnInit time (possibly several   |
 //| indicators got hand-attached while the EA was off) - full window/line scan. Layer 1|
 //| create is NOT done here - OnInitEvent runs ONE consolidated AddAllIndicatorsToNewSeries|
 //| pass after this returns, covering both JSON-sourced AND chart-discovered rows      |
 //| together (GUIPannel_Lifecycle.mqh).                                                |
 //+------------------------------------------------------------------------------------+
 void CGUIPannel::ScanIndicatorOnChartOnInit(void)
  {
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return;
    bool found_new = false;
    for(int win = 0; win < chart.WindowsTotal(); win++)
     {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
         ScanIndicatorOnChartIntoTemplateSetting(wnd.GetIndicatorByIndex(k));
     }    
  }
 // --- Layer 3 -> Layer 1/2 sync, single entry point (Anhnt, 2026-08-18, see SynIndicatorPlan.md
 // --- "3 UseCase" discussion) for the 3 ways a chart-side edit can reach here:
 // --- UseCase 1 (re-Insert an existing/possibly-hidden template by hand): ScanIndicatorOnChart()
 // --- already no-ops for this (IsIndicatorInTemplateSetting() true) - nothing written to the
 // --- array; RefreshIndicatorTableShowColumn() below re-truths the Show checkbox live off the
 // --- chart scan regardless (IsIndicatorShownOnChart/LineRepresentsIndicator fall back to
 // --- type+params match, so it flips ON even if MT5 assigned the re-inserted line a new handle).
 // --- UseCase 2 (style/color only): never reaches this function's CHANGE branch at all - Library's
 // --- CChartWnd::IndicatorsChangeCheck only fires IND_CHANGE when the tracked indicator's NAME
 // --- actually disappears from the window (i.e. a real param edit assigned a new handle) - a pure
 // --- style edit is a non-event by construction, nothing to special-case here.
 // --- UseCase 3 (real param edit on chart): replace the whole old template with the new one -
 // --- former standalone HandleChartIndicatorChange() body, inlined here since this dispatch was
 // --- its only caller. Trishkin's change-check kept a COPY of the old mirror entry (old
 // --- name+handle) in m_list_ind_param and updated the live mirror entry in place with the new
 // --- name+handle at the same window/index. So: old handle -> the exact Layer 1 template to
 // --- replace; the live mirror entry at the same index -> the new params.
 void CGUIPannel::SynIndicatorOnChart(const long id, const int win_num)
  {
    if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD)
       ScanIndicatorOnChart(win_num);
    else if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE && m_time_series_engine != NULL)
     {
      // --- do/while(false): break plays the role of the original method's early-return guard
      // --- clauses, so this inlined body keeps the exact same shape it had as its own function.
      do
       {
        CWndInd *old_ind = m_chart_obj_collection.GetLastChangedIndicator();
        //--- Every exit path reports itself: chart edits are rare, user-driven events and
        //--- each outcome (replace/skip/fail) is worth an audit line in the log
         if(old_ind == NULL) { ::Print(__FUNCTION__, " > no changed-indicator record"); break; }
         ::Print(__FUNCTION__, " > chart edit detected: old '", old_ind.Name(), "' handle=", old_ind.Handle(),
                  " win=", old_ind.WindowNum(), " index=", old_ind.Index());
        // A hand-added line is a SEPARATE terminal instance - fall back to type+params matching
        // against our own Data (README.md muc 7.b: Layer 2 checks its own m_indicator_template_setting[]
        // instead of asking Layer 1). Truly foreign lines (no matching template) are skipped:
        // the ADD/import path picks the new line up by itself.
        // --- Inlined LineRepresentsIndicator (its only caller): fast path checks the Layer 1
        // --- handle Layer 1 assigned this row's instance; slow path reads the line's own
        // --- (type,params) via IndicatorParameters and matches straight against Data - no live
        // --- CIndicatorDE needed either way (proven 18:58 log: line handle=17 vs owned=18 for
        // --- identical SAR(0.05,0.20), so the fast path alone isn't always enough).
         int owned_row = -1;
         for(int row = 0; row < ArraySize(m_indicator_template_setting); row++)
          {
           int row_handle = (m_time_series_engine != NULL) ?
              m_time_series_engine.GetIndicatorHandle(::Symbol(), (ENUM_TIMEFRAMES)::ChartPeriod(0),
                 m_indicator_template_setting[row].type_enum, m_indicator_template_setting[row].raw_params) :
              INVALID_HANDLE;
           if(row_handle != INVALID_HANDLE && row_handle == old_ind.Handle()) { owned_row = row; break; }
           ENUM_INDICATOR line_type;
           MqlParam line_params[];
           if(IndicatorParameters(old_ind.Handle(), line_type, line_params) < 0) continue;
           if(line_type != m_indicator_template_setting[row].type_enum) continue;
           if(IsEqualMqlParamArrays(line_params, m_indicator_template_setting[row].raw_params)) { owned_row = row; break; }
          }
         if(owned_row < 0) { ::Print(__FUNCTION__, " > line matches no Layer 1 template - skip"); break; }
         CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
         if(chart == NULL) { ::Print(__FUNCTION__, " > no CChartObj for this chart"); break; }
         CChartWnd *wnd = chart.GetWindowByNum(old_ind.WindowNum());
         if(wnd == NULL) { ::Print(__FUNCTION__, " > no CChartWnd num=", old_ind.WindowNum()); break; }
         CWndInd *new_ind = NULL;
         for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
          {
           CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
           if(wnd_ind != NULL && wnd_ind.Index() == old_ind.Index()) { new_ind = wnd_ind; break; }
          }
         if(new_ind == NULL || new_ind.Handle() == INVALID_HANDLE)
          { ::Print(__FUNCTION__, " > no mirror entry at window index ", old_ind.Index()); break; }
         ENUM_INDICATOR new_type;
         MqlParam new_params[];
         if(IndicatorParameters(new_ind.Handle(), new_type, new_params) < 0)
          { ::Print(__FUNCTION__, " > IndicatorParameters failed, err ", GetLastError()); break; }
         // --- Capture the OLD identity into plain values NOW, before RemoveIndicatorFromTemplateSetting
         // --- below splices owned_row out of the array - read straight off Data, no live pointer
         // --- to go dangling.
          ENUM_INDICATOR old_type = m_indicator_template_setting[owned_row].type_enum;
          MqlParam old_params[];
          ArrayResize(old_params, ArraySize(m_indicator_template_setting[owned_row].raw_params));
          for(int p = 0; p < ArraySize(old_params); p++)
             old_params[p] = m_indicator_template_setting[owned_row].raw_params[p];
         // --- Explicit check BEFORE removing anything: if the NEW params already match some OTHER
         // --- existing template, appending it below would create a duplicate row - without this
         // --- early check we'd have already removed the OLD template by then, net result = template
         // --- lost with nothing replacing it. Bail out first instead, old template stays untouched.
          if(IsIndicatorInTemplateSetting(new_type, new_params))
           { ::Print(__FUNCTION__, " > chart edit rejected: new params already match another template - old template kept"); break; }
          ::Print(__FUNCTION__, " > chart edit: replacing template '", old_ind.Name(),
                "' with '", new_ind.Name(), "'");
         // --- Replace = remove the old template across ALL series + add the new one across ALL
         // --- series (CIndicatorDE cannot change params in place - its handle is bound to the old
         // --- instance). Both RemoveIndicatorFromTemplateSetting()/AddIndicatorToTemplateSetting()
         // --- are now PureData-only (Layer1 create-or-delete/Layer3 detach-or-show/view resync ALL
         // --- moved to callers) - this branch supplies those for both sides of the replace. Same
         // --- "Layer 2 decides, Layer 1 obeys" order (Data first) as every other caller.
          RemoveIndicatorFromChart(old_type, old_params);
          RemoveIndicatorFromTemplateSetting(old_type, old_params);
          if(m_time_series_engine != NULL)
             m_time_series_engine.RemoveIndicatorFromAllSeries(old_type, old_params);
          AddIndicatorToTemplateSetting(new_type, new_params);
          if(m_time_series_engine != NULL)
             m_time_series_engine.AddNewIndicatorToAllSeries(new_type, new_params);
          if(m_time_series_engine != NULL)
           {
            int handle = m_time_series_engine.GetIndicatorHandle(::Symbol(), (ENUM_TIMEFRAMES)::ChartPeriod(0),
                           new_type, new_params);
            if(handle != INVALID_HANDLE)
             {
              int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
              ENUM_INDICATOR_GROUP group = GetIndicatorGroupForType(new_type);
              int sub_window = (group == INDICATOR_GROUP_TREND) ? 0 : subwindows;
              ::Print("MY DEBUG CGUIPannel::SynIndicatorOnChart: ChartIndicatorAdd handle=", handle);
              ChartIndicatorAdd(0, sub_window, handle);
             }
           }
          SyncIndicatorTreeViewIcons();
          RefreshTableIndicator();
          SyncIndicatorTemplateSettingToBridge();
          ChartRedraw();
          SetValuesToTableIndicatorSymbolTFValue();
       }
      while(false);
     }
    // IND_DEL (Hide via the chart's own right-click Remove) needs no extra step above - just
    // re-truth the Show column below, same as every other branch.
    RefreshIndicatorTableShowColumn();
  }
 // --- Layer 3 -> Layer 2/1 sync (Anhnt, 2026-08-19 - CORRECTED after real-world test): an indicator
 // --- is present on the MAIN chart that m_indicator_template_setting[] does not know yet (added BY
 // --- HAND on the chart). MUST also call Layer 1's AddNewIndicatorToAllSeries for a genuinely new
 // --- identity - the earlier "array-only, never touch Layer 1" version left a row in the array with
 // --- NO backing CIndicatorDE anywhere, so GetIndicatorForRow() could never resolve it: Remove/Show-
 // --- toggle/Label all silently no-op'd for a chart-inserted indicator (confirmed via log 2026-08-19
 // --- 22:21 - clicking the row's X did nothing, no crash, no error, just silently rejected inside
 // --- OnClickRemoveIndicator's ref_indicator==NULL guard). Same "Layer 1 stays fully synced with the
 // --- array" invariant AddIndicatorToTemplateSetting() already upholds - this just triggers from a chart
 // --- scan instead of the Add button. A RE-INSERT of an identity that already has a row (user hand-
 // --- adds something already in the template set, possibly currently Hidden) changes NOTHING in the
 // --- array - only the Show/Hide column needs re-truthing, via RefreshIndicatorTableShowColumn().
 //+------------------------------------------------------------------------------------+
 //| Reads 1 chart line's identity and appends a new row into                           |
 //| m_indicator_template_setting[] (Single Source of Truth) if genuinely new. Mutates  |
 //| Data ONLY - Layer 1 create is the caller's job AFTER, reading type_enum/raw_params  |
 //| straight off the just-appended row ("Layer 2 decides, Layer 1 obeys", same order   |
 //| AddIndicatorToTemplateSetting uses). Both ScanIndicatorOnChart() overloads below   |
 //| call into this - the only difference between them is WHICH line(s) they hand it.  |
 //+------------------------------------------------------------------------------------+
 bool CGUIPannel::ScanIndicatorOnChartIntoTemplateSetting(CWndInd *wnd_ind)
  {

    //int handle = (wnd_ind != NULL) ? wnd_ind.Handle() : INVALID_HANDLE;
    int indicator_handle_OnChart = (wnd_ind != NULL) ? wnd_ind.Handle() : INVALID_HANDLE;
    ENUM_INDICATOR type = IND_CUSTOM;
    MqlParam params[];
    if(indicator_handle_OnChart == INVALID_HANDLE || IndicatorParameters(indicator_handle_OnChart, type, params) < 0) return false;

    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    bool supported = false;
    for(int c = 0; c < ArraySize(catalog); c++)
       if(catalog[c].ind_type == type) { supported = true; break; }

    // Unsupported type (catalog doesn't know it, e.g. SignalMarkers itself) or already tracked
    // (re-Insert of an existing/hidden template by hand) - nothing to append.
    if(!supported || IsIndicatorInTemplateSetting(type, params)) return false;

    int new_row = ArraySize(m_indicator_template_setting);
    ArrayResize(m_indicator_template_setting, new_row + 1);
    string type_key, params_key;
    BuildTemplateMatchKey(type, params, catalog, type_key, params_key);   // display text only - for .type storage
    m_indicator_template_setting[new_row].type = type_key;
    string params_text[];
    BuildIndicatorParamsText(type, params, params_text);
    ArrayResize(m_indicator_template_setting[new_row].params, ArraySize(params_text));
    for(int p = 0; p < ArraySize(params_text); p++)
       m_indicator_template_setting[new_row].params[p] = params_text[p];
    m_indicator_template_setting[new_row].type_enum = type;
    ArrayResize(m_indicator_template_setting[new_row].raw_params, ArraySize(params));
    for(int p = 0; p < ArraySize(params); p++)
       m_indicator_template_setting[new_row].raw_params[p] = params[p];
    m_indicator_template_setting[new_row].buy     = true;
    m_indicator_template_setting[new_row].sell    = true;
    m_indicator_template_setting[new_row].sound   = true;
    m_indicator_template_setting[new_row].message = true;
    return true;
  }
 //+------------------------------------------------------------------------------------+
 //| Event-driven: the IND_ADD event already identifies the ONE indicator that was just |
 //| added (CChartWnd::SendEvent packs its window index into dparam, threaded down from |
 //| OnEvent) - CChartObj::GetLastAddedIndicator(win_num) resolves it directly. No need |
 //| to re-scan every window/line on the chart to find what already changed.           |
 //+------------------------------------------------------------------------------------+
 void CGUIPannel::ScanIndicatorOnChart(const int win_num)
  {
    if(m_time_series_engine == NULL) return;
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return;
    CWndInd *wnd_ind = chart.GetLastAddedIndicator(win_num);
    if(!ScanIndicatorOnChartIntoTemplateSetting(wnd_ind)) return;   // nothing new - caller (SynIndicatorOnChart)
                                                                       // already re-truths Show unconditionally after
    int new_row = ArraySize(m_indicator_template_setting) - 1;
    bool added_ok = m_time_series_engine.AddNewIndicatorToAllSeries(
                       m_indicator_template_setting[new_row].type_enum,
                       m_indicator_template_setting[new_row].raw_params);
    Print("MY DEBUG CGUIPannel::ScanIndicatorOnChart: AddNewIndicatorToAllSeries=", (added_ok ? "OK" : "FAILED"));
    SyncIndicatorTreeViewIcons();
    RefreshTableIndicator();   // structural rebuild already re-paints Show for every row too
    SyncIndicatorTemplateSettingToBridge();   // same fix as AddIndicatorToTemplateSetting/RemoveIndicatorFromTemplate
  }
 
#endif // CGUIPANNEL_TABSETTINGINDICATOR_MQH
