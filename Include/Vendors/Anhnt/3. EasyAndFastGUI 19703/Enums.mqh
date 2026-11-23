//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Enumeration of window types |
//+------------------------------------------------------------------+
#ifndef __ENUMS_MQH__
#define __ENUMS_MQH__
enum ENUM_WINDOW_TYPE
  {
   W_MAIN   =0,
   W_DIALOG =1
  };
//+------------------------------------------------------------------+
// | Enumeration of element types |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_TYPE
  {
   E_CONTEXT_MENU    =0,
   E_COMBO_BOX       =1,
   E_SPLIT_BUTTON    =2,
   E_MENU_BAR        =3,
   E_MENU_ITEM       =4,
   E_DROP_LIST       =5,
   E_SCROLL          =6,
   E_TABLE           =7,
   E_TABS            =8,
   E_SLIDER          =9,
   E_CALENDAR        =10,
   E_DROP_CALENDAR   =11,
   E_SUB_CHART       =12,
   E_PICTURES_SLIDER =13,
   E_TIME_EDIT       =14,
   E_TEXT_BOX        =15,
   E_TREE_VIEW       =16,
   E_FILE_NAVIGATOR  =17,
   E_TOOLTIP         =18,
   E_FRAME           =19
  };
//+------------------------------------------------------------------+
// | Enumeration of pointer types |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_POINTER
  {
   MP_CUSTOM            =0,
   MP_X_RESIZE          =1,
   MP_Y_RESIZE          =2,
   MP_XY1_RESIZE        =3,
   MP_XY2_RESIZE        =4,
   MP_WINDOW_RESIZE     =5,
   MP_X_RESIZE_RELATIVE =6,
   MP_Y_RESIZE_RELATIVE =7,
   MP_X_SCROLL          =8,
   MP_Y_SCROLL          =9,
   MP_TEXT_SELECT       =10
  };
//+------------------------------------------------------------------+
// | Enumeration of left-click areas |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_STATE
  {
   NOT_PRESSED           =0,
   PRESSED_INSIDE        =1,
   PRESSED_OUTSIDE       =2,
   PRESSED_INSIDE_HEADER =3,
   PRESSED_INSIDE_BORDER =4
  };
//+------------------------------------------------------------------+
// | Enumerating menu item types |
//+------------------------------------------------------------------+
enum ENUM_TYPE_MENU_ITEM
  {
   MI_SIMPLE           =0,
   MI_CHECKBOX         =1,
   MI_RADIOBUTTON      =2,
   MI_HAS_CONTEXT_MENU =3
  };
//+------------------------------------------------------------------+
// | Divider line type enumeration |
//+------------------------------------------------------------------+
enum ENUM_TYPE_SEP_LINE
  {
   H_SEP_LINE =0,
   V_SEP_LINE =1
  };
//+------------------------------------------------------------------+
// | Listing the sides of the menu mount |
//+------------------------------------------------------------------+
enum ENUM_FIX_CONTEXT_MENU
  {
   FIX_RIGHT  =0,
   FIX_BOTTOM =1
  };
//+------------------------------------------------------------------+
// | Tab positioning enumeration |
//+------------------------------------------------------------------+
enum ENUM_TABS_POSITION
  {
   TABS_TOP    =0, // Top
   TABS_BOTTOM =1, // Bottom
   TABS_LEFT   =2, // Left
   TABS_RIGHT  =3  // Right
  };
//+------------------------------------------------------------------+
// | Enumerating tree list item types |
//+------------------------------------------------------------------+
enum ENUM_TYPE_TREE_ITEM
  {
   TI_SIMPLE    =0,
   TI_HAS_ITEMS =1
  };
//+------------------------------------------------------------------+
// | Enumeration of file navigator modes |
//+------------------------------------------------------------------+
enum ENUM_FILE_NAVIGATOR_MODE
  {
   FN_ALL          =0,
   FN_ONLY_FOLDERS =1
  };
//+------------------------------------------------------------------+
// | Listing the contents of the file navigator |
//+------------------------------------------------------------------+
enum ENUM_FILE_NAVIGATOR_CONTENT
  {
   FN_BOTH        =0,
   FN_ONLY_MQL    =1,
   FN_ONLY_COMMON =2
  };
//+------------------------------------------------------------------+
// | Enumeration of sorting modes |
//+------------------------------------------------------------------+
enum ENUM_CSORT_MODE
  {
   SORT_ASCEND  =0,
   SORT_DESCEND =1
  };
//+------------------------------------------------------------------+
// | Enumerating table cell types |
//+------------------------------------------------------------------+
enum ENUM_TYPE_CELL
  {
   CELL_SIMPLE   =0,
   CELL_BUTTON   =1,
   CELL_CHECKBOX =2,
   CELL_COMBOBOX =3,
   CELL_EDIT     =4
  };
//+------------------------------------------------------------------+
// | Enumeration by direction of movement of the text cursor |
//+------------------------------------------------------------------+
enum ENUM_MOVE_TEXT_CURSOR
  {
   TO_NEXT_LEFT_SYMBOL  =0,
   TO_NEXT_RIGHT_SYMBOL =1,
   TO_NEXT_LEFT_WORD    =2,
   TO_NEXT_RIGHT_WORD   =3,
   TO_NEXT_UP_LINE      =4,
   TO_NEXT_DOWN_LINE    =5,
   TO_BEGIN_LINE        =6,
   TO_END_LINE          =7,
   TO_BEGIN_FIRST_LINE  =8,
   TO_END_LAST_LINE     =9
  };
//+------------------------------------------------------------------+
#endif // __ENUMS_MQH__
