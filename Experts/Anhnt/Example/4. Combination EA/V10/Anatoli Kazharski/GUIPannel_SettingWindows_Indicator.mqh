//+------------------------------------------------------------------+
//|                           GUIPannel_SettingWindows_Indicator.mqh |
//| The library for the signal markers on chart                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SettingWindows_Indicator_MQH
#define CGUIPANNEL_SettingWindows_Indicator_MQH 
#include "GUIPannel.mqh" 
// For Setting Windows m_window_setting
 bool CGUIPannel::CreateWindowSetting(const string caption_text)
  {
   //--- Add a window pointer to the window array
    CWndContainer::AddWindow(m_window_setting);
   //Setting Properties
    m_window_setting.XSize(M_WINDOW_SETTING_WIDTH);
    m_window_setting.YSize(M_WINDOW_SETTING_HEIGHT);
    m_window_setting.FontSize(9);
    m_window_setting.IsMovable(true);
    m_window_setting.ResizeMode(true);
    m_window_setting.CloseButtonIsUsed(true);
    m_window_setting.CollapseButtonIsUsed(true);
    m_window_setting.TooltipsButtonIsUsed(true);
    m_window_setting.FullscreenButtonIsUsed(true);
    m_window_setting.MinimumXSize(M_WINDOW_SETTING_MIN_WIDTH);
    m_window_setting.MinimumYSize(M_WINDOW_SETTING_MIN_HEIGHT);
    m_window_setting.WindowType(W_DIALOG);    
   //Show Window at 30,30
    if(!m_window_setting.CreateWindow(m_chart_id, m_subwin, caption_text, 30, 30))
       return (false);
   //Set Icon after Create
    m_window_setting.IconFile(IMAGE_RESOURCE_BMP16_SETTING_PNG );
    m_window_setting.IconFileLocked(IMAGE_RESOURCE_BMP16_SETTING_PNG );
    return (true);
  }
 void CGUIPannel::ShowSettingWindow(void)
  {
    m_active_window_index = WindowIdx(m_window_setting);
    Show(m_active_window_index);
    HideAddIndicatorForm();    
    FormAvailableElementsArray();
    m_treeview_indicator.RedrawTreeList();   // force scrollbar recalc now that it's actually visible
  }
 void CGUIPannel::HideSettingWindow(void)
  {
    m_window_setting.Hide();
    m_active_window_index = WindowIdx(m_window_main);
    FormAvailableElementsArray();
  }
