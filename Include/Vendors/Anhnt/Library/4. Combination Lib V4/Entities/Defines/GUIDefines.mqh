//+------------------------------------------------------------------+
//|  GUIDefines.mqh
//+------------------------------------------------------------------+
#ifndef __GUIDEFINES_MQH__
#define __GUIDEFINES_MQH__
 #include "MouseDefines.mqh"
// ──────────────────────────────────────────────────────────────────
// Control size
// ──────────────────────────────────────────────────────────────────
  #define M_CONTROL_HEIGHT               22  //Height for MenuBar,Tab, Combobox,Label, and for every box drawn over the chart
  #define M_CONTROL_BORDER_GAP            3  //Gap between border of two control
  #define M_LOT_WIDTH                    65  //Unified width for every column that displays a Lot/Volume (incl. an embedded combobox); its header is "Vol"
  #define M_ICON16_WIDTH                 22  //Width for icon 16x16
  #define M_ICON32_WIDTH                 33  //Width for icon 32x32
  #define M_TF_WITHOUT_ICON_WIDTH        43  //Unified width for every control/column that displays a Timeframe without an icon (a TF button)
  #define M_TF_WITHICON_WIDTH            (M_TF_WITHOUT_ICON_WIDTH+M_ICON16_WIDTH)  //Unified width for every control/column that displays a Timeframe+Icon
  #define M_SYMBOL_WITHICON_WIDTH       110  //Unified width for every column that displays a Symbol+Icon
  #define M_PRICE_WIDTH                  80  //Unified width for every column that displays a price or the live Value of an indicator
  #define M_DATETIME_WIDTH              150  //Unified width for every column that displays a date and a time, YYYY-MM-DD HH:MM
  #define M_TIME_WIDTH                   50  //Unified width for every column that displays a time HH:MM
  #define M_DATETIME_SEC_WIDTH          (M_DATETIME_WIDTH+20)  //Unified width for every column that displays a date and a time with the seconds, YYYY-MM-DD HH:MM:SS (follows M_DATETIME_WIDTH)
  #define M_EVENT_WIDTH                  90  //Unified width for every column that displays the name of an event (SL, TP, DEAL IN...)
  #define M_SPREAD_WIDTH                 50  //Unified width for every column that displays a Spread in points (its header is the icon SPREADRED)
  #define M_DURATION_WIDTH               80  //Unified width for every column that displays a duration, [Nd ]HH:MM:SS
  #define M_TICKET_WIDTH                100  //Unified width for every column that displays a ticket, a position or a deal number of the terminal
  #define M_MONEY_WIDTH                  75  //Unified width for every column that displays an amount of money (commission, swap, fee, profit, net)
  #define M_INDICATOR_PARATEXT_WIDTH    230  //Unified width for every column that displays LabelText + Icon: the Indicator column
  #define M_SWITCH_WIDTH                200  //Unified width for every switch (CButtonTriggered with the OFF / ON icon): the icon and its text, "Support / Resistance OFF"
  //--- The sections of a tab (CSections): the header (the arrow and the name), the toggle at its right (the icon and ON / OFF), the controls of the body under the text of the header
  #define M_FLAG_SWITCH_WIDTH           32   //a switch with no text: the icon of what it stands for at the left, then the switch
  #define M_FLAG_SWITCH_X               16   //where the switch icon is: after the icon of the flag
  #define M_SECTION_HEADER_WIDTH        170
  #define M_SECTION_TOGGLE_WIDTH        M_FLAG_SWITCH_WIDTH   //the flag icon and the switch
  #define M_SECTION_BODY_INDENT         20   //the body is under the text of the header
  #define M_SECTION_COLUMN_WIDTH        192  //the second control of a row starts one column after the first; every control of a column is as wide
// ──────────────────────────────────────────────────────────────────
// The timer step of the controls, in milliseconds
// ──────────────────────────────────────────────────────────────────
  #define TIMER_STEP_MSC      (16)
  #define SPIN_DELAY_MSC      (-450)   // the delay before a spin button of a text edit repeats
// ──────────────────────────────────────────────────────────────────
// The kind of a cell of a table (CTable)
// ──────────────────────────────────────────────────────────────────
 enum ENUM_TYPE_CELL
  {
   CELL_SIMPLE   = 0,
   CELL_BUTTON   = 1,
   CELL_CHECKBOX = 2,
   CELL_COMBOBOX = 3,
   CELL_EDIT     = 4
  };
 //+------------------------------------------------------------------+
 //| Control flag status (checkbox cells of the tables)               |
 //+------------------------------------------------------------------+
 enum ENUM_CANV_ELEMENT_CHECK_STATE
   {
    CANV_ELEMENT_CHECK_STATE_UNCHECKED,                 // Unchecked
    CANV_ELEMENT_CHECK_STATE_CHECKED,                   // Checked
    CANV_ELEMENT_CHECK_STATE_INDETERMINATE,             // Undefined
   };
// ──────────────────────────────────────────────────────────────────
// The side of an item of a menu a context menu is fixed to (CContextMenu)
// ──────────────────────────────────────────────────────────────────
 enum ENUM_FIX_CONTEXT_MENU
  {
   FIX_RIGHT  = 0,
   FIX_BOTTOM = 1
  };
// ──────────────────────────────────────────────────────────────────
// Position of the headers of the tabs (CTabs)
// ──────────────────────────────────────────────────────────────────
 enum ENUM_TABS_POSITION
  {
   TABS_TOP    = 0,
   TABS_BOTTOM = 1,
   TABS_LEFT   = 2,
   TABS_RIGHT  = 3
  };
#endif // __GUIDEFINES_MQH__

