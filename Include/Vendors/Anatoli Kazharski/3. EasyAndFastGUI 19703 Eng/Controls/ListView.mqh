//+------------------------------------------------------------------+
//|                                                     ListView.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Scrolls.mqh"
//+------------------------------------------------------------------+
// | Class for creating a list |
//+------------------------------------------------------------------+
class CListView : public CElement
  {
private:
   // --- Objects for creating a list
   CRectCanvas       m_listview;
   CScrollV          m_scrollv;
   // --- Array of list item properties
   struct LVItemOptions
     {
      int               m_y;     // Y-coordinate of the top edge of the string
      int               m_y2;    // Y-coordinate of the bottom edge of the line
      string            m_value; // Item text
      bool              m_state; // Checkbox state
     };
   LVItemOptions     m_items[];
   // --- Size of the list and its visible part
   int               m_items_total;
   // --- Overall size and size of the visible part of the list
   int               m_list_y_size;
   int               m_list_visible_y_size;
   // --- General list offset
   int               m_y_offset;
   // --- Y axis point size
   int               m_item_y_size;
   // --- (1) Index and (2) text of the selected item
   int               m_selected_item;
   string            m_selected_item_text;
   // --- Index of the previous selected item
   int               m_prev_selected_item;
   // --- To determine the focus of a row
   int               m_item_index_focus;
   // --- To determine the moment the mouse cursor moves from one line to another
   int               m_prev_item_index_focus;
   // --- List mode with checkboxes
   bool              m_checkbox_mode;
   // --- To calculate the boundaries of the visible part of the input field
   int               m_y_limit;
   int               m_y2_limit;
   // ---Hover highlight mode
   bool              m_lights_hover;
   // --- Timer counter for list rewind
   int               m_timer_counter;
   // --- To determine the indexes of the visible part of the list
   int               m_visible_list_from_index;
   int               m_visible_list_to_index;
   //---
public:
                     CListView(void);
                    ~CListView(void);
   // --- Methods for creating a list
   bool              CreateListView(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateList(void);
   bool              CreateScrollV(void);
   //---
public:
   // --- Returns a pointer to the scroll bar
   CScrollV         *GetScrollVPointer(void) { return(::GetPointer(m_scrollv)); }
   // --- (1) Item height, returns (2) the size of the list and (3) the visible part of it
   void              ItemYSize(const int y_size)                         { m_item_y_size=y_size;         }
   int               ItemsTotal(void)                              const { return(::ArraySize(m_items)); }
   int               VisibleItemsTotal(void);
   // --- (1) Scrollbar state, (2) hover highlighting mode, (3) list mode with checkboxes
   bool              ScrollState(void)                             const { return(m_scrollv.State());    }
   void              LightsHover(const bool state)                       { m_lights_hover=state;         }
   void              CheckBoxMode(const bool state)                      { m_checkbox_mode=state;        }
   // --- Returns (1) the index and (2) the text of the selected item in the list
   int               SelectedItemIndex(void)                       const { return(m_selected_item);      }
   string            SelectedItemText(void)                        const { return(m_selected_item_text); }
   // --- Set shortcuts for the button in the pressed state (available/locked)
   void              IconFilePressed(const string file_path);
   void              IconFilePressedLocked(const string file_path);
   // --- (1) Set value, (2) get value, (3) get state
   void              SetValue(const uint item_index,const string value,const bool redraw=false);
   string            GetValue(const uint item_index);
   bool              GetState(const uint item_index);
   // --- Select an item
   void              SelectItem(const uint item_index,const bool redraw=false);
   // --- Setting (1) the size of the list and (2) the visible part of it
   void              ListSize(const int items_total);
   // --- List reconstruction
   void              Rebuilding(const int items_total,const bool redraw=false);
   // --- Adds an item to the list
   void              AddItem(const int item_index,const string value="",const bool redraw=false);
   // --- Removes an item from the list
   void              DeleteItem(const int item_index,const bool redraw=false);
   // --- Clears the list (removing all items)
   void              Clear(const bool redraw=false);
   // --- Scroll the list
   void              Scrolling(const int pos=WRONG_VALUE);
   // --- Resizing
   void              ChangeSize(const uint x_size,const uint y_size);
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
   // --- Draws an element
   virtual void      Draw(void);
   // --- Item update
   virtual void      Update(const bool redraw=false);
   //---
private:
   // --- Handling clicks on a list item
   bool              OnClickList(const string pressed_object);
   // --- Returns the index of the item clicked on
   int               PressedItemIndex(void);

   // --- Change the color of list items on hover
   void              ChangeItemsColor(void);
   // --- Checking list line focus on hover
   int               CheckItemFocus(void);
   // --- List offset relative to scrollbar position
   void              ShiftData(void);
   // --- Fast forward list
   void              FastSwitching(void);

   // --- Calculates list size
   void              CalculateListYSize(void);
   // --- Change the basic dimensions of an element
   void              ChangeMainSize(const int x_size,const int y_size);
   // --- Resize list
   void              ChangeListSize(void);
   // --- Resize scrollbars
   void              ChangeScrollsSize(void);

   // --- Calculation taking into account the latest changes and resizing the list
   void              RecalculateAndResizeList(const bool redraw=false);
   // --- Initialize the specified item with default values
   void              ItemInitialize(const uint item_index);
   // --- Makes a copy of the specified item (source) to a new location (dest.)
   void              ItemCopy(const uint item_dest,const uint item_source);

   // --- Calculation of the Y-coordinate of a point
   int               CalculationItemY(const int item_index=0);
   // --- Calculation of point width
   int               CalculationItemsWidth(void);
   // --- Calculation of input field boundaries along the Y axis
   void              CalculateYBoundaries(void);
   // ---Adjusting the vertical scroll bar
   void              CorrectingVerticalScrollThumb(void);
   // --- Calculate the Y-position of the scroll bar slider
   int               CalculateScrollPosY(const bool to_down=false);
   // --- Calculate the Y-coordinates of the scroll bar at the top/bottom border of the list
   int               CalculateScrollThumbY(void);
   int               CalculateScrollThumbY2(void);
   // --- Determining the indexes of the visible list area
   void              VisibleListIndexes(void);

   // --- Draws a list
   virtual void      DrawList(const bool only_visible=false);
   // --- Draws a frame
   virtual void      DrawBorder(void);
   // --- Draws pictures of items
   virtual void      DrawImages(void);
   // --- Draws a picture
   virtual void      DrawImage(void);
   // --- Draws the text of the items
   virtual void      DrawText(void);

   // --- Redraws the specified list item
   void              RedrawItem(const int item_index);
   // --- Redraws list items according to the specified mode
   void              RedrawItemsByMode(const bool is_selected_row=false);
   // --- Returns the current background color of the item
   uint              ItemColorCurrent(const int item_index,const bool is_item_focus);
   // --- Returns the text color of the item
   uint              TextColor(const int item_index);

   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   // --- Change the height along the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CListView::CListView(void) : m_item_y_size(18),
                             m_lights_hover(false),
                             m_items_total(0),
                             m_y_offset(0),
                             m_checkbox_mode(false),
                             m_selected_item(WRONG_VALUE),
                             m_selected_item_text(""),
                             m_prev_selected_item(WRONG_VALUE),
                             m_item_index_focus(WRONG_VALUE),
                             m_prev_item_index_focus(WRONG_VALUE),
                             m_visible_list_from_index(WRONG_VALUE),
                             m_visible_list_to_index(WRONG_VALUE)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
// --- Set the size of the list and its visible part
   ListSize(m_items_total);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CListView::~CListView(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CListView::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Shift the list if the scroll bar control is in action
      if(m_scrollv.ScrollBarControl())
        {
         // --- Refresh list and scrollbar
         ShiftData();
         m_scrollv.Update(true);
         return;
        }
      // --- Reset color
      if(!CElementBase::MouseFocus())
        {
         if(m_prev_item_index_focus==WRONG_VALUE)
            return;
         // --- Remove focus
         m_canvas.MouseFocus(false);
         // --- Changes the color of list rows on hover
         ChangeItemsColor();
         return;
        }
      // --- Checking focus on a list
      int x_offset=(m_scrollv.IsVisible())? m_scrollv.ScrollWidth() : 0;
      m_canvas.MouseFocus(m_mouse.X()>m_canvas.X() && m_mouse.X()<X2()-x_offset && 
                          m_mouse.Y()>m_canvas.Y() && m_mouse.Y()<m_canvas.Y2());
      // --- Changes the color of list rows on hover
      ChangeItemsColor();
      // --- Define the mouse wheel scroll tracking mode
      if(m_canvas.MouseFocus())
         ::ChartSetInteger(m_chart_id,CHART_EVENT_MOUSE_WHEEL,true);
      else
         ::ChartSetInteger(m_chart_id,CHART_EVENT_MOUSE_WHEEL,false);
      return;
     }
// --- Handling mouse wheel event
   if(id==CHARTEVENT_MOUSE_WHEEL)
     {
      // --- Get the current scrollbar position
      int pos=(m_scrollv.CurrentPos()-1<0)? 1 : m_scrollv.CurrentPos();
      // --- If the mouse wheel has moved down
      if(dparam<0)
         Scrolling(pos+1);
      // --- If the mouse wheel has moved up
      else if(dparam>0)
         Scrolling(pos-1);
      // --- Refresh scrollbar
      m_scrollv.Update(true);
     }
// --- Handling clicks on objects
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      // --- If there was a click on the list
      if(OnClickList(sparam))
         return;
     }
// --- Handling click events on scrollbar buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      // --- If there was a click on the list scroll bar buttons
      if(m_scrollv.OnClickScrollInc((uint)lparam,(uint)dparam) ||
         m_scrollv.OnClickScrollDec((uint)lparam,(uint)dparam))
        {
         // --- Shifts the list relative to the scroll bar
         ShiftData();
         m_scrollv.Update(true);
         return;
        }
     }
  }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void CListView::OnEventTimer(void)
  {
// --- Fast forward values
   FastSwitching();
  }
