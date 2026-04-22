//+------------------------------------------------------------------+
//|                                                        Table.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Pointer.mqh"
#include "Scrolls.mqh"
#include "TextEdit.mqh"
#include "ComboBox.mqh"
//+------------------------------------------------------------------+
// | Class for creating a drawn table |
//+------------------------------------------------------------------+
class CTable : public CElement
  {
private:
   // --- Objects for creating a table
   CRectCanvas       m_headers;
   CRectCanvas       m_table;
   CScrollV          m_scrollv;
   CScrollH          m_scrollh;
   CTextEdit         m_edit;
   CComboBox         m_combobox;
   CPointer          m_column_resize;
   // --- Table cell properties
   struct CTCell
     {
      ENUM_TYPE_CELL    m_type;           // Cell type
      CImage            m_images[];       // Image array
      int               m_selected_image; // Index of the selected (displayed) picture
      string            m_full_text;      // Full text
      string            m_short_text;     // Short text
      string            m_value_list[];   // Array of values ​​(for cells with combo boxes)
      int               m_selected_item;  // Selected item in the combo box list
      color             m_text_color;     // Text color
      color             m_back_color;     // Background color
      uint              m_digits;         // Number of decimal places
     };
   // --- Array of rows and table column properties
   struct CTOptions
     {
      int               m_x;              // X-coordinate of the left edge of the column
      int               m_x2;             // X-coordinate of the right edge of the column
      int               m_width;          // Column width
      ENUM_DATATYPE     m_data_type;      // Column data type
      ENUM_ALIGN_MODE   m_text_align;     // How to align text in column cells
      int               m_text_x_offset;  // Text indentation
      int               m_image_x_offset; // Indent of the image from the X-edge of the cell
      int               m_image_y_offset; // Indent of the image from the Y-edge of the cell
      string            m_header_text;    // Column header text
      CTCell            m_rows[];         // Array of table rows
     };
   CTOptions         m_columns[];
   // --- Array of table row properties
   struct CTRowOptions
     {
      int               m_y;  // Y-coordinate of the top edge of the string
      int               m_y2; // Y-coordinate of the bottom edge of the line
     };
   CTRowOptions      m_rows[];
   // --- Number of rows and columns
   uint              m_rows_total;
   uint              m_columns_total;
   // --- Overall size and visible size of the table
   int               m_table_x_size;
   int               m_table_y_size;
   int               m_table_visible_x_size;
   int               m_table_visible_y_size;
   // --- Availability of cells with input fields and combo boxes
   bool              m_edit_state;
   bool              m_combobox_state;
   // --- Column and row indexes of the last edited cell
   int               m_last_edit_row_index;
   int               m_last_edit_column_index;
   // --- Minimum width for columns
   int               m_min_column_width;
   // --- Default values: (1) width, (2) data type, (3) text alignment
   int               m_default_width;
   ENUM_DATATYPE     m_default_type_data;
   ENUM_ALIGN_MODE   m_default_text_align;
   // --- Mesh color
   color             m_grid_color;
   // --- Table header display mode
   bool              m_show_headers;
   // --- Size (height) of headings
   int               m_header_y_size;
   // --- Color of headings (background) in different states
   color             m_headers_color;
   color             m_headers_color_hover;
   color             m_headers_color_pressed;
   // --- Heading text color
   color             m_headers_text_color;
   // --- Labels for the sorted data attribute
   CImage            m_sort_arrows[];
   // --- Indentation for the label indicating sorted data
   int               m_sort_arrow_x_gap;
   int               m_sort_arrow_y_gap;
   // --- Size (height) of cells
   int               m_cell_y_size;
   // --- Cell color in different states
   color             m_cell_color;
   color             m_cell_color_hover;
   // --- Color of (1) background and (2) text of the selected line
   color             m_selected_row_color;
   color             m_selected_row_text_color;
   // --- (1) Index and (2) text of the selected line
   int               m_selected_item;
   string            m_selected_item_text;
   // --- Index of the previous selected row
   int               m_prev_selected_item;
   // --- Indentation from the boundaries of the dividing lines to show the mouse pointer in the mode of changing the width of the columns
   int               m_sep_x_offset;
   // --- Line highlighting mode when hovering the mouse cursor
   bool              m_lights_hover;
   // --- Mode of sorting data by columns
   bool              m_is_sort_mode;
   // --- Index of the sorted column (WRONG_VALUE - the table is not sorted)
   int               m_is_sorted_column_index;
   // --- Last sort direction
   ENUM_CSORT_MODE   m_last_sort_direction;
   // --- Selected line mode
   bool              m_selectable_row;
   // --- Without deselecting a row when clicking again
   bool              m_is_without_deselect;
   // --- Zebra formatting mode
   color             m_is_zebra_format_rows;
   // --- State of the left mouse button (pressed/released)
   bool              m_mouse_state;
   // --- Timer counter for list rewind
   int               m_timer_counter;
   // --- To determine the focus of a row
   int               m_item_index_focus;
   // --- To determine the moment the mouse cursor moves from one line to another
   int               m_prev_item_index_focus;
   // --- To determine when the mouse cursor moves from one heading to another
   int               m_prev_header_index_focus;
   // --- Autosize columns
   bool              m_autoresize_columns;
   // --- Auto-column width mode (according to the maximum text width in the column)
   bool              m_auto_correct_columns_width_mode;
   // --- Column width changing mode
   bool              m_column_resize_mode;
   // --- Capture header border state to change column width
   int               m_column_resize_control;
   // --- Auxiliary fields for calculations in changing column widths
   int               m_column_resize_x_fixed;
   int               m_column_resize_prev_width;
   int               m_column_resize_prev_thumb;
   // --- To determine the indexes of the visible part of the table
   uint              m_visible_table_from_index;
   uint              m_visible_table_to_index;
   // --- Step size for horizontal offset
   int               m_shift_x_step;
   // --- Offset restrictions
   int               m_shift_x2_limit;
   int               m_shift_y2_limit;
   // ---Disable scroll bars
   bool              m_is_disabled_scrolls;
   //---
public:
                     CTable(void);
                    ~CTable(void);
   // --- Methods for creating a table
   bool              CreateTable(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateHeaders(void);
   bool              CreateTable(void);
   bool              CreateScrollV(void);
   bool              CreateScrollH(void);
   bool              CreateEdit(void);
   bool              CreateCombobox(void);
   bool              CreateColumnResizePointer(void);
   //---
public:
   // --- Returns pointers to elements
   CScrollV         *GetScrollVPointer(void)                 { return(::GetPointer(m_scrollv));  }
   CScrollH         *GetScrollHPointer(void)                 { return(::GetPointer(m_scrollh));  }
   CTextEdit        *GetTextEditPointer(void)                { return(::GetPointer(m_edit));     }
   CComboBox        *GetComboboxPointer(void)                { return(::GetPointer(m_combobox)); }
   // --- Returns the presence of elements (input field, combo box) in table cells
   bool              HasEditElements(void)             const { return(m_edit_state);             }
   bool              HasComboboxElements(void)         const { return(m_combobox_state);         }
   // --- Color of (1) grid and (2) table cells
   void              GridColor(const color clr)              { m_grid_color=clr;                 }
   void              CellColor(const color clr)              { m_cell_color=clr;                 }
   void              CellColorHover(const color clr)         { m_cell_color_hover=clr;           }
   // --- (1) Header display mode, height of (2) headers and (3) cells, (4) disable scroll bars
   void              ShowHeaders(const bool flag)            { m_show_headers=flag;              }
   void              HeaderYSize(const int y_size)           { m_header_y_size=y_size;           }
   void              CellYSize(const int y_size)             { m_cell_y_size=y_size;             }
   void              IsDisabledScrolls(const bool flag)      { m_is_disabled_scrolls=flag;       }
   // ---Colors of (1) background and (2) header text
   void              HeadersColor(const color clr)           { m_headers_color=clr;              }
   void              HeadersColorHover(const color clr)      { m_headers_color_hover=clr;        }
   void              HeadersColorPressed(const color clr)    { m_headers_color_pressed=clr;      }
   void              HeadersTextColor(const color clr)       { m_headers_text_color=clr;         }
   // --- Indents for the sorted table attribute
   void              SortArrowXGap(const int x_gap)          { m_sort_arrow_x_gap=x_gap;         }
   void              SortArrowYGap(const int y_gap)          { m_sort_arrow_y_gap=y_gap;         }
   // --- Setting images for sorted data attribute
   void              SortArrowFileAscend(const string path)  { m_sort_arrows[0].BmpPath(path);   }
   void              SortArrowFileDescend(const string path) { m_sort_arrows[1].BmpPath(path);   }
   // --- Returns the total number of (1) rows and (2) columns, (3) number of rows in the visible part of the table
   uint              RowsTotal(void)                   const { return(m_rows_total);             }
   uint              ColumnsTotal(void)                const { return(m_columns_total);          }
   int               VisibleRowsTotal(void);
   // --- Returns (1) the index and (2) the text of the selected row in the table
   int               SelectedItem(void)                const { return(m_selected_item);          }
   string            SelectedItemText(void)            const { return(m_selected_item_text);     }
   // --- Modes (1) row highlighting when hovering the mouse cursor, (2) sorted data mode
   void              LightsHover(const bool flag)            { m_lights_hover=flag;              }
   void              IsSortMode(const bool flag)             { m_is_sort_mode=flag;              }
   // --- Modes (1) line selection, (2) without deselecting when pressed again
   void              SelectableRow(const bool flag)          { m_selectable_row=flag;            }
   void              IsWithoutDeselect(const bool flag)      { m_is_without_deselect=flag;       }
   // --- (1) Zebra row format, (2) column width change mode, (3) Column Autosize mode, (4) column width auto-correction mode
   void              IsZebraFormatRows(const color clr)            { m_is_zebra_format_rows=clr; }
   void              ColumnResizeMode(const bool flag)             { m_column_resize_mode=flag;  }
   void              AutoResizeColumnsMode(const bool flag)        { m_autoresize_columns=flag;  }
   void              AutoCorrectColumnsWidthMode(const bool flag)  { m_auto_correct_columns_width_mode=flag; }
   // --- Autosize columns
   void              AutoResizeColumns(void);
   void              AutoCorrectWidthColumns(void);
   // --- Process of changing column widths
   bool              ColumnResizeControl(void) const { return(m_column_resize_control!=WRONG_VALUE); }

   // --- Returns the number of pictures in the specified cell
   int               ImagesTotal(const uint column_index,const uint row_index);
   // --- Minimum column width
   void              MinColumnWidth(const int width);
   // --- Default values: (1) width, (2) data type, (3) text alignment
   void              DefaultWidth(const int width)                 { m_default_width      =width; }
   void              DefaultTypeData(const ENUM_DATATYPE type)     { m_default_type_data  =type;  }
   void              DefaultTextAlign(const ENUM_ALIGN_MODE align) { m_default_text_align =align; }
   // --- Sets the main table size
   void              TableSize(const int columns_total,const int rows_total,const bool init=true);

   // --- Table reconstruction
   void              Rebuilding(const int columns_total,const int rows_total,const bool redraw=false);
   // --- Adds a column to the table at the specified index
   void              AddColumn(const int column_index,const bool redraw=false);
   // --- Deletes a column in a table at the specified index
   void              DeleteColumn(const int column_index,const bool redraw=false);
   // --- Adds a row to the table at the specified index
   void              AddRow(const int row_index,const bool redraw=false);
   // --- Deletes a row in the table at the specified index
   void              DeleteRow(const int row_index,const bool redraw=false);
   // ---Deletes all rows
   void              DeleteAllRows(const bool redraw=false);
   // --- Clears the table. There is only one column and one row left.
   void              Clear(const bool redraw=false);

   // --- (1) Set the text to the specified header, (2) get the text of the specified header, (3) get the headers into the passed array
   void              SetHeaderText(const uint column_index,const string value);
   string            GetHeaderText(const uint column_index);
   uint              GetHeadersText(string &headers[]);

   // --- Set (1) text alignment mode, (2) cell text indentation along X axis, and (3) width for each column
   void              TextAlign(const ENUM_ALIGN_MODE &array[]);
   void              TextAlign(const uint column_index,const ENUM_ALIGN_MODE align);
   void              TextXOffset(const int &array[]);
   void              ColumnsWidth(const int &array[]);
   // --- Image displacement along X- and Y-axes
   void              ImageXOffset(const int &array[]);
   void              ImageYOffset(const int &array[]);
   // --- Set/get data type
   void              DataType(const uint column_index,const ENUM_DATATYPE type);
   ENUM_DATATYPE     DataType(const uint column_index);
   // --- Set/get cell type
   void              CellType(const uint column_index,const uint row_index,const ENUM_TYPE_CELL type);
   ENUM_TYPE_CELL    CellType(const uint column_index,const uint row_index);
   // --- Installs pictures in the specified cell (path to resource)
   void              SetImages(const uint column_index,const uint row_index,const string &bmp_file_path[]);
   // --- Installs pictures in the specified cell (index to the resource)
   void              SetImages(const uint column_index,const uint row_index,const uint &resource_index[]);
   // --- (1) Changes/gets (index) the image in the specified cell, (2) returns the index of the current image, (3) returns the index of the selected item in the combo box list
   void              ChangeImage(const uint column_index,const uint row_index,const uint image_index,const bool redraw=false);
   int               SelectedImageIndex(const uint column_index,const uint row_index);
   int               SelectedComboboxItemIndex(const uint column_index,const uint row_index);
   // --- Sets the text color in the specified table cell
   void              TextColor(const uint column_index,const uint row_index,const color clr,const bool redraw=false);
   // --- (1) Sets and (2) returns the background color to/from the specified table cell(s)
   void              BackColor(const uint column_index,const uint row_index,const color clr,const bool redraw=false);
   color             BackColor(const uint column_index,const uint row_index);

   // --- Sets/gets the value in the specified table cell
   void              SetValue(const uint column_index,const uint row_index,const string value="",const uint digits=0,const bool redraw=false);
   string            GetValue(const uint column_index,const uint row_index);
   // --- Selecting a row in a table
   void              SelectRow(const int row_index);
   // --- Deselect
   void              DeselectRow(void) { m_selected_item=WRONG_VALUE; }
   // --- Add a list of values ​​to the combo box
   void              AddValueList(const uint column_index,const uint row_index,const string &array[],const uint selected_item=0);

   // --- Table scrolling: (1) vertical and (2) horizontal
   void              VerticalScrolling(const int pos=WRONG_VALUE);
   void              HorizontalScrolling(const int pos=WRONG_VALUE);
   // --- Table offset relative to scrollbar positions
   void              ShiftTable(void);

   // --- Sort data by specified column
   void              SortData(const uint column_index=0,const int direction=WRONG_VALUE);
   // --- (1) Current sorting direction, (2) index of the sorted array
   int               IsSortDirection(void)             const { return(m_last_sort_direction);    }
   int               IsSortedColumnIndex(void)         const { return(m_is_sorted_column_index); }
   // --- Reset sorting
   void              ResetSort(void) { m_is_sorted_column_index=WRONG_VALUE; }
   //---
public:
   // ---Changing the X-axis position of the table
   void              MovingX(const int x_gap);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Timer
   virtual void      OnEventTimer(void);
   // ---Move element
   virtual void      Moving(const bool only_visible=true);
   // --- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Delete(void);
   // --- (1) Installation, (2) reset priorities by pressing the left mouse button
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   // --- Item update
   virtual void      Update(const bool redraw=false);
   //---
private:
   // --- Handling clicks on header
   bool              OnClickHeaders(const string clicked_object);
   // --- Handling clicks on the table
   bool              OnClickTable(const string clicked_object);
   // --- Handling double clicks on the table
   bool              OnDoubleClickTable(const string clicked_object);
   // --- Handling the end of entering a value into a cell
   bool              OnEndEditCell(const int id);
   // --- Processing item selection in a cell drop-down list
   bool              OnClickComboboxItem(const int id);
   // --- Processing row selection
   bool              OnSelectRow(const int row_index);

   // --- Checking elements in cells for hiding
   void              CheckAndHideEdit(void);
   void              CheckAndHideCombobox(void);

   // --- Returns the index of the clicked row
   int               PressedRowIndex(void);
   // --- Returns the column index of the clicked cell
   int               PressedCellColumnIndex(void);

   // --- Checks whether an element in a cell was clicked when clicked
   bool              CheckCellElement(const int column_index,const int row_index,const bool double_click=false);
   // --- Checks whether a button in a cell has been clicked
   bool              CheckPressedButton(const int column_index,const int row_index,const bool double_click=false);
   // --- Checks whether a checkbox in a cell has been clicked
   bool              CheckPressedCheckBox(const int column_index,const int row_index,const bool double_click=false);
   // --- Checks whether a cell with an input field has been clicked
   bool              CheckPressedEdit(const int column_index,const int row_index,const bool double_click=false);
   // --- Checks whether there was a click on a cell with a combo box
   bool              CheckPressedCombobox(const int column_index,const int row_index,const bool double_click=false);
   //---
private:
   // --- Quick sort method
   void              QuickSort(uint beg,uint end,uint column,const ENUM_CSORT_MODE mode=SORT_ASCEND);
   // --- Checking the sort condition
   bool              CheckSortCondition(uint column_index,uint row_index,const string check_value,const bool direction);
   // --- Swap the values ​​in the specified cells
   void              Swap(uint r1,uint r2);

   // --- Calculates table sizes
   void              CalculateTableSize(void);
   // --- Calculate the full size of the table along the X and Y axis
   void              CalculateTableXSize(void);
   void              CalculateTableYSize(void);
   // --- Calculate the apparent size of the table along the X and Y axis
   void              CalculateTableVisibleXSize(void);
   void              CalculateTableVisibleYSize(void);

   // --- Change the main table dimensions
   void              ChangeMainSize(const int x_size,const int y_size);
   // --- Resize table
   void              ChangeTableSize(void);
   // --- Resize scrollbars
   void              ChangeScrollsSize(void);
   // --- Defining indexes of the visible table area
   void              VisibleTableIndexes(void);
   //---
private:
   // --- Returns the text
   string            Text(const int column_index,const int row_index);
   // --- Returns the X-coordinate of the text in the specified column
   int               TextX(const int column_index,const bool headers=false);
   // --- Returns how text is aligned in the specified column
   uint              TextAlign(const int column_index,const uint anchor);
   // --- Returns the text color of a cell
   uint              TextColor(const int column_index,const int row_index);
   // --- Returns the background color of a cell
   uint              BackColor(const int column_index,const int row_index);

   // --- Returns the current header background color
   uint              HeaderColorCurrent(const bool is_header_focus);
   // --- Returns the current background color of a row
   uint              RowColorCurrent(const int column_index,const int row_index,const bool is_row_focus);

   // --- Draws an element
   void              Draw(void);
   // --- Draws a table taking into account the latest changes made
   void              DrawTable(const bool only_visible=false);
   // --- Draws table headers
   void              DrawTableHeaders(void);
   // --- Draws headings
   void              DrawHeaders(void);
   // --- Draws a table header grid
   void              DrawHeadersGrid(void);
   // --- Draws a sign that the table can be sorted
   void              DrawSignSortedData(void);
   // --- Draws table header text
   void              DrawHeadersText(void);

   // --- Draws table row background
   void              DrawRows(void);
   // --- Draws the selected line
   void              DrawSelectedRow(void);
   // --- Draws a mesh
   void              DrawGrid(void);
   // --- Draws all table images
   void              DrawImages(void);
   // --- Draws an image in the specified cell
   void              DrawImage(const int column_index,const int row_index);
   // --- Draws text
   void              DrawText(void);

   // --- Redraws the specified table cell
   void              RedrawCell(const int column_index,const int row_index);
   // --- Draws the specified table row using the specified mode
   void              DrawRow(int &indexes[],const int item_index,const int prev_item_index,const bool is_user=true);
   // --- Redraws the specified table row using the specified mode
   void              RedrawRow(const bool is_selected_row=false);
   //---
private:
   // --- Checking focus on headings
   void              CheckHeaderFocus(void);
   // --- Checking focus on table rows
   int               CheckRowFocus(void);
   // --- Check for focus on heading borders to change their width
   void              CheckColumnResizeFocus(void);
   // --- Changes the width of the captured column
   void              ChangeColumnWidth(void);

   // --- Checks the size of the passed array and returns the adjusted value
   template<typename T>
   int               CheckArraySize(const T &array[]);
   // --- Check if columns are out of range
   bool              CheckOutOfColumnRange(const uint column_index);
   // --- Check for out of range columns and rows
   virtual bool      CheckOutOfRange(const uint column_index,const uint row_index);
   // --- Calculation taking into account the latest changes and changing the table size
   void              RecalculateAndResizeTable(const bool redraw=false);

   // --- Initialize the specified column with default values
   void              ColumnInitialize(const uint column_index);
   // --- Initialize the specified cell with default values
   void              CellInitialize(const uint column_index,const uint row_index);

   // --- Makes a copy of the specified column (source) to a new location (dest.)
   void              ColumnCopy(const uint destination,const uint source);
   // --- Makes a copy of the specified cell (source) to a new location (dest.)
   void              CellCopy(const uint column_dest,const uint row_dest,const uint column_source,const uint row_source);
   // --- Copies image data from one array to another
   void              ImageCopy(CImage &destination[],CImage &source[],const int index);
   //---
private:
   // --- Changes the color of table objects
   void              ChangeObjectsColor(void);
   // --- Changes the color of headers on mouseover
   void              ChangeHeadersColor(void);
   // --- Changing the color of rows on mouse hover
   void              ChangeRowsColor(void);

   // --- Returns adjusted text to fit the column width
   string            CorrectingText(const int column_index,const int row_index,const bool headers=false);

   // --- Fast forward table
   void              FastSwitching(void);

   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   // --- Change the height along the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTable::CTable(void) : m_rows_total(1),
                       m_columns_total(1),
                       m_edit_state(false),
                       m_combobox_state(false),
                       m_last_edit_row_index(WRONG_VALUE),
                       m_last_edit_column_index(WRONG_VALUE),
                       m_shift_x_step(10),
                       m_shift_x2_limit(0),
                       m_shift_y2_limit(0),
                       m_show_headers(false),
                       m_header_y_size(20),
                       m_cell_y_size(20),
                       m_default_text_align(ALIGN_CENTER),
                       m_default_width(100),
                       m_default_type_data(TYPE_STRING),
                       m_min_column_width(30),
                       m_grid_color(clrLightGray),
                       m_headers_color(C'255,244,213'),
                       m_headers_color_hover(C'229,241,251'),
                       m_headers_color_pressed(C'204,228,247'),
                       m_headers_text_color(clrBlack),
                       m_is_disabled_scrolls(false),
                       m_is_sort_mode(false),
                       m_last_sort_direction(SORT_ASCEND),
                       m_is_sorted_column_index(WRONG_VALUE),
                       m_sort_arrow_x_gap(10),
                       m_sort_arrow_y_gap(8),
                       m_cell_color(clrWhite),
                       m_cell_color_hover(C'229,243,255'),
                       m_prev_selected_item(WRONG_VALUE),
                       m_selected_item(WRONG_VALUE),
                       m_selected_item_text(""),
                       m_sep_x_offset(5),
                       m_lights_hover(false),
                       m_selectable_row(false),
                       m_is_without_deselect(false),
                       m_autoresize_columns(false),
                       m_auto_correct_columns_width_mode(false),
                       m_column_resize_mode(false),
                       m_column_resize_control(WRONG_VALUE),
                       m_column_resize_x_fixed(0),
                       m_column_resize_prev_width(0),
                       m_column_resize_prev_thumb(0),
                       m_item_index_focus(WRONG_VALUE),
                       m_prev_item_index_focus(WRONG_VALUE),
                       m_prev_header_index_focus(WRONG_VALUE),
                       m_selected_row_color(C'51,153,255'),
                       m_selected_row_text_color(clrWhite),
                       m_is_zebra_format_rows(clrNONE),
                       m_visible_table_from_index(WRONG_VALUE),
                       m_visible_table_to_index(WRONG_VALUE)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
// ---Default text color
   m_label_color=clrBlack;
// --- Set the table size
   TableSize(m_columns_total,m_rows_total);
// --- Initializing the sorting attribute structure
   ::ArrayResize(m_sort_arrows,2);
   m_sort_arrows[0].BmpPath("");
   m_sort_arrows[1].BmpPath("");
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTable::~CTable(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CTable::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- If the scrollbar is in effect
      if(m_scrollv.ScrollBarControl())
        {
         ShiftTable();
         m_scrollv.Update(true);
         return;
        }
      // --- If the scrollbar is in effect
      if(m_scrollh.ScrollBarControl())
        {
         ShiftTable();
         m_scrollh.Update(true);
         return;
        }
      // --- Quit if scrollbar is activated
      if(m_scrollh.State() || m_scrollv.State())
         return;
      // --- Checking focus on elements
      m_headers.MouseFocus(m_mouse.X()>m_headers.X() && m_mouse.X()<m_headers.X2() && 
                           m_mouse.Y()>m_headers.Y() && m_mouse.Y()<m_headers.Y2());
      m_table.MouseFocus(m_mouse.X()>m_table.X() && m_mouse.X()<m_table.X2() && 
                         m_mouse.Y()>m_table.Y() && m_mouse.Y()<m_table.Y2());
      // --- Changing the color of objects
      ChangeObjectsColor();
      // --- Change the width of the captured column
      ChangeColumnWidth();
      return;
     }
// --- Handling mouse wheel event
   if(id==CHARTEVENT_MOUSE_WHEEL)
     {
      // --- If the cursor is in the table
      if(m_table.MouseFocus())
        {
         // --- Get the current scrollbar position
         int pos=(m_scrollv.CurrentPos()-1<0)? 1 : m_scrollv.CurrentPos();
         // --- If the mouse wheel has moved down
         if(dparam<0)
            VerticalScrolling(pos+1);
         // --- If the mouse wheel has moved up
         else if(dparam>0)
            VerticalScrolling(pos-1);
         // --- Refresh scrollbar
         m_scrollv.Update(true);
        }
      return;
     }
// --- Handling clicks on objects
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      // --- Click on title
      if(OnClickHeaders(sparam))
         return;
      // --- Click on the table
      if(OnClickTable(sparam))
         return;
      //---
      return;
     }
// --- Handling end of input event
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      if(OnEndEditCell((int)lparam))
         return;
      //---
      return;
     }
