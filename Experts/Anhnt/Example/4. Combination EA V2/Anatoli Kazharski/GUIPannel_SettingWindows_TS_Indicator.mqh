//+------------------------------------------------------------------+
//|                        GUIPannel_SettingWindows_TS_Indicator.mqh |
//| Indicator tab: template tree (left) + template table (bottom)    |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TS_INDICATOR_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TS_INDICATOR_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 #define COLUMNS_INDICATOR_TEMPLATE_TOTAL 7
 bool CGUIPannel::CreateTreeView_IndicatorTemplateSetting(const int x_gap, const int y_gap)
  {
   m_treeview_indicator.LightsHover(true);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_INDICATOR, m_treeview_indicator);
   return m_treeview_indicator.CreateTreeView(m_chart_id, m_subwin, "TreeIndicatorTemplate", x_gap, y_gap,
                                              INDICATOR_TREE_WIDTH, m_tabs_setting_timeseries.Height() - y_gap - 3);
  }
 //--- Groups (ENUM_INDICATOR_GROUP) as roots, catalog types as leaves
 void CGUIPannel::PopulateTreeView_IndicatorTemplateSetting(void)
  {
   ENUM_INDICATOR_GROUP group_values[4] = {INDICATOR_GROUP_TREND, INDICATOR_GROUP_OSCILLATOR,
                                           INDICATOR_GROUP_VOLUMES, INDICATOR_GROUP_ARROWS};
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   ::ArrayResize(m_type_node_id, 0);
   ::ArrayResize(m_type_node_value, 0);
   for(int g = 0; g < 4; g++)
    {
     long group_id = m_treeview_indicator.AddTreeItem(WRONG_VALUE, GetIndicatorGroupName(group_values[g]));
     if(group_id == WRONG_VALUE) continue;
     for(int i = 0; i < ::ArraySize(catalog); i++)
      {
       if(catalog[i].group != group_values[g]) continue;
       long type_id = m_treeview_indicator.AddTreeItem(group_id, catalog[i].name, IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
       if(type_id == WRONG_VALUE) continue;
       int sz = ::ArraySize(m_type_node_id);
       ::ArrayResize(m_type_node_id, sz + 1);
       ::ArrayResize(m_type_node_value, sz + 1);
       m_type_node_id[sz]    = type_id;
       m_type_node_value[sz] = catalog[i].ind_type;
      }
    }
  }
 //--- Blue arrow on every type (and its group) that has at least one template row
 void CGUIPannel::SyncTreeView_IndicatorTemplateSetting(void)
  {
   if(m_indicator_template_manager == NULL) return;
   for(int i = 0; i < ::ArraySize(m_type_node_id); i++)
    {
     CTreeItem *type_item = m_treeview_indicator.ItemPointer(m_type_node_id[i]);
     CTreeItem *group_item = (type_item != NULL) ? type_item.ParentItem() : NULL;
     if(group_item != NULL) group_item.IsActive(false);
    }
   for(int i = 0; i < ::ArraySize(m_type_node_id); i++)
    {
     bool active = false;
     for(int r = 0; r < m_indicator_template_manager.Total() && !active; r++)
      {
       CIndicatorSetting *row = m_indicator_template_manager.At(r);
       active = (row != NULL && row.TypeEnum() == m_type_node_value[i]);
      }
     CTreeItem *type_item = m_treeview_indicator.ItemPointer(m_type_node_id[i]);
     if(type_item == NULL) continue;
     type_item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
     CTreeItem *group_item = type_item.ParentItem();
     if(active && group_item != NULL)
        group_item.IsActive(true);
    }
   m_treeview_indicator.UpdateTreeList(true);
  }
 //--- 7 columns: Indicator (delete icon), Group, Buy, Sell, Show on chart, Sound, Message
 bool CGUIPannel::CreateTable_IndicatorTemplateSetting(const int x, const int y)
  {
   m_table_indicator_template.TableSize(COLUMNS_INDICATOR_TEMPLATE_TOTAL, 0);
   m_table_indicator_template.View().ShowHeaders(true);
   m_table_indicator_template.View().SelectableRow(true);
   m_table_indicator_template.View().LightsHover(true);
   m_table_indicator_template.View().IsSortMode(false);   // row == CIndicatorTemplateManager index
   m_table_indicator_template.AutoXResizeMode(true);
   m_table_indicator_template.AutoXResizeRightOffset(3);
   m_table_indicator_template.AutoYResizeMode(true);
   m_table_indicator_template.AutoYResizeBottomOffset(3);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_INDICATOR, m_table_indicator_template);
   if(!m_table_indicator_template.CreateTable(m_chart_id, m_subwin, "TableIndicatorTemplate", x, y)) return false;
   int widths[COLUMNS_INDICATOR_TEMPLATE_TOTAL]          = {M_INDICATOR_PARATEXT_WIDTH, 70, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH};
   int image_x[COLUMNS_INDICATOR_TEMPLATE_TOTAL]         = {3, 3, 2, 2, 2, 2, 2};
   ENUM_ALIGN_MODE align[COLUMNS_INDICATOR_TEMPLATE_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
   CTableHeaderView *header = m_table_indicator_template.View().GetHeaderViewPointer();
   header.ColumnsWidth(widths);
   header.TextAlign(align);
   header.ImageXOffset(image_x);
   m_table_indicator_template.SetHeaderText(0, "Indicator");
   m_table_indicator_template.SetHeaderText(1, "Group");
   uint img_buy[]     = {IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG};
   uint img_sell[]    = {IMAGE_RESOURCE_BMP16_SIGNAL_SELL_PNG};
   uint img_visible[] = {IMAGE_RESOURCE_BMP16_VISIBLE_PNG};
   uint img_sound[]   = {IMAGE_RESOURCE_BMP16_BELL_PNG};
   uint img_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
   m_table_indicator_template.SetHeaderText(2, "");  m_table_indicator_template.SetHeaderImage(2, img_buy);
   m_table_indicator_template.SetHeaderText(3, "");  m_table_indicator_template.SetHeaderImage(3, img_sell);
   m_table_indicator_template.SetHeaderText(4, "");  m_table_indicator_template.SetHeaderImage(4, img_visible);
   m_table_indicator_template.SetHeaderText(5, "");  m_table_indicator_template.SetHeaderImage(5, img_sound);
   m_table_indicator_template.SetHeaderText(6, "");  m_table_indicator_template.SetHeaderImage(6, img_message);
   m_table_indicator_template.View().Rebuild(false);
   return true;
  }
 //--- Rows mirror CIndicatorTemplateManager 1:1, in its own order
 void CGUIPannel::InitializeTable_IndicatorTemplateSetting(void)
  {
   if(m_indicator_template_manager == NULL) return;
   int count = m_indicator_template_manager.Total();
   m_table_indicator_template.DeleteAllRows();
   for(int i = 0; i < count; i++)
      m_table_indicator_template.AddRow();
   for(int row = 0; row < count; row++)
      UpdateRow_IndicatorTemplateSetting(row);
   m_table_indicator_template.View().Rebuild(true);
  }
 void CGUIPannel::UpdateRow_IndicatorTemplateSetting(const int row)
  {
   if(m_indicator_template_manager == NULL) return;
   CIndicatorSetting *entry = m_indicator_template_manager.At(row);
   if(entry == NULL) return;
   uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   m_table_indicator_template.CellView(0, row).CellType(CELL_BUTTON);
   m_table_indicator_template.CellView(0, row).SetImages(delete_icon);
   m_table_indicator_template.SetValue(0, row, entry.DisplayLabel());
   m_table_indicator_template.SetValue(1, row, GetIndicatorGroupName(GetIndicatorGroupForType(entry.TypeEnum())));
   bool flags[5];
   flags[0] = entry.BuySignal();
   flags[1] = entry.SellSignal();
   flags[2] = entry.ShowOnChart();
   flags[3] = entry.SoundAlert();
   flags[4] = entry.MessageAlert();
   for(int c = 0; c < 5; c++)
    {
     m_table_indicator_template.CellView(c + 2, row).CellType(CELL_CHECKBOX);
     m_table_indicator_template.SetValue(c + 2, row, (long)(flags[c] ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
    }
  }
 //--- Show-on-chart column follows the Manager (it can change from the chart side too)
 void CGUIPannel::SyncTable_IndicatorTemplateSetting(void)
  {
   if(m_indicator_template_manager == NULL) return;
   int total = ::MathMin(m_indicator_template_manager.Total(), (int)m_table_indicator_template.Model().RowsTotal());
   for(int row = 0; row < total; row++)
    {
     CIndicatorSetting *entry = m_indicator_template_manager.At(row);
     if(entry != NULL)
        m_table_indicator_template.SetValue(4, row, (long)(entry.ShowOnChart() ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
    }
   m_table_indicator_template.Update(true);
  }
 //--- Checkbox handlers: CTable already flipped the cell, its value is the new state
 void CGUIPannel::OnClickToggleShowIndicatorOnChart(const int row)
  {
   if(m_indicator_template_manager == NULL) return;
   m_indicator_template_manager.UpdateRow_IndicatorTemplateSetting_ShowColumn(row, m_table_indicator_template.Cell(4, row).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED);
  }
 void CGUIPannel::OnClickRemoveIndicator(const int row)
  {
   if(m_indicator_template_manager == NULL) return;
   CIndicatorSetting *entry = m_indicator_template_manager.At(row);
   if(entry == NULL) return;
   MqlParam params[];
   entry.GetRawParams(params);
   m_indicator_template_manager.DeleteIndicatorFromIndicatorTemplateSetting(entry.TypeEnum(), params);
  }
 void CGUIPannel::OnClickToggleBuySignal(const int row)
  {
   CIndicatorSetting *entry = (m_indicator_template_manager != NULL) ? m_indicator_template_manager.At(row) : NULL;
   if(entry == NULL) return;
   entry.BuySignal(m_table_indicator_template.Cell(2, row).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED);
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED, (long)row, 0.0, "");
  }
 void CGUIPannel::OnClickToggleSellSignal(const int row)
  {
   CIndicatorSetting *entry = (m_indicator_template_manager != NULL) ? m_indicator_template_manager.At(row) : NULL;
   if(entry == NULL) return;
   entry.SellSignal(m_table_indicator_template.Cell(3, row).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED);
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED, (long)row, 0.0, "");
  }
 void CGUIPannel::OnClickToggleSoundAlert(const int row)
  {
   CIndicatorSetting *entry = (m_indicator_template_manager != NULL) ? m_indicator_template_manager.At(row) : NULL;
   if(entry == NULL) return;
   entry.SoundAlert(m_table_indicator_template.Cell(5, row).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED);
   ShowIndicatorSavePending();
  }
 void CGUIPannel::OnClickToggleMessageAlert(const int row)
  {
   CIndicatorSetting *entry = (m_indicator_template_manager != NULL) ? m_indicator_template_manager.At(row) : NULL;
   if(entry == NULL) return;
   entry.MessageAlert(m_table_indicator_template.Cell(6, row).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED);
   ShowIndicatorSavePending();
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_TS_INDICATOR_MQH_IMPLEMENTATION
