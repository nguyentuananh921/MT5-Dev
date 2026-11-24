//+------------------------------------------------------------------+
//|                                          GUIPannel_Lifecycle.mqh |
//|Implementation of Init, Deinit and other lifecycle events         |
//+------------------------------------------------------------------+
#ifndef __GUIPANNEL_LIFECYCLE_MQH__
#define __GUIPANNEL_LIFECYCLE_MQH__
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
    m_window_order_detail.Hide();
    this.AddChild(&m_window_main);
    this.AddChild(&m_window_addIndicator);
    this.AddChild(&m_window_candle_infomation);
    this.AddChild(&m_window_tradeManage);
    this.AddChild(&m_window_order_detail);
   // Create Main Frame window implementation in GUIPannel_Window_Main.mqh
    Breadcrumb("CreateGUIPannel: CreateWindow_Main");
    if(!CreateWindow_Main("EA PANEL V5",1,1))
     {
      ::Print(__FUNCTION__," > Failed to create Main Window!");
      return(false);
     }
    //Create Status Bar at the bottom of m_window_main
    Breadcrumb("CreateGUIPannel: CreateStatusBar");
    if(!CreateStatusBar(1,M_WINDOW_MAIN_HEIGHT-M_STATUS_BAR_HEIGHT-1))
     {
      ::Print(__FUNCTION__," > Failed to create Status Bar!");
      return(false);
     }
    //Create MenuBar right below the caption bar - always-visible slim strip
    Breadcrumb("CreateGUIPannel: CreateMenuBar");
    if(!CreateMenuBar(1,M_MENU_BAR_Y))
     {
      ::Print(__FUNCTION__," > Failed to create MenuBar!");
      return(false);
     }
    //Create the TF switch below the menu bar: the TFs of the chart Symbol
    Breadcrumb("CreateGUIPannel: BuildTFSwitchButtons");
    if(!BuildTFSwitchButtons(M_CONTROL_BORDER_GAP,M_TF_SWITCH_Y))
     {
      ::Print(__FUNCTION__," > Failed to create the TF switch!");
      return(false);
     }
    //Create Main Tab
    Breadcrumb("CreateGUIPannel: CreateTab_Main");
    if(!CreateTab_Main(M_CONTROL_BORDER_GAP,M_TABS_MAIN_Y))
     {
      ::Print(__FUNCTION__," > Failed to create Main Tabs!");
      return(false);
     }
    //Create the Quick Setting tabs, in the Quick Setting tab of Main Tab
    Breadcrumb("CreateGUIPannel: CreateTab_QuickSetting");
    if(!CreateTab_QuickSetting(M_TAB_QUICK_SETTING_WIDTH,0))
     {
      ::Print(__FUNCTION__," > Failed to create Quick Setting Tabs!");
      return(false);
     }
    //Create the Symbol+TF combobox in the caption bar of m_window_main
    Breadcrumb("CreateGUIPannel: CreateComboBox_SymbolTF");
    if(!CreateComboBox_SymbolTF(m_window_main.Width()-m_window_main.CaptionRightLimit()-M_SYMBOLTF_COMBO_WIDTH,0))
     {
      ::Print(__FUNCTION__," > Failed to create the Symbol TF ComboBox!");
      return(false);
     }
    //Create the labels of the positions and of the profit in the caption bar, left of the combobox
    Breadcrumb("CreateGUIPannel: CreateLabel_Caption");
    if(!CreateLabel_Caption())
     {
      ::Print(__FUNCTION__," > Failed to create the labels of the caption!");
      return(false);
     }
    this.UpdateStatusBar_SymbolSpread();
    this.UpdateStatusBar_Equity();
    this.UpdateStatusBar_MarginLevel();
    this.UpdateStatusBar_BarTime();
    //--- Default to the Trading tab
    m_tabs_main.SelectTab(TAB_TAB_MAIN_TRADING);
    //Create the Add Indicator window (hidden): the tree of the types and the form of the parameters
    Breadcrumb("CreateGUIPannel: CreateWindow_AddIndicator");
    if(!CreateWindow_AddIndicator("Add Indicator",30,30))
     {
      ::Print(__FUNCTION__," > Failed to create the Add Indicator window!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateTreeView_IndicatorTemplateSetting");
    if(!CreateTreeView_IndicatorTemplateSetting(M_CONTROL_BORDER_GAP,PARAM_FORM_Y))
       return(false);
    PopulateTreeView_IndicatorTemplateSetting();
    SyncTreeView_IndicatorTemplateSetting();
    Breadcrumb("CreateGUIPannel: CreateCFrame_IndicatorParameter");
    if(!CreateCFrame_IndicatorParameter(PARAM_FORM_X,PARAM_FORM_Y))
       return(false);
    //Create the Candle information popup (hidden): it opens on Shift + hover on a candle, or on a marker
    Breadcrumb("CreateGUIPannel: CreateWindow_CandleInfo");
    if(!CreateWindow_CandleInfo())
     {
      ::Print(__FUNCTION__," > Failed to create the Candle information window!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateButtons_OpenPosition");
    if(!CreateButtons_OpenPosition())
     {
      ::Print(__FUNCTION__," > Failed to create the Open button of the Trading tab!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateSections_TradingRisk");
    if(!CreateSections_TradingRisk())
     {
      ::Print(__FUNCTION__," > Failed to create the settings of the Automation of the Trading tab!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateSections_TradeSelect");
    if(!CreateSections_TradeSelect())
     {
      ::Print(__FUNCTION__," > Failed to create the Manual Entry of the Trading tab!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateButton_TradeManage");
    if(!CreateButton_TradeManage())
     {
      ::Print(__FUNCTION__," > Failed to create the Trade Manage button!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateButton_CloseAllPosition");
    if(!CreateButton_CloseAllPosition())
     {
      ::Print(__FUNCTION__," > Failed to create the Close all positions button!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateWindow_TradeManage");
    if(!CreateWindow_TradeManage("Trade Manage",60,60))
     {
      ::Print(__FUNCTION__," > Failed to create the Trade Manage window!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateWindow_OrderDetail");
    if(!CreateWindow_OrderDetail("Order detail",90,90))
     {
      ::Print(__FUNCTION__," > Failed to create the Order detail window!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: m_window_main.Show");
    m_window_main.Show();
    ::ChartRedraw(this.m_chart_id);
    Breadcrumb("CreateGUIPannel: done");
    return(true);
  }
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CGUIPannel::CGUIPannel(void) : m_manual_order_type(0),
                                m_SymbolsCollection(NULL),
                                m_HistoryCollection(NULL),
                                m_TradingControl(NULL),
                                m_AccountsCollection(NULL),
                                m_MarketCollection(NULL),
                                m_SymbolTFManager(NULL),
                                m_IndicatorTemplateManager(NULL),
                                m_BarInformationManager(NULL),
                                m_StrategyManager(NULL),
                                m_BarMarkerCollection(NULL),
                                m_GraphElementsCollection(NULL),
                                m_candle_info_shown_bar(0),
                                m_candle_info_last_bar(0),
                                m_candle_info_by_marker(false),
                                m_current_param_type(IND_CUSTOM),
                                m_edit_strategy_id(WRONG_VALUE)
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
     if(!CreateGUIPannel())
        return(false);
     m_first_start=false;
    }
   else
    {
     this.SyncComboBox_SymbolTF();   // the chart moved to another Symbol / TF
     this.BuildTFSwitchButtons();
     this.RebuildRows_Strategy();           // the TFs of the slots: the ones of the chart's Symbol
     this.SyncTreeView_SymbolTFSetting();   // the chart's own Symbol and TF are the active ones
     this.SyncTable_SymbolTFSetting();      // the row of the chart's own pair has the start icon, the others the delete icon
     this.UpdateStatusBar_SymbolSpread();
    }
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Tick                                                             |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTickEvent(void)
  {
   if(m_first_start)
      return;
   //--- Change in V5: the spread follows SYMBOL_EVENT_PROPERTY_CHANGED of the chart symbol (OnChartEvent), not every tick
  }
 //+------------------------------------------------------------------+
 //| Timer: every child takes its step                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTimerEvent(void)
  {
   for(int i=0;i<this.ChildrenTotal();i++)
      this.Child(i).OnTimerEvent();
   //--- The time left of the bar is a clock: it follows the timer (drawn only when its text changes)
   if(!m_first_start)
      this.UpdateStatusBar_BarTime();
   //--- The sound waits while the last one plays: a new one would cut it (the pairs close their bar at the same time)
   static uint last_sound=0;
   if(this.m_alert_sound!="" && (last_sound==0 || ::GetTickCount()-last_sound>=ALERT_SOUND_GAP_MS))
     {
      ::PlaySound(this.m_alert_sound);
      this.m_alert_sound="";
      last_sound=::GetTickCount();
     }
  }
 //+------------------------------------------------------------------+
 //| Trade                                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTradeEvent(void)
  {
  }
 //+------------------------------------------------------------------+
 //| Trade transaction                                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTradeTransaction(const MqlTradeTransaction &trans)
  {
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
   //--- The objects of the chart changed (CChartObj: the terminal drew the arrows of a trade, on top of the windows): the shown windows go back on top (V2)
   if(id==CHARTEVENT_CUSTOM+CHART_OBJ_EVENT_OBJECTS_CHANGE)
     {
      for(int i=0;i<this.ChildrenTotal();i++)
        {
         CGElement *window=dynamic_cast<CGElement *>(this.Child(i));
         if(window!=NULL && window.IsVisible())
            window.BringToTop();
        }
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   this.OnEvent_Alert(id,lparam,dparam,sparam);
   //--- The popup of a candle opens on the chart, away from the windows: it hears the event before the filter below
   this.OnEvent_Window_CandleInfo(id,lparam,dparam,sparam);
   //--- The mouse over the chart, away from the windows and with no control focused or pressed, is not for any control: nobody is asked
   if((id==CHARTEVENT_MOUSE_MOVE || id==CHARTEVENT_MOUSE_WHEEL) && !CGElement::MouseBusy())
     {
      int x=(id==CHARTEVENT_MOUSE_MOVE ? (int)lparam : (int)(short)lparam);
      int y=(id==CHARTEVENT_MOUSE_MOVE ? (int)dparam : (int)(short)(lparam>>16));
      bool on_window=false;
      for(int i=0;i<this.ChildrenTotal() && !on_window;i++)
        {
         CGElement *window=dynamic_cast<CGElement *>(this.Child(i));
         on_window=(window!=NULL && window.ContainsPoint(x,y));
        }
      if(!on_window)
        {
         if(id==CHARTEVENT_MOUSE_MOVE)
            CGElement::MouseNotHeard(sparam);
         return;
        }
     }
   for(int i=0;i<this.ChildrenTotal();i++)
      this.Child(i).OnChartEvent(id,lparam,dparam,sparam);
   //--- A trading event (CTradeEvent::SendEvent, lparam = a ticket): the tables of the Trade Manage window show it
   if(id>CHARTEVENT_CUSTOM+TRADE_EVENT_NO_EVENT && id<CHARTEVENT_CUSTOM+TRADE_EVENTS_NEXT_CODE)
     {
      this.RefreshTables_TradeManage();
      this.UpdateCaption_Position();
      return;
     }
   //--- A property of the account changed (CAccount::SendChanges: the key = the property, the side = up / down)
   if(id==CHARTEVENT_CUSTOM+ACCOUNT_EVENT_PROPERTY_CHANGED)
     {
      datetime time;
      long property;
      ENUM_SIGNAL_DIRECTION side;
      bool is_new;
      this.EventUnpack(lparam,time,property,side,is_new);
      if(property==ACCOUNT_PROP_PROFIT)        // the caption follows, the numbers of the positions with it; the Open tab its Price and Profit
        {
         this.UpdateCaption_Position();
         if(m_window_tradeManage.IsVisible())
            this.FillTable_TradeManagerPosition();
        }
      else if(property==ACCOUNT_PROP_EQUITY)   // the arrow follows the side
         this.UpdateStatusBar_Equity(side);
      else if(property==ACCOUNT_PROP_BALANCE)  // a position closed into the balance can leave the equity as it was: the status bar looks again whether it is flat
         this.UpdateStatusBar_Equity();
      else if(property==ACCOUNT_PROP_MARGIN || property==ACCOUNT_PROP_MARGIN_LEVEL)   // a position opened / closed: the margin level
         this.UpdateStatusBar_MarginLevel();
      return;
     }
   //--- MarginLevelSafe / MarginLevelDanger changed (the tab Risk): the colour of the margin level follows
   if(id==CHARTEVENT_CUSTOM+RISK_SETTING_EVENT_CHANGED && (sparam=="MarginLevelSafe" || sparam=="MarginLevelDanger"))
      this.UpdateStatusBar_MarginLevel();
   //--- New in V5: the spread of the chart symbol changed (CSymbol::RefreshTick)
   if(id==CHARTEVENT_CUSTOM+SYMBOL_EVENT_PROPERTY_CHANGED && sparam==::Symbol())
     {
      datetime time;
      long property;
      ENUM_SIGNAL_DIRECTION side;
      bool is_new;
      this.EventUnpack(lparam,time,property,side,is_new);
      if(property==SYMBOL_PROP_SPREAD)
         this.UpdateStatusBar_SymbolSpread();
      return;
     }
   //--- A Symbol picked in the combobox of the caption: the manager tells the EA, the EA moves the chart, the TF stays
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_COMBOBOX_ITEM && lparam==m_combobox_SymbolTF.ObjectID() && m_SymbolTFManager!=NULL && m_SymbolsCollection!=NULL)
     {
      CSymbol *symbol=m_SymbolsCollection.GetList().At((int)dparam);
      if(symbol!=NULL && symbol.Name()!=::Symbol())
         m_SymbolTFManager.Update_SymbolTF_Setting(symbol.Name(),(ENUM_TIMEFRAMES)::Period(),SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED);
      return;
     }
   //--- A TF picked in the TF switch: the same, the Symbol stays
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_GROUP_BUTTON && lparam==m_btngroup_tf_switch.ObjectID() && m_SymbolTFManager!=NULL)
     {
      ENUM_TIMEFRAMES tf=GetTFSwitchSelection();   // "All" = PERIOD_CURRENT: the chart stays
      if(tf!=PERIOD_CURRENT && tf!=(ENUM_TIMEFRAMES)::Period())
         m_SymbolTFManager.Update_SymbolTF_Setting(::Symbol(),tf,SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED);
      return;
     }
   this.OnEvent_Window_AddIndicator(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Trading(id,lparam,dparam,sparam);
   this.OnEvent_Window_TradeManage(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Indicator(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Candle(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Strategy(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Risk(id,lparam,dparam,sparam);
   this.OnEvent_Tab_SymbolTF(id,lparam,dparam,sparam);
   //--- The window changed its width (border, full screen): the combobox stays next to the caption buttons
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CHANGE_XSIZE && lparam==m_window_main.ObjectID())
     {
      this.ArrangeComboBox_SymbolTF();
      this.ArrangeStatusBar();
     }
   //--- Collapsed: only the numbers of the positions; expanded: the profit too (Expand shows every child again: the hidden ones are hidden again)
   if((id==CHARTEVENT_CUSTOM+WINDOW_EVENT_COLLAPSE || id==CHARTEVENT_CUSTOM+WINDOW_EVENT_EXPAND) && lparam==m_window_main.ObjectID())
      this.UpdateCaption_Position();
   //--- The tracked pairs changed: the TF switch follows; a symbol came to the Market Watch (V3): the combobox lists it too
   if(!m_first_start && (id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE))
      this.BuildTFSwitchButtons();
   if(!m_first_start && id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_ADD)
      this.SyncComboBox_SymbolTF();
  }
#endif // __GUIPANNEL_LIFECYCLE_MQH__