//For Tab Group on the left Setting Windows m_tabs_main_setting_config 
 //+----------------------------------------------------------------------------------------------+
 //| Create a tab group m_tabs_main_setting_config for Settings at Setting m_window_setting       |
 //+----------------------------------------------------------------------------------------------+
 bool CGUIPannel::CreateTabSettingConfig(const int x_gap, const int y_gap)
  {
    string tabs_names[TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL] = {"Indicator", "Symbol TF","Candle Pattern", "Marker", "Sound"};    
    m_tabs_main_setting_config.MainPointer(m_window_setting);
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
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_tabs_main_setting_config);    
    return (true);
  } 
 // For TreeView Indicator m_treeview_indicator on the left m_window_setting 
  bool CGUIPannel::CreateTreeView_IndicatorTemplateSetting(const int x_gap, const int y_gap)
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
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_treeview_indicator);       
    return true;
   }
  void CGUIPannel::PopulateTreeView_IndicatorTemplateSetting(void)
   {    
    //Seting Root Node for m_treeview_indicator base on ENUM_INDICATOR_GROUP in TimeseriesDefines.mqh
    ENUM_INDICATOR_GROUP group_values[4] = {INDICATOR_GROUP_TREND, 
      INDICATOR_GROUP_OSCILLATOR, 
      INDICATOR_GROUP_VOLUMES, 
      INDICATOR_GROUP_ARROWS}; 

    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);    
    for(int g = 0; g < 4; g++)
     {
      int root_li = m_treeview_indicator.ItemsTotal();
      //m_group_tree_pos[g] = root_li;
      m_treeview_indicator.AddTreeItem(root_li,
                                    -1,                          // prev_node_list_index = -1 (root)
                                    GetIndicatorGroupName(group_values[g]),//Node Name IndicatorGroupName in TimeseriesDELib.mqh
                                    IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,     //Inactive Icon
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
        m_type_node_value[sz] = catalog[i].ind_type;
        k++;
       }
     }
   }
  // For Syn and Highlight active Indicator in Template
  void CGUIPannel::SyncTreeView_IndicatorTemplateSetting(void)
   {
    if(m_indicator_template_manager == NULL) return;
    // Reset every Group node to inactive FIRST - the loop below only ever SETS a group's icon
    // to active (blue) when it has an active type, never un-sets it.
    for(int i = 0; i < ArraySize(m_type_node_li); i++)
     {
      int group_li = m_treeview_indicator.ItemPrevNode(m_type_node_li[i]);
      CTreeItem *group_item = m_treeview_indicator.ItemPointer(group_li);
      if(group_item != NULL)
        group_item.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
     }
    for(int i = 0; i < ArraySize(m_type_node_li); i++)
     {
      ENUM_INDICATOR type = m_type_node_value[i];
      bool active = false;
      for(int r = 0; r < m_indicator_template_manager.Total(); r++)
        {
         CIndicatorSetting *row = m_indicator_template_manager.At(r);
         if(row != NULL && row.TypeEnum() == type) { active = true; break; }
        }
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
 //For Table Indicator at Bottom 
  //+----------------------------------------------------------------------------+
  //| Creates m_table_indicator_template (7 columns: Indicator+delete icon,      |
  //| Group, Buy, Sell, Show-on-chart, Sound, Message).                          |
  //+----------------------------------------------------------------------------+
  bool CGUIPannel::CreateTable_IndicatorTemplateSetting(const int x, const int y)
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
    // --- 8 columns: col 0 merges the old icon-only "show on T3" column with the    
    // --- Col 7 (width=0, hidden): carries the row's real m_indicator_template_manager    
     m_table_indicator_template.TableSize(8, 20);
     int widths[8]    = {180, 70, 40, 40, 40, 40, 40, 0};
     int img_x_off[8] = {3,   0,  10, 10, 10, 10, 10, 0};
     int img_y_off[8] = {3,   0,  3,  3,  3,  3,  3,  0};
     ENUM_ALIGN_MODE align[8] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
     m_table_indicator_template.ColumnsWidth(widths);
     m_table_indicator_template.ImageXOffset(img_x_off);
     m_table_indicator_template.ImageYOffset(img_y_off);
     m_table_indicator_template.TextAlign(align);
     m_table_indicator_template.HeaderYSize(24);
     if(!m_table_indicator_template.CreateTable(x, y)) return false;
    //Set Header text
     m_table_indicator_template.SetHeaderText(0, "Indicator");
     m_table_indicator_template.SetHeaderText(1, "Group");
    // Checkbox to include this indicator's signal in the Signal Bridge (feeds SignalMarkers.mq5's    
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
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_table_indicator_template);
    return true;
   }   
  void CGUIPannel::InitializeTable_IndicatorTemplateSetting(void)
   {
    if(m_indicator_template_manager == NULL) return;
    int count        = m_indicator_template_manager.Total();
    int current_rows = (int)m_table_indicator_template.RowsTotal();
    if(count == 0)
     {      
      m_table_indicator_template.DeleteAllRows();
      m_table_indicator_template.AddRow(0);
      m_table_indicator_template.DeleteRow(1);
      m_table_indicator_template.Update(true);
      return;
     }
    if(count != current_rows)
     {
      m_table_indicator_template.DeleteAllRows();
      for(int i = 0; i < count - 1; i++)   // DeleteAllRows leaves one physical row behind
         m_table_indicator_template.AddRow(i, i == count - 2);
     }
    for(int row = 0; row < count; row++)
      UpdateRow_IndicatorTemplateSetting(row);
    m_table_indicator_template.Update(true);
   }
  //+------------------------------------------------------------------------------------+
  //| Appends exactly 1 new row at the end - m_indicator_template_manager.Add_IndicatorTemplateSetting() always |
  //| appends its new entry at Total()-1, so the table's new last physical row lines up  |
  //| with it directly. AddRow(row,false) only grows the row arrays - CTable::AddRow      |
  //| only calls RecalculateAndResizeTable() (the thing that actually resizes the canvas  |
  //| and draws the row) when redraw=true, and Update(false) never calls it either (it    |
  //| just flushes what's already drawn) - so a genuinely-new row stays invisible forever |
  //| with redraw=false throughout (confirmed on the SymbolTF table's identical pattern   |
  //| via MY DEBUG log: RowsTotal grew correctly, row never appeared on screen). Values   |
  //| are painted into the row (UpdateRow_IndicatorTemplateSetting) BEFORE the single     |
  //| Update(true) below, so this is exactly one full redraw pass, not two - paid only    |
  //| when a row is genuinely added (rare, user-triggered), unrelated to the old per-tick |
  //| flicker bug FeatureNote/FixMainWindowFlicker.md fixed.                              |
  //+------------------------------------------------------------------------------------+
  void CGUIPannel::AddRow_IndicatorTemplateSetting(void)
   {
    if(m_indicator_template_manager == NULL) return;
    int row = (int)m_table_indicator_template.RowsTotal();
    string first_col0 = m_table_indicator_template.GetValue(0, 0); StringTrimLeft(first_col0);
    bool placeholder_only = (row == 1 && first_col0 == "");   // reuse the blank baseline row
    if(placeholder_only)
       row = 0;
    else
       m_table_indicator_template.AddRow(row, false);
    UpdateRow_IndicatorTemplateSetting(row);
    m_table_indicator_template.Update(true);
   }
  //+------------------------------------------------------------------------------------+
  //| Paints row from m_indicator_template_setting[row] directly - the single            |
  //| source of truth. Pure Data - no Layer 1 instance needed at all anymore:            |
  //| label (BuildIndicatorTextLabel) and group both derive from (type_enum,raw_params)  |
  //| + catalog[] alone.                                                                  |
  //+------------------------------------------------------------------------------------+
  void CGUIPannel::UpdateRow_IndicatorTemplateSetting(const int row)
   {
    if(m_indicator_template_manager == NULL) return;
    CIndicatorSetting *entry = m_indicator_template_manager.At(row);
    if(entry == NULL) return;
    uint delete_icon[]   = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
    uint chk[]           = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
    //Col 0: delete icon + label
     m_table_indicator_template.CellType(0, row, CELL_BUTTON);
     m_table_indicator_template.SetImages(0, row, delete_icon);
     m_table_indicator_template.ChangeImage(0, row, 0);
     m_table_indicator_template.SetValue(0, row, "        " + entry.DisplayLabel());   
     ENUM_INDICATOR_GROUP group = GetIndicatorGroupForType(entry.TypeEnum());
     m_table_indicator_template.SetValue(1, row, "  " + GetIndicatorGroupName(group));
    //Col 2-6: checkboxes
     m_table_indicator_template.CellType(2, row, CELL_CHECKBOX);
     m_table_indicator_template.SetImages(2, row, chk);
     m_table_indicator_template.ChangeImage(2, row, entry.BuySignal() ? 0 : 1);
     m_table_indicator_template.CellType(3, row, CELL_CHECKBOX);
     m_table_indicator_template.SetImages(3, row, chk);
     m_table_indicator_template.ChangeImage(3, row, entry.SellSignal() ? 0 : 1);
     m_table_indicator_template.CellType(4, row, CELL_CHECKBOX);
     m_table_indicator_template.SetImages(4, row, chk);
     m_table_indicator_template.ChangeImage(4, row, entry.ShowOnChart() ? 0 : 1);
     m_table_indicator_template.CellType(5, row, CELL_CHECKBOX);
     m_table_indicator_template.SetImages(5, row, chk);
     m_table_indicator_template.ChangeImage(5, row, entry.SoundAlert() ? 0 : 1);
     m_table_indicator_template.CellType(6, row, CELL_CHECKBOX);
     m_table_indicator_template.SetImages(6, row, chk);
     m_table_indicator_template.ChangeImage(6, row, entry.MessageAlert() ? 0 : 1);
    //Col 7 (hidden, width=0): real m_indicator_template_manager index - "row" here is only
    //correct at paint time (called from InitializeTable_IndicatorTemplateSetting's 0..count-1 loop); once the
    //user sorts by a header, CTable::Swap() carries this cell along with the rest of the
    //row, so click handlers can always recover the true index via GetValue(7,row).
     m_table_indicator_template.SetValue(7, row, IntegerToString(row));
   } 
  void CGUIPannel::OnClickToggleShowIndicatorOnChart(const int row)
   {
    if(m_indicator_template_manager == NULL) return;
    int real_index = (int)StringToInteger(m_table_indicator_template.GetValue(7, row));   // row = vị trí hiển thị sau sort, không phải index thật
    int new_state = (int)m_table_indicator_template.SelectedImageIndex(4, row);
    // Data only - EA reacts to INDICATOR_TEMPLATE_MANAGER_EVENT_SETTING_CHANGED to attach/detach
    // on chart (CGUIPannel no longer holds CChartObjCollection).
    m_indicator_template_manager.UpdateRow_IndicatorTemplateSetting_ShowColumn(real_index, new_state != INDICATOR_HIDE_ON_CHART);
   }
  void CGUIPannel::SyncTable_IndicatorTemplateSetting(void)
   {
    // Data only - reads entry.ShowOnChart() straight from the Manager (Single Source
    // of Truth) and repaints the icon. The live scan against real chart state now
    // happens in EA (owns CChartObjCollection) via Manager::UpdateRow_IndicatorTemplateSetting_ShowColumn() -
    // CGUIPannel never touches the chart directly anymore.
    if(m_indicator_template_manager == NULL) return;
    int tmpl_total = m_indicator_template_manager.Total();
    bool any_changed = false;
    for(int row = 0; row < tmpl_total; row++)
     {
      CIndicatorSetting *entry = m_indicator_template_manager.At(row);
      if(entry == NULL) continue;
      bool shown = entry.ShowOnChart();
      bool painted_shown = ((int)m_table_indicator_template.SelectedImageIndex(4, row) != INDICATOR_HIDE_ON_CHART);
      if(painted_shown == shown) continue;   // dirty-check against what's already painted
      m_table_indicator_template.ChangeImage(4, row, shown ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART);
      m_table_indicator_template.BackColor(4, row, clrWhite, true);
      any_changed = true;
     }
    if(any_changed)
      m_table_indicator_template.Update(false);
   }
  void CGUIPannel::OnClickRemoveIndicator(const int row)
   {
    if(m_indicator_template_manager == NULL) return;
    int real_index = (int)StringToInteger(m_table_indicator_template.GetValue(7, row));   // row = vị trí hiển thị sau sort, không phải index thật
    CIndicatorSetting *entry = m_indicator_template_manager.At(real_index);
    if(entry == NULL) return;
    ENUM_INDICATOR type = entry.TypeEnum();
    MqlParam params[]; entry.GetRawParams(params);
    // Data only - fires INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE(+TYPE_DELETE). EA (owns
    // ChartObjCollection) reacts via Manager::GetLastRemoved() to detach from chart;
    // GUIPannel_Lifecycle.mqh already reacts to refresh Table/TreeView.
    m_indicator_template_manager.Delete_IndicatorTemplateSetting(type, params);
   }
  void CGUIPannel::OnClickToggleBuySignal(const int row)
   {
    if(m_indicator_template_manager == NULL) return;
    int real_index = (int)StringToInteger(m_table_indicator_template.GetValue(7, row));
    CIndicatorSetting *entry = m_indicator_template_manager.At(real_index);
    if(entry == NULL) return;
    entry.BuySignal((int)m_table_indicator_template.SelectedImageIndex(2, row) == 0);
    // TODO: Signal Bridge sync (SyncIndicatorTemplateSettingToBridge/ResetSignalBridge) not
    // wired to the Manager yet - needs its own design pass, same as Layer 1.
    Print("MY DEBUG CGUIPannel::OnClickToggleBuySignal: Need update - Bridge sync not wired");
   }
  void CGUIPannel::OnClickToggleSellSignal(const int row)
   {
    if(m_indicator_template_manager == NULL) return;
    int real_index = (int)StringToInteger(m_table_indicator_template.GetValue(7, row));
    CIndicatorSetting *entry = m_indicator_template_manager.At(real_index);
    if(entry == NULL) return;
    entry.SellSignal((int)m_table_indicator_template.SelectedImageIndex(3, row) == 0);
    // TODO: Signal Bridge sync (SyncIndicatorTemplateSettingToBridge/ResetSignalBridge) not
    // wired to the Manager yet - needs its own design pass, same as Layer 1.
    Print("MY DEBUG CGUIPannel::OnClickToggleSellSignal: Need update - Bridge sync not wired");
   }
  void CGUIPannel::OnClickToggleSoundAlert(const int row)
   {
    if(m_indicator_template_manager == NULL) return;
    int real_index = (int)StringToInteger(m_table_indicator_template.GetValue(7, row));
    CIndicatorSetting *entry = m_indicator_template_manager.At(real_index);
    if(entry == NULL) return;
    entry.SoundAlert((int)m_table_indicator_template.SelectedImageIndex(5, row) == 0);
    Print("MY DEBUG CGUIPannel::OnClickToggleSoundAlert: Need update");
   }
  void CGUIPannel::OnClickToggleMessageAlert(const int row)
   {
    if(m_indicator_template_manager == NULL) return;
    int real_index = (int)StringToInteger(m_table_indicator_template.GetValue(7, row));
    CIndicatorSetting *entry = m_indicator_template_manager.At(real_index);
    if(entry == NULL) return;
    entry.MessageAlert((int)m_table_indicator_template.SelectedImageIndex(6, row) == 0);
    Print("MY DEBUG CGUIPannel::OnClickToggleMessageAlert: Need update");
   }
#endif //CGUIPANNEL_SettingWindows_Indicator_MQH,