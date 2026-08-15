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
   // Build pattern list trước tạo GUI     
    this.BuildCandlePatternListFromRegistry();      
   //DiscoverPatterns(); //Call before CreatePatternConfigTable
   //--- Creating form 1 for controls   
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
    // For
     //DiscoverPatterns();
     RegisterPatterns();
     if(!CreateTableCandlePatternSetting(0, 0)) return false;
     InitializeTableCandlePatternSetting();
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
     if(!CreateTablePositions(0, POSITIONS_TABLE_Y)) return false;
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
     return true;
  }
//Public Method
 //| Constructor/Destructor                                          | 
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
    m_pattern_bitmap_shown   = NULL;
    m_pattern_bitmap_scale   = -1;
   //m_tick_series = NULL;
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
     //Init m_bridge_writer
      if(m_time_series_engine != NULL &&
         m_IndicatorsCollection != NULL &&
         m_BarTimeSeriesCollection != NULL)
       {
        m_bridge_writer.Initialize(
                        m_time_series_engine.GetSignalsCollection(),
                        m_IndicatorsCollection,
                        m_BarTimeSeriesCollection);
       }
     // Set folder paths for file writers (Anhnt, 2026-08-08)
      string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
      m_signal_logger.SetFolder(ea_folder);
      m_bridge_writer.SetFolder(ea_folder);
     //Create main GUI windows and sub windows.
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
    ::ObjectDelete(m_chart_id, PATTERN_HOVER_LABEL_NAME);   // Alt+hover pattern label, harmless no-op if never created
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
    UpdateSignalBridgeTemplateFlags();
    m_bridge_writer.BuildAndWriteSignalBridge();
   //--- Layer-3 observer poll: diffs all open charts and broadcasts CHART_OBJ_EVENT_*
   //--- custom events (handled in OnEvent -> RefreshIndicatorTableShowStates)
    m_chart_obj_collection.Refresh();
    ulong t2 = ::GetMicrosecondCount();
   // if(t2 - t0 > 1000)
   //  Print("PERF CGUIPannel::OnTimerEvent CWndEvents::OnTimerEvent= ", t1 - t0, " us CTradingLevelBubble::OnPoll= ", t2 - t1, " us");
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
      if(UpdateStatusBar())
        redraw_needed = true;
    // --- Pre-trade-plan table (Anhnt 2026-07-20): Entry/SL live off Bid/Ask, dirty-checked
    // --- per-cell same as everywhere else in this file.
      if(SetValuesToPreTradePlanTable())
        redraw_needed = true;
      if(redraw_needed)
        ::ChartRedraw();
    // --- Sound and message alerts - run every tick to catch all bar 0 changes. CloseBar Sound
    // --- is just "NewBar.wav" via PlaySoundCloseBar now (Anhnt, 2026-08-14) - no more per-flip
    // --- dedup gate shared with CheckIndicatorAlerts/CheckCandlePatternAlerts (those two only
    // --- fire Message/CSV on CloseBar now, see FeatureNote/SoundBugNote.md).
      PlaySoundCloseBar();
      CheckIndicatorAlerts();
      CheckCandlePatternAlerts();
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
            // --- MY DEBUG - verifies the mouse pixel really falls inside the bar we picked.
            // --- Gated on bar_time change so continuous MOUSE_MOVE doesn't spam the log.
            static datetime dbg_last_alt_bar = 0;
            if(bar_time != dbg_last_alt_bar)
             {
              dbg_last_alt_bar = bar_time;
              int bx1 = -1, by1 = -1, bx2 = -1, by2 = -1;
              ::ChartTimePriceToXY(m_chart_id, sub_window, bar_time, price, bx1, by1);
              ::ChartTimePriceToXY(m_chart_id, sub_window, bar_time + ::PeriodSeconds(tf), price, bx2, by2);
              ::Print("MY DEBUG CGUIPannel::OnEvent(Alt-hover): mouse=(", m_mouse.X(), ",", m_mouse.Y(),
                      ") ChartXYToTimePrice.t=", ::TimeToString(t, TIME_DATE|TIME_SECONDS),
                      " bar_time=", ::TimeToString(bar_time, TIME_DATE|TIME_MINUTES),
                      " bar_pixel_x=[", bx1, ",", bx2, "]");
             }
            ShowPatternBitmapAtBar(bar_time);
           }
         }
        else
           HidePatternBitmapShown();
       }
      else
         HidePatternBitmapShown();
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
      SaveGUIConfigToJSON();
      return;
     }
   //Handle m_table_indicator event
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
       && lparam == m_table_indicator_template.Id())
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
      SaveGUIConfigToJSON();
      return;
     }
   //Handle Save marker style/color settings
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.Id())
     {
      // --- Commit current combobox/color selections into m_marker_* BEFORE saving - the
      // --- ON_CLICK_COMBOBOX_ITEM handler above only ever updated the live preview
      // --- (UpdateShapePreview/UpdateColorPreview), never m_marker_* itself, so Save silently
      // --- re-serialized the same old defaults no matter what the user picked
      // --- (BugNote_MarkerMissingDespitePattern.md, 2026-08-15 - Anhnt picked Yellow, Save
      // --- kept writing Lime). Mirrors how the sound-file combos already commit directly.
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

      SaveGUIConfigToJSON();
      // --- Save alone only persists m_marker_* to JSON - the already-running SignalMarkers
      // --- indicator (attached via iCustom) never re-reads input params on its own, so a
      // --- style/color change here had no visible effect until the user manually removed +
      // --- re-added it (BugNote_MarkerMissingDespitePattern.md, 2026-08-15). Recreate it now
      // --- with the just-saved m_marker_* values so Save actually takes effect immediately.
      ReattachSignalMarkersIndicator();
      return;
     }
  //  //Handle "Refresh" next to the sound folder path - re-scans and re-populates both combos
  //   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_refresh_sound_folder.Id())
  //    {
  //     OnClickChangeSoundFolder();
  //     return;
  //    }
   //Handle Save Pattern Config to JSON
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_pattern_config.Id())
     {
      SaveGUIConfigToJSON();
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
   // Handle m_table_CandlePatternsSetting event (Bull/Bear checkbox toggle)
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
      && lparam == m_table_CandlePatternsSetting.Id())
     {
      string parts[];
      if(StringSplit(sparam, '_', parts) != 2) return;
      int col = (int)StringToInteger(parts[0]);
      int row = (int)StringToInteger(parts[1]);
      // col 3 = Sound, col 4 = Message - library already auto-toggled the image before this fires
      // Wire real behavior here (e.g. save to JSON, update Layer 1) when needed
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
   //Handle Symbol TF TreeView Click ON_CLICK_BUTTON
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
#endif // CGUIPANNEL_LIFECYCLE_MQH
