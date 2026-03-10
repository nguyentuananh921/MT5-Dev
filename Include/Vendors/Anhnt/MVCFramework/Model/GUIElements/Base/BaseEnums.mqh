//+------------------------------------------------------------------+
//|                                                    BaseEnums.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|               https://www.mql5.com/en/articles/19979             |
//+------------------------------------------------------------------+
#ifndef __BASE_ENUMS_MQH__
#define __BASE_ENUMS_MQH__
//+------------------------------------------------------------------+
//| Enumeration of element types                                     |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_TYPE                    // Enumeration of graphical element types
  {
   ELEMENT_TYPE_BASE = 0x10000,           // Base graphical element object
   ELEMENT_TYPE_COLOR,                    // Color object
   ELEMENT_TYPE_COLORS_ELEMENT,           // Graphical element color set
   ELEMENT_TYPE_RECTANGLE_AREA,           // Rectangle area element
   ELEMENT_TYPE_IMAGE_PAINTER,            // Image drawing object
   ELEMENT_TYPE_COUNTER,                  // Counter object
   ELEMENT_TYPE_AUTOREPEAT_CONTROL,       // Auto-repeat event object
   ELEMENT_TYPE_BOUNDED_BASE,             // Base object with dimensions
   ELEMENT_TYPE_CANVAS_BASE,              // Base canvas object
   ELEMENT_TYPE_ELEMENT_BASE,             // Base graphical element
   ELEMENT_TYPE_HINT,                     // Tooltip
   ELEMENT_TYPE_LABEL,                    // Text label
   ELEMENT_TYPE_BUTTON,                   // Simple button
   ELEMENT_TYPE_BUTTON_TRIGGERED,         // Two-state button
   ELEMENT_TYPE_BUTTON_ARROW_UP,          // Up arrow button
   ELEMENT_TYPE_BUTTON_ARROW_DOWN,        // Down arrow button
   ELEMENT_TYPE_BUTTON_ARROW_LEFT,        // Left arrow button
   ELEMENT_TYPE_BUTTON_ARROW_RIGHT,       // Right arrow button
   ELEMENT_TYPE_CHECKBOX,                 // CheckBox control
   ELEMENT_TYPE_RADIOBUTTON,              // RadioButton control
   ELEMENT_TYPE_SCROLLBAR_THUMB_H,        // Horizontal scrollbar thumb
   ELEMENT_TYPE_SCROLLBAR_THUMB_V,        // Vertical scrollbar thumb
   ELEMENT_TYPE_SCROLLBAR_H,              // Horizontal scrollbar control
   ELEMENT_TYPE_SCROLLBAR_V,              // Vertical scrollbar control
   ELEMENT_TYPE_TABLE_CELL_VIEW,          // Table cell (View)
   ELEMENT_TYPE_TABLE_ROW_VIEW,           // Table row (View)
   ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW,// Table column caption (View)
   ELEMENT_TYPE_TABLE_HEADER_VIEW,        // Table header (View)
   ELEMENT_TYPE_TABLE_VIEW,               // Table (View)
   ELEMENT_TYPE_TABLE_CONTROL_VIEW,       // Table control (View)
   ELEMENT_TYPE_PANEL,                    // Panel control
   ELEMENT_TYPE_GROUPBOX,                 // GroupBox control
   ELEMENT_TYPE_CONTAINER,                // Container control
  };
//+------------------------------------------------------------------+
//| Element state                                                    |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_STATE                   // Element state
  {
   ELEMENT_STATE_DEF,                     // Default state
   ELEMENT_STATE_ACT,                     // Activated state
  };

enum ENUM_COLOR_STATE                     // Element color states
  {
   COLOR_STATE_DEFAULT,                   // Default color
   COLOR_STATE_FOCUSED,                   // Mouse hover color
   COLOR_STATE_PRESSED,                   // Pressed color
   COLOR_STATE_BLOCKED,                   // Disabled color
  };

enum ENUM_BASE_COMPARE_BY                 // Comparable properties of base objects
  {
   BASE_SORT_BY_ID   =  0,                // Compare by identifier
   BASE_SORT_BY_NAME,                     // Compare by name
   BASE_SORT_BY_X,                        // Compare by X coordinate
   BASE_SORT_BY_Y,                        // Compare by Y coordinate
   BASE_SORT_BY_WIDTH,                    // Compare by width
   BASE_SORT_BY_HEIGHT,                   // Compare by height
   BASE_SORT_BY_ZORDER,                   // Compare by Z-order
  };

enum ENUM_CURSOR_REGION                   // Cursor location on element borders
  {
   CURSOR_REGION_NONE,                    // None
   CURSOR_REGION_TOP,                     // Top border
   CURSOR_REGION_BOTTOM,                  // Bottom border
   CURSOR_REGION_LEFT,                    // Left border
   CURSOR_REGION_RIGHT,                   // Right border
   CURSOR_REGION_LEFT_TOP,                // Top-left corner
   CURSOR_REGION_LEFT_BOTTOM,             // Bottom-left corner
   CURSOR_REGION_RIGHT_TOP,               // Top-right corner
   CURSOR_REGION_RIGHT_BOTTOM,            // Bottom-right corner
  };
//+------------------------------------------------------------------+
//| Resize direction                                                 |
//+------------------------------------------------------------------+
enum ENUM_RESIZE_ZONE_ACTION              // Interaction with resize zone
  {
   RESIZE_ZONE_ACTION_NONE,               // None
   RESIZE_ZONE_ACTION_HOVER,              // Cursor hovering
   RESIZE_ZONE_ACTION_BEGIN,              // Start resizing
   RESIZE_ZONE_ACTION_DRAG,               // Resizing process
   RESIZE_ZONE_ACTION_END                 // End resizing
  };

#endif // __BASE_ENUMS_MQH__