//+------------------------------------------------------------------+
// | Creates a list |
//+------------------------------------------------------------------+
bool CListView::CreateListView(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// --- Calculate list sizes
   CalculateListYSize();
// --- Create a list
   if(!CreateCanvas())
      return(false);
   if(!CreateList())
      return(false);
   if(!CreateScrollV())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CListView::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x             =CElement::CalculateX(x_gap);
   m_y             =CElement::CalculateY(y_gap);
   m_x_size        =(m_x_size<0 || m_auto_xresize_mode)? m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset : m_x_size;
   m_y_size        =(m_y_size<0 || m_auto_yresize_mode)? m_main.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset : m_y_size;
   m_selected_item =(m_selected_item==WRONG_VALUE && !m_checkbox_mode) ? 0 : m_selected_item;
// ---Colors of items in different states
   m_back_color          =(m_back_color!=clrNONE)? m_back_color : clrWhite;
   m_back_color_hover    =(m_back_color_hover!=clrNONE)? m_back_color_hover : C'229,243,255';
   m_back_color_pressed  =(m_back_color_pressed!=clrNONE)? m_back_color_pressed : C'51,153,255';
   m_label_color         =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_color_hover   =(m_label_color_hover!=clrNONE)? m_label_color_hover : clrBlack;
   m_label_color_pressed =(m_label_color_pressed!=clrNONE)? m_label_color_pressed : clrWhite;
   m_border_color        =(m_border_color!=clrNONE)? m_border_color : C'150,170,180';
// --- Indents for pictures and text from the edges of cells
   m_icon_x_gap  =(m_icon_x_gap>0)? m_icon_x_gap : 7;
   m_icon_y_gap  =(m_icon_y_gap>0)? m_icon_y_gap : 4;
   m_label_x_gap =(m_label_x_gap>0)? m_label_x_gap : 5;
   m_label_y_gap =(m_label_y_gap>0)? m_label_y_gap : 4;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates a background for a list |
//+------------------------------------------------------------------+
bool CListView::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("listview");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CListView::CreateList(void)
  {
// --- Formation of object name
   string name=CElementBase::ProgramName()+"_"+"listview_array"+"_"+(string)CElementBase::Id();
// --- Size
   int x_size=m_x_size-2;
// --- Coordinates
   int x =m_x+1;
   int y =m_y+1;
// ---Create an object
   ::ResetLastError();
   if(!m_listview.CreateBitmapLabel(m_chart_id,m_subwin,name,x,y,x_size,m_list_y_size,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось создать холст для рисования списка: ",::GetLastError());
      return(false);
     }
// --- Attach to chart
   if(!m_listview.Attach(m_chart_id,name,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось присоединить холст для рисования к графику: ",::GetLastError());
      return(false);
     }
// --- Properties
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
   ::ObjectSetString(m_chart_id,m_listview.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
// --- If you need a list with checkboxes
   if(m_checkbox_mode)
     {
      IconFile(RESOURCE_CHECKBOX_OFF);
      IconFileLocked(RESOURCE_CHECKBOX_OFF_LOCKED);
      CElement::IconFilePressed(RESOURCE_CHECKBOX_ON);
      CElement::IconFilePressedLocked(RESOURCE_CHECKBOX_ON_LOCKED);
     }
// --- Coordinates
   m_listview.X(x);
   m_listview.Y(y);
// --- Let's save the dimensions
   m_listview.XSize(x_size);
   m_listview.YSize(m_list_y_size);
   m_listview.Resize(x_size,m_list_y_size);
// --- Indents from the extreme point of the panel
   m_listview.XGap(CElement::CalculateXGap(x));
   m_listview.YGap(CElement::CalculateYGap(y));
// --- Set the size of the visible area
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_XSIZE,x_size);
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YSIZE,m_list_visible_y_size);
// --- Set the offset of the frame inside the image along the X and Y axes
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_XOFFSET,0);
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YOFFSET,0);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a vertical scroll |
//+------------------------------------------------------------------+
bool CListView::CreateScrollV(void)
  {
// --- Save pointer to main element
   m_scrollv.MainPointer(this);
// --- Coordinates
   int x=16,y=1;
// --- Properties
   m_scrollv.Index((m_scrollv.Index()!=WRONG_VALUE)? m_scrollv.Index() : 0);
   m_scrollv.XSize(15);
   m_scrollv.YSize(CElementBase::YSize()-2);
   m_scrollv.IsDropdown(CElementBase::IsDropdown());
   m_scrollv.AnchorRightWindowSide(true);
// --- Calculation of the number of steps for displacement
   uint items_total         =ItemsTotal();
   uint visible_items_total =VisibleItemsTotal();
// --- Creating a scrollbar
   if(!m_scrollv.CreateScroll(x,y,items_total,visible_items_total))
      return(false);
// --- Hide the scrollbar if the visible part is larger than the list size
   if(m_list_visible_y_size>m_list_y_size)
      m_scrollv.Hide();
// --- Add element to array
   CElement::AddToArray(m_scrollv);
   return(true);
  }
//+------------------------------------------------------------------+
// | Selects the specified item |
//+------------------------------------------------------------------+
void CListView::SelectItem(const uint item_index,const bool redraw=false)
  {
// --- Exit if there are no items in the list
   if(ItemsTotal()<1)
      return;
// --- Adjustment in case of leaving the range
   int checked_index=(item_index>=(uint)m_items_total)? m_items_total-1 :(int)item_index;
// --- If this is a list with checkboxes
   if(m_checkbox_mode)
     {
      m_selected_item      =WRONG_VALUE;
      m_selected_item_text ="";
      // --- Set the opposite value to the checkbox
      m_items[checked_index].m_state=!m_items[checked_index].m_state;
      // --- Redraw the item if specified
      if(redraw)
         RedrawItem(item_index);
      //---
      return;
     }
// --- Save the index and text of the selected item
   m_selected_item      =checked_index;
   m_selected_item_text =m_items[m_selected_item].m_value;
// --- Redraw the list if specified
   if(redraw)
      Update(true);
  }
//+------------------------------------------------------------------+
// | Returns the number of visible items |
//+------------------------------------------------------------------+
int CListView::VisibleItemsTotal(void)
  {
   double visible_items_total =m_list_visible_y_size/m_item_y_size;
   double check_y_size        =visible_items_total*m_item_y_size;
//---
   visible_items_total=(check_y_size<m_list_visible_y_size+(m_y_offset*2)+1)? visible_items_total : visible_items_total;
   return((int)visible_items_total);
  }
//+------------------------------------------------------------------+
// | Setting a picture for the pressed state (available) |
//+------------------------------------------------------------------+
void CListView::IconFilePressed(const string file_path)
  {
// --- Exit if checkbox list mode is disabled
   if(!m_checkbox_mode)
      return;
// --- Add a place for the image if it doesn't exist yet
   while(!CElement::CheckOutOfRange(0,2))
      AddImage(0,"");
// --- Set picture
   CElement::SetImage(0,2,file_path);
  }
//+------------------------------------------------------------------+
// | Setting the picture for the pressed state (locked) |
//+------------------------------------------------------------------+
void CListView::IconFilePressedLocked(const string file_path)
  {
// --- Exit if checkbox list mode is disabled
   if(!m_checkbox_mode)
      return;
// --- Add a place for the image if it doesn't exist yet
   while(!CElement::CheckOutOfRange(0,3))
      AddImage(0,"");
// --- Set picture
   CElement::SetImage(0,3,file_path);
  }
//+------------------------------------------------------------------+
// | Setting a value in the list at the specified index |
//+------------------------------------------------------------------+
void CListView::SetValue(const uint item_index,const string value,const bool redraw=false)
  {
   uint array_size=ItemsTotal();
// --- If there is not a single item on the list, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в списке есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(item_index>=array_size)? array_size-1 : item_index;
// --- Save the value in the list
   m_items[i].m_value=value;
// --- Redraw the item if specified
   if(redraw)
      RedrawItem(item_index);
  }
//+------------------------------------------------------------------+
// | Getting a value in a list at a specified index |
//+------------------------------------------------------------------+
string CListView::GetValue(const uint item_index)
  {
   uint array_size=ItemsTotal();
// --- If there is not a single item on the list, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в списке есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(item_index>=array_size)? array_size-1 : item_index;
// --- Save the value in the list
   return(m_items[i].m_value);
  }
//+------------------------------------------------------------------+
// | Getting the checkbox state at the specified index |
//+------------------------------------------------------------------+
bool CListView::GetState(const uint item_index)
  {
   uint array_size=ItemsTotal();
// --- If there is not a single item on the list, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в списке есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(item_index>=array_size)? array_size-1 : item_index;
// --- Save the value in the list
   return(m_items[i].m_state);
  }
//+------------------------------------------------------------------+
// | Sets the list size |
//+------------------------------------------------------------------+
void CListView::ListSize(const int items_total)
  {
// --- It makes no sense to make a list of less than two items
   m_items_total=(items_total<1) ? 0 : items_total;
   ::ArrayResize(m_items,m_items_total);
// --- Initializing items with default values
   for(int i=0; i<m_items_total; i++)
      ItemInitialize(i);
  }
//+------------------------------------------------------------------+
// | List reconstruction |
//+------------------------------------------------------------------+
void CListView::Rebuilding(const int items_total,const bool redraw=false)
  {
// --- Set size to zero
   ListSize(items_total);
// --- Calculate and set new list sizes
   RecalculateAndResizeList(redraw);
  }
//+------------------------------------------------------------------+
// | Adds an item to the list |
//+------------------------------------------------------------------+
void CListView::AddItem(const int item_index,const string value="",const bool redraw=false)
  {
// --- Reserve quantity
   int reserve=100;
// --- Increase the size of the array by one element
   int array_size=ItemsTotal();
   m_items_total=array_size+1;
   ::ArrayResize(m_items,m_items_total,reserve);
// --- Index adjustment in case of out of range
   int checked_item_index=(item_index>=m_items_total)? m_items_total-1 : item_index;
// --- Shift other items (we move from the end of the array to the index of the item being added)
   for(int i=array_size; i>=checked_item_index; i--)
     {
      // --- Initializing a new item with default values
      if(i==checked_item_index)
        {
         ItemInitialize(i);
         m_items[i].m_value=value;
         continue;
        }
      // --- Index of previous item
      uint prev_i=i-1;
      // --- Move data from the previous paragraph to the current one
      ItemCopy(i,prev_i);
     }
// --- Calculate and set new list sizes
   RecalculateAndResizeList(redraw);
  }
//+------------------------------------------------------------------+
// | Removes an item from the list |
//+------------------------------------------------------------------+
void CListView::DeleteItem(const int item_index,const bool redraw=false)
  {
// --- Increase the size of the array by one element
   int array_size=ItemsTotal();
// --- Index adjustment in case of out of range
   int checked_item_index=(item_index>=m_items_total)? m_items_total-1 : item_index;
// --- Shift other items (we move from the specified index to the last item)
   for(int i=checked_item_index; i<array_size-1; i++)
     {
      // --- Next item index
      uint next_i=i+1;
      // --- Move data from the next item to the current one
      ItemCopy(i,next_i);
     }
// --- Reduce the size of the array by one element
   m_items_total=array_size-1;
   ::ArrayResize(m_items,m_items_total);
// --- Calculate and set new list sizes
   RecalculateAndResizeList(redraw);
  }
//+------------------------------------------------------------------+
// | Clears the list (removing all items) |
//+------------------------------------------------------------------+
void CListView::Clear(const bool redraw=false)
  {
// --- Reset auxiliary fields
   m_item_index_focus      =WRONG_VALUE;
   m_prev_selected_item    =WRONG_VALUE;
   m_prev_item_index_focus =WRONG_VALUE;
// --- Set size to zero
   ListSize(0);
// --- Calculate and set new list sizes
   RecalculateAndResizeList(redraw);
  }
//+------------------------------------------------------------------+
// | Scrolling list |
//+------------------------------------------------------------------+
void CListView::Scrolling(const int pos=WRONG_VALUE)
  {
// --- Exit if scrollbar is not needed
   if(m_list_y_size<=m_list_visible_y_size)
      return;
// --- To determine the position of the slider
   int index=0;
// ---Last position index
   int last_pos_index=m_list_y_size-m_list_visible_y_size;
// --- Adjustment in case of leaving the range
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
// --- Move the scroll bar slider
   m_scrollv.MovingThumb(index);
// --- Shift the list
   ShiftData();
  }
//+------------------------------------------------------------------+
// | Resizing |
//+------------------------------------------------------------------+
void CListView::ChangeSize(const uint x_size,const uint y_size)
  {
// --- Set new size
   CElementBase::XSize(x_size);
   CElementBase::YSize(y_size);
   m_canvas.XSize(m_x_size);
   m_canvas.YSize(m_y_size);
   m_canvas.Resize(m_x_size,m_y_size);
  }
//+------------------------------------------------------------------+
// | Change list bar color on hover |
//+------------------------------------------------------------------+
void CListView::ChangeItemsColor(void)
  {
// --- Exit if hover highlight is disabled or list scrolling is active
   if(!m_lights_hover || m_scrollv.State())
      return;
// --- Exit if the element is not a drop-down and the form is locked
   if(!CElementBase::IsDropdown() && m_main.CElementBase::IsLocked())
      return;
// ---If out of focus
   if(!m_canvas.MouseFocus())
     {
      // --- If it hasn't already been noted, it's out of focus
      if(m_prev_item_index_focus!=WRONG_VALUE)
        {
         m_item_index_focus=WRONG_VALUE;
         // --- Change color
         RedrawItemsByMode();
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
         m_item_index_focus=CheckItemFocus();
         // --- Change line color
         RedrawItemsByMode();
         // --- Save as previous index in focus
         m_prev_item_index_focus=m_item_index_focus;
         return;
        }
      // --- Get the relative Y-coordinate under the mouse cursor
      int y=m_mouse.RelativeY(m_listview);
      // --- Focus check
      bool condition=(y>m_items[m_item_index_focus].m_y && y<=m_items[m_item_index_focus].m_y2);
      // ---If the focus has changed
      if(!condition)
        {
         // --- Get the index of the row in focus
         m_item_index_focus=CheckItemFocus();
         // --- Exit if you have left the list area
         if(m_item_index_focus<0)
            return;
         // --- Change line color
         RedrawItemsByMode();
         // --- Save as previous index in focus
         m_prev_item_index_focus=m_item_index_focus;
        }
     }
  }
//+------------------------------------------------------------------+
// | Checking list line focus on hover |
//+------------------------------------------------------------------+
int CListView::CheckItemFocus(void)
  {
   int item_index_focus=WRONG_VALUE;
// --- Get the relative Y-coordinate under the mouse cursor
   int y=m_mouse.RelativeY(m_listview);
// /--- Get the indexes of the local table area
   VisibleListIndexes();
// --- Looking for focus
   for(int i=m_visible_list_from_index; i<m_visible_list_to_index; i++)
     {
      // --- If the line focus has changed
      if(y>m_items[i].m_y && y<=m_items[i].m_y2)
        {
         item_index_focus=(int)i;
         break;
        }
     }
// --- Return the index of the row in focus
   return(item_index_focus);
  }
//+------------------------------------------------------------------+
// | List offset relative to scrollbar position |
//+------------------------------------------------------------------+
void CListView::ShiftData(void)
  {
// --- Let's keep the offset constraint
   int shift_y2_limit=m_list_y_size-m_list_visible_y_size;
// --- Get the current position of the scroll bar slider
   int v_offset=(m_scrollv.CurrentPos()*m_item_y_size);
// --- Calculate the indentation for the offset
   int y_offset=(v_offset<m_y_offset)? 0 :(v_offset>=shift_y2_limit-(m_y_offset*2+1))? shift_y2_limit : v_offset;
// --- First position if there is no scroll bar
   long y=(!m_scrollv.IsVisible())? 0 : y_offset;
// ---Data offset
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YOFFSET,y);
  }
