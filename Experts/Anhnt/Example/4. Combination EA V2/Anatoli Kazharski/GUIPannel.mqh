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
  //extern string g_ea_folder;    // From EA
  extern bool   g_ea_init_done; // From EA - false while OnInit() (incl. REASON_CHARTCHANGE reinit) is still wiring modules
  class CGUIPannel
   {
    private:
      CTimeCounter                        m_gui_timecounter;                   //--- Time counters - configured (SetParameters) but not consumed anywhere yet
      CKeys                               m_keys;                              //For Keyboard
      bool                                m_gui_created;                       // guard thay cho s_gui_ready trong EA
     //--- Press-D debug dump snapshot see OnEvent's CHARTEVENT_KEYDOWN/'D' handler; general utility, not tied to any one tab.
     // Private Pointer variables
        CSymbolsCollection               *m_symbol_collection;                // CTradingEngine owns
        CMarketCollection                *m_market_collection;                // CTradingEngine owns
        CAccountsCollection              *m_accounts_collection;              // CTradingEngine owns - direct borrow (Anhnt/Claude, 2026-09-15), same pattern as m_market_collection/m_symbol_collection; GetCurrentAccount() itself lives on CAccountsCollection now, not CTradingEngine
        CBarTimeSeriesCollection         *m_BarTimeSeriesCollection;          // CBarTimeSeriesCollection owns        
        CIndicatorsCollection            *m_IndicatorsCollection;             // CTimeSeriesEngine owns
        CSignalsCollection               *m_SignalsCollection;               // CTimeSeriesEngine owns
        CTradingEngine                   *m_tradingEngine;                    // EA owns - now wired via EA.mq5's OnInit (Anhnt/Claude, 2026-09-09); also hosts the StopLost/Trailing Apply engine (moved from CGUIPannel) - display code below calls through this pointer.
        CTradingControl                  *m_trading_control;                  // CTradingEngine owns - actually wired, via SetTradingControl() below
     // For Single Source of Truth
       CIndicatorTemplateManager         *m_indicator_template_manager;       // EA owns
       CSymbolTFManager                  *m_SymbolTFManager;                  // EA owns
       CBarPatternsControl               *m_BarPatterns_Control;              // EA owns
       CSwingSetting                     *m_SwingSetting;                     // EA owns (CTimeSeriesEngine::m_SwingSetting) - shared Swing N + Wick/Body
       CTradingSetupSettingManager       *m_trading_setup_manager;            // EA owns - per-Symbol StopLost+Trailing
     // For CSignalLogger use in GUIPannel_SoundAndMessageAlerts.mqh
        CSignalLogger                    m_signal_logger;
        ENUM_SIGNAL_DIR                  m_live_signal_last_seen[];
        ENUM_SIGNAL_DIR                  m_upper_last_seen[];
        ENUM_SIGNAL_DIR                  m_lower_last_seen[];
        ENUM_PATTERN_DIRECTION           m_candle_pattern_last_seen[];
        datetime                         m_candle_pattern_last_bar[];         // bar 0 time of the last live pattern alert
        bool                             m_signal_log_watermarks_loaded;
        CChartObjCollection             *m_chart_obj_collection;             // EA owns - for m_btngroup_tf_switch click -> SetActiveChartSymbolTF
        CGraphElementsCollection        *m_graph_elements;                   // EA owns - ZOrder of every canvas element
        long                             m_chart_id;
        int                              m_subwin;
     // For Layer 2 GUI Control Elements implementation in GUIPannel_MainWindows.mqh
        CWindow                          m_window_main;
        CStatusBar                       m_status_bar;
        CMenuBar                         m_menu_bar;
        CContextMenu                     m_contextmenu_settings;
        CContextMenu                     m_contextmenu_trading;               // Stop Lost / Trailling on-off of the New Order Symbol
      // Main Tabs
        CTabs                            m_tabs_main;
       // ==== TAB_TAB_MAIN_TRADING
        CTable                           m_table_positions_StoplostAndTrailling;
        CTable                           m_table_position_pretrade_view;
        CTable                           m_table_indicator_PreTradeSymbolMonitor;
        //For Trading
         CButtonsGroup                   m_btngroup_tf_switch;      // chart Symbol's TFs (+ "All" when 2+), filters m_table_indicator_PreTradeSymbolMonitor
         bool                            m_new_order_is_buy;        //Direction (Buy/Sell) - replaced by clicking the Direction icon in
         double                          m_new_order_lot_last;      //Last user-picked Lot (session-only) - restored into the Lot combobox on rebuild instead of always resetting to MinLot
        //Default RISK_PERCENTAGE_PERPOSITION 5% change on Live
        //--- On/off moved to m_contextmenu_trading, opening the settings to the Monitor's colored SL/Trailling cells
         CCheckBox                       m_checkbox_use_RiskPerNewTrade; // including text
         CTextEdit                       m_edit_RiskPerNewTrade;
         CComboBox                       m_combobox_order_type;
         CTextEdit                       m_edit_order_type_value; 
        //Send Order
         CButton                         m_btn_send_toTrade;        
     // Setting Window for: Indicator and Symbol/TF, Candle Pattern,Swing
      CWindow                            m_window_setting_timeseries;
       CTabs                             m_tabs_setting_timeseries;
       // --- Indicator Setting tab (GUIPannel_SettingWindows_TS_Indicator.mqh) ---
        // TreeView on the left for Indicator Template
         CTreeView                       m_treeview_indicator;
         long                            m_type_node_id[];      // CTreeView item id of each indicator type leaf
         ENUM_INDICATOR                  m_type_node_value[];   //  ENUM_INDICATOR for Type of indicator
         //bool                            m_treeview_indicator_need_sync; //Dirty flag for m_treeview_indicator
         //bool                            m_table_indicator_need_sync; //Dirty flag for m_table_indicator_template
        // For Indicator Add Form display on click m_treeview_indicator node
         //CTextLabel                      m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
         CTextEdit                       m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params, caption = param name
         CComboBox                       m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
         CButton                         m_btn_add_indicator;                         //CButton to Add Indicator
         CButton                         m_btn_save_indicator;                        //CButton to Save Indicator to JSON
         bool                            m_indicator_save_pending;                    // unsaved template change - keeps m_btn_save_indicator visible
         ENUM_INDICATOR                  m_current_param_type;     // which type the form is currently showing, IND_CUSTOM = none
        // For Table at Bottom of the Form, Table m_table_indicator_template
         CTable                          m_table_indicator_template;
         int                             m_pending_remove_row;                        //Mark row for delete
       // --- Symbol/TF Setting tab (GUIPannel_SettingWindows_TS_SymbolTF.mqh) ---
        // For CTreeView on the Left pannel of the Symbol TF Setting
         CTreeView                       m_treeview_SymbolTF;
         CTable                          m_table_SymbolTFSeting;
         CButton                         m_btn_save_SymbolTF;
         //bool                            m_treeview_symboltf_need_sync;               //Dirty flag for m_treeview_SymbolTF
         string                          m_pending_remove_sym_symboltf;
         string                          m_pending_remove_tf_symboltf;
       // --- Candle Pattern Setting tab (GUIPannel_SettingWindows_TS_CandlePattern.mqh) ---
         CTable                          m_table_CandlePatternsSetting;
         CButton                         m_btn_save_pattern_config;
       //For Swing setting - 2 fixed rows (High/Low); all values live in m_SwingSetting (EA owns), GUI holds no copy
         CTable                          m_table_SwingSetting;
         CButton                         m_btn_save_swing_config;
         //CTextLabel                      m_label_swing_strength;      // "Strength" caption
         CTextEdit                       m_edit_swing_strength;       // N - spin edit, caption "Strength"
         CCheckBox                       m_checkbox_swing_wick;       // ticked = Wick, unticked = Body

     // Setting Window for: Trading Setting Stop Lost And Trailling
      CWindow                           m_window_setting_trading;      
       CTabs                            m_tabs_setting_trading;      
       //For Stop Lost Setting
         CTable                         m_table_stoplostsetting;
         CTable                         m_table_trailingsetting;
         CTable                         m_table_indicators_trailingsetting;
       // SL Setting form - embedded inline beside m_table_stoplostsetting
         CLabel                         m_label_StopLostSetting_Symbol;    // Setting symbol
         CLabel                         m_label_StopLost_MinPts;           // server-mandated floor (Spread()/2 + TradeStopLevel())
        //3-column grid: blank-label | Fixed | Indicator, rows Selection/Multiplexer/Value in Point
         CFrame                         m_frame_stoplost_setting_fixedmode;
         CFrame                         m_frame_stoplost_setting_indicatormode;
         //CLabel                         m_label_StopLost_GridCaption[5];   // static captions: 0=ColHeader Fixed, 1=ColHeader Ind, 2=RowLabel Selection, 3=RowLabel Multiplexer, 4=RowLabel Value
         CTextEdit                      m_edit_StopLost_FixedSelection;    // Fixed's Selection cell - editable, default "Spread"
         CTextEdit                      m_edit_StopLost_FixedPoint;        // Fixed's Multiplexer cell - multiplier on Spread
         CComboBox                      m_combobox_ATR_choice;             // Indicator's Selection cell - template x tracked-TF choice
         CTextEdit                      m_edit_ATR_Multiplexer;            // Indicator's Multiplexer cell - multiplier on ATR value
         CLabel                         m_label_StopLost_ValuePreview[2];  // live-computed Value in Point: 0=Fixed, 1=Indicator
        //For Save Stop Lost Setting
         CButton                         m_btn_save_StopLost_Setting;       
       //m_table_indicators_trailingsetting declared above alongside m_table_stoplostsetting
         CLabel                         m_label_TrailingSetting_Symbol;    // which Symbol m_table_indicators_trailingsetting is currently scoped to
        //Trailing form beside m_table_indicators_trailingsetting - Offset/Start/Step, one shared field
        //each (Anhnt, 2026-09-08) - Fixed and Indicator use the SAME m_offset, mirroring
        //CSimpleTrailing in Trishkin's Trailings.mqh (one m_offset, not two per-mode fields). No
        //Selection or Multiplier row either (Indicator picked via the checkbox table).
         //CTextLabel                     m_label_Trailing_GridCaption[4];   // 0=RowLabel Offset, 1=RowLabel Start, 2=RowLabel Step, 3=RowLabel DataRatesIndex
         CFrame                         m_frame_trailling_setting_fixedmode; //Text = Fixed Mode
         CTextEdit                      m_edit_Trailing_Offset;            // shared - offset (points) from the current price / Indicator's line
         CTextEdit                      m_edit_Trailing_Start;             // shared - profit (points) required before trailing starts
         CTextEdit                      m_edit_Trailing_Step;              // shared - minimum improvement (points) before moving SL
         CTextEdit                      m_edit_Trailing_DataRatesIndex;    // EA-wide (not per-Symbol) - M1 bar shift for Trailing-by-Value's base price
         CButton                        m_btn_save_Trailing_Setting;
     // Setting Window for Alert: Marker On Chart and Sound
      CWindow                          m_window_setting_markerAndSound;      
      CTabs                            m_tabs_setting_markerAndSound;
       // For Marker Tab 8 independent shapes to display at each Candle on Chart see SignalMarkers.mq5                
        CComboBox                       m_combo_shape_single_indicator_buy;  //candle only have single indicator, buy or sell base on indicator signal
        CComboBox                       m_combo_shape_single_indicator_sell; //candle only have single indicator, buy or sell base on indicator signal
        CComboBox                       m_combo_shape_multi_indicator_buy;   //candle have multi indicator, buy or sell base on indicator signal
        CComboBox                       m_combo_shape_multi_indicator_sell;  //candle have multi indicator, buy or sell base on indicator signal
        CComboBox                       m_combo_shape_pattern_buy;           //candle only have pattern, buy or sell base on pattern signal
        CComboBox                       m_combo_shape_pattern_sell;          //candle only have pattern, buy or sell base on pattern signal
        CComboBox                       m_combo_shape_combo_buy;             //candle have combo of indicator and pattern, buy or sell base on combo signal
        CComboBox                       m_combo_shape_combo_sell;            //candle have combo of indicator and pattern, buy or sell base on combo signal
        CComboBox                       m_combo_shape_swing_high;            //confirmed Swing High pivot - drawn in sell color, glyph is the only Swing-specific choice
        CComboBox                       m_combo_shape_swing_low;             //confirmed Swing Low pivot - drawn in buy color
       // Current marker style/color state - loaded from Config_Setting.json's "markers" section at startup,
       // Fed to SignalMarkers.mq5 as iCustom inputs, updated by the Save button above.
        CFrame                          m_frame_buy_marker; //Text = Buy Marker
        CFrame                          m_frame_sell_marker; //Text = Sell Marker
        int                             m_marker_single_indicator_buy_code;
        int                             m_marker_single_indicator_sell_code;
        int                             m_marker_multi_indicator_buy_code;
        int                             m_marker_multi_indicator_sell_code;
        int                             m_marker_pattern_buy_code;
        int                             m_marker_pattern_sell_code;
        int                             m_marker_combo_buy_code;
        int                             m_marker_combo_sell_code;
        int                             m_marker_swing_high_code;
        int                             m_marker_swing_low_code;
       // Other tab captions/previews - index 0-3 = shape rows (Single Buy/Sell, Multi Buy/Sell),        
        //CTextLabel                      m_label_other_caption[16];
        CLabel                          m_preview_shape[16];
        CButton                         m_colorbutton[3];            // color swatch, no color picker in Lib V2
       // For color Marker have 3 colors, independent of shape: Buy/Sell apply when a marker relates to this        
        CComboBox                       m_combo_color_buy;           //color of buy marker
        CComboBox                       m_combo_color_sell;          //color of sell marker
        CComboBox                       m_combo_color_nonrelated;    //color of non-related marker
       //For color
        CFrame                          m_frame_color;               //Text = Color for Marker
        color                           m_marker_buy_color;          //color of buy marker
        color                           m_marker_sell_color;         //color of sell marker
        color                           m_marker_nonrelated_color;   //color of non-related marker
       //For button Save marker setting
        CButton                         m_btn_save_marker_settings;        
       // For Sound tab - Buy/Sell alert sound file pickers, own tab (split away from Marker)
        string                          m_marker_buy_sound_file;
        string                          m_marker_sell_sound_file;
        CLabel                          m_textLabel_sound_folder;
        CComboBox                       m_combo_buy_sound;
        CComboBox                       m_combo_sell_sound;
        CComboBox                       m_combo_trailling_sound;
        // On/Off per sound - a picked file alone can't be silenced otherwise (Anhnt, 2026-09-19)
        CCheckBox                       m_checkbox_buy_sound;
        CCheckBox                       m_checkbox_sell_sound;
        CCheckBox                       m_checkbox_trailing_sound;
        bool                            m_buy_sound_enabled;
        bool                            m_sell_sound_enabled;
        bool                            m_trailing_sound_enabled;
        CButton                         m_btn_save_sound_settings;
     // Candle Info popup (Shift+hover) implemented in GUIPannel_CandleInfo_Windows.mqh
       CWindow                          m_window_candle_infomation;
       CTable                           m_table_candle_information_atBar;
       datetime                         m_candle_info_shown_bar;             // 0 = popup hidden
       CGCnvPatternBitmap              *m_pattern_bitmap;                    // m_graph_elements owns
       CTooltip                        *m_tooltip_candle_info;               // m_graph_elements owns
     //Private Method
     // For GUI implemented in in GUIPannel_Lifecycle.mqh
       //int                              WindowIdx(CWindow &wnd);
       bool                             CreateGUIPannel();
     // For Main Window m_window_main Implementation in GUIPannel_MainWindow.mqh
       bool                             CreateWindow_Main(const string caption_text,const int x_gap, const int y_gap);
       void                             OnEvent_Window_Main(const int id,const long &lparam, const double &dparam, const string &sparam);
      //For status Bar on the bottom of Main Window 
       bool                             CreateStatusBar(const int x_gap, const int y_gap);
       bool                             UpdateStatusBar(void); 
      //For MenuBar on top of Main Window
       bool                             CreateMenuBar(const int x_gap, const int y_gap);
      //For Main Tab
       bool                             CreateTab_Main(const int x_gap, const int y_gap);
       //For Tab Trading
        // Table Position's Stoploss and Trailling
         bool                           CreateTable_PositionsStoplostAndTrailling(const int x, const int y);
         bool                           SyncTable_PositionsStoplostAndTrailling(bool force = false);
         bool                           CreateTable_PositionPretradeView(const int x, const int y);
         bool                           SyncTable_PositionPretradeView(bool force = false);
         bool                           SyncComboBox_NewOrderSymbol(void);   // choices = CSymbolsCollection
        // For Table Pre Trade Symbol Monitor
         bool                            CreateTable_PreTradeSymbolMonitor(const int x, const int y);
         bool                            SyncTable_PreTradeSymbolMonitor(const string symbol, bool force = false);         
         int                             BuildSymbolIndicatorMonitorList(const string symbol, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[]);
         //void                          OnClickNavigateToTF(const int row);
         void                            OnSymbolToTradeChanged(const bool move_chart = true);   // false = the chart already shows it
         void                            OnClickToggleSLOrTrailing(const bool is_sl);
         void                            SyncRunSLTrailingButtonIcons(const bool sl_active, const bool trail_active);   // gray icon = setting off, same convention as the Positions table's Run columns
         void                            OnClickTogglePretradeDirection(void);
         void                            OnClickTogglePretradeSLType(void);
         void                            OnClickTogglePretradeTrailType(void);
         void                            OnClickTogglePositionSLType(const int row);
         void                            OnClickTogglePositionTrailType(const int row);
         void                            OnClickSendNewOrder(void);
         void                            OnClickUseRiskPerNewTradeCheckbox(void);
         void                            OnClickOpenTradingSettingTab(const ENUM_TAB_SETTING_TRADING tab);
        //--- Single source of truth for the New Order form's 
         string                          GetNewOrderSymbol(void) { return m_table_position_pretrade_view.Cell(COL_PTV_SYMBOL, 0).Value(); }
         double                          GetNewOrderLot(void)    { return ::StringToDouble(m_table_position_pretrade_view.Cell(COL_PTV_LOT, 0).Value()); }
        // Create Trading Form
         bool                            CreateTFSwitchButtons(const int x_gap, const int y_gap);   // standalone row, top-left of the panel
         bool                            CreateTradingForm(const int x_gap, const int y_gap);
         void                            UpdateSendButtonAppearance(void);
         void                            SyncTFSwitchButtons(void);   // adds a button for each TF CSymbolTFManager has that the group lacks
         void                            OnClickTFSwitchButton(void);
     // For Setting Windows m_window_setting_timeseries
       bool                            CreateWindow_SettingTimeSeries(const string caption_text,const int x_gap, const int y_gap);
       void                            OpenWindow_SettingTimeSeries(void);
       void                            CloseWindow_SettingTimeSeries(void);
       void                            OnTimer_SettingTimeSeries(void);
       void                            OnEvent_Window_SettingTimeSeries(const int id,const long &lparam, const double &dparam, const string &sparam);
       bool                            TableCellFromId(const string cell_id, int &col, int &row);
       void                            ShowIndicatorSavePending(void);
       // For Tab m_tabs_setting_timeseries on Setting Windows m_window_setting_timeseries
        bool                           CreateTab_SettingTimeSeries(const int x_gap, const int y_gap);
       // For Indicator Setting
        // For TreeView Indicator Template Setting
         bool                            CreateTreeView_IndicatorTemplateSetting(const int x_gap, const int y_gap);
         void                            PopulateTreeView_IndicatorTemplateSetting(void);
         void                            SyncTreeView_IndicatorTemplateSetting(void);
        // For Table Indicator Template Setting
         bool                            CreateTable_IndicatorTemplateSetting(const int x, const int y);
         void                            UpdateRow_IndicatorTemplateSetting(const int row);
        // For Add Form to Indicator Template Setting
        //Helper
         static void                     SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw);
         int                             GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[]);
        //Handler for Indicator TreeView on the Left m_treeview_indicator.
         bool                            CreateAddIndicatorForm(const int x_gap, const int y_gap);
         void                            ShowAddIndicatorForm(const ENUM_INDICATOR type);
         void                            HideAddIndicatorForm(void);
         void                            OnClickAddIndicatorBtnOnForm(void);
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
         void                            OnClickTreeView_SymbolTFSetting(const long item_id);
       // For Symbol/TF Setting Table m_table_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
         bool                            CreateTable_SymbolTFSetting(const int x, const int y);
         void                            PopulateTable_SymbolTFSetting(void);
         void                            SyncTable_SymbolTFSetting(void);
         void                            DeleteRow_SymbolTFSetting(const string sym, const string tf_text);
         int                             FindTableRowBySymbolTF(const string &sym, const string &tf_text);
         void                            OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col);
       // For Candle Pattern Setting implementation in Implementation in GUIPannel_SettingWindows_CandlePattern.mqh
         //For working with JSON
          void                            LoadCandlePatternSetting_FromJSON(void);
          void                            BuildJsonSection_PatternAlerts(string &out_json) const;
         // Every Save button rewrites the whole Config_Setting.json from LIVE values. Implementation in GUIPannel_Lifecycle.mqh.
          void                            SaveAllSettingsToJSON(void);
         //For Table_CandlePatternSetting
          void                            InitializeTable_CandlePatternSetting(void);
          bool                            CreateTable_CandlePatternSetting(const int x, const int y);
          int                             FindPatternIndexByRow(const int row);
          void                            OnCheckTableCandlePatternSetting(const int row, const int col);
        // For Candle Pattern
          bool                           PatternSignalBuy(const ENUM_PATTERN_TYPE type) const;
          bool                           PatternSignalSell(const ENUM_PATTERN_TYPE type) const;
          CBarPatternControl            *PatternControlAt(const int i) const;
       // For Swing setting implementation in GUIPannel_SettingWindows_TS_Swing.mqh - JSON is CSwingSetting's own job
         //For Table_SwingSetting
          void                            InitializeTable_SwingSetting(void);
          bool                            CreateTable_SwingSetting(const int x, const int y);
          void                            OnCheckTableSwingSetting(const int row, const int col);
         //For Strength (N) + Wick/Body - live params, shared by every Symbol+TF
          bool                            CreateSwingParamControls(const int x, const int y);
          void                            ApplySwingParams(const int strength, const ENUM_SWING_PRICE_BASIS basis);
          void                            OnChangeSwingParams(void);
     // For Setting Marker and Sound Windows implementation in GUIPannel_SettingWindows_MarkerAndSound.mqh
       bool                            CreateWindow_SettingMarkerAndSound(const string caption_text,const int x_gap, const int y_gap);
       void                            OpenWindow_SettingMarkerAndSound(void);
       void                            CloseWindow_SettingMarkerAndSound(void);
      // Working with JSON 
        void                            LoadMarkerSettingsFromJSON(void);
        void                            BuildJsonSection_Markers(string &out_json);
        void                            LoadSoundSettingsFromJSON(string &out_trailing_sound_file);
        void                            BuildJsonSection_Sound(string &out_json);   // reads the 3 checkboxes + trailing combo live
       // For Tab m_tabs_setting_markerAndSound on Setting Windows m_window_setting_markerAndSound
        bool                            CreateTab_SettingMarkerAndSound(const int x_gap, const int y_gap);
        bool                            CreateTab_SettingConfig_Marker(const int x, const int y);
        bool                            CreateTab_SettingConfig_Sound(const int x, const int y);
        void                            ScanSoundFolder(string &files[]);
        void                            ApplyTrailingSoundToAllSymbols(const string trailing_sound, const bool enabled);
        bool                            CreateCheckBox_SoundEnable(CCheckBox &checkbox, const int x, const int y, const bool pressed);
       // Handle Event on Windows
        void                            OnEvent_Window_SettingMarkerAndSound(const int id,const long &lparam, const double &dparam, const string &sparam);
       // For Marker shape/color settings
         bool                            CreateCombobox_MarkerSelection(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index, const int tab_index = ENUM_TAB_SETTING_MARKERANDSOUND_MARKER);
         //bool                            CreateTextLabel_OtherCaption(const int row, const string text, const int x, const int y, const int tab_index = ENUM_TAB_SETTING_MARKERANDSOUND_MARKER);         
         bool                            CreateTextLabel_ShapePreview(const int row, const int x, const int y, const int arrow_code);
         bool                            CreateColorButton_Preview(const int row, const int x, const int y, const color clr);
         void                            UpdateShapePreview(const int row, const int arrow_code);
         void                            UpdateColorPreview(const int row, const color clr);
         void                            GetMarkerArrowCodeChoices(int &codes[], string &labels[]);
         void                            GetMarkerColorChoices(color &colors[], string &labels[]);
         string                          ArrowLabelForCode(const int code);
         int                             ArrowCodeForLabel(const string label, const int default_code);
         string                          ColorLabelForValue(const color clr);
         color                           ColorForLabel(const string label, const color default_color);         
     // For Setting Trading Windows implementation in GUIPannel_SettingWindows_Trading.mqh
       bool                            CreateWindow_SettingTrading(const string caption_text,const int x_gap, const int y_gap);
       void                            OpenWindow_SettingTrading(void);
       void                            CloseWindow_SettingTrading(void);
       void                            OnEvent_Window_SettingTrading(const int id,const long &lparam, const double &dparam, const string &sparam);
      // For Tab m_tabs_setting_timeseries on Setting Windows m_window_setting_timeseries
       bool                            CreateTab_SettingTrading(const int x_gap, const int y_gap);
      // For Stop Lost Setting implementation in GUIPannel_SettingWindows_TradingStopLost.mqh       
       bool                            CreateTable_StopLostSetting(const int x, const int y);
       bool                            SyncTable_StopLostSetting(bool force = false);   
      //For Form             
       bool                            CreateStopLostForm(const int x_gap, const int y_gap);
       void                            ShowStopLostForm(const string symbol);
       void                            HideStopLostForm(void);
      //For ATR Combobox
       bool                            SyncComboBox_ATRChoice(const string symbol, const ENUM_TIMEFRAMES saved_tf, const int saved_period);
       bool                            GetSelectedATRChoice(const string symbol, ENUM_TIMEFRAMES &out_tf, int &out_period);
       void                            UpdateStopLostPreview(const string symbol);      
       int                             BuildATRChoiceList(const string symbol, ENUM_TIMEFRAMES &out_tf[], int &out_period[]);
     // For Trailing Setting implementation in GUIPannel_SettingWindows_TradingTrailing.mqh
       bool                            CreateTable_TrailingSetting(const int x, const int y);
       bool                            SyncTable_TrailingSetting(bool force = false);
       bool                            CreateTable_IndicatorsTrailingSetting(const int x, const int y);
       bool                            SyncTable_IndicatorsTrailingSetting(const string symbol, bool force = false);
       void                            OnCheckTable_IndicatorsTrailingSetting(const int row);
       bool                            CreateTrailingForm(const int x_gap, const int y_gap);
       void                            ShowTrailingForm(const string symbol);
       void                            HideTrailingForm(void);      
       int                             BuildTrailingIndicatorChoiceList(const string symbol, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[]);
     // For Candle info popup Implementation in GUIPannel_CandleInfo_Windows.mqh
       bool                            MouseOverAnyGUIWindow(const int px, const int py);
       datetime                        CalculateAtCandle(const int x, const int y);
       //For Candle Info Window
        void                            RepositionWindow_CandleInfo(const int cursor_x, const int cursor_y);
        void                            ShowWindow_CandleInfo(const int cursor_x, const int cursor_y);
        void                            HideWindow_CandleInfo(void);
        bool                            CreateWindow_CandleInfo(void);
        bool                            RefreshWindow_CandleInfo(const datetime bar_time);
       //For Candle Pattern
        bool                            CreatePatternHoverElements(void);
        void                            ShowPatternBitmapAtBar(const datetime bar_time);
        void                            HidePatternBitmapAtBar(void);
        void                            ShowTooltip_CandlePatternInfo(CBarPattern *pat);
        void                            RepositionTooltip_CandlePatternInfo(void);
       // Handling Event at Candle Info Window
        void                            OnEvent_Window_CandleInfor(const int id,const long &lparam, const double &dparam, const string &sparam);

     // For Sound and Message Alerts Module Implementation in GUIPannel_SoundAndMessageAlerts.mqh
        //void                            PlaySoundCloseBar(void);
        void                            PlaySoundForDirection(const bool is_buy);
        void                            CheckIndicatorAlerts(void);
        void                            CheckCandlePatternAlerts(void);
        void                            CheckSwingAlerts(void);                       // closed-bar only - a Swing exists only once confirmed
        //ENUM_PATTERN_DIRECTION          CheckPatternLive(ENUM_PATTERN_TYPE pattern_type, MqlRates &rates, CBarPatternControl *ctrl);
        ENUM_PATTERN_DIRECTION          DetectPatternOnBar0(const ENUM_PATTERN_TYPE pattern_type, CBarSeriesDE *series);
        void                            ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name,
                                                        ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key,
                                                        const string label, const string tf_text, const int digits,
                                                        const bool buy_on, const bool sell_on, const bool symtf_buy, const bool symtf_sell);      
     
    public:
     // Lifecycle method implemented in GUIPannel_Lifecycle.mqh
                                        CGUIPannel(void);
                                        ~CGUIPannel(void);
       bool                           OnInitEvent(const int uninit_reason = REASON_PROGRAM);
       void                           OnDeinitEvent(const int reason);
       void                           OnTimerEvent(void);
       void                           OnTickEvent(void);
       void                           OnTradeEvent(void);
       void                           OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
      //For GUI 
       void                           UpdateGUI(const bool redraw = false);        
       CWindow *                      GetMainWindowPointer(void) { return &m_window_main; }       
     //For Indicator Template Table
       void                            SyncTable_IndicatorTemplateSetting(void);
       void                            InitializeTable_IndicatorTemplateSetting(void);
     // For Pointer
       void                           SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { m_indicator_template_manager = manager; }     
       void                           SetSymbolsCollection(CSymbolsCollection *symbols) { m_symbol_collection = symbols; }      
       void                           SetTimeSeriesCollection(CBarTimeSeriesCollection *ts) { m_BarTimeSeriesCollection = ts;} 
       void                           SetPatternsControl(CBarPatternsControl* ctrl) { m_BarPatterns_Control = ctrl; }
       void                           SetSwingSetting(CSwingSetting* setting)       { m_SwingSetting = setting; }
       void                           SetIndicatorsCollection(CIndicatorsCollection *ind) { m_IndicatorsCollection = ind;}
       void                           SetSignalsCollection(CSignalsCollection *signals) { m_SignalsCollection = signals;}
       void                           SetTradingEngine(CTradingEngine *trading_engine) { m_tradingEngine = trading_engine; }
       void                           SetMarketCollection(CMarketCollection *market)      { m_market_collection = market; }
       void                           SetAccountsCollection(CAccountsCollection *acc)     { m_accounts_collection = acc; }
       void                           SetTradingControl(CTradingControl *trading_control) { m_trading_control = trading_control; }
       void                           SetChartObjCollection(CChartObjCollection *coll)    { m_chart_obj_collection = coll; }
       void                           SetSymbolTFManager(CSymbolTFManager *manager) { m_SymbolTFManager = manager; }
       void                           SetGraphElementsCollection(CGraphElementsCollection *coll) { m_graph_elements = coll; }
       void                           SetTradingSetupManager(CTradingSetupSettingManager *manager) { m_trading_setup_manager = manager; }
     // For Marker
      void                            GetMarkerSettings(int &single_buy, int &single_sell, int &multi_buy, int &multi_sell,
                                                           int &pattern_buy, int &pattern_sell, int &combo_buy, int &combo_sell,
                                                           int &swing_high, int &swing_low,
                                                           color &buy_clr, color &sell_clr, color &nonrelated_clr) const;
     // Deletes legacy signal-arrow chart objects
      //void                           PurgeSignalArrowObjects(const string sym, const string tf_string);
   };
