//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//--- Library class for creating the graphical interface             |
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__ 
#include "GUIPannel_Define.mqh"
#include "..\Services\SignalLogger.mqh"
#include "..\Services\SignalBridgeWriter.mqh"
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION   
  class CGUIPannel : public CWndEvents, public ITemplateBuySellProvider
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
       CSignalLogger              m_signal_logger;                     // Signal logger for history and exports
       CSignalBridgeWriter        m_bridge_writer;
       
     //------------------- 
      CTimeCounter                m_gui_timecounter;                   //--- Time counters
      CKeys                       m_keys;                              //For Keyboard
     //For Layer 2 GUI Control Elements  
       //For Main window m_window_main
         CWindow                   m_window_main;
       //For CTreeView left pannel of m_window_main
         CTreeView                 m_treeview_SymbolTF;
         int                       m_sym_tree_pos[];        //To save symbol node list_index       
       // Main Tab on Right of m_window_main
         CTabs                     m_tabs_main;
         //
         //For TAB_TAB_MAIN_TRADE of m_tabs_main
          CTable               m_table_indicator_SymbolTFValue; 
          // per-row dirty-check cache for Trade tab table           
           string               m_string_table_indicator_SymbolTFValue_cache_val[];
           int                  m_int_table_indicator_SymbolTFValue_cache_sig_icon[];
           int                  m_int_table_indicator_SymbolTFValue_cache_dir_icon[];
           int                  m_int_table_indicator_SymbolTFValue_table_row_count;
         //For TAB_TAB_MAIN_POSITIONS at m_tabs_main
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
         //For TAB_TAB_MAIN_SETTINGS at m_tabs_main
          CTabs                      m_tabs_main_setting_config;
           // For controls at TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR at m_tabs_main_setting_config
            // Indicator TreeViews at the Left
              CTreeView                 m_treeview_indicator;
              string                    m_table_indicator_names[];
              int                       m_group_tree_pos[];
              int                       m_type_node_li[];      // list_index của từng node Type (level 1)
              ENUM_INDICATOR            m_type_node_value[];   // ENUM_INDICATOR tương ứng   
            // For Indicator Add Form display on click m_treeview_indicator node
             CTextLabel           m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
             CTextEdit            m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params
             CComboBox            m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
             CButton              m_btn_add_indicator;                         //CButton to Add Indicator
             CButton              m_btn_save_indicator;                        //CButton to Save Indicator to JSON
             ENUM_INDICATOR       m_current_param_type;     // which type the form is currently showing
             int                  m_current_param_type_li;  // its tree list_index (for tree-node insertion later) 
            //for table display indicator template at Layer 1, check box to show/hide on Layer 3 (Chart)
             CTable               m_table_indicator; 
             // row whose delete icon was clicked; executed in OnTimerEvent, NOT inside the click event - 
             // rebuilding the table while CTable is still processing its own click leaves its focus/press indices on freed rows (array out of range in Table.mqh)          
              int                  m_pending_remove_row;
           // For controls at TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF at m_tabs_main_setting_config
            CTable               m_table_indicator_SymbolTFSeting;
            CButton              m_btn_save_SymbolTF;
            CTextLabel           m_label_symboltf_note;   // "takes effect after EA restart" note
            // same deferred-delete pattern as m_pending_remove_row, for m_table_indicator_SymbolTFSeting
             int                  m_pending_remove_row_symboltf;       
           //For controls at TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER at m_tabs_main_setting_config
            // --- 4 independent shapes (each needs its OWN MT5 plot - PLOT_ARROW is a per-plot
            // --- fixed property, not per-bar, so "Single" and "Multi" each need a Buy/Sell PAIR
            // --- of shapes, not one shared shape re-colored - see SignalMarkers.mq5).
             CComboBox            m_combo_shape_single_indicator_buy;
             CComboBox            m_combo_shape_single_indicator_sell;
             CComboBox            m_combo_shape_multi_indicator_buy;
             CComboBox            m_combo_shape_multi_indicator_sell;
             CComboBox            m_combo_shape_pattern_buy;
             CComboBox            m_combo_shape_pattern_sell;
             CComboBox            m_combo_shape_combo_buy;
             CComboBox            m_combo_shape_combo_sell;
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
              CTextLabel           m_label_other_caption[16];
              CTextLabel           m_preview_shape[16];
              CColorButton         m_preview_color[3];
             // --- Current marker style/color state - loaded from Config_Setting.json's "markers" section at startup,
             // --- fed to SignalMarkers.mq5 as iCustom inputs, updated by the Save button above.
              int                  m_marker_single_indicator_buy_code;
              int                  m_marker_single_indicator_sell_code;
              int                  m_marker_multi_indicator_buy_code;
              int                  m_marker_multi_indicator_sell_code;
              int                  m_marker_pattern_buy_code;
              int                  m_marker_pattern_sell_code;
              int                  m_marker_combo_buy_code;
              int                  m_marker_combo_sell_code;
             //For color
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
              //CTextEdit            m_edit_sound_folder;
              //CLabel               m_lbl_sound_folder;
              CTextLabel           m_textLabel_sound_folder;
              CButton              m_btn_refresh_sound_folder;
              CComboBox            m_combo_buy_sound;
              CComboBox            m_combo_sell_sound;
           //-
       //----------
       //For status Bar at Bottom of m_window_main
        CStatusBar                 m_status_bar;
     //---------------
     //For Layer 2 Gui Control
      //CPatternRenderer           *m_renderer;           //EA owns PatternRenderer for display New Patterns
      CTradingLevelBubble         m_trading_bubble;                    // OWNED - self-manages its own lazy-init via EnsureCreated()
       
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
      
      // For guard on GUI.
       bool                       m_gui_created;        // guard thay cho s_gui_ready trong EA 
     // --- Layer-3 observer (README: 3-layer sync). OWNED here. Watches every open chart's
       // --- windows + their indicators and emits CHART_OBJ_EVENT_CHART_WND_IND_ADD/DEL/CHANGE,
       // --- so Layer 2 keeps its "Show" column truthful even when the user adds/removes an
       // --- indicator BY HAND on the chart. Styling (colors) is out of scope by design - MT5
       // --- has no API to restyle an indicator instance that is already attached to a chart.
        CChartObjCollection       m_chart_obj_collection;
      
     
        // Settings table col-4 "Show" dirty cache - parallel with m_table_indicator_ptrs
         int                  m_settings_cache_state[];

       // --- Signal Markers bridge (BugNote 2026-07-16): a separate SignalMarkers.mq5
      // SIndicatorCatalogItem now lives in Artyom Trishkin\IndicatorCatalog.mqh (Tang 1 metadata)      
       // --- Params tab controls (generic fixed-slot form, max 4 params/indicator)
            
    private: // Private methods
     //For GUI
       bool                            CreateGUIPannel(); 
     //--- Form
         int                           WindowIdx(CWindow &wnd);
      //For m_window_main
         bool                          CreateMainWindow(const string text);
       // Symbol TF TreeView m_treeview_SymbolTF        
        bool                          CreateTreeView_SymbolTF(const int x_gap, const int y_gap);               
        void                          PopulateSymbolTFTree(void);
        void                          SynSymbolTFTreeViewIcons(void);
       // For Main Tab
         bool                          CreateTab_Main(const int x_gap, const int y_gap);
       //--- Status bar
         bool                          CreateStatusBar(const int x_gap, const int y_gap);
         bool                          UpdateStatusBar(void);
         
      //
     // For candle info popup (BugNote 7.2: Ctrl+hover -> Signal direction per indicator at that bar)
         bool                          CreateWindowCandleInfo(void);
         bool                          RefreshCandleInfoWindow(const datetime bar_time);
         bool                          MouseOverCandleInfoWindow(void);
         void                          RepositionCandleInfoWindow(const int cursor_x, const int cursor_y);
         void                          ShowCandleInfoPopup(const int cursor_x, const int cursor_y);
         void                          HideCandleInfoPopup(void);
     // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS
         bool                          CreateTabSettingConfig(const int x_gap, const int y_gap);     
      //For TreeView m_treeview_indicator on Left Pannel
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
         bool                         CreateTabbleIndicator(const int x, const int y);         
         void                         RefreshTableIndicator(void);         
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
         bool                         CreateTableIndicatorSymbolTFValue(const int x, const int y);
         void                         SetValuesToTableIndicatorSymbolTFValue(void);
         string                       BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[]);
         void                         PurgeSignalArrowObjects(const string sym, const string tf_string);
       //For Pre-Trade-Plan area (TAB_TAB_MAIN_POSITIONS), sits above m_table_positions - symbol
       //picker + single-row order-setup table. Skeleton only (Anhnt 2026-07-20): Buy/Sell cells
       //are plain CELL_BUTTON placeholders, NOT wired to send real orders yet - that needs the
       //Distance(Fixed/ATR) and Lot(Manual/Risk%) mode toggles first (separate ButtonsGroup
       //controls, not declared yet) to actually compute a price/lot worth sending.
         bool                         CreatePreTradePlanSymbolCombo(const int x, const int y);
         bool                         CreatePreTradePlanControls(const int x, const int y);
         bool                         CreateTablePreTradePlan(const int x, const int y);
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
         void                         SaveMarkerSettingsToJSON(void);
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
        // ITemplateBuySellProvider implementation
        bool                           TemplateBuySellFor(CIndicatorDE *ind, bool &buy, bool &sell);
      //For Pointer      
        void                           SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbol_collection = symbols; }      
        void                           SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_BarTimeSeriesCollection = ts; m_bridge_writer.Initialize(this, m_time_series_engine, m_IndicatorsCollection, m_BarTimeSeriesCollection); } 
        void                           SetPatternsControl(CBarPatternsControl* ctrl) { m_pattern_cfg = ctrl; } 
        void                           SetIndicatorsCollection(CIndicatorsCollection *ind) { m_IndicatorsCollection = ind; m_bridge_writer.Initialize(this, m_time_series_engine, m_IndicatorsCollection, m_BarTimeSeriesCollection); }
        void                           SetTimeSeriesEngine(CTimeSeriesEngine *engine) { m_time_series_engine = engine; m_bridge_writer.Initialize(this, m_time_series_engine, m_IndicatorsCollection, m_BarTimeSeriesCollection); }
      //Temporary remove due to change
        //void  SetPatternRenderer(CPatternRenderer* renderer) { m_renderer = renderer; }
        //void  SetTickSeriesCollection(CTickSeriesCollection *ticks) { m_tick_series = ticks; }
        void  SetMarketCollection(CMarketCollection *market)      { m_trading_bubble.SetMarketCollection(market); }
        void  SetTradingControl(CTradingControl *trading_control) { m_trading_bubble.SetTradingControl(trading_control); }
   };
#endif // CGUIPANNEL_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
//For implementation seperation in module
 #include "GUIPannel_Lifecycle.mqh"
 #include "GUIPannel_MainWindows.mqh" 
 #include "GUIPannel_TabMonitor.mqh"
 //#include "GUIPannel_TabTrade.mqh" 
 #include "GUIPannel_TabPosition.mqh" 
 #include "GUIPannel_TabSetting.mqh"    
 #include "GUIPannel_CandleInfoWindow.mqh" 
// ----------------   
  //Helper for OnClickSaveIndicators() and OnClickSaveSymbolTF() and  
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
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
