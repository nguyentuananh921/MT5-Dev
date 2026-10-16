//+------------------------------------------------------------------+
//|                                             GUIPannel_Define.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNELDEFINE_MQH
#define CGUIPANNELDEFINE_MQH
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\GUIDefines.mqh>   // M_CONTROL_HEIGHT, M_CONTROL_BORDER_GAP, M_TF_WITHICON_WIDTH, M_LOT_WIDTH
 // The models the panel shows and edits, owned by the EA
  #include "..\Configuration\SymbolTFManager.mqh"
  #include "..\Configuration\SwingSetting.mqh"
  #include "..\Configuration\StructureSetting.mqh"
  #include "..\Configuration\IndicatorTemplateManager.mqh"
  #include "..\Configuration\PatternManager.mqh"
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\IndicatorsCollection.mqh>
 // For GUI controls
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Window.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Tabs.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Menu\MenuBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Menu\ContextMenu.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\StatusBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\CheckBox.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\TextEdit.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\ComboBox.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Frame.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\TreeView.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Table\Table.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Button.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\ButtonsGroup.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\SymbolsCollection.mqh>
 // Root of every canvas element + ZOrder owner
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\GraphElementsCollection.mqh>
 // Define GUI control
  //Unified width
    #define M_SYMBOL_WITHICON_WIDTH       110  //Unified width for every control/column that displays a Symbol+Icon
    #define M_TF_WITHOUT_ICON_WIDTH        45  //Unified width for every control/column that displays a Timeframe
    #define M_TABLE_SCROLL_WIDTH           20  //Room for the vertical scroll bar to the right of a table
    #define M_PRICE_WIDTH                  80  //Unified width for every column that displays a price or an Indicator's live Value
    #define M_INDICATOR_PARATEXT_WIDTH    230  //Include LabelText + Icon
  // Control Height: M_CONTROL_HEIGHT is in GUIDefines.mqh
  // Gap
    //M_CONTROL_BORDER_GAP is in GUIDefines.mqh
    #define M_CONTROL_YDISTANCE            22  //Gap Between 2 Control
    #define M_SUBWINDOW_MAIN                0  //The EA runs in the main window of its own chart: one EA instance per chart
  //Treeview
    #define M_TREEVIEW_WIDTH               150 //Wide for m_treeview_SymbolTF and m_treeview_indicator
  // Main panel window m_window_main
    #define M_WINDOW_MAIN_WIDTH         600
    #define M_WINDOW_MAIN_HEIGHT        (480+M_CONTROL_BORDER_GAP+M_CONTROL_BORDER_GAP)   //480 and the two gaps the TF switch row added
    #define M_WINDOW_MIN_WIDTH          300
    #define M_WINDOW_MIN_HEIGHT         200
   //Rows of m_window_main from the top, a M_CONTROL_BORDER_GAP between two of them: caption, menu bar, TF switch row, header of m_tabs_main, body of m_tabs_main.
   //The y of m_tabs_main is the top of its body: its header is the row above it
    #define M_MENU_BAR_Y                WINDOW_CAPTION_HEIGHT
    #define M_TF_SWITCH_Y               (M_MENU_BAR_Y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP)
    #define M_TABS_MAIN_Y               (M_TF_SWITCH_Y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP+M_CONTROL_HEIGHT)
   // Setting panel window
    #define M_WINDOW_SETTING_WIDTH      700
    #define M_WINDOW_SETTING_HEIGHT     480
  // --- Setting Time Series: the content right of the tree (Symbol TF tab)
   #define PARAM_FORM_X              (M_CONTROL_BORDER_GAP + M_TREEVIEW_WIDTH + M_CONTROL_BORDER_GAP)
   #define PARAM_FORM_Y              M_CONTROL_BORDER_GAP
  // --- Candle information popup (GUIPannel_CandleInfo_Windows.mqh)
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
  // --- Indicator tab: parameter form (frame) on top, Save button below it, template table below the button
   struct SIndicatorLayout
    {
     int               row;            // 0-based row in the form
     int               col;            // 0-based column (0 = left, 1 = right)
     int               total_width;    // label + field, equal on every row so the value boxes line up
     int               field_width;    // width of the value control itself
     ENUM_ELEMENT_TYPE element_type;   // E_TEXT_BOX or E_COMBO_BOX
    };
   #define PARAM_ROW_H               30
   #define INDICATOR_PARAM_ROWS      4
   #define INDICATOR_PARAM_LABEL_W   125
   #define INDICATOR_PARAM_FIELD_W   80
   #define INDICATOR_PARAM_COL_WIDTH (INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W + 12)
   #define INDICATOR_FRAME_W         (2 * INDICATOR_PARAM_COL_WIDTH - 12 + 2 * M_CONTROL_BORDER_GAP)
   #define INDICATOR_FRAME_H         (M_CONTROL_HEIGHT + INDICATOR_PARAM_ROWS * PARAM_ROW_H + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
   #define INDICATOR_TABLE_Y         (PARAM_FORM_Y + INDICATOR_FRAME_H + M_CONTROL_BORDER_GAP + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
  // --- Symbol/TF setting table: save button below the top gap, table below the button
   #define SYMBOLTF_BTN_Y            (M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
   #define SYMBOLTF_TABLE_Y          (SYMBOLTF_BTN_Y + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
  // --- Trading tab (GUIPannel_MainWindows_TabTrading.mqh)
   #define TRADING_FORM_ROWS_TOTAL   9
   #define TRADING_FORM_HEIGHT       (TRADING_FORM_ROWS_TOTAL * M_CONTROL_YDISTANCE + M_CONTROL_HEIGHT)
  // --- Setting Trading: height of the StopLost / Trailing symbol tables, the form sits below it
   #define SETTING_TRADING_TABLE_HEIGHT (175 - M_CONTROL_BORDER_GAP - 5)
  // --- StopLost tab: Indicator frame + gap + Fixed frame = width of the Symbol table above
   #define SL_FORM_CAPTION_WIDTH    120
   #define SL_FORM_FIELD_WIDTH      120
   #define SL_FORM_FRAME_WIDTH      (M_CONTROL_BORDER_GAP + SL_FORM_CAPTION_WIDTH + SL_FORM_FIELD_WIDTH + M_CONTROL_BORDER_GAP)
   #define SL_TOTAL_WIDTH           (SL_FORM_FRAME_WIDTH + M_CONTROL_BORDER_GAP + SL_FORM_FRAME_WIDTH)
  // --- Trailling tab: Indicator table + gap + Fixed Mode frame = width of the Symbol table above
   #define TRAIL_IND_TABLE_WIDTH    (2 + 16 + M_TF_WITHICON_WIDTH + M_INDICATOR_PARATEXT_WIDTH - 17 + M_PRICE_WIDTH + M_ICON16_WIDTH)
   #define TRAIL_FORM_CAPTION_WIDTH 90
   #define TRAIL_FORM_EDIT_WIDTH    70
   #define TRAIL_FORM_FRAME_WIDTH   (M_CONTROL_BORDER_GAP + TRAIL_FORM_CAPTION_WIDTH + TRAIL_FORM_EDIT_WIDTH + M_CONTROL_BORDER_GAP)
   #define TRAIL_TOTAL_WIDTH        (TRAIL_IND_TABLE_WIDTH + M_CONTROL_BORDER_GAP + TRAIL_FORM_FRAME_WIDTH)
   //Trading Setting Windows
    #define M_WINDOW_TRADING_SETTING_WIDTH      (TRAIL_TOTAL_WIDTH+2*M_CONTROL_BORDER_GAP)
    #define M_WINDOW_TRADING_SETTING_HEIGHT     480
    // For m_table_stoplostsetting
     #define COLUMNS_STOPLOST_TOTAL 8
     const int STOPLOST_WIDTH[COLUMNS_STOPLOST_TOTAL] = { M_SYMBOL_WITHICON_WIDTH, M_PRICE_WIDTH, 35, M_ICON16_WIDTH, 60, 60, 70, 70 };
     const ENUM_ALIGN_MODE STOPLOST_HEADER_ALIGN[COLUMNS_STOPLOST_TOTAL] = { ALIGN_LEFT, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER };
     const ENUM_ALIGN_MODE STOPLOST_CONTENT_ALIGN[COLUMNS_STOPLOST_TOTAL] = { ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT };
     const int STOPLOST_TEXT_X_OFFSET[COLUMNS_STOPLOST_TOTAL] = { 5, 2, 2, 5, 2, 2, 2, 2 };
     const int STOPLOST_IMAGE_X_OFFSET[COLUMNS_STOPLOST_TOTAL] = { 3, 3, (35 - 16) / 2, 2, (60 - 16) / 2, (60 - 16) / 2, (70 - 16) / 2, (70 - 16) / 2 };
    // For m_table_trailingsetting
     #define COLUMNS_TRAIL_TOTAL 8
     const int TRAIL_WIDTH[COLUMNS_TRAIL_TOTAL] = { M_SYMBOL_WITHICON_WIDTH, M_PRICE_WIDTH, 35, M_ICON16_WIDTH, 60, 60, 70, 70 };
     const ENUM_ALIGN_MODE TRAIL_HEADER_ALIGN[COLUMNS_TRAIL_TOTAL] = { ALIGN_LEFT, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER };
     const ENUM_ALIGN_MODE TRAIL_CONTENT_ALIGN[COLUMNS_TRAIL_TOTAL] = { ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT };
     const int TRAIL_TEXT_X_OFFSET[COLUMNS_TRAIL_TOTAL] = { 5, 2, 2, 5, 2, 2, 2, 2 };
     const int TRAIL_IMAGE_X_OFFSET[COLUMNS_TRAIL_TOTAL] = { 3, 3, (35 - 16) / 2, 2, (60 - 16) / 2, (60 - 16) / 2, (70 - 16) / 2, (70 - 16) / 2 };
    // For m_table_indicators_trailingsetting
     #define COLUMNS_IND_TRAIL_TOTAL 4
     const int IND_TRAIL_WIDTH[COLUMNS_IND_TRAIL_TOTAL] = { M_TF_WITHICON_WIDTH, M_INDICATOR_PARATEXT_WIDTH - 17, M_PRICE_WIDTH, M_ICON16_WIDTH };
     const ENUM_ALIGN_MODE IND_TRAIL_HEADER_ALIGN[COLUMNS_IND_TRAIL_TOTAL] = { ALIGN_LEFT, ALIGN_LEFT, ALIGN_CENTER, ALIGN_CENTER };
     const ENUM_ALIGN_MODE IND_TRAIL_CONTENT_ALIGN[COLUMNS_IND_TRAIL_TOTAL] = { ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_CENTER };
     const int IND_TRAIL_TEXT_X_OFFSET[COLUMNS_IND_TRAIL_TOTAL] = { 5, 5, 5, 5 };
     const int IND_TRAIL_IMAGE_X_OFFSET[COLUMNS_IND_TRAIL_TOTAL] = { 3, 0, 0, 2 }; 
   //--- m_table_indicator_PreTradeSymbolMonitor
   #define COLUMNS_PRETRADEMON_TOTAL 6
   const int PRETRADEMON_WIDTH[COLUMNS_PRETRADEMON_TOTAL] = {M_TF_WITHICON_WIDTH, M_ICON16_WIDTH, M_INDICATOR_PARATEXT_WIDTH, M_PRICE_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH};
   const ENUM_ALIGN_MODE PRETRADEMON_HEADER_ALIGN[COLUMNS_PRETRADEMON_TOTAL] = {ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_CENTER, ALIGN_CENTER};
   const ENUM_ALIGN_MODE PRETRADEMON_CONTENT_ALIGN[COLUMNS_PRETRADEMON_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT};
   const int PRETRADEMON_TEXT_X_OFFSET[COLUMNS_PRETRADEMON_TOTAL] = {5, 5, 5, 5, 5, 5};
   const int PRETRADEMON_IMAGE_X_OFFSET[COLUMNS_PRETRADEMON_TOTAL] = {3, 3, 3, 0, 2, 2};
   //--- m_table_market_story (GUIPannel_MainWindows_TabMarketStory.mqh)
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
   //--- m_table_position_pretrade_view
   #define COLUMNS_PRETRADE_VIEW_TOTAL 8
   #define COL_PTV_SYMBOL      0
   #define COL_PTV_DIR         1
   #define COL_PTV_LOT         2   // CELL_COMBOBOX
   #define COL_PTV_SLTYPE      3
   #define COL_PTV_SLPRICE     4
   #define COL_PTV_SLPROFIT    5   // reference loss @ LotsMin() - see COL_PTV_RISK for the real Lot
   #define COL_PTV_TRAILTYPE   6
   #define COL_PTV_RISK        7   // real $ loss for the actual selected Lot
   #define PRETRADE_VIEW_TABLE_HEIGHT 40 // header(20) + 1 data row(20), CTable's own default m_cell_y_size
   const int PRETRADE_VIEW_WIDTH[COLUMNS_PRETRADE_VIEW_TOTAL] = {M_SYMBOL_WITHICON_WIDTH, M_ICON16_WIDTH, M_LOT_WIDTH, M_ICON16_WIDTH, M_PRICE_WIDTH, 50, M_ICON16_WIDTH, 70};
   const ENUM_ALIGN_MODE PRETRADE_VIEW_HEADER_ALIGN[COLUMNS_PRETRADE_VIEW_TOTAL] = {ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER};
   const ENUM_ALIGN_MODE PRETRADE_VIEW_CONTENT_ALIGN[COLUMNS_PRETRADE_VIEW_TOTAL] = {ALIGN_LEFT, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_CENTER, ALIGN_RIGHT};
   const int PRETRADE_VIEW_TEXT_X_OFFSET[COLUMNS_PRETRADE_VIEW_TOTAL] = {5, 5, 5, 5, 5, 5, 5, 5};
   const int PRETRADE_VIEW_IMAGE_X_OFFSET[COLUMNS_PRETRADE_VIEW_TOTAL] = {3, 2, 3, 2, 3, 17, 2, 3};
   //--- m_table_positions_StoplostAndTrailling
   #define COLUMNS_POS_SL_TRAIL_TOTAL 11
   #define COL_PST_SYMBOL      0
   #define COL_PST_DIR         1
   #define COL_PST_VOLUME      2
   #define COL_PST_NO          3
   #define COL_PST_SLTYPE      4
   #define COL_PST_SLPRICE     5
   #define COL_PST_SLPROFIT    6
   #define COL_PST_RUN_SL      7
   #define COL_PST_TRAILTYPE   8
   #define COL_PST_RUN_TRAIL   9
   #define COL_PST_PROFIT      10
   const int POSITIONS_SLTRAIL_WIDTH[COLUMNS_POS_SL_TRAIL_TOTAL] = {M_SYMBOL_WITHICON_WIDTH, M_ICON16_WIDTH, M_LOT_WIDTH, 30, M_ICON16_WIDTH, M_PRICE_WIDTH, 50, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH, 45};
   const ENUM_ALIGN_MODE POSITIONS_SLTRAIL_HEADER_ALIGN[COLUMNS_POS_SL_TRAIL_TOTAL] = {ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER};
   const ENUM_ALIGN_MODE POSITIONS_SLTRAIL_CONTENT_ALIGN[COLUMNS_POS_SL_TRAIL_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT};
   const int POSITIONS_SLTRAIL_TEXT_X_OFFSET[COLUMNS_POS_SL_TRAIL_TOTAL] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5};
   const int POSITIONS_SLTRAIL_IMAGE_X_OFFSET[COLUMNS_POS_SL_TRAIL_TOTAL] = {3, 2, 3, 3, 2, 3, 17, 2, 2, 2, 14};
  //For menu
    enum ENUM_MENU_ITEM
     {
        MENU_ITEM_SETTINGS,
        MENU_ITEM_TRADING,
        MENU_ITEM_HELP,
        MENU_ITEM_TOTAL,
     };
    enum ENUM_MENU_ITEM_TRADING
     {
        MENU_ITEM_TRADING_STOPLOST,
        MENU_ITEM_TRADING_TRAILLING,
        MENU_ITEM_TRADING_TOTAL,
     };
    enum ENUM_MENU_ITEM_SETTINGS
     {
        MENU_ITEM_SETTINGS_INDICATOR,
        MENU_ITEM_SETTINGS_TRADING,
        MENU_ITEM_SETTINGS_TOTAL,
     };
  // Status bar items, left to right
   #define STATUS_LABELS_TOTAL 3
   enum ENUM_STATUS_BAR_ITEM
    {
      STATUS_BAR_DEPOSIT_LOAD = 0,   // stretches: it takes what the other two leave
      STATUS_BAR_PROFIT,
      STATUS_BAR_SERVER_TIME,
    };
   #define M_STATUS_PROFIT_WIDTH       130   // the width of the text each of the other two holds
   #define M_STATUS_TIME_WIDTH         155
   const int STATUS_BAR_WIDTH[STATUS_LABELS_TOTAL] = {0, M_STATUS_PROFIT_WIDTH, M_STATUS_TIME_WIDTH};   // 0 = stretches
  //For Tab m_tabs_main
   enum ENUM_TAB_MAIN
    {
     TAB_TAB_MAIN_ACCOUNT_INFO = 0,
     TAB_TAB_MAIN_SYMBOL_INFO,
     TAB_TAB_MAIN_TRADING,
     TAB_TAB_MAIN_MARKET_STORY,
     TAB_TAB_MAIN_HISTORY,
     TAB_TAB_MAIN_TOTAL,
    };
   enum ENUM_TAB_SETTING_TRADING
    {
     ENUM_TAB_SETTING_TRADING_STOPLOST = 0,
     ENUM_TAB_SETTING_TRADING_TRAILLING,
     ENUM_TAB_SETTING_TRADING_TOTAL,
    };
   enum ENUM_TAB_SETTING_TIMESERIES
    {
     TAB_TAB_SETTING_TIMESERIES_INDICATOR = 0,
     TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF,
     TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN,
     TAB_TAB_SETTING_TIMESERIES_TOTAL,
    };
#endif // CGUIPANNELDEFINE_MQH
