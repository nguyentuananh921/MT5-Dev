
//+------------------------------------------------------------------+
//|                                             GUIPannel_Define.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNELDEFINE_MQH
#define CGUIPANNELDEFINE_MQH
// For Pure Data Layer 1
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SymbolsCollection.mqh>
  //For timeseries data  
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\TickSeriesCollection.mqh>
   //#include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Timeseries\PatternRenderer.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>  
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\NewBarObj.mqh>   
   #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Trading\TradingLevelBubble.mqh>
   #include "..\Services\IndicatorTemplateManager.mqh"
   #include "..\Services\SymbolTFManager.mqh"
   #include "..\Services\SignalLogger.mqh"
   #include "..\Services\TradingSetupSetting.mqh"   // ENUM_STOPLOST_TRAILING_MODE + CTradingSetupSetting (Anhnt, 2026-09-04)
   #include "..\Services\TradingSetupSettingManager.mqh"

  // GUIPannel only holds CSignalsCollection (a property CTimeSeriesEngine owns), never the
  // engine itself - no other CTimeSeriesEngine method is called from the GUI layer.
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SignalsCollection.mqh>
   #include "..\Artyom Trishkin\TradingEngine.mqh"
 // For GUI controls Layer 2
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Keys.mqh>
  //#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\SplitContainer.mqh>
 // Layer-3 observer: charts/windows/indicators state + CHART_OBJ_EVENT_* events (no WForms deps)
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
 // For CMessage::PlaySound/Out - per-indicator Sound/Message alerts (2026-07-17)
  #include <Vendors\Anhnt\Library\4. Combination Lib\Notify\Message\Message.mqh>
 // For CTradingSetupSetting
 //Define Risk Percentage per Position
    #define RISK_PERCENTAGE_PERPOSITION 5         // 5%
  enum ENUM_CHECKBOX_STATE
    {
      CHECKBOX_STATE_ON  = 0,
      CHECKBOX_STATE_OFF = 1,
    };
  // --- CGUIPannel's own event(s). Continues numbering from SymbolTFManager's own chain - MUST
  // --- chain off its LAST value (SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED), not SETTING_CHANGED -
  // --- chaining off a non-last value collides with whatever was appended after it.
  // --- GUIPANNEL_EVENT_PATTERN_BUYSELL_CHANGED removed (Anhnt, 2026-08-30) - CBarPatternControl
  // --- now owns Buy/Sell directly (moved off CGUIPannel's old parallel arrays) and fires its own
  // --- BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED (BarPatternControl.mqh) instead; CGUIPannel no
  // --- longer fires anything on this domain's behalf.
  enum ENUM_GUIPANNEL_EVENT
    {
      GUIPANNEL_EVENT_MARKER_SETTING_CHANGED = SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED + 1, // Marker style (shape/color) was saved - EA reacts
                                               // by re-attaching SignalMarkers.mq5 with the new inputs
    };
 // Define GUI control
  // Main panel window m_window_main
    #define M_WINDOW_MAIN_WIDTH         550
    #define M_WINDOW_MAIN_HEIGHT        480
    #define M_WINDOW_MIN_WIDTH          300
    #define M_WINDOW_MIN_HEIGHT         200
   // Setting panel window
    #define M_WINDOW_SETTING_WIDTH      700
    #define M_WINDOW_SETTING_HEIGHT     480
   // Size for Candle Windows
    #define CANDLE_INFO_WINDOW_W        300
    #define CANDLE_INFO_WINDOW_H        220 
   //Left pannel m_treeview_SymbolTF (fixed left strip, visible on all tabs)   
    #define M_CONTROL_BORDER_GAP        3  //Gap between border of two control
    #define M_CONTROL_YDISTANCE         22 //Gap Between 2 Control    
   // Control Height
    #define M_CONTROL_HEIGHT            22 //Height for MenuBar,Tab, Combobox,Label
   //Unified width
    #define M_SYMBOL_WIDTH              85 //Unified width for every control/column that displays a Symbol+Icon
    #define M_TF_WIDTH                  55 //Unified width for every control/column that displays a Timeframe+Icon
    #define INDICATOR_PARATEXT_WIDTH    180 //Include LabelText + Icon
    #define INDICATOR_VALUE_WIDTH       80  //Unified width for every column that displays an Indicator's live Value       
   //Right Pannel m_tabs_main starts at (TABS_MAIN_X, TABS_MAIN_Y) inside m_Mainwindow.    
    #define M_TABS_MAIN_Y               WINDOW_CAPTION_HEIGHT+M_CONTROL_HEIGHT+M_CONTROL_HEIGHT
    #define M_TABS_MAIN_WIDTH           (M_WINDOW_MAIN_WIDTH - M_TABS_MAIN_X - M_CONTROL_BORDER_GAP)  
   // For m_table_positions_StoplostAndTrailling (GUIPannel_NewFeatures.mqh) - column indices, defined
   // here (included before every other module) so GUIPannel_MainWindows.mqh's OnEvent dispatch can
   // reference them too, not just GUIPannel_NewFeatures.mqh itself (Anhnt/Claude, 2026-09-07).
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
   // For m_table_position_pretrade_view (GUIPannel_MainWindows_TabTrading.mqh) (dry-run)
    #define COLUMNS_PRETRADE_VIEW_TOTAL 8
    #define COL_PTV_SYMBOL      0
    #define COL_PTV_DIR         1
    #define COL_PTV_LOT         2   // Anhnt, 2026-09-10 - embedded CELL_COMBOBOX, replaces m_combobox_lot_toTrade
    #define COL_PTV_SLTYPE      3
    #define COL_PTV_SLPRICE     4
    #define COL_PTV_SLPROFIT    5   // reference loss @ LotsMin() - see COL_PTV_RISK for the real Lot
    #define COL_PTV_TRAILTYPE   6
    #define COL_PTV_RISK        7   // Anhnt, 2026-09-11 - real $ loss for the ACTUAL selected Lot
    #define PRETRADE_VIEW_TABLE_HEIGHT 40 // header(20) + 1 data row(20), CTable's own default m_cell_y_size
  enum ENUM_MENU_ITEM
   {        
        MENU_ITEM_SETTINGS,
        MENU_ITEM_TOTAL,
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
   enum ENUM_TAB_MAIN
    {
     TAB_TAB_MAIN_ACCOUNT_INFO = 0,
     TAB_TAB_MAIN_SYMBOL_INFO,
     TAB_TAB_MAIN_MONITOR,      
     TAB_TAB_MAIN_TRADING,
     TAB_TAB_MAIN_HISTORY,
     TAB_TAB_MAIN_TOTAL,
    };
  enum ENUM_TAB_SETTING_TIMESERIES
   {
    TAB_TAB_SETTING_TIMESERIES_INDICATOR = 0,
    TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF,
    TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN,
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
   };  
   enum ENUM_INDICATOR_SHOW_STATE
   {
     INDICATOR_SHOW_ON_CHART = CHECKBOX_STATE_ON,
     INDICATOR_HIDE_ON_CHART = CHECKBOX_STATE_OFF,
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
  // --- Indicator tree (Settings tab, left column)
   #define INDICATOR_TREE_WIDTH      150
  // --- Param form (right of indicator tree in Settings tab)
   #define INDICATOR_PARAM_ROWS      4
   #define INDICATOR_PARAM_LABEL_W   100  
   #define INDICATOR_PARAM_FIELD_W   80
   #define INDICATOR_PARAM_COL_WIDTH (INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W + 12)
   #define PARAM_FORM_X              (INDICATOR_TREE_WIDTH + 10)
   #define PARAM_FORM_Y              5
   #define PARAM_ROW_H               30 
  // --- Indicator table: below Add button with 10px gap; width auto-fills m_tabs_main via AutoXResizeMode.
   #define INDICATOR_TABLE_X         PARAM_FORM_X
   #define INDICATOR_TABLE_Y         (PARAM_FORM_Y + INDICATOR_PARAM_ROWS * PARAM_ROW_H + 10 + M_CONTROL_HEIGHT + 10)
  // --- Symbol/TF setting table (Symbol TF sub-tab): note row on top, save button below it,
  // --- table below the button - same 10px gap convention as INDICATOR_TABLE_Y.
   #define SYMBOLTF_BTN_Y            (M_CONTROL_HEIGHT + 5)
   #define SYMBOLTF_TABLE_Y          (SYMBOLTF_BTN_Y + M_CONTROL_HEIGHT + 10)  
   #define POSITIONS_TABLE_Y            175   
  // Signal Markers bridge file header magic - MUST match Indicators\Vendors\Anhnt\Custom Buildin\SignalMarkers.mq5's own   
   #define SIGNAL_BRIDGE_MAGIC       20260808
  // How far INSIDE the popup's near edge the cursor sits when it appears - NOT a gap.
   #define CANDLE_INFO_CURSOR_INSET  15
  //For Indicator table field show in m_table_indicator and m_table_indicator_SymbolTFValue
   
   #define PATTERN_HOVER_LABEL_NAME  "GUIPannel_PatternHoverLabel"
  // --- TAB_TAB_MAIN_TRADING: m_table_indicator_PreTradeSymbolMonitor sits on the left, the New
  // --- Order form (CreateTradingForm) starts right after it - X is read directly off the table's own
  // --- X2() at the GUIPannel_Lifecycle.mqh call site now, not a hand-computed width formula (Anhnt/
  // --- Claude, 2026-09-08 - the old PRETRADE_MONITOR_TABLE_WIDTH/TRADING_FORM_X formula went stale
  // --- every time the table's own columns changed, leaving a growing gap).
  // --- TRADING_FORM_ROWS_TOTAL rows (Symbol/Lot/Direction/OrderType/4 checkboxes+edit row/Send) -
  // --- TRADING_FORM_HEIGHT is shared by the PreTradeSymbolMonitor table's own YSize (so both top-row
  // --- elements end at the same Y) and by m_table_positions_StoplostAndTrailling's Y (starts right
  // --- below, instead of the old fixed POSITIONS_TABLE_Y which the taller form now overlapped).
   #define TRADING_FORM_ROWS_TOTAL   9
   #define TRADING_FORM_HEIGHT       (TRADING_FORM_ROWS_TOTAL * M_CONTROL_YDISTANCE + M_CONTROL_HEIGHT)
#endif // CGUIPANNELDEFINE_MQH

