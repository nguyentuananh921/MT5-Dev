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
    //  // Build pattern list trước tạo GUI     
    //   this.BuildCandlePatternListFromRegistry();      
    //  //DiscoverPatterns(); //Call before CreatePatternConfigTable
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
       if(!CreateTreeView_IndicatorTemplateSetting(TABS_CONFIG_X_GAP, m_window_setting.CaptionHeight() + 3)) return false;
      //For Add Indicator form
       if(!CreateAddIndicatorForm(PARAM_FORM_X, PARAM_FORM_Y)) return false;          
       if(!CreateTable_IndicatorTemplateSetting(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;       
      //For Symbol TF setting on Tab Config
       //Create m_treeview_SymbolTF in left panel m_window_main
      // --- CreateTreeView_SymbolTFSetting() MUST run first - it's the one that calls
      // --- MainPointer() (sets m_chart_id + wires m_scrollv), so InitializeTreeView...()'s
      // --- own AddTreeItem() calls have a live tree to actually draw into. Calling it before
      // --- crashed ("invalid pointer access", CScrollV::MainPointer never set) once enough
      // --- rows queued up to touch the scrollbar - see MQL5\Logs, 2026-08-26 01:02.
       PopulateTreeView_SymbolTFSetting();
       if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+2)) return false;  //WINDOW_CAPTION_HEIGHT = 22        
        SyncTreeView_SymbolTFSetting();
       //Table m_table_SymbolTFSeting on the right of the Symbol TF sub-tab - offset
       //past the TreeView's own width, same convention as INDICATOR_TABLE_X does for the
       //Indicator sub-tab (tree width + 10px padding), not the tree's own x_gap.
        if(!CreateTable_SymbolTFSetting(M_TREEVIEW_SYMBOLTF_WIDTH + 10, WINDOW_CAPTION_HEIGHT)) return false;
        PopulateTable_SymbolTFSetting();
        SyncTable_SymbolTFSetting();



       //Create m_table_indicator_SymbolTFValue control at TAB_TAB_MAIN_TRADE m_tabs_main
         //if(!CreateTableIndicatorSymbolTFValue(0, 0)) return false;
    //Finalize GUI Creation
     CWndEvents::CompletedGUI();     
    
    //  //Create m_tabs_main in right panel m_window_main 
    //   if (!CreateTab_Main(M_TABS_MAIN_X, M_TABS_MAIN_Y))
    //    {
    //     Print(__FUNCTION__, " > Failed to create Tabs1!");
    //     return (false);
    //    }
    //   //Create control at Each Tab
    
    //    //For TAB_TAB_MAIN_SETTINGS Tab at m_tabs_main
    //     //Right Pannel of TAB_TAB_MAIN_SETTINGS m_tabs_main_setting_config
    
    
    
    //   //Create m_window_candle_infomation Information window at to display signal on chart
    //    if (!CreateWindowCandleInfo())
    //     {
    //       Print(__FUNCTION__, " > Failed to create candle info popup!");
    //       return (false);
    //     }
    //    m_window_candle_infomation.Hide();  
    
    //    //DiscoverPatterns();
    //    RegisterPatterns();
    //    if(!CreateTableCandlePatternSetting(0, 0)) return false;
    //    InitializeTableCandlePatternSetting();
    //   //For Other sub-tab at m_tabs_main_setting_config (marker shape/color settings)
    //   if(!CreateTabSettingConfig_Marker(0, WINDOW_CAPTION_HEIGHT)) return false;
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
         
    //   // --- Hide all slots ONLY AFTER CompletedGUI() - FormAvailableElementsArray() (called
    //   // --- inside CompletedGUI) registers only VISIBLE elements into m_available_elements[],
    //   // --- which CComboBox's click-open mechanism depends on. Hiding before CompletedGUI
    //   // --- would exclude them permanently even after Show() - confirmed by reading
    //   // --- FormAvailableElementsArray()'s IsVisible() filter.
    
    //   // --- Same reasoning as HideParamSlots above: hide only AFTER CompletedGUI so
    //   // --- FormAvailableElementsArray() still registers its labels as available.
        return true;
  }
