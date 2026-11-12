//+------------------------------------------------------------------+
//|                                                     TimeEdit.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//| Introduction at https://www.mql5.com/en/articles/2897            |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __TIMEEDIT_MQH__
#define __TIMEEDIT_MQH__
#include "..\Element.mqh"
#include "TextEdit.mqh"
//+------------------------------------------------------------------+
// | Class for creating the Time element |
//+------------------------------------------------------------------+
class CTimeEdit : public CElement
  {
   private:
    //Private properties:
     // --- Objects for creating an element
      CTextEdit         m_hours;
      CTextEdit         m_minutes;
     // ---Value reset mode
      bool              m_reset_mode;
     // --- Element mode with checkbox
      bool              m_checkbox_mode;
    //Private methods:    
      void              InitializeProperties(const string text,const int x_gap,const int y_gap);
      bool              CreateCanvas(void);
      bool              CreateSpinEdit(CTextEdit &edit_obj,const int index);
     // --- Handling clicks on an element
      bool              OnClickElement(const string clicked_object);
     // --- Draws a picture
      virtual void      DrawImage(void);  
   public:
                        CTimeEdit(void);
                     ~CTimeEdit(void);
    // --- Methods for creating an element
      bool              CreateTimeEdit(const string text,const int x_gap,const int y_gap);      
    // --- (1) Returns input field pointers, (2) returns/sets the element's accessibility state
      CTextEdit        *GetHoursEditPointer(void)        { return(::GetPointer(m_hours));     }
      CTextEdit        *GetMinutesEditPointer(void)      { return(::GetPointer(m_minutes));   }
    // --- (1) Reset mode when clicking on a text label, (2) element mode with a checkbox
      bool              ResetMode(void)                  { return(m_reset_mode);              }
      void              ResetMode(const bool mode)       { m_reset_mode=mode;                 }
      void              CheckBoxMode(const bool state)   { m_checkbox_mode=state;             }
    // --- Returning and setting input field values
      int               GetHours(void)                   { return((int)m_hours.GetValue());   }
      int               GetMinutes(void)                 { return((int)m_minutes.GetValue()); }
      void              SetHours(const uint value)       { m_hours.SetValue((string)value);   }
      void              SetMinutes(const uint value)     { m_minutes.SetValue((string)value); }
    // --- Element state (pressed/released)
      bool              IsPressed(void) const { return(m_is_pressed); }
      void              IsPressed(const bool state);      
    // ---Graph event handler
      virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    // --- Lock
      virtual void      IsLocked(const bool state);
    // --- Draws an element
      virtual void      Draw(void);      
  };
 #ifndef CTIMEEDIT_MQH_IMPLEMENTATION
 #define CTIMEEDIT_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CTimeEdit::CTimeEdit(void) : m_reset_mode(false)

     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CTimeEdit::~CTimeEdit(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Event Handling |
   //+------------------------------------------------------------------+
   void CTimeEdit::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
   // --- Handling the cursor movement event
      if(id==CHARTEVENT_MOUSE_MOVE)
        {
         // --- Redraw element
         if(CheckCrossingBorder())
            Update(true);
         //---
         return;
        }
   // --- Handling the event of pressing the left mouse button on an element
      if(id==CHARTEVENT_OBJECT_CLICK)
        {
         if(OnClickElement(sparam))
            return;
         //---
         return;
        }
     }
   //+------------------------------------------------------------------+
   // | Creates a Time control |
   //+------------------------------------------------------------------+
   bool CTimeEdit::CreateTimeEdit(const string text,const int x_gap,const int y_gap)
     {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
   // --- Initializing properties
      InitializeProperties(text,x_gap,y_gap);
   // ---Creating an element
      if(!CreateCanvas())
         return(false);
      if(!CreateSpinEdit(m_minutes,0))
         return(false);
      if(!CreateSpinEdit(m_hours,1))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Initializing properties |
   //+------------------------------------------------------------------+
   void CTimeEdit::InitializeProperties(const string text,const int x_gap,const int y_gap)
     {
      m_x          =CElement::CalculateX(x_gap);
      m_y          =CElement::CalculateY(y_gap);
      m_x_size     =(m_x_size<1)? 100 : m_x_size;
      m_y_size     =(m_y_size<1)? 20 : m_y_size;
      m_label_text =text;
   // ---Default background color
      m_back_color =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
      m_icon_y_gap =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 4;
   // --- Indentation and color of text label
      m_label_x_gap         =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 0;
      m_label_y_gap         =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 3;
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
   bool CTimeEdit::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("time_edit");
   // --- If you need an element with a checkbox
      if(m_checkbox_mode)
        {
         IconFile(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_BMP);
         IconFileLocked(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_LOCKED_BMP);
         IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_BMP);
         IconFilePressedLocked(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_LOCKED_BMP);
        }
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Creates input fields for hours and minutes |
   //+------------------------------------------------------------------+
   bool CTimeEdit::CreateSpinEdit(CTextEdit &edit_obj,const int index)
     {
   // --- Save the pointer to the main element
      edit_obj.MainPointer(this);
   // ---Coordinates
      int x=0,y=0;
   // --- Dimensions
      int x_size=40;
   // --- Input field for minutes
      if(index==0)
        {
         x=x_size;
         // ---Maximum value
         edit_obj.MaxValue(59);
         // --- Element index
         edit_obj.Index(0);
        }
   // --- Input field for hours
      else
        {
         x=x_size*2;
         // ---Maximum value
         edit_obj.MaxValue(23);
         // --- Element index
         edit_obj.Index(1);
        }
   // --- Set the properties before creating
      edit_obj.XSize(x_size);
      edit_obj.YSize(m_y_size);
      edit_obj.MinValue(0);
      edit_obj.StepValue(1);
      edit_obj.SpinEditMode(true);
      edit_obj.AnchorRightWindowSide(true);
      edit_obj.GetTextBoxPointer().XGap(1);
      edit_obj.GetTextBoxPointer().XSize(x_size-1);
      edit_obj.IsDropdown(CElementBase::IsDropdown());
   // --- Let's create a control
      if(!edit_obj.CreateTextEdit("",x,y))
         return(false);
   // --- Add element to array
      CElement::AddToArray(edit_obj);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Show element |
   //+------------------------------------------------------------------+
   void CTimeEdit::IsLocked(const bool state)
     {
      CElement::IsLocked(state);
   // --- Set the corresponding picture
      CElement::ChangeImage(0,(m_is_locked)? !m_is_pressed? 1 : 3 : !m_is_pressed? 0 : 2);
     }
   //+------------------------------------------------------------------+
   // | Setting the element state (pressed/released) |
   //+------------------------------------------------------------------+
   void CTimeEdit::IsPressed(const bool state)
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
   // | Handling clicks on an element |
   //+------------------------------------------------------------------+
   bool CTimeEdit::OnClickElement(const string clicked_object)
     {
   // --- Exit if (1) the element is blocked or (2) the object name is foreign
      if(CElementBase::IsLocked() || m_canvas.ChartObjectName()!=clicked_object)
         return(false);
   // --- If the checkbox is not used
      if(!m_checkbox_mode)
         return(true);
   // --- Switch to the opposite mode
      IsPressed(!(IsPressed()));
   // --- Draw element
      Update(true);
   // --- We will send a message about this
      ::EventChartCustom(m_chart_id,ON_CLICK_CHECKBOX,CElementBase::Id(),CElementBase::Index(),"");
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CTimeEdit::Draw(void)
     {
   // --- Draw background
      CElement::DrawBackground();
   // --- Draw a picture
      CTimeEdit::DrawImage();
   // --- Draw text
      CElement::DrawText();
     }
   //+------------------------------------------------------------------+
   // | Draws a picture |
   //+------------------------------------------------------------------+
   void CTimeEdit::DrawImage(void)
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
 #endif // CTIMEEDIT_MQH_IMPLEMENTATION
#endif // __TIMEEDIT_MQH__
