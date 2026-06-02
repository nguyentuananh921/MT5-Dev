//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//--- Library class for creating the graphical interface             |
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__
 // For GUI controls
 #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
 // For trading data
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SymbolsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Timeseries\PatternRenderer.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>  
//  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\InputData\TradingInpData.mqh>
//  #include <Vendors\Anhnt\Library\4. Combination Lib\Trading\Accounts\Account.mqh>
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
  // Define GUI control
  // id for m_tabsTrade
  enum ENUM_TAB_MAIN
   {
      TAB_TAB_TRADE_ACCOUNT_INFO = 0,
      TAB_TAB_TRADE_SYMBOL_INFO,
      TAB_TAB_TRADE_TRADE,
      TAB_TAB_TRADE_POSITIONS,
      TAB_TAB_TRADE_HISTORY,
      TAB_TAB_TRADE_SETTINGS,
      TAB_TAB_TRADE_EVENTS, //For Pattern Information
      TABS1_TOTAL,          //Total Tab
   };
  // Status bar items
  #define STATUS_LABELS_TOTAL 4
   enum ENUM_STATUS_BAR_ITEM
   {
      STATUS_BAR_HELP = 0,
      STATUS_BAR_DEPOSIT_LOAD,
      STATUS_BAR_PROFIT,
      STATUS_BAR_SERVER_TIME,
   };
  //+------------------------------------------------------------------+
  //| Tab indices                                                      |
  //+------------------------------------------------------------------+
  enum ENUM_TAB_INFO
   {
      TAB_INFO_PATTERNS   = 0,   // Candle pattern confluence
      TAB_INFO_INDICATORS = 1,   // Indicator values (future)
      TAB_INFO_TOTAL
   };
 class CGUIPannel : public CWndEvents
  {
   private: 
    // Private Pointer variables    
      CSymbolsCollection * m_symbols;             //Trading owns
      CBarTimeSeriesCollection  *m_timeseries;    //CBarTimeSeriesCollection owns
      CPatternRenderer* m_renderer;               //EA owns PatternRenderer for display New Patterns
      CBarPatternsControl* m_patterns_ctrl;       // borrowed from EA
    //--- Time counters
      CTimeCounter m_gui_timecounter;
    // Control Elements     
      CWindow     m_Mainwindow;
      CStatusBar  m_status_bar;
      CTabs       m_tabs_main;
      //For CTreeView
       CTreeView   m_treeview_settings;
       bool m_tree_initialized;       
       // Symbol node registry — written once at first build (watermark == 0)
        string      m_tree_symbol_names[];  // symbol name at each registry slot
        int         m_tree_sym_g[];         // tree position (g) of that symbol node
       // TF node registry — tracks which (symbol, TF) pairs are in the tree
        string      m_tree_tf_syms[];       // symbol name of each registered TF node
        ENUM_TIMEFRAMES m_tree_tf_values[]; // TF value of each registered TF node
       //For Pattern
        ENUM_PATTERN_TYPE m_pattern_types[];
        string            m_pattern_display_names[];
       // Pattern panel controls
         CTable      m_pattern_table;         
         CCheckBox   m_check_all_bull;
         CCheckBox   m_check_all_bear; 
         CTextLabel  m_pattern_labels[PATTERNS_TOTAL];
         CCheckBox   m_bull_checks[PATTERNS_TOTAL];
         CCheckBox   m_bear_checks[PATTERNS_TOTAL]; 
       //For Infor Windows 
        CWindow           m_info_Window;
        CTabs             m_tab_info_tabs;
        CTextLabel        m_lbl_info_time;
        CTextLabel        m_lbl_info_open;
        CTextLabel        m_lbl_info_high;
        CTextLabel        m_lbl_info_low;
        CTextLabel        m_lbl_info_close;
        CTable            m_tbl_info_pattern_table;    
    //Test Purpose
      CTextLabel m_test_labels[TABS1_TOTAL];    
   private: // Private methods
     //--- Form
         int WindowIdx(CWindow &wnd);
         bool CreateMainWindow(const string text);
     // For Main Tab
         bool CreateTab_Main(const int x_gap, const int y_gap);
     //--- Status bar
         bool CreateStatusBar(const int x_gap, const int y_gap);
         bool UpdateStatusBar(void);

     //For m_treeview_settings Setting Tab at m_tabs_main
        bool CreateTreeView_Settings(void);
        void PopulateTreeFromCollections(void); 
        void DiscoverPatterns(void);         
       //For table PatternConfig
        void InitializePatternTable(void);
        bool CreatePatternConfigTable(const int x, const int y);
     //For information Windows
         bool              CreateInfoWindow(void);
         bool              CreateInfoTabs(const int x_gap, const int y_gap);
         bool              CreateInfoLabels(const int x_gap, const int y_gap);
         bool              CreateInfoPatternTable(void);  // new
         void              ScanPatternsInfo(CArrayObj *plist,
                              const string symbol,
                              const ENUM_TIMEFRAMES tf_current,
                              const datetime T);
     //Calculation for Control
      double DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0);
   public: // Public methods
      // lifecycle method
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
       //For GUI         
        void RefreshGUI(void); 
        CWindow *GetMainWindowPointer(void) { return &m_Mainwindow; }      
      //For Information windows
         void ShowInfoWindowAt(const int x, const int y,
                     CBar *bar, const int digits,
                     CArrayObj *plist,
                     const string symbol,
                     const ENUM_TIMEFRAMES tf_current);
         void              HideInfoWindow(void);
      //For Pointer      
         void  SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbols = symbols; }      
         void  SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_timeseries = ts; }         
         void  SetPatternRenderer(CPatternRenderer* renderer) { m_renderer = renderer; }
         void  SetPatternsControl(CBarPatternsControl* ctrl) { m_patterns_ctrl = ctrl; } 
            
  };
