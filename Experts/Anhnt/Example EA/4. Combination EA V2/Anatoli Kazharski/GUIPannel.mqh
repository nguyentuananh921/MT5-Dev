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
      bool                                m_gui_created;                       // false until the GUI is built; survives a chart-change re-init so controls are not created twice
     // Private Pointer variables
        CSymbolsCollection               *m_symbol_collection;                // CTradingEngine owns
        CMarketCollection                *m_market_collection;                // CTradingEngine owns
        CAccountsCollection              *m_accounts_collection;              // CTradingEngine owns
        CBarTimeSeriesCollection         *m_BarTimeSeriesCollection;          // CBarTimeSeriesCollection owns        
        CIndicatorsCollection            *m_IndicatorsCollection;             // CTimeSeriesEngine owns
        CSignalsCollection               *m_SignalsCollection;               // CTimeSeriesEngine owns
        CTradingEngine                   *m_tradingEngine;                    // EA owns; also hosts the StopLost/Trailing Apply engine
        CTradingControl                  *m_trading_control;                  // CTradingEngine owns - actually wired, via SetTradingControl() below
     // For Single Source of Truth
       CIndicatorTemplateManager         *m_indicator_template_manager;       // EA owns
       CSymbolTFManager                  *m_SymbolTFManager;                  // EA owns
       CBarPatternsControl               *m_BarPatterns_Control;              // EA owns
       CSwingSetting                     *m_SwingSetting;                     // EA owns (CTimeSeriesEngine::m_SwingSetting) - shared Swing N + Wick/Body
       CTradingSetupSettingManager       *m_trading_setup_manager;            // EA owns - per-Symbol StopLost+Trailing
       CMarkerSetting                    *m_marker_setting;                   // EA owns - the colors of the CCandleMarker badges
     // For CSignalLogger use in GUIPannel_SoundAndMessageAlerts.mqh
        CSignalLogger                    m_signal_logger;
        ENUM_PATTERN_DIRECTION           m_candle_pattern_last_seen[];
        datetime                         m_candle_pattern_last_bar[];         // bar 0 time of the last live pattern alert
        bool                             m_signal_log_watermarks_loaded;
     // For graphic Objects 
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
        CTable                           m_table_indicator_PreTradeSymbolMonitor;        
        CTable                           m_table_position_pretrade_view;
        CTable                           m_table_positions_StoplostAndTrailling;
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
        // For Indicator Add Form display on click m_treeview_indicator node
         CFrame                          m_frame_indicator_parameter;
         CTextEdit                       m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params, caption = param name
         CComboBox                       m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
         CButton                         m_btn_add_indicator;                         //CButton to Add Indicator
         CButton                         m_btn_save_indicator;                        //CButton to Save Indicator to JSON
         bool                            m_indicator_save_pending;                    // unsaved template change - keeps m_btn_save_indicator visible
         ENUM_INDICATOR                  m_current_param_type;     // which type the form is currently showing, IND_CUSTOM = none
        // For Table at Bottom of the Form, Table m_table_indicator_template
         CTable                          m_table_indicator_template;
       // --- Symbol/TF Setting tab (GUIPannel_SettingWindows_TS_SymbolTF.mqh) ---
        // For CTreeView on the Left pannel of the Symbol TF Setting
         CTreeView                       m_treeview_SymbolTF;
         CTable                          m_table_SymbolTFSeting;
         CButton                         m_btn_save_SymbolTF;         
       // --- Candle Pattern Setting tab (GUIPannel_SettingWindows_TS_CandlePattern.mqh) ---
         CTable                          m_table_CandlePatternsSetting;
         CButton                         m_btn_save_pattern_config;
       //For Swing setting - 2 fixed rows (High/Low); all values live in m_SwingSetting (EA owns), GUI holds no copy
         CTable                          m_table_SmartMoneySetting;
         CButton                         m_btn_save_swing_config;         
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
         CTextEdit                      m_edit_StopLost_FixedSelection;    // Fixed's Selection cell - editable, default "Spread"
         CTextEdit                      m_edit_StopLost_FixedPoint;        // Fixed's Multiplexer cell - multiplier on Spread
         CComboBox                      m_combobox_ATR_choice;             // Indicator's Selection cell - template x tracked-TF choice
         CTextEdit                      m_edit_ATR_Multiplexer;            // Indicator's Multiplexer cell - multiplier on ATR value
         CLabel                         m_label_StopLost_ValuePreview[2];  // live-computed Value in Point: 0=Fixed, 1=Indicator
        //For Save Stop Lost Setting
         CButton                        m_btn_save_StopLost_Setting;       
       //m_table_indicators_trailingsetting declared above alongside m_table_stoplostsetting
         CLabel                         m_label_TrailingSetting_Symbol;    // which Symbol m_table_indicators_trailingsetting is currently scoped to
         CFrame                         m_frame_trailling_setting_fixedmode; //Text = Fixed Mode
         CTextEdit                      m_edit_Trailing_Offset;            // shared - offset (points) from the current price / Indicator's line
         CTextEdit                      m_edit_Trailing_Start;             // shared - profit (points) required before trailing starts
         CTextEdit                      m_edit_Trailing_Step;              // shared - minimum improvement (points) before moving SL
         CTextEdit                      m_edit_Trailing_DataRatesIndex;    // EA-wide (not per-Symbol) - M1 bar shift for Trailing-by-Value's base price
         CButton                        m_btn_save_Trailing_Setting;
     // Setting Window for Alert: Marker On Chart and Sound
      CWindow                          m_window_setting_markerAndSound;      
      CTabs                            m_tabs_setting_markerAndSound;
       // Current marker color state - loaded from Config_Setting.json's "markers" section at startup,
       // updated by the Save button below.
        CButton                         m_colorbutton[3];            // color swatch, no color picker in Lib V2
       // For color Marker have 3 colors, independent of shape: Buy/Sell apply when a marker relates to this 
        CFrame                          m_frame_color;               //Text = Color for Marker       
        CComboBox                       m_combo_color_buy;           //color of buy marker
        CComboBox                       m_combo_color_sell;          //color of sell marker
        CComboBox                       m_combo_color_nonrelated;    //color of non-related marker
        CFrame                          m_frame_marker_source;
        CCheckBox                       m_checkbox_show_indicator_markers; 
        CCheckBox                       m_checkbox_show_candle_markers;
        CCheckBox                       m_checkbox_show_smartMoney_markers; 
       //For button Save marker setting
        CButton                         m_btn_save_marker_settings;        
       // For Sound tab - Buy/Sell alert sound file pickers, own tab (split away from Marker)
        string                          m_marker_buy_sound_file;
        string                          m_marker_sell_sound_file;
        CLabel                          m_textLabel_sound_folder;
        CComboBox                       m_combo_buy_sound;
        CComboBox                       m_combo_sell_sound;
        CComboBox                       m_combo_trailling_sound;
        // On/Off per sound - a picked file alone can't be silenced otherwise
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
       bool                             m_candle_info_by_marker;             // the popup was opened by a CCandleMarker and stays while the cursor is on it
     //Private Method
     // For GUI implemented in in GUIPannel_Lifecycle.mqh       
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
         int                             BuildSymbolIndicatorMonitorList(const string symbol,const ENUM_TIMEFRAMES tf_filter, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[]);
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
         void                            Sync_CButtonsGroup_TFSwitchButtons(void);   // adds a button for each TF CSymbolTFManager has that the group lacks
         void                            OnClick_CButtonsGroup_TFSwitchButton(void);
     // For Setting Windows m_window_setting_timeseries
       bool                              CreateWindow_SettingTimeSeries(const string caption_text,const int x_gap, const int y_gap);
       void                              OpenWindow_SettingTimeSeries(void);
       void                              OnEvent_Window_SettingTimeSeries(const int id,const long &lparam, const double &dparam, const string &sparam);
       void                              ShowIndicatorSavePending(void);
       // For Tab m_tabs_setting_timeseries on Setting Windows m_window_setting_timeseries
        bool                             CreateTab_SettingTimeSeries(const int x_gap, const int y_gap);
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
         bool                            CreateCFrame_IndicatorParameter(const int x_gap, const int y_gap);
         void                            ShowCFrame_IndicatorParameter(const ENUM_INDICATOR type);
         void                            OnClickAddIndicatorBtnOnForm(void);
        //Event Handler for m_table_indicator_template
         void                            OnClickToggleShowIndicatorOnChart(const int row, const bool on);
         void                            OnClickToggleBuySignal(const int row, const bool on);
         void                            OnClickToggleSellSignal(const int row, const bool on);
         void                            OnClickToggleSoundAlert(const int row, const bool on);
         void                            OnClickToggleMessageAlert(const int row, const bool on);
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
         void                            OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int col, const bool on);
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
          void                            OnCheckTableCandlePatternSetting(const int row, const int col, const bool on);
        // For Candle Pattern
          CBarPatternControl            *PatternControlAt(const int i) const;
       // For Swing setting implementation in GUIPannel_SettingWindows_TS_Swing.mqh - JSON is CSwingSetting's own job
         //For Table_SwingSetting
          void                            InitializeTable_SmartMoneySetting(void);
          bool                            CreateTable_SmartMoneySetting(const int x, const int y);
          void                            OnCheckTableSmartMoneySetting(const int row, const int col, const bool on);
          void                            ApplyShowToAllSmartMoney(const bool on);
         //For Strength (N) + Wick/Body - live params, shared by every Symbol+TF
          bool                            CreateSwingParamControls(const int x, const int y);
          void                            ApplySwingParams(const int strength, const ENUM_SWING_PRICE_BASIS basis);
          void                            OnChangeSwingParams(void);
     // For Setting Marker and Sound Windows implementation in GUIPannel_SettingWindows_MarkerAndSound.mqh
       bool                               CreateWindow_SettingMarkerAndSound(const string caption_text,const int x_gap, const int y_gap);
       void                               OpenWindow_SettingMarkerAndSound(void);
      // Working with JSON 
        void                            LoadSoundSettingsFromJSON(string &out_trailing_sound_file);
        void                            BuildJsonSection_Sound(string &out_json);   // reads the 3 checkboxes + trailing combo live
       // For Tab m_tabs_setting_markerAndSound on Setting Windows m_window_setting_markerAndSound
        bool                            CreateTab_SettingMarkerAndSound(const int x_gap, const int y_gap);
        bool                            CreateTab_SettingConfig_Marker(const int x, const int y);
        bool                            CreateFrame_MarkerSource(const int x, const int y, const int w, const int h, const int column_x);
        bool                            CreateTab_SettingConfig_Sound(const int x, const int y);
        void                            ScanSoundFolder(string &files[]);
        void                            ApplyTrailingSoundToAllSymbols(const string trailing_sound, const bool enabled);
        bool                            CreateCheckBox_Setting(CCheckBox &checkbox, const int x, const int y, const bool pressed,
                                                               const int tab_index = ENUM_TAB_SETTING_MARKERANDSOUND_SOUND, const int width = 0);
       // Handle Event on Windows
        void                            OnEvent_Window_SettingMarkerAndSound(const int id,const long &lparam, const double &dparam, const string &sparam);
       // For Marker color settings
         bool                            CreateCombobox_MarkerSelection(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index, const int tab_index = ENUM_TAB_SETTING_MARKERANDSOUND_MARKER);
         //bool                            CreateTextLabel_OtherCaption(const int row, const string text, const int x, const int y, const int tab_index = ENUM_TAB_SETTING_MARKERANDSOUND_MARKER);         
         bool                            CreateColorButton_Preview(const int row, const int x, const int y, const color clr);
         void                            UpdateColorPreview(const int row, const color clr);
     // For Setting Trading Windows implementation in GUIPannel_SettingWindows_Trading.mqh
       bool                            CreateWindow_SettingTrading(const string caption_text,const int x_gap, const int y_gap);
       void                            OpenWindow_SettingTrading(void);
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
       //For Candle Info Window
        void                            RepositionWindow_CandleInfo(const int cursor_x, const int cursor_y);
        void                            HideWindow_CandleInfo(void);
        bool                            CreateWindow_CandleInfo(void);
       // Handling Event at Candle Info Window
        void                            OnEvent_Window_CandleInfor(const int id,const long &lparam, const double &dparam, const string &sparam);

     // For Sound and Message Alerts Module Implementation in GUIPannel_SoundAndMessageAlerts.mqh
        //void                            PlaySoundCloseBar(void);
        void                            PlaySoundForDirection(const bool is_buy);
        void                            CheckIndicatorAlerts(void);
        void                            OnSignalLiveFlip(const long handle, const ENUM_SIGNAL_DIR dir, const string line);   // SIGNAL_EVENT_LIVE_FLIP: live Sound/Message/CSV
        void                            CheckCandlePatternAlerts(const bool new_bar);
        void                            CheckSwingAlerts(void);                       // closed-bar only - a Swing exists only once confirmed
        void                            CheckMarketStructureAlerts(void);             // closed-bar only - BOS / CHoCH, Message only for now
        //ENUM_PATTERN_DIRECTION          CheckPatternLive(ENUM_PATTERN_TYPE pattern_type, MqlRates &rates, CBarPatternControl *ctrl);
        ENUM_PATTERN_DIRECTION          DetectPatternOnBar0(const ENUM_PATTERN_TYPE pattern_type, CBarSeriesDE *series);
        void                            ProcessBandLine(CSignalBollinger *bb, const int line_idx, const string line_name, const string type_key, const string params_key,
                                                        const string label, const string tf_text, const int digits,
                                                        const bool buy_on, const bool sell_on, const bool symtf_buy, const bool symtf_sell);      
     
    public:
     // Lifecycle method implemented in GUIPannel_Lifecycle.mqh
                                        CGUIPannel(void);
                                        ~CGUIPannel(void);
       bool                           OnInit(const int uninit_reason = REASON_PROGRAM);
       void                           OnDeinit(const int reason);
       void                           OnTimerEvent(void);
       void                           OnTick(const bool new_bar);
       void                           OnTrade(void);
       void                           OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
      //For GUI 
       void                           UpdateGUI(const bool redraw = false);        
       //CWindow *                      GetMainWindowPointer(void) { return &m_window_main; }       
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
       void                           SetMarkerSetting(CMarkerSetting *setting) { m_marker_setting = setting; }
     // For Candle Info popup: the EA decides when it opens, OnEvent_Window_CandleInfor closes it
       bool                           MouseOverAnyGUIWindow(const int px, const int py);
       bool                           IsWindow_CandleInfoVisible(void) const { return m_candle_info_shown_bar != 0; }
       bool                           RefreshWindow_CandleInfo(const int count, const string &row_label[], const string &row_tf[],
                                                               const ENUM_SIGNAL_DIR &row_dir[], const datetime &row_time[], const int &row_source[]);
       void                           ShowWindow_CandleInfo(const int cursor_x, const int cursor_y, const datetime bar_time, const bool by_marker);
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