// --- Handling the event of selecting an item in the list
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      if(OnClickComboboxItem((int)lparam))
         return;
      //---
      return;
     }
// --- Handling click events on scrollbar buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      // --- Quit if this is a click on the combo box button
      if(m_combobox.CheckElementName(sparam))
         return;
      // --- Quit if the click is not on a scroll bar button
      if(!m_scrollv.GetIncButtonPointer().CheckElementName(sparam))
         return;
      // --- If there was a click on the vertical scroll bar buttons
      if(m_scrollv.OnClickScrollInc((uint)lparam,(uint)dparam) ||
         m_scrollv.OnClickScrollDec((uint)lparam,(uint)dparam))
        {
         // --- Shifts data
         ShiftTable();
         m_scrollv.Update(true);
         return;
        }
      // --- If there was a click on the horizontal scroll bar buttons of the list
      if(m_scrollh.OnClickScrollInc((uint)lparam,(uint)dparam) ||
         m_scrollh.OnClickScrollDec((uint)lparam,(uint)dparam))
        {
         // --- Shifts data
         ShiftTable();
         m_scrollh.Update(true);
         return;
        }
     }
// --- Changing the state of the left mouse button
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_MOUSE_LEFT_BUTTON)
     {
      // --- Checking the input field in cells for hiding
      CheckAndHideEdit();
      // --- Checking the combo box in cells for hiding
      CheckAndHideCombobox();
      // --- Quit if headers are disabled
      if(!m_show_headers)
         return;
      // --- If the left mouse button is released
      if(m_column_resize_control!=WRONG_VALUE && !m_mouse.LeftButtonState())
        {
         // --- Reset width mode
         m_column_resize_control=WRONG_VALUE;
         // --- Redraw the table
         DrawTable();
         Update();
         // --- Hide pointer
         m_column_resize.Hide();
         // --- Send a message to determine available elements
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
      // --- Reset last focus title index
      m_prev_header_index_focus=WRONG_VALUE;
      // --- Changing the color of objects
      ChangeObjectsColor();
      return;
     }
// --- Handling double-click of the left mouse button
   if(id==CHARTEVENT_CUSTOM+ON_DOUBLE_CLICK)
     {
      // --- Exit if the combo box is present and shown
      if(m_combobox_state && m_combobox.IsVisible())
         return;
      // --- Click on the table
      if(OnDoubleClickTable(sparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void CTable::OnEventTimer(void)
  {
// --- Fast forward values
   FastSwitching();
  }
//+------------------------------------------------------------------+
// | Creates a drawn table |
//+------------------------------------------------------------------+
bool CTable::CreateTable(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// --- Calculate the size of the table
   CalculateTableSize();
// ---Creating an element
   if(!CreateCanvas())
      return(false);
   if(!CreateTable())
      return(false);
   if(!CreateHeaders())
      return(false);
   if(!CreateScrollV())
      return(false);
   if(!CreateScrollH())
      return(false);
   if(!CreateEdit())
      return(false);
   if(!CreateCombobox())
      return(false);
   if(!CreateColumnResizePointer())
      return(false);
// --- Resize table
   ChangeTableSize();
   return(true);
  }
//+------------------------------------------------------------------+
// | Changing the X-axis position of the table |
//+------------------------------------------------------------------+
void CTable::MovingX(const int x_gap)
  {
   m_x=CElement::CalculateX(x_gap);
   CElementBase::XGap(x_gap);
//---
   m_canvas.X(m_x);
   m_canvas.XGap(CElement::CalculateXGap(m_x));
//---
   int x=m_x+1;
   m_table.X(x);
   m_table.XGap(CElement::CalculateXGap(x));
//---
   m_headers.X(x);
   m_headers.XGap(CElement::CalculateXGap(x));
//---
   CElement::Moving();
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CTable::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
   m_x_size   =(m_x_size<1 || m_auto_xresize_mode)? (m_anchor_right_window_side)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size   =(m_y_size<1 || m_auto_yresize_mode)? (m_anchor_bottom_window_side)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
// ---Default properties
   m_back_color          =(m_back_color!=clrNONE)? m_back_color : clrWhite;
   m_label_color         =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_color_hover   =(m_label_color_hover!=clrNONE)? m_label_color_hover : clrBlack;
   m_label_color_pressed =(m_label_color_pressed!=clrNONE)? m_label_color_pressed : clrWhite;
   m_border_color        =(m_border_color!=clrNONE)? m_border_color : C'150,170,180';
   m_icon_x_gap          =(m_icon_x_gap>0)? m_icon_x_gap : 3;
   m_icon_y_gap          =(m_icon_y_gap>0)? m_icon_y_gap : 2;
   m_label_x_gap         =(m_label_x_gap>0)? m_label_x_gap : 5;
   m_label_y_gap         =(m_label_y_gap>0)? m_label_y_gap : 4;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates a background for a table |
//+------------------------------------------------------------------+
bool CTable::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("table");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a table |
//+------------------------------------------------------------------+
bool CTable::CreateTable(void)
  {
// --- Formation of object name
   string name=CElementBase::ProgramName()+"_"+"table_grid"+"_"+(string)CElementBase::Id();
// --- Coordinates
   int x =m_x+1;
   int y =m_y+((m_show_headers)? m_header_y_size : 1);
// ---Create an object
   ::ResetLastError();
   if(!m_table.CreateBitmapLabel(m_chart_id,m_subwin,name,x,y,m_table_x_size,m_header_y_size,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось создать холст для рисования таблицы: ",::GetLastError());
      return(false);
     }
// --- Get a pointer to the base class
   if(!m_table.Attach(m_chart_id,name,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось присоединить холст для рисования к графику: ",::GetLastError());
      return(false);
     }
// --- Properties
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
   ::ObjectSetString(m_chart_id,m_table.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
// --- Coordinates
   m_table.X(x);
   m_table.Y(y);
// --- Let's save the dimensions
   m_table.XSize(m_table_visible_x_size);
   m_table.YSize(m_table_visible_y_size);
// --- Indents from the extreme point of the panel
   m_table.XGap(CElement::CalculateXGap(x));
   m_table.YGap(CElement::CalculateYGap(y));
// --- Set the size of the visible area
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_XSIZE,m_table_visible_x_size);
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YSIZE,m_table_visible_y_size);
// --- Set the offset of the frame inside the image along the X and Y axes
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_XOFFSET,0);
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YOFFSET,0);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates table headers |
//+------------------------------------------------------------------+
bool CTable::CreateHeaders(void)
  {
// --- Quit if headers are disabled
   if(!m_show_headers)
      return(true);
// --- Formation of object name
   string name=CElementBase::ProgramName()+"_"+"table_headers"+"_"+(string)CElementBase::Id();
// --- Coordinates
   int x =m_x+1;
   int y =m_y+1;
// --- Let's define pictures as a sign of the possibility of sorting the table
   ::ArrayResize(m_sort_arrows,2);
   if(m_sort_arrows[0].ResourceIndex()==INT_MAX)
      m_sort_arrows[0].ResourceIndex(RESOURCE_SPIN_INC);
   if(m_sort_arrows[1].ResourceIndex()==INT_MAX)
      m_sort_arrows[1].ResourceIndex(RESOURCE_SPIN_DEC);
// --- Save images to arrays
   for(int i=0; i<2; i++)
      m_sort_arrows[i].ReadImageData(m_sort_arrows[i].ResourceIndex());
// ---Create an object
   ::ResetLastError();
   if(!m_headers.CreateBitmapLabel(m_chart_id,m_subwin,name,x,y,m_table_x_size,m_header_y_size,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось создать холст для рисования заголовков таблицы: ",::GetLastError());
      return(false);
     }
// --- Get a pointer to the base class
   if(!m_headers.Attach(m_chart_id,name,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось присоединить холст для рисования к графику: ",::GetLastError());
      return(false);
     }
// --- Properties
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
   ::ObjectSetString(m_chart_id,m_headers.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
// --- Coordinates
   m_headers.X(x);
   m_headers.Y(y);
// --- Let's save the dimensions
   m_headers.XSize(m_table_visible_x_size);
   m_headers.YSize(m_header_y_size);
// --- Indents from the extreme point of the panel
   m_headers.XGap(CElement::CalculateXGap(x));
   m_headers.YGap(CElement::CalculateYGap(y));
// --- Set the size of the visible area
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_XSIZE,m_table_visible_x_size);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_YSIZE,m_header_y_size);
// --- Set the offset of the frame inside the image along the X and Y axes
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_XOFFSET,0);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_YOFFSET,0);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a vertical scroll |
//+------------------------------------------------------------------+
bool CTable::CreateScrollV(void)
  {
// --- Save parent pointer
   m_scrollv.MainPointer(this);
// --- Coordinates
   int x=16,y=1;
// --- Properties
   m_scrollv.Index(0);
   m_scrollv.XSize(15);
   m_scrollv.YSize(CElementBase::YSize()-2);
   m_scrollv.AnchorRightWindowSide(true);
   m_scrollv.Alpha(m_alpha);
// --- Calculation of the number of steps for displacement
   uint rows_total         =RowsTotal();
   uint visible_rows_total =VisibleRowsTotal();
// --- Creating a scrollbar
   if(!m_scrollv.CreateScroll(x,y,rows_total,visible_rows_total))
      return(false);
// --- Hide if not needed now
   if(!m_scrollv.IsScroll() || m_is_disabled_scrolls)
      m_scrollv.Hide();
// --- Add element to array
   CElement::AddToArray(m_scrollv);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a horizontal scroll |
//+------------------------------------------------------------------+
bool CTable::CreateScrollH(void)
  {
// --- Save pointer to main element
   m_scrollh.MainPointer(this);
// --- Coordinates
   int x=1,y=16;
// --- Properties
   m_scrollh.Index(1);
   m_scrollh.XSize(CElementBase::XSize()-2);
   m_scrollh.YSize(15);
   m_scrollh.AnchorBottomWindowSide(true);
   m_scrollh.Alpha(m_alpha);
// --- Calculation of the number of steps for displacement
   uint x_size_total         =m_table_x_size/m_shift_x_step;
   uint visible_x_size_total =m_table_visible_x_size/m_shift_x_step;
// --- Creating a scrollbar
   if(!m_scrollh.CreateScroll(x,y,x_size_total,visible_x_size_total))
      return(false);
// --- Hide if not needed now
   if(!m_scrollh.IsScroll() || m_is_disabled_scrolls)
      m_scrollh.Hide();
// --- Add element to array
   CElement::AddToArray(m_scrollh);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates an input field |
//+------------------------------------------------------------------+
bool CTable::CreateEdit(void)
  {
// --- If there are no cells with an input field
   if(!m_edit_state)
      return(true);
// --- Save the pointer to the main element
   m_edit.MainPointer(this);
// --- Coordinates
   int x=-1,y=0;
// --- Properties
   m_edit.Alpha(0);
   m_edit.XSize(50);
   m_edit.YSize(21);
   m_edit.SetValue("");
   m_edit.GetTextBoxPointer().XGap(1);
   m_edit.GetTextBoxPointer().XSize(50);
   m_edit.GetTextBoxPointer().TextYOffset(4);
   m_edit.GetTextBoxPointer().AutoSelectionMode(true);
// --- Let's create a control
   if(!m_edit.CreateTextEdit("",x,y))
      return(false);
// --- Hide
   m_edit.Hide();
// --- Add element to array
   CElement::AddToArray(m_edit);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a combo box |
//+------------------------------------------------------------------+
bool CTable::CreateCombobox(void)
  {
// --- If there are no cells with a combo box
   if(!m_combobox_state)
      return(true);
// --- Save the pointer to the main element
   m_combobox.MainPointer(this);
// --- Coordinates
   int x=-1,y=0;
// --- Properties
   m_combobox.Alpha(0);
   m_combobox.XSize(50);
   m_combobox.YSize(21);
   m_combobox.ItemsTotal(5);
   m_combobox.GetButtonPointer().XGap(1);
   m_combobox.GetButtonPointer().LabelYGap(4);
   m_combobox.GetButtonPointer().IconYGap(3);
   m_combobox.IsDropdown(CElementBase::IsDropdown());
// --- Get a pointer to the list
   CListView *lv=m_combobox.GetListViewPointer();
// --- Set list properties
   lv.YSize(93);
   lv.LightsHover(true);
   lv.GetScrollVPointer().Index(2);
// --- Add the values ​​to the list
   for(int i=0; i<5; i++)
      m_combobox.SetValue(i,(string)i);
// --- Select the first item in the list
   m_combobox.SelectItem(0);
// --- Let's create a control
   if(!m_combobox.CreateComboBox("",x,y))
      return(false);
// --- Hide
   m_combobox.Hide();
// --- Add element to array
   CElement::AddToArray(m_combobox);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a cursor pointer for changing column widths |
//+------------------------------------------------------------------+
bool CTable::CreateColumnResizePointer(void)
  {
// --- Exit if column width change mode is disabled
   if(!m_column_resize_mode)
     {
      m_column_resize.State(false);
      m_column_resize.IsVisible(false);
      return(true);
     }
// --- Properties
   m_column_resize.XGap(13);
   m_column_resize.YGap(14);
   m_column_resize.XSize(20);
   m_column_resize.YSize(20);
   m_column_resize.Id(CElementBase::Id());
   m_column_resize.Type(MP_X_RESIZE_RELATIVE);
// ---Creating an element
   if(!m_column_resize.CreatePointer(m_chart_id,m_subwin))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns the number of visible rows |
//+------------------------------------------------------------------+
int CTable::VisibleRowsTotal(void)
  {
   double visible_rows_total =m_table_visible_y_size/m_cell_y_size;
   double check_y_size       =visible_rows_total*m_cell_y_size;
   visible_rows_total=(check_y_size<m_table_visible_y_size-1)? visible_rows_total-1 : visible_rows_total;
   return((int)visible_rows_total);
  }
//+------------------------------------------------------------------+
// | Returns the number of images in the specified cell |
//+------------------------------------------------------------------+
int CTable::ImagesTotal(const uint column_index,const uint row_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return(WRONG_VALUE);
// --- Return the size of the image array
   return(::ArraySize(m_columns[column_index].m_rows[row_index].m_images));
  }
//+------------------------------------------------------------------+
// | Minimum column width |
//+------------------------------------------------------------------+
void CTable::MinColumnWidth(const int width)
  {
// --- Column width at least 3 pixels
   m_min_column_width=(width>3)? width : 3;
  }
//+------------------------------------------------------------------+
// | Sets the table size |
//+------------------------------------------------------------------+
void CTable::TableSize(const int columns_total,const int rows_total,const bool init=true)
  {
// --- Must have at least one column
   m_columns_total=(columns_total<1)? 1 : columns_total;
// --- There must be at least two rows
   m_rows_total=(rows_total<1)? 1 : rows_total;
// --- Set size for arrays of rows, columns and headers
   ::ArrayResize(m_rows,m_rows_total);
   ::ArrayResize(m_columns,m_columns_total);
// --- Quit if default initialization is not needed
   if(!init)
      return;
// --- Set size of table arrays
   for(uint c=0; c<m_columns_total; c++)
     {
      ::ArrayResize(m_columns[c].m_rows,m_rows_total);
      // ---Initialize column properties to default values
      ColumnInitialize(c);
      // --- Initializing cell properties
      for(uint r=0; r<m_rows_total; r++)
         CellInitialize(c,r);
     }
  }
//+------------------------------------------------------------------+
// | Reconstruction of the table |
//+------------------------------------------------------------------+
void CTable::Rebuilding(const int columns_total,const int rows_total,const bool redraw=false)
  {
   m_selected_item      =WRONG_VALUE;
   m_prev_selected_item =WRONG_VALUE;
// --- Set new size
   TableSize(columns_total,rows_total);
// --- Calculate and set new table dimensions
   RecalculateAndResizeTable(redraw);
  }
//+------------------------------------------------------------------+
// | Adds a column to the table at the specified index |
//+------------------------------------------------------------------+
void CTable::AddColumn(const int column_index,const bool redraw=false)
  {
// --- Increase the size of the array by one element
   int array_size=(int)ColumnsTotal();
   m_columns_total=array_size+1;
   ::ArrayResize(m_columns,m_columns_total);
// --- Set size to arrays of rows
   ::ArrayResize(m_columns[array_size].m_rows,m_rows_total);
// --- Index adjustment in case of out of range
   int checked_column_index=(column_index>=(int)m_columns_total)?(int)m_columns_total-1 : column_index;
// --- Shift other columns (move from the end of the array to the index of the column to be added)
   for(int c=array_size; c>=checked_column_index; c--)
     {
      // --- Shift attribute of sorted array
      if(c==m_is_sorted_column_index && m_is_sorted_column_index!=WRONG_VALUE)
         m_is_sorted_column_index++;
      // --- Index of the previous column
      int prev_c=c-1;
      // --- In the new column, initialization with default values
      if(c==checked_column_index)
         ColumnInitialize(c);
      // --- Move data from the previous column to the current one
      else
         ColumnCopy(c,prev_c);
      //---
      for(uint r=0; r<m_rows_total; r++)
        {
         // --- Initialize the cells of a new column with default values
         if(c==checked_column_index)
           {
            CellInitialize(c,r);
            continue;
           }
         // --- Move data from a cell in the previous column to a cell in the current one
         CellCopy(c,r,prev_c,r);
        }
     }
// --- Calculate and set new table dimensions
   RecalculateAndResizeTable(redraw);
  }
//+------------------------------------------------------------------+
// | Deletes a column in a table at the specified index |
//+------------------------------------------------------------------+
void CTable::DeleteColumn(const int column_index,const bool redraw=false)
  {
// --- Get the size of the column array
   int array_size=(int)ColumnsTotal();
// --- Exit if there is only one column left
   if(array_size<2)
      return;
// --- Index adjustment in case of out of range
   int checked_column_index=(column_index>=array_size)? array_size-1 : column_index;
// --- Shift other columns (move from the specified index to the last column)
   for(int c=checked_column_index; c<array_size-1; c++)
     {
      // --- Shift attribute of sorted array
      if(c!=checked_column_index)
        {
         if(c==m_is_sorted_column_index && m_is_sorted_column_index!=WRONG_VALUE)
            m_is_sorted_column_index--;
        }
      // --- Reset to zero if sorted column is removed
      else
         m_is_sorted_column_index=WRONG_VALUE;
      // --- Next column index
      int next_c=c+1;
      // --- Move data from the next column to the current one
      ColumnCopy(c,next_c);
      // --- Move data from the cells of the next column to the cells of the current one
      for(uint r=0; r<m_rows_total; r++)
         CellCopy(c,r,next_c,r);
     }
// --- Reduce the column array by one element
   m_columns_total=array_size-1;
   ::ArrayResize(m_columns,m_columns_total);
// --- Calculate and set new table dimensions
   RecalculateAndResizeTable(redraw);
  }
//+------------------------------------------------------------------+
// | Adds a row to the table at the specified index |
//+------------------------------------------------------------------+
void CTable::AddRow(const int row_index,const bool redraw=false)
  {
// --- Increase the size of the array by one element
   int array_size=(int)RowsTotal();
   m_rows_total=array_size+1;
// --- Set size to arrays of rows
   for(uint i=0; i<m_columns_total; i++)
     {
      ::ArrayResize(m_rows,m_rows_total,100000);
      ::ArrayResize(m_columns[i].m_rows,m_rows_total,100000);
     }
// --- Index adjustment in case of out of range
   int checked_row_index=(row_index>=(int)m_rows_total)?(int)m_rows_total-1 : row_index;
// --- Shift other rows (we move from the end of the array to the index of the added row)
   for(int c=0; c<(int)m_columns_total; c++)
     {
      for(int r=array_size; r>=checked_row_index; r--)
        {
         // ---Initializing a new row cell with default values
         if(r==checked_row_index)
           {
            CellInitialize(c,r);
            continue;
           }
         // --- Index of previous row
         uint prev_r=r-1;
         // --- Move data from the cell of the previous row to the cell of the current one
         CellCopy(c,r,c,prev_r);
        }
     }
// --- Calculate and set new table dimensions
   if(redraw)
      RecalculateAndResizeTable(redraw);
  }
//+------------------------------------------------------------------+
// | Deletes a row in a table at the specified index |
//+------------------------------------------------------------------+
void CTable::DeleteRow(const int row_index,const bool redraw=false)
  {
// --- Get the size of the string array
   int array_size=(int)RowsTotal();
// --- Quit if there is only one line left
   if(array_size<2)
      return;
// --- Index adjustment in case of out of range
   int checked_row_index=(row_index>=(int)m_rows_total)?(int)m_rows_total-1 : row_index;
// --- Shift other rows (move from the specified index to the last row)
   for(int c=0; c<(int)m_columns_total; c++)
     {
      for(int r=checked_row_index; r<array_size-1; r++)
        {
         // --- Next line index
         uint next_r=r+1;
         // --- Move data from the cell of the next row to the cell of the current one
         CellCopy(c,r,c,next_r);
        }
     }
// --- Reduce the size of the string array by one element
   m_rows_total=array_size-1;
// --- Set size to arrays of rows
   for(uint i=0; i<m_columns_total; i++)
     {
      ::ArrayResize(m_rows,m_rows_total);
      ::ArrayResize(m_columns[i].m_rows,m_rows_total);
     }
// --- Calculate and set new table dimensions
   RecalculateAndResizeTable(redraw);
  }
//+------------------------------------------------------------------+
// | Removes all lines |
//+------------------------------------------------------------------+
void CTable::DeleteAllRows(const bool redraw=false)
  {
// --- Set dimension
   TableSize(m_columns_total,1,false);
// --- Clear cells
   for(uint i=0; i<m_columns_total; i++)
     {
      m_columns[i].m_data_type=TYPE_STRING;
      SetValue(i,0,"");
      BackColor(i,0,clrWhite);
     }
// --- Set default values
   m_selected_item_text     ="";
   m_selected_item          =WRONG_VALUE;
   m_last_sort_direction    =SORT_ASCEND;
   m_is_sorted_column_index =WRONG_VALUE;
// --- Calculate and set new table dimensions
   RecalculateAndResizeTable(redraw);
  }
//+------------------------------------------------------------------+
// | Clears the table. There is only one column and one row left.     |
//+------------------------------------------------------------------+
void CTable::Clear(const bool redraw=false)
  {
// --- Set minimum size to 1x1
   TableSize(1,1);
// --- Set default values
   m_selected_item_text     ="";
   m_selected_item          =WRONG_VALUE;
   m_last_sort_direction    =SORT_ASCEND;
   m_is_sorted_column_index =WRONG_VALUE;
// --- Calculate and set new table dimensions
   RecalculateAndResizeTable(redraw);
  }
//+------------------------------------------------------------------+
// | Fills the headers array at the specified index |
//+------------------------------------------------------------------+
void CTable::SetHeaderText(const uint column_index,const string value)
  {
// --- Check for out-of-range columns
   if(!CheckOutOfColumnRange(column_index))
      return;
// --- Set value to array
   m_columns[column_index].m_header_text=value;
  }
//+------------------------------------------------------------------+
// | Getting the text of the specified title |
//+------------------------------------------------------------------+
string CTable::GetHeaderText(const uint column_index)
  {
// --- Check for out-of-range columns
   if(!CheckOutOfColumnRange(column_index))
      return("");
// --- Set value to array
   return(m_columns[column_index].m_header_text);
  }
//+------------------------------------------------------------------+
// | Receiving headers into the passed array |
//+------------------------------------------------------------------+
uint CTable::GetHeadersText(string &headers[])
  {
   int columns_total=::ArraySize(m_columns);
   ::ArrayResize(headers,columns_total);
   for(int c=0; c<columns_total; c++)
      headers[c]=m_columns[c].m_header_text;
// --- Return the number of titles
   return(columns_total);
  }
//+------------------------------------------------------------------+
// | Fills an array with text alignment mode |
//+------------------------------------------------------------------+
void CTable::TextAlign(const ENUM_ALIGN_MODE &array[])
  {
   int total=0;
// --- Exit if a zero-size array is passed
   if((total=CheckArraySize(array))==WRONG_VALUE)
      return;
// --- Save values ​​in structure
   for(int c=0; c<total; c++)
      m_columns[c].m_text_align=array[c];
  }
//+------------------------------------------------------------------+
// | Fills an array with text alignment mode |
//+------------------------------------------------------------------+
void CTable::TextAlign(const uint column_index,const ENUM_ALIGN_MODE align)
  {
// --- Check for out-of-range columns
   if(!CheckOutOfColumnRange(column_index))
      return;
// --- Set the alignment method for the specified column
   m_columns[column_index].m_text_align=align;
  }
//+------------------------------------------------------------------+
// | Fills an array of text indentation in a cell along the X axis |
//+------------------------------------------------------------------+
void CTable::TextXOffset(const int &array[])
  {
   int total=0;
// --- Exit if a zero-size array is passed
   if((total=CheckArraySize(array))==WRONG_VALUE)
      return;
// --- Save values ​​in structure
   for(int c=0; c<total; c++)
      m_columns[c].m_text_x_offset=array[c];
  }
//+------------------------------------------------------------------+
// | Fills an array of column widths |
//+------------------------------------------------------------------+
void CTable::ColumnsWidth(const int &array[])
  {
   int total=0;
// --- Exit if a zero-size array is passed
   if((total=CheckArraySize(array))==WRONG_VALUE)
      return;
// --- Save values ​​in structure
   for(int c=0; c<total; c++)
      m_columns[c].m_width=array[c];
  }
//+------------------------------------------------------------------+
// | Indents of pictures from the edges of cells along the X axis |
//+------------------------------------------------------------------+
void CTable::ImageXOffset(const int &array[])
  {
   int total=0;
// --- Exit if a zero-size array is passed
   if((total=CheckArraySize(array))==WRONG_VALUE)
      return;
// --- Save values ​​in structure
   for(int c=0; c<total; c++)
      m_columns[c].m_image_x_offset=array[c];
  }
//+------------------------------------------------------------------+
// | Indents of pictures from the edges of cells along the Y axis |
//+------------------------------------------------------------------+
void CTable::ImageYOffset(const int &array[])
  {
   int total=0;
// --- Exit if a zero-size array is passed
   if((total=CheckArraySize(array))==WRONG_VALUE)
      return;
// --- Save values ​​in structure
   for(int c=0; c<total; c++)
      m_columns[c].m_image_y_offset=array[c];
  }
//+------------------------------------------------------------------+
// | Setting the data type in the specified column |
//+------------------------------------------------------------------+
void CTable::DataType(const uint column_index,const ENUM_DATATYPE type)
  {
// --- Check for out-of-range columns
   if(!CheckOutOfColumnRange(column_index))
      return;
// --- Set the data type for the specified column
   m_columns[column_index].m_data_type=type;
  }
//+------------------------------------------------------------------+
// | Getting the data type in the specified column |
//+------------------------------------------------------------------+
ENUM_DATATYPE CTable::DataType(const uint column_index)
  {
// --- Check for out-of-range columns
   if(!CheckOutOfColumnRange(column_index))
      return(WRONG_VALUE);
// --- Return the data type for the specified column
   return(m_columns[column_index].m_data_type);
  }
//+------------------------------------------------------------------+
// | Sets the cell type |
//+------------------------------------------------------------------+
void CTable::CellType(const uint column_index,const uint row_index,const ENUM_TYPE_CELL type)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Set cell type
   m_columns[column_index].m_rows[row_index].m_type=type;
// --- Indicator of the presence of an input field
   if(type==CELL_EDIT && !m_edit_state)
      m_edit_state=true;
// --- Indication of the presence of a combo box
   else if(type==CELL_COMBOBOX && !m_combobox_state)
      m_combobox_state=true;
  }
//+------------------------------------------------------------------+
// | Getting the cell type |
//+------------------------------------------------------------------+
ENUM_TYPE_CELL CTable::CellType(const uint column_index,const uint row_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return(WRONG_VALUE);
// --- Return the data type for the specified column
   return(m_columns[column_index].m_rows[row_index].m_type);
  }
//+------------------------------------------------------------------+
// | Sets pictures to the specified cell |
//+------------------------------------------------------------------+
void CTable::SetImages(const uint column_index,const uint row_index,const string &bmp_file_path[])
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Exit if a zero-size array is passed
   int total=0;
   if((total=::ArraySize(bmp_file_path))<1)
      return;
// --- Set new size to arrays
   ::ArrayResize(m_columns[column_index].m_rows[row_index].m_images,total);
//---
   for(int i=0; i<total; i++)
     {
      // --- By default, the first image of the array is selected
      m_columns[column_index].m_rows[row_index].m_selected_image=0;
      // --- Write the transmitted image to an array and remember its dimensions
      if(!m_columns[column_index].m_rows[row_index].m_images[i].ReadImageData(bmp_file_path[i]))
         return;
     }
  }
//+------------------------------------------------------------------+
// | Sets pictures to the specified cell |
//+------------------------------------------------------------------+
void CTable::SetImages(const uint column_index,const uint row_index,const uint &resource_index[])
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Exit if a zero-size array is passed
   int total=0;
   if((total=::ArraySize(resource_index))<1)
      return;
// --- Set new size to arrays
   ::ArrayResize(m_columns[column_index].m_rows[row_index].m_images,total);
//---
   for(int i=0; i<total; i++)
     {
      // --- By default, the first image of the array is selected
      m_columns[column_index].m_rows[row_index].m_selected_image=0;
      // --- Write the transmitted image to an array and remember its dimensions
      if(!m_columns[column_index].m_rows[row_index].m_images[i].ReadImageData(resource_index[i]))
         return;
     }
  }
//+------------------------------------------------------------------+
// | Changes the image in the specified cell |
//+------------------------------------------------------------------+
void CTable::ChangeImage(const uint column_index,const uint row_index,const uint image_index,const bool redraw=false)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Get the number of pictures of the cell
   int images_total=ImagesTotal(column_index,row_index);
// --- Exit if (1) there are no pictures or (2) we leave the range
   if(images_total==WRONG_VALUE || image_index>=(uint)images_total)
      return;
// --- Exit if the specified picture matches the selected one
   if(image_index==m_columns[column_index].m_rows[row_index].m_selected_image)
      return;
// --- Save the index of the selected cell image
   m_columns[column_index].m_rows[row_index].m_selected_image=(int)image_index;
// --- Redraw cell if specified
   if(redraw)
      RedrawCell(column_index,row_index);
  }
//+------------------------------------------------------------------+
// | Returns the index of the image in the specified cell |
//+------------------------------------------------------------------+
int CTable::SelectedImageIndex(const uint column_index,const uint row_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return(WRONG_VALUE);
// --- Return value
   return(m_columns[column_index].m_rows[row_index].m_selected_image);
  }
//+------------------------------------------------------------------+
// | Returns the index of the selected item |
// | in the combo box list in the specified cell |
//+------------------------------------------------------------------+
int CTable::SelectedComboboxItemIndex(const uint column_index,const uint row_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return(WRONG_VALUE);
// --- Return value
   return(m_columns[column_index].m_rows[row_index].m_selected_item);
  }
//+------------------------------------------------------------------+
// | Sets the text color in the specified table cell |
//+------------------------------------------------------------------+
void CTable::TextColor(const uint column_index,const uint row_index,const color clr,const bool redraw=false)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Set text color to general array
   m_columns[column_index].m_rows[row_index].m_text_color=clr;
// --- Redraw cell if specified
   if(redraw)
      RedrawCell(column_index,row_index);
  }
//+------------------------------------------------------------------+
// | Sets the background color to the specified table cell |
//+------------------------------------------------------------------+
void CTable::BackColor(const uint column_index,const uint row_index,const color clr,const bool redraw=false)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Set text color to general array
   m_columns[column_index].m_rows[row_index].m_back_color=clr;
// --- Redraw cell if specified
   if(redraw)
      RedrawCell(column_index,row_index);
  }
//+------------------------------------------------------------------+
// | Returns the background color from the specified table cell |
//+------------------------------------------------------------------+
color CTable::BackColor(const uint column_index,const uint row_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return(clrWhite);
//---
   return(m_columns[column_index].m_rows[row_index].m_back_color);
  }
//+------------------------------------------------------------------+
// | Fills an array at the specified indexes |
//+------------------------------------------------------------------+
void CTable::SetValue(const uint column_index,const uint row_index,const string value="",const uint digits=0,const bool redraw=false)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Set value to array:
// String
   if(m_columns[column_index].m_data_type==TYPE_STRING)
      m_columns[column_index].m_rows[row_index].m_full_text=value;
// --- Real
   else if(m_columns[column_index].m_data_type==TYPE_DOUBLE)
     {
      m_columns[column_index].m_rows[row_index].m_digits=digits;
      double type_value=::StringToDouble(value);
      m_columns[column_index].m_rows[row_index].m_full_text=::DoubleToString(type_value,digits);
     }
// --- Time
   else if(m_columns[column_index].m_data_type==TYPE_DATETIME)
     {
      datetime type_value=::StringToTime(value);
      m_columns[column_index].m_rows[row_index].m_full_text=::TimeToString(type_value);
     }
// --- Any other type will be set to string
   else
      m_columns[column_index].m_rows[row_index].m_full_text=value;
// --- Adjust and save text if it does not fit in the cell
   m_columns[column_index].m_rows[row_index].m_short_text=CorrectingText(column_index,row_index);
// --- Redraw cell if specified
   if(redraw)
      RedrawCell(column_index,row_index);
  }
//+------------------------------------------------------------------+
// | Returns a value at the specified indexes |
//+------------------------------------------------------------------+
string CTable::GetValue(const uint column_index,const uint row_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return("");
// --- Return value
   return(m_columns[column_index].m_rows[row_index].m_full_text);
  }
//+------------------------------------------------------------------+
// | Selecting the specified row in the table |
//+------------------------------------------------------------------+
void CTable::SelectRow(const int row_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(0,(uint)row_index))
      return;
// --- If such a line is already selected
   if(m_selected_item==row_index)
      return;
// --- Current and previous row indexes
   m_prev_selected_item =(m_selected_item==WRONG_VALUE)? row_index : m_selected_item;
   m_selected_item      =row_index;
// --- Array for values ​​in a specific sequence
   int indexes[2];
// ---If this is your first time here
   if(m_prev_selected_item==WRONG_VALUE)
      indexes[0]=m_selected_item;
   else
     {
      indexes[0] =(m_selected_item>m_prev_selected_item)? m_prev_selected_item : m_selected_item;
      indexes[1] =(m_selected_item>m_prev_selected_item)? m_selected_item : m_prev_selected_item;
     }
// --- Draws the specified table row using the specified mode
   DrawRow(indexes,m_selected_item,m_prev_selected_item,false);
// --- Get indexes on the boundaries of the visible area
   VisibleTableIndexes();
// --- Move the scroll bar to the specified line
   if(row_index==0)
     {
      VerticalScrolling(0);
     }
   else if((uint)row_index>=m_rows_total-1)
     {
      VerticalScrolling(WRONG_VALUE);
     }
   else if(row_index<(int)m_visible_table_from_index)
     {
      VerticalScrolling(m_scrollv.CurrentPos()-1);
     }
   else if(row_index>=(int)m_visible_table_to_index-1)
     {
      VerticalScrolling(m_scrollv.CurrentPos()+1);
     }
  }
//+------------------------------------------------------------------+
// | Add a list of values ​​to a combo box |
//+------------------------------------------------------------------+
void CTable::AddValueList(const uint column_index,const uint row_index,const string &array[],const uint selected_item=0)
  {
// --- Check for out of range
   if(!CheckOutOfRange(column_index,row_index))
      return;
// --- Set the size of the list of the specified cell
   uint total=::ArraySize(array);
   ::ArrayResize(m_columns[column_index].m_rows[row_index].m_value_list,total);
// --- Save the passed values
   ::ArrayCopy(m_columns[column_index].m_rows[row_index].m_value_list,array);
// --- Checking the index of the selected item in the list
   uint check_item_index=(selected_item>=total)? total-1 : selected_item;
// --- Save the selected item in the list
   m_columns[column_index].m_rows[row_index].m_selected_item=(int)check_item_index;
// --- Save the text of the selected item in a cell
   m_columns[column_index].m_rows[row_index].m_full_text=array[check_item_index];
  }
//+------------------------------------------------------------------+
// | Horizontal scrolling of the input field |
//+------------------------------------------------------------------+
void CTable::HorizontalScrolling(const int pos=WRONG_VALUE)
  {
// --- To determine the position of the slider
   int index=0;
// ---Last position index
   int last_pos_index=int(m_table_x_size-m_table_visible_x_size);
// --- Adjustment in case of leaving the range
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
// --- Move the scroll bar slider
   m_scrollh.MovingThumb(index);
// --- Move the input field
   ShiftTable();
  }
//+------------------------------------------------------------------+
// | Vertical scrolling of an input field |
//+------------------------------------------------------------------+
void CTable::VerticalScrolling(const int pos=WRONG_VALUE)
  {
// --- To determine the position of the slider
   int index=0;
// ---Last position index
   int last_pos_index=int(m_table_y_size-m_table_visible_y_size);
// --- Adjustment in case of leaving the range
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
// --- Move the scroll bar slider
   m_scrollv.MovingThumb(index);
// --- Move the input field
   ShiftTable();
  }
//+------------------------------------------------------------------+
// | Shifts the table relative to the scroll bars |
//+------------------------------------------------------------------+
void CTable::ShiftTable(void)
  {
// --- Get the current positions of the horizontal and vertical scroll bar sliders
   int h_offset =m_scrollh.CurrentPos()*m_shift_x_step;
   int v_offset =m_scrollv.CurrentPos()*m_cell_y_size;
// --- Calculate the indentation for the offset
   int x_offset =(h_offset<1)? 0 : (h_offset>=m_shift_x2_limit)? m_shift_x2_limit-2 : h_offset;
   int y_offset =(v_offset<1)? 0 : (v_offset>=m_shift_y2_limit)? m_shift_y2_limit : v_offset;
// --- Calculate data position relative to scrollbar sliders
   long x =(m_table_x_size>m_table_visible_x_size)? x_offset : 0;
   long y =(m_table_y_size>m_table_visible_y_size)? y_offset : 0;
// --- Table offset
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_XOFFSET,x);
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YOFFSET,y);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_XOFFSET,x);
  }
