//+------------------------------------------------------------------+
//|                          GUIPannel_SettingWindows_TimeSeries.mqh |
//| Module for Setting Time Series                                   |
//+------------------------------------------------------------------+

#include "GUIPannel_Define.mqh"
#ifndef CGUIPANNEL_SETTINGTIMESERIES_MQH
#define CGUIPANNEL_SETTINGTIMESERIES_MQH
  #include "GUIPannel.mqh"
 //For Setting Windows m_window_setting_timeseries
 bool CGUIPannel::CreateWindow_SettingTimeSeries(const string caption_text,const int x_gap, const int y_gap)
  {
   //--- Add a window pointer to the window array
    CWndContainer::AddWindow(m_window_setting_timeseries);
   //Setting Properties
    m_window_setting_timeseries.XSize(M_WINDOW_SETTING_WIDTH);
    m_window_setting_timeseries.YSize(M_WINDOW_SETTING_HEIGHT);
    m_window_setting_timeseries.FontSize(9);
    m_window_setting_timeseries.IsMovable(true);
    m_window_setting_timeseries.ResizeMode(true);
    m_window_setting_timeseries.CloseButtonIsUsed(true);
    m_window_setting_timeseries.CollapseButtonIsUsed(true);
    m_window_setting_timeseries.TooltipsButtonIsUsed(true);
    m_window_setting_timeseries.FullscreenButtonIsUsed(true);
    m_window_setting_timeseries.MinimumXSize(M_WINDOW_MIN_WIDTH);
    m_window_setting_timeseries.MinimumYSize(M_WINDOW_MIN_HEIGHT);
    m_window_setting_timeseries.WindowType(W_DIALOG);    
   //Show Window at 30,30
    if(!m_window_setting_timeseries.CreateWindow(m_chart_id, m_subwin, caption_text, x_gap, y_gap))
       return (false);
   //Set Icon after Create
    m_window_setting_timeseries.IconFile(IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG );
    m_window_setting_timeseries.IconFileLocked(IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG );
    return (true);
  }
 void CGUIPannel::OpenWindow_SettingTimeSeries(void)
  {
    m_window_setting_timeseries.OpenWindow();
    //--- CWindow::Draw() paints whatever ChangeImage() last selected - IsLocked() alone never
    //--- flips it (only the caption background color reacts to that), so switch icons ourselves.
    m_window_setting_timeseries.ChangeImage(0, 0);   // IconFile - active
    HideAddIndicatorForm();
    HidePatternBitmapAtBar();
    HideWindow_CandleInfo();
    m_candle_info_shown_bar = 0;
    FormAvailableElementsArray();
    m_treeview_indicator.RedrawTreeList();   // force scrollbar recalc now that it's actually visible
  }
 void CGUIPannel::CloseWindow_SettingTimeSeries(void)
  {
    m_window_setting_timeseries.Hide();
    m_window_setting_timeseries.ChangeImage(0, 1);   // IconFileLocked - inactive
    m_btn_save_indicator.Hide();
    m_active_window_index = WindowIdx(m_window_main);
    FormAvailableElementsArray();
  }
