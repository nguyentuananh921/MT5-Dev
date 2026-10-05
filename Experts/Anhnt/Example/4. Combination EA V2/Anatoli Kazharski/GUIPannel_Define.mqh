
//+------------------------------------------------------------------+
//|                                             GUIPannel_Define.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNELDEFINE_MQH
#define CGUIPANNELDEFINE_MQH
// For Pure Data Layer 1
   #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SymbolsCollection.mqh>
  //For timeseries data
   #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\BarTimeSeriesCollection.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarPatternsControl\BarPatternsControl.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\IndicatorsCollection.mqh>
   #include "..\Services\IndicatorTemplateManager.mqh"
   #include "..\Services\SymbolTFManager.mqh"
   #include "..\Services\SwingSettingJSON.mqh"
   #include "..\Services\SignalLogger.mqh"
   #include "..\Services\TradingSetupSetting.mqh"
   #include "..\Services\TradingSetupSettingManager.mqh"
   #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SignalsCollection.mqh>
   #include "..\Artyom Trishkin\TradingEngine.mqh"
 // For GUI controls Layer 2
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Tabs.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Menu\MenuBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Menu\ContextMenu.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\StatusBar.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Frame.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Tooltip.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\CheckBox.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\ButtonsGroup.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\ComboBox.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\TextEdit.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\TreeView.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Table\Table.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\Keys.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\TimeCounter.mqh>
 // Layer-3 observer: charts/windows/indicators state + CHART_OBJ_EVENT_* events (no WForms deps)
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\ChartObjCollection.mqh>
 // Root of every canvas element + ZOrder owner
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\GraphElementsCollection.mqh>
 // For CMessage::PlaySound/Out - per-indicator Sound/Message alerts
  #include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\Message\Message.mqh>
 // For CTradingSetupSetting
 //Define Risk Percentage per Position
    #define RISK_PERCENTAGE_PERPOSITION 5         // 5%
  // --- CGUIPannel's own event(s): chained off the LAST link of the EA event chain
  enum ENUM_GUIPANNEL_EVENT
    {
      GUIPANNEL_EVENT_MARKER_SETTING_CHANGED = SWING_SETTING_EVENT_CHANGED + 1, // Marker style (shape/color) was saved - EA reacts
                                               // by re-attaching SignalMarkers.mq5 with the new inputs
    };
 // Define GUI control 
  //Unified width
    #define M_SYMBOL_WITHICON_WIDTH       110  //Unified width for every control/column that displays a Symbol+Icon
    #define M_TF_WITHICON_WIDTH            65  //Unified width for every control/column that displays a Timeframe+Icon
    #define M_TF_WITHOUT_ICON_WIDTH        45  //Unified width for every control/column that displays a Timeframe
    #define M_ICON16_WIDTH                 20  //Width for icon 16x16
    #define M_PRICE_WIDTH                  80  //Unified width for every column that displays a price or an Indicator's live Value
    #define M_LOT_WIDTH                    65  //Unified width for every column that displays a Lot/Volume (incl. an embedded combobox)
    #define M_INDICATOR_PARATEXT_WIDTH    230  //Include LabelText + Icon
  // Control Height
    #define M_CONTROL_HEIGHT               22  //Height for MenuBar,Tab, Combobox,Label
  // Gap
    #define M_CONTROL_BORDER_GAP            3  //Gap between border of two control
    #define M_CONTROL_YDISTANCE            22  //Gap Between 2 Control
  //Treeview
    #define M_TREEVIEW_WIDTH               150 //Wide for m_treeview_indicator and m_treeview_SymbolTF
  // Main panel window m_window_main
    #define M_WINDOW_MAIN_WIDTH         600
    #define M_WINDOW_MAIN_HEIGHT        480
    #define M_WINDOW_MIN_WIDTH          300
    #define M_WINDOW_MIN_HEIGHT         200
   //Right Pannel m_tabs_main starts at (TABS_MAIN_X, TABS_MAIN_Y) inside m_Mainwindow.
    #define M_TABS_MAIN_Y               WINDOW_CAPTION_HEIGHT+M_CONTROL_HEIGHT+M_CONTROL_HEIGHT
    #define M_TABS_MAIN_WIDTH           (M_WINDOW_MAIN_WIDTH - M_TABS_MAIN_X - M_CONTROL_BORDER_GAP)
   // Setting panel window
    #define M_WINDOW_SETTING_WIDTH      700
    #define M_WINDOW_SETTING_HEIGHT     480
   //Trading Setting Windows
    #define M_WINDOW_TRADING_SETTING_WIDTH      TRAIL_TOTAL_WIDTH+2 * M_CONTROL_BORDER_GAP
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
   // Size for Candle Windows
    #define CANDLE_INFO_WINDOW_W        (50+M_ICON16_WIDTH+M_TF_WITHICON_WIDTH+M_INDICATOR_PARATEXT_WIDTH+20)
    #define CANDLE_INFO_WINDOW_H        220
   // For m_table_candle_information_atBar (GUIPannel_CandleInfo_Windows.mqh)
    #define COLUMNS_CANDLEINFO_TOTAL 4
    #define COL_CI_TIME     0
    #define COL_CI_SOURCE   1
    #define COL_CI_TF       2
    #define COL_CI_INFO     3
    const int CANDLEINFO_WIDTH[COLUMNS_CANDLEINFO_TOTAL] = {50, M_ICON16_WIDTH, M_TF_WITHICON_WIDTH, M_INDICATOR_PARATEXT_WIDTH};
    const ENUM_ALIGN_MODE CANDLEINFO_HEADER_ALIGN[COLUMNS_CANDLEINFO_TOTAL] = {ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_LEFT};
    const ENUM_ALIGN_MODE CANDLEINFO_CONTENT_ALIGN[COLUMNS_CANDLEINFO_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    const int CANDLEINFO_TEXT_X_OFFSET[COLUMNS_CANDLEINFO_TOTAL] ={5, 5, 5, 5 };
    const int CANDLEINFO_IMAGE_X_OFFSET[COLUMNS_CANDLEINFO_TOTAL] ={0, 2, 3, 3};
   // For m_table_positions_StoplostAndTrailling 
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
   // For m_table_position_pretrade_view (GUIPannel_MainWindows_TabTrading.mqh) (dry-run)
    #define COLUMNS_PRETRADE_VIEW_TOTAL 8
    #define COL_PTV_SYMBOL      0
    #define COL_PTV_DIR         1
    #define COL_PTV_LOT         2   // CELL_COMBOBOX, replaces m_combobox_lot_toTrade
    #define COL_PTV_SLTYPE      3
    #define COL_PTV_SLPRICE     4
    #define COL_PTV_SLPROFIT    5   // reference loss @ LotsMin() - see COL_PTV_RISK for the real Lot
    #define COL_PTV_TRAILTYPE   6
    #define COL_PTV_RISK        7   // real $ loss for the actual selected Lot
    #define PRETRADE_VIEW_TABLE_HEIGHT 40 // header(20) + 1 data row(20), CTable's own default m_cell_y_size
    const int PRETRADE_VIEW_WIDTH[COLUMNS_PRETRADE_VIEW_TOTAL] =
     {
      M_SYMBOL_WITHICON_WIDTH,
      M_ICON16_WIDTH,
      M_LOT_WIDTH,
      M_ICON16_WIDTH,
      M_PRICE_WIDTH,
      50,
      M_ICON16_WIDTH,
      70
     };
    const ENUM_ALIGN_MODE PRETRADE_VIEW_HEADER_ALIGN[COLUMNS_PRETRADE_VIEW_TOTAL] =
     {
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_CENTER
     };
    const ENUM_ALIGN_MODE PRETRADE_VIEW_CONTENT_ALIGN[COLUMNS_PRETRADE_VIEW_TOTAL] =
     {
      ALIGN_LEFT,         //Combobox Symbol
      ALIGN_CENTER,         
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_RIGHT,
      ALIGN_RIGHT,
      ALIGN_CENTER,
      ALIGN_RIGHT
     };
    const int PRETRADE_VIEW_TEXT_X_OFFSET[COLUMNS_PRETRADE_VIEW_TOTAL] =
     {
      5, 5, 5, 5, 5, 5, 5, 5
     };
    const int PRETRADE_VIEW_IMAGE_X_OFFSET[COLUMNS_PRETRADE_VIEW_TOTAL] =
     {
      3, 2, 3, 2, 3, 17, 2, 3
     };

   // For m_table_indicator_PreTradeSymbolMonitor
    #define COLUMNS_PRETRADEMON_TOTAL 6
    const int PRETRADEMON_WIDTH[COLUMNS_PRETRADEMON_TOTAL] =
     {
      M_TF_WITHICON_WIDTH,
      M_ICON16_WIDTH,
      M_INDICATOR_PARATEXT_WIDTH,
      M_PRICE_WIDTH,
      M_ICON16_WIDTH,
      M_ICON16_WIDTH
     };
    const ENUM_ALIGN_MODE PRETRADEMON_HEADER_ALIGN[COLUMNS_PRETRADEMON_TOTAL] =
     {
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_CENTER,
      ALIGN_RIGHT,
      ALIGN_CENTER,
      ALIGN_CENTER
     }; 
    const ENUM_ALIGN_MODE PRETRADEMON_CONTENT_ALIGN[COLUMNS_PRETRADEMON_TOTAL] =
     {
      ALIGN_LEFT,
      ALIGN_LEFT,
      ALIGN_LEFT,
      ALIGN_RIGHT,
      ALIGN_LEFT,
      ALIGN_LEFT
     };
    const int PRETRADEMON_TEXT_X_OFFSET[COLUMNS_PRETRADEMON_TOTAL] =
     {
      5, 5, 5, 5, 5, 5
     };
    const int PRETRADEMON_IMAGE_X_OFFSET[COLUMNS_PRETRADEMON_TOTAL] =
     {
      3, 3, 3, 0, 2, 2
     }; 
  //For menu
    enum ENUM_MENU_ITEM
     {
        MENU_ITEM_SETTINGS,
        MENU_ITEM_TRADING,
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
        MENU_ITEM_SETTINGS_ALERT,
        MENU_ITEM_SETTINGS_TOTAL,
     };
  // Status bar items
   #define STATUS_LABELS_TOTAL 4
   enum ENUM_STATUS_BAR_ITEM
    {
      STATUS_BAR_HELP = 0,
      STATUS_BAR_DEPOSIT_LOAD,
      STATUS_BAR_PROFIT,
      STATUS_BAR_SERVER_TIME,
    };
  //For Tab m_tabs_main
   enum ENUM_TAB_MAIN
    {
     TAB_TAB_MAIN_ACCOUNT_INFO = 0,
     TAB_TAB_MAIN_SYMBOL_INFO,
     TAB_TAB_MAIN_TRADING,
     TAB_TAB_MAIN_HISTORY,
     TAB_TAB_MAIN_TOTAL,
    };
   enum ENUM_TAB_SETTING_TIMESERIES
    {
     TAB_TAB_SETTING_TIMESERIES_INDICATOR = 0,
     TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF,
     TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN,
     TAB_TAB_SETTING_TIMESERIES_SWING,
     TAB_TAB_SETTING_TIMESERIES_TOTAL,
    };
   enum ENUM_TAB_SETTING_TRADING
    {
     ENUM_TAB_SETTING_TRADING_STOPLOST = 0,
     ENUM_TAB_SETTING_TRADING_TRAILLING,
     ENUM_TAB_SETTING_TRADING_TOTAL,
    };
   enum ENUM_TAB_SETTING_MARKERANDSOUND
    {
     ENUM_TAB_SETTING_MARKERANDSOUND_MARKER = 0,
     ENUM_TAB_SETTING_MARKERANDSOUND_SOUND,
     ENUM_TAB_SETTING_MARKERANDSOUND_TOTAL,
    };
  //For marker
   enum ENUM_MARKER_SHAPE_PREVIEW_ROW
    {
      SHAPE_PREVIEW_SINGLE_INDICATOR_BUY  = 0,
      SHAPE_PREVIEW_SINGLE_INDICATOR_SELL = 1,
      SHAPE_PREVIEW_MULTI_INDICATOR_BUY   = 2,   //Multi Indicator only
      SHAPE_PREVIEW_MULTI_INDICATOR_SELL  = 3,
      SHAPE_PREVIEW_PATTERN_BUY = 4,
      SHAPE_PREVIEW_PATTERN_SELL= 5,
      SHAPE_PREVIEW_COMBO_BUY   = 6,   //Combination Indicator and CandlePattern
      SHAPE_PREVIEW_COMBO_SELL  = 7,
      SHAPE_PREVIEW_SWING_HIGH  = 8,
      SHAPE_PREVIEW_SWING_LOW   = 9,
    };
  // =====================================================================
  // --- Layer 2 (GUI) layout descriptor - decided BEFORE CreateAddIndicatorParaInfor/
  // --- ShowIndicatorParameterForm ever runs, separate from Layer 1's
  // --- SIndicatorParam (which only knows name/type/default/choices, not
  // --- where on screen it goes or which control renders it).
  // =====================================================================
   struct SIndicatorLayout
    {
      int               row;            // 0-based row in the form
      int               col;            // 0-based column (0=left, 1=right)
      int               total_width;    // label + field combined - keep this EQUAL
                                        // across a type's rows to make every row's
                                        // value box line up at the same right edge,
                                        // regardless of each row's label text length.
      int               field_width;    // px width of the value control itself (edit/combo)
      ENUM_ELEMENT_TYPE element_type;   // E_TEXT_BOX or E_COMBO_BOX (GUIDefines.mqh)
    };
  // --- Param form (right of indicator tree in Settings tab)
   #define INDICATOR_PARAM_ROWS      4
   #define INDICATOR_PARAM_LABEL_W   125
   #define INDICATOR_PARAM_FIELD_W   80
   #define INDICATOR_PARAM_COL_WIDTH (INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W + 12)
   #define PARAM_FORM_X              (M_CONTROL_BORDER_GAP + M_TREEVIEW_WIDTH + M_CONTROL_BORDER_GAP)
   #define INDICATOR_FRAME_W         (2 * INDICATOR_PARAM_COL_WIDTH - 12 + 2 * M_CONTROL_BORDER_GAP)
   #define INDICATOR_FRAME_H         (M_CONTROL_HEIGHT + INDICATOR_PARAM_ROWS * PARAM_ROW_H + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
   #define PARAM_FORM_Y              M_CONTROL_BORDER_GAP
   #define PARAM_ROW_H               30
  // --- Indicator table: below the Save button; width auto-fills m_tabs_main via AutoXResizeMode.
   #define INDICATOR_TABLE_X         PARAM_FORM_X
   #define INDICATOR_TABLE_Y         (PARAM_FORM_Y + INDICATOR_FRAME_H + M_CONTROL_BORDER_GAP + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
  // --- Symbol/TF setting table (Symbol TF sub-tab): note row on top, save button below it,
  // --- table below the button - same M_CONTROL_BORDER_GAP convention as INDICATOR_TABLE_Y.
   #define SYMBOLTF_BTN_Y            (M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
   #define SYMBOLTF_TABLE_Y          (SYMBOLTF_BTN_Y + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP)
   #define POSITIONS_TABLE_Y            175
  // --- Setting Trading: height of the StopLost / Trailing symbol tables, the form sits below it
   #define SETTING_TRADING_TABLE_HEIGHT (POSITIONS_TABLE_Y - M_CONTROL_BORDER_GAP - 5)
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
  // SIGNAL_BRIDGE_MAGIC lives only in Services\SignalBridgeWriter.mqh (the only writer)
  // How far INSIDE the popup's near edge the cursor sits when it appears - NOT a gap.
   #define CANDLE_INFO_CURSOR_INSET  15
   #define PATTERN_HOVER_LABEL_NAME  "GUIPannel_PatternHoverLabel"  
   #define TRADING_FORM_ROWS_TOTAL   9
   #define TRADING_FORM_HEIGHT       (TRADING_FORM_ROWS_TOTAL * M_CONTROL_YDISTANCE + M_CONTROL_HEIGHT)  
#endif // CGUIPANNELDEFINE_MQH