//+------------------------------------------------------------------+
// | Moving an element |
//+------------------------------------------------------------------+
void CListView::Moving(const bool only_visible=true)
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
      m_listview.X(m_main.X2()-m_listview.XGap());
     }
   else
     {
      CElementBase::X(m_main.X()+XGap());
      m_listview.X(m_main.X()+m_listview.XGap());
     }
// --- If the binding is below
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_main.Y2()-YGap());
      m_listview.Y(m_main.Y2()-m_listview.YGap());
     }
   else
     {
      CElementBase::Y(m_main.Y()+YGap());
      m_listview.Y(m_main.Y()+m_listview.YGap());
     }
// --- Updating the coordinates of graphic objects
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_XDISTANCE,m_listview.X());
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YDISTANCE,m_listview.Y());
// --- Update object position
   CElement::Moving(only_visible);
  }
//+------------------------------------------------------------------+
// | Shows list |
//+------------------------------------------------------------------+
void CListView::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Show element
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
// --- Visibility state
   CElementBase::IsVisible(true);
// --- Update object position
   Moving();
// --- Show scroll bar
   if(m_scrollv.IsScroll())
      m_scrollv.Show();
  }
//+------------------------------------------------------------------+
// | Hides the list |
//+------------------------------------------------------------------+
void CListView::Hide(void)
  {
   if(!CElementBase::IsVisible())
      return;
// --- Hide element
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
// --- Hide scrollbar
   m_scrollv.Hide();
// --- Visibility state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CListView::Delete(void)
  {
   CElement::Delete();
   m_listview.Destroy();
// --- Free the array
   ::ArrayFree(m_items);
  }
//+------------------------------------------------------------------+
// | Setting Priorities |
//+------------------------------------------------------------------+
void CListView::SetZorders(void)
  {
   CElement::SetZorders();
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
  }
//+------------------------------------------------------------------+
// | Reset priorities |
//+------------------------------------------------------------------+
void CListView::ResetZorders(void)
  {
   CElement::ResetZorders();
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_ZORDER,WRONG_VALUE);
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CListView::Draw(void)
  {
   DrawList();
  }
//+------------------------------------------------------------------+
// | Item Update |
//+------------------------------------------------------------------+
void CListView::Update(const bool redraw=false)
  {
// --- Redraw the table if specified
   if(redraw)
     {
      // ---Calculate dimensions
      CalculateListYSize();
      // --- Set new size
      ChangeListSize();
      // ---Draw
      Draw();
      // --- Apply
      m_canvas.Update();
      m_listview.Update();
      return;
     }
// --- Apply
   m_canvas.Update();
   m_listview.Update();
  }
//+------------------------------------------------------------------+
// | Handling a click on a list item |
//+------------------------------------------------------------------+
bool CListView::OnClickList(const string pressed_object)
  {
// --- Exit if (1) the list is not in focus or (2) the scrollbar is in active mode
   if(!CElementBase::MouseFocus() || m_scrollv.State())
      return(false);
// --- Exit if (1) the object name is foreign or (2) the list is empty
   if(m_listview.ChartObjectName()!=pressed_object || ItemsTotal()<1)
      return(false);
// --- Determine the item clicked on
   int index=PressedItemIndex();
// --- If the list has no checkboxes
   if(!m_checkbox_mode)
     {
      // --- Adjust the vertical scroll bar
      CorrectingVerticalScrollThumb();
      // --- Change item color
      RedrawItemsByMode(true);
     }
   else
     {
      // --- Change the state of the checkbox to the opposite
      m_items[index].m_state=!m_items[index].m_state;
      // --- Refresh list
      RedrawItem(index);
     }
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_LIST_ITEM,CElementBase::Id(),m_selected_item,"");
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns the index of the item clicked |
//+------------------------------------------------------------------+
int CListView::PressedItemIndex(void)
  {
   int index=0;
// --- Get the relative Y-coordinate under the mouse cursor
   int y=m_mouse.RelativeY(m_listview);
// --- Determine the row on which you clicked
   for(int i=0; i<m_items_total; i++)
     {
      // --- If the press was not on this row, go to the next
      if(!(y>=m_items[i].m_y && y<=m_items[i].m_y2))
         continue;
      // --- Remember the index
      index=i;
      // --- If the list has no checkboxes
      if(!m_checkbox_mode)
        {
         // --- Save the row index and the row of the first cell
         m_prev_selected_item =(m_selected_item==WRONG_VALUE)? index : m_selected_item;
         m_selected_item      =index;
         m_selected_item_text =m_items[index].m_value;
        }
      break;
     }
// --- Return index
   return(index);
  }
//+------------------------------------------------------------------+
// | Fast forward list |
//+------------------------------------------------------------------+
void CListView::FastSwitching(void)
  {
// --- Exit if there is no focus on the list
   if(!CElementBase::MouseFocus())
      return;
// --- Return the counter to its original value if the mouse button is released
   if(!m_mouse.LeftButtonState())
      m_timer_counter=SPIN_DELAY_MSC;
// --- If the mouse button is pressed
   else
     {
      // --- Increase the counter by the set interval
      m_timer_counter+=TIMER_STEP_MSC;
      // --- Exit if less than zero
      if(m_timer_counter<0)
         return;
      // --- Rewind flag
      bool scroll_v=false;
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
      // --- Exit if no buttons are pressed
      if(!scroll_v)
         return;
      // --- Refresh list
      ShiftData();
      m_scrollv.Update(true);
     }
  }
//+------------------------------------------------------------------+
// | Calculates the full size of the list along the Y axis |
//+------------------------------------------------------------------+
void CListView::CalculateListYSize(void)
  {
// --- Calculate the total height of the table
   int y_size    =(m_item_y_size*m_items_total)+(m_y_offset*2)+1;
   m_list_y_size =(y_size<=m_y_size)? m_y_size-2 : y_size;
// --- Set the height of the frame to display a fragment of the image (the visible part of the table table)
   m_list_visible_y_size=m_y_size-2;
// ---Adjusting the size of the visible part along the Y axis
   m_list_visible_y_size=(m_list_visible_y_size>=m_list_y_size)? m_list_y_size : m_list_visible_y_size;
// --- Calculation of coordinates
   for(int i=0; i<m_items_total; i++)
     {
      // --- Calculate Y-coordinates
      m_items[i].m_y  =(i<1)? m_y_offset : m_items[i-1].m_y2;
      m_items[i].m_y2 =m_items[i].m_y+m_item_y_size;
     }
  }
//+------------------------------------------------------------------+
// | Change the main dimensions of an element |
//+------------------------------------------------------------------+
void CListView::ChangeMainSize(const int x_size,const int y_size)
  {
// --- Set new size
   CElementBase::XSize(x_size);
   CElementBase::YSize(y_size);
  }
//+------------------------------------------------------------------+
// | Resize input field |
//+------------------------------------------------------------------+
void CListView::ChangeListSize(void)
  {
   int x_size=m_x_size-2;
// --- Set new table size
   m_canvas.XSize(m_x_size);
   m_canvas.YSize(m_y_size);
   m_canvas.Resize(m_x_size,m_y_size);
   m_listview.XSize(x_size);
   m_listview.YSize(m_list_y_size);
   m_listview.Resize(x_size,m_list_y_size);
// --- Set the size of the visible area
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_XSIZE,x_size);
   ::ObjectSetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YSIZE,m_list_visible_y_size);
