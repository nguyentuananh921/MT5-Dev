//+------------------------------------------------------------------+
//|                                                    WndCreate.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "WndEvents.mqh"
//+------------------------------------------------------------------+
// | Class for creating elements |
//+------------------------------------------------------------------+
class CWndCreate : public CWndEvents {
 protected:
  CWndCreate(void);
  ~CWndCreate(void);
  //---
 public:
  // --- Form
  bool              CreateWindow(CWindow &object, const string text,
                                 const int x = 1, const int y = 1, const int x_size = 200, const int y_size = 200,
                                 const bool button_close = true, const bool button_fullscreen = true, const bool button_collapse = true, const bool button_tooltips = true);
  // --- Dialog box
  bool              CreateDialogWindow(CWindow &object, const string caption_text,
                                       const int x, const int y, const int x_size, const int y_size,
                                       const string icon_path = "", const int icon_x_gap = 5, const int icon_y_gap = 2);
  // --- Status line
  bool              CreateStatusBar(CStatusBar &object, CElement &main, const int x, const int y, const int y_size, string &text_items[], int &width_items[]);

  // --- Tabs
  bool              CreateTabs(CTabs &object, CElement &main, const int window_index,
                               const int x, const int y, const int x_size, const int y_size, string &text[], int &width[],
                               ENUM_TABS_POSITION position = TABS_TOP, const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0);
  bool              CreateTabs(CTabs &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                               const int x, const int y, const int x_size, const int y_size, string &text[], int &width[],
                               ENUM_TABS_POSITION position = TABS_TOP, const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0);

  // --- Tables
  bool              CreateTable(CTable &object, CElement &main, const int window_index,
                                const int columns_total, const int rows_total, string &headers[],
                                const int x, const int y, const int x_size = 0, const int y_size = 0,
                                const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0);
                                
  bool              CreateTable(CTable &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                const int columns_total, const int rows_total, string &headers[],
                                const int x, const int y, const int x_size = 0, const int y_size = 0,
                                const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0);

  // --- Standard schedule
  bool              CreateSubCharts(CStandardChart &object, CElement &main, const int window_index,
                                    const int x, const int y, const int x_size, const int y_size,
                                    const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0);
  bool              CreateSubCharts(CStandardChart &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                    const int x, const int y, const int x_size, const int y_size,
                                    const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0);
  // --- Checkbox
  bool              CreateCheckbox(CCheckBox &object, const string text, CElement &main, const int window_index,
                                   const int x, const int y, const int xsize = 100, const bool is_pressed = false, const bool is_right = false, const bool is_bottom = false);

  bool              CreateCheckbox(CCheckBox &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                   const int x, const int y, const int xsize = 100, const bool is_pressed = false, const bool is_right = false, const bool is_bottom = false);
  // --- Combobox
  bool              CreateCombobox(CComboBox &object, const string text, CElement &main, const int window_index,
                                   const bool checkbox_mode, const int x, const int y, const int x_size, const int button_x_size,
                                   string &items[], const int list_y_size, const int selected_item_index = 0);

  bool              CreateCombobox(CComboBox &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                   const bool checkbox_mode, const int x, const int y, const int x_size, const int button_x_size,
                                   string &items[], const int list_y_size, const int selected_item_index = 0);
  // --- Text label
  bool              CreateTextLabel(CTextLabel &object, const string text, CElement &main, const int window_index,
                                    const int x, const int y, const int x_size, const int y_size = 20);
  bool              CreateTextLabel(CTextLabel &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                    const int x, const int y, const int x_size, const int y_size = 20);
  // --- Progress bar
  bool              CreateProgressBar(CProgressBar &object, const string text, CElement &main, const int window_index, const int x, const int y);

  // --- Drop-down calendar
  bool              CreateDropCalendar(CDropCalendar &object, const string text, CElement &main, const int window_index,
                                       const int x, const int y, const int x_size, const datetime selected_date);
                                       
  bool              CreateDropCalendar(CDropCalendar &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                       const int x, const int y, const int x_size, const datetime selected_date);
  // --- Button
  bool              CreateButton(CButton &object, const string text, CElement &main, const int window_index,
                                 const int x, const int y, const int x_size, const bool is_right = false, const bool is_bottom = false,
                                 const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                                 const color label_color = clrNONE, const color border_color = clrNONE);

  bool              CreateButton(CButton &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                 const int x, const int y, const int x_size, const bool is_right = false, const bool is_bottom = false,
                                 const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                                 const color label_color = clrNONE, const color border_color = clrNONE);

  bool              CreateButton(CButton &object, const string text, CElement &main, const int window_index,
                                 const int x, const int y, const int x_size, const int y_size, const int label_x, const int label_y,
                                 const int icon_x, const int icon_y, const string image_path, const bool is_right = false, const bool is_bottom = false,
                                 const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                                 const color label_color = clrNONE, const color border_color = clrNONE);

  bool              CreateButton(CButton &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                 const int x, const int y, const int x_size, const int y_size, const int label_x, const int label_y,
                                 const int icon_x, const int icon_y, const string image_path, const bool is_right = false, const bool is_bottom = false,
                                 const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                                 const color label_color = clrNONE, const color border_color = clrNONE);

