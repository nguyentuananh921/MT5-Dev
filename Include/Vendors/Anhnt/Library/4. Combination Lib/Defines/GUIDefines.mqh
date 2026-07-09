//+------------------------------------------------------------------+
//|                                                   GUIDefines.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//| Merged from: Defines.mqh, Enums.mqh, ControlsDefines.mqh         |

//+------------------------------------------------------------------+
#ifndef __GUIDEFINES_MQH__
#define __GUIDEFINES_MQH__
#include "MouseDefines.mqh"
// ──────────────────────────────────────────────────────────────────
// EVENT IDs  (CHARTEVENT_CUSTOM offset values)
// ──────────────────────────────────────────────────────────────────
  #define ON_WINDOW_EXPAND            (1)
  #define ON_WINDOW_COLLAPSE          (2)
  #define ON_WINDOW_CHANGE_XSIZE      (3)
  #define ON_WINDOW_CHANGE_YSIZE      (4)
  #define ON_WINDOW_TOOLTIPS          (5)
  #define ON_CLICK_LABEL              (6)
  #define ON_CLICK_BUTTON             (7)
  #define ON_CLICK_MENU_ITEM          (8)
  #define ON_CLICK_CONTEXTMENU_ITEM   (9)
  #define ON_CLICK_FREEMENU_ITEM      (10)
  #define ON_CLICK_CHECKBOX           (11)
  #define ON_CLICK_GROUP_BUTTON       (12)
  #define ON_CLICK_ELEMENT            (13)
  #define ON_CLICK_TAB                (14)
  #define ON_CLICK_SUB_CHART          (15)
  #define ON_CLICK_INC                (16)
  #define ON_CLICK_DEC                (17)
  #define ON_CLICK_COMBOBOX_BUTTON    (18)
  #define ON_CLICK_LIST_ITEM          (19)
  #define ON_CLICK_COMBOBOX_ITEM      (20)
  #define ON_CLICK_TEXT_BOX           (21)
  #define ON_DOUBLE_CLICK             (22)
  #define ON_END_EDIT                 (23)
  #define ON_OPEN_DIALOG_BOX          (24)
  #define ON_CLOSE_DIALOG_BOX         (25)
  #define ON_HIDE_CONTEXTMENUS        (26)
  #define ON_HIDE_BACK_CONTEXTMENUS   (27)
  #define ON_CHANGE_GUI               (28)
  #define ON_CHANGE_DATE              (29)
  #define ON_CHANGE_COLOR             (30)
  #define ON_CHANGE_TREE_PATH         (31)
  #define ON_CHANGE_MOUSE_LEFT_BUTTON (32)
  #define ON_SORT_DATA                (33)
  #define ON_MOUSE_BLUR               (34)
  #define ON_MOUSE_FOCUS              (35)
  #define ON_REDRAW_ELEMENT           (36)
  #define ON_MOVE_TEXT_CURSOR         (37)
  #define ON_SUBWINDOW_CHANGE_HEIGHT  (38)
  #define ON_SET_AVAILABLE            (39)
  #define ON_SET_LOCKED               (40)
  #define ON_WINDOW_DRAG_END          (41)
  #define ON_END_CREATE_GUI           (42)
// ──────────────────────────────────────────────────────────────────
// WINDOW / CONTROL SIZES
// ──────────────────────────────────────────────────────────────────
  #define WINDOW_BUTTON_SIZE      20
  #define WINDOW_BUTTON_ICON_GAP  2
  #define WINDOW_CAPTION_HEIGHT   22
// ──────────────────────────────────────────────────────────────────
// ENUMERATIONS
// ──────────────────────────────────────────────────────────────────
enum ENUM_WINDOW_TYPE
 {
   W_MAIN   = 0,
   W_DIALOG = 1
 };

enum ENUM_ELEMENT_TYPE
 {
   E_CONTEXT_MENU    = 0,
   E_COMBO_BOX       = 1,
   E_SPLIT_BUTTON    = 2,
   E_MENU_BAR        = 3,
   E_MENU_ITEM       = 4,
   E_DROP_LIST       = 5,
   E_SCROLL          = 6,
   E_TABLE           = 7,
   E_TABS            = 8,
   E_SLIDER          = 9,
   E_CALENDAR        = 10,
   E_DROP_CALENDAR   = 11,
   E_SUB_CHART       = 12,
   E_PICTURES_SLIDER = 13,
   E_TIME_EDIT       = 14,
   E_TEXT_BOX        = 15,
   E_TREE_VIEW       = 16,
   E_FILE_NAVIGATOR  = 17,
   E_TOOLTIP         = 18,
   E_FRAME           = 19
  };

