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
    if(!CreateWindow_Main("EA PANEL V4",1,1))
     {
      ::Print(__FUNCTION__," > Failed to create Main Window!");
      return(false);
     }
    //Create Status Bar at the bottom of m_window_main
    Breadcrumb("CreateGUIPannel: CreateStatusBar");
    if(!CreateStatusBar(1,M_WINDOW_MAIN_HEIGHT-M_CONTROL_HEIGHT-1))
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
    Breadcrumb("CreateGUIPannel: CreateButton_TradeManage");
    if(!CreateButton_TradeManage())
     {
      ::Print(__FUNCTION__," > Failed to create the Trade Manage button!");
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
 CGUIPannel::CGUIPannel(void) : m_SymbolsCollection(NULL),
                                m_HistoryCollection(NULL),
                                m_AccountsCollection(NULL),
                                m_MarketCollection(NULL),
                                m_SymbolTFManager(NULL),
                                m_IndicatorTemplateManager(NULL),
                                m_BarInformationManager(NULL),
                                m_BarTimeSeriesCollection(NULL),
                                m_SignalsCollection(NULL),
                                m_GraphElementsCollection(NULL),
                                m_candle_info_shown_bar(0),
                                m_candle_info_last_bar(0),
                                m_candle_info_by_marker(false),
                                m_current_param_type(IND_CUSTOM)
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
   this.UpdateStatusBar_SymbolSpread();
  }
 //+------------------------------------------------------------------+
 //| Timer: every child takes its step                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTimerEvent(void)
  {
   for(int i=0;i<this.ChildrenTotal();i++)
      this.Child(i).OnTimerEvent();
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
   //--- A trading event (CTradeEvent::SendEvent, lparam = a ticket): the tables of the Trade Manage window show it; an account event has the same ids (its source is in lparam)
   if(id>CHARTEVENT_CUSTOM+TRADE_EVENT_NO_EVENT && id<CHARTEVENT_CUSTOM+TRADE_EVENTS_NEXT_CODE && ((lparam>>32)&0xFFFF)!=OBJECT_DE_TYPE_ACCOUNT)
     {
      this.RefreshTables_TradeManage();
      this.UpdateCaption_Position();
      return;
     }
   //--- The floating profit of the account changed (an event at each change, V1): the caption follows, the numbers of the positions with it
   if(id==CHARTEVENT_CUSTOM+ACCOUNT_PROP_PROFIT && ((lparam>>32)&0xFFFF)==OBJECT_DE_TYPE_ACCOUNT)
     {
      this.UpdateCaption_Position();
      return;
     }
   //--- The equity of the account changed (CAccountsCollection::RefreshAccount: id = the property, the reason in the second ushort of lparam,
   //--- the source in the third, as DoEasy: the trading events use the same ids with lparam = ticket)
   if(id==CHARTEVENT_CUSTOM+ACCOUNT_PROP_EQUITY && ((lparam>>32)&0xFFFF)==OBJECT_DE_TYPE_ACCOUNT)
     {
      this.UpdateStatusBar_Equity((int)((lparam>>16)&0xFFFF));
      return;
     }
   //--- A position closed into the balance can leave the equity as it was (no equity event): the status bar looks again whether it is flat
   if(id==CHARTEVENT_CUSTOM+ACCOUNT_PROP_BALANCE && ((lparam>>32)&0xFFFF)==OBJECT_DE_TYPE_ACCOUNT)
     {
      this.UpdateStatusBar_Equity();
      return;
     }
   //--- A Symbol picked in the combobox of the caption: the manager tells the EA, the EA moves the chart, the TF stays
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_COMBOBOX_ITEM && lparam==m_combobox_SymbolTF.ObjectID() && m_SymbolTFManager!=NULL && m_SymbolsCollection!=NULL)
     {
      CSymbol *symbol=m_SymbolsCollection.GetList().At((int)dparam);
      if(symbol!=NULL && symbol.Name()!=::Symbol())
         m_SymbolTFManager.NotifySettingChanged(symbol.Name(),(ENUM_TIMEFRAMES)::Period());
      return;
     }
   //--- A TF picked in the TF switch: the same, the Symbol stays
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_GROUP_BUTTON && lparam==m_btngroup_tf_switch.ObjectID() && m_SymbolTFManager!=NULL)
     {
      ENUM_TIMEFRAMES tf=GetTFSwitchSelection();   // "All" = PERIOD_CURRENT: the chart stays
      if(tf!=PERIOD_CURRENT && tf!=(ENUM_TIMEFRAMES)::Period())
         m_SymbolTFManager.NotifySettingChanged(::Symbol(),tf);
      return;
     }
   this.OnEvent_Window_AddIndicator(id,lparam,dparam,sparam);
   this.OnEvent_Window_TradeManage(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Indicator(id,lparam,dparam,sparam);
   this.OnEvent_Tab_Candle(id,lparam,dparam,sparam);
   this.OnEvent_Tab_SymbolTF(id,lparam,dparam,sparam);
   //--- The window changed its width (border, full screen): the combobox stays next to the caption buttons
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CHANGE_XSIZE && lparam==m_window_main.ObjectID())
      this.ArrangeComboBox_SymbolTF();
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
