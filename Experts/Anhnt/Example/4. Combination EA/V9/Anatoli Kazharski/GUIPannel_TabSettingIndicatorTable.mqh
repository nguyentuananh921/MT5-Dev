//+------------------------------------------------------------------+
//|                           GUIPannel_TabSettingIndicatorTable.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGINDICATORTABLE_MQH
#define CGUIPANNEL_TABSETTINGINDICATORTABLE_MQH
 #include "GUIPannel.mqh"
 //For m_table_indicator in TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR m_tabs_main_setting_config
 //List all indicator in template
 bool CGUIPannel::CreateTabbleIndicator(const int x, const int y)
  {
   m_table_indicator_template.MainPointer(m_tabs_main_setting_config);
   m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_table_indicator_template);
   //Resize Properties
    m_table_indicator_template.AutoXResizeMode(true);
    m_table_indicator_template.AutoXResizeRightOffset(3);
    m_table_indicator_template.AutoYResizeMode(true);
    m_table_indicator_template.AutoYResizeBottomOffset(3);
   //Table Properties
    m_table_indicator_template.ShowHeaders(true);
    m_table_indicator_template.SelectableRow(true);
    m_table_indicator_template.LightsHover(true);
    m_table_indicator_template.IsSortMode(true);
   // --- 7 columns: col 0 merges the old icon-only "show on T3" column with the
   // --- "Indicator" text column (CTCell renders image+text independently, click
   // --- detection is scoped to the image's own pixel width - see Table.mqh
   // --- CheckPressedCheckBox/CheckPressedButton). Buy/Sell/Show/Sound/Message shift
   // --- down by 1. Sound/Message added 2026-07-17: per-template opt-in for a sound
   // --- alert + Journal message when that template gets a new Signal - wiring TBD,
   // --- this only adds the checkbox UI columns for now.
    m_table_indicator_template.TableSize(7, 20);
    int widths[7]    = {180, 70, 40, 40, 40, 40, 40};
    int img_x_off[7] = {3,   0,  10, 10, 10, 10, 10};
    int img_y_off[7] = {3,   0,  3,  3,  3,  3,  3};
    ENUM_ALIGN_MODE align[7] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    m_table_indicator_template.ColumnsWidth(widths);
    m_table_indicator_template.ImageXOffset(img_x_off);
    m_table_indicator_template.ImageYOffset(img_y_off);
    m_table_indicator_template.TextAlign(align);
    m_table_indicator_template.HeaderYSize(24);

   if(!m_table_indicator_template.CreateTable(x, y)) return false;
   //Set Header text
    m_table_indicator_template.SetHeaderText(0, "Indicator");
    m_table_indicator_template.SetHeaderText(1, "Group");
   //Checkbox to include this indicator's signal in the Signal Bridge (feeds SignalMarkers.mq5's
   //ComputeBar - gates whether it counts toward Single/Multi/Combo markers on chart).   
   //Column 2
    uint resource_indices_buy[] = {IMAGE_RESOURCE_BMP16_BUY_PNG};
    m_table_indicator_template.SetHeaderImage(2, resource_indices_buy);
    m_table_indicator_template.SetHeaderText(2, "");
   //Column 3
    uint resource_indices_sell[] = {IMAGE_RESOURCE_BMP16_SELL_PNG};
    m_table_indicator_template.SetHeaderImage(3, resource_indices_sell);
    m_table_indicator_template.SetHeaderText(3, "");

   //Column 4 Setting for Visiable on Chart
    uint resource_indices_visiable[] = {IMAGE_RESOURCE_BMP16_VISIBLE_PNG};
    m_table_indicator_template.SetHeaderImage(4, resource_indices_visiable);
    m_table_indicator_template.SetHeaderText(4, "");   //On to show on Chart
    
   //Column 5 Setting for sound alert
    uint resource_indices_sound[] = {IMAGE_RESOURCE_BMP16_BELL_PNG};
    m_table_indicator_template.SetHeaderImage(5, resource_indices_sound);
    m_table_indicator_template.SetHeaderText(5, "");  //On to show sound alert
   //Column 6 Setting for message alert
    uint resource_indices_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
    m_table_indicator_template.SetHeaderImage(6, resource_indices_message);
    m_table_indicator_template.SetHeaderText(6, "");  //On to show message alert
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_template);
   return true;
  } 
 // --- Template view of Layer 1 (see README 5c): one row per template. The row set changes
 // --- ONLY via LoadConfigurationFromJSON (initial build here), AddIndicatorInstance (appends its
 // --- own row) and OnClickRemoveIndicator (DeleteRow) - so no dedup and no periodic rebuild.
 // --- By the Layer-1 invariant every series carries the same template set, hence the current
 // --- chart's (symbol,TF) instance list IS the template list, one instance per template.
 void CGUIPannel::RefreshTableIndicator(void)
  {
   if(m_IndicatorsCollection == NULL) return;
   string sym = ::Symbol();
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
   CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
   list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
   int count = (list == NULL) ? 0 : list.Total();
   // --- Row set already matches the template count: re-point the BORROWED per-row
   // --- pointers at the CURRENT chart's instances (they change on CHARTCHANGE) and
   // --- dirty-refresh the per-chart "Show" column only - no structural change, no flicker.
   // --- Baseline from m_indicator_template_setting[] (Anhnt, 2026-08-18: the live source of
   // --- truth), not the legacy m_table_indicator_ptrs[] - both still kept in sync in parallel
   // --- until Dot 3e removes the legacy array for good.
   if(count == ArraySize(m_indicator_template_setting) && count > 0)
    {
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     for(int i = 0; i < count; i++)
      {
       CIndicatorDE *indicator = list.At(i);
       if(indicator == NULL) continue;
       // --- Table may be sorted (IsSortMode) - Col 0's label text travels WITH its row
       // --- through a sort, so match against it to find the CURRENT physical row
       // --- instead of trusting collection order == row index.
        string label = "        " + BuildIndicatorLabel(indicator, catalog);
        int row = -1;
        for(int r = 0; r < count; r++)
         if(m_table_indicator_template.GetValue(0, r) == label) { row = r; break; }
          if(row < 0) continue;
          m_table_indicator_ptrs[row]  = indicator;
          m_table_indicator_names[row] = indicator.ShortName();
      }
      RefreshIndicatorTableShowColumn();
      return;
    }
   // --- Structural (re)build - initial fill after LoadConfigurationFromJSON, or safety on mismatch
   if(count == 0)
    {
     if(ArraySize(m_indicator_template_setting) == 0) return; // already showing the empty state - leave the table alone
     m_table_indicator_template.DeleteAllRows();
     m_table_indicator_template.AddRow(0);   // safety row: Library bug - DeleteAllRows does not reset m_item_index_focus
     ArrayResize(m_table_indicator_names, 0);
     ArrayResize(m_table_indicator_ptrs, 0);
     ArrayResize(m_settings_cache_state, 0);
     ArrayResize(m_indicator_template_setting, 0);   // SynIndicatorPlan.md, Dot 3b
     m_table_indicator_template.Update(true);
     return;
    }
   // --- Snapshot the CURRENT m_indicator_template_setting[] into a LOCAL copy BEFORE resizing
   // --- it below (SynIndicatorPlan.md, Dot 3b, 2026-08-17) - SetIndicatorTableRow() searches this
   // --- to carry forward each row's buy/sell/sound/message. Works correctly on EVERY rebuild, not
   // --- just the first: right after OnInit this holds the freshly JSON-loaded values; on any
   // --- later rebuild it holds whatever the user has since toggled live (reading the array being
   // --- replaced, not a frozen one-time JSON snapshot, is what keeps live toggles from being lost).
    SJsonIndicatorEntry old_setting[];
    int old_setting_total = ArraySize(m_indicator_template_setting);
    ArrayResize(old_setting, old_setting_total);
    for(int i = 0; i < old_setting_total; i++)
       old_setting[i] = m_indicator_template_setting[i];
   m_table_indicator_template.DeleteAllRows();
   // --- redraw=true on the LAST row only: AddRow() only recalculates the table's visible-area
   // --- size (CTable::RecalculateAndResizeTable) when told to - skipping it on every row and
   // --- doing it once at the end avoids the black/smeared row-overflow bug (README/BugNote
   // --- 2026-07-14) without paying the recalculation cost on every single row.
   for(int i = 0; i < count - 1; i++)   // DeleteAllRows leaves one physical row behind
    m_table_indicator_template.AddRow(i, i == count - 2);
    ArrayResize(m_table_indicator_names, count);
    ArrayResize(m_table_indicator_ptrs, count);
    ArrayResize(m_settings_cache_state, count);
    ArrayResize(m_indicator_template_setting, count);   // SynIndicatorPlan.md, Dot 3b
    for(int row = 0; row < count; row++)
    SetIndicatorTableRow(row, list.At(row), old_setting);
    m_table_indicator_template.Update(true);
  }
 // --- Fill every cell of one template row + the parallel arrays (names/ptrs/state cache) AND
 // --- m_indicator_template_setting[row] (SynIndicatorPlan.md, Dot 3b, 2026-08-17). old_setting[]
 // --- is the caller's LOCAL snapshot (see RefreshTableIndicator) - searched by (type_key,
 // --- params_key) to carry forward buy/sell/sound/message; no match (brand new row, or
 // --- old_setting[] passed empty from AddIndicatorInstance) falls back to false. This ALSO
 // --- replaces the separate ApplyLoadedIndicatorBuySell() pass that used to run after every
 // --- table rebuild - resolving it inline here means there's nothing left to "apply" afterward.
 void CGUIPannel::SetIndicatorTableRow(const int row, CIndicatorDE *indicator, SJsonIndicatorEntry &old_setting[])
  {
   if(indicator == NULL) return;
   uint delete_icon[]   = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   uint chk[]           = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
   uint show_on_chart[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
   string group_names[] = {"Trend", "Oscillator", "Volumes", "Arrows"};
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   string label = BuildIndicatorLabel(indicator, catalog);
   // --- Col 0: red Close (delete) icon + label - click detection covers the icon only
    m_table_indicator_template.CellType(0, row, CELL_BUTTON);
    m_table_indicator_template.SetImages(0, row, delete_icon);
    m_table_indicator_template.ChangeImage(0, row, 0);
    m_table_indicator_template.SetValue(0, row, "        " + label);   // leading spaces clear the icon
   // --- Col 1: group name
    int group = (int)indicator.Group();
    string gname = (group >= 0 && group < 4) ? group_names[group] : "Other";
    m_table_indicator_template.SetValue(1, row, "  " + gname);

   // --- Resolve this row's identity + carried-forward buy/sell/sound/message BEFORE painting
   // --- the checkboxes, by searching old_setting[] for a matching (type_key,params_key).
    string type_key, params_key;
    BuildTemplateMatchKey(indicator, catalog, type_key, params_key);
    bool row_buy = false, row_sell = false, row_sound = false, row_message = false;
    for(int q = 0; q < ArraySize(old_setting); q++)
     {
      string q_params_key = "";
      for(int p = 0; p < ArraySize(old_setting[q].params); p++)
         q_params_key += (p > 0 ? "," : "") + old_setting[q].params[p];
      if(old_setting[q].type == type_key && q_params_key == params_key)
       {
        row_buy = old_setting[q].buy; row_sell = old_setting[q].sell;
        row_sound = old_setting[q].sound; row_message = old_setting[q].message;
        break;
       }
     }
   // --- Col 2/3: Buy / Sell signal filters (opt-in per template; TemplateBuySellFor reads
   // --- these checkboxes live, toggles rewrite the bridge file)
    m_table_indicator_template.CellType(2, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(2, row, chk);
    m_table_indicator_template.ChangeImage(2, row, row_buy ? 0 : 1);
    m_table_indicator_template.CellType(3, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(3, row, chk);
    m_table_indicator_template.ChangeImage(3, row, row_sell ? 0 : 1);
   // --- Col 4: "shown on the CURRENT chart" checkbox
    int state = IsIndicatorShownOnChart(indicator) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
    m_table_indicator_template.CellType(4, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(4, row, show_on_chart);
    m_table_indicator_template.ChangeImage(4, row, state);
   // --- Col 5/6: Sound / Message opt-in per template (same carry-forward pattern as Buy/Sell)
    m_table_indicator_template.CellType(5, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(5, row, chk);
    m_table_indicator_template.ChangeImage(5, row, row_sound ? 0 : 1);
    m_table_indicator_template.CellType(6, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(6, row, chk);
    m_table_indicator_template.ChangeImage(6, row, row_message ? 0 : 1);

    m_table_indicator_names[row] = indicator.ShortName();
    m_table_indicator_ptrs[row]  = indicator;   // BORROWED - CIndicatorsCollection owns it
    m_settings_cache_state[row]  = state;

   // --- Write the live per-row identity+setting record (SynIndicatorPlan.md, Dot 3b) - the
   // --- single source of truth Save/checkbox-toggles/etc. now read from directly.
    m_indicator_template_setting[row].type = type_key;
    string params_text[];
    MqlParam mql_params[];
    indicator.GetMqlParams(mql_params);
    BuildIndicatorParamsText(indicator.TypeIndicator(), mql_params, params_text);
    ArrayResize(m_indicator_template_setting[row].params, ArraySize(params_text));
    for(int p = 0; p < ArraySize(params_text); p++)
       m_indicator_template_setting[row].params[p] = params_text[p];
    m_indicator_template_setting[row].buy     = row_buy;
    m_indicator_template_setting[row].sell    = row_sell;
    m_indicator_template_setting[row].sound   = row_sound;
    m_indicator_template_setting[row].message = row_message;
  }
 // --- Per-chart part of the Settings table (col 4 "Show") - dirty-check, no structural change
 void CGUIPannel::RefreshIndicatorTableShowColumn(void)
  {
   bool any_changed = false;
   // --- SynIndicatorPlan.md, Dot 3b, 2026-08-17: GetIndicatorForRow() (Dot 3a) instead of
   // --- m_table_indicator_ptrs[row] directly - row count from m_indicator_template_setting[]
   // --- (Anhnt, 2026-08-18: the live source of truth), not the legacy array.
   for(int row = 0; row < ArraySize(m_indicator_template_setting); row++)
    {
     int state = IsIndicatorShownOnChart(GetIndicatorForRow(row)) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
     if(state == m_settings_cache_state[row]) continue;
     m_settings_cache_state[row] = state;
     m_table_indicator_template.ChangeImage(4, row, state);
     m_table_indicator_template.BackColor(4, row, clrWhite, true);   // force this one cell to repaint
     any_changed = true;
    }
   if(any_changed)
     m_table_indicator_template.Update(false);
  }
 // --- On-demand replacement for direct m_table_indicator_ptrs[row] access (SynIndicatorPlan.md,
 // --- Dot 3a, 2026-08-17) - resolves the CURRENT CHART's own CIndicatorDE instance for row of
 // --- m_indicator_template_setting[] by matching (type,params) against the live collection,
 // --- instead of trusting a cached pointer that needs re-syncing on every CHARTCHANGE. Same
 // --- (type_key,params_key) string-compare BuildTemplateMatchKey() already uses everywhere else -
 // --- m_indicator_template_setting[row].type IS the type_key text already (catalog display name),
 // --- and params[] joined by comma reproduces params_key AS-IS (BuildIndicatorParamsText/
 // --- BuildTemplateMatchKey share the same schema-aware per-param formatting, so a live
 // --- instance's built key and this row's stored params[] always round-trip identically).
 CIndicatorDE *CGUIPannel::GetIndicatorForRow(const int row)
  {
   if(row < 0 || row >= ArraySize(m_indicator_template_setting)) return NULL;
   if(m_IndicatorsCollection == NULL) return NULL;
   string type_key = m_indicator_template_setting[row].type;
   string params_key = "";
   for(int p = 0; p < ArraySize(m_indicator_template_setting[row].params); p++)
      params_key += (p > 0 ? "," : "") + m_indicator_template_setting[row].params[p];

   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(::Symbol());
   ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, (ENUM_TIMEFRAMES)::ChartPeriod(0), EQUAL);
   int total = (ind_list != NULL) ? ind_list.Total() : 0;
   for(int i = 0; i < total; i++)
    {
     CIndicatorDE *ind = ind_list.At(i);
     if(ind == NULL) continue;
     string ind_type_key, ind_params_key;
     BuildTemplateMatchKey(ind, catalog, ind_type_key, ind_params_key);
     if(ind_type_key == type_key && ind_params_key == params_key)
        return ind;
    }
   return NULL;
  }
 // --- Col 2/3 checkboxes: per-template Buy/Sell signal filters. The table already
 // --- flipped the checkbox image before this handler fires; BuildAndWriteSignalBridge
 // --- reads the checkbox states live via TemplateBuySellFor, so a toggle just needs the
 // --- watermark rewound so the very next write is a full, immediate rewrite.
 // --- Also writes straight into m_indicator_template_setting[row] (SynIndicatorPlan.md, Dot 3b,
 // --- 2026-08-17) - the live single-source-of-truth Save now reads from directly.
 void CGUIPannel::OnClickToggleBuySignal(const string sname, const int row)
  {
        if(row >= 0 && row < ArraySize(m_indicator_template_setting))
           m_indicator_template_setting[row].buy = ((int)m_table_indicator_template.SelectedImageIndex(2, row) == 0);
        SyncIndicatorTemplateSettingToBridge();
        m_bridge_writer.ResetSignalBridge();
  }
 void CGUIPannel::OnClickToggleSellSignal(const string sname, const int row)
  {
    if(row >= 0 && row < ArraySize(m_indicator_template_setting))
       m_indicator_template_setting[row].sell = ((int)m_table_indicator_template.SelectedImageIndex(3, row) == 0);
    SyncIndicatorTemplateSettingToBridge();
    m_bridge_writer.ResetSignalBridge();
  }
 // --- Col 5/6 checkboxes: Sound/Message alert opt-in. NEW (SynIndicatorPlan.md, Dot 3b,
 // --- 2026-08-17) - these 2 columns never had a dedicated handler before (checkbox UI only,
 // --- "wiring TBD"); now needed purely to keep m_indicator_template_setting[row] live - no
 // --- Bridge involvement (Sound/Message don't feed CSignalBridgeWriter, only Buy/Sell do).
 void CGUIPannel::OnClickToggleSoundAlert(const string sname, const int row)
  {
   if(row >= 0 && row < ArraySize(m_indicator_template_setting))
      m_indicator_template_setting[row].sound = ((int)m_table_indicator_template.SelectedImageIndex(5, row) == 0);
  }
 void CGUIPannel::OnClickToggleMessageAlert(const string sname, const int row)
  {
   if(row >= 0 && row < ArraySize(m_indicator_template_setting))
      m_indicator_template_setting[row].message = ((int)m_table_indicator_template.SelectedImageIndex(6, row) == 0);
  }
 //Check or Uncheck Column Show On Chart
 void CGUIPannel::OnClickToggleShowIndicatorOnChart(const string sname, const int row)
  {
    // --- SynIndicatorPlan.md, Dot 3b, 2026-08-17: GetIndicatorForRow() (Dot 3a) instead of
    // --- m_table_indicator_ptrs[row] directly.
    CIndicatorDE *ind = GetIndicatorForRow(row);
    if(ind == NULL) return;
    int new_state = (int)m_table_indicator_template.SelectedImageIndex(4, row);
    int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
    if(new_state == INDICATOR_HIDE_ON_CHART)   // Hide: remove from chart, PureData/handle stay intact
          DetachIndicatorFromChart(ind);
    else // Show: re-attach using the stored handle
     {
      int sub_window = (ind.Group() == INDICATOR_GROUP_TREND) ? 0 : subwindows;
      ChartIndicatorAdd(0, sub_window, ind.Handle());
     }
        ChartRedraw();
  }
 // --- DEAD (SynIndicatorPlan.md, Dot 3b, 2026-08-17): commented out, not deleted yet (Anhnt's
 // --- safety convention). ApplyLoadedIndicatorBuySell's matching logic now runs INLINE inside
 // --- SetIndicatorTableRow() (searches the old_setting[] snapshot passed in by the caller) -
 // --- there's nothing left to "apply" as a separate pass after the table is already built.
 /*
 //+------------------------------------------------------------------+
 //| Called ONCE right after the initial RefreshIndicatorTable() (see |
 //| OnInitEvent) - pulls the Buy/Sell state SetLoadedIndicatorSettings|
 //| seeded from Config_Setting.json and applies it to the matching    |
 //| m_table_indicator rows, so a saved Buy/Sell setting survives an   |
 //| EA restart instead of resetting to OFF.                           |
 //+------------------------------------------------------------------+
 // --- Also applies Sound/Message (col 5/6) despite the name - kept the original name to avoid
 // --- touching its one call site's context; extended in place 2026-07-17.
 void CGUIPannel::ApplyLoadedIndicatorBuySell(void)
  {
   // --- Reads m_indicator_template_setting[] (seeded ONCE by SetLoadedIndicatorSettings(),
   // --- called from EA's OnInit right after Layer 1 parses Config_Setting.json) instead of
   // --- CTimeSeriesEngine::GetLoadedTemplateSettings() - Layer 1 no longer stores this
   // --- (SeparateLayer_Plan.md, 2026-08-16).
    int loaded_total = ArraySize(m_indicator_template_setting);
    if(loaded_total == 0) return;
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
   // --- Same comma-join Layer 1 uses to build params_key (TimeSeriesEngine_JSONConfig.mqh's
   // --- LoadIndicatorTemplateFromJSON) - must match exactly for the lookup below to hit.
    string loaded_params_key[];
    ArrayResize(loaded_params_key, loaded_total);
    for(int q = 0; q < loaded_total; q++)
     {
      string key = "";
      for(int p = 0; p < ArraySize(m_indicator_template_setting[q].params); p++)
        key += (p > 0 ? "," : "") + m_indicator_template_setting[q].params[p];
      loaded_params_key[q] = key;
     }
    int rows = ArraySize(m_table_indicator_ptrs);
    bool any_changed = false;
    for(int row = 0; row < rows; row++)
     {
      CIndicatorDE *ind = m_table_indicator_ptrs[row];
      if(ind == NULL) continue;
      string type_key, params_key;
      BuildTemplateMatchKey(ind, catalog, type_key, params_key);
      for(int q = 0; q < loaded_total; q++)
       {
        if(m_indicator_template_setting[q].type != type_key || loaded_params_key[q] != params_key) continue;
        m_table_indicator_template.ChangeImage(2, row, m_indicator_template_setting[q].buy     ? 0 : 1);
        m_table_indicator_template.ChangeImage(3, row, m_indicator_template_setting[q].sell    ? 0 : 1);
        m_table_indicator_template.ChangeImage(5, row, m_indicator_template_setting[q].sound   ? 0 : 1);
        m_table_indicator_template.ChangeImage(6, row, m_indicator_template_setting[q].message ? 0 : 1);
        any_changed = true;
            break;
        }
     }
    if(any_changed) m_table_indicator_template.Update(true);
  }
 */
 // --- DEAD (same reason) - Save now reads m_indicator_template_setting[] directly (already
 // --- kept live by SetIndicatorTableRow/OnClickToggle*) instead of re-deriving from live CTable
 // --- checkbox icons + a separate Handle()-based join array.
 /*
 // --- Buy/Sell/Sound/Message lookup arrays for SaveGUIConfigToJSON, read off
 // --- m_table_indicator_template's current checkbox state (col 2/3/5/6). Matched back to the
 // --- real m_IndicatorsCollection templates by Handle() (program-wide join key, same
 // --- convention as LineRepresentsIndicator) - mirrors BuildSymbolTFBuySellArrays
 // --- (SeparateLayer_Plan.md, 2026-08-16: replaces the old hardcode-true bug).
 void CGUIPannel::BuildTemplateBuySellSoundMessageArrays(int &handles[], bool &buys[], bool &sells[],
                                                           bool &sounds[], bool &messages[])
   {
    ArrayResize(handles,  0);
    ArrayResize(buys,     0);
    ArrayResize(sells,    0);
    ArrayResize(sounds,   0);
    ArrayResize(messages, 0);
    int rows = ArraySize(m_table_indicator_ptrs);
    int total = 0;
    for(int row = 0; row < rows; row++)
     {
      CIndicatorDE *ind = m_table_indicator_ptrs[row];
      if(ind == NULL) continue;
      ArrayResize(handles,  total + 1);
      ArrayResize(buys,     total + 1);
      ArrayResize(sells,    total + 1);
      ArrayResize(sounds,   total + 1);
      ArrayResize(messages, total + 1);
      handles[total]  = ind.Handle();
      buys[total]     = (m_table_indicator_template.SelectedImageIndex(2, row) == 0);
      sells[total]    = (m_table_indicator_template.SelectedImageIndex(3, row) == 0);
      sounds[total]   = (m_table_indicator_template.SelectedImageIndex(5, row) == 0);
      messages[total] = (m_table_indicator_template.SelectedImageIndex(6, row) == 0);
      total++;
     }
   }
 */
 // --- Resolve a Layer 3 line to the Layer 1 instance (current symbol/TF) it represents,
 // --- or NULL when the line is foreign. Same fast/slow paths as LineRepresentsIndicator.
 CIndicatorDE *CGUIPannel::OwnedInstanceOfLine(const int line_handle)
  {
    if(line_handle == INVALID_HANDLE || m_time_series_engine == NULL) return NULL;
     CIndicatorDE *owned = m_time_series_engine.GetIndicatorByHandle(line_handle);
    if(owned != NULL) return owned;
    // --- SynIndicatorPlan.md, Dot 3d, 2026-08-17: GetIndicatorForRow() (Dot 3a) instead of
    // --- m_table_indicator_ptrs[row] directly - row count from m_indicator_template_setting[]
    // --- (Anhnt, 2026-08-18: the live source of truth), not the legacy array.
    for(int row = 0; row < ArraySize(m_indicator_template_setting); row++)
     {
      CIndicatorDE *cand = GetIndicatorForRow(row);
      if(LineRepresentsIndicator(line_handle, cand))
        return cand;
     }
      return NULL;
  }
 // --- Reverse of GetIndicatorForRow() (SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18) -
 // --- identity (type_key,params_key) -> row, by scanning m_indicator_template_setting[] (same
 // --- comma-join round-trip GetIndicatorForRow/BuildTemplateMatchKey already rely on everywhere else).
 int CGUIPannel::GetRowForIdentity(const string type_key, const string params_key)
  {
   for(int row = 0; row < ArraySize(m_indicator_template_setting); row++)
    {
     if(m_indicator_template_setting[row].type != type_key) continue;
     string row_params_key = "";
     for(int p = 0; p < ArraySize(m_indicator_template_setting[row].params); p++)
        row_params_key += (p > 0 ? "," : "") + m_indicator_template_setting[row].params[p];
     if(row_params_key == params_key) return row;
    }
   return -1;
  }
 // --- L2's identity-based Delete (SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18) -
 // --- symmetric counterpart to AddIndicatorInstance(). Removes this whole template (same
 // --- type+params, regardless of symbol/timeframe) from PureData. Does NOT touch the JSON file
 // --- yet (that part - persisting the removal so it doesn't come back on next EA restart - is
 // --- still open, deferred from the earlier discussion).
 void CGUIPannel::RemoveIndicatorInstance(const ENUM_INDICATOR type, MqlParam &params[])
  {
   if(m_time_series_engine == NULL || m_IndicatorsCollection == NULL) return;
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   string type_key, params_key;
   BuildTemplateMatchKey(type, params, catalog, type_key, params_key);
   int row = GetRowForIdentity(type_key, params_key);
   if(row < 0) { ::Print(__FUNCTION__, " > rejected: no table row for this identity"); return; }
   //--- Audit line: template removals are destructive and reachable from several paths
   //--- (X icon, SynIndicatorOnChart's CHANGE branch) - always log who goes and from which row
    ::Print(__FUNCTION__, " > row=", row, " '", m_table_indicator_names[row], "'");
   // --- Detach from chart FIRST (Layer 3 display) - Layer 1's delete below has no chart/window
   // --- knowledge at all (same as Add never touching the chart either). Read-only loop over
   // --- Layer 1's own collection, purely to find which live instances to detach.
    CArrayObj *list = m_IndicatorsCollection.GetList();
    if(list != NULL)
     {
      for(int i = list.Total() - 1; i >= 0; i--)
       {
        // indicator is BORROWED (CIndicatorsCollection owns it via 'list' FreeMode)
         CIndicatorDE *indicator = list.At(i);
         if(indicator == NULL || indicator.TypeIndicator() != type) continue;
        // --- Same template = same type + same params, regardless of symbol/TF
         MqlParam inst_params[];
         indicator.GetMqlParams(inst_params);
         if(!IsEqualMqlParamArrays(inst_params, params)) continue;
        // --- Detach from chart if currently shown (Layer 3 mirror, handle = join key). The
        // --- slot itself dies exactly once, inside RemoveIndicatorFromAllSeries below.
         DetachIndicatorFromChart(indicator);
       }
     }
   // --- Layer 1 (L1.Task1): mirror removal + delete every symbol/TF instance + its Signal.
    m_time_series_engine.RemoveIndicatorFromAllSeries(type, params);
   // --- Drop exactly this row (Library CTable::DeleteRow shifts the rest up) and keep
   // --- the parallel arrays aligned. No DeleteAllRows here (README 5a/5c). Row count from
   // --- m_indicator_template_setting[] (Layer 2's live source of truth), not the legacy
   // --- m_table_indicator_ptrs[] (SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18).
    int rows_after = ArraySize(m_indicator_template_setting) - 1;
    for(int r = row; r < rows_after; r++)
     {
      m_table_indicator_names[r] = m_table_indicator_names[r + 1];
      m_table_indicator_ptrs[r]  = m_table_indicator_ptrs[r + 1];
      m_settings_cache_state[r]  = m_settings_cache_state[r + 1];
      m_indicator_template_setting[r] = m_indicator_template_setting[r + 1];   // SynIndicatorPlan.md, Dot 3b
     }
    ArrayResize(m_table_indicator_names, rows_after);
    ArrayResize(m_table_indicator_ptrs,  rows_after);
    ArrayResize(m_settings_cache_state,  rows_after);
    ArrayResize(m_indicator_template_setting, rows_after);   // SynIndicatorPlan.md, Dot 3b
    if(rows_after == 0)
     {
      // CTable::DeleteRow never shrinks below one physical row, and SetImages rejects an
      // empty array (no API to strip a cell's icons) - so add a freshly CellInitialize'd
      // blank row first, then delete the old row 0 that still carries the delete/checkbox
      // icons. The blank row shifts up and becomes the single empty survivor.
       m_table_indicator_template.AddRow(1);
       m_table_indicator_template.DeleteRow(0, true);
       m_table_indicator_template.Update(true);
     }
    else
      m_table_indicator_template.DeleteRow(row, true);
   SetValuesToTableIndicatorSymbolTFValue();
   SyncIndicatorTreeViewIcons();
   ChartRedraw();
  }
 // --- Col 0 button: thin row->identity wrapper (SynIndicatorPlan.md, "3 Layer Task breakdown",
 // --- 2026-08-18) - the real work now lives in the identity-based RemoveIndicatorInstance() above,
 // --- reusable from non-UI callers (e.g. SynIndicatorOnChart's CHANGE branch) too.
 void CGUIPannel::OnClickRemoveIndicator(const string sname, const int row)
  {
   // ref_indicator is BORROWED (CIndicatorsCollection owns it) - capture type/params into plain
   // local values now, before RemoveIndicatorInstance's own lookup loop may delete it.
   CIndicatorDE *ref_indicator = GetIndicatorForRow(row);
   if(ref_indicator == NULL) return;
   ENUM_INDICATOR ref_type = ref_indicator.TypeIndicator();
   MqlParam ref_params[];
   ref_indicator.GetMqlParams(ref_params);
   RemoveIndicatorInstance(ref_type, ref_params);
  }
#endif // CGUIPANNEL_TABSETTINGINDICATORTABLE_MQH