// --- Resize scrollbars
   ChangeScrollsSize();
// --- Data correction
   ShiftData();
  }
//+------------------------------------------------------------------+
// | Resize scrollbars |
//+------------------------------------------------------------------+
void CListView::ChangeScrollsSize(void)
  {
// --- Calculation of the number of steps for displacement
   uint y_size_total         =ItemsTotal();
   uint visible_y_size_total =VisibleItemsTotal();
// --- Calculate scrollbar sizes
   m_scrollv.Reinit(y_size_total,visible_y_size_total);
// --- Set new size
   m_scrollv.ChangeYSize(CElementBase::YSize()-2);
// --- If the vertical scroll bar is not needed
   if(!m_scrollv.IsScroll())
     {
      // --- Hide vertical scroll bar
      m_scrollv.Hide();
     }
   else
     {
      // --- Show vertical scroll bar
      if(CElementBase::IsVisible())
         m_scrollv.Show();
     }
  }
//+------------------------------------------------------------------+
// | Calculation taking into account the latest changes and changing the list size |
//+------------------------------------------------------------------+
void CListView::RecalculateAndResizeList(const bool redraw=false)
  {
// --- Calculate list sizes
   CalculateListYSize();
// --- Set new size
   ChangeListSize();
// --- Update
   Update(redraw);
  }
