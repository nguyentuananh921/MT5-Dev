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
 //For timeseries data  
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\TickSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Timeseries\PatternRenderer.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>  
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Trading\TradingLevelBubble.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Keys.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\SplitContainer.mqh>

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
   enum ENUM_TAB_SETTING_INFO
    {
      TAB_SETTING_CONFIG =0,   //To Config indicator.
      TAB_SETTING_INFO   =1,   //To Show how many indicator in timeseries ans set show or hide base on template
      TAB_SETTING_TOTAL
    };
   enum ENUM_TAB_CONFIG_DETAIL
    {
      TAB_CONFIG_DETAIL_PARAMS = 0,   // Form Parameter + Add
      TAB_CONFIG_DETAIL_INFO,         // Mô tả/info indicator đang chọn
      TAB_CONFIG_DETAIL_TOTAL
    };
 class CGUIPannel : public CWndEvents
  {
   private: 
    // Private Pointer variables    
      CSymbolsCollection         *m_symbols;              //Trading owns
      CBarTimeSeriesCollection   *m_bar_timeseries;       //CBarTimeSeriesCollection owns
      //CPatternRenderer           *m_renderer;           //EA owns PatternRenderer for display New Patterns
      CBarPatternsControl        *m_pattern_cfg;          // borrowed from EA
      CIndicatorsCollection      *m_indicators_timeseries;// CTimeSeriesEngine owns
      CTickSeriesCollection      *m_tick_series;           // Collection of tick series    
      
      CTimeCounter               m_gui_timecounter;       //--- Time counters
      CKeys                      m_keys;                  //For Keyboard    
    // For trading bubble
      // CTradingLevelBubble        m_trading_bubble;    
    // Control Elements     
      CWindow                    m_Mainwindow;
      CStatusBar                 m_status_bar;
      CTabs                      m_tabs_main;
      //For CTreeView left pannel on tab Setting of m_tabs_main
       CTreeView                  m_treeview_SymbolTF;
       int                        m_sym_tree_pos[];        //To save symbol node list_index  
      //For Indicator TreeViews    
       CTreeView                  m_treeview_indicator;
       string                     m_indicator_table_names[];
       CSplitContainer            m_split_container;       
       int                        m_group_tree_pos[];
       int                        m_type_node_li[];      // list_index của từng node Type (level 1)
       ENUM_INDICATOR             m_type_node_value[];   // ENUM_INDICATOR tương ứng
       struct SIndicatorCatalogItem
         {
            ENUM_INDICATOR        type;
            ENUM_INDICATOR_GROUP  group;
            string                name;
         };  
      //For Indicator Config
         CTabs                m_tabs_indicator_config;     // Panel2 of m_split_container: [Params] [Info]
       // --- Params tab controls (generic fixed-slot form, max 4 params/indicator)
         CTextLabel           m_param_labels[4];
         CTextEdit            m_param_edits[4];
         CButton              m_btn_add_indicator;
         ENUM_INDICATOR       m_current_param_type;     // which type the form is currently showing
         int                  m_current_param_type_li;  // its tree list_index (for tree-node insertion later)
         // --- Info tab: port of V4 m_indicator_table
         CTable               m_indicator_table;
      struct SIndicatorParam
       {
         string        name;          // field label
         ENUM_DATATYPE data_type;     // TYPE_INT or TYPE_DOUBLE
         string        default_value; // shown pre-filled in the edit box
       };          
    // For guard on GUI.
     bool                          m_gui_created;        // guard thay cho s_gui_ready trong EA     
   private: // Private methods
     //For GUI
       bool                            CreateGUIPannel(); 
     //--- Form
         int                           WindowIdx(CWindow &wnd);
         bool                          CreateMainWindow(const string text);
     // For Main Tab
         bool                          CreateTab_Main(const int x_gap, const int y_gap);
     //--- Status bar
         bool                          CreateStatusBar(const int x_gap, const int y_gap);
         bool                          UpdateStatusBar(void);
     //For TreeView
       // Symbol TF TreeView m_treeview_SymbolTF        
        bool                          CreateTreeView_SymbolTF(const int x_gap, const int y_gap);               
        void                          PopulateSymbolTFTree(void);       
        void                          ApplyHighlightSymbolTFTree(void);
       //Indicator TreeView m_treeview_indicator.
         void                          GetIndicatorCatalog(SIndicatorCatalogItem &out[]);
         void                          AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[]);
         void                          PopulateIndicatorTree(void);
         bool                          CreateTreeView_Indicator(const int x_gap, const int y_gap);
         bool                          Create_SplitContainer(const int x_gap, const int y_gap);
         int                           GetIndicatorParamSchema(const ENUM_INDICATOR type, SIndicatorParam &out[]);
         bool                          CreateConfigDetailTabs(const int x_gap, const int y_gap);
         bool                          CreateParamsTab(const int x_gap, const int y_gap);
         void                          ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li);
         void                          OnClickAddIndicator(void);
         bool                          CreateIndicatorTable(const int x, const int y);
         void                          SetValuesToIndicatorTable(void);
         
       //-------
        void                          OnClickShowLine(const string sname, const int row);
        void                          OnClickToggleBuySignal(const string sname, const int row);
        void                          OnClickToggleSellSignal(const string sname, const int row);
        void                          OnClickRemoveIndicator(const string sname, const int row);  
     //Calculation for Control
      double                          DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0);
   public: 
      // lifecycle method
                                      CGUIPannel(void);
                                      ~CGUIPannel(void);
       bool                           OnInitEvent(const int uninit_reason = REASON_PROGRAM);
       void                           OnDeinitEvent(const int reason);
       void                           OnTimerEvent(void);
       void                           OnTickEvent(void);
       virtual void                   OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
       //--- Trading event handler
         void                           OnTradeEvent(void);
       //For GUI
        void                           UpdateGUI(const bool redraw = false);        
        CWindow *                      GetMainWindowPointer(void) { return &m_Mainwindow; }
      //For Pointer      
        void                           SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbols = symbols; }      
        void                            SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_bar_timeseries = ts; }         
        //void  SetPatternRenderer(CPatternRenderer* renderer) { m_renderer = renderer; }
        void                           SetPatternsControl(CBarPatternsControl* ctrl) { m_pattern_cfg = ctrl; } 
        void                           SetIndicatorsCollection(CIndicatorsCollection *ind) { m_indicators_timeseries = ind; }
        //void  SetTickSeriesCollection(CTickSeriesCollection *ticks) { m_tick_series = ticks; }
        //void  SetMarketCollection(CMarketCollection *market)      { m_trading_bubble.SetMarketCollection(market); }
        //void  SetTradingControl(CTradingControl *trading_control) { m_trading_bubble.SetTradingControl(trading_control); }   
  };
