//+------------------------------------------------------------------+
//|                                        GUIPannel_MainWindows.mqh |
//|           Implementation of function Main Windows m_window_main  |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_MQH
#define CGUIPANNEL_MAINWINDOWS_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Create Main Window                                               |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateWindow_Main(const string caption_text,const int x_gap,const int y_gap)
  {
   //--- Properties
   m_window_main.FontSize(DEF_FONT_SIZE);
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.CloseButtonIsUsed(true);
   m_window_main.CollapseButtonIsUsed(true);
   m_window_main.TooltipsButtonIsUsed(true);
   m_window_main.FullscreenButtonIsUsed(true);
   // Allow shrinking horizontally down to 300px and vertically down to 200px
   m_window_main.MinimumXSize(M_WINDOW_MIN_WIDTH);
   m_window_main.MinimumYSize(M_WINDOW_MIN_HEIGHT);
   //--- Create the form default ENUM_WINDOW_TYPE W_MAIN
   if(!m_window_main.CreateWindow(m_chart_id,m_subwin,caption_text,x_gap,y_gap,M_WINDOW_MAIN_WIDTH,M_WINDOW_MAIN_HEIGHT))
      return(false);
   return(true);
  }
 // For Status Bar at bottom of m_window_main
 //+------------------------------------------------------------------+
 //| Creates the status bar                                           |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateStatusBar(const int x_gap,const int y_gap)
  {
   //--- Specify the number of parts and set their properties
   int width[STATUS_LABELS_TOTAL]={0,155};
   for(int i=0;i<STATUS_LABELS_TOTAL;i++)
      m_status_bar.AddItem("",width[i]);
   //--- Create a control element (follows the window's right and bottom edges)
   m_window_main.AddChild(&m_status_bar);
   if(!m_status_bar.CreateStatusBar(m_chart_id,m_subwin,"StatusBar",x_gap,y_gap,M_WINDOW_MAIN_WIDTH-2))
      return(false);
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Server time: true when the text changed                          |
 //+------------------------------------------------------------------+
 bool CGUIPannel::UpdateStatusBar(void)
  {
   static string s_time="";
   string new_time=::TimeToString(::TimeTradeServer(),TIME_DATE|TIME_SECONDS);
   if(new_time==s_time)
      return(false);
   s_time=new_time;
   m_status_bar.SetValue(STATUS_BAR_SERVER_TIME,new_time);
   return(true);
  }
 // For Menu Bar
 bool CGUIPannel::CreateMenuBar(const int x_gap,const int y_gap)
  {
   //--- Add items (placeholder text/width
   m_menu_bar.AddItem(85,"Settings");
   m_menu_bar.AddItem(85,"Help");
   //--- Create a control element
   m_window_main.AddChild(&m_menu_bar);
   if(!m_menu_bar.CreateMenuBar(m_chart_id,m_subwin,"MenuBar",x_gap,y_gap,M_WINDOW_MAIN_WIDTH-2))
      return(false);
   //--- Icon for the Settings item, text after it
   CMenuItem *settings_item=m_menu_bar.GetItemPointer(MENU_ITEM_SETTINGS);
   settings_item.IconFile(IMAGE_RESOURCE_BMP16_SETTING_PNG);
   settings_item.LabelXGap(22);
   settings_item.Draw(false);
   CMenuItem *help_item=m_menu_bar.GetItemPointer(MENU_ITEM_HELP);
   help_item.IconFile(IMAGE_RESOURCE_BMP16_HELP_DARK_BMP);
   help_item.LabelXGap(22);
   help_item.Draw(false);
   //--- Dropdown for "Settings": Indicator / Trading / Alert - child of the item that opens it
   m_contextmenu_settings.FixSide(FIX_BOTTOM);
   m_contextmenu_settings.AddItem("TimeSeries",IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG,IMAGE_RESOURCE_BMP16_INDICATOR_OFF_PNG,MI_SIMPLE);
   m_contextmenu_settings.AddItem("Trading",IMAGE_RESOURCE_BMP16_TRADE_ON_PNG,IMAGE_RESOURCE_BMP16_TRADING_OFF_PNG,MI_SIMPLE);
   m_contextmenu_settings.AddItem("Alert",IMAGE_RESOURCE_BMP16_ALERT_ON_PNG,IMAGE_RESOURCE_BMP16_ALERT_OFF_PNG,MI_SIMPLE);
   settings_item.AddChild(&m_contextmenu_settings);
   if(!m_contextmenu_settings.CreateContextMenu(m_chart_id,m_subwin,"ContextMenuSettings",120))
      return(false);
   return(true);
  }
 // For Main Tabs m_tabs_main on the right of Main Window m_window_main
 bool CGUIPannel::CreateTab_Main(const int x_gap,const int y_gap)
  {
   string tabs_names[TAB_TAB_MAIN_TOTAL]={"Account infor","Symbol Info","Trading","History"};
   //--- Properties
   m_tabs_main.PositionMode(TABS_TOP);
   m_tabs_main.AutoXResizeMode(true);
   m_tabs_main.AutoYResizeMode(true);
   m_tabs_main.AutoXResizeRightOffset(3);
   m_tabs_main.AutoYResizeBottomOffset(25);
   //--- Add tabs with the specified properties
   for(int i=0;i<TAB_TAB_MAIN_TOTAL;i++)
      m_tabs_main.AddTab(tabs_names[i],100);
   //--- Create Tab before create other control element inside
   m_window_main.AddChild(&m_tabs_main);
   if(!m_tabs_main.CreateTabs(m_chart_id,m_subwin,"TabsMain",x_gap,y_gap))
      return(false);
   return(true);
  }
 //+------------------------------------------------------------------+
 //| What the user did in the main window                             |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_Main(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //Handle for Menu Item click: the setting windows are brought over one at a time
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CONTEXTMENU_ITEM && lparam==m_contextmenu_settings.ObjectID())
     {
      if((int)dparam==MENU_ITEM_SETTINGS_INDICATOR)
         this.OpenWindow_SettingTimeSeries();
      else if((int)dparam==MENU_ITEM_SETTINGS_ALERT)
         this.OpenWindow_SettingMarkerAndSound();
      return;
     }
   //--- Monitor: the colored SL / trailing cell would open the trading setting; it is not ported yet
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM && lparam==m_table_indicator_PreTradeSymbolMonitor.ObjectID())
     {
      int col,row;
      if(m_table_indicator_PreTradeSymbolMonitor.CellIndexes(sparam,col,row) && (col==4 || col==5))
         ::Print("MY DEBUG CGUIPannel::OnEvent_Window_Main: open the ",(col==4 ? "stop loss" : "trailing")," setting, row ",row);   //Print Debug
      return;
     }
   //--- The New Order Symbol picked in the combobox cell
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM && lparam==m_table_position_pretrade_view.ObjectID())
     {
      OnSymbolToTradeChanged();
      return;
     }
   //--- The TF switch row (All / M1 / M5 ...)
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON && lparam==m_btngroup_tf_switch.ObjectID())
     {
      OnClick_CButtonsGroup_TFSwitchButton();
      return;
     }
   //--- The tracked pairs or the Market Watch changed: the Symbol list and the TF buttons follow
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE ||
      id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED ||
      id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_ADD || id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_DEL)
     {
      if(!m_gui_created)
         return;
      if(SyncComboBox_NewOrderSymbol())
         OnSymbolToTradeChanged(false);
      SyncTable_PositionPretradeView(true);
      Sync_CButtonsGroup_TFSwitchButtons();
      OnClick_CButtonsGroup_TFSwitchButton();
      return;
     }
   //--- New Order: Direction / stop loss / trailing icons of the pre-trade table
   if((id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON || id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX) && lparam==m_table_position_pretrade_view.ObjectID())
     {
      int col,row;
      if(!m_table_position_pretrade_view.CellIndexes(sparam,col,row))
         return;
      if(col==COL_PTV_DIR)
         OnClickTogglePretradeDirection();
      else if(col==COL_PTV_SLTYPE)
         OnClickTogglePretradeSLType();
      else if(col==COL_PTV_TRAILTYPE)
         OnClickTogglePretradeTrailType();
      return;
     }
   //--- The Buy / Sell button and the "Use RPT %" checkbox
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_send_toTrade.ObjectID())
     {
      OnClickSendNewOrder();
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_checkbox_use_RiskPerNewTrade.ObjectID())
     {
      OnClickUseRiskPerNewTradeCheckbox();
      return;
     }
   //--- The position table: the stop loss / trailing icons come with the trading engine
   if((id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON || id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX) && lparam==m_table_positions_StoplostAndTrailling.ObjectID())
     {
      int col,row;
      if(m_table_positions_StoplostAndTrailling.CellIndexes(sparam,col,row))
         ::Print("MY DEBUG CGUIPannel::OnEvent_Window_Main: positions table click col ",col," row ",row);   //Print Debug
      return;
     }
  }
#endif // CGUIPANNEL_MAINWINDOWS_MQH
