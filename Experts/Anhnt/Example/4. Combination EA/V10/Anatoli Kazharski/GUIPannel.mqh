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
        CSymbolsCollection         *m_symbol_collection;                //CTradingEngine owns
        CBarTimeSeriesCollection   *m_BarTimeSeriesCollection;          //CBarTimeSeriesCollection owns
        CBarPatternsControl        *m_BarPatterns_Control;              // borrowed from EA
        CIndicatorsCollection      *m_IndicatorsCollection;             // CTimeSeriesEngine owns
        CTimeSeriesEngine          *m_time_series_engine;               // EA owns - Tang 1 entry point for AddIndicatorInstance        
     // For Layer 2 GUI Control Elements implementation in GUIPannel_MainWindows.mqh
        CWindow                    m_window_main;      
        CStatusBar                 m_status_bar;
        CMenuBar                   m_menu_bar;
     // For Layer 2 GUI Control Elements implementation in GUIPannel_SettingWindows.mqh
        CWindow                    m_window_setting;
       // For Tab m_tabs_main_setting_config
        CTabs                      m_tabs_main_setting_config;
       // Indicator TreeViews at the Left of m_tabs_main_setting_config
          CTreeView                m_treeview_indicator;
          int                      m_type_node_li[];      // list_index for Type of indicator
          ENUM_INDICATOR           m_type_node_value[];   //  ENUM_INDICATOR for Type of indicator
       // For Indicator Add Form display on click m_treeview_indicator node
        CTextLabel                 m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
        CTextEdit                  m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params
        CComboBox                  m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
        CButton                    m_btn_add_indicator;                         //CButton to Add Indicator
        CButton                    m_btn_save_indicator;                        //CButton to Save Indicator to JSON
        ENUM_INDICATOR             m_current_param_type;     // which type the form is currently showing
       //For Indicator Table m_table_indicator_template
        CTable                     m_table_indicator_template; 
        int                        m_pending_remove_row; 
       //For Symbol/TF Setting Tab
        //For CTreeView left pannel of the Tab 
         CTreeView                   m_treeview_SymbolTF;
        //  Table m_table_indicator_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
         CTable                      m_table_indicator_SymbolTFSeting;
         CButton                     m_btn_save_SymbolTF;
         CTextLabel                  m_label_symboltf_note;   // "takes effect after EA restart" note
         // row whose delete icon was clicked - same deferred-delete pattern as m_pending_remove_row
          int                         m_pending_remove_row_symboltf;
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
          bool                           CreateStatusBar(const int x_gap, const int y_gap);
          bool                           UpdateStatusBar(void); 
        //For MenuBar on top of Main Window
          bool                           CreateMenuBar(const int x_gap, const int y_gap);
      // For Setting Windows implemetaion in GUIPannel_SettingWindows.mqh
          bool                           CreateWindowSetting(const string caption_text);          
          void                           ShowSettingWindow(void);
          void                           HideSettingWindow(void);
       // For TreeView m_treeview_indicator on Left Pannel of Config Indicator Tab
            bool                          CreateTreeView_Indicator(const int x_gap, const int y_gap);
            void                          PopulateIndicatorTree(void);            
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
          bool                            CreateTabbleIndicator(const int x, const int y);          
          void                            SetIndicatorTableRow(const int row);
         //Event Handler for m_table_indicator_template           
          void                            OnClickToggleShowIndicatorOnChart(const int row);          
          void                            OnClickToggleBuySignal(const int row);
          void                            OnClickToggleSellSignal(const int row);
          void                            OnClickToggleSoundAlert(const int row);
          void                            OnClickToggleMessageAlert(const int row);
          void                            OnClickRemoveIndicator(const int row);
       //For TreeView m_treeview_SymbolTF on Left Pannel of m_tabs_main_setting_config (Symbol TF Tab)
          bool                            CreateTreeView_SymbolTF(const int x_gap, const int y_gap);               
          void                            PopulateSymbolTFTree(void);
          void                            SynSymbolTFTreeViewIcons(void);  
      //For Symbol/TF Setting Table m_table_indicator_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
          bool                            CreateTableSymbolTFSetting(const int x, const int y);
          void                            RefreshTableSymbolTF(void);
          bool                            HasTableSymbolTFSettingRow(const string sym, const string tf_text);
          void                            SetTableSymbolTFSettingRow(const int row, const string sym, const string tf_text);
          bool                            IsCurrentChartSymbolTFRow(const string sym, const string tf_text);
          void                            SyncTableSymbolTFSettingCurrentChartIcon(void);
          void                            OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col);
      //Calculation for multi module implemented in GUIPannel_MultiModule.mqh 
          double                          DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0); 
      //
          CTradingLevelBubble         m_trading_bubble;                    // OWNED - self-manages its own lazy-init via EnsureCreated()`
      //Temporary comment out
       //Private Properties
        //     
        
        //   // Main Tab on Right of m_window_main
        //     CTabs                     m_tabs_main;
        //   
        //   //For TAB_TAB_MAIN_MONITOR of m_tabs_main implementation in GUIPannel_TabMonitor.mqh
        //     CTable                    m_table_indicator_SymbolTFValue; 
        //   // per-row dirty-check cache for Trade tab table           
        //     string                    m_string_table_indicator_SymbolTFValue_cache_val[];
        //     int                       m_int_table_indicator_SymbolTFValue_cache_sig_icon[];
        //     int                       m_int_table_indicator_SymbolTFValue_cache_dir_icon[];
        //     int                       m_int_table_indicator_SymbolTFValue_table_row_count;
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
        //   //For TAB_TAB_MAIN_SETTINGS configuration at m_tabs_main implemenation in GUIPannel_TabSettingIndicator.mqh          
        //   //Table to display indicator-template this template concept exist in Layer 1, Layer 2 and Layer 3
        //   //Seeded ONCE at the top of OnInitEvent() (EA's OnInit) - Layer 2 CGUIPanne writes straight into these fields
        //   // no copy step. Matched back to real indicators by (type,params_key)       
        //       SJsonIndicatorEntry         m_indicator_template_setting[]; //Data for m_table_indicator_template
        //       SJsonSymbolTF               m_symbol_tf_Setting[];                    
        //       bool                        m_bool_table_indicator_template_cache_show[]; // Data for m_table_indicator_template col-4 "Show/Hide"
        //     //Combination view m_indicator_template_setting and m_bool_table_indicator_template_cache_show
        //       
        //     // row whose delete icon was clicked; executed in OnTimerEvent, NOT inside the click event -
        //     // rebuilding the table while CTable is still processing its own click leaves its focus/press indices on freed rows (array out of range in Table.mqh)
        
        //   //TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF at m_tabs_main_setting_config implementation in GUIPannel_TabSettingSymbolTF.mqh
        
        //     // same deferred-delete pattern as m_pending_remove_row, for m_table_indicator_SymbolTFSeting
        //     int                         m_pending_remove_row_symboltf;
        //   //TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN implementation in GUIPannel_TabSettingCandlePattern.mqh
        //     CTable                      m_table_CandlePatternsSetting;         
        //     ENUM_PATTERN_TYPE           m_pattern_types[];
        //     string                      m_pattern_display_names[]; 
        //     CButton                     m_btn_save_pattern_config;      
        //   //For controls at TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER at m_tabs_main_setting_config implementation in GUIPannel_TabSettingMarker.mqh
        //   //For Marker 8 independent shapes to display at each Candle on Chart see SignalMarkers.mq5        
        //     CComboBox           m_combo_shape_single_indicator_buy;  //candle only have single indicator, buy or sell base on indicator signal
        //     CComboBox           m_combo_shape_single_indicator_sell; //candle only have single indicator, buy or sell base on indicator signal
        //     CComboBox           m_combo_shape_multi_indicator_buy;   //candle have multi indicator, buy or sell base on indicator signal
        //     CComboBox           m_combo_shape_multi_indicator_sell;  //candle have multi indicator, buy or sell base on indicator signal
        //     CComboBox           m_combo_shape_pattern_buy;           //candle only have pattern, buy or sell base on pattern signal
        //     CComboBox           m_combo_shape_pattern_sell;          //candle only have pattern, buy or sell base on pattern signal
        //     CComboBox           m_combo_shape_combo_buy;             //candle have combo of indicator and pattern, buy or sell base on combo signal
        //     CComboBox           m_combo_shape_combo_sell;            //candle have combo of indicator and pattern, buy or sell base on combo signal
        //     // Current marker style/color state - loaded from Config_Setting.json's "markers" section at startup,
        //     // Fed to SignalMarkers.mq5 as iCustom inputs, updated by the Save button above.
        //     int                 m_marker_single_indicator_buy_code;
        //     int                 m_marker_single_indicator_sell_code;
        //     int                 m_marker_multi_indicator_buy_code;
        //     int                 m_marker_multi_indicator_sell_code;
        //     int                 m_marker_pattern_buy_code;
        //     int                 m_marker_pattern_sell_code;
        //     int                 m_marker_combo_buy_code;
        //     int                 m_marker_combo_sell_code;
        //     // For color Marker have 3 colors, independent of shape: Buy/Sell apply when a marker relates to this        
        //     CComboBox           m_combo_color_buy;           //color of buy marker
        //     CComboBox           m_combo_color_sell;          //color of sell marker
        //     CComboBox           m_combo_color_nonrelated;    //color of non-related marker
        //     //For color
        //     color               m_marker_buy_color;          //color of buy marker
        //     color               m_marker_sell_color;         //color of sell marker
        //     color               m_marker_nonrelated_color;   //color of non-related marker
        //     //For button Save marker setting
        //     CButton             m_btn_save_marker_settings;
        //     // --- Other tab captions/previews - index 0-3 = shape rows (Single Buy/Sell, Multi
        //     // --- Buy/Sell), index 0-2 of the color arrays = Buy/Sell/Non-Related. Preview labels
        //     // --- render the ACTUAL Wingdings glyph (Font("Wingdings") + the raw char code) so the
        //     // --- user sees the real shape, not just a number; color previews reuse CColorButton's
        //     // --- own swatch rendering, just never wired to a click handler (display-only).
        //     CTextLabel          m_label_other_caption[16];
        //     CTextLabel          m_preview_shape[16];
        //     CColorButton        m_preview_color[3];       
        //     string              m_marker_buy_sound_file;
        //     string              m_marker_sell_sound_file;        
        //     CTextLabel          m_textLabel_sound_folder;         
        //     CComboBox           m_combo_buy_sound;
        //     CComboBox           m_combo_sell_sound;
        //   //Information window at to display signal on chart
        //   CWindow               m_window_candle_infomation;
        //   CTable                m_table_candle_information_atBar;
        //   datetime              m_candle_info_shown_bar;             // 0 = window currently hidden
        //   CBarPattern           *m_pattern_bitmap_shown;             // pattern whose CGCnvPatternBitmap is visible via Alt+hover, NULL = none
        //   int                   m_pattern_bitmap_scale;              // CHART_SCALE the shown bitmap was built at - forces rebuild on zoom change
        //   CTooltip              m_tooltip_candle_info;               // Alt+hover pattern-name label, replaces the raw OBJ_TEXT ShowCandlePatternTooltipInfo used
        //   //For use in GUIPannel_SoundAndMessageAlerts.mqh
        //   //For indicator        
        //       ENUM_SIGNAL_DIR      m_live_signal_last_seen[];
        //     // --- BBands-only (IND_BANDS): Live-bar-0 tracker for CSignalBollinger's 2 remaining        
        //       ENUM_SIGNAL_DIR      m_upper_last_seen[];
        //       ENUM_SIGNAL_DIR      m_lower_last_seen[]; 
        //   //For candle at bar 0 [timeframe_index][pattern_type]track last state per pattern type
        //     ENUM_PATTERN_DIRECTION     m_candle_pattern_last_seen[];
        //     // --- CloseBar-only (Anhnt, 2026-08-11): unlike Indicator (SignalBase.mqh's
        //     // --- CommitClosedBar/SyncHistory already only ever record a TRUE flip - never the same
        //     // --- direction twice in a row), CBarPattern/GetListAllPatterns() lists EVERY detected
        //     // --- pattern occurrence with no such guard - 2 consecutive Bullish hits of the same
        //     // --- pattern type are 2 real, separate entries. Message/CSV still logs every one
        //     // --- (patterns ARE legitimately episodic, not a continuous state) - but Sound should
        //     // --- only fire when direction actually changed vs the last CloseBar-committed one for
        //     // --- this (pattern type, TF), same principle as Indicator already gets for free. Same
        //     // --- ti*pattern_count+row indexing as m_candle_pattern_last_seen, but NEVER reset on
        //     // --- new-bar (that reset is Live-path-only) - this tracks history, not the live bar.
        //     ENUM_PATTERN_DIRECTION     m_candle_pattern_closebar_last_dir[];
        //     // --- CloseBar Sound dedup gate (Anhnt, 2026-08-11): correlated indicators (BBands/PSAR/
        //     // --- AMA...) or Indicator+CandlePattern together can flip on the SAME closed bar - each
        //     // --- flip is individually valid (Message/CSV still logs every one), but ::PlaySound()
        //     // --- calls fired back-to-back within one pass interrupt each other (1 shared OS sound
        //     // --- channel). A single closed bar can also carry MANY Pattern hits at once - picking
        //     // --- Buy/Sell per event just meant more dedup state for no benefit, since CloseBar
        //     // --- Sound's whole job is "something closed, go look" (the actual Buy/Sell/what is
        //     // --- already in Message/CSV). So CloseBar plays ONE fixed file (NewBar.wav) instead of
        //     // --- Buy/Sell-specific, gated by THIS single flag - checked-and-set INLINE, immediately,
        //     // --- at the first CloseBar flip seen this pass (NOT deferred to the end of OnTickEvent -
        //     // --- that was tried and reliably stomped any Live sound that had already played earlier
        //     // --- the same pass, since NewBar.wav would then always fire last - see
        //     // --- FeatureNote/SoundBugNote.md). Reset false at the top of OnTickEvent.
        // // Layer 3 observer moved to EA.mq5 (m_ChartObjCollection) - EA owns/orchestrates Layer 3
        // // directly now, CGUIPannel no longer controls it (README, "control by EA").
        // //Layer 4 IO File Signal Markers bridge a separate SignalMarkers.mq5
        //     CSignalLogger              m_signal_logger;                     // Signal logger for history and exports
        //     CSignalBridgeWriter        m_bridge_writer;
        //     bool                       m_signal_log_watermarks_loaded; 
        
        
           
       // private: 
        // //For Main Window m_window_main Implementation in GUIPannel_MainWindow.mqh      
        //   // For Symbol TF TreeView m_treeview_SymbolTF on Left Pannel of m_window_main
        
        //   // For Main Tab on the right of Main Window m_window_main
        //   bool                           CreateTab_Main(const int x_gap, const int y_gap);
        //   // For Status bar on the bottom of m_window_main  
        //   // //For indicator - both free functions in the Library (TimeseriesDELib.mqh), not CGUIPannel members
        //   //   void                         BuildTemplateMatchKey(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[], string &type_key, string &params_key);
        //   //   string                       BuildIndicatorTextLabel(const ENUM_INDICATOR type, MqlParam &params[], SIndicatorCatalogItem &catalog[]);
        // // For m_table_indicator_SymbolTFValue implemented in GUIPannel_TabMonitor.mqh     
        //     bool                         CreateTableIndicatorSymbolTFValue(const int x, const int y);
        //     void                         SetValuesToTableIndicatorSymbolTFValue(void);
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
        // //For Candle info popup Implementation in GUIPannel_CandleInfo.mqh 
        //   bool                          MouseOverCandleInfoWindow(void);
        //   //For Candle Info Window
        //   void                          RepositionCandleInfoWindow(const int cursor_x, const int cursor_y);
        //   void                          ShowCandleInfoPopup(const int cursor_x, const int cursor_y);
        //   void                          HideCandleInfoPopup(void);
        //   bool                          CreateWindowCandleInfo(void);
        //   bool                          RefreshCandleInfoWindow(const datetime bar_time);
        //   //For Candle Pattern
        //   void                          ShowPatternBitmapAtBar(const datetime bar_time);
        //   void                          HidePatternBitmapAtBar(void);
        //   void                          ShowCandlePatternTooltipInfo(CBarPattern *pat);       
        // //For working with SignalMarker.mq5 implementation in GUIPannel_SignalMarkers.mqh
        //     void                         EnsureMarkerIndicatorAttached(void);
        //     void                         ReattachSignalMarkersIndicator(void);
        //     void                         RemoveMarkerIndicator(void); 
        // //For working with JSON implementation in GUIPannel_JSONConfig.mqh
        //     void                         SaveGUIConfigToJSON(void);
        //     void                         SavePatternAlertConfigToJSON(void);
        //     void                         SaveMarkerSettingsToJSON(void);
        //     //For Load
        //     void                         LoadSymbolTFSettingFromJSON(void);
        //     void                         LoadIndicatorTemplateSettingFromJSON(void);
        //     void                         LoadPatternAlertConfigFromJSON(void);
        //     void                         LoadMarkerSettingsFromJSON(void);
        // //Implementation in GUIPannel_SoundAndMessageAlerts.mqh
        //   //Per-indicator Sound/Message opt-in (m_table_indicator col 5/6) - fires on a genuinely NEW Signal
        //   void                         CheckIndicatorAlerts(void);
        //   void                         CheckCandlePatternAlerts(void);
        //   //Buy/Sell .wav lookup + play - Live-only (Anhnt, 2026-08-14): resolves against
        //   //TERMINAL_PATH\Sounds\ only (see FeatureNote/SoundBugNote.md). CloseBar plays a fixed
        //   //NewBar.wav instead via PlaySoundCloseBar, not Buy/Sell-specific.
        //   void                         PlaySoundForDirection(const bool is_buy);
        //   void                         PlaySoundCloseBar(void);
        //   int                          GetPatternCandleCount(ENUM_PATTERN_TYPE pattern_type);
        //   ENUM_PATTERN_DIRECTION       CheckPatternLive(ENUM_PATTERN_TYPE pattern_type, MqlRates &rates, CBarPatternControl *ctrl);
        //   ENUM_PATTERN_DIRECTION       DetectPatternOnBar0(ENUM_PATTERN_TYPE pattern_type, ENUM_TIMEFRAMES tf, MqlRates &bar_0_temp);
        //   //BBands-only: one independent line's real persisted history (CSignalBollinger::LineXxx) -
        //   //Closed=log-only+own watermark, Live=Message+CSV (no Sound) - see CheckIndicatorAlerts
        //   void                         ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name, ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key, const string label, const string tf_text, const int digits);
        // // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS implementation GUIPannel_TabSettingIndicator.mqh    
                 
        //   // For nested config tabs (m_tabs_main_setting_config) inside TAB_TAB_MAIN_SETTINGS implementation GUIPannel_TabSettingIndicator.mqh            
        
        //   // --- catalog[] type->group lookup, shared by every call site that needs a Group for
        //   // --- ChartIndicatorAdd's sub_window calc (Show/Add/Replace) - no live CIndicatorDE needed,
        //   // --- catalog[] already carries the type->group mapping (README.md muc 7.b). 
        //     // --- ApplyLoadedIndicatorBuySell/BuildTemplateBuySellSoundMessageArrays deleted
        //     // --- (SynIndicatorPlan.md, Dot 3b, 2026-08-17) - SetIndicatorTableRow() paints Buy/Sell/
        //     // --- Sound/Message straight from m_indicator_template_setting[row] (Anhnt, 2026-08-18);
        //     // --- Save already read that same array directly, so there's nothing left to "apply".
        //     void                         PurgeSignalArrowObjects(const string sym, const string tf_string);
        // //----Unfininished         
        //   //For Symbol/TF Setting Table m_table_indicator_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
        
          
        //   //TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN implementation in GUIPannel_TabSettingCandlePattern.mqh         
        //     void                         BuildCandlePatternListFromRegistry(void);
        //     void                         RegisterPatterns(void);
        //     void                         InitializeTableCandlePatternSetting(void);
        //     bool                         CreateTableCandlePatternSetting(const int x, const int y);         
        //   //For TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER - marker shape/color settings for SignalMarkers.mq5 
        //   // Implementation in GUIPannel_TabSettingMarker.mqh       
        //     bool                         CreateTabSettingConfig_Marker(const int x, const int y);
        //     bool                         CreateMarkerTabComboBox(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index);
        //     bool                         CreateMarkerTabCaption(const int row, const string text, const int x, const int y);
        //     bool                         CreateShapePreview(const int row, const int x, const int y, const int arrow_code);
        //     bool                         CreateColorPreview(const int row, const int x, const int y, const color clr);
        //     void                         UpdateShapePreview(const int row, const int arrow_code);
        //     void                         UpdateColorPreview(const int row, const color clr);
        //     void                         GetMarkerArrowCodeChoices(int &codes[], string &labels[]);
        //     void                         GetMarkerColorChoices(color &colors[], string &labels[]);
        //     // --- Round-trip helpers so Config_Setting.json stores human-readable labels
        //     // --- ("83 Bomb", "Dodger Blue") instead of raw Wingdings codes/color ints - looks up
        //     // --- against the SAME catalogs above, so the JSON always matches what the combo shows.
        //     string                       ArrowLabelForCode(const int code);
        //     int                          ArrowCodeForLabel(const string label, const int default_code);
        //     string                       ColorLabelForValue(const color clr);
        //     color                        ColorForLabel(const string label, const color default_color);
        //     //For Buy/Sell alert sound file pickers (Marker tab) - plain combobox, folder scanned via FileFindFirst
        //     void                         ScanSoundFolder(string &files[]);         
        
          
      
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
       //-----------------------------
        // // --- Thin forward to CTimeSeriesEngine::OnChartEvent (Layer 1) - EA.mq5 can't pass
        // // --- m_indicator_template_setting[] itself (private, and MQL5 can't return an array by
        // // --- reference), so this runs INSIDE CGUIPannel where the field is directly reachable.
        // bool                           ForwardChartEventToLayer1(const int id, const long &lparam, const double &dparam, const string &sparam);
      //For Indicator Template Table
       void                            RefreshIndicatorTableShowColumn(void);
       void                            RefreshTableIndicator(void);
      //For Indicator Template Tree View
       void                            SyncIndicatorTreeViewIcons(void);
      // For Pointer SetPointer
        void                           SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { m_indicator_template_manager = manager; }     
        void                           SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbol_collection = symbols; }      
        void                           SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_BarTimeSeriesCollection = ts;} 
        void                           SetPatternsControl(CBarPatternsControl* ctrl) { m_BarPatterns_Control = ctrl; } 
        void                           SetIndicatorsCollection(CIndicatorsCollection *ind) { m_IndicatorsCollection = ind;}
        void                           SetTimeSeriesEngine(CTimeSeriesEngine *engine) { m_time_series_engine = engine;}
        void                           SetMarketCollection(CMarketCollection *market)      { m_trading_bubble.SetMarketCollection(market); }
        void                           SetTradingControl(CTradingControl *trading_control) { m_trading_bubble.SetTradingControl(trading_control); }
        void                           SetSymbolTFManager(CSymbolTFManager *manager) { m_SymbolTFManager = manager; }
      //For Layer 4 Working with file
      //   void SyncIndicatorTemplateSettingToBridge(void); //Move to SignalMarker      
   };