#endif // CGUIPANNEL_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
 //| Constructor/Destructor                                           | 
  CGUIPannel::CGUIPannel(void)
   {
    //--- Setting parameters for the time counters
      m_gui_timecounter.SetParameters(16, 500);
      m_tree_initialized=false;      
      m_renderer = NULL;
    // m_syminfo_mode_changed = false;
      // //For event table
      //    m_events_clicked_row = WRONG_VALUE;
      //    m_events_row_count   = 0;
      //    m_events_filled_count= 0;
   
   } 
  CGUIPannel::~CGUIPannel(void)
   {
   }
 //Get window index
  int CGUIPannel::WindowIdx(CWindow &wnd)
   {
      for(int i = 0; i < WindowsTotal(); i++)
         if(m_windows[i] == GetPointer(wnd))
            return i;
      return 0;
   } 
// CGUIPannel Lifecycle
  
 //+------------------------------------------------------------------+
  //| Init                                                             |
  //+------------------------------------------------------------------+ 
  bool CGUIPannel::OnInitEvent(void)
   {
      DiscoverPatterns();
      //--- Creating form 1 for controls
      if (!CreateMainWindow("EXPERT PANEL V3"))
         {
            Print(__FUNCTION__, " > Failed to create panel!");
            return (false);
         }
      if (!CreateStatusBar(1, 23))
         {
            Print(__FUNCTION__, " > Failed to create Status Bar!");
            return (false);
         }
      // Trade tab controls
         if (!CreateTab_Main(3, 43))
            {
               //Print(__FUNCTION__, " > Failed to create Tabs1!");
               return (false);
            }
      //Create control in each tab
         //For Settings Tab at m_tabs_main
            if(!CreateTreeView_Settings()) 
             {
               { 
                  //Debug
                   //Print("MyDebug from CGUIPannel::OnInitEvent FAIL: CreateTreeView_Settings");
                  return false;
               }
             }
            PopulateTreeFromCollections(); 
             //Debug 
             //Print("MyDebug from CGUIPannel::OnInitEvent pattern_types count=", ArraySize(m_pattern_types));

            if(!CreatePatternConfigTable(215, 5)) return false;
             //Print("MyDebug from CGUIPannel::OnInitEvent OK: all created");
      
      //For infor windows
       if(!CreateInfoWindow()) return false;
      CWndEvents::CompletedGUI();

       InitializePatternTable();
       HideInfoWindow();
      m_chart.Redraw();
      return (true);      
   };
  // OnEvent handler
  void CGUIPannel::OnEvent(const int id, const long &lparam,
                         const double &dparam, const string &sparam)
   {
      bool is_header = ((id - CHARTEVENT_CUSTOM) == ON_SORT_DATA      && lparam == m_pattern_table.Id());
      bool is_cell   = (id == (CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX) && lparam == m_pattern_table.Id());
      if(!is_header && !is_cell) return;

      // ── Phase 1: Update m_pattern_table ──────────────────────────
       int n = ArraySize(m_pattern_types);
       if(is_header)
        {
         int col = (int)dparam;
         if(col != 3 && col != 4) return;

         bool any_off = false;
         for(int i = 0; i < n; i++)
               if(m_pattern_table.SelectedImageIndex(col, i) != 0)
                  { any_off = true; break; }
         int new_state = any_off ? 0 : 1;
         for(int i = 0; i < n; i++)
               m_pattern_table.ChangeImage(col, i, new_state, false);
         m_pattern_table.Update(true);
        }
       else  // is_cell: control đã tự cập nhật visual rồi
        {
         int sep = StringFind(sparam, "_");
         if(sep < 0) return;
         int col = (int)StringToInteger(StringSubstr(sparam, 0, sep));
         int row = (int)StringToInteger(StringSubstr(sparam, sep + 1));
         if((col != 3 && col != 4) || row < 0 || row >= n) return;
        }
      //Debug
      // ── Debug: dump table state after Phase 1 ─────────────────────
       for(int i = 0; i < n; i++)
         {
            int bull_idx = m_pattern_table.SelectedImageIndex(3, i);
            int bear_idx = m_pattern_table.SelectedImageIndex(4, i);
            Print("MyDebug from CGUIPannel::OnEvent [", i, "] ", EnumToString(m_pattern_types[i]),
                  "  bull_idx=", bull_idx, "(on=", (bull_idx==0), ")",
                  "  bear_idx=", bear_idx, "(on=", (bear_idx==0), ")");
         }
         Print("MyDebug from CGUIPannel::OnEvent renderer=", (m_renderer != NULL),
               "  timeseries=", (m_timeseries != NULL));
       if(m_renderer != NULL && m_timeseries != NULL)
         {
            CArrayObj *plist = m_timeseries.GetListAllPatterns();
            Print("MyDebug from CGUIPannel::OnEvent plist total=", (plist != NULL ? plist.Total() : -1));
         }
         // ─────────────────────────────────────────────────────────────
      // ── Phase 2: Update Chart từ state của m_pattern_table ───────      
       if(m_renderer == NULL || m_timeseries == NULL) return;
       if(is_cell) m_pattern_table.Update(true);
       // ── Debug Phase 2 ─────────────────────────────────────────────
         Print("MyDebug from CGUIPannel::OnEvent Phase2 n=", n, " is_header=", is_header, " is_cell=", is_cell);
         for(int i = 0; i < n; i++)
         {
            string vis_name = m_pattern_table.GetValue(0, i);
            int orig = -1;
            for(int j = 0; j < n; j++)
               if(m_pattern_display_names[j] == vis_name)
                     { orig = j; break; }
            int bi = m_pattern_table.SelectedImageIndex(3, i);
            int ri = m_pattern_table.SelectedImageIndex(4, i);
            if(bi == 0 || ri == 0)   // chỉ print dòng nào có checkbox bật
               Print("MyDebug from CGUIPannel::OnEvent  row=", i, " '", vis_name, "' orig=", orig,
                     " bull=", bi, " bear=", ri,
                     " ptype=", (orig >= 0 ? EnumToString(m_pattern_types[orig]) : "???"));
         }
         // ─────────────────────────────────────────────────────────────
        for(int i = 0; i < n; i++)
         {
            // Resolve visual row i → original pattern index
            string vis_name = m_pattern_table.GetValue(0, i);
            int orig = -1;
            for(int j = 0; j < n; j++)
               if(m_pattern_display_names[j] == vis_name)
                     { orig = j; break; }
            if(orig < 0) continue;

            bool bull_on = (m_pattern_table.SelectedImageIndex(3, i) == 0);
            bool bear_on = (m_pattern_table.SelectedImageIndex(4, i) == 0);
            m_renderer.SetFilter(m_pattern_types[orig], bull_on, bear_on);
         }
       CArrayObj *plist = m_timeseries.GetListAllPatterns();
       if(plist != NULL)
         {
            //Update chart
            m_renderer.Refresh(plist, true, true);
            // Debug after Refresh — check what renderer actually has enabled
               int enabled_types = 0;
               for(int k = 0; k < n; k++)
               {
                  bool b = m_renderer.GetFilterBull(m_pattern_types[k]);
                  bool r = m_renderer.GetFilterBear(m_pattern_types[k]);
                  if(b || r)
                  {
                     enabled_types++;
                     Print("MyDebug from CGUIPannel::OnEvent filter ON: ", EnumToString(m_pattern_types[k]),
                           " bull=", b, " bear=", r);
                  }
               }
               Print("MyDebug from CGUIPannel::OnEvent total enabled types in renderer=", enabled_types);
         }
   }
  void CGUIPannel::OnTickEvent(void)
   {
      
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
   }
  void CGUIPannel::RefreshGUI(void) 
   {      
      int old_count = m_treeview_settings.ItemsTotal();
      PopulateTreeFromCollections();
      if(m_treeview_settings.ItemsTotal() > old_count)
         m_treeview_settings.CreateItemsFrom(old_count);
      m_chart.Redraw();
   } 
 //For Control
 // Create GUI controls
  //For Main Window
  //+------------------------------------------------------------------+
  //| Create Main Window                                               |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateMainWindow(const string caption_text)
   {
      //--- Add a window pointer to the window array
      CWndContainer::AddWindow(m_Mainwindow);
      //--- Properties
         m_Mainwindow.XSize(750);
         m_Mainwindow.YSize(480);
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
      return (true);
   }
 // For Status Bar
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
         int width[STATUS_LABELS_TOTAL] = {0, 200, 160, 120};
         for (int i = 0; i < STATUS_LABELS_TOTAL; i++)
            m_status_bar.AddItem("", width[i]);
      //--- Create a control element
         if (!m_status_bar.CreateStatusBar(x_gap, y_gap))
            return (false);
      //--- Set text to the items of the status bar
         m_status_bar.SetValue(STATUS_BAR_HELP, "For Help, press F1");
      //--- Setup icons for Deposit Load item (arrow up=high load, gray=medium, arrow down=low)
         CTextLabel *deposit_item = m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD);
         deposit_item.AddImagesGroup(2, 6); // x_gap=2, y_gap=6
         deposit_item.AddImage(0, IMAGE_RESOURCE_ICONS_BMP16_ARROW_UP_BMP);
         deposit_item.AddImage(0, IMAGE_RESOURCE_ICONS_BMP16_ARROW_DOWN_BMP);
         deposit_item.AddImage(0, IMAGE_RESOURCE_ICONS_BMP16_CIRCLE_GRAY_BMP);
         deposit_item.ChangeImage(0, 2); // default: gray
         deposit_item.LabelXGap(14);     // shift text right for icon
      //--- Setup icons for Profit item (arrow up=profit, arrow down=loss, gray=zero)
         CTextLabel *profit_item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
         profit_item.AddImagesGroup(2, 6); // x_gap=2, y_gap=6
         profit_item.AddImage(0, IMAGE_RESOURCE_ICONS_BMP16_ARROW_UP_BMP);
         profit_item.AddImage(0, IMAGE_RESOURCE_ICONS_BMP16_ARROW_DOWN_BMP);
         profit_item.AddImage(0, IMAGE_RESOURCE_ICONS_BMP16_CIRCLE_GRAY_BMP);
         profit_item.ChangeImage(0, 2); // default: gray
         profit_item.LabelXGap(14);     // shift text right for icon
      //--- Add the object to the common array of object groups
         CWndContainer::AddToElementsArray(0, m_status_bar);
         return (true);
   }
  // Update Status Bar
  bool CGUIPannel::UpdateStatusBar(void)
   {
      static string s_deposit = "";
      static string s_time = "";
      static string s_profit = "";
      static double s_deposit_val = 0;
      static double s_profit_val = 0;

      double deposit_val = DepositLoad(false);
      double profit_val = AccountInfoDouble(ACCOUNT_PROFIT);
      string new_deposit = "Deposit load: " + ::DoubleToString(deposit_val, 2) + "/" +
                           ::DoubleToString(DepositLoad(true), 2) + "%";
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
 // For Main Tabs
  //+------------------------------------------------------------------+
  //| Create a group with tabs Trade                                   |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateTab_Main(const int x_gap, const int y_gap)
   {      
      string tabs_names[TABS1_TOTAL] = {"Account infor", "Symbol Info", "Trade", "Positions", "History", "Settings","Bar Events"};
      string texts[TABS1_TOTAL] = 
         {
         "[ Account Info Tab ]",
         "[ Symbol Info Tab ]",
         "[ Trade Tab ]",
         "[ Positions Tab ]",
         "[ History Tab ]",
         "[ Settings Tab ]",
         "[ Bar Events Tab ]"
         };
      //--- Store the pointer to the main control
      m_tabs_main.MainPointer(m_Mainwindow);
      //--- Properties
      m_tabs_main.IsCenterText(true);
      m_tabs_main.PositionMode(TABS_TOP);
      m_tabs_main.AutoXResizeMode(true);
      m_tabs_main.AutoYResizeMode(true);
      m_tabs_main.AutoXResizeRightOffset(3);
      m_tabs_main.AutoYResizeBottomOffset(25);
      //--- Add tabs with the specified properties
      for (int i = 0; i < TABS1_TOTAL; i++)
         {
            m_tabs_main.AddTab(tabs_names[i], 100);            
         }
      //--- Create Tab before create other control element inside
         if (!m_tabs_main.CreateTabs(x_gap, y_gap))
            return (false);
         for (int i = 0; i < TABS1_TOTAL; i++)
          {
            //Set Pointer before create
               m_test_labels[i].MainPointer(m_tabs_main);
               if(!m_test_labels[i].CreateTextLabel(texts[i], 10, 10))
                  return false;
               m_tabs_main.AddToElementsArray(i, m_test_labels[i]);
            CWndContainer::AddToElementsArray(0, m_test_labels[i]);
          }      
      //--- Add the object to the common array of object groups
      CWndContainer::AddToElementsArray(0, m_tabs_main);
      return (true);
   }
 //Add Control at Setting Tab at m_tabs_main
  bool CGUIPannel::CreateTreeView_Settings(void)
   {
      PopulateTreeFromCollections();
      m_treeview_settings.MainPointer(m_tabs_main);     
      
      m_treeview_settings.AutoXResizeMode(false);  // fixed width
      m_treeview_settings.XSize(200);              // tree chiếm 200px bên trái
      m_treeview_settings.AutoYResizeMode(true);

      m_treeview_settings.VisibleItemsTotal(15);
      m_treeview_settings.LightsHover(true);
      if(!m_treeview_settings.CreateTreeView(10, 10)) return false;
      m_tabs_main.AddToElementsArray(TAB_TAB_TRADE_SETTINGS, m_treeview_settings);
      CWndContainer::AddToElementsArray(0, m_treeview_settings);
      m_tree_initialized = true;
      return true;
   }
  void CGUIPannel::PopulateTreeFromCollections(void)
   {
      if(m_timeseries == NULL) return;

      const int tf_total = 21;
      int mw_total  = ::SymbolsTotal(true);
      int watermark = m_treeview_settings.ItemsTotal();
      int g = 0;

      // ─────────────────────────────────────────────────────────────────
      // PRE-COMPUTE — Count expected TF children per symbol.
      // Used in Loop 1 so AddItem receives the correct items_total and
      // item_state from the very first call. Counts registered nodes plus
      // new nodes that currently have timeseries data.
      // ─────────────────────────────────────────────────────────────────

      int tf_counts[];
      ArrayResize(tf_counts, mw_total);
      for(int i = 0; i < mw_total; i++)
       {
         string sym_name = ::SymbolName(i, true);
         int count = 0;
         for(int j = 0; j < tf_total; j++)
         {
               ENUM_TIMEFRAMES tf = TimeframeByEnumIndex(j + 1);

               bool registered = false;
               for(int n = 0; n < ArraySize(m_tree_tf_syms); n++)
                  if(m_tree_tf_syms[n] == sym_name && m_tree_tf_values[n] == tf)
                     { registered = true; break; }

               if(registered)           { count++; continue; }
               if(m_timeseries.GetSeries(sym_name, tf) != NULL) count++;
         }
         tf_counts[i] = count;
       }

      // ─────────────────────────────────────────────────────────────────
      // LOOP 1 — Root node + one symbol node per MarketWatch symbol.
      // MarketWatch order (SymbolName) is stable across TF-change reinits.
      // The name→position registry is written only at first build
      // (watermark == 0) and never overwritten.
      // ─────────────────────────────────────────────────────────────────

      if(g >= watermark)
         m_treeview_settings.AddItem(g, -1, "Patterns", 0,
                                       0, 0, 0,
                                       mw_total, mw_total, true, true);
      g++;

      for(int i = 0; i < mw_total; i++)
      {
         string sym_name = ::SymbolName(i, true);
         int    sym_g    = g;

         if(watermark == 0)
         {
               int n = ArraySize(m_tree_sym_g);
               ArrayResize(m_tree_sym_g,        n + 1);
               ArrayResize(m_tree_symbol_names, n + 1);
               m_tree_sym_g[n]        = sym_g;
               m_tree_symbol_names[n] = sym_name;
         }

         if(g >= watermark)
               m_treeview_settings.AddItem(g, 0, sym_name, 0,
                                          i, 1, 0,
                                          tf_counts[i],
                                          0,
                                          tf_counts[i] > 0,
                                          tf_counts[i] > 0);
         g++;
      }

      // ─────────────────────────────────────────────────────────────────
      // LOOP 2 — Append TF nodes (outer-join: m_timeseries is right side).
      // Iterates the stable registry so sym_g is always correct regardless
      // of DoEasy collection reordering between TF-change reinits.
      // New nodes are always appended at ItemsTotal() to avoid g-counter
      // drift. After appending, SetItemsTotal syncs the symbol node's
      // m_t_items_total so FormTreeList knows the exact child count and
      // can trigger its sibling-recovery while-loop at the right time.
      // ─────────────────────────────────────────────────────────────────

      int reg_size = ArraySize(m_tree_symbol_names);
      for(int reg_idx = 0; reg_idx < reg_size; reg_idx++)
      {
         string sym_name = m_tree_symbol_names[reg_idx];
         int    sym_g    = m_tree_sym_g[reg_idx];

         // Count already-registered TF nodes for this symbol
         int tf_idx_base = 0;
         for(int j = 0; j < tf_total; j++)
         {
               ENUM_TIMEFRAMES tf = TimeframeByEnumIndex(j + 1);
               for(int n = 0; n < ArraySize(m_tree_tf_syms); n++)
                  if(m_tree_tf_syms[n] == sym_name && m_tree_tf_values[n] == tf)
                     { tf_idx_base++; break; }
         }

         // Add new TF nodes where join condition succeeds
         int new_tf_idx = tf_idx_base;
         for(int j = 0; j < tf_total; j++)
         {
               ENUM_TIMEFRAMES tf = TimeframeByEnumIndex(j + 1);

               bool already_added = false;
               for(int n = 0; n < ArraySize(m_tree_tf_syms); n++)
                  if(m_tree_tf_syms[n] == sym_name && m_tree_tf_values[n] == tf)
                     { already_added = true; break; }
               if(already_added) continue;

               if(m_timeseries.GetSeries(sym_name, tf) == NULL) continue;

               int new_g = m_treeview_settings.ItemsTotal();
               m_treeview_settings.AddItem(new_g, sym_g,
                                          EnumToString(tf),
                                          IMAGE_RESOURCE_ICONS_BMP16_START_BMP,
                                          new_tf_idx, 2, reg_idx, 0, 0,
                                          false, false);

               int n = ArraySize(m_tree_tf_syms);
               ArrayResize(m_tree_tf_syms,   n + 1);
               ArrayResize(m_tree_tf_values, n + 1);
               m_tree_tf_syms[n]   = sym_name;
               m_tree_tf_values[n] = tf;
               new_tf_idx++;
         }

         // Sync symbol node's items_total with actual child count.
         // Existing symbol nodes were skipped by the watermark check in
         // Loop 1, so their m_t_items_total was not updated by AddItem.
         // FormTreeList needs this accurate value to trigger the recovery
         // while-loop (→ process sibling symbols) at the right time.
         m_treeview_settings.SetItemsTotal(sym_g, new_tf_idx);
      }
   }
  // Dynamic pattern discovery — call once at init
  void CGUIPannel::DiscoverPatterns(void)
   {
    ArrayFree(m_pattern_types);
    ArrayFree(m_pattern_display_names);
    for(int bit = 0; bit < 30; bit++)
    {
        ENUM_PATTERN_TYPE t = (ENUM_PATTERN_TYPE)(1 << bit);
        string s = EnumToString(t);
        if(StringFind(s, "PATTERN_TYPE_") != 0) continue;
        int n = ArraySize(m_pattern_types);
        ArrayResize(m_pattern_types,         n + 1);
        ArrayResize(m_pattern_display_names, n + 1);
        m_pattern_types[n] = t;
        string display = StringSubstr(s, StringLen("PATTERN_TYPE_"));
        StringReplace(display, "_", " ");
        m_pattern_display_names[n] = display;
    }
   }
  void CGUIPannel::InitializePatternTable(void)
   {
      int n = ArraySize(m_pattern_types);
      if(n == 0) return;

      m_pattern_table.DeleteAllRows();
      for(int i = 0; i < n - 1; i++)
         m_pattern_table.AddRow(i);

      uint arrow_up[]  = {IMAGE_RESOURCE_ICONS_BMP16_ARROW_UP_BMP};
      uint arrow_dn[]  = {IMAGE_RESOURCE_ICONS_BMP16_ARROW_DOWN_BMP};
      uint chk[]       = {IMAGE_RESOURCE_CONTROLS_CHECKBOXON_BMP,
                        IMAGE_RESOURCE_CONTROLS_CHECKBOXOFF_BMP};      
      for(int i = 0; i < n; i++)
       { 
         m_pattern_table.SetValue(0, i, m_pattern_display_names[i]);
         m_pattern_table.SetValue(1, i, string(CandlesForPatternType(m_pattern_types[i])));// "1", "2", "3"

         m_pattern_table.CellType(2, i, CELL_BUTTON);
         m_pattern_table.SetImages(2, i, arrow_up);   // ▲ static green

         m_pattern_table.CellType(3, i, CELL_CHECKBOX);
         m_pattern_table.SetImages(3, i, chk);
         m_pattern_table.ChangeImage(3, i, 0);        // Bull: default enabled

         m_pattern_table.CellType(4, i, CELL_CHECKBOX);
         m_pattern_table.SetImages(4, i, chk);
         m_pattern_table.ChangeImage(4, i, 0);        // Bear: default enabled

         m_pattern_table.CellType(5, i, CELL_BUTTON);
         m_pattern_table.SetImages(5, i, arrow_dn);   // ▼ static red
       }
      m_pattern_table.Update(true);
   }
  bool CGUIPannel::CreatePatternConfigTable(const int x, const int y)
   {
      m_pattern_table.MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_TRADE_SETTINGS, m_pattern_table);

      m_pattern_table.AutoXResizeMode(true);
      m_pattern_table.AutoXResizeRightOffset(3);
      m_pattern_table.AutoYResizeMode(true);
      m_pattern_table.AutoYResizeBottomOffset(3);
      m_pattern_table.LightsHover(true);
      m_pattern_table.ShowHeaders(true);
      m_pattern_table.SelectableRow(true);
      m_pattern_table.IsSortMode(true);

      m_pattern_table.TableSize(6, ArraySize(m_pattern_types));

      int widths[6]    = {135, 30, 20, 35, 35, 20};
      int img_x_off[6] = {0, 0, 7, 3, 3, 7};
      int img_y_off[6] = {0, 0, 3, 4, 4, 3};
      ENUM_ALIGN_MODE align[6] = {ALIGN_LEFT,ALIGN_CENTER,ALIGN_LEFT,
                                    ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
      m_pattern_table.ColumnsWidth(widths);
      m_pattern_table.ImageXOffset(img_x_off);
      m_pattern_table.ImageYOffset(img_y_off);
      m_pattern_table.TextAlign(align);

      // ← Create BEFORE SetHeaderText
      if(!m_pattern_table.CreateTable(x, y)) return false;

      m_pattern_table.SetHeaderText(0, "Pattern");
      m_pattern_table.SetHeaderText(1, "No");
      m_pattern_table.SetHeaderText(2, "");
      m_pattern_table.SetHeaderText(3, "Bull");
      m_pattern_table.SetHeaderText(4, "Bear");
      m_pattern_table.SetHeaderText(5, "");

      CWndContainer::AddToElementsArray(0, m_pattern_table);
      return true;
   }
 //Adding control for Information windows
  //+------------------------------------------------------------------+
  //| Create the info window                                           |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateInfoWindow(void)
   {    
    CWndContainer::AddWindow(m_info_Window);
    //--- Properties
      m_info_Window.XSize(250);
      m_info_Window.YSize(300);
      m_info_Window.FontSize(9);
      m_info_Window.IsMovable(true);
      m_info_Window.CloseButtonIsUsed(false);
      m_info_Window.CollapseButtonIsUsed(false);
      m_info_Window.FullscreenButtonIsUsed(false);
      m_info_Window.TooltipsButtonIsUsed(false);
      m_info_Window.WindowType(W_DIALOG);
    //--- Create at off-screen position, hidden initially
      if(!m_info_Window.CreateWindow(m_chart_id, m_subwin, "Bar Info", 0, 0)) return(false);
    //--- Create child controls inside this window
      if(!CreateInfoLabels(6, 25))     return false;      
      if(!CreateInfoTabs(3, 120))    return false;
      if(!CreateInfoPatternTable())  return false;      
      return(true);
   } 
  //+------------------------------------------------------------------+
  //| Create tabs at m_info_Window                                                     |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateInfoTabs(const int x_gap, const int y_gap)
   {    
    string tab_names[TAB_INFO_TOTAL] = {"Patterns", "Indicators"};
    //--- Attach to window
      m_tab_info_tabs.MainPointer(m_info_Window);
    //--- Properties
      m_tab_info_tabs.IsCenterText(true);
      m_tab_info_tabs.PositionMode(TABS_TOP);
      m_tab_info_tabs.AutoXResizeMode(true);
      m_tab_info_tabs.AutoYResizeMode(true);
      m_tab_info_tabs.AutoXResizeRightOffset(3);
      m_tab_info_tabs.AutoYResizeBottomOffset(3);
    //--- Add tab
      for(int i = 0; i < TAB_INFO_TOTAL; i++)
         m_tab_info_tabs.AddTab(tab_names[i], 100);
    //--- Create
      if(!m_tab_info_tabs.CreateTabs(x_gap, y_gap))
        return(false);
      CWndContainer::AddToElementsArray(WindowIdx(m_info_Window), m_tab_info_tabs);
        return(true);
   }
  //+------------------------------------------------------------------+
  //| Create text labels for OHLC inside the m_info_Window              |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateInfoLabels(const int x_gap, const int y_gap)
   {
      int       row_h    = 20;
      string    init_texts[] = {"T: -", "O: -", "H: -", "L: -", "C: -"};
      CTextLabel *labels[]   = {&m_lbl_info_time, &m_lbl_info_open, &m_lbl_info_high, &m_lbl_info_low, &m_lbl_info_close};
      for(int i = 0; i < 5; i++)
      {
        //--- Attach to tabs, inside TAB_INFO_BAR
        labels[i].MainPointer(m_info_Window);                
        labels[i].FontSize(9);
        //--- Create        
         if(!labels[i].CreateTextLabel(init_texts[i], x_gap, y_gap + i * row_h))
          return(false);
         CWndContainer::AddToElementsArray(WindowIdx(m_info_Window), *labels[i]);
        
      }
      return(true);
   }
  //+------------------------------------------------------------------+
  //| Create Pattern Table inside the m_info_Window                     |
  //+------------------------------------------------------------------+   
  bool CGUIPannel::CreateInfoPatternTable(void)
   {
         m_tbl_info_pattern_table.MainPointer(m_tab_info_tabs);
         m_tab_info_tabs.AddToElementsArray(TAB_INFO_PATTERNS, m_tbl_info_pattern_table);
         m_tbl_info_pattern_table.AutoXResizeMode(true);
         m_tbl_info_pattern_table.AutoXResizeRightOffset(3);
         m_tbl_info_pattern_table.AutoYResizeMode(true);
         m_tbl_info_pattern_table.AutoYResizeBottomOffset(3);
         m_tbl_info_pattern_table.ShowHeaders(true);
         m_tbl_info_pattern_table.SelectableRow(true);
         m_tbl_info_pattern_table.TableSize(4, 1);
         int widths[4]    = {38, 120, 16, 22};
         int img_x_off[4] = {0, 0, 0, 3};
         int img_y_off[4] = {0, 0, 0, 3};
         ENUM_ALIGN_MODE align[4] = {ALIGN_CENTER, ALIGN_LEFT, ALIGN_CENTER, ALIGN_LEFT};
         m_tbl_info_pattern_table.ColumnsWidth(widths);
         m_tbl_info_pattern_table.ImageXOffset(img_x_off);   
         m_tbl_info_pattern_table.ImageYOffset(img_y_off);   
         m_tbl_info_pattern_table.TextAlign(align);  
         if(!m_tbl_info_pattern_table.CreateTable(3, 3)) return false;

         //Set header 
         m_tbl_info_pattern_table.SetHeaderText(0, "TF");
         m_tbl_info_pattern_table.SetHeaderText(1, "Pattern");
         m_tbl_info_pattern_table.SetHeaderText(2, "#");
         m_tbl_info_pattern_table.SetHeaderText(3, "Dir");
         
         CWndContainer::AddToElementsArray(WindowIdx(m_info_Window), m_tbl_info_pattern_table);
         return true;
   }
 void CGUIPannel::ScanPatternsInfo(CArrayObj *plist, const string symbol,
                                  const ENUM_TIMEFRAMES tf_current, const datetime T)
  {
    //Setting Icon
     uint arrow_up[] = {IMAGE_RESOURCE_ICONS_BMP16_ARROW_UP_BMP};
     uint arrow_dn[] = {IMAGE_RESOURCE_ICONS_BMP16_ARROW_DOWN_BMP};
    m_tbl_info_pattern_table.DeleteAllRows();
    if(plist == NULL) { m_tbl_info_pattern_table.Update(true); return; }

    int row = 0;
     for(int i = 0; i < plist.Total(); i++)
      {
          CBarPattern *p = plist.At(i);
          if(p == NULL) continue;
          if(p.GetProperty(PATTERN_PROP_SYMBOL) != symbol) continue;
          ENUM_TIMEFRAMES p_tf = (ENUM_TIMEFRAMES)p.GetProperty(PATTERN_PROP_PERIOD);
          if((int)p_tf < (int)tf_current) continue;
          datetime p_time = (datetime)p.GetProperty(PATTERN_PROP_TIME);
          if(p_time > T || T >= p_time + PeriodSeconds(p_tf)) continue;

          if(row > 0) m_tbl_info_pattern_table.AddRow(row);


          string tf_str = StringSubstr(EnumToString(p_tf), 7); // "PERIOD_M1"→"M1"
          string name   = p.GetProperty(PATTERN_PROP_NAME);
          int    candles = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          long   dir    = p.GetProperty(PATTERN_PROP_DIRECTION);
          //Update here
            m_tbl_info_pattern_table.SetValue(0, row, tf_str);
            m_tbl_info_pattern_table.SetValue(1, row, name);
            m_tbl_info_pattern_table.SetValue(2, row, string(candles));
            // Col 3: icon
             m_tbl_info_pattern_table.CellType(3, row, CELL_BUTTON);
             if(dir == PATTERN_DIRECTION_BULLISH)
                m_tbl_info_pattern_table.SetImages(3, row, arrow_up);
             else if(dir == PATTERN_DIRECTION_BEARISH)
                m_tbl_info_pattern_table.SetImages(3, row, arrow_dn);
             else // BOTH
              {
                m_tbl_info_pattern_table.CellType(3, row, CELL_SIMPLE);
                m_tbl_info_pattern_table.SetValue(3, row, "±");
              }            
          row++;
      }
      if(row == 0)
          m_tbl_info_pattern_table.SetValue(1, 0, "No patterns");
      m_tbl_info_pattern_table.Update(true);
  }
 //+------------------------------------------------------------------+
 //| Show panel at chart position with bar data                       |
 //+------------------------------------------------------------------+
 void CGUIPannel::ShowInfoWindowAt(const int x, const int y, CBar *bar, const int digits,
                          CArrayObj *plist, const string symbol,
                          const ENUM_TIMEFRAMES tf_current)
  {
      if(bar == NULL) return;     
     // Update ALL OHLC labels
      m_lbl_info_time.LabelText("T: " + TimeToString(bar.Time(), TIME_DATE|TIME_MINUTES));
      m_lbl_info_open.LabelText("O: " + DoubleToString(bar.Open(), digits));
      m_lbl_info_high.LabelText("H: " + DoubleToString(bar.High(), digits));
      m_lbl_info_low.LabelText("L: " + DoubleToString(bar.Low(), digits));
      m_lbl_info_close.LabelText("C: " + DoubleToString(bar.Close(), digits));   
     // Scan patterns
      ScanPatternsInfo(plist, symbol, tf_current, bar.Time());

      // Position với overflow flip
      long chart_w, chart_h;
      ChartGetInteger(0, CHART_WIDTH_IN_PIXELS,  0, chart_w);
      ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, chart_h);
      int px = x + 15;
      int py = y - 10;
      if(px + 250 > (int)chart_w) px = x - 255;
      if(py + 300 > (int)chart_h) py = y - 300;

      m_info_Window.X(px);
      m_info_Window.Y(py);         
      m_active_window_index = WindowIdx(m_info_Window);  
      Moving();
      CWndEvents::Show(m_active_window_index);     // synchronous
      ShowTabElements(m_active_window_index);      // show đúng tab
     // Redraw Label after Moving
      m_lbl_info_time.Draw();   m_lbl_info_time.Draw(); m_lbl_info_time.Update(false);
      m_lbl_info_open.Draw();   m_lbl_info_open.Draw(); m_lbl_info_open.Update(false);
      m_lbl_info_high.Draw();   m_lbl_info_high.Draw(); m_lbl_info_high.Update(false);
      m_lbl_info_low.Draw();    m_lbl_info_low.Draw();  m_lbl_info_low.Update(false);
      m_lbl_info_close.Draw();  m_lbl_info_low.Draw();  m_lbl_info_close.Update(false);
      m_chart.Redraw();
  }

 //+------------------------------------------------------------------+
 //| Hide the panel                                                   |
 //+------------------------------------------------------------------+
 void CGUIPannel::HideInfoWindow(void)
  {   
    int win_idx = WindowIdx(m_info_Window);
    // Hide tất cả child elements trong info window group
      int main_total = MainElementsTotal(win_idx);
      for(int i = 0; i < main_total; i++)
         m_wnd[win_idx].m_main_elements[i].Hide();
    // Hide window canvas
      m_info_Window.Hide();
      m_active_window_index = WindowIdx(m_Mainwindow);
    m_chart.Redraw();
  }
   
  //---------
 //Calculatioon for display in Control
  
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
