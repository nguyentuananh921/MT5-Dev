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
    if (!CreateWindow_Main("EXPERT PANEL Ver10",1,1))
     {
       Print(__FUNCTION__, " > Failed to create Main Window!");
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
    //Create Main Tab 
     if (!CreateTab_Main(M_CONTROL_BORDER_GAP, M_TABS_MAIN_Y))
      {
        Print(__FUNCTION__, " > Failed to create Tabs1!");
        return (false);
      }
   // Create Setting TimeSeries window implementation in GUIPannel_SettingWindows_TimeSeries.mqh
     if (!CreateWindow_SettingTimeSeries("Setting Time Serries",30,30))
      {
        Print(__FUNCTION__, " > Failed to create Setting Windows!");
        return (false);
      }
     //Create Tab
      if(!CreateTab_SettingTimeSeries(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_YDISTANCE))
       {
        Print(__FUNCTION__, " > Failed to create Setting Time Serries Tab!");
        return (false);
       }
     //For Indicator Setting TreeView on the left panel of setting window
      PopulateTreeView_IndicatorTemplateSetting();
      if(!CreateTreeView_IndicatorTemplateSetting(M_CONTROL_BORDER_GAP, PARAM_FORM_Y)) return false;
      //For Add Indicator form
       if(!CreateAddIndicatorForm(PARAM_FORM_X, PARAM_FORM_Y)) return false;          
       if(!CreateTable_IndicatorTemplateSetting(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;       
     //For Symbol TF setting on Tab Config      
       PopulateTreeView_SymbolTFSetting();
       if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+2)) return false;  //WINDOW_CAPTION_HEIGHT = 22        
       SyncTreeView_SymbolTFSetting();
      //Table m_table_SymbolTFSeting on the right of the Symbol TF sub-tab 
       if(!CreateTable_SymbolTFSetting(M_SYMBOL_WIDTH + 10, WINDOW_CAPTION_HEIGHT)) return false;
       PopulateTable_SymbolTFSetting();
       SyncTable_SymbolTFSetting();
     //For Candle Pattern Setting 
       LoadCandlePatternSetting_FromJSON();
       if(!CreateTable_CandlePatternSetting(0, 0)) return false;
       InitializeTable_CandlePatternSetting();
   // Create Setting Trading window implementation in GUIPannel_SettingWindows_Trading.mqh
    if (!CreateWindow_SettingTrading("Setting Trading",30,30))
     {
       Print(__FUNCTION__, " > Failed to create Setting Trading Windows!");
       return (false);
     }
    //Create Tab
     if(!CreateTab_SettingTrading(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_YDISTANCE))
      {
        Print(__FUNCTION__, " > Failed to create Setting Trading Tab!");
        return (false);
      }
    //For Stop Lost Setting tab - fixed-width table (no AutoXResizeMode), so X gets the same
    //M_CONTROL_BORDER_GAP margin every other fixed-width control in this codebase uses (Anhnt,
    //2026-09-08) - was a bare 0, the one inconsistent case found auditing every Create*(0, ...) call.
     if(!CreateTable_StopLostSetting(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT)) return false;
     if(!CreateStopLostForm(M_CONTROL_BORDER_GAP, m_table_stoplostsetting.Y2() - m_tabs_setting_trading.Y() + M_CONTROL_YDISTANCE)) return false;
    //For Trailing Setting tab (GUIPannel_SettingWindows_TradingTrailing.mqh) - m_table_indicators_trailingsetting
    //sits below m_table_trailingsetting, same Y-offset convention CreateStopLostForm uses below its own table.
     if(!CreateTable_TrailingSetting(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT)) return false;
     if(!CreateTable_IndicatorsTrailingSetting(M_CONTROL_BORDER_GAP, m_table_trailingsetting.Y2() - m_tabs_setting_trading.Y() + M_CONTROL_YDISTANCE)) return false;
     if(!CreateTrailingForm(m_table_indicators_trailingsetting.X2() + M_CONTROL_YDISTANCE, m_table_indicators_trailingsetting.Y() - m_tabs_setting_trading.Y())) return false;
   // For Setting Marker and Sound Window implementation in GUIPannel_SettingWindows_MarkerAndSound.mqh
    if (!CreateWindow_SettingMarkerAndSound("Setting Marker and Sound",30,30))
     {
       Print(__FUNCTION__, " > Failed to create Setting Marker and Sound Windows!");
       return (false);
     }
    //Create Tab
     if(!CreateTab_SettingMarkerAndSound(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_YDISTANCE))
      {
        Print(__FUNCTION__, " > Failed to create Setting Marker and Sound Tab!");
        return (false);
      }
    //For Marker Setting
     LoadMarkerSettingsFromJSON();
     if(!CreateTab_SettingConfig_Marker(0, WINDOW_CAPTION_HEIGHT)) return false;
    // For Sound Setting
     if(!CreateTab_SettingConfig_Sound(0, WINDOW_CAPTION_HEIGHT)) return false;
   // Create m_window_candle_infomation Information window at to display signal on chart
    if (!CreateWindow_CandleInfo())
     {
       Print(__FUNCTION__, " > Failed to create candle info popup!");
       return (false);
     }
   //---------------------
     //Create m_table_indicator_SymbolTFValue control at TAB_TAB_MAIN_TRADE m_tabs_main
      if(!CreateTable_IndicatorSymbolTFMonitor(0, 0)) return false;       
   //For m_table_indicator_PreTradeSymbolMonitor (TAB_TAB_MAIN_TRADING) - left of the New Order
   //form, scoped to m_combobox_symbol_toTrade's current selection (Anhnt/Claude, 2026-09-08).
     if(!CreateTable_PreTradeSymbolMonitor(M_CONTROL_BORDER_GAP, M_CONTROL_BORDER_GAP)) return false;
   //For New Order form - starts right after m_table_indicator_PreTradeSymbolMonitor's own right edge
   //(Anhnt/Claude, 2026-09-08 - read off X2() directly, not a hand-computed width formula that goes
   //stale whenever the table's own columns change).
     if(!CreateTradingForm(m_table_indicator_PreTradeSymbolMonitor.X2() + M_CONTROL_BORDER_GAP, M_CONTROL_BORDER_GAP)) return false;
   //For m_table_positions_StoplostAndTrailling (TAB_TAB_MAIN_TRADING) - implementation in
   //GUIPannel_NewFeatures.mqh - fixed-width table (no AutoXResizeMode), M_CONTROL_BORDER_GAP margin
   //same as StopLost/Trailing above (Anhnt, 2026-09-08). Y starts right below the New Order form/
   //Monitor table (both TRADING_FORM_HEIGHT tall) instead of the old fixed POSITIONS_TABLE_Y, which
   //the form now overlaps since it grew to 9 rows (Trailing/Risk% controls added).
     if(!CreateTable_PositionsStoplostAndTrailling(M_CONTROL_BORDER_GAP, M_CONTROL_BORDER_GAP + TRADING_FORM_HEIGHT + M_CONTROL_BORDER_GAP))
      {
       Print(__FUNCTION__, " > Failed to create Positions StopLost/Trailing table!");
       return (false);
      }
     m_window_candle_infomation.Hide();
    //Finalize GUI Creation
     CWndEvents::CompletedGUI();
     HideAddIndicatorForm();
     HideStopLostForm();
     m_btn_save_indicator.Hide();
     CWndEvents::ShowTabElements(WindowIdx(m_window_main));
    //  m_trading_bubble.MousePointer(m_mouse);
    //  m_trading_bubble.SetChartObjCollection(GetPointer(m_chart_obj_collection));
     return true;
  }
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
    // CSignalLogger now reads g_ea_folder directly (no own folder property) - only the
    // once-per-init load guard is still needed here.
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
      // m_trading_bubble.OnDeinitEvent();   // Trading Bubble disabled (Anhnt, 2026-09-04) - see EA.mq5 SetTradingControl comment
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
   //--- Deferred delete and sync
    if(m_pending_remove_row >= 0)
     {
       int remove_row = m_pending_remove_row;
       m_pending_remove_row = -1;
       if(m_indicator_template_manager != NULL && remove_row < (int)m_table_indicator_template.RowsTotal())
         OnClickRemoveIndicator(remove_row);
     }   
    if(m_pending_remove_sym_symboltf != "")
     {
      string remove_sym = m_pending_remove_sym_symboltf;
      string remove_tf  = m_pending_remove_tf_symboltf;
      m_pending_remove_sym_symboltf = "";
      m_pending_remove_tf_symboltf  = "";
      if(m_SymbolTFManager != NULL)
         m_SymbolTFManager.Delete_SymbolTFSetting(remove_sym, TimestampByDescription(remove_tf));
     }   
    if(m_treeview_symboltf_need_sync && m_active_window_index == WindowIdx(m_window_setting_timeseries) &&
      m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF)
     {
      m_treeview_symboltf_need_sync = false;
      PopulateTable_SymbolTFSetting();
      PopulateTreeView_SymbolTFSetting();
      SyncTreeView_SymbolTFSetting();
      SyncTable_SymbolTFSetting();   // same flag - Table needs the same self-healing resync
     }   
    if(m_treeview_indicator_need_sync && m_active_window_index == WindowIdx(m_window_setting_timeseries) &&
      m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
     {
      m_treeview_indicator_need_sync = false;
      SyncTreeView_IndicatorTemplateSetting();
     }   
    if(m_table_indicator_need_sync && m_active_window_index == WindowIdx(m_window_setting_timeseries) &&
      m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
     {
      m_table_indicator_need_sync = false;
      InitializeTable_IndicatorTemplateSetting();
     }   
   // Update data for the Indicator and Symbol/TF Table on the Monitor tab - was running
   // unconditionally every 16ms (this timer's own period) regardless of which window/tab was
   // actually being viewed, unlike every other Sync call in this function - gated now to match
   // (Anhnt, 2026-09-07). This is the heaviest table (every tracked Symbol x TF x Indicator), so
   // this was very likely a real, ongoing source of the reported lag.
    if(m_active_window_index == WindowIdx(m_window_main) && m_tabs_main.SelectedTab() == TAB_TAB_MAIN_MONITOR)
       SynTable_IndicatorSymbolTFMonitor();
   // Handling the elements
    CWndEvents::OnTimerEvent();   
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
   //--- StopLost/Trailing Apply engine now runs inside CTradingEngine::OnTickEvent (Anhnt/Claude,
   //--- 2026-09-09, moved out of the GUI layer) - no explicit call needed here.
   // Update data for the Symbol/SL/TP/Level Table on the Settings tab
    if(m_active_window_index == WindowIdx(m_window_setting_trading)
       && m_tabs_setting_trading.SelectedTab() == ENUM_TAB_SETTING_TRADING_STOPLOST
       && SyncTable_StopLostSetting())
      redraw_needed = true;
   // Update data for the Symbol/Trailing Table on the Settings tab - same gating, Trailling tab
    if(m_active_window_index == WindowIdx(m_window_setting_trading)
       && m_tabs_setting_trading.SelectedTab() == ENUM_TAB_SETTING_TRADING_TRAILLING
       && SyncTable_TrailingSetting())
      redraw_needed = true;
   // Update Col2 (Value) on m_table_indicators_trailingsetting - only once a Symbol has actually
   // been scoped (Trailling-icon clicked at least once); read back off the label the same way the
   // click handler and checkbox handler both do, no separate "current symbol" cache Property.
    if(m_active_window_index == WindowIdx(m_window_setting_trading)
       && m_tabs_setting_trading.SelectedTab() == ENUM_TAB_SETTING_TRADING_TRAILLING)
     {
      string trail_label = m_label_TrailingSetting_Symbol.LabelText();
      int    trail_sep    = StringFind(trail_label, " - ");
      string trail_symbol = (trail_sep >= 0) ? StringSubstr(trail_label, trail_sep + 3) : "";
      if(trail_symbol != "" && trail_symbol != "-" && SyncTable_IndicatorsTrailingSetting(trail_symbol))
         redraw_needed = true;
     }
   // Update data for m_table_positions_StoplostAndTrailling on the Positions tab
    if(m_active_window_index == WindowIdx(m_window_main)
       && m_tabs_main.SelectedTab() == TAB_TAB_MAIN_TRADING
       && SyncTable_PositionsStoplostAndTrailling())
      redraw_needed = true;
   // Update Col0(active-chart-TF)/Col2(Value) on m_table_indicator_PreTradeSymbolMonitor - scoped to
   // m_combobox_symbol_toTrade's current selection (Anhnt/Claude, 2026-09-08), same "read back off
   // the control that already displays it" convention as m_table_indicators_trailingsetting above.
    if(m_active_window_index == WindowIdx(m_window_main)
       && m_tabs_main.SelectedTab() == TAB_TAB_MAIN_TRADING)
     {
      string toTrade_symbol = m_combobox_symbol_toTrade.GetValue();
      if(toTrade_symbol != "" && SyncTable_PreTradeSymbolMonitor(toTrade_symbol))
         redraw_needed = true;
     }
   // Redraw the chart if any of the above updates required it
    if(redraw_needed)
           ::ChartRedraw(); 
      
  }
 //+------------------------------------------------------------------+
 //| Trade operation event                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTradeEvent(void)
  {
      //--- m_table_positions_StoplostAndTrailling already refreshes itself every Tick via
      //--- SyncTable_PositionsStoplostAndTrailling (this file's own OnTickEvent) - no explicit
      //--- refresh call needed here.
      if(m_tradingEngine != NULL) m_tradingEngine.IsLastDealTicket();   // consumes the HistorySelect watermark so the next real check works
  }
 //+------------------------------------------------------------------+
 //| OnEvent handler                                                  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
  {   
    OnEvent_Window_Main(id, lparam, dparam, sparam);
    OnEvent_Window_SettingTimeSeries(id, lparam, dparam, sparam);
    OnEvent_Window_SettingTrading(id, lparam, dparam, sparam);
    OnEvent_Window_SettingMarkerAndSound(id, lparam, dparam, sparam);
    OnEvent_Window_CandleInfor(id, lparam, dparam, sparam);
    if(id == CHARTEVENT_CHART_CHANGE && m_active_window_index != WindowIdx(m_window_main))
     {
      CWndEvents::Show(m_active_window_index);
     }
   // ESC always force-hides whichever Setting window is currently active
    if(id == CHARTEVENT_KEYDOWN && lparam == 27) // VK_ESCAPE
     {
      if(m_active_window_index == WindowIdx(m_window_setting_timeseries))
         CloseWindow_SettingTimeSeries();
      else if(m_active_window_index == WindowIdx(m_window_setting_trading))
         CloseWindow_SettingTrading();
      else if(m_active_window_index == WindowIdx(m_window_setting_markerAndSound))
         CloseWindow_SettingMarkerAndSound();
      return;
     }
   //Handle m_combobox_direction/m_combobox_order_type (Anhnt, 2026-09-03) - CComboBox fires
   //ON_CHANGE_GUI (ComboBox.mqh::OnClickListItem(), lparam=the combobox's own Id()) whenever the
   //selection changes - refresh m_btn_send_toTrade's text/color from whichever one just changed.
     if(id == CHARTEVENT_CUSTOM + ON_CHANGE_GUI
        && (lparam == m_combobox_direction.Id() || lparam == m_combobox_order_type.Id()))
      {
       UpdateSendButtonAppearance();
       return;
      }
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main.Id())
      {
        HidePatternBitmapAtBar();
        HideWindow_CandleInfo();
        m_candle_info_shown_bar = 0;
        return;
      }    
    // Handle Save Pattern Config to JSON
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_pattern_config.Id())
       {
        SaveCandlePatternSettingToJSON();
        return;
       }
    // Handle Save Symbol/TF config to JSON - CSymbolTFManager owns FileOpen/write now
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_SymbolTF.Id())
      {
        if(m_SymbolTFManager != NULL) m_SymbolTFManager.SaveSymbolTFSettingToJSON();
        return;
      } 
    // Handle Save Indicator config to JSON - CIndicatorTemplateManager owns FileOpen/write now
       if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_indicator.Id())
        {
         if(m_indicator_template_manager != NULL) m_indicator_template_manager.SaveIndicatorTemplateToJSON();
         // Saved - clear the pending-change indicator (Anhnt, 2026-09-01).
         m_btn_save_indicator.Hide();
         return;
        }    
    // m_trading_bubble.OnChartEvent(id, lparam, dparam, sparam);   // Trading Bubble disabled (Anhnt, 2026-09-04) - lazy-init on the first Position opened crashed with "invalid pointer access" in Element.mqh:614; multi-position-same-direction SL/TP/Trailing interaction was already an open, paused question before this
  }
 //+------------------------------------------------------------------+
 //| Update GUI                                                       |
 //+------------------------------------------------------------------+ 
 void CGUIPannel::UpdateGUI(const bool redraw)
  {      
   m_treeview_indicator_need_sync = true;
   m_table_indicator_need_sync = true;
   if(redraw) m_chart.Redraw();
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
