//+------------------------------------------------------------------+
//|                                GUIPannel_TabSettingIndicator.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGINDICATOR_MQH
#define CGUIPANNEL_TABSETTINGINDICATOR_MQH
 //For control at TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL of m_tabs_main
 //+------------------------------------------------------------------+
 //| Create a nested tab group m_tabs_main_setting_config for Settings tab config sections       |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTabSettingConfig(const int x_gap, const int y_gap)
  {
    string tabs_names[TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL] = {"Indicator", "Symbol TF","Candle Pattern", "Marker"};
    //--- Store the pointer to the parent control - nested inside m_tabs_main's Settings tab
    m_tabs_main_setting_config.MainPointer(m_tabs_main);
    //--- Properties
    m_tabs_main_setting_config.IsCenterText(true);
    m_tabs_main_setting_config.PositionMode(TABS_TOP);
    m_tabs_main_setting_config.AutoXResizeMode(true);
    m_tabs_main_setting_config.AutoYResizeMode(true);
    m_tabs_main_setting_config.AutoXResizeRightOffset(3);
    m_tabs_main_setting_config.AutoYResizeBottomOffset(3);
    //--- Add tabs with the specified properties
    for(int i = 0; i < TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL; i++)
        m_tabs_main_setting_config.AddTab(tabs_names[i], 100);
    //--- Create Tab before create other control element inside
    if(!m_tabs_main_setting_config.CreateTabs(x_gap, y_gap))
        return (false);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_tabs_main_setting_config);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_tabs_main_setting_config);
    return (true);
  }
 //For control at each tab m_tabs_main_setting_config
 //Tab Indicator TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR
 // For TreeView Indicator m_treeview_indicator on the left TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR m_tabs_main_setting_config
 bool CGUIPannel::CreateTreeView_Indicator(const int x_gap, const int y_gap)
  {
    m_treeview_indicator.MainPointer(m_tabs_main_setting_config);
    m_treeview_indicator.AutoXResizeMode(false);
    m_treeview_indicator.XSize(150);
    m_treeview_indicator.AutoYResizeMode(true);
    m_treeview_indicator.VisibleItemsTotal(15);
    m_treeview_indicator.LightsHover(true);
    //Create treeview
    if(!m_treeview_indicator.CreateTreeView(x_gap, y_gap)) return false;
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_treeview_indicator);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_treeview_indicator);       
    return true;
  }
 void CGUIPannel::PopulateIndicatorTree(void)
  {
    string group_names[4] = {"Trend", "Oscillator", "Volumes", "Arrows"};
    ENUM_INDICATOR_GROUP group_values[4] = {INDICATOR_GROUP_TREND, INDICATOR_GROUP_OSCILLATOR, INDICATOR_GROUP_VOLUMES, INDICATOR_GROUP_ARROWS};

    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    ArrayResize(m_group_tree_pos, 4); 
    for(int g = 0; g < 4; g++)
    {
    int root_li = m_treeview_indicator.ItemsTotal();
    m_group_tree_pos[g] = root_li;
    m_treeview_indicator.AddTreeItem(root_li,
                                    -1,                          // prev_node_list_index = -1 (root)
                                    group_names[g],
                                    IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                    g, 0,                        // item_index, node_level = 0
                                    0, 0, 0,
                                    true, true);                 // item_state, is_folder
    int k = 0;
    for(int i = 0; i < ArraySize(catalog); i++)
        {
        if(catalog[i].group != group_values[g]) continue;
        int child_li = m_treeview_indicator.ItemsTotal();
        m_treeview_indicator.AddTreeItem(child_li, root_li, catalog[i].name,
                                        IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                        k, 1, g, 0, 0, true, true);
        // --- KHÔNG còn gọi leaf.Index(...) nữa — lưu mapping riêng
        int sz = ArraySize(m_type_node_li);
        ArrayResize(m_type_node_li, sz + 1);
        ArrayResize(m_type_node_value, sz + 1);
        m_type_node_li[sz]    = child_li;
        m_type_node_value[sz] = catalog[i].type;
        k++;
        }
    }
  } 
 void CGUIPannel::SyncIndicatorTreeViewIcons(void)
  {
   if(m_IndicatorsCollection == NULL) return;
   CArrayObj *all = m_IndicatorsCollection.GetList();
   if(all == NULL) return;
   ENUM_INDICATOR applied[];
   int applied_count = 0;
   for(int i = 0; i < all.Total(); i++)
    {
     CIndicatorDE *ind = all.At(i);
     if(ind == NULL) continue;
     ENUM_INDICATOR t = ind.TypeIndicator();
     bool found = false;
     for(int j = 0; j < applied_count; j++)
        if(applied[j] == t) { found = true; break; }
     if(!found)
      {
        ArrayResize(applied, applied_count + 1);
        applied[applied_count++] = t;
      }
    }
   for(int i = 0; i < ArraySize(m_type_node_li); i++)
     {
      bool active = false;
      for(int j = 0; j < applied_count; j++)
      if(applied[j] == m_type_node_value[i]) { active = true; break; }
      CTreeItem *type_item = m_treeview_indicator.ItemPointer(m_type_node_li[i]);
      if(type_item != NULL)
      type_item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
      if(active)
       {
        int group_li = m_treeview_indicator.ItemPrevNode(m_type_node_li[i]);
        CTreeItem *group_item = m_treeview_indicator.ItemPointer(group_li);
        if(group_item != NULL)
        group_item.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
       }
     }
    m_treeview_indicator.Update(true);
  }
 // --- GUI "Add" button: indicator creation itself now lives in CTimeSeriesEngine
 // --- (Tang 1, PureData) - GUIPannel only forwards the call, then updates its own
 // --- display state (TreeView icon + m_table_indicator), which is its Tang 2 job.
 void CGUIPannel::AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[])
  {
    if(m_time_series_engine == NULL || m_IndicatorsCollection == NULL) return;
    // --- Source-side duplicate guard (README 5c): the template set stays unique HERE,
    // --- at the only place templates enter Layer 1 - not hidden later by a display dedup.
     if(m_IndicatorsCollection.TemplateExists(type, params))
      {
       ::Print(__FUNCTION__, " > rejected: this template already exists");
       return;
      }
     if(!m_time_series_engine.AddNewIndicatorToAllSeries(type, params)) return;
     SyncIndicatorTreeViewIcons();   // full sweep + Update(true)
    // --- Append exactly ONE row for the new template (README 5c - no rescan, no rebuild).
    // --- The engine appends to the collection, so the new instance for the current chart
    // --- is the LAST one in the (symbol,TF)-filtered list.
     string sym = ::Symbol();
     ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
     CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
     list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
     if(list == NULL || list.Total() == 0) return;
     CIndicatorDE *indicator = list.At(list.Total() - 1);
     int row = ArraySize(m_table_indicator_ptrs);
     if(row > 0)                      // an empty table already owns one physical row - reuse it for row 0
       m_table_indicator_template.AddRow(row, true);   // redraw=true - recalculate visible-area size, see
                                                // README/BugNote 2026-07-14 black/smeared overflow bug
     ArrayResize(m_table_indicator_names, row + 1);
     ArrayResize(m_table_indicator_ptrs,  row + 1);
     ArrayResize(m_settings_cache_state,  row + 1);
     SetIndicatorTableRow(row, indicator);
     m_table_indicator_template.Update(true);
  }
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
   //Checkbox to show or hide on Layer 3 (Chart)
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
   if(count == ArraySize(m_table_indicator_ptrs) && count > 0)
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
     if(ArraySize(m_table_indicator_ptrs) == 0) return; // already showing the empty state - leave the table alone
     m_table_indicator_template.DeleteAllRows();
     m_table_indicator_template.AddRow(0);   // safety row: Library bug - DeleteAllRows does not reset m_item_index_focus
     ArrayResize(m_table_indicator_names, 0);
     ArrayResize(m_table_indicator_ptrs, 0);
     ArrayResize(m_settings_cache_state, 0);
     m_table_indicator_template.Update(true);
     return;
    }
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
    for(int row = 0; row < count; row++)
    SetIndicatorTableRow(row, list.At(row));
    m_table_indicator_template.Update(true);
  }
 // --- Fill every cell of one template row + the parallel arrays (names/ptrs/state cache)
 void CGUIPannel::SetIndicatorTableRow(const int row, CIndicatorDE *indicator)
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
   // --- Col 2/3: Buy / Sell signal filters (default OFF - markers are opt-in per template;
   // --- TemplateBuySellFor reads these checkboxes live, toggles rewrite the bridge file)
    m_table_indicator_template.CellType(2, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(2, row, chk);
    m_table_indicator_template.ChangeImage(2, row, 1);
    m_table_indicator_template.CellType(3, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(3, row, chk);
    m_table_indicator_template.ChangeImage(3, row, 1);
   // --- Col 4: "shown on the CURRENT chart" checkbox
    int state = IsIndicatorShownOnChart(indicator) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
    m_table_indicator_template.CellType(4, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(4, row, show_on_chart);
    m_table_indicator_template.ChangeImage(4, row, state);
   // --- Col 5/6: Sound / Message opt-in per template (default OFF, same pattern as
   // --- Buy/Sell) - checkbox UI only for now, wiring to actually play/print on a new
   // --- Signal is still TBD (2026-07-17).
    m_table_indicator_template.CellType(5, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(5, row, chk);
    m_table_indicator_template.ChangeImage(5, row, 1);
    m_table_indicator_template.CellType(6, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(6, row, chk);
    m_table_indicator_template.ChangeImage(6, row, 1);

    m_table_indicator_names[row] = indicator.ShortName();
    m_table_indicator_ptrs[row]  = indicator;   // BORROWED - CIndicatorsCollection owns it
    m_settings_cache_state[row]  = state;
  }
 // --- Per-chart part of the Settings table (col 4 "Show") - dirty-check, no structural change
 void CGUIPannel::RefreshIndicatorTableShowColumn(void)
  {
   bool any_changed = false;
   for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
    {
     int state = IsIndicatorShownOnChart(m_table_indicator_ptrs[row]) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
     if(state == m_settings_cache_state[row]) continue;
     m_settings_cache_state[row] = state;
     m_table_indicator_template.ChangeImage(4, row, state);
     m_table_indicator_template.BackColor(4, row, clrWhite, true);   // force this one cell to repaint
     any_changed = true;
    }
   if(any_changed)
     m_table_indicator_template.Update(false);
  }
 //To Add Indicator
  // Builds the per-param layout for `type`. element_type is always carried
  // straight from Tang 1's schema (choices!="" -> E_COMBO_BOX) - Tang 2 does
  // not re-decide that fact, only how/where to render it. row/col/field_width
  // are explicitly curated per type below (this is the per-indicator layout
  // the user asked to control directly, not a blanket formula).
  int CGUIPannel::GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[])
   {
    SIndicatorParam schema[];
    int total = GetIndicatorParamSchema(type, schema);
    ArrayResize(out, total);
    for(int i = 0; i < total; i++)
     {
      // --- Fallback default (used for any type not explicitly curated below):
      // --- 2-per-row pairing, matches the catalog's Period/Shift-style ordering.
      out[i].row          = i / 2;
      out[i].col          = i % 2;
      out[i].total_width  = INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W;
      out[i].field_width  = INDICATOR_PARAM_FIELD_W;
      out[i].element_type = (schema[i].choices != "") ? E_COMBO_BOX : E_TEXT_BOX;
     }
    switch(type)
     {
      //Format 
      //1. Indicator Parameter.
      //2. Row number.
      //3. Column Number.
      //4. Total Width.
      //5. Input Value for Parameter width
      case IND_MA:
       SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - wider so the option text isn't clipped
       SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - longest label drives the 180 total
       break;
      case IND_STDDEV:
      // Same shape as MA (Period/Shift/Method/Applied Price) - kept as its
      // own case (not a fallthrough) so each indicator stays independently
      // editable without touching any other type.
        SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_ICHIMOKU:
      // Tenkan-sen / Kijun-sen / Senkou Span B - 3 unrelated periods,
      // one per row reads cleaner than pairing the 3rd alone on its own row.
       SetLayoutSlot(out,ICHIMOKU_TENKAN,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ICHIMOKU_KIJUN,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ICHIMOKU_SENKOU_B,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       break;
      case IND_SAR:
      // Step / Maximum - not a Period+Shift pair, one per row reads cleaner.
        SetLayoutSlot(out,SAR_STEP,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,SAR_MAXIMUM, 0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_BANDS:
        SetLayoutSlot(out,BANDS_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,BANDS_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,BANDS_DEVIATION,      1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,BANDS_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_ALLIGATOR:
      // 8 params would push a single column past the Add button (fixed at
      // 4-row height) - pair them 2-per-row like the catalog's natural
      // Jaw/Teeth/Lips period+shift grouping, same i/2,i%2 the fallback uses.
        SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_GATOR:
      // Same 8-param shape as Alligator (Jaw/Teeth/Lips period+shift, Method,
      // Applied Price) - own case so it stays independently editable.
        SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_ENVELOPES:
      // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
        SetLayoutSlot(out,ENVELOPES_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ENVELOPES_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ENVELOPES_METHOD,         2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,ENVELOPES_APPLIED_PRICE,  2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,ENVELOPES_DEVIATION_PCT,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  
        break;
      case IND_FRAMA:
        SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_DEMA:
      // Same shape as FRAMA/TEMA (Period/Shift/Applied Price) - own case.
        SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_TEMA:
      // Same shape as FRAMA/DEMA (Period/Shift/Applied Price) - own case.
        SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_AMA:
      // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
        SetLayoutSlot(out,AMA_PERIOD,            0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,AMA_FAST_EMA_PERIOD,   0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,AMA_SLOW_EMA_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // longest label ("Slow EMA Period") drives the 220 total
        SetLayoutSlot(out,AMA_SHIFT,             1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,AMA_APPLIED_PRICE,     2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_VIDYA:
        SetLayoutSlot(out,VIDYA_CMO_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,VIDYA_EMA_PERIOD,     0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,VIDYA_SHIFT,          1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,VIDYA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      // --- Single plain "Period" numeric field - same 1-param shape across all
      // --- of these, each kept as its own case (not grouped) so any one of
      // --- them can be retuned without touching the others. idx is always 0,
      // --- no named enum needed for a single unambiguous field.
      case IND_ADX:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_ADXW:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_DEMARKER:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_RVI:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_WPR:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_TRIX:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_ATR:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_BEARS:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_BULLS:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_MFI:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_MOMENTUM:
        SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_CCI:
      // Same shape as RSI/Momentum (Period + Applied Price) - own case.
        SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_RSI:
      // Same shape as CCI/Momentum (Period + Applied Price) - own case.
        SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_MACD:
       SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ESP_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
       break;
      case IND_OSMA:
      // Same shape as MACD (Fast/Slow EMA Period, Signal Period, Applied
      // Price) - own case.
        SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ESP_APPLIED_PRICE,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_STOCHASTIC:
      // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
        SetLayoutSlot(out,STOCH_K_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,STOCH_D_PERIOD,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,STOCH_SLOWING,      2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,STOCH_METHOD,       0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,STOCH_PRICE_FIELD,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_FORCE:
        SetLayoutSlot(out,FORCE_PERIOD,           0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,FORCE_METHOD,           1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,FORCE_APPLIED_VOLUME,   1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - "Applied Volume" drives the 210 total
        break;
      case IND_CHAIKIN:
        SetLayoutSlot(out,CHAIKIN_FAST_MA_PERIOD,  0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,CHAIKIN_SLOW_MA_PERIOD,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,CHAIKIN_METHOD,          2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,CHAIKIN_APPLIED_VOLUME,  3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      // --- Single combo "Applied Volume" field - same 1-param shape across all
      // --- of these, each kept as its own case (not grouped). idx is always 0,
      // --- no named enum needed for a single unambiguous field.
      case IND_OBV:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_AD:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_VOLUMES:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      // --- IND_AO, IND_AC, IND_BWMFI, IND_FRACTALS have 0 params (total=0,
      // --- the loop in ShowIndicatorParameterForm never executes) - no case needed.
      default:
        break; // default pairing is fine
     }
    return total;
   }
  // =====================================================================
  // --- Called from OnEvent when a Type-level tree node is clicked
  // =====================================================================
  void CGUIPannel::ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li)
   {
    m_current_param_type    = type;
    m_current_param_type_li = type_li;
    SIndicatorParam schema[];
    int total = GetIndicatorParamSchema(type, schema);
    // --- Layer 2 layout - decided BEFORE we touch a single control, separate
    // --- from Layer 1's data schema. Drives both position AND which control renders.
     SIndicatorLayout layout[];
     GetIndicatorGuiLayout(type, layout);
    // --- x_gap offsets right of the 150px indicator tree; y_gap from the tab's top.
     const int x_gap = PARAM_FORM_X, y_gap = PARAM_FORM_Y;
     for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
      {
       if(i < total)
        {
         int x = x_gap + layout[i].col * INDICATOR_PARAM_COL_WIDTH;
         int y = y_gap + layout[i].row * 30;
         // --- Reposition label/edit/combo to this type's layout slot. Moving()
         // --- reads the CANVAS's own XGap/YGap (not just the element's), and
         // --- skips repositioning hidden elements by default - see CElement::Moving().
          m_param_labels[i].XGap(x); m_param_labels[i].CanvasPointer().XGap(x);
          m_param_labels[i].YGap(y); m_param_labels[i].CanvasPointer().YGap(y);
          m_param_labels[i].LabelText(schema[i].name);
          m_param_labels[i].Show();
          m_param_labels[i].Moving();
         // --- Field starts after (total_width - field_width) px of label room.
         // --- Keeping total_width equal across a type's rows is what makes the
         // --- field line up at the same right edge regardless of label length.
          int fx = x + (layout[i].total_width - layout[i].field_width);
          if(layout[i].element_type == E_COMBO_BOX)
           {
            string parts[];
            int n = StringSplit(schema[i].choices, '|', parts);
            m_param_combo[i].GetListViewPointer().Rebuilding(n);
            for(int p = 0; p < n; p++)
              m_param_combo[i].SetValue(p, parts[p]);
            int def_idx = (int)StringToInteger(schema[i].default_value);
            if(def_idx >= 0 && def_idx < n) m_param_combo[i].SelectItem(def_idx);
            // --- SetValue()/Rebuilding() default redraw=false - they only store
            // --- the data, they never paint it. Same trap as CSplitContainer's
            // --- separator: must force an element-level Update(true) (-> Draw())
            // --- or the dropdown list stays visually blank even though it has items.
             m_param_combo[i].GetListViewPointer().Update(true);
            // --- XSize() alone never touches the canvas bitmap (logical field
            // --- only) - same trap as CSplitContainer's panel1. Must also resize
            // --- the canvas + the internal button to actually change width on screen.
             int cw = layout[i].field_width;
             m_param_combo[i].XSize(cw);
             m_param_combo[i].CanvasPointer().XSize(cw);
             m_param_combo[i].CanvasPointer().Resize(cw, m_param_combo[i].CanvasPointer().YSize());
            // --- Use built-in ChangeSize to properly resize the button and its image group gap (dropdown arrow position)
             m_param_combo[i].GetButtonPointer().ChangeSize(cw, m_param_combo[i].GetButtonPointer().YSize());
            // --- ComboBox.mqh's CreateButton() computes IconXGap ONCE at creation
            // --- time as (x_size-18), using whatever x_size the button had THEN
            // --- (90, from INDICATOR_PARAM_FIELD_W) - it never re-tracks later
            // --- resizes. Left stale, the dropdown arrow icon stays pinned at the
            // --- OLD x=72 regardless of how narrow/wide the button becomes now,
            // --- which is what made the box look like it had no closed right edge.
            // --- Recompute it here using the Library's own formula every resize.
             m_param_combo[i].GetButtonPointer().IconXGap(cw - 18);
            // --- Also resize the dropdown list view to match the combo width
             m_param_combo[i].GetListViewPointer().ChangeSize(cw, m_param_combo[i].GetListViewPointer().YSize());
             m_param_combo[i].XGap(fx); m_param_combo[i].CanvasPointer().XGap(fx);
             m_param_combo[i].YGap(y);  m_param_combo[i].CanvasPointer().YGap(y);
             m_param_combo[i].Draw();
             m_param_combo[i].Show();
             m_param_combo[i].Moving();
             m_param_edits[i].Hide();
           }
          else
           {
            // --- is_size_adjustment=false: SetValue() defaults to TRUE, which
            // --- calls CorrectSize() and shrinks the box to fit the value text
            // --- (a 1-digit default like "8" collapses the box to almost
            // --- nothing, looking like a stray checkbox icon). Keep our explicit
            // --- per-layout field_width instead.
             m_param_edits[i].SetValue(schema[i].default_value, false);
             int ew = layout[i].field_width;
             m_param_edits[i].XSize(ew);
             m_param_edits[i].CanvasPointer().XSize(ew);
             m_param_edits[i].CanvasPointer().Resize(ew, m_param_edits[i].CanvasPointer().YSize());
            // --- Use built-in ChangeSize to properly resize the inner CTextBox canvas, area width, and visible width
              m_param_edits[i].GetTextBoxPointer().ChangeSize(ew, m_param_edits[i].GetTextBoxPointer().YSize());
              m_param_edits[i].XGap(fx); m_param_edits[i].CanvasPointer().XGap(fx);
              m_param_edits[i].YGap(y);  m_param_edits[i].CanvasPointer().YGap(y);
              m_param_edits[i].Draw();
            // --- The visible VALUE text is painted by the inner CTextBox
            // --- (m_edit), which has its own separate canvas - NOT by the outer
            // --- CTextEdit's Draw()/Update(). Normally SetValue()'s default
            // --- CorrectSize() path repaints it as a side effect of resizing;
            // --- since we pass is_size_adjustment=false (to stop the auto-shrink
            // --- bug), we must explicitly force that inner repaint ourselves,
            // --- or the box keeps showing whatever value the PREVIOUSLY selected
            // --- indicator left behind (confirmed: stale "0.02"/"0.2" from PSAR
            // --- still showing after switching to MA).
              m_param_edits[i].GetTextBoxPointer().Update(true);
              m_param_edits[i].Update(true);
              m_param_edits[i].Show();
              m_param_edits[i].Moving();
              m_param_combo[i].Hide();
           }
        }
       else
        {
         m_param_labels[i].Hide();
         m_param_edits[i].Hide();
         m_param_combo[i].Hide();
        }
       m_param_labels[i].Update(true);
       m_param_edits[i].Update(true);
       m_param_combo[i].GetButtonPointer().Update(true);
      }   
   }

  //Helper to set layout slot
  void CGUIPannel::SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw)
   {
    out[idx].row         = r;
    out[idx].col         = c;
    out[idx].total_width = tw;
    out[idx].field_width = fw;
   } 
  // Hides all param-form slots. Called after any ShowTabElements() that overrides our Hide().
  void CGUIPannel::HideParamSlots(void)
   {
    for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].Hide();
      m_param_edits[i].Hide();
      m_param_combo[i].Hide();
     }     
   } 
  // =====================================================================
  // --- "Add" button click handler — converts text fields to MqlParam[]
  // =====================================================================
  void CGUIPannel::OnClickAddIndicator(void)
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
      AddIndicatorInstance(m_current_param_type_li, m_current_param_type, params);
     }
   }
  // =====================================================================
  // --- Params tab: up to INDICATOR_PARAM_SLOTS_MAX (8) label+field pairs,
  // --- laid out as 2 columns x 4 rows. Each slot has BOTH a CTextEdit (plain
  // --- numeric params) and a CComboBox (enum-like params) at the same spot -
  // --- ShowIndicatorParameterForm() shows exactly one of the two per slot,
  // --- based on whether that param has choices in the schema.
  // =====================================================================  
  bool CGUIPannel::CreateAddIndicatorParaInfor(const int x_gap, const int y_gap)
   {
    const int default_x = x_gap;
    const int default_y = y_gap;
    for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_labels[i]);
      if(!m_param_labels[i].CreateTextLabel("", default_x, default_y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_labels[i]);

      m_param_edits[i].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_edits[i]);
      m_param_edits[i].XSize(INDICATOR_PARAM_FIELD_W);
      // --- Inner CTextBox defaults its LOCAL x-offset to the outer box's x_size at
      // --- creation time unless told otherwise BEFORE CreateTextEdit() - confirmed via
      // --- debug log (inner canvas sitting ~90px right of the outer frame after resize).
       m_param_edits[i].GetTextBoxPointer().XGap(1);
       if(!m_param_edits[i].CreateTextEdit("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_edits[i]);

       m_param_combo[i].MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_combo[i]);
       m_param_combo[i].XSize(INDICATOR_PARAM_FIELD_W);
       m_param_combo[i].YSize(20);
       m_param_combo[i].ItemsTotal(7);          // room for the largest choice list (PRICE_CHOICES)
      // --- CButton inside CComboBox defaults to XSize=80 at XGap=80 unless explicitly
      // --- told otherwise BEFORE CreateComboBox() - mirrors how CTable's own combo usage
      // --- configures it. Without this the button/listview end up outside the narrow canvas.
       m_param_combo[i].GetButtonPointer().XGap(1);
       m_param_combo[i].GetButtonPointer().XSize(INDICATOR_PARAM_FIELD_W);
       m_param_combo[i].GetButtonPointer().LabelYGap(4);
       m_param_combo[i].GetButtonPointer().IconYGap(3);
       if(!m_param_combo[i].CreateComboBox("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_combo[i]);
      // --- Do NOT call Hide() here - CompletedGUI() (called after this function)
      // --- runs FormAvailableElementsArray() which only includes VISIBLE elements
      // --- in m_available_elements[]. Hiding early means MOUSE_MOVE events never
      // --- reach the combo button later (even after Show()), so the dropdown arrow
      // --- click silently does nothing. ShowIndicatorParameterForm() manages
      // --- show/hide correctly AFTER CompletedGUI has already registered everything.
     }
    //For Button Add
     m_btn_add_indicator.MainPointer(m_tabs_main_setting_config);
     m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_add_indicator);
     m_btn_add_indicator.AutoXResizeMode(false);
     m_btn_add_indicator.XSize(80);
     m_btn_add_indicator.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);            
     bool created = m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
     if(!created) return false;
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_add_indicator);
    //For Button Save
     m_btn_save_indicator.MainPointer(m_tabs_main_setting_config);
     m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_save_indicator);
     m_btn_save_indicator.AutoXResizeMode(false);
     m_btn_save_indicator.XSize(80);
     m_btn_save_indicator.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);          
     bool created_save = m_btn_save_indicator.CreateButton("Save", x_gap + 85, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
     if(!created_save) return false;
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_indicator);
     for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
      {
       m_param_labels[i].Update(true);
       m_param_edits[i].Update(true);
      }
     m_btn_add_indicator.Update(true);
     m_btn_save_indicator.Update(true);
    return true;
   }
  // =====================================================================
  // --- Col 4 checkbox: Tang 2 controls Tang 3 only - never touches PureData.
  // --- The table already auto-toggled the icon before sending this event, so
  // --- SelectedImageIndex(4,row) tells us the state to APPLY (0=show, 1=hide).
  // --- Matched by ind.Handle(), not by name - two instances of the same type
  // --- with different params can share the same native chart-assigned name.
  // --- Detaches every chart line currently representing this indicator (Layer 3 mirror,
  // --- handle = join key). Shared by the per-row Hide toggle, per-row Remove, and
  // --- OnDeinitEvent's full sweep (BugNote 2026-07-18: Layer 1 indicators left shown
  // --- on chart - BBands/PSAR/AMA/hand-added MAs - were never detached on final EA
  // --- removal, only the SignalMarkers overlay was; this closes that gap for every row).
  void CGUIPannel::DetachIndicatorFromChart(CIndicatorDE *indicator)
   {
    if(indicator == NULL) return;
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return;
    for(int win = chart.WindowsTotal() - 1; win >= 0; win--)
     {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int i = wnd.IndicatorsTotal() - 1; i >= 0; i--)
       {
        CWndInd *wnd_ind = wnd.GetIndicatorByIndex(i);
        if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
            ChartIndicatorDelete(0, win, wnd_ind.Name());
       }
     }
   }
  // --- Does this Layer 3 line represent this Layer 1 instance?
  // --- Fast path: shared slot - only lines WE attached (ChartIndicatorAdd with our own
  // --- handle). A HAND-ADDED line is a SEPARATE terminal instance with its own slot
  // --- (proven 18:58 log: line handle=17 vs owned=18 for identical SAR(0.05,0.20)),
  // --- so fall back to the template identity: type+params via IndicatorParameters.
  // --- The line's slot stays readable forever because nobody ever releases it.
  bool CGUIPannel::LineRepresentsIndicator(const int line_handle, CIndicatorDE *indicator)
   {
    if(line_handle == INVALID_HANDLE || indicator == NULL) return false;
    if(line_handle == indicator.Handle())
     {
      // --- DEBUG LineRepresentsIndicator FAST-MATCH - removed 2026-07-14, fired every row every tick
      //::Print("DEBUG CGUIPannel::LineRepresentsIndicator FAST-MATCH line_handle=", line_handle,
      //        " own_handle=", indicator.Handle());
       return true;
     }
    ENUM_INDICATOR type;
    MqlParam params[];
    if(IndicatorParameters(line_handle, type, params) < 0) return false;
    if(type != indicator.TypeIndicator()) return false;
    MqlParam own_params[];
    indicator.GetMqlParams(own_params);
    bool eq = IsEqualMqlParamArrays(own_params, params);
    return eq;
   }
  // --- True when the CURRENT chart displays this indicator instance. The Layer 3 mirror
  // --- (CChartObjCollection -> CWndInd) stores the real slot handle, and MQL5 slots are
  // --- program-wide: the line of an instance Layer 1 owns carries Layer 1's own handle
  // --- number - the handle is the exact join key (names have different formats:
  // --- chart line "SAR(0.05,0.2)" vs CIndicatorDE::ShortName "SAR(BTCUSDm,M1)").
  bool CGUIPannel::IsIndicatorShownOnChart(CIndicatorDE *indicator)
   {
    if(indicator == NULL) return false;
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return false;
    for(int win = 0; win < chart.WindowsTotal(); win++)
    {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
        {
        CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
        if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
          {
            // --- DEBUG IsIndicatorShownOnChart - removed 2026-07-14, fired every row every tick
            //::Print("DEBUG IsIndicatorShownOnChart indicator_handle=", indicator.Handle(),
            //        " -> MATCHED line '", wnd_ind.Name(), "' handle=", wnd_ind.Handle());
            return true;
          }
        }
    }
    return false;
   }
  void CGUIPannel::OnClickToggleShowIndicatorOnChart(const string sname, const int row)
   {
    if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
    CIndicatorDE *ind = m_table_indicator_ptrs[row];
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
  // --- Col 2/3 checkboxes: per-template Buy/Sell signal filters. The table already
  // --- flipped the checkbox image before this handler fires; BuildAndWriteSignalBridge
  // --- reads the checkbox states live via TemplateBuySellFor, so a toggle just needs the
  // --- watermark rewound so the very next write is a full, immediate rewrite.
  void CGUIPannel::OnClickToggleBuySignal(const string sname, const int row)
   {
        UpdateSignalBridgeTemplateFlags();
        m_bridge_writer.ResetSignalBridge();
   }
  void CGUIPannel::OnClickToggleSellSignal(const string sname, const int row)
   {
    UpdateSignalBridgeTemplateFlags();
    m_bridge_writer.ResetSignalBridge();
   }  
  //+------------------------------------------------------------------+
  //| Called ONCE right after the initial RefreshIndicatorTable() (see |
  //| OnInitEvent) - pulls the Buy/Sell state CTimeSeriesEngine::       |
  //| LoadConfigurationFromJSON() cached while loading indicators_config|
  //| .json and applies it to the matching m_table_indicator rows, so a |
  //| saved Buy/Sell setting survives an EA restart instead of          |
  //| resetting to OFF.                                                 |
  //+------------------------------------------------------------------+
  // --- Also applies Sound/Message (col 5/6) despite the name - kept the original name to avoid
  // --- touching its one call site's context; extended in place 2026-07-17.
  void CGUIPannel::ApplyLoadedIndicatorBuySell(void)
   {
    if(m_time_series_engine == NULL) return;
    string types[], param_keys[];
    bool buys[], sells[], sounds[], messages[];
    m_time_series_engine.GetLoadedTemplateSettings(types, param_keys, buys, sells, sounds, messages);
    if(ArraySize(types) == 0) return;

    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);

    int rows = ArraySize(m_table_indicator_ptrs);
    bool any_changed = false;
    for(int row = 0; row < rows; row++)
     {
      CIndicatorDE *ind = m_table_indicator_ptrs[row];
      if(ind == NULL) continue;
      string type_key, params_key;
      BuildTemplateMatchKey(ind, catalog, type_key, params_key);
      for(int q = 0; q < ArraySize(types); q++)
       {
        if(types[q] != type_key || param_keys[q] != params_key) continue;
        m_table_indicator_template.ChangeImage(2, row, buys[q]     ? 0 : 1);
        m_table_indicator_template.ChangeImage(3, row, sells[q]    ? 0 : 1);
        m_table_indicator_template.ChangeImage(5, row, sounds[q]   ? 0 : 1);
        m_table_indicator_template.ChangeImage(6, row, messages[q] ? 0 : 1);
        any_changed = true;
            break;
        }
      }
      if(any_changed) m_table_indicator_template.Update(true);
   }
  //+------------------------------------------------------------------+
  //| Build the Col2 display label ("ShortName  (params)") for an      |
  //| indicator - shared by the row-rebuild path and the row-identity  |
  //| key used to keep per-tick updates aligned after a user sort.     |
  //+------------------------------------------------------------------+
  string CGUIPannel::BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[])
   {
    string short_name = "";
    for(int c = 0; c < ::ArraySize(catalog); c++)
      if(catalog[c].type == ind.TypeIndicator()) { short_name = catalog[c].name; break; }
    if(short_name == "") short_name = ind.GetTypeDescription();
    // --- Same schema the Add form uses (README: Tang 1 metadata). schema[i].choices
    // marks an enum-like param (Method, Applied Price, ...) - stored integer_value is
    // always the REAL MQL5 enum value (never a bare combo index), so decode it back to
    // text via the matching CommonDELib.mqh XxxDescription() - dispatched by comparing
    // choices against the 4 known constants, no separate "kind" needed.
    SIndicatorParam schema[];
    GetIndicatorParamSchema(ind.TypeIndicator(), schema);
    MqlParam mql_params[];
    ind.GetMqlParams(mql_params);
    string pvalues = "";
    for(int i = 0; i < ::ArraySize(mql_params); i++)
     {
      if(i > 0) pvalues += ", ";
      string choices = (i < ::ArraySize(schema)) ? schema[i].choices : "";
      if(choices == PRICE_CHOICES)
        pvalues += AppliedPriceDescription((ENUM_APPLIED_PRICE)mql_params[i].integer_value);
      else if(choices == CALCULATION_METHOD_CHOICES)
        pvalues += AveragingMethodDescription((ENUM_MA_METHOD)mql_params[i].integer_value);
      else if(choices == VOLUME_CHOICES)
        pvalues += AppliedVolumeDescription((ENUM_APPLIED_VOLUME)mql_params[i].integer_value);
      else if(choices == STOCH_PRICE_CHOICES)
        pvalues += StochPriceDescription((ENUM_STO_PRICE)mql_params[i].integer_value);
      else if(mql_params[i].type == TYPE_DOUBLE)
        pvalues += ::DoubleToString(mql_params[i].double_value, 2);
      else
        pvalues += ::IntegerToString((int)mql_params[i].integer_value);
     }
      return short_name + (pvalues != "" ? "  (" + pvalues + ")" : "");
   }
  //+------------------------------------------------------------------+
  //| Builds the SAME (type, params-as-text) key CTimeSeriesEngine::   |
  //| SaveConfigurationToJSON writes/LoadConfigurationFromJSON parses -|
  //| NOT BuildIndicatorLabel's pvalues (that rounds doubles to 2      |
  //| decimals for display; the saved file uses 8, so matching against|
  //| it would silently fail for any non-integer param).               |
  //+------------------------------------------------------------------+
  void CGUIPannel::BuildTemplateMatchKey(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[], string &type_key, string &params_key)
   {
    type_key = "";
    for(int c = 0; c < ArraySize(catalog); c++)
      if(catalog[c].type == ind.TypeIndicator()) { type_key = catalog[c].name; break; }

    SIndicatorParam schema[];
    GetIndicatorParamSchema(ind.TypeIndicator(), schema);
    MqlParam params[];
    ind.GetMqlParams(params);

    params_key = "";
    for(int p = 0; p < ArraySize(params); p++)
     {
      if(p > 0) params_key += ",";
       string choices = (p < ArraySize(schema)) ? schema[p].choices : "";
      if(choices == PRICE_CHOICES)
        params_key += AppliedPriceDescription((ENUM_APPLIED_PRICE)params[p].integer_value);
      else if(choices == CALCULATION_METHOD_CHOICES)
        params_key += AveragingMethodDescription((ENUM_MA_METHOD)params[p].integer_value);
      else if(choices == VOLUME_CHOICES)
        params_key += AppliedVolumeDescription((ENUM_APPLIED_VOLUME)params[p].integer_value);
      else if(choices == STOCH_PRICE_CHOICES)
        params_key += StochPriceDescription((ENUM_STO_PRICE)params[p].integer_value);
      else if(params[p].type == TYPE_DOUBLE)
        params_key += ::DoubleToString(params[p].double_value, 8);
      else
        params_key += ::IntegerToString((int)params[p].integer_value);
     }
   }
  // --- Resolve a Layer 3 line to the Layer 1 instance (current symbol/TF) it represents,
  // --- or NULL when the line is foreign. Same fast/slow paths as LineRepresentsIndicator.
  CIndicatorDE *CGUIPannel::OwnedInstanceOfLine(const int line_handle)
   {
    if(line_handle == INVALID_HANDLE || m_time_series_engine == NULL) return NULL;
     CIndicatorDE *owned = m_time_series_engine.GetIndicatorByHandle(line_handle);
    if(owned != NULL) return owned;
    for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
      if(LineRepresentsIndicator(line_handle, m_table_indicator_ptrs[row]))
        return m_table_indicator_ptrs[row];
      return NULL;
   }
   // --- Col 0 button: Tang 1 control - removes this whole template (same type+params,
   // --- regardless of symbol/timeframe) from PureData. Does NOT touch the JSON file
   // --- yet (that part - persisting the removal so it doesn't come back on next
   // --- EA restart - is still open, deferred from the earlier discussion).
  void CGUIPannel::OnClickRemoveIndicator(const string sname, const int row)
   {
    if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
    // ref_indicator is BORROWED (CIndicatorsCollection owns it) - it lives inside the
    // same list the loop below deletes from, so it may dangle partway through.
     CIndicatorDE *ref_indicator = m_table_indicator_ptrs[row];
     if(ref_indicator == NULL || m_IndicatorsCollection == NULL || m_time_series_engine == NULL) return;
     //--- Audit line: template removals are destructive and reachable from several paths
     //--- (X icon, HandleChartIndicatorChange) - always log who goes and from which row
     ::Print(__FUNCTION__, " > row=", row, " '", m_table_indicator_names[row],
              "' ref handle=", ref_indicator.Handle());
     CArrayObj *list = m_IndicatorsCollection.GetList();
     if(list == NULL) return;
     // --- Capture ref_indicator's type/params into plain local values NOW, before the
     // --- loop deletes it (it matches its own template) - never dereference it after.
      ENUM_INDICATOR ref_type = ref_indicator.TypeIndicator();
      MqlParam ref_params[];
      ref_indicator.GetMqlParams(ref_params);
      for(int i = list.Total() - 1; i >= 0; i--)
       {
        // indicator is BORROWED (CIndicatorsCollection owns it via 'list' FreeMode)
         CIndicatorDE *indicator = list.At(i);
         if(indicator == NULL || indicator.TypeIndicator() != ref_type) continue;
        // --- Same template = same type + same params, regardless of symbol/TF
         MqlParam params[];
         indicator.GetMqlParams(params);
         if(!IsEqualMqlParamArrays(params, ref_params)) continue;
        // --- Release the Signal FIRST: CSignalsCollection borrows this indicator's
        // --- pointer (m_indicator_list[] + the signal's own m_indicator), so deleting
        // --- the indicator before its signal would leave both dangling.
         m_time_series_engine.GetSignalsCollection().DeleteSignal(indicator);
        // --- Detach from chart if currently shown (Layer 3 mirror, handle = join key).
        // --- The slot itself dies exactly once, in ~CIndicatorDE via list.Delete below.
         DetachIndicatorFromChart(indicator);
         list.Delete(i);   // CArrayObj FreeMode -> ~CIndicatorDE -> IndicatorRelease(handle)
       }
     // --- Drop exactly this row (Library CTable::DeleteRow shifts the rest up) and keep
     // --- the parallel arrays aligned. No DeleteAllRows here (README 5a/5c).
       int rows_after = ArraySize(m_table_indicator_ptrs) - 1;
       for(int r = row; r < rows_after; r++)
        {
         m_table_indicator_names[r] = m_table_indicator_names[r + 1];
         m_table_indicator_ptrs[r]  = m_table_indicator_ptrs[r + 1];
         m_settings_cache_state[r]  = m_settings_cache_state[r + 1];
        }
       ArrayResize(m_table_indicator_names, rows_after);
       ArrayResize(m_table_indicator_ptrs,  rows_after);
       ArrayResize(m_settings_cache_state,  rows_after);
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
#endif // CGUIPANNEL_TABSETTINGINDICATOR_MQH
