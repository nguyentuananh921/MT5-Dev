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
      CIndicatorTemplateManager          *m_IndicatorTemplateManager;
      CPatternManager                    *m_PatternManager;
      CIndicatorsCollection              *m_IndicatorsCollection;             // the indicators with the state Python reports, the Trading tab shows it
      CSymbolsCollection                 *m_SymbolsCollection;                // the Market Watch symbols: the New Order Symbol list
      CGraphElementsCollection           *m_graph_elements;                    // ZOrder of every canvas element
      CChartObj                          *m_ChartObj;                          // the chart the EA owns: the candle under a pixel
      CTradingSetupSettingManager        *m_TradingSetupManager;               // per-Symbol StopLost+Trailing rows
      CMarketCollection                  *m_MarketCollection;                  // floating profit of a distance in points
      CTradingEngine                     *m_TradingEngine;                     // the distances the Setting Trading window shows
     // For Layer 2 GUI Control Elements implementation in GUIPannel_MainWindows.mqh
      CWindow                             m_window_main;
      CButtonsGroup                       m_btngroup_tf_switch; 
      CStatusBar                          m_status_bar;
      CMenuBar                            m_menu_bar;
      CContextMenu                        m_contextmenu_settings;
      CContextMenu                        m_contextmenu_trading;               // Stop Lost / Trailling on-off of the New Order Symbol
     // Main Tabs
      CTabs                               m_tabs_main;
     // Setting Window for: Indicator, Symbol/TF and Smart Money (Swing, BOS, CHoCH); the Candle Pattern tab comes later
      CWindow                             m_window_setting_timeseries;
     // Trading tab of m_window_main (GUIPannel_MainWindows_TabTrading.mqh)                     
      CTable                              m_table_indicator_PreTradeSymbolMonitor;
      CTable                              m_table_position_pretrade_view;
      CTable                              m_table_positions_StoplostAndTrailling;
     // Market Story tab of m_window_main (GUIPannel_MainWindows_TabMarketStory.mqh)
      CTable                              m_table_market_story;
      CArrayObj                           *m_story_conditions;                 // PythonBridge owns: every change of Market State / Phase
      CArrayObj                           *m_story_movements;                  // PythonBridge owns: every leg between two Swings
      CMarketConditionSetting             *m_story_setting;                    // EA owns: the colour of each Market Phase
      
      CComboBox                           m_combobox_order_type;
      CTextEdit                           m_edit_order_type_value;
      CButton                             m_btn_send_toTrade;
      bool                                m_new_order_is_buy;                  // Direction of the New Order, flipped by the Direction icon
      double                              m_new_order_lot_last;                // Lot the user picked last, restored when the list is rebuilt
     // Setting Trading window (GUIPannel_SettingWindows_Trading.mqh, ..._TradingStopLost.mqh, ..._TradingTrailing.mqh)
      CWindow                             m_window_setting_trading;
       CTabs                              m_tabs_setting_trading;
        CTable                            m_table_stoplostsetting;
        CTable                            m_table_trailingsetting;
        CTable                            m_table_indicators_trailingsetting;
        CLabel                            m_label_StopLostSetting_Symbol;      // Symbol the StopLost form is scoped to
        CLabel                            m_label_StopLost_MinPts;             // server floor (Spread()/2 + TradeStopLevel())
        CFrame                            m_frame_stoplost_setting_fixedmode;
        CFrame                            m_frame_stoplost_setting_indicatormode;
        CTextEdit                         m_edit_StopLost_FixedSelection;      // Fixed's Selection cell, default "Spread"
        CTextEdit                         m_edit_StopLost_FixedPoint;          // Fixed's multiplier on Spread
        CComboBox                         m_combobox_ATR_choice;               // Indicator's Selection cell: ATR template x tracked TF
        CTextEdit                         m_edit_ATR_Multiplexer;              // Indicator's multiplier on the ATR value
        CLabel                            m_label_StopLost_ValuePreview[2];    // Value in Point: 0 = Fixed, 1 = Indicator
        CButton                           m_btn_save_StopLost_Setting;
        CLabel                            m_label_TrailingSetting_Symbol;      // Symbol m_table_indicators_trailingsetting is scoped to
        CFrame                            m_frame_trailling_setting_fixedmode;
        CTextEdit                         m_edit_Trailing_Offset;              // points from the price / the Indicator line
        CTextEdit                         m_edit_Trailing_Start;               // profit in points before trailing starts
        CTextEdit                         m_edit_Trailing_Step;                // minimum improvement in points before SL moves
        CTextEdit                         m_edit_Trailing_DataRatesIndex;      // EA-wide M1 bar shift of the Trailing-by-Value base price
        CButton                           m_btn_save_Trailing_Setting;
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
     // For the Trading tab implementation in GUIPannel_MainWindows_TabTrading.mqh
      bool                                BuildTFSwitchButtons(const int x_gap=0,const int y_gap=0);
      ENUM_TIMEFRAMES                     GetTFSwitchSelection(void)  { return TimestampByDescription(m_btngroup_tf_switch.SelectedButtonText()); }   // "All" = PERIOD_CURRENT
      bool                                CreateTable_PreTradeSymbolMonitor(const int x,const int y);
     // For the Market Story tab implementation in GUIPannel_MainWindows_TabMarketStory.mqh
      bool                                CreateTable_MarketStory(const int x,const int y);
      bool                                SyncTable_MarketStory(void);
      void                                FillRow_MarketStory(const int row,const string tf,const ENUM_MARKET_STATE state,const string phase,const ENUM_MARKET_PHASE phase_value,
                                                              const string move,const bool images);
      void                                HighlightTable_MarketStory(void);
      string                              MarketPhaseText(const ENUM_MARKET_PHASE phase) const;
      bool                                SyncTable_PreTradeSymbolMonitor(const string symbol,bool force=false);
      bool                                CreateTradingForm(const int x_gap,const int y_gap);
      void                                UpdateSendButtonAppearance(void);
      void                                OnClickSendNewOrder(void);
      bool                                CreateTable_PositionPretradeView(const int x,const int y);
      bool                                SyncComboBox_NewOrderSymbol(void);
      bool                                SyncTable_PositionPretradeView(bool force=false);
      void                                OnSymbolToTradeChanged(const bool move_chart=true);
      void                                OnClickTogglePretradeDirection(void);
      void                                OnClickTogglePretradeSLType(void);
      void                                OnClickTogglePretradeTrailType(void);
      bool                                SyncTable_PositionsStoplostAndTrailling(void);
      void                                OnClickTogglePositionSLType(const int row);
      void                                OnClickTogglePositionTrailType(const int row);
      void                                OnClickToggleSLOrTrailing(const bool is_sl);
      void                                SyncRunSLTrailingButtonIcons(const bool sl_active,const bool trail_active);
      void                                OnClickOpenTradingSettingTab(const ENUM_TAB_SETTING_TRADING tab);
      bool                                CreateTable_PositionsStoplostAndTrailling(const int x,const int y);
      string                              GetNewOrderSymbol(void)  { return m_table_position_pretrade_view.Cell(COL_PTV_SYMBOL,0).Value(); }
      double                              GetNewOrderLot(void)     { return ::StringToDouble(m_table_position_pretrade_view.Cell(COL_PTV_LOT,0).Value()); }
     // For the Setting Trading window implementation in GUIPannel_SettingWindows_Trading.mqh
      bool                                CreateWindow_SettingTrading(const string caption_text,const int x_gap,const int y_gap);
      void                                OpenWindow_SettingTrading(void);
      void                                OnEvent_Window_SettingTrading(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTab_SettingTrading(const int x_gap,const int y_gap);
     // For the StopLost tab implementation in GUIPannel_SettingWindows_TradingStopLost.mqh
      bool                                CreateTable_StopLostSetting(const int x,const int y);
      bool                                SyncTable_StopLostSetting(void);
      bool                                CreateStopLostForm(const int x_gap,const int y_gap);
      void                                ShowStopLostForm(const string symbol);
      void                                HideStopLostForm(void);
      bool                                SyncComboBox_ATRChoice(const ENUM_TIMEFRAMES saved_tf,const int saved_period);
      bool                                GetSelectedATRChoice(ENUM_TIMEFRAMES &out_tf,int &out_period);
      bool                                UpdateStopLostPreview(const string symbol);
      int                                 BuildATRChoiceList(ENUM_TIMEFRAMES &out_tf[],int &out_period[]);
     // For the Trailing tab implementation in GUIPannel_SettingWindows_TradingTrailing.mqh
      bool                                CreateTable_TrailingSetting(const int x,const int y);
      bool                                SyncTable_TrailingSetting(void);
      bool                                CreateTable_IndicatorsTrailingSetting(const int x,const int y);
      bool                                SyncTable_IndicatorsTrailingSetting(const string symbol,bool force=false);
      void                                OnCheckTable_IndicatorsTrailingSetting(const int row,const bool commit=false);
      bool                                CreateTrailingForm(const int x_gap,const int y_gap);
      void                                ShowTrailingForm(const string symbol);
      void                                HideTrailingForm(void);
      int                                 BuildTrailingIndicatorChoiceList(const string symbol,CIndicatorDE* &out_inds[],ENUM_TIMEFRAMES &out_tfs[]);
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
    public:
     // Lifecycle methods implemented in GUIPannel_Lifecycle.mqh
                                          CGUIPannel(void);
                                         ~CGUIPannel(void);
      bool                                OnInit(const int uninit_reason=REASON_PROGRAM);
      void                                OnDeinit(const int reason);
      void                                OnTickEvent(void);
      void                                OnTimerEvent(void);
      void                                OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Candle information popup: the EA decides when it opens, OnEvent_Window_CandleInfor closes it
      bool                                MouseOverAnyGUIWindow(const int px,const int py);
      bool                                IsWindow_CandleInfoVisible(void) const { return m_candle_info_shown_bar!=0; }
      bool                                RefreshWindow_CandleInfo(const int count,const string &row_label[],const string &row_tf[],
                                                                   const ENUM_SIGNAL_DIR &row_dir[],const datetime &row_time[],const int &row_source[]);
      void                                ShowWindow_CandleInfo(const int cursor_x,const int cursor_y,const datetime bar_time,const bool by_marker);
     // For Pointer
      void                                SetSymbolTFManager(CSymbolTFManager *manager)               { m_SymbolTFManager=manager;      }
      void                                SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { m_IndicatorTemplateManager=manager; }
      void                                SetPatternManager(CPatternManager *manager)                  { m_PatternManager=manager;      }
      void                                SetIndicatorsCollection(CIndicatorsCollection *collection)   { m_IndicatorsCollection=collection; }
      void                                SetSymbolsCollection(CSymbolsCollection *collection)        { m_SymbolsCollection=collection; }
      void                                SetMarketStory(CArrayObj *conditions,CArrayObj *movements,CMarketConditionSetting *setting)
                                                                                                      { m_story_conditions=conditions; m_story_movements=movements; m_story_setting=setting; }
      void                                SetChartObj(CChartObj *chart)                               { m_ChartObj=chart;               }
      void                                SetGraphElementsCollection(CGraphElementsCollection *coll)  { m_graph_elements=coll;          }
      void                                SetTradingSetupManager(CTradingSetupSettingManager *manager) { m_TradingSetupManager=manager; }
      void                                SetMarketCollection(CMarketCollection *collection)           { m_MarketCollection=collection; }
      void                                SetTradingEngine(CTradingEngine *engine)                     { m_TradingEngine=engine;        }
   };
