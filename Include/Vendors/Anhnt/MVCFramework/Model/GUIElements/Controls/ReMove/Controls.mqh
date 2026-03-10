//+------------------------------------------------------------------+
//|                                                     Controls.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __CONTROLS_MQH__
#define __CONTROLS_MQH__

//+------------------------------------------------------------------+
//|                                                     Controls.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Included libraries                                               |
//+------------------------------------------------------------------+
//#include "Base.mqh"

//+------------------------------------------------------------------+
//| Macro substitutions Move to ControlDefine.mqh                    |
//+------------------------------------------------------------------+
// #define  DEF_LABEL_W                50          // Default label width
// #define  DEF_LABEL_H                16          // Default label height
// #define  DEF_BUTTON_W               60          // Default button width
// #define  DEF_BUTTON_H               16          // Default button height
// #define  DEF_TABLE_ROW_H            16          // Default table row height
// #define  DEF_TABLE_HEADER_H         20          // Default table header height
// #define  DEF_TABLE_COLUMN_MIN_W     12          // Minimum table column width
// #define  DEF_PANEL_W                80          // Default panel width
// #define  DEF_PANEL_H                80          // Default panel height
// #define  DEF_PANEL_MIN_W            60          // Minimum panel width
// #define  DEF_PANEL_MIN_H            60          // Minimum panel height
// #define  DEF_SCROLLBAR_TH           13          // Default scrollbar thickness
// #define  DEF_THUMB_MIN_SIZE         8           // Minimum scrollbar thumb size
// #define  DEF_AUTOREPEAT_DELAY       500         // Delay before starting auto-repeat
// #define  DEF_AUTOREPEAT_INTERVAL    100         // Auto-repeat frequency

// #define  DEF_HINT_NAME_TOOLTIP      "HintTooltip"     // Tooltip hint name
// #define  DEF_HINT_NAME_HORZ         "HintHORZ"        // Hint name "Double horizontal arrow"
// #define  DEF_HINT_NAME_VERT         "HintVERT"        // Hint name "Double vertical arrow"
// #define  DEF_HINT_NAME_NWSE         "HintNWSE"        // Hint name "Double arrow top-left --- bottom-right (NorthWest-SouthEast)"
// #define  DEF_HINT_NAME_NESW         "HintNESW"        // Hint name "Double arrow bottom-left --- top-right (NorthEast-SouthWest)"
// #define  DEF_HINT_NAME_SHIFT_HORZ   "HintShiftHORZ"   // Hint name "Horizontal shift arrow"
// #define  DEF_HINT_NAME_SHIFT_VERT   "HintShiftVERT"   // Hint name "Vertical shift arrow"

//+------------------------------------------------------------------+
//| Enumerations Move to ControlsEnums                               |
//+------------------------------------------------------------------+
// enum ENUM_ELEMENT_SORT_BY                       // Comparable properties
//   {
//    ELEMENT_SORT_BY_ID   =  BASE_SORT_BY_ID,     // Compare by element ID
//    ELEMENT_SORT_BY_NAME =  BASE_SORT_BY_NAME,   // Compare by element name
//    ELEMENT_SORT_BY_X    =  BASE_SORT_BY_X,      // Compare by element X coordinate
//    ELEMENT_SORT_BY_Y    =  BASE_SORT_BY_Y,      // Compare by element Y coordinate
//    ELEMENT_SORT_BY_WIDTH=  BASE_SORT_BY_WIDTH,  // Compare by element width
//    ELEMENT_SORT_BY_HEIGHT= BASE_SORT_BY_HEIGHT, // Compare by element height
//    ELEMENT_SORT_BY_ZORDER= BASE_SORT_BY_ZORDER, // Compare by element Z-order
//    ELEMENT_SORT_BY_TEXT,                        // Compare by element text
//    ELEMENT_SORT_BY_COLOR_BG,                    // Compare by element background color
//    ELEMENT_SORT_BY_ALPHA_BG,                    // Compare by element background transparency
//    ELEMENT_SORT_BY_COLOR_FG,                    // Compare by element foreground color
//    ELEMENT_SORT_BY_ALPHA_FG,                    // Compare by element foreground transparency
//    ELEMENT_SORT_BY_STATE,                       // Compare by element state
//    ELEMENT_SORT_BY_GROUP,                       // Compare by element group
//   };

// enum ENUM_TABLE_SORT_MODE                       // Table column sorting modes
//   {
//    TABLE_SORT_MODE_NONE,                        // No sorting
//    TABLE_SORT_MODE_ASC,                         // Sort ascending
//    TABLE_SORT_MODE_DESC,                        // Sort descending
//   };

// enum ENUM_HINT_TYPE                             // Hint types
//   {
//    HINT_TYPE_TOOLTIP,                           // Tooltip
//    HINT_TYPE_ARROW_HORZ,                        // Double horizontal arrow
//    HINT_TYPE_ARROW_VERT,                        // Double vertical arrow
//    HINT_TYPE_ARROW_NWSE,                        // Double arrow top-left --- bottom-right (NorthWest-SouthEast)
//    HINT_TYPE_ARROW_NESW,                        // Double arrow bottom-left --- top-right (NorthEast-SouthWest)
//    HINT_TYPE_ARROW_SHIFT_HORZ,                  // Horizontal shift arrow
//    HINT_TYPE_ARROW_SHIFT_VERT,                  // Vertical shift arrow
//   };

#endif // __CONTROLS_MQH__