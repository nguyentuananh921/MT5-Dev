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
    //--- Add a window pointer to the window array
      CWndContainer::AddWindow(m_window_main);
    //--- Properties
      m_window_main.XSize(M_WINDOW_MAIN_WIDTH);
      m_window_main.YSize(M_WINDOW_MAIN_HEIGHT);
      m_window_main.FontSize(9);
      m_window_main.IsMovable(true);
      m_window_main.ResizeMode(true);
      m_window_main.CloseButtonIsUsed(true);
      m_window_main.CollapseButtonIsUsed(true);
      m_window_main.TooltipsButtonIsUsed(true);
      m_window_main.FullscreenButtonIsUsed(true);
      // Allow shrinking horizontally down to 300px and vertically down to 200px
      m_window_main.MinimumXSize(M_WINDOW_MIN_WIDTH);
      m_window_main.MinimumYSize(M_WINDOW_MIN_HEIGHT);
    //--- Set the tooltips
      m_window_main.GetCloseButtonPointer().Tooltip("Close");
      m_window_main.GetTooltipButtonPointer().Tooltip("Tooltips");
      m_window_main.GetFullscreenButtonPointer().Tooltip("Fullscreen");
      m_window_main.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
    //--- Create the form default ENUM_WINDOW_TYPE W_MAIN
      if (!m_window_main.CreateWindow(m_chart_id, m_subwin, caption_text, x_gap, y_gap))
         return (false);
   return (true);
  }
 // For Status Bar at bottom of m_window_main
  //+------------------------------------------------------------------+
  //| Creates the status bar                                           |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateStatusBar(const int x_gap, const int y_gap)
   {
     //--- Store the window pointer
      m_status_bar.MainPointer(m_window_main);
     //--- Properties
      m_status_bar.AutoXResizeMode(true);
      m_status_bar.AutoXResizeRightOffset(1);
      m_status_bar.AnchorBottomWindowSide(true);
     //--- Specify the number of parts and set their properties
      int width[STATUS_LABELS_TOTAL] = {0, 200, 160, 120};
      for (int i = 0; i < STATUS_LABELS_TOTAL; i++)
         m_status_bar.AddItem("", width[i]);
     //--- Create a control element
      if (!m_status_bar.CreateStatusBar(x_gap, y_gap))
         return (false);
     //--- Set text to the items of the status bar
      m_status_bar.SetValue(STATUS_BAR_HELP, "For Help, press F1");
     //--- Setup icons for Deposit Load item (arrow up=high load, gray=medium, arrow down=low)
     //--- Same icon set as m_table_indicator_SymbolTFValue's own val_img (Anhnt, 2026-07-19 -
     //--- unify look across the panel instead of the plain ARROW_UP/DOWN pair used before).
      CTextLabel *deposit_item = m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD);
      deposit_item.AddImagesGroup(2, 6); // x_gap=2, y_gap=6
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
      deposit_item.ChangeImage(0, 2); // default: gray
      deposit_item.LabelXGap(22);     // shift text right for icon (16px ICONS8 icon at x=2, same 22px clearance as m_table_indicator_SymbolTFValue's val_img)
     //--- Setup icons for Profit item (arrow up=profit, arrow down=loss, gray=zero)
      CTextLabel *profit_item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
      profit_item.AddImagesGroup(2, 6); // x_gap=2, y_gap=6
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
      profit_item.ChangeImage(0, 2); // default: gray
      profit_item.LabelXGap(22);     // shift text right for icon (16px ICONS8 icon at x=2, same 22px clearance as m_table_indicator_SymbolTFValue's val_img)
     //--- Add the object to the common array of object groups      
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_status_bar);
      return (true);
   }  
  // Update Status Bar - ported from V1 (Anatoli Kazharski\GUIPannel.mqh); V7 kept the item
  // creation/icons above but dropped both this function AND its OnTickEvent call site along
  // the way - restored here, same call site as V1 (see OnTickEvent below).
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
    //--- GetPositionList() with no args = every Symbol/every Direction (Anhnt/Claude, 2026-09-13).
     double profit_val = (m_market_collection != NULL)
       ? m_market_collection.SumFloatingProfit(m_market_collection.GetPositionList())
       : ::AccountInfoDouble(ACCOUNT_PROFIT);
    string new_deposit = "Deposit load: " + ::DoubleToString(deposit_val, 2) + "/" +
                          ::DoubleToString(deposit_pct, 2) + "%";
    string new_time = ::TimeToString(::TimeTradeServer(), TIME_DATE | TIME_SECONDS);
    string new_profit = "Profit: " + ::DoubleToString(profit_val, 2);
    // Check if values changed, if changed, update the status bar item and redraw it. Only update when value changes to reduce CPU usage.
     bool any_changed = false;
     if (new_deposit != s_deposit)
      {
       int img = (s_deposit == "") ? 2 : (deposit_val > s_deposit_val) ? 0
                                       : (deposit_val < s_deposit_val)   ? 1
                                                                      : 2;
        s_deposit_val = deposit_val;
        s_deposit = new_deposit;
        CTextLabel *item = m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD);
        item.ChangeImage(0, img);
        m_status_bar.SetValue(STATUS_BAR_DEPOSIT_LOAD, new_deposit);
        item.Draw();
        item.Update(false);
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
       CTextLabel *item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
       item.ChangeImage(0, img);
       item.LabelColor(clr);
       m_status_bar.SetValue(STATUS_BAR_PROFIT, new_profit);
       item.Draw();
       item.Update(false);
       any_changed = true;
      }
      if (new_time != s_time)
       {
        s_time = new_time;
        m_status_bar.SetValue(STATUS_BAR_SERVER_TIME, new_time);
        m_status_bar.GetItemPointer(STATUS_BAR_SERVER_TIME).Draw();
        m_status_bar.GetItemPointer(STATUS_BAR_SERVER_TIME).Update(false);
       }
       return any_changed;
   } 
 // For Menu Bar
  bool CGUIPannel::CreateMenuBar(const int x_gap, const int y_gap)
   {
    //--- Store the window pointer
     m_menu_bar.MainPointer(m_window_main);
     m_menu_bar.IsCenterText(false);   
     m_menu_bar.LabelXGap(22);         
    //--- Add items (placeholder text/width 
     m_menu_bar.AddItem(70, "Settings");
    //--- Create a control element
     if(!m_menu_bar.CreateMenuBar(x_gap, y_gap))
       return (false);
     //--- Set icon for the Settings item (IconXGap/IconYGap Library đã tự set =3/4 bên trong CreateItems())
       CMenuItem *settings_item = m_menu_bar.GetItemPointer(MENU_ITEM_SETTINGS);
       settings_item.IconFile(IMAGE_RESOURCE_BMP16_SETTING_PNG);
    //--- Register m_menu_bar NOW (not at the end) - CElement::CheckMainPointer() stamps every new
    //--- element's Id() as "owning window's LastId()+1", and LastId() only changes on an
    //--- AddToElementsArray() call. With nothing in between, settings_item and the dropdown's own
    //--- "Indicator" item (both Index()==0, one per container) computed the SAME Id and therefore
    //--- the SAME chart object name (ElementName() = name_part+"_"+Index()+"__"+Id()) - "Indicator"
    //--- silently reused/overwrote Settings' own canvas. Bumping LastId() here, before the dropdown
    //--- items get created below, gives them a different Id and therefore a different name.
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_menu_bar);
     //--- Dropdown for "Settings": Indicator / Trading / Alert (only now that settings_item is real)
       m_contextmenu_settings.MainPointer(m_menu_bar);
       m_contextmenu_settings.PrevNodePointer(*settings_item);
       m_contextmenu_settings.XSize(100);
       m_contextmenu_settings.FixSide(FIX_BOTTOM);
       m_contextmenu_settings.AddItem("Indicator", IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_OFF_PNG, MI_SIMPLE);
       m_contextmenu_settings.AddItem("Trading",   IMAGE_RESOURCE_BMP16_TRADE_ON_PNG, IMAGE_RESOURCE_BMP16_TRADING_OFF_PNG, MI_SIMPLE);
       m_contextmenu_settings.AddItem("Alert",     IMAGE_RESOURCE_BMP16_ALERT_ON_PNG, IMAGE_RESOURCE_BMP16_ALERT_OFF_PNG, MI_SIMPLE);
       bool created_contextmenu_settings = m_contextmenu_settings.CreateContextMenu();
       if(!created_contextmenu_settings) return false;
       m_contextmenu_settings.Hide();
       m_menu_bar.AddContextMenuPointer(MENU_ITEM_SETTINGS, m_contextmenu_settings);
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_contextmenu_settings);
      return (true);
   }
 // For Main Tabs m_tabs_main on the right of Main Window m_window_main  
  bool CGUIPannel::CreateTab_Main(const int x_gap, const int y_gap)
   {      
    string tabs_names[TAB_TAB_MAIN_TOTAL] = {"Account infor", "Symbol Info", "Monitor", "Trading", "History"};    
    //--- Store the pointer to the main control
     m_tabs_main.MainPointer(m_window_main);
    //--- Properties
     m_tabs_main.IsCenterText(true);
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
     if (!m_tabs_main.CreateTabs(x_gap, y_gap))
       return (false);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_tabs_main);
    return (true);
   }  
 void CGUIPannel::OnEvent_Window_Main(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //Handle for Menu Item click
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CONTEXTMENU_ITEM)
     {
      if((int)dparam == MENU_ITEM_SETTINGS_INDICATOR)
         OpenWindow_SettingTimeSeries();
      else if((int)dparam == MENU_ITEM_SETTINGS_TRADING)
         OpenWindow_SettingTrading();
      else if((int)dparam == MENU_ITEM_SETTINGS_ALERT)
         OpenWindow_SettingMarkerAndSound();
      return;
     }
   //--- Handle m_table_positions_StoplostAndTrailling SLTYPE/TRAILTYPE clicks (Anhnt, 2026-09-10) -
   //--- both pure icon toggles now. RUN_SL/RUN_TRAIL stay read-only status-only CELL_BUTTON.
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
       && lparam == m_table_positions_StoplostAndTrailling.Id())
     {
      string parts[];
      if(StringSplit(sparam, '_', parts) != 2) return;
      int col = (int)StringToInteger(parts[0]);
      int row = (int)StringToInteger(parts[1]);
      if(col == COL_PST_SLTYPE) OnClickTogglePositionSLType(row);
      else if(col == COL_PST_TRAILTYPE) OnClickTogglePositionTrailType(row);
      return;
     }
   //Handle m_table_position_pretrade_view's shared combobox cell committing a new pick (Anhnt,
   //2026-09-10) - COL_PTV_SYMBOL and COL_PTV_LOT are BOTH CELL_COMBOBOX now, sharing this one
   //commit event (the embedded-CComboBox commit, distinct from a normal standalone combobox's
   //ON_CHANGE_GUI). lparam equals the TABLE's own Id() (the Library's per-cell combobox widget
   //shares the table's id, since it's constructed inside CTable::Create() before the table itself
   //gets registered as a main element - see Table.mqh CreateCombobox/OnClickComboboxItem). sparam/
   //dparam carry nothing useful, but CWndEvents::CheckElementsEvents() already ran the Table's own
   //OnEvent (which commits the pick via SetValue) before this app-level hook fires, so
   //OnSymbolToTradeChanged() reading the cell back is always fresh; its own guard tells a genuine
   //Symbol pick apart from a Lot pick and no-ops on the latter.
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM && lparam == m_table_position_pretrade_view.Id())
     {
      OnSymbolToTradeChanged();
      return;
     }
   //Handle CSymbolTFManager's own active-Symbol-change events (Anhnt, 2026-09-10 - "Nếu cậu dùng
   //Event thì khỏi phải mất công cache thôi mà") - fires whenever the chart's active Symbol genuinely
   //changes, from ANY source (this combobox, TreeView, or a native chart symbol switch), not just a
   //pick here - re-syncs m_table_position_pretrade_view so its "active chart" icon (COL_PTV_SYMBOL)
   //re-evaluates against the NOW-current ::Symbol() right when it's known to matter, no per-tick
   //polling/cached s_active_old needed.
    if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED ||
       id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)
     {
      SyncTable_PositionPretradeView(true);
      return;
     }
   //Handle account-state trade events (Anhnt, 2026-09-11 - "phải được Update mỗi khi send lệnh
   //mới, Balance Update... có trong EventDefines.mqh rồi") - a new Position (margin used) or a
   //Balance refill/withdrawal both change CalcMaxLotByRisk's own max_lot, so the Lot combobox's
   //enabled/disabled state and choice list go stale otherwise until the next Symbol/Direction/Risk
   //change forces a rebuild.
    if(id == CHARTEVENT_CUSTOM + TRADE_EVENT_POSITION_OPENED ||
       id == CHARTEVENT_CUSTOM + TRADE_EVENT_ACCOUNT_BALANCE_REFILL ||
       id == CHARTEVENT_CUSTOM + TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL)
     {
      SyncTable_PositionPretradeView(true);
      return;
     }
   //Handle m_table_position_pretrade_view Direction/SLType/TrailType icon clicks (Anhnt, 2026-09-10) -
   //toggle Buy/Sell, StopLost Fixed/Indicator, Trailing Fixed/Indicator respectively. Same dual
   //ON_CLICK_BUTTON/ON_CLICK_CHECKBOX check every other checkbox-cell table in this codebase uses.
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
       && lparam == m_table_position_pretrade_view.Id())
     {
      string parts[];
      if(StringSplit(sparam, '_', parts) != 2) return;
      int col = (int)StringToInteger(parts[0]);
      if(col == COL_PTV_DIR) OnClickTogglePretradeDirection();
      else if(col == COL_PTV_SLTYPE) OnClickTogglePretradeSLType();
      else if(col == COL_PTV_TRAILTYPE) OnClickTogglePretradeTrailType();
      return;
     }
   //Handle m_btn_send_toTrade click (Anhnt, 2026-09-10) - places the New Order form's trade.
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_send_toTrade.Id())
     {
      OnClickSendNewOrder();
      return;
     }
   //Handle Run SL/Run Trailing checkbox click (New Order form) - standalone CCheckBox fires
   //ON_CLICK_CHECKBOX with lparam=Id() (CheckBox.mqh:155), not ON_CLICK_BUTTON.
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX &&
       (lparam == m_checkbox_use_StopLostSetting.Id() || lparam == m_checkbox_use_TrailingSetting.Id()))
     {
      OnClickRunSLOrTrailingCheckbox(lparam);
      return;
     }
   //Handle m_btn_open_StopLostSetting/m_btn_open_TrailingSetting click - opens m_window_setting_trading
   //on the matching tab.
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON &&
       (lparam == m_btn_open_StopLostSetting.Id() || lparam == m_btn_open_TrailingSetting.Id()))
     {
      OnClickOpenTradingSettingTab(lparam == m_btn_open_StopLostSetting.Id() ? ENUM_TAB_SETTING_TRADING_STOPLOST : ENUM_TAB_SETTING_TRADING_TRAILLING);
      return;
     }
   //Handle "Use RPT %" checkbox click (New Order form) - toggles m_edit_RiskPerNewTrade's
   //visibility (Anhnt, 2026-09-10).
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_checkbox_use_RiskPerNewTrade.Id())
     {
      OnClickUseRiskPerNewTradeCheckbox();
      return;
     }
   //--- m_table_indicator_PreTradeSymbolMonitor's StopLost/Trailing columns are still read-only
   //--- (Anhnt, 2026-09-10) - just markers, changed only via the gear-icon buttons' Setting popup.
   //--- Col0 (TF) is NOT read-only though (Anhnt/Claude, 2026-09-15) - click switches the active
   //--- chart to that row's own (Symbol,TF).
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_table_indicator_PreTradeSymbolMonitor.Id())
     {
      string parts[];
      if(StringSplit(sparam, '_', parts) != 2) return;
      int col = (int)StringToInteger(parts[0]);
      int row = (int)StringToInteger(parts[1]);
      if(col == 0) OnClickNavigateToTF(row);
      return;
     }
  }
#endif // CGUIPANNEL_MAINWINDOWS_MQH
