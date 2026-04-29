//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//--- Library class for creating the graphical interface             |
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>

//Define GUI control
  //id for m_tabsTrade
    enum ENUM_TAB_TRADE 
      {
        TAB_TAB_TRADE_ACCOUNT_INFO = 0,
        TAB_TAB_TRADE_TRADE,        
        TAB_TAB_TRADE_POSITIONS,
        TAB_TAB_TRADE_HISTORY,
        TAB_TAB_TRADE_SETTINGS,       
      }; 
class CGUIPannel : public CWndEvents 
 {
  private:   //Private variables
   //--- Time counters
    CTimeCounter m_gui_timecounter;
   //--- Symbols for trading
     string m_symbols[];
   //Control Elements
    //--- Window
        CWindow m_Mainwindow;
    //--- Status bar
        CStatusBar m_status_bar;
    //--- Tabs
        CTabs m_tabsTrade;
    //--- Table
        CTable m_table_positions;
        CTable m_table_account_info;
    //--- Edits
      //CTextEdit m_symb_filter;
      CTextEdit m_lot;
      CTextEdit m_up_level;
      CTextEdit m_down_level;
      //CTextEdit m_chart_scale;
    //--- Time and ticket of the last checked trade
      datetime m_last_deal_time;
      ulong m_last_deal_ticket;

  private:   //Private methods
    //--- Form
        bool CreateMainWindow(const string text);
    //--- Status bar
        bool CreateStatusBar(const int x_gap, const int y_gap);
    //--- Tabs
        bool CreateTab_Trade(const int x_gap, const int y_gap);
    //--- Table
        bool CreateAccountInfoTable(const int x_gap, const int y_gap);
      //For Positions Table
        bool CreatePositionsTable(const int x_gap, const int y_gap);
        //--- initialize the position table
        void InitializePositionsTable(void);
        //--- Update the position table
        void UpdatePositionsTable(void);
        //--- Set values in the value table
        void SetValuesToPositionsTable(string &symbols_name[]);
        //--- Get symbols of open positions to the array
        int GetPositionsSymbols(string &symbols_name[]);
        //--- Position average price
        double PositionAveragePrice(const string symbol);
        //--- Number of position trades with a specified symbol
        int PositionsTotal(const string symbol);
        //--- Total volume of positions with the specified properties
        double PositionsVolumeTotal(const string symbol,const ENUM_POSITION_TYPE type = WRONG_VALUE); 
        //--- Total floating profit of positions with the specified properties
        double PositionsFloatingProfitTotal(const string symbol,const ENUM_POSITION_TYPE type = WRONG_VALUE);
        //--- Deposit load
        double DepositLoad(const bool percent_mode, const double price = 0.0,const string symbol = "", const double volume = 0.0);
        //--- Check a new trade on history
        bool IsLastDealTicket(void);
    //--- Lot edit box
        bool CreateLot(const int x_gap, const int y_gap, const string text);
    //--- Up level edit box
        bool CreateUpLevel(const int x_gap, const int y_gap, const string text);
    //--- Down level edit box
        bool CreateDownLevel(const int x_gap, const int y_gap, const string text);

  public:  //Public methods
      CGUIPannel(void);
      ~CGUIPannel(void);
    bool OnInitEvent(void);
    void OnDeinitEvent(const int reason);
    void OnTimerEvent(void);
    void OnTickEvent(void);
    //--- Trading event handler
      void OnTradeEvent(void);

    //Update table

      //For Account Info Table
      bool InitTableAccountInfoStatic();
      bool UpdateTableAccountInfoDynamic();     
    
 };
