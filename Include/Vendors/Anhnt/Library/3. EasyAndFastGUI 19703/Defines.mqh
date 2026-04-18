//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
// --- "Expert window" mode
#define EXPERT_IN_SUBWINDOW false
// --- Class name
#define CLASS_NAME ::StringSubstr(__FUNCTION__,0,::StringFind(__FUNCTION__,"::"))
// --- Program name
#define PROGRAM_NAME ::MQLInfoString(MQL_PROGRAM_NAME)
// --- Program type
#define PROGRAM_TYPE (ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)
// --- Preventing out of range
#define PREVENTING_OUT_OF_RANGE __FUNCTION__," > Preventing array out-of-bounds."

// --- Timer step (milliseconds)
#define TIMER_STEP_MSC (16)
// --- Delay before counter rewind starts (milliseconds)
#define SPIN_DELAY_MSC (-450)
// --- Space character
#define SPACE          (" ")

// --- To represent any names in string format
#define TO_STRING(A) #A
// --- Event data printout
#define PRINT_EVENT(SID,ID,L,D,S) \
::Print(__FUNCTION__," > id: ",TO_STRING(SID)," (",ID,"); lparam: ",L,"; dparam: ",D,"; sparam: ",S);

// --- Event IDs
#define ON_WINDOW_EXPAND            (1)  // Expanding a form
#define ON_WINDOW_COLLAPSE          (2)  // Collapsing a form
#define ON_WINDOW_CHANGE_XSIZE      (3)  // Resizing the window along the X axis
#define ON_WINDOW_CHANGE_YSIZE      (4)  // Resizing the window along the Y axis
#define ON_WINDOW_TOOLTIPS          (5)  // Clicking the "Tooltips" button
//---
#define ON_CLICK_LABEL              (6)  // Clicking on a text label
#define ON_CLICK_BUTTON             (7)  // Pressing a button
#define ON_CLICK_MENU_ITEM          (8)  // Clicking on a menu item
#define ON_CLICK_CONTEXTMENU_ITEM   (9)  // Clicking on a menu item in the context menu
#define ON_CLICK_FREEMENU_ITEM      (10) // Clicking on a free context menu item
#define ON_CLICK_CHECKBOX           (11) // Clicking on the checkbox
#define ON_CLICK_GROUP_BUTTON       (12) // Clicking a button in a group
#define ON_CLICK_ELEMENT            (13) // Clicking on an element
#define ON_CLICK_TAB                (14) // Switch tab
#define ON_CLICK_SUB_CHART          (15) // Clicking on a graphic object
#define ON_CLICK_INC                (16) // Changing counter up
#define ON_CLICK_DEC                (17) // Changing counter down
#define ON_CLICK_COMBOBOX_BUTTON    (18) // Clicking the combo box button
#define ON_CLICK_LIST_ITEM          (19) // Selecting an item in the list
#define ON_CLICK_COMBOBOX_ITEM      (20) // Selecting an item in the combobox list
#define ON_CLICK_TEXT_BOX           (21) // Activating a text input field
//---
#define ON_DOUBLE_CLICK             (22) // Double click left mouse button
#define ON_END_EDIT                 (23) // Finish editing the value in the input field
//---
#define ON_OPEN_DIALOG_BOX          (24) // Dialog box open event
#define ON_CLOSE_DIALOG_BOX         (25) // Dialog close event
#define ON_HIDE_CONTEXTMENUS        (26) // Hide all context menus
#define ON_HIDE_BACK_CONTEXTMENUS   (27) // Hide context menus from the current menu item
//---
#define ON_CHANGE_GUI               (28) // The GUI has changed
#define ON_CHANGE_DATE              (29) // Changing the date in the calendar
#define ON_CHANGE_COLOR             (30) // Changing colors using the color palette
#define ON_CHANGE_TREE_PATH         (31) // The path in the tree list has been changed
#define ON_CHANGE_MOUSE_LEFT_BUTTON (32) // Changing the state of the left mouse button
//---
#define ON_SORT_DATA                (33) // Sorting data
#define ON_MOUSE_BLUR               (34) // The mouse cursor has left the element area
#define ON_MOUSE_FOCUS              (35) // The mouse cursor has entered the element area
#define ON_REDRAW_ELEMENT           (36) // Redrawing an element
#define ON_MOVE_TEXT_CURSOR         (37) // Moving the text cursor
#define ON_SUBWINDOW_CHANGE_HEIGHT  (38) // Changing the height of a subwindow
//---
#define ON_SET_AVAILABLE            (39) // Set available items
#define ON_SET_LOCKED               (40) // Set blocked items
//---
#define ON_WINDOW_DRAG_END          (41) // Form drag and drop is complete
//---
#define ON_END_CREATE_GUI           (42) // GUI created
//+------------------------------------------------------------------+
