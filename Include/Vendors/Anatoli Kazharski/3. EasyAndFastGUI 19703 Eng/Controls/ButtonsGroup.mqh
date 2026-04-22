//+------------------------------------------------------------------+
//|                                                 ButtonsGroup.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Button.mqh"
//+------------------------------------------------------------------+
// | Class for creating a group of buttons |
//+------------------------------------------------------------------+
class CButtonsGroup : public CElement
  {
private:
   // --- Instances to create an element
   CButton           m_buttons[];
   // --- Radio button mode
   bool              m_radio_buttons_mode;
   // --- Radio button display style
   bool              m_radio_buttons_style;
   // --- Button height
   int               m_button_y_size;
   // --- (1) Text and (2) index of the highlighted button
   string            m_selected_button_text;
   int               m_selected_button_index;
   //---
public:
                     CButtonsGroup(void);
                    ~CButtonsGroup(void);
   // --- Methods for creating a button
   bool              CreateButtonsGroup(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateButtons(void);
   //---
public:
   // --- Returns a pointer to the button at the specified index
   CButton          *GetButtonPointer(const uint index);
   // --- (1) Number of buttons, (2) button height
   int               ButtonsTotal(void)                       const { return(::ArraySize(m_buttons));  }
   void              ButtonYSize(const int y_size)                  { m_button_y_size=y_size;          }
   // --- (1) Setting the mode and (2) display style of radio buttons
   void              RadioButtonsMode(const bool flag)              { m_radio_buttons_mode=flag;       }
   void              RadioButtonsStyle(const bool flag)             { m_radio_buttons_style=flag;      }
   // --- Returns (1) the text and (2) the index of the selected button
   string            SelectedButtonText(void)                 const { return(m_selected_button_text);  }
   int               SelectedButtonIndex(void)                const { return(m_selected_button_index); }

   // --- Adds a button with the specified properties before creation
   void              AddButton(const int x_gap,const int y_gap,const string text,const int width,
                               const color button_color=clrNONE,const color button_color_hover=clrNONE,const color button_color_pressed=clrNONE);
   // --- Toggles the button at the specified index
   void              SelectButton(const uint index,const bool is_external_call=true);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // ---Object management
   virtual void      Show(void);
   virtual void      Delete(void);
   // --- Updates the element to reflect the latest changes
   virtual void      Update(const bool redraw=false);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Handling a button click
   bool              OnClickButton(const string pressed_object,const int id,const int index);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CButtonsGroup::CButtonsGroup(void) : m_button_y_size(20),
                                     m_radio_buttons_mode(false),
                                     m_radio_buttons_style(false),
                                     m_selected_button_text(""),
                                     m_selected_button_index(WRONG_VALUE)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
// ---Default label
   CElementBase::NamePart("button");
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CButtonsGroup::~CButtonsGroup(void)
  {
  }
//+------------------------------------------------------------------+
// | Graphics event handler |
//+------------------------------------------------------------------+
void CButtonsGroup::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the event of pressing the left mouse button on an element
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(OnClickButton(sparam,(uint)lparam,(uint)dparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a group of buttons |
//+------------------------------------------------------------------+
bool CButtonsGroup::CreateButtonsGroup(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// --- Creates buttons
   if(!CreateButtons())
      return(false);
// --- Select radio button
   if(m_radio_buttons_mode)
      m_buttons[m_selected_button_index].IsPressed(true);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CButtonsGroup::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x =CElement::CalculateX(x_gap);
   m_y =CElement::CalculateY(y_gap);
// --- Default values
   m_label_x_gap =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 18;
   m_label_y_gap =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
// --- One radio button must be highlighted
   if(m_radio_buttons_mode)
      m_selected_button_index=(m_selected_button_index!=WRONG_VALUE)? m_selected_button_index : 0;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
// ---Priority is the same as the main element, since the element does not have its own clickable area
   CElement::Z_Order(m_main.Z_Order());
  }
//+------------------------------------------------------------------+
// | Creates buttons |
//+------------------------------------------------------------------+
bool CButtonsGroup::CreateButtons(void)
  {
// --- Coordinates
   int x=0,y=0;
// --- Get the number of buttons
   int buttons_total=ButtonsTotal();
// --- If there is not a single button in the group, report it
   if(buttons_total<1)
     {
      // ::Print(__FUNCTION__," > This method must be called ...\n"
      // "... when there is at least one button in the group! Use the CButtonsGroup::AddButton() method"
      
      ::Print(__FUNCTION__," > You must call this method when there is at least one button in the group! "
              "Use the method CButtonsGroup::AddButton()");
      return(false);
     }
// --- Create the specified number of buttons
   for(int i=0; i<buttons_total; i++)
     {
      // --- Save a pointer to the parent element
      m_buttons[i].MainPointer(this);
      // --- Coordinates
      x =m_buttons[i].XGap();
      y =m_buttons[i].YGap();
      // --- Properties
      m_buttons[i].NamePart(CElementBase::NamePart());
      m_buttons[i].Alpha(m_alpha);
      m_buttons[i].IconXGap(m_icon_x_gap);
      m_buttons[i].IconYGap(m_icon_y_gap);
      m_buttons[i].LabelXGap(m_label_x_gap);
      m_buttons[i].LabelYGap(m_label_y_gap);
      m_buttons[i].IsCenterText(CElement::IsCenterText());
      m_buttons[i].IsDropdown(CElementBase::IsDropdown());
      // --- Let's create a control
      if(!m_buttons[i].CreateButton(m_buttons[i].LabelText(),x,y))
         return(false);
      // --- Press the button if defined
      if(i==m_selected_button_index)
         m_buttons[i].IsPressed(true);
      // --- Add element to array
      CElement::AddToArray(m_buttons[i]);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns a pointer to the button at the specified index |
//+------------------------------------------------------------------+
CButton *CButtonsGroup::GetButtonPointer(const uint index)
  {
   uint array_size=::ArraySize(m_buttons);
// --- Checking the size of an array of objects
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > There is no button in the group!");
      return(NULL);
     }
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return object pointer
   return(::GetPointer(m_buttons[i]));
  }
//+------------------------------------------------------------------+
// | Adds a button |
//+------------------------------------------------------------------+
void CButtonsGroup::AddButton(const int x_gap,const int y_gap,const string text,const int width,
                              const color button_color=clrNONE,const color button_color_hover=clrNONE,const color button_color_pressed=clrNONE)
  {
// ---Reserve size
   int reserve_size=100;
// --- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_buttons);
   int new_size=array_size+1;
   ::ArrayResize(m_buttons,new_size,reserve_size);
// --- Set properties
   m_buttons[array_size].Index(array_size);
   m_buttons[array_size].TwoState(true);
   m_buttons[array_size].XSize(width);
   m_buttons[array_size].YSize(m_button_y_size);
   m_buttons[array_size].XGap(x_gap);
   m_buttons[array_size].YGap(y_gap);
   m_buttons[array_size].LabelText(text);
   m_buttons[array_size].BackColor(button_color);
   m_buttons[array_size].BackColorHover(button_color_hover);
   m_buttons[array_size].BackColorPressed(button_color_pressed);
// --- Quit if radio button style is turned off
   if(!m_radio_buttons_style)
      return;
//---
   m_buttons[array_size].BackColor(m_main.BackColor());
   m_buttons[array_size].BackColorHover(m_main.BackColor());
   m_buttons[array_size].BackColorPressed(m_main.BackColor());
   m_buttons[array_size].BackColorLocked(m_main.BackColor());
   m_buttons[array_size].BorderColor(m_main.BackColor());
   m_buttons[array_size].BorderColorHover(m_main.BackColor());
   m_buttons[array_size].BorderColorPressed(m_main.BackColor());
   m_buttons[array_size].BorderColorLocked(m_main.BackColor());
   m_buttons[array_size].LabelColorHover(C'0,120,215');
   m_buttons[array_size].IconXGap(m_icon_x_gap);
   m_buttons[array_size].IconYGap(m_icon_y_gap);
   m_buttons[array_size].IconFileLocked(RESOURCE_RADIO_BUTTON_OFF_LOCKED);
   m_buttons[array_size].IconFile(RESOURCE_RADIO_BUTTON_OFF);
   m_buttons[array_size].IconFileLocked(RESOURCE_RADIO_BUTTON_OFF_LOCKED);
   m_buttons[array_size].CElement::IconFilePressed(RESOURCE_RADIO_BUTTON_ON);
   m_buttons[array_size].CElement::IconFilePressedLocked(RESOURCE_RADIO_BUTTON_ON_LOCKED);
  }
//+------------------------------------------------------------------+
// | Toggles the button at the specified index |
//+------------------------------------------------------------------+
void CButtonsGroup::SelectButton(const uint index,const bool is_external_call=true)
  {
// --- To check the existence of a button pressed in a group
   bool check_pressed_button=false;
// --- Get the number of buttons
   uint buttons_total=ButtonsTotal();
// --- If there is not a single button in the group, report it
   if(buttons_total<1)
     {  
      ::Print(__FUNCTION__," > You must call this method when there is at least one button in the group! "
              "Use the method CButtonsGroup::AddButton()");
      return;
     }
// --- Adjust index value if out of range
   uint correct_index=(index>=buttons_total)? buttons_total-1 : index;
//---
   if(is_external_call && !m_radio_buttons_mode)
      m_buttons[correct_index].IsPressed(!m_buttons[correct_index].IsPressed());
// --- Let's loop through a group of buttons
   for(uint i=0; i<buttons_total; i++)
     {
      if(i==correct_index)
        {
         if(m_radio_buttons_mode)
            m_buttons[i].IsPressed(true);
         // ---If there is a pressed button
         if(m_buttons[i].IsPressed())
            check_pressed_button=true;
         //---
         continue;
        }
      // --- Press the remaining buttons
      if(m_buttons[i].IsPressed())
         m_buttons[i].IsPressed(false);
     }
// --- If there is a pressed button, save its text and index
   m_selected_button_text  =(check_pressed_button)? m_buttons[correct_index].LabelText() : "";
   m_selected_button_index =(check_pressed_button)? (int)correct_index : WRONG_VALUE;
  }
//+------------------------------------------------------------------+
// | Show |
//+------------------------------------------------------------------+
void CButtonsGroup::Show(void)
  {
   CElement::Show();
   int total=ButtonsTotal();
   for(int i=0; i<total; i++)
      m_buttons[i].Show();
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CButtonsGroup::Delete(void)
  {
   CElement::Delete();
// --- Freeing element arrays
   ::ArrayFree(m_buttons);
  }
//+------------------------------------------------------------------+
// | Item Update |
//+------------------------------------------------------------------+
void CButtonsGroup::Update(const bool redraw=false)
  {
   int buttons_total=ButtonsTotal();
// --- With element redrawing
   if(redraw)
     {
      for(int i=0; i<buttons_total; i++)
         m_buttons[i].Draw();
      for(int i=0; i<buttons_total; i++)
         m_buttons[i].Update();
      //---
      return;
     }
// --- Apply
   for(int i=0; i<buttons_total; i++)
      m_buttons[i].Update();
  }
//+------------------------------------------------------------------+
// | Clicking a button in a group |
//+------------------------------------------------------------------+
bool CButtonsGroup::OnClickButton(const string pressed_object,const int id,const int index)
  {
// --- Exit if the click was not on this element
   if(!CElementBase::CheckElementName(pressed_object))
      return(false);
// --- Exit if (1) IDs do not match or (2) element is locked
   if(id!=CElementBase::Id() || CElementBase::IsLocked())
      return(false);
// ---If this button is already pressed
   if(index==m_selected_button_index)
     {
      // --- Toggle button
      SelectButton(m_selected_button_index,false);
      return(true);
     }
//---
   int check_index=WRONG_VALUE;
// --- Let's check whether one of the buttons of this group was pressed
   int buttons_total=ButtonsTotal();
// --- If there was a click, we will remember the index
   for(int i=0; i<buttons_total; i++)
     {
      if(m_buttons[i].Index()==index)
        {
         check_index=i;
         break;
        }
     }
// --- Exit if no button was pressed in this group
   if(check_index==WRONG_VALUE)
      return(false);
// --- Toggle button
   SelectButton(check_index,false);
   Update(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_GROUP_BUTTON,CElementBase::Id(),m_selected_button_index,m_selected_button_text);
   return(true);
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CButtonsGroup::Draw(void)
  {
   int buttons_total=ButtonsTotal();
   for(int i=0; i<buttons_total; i++)
      m_buttons[i].Draw();
  }
//+------------------------------------------------------------------+
