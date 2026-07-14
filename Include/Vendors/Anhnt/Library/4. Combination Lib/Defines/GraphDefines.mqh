//+------------------------------------------------------------------+
//|                                               GraphDefines.mqh   |
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __GRAPH_DEFINES_MQH__
#define __GRAPH_DEFINES_MQH__
#include "EventDefines.mqh"
//+------------------------------------------------------------------+
//| List of anchoring methods                                        |
//| (horizontal and vertical text alignment)                         |
//+------------------------------------------------------------------+
enum ENUM_FRAME_ANCHOR
  {
   FRAME_ANCHOR_LEFT_TOP       =  0,                  // Frame anchor point at the upper left corner of the bounding rectangle
   FRAME_ANCHOR_CENTER_TOP     =  1,                  // Frame anchor point at the top center side of the bounding rectangle
   FRAME_ANCHOR_RIGHT_TOP      =  2,                  // Frame anchor point at the upper right corner of the bounding rectangle
   FRAME_ANCHOR_LEFT_CENTER    =  4,                  // Frame anchor point at the center of the left side of the bounding rectangle
   FRAME_ANCHOR_CENTER         =  5,                  // Frame anchor point at the center of the bounding rectangle
   FRAME_ANCHOR_RIGHT_CENTER   =  6,                  // Frame anchor point at the center of the right side of the bounding rectangle
   FRAME_ANCHOR_LEFT_BOTTOM    =  8,                  // Frame anchor point at the lower left corner of the bounding rectangle
   FRAME_ANCHOR_CENTER_BOTTOM  =  9,                  // Frame anchor point at the bottom center side of the bounding rectangle
   FRAME_ANCHOR_RIGHT_BOTTOM   =  10,                 // Frame anchor point at the lower right corner of the bounding rectangle
  };
//+------------------------------------------------------------------+
//| List of graphical objects affiliations                           |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_BELONG
  {
   GRAPH_OBJ_BELONG_PROGRAM,                          // Graphical object belongs to a program
   GRAPH_OBJ_BELONG_NO_PROGRAM,                       // Graphical object does not belong to a program
  };
//+------------------------------------------------------------------+
//| The list of graphical element types                              |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_ELEMENT_TYPE
  {
   GRAPH_ELEMENT_TYPE_STANDARD,                       // Standard graphical object
   GRAPH_ELEMENT_TYPE_STANDARD_EXTENDED,              // Extended standard graphical object
   GRAPH_ELEMENT_TYPE_SHADOW_OBJ,                     // Shadow object
   GRAPH_ELEMENT_TYPE_ELEMENT,                        // Element
   GRAPH_ELEMENT_TYPE_BITMAP,                         // Bitmap
   GRAPH_ELEMENT_TYPE_FORM,                           // Form
   GRAPH_ELEMENT_TYPE_WINDOW,                         // Window
   //--- WinForms
   GRAPH_ELEMENT_TYPE_WF_UNDERLAY,                    // Panel object underlay
   GRAPH_ELEMENT_TYPE_WF_BASE,                        // Windows Forms Base
   //--- 'Container' object types are to be set below
   GRAPH_ELEMENT_TYPE_WF_CONTAINER,                   // Windows Forms container base object
   GRAPH_ELEMENT_TYPE_WF_PANEL,                       // Windows Forms Panel
   GRAPH_ELEMENT_TYPE_WF_GROUPBOX,                    // Windows Forms GroupBox
   GRAPH_ELEMENT_TYPE_WF_TAB_CONTROL,                 // Windows Forms TabControl
   GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER,             // Windows Forms SplitContainer
   //--- 'Standard control' object types are to be set below
   GRAPH_ELEMENT_TYPE_WF_COMMON_BASE,                 // Windows Forms base standard control
   GRAPH_ELEMENT_TYPE_WF_LABEL,                       // Windows Forms Label
   GRAPH_ELEMENT_TYPE_WF_BUTTON,                      // Windows Forms Button
   GRAPH_ELEMENT_TYPE_WF_CHECKBOX,                    // Windows Forms CheckBox
   GRAPH_ELEMENT_TYPE_WF_RADIOBUTTON,                 // Windows Forms RadioButton
   GRAPH_ELEMENT_TYPE_WF_ELEMENTS_LIST_BOX,           // Base list object of Windows Forms elements
   GRAPH_ELEMENT_TYPE_WF_LIST_BOX,                    // Windows Forms ListBox
   GRAPH_ELEMENT_TYPE_WF_CHECKED_LIST_BOX,            // Windows Forms CheckedListBox
   GRAPH_ELEMENT_TYPE_WF_BUTTON_LIST_BOX,             // Windows Forms ButtonListBox
   GRAPH_ELEMENT_TYPE_WF_TOOLTIP,                     // Windows Forms ToolTip
   GRAPH_ELEMENT_TYPE_WF_PROGRESS_BAR,                // Windows Forms ProgressBar
   //--- Auxiliary elements of WinForms objects
   GRAPH_ELEMENT_TYPE_WF_LIST_BOX_ITEM,               // Windows Forms ListBoxItem
   GRAPH_ELEMENT_TYPE_WF_TAB_HEADER,                  // Windows Forms TabHeader
   GRAPH_ELEMENT_TYPE_WF_TAB_FIELD,                   // Windows Forms TabField
   GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER_PANEL,       // Windows Forms SplitContainerPanel
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON,                // Windows Forms ArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_UP,             // Windows Forms UpArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_DOWN,           // Windows Forms DownArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_LEFT,           // Windows Forms LeftArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_RIGHT,          // Windows Forms RightArrowButton
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_UD_BOX,        // Windows Forms UpDownArrowButtonsBox
   GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_LR_BOX,        // Windows Forms LeftRightArrowButtonsBox
   GRAPH_ELEMENT_TYPE_WF_SPLITTER,                    // Windows Forms Splitter
   GRAPH_ELEMENT_TYPE_WF_HINT_BASE,                   // Windows Forms HintBase
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_LEFT,              // Windows Forms HintMoveLeft
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_RIGHT,             // Windows Forms HintMoveRight
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_UP,                // Windows Forms HintMoveUp
   GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_DOWN,              // Windows Forms HintMoveDown
   GRAPH_ELEMENT_TYPE_WF_BAR_PROGRESS_BAR,            // Windows Forms BarProgressBar
   GRAPH_ELEMENT_TYPE_WF_GLARE_OBJ,                   // Glare object
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_THUMB,            // Windows Forms ScrollBarThumb
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR,                  // Windows Forms ScrollBar
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_HORISONTAL,       // Windows Forms ScrollBarHorisontal
   GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_VERTICAL,         // Windows Forms ScrollBarVertical
  };
