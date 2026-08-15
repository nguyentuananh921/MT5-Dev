//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//--- Library class for creating the graphical interface             |
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__ 
#include "GUIPannel_Define.mqh"
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
  extern string g_ea_folder;  // From EA
  class CGUIPannel : public CWndEvents
   {
    private:
      CNewBarObj                  m_newbar;                            //--- NewBar detector
      CTimeCounter                m_gui_timecounter;                   //--- Time counters
      CKeys                       m_keys;                              //For Keyboard
     //Layer 1 Pure Data
      // Private Pointer variables    
       CSymbolsCollection         *m_symbol_collection;                //CTradingEngine owns
       CBarTimeSeriesCollection   *m_BarTimeSeriesCollection;          //CBarTimeSeriesCollection owns      
       CBarPatternsControl        *m_BarPatterns_Control;              // borrowed from EA
       CIndicatorsCollection      *m_IndicatorsCollection;             // CTimeSeriesEngine owns
       CTimeSeriesEngine          *m_time_series_engine;               // EA owns - Tang 1 entry point for AddIndicatorInstance
       CTickSeriesCollection      *m_tick_series;                      // Collection of tick series      
       CIndicatorDE               *m_table_indicator_ptrs[];           // BORROWED per-row pointers - CIndicatorsCollection owns them; rebuilt on every SetValuesToIndicatorTable, so never delete through these 
     //For Layer 2 GUI Control Elements  
      //For Main window m_window_main implementation in GUIPannel_MainWindows.mqh
        CWindow                   m_window_main;
       //For CTreeView left pannel of m_window_main 
        CTreeView                 m_treeview_SymbolTF;
       // Main Tab on Right of m_window_main
        CTabs                     m_tabs_main;
       //For status Bar at Bottom of m_window_main
        CStatusBar                m_status_bar;
      //For TAB_TAB_MAIN_MONITOR of m_tabs_main implementation in GUIPannel_TabMonitor.mqh
        CTable                    m_table_indicator_SymbolTFValue; 
       // per-row dirty-check cache for Trade tab table           
        string                    m_string_table_indicator_SymbolTFValue_cache_val[];
        int                       m_int_table_indicator_SymbolTFValue_cache_sig_icon[];
        int                       m_int_table_indicator_SymbolTFValue_cache_dir_icon[];
        int                       m_int_table_indicator_SymbolTFValue_table_row_count;
      //For TAB_TAB_MAIN_POSITIONS at m_tabs_main implementation in GUIPannel_TabPositions.mqh
        CComboBox                 m_combo_pre_Trade_plan_symbol;
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
      //For TAB_TAB_MAIN_SETTINGS configuration at m_tabs_main implemenation in GUIPannel_TabSettingIndicator.mqh
       CTabs                      m_tabs_main_setting_config;       
       // Indicator TreeViews at the Left
         CTreeView                 m_treeview_indicator;
         string                    m_table_indicator_names[];         
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
       //Table to display indicator template at Layer 1, check box to show/hide on Layer 3 (Chart)         
         CTable               m_table_indicator_template;
         // Settings table col-4 "Show" dirty cache - parallel with m_table_indicator_ptrs
           int                m_settings_cache_state[];
       // row whose delete icon was clicked; executed in OnTimerEvent, NOT inside the click event - 
       // rebuilding the table while CTable is still processing its own click leaves its focus/press indices on freed rows (array out of range in Table.mqh)
         int                  m_pending_remove_row;
      //TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF at m_tabs_main_setting_config implementation in GUIPannel_TabSettingSymbolTF.mqh
         CTable               m_table_indicator_SymbolTFSeting;
         CButton              m_btn_save_SymbolTF;
         CTextLabel           m_label_symboltf_note;   // "takes effect after EA restart" note
        // same deferred-delete pattern as m_pending_remove_row, for m_table_indicator_SymbolTFSeting
         int                  m_pending_remove_row_symboltf;
      //TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN implementation in GUIPannel_TabSettingCandlePattern.mqh
         CTable               m_table_CandlePatternsSetting;         
         ENUM_PATTERN_TYPE    m_pattern_types[];
         string               m_pattern_display_names[]; 
         CButton              m_btn_save_pattern_config;      
      //For controls at TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER at m_tabs_main_setting_config implementation in GUIPannel_TabSettingMarker.mqh
       //For Marker 8 independent shapes to display at each Candle on Chart see SignalMarkers.mq5        
         CComboBox            m_combo_shape_single_indicator_buy;  //candle only have single indicator, buy or sell base on indicator signal
         CComboBox            m_combo_shape_single_indicator_sell; //candle only have single indicator, buy or sell base on indicator signal
         CComboBox            m_combo_shape_multi_indicator_buy;   //candle have multi indicator, buy or sell base on indicator signal
         CComboBox            m_combo_shape_multi_indicator_sell;  //candle have multi indicator, buy or sell base on indicator signal
         CComboBox            m_combo_shape_pattern_buy;           //candle only have pattern, buy or sell base on pattern signal
         CComboBox            m_combo_shape_pattern_sell;          //candle only have pattern, buy or sell base on pattern signal
         CComboBox            m_combo_shape_combo_buy;             //candle have combo of indicator and pattern, buy or sell base on combo signal
         CComboBox            m_combo_shape_combo_sell;            //candle have combo of indicator and pattern, buy or sell base on combo signal
        // Current marker style/color state - loaded from Config_Setting.json's "markers" section at startup,
        // Fed to SignalMarkers.mq5 as iCustom inputs, updated by the Save button above.
         int                  m_marker_single_indicator_buy_code;
         int                  m_marker_single_indicator_sell_code;
         int                  m_marker_multi_indicator_buy_code;
         int                  m_marker_multi_indicator_sell_code;
         int                  m_marker_pattern_buy_code;
         int                  m_marker_pattern_sell_code;
         int                  m_marker_combo_buy_code;
         int                  m_marker_combo_sell_code;
        // For color Marker have 3 colors, independent of shape: Buy/Sell apply when a marker relates to this        
         CComboBox            m_combo_color_buy;           //color of buy marker
         CComboBox            m_combo_color_sell;          //color of sell marker
         CComboBox            m_combo_color_nonrelated;    //color of non-related marker
         //For color
          color                m_marker_buy_color;          //color of buy marker
          color                m_marker_sell_color;         //color of sell marker
          color                m_marker_nonrelated_color;   //color of non-related marker
        //For button Save marker setting
         CButton              m_btn_save_marker_settings;
        // --- Other tab captions/previews - index 0-3 = shape rows (Single Buy/Sell, Multi
        // --- Buy/Sell), index 0-2 of the color arrays = Buy/Sell/Non-Related. Preview labels
        // --- render the ACTUAL Wingdings glyph (Font("Wingdings") + the raw char code) so the
        // --- user sees the real shape, not just a number; color previews reuse CColorButton's
        // --- own swatch rendering, just never wired to a click handler (display-only).
         CTextLabel           m_label_other_caption[16];
         CTextLabel           m_preview_shape[16];
         CColorButton         m_preview_color[3];       
        
         //string               m_marker_sound_folder;
         string               m_marker_buy_sound_file;
         string               m_marker_sell_sound_file;        
         CTextLabel           m_textLabel_sound_folder;         
         CComboBox            m_combo_buy_sound;
         CComboBox            m_combo_sell_sound;
      //Information window at to display signal on chart
       CWindow                    m_window_candle_infomation;
       CTable                     m_table_candle_information_atBar;
       datetime                   m_candle_info_shown_bar;             // 0 = window currently hidden
       CBarPattern                *m_pattern_bitmap_shown;             // pattern whose CGCnvPatternBitmap is visible via Alt+hover, NULL = none
       int                        m_pattern_bitmap_scale;              // CHART_SCALE the shown bitmap was built at - forces rebuild on zoom change
      //For use in GUIPannel_SoundAndMessageAlerts.mqh
       //For indicator
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
       //For candle at bar 0 [timeframe_index][pattern_type]track last state per pattern type
        ENUM_PATTERN_DIRECTION     m_candle_pattern_last_seen[];
        // --- CloseBar-only (Anhnt, 2026-08-11): unlike Indicator (SignalBase.mqh's
        // --- CommitClosedBar/SyncHistory already only ever record a TRUE flip - never the same
        // --- direction twice in a row), CBarPattern/GetListAllPatterns() lists EVERY detected
        // --- pattern occurrence with no such guard - 2 consecutive Bullish hits of the same
        // --- pattern type are 2 real, separate entries. Message/CSV still logs every one
        // --- (patterns ARE legitimately episodic, not a continuous state) - but Sound should
        // --- only fire when direction actually changed vs the last CloseBar-committed one for
        // --- this (pattern type, TF), same principle as Indicator already gets for free. Same
        // --- ti*pattern_count+row indexing as m_candle_pattern_last_seen, but NEVER reset on
        // --- new-bar (that reset is Live-path-only) - this tracks history, not the live bar.
        ENUM_PATTERN_DIRECTION     m_candle_pattern_closebar_last_dir[];
        // --- CloseBar Sound dedup gate (Anhnt, 2026-08-11): correlated indicators (BBands/PSAR/
        // --- AMA...) or Indicator+CandlePattern together can flip on the SAME closed bar - each
        // --- flip is individually valid (Message/CSV still logs every one), but ::PlaySound()
        // --- calls fired back-to-back within one pass interrupt each other (1 shared OS sound
        // --- channel). A single closed bar can also carry MANY Pattern hits at once - picking
        // --- Buy/Sell per event just meant more dedup state for no benefit, since CloseBar
        // --- Sound's whole job is "something closed, go look" (the actual Buy/Sell/what is
        // --- already in Message/CSV). So CloseBar plays ONE fixed file (NewBar.wav) instead of
        // --- Buy/Sell-specific, gated by THIS single flag - checked-and-set INLINE, immediately,
        // --- at the first CloseBar flip seen this pass (NOT deferred to the end of OnTickEvent -
        // --- that was tried and reliably stomped any Live sound that had already played earlier
        // --- the same pass, since NewBar.wav would then always fire last - see
        // --- FeatureNote/SoundBugNote.md). Reset false at the top of OnTickEvent.
        //bool                       m_closebar_sound_played;
     // Layer-3 observer (README: 3-layer sync). OWNED here. Watches every open chart's
     // --- windows + their indicators and emits CHART_OBJ_EVENT_CHART_WND_IND_ADD/DEL/CHANGE,
     // --- so Layer 2 keeps its "Show" column truthful even when the user adds/removes an
     // --- indicator BY HAND on the chart. Styling (colors) is out of scope by design - MT5
     // --- has no API to restyle an indicator instance that is already attached to a chart.
      CChartObjCollection       m_chart_obj_collection;            
     //Layer 4 IO File Signal Markers bridge a separate SignalMarkers.mq5 
        CSignalLogger              m_signal_logger;                     // Signal logger for history and exports
        CSignalBridgeWriter        m_bridge_writer;
        bool                       m_signal_log_watermarks_loaded; 
     // For guard on GUI.
       bool                       m_gui_created;        // guard thay cho s_gui_ready trong EA 
     //CPatternRenderer           *m_renderer;           //EA owns PatternRenderer for display New Patterns
      CTradingLevelBubble         m_trading_bubble;                    // OWNED - self-manages its own lazy-init via EnsureCreated()
    private: 
     //For Main Window m_window_main Implementation in GUIPannel_MainWindow.mqh
      bool                            CreateMainWindow(const string text);
      // For Symbol TF TreeView m_treeview_SymbolTF on Left Pannel of m_window_main
       bool                           CreateTreeView_SymbolTF(const int x_gap, const int y_gap);               
       void                           PopulateSymbolTFTree(void);
       void                           SynSymbolTFTreeViewIcons(void);
      // For Main Tab on the right of Main Window m_window_main
       bool                           CreateTab_Main(const int x_gap, const int y_gap);
      // For Status bar on the bottom of m_window_main
       bool                           CreateStatusBar(const int x_gap, const int y_gap);
       bool                           UpdateStatusBar(void);     
     //For GUI implemented in in GUIPannel_Lifecycle.mqh
      int                             WindowIdx(CWindow &wnd);
      bool                            CreateGUIPannel();      
     //Calculation for multi module implemented in GUIPannel_MultiModule.mqh 
      double                          DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0);               
      // //For indicator
      //   void                         BuildTemplateMatchKey(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[], string &type_key, string &params_key);
      //   string                       BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[]);
     // For m_table_indicator_SymbolTFValue implemented in GUIPannel_TabMonitor.mqh     
        bool                         CreateTableIndicatorSymbolTFValue(const int x, const int y);
        void                         SetValuesToTableIndicatorSymbolTFValue(void);
     // For TAB_TAB_MAIN_POSITIONS implementation in GUIPannel_TabPosition.mqh
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
        bool                         CreateTablePositions(const int x_gap, const int y_gap);
        void                         InitializePositionsTable(void);
        bool                         SetValuesToPositionsTable(string &symbols_name[], bool force = false);
        bool                         IsLastDealTicket(void);
        int                          GetPositionsSymbols(string &symbols_name[]);
        double                       PositionAveragePrice(const string symbol);
        int                          PositionsTotal(const string symbol);
        double                       PositionsVolumeTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE);
        double                       PositionsFloatingProfitTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE);
     //For Candle info popup Implementation in GUIPannel_CandleInfoWindow.mqh 
       bool                          MouseOverCandleInfoWindow(void);
       void                          RepositionCandleInfoWindow(const int cursor_x, const int cursor_y);
       void                          ShowCandleInfoPopup(const int cursor_x, const int cursor_y);
       void                          HideCandleInfoPopup(void);
       bool                          CreateWindowCandleInfo(void);
       bool                          RefreshCandleInfoWindow(const datetime bar_time);
       void                          ShowPatternBitmapAtBar(const datetime bar_time);
       void                          ShowPatternHoverLabel(CBarPattern *pat);
       void                          HidePatternBitmapShown(void);
     //For working with SignalMarker.mq5 implementation in GUIPannel_SignalMarkers.mqh
        void                         EnsureMarkerIndicatorAttached(void);
        void                         ReattachSignalMarkersIndicator(void);
        void                         RemoveMarkerIndicator(void); 
     //For working with JSON implementation in GUIPannel_JSONConfig.mqh
         void                         SaveGUIConfigToJSON(void);
         void                         SavePatternAlertConfigToJSON(void);
         void                         SaveMarkerSettingsToJSON(void);
        //For Load 
         void                         LoadPatternAlertConfigFromJSON(void);         
         void                         LoadMarkerSettingsFromJSON(void);   
     //Implementation in GUIPannel_SoundAndMessageAlerts.mqh
      //Per-indicator Sound/Message opt-in (m_table_indicator col 5/6) - fires on a genuinely NEW Signal
       void                         CheckIndicatorAlerts(void);
       void                         CheckCandlePatternAlerts(void);
      //Buy/Sell .wav lookup + play - Live-only (Anhnt, 2026-08-14): resolves against
      //TERMINAL_PATH\Sounds\ only (see FeatureNote/SoundBugNote.md). CloseBar plays a fixed
      //NewBar.wav instead via PlaySoundCloseBar, not Buy/Sell-specific.
       void                         PlaySoundForDirection(const bool is_buy);
       void                         PlaySoundCloseBar(void);
       int                          GetPatternCandleCount(ENUM_PATTERN_TYPE pattern_type);
       ENUM_PATTERN_DIRECTION       CheckPatternLive(ENUM_PATTERN_TYPE pattern_type, MqlRates &rates, CBarPatternControl *ctrl);
       ENUM_PATTERN_DIRECTION       DetectPatternOnBar0(ENUM_PATTERN_TYPE pattern_type, ENUM_TIMEFRAMES tf, MqlRates &bar_0_temp);
      //BBands-only: one independent line's real persisted history (CSignalBollinger::LineXxx) -
      //Closed=log-only+own watermark, Live=Message+CSV (no Sound) - see CheckIndicatorAlerts
       void                         ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name, ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key, const string label, const string tf_text, const int digits);
     // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS implementation GUIPannel_TabSettingIndicator.mqh    
       bool                          CreateTabSettingConfig(const int x_gap, const int y_gap);
       //For TreeView m_treeview_indicator on Left Pannel
        bool                          CreateTreeView_Indicator(const int x_gap, const int y_gap);
        void                          PopulateIndicatorTree(void);
        void                          SyncIndicatorTreeViewIcons(void);
       //For Indicator Table m_table_indicator at bottom show list of indicator in template.
        bool                         CreateTabbleIndicator(const int x, const int y);
        void                         RefreshTableIndicator(void);
        void                         SetIndicatorTableRow(const int row, CIndicatorDE *indicator);
        void                         RefreshIndicatorTableShowColumn(void);
       //For Indicator Add, ParaInfor at top of m_tabs_main_setting_config
         //Helper
          static void                  SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw);
          int                          GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[]);
         //Handler for TreeView m_treeview_indicator.
          void                         ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li);
          void                         HideParamSlots(void);
          void                         OnClickAddIndicator(void);
          bool                         CreateAddIndicatorParaInfor(const int x_gap, const int y_gap); 
          void                         AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[]);
      // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS implementation GUIPannel_TabSettingIndicator.mqh            
      //For TreeView m_treeview_indicator on Left Pannel  
       //Handler for TreeView m_treeview_indicator.                  
      //For Indicator Table m_table_indicator 
         bool                         IsIndicatorShownOnChart(CIndicatorDE *indicator);
         bool                         LineRepresentsIndicator(const int line_handle, CIndicatorDE *indicator);
         CIndicatorDE                 *OwnedInstanceOfLine(const int line_handle);
         void                         DetachIndicatorFromChart(CIndicatorDE *indicator);
         void                         ImportForeignChartIndicators(void);         
         void                         ApplyLoadedIndicatorBuySell(void);
         void                         PurgeSignalArrowObjects(const string sym, const string tf_string);
     //----Unfininished         
       //For Symbol/TF Setting Table m_table_indicator_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
         bool                         CreateTableSymbolTFSetting(const int x, const int y);
         void                         PopulateTableSymbolTFSetting(void);
         bool                         HasTableSymbolTFSettingRow(const string sym, const string tf_text);
         void                         SetTableSymbolTFSettingRow(const int row, const string sym, const string tf_text);
         bool                         IsCurrentChartSymbolTFRow(const string sym, const string tf_text);
         void                         SyncTableSymbolTFSettingCurrentChartIcon(void);
         void                         ApplyLoadedSymbolTFSettings(void);         
         void                         BuildSymbolTFBuySellArrays(string &symbols[], string &tfs[], bool &buys[], bool &sells[]);
         void                         OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col);     
       
       //TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN implementation in GUIPannel_TabSettingCandlePattern.mqh
         //void                         DiscoverPatterns(void);
         void                         BuildCandlePatternListFromRegistry(void);
         void                         RegisterPatterns(void);
         void                         InitializeTableCandlePatternSetting(void);
         bool                         CreateTableCandlePatternSetting(const int x, const int y);         
       //For TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER - marker shape/color settings for SignalMarkers.mq5 
       // Implementation in GUIPannel_TabSettingMarker.mqh       
         bool                         CreateTabSettingConfig_Marker(const int x, const int y);
         bool                         CreateMarkerTabComboBox(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index);
         bool                         CreateMarkerTabCaption(const int row, const string text, const int x, const int y);
         bool                         CreateShapePreview(const int row, const int x, const int y, const int arrow_code);
         bool                         CreateColorPreview(const int row, const int x, const int y, const color clr);
         void                         UpdateShapePreview(const int row, const int arrow_code);
         void                         UpdateColorPreview(const int row, const color clr);
         void                         GetMarkerArrowCodeChoices(int &codes[], string &labels[]);
         void                         GetMarkerColorChoices(color &colors[], string &labels[]);
        // --- Round-trip helpers so Config_Setting.json stores human-readable labels
        // --- ("83 Bomb", "Dodger Blue") instead of raw Wingdings codes/color ints - looks up
        // --- against the SAME catalogs above, so the JSON always matches what the combo shows.
         string                       ArrowLabelForCode(const int code);
         int                          ArrowCodeForLabel(const string label, const int default_code);
         string                       ColorLabelForValue(const color clr);
         color                        ColorForLabel(const string label, const color default_color);
        //For Buy/Sell alert sound file pickers (Marker tab) - plain combobox, folder scanned via FileFindFirst
         void                         ScanSoundFolder(string &files[]);
         //void                         OnClickChangeSoundFolder(void);
       //Event Handler for m_table_indicator
        void                          OnClickToggleShowIndicatorOnChart(const string sname, const int row);
        void                          OnClickToggleBuySignal(const string sname, const int row);
        void                          OnClickToggleSellSignal(const string sname, const int row);
        void                          OnClickRemoveIndicator(const string sname, const int row);  
        void                          HandleChartIndicatorChange(void);
     
    public:
     // Lifecycle method implemented in GUIPannel_Lifecycle.mqh
                                      CGUIPannel(void);
                                      ~CGUIPannel(void);
      bool                           OnInitEvent(const int uninit_reason = REASON_PROGRAM);
      void                           OnDeinitEvent(const int reason);
      void                           OnTimerEvent(void);
      void                           OnTickEvent(void);
      void                           OnTradeEvent(void);   // ported from V1 - refreshes m_table_positions on a genuinely new deal
      virtual void                   OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
      //For GUI
       void                          UpdateGUI(const bool redraw = false);        
       CWindow *                     GetMainWindowPointer(void) { return &m_window_main; }
     // For Pointer SetPointer     
       void                           SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbol_collection = symbols; }      
       void                           SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_BarTimeSeriesCollection = ts;} 
       void                           SetPatternsControl(CBarPatternsControl* ctrl) { m_BarPatterns_Control = ctrl; } 
       void                           SetIndicatorsCollection(CIndicatorsCollection *ind) { m_IndicatorsCollection = ind;}
       void                           SetTimeSeriesEngine(CTimeSeriesEngine *engine) { m_time_series_engine = engine;}
       void                           SetMarketCollection(CMarketCollection *market)      { m_trading_bubble.SetMarketCollection(market); }
       void                           SetTradingControl(CTradingControl *trading_control) { m_trading_bubble.SetTradingControl(trading_control); }
     //----------------------------------
     //void  SetPatternRenderer(CPatternRenderer* renderer) { m_renderer = renderer; }
       //void  SetTickSeriesCollection(CTickSeriesCollection *ticks) { m_tick_series = ticks; }             
     //For Layer 4 Working with file        
      void UpdateSignalBridgeTemplateFlags(void);
     // ITemplateBuySellProvider implementation
      bool                           TemplateBuySellFor(CIndicatorDE *ind, bool &buy, bool &sell); 
   };
