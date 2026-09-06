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
  extern string g_ea_folder;    // From EA
  extern bool   g_ea_init_done; // From EA - false while OnInit() (incl. REASON_CHARTCHANGE reinit) is still wiring modules
  class CGUIPannel : public CWndEvents
   {
    private:
      CTimeCounter                       m_gui_timecounter;                   //--- Time counters - configured (SetParameters) but not consumed anywhere yet
      CKeys                              m_keys;                              //For Keyboard
      bool                               m_gui_created;                       // guard thay cho s_gui_ready trong EA
     //--- Press-D debug dump snapshot (Anhnt/Claude, 2026-09-02) - see OnEvent's CHARTEVENT_KEYDOWN/'D' handler; general utility, not tied to any one tab.
      string                             m_debug_object_snapshot[];
     // Private Pointer variables
        CSymbolsCollection               *m_symbol_collection;                // CTradingEngine owns
        CBarTimeSeriesCollection         *m_BarTimeSeriesCollection;          // CBarTimeSeriesCollection owns
        CBarPatternsControl              *m_BarPatterns_Control;              // borrowed from EA
        CIndicatorsCollection            *m_IndicatorsCollection;             // CTimeSeriesEngine owns
        CTimeSeriesEngine                *m_timeSeriesEngine;                 // EA owns  
        CTradingEngine                   *m_tradingEngine;                    // EA owns
     // For Single Source of Truth
       CIndicatorTemplateManager       *m_indicator_template_manager;   // EA owns
       CSymbolTFManager                *m_SymbolTFManager;              // EA owns
       CTradingSetupSettingManager     *m_trading_setup_manager;        // EA owns - per-Symbol StopLost+Trailing
     // For CSignalLogger use in GUIPannel_SoundAndMessageAlerts.mqh
        ENUM_SIGNAL_DIR                 m_live_signal_last_seen[];
        ENUM_SIGNAL_DIR                 m_upper_last_seen[];
        ENUM_SIGNAL_DIR                 m_lower_last_seen[];
        ENUM_PATTERN_DIRECTION          m_candle_pattern_last_seen[];
        CSignalLogger                   m_signal_logger;
        bool                            m_signal_log_watermarks_loaded;  
     // For Layer 2 GUI Control Elements implementation in GUIPannel_MainWindows.mqh
        CWindow                          m_window_main;
        CStatusBar                       m_status_bar;
        CMenuBar                         m_menu_bar;
        CContextMenu   m_contextmenu_settings;
      // Main Tabs
        CTabs                            m_tabs_main;
        // ==== TAB_TAB_MAIN_MONITOR (GUIPannel_MainWindows_TabMonitor.mqh) ====
         CTable                          m_table_indicator_SymbolTFMonitor;
         CTable                          m_table_indicator_CurrentTFMonitor;
        // per-row dirty-check cache for Trade tab table
         string                          m_string_table_indicator_SymbolTFMonitor_cache_val[];
         int                             m_int_table_indicator_SymbolTFMonitor_cache_sig_icon[];
         int                             m_int_table_indicator_SymbolTFMonitor_cache_dir_icon[];
         int                             m_int_table_indicator_SymbolTFMonitor_table_row_count;
        // ==== TAB_TAB_MAIN_POSITIONS (GUIPannel_MainWindows_TabPositions.mqh) ====          
          //For Trading
            CComboBox                    m_combobox_symbol_toTrade;
            CComboBox                    m_combobox_lot_toTrade;
            CComboBox                    m_combobox_direction;    //Buy or Sell
            CComboBox                    m_combobox_order_type;
            CCheckBox                    m_checkbox_use_StopLostSetting;
            CButton                      m_btn_send_toTrade;
          // Position info tables (ported verbatim from V1)
            CTable                       m_table_positions;
            datetime                     m_last_deal_time;                     // IsLastDealTicket's own HistorySelect watermark
            ulong                        m_last_deal_ticket;           
        // ==========================================================================
     //For Layer 1 Setting Indicator and Symbol/TF, Candle Pattern
        CWindow                          m_window_setting_timeseries;
      //For tab Inside
        CTabs                            m_tabs_setting_timeseries;
       //For Tab Indicator Setting       
        // TreeView on the left for Indicator Template
          CTreeView                      m_treeview_indicator;
          int                            m_type_node_li[];      // list_index for Type of indicator
          ENUM_INDICATOR                 m_type_node_value[];   //  ENUM_INDICATOR for Type of indicator
          bool                           m_treeview_indicator_need_sync; //Dirty flag for m_treeview_indicator
          bool                           m_table_indicator_need_sync; //Dirty flag for m_table_indicator_template
        // For Indicator Add Form display on click m_treeview_indicator node
         CTextLabel                      m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
         CTextEdit                       m_param_edits[INDICATOR_PARAM_SLOTS_MAX];    // plain numeric params
         CComboBox                       m_param_combo[INDICATOR_PARAM_SLOTS_MAX];    // enum-like params (Method, Applied Price, ...)
         CButton                         m_btn_add_indicator;                         //CButton to Add Indicator
         CButton                         m_btn_save_indicator;                        //CButton to Save Indicator to JSON
         ENUM_INDICATOR                  m_current_param_type;     // which type the form is currently showing
        //For Table at Bottom of the Form, Table m_table_indicator_template
         CTable                          m_table_indicator_template; 
         int                             m_pending_remove_row;                        //Mark row for delete
       // For Symbol TF Setting  
        // For CTreeView on the Left pannel of the Symbol TF Setting
         CTreeView                       m_treeview_SymbolTF;
        // For Symbol TF Setting        
         CTable                          m_table_SymbolTFSeting;
         CButton                         m_btn_save_SymbolTF;
        //Dirty flag for m_treeview_SymbolTF
         bool                            m_treeview_symboltf_need_sync;         
         string                          m_pending_remove_sym_symboltf;
         string                          m_pending_remove_tf_symboltf;
       //For Candle Pattern Setting at Setting Windows
         CTable                          m_table_CandlePatternsSetting;         
         CButton                         m_btn_save_pattern_config;

     //For Trading Setting 
        CWindow                          m_window_setting_trading;
      //For tab Inside
        CTabs                            m_tabs_setting_trading;      
       //For Stop Lost Setting
         CTable                          m_table_stoplostsetting;
       // SL Setting form - embedded inline beside m_table_stoplostsetting 
         CTextLabel                      m_label_StopLostSetting_Symbol;    // Setting symbol
         CButtonsGroup                   m_buttonsGroup_SLMode;             // Fixed or ATR
        //For Fixed
         CTextLabel                      m_label_StopLost_MinPts;           // server-mandated floor (Spread()/2 + TradeStopLevel())                        
         CTextEdit                       m_edit_StopLost_FixedPoint;        // Fixed mode: manual point input
         CTextLabel                      m_label_StopLost_FixedUnit;        // "pts" suffix beside the field
        //For ATR
         CComboBox                       m_combobox_ATR_choice;             // ATR mode: template x tracked-TF choice   
         CTextEdit                       m_edit_ATR_Multiplexer;            // ATR mode: multiplier (unitless)
         CTextLabel                      m_label_StopLost_ATRUnit;          // "x ATR" suffix beside the field
         CTextLabel                      m_label_StopLost_Preview;          // live-computed "Preview SL - X pts"
         string                          m_string_StopLost_setting_current_symbol; // which row's Symbol the form is currently showing
        //For Risk Percentage
         CTextLabel                      m_label_RiskPercentagePerPosition;
         CTextEdit                       m_edit_RiskPercentagePerPosition;          
        //For Save Stop Lost Setting
         CButton                         m_btn_save_StopLost_Setting;
      
     //For Alert Setting Including Marker and Sound
        CWindow                          m_window_setting_markerAndSound;
      //For tab Inside
        CTabs                            m_tabs_setting_markerAndSound;
       //For Marker 8 independent shapes to display at each Candle on Chart see SignalMarkers.mq5        
         CComboBox                       m_combo_shape_single_indicator_buy;  //candle only have single indicator, buy or sell base on indicator signal
         CComboBox                       m_combo_shape_single_indicator_sell; //candle only have single indicator, buy or sell base on indicator signal
         CComboBox                       m_combo_shape_multi_indicator_buy;   //candle have multi indicator, buy or sell base on indicator signal
         CComboBox                       m_combo_shape_multi_indicator_sell;  //candle have multi indicator, buy or sell base on indicator signal
         CComboBox                       m_combo_shape_pattern_buy;           //candle only have pattern, buy or sell base on pattern signal
         CComboBox                       m_combo_shape_pattern_sell;          //candle only have pattern, buy or sell base on pattern signal
         CComboBox                       m_combo_shape_combo_buy;             //candle have combo of indicator and pattern, buy or sell base on combo signal
         CComboBox                       m_combo_shape_combo_sell;            //candle have combo of indicator and pattern, buy or sell base on combo signal
       // Current marker style/color state - loaded from Config_Setting.json's "markers" section at startup,
       // Fed to SignalMarkers.mq5 as iCustom inputs, updated by the Save button above.
         int                             m_marker_single_indicator_buy_code;
         int                             m_marker_single_indicator_sell_code;
         int                             m_marker_multi_indicator_buy_code;
         int                             m_marker_multi_indicator_sell_code;
         int                             m_marker_pattern_buy_code;
         int                             m_marker_pattern_sell_code;
         int                             m_marker_combo_buy_code;
         int                             m_marker_combo_sell_code;
        // Other tab captions/previews - index 0-3 = shape rows (Single Buy/Sell, Multi Buy/Sell), 
        // index 0-2 of the color arrays = Buy/Sell/Non-Related. Preview labels render the ACTUAL Wingdings glyph (Font("Wingdings") 
        // + the raw char code) so the user sees the real shape, not just a number; color previews reuse CColorButton's
        // own swatch rendering, just never wired to a click handler (display-only).
         CTextLabel                      m_label_other_caption[16];
         CTextLabel                      m_preview_shape[16];
         CColorButton                    m_colorbutton [3];
        // For color Marker have 3 colors, independent of shape: Buy/Sell apply when a marker relates to this        
         CComboBox                       m_combo_color_buy;           //color of buy marker
         CComboBox                       m_combo_color_sell;          //color of sell marker
         CComboBox                       m_combo_color_nonrelated;    //color of non-related marker
        //For color
         color                           m_marker_buy_color;          //color of buy marker
         color                           m_marker_sell_color;         //color of sell marker
         color                           m_marker_nonrelated_color;   //color of non-related marker
        //For button Save marker setting
         CButton                         m_btn_save_marker_settings;        
       //For Sound tab - Buy/Sell alert sound file pickers, own tab (split away from Marker)
         string                          m_marker_buy_sound_file;
         string                          m_marker_sell_sound_file;
         CTextLabel                      m_textLabel_sound_folder;
         CComboBox                       m_combo_buy_sound;
         CComboBox                       m_combo_sell_sound;
         CButton                         m_btn_save_sound_settings;
     // For Candle Infor Windows to display signal on chart     
         CWindow                         m_window_candle_infomation;
         CTable                          m_table_candle_information_atBar;
         datetime                        m_candle_info_shown_bar;             // 0 = window currently hidden
         int                             m_active_window_index_before_candle_info; // active window to restore on popup hide (Anhnt, 2026-08-29 - fixes Setting Window going dead after a CandleInfo hover)
         CBarPattern                     *m_pattern_bitmap_shown;             // pattern whose CGCnvPatternBitmap is visible via Alt+hover, NULL = none
         int                             m_pattern_bitmap_scale;              // CHART_SCALE the shown bitmap was built at - forces rebuild on zoom change
         CTooltip                        m_tooltip_candle_info;               // Alt+hover pattern-name label, replaces the raw OBJ_TEXT ShowCandlePatternTooltipInfo used     //Private Method
      //For GUI implemented in in GUIPannel_Lifecycle.mqh
         int                             WindowIdx(CWindow &wnd);
         bool                            CreateGUIPannel();
      //For Main Window m_window_main Implementation in GUIPannel_MainWindow.mqh
          bool                            CreateWindow_Main(const string caption_text,const int x_gap, const int y_gap);
          void                            OnEvent_Window_Main(const int id,const long &lparam, const double &dparam, const string &sparam);
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
      // For Setting Windows m_window_setting_timeseries
          bool                            CreateWindow_SettingTimeSeries(const string caption_text,const int x_gap, const int y_gap);
          void                            OpenWindow_SettingTimeSeries(void);
          void                            CloseWindow_SettingTimeSeries(void);
          void                            OnEvent_Window_SettingTimeSeries(const int id,const long &lparam, const double &dparam, const string &sparam);
       // For Tab m_tabs_setting_timeseries on Setting Windows m_window_setting_timeseries
          bool                            CreateTab_SettingTimeSeries(const int x_gap, const int y_gap);
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
           static void                    SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw);
           int                            GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[]);
          //Handler for Indicator TreeView on the Left m_treeview_indicator.
           bool                            CreateAddIndicatorForm(const int x_gap, const int y_gap);
           void                            ShowAddIndicatorForm(const ENUM_INDICATOR type, const int type_li);
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
       // For Symbol/TF Setting Table m_table_SymbolTFSeting (Settings tab, Symbol TF sub-tab)
          bool                            CreateTable_SymbolTFSetting(const int x, const int y);
          void                            PopulateTable_SymbolTFSetting(void);
          void                            SyncTable_SymbolTFSetting(void);
          void                            DeleteRow_SymbolTFSetting(const string sym, const string tf_text);
          int                             FindTableRowBySymbolTF(const string &sym, const string &tf_text);
          bool                            IsCurrentChartSymbolTFRow(const string sym, const string tf_text);
          void                            OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col);      
       // For Candle Pattern Setting implementation in Implementation in GUIPannel_SettingWindows_CandlePattern.mqh
        //For working with JSON
         void                            LoadCandlePatternSetting_FromJSON(void);
         void                            SaveCandlePatternSettingToJSON(void);
        //For Table_CandlePatternSetting
         void                            InitializeTable_CandlePatternSetting(void);
         bool                            CreateTable_CandlePatternSetting(const int x, const int y);
         int                             FindPatternIndexByRow(const int row);
         void                            OnCheckTableCandlePatternSetting(const int row, const int col); 
        // For Candle Pattern      
         bool                           PatternSignalBuy(const ENUM_PATTERN_TYPE type) const;
         bool                           PatternSignalSell(const ENUM_PATTERN_TYPE type) const;      
         CBarPatternControl            *PatternControlAt(const int i) const;                       
      // For Setting Marker and Sound Windows implementation in GUIPannel_SettingWindows_MarkerAndSound.mqh
          bool                            CreateWindow_SettingMarkerAndSound(const string caption_text,const int x_gap, const int y_gap);
          void                            OpenWindow_SettingMarkerAndSound(void);
          void                            CloseWindow_SettingMarkerAndSound(void);
        // Working with JSON 
         void                            LoadMarkerSettingsFromJSON(void);
         void                            SaveMarkerSettingsToJSON(void);
         void                            LoadSoundSettingsFromJSON(void);         
         void                            SaveSoundSettingsToJSON(void);
        // For Tab m_tabs_setting_markerAndSound on Setting Windows m_window_setting_markerAndSound
          bool                            CreateTab_SettingMarkerAndSound(const int x_gap, const int y_gap);
          bool                            CreateTab_SettingConfig_Marker(const int x, const int y);
          bool                            CreateTab_SettingConfig_Sound(const int x, const int y);
          void                            ScanSoundFolder(string &files[]);
        // Handle Event on Windows
          void                            OnEvent_Window_SettingMarkerAndSound(const int id,const long &lparam, const double &dparam, const string &sparam);
        // For Marker shape/color settings
         bool                            CreateCombobox_MarkerSelection(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index, const int tab_index = ENUM_TAB_SETTING_MARKERANDSOUND_MARKER);
         bool                            CreateTextLabel_OtherCaption(const int row, const string text, const int x, const int y, const int tab_index = ENUM_TAB_SETTING_MARKERANDSOUND_MARKER);         
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
      // For Setting Trading
          bool                            CreateWindow_SettingTrading(const string caption_text,const int x_gap, const int y_gap);
          void                            OpenWindow_SettingTrading(void);
          void                            CloseWindow_SettingTrading(void);
          void                            OnEvent_Window_SettingTrading(const int id,const long &lparam, const double &dparam, const string &sparam);
       // For Tab m_tabs_setting_timeseries on Setting Windows m_window_setting_timeseries
          bool                            CreateTab_SettingTrading(const int x_gap, const int y_gap);
      // For Stop Lost Setting implementation in GUIPannel_SettingWindows_TradingStopLost.mqh
        //For Table 
         bool                            CreateTable_StopLostSetting(const int x, const int y);
         bool                            SyncTable_StopLostSetting(bool force = false);   
        //For Form             
         bool                            CreateStopLostForm(const int x_gap, const int y_gap);
         void                            ShowStopLostForm(const string symbol);
         void                            HideStopLostForm(void);
         //Form component in form 
          bool                            CreateButtonsGroup_SLMode(const int x, const int y);   // attaches to m_tabs_main        
          void                            ToggleStopLostModeState(void);
         //For ATR Combobox 
          bool                            SyncComboBox_ATRChoice(const string symbol, const ENUM_TIMEFRAMES saved_tf, const int saved_period);                 
         
         void                            UpdateStopLostPreview(void);
         int                             GetCurrentStopLostDistancePoints(const string symbol);
         string                          FormatStopLostCacheValue(const string symbol);
         double                          GetStopLostDistancePrice(const string symbol); 
         double                          GetStopLostMoneyValue(const string symbol);      
      //For Candle info popup Implementation in GUIPannel_CandleInfo_Windows.mqh       
          bool                          MouseOverAnyGUIWindow(const int px = INT_MIN, const int py = INT_MIN);       
          datetime                      CalculateAtCandle(void);
       //For Candle Info Window
          void                          RepositionWindow_CandleInfo(const int cursor_x, const int cursor_y);
          void                          ShowWindow_CandleInfo(const int cursor_x, const int cursor_y);
          void                          HideWindow_CandleInfo(void);
          bool                          CreateWindow_CandleInfo(void);
          bool                          RefreshWindow_CandleInfo(const datetime bar_time);
       //For Candle Pattern
          void                          ShowPatternBitmapAtBar(const datetime bar_time);
          void                          HidePatternBitmapAtBar(void);
          void                          ShowTooltip_CandlePatternInfo(CBarPattern *pat);
       // Handling Event at Candle Info Window 
          void                          OnEvent_Window_CandleInfor(const int id,const long &lparam, const double &dparam, const string &sparam);
      
      CTradingLevelBubble             m_trading_bubble;                  
      //For Sound and Message Alerts Implementation in GUIPannel_SoundAndMessageAlerts.mqh       
         void                         CheckIndicatorAlerts(void);
         void                         CheckCandlePatternAlerts(void);
       //Buy/Sell .wav lookup + play - Live-only: resolves against TERMINAL_PATH\Sounds\ only       
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
       
          //--- New Order form (Anhnt/Claude, 2026-09-03) - Symbol/Lot/Direction/Order Type +
          //--- Send button, below the SL Setting form. First draft - controls + the Send button's
          //--- adaptive text/color only, actual OrderSend wiring not done yet.
            bool                         CreateTradingForm(const int x_gap, const int y_gap);
          //--- Refreshes m_btn_send_toTrade's text ("Buy"/"Sell Limit"/...) and color (green=Buy,
          //--- red=Sell) from m_combobox_direction/m_combobox_order_type's CURRENT selection -
          //--- called once at creation and on every ON_CHANGE_GUI from either combobox.
            void                         UpdateSendButtonAppearance(void);
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
        void                           SetTradingSetupManager(CTradingSetupSettingManager *manager) { m_trading_setup_manager = manager; }
       //For Layer 4 Working with file       
        void                           GetMarkerSettings(int &single_buy, int &single_sell, int &multi_buy, int &multi_sell,
                                                           int &pattern_buy, int &pattern_sell, int &combo_buy, int &combo_sell,
                                                           color &buy_clr, color &sell_clr, color &nonrelated_clr) const;
       // Deletes legacy signal-arrow chart objects
        void                           PurgeSignalArrowObjects(const string sym, const string tf_string);
   };
