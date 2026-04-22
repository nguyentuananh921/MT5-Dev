//+------------------------------------------------------------------+
//|                                                     MenuItem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Button.mqh"
class CContextMenu;
//+------------------------------------------------------------------+
// | Menu item creation class |
//+------------------------------------------------------------------+
class CMenuItem : public CButton
  {
private:
   // --- Pointer to previous node
   CMenuItem        *m_prev_node;
   // --- Pointer to the bound context menu
   CContextMenu     *m_context_menu;
   // --- Menu item type
   ENUM_TYPE_MENU_ITEM m_type_menu_item;
   // --- Context menu attribute properties
   bool              m_show_right_arrow;
   int               m_arrow_x_gap;
   // --- Checkbox state
   bool              m_checkbox_state;
   // --- Radio button state and its identifier
   bool              m_radiobutton_state;
   int               m_radiobutton_id;
   //---
public:
                     CMenuItem(void);
                    ~CMenuItem(void);
   // ---Methods for creating a menu item
   bool              CreateMenuItem(const string text,const int x_gap,const int y_gap);
   //---
public:
   // --- (1) Receive and (2) store the previous node pointer
   void              GetPrevNodePointer(CMenuItem &object)                { m_prev_node=::GetPointer(object);    }
   CMenuItem        *GetPrevNodePointer(void)                       const { return(m_prev_node);                 }
   void              GetContextMenuPointer(CContextMenu &object)          { m_context_menu=::GetPointer(object); }
   CContextMenu     *GetContextMenuPointer(void)                    const { return(m_context_menu);              }
   // --- (1) Set and get type, (2) index number
   void              TypeMenuItem(const ENUM_TYPE_MENU_ITEM type)         { m_type_menu_item=type;               }
   ENUM_TYPE_MENU_ITEM TypeMenuItem(void)                           const { return(m_type_menu_item);            }
   // --- (1) Displays the indication of the presence of a context menu, (2) the general state of the checkbox item
   void              ShowRightArrow(const bool flag)                      { m_show_right_arrow=flag;             }
   bool              CheckBoxState(void)                            const { return(m_checkbox_state);            }
   void              CheckBoxState(const bool state);
   // --- (1) Radio point identifier, (2) radio point status
   void              RadioButtonID(const int id)                          { m_radiobutton_id=id;                 }
   int               RadioButtonID(void)                            const { return(m_radiobutton_id);            }
   bool              RadioButtonState(void)                         const { return(m_radiobutton_state);         }
   void              RadioButtonState(const bool state);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Click on a menu item
   bool              OnClickMenuItem(const string pressed_object,const int id,const int index);
   // --- Draws a picture
   virtual void      DrawImage(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMenuItem::CMenuItem(void) : m_type_menu_item(MI_SIMPLE),
                             m_checkbox_state(true),
                             m_radiobutton_id(0),
                             m_radiobutton_state(false),
                             m_show_right_arrow(true),
                             m_arrow_x_gap(18)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMenuItem::~CMenuItem(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CMenuItem::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handle the event in the base class
   CButton::OnEvent(id,lparam,dparam,sparam);
// --- Handling the event of pressing the left mouse button on an element
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(OnClickMenuItem(sparam,(uint)lparam,(uint)dparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a "Menu Item" element |
//+------------------------------------------------------------------+
bool CMenuItem::CreateMenuItem(const string text,const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- If there is no pointer to the previous node, then the item is not part of the context menu
   if(::CheckPointer(m_prev_node)==POINTER_INVALID)
     {
      // --- Exit if the set type does not match
      if(m_type_menu_item!=MI_SIMPLE && m_type_menu_item!=MI_HAS_CONTEXT_MENU)
        {
         ::Print(__FUNCTION__," > Тип независимого пункта меню может быть только MI_SIMPLE или MI_HAS_CONTEXT_MENU, ",
                 "то есть, с наличием контекстного меню.\n",
                 __FUNCTION__," > Установить тип пункта меню можно с помощью метода CMenuItem::TypeMenuItem()");
         return(false);
        }
     }
// --- Define shortcuts if the item has a drop-down menu
   if(m_type_menu_item==MI_HAS_CONTEXT_MENU)
     {
      CButton::TwoState(true);
      // --- If you need to display an arrow as a sign of the presence of a context menu
      if(m_show_right_arrow)
        {
         if(CButton::ImagesGroupTotal()<2)
           {
            CButton::AddImagesGroup(CElementBase::XSize()-m_arrow_x_gap,CElement::IconYGap());
            CButton::AddImage(1,RESOURCE_ARROW_RIGHT_BLACK);
            CButton::AddImage(1,RESOURCE_ARROW_RIGHT_WHITE);
           }
        }
     }
// --- If it's a checkbox
   if(m_type_menu_item==MI_CHECKBOX)
     {
      // ---Default images
      CButton::SetImage(0,0,RESOURCE_CHECKBOX_MINI_BLACK);
      CButton::SetImage(0,1,RESOURCE_CHECKBOX_MINI_WHITE);
      CButton::AddImage(0,INT_MAX);
     }
// ---If it is a radio point
   else if(m_type_menu_item==MI_RADIOBUTTON)
     {
      // ---Default images
      CButton::SetImage(0,0,RESOURCE_CHECKBOX_MINI_BLACK);
      CButton::SetImage(0,1,RESOURCE_CHECKBOX_MINI_WHITE);
      CButton::AddImage(0,INT_MAX);
     }
// --- Properties
   CButton::NamePart("menu_item");
// --- Let's create a control
   if(!CButton::CreateButton(text,x_gap,y_gap))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Changing the state of a checkbox menu item |
//+------------------------------------------------------------------+
void CMenuItem::CheckBoxState(const bool state)
  {
   m_checkbox_state=state;
   Update(true);
  }
//+------------------------------------------------------------------+
// | Changing the state of a menu item such as radio item |
//+------------------------------------------------------------------+
void CMenuItem::RadioButtonState(const bool state)
  {
   m_radiobutton_state=state;
   Update(true);
  }
//+------------------------------------------------------------------+
// | Makes the menu item visible |
//+------------------------------------------------------------------+
void CMenuItem::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Show element
   CButton::Show();
// --- Update object position
   Moving();
  }
//+------------------------------------------------------------------+
// | Hides menu item |
//+------------------------------------------------------------------+
void CMenuItem::Hide(void)
  {
// --- Exit if element is hidden
   if(!CElementBase::IsVisible())
      return;
// --- Hide element
   CButton::Hide();
// --- Resetting variables
   CElementBase::IsVisible(false);
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
// | Handling a click on a menu item |
//+------------------------------------------------------------------+
bool CMenuItem::OnClickMenuItem(const string pressed_object,const int id,const int index)
  {
// --- Exit if the button was not pressed
   if(::StringFind(pressed_object,"menu_item")<0)
      return(false);
// --- Exit if (1) IDs do not match or (2) element is locked
   if(id!=CElementBase::Id() || index!=CElementBase::Index() || CElementBase::IsLocked())
      return(false);
      
// --- If this item contains a context menu
   if(m_type_menu_item==MI_HAS_CONTEXT_MENU)
     {
      if(::CheckPointer(m_context_menu)==POINTER_INVALID)
         return(true);
      // --- If the drop-down menu of this item is not activated
      if(!m_context_menu.IsVisible())
        {
         // --- Show context menu
         m_context_menu.Show();
         // --- Message to restore available items
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
        }
      else
        {
         int is_restore=1;
         if(CheckPointer(m_prev_node)!=POINTER_INVALID)
            is_restore=0;
         // --- Hide context menu
         m_context_menu.Hide();
         // --- Send a signal to close context menus that are further than this item
         ::EventChartCustom(m_chart_id,ON_HIDE_BACK_CONTEXTMENUS,CElementBase::Id(),0,"");
         // --- Message to restore available items
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),is_restore,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
        }
     }
// --- If this item does not contain a context menu, but is part of the context menu
   else
     {
      // --- Message prefix with program name
      string message=CElementBase::ProgramName();
      // --- If this is a checkbox, change its state
      if(m_type_menu_item==MI_CHECKBOX)
        {
         m_checkbox_state=(m_checkbox_state)? false : true;
         // --- Add to the message that this is a checkbox
         message+="_checkbox";
        }
      // --- If this is a radio item, change its state
      else if(m_type_menu_item==MI_RADIOBUTTON)
        {
         m_radiobutton_state=(m_radiobutton_state)? false : true;
         // --- Let's add to the message that this is a radio point
         message+="_radioitem_"+(string)m_radiobutton_id;
        }
      // --- Press the button
      CElementBase::MouseFocus(false);
      CElement::Update(true);
      // --- We will send a message about this
      ::EventChartCustom(m_chart_id,ON_CLICK_MENU_ITEM,CElementBase::Id(),CElementBase::Index(),message);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CMenuItem::Draw(void)
  {
// --- Draw background
   CButton::DrawBackground();
// --- Draw a frame
   CButton::DrawBorder();
// --- Draw a picture
   if(m_type_menu_item!=MI_SIMPLE)
      CMenuItem::DrawImage();
   else
      CButton::DrawImage();
// --- Draw text
   CElement::DrawText();
  }
//+------------------------------------------------------------------+
// | Draws a picture |
//+------------------------------------------------------------------+
void CMenuItem::DrawImage(void)
  {
// --- Define the index
   uint image_index=0;
//---
   if(m_type_menu_item==MI_CHECKBOX)
     {
      image_index=(m_checkbox_state)?(m_mouse_focus)? 1 : 0 : 2;
      // --- Save index of selected image
      CElement::ChangeImage(0,image_index);
     }
   else if(m_type_menu_item==MI_RADIOBUTTON)
     {
      image_index=(m_radiobutton_state)?(m_mouse_focus)? 1 : 0 : 2;
      // --- Save index of selected image
      CElement::ChangeImage(0,image_index);
     }
   else if(m_type_menu_item==MI_HAS_CONTEXT_MENU)
     {
      image_index=(m_mouse_focus || m_is_pressed)? 1 : 0;
      // --- Save index of selected image
      CElement::ChangeImage(0,0);
      CElement::ChangeImage(1,image_index);
     }
   else
     {
      // --- Save index of selected image
      CElement::ChangeImage(0,image_index);
     }
// --- Draw a picture
   CElement::DrawImage();
  }
//+------------------------------------------------------------------+
