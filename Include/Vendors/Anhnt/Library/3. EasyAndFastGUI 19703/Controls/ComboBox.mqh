//+------------------------------------------------------------------+
//|                                                     ComboBox.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "ListView.mqh"
//+------------------------------------------------------------------+
// | Class for creating a combo box |
//+------------------------------------------------------------------+
class CComboBox : public CElement
  {
private:
   // --- Instances to create an element
   CButton           m_button;
   CListView         m_listview;
   // --- Element mode with checkbox
   bool              m_checkbox_mode;
   //---
public:
                     CComboBox(void);
                    ~CComboBox(void);
   // ---Methods for creating a combo box
   bool              CreateComboBox(const string text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const string text,const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateButton(void);
   bool              CreateList(void);
   //---
public:
   // --- Returns pointers to (1) a button, (2) a list, and (3) a scrollbar
   CButton          *GetButtonPointer(void)                 { return(::GetPointer(m_button));         }
   CListView        *GetListViewPointer(void)               { return(::GetPointer(m_listview));       }
   CScrollV         *GetScrollVPointer(void)                { return(m_listview.GetScrollVPointer()); }
   // --- (1) List size (number of items) (2) setting the element mode with a checkbox
   void              ItemsTotal(const int items_total)      { m_listview.ListSize(items_total);       }
   void              CheckBoxMode(const bool state)         { m_checkbox_mode=state;                  }
   // --- Element state (pressed/released)
   bool              IsPressed(void) const { return(m_is_pressed); }
   void              IsPressed(const bool state);
   // --- Stores the passed value in a list at the specified index
   void              SetValue(const int item_index,const string item_text);
   // --- Returns the selected value in the list
   string            GetValue(void);
   // --- Select an item by the specified index
   void              SelectItem(const int item_index);
   // --- Changes the current state of the combo box to the opposite
   void              ChangeComboBoxListState(void);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Lock
   virtual void      IsLocked(const bool state);
   // --- Visibility control
   virtual void      Hide(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Handling clicks on an element
   bool              OnClickElement(const string pressed_object);
   // --- Handling a button click
   bool              OnClickButton(const string pressed_object,const int id,const int index);
   // --- Handling clicks on a list item
   bool              OnClickListItem(const int id);

   // --- Checking the left mouse button pressed above the combo box button
   void              CheckPressedOverButton(void);
   // --- Draws a picture
   virtual void      DrawImage(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CComboBox::CComboBox(void) : m_checkbox_mode(false)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
// --- Dropdown list mode
   m_listview.IsDropdown(true);
   m_listview.GetScrollVPointer().IsDropdown(true);
   m_listview.GetScrollVPointer().GetIncButtonPointer().IsDropdown(true);
   m_listview.GetScrollVPointer().GetDecButtonPointer().IsDropdown(true);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CComboBox::~CComboBox(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CComboBox::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Checking the left mouse button pressed above the button
      CheckPressedOverButton();
      // --- Redraw element
      if(CheckCrossingBorder())
         Update(true);
      //---
      return;
     }
// --- Handling a click event on a list item
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
     {
      if(!OnClickListItem((int)lparam))
         return;
      //---
      return;
     }
// --- Handling clicks on an element
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OnClickElement(sparam))
         return;
      //---
      return;
     }
// --- Handling the button click event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(OnClickButton(sparam,(uint)lparam,(uint)dparam))
         return;
      //---
      return;
     }
// --- Processing the event of changing chart properties
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      // --- Exit if (1) the element is locked or (2) the button is released
      if(CElementBase::IsLocked() || !m_button.IsPressed())
         return;
      // --- Press the button
      m_button.IsPressed(false);
      // --- Change list state
      ChangeComboBoxListState();
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a group of objects of the combo box type |
//+------------------------------------------------------------------+
bool CComboBox::CreateComboBox(const string text,const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// ---Initializing properties
   InitializeProperties(text,x_gap,y_gap);
// ---Creating an element
   if(!CreateCanvas())
      return(false);
   if(!CreateButton())
      return(false);
   if(!CreateList())
      return(false);
// --- Set text to button
   m_button.LabelText(m_listview.SelectedItemText());
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CComboBox::InitializeProperties(const string text,const int x_gap,const int y_gap)
  {
   m_x          =CElement::CalculateX(x_gap);
   m_y          =CElement::CalculateY(y_gap);
   m_x_size     =(m_x_size<1)? 50 : m_x_size;
   m_y_size     =(m_y_size<1)? 20 : m_y_size;
   m_label_text =text;
// --- Background color and padding for the image/checkbox
   m_back_color=(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
// --- Indentation and color of text label
   m_icon_y_gap          =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 4;
   m_label_x_gap         =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : (m_checkbox_mode)? 20 : 0;
   m_label_y_gap         =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 4;
   m_label_color         =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_color_hover   =(m_label_color_hover!=clrNONE)? m_label_color_hover : C'0,120,215';
   m_label_color_locked  =(m_label_color_locked!=clrNONE)? m_label_color_locked : clrSilver;
   m_label_color_pressed =(m_label_color_pressed!=clrNONE)? m_label_color_pressed : clrBlack;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CComboBox::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("combobox");
// --- If you need an element with a checkbox
   if(m_checkbox_mode)
     {
      IconFile(IMAGE_RESOURCE_CONTROLS_CHECKBOX_OFF_BMP);
      IconFileLocked(IMAGE_RESOURCE_CONTROLS_CHECKBOX_OFF_LOCKED_BMP);
      IconFilePressed(IMAGE_RESOURCE_CONTROLS_CHECKBOX_ON_BMP);
      IconFilePressedLocked(IMAGE_RESOURCE_CONTROLS_CHECKBOX_ON_LOCKED_BMP);
     }
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a button |
//+------------------------------------------------------------------+
bool CComboBox::CreateButton(void)
  {
// --- Save a pointer to the parent element
   m_button.MainPointer(this);
// --- Dimensions
   int x_size=(m_button.XSize()<1)? 80 : m_button.XSize();
// --- Coordinates
   int x =(m_button.XGap()<1)? x_size : m_button.XGap();
   int y =0;
// --- Indents for the image
   int icon_x_gap =(m_button.IconXGap()<1)? x_size-18 : m_button.IconXGap();
   int icon_y_gap =(m_button.IconYGap()<1)? 2 : m_button.IconYGap();
// ---Text indentation
   int label_x_gap =(m_button.LabelXGap()<1)? 7 : m_button.LabelXGap();
   int label_y_gap =(m_button.LabelYGap()<1)? 4 : m_button.LabelYGap();
// --- Properties
   m_button.NamePart("combobox_button");
   m_button.Index(0);
   m_button.TwoState(true);
   m_button.XSize(x_size);
   m_button.YSize(m_y_size);
   m_button.IconXGap(icon_x_gap);
   m_button.IconYGap(icon_y_gap);
   m_button.LabelXGap(label_x_gap);
   m_button.LabelYGap(label_y_gap);
   m_button.IsDropdown(CElementBase::IsDropdown());
   m_button.IconFile(IMAGE_RESOURCE_CONTROLS_DOWN_THIN_BLACK_BMP);
   m_button.IconFileLocked(IMAGE_RESOURCE_CONTROLS_DOWN_THIN_BLACK_BMP);
   m_button.CElement::IconFilePressed(IMAGE_RESOURCE_CONTROLS_UP_THIN_BLACK_BMP);
   m_button.CElement::IconFilePressedLocked(IMAGE_RESOURCE_CONTROLS_UP_THIN_BLACK_BMP);
   
// --- Let's create a control
   if(!m_button.CreateButton("",x,y))
      return(false);
   
// --- Add element to array
   CElement::AddToArray(m_button);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a list |
//+------------------------------------------------------------------+
bool CComboBox::CreateList(void)
  {
// --- Save the pointer to the main element
   m_listview.MainPointer(this);
// --- Coordinates
   int x =m_button.XGap();
   int y =m_button.YSize();
// --- Dimensions
   int x_size =(m_listview.XSize()<1)? m_button.XSize() : m_listview.XSize();
   int y_size =(m_listview.YSize()<1)? 93 : m_listview.YSize();
// --- Properties
   m_listview.XSize(x_size);
   m_listview.YSize(y_size);
   m_listview.AnchorRightWindowSide(m_button.AnchorRightWindowSide());
// --- Let's create a control
   if(!m_listview.CreateListView(x,y))
      return(false);
// --- Hide list
   m_listview.Hide();
// --- Add element to array
   CElement::AddToArray(m_listview);
   return(true);
  }
//+------------------------------------------------------------------+
// | Setting the element state (pressed/released) |
//+------------------------------------------------------------------+
void CComboBox::IsPressed(const bool state)
  {
// --- Exit if (1) the element is blocked or (2) the element is already in this state
   if(CElementBase::IsLocked() || m_is_pressed==state)
      return;
// ---Status setting
   m_is_pressed=state;
// --- Set the corresponding picture
   CElement::ChangeImage(0,!m_is_pressed? 0 : 2);
  }
//+------------------------------------------------------------------+
// | Stores the passed value in a list at the specified index |
//+------------------------------------------------------------------+
void CComboBox::SetValue(const int item_index,const string item_text)
  {
   m_listview.SetValue(item_index,item_text);
  }
//+------------------------------------------------------------------+
// | Returns the selected value in the list |
//+------------------------------------------------------------------+
string CComboBox::GetValue(void)
  {
   return(m_listview.SelectedItemText());
  }
//+------------------------------------------------------------------+
// | Selecting an item by the specified index |
//+------------------------------------------------------------------+
void CComboBox::SelectItem(const int item_index)
  {
// --- Select an item in the list
   m_listview.SelectItem(item_index);
// --- Set text to button
   m_button.LabelText(m_listview.SelectedItemText());
  }
//+------------------------------------------------------------------+
// | Lock |
//+------------------------------------------------------------------+
void CComboBox::IsLocked(const bool state)
  {
   CElement::IsLocked(state);
// --- Set the corresponding picture
   CElement::ChangeImage(0,(m_is_locked)? !m_is_pressed? 1 : 3 : !m_is_pressed? 0 : 2);
  }
//+------------------------------------------------------------------+
// | Hiding |
//+------------------------------------------------------------------+
void CComboBox::Hide(void)
  {
   CElement::Hide();
// --- Press the button
   m_button.IsPressed(false);
  }
//+------------------------------------------------------------------+
// | Changes the current state of the combo box to the opposite |
//+------------------------------------------------------------------+
void CComboBox::ChangeComboBoxListState(void)
  {
// ---If the button is pressed
   if(m_button.IsPressed())
     {
      // --- Show list
      m_listview.Show();
      // --- Send a message to determine available elements
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
     }
   else
     {
      // --- Hide list
      m_listview.Hide();
      // --- We will send a message to restore the items
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
     }
  }
//+------------------------------------------------------------------+
// | Clicking on the checkbox |
//+------------------------------------------------------------------+
bool CComboBox::OnClickElement(const string pressed_object)
  {
// --- Exit if (1) the element is blocked or (2) the object name is foreign
   if(CElementBase::IsLocked() || m_canvas.ChartObjectName()!=pressed_object)
      return(false);
// --- If the checkbox is enabled
   if(m_checkbox_mode)
     {
      // --- Switch to the opposite mode
      IsPressed(!(IsPressed()));
      // --- We will send a message about this
      ::EventChartCustom(m_chart_id,ON_CLICK_CHECKBOX,CElementBase::Id(),CElementBase::Index(),"");
     }
// --- Draw element
   CElement::Update(true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Clicking the combo box button |
//+------------------------------------------------------------------+
bool CComboBox::OnClickButton(const string pressed_object,const int id,const int index)
  {
// --- Exit if the click was on another element
   if(!m_button.CheckElementName(pressed_object))
      return(false);
// --- Exit if values ​​do not match
   if(id!=m_button.Id() || index!=m_button.Index())
      return(false);
// --- Change list state
   ChangeComboBoxListState();
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_COMBOBOX_BUTTON,CElementBase::Id(),0,"");
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling a click on a list item |
//+------------------------------------------------------------------+
bool CComboBox::OnClickListItem(const int id)
  {
// --- Exit if values ​​do not match
   if(id!=CElementBase::Id())
      return(false);
// --- Press the button
   m_button.IsPressed(false);
// --- Set text to button
   m_button.LabelText(m_listview.SelectedItemText());
   m_button.Update(true);
// --- Change list state
   ChangeComboBoxListState();
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_COMBOBOX_ITEM,CElementBase::Id(),0,m_label_text);
   return(true);
  }
//+------------------------------------------------------------------+
// | Checking the left mouse button pressed above the button |
//+------------------------------------------------------------------+
void CComboBox::CheckPressedOverButton(void)
  {
// --- Exit if the button is already released
   if(!m_button.IsPressed())
      return;
// --- Exit if (1) the element is locked or (2) the left mouse button is released
   if(CElementBase::IsLocked() || !m_mouse.LeftButtonState())
      return;
// --- If there is no focus
   if(!CElementBase::MouseFocus() && !m_button.MouseFocus())
     {
      // --- Exit if focus is on list or list scrollbar in action
      if(m_listview.MouseFocus() || m_listview.ScrollState())
         return;
      // --- Hide list
      m_listview.Hide();
      m_button.IsPressed(false);
      m_button.Update(true);
      // --- Draw element
      Update(true);
      // --- We will send a message to restore the items
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
     }
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CComboBox::Draw(void)
  {
// --- Draw background
   CElement::DrawBackground();
// --- Draw a picture
   CElement::DrawImage();
// --- Draw text
   CElement::DrawText();
  }
//+------------------------------------------------------------------+
// | Draws a picture |
//+------------------------------------------------------------------+
void CComboBox::DrawImage(void)
  {
// --- Quit if (1) the checkbox is not needed or (2) the image is not defined
   if(!m_checkbox_mode || CElement::IconFile()=="")
      return;
// --- Define the index
   uint image_index=(m_is_pressed)? 2 : 0;
// --- If the element is not locked
   if(!CElementBase::IsLocked())
     {
      if(CElementBase::MouseFocus())
         image_index=(m_is_pressed)? 2 : 0;
     }
   else
      image_index=(m_is_pressed)? 3 : 1;
// --- Set the corresponding picture
   CElement::ChangeImage(0,image_index);
// --- Draw a picture
   CElement::DrawImage();
  }
//+------------------------------------------------------------------+