#endif // CGUIPannel_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
//For implementation seperation in module
 #include "GUIPannel_Lifecycle.mqh"   //Implementation of Init, Deinit and other lifecycle events
 //For Implemetation Each Window in cluding Event    
  #include "GUIPannel_MainWindows.mqh" //Implementation of function Main Windows m_window_main
   #include "GUIPannel_MainWindows_TabTrading.mqh"
  #include "GUIPannel_SettingWindows_TimeSeries.mqh"
   // Implementation for each tab
    #include "GUIPannel_SettingWindows_TS_Indicator.mqh"
    #include "GUIPannel_SettingWindows_TS_IndicatorAddForm.mqh"
    #include "GUIPannel_SettingWindows_TS_SymbolTF.mqh"
    #include "GUIPannel_SettingWindows_TS_CandlePattern.mqh"
    #include "GUIPannel_SettingWindows_TS_Swing.mqh"
  #include "GUIPannel_SettingWindows_Trading.mqh"
   #include "GUIPannel_SettingWindows_TradingStopLost.mqh"
   #include "GUIPannel_SettingWindows_TradingTrailing.mqh"
  #include "GUIPannel_SettingWindows_Alert.mqh"
   //Implementation for each Tab
    #include "GUIPannel_SettingWindows_Alert_Marker.mqh"
    #include "GUIPannel_SettingWindows_Alert_Sound.mqh" 
  #include "GUIPannel_CandleInfo_Windows.mqh" 
  #include "GUIPannel_SoundAndMessageAlerts.mqh"
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
