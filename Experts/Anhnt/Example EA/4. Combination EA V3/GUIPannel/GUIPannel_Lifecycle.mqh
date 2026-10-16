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
    m_window_setting_trading.Hide();
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
    //Create MenuBar right below the caption bar - always-visible slim strip
    if(!CreateMenuBar(1,M_MENU_BAR_Y))
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
    // Create Setting Trading window implementation in GUIPannel_SettingWindows_Trading.mqh
    if(!CreateWindow_SettingTrading("Setting Trading",30,30))
      {
       Print(__FUNCTION__," > Failed to create the Setting Trading window!");
       return(false);
      }
    if(!CreateTab_SettingTrading(M_CONTROL_BORDER_GAP,WINDOW_CAPTION_HEIGHT+M_CONTROL_HEIGHT))
      {
       Print(__FUNCTION__," > Failed to create the Setting Trading Tab!");
       return(false);
      }
    if(!CreateTable_StopLostSetting(M_CONTROL_BORDER_GAP,0))
       return(false);
    if(!CreateStopLostForm(M_CONTROL_BORDER_GAP,SETTING_TRADING_TABLE_HEIGHT+M_CONTROL_BORDER_GAP))
       return(false);
    if(!CreateTable_TrailingSetting(M_CONTROL_BORDER_GAP,0))
       return(false);
    if(!CreateTable_IndicatorsTrailingSetting(M_CONTROL_BORDER_GAP,SETTING_TRADING_TABLE_HEIGHT+M_CONTROL_BORDER_GAP))
       return(false);
    if(!CreateTrailingForm(M_CONTROL_BORDER_GAP+m_table_indicators_trailingsetting.Width()+M_CONTROL_BORDER_GAP,
                           SETTING_TRADING_TABLE_HEIGHT+M_CONTROL_BORDER_GAP+M_CONTROL_YDISTANCE))
       return(false);
    if(!CreateWindow_CandleInfo())
      {
       Print(__FUNCTION__," > Failed to create the Candle Information window!");
       return(false);
      }
    // Trading tab implementation in GUIPannel_MainWindows_TabTrading.mqh
    int trading_body_top=M_CONTROL_BORDER_GAP+M_CONTROL_BORDER_GAP;   // the TF switch row is above the tabs, in m_window_main
    if(!BuildTFSwitchButtons(M_CONTROL_BORDER_GAP,M_TF_SWITCH_Y))
       return(false);
    if(!CreateTable_PreTradeSymbolMonitor(M_CONTROL_BORDER_GAP,trading_body_top))
       return(false);
    if(!CreateTradingForm(M_CONTROL_BORDER_GAP+m_table_indicator_PreTradeSymbolMonitor.Width()+M_CONTROL_BORDER_GAP,trading_body_top))
       return(false);
    if(!CreateTable_PositionPretradeView(M_CONTROL_BORDER_GAP,trading_body_top+TRADING_FORM_HEIGHT+M_CONTROL_HEIGHT))
       return(false);
    OnSymbolToTradeChanged();
    BuildTFSwitchButtons();
    if(!CreateTable_PositionsStoplostAndTrailling(M_CONTROL_BORDER_GAP,trading_body_top+TRADING_FORM_HEIGHT+M_CONTROL_HEIGHT+PRETRADE_VIEW_TABLE_HEIGHT+M_CONTROL_HEIGHT))
       return(false);
    if(!CreateTable_MarketStory(M_CONTROL_BORDER_GAP,trading_body_top))
       return(false);
    //--- Default to the Trading tab
    m_tabs_main.SelectTab(TAB_TAB_MAIN_TRADING);
    //--- One Show for the whole panel; CTabs::Show keeps only the selected tab
    m_window_main.Show();
    ::ChartRedraw(m_ChartObj.GetChartID());
    return(true);
  }
 //+------------------------------------------------------------------+
 //| Constructor/Destructor                                           |
 //+------------------------------------------------------------------+
 CGUIPannel::CGUIPannel(void) : m_gui_created(false),
                                m_SymbolTFManager(NULL),
                                m_IndicatorTemplateManager(NULL),
                                m_PatternManager(NULL),
                                m_IndicatorsCollection(NULL),
                                m_SymbolsCollection(NULL),
                                m_story_conditions(NULL),
                                m_story_movements(NULL),
                                m_story_setting(NULL),
                                m_ChartObj(NULL),
                                m_TradingSetupManager(NULL),
                                m_MarketCollection(NULL),
                                m_TradingEngine(NULL),
                                m_new_order_is_buy(true),
                                m_new_order_lot_last(0.0),
                                m_candle_info_shown_bar(0),
                                m_candle_info_by_marker(false),
                                m_current_param_type(IND_CUSTOM),
                                m_graph_elements(NULL)
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
     //--- The New Order combobox mirrors the chart Symbol, the TF buttons select the TF the chart is on (the chart is not moved again)
     m_table_position_pretrade_view.SetValue(COL_PTV_SYMBOL,0,::Symbol());
     OnSymbolToTradeChanged(false);
     BuildTFSwitchButtons();
     HighlightTable_MarketStory();   // the TF the chart is on; the data come with the answer of Python
    }
   //--- Registration order = stacking order: main at the bottom of the panel, dialogs above it
   if(m_graph_elements!=NULL)
     {
      m_graph_elements.RegisterElement(::GetPointer(m_window_main));
      m_graph_elements.RegisterElement(::GetPointer(m_window_setting_timeseries));
      m_graph_elements.RegisterElement(::GetPointer(m_window_setting_trading));
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
      ::ChartRedraw(m_ChartObj.GetChartID());
  }