#endif // CGUIPANNEL_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CGUIPannel::CGUIPannel(void) 
  {
    //--- Setting parameters for the time counters
    m_gui_timecounter.SetParameters(16, 500);
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CGUIPannel::~CGUIPannel(void) 
  {
  }
 //+------------------------------------------------------------------+
 //| Init                                                             |
 //+------------------------------------------------------------------+
 bool CGUIPannel::OnInitEvent(void) 
  {
    //--- Creating form 1 for controls
      if (!CreateMainWindow("EXPERT PANEL")) {
          Print(__FUNCTION__, " > Failed to create panel!");
          return (false);
      }
      if (!CreateStatusBar(1, 23)) {
          Print(__FUNCTION__, " > Failed to create Status Bar!");
          return (false);
      }    
    //Trade tab controls 
    if(!CreateTab_Trade(3,43)) 
    {
        Print(__FUNCTION__, " > Failed to create Tabs1!");
        return (false);
    }
     //Tab Account info
      if (!CreateAccountInfoTable(4, 73)) 
      {
          Print(__FUNCTION__, " > Failed to create Account Infortable!");
          return (false);
      }
      if (!InitTableAccountInfoStatic()) 
      {
          Print(__FUNCTION__, " > Failed to initialize Account Info table!");
          return (false);
      }
     //Tab Positions
        if(!CreatePositionsTable(4, 73))
        {
            Print(__FUNCTION__, " > Failed to create Table1!");
            return (false);
        }
        InitializePositionsTable();        
    
    if(!CreateLot(180, 30, "Lot"))
    {
        Print(__FUNCTION__, " > Failed to create Lot!");
        return (false);
    }
    if(!CreateUpLevel(400, 30, "Up Level"))
    {
        Print(__FUNCTION__, " > Failed to create Up Level!");
        return (false);
    }
    if(!CreateDownLevel(510, 30, "Down Level"))
    {
        Print(__FUNCTION__, " > Failed to create Down Level!");
        return (false);
    }
    CWndEvents::CompletedGUI();
    m_chart.Redraw();
    return (true);

    // if(!CreateTabs1(3,43)) return(false);
    // //--- Edits
    //   if(!CreateSymbolsFilter(7,5,"Symbols filter:")) return(false);
    //   if(!CreateLot(180,30,"Lot:")) return(false);
    //   if(!CreateUpLevel(400,30,"Up level:")) return(false);
    //   if(!CreateDownLevel(510,30,"Down level:")) return(false);
  }
 void CGUIPannel::OnTickEvent(void)
   {
      //UpdateTableAccountInfoDynamic(); //No Need to update every tick, only when there is an event in account
      //For Positions Table
        //--- Get symbols of open positions
        string symbols_name[];
        int symbols_total = GetPositionsSymbols(symbols_name);
        //--- Update values in the table
        SetValuesToPositionsTable(symbols_name);
        //--- Sort if this has already been done by a user before the update
          // m_table_positions.SortData((uint)m_table_positions.IsSortedColumnIndex(),
          //                           m_table_positions.IsSortDirection());
        //--- Update the table
        UpdatePositionsTable();
   }
 //+------------------------------------------------------------------+
 //| Deinit                                                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnDeinitEvent(const int reason)
  {
    CWndEvents::Destroy();
  }
 //+------------------------------------------------------------------+
 //| Timer                                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTimerEvent(void) 
  {
    //--- Exit if this is the tester
      if (::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_FRAME_MODE))
        return;
    //--- Handling the elements
      CWndEvents::OnTimerEvent();
    //--- Update points in the status bar
     if (m_gui_timecounter.CheckTimeCounter()) 
      {
        // //--- Set the values
        // m_status_bar.SetValue(
        //     1, "Deposit load: " + ::DoubleToString(DepositLoad(false), 2) + "/" +
        //           ::DoubleToString(DepositLoad(true), 2) + "%");
        m_status_bar.SetValue(
            2, ::TimeToString(::TimeTradeServer(), TIME_DATE | TIME_SECONDS));
        //--- Update the points
        //m_status_bar.GetItemPointer(1).Update(true);
        m_status_bar.GetItemPointer(2).Update(true);        
      }    
  }
 //+------------------------------------------------------------------+
 //| Trade operation event                                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnTradeEvent(void) 
   {
    //--- If a new trade
    if (IsLastDealTicket()) {
      //--- initialize the position table
      InitializePositionsTable();
    }
   }
 //+------------------------------------------------------------------+
 //| Create Main Window                                               |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateMainWindow(const string caption_text) 
  {
   //--- Add a window pointer to the window array
    CWndContainer::AddWindow(m_Mainwindow);
   //--- Properties
     m_Mainwindow.XSize(750);
     m_Mainwindow.YSize(450);
     m_Mainwindow.FontSize(9);
     m_Mainwindow.IsMovable(true);
     m_Mainwindow.ResizeMode(true);
     m_Mainwindow.CloseButtonIsUsed(true);
     m_Mainwindow.CollapseButtonIsUsed(true);
     m_Mainwindow.TooltipsButtonIsUsed(true);
     m_Mainwindow.FullscreenButtonIsUsed(true);
     m_Mainwindow.MinimumXSize(300); // Allow shrinking horizontally down to 300px
     m_Mainwindow.MinimumYSize(200); // Allow shrinking vertically down to 200px
    //--- Set the tooltips
     m_Mainwindow.GetCloseButtonPointer().Tooltip("Close");
     m_Mainwindow.GetTooltipButtonPointer().Tooltip("Tooltips");
     m_Mainwindow.GetFullscreenButtonPointer().Tooltip("Fullscreen");
     m_Mainwindow.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
    //--- Create the form
    if (!m_Mainwindow.CreateWindow(m_chart_id, m_subwin, caption_text, 1, 1))
        return (false);
    //---
    return (true);
  }
 //For Status Bar
  //+------------------------------------------------------------------+
  //| Creates the status bar                                           |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateStatusBar(const int x_gap, const int y_gap) 
    {
      #define STATUS_LABELS_TOTAL 3
     //--- Store the window pointer
      m_status_bar.MainPointer(m_Mainwindow);
     //--- Properties
        m_status_bar.AutoXResizeMode(true);
        m_status_bar.AutoXResizeRightOffset(1); 
        m_status_bar.AnchorBottomWindowSide(true);
     //--- Specify the number of parts and set their properties
      int width[STATUS_LABELS_TOTAL] = {0, 200, 160};
      for (int i = 0; i < STATUS_LABELS_TOTAL; i++)
          // m_status_bar.AddItem(width[i]);
          m_status_bar.AddItem("", width[i]);
     //--- Create a control element
      if (!m_status_bar.CreateStatusBar(x_gap, y_gap))
          return (false);
     //--- Set text to the items of the status bar
      m_status_bar.SetValue(0, "For Help, press F1");
     //--- Add the object to the common array of object groups
      CWndContainer::AddToElementsArray(0, m_status_bar);
      return (true);
    }
 //For Tabs
  //+------------------------------------------------------------------+
  //| Create a group with tabs Trade                                   |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateTab_Trade(const int x_gap,const int y_gap)
   {     
     #define TABS1_TOTAL 5 //Total number of tabs in m_tabsTrade
     string tabs_names[TABS1_TOTAL] = {"Account infor", "Trade", "Positions", "History", "Settings"};
         
     //--- Store the pointer to the main control
      m_tabsTrade.MainPointer(m_Mainwindow);
     //--- Properties
      m_tabsTrade.IsCenterText(true);
      m_tabsTrade.PositionMode(TABS_TOP);
      m_tabsTrade.AutoXResizeMode(true);
      m_tabsTrade.AutoYResizeMode(true);
      m_tabsTrade.AutoXResizeRightOffset(3);
      m_tabsTrade.AutoYResizeBottomOffset(25);
     //--- Add tabs with the specified properties      
      for(int i=0; i<TABS1_TOTAL; i++)
          m_tabsTrade.AddTab(tabs_names[i],100);
     //--- Create a control element
      if(!m_tabsTrade.CreateTabs(x_gap,y_gap))
          return(false);
     //--- Add the object to the common array of object groups
      CWndContainer::AddToElementsArray(0,m_tabsTrade);
      return(true);
   }
 //For Account Infor Table
   bool CGUIPannel::CreateAccountInfoTable(const int x_gap, const int y_gap)
    {
      // Implementation for creating account info table
        #define ACCOUNT_INFO_COLS  2   // Property | Value
        #define ACCOUNT_INFO_ROWS  12  // 12 dòng thông tin
      //--- Attach to main tab control và tab Account Info
        m_table_account_info.MainPointer(m_tabsTrade);
        m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_ACCOUNT_INFO, m_table_account_info);
      //--- Column widths
        int width[ACCOUNT_INFO_COLS] = {120, 250};
      //--- Text alignment: cột 0 left, cột 1 left
        ENUM_ALIGN_MODE align[ACCOUNT_INFO_COLS];
        ArrayInitialize(align, ALIGN_LEFT);
        int text_x_offset[ACCOUNT_INFO_COLS];
        ArrayInitialize(text_x_offset, 5);

      //--- Properties
        m_table_account_info.TableSize(ACCOUNT_INFO_COLS, ACCOUNT_INFO_ROWS);
        m_table_account_info.ColumnsWidth(width);
        m_table_account_info.TextAlign(align);
        m_table_account_info.TextXOffset(text_x_offset);
        m_table_account_info.ShowHeaders(true);
        m_table_account_info.IsSortMode(false);
        m_table_account_info.SelectableRow(false);
        m_table_account_info.AutoXResizeMode(true);
        m_table_account_info.AutoYResizeMode(true);
        m_table_account_info.AutoXResizeRightOffset(2);
        m_table_account_info.AutoYResizeBottomOffset(2);
      //--- Create
        if(!m_table_account_info.CreateTable(x_gap, y_gap))
          return(false);
      //--- Headers
        m_table_account_info.SetHeaderText(0, "Property");
        m_table_account_info.SetHeaderText(1, "Value");
      //--- Fill Property column (cột 0) - cố định
        string props[ACCOUNT_INFO_ROWS] = {
          "Name", "Login", "Server", "Type", "Currency", "Leverage",
          "Balance", "Equity", "Margin", "Free Margin", "Margin Level", "Profit"
        };
        for(int i = 0; i < ACCOUNT_INFO_ROWS; i++)
          //--- Set property names in column 0
          m_table_account_info.SetValue(0, i, props[i]);
        CWndContainer::AddToElementsArray(0, m_table_account_info);
        return(true);
    }
   //Initially fill static account info.
   bool CGUIPannel::InitTableAccountInfoStatic()
    {
      m_table_account_info.SetValue(1, 0, AccountInfoString(ACCOUNT_NAME));
      m_table_account_info.SetValue(1, 1, (string)AccountInfoInteger(ACCOUNT_LOGIN));
      m_table_account_info.SetValue(1, 2, AccountInfoString(ACCOUNT_SERVER));
      
      string account_type = "";
      switch((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE))
      {
          case ACCOUNT_TRADE_MODE_DEMO:    account_type = "Demo";    break;
          case ACCOUNT_TRADE_MODE_CONTEST: account_type = "Contest"; break;
          case ACCOUNT_TRADE_MODE_REAL:    account_type = "Real";    break;
      }
      m_table_account_info.SetValue(1, 3, account_type);
      m_table_account_info.SetValue(1, 4, AccountInfoString(ACCOUNT_CURRENCY));
      m_table_account_info.SetValue(1, 5, "1:" + (string)AccountInfoInteger(ACCOUNT_LEVERAGE));
      
      m_table_account_info.Update(true);
      return(true);
    }
   //Updates dynamic account information
   bool CGUIPannel::UpdateTableAccountInfoDynamic()
    {
      int digits = (int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);      
      m_table_account_info.SetValue(1, 6,  DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),     digits));
      m_table_account_info.SetValue(1, 7,  DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),      digits));
      m_table_account_info.SetValue(1, 8,  DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN),      digits));
      m_table_account_info.SetValue(1, 9,  DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), digits));
      m_table_account_info.SetValue(1, 10, DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2) + " %");
      m_table_account_info.SetValue(1, 11, DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),      digits)); 
      //Setting Color Text For Value
      // Profit: xanh nếu dương, đỏ nếu âm
      double profit = AccountInfoDouble(ACCOUNT_PROFIT);
      color clr_profit = (profit > 0) ? clrLime : (profit < 0) ? clrRed : clrSilver;
      m_table_account_info.TextColor(1, 11, clr_profit);
      // Margin Level: xanh an toàn, vàng cảnh báo, đỏ nguy hiểm
      double margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      color clr_margin;
      if(margin_level == 0 || margin_level > 200)  clr_margin = clrLime;
      else if(margin_level > 100)                   clr_margin = clrYellow;
      else                                           clr_margin = clrRed;
      m_table_account_info.TextColor(1, 10, clr_margin);

      m_table_account_info.Update(true);      
      return(true);
    } 
 //For Positions Table
  //+------------------------------------------------------------------+
  //| Create a position table                                          |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreatePositionsTable(const int x_gap,const int y_gap)
   {
      #define COLUMNS2_TOTAL 10
      #define ROWS2_TOTAL    1
      //--- Store the pointer to the main control
        m_table_positions.MainPointer(m_tabsTrade);
      //--- Attach to tab
        m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_POSITIONS,m_table_positions);
      //--- Array of column widths
        int width[COLUMNS2_TOTAL];
        ::ArrayInitialize(width,75);
        width[0]=90;
        width[1]=63;
        width[2]=60;
        width[5]=60;
        width[8]=90;
      //--- Array of text alignment in columns
        ENUM_ALIGN_MODE align[COLUMNS2_TOTAL];
        ::ArrayInitialize(align,ALIGN_CENTER);
        align[0]=ALIGN_LEFT;
      //--- Array of text offset along the X axis in the columns
        int text_x_offset[COLUMNS2_TOTAL];
        ::ArrayInitialize(text_x_offset,21);
      //--- Array of column image offsets along the X axis
        int image_x_offset[COLUMNS2_TOTAL];
        ::ArrayInitialize(image_x_offset,3);
      //--- Array of column image offsets along the Y axis
        int image_y_offset[COLUMNS2_TOTAL];
        ::ArrayInitialize(image_y_offset,2);
      //--- Properties
        m_table_positions.TableSize(COLUMNS2_TOTAL,ROWS2_TOTAL);
        m_table_positions.ColumnsWidth(width);
        m_table_positions.TextAlign(align);
        m_table_positions.TextXOffset(text_x_offset);
        m_table_positions.ImageXOffset(image_x_offset);
        m_table_positions.ImageYOffset(image_y_offset);
        m_table_positions.ShowHeaders(true);
        m_table_positions.IsSortMode(true);
        m_table_positions.SelectableRow(true);
        m_table_positions.ColumnResizeMode(true);
        m_table_positions.IsZebraFormatRows(clrWhiteSmoke);
        m_table_positions.AutoXResizeMode(true);
        m_table_positions.AutoYResizeMode(true);
        m_table_positions.AutoXResizeRightOffset(2);
        m_table_positions.AutoYResizeBottomOffset(2);
      //--- Create a control element
        if(!m_table_positions.CreateTable(x_gap,y_gap))
            return(false);
      //--- Set the header titles
        string headers[COLUMNS2_TOTAL]={"Symbol","Positions","Volume","Buy Volume","Sell Volume","Profit","Buy Profit","Sell Profit","Deposit Load","Average Price"};
        for(int i=0; i<COLUMNS2_TOTAL; i++)
            m_table_positions.SetHeaderText(i,headers[i]);
      //--- Add the object to the common array of object groups
        CWndContainer::AddToElementsArray(0,m_table_positions);
        return(true);
   }  
  //+------------------------------------------------------------------+
  //| Update the position table                                        |
  //+------------------------------------------------------------------+
  void CGUIPannel::UpdatePositionsTable(void) 
   {
    //--- Update the table
    m_table_positions.Update(true);
    m_table_positions.GetScrollVPointer().Update(true);
    m_table_positions.GetScrollHPointer().Update(true);
   }
  //+------------------------------------------------------------------+
  //| Initializing the position table                                  |
  //+------------------------------------------------------------------+  
  void CGUIPannel::InitializePositionsTable(void) 
   {
    //--- Get symbols of open positions
      string symbols_name[];
      int symbols_total = GetPositionsSymbols(symbols_name);
    //--- Delete all rows
      m_table_positions.DeleteAllRows();
    //--- Set the number of rows by the number of symbols
    for (int i = 0; i < symbols_total - 1; i++)
      m_table_positions.AddRow(i);
    //--- If there are positions
    if (symbols_total > 0) {
      //--- Array of images for buttons
      //string button_images[1] = {"Images\\EasyAndFastGUI\\Controls\\close_black.bmp"};
      uint button_images[1]={IMAGE_RESOURCE_CONTROLS_CLOSE_BLACK_BMP};
      //--- Set the values in the third column
      for (uint r = 0; r < (uint)symbols_total; r++) 
       {
        //--- Set the type and the images
        m_table_positions.CellType(0, r, CELL_BUTTON);
        m_table_positions.SetImages(0, r, button_images);
       }
      //--- Set the values in the table
        SetValuesToPositionsTable(symbols_name);
    }
    //--- Update the table
    UpdatePositionsTable();
   }
  //+------------------------------------------------------------------+
  //| Set the values in the position table                             |
  //+------------------------------------------------------------------+
  void CGUIPannel::SetValuesToPositionsTable(string &symbols_name[]) 
   {
    //--- Check for out of range
    uint symbols_total = ::ArraySize(symbols_name);
    uint rows_total = m_table_positions.RowsTotal();
    if (symbols_total < rows_total)
      return;
    //--- Get the indicators in the table
    for (uint r = 0; r < rows_total; r++) {
      int positions_total = PositionsTotal(symbols_name[r]);
      double pos_volume = PositionsVolumeTotal(symbols_name[r]);
      double buy_volume =
          PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_BUY);
      double sell_volume =
          PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_SELL);
      double pos_profit = PositionsFloatingProfitTotal(symbols_name[r]);
      double buy_profit =
          PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_BUY);
      double sell_profit =
          PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_SELL);
      double average_price = PositionAveragePrice(symbols_name[r]);
      string deposit_load =
          ::DoubleToString(
              DepositLoad(false, average_price, symbols_name[r], pos_volume), 2) +
          "/" +
          ::DoubleToString(
              DepositLoad(true, average_price, symbols_name[r], pos_volume), 2) +
          "%";
      //--- Set the values
      m_table_positions.SetValue(0, r, symbols_name[r]);
      m_table_positions.SetValue(1, r, (string)positions_total);
      m_table_positions.SetValue(2, r, ::DoubleToString(pos_volume, 2));
      m_table_positions.SetValue(3, r, ::DoubleToString(buy_volume, 2));
      m_table_positions.SetValue(4, r, ::DoubleToString(sell_volume, 2));
      m_table_positions.SetValue(5, r, ::DoubleToString(pos_profit, 2));
      m_table_positions.SetValue(6, r, ::DoubleToString(buy_profit, 2));
      m_table_positions.SetValue(7, r, ::DoubleToString(sell_profit, 2));
      m_table_positions.SetValue(8, r, deposit_load);
      m_table_positions.SetValue(
          9, r,
          ::DoubleToString(average_price, (int)::SymbolInfoInteger(
                                              symbols_name[r], SYMBOL_DIGITS)));
      //--- Set the color
      m_table_positions.TextColor(3, r,
                                  (buy_volume > 0) ? clrBlack : clrLightGray);
      m_table_positions.TextColor(4, r,
                                  (sell_volume > 0) ? clrBlack : clrLightGray);
      m_table_positions.TextColor(5, r,
                                  (pos_profit != 0)
                                      ? (pos_profit > 0) ? clrGreen : clrRed
                                      : clrLightGray);
      m_table_positions.TextColor(6, r,
                                  (buy_profit != 0)
                                      ? (buy_profit > 0) ? clrGreen : clrRed
                                      : clrLightGray);
      m_table_positions.TextColor(7, r,
                                  (sell_profit != 0)
                                      ? (sell_profit > 0) ? clrGreen : clrRed
                                      : clrLightGray);
    }
   }
  //+------------------------------------------------------------------+
  //| Get symbols of open positions in the array                       |
  //+------------------------------------------------------------------+
  int CGUIPannel::GetPositionsSymbols(string &symbols_name[]) 
   {
    string symbols = "";
    //--- Go through the loop for the first time and get symbols of open positions
    int positions_total = ::PositionsTotal();
    for (int i = 0; i < positions_total; i++) 
     {
      //--- Select a position and get its symbol
      string position_symbol = ::PositionGetSymbol(i);
      //--- If there is a symbol name
      if (position_symbol == "")
        continue;
      //--- If there is no such a string, add it
      if (::StringFind(symbols, position_symbol, 0) == WRONG_VALUE)
        ::StringAdd(symbols,
                    (symbols == "") ? position_symbol : "," + position_symbol);
     }
    //--- Get string elements by separator
      ushort u_sep = ::StringGetCharacter(",", 0);
      int symbols_total = ::StringSplit(symbols, u_sep, symbols_name);
    //--- Return the number of symbols
    return (symbols_total);
   }
  //+------------------------------------------------------------------+
  //| Position average price                                           |
  //+------------------------------------------------------------------+
  double CGUIPannel::PositionAveragePrice(const string symbol) 
   {
    //--- For calculating the average price
    double sum_mult = 0.0;
    double sum_volumes = 0.0;
    //--- Check if there is a position with specified properties
     int positions_total = ::PositionsTotal();
     for (int i = positions_total - 1; i >= 0; i--) 
      {
        //--- If failed to select a position, go to the next one
        if (symbol != ::PositionGetSymbol(i))
          continue;
        //--- Get the price and position volume
        double pos_price = ::PositionGetDouble(POSITION_PRICE_OPEN);
        double pos_volume = ::PositionGetDouble(POSITION_VOLUME);
        //--- Sum up the intermediate indicators
        sum_mult += (pos_price * pos_volume);
        sum_volumes += pos_volume;
      }
    //--- Prevent division by zero
     if (sum_volumes <= 0)
      return (0.0);
    //--- Return the average price
     return (::NormalizeDouble(sum_mult / sum_volumes,(int)::SymbolInfoInteger(symbol, SYMBOL_DIGITS)));
   } 
  //+------------------------------------------------------------------+
  //| Number of position trades with a specified symbol                |
  //+------------------------------------------------------------------+
  int CGUIPannel::PositionsTotal(const string symbol) 
   {
    //--- Position counter
      int pos_counter = 0;
    //--- Check if there is a position with specified properties
      int positions_total = ::PositionsTotal();
    for (int i = positions_total - 1; i >= 0; i--) 
     {
      //--- If failed to select a position, go to the next one
      if (symbol != ::PositionGetSymbol(i))
        continue;
      //--- Increase the counter
      pos_counter++;
     }
    //--- Return the number of positions
    return (pos_counter);
   }
  //+------------------------------------------------------------------+
  //| Total volume of positions with the specified properties          |
  //+------------------------------------------------------------------+
  double CGUIPannel::PositionsVolumeTotal(const string symbol,const ENUM_POSITION_TYPE type = WRONG_VALUE) 
   {
    //--- Volume counter
      double volume_counter = 0;
    //--- Check if there is a position with specified properties
      int positions_total = ::PositionsTotal();
    for (int i = positions_total - 1; i >= 0; i--) 
      {
        //--- If failed to select a position, go to the next one
        if (symbol != ::PositionGetSymbol(i))
          continue;
        //--- If the type should be selected
        if (type != WRONG_VALUE) {
          //--- If the type does not match, go to the next position
          if (type != (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE))
            continue;
        }
        //--- Sum up the volume
        volume_counter += ::PositionGetDouble(POSITION_VOLUME);
      }
    //--- Return the volume
    return (volume_counter);
   }
  //+------------------------------------------------------------------+
  //| Total floating profit of positions with the specified properties |
  //+------------------------------------------------------------------+
  double CGUIPannel::PositionsFloatingProfitTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE) 
   {
    //--- Current profit counter
      double profit_counter = 0.0;
    //--- Check if there is a position with specified properties
      int positions_total = ::PositionsTotal();
      for (int i = positions_total - 1; i >= 0; i--) 
      {
        //--- If failed to select a position, go to the next one
        if (symbol != ::PositionGetSymbol(i))
          continue;
        //--- If the type should be selected
        if (type != WRONG_VALUE) 
          {
            //--- If the type does not match, go to the next position
            if (type != (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE))
              continue;
          }
        //--- Sum up the current profit + accumulated swap
        profit_counter += ::PositionGetDouble(POSITION_PROFIT) +::PositionGetDouble(POSITION_SWAP);
      }
    //--- Return the result
    return (profit_counter);
   }
  //+------------------------------------------------------------------+
  //| Deposit load                                                     |
  //+------------------------------------------------------------------+
  double CGUIPannel::DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "",const double volume = 0.0) 
   {
    //--- Calculate the current value of the deposit load
      double margin = 0.0;
    //--- Total account load
     if (symbol == "" || volume == 0.0)
        margin = ::AccountInfoDouble(ACCOUNT_MARGIN);
    //--- Load on a specified symbol
     else 
      {
      //--- Get margin calculation data
        double leverage = ((double)::AccountInfoInteger(ACCOUNT_LEVERAGE) == 0)
                              ? 1
                              : (double)::AccountInfoInteger(ACCOUNT_LEVERAGE);
        double contract_size =
            ::SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        string account_currency = ::AccountInfoString(ACCOUNT_CURRENCY);
        string base_currency = ::SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE);
      //--- If trading account currency is the same as the symbol base currency
        if (account_currency == base_currency)
          margin = (volume * contract_size) / leverage;
        else
          margin = (volume * contract_size) / leverage * price;
       }
    //--- Get the current funds
      double equity = (::AccountInfoDouble(ACCOUNT_EQUITY) == 0)
                          ? 1
                          : ::AccountInfoDouble(ACCOUNT_EQUITY);
    //--- Return the current deposit load
    return ((!percent_mode) ? margin : (margin / equity) * 100);
   }
  //+------------------------------------------------------------------+
  //| Check a new trade on history                                     |
  //+------------------------------------------------------------------+
  bool CGUIPannel::IsLastDealTicket(void) 
   {
    //--- Exit if the history is not received
      if (!::HistorySelect(m_last_deal_time, UINT_MAX))
        return (false);
    //--- Get the number of deals in the obtained list
      int total_deals = ::HistoryDealsTotal();
    //--- Loop through the total number of deals in the obtained list from the
    // last deal to the first one
    for (int i = total_deals - 1; i >= 0; i--) 
     {
        //--- Get the deal ticket
        ulong deal_ticket = ::HistoryDealGetTicket(i);
        //--- Exit if the tickets are equal
        if (deal_ticket == m_last_deal_ticket)
          return (false);
        //--- If the tickets are not equal, report it
        else {
          datetime deal_time =
              (datetime)::HistoryDealGetInteger(deal_ticket, DEAL_TIME);
          //--- Save the last deal time and ticket
          m_last_deal_time = deal_time;
          m_last_deal_ticket = deal_ticket;
          return (true);
        }
     }
    //--- Tickets of another symbol
    return (false);
   }

 //+------------------------------------------------------------------+
 //| Create the "Lot" edit box                                        |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateLot(const int x_gap,const int y_gap,const string text)
  {
     //--- Store the pointer to the main control
      m_lot.MainPointer(m_tabsTrade);//Pointer to the tab control m_tabsTrade
     //--- Attach to tab
      m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_TRADE,m_lot);// Add to tab trade
     //--- Properties
      m_lot.XSize(80);
      m_lot.MaxValue(1000);
      m_lot.MinValue(0.01);
      m_lot.StepValue(0.01);
      m_lot.SetDigits(2);
      m_lot.SpinEditMode(true);
      m_lot.SetValue((string)0.1);
      m_lot.GetTextBoxPointer().XSize(50);
      m_lot.GetTextBoxPointer().AutoSelectionMode(true);
      m_lot.GetTextBoxPointer().AnchorRightWindowSide(true);
     //--- Create a control element
      if(!m_lot.CreateTextEdit(text,x_gap,y_gap))
          return(false);
     //--- Add the object to the common array of object groups
      CWndContainer::AddToElementsArray(0,m_lot); // Add to main window
      return(true);
  }
  //+------------------------------------------------------------------+
  //| Create the "Up level" edit box                                   |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateUpLevel(const int x_gap,const int y_gap,const string text)
   {
     //--- Store the pointer to the main control
      m_up_level.MainPointer(m_tabsTrade);//Pointer to the tab control m_tabsTrade
     //--- Attach to tab
      m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_TRADE,m_up_level);// Add to tab Trade
     //--- Properties
      m_up_level.XSize(100);
      m_up_level.MaxValue(100);
      m_up_level.MinValue(50);
      m_up_level.StepValue(1);
      m_up_level.SetDigits(0);
      m_up_level.SpinEditMode(true);
      m_up_level.SetValue((string)80);
      m_up_level.GetTextBoxPointer().XSize(50);
      m_up_level.GetTextBoxPointer().AutoSelectionMode(true);
      m_up_level.GetTextBoxPointer().AnchorRightWindowSide(true);
     //--- Create a control element
      if(!m_up_level.CreateTextEdit(text,x_gap,y_gap))
          return(false);
     //--- Add the object to the common array of object groups
      CWndContainer::AddToElementsArray(0,m_up_level);//Add to main window
      return(true);
    }
   //+------------------------------------------------------------------+
   //| Create the "Down level" edit box                                 |
   //+------------------------------------------------------------------+
   bool CGUIPannel::CreateDownLevel(const int x_gap,const int y_gap,const string text)
    {
     //--- Store the pointer to the main control
      m_down_level.MainPointer(m_tabsTrade);
     //--- Attach to tab
      m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_TRADE,m_down_level);
     //--- Properties
      m_down_level.XSize(115);
      m_down_level.MaxValue(50);
      m_down_level.MinValue(0);
      m_down_level.StepValue(1);
      m_down_level.SetDigits(0);
      m_down_level.SpinEditMode(true);
      m_down_level.SetValue((string)20);
      m_down_level.GetTextBoxPointer().XSize(50);
      m_down_level.GetTextBoxPointer().AutoSelectionMode(true);
      m_down_level.GetTextBoxPointer().AnchorRightWindowSide(true);
     //--- Create a control element
      if(!m_down_level.CreateTextEdit(text,x_gap,y_gap))
          return(false);
     //--- Add the object to the common array of object groups
      CWndContainer::AddToElementsArray(0,m_down_level);//Add to main window
      return(true);
    } 
  
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