//+------------------------------------------------------------------+
//| Graphical object species                                         |
//+------------------------------------------------------------------+
enum ENUM_GRAPH_OBJ_SPECIES
  {
   GRAPH_OBJ_SPECIES_LINES,                             // Lines
   GRAPH_OBJ_SPECIES_CHANNELS,                          // Channels
   GRAPH_OBJ_SPECIES_GANN,                              // Gann
   GRAPH_OBJ_SPECIES_FIBO,                              // Fibo
   GRAPH_OBJ_SPECIES_ELLIOTT,                           // Elliott
   GRAPH_OBJ_SPECIES_SHAPES,                            // Shapes
   GRAPH_OBJ_SPECIES_ARROWS,                            // Arrows
   GRAPH_OBJ_SPECIES_GRAPHICAL,                         // Graphical objects
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
#define GRAPH_OBJ_PROP_INTEGER_SKIP  (0)              // Number of integer properties not used in sorting
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
#define GRAPH_OBJ_PROP_DOUBLE_SKIP   (0)              // Number of real properties not used in sorting
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
//+------------------------------------------------------------------+
//| Possible sorting criteria of graphical objects                   |
//+------------------------------------------------------------------+
#define FIRST_GRAPH_OBJ_DBL_PROP  (GRAPH_OBJ_PROP_INTEGER_TOTAL-GRAPH_OBJ_PROP_INTEGER_SKIP)
#define FIRST_GRAPH_OBJ_STR_PROP  (GRAPH_OBJ_PROP_INTEGER_TOTAL-GRAPH_OBJ_PROP_INTEGER_SKIP+GRAPH_OBJ_PROP_DOUBLE_TOTAL-GRAPH_OBJ_PROP_DOUBLE_SKIP)
enum ENUM_SORT_GRAPH_OBJ_MODE
 {
   //--- Sort by integer properties
    SORT_BY_GRAPH_OBJ_ID = 0,                          // Sort by object ID
    SORT_BY_GRAPH_OBJ_BASE_ID,                         // Sort by base object ID
    SORT_BY_GRAPH_OBJ_TYPE,                            // Sort by object type
    SORT_BY_GRAPH_OBJ_ELEMENT_TYPE,                    // Sort by graphical element type
    SORT_BY_GRAPH_OBJ_SPECIES,                         // Sort by a graphical object species
    SORT_BY_GRAPH_OBJ_BELONG,                          // Sort by a graphical element affiliation
    SORT_BY_GRAPH_OBJ_CHART_ID,                        // Sort by chart ID
    SORT_BY_GRAPH_OBJ_WND_NUM,                         // Sort by chart subwindow index
    SORT_BY_GRAPH_OBJ_NUM,                             // Sort by object index in the list
    SORT_BY_GRAPH_OBJ_CHANGE_HISTORY,                  // Sort by the flag of storing the change history
    SORT_BY_GRAPH_OBJ_GROUP,                           // Sort by the group of objects the graphical object belongs to
    SORT_BY_GRAPH_OBJ_CREATETIME,                      // Sort by object creation time
    SORT_BY_GRAPH_OBJ_TIMEFRAMES,                      // Sort by object visibility on timeframes
    SORT_BY_GRAPH_OBJ_BACK,                            // Sort by the "Background object" property
    SORT_BY_GRAPH_OBJ_ZORDER,                          // Sort by the priority of a graphical object for receiving the event of clicking on a chart
    SORT_BY_GRAPH_OBJ_HIDDEN,                          // Sort by a disabling display of the name of a graphical object in the terminal object list
    SORT_BY_GRAPH_OBJ_SELECTED,                        // Sort by the "Object selection" property
    SORT_BY_GRAPH_OBJ_SELECTABLE,                      // Sort by the "Object availability" property
    SORT_BY_GRAPH_OBJ_TIME,                            // Sort by time coordinate
    SORT_BY_GRAPH_OBJ_COLOR,                           // Sort by color
    SORT_BY_GRAPH_OBJ_STYLE,                           // Sort by style
    SORT_BY_GRAPH_OBJ_WIDTH,                           // Sort by line width
    SORT_BY_GRAPH_OBJ_FILL,                            // Sort by the "Object color filling" property
    SORT_BY_GRAPH_OBJ_READONLY,                        // Sort by the ability to edit text in the Edit object
    SORT_BY_GRAPH_OBJ_LEVELS,                          // Sort by number of levels
    SORT_BY_GRAPH_OBJ_LEVELCOLOR,                      // Sort by line level color
    SORT_BY_GRAPH_OBJ_LEVELSTYLE,                      // Sort by line level style
    SORT_BY_GRAPH_OBJ_LEVELWIDTH,                      // Sort by line level width
    SORT_BY_GRAPH_OBJ_ALIGN,                           // Sort by the "Horizontal text alignment in the Entry field" property
    SORT_BY_GRAPH_OBJ_FONTSIZE,                        // Sort by font size
    SORT_BY_GRAPH_OBJ_RAY_LEFT,                        // Sort by "Ray goes to the left" property
    SORT_BY_GRAPH_OBJ_RAY_RIGHT,                       // Sort by "Ray goes to the right" property
    SORT_BY_GRAPH_OBJ_RAY,                             // Sort by the "Vertical line goes through all windows of a chart" property
    SORT_BY_GRAPH_OBJ_ELLIPSE,                         // Sort by the "Display the full ellipse of the Fibonacci Arc object" property
    SORT_BY_GRAPH_OBJ_ARROWCODE,                       // Sort by an arrow code for the Arrow object
    SORT_BY_GRAPH_OBJ_ANCHOR,                          // Sort by the position of a binding point of a graphical object
    SORT_BY_GRAPH_OBJ_XDISTANCE,                       // Sort by a distance from the base corner along the X axis in pixels
    SORT_BY_GRAPH_OBJ_YDISTANCE,                       // Sort by a distance from the base corner along the Y axis in pixels
    SORT_BY_GRAPH_OBJ_DIRECTION,                       // Sort by the "Gann object trend" property
    SORT_BY_GRAPH_OBJ_DEGREE,                          // Sort by the "Elliott wave marking level" property
    SORT_BY_GRAPH_OBJ_DRAWLINES,                       // Sort by the "Display lines for Elliott wave marking" property
    SORT_BY_GRAPH_OBJ_STATE,                           // Sort by button state (pressed/released)
    SORT_BY_GRAPH_OBJ_OBJ_CHART_ID,                    // Sort by Chart object ID
    SORT_BY_GRAPH_OBJ_CHART_OBJ_PERIOD,                // Sort by Chart object period
    SORT_BY_GRAPH_OBJ_CHART_OBJ_DATE_SCALE,            // Sort by time scale display flag for the Chart object
    SORT_BY_GRAPH_OBJ_CHART_OBJ_PRICE_SCALE,           // Sort by price scale display flag for the Chart object
    SORT_BY_GRAPH_OBJ_CHART_OBJ_CHART_SCALE,           // Sort by Chart object scale
    SORT_BY_GRAPH_OBJ_XSIZE,                           // Sort by Object width along the X axis in pixels
    SORT_BY_GRAPH_OBJ_YSIZE,                           // Sort by object height along the Y axis in pixels
    SORT_BY_GRAPH_OBJ_XOFFSET,                         // Sort by X coordinate of the upper-left corner of the visibility area
    SORT_BY_GRAPH_OBJ_YOFFSET,                         // Sort by Y coordinate of the upper-left corner of the visibility area
    SORT_BY_GRAPH_OBJ_BGCOLOR,                         // Sort by background color for OBJ_EDIT, OBJ_BUTTON and OBJ_RECTANGLE_LABEL
    SORT_BY_GRAPH_OBJ_CORNER,                          // Sort by chart corner for binding a graphical object
    SORT_BY_GRAPH_OBJ_BORDER_TYPE,                     // Sort by border type for the "Rectangle border" object
    SORT_BY_GRAPH_OBJ_BORDER_COLOR,                    // Sort by frame color for the OBJ_EDIT and OBJ_BUTTON objects
   //--- Sort by real properties
    SORT_BY_GRAPH_OBJ_PRICE = FIRST_GRAPH_OBJ_DBL_PROP,// Sort by price coordinate
    SORT_BY_GRAPH_OBJ_LEVELVALUE,                      // Sort by level value
    SORT_BY_GRAPH_OBJ_SCALE,                           // Sort by scale (property of Gann objects and Fibonacci Arcs objects)
    SORT_BY_GRAPH_OBJ_ANGLE,                           // Sort by angle
    SORT_BY_GRAPH_OBJ_DEVIATION,                       // Sort by a deviation of the standard deviation channel
   //--- Sort by string properties
    SORT_BY_GRAPH_OBJ_NAME = FIRST_GRAPH_OBJ_STR_PROP, // Sort by object name
    SORT_BY_GRAPH_OBJ_BASE_NAME,                       // Sort by base object name
    SORT_BY_GRAPH_OBJ_TEXT,                            // Sort by object description
    SORT_BY_GRAPH_OBJ_TOOLTIP,                         // Sort by tooltip text
    SORT_BY_GRAPH_OBJ_LEVELTEXT,                       // Sort by level description
    SORT_BY_GRAPH_OBJ_FONT,                            // Sort by font
    SORT_BY_GRAPH_OBJ_BMPFILE,                         // Sort by BMP file name for the "Bitmap Level" object
    SORT_BY_GRAPH_OBJ_CHART_OBJ_SYMBOL,                // Sort by Chart object period symbol 
 };
//+------------------------------------------------------------------+
//| Mode of automatic interface element resizing                     |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_AUTO_SIZE_MODE
 {
   CANV_ELEMENT_AUTO_SIZE_MODE_GROW,                  // Increase only
   CANV_ELEMENT_AUTO_SIZE_MODE_GROW_SHRINK,           // Increase and decrease
 };
//+------------------------------------------------------------------+
//| Control borders bound to the container                           |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_DOCK_MODE
 {
   CANV_ELEMENT_DOCK_MODE_NONE,                       // Attached to the specified coordinates, size does not change
   CANV_ELEMENT_DOCK_MODE_TOP,                        // Attaching to the top and stretching along the container width
   CANV_ELEMENT_DOCK_MODE_BOTTOM,                     // Attaching to the bottom and stretching along the container width
   CANV_ELEMENT_DOCK_MODE_LEFT,                       // Attaching to the left and stretching along the container height
   CANV_ELEMENT_DOCK_MODE_RIGHT,                      // Attaching to the right and stretching along the container height
   CANV_ELEMENT_DOCK_MODE_FILL,                       // Stretching along the entire container width and height
 };
//+------------------------------------------------------------------+
//| Control flag status                                              |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_CHEK_STATE
 {
   CANV_ELEMENT_CHEK_STATE_UNCHECKED,                 // Unchecked
   CANV_ELEMENT_CHEK_STATE_CHECKED,                   // Checked
   CANV_ELEMENT_CHEK_STATE_INDETERMINATE,             // Undefined
 };
//+------------------------------------------------------------------+
//| Location of an object inside a control                           |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_ALIGNMENT
 {
   CANV_ELEMENT_ALIGNMENT_TOP,                        // Top
   CANV_ELEMENT_ALIGNMENT_BOTTOM,                     // Bottom
   CANV_ELEMENT_ALIGNMENT_LEFT,                       // Left
   CANV_ELEMENT_ALIGNMENT_RIGHT,                      // Right
 };
//+------------------------------------------------------------------+
//| Tab size setting mode                                            |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_TAB_SIZE_MODE
 {
   CANV_ELEMENT_TAB_SIZE_MODE_NORMAL,                 // By tab header width
   CANV_ELEMENT_TAB_SIZE_MODE_FIXED,                  // Fixed size
   CANV_ELEMENT_TAB_SIZE_MODE_FILL,                   // By TabControl width
 };
//+------------------------------------------------------------------+
//| Panel index in Split Container,                                  |
//| which saves the size when the container size is changed          |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL
 {
   CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL_NONE,     // None
   CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL_1,        // Panel1
   CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL_2,        // Panel2
 };
//+------------------------------------------------------------------+
//| Separator location in Split Container                            |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_SPLITTER_ORIENTATION
 {
   CANV_ELEMENT_SPLITTER_ORIENTATION_VERTICAL,        // Vertical
   CANV_ELEMENT_SPLITTER_ORIENTATION_HORISONTAL,      // Horizontal
 };
//+------------------------------------------------------------------+
//| The list of predefined icons                                     |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_TOOLTIP_ICON
 {
   CANV_ELEMENT_TOOLTIP_ICON_NONE,                    // None
   CANV_ELEMENT_TOOLTIP_ICON_INFO,                    // Info
   CANV_ELEMENT_TOOLTIP_ICON_WARNING,                 // Warning
   CANV_ELEMENT_TOOLTIP_ICON_ERROR,                   // Error
   CANV_ELEMENT_TOOLTIP_ICON_USER,                    // User
 };
//+------------------------------------------------------------------+
//| List of control display states                                   |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_DISPLAY_STATE
 {
   CANV_ELEMENT_DISPLAY_STATE_NORMAL,                 // Normal
   CANV_ELEMENT_DISPLAY_STATE_WAITING_FADE_IN,        // Wait for fading in
   CANV_ELEMENT_DISPLAY_STATE_PROCESS_FADE_IN,        // Fading in
   CANV_ELEMENT_DISPLAY_STATE_COMPLETED_FADE_IN,      // Fading in end
   CANV_ELEMENT_DISPLAY_STATE_WAITING_FADE_OUT,       // Wait for fading out
   CANV_ELEMENT_DISPLAY_STATE_PROCESS_FADE_OUT,       // Fading out
   CANV_ELEMENT_DISPLAY_STATE_COMPLETED_FADE_OUT,     // Fading out end
   CANV_ELEMENT_DISPLAY_STATE_COMPLETED,              // Complete processing
 };
//+------------------------------------------------------------------+
//| List of ProgressBar element styles                               |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROGRESS_BAR_STYLE
 {
   CANV_ELEMENT_PROGRESS_BAR_STYLE_BLOCKS,            // Segmented blocks
   CANV_ELEMENT_PROGRESS_BAR_STYLE_CONTINUOUS,        // Continuous bar
   CANV_ELEMENT_PROGRESS_BAR_STYLE_MARQUEE,           // Continuous scrolling
 };
//+------------------------------------------------------------------+
//| List of visual effect styles                                     |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_VISUAL_EFF_STYLE
 {
   CANV_ELEMENT_VISUAL_EFF_STYLE_RECTANGLE,           // Rectangle
   CANV_ELEMENT_VISUAL_EFF_STYLE_PARALLELOGRAMM,      // Parallelogram
 };
//+------------------------------------------------------------------+
//| Integer properties of the graphical element on the canvas        |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROP_INTEGER
 {
   CANV_ELEMENT_PROP_ID = 0,                          // Element ID
   CANV_ELEMENT_PROP_TYPE,                            // Graphical element type
   CANV_ELEMENT_PROP_BELONG,                          // Graphical element affiliation
   CANV_ELEMENT_PROP_NUM,                             // Element index in the list
   CANV_ELEMENT_PROP_CHART_ID,                        // Chart ID
   CANV_ELEMENT_PROP_WND_NUM,                         // Chart subwindow index
   CANV_ELEMENT_PROP_COORD_X,                         // Element X coordinate on the chart
   CANV_ELEMENT_PROP_COORD_Y,                         // Element Y coordinate on the chart
   CANV_ELEMENT_PROP_WIDTH,                           // Element width
   CANV_ELEMENT_PROP_HEIGHT,                          // Element height
   CANV_ELEMENT_PROP_RIGHT,                           // Element right border
   CANV_ELEMENT_PROP_BOTTOM,                          // Element bottom border
   CANV_ELEMENT_PROP_ACT_SHIFT_LEFT,                  // Active area offset from the left edge of the element
   CANV_ELEMENT_PROP_ACT_SHIFT_TOP,                   // Active area offset from the upper edge of the element
   CANV_ELEMENT_PROP_ACT_SHIFT_RIGHT,                 // Active area offset from the right edge of the element
   CANV_ELEMENT_PROP_ACT_SHIFT_BOTTOM,                // Active area offset from the bottom edge of the element
   CANV_ELEMENT_PROP_MOVABLE,                         // Element moveability flag
   CANV_ELEMENT_PROP_ACTIVE,                          // Element activity flag
   CANV_ELEMENT_PROP_INTERACTION,                     // Flag of interaction with the outside environment
   CANV_ELEMENT_PROP_COORD_ACT_X,                     // X coordinate of the element active area
   CANV_ELEMENT_PROP_COORD_ACT_Y,                     // Y coordinate of the element active area
   CANV_ELEMENT_PROP_ACT_RIGHT,                       // Right border of the element active area
   CANV_ELEMENT_PROP_ACT_BOTTOM,                      // Bottom border of the element active area
   CANV_ELEMENT_PROP_VISIBLE_AREA_X,                  // Visibility scope X coordinate
   CANV_ELEMENT_PROP_VISIBLE_AREA_Y,                  // Visibility scope Y coordinate
   CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH,              // Visibility scope width
   CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT,             // Visibility scope height
   CANV_ELEMENT_PROP_CONTROL_AREA_X,                  // Control area X coordinate
   CANV_ELEMENT_PROP_CONTROL_AREA_Y,                  // Control area Y coordinate
   CANV_ELEMENT_PROP_CONTROL_AREA_WIDTH,              // Control area width
   CANV_ELEMENT_PROP_CONTROL_AREA_HEIGHT,             // Control area height
   CANV_ELEMENT_PROP_SCROLL_AREA_X_RIGHT,             // Right scroll area X coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_Y_RIGHT,             // Right scroll area Y coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_RIGHT,         // Right scroll area width
   CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_RIGHT,        // Right scroll area height
   CANV_ELEMENT_PROP_SCROLL_AREA_X_BOTTOM,            // Bottom scroll area X coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_Y_BOTTOM,            // Bottom scroll area Y coordinate
   CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_BOTTOM,        // Bottom scroll area width
   CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_BOTTOM,       // Bottom scroll area height
   CANV_ELEMENT_PROP_BORDER_LEFT_AREA_WIDTH,          // Left edge area width
   CANV_ELEMENT_PROP_BORDER_BOTTOM_AREA_WIDTH,        // Bottom edge area width
   CANV_ELEMENT_PROP_BORDER_RIGHT_AREA_WIDTH,         // Right edge area width
   CANV_ELEMENT_PROP_BORDER_TOP_AREA_WIDTH,           // Upper edge area width
   CANV_ELEMENT_PROP_DISPLAYED,                       // Non-hidden control display flag
   CANV_ELEMENT_PROP_DISPLAY_STATE,                   // Control display state
   CANV_ELEMENT_PROP_DISPLAY_DURATION,                // Control display duration
   CANV_ELEMENT_PROP_GROUP,                           // Group the graphical element belongs to
   CANV_ELEMENT_PROP_ZORDER,                          // Priority of a graphical object for receiving the event of clicking on a chart
   CANV_ELEMENT_PROP_ENABLED,                         // Element availability flag
   CANV_ELEMENT_PROP_RESIZABLE,                       // Resizable element flag
   CANV_ELEMENT_PROP_FORE_COLOR,                      // Default text color for all control objects
   CANV_ELEMENT_PROP_FORE_COLOR_OPACITY,              // Default text color opacity for all control objects
   CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_DOWN,           // Default control text color when clicking on the control
   CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_OVER,           // Default control text color when hovering the mouse over the control
   CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON,             // Text color of the control which is on
   CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_DOWN,  // Default control text color when clicking on the control which is on
   CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_OVER,  // Default control text color when hovering the mouse over the control which is on
   CANV_ELEMENT_PROP_BACKGROUND_COLOR,                // Control background color
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_OPACITY,        // Opacity of control background color
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN,     // Control background color when clicking on the control
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER,     // Control background color when hovering the mouse over the control
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON,       // Background color of the control which is on
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_DOWN,// Control background color when clicking on the control which is on
   CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_OVER,// Control background color when hovering the mouse over control which is on
   CANV_ELEMENT_PROP_BOLD_TYPE,                       // Font width type
   CANV_ELEMENT_PROP_BORDER_STYLE,                    // Control frame style
   CANV_ELEMENT_PROP_BORDER_SIZE_TOP,                 // Control frame top size
   CANV_ELEMENT_PROP_BORDER_SIZE_BOTTOM,              // Control frame bottom size
   CANV_ELEMENT_PROP_BORDER_SIZE_LEFT,                // Control frame left size
   CANV_ELEMENT_PROP_BORDER_SIZE_RIGHT,               // Control frame right size
   CANV_ELEMENT_PROP_BORDER_COLOR,                    // Control frame color
   CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_DOWN,         // Control frame color when clicking on the control
   CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_OVER,         // Control frame color when hovering the mouse over the control
   CANV_ELEMENT_PROP_AUTOSIZE,                        // Flag of the element auto resizing depending on the content
   CANV_ELEMENT_PROP_AUTOSIZE_MODE,                   // Mode of the element auto resizing depending on the content
   CANV_ELEMENT_PROP_AUTOSCROLL,                      // Auto scrollbar flag
   CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_W,             // Width of the field inside the element during auto scrolling
   CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_H,             // Height of the field inside the element during auto scrolling
   CANV_ELEMENT_PROP_DOCK_MODE,                       // Mode of binding control borders to the container
   CANV_ELEMENT_PROP_MARGIN_TOP,                      // Top margin between the fields of this and another control
   CANV_ELEMENT_PROP_MARGIN_BOTTOM,                   // Bottom margin between the fields of this and another control
   CANV_ELEMENT_PROP_MARGIN_LEFT,                     // Left margin between the fields of this and another control
   CANV_ELEMENT_PROP_MARGIN_RIGHT,                    // Right margin between the fields of this and another control
   CANV_ELEMENT_PROP_PADDING_TOP,                     // Top margin inside the control
   CANV_ELEMENT_PROP_PADDING_BOTTOM,                  // Bottom margin inside the control
   CANV_ELEMENT_PROP_PADDING_LEFT,                    // Left margin inside the control
   CANV_ELEMENT_PROP_PADDING_RIGHT,                   // Right margin inside the control
   CANV_ELEMENT_PROP_TEXT_ALIGN,                      // Text position within text label boundaries
   CANV_ELEMENT_PROP_CHECK_ALIGN,                     // Position of the checkbox within control borders
   CANV_ELEMENT_PROP_CHECKED,                         // Control checkbox status
   CANV_ELEMENT_PROP_CHECK_STATE,                     // Status of a control having a checkbox
   CANV_ELEMENT_PROP_AUTOCHECK,                       // Auto change flag status when it is selected
   CANV_ELEMENT_PROP_BUTTON_TOGGLE,                   // Toggle flag of the control featuring a button
   CANV_ELEMENT_PROP_BUTTON_GROUP,                    // Button group flag
   CANV_ELEMENT_PROP_BUTTON_STATE,                    // Status of the Toggle control featuring a button
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR,          // Color of control checkbox background
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_OPACITY,  // Opacity of the control checkbox background color
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_DOWN,// Color of control checkbox background when clicking on the control
   CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_OVER,// Color of control checkbox background when hovering the mouse over the control
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR,                // Color of control checkbox frame
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR_OPACITY,        // Opacity of the control checkbox frame color
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_DOWN,     // Color of control checkbox frame when clicking on the control
   CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_OVER,     // Color of control checkbox frame when hovering the mouse over the control
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR,                // Color of control checkbox
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_OPACITY,        // Opacity of the control checkbox color
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_DOWN,     // Color of control checkbox when clicking on the control
   CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_OVER,     // Color of control checkbox when hovering the mouse over the control
   CANV_ELEMENT_PROP_LIST_BOX_MULTI_COLUMN,           // Horizontal display of columns in the ListBox control
   CANV_ELEMENT_PROP_LIST_BOX_COLUMN_WIDTH,           // Width of each ListBox control column
   CANV_ELEMENT_PROP_TAB_MULTILINE,                   // Several lines of tabs in TabControl
   CANV_ELEMENT_PROP_TAB_ALIGNMENT,                   // Location of tabs inside the control
   CANV_ELEMENT_PROP_TAB_SIZE_MODE,                   // Tab size setting mode
   CANV_ELEMENT_PROP_TAB_PAGE_NUMBER,                 // Tab index number
   CANV_ELEMENT_PROP_TAB_PAGE_ROW,                    // Tab row index
   CANV_ELEMENT_PROP_TAB_PAGE_COLUMN,                 // Tab column index
   CANV_ELEMENT_PROP_ALIGNMENT,                       // Location of an object inside the control
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_FIXED_PANEL,     // Panel that retains its size when the container is resized
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_FIXED,  // Separator moveability flag
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_DISTANCE,// Distance from edge to separator
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_WIDTH,  // Separator width
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_ORIENTATION,// Separator location
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_COLLAPSED,// Flag for collapsed panel 1
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_MIN_SIZE, // Panel 1 minimum size
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_COLLAPSED,// Flag for collapsed panel 1
   CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_MIN_SIZE, // Panel 2 minimum size
   CANV_ELEMENT_PROP_TOOLTIP_INITIAL_DELAY,           // Tooltip display delay
   CANV_ELEMENT_PROP_TOOLTIP_AUTO_POP_DELAY,          // Tooltip display duration
   CANV_ELEMENT_PROP_TOOLTIP_RESHOW_DELAY,            // One element new tooltip display delay
   CANV_ELEMENT_PROP_TOOLTIP_SHOW_ALWAYS,             // Display a tooltip in inactive window
   CANV_ELEMENT_PROP_TOOLTIP_ICON,                    // Icon displayed in tooltip
   CANV_ELEMENT_PROP_TOOLTIP_IS_BALLOON,              // Tooltip in the form of a "cloud"
   CANV_ELEMENT_PROP_TOOLTIP_USE_FADING,              // Fade when showing/hiding a tooltip
   CANV_ELEMENT_PROP_PROGRESS_BAR_MAXIMUM,            // The upper bound of the range ProgressBar operates in
   CANV_ELEMENT_PROP_PROGRESS_BAR_MINIMUM,            // The lower bound of the range ProgressBar operates in
   CANV_ELEMENT_PROP_PROGRESS_BAR_STEP,               // ProgressBar increment needed to redraw it
   CANV_ELEMENT_PROP_PROGRESS_BAR_STYLE,              // ProgressBar style
   CANV_ELEMENT_PROP_PROGRESS_BAR_VALUE,              // Current ProgressBar value from Min to Max
   CANV_ELEMENT_PROP_PROGRESS_BAR_MARQUEE_ANIM_SPEED, // Progress bar animation speed in case of Marquee style
   CANV_ELEMENT_PROP_BUTTON_ARROW_SIZE,               // Size of the arrow drawn on the button
 };
#define CANV_ELEMENT_PROP_INTEGER_TOTAL (140)         // Total number of integer properties
#define CANV_ELEMENT_PROP_INTEGER_SKIP  (0)           // Number of integer properties not used in sorting
//+------------------------------------------------------------------+
//| Real properties of the graphical element on the canvas           |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROP_DOUBLE
 {
   CANV_ELEMENT_PROP_DUMMY = CANV_ELEMENT_PROP_INTEGER_TOTAL, // DBL stub
 };
#define CANV_ELEMENT_PROP_DOUBLE_TOTAL  (1)           // Total number of real properties
#define CANV_ELEMENT_PROP_DOUBLE_SKIP   (1)           // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| String properties of the graphical element on the canvas         |
//+------------------------------------------------------------------+
enum ENUM_CANV_ELEMENT_PROP_STRING
 {
   CANV_ELEMENT_PROP_NAME_OBJ = (CANV_ELEMENT_PROP_INTEGER_TOTAL+CANV_ELEMENT_PROP_DOUBLE_TOTAL), // Graphical element object name
   CANV_ELEMENT_PROP_NAME_RES,                        // Graphical resource name
   CANV_ELEMENT_PROP_TEXT,                            // Graphical element text
   CANV_ELEMENT_PROP_DESCRIPTION,                     // Graphical element description
   CANV_ELEMENT_PROP_TOOLTIP_TITLE,                   // Element tooltip title
   CANV_ELEMENT_PROP_TOOLTIP_TEXT,                    // Element tooltip text
 };
#define CANV_ELEMENT_PROP_STRING_TOTAL  (6)           // Total number of string properties
//+------------------------------------------------------------------+
//| Possible sorting criteria of graphical elements on the canvas    |
//+------------------------------------------------------------------+
#define FIRST_CANV_ELEMENT_DBL_PROP  (CANV_ELEMENT_PROP_INTEGER_TOTAL-CANV_ELEMENT_PROP_INTEGER_SKIP)
#define FIRST_CANV_ELEMENT_STR_PROP  (CANV_ELEMENT_PROP_INTEGER_TOTAL-CANV_ELEMENT_PROP_INTEGER_SKIP+CANV_ELEMENT_PROP_DOUBLE_TOTAL-CANV_ELEMENT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_CANV_ELEMENT_MODE
 {
  //--- Sort by integer properties
   SORT_BY_CANV_ELEMENT_ID = 0,                       // Sort by element ID
   SORT_BY_CANV_ELEMENT_TYPE,                         // Sort by graphical element type
   SORT_BY_CANV_ELEMENT_BELONG,                       // Sort by a graphical element affiliation
   SORT_BY_CANV_ELEMENT_NUM,                          // Sort by form index in the list
   SORT_BY_CANV_ELEMENT_CHART_ID,                     // Sort by chart ID
   SORT_BY_CANV_ELEMENT_WND_NUM,                      // Sort by chart window index
   SORT_BY_CANV_ELEMENT_COORD_X,                      // Sort by the element X coordinate on the chart
   SORT_BY_CANV_ELEMENT_COORD_Y,                      // Sort by the element Y coordinate on the chart
   SORT_BY_CANV_ELEMENT_WIDTH,                        // Sort by the element width
   SORT_BY_CANV_ELEMENT_HEIGHT,                       // Sort by the element height
   SORT_BY_CANV_ELEMENT_RIGHT,                        // Sort by the element right border
   SORT_BY_CANV_ELEMENT_BOTTOM,                       // Sort by the element bottom border
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_LEFT,               // Sort by the active area offset from the left edge of the element
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_TOP,                // Sort by the active area offset from the top edge of the element
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_RIGHT,              // Sort by the active area offset from the right edge of the element
   SORT_BY_CANV_ELEMENT_ACT_SHIFT_BOTTOM,             // Sort by the active area offset from the bottom edge of the element
   SORT_BY_CANV_ELEMENT_MOVABLE,                      // Sort by the element moveability flag
   SORT_BY_CANV_ELEMENT_ACTIVE,                       // Sort by the element activity flag
   SORT_BY_CANV_ELEMENT_INTERACTION,                  // Sort by the flag of interaction with the outside environment
   SORT_BY_CANV_ELEMENT_COORD_ACT_X,                  // Sort by X coordinate of the element active area
   SORT_BY_CANV_ELEMENT_COORD_ACT_Y,                  // Sort by Y coordinate of the element active area
   SORT_BY_CANV_ELEMENT_ACT_RIGHT,                    // Sort by the right border of the element active area
   SORT_BY_CANV_ELEMENT_ACT_BOTTOM,                   // Sort by the bottom border of the element active area
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_X,               // Sort by visibility scope X coordinate
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_Y,               // Sort by visibility scope Y coordinate
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_WIDTH,           // Sort by visibility scope width
   SORT_BY_CANV_ELEMENT_VISIBLE_AREA_HEIGHT,          // Sort by visibility scope height
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_X,               // Sort by control area X coordinate
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_Y,               // Sort by control area Y coordinate
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_WIDTH,           // Sort by control area width
   SORT_BY_CANV_ELEMENT_CONTROL_AREA_HEIGHT,          // Sort by control area height
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_X_RIGHT,          // Sort by right scroll area X coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_Y_RIGHT,          // Sort by right scroll area Y coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_WIDTH_RIGHT,      // Sort by right scroll area width
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_HEIGHT_RIGHT,     // Sort by right scroll area height
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_X_BOTTOM,         // Sort by bottom scroll area X coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_Y_BOTTOM,         // Sort by bottom scroll area Y coordinate
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_WIDTH_BOTTOM,     // Sort by bottom scroll area width
   SORT_BY_CANV_ELEMENT_SCROLL_AREA_HEIGHT_BOTTOM,    // Sort by bottom scroll area height
   SORT_BY_CANV_ELEMENT_BORDER_LEFT_AREA_WIDTH,       // Sort by left edge area width
   SORT_BY_CANV_ELEMENT_BORDER_BOTTOM_AREA_WIDTH,     // Sort by bottom edge area width
   SORT_BY_CANV_ELEMENT_BORDER_RIGHT_AREA_WIDTH,      // Sort by right edge area width
   SORT_BY_CANV_ELEMENT_BORDER_TOP_AREA_WIDTH,        // Sort by upper edge area width
   SORT_BY_CANV_ELEMENT_DISPLAYED,                    // Sort by non-hidden control display flag
   SORT_BY_CANV_ELEMENT_DISPLAY_STATE,                // Sort by control display state
   SORT_BY_CANV_ELEMENT_DISPLAY_DURATION,             // Sort by control display duration
   SORT_BY_CANV_ELEMENT_GROUP,                        // Sort by a group the graphical element belongs to
   SORT_BY_CANV_ELEMENT_ZORDER,                       // Sort by the priority of a graphical object for receiving the event of clicking on a chart
   SORT_BY_CANV_ELEMENT_ENABLED,                      // Sort by the element availability flag
   SORT_BY_CANV_ELEMENT_RESIZABLE,                    // Sort by resizable element flag
   SORT_BY_CANV_ELEMENT_FORE_COLOR,                   // Sort by default text color for all control objects
   SORT_BY_CANV_ELEMENT_FORE_COLOR_OPACITY,           // Sort by default text color opacity for all control objects
   SORT_BY_CANV_ELEMENT_FORE_COLOR_MOUSE_DOWN,        // Sort by control text color when clicking on the control
   SORT_BY_CANV_ELEMENT_FORE_COLOR_MOUSE_OVER,        // Sort by control text color when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_FORE_COLOR_STATE_ON,          // Sort by control text color when the control is on
   SORT_BY_CANV_ELEMENT_FORE_COLOR_STATE_ON_MOUSE_DOWN,// Sort by the default control text color when clicking on the control while it is on
   SORT_BY_CANV_ELEMENT_FORE_COLOR_STATE_ON_MOUSE_OVER,// Sort by the default control text color when hovering the mouse over the control while it is on
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR,             // Sort by control background text color
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_OPACITY,     // Sort by control background color opacity
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_MOUSE_DOWN,  // Sort by control background text color when clicking on the control
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_MOUSE_OVER,  // Sort by control background text color when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_STATE_ON,    // Sort by control background color when the control is on
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_STATE_ON_MOUSE_DOWN,// Sort by control background color when clicking on the control while it is on
   SORT_BY_CANV_ELEMENT_BACKGROUND_COLOR_STATE_ON_MOUSE_OVER,// Sort by control background color when hovering the mouse over the control while it is on
   SORT_BY_CANV_ELEMENT_BOLD_TYPE,                    // Sort by font width type
   SORT_BY_CANV_ELEMENT_BORDER_STYLE,                 // Sort by control frame style
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_TOP,              // Sort by control frame top size
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_BOTTOM,           // Sort by control frame bottom size
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_LEFT,             // Sort by control frame left size
   SORT_BY_CANV_ELEMENT_BORDER_SIZE_RIGHT,            // Sort by control frame right size
   SORT_BY_CANV_ELEMENT_BORDER_COLOR,                 // Sort by control frame color
   SORT_BY_CANV_ELEMENT_BORDER_COLOR_MOUSE_DOWN,      // Sort by control frame color when clicking on the control
   SORT_BY_CANV_ELEMENT_BORDER_COLOR_MOUSE_OVER,      // Sort by control frame color when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_AUTOSIZE,                     // Sort by the flag of the element auto resizing depending on the content
   SORT_BY_CANV_ELEMENT_AUTOSIZE_MODE,                // Sort by the mode of the control auto resizing depending on the content
   SORT_BY_CANV_ELEMENT_AUTOSCROLL,                   // Sort by auto scrollbar flag
   SORT_BY_CANV_ELEMENT_AUTOSCROLL_MARGIN_W,          // Sort by width of the field inside the element during auto scrolling
   SORT_BY_CANV_ELEMENT_AUTOSCROLL_MARGIN_H, // Sort by height of the field inside the element during auto scrolling
   SORT_BY_CANV_ELEMENT_DOCK_MODE,                    // Sort by mode of binding control borders to the container
   SORT_BY_CANV_ELEMENT_MARGIN_TOP,                   // Sort by top margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_MARGIN_BOTTOM,                // Sort by bottom margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_MARGIN_LEFT,                  // Sort by left margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_MARGIN_RIGHT,                 // Sort by right margin between the fields of this and another control
   SORT_BY_CANV_ELEMENT_PADDING_TOP,                  // Sort by top margin inside the control
   SORT_BY_CANV_ELEMENT_PADDING_BOTTOM,               // Sort by bottom margin inside the control
   SORT_BY_CANV_ELEMENT_PADDING_LEFT,                 // Sort by left margin inside the control
   SORT_BY_CANV_ELEMENT_PADDING_RIGHT,                // Sort by right margin inside the control
   SORT_BY_CANV_ELEMENT_TEXT_ALIGN,                   // Sort by text position within text label boundaries
   SORT_BY_CANV_ELEMENT_CHECK_ALIGN,                  // Sort by position of the checkbox within control borders
   SORT_BY_CANV_ELEMENT_CHECKED,                      // Sort by control checkbox status
   SORT_BY_CANV_ELEMENT_CHECK_STATE,                  // Sort by status of a control having a checkbox
   SORT_BY_CANV_ELEMENT_AUTOCHECK,                    // Sort by auto change flag status when it is selected
   SORT_BY_CANV_ELEMENT_BUTTON_TOGGLE,                // Sort by the Toggle flag of the control featuring a button
   SORT_BY_CANV_ELEMENT_BUTTON_GROUP,                 // Sort by button group flag
   SORT_BY_CANV_ELEMENT_BUTTON_STATE,                 // Sort by the status of the Toggle control featuring a button
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR,       // Sort by color of control checkbox background
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR_OPACITY,   // Sort by opacity of control checkbox background color
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR_MOUSE_DOWN,// Sort by color of control checkbox background when clicking on the control
   SORT_BY_CANV_ELEMENT_CHECK_BACKGROUND_COLOR_MOUSE_OVER,// Sort by color of control checkbox background when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR,             // Sort by color of control checkbox frame
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR_OPACITY,     // Sort by opacity of control checkbox frame color
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR_MOUSE_DOWN,  // Sort by color of control checkbox frame when clicking on the control
   SORT_BY_CANV_ELEMENT_CHECK_FORE_COLOR_MOUSE_OVER,  // Sort by color of control checkbox frame when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR,             // Sort by color of control checkbox
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR_OPACITY,     // Sort by opacity of control checkbox color
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR_MOUSE_DOWN,  // Sort by color of control checkbox when clicking on the control
   SORT_BY_CANV_ELEMENT_CHECK_FLAG_COLOR_MOUSE_OVER,  // Sort by color of control checkbox when hovering the mouse over the control
   SORT_BY_CANV_ELEMENT_LIST_BOX_MULTI_COLUMN,        // Sort by horizontal column display flag in the ListBox control
   SORT_BY_CANV_ELEMENT_LIST_BOX_COLUMN_WIDTH,        // Sort by the width of each ListBox control column
   SORT_BY_CANV_ELEMENT_TAB_MULTILINE,                // Sort by the flag of several rows of tabs in TabControl
   SORT_BY_CANV_ELEMENT_TAB_ALIGNMENT,                // Sort by the location of tabs inside the control
   SORT_BY_CANV_ELEMENT_TAB_SIZE_MODE,                // Sort by the mode of setting the tab size
   SORT_BY_CANV_ELEMENT_TAB_PAGE_NUMBER,              // Sort by the tab index number
   SORT_BY_CANV_ELEMENT_TAB_PAGE_ROW,                 // Sort by tab row index
   SORT_BY_CANV_ELEMENT_TAB_PAGE_COLUMN,              // Sort by tab column index
   SORT_BY_CANV_ELEMENT_ALIGNMENT,                    // Sort by the location of the object inside the control
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_FIXED_PANEL,     // Sort by the panel that retains its size when the container is resized
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_FIXED,  // Sort by the separator moveability flag
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_DISTANCE,// Sort by distance from edge to separator
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_WIDTH,  // Sort by separator width
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_SPLITTER_ORIENTATION,// Sort by separator location
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL1_COLLAPSED,// Sort by flag for collapsed panel 1
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL1_MIN_SIZE, // Sort by panel 1 minimum size
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL2_COLLAPSED,// Sort by flag for collapsed panel 1
   SORT_BY_CANV_ELEMENT_SPLIT_CONTAINER_PANEL2_MIN_SIZE, // Sort by panel 2 minimum size
   SORT_BY_CANV_ELEMENT_TOOLTIP_INITIAL_DELAY,        // Sort by tooltip display delay
   SORT_BY_CANV_ELEMENT_TOOLTIP_AUTO_POP_DELAY,       // Sort by tooltip display duration
   SORT_BY_CANV_ELEMENT_TOOLTIP_RESHOW_DELAY,         // Sort by one element new tooltip display delay
   SORT_BY_CANV_ELEMENT_TOOLTIP_SHOW_ALWAYS,          // Sort by a tooltip in inactive window
   SORT_BY_CANV_ELEMENT_TOOLTIP_ICON,                 // Sort by icon displayed in a tooltip
   SORT_BY_CANV_ELEMENT_TOOLTIP_IS_BALLOON,           // Sort by a cloud tooltip flag
   SORT_BY_CANV_ELEMENT_TOOLTIP_USE_FADING,           // Sort by the flag of fading when showing/hiding a tooltip
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_MAXIMUM,         // Sort by the upper bound of the range ProgressBar operates in
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_MINIMUM,         // Sort by the lower bound of the range ProgressBar operates in
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_STEP,            // Sort by ProgressBar increment needed to redraw it
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_STYLE,           // Sort by ProgressBar style
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_VALUE,           // Sort by the current ProgressBar value from Min to Max
   SORT_BY_CANV_ELEMENT_PROGRESS_BAR_MARQUEE_ANIM_SPEED, // Sort by progress bar animation speed in case of Marquee style
   SORT_BY_CANV_ELEMENT_BUTTON_ARROW_SIZE,            // Sort by the size of the arrow drawn on the button
  //--- Sort by real properties

  //--- Sort by string properties
   SORT_BY_CANV_ELEMENT_NAME_OBJ = FIRST_CANV_ELEMENT_STR_PROP,// Sort by an element object name
   SORT_BY_CANV_ELEMENT_NAME_RES,                     // Sort by the graphical resource name
   SORT_BY_CANV_ELEMENT_TEXT,                         // Sort by graphical element text
   SORT_BY_CANV_ELEMENT_DESCRIPTION,                  // Sort by graphical element description
   SORT_BY_CANV_ELEMENT_TOOLTIP_HEADER,               // Sort by Tooltip header for an element
   SORT_BY_CANV_ELEMENT_TOOLTIP_TEXT,                 // Sort by Tooltip text for an element
 };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with graphical element animation                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of animation frame types                                    |
//+------------------------------------------------------------------+
enum ENUM_ANIMATION_FRAME_TYPE
  {
   ANIMATION_FRAME_TYPE_TEXT,                         // Text animation frame
   ANIMATION_FRAME_TYPE_QUAD,                         // Rectangular animation frame
   ANIMATION_FRAME_TYPE_GEOMETRY,                     // Square animation frame of geometric shapes
  };
//+------------------------------------------------------------------+
//| List of drawn shape types                                        |
//+------------------------------------------------------------------+
enum ENUM_FIGURE_TYPE
  {
   FIGURE_TYPE_PIXEL,                                 // Pixel
   FIGURE_TYPE_PIXEL_AA,                              // Pixel with antialiasing
   
   FIGURE_TYPE_LINE_VERTICAL,                         // Vertical line
   FIGURE_TYPE_LINE_VERTICAL_THICK,                   // Vertical segment of a freehand line having a specified width using antialiasing algorithm
   
   FIGURE_TYPE_LINE_HORIZONTAL,                       // Horizontal line
   FIGURE_TYPE_LINE_HORIZONTAL_THICK,                 // Horizontal segment of a freehand line having a specified width using antialiasing algorithm
   
   FIGURE_TYPE_LINE,                                  // Arbitrary line
   FIGURE_TYPE_LINE_AA,                               // Line with antialiasing
   FIGURE_TYPE_LINE_WU,                               // Line with WU smoothing
   FIGURE_TYPE_LINE_THICK,                            // Segment of a freehand line having a specified width using antialiasing algorithm
   
   FIGURE_TYPE_POLYLINE,                              // Polyline
   FIGURE_TYPE_POLYLINE_AA,                           // Polyline with antialiasing
   FIGURE_TYPE_POLYLINE_WU,                           // Polyline with WU smoothing
   FIGURE_TYPE_POLYLINE_SMOOTH,                       // Polyline with a specified width using two smoothing algorithms
   FIGURE_TYPE_POLYLINE_THICK,                        // Polyline with a specified width using a smoothing algorithm    
   
   FIGURE_TYPE_POLYGON,                               // Polygon
   FIGURE_TYPE_POLYGON_FILL,                          // Filled polygon
   FIGURE_TYPE_POLYGON_AA,                            // Polygon with antialiasing
   FIGURE_TYPE_POLYGON_WU,                            // Polygon with WU smoothing
   FIGURE_TYPE_POLYGON_SMOOTH,                        // Polygon with a specified width using two smoothing algorithms
   FIGURE_TYPE_POLYGON_THICK,                         // Polygon with a specified width using a smoothing algorithm
   
   FIGURE_TYPE_RECTANGLE,                             // Rectangle
   FIGURE_TYPE_RECTANGLE_FILL,                        // Filled rectangle
   
   FIGURE_TYPE_CIRCLE,                                // Circle
   FIGURE_TYPE_CIRCLE_FILL,                           // Filled circle
   FIGURE_TYPE_CIRCLE_AA,                             // Circle with antialiasing
   FIGURE_TYPE_CIRCLE_WU,                             // Circle with WU smoothing
   
   FIGURE_TYPE_TRIANGLE,                              // Triangle
   FIGURE_TYPE_TRIANGLE_FILL,                         // Filled triangle
   FIGURE_TYPE_TRIANGLE_AA,                           // Triangle with antialiasing
   FIGURE_TYPE_TRIANGLE_WU,                           // Triangle with WU smoothing
   
   FIGURE_TYPE_ELLIPSE,                               // Ellipse
   FIGURE_TYPE_ELLIPSE_FILL,                          // Filled ellipse
   FIGURE_TYPE_ELLIPSE_AA,                            // Ellipse with antialiasing
   FIGURE_TYPE_ELLIPSE_WU,                            // Ellipse with WU smoothing
   
   FIGURE_TYPE_ARC,                                   // Ellipse arc
   FIGURE_TYPE_PIE,                                   // Ellipse sector
   
   FIGURE_TYPE_FILL,                                  // Filled area
   
  };
//+------------------------------------------------------------------+
//| Font style list                                                  |
//+------------------------------------------------------------------+
enum ENUM_FONT_STYLE
  {
   FONT_STYLE_NORMAL=0,                               // Normal
   FONT_STYLE_ITALIC=FONT_ITALIC,                     // Italic
   FONT_STYLE_UNDERLINE=FONT_UNDERLINE,               // Underline
   FONT_STYLE_STRIKEOUT=FONT_STRIKEOUT                // Strikeout
  };
//+------------------------------------------------------------------+
//| Font width type list                                             |
//+------------------------------------------------------------------+
enum ENUM_FW_TYPE
  {
   FW_TYPE_DONTCARE=FW_DONTCARE,
   FW_TYPE_THIN=FW_THIN,
   FW_TYPE_EXTRALIGHT=FW_EXTRALIGHT,
   FW_TYPE_ULTRALIGHT=FW_ULTRALIGHT,
   FW_TYPE_LIGHT=FW_LIGHT,
   FW_TYPE_NORMAL=FW_NORMAL,
   FW_TYPE_REGULAR=FW_REGULAR,
   FW_TYPE_MEDIUM=FW_MEDIUM,
   FW_TYPE_SEMIBOLD=FW_SEMIBOLD,
   FW_TYPE_DEMIBOLD=FW_DEMIBOLD,
   FW_TYPE_BOLD=FW_BOLD,
   FW_TYPE_EXTRABOLD=FW_EXTRABOLD,
   FW_TYPE_ULTRABOLD=FW_ULTRABOLD,
   FW_TYPE_HEAVY=FW_HEAVY,
   FW_TYPE_BLACK=FW_BLACK
  };  

#endif // __GRAPH_DEFINES_MQH__