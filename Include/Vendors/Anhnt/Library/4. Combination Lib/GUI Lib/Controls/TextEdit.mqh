//+------------------------------------------------------------------+
//|                                                     TextEdit.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//| Introduction at https://www.mql5.com/en/articles/2829            |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __TEXTEDIT_MQH__
#define __TEXTEDIT_MQH__
#include "..\Element.mqh"
#include "TextBox.mqh"
class CCalendar;
//+------------------------------------------------------------------+
// | Class for creating a text input field |
//+------------------------------------------------------------------+
class CTextEdit : public CElement
  {
   private:
    //Private properties:  
     // --- Objects for creating an input field
      CTextBox          m_edit;
      CButton           m_button_inc;
      CButton           m_button_dec;
     // --- Element mode with checkbox
      bool              m_checkbox_mode;
     // --- Numeric input field mode with buttons
      bool              m_spin_edit_mode;
     // --- Current value in the input field
      string            m_edit_value;
     // --- Reset mode (empty line)
      bool              m_reset_mode;
     // ---Min/max value
      double            m_min_value;
      double            m_max_value;
     // --- Step to change the value in the input field
      double            m_step_value;
     // --- Timer counter for list rewind
      int               m_timer_counter;
     // --- Number of decimal places
      int               m_digits;
    //Private methods:    
      void              InitializeProperties(const string text,const int x_gap,const int y_gap);
      bool              CreateCanvas(void);
      bool              CreateEdit(void);
      bool              CreateSpinButton(CButton &button_obj,const int index);   
     // --- Handling clicks on an element
      bool              OnClickElement(const string clicked_object);
     // --- Processing the end of value entry
      bool              OnEndEdit(const uint id);
     // --- Handling input field button clicks
      bool              OnClickButtonInc(const string pressed_object,const uint id,const uint index);
      bool              OnClickButtonDec(const string pressed_object,const uint id,const uint index);
     // --- Fast forward values ​​in the input field
      void              FastSwitching(void);
     // --- Value adjustment
      string            AdjustmentValue(const double value);
     // --- Limit highlighting
      void              HighlightLimit(void);
     // --- Draws a picture
      virtual void      DrawImage(void);
     // --- Change the width along the right edge of the window
      virtual void      ChangeWidthByRightWindowSide(void);      
   public:
                        CTextEdit(void);
                     ~CTextEdit(void);
     // --- Methods for creating a text input field
      bool              CreateTextEdit(const string text,const int x_gap,const int y_gap);      
     // --- Returns pointers to constituent elements
      CTextBox         *GetTextBoxPointer(void)                 { return(::GetPointer(m_edit));       }
      CButton          *GetIncButtonPointer(void)               { return(::GetPointer(m_button_inc)); }
      CButton          *GetDecButtonPointer(void)               { return(::GetPointer(m_button_dec)); }
     // --- Reset mode when clicking on the text label
      bool              ResetMode(void)                   const { return(m_reset_mode);               }
      void              ResetMode(const bool mode)              { m_reset_mode=mode;                  }
     // --- (1) Checkbox and (2) numeric input field modes
      void              CheckBoxMode(const bool state)          { m_checkbox_mode=state;              }
      bool              SpinEditMode(void)                const { return(m_spin_edit_mode);           }
      void              SpinEditMode(const bool state)          { m_spin_edit_mode=state;             }
     // --- Minimum value
      double            MinValue(void)                    const { return(m_min_value);                }
      void              MinValue(const double value)            { m_min_value=value;                  }
     // ---Maximum value
      double            MaxValue(void)                    const { return(m_max_value);                }
      void              MaxValue(const double value)            { m_max_value=value;                  }
     // --- (1) Value step, (2) setting the number of decimal places
      double            StepValue(void)                   const { return(m_step_value);               }
      void              StepValue(const double value)           { m_step_value=(value<=0)? 1 : value; }
      int               GetDigits(void)                   const { return(m_digits);                   }
      void              SetDigits(const int digits)             { m_digits=::fabs(digits);            }
     // --- Element state (pressed/released)
      bool              IsPressed(void) const { return(m_is_pressed); }
      void              IsPressed(const bool state);
     // --- Return and set the value of an input field
      string            GetValue(void) { return(m_edit.GetValue(0)); }
      void              SetValue(const string value,const bool is_size_adjustment=true);      
     // ---Graph event handler
      virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     // --- Timer
      virtual void      OnEventTimer(void);
     // --- Lock
      virtual void      IsLocked(const bool state);
     // --- Draws an element
      virtual void      Draw(void);      
  };
 #ifndef CTEXTEDIT_MQH_IMPLEMENTATION
 #define CTEXTEDIT_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CTextEdit::CTextEdit(void) : m_edit_value(""),
                                m_digits(0),
                                m_min_value(DBL_MIN),
                                m_max_value(DBL_MAX),
                                m_step_value(1),
                                m_reset_mode(false),
                                m_checkbox_mode(false),
                                m_spin_edit_mode(false),
                                m_timer_counter(SPIN_DELAY_MSC)

     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CTextEdit::~CTextEdit(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Event Handling |
   //+------------------------------------------------------------------+
   void CTextEdit::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
   // --- Handling the cursor movement event
      if(id==CHARTEVENT_MOUSE_MOVE)
        {
         // --- Checking focus on elements
         m_edit.MouseFocus(m_mouse.X()>m_edit.X() && m_mouse.X()<m_edit.X2() && 
                           m_mouse.Y()>m_edit.Y() && m_mouse.Y()<m_edit.Y2());
         // --- Redraw element
         if(CheckCrossingBorder())
            Update(true);
         //---
         return;
        }
   // --- Handling the event of pressing the left mouse button on an object
      if(id==CHARTEVENT_OBJECT_CLICK)
        {
         // --- Handling clicks on an element
         if(OnClickElement(sparam))
            return;
         //---
         return;
        }
   // --- Processing the entry of a new value
      if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
        {
         // --- Handling clicks on an element
         if(OnEndEdit((uint)lparam))
            return;
         //---
         return;
        }
   // --- Exit if numeric input field mode is disabled
      if(!m_spin_edit_mode)
         return;
   // --- Handling the event of pressing the left mouse button on an object
      if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
        {
         // --- Handling clicks on the increment button
         if(OnClickButtonInc(sparam,(uint)lparam,(uint)dparam))
            return;
         // --- Handling clicks on the decrement button
         if(OnClickButtonDec(sparam,(uint)lparam,(uint)dparam))
            return;
         //---
         return;
        }
     }
   //+------------------------------------------------------------------+
   // | Timer |
   //+------------------------------------------------------------------+
   void CTextEdit::OnEventTimer(void)
     {
   // --- Fast forward values
      FastSwitching();
     }
   //+------------------------------------------------------------------+
   // | Creates a group of text input field objects |
   //+------------------------------------------------------------------+
   bool CTextEdit::CreateTextEdit(const string text,const int x_gap,const int y_gap)
     {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
   // --- Initializing properties
      InitializeProperties(text,x_gap,y_gap);
   // ---Creating an element
      if(!CreateCanvas())
         return(false);
      if(!CreateEdit())
         return(false);
      if(!CreateSpinButton(m_button_inc,0))
         return(false);
      if(!CreateSpinButton(m_button_dec,1))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Initializing properties |
   //+------------------------------------------------------------------+
   void CTextEdit::InitializeProperties(const string text,const int x_gap,const int y_gap)
     {
      m_x          =CElement::CalculateX(x_gap);
      m_y          =CElement::CalculateY(y_gap);
      m_x_size     =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
      m_y_size     =(m_y_size<1)? 20 : m_y_size;
      m_label_text =text;
   // ---Default properties
      m_back_color          =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
      m_icon_y_gap          =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 4;
      m_label_x_gap         =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : (m_checkbox_mode)? 18 : 0;
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
   bool CTextEdit::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("text_edit");
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Creates an input field |
   //+------------------------------------------------------------------+
   bool CTextEdit::CreateEdit(void)
     {
   // --- Save main element pointer
      m_edit.MainPointer(this);
   // --- Dimensions
      int x_size=(m_edit.XSize()<1)? 80 : m_edit.XSize();
   // --- Coordinates
      int x =(m_edit.XGap()<1)? x_size : m_edit.XGap();
      int y =0;
   // --- If you need an element with a checkbox
      if(m_checkbox_mode)
        {
         /*IconFile(RESOURCE_CHECKBOX_OFF);
         IconFileLocked(RESOURCE_CHECKBOX_OFF_LOCKED);
         IconFilePressed(RESOURCE_CHECKBOX_ON);
         IconFilePressedLocked(RESOURCE_CHECKBOX_ON_LOCKED);*/
         
         IconFile(IMAGE_RESOURCE_CONTROLS_CHECKBOX_OFF_BMP);
         IconFileLocked(IMAGE_RESOURCE_CONTROLS_CHECKBOX_OFF_LOCKED_BMP);
         IconFilePressed(IMAGE_RESOURCE_CONTROLS_CHECKBOX_ON_BMP);
         IconFilePressedLocked(IMAGE_RESOURCE_CONTROLS_CHECKBOX_ON_LOCKED_BMP);
        }
   // --- Set the properties before creating
      if(m_index!=WRONG_VALUE)
         m_edit.Index(m_index);
   //---
      m_edit.XSize(x_size);
      m_edit.YSize(m_y_size);
      m_edit.TextYOffset(5);
      m_edit.Font(CElement::Font());
      m_edit.FontSize(CElement::FontSize());
      m_edit.IsDropdown(CElementBase::IsDropdown());
   // --- Set the object
      if(!m_edit.CreateTextBox(x,y))
         return(false);
   // --- Add element to array
      CElement::AddToArray(m_edit);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Creates up and down input field buttons |
   //+------------------------------------------------------------------+
   bool CTextEdit::CreateSpinButton(CButton &button_obj,const int index)
     {
   // --- Save the pointer to the main element
      button_obj.MainPointer(m_edit);
   // --- Exit if numeric input field mode is disabled
      if(!m_spin_edit_mode)
         return(true);
   // --- Dimensions
      int x_size=15,y_size=0;
   // --- Coordinates
      int x=x_size+1,y=0;
   // --- Files
      string file="",file_locked="",file_pressed="";
   // --- Up button
      if(index==0)
        {
         y      =1;
         y_size =m_edit.YSize()/2;
         //--- 
         file         =(string)IMAGE_RESOURCE_CONTROLS_SPIN_INC_BMP;
         file_locked  =(string)IMAGE_RESOURCE_CONTROLS_SPIN_INC_BMP;
         file_pressed =(string)IMAGE_RESOURCE_CONTROLS_SPIN_INC_BMP;
         //---
         button_obj.NamePart(button_obj.NamePart()==""? "spin_inc" : button_obj.NamePart());
         button_obj.AnchorRightWindowSide(true);
         // --- Element index
         button_obj.Index((m_index!=WRONG_VALUE)? m_index*2 : 0);
        }
   // --- Down button
      else
        {
         y      =m_button_inc.YGap()+m_button_inc.YSize()-1;
         y_size =m_edit.Y2()-m_button_inc.Y2();
         //---
         file         =(string)IMAGE_RESOURCE_CONTROLS_SPIN_DEC_BMP;
         file_locked  =(string)IMAGE_RESOURCE_CONTROLS_SPIN_DEC_BMP;
         file_pressed =(string)IMAGE_RESOURCE_CONTROLS_SPIN_DEC_BMP;
         //---
         button_obj.NamePart(button_obj.NamePart()==""? "spin_dec" : button_obj.NamePart());
         button_obj.AnchorRightWindowSide(true);
         button_obj.AnchorBottomWindowSide(true);
         // --- Element index
         button_obj.Index((m_index!=WRONG_VALUE)? m_button_inc.Index()+1 : 1);
        }
   //--- 
      color back_color         =(button_obj.BackColor()!=clrNONE)? button_obj.BackColor() : m_edit.BackColor();
      color back_color_hover   =(button_obj.BackColorHover()!=clrNONE)? button_obj.BackColorHover() : C'225,225,225';
      color back_color_pressed =(button_obj.BackColorPressed()!=clrNONE)? button_obj.BackColorPressed() : clrLightGray;
   // --- Set the properties before creating
      button_obj.XSize(x_size);
      button_obj.YSize(y_size);
      button_obj.IconXGap(5);
      button_obj.IconYGap(3);
      button_obj.BackColor(back_color);
      button_obj.BackColorHover(back_color_hover);
      button_obj.BackColorLocked(clrLightGray);
      button_obj.BackColorPressed(back_color_pressed);
      button_obj.BorderColor(back_color);
      button_obj.BorderColorHover(back_color_hover);
      button_obj.BorderColorLocked(clrLightGray);
      button_obj.BorderColorPressed(back_color_pressed);
      button_obj.IconFile((uint)file);
      button_obj.IconFileLocked((uint)file_locked);
      button_obj.CElement::IconFilePressed((uint)file_pressed);
      button_obj.CElement::IconFilePressedLocked((uint)file_locked);
      button_obj.IsDropdown(CElementBase::IsDropdown());
   // --- Let's create a control
      if(!button_obj.CreateButton("",x,y))
         return(false);
   // --- Add element to array
      CElement::AddToArray(button_obj);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Setting the element state (pressed/released) |
   //+------------------------------------------------------------------+
   void CTextEdit::IsPressed(const bool state)
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
   // | Setting a value in an input field |
   //+------------------------------------------------------------------+
   void CTextEdit::SetValue(const string value,const bool is_size_adjustment=true)
     {
   // --- Clear input field
      m_edit.ClearTextBox();
   // ---Add new value
      if(!m_spin_edit_mode)
         m_edit.AddText(0,value);
      else
         m_edit.AddText(0,AdjustmentValue(::StringToDouble(value)));
   // --- Adjust the size of the input field, if specified
      if(is_size_adjustment)
        {
         m_edit.CorrectSize();
        }
     }
   //+------------------------------------------------------------------+
   // | Value adjustment |
   //+------------------------------------------------------------------+
   string CTextEdit::AdjustmentValue(const double value)
     {
   // --- For adjustments
      double corrected_value=0.0;
   // --- We will adjust it taking into account the step
      corrected_value=::MathRound(value/m_step_value)*m_step_value;
   // --- Check for minimum/maximum
      if(corrected_value<m_min_value)
         corrected_value=m_min_value;
      if(corrected_value>m_max_value)
         corrected_value=m_max_value;
   // --- If the value has been changed
      if(::StringToDouble(m_edit_value)!=corrected_value || m_edit_value=="")
         m_edit_value=::DoubleToString(corrected_value,m_digits);
   // --- Value unchanged
      return(m_edit_value);
     }
   //+------------------------------------------------------------------+
   // | Lock |
   //+------------------------------------------------------------------+
   void CTextEdit::IsLocked(const bool state)
     {
      CElement::IsLocked(state);
   // --- Set the corresponding picture
      CElement::ChangeImage(0,(m_is_locked)? !m_is_pressed? 1 : 3 : !m_is_pressed? 0 : 2);
     }
   //+------------------------------------------------------------------+
   // | Handling clicks on an element |
   //+------------------------------------------------------------------+
   bool CTextEdit::OnClickElement(const string clicked_object)
     {
   // --- Exit if (1) the element is blocked or (2) the object name is foreign
      if(CElementBase::IsLocked() || m_canvas.ChartObjectName()!=clicked_object)
         return(false);
   // --- If the value reset mode is enabled
      if(m_reset_mode)
         SetValue("");
   // --- If the checkbox is enabled
      if(m_checkbox_mode)
        {
         // --- Switch to the opposite state
         IsPressed(!(IsPressed()));
         // --- Draw element
         Update(true);
         // --- We will send a message about this
         ::EventChartCustom(m_chart_id,ON_CLICK_CHECKBOX,CElementBase::Id(),CElementBase::Index(),"");
        }
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Handling clicks on an element |
   //+------------------------------------------------------------------+
   bool CTextEdit::OnEndEdit(const uint id)
     {
   // --- Exit if IDs do not match
      if(id!=CElementBase::Id())
         return(false);
   // --- Set value
      SetValue(m_edit.GetValue());
   // --- Update input field
      m_edit.Update(true);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Clicking the increment switch |
   //+------------------------------------------------------------------+
   bool CTextEdit::OnClickButtonInc(const string pressed_object,const uint id,const uint index)
     {
   // --- Exit if the button was not pressed
      if(::StringFind(pressed_object,m_program_name+"_spin_inc")<0)
         return(false);
   // --- Exit if identifiers and indices do not match
      if(id!=CElementBase::Id() || index!=m_button_inc.Index())
         return(false);
   // --- Get a new value
      double value=::StringToDouble(m_edit.GetValue())+m_step_value;
   // --- Increase by one step and check for exceeding the limit
      SetValue(::DoubleToString(value),false);
   // --- Press the button
      m_button_inc.IsPressed(false);
   // --- Update input field
      m_edit.Update(true);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Pressing the decrement switch |
   //+------------------------------------------------------------------+
   bool CTextEdit::OnClickButtonDec(const string pressed_object,const uint id,const uint index)
     {
   // --- Exit if the button was not pressed
      if(::StringFind(pressed_object,m_program_name+"_spin_dec")<0)
         return(false);
   // --- Exit if identifiers and indices do not match
      if(id!=CElementBase::Id() || index!=m_button_dec.Index())
         return(false);
   // --- Get the current value
      double value=::StringToDouble(m_edit.GetValue())-m_step_value;
   // --- Let's reduce it by one step and check for exceeding the limit
      SetValue(::DoubleToString(value),false);
   // --- Press the button
      m_button_dec.IsPressed(false);
   // --- Update input field
      m_edit.Update(true);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Fast scrolling through values ​​in an input field |
   //+------------------------------------------------------------------+
   void CTextEdit::FastSwitching(void)
     {
   // --- Exit if (1) there is no focus on the element or (2) the element is part of the calendar
      if(!CElementBase::MouseFocus() || dynamic_cast<CCalendar*>(m_main)!=NULL)
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
         // --- Get the current value in the input field
         double current_value=::StringToDouble(m_edit.GetValue());
         // --- If you enlarge
         if(m_button_inc.MouseFocus())
           {
            SetValue(::DoubleToString(current_value+m_step_value),false);
            m_edit.Update(true);
            // --- We will send a message about this
            ::EventChartCustom(m_chart_id,ON_CLICK_INC,CElementBase::Id(),m_button_inc.Index(),"");
           }
         // --- If you reduce
         else if(m_button_dec.MouseFocus())
           {
            SetValue(::DoubleToString(current_value-m_step_value),false);
            m_edit.Update(true);
            // --- We will send a message about this
            ::EventChartCustom(m_chart_id,ON_CLICK_DEC,CElementBase::Id(),m_button_dec.Index(),"");
           }
        }
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CTextEdit::Draw(void)
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
   void CTextEdit::DrawImage(void)
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
   // | Change the width along the right edge of the form |
   //+------------------------------------------------------------------+
   void CTextEdit::ChangeWidthByRightWindowSide(void)
     {
   // --- Exit if the mode of fixing to the right edge of the form is enabled
      if(m_anchor_right_window_side)
         return;
   // ---Coordinates and dimensions
      int x=0,x_size=0;
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
 #endif // CTEXTEDIT_MQH_IMPLEMENTATION
#endif // __TEXTEDIT_MQH__
