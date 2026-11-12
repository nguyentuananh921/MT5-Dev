//+------------------------------------------------------------------+
//|                                                  BaseEnums.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
#ifndef __BASEENUMS_MQH__
#define __BASEENUMS_MQH__       
   enum ENUM_ELEMENT_TYPE                    // Enumeration of types of graphic elements
   {
      ELEMENT_TYPE_BASE = 0x10000,           // Basic object of graphic elements
      ELEMENT_TYPE_COLOR,                    // Color object
      ELEMENT_TYPE_COLORS_ELEMENT,           // Graphics Element Colors Object
      ELEMENT_TYPE_RECTANGLE_AREA,           // Rectangular element area
      ELEMENT_TYPE_IMAGE_PAINTER,            // Object for drawing images
      ELEMENT_TYPE_COUNTER,                  // Counter object
      ELEMENT_TYPE_AUTOREPEAT_CONTROL,       // Auto-repeat event object
      ELEMENT_TYPE_BOUNDED_BASE,             // Basic object of dimensions of graphic elements
      ELEMENT_TYPE_CANVAS_BASE,              // Basic graphic element canvas object
      ELEMENT_TYPE_ELEMENT_BASE,             // Basic object of graphic elements
      ELEMENT_TYPE_HINT,                     // Clue
      ELEMENT_TYPE_LABEL,                    // Text label
      ELEMENT_TYPE_BUTTON,                   // Simple button
      ELEMENT_TYPE_BUTTON_TRIGGERED,         // Two-position button
      ELEMENT_TYPE_BUTTON_ARROW_UP,          // Up arrow button
      ELEMENT_TYPE_BUTTON_ARROW_DOWN,        // Down arrow button
      ELEMENT_TYPE_BUTTON_ARROW_LEFT,        // Left Arrow Button
      ELEMENT_TYPE_BUTTON_ARROW_RIGHT,       // Right arrow button
      ELEMENT_TYPE_CHECKBOX,                 // CheckBox control
      ELEMENT_TYPE_RADIOBUTTON,              // RadioButton control
      ELEMENT_TYPE_SCROLLBAR_THUMB_H,        // Horizontal scroll bar slider
      ELEMENT_TYPE_SCROLLBAR_THUMB_V,        // Vertical scroll bar slider
      ELEMENT_TYPE_SCROLLBAR_H,              // ScrollBarHorizontal control
      ELEMENT_TYPE_SCROLLBAR_V,              // ScrollBarVertical control
      ELEMENT_TYPE_TABLE_CELL_VIEW,          // Table cell (View)
      ELEMENT_TYPE_TABLE_ROW_VIEW,           // Table row (View)
      ELEMENT_TYPE_TABLE_CAPTION_VIEW,       // Basic header object (View)
      ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW,// Table Column Header (View)
      ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW,   // Table Row Header (View)
      ELEMENT_TYPE_TABLE_HEADER_VIEW,        // Table title (View)
      ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW,   // Table row header (View)
      ELEMENT_TYPE_TABLE_VIEW,               // Table (View)
   //| Update in: Customizable and sortable table columns               |
   //|                           https://www.mql5.com/en/articles/19979 |
      ELEMENT_TYPE_TABLE_CONTROL_VIEW,       // Table Control (View) 
   //--------------------------------------------------------------------   
      ELEMENT_TYPE_PANEL,                    // Panel control
      ELEMENT_TYPE_GROUPBOX,                 // GroupBox control
      ELEMENT_TYPE_CONTAINER,                // Container control
   };
   #define  ACTIVE_ELEMENT_MIN   ELEMENT_TYPE_LABEL               // Minimum value of the list of active elements
   #define  ACTIVE_ELEMENT_MAX   ELEMENT_TYPE_TABLE_HEADER_VIEW   // Maximum value of the list of active elements

   enum ENUM_ELEMENT_STATE                   // Item State
   {
      ELEMENT_STATE_DEF,                     // Default (e.g. button released, etc.)
      ELEMENT_STATE_ACT,                     // Activated (eg button pressed, etc.)
   };

   enum ENUM_COLOR_STATE                     // Enumerating element state colors
   {
      COLOR_STATE_DEFAULT,                   // Normal color
      COLOR_STATE_FOCUSED,                   // Color when hovering over an element
      COLOR_STATE_PRESSED,                   // Color when clicking on an element
      COLOR_STATE_BLOCKED,                   // Blocked element color
   };
   
   enum ENUM_BASE_COMPARE_BY                 // Comparable properties of base objects
   {
      BASE_SORT_BY_ID   =  0,                // Comparing base objects by ID
      BASE_SORT_BY_NAME,                     // Compare base objects by name
      BASE_SORT_BY_X,                        // Comparison of base objects by X coordinate
      BASE_SORT_BY_Y,                        // Comparison of base objects by Y coordinate
      BASE_SORT_BY_WIDTH,                    // Comparing base objects by width
      BASE_SORT_BY_HEIGHT,                   // Comparison of base objects by height
      BASE_SORT_BY_ZORDER,                   // Comparison by Z-order of objects
   };
   
   enum ENUM_CURSOR_REGION                   // Enumerating cursor locations on element boundaries
   {
      CURSOR_REGION_NONE,                    // No
      CURSOR_REGION_TOP,                     // On the top edge
      CURSOR_REGION_BOTTOM,                  // On the bottom edge
      CURSOR_REGION_LEFT,                    // On the left side
      CURSOR_REGION_RIGHT,                   // On the right side
      CURSOR_REGION_LEFT_TOP,                // In the upper left corner
      CURSOR_REGION_LEFT_BOTTOM,             // In the lower left corner
      CURSOR_REGION_RIGHT_TOP,               // In the upper right corner
      CURSOR_REGION_RIGHT_BOTTOM,            // In the lower right corner
   };
   
   enum ENUM_RESIZE_ZONE_ACTION              // Enumerating interactions with an element's drop zone
   {
      RESIZE_ZONE_ACTION_NONE,               // No
      RESIZE_ZONE_ACTION_HOVER,              // Hover over a zone
      RESIZE_ZONE_ACTION_BEGIN,              // Start dragging
      RESIZE_ZONE_ACTION_DRAG,               // Drag and drop process
      RESIZE_ZONE_ACTION_END                 // Completing Drag and Drop
   };  
#endif // __BASEENUMS_MQH__
