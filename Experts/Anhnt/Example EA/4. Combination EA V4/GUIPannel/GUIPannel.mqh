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
      CBarTimeSeriesCollection           *m_BarTimeSeriesCollection;          // the types of information found on a candle: the popup of a candle asks it
      CSignalsCollection                 *m_SignalsCollection;                // the signals of the indicator templates found on a candle: the popup of a candle asks it
      CGraphElementsCollection           *m_GraphElementsCollection;          // the layer and the markers: the popup lights the box of its candle
      CHistoryCollection                 *m_HistoryCollection;                // the table Orders: the tables of the Trade Manage window are read through it
      CAccountsCollection                *m_AccountsCollection;               // the account in RAM: the equity of the status bar, the profit of the caption
      CMarketCollection                  *m_MarketCollection;                 // the positions in RAM: their numbers on the caption
     // For Layer 2 GUI Control Elements implementation in GUIPannel_Window_Main.mqh
      CWindow                             m_window_main;
      CStatusBar                          m_status_bar;
      CMenuBar                            m_menu_bar;
      CComboBox                           m_combobox_SymbolTF;                 // a child of the caption bar of m_window_main: the Symbols of the CSymbolsCollection
      CLabel                              m_label_PositionBuy;                 // children of the caption bar, left of the combobox: the number of the Buy positions (green),
      CLabel                              m_label_PositionSell;                // of the Sell positions (red),
      CLabel                              m_label_Profit;                      // the floating profit (not while the window is collapsed)
      CButtonsGroup                       m_btngroup_tf_switch;                // a child of m_window_main above the tabs: the TFs of the chart Symbol
     // Main Tabs
      CTabs                               m_tabs_main;      
     //Trade tab    
      CButton                             m_btn_tradeManage;                   // in the Trading tab: opens m_window_tradeManage
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
     // Trade Manage window (GUIPannel_Window_TradeManager.mqh): the tabs of the positions, the button of the columns of the table of the tab
      CWindow                             m_window_tradeManage;
      CTabs                               m_tabs_tradeManage;
      CButtonTriggered                    m_btn_table_columns;
      CTable                              m_table_trade_history;               // the History tab (GUIPannel_Window_TradeManagerTabHistory.mqh): the trades
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
      CButton                             m_btn_add_indicator_form;            // in the form: gives the manager the new template
      ENUM_INDICATOR                      m_current_param_type;                // type the form shows, IND_CUSTOM = none     
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
      bool                                CreateButton_TradeManage(void);
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
     // For the Indicator tab implementation in GUIPannel_TabQuickSetting_Indicator.mqh
      bool                                CreateSections_IndicatorTemplateSetting(const int y);
      bool                                AddRow_IndicatorTemplateSetting(const int section,const int row,const long id,const string display,const bool show,const bool buy,const bool sell,const bool sound,const bool message);
      void                                PopulateSections_IndicatorTemplateSetting(void);
      void                                SyncSections_IndicatorTemplateSetting(void);
      bool                                TemplateOfId_IndicatorTemplateSetting(const long id,ENUM_INDICATOR &type,string &params_text);
      void                                OnEvent_Tab_Indicator(const int id,const long &lparam,const double &dparam,const string &sparam);
     // For the Add Indicator window implementation in GUIPannel_TabQuickSetting_AddIndicator.mqh
      bool                                CreateWindow_AddIndicator(const string caption_text,const int x_gap,const int y_gap);
      void                                OpenWindow_AddIndicator(void);
      bool                                CreateTreeView_IndicatorTemplateSetting(const int x_gap,const int y_gap);
      void                                PopulateTreeView_IndicatorTemplateSetting(void);
      void                                SyncTreeView_IndicatorTemplateSetting(void);
      bool                                CreateCFrame_IndicatorParameter(const int x_gap,const int y_gap);
      void                                ShowCFrame_IndicatorParameter(const ENUM_INDICATOR type);
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
     //For status Bar on the bottom of Main Window
      bool                                CreateStatusBar(const int x_gap,const int y_gap);
      void                                UpdateStatusBar_SymbolSpread(void);
      void                                UpdateStatusBar_Equity(const int reason=WRONG_VALUE);
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
      void                                SetBarTimeSeriesCollection(CBarTimeSeriesCollection *collection) { m_BarTimeSeriesCollection=collection; }
      void                                SetSignalsCollection(CSignalsCollection *collection)            { m_SignalsCollection=collection; }
      void                                SetGraphElementsCollection(CGraphElementsCollection *collection) { m_GraphElementsCollection=collection; }
      void                                SetHistoryCollection(CHistoryCollection *collection)            { m_HistoryCollection=collection; }
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
   #include "GUIPannel_TabQuickSetting_AddIndicator.mqh"   //The Add Indicator window, opened by the Add button of the Indicator tab
   #include "GUIPannel_TabQuickSetting_SymbolTF.mqh"   //The Symbol TF tab: the tree and the table of the pairs
 #include "GUIPannel_Window_TradeManager.mqh"            //The Trade Manage window: the tabs and the helpers of its tables
  #include "GUIPannel_Window_TradeManagerTabHistory.mqh"   //The History tab of the Trade Manage window: the trades
 #include "GUIPannel_Window_OrderDetail.mqh"             //The Order detail window
 #include "GUIPannel_Window_CandleInfo.mqh"            //The popup of what was found in a candle
#endif // __GUIPANNEL_MQH__
