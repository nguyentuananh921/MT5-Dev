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
 // Layer-3 observer: charts/windows/indicators state + CHART_OBJ_EVENT_* events (no WForms deps)
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
 // For CMessage::PlaySound/Out - per-indicator Sound/Message alerts (2026-07-17)
  #include <Vendors\Anhnt\Library\4. Combination Lib\Notify\Message\Message.mqh>
//  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\InputData\TradingInpData.mqh>
//  #include <Vendors\Anhnt\Library\4. Combination Lib\Trading\Accounts\Account.mqh>
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
 // Define GUI control
  // --- Main panel window m_window_main
    #define M_WINDOW_MAIN_WIDTH         750
    #define M_WINDOW_MAIN_HEIGHT        480
   //Left pannel m_treeview_SymbolTF (fixed left strip, visible on all tabs)   
    //#define SYMBOL_TREE_WIDTH         100
    #define M_TREEVIEW_SYMBOLTF_WIDTH   100
   //Right Pannel m_tabs_main starts at (TABS_MAIN_X, TABS_MAIN_Y) inside m_Mainwindow.
    // --- AutoXResizeRightOffset=3, so: TABS_WIDTH = PANEL_WIDTH - TABS_MAIN_X - 3.    
    #define M_TABS_MAIN_X               115
    #define M_TABS_MAIN_Y               43
    #define M_TABS_MAIN_WIDTH           (M_WINDOW_MAIN_WIDTH - M_TABS_MAIN_X - 3)
    enum ENUM_TAB_MAIN
     {
      TAB_TAB_MAIN_ACCOUNT_INFO = 0,
      TAB_TAB_MAIN_SYMBOL_INFO,
      TAB_TAB_MAIN_TRADE,
      TAB_TAB_MAIN_POSITIONS,
      TAB_TAB_MAIN_HISTORY,
      TAB_TAB_MAIN_SETTINGS,
      TAB_TAB_MAIN_EVENTS, //For Pattern Information      
      TAB_TAB_MAIN_TOTAL,
     };
     //m_tabs_main_setting_config      
      enum ENUM_TAB_MAIN_SETTINGS_CONFIG
       {
        TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR =0,
        TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF,    
        TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER,
        TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL,
       };
      enum ENUM_INDICATOR_SHOW_STATE
       {
        INDICATOR_SHOW_ON_CHART = CHECKBOX_STATE_ON,
        INDICATOR_HIDE_ON_CHART = CHECKBOX_STATE_OFF,
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
  //--------------------
  enum ENUM_CHECKBOX_STATE
   {
    CHECKBOX_STATE_ON  = 0,
    CHECKBOX_STATE_OFF = 1,
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
  
  
  
  // --- Nested m_tabs_main_setting_config header (its own tab row draws ABOVE its
  // --- canvas - offsetting its canvas down by the header height keeps that row
  // --- clear of m_tabs_main's own tab headers instead of overlapping them).
   #define TABS_CONFIG_HEADER_H      22
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
  // --- Symbol/TF setting table (Symbol TF sub-tab): note row on top, save button below it,
  // --- table below the button - same 10px gap convention as INDICATOR_TABLE_Y.
   #define SYMBOLTF_NOTE_H           20
   #define SYMBOLTF_BTN_Y            (SYMBOLTF_NOTE_H + 5)
   #define SYMBOLTF_TABLE_Y          (SYMBOLTF_BTN_Y + ADD_BTN_H + 10)
  // --- Positions tab: pre-trade-plan area above m_table_positions (Anhnt 2026-07-20).
  // --- Row 1 (y=POSITIONS_PLAN_Y): m_combo_pre_Trade_plan_symbol.
  // --- Row 2 (y=POSITIONS_PLAN_CONTROLS_Y): Distance mode+value, Lot mode+value - one
  // --- horizontal row per user request ("dàn hàng ngang").
  // --- Row 3 (y=POSITIONS_PLAN_TABLE_Y): m_table_pre_Trade_plan.
   #define POSITIONS_PLAN_Y             0
   #define POSITIONS_PLAN_CONTROLS_Y    25
   #define POSITIONS_PLAN_TABLE_Y       50
   #define POSITIONS_TABLE_Y            175
  // --- Candle info popup (BugNote 7.2): Ctrl+hover shows m_table_candle_information_atBar -
  // --- every tracked Indicator (current chart's symbol, every TF with a BarSeries) with its
  // --- Signal direction at the hovered bar. Fixed at the chart's top-right corner - content
  // --- only, no drag-to-follow-cursor (CWindow has no simple move-to-XY API, only manual
  // --- drag state).
   #define CANDLE_INFO_WINDOW_W      300
   #define CANDLE_INFO_WINDOW_H      220
   // --- Signal Markers bridge file header magic - MUST match SignalMarkers.mq5's own
   // --- SIGNAL_BRIDGE_MAGIC exactly (Indicators\Vendors\Anhnt\Custom Buildin\SignalMarkers.mq5).
   #define SIGNAL_BRIDGE_MAGIC       20260716
   // --- How far INSIDE the popup's near edge the cursor sits when it appears - NOT a gap.
   // --- BugNote 2026-07-16: a GAP between cursor and popup meant the mouse had to cross that
   // --- stretch of raw chart to reach it, and on a zoomed-out TF that stretch covers OTHER
   // --- candles, each flipping bar_time (and re-triggering RepositionCandleInfoWindow) along
   // --- the way - the popup kept jumping just out of reach. Placing the cursor already INSIDE
   // --- the popup's rect the instant it appears means MouseOverCandleInfoWindow() is true
   // --- before the user moves at all - zero distance left to cross.
   #define CANDLE_INFO_CURSOR_INSET  15

  //For Indicator table field show in m_table_indicator and m_table_indicator_SymbolTFValue
   #define INDICATOR_PARATEXT_WIDTH 180 //Include name + Icon
  class CGUIPannel : public CWndEvents
   {
    private: 
     //Layer 1 Pure Data
      // Private Pointer variables    
       CSymbolsCollection         *m_symbol_collection;                //CTradingEngine owns
       CBarTimeSeriesCollection   *m_BarTimeSeriesCollection;          //CBarTimeSeriesCollection owns      
       CBarPatternsControl        *m_pattern_cfg;                      // borrowed from EA
       CIndicatorsCollection      *m_IndicatorsCollection;             // CTimeSeriesEngine owns
       CTimeSeriesEngine          *m_time_series_engine;               // EA owns - Tang 1 entry point for AddIndicatorInstance
       CTickSeriesCollection      *m_tick_series;                      // Collection of tick series
      
       CIndicatorDE               *m_table_indicator_ptrs[];           // BORROWED per-row pointers - CIndicatorsCollection owns them; rebuilt on every SetValuesToIndicatorTable, so never delete through these
       //For Layer 2 Handling on m_table_indicator
        int                        m_pending_remove_row;                // row whose delete icon was clicked; executed in OnTimerEvent, NOT inside the click event - rebuilding the table while CTable is still processing its own click leaves its focus/press indices on freed rows (array out of range in Table.mqh)
        int                        m_pending_remove_row_symboltf;       // same deferred-delete pattern as m_pending_remove_row, for m_table_indicator_SymbolTFSeting
     //------------------- 
      CTimeCounter               m_gui_timecounter;                   //--- Time counters
      CKeys                      m_keys;                              //For Keyboard
     //For Layer 2 Gui Control
      //CPatternRenderer           *m_renderer;           //EA owns PatternRenderer for display New Patterns
      CTradingLevelBubble         m_trading_bubble;                    // OWNED - self-manages its own lazy-init via EnsureCreated()
      // GUI Control Elements
       CWindow                    m_window_main;
      //Control at m_window_main       
       //For CTreeView left pannel 
        CTreeView                 m_treeview_SymbolTF;
        int                       m_sym_tree_pos[];        //To save symbol node list_index
       // Main Tab on Right
        CTabs                      m_tabs_main;
        //for control at TAB_TAB_MAIN_TRADE
          CTable               m_table_indicator_SymbolTFValue;
        //For TAB_TAB_MAIN_POSITIONS - ported verbatim from V1 (Anatoli Kazharski\GUIPannel.mqh)
          CComboBox            m_combo_pre_Trade_plan_symbol;
          //--- Order-setup row, single horizontal line (Anhnt 2026-07-20): Distance mode toggle
          //--- + Distance value, Lot mode toggle + Lot-or-Risk% value (same edit box, meaning
          //--- switches with m_group_pre_trade_lot_mode - see SetValuesToPreTradePlanTable).
          CTextLabel           m_label_pre_trade_distance;
          CButtonsGroup        m_group_pre_trade_distance_mode;   // Fixed / ATR
          CTextEdit            m_edit_pre_trade_distance_pts;
          CTextLabel           m_label_pre_trade_lot;
          CButtonsGroup        m_group_pre_trade_lot_mode;        // By Distance (manual) / By Risk %
          CTextEdit            m_edit_pre_trade_lot_or_risk;
          CTable               m_table_pre_Trade_plan;
          CTable               m_table_positions;
          datetime             m_last_deal_time;   // IsLastDealTicket's own HistorySelect watermark
          ulong                m_last_deal_ticket;
        //For Control at TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR 
         CTabs                      m_tabs_main_setting_config;
         //For TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR at m_tabs_main_setting_config
          // Indicator TreeViews at the Left     
           CTreeView                 m_treeview_indicator;
           string                    m_table_indicator_names[];
           int                       m_group_tree_pos[];
           int                       m_type_node_li[];      // list_index của từng node Type (level 1)
           ENUM_INDICATOR            m_type_node_value[];   // ENUM_INDICATOR tương ứng         
          // For Indicator Add Form 
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
         //for TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF at m_tabs_main_setting_config
          CTable               m_table_indicator_SymbolTFSeting;
          CButton              m_btn_save_SymbolTF;
          CTextLabel           m_label_symboltf_note;   // "takes effect after EA restart" note
         //For TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER
          // --- 4 independent shapes (each needs its OWN MT5 plot - PLOT_ARROW is a per-plot
          // --- fixed property, not per-bar, so "Single" and "Multi" each need a Buy/Sell PAIR
          // --- of shapes, not one shared shape re-colored - see SignalMarkers.mq5).
           CComboBox            m_combo_shape_single_buy;
           CComboBox            m_combo_shape_single_sell;
           CComboBox            m_combo_shape_multi_buy;
           CComboBox            m_combo_shape_multi_sell;
          // --- 3 colors, independent of shape: Buy/Sell apply when a marker relates to this
          // --- chart's own current Symbol+TF; Non-Related is used otherwise. Picked from a
          // --- small fixed palette via ComboBox (CColorPicker is a fixed 348x266 full HSL/RGB
          // --- dialog, no compact variant - not worth it for 3 preset-style picks).
           CComboBox            m_combo_color_buy;
           CComboBox            m_combo_color_sell;
           CComboBox            m_combo_color_nonrelated;
           CButton              m_btn_save_marker_settings;
          // --- Other tab captions/previews - index 0-3 = shape rows (Single Buy/Sell, Multi
          // --- Buy/Sell), index 0-2 of the color arrays = Buy/Sell/Non-Related. Preview labels
          // --- render the ACTUAL Wingdings glyph (Font("Wingdings") + the raw char code) so the
          // --- user sees the real shape, not just a number; color previews reuse CColorButton's
          // --- own swatch rendering, just never wired to a click handler (display-only).
           CTextLabel           m_label_other_caption[10];
           CTextLabel           m_preview_shape[4];
           CColorButton         m_preview_color[3];
          // --- Current marker style/color state - loaded from Config_Setting.json's "markers" section at startup,
          // --- fed to SignalMarkers.mq5 as iCustom inputs, updated by the Save button above.
           int                  m_marker_single_buy_code;
           int                  m_marker_single_sell_code;
           int                  m_marker_multi_buy_code;
           int                  m_marker_multi_sell_code;
           color                m_marker_buy_color;
           color                m_marker_sell_color;
           color                m_marker_nonrelated_color;
          // --- Buy/Sell alert sound files (2026-07-17) - CFileNavigator's tree+content-list
          // --- popup turned out to have a real bug (splitter-drag state can get stuck, freezing
          // --- the popup) and was overkill for "pick one file from one known folder" anyway.
          // --- Simplified: m_marker_sound_folder is a user-editable path (relative to
          // --- MQL5\Files\, persisted in JSON so it's never "lost" if changed) that gets scanned
          // --- with plain FileFindFirst/FileFindNext into 2 comboboxes - no tree, no splitter,
          // --- nothing to freeze. m_marker_buy_sound_file/m_marker_sell_sound_file now store just
          // --- the FILENAME (not a full path) - portable if the folder itself ever moves, since
          // --- the folder is tracked separately. Actually playing these on a live Signal is a
          // --- separate, not-yet-wired step (per-indicator Sound checkbox in m_table_indicator
          // --- already exists as UI-only).
           string               m_marker_sound_folder;
           string               m_marker_buy_sound_file;
           string               m_marker_sell_sound_file;
           CTextEdit            m_edit_sound_folder;
           CButton              m_btn_refresh_sound_folder;
           CComboBox            m_combo_buy_sound;
           CComboBox            m_combo_sell_sound;
          // --- Closed-bar path (CheckIndicatorAlerts): per-template (type_key/params_key, NOT
          // --- per-row - row index isn't stable across a table rebuild) watermark of the newest
          // --- committed HistoryTime() already written to Signal_Log.csv, persisted to
          // --- Signal_Log_Watermark_<SYMBOL>_<TF>.json so a restart's SyncHistory backfill is
          // --- logged (catch-up) without ever re-writing rows already on disk. Loaded lazily,
          // --- once, on CheckIndicatorAlerts' first call.
           string               m_wm_type[];
           string               m_wm_params[];
           datetime             m_wm_time[];
           bool                 m_signal_log_watermarks_loaded;
          // --- Live-bar path (CheckIndicatorAlerts): per-row (m_table_indicator_ptrs index - fine
          // --- here, this array is transient/session-only, never persisted) last-seen
          // --- GetCurrentSignal() direction for the still-forming bar 0. A still-forming bar can
          // --- flip back and forth several times before it closes ("uốn lượn như rắn", Anhnt
          // --- 2026-07-17) - each real change fires Sound+Message+CSV immediately with
          // --- TimeCurrent(), unlike the closed-bar path which never sounds an alert (the chart
          // --- Marker already shows closed-bar flips visually - Sound/Message is only for
          // --- catching a live move before it commits).
           ENUM_SIGNAL_DIR      m_live_signal_last_seen[];
          // --- BBands-only (IND_BANDS): Live-bar-0 tracker for CSignalBollinger's 2 remaining
          // --- independent line histories (Upper/Lower - see ProcessBandLine/SignalBands.mqh
          // --- Layer 1). MidBand is NOT tracked here anymore (Anhnt, 2026-07-19): it was folded
          // --- into the primary signal itself (CSignalBollinger::ComputeAt IS the MidBand cross
          // --- now), so Mid's Live/Closed events already come from the generic
          // --- m_live_signal_last_seen / signal.HistoryDir() path below, with Sound included -
          // --- keeping a separate Mid tracker here would have double-fired every Mid cross.
          // --- Transient like the array above - only the LIVE side needs this; the Closed side
          // --- reads CSignalBollinger's own real persisted LineHistoryXxx() instead.
           ENUM_SIGNAL_DIR      m_upper_last_seen[];
           ENUM_SIGNAL_DIR      m_lower_last_seen[];
      //Information window at to display signal on chart
       CWindow                    m_window_candle_infomation;
       CTable                     m_table_candle_information_atBar;
       datetime                   m_candle_info_shown_bar;             // 0 = window currently hidden
      //For status Bar 
       CStatusBar                 m_status_bar;
      // For guard on GUI.
       bool                       m_gui_created;        // guard thay cho s_gui_ready trong EA 
     // --- Layer-3 observer (README: 3-layer sync). OWNED here. Watches every open chart's
       // --- windows + their indicators and emits CHART_OBJ_EVENT_CHART_WND_IND_ADD/DEL/CHANGE,
       // --- so Layer 2 keeps its "Show" column truthful even when the user adds/removes an
       // --- indicator BY HAND on the chart. Styling (colors) is out of scope by design - MT5
       // --- has no API to restyle an indicator instance that is already attached to a chart.
        CChartObjCollection       m_chart_obj_collection;
      
     // per-row dirty-check cache for Trade tab table
         string               m_trade_cache_val[];
         int                  m_trade_cache_sig_icon[];
         int                  m_trade_cache_dir_icon[];
         int                  m_trade_table_row_count;
         // Settings table col-4 "Show" dirty cache - parallel with m_table_indicator_ptrs
         int                  m_settings_cache_state[];

       // --- Signal Markers bridge (BugNote 2026-07-16): a separate SignalMarkers.mq5
       // --- indicator (DRAW_COLOR_ARROW buffers) renders the actual chart markers now -
       // --- this EA only feeds it via a small binary file, one per symbol, containing every
       // --- currently Buy/Sell-enabled indicator's flip history across every tracked TF of
       // --- the CURRENT chart's own symbol. Watermark is a single (symbol, newest-seen-flip)
       // --- pair, not an array, because this EA instance only ever cares about its own
       // --- chart's current ::Symbol() (switching symbol resets it - see BuildAndWriteSignalBridge).
        string                    m_signal_bridge_symbol;
        datetime                  m_signal_bridge_last_time;
       
      // SIndicatorCatalogItem now lives in Artyom Trishkin\IndicatorCatalog.mqh (Tang 1 metadata)      
       // --- Params tab controls (generic fixed-slot form, max 4 params/indicator)
            
    private: // Private methods
     //For GUI
       bool                            CreateGUIPannel(); 
     //--- Form
         int                           WindowIdx(CWindow &wnd);
         bool                          CreateMainWindow(const string text);
     // For candle info popup (BugNote 7.2: Ctrl+hover -> Signal direction per indicator at that bar)
         bool                          CreateWindowCandleInfo(void);
         bool                          RefreshCandleInfoWindow(const datetime bar_time);
         bool                          MouseOverCandleInfoWindow(void);
         void                          RepositionCandleInfoWindow(const int cursor_x, const int cursor_y);
         void                          ShowCandleInfoPopup(const int cursor_x, const int cursor_y);
         void                          HideCandleInfoPopup(void);
     // For Main Tab
         bool                          CreateTab_Main(const int x_gap, const int y_gap);
     // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS
         bool                          CreateTabSettingConfig(const int x_gap, const int y_gap);
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
         void                         DetachIndicatorFromChart(CIndicatorDE *indicator);
         void                         ImportForeignChartIndicators(void);
         void                         BuildTemplateMatchKey(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[], string &type_key, string &params_key);
         void                         ApplyLoadedIndicatorBuySell(void);
       //For Indicator Symbol TF Table m_table_indicator_SymbolTFValue
         bool                         CreateIndicatorSymbolTFTable(const int x, const int y);
         void                         SetValuesToIndicatorSymbolTFTable(void);
         string                       BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[]);
         void                         BuildAndWriteSignalBridge(void);
         bool                         TemplateBuySellFor(CIndicatorDE *ind, bool &buy, bool &sell);
         void                         WriteSignalBridgeFile(const datetime &row_time[], const int &row_tf[], const int &row_dir[], const int count);
         void                         ResetSignalBridge(void);
         void                         PurgeSignalArrowObjects(const string sym, const string tf_string);
       //For Pre-Trade-Plan area (TAB_TAB_MAIN_POSITIONS), sits above m_table_positions - symbol
       //picker + single-row order-setup table. Skeleton only (Anhnt 2026-07-20): Buy/Sell cells
       //are plain CELL_BUTTON placeholders, NOT wired to send real orders yet - that needs the
       //Distance(Fixed/ATR) and Lot(Manual/Risk%) mode toggles first (separate ButtonsGroup
       //controls, not declared yet) to actually compute a price/lot worth sending.
         bool                         CreatePreTradePlanSymbolCombo(const int x, const int y);
         bool                         CreatePreTradePlanControls(const int x, const int y);
         bool                         CreatePreTradePlanTable(const int x, const int y);
         bool                         SetValuesToPreTradePlanTable(bool force = false);
       //For Positions Table m_table_positions (TAB_TAB_MAIN_POSITIONS) - ported verbatim from V1,
       //raw ::PositionsTotal()/::PositionGetX() loops (not Layer 1's CMarketCollection) - temporary,
       //per user request to bring V1's table over as-is before any redesign.
         bool                         CreatePositionsTable(const int x_gap, const int y_gap);
         void                         InitializePositionsTable(void);
         bool                         SetValuesToPositionsTable(string &symbols_name[], bool force = false);
         bool                         IsLastDealTicket(void);
         int                          GetPositionsSymbols(string &symbols_name[]);
         double                       PositionAveragePrice(const string symbol);
         int                          PositionsTotal(const string symbol);
         double                       PositionsVolumeTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE);
         double                       PositionsFloatingProfitTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE);
       //For Symbol/TF Setting Table m_table_indicator_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
         bool                         CreateTableSymbolTFSetting(const int x, const int y);
         void                         PopulateTableSymbolTFSetting(void);
         bool                         HasTableSymbolTFSettingRow(const string sym, const string tf_text);
         void                         SetTableSymbolTFSettingRow(const int row, const string sym, const string tf_text);
         bool                         IsCurrentChartSymbolTFRow(const string sym, const string tf_text);
         void                         SyncTableSymbolTFSettingCurrentChartIcon(void);
         void                         ApplyLoadedSymbolTFSettings(void);
         void                         OnClickSaveSymbolTF(void);
         void                         SaveGUIConfigToJSON(void);
         void                         BuildSymbolTFBuySellArrays(string &symbols[], string &tfs[], bool &buys[], bool &sells[]);
         void                         OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col);
       //For TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER - marker shape/color settings for SignalMarkers.mq5
         bool                         CreateTabSettingConfig_Marker(const int x, const int y);
         bool                         CreateMarkerTabComboBox(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index);
         bool                         CreateMarkerTabCaption(const int row, const string text, const int x, const int y);
         bool                         CreateShapePreview(const int row, const int x, const int y, const int arrow_code);
         bool                         CreateColorPreview(const int row, const int x, const int y, const color clr);
         void                         UpdateShapePreview(const int row, const int arrow_code);
         void                         UpdateColorPreview(const int row, const color clr);
         void                         GetMarkerArrowCodeChoices(int &codes[], string &labels[]);
         void                         GetMarkerColorChoices(color &colors[], string &labels[]);
         void                         OnClickSaveMarkerSettings(void);
         void                         LoadMarkerSettings(void);
         void                         SaveMarkerSettings(void);
         bool                         JsonIntValue(const string content, const string key, int &value);
         bool                         JsonStringValue(const string content, const string key, string &value);
         void                         EnsureMarkerIndicatorAttached(void);
         void                         ReattachSignalMarkersIndicator(void);
         void                         RemoveMarkerIndicator(void);
       //For Buy/Sell alert sound file pickers (Marker tab) - plain combobox, folder scanned via FileFindFirst
         void                         ScanSoundFolder(string &files[]);
         void                         OnClickChangeSoundFolder(void);
       //Per-indicator Sound/Message opt-in (m_table_indicator col 5/6) - fires on a genuinely NEW Signal
         void                         CheckIndicatorAlerts(void);
         void                         WriteSignalLogRow(const string time_text, const string symbol, const string tf, const string indicator, const string direction, const string price_text, const string status, const string cross_text);
         datetime                     GetSignalLogWatermark(const string type_key, const string params_key);
         void                         SetSignalLogWatermark(const string type_key, const string params_key, const datetime t);
         void                         LoadSignalLogWatermarks(void);
         void                         SaveSignalLogWatermarksToFile(void);
       //BBands-only: one independent line's real persisted history (CSignalBollinger::LineXxx) -
       //Closed=log-only+own watermark, Live=Message+CSV (no Sound) - see CheckIndicatorAlerts
         void                         ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name, ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key, const string label, const string tf_text, const int digits);
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
       void                           OnTradeEvent(void);   // ported from V1 - refreshes m_table_positions on a genuinely new deal
       virtual void                   OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
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
      m_pending_remove_row_symboltf = -1;
      m_candle_info_shown_bar  = 0;
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
      // Snapshot every open chart (windows + indicators) once - Refresh() in OnTimerEvent
      // then diffs against this baseline and emits CHART_OBJ_EVENT_* on changes
      m_chart_obj_collection.CreateCollection();
      UpdateGUI(true);
      // --- Seed m_table_indicator's Buy/Sell checkboxes from indicators_config.json (same
      // --- pattern as ApplyLoadedSymbolTFSettings for m_table_indicator_SymbolTFSeting) - MUST
      // --- run after UpdateGUI() so m_table_indicator_ptrs[] is already built.
      ApplyLoadedIndicatorBuySell();
      // Startup reconcile: adopt any indicator the user attached while the EA was off.
      // MUST run AFTER UpdateGUI - m_IndicatorsCollection.TemplateExists() needs the collection
      // already populated; running before it re-imported
      // every JSON template as a duplicate (and AddIndicatorToList deleting those duplicates
      // was the source of the dangling-pointer crash in SignalsCollection).
       ImportForeignChartIndicators();
      // Debug helper (kept available, call disabled after the 4807 hunt closed): dump the
      // instance->handle map right after startup
      //m_time_series_engine.PrintIndicatorsInventory();
      // --- One-time retroactive purge (BugNote 2026-07-16, "2531 leftover Arrow objects after
      // --- Remove from chart"): cleans up legacy CreateSignalBuy/Sell/CreateThumbUp/Down
      // --- objects from sessions before OnDeinitEvent's own per-removal purge existed. Gated
      // --- so it only ever runs once per terminal, not once per chart/attach.
      if(!::GlobalVariableCheck("CombinationEA_SignalMarkersMigrated_v1"))
        {
         PurgeSignalArrowObjects(::Symbol(), EnumToString((ENUM_TIMEFRAMES)::Period()));
         ::GlobalVariableSet("CombinationEA_SignalMarkersMigrated_v1", 1);
        }
      EnsureMarkerIndicatorAttached();
    }
   else if(uninit_reason == REASON_CHARTCHANGE)
    {
      // No manual redraw here (2026-07-14) - MT5 already redraws the chart natively on
      // symbol/TF change, and CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE (OnEvent) does the
      // same content refresh moments later. Two ChartRedraw() calls back-to-back was
      // the m_window_main flicker on every TF switch.
      UpdateGUI(false);
      // --- No explicit bubble lazy-init call needed here (2026-07-14, BugNote "ChartChange
      // --- là mất") - CTradingLevelBubble now self-manages via EnsureCreated(), called from
      // --- its own OnPoll()/OnChartEvent() every time either is invoked, so the very next
      // --- OnEvent()/OnTimerEvent() call after this reinit already covers it.
      // --- Defensive re-check (cheap, idempotent) - the indicator itself already survives a
      // --- symbol/TF change on its own, this just covers the case where it got removed by hand.
      EnsureMarkerIndicatorAttached();
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
    // --- Trading bubble FIRST, before any other GUI Lib control gets a chance at this
    // --- event (2026-07-14, BugNote "khó di chuyển"/hard-to-drag): this used to be the
    // --- LAST thing forwarded in this function, so CHARTEVENT_MOUSE_MOVE during a drag
    // --- had to fall through every other branch below first. The bubble's own
    // --- OnChartEvent() already no-ops for event types it doesn't care about, and now also
    // --- self-manages its own lazy-init via EnsureCreated() (2026-07-14), so it's always
    // --- safe to forward every event to it regardless of whether it's created yet.
     m_trading_bubble.OnChartEvent(id, lparam, dparam, sparam);
    // --- Ctrl+hover candle info popup (BugNote 7.2, redesigned 2026-07-16). m_mouse is already
    // --- refreshed for this event by CWndEvents::InitChartEventsParams() before OnEvent() is
    // --- called, so X()/Y() here are current.
    //
    // --- Use case (Anhnt, 2026-07-16):
    //  1. Ctrl+hover a candle with NO signal at all -> popup does not appear.
    //  2. Ctrl+hover a candle WITH a signal -> popup appears; cursor is already inside its
    //     rect the instant it appears (CANDLE_INFO_CURSOR_INSET), zero distance to cross.
    //  3. Mouse moves further into the popup/table to drag the scrollbar - MouseOverCandle-
    //     InfoWindow() being true is the ONLY thing keeping it open past this point; Ctrl no
    //     longer matters once inside.
    //  4. Mouse leaves the popup's rect -> it hides and native dispatch reverts to m_window_main.
    //
    // --- ShowCandleInfoPopup()/HideCandleInfoPopup() also swap m_active_window_index so
    // --- CWndEvents::CheckElementsEvents() natively dispatches to the table (scrollbar
    // --- included) while shown - see those methods for why m_window_main going quiet during
    // --- that window isn't a real trade-off (mouse can't be on both at once).
     if(id == CHARTEVENT_MOUSE_MOVE)
      {
       bool popup_shown = (m_candle_info_shown_bar != 0);
       if(popup_shown && MouseOverCandleInfoWindow())
         {
          // --- Stay open, don't touch bar_time - let the table's native dispatch (now
          // --- routed to it via m_active_window_index) handle the scrollbar/clicks.
         }
       else if(m_keys.KeyCtrlState())
         {
          datetime t; double price; int sub_window;
          if(::ChartXYToTimePrice(m_chart_id, m_mouse.X(), m_mouse.Y(), sub_window, t, price))
            {
             string sym = ::Symbol();
             ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
             int shift = ::iBarShift(sym, tf, t, false);
             if(shift >= 0)
               {
                datetime bar_time = ::iTime(sym, tf, shift);
                if(bar_time != m_candle_info_shown_bar)
                  {
                   bool has_signal = RefreshCandleInfoWindow(bar_time);
                   if(has_signal)
                     {
                      m_candle_info_shown_bar = bar_time;
                      ShowCandleInfoPopup(m_mouse.X(), m_mouse.Y());
                     }
                   else if(popup_shown)
                     {
                      HideCandleInfoPopup();
                      m_candle_info_shown_bar = 0;
                     }
                  }
               }
            }
         }
        else if(popup_shown)
         {
          HideCandleInfoPopup();
          m_candle_info_shown_bar = 0;
         }
      }
    // --- Re-hide param slots after CTabs::ShowTabElements() shows them on tab switch.
    //     ShowTabElements() runs inside CTabs::OnEvent() (before our OnEvent is called),
    //     so by this point the slots are already visible — we undo that.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main.Id())
      {
       HideParamSlots();
       return;
      }
    // --- Same issue on the NESTED m_tabs_main_setting_config (Indicator/Symbol TF sub-tabs) -
    //     it's its own CTabs with its own ON_CLICK_TAB event, so switching between its 2 tabs
    //     runs its own ShowTabElements() -> Reset() cascade, which force-shows m_param_labels/
    //     m_param_edits/m_param_combo[] the same way the outer tab switch does.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_main_setting_config.Id())
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
    //Handle Save Symbol/TF config to JSON
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_SymbolTF.Id())
      {
         OnClickSaveSymbolTF();
         return;
      }
    //Handle Save marker style/color settings
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.Id())
      {
         OnClickSaveMarkerSettings();
         return;
      }
    //Handle "Refresh" next to the sound folder path - re-scans and re-populates both combos
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_refresh_sound_folder.Id())
      {
         OnClickChangeSoundFolder();
         return;
      }
    //Handle Other tab combo selection - live-updates the preview immediately (BEFORE Save),
    //so the user sees what they're about to pick, not just its number/name. Reads directly off
    //the just-clicked combo's own SelectedItemIndex() - m_marker_* only changes on Save.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM)
      {
       int codes[]; string shape_labels[];
       GetMarkerArrowCodeChoices(codes, shape_labels);
       int n_shapes = ArraySize(codes);
       color mcolors[]; string color_labels[];
       GetMarkerColorChoices(mcolors, color_labels);
       int n_colors = ArraySize(mcolors);

       if(lparam == m_combo_shape_single_buy.Id())
         {
          int sel = (int)m_combo_shape_single_buy.GetListViewPointer().SelectedItemIndex();
          if(sel >= 0 && sel < n_shapes) UpdateShapePreview(0, codes[sel]);
          return;
         }
       if(lparam == m_combo_shape_single_sell.Id())
         {
          int sel = (int)m_combo_shape_single_sell.GetListViewPointer().SelectedItemIndex();
          if(sel >= 0 && sel < n_shapes) UpdateShapePreview(1, codes[sel]);
          return;
         }
       if(lparam == m_combo_shape_multi_buy.Id())
         {
          int sel = (int)m_combo_shape_multi_buy.GetListViewPointer().SelectedItemIndex();
          if(sel >= 0 && sel < n_shapes) UpdateShapePreview(2, codes[sel]);
          return;
         }
       if(lparam == m_combo_shape_multi_sell.Id())
         {
          int sel = (int)m_combo_shape_multi_sell.GetListViewPointer().SelectedItemIndex();
          if(sel >= 0 && sel < n_shapes) UpdateShapePreview(3, codes[sel]);
          return;
         }
       if(lparam == m_combo_color_buy.Id())
         {
          int sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
          if(sel >= 0 && sel < n_colors) UpdateColorPreview(0, mcolors[sel]);
          return;
         }
       if(lparam == m_combo_color_sell.Id())
         {
          int sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
          if(sel >= 0 && sel < n_colors) UpdateColorPreview(1, mcolors[sel]);
          return;
         }
       if(lparam == m_combo_color_nonrelated.Id())
         {
          int sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
          if(sel >= 0 && sel < n_colors) UpdateColorPreview(2, mcolors[sel]);
          return;
         }
      }
    //Handle m_table_indicator_SymbolTFSeting event
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
        && lparam == m_table_indicator_SymbolTFSeting.Id())
      {
         string parts[];
         if(StringSplit(sparam, '_', parts) != 2) return;
         int col = (int)StringToInteger(parts[0]);
         int row = (int)StringToInteger(parts[1]);
         if(row < 0 || row >= (int)m_table_indicator_SymbolTFSeting.RowsTotal()) return;
         string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row); StringTrimLeft(sym);
         string tf  = m_table_indicator_SymbolTFSeting.GetValue(1, row); StringTrimLeft(tf);

         // --- Delete is DEFERRED to OnTimerEvent - same CTable crash reason as m_table_indicator's col 0.
         // --- col 0 on the current-chart's own row shows the "start" icon (IsCurrentChartSymbolTFRow) -
         // --- not deletable, ignore the click.
         if(col == 0 && !IsCurrentChartSymbolTFRow(sym, tf))
            m_pending_remove_row_symboltf = row;
         else if(col == 2 || col == 3)
            OnCheckTableSymbolTFSetting(sym, tf, row, col);
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
         PopulateTableSymbolTFSetting();   // additive-only: picks up any newly tracked Symbol+TF pair
         SyncTableSymbolTFSettingCurrentChartIcon();   // "current chart" row just moved
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
   }
  void CGUIPannel::OnTickEvent(void)
   {
      // --- Positions Table (TAB_TAB_MAIN_POSITIONS) - ported verbatim from V1, 2026-07-19:
      // --- row-count mismatch (new/closed symbol) forces a full rebuild; otherwise a plain
      // --- dirty-checked value refresh, same as V1's own OnTickEvent.
      bool redraw_needed = false;
      string pos_symbols_name[];
      int pos_symbols_total = GetPositionsSymbols(pos_symbols_name);
      int pos_rows_total = (int)m_table_positions.RowsTotal();
      if(pos_symbols_total > 0 && pos_symbols_total != pos_rows_total)
        {
         InitializePositionsTable();
         redraw_needed = true;
        }
      else if(pos_symbols_total > 0)
         redraw_needed = SetValuesToPositionsTable(pos_symbols_name);
      // --- Status Bar (Deposit Load/Profit/Server Time), only update+redraw when a value
      // --- actually changed - same call site/pattern as V1's OnTickEvent. Symbol Info table
      // --- updates that used to sit alongside this in V1 aren't ported yet (still an empty
      // --- shell in V7).
      if(UpdateStatusBar())
         redraw_needed = true;
      // --- Pre-trade-plan table (Anhnt 2026-07-20): Entry/SL live off Bid/Ask, dirty-checked
      // --- per-cell same as everywhere else in this file.
      if(SetValuesToPreTradePlanTable())
         redraw_needed = true;
      if(redraw_needed)
         ::ChartRedraw();
   }
  //+------------------------------------------------------------------+
  //| Deinit                                                           |
  //+------------------------------------------------------------------+
  void CGUIPannel::OnDeinitEvent(const int reason)
   {
      // --- CHARTCHANGE (TF/symbol switch on this SAME chart) must NOT touch
      // --- m_trading_bubble's chart-level properties (Anhnt, 2026-07-19): its own
      // --- OnDeinitEvent() restores CHART_SHOW_TRADE_LEVELS/CHART_SHIFT to MT5
      // --- defaults, which only gets undone again (back to the bubble's preferred
      // --- values) once EnsureCreated() next runs - and that's gated on HasAnyLevel(),
      // --- so with zero open positions right after a TF change, native trade-level
      // --- lines stay stuck ON indefinitely. The chart itself isn't going anywhere on
      // --- CHARTCHANGE, so there's nothing to restore - skip it, same as every other
      // --- teardown step below that already special-cases this reason.
      if(reason != REASON_CHARTCHANGE)
        {
         m_trading_bubble.OnDeinitEvent();
         CWndEvents::Destroy();
         // --- Legacy cleanup (BugNote 2026-07-16, "2531 leftover Arrow objects after Remove
         // --- from chart"): the OLD graphic-object drawing path (CreateSignalBuy/Sell/
         // --- CreateThumbUp/Down, now retired in favor of the SignalMarkers.mq5 indicator +
         // --- bridge file) never purged its own objects on final removal. Purge this chart's
         // --- own current (sym, tf) directly - the broader one-time sweep for OTHER (sym,tf)
         // --- combos this chart visited in past sessions lives in OnInitEvent instead (gated
         // --- by a GlobalVariable so it only ever runs once per terminal).
         PurgeSignalArrowObjects(::Symbol(), EnumToString((ENUM_TIMEFRAMES)::Period()));
         // --- ChartIndicatorAdd() makes SignalMarkers.mq5 an independent chart program - it
         // --- keeps running/drawing even after this EA is gone unless explicitly detached here.
         RemoveMarkerIndicator();
         ::ChartRedraw(m_chart_id);
        }
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
      //--- Deferred delete for m_table_indicator_SymbolTFSeting - GUI-only removal (no Tang 1
      //--- series is stopped yet, see PopulateTableSymbolTFSetting note)
      if(m_pending_remove_row_symboltf >= 0)
        {
         int remove_row = m_pending_remove_row_symboltf;
         m_pending_remove_row_symboltf = -1;
         if(remove_row < (int)m_table_indicator_SymbolTFSeting.RowsTotal())
           {
            // --- Drop the pair from indicators_config.json BEFORE the row disappears - live
            // --- Tang1 (BarSeriesDE/indicators/signals) keeps running this session (no Library
            // --- removal method yet); it just won't be recreated on the next EA attach/restart.
            string sym = m_table_indicator_SymbolTFSeting.GetValue(0, remove_row); StringTrimLeft(sym);
            string tf  = m_table_indicator_SymbolTFSeting.GetValue(1, remove_row); StringTrimLeft(tf);
            if(m_time_series_engine != NULL)
               m_time_series_engine.RemoveSymbolTFFromConfigJSON("Config_Setting.json", sym, tf);
            m_table_indicator_SymbolTFSeting.DeleteRow(remove_row, true);
           }
        }
      //--- Handling the elements

      ulong t0 = ::GetMicrosecondCount();

      CWndEvents::OnTimerEvent();

      ulong t1 = ::GetMicrosecondCount();

      // --- CTradingLevelBubble self-manages lazy-init via EnsureCreated(), called from the
      // --- top of its own OnPoll() (2026-07-14) - GUIPannel no longer needs to track whether
      // --- it's created or special-case the retry, just poll it unconditionally every tick.
      m_trading_bubble.OnPoll();

      SetValuesToIndicatorSymbolTFTable();
      BuildAndWriteSignalBridge();
      CheckIndicatorAlerts();
      //--- Layer-3 observer poll: diffs all open charts and broadcasts CHART_OBJ_EVENT_*
      //--- custom events (handled in OnEvent -> RefreshIndicatorTableShowStates)
      m_chart_obj_collection.Refresh();

      ulong t2 = ::GetMicrosecondCount();
      // if(t2 - t0 > 1000)
      //  Print("PERF CGUIPannel::OnTimerEvent CWndEvents::OnTimerEvent= ", t1 - t0, " us CTradingLevelBubble::OnPoll= ", t2 - t1, " us");
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
       if (!CreateWindowCandleInfo())
         {
            Print(__FUNCTION__, " > Failed to create candle info popup!");
            return (false);
         }
       if (!CreateStatusBar(1, 23))
         {
            Print(__FUNCTION__, " > Failed to create Status Bar!");
            return (false);
         }      
       if (!CreateTab_Main(M_TABS_MAIN_X, M_TABS_MAIN_Y))
         {
            //Print(__FUNCTION__, " > Failed to create Tabs1!");
            return (false);
         }
       if (!CreateTabSettingConfig(0, TABS_CONFIG_HEADER_H))
         {
            Print(__FUNCTION__, " > Failed to create Settings config tabs!");
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
       //For Symbol TF sub-tab at m_tabs_main_setting_config
        if(!CreateTableSymbolTFSetting(0, 22)) return false;
        PopulateTableSymbolTFSetting();
        ApplyLoadedSymbolTFSettings();   // seed Buy/Sell from indicators_config.json, once (see note)
       //For Other sub-tab at m_tabs_main_setting_config (marker shape/color settings)
        if(!CreateTabSettingConfig_Marker(0, 22)) return false;
       //For Trade Tab at m_tabs_main
        if(!CreateIndicatorSymbolTFTable(0, 0)) return false;
       //For Positions Tab at m_tabs_main - ported verbatim from V1 (2026-07-19)
       //--- Pre-trade-plan area (2026-07-20): symbol combo, then the Distance/Lot mode+value
       //--- controls in one horizontal row, then the order-setup table, m_table_positions
       //--- still shifted down to POSITIONS_TABLE_Y below all of it.
        if(!CreatePreTradePlanSymbolCombo(0, POSITIONS_PLAN_Y)) return false;
        if(!CreatePreTradePlanControls(0, POSITIONS_PLAN_CONTROLS_Y)) return false;
        if(!CreatePreTradePlanTable(0, POSITIONS_PLAN_TABLE_Y)) return false;
        if(!CreatePositionsTable(0, POSITIONS_TABLE_Y)) return false;
      // --- Trading bubble: just wire the mouse pointer now (cheap, no canvas yet) -
      // --- it lazily creates its own canvas via EnsureCreated(), called from its own
      // --- OnPoll()/OnChartEvent(), only once HasAnyLevel() is true (avoid creating a
      // --- full-screen canvas + hiding native SL/TP lines when there is nothing to show).
        m_trading_bubble.MousePointer(m_mouse);
        m_trading_bubble.SetChartObjCollection(GetPointer(m_chart_obj_collection));
      //m_tabs_main.ShowTabElements(); //Need verify
      CWndEvents::CompletedGUI();
      // --- Hide all slots ONLY AFTER CompletedGUI() - FormAvailableElementsArray() (called
      // --- inside CompletedGUI) registers only VISIBLE elements into m_available_elements[],
      // --- which CComboBox's click-open mechanism depends on. Hiding before CompletedGUI
      // --- would exclude them permanently even after Show() - confirmed by reading
      // --- FormAvailableElementsArray()'s IsVisible() filter.
      HideParamSlots();
      // --- Same reasoning as HideParamSlots above: hide only AFTER CompletedGUI so
      // --- FormAvailableElementsArray() still registers its labels as available.
      m_window_candle_infomation.Hide();

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
         m_window_main.XSize(M_WINDOW_MAIN_WIDTH);
         m_window_main.YSize(M_WINDOW_MAIN_HEIGHT);
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
  // For candle info popup (BugNote 7.2)
   //+------------------------------------------------------------------+
   //| True while the current mouse position is inside the candle info  |
   //| popup's own screen rect - used to suspend the Ctrl+hover bar      |
   //| re-derivation (see OnEvent) so scrolling/clicking the popup's own |
   //| table doesn't fight with it.                                     |
   //+------------------------------------------------------------------+
   bool CGUIPannel::MouseOverCandleInfoWindow(void)
    {
     int x = m_window_candle_infomation.X();
     int y = m_window_candle_infomation.Y();
     return(m_mouse.X() >= x && m_mouse.X() <= x + m_window_candle_infomation.XSize() &&
            m_mouse.Y() >= y && m_mouse.Y() <= y + m_window_candle_infomation.YSize());
    }
   //+------------------------------------------------------------------+
   //| Snaps the popup so the cursor is ALREADY inside it the instant it |
   //| appears (CANDLE_INFO_CURSOR_INSET, not a gap) - BugNote            |
   //| 2026-07-16: first tried placing the popup NEAR the cursor with a  |
   //| small gap, but on a zoomed-out TF that gap still covers OTHER      |
   //| candles - crossing it to reach the popup flipped bar_time (and    |
   //| re-triggered this same reposition) along the way, so the popup    |
   //| kept jumping just out of reach. Zero distance to cross means      |
   //| MouseOverCandleInfoWindow() is already true before any movement.  |
   //| CWindow has no "MainPointer" parent, so its own Moving(x,y)       |
   //| overload takes absolute coords directly - but it only updates    |
   //| m_canvas, not the base m_x/m_y CElementBase stores (confirmed by  |
   //| reading Window.mqh), so those must be set explicitly here or      |
   //| MouseOverCandleInfoWindow()/future calls would read stale coords. |
   //| The table needs NO manual repositioning: it was created via       |
   //| MainPointer(m_window_candle_infomation), so CElement::Moving()    |
   //| (its own, argument-less overload) re-derives its position from    |
   //| m_main.X()/Y() - i.e. the window's now-updated position - on its  |
   //| own.                                                              |
   //+------------------------------------------------------------------+
   void CGUIPannel::RepositionCandleInfoWindow(const int cursor_x, const int cursor_y)
    {
     int chart_w = (int)::ChartGetInteger(m_chart_id, CHART_WIDTH_IN_PIXELS);
     int chart_h = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);

     // --- Cursor sits INSET pixels inside the popup's LEFT edge (popup extends mostly to the
     // --- right of the cursor) - flip so cursor sits INSET pixels inside the RIGHT edge
     // --- instead if that would run off the chart's right edge (popup extends to the left).
     // --- Either way the cursor is ALREADY inside the rect - see CANDLE_INFO_CURSOR_INSET.
     int x = cursor_x - CANDLE_INFO_CURSOR_INSET;
     if(x + CANDLE_INFO_WINDOW_W > chart_w)
        x = cursor_x - CANDLE_INFO_WINDOW_W + CANDLE_INFO_CURSOR_INSET;
     if(x < 0) x = 0;

     // --- Same idea vertically - cursor INSET pixels inside the top edge, flipping to sit
     // --- inside the bottom edge if that would run off the chart's bottom.
     int y = cursor_y - CANDLE_INFO_CURSOR_INSET;
     if(y + CANDLE_INFO_WINDOW_H > chart_h)
        y = cursor_y - CANDLE_INFO_WINDOW_H + CANDLE_INFO_CURSOR_INSET;
     if(y < 0) y = 0;

     m_window_candle_infomation.X(x);
     m_window_candle_infomation.Y(y);
     m_window_candle_infomation.Moving(x, y);
     m_table_candle_information_atBar.Moving();
    }
   //+------------------------------------------------------------------+
   //| Shows the popup AND hands it native mouse/keyboard dispatch by    |
   //| making it the active window (BugNote 2026-07-16). CWndEvents::    |
   //| CheckElementsEvents() (WndEvents.mqh, protected - accessible from |
   //| this subclass, no Library edit needed) only ever routes           |
   //| CheckMouseFocus()/OnEvent() to m_active_window_index's elements,  |
   //| so without this the popup's table (its scrollbar included) never |
   //| receives a native event no matter how it's shown. m_window_main   |
   //| going quiet while this is active is not a real trade-off here:    |
   //| the ONLY thing that keeps this popup active is the cursor         |
   //| physically sitting inside it (see MouseOverCandleInfoWindow), so   |
   //| m_window_main can't be receiving meaningful mouse input at the    |
   //| same moment anyway. CWndEvents::Show(window_index) (also          |
   //| protected) cascades to m_main_elements - i.e. the table - on its   |
   //| own, so no manual table.Show() call is needed here either.        |
   //+------------------------------------------------------------------+
   void CGUIPannel::ShowCandleInfoPopup(const int cursor_x, const int cursor_y)
    {
     RepositionCandleInfoWindow(cursor_x, cursor_y);
     m_active_window_index = WindowIdx(m_window_candle_infomation);
     Show(m_active_window_index);
     FormAvailableElementsArray();
    }
   //+------------------------------------------------------------------+
   //| Hides the popup and hands native dispatch back to m_window_main.  |
   //+------------------------------------------------------------------+
   void CGUIPannel::HideCandleInfoPopup(void)
    {
     m_window_candle_infomation.Hide();
     m_table_candle_information_atBar.Hide();
     m_active_window_index = WindowIdx(m_window_main);
     FormAvailableElementsArray();
    }
   //+------------------------------------------------------------------+
   //| Creates the Ctrl+hover "Signal at this bar" popup - fixed at the |
   //| chart's top-right corner, content-only (no drag-to-follow-cursor;|
   //| CWindow has no simple move-to-XY API for that, only manual drag  |
   //| state gated behind IsMovable/mouse-button-held).                 |
   //+------------------------------------------------------------------+
   bool CGUIPannel::CreateWindowCandleInfo(void)
    {
      CWndContainer::AddWindow(m_window_candle_infomation);
      int chart_w = (int)::ChartGetInteger(m_chart_id, CHART_WIDTH_IN_PIXELS);
      int x = chart_w - CANDLE_INFO_WINDOW_W - 10;
      int y = 10;
      m_window_candle_infomation.XSize(CANDLE_INFO_WINDOW_W);
      m_window_candle_infomation.YSize(CANDLE_INFO_WINDOW_H);
      m_window_candle_infomation.FontSize(9);
      m_window_candle_infomation.IsMovable(false);
      m_window_candle_infomation.ResizeMode(false);
      m_window_candle_infomation.CloseButtonIsUsed(false);
      m_window_candle_infomation.CollapseButtonIsUsed(false);
      m_window_candle_infomation.TooltipsButtonIsUsed(false);
      m_window_candle_infomation.FullscreenButtonIsUsed(false);
      if(!m_window_candle_infomation.CreateWindow(m_chart_id, m_subwin, "Signals at Bar", x, y))
         return (false);

      // --- 3 cols: Time | Indicator (+ up/down signal icon) | TF. No Symbol column - this
      // --- popup is always scoped to the CURRENT chart's own symbol. Time is needed because
      // --- this popup spans EVERY tracked TF of the symbol, not just the hovered bar's own TF -
      // --- a lower-TF indicator can flip at a time inside the hovered bar's span without
      // --- landing exactly on its open time (see RefreshCandleInfoWindow).
      m_table_candle_information_atBar.MainPointer(m_window_candle_infomation);
      m_table_candle_information_atBar.AutoXResizeMode(true);
      m_table_candle_information_atBar.AutoXResizeRightOffset(3);
      m_table_candle_information_atBar.AutoYResizeMode(true);
      m_table_candle_information_atBar.AutoYResizeBottomOffset(3);
      m_table_candle_information_atBar.ShowHeaders(true);
      m_table_candle_information_atBar.SelectableRow(true);
      m_table_candle_information_atBar.LightsHover(true);
      m_table_candle_information_atBar.TableSize(3, 10);
      int widths[3]    = {55, 150, 45};
      int img_x_off[3] = {0, 3, 0};
      int img_y_off[3] = {0, 3, 0};
      int txt_x_off[3] = {5, 22, 5};
      ENUM_ALIGN_MODE al[3] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
      m_table_candle_information_atBar.ColumnsWidth(widths);
      m_table_candle_information_atBar.ImageXOffset(img_x_off);
      m_table_candle_information_atBar.ImageYOffset(img_y_off);
      m_table_candle_information_atBar.TextXOffset(txt_x_off);
      m_table_candle_information_atBar.TextAlign(al);

      // --- y=WINDOW_CAPTION_HEIGHT, not 0 - CWindow's child coordinate space starts at the
      // --- window's absolute top-left, INCLUDING the caption bar (same convention as every
      // --- other table placed directly on a CWindow, e.g. CreateTableSymbolTFSetting(0,22));
      // --- y=0 here made the table paint straight over the "Signals at Bar" title.
      if(!m_table_candle_information_atBar.CreateTable(0, WINDOW_CAPTION_HEIGHT)) return (false);
      m_table_candle_information_atBar.SetHeaderText(0, "Time");
      m_table_candle_information_atBar.SetHeaderText(1, "Indicator");
      m_table_candle_information_atBar.SetHeaderText(2, "TF");
      // --- Collapse the TableSize() padding down to a single blank baseline row, same
      // --- convention as CreateTableSymbolTFSetting.
      m_table_candle_information_atBar.DeleteAllRows();

      CWndContainer::AddToElementsArray(WindowIdx(m_window_candle_infomation), m_table_candle_information_atBar);
      return (true);
    }
   //+------------------------------------------------------------------+
   //| Fills the popup with every (Indicator, TF, Time) flip that lands |
   //| inside the hovered CURRENT-CHART bar's time SPAN [bar_time,      |
   //| bar_time + PeriodSeconds()) - not just flips on the hovered bar's |
   //| own TF. This popup spans EVERY TF tracked for the symbol, and a  |
   //| lower-TF indicator can flip at a time that falls inside the      |
   //| hovered bar's span without landing exactly on its open time, so  |
   //| each qualifying flip becomes its OWN row (same indicator can     |
   //| appear more than once if it flipped twice within the span).      |
   //| Unlike BuildAndWriteSignalBridge/m_table_indicator_SymbolTFValue  |
   //| show the PERSISTED state carried forward from the last flip),    |
   //| this popup answers "what flipped DURING this bar" - anything     |
   //| outside the span is left out entirely.                           |
   //|                                                                    |
   //| Returns true if the bar has at least one flip (i.e. the popup has |
   //| something to show) - false means "nothing happened at this bar",  |
   //| telling the caller NOT to show the popup for it at all.           |
   //+------------------------------------------------------------------+
   bool CGUIPannel::RefreshCandleInfoWindow(const datetime bar_time)
    {
      if(m_IndicatorsCollection == NULL || m_time_series_engine == NULL || m_BarTimeSeriesCollection == NULL)
         return false;

      datetime next_bar_time = bar_time + ::PeriodSeconds();

      string sym = ::Symbol();
      CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
      CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
      int series_total = (series_list != NULL) ? series_list.Total() : 0;

      // --- Sort this symbol's TFs ascending by IndexEnumTimeframe() (CommonDELib.mqh - M1..MN1
      // --- natural rank), same convention as CTimeSeriesEngine::SaveConfigurationToJSON.
      int order[];
      ArrayResize(order, series_total);
      for(int ti = 0; ti < series_total; ti++)
         order[ti] = ti;
      for(int a = 0; a < series_total - 1; a++)
         for(int b = a + 1; b < series_total; b++)
           {
            CBarSeriesDE *sa = series_list.At(order[a]);
            CBarSeriesDE *sb = series_list.At(order[b]);
            if(sa == NULL || sb == NULL) continue;
            if(IndexEnumTimeframe(sb.Timeframe()) < IndexEnumTimeframe(sa.Timeframe()))
              { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
           }

      // --- Collect (Indicator, TF text, Dir, Time) rows - one per flip whose time falls
      // --- inside [bar_time, next_bar_time). A signal with no flip in that span contributes
      // --- nothing at all (not even its carried-over state).
      CIndicatorDE   *row_ind[];
      string          row_tf[];
      ENUM_SIGNAL_DIR row_dir[];
      datetime        row_time[];
      int count = 0;
      for(int ti = 0; ti < series_total; ti++)
        {
         CBarSeriesDE *s = series_list.At(order[ti]);
         if(s == NULL) continue;
         string tf_text = TimeframeDescription(s.Timeframe());
         CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
         ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, s.Timeframe(), EQUAL);
         int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
         for(int ii = 0; ii < ind_total; ii++)
           {
            CIndicatorDE *ind = ind_list.At(ii);
            if(ind == NULL) continue;
            // signal is BORROWED - CSignalsCollection owns it
            CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
            if(signal == NULL) continue;
            // --- history is oldest->newest; walk backward and stop once we're before the span -
            // --- collect EVERY flip inside the span (usually 0 or 1, but never assume 1).
            for(int h = signal.HistoryTotal() - 1; h >= 0; h--)
              {
               datetime ht = signal.HistoryTime(h);
               if(ht >= next_bar_time) continue;
               if(ht < bar_time) break;

               ArrayResize(row_ind,  count + 1);
               ArrayResize(row_tf,   count + 1);
               ArrayResize(row_dir,  count + 1);
               ArrayResize(row_time, count + 1);
               row_ind[count]  = ind;
               row_tf[count]   = tf_text;
               row_dir[count]  = signal.HistoryDir(h);
               row_time[count] = ht;
               count++;
              }
            // --- BBands-only: also surface the Upper/Lower line-cross histories (Anhnt,
            // --- 2026-07-19) - same source BuildAndWriteSignalBridge now reads. Mid is
            // --- skipped here: it IS the primary signal now (CSignalBollinger::ComputeAt),
            // --- already collected by the generic signal.HistoryDir() loop just above -
            // --- including it here too would duplicate every Mid cross in this table.
            if(ind.TypeIndicator() == IND_BANDS)
              {
               CSignalBollinger *bb = (CSignalBollinger*)signal;
               for(int li = 0; li < 3; li++)
                 {
                  if(li == BBAND_LINE_MID) continue;
                  for(int h = bb.LineHistoryTotal(li) - 1; h >= 0; h--)
                    {
                     datetime ht = bb.LineHistoryTime(li, h);
                     if(ht >= next_bar_time) continue;
                     if(ht < bar_time) break;

                     ArrayResize(row_ind,  count + 1);
                     ArrayResize(row_tf,   count + 1);
                     ArrayResize(row_dir,  count + 1);
                     ArrayResize(row_time, count + 1);
                     row_ind[count]  = ind;
                     row_tf[count]   = tf_text;
                     row_dir[count]  = bb.LineHistoryDir(li, h);
                     row_time[count] = ht;
                     count++;
                    }
                 }
              }
           }
        }

      if(count == 0)
        {
         m_table_candle_information_atBar.DeleteAllRows();
         m_table_candle_information_atBar.Update(true);
         return false;
        }

      // --- Sort all collected rows ascending by time (stable-ish bubble sort - count is
      // --- small, same style as the TF order[] sort above).
      for(int a = 0; a < count - 1; a++)
         for(int b = a + 1; b < count; b++)
           if(row_time[b] < row_time[a])
             {
              CIndicatorDE   *ti_ = row_ind[a];  row_ind[a]  = row_ind[b];  row_ind[b]  = ti_;
              string          tf_ = row_tf[a];   row_tf[a]   = row_tf[b];   row_tf[b]   = tf_;
              ENUM_SIGNAL_DIR d_  = row_dir[a];  row_dir[a]  = row_dir[b];  row_dir[b]  = d_;
              datetime        tm_ = row_time[a]; row_time[a] = row_time[b]; row_time[b] = tm_;
             }

      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);
      uint dir_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};

      m_table_candle_information_atBar.DeleteAllRows();
      // --- redraw=true on the LAST row only - same black/smeared row-overflow reasoning as
      // --- RefreshIndicatorTable (README/BugNote 2026-07-14).
      for(int i = 0; i < count - 1; i++)
         m_table_candle_information_atBar.AddRow(i, i == count - 2);

      for(int row = 0; row < count; row++)
        {
         CIndicatorDE *ind = row_ind[row];
         int img_idx = (row_dir[row] == SIGNAL_BUY) ? 0 : 1; // row_dir is never SIGNAL_NONE here

         m_table_candle_information_atBar.SetImages(1, row, dir_img);
         m_table_candle_information_atBar.ChangeImage(1, row, img_idx);
         m_table_candle_information_atBar.SetValue(0, row, ::TimeToString(row_time[row], TIME_MINUTES));
         m_table_candle_information_atBar.SetValue(1, row, BuildIndicatorLabel(ind, catalog));
         m_table_candle_information_atBar.SetValue(2, row, row_tf[row]);
        }
      m_table_candle_information_atBar.Update(true);
      return true;
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
      string tabs_names[TAB_TAB_MAIN_TOTAL] = {"Account infor", "Symbol Info", "Trade", "Positions", "History", "Settings","Bar Events"};
      string texts[TAB_TAB_MAIN_TOTAL] = 
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
   // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS
   //+------------------------------------------------------------------+
   //| Create a nested tab group for Settings tab config sections       |
   //+------------------------------------------------------------------+
    bool CGUIPannel::CreateTabSettingConfig(const int x_gap, const int y_gap)
     {
      string tabs_names[TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL] = {"Indicator", "Symbol TF", "Marker"};
      //--- Store the pointer to the parent control - nested inside m_tabs_main's Settings tab
       m_tabs_main_setting_config.MainPointer(m_tabs_main);
      //--- Properties
       m_tabs_main_setting_config.IsCenterText(true);
       m_tabs_main_setting_config.PositionMode(TABS_TOP);
       m_tabs_main_setting_config.AutoXResizeMode(true);
       m_tabs_main_setting_config.AutoYResizeMode(true);
       m_tabs_main_setting_config.AutoXResizeRightOffset(3);
       m_tabs_main_setting_config.AutoYResizeBottomOffset(3);
      //--- Add tabs with the specified properties
       for(int i = 0; i < TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL; i++)
          m_tabs_main_setting_config.AddTab(tabs_names[i], 100);
      //--- Create Tab before create other control element inside
       if(!m_tabs_main_setting_config.CreateTabs(x_gap, y_gap))
          return (false);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_tabs_main_setting_config);
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_tabs_main_setting_config);
      return (true);
     }
    // For TreeView Indicator TabSetting at m_tabs_main
    bool CGUIPannel::CreateTreeView_Indicator(const int x_gap, const int y_gap)
     {
       m_treeview_indicator.MainPointer(m_tabs_main_setting_config);
       m_treeview_indicator.AutoXResizeMode(false);
       m_treeview_indicator.XSize(150);
       m_treeview_indicator.AutoYResizeMode(true);
       m_treeview_indicator.VisibleItemsTotal(15);
       m_treeview_indicator.LightsHover(true);
      //Create treeview
       if(!m_treeview_indicator.CreateTreeView(x_gap, y_gap)) return false;

       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_treeview_indicator);

       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_treeview_indicator);       
       return true;
     }
   //For m_table_indicator in TAB_TAB_MAIN_SETTINGS    
    // =====================================================================
    // --- Info tab: port of V4 m_table_indicator, same 5-column layout
    // =====================================================================
    bool CGUIPannel::CreateIndicatorTable(const int x, const int y)
     {
       m_table_indicator.MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_table_indicator);
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
       // --- 7 columns: col 0 merges the old icon-only "show on T3" column with the
       // --- "Indicator" text column (CTCell renders image+text independently, click
       // --- detection is scoped to the image's own pixel width - see Table.mqh
       // --- CheckPressedCheckBox/CheckPressedButton). Buy/Sell/Show/Sound/Message shift
       // --- down by 1. Sound/Message added 2026-07-17: per-template opt-in for a sound
       // --- alert + Journal message when that template gets a new Signal - wiring TBD,
       // --- this only adds the checkbox UI columns for now.
        m_table_indicator.TableSize(7, 20);
        int widths[7]    = {180, 70, 40, 40, 40, 40, 40};
        int img_x_off[7] = {3,   0,  10, 10, 10, 10, 10};
        int img_y_off[7] = {3,   0,  3,  3,  3,  3,  3};
        ENUM_ALIGN_MODE align[7] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
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
          m_table_indicator.SetHeaderText(5, "Sound");
          m_table_indicator.SetHeaderText(6, "Message");

       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator);
       return true;
     }
   //For m_table_indicator_SymbolTFSeting + m_btn_save_SymbolTF in TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF
    // =====================================================================
    // --- Symbol TF sub-tab: flat list of every Symbol+TF pair currently tracked by
    // --- m_BarTimeSeriesCollection (same source as m_treeview_SymbolTF), each row with
    // --- its own Buy/Sell checkboxes and a red delete icon. Save button writes the
    // --- current Buy/Sell state to JSON.
    // =====================================================================
    bool CGUIPannel::CreateTableSymbolTFSetting(const int x, const int y)
     {
      //--- Note (own row, on top): Delete/Buy/Sell edits here only take effect in
      //--- indicators_config.json - the running EA keeps today's live series/indicators
      //--- until it's restarted. Colored to stand out from the Save button below it.
       m_label_symboltf_note.MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_label_symboltf_note);
       // --- CTextLabel::InitializeProperties defaults XSize to 100px when unset - too narrow for
       // --- this sentence (and CTextLabel never checks AutoXResizeMode, unlike CTable/CTreeView),
       // --- so XSize must be set explicitly, wide enough to clear the tab's own right edge.
       m_label_symboltf_note.XSize(M_TABS_MAIN_WIDTH - x - 5);
       m_label_symboltf_note.Font("Calibri Bold");   // CElement::DrawText hardcodes FW_NORMAL - request a bold face by name instead
       if(!m_label_symboltf_note.CreateTextLabel("Delete Symbol+TF here apply after the EA is restarted", x, y)) return false;
       m_label_symboltf_note.LabelColor(clrDodgerBlue);
       m_label_symboltf_note.Draw();
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_symboltf_note);

      //--- Save button, same convention as m_btn_save_indicator
       m_btn_save_SymbolTF.MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_btn_save_SymbolTF);
       m_btn_save_SymbolTF.AutoXResizeMode(false);
       m_btn_save_SymbolTF.XSize(80);
       m_btn_save_SymbolTF.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
       if(!m_btn_save_SymbolTF.CreateButton("Save", x, y + SYMBOLTF_BTN_Y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_SymbolTF);

      //--- Table: col 0 merges the red delete icon with the Symbol label (same CTable
      //--- click-detection trick as m_table_indicator col 0 - see Table.mqh CheckPressedButton).
       m_table_indicator_SymbolTFSeting.MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_table_indicator_SymbolTFSeting);
       m_table_indicator_SymbolTFSeting.AutoXResizeMode(true);
       m_table_indicator_SymbolTFSeting.AutoXResizeRightOffset(3);
       m_table_indicator_SymbolTFSeting.AutoYResizeMode(true);
       m_table_indicator_SymbolTFSeting.AutoYResizeBottomOffset(3);
       m_table_indicator_SymbolTFSeting.ShowHeaders(true);
       m_table_indicator_SymbolTFSeting.SelectableRow(true);
       m_table_indicator_SymbolTFSeting.LightsHover(true);
       m_table_indicator_SymbolTFSeting.IsSortMode(true);
       m_table_indicator_SymbolTFSeting.TableSize(4, 10);
       int widths[4]    = {150, 70, 40, 40};
       int img_x_off[4] = {3,   0,  10, 10};
       int img_y_off[4] = {3,   0,  3,  3};
       ENUM_ALIGN_MODE align[4] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
       m_table_indicator_SymbolTFSeting.ColumnsWidth(widths);
       m_table_indicator_SymbolTFSeting.ImageXOffset(img_x_off);
       m_table_indicator_SymbolTFSeting.ImageYOffset(img_y_off);
       m_table_indicator_SymbolTFSeting.TextAlign(align);

       if(!m_table_indicator_SymbolTFSeting.CreateTable(x, y + SYMBOLTF_TABLE_Y)) return false;
       m_table_indicator_SymbolTFSeting.SetHeaderText(0, "Symbol");
       m_table_indicator_SymbolTFSeting.SetHeaderText(1, "TF");
       m_table_indicator_SymbolTFSeting.SetHeaderText(2, "Buy");
       m_table_indicator_SymbolTFSeting.SetHeaderText(3, "Sell");
      // --- Collapse the TableSize() padding down to a single blank baseline row -
      // --- PopulateTableSymbolTFSetting() reuses that one row for its very first entry.
       m_table_indicator_SymbolTFSeting.DeleteAllRows();

       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_SymbolTFSeting);
       return true;
     }
    // --- Incremental sync with m_treeview_SymbolTF's own data source (m_BarTimeSeriesCollection) -
    // --- called every time PopulateSymbolTFTree() runs (init + real symbol/TF change), same as the
    // --- treeview. Purely ADDITIVE: only appends pairs not already present as a row - never
    // --- DeleteAllRows()/rebuilds, so a user-deleted row stays deleted. Real "stop tracking" on
    // --- delete is follow-up work once the Library gets a RemoveSeries()-style API (BugNote/2026-07-15).
    void CGUIPannel::PopulateTableSymbolTFSetting(void)
     {
      if(m_BarTimeSeriesCollection == NULL) return;

      int mw_total = ::SymbolsTotal(true);
      for(int i = 0; i < mw_total; i++)
        {
         string sym_name = ::SymbolName(i, true);
         CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym_name);
         CArrayObj *list = (bts != NULL) ? bts.GetListSeries() : NULL;
         int tf_cnt = (list != NULL) ? list.Total() : 0;
         for(int k = 0; k < tf_cnt; k++)
           {
            CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
            if(s == NULL) continue;
            string tf_text = TimeframeDescription(s.Timeframe());
            if(HasTableSymbolTFSettingRow(sym_name, tf_text)) continue;

            int row = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
            string first_col0 = m_table_indicator_SymbolTFSeting.GetValue(0, 0);
            StringTrimLeft(first_col0);
            bool placeholder_only = (row == 1 && first_col0 == "");
            if(placeholder_only)
               row = 0;   // reuse the blank baseline row left by DeleteAllRows()
            else
               m_table_indicator_SymbolTFSeting.AddRow(row, false);
            SetTableSymbolTFSettingRow(row, sym_name, tf_text);
           }
        }
      m_table_indicator_SymbolTFSeting.Update(true);
     }
    // --- True when (sym, tf_text) already has a row (trimmed match against col0/col1 text)
    bool CGUIPannel::HasTableSymbolTFSettingRow(const string sym, const string tf_text)
     {
      int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
      for(int row = 0; row < rows; row++)
        {
         string s = m_table_indicator_SymbolTFSeting.GetValue(0, row);
         StringTrimLeft(s);
         if(s != sym) continue;
         string t = m_table_indicator_SymbolTFSeting.GetValue(1, row);
         StringTrimLeft(t);
         if(t == tf_text) return true;
        }
      return false;
     }
    // --- Called ONCE right after the initial PopulateTableSymbolTFSetting() (see CreateGUIPannel) -
    // --- pulls the Buy/Sell state CTimeSeriesEngine::LoadConfigurationFromJSON() cached while
    // --- loading indicators_config.json and applies it to the matching rows, so a saved Buy/Sell
    // --- setting survives an EA restart instead of resetting to OFF.
    void CGUIPannel::ApplyLoadedSymbolTFSettings(void)
     {
      if(m_time_series_engine == NULL) return;
      string symbols[], tfs[];
      bool buys[], sells[];
      m_time_series_engine.GetLoadedSymbolTFSettings(symbols, tfs, buys, sells);
      int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
      for(int i = 0; i < ArraySize(symbols); i++)
        {
         for(int row = 0; row < rows; row++)
           {
            string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
            StringTrimLeft(sym);
            if(sym != symbols[i]) continue;
            string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
            StringTrimLeft(tf);
            if(tf != tfs[i]) continue;
            m_table_indicator_SymbolTFSeting.ChangeImage(2, row, buys[i]  ? 0 : 1);
            m_table_indicator_SymbolTFSeting.ChangeImage(3, row, sells[i] ? 0 : 1);
            break;
           }
        }
      m_table_indicator_SymbolTFSeting.Update(true);
     }
    // --- True for the ONE row matching this chart's own symbol/TF - CTimeSeriesEngine::OnInitEvent
    // --- creates that series unconditionally and everything else (RefreshIndicatorTable,
    // --- BuildAndWriteSignalBridge...) assumes it always exists, so that row must never be deletable.
    bool CGUIPannel::IsCurrentChartSymbolTFRow(const string sym, const string tf_text)
     {
      return (sym == ::Symbol() && tf_text == TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
     }
    // --- Re-evaluates col 0's icon (delete vs start) for every row - called after a real
    // --- symbol/TF chart change, since which row counts as "current" just moved.
    void CGUIPannel::SyncTableSymbolTFSettingCurrentChartIcon(void)
     {
      uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
      uint start_icon[]  = {IMAGE_RESOURCE_BMP16_START_BMP};
      int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
      for(int row = 0; row < rows; row++)
        {
         string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
         StringTrimLeft(sym);
         if(sym == "") continue;
         string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
         StringTrimLeft(tf);
         if(IsCurrentChartSymbolTFRow(sym, tf))
            m_table_indicator_SymbolTFSeting.SetImages(0, row, start_icon);
         else
            m_table_indicator_SymbolTFSeting.SetImages(0, row, delete_icon);
         m_table_indicator_SymbolTFSeting.ChangeImage(0, row, 0);
        }
      m_table_indicator_SymbolTFSeting.Update(true);
     }
    // --- Fill every cell of one Symbol+TF row - Buy/Sell default OFF (opt-in, same convention
    // --- as m_table_indicator's col 2/3)
    void CGUIPannel::SetTableSymbolTFSettingRow(const int row, const string sym, const string tf_text)
     {
      uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
      uint start_icon[]  = {IMAGE_RESOURCE_BMP16_START_BMP};
      uint chk[]         = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};

      // --- Col 0: Symbol label + icon - red Close (delete), EXCEPT the row matching the current
      // --- chart's own symbol/TF, which gets the "start" icon and is not deletable (this EA
      // --- instance depends on that series existing - see IsCurrentChartSymbolTFRow).
       bool is_current = IsCurrentChartSymbolTFRow(sym, tf_text);
       m_table_indicator_SymbolTFSeting.CellType(0, row, CELL_BUTTON);
       if(is_current)
          m_table_indicator_SymbolTFSeting.SetImages(0, row, start_icon);
       else
          m_table_indicator_SymbolTFSeting.SetImages(0, row, delete_icon);
       m_table_indicator_SymbolTFSeting.ChangeImage(0, row, 0);
       m_table_indicator_SymbolTFSeting.SetValue(0, row, "        " + sym);
      // --- Col 1: TF
       m_table_indicator_SymbolTFSeting.SetValue(1, row, "  " + tf_text);
      // --- Col 2/3: Buy / Sell
       m_table_indicator_SymbolTFSeting.CellType(2, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFSeting.SetImages(2, row, chk);
       m_table_indicator_SymbolTFSeting.ChangeImage(2, row, 1);
       m_table_indicator_SymbolTFSeting.CellType(3, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFSeting.SetImages(3, row, chk);
       m_table_indicator_SymbolTFSeting.ChangeImage(3, row, 1);
     }
    // --- Save button click - both m_btn_save_indicator and m_btn_save_SymbolTF write the SAME
    // --- indicators_config.json (single source of truth, no separate Buy/Sell file) - see
    // --- SaveGUIConfigToJSON().
    void CGUIPannel::OnClickSaveSymbolTF(void)
     {
      SaveGUIConfigToJSON();
     }
    // --- Shared by OnClickSaveIndicators() and OnClickSaveSymbolTF(): builds the Buy/Sell
    // --- lookup arrays from m_table_indicator_SymbolTFSeting and hands them to
    // --- CTimeSeriesEngine::SaveConfigurationToJSON, which merges them into each "symbols_tf"
    // --- entry of indicators_config.json.
    void CGUIPannel::SaveGUIConfigToJSON(void)
     {
      if(m_time_series_engine == NULL) return;
      string symbols[], tfs[];
      bool buys[], sells[];
      BuildSymbolTFBuySellArrays(symbols, tfs, buys, sells);

      // --- Templates: m_table_indicator_ptrs[] IS the current chart's template list (one row
      // --- per template, RefreshIndicatorTable's own invariant) - read Buy/Sell/Sound/Message
      // --- straight off it (col 2/3/5/6 - col 4 "Show" is chart-local, not saved here).
      int tmpl_total = ArraySize(m_table_indicator_ptrs);
      CIndicatorDE *tmpl_ptrs[];
      bool tmpl_buy[], tmpl_sell[], tmpl_sound[], tmpl_message[];
      ArrayResize(tmpl_ptrs,    tmpl_total);
      ArrayResize(tmpl_buy,     tmpl_total);
      ArrayResize(tmpl_sell,    tmpl_total);
      ArrayResize(tmpl_sound,   tmpl_total);
      ArrayResize(tmpl_message, tmpl_total);
      for(int row = 0; row < tmpl_total; row++)
        {
         tmpl_ptrs[row]    = m_table_indicator_ptrs[row];
         tmpl_buy[row]     = ((int)m_table_indicator.SelectedImageIndex(2, row) == 0);
         tmpl_sell[row]    = ((int)m_table_indicator.SelectedImageIndex(3, row) == 0);
         tmpl_sound[row]   = ((int)m_table_indicator.SelectedImageIndex(5, row) == 0);
         tmpl_message[row] = ((int)m_table_indicator.SelectedImageIndex(6, row) == 0);
        }

      m_time_series_engine.SaveConfigurationToJSON("Config_Setting.json", symbols, tfs, buys, sells,
                                                    tmpl_ptrs, tmpl_buy, tmpl_sell, tmpl_sound, tmpl_message);
     }
    // --- Buy/Sell lookup arrays for SaveGUIConfigToJSON, read off m_table_indicator_SymbolTFSeting's
    // --- current checkbox state (col 2/3).
    void CGUIPannel::BuildSymbolTFBuySellArrays(string &symbols[], string &tfs[], bool &buys[], bool &sells[])
     {
      ArrayResize(symbols, 0);
      ArrayResize(tfs, 0);
      ArrayResize(buys, 0);
      ArrayResize(sells, 0);
      int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
      int total = 0;
      for(int row = 0; row < rows; row++)
        {
         string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
         StringTrimLeft(sym);
         if(sym == "") continue;
         string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
         StringTrimLeft(tf);
         ArrayResize(symbols, total + 1);
         ArrayResize(tfs, total + 1);
         ArrayResize(buys, total + 1);
         ArrayResize(sells, total + 1);
         symbols[total] = sym;
         tfs[total]     = tf;
         buys[total]    = (m_table_indicator_SymbolTFSeting.SelectedImageIndex(2, row) == 0);
         sells[total]   = (m_table_indicator_SymbolTFSeting.SelectedImageIndex(3, row) == 0);
         total++;
        }
     }
    // --- Checkbox click stub (col 2 = Buy, col 3 = Sell) - the table already auto-toggled the
    // --- icon before this event fires (see Table.mqh CheckPressedCheckBox), so no manual image
    // --- flip needed here. Intentionally empty for now - no Tang 1 trading data model exists
    // --- yet to apply this to (see PopulateTableSymbolTFSetting note); wire real behavior here
    // --- once that's decided.
    void CGUIPannel::OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col)
     {
     }
    // --- Fixed catalog of common Wingdings arrow codes offered in all 4 marker-shape combos.
    // --- 67/68 (Thumb Up/Down) restore the original OBJ_ARROW_THUMB_UP/DOWN look this popup
    // --- used before the DRAW_COLOR_ARROW redesign (Anhnt, 2026-07-17) - those were native
    // --- chart OBJECT types back then; now they're just Wingdings glyph codes like any other
    // --- shape choice here, rendered via the indicator's PLOT_ARROW, not a chart object.
    void CGUIPannel::GetMarkerArrowCodeChoices(int &codes[], string &labels[])
     {
      int    c[] = {233, 234, 67, 68, 108, 109, 159, 161, 162, 217, 218};
      string l[] = {"233 Arrow Up", "234 Arrow Down", "67 Thumb Up", "68 Thumb Down",
                    "108 Circle", "109 Circle Filled",
                    "159 Diamond", "161 Diamond Filled", "162 Star", "217 Chevron Up", "218 Chevron Down"};
      ArrayCopy(codes,  c);
      ArrayCopy(labels, l);
     }
    // --- Fixed color palette offered in all 3 marker-color combos - CColorPicker is a hard-
    // --- coded 348x266 full HSL/RGB/Lab dialog (ColorPicker.mqh:234-235, no compact variant),
    // --- not worth it for what's really just picking from a short list of common colors.
    void CGUIPannel::GetMarkerColorChoices(color &colors[], string &labels[])
     {
      color  c[] = {clrLime, clrGreen, clrDodgerBlue, clrOrange, clrYellow,
                    clrRed, clrCrimson, clrMagenta,
                    clrGray, clrSilver, clrWhite, clrBlack};
      string l[] = {"Lime", "Green", "Dodger Blue", "Orange", "Yellow",
                    "Red", "Crimson", "Magenta",
                    "Gray", "Silver", "White", "Black"};
      ArrayCopy(colors, c);
      ArrayCopy(labels, l);
     }
    // --- Shared recipe for every combobox on the Other tab (4 shape + 3 color) - same
    // --- creation/population steps as m_param_combo[]'s own recipe, just factored out since
    // --- 7 combos would otherwise repeat it verbatim.
    bool CGUIPannel::CreateMarkerTabComboBox(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index)
     {
      combo.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, combo);
      int n = ArraySize(labels);
      combo.XSize(combo_w);
      combo.YSize(20);
      combo.ItemsTotal(n);
      // --- Default dropdown viewport is only 93px (~5 rows) - with 11-12 choices that forces
      // --- a cramped scrollbar drag to reach the rest (Anhnt, 2026-07-17: "scrollbar khó kéo,
      // --- chọn không được"). Size the list to show every item at once so no scrolling is
      // --- ever needed - must be set BEFORE CreateComboBox() (CreateList() reads it once).
      // --- Capped at 300px (Anhnt, 2026-07-17: a real Sounds folder can have 30-40+ files -
      // --- letting the list grow to 18*n+4 uncapped ran the dropdown off the bottom of the
      // --- screen, making everything past the visible part unreachable). Small catalogs
      // --- (shape/color, 11-12 items = up to ~220px) still fit under the cap with no scrolling.
      int list_h = 18 * n + 4;
      if(list_h > 300) list_h = 300;
      combo.GetListViewPointer().YSize(list_h);
      combo.GetButtonPointer().XGap(1);
      combo.GetButtonPointer().XSize(combo_w);
      combo.GetButtonPointer().LabelYGap(4);
      combo.GetButtonPointer().IconYGap(3);
      if(!combo.CreateComboBox("", x, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), combo);

      combo.GetListViewPointer().Rebuilding(n);
      for(int i = 0; i < n; i++)
         combo.SetValue(i, labels[i]);
      combo.SelectItem(selected_index);
      combo.GetListViewPointer().Update(true);
      return true;
     }
    // --- Caption to the LEFT of a combo, e.g. "Single Buy:" - m_label_other_caption[row].
    bool CGUIPannel::CreateMarkerTabCaption(const int row, const string text, const int x, const int y)
     {
      m_label_other_caption[row].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_label_other_caption[row]);
      m_label_other_caption[row].XSize(140);
      if(!m_label_other_caption[row].CreateTextLabel(text, x, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_other_caption[row]);
      return true;
     }
    // --- Preview to the RIGHT of a shape combo - renders the ACTUAL Wingdings glyph (not just
    // --- its numeric code) so the user can see what the shape looks like before saving.
    bool CGUIPannel::CreateShapePreview(const int row, const int x, const int y, const int arrow_code)
     {
      m_preview_shape[row].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_preview_shape[row]);
      m_preview_shape[row].Font("Wingdings");
      m_preview_shape[row].FontSize(16);
      if(!m_preview_shape[row].CreateTextLabel(::ShortToString((ushort)arrow_code), x, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_preview_shape[row]);
      return true;
     }
    // --- Preview to the RIGHT of a color combo - reuses CColorButton's own swatch rendering
    // --- (CurrentColor() builds a small bordered color icon) purely for DISPLAY - never wired
    // --- to a click handler, so clicking it does nothing (no picker to open, see BugNote
    // --- 2026-07-17: CColorPicker dropped in favor of these fixed-palette combos).
    bool CGUIPannel::CreateColorPreview(const int row, const int x, const int y, const color clr)
     {
      m_preview_color[row].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_preview_color[row]);
      m_preview_color[row].CurrentColor(clr);
      if(!m_preview_color[row].CreateColorButton("", x, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_preview_color[row]);
      return true;
     }
    // --- Live-updates a shape preview as the user browses the combo, BEFORE clicking Save -
    // --- called from OnEvent's ON_CLICK_COMBOBOX_ITEM handling, not from OnClickSaveMarkerSettings
    // --- (which commits the choice to m_marker_* instead).
    void CGUIPannel::UpdateShapePreview(const int row, const int arrow_code)
     {
      m_preview_shape[row].LabelText(::ShortToString((ushort)arrow_code));
      m_preview_shape[row].Update(true);
     }
    void CGUIPannel::UpdateColorPreview(const int row, const color clr)
     {
      m_preview_color[row].CurrentColor(clr);
      m_preview_color[row].Update(true);
     }
    // --- "Marker" sub-tab (TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER): 4 independent shape choices
    // --- (Single Buy/Sell, Multi Buy/Sell - each needs its OWN plot/shape, see
    // --- SignalMarkers.mq5's header comment) and 3 independent color choices (Buy/Sell when a
    // --- marker relates to this chart's own Symbol+TF, Non-Related otherwise) - shape and
    // --- color are orthogonal axes (Anhnt, 2026-07-17).
    bool CGUIPannel::CreateTabSettingConfig_Marker(const int x, const int y)
     {
      LoadMarkerSettings(); // seed m_marker_* from Config_Setting.json's "markers" section before building defaults

      int codes[]; string shape_labels[];
      GetMarkerArrowCodeChoices(codes, shape_labels);
      color mcolors[]; string color_labels[];
      GetMarkerColorChoices(mcolors, color_labels);

      // --- Anhnt 2026-07-17: captions were sitting flush against the tab's left edge while
      // --- the combo/preview columns left a lot of empty space on the right - shift the
      // --- whole row layout right by 20px.
      const int base_x   = x + 20;
      int combo_w   = 160;
      int row_h     = 26;
      int combo_x   = base_x + 110;
      int preview_x = combo_x + combo_w + 10;

      int n_shapes = ArraySize(codes);
      int sel_single_buy = 0, sel_single_sell = 0, sel_multi_buy = 0, sel_multi_sell = 0;
      for(int i = 0; i < n_shapes; i++)
        {
         if(codes[i] == m_marker_single_buy_code)  sel_single_buy  = i;
         if(codes[i] == m_marker_single_sell_code) sel_single_sell = i;
         if(codes[i] == m_marker_multi_buy_code)   sel_multi_buy   = i;
         if(codes[i] == m_marker_multi_sell_code)  sel_multi_sell  = i;
        }

      string shape_captions[4] = {"Single Buy", "Single Sell", "Multi Buy", "Multi Sell"};
      int    shape_codes[4]    = {m_marker_single_buy_code, m_marker_single_sell_code, m_marker_multi_buy_code, m_marker_multi_sell_code};

      if(!CreateMarkerTabCaption(0, shape_captions[0], base_x, y))                                          return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_single_buy,  combo_x, y,             combo_w, shape_labels, sel_single_buy))  return false;
      if(!CreateShapePreview(0, preview_x, y, shape_codes[0]))                                             return false;

      if(!CreateMarkerTabCaption(1, shape_captions[1], base_x, y + row_h))                                   return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_single_sell, combo_x, y + row_h,     combo_w, shape_labels, sel_single_sell)) return false;
      if(!CreateShapePreview(1, preview_x, y + row_h, shape_codes[1]))                                     return false;

      if(!CreateMarkerTabCaption(2, shape_captions[2], base_x, y + row_h * 2))                               return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_multi_buy,   combo_x, y + row_h * 2, combo_w, shape_labels, sel_multi_buy))   return false;
      if(!CreateShapePreview(2, preview_x, y + row_h * 2, shape_codes[2]))                                 return false;

      if(!CreateMarkerTabCaption(3, shape_captions[3], base_x, y + row_h * 3))                               return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_multi_sell,  combo_x, y + row_h * 3, combo_w, shape_labels, sel_multi_sell))  return false;
      if(!CreateShapePreview(3, preview_x, y + row_h * 3, shape_codes[3]))                                 return false;

      int n_colors = ArraySize(mcolors);
      int sel_buy = 0, sel_sell = 0, sel_nonrelated = 0;
      for(int i = 0; i < n_colors; i++)
        {
         if(mcolors[i] == m_marker_buy_color)        sel_buy        = i;
         if(mcolors[i] == m_marker_sell_color)       sel_sell       = i;
         if(mcolors[i] == m_marker_nonrelated_color) sel_nonrelated = i;
        }

      int color_row0 = row_h * 4 + 10;

      if(!CreateMarkerTabCaption(4, "Buy Color", base_x, y + color_row0))                                        return false;
      if(!CreateMarkerTabComboBox(m_combo_color_buy,        combo_x, y + color_row0,           combo_w, color_labels, sel_buy))        return false;
      if(!CreateColorPreview(0, preview_x, y + color_row0, m_marker_buy_color))                                return false;

      if(!CreateMarkerTabCaption(5, "Sell Color", base_x, y + color_row0 + row_h))                               return false;
      if(!CreateMarkerTabComboBox(m_combo_color_sell,       combo_x, y + color_row0 + row_h,   combo_w, color_labels, sel_sell))       return false;
      if(!CreateColorPreview(1, preview_x, y + color_row0 + row_h, m_marker_sell_color))                       return false;

      if(!CreateMarkerTabCaption(6, "Non-Related Color", base_x, y + color_row0 + row_h * 2))                    return false;
      if(!CreateMarkerTabComboBox(m_combo_color_nonrelated, combo_x, y + color_row0 + row_h * 2, combo_w, color_labels, sel_nonrelated)) return false;
      if(!CreateColorPreview(2, preview_x, y + color_row0 + row_h * 2, m_marker_nonrelated_color))             return false;

      // --- Buy/Sell alert sound files (2026-07-17, simplified after CFileNavigator's splitter-
      // --- drag froze the popup): m_marker_sound_folder is a user-editable path relative to
      // --- MQL5\Files\ - persisted in JSON so it's never "lost" if changed. "Refresh" re-scans
      // --- it with plain FileFindFirst/FileFindNext and repopulates both comboboxes below -
      // --- no tree, no popup, nothing to freeze.
      int sound_row0 = color_row0 + row_h * 3 + 10;
      // --- Sound filenames (AUTO_TRADING_OFF_EN.wav etc.) run a lot longer than "233 Arrow Up"/
      // --- "Lime" - widen just this section's field so names aren't clipped, and the
      // --- Refresh/preview-x column lines up with the color swatches above (Anhnt, 2026-07-17).
      int sound_combo_w = preview_x + 60 - combo_x;

      if(!CreateMarkerTabCaption(7, "Sound Folder", base_x, y + sound_row0)) return false;
      m_edit_sound_folder.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_edit_sound_folder);
      m_edit_sound_folder.XSize(sound_combo_w);
      m_edit_sound_folder.GetTextBoxPointer().XGap(1);
      if(!m_edit_sound_folder.CreateTextEdit(m_marker_sound_folder, combo_x, y + sound_row0)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_sound_folder);

      m_btn_refresh_sound_folder.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_btn_refresh_sound_folder);
      m_btn_refresh_sound_folder.AutoXResizeMode(false);
      m_btn_refresh_sound_folder.XSize(80);
      if(!m_btn_refresh_sound_folder.CreateButton("Refresh", combo_x + sound_combo_w + 10, y + sound_row0)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_refresh_sound_folder);

      string files[];
      ScanSoundFolder(files);
      int n_files = ArraySize(files);
      int sel_buy_sound = 0, sel_sell_sound = 0;
      for(int i = 0; i < n_files; i++)
        {
         if(files[i] == m_marker_buy_sound_file)  sel_buy_sound  = i;
         if(files[i] == m_marker_sell_sound_file) sel_sell_sound = i;
        }

      if(!CreateMarkerTabCaption(8, "Buy Sound", base_x, y + sound_row0 + row_h)) return false;
      if(!CreateMarkerTabComboBox(m_combo_buy_sound, combo_x, y + sound_row0 + row_h, sound_combo_w, files, sel_buy_sound)) return false;

      if(!CreateMarkerTabCaption(9, "Sell Sound", base_x, y + sound_row0 + row_h * 2)) return false;
      if(!CreateMarkerTabComboBox(m_combo_sell_sound, combo_x, y + sound_row0 + row_h * 2, sound_combo_w, files, sel_sell_sound)) return false;

      m_btn_save_marker_settings.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_btn_save_marker_settings);
      m_btn_save_marker_settings.AutoXResizeMode(false);
      m_btn_save_marker_settings.XSize(80);
      m_btn_save_marker_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
      if(!m_btn_save_marker_settings.CreateButton("Save", base_x, y + sound_row0 + row_h * 3 + 10)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_marker_settings);

      return true;
     }
    // --- Reads all 7 combos, persists to Config_Setting.json's "markers" section, and hot-swaps the running
    // --- SignalMarkers.mq5 instance so the new look applies immediately.
    void CGUIPannel::OnClickSaveMarkerSettings(void)
     {
      int codes[]; string shape_labels[];
      GetMarkerArrowCodeChoices(codes, shape_labels);
      int n_shapes = ArraySize(codes);

      int sel;
      sel = (int)m_combo_shape_single_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_single_buy_code = codes[sel];
      sel = (int)m_combo_shape_single_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_single_sell_code = codes[sel];
      sel = (int)m_combo_shape_multi_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_multi_buy_code = codes[sel];
      sel = (int)m_combo_shape_multi_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_multi_sell_code = codes[sel];

      color mcolors[]; string color_labels[];
      GetMarkerColorChoices(mcolors, color_labels);
      int n_colors = ArraySize(mcolors);

      sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_buy_color = mcolors[sel];
      sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_sell_color = mcolors[sel];
      sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_nonrelated_color = mcolors[sel];

      m_marker_sound_folder = m_edit_sound_folder.GetValue();
      string sound_val = m_combo_buy_sound.GetValue();
      if(sound_val != "") m_marker_buy_sound_file = sound_val;
      sound_val = m_combo_sell_sound.GetValue();
      if(sound_val != "") m_marker_sell_sound_file = sound_val;

      SaveMarkerSettings();
      ReattachSignalMarkersIndicator();
     }
    // --- Loads the "markers" section of Config_Setting.json - the SAME single file
    // --- CTimeSeriesEngine::SaveConfigurationToJSON/LoadConfigurationFromJSON already use for
    // --- "symbols_tf"/"templates" (Anhnt, 2026-07-17: one file for everything, not scattered
    // --- across separate files). Always sets sane defaults first so a missing/partial file
    // --- (or a file that simply has no "markers" key yet) still leaves the EA in a working state.
    void CGUIPannel::LoadMarkerSettings(void)
     {
      m_marker_single_buy_code  = 233;
      m_marker_single_sell_code = 234;
      m_marker_multi_buy_code   = 67;
      m_marker_multi_sell_code  = 68;
      m_marker_buy_color        = clrLime;
      m_marker_sell_color       = clrRed;
      m_marker_nonrelated_color = clrGray;
      m_marker_buy_sound_file   = "";
      m_marker_sell_sound_file  = "";
      m_marker_sound_folder     = "Sounds";

      string content = IndicatorConfig_ReadWholeFile("Config_Setting.json");
      if(content == "") return;

      int v;
      if(JsonIntValue(content, "single_buy_arrow_code",  v)) m_marker_single_buy_code  = v;
      if(JsonIntValue(content, "single_sell_arrow_code", v)) m_marker_single_sell_code = v;
      if(JsonIntValue(content, "multi_buy_arrow_code",   v)) m_marker_multi_buy_code   = v;
      if(JsonIntValue(content, "multi_sell_arrow_code",  v)) m_marker_multi_sell_code  = v;
      if(JsonIntValue(content, "buy_color",        v)) m_marker_buy_color        = (color)v;
      if(JsonIntValue(content, "sell_color",       v)) m_marker_sell_color       = (color)v;
      if(JsonIntValue(content, "nonrelated_color", v)) m_marker_nonrelated_color = (color)v;
      string sv;
      if(JsonStringValue(content, "buy_sound_file",  sv)) m_marker_buy_sound_file  = sv;
      if(JsonStringValue(content, "sell_sound_file", sv)) m_marker_sell_sound_file = sv;
      if(JsonStringValue(content, "sound_folder",    sv)) m_marker_sound_folder    = sv;
     }
    // --- Rewrites Config_Setting.json with a fresh "markers" section, carrying "symbols_tf"/
    // --- "templates" through UNCHANGED (raw text, not re-parsed/re-built) via
    // --- IndicatorConfig_ExtractRawSection - this function only owns "markers", so it must
    // --- never destroy the OTHER sections CTimeSeriesEngine owns, symmetric with how that
    // --- engine's own writers now preserve "markers" when THEY rewrite this same file.
    void CGUIPannel::SaveMarkerSettings(void)
     {
      string existing   = IndicatorConfig_ReadWholeFile("Config_Setting.json");
      string symbols_tf = IndicatorConfig_ExtractRawSection(existing, "symbols_tf");
      string templates   = IndicatorConfig_ExtractRawSection(existing, "templates");

      string json = "{\n";
      if(symbols_tf != "") json += " \"symbols_tf\": " + symbols_tf + ",\n";
      if(templates  != "") json += " \"templates\": "  + templates  + ",\n";
      string buy_sound_esc  = m_marker_buy_sound_file;
      string sell_sound_esc = m_marker_sell_sound_file;
      string sound_folder_esc = m_marker_sound_folder;
      ::StringReplace(buy_sound_esc,  "\\", "\\\\");
      ::StringReplace(sell_sound_esc, "\\", "\\\\");
      ::StringReplace(sound_folder_esc, "\\", "\\\\");

      json += " \"markers\": { \"single_buy_arrow_code\": "  + (string)m_marker_single_buy_code +
              ", \"single_sell_arrow_code\": " + (string)m_marker_single_sell_code +
              ", \"multi_buy_arrow_code\": "   + (string)m_marker_multi_buy_code +
              ", \"multi_sell_arrow_code\": "  + (string)m_marker_multi_sell_code +
              ", \"buy_color\": "        + (string)(int)m_marker_buy_color +
              ", \"sell_color\": "       + (string)(int)m_marker_sell_color +
              ", \"nonrelated_color\": " + (string)(int)m_marker_nonrelated_color +
              ", \"buy_sound_file\": \""  + buy_sound_esc  + "\"" +
              ", \"sell_sound_file\": \"" + sell_sound_esc + "\"" +
              ", \"sound_folder\": \""    + sound_folder_esc + "\"" + " }\n}";

      int fh = ::FileOpen("Config_Setting.json", FILE_TXT|FILE_WRITE|FILE_ANSI);
      if(fh == INVALID_HANDLE) return;
      ::FileWriteString(fh, json);
      ::FileClose(fh);
     }
    // --- Minimal "find an int value after a JSON key" scan - Config_Setting.json's "markers" section is only ever
    // --- machine-written by SaveMarkerSettings() above, so a full JSON parser is unwarranted.
    bool CGUIPannel::JsonIntValue(const string content, const string key, int &value)
     {
      int pos = ::StringFind(content, "\"" + key + "\"");
      if(pos < 0) return false;
      int colon = ::StringFind(content, ":", pos);
      if(colon < 0) return false;
      int len = ::StringLen(content);
      int i = colon + 1;
      while(i < len && ::StringGetCharacter(content, i) == ' ') i++;
      int start = i;
      while(i < len)
        {
         ushort ch = ::StringGetCharacter(content, i);
         if((ch < '0' || ch > '9') && ch != '-') break;
         i++;
        }
      string num = ::StringSubstr(content, start, i - start);
      if(num == "") return false;
      value = (int)::StringToInteger(num);
      return true;
     }
    // --- Same idea as JsonIntValue but for a quoted string value - backslashes in Windows
    // --- paths are escaped ("\\") on write (SaveMarkerSettings) and un-escaped here on read.
    bool CGUIPannel::JsonStringValue(const string content, const string key, string &value)
     {
      int pos = ::StringFind(content, "\"" + key + "\"");
      if(pos < 0) return false;
      int colon = ::StringFind(content, ":", pos);
      if(colon < 0) return false;
      int q1 = ::StringFind(content, "\"", colon + 1);
      if(q1 < 0) return false;
      int q2 = ::StringFind(content, "\"", q1 + 1);
      if(q2 < 0) return false;
      value = ::StringSubstr(content, q1 + 1, q2 - q1 - 1);
      ::StringReplace(value, "\\\\", "\\");
      return true;
     }
    // --- Attaches SignalMarkers.mq5 to this chart if not already running (checked by short
    // --- name, set via IndicatorSetString(INDICATOR_SHORTNAME,...) in the indicator's own
    // --- OnInit) - idempotent, safe to call defensively on every OnInitEvent branch, same
    // --- style as CTradingLevelBubble::EnsureCreated() being polled unconditionally.
    void CGUIPannel::EnsureMarkerIndicatorAttached(void)
     {
      int total = ::ChartIndicatorsTotal(m_chart_id, 0);
      for(int i = 0; i < total; i++)
         if(::StringFind(::ChartIndicatorName(m_chart_id, 0, i), "SignalMarkers") == 0)
            return; // already attached

      int h = ::iCustom(NULL, 0, "Vendors\\Anhnt\\Custom Buildin\\SignalMarkers",
                         m_marker_single_buy_code, m_marker_single_sell_code,
                         m_marker_multi_buy_code, m_marker_multi_sell_code,
                         m_marker_buy_color, m_marker_sell_color, m_marker_nonrelated_color);
      if(h == INVALID_HANDLE)
        {
         ::Print(__FUNCTION__, " > iCustom(SignalMarkers) failed, error ", ::GetLastError());
         return;
        }
      if(!::ChartIndicatorAdd(m_chart_id, 0, h))
         ::Print(__FUNCTION__, " > ChartIndicatorAdd(SignalMarkers) failed, error ", ::GetLastError());
     }
    // --- Detaches SignalMarkers.mq5 if attached - ChartIndicatorAdd() makes it an independent
    // --- chart program, so removing THIS EA does NOT auto-detach it. Called from
    // --- ReattachSignalMarkersIndicator() (style change) AND from OnDeinitEvent on final removal.
    // --- BugNote 2026-07-18: "SignalMarkers survives Remove EA" - the old scan-by-
    // --- ChartIndicatorsTotal()/ChartIndicatorName() approach reads 0/garbage when called from
    // --- OnDeinit() while THIS chart's own program is mid-removal (confirmed empirically: the
    // --- native Indicators List dialog showed SignalMarkers very much still attached at the
    // --- exact moment our own scan reported total=0). SignalMarkers.mq5 sets its own short name
    // --- deterministically ("SignalMarkers(" + Symbol() + ")", see SignalMarkers.mq5 line ~102) -
    // --- delete by that known name directly instead of trusting the unreliable enumeration.
    // --- ChartIndicatorDelete() itself also reports a false/error return here (confirmed
    // --- error 4022) even though the deletion genuinely takes effect - another OnDeinit-timing
    // --- artifact, not a real failure, so the return value is intentionally not checked.
    void CGUIPannel::RemoveMarkerIndicator(void)
     {
      ::ChartIndicatorDelete(m_chart_id, 0, "SignalMarkers(" + ::Symbol() + ")");
     }
    // --- Detach + re-attach with the CURRENT m_marker_* values - MT5 has no live-input-update
    // --- API for a running indicator, so a style change means recreate it.
    void CGUIPannel::ReattachSignalMarkersIndicator(void)
     {
      RemoveMarkerIndicator();
      EnsureMarkerIndicatorAttached();
     }
    // --- Lists every FILE (not subfolder) directly inside MQL5\Files\<m_marker_sound_folder>\ -
    // --- plain FileFindFirst/FileFindNext, no tree/splitter/popup to freeze (2026-07-17,
    // --- replaces the CFileNavigator attempt after its splitter-drag state got stuck).
    void CGUIPannel::ScanSoundFolder(string &files[])
     {
      ::ArrayResize(files, 0);
      string folder = m_marker_sound_folder;
      if(folder == "") folder = "Sounds";
      string search_path = folder + "\\*.*";
      string name;
      long h = ::FileFindFirst(search_path, name);
      if(h == INVALID_HANDLE) return;
      do
        {
         // --- MQL5's FileFindFirst/Next marks folders with a TRAILING BACKSLASH in the
         // --- returned name (same convention CFileNavigator::IsFolder relies on) - skip those,
         // --- keep only actual files.
         if(::StringFind(name, "\\") < 0)
           {
            int n = ::ArraySize(files);
            ::ArrayResize(files, n + 1);
            files[n] = name;
           }
        }
      while(::FileFindNext(h, name));
      ::FileFindClose(h);
     }
    // --- "Refresh" button next to the sound-folder path: read the CURRENT text box value (the
    // --- user may have just typed a new folder), re-scan it, and rebuild both combos in place.
    void CGUIPannel::OnClickChangeSoundFolder(void)
     {
      m_marker_sound_folder = m_edit_sound_folder.GetValue();

      string files[];
      ScanSoundFolder(files);
      int n_files = ArraySize(files);

      // --- Rebuilding() only replaces the ITEM CONTENT - it does NOT resize the dropdown's own
      // --- viewport (that's a one-time YSize() read at CreateComboBox() time, same trap as
      // --- CreateMarkerTabComboBox's own comment) - without redoing it here, a folder that grows
      // --- from a handful of files to 61 keeps the OLD tiny viewport, squeezing the scrollbar
      // --- thumb down to almost nothing (Anhnt, 2026-07-17: exactly this happened on Refresh).
      int list_h = 18 * n_files + 4;
      if(list_h > 300) list_h = 300;
      m_combo_buy_sound.GetListViewPointer().YSize(list_h);
      m_combo_sell_sound.GetListViewPointer().YSize(list_h);

      m_combo_buy_sound.GetListViewPointer().Rebuilding(n_files);
      m_combo_sell_sound.GetListViewPointer().Rebuilding(n_files);
      for(int i = 0; i < n_files; i++)
        {
         m_combo_buy_sound.SetValue(i, files[i]);
         m_combo_sell_sound.SetValue(i, files[i]);
        }
      m_combo_buy_sound.SelectItem(0);
      m_combo_sell_sound.SelectItem(0);
      m_combo_buy_sound.GetListViewPointer().Update(true);
      m_combo_sell_sound.GetListViewPointer().Update(true);
     }
    // --- Two independent paths (Anhnt, 2026-07-17 design discussion):
    // --- CLOSED bar (HistoryTime/HistoryDir): never Sound/Message - the chart Marker already
    // --- shows these visually. Only appended to Signal_Log.csv (status "Closed"), gated by a
    // --- per-template watermark (m_wm_*, persisted to Signal_Log_Watermark_<SYMBOL>_<TF>.json)
    // --- so a restart's SyncHistory backfill catches up the CSV without ever duplicating a row
    // --- already on disk, and without ever making noise for old history.
    // --- LIVE bar 0 (GetCurrentSignal): the still-forming bar can flip back and forth several
    // --- times before it closes - each REAL change (vs m_live_signal_last_seen[row]) fires
    // --- Sound+Message+CSV (status "Live") immediately with TimeCurrent(), since there's no
    // --- fixed bar time yet. Runs every OnTimerEvent tick - cheap, no file I/O unless something
    // --- actually changed.
    void CGUIPannel::CheckIndicatorAlerts(void)
     {
      if(m_time_series_engine == NULL) return;
      int rows = ArraySize(m_table_indicator_ptrs);
      if(rows == 0) return;

      if(!m_signal_log_watermarks_loaded)
        {
         LoadSignalLogWatermarks();
         m_signal_log_watermarks_loaded = true;
        }

      int prev_size = ArraySize(m_live_signal_last_seen);
      bool seeding = (prev_size != rows); // new rows just appeared - seed their baseline, don't fire
      if(seeding)
        {
         ArrayResize(m_live_signal_last_seen, rows);
         ArrayResize(m_upper_last_seen, rows);
         ArrayResize(m_lower_last_seen, rows);
        }

      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);

      for(int row = 0; row < rows; row++)
        {
         CIndicatorDE *ind = m_table_indicator_ptrs[row];
         if(ind == NULL) continue;
         CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(signal == NULL) continue;

         bool sound_on   = ((int)m_table_indicator.SelectedImageIndex(5, row) == 0);
         bool message_on = ((int)m_table_indicator.SelectedImageIndex(6, row) == 0);
         if(!sound_on && !message_on) continue;

         string label   = BuildIndicatorLabel(ind, catalog);
         string tf_text = TimeframeDescription(ind.Timeframe());
         int digits = (int)::SymbolInfoInteger(ind.Symbol(), SYMBOL_DIGITS);
         string type_key, params_key;
         BuildTemplateMatchKey(ind, catalog, type_key, params_key);

         //--- BBands-only: Upper/Lower lines, each backed by CSignalBollinger's OWN real
         //--- persisted history (Layer 1) - safe downcast, ind.TypeIndicator()==IND_BANDS
         //--- already confirms `signal` really is a CSignalBollinger instance. Mid is NOT
         //--- processed here (Anhnt, 2026-07-19): it's now the primary signal itself (see
         //--- CSignalBollinger::ComputeAt), handled by the generic closed-bar/live-bar block
         //--- below like any other indicator - processing it here too would double-fire it.
         if(message_on && ind.TypeIndicator() == IND_BANDS)
           {
            CSignalBollinger *bb = (CSignalBollinger*)signal;
            ProcessBandLine(row, bb, BBAND_LINE_UPPER, "Upper", m_upper_last_seen, seeding, type_key, params_key, label, tf_text, digits);
            ProcessBandLine(row, bb, BBAND_LINE_LOWER, "Lower", m_lower_last_seen, seeding, type_key, params_key, label, tf_text, digits);
           }

         //--- Closed-bar path: log-only catch-up of every committed flip newer than the
         //--- persisted per-template watermark - never Sound/Message.
         datetime wm = GetSignalLogWatermark(type_key, params_key);
         int total = signal.HistoryTotal();
         datetime newest_committed = wm;
         for(int idx = 0; idx < total; idx++)
           {
            datetime t = signal.HistoryTime(idx);
            if(t <= wm) continue;
            ENUM_SIGNAL_DIR hdir = signal.HistoryDir(idx);
            string dir_text = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
            // --- BBands' own primary signal IS the MidBand cross now (Anhnt, 2026-07-19) -
            // --- name it explicitly so this row can't be confused with the Upper/Lower
            // --- line-cross rows (ProcessBandLine, below) which use the same "Buy"/"Sell" text.
            string cross_text = (ind.TypeIndicator() == IND_BANDS)
                                 ? ((hdir == SIGNAL_BUY) ? "Cross Up MidBand" : "Cross Down MidBand") : "";
            string time_text = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
            // --- Bar already closed - look up ITS OWN Close, not the current live price
            // --- (Anhnt, 2026-07-17): map flip_time back to a shift via iBarShift.
            int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
            double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
            string price_text = ::DoubleToString(price, digits);
            WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Closed", cross_text);
            if(t > newest_committed) newest_committed = t;
           }
         if(newest_committed > wm)
            SetSignalLogWatermark(type_key, params_key, newest_committed);

         //--- Live bar-0 path: fire Sound+Message+CSV on every real direction change.
         ENUM_SIGNAL_DIR live_dir = signal.GetCurrentSignal();
         if(seeding)
           {
            // --- Upper/Lower baselines already seeded by ProcessBandLine above; Mid is this
            // --- very signal (see CSignalBollinger::ComputeAt), seeded right here.
            m_live_signal_last_seen[row] = live_dir; // baseline only, never fires on first sight
            continue;
           }
         if(live_dir == m_live_signal_last_seen[row]) continue;
         m_live_signal_last_seen[row] = live_dir;
         if(live_dir == SIGNAL_NONE) continue; // dropped to no-signal - not alert-worthy itself

         bool is_buy = (live_dir == SIGNAL_BUY);
         if(sound_on)
           {
            // --- Deliberately native ::PlaySound(), NOT CMessage::PlaySound() (Anhnt,
            // --- 2026-07-17 - confirmed by reading Message.mqh): that wrapper unconditionally
            // --- prepends "\Files\" to any filename that isn't one of its own built-in SND_*
            // --- constants, no matter what we pass it - so it can NEVER reach a file sitting in
            // --- MQL5\Sounds\ (only MQL5\Files\...\ - a different sandbox from FileFindFirst/
            // --- FileOpen, which only reach MQL5\Files\ - see the Sound-picker combobox's own
            // --- ScanSoundFolder). The chosen .wav needs to physically exist in MQL5\Sounds\
            // --- (copied once, not auto-synced) - native ::PlaySound(bare filename) resolves
            // --- against that folder directly, with no wrapper in the way.
             string file = is_buy ? m_marker_buy_sound_file : m_marker_sell_sound_file;
             if(file != "")
                ::PlaySound(file);
           }
         if(message_on)
           {
            // --- Field order Time;Live/Closed;TF;Indicator;Signal (Anhnt, 2026-07-17) - ";"
            // --- delimited so pasting Journal lines straight into Excel auto-splits into columns,
            // --- same convention as Signal_Log.csv's own sep=; fix. Closed bars never reach this
            // --- branch at all (log-only, see the loop above) - every message printed here IS a
            // --- Live bar-0 event, hence the literal "Live" in the 2nd field.
             string dir_text  = is_buy ? "Buy" : "Sell";
            // --- Same MidBand naming as the closed-bar loop above (Anhnt, 2026-07-19).
             string cross_text = (ind.TypeIndicator() == IND_BANDS)
                                  ? (is_buy ? "Cross Up MidBand" : "Cross Down MidBand") : "";
             string time_text = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
            // --- Bar 0 hasn't closed yet - treat the CURRENT price as its "Close" (Anhnt, 2026-07-17).
             double price = ::iClose(ind.Symbol(), ind.Timeframe(), 0);
             string price_text = ::DoubleToString(price, digits);
             CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + (cross_text != "" ? ";" + cross_text : ""));
             WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Live", cross_text);
           }
        }
     }
    // --- BBands-only (Anhnt, 2026-07-17): processes ONE line's REAL persisted history from
    // --- CSignalBollinger (Layer 1) - Closed-bar catch-up mirrors the primary signal's own loop
    // --- exactly (log-only, watermark keyed by params_key+"|"+line_name so it never collides
    // --- with the primary signal's own watermark entry), then a Live-bar check (transient
    // --- last_seen[] vs LineCurrentSignal()) fires Message+CSV (deliberately no Sound, matching
    // --- the earlier scoped-down decision) on every real change.
    void CGUIPannel::ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name, ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key, const string label, const string tf_text, const int digits)
     {
      CIndicatorDE *ind = bb.GetIndicator();
      if(ind == NULL) return;
      string line_params_key = params_key + "|" + line_name;

      datetime wm = GetSignalLogWatermark(type_key, line_params_key);
      int total = bb.LineHistoryTotal(line_idx);
      datetime newest_committed = wm;
      for(int idx = 0; idx < total; idx++)
        {
         datetime t = bb.LineHistoryTime(line_idx, idx);
         if(t <= wm) continue;
         ENUM_SIGNAL_DIR hdir = bb.LineHistoryDir(line_idx, idx);
         string dir_text   = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
         string cross_text = (hdir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
         string time_text  = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
         int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
         double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
         string price_text = ::DoubleToString(price, digits);
         WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Closed", cross_text);
         if(t > newest_committed) newest_committed = t;
        }
      if(newest_committed > wm)
         SetSignalLogWatermark(type_key, line_params_key, newest_committed);

      ENUM_SIGNAL_DIR live_dir = bb.LineCurrentSignal(line_idx);
      if(seeding)
        {
         last_seen[row] = live_dir; // baseline only, never fires on first sight
         return;
        }
      if(live_dir == last_seen[row]) return; // no change
      last_seen[row] = live_dir;
      if(live_dir == SIGNAL_NONE) return; // dropped to exactly-on-the-line - not report-worthy itself

      // --- Same Time;Live;TF;Indicator;Signal shape as the primary message, plus a 6th
      // --- ";"-delimited field naming which line/direction triggered it (Anhnt, 2026-07-17:
      // --- "viết ra Journal như nào thì cũng viết ra Signal_Log.csv y như thế").
      string dir_text   = (live_dir == SIGNAL_BUY) ? "Buy" : "Sell";
      string cross_text = (live_dir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
      string time_text  = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
      double price = ::iClose(ind.Symbol(), ind.Timeframe(), 0);
      string price_text = ::DoubleToString(price, digits);
      CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
      WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Live", cross_text);
     }
    // --- Appends one row to MQL5\Files\Signal_Log.csv (Excel-openable) - writes a leading
    // --- "sep=;" line + header once, the very first time the file is empty/new, then appends
    // --- after that. Delimiter is ';' (not ',') and the sep= line forces Excel to honor it
    // --- regardless of the machine's own Regional Settings list separator (Anhnt, 2026-07-17 -
    // --- opening the ','-delimited file directly in Excel dumped every field into one column).
    // --- Opened with FILE_READ|FILE_WRITE (not bare FILE_WRITE, which truncates on every open)
    // --- so existing history is never lost between EA restarts. cross_text is "" for every
    // --- non-BBands signal row; BBands rows always populate it - "Cross Up/Down MidBand" from
    // --- the primary signal itself, or "Cross Up/Down Upper/LowerBand" from ProcessBandLine
    // --- (Anhnt, 2026-07-19).
    void CGUIPannel::WriteSignalLogRow(const string time_text, const string symbol, const string tf, const string indicator, const string direction, const string price_text, const string status, const string cross_text)
     {
      int fh = ::FileOpen("Signal_Log.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
      if(fh == INVALID_HANDLE) return;
      bool is_new = (::FileSize(fh) == 0);
      if(is_new)
        {
         ::FileWriteString(fh, "sep=;\n");
         ::FileWrite(fh, "Time", "Symbol", "TF", "Indicator", "Signal", "Price", "Status", "Cross");
        }
      else
         ::FileSeek(fh, 0, SEEK_END);
      ::FileWrite(fh, time_text, symbol, tf, indicator, direction, price_text, status, cross_text);
      ::FileClose(fh);
     }
    // --- Per-template watermark of the newest committed HistoryTime() already written to
    // --- Signal_Log.csv - linear search is fine, template counts here are small (<50).
    datetime CGUIPannel::GetSignalLogWatermark(const string type_key, const string params_key)
     {
      for(int i = 0; i < ArraySize(m_wm_type); i++)
         if(m_wm_type[i] == type_key && m_wm_params[i] == params_key)
            return m_wm_time[i];
      return 0;
     }
    // --- Updates (or appends) one template's watermark and persists the whole small file right
    // --- away - only called when a closed bar genuinely committed a new flip, so this is a rare
    // --- event, not a per-tick cost.
    void CGUIPannel::SetSignalLogWatermark(const string type_key, const string params_key, const datetime t)
     {
      for(int i = 0; i < ArraySize(m_wm_type); i++)
         if(m_wm_type[i] == type_key && m_wm_params[i] == params_key)
           {
            m_wm_time[i] = t;
            SaveSignalLogWatermarksToFile();
            return;
           }
      int n = ArraySize(m_wm_type);
      ArrayResize(m_wm_type,   n + 1);
      ArrayResize(m_wm_params, n + 1);
      ArrayResize(m_wm_time,   n + 1);
      m_wm_type[n]   = type_key;
      m_wm_params[n] = params_key;
      m_wm_time[n]   = t;
      SaveSignalLogWatermarksToFile();
     }
    // --- Dedicated small file, NOT Config_Setting.json - that file is already rewritten wholesale
    // --- by several other writers (SaveMarkerSettings, CTimeSeriesEngine::SaveConfigurationToJSON)
    // --- that don't know about this section and would silently drop it; a separate per-(symbol,TF)
    // --- file avoids any multi-writer coordination. Reuses the existing JsonIntValue/JsonStringValue
    // --- single-key scanners against each "{...}" object substring - no new parser needed.
    void CGUIPannel::LoadSignalLogWatermarks(void)
     {
      string fname = "Signal_Log_Watermark_" + ::Symbol() + "_" + ::EnumToString((ENUM_TIMEFRAMES)::Period()) + ".json";
      string content = IndicatorConfig_ReadWholeFile(fname);
      if(content == "") return;

      int pos = ::StringFind(content, "\"watermarks\"");
      if(pos < 0) return;
      int arr_start = ::StringFind(content, "[", pos);
      int arr_end   = ::StringFind(content, "]", arr_start);
      if(arr_start < 0 || arr_end < 0) return;

      int i = arr_start + 1;
      while(i < arr_end)
        {
         int obj_start = ::StringFind(content, "{", i);
         if(obj_start < 0 || obj_start > arr_end) break;
         int obj_end = ::StringFind(content, "}", obj_start);
         if(obj_end < 0 || obj_end > arr_end) break;
         string obj = ::StringSubstr(content, obj_start, obj_end - obj_start + 1);

         string type_key, params_key; int t;
         if(JsonStringValue(obj, "type", type_key) && JsonStringValue(obj, "params", params_key) && JsonIntValue(obj, "time", t))
           {
            int n = ArraySize(m_wm_type);
            ArrayResize(m_wm_type,   n + 1);
            ArrayResize(m_wm_params, n + 1);
            ArrayResize(m_wm_time,   n + 1);
            m_wm_type[n]   = type_key;
            m_wm_params[n] = params_key;
            m_wm_time[n]   = (datetime)t;
           }
         i = obj_end + 1;
        }
     }
    void CGUIPannel::SaveSignalLogWatermarksToFile(void)
     {
      string fname = "Signal_Log_Watermark_" + ::Symbol() + "_" + ::EnumToString((ENUM_TIMEFRAMES)::Period()) + ".json";
      string json = "{\n \"watermarks\": [\n";
      int n = ArraySize(m_wm_type);
      for(int i = 0; i < n; i++)
        {
         string type_esc = m_wm_type[i]; ::StringReplace(type_esc, "\\", "\\\\");
         string params_esc = m_wm_params[i]; ::StringReplace(params_esc, "\\", "\\\\");
         json += "  { \"type\": \"" + type_esc + "\", \"params\": \"" + params_esc + "\", \"time\": " + (string)(int)m_wm_time[i] + " }";
         json += (i < n - 1) ? ",\n" : "\n";
        }
      json += " ]\n}";

      int fh = ::FileOpen(fname, FILE_TXT|FILE_WRITE|FILE_ANSI);
      if(fh == INVALID_HANDLE) return;
      ::FileWriteString(fh, json);
      ::FileClose(fh);
     }
    //Ver 1
    // --- Template view of Layer 1 (see README 5c): one row per template. The row set changes
    // --- ONLY via LoadConfigurationFromJSON (initial build here), AddIndicatorInstance (appends its
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
      // --- Structural (re)build - initial fill after LoadConfigurationFromJSON, or safety on mismatch
      if(count == 0)
        {
         if(ArraySize(m_table_indicator_ptrs) == 0) return; // already showing the empty state - leave the table alone
         m_table_indicator.DeleteAllRows();
         m_table_indicator.AddRow(0);   // safety row: Library bug - DeleteAllRows does not reset m_item_index_focus
         ArrayResize(m_table_indicator_names, 0);
         ArrayResize(m_table_indicator_ptrs, 0);
         ArrayResize(m_settings_cache_state, 0);
         m_table_indicator.Update(true);
         return;
        }
      m_table_indicator.DeleteAllRows();
      // --- redraw=true on the LAST row only: AddRow() only recalculates the table's visible-area
      // --- size (CTable::RecalculateAndResizeTable) when told to - skipping it on every row and
      // --- doing it once at the end avoids the black/smeared row-overflow bug (README/BugNote
      // --- 2026-07-14) without paying the recalculation cost on every single row.
      for(int i = 0; i < count - 1; i++)   // DeleteAllRows leaves one physical row behind
         m_table_indicator.AddRow(i, i == count - 2);
      ArrayResize(m_table_indicator_names, count);
      ArrayResize(m_table_indicator_ptrs, count);
      ArrayResize(m_settings_cache_state, count);
      for(int row = 0; row < count; row++)
         SetIndicatorTableRow(row, list.At(row));
      m_table_indicator.Update(true);
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
      // --- Col 2/3: Buy / Sell signal filters (default OFF - markers are opt-in per template;
      // --- TemplateBuySellFor reads these checkboxes live, toggles rewrite the bridge file)
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
      // --- Col 5/6: Sound / Message opt-in per template (default OFF, same pattern as
      // --- Buy/Sell) - checkbox UI only for now, wiring to actually play/print on a new
      // --- Signal is still TBD (2026-07-17).
       m_table_indicator.CellType(5, row, CELL_CHECKBOX);
       m_table_indicator.SetImages(5, row, chk);
       m_table_indicator.ChangeImage(5, row, 1);
       m_table_indicator.CellType(6, row, CELL_CHECKBOX);
       m_table_indicator.SetImages(6, row, chk);
       m_table_indicator.ChangeImage(6, row, 1);

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
    // --- Detaches every chart line currently representing this indicator (Layer 3 mirror,
    // --- handle = join key). Shared by the per-row Hide toggle, per-row Remove, and
    // --- OnDeinitEvent's full sweep (BugNote 2026-07-18: Layer 1 indicators left shown
    // --- on chart - BBands/PSAR/AMA/hand-added MAs - were never detached on final EA
    // --- removal, only the SignalMarkers overlay was; this closes that gap for every row).
    void CGUIPannel::DetachIndicatorFromChart(CIndicatorDE *indicator)
     {
      if(indicator == NULL) return;
      CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
      if(chart == NULL) return;
      for(int win = chart.WindowsTotal() - 1; win >= 0; win--)
        {
         CChartWnd *wnd = chart.GetWindowByNum(win);
         if(wnd == NULL) continue;
         for(int i = wnd.IndicatorsTotal() - 1; i >= 0; i--)
           {
            CWndInd *wnd_ind = wnd.GetIndicatorByIndex(i);
            if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
               ChartIndicatorDelete(0, win, wnd_ind.Name());
           }
        }
     }
    void CGUIPannel::OnClickToggleShowIndicatorOnChart(const string sname, const int row)
     {
      if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
      CIndicatorDE *ind = m_table_indicator_ptrs[row];
      if(ind == NULL) return;

      int new_state = (int)m_table_indicator.SelectedImageIndex(4, row);
      int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
      if(new_state == INDICATOR_HIDE_ON_CHART)   // Hide: remove from chart, PureData/handle stay intact
         DetachIndicatorFromChart(ind);
      else // Show: re-attach using the stored handle
        {
         int sub_window = (ind.Group() == INDICATOR_GROUP_TREND) ? 0 : subwindows;
         ChartIndicatorAdd(0, sub_window, ind.Handle());
        }
      ChartRedraw();
     }
    // --- Col 2/3 checkboxes: per-template Buy/Sell signal filters. The table already
    // --- flipped the checkbox image before this handler fires; BuildAndWriteSignalBridge
    // --- reads the checkbox states live via TemplateBuySellFor, so a toggle just needs the
    // --- watermark rewound so the very next write is a full, immediate rewrite.
    void CGUIPannel::OnClickToggleBuySignal(const string sname, const int row)
     {
      ResetSignalBridge();
     }
    void CGUIPannel::OnClickToggleSellSignal(const string sname, const int row)
     {
      ResetSignalBridge();
     }
    // --- Rewinds the bridge watermark and rewrites the bridge file immediately (not deferred
    // --- to the next timer tick) so a Buy/Sell toggle is reflected on the chart right away.
    void CGUIPannel::ResetSignalBridge(void)
     {
      m_signal_bridge_last_time = 0;
      BuildAndWriteSignalBridge();
     }
    // --- Delete every legacy signal-arrow chart object of (sym, tf) - leftovers from the old
    // --- graphic-object drawing path (CreateSignalBuy/Sell/CreateThumbUp/Down), before the
    // --- SignalMarkers.mq5 indicator + bridge file replaced it entirely (BugNote 2026-07-16).
    // --- Kept only for migration/cleanup purposes - the new path never creates these objects.
    void CGUIPannel::PurgeSignalArrowObjects(const string sym, const string tf_string)
     {
      string prefix = ::MQLInfoString(MQL_PROGRAM_NAME) + "_sig_" + sym + "_" + tf_string + "_";
      for(int i = ::ObjectsTotal(m_chart_id) - 1; i >= 0; i--)
        {
         string obj_name = ::ObjectName(m_chart_id, i);
         if(::StringFind(obj_name, prefix) == 0)
            ::ObjectDelete(m_chart_id, obj_name);
        }
     }
    // ============================================================================
    // Positions Table (TAB_TAB_MAIN_POSITIONS) - ported VERBATIM from V1
    // (Anatoli Kazharski\GUIPannel.mqh), 2026-07-19, per user request: bring it over
    // as-is before any redesign against Layer 1 (CTradingEngine/CMarketCollection).
    // Deliberately still raw ::PositionsTotal()/::PositionGetX() loops, same as V1 -
    // NOT wired to CMarketCollection/CTradingSelect yet.
    // ============================================================================
    //+------------------------------------------------------------------+
    //| Create a position table                                          |
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    //| Pre-trade-plan symbol picker - Market Watch symbols, alphabetical |
    //| (same sort convention as PopulateSymbolTFTree), default-selects   |
    //| the current chart symbol.                                        |
    //+------------------------------------------------------------------+
    bool CGUIPannel::CreatePreTradePlanSymbolCombo(const int x, const int y)
     {
      m_combo_pre_Trade_plan_symbol.MainPointer(m_tabs_main);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_combo_pre_Trade_plan_symbol);
      int mw_total = ::SymbolsTotal(true);
      string labels[];
      ::ArrayResize(labels, mw_total);
      for(int i = 0; i < mw_total; i++)
         labels[i] = ::SymbolName(i, true);
      for(int a = 0; a < mw_total - 1; a++)
         for(int b = a + 1; b < mw_total; b++)
            if(labels[b] < labels[a])
              { string tmp = labels[a]; labels[a] = labels[b]; labels[b] = tmp; }
      int selected = 0;
      for(int i = 0; i < mw_total; i++)
         if(labels[i] == _Symbol) { selected = i; break; }
      int combo_w = 150;
      m_combo_pre_Trade_plan_symbol.XSize(combo_w);
      m_combo_pre_Trade_plan_symbol.YSize(20);
      m_combo_pre_Trade_plan_symbol.ItemsTotal(mw_total);
      int list_h = 18 * mw_total + 4;
      if(list_h > 300) list_h = 300;
      m_combo_pre_Trade_plan_symbol.GetListViewPointer().YSize(list_h);
      m_combo_pre_Trade_plan_symbol.GetButtonPointer().XGap(1);
      m_combo_pre_Trade_plan_symbol.GetButtonPointer().XSize(combo_w);
      m_combo_pre_Trade_plan_symbol.GetButtonPointer().LabelYGap(4);
      m_combo_pre_Trade_plan_symbol.GetButtonPointer().IconYGap(3);
      if(!m_combo_pre_Trade_plan_symbol.CreateComboBox("", x, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_combo_pre_Trade_plan_symbol);
      m_combo_pre_Trade_plan_symbol.GetListViewPointer().Rebuilding(mw_total);
      for(int i = 0; i < mw_total; i++)
         m_combo_pre_Trade_plan_symbol.SetValue(i, labels[i]);
      m_combo_pre_Trade_plan_symbol.SelectItem(selected);
      m_combo_pre_Trade_plan_symbol.GetListViewPointer().Update(true);
      return true;
     }
    //+------------------------------------------------------------------+
    //| Pre-trade-plan order-setup controls - Distance mode+value and    |
    //| Lot mode+value, laid out in ONE horizontal row (Anhnt 2026-07-20,|
    //| per user request "dàn hàng ngang" instead of the mockup's        |
    //| original stacked layout). ATR mode is a placeholder toggle only -|
    //| not wired to a real ATR series yet, falls back to the Distance   |
    //| edit's own value either way (see SetValuesToPreTradePlanTable).  |
    //+------------------------------------------------------------------+
    bool CGUIPannel::CreatePreTradePlanControls(const int x, const int y)
     {
      //--- "Dist" caption + Fixed/ATR toggle
       m_label_pre_trade_distance.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_label_pre_trade_distance);
       m_label_pre_trade_distance.XSize(28);
       if(!m_label_pre_trade_distance.CreateTextLabel("Dist", x, y + 4)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_pre_trade_distance);

       int dist_group_x = x + 28;
       m_group_pre_trade_distance_mode.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_group_pre_trade_distance_mode);
       m_group_pre_trade_distance_mode.RadioButtonsMode(true);
       m_group_pre_trade_distance_mode.AddButton(0, 0, "Fixed", 45);
       m_group_pre_trade_distance_mode.AddButton(0, 0, "ATR", 45);
       if(!m_group_pre_trade_distance_mode.CreateButtonsGroup(dist_group_x, y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_group_pre_trade_distance_mode);

      //--- Distance value (points) - meaning is the same in both modes for now, ATR isn't
      //--- wired up to override it yet.
       int dist_edit_x = dist_group_x + 95;
       m_edit_pre_trade_distance_pts.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_edit_pre_trade_distance_pts);
       m_edit_pre_trade_distance_pts.XSize(50);
       m_edit_pre_trade_distance_pts.GetTextBoxPointer().XGap(1);
       if(!m_edit_pre_trade_distance_pts.CreateTextEdit("100", dist_edit_x, y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_pre_trade_distance_pts);

      //--- "Lot" caption + By Distance(manual)/By Risk % toggle
       int lot_label_x = dist_edit_x + 60;
       m_label_pre_trade_lot.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_label_pre_trade_lot);
       m_label_pre_trade_lot.XSize(25);
       if(!m_label_pre_trade_lot.CreateTextLabel("Lot", lot_label_x, y + 4)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_pre_trade_lot);

       int lot_group_x = lot_label_x + 25;
       m_group_pre_trade_lot_mode.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_group_pre_trade_lot_mode);
       m_group_pre_trade_lot_mode.RadioButtonsMode(true);
       m_group_pre_trade_lot_mode.AddButton(0, 0, "By Distance", 80);
       m_group_pre_trade_lot_mode.AddButton(0, 0, "By Risk %", 80);
       if(!m_group_pre_trade_lot_mode.CreateButtonsGroup(lot_group_x, y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_group_pre_trade_lot_mode);

      //--- Lot-or-Risk% value - same edit box, meaning switches with the toggle above
       int lot_edit_x = lot_group_x + 165;
       m_edit_pre_trade_lot_or_risk.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_edit_pre_trade_lot_or_risk);
       m_edit_pre_trade_lot_or_risk.XSize(50);
       m_edit_pre_trade_lot_or_risk.GetTextBoxPointer().XGap(1);
       if(!m_edit_pre_trade_lot_or_risk.CreateTextEdit("0.01", lot_edit_x, y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_pre_trade_lot_or_risk);
       return true;
     }
    //+------------------------------------------------------------------+
    //| Pre-trade-plan order-setup table - one row per direction (row 0  |
    //| = Buy, row 1 = Sell), matching the agreed mockup layout (Dir /   |
    //| Entry / SL / Distance / Lot / Risk $ / Risk %). Values come from |
    //| CreatePreTradePlanControls' Distance/Lot mode+value controls -   |
    //| see SetValuesToPreTradePlanTable. Dir cell is still NOT wired to |
    //| send real orders yet (Anhnt 2026-07-20).                          |
    //+------------------------------------------------------------------+
    bool CGUIPannel::CreatePreTradePlanTable(const int x, const int y)
     {
      #define COLUMNS3_TOTAL 7
      #define ROWS3_TOTAL 2
       m_table_pre_Trade_plan.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_table_pre_Trade_plan);
       int width[COLUMNS3_TOTAL];
       ::ArrayInitialize(width, 70);
       width[0] = 55; // Dir
       width[4] = 55; // Lot
      //--- Icon columns (Dir) must be ALIGN_LEFT or RedrawCell silently skips DrawImage
       ENUM_ALIGN_MODE align[COLUMNS3_TOTAL];
       ::ArrayInitialize(align, ALIGN_RIGHT);
       align[0] = ALIGN_LEFT;
       int text_x_offset[COLUMNS3_TOTAL];
       ::ArrayInitialize(text_x_offset, 5);
       text_x_offset[0] = 22; // clear the Dir icon, same convention as m_table_indicator_SymbolTFValue
       int image_x_offset[COLUMNS3_TOTAL];
       ::ArrayInitialize(image_x_offset, 3);
       int image_y_offset[COLUMNS3_TOTAL];
       ::ArrayInitialize(image_y_offset, 2);
       m_table_pre_Trade_plan.TableSize(COLUMNS3_TOTAL, ROWS3_TOTAL);
       m_table_pre_Trade_plan.ColumnsWidth(width);
       m_table_pre_Trade_plan.TextAlign(align);
       m_table_pre_Trade_plan.TextXOffset(text_x_offset);
       m_table_pre_Trade_plan.ImageXOffset(image_x_offset);
       m_table_pre_Trade_plan.ImageYOffset(image_y_offset);
       m_table_pre_Trade_plan.ShowHeaders(true);
       m_table_pre_Trade_plan.SelectableRow(false);
       m_table_pre_Trade_plan.AutoXResizeMode(true);
       m_table_pre_Trade_plan.AutoXResizeRightOffset(2);
       if(!m_table_pre_Trade_plan.CreateTable(x, y)) return false;
       string headers[COLUMNS3_TOTAL] = {"Dir", "Entry", "SL", "Distance", "Lot", "Risk $", "Risk %"};
       for(int i = 0; i < COLUMNS3_TOTAL; i++)
          m_table_pre_Trade_plan.SetHeaderText(i, headers[i]);
       for(int r = 0; r < ROWS3_TOTAL; r++)
          m_table_pre_Trade_plan.AddRow(r, r == ROWS3_TOTAL - 1);
      //--- Dir icon: same val_img set as m_table_indicator_SymbolTFValue's col 2 - row 0/Buy is
      //--- always the up arrow, row 1/Sell is always the down arrow (gray/index 2 unused here,
      //--- direction is fixed per row, not data-driven).
       uint dir_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG,
                        IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
       m_table_pre_Trade_plan.SetImages(0, 0, dir_img);
       m_table_pre_Trade_plan.ChangeImage(0, 0, 0);
       m_table_pre_Trade_plan.SetValue(0, 0, " Buy");
       m_table_pre_Trade_plan.SetImages(0, 1, dir_img);
       m_table_pre_Trade_plan.ChangeImage(0, 1, 1);
       m_table_pre_Trade_plan.SetValue(0, 1, " Sell");
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_pre_Trade_plan);
       SetValuesToPreTradePlanTable(true);
       return true;
     }
    //+------------------------------------------------------------------+
    //| Live refresh for the pre-trade-plan table - Entry/SL track real  |
    //| Bid/Ask of the combo's selected symbol every tick; Distance/Lot  |
    //| now come from the real Distance/Lot mode+value controls (Anhnt   |
    //| 2026-07-20). ATR mode isn't wired to a real ATR series yet - it  |
    //| still just uses the Distance edit's own value either way. Risk   |
    //| $/% use the same lot-sizing formula as EA2.mq5's CalcLots.       |
    //+------------------------------------------------------------------+
    bool CGUIPannel::SetValuesToPreTradePlanTable(bool force = false)
     {
      string symbol = m_combo_pre_Trade_plan_symbol.GetValue();
      if(symbol == "") symbol = _Symbol;
      double bid    = ::SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask    = ::SymbolInfoDouble(symbol, SYMBOL_ASK);
      double point  = ::SymbolInfoDouble(symbol, SYMBOL_POINT);
      int    digits = (int)::SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      int    stops_level  = (int)::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double dist_input   = ::StringToDouble(m_edit_pre_trade_distance_pts.GetValue());
      // --- Distance mode toggle (Fixed/ATR) read but not yet acted on - ATR needs a real ATR
      // --- series wired to this table, not built yet. Both modes use the edit's own value.
      int    distance_pts = (dist_input > 0) ? (int)dist_input : ((stops_level > 0) ? stops_level : 100);
      double tick_value  = ::SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double balance     = ::AccountInfoDouble(ACCOUNT_BALANCE);
      double lot_or_risk_input = ::StringToDouble(m_edit_pre_trade_lot_or_risk.GetValue());
      double lot;
      if(m_group_pre_trade_lot_mode.SelectedButtonIndex() == 1) // By Risk %
        {
         double risk_pct_target = (lot_or_risk_input > 0) ? lot_or_risk_input : 1.0;
         double risk_usd_target = balance * risk_pct_target / 100.0;
         double money_per_lot   = distance_pts * tick_value;
         lot = (money_per_lot > 0) ? risk_usd_target / money_per_lot : 0.01;
         double lot_step = ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
         double lot_min  = ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
         double lot_max  = ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
         if(lot_step > 0) lot = ::MathFloor(lot / lot_step) * lot_step;
         if(lot < lot_min) lot = lot_min;
         if(lot > lot_max) lot = lot_max;
        }
      else // By Distance (manual pick)
         lot = (lot_or_risk_input > 0) ? lot_or_risk_input : 0.01;
      double risk_usd = lot * distance_pts * tick_value;
      double risk_pct = (balance > 0) ? risk_usd / balance * 100.0 : 0.0;
      double entry[2], sl[2];
      entry[0] = ask; sl[0] = ask - distance_pts * point; // Buy
      entry[1] = bid; sl[1] = bid + distance_pts * point; // Sell
      static string s_entry[2], s_sl[2], s_dist[2], s_lot[2], s_risk_usd[2], s_risk_pct[2];
      bool any_changed = false;
      for(int row = 0; row < 2; row++)
        {
         string c_entry    = ::DoubleToString(entry[row], digits);
         string c_sl       = ::DoubleToString(sl[row], digits);
         string c_dist     = (string)distance_pts + " pts";
         string c_lot      = ::DoubleToString(lot, 2);
         string c_risk_usd = ::DoubleToString(risk_usd, 2);
         string c_risk_pct = ::DoubleToString(risk_pct, 2) + "%";
         if(force || c_entry    != s_entry[row])    { m_table_pre_Trade_plan.SetValue(1, row, c_entry,    0, true); s_entry[row]    = c_entry;    any_changed = true; }
         if(force || c_sl       != s_sl[row])       { m_table_pre_Trade_plan.SetValue(2, row, c_sl,       0, true); s_sl[row]       = c_sl;       any_changed = true; }
         if(force || c_dist     != s_dist[row])     { m_table_pre_Trade_plan.SetValue(3, row, c_dist,     0, true); s_dist[row]     = c_dist;     any_changed = true; }
         if(force || c_lot      != s_lot[row])      { m_table_pre_Trade_plan.SetValue(4, row, c_lot,      0, true); s_lot[row]      = c_lot;      any_changed = true; }
         if(force || c_risk_usd != s_risk_usd[row]) { m_table_pre_Trade_plan.SetValue(5, row, c_risk_usd, 0, true); s_risk_usd[row] = c_risk_usd; any_changed = true; }
         if(force || c_risk_pct != s_risk_pct[row]) { m_table_pre_Trade_plan.SetValue(6, row, c_risk_pct, 0, true); s_risk_pct[row] = c_risk_pct; any_changed = true; }
        }
      // --- Update(false), NOT Update(true) - true runs the full DrawTable()/AutoResizeColumns
      // --- repaint path, which given Entry/SL change on nearly every tick caused a full-table
      // --- flicker (Anhnt, 2026-07-20, reported "nháy điên cuồng"). Per-cell RedrawCell (via
      // --- SetValue's redraw=true above) + a cheap Update(false) is the same no-flicker pattern
      // --- SetValuesToPositionsTable already uses.
      if(any_changed) m_table_pre_Trade_plan.Update(false);
      return any_changed;
     }
    bool CGUIPannel::CreatePositionsTable(const int x_gap, const int y_gap)
     {
      #define COLUMNS2_TOTAL 10
      #define ROWS2_TOTAL 1
      //--- Store the pointer to the parent tab and attach
       m_table_positions.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_table_positions);
      //--- Array of column widths
       int width[COLUMNS2_TOTAL];
       ::ArrayInitialize(width, 75);
       width[0] = 90;
       width[1] = 63;
       width[2] = 60;
       width[5] = 60;
       width[8] = 90;
      //--- Array of text alignment in columns
       ENUM_ALIGN_MODE align[COLUMNS2_TOTAL];
       ::ArrayInitialize(align, ALIGN_CENTER);
       align[0] = ALIGN_LEFT;
      //--- Array of text offset along the X axis in the columns
       int text_x_offset[COLUMNS2_TOTAL];
       ::ArrayInitialize(text_x_offset, 21);
      //--- Array of column image offsets along the X axis
       int image_x_offset[COLUMNS2_TOTAL];
       ::ArrayInitialize(image_x_offset, 3);
      //--- Array of column image offsets along the Y axis
       int image_y_offset[COLUMNS2_TOTAL];
       ::ArrayInitialize(image_y_offset, 2);
      //--- Properties
       m_table_positions.TableSize(COLUMNS2_TOTAL, ROWS2_TOTAL);
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
       if(!m_table_positions.CreateTable(x_gap, y_gap))
          return(false);
      //--- Set the header titles
       string headers[COLUMNS2_TOTAL] = {"Symbol", "Positions", "Volume", "Buy Volume", "Sell Volume", "Profit", "Buy Profit", "Sell Profit", "Deposit Load", "Average Price"};
       for(int i = 0; i < COLUMNS2_TOTAL; i++)
          m_table_positions.SetHeaderText(i, headers[i]);
      //--- Add the object to the common array of object groups
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_positions);
       return(true);
     }
    //+------------------------------------------------------------------+
    //| Initialize the position table with current open positions        |
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
           uint button_images[1] = {IMAGE_RESOURCE_BMP16_CLOSE_BLACK_BMP};
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
    bool CGUIPannel::SetValuesToPositionsTable(string &symbols_name[], bool force = false)
     {
      uint symbols_total = ::ArraySize(symbols_name);
      uint rows_total = m_table_positions.RowsTotal();
      if(symbols_total < rows_total)
         return false;
      static uint s_prev_rows = 0;
      static string s_c0[], s_c1[], s_c2[], s_c3[], s_c4[];
      static string s_c5[], s_c6[], s_c7[], s_c8[], s_c9[];
      if(s_prev_rows != rows_total || force)
        {
         s_prev_rows = rows_total;
         ::ArrayResize(s_c0, rows_total);
         ::ArrayResize(s_c1, rows_total);
         ::ArrayResize(s_c2, rows_total);
         ::ArrayResize(s_c3, rows_total);
         ::ArrayResize(s_c4, rows_total);
         ::ArrayResize(s_c5, rows_total);
         ::ArrayResize(s_c6, rows_total);
         ::ArrayResize(s_c7, rows_total);
         ::ArrayResize(s_c8, rows_total);
         ::ArrayResize(s_c9, rows_total);
         for(uint i = 0; i < rows_total; i++)
            s_c0[i] = s_c1[i] = s_c2[i] = s_c3[i] = s_c4[i] =
                s_c5[i] = s_c6[i] = s_c7[i] = s_c8[i] = s_c9[i] = "";
        }
      bool any_changed = false;
      // Calculate values and set to table with dirty-check
      for(uint r = 0; r < rows_total; r++)
        {
         double pos_volume = PositionsVolumeTotal(symbols_name[r]);
         double buy_volume = PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_BUY);
         double sell_volume = PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_SELL);
         double pos_profit = PositionsFloatingProfitTotal(symbols_name[r]);
         double buy_profit = PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_BUY);
         double sell_profit = PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_SELL);
         double avg_price = PositionAveragePrice(symbols_name[r]);
         string v0 = symbols_name[r];
         string v1 = (string)PositionsTotal(symbols_name[r]);
         string v2 = ::DoubleToString(pos_volume, 2);
         string v3 = ::DoubleToString(buy_volume, 2);
         string v4 = ::DoubleToString(sell_volume, 2);
         string v5 = ::DoubleToString(pos_profit, 2);
         string v6 = ::DoubleToString(buy_profit, 2);
         string v7 = ::DoubleToString(sell_profit, 2);
         string v8 = ::DoubleToString(DepositLoad(false, avg_price, symbols_name[r], pos_volume), 2) + "/" +
                     ::DoubleToString(DepositLoad(true, avg_price, symbols_name[r], pos_volume), 2) + "%";
         string v9 = ::DoubleToString(avg_price, (int)::SymbolInfoInteger(symbols_name[r], SYMBOL_DIGITS));

         if(v0 != s_c0[r])
           {
            s_c0[r] = v0;
            m_table_positions.SetValue(0, r, v0, 0, true);
            any_changed = true;
           }
         if(v1 != s_c1[r])
           {
            s_c1[r] = v1;
            m_table_positions.SetValue(1, r, v1, 0, true);
            any_changed = true;
           }
         if(v2 != s_c2[r])
           {
            s_c2[r] = v2;
            m_table_positions.SetValue(2, r, v2, 0, true);
            any_changed = true;
           }
         if(v3 != s_c3[r])
           {
            s_c3[r] = v3;
            m_table_positions.TextColor(3, r, (buy_volume > 0) ? clrBlack : clrLightGray);
            m_table_positions.SetValue(3, r, v3, 0, true);
            any_changed = true;
           }
         if(v4 != s_c4[r])
           {
            s_c4[r] = v4;
            m_table_positions.TextColor(4, r, (sell_volume > 0) ? clrBlack : clrLightGray);
            m_table_positions.SetValue(4, r, v4, 0, true);
            any_changed = true;
           }
         if(v5 != s_c5[r])
           {
            s_c5[r] = v5;
            m_table_positions.TextColor(5, r, (pos_profit != 0) ? (pos_profit > 0 ? clrGreen : clrRed) : clrLightGray);
            m_table_positions.SetValue(5, r, v5, 0, true);
            any_changed = true;
           }
         if(v6 != s_c6[r])
           {
            s_c6[r] = v6;
            m_table_positions.TextColor(6, r, (buy_profit != 0) ? (buy_profit > 0 ? clrGreen : clrRed) : clrLightGray);
            m_table_positions.SetValue(6, r, v6, 0, true);
            any_changed = true;
           }
         if(v7 != s_c7[r])
           {
            s_c7[r] = v7;
            m_table_positions.TextColor(7, r, (sell_profit != 0) ? (sell_profit > 0 ? clrGreen : clrRed) : clrLightGray);
            m_table_positions.SetValue(7, r, v7, 0, true);
            any_changed = true;
           }
         if(v8 != s_c8[r])
           {
            s_c8[r] = v8;
            m_table_positions.SetValue(8, r, v8, 0, true);
            any_changed = true;
           }
         if(v9 != s_c9[r])
           {
            s_c9[r] = v9;
            m_table_positions.SetValue(9, r, v9, 0, true);
            any_changed = true;
           }
        }
      if(any_changed)
         m_table_positions.Update(false);
      return any_changed;
     }
    //+------------------------------------------------------------------+
    //| Check a new trade on history                                     |
    //+------------------------------------------------------------------+
    bool CGUIPannel::IsLastDealTicket(void)
     {
      //--- Exit if the history is not received
       if(!::HistorySelect(m_last_deal_time, UINT_MAX))
          return(false);
      //--- Get the number of deals in the obtained list
       int total_deals = ::HistoryDealsTotal();
      //--- Loop through the total number of deals in the obtained list from the
      // last deal to the first one
       for(int i = total_deals - 1; i >= 0; i--)
         {
          //--- Get the deal ticket
           ulong deal_ticket = ::HistoryDealGetTicket(i);
          //--- Exit if the tickets are equal
           if(deal_ticket == m_last_deal_ticket)
              return(false);
          //--- If the tickets are not equal, report it
           else
             {
              datetime deal_time = (datetime)::HistoryDealGetInteger(deal_ticket, DEAL_TIME);
              //--- Save the last deal time and ticket
               m_last_deal_time = deal_time;
               m_last_deal_ticket = deal_ticket;
               return(true);
             }
         }
       return(false);
     }
    //+------------------------------------------------------------------+
    //| Get symbols of open positions in the array                       |
    //+------------------------------------------------------------------+
    int CGUIPannel::GetPositionsSymbols(string &symbols_name[])
     {
      string symbols = "";
      //--- Go through the loop for the first time and get symbols of open positions
       int positions_total = ::PositionsTotal();
       for(int i = 0; i < positions_total; i++)
         {
          //--- Select a position and get its symbol
           string position_symbol = ::PositionGetSymbol(i);
          //--- If there is a symbol name
           if(position_symbol == "")
              continue;
          //--- If there is no such a string, add it
           if(::StringFind(symbols, position_symbol, 0) == WRONG_VALUE)
              ::StringAdd(symbols, (symbols == "") ? position_symbol : "," + position_symbol);
         }
      //--- Get string elements by separator
       ushort u_sep = ::StringGetCharacter(",", 0);
       int symbols_total = ::StringSplit(symbols, u_sep, symbols_name);
      //--- Return the number of symbols
       return(symbols_total);
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
       for(int i = positions_total - 1; i >= 0; i--)
         {
          //--- If failed to select a position, go to the next one
           if(symbol != ::PositionGetSymbol(i))
              continue;
          //--- Get the price and position volume
           double pos_price = ::PositionGetDouble(POSITION_PRICE_OPEN);
           double pos_volume = ::PositionGetDouble(POSITION_VOLUME);
          //--- Sum up the intermediate indicators
           sum_mult += (pos_price * pos_volume);
           sum_volumes += pos_volume;
         }
      //--- Prevent division by zero
       if(sum_volumes <= 0)
          return(0.0);
      //--- Return the average price
       return(::NormalizeDouble(sum_mult / sum_volumes, (int)::SymbolInfoInteger(symbol, SYMBOL_DIGITS)));
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
       for(int i = positions_total - 1; i >= 0; i--)
         {
          //--- If failed to select a position, go to the next one
           if(symbol != ::PositionGetSymbol(i))
              continue;
          //--- Increase the counter
           pos_counter++;
         }
      //--- Return the number of positions
       return(pos_counter);
     }
    //+------------------------------------------------------------------+
    //| Total volume of positions with the specified properties          |
    //+------------------------------------------------------------------+
    double CGUIPannel::PositionsVolumeTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE)
     {
      //--- Volume counter
       double volume_counter = 0;
      //--- Check if there is a position with specified properties
       int positions_total = ::PositionsTotal();
       for(int i = positions_total - 1; i >= 0; i--)
         {
          //--- If failed to select a position, go to the next one
           if(symbol != ::PositionGetSymbol(i))
              continue;
          //--- If the type should be selected
           if(type != WRONG_VALUE)
             {
              //--- If the type does not match, go to the next position
               if(type != (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE))
                  continue;
             }
          //--- Sum up the volume
           volume_counter += ::PositionGetDouble(POSITION_VOLUME);
         }
      //--- Return the volume
       return(volume_counter);
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
       for(int i = positions_total - 1; i >= 0; i--)
         {
          //--- If failed to select a position, go to the next one
           if(symbol != "" && symbol != ::PositionGetSymbol(i))
              continue;
          //--- If the type should be selected
           if(type != WRONG_VALUE)
             {
              //--- If the type does not match, go to the next position
               if(type != (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE))
                  continue;
             }
          //--- Sum up the current profit + accumulated swap
           profit_counter += ::PositionGetDouble(POSITION_PROFIT) + ::PositionGetDouble(POSITION_SWAP);
         }
      //--- Return the result
       return(profit_counter);
     }
    //+------------------------------------------------------------------+
    //| Trade operation event - refresh positions table on a new deal    |
    //+------------------------------------------------------------------+
    void CGUIPannel::OnTradeEvent(void)
     {
      if(IsLastDealTicket())
         InitializePositionsTable();
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
         DetachIndicatorFromChart(indicator);
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

      SetValuesToIndicatorSymbolTFTable();
      SyncIndicatorTreeViewIcons();
      ChartRedraw();
     } 
   
   //For Symbol TF treeview
   bool CGUIPannel::CreateTreeView_SymbolTF(const int x_gap, const int y_gap)
    {       
       m_treeview_SymbolTF.MainPointer(m_window_main);
       m_treeview_SymbolTF.AutoXResizeMode(false);  // fixed width
       m_treeview_SymbolTF.XSize(M_TREEVIEW_SYMBOLTF_WIDTH);
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
      // --- SymbolName(i,true)'s own index order is Market Watch's internal/insertion order,
      // --- NOT the alphabetically-sorted order the Market Watch grid displays (Anhnt,
      // --- 2026-07-19) - a brand new symbol node only ever gets APPENDED (AddTreeItem always
      // --- uses ItemsTotal() as the new list_index, there's no "insert at position"), so the
      // --- only way to make first-time node creation come out sorted is to visit symbols in
      // --- sorted order here. m_sym_tree_pos[] stays keyed by the RAW Market Watch index i -
      // --- only the iteration order changes, already-created nodes are unaffected.
      int order[];
      ArrayResize(order, mw_total);
      for(int i = 0; i < mw_total; i++) order[i] = i;
      for(int a = 0; a < mw_total - 1; a++)
         for(int b = a + 1; b < mw_total; b++)
            if(::SymbolName(order[b], true) < ::SymbolName(order[a], true))
              { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
      // --- FormTreeList() silently drops any item whose item_index is not monotonically
      // --- increasing within its node_level, in the order items were created/appended
      // --- (Anhnt, 2026-07-19) - since we now visit symbols in ALPHABETICAL order (not raw
      // --- Market Watch index order), raw i is NOT monotonic across creation order any more.
      // --- sym_item_seq tracks "how many sym nodes exist so far" and is used as item_index
      // --- instead of i, so it always increases by exactly 1 per new node, regardless of
      // --- which raw index i that node happens to be.
       int sym_item_seq = 0;
       for(int c = 0; c < ArraySize(m_sym_tree_pos); c++)
         if(m_sym_tree_pos[c] != -1) sym_item_seq++;
       for(int oi = 0; oi < mw_total; oi++)
        {
          int               i        = order[oi];
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
                                          sym_item_seq,
                                          0, //node_level symnode = 0 Node level must be >=0
                                          0,
                                          0, 0,
                                          false,    //item_state, m_t_item_state[]=true
                                          false      //is_folder m_t_is_folder[]=false
                                          );
             sym_item_seq++;
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
          // --- GetSeriesByIndex()'s own order is creation order, not TF rank (Anhnt,
          // --- 2026-07-19) - sort the LOOKUP order by IndexEnumTimeframe() so slot k below
          // --- (positionally matched against existing children[k]) ends up ascending M1..MN1,
          // --- same reasoning as the symbol-level sort above.
           int tf_order[];
           ArrayResize(tf_order, tf_cnt);
           for(int k = 0; k < tf_cnt; k++) tf_order[k] = k;
           for(int a = 0; a < tf_cnt - 1; a++)
              for(int b = a + 1; b < tf_cnt; b++)
                {
                 CBarSeriesDE *sa = bts.GetSeriesByIndex((uchar)tf_order[a]);
                 CBarSeriesDE *sb = bts.GetSeriesByIndex((uchar)tf_order[b]);
                 if(sa == NULL || sb == NULL) continue;
                 if(IndexEnumTimeframe(sb.Timeframe()) < IndexEnumTimeframe(sa.Timeframe()))
                   { int tmp = tf_order[a]; tf_order[a] = tf_order[b]; tf_order[b] = tmp; }
                }
          // Step 3: Match bts[k] against children[k]
           int actual_sym_li = -1;
           for(int k = 0; k < tf_cnt; k++)
            {
             CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)tf_order[k]);
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
         m_table_indicator.AddRow(row, true);   // redraw=true - recalculate visible-area size, see
                                                  // README/BugNote 2026-07-14 black/smeared overflow bug
       ArrayResize(m_table_indicator_names, row + 1);
       ArrayResize(m_table_indicator_ptrs,  row + 1);
       ArrayResize(m_settings_cache_state,  row + 1);
       SetIndicatorTableRow(row, indicator);
       m_table_indicator.Update(true);
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
  //+------------------------------------------------------------------+
  //| Deposit load - ported verbatim from V1 (Anatoli Kazharski\        |
  //| GUIPannel.mqh): plain built-in AccountInfoDouble/SymbolInfoDouble |
  //| calls, no Library CAccount wrapper needed. percent_mode==true     |
  //| returns margin as % of EQUITY (not Balance).                      |
  //| Used in: UpdateStatusBar (Deposit Load status bar item).          |
  //+------------------------------------------------------------------+
  double CGUIPannel::DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0)
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
         double contract_size = ::SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
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
      m_param_labels[i].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_labels[i]);
      if(!m_param_labels[i].CreateTextLabel("", default_x, default_y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_labels[i]);

      m_param_edits[i].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_edits[i]);
      m_param_edits[i].XSize(INDICATOR_PARAM_FIELD_W);
      // --- Inner CTextBox defaults its LOCAL x-offset to the outer box's x_size at
      // --- creation time unless told otherwise BEFORE CreateTextEdit() - confirmed via
      // --- debug log (inner canvas sitting ~90px right of the outer frame after resize).
       m_param_edits[i].GetTextBoxPointer().XGap(1);
       if(!m_param_edits[i].CreateTextEdit("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_edits[i]);

       m_param_combo[i].MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_combo[i]);
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
      m_btn_add_indicator.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_add_indicator);
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
      m_btn_save_indicator.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_save_indicator);
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
      SaveGUIConfigToJSON();
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
//| Builds the SAME (type, params-as-text) key CTimeSeriesEngine::   |
//| SaveConfigurationToJSON writes/LoadConfigurationFromJSON parses -|
//| NOT BuildIndicatorLabel's pvalues (that rounds doubles to 2      |
//| decimals for display; the saved file uses 8, so matching against|
//| it would silently fail for any non-integer param).               |
//+------------------------------------------------------------------+
void CGUIPannel::BuildTemplateMatchKey(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[], string &type_key, string &params_key)
  {
   type_key = "";
   for(int c = 0; c < ArraySize(catalog); c++)
      if(catalog[c].type == ind.TypeIndicator()) { type_key = catalog[c].name; break; }

   SIndicatorParam schema[];
   GetIndicatorParamSchema(ind.TypeIndicator(), schema);
   MqlParam params[];
   ind.GetMqlParams(params);

   params_key = "";
   for(int p = 0; p < ArraySize(params); p++)
     {
      if(p > 0) params_key += ",";
      string choices = (p < ArraySize(schema)) ? schema[p].choices : "";
      if(choices == PRICE_CHOICES)
         params_key += AppliedPriceDescription((ENUM_APPLIED_PRICE)params[p].integer_value);
      else if(choices == CALCULATION_METHOD_CHOICES)
         params_key += AveragingMethodDescription((ENUM_MA_METHOD)params[p].integer_value);
      else if(choices == VOLUME_CHOICES)
         params_key += AppliedVolumeDescription((ENUM_APPLIED_VOLUME)params[p].integer_value);
      else if(choices == STOCH_PRICE_CHOICES)
         params_key += StochPriceDescription((ENUM_STO_PRICE)params[p].integer_value);
      else if(params[p].type == TYPE_DOUBLE)
         params_key += ::DoubleToString(params[p].double_value, 8);
      else
         params_key += ::IntegerToString((int)params[p].integer_value);
     }
  }