enum ENUM_MOUSE_POINTER
  {
   MP_CUSTOM            = 0,
   MP_X_RESIZE          = 1,
   MP_Y_RESIZE          = 2,
   MP_XY1_RESIZE        = 3,
   MP_XY2_RESIZE        = 4,
   MP_WINDOW_RESIZE     = 5,
   MP_X_RESIZE_RELATIVE = 6,
   MP_Y_RESIZE_RELATIVE = 7,
   MP_X_SCROLL          = 8,
   MP_Y_SCROLL          = 9,
   MP_TEXT_SELECT       = 10
  };

enum ENUM_MOUSE_STATE
 {
   NOT_PRESSED           = 0,
   PRESSED_INSIDE        = 1,
   PRESSED_OUTSIDE       = 2,
   PRESSED_INSIDE_HEADER = 3,
   PRESSED_INSIDE_BORDER = 4
 };

enum ENUM_TYPE_MENU_ITEM
  {
   MI_SIMPLE           = 0,
   MI_CHECKBOX         = 1,
   MI_RADIOBUTTON      = 2,
   MI_HAS_CONTEXT_MENU = 3
  };

enum ENUM_TYPE_SEP_LINE
 {
   H_SEP_LINE = 0,
   V_SEP_LINE = 1
 };

enum ENUM_FIX_CONTEXT_MENU
 {
   FIX_RIGHT  = 0,
   FIX_BOTTOM = 1
 };

enum ENUM_TABS_POSITION
 {
   TABS_TOP    = 0,
   TABS_BOTTOM = 1,
   TABS_LEFT   = 2,
   TABS_RIGHT  = 3
 };

enum ENUM_TYPE_TREE_ITEM
 {
   TI_SIMPLE    = 0,
   TI_HAS_ITEMS = 1
 };

enum ENUM_FILE_NAVIGATOR_MODE
 {
   FN_ALL          = 0,
   FN_ONLY_FOLDERS = 1
 };

enum ENUM_FILE_NAVIGATOR_CONTENT
 {
   FN_BOTH        = 0,
   FN_ONLY_MQL    = 1,
   FN_ONLY_COMMON = 2
 };

enum ENUM_CSORT_MODE
 {
   SORT_ASCEND  = 0,
   SORT_DESCEND = 1
 };

enum ENUM_TYPE_CELL
 {
   CELL_SIMPLE   = 0,
   CELL_BUTTON   = 1,
   CELL_CHECKBOX = 2,
   CELL_COMBOBOX = 3,
   CELL_EDIT     = 4
 };

enum ENUM_MOVE_TEXT_CURSOR
 {
   TO_NEXT_LEFT_SYMBOL  = 0,
   TO_NEXT_RIGHT_SYMBOL = 1,
   TO_NEXT_LEFT_WORD    = 2,
   TO_NEXT_RIGHT_WORD   = 3,
   TO_NEXT_UP_LINE      = 4,
   TO_NEXT_DOWN_LINE    = 5,
   TO_BEGIN_LINE        = 6,
   TO_END_LINE          = 7,
   TO_BEGIN_FIRST_LINE  = 8,
   TO_END_LAST_LINE     = 9
 };

// ──────────────────────────────────────────────────────────────────
// MACROS
// ──────────────────────────────────────────────────────────────────
  #define EXPERT_IN_SUBWINDOW false
  #define CLASS_NAME          ::StringSubstr(__FUNCTION__,0,::StringFind(__FUNCTION__,"::"))
  #define PROGRAM_NAME        ::MQLInfoString(MQL_PROGRAM_NAME)
  #define PROGRAM_TYPE        (ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)
  #define PREVENTING_OUT_OF_RANGE __FUNCTION__," > Preventing array out-of-bounds."
  #define TIMER_STEP_MSC      (16)
  #define SPIN_DELAY_MSC      (-450)
  #define SPACE               (" ")
  #define STRINGIFY(A)        #A
  #define PRINT_EVENT(SID,ID,L,D,S) \
   ::Print(__FUNCTION__," > id: ",STRINGIFY(SID)," (",ID,"); lparam: ",L,"; dparam: ",D,"; sparam: ",S);
#endif // __GUIDEFINES_MQH__
