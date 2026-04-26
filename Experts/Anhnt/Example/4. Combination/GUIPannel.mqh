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
  private:
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
    //--- Edits
      //CTextEdit m_symb_filter;
      CTextEdit m_lot;
      CTextEdit m_up_level;
      CTextEdit m_down_level;
      //CTextEdit m_chart_scale;

  private:
    //--- Form
        bool CreateMainWindow(const string text);
    //--- Status bar
        bool CreateStatusBar(const int x_gap, const int y_gap);
    //--- Tabs
        bool CreateTab_Trade(const int x_gap, const int y_gap);
    //--- Table
        bool CreateAccountInfoTable(const int x_gap, const int y_gap);        
        bool CreatePositionsTable(const int x_gap, const int y_gap);
    //--- Lot edit box
        bool CreateLot(const int x_gap, const int y_gap, const string text);
    //--- Up level edit box
        bool CreateUpLevel(const int x_gap, const int y_gap, const string text);
    //--- Down level edit box
        bool CreateDownLevel(const int x_gap, const int y_gap, const string text);

  public:
      CGUIPannel(void);
      ~CGUIPannel(void);
    bool OnInitEvent(void);
    void OnDeinitEvent(const int reason);
    void OnTimerEvent(void);
    void OnTickEvent(void);

    //Update table
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
    if(!CreateTab_Trade(3,43)) 
    {
        Print(__FUNCTION__, " > Failed to create Tabs1!");
        return (false);
    }
    //Trade tab controls 
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
 bool CGUIPannel::UpdateTableAccountInfoDynamic()
  {
      int digits = (int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);      
      m_table_account_info.SetValue(1, 6,  DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),     digits));
      m_table_account_info.SetValue(1, 7,  DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),      digits));
      m_table_account_info.SetValue(1, 8,  DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN),      digits));
      m_table_account_info.SetValue(1, 9,  DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), digits));
      m_table_account_info.SetValue(1, 10, DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2) + " %");
      m_table_account_info.SetValue(1, 11, DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),      digits));      
      m_table_account_info.Update(true);
      return(true);
  }
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
