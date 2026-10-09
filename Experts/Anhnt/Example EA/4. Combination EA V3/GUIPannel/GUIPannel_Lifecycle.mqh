//+------------------------------------------------------------------+
//|                                          GUIPannel_Lifecycle.mqh |
//|Implementation of Init, Deinit and other lifecycle events         |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_LIFECYCLE_MQH
#define CGUIPANNEL_LIFECYCLE_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Create every window, hidden, then show the main one              |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateGUIPannel(void)
  {
   //--- Every window is hidden BEFORE Create: born hidden, children inherit it, m_window_main shown once at the end
    m_window_main.Hide();
    m_window_setting_timeseries.Hide();
    m_window_setting_markerAndSound.Hide();
    m_window_candle_infomation.Hide();
   // Create Main Frame window implementation in GUIPannel_MainWindows.mqh
    if(!CreateWindow_Main("EXPERT PANEL Ver3",1,1))
     {
      Print(__FUNCTION__," > Failed to create Main Window!");
      return(false);
     }
    //Create Status Bar at the bottom of m_window_main
    if(!CreateStatusBar(1,M_WINDOW_MAIN_HEIGHT-23))
     {
      Print(__FUNCTION__," > Failed to create Status Bar!");
      return(false);
     }
    //Create MenuBar right below the caption bar (22px) - always-visible slim strip
    if(!CreateMenuBar(1,22))
     {
      Print(__FUNCTION__," > Failed to create MenuBar!");
      return(false);
     }
    //Create Main Tab
    if(!CreateTab_Main(M_CONTROL_BORDER_GAP,M_TABS_MAIN_Y))
     {
      Print(__FUNCTION__," > Failed to create Tabs1!");
      return(false);
     }
   // Create Setting TimeSeries window implementation in GUIPannel_SettingWindows_TimeSeries.mqh
    if(!CreateWindow_SettingTimeSeries("Setting Time Serries",30,30))
     {
      Print(__FUNCTION__," > Failed to create Setting Windows!");
      return(false);
     }
    if(!CreateTab_SettingTimeSeries(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+M_CONTROL_HEIGHT))
     {
      Print(__FUNCTION__," > Failed to create Setting Time Serries Tab!");
      return(false);
     }
    //Tab children y is measured from the content area, below the tab header
    if(!CreateTreeView_IndicatorTemplateSetting(M_CONTROL_BORDER_GAP,PARAM_FORM_Y))
       return(false);
    PopulateTreeView_IndicatorTemplateSetting();
    SyncTreeView_IndicatorTemplateSetting();
    if(!CreateCFrame_IndicatorParameter(PARAM_FORM_X,PARAM_FORM_Y))
       return(false);
    if(!CreateTable_IndicatorTemplateSetting(PARAM_FORM_X,INDICATOR_TABLE_Y))
       return(false);
    InitializeTable_IndicatorTemplateSetting();
    if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP,PARAM_FORM_Y))
       return(false);
    PopulateTreeView_SymbolTFSetting();
    SyncTreeView_SymbolTFSetting();
    if(!CreateTable_SymbolTFSetting(PARAM_FORM_X,0))
       return(false);
    PopulateTable_SymbolTFSetting();
    if(!CreateTable_CandlePatternSetting(0,0))
       return(false);
    InitializeTable_CandlePatternSetting();
    if(!CreateTable_SmartMoneySetting(0,0))
       return(false);
    InitializeTable_SmartMoneySetting();
    // Create Setting Marker and Sound window implementation in GUIPannel_SettingWindows_Alert.mqh
    if(!CreateWindow_SettingMarkerAndSound("Setting Marker and Sound",30,30))
      {
       Print(__FUNCTION__," > Failed to create the Marker and Sound window!");
       return(false);
      }
    if(!CreateTab_SettingMarkerAndSound(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+M_CONTROL_HEIGHT))
       return(false);
    if(!CreateTab_SettingConfig_Marker(0,M_CONTROL_BORDER_GAP+5))
       return(false);
    if(!CreateWindow_CandleInfo())
      {
       Print(__FUNCTION__," > Failed to create the Candle Information window!");
       return(false);
      }
    // Trading tab implementation in GUIPannel_MainWindows_TabTrading.mqh
    int trading_top=M_CONTROL_BORDER_GAP+3;
    int trading_body_top=trading_top+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;   // below the TF switch row
    if(!CreateTFSwitchButtons(M_CONTROL_BORDER_GAP,trading_top))
       return(false);
    if(!CreateTable_PreTradeSymbolMonitor(M_CONTROL_BORDER_GAP,trading_body_top))
       return(false);
    if(!CreateTradingForm(M_CONTROL_BORDER_GAP+m_table_indicator_PreTradeSymbolMonitor.Width()+M_CONTROL_BORDER_GAP,trading_body_top))
       return(false);
    if(!CreateTable_PositionPretradeView(M_CONTROL_BORDER_GAP,trading_body_top+TRADING_FORM_HEIGHT+M_CONTROL_HEIGHT))
       return(false);
    OnSymbolToTradeChanged();
    Sync_CButtonsGroup_TFSwitchButtons();
    if(!CreateTable_PositionsStoplostAndTrailling(M_CONTROL_BORDER_GAP,trading_body_top+TRADING_FORM_HEIGHT+M_CONTROL_HEIGHT+PRETRADE_VIEW_TABLE_HEIGHT+M_CONTROL_HEIGHT))
       return(false);
    //--- Default to the Trading tab
    m_tabs_main.SelectTab(TAB_TAB_MAIN_TRADING);
    //--- One Show for the whole panel; CTabs::Show keeps only the selected tab
    m_window_main.Show();
    ::ChartRedraw(m_chart_id);
    return(true);
  }
 //+------------------------------------------------------------------+
 //| Constructor/Destructor                                           |
 //+------------------------------------------------------------------+
 CGUIPannel::CGUIPannel(void) : m_gui_created(false),
                                m_SymbolTFManager(NULL),
                                m_SmartMoneySetting(NULL),
                                m_IndicatorTemplateManager(NULL),
                                m_PatternManager(NULL),
                                m_MarkerSetting(NULL),
                                m_IndicatorsCollection(NULL),
                                m_SymbolsCollection(NULL),
                                m_new_order_is_buy(true),
                                m_new_order_lot_last(0.0),
                                m_candle_info_shown_bar(0),
                                m_candle_info_by_marker(false),
                                m_current_param_type(IND_CUSTOM),
                                m_graph_elements(NULL),
                                m_chart_id(::ChartID()),
                                m_subwin(0)
  {
  }
 CGUIPannel::~CGUIPannel(void)
  {
  }
 //+------------------------------------------------------------------+
 //| Init                                                             |
 //+------------------------------------------------------------------+
 bool CGUIPannel::OnInit(const int uninit_reason)
  {
   if(!m_gui_created)
    {
     if(!CreateGUIPannel())
        return(false);
     m_gui_created=true;
     UpdateStatusBar();
    }
   else if(uninit_reason==REASON_CHARTCHANGE)
    {
     //--- The chart moved to another Symbol / TF: it is tracked from now on, the tree and the table follow it
     if(m_SymbolTFManager!=NULL && !m_SymbolTFManager.Exists(::Symbol(),(ENUM_TIMEFRAMES)::Period()))
        m_SymbolTFManager.Add_SymbolTFSetting(::Symbol(),(ENUM_TIMEFRAMES)::Period());
     SyncTreeView_SymbolTFSetting();
     SyncTable_SymbolTFSetting();
     //--- The New Order combobox mirrors the chart Symbol; the TF buttons follow the events of the manager, the monitor its filter
     m_table_position_pretrade_view.SetValue(COL_PTV_SYMBOL,0,::Symbol());
     OnSymbolToTradeChanged(false);
     OnClick_CButtonsGroup_TFSwitchButton();
    }
   //--- Registration order = stacking order: main at the bottom of the panel, dialogs above it
   if(m_graph_elements!=NULL)
     {
      m_graph_elements.RegisterElement(::GetPointer(m_window_main));
      m_graph_elements.RegisterElement(::GetPointer(m_window_setting_timeseries));
      m_graph_elements.RegisterElement(::GetPointer(m_window_setting_markerAndSound));
      m_graph_elements.RegisterElement(::GetPointer(m_window_candle_infomation));
     }
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Deinit                                                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnDeinit(const int reason)
  {
   //--- Symbol/TF change too: the popup belongs to the old bars
   HideWindow_CandleInfo();
   if(reason!=REASON_CHARTCHANGE)
      ::ChartRedraw(m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| Timer                                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTimerEvent(void)
  {
   //--- Exit if this is the tester
   if(::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_FRAME_MODE))
      return;
   bool redraw_needed=UpdateStatusBar();
   //--- The tables of the Trading tab, only while it is on screen and not more than four times a second
   static ulong trading_sync_ms=0;
   if(m_window_main.IsVisible() && !m_window_main.IsMinimized() && m_tabs_main.SelectedTab()==TAB_TAB_MAIN_TRADING &&
      ::GetTickCount64()-trading_sync_ms>=250)
     {
      trading_sync_ms=::GetTickCount64();
      if(SyncTable_PreTradeSymbolMonitor(::Symbol()))
         redraw_needed=true;
      if(SyncTable_PositionPretradeView())
         redraw_needed=true;
     }
   if(redraw_needed)
      ::ChartRedraw(m_chart_id);
   if(m_window_setting_timeseries.IsVisible())
      m_window_setting_timeseries.OnTimerEvent();
   if(m_window_setting_markerAndSound.IsVisible())
      m_window_setting_markerAndSound.OnTimerEvent();
   if(m_window_candle_infomation.IsVisible())
      m_window_candle_infomation.OnTimerEvent();
   m_window_main.OnTimerEvent();
  }
 //+------------------------------------------------------------------+
 //| OnEvent handler: windows handle their controls first, then the   |
 //| panel reacts to what they shouted                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   m_window_setting_timeseries.OnChartEvent(id,lparam,dparam,sparam);
   m_window_setting_markerAndSound.OnChartEvent(id,lparam,dparam,sparam);
   m_window_candle_infomation.OnChartEvent(id,lparam,dparam,sparam);
   OnEvent_Window_Main(id,lparam,dparam,sparam);
   OnEvent_Window_SettingTimeSeries(id,lparam,dparam,sparam);
   OnEvent_Window_SettingMarkerAndSound(id,lparam,dparam,sparam);
   OnEvent_Window_CandleInfor(id,lparam,dparam,sparam);
   //--- Esc closes the setting window that is open
   if(id==CHARTEVENT_KEYDOWN && lparam==27 && m_window_setting_timeseries.IsVisible())
     {
      m_window_setting_timeseries.CloseWindow();
      return;
     }
   if(id==CHARTEVENT_KEYDOWN && lparam==27 && m_window_setting_markerAndSound.IsVisible())
     {
      m_window_setting_markerAndSound.CloseWindow();
      return;
     }
   // A modal setting window locks the main window while it is open
   if(id==CHARTEVENT_CUSTOM+ON_OPEN_DIALOG_BOX && (int)dparam==W_DIALOG)
     {
      m_window_main.IsLocked(true);
      ::ChartRedraw(m_chart_id);
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLOSE_DIALOG_BOX && (int)dparam==W_DIALOG)
     {
      m_window_main.IsLocked(false);
      ::ChartRedraw(m_chart_id);
      return;
     }
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
