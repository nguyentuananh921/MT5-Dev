//+------------------------------------------------------------------+
//|                                                  ContextMenu.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "MenuItem.mqh"
#include "SeparateLine.mqh"
//+------------------------------------------------------------------+
// | Class for creating a context menu |
//+------------------------------------------------------------------+
class CContextMenu : public CElement
  {
private:
   // --- Objects for creating a menu item
   CMenuItem         m_items[];
   CSeparateLine     m_sep_line[];
   // --- Pointer to previous node
   CMenuItem        *m_prev_node;
   // --- Menu Item Properties
   int               m_item_y_size;
   // --- Dividing line properties
   color             m_sepline_dark_color;
   color             m_sepline_light_color;
   // --- Arrays of menu item properties:
   // (1) Text, (2) available item shortcut, (3) locked item shortcut
   string            m_text[];
   string            m_path_bmp_on[];
   string            m_path_bmp_off[];
   // --- Array of index numbers of menu items after which you need to set a dividing line
   int               m_sep_line_index[];
   // --- Fixing side of the context menu
   ENUM_FIX_CONTEXT_MENU m_fix_side;
   // --- Free context menu mode. That is, without reference to the previous node.
   bool              m_free_context_menu;
   //---
public:
                     CContextMenu(void);
                    ~CContextMenu(void);
   // --- Methods for creating a context menu
   bool              CreateContextMenu(const int x_gap=0,const int y_gap=0);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateItems(void);
   bool              CreateSeparateLine(const int item_index,const int line_index);
   //---
public:
   // --- Returns the pointer to an item from the context menu
   CMenuItem        *GetItemPointer(const uint index);
   CSeparateLine    *GetSeparateLinePointer(const uint index);
   // --- (1) Save and (2) get the previous node pointer, (3) set the free context menu mode
   void              PrevNodePointer(CMenuItem &object);
   CMenuItem        *PrevNodePointer(void)                    const { return(m_prev_node);              }
   void              FreeContextMenu(const bool flag)               { m_free_context_menu=flag;         }
   // --- (1) Number of menu items, (2) height
   int               ItemsTotal(void)                         const { return(::ArraySize(m_items));     }
   int               SeparateLinesTotal(void)                 const { return(::ArraySize(m_sep_line));  }
   void              ItemYSize(const int y_size)                    { m_item_y_size=y_size;             }
   // --- (1) Dark and (2) light dividing line color
   void              SeparateLineDarkColor(const color clr)         { m_sepline_dark_color=clr;         }
   void              SeparateLineLightColor(const color clr)        { m_sepline_light_color=clr;        }
   // --- Setting the context menu fixing mode
   void              FixSide(const ENUM_FIX_CONTEXT_MENU side) { m_fix_side=side; }

   // --- Adds a menu item with the specified properties before creating the context menu
   void              AddItem(const string text,const string path_bmp_on,const string path_bmp_off,const ENUM_TYPE_MENU_ITEM type);
   // --- Adds a separator line after the specified item before creating the context menu
   void              AddSeparateLine(const int item_index);
   // --- Returns the description (display text)
   string            DescriptionByIndex(const uint index);
   // --- Returns the type of menu item
   ENUM_TYPE_MENU_ITEM TypeMenuItemByIndex(const uint index);
   // --- (1) Get and (2) set the checkbox state
   bool              CheckBoxStateByIndex(const uint index);
   void              CheckBoxStateByIndex(const uint index,const bool state);
   // --- (1) Returns and (2) sets the id of the radio point by index
   int               RadioItemIdByIndex(const uint index);
   void              RadioItemIdByIndex(const uint item_index,const int radio_id);
   // --- (1) Returns the selected radio item, (2) switches the radio item
   int               SelectedRadioItem(const int radio_id);
   void              SelectedRadioItem(const int radio_index,const int radio_id);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Delete(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Checking conditions for closing all context menus
   void              CheckHideContextMenus(void);
   // --- Checking the conditions for closing all context menus that were opened after this
   void              CheckHideBackContextMenus(void);
   // --- Processing clicks on the item to which this context menu is linked
   bool              OnClickMenuItem(const string pressed_object,const int id,const int index);

   // --- Receiving a message from a menu item for processing
   void              ReceiveMessageFromMenuItem(const int id,const int index_item,const string message_item);
   // --- Obtaining (1) identifier and (2) index from radio point message
   int               RadioIdFromMessage(const string message);
   int               RadioIndexByItemIndex(const int index);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CContextMenu::CContextMenu(void) : m_free_context_menu(false),
                                   m_fix_side(FIX_RIGHT),
                                   m_item_y_size(24),
                                   m_sepline_dark_color(C'160,160,160'),
                                   m_sepline_light_color(clrWhite)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
// --- The context menu is a drop-down element
   CElementBase::IsDropdown(true);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CContextMenu::~CContextMenu(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CContextMenu::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling mouse cursor movement
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Quit if this is a free context menu
      if(m_free_context_menu)
         return;
      // --- If the context menu is enabled and the left mouse button is pressed
      if(m_mouse.LeftButtonState())
        {
         // --- Let's check the conditions for closing all context menus
         CheckHideContextMenus();
         return;
        }
      // --- Let's check the conditions for closing all context menus that were opened after this
      CheckHideBackContextMenus();
      return;
     }
// --- Handling the event of pressing the left mouse button on an object
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(OnClickMenuItem(sparam,(int)lparam,(int)dparam))
         return;
     }
// --- Handling the click event on a menu item
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_MENU_ITEM)
     {
      // --- Quit if this is a free context menu
      if(m_free_context_menu)
         return;
      //---
      int    item_id      =int(lparam);
      int    item_index   =int(dparam);
      string item_message =sparam;
      // --- Receiving a message from a menu item for processing
      ReceiveMessageFromMenuItem(item_id,item_index,item_message);
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a context menu |
//+------------------------------------------------------------------+
bool CContextMenu::CreateContextMenu(const int x_gap=0,const int y_gap=0)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- If this is a bound context menu
   if(!m_free_context_menu)
     {
      // --- Exit if there is no pointer to the previous node
      if(::CheckPointer(m_prev_node)==POINTER_INVALID)
        {
         ::Print(__FUNCTION__," > Перед созданием контекстного меню ему нужно передать "
                 "указатель на предыдущий узел с помощью метода CContextMenu::PrevNodePointer(CMenuItem &object).");
         return(false);
        }
     }
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// ---Creating a context menu
   if(!CreateCanvas())
      return(false);
   if(!CreateItems())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CContextMenu::InitializeProperties(const int x_gap,const int y_gap)
  {
// --- Context menu height calculation depends on the number of menu items and dividing lines
   int items_total =ItemsTotal();
   int sep_y_size  =::ArraySize(m_sep_line)*9;
   m_y_size        =(m_item_y_size*items_total+2)+sep_y_size;
// --- If coordinates are not specified
   if(!m_free_context_menu && (x_gap==0 || y_gap==0))
     {
      if(m_fix_side==FIX_RIGHT)
        {
         m_x =(m_anchor_right_window_side)? m_prev_node.X()-m_prev_node.XSize()+3 : m_prev_node.X2()-3;
         m_y =(m_anchor_bottom_window_side)? m_prev_node.Y()+1 : m_prev_node.Y()-1;
        }
      else
        {
         m_x =(m_anchor_right_window_side)? m_prev_node.X()-1 : m_prev_node.X()+1;
         m_y =(m_anchor_bottom_window_side)? m_prev_node.Y()-m_prev_node.YSize()+1 : m_prev_node.Y2()-1;
        }
     }
// --- If the coordinates are specified
   else
     {
      m_x =CElement::CalculateX(x_gap);
      m_y =CElement::CalculateY(y_gap);
     }
// ---Default background color
   m_back_color         =(m_back_color!=clrNONE)? m_back_color : C'240,240,240';
   m_back_color_hover   =(m_back_color_hover!=clrNONE)? m_back_color_hover : C'51,153,255';
   m_back_color_locked  =(m_back_color_locked!=clrNONE)? m_back_color_locked : clrLightGray;
   m_back_color_pressed =(m_back_color_pressed!=clrNONE)? m_back_color_pressed : C'51,153,255';
   m_border_color       =(m_border_color!=clrNONE)? m_border_color : C'150,170,180';
// --- Indentation and color of text label
   m_icon_x_gap         =(m_icon_x_gap!=WRONG_VALUE)? m_icon_x_gap : 3;
   m_icon_y_gap         =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 3;
   m_label_x_gap        =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 24;
   m_label_y_gap        =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 5;
   m_label_color        =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_color_hover  =(m_label_color_hover!=clrNONE)? m_label_color_hover : clrWhite;
// --- Indents from the extreme point
   CElementBase::XGap(CElement::CalculateXGap(m_x));
   CElementBase::YGap(CElement::CalculateYGap(m_y));
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CContextMenu::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("context_menu");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a list of menu items |
//+------------------------------------------------------------------+
bool CContextMenu::CreateItems(void)
  {
// --- To determine the position of dividing lines
   int s=0;
// ---Coordinates
   int x=1,y=0;
// --- Number of dividing lines
   int sep_lines_total=::ArraySize(m_sep_line_index);
//---
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      // --- Y coordinate calculation
      y=(i>0) ? y+m_item_y_size : 1;
      // --- Save the form pointer
      m_items[i].MainPointer(this);
      // --- If the context menu is anchored, then add a pointer to the previous node
      if(!m_free_context_menu)
         m_items[i].GetPrevNodePointer(m_prev_node);
      // --- Set properties
      m_items[i].Index(i);
      m_items[i].TwoState(m_items[i].TypeMenuItem()==MI_HAS_CONTEXT_MENU? true : false);
      m_items[i].XSize(m_x_size-2);
      m_items[i].YSize(m_item_y_size);
      m_items[i].IconXGap(m_icon_x_gap);
      m_items[i].IconYGap(m_icon_y_gap);
      m_items[i].IconFile(m_path_bmp_on[i]);
      m_items[i].IconFileLocked(m_path_bmp_off[i]);
      m_items[i].IconFilePressed(m_path_bmp_on[i]);
      m_items[i].IconFilePressedLocked(m_path_bmp_off[i]);
      m_items[i].BackColor(m_back_color);
      m_items[i].BackColorHover(m_back_color_hover);
      m_items[i].BackColorPressed(m_back_color_hover);
      m_items[i].BorderColor(m_back_color);
      m_items[i].BorderColorHover(m_back_color);
      m_items[i].BorderColorLocked(m_back_color);
      m_items[i].BorderColorPressed(m_back_color);
      m_items[i].LabelXGap(m_label_x_gap);
      m_items[i].LabelYGap(m_label_y_gap);
      m_items[i].LabelColor(m_label_color);
      m_items[i].LabelColorHover(m_label_color_hover);
      m_items[i].LabelColorPressed(m_label_color_hover);
      m_items[i].IsDropdown(m_is_dropdown);
      m_items[i].AnchorRightWindowSide(m_anchor_right_window_side);
      m_items[i].AnchorBottomWindowSide(m_anchor_bottom_window_side);
      // --- Create a menu item
      if(!m_items[i].CreateMenuItem(m_text[i],x,y))
         return(false);
      // --- Add element to array
      CElement::AddToArray(m_items[i]);
      // --- Reset focus
      CElementBase::MouseFocus(false);
      // --- Move to next if all dividing lines are set
      if(s>=sep_lines_total)
         continue;
      // --- If the indices match, then after this point you need to set a dividing line
      if(i==m_sep_line_index[s])
        {
         if(!CreateSeparateLine(i,s))
            return(false);
         // --- Adjustment of Y coordinate for the next item
         y=y+9;
         // --- Increase dividing line counter
         s++;
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a dividing line |
//+------------------------------------------------------------------+
bool CContextMenu::CreateSeparateLine(const int item_index,const int line_index)
  {
   int x=CElement::CalculateXGap(m_items[item_index].X()+5);
   int y=CElement::CalculateYGap(m_items[item_index].Y2()+2);
// --- Save the form pointer
   m_sep_line[line_index].MainPointer(m_main);
// --- Set properties
   m_sep_line[line_index].Index(line_index);
   m_sep_line[line_index].IsDropdown(m_is_dropdown);
   m_sep_line[line_index].TypeSepLine(H_SEP_LINE);
   m_sep_line[line_index].DarkColor(m_sepline_dark_color);
   m_sep_line[line_index].LightColor(m_sepline_light_color);
   m_sep_line[line_index].AnchorRightWindowSide(m_anchor_right_window_side);
   m_sep_line[line_index].AnchorBottomWindowSide(m_anchor_bottom_window_side);
// ---Creating a dividing line
   if(!m_sep_line[line_index].CreateSeparateLine(x,y,m_x_size-10,2))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_sep_line[line_index]);
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns the menu item pointer by index |
//+------------------------------------------------------------------+
CMenuItem *CContextMenu::GetItemPointer(const uint index)
  {
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в контекстном меню есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return pointer
   return(::GetPointer(m_items[i]));
  }
//+------------------------------------------------------------------+
// | Returns the dividing line pointer at index |
//+------------------------------------------------------------------+
CSeparateLine *CContextMenu::GetSeparateLinePointer(const uint index)
  {
   uint array_size=::ArraySize(m_sep_line);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      return(NULL);
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return pointer
   return(::GetPointer(m_sep_line[i]));
  }
//+------------------------------------------------------------------+
// | Exchange menu item and context menu pointers |
//+------------------------------------------------------------------+
void CContextMenu::PrevNodePointer(CMenuItem &object)
  {
// --- Save a pointer to the menu item to which this context menu is bound
   m_prev_node=::GetPointer(object);
// --- Save pointer to this context menu
   m_prev_node.GetContextMenuPointer(this);
  }
//+------------------------------------------------------------------+
// | Adds a menu item |
//+------------------------------------------------------------------+
void CContextMenu::AddItem(const string text,const string path_bmp_on,const string path_bmp_off,const ENUM_TYPE_MENU_ITEM type)
  {
// --- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_items);
   ::ArrayResize(m_items,array_size+1);
   ::ArrayResize(m_text,array_size+1);
   ::ArrayResize(m_path_bmp_on,array_size+1);
   ::ArrayResize(m_path_bmp_off,array_size+1);
// --- Save the values ​​of the passed parameters
   m_text[array_size]=text;
   m_path_bmp_on[array_size]  =path_bmp_on;
   m_path_bmp_off[array_size] =path_bmp_off;
// --- Setting the menu item type
   m_items[array_size].TypeMenuItem(type);
  }
//+------------------------------------------------------------------+
// | Adds a dividing line |
//+------------------------------------------------------------------+
void CContextMenu::AddSeparateLine(const int item_index)
  {
// --- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_sep_line);
   ::ArrayResize(m_sep_line,array_size+1);
   ::ArrayResize(m_sep_line_index,array_size+1);
// --- Save the index number
   m_sep_line_index[array_size]=item_index;
  }
//+------------------------------------------------------------------+
// | Returns the item name by index |
//+------------------------------------------------------------------+
string CContextMenu::DescriptionByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в контекстном меню есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return item description
   return(m_items[i].LabelText());
  }
//+------------------------------------------------------------------+
// | Returns the item type by index |
//+------------------------------------------------------------------+
ENUM_TYPE_MENU_ITEM CContextMenu::TypeMenuItemByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в контекстном меню есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return item type
   return(m_items[i].TypeMenuItem());
  }
//+------------------------------------------------------------------+
// | Returns the state of a checkbox by index |
//+------------------------------------------------------------------+
bool CContextMenu::CheckBoxStateByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в контекстном меню есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return item state
   return(m_items[i].CheckBoxState());
  }
//+------------------------------------------------------------------+
// | Sets the checkbox state by index |
//+------------------------------------------------------------------+
void CContextMenu::CheckBoxStateByIndex(const uint index,const bool state)
  {
// --- Check for out of range
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      return;
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// ---Set state
   m_items[i].CheckBoxState(state);
  }
//+------------------------------------------------------------------+
// | Returns the id of a radio point by index |
//+------------------------------------------------------------------+
int CContextMenu::RadioItemIdByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда в контекстном меню есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return ID
   return(m_items[i].RadioButtonID());
  }
