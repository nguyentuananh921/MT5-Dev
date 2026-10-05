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
 bool CGUIPannel::CreateWindow_Main(const string caption_text,const int x_gap, const int y_gap)
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
      if (!m_window_main.CreateWindow(m_chart_id, m_subwin, caption_text, x_gap, y_gap, M_WINDOW_MAIN_WIDTH, M_WINDOW_MAIN_HEIGHT))
         return (false);
   return (true);
  }
 // For Status Bar at bottom of m_window_main
  //+------------------------------------------------------------------+
  //| Creates the status bar                                           |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateStatusBar(const int x_gap, const int y_gap)
   {
     //--- Specify the number of parts and set their properties
      int width[STATUS_LABELS_TOTAL] = {0, 215, 130, 155};
      for (int i = 0; i < STATUS_LABELS_TOTAL; i++)
         m_status_bar.AddItem("", width[i]);
     //--- Create a control element (follows the window's right and bottom edges)
      m_window_main.AddChild(&m_status_bar);
      if (!m_status_bar.CreateStatusBar(m_chart_id, m_subwin, "StatusBar", x_gap, y_gap, M_WINDOW_MAIN_WIDTH - 2))
         return (false);
     //--- Set text to the items of the status bar
      m_status_bar.SetValue(STATUS_BAR_HELP, "For Help, F1");
     //--- Deposit/Profit icons: arrow up, arrow down, gray (same set as the SymbolTF value table)
      CLabel *deposit_item = m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD);
      deposit_item.AddImagesGroup(2, 3);
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
      deposit_item.ChangeImage(0, 2); // default: gray
      deposit_item.LabelXGap(22);     // text after the 16px icon at x=2
      CLabel *profit_item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
      profit_item.AddImagesGroup(2, 3);
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
      profit_item.ChangeImage(0, 2); // default: gray
      profit_item.LabelXGap(22);
      return (true);
   }
  bool CGUIPannel::UpdateStatusBar(void)
   {
    static string s_deposit = "";
    static string s_time = "";
    static string s_profit = "";
    static double s_deposit_val = 0;
    static double s_profit_val = 0;

    CAccount *acc = (m_accounts_collection != NULL) ? m_accounts_collection.GetCurrentAccount() : NULL;
    double deposit_val = (acc != NULL) ? acc.Margin() : ::AccountInfoDouble(ACCOUNT_MARGIN);
    double deposit_pct = (acc != NULL && acc.Balance() != 0.0) ? (acc.Margin() / acc.Balance() * 100) : 0.0;
    //--- GetPositionList() with no args = every Symbol/every Direction.
     double profit_val = (m_market_collection != NULL)
       ? m_market_collection.SumFloatingProfit(m_market_collection.GetPositionList())
       : ::AccountInfoDouble(ACCOUNT_PROFIT);
    string new_deposit = "Deposit load: " + ::DoubleToString(deposit_val, 2) + "/" +
                          ::DoubleToString(deposit_pct, 2) + "%";
    string new_time = ::TimeToString(::TimeTradeServer(), TIME_DATE | TIME_SECONDS);
    string new_profit = "Profit: " + ::DoubleToString(profit_val, 2);
    // Only redraw the parts whose text changed
     bool any_changed = false;
     if (new_deposit != s_deposit)
      {
       int img = (s_deposit == "") ? 2 : (deposit_val > s_deposit_val) ? 0
                                       : (deposit_val < s_deposit_val)   ? 1
                                                                      : 2;
        s_deposit_val = deposit_val;
        s_deposit = new_deposit;
        m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD).ChangeImage(0, img);
        m_status_bar.SetValue(STATUS_BAR_DEPOSIT_LOAD, new_deposit);
        any_changed = true;
      }
     if (new_profit != s_profit)
      {
       int img = (s_profit == "") ? 2 : (profit_val > s_profit_val) ? 0
                                       : (profit_val < s_profit_val)   ? 1
                                                                      : 2;
       color clr = (profit_val > 0) ? clrGreen : (profit_val < 0) ? clrRed
                                                                    : clrBlack;
       s_profit_val = profit_val;
       s_profit = new_profit;
       CLabel *item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
       item.ChangeImage(0, img);
       item.GetForeColorControl().InitColors(clr, clr, clr, clrGray);
       item.ColorChange(COLOR_STATE_DEFAULT);
       m_status_bar.SetValue(STATUS_BAR_PROFIT, new_profit);
       any_changed = true;
      }
      if (new_time != s_time)
       {
        s_time = new_time;
        m_status_bar.SetValue(STATUS_BAR_SERVER_TIME, new_time);
        any_changed = true;
       }
       return any_changed;
   }
 // For Menu Bar
  bool CGUIPannel::CreateMenuBar(const int x_gap, const int y_gap)
   {
    //--- Add items (placeholder text/width
     m_menu_bar.AddItem(85, "Settings");
     m_menu_bar.AddItem(85, "Trading");
    //--- Create a control element
     m_window_main.AddChild(&m_menu_bar);
     if(!m_menu_bar.CreateMenuBar(m_chart_id, m_subwin, "MenuBar", x_gap, y_gap, M_WINDOW_MAIN_WIDTH - 2))
       return (false);
     //--- Icon for the Settings item, text after it
       CMenuItem *settings_item = m_menu_bar.GetItemPointer(MENU_ITEM_SETTINGS);
       settings_item.IconFile(IMAGE_RESOURCE_BMP16_SETTING_PNG);
       settings_item.LabelXGap(22);
       settings_item.Draw(false);
     //--- Dropdown for "Settings": Indicator / Trading / Alert - child of the item that opens it
       m_contextmenu_settings.FixSide(FIX_BOTTOM);
       m_contextmenu_settings.AddItem("TimeSeries", IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_OFF_PNG, MI_SIMPLE);
       m_contextmenu_settings.AddItem("Trading",   IMAGE_RESOURCE_BMP16_TRADE_ON_PNG, IMAGE_RESOURCE_BMP16_TRADING_OFF_PNG, MI_SIMPLE);
       m_contextmenu_settings.AddItem("Alert",     IMAGE_RESOURCE_BMP16_ALERT_ON_PNG, IMAGE_RESOURCE_BMP16_ALERT_OFF_PNG, MI_SIMPLE);
       settings_item.AddChild(&m_contextmenu_settings);
       if(!m_contextmenu_settings.CreateContextMenu(m_chart_id, m_subwin, "ContextMenuSettings", 120))
          return false;
     //--- "Trading": Stop Lost / Trailling on-off, colored icon = on, gray = off (SyncRunSLTrailingButtonIcons)
       CMenuItem *trading_item = m_menu_bar.GetItemPointer(MENU_ITEM_TRADING);
       trading_item.IconFile(IMAGE_RESOURCE_BMP16_TRADE_ON_PNG);
       trading_item.LabelXGap(22);
       trading_item.Draw(false);
       m_contextmenu_trading.FixSide(FIX_BOTTOM);
       m_contextmenu_trading.AddItem("Stop Lost", IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG, IMAGE_RESOURCE_BMP16_START_GRAY_BMP, MI_SIMPLE);
       m_contextmenu_trading.AddItem("Trailling", IMAGE_RESOURCE_BMP16_TRAILLING_PNG,   IMAGE_RESOURCE_BMP16_START_GRAY_BMP, MI_SIMPLE);
       trading_item.AddChild(&m_contextmenu_trading);
       if(!m_contextmenu_trading.CreateContextMenu(m_chart_id, m_subwin, "ContextMenuTrading", 120))
          return false;
      return (true);
   }
 // For Main Tabs m_tabs_main on the right of Main Window m_window_main
  bool CGUIPannel::CreateTab_Main(const int x_gap, const int y_gap)
   {
    string tabs_names[TAB_TAB_MAIN_TOTAL] = {"Account infor", "Symbol Info", "Trading", "History"};
    //--- Properties
     m_tabs_main.PositionMode(TABS_TOP);
     m_tabs_main.AutoXResizeMode(true);
     m_tabs_main.AutoYResizeMode(true);
     m_tabs_main.AutoXResizeRightOffset(3);
     m_tabs_main.AutoYResizeBottomOffset(25);
    //--- Add tabs with the specified properties
     for (int i = 0; i < TAB_TAB_MAIN_TOTAL; i++)
      {
       m_tabs_main.AddTab(tabs_names[i], 100);
      }
    //--- Create Tab before create other control element inside
     m_window_main.AddChild(&m_tabs_main);
     if (!m_tabs_main.CreateTabs(m_chart_id, m_subwin, "TabsMain", x_gap, y_gap))
       return (false);
    return (true);
   }
 void CGUIPannel::OnEvent_Window_Main(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //Handle for Menu Item click
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CONTEXTMENU_ITEM && lparam == m_contextmenu_settings.ObjectID())
     {
      if((int)dparam == MENU_ITEM_SETTINGS_INDICATOR)
         OpenWindow_SettingTimeSeries();
      else if((int)dparam == MENU_ITEM_SETTINGS_TRADING)
         OpenWindow_SettingTrading();
      else if((int)dparam == MENU_ITEM_SETTINGS_ALERT)
         OpenWindow_SettingMarkerAndSound();
      ::Print("MY DEBUG CGUIPannel::OnEvent_Window_Main: settings menu item=", (int)dparam, " text=", sparam);
      return;
     }
   //--- "Trading" menu: Stop Lost / Trailling on-off of the New Order Symbol
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CONTEXTMENU_ITEM && lparam == m_contextmenu_trading.ObjectID())
     {
      if((int)dparam == MENU_ITEM_TRADING_STOPLOST)
         OnClickToggleSLOrTrailing(true);
      else if((int)dparam == MENU_ITEM_TRADING_TRAILLING)
         OnClickToggleSLOrTrailing(false);
      return;
     }
   //--- Monitor: only the colored SL / Trailling cell opens Setting Trading on its tab, gray cells do nothing
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_LIST_ITEM && lparam == m_table_indicator_PreTradeSymbolMonitor.ObjectID())
     {
      int col, row;
      if(!m_table_indicator_PreTradeSymbolMonitor.CellIndexes(sparam, col, row)) return;
      if((col == 4 || col == 5) && m_table_indicator_PreTradeSymbolMonitor.CellView(col, row).SelectedImage() == 0)
         OnClickOpenTradingSettingTab(col == 4 ? ENUM_TAB_SETTING_TRADING_STOPLOST : ENUM_TAB_SETTING_TRADING_TRAILLING);
      return;
     }
   // Handle m_table_positions_StoplostAndTrailling SLTYPE/TRAILTYPE clicks
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
       && lparam == m_table_positions_StoplostAndTrailling.ObjectID())
     {
      int col, row;
      if(!m_table_positions_StoplostAndTrailling.CellIndexes(sparam, col, row)) return;
      if(col == COL_PST_SLTYPE) OnClickTogglePositionSLType(row);
      else if(col == COL_PST_TRAILTYPE) OnClickTogglePositionTrailType(row);
      return;
     }
   // Handle m_table_position_pretrade_view's shared combobox cell committing a new pick
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM && lparam == m_table_position_pretrade_view.ObjectID())
     {
      OnSymbolToTradeChanged();
      return;
     }
   // Handle the TF switch row (All / M1 / M5 ...)
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_GROUP_BUTTON && lparam == m_btngroup_tf_switch.ObjectID())
     {
      OnClick_CButtonsGroup_TFSwitchButton();
      return;
     }
   // Handle CSymbolTFManager's own active-Symbol-change events
    if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_DELETE ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED ||
       id == CHARTEVENT_CUSTOM + MARKET_WATCH_EVENT_SYMBOL_ADD ||
       id == CHARTEVENT_CUSTOM + MARKET_WATCH_EVENT_SYMBOL_DEL)
     {
      if(SyncComboBox_NewOrderSymbol())
         OnSymbolToTradeChanged(false);
      SyncTable_PositionPretradeView(true);
      Sync_CButtonsGroup_TFSwitchButtons();
      OnClick_CButtonsGroup_TFSwitchButton();
      return;
     }
   // Handle account-state trade events: the Lot combobox's max lot goes stale otherwise
    if(id == CHARTEVENT_CUSTOM + TRADE_EVENT_POSITION_OPENED ||
       id == CHARTEVENT_CUSTOM + TRADE_EVENT_ACCOUNT_BALANCE_REFILL ||
       id == CHARTEVENT_CUSTOM + TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL)
     {
      SyncTable_PositionPretradeView(true);
      return;
     }
   // Handle m_table_position_pretrade_view Direction/SLType/TrailType icon clicks
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
       && lparam == m_table_position_pretrade_view.ObjectID())
     {
      int col, row;
      if(!m_table_position_pretrade_view.CellIndexes(sparam, col, row)) return;
      if(col == COL_PTV_DIR) OnClickTogglePretradeDirection();
      else if(col == COL_PTV_SLTYPE) OnClickTogglePretradeSLType();
      else if(col == COL_PTV_TRAILTYPE) OnClickTogglePretradeTrailType();
      return;
     }
   // Handle m_btn_send_toTrade click - places the New Order form's trade.
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_send_toTrade.ObjectID())
     {
      OnClickSendNewOrder();
      return;
     }   
   // Handle "Use RPT %" checkbox click (New Order form)
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_checkbox_use_RiskPerNewTrade.ObjectID())
     {
      OnClickUseRiskPerNewTradeCheckbox();
      return;
     }   
  }
#endif // CGUIPANNEL_MAINWINDOWS_MQH
