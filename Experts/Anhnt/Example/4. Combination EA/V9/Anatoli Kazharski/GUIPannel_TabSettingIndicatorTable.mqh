//+------------------------------------------------------------------+
//|                           GUIPannel_TabSettingIndicatorTable.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGINDICATORTABLE_MQH
#define CGUIPANNEL_TABSETTINGINDICATORTABLE_MQH
 #include "GUIPannel.mqh"
 //+------------------------------------------------------------------------------------+
 //| catalog[] type->group lookup - shared by every call site that needs a Group for    |
 //| ChartIndicatorAdd's sub_window calc (Show/Add/Replace). No live CIndicatorDE       |
 //| needed - catalog[] already carries the type->group mapping.                        |
 //+------------------------------------------------------------------------------------+
 ENUM_INDICATOR_GROUP CGUIPannel::GetIndicatorGroupForType(const ENUM_INDICATOR type)
  {
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int c = 0; c < ArraySize(catalog); c++)
      if(catalog[c].ind_type == type) return catalog[c].group;
   return INDICATOR_GROUP_OSCILLATOR;
  }
 //+----------------------------------------------------------------------------+
 //| Creates m_table_indicator_template (7 columns: Indicator+delete icon,      |
 //| Group, Buy, Sell, Show-on-chart, Sound, Message).                          |
 //+----------------------------------------------------------------------------+
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
 //+------------------------------------------------------------------------------------+
 //| One row per m_indicator_template_setting[] entry. Pure view - grows/               |
 //| shrinks ONLY by reading the array (append/shrink happen at the point of            |
 //| intent elsewhere); Layer 2 decides, Layer 1 obeys, this never scans                |
 //| Layer 1's live collection itself.                                                  |
 //+------------------------------------------------------------------------------------+
 // --- Append happens at the point of intent in OnClickAddIndicatorBtn/SynIndicatorOnChart's
 // --- CHANGE branch/ScanIndicatorOnChart, right after each one decides a new template
 // --- exists; shrink happens in RemoveIndicatorFromTemplateSetting() before it calls back in here.
 void CGUIPannel::RefreshTableIndicator(void)
  {
   int count = ArraySize(m_indicator_template_setting);   // the array is the authoritative row count
   if(count == 0)
    {
     if(ArraySize(m_bool_table_indicator_template_cache_show) == 0) return; // already showing the empty state - leave the table alone
     m_table_indicator_template.DeleteAllRows();
     // --- DeleteAllRows() leaves 1 row behind but only clears TEXT+BackColor for it - the per-cell
     // --- Images array (SetImages) is untouched, and CTable::RedrawCell draws whatever
     // --- ImagesTotal(col,row)>0 regardless of CellType (confirmed via Table.mqh source), so a
     // --- CellType-only reset does NOT hide the leftover row's stale icons (delete X, checkboxes)
     // --- from the LAST real SetIndicatorTableRow() paint. The only place Images actually gets
     // --- cleared is CellInitialize() (private - unreachable directly), which AddRow() calls
     // --- internally for the row it inserts. So: insert a fresh clean row at 0 (pushes the dirty
     // --- leftover down to 1), then DeleteRow(1) truncates the dirty one away - net exactly 1 row,
     // --- Images included, no Library edit needed.
      m_table_indicator_template.AddRow(0);
      m_table_indicator_template.DeleteRow(1);
     ArrayResize(m_bool_table_indicator_template_cache_show, 0);
     m_table_indicator_template.Update(true);
     return;
    }
   if(count != ArraySize(m_bool_table_indicator_template_cache_show))
    {
     m_table_indicator_template.DeleteAllRows();
     // --- redraw=true on the LAST row only: AddRow() only recalculates the table's visible-area
     // --- size (CTable::RecalculateAndResizeTable) when told to - skipping it on every row and
     // --- doing it once at the end avoids the black/smeared row-overflow bug (README/BugNote
     // --- 2026-07-14) without paying the recalculation cost on every single row.
     for(int i = 0; i < count - 1; i++)   // DeleteAllRows leaves one physical row behind
        m_table_indicator_template.AddRow(i, i == count - 2);
     ArrayResize(m_bool_table_indicator_template_cache_show, count);
    }
   for(int row = 0; row < count; row++)
      SetIndicatorTableRow(row);
   m_table_indicator_template.Update(true);
  }
 //+------------------------------------------------------------------------------------+
 //| Paints row from m_indicator_template_setting[row] directly - the single            |
 //| source of truth. Pure Data - no Layer 1 instance needed at all anymore:            |
 //| label (BuildIndicatorTextLabel) and group both derive from (type_enum,raw_params)  |
 //| + catalog[] alone.                                                                  |
 //+------------------------------------------------------------------------------------+
 void CGUIPannel::SetIndicatorTableRow(const int row)
  {
   if(row < 0 || row >= ArraySize(m_indicator_template_setting)) return;
   uint delete_icon[]   = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   uint chk[]           = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
   uint show_on_chart[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
   string group_names[] = {"Trend", "Oscillator", "Volumes", "Arrows"};
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   ENUM_INDICATOR type = m_indicator_template_setting[row].type_enum;
   string label = BuildIndicatorTextLabel(type, m_indicator_template_setting[row].raw_params, catalog);
   // --- Col 0: red Close (delete) icon + label - click detection covers the icon only
    m_table_indicator_template.CellType(0, row, CELL_BUTTON);
    m_table_indicator_template.SetImages(0, row, delete_icon);
    m_table_indicator_template.ChangeImage(0, row, 0);
    m_table_indicator_template.SetValue(0, row, "        " + label);   // leading spaces clear the icon
   // --- Col 1: group name - catalog[] already carries the type->group mapping, no live instance needed
    int group = -1;
    for(int c = 0; c < ArraySize(catalog); c++)
      if(catalog[c].ind_type == type) { group = (int)catalog[c].group; break; }
    string gname = (group >= 0 && group < 4) ? group_names[group] : "Other";
    m_table_indicator_template.SetValue(1, row, "  " + gname);
    bool row_buy     = m_indicator_template_setting[row].buy;
    bool row_sell    = m_indicator_template_setting[row].sell;
    bool row_sound   = m_indicator_template_setting[row].sound;
    bool row_message = m_indicator_template_setting[row].message;
   // --- Col 2/3: Buy / Sell signal filters (opt-in per template; TemplateBuySellFor reads
   // --- these checkboxes live, toggles rewrite the bridge file)
    m_table_indicator_template.CellType(2, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(2, row, chk);
    m_table_indicator_template.ChangeImage(2, row, row_buy ? 0 : 1);
    m_table_indicator_template.CellType(3, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(3, row, chk);
    m_table_indicator_template.ChangeImage(3, row, row_sell ? 0 : 1);
   // --- Col 4: "shown on the CURRENT chart" checkbox
    bool shown = IsIndicatorShownOnChart(m_indicator_template_setting[row].type_enum, m_indicator_template_setting[row].raw_params);
    m_table_indicator_template.CellType(4, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(4, row, show_on_chart);
    m_table_indicator_template.ChangeImage(4, row, shown ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART);
   // --- Col 5/6: Sound / Message opt-in per template
    m_table_indicator_template.CellType(5, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(5, row, chk);
    m_table_indicator_template.ChangeImage(5, row, row_sound ? 0 : 1);
    m_table_indicator_template.CellType(6, row, CELL_CHECKBOX);
    m_table_indicator_template.SetImages(6, row, chk);
    m_table_indicator_template.ChangeImage(6, row, row_message ? 0 : 1);

    m_bool_table_indicator_template_cache_show[row] = shown;
  }
 //+------------------------------------------------------------------------------------+
 //| Per-chart part of the Settings table (col 4 "Show") - dirty-check only,            |
 //| no structural change.                                                              |
 //+------------------------------------------------------------------------------------+
 // --- m_bool_table_indicator_template_cache_show[] is always already correctly
 // --- sized+painted by the time this runs (every m_indicator_template_setting[] size
 // --- change funnels through RefreshTableIndicator() -> SetIndicatorTableRow(), which
 // --- writes this cache unconditionally for every row) - the ArrayResize below is just
 // --- a defensive safety net, not something this function's own callers rely on.
 void CGUIPannel::RefreshIndicatorTableShowColumn(void)
  {
   int tmpl_total = ArraySize(m_indicator_template_setting);
   if(ArraySize(m_bool_table_indicator_template_cache_show) != tmpl_total)
      ArrayResize(m_bool_table_indicator_template_cache_show, tmpl_total);
   bool any_changed = false;
   // --- Row count from m_indicator_template_setting[] (the live source of truth).
   // --- IsIndicatorShownOnChart takes (type,params) RAW directly - no need to resolve
   // --- a live CIndicatorDE instance via GetIndicatorForRow just for this check.
   for(int row = 0; row < tmpl_total; row++)
    {
     bool shown = IsIndicatorShownOnChart(m_indicator_template_setting[row].type_enum, m_indicator_template_setting[row].raw_params);
     if(shown == m_bool_table_indicator_template_cache_show[row]) continue;
     m_bool_table_indicator_template_cache_show[row] = shown;
     m_table_indicator_template.ChangeImage(4, row, shown ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART);
     m_table_indicator_template.BackColor(4, row, clrWhite, true);   // force this one cell to repaint
     any_changed = true;
    }
   if(any_changed)
     m_table_indicator_template.Update(false);
  }
 //+------------------------------------------------------------------------------------+
 //| Col 2/3 checkboxes: per-template Buy/Sell signal filters - writes into             |
 //| m_indicator_template_setting[row] (the live single-source-of-truth Save            |
 //| reads from) and resyncs the Signal Bridge.                                         |
 //+------------------------------------------------------------------------------------+
 // --- The table already flipped the checkbox image before this handler fires;
 // --- BuildAndWriteSignalBridge reads the checkbox states live via TemplateBuySellFor,
 // --- so a toggle just needs the watermark rewound so the very next write is a full,
 // --- immediate rewrite.
 void CGUIPannel::OnClickToggleBuySignal(const int row)
  {
        if(row >= 0 && row < ArraySize(m_indicator_template_setting))
           m_indicator_template_setting[row].buy = ((int)m_table_indicator_template.SelectedImageIndex(2, row) == 0);
        SyncIndicatorTemplateSettingToBridge();
        m_bridge_writer.ResetSignalBridge();
  }
 void CGUIPannel::OnClickToggleSellSignal(const int row)
  {
    if(row >= 0 && row < ArraySize(m_indicator_template_setting))
       m_indicator_template_setting[row].sell = ((int)m_table_indicator_template.SelectedImageIndex(3, row) == 0);
    SyncIndicatorTemplateSettingToBridge();
    m_bridge_writer.ResetSignalBridge();
  }
 //+------------------------------------------------------------------------------------+
 //| Col 5/6 checkboxes: Sound/Message alert opt-in - keeps                             |
 //| m_indicator_template_setting[row] live only, no Bridge involvement                 |
 //| (Sound/Message don't feed CSignalBridgeWriter, only Buy/Sell do).                  |
 //+------------------------------------------------------------------------------------+
 void CGUIPannel::OnClickToggleSoundAlert(const int row)
  {
   if(row >= 0 && row < ArraySize(m_indicator_template_setting))
      m_indicator_template_setting[row].sound = ((int)m_table_indicator_template.SelectedImageIndex(5, row) == 0);
  }
 void CGUIPannel::OnClickToggleMessageAlert(const int row)
  {
   if(row >= 0 && row < ArraySize(m_indicator_template_setting))
      m_indicator_template_setting[row].message = ((int)m_table_indicator_template.SelectedImageIndex(6, row) == 0);
  }
 //+----------------------------------------------------------------------------+
 //| Col 4 checkbox: toggles this indicator's visibility on the CURRENT         |
 //| chart (ChartIndicatorAdd / RemoveIndicatorFromChart).                      |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::OnClickToggleShowIndicatorOnChart(const int row)
  {
    if(row < 0 || row >= ArraySize(m_indicator_template_setting)) return;
    int new_state = (int)m_table_indicator_template.SelectedImageIndex(4, row);
    if(new_state == INDICATOR_HIDE_ON_CHART)   // Hide: pure Data identity, no Layer 1 instance needed
          RemoveIndicatorFromChart(m_indicator_template_setting[row].type_enum, m_indicator_template_setting[row].raw_params);
    else // Show: Handle via Layer 1 query, Group via catalog[] - no live pointer needed
     {
      if(m_time_series_engine == NULL) return;
      int handle = m_time_series_engine.GetIndicatorHandle(::Symbol(), (ENUM_TIMEFRAMES)::ChartPeriod(0),
                     m_indicator_template_setting[row].type_enum, m_indicator_template_setting[row].raw_params);
      if(handle == INVALID_HANDLE) return;
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
      ENUM_INDICATOR_GROUP group = GetIndicatorGroupForType(m_indicator_template_setting[row].type_enum);
      int sub_window = (group == INDICATOR_GROUP_TREND) ? 0 : subwindows;
      ::Print("MY DEBUG CGUIPannel::OnClickToggleShowIndicatorOnChart: ChartIndicatorAdd handle=", handle, " row=", row);
      ChartIndicatorAdd(0, sub_window, handle);
     }
        ChartRedraw();
  }
 //+------------------------------------------------------------------------------------+
 //| Col 0 button: thin row->identity wrapper - the real work lives in the              |
 //| identity-based RemoveIndicatorFromTemplateSetting() above, reusable from           |
 //| non-UI callers (e.g. SynIndicatorOnChart's CHANGE branch) too. Owns Layer 3        |
 //| detach, Layer 1 delete, and view resync - RemoveIndicatorFromTemplateSetting()     |
 //| itself only mutates m_indicator_template_setting[]/PureData.                       |
 //+------------------------------------------------------------------------------------+
 void CGUIPannel::OnClickRemoveIndicator(const int row)
  {
   if(row < 0 || row >= ArraySize(m_indicator_template_setting)) return;
   // --- Copy type/raw_params OUT to plain local values NOW - RemoveIndicatorFromTemplateSetting()
   // --- below splices/resizes m_indicator_template_setting[], so a reference straight into
   // --- row's own .raw_params[] would go stale/corrupt mid-call if not copied first.
   ENUM_INDICATOR ref_type = m_indicator_template_setting[row].type_enum;
   MqlParam ref_params[];
   ArrayResize(ref_params, ArraySize(m_indicator_template_setting[row].raw_params));
   for(int p = 0; p < ArraySize(ref_params); p++)
      ref_params[p] = m_indicator_template_setting[row].raw_params[p];
   // --- Detach from the CURRENT chart FIRST (Layer 3), THEN mutate Data, THEN command Layer 1 to
   // --- delete every symbol/TF instance - same order RemoveIndicatorFromTemplateSetting() used to
   // --- do internally, now split across caller + Data-only function ("Layer 2 decides, Layer 1
   // --- obeys": Data change is the deciding step, Layer 1 catches up after).
    RemoveIndicatorFromChart(ref_type, ref_params);
    RemoveIndicatorFromTemplateSetting(ref_type, ref_params);
    if(m_time_series_engine != NULL)
       m_time_series_engine.RemoveIndicatorFromAllSeries(ref_type, ref_params);
   // --- View resync - SyncIndicatorTemplateSettingToBridge() is NOT optional: skipping it leaves
   // --- the Bridge holding a dangling CIndicatorDE* for the row just destroyed above (see
   // --- RemoveIndicatorFromAllSeries's own dangling-pointer history).
    SyncIndicatorTemplateSettingToBridge();
    RefreshTableIndicator();
    SetValuesToTableIndicatorSymbolTFValue();
    SyncIndicatorTreeViewIcons();
    ChartRedraw();
  }
#endif // CGUIPANNEL_TABSETTINGINDICATORTABLE_MQH
