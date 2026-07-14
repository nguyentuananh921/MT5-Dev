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
 // Layer-3 observer: charts/windows/indicators state + CHART_OBJ_EVENT_* events (no WForms deps)
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
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
   enum ENUM_CHECKBOX_STATE
   {
    CHECKBOX_STATE_ON  = 0,
    CHECKBOX_STATE_OFF = 1,
   };
   enum ENUM_INDICATOR_SHOW_STATE
    {
      INDICATOR_SHOW_ON_CHART = CHECKBOX_STATE_ON,
      INDICATOR_HIDE_ON_CHART = CHECKBOX_STATE_OFF,
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
   
  //For Indicator table field show in m_table_indicator and m_table_indicator_SymbolTFValue
   #define INDICATOR_PARATEXT_WIDTH 180 //Include name + Icon
  class CGUIPannel : public CWndEvents
   {
    private: 
     //PUre Data Layer 1
     // Private Pointer variables    
      CSymbolsCollection         *m_symbol_collection;                //CTradingEngine owns
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
      CTradingLevelBubble        m_trading_bubble;                    // OWNED - lazy-init: OnInitEvent() only called once HasAnyLevel() is true
      bool                       m_bubble_created;                    // guard, like m_gui_created
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
         CButton              m_btn_add_indicator;                         //CButton to Add Indicator
         CButton              m_btn_save_indicator;                        //CButton to Save Indicator to JSON
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
         // Settings table col-4 "Show" dirty cache - parallel with m_table_indicator_ptrs
         int                  m_settings_cache_state[];

       // --- Signal arrows/thumbs on the chart (current chart symbol+period only - other symbols
       // in the table have no chart of their own to draw on). Watermark tracked per (symbol,TF)
       // key so switching the chart's own symbol/TF doesn't skip real new signals by comparing
       // against an unrelated timeline's last-drawn time.
        CGraphElementsCollection  m_graph_elements;
        string                    m_signal_arrows_key[];
        datetime                  m_signal_arrows_last_time[];

       // --- Layer-3 observer (README: 3-layer sync). OWNED here. Watches every open chart's
       // --- windows + their indicators and emits CHART_OBJ_EVENT_CHART_WND_IND_ADD/DEL/CHANGE,
       // --- so Layer 2 keeps its "Show" column truthful even when the user adds/removes an
       // --- indicator BY HAND on the chart. Styling (colors) is out of scope by design - MT5
       // --- has no API to restyle an indicator instance that is already attached to a chart.
        CChartObjCollection       m_chart_obj_collection;
      // SIndicatorCatalogItem now lives in Artyom Trishkin\IndicatorCatalog.mqh (Tang 1 metadata)      
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
       //Handler for TreeView m_treeview_indicator.
         void                         ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li);
         void                         HideParamSlots(void);
         void                         OnClickAddIndicator(void);
         void                         OnClickSaveIndicators(void);
       //For Indicator Table m_table_indicator   
         bool                         CreateIndicatorTable(const int x, const int y);         
         void                         RefreshIndicatorTable(void);         
         void                         RefreshIndicatorTableShowColumn(void);
         void                         SetIndicatorTableRow(const int row, CIndicatorDE *indicator);         
         bool                         IsIndicatorShownOnChart(CIndicatorDE *indicator);         
         bool                         LineRepresentsIndicator(const int line_handle, CIndicatorDE *indicator);
         CIndicatorDE                 *OwnedInstanceOfLine(const int line_handle);
         void                         ImportForeignChartIndicators(void);        
       //For Indicator Symbol TF Table m_table_indicator_SymbolTFValue
         bool                         CreateIndicatorSymbolTFTable(const int x, const int y);
         void                         SetValuesToIndicatorSymbolTFTable(void);
       //TEST-ONLY (V7 Test copy): table-overflow diagnostic, remove once root-caused
         void                         LogTableGeometry(const string tag, CTable &table);
         string                       BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[]);
         void                         DrawSignalArrows(void);
         int                          SignalArrowsFindOrAddKey(const string key);
         void                         ResetSignalArrows(void);
         void                         PurgeSignalArrowObjects(const string sym, const ENUM_TIMEFRAMES tf);
       //Helper
        static void                   SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw);
        int                           GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[]); 
       //Event Handler for m_table_indicator
        void                          OnClickToggleShowIndicatorOnChart(const string sname, const int row);
        void                          OnClickToggleBuySignal(const string sname, const int row);
        void                          OnClickToggleSellSignal(const string sname, const int row);
        void                          OnClickRemoveIndicator(const string sname, const int row);  
        void                          HandleChartIndicatorChange(void);
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
         void                         OnTradeEvent(void);
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
        void  SetMarketCollection(CMarketCollection *market)      { m_trading_bubble.SetMarketCollection(market); }
        void  SetTradingControl(CTradingControl *trading_control) { m_trading_bubble.SetTradingControl(trading_control); }
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
      m_bubble_created  = false;
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
      // Snapshot every open chart (windows + indicators) once - Refresh() in OnTimerEvent
      // then diffs against this baseline and emits CHART_OBJ_EVENT_* on changes
      m_chart_obj_collection.CreateCollection();
      UpdateGUI(true);
      // Startup reconcile: adopt any indicator the user attached while the EA was off.
      // MUST run AFTER UpdateGUI - m_IndicatorsCollection.TemplateExists() needs the collection
      // already populated; running before it re-imported
      // every JSON template as a duplicate (and AddIndicatorToList deleting those duplicates
      // was the source of the dangling-pointer crash in SignalsCollection).
       ImportForeignChartIndicators();
      // Debug helper (kept available, call disabled after the 4807 hunt closed): dump the
      // instance->handle map right after startup
      //m_time_series_engine.PrintIndicatorsInventory();
    }
   else if(uninit_reason == REASON_CHARTCHANGE)
    {
      // No manual redraw here (2026-07-14) - MT5 already redraws the chart natively on
      // symbol/TF change, and CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE (OnEvent) does the
      // same content refresh moments later. Two ChartRedraw() calls back-to-back was
      // the m_window_main flicker on every TF switch.
      UpdateGUI(false);
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
         //else if(col == 4)    OnClickShowLine(sname, row);     // toggle ChartIndicatorAdd/Delete
         else if(col == 4)    OnClickToggleShowIndicatorOnChart(sname, row);     // toggle ChartIndicatorAdd/Delete
         return;
      }  
    //--- Layer 3 -> Layer 2 state sync: an indicator was added/removed/param-changed on some
    //--- chart window (possibly BY HAND on the chart) - re-truth the "Show" column. Events
    //--- come from m_chart_obj_collection.Refresh() polled in OnTimerEvent.
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_DEL ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
      {
         // A NEW indicator on the chart may be one Layer 1 doesn't know yet (added by hand) -
         // import it as a template first (idempotent), THEN re-truth the "Show" column.
         if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD)
            ImportForeignChartIndicators();
         // A param edit made ON THE CHART replaces the matching Layer 1 template (Layer 3
         // leads, Layer 1+2 follow). A DEL stays visibility-only: Layer 1 keeps the
         // template, only the "Show" checkbox unticks.
         if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
            HandleChartIndicatorChange();
         RefreshIndicatorTableShowColumn();
         return;
      }
    //--- Layer 3 -> Layer 2: symbol/TF actually changed on this chart (CChartObjCollection,
    //--- same poll/diff pattern as IND_ADD/DEL/CHANGE above) - single place that rebuilds the
    //--- SymbolTF tree + indicator table on a real change. Replaces the old CHARTEVENT_CHART_CHANGE
    //--- handler, which duplicated this same refresh AND called ChartRedraw() a second time right
    //--- after OnInitEvent's REASON_CHARTCHANGE already did - that double-redraw was the
    //--- m_window_main flicker on every TF/symbol switch (fixed 2026-07-14).
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_CHANGE ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_TF_CHANGE ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE)
      {
         PopulateSymbolTFTree();
         SynSymbolTFTreeViewIcons();
         UpdateGUI(false);   // dirty-check refresh only - no manual redraw, MT5 already redraws natively on chart change
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
    // --- CHARTEVENT_CHART_CHANGE: symbol/TF tree rebuild moved to CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE
    // --- above (2026-07-14) - this native event still fires on every scroll/zoom too, so it was never
    // --- a reliable "did symbol/TF really change" signal on its own; the CChartObjCollection event is.
    // --- Trading bubble: forward whatever wasn't already claimed above
    // --- (CHARTEVENT_MOUSE_MOVE for drag, CHARTEVENT_CLICK for the X button,
    // --- CHARTEVENT_CUSTOM trade events from CTradeEventsCollection, and
    // --- CHARTEVENT_CHART_CHANGE for redraw-on-zoom/scroll).
     if(m_bubble_created)
        m_trading_bubble.OnChartEvent(id, lparam, dparam, sparam);
   }
  void CGUIPannel::OnTickEvent(void)
   {
      
   }
  //+------------------------------------------------------------------+
  //| Deinit                                                           |
  //+------------------------------------------------------------------+
  void CGUIPannel::OnDeinitEvent(const int reason)
   {
      if(m_bubble_created) m_trading_bubble.OnDeinitEvent();
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

      if(m_bubble_created) m_trading_bubble.OnPoll();

      SetValuesToIndicatorSymbolTFTable();
      DrawSignalArrows();
      //--- Layer-3 observer poll: diffs all open charts and broadcasts CHART_OBJ_EVENT_*
      //--- custom events (handled in OnEvent -> RefreshIndicatorTableShowStates)
      m_chart_obj_collection.Refresh();

      ulong t2 = ::GetMicrosecondCount();
      // if(t2 - t0 > 1000)
      //  Print("PERF CGUIPannel::OnTimerEvent CWndEvents::OnTimerEvent= ", t1 - t0, " us CTradingLevelBubble::OnPoll= ", t2 - t1, " us");
   }
  //+------------------------------------------------------------------+
  //| Trade operation event                                            |
  //+------------------------------------------------------------------+
  void CGUIPannel::OnTradeEvent(void)
   {
      // --- Lazy-init the trading bubble: only pay for the full-screen canvas +
      // --- hiding native SL/TP lines once there is an actual SL/TP to show on the
      // --- CURRENT chart's symbol. Once created, left running (idle draws are
      // --- cheap - Draw() itself no-ops via the unchanged-state check).
      if(!m_bubble_created && m_trading_bubble.HasAnyLevel())
        {
         if(m_trading_bubble.OnInitEvent())
            m_bubble_created = true;
        }
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
      // --- Trading bubble: just wire the mouse pointer now (cheap, no canvas yet) -
      // --- OnInitEvent() itself is lazy, called from OnTradeEvent() only once
      // --- HasAnyLevel() is true (avoid creating a full-screen canvas + hiding
      // --- native SL/TP lines when there is nothing to show).
        m_trading_bubble.MousePointer(m_mouse);
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
      // No unconditional full-canvas Update(true) here - repainting the whole treeview and
      // the whole Settings table on every CHARTCHANGE was exactly the m_window_main blink.
      // Each call below repaints only the cells/icons it actually changed (dirty-check),
      // and PopulateSymbolTFTree (CHARTEVENT_CHART_CHANGE handler) already updates the tree
      // when the symbol/TF really changed.
      RefreshIndicatorTable();
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
   //For m_table_indicator in TAB_TAB_MAIN_SETTINGS    
    // =====================================================================
    // --- Info tab: port of V4 m_table_indicator, same 5-column layout
    // =====================================================================
    bool CGUIPannel::CreateIndicatorTable(const int x, const int y)
     {
       m_table_indicator.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_table_indicator);
       //Resize Properties
        m_table_indicator.AutoXResizeMode(true);
        m_table_indicator.AutoXResizeRightOffset(3);
        m_table_indicator.AutoYResizeMode(true);
        m_table_indicator.AutoYResizeBottomOffset(3);
       //Table Properties
        m_table_indicator.ShowHeaders(true);
        m_table_indicator.SelectableRow(true);
        m_table_indicator.LightsHover(true);
        m_table_indicator.IsSortMode(true);
       // --- 5 columns: col 0 merges the old icon-only "show on T3" column with the
       // --- "Indicator" text column (CTCell renders image+text independently, click
       // --- detection is scoped to the image's own pixel width - see Table.mqh
       // --- CheckPressedCheckBox/CheckPressedButton). Buy/Sell/Delete shift down by 1.
        m_table_indicator.TableSize(5, 20);
        int widths[5]    = {180, 70, 40, 40, 40};
        int img_x_off[5] = {3,   0,  10, 10, 10};
        int img_y_off[5] = {3,   0,  3,  3,  3};
        ENUM_ALIGN_MODE align[5] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
        m_table_indicator.ColumnsWidth(widths);
        m_table_indicator.ImageXOffset(img_x_off);
        m_table_indicator.ImageYOffset(img_y_off);
        m_table_indicator.TextAlign(align);

        if(!m_table_indicator.CreateTable(x, y)) return false;
        //Set Header text
          m_table_indicator.SetHeaderText(0, "Indicator");
          m_table_indicator.SetHeaderText(1, "Group");
        //Checkbox to show or hide on Layer 3 (Chart)
          m_table_indicator.SetHeaderText(2, "Buy");
          m_table_indicator.SetHeaderText(3, "Sell");
          m_table_indicator.SetHeaderText(4, "Show");

       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator);
       return true;
     }
    //Ver 1
    // --- Template view of Layer 1 (see README 5c): one row per template. The row set changes
    // --- ONLY via LoadIndicatorFromJSON (initial build here), AddIndicatorInstance (appends its
    // --- own row) and OnClickRemoveIndicator (DeleteRow) - so no dedup and no periodic rebuild.
    // --- By the Layer-1 invariant every series carries the same template set, hence the current
    // --- chart's (symbol,TF) instance list IS the template list, one instance per template.
    void CGUIPannel::RefreshIndicatorTable(void)
     {
      if(m_IndicatorsCollection == NULL) return;
      string sym = ::Symbol();
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);

      CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      int count = (list == NULL) ? 0 : list.Total();

      // --- Row set already matches the template count: re-point the BORROWED per-row
      // --- pointers at the CURRENT chart's instances (they change on CHARTCHANGE) and
      // --- dirty-refresh the per-chart "Show" column only - no structural change, no flicker.
      if(count == ArraySize(m_table_indicator_ptrs) && count > 0)
       {
        SIndicatorCatalogItem catalog[];
        GetIndicatorCatalog(catalog);
        for(int i = 0; i < count; i++)
          {
            CIndicatorDE *indicator = list.At(i);
            if(indicator == NULL) continue;
            // --- Table may be sorted (IsSortMode) - Col 0's label text travels WITH its row
            // --- through a sort, so match against it to find the CURRENT physical row
            // --- instead of trusting collection order == row index.
            string label = "        " + BuildIndicatorLabel(indicator, catalog);
            int row = -1;
            for(int r = 0; r < count; r++)
              if(m_table_indicator.GetValue(0, r) == label) { row = r; break; }
            if(row < 0) continue;
            m_table_indicator_ptrs[row]  = indicator;
            m_table_indicator_names[row] = indicator.ShortName();
          }
        RefreshIndicatorTableShowColumn();
        return;
       }
      // --- Structural (re)build - initial fill after LoadIndicatorFromJSON, or safety on mismatch
      if(count == 0)
        {
         if(ArraySize(m_table_indicator_ptrs) == 0) return; // already showing the empty state - leave the table alone
         m_table_indicator.DeleteAllRows();
         m_table_indicator.AddRow(0);   // safety row: Library bug - DeleteAllRows does not reset m_item_index_focus
         ArrayResize(m_table_indicator_names, 0);
         ArrayResize(m_table_indicator_ptrs, 0);
         ArrayResize(m_settings_cache_state, 0);
         m_table_indicator.Update(true);
         LogTableGeometry("RefreshIndicatorTable-empty", m_table_indicator);
         return;
        }
      m_table_indicator.DeleteAllRows();
      for(int i = 0; i < count - 1; i++)   // DeleteAllRows leaves one physical row behind
         m_table_indicator.AddRow(i);
      ArrayResize(m_table_indicator_names, count);
      ArrayResize(m_table_indicator_ptrs, count);
      ArrayResize(m_settings_cache_state, count);
      for(int row = 0; row < count; row++)
         SetIndicatorTableRow(row, list.At(row));
      m_table_indicator.Update(true);
      LogTableGeometry("RefreshIndicatorTable count=" + IntegerToString(count), m_table_indicator);
     }
    // --- Fill every cell of one template row + the parallel arrays (names/ptrs/state cache)
    void CGUIPannel::SetIndicatorTableRow(const int row, CIndicatorDE *indicator)
     {
      if(indicator == NULL) return;
      uint delete_icon[]   = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
      uint chk[]           = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
      uint show_on_chart[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
      string group_names[] = {"Trend", "Oscillator", "Volumes", "Arrows"};

      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);
      string label = BuildIndicatorLabel(indicator, catalog);

      // --- Col 0: red Close (delete) icon + label - click detection covers the icon only
      // --- (Table.mqh CheckPressedButton scopes it to the image pixel width)
      m_table_indicator.CellType(0, row, CELL_BUTTON);
      m_table_indicator.SetImages(0, row, delete_icon);
      m_table_indicator.ChangeImage(0, row, 0);
      m_table_indicator.SetValue(0, row, "        " + label);   // leading spaces clear the icon
      // --- Col 1: group name
       int group = (int)indicator.Group();
       string gname = (group >= 0 && group < 4) ? group_names[group] : "Other";
       m_table_indicator.SetValue(1, row, "  " + gname);
      // --- Col 2/3: Buy / Sell signal filters (default OFF - arrows are opt-in per template;
      // --- DrawSignalArrows reads these checkboxes live, toggles just reset the arrows)
       m_table_indicator.CellType(2, row, CELL_CHECKBOX);
       m_table_indicator.SetImages(2, row, chk);
       m_table_indicator.ChangeImage(2, row, 1);
       m_table_indicator.CellType(3, row, CELL_CHECKBOX);
       m_table_indicator.SetImages(3, row, chk);
       m_table_indicator.ChangeImage(3, row, 1);
      // --- Col 4: "shown on the CURRENT chart" checkbox
       int state = IsIndicatorShownOnChart(indicator) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
       m_table_indicator.CellType(4, row, CELL_CHECKBOX);
       m_table_indicator.SetImages(4, row, show_on_chart);
       m_table_indicator.ChangeImage(4, row, state);

       m_table_indicator_names[row] = indicator.ShortName();
       m_table_indicator_ptrs[row]  = indicator;   // BORROWED - CIndicatorsCollection owns it
       m_settings_cache_state[row]  = state;
     }
    // --- True when the CURRENT chart displays this indicator instance. The Layer 3 mirror
    // --- (CChartObjCollection -> CWndInd) stores the real slot handle, and MQL5 slots are
    // --- program-wide: the line of an instance Layer 1 owns carries Layer 1's own handle
    // --- number - the handle is the exact join key (names have different formats:
    // --- chart line "SAR(0.05,0.2)" vs CIndicatorDE::ShortName "SAR(BTCUSDm,M1)").
    bool CGUIPannel::IsIndicatorShownOnChart(CIndicatorDE *indicator)
    {
      if(indicator == NULL) return false;
      CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
      if(chart == NULL) return false;
      for(int win = 0; win < chart.WindowsTotal(); win++)
        {
          CChartWnd *wnd = chart.GetWindowByNum(win);
          if(wnd == NULL) continue;
          for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
            {
            CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
            if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
              {
                // --- DEBUG IsIndicatorShownOnChart - removed 2026-07-14, fired every row every tick
                //::Print("DEBUG IsIndicatorShownOnChart indicator_handle=", indicator.Handle(),
                //        " -> MATCHED line '", wnd_ind.Name(), "' handle=", wnd_ind.Handle());
                return true;
              }
            }
        }
      return false;
    }
    // --- Per-chart part of the Settings table (col 4 "Show") - dirty-check, no structural change
    void CGUIPannel::RefreshIndicatorTableShowColumn(void)
     {
      bool any_changed = false;
      for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
        {
         int state = IsIndicatorShownOnChart(m_table_indicator_ptrs[row]) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
         if(state == m_settings_cache_state[row]) continue;
         m_settings_cache_state[row] = state;
         m_table_indicator.ChangeImage(4, row, state);
         m_table_indicator.BackColor(4, row, clrWhite, true);   // force this one cell to repaint
         any_changed = true;
        }
      if(any_changed)
         m_table_indicator.Update(false);
     }
    // =====================================================================
    // --- "Add" button click handler — converts text fields to MqlParam[]
    // =====================================================================
    // --- Col 4 checkbox: Tang 2 controls Tang 3 only - never touches PureData.
    // --- The table already auto-toggled the icon before sending this event, so
    // --- SelectedImageIndex(4,row) tells us the state to APPLY (0=show, 1=hide).
    // --- Matched by ind.Handle(), not by name - two instances of the same type
    // --- with different params can share the same native chart-assigned name.
    void CGUIPannel::OnClickToggleShowIndicatorOnChart(const string sname, const int row)
     {
      if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
      CIndicatorDE *ind = m_table_indicator_ptrs[row];
      if(ind == NULL) return;

      int new_state = (int)m_table_indicator.SelectedImageIndex(4, row);
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
      if(new_state == INDICATOR_HIDE_ON_CHART)   // Hide: remove from chart, PureData/handle stay intact
        {
         // Find this instance's line(s) through the Layer 3 mirror - handle is the join
         // key (program-wide slot), no Get/Release needed in the GUI at all
         CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
         if(chart != NULL)
            for(int win = chart.WindowsTotal() - 1; win >= 0; win--)
              {
               CChartWnd *wnd = chart.GetWindowByNum(win);
               if(wnd == NULL) continue;
               for(int i = wnd.IndicatorsTotal() - 1; i >= 0; i--)
                 {
                  CWndInd *wnd_ind = wnd.GetIndicatorByIndex(i);
                  if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), ind))
                     ChartIndicatorDelete(0, win, wnd_ind.Name());
                 }
              }
        }
      else // Show: re-attach using the stored handle
        {
         int sub_window = (ind.Group() == INDICATOR_GROUP_TREND) ? 0 : subwindows;
         ChartIndicatorAdd(0, sub_window, ind.Handle());
        }
      ChartRedraw();
     }
    // --- Col 2/3 checkboxes: per-template Buy/Sell signal filters. The table already
    // --- flipped the checkbox image before this handler fires; DrawSignalArrows reads the
    // --- checkbox states live, so all a toggle needs is a clean redraw of the arrows.
    void CGUIPannel::OnClickToggleBuySignal(const string sname, const int row) { ResetSignalArrows(); }
    void CGUIPannel::OnClickToggleSellSignal(const string sname, const int row) { ResetSignalArrows(); }
    // --- Wipe this chart's signal arrows and rewind the watermark: the next timer tick
    // --- redraws the whole history from scratch under the CURRENT Buy/Sell filters
    void CGUIPannel::ResetSignalArrows(void)
     {
      string sym = ::Symbol();
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
      int wm_idx = SignalArrowsFindOrAddKey(sym + "|" + EnumToString(tf));
      m_signal_arrows_last_time[wm_idx] = 0;
      PurgeSignalArrowObjects(sym, tf);
      ::ChartRedraw(m_chart_id);
     }
    // --- Delete every signal-arrow object of (sym, tf) from BOTH the chart and
    // --- CGraphElementsCollection's registry. A raw ObjectsDeleteAll leaves the registry
    // --- stale, and the collection then refuses to re-create the same names forever
    // --- ("Such a graphic object already exists" - its pre-create check is list-based).
    void CGUIPannel::PurgeSignalArrowObjects(const string sym, const ENUM_TIMEFRAMES tf)
     {
      string prefix = ::MQLInfoString(MQL_PROGRAM_NAME) + "_sig_" + sym + "_" + EnumToString(tf) + "_";
      // 1) Deregister first: GetListGraphObj() hands out the LIVE registry list
      //    (DeleteGraphObjFromList is private), and its FreeMode delete frees the
      //    collection-owned CGStdGraphObj records
      CArrayObj *registry = m_graph_elements.GetListGraphObj();
      if(registry != NULL)
         for(int r = registry.Total() - 1; r >= 0; r--)
           {
            CGStdGraphObj *obj = registry.At(r);
            if(obj != NULL && obj.ChartID() == m_chart_id && ::StringFind(obj.Name(), prefix) == 0)
               registry.Delete(r);
           }
      // 2) Then the chart objects themselves - also covers leftovers from a previous
      //    EA run that this instance never registered
      for(int i = ::ObjectsTotal(m_chart_id) - 1; i >= 0; i--)
        {
         string obj_name = ::ObjectName(m_chart_id, i);
         if(::StringFind(obj_name, prefix) == 0)
            ::ObjectDelete(m_chart_id, obj_name);
        }
     }
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
      //--- Audit line: template removals are destructive and reachable from several paths
      //--- (X icon, HandleChartIndicatorChange) - always log who goes and from which row
       ::Print(__FUNCTION__, " > row=", row, " '", m_table_indicator_names[row],
              "' ref handle=", ref_indicator.Handle());

       CArrayObj *list = m_IndicatorsCollection.GetList();
       if(list == NULL) return;
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
         if(!IsEqualMqlParamArrays(params, ref_params)) continue;

         // --- Release the Signal FIRST: CSignalsCollection borrows this indicator's
         // --- pointer (m_indicator_list[] + the signal's own m_indicator), so deleting
         // --- the indicator before its signal would leave both dangling.
         m_time_series_engine.GetSignalsCollection().DeleteSignal(indicator);

         // --- Detach from chart if currently shown (Layer 3 mirror, handle = join key).
         // --- The slot itself dies exactly once, in ~CIndicatorDE via list.Delete below.
         CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
         if(chart != NULL)
            for(int win = chart.WindowsTotal() - 1; win >= 0; win--)
              {
               CChartWnd *wnd = chart.GetWindowByNum(win);
               if(wnd == NULL) continue;
               for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
                 {
                  CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
                  if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
                     ChartIndicatorDelete(0, win, wnd_ind.Name());
                 }
              }
         list.Delete(i);   // CArrayObj FreeMode -> ~CIndicatorDE -> IndicatorRelease(handle)
        }
      // --- Drop exactly this row (Library CTable::DeleteRow shifts the rest up) and keep
      // --- the parallel arrays aligned. No DeleteAllRows here (README 5a/5c).
       int rows_after = ArraySize(m_table_indicator_ptrs) - 1;
       for(int r = row; r < rows_after; r++)
        {
         m_table_indicator_names[r] = m_table_indicator_names[r + 1];
         m_table_indicator_ptrs[r]  = m_table_indicator_ptrs[r + 1];
         m_settings_cache_state[r]  = m_settings_cache_state[r + 1];
        }
      ArrayResize(m_table_indicator_names, rows_after);
      ArrayResize(m_table_indicator_ptrs,  rows_after);
      ArrayResize(m_settings_cache_state,  rows_after);
      if(rows_after == 0)
        {
         // CTable::DeleteRow never shrinks below one physical row, and SetImages rejects an
         // empty array (no API to strip a cell's icons) - so add a freshly CellInitialize'd
         // blank row first, then delete the old row 0 that still carries the delete/checkbox
         // icons. The blank row shifts up and becomes the single empty survivor.
         m_table_indicator.AddRow(1);
         m_table_indicator.DeleteRow(0, true);
         m_table_indicator.Update(true);
        }
      else
         m_table_indicator.DeleteRow(row, true);
      LogTableGeometry("OnClickRemoveIndicator rows_after=" + IntegerToString(rows_after), m_table_indicator);

      SetValuesToIndicatorSymbolTFTable();
      SyncIndicatorTreeViewIcons();
      ChartRedraw();
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
//Event Handle  
  // =====================================================================
  // --- "Add" button click handler — converts text fields to MqlParam[]
  // =====================================================================
  void CGUIPannel::OnClickAddIndicator(void)
    {      
      SIndicatorParam schema[];
      int total = GetIndicatorParamSchema(m_current_param_type, schema);      
      if(total == 0) return;

      MqlParam params[];
      ArrayResize(params, total);
      for(int i = 0; i < total; i++)
       {
         params[i].type = schema[i].data_type;
         if(schema[i].choices != "")
           {
            // --- Enum param: read back the SELECTED TEXT, then let the Library's own
            // --- Xxx-ByDescription() (CommonDELib.mqh) resolve it to the real MQL5
            // --- enum value - no combo-row/native-value arithmetic anywhere.
             string parts[];
             int n = ::StringSplit(schema[i].choices, '|', parts);
             int sel = (int)m_param_combo[i].GetListViewPointer().SelectedItemIndex();
             string sel_text = (sel >= 0 && sel < n) ? parts[sel] : "";
             if(schema[i].choices == PRICE_CHOICES)
                params[i].integer_value = (long)AppliedPriceByDescription(sel_text);
             else if(schema[i].choices == CALCULATION_METHOD_CHOICES)
                params[i].integer_value = (long)AveragingMethodByDescription(sel_text);
             else if(schema[i].choices == VOLUME_CHOICES)
                params[i].integer_value = (long)AppliedVolumeByDescription(sel_text);
             else if(schema[i].choices == STOCH_PRICE_CHOICES)
                params[i].integer_value = (long)StochPriceByDescription(sel_text);
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
      if(m_time_series_engine == NULL || m_IndicatorsCollection == NULL) return;
      // --- Source-side duplicate guard (README 5c): the template set stays unique HERE,
      // --- at the only place templates enter Layer 1 - not hidden later by a display dedup.
      if(m_IndicatorsCollection.TemplateExists(type, params))
        {
         ::Print(__FUNCTION__, " > rejected: this template already exists");
         return;
        }

      if(!m_time_series_engine.AddNewIndicatorToAllSeries(type, params)) return;
      SyncIndicatorTreeViewIcons();   // full sweep + Update(true)

      // --- Append exactly ONE row for the new template (README 5c - no rescan, no rebuild).
      // --- The engine appends to the collection, so the new instance for the current chart
      // --- is the LAST one in the (symbol,TF)-filtered list.
      string sym = ::Symbol();
      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
      CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      if(list == NULL || list.Total() == 0) return;
      CIndicatorDE *indicator = list.At(list.Total() - 1);
      int row = ArraySize(m_table_indicator_ptrs);
      if(row > 0)                      // an empty table already owns one physical row - reuse it for row 0
         m_table_indicator.AddRow(row);
      ArrayResize(m_table_indicator_names, row + 1);
      ArrayResize(m_table_indicator_ptrs,  row + 1);
      ArrayResize(m_settings_cache_state,  row + 1);
      SetIndicatorTableRow(row, indicator);
      m_table_indicator.Update(true);
      LogTableGeometry("AddIndicatorInstance row=" + IntegerToString(row), m_table_indicator);
   }  
  // --- Does this Layer 3 line represent this Layer 1 instance?
  // --- Fast path: shared slot - only lines WE attached (ChartIndicatorAdd with our own
  // --- handle). A HAND-ADDED line is a SEPARATE terminal instance with its own slot
  // --- (proven 18:58 log: line handle=17 vs owned=18 for identical SAR(0.05,0.20)),
  // --- so fall back to the template identity: type+params via IndicatorParameters.
  // --- The line's slot stays readable forever because nobody ever releases it.
  bool CGUIPannel::LineRepresentsIndicator(const int line_handle, CIndicatorDE *indicator)
  {
    if(line_handle == INVALID_HANDLE || indicator == NULL) return false;
    if(line_handle == indicator.Handle())
      {
        // --- DEBUG LineRepresentsIndicator FAST-MATCH - removed 2026-07-14, fired every row every tick
        //::Print("DEBUG CGUIPannel::LineRepresentsIndicator FAST-MATCH line_handle=", line_handle,
        //        " own_handle=", indicator.Handle());
        return true;
      }
    ENUM_INDICATOR type;
    MqlParam params[];
    if(IndicatorParameters(line_handle, type, params) < 0) return false;
    if(type != indicator.TypeIndicator()) return false;
    MqlParam own_params[];
    indicator.GetMqlParams(own_params);
    bool eq = IsEqualMqlParamArrays(own_params, params);
    return eq;
  }
  // --- Resolve a Layer 3 line to the Layer 1 instance (current symbol/TF) it represents,
  // --- or NULL when the line is foreign. Same fast/slow paths as LineRepresentsIndicator.
  CIndicatorDE *CGUIPannel::OwnedInstanceOfLine(const int line_handle)
   {
      if(line_handle == INVALID_HANDLE || m_time_series_engine == NULL) return NULL;
      CIndicatorDE *owned = m_time_series_engine.GetIndicatorByHandle(line_handle);
      if(owned != NULL) return owned;
      for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
         if(LineRepresentsIndicator(line_handle, m_table_indicator_ptrs[row]))
            return m_table_indicator_ptrs[row];
      return NULL;
   }
  // --- Layer 3 -> Layer 1 import (README: 3-layer sync): an indicator is present on the MAIN
  // --- chart that Layer 1 does not know yet (added BY HAND on the chart). Rebuild its
  // --- type+params via IndicatorParameters() and feed it through the SAME entry point as the
  // --- GUI "Add" button (AddIndicatorInstance), so the duplicate guard, the engine creation
  // --- across ALL series (+Signals via GetOrCreateSignal) and the template-row append all
  // --- behave identically. Idempotent: our own ChartIndicatorAdd (Show checkbox) also fires
  // --- IND_ADD, but TemplateExists() filters it out here without log spam.
  void CGUIPannel::ImportForeignChartIndicators(void)
   {
      if(m_time_series_engine == NULL) return;
      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);
      // Layer 3 topology comes from CChartObjCollection (the one chart observer),
      // not from raw built-in scans - README: 3-layer sync.
      CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
      if(chart == NULL) return;
      for(int win = 0; win < chart.WindowsTotal(); win++)
        {
         CChartWnd *wnd = chart.GetWindowByNum(win);
         if(wnd == NULL) continue;
         for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
           {
            CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
            if(wnd_ind == NULL) continue;
            string name = wnd_ind.Name();
            // The mirror's handle is the join key: same program-wide slot number as the
            // owned instance when the line belongs to Layer 1. Never released anywhere
            // in the GUI - the sole IndicatorRelease site is ~CIndicatorDE.
            int handle = wnd_ind.Handle();
            if(handle == INVALID_HANDLE) continue;
            if(m_time_series_engine.GetIndicatorByHandle(handle) != NULL)
               continue;   // Layer 1 owns it already: nothing to import
            ENUM_INDICATOR type;
            MqlParam params[];
            int params_total = IndicatorParameters(handle, type, params);
            // Only types Layer 1 knows how to create (present in the catalog)
            bool supported = false;
            for(int c = 0; c < ArraySize(catalog); c++)
               if(catalog[c].type == type) { supported = true; break; }
            if(params_total < 0 || !supported || m_IndicatorsCollection.TemplateExists(type, params))
               continue;
            ::Print(__FUNCTION__, " > importing hand-added indicator '", name, "' into Layer 1");
            // Adopt: AddIndicatorInstance -> IndicatorCreate returns this very slot and
            // Layer 1 becomes its owner (released exactly once, in ~CIndicatorDE).
            AddIndicatorInstance(-1, type, params);
           }
        }
   }
  // --- Layer 3 -> Layer 1 sync for a param edit made ON THE CHART (README: 3-layer sync).
  // --- Trishkin's change-check kept a COPY of the old mirror entry (old name+handle) in
  // --- m_list_ind_param and updated the live mirror entry in place with the new name+handle
  // --- at the same window/index. So: old handle -> the exact Layer 1 template to replace;
  // --- the live mirror entry at the same index -> the new params.
  void CGUIPannel::HandleChartIndicatorChange(void)
   {
      if(m_time_series_engine == NULL) return;
      CWndInd *old_ind = m_chart_obj_collection.GetLastChangedIndicator();
      //--- Every exit path reports itself: chart edits are rare, user-driven events and
      //--- each outcome (replace/skip/fail) is worth an audit line in the log
      if(old_ind == NULL) { ::Print(__FUNCTION__, " > no changed-indicator record"); return; }
      ::Print(__FUNCTION__, " > chart edit detected: old '", old_ind.Name(), "' handle=", old_ind.Handle(),
              " win=", old_ind.WindowNum(), " index=", old_ind.Index());
      // A hand-added line is a SEPARATE terminal instance - OwnedInstanceOfLine falls back
      // to type+params matching. Truly foreign lines (no matching template) are skipped:
      // the ADD/import path picks the new line up by itself.
      CIndicatorDE *owned = OwnedInstanceOfLine(old_ind.Handle());
      if(owned == NULL) { ::Print(__FUNCTION__, " > line matches no Layer 1 template - skip"); return; }
      CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
      if(chart == NULL) { ::Print(__FUNCTION__, " > no CChartObj for this chart"); return; }
      CChartWnd *wnd = chart.GetWindowByNum(old_ind.WindowNum());
      if(wnd == NULL) { ::Print(__FUNCTION__, " > no CChartWnd num=", old_ind.WindowNum()); return; }
      CWndInd *new_ind = NULL;
      for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
        {
         CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
         if(wnd_ind != NULL && wnd_ind.Index() == old_ind.Index()) { new_ind = wnd_ind; break; }
        }
      if(new_ind == NULL || new_ind.Handle() == INVALID_HANDLE)
        { ::Print(__FUNCTION__, " > no mirror entry at window index ", old_ind.Index()); return; }
      ENUM_INDICATOR type;
      MqlParam params[];
      if(IndicatorParameters(new_ind.Handle(), type, params) < 0)
        { ::Print(__FUNCTION__, " > IndicatorParameters failed, err ", GetLastError()); return; }
      // Find the table row of the owned template (its current-symbol/TF instance is the
      // very object GetIndicatorByHandle returned, because the edit happened on THIS chart)
      int row = -1;
      for(int r = 0; r < ArraySize(m_table_indicator_ptrs); r++)
         if(m_table_indicator_ptrs[r] == owned) { row = r; break; }
      ::Print(__FUNCTION__, " > chart edit: replacing template '", old_ind.Name(),
              "' with '", new_ind.Name(), "'");
      // Replace = remove the old template across ALL series + add the new one across ALL
      // series (CIndicatorDE cannot change params in place - its handle is bound to the
      // old instance). One row out, one row in - the table keeps its size.
      // NOTE: owned is DEAD after OnClickRemoveIndicator (collection FreeMode deletes it).
      if(row >= 0)
         OnClickRemoveIndicator(m_table_indicator_names[row], row);
      AddIndicatorInstance(-1, type, params);
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
        // m_btn_add_indicator.BackColor(clrDodgerBlue);
        // m_btn_add_indicator.BackColorHover(clrRoyalBlue);
        // m_btn_add_indicator.BackColorPressed(clrBlue);
        // m_btn_add_indicator.LabelColor(clrWhite);
        // m_btn_add_indicator.BorderColor(clrBlue);
      bool created = m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
   if(!created) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_add_indicator);
   //For Button Save
      m_btn_save_indicator.MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_btn_save_indicator);
      m_btn_save_indicator.AutoXResizeMode(false);
      m_btn_save_indicator.XSize(80);
      m_btn_save_indicator.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
        // m_btn_save_indicator.BackColor(clrForestGreen);
        // m_btn_save_indicator.BackColorHover(clrGreen);
        // m_btn_save_indicator.BackColorPressed(clrDarkGreen);
        // m_btn_save_indicator.LabelColor(clrWhite);
        // m_btn_save_indicator.BorderColor(clrGreen);
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
void CGUIPannel::OnClickSaveIndicators(void)
    {
      if(m_time_series_engine == NULL) return;
      m_time_series_engine.SaveIndicatorToJSON("indicators_config.json");
    }
 //Calculatioon for display in Control  
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
    int widths[7]    = {90,  60, INDICATOR_PARATEXT_WIDTH, 90, 40, 40, 55};
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

   // --- Same schema the Add form uses (README: Tang 1 metadata). schema[i].choices
   // marks an enum-like param (Method, Applied Price, ...) - stored integer_value is
   // always the REAL MQL5 enum value (never a bare combo index), so decode it back to
   // text via the matching CommonDELib.mqh XxxDescription() - dispatched by comparing
   // choices against the 4 known constants, no separate "kind" needed.
   SIndicatorParam schema[];
   GetIndicatorParamSchema(ind.TypeIndicator(), schema);

   MqlParam mql_params[];
   ind.GetMqlParams(mql_params);
   string pvalues = "";
   for(int i = 0; i < ::ArraySize(mql_params); i++)
     {
      if(i > 0) pvalues += ", ";
      string choices = (i < ::ArraySize(schema)) ? schema[i].choices : "";
      if(choices == PRICE_CHOICES)
         pvalues += AppliedPriceDescription((ENUM_APPLIED_PRICE)mql_params[i].integer_value);
      else if(choices == CALCULATION_METHOD_CHOICES)
         pvalues += AveragingMethodDescription((ENUM_MA_METHOD)mql_params[i].integer_value);
      else if(choices == VOLUME_CHOICES)
         pvalues += AppliedVolumeDescription((ENUM_APPLIED_VOLUME)mql_params[i].integer_value);
      else if(choices == STOCH_PRICE_CHOICES)
         pvalues += StochPriceDescription((ENUM_STO_PRICE)mql_params[i].integer_value);
      else if(mql_params[i].type == TYPE_DOUBLE)
         pvalues += ::DoubleToString(mql_params[i].double_value, 2);
      else
         pvalues += ::IntegerToString((int)mql_params[i].integer_value);
     }
   return short_name + (pvalues != "" ? "  (" + pvalues + ")" : "");
  }
