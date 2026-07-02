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
 // Tang 1 (PureData): indicator catalog/schema + CTimeSeriesEngine itself - JSON loading and
 // indicator creation live there now, GUIPannel only reads + renders (EA-local, not the Library)
  #include "..\Artyom Trishkin\TimeSeriesEngine.mqh"

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
      CTimeSeriesEngine          *m_time_series_engine;   // EA owns - Tang 1 entry point for AddIndicatorInstance
      CTickSeriesCollection      *m_tick_series;           // Collection of tick series
      CIndicatorDE               *m_indicator_table_ptrs[];// per-row PureData record, for the upcoming Show/Hide+Delete handlers
      
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
       // SIndicatorCatalogItem now lives in Artyom Trishkin\IndicatorCatalog.mqh (Tang 1 metadata)
      //For Indicator Config
         CTabs                m_tabs_indicator_config;     // Panel2 of m_split_container: [Params] [Info]
       // --- Params tab controls (generic fixed-slot form, max 4 params/indicator)
         // --- INDICATOR_PARAM_SLOTS_MAX (8) matches the largest schema (Alligator/Gator)
         CTextLabel           m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
         CTextEdit            m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params
         CComboBox            m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
         CButton              m_btn_add_indicator;
         ENUM_INDICATOR       m_current_param_type;     // which type the form is currently showing
         int                  m_current_param_type_li;  // its tree list_index (for tree-node insertion later)
         // --- Info tab: port of V4 m_indicator_table
         CTable               m_indicator_table;
      // SIndicatorParam now lives in Artyom Trishkin\IndicatorCatalog.mqh (Tang 1 metadata)
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
         void                          AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[]);
         void                          PopulateIndicatorTree(void);
         bool                          CreateTreeView_Indicator(const int x_gap, const int y_gap);
         bool                          Create_SplitContainer(const int x_gap, const int y_gap);
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
        void                           SetTimeSeriesEngine(CTimeSeriesEngine *engine) { m_time_series_engine = engine; }
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
    // --- CComboBox standalone click workaround: Library CComboBox is designed for
    // --- embedding inside CTable (Table triggers Show/Hide programmatically).
    // --- For standalone use, the internal button's CHARTEVENT_OBJECT_CLICK never
    // --- reaches it through the standard WndEvents routing, so we intercept here.
     if(id == CHARTEVENT_OBJECT_CLICK)
      {
       for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
         if(m_param_combo[i].IsVisible() &&
            m_param_combo[i].GetButtonPointer().CheckElementName(sparam))
           {
            m_param_combo[i].ChangeComboBoxListState();
            return;
           }
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

         // --- col 0 = Tang 1 (remove template from PureData), col 4 = Tang 3
         // --- (show/hide on chart). Buy/Sell unchanged at 2/3.
         if(col == 0)        OnClickRemoveIndicator(sname, row);
         else if(col == 2)    OnClickToggleBuySignal(sname, row);
         else if(col == 3)    OnClickToggleSellSignal(sname, row);
         else if(col == 4)    OnClickShowLine(sname, row);     // toggle ChartIndicatorAdd/Delete
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
       if (!CreateMainWindow("EXPERT PANEL Ver6"))
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
         m_indicator_table.Update(true);
         SetValuesToIndicatorTable();
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
      // --- 5 columns: col 0 merges the old icon-only "show on T3" column with the
      // --- "Indicator" text column (CTCell renders image+text independently, click
      // --- detection is scoped to the image's own pixel width - see Table.mqh
      // --- CheckPressedCheckBox/CheckPressedButton). Buy/Sell/Delete shift down by 1.
      m_indicator_table.TableSize(5, 20);
      int widths[5]    = {160, 70, 40, 40, 30};
      int img_x_off[5] = {3,   0,  10, 10, 3};
      int img_y_off[5] = {3,   0,  3,  3,  3};
      ENUM_ALIGN_MODE align[5] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
      m_indicator_table.ColumnsWidth(widths);
      m_indicator_table.ImageXOffset(img_x_off);
      m_indicator_table.ImageYOffset(img_y_off);
      m_indicator_table.TextAlign(align);

      if(!m_indicator_table.CreateTable(x, y)) return false;
      m_indicator_table.SetHeaderText(0, "Indicator");
      m_indicator_table.SetHeaderText(1, "Group");
      m_indicator_table.SetHeaderText(2, "Buy");
      m_indicator_table.SetHeaderText(3, "Sell");
      m_indicator_table.SetHeaderText(4, "Show");

     CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_indicator_table);
     return true;
    }
   void CGUIPannel::SetValuesToIndicatorTable(void)
    {
      //Debug
       //Print("My Debug SetValuesToIndicatorTable ENTER m_indicators_timeseries=", (m_indicators_timeseries==NULL?"NULL":"OK"));
      if(m_indicators_timeseries == NULL) return;
      string sym = ::Symbol();
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
      //Print("My Debug SetValuesToIndicatorTable sym=", sym, " tf=", EnumToString(tf));

      CArrayObj *list = m_indicators_timeseries.GetListIndBySymbol(sym);
      //Print("My Debug SetValuesToIndicatorTable GetListIndBySymbol total=", (list==NULL?-1:list.Total()));

      list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      //Print("My Debug SetValuesToIndicatorTable after ByIndicatorProperty total=", (list==NULL?-1:list.Total()));
   
      if(list == NULL || list.Total() == 0)
        {
          m_indicator_table.DeleteAllRows();
          ArrayResize(m_indicator_table_names, 0);
          ArrayResize(m_indicator_table_ptrs, 0);
          m_indicator_table.Update(true);
          return;
        }

      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);

      string labels[]; int groups[]; int line_states[]; bool has_signal[];
      CIndicatorDE *ptrs[];
      int count = 0;
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
      for(int i = 0; i < list.Total(); i++)
        {
            CIndicatorDE *ind = list.At(i);
            if(ind == NULL) continue;
            // --- Dedup by full equality (type+params+...), not just ShortName() -
            // --- two PSARs with different Step/Maximum must stay as separate rows.
            bool dup = false;
            for(int n = 0; n < count; n++)
              if(ptrs[n].IsEqual(ind)) { dup = true; break; }
            if(dup) continue;

            // --- Compact label: catalog short name + raw param values (no Symbol/TF -
            // --- that's already shown via the highlighted node in m_treeview_SymbolTF).
            string short_name = "";
            for(int c = 0; c < ArraySize(catalog); c++)
              if(catalog[c].type == ind.TypeIndicator()) { short_name = catalog[c].name; break; }
            if(short_name == "") short_name = ind.GetTypeDescription();

            // --- Compact on purpose: full named/decoded text (FormatIndicatorLabel)
            // --- was too long for the column and the table can't be resized to fit -
            // --- reserved for a tooltip later, when CTable actually supports one.
            MqlParam mql_params[];
            ind.GetMqlParams(mql_params);
            string values = "";
            for(int p = 0; p < ArraySize(mql_params); p++)
              {
               if(p > 0) values += ", ";
               values += (mql_params[p].type == TYPE_DOUBLE)
                          ? DoubleToString(mql_params[p].double_value, 2)
                          : IntegerToString((int)mql_params[p].integer_value);
              }
            string label = short_name + (values != "" ? "  (" + values + ")" : "");

            bool on_chart = false;
            string sname = ind.ShortName();
            for(int sub = 0; sub < subwindows && !on_chart; sub++)
              for(int k = ChartIndicatorsTotal(0, sub) - 1; k >= 0; k--)
                  if(ChartIndicatorName(0, sub, k) == sname) { on_chart = true; break; }

            ArrayResize(labels, count + 1);
            ArrayResize(groups, count + 1);
            ArrayResize(line_states, count + 1);
            ArrayResize(has_signal, count + 1);
            ArrayResize(ptrs, count + 1);
            labels[count]      = label;
            groups[count]      = (int)ind.Group();
            line_states[count] = on_chart ? 0 : 1;   // 0=shown(checkbox img[0]) 1=hidden(img[1])
            has_signal[count]  = ind.HasSignal();   // chỉ cho click Buy/Sell nếu loại này thực có Signal
            ptrs[count]        = ind;
            count++;
          }
      if(count == 0) return;

      m_indicator_table.DeleteAllRows();
      for(int i = 0; i < count - 1; i++)
         m_indicator_table.AddRow(i);

      ArrayResize(m_indicator_table_names, count);
      ArrayResize(m_indicator_table_ptrs, count);

      // --- Col 0: Play/Stop icon merged with the Indicator label text - this is
      // --- the Tang 1 control (click = remove this whole template from PureData).
      // --- CTCell draws image+text independently, and click detection is scoped
      // --- to the image's own pixel width (Table.mqh CheckPressedButton), so
      // --- clicking the label text won't trigger it.
      uint t1_icon[] = {IMAGE_RESOURCE_BMP16_START_BMP, IMAGE_RESOURCE_BMP16_STOP_BMP};
      uint chk[]   = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_BMP};
      // --- Col 4: Tang 3 control (tick/untick = ChartIndicatorAdd/Delete) - a real checkbox.
      uint show_on_chart[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_BMP};
      string group_names[] = {"Trend", "Oscillator", "Volumes", "Arrows"};
      for(int row = 0; row < count; row++)
        {
          // --- Col 0 (Tang 1): one-shot button, not a toggle - every visible row
          // --- already exists in PureData by definition, so it always shows the
          // --- "exists" (green) icon; clicking removes the template.
          m_indicator_table.CellType(0, row, CELL_BUTTON);
          m_indicator_table.SetImages(0, row, t1_icon);
          m_indicator_table.ChangeImage(0, row, 0);
          m_indicator_table.SetValue(0, row, "        " + labels[row]);   // leading spaces clear the icon

          string gname = (groups[row] >= 0 && groups[row] < 4) ? group_names[groups[row]] : "Other";
          m_indicator_table.SetValue(1, row, "  " + gname);

          // --- Buy / Sell checkboxes: only meaningful when this indicator has a Signal
          m_indicator_table.CellType(2, row, CELL_CHECKBOX);
          m_indicator_table.SetImages(2, row, chk);
          m_indicator_table.ChangeImage(2, row, has_signal[row] ? 1 : 1);   // default unchecked
          m_indicator_table.CellType(3, row, CELL_CHECKBOX);
          m_indicator_table.SetImages(3, row, chk);
          m_indicator_table.ChangeImage(3, row, has_signal[row] ? 1 : 1);   // default unchecked

          // --- Col 4 (Tang 3): real checkbox - tick = shown on chart right now.
          m_indicator_table.CellType(4, row, CELL_CHECKBOX);
          m_indicator_table.SetImages(4, row, show_on_chart);
          m_indicator_table.ChangeImage(4, row, line_states[row]);

          m_indicator_table_names[row] = ptrs[row].ShortName();
          m_indicator_table_ptrs[row]  = ptrs[row];
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
      //Print("My Debug OnClickAddIndicator type=", EnumToString(m_current_param_type), " type_li=", m_current_param_type_li);
      SIndicatorParam schema[];
      int total = GetIndicatorParamSchema(m_current_param_type, schema);
      //Print("My Debug OnClickAddIndicator schema total=", total);
      if(total == 0) return;

      MqlParam params[];
      ArrayResize(params, total);
      for(int i = 0; i < total; i++)
       {
         params[i].type = schema[i].data_type;
         if(schema[i].choices != "")
           {
            // --- Enum param: the selected dropdown INDEX IS the integer value
            params[i].integer_value = (long)m_param_combo[i].GetListViewPointer().SelectedItemIndex();
           }
         else if(schema[i].data_type == TYPE_DOUBLE)
           {
            params[i].double_value = StringToDouble(m_param_edits[i].GetValue());
           }
         else
           {
            params[i].integer_value = (long)StringToInteger(m_param_edits[i].GetValue());
           }
       }
      AddIndicatorInstance(m_current_param_type_li, m_current_param_type, params);
    }
  // --- GUI "Add" button: indicator creation itself now lives in CTimeSeriesEngine
  // --- (Tang 1, PureData) - GUIPannel only forwards the call, then updates its own
  // --- display state (TreeView icon + m_indicator_table), which is its Tang 2 job.
  void CGUIPannel::AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[])
   {
      if(m_time_series_engine == NULL) return;
      if(!m_time_series_engine.ApplyIndicatorToAllSeries(type, params)) return;
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
  
  // GetIndicatorCatalog() and GetIndicatorParamSchema() now live as free functions in
  // Artyom Trishkin\IndicatorCatalog.mqh (Tang 1 metadata, shared with CTimeSeriesEngine).

 // =====================================================================
 // --- Params tab: up to INDICATOR_PARAM_SLOTS_MAX (8) label+field pairs,
 // --- laid out as 2 columns x 4 rows. Each slot has BOTH a CTextEdit (plain
 // --- numeric params) and a CComboBox (enum-like params) at the same spot -
 // --- ShowIndicatorParameterForm() shows exactly one of the two per slot,
 // --- based on whether that param has choices in the schema.
 // =====================================================================
 #define INDICATOR_PARAM_ROWS      4
 #define INDICATOR_PARAM_COL_WIDTH 175
 #define INDICATOR_PARAM_FIELD_X   75     // field starts this far right of its label
 #define INDICATOR_PARAM_FIELD_W   90
 bool CGUIPannel::CreateParamsTab(const int x_gap, const int y_gap)
  {
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      int row = i % INDICATOR_PARAM_ROWS;
      int col = i / INDICATOR_PARAM_ROWS;
      int x   = x_gap + col * INDICATOR_PARAM_COL_WIDTH;
      int y   = y_gap + row * 30;

      m_param_labels[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_PARAMS, m_param_labels[i]);
      if(!m_param_labels[i].CreateTextLabel("", x, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_labels[i]);

      m_param_edits[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_PARAMS, m_param_edits[i]);
      m_param_edits[i].XSize(INDICATOR_PARAM_FIELD_W);
      if(!m_param_edits[i].CreateTextEdit("", x + INDICATOR_PARAM_FIELD_X, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_edits[i]);

      m_param_combo[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_PARAMS, m_param_combo[i]);
      m_param_combo[i].XSize(INDICATOR_PARAM_FIELD_W);
      m_param_combo[i].YSize(20);
      m_param_combo[i].ItemsTotal(7);          // room for the largest choice list (PRICE_CHOICES)
      if(!m_param_combo[i].CreateComboBox("", x + INDICATOR_PARAM_FIELD_X, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_combo[i]);
      // --- Do NOT call Hide() here - CompletedGUI() (called after this function)
      // --- runs FormAvailableElementsArray() which only includes VISIBLE elements
      // --- in m_available_elements[]. Hiding early means MOUSE_MOVE events never
      // --- reach the combo button later (even after Show()), so the dropdown arrow
      // --- click silently does nothing. ShowIndicatorParameterForm() manages
      // --- show/hide correctly AFTER CompletedGUI has already registered everything.
     }
      m_btn_add_indicator.MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TAB_CONFIG_DETAIL_PARAMS, m_btn_add_indicator);
      m_btn_add_indicator.AutoXResizeMode(false);
      m_btn_add_indicator.XSize(70);
      m_btn_add_indicator.BackColor(clrDodgerBlue);
      m_btn_add_indicator.BackColorHover(clrRoyalBlue);
      m_btn_add_indicator.BackColorPressed(clrBlue);
      m_btn_add_indicator.LabelColor(clrWhite);
      m_btn_add_indicator.BorderColor(clrBlue);
      bool created = m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
   if(!created) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_btn_add_indicator);

   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].Update(true);
      m_param_edits[i].Update(true);
     }
   m_btn_add_indicator.Update(true);
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
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      if(i < total)
        {
         m_param_labels[i].LabelText(schema[i].name);
         m_param_labels[i].Show();

         if(schema[i].choices != "")
           {
            // --- Enum param: populate and show combo, hide text edit
            string parts[];
            int n = StringSplit(schema[i].choices, '|', parts);
            m_param_combo[i].GetListViewPointer().Rebuilding(n);
            for(int p = 0; p < n; p++)
               m_param_combo[i].SetValue(p, parts[p]);
            int def_idx = (int)StringToInteger(schema[i].default_value);
            if(def_idx >= 0 && def_idx < n) m_param_combo[i].SelectItem(def_idx);
            m_param_combo[i].Show();
            m_param_edits[i].Hide();
           }
         else
           {
            // --- Plain numeric param: show text edit, hide combo
            m_param_edits[i].SetValue(schema[i].default_value);
            m_param_edits[i].Show();
            m_param_combo[i].Hide();
           }
        }
      else
        {
         m_param_labels[i].Hide();
         m_param_edits[i].Hide();
         m_param_combo[i].Hide();
        }
      m_param_labels[i].Update(true);
      m_param_edits[i].Update(true);
      m_param_combo[i].GetButtonPointer().Update(true);
     }
  }