//+------------------------------------------------------------------+
// | Initialize the specified item with default values ​​|
//+------------------------------------------------------------------+
void CListView::ItemInitialize(const uint item_index)
  {
   m_items[item_index].m_y     =0;
   m_items[item_index].m_y2    =0;
   m_items[item_index].m_value ="";
   m_items[item_index].m_state =false;
  }
//+------------------------------------------------------------------+
// | Makes a copy of the specified item (source) to a new location (dest.) |
//+------------------------------------------------------------------+
void CListView::ItemCopy(const uint item_dest,const uint item_source)
  {
   m_items[item_dest].m_value =m_items[item_source].m_value;
   m_items[item_dest].m_state =m_items[item_source].m_state;
  }
//+------------------------------------------------------------------+
// | Calculation of the width of points |
//+------------------------------------------------------------------+
int CListView::CalculationItemsWidth(void)
  {
   return((m_scrollv.IsScroll()) ? CElementBase::XSize()-m_scrollv.ScrollWidth()-3 : CElementBase::XSize()-3);
  }
//+------------------------------------------------------------------+
// | Calculation of element boundaries along the Y axis |
//+------------------------------------------------------------------+
void CListView::CalculateYBoundaries(void)
  {
// --- Quit if there is no scrollbar
   if(!m_scrollv.IsVisible())
      return;
// --- Get the Y-coordinate and offset along the Y axis
   int y       =(int)::ObjectGetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YDISTANCE);
   int yoffset =(int)::ObjectGetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YOFFSET);