//+------------------------------------------------------------------+
// | Sets the id for a radio item by index |
//+------------------------------------------------------------------+
void CContextMenu::RadioItemIdByIndex(const uint index,const int id)
  {
// --- Check for out of range
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      return;
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Set ID
   m_items[i].RadioButtonID(id);
  }
//+------------------------------------------------------------------+
// | Returns the index of a radio item by id |
//+------------------------------------------------------------------+
int CContextMenu::SelectedRadioItem(const int radio_id)
  {
// --- Radio point counter
   int count_radio_id=0;
// --- Let's loop through the list of context menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      // ---Go to next if not radio item
      if(m_items[i].TypeMenuItem()!=MI_RADIOBUTTON)
         continue;
      // --- If the IDs match
      if(m_items[i].RadioButtonID()==radio_id)
        {
         // --- If this is an active radio point, exit the loop
         if(m_items[i].RadioButtonState())
            break;
         // --- Increase radio point counter
         count_radio_id++;
        }
     }
// --- Return index
   return(count_radio_id);
  }
//+------------------------------------------------------------------+
// | Switches radio item by index and id |
//+------------------------------------------------------------------+
void CContextMenu::SelectedRadioItem(const int radio_index,const int radio_id)
  {
// --- Radio point counter
   int count_radio_id=0;
// --- Let's loop through the list of context menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      // ---Go to next if not radio item
      if(m_items[i].TypeMenuItem()!=MI_RADIOBUTTON)
         continue;
      // --- If the IDs match
      if(m_items[i].RadioButtonID()==radio_id)
        {
         // --- Switch radio item
         if(count_radio_id==radio_index)
            m_items[i].RadioButtonState(true);
         else
            m_items[i].RadioButtonState(false);
         // --- Increase radio point counter
         count_radio_id++;
        }
     }
  }