//+------------------------------------------------------------------+
// | Sort data by specified column |
//+------------------------------------------------------------------+
void CTable::SortData(const uint column_index=0,const int direction=WRONG_VALUE)
  {
// --- Exit if we go beyond the table
   if(column_index>=m_columns_total)
      return;
// --- Index to start sorting from
   uint first_index=0;
// --- Last index
   uint last_index=m_rows_total-1;
// --- Without user direction control
   if(direction==WRONG_VALUE)
     {
      // --- The first time will be sorted in ascending order, and then each time in the opposite direction
      if(m_is_sorted_column_index==WRONG_VALUE || column_index!=m_is_sorted_column_index || m_last_sort_direction==SORT_DESCEND)
         m_last_sort_direction=SORT_ASCEND;
      else
         m_last_sort_direction=SORT_DESCEND;
     }
   else
     {
      m_last_sort_direction=(ENUM_CSORT_MODE)direction;
     }
// --- Remember the index of the last sorted data column
   m_is_sorted_column_index=(int)column_index;
// --- Sorting
   QuickSort(first_index,last_index,column_index,m_last_sort_direction);
  }
//+------------------------------------------------------------------+
// | Auto-change column widths |
//+------------------------------------------------------------------+
void CTable::AutoResizeColumns(void)
  {
   if(!m_autoresize_columns)
      return;
//---
   int  table_x_size      =m_x_size-2;
   uint last_column_index =m_columns_total-1;
// --- Sum of the width of all columns
   int sum_width=0;
   for(uint c=0; c<m_columns_total; c++)
      sum_width+=m_columns[c].m_width;
// --- Adjust the width of the last column
   if(m_rows_total>(uint)VisibleRowsTotal())
     {
      if(sum_width==table_x_size)
         m_columns[last_column_index].m_width=m_columns[last_column_index].m_width-m_scrollv.XSize();
     }
   else
     {
      if(sum_width!=table_x_size)
        {
         if(sum_width<table_x_size)
           {
            int difference=table_x_size-sum_width;
            m_columns[last_column_index].m_width=m_columns[last_column_index].m_width+difference;
           }
         else
           {
            int difference=sum_width-(table_x_size);
            m_columns[last_column_index].m_width=m_columns[last_column_index].m_width-difference;
           }
        }
     }
  }