// --- Calculate the boundaries of the visible part of the input field
   m_y_limit  =(y+yoffset)-y;
   m_y2_limit =(y+yoffset+m_y_size)-y;
  }
//+------------------------------------------------------------------+
// | Adjusting the vertical scroll bar |
//+------------------------------------------------------------------+
void CListView::CorrectingVerticalScrollThumb(void)
  {
// --- Get the boundaries of the visible part of the input field
   CalculateYBoundaries();
// --- If the text cursor moves out of the visibility field upwards
   if(m_items[m_selected_item].m_y<=m_y_limit)
     {
      Scrolling(CalculateScrollPosY());
     }
// --- If the text cursor has left the field of view downwards
   else if(m_items[m_selected_item].m_y2>=m_y2_limit)
     {
      Scrolling(CalculateScrollPosY(true));
     }
  }
//+------------------------------------------------------------------+
// | Calculating the Y-position of a scroll bar |
//+------------------------------------------------------------------+
int CListView::CalculateScrollPosY(const bool to_down=false)
  {
   int    calc_y      =(!to_down)? CalculateScrollThumbY() : CalculateScrollThumbY2();
   double pos_y_value =(calc_y-::fmod((double)calc_y,(double)m_item_y_size))/m_item_y_size+((!to_down)? 0 : 1);
//---
   return((int)pos_y_value);
  }
//+------------------------------------------------------------------+
// | Calculation of the Y-coordinate of the scroll bar at the top of the list |
//+------------------------------------------------------------------+
int CListView::CalculateScrollThumbY(void)
  {
   return(m_items[m_selected_item].m_y-m_y_offset);
  }
