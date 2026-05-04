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
//For GUI controls
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
//For trading data
  #include <Vendors\Anhnt\Library\4. Combination Lib\Trading\Accounts\Account.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Trading\Collections\SymbolsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\InputData\TradingInpData.mqh>

//Define GUI control
  //id for m_tabsTrade
    enum ENUM_TAB_TRADE 
      {
        TAB_TAB_TRADE_ACCOUNT_INFO = 0,
        TAB_TAB_TRADE_SYMBOL_INFO,
        TAB_TAB_TRADE_TRADE,        
        TAB_TAB_TRADE_POSITIONS,
        TAB_TAB_TRADE_HISTORY,
        TAB_TAB_TRADE_SETTINGS,       
      }; 
  // Status bar items
    #define STATUS_LABELS_TOTAL 3
    enum ENUM_STATUS_BAR_ITEM 
     {
        STATUS_BAR_HELP         = 0,
        STATUS_BAR_DEPOSIT_LOAD ,
        STATUS_BAR_SERVER_TIME,
     };
class CGUIPannel : public CWndEvents 
 {
  private:   //Private variables
   //--- Time counters
    CTimeCounter m_gui_timecounter;   
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
        CTable m_table_symb;
        CTable m_table_syminfo;
    //--- Edits
      //CTextEdit m_symb_filter;
      CTextEdit m_lot;
      CTextEdit m_up_level;
      CTextEdit m_down_level;
    // For selecting symbol list mode (Market Watch, Server, etc.)
      CButtonsGroup m_btns_symbols_mode; 
      //CTextEdit m_chart_scale;
    //--- Time and ticket of the last checked trade
      datetime m_last_deal_time;
      ulong m_last_deal_ticket;
    // For stroring symbols collection from trading engine
      CSymbolsCollection *m_symTableInfor_symbols;   
  private:   //Private methods
    //--- Form
        bool CreateMainWindow(const string text);
    //--- Status bar
        bool CreateStatusBar(const int x_gap, const int y_gap);
    //--- Tabs
        bool CreateTab_Trade(const int x_gap, const int y_gap);
    //--- Table
      //For Account Info Table
        bool CreateAccountInfoTable(const int x_gap, const int y_gap);
      //For Positions Table
        bool CreatePositionsTable(const int x_gap, const int y_gap);
        //--- initialize the position table
        void InitializePositionsTable(void);
        //--- Set values in the value table
        bool SetValuesToPositionsTable(string &symbols_name[], bool force=false);
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
      //--- Symbols table
        bool CreateSymbolsTable(const int x_gap, const int y_gap);
        //--- Update the symbol table
        void UpdateSymbolsTable(void);
      //--- Symbols Information table
        bool CreateSymbolsInfoTable(const int x_gap, const int y_gap);
        bool CreateSymbolsModeButtons(const int x_gap, const int y_gap);
        
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
    virtual void OnEvent(const int id, const long &lparam,
                     const double &dparam, const string &sparam);

    //--- Trading event handler
      void OnTradeEvent(void);
    //Update table
      //For Account Info Table
        bool InitTableAccountInfoStatic();
        bool UpdateTableAccountInfoDynamic();  
        void UpdateTableAccountInfoDynamicFromEngine(CAccount *acc);   
      //For Symbols Table
        void InitializeSymbolInfoTable(ENUM_SYMBOLS_MODE mode);
        void UpdateSymbolInfoTableFromEngine(CSymbolsCollection *symbols);
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
     //Tab Trade
        if (!CreateSymbolsTable(2,55))
        {
          Print(__FUNCTION__, " > Failed to create Symbols Table!");
            return (false);
        }
     //Control in Trade tab   
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
     //Control in symbol information tab
        if(!CreateSymbolsModeButtons(617, 5))
        {
            Print(__FUNCTION__, " > Failed to create Symbols Mode ComboBox!");
            return false;
        }
       if (!CreateSymbolsInfoTable(4, 5)) 
        {
            Print(__FUNCTION__, " > Failed to create Symbols Information Table!");
            return (false);
        } 
        InitializeSymbolInfoTable(SYMBOLS_MODE_CURRENT);     
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
 //OnEvent handler
 void CGUIPannel::OnEvent(const int id, const long &lparam,
                         const double &dparam, const string &sparam)
  {
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON)
      {
        static ENUM_SYMBOLS_MODE s_prev_mode = (ENUM_SYMBOLS_MODE)-1;
        ENUM_SYMBOLS_MODE mode = (ENUM_SYMBOLS_MODE)(uint)dparam;  // ← dùng dparam
        if(mode != s_prev_mode)
          {
            s_prev_mode = mode;
            InitializeSymbolInfoTable(mode);
          }
      }
  }
 void CGUIPannel::OnTickEvent(void)
   {
      //For Account info table, only update dynamic info when there is an event in account, no need to update every tick
        //UpdateTableAccountInfoDynamic();  
      //For symbols table at Trade tab
        UpdateSymbolsTable(); //Temporary doing nothing.
      //For Positions Table
        bool positions_table_need_redraw = false;
        //--- Get symbols of open positions
        string symbols_name[];
        int symbols_total = GetPositionsSymbols(symbols_name);
        int rows_total    = (int)m_table_positions.RowsTotal();
        if(symbols_total > 0 && symbols_total != rows_total)
          {
            //--- Symbol list changed: rebuild table structure (add/remove rows + full redraw)
              InitializePositionsTable();
              positions_table_need_redraw = true;
          }
        else if(symbols_total > 0)
          {
            //--- Same symbols: only update changed cells (dirty-check)
            positions_table_need_redraw = SetValuesToPositionsTable(symbols_name);
          }        
      //--- Update status bar only when value changes  
          static string status_bar_prev_deposit = "";
          static string status_bar_prev_time    = "";
          string new_deposit = "Deposit load: " + ::DoubleToString(DepositLoad(false), 2) + "/" + ::DoubleToString(DepositLoad(true), 2) + "%";
          string new_time    = ::TimeToString(::TimeTradeServer(), TIME_DATE | TIME_SECONDS);
          if(new_deposit != status_bar_prev_deposit)
            {
              status_bar_prev_deposit = new_deposit;
              //m_status_bar.SetValue(STATUS_BAR_DEPOSIT_LOAD, new_deposit);
              //m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD).Update(true);
              m_status_bar.SetValue(STATUS_BAR_DEPOSIT_LOAD, new_deposit);
              m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD).Draw();
              m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD).Update(false);
              positions_table_need_redraw=true; //Redraw the table when deposit load changes as it is one of the columns in the table
            }
          if(new_time != status_bar_prev_time)
            {
              status_bar_prev_time = new_time;
              //m_status_bar.SetValue(STATUS_BAR_SERVER_TIME, new_time);
              //m_status_bar.GetItemPointer(STATUS_BAR_SERVER_TIME).Update(true);
              m_status_bar.SetValue(STATUS_BAR_SERVER_TIME, new_time);
              m_status_bar.GetItemPointer(STATUS_BAR_SERVER_TIME).Draw();
              m_status_bar.GetItemPointer(STATUS_BAR_SERVER_TIME).Update(false);
              positions_table_need_redraw=true; //Redraw the table when server time changes as it is one of the columns in the table
            } 
      if(positions_table_need_redraw) ::ChartRedraw();           
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
      m_status_bar.SetValue(STATUS_BAR_HELP, "For Help, press F1");
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
     #define TABS1_TOTAL 6 //Total number of tabs in m_tabsTrade
     string tabs_names[TABS1_TOTAL] = {"Account infor", "Symbol Info", "Trade", "Positions", "History", "Settings"};
         
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
 //For Account Infor Table at Tab Account infor
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
   // Updates dynamic account info using CAccount* from TradingEngine
    void CGUIPannel::UpdateTableAccountInfoDynamicFromEngine(CAccount *acc)
    {
        static double s_prev_profit = DBL_MAX;
        static double s_prev_equity = DBL_MAX;
        if(acc.Profit() == s_prev_profit && acc.Equity() == s_prev_equity)
            return;
        s_prev_profit = acc.Profit();
        s_prev_equity = acc.Equity();
        int digits = (int)acc.CurrencyDigits();
        //Set values from CAccount object
          m_table_account_info.SetValue(1, 6,  DoubleToString(acc.Balance(),     digits));
          m_table_account_info.SetValue(1, 7,  DoubleToString(acc.Equity(),      digits));
          m_table_account_info.SetValue(1, 8,  DoubleToString(acc.Margin(),      digits));
          m_table_account_info.SetValue(1, 9,  DoubleToString(acc.MarginFree(),  digits));
          m_table_account_info.SetValue(1, 10, DoubleToString(acc.MarginLevel(),  2) + " %");
          m_table_account_info.SetValue(1, 11, DoubleToString(acc.Profit(),      digits));
        //Setting Color Text For Value
        // Equity: green if above balance, red if below
          color clr_equity = (acc.Equity() > acc.Balance()) ? clrLime :
                            (acc.Equity() < acc.Balance()) ? clrRed  : clrSilver;
          m_table_account_info.TextColor(1, 7, clr_equity);

        // Margin Level: green safe, yellow caution, red danger
          double margin_level = acc.MarginLevel();
          color clr_margin;
          if(margin_level == 0 || margin_level > 200) clr_margin = clrLime;
          else if(margin_level > 100)                 clr_margin = clrYellow;
          else                                        clr_margin = clrRed;
          m_table_account_info.TextColor(1, 10, clr_margin);

          // Profit: green positive, red negative
          color clr_profit = (acc.Profit() > 0) ? clrLime :
                            (acc.Profit() < 0) ? clrRed  : clrSilver;
          m_table_account_info.TextColor(1, 11, clr_profit);
          m_table_account_info.Update(true);
    }
  
 //For Positions Table at tab Positions
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
  //| Initialize the position table with current open positions         |
  //+------------------------------------------------------------------+
  void CGUIPannel::InitializePositionsTable(void) 
    {
      //--- Get symbols of open positions
        string symbols_name[];
        int symbols_total = GetPositionsSymbols(symbols_name);
      //--- Delete all rows
        m_table_positions.DeleteAllRows();
      //--- Set the number of rows by the number of symbols
        for(int i = 0; i < symbols_total - 1; i++)
            m_table_positions.AddRow(i);
      //--- If there are positions
        if(symbols_total > 0) 
          {
            //--- Array of images for buttons
              uint button_images[1] = {IMAGE_RESOURCE_CONTROLS_CLOSE_BLACK_BMP};
            //--- Set the type and images for each row
              for(uint row = 0; row < (uint)symbols_total; row++) 
                {
                m_table_positions.CellType(0, row, CELL_BUTTON);
                m_table_positions.SetImages(0, row, button_images);
                }
            //--- Force fill all cells (bypass dirty-check after DeleteAllRows)
              SetValuesToPositionsTable(symbols_name, true);
          }
      //--- Update the table
        m_table_positions.Update(true);
    }
  //+------------------------------------------------------------------+
  //| Set the values in the position table                             |
  //+------------------------------------------------------------------+
  bool CGUIPannel::SetValuesToPositionsTable(string &symbols_name[], bool force/*=false*/)
   {
      uint symbols_total = ::ArraySize(symbols_name);
      uint rows_total    = m_table_positions.RowsTotal();
      if(symbols_total < rows_total)
         return false;
      static uint   s_prev_rows = 0;
      static string s_c0[], s_c1[], s_c2[], s_c3[], s_c4[];
      static string s_c5[], s_c6[], s_c7[], s_c8[], s_c9[];
      if(s_prev_rows != rows_total || force)
        {
         s_prev_rows = rows_total;
         ::ArrayResize(s_c0,rows_total); ::ArrayResize(s_c1,rows_total);
         ::ArrayResize(s_c2,rows_total); ::ArrayResize(s_c3,rows_total);
         ::ArrayResize(s_c4,rows_total); ::ArrayResize(s_c5,rows_total);
         ::ArrayResize(s_c6,rows_total); ::ArrayResize(s_c7,rows_total);
         ::ArrayResize(s_c8,rows_total); ::ArrayResize(s_c9,rows_total);
         for(uint i=0; i<rows_total; i++)
            s_c0[i]=s_c1[i]=s_c2[i]=s_c3[i]=s_c4[i]=
            s_c5[i]=s_c6[i]=s_c7[i]=s_c8[i]=s_c9[i]="";
        }

      bool any_changed = false;
      //Calulate values and set to table with dirty-check
        for(uint r = 0; r < rows_total; r++)
          {
          double pos_volume  = PositionsVolumeTotal(symbols_name[r]);
          double buy_volume  = PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_BUY);
          double sell_volume = PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_SELL);
          double pos_profit  = PositionsFloatingProfitTotal(symbols_name[r]);
          double buy_profit  = PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_BUY);
          double sell_profit = PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_SELL);
          double avg_price   = PositionAveragePrice(symbols_name[r]);

          string v0 = symbols_name[r];
          string v1 = (string)PositionsTotal(symbols_name[r]);
          string v2 = ::DoubleToString(pos_volume,  2);
          string v3 = ::DoubleToString(buy_volume,  2);
          string v4 = ::DoubleToString(sell_volume, 2);
          string v5 = ::DoubleToString(pos_profit,  2);
          string v6 = ::DoubleToString(buy_profit,  2);
          string v7 = ::DoubleToString(sell_profit, 2);
          string v8 = ::DoubleToString(DepositLoad(false,avg_price,symbols_name[r],pos_volume),2)+"/"+
                      ::DoubleToString(DepositLoad(true, avg_price,symbols_name[r],pos_volume),2)+"%";
          string v9 = ::DoubleToString(avg_price,(int)::SymbolInfoInteger(symbols_name[r],SYMBOL_DIGITS));

          if(v0!=s_c0[r]){s_c0[r]=v0;m_table_positions.SetValue(0,r,v0,0,true);any_changed=true;}
          if(v1!=s_c1[r]){s_c1[r]=v1;m_table_positions.SetValue(1,r,v1,0,true);any_changed=true;}
          if(v2!=s_c2[r]){s_c2[r]=v2;m_table_positions.SetValue(2,r,v2,0,true);any_changed=true;}
          if(v3!=s_c3[r])
            {
              s_c3[r]=v3;
              m_table_positions.TextColor(3,r,(buy_volume >0)?clrBlack:clrLightGray);
              m_table_positions.SetValue(3,r,v3,0,true);
              any_changed=true;
            }
          if(v4!=s_c4[r])
            {
              s_c4[r]=v4;
              m_table_positions.TextColor(4,r,(sell_volume>0)?clrBlack:clrLightGray);
              m_table_positions.SetValue(4,r,v4,0,true);
              any_changed=true;
            }
          if(v5!=s_c5[r])
            {
              s_c5[r]=v5;
              m_table_positions.TextColor(5,r,(pos_profit !=0)?(pos_profit >0?clrGreen:clrRed):clrLightGray);
              m_table_positions.SetValue(5,r,v5,0,true);
              any_changed=true;
            }
          if(v6!=s_c6[r])
            {
              s_c6[r]=v6;
              m_table_positions.TextColor(6,r,(buy_profit !=0)?(buy_profit >0?clrGreen:clrRed):clrLightGray);
              m_table_positions.SetValue(6,r,v6,0,true);
              any_changed=true;
            }
          if(v7!=s_c7[r])
            {
              s_c7[r]=v7;
              m_table_positions.TextColor(7,r,(sell_profit!=0)?(sell_profit>0?clrGreen:clrRed):clrLightGray);
              m_table_positions.SetValue(7,r,v7,0,true);
              any_changed=true;
            }
          if(v8!=s_c8[r]){s_c8[r]=v8;m_table_positions.SetValue(8,r,v8,0,true);any_changed=true;}
          if(v9!=s_c9[r]){s_c9[r]=v9;m_table_positions.SetValue(9,r,v9,0,true);any_changed=true;}
          }
      if(any_changed)
         m_table_positions.Update(false);
      return any_changed;
   }
  //Calculate value for Table
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
    //| Using in                                                         |
    //|    - CGUIPannel::SetValuesToPositionsTable                       |
    //|    - m_status_bar.SetValue                                       |
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
 //For Symbols Information at tab Trade
   //+------------------------------------------------------------------+
   //| Create a symbol table                                            |
   //+------------------------------------------------------------------+
   bool CGUIPannel::CreateSymbolsTable(const int x_gap,const int y_gap)
    {
      #define COLUMNS1_TOTAL 2
      #define ROWS1_TOTAL    1
      //--- Store the pointer to the main control
        m_table_symb.MainPointer(m_tabsTrade);
      //--- Attach to tab
        m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_TRADE,m_table_symb);
      //--- Array of column widths
        int width[COLUMNS1_TOTAL]={95,58};
      //--- Array of text alignment in columns
        ENUM_ALIGN_MODE align[COLUMNS1_TOTAL]={ALIGN_LEFT,ALIGN_RIGHT};
      //--- Array of text offset along the X axis in the columns
        int text_x_offset[COLUMNS1_TOTAL]={5,5};
      //--- Properties
        m_table_symb.XSize(168);
        m_table_symb.TableSize(COLUMNS1_TOTAL,ROWS1_TOTAL);
        m_table_symb.ColumnsWidth(width);
        m_table_symb.TextAlign(align);
        m_table_symb.TextXOffset(text_x_offset);
        m_table_symb.ShowHeaders(true);
        m_table_symb.SelectableRow(true);
        m_table_symb.ColumnResizeMode(true);
        m_table_symb.IsZebraFormatRows(clrWhiteSmoke);
        m_table_symb.AutoYResizeMode(true);
        m_table_symb.AutoYResizeBottomOffset(2);
      //--- Create a control element
        if(!m_table_symb.CreateTable(x_gap,y_gap))
            return(false);
      //--- Set the header titles
        m_table_symb.SetHeaderText(0,"Symbol");
        m_table_symb.SetHeaderText(1,"Values");
      //--- Add the object to the common array of object groups
        CWndContainer::AddToElementsArray(0,m_table_symb);
        return(true);
    }
   //Initially fill symbol information table with current symbol data
   void CGUIPannel::InitializeSymbolInfoTable(ENUM_SYMBOLS_MODE mode)
    {
      //--- Build symbol name list by mode
        string syms[];
        int total_symbol = 0;
        if(mode == SYMBOLS_MODE_CURRENT)
          {
            ArrayResize(syms, 1);
            syms[0] = ::Symbol();
            total_symbol = 1;
          }
        else if(mode == SYMBOLS_MODE_DEFINES)
          {
            total_symbol = GetPositionsSymbols(syms);
          }
        else if(mode == SYMBOLS_MODE_MARKET_WATCH)
          {
            total_symbol = ::SymbolsTotal(true);
            ArrayResize(syms, total_symbol);
            for(int i = 0; i < total_symbol; i++)
                syms[i] = ::SymbolName(i, true);
          }
        else // SYMBOLS_MODE_ALL
          {
            total_symbol = ::SymbolsTotal(false);
            ArrayResize(syms, total_symbol);
            for(int i = 0; i < total_symbol; i++)
                syms[i] = ::SymbolName(i, false);
          }
      //--- DeleteAllRows giữ lại 1 row trống (row 0), headers không bị xóa
        m_table_syminfo.DeleteAllRows();
      //--- Handle empty list (DEFINES không có position)
        if(total_symbol == 0)
          {
            m_table_syminfo.SetValue(0, 0, "No trading found, symbol table cleared");
            m_table_syminfo.Update(true);
            return;
          }
      //--- Set direction icons array cho tất cả rows (kể cả row 0)
        uint icons[3] = {
            IMAGE_RESOURCE_ICONS_BMP16_ARROW_UP_BMP,
            IMAGE_RESOURCE_ICONS_BMP16_ARROW_DOWN_BMP,
            IMAGE_RESOURCE_ICONS_BMP16_CIRCLE_GRAY_BMP
        };
      // Add rows
        for(int symbol_i = 0; symbol_i < total_symbol - 1; symbol_i++)
            m_table_syminfo.AddRow(symbol_i);
      // Set data for total_symbol rows
        for(int symbol_i = 0; symbol_i < total_symbol; symbol_i++)
        {
          m_table_syminfo.SetValue(0, symbol_i, syms[symbol_i]);
          m_table_syminfo.SetImages(0, symbol_i, icons);
          m_table_syminfo.ChangeImage(0, symbol_i, 2);
        }          
      //--- Update
        m_table_syminfo.Update(true);
    }

   //For Symbol Information Table at tab Symbol Info
   void CGUIPannel::UpdateSymbolInfoTableFromEngine(CSymbolsCollection *symbols)
    {
      if(symbols == NULL) return;
      int mode = m_btns_symbols_mode.SelectedButtonIndex();
      //--- Rebuild symbol list only when mode changes
        static int s_prev_mode = -1;
        static string s_syms[];
        static int    s_total = 0;

      if(mode != s_prev_mode)
        {
          s_prev_mode = mode;
          s_total     = 0;
          if(mode == SYMBOLS_MODE_CURRENT)
            {
              ArrayResize(s_syms, 1);
              s_syms[0] = ::Symbol();
              s_total   = 1;
            }
          else if(mode == SYMBOLS_MODE_DEFINES)
            {
              s_total = GetPositionsSymbols(s_syms);
            }
          else // MARKET_WATCH or ALL
            {
              s_total = symbols.GetSymbolsCollectionTotal();
              ArrayResize(s_syms, s_total);
              for(int i = 0; i < s_total; i++)
                {
                  CSymbol *s = (CSymbol*)symbols.GetList().At(i);
                  s_syms[i]  = (s != NULL) ? s.Name() : "";
              }
            }
          //--- Rebuild table rows
          m_table_syminfo.DeleteAllRows();
          if(s_total == 0)
            {
            m_table_syminfo.AddRow(0);
            m_table_syminfo.SetValue(0, 0, "No trading found, symbol table cleared");
            m_table_syminfo.Update(true);
            return;
            }
          for(int i = 0; i < s_total; i++)
              m_table_syminfo.AddRow(i);
          //Print debug
          Print("Mode=", mode, " Total=", s_total, " RowsTotal=", m_table_syminfo.RowsTotal());
        }

      if(s_total == 0) return;
       //--- Update data every tick — raw SymbolInfo (reliable, no collection needed)
        bool     any_changed = false;
        datetime now         = TimeTradeServer();
        static string s_bid[], s_ask[], s_spread[], s_time[], s_sym[];
        static int    s_prev_total = -1;
        if(s_prev_total != s_total)
          {
            s_prev_total = s_total;
            ArrayResize(s_sym, s_total); ArrayResize(s_bid,    s_total);
            ArrayResize(s_ask, s_total); ArrayResize(s_spread, s_total);
            ArrayResize(s_time, s_total);
            for(int i = 0; i < s_total; i++)
                s_sym[i] = s_bid[i] = s_ask[i] = s_spread[i] = s_time[i] = "";
          }

        for(int r = 0; r < s_total; r++)
          {
            string   sym_name  = s_syms[r];
            if(sym_name == "") continue;
            int      digits    = (int)SymbolInfoInteger(sym_name, SYMBOL_DIGITS);
            double   bid       = SymbolInfoDouble(sym_name, SYMBOL_BID);
            double   ask       = SymbolInfoDouble(sym_name, SYMBOL_ASK);
            int      spread    = (int)SymbolInfoInteger(sym_name, SYMBOL_SPREAD);
            datetime tick_time = (datetime)SymbolInfoInteger(sym_name, SYMBOL_TIME);
            color    clr_price = (bid > SymbolInfoDouble(sym_name, SYMBOL_BID)) ? clrGreen :
                                (bid < SymbolInfoDouble(sym_name, SYMBOL_BID)) ? clrRed : clrBlack;
            color    clr_time  = ((now - tick_time) <= 3) ? clrRed : clrDimGray;
            string   v_sym     = sym_name;
            string   v_bid     = DoubleToString(bid,    digits);
            string   v_ask     = DoubleToString(ask,    digits);
            string   v_spread  = (string)spread;
            string   v_time    = TimeToString(tick_time, TIME_SECONDS);

            if(v_sym != s_sym[r])
              { s_sym[r]=v_sym; m_table_syminfo.SetValue(0,r,v_sym,0,true); any_changed=true; }
            if(v_bid != s_bid[r])
              {
              s_bid[r]=v_bid;       m_table_syminfo.SetValue(1,r,v_bid,    0,true);
              s_ask[r]=v_ask;       m_table_syminfo.SetValue(2,r,v_ask,    0,true);
              s_spread[r]=v_spread; m_table_syminfo.SetValue(3,r,v_spread, 0,true);
              any_changed = true;
              }
            if(v_time != s_time[r])
              {
              s_time[r]=v_time;
              m_table_syminfo.TextColor(4,r,clr_time);
              m_table_syminfo.SetValue(4,r,v_time,0,true);
              any_changed = true;
              }
          }
        if(any_changed) m_table_syminfo.Update(false);
    }  
   //+------------------------------------------------------------------+
   //| Update the symbol table                                          |
   //+------------------------------------------------------------------+
   void CGUIPannel::UpdateSymbolsTable(void) 
    {
      //Temporatry remove
        // uint values_total = ::ArraySize(m_values);
        // //--- Set the values in the symbol table
        // uint rows_total = m_table_symb.RowsTotal();
        // for (uint r = 0; r < (uint)rows_total; r++) {
        //   //--- Stop the loop if the array is out of range
        //   if (r > values_total - 1 || values_total < 1)
        //     break;
        //   //--- Set the values
        //   m_table_symb.SetValue(1, r, ::DoubleToString(m_values[r], 2));
        //   //--- Set the colors
        //   color clr = (m_values[r] > (double)m_up_level.GetValue()) ? clrRed
        //               : (m_values[r] < (double)m_down_level.GetValue())
        //                   ? C'85,170,255'
        //                   : clrBlack;
        //   m_table_symb.TextColor(0, r, clr, true);
        //   m_table_symb.TextColor(1, r, clr, true);
        //   //--- Update the progress bar
        //   m_progress_bar.LabelText("Initialize tables: " + string(rows_total) + "/" +
        //                           string(r) + "...");
        //   m_progress_bar.Update(r, rows_total);
        //   ::Sleep(5);
        // }
        // //--- Update the table
        // m_table_symb.Update();
    }
  bool CGUIPannel::CreateSymbolsInfoTable(const int x_gap, const int y_gap)
    {
      #define SYMINFO_COLS 5
      #define SYMINFO_ROWS 1
      //--- Store pointer to main control
        m_table_syminfo.MainPointer(m_tabsTrade);
      //--- Attach to tab
        m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_SYMBOL_INFO, m_table_syminfo);
      //--- Column widths
        int width[SYMINFO_COLS] = {115, 90, 80, 55, 100};
      //--- Text alignment
        ENUM_ALIGN_MODE align[SYMINFO_COLS];
        ::ArrayInitialize(align, ALIGN_RIGHT);
        align[0] = ALIGN_LEFT;
      //--- Text X offset
        int text_x_offset[SYMINFO_COLS];
        ::ArrayInitialize(text_x_offset, 5);
      //--- Properties
        m_table_syminfo.TableSize(SYMINFO_COLS, SYMINFO_ROWS);
        m_table_syminfo.ColumnsWidth(width);
        m_table_syminfo.TextAlign(align);
        m_table_syminfo.TextXOffset(text_x_offset);
        m_table_syminfo.ShowHeaders(true);
        m_table_syminfo.IsSortMode(false);
        m_table_syminfo.SelectableRow(true);
        m_table_syminfo.ColumnResizeMode(true);
        m_table_syminfo.IsZebraFormatRows(clrWhiteSmoke);
        m_table_syminfo.XSize(433);
        m_table_syminfo.AutoXResizeMode(true);
        m_table_syminfo.AutoYResizeMode(true);
        m_table_syminfo.AutoXResizeRightOffset(130);
        m_table_syminfo.AutoYResizeBottomOffset(2);
      //--- Create
        if(!m_table_syminfo.CreateTable(x_gap, y_gap))
            return false;
      //--- Headers
        m_table_syminfo.SetHeaderText(0, "Symbol");
        m_table_syminfo.SetHeaderText(1, "Bid");
        m_table_syminfo.SetHeaderText(2, "Ask");
        m_table_syminfo.SetHeaderText(3, "!");
        m_table_syminfo.SetHeaderText(4, "Time");
      //--- Add to elements array
        CWndContainer::AddToElementsArray(0, m_table_syminfo);
        return true;
    }
  bool CGUIPannel::CreateSymbolsModeButtons(const int x_gap, const int y_gap)
    {
      m_btns_symbols_mode.MainPointer(m_tabsTrade);
      m_tabsTrade.AddToElementsArray(TAB_TAB_TRADE_SYMBOL_INFO, m_btns_symbols_mode);
      //--- Radio mode: chỉ 1 button được chọn tại 1 thời điểm
        m_btns_symbols_mode.RadioButtonsMode(true);
        m_btns_symbols_mode.RadioButtonsStyle(true);
        m_btns_symbols_mode.ButtonYSize(22);
      //--- Add buttons — index khớp ENUM_SYMBOLS_MODE
        m_btns_symbols_mode.AddButton(0, 0,  "Current",      120);
        m_btns_symbols_mode.AddButton(0, 24, "Positions",    120);
        m_btns_symbols_mode.AddButton(0, 48, "Market Watch", 120);
        m_btns_symbols_mode.AddButton(0, 72, "All",          120);       
      //--- Create
        if(!m_btns_symbols_mode.CreateButtonsGroup(x_gap, y_gap))
            return false;
      //--- Default: Current (index 0)
        m_btns_symbols_mode.SelectButton(SYMBOLS_MODE_CURRENT);
      CWndContainer::AddToElementsArray(0, m_btns_symbols_mode);
      return true;
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
