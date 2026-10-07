//+------------------------------------------------------------------+
//|                                               GraphDefines.mqh   |
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Link                      https://www.mql5.com/en/articles/10237  |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __GRAPH_DEFINES_MQH__
#define __GRAPH_DEFINES_MQH__
//+------------------------------------------------------------------+
//| The list of graphical element types                              |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_ELEMENT_TYPE
  {
     GRAPH_ELEMENT_TYPE_STANDARD,                       // Standard graphical object
  };
//+------------------------------------------------------------------+
//| Integer properties of a standard graphical object                |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_PROP_INTEGER
  {
   //--- Additional properties
    GRAPH_OBJ_PROP_ID = 0,                             // Object ID
    GRAPH_OBJ_PROP_BASE_ID,                            // Base object ID
    GRAPH_OBJ_PROP_TYPE,                               // Graphical object type (ENUM_OBJECT)
    GRAPH_OBJ_PROP_ELEMENT_TYPE,                       // Graphical element type (ENUM_GRAPH_ELEMENT_TYPE)
    GRAPH_OBJ_PROP_SPECIES,                            // Graphical object species (ENUM_GRAPH_OBJ_SPECIES)
    GRAPH_OBJ_PROP_BELONG,                             // Graphical object affiliation
    GRAPH_OBJ_PROP_CHART_ID,                           // Chart ID
    GRAPH_OBJ_PROP_WND_NUM,                            // Chart subwindow index
    GRAPH_OBJ_PROP_NUM,                                // Object index in the list
    GRAPH_OBJ_PROP_CHANGE_HISTORY,                     // Flag of storing the change history
    GRAPH_OBJ_PROP_GROUP,                              // Group of objects the graphical object belongs to
   //--- Common properties of all graphical objects
    GRAPH_OBJ_PROP_CREATETIME,                         // Object creation time
    GRAPH_OBJ_PROP_TIMEFRAMES,                         // Object visibility on timeframes
    GRAPH_OBJ_PROP_BACK,                               // Background object
    GRAPH_OBJ_PROP_ZORDER,                             // Priority of a graphical object for receiving the event of clicking on a chart
    GRAPH_OBJ_PROP_HIDDEN,                             // Disable displaying the name of a graphical object in the terminal object list
    GRAPH_OBJ_PROP_SELECTED,                           // Object selection
    GRAPH_OBJ_PROP_SELECTABLE,                         // Object availability
//--- Properties belonging to different graphical objects
    GRAPH_OBJ_PROP_TIME,                               // Time coordinate
    GRAPH_OBJ_PROP_COLOR,                              // Color
    GRAPH_OBJ_PROP_STYLE,                              // Style
    GRAPH_OBJ_PROP_WIDTH,                              // Line width
    GRAPH_OBJ_PROP_FILL,                               // Object color filling
    GRAPH_OBJ_PROP_READONLY,                           // Ability to edit text in the Edit object
    GRAPH_OBJ_PROP_LEVELS,                             // Number of levels
    GRAPH_OBJ_PROP_LEVELCOLOR,                         // Level line color
    GRAPH_OBJ_PROP_LEVELSTYLE,                         // Level line style
    GRAPH_OBJ_PROP_LEVELWIDTH,                         // Level line width
    GRAPH_OBJ_PROP_ALIGN,                              // Horizontal text alignment in the Edit object (OBJ_EDIT)
    GRAPH_OBJ_PROP_FONTSIZE,                           // Font size
    GRAPH_OBJ_PROP_RAY_LEFT,                           // Ray goes to the left
    GRAPH_OBJ_PROP_RAY_RIGHT,                          // Ray goes to the right
    GRAPH_OBJ_PROP_RAY,                                // Vertical line goes through all windows of a chart
    GRAPH_OBJ_PROP_ELLIPSE,                            // Display the full ellipse of the Fibonacci Arc object
    GRAPH_OBJ_PROP_ARROWCODE,                          // Arrow code for the "Arrow" object
    GRAPH_OBJ_PROP_ANCHOR,                             // Position of the binding point of the graphical object
    GRAPH_OBJ_PROP_XDISTANCE,                          // Distance from the base corner along the X axis in pixels
    GRAPH_OBJ_PROP_YDISTANCE,                          // Distance from the base corner along the Y axis in pixels
    GRAPH_OBJ_PROP_DIRECTION,                          // Gann object trend
    GRAPH_OBJ_PROP_DEGREE,                             // Elliott wave marking level
    GRAPH_OBJ_PROP_DRAWLINES,                          // Display lines for Elliott wave marking
    GRAPH_OBJ_PROP_STATE,                              // Button state (pressed/released)
    GRAPH_OBJ_PROP_CHART_OBJ_CHART_ID,                 // Chart object ID (OBJ_CHART).
    GRAPH_OBJ_PROP_CHART_OBJ_PERIOD,                   // Chart object period
    GRAPH_OBJ_PROP_CHART_OBJ_DATE_SCALE,               // Time scale display flag for the Chart object
    GRAPH_OBJ_PROP_CHART_OBJ_PRICE_SCALE,              // Price scale display flag for the Chart object
    GRAPH_OBJ_PROP_CHART_OBJ_CHART_SCALE,              // Chart object scale
    GRAPH_OBJ_PROP_XSIZE,                              // Object width along the X axis in pixels.
    GRAPH_OBJ_PROP_YSIZE,                              // Object height along the Y axis in pixels.
    GRAPH_OBJ_PROP_XOFFSET,                            // X coordinate of the upper-left corner of the visibility area.
    GRAPH_OBJ_PROP_YOFFSET,                            // Y coordinate of the upper-left corner of the visibility area.
    GRAPH_OBJ_PROP_BGCOLOR,                            // Background color for OBJ_EDIT, OBJ_BUTTON, OBJ_RECTANGLE_LABEL
    GRAPH_OBJ_PROP_CORNER,                             // Chart corner for binding a graphical object
    GRAPH_OBJ_PROP_BORDER_TYPE,                        // Border type for "Rectangle border"
    GRAPH_OBJ_PROP_BORDER_COLOR,                       // Border color for OBJ_EDIT and OBJ_BUTTON
  };
