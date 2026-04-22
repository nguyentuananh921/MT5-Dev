//+------------------------------------------------------------------+
//|                                                       Slider.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __SLIDER_MQH__
#define __SLIDER_MQH__
#include "..\Element.mqh"
#include "TextEdit.mqh"
//+------------------------------------------------------------------+
// | Class for creating a slider with an input field |
//+------------------------------------------------------------------+
class CSlider : public CElement
  {
private:
   // --- Objects for creating an element
   CTextEdit         m_left_edit;
   CTextEdit         m_right_edit;
   // --- (1) Coordinate and (2) size of indicator area
   int               m_slot_y;
   int               m_slot_y_size;
   // ---Indicator colors in different states
   color             m_slot_line_dark_color;
   color             m_slot_line_light_color;
   color             m_slot_indicator_color;
   color             m_slot_indicator_color_locked;
   // --- Current slider position: (1) value, (2) XY coordinates
   double            m_thumb_x_pos_left;
   double            m_thumb_x_pos_right;
   double            m_thumb_x_left;
   double            m_thumb_x_right;
   int               m_thumb_y;
   // --- Slider Slider Dimensions
   int               m_thumb_x_size;
   int               m_thumb_y_size;
   // ---Slider Slider Colors
   color             m_thumb_color;
   color             m_thumb_color_hover;
   color             m_thumb_color_locked;
   color             m_thumb_color_pressed;
   // --- (1) Focus on the slider and (2) the moment it crosses the boundaries
   bool              m_thumb_focus_left;
   bool              m_thumb_focus_right;
   bool              m_is_crossing_left_thumb_border;
   bool              m_is_crossing_right_thumb_border;
   // --- Number of pixels in the work area
   int               m_pixels_total;
   // --- Number of steps in the range of work area values
   int               m_value_steps_total;
   // --- Step size relative to the width of the work area
   double            m_position_step;
   // ---Mouse button state (pressed/released)
   ENUM_MOUSE_STATE  m_clamping_left_thumb;
   ENUM_MOUSE_STATE  m_clamping_right_thumb;
   // --- To determine the mode of movement of the slider slider
   bool              m_slider_thumb_state;
   // --- Variables associated with slider movement
   int               m_slider_size_fixing;
   int               m_slider_point_fixing;
   // ---Double slider mode
   bool              m_dual_slider_mode;
   //---
public:
                     CSlider(void);
                    ~CSlider(void);
   // --- Methods for creating an element
   bool              CreateSlider(const string text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const string text,const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateLeftTextEdit(void);
   bool              CreateRightTextEdit(void);
   //---
public:
   // --- Returns pointers to elements
   CTextEdit        *GetLeftEditPointer(void)                   { return(::GetPointer(m_left_edit));  }
   CTextEdit        *GetRightEditPointer(void)                  { return(::GetPointer(m_right_edit)); }
   // --- Slider indicator colors in different states
   void              SlotLineDarkColor(const color clr)         { m_slot_line_dark_color=clr;         }
   void              SlotLineLightColor(const color clr)        { m_slot_line_light_color=clr;        }
   void              SlotIndicatorColor(const color clr)        { m_slot_indicator_color=clr;         }
   void              SlotIndicatorColorLocked(const color clr)  { m_slot_indicator_color_locked=clr;  }
   // ---Double slider mode
   void              DualSliderMode(const bool state)           { m_dual_slider_mode=state;           }
   bool              DualSliderMode(void)                 const { return(m_dual_slider_mode);         }
   bool              State(void)                          const { return(m_slider_thumb_state);       }
   // --- Slider Slider Dimensions
   void              ThumbXSize(const int x_size)               { m_thumb_x_size=x_size;              }
   void              ThumbYSize(const int y_size)               { m_thumb_y_size=y_size;              }
   // ---Slider Slider Colors
   void              ThumbColor(const color clr)                { m_thumb_color=clr;                  }
   void              ThumbColorHover(const color clr)           { m_thumb_color_hover=clr;            }
   void              ThumbColorLocked(const color clr)          { m_thumb_color_locked=clr;           }
   void              ThumbColorPressed(const color clr)         { m_thumb_color_pressed=clr;          }
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Processing the value entered into the input field
   bool              OnEndEditLeftThumb(const int id,const int index);
   bool              OnEndEditRightThumb(const int id,const int index);
   // --- Process of moving the slider slider
   void              OnDragLeftThumb(void);
   void              OnDragRightThumb(void);
   // ---Updating the slider position
   void              UpdateLeftThumb(const int new_x_point);
   void              UpdateRightThumb(const int new_x_point);

   // --- Checking focus above the slider
   bool              CheckLeftThumbFocus(void);
   bool              CheckRightThumbFocus(void);
   // --- Checks the state of the mouse button
   void              CheckMouseOnLeftThumb(void);
   void              CheckMouseOnRightThumb(void);
   // --- Resetting variables associated with moving the slider slider
   void              ZeroLeftThumbVariables(void);
   void              ZeroRightThumbVariables(void);
   // --- Calculation of values ​​(steps and coefficients)
   bool              CalculateCoefficients(void);
   // --- Calculate the X coordinate of the slider
   void              CalculateLeftThumbX(void);
   void              CalculateRightThumbX(void);
   // --- Changes the position of the slider relative to the current value
   void              CalculateLeftThumbPos(void);
   void              CalculateRightThumbPos(void);
   // --- Current slider color
   uint              ThumbColorCurrent(const bool thumb_focus,const ENUM_MOUSE_STATE thumb_clamping);

   // --- Draws borders for the indicator
   void              DrawSlot(void);
   // --- Draws an indicator
   void              DrawIndicator(void);
   // --- Draws the slider slider
   void              DrawLeftThumb(void);
   void              DrawRightThumb(void);
  };
 #ifndef CSLIDER_MQH_IMPLEMENTATION
 #define CSLIDER_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CSlider::CSlider(void) : m_dual_slider_mode(false),
                            m_slider_size_fixing(0),
                            m_slider_point_fixing(0),
                            m_slot_y(30),
                            m_slot_y_size(4),
                            m_slot_line_dark_color(clrSilver),
                            m_slot_line_light_color(clrWhite),
                            m_slot_indicator_color(C'85,170,255'),
                            m_slot_indicator_color_locked(clrLightGray),
                            m_thumb_x_pos_left(WRONG_VALUE),
                            m_thumb_x_pos_right(WRONG_VALUE),
                            m_thumb_x_left(0),
                            m_thumb_x_right(0),
                            m_thumb_y(0),
                            m_thumb_x_size(6),
                            m_thumb_y_size(14),
                            m_thumb_color(C'205,205,205'),
                            m_thumb_color_hover(C'166,166,166'),
                            m_thumb_color_locked(clrLightGray),
                            m_thumb_color_pressed(C'96,96,96'),
                            m_thumb_focus_left(false),
                            m_thumb_focus_right(false),
                            m_is_crossing_left_thumb_border(false),
                            m_is_crossing_right_thumb_border(false)
     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CSlider::~CSlider(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Graphics event handler |
   //+------------------------------------------------------------------+
   void CSlider::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
   // --- Handling the cursor movement event
      if(id==CHARTEVENT_MOUSE_MOVE)
        {
         // --- Let's check and remember the state of the mouse button
         CheckMouseOnRightThumb();
         // --- Change the color of the slider slider
         CheckRightThumbFocus();
         // --- If control is transferred to the slider bar, determine its position
         if(m_clamping_right_thumb==PRESSED_INSIDE)
           {
            // --- Moving the slider
            OnDragRightThumb();
            // --- Calculate the position of the slider slider in a range of values
            CalculateRightThumbPos();
            // --- Setting a new value in the input field
            m_right_edit.SetValue(::DoubleToString(m_thumb_x_pos_right,m_right_edit.GetDigits()),false);
            // --- Update element
            Update(true);
            m_right_edit.GetTextBoxPointer().Update(true);
            return;
           }
         // --- Quit if it's not a double slider
         if(!m_dual_slider_mode)
            return;
         // --- Let's check and remember the state of the mouse button
         CheckMouseOnLeftThumb();
         // --- Change the color of the slider slider
         CheckLeftThumbFocus();
         // --- If control is transferred to the slider bar, determine its position
         if(m_clamping_left_thumb==PRESSED_INSIDE)
           {
            // --- Moving the slider
            OnDragLeftThumb();
            // --- Calculate the position of the slider slider in a range of values
            CalculateLeftThumbPos();
            // --- Setting a new value in the input field
            m_left_edit.SetValue(::DoubleToString(m_thumb_x_pos_left,m_left_edit.GetDigits()),false);
            // --- Update element
            Update(true);
            m_left_edit.GetTextBoxPointer().Update(true);
            return;
           }
         return;
        }
   // --- Handling the event of changing the value in the input field
      if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
        {
         // --- Value input processing
         if(OnEndEditLeftThumb((int)lparam,(int)dparam))
            return;
         // --- Value input processing
         if(OnEndEditRightThumb((int)lparam,(int)dparam))
            return;
         //---
         return;
        }
     }
   //+------------------------------------------------------------------+
   // | Creates a slider with an input field |
   //+------------------------------------------------------------------+
   bool CSlider::CreateSlider(const string text,const int x_gap,const int y_gap)
     {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
   // --- Initializing properties
      InitializeProperties(text,x_gap,y_gap);
   // ---Creating an element
      if(!CreateCanvas())
         return(false);
      if(!CreateRightTextEdit())
         return(false);
      if(!CreateLeftTextEdit())
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Initializing properties |
   //+------------------------------------------------------------------+
   void CSlider::InitializeProperties(const string text,const int x_gap,const int y_gap)
     {
      m_x           =CElement::CalculateX(x_gap);
      m_y           =CElement::CalculateY(y_gap);
      m_label_text  =text;
      m_back_color  =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
      m_border_color=(m_border_color!=clrNONE)? m_border_color : clrBlack;
   // --- Indents from the extreme point
      CElementBase::XGap(x_gap);
      CElementBase::YGap(y_gap);
     }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CSlider::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("slider");
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Creates an input field |
   //+------------------------------------------------------------------+
   bool CSlider::CreateRightTextEdit(void)
     {
   // --- Save the pointer to the main element
      m_right_edit.MainPointer(this);
   // --- Coordinates
      int x=0,y=0;
   // --- Properties
      m_right_edit.Index(0);
      m_right_edit.YSize(20);
      m_right_edit.LabelXGap(0);
      m_right_edit.MaxValue((m_right_edit.MaxValue()==DBL_MAX)? 1000 : m_right_edit.MaxValue());
      m_right_edit.MinValue((m_right_edit.MinValue()==DBL_MIN)? -1000 : m_right_edit.MinValue());
      m_right_edit.StepValue(m_right_edit.StepValue());
      m_right_edit.SetDigits(m_right_edit.GetDigits());
   // --- Value in the input field
      int digits=m_right_edit.GetDigits();
      string value=(m_right_edit.GetValue()=="")? ::DoubleToString(0,digits) : m_right_edit.GetValue();
      m_right_edit.SetValue(value);
   // --- Size
      int xsize=m_right_edit.GetTextBoxPointer().XSize();
      m_right_edit.GetTextBoxPointer().XSize((xsize>0)? xsize : 60);
   //---
      m_right_edit.AutoXResizeMode(true);
      m_right_edit.IsDropdown(CElementBase::IsDropdown());
      m_right_edit.GetTextBoxPointer().AnchorRightWindowSide(true);
   // --- Let's create a control
      if(!m_right_edit.CreateTextEdit(m_label_text,x,y))
         return(false);
   // --- Add element to array
      CElement::AddToArray(m_right_edit);
   // --- Calculation of values ​​of auxiliary variables
      CalculateCoefficients();
   // --- Calculate the X coordinate of the slider relative to the current value in the input field
      CalculateRightThumbX();
   // --- Calculation of the Y coordinate of the slider
      m_thumb_y=m_slot_y-((m_thumb_y_size-m_slot_y_size)/2);
   // --- Calculate the position of the slider slider in a range of values
      CalculateRightThumbPos();
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Creates an input field |
   //+------------------------------------------------------------------+
   bool CSlider::CreateLeftTextEdit(void)
     {
      if(!m_dual_slider_mode)
         return(true);
   // --- Save the pointer to the parent
      m_left_edit.MainPointer(this);
   // --- Dimensions
      int x_size=m_right_edit.GetTextBoxPointer().XSize();
   // ---Coordinates
      int x=x_size*2+2;
      int y=0;
   // --- Properties
      m_left_edit.Index(1);
      m_left_edit.XSize(x_size+1);
      m_left_edit.YSize(20);
      m_left_edit.LabelXGap(0);
      m_left_edit.MaxValue(m_right_edit.MaxValue());
      m_left_edit.MinValue(m_right_edit.MinValue());
      m_left_edit.StepValue(m_right_edit.StepValue());
      m_left_edit.SetDigits(m_right_edit.GetDigits());
   // ---Value in the input field
      int digits=m_right_edit.GetDigits();
      string value=(m_left_edit.GetValue()=="")? ::DoubleToString(0,digits) : m_left_edit.GetValue();
      m_left_edit.SetValue((string)value);
      m_left_edit.AnchorRightWindowSide(true);
      m_left_edit.IsDropdown(CElementBase::IsDropdown());
      m_left_edit.GetTextBoxPointer().XSize(x_size);
      m_left_edit.GetTextBoxPointer().AnchorRightWindowSide(true);
   // --- Let's create a control
      if(!m_left_edit.CreateTextEdit("",x,y))
         return(false);
   // --- Add element to array
      CElement::AddToArray(m_left_edit);
   // --- Calculate the X coordinate of the slider relative to the current value in the input field
      CalculateLeftThumbX();
   // --- Calculate the position of the slider slider in a range of values
      CalculateLeftThumbPos();
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Processing a value entered into an input field |
   //+------------------------------------------------------------------+
   bool CSlider::OnEndEditLeftThumb(const int id,const int index)
     {
   // --- Exit if identifiers and indices do not match
      if(id!=m_left_edit.Id() || index!=m_left_edit.Index())
         return(false);
   // --- Get the value you just entered
      double entered_value=::StringToDouble(m_left_edit.GetValue());
   // --- Calculate the X coordinate of the slider
      CalculateLeftThumbX();
   // ---Updating the slider position
      UpdateLeftThumb((int)m_thumb_x_left);
   // --- Calculate the position in the range of values
      CalculateLeftThumbPos();
   // --- Setting a new value in the input field
      m_left_edit.SetValue(::DoubleToString(m_thumb_x_pos_left,m_left_edit.GetDigits()));
   // --- Update element
      Update(true);
      m_left_edit.GetTextBoxPointer().Update(true);
   // --- We will send a message about this
   //::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),index,m_label_text);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Processing a value entered into an input field |
   //+------------------------------------------------------------------+
   bool CSlider::OnEndEditRightThumb(const int id,const int index)
     {
   // --- Exit if identifiers and indices do not match
      if(id!=m_right_edit.Id() || index!=m_right_edit.Index())
         return(false);
   // --- Get the value you just entered
      double entered_value=::StringToDouble(m_right_edit.GetValue());
   // --- Calculate the X coordinate of the slider
      CalculateRightThumbX();
   // ---Updating the slider position
      UpdateRightThumb((int)m_thumb_x_right);
   // --- Calculate the position in the range of values
      CalculateRightThumbPos();
   // --- Setting a new value in the input field
      m_right_edit.SetValue(::DoubleToString(m_thumb_x_pos_right,m_right_edit.GetDigits()));
   // --- Update element
      Update(true);
      m_right_edit.GetTextBoxPointer().Update(true);
   // --- We will send a message about this
   //::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),index,m_label_text);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Slider slider moving process |
   //+------------------------------------------------------------------+
   void CSlider::OnDragLeftThumb(void)
     {
      int x=m_mouse.RelativeX(m_canvas);
   // --- To define a new X coordinate
      int new_x_point=0;
   // --- If the slider slider is inactive, ...
      if(!m_slider_thumb_state)
        {
         // --- ...reset auxiliary variables for moving the slider to zero
         m_slider_point_fixing =0;
         m_slider_size_fixing  =0;
         return;
        }
   // --- If the fixation point is zero, then remember the current cursor coordinate
      if(m_slider_point_fixing==0)
         m_slider_point_fixing=x;
   // --- If the distance value from the extreme point of the slider to the current cursor coordinate is zero, calculate it
      if(m_slider_size_fixing==0)
         m_slider_size_fixing=(int)m_thumb_x_left-x;
   // --- If, while pressed, you have passed the threshold to the right
      if(x-m_slider_point_fixing>0)
        {
         // --- Calculate the X coordinate
         new_x_point=x+m_slider_size_fixing;
         // ---Updating scrollbar position
         UpdateLeftThumb(new_x_point);
         return;
        }
   // --- If, while pressed, the threshold is passed to the left
      if(x-m_slider_point_fixing<0)
        {
         // --- Calculate the X coordinate
         new_x_point=x-::fabs(m_slider_size_fixing);
         // ---Updating scrollbar position
         UpdateLeftThumb(new_x_point);
         return;
        }
     }
   //+------------------------------------------------------------------+
   // | Slider slider moving process |
   //+------------------------------------------------------------------+
   void CSlider::OnDragRightThumb(void)
     {
      int x=m_mouse.RelativeX(m_canvas);
   // --- To define a new X coordinate
      int new_x_point=0;
   // --- If the slider slider is inactive, ...
      if(!m_slider_thumb_state)
        {
         // --- ...reset auxiliary variables for moving the slider to zero
         m_slider_point_fixing =0;
         m_slider_size_fixing  =0;
         return;
        }
   // --- If the fixation point is zero, then remember the current cursor coordinate
      if(m_slider_point_fixing==0)
         m_slider_point_fixing=x;
   // --- If the distance value from the extreme point of the slider to the current cursor coordinate is zero, calculate it
      if(m_slider_size_fixing==0)
         m_slider_size_fixing=(int)m_thumb_x_right-x;
   // --- If, while pressed, you have passed the threshold to the right
      if(x-m_slider_point_fixing>0)
        {
         // --- Calculate the X coordinate
         new_x_point=x+m_slider_size_fixing;
         // ---Updating scrollbar position
         UpdateRightThumb(new_x_point);
         return;
        }
   // --- If, while pressed, the threshold is passed to the left
      if(x-m_slider_point_fixing<0)
        {
         // --- Calculate the X coordinate
         new_x_point=x-::fabs(m_slider_size_fixing);
         // ---Updating scrollbar position
         UpdateRightThumb(new_x_point);
         return;
        }
     }
   //+------------------------------------------------------------------+
   // | Updating the slider position |
   //+------------------------------------------------------------------+
   void CSlider::UpdateLeftThumb(const int new_x_point)
     {
      int x=new_x_point;
   // --- Resetting the fixation point
      m_slider_point_fixing=0;
   // --- Right border
      int right_limit=(!m_dual_slider_mode)? m_x_size-m_thumb_x_size :(int)m_thumb_x_right-m_thumb_x_size;
   // --- Check for leaving the work area
      if(x>right_limit)
         x=right_limit;
      if(x<=0)
         x=0;
   // --- Save coordinate
      m_thumb_x_left=x;
     }
   //+------------------------------------------------------------------+
   // | Updating the slider position |
   //+------------------------------------------------------------------+
   void CSlider::UpdateRightThumb(const int new_x_point)
     {
      int x=new_x_point;
   // --- Resetting the fixation point
      m_slider_point_fixing=0;
   // --- Right border
      int right_limit=m_x_size-m_thumb_x_size;
   // ---Left border
      int left_limit=(!m_dual_slider_mode)? 0 :(int)m_thumb_x_left+m_thumb_x_size;
   // --- Check for leaving the work area
      if(x>right_limit)
         x=right_limit;
      if(x<=left_limit)
         x=left_limit;
   // --- Save coordinate
      m_thumb_x_right=x;
     }
   //+------------------------------------------------------------------+
   // | Current slider color |
   //+------------------------------------------------------------------+
   uint CSlider::ThumbColorCurrent(const bool thumb_focus,const ENUM_MOUSE_STATE thumb_clamping)
     {
   // --- Define the color of the slider
      color clr=(thumb_clamping==PRESSED_INSIDE)? m_thumb_color_pressed : m_thumb_color;
   // --- If the mouse cursor is in the slider area
      if(thumb_focus)
        {
         // --- If the left mouse button is released
         if(thumb_clamping==NOT_PRESSED)
            clr=m_thumb_color_hover;
         // --- Left mouse button pressed on slider
         else if(thumb_clamping==PRESSED_INSIDE)
            clr=m_thumb_color_pressed;
        }
   // --- If the cursor is outside the slider area
      else
        {
         // --- Left mouse button released
         if(thumb_clamping==NOT_PRESSED)
            clr=(m_is_locked)? m_thumb_color_locked : m_thumb_color;
        }
   //---
      return(::ColorToARGB(clr));
     }
   //+------------------------------------------------------------------+
   // | Checking focus above the slider |
   //+------------------------------------------------------------------+
   bool CSlider::CheckLeftThumbFocus(void)
     {
   // --- Exit if invalid pointer
      if(::CheckPointer(m_mouse)==POINTER_INVALID)
         return(false);
   // --- Checking focus above the slider
      int x =m_mouse.RelativeX(m_canvas);
      int y =m_mouse.RelativeY(m_canvas);
   // --- Focus check
      m_thumb_focus_left=(x>m_thumb_x_left && x<m_thumb_x_left+m_thumb_x_size && 
                          y>m_thumb_y && y<m_thumb_y+m_thumb_y_size);
   // --- If this is the moment of crossing the boundaries of the element
      if((m_thumb_focus_left && !m_is_crossing_left_thumb_border) || 
         (!m_thumb_focus_left && m_is_crossing_left_thumb_border))
        {
         m_is_crossing_left_thumb_border=m_thumb_focus_left;
         // --- Draw a filled rectangle
         DrawLeftThumb();
         m_canvas.Update();
         return(true);
        }
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Checking focus above the slider |
   //+------------------------------------------------------------------+
   bool CSlider::CheckRightThumbFocus(void)
     {
   // --- Exit if invalid pointer
      if(::CheckPointer(m_mouse)==POINTER_INVALID)
         return(false);
   // --- Checking focus above the slider
      int x =m_mouse.RelativeX(m_canvas);
      int y =m_mouse.RelativeY(m_canvas);
   // --- Focus check
      m_thumb_focus_right=(x>m_thumb_x_right && x<m_thumb_x_right+m_thumb_x_size && 
                           y>m_thumb_y && y<m_thumb_y+m_thumb_y_size);
   // --- If this is the moment of crossing the boundaries of the element
      if((m_thumb_focus_right && !m_is_crossing_right_thumb_border) || 
         (!m_thumb_focus_right && m_is_crossing_right_thumb_border))
        {
         m_is_crossing_right_thumb_border=m_thumb_focus_right;
         // --- Draw a filled rectangle
         DrawRightThumb();
         m_canvas.Update();
         return(true);
        }
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Checks the state of the mouse button |
   //+------------------------------------------------------------------+
   void CSlider::CheckMouseOnLeftThumb(void)
     {
   // --- Quit if it's not a double slider
      if(!m_dual_slider_mode)
         return;
   // --- If the left mouse button is released
      if(!m_mouse.LeftButtonState())
        {
         // --- Let's reset the variables
         ZeroLeftThumbVariables();
         return;
        }
   // ---If the left mouse button is pressed
      else
        {
         // --- Exit if the button is already pressed in any area
         if(m_clamping_left_thumb!=NOT_PRESSED)
            return;
         // --- Outside the slider area
         if(!m_thumb_focus_left)
            m_clamping_left_thumb=PRESSED_OUTSIDE;
         // --- In the slider area
         else
           {
            m_slider_thumb_state  =true;
            m_clamping_left_thumb =PRESSED_INSIDE;
            // --- Redraw the slider
            DrawLeftThumb();
            m_canvas.Update();
            // --- Send a message to determine available elements
            ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
            // --- Send a message about the change in the graphical interface
            ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
           }
        }
     }
   //+------------------------------------------------------------------+
   // | Checks the state of the mouse button |
   //+------------------------------------------------------------------+
   void CSlider::CheckMouseOnRightThumb(void)
     {
   // --- If the left mouse button is released
      if(!m_mouse.LeftButtonState())
        {
         // --- Let's reset the variables
         ZeroRightThumbVariables();
         return;
        }
   // ---If the left mouse button is pressed
      else
        {
         // --- Exit if the button is already pressed in any area
         if(m_clamping_right_thumb!=NOT_PRESSED)
            return;
         // --- Outside the slider area
         if(!m_thumb_focus_right)
            m_clamping_right_thumb=PRESSED_OUTSIDE;
         // --- In the slider area
         else
           {
            m_slider_thumb_state=true;
            m_clamping_right_thumb=PRESSED_INSIDE;
            // --- Redraw the slider
            DrawRightThumb();
            m_canvas.Update();
            // --- Send a message to determine available elements
            ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
            // --- Send a message about the change in the graphical interface
            ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
           }
        }
     }
   //+------------------------------------------------------------------+
   // | Resetting variables associated with moving the slider slider |
   //+------------------------------------------------------------------+
   void CSlider::ZeroLeftThumbVariables(void)
     {
   // --- Quit if it's not a double slider
      if(!m_dual_slider_mode)
         return;
   // --- If you came here, it means that the left mouse button is released.
   // If you previously held down the left mouse button over the slider...
      if(m_clamping_left_thumb==PRESSED_INSIDE)
        {
         // --- ... send a message that changing the value in the input field using the slider is completed
         ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),"");
         // --- Send a message to determine available elements
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
   // --- Reset variables
      if(m_clamping_left_thumb!=NOT_PRESSED)
        {
         m_slider_thumb_state  =false;
         m_slider_size_fixing  =0;
         m_clamping_left_thumb =NOT_PRESSED;
         // --- Redraw the slider
         DrawLeftThumb();
         m_canvas.Update();
        }
     }
   //+------------------------------------------------------------------+
   // | Resetting variables associated with moving the slider slider |
   //+------------------------------------------------------------------+
   void CSlider::ZeroRightThumbVariables(void)
     {
   // --- If you came here, it means that the left mouse button is released.
   // If you previously held down the left mouse button over the slider...
      if(m_clamping_right_thumb==PRESSED_INSIDE)
        {
         // --- ... send a message that changing the value in the input field using the slider is completed
         ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),"");
         // --- Send a message to determine available elements
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
   // --- Reset variables
      if(m_clamping_right_thumb!=NOT_PRESSED)
        {
         m_slider_thumb_state   =false;
         m_slider_size_fixing   =0;
         m_clamping_right_thumb =NOT_PRESSED;
         // --- Redraw the slider
         DrawRightThumb();
         m_canvas.Update();
        }
     }
   //+------------------------------------------------------------------+
   // | Calculation of values ​​(steps and coefficients) |
   //+------------------------------------------------------------------+
   bool CSlider::CalculateCoefficients(void)
     {
   // --- Quit if the element's width is less than the slider's width
      if(CElementBase::XSize()<m_thumb_x_size)
         return(false);
   // --- Number of pixels in the work area
      m_pixels_total=CElementBase::XSize()-m_thumb_x_size;
   // --- Number of steps in the range of work area values
      m_value_steps_total=int((m_right_edit.MaxValue()-m_right_edit.MinValue())/m_right_edit.StepValue());
   // --- Step size relative to the width of the work area
      m_position_step=m_right_edit.StepValue()*(double(m_value_steps_total)/double(m_pixels_total));
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Calculation of the X coordinate of the slider |
   //+------------------------------------------------------------------+
   void CSlider::CalculateLeftThumbX(void)
     {
   // --- Adjustment to take into account that the minimum value may be negative
      double neg_range=(m_left_edit.MinValue()<0)? ::fabs(m_left_edit.MinValue()/m_position_step) : 0;
   // --- Calculate the X coordinate for the slider
      m_thumb_x_left=((double)m_left_edit.GetValue()/m_position_step)+neg_range;
   // --- If we go beyond the working area to the left
      if(m_thumb_x_left<0)
         m_thumb_x_left=0;
   // --- If we go beyond the working area to the right
      if(m_thumb_x_left+m_thumb_x_size>m_thumb_x_right)
         m_thumb_x_left=m_thumb_x_right-m_thumb_x_size;
     }
   //+------------------------------------------------------------------+
   // | Calculation of the X coordinate of the slider |
   //+------------------------------------------------------------------+
   void CSlider::CalculateRightThumbX(void)
     {
   // --- Adjustment to take into account that the minimum value may be negative
      double neg_range=(m_right_edit.MinValue()<0)? ::fabs(m_right_edit.MinValue()/m_position_step) : 0;
   // --- Calculate the X coordinate for the slider
      m_thumb_x_right=((double)m_right_edit.GetValue()/m_position_step)+neg_range;
   // --- If we go beyond the working area to the left
      if(m_thumb_x_right<0)
         m_thumb_x_right=0;
   // --- If we go beyond the working area to the right
      if(m_thumb_x_right+m_thumb_x_size>m_x_size)
         m_thumb_x_right=m_x_size-m_thumb_x_size;
     }
   //+------------------------------------------------------------------+
   // | Calculating the position of a slider slider in a range of values ​​|
   //+------------------------------------------------------------------+
   void CSlider::CalculateLeftThumbPos(void)
     {
   // --- Get the position number of the slider slider
      m_thumb_x_pos_left=m_thumb_x_left*m_position_step;
   // --- Adjustment to take into account that the minimum value may be negative
      if(m_left_edit.MinValue()<0 && m_thumb_x_left!=WRONG_VALUE)
         m_thumb_x_pos_left+=int(m_left_edit.MinValue());
   // --- Check for leaving the work area to the left
      if(m_thumb_x_left<=0)
         m_thumb_x_pos_left=int(m_left_edit.MinValue());
     }
   //+------------------------------------------------------------------+
   // | Calculating the position of a slider slider in a range of values ​​|
   //+------------------------------------------------------------------+
   void CSlider::CalculateRightThumbPos(void)
     {
   // --- Get the position number of the slider slider
      m_thumb_x_pos_right=m_thumb_x_right*m_position_step;
   // --- Adjustment to take into account that the minimum value may be negative
      if(m_right_edit.MinValue()<0 && m_thumb_x_right!=WRONG_VALUE)
         m_thumb_x_pos_right+=int(m_right_edit.MinValue());
   // --- Check for leaving the work area to the right/left
      if(m_thumb_x_right+m_thumb_x_size>m_x_size)
         m_thumb_x_pos_right=int(m_right_edit.MaxValue());
      if(m_thumb_x_right<=0)
         m_thumb_x_pos_right=int(m_right_edit.MinValue());
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CSlider::Draw(void)
     {
   // --- Draw background
      CElement::DrawBackground();
   // --- Draw indicator boundaries
      DrawSlot();
   // ---Draw indicator
      DrawIndicator();
   // --- Draw a slider slider
      DrawLeftThumb();
   // --- Draw a slider slider
      DrawRightThumb();
     }
   //+------------------------------------------------------------------+
   // | Draws borders for the indicator |
   //+------------------------------------------------------------------+
   void CSlider::DrawSlot(void)
     {
   // ---Upper limit
      int x1=0,x2=m_x_size;
      int y1=m_slot_y,y2=y1;
      m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(m_slot_line_dark_color));
   // --- Lower limit
      y1+=m_slot_y_size; y2=y1;
      m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(m_slot_line_light_color));
     }
   //+------------------------------------------------------------------+
   // | Draws an indicator |
   //+------------------------------------------------------------------+
   void CSlider::DrawIndicator(void)
     {
   // ---Coordinates
      int x1 =(int)m_thumb_x_left;
      int x2 =(int)m_thumb_x_right;
      int y1 =m_slot_y+1;
      int y2 =m_slot_y+m_slot_y_size-1;
   // --- Color
      color clr=(m_is_locked)? m_slot_indicator_color_locked : m_slot_indicator_color;
   // --- Drawing an indicator
      m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(clr));
     }
   //+------------------------------------------------------------------+
   // | Draws the slider slider |
   //+------------------------------------------------------------------+
   void CSlider::DrawLeftThumb(void)
     {
   // --- Quit if it's not a double slider
      if(!m_dual_slider_mode)
         return;
   // ---Coordinates
      int x1 =(int)m_thumb_x_left;
      int x2 =(int)m_thumb_x_left+m_thumb_x_size;
      int y1 =m_thumb_y;
      int y2 =y1+m_thumb_y_size;
   // --- Drawing the slider
      m_canvas.FillRectangle(x1,y1,x2,y2,ThumbColorCurrent(m_thumb_focus_left,m_clamping_left_thumb));
     }
   //+------------------------------------------------------------------+
   // | Draws the slider slider |
   //+------------------------------------------------------------------+
   void CSlider::DrawRightThumb(void)
     {
   // --- Coordinates
      int x1 =(int)m_thumb_x_right;
      int x2 =(int)m_thumb_x_right+m_thumb_x_size;
      int y1 =m_thumb_y;
      int y2 =y1+m_thumb_y_size;
   // --- Drawing the slider
      m_canvas.FillRectangle(x1,y1,x2,y2,ThumbColorCurrent(m_thumb_focus_right,m_clamping_right_thumb));
     }
   //+------------------------------------------------------------------+
 #endif // CSLIDER_MQH_IMPLEMENTATION
#endif // __SLIDER_MQH__
