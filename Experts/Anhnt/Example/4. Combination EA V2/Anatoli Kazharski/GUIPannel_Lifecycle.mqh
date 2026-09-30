//+------------------------------------------------------------------+
//|                                          GUIPannel_Lifecycle.mqh |
//|Implementation of Init, Deinit and other lifecycle events         |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_LIFECYCLE_MQH
#define CGUIPANNEL_LIFECYCLE_MQH
#include "GUIPannel.mqh"
//Private Method
 //Get window index
 //int CGUIPannel::WindowIdx(CWindow &wnd)
 // {
 //  for(int i = 0; i < WindowsTotal(); i++)
 //   {
 //    if(m_windows[i] == GetPointer(wnd))
 //     return i;
 //   }
 //    return 0;
 // }
 //For GUIPannel
 bool CGUIPannel::CreateGUIPannel(void)
  {
   //--- Every window is hidden BEFORE Create: born hidden, children inherit it, m_window_main shown once at the end
    m_window_main.Hide();
    m_window_setting_timeseries.Hide();
    m_window_setting_trading.Hide();
    m_window_setting_markerAndSound.Hide();
    m_window_candle_infomation.Hide();
   // Create Main Frame window implementation in GUIPannel_MainWindows.mqh
    if (!CreateWindow_Main("EXPERT PANEL Ver2",1,1))
     {
       Print(__FUNCTION__, " > Failed to create Main Window!");
       return (false);
     }
     //m_window_main.Hide();
    //Create Status Bar at the bottom of m_window_main
     if (!CreateStatusBar(1, M_WINDOW_MAIN_HEIGHT - 23))
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
     //m_window_setting_timeseries.Hide();
     if(!CreateTab_SettingTimeSeries(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__, " > Failed to create Setting Time Serries Tab!");
       return (false);
      }
    //Tab children y is measured from the content area, below the tab header
     if(!CreateTreeView_IndicatorTemplateSetting(M_CONTROL_BORDER_GAP, PARAM_FORM_Y)) return false;
     PopulateTreeView_IndicatorTemplateSetting();
     SyncTreeView_IndicatorTemplateSetting();
     if(!CreateAddIndicatorForm(PARAM_FORM_X, PARAM_FORM_Y)) return false;
     if(!CreateTable_IndicatorTemplateSetting(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;
     InitializeTable_IndicatorTemplateSetting();
     if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP, PARAM_FORM_Y)) return false;
     PopulateTreeView_SymbolTFSetting();
     SyncTreeView_SymbolTFSetting();
     if(!CreateTable_SymbolTFSetting(M_SYMBOL_WIDTH + 10, 0)) return false;
     PopulateTable_SymbolTFSetting();
     LoadCandlePatternSetting_FromJSON();
     if(!CreateTable_CandlePatternSetting(0, 0)) return false;
     InitializeTable_CandlePatternSetting();
     if(!CreateTable_SwingSetting(0, 0)) return false;
     InitializeTable_SwingSetting();
     //m_window_setting_timeseries.Hide();
   //  if (!CreateWindow_SettingTimeSeries("Setting Time Serries",30,30))
   //   {
   //     Print(__FUNCTION__, " > Failed to create Setting Windows!");
   //     return (false);
   //   }
   //  //Create Tab
   //   if(!CreateTab_SettingTimeSeries(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_YDISTANCE))
   //    {
   //     Print(__FUNCTION__, " > Failed to create Setting Time Serries Tab!");
   //     return (false);
   //    }
   //  //For Indicator Setting TreeView on the left panel of setting window
   //   PopulateTreeView_IndicatorTemplateSetting();
   //   if(!CreateTreeView_IndicatorTemplateSetting(M_CONTROL_BORDER_GAP, PARAM_FORM_Y)) return false;
   //   //For Add Indicator form
   //    if(!CreateAddIndicatorForm(PARAM_FORM_X, PARAM_FORM_Y)) return false;
   //    if(!CreateTable_IndicatorTemplateSetting(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;
   //  //For Symbol TF setting on Tab Config
   //    PopulateTreeView_SymbolTFSetting();
   //    if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+2)) return false;  //WINDOW_CAPTION_HEIGHT = 22
   //    SyncTreeView_SymbolTFSetting();
   //   //Table m_table_SymbolTFSeting on the right of the Symbol TF sub-tab
   //    if(!CreateTable_SymbolTFSetting(M_SYMBOL_WIDTH + 10, WINDOW_CAPTION_HEIGHT)) return false;
   //    PopulateTable_SymbolTFSetting();
   //    SyncTable_SymbolTFSetting();
   //  //For Candle Pattern Setting
   //    LoadCandlePatternSetting_FromJSON();
   //    if(!CreateTable_CandlePatternSetting(0, 0)) return false;
   //    InitializeTable_CandlePatternSetting();
   //  //For Swing Setting - m_SwingSetting already loaded from JSON by CTimeSeriesEngine::OnInitEvent
   //    if(!CreateTable_SwingSetting(0, 0)) return false;
   //    InitializeTable_SwingSetting();
   // Create Setting Trading window implementation in GUIPannel_SettingWindows_Trading.mqh
     if (!CreateWindow_SettingTrading("Setting Trading",30,30))
      {
        Print(__FUNCTION__, " > Failed to create Setting Trading Windows!");
        return (false);
      }
     //m_window_setting_trading.Hide();
     if(!CreateTab_SettingTrading(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__, " > Failed to create Setting Trading Tab!");
       return (false);
      }
     if(!CreateTable_StopLostSetting(M_CONTROL_BORDER_GAP, 0)) return false;
     if(!CreateStopLostForm(M_CONTROL_BORDER_GAP, SETTING_TRADING_TABLE_HEIGHT + M_CONTROL_BORDER_GAP)) return false;
     if(!CreateTable_TrailingSetting(M_CONTROL_BORDER_GAP, 0)) return false;
     if(!CreateTable_IndicatorsTrailingSetting(M_CONTROL_BORDER_GAP, SETTING_TRADING_TABLE_HEIGHT + M_CONTROL_BORDER_GAP)) return false;
     if(!CreateTrailingForm(M_CONTROL_BORDER_GAP + m_table_indicators_trailingsetting.Width() + TRAIL_FORM_GAP,
                            SETTING_TRADING_TABLE_HEIGHT + M_CONTROL_BORDER_GAP + M_CONTROL_YDISTANCE)) return false;
   // Create Setting Alert window (Marker / Sound) implementation in GUIPannel_SettingWindows_Alert.mqh
     if (!CreateWindow_SettingMarkerAndSound("Setting Marker and Sound",30,30))
      {
        Print(__FUNCTION__, " > Failed to create Setting Marker and Sound Windows!");
        return (false);
      }
     if(!CreateTab_SettingMarkerAndSound(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__, " > Failed to create Setting Marker and Sound Tab!");
       return (false);
      }
     if(!CreateTab_SettingConfig_Marker(0, M_CONTROL_BORDER_GAP + 5)) return false;
     if(!CreateTab_SettingConfig_Sound(0, M_CONTROL_BORDER_GAP + 5)) return false;
   // Create Candle Info popup implementation in GUIPannel_CandleInfo_Windows.mqh
     if(!CreateWindow_CandleInfo())
      {
       Print(__FUNCTION__, " > Failed to create candle info popup!");
       return (false);
      }
   //// Create Setting Trading window implementation in GUIPannel_SettingWindows_Trading.mqh
   // if (!CreateWindow_SettingTrading("Setting Trading",30,30))
   //  {
   //    Print(__FUNCTION__, " > Failed to create Setting Trading Windows!");
   //    return (false);
   //  }
   // //Create Tab
   //  if(!CreateTab_SettingTrading(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_YDISTANCE))
   //   {
   //     Print(__FUNCTION__, " > Failed to create Setting Trading Tab!");
   //     return (false);
   //   }
   //  if(!CreateTable_StopLostSetting(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT)) return false;
   //  if(!CreateStopLostForm(M_CONTROL_BORDER_GAP, m_table_stoplostsetting.Y2() - m_tabs_setting_trading.Y() + M_CONTROL_YDISTANCE)) return false;
   //  if(!CreateTable_TrailingSetting(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT)) return false;
   //  if(!CreateTable_IndicatorsTrailingSetting(M_CONTROL_BORDER_GAP, m_table_trailingsetting.Y2() - m_tabs_setting_trading.Y() + M_CONTROL_YDISTANCE)) return false;
   //  if(!CreateTrailingForm(m_table_indicators_trailingsetting.X2() + M_CONTROL_YDISTANCE, m_table_indicators_trailingsetting.Y() - m_tabs_setting_trading.Y())) return false;
   //// For Setting Marker and Sound Window implementation in GUIPannel_SettingWindows_MarkerAndSound.mqh
   // if (!CreateWindow_SettingMarkerAndSound("Setting Marker and Sound",30,30))
   //  {
   //    Print(__FUNCTION__, " > Failed to create Setting Marker and Sound Windows!");
   //    return (false);
   //  }
   // //Create Tab
   //  if(!CreateTab_SettingMarkerAndSound(M_CONTROL_BORDER_GAP, WINDOW_CAPTION_HEIGHT + M_CONTROL_YDISTANCE))
   //   {
   //     Print(__FUNCTION__, " > Failed to create Setting Marker and Sound Tab!");
   //     return (false);
   //   }
   // //For Marker Setting
   //  LoadMarkerSettingsFromJSON();
   //  if(!CreateTab_SettingConfig_Marker(0, WINDOW_CAPTION_HEIGHT)) return false;
   // // For Sound Setting
   //  if(!CreateTab_SettingConfig_Sound(0, WINDOW_CAPTION_HEIGHT)) return false;
   //---------------------
     int trading_top = M_CONTROL_BORDER_GAP + 3;
     if(!CreateTFSwitchButtons(M_CONTROL_BORDER_GAP, trading_top)) return false;
     if(!CreateTable_PreTradeSymbolMonitor(M_CONTROL_BORDER_GAP, trading_top + TF_SWITCH_ROW_HEIGHT)) return false;
     if(!CreateTradingForm(M_CONTROL_BORDER_GAP + m_table_indicator_PreTradeSymbolMonitor.Width() + M_CONTROL_BORDER_GAP, trading_top + TF_SWITCH_ROW_HEIGHT)) return false;
     if(!CreateTable_PositionPretradeView(M_CONTROL_BORDER_GAP, trading_top + TF_SWITCH_ROW_HEIGHT + TRADING_FORM_HEIGHT + M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__, " > Failed to create Position Pretrade View table!");
       return (false);
      }
     OnSymbolToTradeChanged();
     SyncTFSwitchButtons();
     if(!CreateTable_PositionsStoplostAndTrailling(M_CONTROL_BORDER_GAP, trading_top + TF_SWITCH_ROW_HEIGHT + TRADING_FORM_HEIGHT + M_CONTROL_HEIGHT + PRETRADE_VIEW_TABLE_HEIGHT + M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__, " > Failed to create Positions StopLost/Trailing table!");
       return (false);
      }
    //Finalize GUI Creation
    // CWndEvents::CompletedGUI();
    // HideAddIndicatorForm();
    // HideStopLostForm();
    // m_btn_save_indicator.Hide();
    // CWndEvents::ShowTabElements(WindowIdx(m_window_main));
    //--- Default to the Trading tab
     m_tabs_main.SelectTab(TAB_TAB_MAIN_TRADING);
    //--- One Show for the whole panel; CTabs::Show keeps only the selected tab, then re-hide the per-mode ones
     m_window_main.Show();
     UpdateSendButtonAppearance();
     if(m_checkbox_use_RiskPerNewTrade.State()) m_edit_RiskPerNewTrade.Show(); else m_edit_RiskPerNewTrade.Hide();
     ::ChartRedraw(m_chart_id);
     return true;
  }
 //| Constructor/Destructor                                          |
 CGUIPannel::CGUIPannel(void) : m_symbol_collection(NULL),m_market_collection(NULL),m_accounts_collection(NULL),
                                m_BarTimeSeriesCollection(NULL),m_IndicatorsCollection(NULL),m_SignalsCollection(NULL),
                                m_tradingEngine(NULL),m_trading_control(NULL),m_indicator_template_manager(NULL),
                                m_SymbolTFManager(NULL),m_BarPatterns_Control(NULL),m_SwingSetting(NULL),
                                m_trading_setup_manager(NULL),m_chart_obj_collection(NULL),m_graph_elements(NULL),
                                m_candle_info_shown_bar(0),m_pattern_bitmap(NULL),m_tooltip_candle_info(NULL),m_chart_id(::ChartID()),m_subwin(0)
  {
   //--- Setting parameters for the time counters
    m_gui_timecounter.SetParameters(16, 500);
    m_pending_remove_row     = -1;
    m_pending_remove_sym_symboltf = "";
    m_pending_remove_tf_symboltf  = "";
    //m_treeview_symboltf_need_sync = false;
    //m_treeview_indicator_need_sync = false;
    //m_table_indicator_need_sync = false;
    m_indicator_save_pending = false;
    m_current_param_type = IND_CUSTOM;
    m_gui_created     = false;
    m_signal_log_watermarks_loaded = false;
    m_new_order_is_buy   = true;
    m_new_order_lot_last = 0.0;
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
      //--- The New Order combobox mirrors the chart Symbol (tree click / combobox both move the chart)
      m_table_position_pretrade_view.SetValue(COL_PTV_SYMBOL, 0, ::Symbol());
      OnSymbolToTradeChanged(false);
      SyncTFSwitchButtons();          // chart Symbol may have changed
      SyncTreeView_SymbolTFSetting(); // chart pair moved: the start-icon row and the active Symbol node follow it
      SyncTable_SymbolTFSetting();
      UpdateGUI(false);
    }
   //--- Re-register every init: CreateCollection() rebuilds the chart objects
   // if(m_chart_obj_collection != NULL)
   //  {
   //    CChartObj *chart = m_chart_obj_collection.GetChart(m_chart_id);
   //    if(chart != NULL)
   //     {
   //      chart.AddTopElement(GetPointer(m_window_main));
   //      chart.AddTopElement(GetPointer(m_window_setting_timeseries));
   //      chart.AddTopElement(GetPointer(m_window_setting_trading));
   //      chart.AddTopElement(GetPointer(m_window_setting_markerAndSound));
   //     }
   //  }
   //--- Registration order = stacking order: main at the bottom of the panel, dialogs above it
   if(m_graph_elements != NULL)
    {
      m_graph_elements.RegisterElement(GetPointer(m_window_main));
      m_graph_elements.RegisterElement(GetPointer(m_window_setting_timeseries));
      m_graph_elements.RegisterElement(GetPointer(m_window_setting_trading));
      m_graph_elements.RegisterElement(GetPointer(m_window_setting_markerAndSound));
      m_graph_elements.RegisterElement(GetPointer(m_window_candle_infomation));
    }
   //--- Box/tooltip after the windows: the tooltip stacks above them
   if(!CreatePatternHoverElements())
      Print(__FUNCTION__, " > Failed to create the pattern hover box/tooltip");
   return true;
  };
 //+------------------------------------------------------------------+
 //| Deinit                                                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnDeinitEvent(const int reason)
  {
    //--- Symbol/TF change too: the box and the popup belong to the old bars
    HidePatternBitmapAtBar();
    HideWindow_CandleInfo();
    if(reason != REASON_CHARTCHANGE)
     {
     // CWndEvents::Destroy();
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
   // if(m_pending_remove_row >= 0)
   //  {
   //    int remove_row = m_pending_remove_row;
   //    m_pending_remove_row = -1;
   //    if(m_indicator_template_manager != NULL && remove_row < (int)m_table_indicator_template.RowsTotal())
   //      OnClickRemoveIndicator(remove_row);
   //  }
   // if(m_pending_remove_sym_symboltf != "")
   //  {
   //   string remove_sym = m_pending_remove_sym_symboltf;
   //   string remove_tf  = m_pending_remove_tf_symboltf;
   //   m_pending_remove_sym_symboltf = "";
   //   m_pending_remove_tf_symboltf  = "";
   //   if(m_SymbolTFManager != NULL)
   //      m_SymbolTFManager.Delete_SymbolTFSetting(remove_sym, TimestampByDescription(remove_tf));
   //  }
   // if(m_treeview_symboltf_need_sync && m_active_window_index == WindowIdx(m_window_setting_timeseries) &&
   //   m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF)
   //  {
   //   m_treeview_symboltf_need_sync = false;
   //   PopulateTable_SymbolTFSetting();
   //   PopulateTreeView_SymbolTFSetting();
   //   SyncTreeView_SymbolTFSetting();
   //   SyncTable_SymbolTFSetting();
   //  }
   // if(m_treeview_indicator_need_sync && m_active_window_index == WindowIdx(m_window_setting_timeseries) &&
   //   m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
   //  {
   //   m_treeview_indicator_need_sync = false;
   //   SyncTreeView_IndicatorTemplateSetting();
   //  }
   // if(m_table_indicator_need_sync && m_active_window_index == WindowIdx(m_window_setting_timeseries) &&
   //   m_tabs_setting_timeseries.SelectedTab() == TAB_TAB_SETTING_TIMESERIES_INDICATOR)
   //  {
   //   m_table_indicator_need_sync = false;
   //   InitializeTable_IndicatorTemplateSetting();
   //  }
   // Handling the elements
    OnTimer_SettingTimeSeries();
    if(m_window_setting_trading.IsVisible())
       m_window_setting_trading.OnTimerEvent();
    if(m_window_setting_markerAndSound.IsVisible())
       m_window_setting_markerAndSound.OnTimerEvent();
    if(m_window_candle_infomation.IsVisible())
       m_window_candle_infomation.OnTimerEvent();
    m_window_main.OnTimerEvent();
  }
 void CGUIPannel::OnTickEvent(void)
  {
   bool redraw_needed = false;
   // --- Status Bar (Deposit Load/Profit/Server Time)
    if(UpdateStatusBar())
      redraw_needed = true;
   //For sound and message alerts - run every tick to catch all bar 0 changes.
   // PlaySoundCloseBar();
    CheckIndicatorAlerts();
    CheckCandlePatternAlerts();
    CheckSwingAlerts();
   //// Update data for the Symbol/SL/TP/Level Table on the Settings tab
   // if(m_active_window_index == WindowIdx(m_window_setting_trading)
   //    && m_tabs_setting_trading.SelectedTab() == ENUM_TAB_SETTING_TRADING_STOPLOST
   //    && SyncTable_StopLostSetting())
   //   redraw_needed = true;
   //// Update data for the Symbol/Trailing Table on the Settings tab - same gating, Trailling tab
   // if(m_active_window_index == WindowIdx(m_window_setting_trading)
   //    && m_tabs_setting_trading.SelectedTab() == ENUM_TAB_SETTING_TRADING_TRAILLING
   //    && SyncTable_TrailingSetting())
   //   redraw_needed = true;
   // if(m_active_window_index == WindowIdx(m_window_setting_trading)
   //    && m_tabs_setting_trading.SelectedTab() == ENUM_TAB_SETTING_TRADING_TRAILLING)
   //  {
   //   string trail_label = m_label_TrailingSetting_Symbol.LabelText();
   //   int    trail_sep    = StringFind(trail_label, " - ");
   //   string trail_symbol = (trail_sep >= 0) ? StringSubstr(trail_label, trail_sep + 3) : "";
   //   if(trail_symbol != "" && trail_symbol != "-" && SyncTable_IndicatorsTrailingSetting(trail_symbol))
   //      redraw_needed = true;
   //  }
   // Setting Trading window: live tables of the tab being shown
    if(m_window_setting_trading.IsVisible())
     {
      int trading_tab = m_tabs_setting_trading.SelectedTab();
      if(trading_tab == ENUM_TAB_SETTING_TRADING_STOPLOST && SyncTable_StopLostSetting())
         redraw_needed = true;
      if(trading_tab == ENUM_TAB_SETTING_TRADING_TRAILLING)
       {
        if(SyncTable_TrailingSetting())
           redraw_needed = true;
        string trail_label  = m_label_TrailingSetting_Symbol.Text();
        int    trail_sep    = ::StringFind(trail_label, " - ");
        string trail_symbol = (trail_sep >= 0) ? ::StringSubstr(trail_label, trail_sep + 3) : "";
        if(trail_symbol != "" && trail_symbol != "-" && m_table_indicators_trailingsetting.IsVisible() &&
           SyncTable_IndicatorsTrailingSetting(trail_symbol))
           redraw_needed = true;
       }
     }
   // Update data for m_table_positions_StoplostAndTrailling on the Trading tab
    bool trading_tab_shown = (m_window_main.IsVisible() && !m_window_main.IsMinimized()
                              && m_tabs_main.SelectedTab() == TAB_TAB_MAIN_TRADING);
    if(trading_tab_shown && SyncTable_PositionsStoplostAndTrailling())
      redraw_needed = true;
   // Update data for m_table_position_pretrade_view
    if(trading_tab_shown && SyncTable_PositionPretradeView())
      redraw_needed = true;
    if(trading_tab_shown)
     {
      string toTrade_symbol = GetNewOrderSymbol();
      if(SyncTable_PreTradeSymbolMonitor(::Symbol()))   // Monitor follows the chart Symbol
         redraw_needed = true;
      if(toTrade_symbol != "" && m_trading_setup_manager != NULL)
       {
        CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(toTrade_symbol);
        bool sl_on    = (row_setting != NULL) && row_setting.StopLostActive();
        bool trail_on = (row_setting != NULL) && row_setting.TrailingActive();
        SyncRunSLTrailingButtonIcons(sl_on, trail_on);   // gear icons gray when off, dirty-checked inside
       }
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
  }
 //+------------------------------------------------------------------+
 //| OnEvent handler: windows handle their controls first, then the   |
 //| panel reacts to what they shouted                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
  {
    if(id == CHARTEVENT_KEYDOWN && lparam == 'O')
     {
       int total = ::ObjectsTotal(m_chart_id);
       int trade_objects = 0;
       ::Print("MY DEBUG CGUIPannel::OnEvent: ObjectsTotal=", total);
       for(int i = 0; i < total; i++)
        {
          string name = ::ObjectName(m_chart_id, i);
          if(::StringFind(name, "#") != 0) continue;
          trade_objects++;
          ::Print("MY DEBUG CGUIPannel::OnEvent: trade object ", name,
                  " type=", (int)::ObjectGetInteger(m_chart_id, name, OBJPROP_TYPE),
                  " zorder=", ::ObjectGetInteger(m_chart_id, name, OBJPROP_ZORDER));
        }
       ::Print("MY DEBUG CGUIPannel::OnEvent: trade objects found=", trade_objects);
     }
    m_window_main.OnChartEvent(id, lparam, dparam, sparam);
    m_window_setting_timeseries.OnChartEvent(id, lparam, dparam, sparam);
    m_window_setting_trading.OnChartEvent(id, lparam, dparam, sparam);
    m_window_setting_markerAndSound.OnChartEvent(id, lparam, dparam, sparam);
    m_window_candle_infomation.OnChartEvent(id, lparam, dparam, sparam);
    OnEvent_Window_Main(id, lparam, dparam, sparam);
    OnEvent_Window_SettingTimeSeries(id, lparam, dparam, sparam);
    OnEvent_Window_SettingTrading(id, lparam, dparam, sparam);
    OnEvent_Window_SettingMarkerAndSound(id, lparam, dparam, sparam);
    OnEvent_Window_CandleInfor(id, lparam, dparam, sparam);
   // A modal setting window locks the main window while it is open
    if(id == CHARTEVENT_CUSTOM + ON_OPEN_DIALOG_BOX && (int)dparam == W_DIALOG)
     {
      m_window_main.IsLocked(true);
      ::ChartRedraw(m_chart_id);
      return;
     }
    if(id == CHARTEVENT_CUSTOM + ON_CLOSE_DIALOG_BOX && (int)dparam == W_DIALOG)
     {
      m_window_main.IsLocked(false);
      ::ChartRedraw(m_chart_id);
      return;
     }
   // ESC always force-hides whichever Setting window is currently active
    if(id == CHARTEVENT_KEYDOWN && lparam == 27 && m_window_setting_timeseries.IsVisible())
     {
      CloseWindow_SettingTimeSeries();
      return;
     }
    if(id == CHARTEVENT_KEYDOWN && lparam == 27 && m_window_setting_trading.IsVisible())
     {
      CloseWindow_SettingTrading();
      return;
     }
    if(id == CHARTEVENT_KEYDOWN && lparam == 27 && m_window_setting_markerAndSound.IsVisible())
     {
      CloseWindow_SettingMarkerAndSound();
      return;
     }
   // if(id == CHARTEVENT_KEYDOWN && lparam == 27) // VK_ESCAPE
   //  {
   //   if(m_active_window_index == WindowIdx(m_window_setting_timeseries))
   //      CloseWindow_SettingTimeSeries();
   //   else if(m_active_window_index == WindowIdx(m_window_setting_trading))
   //      CloseWindow_SettingTrading();
   //   else if(m_active_window_index == WindowIdx(m_window_setting_markerAndSound))
   //      CloseWindow_SettingMarkerAndSound();
   //   return;
   //  }
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM && lparam == m_combobox_order_type.ObjectID())
      {
       UpdateSendButtonAppearance();
       return;
      }
   // A tab (re)show shows every element of the tab: hide again the ones that must stay hidden
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main.ObjectID())
      {
        HidePatternBitmapAtBar();
        HideWindow_CandleInfo();
        UpdateSendButtonAppearance();
        if(m_checkbox_use_RiskPerNewTrade.State()) m_edit_RiskPerNewTrade.Show(); else m_edit_RiskPerNewTrade.Hide();
        ::ChartRedraw(m_chart_id);
        return;
      }
   //   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON &&
   //      (lparam == m_btn_save_pattern_config.Id() || lparam == m_btn_save_swing_config.Id() || lparam == m_btn_save_SymbolTF.Id()))
   //    {
   //     SaveAllSettingsToJSON();
   //     return;
   //    }
   //    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_indicator.Id())
   //     {
   //      SaveAllSettingsToJSON();
   //      m_btn_save_indicator.Hide();
   //      return;
   //     }
  } 
 void CGUIPannel::SaveAllSettingsToJSON(void)
  {
   if(m_SymbolTFManager == NULL) return;
   string full_path = m_SymbolTFManager.GetFolderName() + "/Config_Setting.json";
   //string old_content = JSONConfig_ReadWholeFile(full_path);
   //string markers = JSONConfig_ExtractRawSection(old_content, "Markers_Setting");
   //string sound   = JSONConfig_ExtractRawSection(old_content, "Sound_Settings");
   //if(markers == "") markers = "{\n }";
   //if(sound == "")   sound   = "{\n }";
   string markers, sound;
   BuildJsonSection_Markers(markers);
   BuildJsonSection_Sound(sound);
   string symbols_tf = "[\n ]", templates = "[\n ]", stoplost = "[\n ]", trail_dri = "2";
   string pattern_alerts, swing = "{\n }";
   m_SymbolTFManager.BuildJsonSection(symbols_tf);
   if(m_indicator_template_manager != NULL) m_indicator_template_manager.BuildJsonSection(templates);
   if(m_trading_setup_manager != NULL)
    {
     m_trading_setup_manager.BuildJsonSection(stoplost);
     trail_dri = (string)m_trading_setup_manager.TrailingDataRatesIndex();
    }
   BuildJsonSection_PatternAlerts(pattern_alerts);
   if(m_SwingSetting != NULL) SwingSetting_BuildJsonSection(m_SwingSetting, swing);
   string json = "{\n"
                 " \"Symbols_TFs_List\": "        + symbols_tf     + ",\n"
                 " \"Indicator_Templates\": "     + templates      + ",\n"
                 " \"Markers_Setting\": "         + markers        + ",\n"
                 " \"Sound_Settings\": "          + sound          + ",\n"
                 " \"StopLost_Setting\": "        + stoplost       + ",\n"
                 " \"Trailing_DataRatesIndex\": " + trail_dri      + ",\n"
                 " \"Pattern_Alerts_Setting\": "  + pattern_alerts + ",\n"
                 " \"Swing_Alerts_Setting\": "    + swing          + "\n"
                 "}\n";
   int fh = ::FileOpen(full_path, FILE_TXT | FILE_WRITE | FILE_ANSI);
   if(fh == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > cannot open ", full_path, " for writing, err=", ::GetLastError());
     return;
    }
   ::FileWriteString(fh, json);
   ::FileClose(fh);
   ::Print(__FUNCTION__, " > saved all settings to ", full_path);
  }
 //+------------------------------------------------------------------+
 //| Update GUI                                                       |
 //+------------------------------------------------------------------+
 void CGUIPannel::UpdateGUI(const bool redraw)
  {
   // m_treeview_indicator_need_sync = true;
   // m_table_indicator_need_sync = true;
   if(redraw) ::ChartRedraw(m_chart_id);
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
