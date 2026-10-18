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
    m_window_addIndicator.Hide();
    m_window_candle_infomation.Hide();
    m_window_tradeManage.Hide();
    this.AddChild(&m_window_main);
    this.AddChild(&m_window_addIndicator);
    this.AddChild(&m_window_candle_infomation);
    this.AddChild(&m_window_tradeManage);
   // Create Main Frame window implementation in GUIPannel_MainWindows.mqh
    if(!CreateWindow_Main("EXPERT PANEL Ver3",1,1))
     {
      ::Print(__FUNCTION__," > Failed to create Main Window!");
      return(false);
     }
    //Create Status Bar at the bottom of m_window_main
    if(!CreateStatusBar(1,M_WINDOW_MAIN_HEIGHT-M_CONTROL_HEIGHT-1))
     {
      ::Print(__FUNCTION__," > Failed to create Status Bar!");
      return(false);
     }
    //Create MenuBar right below the caption bar - always-visible slim strip
    if(!CreateMenuBar(1,M_MENU_BAR_Y))
     {
      ::Print(__FUNCTION__," > Failed to create MenuBar!");
      return(false);
     }
    //Create the TF switch below the menu bar: the TFs of the chart Symbol
    if(!BuildTFSwitchButtons(M_CONTROL_BORDER_GAP,M_TF_SWITCH_Y))
     {
      ::Print(__FUNCTION__," > Failed to create the TF switch!");
      return(false);
     }
    //Create Main Tab
    if(!CreateTab_Main(M_CONTROL_BORDER_GAP,M_TABS_MAIN_Y))
     {
      ::Print(__FUNCTION__," > Failed to create Main Tabs!");
      return(false);
     }
    //Create the Quick Setting tabs, in the Quick Setting tab of Main Tab
    if(!CreateTab_QuickSetting(M_TAB_QUICK_SETTING_WIDTH,0))
     {
      ::Print(__FUNCTION__," > Failed to create Quick Setting Tabs!");
      return(false);
     }
    //Create the monitor tabs, in the Trading tab of Main Tab
    if(!CreateTabs_Monitor(0,M_CONTROL_HEIGHT))
     {
      ::Print(__FUNCTION__," > Failed to create the Monitor Tabs!");
      return(false);
     }
    //Create the Symbol+TF combobox in the caption bar of m_window_main
    if(!CreateComboBox_SymbolTF(m_window_main.Width()-m_window_main.CaptionRightLimit()-M_SYMBOLTF_COMBO_WIDTH,0))
     {
      ::Print(__FUNCTION__," > Failed to create the Symbol TF ComboBox!");
      return(false);
     }
    this.UpdateStatusBar_SymbolSpread();
    this.UpdateStatusBar_Balance();
    //--- Default to the Trading tab
    m_tabs_main.SelectTab(TAB_TAB_MAIN_TRADING);
    // Create the Add Indicator window (hidden): the tree of the types and the form of the parameters
    if(!CreateWindow_AddIndicator("Add Indicator",30,30))
     {
      ::Print(__FUNCTION__," > Failed to create the Add Indicator window!");
      return(false);
     }
    if(!CreateTreeView_IndicatorTemplateSetting(M_CONTROL_BORDER_GAP,PARAM_FORM_Y))
       return(false);
    PopulateTreeView_IndicatorTemplateSetting();
    SyncTreeView_IndicatorTemplateSetting();
    if(!CreateCFrame_IndicatorParameter(PARAM_FORM_X,PARAM_FORM_Y))
       return(false);
    // Create the Trade Manage window (hidden): its button of the Trading tab opens it
    if(!CreateWindow_TradeManage("Trade Manage",30,30))
     {
      ::Print(__FUNCTION__," > Failed to create the Trade Manage window!");
      return(false);
     }
    // Create the Candle information popup (hidden): the EA opens it
    if(!CreateWindow_CandleInfo())
      {
       ::Print(__FUNCTION__," > Failed to create the Candle information window!");
       return(false);
      }
    m_window_main.Show();
    ::ChartRedraw(this.m_chart_id);
    return(true);
  }
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CGUIPannel::CGUIPannel(void) : m_graph_elements(NULL),
                                m_SymbolsCollection(NULL),
                                m_AccountsCollection(NULL),
                                m_SymbolTFManager(NULL),
                                m_PatternManager(NULL),
                                m_IndicatorTemplateManager(NULL),
                                m_current_param_type(IND_CUSTOM),
                                m_SwingSetting(NULL),
                                m_StructureSetting(NULL),
                                m_FvgSetting(NULL),
                                m_MomentumCandleSetting(NULL),
                                m_SupplyDemandSetting(NULL),
                                m_TrendlineSetting(NULL),
                                m_SupportResistanceSetting(NULL),
                                m_IndicatorsCollection(NULL),
                                m_TradingSetupManager(NULL),
                                m_TradingEngine(NULL),
                                m_story_conditions(NULL),
                                m_story_movements(NULL),
                                m_story_setting(NULL),
                                m_position_reload_at(0),
                                m_candle_info_shown_bar(0),
                                m_candle_info_by_marker(false)
  {
   this.m_chart_id=::ChartID();
  }
 //+------------------------------------------------------------------+
 //| Init                                                             |
 //+------------------------------------------------------------------+
 bool CGUIPannel::OnInit(const int uninit_reason)
  {
   if(m_first_start)   // true until the GUI is built; survives a chart-change re-init so controls are not created twice
    {
     CAccount *account=(m_AccountsCollection!=NULL) ? m_AccountsCollection.GetCurrentAccount() : NULL;
     if(account!=NULL)
       {
        account.SetControlBalanceInc(0);   // any increase / decrease of the balance is flagged
        account.SetControlBalanceDec(0);
       }
     if(!CreateGUIPannel())
        return(false);
     m_first_start=false;
    }
   else
      this.SyncComboBox_SymbolTF();   // the chart moved to another Symbol / TF
      this.BuildTFSwitchButtons();
      this.HighlightTable_MarketStory();   // the TF the chart is on; the data come with the answer of Python
      this.SyncTreeView_SymbolTFSetting();
      this.SyncTable_SymbolTFSetting();
      this.UpdateStatusBar_SymbolSpread();
   //--- Registration order = stacking order
   if(m_graph_elements!=NULL)
     {
      m_graph_elements.RegisterElement(::GetPointer(m_window_main));
      m_graph_elements.RegisterElement(::GetPointer(m_window_addIndicator));
      m_graph_elements.RegisterElement(::GetPointer(m_window_tradeManage));
      m_graph_elements.RegisterElement(::GetPointer(m_window_candle_infomation));   // the last one: on top
     }
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Tick: the spread of the chart Symbol                             |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTickEvent(void)
  {
   if(m_first_start)
      return;
   this.UpdateStatusBar_SymbolSpread();
   //--- The Stop Loss tab: the distances follow the market (the spread), at most four times a second; the tables of the indicators follow the event of Python
   static ulong risk_sync_ms=0;
   if(!m_tabs_riskManagement.IsVisible() || ::GetTickCount64()-risk_sync_ms<250)
      return;
   risk_sync_ms=::GetTickCount64();
   bool redraw_needed=false;
   if(m_tabs_riskManagement.SelectedTab()==TAB_RISK_MANAGEMENT_STOP_LOST)
      redraw_needed=this.UpdateStopLostPreview(::Symbol());
   if(redraw_needed)
      ::ChartRedraw(this.m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| Trade: the balance may have changed                              |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTradeEvent(void)
  {
   if(!m_first_start)
      this.UpdateStatusBar_Balance();
   m_position_reload_at=::GetTickCount64()+1500;   // the positions file is written by Python a moment later: OnTimerEvent reads it then
  }
 //+------------------------------------------------------------------+
 //| Deinit                                                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnDeinit(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE)
      ::ChartRedraw(this.m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| Every child gets the event and handles what is its own           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0;i<this.ChildrenTotal();i++)
      this.Child(i).OnChartEvent(id,lparam,dparam,sparam);
   //--- A Symbol picked in the combobox of the caption: the manager tells the EA, the EA moves the chart, the TF stays
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM && lparam==m_combobox_SymbolTF.ObjectID() && m_SymbolTFManager!=NULL && m_SymbolsCollection!=NULL)
     {
      CSymbol *symbol=m_SymbolsCollection.GetList().At((int)dparam);
      if(symbol!=NULL && symbol.Name()!=::Symbol())
         m_SymbolTFManager.NotifySettingChanged(symbol.Name(),(ENUM_TIMEFRAMES)::Period());
      return;
     }
   //--- A TF picked in the TF switch: the same, the Symbol stays
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON && lparam==m_btngroup_tf_switch.ObjectID() && m_SymbolTFManager!=NULL)
     {
      ENUM_TIMEFRAMES tf=GetTFSwitchSelection();   // "All" = PERIOD_CURRENT: the monitor shows every TF and the chart stays
      if(tf!=PERIOD_CURRENT && tf!=(ENUM_TIMEFRAMES)::Period())
         m_SymbolTFManager.NotifySettingChanged(::Symbol(),tf);
      else
         this.SyncTable_PreTradeSymbolMonitor(::Symbol(),true);
      return;
     }
   this.OnEvent_Window_AddIndicator(id,lparam,dparam,sparam);
   this.OnEvent_Window_TradeManage(id,lparam,dparam,sparam);
   this.OnEvent_Window_CandleInfor(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Indicator(id,lparam,dparam,sparam);
   this.OnEvent_Tab_SymbolTF(id,lparam,dparam,sparam);
   this.OnEvent_Tab_CandlePattern(id,lparam,dparam,sparam);
   this.OnEvent_Tab_SmartMoney(id,lparam,dparam,sparam);
   this.OnEvent_Tab_StopLost(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Trailing(id,lparam,dparam,sparam);
   this.OnEvent_Tab_RiskSetup(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Trading(id,lparam,dparam,sparam);
   //--- The window changed its width (border, full screen): the combobox stays next to the caption buttons
   if(id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE && lparam==m_window_main.ObjectID())
      this.ArrangeComboBox_SymbolTF();
   //--- The tracked pairs changed: the list follows
   if(!m_first_start && (id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE ||
                         id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_ADD || id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_DEL))
     {
      this.SyncComboBox_SymbolTF();
      this.BuildTFSwitchButtons();
     }
  }
#endif // CGUIPANNEL_LIFECYCLE_MQH
