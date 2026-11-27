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
    //--- Manual first (the Entry by hand, Action in it), then Auto and Risk: CreateSections_TradingRisk fills both (PopulateSections_TradingRisk)
    Breadcrumb("CreateGUIPannel: CreateSections_TradeManualSetup");
    if(!CreateSections_TradeManualSetup())
     {
      ::Print(__FUNCTION__," > Failed to create the manual setup of the Trading tab!");
      return(false);
     }
    Breadcrumb("CreateGUIPannel: CreateSections_TradingRisk");
    if(!CreateSections_TradingRisk())
     {
      ::Print(__FUNCTION__," > Failed to create the Automation ON / OFF of the Trading tab!");
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
    //--- New 2026-11-27: the box of a basket, hidden; the collection gives it the events of the chart (the mouse too)
    Breadcrumb("CreateGUIPannel: m_box_basket");
    if(m_GraphElementsCollection==NULL || !m_box_basket.Create(this.m_chart_id,0,"BoxBasket") || !m_GraphElementsCollection.AddChild(::GetPointer(m_box_basket)))
     {
      ::Print(__FUNCTION__," > Failed to create the box of a basket!");
      return(false);
     }
    m_box_basket.SetManage(true);
    m_box_basket.SetLevels(1);   // one TP for the basket
    m_box_basket.Hide();
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
                               m_order_detail_position(0),
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
                                m_box_basket_symbol(""),
                                m_box_basket_buy(true),
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
     if(m_box_basket_symbol!="")   // Manage of a basket of another symbol moved the chart: its box now
        this.ShowBox_Basket();
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
     {
      if(m_GraphElementsCollection!=NULL)
         m_GraphElementsCollection.DeleteChild(::GetPointer(m_box_basket));   // a member of the panel: not the collection's to delete
      ::ChartRedraw(this.m_chart_id);
     }
  }
 //+------------------------------------------------------------------+
 //| MY DEBUG: the time of each step at a change of the profit         |
 //| (ACCOUNT_PROP_PROFIT), summed and told every 10 s: is it the      |
 //| caption, the buttons of Action or the tables of Trade Manage?     |
 //+------------------------------------------------------------------+
 ulong g_debug_profit_ms=0,g_debug_profit_events=0,g_debug_profit_visible=0;
 ulong g_debug_profit_caption=0,g_debug_profit_action=0,g_debug_profit_position=0,g_debug_profit_basket=0;
 //--- MY DEBUG: the other parts of an account event (2026-11-26: m_GUIPannel 10-15 ms an event outside ACCOUNT_PROP_PROFIT): the steps before the
 //--- children, the children (every window), each property branch; told with the line of the profit
 ulong g_debug_account_events=0,g_debug_account_before=0,g_debug_account_children=0;
 ulong g_debug_account_equity=0,g_debug_account_equity_n=0,g_debug_account_balance=0,g_debug_account_balance_n=0;
 ulong g_debug_account_margin=0,g_debug_account_margin_n=0,g_debug_account_other_n=0;
 //--- MY DEBUG: the whole CGUIPannel::OnChartEvent of a custom event, told when it takes 50 ms or more (opening Trade Manage took 4.6-4.8 s, 2026-11-26)
 #define DEBUG_GUI_SLOW_US  50000
 class CDebugGUIScope
  {
   private:
     ulong             m_start;
     int               m_id;
     string            m_sparam;
   public:
                       CDebugGUIScope(const int id,const string sparam) : m_start(::GetMicrosecondCount()),m_id(id),m_sparam(sparam) {}
                      ~CDebugGUIScope(void)
                        {
                         const ulong spent=::GetMicrosecondCount()-this.m_start;
                         if(this.m_id>=CHARTEVENT_CUSTOM && spent>=DEBUG_GUI_SLOW_US)
                            ::Print("MY DEBUG CGUIPannel::OnChartEvent: custom ",this.m_id-CHARTEVENT_CUSTOM," ",this.m_sparam," took ",spent/1000," ms in all");
                        }
  };
 void DebugProfitStep(const ulong caption_us,const ulong action_us,const ulong position_us,const ulong basket_us,const bool visible)
  {
   g_debug_profit_events++;
   g_debug_profit_visible+=(visible ? 1 : 0);
   g_debug_profit_caption+=caption_us;
   g_debug_profit_action+=action_us;
   g_debug_profit_position+=position_us;
   g_debug_profit_basket+=basket_us;
   const ulong now=::GetTickCount64();
   if(g_debug_profit_ms==0)
      g_debug_profit_ms=now;
   if(now-g_debug_profit_ms<10000)
      return;
   ::Print("MY DEBUG CGUIPannel::OnChartEvent ACCOUNT_PROP_PROFIT: ",g_debug_profit_events," events (Trade Manage shown at ",g_debug_profit_visible,"), positions ",::PositionsTotal(),
           ": UpdateCaption_Position ",::DoubleToString(g_debug_profit_caption/1000.0,1)," ms, SyncButtons_Action ",::DoubleToString(g_debug_profit_action/1000.0,1),
           " ms, FillTable_TradeManagerPosition ",::DoubleToString(g_debug_profit_position/1000.0,1)," ms, FillTable_TradeManagerOpenPositionByBasket ",
           ::DoubleToString(g_debug_profit_basket/1000.0,1)," ms");
   ::Print("MY DEBUG CGUIPannel::OnChartEvent ACCOUNT_EVENT_PROPERTY_CHANGED: ",g_debug_account_events," events: before the children ",
           ::DoubleToString(g_debug_account_before/1000.0,1)," ms, the children ",::DoubleToString(g_debug_account_children/1000.0,1)," ms, EQUITY x",
           g_debug_account_equity_n," ",::DoubleToString(g_debug_account_equity/1000.0,1)," ms, BALANCE x",g_debug_account_balance_n," ",
           ::DoubleToString(g_debug_account_balance/1000.0,1)," ms, MARGIN / MARGIN_LEVEL x",g_debug_account_margin_n," ",
           ::DoubleToString(g_debug_account_margin/1000.0,1)," ms, other properties x",g_debug_account_other_n);
   g_debug_account_events=0;
   g_debug_account_before=0;
   g_debug_account_children=0;
   g_debug_account_equity=0;
   g_debug_account_equity_n=0;
   g_debug_account_balance=0;
   g_debug_account_balance_n=0;
   g_debug_account_margin=0;
   g_debug_account_margin_n=0;
   g_debug_account_other_n=0;
   g_debug_profit_ms=now;
   g_debug_profit_events=0;
   g_debug_profit_visible=0;
   g_debug_profit_caption=0;
   g_debug_profit_action=0;
   g_debug_profit_position=0;
   g_debug_profit_basket=0;
  }
 //+------------------------------------------------------------------+
 //| Every child gets the event and handles what is its own           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   CDebugGUIScope debug_scope(id,sparam);   // MY DEBUG: the whole call, told at its end when slow
   const bool debug_account=(id==CHARTEVENT_CUSTOM+ACCOUNT_EVENT_PROPERTY_CHANGED);
   const ulong debug_t0=::GetMicrosecondCount();
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
   const ulong debug_t1=::GetMicrosecondCount();
   if(id>=CHARTEVENT_CUSTOM && debug_t1-debug_t0>=DEBUG_GUI_SLOW_US)
      ::Print("MY DEBUG CGUIPannel::OnChartEvent: custom ",id-CHARTEVENT_CUSTOM," ",sparam," -> OnEvent_Alert + OnEvent_Window_CandleInfo took ",(debug_t1-debug_t0)/1000," ms");
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
     {
      const ulong debug_child=::GetMicrosecondCount();   // MY DEBUG: a window that takes long on a custom event is told
      this.Child(i).OnChartEvent(id,lparam,dparam,sparam);
      const ulong debug_child_us=::GetMicrosecondCount()-debug_child;
      if(id>=CHARTEVENT_CUSTOM && debug_child_us>=DEBUG_GUI_SLOW_US)
         ::Print("MY DEBUG CGUIPannel::OnChartEvent: custom ",id-CHARTEVENT_CUSTOM," ",sparam," -> child ",i," ",this.Child(i).Name()," took ",debug_child_us/1000," ms");
     }
   const ulong debug_t2=::GetMicrosecondCount();
   if(debug_account)
     {
      g_debug_account_events++;
      g_debug_account_before+=debug_t1-debug_t0;
      g_debug_account_children+=debug_t2-debug_t1;
     }
   //--- A trading event (CTradeEvent::SendEvent, lparam = a ticket): the tables of the Trade Manage window show it; the Order detail of that position
   //--- follows it live (the SL / TP changed, a deal), from RAM
   if(id>CHARTEVENT_CUSTOM+TRADE_EVENT_NO_EVENT && id<CHARTEVENT_CUSTOM+TRADE_EVENTS_NEXT_CODE)
     {
      this.RefreshTables_TradeManage();
      this.UpdateCaption_Position();
      this.SyncButtons_Action();   // a position came or went: the groups of Action
      if(m_window_order_detail.IsVisible() && lparam==m_order_detail_position)
        {
         this.FillTable_OrderDetail(m_order_detail_position);
         ::ChartRedraw(this.m_chart_id);
        }
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
      if(property==ACCOUNT_PROP_PROFIT)        // the caption follows, the numbers of the positions with it; the Open and By Basket tabs their Price and Profit
        {
         const ulong debug_t0=::GetMicrosecondCount();   // MY DEBUG: the time of each step at a change of the profit (25-43 ms an event with 11 positions, 2026-11-26)
         this.UpdateCaption_Position();
         const ulong debug_t1=::GetMicrosecondCount();
         this.SyncButtons_Action();             // the floating profit of each group of Action
         const ulong debug_t2=::GetMicrosecondCount();
         ulong debug_t3=debug_t2;
         const bool debug_visible=m_window_tradeManage.IsVisible();
         if(debug_visible)
           {
            this.FillTable_TradeManagerPosition();
            debug_t3=::GetMicrosecondCount();
            this.FillTable_TradeManagerOpenPositionByBasket();
           }
         const ulong debug_t4=::GetMicrosecondCount();
         DebugProfitStep(debug_t1-debug_t0,debug_t2-debug_t1,debug_t3-debug_t2,debug_t4-debug_t3,debug_visible);
        }
      else if(property==ACCOUNT_PROP_EQUITY)   // the arrow follows the side
        {
         const ulong debug_e=::GetMicrosecondCount();   // MY DEBUG
         this.UpdateStatusBar_Equity(side);
         g_debug_account_equity+=::GetMicrosecondCount()-debug_e;
         g_debug_account_equity_n++;
        }
      else if(property==ACCOUNT_PROP_BALANCE)  // a position closed into the balance can leave the equity as it was: the status bar looks again whether it is flat
        {
         const ulong debug_b=::GetMicrosecondCount();   // MY DEBUG
         this.UpdateStatusBar_Equity();
         g_debug_account_balance+=::GetMicrosecondCount()-debug_b;
         g_debug_account_balance_n++;
        }
      else if(property==ACCOUNT_PROP_MARGIN || property==ACCOUNT_PROP_MARGIN_LEVEL)   // a position opened / closed: the margin level
        {
         const ulong debug_m=::GetMicrosecondCount();   // MY DEBUG
         this.UpdateStatusBar_MarginLevel();
         g_debug_account_margin+=::GetMicrosecondCount()-debug_m;
         g_debug_account_margin_n++;
        }
      else
         g_debug_account_other_n++;   // MY DEBUG: a property no branch draws
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