  // --- Input field
  bool              CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index,
                                   const bool checkbox_mode, const int x, const int y,
                                   const int x_size, const int edit_x_size, const string value, const string default_text = "");

  bool              CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index, 
                                   CTabs &tabs, const int tab_index,
                                   const bool checkbox_mode, const int x, const int y, 
                                   const int x_size, const int edit_x_size, const string value, const string default_text = "");

  bool              CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index,
                                   const bool checkbox_mode, const int x, const int y, const int x_size, const int edit_x_size,
                                   const double max, const double min, const double step, const int digits, const double value = 0);

  bool              CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index, 
                                   CTabs &tabs, const int tab_index,
                                   const bool checkbox_mode, const int x, const int y, const int x_size, const int edit_x_size,
                                   const double max, const double min, const double step, const int digits, const double value = 0);

  // --- Radio buttons
  bool              CreateRadioButtons(CButtonsGroup &object, CElement &main, const int window_index,
                                       const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[]);
  bool              CreateRadioButtons(CButtonsGroup &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                       const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[]);

  // --- Button group
  bool              CreateButtonsGroup(CButtonsGroup &object, CElement &main, const int window_index,
                                       const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[],
                                       color &back_clr[], color &hover_clr[], color &pressed_clr[], const color label_clr, const color border_clr);

  bool              CreateButtonsGroup(CButtonsGroup &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                       const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[],
                                       color &back_clr[], color &hover_clr[], color &pressed_clr[], const color label_clr, const color border_clr);

  // ---Color button
  bool              CreateColorButton(CColorButton &object, const string text, CElement &main, const int window_index,
                                      const int x, const int y, const int xsize, const int button_x_size);
                                      
  bool              CreateColorButton(CColorButton &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                      const int x, const int y, const int xsize, const int button_x_size);
  // --- Color palette
  bool              CreateColorPicker(CColorPicker &object, CElement &main, const int window_index, const int x, const int y);

  // ---Area
  bool              CreateFrame(CFrame &object, const string text, CElement &main, const int window_index,
                                const int x, const int y, const int x_size, const int y_size, const int label_x_size,
                                const bool is_right = false, const bool is_bottom = false, const int right_offset = 0, const int bottom_offset = 0);

  bool              CreateFrame(CFrame &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                const int x, const int y, const int x_size, const int y_size, const int label_x_size,
                                const bool is_right = false, const bool is_bottom = false, const int right_offset = 0, const int bottom_offset = 0);

  // --- File navigator
  bool              CreateFileNavigator(CFileNavigator &object, CElement &main, const int window_index, const int x, const int y,
                                        const int tree_view_x_size, const bool auto_x_resize, const int right_offset, const int visible_items_total,
                                        ENUM_FILE_NAVIGATOR_CONTENT content_mode = FN_BOTH, ENUM_FILE_NAVIGATOR_MODE navigator_mode = FN_ONLY_FOLDERS);
  // --- Charts
  bool              CreateGraph(CGraph &object, CElement &main, const int window_index,
                                const int x, const int y, const bool auto_x_resize, const bool auto_y_resize,
                                const int right_offset, const int bottom_offset, const bool is_right, const bool is_bottom,
                                ENUM_AXIS_TYPE axis_type, DoubleToStringFunction func_x_axis, DoubleToStringFunction func_y_axis);
                                
  bool              CreateGraph(CGraph &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                const int x, const int y, const bool auto_x_resize, const bool auto_y_resize,
                                const int right_offset, const int bottom_offset, const bool is_right, const bool is_bottom,
                                ENUM_AXIS_TYPE axis_type, DoubleToStringFunction func_x_axis, DoubleToStringFunction func_y_axis);
  // --- Dividing line
  bool              CreateSepLine(CSeparateLine &object, CElement &main, const int window_index,
                                  const int x, const int y, const int x_size, const int y_size,
                                  color dark_clr, color light_clr, ENUM_TYPE_SEP_LINE type_line);
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWndCreate::CWndCreate(void) {
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWndCreate::~CWndCreate(void) {
}
//+------------------------------------------------------------------+
// | Создаёт форму для элементов управления                           |
//+------------------------------------------------------------------+
bool CWndCreate::CreateWindow(CWindow &object, const string caption_text,
                              const int x = 1, const int y = 1, const int x_size = 200, const int y_size = 200,
                              const bool button_close = true, const bool button_fullscreen = true, const bool button_collapse = true, const bool button_tooltips = true) {
//--- Добавим указатель окна в массив окон
  CWndContainer::AddWindow(object);
// ---Coordinates
  int x_l = (object.X() > x) ? object.X() : x;
  int y_l = (object.Y() > y) ? object.Y() : y;
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.IsMovable(true);
// ---Buttons
  object.CloseButtonIsUsed(button_close);
  object.CollapseButtonIsUsed(button_collapse);
  object.TooltipsButtonIsUsed(button_tooltips);
  object.FullscreenButtonIsUsed(button_fullscreen);
  object.TransparentOnlyCaption(false);
//--- Установим всплывающие подсказки
  object.GetCloseButtonPointer().Tooltip("Close");
  object.GetTooltipButtonPointer().Tooltip("Tooltips");
  object.GetFullscreenButtonPointer().Tooltip("Fullscreen");
  object.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
// ---Creating a form
  if(!object.CreateWindow(m_chart_id, m_subwin, caption_text, x_l, y_l))
    return(false);
//---
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a dialog box |
//+------------------------------------------------------------------+
bool CWndCreate::CreateDialogWindow(CWindow &object, const string caption_text,
                                    const int x, const int y, const int x_size, const int y_size,
                                    const string icon_path = "", const int icon_x_gap = 5, const int icon_y_gap = 2) {
// --- Add a window object to the window array
  CWndContainer::AddWindow(object);
// --- Properties
  object.IsMovable(true);
  object.XSize(x_size);
  object.YSize(y_size);
  object.IconXGap(icon_x_gap);
  object.IconYGap(icon_y_gap);
  object.WindowType(W_DIALOG);

  if(icon_path != "") {
    object.IconFile(icon_path);
  } else {
    object.IconFile((uint)RESOURCE_HELP);
  }
// ---Creating a form
  if(!object.CreateWindow(m_chart_id, m_subwin, caption_text, x, y))
    return(false);
//---
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a status line |
//+------------------------------------------------------------------+
bool CWndCreate::CreateStatusBar(CStatusBar &object, CElement &main, const int x, const int y, const int y_size, string &text_items[], int &width_items[]) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Properties
  object.YSize(y_size);
  object.AutoXResizeMode(true);
  object.AutoXResizeRightOffset(1);
  object.AnchorBottomWindowSide(true);
// --- We indicate how many parts there should be and set their properties
  int total =::ArraySize(text_items);
  for(int i = 0; i < total; i++)
    object.AddItem(text_items[i], width_items[i]);
// ---Creating an element
  if(!object.CreateStatusBar(x, y))
    return(false);
//--- Добавим объект в общий массив
  CWndContainer::AddToElementsArray(0, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт область с вкладками                                      |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTabs(CTabs &object, CElement &main, const int window_index,
                            const int x, const int y, const int x_size, const int y_size, string &text[], int &width[],
                            ENUM_TABS_POSITION position = TABS_TOP, const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.IsCenterText(true);
  object.PositionMode(position);
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
// --- Add tabs with the specified properties
  int total =::ArraySize(text);
  for(int i = 0; i < total; i++)
    object.AddTab(text[i], width[i]);
// --- Let's create a control
  if(!object.CreateTabs(x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт область с вкладками                                      |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTabs(CTabs &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                            const int x, const int y, const int x_size, const int y_size, string &text[], int &width[],
                            ENUM_TABS_POSITION position = TABS_TOP, const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.IsCenterText(true);
  object.PositionMode(position);
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
// --- Add tabs with the specified properties
  int total =::ArraySize(text);
  for(int i = 0; i < total; i++)
    object.AddTab(text[i], width[i]);
// --- Let's create a control
  if(!object.CreateTabs(x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a table |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTable(CTable &object, CElement &main, const int window_index,
                             const int columns_total, const int rows_total, string &headers[],
                             const int x, const int y, const int x_size = 0, const int y_size = 0,
                             const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
  
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.TableSize(columns_total, rows_total);
  object.ShowHeaders(::ArraySize(headers) > 0);
  object.SelectableRow(true);
  object.IsWithoutDeselect(true);
  object.IsSortMode(true);
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
  
// --- Let's create a control
  if(!object.CreateTable(x, y))
    return(false);
    
// --- Headings
  if(object.ColumnsTotal() == ::ArraySize(headers) && ::ArraySize(headers) > 0) {
    for(uint i = 0; i < object.ColumnsTotal(); i++)
      object.SetHeaderText(i, headers[i]);
  }
//--- Добавим объект в общий массив групп объектов
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a table |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTable(CTable &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                             const int columns_total, const int rows_total, string &headers[],
                             const int x, const int y, const int x_size = 0, const int y_size = 0,
                             const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0) {
//--- Сохраним указатель на главный элемент
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  if(object.ColumnsTotal() < 2 && object.RowsTotal() < 2)
    object.TableSize(columns_total, rows_total);
  object.ShowHeaders(::ArraySize(headers) > 0);
  object.SelectableRow(true);
  object.IsWithoutDeselect(true);
  object.IsSortMode(true);
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
// --- Let's create a control
  if(!object.CreateTable(x, y))
    return(false);
// --- Headings
  if(object.ColumnsTotal() ==::ArraySize(headers) && ::ArraySize(headers) > 0) {
    for(uint i = 0; i < object.ColumnsTotal(); i++)
      object.SetHeaderText(i, headers[i]);
  }
// --- Add an object to the general array of object groups
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a standard chart |
//+------------------------------------------------------------------+
bool CWndCreate::CreateSubCharts(CStandardChart &object, CElement &main, const int window_index,
                                 const int x, const int y, const int x_size, const int y_size,
                                 const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.XScrollMode(true);
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
  object.AddSubChart(_Symbol, _Period);
//--- Создадим элемент управления
  if(!object.CreateStandardChart(x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a standard chart |
//+------------------------------------------------------------------+
bool CWndCreate::CreateSubCharts(CStandardChart &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                 const int x, const int y, const int x_size, const int y_size,
                                 const bool auto_x_resize = false, const bool auto_y_resize = false, const int right_offset = 0, const int bottom_offset = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.XScrollMode(true);
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
  object.AddSubChart(_Symbol, _Period);
// --- Let's create a control
  if(!object.CreateStandardChart(x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a checkbox |
//+------------------------------------------------------------------+
bool CWndCreate::CreateCheckbox(CCheckBox &object, const string text, CElement &main, const int window_index,
                                const int x, const int y, const int xsize = 100, const bool is_pressed = false, const bool is_right = false, const bool is_bottom = false) {
// --- Save the pointer to the main element
  object.MainPointer(main);

// --- Properties
  object.XSize(xsize);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);

// --- Let's create a control
  if(!object.CreateCheckBox(text, x, y))
    return(false);

// --- Enable checkbox
  object.IsPressed(is_pressed);

// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт чекбокс                                                  |
//+------------------------------------------------------------------+
bool CWndCreate::CreateCheckbox(CCheckBox &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                const int x, const int y, const int xsize = 100, const bool is_pressed = false, const bool is_right = false, const bool is_bottom = false) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(xsize);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
// --- Let's create a control
  if(!object.CreateCheckBox(text, x, y))
    return(false);
// --- Enable checkbox
  object.IsPressed(is_pressed);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a combo box |
//+------------------------------------------------------------------+
bool CWndCreate::CreateCombobox(CComboBox &object, const string text, CElement &main, const int window_index,
                                const bool checkbox_mode, const int x, const int y, const int x_size, const int button_x_size,
                                string &items[], const int list_y_size, const int selected_item_index = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Number of points
  int total =::ArraySize(items);
// --- Set the properties before creating
  object.XSize(x_size);
  object.YSize(20);
  object.ItemsTotal(total);
  object.CheckBoxMode(checkbox_mode);
  object.GetButtonPointer().XSize(button_x_size);
  object.GetButtonPointer().YSize(18);
  object.GetButtonPointer().AnchorRightWindowSide(true);
// --- Save the item values ​​to the combo box list
  for(int i = 0; i < total; i++)
    object.SetValue(i, items[i]);
// --- Get the list pointer
  CListView *lv = object.GetListViewPointer();
// --- Set list properties
  lv.YSize(list_y_size);
  lv.LightsHover(true);
  lv.SelectItem(lv.SelectedItemIndex() == WRONG_VALUE ? selected_item_index : lv.SelectedItemIndex());

// --- Let's create a control
  if(!object.CreateComboBox(text, x, y))
    return(false);

// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a combo box |
//+------------------------------------------------------------------+
bool CWndCreate::CreateCombobox(CComboBox &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                const bool checkbox_mode, const int x, const int y, const int x_size, const int button_x_size,
                                string &items[], const int list_y_size, const int selected_item_index = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Number of points
  int total =::ArraySize(items);
// --- Set the properties before creating
  object.XSize(x_size);
  object.YSize(20);
  object.ItemsTotal(total);
  object.CheckBoxMode(checkbox_mode);
  object.GetButtonPointer().XSize(button_x_size);
  object.GetButtonPointer().YSize(18);
  object.GetButtonPointer().AnchorRightWindowSide(true);
// --- Save the item values ​​to the combo box list
  for(int i = 0; i < total; i++)
    object.SetValue(i, items[i]);
// --- Get the list pointer
  CListView *lv = object.GetListViewPointer();
// --- Set list properties
  lv.YSize(list_y_size);
  lv.LightsHover(true);
  lv.SelectItem(lv.SelectedItemIndex() == WRONG_VALUE ? selected_item_index : lv.SelectedItemIndex());
// --- Let's create a control
  if(!object.CreateComboBox(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт текстовую метку                                          |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTextLabel(CTextLabel &object, const string text, CElement &main, const int window_index,
                                 const int x, const int y, const int x_size, const int y_size = 20) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
// --- Creating a button
  if(!object.CreateTextLabel(text, x, y))
    return(false);
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт текстовую метку                                          |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTextLabel(CTextLabel &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                 const int x, const int y, const int x_size, const int y_size = 20) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
// --- Creating a button
  if(!object.CreateTextLabel(text, x, y))
    return(false);
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a progress bar |
//+------------------------------------------------------------------+
bool CWndCreate::CreateProgressBar(CProgressBar &object, const string text, CElement &main, const int window_index, const int x, const int y) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Properties
  object.YSize(17);
  object.BarYSize(14);
  object.BarXGap(0);
  object.BarYGap(1);
  object.LabelXGap(5);
  object.LabelYGap(2);
  object.PercentXGap(5);
  object.PercentYGap(2);
  object.IsDropdown(true);
  object.Font("Consolas");
  object.BorderColor(clrSilver);
  object.IndicatorBackColor(clrWhiteSmoke);
  object.IndicatorColor(clrLightGreen);
  object.AutoXResizeMode(true);
  object.AutoXResizeRightOffset(2);
// ---Creating an element
  if(!object.CreateProgressBar(text, x, y))
    return(false);
//--- Добавим указатель на элемент в базу
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a drop-down calendar |
//+------------------------------------------------------------------+
bool CWndCreate::CreateDropCalendar(CDropCalendar &object, const string text, CElement &main, const int window_index,
                                    const int x, const int y, const int x_size, const datetime selected_date) {
//--- Сохранить указатель на главный элемент
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.YSize(20);
  object.SelectedDate(selected_date);
// --- Let's create a control
  if(!object.CreateDropCalendar(text, x, y))
    return(false);
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a drop-down calendar |
//+------------------------------------------------------------------+
bool CWndCreate::CreateDropCalendar(CDropCalendar &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                    const int x, const int y, const int x_size, const datetime selected_date) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.YSize(20);
  object.SelectedDate(selected_date);
// --- Let's create a control
  if(!object.CreateDropCalendar(text, x, y))
    return(false);
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a button |
//+------------------------------------------------------------------+
bool CWndCreate::CreateButton(CButton &object, const string text, CElement &main, const int window_index,
                              const int x, const int y, const int x_size, const bool is_right = false, const bool is_bottom = false,
                              const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                              const color label_color = clrNONE, const color border_color = clrNONE) {
//--- Сохранить указатель на главный элемент
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.IsCenterText(true);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
  if(back_color != clrNONE) {
    object.BackColor(back_color);
    object.BackColorHover(back_color_hover);
    object.BackColorPressed(back_color_pressed);
    object.LabelColor(label_color);
    object.LabelColorHover(label_color);
    object.LabelColorPressed(label_color);
    object.BorderColor(border_color);
    object.BorderColorHover(border_color);
    object.BorderColorPressed(border_color);
  }
// --- Let's create a control
  if(!object.CreateButton(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт кнопку                                                   |
//+------------------------------------------------------------------+
bool CWndCreate::CreateButton(CButton &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                              const int x, const int y, const int x_size, const bool is_right = false, const bool is_bottom = false,
                              const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                              const color label_color = clrNONE, const color border_color = clrNONE) {
//--- Сохранить указатель на главный элемент
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.IsCenterText(true);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
  if(back_color != clrNONE) {
    object.BackColor(back_color);
    object.BackColorHover(back_color_hover);
    object.BackColorPressed(back_color_pressed);
    object.LabelColor(label_color);
    object.LabelColorHover(label_color);
    object.LabelColorPressed(label_color);
    object.BorderColor(border_color);
    object.BorderColorHover(border_color);
    object.BorderColorPressed(border_color);
  }
// --- Let's create a control
  if(!object.CreateButton(text, x, y))
    return(false);
//--- Добавим объект в общий массив
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт кнопку                                                   |
//+------------------------------------------------------------------+
bool CWndCreate::CreateButton(CButton &object, const string text, CElement &main, const int window_index,
                              const int x, const int y, const int x_size, const int y_size, const int label_x, const int label_y,
                              const int icon_x, const int icon_y, const string image_path, const bool is_right = false, const bool is_bottom = false,
                              const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                              const color label_color = clrNONE, const color border_color = clrNONE) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.LabelXGap(label_x);
  object.LabelYGap(label_y);
  object.IconXGap(icon_x);
  object.IconYGap(icon_y);
  object.IconFile(image_path);
  object.IconFileLocked(image_path);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
  if(back_color != clrNONE) {
    object.BackColor(back_color);
    object.BackColorHover(back_color_hover);
    object.BackColorPressed(back_color_pressed);
    object.LabelColor(label_color);
    object.LabelColorHover(label_color);
    object.LabelColorPressed(label_color);
    object.BorderColor(border_color);
    object.BorderColorHover(border_color);
    object.BorderColorPressed(border_color);
  }
// --- Let's create a control
  if(!object.CreateButton(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Создаёт кнопку                                                   |
//+------------------------------------------------------------------+
bool CWndCreate::CreateButton(CButton &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                              const int x, const int y, const int x_size, const int y_size, const int label_x, const int label_y,
                              const int icon_x, const int icon_y, const string image_path, const bool is_right = false, const bool is_bottom = false,
                              const color back_color = clrNONE, const color back_color_hover = clrNONE, const color back_color_pressed = clrNONE,
                              const color label_color = clrNONE, const color border_color = clrNONE) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.LabelXGap(label_x);
  object.LabelYGap(label_y);
  object.IconXGap(icon_x);
  object.IconYGap(icon_y);
  object.IconFile(image_path);
  object.IconFileLocked(image_path);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
  if(back_color != clrNONE) {
    object.BackColor(back_color);
    object.BackColorHover(back_color_hover);
    object.BackColorPressed(back_color_pressed);
    object.LabelColor(label_color);
    object.LabelColorHover(label_color);
    object.LabelColorPressed(label_color);
    object.BorderColor(border_color);
    object.BorderColorHover(border_color);
    object.BorderColorPressed(border_color);
  }
// --- Let's create a control
  if(!object.CreateButton(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates an input field - text |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index,
                                const bool checkbox_mode, const int x, const int y, 
                                const int x_size, const int edit_x_size, 
                                const string value, const string default_text = "") {
// --- Save the pointer to the main element
  object.MainPointer(main);
  
// --- Properties
  object.XSize(x_size);
  object.SetValue(value);
  object.SpinEditMode(false);
  object.CheckBoxMode(checkbox_mode);
  object.GetTextBoxPointer().XSize(edit_x_size);
  object.GetTextBoxPointer().AutoSelectionMode(true);
  object.GetTextBoxPointer().AnchorRightWindowSide(true);
  object.GetTextBoxPointer().DefaultText(default_text);
  
// --- Let's create a control
  if(!object.CreateTextEdit(text, x, y))
    return(false);
    
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates an input field - text |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                const bool checkbox_mode, const int x, const int y, 
                                const int x_size, const int edit_x_size, 
                                const string value, const string default_text = "") {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.SetValue(value);
  object.SpinEditMode(false);
  object.CheckBoxMode(checkbox_mode);
  object.GetTextBoxPointer().XSize(edit_x_size);
  object.GetTextBoxPointer().AutoSelectionMode(true);
  object.GetTextBoxPointer().AnchorRightWindowSide(true);
  object.GetTextBoxPointer().DefaultText(default_text);
// --- Let's create a control
  if(!object.CreateTextEdit(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates an input field - numeric |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index,
                                const bool checkbox_mode, const int x, const int y, const int x_size, const int edit_x_size,
                                const double max, const double min, const double step, const int digits, const double value = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.MaxValue(max);
  object.MinValue(min);
  object.StepValue(step);
  object.SetDigits(digits);
  object.SpinEditMode(true);
  object.CheckBoxMode(checkbox_mode);
  object.SetValue((string)value);
  object.AnchorBottomWindowSide(false);
  object.GetTextBoxPointer().XSize(edit_x_size);
  object.GetTextBoxPointer().AutoSelectionMode(true);
  object.GetTextBoxPointer().AnchorRightWindowSide(true);
// --- Let's create a control
  if(!object.CreateTextEdit(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates an input field - numeric |
//+------------------------------------------------------------------+
bool CWndCreate::CreateTextEdit(CTextEdit &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                const bool checkbox_mode, const int x, const int y, const int x_size, const int edit_x_size,
                                const double max, const double min, const double step, const int digits, const double value = 0) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.MaxValue(max);
  object.MinValue(min);
  object.StepValue(step);
  object.SetDigits(digits);
  object.SpinEditMode(true);
  object.CheckBoxMode(checkbox_mode);
  object.SetValue((string)value);
  object.AnchorBottomWindowSide(false);
  object.GetTextBoxPointer().XSize(edit_x_size);
  object.GetTextBoxPointer().AutoSelectionMode(true);
  object.GetTextBoxPointer().AnchorRightWindowSide(true);
// --- Let's create a control
  if(!object.CreateTextEdit(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a group of radio buttons |
//+------------------------------------------------------------------+
bool CWndCreate::CreateRadioButtons(CButtonsGroup &object, CElement &main, const int window_index,
                                    const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[]) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Properties
  object.RadioButtonsMode(true);
  object.RadioButtonsStyle(true);
// --- Add buttons to the group
  int total =::ArraySize(x_offset);
  for(int i = 0; i < total; i++) {
    // --- First add a button
    object.AddButton(x_offset[i], y_offset[i], text[i], width[i]);
    // --- Set properties for the button
    object.GetButtonPointer(i).YSize(14);
    object.GetButtonPointer(i).LabelXGap(17);
    object.GetButtonPointer(i).LabelYGap(0);
  }
// --- Create a button group
  if(!object.CreateButtonsGroup(x, y))
    return(false);
// --- Select the button in the group
  object.SelectButton(0);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a group of radio buttons |
//+------------------------------------------------------------------+
bool CWndCreate::CreateRadioButtons(CButtonsGroup &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                    const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[]) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.RadioButtonsMode(true);
  object.RadioButtonsStyle(true);
// --- Add buttons to the group
  int total =::ArraySize(x_offset);
  for(int i = 0; i < total; i++) {
    // --- First add a button
    object.AddButton(x_offset[i], y_offset[i], text[i], width[i]);
    // --- Set properties for the button
    object.GetButtonPointer(i).YSize(14);
    object.GetButtonPointer(i).LabelXGap(17);
    object.GetButtonPointer(i).LabelYGap(0);
  }
// --- Create a button group
  if(!object.CreateButtonsGroup(x, y))
    return(false);
// --- Select the button in the group
  object.SelectButton(0);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a group of buttons |
//+------------------------------------------------------------------+
bool CWndCreate::CreateButtonsGroup(CButtonsGroup &object, CElement &main, const int window_index,
                                    const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[],
                                    color &back_clr[], color &hover_clr[], color &pressed_clr[], const color label_clr, const color border_clr) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Properties
  object.RadioButtonsMode(false);
  object.RadioButtonsStyle(false);
  object.IsCenterText(true);
// --- Add buttons to the group
  int total =::ArraySize(x_offset);
  for(int i = 0; i < total; i++) {
    // --- First add a button
    object.AddButton(x_offset[i], y_offset[i], text[i], width[i], back_clr[i], hover_clr[i], pressed_clr[i]);
    // --- Set properties for the button
    object.GetButtonPointer(i).YSize(20);
    object.GetButtonPointer(i).LabelColor(label_clr);
    object.GetButtonPointer(i).LabelColorHover(label_clr);
    object.GetButtonPointer(i).LabelColorPressed(label_clr);
    object.GetButtonPointer(i).BorderColor(border_clr);
    object.GetButtonPointer(i).BorderColorHover(border_clr);
    object.GetButtonPointer(i).BorderColorPressed(border_clr);
  }
// --- Create a button group
  if(!object.CreateButtonsGroup(x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a group of buttons |
//+------------------------------------------------------------------+
bool CWndCreate::CreateButtonsGroup(CButtonsGroup &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                    const int x, const int y, int &x_offset[], int &y_offset[], string &text[], int &width[],
                                    color &back_clr[], color &hover_clr[], color &pressed_clr[], const color label_clr, const color border_clr) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.RadioButtonsMode(false);
  object.RadioButtonsStyle(false);
  object.IsCenterText(true);
// --- Add buttons to the group
  int total =::ArraySize(x_offset);
  for(int i = 0; i < total; i++) {
    // --- First add a button
    object.AddButton(x_offset[i], y_offset[i], text[i], width[i], back_clr[i], hover_clr[i], pressed_clr[i]);
    // --- Set properties for the button
    object.GetButtonPointer(i).YSize(20);
    object.GetButtonPointer(i).LabelColor(label_clr);
    object.GetButtonPointer(i).LabelColorHover(label_clr);
    object.GetButtonPointer(i).LabelColorPressed(label_clr);
    object.GetButtonPointer(i).BorderColor(border_clr);
    object.GetButtonPointer(i).BorderColorHover(border_clr);
    object.GetButtonPointer(i).BorderColorPressed(border_clr);
  }
// --- Create a button group
  if(!object.CreateButtonsGroup(x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a color button |
//+------------------------------------------------------------------+
bool CWndCreate::CreateColorButton(CColorButton &object, const string text, CElement &main, const int window_index,
                                   const int x, const int y, const int xsize, const int button_x_size) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Properties
  object.XSize(xsize);
  object.GetButtonPointer().XSize(button_x_size);
  object.GetButtonPointer().AnchorRightWindowSide(true);
// --- Let's create an element
  if(!object.CreateColorButton(text, x, y))
    return(false);
// --- Add an object to the common array
  AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a color button |
//+------------------------------------------------------------------+
bool CWndCreate::CreateColorButton(CColorButton &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                                   const int x, const int y, const int xsize, const int button_x_size) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(xsize);
  object.GetButtonPointer().XSize(button_x_size);
  object.GetButtonPointer().AnchorRightWindowSide(true);
// --- Let's create an element
  if(!object.CreateColorButton(text, x, y))
    return(false);
// --- Add an object to the common array
  AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a color palette |
//+------------------------------------------------------------------+
bool CWndCreate::CreateColorPicker(CColorPicker &object, CElement &main, const int window_index, const int x, const int y) {
// --- Save pointer to main element
  object.MainPointer(main);
// --- Let's create an element
  if(!object.CreateColorPicker(x, y))
    return(false);
// --- Add an object to the common array
  AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates an area |
//+------------------------------------------------------------------+
bool CWndCreate::CreateFrame(CFrame &object, const string text, CElement &main, const int window_index,
                             const int x, const int y, const int x_size, const int y_size, const int label_x_size,
                             const bool is_right = false, const bool is_bottom = false, const int right_offset = 0, const int bottom_offset = 0) {
// --- Save the pointer to the window
  object.MainPointer(main);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.BorderColor(C'213,223,229');
  object.GetTextLabelPointer().XSize(label_x_size);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
  if(right_offset) {
    object.AutoXResizeMode(true);
    object.AutoXResizeRightOffset(right_offset);
  }
  if(bottom_offset) {
    object.AutoYResizeMode(true);
    object.AutoYResizeBottomOffset(bottom_offset);
  }
// --- Let's create a control
  if(!object.CreateFrame(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates an area |
//+------------------------------------------------------------------+
bool CWndCreate::CreateFrame(CFrame &object, const string text, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                             const int x, const int y, const int x_size, const int y_size, const int label_x_size,
                             const bool is_right = false, const bool is_bottom = false, const int right_offset = 0, const int bottom_offset = 0) {
// --- Save the pointer to the window
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.XSize(x_size);
  object.YSize(y_size);
  object.BorderColor(C'213,223,229');
  object.GetTextLabelPointer().XSize(label_x_size);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
  if(right_offset) {
    object.AutoXResizeMode(true);
    object.AutoXResizeRightOffset(right_offset);
  }
  if(bottom_offset) {
    object.AutoYResizeMode(true);
    object.AutoYResizeBottomOffset(bottom_offset);
  }
// --- Let's create a control
  if(!object.CreateFrame(text, x, y))
    return(false);
// --- Add an object to the common array
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a file navigator |
//+------------------------------------------------------------------+
bool CWndCreate::CreateFileNavigator(CFileNavigator &object, CElement &main, const int window_index, const int x, const int y,
                                     const int tree_view_x_size, const bool auto_x_resize, const int right_offset, const int visible_items_total,
                                     ENUM_FILE_NAVIGATOR_CONTENT content_mode = FN_BOTH, ENUM_FILE_NAVIGATOR_MODE navigator_mode = FN_ONLY_FOLDERS) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Properties
  object.NavigatorMode(navigator_mode);
  object.NavigatorContent(content_mode);
  object.TreeViewWidth(tree_view_x_size);
  object.AutoXResizeMode(auto_x_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.GetTreeViewPointer().VisibleItemsTotal(visible_items_total);
// ---Creating an element
  if(!object.CreateFileNavigator(x, y))
    return(false);
// --- Hide object
  object.Hide();
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a graph |
//+------------------------------------------------------------------+
bool CWndCreate::CreateGraph(CGraph &object, CElement &main, const int window_index,
                             const int x, const int y, const bool auto_x_resize, const bool auto_y_resize,
                             const int right_offset, const int bottom_offset, const bool is_right, const bool is_bottom,
                             ENUM_AXIS_TYPE axis_type, DoubleToStringFunction func_x_axis, DoubleToStringFunction func_y_axis) {
// --- Save the pointer to the main element
  object.MainPointer(main);
  
// --- Properties
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
  
// ---Creating an element
  if(!object.CreateGraph(x, y))
    return(false);
    
// --- Hide object
  object.Hide();
// --- Chart properties
  CGraphic *graph = object.GetGraphicPointer();
  graph.BackgroundMainSize(16);
  graph.BackgroundMain("");
  graph.BackgroundColor(::ColorToARGB(clrWhite));
  graph.IndentLeft(-15);
  graph.IndentRight(-5);
  graph.IndentUp(-5);
  graph.IndentDown(0);
  
// --- X-axis properties
  CAxis *x_axis = graph.XAxis();
  x_axis.AutoScale(false);
  x_axis.Min(0);
  x_axis.Max(1);
  x_axis.MaxGrace(0);
  x_axis.MinGrace(0);
  x_axis.NameSize(14);
  x_axis.Type(axis_type);
  x_axis.ValuesFunctionFormat(func_x_axis);
  
// --- Y-axis properties
  CAxis *y_axis = graph.YAxis();
  y_axis.MaxLabels(10);
  y_axis.ValuesWidth(60);
  y_axis.Type(axis_type);
  y_axis.ValuesFunctionFormat(func_y_axis);
  
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a graph |
//+------------------------------------------------------------------+
bool CWndCreate::CreateGraph(CGraph &object, CElement &main, const int window_index, CTabs &tabs, const int tab_index,
                             const int x, const int y, const bool auto_x_resize, const bool auto_y_resize,
                             const int right_offset, const int bottom_offset, const bool is_right, const bool is_bottom,
                             ENUM_AXIS_TYPE axis_type, DoubleToStringFunction func_x_axis, DoubleToStringFunction func_y_axis) {
// --- Save the pointer to the main element
  object.MainPointer(main);
// --- Pin to tab
  tabs.AddToElementsArray(tab_index, object);
// --- Properties
  object.AutoXResizeMode(auto_x_resize);
  object.AutoYResizeMode(auto_y_resize);
  object.AutoXResizeRightOffset(right_offset);
  object.AutoYResizeBottomOffset(bottom_offset);
  object.AnchorRightWindowSide(is_right);
  object.AnchorBottomWindowSide(is_bottom);
// ---Creating an element
  if(!object.CreateGraph(x, y))
    return(false);
// --- Hide object
  object.Hide();
// --- Chart properties
  CGraphic *graph = object.GetGraphicPointer();
  graph.BackgroundMainSize(16);
  graph.BackgroundMain("");
  graph.BackgroundColor(::ColorToARGB(clrWhite));
  graph.IndentLeft(-15);
  graph.IndentRight(-5);
  graph.IndentUp(-5);
  graph.IndentDown(0);
// --- X-axis properties
  CAxis *x_axis = graph.XAxis();
  x_axis.AutoScale(false);
  x_axis.Min(0);
  x_axis.Max(1);
  x_axis.MaxGrace(0);
  x_axis.MinGrace(0);
  x_axis.NameSize(14);
  x_axis.Type(axis_type);
  x_axis.ValuesFunctionFormat(func_x_axis);
// --- Y-axis properties
  CAxis *y_axis = graph.YAxis();
  y_axis.MaxLabels(10);
  y_axis.ValuesWidth(60);
  y_axis.Type(axis_type);
  y_axis.ValuesFunctionFormat(func_y_axis);
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
// | Creates a dividing line |
//+------------------------------------------------------------------+
bool CWndCreate::CreateSepLine(CSeparateLine &object, CElement &main, const int window_index,
                               const int x, const int y, const int x_size, const int y_size,
                               color dark_clr, color light_clr, ENUM_TYPE_SEP_LINE type_line) {
// --- Save the pointer to the window
  object.MainPointer(main);
// --- Properties
  object.DarkColor(dark_clr);
  object.LightColor(light_clr);
  object.TypeSepLine(type_line);
// --- Creating an element
  if(!object.CreateSeparateLine(x, y, x_size, y_size))
    return(false);
// --- Add a pointer to the element to the database
  CWndContainer::AddToElementsArray(window_index, object);
  return(true);
}
//+------------------------------------------------------------------+