#endif // CGUIPannel_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
//For implementation seperation in module
 #include "GUIPannel_Lifecycle.mqh"   //Implementation of Init, Deinit and other lifecycle events
 #include "GUIPannel_JSONConfig.mqh"  //Implementation of JSON config and save setting of GUI Pannel
 #include "GUIPannel_MultiModule.mqh" //Implementation of function using in multi module GUI Pannel
 #include "GUIPannel_MainWindows.mqh" //Implementation of function Main Windows m_window_main
 #include "GUIPannel_TabMonitor.mqh"  
 #include "GUIPannel_TabPositions.mqh" 
 #include "GUIPannel_TabSettingSymbolTF.mqh" 
 #include "GUIPannel_TabSettingIndicator.mqh" 
 #include "GUIPannel_TabSettingCandlePattern.mqh"
 #include "GUIPannel_TabSettingMarker.mqh"    
 #include "GUIPannel_CandleInfoWindow.mqh" //Implementation of function Candle Info Window m_window_candle_infomation
 #include "GUIPannel_SoundAndMessageAlerts.mqh"
 #include "GUIPannel_SignalMarkers.mqh"
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
      buy  = ((int)m_table_indicator_template.SelectedImageIndex(2, row) == 0);
      sell = ((int)m_table_indicator_template.SelectedImageIndex(3, row) == 0);
      return true;
     }
   return false;
  }
 void CGUIPannel::UpdateSignalBridgeTemplateFlags(void)
  {
    int tmpl_total = ArraySize(m_table_indicator_ptrs);
    CIndicatorDE *tmpl_ptrs[];
    bool tmpl_buy[], tmpl_sell[];

    ArrayResize(tmpl_ptrs, tmpl_total);
    ArrayResize(tmpl_buy,  tmpl_total);
    ArrayResize(tmpl_sell, tmpl_total);

    for(int row = 0; row < tmpl_total; row++)
     {
      tmpl_ptrs[row] = m_table_indicator_ptrs[row];
      tmpl_buy[row]  = ((int)m_table_indicator_template.SelectedImageIndex(2, row) == 0);
      tmpl_sell[row] = ((int)m_table_indicator_template.SelectedImageIndex(3, row) == 0);
     }
    m_bridge_writer.SetTemplateBuySell(tmpl_ptrs, tmpl_buy, tmpl_sell);
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
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
