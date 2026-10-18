//+------------------------------------------------------------------+
//|                                             GUIPannel_Define.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNELDEFINE_MQH
#define CGUIPANNELDEFINE_MQH
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\GUIDefines.mqh>
 // For GUI controls
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Window.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\StatusBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\ComboBox.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Tabs.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\TreeView.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Frame.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\TradingSetupSettingManager.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\IndicatorsCollection.mqh>
  #include "..\Services\TradingEngine.mqh"
  #include "..\Configuration\TimeSeriesSetting\SwingSetting.mqh"   // the settings the Smart Money tab edits
  #include "..\Configuration\TimeSeriesSetting\StructureSetting.mqh"
  #include "..\Configuration\TimeSeriesSetting\ZoneSetting\FvgSetting.mqh"
  #include "..\Configuration\TimeSeriesSetting\ZoneSetting\MomentumCandleSetting.mqh"
  #include "..\Configuration\TimeSeriesSetting\ZoneSetting\SupplyDemandSetting.mqh"
  #include "..\Configuration\TimeSeriesSetting\TrendlineSetting.mqh"
  #include "..\Configuration\TimeSeriesSetting\MarketConditionSetting.mqh"   // the colours of the Phases in the Market Phase table
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MarketConditionSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MovementSeries.mqh>
  #include "..\Configuration\TimeSeriesSetting\ZoneSetting\SupportResistanceSetting.mqh"
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Trading\TradeDatabase.mqh>   // the positions Python wrote
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\CandleMarker.mqh>   // the badge the popup follows, the box it lights
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\TextEdit.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Button.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\CheckBox.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Table\Table.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Menu\MenuBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Menu\ContextMenu.mqh>
 // Root of every canvas element + ZOrder owner
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\GraphElementsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\SymbolsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\SymbolTFManager.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\PatternManager.mqh>   // the candle patterns the Quick Setting tab edits
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\IndicatorTemplateManager.mqh>   // the indicator templates the Quick Setting tab edits
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\AccountsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\TimeseriesDELib.mqh>   // TimeframeDescription
 // Define GUI control
  #define M_SUBWINDOW_MAIN                0  //The EA runs in the main window of its own chart: one EA instance per chart
  // Main panel window m_window_main
    #define M_WINDOW_MAIN_WIDTH         480   // the Indicator table: 400 + the icon tabs 40 + the borders
    #define M_WINDOW_MAIN_HEIGHT        (480+M_CONTROL_BORDER_GAP+M_CONTROL_BORDER_GAP+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP)   // and the row of the TF switch
    #define M_WINDOW_MIN_WIDTH          300
    #define M_WINDOW_MIN_HEIGHT         200
    #define M_SYMBOLTF_COMBO_WIDTH      130
    #define M_INDICATOR_PARATEXT_WIDTH  230   // LabelText + Icon: the Indicator column
    #define M_SYMBOLTF_COMBO_LIST_HEIGHT 110
    #define M_MENU_BAR_Y                M_CONTROL_HEIGHT   //The menu bar is right below the caption
   //Rows of m_window_main from the top, a M_CONTROL_BORDER_GAP between two of them: caption, menu bar, header of m_tabs_main, body of m_tabs_main.
   //The y of m_tabs_main is the top of its body: its header is the row above it
    #define M_TF_SWITCH_Y               (M_MENU_BAR_Y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP)   // the TF buttons are right below the menu bar
    #define M_TF_WITHOUT_ICON_WIDTH     45    // a TF button
    #define M_TABS_MAIN_Y               (M_TF_SWITCH_Y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP+M_CONTROL_HEIGHT)
  //For menu
    enum ENUM_MENU_ITEM
     {
        MENU_ITEM_HELP,
        MENU_ITEM_TOTAL,
     };
    #define ENUM_MENU_ITEM_WIDTH         85
  //For Tab m_tabs_main
    enum ENUM_TAB_MAIN
     {
      TAB_TAB_MAIN_TRADING,
      TAB_TAB_MAIN_QUICK_SETTING,
      TAB_TAB_MAIN_TOTAL
     };
  //For Tab m_tabs_quickSetting: a column of icon tabs at the left of the Quick Setting tab of m_tabs_main
    enum ENUM_TAB_QUICK_SETTING
     {
      TAB_QUICK_SETTING_INDICATOR, 
      TAB_QUICK_SETTING_SYMBOL_TF, 
      TAB_QUICK_SETTING_CANDLE,    
      TAB_QUICK_SETTING_RISK_MANAGEMENT,
      TAB_QUICK_SETTING_SMART_MONEY,
      TAB_QUICK_SETTING_TOTAL
     };
  //For Risk Management Tab
    enum ENUM_TAB_RISK_MANAGEMENT
     {
      TAB_RISK_MANAGEMENT_STOP_LOST,
      TAB_RISK_MANAGEMENT_STOP_TRAILLING,
      TAB_RISK_MANAGEMENT_SETUP,
      TAB_RISK_MANAGEMENT_TOTAL
     };
  //For Tab Monitor in Tab Trading
   enum ENUM_TAB_MONITOR
     {
      TAB_MONITOR_INDICATOR,
      TAB_MONITOR_MARKET_PHASE,
      TAB_MONITOR_TOTAL
     };
    #define M_TAB_QUICK_SETTING_WIDTH   40   // the icon is 32x32
    #define M_CHECKBOX_SHOW_WIDTH       250  //Checkbox width on Tab Candle Setting
    #define M_BUTTON_SAVE_WIDTH         80
   //m_table_indicator_template: 7 columns: Indicator (delete icon), Group, Buy, Sell, Show on chart, Sound, Message
    #define COLUMNS_INDICATOR_TEMPLATE_TOTAL 7
   //m_window_addIndicator (Add Indicator): the tree of the types (left) and the form of the parameters (right)
    #define PARAM_ROW_H               26    // a control and a gap
    #define INDICATOR_PARAM_LABEL_W   150
    #define INDICATOR_PARAM_FIELD_W   80
    #define M_TREEVIEW_ADDINDICATOR_WIDTH  200   // the tree of the types in the Add Indicator window
    #define INDICATOR_FRAME_W         (M_WINDOW_MAIN_WIDTH - PARAM_FORM_X - 2 * M_CONTROL_BORDER_GAP)   // the form takes what is left of the window, as wide as the main window
    #define INDICATOR_FRAME_H         (M_CONTROL_HEIGHT + INDICATOR_PARAM_SLOTS_MAX * PARAM_ROW_H + M_CONTROL_HEIGHT + 2 * M_CONTROL_BORDER_GAP)   // the caption, a row for each slot, the Add button
    #define PARAM_FORM_X              (M_CONTROL_BORDER_GAP + M_TREEVIEW_ADDINDICATOR_WIDTH + M_CONTROL_BORDER_GAP)
    #define PARAM_FORM_Y              (M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)   // below the caption of the window
    #define M_WINDOW_ADDINDICATOR_WIDTH    M_WINDOW_MAIN_WIDTH
    #define M_WINDOW_ADDINDICATOR_HEIGHT   (PARAM_FORM_Y + INDICATOR_FRAME_H + M_CONTROL_BORDER_GAP)
   //Candle information popup (GUIPannel_CandleInfo_Windows.mqh)
    #define CANDLE_INFO_WINDOW_W        (50+M_ICON16_WIDTH+M_TF_WITHICON_WIDTH+M_INDICATOR_PARATEXT_WIDTH+20)
    #define CANDLE_INFO_WINDOW_H        220
    #define CANDLE_INFO_CURSOR_INSET    15   // how far INSIDE the popup's near edge the cursor sits when it appears, not a gap
    #define CANDLE_INFO_CANDLE_GAP      40   // room between the candle column and the popup: clears a CCandleMarker badge
    #define COLUMNS_CANDLEINFO_TOTAL    4
    #define COL_CI_TIME     0
    #define COL_CI_SOURCE   1
    #define COL_CI_TF       2
    #define COL_CI_INFO     3
    const int CANDLEINFO_WIDTH[COLUMNS_CANDLEINFO_TOTAL] = {50, M_ICON16_WIDTH, M_TF_WITHICON_WIDTH, M_INDICATOR_PARATEXT_WIDTH};
    const ENUM_ALIGN_MODE CANDLEINFO_HEADER_ALIGN[COLUMNS_CANDLEINFO_TOTAL] = {ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_LEFT};
    const ENUM_ALIGN_MODE CANDLEINFO_CONTENT_ALIGN[COLUMNS_CANDLEINFO_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    const int CANDLEINFO_TEXT_X_OFFSET[COLUMNS_CANDLEINFO_TOTAL] = {5, 5, 5, 5};
    const int CANDLEINFO_IMAGE_X_OFFSET[COLUMNS_CANDLEINFO_TOTAL] = {0, 2, 3, 3};
   //Risk Management tab: the forms of the Stop Loss and Trailing tabs (the Symbol is the one of the chart)
    #define M_PRICE_WIDTH              80    // a column that displays a price or the live Value of an indicator
    #define M_CONTROL_YDISTANCE        22    // a control and the row under it
    #define SL_FORM_CAPTION_WIDTH      120
    #define SL_FORM_FIELD_WIDTH        150   // a box of a number, and the button of the ATR choice ("ATR(14) M15")
    #define SL_FORM_FRAME_WIDTH        (M_WINDOW_MAIN_WIDTH - 2 - 2 * M_CONTROL_BORDER_GAP - M_TAB_QUICK_SETTING_WIDTH)   // the frames take the width of the tab
    #define TRAIL_FORM_CAPTION_WIDTH   90
    #define TRAIL_FORM_EDIT_WIDTH      60
    #define TRAIL_FORM_FRAME_WIDTH     (3 * M_CONTROL_BORDER_GAP + 2 * (TRAIL_FORM_CAPTION_WIDTH + TRAIL_FORM_EDIT_WIDTH))   // two fields in a row
    #define TRAIL_FORM_FRAME_HEIGHT    (M_CONTROL_HEIGHT + 2 * M_CONTROL_YDISTANCE + M_CONTROL_BORDER_GAP)   // the caption cut into the border, two rows
    #define TRAIL_IND_TABLE_WIDTH      (2 + 16 + M_TF_WITHICON_WIDTH + M_INDICATOR_PARATEXT_WIDTH - 17 + M_PRICE_WIDTH + M_ICON16_WIDTH)   // border + scrollbar + columns
    #define COLUMNS_IND_TRAIL_TOTAL 4
    const int IND_TRAIL_WIDTH[COLUMNS_IND_TRAIL_TOTAL] = { M_TF_WITHICON_WIDTH, M_INDICATOR_PARATEXT_WIDTH - 17, M_PRICE_WIDTH, M_ICON16_WIDTH };
    const ENUM_ALIGN_MODE IND_TRAIL_HEADER_ALIGN[COLUMNS_IND_TRAIL_TOTAL] = { ALIGN_LEFT, ALIGN_LEFT, ALIGN_CENTER, ALIGN_CENTER };
    const ENUM_ALIGN_MODE IND_TRAIL_CONTENT_ALIGN[COLUMNS_IND_TRAIL_TOTAL] = { ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_CENTER };
    const int IND_TRAIL_TEXT_X_OFFSET[COLUMNS_IND_TRAIL_TOTAL] = { 5, 5, 5, 5 };
    const int IND_TRAIL_IMAGE_X_OFFSET[COLUMNS_IND_TRAIL_TOTAL] = { 3, 0, 0, 2 };
   //The Trade Manage window (GUIPannel_TabTrading_TradeManage.mqh): the columns of the view position_summary, in its order (Python makes the view)
    #define M_BUTTON_TRADEMANAGE_WIDTH   100
    #define M_WINDOW_TRADEMANAGE_WIDTH   900
    #define M_WINDOW_TRADEMANAGE_HEIGHT  380
    #define POSITION_ROWS_MAX            500    // the newest positions shown
    #define POSITION_LAYOUT_FILE         "/Configuration/Table Position Columns.txt"   // under MQL5\Files\<program name>
    enum ENUM_COLUMN_POSITION
     {
      COL_P_POSITION,COL_P_SYMBOL,COL_P_SIDE,COL_P_VOLUME,COL_P_OPEN_TICKET,COL_P_OPEN_TIME,COL_P_OPEN_PRICE,COL_P_OPEN_BID,COL_P_OPEN_ASK,COL_P_OPEN_SPREAD,COL_P_OPEN_SOURCE,
      COL_P_CLOSE_TICKET,COL_P_CLOSE_TIME,COL_P_CLOSE_PRICE,COL_P_CLOSE_BID,COL_P_CLOSE_ASK,COL_P_CLOSE_SPREAD,COL_P_CLOSE_SOURCE,COL_P_NET,
      COLUMNS_POSITION_TOTAL
     };
    const string POSITION_CAPTION[COLUMNS_POSITION_TOTAL]={"Position","Symbol","Side","Volume","Open ticket","Open time","Open price","Open bid","Open ask","Open spread","Open source",
                                                           "Close ticket","Close time","Close price","Close bid","Close ask","Close spread","Close source","Net"};
    const int    POSITION_WIDTH[COLUMNS_POSITION_TOTAL]={80,70,50,55,90,150,80,80,80,80,80,90,150,80,80,80,80,80,70};
    const int    POSITION_NUMBER_COLUMNS[]={COL_P_VOLUME,COL_P_OPEN_PRICE,COL_P_OPEN_BID,COL_P_OPEN_ASK,COL_P_OPEN_SPREAD,COL_P_CLOSE_PRICE,COL_P_CLOSE_BID,COL_P_CLOSE_ASK,COL_P_CLOSE_SPREAD,COL_P_NET};
   //m_table_indicator_PreTradeSymbolMonitor (GUIPannel_TabTrading_MonitorIndicator.mqh)
    #define TRADING_FORM_ROWS_TOTAL   9
    #define TRADING_FORM_HEIGHT       (TRADING_FORM_ROWS_TOTAL * M_CONTROL_YDISTANCE + M_CONTROL_HEIGHT)   // the height of the table: a header and nine rows
    #define COLUMNS_PRETRADEMON_TOTAL 6
    const int PRETRADEMON_WIDTH[COLUMNS_PRETRADEMON_TOTAL] = {M_TF_WITHICON_WIDTH, M_ICON16_WIDTH, M_INDICATOR_PARATEXT_WIDTH, M_PRICE_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH};
    const ENUM_ALIGN_MODE PRETRADEMON_HEADER_ALIGN[COLUMNS_PRETRADEMON_TOTAL] = {ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_CENTER, ALIGN_CENTER};
    const ENUM_ALIGN_MODE PRETRADEMON_CONTENT_ALIGN[COLUMNS_PRETRADEMON_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT};
    const int PRETRADEMON_TEXT_X_OFFSET[COLUMNS_PRETRADEMON_TOTAL] = {5, 5, 5, 5, 5, 5};
    const int PRETRADEMON_IMAGE_X_OFFSET[COLUMNS_PRETRADEMON_TOTAL] = {3, 3, 3, 0, 2, 2};
   //m_table_market_story (GUIPannel_TabTrading_MonitorMarketPhase.mqh)
    #define COLUMNS_MARKETSTORY_TOTAL 4
    #define COL_MS_TF           0
    #define COL_MS_STATE        1
    #define COL_MS_PHASE        2
    #define COL_MS_MOVE         3
    const int MARKETSTORY_WIDTH[COLUMNS_MARKETSTORY_TOTAL] = {M_TF_WITHICON_WIDTH, M_ICON16_WIDTH, M_TF_WITHICON_WIDTH, M_INDICATOR_PARATEXT_WIDTH};   // the State is an icon, the Phase a short word
    const ENUM_ALIGN_MODE MARKETSTORY_HEADER_ALIGN[COLUMNS_MARKETSTORY_TOTAL] = {ALIGN_CENTER, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    const ENUM_ALIGN_MODE MARKETSTORY_CONTENT_ALIGN[COLUMNS_MARKETSTORY_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    const int MARKETSTORY_TEXT_X_OFFSET[COLUMNS_MARKETSTORY_TOTAL] = {5, 5, 5, 5};
    const int MARKETSTORY_IMAGE_X_OFFSET[COLUMNS_MARKETSTORY_TOTAL] = {3, 2, 0, 0};
   //Smart Money tab: a section is a header (arrow, name, toggle) and its body below it; the sections are one under the other
    enum ENUM_SMART_MONEY_SECTION
     {
      SMART_MONEY_SECTION_SWING,
      SMART_MONEY_SECTION_STRUCTURE,          // BOS and CHoCH
      SMART_MONEY_SECTION_FVG,
      SMART_MONEY_SECTION_MOMENTUM_CANDLE,
      SMART_MONEY_SECTION_SUPPLY_DEMAND,
      SMART_MONEY_SECTION_TRENDLINE,
      SMART_MONEY_SECTION_SUPPORT_RESISTANCE,
      SMART_MONEY_SECTION_TOTAL
     };
    enum ENUM_SETUP_SECTION   // the sections of the Setup tab of the Risk Management tab
     {
      SETUP_SECTION_RISK,                     // the risk of a new trade
      SETUP_SECTION_RRR,                      // the Risk Reward Ratio
      SETUP_SECTION_TOTAL
     };
    #define SETUP_BOX_WIDTH            250   // a control of the body of a section of the Setup tab
    #define SMART_MONEY_BODY_MAX       12     // the controls in the body of a section
    #define M_SECTION_HEADER_WIDTH     170
    #define M_SECTION_TOGGLE_WIDTH      60    // the icon and ON / OFF
    #define M_SECTION_BODY_INDENT      20    // the body is under the text of the header
    #define M_SECTION_COLUMN_WIDTH     192   // the second control of a row starts one column after the first; every control of a column is as wide
    #define M_SECTION_EDIT_FIELD_WIDTH 50    // the box of a number, at the right end of its column
    #define M_SECTION_TEXT_X           22    // where the text of a check box starts: the captions of the boxes start there too
   //m_table_SymbolTFSeting: Symbol, TF, Buy, Sell, Sound, Message
    #define COLUMNS_SYMBOLTF_TOTAL 6
    #define M_TREEVIEW_WIDTH            110   // m_treeview_SymbolTF
    #define M_SYMBOL_WITHICON_WIDTH     110   // a column that displays a Symbol+Icon
   //m_table_CandlePatternsSetting: Pattern, No, Buy, Sell, up-arrow legend, Sound, Message, down-arrow legend
    #define COLUMNS_CANDLE_PATTERN_TOTAL 8
  // Status bar items, left to right
   #define STATUS_LABELS_TOTAL 2
   enum ENUM_STATUS_BAR_ITEM
    {
      STATUS_BAR_SYMBOL_SPREAD=0,   // the first item stretches: it takes what the others leave (CStatusBar)
      STATUS_BAR_BALANCE,
    };
   #define M_STATUS_BALANCE_WIDTH      190   // icon + Balance: 99999.99 USD
   const int STATUS_BAR_WIDTH[STATUS_LABELS_TOTAL] = {0, M_STATUS_BALANCE_WIDTH};   // the order of ENUM_STATUS_BAR_ITEM, 0 = stretches
#endif // CGUIPANNELDEFINE_MQH