#endif // CGUIPANNEL_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
 //| Constructor/Destructor                                           | 
  CGUIPannel::CGUIPannel(void)
   {
    //--- Setting parameters for the time counters
      m_gui_timecounter.SetParameters(16, 500);           
      //m_renderer = NULL;
      m_indicators_timeseries = NULL;
      //m_tick_series = NULL;
      m_gui_created     = false;      
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
  bool CGUIPannel::OnInitEvent(const int uninit_reason)
   {      
    if(!m_gui_created)
     {
      if(!CreateGUIPannel()) return false;
      m_gui_created = true;         
      UpdateGUI(true);
    }  
   else if(uninit_reason == REASON_CHARTCHANGE)
    {      
      UpdateGUI(true);
    }   
   return true;           
   };
  // OnEvent handler
  void CGUIPannel::OnEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
   {
    //Handle Indicator TreeView Click
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_treeview_indicator.Id())
      {
         int li = (int)dparam;
         if(li < 0 || li >= m_treeview_indicator.ItemsTotal()) return;
         for(int i = 0; i < ArraySize(m_type_node_li); i++)
         {
            if(m_type_node_li[i] == li)
            {
               ShowIndicatorParameterForm(m_type_node_value[i], li);
               break;
            }
         }
         return;
      }
    //Handle Add Indicator
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_add_indicator.Id())
      {
         OnClickAddIndicator();
         return;
      }
    //Handle m_indicator_table event
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
        && lparam == m_indicator_table.Id())
      {
         string parts[];
         if(StringSplit(sparam, '_', parts) != 2) return;
         int col = (int)StringToInteger(parts[0]);
         int row = (int)StringToInteger(parts[1]);
         if(row < 0 || row >= ArraySize(m_indicator_table_names)) return;
         string sname = m_indicator_table_names[row];

         if(col == 0)        OnClickShowLine(sname, row);     // toggle ChartIndicatorAdd/Delete
         else if(col == 3)    OnClickToggleBuySignal(sname, row);
         else if(col == 4)    OnClickToggleSellSignal(sname, row);
         else if(col == 5)    OnClickRemoveIndicator(sname, row);
         return;
      }  
    //Handle Symbol TF TreeView Click     
     //ON_CLICK_BUTTON 
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON  && lparam == m_treeview_SymbolTF.Id())
       {
         int li = (int)dparam;
         // ADDED: guard against stale/out-of-range list_index from event queue.
         // ItemPointer() clamps silently so item != NULL even for invalid li;
         // this early return prevents navigating to the wrong node.
         if(li < 0 || li >= m_treeview_SymbolTF.ItemsTotal()) return;
         CTreeItem *item = m_treeview_SymbolTF.ItemPointer(li);
         //Print Debug            
            // Print("My debug from CGUIPannel::OnEvent [ON_CLICK_BUTTON] ", " lparam = ",lparam," dparam= ",sparam," sparam= ",sparam,"\n",
            // "li= ",li, " item=", (item != NULL ? "OK" : "NULL"),
            // " item nodelevel = ",string(item.NodeLevel()),
            // " Itemtype= ", (item != NULL ? (string)item.ItemType() : "N/A"),
            // " TI_HAS_ITEMS= ", (string)TI_HAS_ITEMS," item_state= ", (item != NULL ? (string)item.ItemState() : "N/A"),
            // " parent_pos= ", m_treeview_settings.ItemPrevNode(li));  // safe: ItemPrevNode now has bounds check
         //--------------------------------
         if(item == NULL) return;
         int parent_pos = m_treeview_SymbolTF.ItemPrevNode(li);
         if(parent_pos == -1)  // Symbol node
          {
            if(item.ItemType() == TI_SIMPLE) //No TF Found                        
              ChartSetSymbolPeriod(0, item.LabelText(), _Period);
          }
         else // TF node → navigate to exact sym + tf
          {  
            CTreeItem *parent = m_treeview_SymbolTF.ItemPointer(parent_pos);
            if(parent != NULL)
             {                  
               ChartSetSymbolPeriod(0,parent.LabelText(),TimestampByDescription(item.LabelText()));
             }                  
          }        
         return;
         }
    //CHARTEVENT_CHART_CHANGE
     if(id == CHARTEVENT_CHART_CHANGE)
      {       
       // Guard 1: rebuild tree only on symbol/TF change
        static string          last_sym = "";
        static ENUM_TIMEFRAMES last_tf  = PERIOD_CURRENT;
        if(_Symbol != last_sym || _Period != last_tf)
         {
            last_sym = _Symbol;
            last_tf  = _Period;            
            PopulateSymbolTFTree();               
            ApplyHighlightSymbolTFTree();
            m_chart.Redraw();
         }  
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
      //m_trading_bubble.OnDeinitEvent();
      if(reason != REASON_CHARTCHANGE)
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

      ulong t0 = ::GetMicrosecondCount();

      CWndEvents::OnTimerEvent();

      ulong t1 = ::GetMicrosecondCount();

      //m_trading_bubble.OnPoll();
      
      ulong t2 = ::GetMicrosecondCount();
      if(t2 - t0 > 1000)
       Print("PERF CGUIPannel::OnTimerEvent CWndEvents::OnTimerEvent= ", t1 - t0, " us CTradingLevelBubble::OnPoll= ", t2 - t1, " us");
   }
  //+------------------------------------------------------------------+
  //| Trade operation event                                            |
  //+------------------------------------------------------------------+
  void CGUIPannel::OnTradeEvent(void)
   {      
   }
 //For GUIPannel
  bool CGUIPannel::CreateGUIPannel(void) 
   { 
      //DiscoverPatterns(); //Call before CreatePatternConfigTable
      //--- Creating form 1 for controls
      //Create control
       if (!CreateMainWindow("EXPERT PANEL Ver5"))
         {
            Print(__FUNCTION__, " > Failed to create panel!");
            return (false);
         }
       if (!CreateStatusBar(1, 23))
         {
            Print(__FUNCTION__, " > Failed to create Status Bar!");
            return (false);
         }      
       if (!CreateTab_Main(115, 43))
         {
            //Print(__FUNCTION__, " > Failed to create Tabs1!");
            return (false);
         }
        PopulateSymbolTFTree();
        if(!CreateTreeView_SymbolTF(10,22)) return false;  
        ApplyHighlightSymbolTFTree(); 
      //Create control in each tab
       //For Settings Tab at m_tabs_main       
        PopulateIndicatorTree();        
        if(!Create_SplitContainer(10, 22)) return false;
        if(!CreateTreeView_Indicator(0, 0)) return false;   
        if(!CreateConfigDetailTabs(5, 5)) return false;   
      //m_tabs_main.ShowTabElements(); //Need verify
      CWndEvents::CompletedGUI();
       
      //Debug
        //  Print("My Debug CreateGUIPannel END m_split_container.IsVisible=", m_split_container.IsVisible(),
        //  " m_config_detail_tabs.IsVisible=", m_tabs_indicator_config.IsVisible(),
        //  " m_tabs_main.SelectedTab=", m_tabs_main.SelectedTab());
      return true;
   }   
  //+------------------------------------------------------------------+
  //| Update GUI                                                       |
  //+------------------------------------------------------------------+
  void CGUIPannel::UpdateGUI(const bool redraw)
   {
      // Treeview: new items → CreateItemsFrom, existing only → re-render
       m_treeview_SymbolTF.Update(true);
      // Tables: resize canvas + draw all rows
         //m_pattern_table.Update(true);
         //m_indicator_table.Update(true);
         //SetValuesToIndicatorTable();   
      if(redraw) m_chart.Redraw();
   }  
 //For Control Create GUI controls  
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
         deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ARROW_UP_PNG);
         deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG);
         deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
         deposit_item.ChangeImage(0, 2); // default: gray
         deposit_item.LabelXGap(14);     // shift text right for icon
      //--- Setup icons for Profit item (arrow up=profit, arrow down=loss, gray=zero)
         CTextLabel *profit_item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
         profit_item.AddImagesGroup(2, 6); // x_gap=2, y_gap=6
         profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ARROW_UP_PNG);
         profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG);
         profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
         profit_item.ChangeImage(0, 2); // default: gray
         profit_item.LabelXGap(14);     // shift text right for icon
      //--- Add the object to the common array of object groups      
         CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_status_bar);         
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
       CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_tabs_main);      
      return (true);
    } 
   //For Tab Setting at m_tabs_main   
   //For SplitContainer
    bool CGUIPannel::Create_SplitContainer(const int x_gap, const int y_gap)
     {
      // --- SplitContainer nằm trong tab Settings
       m_split_container.MainPointer(m_tabs_main);
       m_split_container.AutoXResizeMode(true);
       m_split_container.AutoYResizeMode(true);
       m_split_container.AutoYResizeBottomOffset(25);
       //m_split_container.SplitX(150);
       if(!m_split_container.CreateSplitContainer(x_gap, y_gap)) return false;
       m_tabs_main.AddToElementsArray(TAB_TAB_TRADE_SETTINGS, m_split_container);
       CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_split_container);
       return true;
     }
    // For TreeView Indicator at m_split_container Panel1
    bool CGUIPannel::CreateTreeView_Indicator(const int x_gap, const int y_gap)
     {
      // --- TreeView nằm Panel1 (trái) của m_split_container
       m_treeview_indicator.MainPointer(m_split_container);
       m_treeview_indicator.AutoXResizeMode(false);
       m_treeview_indicator.XSize(150);
       m_treeview_indicator.AutoYResizeMode(true);
       m_treeview_indicator.VisibleItemsTotal(15);
       m_treeview_indicator.LightsHover(true);
      //Create treeview
       if(!m_treeview_indicator.CreateTreeView(x_gap, y_gap)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_treeview_indicator);
       m_split_container.SetPanel1(m_treeview_indicator);
       return true;
     }
    // =====================================================================
    // --- Create Panel2 container + both sub-tabs, called from CreateTreeView_Indicator()
    // =====================================================================
    bool CGUIPannel::CreateConfigDetailTabs(const int x_gap, const int y_gap)
      {
       // --- Panel2 m_split_container container for m_tabs_indicator_config tab_Settings
        m_tabs_indicator_config.MainPointer(m_split_container);
        m_tabs_indicator_config.IsCenterText(true);
        m_tabs_indicator_config.PositionMode(TABS_TOP);
        m_tabs_indicator_config.AutoXResizeMode(true);
        m_tabs_indicator_config.AutoYResizeMode(true);
        m_tabs_indicator_config.AddTab("Params", 70);
        m_tabs_indicator_config.AddTab("Info", 70);
       // --- Tạo thẳng ở đúng vị trí Panel2 (sau splitter), không tạo ở x_gap rồi dịch lại sau
        if(!m_tabs_indicator_config.CreateTabs(m_split_container.SplitX() + 4, y_gap)) return false;
        CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_tabs_indicator_config);
        m_split_container.SetPanel2(m_tabs_indicator_config);
        if(!CreateParamsTab(5, 5)) return false;
        if(!CreateIndicatorTable(5, 5)) return false;
        m_tabs_indicator_config.CElementBase::IsVisible(true);
        m_tabs_indicator_config.ShowTabElements();
       //Debug 
        Print("My Debug CGUIPannel::CreateConfigDetailTabs AFTER ShowTabElements btn IsVisible=", m_btn_add_indicator.IsVisible(),
          " selected_tab=", m_tabs_indicator_config.SelectedTab());
          string btn_obj = m_btn_add_indicator.CanvasPointer().ChartObjectName();
        Print("My Debug CGUIPannel::CreateConfigDetailTabs btn NATIVE obj=", btn_obj,
            " exists_subwin=", ObjectFind(0, btn_obj),
            " X=", ObjectGetInteger(0, btn_obj, OBJPROP_XDISTANCE),
            " Y=", ObjectGetInteger(0, btn_obj, OBJPROP_YDISTANCE),
            " XSIZE=", ObjectGetInteger(0, btn_obj, OBJPROP_XSIZE),
            " YSIZE=", ObjectGetInteger(0, btn_obj, OBJPROP_YSIZE),
            " TIMEFRAMES=", ObjectGetInteger(0, btn_obj, OBJPROP_TIMEFRAMES),
            " ZORDER=", ObjectGetInteger(0, btn_obj, OBJPROP_ZORDER),
            " HIDDEN=", ObjectGetInteger(0, btn_obj, OBJPROP_HIDDEN),
            " BACK=", ObjectGetInteger(0, btn_obj, OBJPROP_BACK));
       return true;
      }
    // =====================================================================
    // --- Info tab: port of V4 m_indicator_table, same 5-column layout
    // =====================================================================
   bool CGUIPannel::CreateIndicatorTable(const int x, const int y)
    {
      m_indicator_table.MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_INFO, m_indicator_table);
      m_indicator_table.AutoXResizeMode(true);
      m_indicator_table.AutoXResizeRightOffset(3);
      m_indicator_table.AutoYResizeMode(true);
      m_indicator_table.AutoYResizeBottomOffset(3);
      m_indicator_table.ShowHeaders(true);
      m_indicator_table.SelectableRow(true);
      m_indicator_table.LightsHover(true);
      m_indicator_table.IsSortMode(true);
      m_indicator_table.TableSize(6, 20);
      int widths[6]    = {30, 130, 70, 40, 40, 30};
      int img_x_off[6] = {3,  0,   0,  10, 10, 3};
      int img_y_off[6] = {3,  0,   0,  3,  3,  3};
      ENUM_ALIGN_MODE align[6] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
      m_indicator_table.ColumnsWidth(widths);
      m_indicator_table.ImageXOffset(img_x_off);
      m_indicator_table.ImageYOffset(img_y_off);
      m_indicator_table.TextAlign(align);

      if(!m_indicator_table.CreateTable(x, y)) return false;
      m_indicator_table.SetHeaderText(0, "");
      m_indicator_table.SetHeaderText(1, "Indicator");
      m_indicator_table.SetHeaderText(2, "Group");
      m_indicator_table.SetHeaderText(3, "Buy");
      m_indicator_table.SetHeaderText(4, "Sell");
      m_indicator_table.SetHeaderText(5, "");

     CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_indicator_table);
     return true;
    }
   void CGUIPannel::SetValuesToIndicatorTable(void)
    {
      //Debug
       Print("My Debug SetValuesToIndicatorTable ENTER m_indicators_timeseries=", (m_indicators_timeseries==NULL?"NULL":"OK"));
      if(m_indicators_timeseries == NULL) return;
      string sym = ::Symbol();
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
      Print("My Debug SetValuesToIndicatorTable sym=", sym, " tf=", EnumToString(tf));

      CArrayObj *list = m_indicators_timeseries.GetListIndBySymbol(sym);
      Print("My Debug SetValuesToIndicatorTable GetListIndBySymbol total=", (list==NULL?-1:list.Total()));

      list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      Print("My Debug SetValuesToIndicatorTable after ByIndicatorProperty total=", (list==NULL?-1:list.Total()));
   
      if(list == NULL || list.Total() == 0)
        {
          m_indicator_table.DeleteAllRows();
          m_indicator_table.Update(true);
          return;
        }

      string names[]; int groups[]; int line_states[]; bool has_signal[]; int count = 0;
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
      for(int i = 0; i < list.Total(); i++)
        {
            CIndicatorDE *ind = list.At(i);
            if(ind == NULL) continue;
            string sname = ind.ShortName();
            bool dup = false;
            for(int n = 0; n < count; n++)
              if(names[n] == sname) { dup = true; break; }
            if(dup) continue;
            bool on_chart = false;
            for(int sub = 0; sub < subwindows && !on_chart; sub++)
              for(int k = ChartIndicatorsTotal(0, sub) - 1; k >= 0; k--)
                  if(ChartIndicatorName(0, sub, k) == sname) { on_chart = true; break; }
            ArrayResize(names, count + 1);
            ArrayResize(groups, count + 1);
            ArrayResize(line_states, count + 1);
            ArrayResize(has_signal, count + 1);
            names[count]       = sname;
            groups[count]      = (int)ind.Group();
            line_states[count] = on_chart ? 0 : 1;
            has_signal[count]  = ind.HasSignal();   // chỉ cho click Buy/Sell nếu loại này thực có Signal
            count++;
          }
      if(count == 0) return;

      m_indicator_table.DeleteAllRows();
      for(int i = 0; i < count - 1; i++)
         m_indicator_table.AddRow(i);

      uint green[] = {IMAGE_RESOURCE_BMP16_START_BMP};
      uint red[]   = {IMAGE_RESOURCE_BMP16_STOP_BMP};
      uint chk[]   = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_BMP};
      string group_names[] = {"Trend", "Oscillator", "Volumes", "Arrows"};
      for(int row = 0; row < count; row++)
        {
          m_indicator_table.CellType(0, row, CELL_BUTTON);
          m_indicator_table.SetImages(0, row, green);
          m_indicator_table.ChangeImage(0, row, 0);
          m_indicator_table.SetValue(1, row, "  " + names[row]);
          string gname = (groups[row] >= 0 && groups[row] < 4) ? group_names[groups[row]] : "Other";
          m_indicator_table.SetValue(2, row, "  " + gname);

          // --- Buy / Sell checkboxes: only meaningful when this indicator has a Signal
          m_indicator_table.CellType(3, row, CELL_CHECKBOX);
          m_indicator_table.SetImages(3, row, chk);
          m_indicator_table.ChangeImage(3, row, has_signal[row] ? 1 : 1);   // default unchecked
          m_indicator_table.CellType(4, row, CELL_CHECKBOX);
          m_indicator_table.SetImages(4, row, chk);
          m_indicator_table.ChangeImage(4, row, has_signal[row] ? 1 : 1);   // default unchecked

          m_indicator_table.CellType(5, row, CELL_BUTTON);
          m_indicator_table.SetImages(5, row, red);
          m_indicator_table.ChangeImage(5, row, 0);
        }
      m_indicator_table.Update(true);
    }
  //For Symbol TF treeview
   bool CGUIPannel::CreateTreeView_SymbolTF(const int x_gap, const int y_gap)
    { 
      
       m_treeview_SymbolTF.MainPointer(m_Mainwindow);
       m_treeview_SymbolTF.AutoXResizeMode(false);  // fixed width
       m_treeview_SymbolTF.XSize(100);              // tree chiếm 100px bên trái
       m_treeview_SymbolTF.AutoYResizeMode(true);
       m_treeview_SymbolTF.VisibleItemsTotal(15);
       m_treeview_SymbolTF.LightsHover(true);
       m_treeview_SymbolTF.AutoYResizeBottomOffset(25);
       if(!m_treeview_SymbolTF.CreateTreeView(x_gap, y_gap)) return false;      
       CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_treeview_SymbolTF);      
       return true;
    }  
   void CGUIPannel::PopulateSymbolTFTree(void)
    {
      //=== DEBUG: trang thai luc vao ham ===
         // Print("My Debug PopulateSymbolTFTree ENTER  m_timeseries=", (m_timeseries == NULL ? "NULL" : "OK"),
         //       "  mw_total=", ::SymbolsTotal(true),
         //       "  ItemsTotal_before=", m_treeview_settings.ItemsTotal());

      if(m_bar_timeseries == NULL) return;
      int mw_total = ::SymbolsTotal(true);

      // Grow registry if MarketWatch expanded
       if(ArraySize(m_sym_tree_pos) < mw_total)
        {
         int old = ArraySize(m_sym_tree_pos);
         ArrayResize(m_sym_tree_pos, mw_total);
         ArrayFill  (m_sym_tree_pos, old, mw_total - old, -1);
        }
       for(int i = 0; i < mw_total; i++)
        {
          string            sym_name = ::SymbolName(i, true);
          //=== DEBUG: xem i <-> sym_name co on dinh giua cac lan goi khong ===
            // Print("My Debug CGUIPannel::PopulateSymbolTFTree FOR LOOP i=", i, " sym_name=", sym_name,
            //       " m_sym_tree_pos[i]=", m_sym_tree_pos[i]);

          CBarTimeSeriesDE *bts      = m_bar_timeseries.GetTimeseries(sym_name);
          CArrayObj        *list     = (bts != NULL) ? bts.GetListSeries() : NULL;
          int               tf_cnt   = (list != NULL) ? list.Total() : 0;

          // Step 1: Ensure sym node exists
           if(m_sym_tree_pos[i] == -1)
            {
             int sym_li = m_treeview_SymbolTF.ItemsTotal();
             m_sym_tree_pos[i] = sym_li;
             // AddTreeItem() auto-increments parent count + sets state when TF children are added
              m_treeview_SymbolTF.AddTreeItem(sym_li, 
                                          -1, //prev_node_list_index
                                          sym_name, 
                                          IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                          i, 
                                          0, //node_level symnode = 0 Node level must be >=0
                                          0,
                                          0, 0, 
                                          false,    //item_state, m_t_item_state[]=true
                                          false      //is_folder m_t_is_folder[]=false
                                          );             
            }            
           int sym_li = m_sym_tree_pos[i];
           if(tf_cnt == 0) continue;   //No TF found on sym_li
          // Step 2: Collect existing TF children of sym_li node
           int children[];
           ArrayResize(children, 0);
           int total_now = m_treeview_SymbolTF.ItemsTotal();
           for(int j = 0; j < total_now; j++)
            if(m_treeview_SymbolTF.ItemPrevNode(j) == sym_li)
             {
               int sz = ArraySize(children);
               ArrayResize(children, sz + 1);
               children[sz] = j;
             }
           int child_count = ArraySize(children);
          // Step 3: Match bts[k] against children[k]
           int actual_sym_li = -1;     
           for(int k = 0; k < tf_cnt; k++)
            {
             CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
             if(s == NULL) continue;
             string actual = TimeframeDescription(s.Timeframe());
             if(k < child_count)
              {
               // Slot exists — Bug B: update label if period changed
               CTreeItem *ti = m_treeview_SymbolTF.ItemPointer(children[k]);
               if(ti != NULL && ti.LabelText() != actual)
               { ti.LabelText(actual); ti.Update(true); }
              }
             else
              {
               // New slot — add TF node
                m_treeview_SymbolTF.AddTreeItem(m_treeview_SymbolTF.ItemsTotal(), sym_li, 
                                          actual,
                                          IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP,
                                          k, 1, i, 0, 0, 
                                          true,   //item_state, m_t_item_state[]=true;
                                          false   //is_folder m_t_is_folder[]=false
                                       );
               //Register new CTreeItem  
                CTreeItem *new_item = m_treeview_SymbolTF.ItemPointer(m_treeview_SymbolTF.ItemsTotal() - 1);
                if(new_item != NULL)
                  CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), *new_item);
             }
            }
          // //=== DEBUG: dump TOAN BO item sau khi populate xong ===
            //  int dbg_total = m_treeview_settings.ItemsTotal();
            //    Print("My Debug PopulateSymbolTFTree EXIT  ItemsTotal_after=", dbg_total);
            //    for(int k = 0; k < dbg_total; k++)
            //       {
            //       CTreeItem *dbg_it = m_treeview_settings.ItemPointer(k);
            //       if(dbg_it == NULL) continue;
            //       Print("My Debug CGUIPannel::PopulateSymbolTFTree idx=", k,
            //             " text=", dbg_it.LabelText(),
            //             " nodeLevel=", dbg_it.NodeLevel(),
            //             " prevNode=", m_treeview_settings.ItemPrevNode(k),
            //             " arrowXGap=", dbg_it.ArrowXGap(),
            //             " iconXGap=", dbg_it.IconXGap());
            //       }
        }
    }  
   void CGUIPannel::ApplyHighlightSymbolTFTree(void)
    {
      string chart_tf = TimeframeDescription(_Period);
      int    total    = m_treeview_SymbolTF.ItemsTotal();  // duyệt tất cả items

      for(int i = 0; i < total; i++)
       {
         CTreeItem *item = m_treeview_SymbolTF.ItemPointer(i);
         if(item == NULL) continue;

         int parent_pos = m_treeview_SymbolTF.ItemPrevNode(i);

         if(parent_pos == -1)  // sym node
          {

            bool active = (item.LabelText() == _Symbol);
            if(item.ItemType() == TI_HAS_ITEMS)
             {
               item.IsActive(active);
               item.Draw();
               item.CanvasPointer().Update(false);
             }
            else
             item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP
                                    : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
          }
         else  // TF node
          {
               CTreeItem *parent_item = m_treeview_SymbolTF.ItemPointer(parent_pos);
               bool parent_is_active  = (parent_item != NULL && parent_item.LabelText() == _Symbol);
               bool highlight = (parent_is_active && item.LabelText() == chart_tf);
               item.IconFile(highlight ? IMAGE_RESOURCE_BMP16_BAR_CHART_BMP
                                 : IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP);
          }
        }
      m_treeview_SymbolTF.RedrawTreeList(); 
      m_treeview_SymbolTF.UpdateTreeList(true);
    } 
 
 // =====================================================================
 // --- "Add" button click handler — converts text fields to MqlParam[]
 // =====================================================================
  void CGUIPannel::OnClickAddIndicator(void)
    {
      Print("My Debug OnClickAddIndicator type=", EnumToString(m_current_param_type), " type_li=", m_current_param_type_li);
      SIndicatorParam schema[];
      int total = GetIndicatorParamSchema(m_current_param_type, schema);
      Print("My Debug OnClickAddIndicator schema total=", total);
      if(total == 0) return;

      MqlParam params[];
      ArrayResize(params, total);
      for(int i = 0; i < total; i++)
       {
         params[i].type = schema[i].data_type;
         string text = m_param_edits[i].GetValue();
         if(schema[i].data_type == TYPE_DOUBLE)
           params[i].double_value = StringToDouble(text);
         else
           params[i].integer_value = (long)StringToInteger(text);
       }
      AddIndicatorInstance(m_current_param_type_li, m_current_param_type, params);
    }
  void CGUIPannel::AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[])
   {
     //Debug 
       Print("My Debug CGUIPannel::AddIndicatorInstance ENTER type=", EnumToString(type), " m_bar_timeseries=", (m_bar_timeseries==NULL?"NULL":"OK"), " m_indicators_timeseries=", (m_indicators_timeseries==NULL?"NULL":"OK"));
     int mw_total = ::SymbolsTotal(true);
     bool created_any = false;

     for(int i = 0; i < mw_total; i++)
       {
         string sym_name = ::SymbolName(i, true);
         CBarTimeSeriesDE *bts  = m_bar_timeseries.GetTimeseries(sym_name);
         CArrayObj        *list = (bts != NULL) ? bts.GetListSeries() : NULL;
         int tf_cnt = (list != NULL) ? list.Total() : 0;
         //Debug 
          Print("My Debug CGUIPannel::AddIndicatorInstance sym=", sym_name, " bts=", (bts==NULL?"NULL":"OK"), " tf_cnt=", tf_cnt);
         if(tf_cnt == 0) continue;
         for(int k = 0; k < tf_cnt; k++)
          {
            CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
            if(s == NULL) continue;
            CIndicatorDE *indicator = m_indicators_timeseries.CreateIndicator(type, params, sym_name, s.Timeframe());
             Print("My Debug CGUIPannel::AddIndicatorInstance CreateIndicator sym=", sym_name, " tf=", EnumToString(s.Timeframe()), " result=", (indicator==NULL?"NULL":"OK"));
            if(indicator != NULL) created_any = true;
          }
       }
      //Debug 
         Print("My Debug CGUIPannel::AddIndicatorInstance created_any=", created_any);
      if(!created_any) return;
      CTreeItem *type_item = m_treeview_indicator.ItemPointer(type_li);
      if(type_item != NULL) type_item.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
      int group_li = m_treeview_indicator.ItemPrevNode(type_li);
      CTreeItem *group_item = m_treeview_indicator.ItemPointer(group_li);
      if(group_item != NULL) group_item.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);

      SetValuesToIndicatorTable();
      //m_chart.Redraw();
   }  
  void CGUIPannel::PopulateIndicatorTree(void)
   {
      string group_names[4] = {"Trend", "Oscillator", "Volumes", "Arrows"};
      ENUM_INDICATOR_GROUP group_values[4] = {INDICATOR_GROUP_TREND, INDICATOR_GROUP_OSCILLATOR, INDICATOR_GROUP_VOLUMES, INDICATOR_GROUP_ARROWS};

      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);
      ArrayResize(m_group_tree_pos, 4); 
      for(int g = 0; g < 4; g++)
       {
         int root_li = m_treeview_indicator.ItemsTotal();
         m_group_tree_pos[g] = root_li;
         m_treeview_indicator.AddTreeItem(root_li,
                                        -1,                          // prev_node_list_index = -1 (root)
                                        group_names[g],
                                        IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                        g, 0,                        // item_index, node_level = 0
                                        0, 0, 0,
                                        true, true);                 // item_state, is_folder

         int k = 0;
         for(int i = 0; i < ArraySize(catalog); i++)
          {
            if(catalog[i].group != group_values[g]) continue;
            int child_li = m_treeview_indicator.ItemsTotal();
            m_treeview_indicator.AddTreeItem(child_li, root_li, catalog[i].name,
                                           IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                           k, 1, g, 0, 0, true, true);
            // --- KHÔNG còn gọi leaf.Index(...) nữa — lưu mapping riêng
            int sz = ArraySize(m_type_node_li);
            ArrayResize(m_type_node_li, sz + 1);
            ArrayResize(m_type_node_value, sz + 1);
            m_type_node_li[sz]    = child_li;
            m_type_node_value[sz] = catalog[i].type;
            k++;
          }
       }
   }
  
  void CGUIPannel::GetIndicatorCatalog(SIndicatorCatalogItem &out[])
   {
    SIndicatorCatalogItem list[] =
     {
      // --- Trend
      {IND_SAR,        INDICATOR_GROUP_TREND,      "PSAR"},
      {IND_MA,         INDICATOR_GROUP_TREND,      "MA"},
      {IND_BANDS,      INDICATOR_GROUP_TREND,      "BBands"},
      {IND_ALLIGATOR,  INDICATOR_GROUP_TREND,      "Alligator"},
      {IND_ICHIMOKU,   INDICATOR_GROUP_TREND,      "Ichimoku"},
      {IND_ENVELOPES,  INDICATOR_GROUP_TREND,      "Envelopes"},
      {IND_FRAMA,      INDICATOR_GROUP_TREND,      "FRAMA"},
      {IND_AMA,        INDICATOR_GROUP_TREND,      "AMA"},
      {IND_DEMA,       INDICATOR_GROUP_TREND,      "DEMA"},
      {IND_TEMA,       INDICATOR_GROUP_TREND,      "TEMA"},
      {IND_VIDYA,      INDICATOR_GROUP_TREND,      "VIDYA"},
      {IND_ADX,        INDICATOR_GROUP_TREND,      "ADX"},
      {IND_ADXW,       INDICATOR_GROUP_TREND,      "ADX Wilder"},
      {IND_STDDEV,     INDICATOR_GROUP_TREND,      "StdDev"},

      // --- Oscillator
      {IND_RSI,        INDICATOR_GROUP_OSCILLATOR, "RSI"},
      {IND_MACD,       INDICATOR_GROUP_OSCILLATOR, "MACD"},
      {IND_STOCHASTIC, INDICATOR_GROUP_OSCILLATOR, "Stochastic Oscillator"},
      {IND_CCI,        INDICATOR_GROUP_OSCILLATOR, "CCI"},
      {IND_MOMENTUM,   INDICATOR_GROUP_OSCILLATOR, "Momentum"},
      {IND_DEMARKER,   INDICATOR_GROUP_OSCILLATOR, "DeMarker"},
      {IND_RVI,        INDICATOR_GROUP_OSCILLATOR, "Relative Vigor Index"},
      {IND_WPR,        INDICATOR_GROUP_OSCILLATOR, "Williams' Percent Range"},
      {IND_OSMA,       INDICATOR_GROUP_OSCILLATOR, "OsMA"},
      {IND_TRIX,       INDICATOR_GROUP_OSCILLATOR, "Triple Exponential Average"},
      {IND_ATR,        INDICATOR_GROUP_OSCILLATOR, "Average True Range"},
      {IND_FORCE,      INDICATOR_GROUP_OSCILLATOR, "Force Index"},
      {IND_AO,         INDICATOR_GROUP_OSCILLATOR, "Awesome Oscillator"},
      {IND_AC,         INDICATOR_GROUP_OSCILLATOR, "Accelerator Oscillator"},
      {IND_GATOR,      INDICATOR_GROUP_OSCILLATOR, "Gator Oscillator"},
      {IND_BEARS,      INDICATOR_GROUP_OSCILLATOR, "Bears Power"},
      {IND_BULLS,      INDICATOR_GROUP_OSCILLATOR, "Bulls Power"},
      {IND_CHAIKIN,    INDICATOR_GROUP_OSCILLATOR, "Chaikin Oscillator"},

      // --- Volumes
      {IND_OBV,        INDICATOR_GROUP_VOLUMES,    "On Balance Volume"},
      {IND_AD,         INDICATOR_GROUP_VOLUMES,    "Accumulation/Distribution"},
      {IND_MFI,        INDICATOR_GROUP_VOLUMES,    "Money Flow Index"},
      {IND_VOLUMES,    INDICATOR_GROUP_VOLUMES,    "Volumes"},
      {IND_BWMFI,      INDICATOR_GROUP_VOLUMES,    "Market Facilitation Index"},

      // --- Arrows
      {IND_FRACTALS,   INDICATOR_GROUP_ARROWS,     "Fractals"},
     };
     int total = ArraySize(list);
     ArrayResize(out, total);
     for(int i = 0; i < total; i++)
      out[i] = list[i];
   }
 //For Table at Config Tab
  int CGUIPannel::GetIndicatorParamSchema(const ENUM_INDICATOR type, SIndicatorParam &out[])
   {
     ArrayResize(out, 4);
     for(int i = 0; i < 4; i++)
      {
        out[i].name = "";
        out[i].data_type = TYPE_DOUBLE;
        out[i].default_value = "";
      }
     switch(type)
       {
        case IND_SAR:
           out[0].name = "Step";     out[0].data_type = TYPE_DOUBLE; out[0].default_value = "0.02";
           out[1].name = "Maximum";  out[1].data_type = TYPE_DOUBLE; out[1].default_value = "0.2";
           return 2;
        case IND_MA:
           out[0].name = "Period";   out[0].data_type = TYPE_INT;    out[0].default_value = "14";
           out[1].name = "Shift";    out[1].data_type = TYPE_INT;    out[1].default_value = "0";
           out[2].name = "Method (0=SMA,1=EMA,2=SMMA,3=LWMA)"; out[2].data_type = TYPE_INT; out[2].default_value = "1";
           out[3].name = "Applied Price (0=Close..6=WClose)";  out[3].data_type = TYPE_INT; out[3].default_value = "0";
           return 4;
        // TODO: add the remaining ~30 types here, following the same pattern
        //       (look up each CIndXXX's own param order in its constructor/IndicatorCreate call)
        default:
           return 0;
       }
    }
 
 // =====================================================================
 // --- Params tab: 4 generic label+edit pairs + Add button
 // =====================================================================
 bool CGUIPannel::CreateParamsTab(const int x_gap, const int y_gap)
  {
   for(int i = 0; i < 4; i++)
     {
      int y = y_gap + i * 30;
      m_param_labels[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_PARAMS, m_param_labels[i]);
      if(!m_param_labels[i].CreateTextLabel("", x_gap, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_labels[i]);

      m_param_edits[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_PARAMS, m_param_edits[i]);
      m_param_edits[i].XSize(100);
      if(!m_param_edits[i].CreateTextEdit("", x_gap + 160, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_edits[i]);
     }
      m_btn_add_indicator.MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_PARAMS, m_btn_add_indicator);
      m_btn_add_indicator.AutoXResizeMode(true);
      m_btn_add_indicator.BackColor(clrDodgerBlue);
      m_btn_add_indicator.BackColorHover(clrRoyalBlue);
      m_btn_add_indicator.BackColorPressed(clrBlue);
      m_btn_add_indicator.LabelColor(clrWhite);
      m_btn_add_indicator.BorderColor(clrBlue);
      bool created = m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + 4 * 30 + 10);
      //Debug 
         Print("My Debug CreateParamsTab CreateButton result=", created,
               " X=", m_btn_add_indicator.X(), " Y=", m_btn_add_indicator.Y(),
               " XSize=", m_btn_add_indicator.XSize(), " YSize=", m_btn_add_indicator.YSize(),
               " IsVisible=", m_btn_add_indicator.IsVisible());
   if(!created) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_btn_add_indicator);

   for(int i = 0; i < 4; i++)
     {
      m_param_labels[i].Update(true);
      m_param_edits[i].Update(true);
     }
   m_btn_add_indicator.Update(true);
   Print("My Debug CreateParamsTab AFTER Update(true) IsVisible=", m_btn_add_indicator.IsVisible(),
         " X=", m_btn_add_indicator.X(), " Y=", m_btn_add_indicator.Y());
   return true;
  }

