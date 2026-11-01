//+------------------------------------------------------------------+
//|                                             GUIPannel_Define.mqh |
//+------------------------------------------------------------------+
//--- The Enums and Macros of CGUIPannel
#ifndef __GUIPANNEL_DEFINE_MQH__
#define __GUIPANNEL_DEFINE_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Defines\GUIDefines.mqh>
 // For GUI controls
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Window.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\StatusBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Menu\MenuBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\ComboBox.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Button.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Frame.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Sections.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\TextEdit.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\ButtonsGroup.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Tabs.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\TreeView.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Table\Table.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Menu\ContextMenu.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Controls\Tooltip.mqh>
 // The models the panel shows
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\AccountsCollection.mqh>   // the equity of the status bar
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\SymbolsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\SymbolTFManager.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\IndicatorTemplateManager.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\BarInformationManager.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\BarTimeSeriesCollection.mqh>   // what was found on a candle
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\SignalsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\HistoryCollection.mqh>   // the table Orders: the tables of the Trade Manage window
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\MarketCollection.mqh>    // the positions: their numbers on the caption
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\GraphElementsCollection.mqh>   // the markers: the popup lights the box of its candle
  #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Graph\Composite\BarMarker.mqh>
 // Define GUI control
  #define M_SUBWINDOW_MAIN                0  //The EA runs in the main window of its own chart: one EA instance per chart
  // Main panel window m_window_main
    #define M_WINDOW_MAIN_WIDTH         480
    #define M_WINDOW_MAIN_HEIGHT        (480+M_CONTROL_BORDER_GAP+M_CONTROL_BORDER_GAP+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP+(M_TAB_MAIN_HEIGHT-M_CONTROL_HEIGHT))   // and the row of the TF switch, the header of the tabs is taller than a row
    #define M_WINDOW_MIN_WIDTH          M_WINDOW_MAIN_WIDTH    // the window is not dragged smaller than it is made: the rows of the tabs would be cut
    #define M_WINDOW_MIN_HEIGHT         M_WINDOW_MAIN_HEIGHT
    #define M_SYMBOLTF_COMBO_WIDTH      130
    #define M_SYMBOLTF_COMBO_LIST_HEIGHT 110
    #define M_CAPTION_LABEL_PADDING     4           // the caption: the labels of the positions and of the profit, left of the combobox, as wide as their text + this on each side
    #define M_CAPTION_LABEL_SLACK       8           // and this more: the text never meets the "..." of CLabel
    #define M_CAPTION_LABEL_GAP         2           // between two of them
    #define M_CAPTION_LABEL_Y           2           // from the top of the caption (the bottom the same)
    #define M_COLOR_CAPTION_LABEL_BACK  clrWhite    // their background: the text (M_COLOR_PROFIT, M_COLOR_LOSS) stands out on the blue caption
    #define M_MENU_BAR_Y                M_CONTROL_HEIGHT   //The menu bar is right below the caption
    #define M_TF_SWITCH_Y               (M_MENU_BAR_Y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP)   // the TF buttons are right below the menu bar
   //Rows of m_window_main from the top, a M_CONTROL_BORDER_GAP between two of them: caption, menu bar, TF switch, header of m_tabs_main, body of m_tabs_main.
   //The y of m_tabs_main is the top of its body: its header is the row above it
    #define M_TAB_MAIN_HEIGHT           40   // the header of m_tabs_main: the icon is 32x32
    #define M_TABS_MAIN_Y               (M_TF_SWITCH_Y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP+M_TAB_MAIN_HEIGHT)
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
    #define M_TAB_QUICK_SETTING_WIDTH   40   // the icon is 32x32
   //m_sections_candle: what a control of a type block stands for (the slot of the control, with the type)
    enum ENUM_CANDLE_SLOT
     {
      CANDLE_SLOT_SHOW_BUY,     // the switch of show_buy_signal
      CANDLE_SLOT_SHOW_SELL,    // the switch of show_sell_signal
      CANDLE_SLOT_SOUND_ALERT,  // the switch of sound_alert
      CANDLE_SLOT_MESSAGE_ALERT,// the switch of message_alert
      CANDLE_SLOT_CANDLES,      // the number of candles of the type
      CANDLE_SLOT_HEADER,       // the arrow and the name: opens the block
      CANDLE_SLOT_PARAM_LABEL,  // the name of a parameter that is a choice of two
      CANDLE_SLOT_PARAM_SWITCH, // a switch of a parameter that is a choice of two (the price basis), its name is the param of the control
      CANDLE_SLOT_PARAM         // an edit of a parameter of the type (its name is the param of the control)
     };
    enum ENUM_CANDLE_COLUMN   // the columns of the body of m_sections_candle
     {
      CANDLE_COLUMN_NAME,      // the arrow and the name of a type
      CANDLE_COLUMN_CANDLES,
      CANDLE_COLUMN_SHOW_BUY,
      CANDLE_COLUMN_SHOW_SELL,
      CANDLE_COLUMN_SOUND_ALERT,
      CANDLE_COLUMN_MESSAGE_ALERT,
      CANDLE_COLUMN_PARAM,     // the edits of the parameters, a little to the right of the name
      CANDLE_COLUMN_PARAM_VALUE, // the box of a parameter: where its switch is when it is a choice
      CANDLE_COLUMN_TOTAL
     };
    #define M_CANDLE_NAME_WIDTH         160   // a row of a type: the name, the candles, then the four switches (the icon of the flag and the switch, no text)
    #define M_CANDLE_CANDLES_WIDTH      30
    #define M_CANDLE_COLUMN_CANDLES     (M_CANDLE_NAME_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_CANDLE_COLUMN_SHOW_BUY  (M_CANDLE_COLUMN_CANDLES+M_CANDLE_CANDLES_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_CANDLE_COLUMN_SHOW_SELL (M_CANDLE_COLUMN_SHOW_BUY+M_FLAG_SWITCH_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_CANDLE_COLUMN_SOUND_ALERT (M_CANDLE_COLUMN_SHOW_SELL+M_FLAG_SWITCH_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_CANDLE_COLUMN_MESSAGE_ALERT (M_CANDLE_COLUMN_SOUND_ALERT+M_FLAG_SWITCH_WIDTH+M_CONTROL_BORDER_GAP)
    enum ENUM_CANDLE_TOGGLE   // the toggles of the header of a section of m_sections_candle
     {
      CANDLE_TOGGLE_SHOW,     // show_buy_signal and show_sell_signal of every type of the group
      CANDLE_TOGGLE_ALERT     // sound_alert and message_alert
     };
    #define M_CANDLE_TOGGLE_SHOW_X    ((M_CANDLE_COLUMN_SHOW_BUY+M_CANDLE_COLUMN_SHOW_SELL+M_FLAG_SWITCH_WIDTH-M_FLAG_SWITCH_WIDTH)/2)   // the toggle of the header over the two columns it rules: show_buy_signal, show_sell_signal
    #define M_CANDLE_TOGGLE_ALERT_X     ((M_CANDLE_COLUMN_SOUND_ALERT+M_CANDLE_COLUMN_MESSAGE_ALERT+M_FLAG_SWITCH_WIDTH-M_FLAG_SWITCH_WIDTH)/2)   // and sound_alert, message_alert
    #define M_CANDLE_PARAM_INDENT       20   // a parameter is a little to the right of the name of its type
    #define M_CANDLE_PARAM_WIDTH        (M_CANDLE_COLUMN_MESSAGE_ALERT+M_FLAG_SWITCH_WIDTH-M_CANDLE_PARAM_INDENT)   // it ends under the last switch
    #define M_CANDLE_COLUMN_PARAM_VALUE (M_CANDLE_PARAM_INDENT+M_CANDLE_PARAM_WIDTH-M_CANDLE_PARAM_EDIT_WIDTH)
    #define M_CANDLE_PARAM_DECIMALS     1    // a parameter in ATR or a multiplier has one decimal
    #define M_CANDLE_PARAM_DECIMAL_STEP 0.1
    #define M_CANDLE_PARAM_EDIT_WIDTH   70   // the box of a parameter edit, the name takes the rest
    #define M_CANDLE_PARAM_MAX          100  // a parameter is a percent of the candle
    #define M_CANDLE_PARAM_POINTS_MAX   10000   // the tolerance of Tweezer is in points
   //m_sections_indicator: a section for each group of the indicators, a row for each template: [delete][name][show_on_chart][buy_signal][sell_signal][sound_alert][message_alert]
    #define INDICATOR_SECTIONS_TOTAL    4
    const ENUM_INDICATOR_GROUP INDICATOR_SECTION_GROUPS[INDICATOR_SECTIONS_TOTAL]={INDICATOR_GROUP_TREND,INDICATOR_GROUP_OSCILLATOR,INDICATOR_GROUP_VOLUMES,INDICATOR_GROUP_ARROWS};   // the group of each section
    enum ENUM_INDICATOR_SLOT   // what a control of a row stands for (the slot of the control, with the id of the template)
     {
      INDICATOR_SLOT_DELETE,
      INDICATOR_SLOT_LABEL,
      INDICATOR_SLOT_SHOW_ON_CHART,
      INDICATOR_SLOT_BUY_SIGNAL,
      INDICATOR_SLOT_SELL_SIGNAL,
      INDICATOR_SLOT_SOUND_ALERT,
      INDICATOR_SLOT_MESSAGE_ALERT
     };
    enum ENUM_INDICATOR_COLUMN   // the columns of the body of m_sections_indicator
     {
      INDICATOR_COLUMN_DELETE,
      INDICATOR_COLUMN_LABEL,
      INDICATOR_COLUMN_SHOW,
      INDICATOR_COLUMN_BUY_SIGNAL,
      INDICATOR_COLUMN_SELL_SIGNAL,
      INDICATOR_COLUMN_SOUND_ALERT,
      INDICATOR_COLUMN_MESSAGE_ALERT,
      INDICATOR_COLUMN_TOTAL
     };
    #define M_INDICATOR_LABEL_WIDTH        195
    #define M_INDICATOR_COLUMN_LABEL       (M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP)
    #define M_INDICATOR_COLUMN_SHOW        (M_INDICATOR_COLUMN_LABEL+M_INDICATOR_LABEL_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_INDICATOR_COLUMN_BUY_SIGNAL  (M_INDICATOR_COLUMN_SHOW+M_FLAG_SWITCH_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_INDICATOR_COLUMN_SELL_SIGNAL (M_INDICATOR_COLUMN_BUY_SIGNAL+M_FLAG_SWITCH_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_INDICATOR_COLUMN_SOUND_ALERT (M_INDICATOR_COLUMN_SELL_SIGNAL+M_FLAG_SWITCH_WIDTH+M_CONTROL_BORDER_GAP)
    #define M_INDICATOR_COLUMN_MESSAGE_ALERT (M_INDICATOR_COLUMN_SOUND_ALERT+M_FLAG_SWITCH_WIDTH+M_CONTROL_BORDER_GAP)
    enum ENUM_INDICATOR_TOGGLE   // the toggles of the header of a section of m_sections_indicator
     {
      INDICATOR_TOGGLE_SHOW,     // show_on_chart of every template of the group
      INDICATOR_TOGGLE_SIGNAL,   // buy_signal and sell_signal
      INDICATOR_TOGGLE_ALERT     // sound_alert and message_alert
     };
    #define M_INDICATOR_TOGGLE_SHOW_X      (M_INDICATOR_COLUMN_SHOW)   // the toggle of a section over the column it rules
    #define M_INDICATOR_TOGGLE_SIGNAL_X    ((M_INDICATOR_COLUMN_BUY_SIGNAL+M_INDICATOR_COLUMN_SELL_SIGNAL)/2)     // the toggle of a section over the two columns it rules
    #define M_INDICATOR_TOGGLE_ALERT_X     ((M_INDICATOR_COLUMN_SOUND_ALERT+M_INDICATOR_COLUMN_MESSAGE_ALERT)/2)
    #define M_BUTTON_ADD_WIDTH          80
   //m_window_addIndicator (Add Indicator): the tree of the types (left) and the form of the parameters (right)
    //#define PARAM_ROW_H               26    // a control and a gap M_CONTROL_HEIGHT
    #define PARAM_ROW_H               M_CONTROL_HEIGHT    // a control and a gap M_CONTROL_HEIGHT
    #define INDICATOR_PARAM_LABEL_W   150
    #define INDICATOR_PARAM_FIELD_W   80
    #define M_TREEVIEW_ADDINDICATOR_WIDTH  200   // the tree of the types in the Add Indicator window
    #define PARAM_FORM_X              (M_CONTROL_BORDER_GAP + M_TREEVIEW_ADDINDICATOR_WIDTH + M_CONTROL_BORDER_GAP)
    #define PARAM_FORM_Y              (M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)   // below the caption of the window
    #define INDICATOR_FRAME_W         (M_WINDOW_MAIN_WIDTH - PARAM_FORM_X - 2 * M_CONTROL_BORDER_GAP)   // the form takes what is left of the window, as wide as the main window
    #define INDICATOR_FRAME_H         (M_CONTROL_HEIGHT + INDICATOR_PARAM_SLOTS_MAX * PARAM_ROW_H + M_CONTROL_HEIGHT + 2 * M_CONTROL_BORDER_GAP)   // the caption, a row for each slot, the Add button
    #define M_WINDOW_ADDINDICATOR_WIDTH    M_WINDOW_MAIN_WIDTH
    #define M_WINDOW_ADDINDICATOR_HEIGHT   (PARAM_FORM_Y + INDICATOR_FRAME_H + M_CONTROL_BORDER_GAP)
   //m_window_candle_infomation (GUIPannel_Window_CandleInfo.mqh): the popup of what was found in a candle
    #define CANDLE_INFO_WINDOW_W        (50+M_ICON16_WIDTH+M_TF_WITHICON_WIDTH+M_INDICATOR_PARATEXT_WIDTH+20)
    #define CANDLE_INFO_WINDOW_H        220
    #define CANDLE_INFO_CURSOR_INSET    15   // how far INSIDE the popup's near edge the cursor sits when it appears, not a gap
    #define CANDLE_INFO_CANDLE_GAP      40   // room between the candle column and the popup: clears a CBarMarker
    #define CANDLE_INFO_SOURCE_TOTAL    (BAR_INFORMATION_SIGNAL+1)   // the source of a row is its group (ENUM_BAR_INFORMATION_GROUP): the signal of an indicator is the last one
    #define COLUMNS_CANDLEINFO_TOTAL    4
    #define COL_CI_TIME     0
    #define COL_CI_SOURCE   1
    #define COL_CI_TF       2
    #define COL_CI_INFO     3
    const int CANDLEINFO_WIDTH[COLUMNS_CANDLEINFO_TOTAL] = {M_TIME_WIDTH, M_ICON16_WIDTH, M_TF_WITHICON_WIDTH, M_INDICATOR_PARATEXT_WIDTH};
    const ENUM_ALIGN_MODE CANDLEINFO_HEADER_ALIGN[COLUMNS_CANDLEINFO_TOTAL] = {ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_LEFT};
    const ENUM_ALIGN_MODE CANDLEINFO_CONTENT_ALIGN[COLUMNS_CANDLEINFO_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    const int CANDLEINFO_TEXT_X_OFFSET[COLUMNS_CANDLEINFO_TOTAL] = {5, 5, 5, 5};
    const int CANDLEINFO_IMAGE_X_OFFSET[COLUMNS_CANDLEINFO_TOTAL] = {0, 2, 3, 3};
   //m_table_SymbolTFSeting: Symbol, TF, Buy, Sell, Sound, Message
    #define COLUMNS_SYMBOLTF_TOTAL 6
    #define M_TREEVIEW_WIDTH            110   // m_treeview_SymbolTF
   //The Trade Manage window (GUIPannel_Window_TradeManager.mqh): a tab for each kind of position
    enum ENUM_TAB_TRADE
     {
      TAB_TRADE_OPEN_POSITION_BY_SYMBOL,
      TAB_TRADE_OPEN_POSITION,
      TAB_TRADE_PENDING_POSITION,
      TAB_TRADE_HISTORY_POSITION,
      TAB_TRADE_TOTAL
     };
    #define M_BUTTON_TRADEMANAGE_WIDTH   100
    #define M_WINDOW_TRADEMANAGE_WIDTH   900
    #define M_WINDOW_TRADEMANAGE_HEIGHT  380
   //The History tab (GUIPannel_Window_TradeManagerTabHistory.mqh): the trades, one row for each position that was closed. Its deals (IN and OUT, with the Bid and the Ask)
   //are in the Order detail window, the Profit and the costs here are the sums of its deals
    #define TRADE_ROWS_MAX               500    // the newest trades shown
    enum ENUM_COLUMN_TRADE
     {
      COL_T_SYMBOL,COL_T_DIRECTION,COL_T_REASON,COL_T_VOLUME,COL_T_TIME_HOLD,COL_T_COMMISSION,COL_T_SWAP,COL_T_POSITION_ID,
      COL_T_TIME_OPEN,COL_T_TIME_CLOSE,COL_T_PRICE_OPEN,COL_T_PRICE_CLOSE,COL_T_FEE,COL_T_PROFIT,COL_T_DETAIL,
      COLUMNS_TRADE_TOTAL
     };
    #define TRADE_REASON_TOTAL           7      // the reasons of a trade: the source of the deal that closed it, an icon with a tooltip (ENUM_DEAL_REASON 0..6)
    const string TRADE_REASON_VALUE[TRADE_REASON_TOTAL]={"CLIENT","MOBILE","WEB","EXPERT","SL","TP","SO"};   // the text of the cell, the order of the icons
    const string TRADE_REASON_TOOLTIP[TRADE_REASON_TOTAL]={"The order was placed from a desktop terminal","The order was placed from a mobile application","The order was placed from a web platform",
                                                           "The order was placed from an MQL5-program, i.e. by an Expert Advisor or a script","The order was placed as a result of Stop Loss activation",
                                                           "The order was placed as a result of Take Profit activation","The order was placed as a result of the Stop Out event"};
    const string TRADE_CAPTION[COLUMNS_TRADE_TOTAL]={"Symbol","Direction","Reason","Vol","Time hold","Commission","Swap","Position ID","Time open","Time close","Price open","Price close","Fee","Profit","Detail"};
    const int    TRADE_WIDTH[COLUMNS_TRADE_TOTAL]={M_SYMBOL_WITHICON_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_LOT_WIDTH,M_DURATION_WIDTH,M_MONEY_WIDTH,M_MONEY_WIDTH,M_TICKET_WIDTH,
                                                  M_DATETIME_WIDTH,M_DATETIME_WIDTH,M_PRICE_WIDTH,M_PRICE_WIDTH,M_MONEY_WIDTH,M_MONEY_WIDTH,M_ICON16_WIDTH};
    const int    TRADE_NUMBER_COLUMNS[]={COL_T_VOLUME,COL_T_TIME_HOLD,COL_T_COMMISSION,COL_T_SWAP,COL_T_FEE,COL_T_PRICE_OPEN,COL_T_PRICE_CLOSE,COL_T_PROFIT};
   //The colours of the Profit and the Net: a gain is green, a loss is red
    #define M_COLOR_PROFIT               C'0,160,0'
    #define M_COLOR_LOSS                 C'200,0,0'
   //The Order detail window (GUIPannel_Window_OrderDetail.mqh): what happened to a position, from its order to its deals
    #define M_WINDOW_ORDERDETAIL_WIDTH   M_WINDOW_TRADEMANAGE_WIDTH
    #define M_WINDOW_ORDERDETAIL_HEIGHT  300
    #define ORDER_DETAIL_ROWS_MAX        200    // the rows shown
    enum ENUM_COLUMN_ORDER_DETAIL   // starts as the trades do: Symbol, Direction; the widths are the ones of the trades
     {
      COL_O_SYMBOL,COL_O_DIRECTION,COL_O_TIME,COL_O_EVENT,COL_O_PRICE_OPEN,COL_O_SL,COL_O_TP,COL_O_VOLUME,COL_O_BID,COL_O_ASK,COL_O_SPREAD,
      COLUMNS_ORDER_DETAIL_TOTAL
     };
    const string ORDER_DETAIL_CAPTION[COLUMNS_ORDER_DETAIL_TOTAL]={"Symbol","Direction","Time","Event","Price open","SL","TP","Vol","Bid","Ask","Spread"};
    const int    ORDER_DETAIL_WIDTH[COLUMNS_ORDER_DETAIL_TOTAL]={M_SYMBOL_WITHICON_WIDTH,M_ICON16_WIDTH,M_DATETIME_SEC_WIDTH,M_EVENT_WIDTH,M_PRICE_WIDTH,M_PRICE_WIDTH,M_PRICE_WIDTH,M_LOT_WIDTH,M_PRICE_WIDTH,M_PRICE_WIDTH,M_SPREAD_WIDTH};
    const int    ORDER_DETAIL_NUMBER_COLUMNS[]={COL_O_PRICE_OPEN,COL_O_SL,COL_O_TP,COL_O_VOLUME,COL_O_BID,COL_O_ASK,COL_O_SPREAD};
    const int    ORDER_DETAIL_SPREAD_COLUMNS[]={COL_O_SPREAD};
  //For menu
    enum ENUM_MENU_ITEM
     {
      MENU_ITEM_HELP,
     };
    #define ENUM_MENU_ITEM_WIDTH         85
  // Status bar items, left to right
   #define STATUS_LABELS_TOTAL 2
   enum ENUM_STATUS_BAR_ITEM
    {
      STATUS_BAR_SYMBOL_SPREAD=0,   // the first item stretches: it takes what the others leave (CStatusBar)
      STATUS_BAR_EQUITY,
    };
   #define M_STATUS_EQUITY_WIDTH       190   // icon + Equity: 99999.99 USD
   const int STATUS_BAR_WIDTH[STATUS_LABELS_TOTAL] = {0, M_STATUS_EQUITY_WIDTH};   // the order of ENUM_STATUS_BAR_ITEM, 0 = stretches
#endif // __GUIPANNEL_DEFINE_MQH__