//+------------------------------------------------------------------+
// | Calculation of the Y-coordinate of the scrollbar at the bottom of the list |
//+------------------------------------------------------------------+
int CListView::CalculateScrollThumbY2(void)
  {
// --- Calculate and return value
   return(m_items[m_selected_item].m_y-m_y_size+m_item_y_size);
  }
//+------------------------------------------------------------------+
// | Defining indexes of the visible list area |
//+------------------------------------------------------------------+
void CListView::VisibleListIndexes(void)
  {
// --- Determine the boundaries taking into account the offset of the visible area of ​​the table
   int yoffset1 =(int)::ObjectGetInteger(m_chart_id,m_listview.ChartObjectName(),OBJPROP_YOFFSET);
   int yoffset2 =yoffset1+m_list_visible_y_size;
// --- Determine the first and last indexes of the visible area of ​​the table
   m_visible_list_from_index =int(double(yoffset1/m_item_y_size));
   m_visible_list_to_index   =int(double(yoffset2/m_item_y_size));
// --- The subscript is one more if we do not go out of range
   m_visible_list_to_index=(m_visible_list_to_index+1>m_items_total)? m_items_total : m_visible_list_to_index+1;
  }
//+------------------------------------------------------------------+
// | Draws a list |
//+------------------------------------------------------------------+
void CListView::DrawList(const bool only_visible=false)
  {
// --- If not specified, redraw only the visible part of the list
   if(!only_visible)
     {
      // --- Set the indexes of the rows of the entire list from the very beginning to the end
      m_visible_list_from_index =0;
      m_visible_list_to_index   =m_items_total;
     }
// --- Get the indexes of the rows of the visible part of the list
   else
      VisibleListIndexes();
// --- Draw background
   DrawBackground();
   m_listview.Erase(::ColorToARGB(m_back_color,m_alpha));
// --- Draw pictures
   DrawImages();
// --- Draw text
   DrawText();
// --- Draw a frame
   DrawBorder();
  }
//+------------------------------------------------------------------+
// | Draws an input field frame |
//+------------------------------------------------------------------+
void CListView::DrawBorder(void)
  {
// --- Get the offset along the X axis
   int x_offset =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XOFFSET);
   int y_offset =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YOFFSET);
// --- Borders
   int x_size =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XSIZE);
   int y_size =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YSIZE);
// --- Coordinates
   int x1 =x_offset;
   int y1 =y_offset;
   int x2 =x_offset+x_size;
   int y2 =y_offset+y_size;
// --- Draw a rectangle without fill
   m_canvas.Rectangle(x1,y1,x2-1,y2-1,::ColorToARGB(m_border_color));
  }
//+------------------------------------------------------------------+
// | Draws pictures |
//+------------------------------------------------------------------+
void CListView::DrawImages(void)
  {
// --- Exit if checkboxes are disabled
   if(!m_checkbox_mode)
      return;
// --- Draw check boxes in points
   for(int i=m_visible_list_from_index; i<m_visible_list_to_index; i++)
     {
      // --- Calculation of coordinates
      m_images_group[0].m_y_gap=m_items[i].m_y+m_icon_y_gap;
      // --- Set the corresponding picture
      CElement::ChangeImage(0,(m_items[i].m_state)? 2 : 0);
      CListView::DrawImage();
     }
  }
