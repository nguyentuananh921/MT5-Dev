//+------------------------------------------------------------------+
//|                          GUIPannel_SettingWindows_TimeSeries.mqh |
//| Setting Time Series window: Indicator / Symbol TF / Candle       |
//| Pattern / Swing tabs, built on the Combination Lib V2 controls   |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGTIMESERIES_MQH
#define CGUIPANNEL_SETTINGTIMESERIES_MQH
 #include "GUIPannel.mqh"
 bool CGUIPannel::CreateWindow_SettingTimeSeries(const string caption_text,const int x_gap, const int y_gap)
  {
   m_window_setting_timeseries.FontSize(DEF_FONT_SIZE);
   m_window_setting_timeseries.IsMovable(true);
   m_window_setting_timeseries.ResizeMode(true);
   m_window_setting_timeseries.CloseButtonIsUsed(true);
   m_window_setting_timeseries.CollapseButtonIsUsed(true);
   m_window_setting_timeseries.MinimumXSize(M_WINDOW_MIN_WIDTH);
   m_window_setting_timeseries.MinimumYSize(M_WINDOW_MIN_HEIGHT);
   m_window_setting_timeseries.WindowType(W_DIALOG);
   if(!m_window_setting_timeseries.CreateWindow(m_chart_id, m_subwin, caption_text, x_gap, y_gap, M_WINDOW_SETTING_WIDTH, M_WINDOW_SETTING_HEIGHT))
      return false;
   m_window_setting_timeseries.IconFile(IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG);
   return true;
  }
  void CGUIPannel::OpenWindow_SettingTimeSeries(void)
  {
   m_window_setting_timeseries.OpenWindow();   
   m_frame_indicator_parameter.Hide();
   m_btn_save_indicator.Hide();
   ::ChartRedraw(m_chart_id);
  }
 bool CGUIPannel::CreateTab_SettingTimeSeries(const int x_gap, const int y_gap)
  {
   string tabs_names[TAB_TAB_SETTING_TIMESERIES_TOTAL] = {"Indicator", "Symbol TF", "Candle Pattern", "Smart Money Concepts"};
   m_tabs_setting_timeseries.PositionMode(TABS_TOP);
   m_tabs_setting_timeseries.AutoXResizeMode(true);
   m_tabs_setting_timeseries.AutoYResizeMode(true);
   m_tabs_setting_timeseries.AutoXResizeRightOffset(3);
   m_tabs_setting_timeseries.AutoYResizeBottomOffset(3);
   for(int i = 0; i < TAB_TAB_SETTING_TIMESERIES_TOTAL; i++)
      m_tabs_setting_timeseries.AddTab(tabs_names[i], 100);
   m_window_setting_timeseries.AddChild(&m_tabs_setting_timeseries);
   return m_tabs_setting_timeseries.CreateTabs(m_chart_id, m_subwin, "TabsSettingTS", x_gap, y_gap);
  }
 void CGUIPannel::OnEvent_Window_SettingTimeSeries(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Tab switch / window expand: Show() cascaded to the hidden form slots again
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_setting_timeseries.ObjectID()) ||
       (id == CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND && lparam == m_window_setting_timeseries.ObjectID()))
     {
      m_frame_indicator_parameter.Hide();
      if(m_current_param_type != IND_CUSTOM && m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
         ShowCFrame_IndicatorParameter(m_current_param_type);
      if(!m_indicator_save_pending) m_btn_save_indicator.Hide();
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- Indicator tree: a type leaf opens the Add form for that type
    if(id == CHARTEVENT_CUSTOM + ON_CHANGE_TREE_PATH && lparam == m_treeview_indicator.ObjectID())
     {
      long item_id = (long)dparam;
      //--- A group label click expands/collapses it too, not only its arrow
      CTreeItem *clicked = m_treeview_indicator.ItemPointer(item_id);
      if(clicked != NULL && clicked.ChildrenTotal() > 0)
       {
        m_treeview_indicator.ItemState(item_id, !clicked.ItemState(), true);
        return;
       }
      for(int i = 0; i < ::ArraySize(m_type_node_id); i++)
        {
         if(m_type_node_id[i] != item_id) continue;
         ShowCFrame_IndicatorParameter(m_type_node_value[i]);
         ::ChartRedraw(m_chart_id);
         break;
        }
      return;
     }
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_add_indicator.ObjectID())
     {
      OnClickAddIndicatorBtnOnForm();
      return;
     }
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON &&
       (lparam == m_btn_save_indicator.ObjectID() || lparam == m_btn_save_SymbolTF.ObjectID() ||
        lparam == m_btn_save_pattern_config.ObjectID() || lparam == m_btn_save_swing_config.ObjectID()))
     {
      SaveAllSettingsToJSON();
      m_indicator_save_pending = false;
      m_btn_save_indicator.Hide();
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- CIndicatorTemplateManager changed for real: refresh our own view
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED ||
       id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      if(!g_ea_init_done) return;
      //m_table_indicator_need_sync = true;
      InitializeTable_IndicatorTemplateSetting();
      ShowIndicatorSavePending();
      return;
     }
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_ADDED ||
       id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_DELETE)
     {
      //m_treeview_indicator_need_sync = true;
      SyncTreeView_IndicatorTemplateSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
     {
      SyncTable_IndicatorTemplateSetting();
      ShowIndicatorSavePending();
      return;
     }
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED)
     {
      ShowIndicatorSavePending();
      return;
     }
   //--- m_table_indicator_template: col 0 = delete button
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_table_indicator_template.ObjectID())
     {
      int col, row;
      if(!m_table_indicator_template.CellIndexes(sparam, col, row)) return;
      if(col == 0) OnClickRemoveIndicator(row);
      return;
     }
   //--- m_table_indicator_template: cols 2..6 = checkboxes, dparam = the new state
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_table_indicator_template.ObjectID())
     {
      int col, row;
      if(!m_table_indicator_template.CellIndexes(sparam, col, row)) return;
      bool on = (dparam != 0);
      if(col == 2)      OnClickToggleBuySignal(row, on);
      else if(col == 3) OnClickToggleSellSignal(row, on);
      else if(col == 4) OnClickToggleShowIndicatorOnChart(row, on);
      else if(col == 5) OnClickToggleSoundAlert(row, on);
      else if(col == 6) OnClickToggleMessageAlert(row, on);
      return;
     }
   //--- m_table_SymbolTFSeting: col 0 = delete button (not the chart's own pair)
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_table_SymbolTFSeting.ObjectID())
     {
      int col, row;
      if(!m_table_SymbolTFSeting.CellIndexes(sparam, col, row)) return;
      if(col != 0 || row < 0 || row >= (int)m_table_SymbolTFSeting.Model().RowsTotal()) return;
      string sym = m_table_SymbolTFSeting.Cell(0, row).ValueS();
      string tf  = m_table_SymbolTFSeting.Cell(1, row).ValueS();
      if(sym == ::Symbol() && tf == TimeframeDescription((ENUM_TIMEFRAMES)::Period())) return;
      if(m_SymbolTFManager != NULL)
         m_SymbolTFManager.Delete_SymbolTFSetting(sym, TimestampByDescription(tf));
      return;
     }
   //--- m_table_SymbolTFSeting: cols 2..5 = checkboxes, dparam = the new state
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_table_SymbolTFSeting.ObjectID())
     {
      int col, row;
      if(!m_table_SymbolTFSeting.CellIndexes(sparam, col, row)) return;
      if(col < 2 || col > 5 || row < 0 || row >= (int)m_table_SymbolTFSeting.Model().RowsTotal()) return;
      OnCheckTableSymbolTFSetting(m_table_SymbolTFSeting.Cell(0, row).ValueS(), m_table_SymbolTFSeting.Cell(1, row).ValueS(), col, dparam != 0);
      return;
     }
   //--- CSymbolsCollection: a symbol was added to / removed from Market Watch
    if(id == CHARTEVENT_CUSTOM + MARKET_WATCH_EVENT_SYMBOL_ADD ||
       id == CHARTEVENT_CUSTOM + MARKET_WATCH_EVENT_SYMBOL_DEL)
     {
      PopulateTreeView_SymbolTFSetting();
      SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- CSymbolTFManager changed for real: resync our own view right away
    if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED)
     {
      //m_treeview_symboltf_need_sync = true;
      PopulateTable_SymbolTFSetting();
      PopulateTreeView_SymbolTFSetting();
      SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
    if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      string removed_sym = ""; ENUM_TIMEFRAMES removed_tf = PERIOD_CURRENT;
      if(m_SymbolTFManager != NULL)
         m_SymbolTFManager.GetLastRemoved(removed_sym, removed_tf);
      DeleteRow_SymbolTFSetting(removed_sym, TimeframeDescription(removed_tf));
      //m_treeview_symboltf_need_sync = true;
      PopulateTreeView_SymbolTFSetting();
      SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
    if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_CHANGE ||
       id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_TF_CHANGE ||
       id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE)
     {
      if(lparam != ::ChartID()) return;
      if(m_SymbolTFManager != NULL && !m_SymbolTFManager.Exists(_Symbol, (ENUM_TIMEFRAMES)_Period))
         m_SymbolTFManager.Add_SymbolTFSetting(_Symbol, (ENUM_TIMEFRAMES)_Period);
      //m_treeview_symboltf_need_sync = true;
      SyncTreeView_SymbolTFSetting();
      SyncTable_SymbolTFSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- Symbol TF tree: a symbol leaf starts tracking it, a TF leaf asks to navigate there
    if(id == CHARTEVENT_CUSTOM + ON_CHANGE_TREE_PATH && lparam == m_treeview_SymbolTF.ObjectID())
     {
      OnClickTreeView_SymbolTFSetting((long)dparam);
      return;
     }
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_table_CandlePatternsSetting.ObjectID())
     {
      int col, row;
      if(!m_table_CandlePatternsSetting.CellIndexes(sparam, col, row)) return;
      if(col == 2 || col == 3 || col == 5 || col == 6)
         OnCheckTableCandlePatternSetting(row, col, dparam != 0);
      return;
     }
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_table_SmartMoneySetting.ObjectID())
     {
      int col, row;
      if(!m_table_SmartMoneySetting.CellIndexes(sparam, col, row)) return;
      if(col >= 1 && col <= 3)
         OnCheckTableSmartMoneySetting(row, col, dparam != 0);
      return;
     }
   //--- Swing Strength spin-edit (Enter or +/-) and Wick checkbox apply live
    if((id == CHARTEVENT_CUSTOM + ON_END_EDIT || id == CHARTEVENT_CUSTOM + ON_CLICK_INC || id == CHARTEVENT_CUSTOM + ON_CLICK_DEC)
       && lparam == m_edit_swing_strength.ObjectID())
     {
      OnChangeSwingParams();
      return;
     }
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_checkbox_swing_wick.ObjectID())
     {
      OnChangeSwingParams();
      return;
     }
  }
 void CGUIPannel::ShowIndicatorSavePending(void)
  {
   m_indicator_save_pending = true;
   if(m_window_setting_timeseries.IsVisible() &&
      m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
     {
      m_btn_save_indicator.Show();
      ::ChartRedraw(m_chart_id);
     }
  }
#endif //CGUIPANNEL_SETTINGTIMESERIES_MQH
