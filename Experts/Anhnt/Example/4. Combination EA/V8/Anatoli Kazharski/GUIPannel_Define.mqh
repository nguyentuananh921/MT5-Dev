
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
   #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Timeseries\PatternRenderer.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>  
   #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
   #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\NewBarObj.mqh>   
   #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Trading\TradingLevelBubble.mqh>
   #include "..\Services\SignalLogger.mqh"
   #include "..\Services\SignalBridgeWriter.mqh"
   
  // For indicator catalog/schema + CTimeSeriesEngine itself - JSON loading and
  // indicator creation live there now, GUIPannel only reads + renders (EA-local, not the Library)
   #include "..\Artyom Trishkin\TimeSeriesEngine.mqh"
 // For GUI controls Layer 2
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Keys.mqh>
  //#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\SplitContainer.mqh>
 // Layer-3 observer: charts/windows/indicators state + CHART_OBJ_EVENT_* events (no WForms deps)
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
 // For CMessage::PlaySound/Out - per-indicator Sound/Message alerts (2026-07-17)
  #include <Vendors\Anhnt\Library\4. Combination Lib\Notify\Message\Message.mqh>

  enum ENUM_CHECKBOX_STATE
    {
      CHECKBOX_STATE_ON  = 0,
      CHECKBOX_STATE_OFF = 1,
    };
 // Define GUI control
  // --- Main panel window m_window_main
    #define M_WINDOW_MAIN_WIDTH         750
    #define M_WINDOW_MAIN_HEIGHT        480
    #define M_WINDOW_MAIN_MIN_WIDTH     300
    #define M_WINDOW_MAIN_MIN_HEIGHT    200
   //Left pannel m_treeview_SymbolTF (fixed left strip, visible on all tabs)   
    #define M_CONTROL_BORDER_GAP        3  //Gap between border of two control
    #define M_TREEVIEW_SYMBOLTF_WIDTH   85    
   //Right Pannel m_tabs_main starts at (TABS_MAIN_X, TABS_MAIN_Y) inside m_Mainwindow.        
    #define M_TABS_MAIN_X               M_CONTROL_BORDER_GAP+M_TREEVIEW_SYMBOLTF_WIDTH +M_CONTROL_BORDER_GAP
    #define M_TABS_MAIN_Y               43  //WINDOW_CAPTION_HEIGHT = 22
    #define M_TABS_MAIN_WIDTH           (M_WINDOW_MAIN_WIDTH - M_TABS_MAIN_X - M_CONTROL_BORDER_GAP)
    enum ENUM_TAB_MAIN
     {
      TAB_TAB_MAIN_ACCOUNT_INFO = 0,
      TAB_TAB_MAIN_SYMBOL_INFO,
      TAB_TAB_MAIN_MONITOR,      
      TAB_TAB_MAIN_POSITIONS,
      TAB_TAB_MAIN_HISTORY,
      TAB_TAB_MAIN_SETTINGS,
      TAB_TAB_MAIN_EVENTS, //For Pattern Information      
      TAB_TAB_MAIN_TOTAL,
     };
     //m_tabs_main_setting_config      
      enum ENUM_TAB_MAIN_SETTINGS_CONFIG
       {
        TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR =0,
        TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF,
        TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN,    
        TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER,
        TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL,
       };      
      enum ENUM_INDICATOR_SHOW_STATE
       {
        INDICATOR_SHOW_ON_CHART = CHECKBOX_STATE_ON,
        INDICATOR_HIDE_ON_CHART = CHECKBOX_STATE_OFF,
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
   // Status bar items
    #define STATUS_LABELS_TOTAL 4
    enum ENUM_STATUS_BAR_ITEM
     {
      STATUS_BAR_HELP = 0,
      STATUS_BAR_DEPOSIT_LOAD,
      STATUS_BAR_PROFIT,
      STATUS_BAR_SERVER_TIME,
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
  // --- ENUM_*_PARAM named slot indices live in IndicatorCatalog.mqh (Tang 1),
  // --- co-located with GetIndicatorParamSchema(). Pulled in via TimeSeriesEngine.mqh.
  // =====================================================================
  // --- Layout constants: all pixel dimensions defined here.
  // --- Change here; derived values update automatically.
  // ===================================================================== 
  // --- Nested m_tabs_main_setting_config header (its own tab row draws ABOVE its
  // --- canvas - offsetting its canvas down by the header height keeps that row
  // --- clear of m_tabs_main's own tab headers instead of overlapping them).
   #define TABS_CONFIG_HEADER_H      22
  // --- Indicator tree (Settings tab, left column)
   #define INDICATOR_TREE_WIDTH      150
  // --- Param form (right of indicator tree in Settings tab)
   #define INDICATOR_PARAM_ROWS      4
   #define INDICATOR_PARAM_LABEL_W   100
  // --- FIELD_W must clear the longest label across ALL indicator types
  // --- (e.g. "Slow EMA Period", "Applied Volume").
   #define INDICATOR_PARAM_FIELD_W   80
   #define INDICATOR_PARAM_COL_WIDTH (INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W + 12)
   #define PARAM_FORM_X              (INDICATOR_TREE_WIDTH + 10)
   #define PARAM_FORM_Y              5
   #define PARAM_ROW_H               30
   //#define ADD_BTN_H                 22
   #define BTN_HEIGHT                 22
  // --- Indicator table: below Add button with 10px gap; width auto-fills m_tabs_main via AutoXResizeMode.
   #define INDICATOR_TABLE_X         PARAM_FORM_X
   #define INDICATOR_TABLE_Y         (PARAM_FORM_Y + INDICATOR_PARAM_ROWS * PARAM_ROW_H + 10 + BTN_HEIGHT + 10)
  // --- Symbol/TF setting table (Symbol TF sub-tab): note row on top, save button below it,
  // --- table below the button - same 10px gap convention as INDICATOR_TABLE_Y.
   #define SYMBOLTF_NOTE_H           20
   #define SYMBOLTF_BTN_Y            (SYMBOLTF_NOTE_H + 5)
   #define SYMBOLTF_TABLE_Y          (SYMBOLTF_BTN_Y + BTN_HEIGHT + 10)
  // --- Positions tab: pre-trade-plan area above m_table_positions (Anhnt 2026-07-20).
  // --- Row 1 (y=POSITIONS_PLAN_Y): m_combo_pre_Trade_plan_symbol.
  // --- Row 2 (y=POSITIONS_PLAN_CONTROLS_Y): Distance mode+value, Lot mode+value - one
  // --- horizontal row per user request ("dàn hàng ngang").
  // --- Row 3 (y=POSITIONS_PLAN_TABLE_Y): m_table_pre_Trade_plan.
   #define POSITIONS_PLAN_Y             0
   #define POSITIONS_PLAN_CONTROLS_Y    25
   #define POSITIONS_PLAN_TABLE_Y       50
   #define POSITIONS_TABLE_Y            175
  // --- Candle info popup (BugNote 7.2): Ctrl+hover shows m_table_candle_information_atBar -
  // --- every tracked Indicator (current chart's symbol, every TF with a BarSeries) with its
  // --- Signal direction at the hovered bar. Fixed at the chart's top-right corner - content
  // --- only, no drag-to-follow-cursor (CWindow has no simple move-to-XY API, only manual
  // --- drag state).
   #define CANDLE_INFO_WINDOW_W      300
   #define CANDLE_INFO_WINDOW_H      220
   // --- Signal Markers bridge file header magic - MUST match SignalMarkers.mq5's own
   // --- SIGNAL_BRIDGE_MAGIC exactly (Indicators\Vendors\Anhnt\Custom Buildin\SignalMarkers.mq5).
   #define SIGNAL_BRIDGE_MAGIC       20260808
   // --- How far INSIDE the popup's near edge the cursor sits when it appears - NOT a gap.
   // --- BugNote 2026-07-16: a GAP between cursor and popup meant the mouse had to cross that
   // --- stretch of raw chart to reach it, and on a zoomed-out TF that stretch covers OTHER
   // --- candles, each flipping bar_time (and re-triggering RepositionCandleInfoWindow) along
   // --- the way - the popup kept jumping just out of reach. Placing the cursor already INSIDE
   // --- the popup's rect the instant it appears means MouseOverCandleInfoWindow() is true
   // --- before the user moves at all - zero distance left to cross.
   #define CANDLE_INFO_CURSOR_INSET  15
  //For Indicator table field show in m_table_indicator and m_table_indicator_SymbolTFValue
   #define INDICATOR_PARATEXT_WIDTH 180 //Include name + Icon
  // --- Alt + hover pattern bitmap label (GUIPannel_CandleInfoWindow.mqh:ShowPatternBitmapAtBar).
  // --- One fixed OBJ_TEXT object, repositioned/retexted per hover - native OBJPROP_TOOLTIP
  // --- hover-delay proved unreliable while the mouse keeps moving with Alt held, so the name
  // --- is drawn directly on chart instead.
   #define PATTERN_HOVER_LABEL_NAME  "GUIPannel_PatternHoverLabel"
#endif // CGUIPANNELDEFINE_MQH

