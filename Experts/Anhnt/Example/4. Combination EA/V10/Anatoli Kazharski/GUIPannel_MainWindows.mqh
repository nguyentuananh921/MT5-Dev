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

    CAccount *acc = (m_tradingEngine != NULL) ? m_tradingEngine.GetCurrentAccount() : NULL;
    double deposit_val = (acc != NULL) ? acc.Margin() : ::AccountInfoDouble(ACCOUNT_MARGIN);
    double deposit_pct = (acc != NULL && acc.Balance() != 0.0) ? (acc.Margin() / acc.Balance() * 100) : 0.0;
    double profit_val = (m_tradingEngine != NULL) ? m_tradingEngine.CalcProfit() : ::AccountInfoDouble(ACCOUNT_PROFIT);
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
       ::Print("MY DEBUG CGUIPannel::CreateMenuBar: settings_item X=", settings_item.X(),
               " Y=", settings_item.Y(), " XSize=", settings_item.XSize(), " YSize=", settings_item.YSize(),
               " LabelText=", settings_item.LabelText(), " IsVisible=", settings_item.IsVisible());
       ::Print("MY DEBUG CGUIPannel::CreateMenuBar: BEFORE dropdown creation - m_window_main.Id()=", m_window_main.Id(),
               " m_menu_bar.Id()=", m_menu_bar.Id(), " settings_item.Id()=", settings_item.Id(),
               " settings_item.Index()=", settings_item.Index(), " m_contextmenu_settings.Id()=", m_contextmenu_settings.Id(),
               " m_contextmenu_settings.Index()=", m_contextmenu_settings.Index());
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
       ::Print("MY DEBUG CGUIPannel::CreateMenuBar: CreateContextMenu returned=", created_contextmenu_settings);
       if(!created_contextmenu_settings) return false;
       ::Print("MY DEBUG CGUIPannel::CreateMenuBar: dropdown X=", m_contextmenu_settings.X(),
               " Y=", m_contextmenu_settings.Y(), " XSize=", m_contextmenu_settings.XSize(),
               " YSize=", m_contextmenu_settings.YSize());
       for(int dbg_i = 0; dbg_i < m_contextmenu_settings.ItemsTotal(); dbg_i++)
        {
         CMenuItem *dbg_item = m_contextmenu_settings.GetItemPointer(dbg_i);
         ::Print("MY DEBUG CGUIPannel::CreateMenuBar: dropdown item[", dbg_i, "] LabelText=", dbg_item.LabelText(),
                 " X=", dbg_item.X(), " Y=", dbg_item.Y(), " IsVisible=", dbg_item.IsVisible());
        }
       m_contextmenu_settings.Hide();
       ::Print("MY DEBUG CGUIPannel::CreateMenuBar: after Hide, IsVisible=", m_contextmenu_settings.IsVisible());
       m_menu_bar.AddContextMenuPointer(MENU_ITEM_SETTINGS, m_contextmenu_settings);
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_contextmenu_settings);
      return (true);
   }
 // For Main Tabs m_tabs_main on the right of Main Window m_window_main  
  bool CGUIPannel::CreateTab_Main(const int x_gap, const int y_gap)
   {      
    string tabs_names[TAB_TAB_MAIN_TOTAL] = {"Account infor", "Symbol Info", "Monitor", "Positions", "History", "Settings","Bar Events"};
    string texts[TAB_TAB_MAIN_TOTAL] = 
    {
      "[ Account Info Tab ]",
      "[ Symbol Info Tab ]",
      "[ Monitor Tab ]",
      "[ Positions Tab ]",
      "[ History Tab ]",
      "[ Settings Tab ]",
      "[ Bar Events Tab ]"
    };
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
  }
#endif // CGUIPANNEL_MAINWINDOWS_MQH