//+------------------------------------------------------------------+
//| Populate / refresh the Trade tab table (no-flicker per-cell)     |
//+------------------------------------------------------------------+
// --- TEST-ONLY (V7 Test copy): dumps row count vs visible capacity vs window Y size right
// --- after a table rebuild, to correlate against when the black/smeared overflow area is
// --- actually seen on screen. Remove once Table.mqh's overflow bug is root-caused.
void CGUIPannel::LogTableGeometry(const string tag, CTable &table)
  {
   Print("TEST LogTableGeometry [", tag, "] RowsTotal=", table.RowsTotal(),
         " VisibleRowsTotal=", table.VisibleRowsTotal(),
         " window_main.YSize=", m_window_main.YSize(),
         " table.YSize=", table.YSize(),
         " table.YGap=", table.YGap());
  }
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

   // --- All templates gone: purge the table down to ONE truly blank physical row.
   // --- DeleteAllRows only clears text - the surviving row would keep its icons
   // --- (SetImages rejects an empty array), so swap in a freshly CellInitialize'd
   // --- row via AddRow(1) + DeleteRow(0), same trick as m_table_indicator.
   if(count == 0)
     {
      if(m_trade_table_row_count != 0)
        {
         m_table_indicator_SymbolTFValue.DeleteAllRows();
         m_table_indicator_SymbolTFValue.AddRow(1);
         m_table_indicator_SymbolTFValue.DeleteRow(0, true);
         ::ArrayResize(m_trade_cache_val,      0);
         ::ArrayResize(m_trade_cache_sig_icon, 0);
         ::ArrayResize(m_trade_cache_dir_icon, 0);
         m_trade_table_row_count = 0;
         m_table_indicator_SymbolTFValue.Update(true);
         LogTableGeometry("SetValuesToIndicatorSymbolTFTable-empty", m_table_indicator_SymbolTFValue);
        }
      return;
     }

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
      LogTableGeometry("SetValuesToIndicatorSymbolTFTable count=" + IntegerToString(count), m_table_indicator_SymbolTFValue);
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
      // Col 2/3 checkboxes are the per-template opt-in: image 0 = ticked. Rows hold the
      // very same current-symbol/TF instances this loop iterates, so pointer match works.
      bool buy_on = false, sell_on = false;
      for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
         if(m_table_indicator_ptrs[row] == ind)
           {
            buy_on  = ((int)m_table_indicator.SelectedImageIndex(2, row) == 0);
            sell_on = ((int)m_table_indicator.SelectedImageIndex(3, row) == 0);
            break;
           }
      if(!buy_on && !sell_on) continue;   // nothing requested: don't even create the signal
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
         if(dir == SIGNAL_BUY  && !buy_on)  continue;
         if(dir == SIGNAL_SELL && !sell_on) continue;
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

   // Fresh watermark (first run after start/restart or after a Buy/Sell toggle): wipe any
   // leftover arrows of this sym|TF first, so the set on chart always equals exactly what
   // the current filters say (also purges the price~0 corpses of README 5b).
   if(last_time == 0 && ::ArraySize(bucket_time) > 0)
      PurgeSignalArrowObjects(sym, tf);

   double pad = ::SymbolInfoDouble(sym, SYMBOL_POINT) * 50;
   datetime newest = last_time;
   datetime failed_oldest = 0;
   for(int b = 0; b < ::ArraySize(bucket_time); b++)
     {
      int total    = bucket_buy[b] + bucket_sell[b];
      bool net_buy = bucket_buy[b] >= bucket_sell[b];
      // README 5b fix: only draw when the bar data is truly ready - a failed shift or an
      // empty CopyLow/High used to produce an arrow at price~0, parked forever below the
      // viewport because the watermark advanced anyway.
      int shift    = ::iBarShift(sym, tf, bucket_time[b], true);
      double lo[1] = {0}, hi[1] = {0};
      bool data_ok = (shift >= 0 &&
                      ::CopyLow(sym, tf, shift, 1, lo)  == 1 &&
                      ::CopyHigh(sym, tf, shift, 1, hi) == 1 &&
                      lo[0] > 0.0);
      if(!data_ok)
        {
         // Remember the OLDEST failed bar: the watermark must stay below it so the next
         // timer tick retries this signal instead of losing it forever
         if(failed_oldest == 0 || bucket_time[b] < failed_oldest)
            failed_oldest = bucket_time[b];
         continue;
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
   // Watermark never crosses an undrawn signal: cap it just below the oldest failure.
   // Re-visiting already-drawn newer arrows next tick is cheap (the ObjectFind check).
   if(failed_oldest > 0 && failed_oldest - 1 < newest)
      newest = failed_oldest - 1;
   m_signal_arrows_last_time[wm_idx] = newest;
  }

#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
