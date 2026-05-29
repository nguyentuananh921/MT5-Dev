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
 class CGUIPannel : public CWndEvents
  {
   private: 
    // Private Pointer variables    
      CSymbolsCollection * m_symbols;             //Trading owns
      CBarTimeSeriesCollection  *m_timeseries;    //CBarTimeSeriesCollection owns
      CPatternRenderer* m_renderer;               //EA owns PatternRenderer for display New Patterns
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
    //Test Purpose
      CTextLabel m_test_labels[TABS1_TOTAL];    
   private: // Private methods
     //--- Form
         bool CreateMainWindow(const string text);
     // For Main Tab
         bool CreateTab_Main(const int x_gap, const int y_gap);
     //--- Status bar
         bool CreateStatusBar(const int x_gap, const int y_gap);
         bool UpdateStatusBar(void);

     //For m_treeview_settings Setting Tab at m_tabs_main
        bool CreateTreeView_Settings(void);
        void PopulateTreeFromCollections(void);        
     //Calculation for Control
      double DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0);
   public: // Public methods
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
      //For Pointer      
         void  SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbols = symbols; }      
         void  SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_timeseries = ts; } 
      //Refress GUI
         void   RefreshGUI(void);      
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
    // m_syminfo_mode_changed = false;
      // //For event table
      //    m_events_clicked_row = WRONG_VALUE;
      //    m_events_row_count   = 0;
      //    m_events_filled_count= 0;
   
   } 
  CGUIPannel::~CGUIPannel(void)
   {
   }
 // CGUIPannel Lifecycle
  //+------------------------------------------------------------------+
  //| Init                                                             |
  //+------------------------------------------------------------------+ 
  bool CGUIPannel::OnInitEvent(void)
   {
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
               Print(__FUNCTION__, " > Failed to create Tabs1!");
               return (false);
            }
      //Create control in each tab
         //For Settings Tab at m_tabs_main
            if(!CreateTreeView_Settings()) return false;
            PopulateTreeFromCollections();                       
            m_treeview_settings.UpdateTreeList();
      CWndEvents::CompletedGUI();
      m_chart.Redraw();
      return (true);      
   };
  // OnEvent handler
  void CGUIPannel::OnEvent(const int id, const long &lparam,
                          const double &dparam, const string &sparam)
   {
      //--- Propagate to all elements (ButtonsGroup updates SelectedButtonIndex here)      
                 
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
  //Refresh GUI
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
 //For Setting Tab at m_tabs_main
  bool CGUIPannel::CreateTreeView_Settings(void)
   {
      PopulateTreeFromCollections();
      m_treeview_settings.MainPointer(m_tabs_main);
      m_treeview_settings.AutoXResizeMode(true);
      m_treeview_settings.AutoXResizeRightOffset(3);
      m_treeview_settings.AutoYResizeMode(true);
      m_treeview_settings.AutoYResizeBottomOffset(3);
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


  //---------
 //Calculatioon for display in Control
  
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