#endif // CGUIPannel_MQH_DECLARATION
#ifndef CGUIPANNEL_MQH_IMPLEMENTATION
#define CGUIPANNEL_MQH_IMPLEMENTATION
//For implementation seperation in module
 #include "GUIPannel_Lifecycle.mqh"   //Implementation of Init, Deinit and other lifecycle events
 //For Implemetation Each Window in cluding Event    
  #include "GUIPannel_MainWindows.mqh" //Implementation of function Main Windows m_window_main
   #include "GUIPannel_MainWindows_TabMonitor.mqh"
   #include "GUIPannel_MainWindows_TabPositions.mqh" 
  #include "GUIPannel_SettingWindows_TimeSeries.mqh"
   // Implementation for each tab
    #include "GUIPannel_SettingWindows_TS_Indicator.mqh"
    #include "GUIPannel_SettingWindows_TS_IndicatorAddForm.mqh"
    #include "GUIPannel_SettingWindows_TS_SymbolTF.mqh" 
    #include "GUIPannel_SettingWindows_TS_CandlePattern.mqh" 
  #include "GUIPannel_SettingWindows_Trading.mqh"
   #include "GUIPannel_SettingWindows_TradingStopLost.mqh" 
  #include "GUIPannel_SettingWindows_Alert.mqh"
   //Implementation for each Tab
    #include "GUIPannel_SettingWindows_Alert_Marker.mqh"
    #include "GUIPannel_SettingWindows_Alert_Sound.mqh" 
  #include "GUIPannel_CandleInfo_Windows.mqh" 
 //For module Sound and Message   
  #include "GUIPannel_SoundAndMessageAlerts.mqh" 
#endif // CGUIPANNEL_MQH_IMPLEMENTATION
#endif // __GUIPANNEL_MQH__