#define GRAPH_OBJ_PROP_INTEGER_TOTAL (55)             // Total number of integer properties
//+------------------------------------------------------------------+
//| Real properties of a standard graphical object                   |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_PROP_DOUBLE
  {
   GRAPH_OBJ_PROP_PRICE = GRAPH_OBJ_PROP_INTEGER_TOTAL,// Price coordinate
   GRAPH_OBJ_PROP_LEVELVALUE,                         // Level value
   GRAPH_OBJ_PROP_SCALE,                              // Scale (property of Gann objects and Fibonacci Arcs objects)
   GRAPH_OBJ_PROP_ANGLE,                              // Angle
   GRAPH_OBJ_PROP_DEVIATION,                          // Deviation of the standard deviation channel
  };
#define GRAPH_OBJ_PROP_DOUBLE_TOTAL  (5)              // Total number of real properties
//+------------------------------------------------------------------+
//| String properties of a standard graphical object                 |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_PROP_STRING
  {
   GRAPH_OBJ_PROP_NAME = (GRAPH_OBJ_PROP_INTEGER_TOTAL+GRAPH_OBJ_PROP_DOUBLE_TOTAL), // Object name
   GRAPH_OBJ_PROP_BASE_NAME,                          // Base object name
   GRAPH_OBJ_PROP_TEXT,                               // Object description (text contained in the object)
   GRAPH_OBJ_PROP_TOOLTIP,                            // Tooltip text
   GRAPH_OBJ_PROP_LEVELTEXT,                          // Level description
   GRAPH_OBJ_PROP_FONT,                               // Font
   GRAPH_OBJ_PROP_BMPFILE,                            // BMP file name for the "Bitmap Level" object
   GRAPH_OBJ_PROP_CHART_OBJ_SYMBOL,                   // Symbol for the Chart object 
  };
#define GRAPH_OBJ_PROP_STRING_TOTAL  (8)              // Total number of string properties

#endif // __GRAPH_DEFINES_MQH__