//+------------------------------------------------------------------+
//| Called ONCE right after the initial RefreshIndicatorTable() (see |
//| OnInitEvent) - pulls the Buy/Sell state CTimeSeriesEngine::       |
//| LoadConfigurationFromJSON() cached while loading indicators_config|
//| .json and applies it to the matching m_table_indicator rows, so a |
//| saved Buy/Sell setting survives an EA restart instead of          |
//| resetting to OFF.                                                 |
//+------------------------------------------------------------------+
// --- Also applies Sound/Message (col 5/6) despite the name - kept the original name to avoid
// --- touching its one call site's context; extended in place 2026-07-17.
void CGUIPannel::ApplyLoadedIndicatorBuySell(void)
  {
   if(m_time_series_engine == NULL) return;
   string types[], param_keys[];
   bool buys[], sells[], sounds[], messages[];
   m_time_series_engine.GetLoadedTemplateSettings(types, param_keys, buys, sells, sounds, messages);
   if(ArraySize(types) == 0) return;

   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);

   int rows = ArraySize(m_table_indicator_ptrs);
   bool any_changed = false;
   for(int row = 0; row < rows; row++)
     {
      CIndicatorDE *ind = m_table_indicator_ptrs[row];
      if(ind == NULL) continue;
      string type_key, params_key;
      BuildTemplateMatchKey(ind, catalog, type_key, params_key);
      for(int q = 0; q < ArraySize(types); q++)
        {
         if(types[q] != type_key || param_keys[q] != params_key) continue;
         m_table_indicator.ChangeImage(2, row, buys[q]     ? 0 : 1);
         m_table_indicator.ChangeImage(3, row, sells[q]    ? 0 : 1);
         m_table_indicator.ChangeImage(5, row, sounds[q]   ? 0 : 1);
         m_table_indicator.ChangeImage(6, row, messages[q] ? 0 : 1);
         any_changed = true;
         break;
        }
     }
   if(any_changed) m_table_indicator.Update(true);
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

      // --- redraw=true on the LAST row only, same reasoning as RefreshIndicatorTable - see
      // --- README/BugNote 2026-07-14 black/smeared row-overflow bug.
      for(int i = 0; i < count - 1; i++)
         m_table_indicator_SymbolTFValue.AddRow(i, i == count - 2);
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
      // Col 1 (TF): sig_img - the actual Signal system, NOT value slope. GetOrCreateSignal itself
      // returns NULL for indicator types with no CSignalXXX wired yet, so this falls back to
      // dir_icon automatically - that fallback is the only place dir_icon and sig_icon are
      // allowed to share a value.
      // --- Sticky last-known direction (Anhnt, 2026-07-17): GetCurrentSignal() only fires at the
      // --- exact tick a crossover happens (bar0 vs bar1) - EMPTY_VALUE/neutral the rest of the
      // --- time, since a cross is a rare event, not a continuous state. User wants this column to
      // --- read as "uptrend/downtrend since the last Buy/Sell signal" instead - green/red persists
      // --- until the NEXT opposite flip, not just the instant of the flip itself. Prefer a flip
      // --- happening RIGHT NOW (more responsive); otherwise fall back to the last COMMITTED
      // --- history entry's direction (m_hist_* - permanent, only written when a bar actually
      // --- closed with a real flip), which is exactly this "last known direction" state.
      int sig_icon = dir_icon;
      if(m_time_series_engine != NULL)
        {
         // signal is BORROWED - CSignalsCollection owns it
         CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(signal != NULL)
           {
            ENUM_SIGNAL_DIR dir = signal.GetCurrentSignal();
            if(dir == SIGNAL_NONE)
              {
               int last_idx = signal.HistoryTotal() - 1;
               if(last_idx >= 0) dir = signal.HistoryDir(last_idx);
              }
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
//| Looks up (ind's type+params) among m_table_indicator_ptrs' rows  |
//| and returns that row's Buy/Sell checkbox state. Can't match by   |
//| pointer identity (m_table_indicator_ptrs only holds the CURRENT  |
//| chart's own-TF instances) - ind may be from a DIFFERENT tracked  |
//| TF of the same symbol, so this matches by TEMPLATE (type+params, |
//| via IsEqualMqlParamArrays - same "same template regardless of    |
//| symbol/TF" identity OnClickRemoveIndicator already relies on),   |
//| which the project's own invariant guarantees is uniform across   |
//| every TF (README: "every series has the exact same indicator    |
//| set"). Returns false (buy/sell both false) if no matching row is |
//| found at all.                                                    |
//+------------------------------------------------------------------+
bool CGUIPannel::TemplateBuySellFor(CIndicatorDE *ind, bool &buy, bool &sell)
  {
   buy = false; sell = false;
   if(ind == NULL) return false;
   ENUM_INDICATOR type = ind.TypeIndicator();
   MqlParam params[];
   ind.GetMqlParams(params);
   for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
     {
      CIndicatorDE *row_ind = m_table_indicator_ptrs[row];
      if(row_ind == NULL || row_ind.TypeIndicator() != type) continue;
      MqlParam row_params[];
      row_ind.GetMqlParams(row_params);
      if(!IsEqualMqlParamArrays(params, row_params)) continue;
      buy  = ((int)m_table_indicator.SelectedImageIndex(2, row) == 0);
      sell = ((int)m_table_indicator.SelectedImageIndex(3, row) == 0);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Feeds the SignalMarkers.mq5 indicator: gathers every flip of     |
//| every Buy/Sell-enabled indicator across EVERY tracked TF of the  |
//| CURRENT chart's own symbol (same multi-TF loop RefreshCandleInfo |
//| Window uses for the Ctrl+hover popup) and writes the COMPLETE set|
//| to a bridge file - the indicator replaces its whole row array on |
//| each read, it never merges deltas, so a partial/delta write here |
//| would silently drop markers instead of updating them.            |
//|                                                                    |
//| Cheap early-out: a first pass only checks each signal's NEWEST   |
//| committed flip time (O(indicators), not O(history)) - the full   |
//| collection + file write below only runs when that moved past the |
//| watermark (or the chart's own symbol just changed).              |
//+------------------------------------------------------------------+
void CGUIPannel::BuildAndWriteSignalBridge(void)
  {
   if(m_time_series_engine == NULL || m_IndicatorsCollection == NULL || m_BarTimeSeriesCollection == NULL)
      return;

   string sym = ::Symbol();
   bool fresh = (sym != m_signal_bridge_symbol);

   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;

   datetime newest_seen = 0;
   for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *s = series_list.At(ti);
      if(s == NULL) continue;
      CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, s.Timeframe(), EQUAL);
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
      for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *ind = ind_list.At(ii);
         if(ind == NULL) continue;
         bool buy_on, sell_on;
         if(!TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
         // signal is BORROWED - CSignalsCollection owns it
         CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(signal == NULL) continue;
         int ht = signal.HistoryTotal();
         if(ht > 0)
           {
            datetime t = signal.HistoryTime(ht - 1); // history is oldest->newest
            if(t > newest_seen) newest_seen = t;
           }
         // --- BBands-only: also watch the 3 independent line-cross histories (Anhnt,
         // --- 2026-07-17) - Layer 1 (SignalBands.mqh) keeps them inside the SAME
         // --- CSignalBollinger instance, so this is a safe downcast.
         if(ind.TypeIndicator() == IND_BANDS)
           {
            CSignalBollinger *bb = (CSignalBollinger*)signal;
            for(int li = 0; li < 3; li++)
              {
               int lt = bb.LineHistoryTotal(li);
               if(lt == 0) continue;
               datetime lts = bb.LineHistoryTime(li, lt - 1);
               if(lts > newest_seen) newest_seen = lts;
              }
           }
        }
     }

   if(!fresh && newest_seen <= m_signal_bridge_last_time)
      return; // nothing changed since the last write - skip the full collection+file write

   m_signal_bridge_symbol = sym;

   // --- Full collection: every flip of every Buy/Sell-enabled indicator, every tracked TF.
   datetime row_time[]; int row_tf[]; int row_dir[];
   int count = 0;
   for(int ti = 0; ti < series_total; ti++)
     {
      CBarSeriesDE *s = series_list.At(ti);
      if(s == NULL) continue;
      ENUM_TIMEFRAMES tf = s.Timeframe();
      CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
      for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *ind = ind_list.At(ii);
         if(ind == NULL) continue;
         bool buy_on, sell_on;
         if(!TemplateBuySellFor(ind, buy_on, sell_on) || (!buy_on && !sell_on)) continue;
         CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
         if(signal == NULL) continue;
         int hist_total = signal.HistoryTotal();
         for(int h = 0; h < hist_total; h++)
           {
            ENUM_SIGNAL_DIR dir = signal.HistoryDir(h);
            if(dir == SIGNAL_NONE) continue;
            if(dir == SIGNAL_BUY  && !buy_on)  continue;
            if(dir == SIGNAL_SELL && !sell_on) continue;
            ArrayResize(row_time, count + 1);
            ArrayResize(row_tf,   count + 1);
            ArrayResize(row_dir,  count + 1);
            row_time[count] = signal.HistoryTime(h);
            row_tf[count]   = (int)tf;
            row_dir[count]  = (dir == SIGNAL_BUY) ? 1 : -1;
            count++;
           }
         // --- BBands-only: also feed the Upper/Lower line-cross histories (Anhnt, 2026-07-19)
         // --- as extra rows for the SAME (symbol,tf) - a bar with both a Mid flip (the primary
         // --- signal above) AND an Upper/Lower cross correctly ends up with 2+ rows, which is
         // --- exactly what makes the multi-signal ("Thumb Up/Down") marker shape kick in instead
         // --- of the single arrow. Mid itself is skipped here - it was already added by the
         // --- generic signal.HistoryDir() loop just above; adding it again here would duplicate it.
         if(ind.TypeIndicator() == IND_BANDS)
           {
            CSignalBollinger *bb = (CSignalBollinger*)signal;
            for(int li = 0; li < 3; li++)
              {
               if(li == BBAND_LINE_MID) continue;
               int line_total = bb.LineHistoryTotal(li);
               for(int h = 0; h < line_total; h++)
                 {
                  ENUM_SIGNAL_DIR dir = bb.LineHistoryDir(li, h);
                  if(dir == SIGNAL_NONE) continue;
                  if(dir == SIGNAL_BUY  && !buy_on)  continue;
                  if(dir == SIGNAL_SELL && !sell_on) continue;
                  ArrayResize(row_time, count + 1);
                  ArrayResize(row_tf,   count + 1);
                  ArrayResize(row_dir,  count + 1);
                  row_time[count] = bb.LineHistoryTime(li, h);
                  row_tf[count]   = (int)tf;
                  row_dir[count]  = (dir == SIGNAL_BUY) ? 1 : -1;
                  count++;
                 }
              }
           }
        }
     }

   // --- Sort ascending by time (bubble - count is small, same style used elsewhere in this file).
   for(int a = 0; a < count - 1; a++)
      for(int b = a + 1; b < count; b++)
         if(row_time[b] < row_time[a])
           {
            datetime tm_ = row_time[a]; row_time[a] = row_time[b]; row_time[b] = tm_;
            int      tf_ = row_tf[a];   row_tf[a]   = row_tf[b];   row_tf[b]   = tf_;
            int      d_  = row_dir[a];  row_dir[a]  = row_dir[b];  row_dir[b]  = d_;
           }

   WriteSignalBridgeFile(row_time, row_tf, row_dir, count);
   m_signal_bridge_last_time = newest_seen;
  }
//+------------------------------------------------------------------+
//| Writes the bridge file for m_signal_bridge_symbol - format MUST   |
//| stay byte-identical to SignalMarkers.mq5's reader:                |
//|   int magic_version; long last_update; int row_count;             |
//|   row_count x { long flip_time; int tf; int dir(+1/-1); }          |
//| Written to a .tmp file then FileMove'd over the real name, so the |
//| indicator's own polling never sees a half-written file.           |
//+------------------------------------------------------------------+
void CGUIPannel::WriteSignalBridgeFile(const datetime &row_time[], const int &row_tf[], const int &row_dir[], const int count)
  {
   string final_name = "SignalBridge_" + m_signal_bridge_symbol + ".dat";
   string tmp_name    = "SignalBridge_" + m_signal_bridge_symbol + ".tmp";

   int fh = ::FileOpen(tmp_name, FILE_BIN|FILE_WRITE);
   if(fh == INVALID_HANDLE)
      return;

   ::FileWriteInteger(fh, SIGNAL_BRIDGE_MAGIC, INT_VALUE);
   ::FileWriteLong(fh, (long)::TimeCurrent()); // last_update is a plain rewrite-happened watermark,
                                                // decoupled from m_signal_bridge_last_time's own
                                                // change-detection role - always moves forward.
   ::FileWriteInteger(fh, count, INT_VALUE);
   for(int i = 0; i < count; i++)
     {
      ::FileWriteLong(fh, (long)row_time[i]);
      ::FileWriteInteger(fh, row_tf[i],  INT_VALUE);
      ::FileWriteInteger(fh, row_dir[i], INT_VALUE);
     }
   ::FileClose(fh);

   ::FileMove(tmp_name, 0, final_name, FILE_REWRITE);
  }

#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