#endif // CGUIPANNEL_MQH_DECLARATION
 #include "GUIPannel_Lifecycle.mqh"                    //Implementation of Init, Deinit and other lifecycle events
 #include "GUIPannel_MainWindows.mqh"                  //Implementation of Main Window m_window_main
  #include "GUIPannel_MainWindows_TabTrading.mqh"
  #include "GUIPannel_MainWindows_TabMarketStory.mqh"
 #include "GUIPannel_SettingWindows_TimeSeries.mqh"    //Implementation of the Setting Time Series window
  #include "GUIPannel_SettingWindows_TS_Indicator.mqh"
  #include "GUIPannel_SettingWindows_TS_IndicatorAddForm.mqh"
  #include "GUIPannel_SettingWindows_TS_SymbolTF.mqh"
  #include "GUIPannel_SettingWindows_TS_CandlePattern.mqh"
 #include "GUIPannel_SettingWindows_Trading.mqh"                 //Implementation of the Setting Trading window
  #include "GUIPannel_SettingWindows_TradingStopLost.mqh"
  #include "GUIPannel_SettingWindows_TradingTrailing.mqh"
 #include "GUIPannel_CandleInfo_Windows.mqh"                  //Implementation of the Candle information popup
#endif // __GUIPANNEL_MQH__
