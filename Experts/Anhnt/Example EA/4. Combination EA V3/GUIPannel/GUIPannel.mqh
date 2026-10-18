//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//--- The graphical interface only: it shows what the models hold and
//--- reports what the user changed, it calculates nothing.
//--- A child of the EA: it gets the chart events from it and handles them itself
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__
#include "GUIPannel_Define.mqh"
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
  class CGUIPannel : public CGBaseObj
   {
    private:
     // Private Pointer variables, every model is owned by the EA
      CGraphElementsCollection           *m_graph_elements;                    // ZOrder of every canvas element
      CSymbolsCollection                 *m_SymbolsCollection;                // the Market Watch symbols: the spread of the chart Symbol
      CAccountsCollection                *m_AccountsCollection;               // the account: the balance of the status bar
      CSymbolTFManager                   *m_SymbolTFManager;                  // the Symbol+TF pairs the combobox of the caption lists
      CPatternManager                    *m_PatternManager;                   // the candle patterns of the Quick Setting tab
      CSwingSetting                      *m_SwingSetting;                     // the settings of the Smart Money tab
      CStructureSetting                  *m_StructureSetting;
      CFvgSetting                        *m_FvgSetting;
      CMomentumCandleSetting             *m_MomentumCandleSetting;
      CSupplyDemandSetting               *m_SupplyDemandSetting;
      CTrendlineSetting                  *m_TrendlineSetting;
      CSupportResistanceSetting          *m_SupportResistanceSetting;
      CIndicatorsCollection              *m_IndicatorsCollection;             // the indicators with the state Python reports: the ATR value, the indicators to trail by
      CTradingSetupSettingManager        *m_TradingSetupManager;              // the Stop Loss and Trailing of each Symbol
      CArrayObj                          *m_story_conditions;                 // Python's State / Phase changes: the Market Phase table
      CArrayObj                          *m_story_movements;                  // its legs between two Swings
      CMarketConditionSetting            *m_story_setting;                    // the colours of the Phases
      CTradingEngine                     *m_TradingEngine;                    // the distances the Stop Loss tab shows
      CIndicatorTemplateManager          *m_IndicatorTemplateManager;         // the indicator templates of the Quick Setting tab
     // For Layer 2 GUI Control Elements implementation in GUIPannel_MainWindows.mqh
      CWindow                             m_window_main;
      CStatusBar                          m_status_bar;
      CMenuBar                            m_menu_bar;
      CComboBox                           m_combobox_SymbolTF;                 // a child of the caption bar of m_window_main: the Symbols of the CSymbolsCollection
      CButtonsGroup                       m_btngroup_tf_switch;                // a child of m_window_main above the tabs: the TFs of the chart Symbol
     // Main Tabs
      CTabs                               m_tabs_main;    
     //Tab Monitor
      CTabs                               m_tabs_monitor;                      // a child of the Trading tab: Indicator, Market Phase
        CTable                            m_table_indicator_PreTradeSymbolMonitor;   // in TAB_MONITOR_INDICATOR
        CTable                            m_table_market_story;                      // in TAB_MONITOR_MARKET_PHASE
     // Quick Setting tab of m_tabs_main (GUIPannel_TabQuickSetting.mqh)
      CTabs                               m_tabs_quickSetting;
      //Candle Tab
        CTable                            m_table_CandlePatternsSetting;
        CButton                           m_btn_save_pattern_config;
        CCheckBox                         m_check_pattern_show;                // the badges of the candle patterns: InpPatternShow at the start
      //Indicator tab
        CTable                            m_table_indicator_template;
        CButton                           m_btn_save_indicator;
        CButton                           m_btn_add_indicator;                 // in the tab: opens m_window_addIndicator
        CCheckBox                         m_check_indicator_show;              // the badges of the indicator templates: InpPatternShow at the start
     // Add Indicator window (GUIPannel_TabQuickSetting_AddIndicator.mqh): the tree of the types and the form of the parameters
      CWindow                             m_window_addIndicator;
     // Trade Manage window (GUIPannel_TabTrading_TradeManage.mqh): the positions of the account
      CWindow                             m_window_tradeManage;
      CTable                              m_table_position;
      CButton                             m_btn_position_columns;
      CButton                             m_btn_tradeManage;                   // in the Trading tab: opens m_window_tradeManage
      ulong                               m_position_reload_at;                // when the table is asked again after a trade event, 0 = not asked
     // Candle information popup (GUIPannel_CandleInfo_Windows.mqh)
      CWindow                             m_window_candle_infomation;
      CTable                              m_table_candle_information_atBar;
      datetime                            m_candle_info_shown_bar;             // 0 = popup hidden
      bool                                m_candle_info_by_marker;             // opened by a CCandleMarker: stays while the cursor is on it
        CTreeView                         m_treeview_indicator;
        long                              m_type_node_id[];                    // CTreeView item id of each indicator type leaf
        ENUM_INDICATOR                    m_type_node_value[];                 // ENUM_INDICATOR of that leaf
        CFrame                            m_frame_indicator_parameter;         // the form
        CTextEdit                         m_param_edits[INDICATOR_PARAM_SLOTS_MAX];   // plain numeric params, caption = param name
        CComboBox                         m_param_combo[INDICATOR_PARAM_SLOTS_MAX];   // enum-like params (Method, Applied Price...)
        CButton                           m_btn_add_indicator_form;            // in the form: gives the manager the new template
        ENUM_INDICATOR                    m_current_param_type;                // type the form shows, IND_CUSTOM = none
      //Symbol TF tab
        CTreeView                         m_treeview_SymbolTF;
        CTable                            m_table_SymbolTFSeting;        
        CButton                           m_btn_save_SymbolTF;
      //Risk Management Tab
        CTabs                             m_tabs_riskManagement;               //A child of the Quick Setting tab of m_tabs_main: it shows and hides with it
       //Smart Money tab of m_tabs_quickSetting (GUIPannel_TabQuickSetting_SmartMoney.mqh): the sections one under the other
        CButton                           m_btn_save_smartmoney;               // the settings are applied and saved when it is clicked, not on every change
        CScrollV                          m_scroll_smart_money;                // the sections are taller than the tab: the scroll moves them
        CButtonTriggered                  m_btn_section_header[SMART_MONEY_SECTION_TOTAL];   // the arrow and the name: opens and closes the body below
        CButtonTriggered                  m_btn_section_toggle[SMART_MONEY_SECTION_TOTAL];    // ON: every Show of the section is on, OFF: every one is off
        CGElement                        *m_section_body[SMART_MONEY_SECTION_TOTAL*SMART_MONEY_BODY_MAX];   // the controls of each body
        int                               m_section_body_x[SMART_MONEY_SECTION_TOTAL*SMART_MONEY_BODY_MAX];   // their x in the body, and the row
        int                               m_section_body_row[SMART_MONEY_SECTION_TOTAL*SMART_MONEY_BODY_MAX];
        int                               m_section_body_total[SMART_MONEY_SECTION_TOTAL];
        int                               m_section_rows[SMART_MONEY_SECTION_TOTAL];                          // the rows of each body
        CTextEdit                         m_edit_swing_strength;               // candles on each side of a Swing
        CCheckBox                         m_check_swing_wick;                  // found on the wicks
        CCheckBox                         m_check_swing_high;                  // the Swing Highs are drawn
        CCheckBox                         m_check_swing_low;                   // the Swing Lows are drawn
        CCheckBox                         m_check_structure_bos;
        CCheckBox                         m_check_structure_choch;
        CCheckBox                         m_check_fvg_bullish;
        CCheckBox                         m_check_fvg_bearish;
        CCheckBox                         m_check_fvg_dead;                    // the filled gaps are drawn
        CTextEdit                         m_edit_fvg_maxdead;                  // how many filled gaps are kept
        CTextEdit                         m_edit_fvg_open_bullish;             // the newest bullish gaps shown from the start
        CTextEdit                         m_edit_fvg_open_bearish;             // the newest bearish gaps shown from the start
        CTextEdit                         m_edit_momentum_bars;                // candles before the momentum candle
        CTextEdit                         m_edit_momentum_multiplier;          // its body against the biggest body before it
        CCheckBox                         m_check_sd_demand;
        CCheckBox                         m_check_sd_supply;
        CCheckBox                         m_check_sd_dead;                     // the filled zones are drawn
        CTextEdit                         m_edit_sd_maxdead;                   // how many filled zones are kept
        CTextEdit                         m_edit_sd_open_demand;               // the newest demand zones shown from the start
        CTextEdit                         m_edit_sd_open_supply;               // the newest supply zones shown from the start
        CCheckBox                         m_check_tl_support;
        CCheckBox                         m_check_tl_resistance;
        CCheckBox                         m_check_tl_dead;                     // the dead lines are drawn
        CTextEdit                         m_edit_tl_maxdead;                   // how many dead lines are kept
        CTextEdit                         m_edit_tl_nearest;                   // the living lines drawn solid per side
        CTextEdit                         m_edit_tl_confirm_atr;               // what Python calculates for the trendlines
        CTextEdit                         m_edit_tl_confirm_closes;
        CTextEdit                         m_edit_tl_min_move;
        CTextEdit                         m_edit_tl_min_swing;
        CTextEdit                         m_edit_tl_swings_tried;
        CCheckBox                         m_check_sr_support;
        CCheckBox                         m_check_sr_resistance;
        CCheckBox                         m_check_sr_dead;                     // the dead zones are drawn
        CTextEdit                         m_edit_sr_maxdead;                   // how many dead zones are kept
        CTextEdit                         m_edit_sr_open_support;              // the newest support zones shown from the start
        CTextEdit                         m_edit_sr_open_resistance;           // the newest resistance zones shown from the start
        CTextEdit                         m_edit_sr_min_score;                 // what Python calculates for the zones
        CTextEdit                         m_edit_sr_confirm_closes;
        CTextEdit                         m_edit_sr_ghost_bars;
        CTextEdit                         m_edit_sr_max_age;
        CTextEdit                         m_edit_sr_volume_ma;
        CCheckBox                         m_check_sr_revive;                   // a broken zone may come back
       //Stop Loss tab of m_tabs_riskManagement (GUIPannel_TabQuickSetting_RiskManagement_StopLost.mqh)
        CFrame                            m_frame_stoplost_setting_fixedmode;
        CFrame                            m_frame_stoplost_setting_indicatormode;
        CTextEdit                         m_edit_StopLost_FixedSelection;      // Fixed's Selection cell, default "Spread"
        CTextEdit                         m_edit_StopLost_FixedPoint;          // Fixed's multiplier on Spread
        CComboBox                         m_combobox_ATR_choice;               // Indicator's Selection cell: ATR template x tracked TF
        CTextEdit                         m_edit_ATR_Multiplexer;              // Indicator's multiplier on the ATR value
        CLabel                            m_label_StopLost_ValuePreview[2];    // Value in Point: 0 = Fixed, 1 = Indicator
        CLabel                            m_label_StopLost_MinPts;             // server floor (Spread()/2 + TradeStopLevel())
        CButton                           m_btn_save_StopLost_Setting;
        CButtonTriggered                  m_btn_stoplost_switch[2];            // in the frames: which mode the Stop Loss uses, [0] Indicator, [1] Fixed; one of them is ON
       //Setup tab of m_tabs_riskManagement (GUIPannel_TabQuickSetting_RiskManagement_Setup.mqh): the risk of a new trade and the Risk Reward Ratio
        CButtonTriggered                  m_btn_setup_header[SETUP_SECTION_TOTAL];   // the arrow and the name: opens and closes the body below
        CButtonTriggered                  m_btn_setup_toggle[SETUP_SECTION_TOTAL];   // ON: the risk of a new trade is used (InpUseRiskPerNewTrade at the start) / the take profit is put by the ratio
        CTextEdit                         m_edit_risk_percent;                 // InpRiskPerNewTrade at the start
        CComboBox                         m_combobox_rrr;                      // 1 : 1 ... 1 : 6
        CButton                           m_btn_save_RiskSetup;
       //Trailing tab of m_tabs_riskManagement (GUIPannel_TabQuickSetting_RiskManagement_Trailing.mqh)
        CTable                            m_table_indicators_trailingsetting;
        CFrame                            m_frame_trailling_setting_fixedmode;
        CTextEdit                         m_edit_Trailing_Offset;              // points from the price / the Indicator line
        CTextEdit                         m_edit_Trailing_Start;               // profit in points before trailing starts
        CTextEdit                         m_edit_Trailing_Step;                // minimum improvement in points before SL moves
        CTextEdit                         m_edit_Trailing_DataRatesIndex;      // EA-wide M1 bar shift of the Trailing-by-Value base price
        CButton                           m_btn_save_Trailing_Setting;
     //Private Method
     // For GUI implemented in GUIPannel_Lifecycle.mqh
      bool                                CreateGUIPannel(void);
     // For Main Window m_window_main implementation in GUIPannel_MainWindows.mqh
      bool                                CreateWindow_Main(const string caption_text,const int x_gap,const int y_gap);
      bool                                CreateComboBox_SymbolTF(const int x_gap,const int y_gap);
      bool                                BuildTFSwitchButtons(const int x_gap=M_CONTROL_BORDER_GAP,const int y_gap=M_TF_SWITCH_Y);
     // The Trading tab (GUIPannel_TabTrading.mqh and its monitor and Trade Manage modules)
      bool                                CreateButton_TradeManage(const int x_gap,const int y_gap);
      bool                                CreateWindow_TradeManage(const string caption_text,const int x_gap,const int y_gap);
      void                                SaveLayout_Position(void);
      void                                LoadLayout_Position(void);
      void                                FillTable_Position(void);
      void                                OnEvent_Window_TradeManage(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTabs_Monitor(const int x_gap,const int y_gap);
      void                                OnEvent_Tab_Trading(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTable_PreTradeSymbolMonitor(const int x,const int y);
      bool                                SyncTable_PreTradeSymbolMonitor(const string symbol,bool force=false);
      bool                                CreateTable_MarketStory(const int x,const int y);
      bool                                SyncTable_MarketStory(void);
      void                                FillRow_MarketStory(const int row,const string tf,const ENUM_MARKET_STATE state,const string phase,const ENUM_MARKET_PHASE phase_value,
                                                              const string move,const bool images);
      void                                HighlightTable_MarketStory(void);
      string                              MarketPhaseText(const ENUM_MARKET_PHASE phase) const;
      ENUM_TIMEFRAMES                     GetTFSwitchSelection(void)  { string text=m_btngroup_tf_switch.SelectedButtonText(); return (text=="All" ? PERIOD_CURRENT : TimestampByDescription(text)); }   // "All" = PERIOD_CURRENT
      void                                SyncComboBox_SymbolTF(void);
      void                                ArrangeComboBox_SymbolTF(void);
     //For status Bar on the bottom of Main Window
      bool                                CreateStatusBar(const int x_gap,const int y_gap);
      void                                UpdateStatusBar_SymbolSpread(void);
      void                                UpdateStatusBar_Balance(void);
     //For Main Tab
      bool                                CreateTab_Main(const int x_gap,const int y_gap);
     //For the Quick Setting tab implementation in GUIPannel_TabQuickSetting.mqh
      bool                                CreateTab_QuickSetting(const int x_gap,const int y_gap);
      bool                                CreateTable_IndicatorTemplateSetting(const int x,const int y);
      void                                InitializeTable_IndicatorTemplateSetting(void);
      void                                UpdateRow_IndicatorTemplateSetting(const int row);
      void                                OnClickRemoveIndicator(const int row);
      void                                OnCheckTableIndicatorTemplateSetting(const int row,const int col,const bool on);
      void                                OnEvent_Tab_Indicator(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateWindow_AddIndicator(const string caption_text,const int x_gap,const int y_gap);
     // For the Candle information popup implementation in GUIPannel_CandleInfo_Windows.mqh
      bool                                CreateWindow_CandleInfo(void);
      bool                                ShownBarColumn(int &left,int &right);
      void                                RepositionWindow_CandleInfo(const int cursor_x,const int cursor_y);
      void                                HideWindow_CandleInfo(void);
      void                                OnEvent_Window_CandleInfor(const int id,const long &lparam,const double &dparam,const string &sparam);
      void                                OpenWindow_AddIndicator(void);
      void                                OnEvent_Window_AddIndicator(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTreeView_IndicatorTemplateSetting(const int x_gap,const int y_gap);
      void                                PopulateTreeView_IndicatorTemplateSetting(void);
      void                                SyncTreeView_IndicatorTemplateSetting(void);
      bool                                CreateCFrame_IndicatorParameter(const int x_gap,const int y_gap);
      void                                ShowCFrame_IndicatorParameter(const ENUM_INDICATOR type);
      void                                OnClickAddIndicatorBtnOnForm(void);
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
      bool                                CreateSections_SmartMoney(const int x,const int y);
      bool                                CreateSection(const ENUM_SMART_MONEY_SECTION section,const string name,const bool on,const bool opened=false);
      void                                AddSectionBody(const ENUM_SMART_MONEY_SECTION section,CGElement &control,const int column,const int row);
      void                                ArrangeSections_SmartMoney(void);
      bool                                SectionOn(const ENUM_SMART_MONEY_SECTION section) const;
      void                                SectionSet(const ENUM_SMART_MONEY_SECTION section,const bool on);
      void                                UpdateSectionToggles(void);
      void                                OnEvent_Tab_SmartMoney(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTabs_RiskManagement(const int x_gap,const int y_gap);
      bool                                CreateStopLostForm(const int x_gap,const int y_gap);
      bool                                CreateSwitch(CButtonTriggered &toggle,const bool on,CGElement &parent,const string name,const int x,const int y);
      int                                 BuildATRChoiceList(ENUM_TIMEFRAMES &out_tf[],int &out_period[]);
      bool                                SyncComboBox_ATRChoice(const ENUM_TIMEFRAMES saved_tf,const int saved_period);
      bool                                GetSelectedATRChoice(ENUM_TIMEFRAMES &out_tf,int &out_period);
      bool                                UpdateStopLostPreview(const string symbol);
      void                                OnEvent_Tab_StopLost(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTable_IndicatorsTrailingSetting(const int x,const int y);
      int                                 BuildTrailingIndicatorChoiceList(const string symbol,CIndicatorDE* &out_inds[],ENUM_TIMEFRAMES &out_tfs[]);
      bool                                SyncTable_IndicatorsTrailingSetting(const string symbol,bool force=false);
      void                                OnCheckTable_IndicatorsTrailingSetting(const int row,const bool commit=false);
      bool                                CreateTrailingForm(const int x_gap,const int y_gap);
      bool                                CreateSetupForm(const int x_gap,const int y_gap);
      void                                ArrangeSections_Setup(void);
      bool                                CreateSectionHeader(CButtonTriggered &header,CButtonTriggered *toggle,const string name,const bool on,const bool opened,CTabs &tabs,const int tab,const string key);
      string                              RiskRewardRatioText(const ENUM_RISK_REWARD_RATIO ratio) const;
      void                                OnEvent_Tab_RiskSetup(const int id,const long &lparam,const double &dparam,const string &sparam);
      void                                ArrangeTrailingForm(void);
      void                                OnEvent_Tab_Trailing(const int id,const long &lparam,const double &dparam,const string &sparam);
      bool                                CreateTable_CandlePatternSetting(const int x,const int y);
      void                                InitializeTable_CandlePatternSetting(void);
      void                                OnCheckTableCandlePatternSetting(const int row,const int col,const bool on);
      void                                OnEvent_Tab_CandlePattern(const int id,const long &lparam,const double &dparam,const string &sparam);
     //For MenuBar on top of Main Window
      bool                                CreateMenuBar(const int x_gap,const int y_gap);
    public:
     // Lifecycle methods implemented in GUIPannel_Lifecycle.mqh
                                          CGUIPannel(void);
                                         ~CGUIPannel(void) {}
      bool                                OnInit(const int uninit_reason=REASON_PROGRAM);
      void                                OnDeinit(const int reason);
      void                                OnTickEvent(void);
      void                                OnTradeEvent(void);
      void                                OnTimerEvent(void);
      virtual void                        OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Candle information popup: the EA decides when it opens, OnEvent_Window_CandleInfor closes it
      bool                                MouseOverAnyGUIWindow(const int px,const int py);
      bool                                IsWindow_CandleInfoVisible(void) const { return m_candle_info_shown_bar!=0; }
      bool                                RefreshWindow_CandleInfo(const int count,const string &row_label[],const string &row_tf[],
                                                                   const ENUM_SIGNAL_DIR &row_dir[],const datetime &row_time[],const int &row_source[]);
      void                                ShowWindow_CandleInfo(const int cursor_x,const int cursor_y,const datetime bar_time,const bool by_marker);
     // For Pointer
      void                                SetGraphElementsCollection(CGraphElementsCollection *coll)  { m_graph_elements=coll; }
      void                                SetSymbolsCollection(CSymbolsCollection *collection)        { m_SymbolsCollection=collection; }
      void                                SetAccountsCollection(CAccountsCollection *collection)      { m_AccountsCollection=collection; }
      void                                SetSymbolTFManager(CSymbolTFManager *manager)               { m_SymbolTFManager=manager; }
      void                                SetPatternManager(CPatternManager *manager)                 { m_PatternManager=manager; }
      void                                SetSwingSetting(CSwingSetting *setting)                     { m_SwingSetting=setting; }
      void                                SetStructureSetting(CStructureSetting *setting)             { m_StructureSetting=setting; }
      void                                SetFvgSetting(CFvgSetting *setting)                         { m_FvgSetting=setting; }
      void                                SetMomentumCandleSetting(CMomentumCandleSetting *setting)   { m_MomentumCandleSetting=setting; }
      void                                SetSupplyDemandSetting(CSupplyDemandSetting *setting)       { m_SupplyDemandSetting=setting; }
      void                                SetTrendlineSetting(CTrendlineSetting *setting)             { m_TrendlineSetting=setting; }
      void                                SetSupportResistanceSetting(CSupportResistanceSetting *setting) { m_SupportResistanceSetting=setting; }
      void                                SetIndicatorsCollection(CIndicatorsCollection *collection)  { m_IndicatorsCollection=collection; }
      void                                SetTradingSetupManager(CTradingSetupSettingManager *manager) { m_TradingSetupManager=manager; }
      void                                SetTradingEngine(CTradingEngine *engine)                    { m_TradingEngine=engine; }
      void                                SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { m_IndicatorTemplateManager=manager; }
      void                                SetMarketStory(CArrayObj *conditions,CArrayObj *movements,CMarketConditionSetting *setting)
                                                                                                   { m_story_conditions=conditions; m_story_movements=movements; m_story_setting=setting; }
   };
#endif // CGUIPANNEL_MQH_DECLARATION
 #include "GUIPannel_Lifecycle.mqh"                    //Implementation of Init, Deinit and other lifecycle events
 #include "GUIPannel_MainWindows.mqh"                  //Implementation of Main Window m_window_main
  #include "GUIPannel_TabQuickSetting.mqh"                //Implementation of the Quick Setting tab of m_tabs_main
   #include "GUIPannel_TabQuickSetting_Indicator.mqh"      //The Indicator marker tab: the table of the indicator templates
   #include "GUIPannel_TabQuickSetting_SymbolTF.mqh"        //The Symbol TF marker tab: the tree and the table of the pairs
   #include "GUIPannel_TabQuickSetting_Candle.mqh"          //The Candle marker tab: the table of the candle patterns
   #include "GUIPannel_TabQuickSetting_RiskManagement.mqh"   //The Risk Management tab
    #include "GUIPannel_TabQuickSetting_RiskManagement_StopLost.mqh"   //  its Stop Loss tab
    #include "GUIPannel_TabQuickSetting_RiskManagement_Trailing.mqh"   //  its Trailing tab
    #include "GUIPannel_TabQuickSetting_RiskManagement_Setup.mqh"      //  its Setup tab
   #include "GUIPannel_TabQuickSetting_SmartMoney.mqh"       //The Smart Money tab
   #include "GUIPannel_TabTrading.mqh"                      //The Trading tab: the monitor tabs
  #include "GUIPannel_TabTrading_MonitorIndicator.mqh"      //  its Indicator tab
  #include "GUIPannel_TabTrading_MonitorMarketPhase.mqh"    //  its Market Phase tab
  #include "GUIPannel_TabTrading_TradeManage.mqh"           //  the Trade Manage button and its window
 #include "GUIPannel_CandleInfo_Windows.mqh"                  //Implementation of the Candle information popup
 #include "GUIPannel_TabQuickSetting_AddIndicator.mqh"    //The Add Indicator window the Indicator marker tab opens
#endif // __GUIPANNEL_MQH__
