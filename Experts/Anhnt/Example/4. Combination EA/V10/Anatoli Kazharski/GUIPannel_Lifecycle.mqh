//+------------------------------------------------------------------+
//|                                          GUIPannel_Lifecycle.mqh |
//|Implementation of Init, Deinit and other lifecycle events         |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_LIFECYCLE_MQH
#define CGUIPANNEL_LIFECYCLE_MQH
#include "GUIPannel.mqh"
//Private Method
 //Get window index
 int CGUIPannel::WindowIdx(CWindow &wnd)
  {
   for(int i = 0; i < WindowsTotal(); i++)
    {
     if(m_windows[i] == GetPointer(wnd))
      return i;
    }
     return 0;
  } 
 //For GUIPannel    
 bool CGUIPannel::CreateGUIPannel(void) 
  {     
    // Create Main Frame window implementation in GUIPannel_MainWindows.mqh
      if (!CreateMainWindow("EXPERT PANEL Ver10 Synchronize Indicator"))
       {
         Print(__FUNCTION__, " > Failed to create panel!");
         return (false);
       }    
     //Create Status Bar at m_window_main
      if (!CreateStatusBar(1, 23))
       {
        Print(__FUNCTION__, " > Failed to create Status Bar!");
        return (false);
       }
     //Create MenuBar right below the caption bar (22px) - always-visible slim strip
      if(!CreateMenuBar(1, 22))
       {
        Print(__FUNCTION__, " > Failed to create MenuBar!");
        return (false);
       }
     // Create m_tabs_main in right panel m_window_main 
      if (!CreateTab_Main(M_TABS_MAIN_X, M_TABS_MAIN_Y))
       {
        Print(__FUNCTION__, " > Failed to create Tabs1!");
        return (false);
       }       
      //Create m_table_indicator_SymbolTFValue control at TAB_TAB_MAIN_TRADE m_tabs_main
       if(!CreateTable_IndicatorSymbolTFMonitor(0, 0)) return false;
    // Create Setting Windows implementation in GUIPannel_SettingWindows.mqh
      if(!CreateWindowSetting("Setting"))
       {
        Print(__FUNCTION__, " > Failed to create Setting Windows!");
        return (false);
       }
      //Hide Setting Windows       
       HideSettingWindow();
      //For Tab Group on the right panel of setting window m_tabs_main_setting_config 
       if (!CreateTabSettingConfig(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT*2 + 3))
        {
         Print(__FUNCTION__, " > Failed to create Settings config tabs!");
         return (false);
        }
      // For TreeView on the left panel of setting window m_treeview_indicator
       PopulateTreeView_IndicatorTemplateSetting();
       if(!CreateTreeView_IndicatorTemplateSetting(TABS_CONFIG_X_GAP, PARAM_FORM_Y)) return false;
      //For Add Indicator form
       if(!CreateAddIndicatorForm(PARAM_FORM_X, PARAM_FORM_Y)) return false;          
       if(!CreateTable_IndicatorTemplateSetting(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;       
      //For Symbol TF setting on Tab Config      
       PopulateTreeView_SymbolTFSetting();
       if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+2)) return false;  //WINDOW_CAPTION_HEIGHT = 22        
        SyncTreeView_SymbolTFSetting();
       //Table m_table_SymbolTFSeting on the right of the Symbol TF sub-tab - offset
       //past the TreeView's own width, same convention as INDICATOR_TABLE_X does for the
       //Indicator sub-tab (tree width + 10px padding), not the tree's own x_gap.
        if(!CreateTable_SymbolTFSetting(M_TREEVIEW_SYMBOLTF_WIDTH + 10, WINDOW_CAPTION_HEIGHT)) return false;
        PopulateTable_SymbolTFSetting();
        SyncTable_SymbolTFSetting();
       //For Candle Pattern Setting - m_BarPatterns_Control (borrowed via SetPatternsControl(),
       //already populated by CTimeSeriesEngine's RegisterAllKnownPatterns()) IS the Single
       //Source of Truth now - no separate build-into-arrays step needed (Anhnt, 2026-08-29).
        LoadCandlePatternSetting_FromJSON();
        if(!CreateTable_CandlePatternSetting(0, 0)) return false;
        InitializeTable_CandlePatternSetting();
       // For Marker Setting
       LoadMarkerSettingsFromJSON();
       if(!CreateTabSettingConfig_Marker(0, WINDOW_CAPTION_HEIGHT)) return false;
       // For Sound Setting
       if(!CreateTabSettingConfig_Sound(0, WINDOW_CAPTION_HEIGHT)) return false;       
       //Create m_window_candle_infomation Information window at to display signal on chart
        if (!CreateWindowCandleInfo())
         {
          Print(__FUNCTION__, " > Failed to create candle info popup!");
          return (false);
         }
        m_window_candle_infomation.Hide(); 
    //Finalize GUI Creation
     CWndEvents::CompletedGUI();
    // --- Hide all slots ONLY AFTER CompletedGUI() - FormAvailableElementsArray() (called
    // --- inside CompletedGUI) registers only VISIBLE elements into m_available_elements[],
    // --- which CComboBox's click-open mechanism depends on. Hiding before CompletedGUI
    // --- would exclude them permanently even after Show() - confirmed by reading
    // --- FormAvailableElementsArray()'s IsVisible() filter.
     HideAddIndicatorForm();   
    
    
    
    //   //For Trade Tab at m_tabs_main
    //   //For Positions Tab at m_tabs_main symbol combo, then the Distance/Lot mode+value
    //   //--- controls in one horizontal row, then the order-setup table, m_table_positions
    //   //--- still shifted down to POSITIONS_TABLE_Y below all of it.
    //    if(!CreatePreTradePlanSymbolCombo(0, POSITIONS_PLAN_Y)) return false;
    //    if(!CreatePreTradePlanControls(0, POSITIONS_PLAN_CONTROLS_Y)) return false;
    //    if(!CreateTablePreTradePlan(0, POSITIONS_PLAN_TABLE_Y)) return false;
    //    if(!CreateTablePositions(0, POSITIONS_TABLE_Y)) return false;
    //   // --- Trading bubble: just wire the mouse pointer now (cheap, no canvas yet) -
    //   // --- it lazily creates its own canvas via EnsureCreated(), called from its own
    //   // --- OnPoll()/OnChartEvent(), only once HasAnyLevel() is true (avoid creating a
    //   // --- full-screen canvas + hiding native SL/TP lines when there is nothing to show).
    //    m_trading_bubble.MousePointer(m_mouse);
    //    m_trading_bubble.SetChartObjCollection(GetPointer(m_chart_obj_collection));
        return true;
  }
