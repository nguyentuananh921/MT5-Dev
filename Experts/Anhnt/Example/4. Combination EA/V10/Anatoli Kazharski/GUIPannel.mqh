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
      CTimeCounter                m_gui_timecounter;                   //--- Time counters - configured (SetParameters) but not consumed anywhere yet
      CKeys                       m_keys;                              //For Keyboard
      bool                        m_gui_created;                       // guard thay cho s_gui_ready trong EA
     // Private Pointer variables
        CSymbolsCollection         *m_symbol_collection;                // CTradingEngine owns
        CBarTimeSeriesCollection   *m_BarTimeSeriesCollection;          // CBarTimeSeriesCollection owns
        CBarPatternsControl        *m_BarPatterns_Control;              // borrowed from EA
        CIndicatorsCollection      *m_IndicatorsCollection;             // CTimeSeriesEngine owns
        CTimeSeriesEngine          *m_timeSeriesEngine;                 // EA owns  
        CTradingEngine             *m_tradingEngine;                    // EA owns 
     // For Layer 2 GUI Control Elements implementation in GUIPannel_MainWindows.mqh
        CWindow                    m_window_main;
        CStatusBar                 m_status_bar;
        CMenuBar                   m_menu_bar;
      // Main Tabs
        CTabs                      m_tabs_main;
        // For table 
            CTable                    m_table_indicator_SymbolTFMonitor; 
          // per-row dirty-check cache for Trade tab table           
            string                    m_string_table_indicator_SymbolTFMonitor_cache_val[];
            int                       m_int_table_indicator_SymbolTFMonitor_cache_sig_icon[];
            int                       m_int_table_indicator_SymbolTFMonitor_cache_dir_icon[];
            int                       m_int_table_indicator_SymbolTFMonitor_table_row_count;

     // For Layer 2 GUI Control Elements implementation in GUIPannel_SettingWindows.mqh
        CWindow                    m_window_setting;
       // For Tab m_tabs_main_setting_config
        CTabs                      m_tabs_main_setting_config;
       //For Indicator Template Setting 
        // TreeView on the left for Indicator Template
          CTreeView                m_treeview_indicator;
          int                      m_type_node_li[];      // list_index for Type of indicator
          ENUM_INDICATOR           m_type_node_value[];   //  ENUM_INDICATOR for Type of indicator
          bool                     m_treeview_indicator_need_sync; //Dirty flag for m_treeview_indicator
          bool                     m_table_indicator_need_sync; //Dirty flag for m_table_indicator_template
        // For Indicator Add Form display on click m_treeview_indicator node
         CTextLabel                 m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
         CTextEdit                  m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params
         CComboBox                  m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
         CButton                    m_btn_add_indicator;                         //CButton to Add Indicator
         CButton                    m_btn_save_indicator;                        //CButton to Save Indicator to JSON
         ENUM_INDICATOR             m_current_param_type;     // which type the form is currently showing
        //For Table at Bottom of the Form, Table m_table_indicator_template
         CTable                     m_table_indicator_template; 
         int                        m_pending_remove_row; //Mark row for delete
       //For Symbol/TF Setting
        // For CTreeView on the Left pannel of the Symbol TF Setting
         CTreeView                   m_treeview_SymbolTF;
        // Table m_table_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
         CTable                      m_table_SymbolTFSeting;
         CButton                     m_btn_save_SymbolTF;
         bool                        m_treeview_symboltf_need_sync; //Dirty flag for m_treeview_SymbolTF
         // (sym,tf) whose delete icon was clicked - same deferred-delete pattern as
         // m_pending_remove_row, but stores identity (not a physical row position) captured
         // right at click time, so it can never go stale even if the table gets re-sorted
         // between the click and the deferred OnTimerEvent processing.
          string                      m_pending_remove_sym_symboltf;
          string                      m_pending_remove_tf_symboltf;
       //For Candle Pattern Setting at Setting Windows
         CTable                      m_table_CandlePatternsSetting;
         // --- Type, display name, Buy/Sell/Sound/Message all live on CBarPatternControl itself
         // --- (m_BarPatterns_Control.GetListControls()) - no parallel arrays here at all
         // --- (Anhnt, 2026-08-29).
         CButton                     m_btn_save_pattern_config;
       //For Marker 8 independent shapes to display at each Candle on Chart see SignalMarkers.mq5        
         CComboBox           m_combo_shape_single_indicator_buy;  //candle only have single indicator, buy or sell base on indicator signal
         CComboBox           m_combo_shape_single_indicator_sell; //candle only have single indicator, buy or sell base on indicator signal
         CComboBox           m_combo_shape_multi_indicator_buy;   //candle have multi indicator, buy or sell base on indicator signal
         CComboBox           m_combo_shape_multi_indicator_sell;  //candle have multi indicator, buy or sell base on indicator signal
         CComboBox           m_combo_shape_pattern_buy;           //candle only have pattern, buy or sell base on pattern signal
         CComboBox           m_combo_shape_pattern_sell;          //candle only have pattern, buy or sell base on pattern signal
         CComboBox           m_combo_shape_combo_buy;             //candle have combo of indicator and pattern, buy or sell base on combo signal
         CComboBox           m_combo_shape_combo_sell;            //candle have combo of indicator and pattern, buy or sell base on combo signal
        // Current marker style/color state - loaded from Config_Setting.json's "markers" section at startup,
        // Fed to SignalMarkers.mq5 as iCustom inputs, updated by the Save button above.
         int                 m_marker_single_indicator_buy_code;
         int                 m_marker_single_indicator_sell_code;
         int                 m_marker_multi_indicator_buy_code;
         int                 m_marker_multi_indicator_sell_code;
         int                 m_marker_pattern_buy_code;
         int                 m_marker_pattern_sell_code;
         int                 m_marker_combo_buy_code;
         int                 m_marker_combo_sell_code;
        // --- Other tab captions/previews - index 0-3 = shape rows (Single Buy/Sell, Multi
        // --- Buy/Sell), index 0-2 of the color arrays = Buy/Sell/Non-Related. Preview labels
        // --- render the ACTUAL Wingdings glyph (Font("Wingdings") + the raw char code) so the
        // --- user sees the real shape, not just a number; color previews reuse CColorButton's
        // --- own swatch rendering, just never wired to a click handler (display-only).
         CTextLabel          m_label_other_caption[16];
         CTextLabel          m_preview_shape[16];
         CColorButton        m_preview_color[3];
        // For color Marker have 3 colors, independent of shape: Buy/Sell apply when a marker relates to this        
         CComboBox           m_combo_color_buy;           //color of buy marker
         CComboBox           m_combo_color_sell;          //color of sell marker
         CComboBox           m_combo_color_nonrelated;    //color of non-related marker
        //For color
         color               m_marker_buy_color;          //color of buy marker
         color               m_marker_sell_color;         //color of sell marker
         color               m_marker_nonrelated_color;   //color of non-related marker
        //For button Save marker setting
         CButton             m_btn_save_marker_settings;        
       //For Sound tab - Buy/Sell alert sound file pickers, own tab (split away from Marker)
         string              m_marker_buy_sound_file;
         string              m_marker_sell_sound_file;
         CTextLabel          m_textLabel_sound_folder;
         CComboBox           m_combo_buy_sound;
         CComboBox           m_combo_sell_sound;
         CButton             m_btn_save_sound_settings;
       //Information window at to display signal on chart
         CWindow               m_window_candle_infomation;
         CTable                m_table_candle_information_atBar;
         datetime              m_candle_info_shown_bar;             // 0 = window currently hidden
         int                   m_active_window_index_before_candle_info; // active window to restore on popup hide (Anhnt, 2026-08-29 - fixes Setting Window going dead after a CandleInfo hover)
         CBarPattern           *m_pattern_bitmap_shown;             // pattern whose CGCnvPatternBitmap is visible via Alt+hover, NULL = none
         int                   m_pattern_bitmap_scale;              // CHART_SCALE the shown bitmap was built at - forces rebuild on zoom change
         CTooltip              m_tooltip_candle_info;               // Alt+hover pattern-name label, replaces the raw OBJ_TEXT ShowCandlePatternTooltipInfo used
       //For CSignalLogger use in GUIPannel_SoundAndMessageAlerts.mqh
        ENUM_SIGNAL_DIR        m_live_signal_last_seen[];
        ENUM_SIGNAL_DIR        m_upper_last_seen[];
        ENUM_SIGNAL_DIR        m_lower_last_seen[];
        ENUM_PATTERN_DIRECTION m_candle_pattern_last_seen[];
        ENUM_PATTERN_DIRECTION m_candle_pattern_closebar_last_dir[];
        CSignalLogger        m_signal_logger;
        bool                 m_signal_log_watermarks_loaded;
       
     //For Single Source of Truth
       CIndicatorTemplateManager  *m_indicator_template_manager;   // EA owns
       CSymbolTFManager           *m_SymbolTFManager;              // EA owns
     //Private Method
      //For GUI implemented in in GUIPannel_Lifecycle.mqh
          int                             WindowIdx(CWindow &wnd);
          bool                            CreateGUIPannel();
      //For Main Window m_window_main Implementation in GUIPannel_MainWindow.mqh
          bool                            CreateMainWindow(const string text);
        //For status Bar on the bottom of Main Window 
          bool                            CreateStatusBar(const int x_gap, const int y_gap);
          bool                            UpdateStatusBar(void); 
        //For MenuBar on top of Main Window
          bool                            CreateMenuBar(const int x_gap, const int y_gap);
        //For Main Tab
          bool                            CreateTab_Main(const int x_gap, const int y_gap);
         // For m_table_indicator_SymbolTFValue implemented in GUIPannel_TabMonitor.mqh     
          bool                            CreateTable_IndicatorSymbolTFMonitor(const int x, const int y);
          void                            SetValuesToTable_IndicatorSymbolTFMonitor(void);
      // For Setting Windows implemetaion in GUIPannel_SettingWindows.mqh
          bool                           CreateWindowSetting(const string caption_text);          
          void                           ShowSettingWindow(void);
          void                           HideSettingWindow(void);
       // For TreeView m_treeview_indicator on Left Pannel of Config Indicator Tab
            bool                          CreateTreeView_IndicatorTemplateSetting(const int x_gap, const int y_gap);
            void                          PopulateTreeView_IndicatorTemplateSetting(void);
        //Helper
          static void                     SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw);
          int                             GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[]);
        //Handler for Indicator TreeView on the Left m_treeview_indicator.
          bool                            CreateAddIndicatorForm(const int x_gap, const int y_gap);
          void                            ShowAddIndicatorForm(const ENUM_INDICATOR type, const int type_li);
          void                            HideAddIndicatorForm(void);
          void                            OnClickAddIndicatorBtnOnForm(void); 
       // For m_tabs_main_setting_config on the right
          bool                            CreateTabSettingConfig(const int x_gap, const int y_gap);
       // For Indicator Table m_table_indicator_template at bottom show list of indicator in template.
          //ENUM_INDICATOR_GROUP            GetIndicatorGroupForType(const ENUM_INDICATOR type); //Move to Deblib
          bool                            CreateTable_IndicatorTemplateSetting(const int x, const int y);          
          void                            UpdateRow_IndicatorTemplateSetting(const int row);
         //Event Handler for m_table_indicator_template           
          void                            OnClickToggleShowIndicatorOnChart(const int row);          
          void                            OnClickToggleBuySignal(const int row);
          void                            OnClickToggleSellSignal(const int row);
          void                            OnClickToggleSoundAlert(const int row);
          void                            OnClickToggleMessageAlert(const int row);
          void                            OnClickRemoveIndicator(const int row);
       //For TreeView m_treeview_SymbolTF on Left Pannel of m_tabs_main_setting_config (Symbol TF Tab)
          bool                            CreateTreeView_SymbolTFSetting(const int x_gap, const int y_gap);               
          void                            PopulateTreeView_SymbolTFSetting(void);
          void                            SyncTreeView_SymbolTFSetting(void);  
      //For Symbol/TF Setting Table m_table_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
          bool                            CreateTable_SymbolTFSetting(const int x, const int y);
          void                            PopulateTable_SymbolTFSetting(void);
          void                            SyncTable_SymbolTFSetting(void);
          void                            DeleteRow_SymbolTFSetting(const string sym, const string tf_text);
          int                             FindTableRowBySymbolTF(const string &sym, const string &tf_text);
          bool                            IsCurrentChartSymbolTFRow(const string sym, const string tf_text);
          void                            OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col);      
      //For Candle Pattern Setting implementation in Implementation in GUIPannel_SettingWindows_CandlePattern.mqh
       //For working with JSON
         void                            LoadCandlePatternSetting_FromJSON(void);
       //For Table_CandlePatternSetting
         void                            InitializeTable_CandlePatternSetting(void);
         bool                            CreateTable_CandlePatternSetting(const int x, const int y);
         int                             FindPatternIndexByRow(const int row);
         void                            OnCheckTableCandlePatternSetting(const int row, const int col);
         void                            SaveCandlePatternSettingToJSON(void);
      // Marker Setting implementation in GUIPannel_SettingWindows_Marker.mqh SignalMarkers.mq5
       // Working with JSON 
         void                            LoadMarkerSettingsFromJSON(void);
         bool                            CreateTabSettingConfig_Marker(const int x, const int y);
       // For Marker shape/color settings
         bool                            CreateMarkerTabComboBox(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index, const int tab_index = TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER);
         bool                            CreateMarkerTabCaption(const int row, const string text, const int x, const int y, const int tab_index = TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER);
         bool                            CreateShapePreview(const int row, const int x, const int y, const int arrow_code);
         bool                            CreateColorPreview(const int row, const int x, const int y, const color clr);
         void                            UpdateShapePreview(const int row, const int arrow_code);
         void                            UpdateColorPreview(const int row, const color clr);
         void                            GetMarkerArrowCodeChoices(int &codes[], string &labels[]);
         void                            GetMarkerColorChoices(color &colors[], string &labels[]);
         string                          ArrowLabelForCode(const int code);
         int                             ArrowCodeForLabel(const string label, const int default_code);
         string                          ColorLabelForValue(const color clr);
         color                           ColorForLabel(const string label, const color default_color);
         void                            SaveMarkerSettingsToJSON(void);
      // For Sound Seting
       //Working with JSON
         void                            LoadSoundSettingsFromJSON(void);         
         void                            SaveSoundSettingsToJSON(void);
       //For Setting Sound
         bool                            CreateTabSettingConfig_Sound(const int x, const int y);
         void                            ScanSoundFolder(string &files[]);
      //For Candle Pattern
      // --- Read-only accessors for Candle Pattern's Buy/Sell opt-in - backed by
      // --- m_BarPatterns_Control (CBarPatternControl.BuySignal()/SellSignal()), not a parallel
      // --- array, since that Library object already IS the per-pattern-type setting row
      // --- (Anhnt, 2026-08-29).
         bool                           PatternSignalBuy(const ENUM_PATTERN_TYPE type) const;
         bool                           PatternSignalSell(const ENUM_PATTERN_TYPE type) const;
      // --- index-based lookup into m_BarPatterns_Control.GetListControls() - NULL-safe, shared
      // --- by every Candle Pattern method that needs "row i's Control object" (Anhnt, 2026-08-29).
         CBarPatternControl            *PatternControlAt(const int i) const;
      //For Candle info popup Implementation in GUIPannel_CandleInfo.mqh 
          bool                          MouseOverCandleInfoWindow(void);
       //For Candle Info Window
          void                          RepositionCandleInfoWindow(const int cursor_x, const int cursor_y);
          void                          ShowCandleInfoPopup(const int cursor_x, const int cursor_y);
          void                          HideCandleInfoPopup(void);
          bool                          CreateWindowCandleInfo(void);
          bool                          RefreshCandleInfoWindow(const datetime bar_time);
       //For Candle Pattern
          void                          ShowPatternBitmapAtBar(const datetime bar_time);
          void                          HidePatternBitmapAtBar(void);
          void                          ShowCandlePatternTooltipInfo(CBarPattern *pat); 
      //Calculation for multi module implemented in GUIPannel_MultiModule.mqh
         //double                         DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0); 
      //
          CTradingLevelBubble             m_trading_bubble;                    // OWNED - self-manages its own lazy-init via EnsureCreated()`
      //For Sound and Message Alerts Implementation in GUIPannel_SoundAndMessageAlerts.mqh
       //Per-indicator/pattern Sound/Message opt-in read straight from CIndicatorTemplateManager/
       //m_BarPatterns_Control (Single Source of Truth), gated by the same 2-layer
       //Buy/Sell gate (Indicator/Pattern-level AND Symbol+TF-level via m_SymbolTFManager)
       //CSignalBridgeWriter/GUIPannel_CandleInfo.mqh already use - fires on a genuinely NEW Signal.
         void                         CheckIndicatorAlerts(void);
         void                         CheckCandlePatternAlerts(void);
       //Buy/Sell .wav lookup + play - Live-only: resolves against TERMINAL_PATH\Sounds\ only
       //(see FeatureNote/SoundBugNote.md). CloseBar plays a fixed NewBar.wav instead via
       //PlaySoundCloseBar, not Buy/Sell-specific.
         void                         PlaySoundForDirection(const bool is_buy);
         void                         PlaySoundCloseBar(void);
         ENUM_PATTERN_DIRECTION       CheckPatternLive(ENUM_PATTERN_TYPE pattern_type, MqlRates &rates, CBarPatternControl *ctrl);
         ENUM_PATTERN_DIRECTION       DetectPatternOnBar0(ENUM_PATTERN_TYPE pattern_type, ENUM_TIMEFRAMES tf, MqlRates &bar_0_temp);
       //BBands-only: one independent line's real persisted history (CSignalBollinger::LineXxx) -
       //Closed=log-only+own watermark, Live=Message+CSV (no Sound) - see CheckIndicatorAlerts.
       //buy_on/sell_on/symtf_buy/symtf_sell: same 2-layer gate the caller already computed
       //for the primary signal (Anhnt, 2026-08-28).
         void                         ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name,
                                         ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key,
                                         const string label, const string tf_text, const int digits,
                                         const bool buy_on, const bool sell_on, const bool symtf_buy, const bool symtf_sell);
      //Temporary comment out
       //Private Properties        
        
        //   // Main Tab on Right of m_window_main
        //     CTabs                     m_tabs_main;           
        //   //For TAB_TAB_MAIN_MONITOR of m_tabs_main implementation in GUIPannel_TabMonitor.mqh
        
        //   //For TAB_TAB_MAIN_POSITIONS at m_tabs_main implementation in GUIPannel_TabPositions.mqh
        //     CComboBox                 m_combo_pre_Trade_plan_symbol;
        //   //--- Order-setup row, single horizontal line (Anhnt 2026-07-20): Distance mode toggle
        //   //--- + Distance value, Lot mode toggle + Lot-or-Risk% value (same edit box, meaning
        //   //--- switches with m_group_pre_trade_lot_mode - see SetValuesToPreTradePlanTable).
        //     CTextLabel           m_label_pre_trade_distance;
        //     CButtonsGroup        m_group_pre_trade_distance_mode;   // Fixed / ATR
        //     CTextEdit            m_edit_pre_trade_distance_pts;
        //     CTextLabel           m_label_pre_trade_lot;
        //     CButtonsGroup        m_group_pre_trade_lot_mode;        // By Distance (manual) / By Risk %
        //     CTextEdit            m_edit_pre_trade_lot_or_risk;
        //     CTable               m_table_pre_Trade_plan;
        //     CTable               m_table_positions;
        //     datetime             m_last_deal_time;   // IsLastDealTicket's own HistorySelect watermark
        //     ulong                m_last_deal_ticket;  
        //   //For controls at TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER at m_tabs_main_setting_config implementation in GUIPannel_TabSettingMarker.mqh       
      
        
        
           
       // private: 
        //   // For Main Tab on the right of Main Window m_window_main
        
        //   // For Status bar on the bottom of m_window_main  
        //   // //For indicator - both free functions in the Library (TimeseriesDELib.mqh), not CGUIPannel members
        //   //   void                         BuildTemplateMatchKey(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[], string &type_key, string &params_key);
        //   //   string                       BuildIndicatorTextLabel(const ENUM_INDICATOR type, MqlParam &params[], SIndicatorCatalogItem &catalog[]);
        
        // // For TAB_TAB_MAIN_POSITIONS implementation in GUIPannel_TabPosition.mqh
        //   //For Pre-Trade-Plan area (TAB_TAB_MAIN_POSITIONS), sits above m_table_positions - symbol
        //   //picker + single-row order-setup table. Skeleton only (Anhnt 2026-07-20): Buy/Sell cells
        //   //are plain CELL_BUTTON placeholders, NOT wired to send real orders yet - that needs the
        //   //Distance(Fixed/ATR) and Lot(Manual/Risk%) mode toggles first (separate ButtonsGroup
        //   //controls, not declared yet) to actually compute a price/lot worth sending.
        //     bool                         CreatePreTradePlanSymbolCombo(const int x, const int y);
        //     bool                         CreatePreTradePlanControls(const int x, const int y);
        //     bool                         CreateTablePreTradePlan(const int x, const int y);
        //     bool                         SetValuesToPreTradePlanTable(bool force = false);
        //   //For Positions Table m_table_positions (TAB_TAB_MAIN_POSITIONS) - ported verbatim from V1,
        //   //raw ::PositionsTotal()/::PositionGetX() loops (not Layer 1's CMarketCollection) - temporary,
        //   //per user request to bring V1's table over as-is before any redesign.
        //     bool                         CreateTablePositions(const int x_gap, const int y_gap);
        //     void                         InitializePositionsTable(void);
        //     bool                         SetValuesToPositionsTable(string &symbols_name[], bool force = false);
        //     bool                         IsLastDealTicket(void);
        //     int                          GetPositionsSymbols(string &symbols_name[]);
        //     double                       PositionAveragePrice(const string symbol);
        //     int                          PositionsTotal(const string symbol);
        //     double                       PositionsVolumeTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE);
        //     double                       PositionsFloatingProfitTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE);
             
        // --- EnsureMarkerIndicatorAttached/RemoveMarkerIndicator/ReattachSignalMarkersIndicator
        // --- moved to EA (Anhnt, 2026-08-28) - chart-level Layer 3 work, same reasoning as
        // --- ShowIndicatorOnChart/RemoveIndicatorFromChart already living there, not CGUIPannel.
        
        
        // // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS implementation GUIPannel_TabSettingIndicator.mqh    
                 
        //   // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS implementation GUIPannel_TabSettingIndicator.mqh            
        
        //   // --- catalog[] type->group lookup, shared by every call site that needs a Group for
        //   // --- ChartIndicatorAdd's sub_window calc (Show/Add/Replace) - no live CIndicatorDE needed,
        //   // --- catalog[] already carries the type->group mapping (README.md muc 7.b). 
        //     // --- ApplyLoadedIndicatorBuySell/BuildTemplateBuySellSoundMessageArrays deleted
        //     // --- (SynIndicatorPlan.md, Dot 3b, 2026-08-17) - UpdateRow_IndicatorTemplateSetting() paints Buy/Sell/
        //     // --- Sound/Message straight from m_indicator_template_setting[row] (Anhnt, 2026-08-18);
        //     // --- Save already read that same array directly, so there's nothing left to "apply".

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
       //For Indicator Template Table
        void                            SyncTable_IndicatorTemplateSetting(void);
        void                            InitializeTable_IndicatorTemplateSetting(void);
        void                            AddRow_IndicatorTemplateSetting(void);
       //For Indicator Template Tree View
         void                            SyncTreeView_IndicatorTemplateSetting(void);
       // For Pointer SetPointer
        void                           SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { m_indicator_template_manager = manager; }     
        void                           SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbol_collection = symbols; }      
        void                           SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_BarTimeSeriesCollection = ts;} 
        void                           SetPatternsControl(CBarPatternsControl* ctrl) { m_BarPatterns_Control = ctrl; } 
        void                           SetIndicatorsCollection(CIndicatorsCollection *ind) { m_IndicatorsCollection = ind;}
        void                           SetTimeSeriesEngine(CTimeSeriesEngine *engine) { m_timeSeriesEngine = engine;}
        void                           SetTradingEngine(CTradingEngine *trading_engine) { m_tradingEngine = trading_engine; }
        void                           SetMarketCollection(CMarketCollection *market)      { m_trading_bubble.SetMarketCollection(market); }
        void                           SetTradingControl(CTradingControl *trading_control) { m_trading_bubble.SetTradingControl(trading_control); }
        void                           SetSymbolTFManager(CSymbolTFManager *manager) { m_SymbolTFManager = manager; }
       //For Layer 4 Working with file
       //   void SyncIndicatorTemplateSettingToBridge(void); //Move to SignalMarker
       // --- EA needs this to pass as iCustom inputs when attaching SignalMarkers.mq5 - fixed
       // --- GUI-only catalog (no Manager), read-only accessor, must be public (Anhnt, 2026-08-28 -
       // --- moved out of the private: section above, where EA couldn't actually call them).
       // --- GetPatternSignalArrays() removed (Anhnt, 2026-08-29): CSignalBridgeWriter now reads
       // --- Buy/Sell straight off m_BarPatterns_Control (live), no more EA-pushed snapshot.
        void                           GetMarkerSettings(int &single_buy, int &single_sell, int &multi_buy, int &multi_sell,
                                                           int &pattern_buy, int &pattern_sell, int &combo_buy, int &combo_sell,
                                                           color &buy_clr, color &sell_clr, color &nonrelated_clr) const;
       // --- Migration cleanup (BugNote 2026-07-16) - deletes legacy signal-arrow chart objects
       // --- from before SignalMarkers.mq5 existed. Implementation moved to
       // --- GUIPannel_SettingWindows_Marker.mqh (Anhnt, 2026-08-28).
        void                           PurgeSignalArrowObjects(const string sym, const string tf_string);
   };
#endif // CGUIPannel_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
//For implementation seperation in module
 #include "GUIPannel_Lifecycle.mqh"   //Implementation of Init, Deinit and other lifecycle events  
 //#include "GUIPannel_MultiModule.mqh" //Implementation of function using in multi module GUI Pannel
 #include "GUIPannel_MainWindows.mqh" //Implementation of function Main Windows m_window_main
 #include "GUIPannel_SettingWindows_Indicator.mqh" //Implementation of function Setting Windows m_window_setting
 #include "GUIPannel_SettingWindows_AddIndicatorForm.mqh"
 #include "GUIPannel_SettingWindows_SymbolTF.mqh"
 #include "GUIPannel_SettingWindows_CandlePattern.mqh"
 #include "GUIPannel_SettingWindows_Marker.mqh"
 #include "GUIPannel_SettingWindows_Sound.mqh"
 #include "GUIPannel_CandleInfo.mqh" 
 #include "GUIPannel_SoundAndMessageAlerts.mqh"
 #include "GUIPannel_MainWindows_TabMonitor.mqh"  
  //  #include "GUIPannel_TabPositions.mqh"
  
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