//For Tab Group on the left Setting Windows m_tabs_main_setting_config 
 //+----------------------------------------------------------------------------------------------+
 //| Create a tab group m_tabs_main_setting_config for Settings at Setting m_window_setting       |
 //+----------------------------------------------------------------------------------------------+
 bool CGUIPannel::CreateTab_SettingTimeSeries(const int x_gap, const int y_gap)
  {
    string tabs_names[TAB_TAB_SETTING_TIMESERIES_TOTAL] = {"Indicator", "Symbol TF","Candle Pattern"};    
    m_tabs_setting_timeseries.MainPointer(m_window_setting_timeseries);
    //--- Properties
    m_tabs_setting_timeseries.IsCenterText(true);
    m_tabs_setting_timeseries.PositionMode(TABS_TOP);
    m_tabs_setting_timeseries.AutoXResizeMode(true);
    m_tabs_setting_timeseries.AutoYResizeMode(true);
    m_tabs_setting_timeseries.AutoXResizeRightOffset(3);
    m_tabs_setting_timeseries.AutoYResizeBottomOffset(3);
    //--- Add tabs with the specified properties
    for(int i = 0; i < TAB_TAB_SETTING_TIMESERIES_TOTAL; i++)
        m_tabs_setting_timeseries.AddTab(tabs_names[i], 100);
    //--- Create Tab before create other control element inside
     if(!m_tabs_setting_timeseries.CreateTabs(x_gap, y_gap))
        return (false);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_tabs_setting_timeseries);    
    return (true);
  }
 void CGUIPannel::OnEvent_Window_SettingTimeSeries(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Setting Time Series Window's native Close (X) button
     if(id == CHARTEVENT_CUSTOM + ON_CLOSE_DIALOG_BOX && lparam == m_window_setting_timeseries.Id())
      {
       CloseWindow_SettingTimeSeries();
       return;
      }
   //Handle tab switch on m_tabs_setting_timeseries - hide the Add Indicator popup form when
   //navigating away from the Indicator sub-tab
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_setting_timeseries.Id())
      {
        HideAddIndicatorForm();
        return;
      }
   // --- Same issue on window expand: OnWindowExpand() calls ShowTabElements() before
   //     our OnEvent runs. Re-hide to keep param slots invisible until tree node clicked.
     if(id == CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND && lparam == m_window_setting_timeseries.Id())
      {
        HideAddIndicatorForm();
        return;
      }
   // --- On window collapse: library OnWindowCollapse() may skip elements with Id()==0
     if(id == CHARTEVENT_CUSTOM + ON_WINDOW_COLLAPSE && lparam == m_window_setting_timeseries.Id())
      {
        m_treeview_indicator.Hide();
        m_treeview_SymbolTF.Hide();
        HideAddIndicatorForm();
        return;
      }
   //Handle Indicator TreeView Click
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_treeview_indicator.Id())
     {
      int li = (int)dparam;
      if(li < 0 || li >= m_treeview_indicator.ItemsTotal()) return;
      for(int i = 0; i < ArraySize(m_type_node_li); i++)
       {
        if(m_type_node_li[i] == li)
         {
          ShowAddIndicatorForm(m_type_node_value[i], li);
          break;
         }
      }
      return;
     }
   //Handle Add Indicator Button On Form Add Indicator move to EA
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_add_indicator.Id())
      {
        OnClickAddIndicatorBtnOnForm(); //Implementation in GUIPannel_AddIndicatorForm.mqh
        return;
      }
   //Handle CIndicatorTemplateManager's own events - Data changed for real, refresh our own GUI
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
      {
       // CIndicatorTemplateManager::OnChartEvent's own native ADD handler (CHART_OBJ_EVENT_
       // CHART_WND_IND_ADD) fires this unconditionally, unguarded by m_suppress_event (that flag
       // only covers OnInitEvent()'s OWN internal chart-scan loop, which finishes and resets it
       // to false BEFORE CTimeSeriesEngine::AddAllIndicatorsToNewSeries() ever runs) - so every
       // native indicator attach during EA startup's bulk-create phase reaches here too, before
       // m_table_indicator_template exists at all. g_ea_init_done (EA.mq5) is the one shared
       // "still wiring up" flag for the whole EA - reuse it instead of a separate local guard.
       if(!g_ea_init_done) return;
       // Manager.AddIndicatorToIndicatorTemplateSetting() always appends at the end - fast path, no full rebuild.
       AddRow_IndicatorTemplateSetting();
       // Data genuinely changed - only actually Show() the button while Setting Window is the
       // active window AND its immediate parent (the Indicator sub-tab) is the one currently
       // selected (Anhnt, 2026-09-01). m_tabs_setting_timeseries.IsVisible() alone is NOT
       // reliable here - it's never registered into m_window_setting_timeseries's own CElement cascade
       // array (MainPointer() is just a plain pointer, no side effect - confirmed by grep, no
       // such registration exists anywhere), so it stays stuck at its creation-time default
       // forever, regardless of the window actually opening/closing. m_active_window_index IS
       // real - the Library updates it via ON_OPEN_DIALOG_BOX/ON_CLOSE_DIALOG_BOX.
       if(m_active_window_index == WindowIdx(m_window_setting_timeseries)
          && m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
          m_btn_save_indicator.Show();
       return;
      }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      {
       // TODO: still full-rebuild here - DeleteRow_IndicatorTemplateSetting(index) needs an
       // index, but callers of Delete_IndicatorTemplateSetting other than OnClickRemoveIndicator
       // (e.g. EA's CHART_OBJ_EVENT_CHART_WND_IND_CHANGE handler) don't have a table row/index
       // to give it - revisit once that's resolved.
       InitializeTable_IndicatorTemplateSetting();
       if(m_active_window_index == WindowIdx(m_window_setting_timeseries)
          && m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
          m_btn_save_indicator.Show();
       return;
      }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_ADDED || id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_TYPE_DELETE)
      {
       SyncTreeView_IndicatorTemplateSetting();
       return;
      }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
      {
       // e.g. ShowOnChart flipped by EA reacting to a chart-native indicator add/remove -
       // re-read the row and repaint whatever's out of sync (dirty-checked internally).
       // Own dedicated event now (Anhnt, 2026-08-30) - this only ever paints the Show column
       // (col 4), so it never needed to wake up on a Buy/Sell toggle either.
       SyncTable_IndicatorTemplateSetting();
       if(m_active_window_index == WindowIdx(m_window_setting_timeseries)
          && m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
          m_btn_save_indicator.Show();
       return;
      }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED)
      {
       // Buy/Sell checkbox toggle on the Indicator Template table - data changed (Anhnt,
       // 2026-08-31). No table repaint needed here - the checkbox's own click handler
       // already redrew itself; this only exists to surface the pending-save state.
       if(m_active_window_index == WindowIdx(m_window_setting_timeseries)
          && m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
          m_btn_save_indicator.Show();
       return;
      }
   // Handle m_table_indicator event
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
          && lparam == m_table_indicator_template.Id())
      {
        string parts[];
        if(StringSplit(sparam, '_', parts) != 2) return;
       int col = (int)StringToInteger(parts[0]);
       int row = (int)StringToInteger(parts[1]);
          if(col == 0)        m_pending_remove_row = row;
          else if(col == 2)    OnClickToggleBuySignal(row);
          else if(col == 3)    OnClickToggleSellSignal(row);
          else if(col == 4)    OnClickToggleShowIndicatorOnChart(row);
          else if(col == 5)    OnClickToggleSoundAlert(row);
          else if(col == 6)    OnClickToggleMessageAlert(row);
          return;
      }
   //Handle Symbol TF Setting event
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
          && lparam == m_table_SymbolTFSeting.Id())
      {
        string parts[];
        if(StringSplit(sparam, '_', parts) != 2) return;
        int col = (int)StringToInteger(parts[0]);
        int row = (int)StringToInteger(parts[1]);
        if(row < 0 || row >= (int)m_table_SymbolTFSeting.RowsTotal()) return;
        string sym = m_table_SymbolTFSeting.GetValue(0, row); StringTrimLeft(sym);
        string tf  = m_table_SymbolTFSeting.GetValue(1, row); StringTrimLeft(tf);
        // --- Delete is DEFERRED to OnTimerEvent - same CTable crash reason as m_table_indicator's col 0.
        if(col == 0 && !IsCurrentChartSymbolTFRow(sym, tf))
         {
          m_pending_remove_sym_symboltf = sym;
          m_pending_remove_tf_symboltf  = tf;
         }
        else if(col == 2 || col == 3 || col == 4 || col == 5)
        OnCheckTableSymbolTFSetting(sym, tf, row, col);
        return;
      }
    //Handle CSymbolTFManager's own events - Data changed for real, refresh our own GUI
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED)
      {
       // Just flag it PureData (m_SymbolTFManager) already has the new row, no rush to repaint inline.
       // OnTimerEvent is the one place that calls Populate then Sync.
         m_treeview_symboltf_need_sync = true;
       return;
      }
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE)
      {
       // Row is already gone from Manager by the time this (async) event is processed - read
       // the snapshot GetLastRemoved() cached BEFORE the delete instead of trying to look it up.
       string removed_sym = ""; ENUM_TIMEFRAMES removed_tf = PERIOD_CURRENT;
       if(m_SymbolTFManager != NULL)
         m_SymbolTFManager.GetLastRemoved(removed_sym, removed_tf);
       DeleteRow_SymbolTFSetting(removed_sym, TimeframeDescription(removed_tf));
       // Mark it (2026-08-28) - the TreeView leaf for this (sym,tf) can't actually be removed
       // (no per-item removal API), but SyncTreeView_SymbolTFSetting()'s Exists() check needs to
       // re-run so it re-paints that leaf red (orphaned) - without this the leaf just kept
       // whatever icon it had before the delete, forever, until some UNRELATED trigger happened
       // to fire a Sync pass.
         m_treeview_symboltf_need_sync = true;
       return;
      }
    //Handle Symbol TF Settings
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_CHANGE ||
          id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_TF_CHANGE ||
          id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE)
      {
       // lparam carries the chart_id of whichever chart actually changed (see ChartObj.mqh's
       // own SendEvent - "pass the chart ID to lparam" for all 3 of these events). Each EA
       // instance's own m_ChartObjCollection tracks EVERY open chart, not just its own, and
       // always reports back to m_chart_id_main - so without this filter, changing the TF on
       // ANY open chart tab fires this in EVERY OTHER chart's EA instance too, each one
       // redundantly reprocessing its own (unchanged) _Symbol/_Period - the actual cause of
       // the "nháy loạn xạ" flicker across tabs (Anhnt, 2026-08-26).
        if(lparam != ::ChartID()) return;
       // Data only - self-register the chart's own (sym,tf) into m_SymbolTFManager (Single
       // Source of Truth) if not already tracked. Everything below is CGUIPannel's own GUI
       // concern - reflect whatever the Manager now holds, same split as the Indicator side.
        string sym_now = _Symbol;
        ENUM_TIMEFRAMES tf_now = (ENUM_TIMEFRAMES)_Period;
        Print("MY DEBUG CGUIPannel::OnEvent CHART_OBJ_EVENT_CHART_..._CHANGE: id=", id,
              " sparam(old_sym)=", sparam, " dparam(old_tf raw)=", dparam,
              " old_tf_desc=", TimeframeDescription((ENUM_TIMEFRAMES)(int)dparam),
              " sym_now=", sym_now, " tf_now=", TimeframeDescription(tf_now));
        if(m_SymbolTFManager != NULL && !m_SymbolTFManager.Exists(sym_now, tf_now))
          m_SymbolTFManager.Add_SymbolTFSetting(sym_now, tf_now);
        // Just flag it, whether this pair was already tracked or brand new - OnTimerEvent is
        // the one place that calls SyncTreeView_SymbolTFSetting(). Used to branch on
        // already-tracked-or-not to dodge a double Sync with the ADDED listener above; the flag
        // makes that unnecessary - any number of flag-sets before the next timer tick still cost
        // exactly 1 real redraw (root cause of the "nháy loạn" whole-window flicker, 2026-08-26).
         m_treeview_symboltf_need_sync = true;
        // Table refresh (which 2 rows need their icon flipped) used to happen right here,
        // targeted, using this native event's own sparam/dparam for the "old" identity - removed
        // (Anhnt, 2026-08-26): that native event silently doesn't fire at all for any chart
        // switch WE trigger ourselves (SetActiveChartSymbolTF's resulting reinit resets
        // CreateCollection()'s un-guarded diff baseline), so rows kept getting stuck. Same flag
        // above now also drives SyncTable_SymbolTFSetting() (full rescan, self-healing same as
        // the Tree), so nothing further needed here.
         UpdateGUI(false);   // dirty-check refresh only - no manual redraw, MT5 already redraws natively on chart change
         return;
      }
    // Handle Symbol TF TreeView Click ON_CLICK_BUTTON
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON  && lparam == m_treeview_SymbolTF.Id())
      {
       int li = (int)dparam;
       Print("MY DEBUG CGUIPannel::OnEvent ON_CLICK_BUTTON SymbolTF: li=", li,
             " ItemsTotal=", m_treeview_SymbolTF.ItemsTotal());
       if(li < 0 || li >= m_treeview_SymbolTF.ItemsTotal()) return;
       CTreeItem *item = m_treeview_SymbolTF.ItemPointer(li);
       if(item == NULL) return;
       int parent_pos = m_treeview_SymbolTF.ItemPrevNode(li);
       Print("MY DEBUG CGUIPannel::OnEvent ON_CLICK_BUTTON SymbolTF: item_label=", item.LabelText(),
             " item_type=", EnumToString(item.ItemType()), " parent_pos=", parent_pos);
       if(parent_pos == -1 && item.ItemType() == TI_SIMPLE)   // Symbol "note" - not tracked yet
        {
         // Data only - CGUIPannel's job stops at m_SymbolTFManager; nothing chart-related here.
         // Table/TreeView refresh for the new row happens in the SYMBOLTF_MANAGER_EVENT_ADDED
         // listener - CGUIPannel reacts to its own Manager, no direct call needed here.
         if(m_SymbolTFManager != NULL && !m_SymbolTFManager.Exists(item.LabelText(), (ENUM_TIMEFRAMES)_Period))
            m_SymbolTFManager.Add_SymbolTFSetting(item.LabelText(), (ENUM_TIMEFRAMES)_Period);
        }
       else if(parent_pos != -1)   // TF child - already tracked, pure navigation, no Data change
        {
         // Not a row mutation, so m_SymbolTFManager itself just broadcasts the intent
         // (NotifySettingChanged - no Add/Delete involved) - CGUIPannel's job still stops at
         // the Manager, EA is the one that decides whether/how to react on the chart.
         CTreeItem *parent = m_treeview_SymbolTF.ItemPointer(parent_pos);
         if(parent != NULL && m_SymbolTFManager != NULL)
          {
           ENUM_TIMEFRAMES target_tf = TimestampByDescription(item.LabelText());
           m_SymbolTFManager.NotifySettingChanged(parent.LabelText(), target_tf);
          }
         // Flag it - nothing else in this branch schedules a resync, so without this the
         // tree only happens to update if some unrelated event later sets the flag too.
         m_treeview_symboltf_need_sync = true;
        }
         return;
      }
    // Handle m_table_CandlePatternsSetting event (Buy/Sell/Sound/Message checkbox toggle)
      if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
        && lparam == m_table_CandlePatternsSetting.Id())
       {
        string parts[];
        ::Print("MY DEBUG CGUIPannel::OnEvent: CandlePatternsSetting id=", id, " sparam=", sparam);
        if(StringSplit(sparam, '_', parts) != 2) return;
        int col = (int)StringToInteger(parts[0]);
        int row = (int)StringToInteger(parts[1]);
        if(col == 2 || col == 3 || col == 5 || col == 6)
          OnCheckTableCandlePatternSetting(row, col);
        return;
       }
  }

#endif//CGUIPANNEL_SETTINGTIMESERIES_MQH