//Public Method
 //| Constructor/Destructor                                          | 
 CGUIPannel::CGUIPannel(void)
  {
   //--- Setting parameters for the time counters
    m_gui_timecounter.SetParameters(16, 500);
   //   m_int_table_indicator_SymbolTFMonitor_table_row_count  = 0;
    m_pending_remove_row     = -1;
    m_pending_remove_sym_symboltf = "";
    m_pending_remove_tf_symboltf  = "";
    m_treeview_symboltf_need_sync = false;
    m_treeview_indicator_need_sync = false;
    m_table_indicator_need_sync = false;
    m_candle_info_shown_bar  = 0;
    m_active_window_index_before_candle_info = WindowIdx(m_window_main);
    m_pattern_bitmap_shown   = NULL;
    m_pattern_bitmap_scale   = -1;
    m_gui_created     = false;
  }
 CGUIPannel::~CGUIPannel(void)
  {
  }
 // CGUIPannel Lifecycle  
 //+------------------------------------------------------------------+
 //| Init                                                             |
 //+------------------------------------------------------------------+ 
 bool CGUIPannel::OnInitEvent(const int uninit_reason)
  {
   if(!m_gui_created)
    {
      // Set folder paths for file
         string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
      // --- CSignalLogger guard: SetFolder() was never being called anywhere (static, defaulted
      // --- to "" - Signal_Log_<SYMBOL>.csv/watermarks were reading/writing MQL5\Files\ root
      // --- instead of the EA's own subfolder), and LoadSignalLogWatermarks() was only lazily
      // --- triggered from inside CheckIndicatorAlerts() (tick-driven) instead of a proper OnInit
      // --- call. Same "load once, guarded" convention as every Manager's own OnInitEvent
      // --- (Anhnt, 2026-08-29).
         CSignalLogger::SetFolder(ea_folder);
         if(!m_signal_log_watermarks_loaded)
          {
           m_signal_logger.LoadSignalLogWatermarks();
           m_signal_log_watermarks_loaded = true;
          }
      //Create GUI Pannel
         if(!CreateGUIPannel()) return false;
         m_gui_created = true;
         UpdateGUI(true);      
    }
   else if(uninit_reason == REASON_CHARTCHANGE)
    {
      UpdateGUI(false);      
    }
   return true;
  }; 
 //+------------------------------------------------------------------+
 //| Deinit                                                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnDeinitEvent(const int reason)
  {    
       ::ObjectDelete(m_chart_id, PATTERN_HOVER_LABEL_NAME);   // Alt+hover pattern label, harmless no-op if never created
      if(reason != REASON_CHARTCHANGE)
       {
        m_trading_bubble.OnDeinitEvent();
        CWndEvents::Destroy();
         ::ChartRedraw(m_chart_id);
       }
  }
 //+------------------------------------------------------------------+
 //| Timer                                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTimerEvent(void)
  {
     //--- Exit if this is the tester
      if (::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_FRAME_MODE))
          return;
      //--- Deferred indicator delete (queued by the col-0 click in OnEvent) - safe here,
      //--- the table finished its own click processing on the previous chart event
      if(m_pending_remove_row >= 0)
       {
         int remove_row = m_pending_remove_row;
         m_pending_remove_row = -1;
         if(m_indicator_template_manager != NULL && remove_row < (int)m_table_indicator_template.RowsTotal())
           OnClickRemoveIndicator(remove_row);
       }
      //--- Deferred delete - Data only (no Layer 1 series stopped yet - it keeps running this
      //--- session, the pair just won't be recreated on the next EA attach/restart once the
      //--- user actually saves). Table-side removal happens in the SYMBOLTF_MANAGER_EVENT_DELETE
      //--- listener below, reacting to the Manager's own event - same split ADDED already uses.
        if(m_pending_remove_sym_symboltf != "")
        {
          string remove_sym = m_pending_remove_sym_symboltf;
          string remove_tf  = m_pending_remove_tf_symboltf;
          m_pending_remove_sym_symboltf = "";
          m_pending_remove_tf_symboltf  = "";
          if(m_SymbolTFManager != NULL)
             m_SymbolTFManager.Delete_SymbolTFSetting(remove_sym, TimestampByDescription(remove_tf));
        }
      //--- Deferred rebuild+sync for m_treeview_SymbolTF/m_table_SymbolTFSeting - the ONE place
      //--- that actually calls Populate/Sync. Every reactive call site (SYMBOLTF_MANAGER_EVENT_ADDED
      //--- included) just sets the flag now (2026-08-28) - PureData (m_SymbolTFManager) is free to
      //--- change as often as it likes; N flag-sets within one timer interval still cost exactly
      //--- 1 real rebuild+redraw here, instead of each event handler repainting immediately inline.
      //--- Populate MUST run before Sync - it creates the row/node structure Sync then paints icons
      //--- onto; both no-op cheaply if nothing actually changed since the last pass.
      //--- Gated on the active sub-tab (Anhnt, 2026-08-26): repainting a sub-tab the user isn't
      //--- even looking at is pure waste - the flag is left set (not consumed) until the user
      //--- actually switches to it, so nothing is ever lost, just deferred.
        if(m_treeview_symboltf_need_sync && m_active_window_index == WindowIdx(m_window_setting) &&
           m_tabs_main_setting_config.SelectedTab() == TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF)
        {
          m_treeview_symboltf_need_sync = false;
          PopulateTable_SymbolTFSetting();
          PopulateTreeView_SymbolTFSetting();
          SyncTreeView_SymbolTFSetting();
          SyncTable_SymbolTFSetting();   // same flag - Table needs the same self-healing resync
        }
      //--- Deferred TreeView sync for m_treeview_indicator - same pattern, see UpdateGUI().
        if(m_treeview_indicator_need_sync && m_active_window_index == WindowIdx(m_window_setting) &&
           m_tabs_main_setting_config.SelectedTab() == TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR)
        {
          m_treeview_indicator_need_sync = false;
          SyncTreeView_IndicatorTemplateSetting();
        }
      //--- Deferred Table rebuild for m_table_indicator_template - same pattern, see UpdateGUI().
      //--- UpdateGUI() itself runs from 2+ places on the very same real symbol/TF change
      //--- (OnInitEvent's REASON_CHARTCHANGE branch AND CHART_OBJ_EVENT_CHART_..._CHANGE), so a
      //--- direct InitializeTable_IndicatorTemplateSetting() call there fired its full
      //--- DeleteAllRows/AddRow+Update(true) rebuild twice back-to-back per TF switch - the
      //--- SettingWindows flicker (Anhnt, 2026-08-26).
        if(m_table_indicator_need_sync && m_active_window_index == WindowIdx(m_window_setting) &&
           m_tabs_main_setting_config.SelectedTab() == TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR)
        {
          m_table_indicator_need_sync = false;
          InitializeTable_IndicatorTemplateSetting();
        }
      //For m_table_indicator_SymbolTFMonitor
       SetValuesToTable_IndicatorSymbolTFMonitor();
     //--- Handling the elements
      //ulong t0 = ::GetMicrosecondCount();
      CWndEvents::OnTimerEvent();
      //ulong t1 = ::GetMicrosecondCount();
     // --- CTradingLevelBubble self-manages lazy-init via EnsureCreated(), called from the
     // --- top of its own OnPoll() (2026-07-14) - GUIPannel no longer needs to track whether
     // --- it's created or special-case the retry, just poll it unconditionally every tick.
        // m_trading_bubble.OnPoll();
        // SetValuesToTableIndicatorSymbolTFValue();
      // --- SyncIndicatorTemplateSettingToBridge() removed from here (Anhnt, 2026-08-16): was
      // --- polling unconditionally every timer tick, rebuilding the same unchanged arrays for
      // --- nothing. OnClickToggleBuySignal/OnClickToggleSellSignal (GUIPannel_TabSettingIndicator.mqh)
      // --- call it exactly when the Buy/Sell checkboxes actually change, and OnInitEvent now
      // --- calls it once at startup too (see there) - removing this polling call turned out to
      // --- have ALSO removed the only startup seed, which was a real bug, now fixed separately.
          //m_bridge_writer.BuildAndWriteSignalBridge();
     //--- Layer-3 observer poll: diffs all open charts and broadcasts CHART_OBJ_EVENT_*
     //--- custom events (handled in OnEvent -> RefreshIndicatorTableShowStates)
        // m_chart_obj_collection.Refresh();
        // ulong t2 = ::GetMicrosecondCount();
     // if(t2 - t0 > 1000)
     //  Print("PERF CGUIPannel::OnTimerEvent CWndEvents::OnTimerEvent= ", t1 - t0, " us CTradingLevelBubble::OnPoll= ", t2 - t1, " us");
  }  
 void CGUIPannel::OnTickEvent(void)
  {      
    bool redraw_needed = false;
    // --- Status Bar (Deposit Load/Profit/Server Time)
      if(UpdateStatusBar())
          redraw_needed = true;
    //For sound and message alerts - run every tick to catch all bar 0 changes.
        PlaySoundCloseBar();
        CheckIndicatorAlerts();
        CheckCandlePatternAlerts();    
      //   string pos_symbols_name[];
      //   int pos_symbols_total = GetPositionsSymbols(pos_symbols_name);
      //   int pos_rows_total = (int)m_table_positions.RowsTotal();
      //   if(pos_symbols_total > 0 && pos_symbols_total != pos_rows_total)
      //   {
      //     InitializePositionsTable();
      //     redraw_needed = true;
      //   }
      //   else if(pos_symbols_total > 0)
      //     redraw_needed = SetValuesToPositionsTable(pos_symbols_name);
      // // --- Status Bar (Deposit Load/Profit/Server Time), only update+redraw when a value    
      
      // // --- Pre-trade-plan table (Anhnt 2026-07-20): Entry/SL live off Bid/Ask, dirty-checked
      // // --- per-cell same as everywhere else in this file.
      //   if(SetValuesToPreTradePlanTable())
      //     redraw_needed = true;
    if(redraw_needed)
           ::ChartRedraw(); 
      
  }
 //+------------------------------------------------------------------+
 //| Trade operation event - refresh positions table on a new deal    |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTradeEvent(void)
  {
      // if(IsLastDealTicket())
      //   InitializePositionsTable();
  }  
 //+------------------------------------------------------------------+
 //| OnEvent handler                                                  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
  {
   // --- Self-correcting safety net (Anhnt, 2026-08-29, widened 2026-08-30): m_active_window_index
   // --- (Library core - WndEvents.mqh - controls which window's elements receive dispatched
   // --- clicks) is only ever meant to point away from m_window_main while m_window_candle_infomation
   // --- (Shift+hover popup) is genuinely showing. If some edge case left it stuck pointing
   // --- there after the popup already closed, every click on the Setting Window would silently
   // --- be ignored (BugNote: "Setting Window khong tac dong duoc", 2026-08-29).
   // --- Originally gated on m_candle_info_shown_bar==0, but that flag is ONLY ever reset from
   // --- inside the CHARTEVENT_MOUSE_MOVE branch below - if the mouse leaves the chart without
   // --- generating one more MOUSE_MOVE there (jumps straight onto an overlapping window, or off
   // --- the terminal entirely), shown_bar never returns to 0 and this safety net's own
   // --- precondition never fires either - the exact stuck case it exists to catch. Checking
   // --- MouseOverCandleInfoWindow() directly instead doesn't depend on that same broken path,
   // --- and runs on every event (not just mouse-move), so the very next interaction self-heals.
    if(m_active_window_index == WindowIdx(m_window_candle_infomation) && !MouseOverCandleInfoWindow())
     {
      HideCandleInfoPopup();
      m_candle_info_shown_bar = 0;
     }
   // --- Escape hatch (Anhnt, 2026-08-29): ESC always force-hides the Setting Window regardless
   // --- of m_active_window_index. CHARTEVENT_KEYDOWN always reaches OnEvent - it isn't gated by
   // --- "which window's elements are under the mouse" the way native click detection is - so
   // --- this works even when Setting Window's own Close (X) button is dead because some other
   // --- window still owns dispatch. Fixes "can't close Setting Window to see the Chart
   // --- underneath" without needing to find every possible m_active_window_index leak first.
    if(id == CHARTEVENT_KEYDOWN && lparam == 27) // VK_ESCAPE
     {
      HideSettingWindow();
      return;
     }
   // --- Setting Window's native Close (X) button (Anhnt, 2026-08-29): CWindow::CloseDialogBox()
   // --- (WndControls\Window.mqh, fired for any W_DIALOG-type window's close button, m_window_setting
   // --- being the only one here) never hides the window itself - it only broadcasts
   // --- ON_CLOSE_DIALOG_BOX (lparam = the window's own element Id) and leaves it to the consuming
   // --- EA to react. Nothing here ever listened for it, so the X button silently did nothing -
   // --- this is what actually closes it now.
    if(id == CHARTEVENT_CUSTOM + ON_CLOSE_DIALOG_BOX)
     {
      ::Print("MY DEBUG CGUIPannel::OnEvent ON_CLOSE_DIALOG_BOX: lparam=", lparam,
              " m_window_setting.Id()=", m_window_setting.Id(), " match=", (lparam == m_window_setting.Id()));
      if(lparam == m_window_setting.Id())
       {
        HideSettingWindow();
        return;
       }
     }
   //Handle MenuBar Settings item click
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_menu_bar.GetItemPointer(MENU_ITEM_SETTINGS).Id())
     {
      ShowSettingWindow();
      return;
     }
   //Handle Event on Setting Windows m_window_setting
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
       // Manager.AddIndicatorToIndicatorTemplateSetting() always appends at the end - fast path, no full rebuild.
       AddRow_IndicatorTemplateSetting();
       return;
      }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      {
       // TODO: still full-rebuild here - DeleteRow_IndicatorTemplateSetting(index) needs an
       // index, but callers of Delete_IndicatorTemplateSetting other than OnClickRemoveIndicator
       // (e.g. EA's CHART_OBJ_EVENT_CHART_WND_IND_CHANGE handler) don't have a table row/index
       // to give it - revisit once that's resolved.
       InitializeTable_IndicatorTemplateSetting();
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
        // --- col 0 on the current-chart's own row shows the "start" icon (IsCurrentChartSymbolTFRow) -
        // --- not deletable, ignore the click.
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
       // Just flag it (2026-08-28) - PureData (m_SymbolTFManager) already has the new row, no
       // rush to repaint inline. OnTimerEvent is the one place that calls Populate then Sync,
       // batching every reactive mark within one timer interval into exactly 1 real rebuild -
       // avoids a redundant extra repaint pass when this event fires mid-OnInit (REASON_CHARTCHANGE
       // adding a not-yet-tracked Symbol+TF), same tick UpdateGUI()'s own deferred pass already covers.
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
    //Handle Save Symbol/TF config to JSON - CSymbolTFManager owns FileOpen/write now
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_SymbolTF.Id())
      {
        if(m_SymbolTFManager != NULL) m_SymbolTFManager.SaveSymbolTFSettingToJSON();
        return;
      }
    //Handle Save marker style/color settings
    //Handle Other tab combo selection - live-updates the preview immediately (BEFORE Save),    
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM)
      {
       int codes[]; string shape_labels[];
       GetMarkerArrowCodeChoices(codes, shape_labels);
       int n_shapes = ArraySize(codes);
       color mcolors[]; string color_labels[];
       GetMarkerColorChoices(mcolors, color_labels);
       int n_colors = ArraySize(mcolors);
       if(lparam == m_combo_shape_single_indicator_buy.Id())
        {
         int sel = (int)m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_BUY, codes[sel]);
         return;
        }
       if(lparam == m_combo_shape_single_indicator_sell.Id())
        {
         int sel = (int)m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_SELL, codes[sel]);
         return;
        }
       if(lparam == m_combo_shape_multi_indicator_buy.Id())
        {
         int sel = (int)m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_BUY, codes[sel]);
         return;
        }
       if(lparam == m_combo_shape_multi_indicator_sell.Id())
        {
         int sel = (int)m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_SELL, codes[sel]);
         return;
        }
       if(lparam == m_combo_shape_pattern_buy.Id())
        {
         int sel = (int)m_combo_shape_pattern_buy.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_BUY, codes[sel]);
         return;
        }
       if(lparam == m_combo_shape_pattern_sell.Id())
        {
         int sel = (int)m_combo_shape_pattern_sell.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_SELL, codes[sel]);
         return;
        }
       if(lparam == m_combo_shape_combo_buy.Id())
        {
         int sel = (int)m_combo_shape_combo_buy.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_COMBO_BUY, codes[sel]);
         return;
        }
       if(lparam == m_combo_shape_combo_sell.Id())
        {
         int sel = (int)m_combo_shape_combo_sell.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_COMBO_SELL, codes[sel]);
         return;
        }
       if(lparam == m_combo_color_buy.Id())
        {
         int sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_colors) UpdateColorPreview(0, mcolors[sel]);
         return;
        }
       if(lparam == m_combo_color_sell.Id())
        {
         int sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_colors) UpdateColorPreview(1, mcolors[sel]);
         return;
        }
       if(lparam == m_combo_color_nonrelated.Id())
        {
         int sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
         if(sel >= 0 && sel < n_colors) UpdateColorPreview(2, mcolors[sel]);
         return;
        }
       if(lparam == m_combo_buy_sound.Id())
        {
         int sel = (int)m_combo_buy_sound.GetListViewPointer().SelectedItemIndex();
         string files[];
         ScanSoundFolder(files);
         if(sel >= 0 && sel < ArraySize(files))
            m_marker_buy_sound_file = files[sel];
         return;
        }
       if(lparam == m_combo_sell_sound.Id())
        {
         int sel = (int)m_combo_sell_sound.GetListViewPointer().SelectedItemIndex();
         string files[];
         ScanSoundFolder(files);
         if(sel >= 0 && sel < ArraySize(files))
            m_marker_sell_sound_file = files[sel];
         return;
        }
      }
    //Handle Save marker style/color settings - commits the currently-selected combo items into
    //m_marker_*_code/m_marker_*_color (previews above only update DISPLAY, not these fields),
    //then writes them out.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.Id())
      {
       int codes[]; string shape_labels[];
       GetMarkerArrowCodeChoices(codes, shape_labels);
       int n_shapes = ArraySize(codes);
       color mcolors[]; string color_labels[];
       GetMarkerColorChoices(mcolors, color_labels);
       int n_colors = ArraySize(mcolors);
       int sel;
       sel = (int)m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_buy_code  = codes[sel];
       sel = (int)m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_sell_code = codes[sel];
       sel = (int)m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_buy_code   = codes[sel];
       sel = (int)m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_sell_code  = codes[sel];
       sel = (int)m_combo_shape_pattern_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_pattern_buy_code  = codes[sel];
       sel = (int)m_combo_shape_pattern_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_pattern_sell_code = codes[sel];
       sel = (int)m_combo_shape_combo_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_combo_buy_code  = codes[sel];
       sel = (int)m_combo_shape_combo_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_combo_sell_code = codes[sel];
       sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_colors) m_marker_buy_color = mcolors[sel];
       sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_colors) m_marker_sell_color = mcolors[sel];
       sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_colors) m_marker_nonrelated_color = mcolors[sel];
       SaveMarkerSettingsToJSON();
       // EA has no Manager for Marker style (fixed GUI-only fields) - fire so it can
       // re-attach SignalMarkers.mq5 with the new shape/color inputs (Anhnt, 2026-08-28).
       ::EventChartCustom(::ChartID(), (ushort)GUIPANNEL_EVENT_MARKER_SETTING_CHANGED, 0, 0.0, "");
        return;
      }
    //Handle Save sound settings - m_marker_*_sound_file already committed live by the
    //ON_CLICK_COMBOBOX_ITEM handler above, just write them out.
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_sound_settings.Id())
       {
         SaveSoundSettingsToJSON();
         return;
       }       
    // Handle Save Indicator config to JSON - CIndicatorTemplateManager owns FileOpen/write now
       if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_indicator.Id())
        {
         if(m_indicator_template_manager != NULL) m_indicator_template_manager.SaveIndicatorTemplateToJSON();
         return;
        }
    //Handle on Candle Infor
     if(id == CHARTEVENT_MOUSE_MOVE)
      {
        bool popup_shown = (m_candle_info_shown_bar != 0);
        if(popup_shown && MouseOverCandleInfoWindow())
         {
            // --- Stay open, don't touch bar_time - let the table's native dispatch (now
            // --- routed to it via m_active_window_index) handle the scrollbar/clicks.
         }
        else if(popup_shown && !MouseOverCandleInfoWindow())
         {
            // --- Mouse left the popup rect -> hide it, reset to m_window_main dispatch.
            HideCandleInfoPopup();
            m_candle_info_shown_bar = 0;
         }
        else if(m_keys.KeyShiftState())
         {
          datetime t; double price; int sub_window;
          if(::ChartXYToTimePrice(m_chart_id, m_mouse.X(), m_mouse.Y(), sub_window, t, price))
            {
            string sym = ::Symbol();
            ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
            int shift = ::iBarShift(sym, tf, t, false);
            if(shift >= 0)
              {
              datetime bar_time = ::iTime(sym, tf, shift);
              if(bar_time != m_candle_info_shown_bar)
                {
                bool has_signal = RefreshCandleInfoWindow(bar_time);
                if(has_signal)
                  {
                    m_candle_info_shown_bar = bar_time;
                    ShowCandleInfoPopup(m_mouse.X(), m_mouse.Y());
                  }
                else if(popup_shown)
                  {
                    HideCandleInfoPopup();
                    m_candle_info_shown_bar = 0;
                  }
                }
              }
            }
          else if(popup_shown)
            {
            HideCandleInfoPopup();
            m_candle_info_shown_bar = 0;
            }
         }
        // --- Alt + hover pattern bitmap - independent of the Shift popup above (Anhnt,
        // --- 2026-08-14): while Alt is held, shows the CGCnvPatternBitmap for whatever
        // --- pattern is confirmed at the hovered bar; releasing Alt or moving off a bar
        // --- with no pattern hides it again (ShowPatternBitmapAtBar/HidePatternBitmapShown
        // --- both no-op cheaply when there's nothing to do).
        if(m_keys.KeyAltState())
         {
          datetime t; double price; int sub_window;
          if(::ChartXYToTimePrice(m_chart_id, m_mouse.X(), m_mouse.Y(), sub_window, t, price))
          {
            string sym = ::Symbol();
            ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
            int shift = ::iBarShift(sym, tf, t, false);
            if(shift >= 0)
            {
              datetime bar_time = ::iTime(sym, tf, shift);
              // --- MY DEBUG: dump OHLC + the exact 3 ratios CBarPatternControlHammer::FindPattern()
              // --- checks (body<=0.35, lower_shadow>=0.55, upper_shadow<=0.10, all as % of full
              // --- High-Low range) - verifies whether a hovered candle SHOULD actually qualify
              // --- as Hammer (Anhnt, 2026-08-29).
              {
               double o = ::iOpen(sym, tf, shift), h = ::iHigh(sym, tf, shift),
                      l = ::iLow(sym, tf, shift),  cl = ::iClose(sym, tf, shift);
               double full = h - l;
               if(full > 0)
                {
                 double body  = ::MathAbs(cl - o);
                 double lower = ::MathMin(o, cl) - l;
                 double upper = h - ::MathMax(o, cl);
                 ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE: bar_time=", ::TimeToString(bar_time, TIME_DATE|TIME_MINUTES),
                         " O=", o, " H=", h, " L=", l, " C=", cl,
                         " body%=", ::DoubleToString(body/full*100, 1),
                         " lower_shadow%=", ::DoubleToString(lower/full*100, 1),
                         " upper_shadow%=", ::DoubleToString(upper/full*100, 1),
                         " Hammer_needs(body<=35, lower>=55, upper<=10)");
                }
              }
              // --- MY DEBUG: dump every REAL detected pattern instance at this exact bar (same
              // --- source CheckCandlePatternAlerts()'s CloseBar path and the CSV log read) - lets
              // --- us cross-check the ratio math above against what the real Alert pipeline
              // --- actually sees (Anhnt, 2026-08-29). Each line is now tagged table_enabled=YES/NO
              // --- (same PatternSignalBuy/Sell + Symbol-TF gate ShowPatternBitmapAtBar uses) and a
              // --- final "=> Chart shows" line reproduces its exact best-of pick, so with only one
              // --- row checked on the Setting table this collapses to a clean 1:1 against the Chart
              // --- bitmap/tooltip - the point being to verify each pattern's name+math in isolation
              // --- before ever turning several on at once for live use.
              {
               CArrayObj *all_pat_dbg = m_BarTimeSeriesCollection.GetListAllPatterns();
               int found_dbg = 0;
               CSymbolTFSetting *symtf_dbg = (m_SymbolTFManager != NULL) ? m_SymbolTFManager.FindByIdentity(sym, tf) : NULL;
               bool symtf_buy_dbg  = (symtf_dbg != NULL) ? symtf_dbg.BuySignal()  : false;
               bool symtf_sell_dbg = (symtf_dbg != NULL) ? symtf_dbg.SellSignal() : false;
               CBarPattern *best_dbg = NULL;
               int best_candles_dbg = 0;
               if(all_pat_dbg != NULL)
                {
                 int total_dbg = all_pat_dbg.Total();
                 for(int pi = 0; pi < total_dbg; pi++)
                  {
                   CBarPattern *p_dbg = all_pat_dbg.At(pi);
                   if(p_dbg == NULL || p_dbg.Symbol() != sym || p_dbg.Timeframe() != tf || p_dbg.Time() != bar_time) continue;
                   found_dbg++;
                   ENUM_PATTERN_DIRECTION pdir_dbg = p_dbg.Direction();
                   bool is_buy_dbg  = (pdir_dbg == PATTERN_DIRECTION_BULLISH);
                   bool is_sell_dbg = (pdir_dbg == PATTERN_DIRECTION_BEARISH);
                   bool enabled_dbg = (is_buy_dbg  && PatternSignalBuy(p_dbg.TypePattern())  && symtf_buy_dbg) ||
                                      (is_sell_dbg && PatternSignalSell(p_dbg.TypePattern()) && symtf_sell_dbg);
                   ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE real pattern #", found_dbg, ": type=", EnumToString(p_dbg.TypePattern()),
                           " name=", p_dbg.GetProperty(PATTERN_PROP_NAME),
                           " direction=", EnumToString(pdir_dbg),
                           " table_enabled=", (enabled_dbg ? "YES" : "no"));
                   if(enabled_dbg)
                    {
                     int n_dbg = (int)p_dbg.Candles();
                     if(best_dbg == NULL || n_dbg > best_candles_dbg) { best_dbg = p_dbg; best_candles_dbg = n_dbg; }
                    }
                  }
                }
               if(found_dbg == 0)
                 ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE: no real detected pattern at this closed bar (may be live bar-0, or genuinely no match)");
               ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE => Chart shows: ",
                       (best_dbg != NULL) ? best_dbg.GetProperty(PATTERN_PROP_NAME) : "(none - no table-enabled pattern matches here)");
              }
              ShowPatternBitmapAtBar(bar_time);
            }
          }
          else
            HidePatternBitmapAtBar();
         }
        else
          HidePatternBitmapAtBar();
      }
    //Handle Save Pattern Config to JSON
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_pattern_config.Id())
       {
        SaveCandlePatternSettingToJSON();
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

    
      m_trading_bubble.OnChartEvent(id, lparam, dparam, sparam);
    // --- Re-enabled (Anhnt, 2026-08-30): these blocks were written but left commented out,
    // --- still calling the old name HideParamSlots() (renamed to HideAddIndicatorForm() since).
    // --- Without them, any tab switch/window expand force-shows m_param_labels/m_param_edits/
    // --- m_param_combo[] via the Library's own ShowTabElements()->Reset() cascade, regardless of
    // --- whether a tree indicator was ever clicked - this is exactly the stray empty combobox
    // --- BugNote: seen sitting in the Indicator tab no matter which indicator was selected.
    // --- A 4th block for the OUTER m_tabs_main was dropped (Anhnt, 2026-08-30) - that whole
    // --- Monitor/Positions tab feature is disabled (GUIPannel_TabMonitor.mqh/TabPositions.mqh
    // --- both commented out, m_tabs_main itself never declared), so it never compiled and would
    // --- never have fired anyway.
    // --- Same issue on the NESTED m_tabs_main_setting_config (Indicator/Symbol TF sub-tabs) -
    //     it's its own CTabs with its own ON_CLICK_TAB event, so switching between its 2 tabs
    //     runs its own ShowTabElements() -> Reset() cascade, which force-shows m_param_labels/
    //     m_param_edits/m_param_combo[] the same way the outer tab switch does.
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main_setting_config.Id())
      {
        HideAddIndicatorForm();
        return;
      }
    // --- Same issue on window expand: OnWindowExpand() calls ShowTabElements() before
    //     our OnEvent runs. Re-hide to keep param slots invisible until tree node clicked.
      if(id == CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND && lparam == m_window_main.Id())
      {
        HideAddIndicatorForm();
        return;
      }
    // --- On window collapse: library OnWindowCollapse() may skip elements with Id()==0
    //     (e.g. dynamic TreeItems). Explicitly hide both treeviews so their items
    //     cascade-hide, eliminating gray canvas artifacts on the chart.
      if(id == CHARTEVENT_CUSTOM + ON_WINDOW_COLLAPSE && lparam == m_window_main.Id())
      {
        m_treeview_indicator.Hide();
        m_treeview_SymbolTF.Hide();
        HideAddIndicatorForm();
        return;
      }
    

      //   SaveGUIConfigToJSON();
      //   // --- Save alone only persists m_marker_* to JSON - the already-running SignalMarkers
      //   // --- indicator (attached via iCustom) never re-reads input params on its own, so a
      //   // --- style/color change here had no visible effect until the user manually removed +
      //   // --- re-added it (BugNote_MarkerMissingDespitePattern.md, 2026-08-15). Recreate it now
      //   // --- with the just-saved m_marker_* values so Save actually takes effect immediately.
      //   ReattachSignalMarkersIndicator();
      //   return;
      // }   
    
  }
 //+------------------------------------------------------------------+
 //| Update GUI                                                       |
 //+------------------------------------------------------------------+ 
 void CGUIPannel::UpdateGUI(const bool redraw)
  {
      // // No unconditional full-canvas Update(true) here - repainting the whole treeview and
      // // the whole Settings table on every CHARTCHANGE was exactly the m_window_main blink.
      // // Each call below repaints only the cells/icons it actually changed (dirty-check),
      // // and PopulateTreeView_SymbolTFSetting (CHARTEVENT_CHART_CHANGE handler) already updates the tree
      // when the symbol/TF really changed.
      //   SetValuesToTableIndicatorSymbolTFValue();
       // Just flag it - UpdateGUI() itself is called from 2+ places on the very same real
       // symbol/TF change (OnInitEvent's REASON_CHARTCHANGE branch AND the CHART_OBJ_EVENT_CHART_
       // ..._CHANGE handler), so calling SyncTreeView_IndicatorTemplateSetting()/
       // InitializeTable_IndicatorTemplateSetting() directly here was the same double-redraw risk -
       // OnTimerEvent is the ONE place that actually calls either now (Anhnt, 2026-08-26).
         m_treeview_indicator_need_sync = true;
         m_table_indicator_need_sync = true;
         if(redraw) m_chart.Redraw();
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
