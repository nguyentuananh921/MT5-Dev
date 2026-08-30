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
 bool CGUIPannel::CreateMainWindow(const string caption_text)
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
      m_window_main.MinimumXSize(M_WINDOW_MAIN_MIN_WIDTH); 
      m_window_main.MinimumYSize(M_WINDOW_MAIN_MIN_HEIGHT); 
    //--- Set the tooltips
      m_window_main.GetCloseButtonPointer().Tooltip("Close");
      m_window_main.GetTooltipButtonPointer().Tooltip("Tooltips");
      m_window_main.GetFullscreenButtonPointer().Tooltip("Fullscreen");
      m_window_main.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
    //--- Create the form default ENUM_WINDOW_TYPE W_MAIN
      if (!m_window_main.CreateWindow(m_chart_id, m_subwin, caption_text, 1, 1))
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
 //For Menu Bar
  bool CGUIPannel::CreateMenuBar(const int x_gap, const int y_gap)
   {
    //--- Store the window pointer
     m_menu_bar.MainPointer(m_window_main);
     m_menu_bar.MainPointer(m_window_main);
     m_menu_bar.IsCenterText(false);   
     m_menu_bar.LabelXGap(22);         
    //--- Add items (placeholder text/width - tinh chỉnh sau khi quyết map tab->item)
     //  m_menu_bar.AddItem(70, "Symbol TF");
     //  m_menu_bar.AddItem(70, "Indicator");
     m_menu_bar.AddItem(70, "Settings");
     //  m_menu_bar.AddItem(70, "Positions");
    //--- Create a control element
     if(!m_menu_bar.CreateMenuBar(x_gap, y_gap))
       return (false);
     //--- Set icon for the Settings item (IconXGap/IconYGap Library đã tự set =3/4 bên trong CreateItems())
       CMenuItem *settings_item = m_menu_bar.GetItemPointer(MENU_ITEM_SETTINGS);
       settings_item.IconFile(IMAGE_RESOURCE_BMP16_SETTING_PNG);     
       
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_menu_bar);
      return (true);
   } 
  //Need update later
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
#endif // CGUIPANNEL_MAINWINDOWS_MQH