//+------------------------------------------------------------------+
// | Auto-correction of column widths based on text |
//+------------------------------------------------------------------+
void CTable::AutoCorrectWidthColumns(void)
  {
   if(!m_auto_correct_columns_width_mode || m_column_resize_mode)
      return;
// --- Define the maximum width for each column
   uint max_width[];
   ::ArrayResize(max_width,m_columns_total);
   for(uint c=0; c<m_columns_total; c++)
     {
      uint width  =0;
      uint height =0;
      ::TextGetSize(GetHeaderText(c),width,height);
      max_width[c]=width;
      //---
      for(uint r=0; r<m_rows_total; r++)
        {
         string text=m_columns[c].m_rows[r].m_full_text;
         ::TextGetSize(text,width,height);
         max_width[c]=(uint)::fmax((double)width,(double)max_width[c]);
        }
      //---
      m_columns[c].m_width=(int)max_width[c]+25;
     }
  }
//+------------------------------------------------------------------+
// | Update table |
//+------------------------------------------------------------------+
void CTable::Update(const bool redraw=false)
  {
// --- Redraw the table if specified
   if(redraw)
     {
      // --- Autosize columns
      AutoCorrectWidthColumns();
      AutoResizeColumns();
      // --- Set new table background size
      ChangeMainSize(m_x_size,m_y_size);
      // --- Calculate table dimensions
      CalculateTableSize();
      // --- Set new table size
      ChangeTableSize();
      // --- Redraw the table
      DrawTable();
      // --- Update table
      m_canvas.Update();
      m_table.Update();
      // --- Update headers if enabled
      if(m_show_headers)
         m_headers.Update();
      // --- Refresh scrollbars
      m_scrollv.Update(true);
      m_scrollh.Update(true);
      return;
     }
// --- Autosize columns
   AutoCorrectWidthColumns();
   AutoResizeColumns();
// --- Update table
   m_canvas.Update();
   m_table.Update();
// --- Update headers if enabled
   if(m_show_headers)
      m_headers.Update();
  }
//+------------------------------------------------------------------+
// | Handling clicks on header |
//+------------------------------------------------------------------+
bool CTable::OnClickHeaders(const string clicked_object)
  {
// --- Exit if (1) sort mode is disabled or (2) in the process of changing column width
   if(!m_is_sort_mode || m_column_resize_control!=WRONG_VALUE)
      return(false);
// --- Quit if there are input fields or combo boxes in cells
   if(m_edit_state && m_combobox_state)
      return(false);
// --- Exit if the scrollbar is in active mode
   if(m_scrollv.State() || m_scrollh.State())
      return(false);
// --- Exit if the object name is foreign
   if(m_headers.ChartObjectName()!=clicked_object)
      return(false);
// --- To determine the index of a column
   uint column_index=0;
// --- Get the relative X-coordinate under the mouse cursor
   int x=m_mouse.RelativeX(m_headers);
// --- Determine the title that was clicked on
   for(uint c=0; c<m_columns_total; c++)
     {
      // --- If you find a title, remember its index
      if(x>=m_columns[c].m_x && x<=m_columns[c].m_x2)
        {
         column_index=c;
         break;
        }
     }
// --- Sort data by specified column
   SortData(column_index);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_SORT_DATA,CElementBase::Id(),m_is_sorted_column_index,::EnumToString(DataType(column_index)));
   return(true);
  }
