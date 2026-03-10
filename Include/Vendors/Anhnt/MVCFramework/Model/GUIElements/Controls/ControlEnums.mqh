//+------------------------------------------------------------------+
//|                                                 ControlEnums.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __CONTROL_ENUMS_MQH__            // Chat GPT add here for include guard
#define __CONTROL_ENUMS_MQH__            // Chat GPT add here for include guard
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+

#include "..\Base\BaseEnums.mqh"
enum ENUM_ELEMENT_SORT_BY                       // Comparable properties
  {
   ELEMENT_SORT_BY_ID   =  BASE_SORT_BY_ID,     // Compare by element ID
   ELEMENT_SORT_BY_NAME =  BASE_SORT_BY_NAME,   // Compare by element name
   ELEMENT_SORT_BY_X    =  BASE_SORT_BY_X,      // Compare by element X coordinate
   ELEMENT_SORT_BY_Y    =  BASE_SORT_BY_Y,      // Compare by element Y coordinate
   ELEMENT_SORT_BY_WIDTH=  BASE_SORT_BY_WIDTH,  // Compare by element width
   ELEMENT_SORT_BY_HEIGHT= BASE_SORT_BY_HEIGHT, // Compare by element height
   ELEMENT_SORT_BY_ZORDER= BASE_SORT_BY_ZORDER, // Compare by element Z-order
   ELEMENT_SORT_BY_TEXT,                        // Compare by element text
   ELEMENT_SORT_BY_COLOR_BG,                    // Compare by element background color
   ELEMENT_SORT_BY_ALPHA_BG,                    // Compare by element background transparency
   ELEMENT_SORT_BY_COLOR_FG,                    // Compare by element foreground color
   ELEMENT_SORT_BY_ALPHA_FG,                    // Compare by element foreground transparency
   ELEMENT_SORT_BY_STATE,                       // Compare by element state
   ELEMENT_SORT_BY_GROUP,                       // Compare by element group
  };

enum ENUM_TABLE_SORT_MODE                       // Table column sorting modes
  {
   TABLE_SORT_MODE_NONE,                        // No sorting
   TABLE_SORT_MODE_ASC,                         // Sort ascending
   TABLE_SORT_MODE_DESC,                        // Sort descending
  };

enum ENUM_HINT_TYPE                             // Hint types
  {
   HINT_TYPE_TOOLTIP,                           // Tooltip
   HINT_TYPE_ARROW_HORZ,                        // Double horizontal arrow
   HINT_TYPE_ARROW_VERT,                        // Double vertical arrow
   HINT_TYPE_ARROW_NWSE,                        // Double arrow top-left --- bottom-right (NorthWest-SouthEast)
   HINT_TYPE_ARROW_NESW,                        // Double arrow bottom-left --- top-right (NorthEast-SouthWest)
   HINT_TYPE_ARROW_SHIFT_HORZ,                  // Horizontal shift arrow
   HINT_TYPE_ARROW_SHIFT_VERT,                  // Vertical shift arrow
  };

#endif // __CONTROL_ENUMS_MQH__        // Chat GPT add here for include guard