#endif // CGUIPannel_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
//For implementation seperation in module
 #include "GUIPannel_Lifecycle.mqh"   //Implementation of Init, Deinit and other lifecycle events
  //  #include "GUIPannel_JSONConfig.mqh"  //Implementation of JSON config and save setting of GUI Pannel
 #include "GUIPannel_MultiModule.mqh" //Implementation of function using in multi module GUI Pannel
 #include "GUIPannel_MainWindows.mqh" //Implementation of function Main Windows m_window_main
 #include "GUIPannel_SettingWindows_Indicator.mqh" //Implementation of function Setting Windows m_window_setting
 #include "GUIPannel_AddIndicatorForm.mqh"
 #include "GUIPannel_TabSettingSymbolTF.mqh"
  //  #include "GUIPannel_TabMonitor.mqh"  
  //  #include "GUIPannel_TabPositions.mqh" 
    
  //  #include "GUIPannel_TabSettingIndicatorTreeView.mqh"  
  //  #include "GUIPannel_TabSettingIndicator.mqh" 
  //  #include "GUIPannel_TabSettingCandlePattern.mqh"
  //  #include "GUIPannel_TabSettingMarker.mqh"    
  //  #include "GUIPannel_CandleInfo.mqh" 
  //  #include "GUIPannel_SoundAndMessageAlerts.mqh"
  //  #include "GUIPannel_SignalMarkers.mqh"    
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
