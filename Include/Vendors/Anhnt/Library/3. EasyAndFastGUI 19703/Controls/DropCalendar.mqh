//+------------------------------------------------------------------+
//|                                                 DropCalendar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Calendar.mqh"
//+------------------------------------------------------------------+
// | Class for creating a drop-down calendar |
//+------------------------------------------------------------------+
class CDropCalendar : public CElement
  {
private:
   // --- Objects and elements to create an element
   CTextEdit         m_date_box;
   CButton           m_drop_button;
   CCalendar         m_calendar;
   //---
public:
                     CDropCalendar(void);
                    ~CDropCalendar(void);
   // ---Methods for creating a drop-down calendar
   bool              CreateDropCalendar(const string text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const string text,const int x_gap,const int y_gap);
   bool              CreateDateBox(void);
   bool              CreateDropButton(void);
   bool              CreateCalendar(void);
   //---
public:
   // --- Returns pointers to elements
   CTextEdit        *GetTextEditPointer(void)      { return(::GetPointer(m_date_box));    }
   CButton          *GetDropButtonPointer(void)    { return(::GetPointer(m_drop_button)); }
   CCalendar        *GetCalendarPointer(void)      { return(::GetPointer(m_calendar));    }
   // --- (1) Set (highlight) and (2) get the selected date
   void              SelectedDate(const datetime date);
   datetime          SelectedDate(void) { return(m_calendar.SelectedDate()); }
   // --- Reversing the calendar visibility state
   void              ChangeComboBoxCalendarState(void);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Handling a click on a combo box button
   bool              OnClickButton(const string pressed_object,const int id,const int index);
   // --- Checking the left mouse button pressed above the combo box button
   void              CheckPressedOverButton(void);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDropCalendar::CDropCalendar(void)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDropCalendar::~CDropCalendar(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CDropCalendar::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Checking the left mouse button pressed above the combo box button
      CheckPressedOverButton();
      return;
     }
// --- Handling the event of selecting a new date in the calendar
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_DATE)
     {
      // --- Exit if element IDs do not match
      if(lparam!=CElementBase::Id())
         return;
      // --- Set a new date in the combo box
      m_date_box.SetValue(::TimeToString((datetime)dparam,TIME_DATE),false);
      m_date_box.GetTextBoxPointer().Update(true);
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
  }
