//+------------------------------------------------------------------+
//|                                                    GUIPannel.mqh |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __GUIPANNEL_MQH__
#define __GUIPANNEL_MQH__
#include "GUIPannel_Define.mqh"
#ifndef CGUIPANNEL_MQH_DECLARATION
#define CGUIPANNEL_MQH_DECLARATION
  class CGUIPannel : public CGBaseObj
   {
    private:
     // Private Pointer variables, every model is owned by the EA
      CSymbolsCollection                 *m_SymbolsCollection;                // the symbols of this account: the combobox of the caption lists them
      CSymbolTFManager                   *m_SymbolTFManager;                  // the Symbol+TF pairs the TF switch lists
      CIndicatorTemplateManager          *m_IndicatorTemplateManager;         // the indicator templates of the Quick Setting tab
      CBarInformationManager             *m_BarInformationManager;            // the information of a bar (the candle patterns) of the Candle tab
      CStrategyManager                   *m_StrategyManager;                  // the strategies of the Strategy tab
      CBarMarkerCollection               *m_BarMarkerCollection;              // the rows of a candle joined on RAM (load on demand): the popup of a candle asks it
      CGraphElementsCollection           *m_GraphElementsCollection;          // the layer and the markers: the popup lights the box of its candle
      CHistoryCollection                 *m_HistoryCollection;                // the history of the terminal on RAM: the tables of the Trade Manage window are read through it
      CTradingControl                    *m_TradingControl;                   // the changes of the SL / TP of a position (TradingOrderDetail): the Order detail window
      CAccountsCollection                *m_AccountsCollection;               // the account in RAM: the equity of the status bar, the profit of the caption
      CMarketCollection                  *m_MarketCollection;                 // the positions in RAM: their numbers on the caption
     // For Layer 2 GUI Control Elements implementation in GUIPannel_Window_Main.mqh
      CWindow                             m_window_main;
      CStatusBar                          m_status_bar;
      CLabel                              m_status_caption[STATUS_LABELS_TOTAL]; // children of each item of m_status_bar (they move with it): the caption on top,
      CLabel                              m_status_value[STATUS_LABELS_TOTAL];   // its value under it (the item itself has no text)
      CLabel                              m_status_equity_icon;                  // a child of the Equity item: the arrow, moved next to the number (PlaceStatusBar_EquityIcon)
      CMenuBar                            m_menu_bar;
      CComboBox                           m_combobox_SymbolTF;                 // a child of the caption bar of m_window_main: the Symbols of the CSymbolsCollection
      CLabel                              m_label_PositionBuy;                 // children of the caption bar, left of the combobox: the number of the Buy positions (green),
      CLabel                              m_label_PositionSell;                // of the Sell positions (red),
      CLabel                              m_label_Profit;                      // the floating profit (not while the window is collapsed)
      CButtonsGroup                       m_btngroup_tf_switch;                // a child of m_window_main above the tabs: the TFs of the chart Symbol
     // Main Tabs
      CTabs                               m_tabs_main;      
     //Trade tab
      CSections                           m_sections_trade_automation_setting; // the settings of the Automation (Setting_Risk)
      CSections                           m_sections_trade_select;             // the Manual Entry (only the lot is manual): direction, order type, the results of the Automation (SL, TP, MaxLot), the lot chosen
      CButton                             m_btn_tradeManage;                   // in the Trading tab: opens m_window_tradeManage
      CLabel                              m_label_manual_sl;                   // in m_sections_trade_select: the stop of the bases ON for the direction (CTradingControl::ManualPlan)
      CLabel                              m_label_manual_tp;                   // and the take profit
      CLabel                              m_label_manual_maxlot;               // and the MaxLot of the risk (capped by the margin)
      int                                 m_manual_order_type;                 // the row ON in Manual Order Type (0 Market; the others are not sent yet): m_btn_manual_open_position sends it
      CButtonTriggered                    m_btn_triggered_manual_trade_dirrection; // in m_sections_trade_select: pressed Buy, released Sell; m_btn_manual_open_position follows it
      CButton                             m_btn_manual_open_position;          // outside the sections: opens the direction chosen (TRADE_SETUP_EVENT_SEND), its text and colour follow it
      CButton                             m_btn_manual_close_all_Position;     // outside the sections: closes every position of the account (emergency, no confirmation)
      CComboBox                           m_combobox_manual_lot;               // in m_sections_trade_select: MinLot .. MaxLot of the Automation, step VolumeStep (CSymbol)
      CTextEdit                           m_edit_manual_magic;                 // in m_sections_trade_select: the magic of the Manual Entry, typed (first: the EA's)
     // Quick Setting tab of m_tabs_main (GUIPannel_TabQuickSetting.mqh)
      CTabs                               m_tabs_quickSetting;  
     //Indicator tab
        CSections                         m_sections_indicator;   // one section for each group of the indicators: a row for each template, the switches of its flags
        CButton                           m_btn_add_indicator;                 // in the tab: opens m_window_addIndicator
     //Symbol TF tab
      CTreeView                           m_treeview_SymbolTF;
      CTable                              m_table_SymbolTFSeting; 
     //Candle Tab
        CSections                         m_sections_candle;      // one section for each ENUM_BAR_INFORMATION_GROUP: its toggle (the information switch) shows or hides the CBarMarker of the group on the chart, its body has the types
     //Strategy Tab
        CSections                         m_sections_strategy;    // one section for each strategy: its toggles (show, trade, available), a row for each of its slots
     //Risk Management Tab
        CSections                         m_sections_risk;        // one section for each input group of Setting_Risk (grp) with a key shown: a row for each key
        string                            m_risk_groups[];        // the grp of each section of m_sections_risk, in the order of the inputs
     // Trade Manage window (GUIPannel_Window_TradeManager.mqh): the tabs of the positions, the button of the columns of the table of the tab
      CWindow                             m_window_tradeManage;
      CTabs                               m_tabs_tradeManage;
      CButtonTriggered                    m_btn_table_columns;
      CTable                              m_table_trade_history; // the History tab (GUIPannel_Window_TradeManagerTabHistory.mqh): the trades
      CTable                              m_table_open_position; // the Open tab (GUIPannel_Window_TradeManagerPosition.mqh): the positions open now, their SL / TP
      CTable                              m_table_open_position_by_basket;
     // Order detail window (GUIPannel_Window_OrderDetail.mqh): what happened to a position
      CWindow                             m_window_order_detail;
      CTable                              m_table_order_detail;
     // Candle information popup (GUIPannel_Window_CandleInfo.mqh): what was found in a candle, on its TF and the shorter ones
      CWindow                             m_window_candle_infomation;
      CTable                              m_table_candle_information_atBar;
      datetime                            m_candle_info_shown_bar;             // the open time of the candle the popup shows, 0 = hidden
      datetime                            m_candle_info_last_bar;              // the candle the popup was asked for while Shift stays down: it is not asked again
      bool                                m_candle_info_by_marker;             // opened by a CBarMarker: stays while the cursor is on it
     // Add Indicator window (GUIPannel_TabQuickSetting_AddIndicator.mqh): the tree of the types and the form of the parameters
      CWindow                             m_window_addIndicator;
      CTreeView                           m_treeview_indicator;
      CFrame                              m_frame_indicator_parameter;         // the form
      CTextEdit                           m_param_edits[INDICATOR_PARAM_SLOTS_MAX];   // plain numeric params, caption = param name
      CComboBox                           m_param_combo[INDICATOR_PARAM_SLOTS_MAX];   // enum-like params (Method, Applied Price...)
      CButton                             m_btn_add_indicator_form;            // in the form: gives the manager the new template (Save: the slot of a strategy)
      ENUM_INDICATOR                      m_current_param_type;                // type the form shows, IND_CUSTOM = none
      CComboBox                           m_combo_param_tf;                    // in the form: the timeframe of the strategy slot being edited
      long                                m_edit_strategy_id;                  // the form edits a slot of this strategy (Edit of the Strategy tab), WRONG_VALUE = it adds a template
      string                              m_edit_strategy_slot;
     //Private Method
     // For GUI implemented in GUIPannel_Lifecycle.mqh
      bool                                CreateGUIPannel(void);
     // For Main Window m_window_main implementation in GUIPannel_Window_Main.mqh
      bool                                CreateWindow_Main(const string caption_text,const int x_gap,const int y_gap);
      bool                                CreateComboBox_SymbolTF(const int x_gap,const int y_gap);
      bool                                BuildTFSwitchButtons(const int x_gap=M_CONTROL_BORDER_GAP,const int y_gap=M_TF_SWITCH_Y);
      ENUM_TIMEFRAMES                     GetTFSwitchSelection(void);   // "All" = PERIOD_CURRENT
      void                                SyncComboBox_SymbolTF(void);
      void                                ArrangeComboBox_SymbolTF(void);
      bool                                CreateLabel_Caption(void);
      void                                UpdateCaption_Position(void);   // the numbers of the positions and the profit, placed right to left from the combobox
     //For Main Tab
      bool                                CreateTab_Main(const int x_gap,const int y_gap);
     //For the Quick Setting tab implementation in GUIPannel_TabQuickSetting.mqh
      bool                                CreateTab_QuickSetting(const int x_gap,const int y_gap);
     // For the Trade Manage window implementation in GUIPannel_Window_TradeManager.mqh
      bool                                CreateButtons_OpenPosition(void);   // the direction and the Open button: left of Close All in the Trading tab
      void                                SyncButton_OpenPosition(void);      // the text and the icon of m_btn_manual_open_position follow the direction
      bool                                CreateSections_TradingRisk(void);   // m_sections_trade_automation_setting: Auto (ON / OFF, the strategies that trade), Lot Size, Stop Loss, Trailing of Setting_Risk
      void                                PopulateSections_TradingRisk(void); // their rows: the modes and their values, the bases (templates) with the role
     //--- A row [name][switch] / a value of a key of Setting_Risk in the sections of a tab (the Trading tab, the Risk Management tab); flag_icon 0: the name only
      bool                                AddRow_TradingRisk(CTabs &tabs,const int tab,CSections &sections,const int section,const int row,const long value,const string text,const int label_width,
                                                             const uint flag_icon,const int switch_column,const string key,const int slot,const string param="",const bool switch_only=false);
      bool                                AddValue_TradingRisk(CTabs &tabs,const int tab,CSections &sections,const int section,const int row,const int column,const long value,const string param,const double number,const string key,
                                                               const int digits=2,const double step=0.1);
      bool                                AddEnum_TradingRisk(CTabs &tabs,const int tab,CSections &sections,const int section,const int row,const int column,const long value,const string param,
                                                              const string &items[],const int selected,const string key);
      void                                SyncSections_TradingRisk(void);     // the switches, the values and the headers follow Setting_Risk
      string                              BaseIds_TradingRisk(const int section);   // the ids of the bases of Stop Loss / Trailing (their header toggle ON)
      bool                                CreateSections_TradeSelect(void);   // m_sections_trade_select: the Manual Entry (direction, SL, TP, MaxLot, the lot), Order Type
      void                                SyncSections_TradeSelect(void);     // the results of the Automation for the direction (CTradingControl::ManualPlan), the lots up to MaxLot
      bool                                CreateButton_TradeManage(void);
      bool                                CreateButton_CloseAllPosition(void);
      void                                OnEvent_Tab_Trading(const int id,const long &lparam,const double &dparam,const string &sparam);   // GUIPannel_TabTrading.mqh
      bool                                CreateWindow_TradeManage(const string caption_text,const int x_gap,const int y_gap);
      bool                                CreateTabs_TradeManage(void);
      bool                                CreateTable_Trade(CTable &table,const string name,const int tab,const int columns,const string &captions[],const int &widths[],const int &numbers[],
                                                            const int direction_column,const int &spread_columns[],const int detail_column);
      CTable                             *TableOfTab_TradeManage(const int tab);
      string                              LayoutFile_TradeManage(const int tab) const;
      void                                SaveLayout_Table(CTable &table,const string file);
      void                                LoadLayout_Table(CTable &table,const string file);
      int                                 FillTable_Trade(CTable &table,const string &cells[],const int rows,const int columns,const int symbol_column,const int &spread_columns[],
                                                          const int fee_column,const int volume_column,const int commission_column,const int swap_column);
      void                                FormatTradeRows(CTable &table,const int rows,const int symbol_column,const int direction_column,const int profit_column,const int detail_column);
      void                                OpenWindow_TradeManage(void);
      void                                OnEvent_Window_TradeManage(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the History tab of the Trade Manage window implementation in GUIPannel_Window_TradeManagerTabHistory.mqh
      bool                                CreateTable_TradeManagerTabHistory(void);
      void                                FillTable_TradeManagerTabHistory(void);
     // For the Open tab of the Trade Manage window implementation in GUIPannel_Window_TradeManagerPosition.mqh
      bool                                CreateTable_TradeManagerPosition(void);
      void                                FillTable_TradeManagerPosition(void);
     // For the Order detail window implementation in GUIPannel_Window_OrderDetail.mqh
      bool                                CreateWindow_OrderDetail(const string caption_text,const int x_gap,const int y_gap);
      void                                OpenWindow_OrderDetail(const long position_id);
      void                                FillTable_OrderDetail(const long position_id);
     // For the Candle tab implementation in GUIPannel_TabQuickSetting_Candle.mqh
      bool                                CreateSections_BarInformation(void);
      bool                                CreateBody_BarInformation(const int section);
      bool                                CreateBlock_BarInformation(const int section,int &row,const ENUM_BAR_INFOR_TYPE type,const string name,const int candles,const bool have_buy,const bool have_sell,const bool show_buy,const bool show_sell,const bool sound,const bool message);
      void                                SyncSections_BarInformation(void);
      void                                OnEvent_Tab_Candle(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Strategy tab implementation in GUIPannel_TabQuickSetting_Strategy.mqh
      bool                                CreateSections_Strategy(void);
      bool                                AddRow_Strategy(const int section,CStrategySetting *strategy);
      void                                RebuildRows_Strategy(void);
      string                              SlotText_Strategy(CStrategyIndicatorSetting *slot);
      void                                OpenWindow_EditSlot_Strategy(const long value);
      void                                SaveSlot_Strategy(void);
      void                                SyncSections_Strategy(void);
      void                                OnEvent_Tab_Strategy(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Risk Management tab implementation in GUIPannel_TabQuickSetting_Risk.mqh
      bool                                KeyShown_RiskSetting(CRiskSetting *risk,const int index);
      bool                                CreateSections_RiskSetting(void);
      void                                PopulateSections_RiskSetting(void);
      void                                SyncSections_RiskSetting(void);
      void                                OnEvent_Tab_Risk(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Indicator tab implementation in GUIPannel_TabQuickSetting_Indicator.mqh
      bool                                CreateSections_IndicatorTemplateSetting(const int y);
      bool                                AddRow_IndicatorTemplateSetting(const int section,const int row,const long id,const string display,const bool show,const bool buy,const bool sell,const bool sound,const bool message);
      void                                PopulateSections_IndicatorTemplateSetting(void);
      void                                SyncSections_IndicatorTemplateSetting(void);
   long              RowHandle_IndicatorTemplateSetting(const ENUM_INDICATOR type,const string params_text);
      bool                                TemplateOfId_IndicatorTemplateSetting(const long id,ENUM_INDICATOR &type,string &params_text);
      void                                OnEvent_Tab_Indicator(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Add Indicator window implementation in GUIPannel_TabQuickSetting_AddIndicator.mqh
      bool                                CreateWindow_AddIndicator(const string caption_text,const int x_gap,const int y_gap);
      void                                OpenWindow_AddIndicator(void);
      void                                Mode_AddIndicator(const long strategy_id,const string slot);
      bool                                CreateTreeView_IndicatorTemplateSetting(const int x_gap,const int y_gap);
      void                                PopulateTreeView_IndicatorTemplateSetting(void);
      void                                SyncTreeView_IndicatorTemplateSetting(void);
      bool                                CreateCFrame_IndicatorParameter(const int x_gap,const int y_gap);
      void                                ShowCFrame_IndicatorParameter(const ENUM_INDICATOR type,const string params_text="");
      bool                                ReadCFrame_IndicatorParameter(MqlParam &params[]);
      void                                OnClickAddIndicatorBtnOnForm(void);
      void                                OnEvent_Window_AddIndicator(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Symbol TF tab implementation in GUIPannel_TabQuickSetting_SymbolTF.mqh
      bool                                CreateTreeView_SymbolTFSetting(const int x_gap,const int y_gap);
      void                                PopulateTreeView_SymbolTFSetting(void);
      void                                SyncTreeView_SymbolTFSetting(void);
      void                                OnClickTreeView_SymbolTFSetting(const long item_id);
      bool                                CreateTable_SymbolTFSetting(const int x,const int y);
      void                                PopulateTable_SymbolTFSetting(void);
      void                                SyncTable_SymbolTFSetting(void);
      void                                DeleteRow_SymbolTFSetting(const string sym,const ENUM_TIMEFRAMES tf);
      void                                OnCheckTableSymbolTFSetting(const string sym,const ENUM_TIMEFRAMES tf,const int col,const bool on);
      void                                OnEvent_Tab_SymbolTF(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Candle information popup implementation in GUIPannel_Window_CandleInfo.mqh
      bool                                CreateWindow_CandleInfo(void);
      bool                                MouseOverAnyWindow(const int px,const int py);
      datetime                            BarTimeOfCursor_CandleInfo(const int x,const int y);
      bool                                ShownBarColumn_CandleInfo(int &left,int &right);
      void                                MoveWindow_CandleInfo(const int cursor_x,const int cursor_y);
      int                                 PopulateTable_CandleInfo(const datetime bar_time);
      void                                AddRow_CandleInfo(int &count,const string label,const int source,const ENUM_TIMEFRAMES timeframe,const ENUM_SIGNAL_DIRECTION side,const datetime time,
                                                            string &row_label[],string &row_tf[],int &row_source[],int &row_side[],datetime &row_time[]);
      string                              SourceName_CandleInfo(const int source);
      void                                OpenWindow_CandleInfo(const int cursor_x,const int cursor_y,const datetime bar_time,const bool by_marker);
      void                                HideWindow_CandleInfo(void);
      void                                OnEvent_Window_CandleInfo(const int id,const long &lparam,const double &dparam,const string &sparam);
     //Alert (GUIPannel_SoundAndMessageAlerts.mqh): a new row: its message at once, its sound at the next beat of the timer (the last one of the beats)
      string                              m_alert_sound;
      void                                OnEvent_Alert(const int id,const long &lparam,const double &dparam,const string &sparam);
     //For status Bar on the bottom of Main Window
      bool                                CreateStatusBar(const int x_gap,const int y_gap);
      void                                ArrangeStatusBar(void);   // the labels of the item that stretches take its width (the window changed its width)
      void                                PlaceStatusBar_EquityIcon(void);   // the arrow just left of the centered number
      void                                UpdateStatusBar_BarTime(void);     // the time left of the bar of the chart TF (OnTimerEvent)
      void                                UpdateStatusBar_MarginLevel(void); // the margin level, its colour by MarginLevelSafe / MarginLevelDanger
      void                                UpdateStatusBar_SymbolSpread(void);
      void                                UpdateStatusBar_Equity(const ENUM_SIGNAL_DIRECTION side=SIGNAL_DIRECTION_NONE);
     //For MenuBar on top of Main Window
      bool                                CreateMenuBar(const int x_gap,const int y_gap);
    public:
     // Lifecycle methods implemented in GUIPannel_Lifecycle.mqh
                                          CGUIPannel(void);
                                         ~CGUIPannel(void) {}
      bool                                OnInit(const int uninit_reason=REASON_PROGRAM);
      void                                OnDeinit(const int reason);
      void                                OnTickEvent(void);
      virtual void                        OnTimerEvent(void);
      void                                OnTradeEvent(void);
      void                                OnTradeTransaction(const MqlTradeTransaction &trans);
      virtual void                        OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For Pointer
      void                                SetSymbolsCollection(CSymbolsCollection *collection)        { m_SymbolsCollection=collection; }
      void                                SetSymbolTFManager(CSymbolTFManager *manager)               { m_SymbolTFManager=manager; }
      void                                SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { m_IndicatorTemplateManager=manager; }
      void                                SetBarInformationManager(CBarInformationManager *manager)       { m_BarInformationManager=manager; }
      void                                SetStrategyManager(CStrategyManager *manager)                   { m_StrategyManager=manager; }
      void                                SetBarMarkerCollection(CBarMarkerCollection *collection)        { m_BarMarkerCollection=collection; }
      void                                SetGraphElementsCollection(CGraphElementsCollection *collection) { m_GraphElementsCollection=collection; }
      void                                SetHistoryCollection(CHistoryCollection *collection)            { m_HistoryCollection=collection; }
      void                                SetTradingControl(CTradingControl *control)                     { m_TradingControl=control; }
      void                                SetAccountsCollection(CAccountsCollection *collection)          { m_AccountsCollection=collection; }
      void                                SetMarketCollection(CMarketCollection *collection)              { m_MarketCollection=collection; }
     // The tables of the Trade Manage window are read again (on a trading event)
      void                                RefreshTables_TradeManage(void);
   };
#endif // CGUIPANNEL_MQH_DECLARATION
 #include "GUIPannel_Lifecycle.mqh"                    //Implementation of Init, Deinit and other lifecycle events
 #include "GUIPannel_Window_Main.mqh"                  //Implementation of Main Window m_window_main
  #include "GUIPannel_TabQuickSetting.mqh"             //Implementation of the Quick Setting tab of m_tabs_main
   #include "GUIPannel_TabQuickSetting_Indicator.mqh"   //The Indicator tab: the table of the indicator templates
   #include "GUIPannel_TabQuickSetting_Candle.mqh"      //The Candle tab: a switch for each group of the information of a bar
   #include "GUIPannel_TabQuickSetting_Strategy.mqh"    //The Strategy tab: a section for each strategy, a row for each of its slots
   #include "GUIPannel_TabQuickSetting_Risk.mqh"        //The Risk Management tab: a section for each tier of Setting_Risk, a row for each key
   #include "GUIPannel_TabQuickSetting_AddIndicator.mqh"   //The Add Indicator window, opened by the Add button of the Indicator tab
   #include "GUIPannel_TabQuickSetting_SymbolTF.mqh"   //The Symbol TF tab: the tree and the table of the pairs
 #include "GUIPannel_TabTrading.mqh"                     //The Trading tab of m_tabs_main: the row of buttons, Auto, Lot Size, Stop Loss, Trailing, the Manual Entry
 #include "GUIPannel_Window_TradeManager.mqh"            //The Trade Manage window: the tabs and the helpers of its tables
  #include "GUIPannel_Window_TradeManagerTabHistory.mqh"   //The History tab of the Trade Manage window: the trades
  #include "GUIPannel_Window_TradeManagerPosition.mqh"     //The Open tab of the Trade Manage window: the positions open now
 #include "GUIPannel_Window_OrderDetail.mqh"             //The Order detail window
 #include "GUIPannel_SoundAndMessageAlerts.mqh"        //The message and the sound of a new row
 #include "GUIPannel_Window_CandleInfo.mqh"            //The popup of what was found in a candle
#endif // __GUIPANNEL_MQH__
