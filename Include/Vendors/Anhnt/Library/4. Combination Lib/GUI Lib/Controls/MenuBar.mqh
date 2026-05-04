//+------------------------------------------------------------------+
//|                                                      MenuBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class for creating the main menu                                 |
//+------------------------------------------------------------------+
#ifndef __MENUBAR_MQH__
#define __MENUBAR_MQH__
 #include "..\Element.mqh"
 #include "MenuItem.mqh"
 #include "ContextMenu.mqh"
 class CMenuBar : public CElement
  {    
    private:
    //Private properties:
      // --- Objects for creating a menu item
        CMenuItem         m_items[];
      // --- Array of pointers to context menus
        CContextMenu     *m_contextmenus[];
      // --- Main menu status
        bool              m_menubar_state;
      // --- Index of the previous activated item
        int               m_prev_active_item_index;
    //Private methods:    
        void              InitializeProperties(const int x_gap,const int y_gap);
        bool              CreateCanvas(void);
        bool              CreateItems(void); 
      // --- Handling clicks on a menu item
        bool              OnClickMenuItem(const int id,const int index);
      // --- Returns the active main menu item
        int               ActiveItemIndex(void);
      // --- Toggles the context menus of the main menu by hovering the cursor
        void              SwitchContextMenuByFocus(void);

      // --- Change the width along the right edge of the window
        virtual void      ChangeWidthByRightWindowSide(void);  
   public:
                     CMenuBar(void);
                     ~CMenuBar(void);
    // --- Methods for creating an element
      bool              CreateMenuBar(const int x_gap,const int y_gap); 
    // --- (1) Get the pointer to the specified menu item, (2) get the pointer to the specified context menu
      CMenuItem        *GetItemPointer(const uint index);
      CContextMenu     *GetContextMenuPointer(const uint index);
    // --- Number of (1) items and (2) context menus, (3) main menu status
      int               ItemsTotal(void)               const { return(::ArraySize(m_items));        }
      int               ContextMenusTotal(void)        const { return(::ArraySize(m_contextmenus)); }
      bool              State(void)                    const { return(m_menubar_state);             }
      void              State(const bool state);
    // --- Adds a menu item with the specified properties before creating the main menu
      void              AddItem(const int width,const string text);
    // --- Attaches the passed context menu to the specified main menu item
      void              AddContextMenuPointer(const uint index,CContextMenu &object);    
    // ---Graph event handler
      virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    // ---Delete
      virtual void      Delete(void);
    // --- Draws an element
      virtual void      Draw(void); 
  };
 #ifndef CMENUBAR_MQH_IMPLEMENTATION
 #define CMENUBAR_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CMenuBar::CMenuBar(void) : m_menubar_state(false),
                           m_prev_active_item_index(WRONG_VALUE)
    {
      // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
      // --- Center text in menu items
      CElement::IsCenterText(true);
    }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CMenuBar::~CMenuBar(void)
      {
      }
   //+------------------------------------------------------------------+
   // | Event Handler |
   //+------------------------------------------------------------------+
   void CMenuBar::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
    {
      // --- Handling focus change event on menu buttons
      if(id==CHARTEVENT_CUSTOM+ON_MOUSE_FOCUS)
         {
         // --- Exit if (2) main menu is not activated or (2) IDs do not match
         if(!m_menubar_state || lparam!=CElementBase::Id())
            return;
         // --- Switch the context menu for an activated main menu item
         SwitchContextMenuByFocus();
         return;
         }
      // --- Handling the event of pressing the left mouse button on a main menu item
      if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
         {
         if(OnClickMenuItem((uint)lparam,(uint)dparam))
            return;
         //---
         return;
         }
    }
   //+------------------------------------------------------------------+
   //| Creates the main menu                                            |
   //+------------------------------------------------------------------+
   bool CMenuBar::CreateMenuBar(const int x_gap,const int y_gap)
    {
      // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
      // ---Initializing properties
      InitializeProperties(x_gap,y_gap);
      // ---Creating an element
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
   void CMenuBar::InitializeProperties(const int x_gap,const int y_gap)
    {
      m_x        =CElement::CalculateX(x_gap);
      m_y        =CElement::CalculateY(y_gap);
      m_x_size   =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
      m_y_size   =(m_y_size<1)? 22 : m_y_size;
      // ---Default properties
         m_back_color           =(m_back_color!=clrNONE)? m_back_color : C'225,225,225';
         m_back_color_hover     =(m_back_color_hover!=clrNONE)? m_back_color_hover : C'51,153,255';
         m_back_color_pressed   =(m_back_color_pressed!=clrNONE)? m_back_color_pressed : m_back_color_hover;
         m_border_color         =(m_border_color!=clrNONE)? m_border_color : m_back_color;
         m_border_color_hover   =(m_border_color_hover!=clrNONE)? m_border_color_hover : m_back_color;
         m_border_color_pressed =(m_border_color_pressed!=clrNONE)? m_border_color_pressed : m_back_color;
         m_label_y_gap          =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 3;
         m_label_color          =(m_label_color!=clrNONE)? m_label_color : clrBlack;
         m_label_color_hover    =(m_label_color_hover!=clrNONE)? m_label_color_hover : clrWhite;
         m_label_color_pressed  =(m_label_color_pressed!=clrNONE)? m_label_color_pressed : clrWhite;
      // --- Indents from the extreme point
         CElementBase::XGap(x_gap);
         CElementBase::YGap(y_gap);
    }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CMenuBar::CreateCanvas(void)
    {
      // --- Formation of object name
      string name=CElementBase::ElementName("menubar");
      // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
      //---
      return(true);
    }
   //+------------------------------------------------------------------+
   // | Creates a list of menu items |
   //+------------------------------------------------------------------+
   bool CMenuBar::CreateItems(void)
    {
     // ---Coordinates
      int x=0,y=0;
     //---
      int items_total=ItemsTotal();
      for(int i=0; i<items_total; i++)
      {
       // --- X coordinate calculation
         x=(i>0)? x+m_items[i-1].XSize() : x;
       // --- Save the pointer to the main element
         m_items[i].MainPointer(this);
       // --- Set the properties before creating
         m_items[i].Index(i);
         m_items[i].NamePart("menu_item");
         m_items[i].TwoState(true);
         m_items[i].TypeMenuItem(MI_HAS_CONTEXT_MENU);
         m_items[i].ShowRightArrow(false);
         m_items[i].XSize(m_items[i].XSize());
         m_items[i].YSize(m_y_size);
         m_items[i].BackColor(m_back_color);
         m_items[i].BackColorHover(m_back_color_hover);
         m_items[i].BackColorPressed(m_back_color_pressed);
         m_items[i].BorderColor(m_border_color);
         m_items[i].BorderColorHover(m_border_color_hover);
         m_items[i].BorderColorPressed(m_border_color_pressed);
         m_items[i].IconXGap(3);
         m_items[i].IconYGap(4);
         m_items[i].LabelXGap(m_label_x_gap);
         m_items[i].LabelYGap(m_label_y_gap);
         m_items[i].LabelColor(m_label_color);
         m_items[i].LabelColorHover(m_label_color_hover);
         m_items[i].LabelColorPressed(m_label_color_pressed);
         m_items[i].IsCenterText(CElement::IsCenterText());
       // --- Create a menu item
         if(!m_items[i].CreateMenuItem(m_items[i].LabelText(),x,y))
            return(false);
       // --- Add element to array
         CElement::AddToArray(m_items[i]);
      }
      //---
      return(true);
    }
   //+------------------------------------------------------------------+
   // | Setting the main menu state |
   //+------------------------------------------------------------------+
   void CMenuBar::State(const bool state)
    {
      if(state)
         m_menubar_state=true;
      else
         {
         m_menubar_state=false;
         // --- Go through all main menu items to set the status of disabled context menus
         int items_total=ItemsTotal();
         for(int i=0; i<items_total; i++)
            {
            m_items[i].IsPressed(false);
            m_items[i].Update(true);
            }
         }
    }
   //+------------------------------------------------------------------+
   // | Returns the menu item pointer by index |
   //+------------------------------------------------------------------+
   CMenuItem *CMenuBar::GetItemPointer(const uint index)
    {
      uint array_size=::ArraySize(m_items);
      // --- If there is not a single item in the main menu, report it
      if(array_size<1)
         {
         ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, "
                  "когда в главном меню есть хотя бы один пункт!");
         }
      // --- Adjustment in case of leaving the range
      uint i=(index>=array_size)? array_size-1 : index;
      // --- Return pointer
      return(::GetPointer(m_items[i]));
    }
   //+------------------------------------------------------------------+
   //| Returns the context menu pointer by index                        |
   //+------------------------------------------------------------------+
   CContextMenu *CMenuBar::GetContextMenuPointer(const uint index)
    {
      uint array_size=::ArraySize(m_contextmenus);
      // --- If there is not a single item in the main menu, report it
      if(array_size<1)
         {
         ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, "
                  "когда в главном меню есть хотя бы один пункт!");
         }
      // --- Adjustment in case of leaving the range
      uint i=(index>=array_size)? array_size-1 : index;
      // --- Return pointer
      return(::GetPointer(m_contextmenus[i]));
    }
   //+------------------------------------------------------------------+
   // | Adds a menu item |
   //+------------------------------------------------------------------+
   void CMenuBar::AddItem(const int width,const string text)
    {
      // --- Increase the size of the arrays by one element
      int array_size=::ArraySize(m_items);
      ::ArrayResize(m_items,array_size+1);
      ::ArrayResize(m_contextmenus,array_size+1);
      // --- Save the values ​​of the passed parameters
      m_items[array_size].XSize(width);
      m_items[array_size].LabelText(text);
    }
   //+------------------------------------------------------------------+
   //| Adds a context menu pointer                                      |
   //+------------------------------------------------------------------+
   void CMenuBar::AddContextMenuPointer(const uint index,CContextMenu &object)
    {
      // --- Check for out of range
      uint size=::ArraySize(m_contextmenus);
      if(size<1 || index>=size)
         return;
      // --- Save pointer
      m_contextmenus[index]=::GetPointer(object);
    }
   //+------------------------------------------------------------------+
   // | Removal |
   //+------------------------------------------------------------------+
   void CMenuBar::Delete(void)
    {
      // --- Deleting objects
      CElement::Delete();
      // --- Freeing element arrays
      ::ArrayFree(m_items);
      ::ArrayFree(m_contextmenus);
    }
   //+------------------------------------------------------------------+
   // | Clicking on the main menu item |
   //+------------------------------------------------------------------+
   bool CMenuBar::OnClickMenuItem(const int id,const int index)
    {
      // --- Exit if (1) IDs do not match or (2) element is locked
      if(id!=CElementBase::Id() || CElementBase::IsLocked())
         return(false);
      // --- If there is a pointer to the context menu
      if(::CheckPointer(m_contextmenus[index])!=POINTER_INVALID)
         {
         // --- The state of the main menu depends on the visibility of the context menu
         m_menubar_state=(m_contextmenus[index].IsVisible())? false : true;
         // --- Define the selected item
         m_prev_active_item_index=(m_menubar_state)? index : WRONG_VALUE;
         }
      //---
      return(true);
    }
   //+------------------------------------------------------------------+
   // | Returns the index of the activated menu item |
   //+------------------------------------------------------------------+
   int CMenuBar::ActiveItemIndex(void)
    {
      int active_item_index=WRONG_VALUE;
      //---
      int items_total=ItemsTotal();
      for(int i=0; i<items_total; i++)
         {
         // ---If the item is in focus
         if(m_items[i].MouseFocus())
            {
            // --- Remember the index and stop the loop
            active_item_index=i;
            break;
            }
         }
      //---
      return(active_item_index);
    }
   //+------------------------------------------------------------------+
   // | Toggles main menu context menus by hovering |
   //+------------------------------------------------------------------+
   void CMenuBar::SwitchContextMenuByFocus(void)
    {
      // --- Get the index of the activated main menu item
      int active_item_index=ActiveItemIndex();
      // --- Quit if (1) the menu is not activated or (2) it is the same menu item
      if(active_item_index==WRONG_VALUE || active_item_index==m_prev_active_item_index)
         return;
      // --- Go to next if there is no context menu in this item
      if(::CheckPointer(m_contextmenus[active_item_index])!=POINTER_INVALID)
         {
         // --- Make the context menu visible
         m_contextmenus[active_item_index].Show();
         m_items[active_item_index].IsPressed(true);
         }
      // --- Get a pointer to the previous selected item
      CContextMenu *cm=m_contextmenus[m_prev_active_item_index];
      // --- Hide context menus that are opened from other context menus.
      // Let's loop through the items in the current context menu to find out if there are any.
      int cm_items_total=cm.ItemsTotal();
      for(int c=0; c<cm_items_total; c++)
         {
         CMenuItem *mi=cm.GetItemPointer(c);
         // --- Move to next if pointer to item is invalid
         if(::CheckPointer(mi)==POINTER_INVALID)
            continue;
         // --- Go to next if this item does not contain a context menu
         if(mi.TypeMenuItem()!=MI_HAS_CONTEXT_MENU)
            continue;
         // --- If the context menu is activated
         if(mi.IsPressed())
            {
            // --- Send a signal to close all context menus that are opened from this
            ::EventChartCustom(m_chart_id,ON_HIDE_BACK_CONTEXTMENUS,CElementBase::Id(),0,"");
            break;
            }
         }
      // --- Hide the main menu context menu
         m_contextmenus[m_prev_active_item_index].Hide();
         m_items[m_prev_active_item_index].IsPressed(false);
         m_items[m_prev_active_item_index].Update(true);
      // --- Remember the index of the currently activated menu
         m_prev_active_item_index=active_item_index;
      // --- Send a message to determine available elements
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
      // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
    }
   //+------------------------------------------------------------------+
   // | Change the width along the right edge of the form |
   //+------------------------------------------------------------------+
   void CMenuBar::ChangeWidthByRightWindowSide(void)
    {
      // --- Exit if the mode of fixing to the right edge of the form is enabled
      if(m_anchor_right_window_side)
         return;
      // --- Dimensions
      int x_size=0;
      // --- Calculate and set a new size for the element's background
      x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
      CElementBase::XSize(x_size);
      m_canvas.XSize(x_size);
      m_canvas.Resize(x_size,m_y_size);
      // --- Redraw element
      Draw();
      // --- Update object position
      Moving();
    }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CMenuBar::Draw(void)
    {
      // --- Draw background
      CElement::DrawBackground();
    }
   //+------------------------------------------------------------------+
 #endif // CMENUBAR_MQH_IMPLEMENTATION
#endif // __MENUBAR_MQH__




