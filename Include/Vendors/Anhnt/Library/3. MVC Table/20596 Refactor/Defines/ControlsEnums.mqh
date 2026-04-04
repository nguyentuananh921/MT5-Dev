//+------------------------------------------------------------------+
//|                                              ControlsEnums.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>

#ifndef __CONTROLSENUMS_MQH__
#define __CONTROLSENUMS_MQH__
    //+------------------------------------------------------------------+
//| Enums |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_SORT_BY                       // Comparable Properties
  {
   ELEMENT_SORT_BY_ID   =  BASE_SORT_BY_ID,     // Comparison by element ID
   ELEMENT_SORT_BY_NAME =  BASE_SORT_BY_NAME,   // Comparison by element name
   ELEMENT_SORT_BY_X    =  BASE_SORT_BY_X,      // Comparison by element's X coordinate
   ELEMENT_SORT_BY_Y    =  BASE_SORT_BY_Y,      // Comparison by element's Y coordinate
   ELEMENT_SORT_BY_WIDTH=  BASE_SORT_BY_WIDTH,  // Comparison by element width
   ELEMENT_SORT_BY_HEIGHT= BASE_SORT_BY_HEIGHT, // Comparison by element height
   ELEMENT_SORT_BY_ZORDER= BASE_SORT_BY_ZORDER, // Comparison by Z-order of an element
   ELEMENT_SORT_BY_TEXT,                        // Comparison by element text
   ELEMENT_SORT_BY_COLOR_BG,                    // Comparison by element background color
   ELEMENT_SORT_BY_ALPHA_BG,                    // Comparison of element background transparency
   ELEMENT_SORT_BY_COLOR_FG,                    // Comparison by element's foreground color
   ELEMENT_SORT_BY_ALPHA_FG,                    // Comparison by foreground element transparency
   ELEMENT_SORT_BY_STATE,                       // Comparison by item condition
   ELEMENT_SORT_BY_GROUP,                       // Comparison by element group
  };

enum ENUM_TABLE_SORT_MODE                       // Table column sorting modes
   {
      TABLE_SORT_MODE_NONE,                        // No sorting
      TABLE_SORT_MODE_ASC,                         // Sort in ascending order
      TABLE_SORT_MODE_DESC,                        // Sort in descending order
   };

enum ENUM_HINT_TYPE                             // Types of tooltips
  {
   HINT_TYPE_TOOLTIP,                           // Tooltip
   HINT_TYPE_ARROW_HORZ,                        // Double horizontal arrow
   HINT_TYPE_ARROW_VERT,                        // Double vertical arrow
   HINT_TYPE_ARROW_NWSE,                        // Double arrow top-left --- bottom-right (NorthWest-SouthEast)
   HINT_TYPE_ARROW_NESW,                        // Double arrow bottom-left --- top-right (NorthEast-SouthWest)
   HINT_TYPE_ARROW_SHIFT_HORZ,                  // Horizontal offset arrow
   HINT_TYPE_ARROW_SHIFT_VERT,                  // Vertical offset arrow
  };

enum ENUM_ROWS_HIGHLIGHT_MODE                   // Table row/cell highlighting modes
  {
   ROWS_HIGHLIGHT_MODE_CELLS,                   // Highlight individual cells (cell mode)
   ROWS_HIGHLIGHT_MODE_ROW,                     // Highlight the entire line (line mode)
  };  
#endif // __CONTROLSENUMS_MQH__