// =====================================================================
// --- "Add" button click handler — converts text fields to MqlParam[]
// =====================================================================

   // --- Col 4 checkbox: Tang 2 controls Tang 3 only - never touches PureData.
   // --- The table already auto-toggled the icon before sending this event, so
   // --- SelectedImageIndex(4,row) tells us the state to APPLY (0=show, 1=hide).
   // --- Matched by ind.Handle(), not by name - two instances of the same type
   // --- with different params can share the same native chart-assigned name.
   void CGUIPannel::OnClickShowLine(const string sname, const int row)
    {
      if(row < 0 || row >= ArraySize(m_indicator_table_ptrs)) return;
      CIndicatorDE *ind = m_indicator_table_ptrs[row];
      if(ind == NULL) return;

      int new_state = (int)m_indicator_table.SelectedImageIndex(4, row);
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);

      if(new_state == 1)   // Hide: remove from chart, PureData/handle stay intact
        {
         for(int sub = subwindows - 1; sub >= 0; sub--)
            for(int i = ChartIndicatorsTotal(0, sub) - 1; i >= 0; i--)
              {
               string name = ChartIndicatorName(0, sub, i);
               if((int)ChartIndicatorGet(0, sub, name) == ind.Handle())
                  ChartIndicatorDelete(0, sub, name);
              }
        }
      else                 // Show: re-attach using the stored handle
        {
         int sub_window = (ind.Group() == INDICATOR_GROUP_TREND) ? 0 : subwindows;
         ChartIndicatorAdd(0, sub_window, ind.Handle());
        }
      ChartRedraw();
    }
   void CGUIPannel::OnClickToggleBuySignal(const string sname, const int row) { Print("TODO OnClickToggleBuySignal: ", sname); }
   void CGUIPannel::OnClickToggleSellSignal(const string sname, const int row) { Print("TODO OnClickToggleSellSignal: ", sname); }
   // --- Col 0 button: Tang 1 control - removes this whole template (same type+params,
   // --- regardless of symbol/timeframe) from PureData. Does NOT touch the JSON file
   // --- yet (that part - persisting the removal so it doesn't come back on next
   // --- EA restart - is still open, deferred from the earlier discussion).
   void CGUIPannel::OnClickRemoveIndicator(const string sname, const int row)
    {
      if(row < 0 || row >= ArraySize(m_indicator_table_ptrs)) return;
      CIndicatorDE *ref = m_indicator_table_ptrs[row];
      if(ref == NULL || m_indicators_timeseries == NULL) return;

      CArrayObj *list = m_indicators_timeseries.GetList();
      if(list == NULL) return;
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);

      // --- ref itself lives inside this same list and will be deleted partway
      // --- through the loop below (it matches its own template) - capture its
      // --- type/params into plain local values now, BEFORE that happens, so we
      // --- never dereference ref again once it may have become a dangling pointer.
      ENUM_INDICATOR ref_type = ref.TypeIndicator();
      MqlParam ref_params[];
      ref.GetMqlParams(ref_params);

      for(int i = list.Total() - 1; i >= 0; i--)
        {
         CIndicatorDE *ind = list.At(i);
         if(ind == NULL || ind.TypeIndicator() != ref_type) continue;

         // --- Same template = same type + same params, regardless of symbol/TF
         MqlParam params[];
         ind.GetMqlParams(params);
         if(ArraySize(params) != ArraySize(ref_params)) continue;
         bool same = true;
         for(int p = 0; p < ArraySize(params) && same; p++)
           {
            if(params[p].type != ref_params[p].type) { same = false; break; }
            if(params[p].type == TYPE_DOUBLE)
               same = (params[p].double_value == ref_params[p].double_value);
            else
               same = (params[p].integer_value == ref_params[p].integer_value);
           }
         if(!same) continue;

         // --- Detach from chart first if currently shown, then release the handle
         for(int sub = subwindows - 1; sub >= 0; sub--)
            for(int k = ChartIndicatorsTotal(0, sub) - 1; k >= 0; k--)
              {
               string name = ChartIndicatorName(0, sub, k);
               if((int)ChartIndicatorGet(0, sub, name) == ind.Handle())
                  ChartIndicatorDelete(0, sub, name);
              }
         list.Delete(i);   // CArrayObj FreeMode -> ~CIndicatorDE -> IndicatorRelease(handle)
        }

      SetValuesToIndicatorTable();
      ChartRedraw();
    }
 
 //Calculatioon for display in Control
  
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
