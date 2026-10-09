//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//--- The graphical interface only: it shows what the models hold and
//--- reports what the user changed, it calculates nothing
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__
#include "GUIPannel_Define.mqh"
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
  class CGUIPannel
   {
    private:
      bool                                m_gui_created;                       // false until the GUI is built; survives a chart-change re-init so controls are not created twice
     // Private Pointer variables, every model is owned by the EA
      CSymbolTFManager                   *m_SymbolTFManager;
      CSmartMoneySetting                 *m_SmartMoneySetting;                 // shared Swing Strength + Wick/Body and the Show/Sound/Message flags
      CIndicatorTemplateManager          *m_IndicatorTemplateManager;
      CPatternManager                    *m_PatternManager;
      CMarkerSetting                     *m_MarkerSetting;                    // colors and sources of the CCandleMarker badges
      CIndicatorsCollection              *m_IndicatorsCollection;             // the indicators with the state Python reports, the Trading tab shows it
      CSymbolsCollection                 *m_SymbolsCollection;                // the Market Watch symbols: the New Order Symbol list
      CGraphElementsCollection           *m_graph_elements;                    // ZOrder of every canvas element
      long                                m_chart_id;
      int                                 m_subwin;
     // For Layer 2 GUI Control Elements implementation in GUIPannel_MainWindows.mqh
      CWindow                             m_window_main;
      CStatusBar                          m_status_bar;
      CMenuBar                            m_menu_bar;
      CContextMenu                        m_contextmenu_settings;
     // Main Tabs
      CTabs                               m_tabs_main;
     // Setting Window for: Indicator, Symbol/TF and Smart Money (Swing, BOS, CHoCH); the Candle Pattern tab comes later
      CWindow                             m_window_setting_timeseries;
     // Setting Marker and Sound window (GUIPannel_SettingWindows_Alert.mqh); the Sound tab comes later
      CWindow                             m_window_setting_markerAndSound;
       CTabs                              m_tabs_setting_markerAndSound;
       // --- Marker tab (GUIPannel_SettingWindows_Alert_Marker.mqh) ---
        CFrame                            m_frame_color;                       // Color for Marker
        CComboBox                         m_combo_color_buy;
        CComboBox                         m_combo_color_sell;
        CButton                           m_colorbutton[2];                    // color swatch: Buy, Sell
        CFrame                            m_frame_marker_source;               // Show Marker
        CCheckBox                         m_checkbox_show_indicator_markers;
        CCheckBox                         m_checkbox_show_candle_markers;
        CCheckBox                         m_checkbox_show_smartMoney_markers;
        CButton                           m_btn_save_marker_settings;
     // Trading tab of m_window_main (GUIPannel_MainWindows_TabTrading.mqh)
      CButtonsGroup                       m_btngroup_tf_switch;                // the chart Symbol's TFs (+ "All" with 2+), filters the monitor
      CTable                              m_table_indicator_PreTradeSymbolMonitor;
      CTable                              m_table_position_pretrade_view;
      CTable                              m_table_positions_StoplostAndTrailling;
      CCheckBox                           m_checkbox_use_RiskPerNewTrade;
      CTextEdit                           m_edit_RiskPerNewTrade;
      CComboBox                           m_combobox_order_type;
      CTextEdit                           m_edit_order_type_value;
      CButton                             m_btn_send_toTrade;
      bool                                m_new_order_is_buy;                  // Direction of the New Order, flipped by the Direction icon
      double                              m_new_order_lot_last;                // Lot the user picked last, restored when the list is rebuilt
     // Candle information popup (GUIPannel_CandleInfo_Windows.mqh)
      CWindow                             m_window_candle_infomation;
      CTable                              m_table_candle_information_atBar;
      datetime                            m_candle_info_shown_bar;             // 0 = popup hidden
      bool                                m_candle_info_by_marker;             // opened by a CCandleMarker: stays while the cursor is on it
       CTabs                              m_tabs_setting_timeseries;
       // --- Indicator Setting tab (GUIPannel_SettingWindows_TS_Indicator.mqh, ..._TS_IndicatorAddForm.mqh) ---
        CTreeView                         m_treeview_indicator;
        long                              m_type_node_id[];                    // CTreeView item id of each indicator type leaf
        ENUM_INDICATOR                    m_type_node_value[];                 // ENUM_INDICATOR of that leaf
        CFrame                            m_frame_indicator_parameter;         // the Add form
        CTextEdit                         m_param_edits[INDICATOR_PARAM_SLOTS_MAX];   // plain numeric params, caption = param name
        CComboBox                         m_param_combo[INDICATOR_PARAM_SLOTS_MAX];   // enum-like params (Method, Applied Price...)
        CButton                           m_btn_add_indicator;
        CButton                           m_btn_save_indicator;
        ENUM_INDICATOR                    m_current_param_type;                // type the form shows, IND_CUSTOM = none
        CTable                            m_table_indicator_template;
       // --- Candle Pattern Setting tab (GUIPannel_SettingWindows_TS_CandlePattern.mqh) ---
        CTable                            m_table_CandlePatternsSetting;
        CButton                           m_btn_save_pattern_config;
       // --- Symbol/TF Setting tab (GUIPannel_SettingWindows_TS_SymbolTF.mqh) ---
        CTreeView                         m_treeview_SymbolTF;
        CTable                            m_table_SymbolTFSeting;
        CButton                           m_btn_save_SymbolTF;
       // --- Smart Money Setting tab (GUIPannel_SettingWindows_TS_Swing.mqh) ---
        CTable                            m_table_SmartMoneySetting;
        CButton                           m_btn_save_swing_config;
        CTextEdit                         m_edit_swing_strength;               // N - spin edit, caption "Strength"
        CCheckBox                         m_checkbox_swing_wick;               // ticked = Wick, unticked = Body
     //Private Method
     // For GUI implemented in GUIPannel_Lifecycle.mqh
      bool                                CreateGUIPannel(void);
     // For Main Window m_window_main implementation in GUIPannel_MainWindows.mqh
      bool                                CreateWindow_Main(const string caption_text,const int x_gap,const int y_gap);
      void                                OnEvent_Window_Main(const int id,const long &lparam,const double &dparam,const string &sparam);
     //For status Bar on the bottom of Main Window
      bool                                CreateStatusBar(const int x_gap,const int y_gap);
      bool                                UpdateStatusBar(void);
     //For MenuBar on top of Main Window
      bool                                CreateMenuBar(const int x_gap,const int y_gap);
     //For Main Tab
      bool                                CreateTab_Main(const int x_gap,const int y_gap);
     // For Setting Windows m_window_setting_timeseries implementation in GUIPannel_SettingWindows_TimeSeries.mqh
      bool                                CreateWindow_SettingTimeSeries(const string caption_text,const int x_gap,const int y_gap);
      void                                OpenWindow_SettingTimeSeries(void);
      void                                OnEvent_Window_SettingTimeSeries(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTab_SettingTimeSeries(const int x_gap,const int y_gap);
     // For the Setting Marker and Sound window implementation in GUIPannel_SettingWindows_Alert.mqh
      bool                                CreateWindow_SettingMarkerAndSound(const string caption_text,const int x_gap,const int y_gap);
      void                                OpenWindow_SettingMarkerAndSound(void);
      bool                                CreateTab_SettingMarkerAndSound(const int x_gap,const int y_gap);
      void                                OnEvent_Window_SettingMarkerAndSound(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Marker tab implementation in GUIPannel_SettingWindows_Alert_Marker.mqh
      bool                                CreateTab_SettingConfig_Marker(const int x,const int y);
      bool                                CreateFrame_MarkerSource(const int x,const int y,const int w,const int h,const int column_x);
      bool                                CreateCombobox_MarkerSelection(CComboBox &combo,const int x,const int y,const int combo_w,string &labels[],const int selected_index,const int tab_index=ENUM_TAB_SETTING_MARKERANDSOUND_MARKER);
      bool                                CreateCheckBox_Setting(CCheckBox &checkbox,const int x,const int y,const bool pressed,const int tab_index,const int width);
      bool                                CreateColorButton_Preview(const int row,const int x,const int y,const color clr);
      void                                UpdateColorPreview(const int row,const color clr);
      void                                ApplyShowToAllSmartMoney(const bool on);
      void                                SyncMarkerSourceCheckBoxes(void);
      void                                OnEvent_Tab_Marker(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Trading tab implementation in GUIPannel_MainWindows_TabTrading.mqh
      bool                                CreateTFSwitchButtons(const int x_gap,const int y_gap);
      void                                Sync_CButtonsGroup_TFSwitchButtons(void);
      void                                OnClick_CButtonsGroup_TFSwitchButton(void);
      bool                                CreateTable_PreTradeSymbolMonitor(const int x,const int y);
      bool                                SyncTable_PreTradeSymbolMonitor(const string symbol,bool force=false);
      bool                                CreateTradingForm(const int x_gap,const int y_gap);
      void                                UpdateSendButtonAppearance(void);
      void                                OnClickUseRiskPerNewTradeCheckbox(void);
      void                                OnClickSendNewOrder(void);
      bool                                CreateTable_PositionPretradeView(const int x,const int y);
      bool                                SyncComboBox_NewOrderSymbol(void);
      bool                                SyncTable_PositionPretradeView(bool force=false);
      void                                OnSymbolToTradeChanged(const bool move_chart=true);
      void                                OnClickTogglePretradeDirection(void);
      void                                OnClickTogglePretradeSLType(void);
      void                                OnClickTogglePretradeTrailType(void);
      bool                                CreateTable_PositionsStoplostAndTrailling(const int x,const int y);
      string                              GetNewOrderSymbol(void)  { return m_table_position_pretrade_view.Cell(COL_PTV_SYMBOL,0).Value(); }
      double                              GetNewOrderLot(void)     { return ::StringToDouble(m_table_position_pretrade_view.Cell(COL_PTV_LOT,0).Value()); }
     // For the Candle information popup implementation in GUIPannel_CandleInfo_Windows.mqh
      bool                                CreateWindow_CandleInfo(void);
      void                                RepositionWindow_CandleInfo(const int cursor_x,const int cursor_y);
      void                                HideWindow_CandleInfo(void);
      void                                OnEvent_Window_CandleInfor(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For Indicator Setting implementation in GUIPannel_SettingWindows_TS_Indicator.mqh
      bool                                CreateTreeView_IndicatorTemplateSetting(const int x_gap,const int y_gap);
      void                                PopulateTreeView_IndicatorTemplateSetting(void);
      void                                SyncTreeView_IndicatorTemplateSetting(void);
      bool                                CreateTable_IndicatorTemplateSetting(const int x,const int y);
      void                                InitializeTable_IndicatorTemplateSetting(void);
      void                                UpdateRow_IndicatorTemplateSetting(const int row);
      void                                OnClickRemoveIndicator(const int row);
      void                                OnCheckTableIndicatorTemplateSetting(const int row,const int col,const bool on);
      void                                OnEvent_Tab_Indicator(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Indicator Add form implementation in GUIPannel_SettingWindows_TS_IndicatorAddForm.mqh
      bool                                CreateCFrame_IndicatorParameter(const int x_gap,const int y_gap);
      void                                ShowCFrame_IndicatorParameter(const ENUM_INDICATOR type);
      int                                 GetIndicatorGuiLayout(const ENUM_INDICATOR type,SIndicatorLayout &out[]);
      void                                SetLayoutSlot(SIndicatorLayout &out[],const int idx,const int r,const int c,const int tw,const int fw);
      void                                OnClickAddIndicatorBtnOnForm(void);
     // For Candle Pattern Setting implementation in GUIPannel_SettingWindows_TS_CandlePattern.mqh
      bool                                CreateTable_CandlePatternSetting(const int x,const int y);
      void                                InitializeTable_CandlePatternSetting(void);
      void                                OnCheckTableCandlePatternSetting(const int row,const int col,const bool on);
      void                                OnEvent_Tab_CandlePattern(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For Symbol/TF Setting implementation in GUIPannel_SettingWindows_TS_SymbolTF.mqh
      bool                                CreateTreeView_SymbolTFSetting(const int x_gap,const int y_gap);
      void                                PopulateTreeView_SymbolTFSetting(void);
      void                                SyncTreeView_SymbolTFSetting(void);
      void                                OnClickTreeView_SymbolTFSetting(const long item_id);
      bool                                CreateTable_SymbolTFSetting(const int x,const int y);
      void                                PopulateTable_SymbolTFSetting(void);
      void                                SyncTable_SymbolTFSetting(void);
      void                                DeleteRow_SymbolTFSetting(const string sym,const string tf_text);
      void                                OnCheckTableSymbolTFSetting(const string sym,const string tf_text,const int col,const bool on);
      void                                OnEvent_Tab_SymbolTF(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For Smart Money Setting implementation in GUIPannel_SettingWindows_TS_Swing.mqh
      bool                                CreateTable_SmartMoneySetting(const int x,const int y);
      void                                InitializeTable_SmartMoneySetting(void);
      void                                OnCheckTableSmartMoneySetting(const int row,const int col,const bool on);
      bool                                CreateSwingParamControls(const int x,const int y);
      void                                OnChangeSwingParams(void);
      void                                OnEvent_Tab_SmartMoney(const int id,const long &lparam,const double &dparam,const string &sparam);
    public:
     // Lifecycle methods implemented in GUIPannel_Lifecycle.mqh
                                          CGUIPannel(void);
                                         ~CGUIPannel(void);
      bool                                OnInit(const int uninit_reason=REASON_PROGRAM);
      void                                OnDeinit(const int reason);
      void                                OnTimerEvent(void);
      void                                OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Candle information popup: the EA decides when it opens, OnEvent_Window_CandleInfor closes it
      bool                                MouseOverAnyGUIWindow(const int px,const int py);
      datetime                            BarTimeFromXY(const int px,const int py);
      bool                                IsWindow_CandleInfoVisible(void) const { return m_candle_info_shown_bar!=0; }
      bool                                RefreshWindow_CandleInfo(const int count,const string &row_label[],const string &row_tf[],
                                                                   const ENUM_SIGNAL_DIR &row_dir[],const datetime &row_time[],const int &row_source[]);
      void                                ShowWindow_CandleInfo(const int cursor_x,const int cursor_y,const datetime bar_time,const bool by_marker);
     // For Pointer
      void                                SetSymbolTFManager(CSymbolTFManager *manager)               { m_SymbolTFManager=manager;      }
      void                                SetSmartMoneySetting(CSmartMoneySetting *setting)           { m_SmartMoneySetting=setting;    }
      void                                SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { m_IndicatorTemplateManager=manager; }
      void                                SetPatternManager(CPatternManager *manager)                  { m_PatternManager=manager;      }
      void                                SetMarkerSetting(CMarkerSetting *setting)                    { m_MarkerSetting=setting;       }
      void                                SetIndicatorsCollection(CIndicatorsCollection *collection)   { m_IndicatorsCollection=collection; }
      void                                SetSymbolsCollection(CSymbolsCollection *collection)        { m_SymbolsCollection=collection; }
      void                                SetGraphElementsCollection(CGraphElementsCollection *coll)  { m_graph_elements=coll;          }
   };
#endif // CGUIPANNEL_MQH_DECLARATION
 #include "GUIPannel_Lifecycle.mqh"                    //Implementation of Init, Deinit and other lifecycle events
 #include "GUIPannel_MainWindows.mqh"                  //Implementation of Main Window m_window_main
  #include "GUIPannel_MainWindows_TabTrading.mqh"
 #include "GUIPannel_SettingWindows_TimeSeries.mqh"    //Implementation of the Setting Time Series window
  #include "GUIPannel_SettingWindows_TS_Indicator.mqh"
  #include "GUIPannel_SettingWindows_TS_IndicatorAddForm.mqh"
  #include "GUIPannel_SettingWindows_TS_SymbolTF.mqh"
  #include "GUIPannel_SettingWindows_TS_CandlePattern.mqh"
  #include "GUIPannel_SettingWindows_TS_Swing.mqh"
 #include "GUIPannel_SettingWindows_Alert.mqh"                   //Implementation of the Setting Marker and Sound window
  #include "GUIPannel_SettingWindows_Alert_Marker.mqh"
 #include "GUIPannel_CandleInfo_Windows.mqh"                  //Implementation of the Candle information popup
#endif // __GUIPANNEL_MQH__
