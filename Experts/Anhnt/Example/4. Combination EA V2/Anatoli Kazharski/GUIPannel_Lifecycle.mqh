//+------------------------------------------------------------------+
//|                                          GUIPannel_Lifecycle.mqh |
//|Implementation of Init, Deinit and other lifecycle events         |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_LIFECYCLE_MQH
#define CGUIPANNEL_LIFECYCLE_MQH
#include "GUIPannel.mqh"
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
     if(!CreateCFrame_IndicatorParameter(PARAM_FORM_X, PARAM_FORM_Y)) return false;
     if(!CreateTable_IndicatorTemplateSetting(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;
     InitializeTable_IndicatorTemplateSetting();
     if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP, PARAM_FORM_Y)) return false;
     PopulateTreeView_SymbolTFSetting();
     SyncTreeView_SymbolTFSetting();
     if(!CreateTable_SymbolTFSetting(PARAM_FORM_X, 0)) return false;
     PopulateTable_SymbolTFSetting();
     LoadCandlePatternSetting_FromJSON();
     if(!CreateTable_CandlePatternSetting(0, 0)) return false;
     InitializeTable_CandlePatternSetting();
     if(!CreateTable_SmartMoneySetting(0, 0)) return false;
     InitializeTable_SmartMoneySetting();     
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
     if(!CreateTrailingForm(M_CONTROL_BORDER_GAP + m_table_indicators_trailingsetting.Width() + M_CONTROL_BORDER_GAP,
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
     int trading_top = M_CONTROL_BORDER_GAP + 3;
     int trading_body_top = trading_top + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP;   // below the TF switch row
     if(!CreateTFSwitchButtons(M_CONTROL_BORDER_GAP, trading_top)) return false;
     if(!CreateTable_PreTradeSymbolMonitor(M_CONTROL_BORDER_GAP, trading_body_top)) return false;
     if(!CreateTradingForm(M_CONTROL_BORDER_GAP + m_table_indicator_PreTradeSymbolMonitor.Width() + M_CONTROL_BORDER_GAP, trading_body_top)) return false;
     if(!CreateTable_PositionPretradeView(M_CONTROL_BORDER_GAP, trading_body_top + TRADING_FORM_HEIGHT + M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__, " > Failed to create Position Pretrade View table!");
       return (false);
      }
     OnSymbolToTradeChanged();
     Sync_CButtonsGroup_TFSwitchButtons();
     if(!CreateTable_PositionsStoplostAndTrailling(M_CONTROL_BORDER_GAP, trading_body_top + TRADING_FORM_HEIGHT + M_CONTROL_HEIGHT + PRETRADE_VIEW_TABLE_HEIGHT + M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__, " > Failed to create Positions StopLost/Trailing table!");
       return (false);
      }    
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
                                m_trading_setup_manager(NULL),m_marker_setting(NULL),m_chart_obj_collection(NULL),m_graph_elements(NULL),
                                m_candle_info_shown_bar(0),m_candle_info_by_marker(false),m_chart_id(::ChartID()),m_subwin(0)
  {
   //--- Setting parameters for the time counters
    m_gui_timecounter.SetParameters(16, 500);
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
 bool CGUIPannel::OnInit(const int uninit_reason)
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
      OnClick_CButtonsGroup_TFSwitchButton();          // chart Symbol may have changed
      SyncTreeView_SymbolTFSetting(); // chart pair moved: the start-icon row and the active Symbol node follow it
      SyncTable_SymbolTFSetting();
      UpdateGUI(false);
    }   
   //--- Registration order = stacking order: main at the bottom of the panel, dialogs above it
   if(m_graph_elements != NULL)
    {
      m_graph_elements.RegisterElement(GetPointer(m_window_main));
      m_graph_elements.RegisterElement(GetPointer(m_window_setting_timeseries));
      m_graph_elements.RegisterElement(GetPointer(m_window_setting_trading));
      m_graph_elements.RegisterElement(GetPointer(m_window_setting_markerAndSound));
      m_graph_elements.RegisterElement(GetPointer(m_window_candle_infomation));
    }
   return true;
  };
 //+------------------------------------------------------------------+
 //| Deinit                                                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnDeinit(const int reason)
  {
    //--- Symbol/TF change too: the popup belongs to the old bars
     HideWindow_CandleInfo();
    if(reason != REASON_CHARTCHANGE)
     ::ChartRedraw(m_chart_id);    
  }
 //+------------------------------------------------------------------+
 //| Timer                                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTimerEvent(void)
  {
   //--- Exit if this is the tester
    if (::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_FRAME_MODE))
      return;   
   // Handling the elements
    if(m_window_setting_timeseries.IsVisible())
       m_window_setting_timeseries.OnTimerEvent();
    if(m_window_setting_trading.IsVisible())
       m_window_setting_trading.OnTimerEvent();
    if(m_window_setting_markerAndSound.IsVisible())
       m_window_setting_markerAndSound.OnTimerEvent();
    if(m_window_candle_infomation.IsVisible())
       m_window_candle_infomation.OnTimerEvent();
    m_window_main.OnTimerEvent();
  }
 void CGUIPannel::OnTick(const bool new_bar)
  {
   //Print Debug
        PERF_BEGIN
   bool redraw_needed = false;
   // --- Status Bar (Deposit Load/Profit/Server Time)
    if(UpdateStatusBar())
      redraw_needed = true;
    //Print Debug
        PERF_LAP("GUI.Tick.statusBar")
   // PlaySoundCloseBar();
    if(new_bar)
       CheckIndicatorAlerts();   // closed-bar flips only; live flips arrive as SIGNAL_EVENT_LIVE_FLIP
    //Print Debug
        PERF_LAP("GUI.Tick.indicatorAlerts")
    CheckCandlePatternAlerts(new_bar);   // closed-bar part on a new bar only, live bar 0 every tick
    //Print Debug
        PERF_LAP("GUI.Tick.patternAlerts")
    if(new_bar)
       CheckSwingAlerts();
    if(new_bar)
       CheckMarketStructureAlerts();
    //Print Debug
        PERF_LAP("GUI.Tick.swingAndStructureAlerts")
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
   //Print Debug
       PERF_LAP("GUI.Tick.tables")
   // Redraw the chart if any of the above updates required it
    if(redraw_needed)
           ::ChartRedraw();

  }
 //+------------------------------------------------------------------+
 //| Trade operation event                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTrade(void)
  {
  }
 //+------------------------------------------------------------------+
 //| OnEvent handler: windows handle their controls first, then the   |
 //| panel reacts to what they shouted                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnChartEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
  {
    if(id == CHARTEVENT_CUSTOM + SIGNAL_EVENT_LIVE_FLIP)
     {
      OnSignalLiveFlip(lparam, (ENUM_SIGNAL_DIR)(int)dparam, sparam);
      return;
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
      m_window_setting_timeseries.CloseWindow();
      return;
     }
    if(id == CHARTEVENT_KEYDOWN && lparam == 27 && m_window_setting_trading.IsVisible())
     {
      m_window_setting_trading.CloseWindow();
      return;
     }
    if(id == CHARTEVENT_KEYDOWN && lparam == 27 && m_window_setting_markerAndSound.IsVisible())
     {
      m_window_setting_markerAndSound.CloseWindow();
      return;
     }   
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM && lparam == m_combobox_order_type.ObjectID())
      {
       UpdateSendButtonAppearance();
       return;
      }
   // A tab (re)show shows every element of the tab: hide again the ones that must stay hidden
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main.ObjectID())
      {
        HideWindow_CandleInfo();
        UpdateSendButtonAppearance();
        if(m_checkbox_use_RiskPerNewTrade.State()) m_edit_RiskPerNewTrade.Show(); else m_edit_RiskPerNewTrade.Hide();
        ::ChartRedraw(m_chart_id);
        return;
      }   
  } 
 void CGUIPannel::SaveAllSettingsToJSON(void)
  {
   if(m_SymbolTFManager == NULL) return;
   string full_path = m_SymbolTFManager.GetFolderName() + "/Config_Setting.json";   
   string markers = "{\n }", sound;
   if(m_marker_setting != NULL) m_marker_setting.BuildJsonSection(markers);
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
   if(m_SwingSetting != NULL) SmartMoneySetting_BuildJsonSection(m_SwingSetting, swing);
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
   if(redraw) ::ChartRedraw(m_chart_id);
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
