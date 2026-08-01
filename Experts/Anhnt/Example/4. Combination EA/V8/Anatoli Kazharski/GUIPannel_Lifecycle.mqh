//+------------------------------------------------------------------+
//|                                          GUIPannel_Lifecycle.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_LIFECYCLE_MQH
#define CGUIPANNEL_LIFECYCLE_MQH
//| Constructor/Destructor                                           | 
  CGUIPannel::CGUIPannel(void)
   {
    //--- Setting parameters for the time counters
       m_gui_timecounter.SetParameters(16, 500);
      //m_renderer = NULL;
       m_IndicatorsCollection  = NULL;
       m_int_table_indicator_SymbolTFValue_table_row_count  = 0;
       m_pending_remove_row     = -1;
       m_pending_remove_row_symboltf = -1;
       m_candle_info_shown_bar  = 0;
      //m_tick_series = NULL;
       m_gui_created     = false;
   }
  CGUIPannel::~CGUIPannel(void)
   {
   }
 //Get window index
  int CGUIPannel::WindowIdx(CWindow &wnd)
   {
      for(int i = 0; i < WindowsTotal(); i++)
         if(m_windows[i] == GetPointer(wnd))
            return i;
      return 0;
   } 
 // CGUIPannel Lifecycle  
  //+------------------------------------------------------------------+
  //| Init                                                             |
  //+------------------------------------------------------------------+ 
  bool CGUIPannel::OnInitEvent(const int uninit_reason)
   {      
    if(!m_gui_created)
     {
      if(!CreateGUIPannel()) return false;
      m_gui_created = true;
      // Snapshot every open chart (windows + indicators) once - Refresh() in OnTimerEvent
      // then diffs against this baseline and emits CHART_OBJ_EVENT_* on changes
       m_chart_obj_collection.CreateCollection();
       UpdateGUI(true);
      // --- Seed m_table_indicator's Buy/Sell checkboxes from indicators_config.json (same
      // --- pattern as ApplyLoadedSymbolTFSettings for m_table_indicator_SymbolTFSeting) - MUST
      // --- run after UpdateGUI() so m_table_indicator_ptrs[] is already built.
       ApplyLoadedIndicatorBuySell();
      // Startup reconcile: adopt any indicator the user attached while the EA was off.
      // MUST run AFTER UpdateGUI - m_IndicatorsCollection.TemplateExists() needs the collection
      // already populated; running before it re-imported
      // every JSON template as a duplicate (and AddIndicatorToList deleting those duplicates
      // was the source of the dangling-pointer crash in SignalsCollection).
       ImportForeignChartIndicators();
      // Debug helper (kept available, call disabled after the 4807 hunt closed): dump the
      // instance->handle map right after startup
      //m_time_series_engine.PrintIndicatorsInventory();
      // --- One-time retroactive purge (BugNote 2026-07-16, "2531 leftover Arrow objects after
      // --- Remove from chart"): cleans up legacy CreateSignalBuy/Sell/CreateThumbUp/Down
      // --- objects from sessions before OnDeinitEvent's own per-removal purge existed. Gated
      // --- so it only ever runs once per terminal, not once per chart/attach.
       if(!::GlobalVariableCheck("CombinationEA_SignalMarkersMigrated_v1"))
        {
         PurgeSignalArrowObjects(::Symbol(), EnumToString((ENUM_TIMEFRAMES)::Period()));
         ::GlobalVariableSet("CombinationEA_SignalMarkersMigrated_v1", 1);
        }
       EnsureMarkerIndicatorAttached();
     }
    else if(uninit_reason == REASON_CHARTCHANGE)
     {
      // No manual redraw here (2026-07-14) - MT5 already redraws the chart natively on
      // symbol/TF change, and CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE (OnEvent) does the
      // same content refresh moments later. Two ChartRedraw() calls back-to-back was
      // the m_window_main flicker on every TF switch.
       UpdateGUI(false);
      // --- No explicit bubble lazy-init call needed here (2026-07-14, BugNote "ChartChange
      // --- là mất") - CTradingLevelBubble now self-manages via EnsureCreated(), called from
      // --- its own OnPoll()/OnChartEvent() every time either is invoked, so the very next
      // --- OnEvent()/OnTimerEvent() call after this reinit already covers it.
      // --- Defensive re-check (cheap, idempotent) - the indicator itself already survives a
      // --- symbol/TF change on its own, this just covers the case where it got removed by hand.
       EnsureMarkerIndicatorAttached();
     }
    return true;
   };
  //+------------------------------------------------------------------+
  //| OnEvent handler                                                  |
  //+------------------------------------------------------------------+  
  void CGUIPannel::OnEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
   {
    // --- Trading bubble FIRST, before any other GUI Lib control gets a chance at this
    // --- event (2026-07-14, BugNote "khó di chuyển"/hard-to-drag): this used to be the
    // --- LAST thing forwarded in this function, so CHARTEVENT_MOUSE_MOVE during a drag
    // --- had to fall through every other branch below first. The bubble's own
    // --- OnChartEvent() already no-ops for event types it doesn't care about, and now also
    // --- self-manages its own lazy-init via EnsureCreated() (2026-07-14), so it's always
    // --- safe to forward every event to it regardless of whether it's created yet.
     m_trading_bubble.OnChartEvent(id, lparam, dparam, sparam);
    // --- Ctrl+hover candle info popup (BugNote 7.2, redesigned 2026-07-16). m_mouse is already
    // --- refreshed for this event by CWndEvents::InitChartEventsParams() before OnEvent() is
    // --- called, so X()/Y() here are current.
    //
    // --- Use case (Anhnt, 2026-07-16):
    //  1. Ctrl+hover a candle with NO signal at all -> popup does not appear.
    //  2. Ctrl+hover a candle WITH a signal -> popup appears; cursor is already inside its
    //     rect the instant it appears (CANDLE_INFO_CURSOR_INSET), zero distance to cross.
    //  3. Mouse moves further into the popup/table to drag the scrollbar - MouseOverCandle-
    //     InfoWindow() being true is the ONLY thing keeping it open past this point; Ctrl no
    //     longer matters once inside.
    //  4. Mouse leaves the popup's rect -> it hides and native dispatch reverts to m_window_main.
    //
    // --- ShowCandleInfoPopup()/HideCandleInfoPopup() also swap m_active_window_index so
    // --- CWndEvents::CheckElementsEvents() natively dispatches to the table (scrollbar
    // --- included) while shown - see those methods for why m_window_main going quiet during
    // --- that window isn't a real trade-off (mouse can't be on both at once).
     if(id == CHARTEVENT_MOUSE_MOVE)
      {
       bool popup_shown = (m_candle_info_shown_bar != 0);
       if(popup_shown && MouseOverCandleInfoWindow())
         {
          // --- Stay open, don't touch bar_time - let the table's native dispatch (now
          // --- routed to it via m_active_window_index) handle the scrollbar/clicks.
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
         }
        else if(popup_shown)
         {
          HideCandleInfoPopup();
          m_candle_info_shown_bar = 0;
         }
      }
    // --- Re-hide param slots after CTabs::ShowTabElements() shows them on tab switch.
    //     ShowTabElements() runs inside CTabs::OnEvent() (before our OnEvent is called),
    //     so by this point the slots are already visible — we undo that.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main.Id())
      {
       HideParamSlots();
       return;
      }
    // --- Same issue on the NESTED m_tabs_main_setting_config (Indicator/Symbol TF sub-tabs) -
    //     it's its own CTabs with its own ON_CLICK_TAB event, so switching between its 2 tabs
    //     runs its own ShowTabElements() -> Reset() cascade, which force-shows m_param_labels/
    //     m_param_edits/m_param_combo[] the same way the outer tab switch does.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main_setting_config.Id())
      {
       HideParamSlots();
       return;
      }
    // --- Same issue on window expand: OnWindowExpand() calls ShowTabElements() before
    //     our OnEvent runs. Re-hide to keep param slots invisible until tree node clicked.
     if(id == CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND && lparam == m_window_main.Id())
      {
       HideParamSlots();
       return;
      }
    // --- On window collapse: library OnWindowCollapse() may skip elements with Id()==0
    //     (e.g. dynamic TreeItems). Explicitly hide both treeviews so their items
    //     cascade-hide, eliminating gray canvas artifacts on the chart.
     if(id == CHARTEVENT_CUSTOM + ON_WINDOW_COLLAPSE && lparam == m_window_main.Id())
      {
       m_treeview_indicator.Hide();
       m_treeview_SymbolTF.Hide();
       HideParamSlots();
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
               ShowIndicatorParameterForm(m_type_node_value[i], li);
               break;
            }
         }
         return;
      }
    //Handle Add Indicator
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_add_indicator.Id())
      {
         OnClickAddIndicator();
         return;
      }
    //Handle Save Indicator config to JSON
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_indicator.Id())
      {
         OnClickSaveIndicators();
         return;
      }
    //Handle m_table_indicator event
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
        && lparam == m_table_indicator.Id())
      {
         string parts[];
         if(StringSplit(sparam, '_', parts) != 2) return;
         int col = (int)StringToInteger(parts[0]);
         int row = (int)StringToInteger(parts[1]);
         if(row < 0 || row >= ArraySize(m_table_indicator_names)) return;
         string sname = m_table_indicator_names[row];

         // --- col 0 = Tang 1 (remove template from PureData), col 4 = Tang 3
         // --- (show/hide on chart). Buy/Sell unchanged at 2/3.
         // --- Delete is DEFERRED to OnTimerEvent: rebuilding the table here, inside its
         // --- own click processing, crashes CTable (stale focus/press row indices).
         if(col == 0)        m_pending_remove_row = row;
         else if(col == 2)    OnClickToggleBuySignal(sname, row);
         else if(col == 3)    OnClickToggleSellSignal(sname, row);
         //else if(col == 4)    OnClickShowLine(sname, row);     // toggle ChartIndicatorAdd/Delete
         else if(col == 4)    OnClickToggleShowIndicatorOnChart(sname, row);     // toggle ChartIndicatorAdd/Delete
         return;
      }
    //Handle Save Symbol/TF config to JSON
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_SymbolTF.Id())
      {
         OnClickSaveSymbolTF();
         return;
      }
    //Handle Save marker style/color settings
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.Id())
      {
         OnClickSaveMarkerSettings();
         return;
      }
    //Handle "Refresh" next to the sound folder path - re-scans and re-populates both combos
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_refresh_sound_folder.Id())
      {
         OnClickChangeSoundFolder();
         return;
      }
    //Handle Other tab combo selection - live-updates the preview immediately (BEFORE Save),
    //so the user sees what they're about to pick, not just its number/name. Reads directly off
    //the just-clicked combo's own SelectedItemIndex() - m_marker_* only changes on Save.
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
      }
    //Handle m_table_indicator_SymbolTFSeting event
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
        && lparam == m_table_indicator_SymbolTFSeting.Id())
      {
         string parts[];
         if(StringSplit(sparam, '_', parts) != 2) return;
         int col = (int)StringToInteger(parts[0]);
         int row = (int)StringToInteger(parts[1]);
         if(row < 0 || row >= (int)m_table_indicator_SymbolTFSeting.RowsTotal()) return;
         string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row); StringTrimLeft(sym);
         string tf  = m_table_indicator_SymbolTFSeting.GetValue(1, row); StringTrimLeft(tf);

         // --- Delete is DEFERRED to OnTimerEvent - same CTable crash reason as m_table_indicator's col 0.
         // --- col 0 on the current-chart's own row shows the "start" icon (IsCurrentChartSymbolTFRow) -
         // --- not deletable, ignore the click.
         if(col == 0 && !IsCurrentChartSymbolTFRow(sym, tf))
            m_pending_remove_row_symboltf = row;
         else if(col == 2 || col == 3)
            OnCheckTableSymbolTFSetting(sym, tf, row, col);
         return;
      }
    //--- Layer 3 -> Layer 2 state sync: an indicator was added/removed/param-changed on some
    //--- chart window (possibly BY HAND on the chart) - re-truth the "Show" column. Events
    //--- come from m_chart_obj_collection.Refresh() polled in OnTimerEvent.
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_DEL ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
      {
         // A NEW indicator on the chart may be one Layer 1 doesn't know yet (added by hand) -
         // import it as a template first (idempotent), THEN re-truth the "Show" column.
         if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD)
            ImportForeignChartIndicators();
         // A param edit made ON THE CHART replaces the matching Layer 1 template (Layer 3
         // leads, Layer 1+2 follow). A DEL stays visibility-only: Layer 1 keeps the
         // template, only the "Show" checkbox unticks.
         if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
            HandleChartIndicatorChange();
         RefreshIndicatorTableShowColumn();
         return;
      }
    //--- Layer 3 -> Layer 2: symbol/TF actually changed on this chart (CChartObjCollection,
    //--- same poll/diff pattern as IND_ADD/DEL/CHANGE above) - single place that rebuilds the
    //--- SymbolTF tree + indicator table on a real change. Replaces the old CHARTEVENT_CHART_CHANGE
    //--- handler, which duplicated this same refresh AND called ChartRedraw() a second time right
    //--- after OnInitEvent's REASON_CHARTCHANGE already did - that double-redraw was the
    //--- m_window_main flicker on every TF/symbol switch (fixed 2026-07-14).
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_CHANGE ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_TF_CHANGE ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE)
      {
         PopulateSymbolTFTree();
         SynSymbolTFTreeViewIcons();
         PopulateTableSymbolTFSetting();   // additive-only: picks up any newly tracked Symbol+TF pair
         SyncTableSymbolTFSettingCurrentChartIcon();   // "current chart" row just moved
         UpdateGUI(false);   // dirty-check refresh only - no manual redraw, MT5 already redraws natively on chart change
         return;
      }
    //Handle Symbol TF TreeView Click
     //ON_CLICK_BUTTON
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON  && lparam == m_treeview_SymbolTF.Id())
       {
         int li = (int)dparam;
         // ADDED: guard against stale/out-of-range list_index from event queue.
         // ItemPointer() clamps silently so item != NULL even for invalid li;
         // this early return prevents navigating to the wrong node.
         if(li < 0 || li >= m_treeview_SymbolTF.ItemsTotal()) return;
         CTreeItem *item = m_treeview_SymbolTF.ItemPointer(li);         
         //--------------------------------
         if(item == NULL) return;
         int parent_pos = m_treeview_SymbolTF.ItemPrevNode(li);
         if(parent_pos == -1)  // Symbol node
          {
            if(item.ItemType() == TI_SIMPLE) //No TF Found
            {              
              ChartSetSymbolPeriod(0, item.LabelText(), _Period);
            } 
          }
         else // TF node → navigate to exact sym + tf
          {
            CTreeItem *parent = m_treeview_SymbolTF.ItemPointer(parent_pos);
            if(parent != NULL)
             {
               ENUM_TIMEFRAMES target_tf = TimestampByDescription(item.LabelText());
               ChartSetSymbolPeriod(0,parent.LabelText(),target_tf);
             }
          }
         return;
         }
    // --- CHARTEVENT_CHART_CHANGE: symbol/TF tree rebuild moved to CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE
    // --- above (2026-07-14) - this native event still fires on every scroll/zoom too, so it was never
    // --- a reliable "did symbol/TF really change" signal on its own; the CChartObjCollection event is.
   }
  void CGUIPannel::OnTickEvent(void)
   {
      // --- Positions Table (TAB_TAB_MAIN_POSITIONS) - ported verbatim from V1, 2026-07-19:
      // --- row-count mismatch (new/closed symbol) forces a full rebuild; otherwise a plain
      // --- dirty-checked value refresh, same as V1's own OnTickEvent.
       bool redraw_needed = false;
       string pos_symbols_name[];
       int pos_symbols_total = GetPositionsSymbols(pos_symbols_name);
       int pos_rows_total = (int)m_table_positions.RowsTotal();
       if(pos_symbols_total > 0 && pos_symbols_total != pos_rows_total)
        {
         InitializePositionsTable();
         redraw_needed = true;
        }
       else if(pos_symbols_total > 0)
         redraw_needed = SetValuesToPositionsTable(pos_symbols_name);
      // --- Status Bar (Deposit Load/Profit/Server Time), only update+redraw when a value
      // --- actually changed - same call site/pattern as V1's OnTickEvent. Symbol Info table
      // --- updates that used to sit alongside this in V1 aren't ported yet (still an empty
      // --- shell in V7).
       if(UpdateStatusBar())
         redraw_needed = true;
      // --- Pre-trade-plan table (Anhnt 2026-07-20): Entry/SL live off Bid/Ask, dirty-checked
      // --- per-cell same as everywhere else in this file.
       if(SetValuesToPreTradePlanTable())
         redraw_needed = true;
       if(redraw_needed)
         ::ChartRedraw();
   }
  //+------------------------------------------------------------------+
  //| Trade operation event - refresh positions table on a new deal    |
  //+------------------------------------------------------------------+
  void CGUIPannel::OnTradeEvent(void)
   {
      if(IsLastDealTicket())
         InitializePositionsTable();
   }
  //+------------------------------------------------------------------+
  //| Deinit                                                           |
  //+------------------------------------------------------------------+
  void CGUIPannel::OnDeinitEvent(const int reason)
   {
      // --- CHARTCHANGE (TF/symbol switch on this SAME chart) must NOT touch
      // --- m_trading_bubble's chart-level properties (Anhnt, 2026-07-19): its own
      // --- OnDeinitEvent() restores CHART_SHOW_TRADE_LEVELS/CHART_SHIFT to MT5
      // --- defaults, which only gets undone again (back to the bubble's preferred
      // --- values) once EnsureCreated() next runs - and that's gated on HasAnyLevel(),
      // --- so with zero open positions right after a TF change, native trade-level
      // --- lines stay stuck ON indefinitely. The chart itself isn't going anywhere on
      // --- CHARTCHANGE, so there's nothing to restore - skip it, same as every other
      // --- teardown step below that already special-cases this reason.
      if(reason != REASON_CHARTCHANGE)
        {
         m_trading_bubble.OnDeinitEvent();
         CWndEvents::Destroy();
         // --- Legacy cleanup (BugNote 2026-07-16, "2531 leftover Arrow objects after Remove
         // --- from chart"): the OLD graphic-object drawing path (CreateSignalBuy/Sell/
         // --- CreateThumbUp/Down, now retired in favor of the SignalMarkers.mq5 indicator +
         // --- bridge file) never purged its own objects on final removal. Purge this chart's
         // --- own current (sym, tf) directly - the broader one-time sweep for OTHER (sym,tf)
         // --- combos this chart visited in past sessions lives in OnInitEvent instead (gated
         // --- by a GlobalVariable so it only ever runs once per terminal).
         PurgeSignalArrowObjects(::Symbol(), EnumToString((ENUM_TIMEFRAMES)::Period()));
         // --- ChartIndicatorAdd() makes SignalMarkers.mq5 an independent chart program - it
         // --- keeps running/drawing even after this EA is gone unless explicitly detached here.
         RemoveMarkerIndicator();
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
         if(remove_row < ArraySize(m_table_indicator_names))
            OnClickRemoveIndicator(m_table_indicator_names[remove_row], remove_row);
        }
      //--- Deferred delete for m_table_indicator_SymbolTFSeting - GUI-only removal (no Tang 1
      //--- series is stopped yet, see PopulateTableSymbolTFSetting note)
      if(m_pending_remove_row_symboltf >= 0)
        {
         int remove_row = m_pending_remove_row_symboltf;
         m_pending_remove_row_symboltf = -1;
         if(remove_row < (int)m_table_indicator_SymbolTFSeting.RowsTotal())
           {
            // --- Drop the pair from indicators_config.json BEFORE the row disappears - live
            // --- Tang1 (BarSeriesDE/indicators/signals) keeps running this session (no Library
            // --- removal method yet); it just won't be recreated on the next EA attach/restart.
            string sym = m_table_indicator_SymbolTFSeting.GetValue(0, remove_row); StringTrimLeft(sym);
            string tf  = m_table_indicator_SymbolTFSeting.GetValue(1, remove_row); StringTrimLeft(tf);
            if(m_time_series_engine != NULL)
               m_time_series_engine.RemoveSymbolTFFromConfigJSON("Config_Setting.json", sym, tf);
            m_table_indicator_SymbolTFSeting.DeleteRow(remove_row, true);
           }
        }
      //--- Handling the elements

      ulong t0 = ::GetMicrosecondCount();

      CWndEvents::OnTimerEvent();

      ulong t1 = ::GetMicrosecondCount();

      // --- CTradingLevelBubble self-manages lazy-init via EnsureCreated(), called from the
      // --- top of its own OnPoll() (2026-07-14) - GUIPannel no longer needs to track whether
      // --- it's created or special-case the retry, just poll it unconditionally every tick.
      m_trading_bubble.OnPoll();

      SetValuesToTableIndicatorSymbolTFValue();
      BuildAndWriteSignalBridge();
      CheckIndicatorAlerts();
      //--- Layer-3 observer poll: diffs all open charts and broadcasts CHART_OBJ_EVENT_*
      //--- custom events (handled in OnEvent -> RefreshIndicatorTableShowStates)
      m_chart_obj_collection.Refresh();

      ulong t2 = ::GetMicrosecondCount();
      // if(t2 - t0 > 1000)
      //  Print("PERF CGUIPannel::OnTimerEvent CWndEvents::OnTimerEvent= ", t1 - t0, " us CTradingLevelBubble::OnPoll= ", t2 - t1, " us");
   }   
 //For GUIPannel
  bool CGUIPannel::CreateGUIPannel(void) 
   { 
      //DiscoverPatterns(); //Call before CreatePatternConfigTable
      //--- Creating form 1 for controls
      //Create control
       //Create m_window_main
        if (!CreateMainWindow("EXPERT PANEL Ver8 Seperation Module"))
         {
            Print(__FUNCTION__, " > Failed to create panel!");
            return (false);
         }
        //Create m_treeview_SymbolTF in left panel m_window_main        
         PopulateSymbolTFTree();        
         if(!CreateTreeView_SymbolTF(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+2)) return false;  //WINDOW_CAPTION_HEIGHT = 22
         SynSymbolTFTreeViewIcons(); 
        //Create m_tabs_main in right panel m_window_main 
         if (!CreateTab_Main(M_TABS_MAIN_X, M_TABS_MAIN_Y))
          {
            Print(__FUNCTION__, " > Failed to create Tabs1!");
            return (false);
          }
          //Create control at Each Tab
           //Create m_table_indicator_SymbolTFValue control at TAB_TAB_MAIN_TRADE m_tabs_main
            if(!CreateTableIndicatorSymbolTFValue(0, 0)) return false;
           //For TAB_TAB_MAIN_SETTINGS Tab at m_tabs_main
            //Right Pannel of TAB_TAB_MAIN_SETTINGS m_tabs_main_setting_config
              if (!CreateTabSettingConfig(0, TABS_CONFIG_HEADER_H))
               {
                 Print(__FUNCTION__, " > Failed to create Settings config tabs!");
                 return (false);
               }
            //Left pannel of TAB_TAB_MAIN_SETTINGS m_treeview_indicator
             PopulateIndicatorTree();
             if(!CreateTreeView_Indicator(0, 0)) return false; 
             if(!CreateAddIndicatorParaInfor(PARAM_FORM_X, PARAM_FORM_Y)) return false;
             if(!CreateTabbleIndicator(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;
             
        //Create Status Bar at m_window_main
         if (!CreateStatusBar(1, 23))
          {
            Print(__FUNCTION__, " > Failed to create Status Bar!");
            return (false);
          } 
       //Create m_window_candle_infomation Information window at to display signal on chart
        if (!CreateWindowCandleInfo())
          {
            Print(__FUNCTION__, " > Failed to create candle info popup!");
            return (false);
          }
        m_window_candle_infomation.Hide();  
       //For Symbol TF sub-tab at m_tabs_main_setting_config
        if(!CreateTableSymbolTFSetting(0, WINDOW_CAPTION_HEIGHT)) return false;
        PopulateTableSymbolTFSetting();
        ApplyLoadedSymbolTFSettings();   // seed Buy/Sell from indicators_config.json, once (see note)
       //For Other sub-tab at m_tabs_main_setting_config (marker shape/color settings)
        if(!CreateTabSettingConfig_Marker(0, WINDOW_CAPTION_HEIGHT)) return false;
       //For Trade Tab at m_tabs_main
        
       //For Positions Tab at m_tabs_main - ported verbatim from V1 (2026-07-19)
       //--- Pre-trade-plan area (2026-07-20): symbol combo, then the Distance/Lot mode+value
       //--- controls in one horizontal row, then the order-setup table, m_table_positions
       //--- still shifted down to POSITIONS_TABLE_Y below all of it.
        if(!CreatePreTradePlanSymbolCombo(0, POSITIONS_PLAN_Y)) return false;
        if(!CreatePreTradePlanControls(0, POSITIONS_PLAN_CONTROLS_Y)) return false;
        if(!CreateTablePreTradePlan(0, POSITIONS_PLAN_TABLE_Y)) return false;
        if(!CreatePositionsTable(0, POSITIONS_TABLE_Y)) return false;
      // --- Trading bubble: just wire the mouse pointer now (cheap, no canvas yet) -
      // --- it lazily creates its own canvas via EnsureCreated(), called from its own
      // --- OnPoll()/OnChartEvent(), only once HasAnyLevel() is true (avoid creating a
      // --- full-screen canvas + hiding native SL/TP lines when there is nothing to show).
        m_trading_bubble.MousePointer(m_mouse);
        m_trading_bubble.SetChartObjCollection(GetPointer(m_chart_obj_collection));      
      CWndEvents::CompletedGUI();
      // --- Hide all slots ONLY AFTER CompletedGUI() - FormAvailableElementsArray() (called
      // --- inside CompletedGUI) registers only VISIBLE elements into m_available_elements[],
      // --- which CComboBox's click-open mechanism depends on. Hiding before CompletedGUI
      // --- would exclude them permanently even after Show() - confirmed by reading
      // --- FormAvailableElementsArray()'s IsVisible() filter.
      HideParamSlots();
      // --- Same reasoning as HideParamSlots above: hide only AFTER CompletedGUI so
      // --- FormAvailableElementsArray() still registers its labels as available.
      

      //Debug
        //  Print("My Debug CreateGUIPannel END m_split_container.IsVisible=", m_split_container.IsVisible(),
        //  " m_config_detail_tabs.IsVisible=", m_tabs_indicator_config.IsVisible(),
        //  " m_tabs_main.SelectedTab=", m_tabs_main.SelectedTab());
      return true;
   }   
  //+------------------------------------------------------------------+
  //| Update GUI                                                       |
  //+------------------------------------------------------------------+
  void CGUIPannel::UpdateGUI(const bool redraw)
   {
      // No unconditional full-canvas Update(true) here - repainting the whole treeview and
      // the whole Settings table on every CHARTCHANGE was exactly the m_window_main blink.
      // Each call below repaints only the cells/icons it actually changed (dirty-check),
      // and PopulateSymbolTFTree (CHARTEVENT_CHART_CHANGE handler) already updates the tree
      // when the symbol/TF really changed.
       RefreshTableIndicator();
       SetValuesToTableIndicatorSymbolTFValue();
       SyncIndicatorTreeViewIcons();
       if(redraw) m_chart.Redraw();
   }
  // --- Two independent paths (Anhnt, 2026-07-17 design discussion):
  // --- CLOSED bar (HistoryTime/HistoryDir): never Sound/Message - the chart Marker already
  // --- shows these visually. Only appended to Signal_Log.csv (status "Closed"), gated by a
  // --- per-template watermark (m_wm_*, persisted to Signal_Log_Watermark_<SYMBOL>_<TF>.json)
  // --- so a restart's SyncHistory backfill catches up the CSV without ever duplicating a row
  // --- already on disk, and without ever making noise for old history.
  // --- LIVE bar 0 (GetCurrentSignal): the still-forming bar can flip back and forth several
  // --- times before it closes - each REAL change (vs m_live_signal_last_seen[row]) fires
  // --- Sound+Message+CSV (status "Live") immediately with TimeCurrent(), since there's no
  // --- fixed bar time yet. Runs every OnTimerEvent tick - cheap, no file I/O unless something
  // --- actually changed.
  void CGUIPannel::CheckIndicatorAlerts(void)
    {
      if(m_time_series_engine == NULL) return;
      int rows = ArraySize(m_table_indicator_ptrs);
      if(rows == 0) return;
      if(!m_signal_log_watermarks_loaded)
        {
         m_signal_logger.LoadSignalLogWatermarks();
         m_signal_log_watermarks_loaded = true;
        }
      int prev_size = ArraySize(m_live_signal_last_seen);
      bool seeding = (prev_size != rows); // new rows just appeared - seed their baseline, don't fire
      if(seeding)
        {
         ArrayResize(m_live_signal_last_seen, rows);
         ArrayResize(m_upper_last_seen, rows);
         ArrayResize(m_lower_last_seen, rows);
        }

      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);
      for(int row = 0; row < rows; row++)
        {
         CIndicatorDE *ind = m_table_indicator_ptrs[row];
         if(ind == NULL) continue;
         CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(signal == NULL) continue;

         bool sound_on   = ((int)m_table_indicator.SelectedImageIndex(5, row) == 0);
         bool message_on = ((int)m_table_indicator.SelectedImageIndex(6, row) == 0);
         if(!sound_on && !message_on) continue;

         string label   = BuildIndicatorLabel(ind, catalog);
         string tf_text = TimeframeDescription(ind.Timeframe());
         int digits = (int)::SymbolInfoInteger(ind.Symbol(), SYMBOL_DIGITS);
         string type_key, params_key;
         BuildTemplateMatchKey(ind, catalog, type_key, params_key);

         //--- BBands-only: Upper/Lower lines, each backed by CSignalBollinger's OWN real
         //--- persisted history (Layer 1) - safe downcast, ind.TypeIndicator()==IND_BANDS
         //--- already confirms `signal` really is a CSignalBollinger instance. Mid is NOT
         //--- processed here (Anhnt, 2026-07-19): it's now the primary signal itself (see
         //--- CSignalBollinger::ComputeAt), handled by the generic closed-bar/live-bar block
         //--- below like any other indicator - processing it here too would double-fire it.
         if(message_on && ind.TypeIndicator() == IND_BANDS)
           {
            CSignalBollinger *bb = (CSignalBollinger*)signal;
            ProcessBandLine(row, bb, BBAND_LINE_UPPER, "Upper", m_upper_last_seen, seeding, type_key, params_key, label, tf_text, digits);
            ProcessBandLine(row, bb, BBAND_LINE_LOWER, "Lower", m_lower_last_seen, seeding, type_key, params_key, label, tf_text, digits);
           }

         //--- Closed-bar path: log-only catch-up of every committed flip newer than the
         //--- persisted per-template watermark - never Sound/Message.
         datetime wm = m_signal_logger.GetSignalLogWatermark(type_key, params_key);
         int total = signal.HistoryTotal();
         datetime newest_committed = wm;
         for(int idx = 0; idx < total; idx++)
           {
            datetime t = signal.HistoryTime(idx);
            if(t <= wm) continue;
            ENUM_SIGNAL_DIR hdir = signal.HistoryDir(idx);
            string dir_text = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
            // --- BBands' own primary signal IS the MidBand cross now (Anhnt, 2026-07-19) -
            // --- name it explicitly so this row can't be confused with the Upper/Lower
            // --- line-cross rows (ProcessBandLine, below) which use the same "Buy"/"Sell" text.
            string cross_text = (ind.TypeIndicator() == IND_BANDS)
                                 ? ((hdir == SIGNAL_BUY) ? "Cross Up MidBand" : "Cross Down MidBand") : "";
            string time_text = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
            // --- Bar already closed - look up ITS OWN Close, not the current live price
            // --- (Anhnt, 2026-07-17): map flip_time back to a shift via iBarShift.
            int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
            double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
            string price_text = ::DoubleToString(price, digits);
            m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Closed", cross_text);
            if(t > newest_committed) newest_committed = t;
           }
         if(newest_committed > wm)
            m_signal_logger.SetSignalLogWatermark(type_key, params_key, newest_committed);

         //--- Live bar-0 path: fire Sound+Message+CSV on every real direction change.
         ENUM_SIGNAL_DIR live_dir = signal.GetCurrentSignal();
         if(seeding)
           {
            // --- Upper/Lower baselines already seeded by ProcessBandLine above; Mid is this
            // --- very signal (see CSignalBollinger::ComputeAt), seeded right here.
            m_live_signal_last_seen[row] = live_dir; // baseline only, never fires on first sight
            continue;
           }
         if(live_dir == m_live_signal_last_seen[row]) continue;
         m_live_signal_last_seen[row] = live_dir;
         if(live_dir == SIGNAL_NONE) continue; // dropped to no-signal - not alert-worthy itself

         bool is_buy = (live_dir == SIGNAL_BUY);
         if(sound_on)
           {
            // --- Deliberately native ::PlaySound(), NOT CMessage::PlaySound() (Anhnt,
            // --- 2026-07-17 - confirmed by reading Message.mqh): that wrapper unconditionally
            // --- prepends "\Files\" to any filename that isn't one of its own built-in SND_*
            // --- constants, no matter what we pass it - so it can NEVER reach a file sitting in
            // --- MQL5\Sounds\ (only MQL5\Files\...\ - a different sandbox from FileFindFirst/
            // --- FileOpen, which only reach MQL5\Files\ - see the Sound-picker combobox's own
            // --- ScanSoundFolder). The chosen .wav needs to physically exist in MQL5\Sounds\
            // --- (copied once, not auto-synced) - native ::PlaySound(bare filename) resolves
            // --- against that folder directly, with no wrapper in the way.
             string file = is_buy ? m_marker_buy_sound_file : m_marker_sell_sound_file;
             if(file != "")
                ::PlaySound(file);
           }
         if(message_on)
           {
            // --- Field order Time;Live/Closed;TF;Indicator;Signal (Anhnt, 2026-07-17) - ";"
            // --- delimited so pasting Journal lines straight into Excel auto-splits into columns,
            // --- same convention as Signal_Log.csv's own sep=; fix. Closed bars never reach this
            // --- branch at all (log-only, see the loop above) - every message printed here IS a
            // --- Live bar-0 event, hence the literal "Live" in the 2nd field.
             string dir_text  = is_buy ? "Buy" : "Sell";
            // --- Same MidBand naming as the closed-bar loop above (Anhnt, 2026-07-19).
             string cross_text = (ind.TypeIndicator() == IND_BANDS)
                                  ? (is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
             string time_text = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
            // --- Bar 0 hasn't closed yet - treat the CURRENT price as its "Close" (Anhnt, 2026-07-17).
             double price = ::iClose(ind.Symbol(), ind.Timeframe(), 0);
             string price_text = ::DoubleToString(price, digits);
             CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
             m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Live", cross_text);
           }
        }
    }    
  // --- Layer 3 -> Layer 1 sync for a param edit made ON THE CHART (README: 3-layer sync).
  // --- Trishkin's change-check kept a COPY of the old mirror entry (old name+handle) in
  // --- m_list_ind_param and updated the live mirror entry in place with the new name+handle
  // --- at the same window/index. So: old handle -> the exact Layer 1 template to replace;
  // --- the live mirror entry at the same index -> the new params.
  void CGUIPannel::HandleChartIndicatorChange(void)
   {
      if(m_time_series_engine == NULL) return;
      CWndInd *old_ind = m_chart_obj_collection.GetLastChangedIndicator();
      //--- Every exit path reports itself: chart edits are rare, user-driven events and
      //--- each outcome (replace/skip/fail) is worth an audit line in the log
       if(old_ind == NULL) { ::Print(__FUNCTION__, " > no changed-indicator record"); return; }
       ::Print(__FUNCTION__, " > chart edit detected: old '", old_ind.Name(), "' handle=", old_ind.Handle(),
              " win=", old_ind.WindowNum(), " index=", old_ind.Index());
      // A hand-added line is a SEPARATE terminal instance - OwnedInstanceOfLine falls back
      // to type+params matching. Truly foreign lines (no matching template) are skipped:
      // the ADD/import path picks the new line up by itself.
       CIndicatorDE *owned = OwnedInstanceOfLine(old_ind.Handle());
       if(owned == NULL) { ::Print(__FUNCTION__, " > line matches no Layer 1 template - skip"); return; }
       CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
       if(chart == NULL) { ::Print(__FUNCTION__, " > no CChartObj for this chart"); return; }
       CChartWnd *wnd = chart.GetWindowByNum(old_ind.WindowNum());
       if(wnd == NULL) { ::Print(__FUNCTION__, " > no CChartWnd num=", old_ind.WindowNum()); return; }
       CWndInd *new_ind = NULL;
       for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
         {
          CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
          if(wnd_ind != NULL && wnd_ind.Index() == old_ind.Index()) { new_ind = wnd_ind; break; }
         }
       if(new_ind == NULL || new_ind.Handle() == INVALID_HANDLE)
        { ::Print(__FUNCTION__, " > no mirror entry at window index ", old_ind.Index()); return; }
       ENUM_INDICATOR type;
       MqlParam params[];
       if(IndicatorParameters(new_ind.Handle(), type, params) < 0)
         { ::Print(__FUNCTION__, " > IndicatorParameters failed, err ", GetLastError()); return; }
      // Find the table row of the owned template (its current-symbol/TF instance is the
      // very object GetIndicatorByHandle returned, because the edit happened on THIS chart)
       int row = -1;
       for(int r = 0; r < ArraySize(m_table_indicator_ptrs); r++)
         if(m_table_indicator_ptrs[r] == owned) { row = r; break; }
       ::Print(__FUNCTION__, " > chart edit: replacing template '", old_ind.Name(),
              "' with '", new_ind.Name(), "'");
      // Replace = remove the old template across ALL series + add the new one across ALL
      // series (CIndicatorDE cannot change params in place - its handle is bound to the
      // old instance). One row out, one row in - the table keeps its size.
      // NOTE: owned is DEAD after OnClickRemoveIndicator (collection FreeMode deletes it).
       if(row >= 0)
         OnClickRemoveIndicator(m_table_indicator_names[row], row);
        AddIndicatorInstance(-1, type, params);
   }
  // --- Layer 3 -> Layer 1 import (README: 3-layer sync): an indicator is present on the MAIN
  // --- chart that Layer 1 does not know yet (added BY HAND on the chart). Rebuild its
  // --- type+params via IndicatorParameters() and feed it through the SAME entry point as the
  // --- GUI "Add" button (AddIndicatorInstance), so the duplicate guard, the engine creation
  // --- across ALL series (+Signals via GetOrCreateSignal) and the template-row append all
  // --- behave identically. Idempotent: our own ChartIndicatorAdd (Show checkbox) also fires
  // --- IND_ADD, but TemplateExists() filters it out here without log spam.
  void CGUIPannel::ImportForeignChartIndicators(void)
   {
     if(m_time_series_engine == NULL) return;
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     // Layer 3 topology comes from CChartObjCollection (the one chart observer),
     // not from raw built-in scans - README: 3-layer sync.
      CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
      if(chart == NULL) return;
      for(int win = 0; win < chart.WindowsTotal(); win++)
        {
         CChartWnd *wnd = chart.GetWindowByNum(win);
         if(wnd == NULL) continue;
         for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
           {
            CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
            if(wnd_ind == NULL) continue;
            string name = wnd_ind.Name();
            // The mirror's handle is the join key: same program-wide slot number as the
            // owned instance when the line belongs to Layer 1. Never released anywhere
            // in the GUI - the sole IndicatorRelease site is ~CIndicatorDE.
            int handle = wnd_ind.Handle();
            if(handle == INVALID_HANDLE) continue;
            if(m_time_series_engine.GetIndicatorByHandle(handle) != NULL)
               continue;   // Layer 1 owns it already: nothing to import
            ENUM_INDICATOR type;
            MqlParam params[];
            int params_total = IndicatorParameters(handle, type, params);
            // Only types Layer 1 knows how to create (present in the catalog)
            bool supported = false;
            for(int c = 0; c < ArraySize(catalog); c++)
               if(catalog[c].type == type) { supported = true; break; }
            if(params_total < 0 || !supported || m_IndicatorsCollection.TemplateExists(type, params))
               continue;
            ::Print(__FUNCTION__, " > importing hand-added indicator '", name, "' into Layer 1");
            // Adopt: AddIndicatorInstance -> IndicatorCreate returns this very slot and
            // Layer 1 becomes its owner (released exactly once, in ~CIndicatorDE).
            AddIndicatorInstance(-1, type, params);
           }
        }
   }
  
#endif // CGUIPANNEL_LIFECYCLE_MQH