//Public Method
 //| Constructor/Destructor                                          | 
 CGUIPannel::CGUIPannel(void)
  {
    //--- Setting parameters for the time counters
     m_gui_timecounter.SetParameters(16, 500);
    //   m_int_table_indicator_SymbolTFValue_table_row_count  = 0;
    //   m_pending_remove_row     = -1;
       m_pending_remove_sym_symboltf = "";
       m_pending_remove_tf_symboltf  = "";
       m_treeview_symboltf_need_sync = false;
       m_treeview_indicator_need_sync = false;
    //   m_candle_info_shown_bar  = 0;
    //   m_pattern_bitmap_shown   = NULL;
    //   m_pattern_bitmap_scale   = -1;
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
      // // --- Layer 1's mechanical init (build collection, create current chart's Series, DOM/pattern
      // // --- setup) + Config_Setting.json load MUST run FIRST - CreateGUIPannel() below reads
      // // --- m_indicator_template_setting[]/m_symbol_tf_Setting[] to build its tables
      // // --- (SynIndicatorPlan.md, "Action" Step 2, 2026-08-18).
      //   if(m_time_series_engine != NULL)
      //   {
      //     m_time_series_engine.OnInitEvent(::Symbol(), (ENUM_TIMEFRAMES)::Period());
      //     // Order matters: SymbolTF first (creates the Series), Template second (needs those
      //     // Series to attach indicators to).
      //     LoadSymbolTFSettingFromJSON();
      //     LoadIndicatorTemplateSettingFromJSON();
      //   }
      // //Init m_bridge_writer
      //   if(m_time_series_engine != NULL &&
      //     m_IndicatorsCollection != NULL &&
      //     m_BarTimeSeriesCollection != NULL)
      //   {
      //     m_bridge_writer.Initialize(
      //                     m_time_series_engine.GetSignalsCollection(),
      //                     m_IndicatorsCollection,
      //                     m_BarTimeSeriesCollection);
      //   }
      // Set folder paths for file writers (Anhnt, 2026-08-08)
         string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
      //   m_signal_logger.SetFolder(ea_folder);
      //   m_bridge_writer.SetFolder(ea_folder);
      
      //Create GUI Pannel
         if(!CreateGUIPannel()) return false;
         m_gui_created = true;  
      // // Snapshot every open chart (windows + indicators) once - Refresh() in OnTimerEvent
      // // then diffs against this baseline and emits CHART_OBJ_EVENT_* on changes
      //   m_chart_obj_collection.CreateCollection();
      // // Startup reconcile: adopt any indicator the user attached while the EA was off.
      // // MUST run AFTER LoadIndicatorTemplateSettingFromJSON (line ~140) - ScanIndicatorOnChartOnInit's
      // // dedup check (IsIndicatorInTemplateSetting, against m_indicator_template_setting[]) needs it
      // // already populated from JSON; running before that would re-add every JSON template as a
      // // duplicate row. Runs BEFORE UpdateGUI on purpose (Anhnt, 2026-08-20): m_indicator_template_setting[]
      // // is fully merged (JSON + chart-discovered) by the time UpdateGUI paints the table, so it paints
      // // the correct final row set in one pass instead of painting once then Scan repainting again.
      //   ScanIndicatorOnChartOnInit();
         UpdateGUI(true);      
      //   SyncIndicatorTemplateSettingToBridge();     
      // // --- Single Layer 1 create pass (Anhnt, 2026-08-20): LoadIndicatorTemplateSettingFromJSON and
      // // --- ScanIndicatorOnChartOnInit() above are both PureData-only now - m_indicator_template_setting[]
      // // --- is fully merged (JSON-sourced + chart-discovered) by this point, so AddAllIndicatorsToNewSeries
      // // --- runs exactly once per series here, covering everything in one pass instead of 2 separate
      // // --- Layer 1 creation mechanisms running at different times.
      //   if(m_time_series_engine != NULL)
      //     for(int i = 0; i < ArraySize(m_symbol_tf_Setting); i++)
      //         m_time_series_engine.AddAllIndicatorsToNewSeries(m_symbol_tf_Setting[i].symbol,
      //                                                           TimestampByDescription(m_symbol_tf_Setting[i].tf),
      //                                                           m_indicator_template_setting);
      // // Debug helper (kept available, call disabled after the 4807 hunt closed): dump the
      // // instance->handle map right after startup
      // //m_time_series_engine.PrintIndicatorsInventory();
      // // --- One-time retroactive purge (BugNote 2026-07-16, "2531 leftover Arrow objects after
      // // --- Remove from chart"): cleans up legacy CreateSignalBuy/Sell/CreateThumbUp/Down
      // // --- objects from sessions before OnDeinitEvent's own per-removal purge existed. Gated
      // // --- so it only ever runs once per terminal, not once per chart/attach.
      //   if(!::GlobalVariableCheck("CombinationEA_SignalMarkersMigrated_v1"))
      //   {
      //     PurgeSignalArrowObjects(::Symbol(), EnumToString((ENUM_TIMEFRAMES)::Period()));
      //     ::GlobalVariableSet("CombinationEA_SignalMarkersMigrated_v1", 1);
      //   }
      //   EnsureMarkerIndicatorAttached();
    }
   else if(uninit_reason == REASON_CHARTCHANGE)
    {
      //  // No manual redraw here (2026-07-14) - MT5 already redraws the chart natively on
      //  // symbol/TF change, and CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE (OnEvent) does the
      //  // same content refresh moments later. Two ChartRedraw() calls back-to-back was
      //  // the m_window_main flicker on every TF switch.
         UpdateGUI(false);
      //  // --- No explicit bubble lazy-init call needed here (2026-07-14, BugNote "ChartChange
      //  // --- là mất") - CTradingLevelBubble now self-manages via EnsureCreated(), called from
      //  // --- its own OnPoll()/OnChartEvent() every time either is invoked, so the very next
      //  // --- OnEvent()/OnTimerEvent() call after this reinit already covers it.
      //  // --- Defensive re-check (cheap, idempotent) - the indicator itself already survives a
      //  // --- symbol/TF change on its own, this just covers the case where it got removed by hand.
      //   EnsureMarkerIndicatorAttached();
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
        
        //  PurgeSignalArrowObjects(::Symbol(), EnumToString((ENUM_TIMEFRAMES)::Period()));
        // // --- ChartIndicatorAdd() makes SignalMarkers.mq5 an independent chart program - it
        // // --- keeps running/drawing even after this EA is gone unless explicitly detached here.
        //  RemoveMarkerIndicator();
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
      //--- Deferred TreeView sync for m_treeview_SymbolTF - the ONE place that actually calls
      //--- SyncTreeView_SymbolTFSetting(). Every reactive call site just sets the flag; by the
      //--- time this timer tick runs, any same-tick SYMBOLTF_MANAGER_EVENT_ADDED (queued custom
      //--- event) has already been dispatched and PopulateTreeView_SymbolTFSetting() has
      //--- already created the new node, so Sync always sees final state - and N flag-sets
      //--- within one timer interval still cost exactly 1 real redraw.
        if(m_treeview_symboltf_need_sync)
        {
          m_treeview_symboltf_need_sync = false;
          SyncTreeView_SymbolTFSetting();
          SyncTable_SymbolTFSetting();   // same flag - Table needs the same self-healing resync
        }
      //--- Deferred TreeView sync for m_treeview_indicator - same pattern, see UpdateGUI().
        if(m_treeview_indicator_need_sync)
        {
          m_treeview_indicator_need_sync = false;
          SyncTreeView_IndicatorTemplateSetting();
        }
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
      //   if(UpdateStatusBar())
      //     redraw_needed = true;
      // // --- Pre-trade-plan table (Anhnt 2026-07-20): Entry/SL live off Bid/Ask, dirty-checked
      // // --- per-cell same as everywhere else in this file.
      //   if(SetValuesToPreTradePlanTable())
      //     redraw_needed = true;
      //   if(redraw_needed)
      //     ::ChartRedraw();
      // // --- Sound and message alerts - run every tick to catch all bar 0 changes. CloseBar Sound
      // // --- is just "NewBar.wav" via PlaySoundCloseBar now (Anhnt, 2026-08-14) - no more per-flip
      // // --- dedup gate shared with CheckIndicatorAlerts/CheckCandlePatternAlerts (those two only
      // // --- fire Message/CSV on CloseBar now, see FeatureNote/SoundBugNote.md).
      //   PlaySoundCloseBar();
      //   CheckIndicatorAlerts();
      //   CheckCandlePatternAlerts();
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
       // Manager.Add_IndicatorTemplateSetting() always appends at the end - fast path, no full rebuild.
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
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SETTING_CHANGED)
      {
       // e.g. ShowOnChart flipped by EA reacting to a chart-native indicator add/remove -
       // re-read the row and repaint whatever's out of sync (dirty-checked internally).
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
       // Data-only pass over the whole Manager - cheap (skips any row/node already present),
       // and matches PopulateTreeView_SymbolTFSetting()'s own same-shape call just below.
         PopulateTable_SymbolTFSetting();
         PopulateTreeView_SymbolTFSetting();
       // Just flag it - OnTimerEvent is the one place that calls SyncTreeView/SyncTable, after
       // this row/node now exists (see m_treeview_symboltf_need_sync).
         m_treeview_symboltf_need_sync = true;
       return;
      }
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE)
      {
       // Row is already gone from Manager by the time this (async) event is processed - read
       // the snapshot GetLastRemoved() cached BEFORE the delete instead of trying to look it up.
       string removed_sym; ENUM_TIMEFRAMES removed_tf;
       if(m_SymbolTFManager != NULL)
         m_SymbolTFManager.GetLastRemoved(removed_sym, removed_tf);
       DeleteRow_SymbolTFSetting(removed_sym, TimeframeDescription(removed_tf));
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
   //Handle Saving to JSON Need check

     
    // Handle Save Indicator config to JSON
      //  if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_indicator.Id())
      //   {
      //    SaveGUIConfigToJSON();
      //    return;
      //   }
    
      m_trading_bubble.OnChartEvent(id, lparam, dparam, sparam);
    // --- Shift + hover candle info popup (BugNote 7.2, redesigned 2026-07-16). m_mouse is already
    // --- refreshed for this event by CWndEvents::InitChartEventsParams() before OnEvent() is
    // --- called, so X()/Y() here are current.  
    // --- Use case 
    //  1. Shift + hover a candle with NO signal at all -> popup does not appear.
    //  2. Shift + hover a candle WITH a signal -> popup appears; cursor is already inside its
    //     rect the instant it appears (CANDLE_INFO_CURSOR_INSET), zero distance to cross.
    //  3. Mouse moves further into the popup/table to drag the scrollbar - MouseOverCandle-
    //     InfoWindow() being true is the ONLY thing keeping it open past this point; Shift no
    //     longer matters once inside.
    //  4. Mouse leaves the popup's rect -> it hides and native dispatch reverts to m_window_main.   
    // --- ShowCandleInfoPopup()/HideCandleInfoPopup() also swap m_active_window_index so
    // --- CWndEvents::CheckElementsEvents() natively dispatches to the table (scrollbar
    // --- included) while shown - see those methods for why m_window_main going quiet during
    // --- that window isn't a real trade-off (mouse can't be on both at once).
      // if(id == CHARTEVENT_MOUSE_MOVE)
      // {
      //   bool popup_shown = (m_candle_info_shown_bar != 0);
      //   if(popup_shown && MouseOverCandleInfoWindow())
      //   {
      //       // --- Stay open, don't touch bar_time - let the table's native dispatch (now
      //       // --- routed to it via m_active_window_index) handle the scrollbar/clicks.
      //   }
      //   else if(popup_shown && !MouseOverCandleInfoWindow())
      //   {
      //       // --- Mouse left the popup rect -> hide it, reset to m_window_main dispatch.
      //       HideCandleInfoPopup();
      //       m_candle_info_shown_bar = 0;
      //   }
      //   else if(m_keys.KeyShiftState())
      //   {
      //     datetime t; double price; int sub_window;
      //     if(::ChartXYToTimePrice(m_chart_id, m_mouse.X(), m_mouse.Y(), sub_window, t, price))
      //       {
      //       string sym = ::Symbol();
      //       ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
      //       int shift = ::iBarShift(sym, tf, t, false);
      //       if(shift >= 0)
      //         {
      //         datetime bar_time = ::iTime(sym, tf, shift);
      //         if(bar_time != m_candle_info_shown_bar)
      //           {
      //           bool has_signal = RefreshCandleInfoWindow(bar_time);
      //           if(has_signal)
      //             {
      //               m_candle_info_shown_bar = bar_time;
      //               ShowCandleInfoPopup(m_mouse.X(), m_mouse.Y());
      //             }
      //           else if(popup_shown)
      //             {
      //               HideCandleInfoPopup();
      //               m_candle_info_shown_bar = 0;
      //             }
      //           }
      //         }
      //       }
      //     else if(popup_shown)
      //       {
      //       HideCandleInfoPopup();
      //       m_candle_info_shown_bar = 0;
      //       }
      //   }
      //   // --- Alt + hover pattern bitmap - independent of the Shift popup above (Anhnt,
      //   // --- 2026-08-14): while Alt is held, shows the CGCnvPatternBitmap for whatever
      //   // --- pattern is confirmed at the hovered bar; releasing Alt or moving off a bar
      //   // --- with no pattern hides it again (ShowPatternBitmapAtBar/HidePatternBitmapShown
      //   // --- both no-op cheaply when there's nothing to do).
      //   if(m_keys.KeyAltState())
      //   {
      //     datetime t; double price; int sub_window;
      //     if(::ChartXYToTimePrice(m_chart_id, m_mouse.X(), m_mouse.Y(), sub_window, t, price))
      //     {
      //       string sym = ::Symbol();
      //       ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
      //       int shift = ::iBarShift(sym, tf, t, false);
      //       if(shift >= 0)
      //       {
      //         datetime bar_time = ::iTime(sym, tf, shift);
      //         ShowPatternBitmapAtBar(bar_time);
      //       }
      //     }
      //     else
      //       HidePatternBitmapAtBar();
      //   }
      //   else
      //     HidePatternBitmapAtBar();
      // }
    // --- Re-hide param slots after CTabs::ShowTabElements() shows them on tab switch.
    //     ShowTabElements() runs inside CTabs::OnEvent() (before our OnEvent is called),
    //     so by this point the slots are already visible — we undo that.
      // if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main.Id())
      // {
      //   HideParamSlots();
      //   return;
      // }
    // --- Same issue on the NESTED m_tabs_main_setting_config (Indicator/Symbol TF sub-tabs) -
    //     it's its own CTabs with its own ON_CLICK_TAB event, so switching between its 2 tabs
    //     runs its own ShowTabElements() -> Reset() cascade, which force-shows m_param_labels/
    //     m_param_edits/m_param_combo[] the same way the outer tab switch does.
      // if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main_setting_config.Id())
      // {
      //   HideParamSlots();
      //   return;
      // }
    // --- Same issue on window expand: OnWindowExpand() calls ShowTabElements() before
    //     our OnEvent runs. Re-hide to keep param slots invisible until tree node clicked.
      // if(id == CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND && lparam == m_window_main.Id())
      // {
      //   HideParamSlots();
      //   return;
      // }
    // --- On window collapse: library OnWindowCollapse() may skip elements with Id()==0
    //     (e.g. dynamic TreeItems). Explicitly hide both treeviews so their items
    //     cascade-hide, eliminating gray canvas artifacts on the chart.
      // if(id == CHARTEVENT_CUSTOM + ON_WINDOW_COLLAPSE && lparam == m_window_main.Id())
      // {
      //   m_treeview_indicator.Hide();
      //   m_treeview_SymbolTF.Hide();
      //   HideParamSlots();
      //   return;
      // }
    
    //Handle Save Symbol/TF config to JSON
      // if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_SymbolTF.Id())
      // {
      //   SaveGUIConfigToJSON();
      //   return;
      // }
    //Handle Save marker style/color settings
      // if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.Id())
      // {
      //   // --- Commit current combobox/color selections into m_marker_* BEFORE saving - the
      //   // --- ON_CLICK_COMBOBOX_ITEM handler above only ever updated the live preview
      //   // --- (UpdateShapePreview/UpdateColorPreview), never m_marker_* itself, so Save silently
      //   // --- re-serialized the same old defaults no matter what the user picked
      //   // --- (BugNote_MarkerMissingDespitePattern.md, 2026-08-15 - Anhnt picked Yellow, Save
      //   // --- kept writing Lime). Mirrors how the sound-file combos already commit directly.
      //   int codes[]; string shape_labels[];
      //   GetMarkerArrowCodeChoices(codes, shape_labels);
      //   int n_shapes = ArraySize(codes);
      //   color mcolors[]; string color_labels[];
      //   GetMarkerColorChoices(mcolors, color_labels);
      //   int n_colors = ArraySize(mcolors);
      //   int sel;
      //   sel = (int)m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_buy_code  = codes[sel];
      //   sel = (int)m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_sell_code = codes[sel];
      //   sel = (int)m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_buy_code   = codes[sel];
      //   sel = (int)m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_sell_code  = codes[sel];
      //   sel = (int)m_combo_shape_pattern_buy.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_pattern_buy_code  = codes[sel];
      //   sel = (int)m_combo_shape_pattern_sell.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_pattern_sell_code = codes[sel];
      //   sel = (int)m_combo_shape_combo_buy.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_combo_buy_code  = codes[sel];
      //   sel = (int)m_combo_shape_combo_sell.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_shapes) m_marker_combo_sell_code = codes[sel];
      //   sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_colors) m_marker_buy_color = mcolors[sel];
      //   sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_colors) m_marker_sell_color = mcolors[sel];
      //   sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
      //   if(sel >= 0 && sel < n_colors) m_marker_nonrelated_color = mcolors[sel];

      //   SaveGUIConfigToJSON();
      //   // --- Save alone only persists m_marker_* to JSON - the already-running SignalMarkers
      //   // --- indicator (attached via iCustom) never re-reads input params on its own, so a
      //   // --- style/color change here had no visible effect until the user manually removed +
      //   // --- re-added it (BugNote_MarkerMissingDespitePattern.md, 2026-08-15). Recreate it now
      //   // --- with the just-saved m_marker_* values so Save actually takes effect immediately.
      //   ReattachSignalMarkersIndicator();
      //   return;
      // }
    //  //Handle "Refresh" next to the sound folder path - re-scans and re-populates both combos
    //   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_refresh_sound_folder.Id())
    //    {
    //     OnClickChangeSoundFolder();
    //     return;
    //    }
    //Handle Save Pattern Config to JSON
      // if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_pattern_config.Id())
      // {
      //   SaveGUIConfigToJSON();
      //   return;
      // }
    //Handle Other tab combo selection - live-updates the preview immediately (BEFORE Save),
    //so the user sees what they're about to pick, not just its number/name. Reads directly off
    //the just-clicked combo's own SelectedItemIndex() - m_marker_* only changes on Save.
     // if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM)
      // {
      //   int codes[]; string shape_labels[];
      //   GetMarkerArrowCodeChoices(codes, shape_labels);
      //   int n_shapes = ArraySize(codes);
      //   color mcolors[]; string color_labels[];
      //   GetMarkerColorChoices(mcolors, color_labels);
      //   int n_colors = ArraySize(mcolors);
      //   if(lparam == m_combo_shape_single_indicator_buy.Id())
      //     {
      //     int sel = (int)m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_BUY, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_shape_single_indicator_sell.Id())
      //     {
      //     int sel = (int)m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_SELL, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_shape_multi_indicator_buy.Id())
      //     {
      //     int sel = (int)m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_BUY, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_shape_multi_indicator_sell.Id())
      //     {
      //     int sel = (int)m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_SELL, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_shape_pattern_buy.Id())
      //     {
      //     int sel = (int)m_combo_shape_pattern_buy.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_BUY, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_shape_pattern_sell.Id())
      //     {
      //     int sel = (int)m_combo_shape_pattern_sell.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_SELL, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_shape_combo_buy.Id())
      //     {
      //     int sel = (int)m_combo_shape_combo_buy.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_COMBO_BUY, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_shape_combo_sell.Id())
      //     {
      //     int sel = (int)m_combo_shape_combo_sell.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_COMBO_SELL, codes[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_color_buy.Id())
      //     {
      //     int sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_colors) UpdateColorPreview(0, mcolors[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_color_sell.Id())
      //     {
      //     int sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_colors) UpdateColorPreview(1, mcolors[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_color_nonrelated.Id())
      //     {
      //     int sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
      //     if(sel >= 0 && sel < n_colors) UpdateColorPreview(2, mcolors[sel]);
      //     return;
      //     }
      //   if(lparam == m_combo_buy_sound.Id())
      //     {
      //     int sel = (int)m_combo_buy_sound.GetListViewPointer().SelectedItemIndex();
      //     string files[];
      //     ScanSoundFolder(files);
      //     if(sel >= 0 && sel < ArraySize(files))
      //         m_marker_buy_sound_file = files[sel];
      //     return;
      //     }
      //   if(lparam == m_combo_sell_sound.Id())
      //     {
      //     int sel = (int)m_combo_sell_sound.GetListViewPointer().SelectedItemIndex();
      //     string files[];
      //     ScanSoundFolder(files);
      //     if(sel >= 0 && sel < ArraySize(files))
      //         m_marker_sell_sound_file = files[sel];
      //     return;
      //     }
      // }
    
    // Handle m_table_CandlePatternsSetting event (Bull/Bear checkbox toggle)
      // if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
      //   && lparam == m_table_CandlePatternsSetting.Id())
      // {
      //   string parts[];
      //   if(StringSplit(sparam, '_', parts) != 2) return;
      //   int col = (int)StringToInteger(parts[0]);
      //   int row = (int)StringToInteger(parts[1]);
      //   // col 3 = Sound, col 4 = Message - library already auto-toggled the image before this fires
      //   // Wire real behavior here (e.g. save to JSON, update Layer 1) when needed
      //   return;
      // } 
    //--- Layer 3 -> Layer 2 state sync: an indicator was added/removed/param-changed on some
    //--- chart window (possibly BY HAND on the chart) - re-truth the "Show" column. Events
    //--- come from m_chart_obj_collection.Refresh() polled in OnTimerEvent.
      
    //--- Layer 3 -> Layer 2: symbol/TF actually changed on this chart (CChartObjCollection,
    //--- same poll/diff pattern as IND_ADD/DEL/CHANGE above) - single place that rebuilds the
    //--- SymbolTF tree + indicator table on a real change. Replaces the old CHARTEVENT_CHART_CHANGE
    //--- handler, which duplicated this same refresh AND called ChartRedraw() a second time right
    //--- after OnInitEvent's REASON_CHARTCHANGE already did - that double-redraw was the
    //--- m_window_main flicker on every TF/symbol switch (fixed 2026-07-14).     
    
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
         InitializeTable_IndicatorTemplateSetting();
      //   SetValuesToTableIndicatorSymbolTFValue();
       // Just flag it - UpdateGUI() itself is called from 2+ places on the very same real
       // symbol/TF change (OnInitEvent's REASON_CHARTCHANGE branch AND the CHART_OBJ_EVENT_CHART_
       // ..._CHANGE handler), so calling SyncTreeView_IndicatorTemplateSetting() directly here was
       // the same double-redraw risk already fixed for m_treeview_SymbolTF (2026-08-26) - OnTimerEvent
       // is the ONE place that actually calls it now.
         m_treeview_indicator_need_sync = true;
         if(redraw) m_chart.Redraw();
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