//+------------------------------------------------------------------+
// | Shows context menu |
//+------------------------------------------------------------------+
void CContextMenu::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Assign the status of a visible element
   CElementBase::IsVisible(true);
// --- Update object position
   Moving();
// --- Show object
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
// --- Show menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Show();
// --- Show dividing lines
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Show();
// --- Mark state in previous node
   if(!m_free_context_menu)
      m_prev_node.IsPressed(true);
  }
//+------------------------------------------------------------------+
// | Hides the context menu |
//+------------------------------------------------------------------+
void CContextMenu::Hide(void)
  {
// --- Exit if element is hidden
   if(!CElementBase::IsVisible())
      return;
// --- Hide object
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
// --- Hide menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Hide();
// --- Hide dividing lines
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Hide();
// --- Reset focus
   CElementBase::MouseFocus(false);
// --- Assign the status of a hidden element
   CElementBase::IsVisible(false);
// --- Mark state in previous node
   if(!m_free_context_menu)
      m_prev_node.IsPressed(false);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CContextMenu::Delete(void)
  {
// --- Deleting objects
   m_canvas.Destroy();
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Delete();
// --- Removing dividing lines
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Delete();
// --- Freeing element arrays
   ::ArrayFree(m_items);
   ::ArrayFree(m_sep_line);
   ::ArrayFree(m_sep_line_index);
   ::ArrayFree(m_text);
   ::ArrayFree(m_path_bmp_on);
   ::ArrayFree(m_path_bmp_off);
// --- Freeing arrays of elements and objects
   CElement::FreeElementsArray();
// --- Initializing variables to default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
// | Checking conditions for closing all context menus |
//+------------------------------------------------------------------+
void CContextMenu::CheckHideContextMenus(void)
  {
// --- Quit if (1) the cursor is in the context menu area or (2) in the previous node area
   if(CElementBase::MouseFocus() || m_prev_node.MouseFocus())
      return;
// --- If the cursor is outside the area of ​​these elements, then...
// ... need to check if there are open context menus that were activated from this
// --- To do this, let's loop through the list of this context menu...
// ... to determine the presence of an item that contains a context menu
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      // --- If such an item is found, then you need to check whether its context menu is open.
      // If it is open, then there is no need to send a signal to close all context menus from this element, since...
      // ... it is possible that the cursor is in the next area and need to check there.
      if(m_items[i].TypeMenuItem()==MI_HAS_CONTEXT_MENU)
         if(m_items[i].GetContextMenuPointer().IsVisible())
            return;
     }
// --- Press the button of the previous bridle
   m_prev_node.IsPressed(false);
   m_prev_node.Update(true);
// --- Send a signal to hide all context menus
   ::EventChartCustom(m_chart_id,ON_HIDE_CONTEXTMENUS,0,0,"");
// --- Message to restore available items
   ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
// --- Send a message about the change in the graphical interface
   ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
  }
//+------------------------------------------------------------------+
// | Checking conditions for closing all context menus, |
// | which were opened after this |
//+------------------------------------------------------------------+
void CContextMenu::CheckHideBackContextMenus(void)
  {
// --- Go through all menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      // --- If (1) the item contains a context menu and (2) it is enabled
      if(m_items[i].TypeMenuItem()==MI_HAS_CONTEXT_MENU && m_items[i].IsPressed())
        {
         // --- If the focus is in the context menu, but not in this item
         if(CElementBase::MouseFocus() && !m_items[i].MouseFocus())
           {
            // --- Send a signal to hide all context menus that were opened after this
            ::EventChartCustom(m_chart_id,ON_HIDE_BACK_CONTEXTMENUS,CElementBase::Id(),0,"");
            // --- Message to restore available items
            ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
            // --- Send a message about the change in the graphical interface
            ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
// | Handling a click on a menu item |
//+------------------------------------------------------------------+
bool CContextMenu::OnClickMenuItem(const string pressed_object,const int id,const int index)
  {
// --- Exit if the button was not pressed
   if(::StringFind(pressed_object,"menu_item")<0)
      return(false);
// --- Exit if (1) this context menu has a previous node and (2) is already open
   if(!m_free_context_menu && CElementBase::IsVisible())
      return(true);
// ---If this is a free context menu
   if(m_free_context_menu)
     {
      // --- Find in the loop the menu item that was clicked
      int total=ItemsTotal();
      for(int i=0; i<total; i++)
        {
         if(i!=index)
            continue;
         // --- We will send a message about this
         ::EventChartCustom(m_chart_id,ON_CLICK_FREEMENU_ITEM,CElementBase::Id(),i,DescriptionByIndex(i));
         break;
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Receiving a message from a menu item for processing |
//+------------------------------------------------------------------+
void CContextMenu::ReceiveMessageFromMenuItem(const int id,const int index_item,const string message_item)
  {
// --- If (1) there is no sign of this program or (2) the identifiers do not match
   if(::StringFind(message_item,CElementBase::ProgramName(),0)<0 || id!=CElementBase::Id())
      return;
// --- If the press was on a radio point
   if(::StringFind(message_item,"radioitem",0)>-1)
     {
      // --- Get the id of the radio point from the transmitted message
      int radio_id=RadioIdFromMessage(message_item);
      // --- Get the index of the radio point using the general index
      int radio_index=RadioIndexByItemIndex(index_item);
      // --- Switch radio item
      SelectedRadioItem(radio_index,radio_id);
     }
// --- Hiding the context menu
   Hide();
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_CONTEXTMENU_ITEM,id,index_item,DescriptionByIndex(index_item));
// --- Send a signal to hide all context menus
   ::EventChartCustom(m_chart_id,ON_HIDE_CONTEXTMENUS,0,0,"");
// --- Message to restore available items
   ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
// --- Send a message about the change in the graphical interface
   ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
  }
//+------------------------------------------------------------------+
// | Retrieves an identifier from a message for a radio point |
//+------------------------------------------------------------------+
int CContextMenu::RadioIdFromMessage(const string message)
  {
   ushort u_sep=0;
   string result[];
   int    array_size=0;
// --- Get the separator code
   u_sep=::StringGetCharacter("_",0);
// --- Let's split the line
   ::StringSplit(message,u_sep,result);
   array_size=::ArraySize(result);
// --- If the message structure is different from what is expected
   if(array_size!=3)
     {
      ::Print(__FUNCTION__," > Неправильная структура в сообщении для радио-пункта! message: ",message);
      return(WRONG_VALUE);
     }
// --- Preventing array out-of-bounds
   if(array_size<3)
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
// --- Return radio point id
   return((int)result[2]);
  }
//+------------------------------------------------------------------+
// | Returns the index of a radio item based on the general index |
//+------------------------------------------------------------------+
int CContextMenu::RadioIndexByItemIndex(const int index)
  {
   int radio_index=0;
// --- Get the radio point ID using the general index
   int radio_id=RadioItemIdByIndex(index);
// --- Counter of items from the desired group
   int count_radio_id=0;
// --- Let's loop through the list
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      // ---If this is not a radio item, go to the next one
      if(m_items[i].TypeMenuItem()!=MI_RADIOBUTTON)
         continue;
      // --- If the IDs match
      if(m_items[i].RadioButtonID()==radio_id)
        {
         // --- If the indices coincide, then
         // remember the current counter value and end the loop
         if(m_items[i].Index()==index)
           {
            radio_index=count_radio_id;
            break;
           }
         // --- Counter increase
         count_radio_id++;
        }
     }
// --- Return index
   return(radio_index);
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CContextMenu::Draw(void)
  {
// --- Draw background
   CElement::DrawBackground();
// --- Draw a frame
   CElement::DrawBorder();
  }
//+------------------------------------------------------------------+