//+------------------------------------------------------------------+
// | Draws a picture |
//+------------------------------------------------------------------+
void CListView::DrawImage(void)
  {
// ---Image index
   int i=SelectedImage();
// ---If there are no images
   if(i==WRONG_VALUE)
      return;
// --- Coordinates
   int x =m_images_group[0].m_x_gap;
   int y =m_images_group[0].m_y_gap;
// --- Dimensions
   uint height =m_images_group[0].m_image[i].Height();
   uint width  =m_images_group[0].m_image[i].Width();
// --- Draw
   for(uint ly=0,p=0; ly<height; ly++)
     {
      for(uint lx=0; lx<width; lx++,p++)
        {
         // ---If there is no color, move to the next pixel
         if(m_images_group[0].m_image[i].Data(p)<1)
            continue;
         // --- Get the color of the bottom layer (cell background) and the color of the specified pixel in the image
         uint background  =::ColorToARGB(m_listview.PixelGet(x+lx,y+ly));
         uint pixel_color =m_images_group[0].m_image[i].Data(p);
         // --- Mix colors
         uint foreground=::ColorToARGB(m_clr.BlendColors(background,pixel_color));
         // --- Drawing a pixel of the layered image
         m_listview.PixelSet(x+lx,y+ly,foreground);
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws a picture |
//+------------------------------------------------------------------+
void CListView::DrawText(void)
  {
// --- To calculate coordinates and offsets
   int x=0,y=0;
// --- Font properties
   m_listview.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// ---Rows
   for(int i=m_visible_list_from_index; i<m_visible_list_to_index; i++)
     {
      // --- Draw line background
      int x1 =0;
      int x2 =CalculationItemsWidth();
      int y1 =m_items[i].m_y;
      int y2 =m_items[i].m_y2;
      //---
      if(i==m_selected_item)
        {
         m_listview.FillRectangle(x1,y1,x2,y2,ItemColorCurrent(i,false));
         m_listview.Rectangle(x1,y1,x2,y2,::ColorToARGB(m_back_color,m_alpha));
        }
      // --- Draw text
      x =m_label_x_gap;
      y =m_items[i].m_y+m_label_y_gap;
      m_listview.TextOut(x,y,m_items[i].m_value,TextColor(i),TA_LEFT|TA_TOP);
     }
  }
//+------------------------------------------------------------------+
// | Redraws the specified list item |
//+------------------------------------------------------------------+
void CListView::RedrawItem(const int item_index)
  {
// --- Coordinates
   int x1 =0;
   int x2 =CalculationItemsWidth();
   int y1 =m_items[item_index].m_y;
   int y2 =m_items[item_index].m_y2;
// --- To calculate coordinates
   int x=0,y=0;
// --- To check focus
   bool is_item_focus=false;
// --- If the list line highlighting mode is enabled
   if(m_lights_hover)
     {
      // --- (1) Get the relative Y-coordinate of the mouse cursor and (2) focus on the specified table row
      y=m_mouse.RelativeY(m_listview);
      is_item_focus=(y>m_items[item_index].m_y && y<=m_items[item_index].m_y2);
     }
// --- Draw item
   m_listview.FillRectangle(x1,y1,x2,y2,ItemColorCurrent(item_index,is_item_focus));
// --- Draw a frame
   m_listview.Rectangle(x1,y1,x2,y2,::ColorToARGB(m_back_color,m_alpha));
// --- Draw pictures if the list has checkboxes
   if(m_checkbox_mode)
     {
      // --- Calculation of coordinates
      m_images_group[0].m_y_gap=m_items[item_index].m_y+m_icon_y_gap;
      // --- Set the corresponding picture
      CElement::ChangeImage(0,(m_items[item_index].m_state)? 2 : 0);
      CListView::DrawImage();
     }
// --- Draw text
   x1 =m_label_x_gap;
   y1 =m_items[item_index].m_y+m_label_y_gap;
   m_listview.TextOut(x1,y1,m_items[item_index].m_value,TextColor(item_index),TA_LEFT|TA_TOP);
// --- Refresh canvas
   m_listview.Update();
  }
//+------------------------------------------------------------------+
// | Redraws list items according to the specified mode |
//+------------------------------------------------------------------+
void CListView::RedrawItemsByMode(const bool is_selected_item=false)
  {
// --- Current and previous row indexes
   int item_index      =WRONG_VALUE;
   int prev_item_index =WRONG_VALUE;
// --- Initialize row indexes relative to the specified mode
   if(is_selected_item)
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
// --- Number of points to draw
   uint items_total=(item_index!=WRONG_VALUE && prev_item_index!=WRONG_VALUE && item_index!=prev_item_index)? 2 : 1;
// --- Coordinates
   int x1=0;
   int x2=CalculationItemsWidth();
   int y1[2]={0},y2[2]={0};
// --- Array for values ​​in a specific sequence
   int indexes[2];
// --- If (1) the mouse cursor has moved down or (2) the first time here
   if(item_index>m_prev_item_index_focus || item_index==WRONG_VALUE)
     {
      indexes[0]=(item_index==WRONG_VALUE || prev_item_index!=WRONG_VALUE)? prev_item_index : item_index;
      indexes[1]=item_index;
     }
// --- If the mouse cursor moves up
   else
     {
      indexes[0]=item_index;
      indexes[1]=prev_item_index;
     }
// --- Draw the background of the items
   for(uint i=0; i<items_total; i++)
     {
      // --- Calculation of the coordinates of the upper and lower boundaries of the line
      y1[i] =m_items[indexes[i]].m_y;
      y2[i] =m_items[indexes[i]].m_y2;
      // --- Determine the focus on the line relative to the backlight mode
      bool is_item_focus=false;
      if(!m_lights_hover)
         is_item_focus=(indexes[i]==item_index && item_index!=WRONG_VALUE);
      else
         is_item_focus=(item_index==WRONG_VALUE)?(indexes[i]==prev_item_index) :(indexes[i]==item_index);
      // --- Draw item
      m_listview.FillRectangle(x1,y1[i],x2,y2[i],ItemColorCurrent(indexes[i],is_item_focus));
      // --- Draw a frame
      m_listview.Rectangle(x1,y1[i],x2,y2[i],::ColorToARGB(m_back_color,m_alpha));
     }
// --- Draw pictures if the list has checkboxes
   if(m_checkbox_mode)
     {
      for(uint i=0; i<items_total; i++)
        {
         // --- Calculation of coordinates
         m_images_group[0].m_y_gap=m_items[indexes[i]].m_y+m_icon_y_gap;
         // --- Set the corresponding picture
         CElement::ChangeImage(0,(m_items[indexes[i]].m_state)? 2 : 0);
         CListView::DrawImage();
        }
     }
// --- To calculate coordinates
   int x=0,y=0;
// --- Get the X-coordinate of the text
   x=m_label_x_gap;
// --- Drawing text
   for(uint i=0; i<items_total; i++)
     {
      // --- (1) Calculate coordinate and (2) draw text
      y=m_items[indexes[i]].m_y+m_label_y_gap;
      m_listview.TextOut(x,y,m_items[indexes[i]].m_value,TextColor(indexes[i]),TA_TOP|TA_LEFT);
     }
// --- Apply
   m_listview.Update();
  }
//+------------------------------------------------------------------+
// | Returns the current background color of an item |
//+------------------------------------------------------------------+
uint CListView::ItemColorCurrent(const int item_index,const bool is_item_focus)
  {
// --- If the selected line
   if(item_index==m_selected_item)
      return(::ColorToARGB(m_back_color_pressed,m_alpha));
// ---Item color
   uint clr=m_back_color;
// --- If (1) there is no focus or (2) the form is locked
   bool condition=(!is_item_focus || !m_canvas.MouseFocus() || m_main.CElementBase::IsLocked());
//---
   clr=(condition)? m_back_color : m_back_color_hover;
// ---Return color
   return(::ColorToARGB(clr,m_alpha));
  }
//+------------------------------------------------------------------+
// | Returns the text color of an item |
//+------------------------------------------------------------------+
uint CListView::TextColor(const int item_index)
  {
   uint clr=(item_index==m_selected_item)? m_label_color_pressed : m_label_color;
// --- Return title color
   return(::ColorToARGB(clr));
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CListView::ChangeWidthByRightWindowSide(void)
  {
// --- Exit if the mode of fixing to the right edge of the form is enabled
   if(m_anchor_right_window_side)
      return;
// --- Dimensions
   int x_size =m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset;
   int y_size =(m_auto_yresize_mode)? m_main.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset : m_y_size;
// --- Set new size
   ChangeMainSize(x_size,y_size);
// --- Calculate the size of the input field
   CalculateListYSize();
// --- Set a new size for the input field
   ChangeListSize();
// --- Draw element
   Draw();
   Update();
   if(m_scrollv.IsScroll())
      m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
// | Change the height along the bottom edge of the window |
//+------------------------------------------------------------------+
void CListView::ChangeHeightByBottomWindowSide(void)
  {
// --- Exit if the mode of fixing to the bottom edge of the form is enabled
   if(m_anchor_bottom_window_side)
      return;
// --- Dimensions
   int x_size =(m_auto_xresize_mode)? m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset : m_x_size;
   int y_size =m_main.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset;
// --- Set new size
   ChangeMainSize(x_size,y_size);
// --- Calculate list sizes
   CalculateListYSize();
// --- Set a new size for the input field
   ChangeListSize();
// --- Draw element
   Draw();
   Update();
   if(m_scrollv.IsScroll())
      m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