// =====================================================================
// --- Called from OnEvent when a Type-level tree node is clicked
// =====================================================================
void CGUIPannel::ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li)
  {
   m_current_param_type    = type;
   m_current_param_type_li = type_li;

   SIndicatorParam schema[];
   int total = GetIndicatorParamSchema(type, schema);
   for(int i = 0; i < 4; i++)
     {
      if(i < total)
        {
         m_param_labels[i].LabelText(schema[i].name);
         m_param_edits[i].SetValue(schema[i].default_value);
         m_param_labels[i].Show();
         m_param_edits[i].Show();
        }
      else
        {
         m_param_labels[i].Hide();
         m_param_edits[i].Hide();
        }
      // --- Force repaint for EVERY slot, not just index 0
         m_param_labels[i].Update(true);
         m_param_edits[i].Update(true);
     }   
  }

// =====================================================================
// --- "Add" button click handler — converts text fields to MqlParam[]
// =====================================================================

   void CGUIPannel::OnClickShowLine(const string sname, const int row) { Print("TODO OnClickShowLine: ", sname); }
   void CGUIPannel::OnClickToggleBuySignal(const string sname, const int row) { Print("TODO OnClickToggleBuySignal: ", sname); }
   void CGUIPannel::OnClickToggleSellSignal(const string sname, const int row) { Print("TODO OnClickToggleSellSignal: ", sname); }
   void CGUIPannel::OnClickRemoveIndicator(const string sname, const int row) { Print("TODO OnClickRemoveIndicator: ", sname); }
 
 //Calculatioon for display in Control
  
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