//+------------------------------------------------------------------+
// | Creates a drop-down calendar |
//+------------------------------------------------------------------+
bool CDropCalendar::CreateDropCalendar(const string text,const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// ---Initializing properties
   InitializeProperties(text,x_gap,y_gap);
// ---Creating an element
   if(!CreateDateBox())
      return(false);
   if(!CreateDropButton())
      return(false);
   if(!CreateCalendar())
      return(false);
// --- Hide calendar
   m_calendar.Hide();
// --- Display the selected date in the calendar
   m_date_box.SetValue(::TimeToString((datetime)m_calendar.SelectedDate(),TIME_DATE));
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CDropCalendar::InitializeProperties(const string text,const int x_gap,const int y_gap)
  {
   m_x           =CElement::CalculateX(x_gap);
   m_y           =CElement::CalculateY(y_gap);
   m_label_text  =text;
// ---Default colors
   m_back_color  =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
   m_label_color =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_x_gap =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 0;
   m_label_y_gap =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 4;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
// ---Priority is the same as the main element, since the element does not have its own clickable area
   CElement::Z_Order(m_main.Z_Order());
  }
//+------------------------------------------------------------------+
// | Creates a date input field |
//+------------------------------------------------------------------+
bool CDropCalendar::CreateDateBox(void)
  {
// --- Save a pointer to the parent element
   m_date_box.MainPointer(this);
// --- Properties
   m_date_box.Index(0);
   m_date_box.NamePart("drop_calendar");
   m_date_box.XSize(m_x_size);
   m_date_box.YSize(m_y_size);
   m_date_box.LabelXGap(m_label_x_gap);
   m_date_box.LabelYGap(m_label_y_gap);
   m_date_box.Font(CElement::Font());
   m_date_box.FontSize(CElement::FontSize());
   m_date_box.GetTextBoxPointer().XSize(95);
   m_date_box.GetTextBoxPointer().TextYOffset(5);
   m_date_box.GetTextBoxPointer().ReadOnlyMode(true);
   m_date_box.GetTextBoxPointer().NamePart("date_box");
   m_date_box.GetTextBoxPointer().AnchorRightWindowSide(true);
// --- Set the object
   if(!m_date_box.CreateTextEdit(m_label_text,0,0))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_date_box);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a combo box button |
//+------------------------------------------------------------------+
bool CDropCalendar::CreateDropButton(void)
  {
// --- Save a pointer to the parent element
   m_drop_button.MainPointer(m_date_box);
// --- Dimensions
   int x_size=28;
// --- Coordinates
   int x=x_size,y=0;
// --- Indents for the image
   int icon_x_gap =(m_drop_button.IconXGap()<1)? 4 : m_drop_button.IconXGap();
   int icon_y_gap =(m_drop_button.IconYGap()<1)? 2 : m_drop_button.IconYGap();
// --- Properties
   m_drop_button.NamePart("drop_button");
   m_drop_button.TwoState(true);
   m_drop_button.XSize(x_size);
   m_drop_button.YSize(m_y_size);
   m_drop_button.IconXGap(icon_x_gap);
   m_drop_button.IconYGap(icon_y_gap);
   m_drop_button.AnchorRightWindowSide(true);
   m_drop_button.IconFile(RESOURCE_CALENDAR_DROP_OFF);
   m_drop_button.IconFileLocked(RESOURCE_CALENDAR_DROP_LOCKED);
   m_drop_button.CElement::IconFilePressed(RESOURCE_CALENDAR_DROP_ON);
   m_drop_button.CElement::IconFilePressedLocked(RESOURCE_CALENDAR_DROP_LOCKED);
// --- Let's create a control
   if(!m_drop_button.CreateButton("",x,y))
      return(false);
// ---Set priority
   m_drop_button.Z_Order(m_date_box.GetTextBoxPointer().Z_Order()+1);
// --- Add element to array
   CElement::AddToArray(m_drop_button);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a list |
//+------------------------------------------------------------------+
bool CDropCalendar::CreateCalendar(void)
  {
// --- Save the pointer to the main element
   m_calendar.MainPointer(m_date_box);
// --- Coordinates
   int x =m_date_box.GetTextBoxPointer().XGap();
   int y =m_y_size;
// --- Properties
   m_calendar.IsDropdown(true);
   m_calendar.AnchorRightWindowSide(true);
// --- Let's create a control
   if(!m_calendar.CreateCalendar(x,y))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_calendar);
   return(true);
  }
//+------------------------------------------------------------------+
// | Setting a new date in the calendar |
//+------------------------------------------------------------------+
void CDropCalendar::SelectedDate(const datetime date)
  {
// --- Set and remember the date
   m_calendar.SelectedDate(date);
// --- Display the date in the combo box input field
   m_date_box.LabelText(::TimeToString(date,TIME_DATE));
  }
//+------------------------------------------------------------------+
// | Reversing the calendar visibility state |
//+------------------------------------------------------------------+
void CDropCalendar::ChangeComboBoxCalendarState(void)
  {
// --- If the calendar is open, hide it
   if(m_calendar.IsVisible())
      {
       m_calendar.Hide();
      // --- Send a message to determine available elements
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
      }
// --- If the calendar is hidden, open it
   else
      {
       m_calendar.Show();
       m_calendar.GetComboBoxPointer().Show();
       m_calendar.GetComboBoxPointer().GetButtonPointer().Show();
      // --- Send a message to determine available elements
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
      }
  }
//+------------------------------------------------------------------+
// | Clicking the combo box button |
//+------------------------------------------------------------------+
bool CDropCalendar::OnClickButton(const string pressed_object,const int id,const int index)
  {
// --- Exit if the click was not on this element
   if(!m_drop_button.CheckElementName(pressed_object))
      return(false);
// --- Exit if values ​​do not match
   if(id!=m_drop_button.Id() || index!=m_drop_button.Index())
      return(false);
// --- Change the calendar visibility state to the opposite
   ChangeComboBoxCalendarState();
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_COMBOBOX_BUTTON,CElementBase::Id(),0,"");
   return(true);
  }
//+------------------------------------------------------------------+
// | Checking the left mouse button pressed above the button |
//+------------------------------------------------------------------+
void CDropCalendar::CheckPressedOverButton(void)
  {
// --- Exit if (1) left mouse button or (2) calendar call button is released
   if(!m_mouse.LeftButtonState() || !m_drop_button.IsPressed())
      return;
// --- If there is no focus on the element
   if(!CElementBase::MouseFocus())
     {
      // --- Quit if focus is on calendar
      if(m_calendar.MouseFocus())
         return;
      // --- Quit if the calendar month list scrollbar is in effect
      if(m_calendar.GetComboBoxPointer().GetScrollVPointer().State())
         return;
      // --- Hide calendar and reset object colors
      m_calendar.Hide();
      m_drop_button.IsPressed(false);
      m_drop_button.Update(true);
      // --- Send a message to determine available elements
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
     }
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CDropCalendar::Draw(void)
  {
// --- Draw background
   DrawBackground();
// --- Draw text
   CElement::DrawText();
  }
//+------------------------------------------------------------------+