//+------------------------------------------------------------------+
 //| Tick: the live tables of the Setting Trading window, at most four |
 //| times a second                                                   |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTickEvent(void)
  {
   static ulong setting_trading_sync_ms=0;
   if(!m_window_setting_trading.IsVisible() || ::GetTickCount64()-setting_trading_sync_ms<250)
      return;
   setting_trading_sync_ms=::GetTickCount64();
   bool redraw_needed=false;
   int trading_tab=m_tabs_setting_trading.SelectedTab();
   if(trading_tab==ENUM_TAB_SETTING_TRADING_STOPLOST)
     {
      if(SyncTable_StopLostSetting())
         redraw_needed=true;
      string sl_label=m_label_StopLostSetting_Symbol.Text();
      int    sl_sep=::StringFind(sl_label," - ");
      string sl_symbol=(sl_sep>=0) ? ::StringSubstr(sl_label,sl_sep+3) : "";
      if(sl_symbol!="" && sl_symbol!="-" && m_label_StopLostSetting_Symbol.IsVisible() && UpdateStopLostPreview(sl_symbol))
         redraw_needed=true;
     }
   if(trading_tab==ENUM_TAB_SETTING_TRADING_TRAILLING)
     {
      if(SyncTable_TrailingSetting())
         redraw_needed=true;
      string trail_label=m_label_TrailingSetting_Symbol.Text();
      int    trail_sep=::StringFind(trail_label," - ");
      string trail_symbol=(trail_sep>=0) ? ::StringSubstr(trail_label,trail_sep+3) : "";
      if(trail_symbol!="" && trail_symbol!="-" && m_table_indicators_trailingsetting.IsVisible() &&
         SyncTable_IndicatorsTrailingSetting(trail_symbol))
         redraw_needed=true;
     }
   if(redraw_needed)
      ::ChartRedraw(m_ChartObj.GetChartID());
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
      if(SyncTable_PositionsStoplostAndTrailling())
         redraw_needed=true;
      string to_trade_symbol=GetNewOrderSymbol();
      CTradingSetupSetting *to_trade_setting=(to_trade_symbol!="" && m_TradingSetupManager!=NULL) ? m_TradingSetupManager.FindByIdentity(to_trade_symbol) : NULL;
      SyncRunSLTrailingButtonIcons(to_trade_setting!=NULL && to_trade_setting.StopLostActive(),to_trade_setting!=NULL && to_trade_setting.TrailingActive());
     }
   if(redraw_needed)
      ::ChartRedraw(m_ChartObj.GetChartID());
   if(m_window_setting_timeseries.IsVisible())
      m_window_setting_timeseries.OnTimerEvent();
   if(m_window_setting_trading.IsVisible())
      m_window_setting_trading.OnTimerEvent();
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
   m_window_setting_trading.OnChartEvent(id,lparam,dparam,sparam);
   m_window_candle_infomation.OnChartEvent(id,lparam,dparam,sparam);
   OnEvent_Window_Main(id,lparam,dparam,sparam);
   OnEvent_Window_SettingTimeSeries(id,lparam,dparam,sparam);
   OnEvent_Window_SettingTrading(id,lparam,dparam,sparam);
   OnEvent_Window_CandleInfor(id,lparam,dparam,sparam);
   //--- Esc closes the setting window that is open
   if(id==CHARTEVENT_KEYDOWN && lparam==27 && m_window_setting_timeseries.IsVisible())
     {
      m_window_setting_timeseries.CloseWindow();
      return;
     }
   if(id==CHARTEVENT_KEYDOWN && lparam==27 && m_window_setting_trading.IsVisible())
     {
      m_window_setting_trading.CloseWindow();
      return;
     }
   // A modal setting window locks the main window while it is open
   if(id==CHARTEVENT_CUSTOM+ON_OPEN_DIALOG_BOX && (int)dparam==W_DIALOG)
     {
      m_window_main.IsLocked(true);
      ::ChartRedraw(m_ChartObj.GetChartID());
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLOSE_DIALOG_BOX && (int)dparam==W_DIALOG)
     {
      m_window_main.IsLocked(false);
      ::ChartRedraw(m_ChartObj.GetChartID());
      return;
     }
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