//+------------------------------------------------------------------+
// | Row selection processing |
//+------------------------------------------------------------------+
bool CTable::OnSelectRow(const int row_index)
  {
// --- If you clicked on an already selected row
   if(row_index==m_selected_item)
     {
      // --- Deselect if not disabled
      if(!m_is_without_deselect)
        {
         m_prev_selected_item =m_selected_item;
         m_selected_item      =WRONG_VALUE;
         m_selected_item_text ="";
        }
      return(true);
     }
// --- Save the row index and the row of the first cell
   m_prev_selected_item =(m_selected_item==WRONG_VALUE)? row_index : m_selected_item;
   m_selected_item      =row_index;
   m_selected_item_text =m_columns[0].m_rows[row_index].m_full_text;
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling clicks on the table |
//+------------------------------------------------------------------+
bool CTable::OnClickTable(const string clicked_object)
  {
// --- Quit if column width is being changed
   if(m_column_resize_control!=WRONG_VALUE)
      return(false);
// --- Exit if the scrollbar is in active mode
   if(m_scrollv.State() || m_scrollh.State())
      return(false);
// --- Exit if the object name is foreign
   if(m_table.ChartObjectName()!=clicked_object)
      return(false);
// --- Determine the row on which you clicked
   int r=PressedRowIndex();
// --- Determine the cell on which you clicked
   int c=PressedCellColumnIndex();
// --- Let's check whether the element in the cell was involved
   bool is_cell_element=CheckCellElement(c,r);
// --- If (1) row selection mode is enabled and (2) the element in the cell is not engaged
   if(m_selectable_row && !is_cell_element)
     {
      OnSelectRow(r);
      // --- Change color
      RedrawRow(true);
      m_table.Update();
      // --- We will send a message about this
      ::EventChartCustom(m_chart_id,ON_CLICK_LIST_ITEM,CElementBase::Id(),m_selected_item,string(c)+"_"+string(r));
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling a double click on a table |
//+------------------------------------------------------------------+
bool CTable::OnDoubleClickTable(const string clicked_object)
  {
// --- Exit if table is out of focus
   if(!m_table.MouseFocus())
      return(false);
// --- Determine the row on which you clicked
   int r=PressedRowIndex();
// --- Determine the cell on which you clicked
   int c=PressedCellColumnIndex();
// --- Let's check whether the element in the cell was involved and return the result
   return(CheckCellElement(c,r,true));
  }
//+------------------------------------------------------------------+
// | Processing the end of entering a value into a cell |
//+------------------------------------------------------------------+
bool CTable::OnEndEditCell(const int id)
  {
// --- Exit if (1) IDs do not match or (2) there are no cells with input fields
   if(id!=CElementBase::Id() || !m_edit_state)
      return(false);
// --- Set a new value to a table cell
   SetValue(m_last_edit_column_index,m_last_edit_row_index,m_edit.GetValue(),0,true);
   Update();
// --- Deactivate and hide the input field
   m_edit.GetTextBoxPointer().DeactivateTextBox();
   m_edit.Hide();
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
// | Processing item selection in a cell combo box |
//+------------------------------------------------------------------+
bool CTable::OnClickComboboxItem(const int id)
  {
// --- Exit if (1) the identifiers do not match or (2) there are no cells with a combo box
   if(id!=CElementBase::Id() || !m_combobox_state)
      return(false);
// ---Indices of the last edited cell
   int c=m_last_edit_column_index;
   int r=m_last_edit_row_index;
// --- Remember the index of the selected item in the cell
   m_columns[c].m_rows[r].m_selected_item=m_combobox.GetListViewPointer().SelectedItemIndex();
// --- Set a new value to a table cell
   SetValue(c,r,m_combobox.GetValue(),0,true);
   Update();
   return(true);
  }
//+------------------------------------------------------------------+
// | Checking the input field in cells for hiding |
//+------------------------------------------------------------------+
void CTable::CheckAndHideEdit(void)
  {
// --- Exit if (1) there is no input field or (2) it is hidden
   if(!m_edit_state || !m_edit.IsVisible())
      return;
// --- Let's check the focus
   m_edit.GetTextBoxPointer().CheckMouseFocus();
// --- Deactivate and hide an input field if it is (1) out of focus and (2) the mouse button is pressed
   if(!m_edit.GetTextBoxPointer().MouseFocus() && m_mouse.LeftButtonState())
     {
      m_edit.GetTextBoxPointer().DeactivateTextBox();
      m_edit.Hide();
      m_chart.Redraw();
     }
  }
//+------------------------------------------------------------------+
// | Checking the combo box in cells for hiding |
//+------------------------------------------------------------------+
void CTable::CheckAndHideCombobox(void)
  {
// --- Exit if (1) there is no combo box or (2) it is hidden
   if(!m_combobox_state || !m_combobox.IsVisible())
      return;
// --- Hide the combo box if it is out of focus and the mouse button is pressed
   if(!m_combobox.GetButtonPointer().MouseFocus() && m_mouse.LeftButtonState())
     {
      m_combobox.Hide();
      m_chart.Redraw();
     }
  }
//+------------------------------------------------------------------+
// | Returns the index of the clicked row |
//+------------------------------------------------------------------+
int CTable::PressedRowIndex(void)
  {
   int index=0;
// --- Get the relative Y-coordinate under the mouse cursor
   int y=m_mouse.RelativeY(m_table);
// --- Determine the row on which you clicked
   for(uint r=0; r<m_rows_total; r++)
     {
      // --- If the press was not on this row, go to the next
      if(!(y>=m_rows[r].m_y && y<=m_rows[r].m_y2))
         continue;
      //---
      index=(int)r;
      break;
     }
// --- Return index
   return(index);
  }
//+------------------------------------------------------------------+
// | Returns the column index of the clicked cell |
//+------------------------------------------------------------------+
int CTable::PressedCellColumnIndex(void)
  {
   int index=0;
// --- Get the relative X-coordinate under the mouse cursor
   int x=m_mouse.RelativeX(m_table);
// --- Determine the cell on which you clicked
   for(uint c=0; c<m_columns_total; c++)
     {
      // --- If this cell is clicked, remember the column index
      if(x>=m_columns[c].m_x && x<=m_columns[c].m_x2)
        {
         index=(int)c;
         break;
        }
     }
// --- Return column index
   return(index);
  }
//+------------------------------------------------------------------+
// | Checks whether an element in a cell was clicked |
//+------------------------------------------------------------------+
bool CTable::CheckCellElement(const int column_index,const int row_index,const bool double_click=false)
  {
// --- Quit if there is no control in the cell
   if(m_columns[column_index].m_rows[row_index].m_type==CELL_SIMPLE)
      return(false);
//---
   switch(m_columns[column_index].m_rows[row_index].m_type)
     {
      // --- If it is a button cell
      case CELL_BUTTON :
        {
         if(!CheckPressedButton(column_index,row_index,double_click))
            return(false);
         //---
         break;
        }
      // --- If this is a checkbox cell
      case CELL_CHECKBOX :
        {
         if(!CheckPressedCheckBox(column_index,row_index,double_click))
            return(false);
         //---
         break;
        }
      // --- If this is a cell with an input field
      case CELL_EDIT :
        {
         if(!CheckPressedEdit(column_index,row_index,double_click))
            return(false);
         //---
         break;
        }
      // --- If this is a cell with a combo box
      case CELL_COMBOBOX :
        {
         if(!CheckPressedCombobox(column_index,row_index,double_click))
            return(false);
         //---
         break;
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Checks whether a button in a cell has been clicked |
//+------------------------------------------------------------------+
bool CTable::CheckPressedButton(const int column_index,const int row_index,const bool double_click=false)
  {
// --- Exit if there are no pictures in the cell
   if(ImagesTotal(column_index,row_index)<1)
     {
      ::Print(__FUNCTION__," > Установите минимум одну картинку для ячейки-кнопки!");
      return(false);
     }
// --- Get relative coordinates under the mouse cursor
   int x=m_mouse.RelativeX(m_table);
// --- Get the right border of the picture
   int image_x  =int(m_columns[column_index].m_x+m_columns[column_index].m_image_x_offset);
   int image_x2 =int(image_x+m_columns[column_index].m_rows[row_index].m_images[0].Width());
// --- Exit if you clicked on something other than the picture
   if(x>image_x2)
      return(false);
   else
     {
      // --- If this is not a double click, we will send a message
      if(!double_click)
        {
         int image_index=m_columns[column_index].m_rows[row_index].m_selected_image;
         ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),image_index,string(column_index)+"_"+string(row_index));
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Checks whether a checkbox in a cell has been clicked |
//+------------------------------------------------------------------+
bool CTable::CheckPressedCheckBox(const int column_index,const int row_index,const bool double_click=false)
  {
// --- Exit if there are no pictures in the cell
   if(ImagesTotal(column_index,row_index)<2)
     {
      ::Print(__FUNCTION__," > Установите минимум две картинки для ячейки-чекбокса!");
      return(false);
     }
// --- Get relative coordinates under the mouse cursor
   int x=m_mouse.RelativeX(m_table);
// --- Get the right border of the picture
   int image_x  =int(m_columns[column_index].m_x+m_icon_x_gap);
   int image_x2 =int(image_x+m_columns[column_index].m_rows[row_index].m_images[0].Width());
   
// --- Exit if (1) the click is not on the image and (2) this is not a double click
   if(x>image_x2 && !double_click)
      return(false);
   else
     {
      // --- Current index of the selected image
      int image_i=m_columns[column_index].m_rows[row_index].m_selected_image;
      // --- Define the next index for the image
      int next_i=(image_i<ImagesTotal(column_index,row_index)-1)?++image_i : 0;
      // --- Select next picture
      //if(m_selectable_row)
      //  {
      //   ChangeImage(column_index,row_index,next_i);
      //   RedrawRow(true);
      //  }
      //else
      
      ChangeImage(column_index,row_index,next_i,true);
      // --- Update table
      m_table.Update();
      // --- We will send a message about this
      ::EventChartCustom(m_chart_id,ON_CLICK_CHECKBOX,CElementBase::Id(),next_i,string(column_index)+"_"+string(row_index));
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Checks whether an input field has been clicked in a cell |
//+------------------------------------------------------------------+
bool CTable::CheckPressedEdit(const int column_index,const int row_index,const bool double_click=false)
  {
// --- Quit if it's not a double click
   if(!double_click)
      return(false);
// --- Save indexes
   m_last_edit_row_index    =row_index;
   m_last_edit_column_index =column_index;
// --- Shift along two axes
   int x_offset =(int)::ObjectGetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_XOFFSET);
   int y_offset =(int)::ObjectGetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YOFFSET);
// --- Set new coordinates
   m_edit.XGap(m_columns[column_index].m_x-x_offset);
   m_edit.YGap(m_rows[row_index].m_y+((m_show_headers)? m_header_y_size : 0)-y_offset);
// --- Dimensions
   int x_size =m_columns[column_index].m_x2-m_columns[column_index].m_x+1;
   int y_size =m_cell_y_size+1;
// ---Set size
   m_edit.GetTextBoxPointer().ChangeSize(x_size,y_size);
// --- Set value from table cell
   m_edit.SetValue(m_columns[column_index].m_rows[row_index].m_full_text);
// --- Activate input field
   m_edit.GetTextBoxPointer().ActivateTextBox();
// --- Set focus
   m_edit.GetTextBoxPointer().MouseFocus(true);
// --- Show input field
   m_edit.Reset();
// --- Redraw the graph
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
// | Checks whether the combo box in the cell was clicked |
//+------------------------------------------------------------------+
bool CTable::CheckPressedCombobox(const int column_index,const int row_index,const bool double_click=false)
  {
// --- Quit if it's not a double click
   if(!double_click)
      return(false);
// --- Save indexes
   m_last_edit_row_index    =row_index;
   m_last_edit_column_index =column_index;
// --- Shift along two axes
   int x_offset =(int)::ObjectGetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_XOFFSET);
   int y_offset =(int)::ObjectGetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YOFFSET);
// --- Set new coordinates
   m_combobox.XGap(m_columns[column_index].m_x-x_offset);
   m_combobox.YGap(m_rows[row_index].m_y+((m_show_headers)? m_header_y_size : 0)-y_offset);
// --- Set button size
   int x_size =m_columns[column_index].m_x2-m_columns[column_index].m_x+1;
   int y_size =m_cell_y_size+1;
   m_combobox.GetButtonPointer().ChangeSize(x_size,y_size);
// --- Set list size
   y_size=m_combobox.GetListViewPointer().YSize();
   m_combobox.GetListViewPointer().ChangeSize(x_size,y_size);
// ---Set cell list size
   int total=::ArraySize(m_columns[column_index].m_rows[row_index].m_value_list);
   m_combobox.GetListViewPointer().Rebuilding(total);
// --- Set list from cell
   for(int i=0; i<total; i++)
      m_combobox.GetListViewPointer().SetValue(i,m_columns[column_index].m_rows[row_index].m_value_list[i]);
// --- Set item from cell
   int index=m_columns[column_index].m_rows[row_index].m_selected_item;
   m_combobox.SelectItem(index);
// --- Update element
   m_combobox.GetButtonPointer().MouseFocus(true);
   m_combobox.GetButtonPointer().Update(true);
   m_combobox.GetListViewPointer().Update(true);
// --- Show input field
   m_combobox.Reset();
// --- Redraw the graph
   m_chart.Redraw();
// --- Send a message about the change in the graphical interface
   ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
   return(true);
  }
//+------------------------------------------------------------------+
// | Quicksort algorithm |
//+------------------------------------------------------------------+
void CTable::QuickSort(uint beg,uint end,uint column,const ENUM_CSORT_MODE mode=SORT_ASCEND)
  {
   uint   r1         =beg;
   uint   r2         =end;
   uint   c          =column;
   string temp       =NULL;
   string value      =NULL;
   uint   data_total =m_rows_total-1;
// --- Execute the algorithm as long as the left index is less than the rightmost index
   while(r1<end)
     {
      // --- Get the value from the middle of the row
      value=m_columns[c].m_rows[(beg+end)>>1].m_full_text;
      // --- Execute the algorithm as long as the left index is less than the found right index
      while(r1<r2)
        {
         // --- Shift the index to the right while we find the value according to the specified condition
         while(CheckSortCondition(c,r1,value,(mode==SORT_ASCEND)? false : true))
           {
            // --- Control of overflow of array boundaries
            if(r1==data_total)
               break;
            r1++;
           }
         // --- Shift the index to the left while we find the value according to the specified condition
         while(CheckSortCondition(c,r2,value,(mode==SORT_ASCEND)? true : false))
           {
            // --- Control of overflow of array boundaries
            if(r2==0)
               break;
            r2--;
           }
         // --- If the left index is not yet greater than the right one
         if(r1<=r2)
           {
            // --- Swap values
            Swap(r1,r2);
            // --- If you reach the limit on the left
            if(r2==0)
              {
               r1++;
               break;
              }
            //---
            r1++;
            r2--;
           }
        }
      // --- Recursive continuation of the algorithm until we reach the beginning of the range
      if(beg<r2)
         QuickSort(beg,r2,c,mode);
      // --- Narrowing the range for the next iteration
      beg=r1;
      r2=end;
     }
  }
//+------------------------------------------------------------------+
// | Comparing values ​​by specified sorting condition |
//+------------------------------------------------------------------+
//| direction: true (>), false (<)                                   |
//+------------------------------------------------------------------+
bool CTable::CheckSortCondition(uint column_index,uint row_index,const string check_value,const bool direction)
  {
   bool condition=false;
//---
   switch(m_columns[column_index].m_data_type)
     {
      case TYPE_STRING :
        {
         string v1=m_columns[column_index].m_rows[row_index].m_full_text;
         string v2=check_value;
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
      //---
      case TYPE_DOUBLE :
        {
         double v1=double(m_columns[column_index].m_rows[row_index].m_full_text);
         double v2=double(check_value);
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
      //---
      case TYPE_DATETIME :
        {
         datetime v1=::StringToTime(m_columns[column_index].m_rows[row_index].m_full_text);
         datetime v2=::StringToTime(check_value);
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
      //---
      default :
        {
         long v1=(long)m_columns[column_index].m_rows[row_index].m_full_text;
         long v2=(long)check_value;
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
     }
//---
   return(condition);
  }
//+------------------------------------------------------------------+
// | Swaps elements |
//+------------------------------------------------------------------+
void CTable::Swap(uint r1,uint r2)
  {
// --- Let's loop through all the columns
   for(uint c=0; c<m_columns_total; c++)
     {
      // --- Swap the full text
      string temp_text                    =m_columns[c].m_rows[r1].m_full_text;
      m_columns[c].m_rows[r1].m_full_text =m_columns[c].m_rows[r2].m_full_text;
      m_columns[c].m_rows[r2].m_full_text =temp_text;
      // --- Swap the short text
      temp_text                            =m_columns[c].m_rows[r1].m_short_text;
      m_columns[c].m_rows[r1].m_short_text =m_columns[c].m_rows[r2].m_short_text;
      m_columns[c].m_rows[r2].m_short_text =temp_text;
      // --- Swap the number of decimal places
      uint temp_digits                 =m_columns[c].m_rows[r1].m_digits;
      m_columns[c].m_rows[r1].m_digits =m_columns[c].m_rows[r2].m_digits;
      m_columns[c].m_rows[r2].m_digits =temp_digits;
      // --- Swap text color
      color temp_text_color                =m_columns[c].m_rows[r1].m_text_color;
      m_columns[c].m_rows[r1].m_text_color =m_columns[c].m_rows[r2].m_text_color;
      m_columns[c].m_rows[r2].m_text_color =temp_text_color;
      // --- Swap the background color
      color temp_back_color                =m_columns[c].m_rows[r1].m_back_color;
      m_columns[c].m_rows[r1].m_back_color =m_columns[c].m_rows[r2].m_back_color;
      m_columns[c].m_rows[r2].m_back_color =temp_back_color;
      // --- Swap the index of the selected image
      int temp_selected_image                  =m_columns[c].m_rows[r1].m_selected_image;
      m_columns[c].m_rows[r1].m_selected_image =m_columns[c].m_rows[r2].m_selected_image;
      m_columns[c].m_rows[r2].m_selected_image =temp_selected_image;
      // --- Let's check if there are pictures in the cells
      int r1_images_total=::ArraySize(m_columns[c].m_rows[r1].m_images);
      int r2_images_total=::ArraySize(m_columns[c].m_rows[r2].m_images);
      // --- Move to the next column if there are no pictures in both cells
      if(r1_images_total<1 && r2_images_total<1)
         continue;
      // --- Swap pictures
      CImage r1_temp_images[];
      //---
      ::ArrayResize(r1_temp_images,r1_images_total);
      for(int i=0; i<r1_images_total; i++)
         ImageCopy(r1_temp_images,m_columns[c].m_rows[r1].m_images,i);
      //---
      ::ArrayResize(m_columns[c].m_rows[r1].m_images,r2_images_total);
      for(int i=0; i<r2_images_total; i++)
         ImageCopy(m_columns[c].m_rows[r1].m_images,m_columns[c].m_rows[r2].m_images,i);
      //---
      ::ArrayResize(m_columns[c].m_rows[r2].m_images,r1_images_total);
      for(int i=0; i<r1_images_total; i++)
         ImageCopy(m_columns[c].m_rows[r2].m_images,r1_temp_images,i);
     }
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CTable::Draw(void)
  {
   DrawTable();
  }
//+------------------------------------------------------------------+
// | Draws a table |
//+------------------------------------------------------------------+
void CTable::DrawTable(const bool only_visible=false)
  {
// --- If not specified, redraw only the visible part of the table
   if(!only_visible)
     {
      // --- Set the row indexes of the entire table from the very beginning to the end
      m_visible_table_from_index =0;
      m_visible_table_to_index   =m_rows_total;
     }
// --- Get the row indexes of the visible part of the table
   else
      VisibleTableIndexes();
// --- Draw background
   CElement::DrawBackground();
// --- Draw a frame
   CElement::DrawBorder();
// ---Draw mesh
   DrawGrid();
// ---Draw table row background
   DrawRows();
// --- Draw the selected line
   DrawSelectedRow();
// --- Draw a picture
   DrawImages();
// --- Draw text
   DrawText();
// --- Update headers if enabled
   if(m_show_headers)
      DrawTableHeaders();
  }
//+------------------------------------------------------------------+
// | Redraws the specified table cell |
//+------------------------------------------------------------------+
void CTable::RedrawCell(const int column_index,const int row_index)
  {
// --- Coordinates
   int x1=m_columns[column_index].m_x+1;
   int x2=m_columns[column_index].m_x2-1;
   int y1=m_rows[row_index].m_y+1;
   int y2=m_rows[row_index].m_y2-1;
// --- To calculate coordinates
   int  x=0,y=0;
// --- To check focus
   bool is_row_focus=false;
// --- If table row highlighting mode is enabled
   if(m_lights_hover)
     {
      // --- (1) Get the relative Y-coordinate of the mouse cursor and (2) focus on the specified table row
      y=m_mouse.RelativeY(m_table);
      is_row_focus=(y>m_rows[row_index].m_y && y<=m_rows[row_index].m_y2);
     }
// --- Draw cell background
   m_table.FillRectangle(x1,y1,x2,y2,RowColorCurrent(column_index,row_index,is_row_focus));
// --- Draw a picture if (1) it is in this cell and (2) in this column the text is aligned to the left
   if(ImagesTotal(column_index,row_index)>0 && m_columns[column_index].m_text_align==ALIGN_LEFT)
      CTable::DrawImage(column_index,row_index);
// --- Let's get the text alignment method
   uint text_align=TextAlign(column_index,TA_TOP);
// --- Drawing text
   for(uint c=0; c<m_columns_total; c++)
     {
      // --- Get the X-coordinate of the text
      x=TextX(c);
      // --- Stop the cycle
      if(c==column_index)
         break;
     }
// --- (1) Calculate Y-coordinate and (2) draw text
   y=y1+m_label_y_gap-1;
   m_table.TextOut(x,y,m_columns[column_index].m_rows[row_index].m_short_text,TextColor(column_index,row_index),text_align);
  }
//+------------------------------------------------------------------+
// | Draws the specified table row using the specified mode |
//+------------------------------------------------------------------+
void CTable::DrawRow(int &indexes[],const int item_index,const int prev_item_index,const bool is_user=true)
  {
   int x1=0,x2=m_table_x_size-2;
   int y1[2]={0},y2[2]={0};
// --- Number of rows and columns to draw
   uint rows_total    =0;
   uint columns_total =m_columns_total-1;
// --- If this is a programmatic method for selecting a line
   if(!is_user)
      rows_total=(prev_item_index!=WRONG_VALUE && item_index!=prev_item_index)? 2 : 1;
   else
      rows_total=(item_index!=WRONG_VALUE && prev_item_index!=WRONG_VALUE && item_index!=prev_item_index)? 2 : 1;
// --- Draw the background of the lines
   for(uint r=0; r<rows_total; r++)
     {
      // --- Calculation of the coordinates of the upper and lower boundaries of the line
      y1[r] =m_rows[indexes[r]].m_y+1;
      y2[r] =m_rows[indexes[r]].m_y2-1;
      // --- Determine the focus on the line relative to the backlight mode
      bool is_item_focus=false;
      if(!m_lights_hover)
         is_item_focus=(indexes[r]==item_index && item_index!=WRONG_VALUE);
      else
         is_item_focus=(item_index==WRONG_VALUE)?(indexes[r]==prev_item_index) :(indexes[r]==item_index);
      // --- Draw cell background
      for(uint c=0; c<m_columns_total; c++)
        {
         x1=m_columns[c].m_x+((c>0)? 1 : 0);
         x2=m_columns[c].m_x2-1;
         m_table.FillRectangle(x1,y1[r],x2,y2[r],RowColorCurrent(c,indexes[r],(is_user)? is_item_focus : false));
        }
     }
// --- Drawing borders
   for(uint r=0; r<rows_total; r++)
     {
      for(uint c=0; c<columns_total; c++)
         m_table.Line(m_columns[c].m_x2,y1[r],m_columns[c].m_x2,y2[r],::ColorToARGB(m_grid_color));
     }
// --- Drawing pictures
   for(uint r=0; r<rows_total; r++)
     {
      for(uint c=0; c<m_columns_total; c++)
        {
         // --- Draw a picture if (1) it is in this cell and (2) in this column the text is aligned to the left
         if(ImagesTotal(c,indexes[r])>0 && m_columns[c].m_text_align==ALIGN_LEFT)
            CTable::DrawImage(c,indexes[r]);
        }
     }
// --- To calculate coordinates
   int x=0,y=0;
// --- Text alignment method
   uint text_align=0;
// --- Drawing text
   for(uint c=0; c<m_columns_total; c++)
     {
      // --- Get (1) the X-coordinate of the text and (2) the text alignment method
      x          =TextX(c);
      text_align =TextAlign(c,TA_TOP);
      //---
      for(uint r=0; r<rows_total; r++)
        {
         // --- (1) Calculate coordinate and (2) draw text
         y=m_rows[indexes[r]].m_y+m_label_y_gap;
         m_table.TextOut(x,y,m_columns[c].m_rows[indexes[r]].m_short_text,TextColor(c,indexes[r]),text_align);
        }
     }
  }
//+------------------------------------------------------------------+
// | Redraws the specified table row using the specified mode |
//+------------------------------------------------------------------+
void CTable::RedrawRow(const bool is_selected_row=false)
  {
// --- Current and previous row indexes
   int item_index      =WRONG_VALUE;
   int prev_item_index =WRONG_VALUE;
// --- Initialize row indexes relative to the specified mode
   if(is_selected_row)
     {
      item_index      =m_selected_item;
      prev_item_index =m_prev_selected_item;
     }
   else
     {
      item_index      =m_item_index_focus;
      prev_item_index =m_prev_item_index_focus;
     }
// --- Quit if indexes are not defined
   if(prev_item_index==WRONG_VALUE && item_index==WRONG_VALUE)
      return;
// --- Array for values ​​in a specific sequence
   int indexes[2];
// --- If (1) the mouse cursor has moved down or (2) the first time here
   if(item_index>m_prev_item_index_focus || item_index==WRONG_VALUE)
     {
      indexes[0] =(item_index==WRONG_VALUE || prev_item_index!=WRONG_VALUE)? prev_item_index : item_index;
      indexes[1] =item_index;
     }
// --- If the mouse cursor moves up
   else
     {
      indexes[0] =item_index;
      indexes[1] =prev_item_index;
     }
// --- Draws the specified table row using the specified mode
   DrawRow(indexes,item_index,prev_item_index);
  }
//+------------------------------------------------------------------+
// | Draws background of table rows |
//+------------------------------------------------------------------+
void CTable::DrawRows(void)
  {
// --- Mouse cursor coordinates
   int y=0;
// --- Header coordinates
   int x1=0,x2=m_table_x_size-2;
   int y1=0,y2=0;
   bool is_row_focus=false;
// --- Get the relative X-coordinate under the mouse cursor
   y=m_mouse.RelativeY(m_table);
// --- Drawing rows
   for(uint r=m_visible_table_from_index; r<m_visible_table_to_index; r++)
     {
      // --- Calculation of coordinates of row boundaries with saving values
      m_rows[r].m_y  =(int)(r*m_cell_y_size);
      m_rows[r].m_y2 =m_rows[r].m_y+m_cell_y_size;
      y1 =m_rows[r].m_y+((r>0)? 1 : 0);
      y2 =m_rows[r].m_y2-1;
      // --- Let's check the focus
      is_row_focus=(m_lights_hover)?(y>y1 && y<y2) : false;
      // --- Draw cell background
      for(uint c=0; c<m_columns_total; c++)
        {
         x1 =m_columns[c].m_x+((c>0)? 1 : 0);
         x2 =m_columns[c].m_x2-1;
         m_table.FillRectangle(x1,y1,x2,y2,RowColorCurrent(c,r,is_row_focus));
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws the selected row |
//+------------------------------------------------------------------+
void CTable::DrawSelectedRow(void)
  {
// --- Quit if there is no selected row
   if(m_selected_item==WRONG_VALUE || !m_selectable_row)
      return;
// --- Set the initial coordinates to check the condition
   int y_offset=m_selected_item*m_cell_y_size;
// --- Coordinates
   int x1=0;
   int x2=0;
   int y1=y_offset+1;
   int y2=y_offset+m_cell_y_size-1;
// ---Draw cell background
   for(uint c=0; c<m_columns_total; c++)
     {
      x1 =m_columns[c].m_x+((c>0)? 1 : 0);
      x2 =m_columns[c].m_x2-1;
      m_table.FillRectangle(x1,y1,x2,y2,::ColorToARGB(m_selected_row_color,m_alpha));
     }
  }
//+------------------------------------------------------------------+
// | Draws a grid |
//+------------------------------------------------------------------+
void CTable::DrawGrid(void)
  {
// --- Mesh color
   uint clr=::ColorToARGB(m_grid_color);
// --- Painting canvas size
   int x_size=m_table_x_size;
   int y_size=m_table_y_size-1;
// --- Coordinates
   int x1=0,x2=0,y1=0,y2=0;
// --- Horizontal lines
   uint first_index=(m_show_headers)? 0 : 1;
   x1=0; y1=0; x2=x_size; y2=0;
   for(uint r=first_index; r<m_rows_total; r++)
     {
      // --- Calculation of coordinates of row boundaries with saving values
      m_rows[r].m_y  =y1 =(int)(r*m_cell_y_size);
      m_rows[r].m_y2 =y2 =y1+m_cell_y_size;
      m_table.Line(x1,m_rows[r].m_y,x2,m_rows[r].m_y,clr);
     }
// --- Vertical lines
   x1=0; y1=0; x2=0; y2=y_size;
   for(uint i=0; i<m_columns_total; i++)
     {
      m_columns[i].m_x2=x2=x1+=m_columns[i].m_width;
      m_table.Line(x1,y1,x2,y2,clr);
      // --- Save the X-coordinate of the column
      if(i>0)
        {
         uint prev_i=i-1;
         m_columns[i].m_x=m_columns[prev_i].m_x+m_columns[prev_i].m_width;
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws all table images |
//+------------------------------------------------------------------+
void CTable::DrawImages(void)
  {
// --- To calculate coordinates
   int x=0,y=0;
// --- Columns
   for(int c=0; c<(int)m_columns_total; c++)
     {
      // --- If text alignment is not left, move to next column
      if(m_columns[c].m_text_align!=ALIGN_LEFT)
         continue;
      // --- Strings
      for(int r=(int)m_visible_table_from_index; r<(int)m_visible_table_to_index; r++)
        {
         // ---Go to the next one if there are no pictures in this cell
         if(ImagesTotal(c,r)<1)
            continue;
         // --- Selected image in cell (by default the first one is selected [0])
         int selected_image=m_columns[c].m_rows[r].m_selected_image;
         // --- Move to next if pixel array is empty
         if(m_columns[c].m_rows[r].m_images[selected_image].DataTotal()<1)
            continue;
         // --- Draw a picture
         CTable::DrawImage(c,r);
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws an image in the specified cell |
//+------------------------------------------------------------------+
void CTable::DrawImage(const int column_index,const int row_index)
  {
// --- Calculation of coordinates
   int x =m_columns[column_index].m_x+m_columns[column_index].m_image_x_offset;
   int y =m_rows[row_index].m_y+m_columns[column_index].m_image_y_offset;
// --- Selected image in the cell and its dimensions
   int  selected_image =m_columns[column_index].m_rows[row_index].m_selected_image;
   uint image_height   =m_columns[column_index].m_rows[row_index].m_images[selected_image].Height();
   uint image_width    =m_columns[column_index].m_rows[row_index].m_images[selected_image].Width();
// --- Draw
   for(uint ly=0,i=0; ly<image_height; ly++)
     {
      for(uint lx=0; lx<image_width; lx++,i++)
        {
         // ---If there is no color, move to the next pixel
         if(m_columns[column_index].m_rows[row_index].m_images[selected_image].Data(i)<1)
            continue;
         // --- Get the color of the bottom layer (cell background) and the color of the specified pixel in the image
         uint background  =(row_index==m_selected_item)? m_selected_row_color : m_canvas.PixelGet(x+lx,y+ly);
         uint pixel_color =m_columns[column_index].m_rows[row_index].m_images[selected_image].Data(i);
         // --- Mix colors
         uint foreground=::ColorToARGB(m_clr.BlendColors(background,pixel_color));
         // --- Drawing a pixel of the layered image
         m_table.PixelSet(x+lx,y+ly,foreground);
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws text |
//+------------------------------------------------------------------+
void CTable::DrawText(void)
  {
// --- To calculate coordinates and offsets
   int  x=0,y=0;
   uint text_align=0;
// --- Font properties
   m_table.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// --- Columns
   for(uint c=0; c<m_columns_total; c++)
     {
      // --- Get the X-coordinate of the text
      x=TextX(c);
      // --- Let's get the text alignment method
      text_align=TextAlign(c,TA_TOP);
      // ---Rows
      for(uint r=m_visible_table_from_index; r<m_visible_table_to_index; r++)
        {
         // --- Calculate the Y-coordinate
         y=m_rows[r].m_y+m_label_y_gap;
         // --- Draw text
         m_table.TextOut(x,y,Text(c,r),TextColor(c,r),text_align);
        }
      // --- Reset Y coordinate for next cycle
      y=0;
     }
  }
//+------------------------------------------------------------------+
// | Draws table headers |
//+------------------------------------------------------------------+
void CTable::DrawTableHeaders(void)
  {
// --- Draw headings
   DrawHeaders();
// ---Draw mesh
   DrawHeadersGrid();
// --- Draw title text
   DrawHeadersText();
// --- Draw a sign that the table can be sorted
   DrawSignSortedData();
  }
//+------------------------------------------------------------------+
// | Draws header background |
//+------------------------------------------------------------------+
void CTable::DrawHeaders(void)
  {
// ---If out of focus, reset title color
   if(!m_headers.MouseFocus() && m_column_resize_control==WRONG_VALUE)
     {
      m_headers.Erase(::ColorToARGB(m_headers_color,m_alpha));
      return;
     }
// --- To check focus on headings
   bool is_header_focus=false;
// --- Mouse cursor coordinates
   int x=0;
// --- Coordinates
   int y1=0,y2=m_header_y_size;
// --- Get the relative X-coordinate under the mouse cursor
   if(::CheckPointer(m_mouse)!=POINTER_INVALID)
      x=m_mouse.RelativeX(m_headers);
// --- Clear header background
   m_headers.Erase(::ColorToARGB(clrNONE,m_alpha));
// --- Indentation taking into account the mode of changing the column width
   int sep_x_offset=(m_column_resize_mode)? m_sep_x_offset : 0;
// --- Drawing the background of the headers
   for(uint i=0; i<m_columns_total; i++)
     {
      // --- Let's check the focus
      if(is_header_focus=x>m_columns[i].m_x+((i!=0)? sep_x_offset : 0) && x<=m_columns[i].m_x2+sep_x_offset)
         m_prev_header_index_focus=(int)i;
      // --- Define the title color
      uint clr=(i==m_column_resize_control)? ::ColorToARGB(m_headers_color_hover,m_alpha) : HeaderColorCurrent(is_header_focus);
      // ---Draw header background
      m_headers.FillRectangle(m_columns[i].m_x,y1,m_columns[i].m_x2,y2,clr);
     }
  }
//+------------------------------------------------------------------+
// | Draws a table header grid |
//+------------------------------------------------------------------+
void CTable::DrawHeadersGrid(void)
  {
// --- Mesh color
   uint clr=::ColorToARGB(m_grid_color);
// --- Coordinates
   int x1=0,x2=0,y1=0,y2=0;
   x2=m_table_x_size-1;
   y2=m_header_y_size-1;
// --- Draw a frame
   m_headers.Line(x1,y2,x2,y2,clr);
// --- Dividing lines
   x2=x1=m_columns[0].m_width;
   for(uint i=1; i<m_columns_total; i++)
      m_headers.Line(m_columns[i].m_x,y1,m_columns[i].m_x,y2,clr);
  }
//+------------------------------------------------------------------+
// | Draws a sign that a table can be sorted |
//+------------------------------------------------------------------+
void CTable::DrawSignSortedData(void)
  {
// --- Exit if (1) sorting is disabled or (2) has not yet been performed
   if(!m_is_sort_mode || m_is_sorted_column_index==WRONG_VALUE)
      return;
// --- Quit if there are input fields or combo boxes in cells
   if(m_edit_state && m_combobox_state)
      return;
// --- Exit if array is out of bounds
   if(m_is_sorted_column_index>=::ArraySize(m_columns))
      return;
// --- Calculation of coordinates
   int x =m_columns[m_is_sorted_column_index].m_x2-m_sort_arrow_x_gap;
   int y =m_sort_arrow_y_gap;
// --- Selected picture by sorting direction
   int image_index=(m_last_sort_direction==SORT_ASCEND)? 0 : 1;
// --- Draw
   for(uint ly=0,i=0; ly<m_sort_arrows[image_index].Height(); ly++)
     {
      for(uint lx=0; lx<m_sort_arrows[image_index].Width(); lx++,i++)
        {
         // ---If there is no color, move to the next pixel
         if(m_sort_arrows[image_index].Data(i)<1)
            continue;
         // --- Get the color of the bottom layer (header background) and the color of the specified pixel in the image
         uint background  =m_headers.PixelGet(x+lx,y+ly);
         uint pixel_color =m_sort_arrows[image_index].Data(i);
         // --- Mix colors
         uint foreground=::ColorToARGB(m_clr.BlendColors(background,pixel_color));
         // --- Drawing a pixel of the layered image
         m_headers.PixelSet(x+lx,y+ly,foreground);
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws table header text |
//+------------------------------------------------------------------+
void CTable::DrawHeadersText(void)
  {
// --- To calculate coordinates and offsets
   int x=0,y=m_header_y_size/2;
   int column_offset =0;
   uint text_align   =0;
// --- Text color
   uint clr=::ColorToARGB(m_headers_text_color);
// --- Font properties
   m_headers.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// --- Draw text
   for(uint c=0; c<m_columns_total; c++)
     {
      // --- Get the X-coordinate of the text
      x=TextX(c,true);
      // --- Let's get the text alignment method
      text_align=TextAlign(c,TA_VCENTER);
      // --- Draw column title
      m_headers.TextOut(x,y,CorrectingText(c,0,true),clr,text_align);
     }
  }
//+------------------------------------------------------------------+
// | Changing the color of table objects |
//+------------------------------------------------------------------+
void CTable::ChangeObjectsColor(void)
  {
// --- Track color changes only if not in column width changing mode
   if(m_column_resize_control!=WRONG_VALUE)
      return;
// ---Change header color
   ChangeHeadersColor();
// --- Change row color on mouse hover
   ChangeRowsColor();
  }
//+------------------------------------------------------------------+
// | Change title color on mouseover |
//+------------------------------------------------------------------+
void CTable::ChangeHeadersColor(void)
  {
// --- Quit if headers are disabled
   if(!m_show_headers)
      return;
// --- If the cursor pointer is activated
   if(m_column_resize_control==WRONG_VALUE && 
      m_column_resize.IsVisible() && m_mouse.LeftButtonState())
     {
      // --- Remember the index of the captured column
      m_column_resize_control=m_prev_header_index_focus;
      // --- Send a message to determine available elements
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
      return;
     }
// ---If out of focus
   if(!m_headers.MouseFocus())
     {
      // --- If it hasn't already been noted, it's out of focus
      if(m_prev_header_index_focus!=WRONG_VALUE)
        {
         // --- Reset focus
         m_prev_header_index_focus=WRONG_VALUE;
         // --- Change color
         DrawTableHeaders();
         m_headers.Update();
        }
     }
// ---If in focus
   else
     {
      // --- Check focus on headings
      CheckHeaderFocus();
      // ---If there is no focus
      if(m_prev_header_index_focus==WRONG_VALUE)
        {
         // --- Change color
         DrawTableHeaders();
         m_headers.Update();
        }
     }
  }
//+------------------------------------------------------------------+
// | Changing the color of rows on mouseover |
//+------------------------------------------------------------------+
void CTable::ChangeRowsColor(void)
  {
// --- Exit if row highlighting on hover is disabled
   if(!m_lights_hover)
      return;
// ---If out of focus
   if(!m_table.MouseFocus())
     {
      // --- If it hasn't already been noted, it's out of focus
      if(m_prev_item_index_focus!=WRONG_VALUE)
        {
         m_item_index_focus=WRONG_VALUE;
         // --- Change color
         RedrawRow();
         m_table.Update();
         // --- Reset focus
         m_prev_item_index_focus=WRONG_VALUE;
        }
     }
// ---If in focus
   else
     {
      // --- Check focus on rows
      if(m_item_index_focus==WRONG_VALUE)
        {
         // --- Get the index of the row in focus
         m_item_index_focus=CheckRowFocus();
         // --- Change line color
         RedrawRow();
         m_table.Update();
         // --- Save as previous index in focus
         m_prev_item_index_focus=m_item_index_focus;
         return;
        }
      // --- Get the relative Y-coordinate under the mouse cursor
      int y=m_mouse.RelativeY(m_table);
      // --- Focus check
      bool condition=(y>m_rows[m_item_index_focus].m_y && y<=m_rows[m_item_index_focus].m_y2);
      // ---If the focus has changed
      if(!condition)
        {
         // --- Get the index of the row in focus
         m_item_index_focus=CheckRowFocus();
         // --- Change line color
         RedrawRow();
         m_table.Update();
         // --- Save as previous index in focus
         m_prev_item_index_focus=m_item_index_focus;
        }
     }
  }
//+------------------------------------------------------------------+
// | Checking focus on title |
//+------------------------------------------------------------------+
void CTable::CheckHeaderFocus(void)
  {
// --- Quit if (1) headers are disabled or (2) started changing column width
   if(!m_show_headers || m_column_resize_control!=WRONG_VALUE)
      return;
// --- Get the relative X-coordinate under the mouse cursor
   int x=m_mouse.RelativeX(m_headers);
// --- Indentation taking into account the mode of changing the column width
   int sep_x_offset=(m_column_resize_mode)? m_sep_x_offset : 0;
// --- Looking for focus
   for(uint i=0; i<m_columns_total; i++)
     {
      // ---If the title focus has changed
      if((x>m_columns[i].m_x+sep_x_offset && x<=m_columns[i].m_x2+sep_x_offset) && m_prev_header_index_focus!=i)
        {
         m_prev_header_index_focus=WRONG_VALUE;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
// | Defining indexes of the visible area of ​​the table |
//+------------------------------------------------------------------+
void CTable::VisibleTableIndexes(void)
  {
// --- Determine the boundaries taking into account the offset of the visible area of ​​the table
   int yoffset1 =(int)::ObjectGetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YOFFSET);
   int yoffset2 =yoffset1+m_table_visible_y_size;
// --- Determine the first and last indexes of the visible area of ​​the table
   m_visible_table_from_index =int(double(yoffset1/m_cell_y_size));
   m_visible_table_to_index   =int(double(yoffset2/m_cell_y_size));
// --- The subscript is one more if we do not go out of range
   m_visible_table_to_index=(m_visible_table_to_index+1>m_rows_total)? m_rows_total : m_visible_table_to_index+1;
  }
//+------------------------------------------------------------------+
// | Checking focus on table rows |
//+------------------------------------------------------------------+
int CTable::CheckRowFocus(void)
  {
   int item_index_focus=WRONG_VALUE;
// --- Get the relative Y-coordinate under the mouse cursor
   int y=m_mouse.RelativeY(m_table);
// /--- Get the indexes of the local table area
   VisibleTableIndexes();
// --- Looking for focus
   for(uint i=m_visible_table_from_index; i<m_visible_table_to_index; i++)
     {
      // --- If the line focus has changed
      if(y>m_rows[i].m_y && y<=m_rows[i].m_y2)
        {
         item_index_focus=(int)i;
         break;
        }
     }
// --- Return the index of the row in focus
   return(item_index_focus);
  }
//+------------------------------------------------------------------+
// | Checking focus on heading borders to change their width |
//+------------------------------------------------------------------+
void CTable::CheckColumnResizeFocus(void)
  {
// --- Exit if column width change mode is disabled
   if(!m_column_resize_mode || m_auto_correct_columns_width_mode)
      return;
// --- Exit if started changing column width
   if(m_column_resize_control!=WRONG_VALUE)
     {
      // --- Update pointer coordinates
      m_column_resize.Moving(m_mouse.X(),m_mouse.Y());
      return;
     }
// --- To check focus over heading boundaries
   bool is_focus=false;
// --- If the mouse cursor is in the title area
   if(m_headers.MouseFocus())
     {
      // --- Get the relative X-coordinate under the mouse cursor
      int x=m_mouse.RelativeX(m_headers);
      // --- Looking for focus
      for(uint i=0; i<m_columns_total; i++)
        {
         if(is_focus=x>m_columns[i].m_x2-m_sep_x_offset && x<=m_columns[i].m_x2+m_sep_x_offset)
            break;
        }
      // --- If there is focus
      if(is_focus)
        {
         // --- Update pointer coordinates and make it visible
         m_column_resize.Moving(m_mouse.X(),m_mouse.Y());
         m_column_resize.Reset();
         m_chart.Redraw();
        }
      else
        {
         m_column_resize.Hide();
        }
     }
// --- Hide the pointer if there is no focus
   else if(!is_focus)
      m_column_resize.Hide();
  }
//+------------------------------------------------------------------+
// | Changes the width of the captured column |
//+------------------------------------------------------------------+
void CTable::ChangeColumnWidth(void)
  {
// --- Quit if headers are disabled
   if(!m_show_headers)
      return;
// --- Checking focus on heading boundaries
   CheckColumnResizeFocus();
// --- If you're done, reset the values
   if(m_column_resize_control==WRONG_VALUE)
     {
      m_column_resize_x_fixed    =0;
      m_column_resize_prev_width =0;
      m_column_resize_prev_thumb =0;
      return;
     }
// --- Get the relative X-coordinate under the mouse cursor
   int x=m_mouse.RelativeX(m_headers);
// --- If you just started changing the column width
   if(m_column_resize_x_fixed<1)
     {
      // --- Remember the current X-coordinate and column width
      m_column_resize_x_fixed    =x;
      m_column_resize_prev_width =m_columns[m_column_resize_control].m_width;
      m_column_resize_prev_thumb =m_scrollh.CurrentPos();
     }
// --- Calculate the new width for the column
   int new_width=m_column_resize_prev_width+(x-m_column_resize_x_fixed);
// --- Leave unchanged if less than the established limit
   if(new_width<m_min_column_width)
      return;
// --- Save the new column width
   m_columns[m_column_resize_control].m_width=new_width;
// --- Calculate table dimensions
   CalculateTableSize();
// --- Set new table size
   ChangeTableSize();
// --- Adjust the scroll bar slider if its position has changed
   if(m_scrollh.CurrentPos()!=m_column_resize_prev_thumb)
     {
      m_scrollh.MovingThumb(m_column_resize_prev_thumb);
      // --- Adjusting the table relative to scroll bars
      ShiftTable();
     }
// --- Let's draw a table
   DrawTable(true);
   Update();
   if(m_scrollh.IsScroll())
      m_scrollh.Update(true);
   if(m_scrollv.IsScroll())
      m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
// | Check Column Range Out of Range |
//+------------------------------------------------------------------+
template<typename T>
int CTable::CheckArraySize(const T &array[])
  {
   int total=0;
   int array_size=::ArraySize(array);
// --- Exit if a zero-size array is passed
   if(array_size<1)
      return(WRONG_VALUE);
// --- Adjust value to prevent array from going out of range
   total=(array_size<(int)m_columns_total)? array_size :(int)m_columns_total;
// --- Return adjusted array size
   return(total);
  }
//+------------------------------------------------------------------+
// | Check Column Range Out of Range |
//+------------------------------------------------------------------+
bool CTable::CheckOutOfColumnRange(const uint column_index)
  {
// --- Check for out-of-range columns
   uint csize=::ArraySize(m_columns);
   if(csize<1 || column_index>=csize)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Check out of range columns and rows |
//+------------------------------------------------------------------+
bool CTable::CheckOutOfRange(const uint column_index,const uint row_index)
  {
// --- Check for out-of-range columns
   uint csize=::ArraySize(m_columns);
   if(csize<1 || column_index>=csize)
      return(false);
// --- Check for out of range rows
   uint rsize=::ArraySize(m_columns[column_index].m_rows);
   if(rsize<1 || row_index>=rsize)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Calculation taking into account the latest changes and changing table sizes |
//+------------------------------------------------------------------+
void CTable::RecalculateAndResizeTable(const bool redraw=false)
  {
// --- Calculate table dimensions
   CalculateTableSize();
// --- Set new table size
   ChangeTableSize();
// --- Update table
   Update(redraw);
//---
   if(RowsTotal()>(uint)VisibleRowsTotal())
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,0,0.0,"");
  }
//+------------------------------------------------------------------+
// | Initialize the specified column with default values ​​|
//+------------------------------------------------------------------+
void CTable::ColumnInitialize(const uint column_index)
  {
// ---Initialize column properties to default values
   m_columns[column_index].m_x              =0;
   m_columns[column_index].m_x2             =0;
   m_columns[column_index].m_width          =m_default_width;
   m_columns[column_index].m_data_type      =m_default_type_data;
   m_columns[column_index].m_text_align     =m_default_text_align;
   m_columns[column_index].m_text_x_offset  =m_label_x_gap;
   m_columns[column_index].m_image_x_offset =m_icon_x_gap;
   m_columns[column_index].m_image_y_offset =m_icon_y_gap;
   m_columns[column_index].m_header_text    ="";
  }
//+------------------------------------------------------------------+
// | Initialize the specified cell with default values ​​|
//+------------------------------------------------------------------+
void CTable::CellInitialize(const uint column_index,const uint row_index)
  {
   m_columns[column_index].m_rows[row_index].m_full_text      ="";
   m_columns[column_index].m_rows[row_index].m_short_text     ="";
   m_columns[column_index].m_rows[row_index].m_selected_image =0;
   m_columns[column_index].m_rows[row_index].m_text_color     =m_label_color;
   m_columns[column_index].m_rows[row_index].m_back_color     =m_back_color;
   m_columns[column_index].m_rows[row_index].m_digits         =0;
   m_columns[column_index].m_rows[row_index].m_type           =CELL_SIMPLE;
// --- By default, a cell has no images
   ::ArrayFree(m_columns[column_index].m_rows[row_index].m_images);
  }
//+------------------------------------------------------------------+
// | Makes a copy of the specified column (source) to a new location (dest.) |
//+------------------------------------------------------------------+
void CTable::ColumnCopy(const uint destination,const uint source)
  {
   m_columns[destination].m_header_text    =m_columns[source].m_header_text;
   m_columns[destination].m_width          =m_columns[source].m_width;
   m_columns[destination].m_data_type      =m_columns[source].m_data_type;
   m_columns[destination].m_text_align     =m_columns[source].m_text_align;
   m_columns[destination].m_text_x_offset  =m_columns[source].m_text_x_offset;
   m_columns[destination].m_image_x_offset =m_columns[source].m_image_x_offset;
   m_columns[destination].m_image_y_offset =m_columns[source].m_image_y_offset;
  }
//+------------------------------------------------------------------+
// | Makes a copy of the specified cell (source) to a new location (dest.) |
//+------------------------------------------------------------------+
void CTable::CellCopy(const uint column_dest,const uint row_dest,const uint column_source,const uint row_source)
  {
   m_columns[column_dest].m_rows[row_dest].m_type           =m_columns[column_source].m_rows[row_source].m_type;
   m_columns[column_dest].m_rows[row_dest].m_digits         =m_columns[column_source].m_rows[row_source].m_digits;
   m_columns[column_dest].m_rows[row_dest].m_full_text      =m_columns[column_source].m_rows[row_source].m_full_text;
   m_columns[column_dest].m_rows[row_dest].m_short_text     =m_columns[column_source].m_rows[row_source].m_short_text;
   m_columns[column_dest].m_rows[row_dest].m_text_color     =m_columns[column_source].m_rows[row_source].m_text_color;
   m_columns[column_dest].m_rows[row_dest].m_back_color     =m_columns[column_source].m_rows[row_source].m_back_color;
   m_columns[column_dest].m_rows[row_dest].m_selected_image =m_columns[column_source].m_rows[row_source].m_selected_image;
// --- Copy the array size from the source to the destination
   int images_total=::ArraySize(m_columns[column_source].m_rows[row_source].m_images);
   ::ArrayResize(m_columns[column_dest].m_rows[row_dest].m_images,images_total);
//---
   for(int i=0; i<images_total; i++)
     {
      // --- Copy if there are pictures
      if(m_columns[column_source].m_rows[row_source].m_images[i].DataTotal()<1)
         continue;
      // --- Making a copy of the image
      ImageCopy(m_columns[column_dest].m_rows[row_dest].m_images,m_columns[column_source].m_rows[row_source].m_images,i);
     }
  }
//+------------------------------------------------------------------+
// | Copies image data from one array to another |
//+------------------------------------------------------------------+
void CTable::ImageCopy(CImage &destination[],CImage &source[],const int index)
  {
// --- Copy the pixels of the image
   destination[index].CopyImageData(source[index]);
// --- Copy the properties of the image
   destination[index].Width(source[index].Width());
   destination[index].Height(source[index].Height());
   destination[index].BmpPath(source[index].BmpPath());
  }
//+------------------------------------------------------------------+
// | Returns text |
//+------------------------------------------------------------------+
string CTable::Text(const int column_index,const int row_index)
  {
   string text="";
// --- We adjust the text if not in the mode of changing the column width
   if(m_column_resize_control==WRONG_VALUE)
      text=CorrectingText(column_index,row_index);
// --- If in the mode of changing the column width, then...
   else
     {
      // --- ...we adjust the text only for the column whose width we change
      if(column_index==m_column_resize_control)
         text=CorrectingText(column_index,row_index);
      // --- For everyone else, we use the previously corrected text
      else
         text=m_columns[column_index].m_rows[row_index].m_short_text;
     }
// --- Let's return the text
   return(text);
  }
//+------------------------------------------------------------------+
// | Returns the X-coordinate of the text in the specified column |
//+------------------------------------------------------------------+
int CTable::TextX(const int column_index,const bool headers=false)
  {
   int x=0;
// --- Align text in cells according to the specified mode for each column
   switch(m_columns[column_index].m_text_align)
     {
      // --- Center
      case ALIGN_CENTER :
         x=m_columns[column_index].m_x+(m_columns[column_index].m_width/2);
         break;
         // --- Right
      case ALIGN_RIGHT :
        {
         int x_offset=0;
         //---
         if(headers)
           {
            bool condition=(m_is_sorted_column_index!=WRONG_VALUE && m_is_sorted_column_index==column_index);
            x_offset=(condition)? m_label_x_gap+m_sort_arrow_x_gap : m_label_x_gap;
           }
         else
            x_offset=m_columns[column_index].m_text_x_offset;
         //---
         x=m_columns[column_index].m_x2-x_offset;
         break;
        }
      // --- Left
      case ALIGN_LEFT :
         x=m_columns[column_index].m_x+((headers)? m_label_x_gap : m_columns[column_index].m_text_x_offset);
         break;
     }
// --- Restore alignment method
   return(x);
  }
//+------------------------------------------------------------------+
// | Returns how the text in the specified column is aligned |
//+------------------------------------------------------------------+
uint CTable::TextAlign(const int column_index,const uint anchor)
  {
   uint text_align=0;
// --- Text alignment for the current column
   switch(m_columns[column_index].m_text_align)
     {
      case ALIGN_CENTER :
         text_align=TA_CENTER|anchor;
         break;
      case ALIGN_RIGHT :
         text_align=TA_RIGHT|anchor;
         break;
      case ALIGN_LEFT :
         text_align=TA_LEFT|anchor;
         break;
     }
// --- Restore alignment method
   return(text_align);
  }
//+------------------------------------------------------------------+
// | Returns the cell text color |
//+------------------------------------------------------------------+
uint CTable::TextColor(const int column_index,const int row_index)
  {
   uint clr=(row_index==m_selected_item)? m_selected_row_text_color : m_columns[column_index].m_rows[row_index].m_text_color;
// --- Return title color
   return(::ColorToARGB(clr));
  }
//+------------------------------------------------------------------+
// | Returns the background color of a cell |
//+------------------------------------------------------------------+
uint CTable::BackColor(const int column_index,const int row_index)
  {
   uint clr=(row_index==m_selected_item)? m_selected_row_color : m_columns[column_index].m_rows[row_index].m_back_color;
// --- Return title color
   return(::ColorToARGB(clr));
  }
//+------------------------------------------------------------------+
// | Returns the current header background color |
//+------------------------------------------------------------------+
uint CTable::HeaderColorCurrent(const bool is_header_focus)
  {
   uint clr=clrNONE;
// ---If there is no focus
   if(!is_header_focus || !m_headers.MouseFocus())
      clr=m_headers_color;
   else
     {
      // --- If the left mouse button is pressed and not in the process of changing the column width
      bool condition=(m_mouse.LeftButtonState() && m_column_resize_control==WRONG_VALUE);
      clr=(condition)? m_headers_color_pressed : m_headers_color_hover;
     }
// --- Return title color
   return(::ColorToARGB(clr,m_alpha));
  }
//+------------------------------------------------------------------+
// | Returns the current background color of a row |
//+------------------------------------------------------------------+
uint CTable::RowColorCurrent(const int column_index,const int row_index,const bool is_row_focus)
  {
// --- If the selected line
   if(row_index==m_selected_item)
      return(::ColorToARGB(m_selected_row_color,m_alpha));
// --- Row color
   uint clr=m_cell_color;
// --- If (1) there is no focus or (2) in the process of changing the column width or (3) the form is locked
   bool condition=(!is_row_focus || !m_table.MouseFocus() || m_column_resize_control!=WRONG_VALUE || m_main.CElementBase::IsLocked());
// --- When Zebra formatting mode is enabled
   if(m_is_zebra_format_rows!=clrNONE)
     {
      if(condition)
         clr=(row_index%2!=0)? m_is_zebra_format_rows : m_cell_color;
      else
         clr=m_cell_color_hover;
     }
   else
     {
      clr=(condition)? m_columns[column_index].m_rows[row_index].m_back_color : m_cell_color_hover;
     }
// ---Return color
   return(::ColorToARGB(clr,m_alpha));
  }
//+------------------------------------------------------------------+
// | Returns adjusted text to fit the column width |
//+------------------------------------------------------------------+
string CTable::CorrectingText(const int column_index,const int row_index,const bool headers=false)
  {
// --- Get the current text
   string corrected_text=(headers)? m_columns[column_index].m_header_text : m_columns[column_index].m_rows[row_index].m_full_text;
// --- Indents from cell edges along the X axis
   int x_offset=0;
//---
   if(headers)
      x_offset=(m_is_sorted_column_index==WRONG_VALUE)? m_label_x_gap*2 : m_label_x_gap+m_sort_arrow_x_gap;
   else
      x_offset=m_label_x_gap+m_columns[column_index].m_text_x_offset;
// --- Get a pointer to the canvas object
   CRectCanvas *obj=(headers)? ::GetPointer(m_headers) : ::GetPointer(m_table);
// --- Get the width of the text
   int full_text_width=obj.TextWidth(corrected_text);
// --- Line space
   int space_width=m_columns[column_index].m_width-x_offset;
// --- If we fit it into a cell, save the adjusted text in a separate array and return it
   if(full_text_width<=space_width)
     {
      // --- If these are not headings, save the corrected text
      if(!headers)
         m_columns[column_index].m_rows[row_index].m_short_text=corrected_text;
      //---
      return(corrected_text);
     }
// --- If the text does not fit into the cell, you need to correct it (cut off extra characters and add an ellipsis)
   else
     {
      // --- To work with a string
      string temp_text="";
      // --- Get the length of the string
      int total=::StringLen(corrected_text);
      // --- We will delete one character at a time from the line until we reach the desired text width
      for(int i=total-1; i>=0; i--)
        {
         // --- Delete one character
         temp_text=::StringSubstr(corrected_text,0,i);
         // --- If there is nothing left, leave an empty line
         if(temp_text=="")
           {
            corrected_text="";
            break;
           }
         // --- Add an ellipsis before the check
         int text_width=obj.TextWidth(temp_text+"...");
         // --- If we fit into a cell
         if(text_width<space_width)
           {
            // --- Save the text and stop the loop
            corrected_text=temp_text+"...";
            break;
           }
        }
     }
// --- If these are not headings, save the corrected text
   if(!headers)
      m_columns[column_index].m_rows[row_index].m_short_text=corrected_text;
// --- Return the adjusted text
   return(corrected_text);
  }
//+------------------------------------------------------------------+
// | Moving an element |
//+------------------------------------------------------------------+
void CTable::Moving(const bool only_visible=true)
  {
// --- Exit if element is hidden
   if(only_visible)
      if(!CElementBase::IsVisible())
         return;
// --- If the anchor is on the right
   if(m_anchor_right_window_side)
     {
      // ---Saving coordinates in element fields
      CElementBase::X(m_main.X2()-XGap());
      // ---Saving coordinates in object fields
      m_table.X(m_main.X2()-m_table.XGap());
      m_headers.X(m_main.X2()-m_headers.XGap());
     }
   else
     {
      CElementBase::X(m_main.X()+XGap());
      m_table.X(m_main.X()+m_table.XGap());
      m_headers.X(m_main.X()+m_headers.XGap());
     }
// --- If the binding is below
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_main.Y2()-YGap());
      m_table.Y(m_main.Y2()-m_table.YGap());
      m_headers.Y(m_main.Y2()-m_headers.YGap());
     }
   else
     {
      CElementBase::Y(m_main.Y()+YGap());
      m_table.Y(m_main.Y()+m_table.YGap());
      m_headers.Y(m_main.Y()+m_headers.YGap());
     }
// --- Updating the coordinates of graphic objects
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_XDISTANCE,m_table.X());
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YDISTANCE,m_table.Y());
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_XDISTANCE,m_headers.X());
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_YDISTANCE,m_headers.Y());
// --- Move remaining elements
   CElement::Moving(only_visible);
  }
//+------------------------------------------------------------------+
// | Shows element |
//+------------------------------------------------------------------+
void CTable::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Visibility state
   CElementBase::IsVisible(true);
// ---Move element
   Moving();
// --- Make all objects visible
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
//---
   if(!m_is_disabled_scrolls)
     {
      if(m_scrollv.IsScroll())
         m_scrollv.Show();
      if(m_scrollh.IsScroll())
         m_scrollh.Show();
     }
  }
//+------------------------------------------------------------------+
// | Hides the element |
//+------------------------------------------------------------------+
void CTable::Hide(void)
  {
// --- Exit if element is already hidden
   if(!CElementBase::IsVisible())
      return;
// --- Hide all objects
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   m_scrollv.Hide();
   m_scrollh.Hide();
// --- Visibility state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CTable::Delete(void)
  {
// --- Deleting graphic objects
   m_table.Destroy();
   m_canvas.Destroy();
   m_headers.Destroy();
   m_column_resize.Delete();
// --- Freeing element arrays
   for(uint c=0; c<m_columns_total; c++)
     {
      for(uint r=0; r<m_rows_total; r++)
        {
         for(int i=0; i<ImagesTotal(c,r); i++)
            m_columns[c].m_rows[r].m_images[i].DeleteImageData();
         //---
         ::ArrayFree(m_columns[c].m_rows[r].m_images);
        }
     }
//---
   for(uint c=0; c<m_columns_total; c++)
      ::ArrayFree(m_columns[c].m_rows);
//---
   uint total=ArraySize(m_sort_arrows);
   for(uint i=0; i<total; i++)
      m_sort_arrows[i].DeleteImageData();
//---
   ::ArrayFree(m_rows);
   ::ArrayFree(m_columns);
   ::ArrayFree(m_sort_arrows);
// --- Initializing variables to default values
   CElementBase::IsVisible(true);
   m_is_sorted_column_index=WRONG_VALUE;
  }
//+------------------------------------------------------------------+
// | Setting Priorities |
//+------------------------------------------------------------------+
void CTable::SetZorders(void)
  {
   CElement::SetZorders();
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
  }
//+------------------------------------------------------------------+
// | Reset priorities |
//+------------------------------------------------------------------+
void CTable::ResetZorders(void)
  {
   CElement::ResetZorders();
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_ZORDER,WRONG_VALUE);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_ZORDER,WRONG_VALUE);
  }
//+------------------------------------------------------------------+
// | Fast forward scroll bar |
//+------------------------------------------------------------------+
void CTable::FastSwitching(void)
  {
// --- Exit if there is no focus on the list
   if(!CElementBase::MouseFocus())
      return;
// --- Return the counter to its original value if the mouse button is released
   if(!m_mouse.LeftButtonState() || m_scrollv.State() || m_scrollh.State())
      m_timer_counter=SPIN_DELAY_MSC;
// --- If the mouse button is pressed
   else
     {
      // --- Increase the counter by the set interval
      m_timer_counter+=TIMER_STEP_MSC;
      // --- Exit if less than zero
      if(m_timer_counter<0)
         return;
      //---
      bool scroll_v=false,scroll_h=false;
      // ---If scroll up
      if(m_scrollv.GetIncButtonPointer().MouseFocus())
        {
         m_scrollv.OnClickScrollInc((uint)Id(),0);
         scroll_v=true;
        }
      // --- If scroll down
      else if(m_scrollv.GetDecButtonPointer().MouseFocus())
        {
         m_scrollv.OnClickScrollDec((uint)Id(),1);
         scroll_v=true;
        }
      // --- If scroll left
      else if(m_scrollh.GetIncButtonPointer().MouseFocus())
        {
         m_scrollh.OnClickScrollInc((uint)Id(),2);
         scroll_h=true;
        }
      // --- If scroll to the right
      else if(m_scrollh.GetDecButtonPointer().MouseFocus())
        {
         m_scrollh.OnClickScrollDec((uint)Id(),3);
         scroll_h=true;
        }
      // --- Exit if no button is pressed
      if(!scroll_v && !scroll_h)
         return;
      // --- Offsets the table
      ShiftTable();
      // --- Refresh scrollbars
      if(scroll_v) m_scrollv.Update(true);
      if(scroll_h) m_scrollh.Update(true);
     }
  }
//+------------------------------------------------------------------+
// | Calculates table sizes |
//+------------------------------------------------------------------+
void CTable::CalculateTableSize(void)
  {
// --- Calculate the total width and height of the table
   CalculateTableXSize();
   CalculateTableYSize();
// --- Calculates the visible dimensions of the table (twice in case you need to show both scroll bars)
   for(int i=0; i<2; i++)
     {
      CalculateTableVisibleXSize();
      CalculateTableVisibleYSize();
     }
  }
//+------------------------------------------------------------------+
// | Calculates the full size of the table along the X axis |
//+------------------------------------------------------------------+
void CTable::CalculateTableXSize(void)
  {
// --- Calculate the total width of the table
   m_table_x_size=0;
   for(uint c=0; c<m_columns_total; c++)
      m_table_x_size=m_table_x_size+m_columns[c].m_width;
  }
//+------------------------------------------------------------------+
// | Calculates the full size of the table along the Y axis |
//+------------------------------------------------------------------+
void CTable::CalculateTableYSize(void)
  {
// --- Calculate the total height of the table
   m_table_y_size=(int)(m_cell_y_size*m_rows_total)+1;
  }
//+------------------------------------------------------------------+
// | Calculates the apparent size of the table along the X axis |
//+------------------------------------------------------------------+
void CTable::CalculateTableVisibleXSize(void)
  {
   if(m_is_disabled_scrolls)
     {
      m_table_visible_x_size=m_table_x_size-1;
      return;
     }
// --- Table width taking into account the presence of a vertical scroll bar
   int x_size=(m_table_y_size>m_table_visible_y_size) ? m_x_size-m_scrollh.ScrollWidth()-2 : m_x_size-2;
// --- Set the width of the frame to display a fragment of the image (the visible part of the table table)
   m_table_visible_x_size=x_size;
// ---Adjusting the size of the visible part along the X axis
   m_table_visible_x_size=(m_table_visible_x_size>=m_table_x_size)? m_table_x_size : m_table_visible_x_size;
// --- Let's keep the offset constraint
   m_shift_x2_limit=m_table_x_size-m_table_visible_x_size;
  }
//+------------------------------------------------------------------+
// | Calculates the apparent size of the table along the Y axis |
//+------------------------------------------------------------------+
void CTable::CalculateTableVisibleYSize(void)
  {
   if(m_is_disabled_scrolls)
     {
      m_table_visible_y_size=m_table_y_size-1;
      return;
     }
// --- Calculation of the number of steps for displacement
   uint x_size_total         =m_table_x_size/m_shift_x_step;
   uint visible_x_size_total =m_table_visible_x_size/m_shift_x_step;
// --- If there are headings and horizons. scroll bar, then adjust the size of the element along the Y axis
   int header_y_size=(m_show_headers)? m_header_y_size : 2;
   int y_size=(x_size_total>visible_x_size_total) ? m_y_size-header_y_size-m_scrollv.ScrollWidth()-2 : m_y_size-header_y_size-2;
// --- Set the height of the frame to display a fragment of the image (the visible part of the table table)
   m_table_visible_y_size=y_size;
// ---Adjusting the size of the visible part along the Y axis
   m_table_visible_y_size=(m_table_visible_y_size>=m_table_y_size)? m_table_y_size : m_table_visible_y_size;
// --- Let's keep the offset constraint
   m_shift_y2_limit=m_table_y_size-m_table_visible_y_size;
  }
//+------------------------------------------------------------------+
// | Change main table dimensions |
//+------------------------------------------------------------------+
void CTable::ChangeMainSize(const int x_size,const int y_size)
  {
// --- Set a new size for the table background
   CElementBase::XSize(x_size);
   CElementBase::YSize(y_size);
   m_canvas.XSize(x_size);
   m_canvas.YSize(y_size);
   m_canvas.Resize(x_size,y_size);
  }
//+------------------------------------------------------------------+
// | Resize table |
//+------------------------------------------------------------------+
void CTable::ChangeTableSize(void)
  {
// --- Set new table size
   m_table.XSize(m_table_visible_x_size);
   m_table.YSize(m_table_visible_y_size);
   m_headers.XSize(m_table_visible_x_size);
   m_headers.YSize(m_header_y_size);
   m_table.Resize(m_table_x_size,m_table_y_size);
   m_headers.Resize(m_table_x_size,m_header_y_size);
// --- Set the size of the visible area
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_XSIZE,m_table_visible_x_size);
   ::ObjectSetInteger(m_chart_id,m_table.ChartObjectName(),OBJPROP_YSIZE,m_table_visible_y_size);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_XSIZE,m_table_visible_x_size);
   ::ObjectSetInteger(m_chart_id,m_headers.ChartObjectName(),OBJPROP_YSIZE,m_header_y_size);
// --- Resize scrollbars
   ChangeScrollsSize();
// --- Data correction
   ShiftTable();
  }
//+------------------------------------------------------------------+
// | Resize scrollbars |
//+------------------------------------------------------------------+
void CTable::ChangeScrollsSize(void)
  {
// --- Calculation of the number of steps for displacement
   uint x_size_total         =m_table_x_size/m_shift_x_step;
   uint visible_x_size_total =m_table_visible_x_size/m_shift_x_step;
   uint y_size_total         =RowsTotal();
   uint visible_y_size_total =VisibleRowsTotal();
// --- Calculate scrollbar sizes
   m_scrollh.Reinit(x_size_total,visible_x_size_total);
   m_scrollv.Reinit(y_size_total,visible_y_size_total);
// --- If the horizontal scroll bar is not needed
   if(!m_scrollh.IsScroll())
     {
      // --- Hide horizontal scrollbar
      m_scrollh.Hide();
      // --- Calculate and change the height of the vertical scrollbar
      int y_size=CElementBase::YSize()-2;
      m_scrollv.ChangeYSize(y_size);
     }
   else
     {
      // --- Show horizontal scroll bar
      if(CElementBase::IsVisible() && !m_is_disabled_scrolls)
         m_scrollh.Show();
      // --- Calculate and change the height of the vertical scrollbar
      int y_size=CElementBase::YSize()-m_scrollh.ScrollWidth()-2;
      m_scrollv.ChangeYSize(y_size);
     }
// --- If the vertical scroll bar is not needed
   if(!m_scrollv.IsScroll())
     {
      // --- Hide vertical scroll bar
      m_scrollv.Hide();
      // --- Change the width of the horizontal scroll bar
      int x_size=CElementBase::XSize()-1;
      m_scrollh.ChangeXSize(x_size);
     }
   else
     {
      // --- Show vertical scroll bar
      if(CElementBase::IsVisible() && !m_is_disabled_scrolls)
         m_scrollv.Show();
      // --- Calculate and change the width of the horizontal scrollbar
      int x_size=CElementBase::XSize()-m_scrollv.ScrollWidth()-1;
      m_scrollh.ChangeXSize(x_size);
     }
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CTable::ChangeWidthByRightWindowSide(void)
  {
// --- Exit if the mode of fixing to the right edge of the form is enabled
   if(m_anchor_right_window_side)
      return;
// --- Dimensions
   int x_size =m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
   int y_size =(m_auto_yresize_mode)? m_main.Y2()-m_canvas.Y()-m_auto_yresize_bottom_offset : m_y_size;
// --- Exit if size is less than specified
   if(x_size<100)
      return;
// --- Set new table background size
   ChangeMainSize(x_size,y_size);
// --- Calculate table dimensions
   CalculateTableSize();
// --- Set new table size
   ChangeTableSize();
// --- Let's draw a table
   DrawTable();
   if(m_scrollh.IsScroll())
      m_scrollh.Update(true);
   if(m_scrollv.IsScroll())
      m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
// | Change the height along the bottom edge of the window |
//+------------------------------------------------------------------+
void CTable::ChangeHeightByBottomWindowSide(void)
  {
// --- Exit if the mode of fixing to the bottom edge of the form is enabled
   if(m_anchor_bottom_window_side)
      return;
// --- Dimensions
   int x_size =(m_auto_xresize_mode)? m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset : m_x_size;
   int y_size =m_main.Y2()-m_canvas.Y()-m_auto_yresize_bottom_offset;
// --- Exit if size is less than specified
   if(y_size<60)
      return;
// --- Set new table background size
   ChangeMainSize(x_size,y_size);
// --- Calculate table dimensions
   CalculateTableSize();
// --- Set new table size
   ChangeTableSize();
// --- Let's draw a table
   DrawTable();
   if(m_scrollh.IsScroll())
      m_scrollh.Update(true);
   if(m_scrollv.IsScroll())
      m_scrollv.Update(true);
// --- Update
   Update(true);
  }
//+------------------------------------------------------------------+
