//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//--- Library class for creating the graphical interface             |
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__
 // For Pure Data Layer 1
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SymbolsCollection.mqh>
  //For timeseries data  
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\TickSeriesCollection.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Timeseries\PatternRenderer.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>  
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Trading\TradingLevelBubble.mqh>
  // For indicator catalog/schema + CTimeSeriesEngine itself - JSON loading and
  // indicator creation live there now, GUIPannel only reads + renders (EA-local, not the Library)
   #include "..\Artyom Trishkin\TimeSeriesEngine.mqh"
 // For GUI controls Layer 2
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Keys.mqh>
  //#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\SplitContainer.mqh>
 // Signal arrow drawing (Standard Graph Objects only) - included AFTER Kazharski's own GUI Lib
 // so CFrame/CElement/CElementBase are fully resolved first (MQL5 compiles as one flat unit,
 // so include order matters here).
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\GraphElementsCollection.mqh>
//  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\InputData\TradingInpData.mqh>
//  #include <Vendors\Anhnt\Library\4. Combination Lib\Trading\Accounts\Account.mqh>
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
 // Define GUI control  
  enum ENUM_TAB_MAIN
    {
      TAB_TAB_MAIN_ACCOUNT_INFO = 0,
      TAB_TAB_MAIN_SYMBOL_INFO,
      TAB_TAB_MAIN_TRADE,
      TAB_TAB_MAIN_POSITIONS,
      TAB_TAB_MAIN_HISTORY,
      TAB_TAB_MAIN_SETTINGS,
      TAB_TAB_MAIN_EVENTS, //For Pattern Information
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
  // =====================================================================
  // --- Layer 2 (GUI) layout descriptor - decided BEFORE CreateAddIndicatorParaInfor/
  // --- ShowIndicatorParameterForm ever runs, separate from Layer 1's
  // --- SIndicatorParam (which only knows name/type/default/choices, not
  // --- where on screen it goes or which control renders it).
  // =====================================================================
   struct SIndicatorLayout
    {
      int               row;            // 0-based row in the form
      int               col;            // 0-based column (0=left, 1=right)
      int               total_width;    // label + field combined - keep this EQUAL
                                        // across a type's rows to make every row's
                                        // value box line up at the same right edge,
                                        // regardless of each row's label text length.
      int               field_width;    // px width of the value control itself (edit/combo)
      ENUM_ELEMENT_TYPE element_type;   // E_TEXT_BOX or E_COMBO_BOX (GUIDefines.mqh)
    };
  // --- ENUM_*_PARAM named slot indices live in IndicatorCatalog.mqh (Tang 1),
  // --- co-located with GetIndicatorParamSchema(). Pulled in via TimeSeriesEngine.mqh.

  // =====================================================================
  // --- Layout constants: all pixel dimensions defined here.
  // --- Change here; derived values update automatically.
  // =====================================================================
  // --- Main panel window
   #define PANEL_WIDTH               750
   #define PANEL_HEIGHT              480
  // --- Symbol/TF tree (fixed left strip, visible on all tabs)
   #define SYMBOL_TREE_WIDTH         100
  // --- m_tabs_main: starts at (TABS_MAIN_X, TABS_MAIN_Y) inside m_Mainwindow.
  // --- AutoXResizeRightOffset=3, so: TABS_WIDTH = PANEL_WIDTH - TABS_MAIN_X - 3.
   #define TABS_MAIN_X               115
   #define TABS_MAIN_Y               43
   #define TABS_WIDTH                (PANEL_WIDTH - TABS_MAIN_X - 3)
  // --- Indicator tree (Settings tab, left column)
   #define INDICATOR_TREE_WIDTH      150
  // --- Param form (right of indicator tree in Settings tab)
   #define INDICATOR_PARAM_ROWS      4
   #define INDICATOR_PARAM_LABEL_W   100
  // --- FIELD_W must clear the longest label across ALL indicator types
  // --- (e.g. "Slow EMA Period", "Applied Volume").
   #define INDICATOR_PARAM_FIELD_W   80
   #define INDICATOR_PARAM_COL_WIDTH (INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W + 12)
   #define PARAM_FORM_X              (INDICATOR_TREE_WIDTH + 10)
   #define PARAM_FORM_Y              5
   #define PARAM_ROW_H               30
   #define ADD_BTN_H                 20
  // --- Indicator table: below Add button with 10px gap; width auto-fills m_tabs_main via AutoXResizeMode.
   #define INDICATOR_TABLE_X         PARAM_FORM_X
   #define INDICATOR_TABLE_Y         (PARAM_FORM_Y + INDICATOR_PARAM_ROWS * PARAM_ROW_H + 10 + ADD_BTN_H + 10)

  class CGUIPannel : public CWndEvents
   {
    private: 
     //PUre Data Layer 1
     // Private Pointer variables    
      CSymbolsCollection         *m_symbol_collection;                //Trading owns
      CBarTimeSeriesCollection   *m_BarTimeSeriesCollection;          //CBarTimeSeriesCollection owns      
      CBarPatternsControl        *m_pattern_cfg;                      // borrowed from EA
      CIndicatorsCollection      *m_IndicatorsCollection;             // CTimeSeriesEngine owns
      CTimeSeriesEngine          *m_time_series_engine;               // EA owns - Tang 1 entry point for AddIndicatorInstance
      CTickSeriesCollection      *m_tick_series;                      // Collection of tick series
      CIndicatorDE               *m_table_indicator_ptrs[];           // BORROWED per-row pointers - CIndicatorsCollection owns them; rebuilt on every SetValuesToIndicatorTable, so never delete through these
      int                        m_pending_remove_row;                // row whose delete icon was clicked; executed in OnTimerEvent, NOT inside the click event - rebuilding the table while CTable is still processing its own click leaves its focus/press indices on freed rows (array out of range in Table.mqh)
      CTimeCounter               m_gui_timecounter;                   //--- Time counters
      CKeys                      m_keys;                              //For Keyboard    
     // For trading bubble
     //CPatternRenderer           *m_renderer;           //EA owns PatternRenderer for display New Patterns
     // CTradingLevelBubble        m_trading_bubble;    
     // Control Elements 
       CWindow                    m_window_main;
       CStatusBar                 m_status_bar;    
       CTabs                      m_tabs_main;       
      //For CTreeView left pannel 
       CTreeView                 m_treeview_SymbolTF;
       int                       m_sym_tree_pos[];        //To save symbol node list_index  
      //For control at Setting tab on m_tabs_main       
       //For Indicator TreeViews at      
        CTreeView                 m_treeview_indicator;
        string                    m_table_indicator_names[];
        int                       m_group_tree_pos[];
        int                       m_type_node_li[];      // list_index của từng node Type (level 1)
        ENUM_INDICATOR            m_type_node_value[];   // ENUM_INDICATOR tương ứng
       //-----------
        // --- INDICATOR_PARAM_SLOTS_MAX (8) matches the largest schema (Alligator/Gator)
         CTextLabel           m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
         CTextEdit            m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params
         CComboBox            m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
         CButton              m_btn_add_indicator;
         CButton              m_btn_save_indicator;
         ENUM_INDICATOR       m_current_param_type;     // which type the form is currently showing
         int                  m_current_param_type_li;  // its tree list_index (for tree-node insertion later)        
        // --- Indicator Info table: port of V4 m_table_indicator         
         CTable               m_table_indicator;
         CTable               m_table_indicator_SymbolTFValue;
         // per-row dirty-check cache for Trade tab table
         string               m_trade_cache_val[];
         int                  m_trade_cache_sig_icon[];
         int                  m_trade_cache_dir_icon[];
         int                  m_trade_table_row_count;

       // --- Signal arrows/thumbs on the chart (current chart symbol+period only - other symbols
       // in the table have no chart of their own to draw on). Watermark tracked per (symbol,TF)
       // key so switching the chart's own symbol/TF doesn't skip real new signals by comparing
       // against an unrelated timeline's last-drawn time.
        CGraphElementsCollection  m_graph_elements;
        string                    m_signal_arrows_key[];
        datetime                  m_signal_arrows_last_time[];

      // SIndicatorCatalogItem now lives in Artyom Trishkin\IndicatorCatalog.mqh (Tang 1 metadata)
      //For Indicator Config
         //CTabs                m_tabs_indicator_config;     // Panel2 of m_split_container: [Params] [Info]
       // --- Params tab controls (generic fixed-slot form, max 4 params/indicator)
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
        void                          SynSymbolTFTreeViewIcons(void);
       //Indicator TreeView m_treeview_indicator.         
         bool                         CreateTreeView_Indicator(const int x_gap, const int y_gap);
         void                         PopulateIndicatorTree(void);
         void                         SyncIndicatorTreeViewIcons(void);
         void                         AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[]);         
         bool                         CreateAddIndicatorParaInfor(const int x_gap, const int y_gap);
         void                          ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li);
         void                          HideParamSlots(void);
         void                          OnClickAddIndicator(void);
         void                          OnClickSaveIndicators(void);
         
         bool                          CreateIndicatorTable(const int x, const int y);
         void                          SetValuesToIndicatorTable(void);
         bool                          CreateIndicatorSymbolTFTable(const int x, const int y);
         void                          SetValuesToIndicatorSymbolTFTable(void);
         string                        BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[]);
         void                          DrawSignalArrows(void);
         int                           SignalArrowsFindOrAddKey(const string key);
       //Helper
        static void                   SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw);
        int                           GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[]); 
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
        CWindow *                      GetMainWindowPointer(void) { return &m_window_main; }
      //For Pointer      
        void                           SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbol_collection = symbols; }      
        void                           SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_BarTimeSeriesCollection = ts; } 
        void                           SetPatternsControl(CBarPatternsControl* ctrl) { m_pattern_cfg = ctrl; } 
        void                           SetIndicatorsCollection(CIndicatorsCollection *ind) { m_IndicatorsCollection = ind; }
        void                           SetTimeSeriesEngine(CTimeSeriesEngine *engine) { m_time_series_engine = engine; }
      //Temporary remove due to change
        //void  SetPatternRenderer(CPatternRenderer* renderer) { m_renderer = renderer; }
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
      m_IndicatorsCollection  = NULL;
      m_trade_table_row_count  = 0;
      m_pending_remove_row     = -1;
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
  void CGUIPannel::SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw)
    {
      out[idx].row         = r;
      out[idx].col         = c;
      out[idx].total_width = tw;
      out[idx].field_width = fw;
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
  // Hides all param-form slots. Called after any ShowTabElements() that overrides our Hide().
  void CGUIPannel::HideParamSlots(void)
   {
    for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].Hide();
      m_param_edits[i].Hide();
      m_param_combo[i].Hide();
     }
     //m_btn_add_indicator.Hide();
   }
  // OnEvent handler
  void CGUIPannel::OnEvent(const int id, const long &lparam,
                        const double &dparam, const string &sparam)
   {
    // --- Re-hide param slots after CTabs::ShowTabElements() shows them on tab switch.
    //     ShowTabElements() runs inside CTabs::OnEvent() (before our OnEvent is called),
    //     so by this point the slots are already visible — we undo that.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main.Id())
      {
       HideParamSlots();
       return;
      }
    // --- Same issue on window expand: OnWindowExpand() calls ShowTabElements() before
    //     our OnEvent runs. Re-hide to keep param slots invisible until tree node clicked.
     if(id == CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND && lparam == m_window_main.Id())
      {
       HideParamSlots();
       return;
      }
    // --- On window collapse: library OnWindowCollapse() may skip elements with Id()==0
    //     (e.g. dynamic TreeItems). Explicitly hide both treeviews so their items
    //     cascade-hide, eliminating gray canvas artifacts on the chart.
     if(id == CHARTEVENT_CUSTOM + ON_WINDOW_COLLAPSE && lparam == m_window_main.Id())
      {
       m_treeview_indicator.Hide();
       m_treeview_SymbolTF.Hide();
       HideParamSlots();
       return;
      }
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
    //Handle Save Indicator config to JSON
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_indicator.Id())
      {
         OnClickSaveIndicators();
         return;
      }
    //Handle m_table_indicator event
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
        && lparam == m_table_indicator.Id())
      {
         string parts[];
         if(StringSplit(sparam, '_', parts) != 2) return;
         int col = (int)StringToInteger(parts[0]);
         int row = (int)StringToInteger(parts[1]);
         if(row < 0 || row >= ArraySize(m_table_indicator_names)) return;
         string sname = m_table_indicator_names[row];

         // --- col 0 = Tang 1 (remove template from PureData), col 4 = Tang 3
         // --- (show/hide on chart). Buy/Sell unchanged at 2/3.
         // --- Delete is DEFERRED to OnTimerEvent: rebuilding the table here, inside its
         // --- own click processing, crashes CTable (stale focus/press row indices).
         if(col == 0)        m_pending_remove_row = row;
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
         //--------------------------------
         if(item == NULL) return;
         int parent_pos = m_treeview_SymbolTF.ItemPrevNode(li);
         if(parent_pos == -1)  // Symbol node
          {
            if(item.ItemType() == TI_SIMPLE) //No TF Found
            {              
              ChartSetSymbolPeriod(0, item.LabelText(), _Period);
            } 
          }
         else // TF node → navigate to exact sym + tf
          {
            CTreeItem *parent = m_treeview_SymbolTF.ItemPointer(parent_pos);
            if(parent != NULL)
             {
               ENUM_TIMEFRAMES target_tf = TimestampByDescription(item.LabelText());
               ChartSetSymbolPeriod(0,parent.LabelText(),target_tf);
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
            SynSymbolTFTreeViewIcons();
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
      //--- Deferred indicator delete (queued by the col-0 click in OnEvent) - safe here,
      //--- the table finished its own click processing on the previous chart event
      if(m_pending_remove_row >= 0)
        {
         int remove_row = m_pending_remove_row;
         m_pending_remove_row = -1;
         if(remove_row < ArraySize(m_table_indicator_names))
            OnClickRemoveIndicator(m_table_indicator_names[remove_row], remove_row);
        }
      //--- Handling the elements

      ulong t0 = ::GetMicrosecondCount();

      CWndEvents::OnTimerEvent();

      ulong t1 = ::GetMicrosecondCount();

      //m_trading_bubble.OnPoll();
      
      SetValuesToIndicatorSymbolTFTable();
      DrawSignalArrows();

      ulong t2 = ::GetMicrosecondCount();
      // if(t2 - t0 > 1000)
      //  Print("PERF CGUIPannel::OnTimerEvent CWndEvents::OnTimerEvent= ", t1 - t0, " us CTradingLevelBubble::OnPoll= ", t2 - t1, " us");
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
       if (!CreateMainWindow("EXPERT PANEL Ver7"))
         {
            Print(__FUNCTION__, " > Failed to create panel!");
            return (false);
         }
       if (!CreateStatusBar(1, 23))
         {
            Print(__FUNCTION__, " > Failed to create Status Bar!");
            return (false);
         }      
       if (!CreateTab_Main(TABS_MAIN_X, TABS_MAIN_Y))
         {
            //Print(__FUNCTION__, " > Failed to create Tabs1!");
            return (false);
         }
        PopulateSymbolTFTree();
        if(!CreateTreeView_SymbolTF(10,22)) return false;  
        SynSymbolTFTreeViewIcons(); 
      //Create control in each tab
       //For Settings Tab at m_tabs_main       
        PopulateIndicatorTree();
        //if(!Create_SplitContainer(10, 22)) return false;
        if(!CreateTreeView_Indicator(0, 0)) return false;
        //if(!CreateConfigDetailTabs(5, 5)) return false;
        if(!CreateAddIndicatorParaInfor(PARAM_FORM_X, PARAM_FORM_Y)) return false;
        if(!CreateIndicatorTable(INDICATOR_TABLE_X, INDICATOR_TABLE_Y)) return false;
       //For Trade Tab at m_tabs_main
        if(!CreateIndicatorSymbolTFTable(0, 0)) return false;
      //m_tabs_main.ShowTabElements(); //Need verify
      CWndEvents::CompletedGUI();
      // --- Hide all slots ONLY AFTER CompletedGUI() - FormAvailableElementsArray() (called
      // --- inside CompletedGUI) registers only VISIBLE elements into m_available_elements[],
      // --- which CComboBox's click-open mechanism depends on. Hiding before CompletedGUI
      // --- would exclude them permanently even after Show() - confirmed by reading
      // --- FormAvailableElementsArray()'s IsVisible() filter.
      HideParamSlots();
       
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
      m_treeview_SymbolTF.Update(true);
      m_table_indicator.Update(true);
      SetValuesToIndicatorTable();
      SetValuesToIndicatorSymbolTFTable();
      SyncIndicatorTreeViewIcons();
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
        CWndContainer::AddWindow(m_window_main);
      //--- Properties
         m_window_main.XSize(PANEL_WIDTH);
         m_window_main.YSize(PANEL_HEIGHT);
         m_window_main.FontSize(9);
         m_window_main.IsMovable(true);
         m_window_main.ResizeMode(true);
         m_window_main.CloseButtonIsUsed(true);
         m_window_main.CollapseButtonIsUsed(true);
         m_window_main.TooltipsButtonIsUsed(true);
         m_window_main.FullscreenButtonIsUsed(true);
         m_window_main.MinimumXSize(300); // Allow shrinking horizontally down to 300px
         m_window_main.MinimumYSize(200); // Allow shrinking vertically down to 200px
      //--- Set the tooltips
         m_window_main.GetCloseButtonPointer().Tooltip("Close");
         m_window_main.GetTooltipButtonPointer().Tooltip("Tooltips");
         m_window_main.GetFullscreenButtonPointer().Tooltip("Fullscreen");
         m_window_main.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
      //--- Create the form
         if (!m_window_main.CreateWindow(m_chart_id, m_subwin, caption_text, 1, 1))
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
         CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_status_bar);         
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
       m_tabs_main.MainPointer(m_window_main);
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
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_tabs_main);      
      return (true);
    }    
    // For TreeView Indicator TabSetting at m_tabs_main
    bool CGUIPannel::CreateTreeView_Indicator(const int x_gap, const int y_gap)
     {
       m_treeview_indicator.MainPointer(m_tabs_main); 
       m_treeview_indicator.AutoXResizeMode(false);
       m_treeview_indicator.XSize(150);
       m_treeview_indicator.AutoYResizeMode(true);
       m_treeview_indicator.VisibleItemsTotal(15);
       m_treeview_indicator.LightsHover(true);
      //Create treeview
       if(!m_treeview_indicator.CreateTreeView(x_gap, y_gap)) return false;

       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_treeview_indicator);

       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_treeview_indicator);       
       return true;
     }    
   // =====================================================================
   // --- Info tab: port of V4 m_table_indicator, same 5-column layout
   // =====================================================================
   bool CGUIPannel::CreateIndicatorTable(const int x, const int y)
    {
      m_table_indicator.MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_table_indicator);
      m_table_indicator.AutoXResizeMode(true);
      m_table_indicator.AutoXResizeRightOffset(3);
      m_table_indicator.AutoYResizeMode(true);
      m_table_indicator.AutoYResizeBottomOffset(3);
      m_table_indicator.ShowHeaders(true);
      m_table_indicator.SelectableRow(true);
      m_table_indicator.LightsHover(true);
      m_table_indicator.IsSortMode(true);
      // --- 5 columns: col 0 merges the old icon-only "show on T3" column with the
      // --- "Indicator" text column (CTCell renders image+text independently, click
      // --- detection is scoped to the image's own pixel width - see Table.mqh
      // --- CheckPressedCheckBox/CheckPressedButton). Buy/Sell/Delete shift down by 1.
       m_table_indicator.TableSize(5, 20);
       int widths[5]    = {160, 70, 40, 40, 40};
       int img_x_off[5] = {3,   0,  10, 10, 10};
       int img_y_off[5] = {3,   0,  3,  3,  3};
       ENUM_ALIGN_MODE align[5] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
       m_table_indicator.ColumnsWidth(widths);
       m_table_indicator.ImageXOffset(img_x_off);
       m_table_indicator.ImageYOffset(img_y_off);
       m_table_indicator.TextAlign(align);

       if(!m_table_indicator.CreateTable(x, y)) return false;
       m_table_indicator.SetHeaderText(0, "Indicator");
       m_table_indicator.SetHeaderText(1, "Group");
       m_table_indicator.SetHeaderText(2, "Buy");
       m_table_indicator.SetHeaderText(3, "Sell");
       m_table_indicator.SetHeaderText(4, "Show");

     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator);
     return true;
    }
   void CGUIPannel::SetValuesToIndicatorTable(void)
    {
      //Debug
       //Print("My Debug SetValuesToIndicatorTable ENTER m_IndicatorsCollection=", (m_IndicatorsCollection==NULL?"NULL":"OK"));
      if(m_IndicatorsCollection == NULL) return;
      string sym = ::Symbol();
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
      //Print("My Debug SetValuesToIndicatorTable sym=", sym, " tf=", EnumToString(tf));

      CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      //Print("My Debug SetValuesToIndicatorTable GetListIndBySymbol total=", (list==NULL?-1:list.Total()));

      list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      //Print("My Debug SetValuesToIndicatorTable after ByIndicatorProperty total=", (list==NULL?-1:list.Total()));
   
      if(list == NULL || list.Total() == 0)
        {
          m_table_indicator.DeleteAllRows();
          m_table_indicator.AddRow(0);   // safety row: Library bug — DeleteAllRows does not reset m_item_index_focus
          ArrayResize(m_table_indicator_names, 0);
          ArrayResize(m_table_indicator_ptrs, 0);
          m_table_indicator.Update(true);
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

      m_table_indicator.DeleteAllRows();
      for(int i = 0; i < count-1; i++)   // +1 extra row: guards stale m_item_index_focus (Library bug in DeleteAllRows)
         m_table_indicator.AddRow(i);

      ArrayResize(m_table_indicator_names, count);
      ArrayResize(m_table_indicator_ptrs, count);
      // --- Col 0: red Close (delete) icon merged with the Indicator label text - this is
      // --- the Tang 1 control (click = delete this template from PureData; its Signals
      // --- are released first in OnClickRemoveIndicator). CTCell draws image+text
      // --- independently, and click detection is scoped to the image's own pixel width
      // --- (Table.mqh CheckPressedButton), so clicking the label text won't trigger it.
       uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
       uint chk[]   = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
      // --- Col 4: Layer 3 control (tick/untick = ChartIndicatorAdd/Delete) - a real checkbox.
       uint show_on_chart[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
       string group_names[] = {"Trend", "Oscillator", "Volumes", "Arrows"};
       for(int row = 0; row < count; row++)
        {
         // --- Col 0 (Layer 1): one-shot delete button, not a toggle - clicking the
         // --- red Close icon deletes this template (Signal first, then Indicator).
          m_table_indicator.CellType(0, row, CELL_BUTTON);
          m_table_indicator.SetImages(0, row, delete_icon);
          m_table_indicator.ChangeImage(0, row, 0);
          m_table_indicator.SetValue(0, row, "        " + labels[row]);   // leading spaces clear the icon

          string gname = (groups[row] >= 0 && groups[row] < 4) ? group_names[groups[row]] : "Other";
          m_table_indicator.SetValue(1, row, "  " + gname);

         // --- Buy / Sell checkboxes: only meaningful when this indicator has a Signal
          m_table_indicator.CellType(2, row, CELL_CHECKBOX);
          m_table_indicator.SetImages(2, row, chk);
          m_table_indicator.ChangeImage(2, row, has_signal[row] ? 1 : 1);   // default unchecked
          m_table_indicator.CellType(3, row, CELL_CHECKBOX);
          m_table_indicator.SetImages(3, row, chk);
          m_table_indicator.ChangeImage(3, row, has_signal[row] ? 1 : 1);   // default unchecked

         // --- Col 4 (Layer 3): real checkbox - tick = shown on chart right now.
          m_table_indicator.CellType(4, row, CELL_CHECKBOX);
          m_table_indicator.SetImages(4, row, show_on_chart);
          m_table_indicator.ChangeImage(4, row, line_states[row]);

          m_table_indicator_names[row] = ptrs[row].ShortName();
          m_table_indicator_ptrs[row]  = ptrs[row];
        }
      m_table_indicator.Update(true);
    }
  //For Symbol TF treeview
   bool CGUIPannel::CreateTreeView_SymbolTF(const int x_gap, const int y_gap)
    {       
       m_treeview_SymbolTF.MainPointer(m_window_main);
       m_treeview_SymbolTF.AutoXResizeMode(false);  // fixed width
       m_treeview_SymbolTF.XSize(SYMBOL_TREE_WIDTH);
       m_treeview_SymbolTF.AutoYResizeMode(true);
       m_treeview_SymbolTF.VisibleItemsTotal(15);
       m_treeview_SymbolTF.LightsHover(true);
       m_treeview_SymbolTF.AutoYResizeBottomOffset(25);
       if(!m_treeview_SymbolTF.CreateTreeView(x_gap, y_gap)) return false;      
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_treeview_SymbolTF);      
       return true;
    }  
   void CGUIPannel::PopulateSymbolTFTree(void)
    {      
      if(m_BarTimeSeriesCollection == NULL) return;
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
          CBarTimeSeriesDE *bts      = m_BarTimeSeriesCollection.GetTimeseries(sym_name);
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
                  CWndContainer::AddToElementsArray(WindowIdx(m_window_main), *new_item);
             }
            }          
        }
    }  
   void CGUIPannel::SynSymbolTFTreeViewIcons(void)
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
  // --- display state (TreeView icon + m_table_indicator), which is its Tang 2 job.
  void CGUIPannel::AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[])
   {
      if(m_time_series_engine == NULL) return;
      if(!m_time_series_engine.AddNewIndicatorToAllSeries(type, params)) return;
      SyncIndicatorTreeViewIcons();   // full sweep + Update(true)
      SetValuesToIndicatorTable();      
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
  // Builds the per-param layout for `type`. element_type is always carried
  // straight from Tang 1's schema (choices!="" -> E_COMBO_BOX) - Tang 2 does
  // not re-decide that fact, only how/where to render it. row/col/field_width
  // are explicitly curated per type below (this is the per-indicator layout
  // the user asked to control directly, not a blanket formula).
  int CGUIPannel::GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[])
   {
     SIndicatorParam schema[];
     int total = GetIndicatorParamSchema(type, schema);
     ArrayResize(out, total);
     for(int i = 0; i < total; i++)
      {
        // --- Fallback default (used for any type not explicitly curated below):
        // --- 2-per-row pairing, matches the catalog's Period/Shift-style ordering.
         out[i].row          = i / 2;
         out[i].col          = i % 2;
         out[i].total_width  = INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W;
         out[i].field_width  = INDICATOR_PARAM_FIELD_W;
         out[i].element_type = (schema[i].choices != "") ? E_COMBO_BOX : E_TEXT_BOX;
      }
     switch(type)
      {
       //Format 
        //1. Indicator Parameter.
        //2. Row number.
        //3. Column Number.
        //4. Total Width.
        //5. Input Value for Parameter width
       case IND_MA:
         SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - wider so the option text isn't clipped
         SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - longest label drives the 180 total
         break;
       case IND_STDDEV:
         // Same shape as MA (Period/Shift/Method/Applied Price) - kept as its
         // own case (not a fallthrough) so each indicator stays independently
         // editable without touching any other type.
          SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_ICHIMOKU:
         // Tenkan-sen / Kijun-sen / Senkou Span B - 3 unrelated periods,
         // one per row reads cleaner than pairing the 3rd alone on its own row.
         SetLayoutSlot(out,ICHIMOKU_TENKAN,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,ICHIMOKU_KIJUN,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,ICHIMOKU_SENKOU_B,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_SAR:
         // Step / Maximum - not a Period+Shift pair, one per row reads cleaner.
          SetLayoutSlot(out,SAR_STEP,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,SAR_MAXIMUM, 0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          break;
       case IND_BANDS:
         SetLayoutSlot(out,BANDS_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,BANDS_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,BANDS_DEVIATION,      1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,BANDS_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         break;
       case IND_ALLIGATOR:
         // 8 params would push a single column past the Add button (fixed at
         // 4-row height) - pair them 2-per-row like the catalog's natural
         // Jaw/Teeth/Lips period+shift grouping, same i/2,i%2 the fallback uses.
          SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_GATOR:
         // Same 8-param shape as Alligator (Jaw/Teeth/Lips period+shift, Method,
         // Applied Price) - own case so it stays independently editable.
          SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_ENVELOPES:
         // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
          SetLayoutSlot(out,ENVELOPES_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,ENVELOPES_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,ENVELOPES_METHOD,         2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          SetLayoutSlot(out,ENVELOPES_APPLIED_PRICE,  2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          SetLayoutSlot(out,ENVELOPES_DEVIATION_PCT,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  
          break;
       case IND_FRAMA:
         SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         break;
       case IND_DEMA:
         // Same shape as FRAMA/TEMA (Period/Shift/Applied Price) - own case.
          SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_TEMA:
         // Same shape as FRAMA/DEMA (Period/Shift/Applied Price) - own case.
          SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_AMA:
         // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
          SetLayoutSlot(out,AMA_PERIOD,            0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,AMA_FAST_EMA_PERIOD,   0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,AMA_SLOW_EMA_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // longest label ("Slow EMA Period") drives the 220 total
          SetLayoutSlot(out,AMA_SHIFT,             1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,AMA_APPLIED_PRICE,     2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_VIDYA:
         SetLayoutSlot(out,VIDYA_CMO_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,VIDYA_EMA_PERIOD,     0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,VIDYA_SHIFT,          1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,VIDYA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         break;
       // --- Single plain "Period" numeric field - same 1-param shape across all
       // --- of these, each kept as its own case (not grouped) so any one of
       // --- them can be retuned without touching the others. idx is always 0,
       // --- no named enum needed for a single unambiguous field.
       case IND_ADX:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_ADXW:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_DEMARKER:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_RVI:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_WPR:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_TRIX:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_ATR:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_BEARS:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_BULLS:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_MFI:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_MOMENTUM:
         SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         break;
       case IND_CCI:
         // Same shape as RSI/Momentum (Period + Applied Price) - own case.
          SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_RSI:
         // Same shape as CCI/Momentum (Period + Applied Price) - own case.
          SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_MACD:
         SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,ESP_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         break;
       case IND_OSMA:
         // Same shape as MACD (Fast/Slow EMA Period, Signal Period, Applied
         // Price) - own case.
          SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,ESP_APPLIED_PRICE,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          break;
       case IND_STOCHASTIC:
         // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
          SetLayoutSlot(out,STOCH_K_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,STOCH_D_PERIOD,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,STOCH_SLOWING,      2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
          SetLayoutSlot(out,STOCH_METHOD,       0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
          SetLayoutSlot(out,STOCH_PRICE_FIELD,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         break;
       case IND_FORCE:
         SetLayoutSlot(out,FORCE_PERIOD,           0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,FORCE_METHOD,           1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         SetLayoutSlot(out,FORCE_APPLIED_VOLUME,   1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - "Applied Volume" drives the 210 total
         break;
       case IND_CHAIKIN:
         SetLayoutSlot(out,CHAIKIN_FAST_MA_PERIOD,  0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,CHAIKIN_SLOW_MA_PERIOD,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         SetLayoutSlot(out,CHAIKIN_METHOD,          2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         SetLayoutSlot(out,CHAIKIN_APPLIED_VOLUME,  3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
         break;
       // --- Single combo "Applied Volume" field - same 1-param shape across all
       // --- of these, each kept as its own case (not grouped). idx is always 0,
       // --- no named enum needed for a single unambiguous field.
       case IND_OBV:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_AD:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       case IND_VOLUMES:
         SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
         break;
       // --- IND_AO, IND_AC, IND_BWMFI, IND_FRACTALS have 0 params (total=0,
       // --- the loop in ShowIndicatorParameterForm never executes) - no case needed.
       default:
         break; // default pairing is fine
     }
    return total;
   }  

 // =====================================================================
 // --- Params tab: up to INDICATOR_PARAM_SLOTS_MAX (8) label+field pairs,
 // --- laid out as 2 columns x 4 rows. Each slot has BOTH a CTextEdit (plain
 // --- numeric params) and a CComboBox (enum-like params) at the same spot -
 // --- ShowIndicatorParameterForm() shows exactly one of the two per slot,
 // --- based on whether that param has choices in the schema.
 // =====================================================================  
 bool CGUIPannel::CreateAddIndicatorParaInfor(const int x_gap, const int y_gap)
  {
    const int default_x = x_gap;
    const int default_y = y_gap;
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      // int row = i % INDICATOR_PARAM_ROWS;
      // int col = i / INDICATOR_PARAM_ROWS;
      // int x   = x_gap + col * INDICATOR_PARAM_COL_WIDTH;
      // int y   = y_gap + row * 30;

      m_param_labels[i].MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_param_labels[i]);
      if(!m_param_labels[i].CreateTextLabel("", default_x, default_y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_labels[i]);

      m_param_edits[i].MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_param_edits[i]);
      m_param_edits[i].XSize(INDICATOR_PARAM_FIELD_W);
      // --- Inner CTextBox defaults its LOCAL x-offset to the outer box's x_size at
      // --- creation time unless told otherwise BEFORE CreateTextEdit() - confirmed via
      // --- debug log (inner canvas sitting ~90px right of the outer frame after resize).
      m_param_edits[i].GetTextBoxPointer().XGap(1);
      if(!m_param_edits[i].CreateTextEdit("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_edits[i]);

      m_param_combo[i].MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_param_combo[i]);
      m_param_combo[i].XSize(INDICATOR_PARAM_FIELD_W);
      m_param_combo[i].YSize(20);
      m_param_combo[i].ItemsTotal(7);          // room for the largest choice list (PRICE_CHOICES)
      // --- CButton inside CComboBox defaults to XSize=80 at XGap=80 unless explicitly
      // --- told otherwise BEFORE CreateComboBox() - mirrors how CTable's own combo usage
      // --- configures it. Without this the button/listview end up outside the narrow canvas.
      m_param_combo[i].GetButtonPointer().XGap(1);
      m_param_combo[i].GetButtonPointer().XSize(INDICATOR_PARAM_FIELD_W);
      m_param_combo[i].GetButtonPointer().LabelYGap(4);
      m_param_combo[i].GetButtonPointer().IconYGap(3);
      if(!m_param_combo[i].CreateComboBox("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_combo[i]);
      // --- Do NOT call Hide() here - CompletedGUI() (called after this function)
      // --- runs FormAvailableElementsArray() which only includes VISIBLE elements
      // --- in m_available_elements[]. Hiding early means MOUSE_MOVE events never
      // --- reach the combo button later (even after Show()), so the dropdown arrow
      // --- click silently does nothing. ShowIndicatorParameterForm() manages
      // --- show/hide correctly AFTER CompletedGUI has already registered everything.
     }
     //For Button Add
      m_btn_add_indicator.MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_btn_add_indicator);
      m_btn_add_indicator.AutoXResizeMode(false);
      m_btn_add_indicator.XSize(80);
      m_btn_add_indicator.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);
      m_btn_add_indicator.BackColor(clrDodgerBlue);
      m_btn_add_indicator.BackColorHover(clrRoyalBlue);
      m_btn_add_indicator.BackColorPressed(clrBlue);
      m_btn_add_indicator.LabelColor(clrWhite);
      m_btn_add_indicator.BorderColor(clrBlue);
      bool created = m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
   if(!created) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_add_indicator);
   //For Button Save
      m_btn_save_indicator.MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_btn_save_indicator);
      m_btn_save_indicator.AutoXResizeMode(false);
      m_btn_save_indicator.XSize(80);
      m_btn_save_indicator.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
      m_btn_save_indicator.BackColor(clrForestGreen);
      m_btn_save_indicator.BackColorHover(clrGreen);
      m_btn_save_indicator.BackColorPressed(clrDarkGreen);
      m_btn_save_indicator.LabelColor(clrWhite);
      m_btn_save_indicator.BorderColor(clrGreen);
      bool created_save = m_btn_save_indicator.CreateButton("Save", x_gap + 85, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
   if(!created_save) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_indicator);
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].Update(true);
      m_param_edits[i].Update(true);
     }
   m_btn_add_indicator.Update(true);
   m_btn_save_indicator.Update(true);
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
   // --- Layer 2 layout - decided BEFORE we touch a single control, separate
   // --- from Layer 1's data schema. Drives both position AND which control renders.
    SIndicatorLayout layout[];
    GetIndicatorGuiLayout(type, layout);
   // --- x_gap offsets right of the 150px indicator tree; y_gap from the tab's top.
    const int x_gap = PARAM_FORM_X, y_gap = PARAM_FORM_Y;
    for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      if(i < total)
       {
         int x = x_gap + layout[i].col * INDICATOR_PARAM_COL_WIDTH;
         int y = y_gap + layout[i].row * 30;
         // --- Reposition label/edit/combo to this type's layout slot. Moving()
         // --- reads the CANVAS's own XGap/YGap (not just the element's), and
         // --- skips repositioning hidden elements by default - see CElement::Moving().
          m_param_labels[i].XGap(x); m_param_labels[i].CanvasPointer().XGap(x);
          m_param_labels[i].YGap(y); m_param_labels[i].CanvasPointer().YGap(y);
          m_param_labels[i].LabelText(schema[i].name);
          m_param_labels[i].Show();
          m_param_labels[i].Moving();
         // --- Field starts after (total_width - field_width) px of label room.
         // --- Keeping total_width equal across a type's rows is what makes the
         // --- field line up at the same right edge regardless of label length.
          int fx = x + (layout[i].total_width - layout[i].field_width);
          if(layout[i].element_type == E_COMBO_BOX)
           {
            string parts[];
            int n = StringSplit(schema[i].choices, '|', parts);
            m_param_combo[i].GetListViewPointer().Rebuilding(n);
            for(int p = 0; p < n; p++)
               m_param_combo[i].SetValue(p, parts[p]);
            int def_idx = (int)StringToInteger(schema[i].default_value);
            if(def_idx >= 0 && def_idx < n) m_param_combo[i].SelectItem(def_idx);
            // --- SetValue()/Rebuilding() default redraw=false - they only store
            // --- the data, they never paint it. Same trap as CSplitContainer's
            // --- separator: must force an element-level Update(true) (-> Draw())
            // --- or the dropdown list stays visually blank even though it has items.
             m_param_combo[i].GetListViewPointer().Update(true);
            // --- XSize() alone never touches the canvas bitmap (logical field
            // --- only) - same trap as CSplitContainer's panel1. Must also resize
            // --- the canvas + the internal button to actually change width on screen.
             int cw = layout[i].field_width;
             m_param_combo[i].XSize(cw);
             m_param_combo[i].CanvasPointer().XSize(cw);
             m_param_combo[i].CanvasPointer().Resize(cw, m_param_combo[i].CanvasPointer().YSize());
            // --- Use built-in ChangeSize to properly resize the button and its image group gap (dropdown arrow position)
             m_param_combo[i].GetButtonPointer().ChangeSize(cw, m_param_combo[i].GetButtonPointer().YSize());
            // --- ComboBox.mqh's CreateButton() computes IconXGap ONCE at creation
            // --- time as (x_size-18), using whatever x_size the button had THEN
            // --- (90, from INDICATOR_PARAM_FIELD_W) - it never re-tracks later
            // --- resizes. Left stale, the dropdown arrow icon stays pinned at the
            // --- OLD x=72 regardless of how narrow/wide the button becomes now,
            // --- which is what made the box look like it had no closed right edge.
            // --- Recompute it here using the Library's own formula every resize.
            m_param_combo[i].GetButtonPointer().IconXGap(cw - 18);
            // --- Also resize the dropdown list view to match the combo width
             m_param_combo[i].GetListViewPointer().ChangeSize(cw, m_param_combo[i].GetListViewPointer().YSize());
             m_param_combo[i].XGap(fx); m_param_combo[i].CanvasPointer().XGap(fx);
             m_param_combo[i].YGap(y);  m_param_combo[i].CanvasPointer().YGap(y);
             m_param_combo[i].Draw();
             m_param_combo[i].Show();
             m_param_combo[i].Moving();
             m_param_edits[i].Hide();
           }
         else
           {
            // --- is_size_adjustment=false: SetValue() defaults to TRUE, which
            // --- calls CorrectSize() and shrinks the box to fit the value text
            // --- (a 1-digit default like "8" collapses the box to almost
            // --- nothing, looking like a stray checkbox icon). Keep our explicit
            // --- per-layout field_width instead.
             m_param_edits[i].SetValue(schema[i].default_value, false);
             int ew = layout[i].field_width;
             m_param_edits[i].XSize(ew);
             m_param_edits[i].CanvasPointer().XSize(ew);
             m_param_edits[i].CanvasPointer().Resize(ew, m_param_edits[i].CanvasPointer().YSize());
            // --- Use built-in ChangeSize to properly resize the inner CTextBox canvas, area width, and visible width
             m_param_edits[i].GetTextBoxPointer().ChangeSize(ew, m_param_edits[i].GetTextBoxPointer().YSize());
             m_param_edits[i].XGap(fx); m_param_edits[i].CanvasPointer().XGap(fx);
             m_param_edits[i].YGap(y);  m_param_edits[i].CanvasPointer().YGap(y);
             m_param_edits[i].Draw();
            // --- The visible VALUE text is painted by the inner CTextBox
            // --- (m_edit), which has its own separate canvas - NOT by the outer
            // --- CTextEdit's Draw()/Update(). Normally SetValue()'s default
            // --- CorrectSize() path repaints it as a side effect of resizing;
            // --- since we pass is_size_adjustment=false (to stop the auto-shrink
            // --- bug), we must explicitly force that inner repaint ourselves,
            // --- or the box keeps showing whatever value the PREVIOUSLY selected
            // --- indicator left behind (confirmed: stale "0.02"/"0.2" from PSAR
            // --- still showing after switching to MA).
             m_param_edits[i].GetTextBoxPointer().Update(true);
             m_param_edits[i].Update(true);
             m_param_edits[i].Show();
             m_param_edits[i].Moving();
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
      if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
      CIndicatorDE *ind = m_table_indicator_ptrs[row];
      if(ind == NULL) return;

      int new_state = (int)m_table_indicator.SelectedImageIndex(4, row);
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
      if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
      // ref_indicator is BORROWED (CIndicatorsCollection owns it) - it lives inside the
      // same list the loop below deletes from, so it may dangle partway through.
      CIndicatorDE *ref_indicator = m_table_indicator_ptrs[row];
      if(ref_indicator == NULL || m_IndicatorsCollection == NULL || m_time_series_engine == NULL) return;

      CArrayObj *list = m_IndicatorsCollection.GetList();
      if(list == NULL) return;
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);

      // --- Capture ref_indicator's type/params into plain local values NOW, before the
      // --- loop deletes it (it matches its own template) - never dereference it after.
      ENUM_INDICATOR ref_type = ref_indicator.TypeIndicator();
      MqlParam ref_params[];
      ref_indicator.GetMqlParams(ref_params);

      for(int i = list.Total() - 1; i >= 0; i--)
        {
         // indicator is BORROWED (CIndicatorsCollection owns it via 'list' FreeMode)
         CIndicatorDE *indicator = list.At(i);
         if(indicator == NULL || indicator.TypeIndicator() != ref_type) continue;

         // --- Same template = same type + same params, regardless of symbol/TF
         MqlParam params[];
         indicator.GetMqlParams(params);
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

         // --- Release the Signal FIRST: CSignalsCollection borrows this indicator's
         // --- pointer (m_indicator_list[] + the signal's own m_indicator), so deleting
         // --- the indicator before its signal would leave both dangling.
         m_time_series_engine.GetSignalsCollection().DeleteSignal(indicator);

         // --- Detach from chart if currently shown, then release the handle
         for(int sub = subwindows - 1; sub >= 0; sub--)
            for(int k = ChartIndicatorsTotal(0, sub) - 1; k >= 0; k--)
              {
               string name = ChartIndicatorName(0, sub, k);
               if((int)ChartIndicatorGet(0, sub, name) == indicator.Handle())
                  ChartIndicatorDelete(0, sub, name);
              }
         list.Delete(i);   // CArrayObj FreeMode -> ~CIndicatorDE -> IndicatorRelease(handle)
        }

      SetValuesToIndicatorTable();
      SetValuesToIndicatorSymbolTFTable();
      SyncIndicatorTreeViewIcons();
      ChartRedraw();
    }
 
 //Calculatioon for display in Control

  void CGUIPannel::OnClickSaveIndicators(void)
   {
      if(m_time_series_engine == NULL) return;
      m_time_series_engine.SaveIndicatorToJSON("indicators_config.json");
   }
  void CGUIPannel::SyncIndicatorTreeViewIcons(void)
   {
      if(m_IndicatorsCollection == NULL) return;
      CArrayObj *all = m_IndicatorsCollection.GetList();
      if(all == NULL) return;
      ENUM_INDICATOR applied[];
      int applied_count = 0;
      for(int i = 0; i < all.Total(); i++)
        {
         CIndicatorDE *ind = all.At(i);
         if(ind == NULL) continue;
         ENUM_INDICATOR t = ind.TypeIndicator();
         bool found = false;
         for(int j = 0; j < applied_count; j++)
            if(applied[j] == t) { found = true; break; }
         if(!found)
           {
            ArrayResize(applied, applied_count + 1);
            applied[applied_count++] = t;
           }
        }
      for(int i = 0; i < ArraySize(m_type_node_li); i++)
        {
         bool active = false;
         for(int j = 0; j < applied_count; j++)
            if(applied[j] == m_type_node_value[i]) { active = true; break; }
         CTreeItem *type_item = m_treeview_indicator.ItemPointer(m_type_node_li[i]);
         if(type_item != NULL)
            type_item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
         if(active)
           {
            int group_li = m_treeview_indicator.ItemPrevNode(m_type_node_li[i]);
            CTreeItem *group_item = m_treeview_indicator.ItemPointer(group_li);
            if(group_item != NULL)
               group_item.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
           }
        }
      m_treeview_indicator.Update(true);
   }

//+------------------------------------------------------------------+
//| Create Trade tab table: Symbol / TF / Indicator / Value / Buy / Sell / Trailing
//+------------------------------------------------------------------+
bool CGUIPannel::CreateIndicatorSymbolTFTable(const int x, const int y)
  {
   m_table_indicator_SymbolTFValue.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADE, m_table_indicator_SymbolTFValue);
   m_table_indicator_SymbolTFValue.AutoXResizeMode(true);
   m_table_indicator_SymbolTFValue.AutoXResizeRightOffset(3);
   m_table_indicator_SymbolTFValue.AutoYResizeMode(true);
   m_table_indicator_SymbolTFValue.AutoYResizeBottomOffset(3);
   m_table_indicator_SymbolTFValue.ShowHeaders(true);
   m_table_indicator_SymbolTFValue.SelectableRow(true);
   m_table_indicator_SymbolTFValue.LightsHover(true);
   m_table_indicator_SymbolTFValue.IsSortMode(true);

   // 7 cols: Symbol | TF(+signal icon) | Indicator(+dir icon) | Value | Buy | Sell | Trailing
   // Col 1 (TF): signal icon = trend direction; TextXOffset=22 clears 16px icon at x=3
   // Col 2 (Indicator): dir icon = value slope (v0 vs v1); same TextXOffset=22
   // Col 3 (Value): no icon, ALIGN_RIGHT, colored text only
   m_table_indicator_SymbolTFValue.TableSize(7, 20);
   int widths[7]    = {90,  60, 130, 90, 40, 40, 55};
   int img_x_off[7] = { 3,   3,   3,  0, 10, 10, 10};
   int img_y_off[7] = { 0,   3,   3,  0,  3,  3,  3};
   int txt_x_off[7] = { 5,  22,  22,  5,  5,  5,  5};
   ENUM_ALIGN_MODE al[7] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT,
                             ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
   m_table_indicator_SymbolTFValue.ColumnsWidth(widths);
   m_table_indicator_SymbolTFValue.ImageXOffset(img_x_off);
   m_table_indicator_SymbolTFValue.ImageYOffset(img_y_off);
   m_table_indicator_SymbolTFValue.TextXOffset(txt_x_off);
   m_table_indicator_SymbolTFValue.TextAlign(al);

   if(!m_table_indicator_SymbolTFValue.CreateTable(x, y)) return false;

   m_table_indicator_SymbolTFValue.SetHeaderText(0, "Symbol");
   m_table_indicator_SymbolTFValue.SetHeaderText(1, "TF");
   m_table_indicator_SymbolTFValue.SetHeaderText(2, "Indicator");
   m_table_indicator_SymbolTFValue.SetHeaderText(3, "Value");
   m_table_indicator_SymbolTFValue.SetHeaderText(4, "Buy");
   m_table_indicator_SymbolTFValue.SetHeaderText(5, "Sell");
   m_table_indicator_SymbolTFValue.SetHeaderText(6, "Trailing");

   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_SymbolTFValue);
   return true;
  }
//+------------------------------------------------------------------+
//| Build the Col2 display label ("ShortName  (params)") for an      |
//| indicator - shared by the row-rebuild path and the row-identity  |
//| key used to keep per-tick updates aligned after a user sort.     |
//+------------------------------------------------------------------+
string CGUIPannel::BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[])
  {
   string short_name = "";
   for(int c = 0; c < ::ArraySize(catalog); c++)
      if(catalog[c].type == ind.TypeIndicator()) { short_name = catalog[c].name; break; }
   if(short_name == "") short_name = ind.GetTypeDescription();
   MqlParam mql_params[];
   ind.GetMqlParams(mql_params);
   string pvalues = "";
   for(int p = 0; p < ::ArraySize(mql_params); p++)
     {
      if(p > 0) pvalues += ", ";
      pvalues += (mql_params[p].type == TYPE_DOUBLE)
                 ? ::DoubleToString(mql_params[p].double_value, 2)
                 : ::IntegerToString((int)mql_params[p].integer_value);
     }
   return short_name + (pvalues != "" ? "  (" + pvalues + ")" : "");
  }
//+------------------------------------------------------------------+
//| Populate / refresh the Trade tab table (no-flicker per-cell)     |
//+------------------------------------------------------------------+
void CGUIPannel::SetValuesToIndicatorSymbolTFTable(void)
  {
   if(m_IndicatorsCollection == NULL || m_BarTimeSeriesCollection == NULL) return;

   // --- Collect every indicator by walking m_BarTimeSeriesCollection (reliable: symbol -> TF series
   // structure, never observed to drift), then pulling each series' own indicator set from
   // m_IndicatorsCollection. All_syms[] is taken from the CBarSeriesDE object itself, not from
   // ind.Symbol() - keeps the two collections' data consistent with each other rather than
   // trusting the indicator's own copy of a value that (elsewhere, before a fix) was seen to drift.
   CIndicatorDE *all_inds[];
   string        all_syms[];
   int           count = 0;

   CArrayObj *sym_containers = m_BarTimeSeriesCollection.GetList();
   int sym_total = (sym_containers != NULL) ? sym_containers.Total() : 0;
   for(int si = 0; si < sym_total; si++)
     {
      CBarTimeSeriesDE *bts = sym_containers.At(si);
      if(bts == NULL) continue;
      CArrayObj *series_list = bts.GetListSeries();
      int series_total = (series_list != NULL) ? series_list.Total() : 0;
      for(int ti = 0; ti < series_total; ti++)
        {
         CBarSeriesDE *bs = series_list.At(ti);
         if(bs == NULL) continue;
         CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(bs.Symbol());
         ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, bs.Timeframe(), EQUAL);
         int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
         for(int ii = 0; ii < ind_total; ii++)
           {
            CIndicatorDE *ind = ind_list.At(ii);
            if(ind == NULL) continue;
            ::ArrayResize(all_inds, count + 1);
            ::ArrayResize(all_syms, count + 1);
            all_inds[count] = ind;
            all_syms[count] = bs.Symbol();
            count++;
           }
        }
     }

   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);

   // --- Full rebuild when row count changes
   if(count != m_trade_table_row_count)
     {
      uint chk[]     = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG,
                        IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
      uint sig_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG,
                        IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
      uint val_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG,
                        IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};

      m_table_indicator_SymbolTFValue.DeleteAllRows();
      ::ArrayResize(m_trade_cache_val,      count);
      ::ArrayResize(m_trade_cache_sig_icon, count);
      ::ArrayResize(m_trade_cache_dir_icon, count);
      ::ArrayInitialize(m_trade_cache_sig_icon, -1);
      ::ArrayInitialize(m_trade_cache_dir_icon, -1);
      for(int i = 0; i < count; i++) m_trade_cache_val[i] = "";

      for(int i = 0; i < count - 1; i++)
         m_table_indicator_SymbolTFValue.AddRow(i);

      for(int row = 0; row < count; row++)
        {
         CIndicatorDE *ind = all_inds[row];
         // Col 0: Symbol
          m_table_indicator_SymbolTFValue.SetValue(0, row, all_syms[row]);
         // Col 1: signal icon (trend) + TF text — TextXOffset=22 clears icon
         m_table_indicator_SymbolTFValue.SetImages(1, row, sig_img);
         m_table_indicator_SymbolTFValue.ChangeImage(1, row, 2);
         m_table_indicator_SymbolTFValue.SetValue(1, row, TimeframeDescription(ind.Timeframe()));
         // Col 2: signal icon + Indicator name — TextXOffset=22 pushes name past 16px icon
         string ind_label = BuildIndicatorLabel(ind, catalog);
         m_table_indicator_SymbolTFValue.SetImages(2, row, val_img);
         m_table_indicator_SymbolTFValue.ChangeImage(2, row, 2);
         m_table_indicator_SymbolTFValue.SetValue(2, row, ind_label);
         // Col 3: Value — ALIGN_RIGHT, no icon; direction shown by text color (red/green/gray)
         m_table_indicator_SymbolTFValue.SetValue(3, row, "--");
         // Cols 4-6: checkboxes
         m_table_indicator_SymbolTFValue.CellType(4, row, CELL_CHECKBOX);
         m_table_indicator_SymbolTFValue.SetImages(4, row, chk);
         m_table_indicator_SymbolTFValue.ChangeImage(4, row, 1);
         m_table_indicator_SymbolTFValue.CellType(5, row, CELL_CHECKBOX);
         m_table_indicator_SymbolTFValue.SetImages(5, row, chk);
         m_table_indicator_SymbolTFValue.ChangeImage(5, row, 1);
         m_table_indicator_SymbolTFValue.CellType(6, row, CELL_CHECKBOX);
         m_table_indicator_SymbolTFValue.SetImages(6, row, chk);
         m_table_indicator_SymbolTFValue.ChangeImage(6, row, 1);
        }

      m_trade_table_row_count = count;
      m_table_indicator_SymbolTFValue.Update(true);
      return;
     }

   // --- Re-derive each indicator's CURRENT visual row before writing anything. CTable's own
   // header-click sort reorders its rows internally (Col 0/1/2 identity text moves together with
   // the row), independent of all_inds[]'s construction order - so after a user sorts, row index
   // no longer says which indicator is which. Col 0/1/2 text is never touched below (only their
   // icons/colors are), so it stays a reliable post-sort identity key to match back against.
   int row_of[];
   ::ArrayResize(row_of, count);
   for(int i = 0; i < count; i++)
     {
      string want = all_syms[i] + "|" + TimeframeDescription(all_inds[i].Timeframe()) + "|" +
                    BuildIndicatorLabel(all_inds[i], catalog);
      row_of[i] = -1;
      for(int row = 0; row < count; row++)
        {
         string have = m_table_indicator_SymbolTFValue.GetValue(0, row) + "|" +
                       m_table_indicator_SymbolTFValue.GetValue(1, row) + "|" +
                       m_table_indicator_SymbolTFValue.GetValue(2, row);
         if(have == want) { row_of[i] = row; break; }
        }
     }

   // --- Per-cell dirty update: only Value text + icons change in real-time
   bool any_changed = false;
   for(int i = 0; i < count; i++)
     {
      int row = row_of[i];
      if(row < 0) continue; // identity not found this tick - next full rebuild will resync
      CIndicatorDE *ind = all_inds[i];
      double v0 = ind.GetDataBuffer(0, 0); // current bar (realtime via CopyBuffer)
      double v1 = ind.GetDataBuffer(0, 1); // previous bar (direction comparison)

      // Value direction: index 0=up 1=down 2=flat
      int dir_icon = 2;
      if(v0 != EMPTY_VALUE && v1 != EMPTY_VALUE)
         dir_icon = (v0 > v1) ? 0 : (v0 < v1) ? 1 : 2;
      color txt_clr = (dir_icon == 0) ? C'0,160,0' :    // rising  → green text
                      (dir_icon == 1) ? C'200,0,0' :    // falling → red text
                                        clrGray;         // flat    → gray text

      // Col 2 (Indicator): dir icon = value slope (v0 vs v1) - val_img, NOT the Signal system
      bool dir_changed = (dir_icon != m_trade_cache_dir_icon[row]);
      if(dir_changed)
        {
         m_trade_cache_dir_icon[row] = dir_icon;
         m_table_indicator_SymbolTFValue.ChangeImage(2, row, dir_icon);
         m_table_indicator_SymbolTFValue.BackColor(2, row, clrWhite, true);
         any_changed = true;
        }
      // Col 3 (Value): ALIGN_RIGHT, colored text only — redraw via TextColor(true)
      string val_str     = (v0 == EMPTY_VALUE) ? "--" : ::DoubleToString(v0, 5);
      bool   val_changed = (val_str != m_trade_cache_val[row]);
      if(val_changed || dir_changed)  // recolor on direction change too, even if the text itself didn't
        {
         if(val_changed)
           {
            m_trade_cache_val[row] = val_str;
            m_table_indicator_SymbolTFValue.SetValue(3, row, val_str);
           }
         m_table_indicator_SymbolTFValue.TextColor(3, row, txt_clr, true);
         any_changed = true;
        }
      // Col 1 (TF): sig_img - the actual Signal system (CSignalBase.GetCurrentSignal), NOT value slope.
      // GetOrCreateSignal itself returns NULL for indicator types with no CSignalXXX wired yet,
      // so this falls back to dir_icon automatically - that fallback is the only place dir_icon
      // and sig_icon are allowed to share a value.
      int sig_icon = dir_icon;
      if(m_time_series_engine != NULL)
        {
         // signal is BORROWED - CSignalsCollection owns it
         CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(signal != NULL)
           {
            ENUM_SIGNAL_DIR dir = signal.GetCurrentSignal();
            sig_icon = (dir == SIGNAL_BUY) ? 0 : (dir == SIGNAL_SELL) ? 1 : 2;
           }
        }
      if(sig_icon != m_trade_cache_sig_icon[row])
        {
         m_trade_cache_sig_icon[row] = sig_icon;
         m_table_indicator_SymbolTFValue.ChangeImage(1, row, sig_icon);
         m_table_indicator_SymbolTFValue.BackColor(1, row, clrWhite, true);
         any_changed = true;
        }
     }
   if(any_changed)
      m_table_indicator_SymbolTFValue.Update(false);
  }
//+------------------------------------------------------------------+
//| Find (or add) the watermark slot for a "symbol|TF" key - each    |
//| chart symbol/TF gets its own "last drawn signal time" so         |
//| switching the chart doesn't skip real signals by comparing       |
//| against an unrelated timeline.                                   |
//+------------------------------------------------------------------+
int CGUIPannel::SignalArrowsFindOrAddKey(const string key)
  {
   int total = ::ArraySize(m_signal_arrows_key);
   for(int i = 0; i < total; i++)
      if(m_signal_arrows_key[i] == key) return i;
   ::ArrayResize(m_signal_arrows_key, total + 1);
   ::ArrayResize(m_signal_arrows_last_time, total + 1);
   m_signal_arrows_key[total]        = key;
   m_signal_arrows_last_time[total]  = 0;
   return total;
  }
//+------------------------------------------------------------------+
//| Draw a Buy/Sell arrow (single signal) or Thumb (2+ signals at    |
//| the same bar) for the CURRENT chart's own symbol+period - other  |
//| symbols/TFs in the table have no chart of their own to draw on.  |
//+------------------------------------------------------------------+
void CGUIPannel::DrawSignalArrows(void)
  {
   if(m_time_series_engine == NULL || m_IndicatorsCollection == NULL) return;

   string sym = ::Symbol();
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
   int wm_idx = SignalArrowsFindOrAddKey(sym + "|" + EnumToString(tf));
   datetime last_time = m_signal_arrows_last_time[wm_idx];

   CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
   ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
   int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;

   // Merge every tracked indicator's signal history into buckets keyed by exact bar time,
   // counting how many indicators agree Buy vs Sell at that bar (1 = plain arrow, 2+ = thumb).
   datetime bucket_time[]; int bucket_buy[]; int bucket_sell[];
   for(int i = 0; i < ind_total; i++)
     {
      CIndicatorDE *ind = ind_list.At(i);
      if(ind == NULL) continue;
      // signal is BORROWED - CSignalsCollection owns it
      CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
      if(signal == NULL) continue;
      int hist_total = signal.HistoryTotal();
      for(int h = 0; h < hist_total; h++)
        {
         datetime t = signal.HistoryTime(h);
         if(t <= last_time) continue; // already drawn in a prior call
         ENUM_SIGNAL_DIR dir = signal.HistoryDir(h);
         if(dir == SIGNAL_NONE) continue;
         int bi = -1;
         for(int b = 0; b < ::ArraySize(bucket_time); b++)
            if(bucket_time[b] == t) { bi = b; break; }
         if(bi < 0)
           {
            bi = ::ArraySize(bucket_time);
            ::ArrayResize(bucket_time, bi + 1);
            ::ArrayResize(bucket_buy,  bi + 1);
            ::ArrayResize(bucket_sell, bi + 1);
            bucket_buy[bi] = 0; bucket_sell[bi] = 0;
           }
         if(dir == SIGNAL_BUY) bucket_buy[bi]++; else bucket_sell[bi]++;
        }
     }

   double pad = ::SymbolInfoDouble(sym, SYMBOL_POINT) * 50;
   datetime newest = last_time;
   for(int b = 0; b < ::ArraySize(bucket_time); b++)
     {
      int total    = bucket_buy[b] + bucket_sell[b];
      bool net_buy = bucket_buy[b] >= bucket_sell[b];
      int shift    = ::iBarShift(sym, tf, bucket_time[b], true);
      double lo[1] = {0}, hi[1] = {0};
      if(shift >= 0)
        {
         ::CopyLow(sym, tf, shift, 1, lo);
         ::CopyHigh(sym, tf, shift, 1, hi);
        }
      double price = net_buy ? (lo[0] - pad) : (hi[0] + pad);
      string name  = "sig_" + sym + "_" + EnumToString(tf) + "_" + (string)(long)bucket_time[b];

      // Skip if this arrow is already physically on the chart - objects survive an EA
      // restart/recompile while our watermark arrays reset to 0, so without this check the
      // first refresh after a restart re-attempts every historical arrow and floods the log
      // with "Such a graphic object already exists". CreateSignalXxx prefixes the object
      // name with the program name, so check the same full name here.
      if(::ObjectFind(m_chart_id, ::MQLInfoString(MQL_PROGRAM_NAME) + "_" + name) >= 0)
        {
         if(bucket_time[b] > newest) newest = bucket_time[b];
         continue;
        }

      if(total == 1)
        {
         if(net_buy) m_graph_elements.CreateSignalBuy(m_chart_id, name, 0, false, bucket_time[b], price);
         else        m_graph_elements.CreateSignalSell(m_chart_id, name, 0, false, bucket_time[b], price);
        }
      else
        {
         if(net_buy) m_graph_elements.CreateThumbUp(m_chart_id, name, 0, false, bucket_time[b], price);
         else        m_graph_elements.CreateThumbDown(m_chart_id, name, 0, false, bucket_time[b], price);
        }
      if(bucket_time[b] > newest) newest = bucket_time[b];
     }
   m_signal_arrows_last_time[wm_idx] = newest;
  }

#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
