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
     if (!CreateTab_Main(M_TABS_MAIN_X, M_TABS_MAIN_Y))
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
      if(!CreateTreeView_IndicatorTemplateSetting(TABS_CONFIG_X_GAP, PARAM_FORM_Y)) return false;
      //For Add Indicator form
       if(!CreateAddIndicatorForm(PARAM_FORM_X, PARAM_FORM_Y)) return false;          
       if(!CreateTable_IndicatorTemplateSetting(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;       
     //For Symbol TF setting on Tab Config      
       PopulateTreeView_SymbolTFSetting();
       if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+2)) return false;  //WINDOW_CAPTION_HEIGHT = 22        
       SyncTreeView_SymbolTFSetting();
      //Table m_table_SymbolTFSeting on the right of the Symbol TF sub-tab 
       if(!CreateTable_SymbolTFSetting(M_TREEVIEW_SYMBOLTF_WIDTH + 10, WINDOW_CAPTION_HEIGHT)) return false;
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
    //For Stop Lost Setting tab
     if(!CreateTable_StopLostSetting(0, WINDOW_CAPTION_HEIGHT)) return false;
     if(!CreateStopLostForm(0, m_table_stoplostsetting.Y2() - m_tabs_setting_trading.Y() + M_CONTROL_YDISTANCE)) return false;
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
   //For New Order form
     if(!CreateTradingForm(M_CONTROL_BORDER_GAP, M_CONTROL_BORDER_GAP)) return false;
     m_window_candle_infomation.Hide();
    //Finalize GUI Creation
     CWndEvents::CompletedGUI();
     HideAddIndicatorForm();
     HideStopLostForm();
     m_btn_save_indicator.Hide();
     //if(!CreateTablePositions(0, POSITIONS_TABLE_Y)) return false;    
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
   // Update data for the Indicator and Symbol/TF Table on the Settings tab
    SetValuesToTable_IndicatorSymbolTFMonitor();
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
   // Update data for the Symbol/SL/TP/Level Table on the Settings tab
    if(m_active_window_index == WindowIdx(m_window_setting_trading)
       && m_tabs_setting_trading.SelectedTab() == ENUM_TAB_SETTING_TRADING_STOPLOST
       && SyncTable_StopLostSetting())
      redraw_needed = true;
   // Redraw the chart if any of the above updates required it
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
 //| OnEvent handler                                                  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
  {   
    OnEvent_Window_Main(id, lparam, dparam, sparam);
    OnEvent_Window_SettingTimeSeries(id, lparam, dparam, sparam);
    OnEvent_Window_SettingTrading(id, lparam, dparam, sparam);
    OnEvent_Window_SettingMarkerAndSound(id, lparam, dparam, sparam);
   ulong __dbg_t_entry = (id == CHARTEVENT_MOUSE_MOVE) ? ::GetMicrosecondCount() : 0;
    OnEvent_Window_CandleInfor(id, lparam, dparam, sparam);
  //--- MY DEBUG (temp, Anhnt 2026-09-03)
   if(id == CHARTEVENT_MOUSE_MOVE)
    {
     ulong dt = ::GetMicrosecondCount() - __dbg_t_entry;
     if(dt > 500)
        CMessage::ToFile(g_ea_folder, "CGUIPannel", "OnEvent",
            "MY DEBUG PERF OnEvent_Window_CandleInfor took " + (string)dt + "us");
    }
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
   //--- Debug: press D to dump every chart object that's NEW since the last press
    if(id == CHARTEVENT_KEYDOWN && lparam == 68) // 'D'
     {
      int total = (int)::ObjectsTotal(0);
      string current[];
      ::ArrayResize(current, total);
      for(int i = 0; i < total; i++)
         current[i] = ::ObjectName(0, i);
      int new_count = 0;
      for(int i = 0; i < total; i++)
       {
        bool was_there = false;
        for(int j = 0; j < ::ArraySize(m_debug_object_snapshot); j++)
           if(m_debug_object_snapshot[j] == current[i]) { was_there = true; break; }
        if(was_there) continue;
        new_count++;
        string name = current[i];
        CMessage::ToFile(g_ea_folder, "CGUIPannel", "OnEvent",
            "MY DEBUG PRESS-D NEW OBJECT: name=" + name +
            " x=" + (string)::ObjectGetInteger(0, name, OBJPROP_XDISTANCE) +
            " y=" + (string)::ObjectGetInteger(0, name, OBJPROP_YDISTANCE) +
            " xsize=" + (string)::ObjectGetInteger(0, name, OBJPROP_XSIZE) +
            " ysize=" + (string)::ObjectGetInteger(0, name, OBJPROP_YSIZE) +
            " corner=" + (string)::ObjectGetInteger(0, name, OBJPROP_CORNER) +
            " timeframes=" + (string)::ObjectGetInteger(0, name, OBJPROP_TIMEFRAMES) +
            " zorder=" + (string)::ObjectGetInteger(0, name, OBJPROP_ZORDER) +
            " type=" + (string)::ObjectGetInteger(0, name, OBJPROP_TYPE) +
            " hidden=" + (string)::ObjectGetInteger(0, name, OBJPROP_HIDDEN));
       }
      CMessage::ToFile(g_ea_folder, "CGUIPannel", "OnEvent",
          "MY DEBUG PRESS-D total_objects=" + (string)total + " new_since_last=" + (string)new_count);
     //--- Also always dump the SPECIFIC "Settings" menu/dropdown objects by name (not gated by "new" -
     //--- these exist from OnInit onward, so they'd never show up in the diff above) - this is the
     //--- part that actually matters for the invisible-Settings-text / unclickable-sub-item bug.
      string watch[5];
      watch[0] = m_menu_bar.GetItemPointer(MENU_ITEM_SETTINGS).CanvasPointer().ChartObjectName();
      watch[1] = m_contextmenu_settings.CanvasPointer().ChartObjectName();
      watch[2] = m_contextmenu_settings.GetItemPointer(0).CanvasPointer().ChartObjectName();
      watch[3] = m_contextmenu_settings.GetItemPointer(1).CanvasPointer().ChartObjectName();
      watch[4] = m_contextmenu_settings.GetItemPointer(2).CanvasPointer().ChartObjectName();
      for(int w = 0; w < 5; w++)
       {
        string name = watch[w];
        bool exists = (::ObjectFind(0, name) >= 0);
        CMessage::ToFile(g_ea_folder, "CGUIPannel", "OnEvent",
            "MY DEBUG PRESS-D WATCH: name=" + name + " exists=" + (string)exists +
            " x=" + (string)::ObjectGetInteger(0, name, OBJPROP_XDISTANCE) +
            " y=" + (string)::ObjectGetInteger(0, name, OBJPROP_YDISTANCE) +
            " xsize=" + (string)::ObjectGetInteger(0, name, OBJPROP_XSIZE) +
            " ysize=" + (string)::ObjectGetInteger(0, name, OBJPROP_YSIZE) +
            " corner=" + (string)::ObjectGetInteger(0, name, OBJPROP_CORNER) +
            " timeframes=" + (string)::ObjectGetInteger(0, name, OBJPROP_TIMEFRAMES) +
            " zorder=" + (string)::ObjectGetInteger(0, name, OBJPROP_ZORDER) +
            " hidden=" + (string)::ObjectGetInteger(0, name, OBJPROP_HIDDEN) +
            " back=" + (string)::ObjectGetInteger(0, name, OBJPROP_BACK));
       }
      ::ArrayResize(m_debug_object_snapshot, total);
      for(int i = 0; i < total; i++)
         m_debug_object_snapshot[i] = current[i];
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

    
    //--- MY DEBUG (temp, Anhnt 2026-09-03) - time reached the bottom of the if-chain vs. the
    //--- trading_bubble call itself, both only for MOUSE_MOVE (see __dbg_t_entry at the top).
     ulong __dbg_t_before_bubble = (id == CHARTEVENT_MOUSE_MOVE) ? ::GetMicrosecondCount() : 0;
     if(id == CHARTEVENT_MOUSE_MOVE)
      {
       ulong dt = __dbg_t_before_bubble - __dbg_t_entry;
       if(dt > 500)
          CMessage::ToFile(g_ea_folder, "CGUIPannel", "OnEvent",
              "MY DEBUG PERF if-chain (entry->before trading_bubble) took " + (string)dt + "us");
      }
      // m_trading_bubble.OnChartEvent(id, lparam, dparam, sparam);   // Trading Bubble disabled (Anhnt, 2026-09-04) - lazy-init on the first Position opened crashed with "invalid pointer access" in Element.mqh:614; multi-position-same-direction SL/TP/Trailing interaction was already an open, paused question before this
     if(id == CHARTEVENT_MOUSE_MOVE)
      {
       ulong dt = ::GetMicrosecondCount() - __dbg_t_before_bubble;
       if(dt > 500)
          CMessage::ToFile(g_ea_folder, "CGUIPannel", "OnEvent",
              "MY DEBUG PERF m_trading_bubble.OnChartEvent took " + (string)dt + "us");
      }

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
