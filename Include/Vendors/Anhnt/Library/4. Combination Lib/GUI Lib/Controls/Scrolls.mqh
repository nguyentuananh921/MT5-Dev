//+------------------------------------------------------------------+
//|                                                      Scrolls.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __SCROLLS_MQH__
#define __SCROLLS_MQH__
#include "..\Element.mqh"
#include "Button.mqh"
// --- List of classes in the file for quick transition (Alt+G)
class CScroll;
class CScrollV;
class CScrollH;
#ifndef CCSCROLL_MQH_DECLARATION
#define CCSCROLL_MQH_DECLARATION
 //+------------------------------------------------------------------+
 // | Base class for creating a scrollbar |
 //+------------------------------------------------------------------+
 class CScroll : public CElement
 {  
  protected:  
   // --- Objects for creating a scrollbar
      CButton           m_button_inc;
      CButton           m_button_dec;
   // --- Scrollbar total area properties
      int               m_area_width;
      int               m_area_length;
   // --- Pictures for buttons
      string            m_inc_file;
      string            m_inc_file_locked;
      string            m_inc_file_pressed;
      string            m_dec_file;
      string            m_dec_file_locked;
      string            m_dec_file_pressed;
   // --- (1) Focus on the slider and (2) the moment it crosses the boundaries
      bool              m_thumb_focus;
      bool              m_thumb_dragging;      // NEW: Track if thumb is currently being dragged
      bool              m_is_crossing_thumb_border;
   // --- Slider colors in different states
      color             m_thumb_color;
      color             m_thumb_color_hover;
      color             m_thumb_color_pressed;
   // --- (1) Total number of items and (2) visible
      int               m_items_total;
      int               m_visible_items_total;
   // --- Slider coordinates
      int               m_thumb_x;
      int               m_thumb_y;
   // --- (1) Slider width, (2) Slider length, and (3) Slider minimum length
      int               m_thumb_width;
      int               m_thumb_length;
      int               m_thumb_min_length;
   // --- (1) Slider step size and (2) number of steps
      double            m_thumb_step_size;
      double            m_thumb_steps_total;
   // --- Variables associated with slider movement
      bool              m_scroll_state;
      int               m_thumb_size_fixing;
      int               m_thumb_point_fixing;
   // --- Current position of the slider
      int               m_current_pos;
   // --- To determine the area where the left mouse button is pressed
      ENUM_MOUSE_STATE  m_clamping_area_mouse;
  //Protected methods:
     // --- Current slider color
      uint              ThumbColorCurrent(void);
     // --- Checking focus above the slider
      bool              CheckThumbFocus(const int x,const int y);
     // --- Defines the area where the left mouse button is pressed
      void              CheckMouseButtonState(void);
     // --- Resetting variables
      void              ZeroThumbVariables(void);
     // --- Calculate the length of the scrollbar slider
      bool              CalculateThumbSize(void);
     // --- Calculate scroll bar boundaries
      void              CalculateThumbBoundaries(int &x1,int &y1,int &x2,int &y2);   
  private:
    //Private methods:   
      void              InitializeProperties(const int x_gap,const int y_gap,
                                             const int items_total,const int visible_items_total);
      bool              CreateCanvas(void);
      bool              CreateScrollButton(CButton &button_obj,const int index);
    // --- Draws the background
      virtual void      DrawThumb(void); 
  public:
                     CScroll(void);
                    ~CScroll(void);
   // ---Methods for creating a scrollbar
      bool              CreateScroll(const int x_gap,const int y_gap,
                                  const int items_total,const int visible_items_total);
   // --- Returns pointers to the scrollbar buttons
      CButton          *GetIncButtonPointer(void)                { return(::GetPointer(m_button_inc)); }
      CButton          *GetDecButtonPointer(void)                { return(::GetPointer(m_button_dec)); }
   // ---Scrollbar width
      void              ScrollWidth(const int width)             { m_area_width=width;                 }
      int               ScrollWidth(void)                  const { return(m_area_width);               }
   // --- Setting images for buttons
      void              IncFile(const string file_path)          { m_inc_file=file_path;               }
      void              IncFileLocked(const string file_path)    { m_inc_file_locked=file_path;        }
      void              IncFilePressed(const string file_path)   { m_inc_file_pressed=file_path;       }
      void              DecFile(const string file_path)          { m_dec_file=file_path;               }
      void              DecFileLocked(const string file_path)    { m_dec_file_locked=file_path;        }
      void              DecFilePressed(const string file_path)   { m_dec_file_pressed=file_path;       }
   // --- (1) Slider colors and (2) Slider frame
      void              ThumbColor(const color clr)              { m_thumb_color=clr;                  }
      void              ThumbColorHover(const color clr)         { m_thumb_color_hover=clr;            }
      void              ThumbColorPressed(const color clr)       { m_thumb_color_pressed=clr;          }
   // --- Button status
      bool              ScrollIncState(void)               const { return(m_button_inc.IsPressed());   }
      bool              ScrollDecState(void)               const { return(m_button_dec.IsPressed());   }
   // --- Scrollbar state (free/slider moving mode)
      void              State(const bool scroll_state)           { m_scroll_state=scroll_state;        }
      bool              State(void)                        const { return(m_scroll_state);             }
   // --- Current position of the slider
      void              CurrentPos(const int pos)                { m_current_pos=pos;                  }
      int               CurrentPos(void)                   const { return(m_current_pos);              }
   // --- Initialization with new values
      void              Reinit(const int items_total,const int visible_items_total);
   // --- Changing the slider size according to new conditions
      void              ChangeThumbSize(const int items_total,const int visible_items_total);
   // --- The need to show a scroll bar
      bool              IsScroll(void) const { return(m_items_total>m_visible_items_total); };
   // --- Management
      virtual void      Show(void);
      virtual void      Hide(void);
      virtual void      Delete(void);   
      virtual void      Draw(void);  // --- Draws an element
 };
#endif // CCSCROLL_MQH_DECLARATION

#ifndef CCSCROLL_MQH_IMPLEMENTATION
#define CCSCROLL_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CScroll::CScroll(void) : m_current_pos(0),
                            m_area_width(15),
                            m_area_length(0),
                            m_inc_file(""),
                            m_inc_file_locked(""),
                            m_inc_file_pressed(""),
                            m_dec_file(""),
                            m_dec_file_locked(""),
                            m_dec_file_pressed(""),
                            m_thumb_focus(false),
                            m_is_crossing_thumb_border(false),
                            m_thumb_x(0),
                            m_thumb_y(0),
                            m_thumb_width(0),
                            m_thumb_length(0),
                            m_thumb_min_length(15),
                            m_thumb_size_fixing(0),
                            m_thumb_point_fixing(0),
                            m_thumb_color(C'205,205,205'),
                            m_thumb_color_hover(C'166,166,166'),
                            m_thumb_color_pressed(C'96,96,96')
     {
     }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CScroll::~CScroll(void)
     {
     }
  //+------------------------------------------------------------------+
  // | Creates a scroll bar |
  //+------------------------------------------------------------------+
  bool CScroll::CreateScroll(const int x_gap,const int y_gap,const int items_total,const int visible_items_total)
   {
      // --- Quit if there is no pointer to the main element
       if(!CElement::CheckMainPointer())
          return(false);
      // --- Quit if an attempt is made to use the base scrollbar class
       if(CElementBase::ClassName()=="")
        {
         ::Print(__FUNCTION__," > Используйте производные классы полосы прокрутки (CScrollV или CScrollH).");
         return(false);
        }
      // --- Initializing properties
       InitializeProperties(x_gap,y_gap,items_total,visible_items_total);
      // ---Creating an element
       if(!CreateCanvas())
         return(false);
       if(!CreateScrollButton(m_button_inc,0))
         return(false);
       if(!CreateScrollButton(m_button_dec,1))
         return(false);
      //---
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Initializing properties |
  //+------------------------------------------------------------------+
  void CScroll::InitializeProperties(const int x_gap,const int y_gap,
                                      const int items_total,const int visible_items_total)
   {
      m_x                   =CElement::CalculateX(x_gap);
      m_y                   =CElement::CalculateY(y_gap);
      m_area_width          =(CElementBase::ClassName()=="CScrollV")? CElementBase::XSize() : CElementBase::YSize();
      m_area_length         =(CElementBase::ClassName()=="CScrollV")? CElementBase::YSize() : CElementBase::XSize();
      m_items_total         =(items_total<1)? 1 : items_total;
      m_visible_items_total =(visible_items_total>0)? visible_items_total : 1;
      m_thumb_width         =m_area_width;
      m_thumb_steps_total   =(IsScroll())? m_items_total-m_visible_items_total : 1;
      m_back_color          =(m_back_color!=clrNONE)? m_back_color : C'240,240,240';
    // --- Indents from the extreme point
      CElementBase::XGap(x_gap);
      CElementBase::YGap(y_gap);
    // --- Calculate the size of the scroll bar
      CalculateThumbSize();
   }
  //+------------------------------------------------------------------+
  // | Creates an object to draw |
  //+------------------------------------------------------------------+
  bool CScroll::CreateCanvas(void)
   {
     // --- Formation of object name
      string name=CElementBase::ElementName((CElementBase::ClassName()=="CScrollV")? "scrollv" : "scrollh");
     // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
     //---
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Creates a scroll switch up or left |
  //+------------------------------------------------------------------+
  bool CScroll::CreateScrollButton(CButton &button_obj,const int index)
   {
     // --- Save the pointer to the main element
      button_obj.MainPointer(this);
     // --- Coordinates
      int x=0,y=0;
     // --- Files
      string file="",file_locked="",file_pressed="";
     // --- Up or left button
      if(index==0)
        {
         // --- Setting properties based on scroll type
         if(CElementBase::ClassName()=="CScrollV")
           {
            file=(m_inc_file=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_UP_BLACK_BMP : m_inc_file;
            file_locked=(m_inc_file_locked=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_UP_BLACK_BMP : m_inc_file_locked;
            file_pressed=(m_inc_file_pressed=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_UP_WHITE_BMP : m_inc_file_pressed;
           }
         else
           {
            file=(m_inc_file=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_LEFT_BLACK_BMP : m_inc_file;
            file_locked=(m_inc_file_locked=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_LEFT_BLACK_BMP : m_inc_file_locked;
            file_pressed=(m_inc_file_pressed=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_LEFT_WHITE_BMP : m_inc_file_pressed;
           }
         // --- Element index
         button_obj.Index(m_index*2);
        }
     // --- Down or Right button
      else
       {
        // --- Setting properties based on scroll type
         if(CElementBase::ClassName()=="CScrollV")
           {
            x=0; y=m_thumb_width;
            file=(m_dec_file=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_DOWN_BLACK_BMP : m_dec_file;
            file_locked=(m_dec_file_locked=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_DOWN_BLACK_BMP : m_dec_file_locked;
            file_pressed=(m_dec_file_pressed=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_DOWN_WHITE_BMP : m_dec_file_pressed;
            button_obj.AnchorBottomWindowSide(true);
           }
         else
           {
            x=m_thumb_width; y=0;
            file=(m_dec_file=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_BLACK_BMP : m_dec_file;
            file_locked=(m_dec_file_locked=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_BLACK_BMP : m_dec_file_locked;
            file_pressed=(m_dec_file_pressed=="")? (string)IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_WHITE_BMP : m_dec_file_pressed;
            button_obj.AnchorRightWindowSide(true);
           }
        // --- Element index
         button_obj.Index(m_index*2+1);
       }
     // --- Properties
      button_obj.NamePart("scroll_button");
      button_obj.Alpha(m_alpha);
      button_obj.XSize(15);
      button_obj.YSize(15);
      button_obj.IconXGap(0);
      button_obj.IconYGap(0);
      button_obj.TwoState(true);
      button_obj.BackColor(m_back_color);
      button_obj.BackColorHover(C'218,218,218');
      button_obj.BackColorLocked(clrLightGray);
      button_obj.BackColorPressed(m_thumb_color_pressed);
      button_obj.BorderColor(m_back_color);
      button_obj.BorderColorHover(C'218,218,218');
      button_obj.BorderColorLocked(clrLightGray);
      button_obj.BorderColorPressed(m_thumb_color_pressed);
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
  // | Current slider color |
  //+------------------------------------------------------------------+
  uint CScroll::ThumbColorCurrent(void)
   {
     // --- Define the color of the slider
      color clr=(m_scroll_state)? m_thumb_color_pressed : m_thumb_color;
     // --- If the mouse cursor is in the scroll bar area
      if(m_thumb_focus)
        {
         // --- If the left mouse button is released
         if(m_clamping_area_mouse==NOT_PRESSED)
            clr=m_thumb_color_hover;
         // --- Left mouse button pressed on slider
         else if(m_clamping_area_mouse==PRESSED_INSIDE)
            clr=m_thumb_color_pressed;
        }
     // --- If the cursor is outside the scroll bar area
      else
        {
         // --- Left mouse button released
         if(m_clamping_area_mouse==NOT_PRESSED)
            clr=m_thumb_color;
        }
     //---
      return(::ColorToARGB(clr,m_alpha));
   }
  //+------------------------------------------------------------------+
  // | Checking focus above the slider |
  //+------------------------------------------------------------------+
  bool CScroll::CheckThumbFocus(const int x,const int y)
   {
     // --- Checking focus above the slider
      if(CElementBase::ClassName()=="CScrollV")
        {
         m_thumb_focus=(x>m_thumb_x && x<m_thumb_x+m_thumb_width && 
                        y>m_thumb_y && y<m_thumb_y+m_thumb_length);
        }
      else
        {
         m_thumb_focus=(x>m_thumb_x && x<m_thumb_x+m_thumb_length && 
                        y>m_thumb_y && y<m_thumb_y+m_thumb_width);
        }
     // --- If this is the moment of crossing the boundaries of the element
      if((m_thumb_focus && !m_is_crossing_thumb_border) || (!m_thumb_focus && m_is_crossing_thumb_border))
        {
         m_is_crossing_thumb_border=m_thumb_focus;
         //---
         if(!CScroll::State())
           {
            int x1=0,y1=0,x2=0,y2=0;
            CalculateThumbBoundaries(x1,y1,x2,y2);
            // --- Draw a filled rectangle
            m_canvas.FillRectangle(x1,y1,x2-1,y2-1,ThumbColorCurrent());
            m_canvas.Update();
           }
         return(true);
        }
     //---
      return(false);
   }
  //+------------------------------------------------------------------+
  // | Defines the area where the left mouse button is pressed |
  //+------------------------------------------------------------------+
  void CScroll::CheckMouseButtonState(void)
   {
     // --- If the left mouse button is released
      if(!m_mouse.IsLeftBtn())
        {
         // --- Let's reset the variables
          ZeroThumbVariables();
          return;
        }
     // ---If the button is pressed
      else
       {
        // --- Exit if the button is already pressed in any area
        //BUT: Allow continue drag if m_thumb_dragging = true
         if(m_clamping_area_mouse!=NOT_PRESSED && !m_thumb_dragging)
            return;
        // --- Outside the scrollbar slider area
         if(!m_thumb_focus)   
          {
            // Only set PRESSED_OUTSIDE if NOT already dragging
            if(!m_thumb_dragging)         // ← NEW: Allow drag to continue outside rect
              m_clamping_area_mouse=PRESSED_OUTSIDE;
             else
              {
                // While dragging outside thumb, keep scroll state active
                  m_scroll_state = true;  // ← NEW
              }
          }            
        // --- In the scroll bar slider area
         else
          {
            m_scroll_state        =true;
            m_thumb_dragging      =true;  // ← NEW: Mark as actively dragging
            m_clamping_area_mouse =PRESSED_INSIDE;
            // --- Redraw element
            Update(true);
            // --- If the element is not a drop-down
            if(!CElementBase::IsDropdown())
              {
               // --- Send a message to determine available elements
               ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
               // --- Send a message about the change in the graphical interface
               ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
              }
          }
        }
   }
  //+------------------------------------------------------------------+
  // | Resetting variables associated with slider movement |
  //+------------------------------------------------------------------+
  void CScroll::ZeroThumbVariables(void)
   {
    // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return;
    // --- Exit if the button is already released
      if(m_clamping_area_mouse==NOT_PRESSED)
         return;
    // --- If the element is not a drop-down
      if(!CElementBase::IsDropdown() && m_clamping_area_mouse==PRESSED_INSIDE)
        {
         // --- Send a message to determine available elements
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
    // --- Reset variables
      m_scroll_state        =false;
      m_thumb_dragging = false;   // ← NEW: Reset when button released
      m_thumb_size_fixing   =0;
      m_clamping_area_mouse =NOT_PRESSED;
    // --- Redraw element
      Update(true);
   }
  //+------------------------------------------------------------------+
  // | Changing the slider size according to new conditions |
  //+------------------------------------------------------------------+
  void CScroll::ChangeThumbSize(const int items_total,const int visible_items_total)
   {
      m_items_total         =items_total;
      m_visible_items_total =visible_items_total;
     // --- Exit if the number of list elements is not greater than the number of visible parts of the list
      if(!IsScroll())
         return;
     // --- Get the number of steps for the slider
      m_thumb_steps_total=items_total-visible_items_total;
     // --- Get the scrollbar size
      if(!CalculateThumbSize())
         return;
   }
  //+------------------------------------------------------------------+
  // | Scrollbar size calculation |
  //+------------------------------------------------------------------+
  bool CScroll::CalculateThumbSize(void)
   {
    // --- Percentage difference between the total number of points and the visible one
      double percentage_difference=1-(double)(m_items_total-m_visible_items_total)/m_items_total;
    // --- Calculate the slider step size
      uint bg_length=(m_class_name=="CScrollV")? m_y_size-(m_thumb_width*2) : m_x_size-(m_thumb_width*2);
      m_thumb_step_size=(double)(bg_length-(bg_length*percentage_difference))/m_thumb_steps_total;
    // --- Calculate the size of the working area for moving the slider
      double work_area=m_thumb_step_size*m_thumb_steps_total;
    // --- If the size of the work area is less than the size of the entire area, we will get the size of the slider, otherwise we will set the minimum size
      double thumb_size=(work_area<bg_length)? bg_length-work_area+m_thumb_step_size : m_thumb_min_length;
    // --- Checking the size of the slider taking into account the type cast
      m_thumb_length=((int)thumb_size<m_thumb_min_length)? m_thumb_min_length :(int)thumb_size;
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Calculating scrollbar slider boundaries |
  //+------------------------------------------------------------------+
  void CScroll::CalculateThumbBoundaries(int &x1,int &y1,int &x2,int &y2)
   {
      if(CElementBase::ClassName()=="CScrollV")
        {
         x1 =0;
         y1 =(m_thumb_y>0) ? m_thumb_y : m_thumb_width;
         x2 =x1+m_thumb_width;
         y2 =y1+m_thumb_length;
        }
      else
        {
         x1 =(m_thumb_x>0) ? m_thumb_x : m_thumb_width;
         y1 =0;
         x2 =x1+m_thumb_length;
         y2 =y1+m_thumb_width;
        }
   }
  //+------------------------------------------------------------------+
  // | Initialization with new values ​​|
  //+------------------------------------------------------------------+
  void CScroll::Reinit(const int items_total,const int visible_items_total)
   {
      m_items_total         =(items_total>0)? items_total : 1;
      m_visible_items_total =(visible_items_total>items_total)? items_total : visible_items_total;
      m_thumb_steps_total   =m_items_total-m_visible_items_total+1;
   }
  //+------------------------------------------------------------------+
  // | Shows element |
  //+------------------------------------------------------------------+
  void CScroll::Show(void)
   {
    //Debug
   //   Print("My Debug CScroll::Show CALLED obj=", m_canvas.ChartObjectName(),
   //       " IsVisible=", CElementBase::IsVisible(),
   //       " IsScroll=", IsScroll(),
   //       " m_items_total=", m_items_total,
   //       " m_visible_items_total=", m_visible_items_total);
    // --- Exit if (1) the element is already visible or (2) it does not need to be shown
      if(CElementBase::IsVisible() || !IsScroll())
         return;
    // --- Visibility state
      CElementBase::IsVisible(true);
    // --- Update object position
      Moving();
    // --- Show objects
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
      m_button_inc.Show();
      m_button_dec.Show();
    //Fix Add Here
      Draw();
      CElement::Update(true);
      ::ObjectSetInteger(m_chart_id, m_canvas.ChartObjectName(), OBJPROP_BACK, false);
      ::ChartRedraw(m_chart_id);
    //Debug native dump
      // string sobj = m_canvas.ChartObjectName();
      // Print("My Debug CScroll::Show AFTER NATIVE obj=", sobj,
      //       " TIMEFRAMES=", ObjectGetInteger(0, sobj, OBJPROP_TIMEFRAMES),
      //       " X=", ObjectGetInteger(0, sobj, OBJPROP_XDISTANCE),
      //       " Y=", ObjectGetInteger(0, sobj, OBJPROP_YDISTANCE),
      //       " XSIZE=", ObjectGetInteger(0, sobj, OBJPROP_XSIZE),
      //       " YSIZE=", ObjectGetInteger(0, sobj, OBJPROP_YSIZE));
   }
  //+------------------------------------------------------------------+
  // | Hides the element |
  //+------------------------------------------------------------------+
  void CScroll::Hide(void)
   {
    //Debug
   //   Print("My Debug CScroll::Hide CALLED obj=", m_canvas.ChartObjectName(), " IsVisible_before=", CElementBase::IsVisible());
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
      m_button_inc.Hide();
      m_button_dec.Hide();
    // --- Visibility state
      CElementBase::IsVisible(false);
   }
  //+------------------------------------------------------------------+
  // | Removal |
  //+------------------------------------------------------------------+
  void CScroll::Delete(void)
   {
    // --- Deleting objects
      m_canvas.Destroy();
    // --- Initializing variables to default values
      m_thumb_x=0;
      m_thumb_y=0;
      CurrentPos(0);
      CElementBase::IsVisible(true);
   }
  //+------------------------------------------------------------------+
  // | Draws an element |
  //+------------------------------------------------------------------+
  void CScroll::Draw(void)
   {
    // --- Draw background
      CElement::DrawBackground();
    // ---Draw slider
      DrawThumb();
   }
  //+------------------------------------------------------------------+
  //| Draws a scroll bar slider                                         |
  //+------------------------------------------------------------------+
  void CScroll::DrawThumb(void)
   {
    // --- Coordinates
      int x1=0,y1=0,x2=0,y2=0;
    // --- Calculation of slider boundaries
      CalculateThumbBoundaries(x1,y1,x2,y2);
    // --- Save the coordinates of the slider (upper left corner)
      m_thumb_x=x1;
      m_thumb_y=y1;
    // --- Draw a filled rectangle
      m_canvas.FillRectangle(x1,y1,x2-1,y2-1,ThumbColorCurrent());
   }
#endif // CCSCROLL_MQH_IMPLEMENTATION

#ifndef CCSCROLLV_MQH_DECLARATION
#define CCSCROLLV_MQH_DECLARATION
 //+------------------------------------------------------------------+
 // | Class to control the vertical scrollbar |
 //+------------------------------------------------------------------+
 class CScrollV : public CScroll
   {
    public:
                        CScrollV(void);
                       ~CScrollV(void);
      // --- Slider control
       bool              ScrollBarControl(void);
      // --- Moves the slider to the specified position
       void              MovingThumb(const int pos=WRONG_VALUE);
      // --- Set new coordinate for scrollbar
       void              XDistance(const int x);
      // --- Change scrollbar length
       void              ChangeYSize(const int height);
      // --- Handling clicks on scrollbar buttons
       bool              OnClickScrollInc(const int id=WRONG_VALUE,const int index=WRONG_VALUE);
       bool              OnClickScrollDec(const int id=WRONG_VALUE,const int index=WRONG_VALUE);
      //---
    private:
      // --- Process of moving the slider
       bool              OnDragThumb(const int y);
      // ---Updating the slider position
       void              UpdateThumb(const int new_y_point);
      // --- Calculation of the Y coordinate of the slider
       void              CalculateThumbY(void);
      // --- Adjusts the slider position number
       void              CalculateThumbPos(void);
      // --- Quick redraw of the scroll bar slider
       void              RedrawThumb(const int y);
   };
#endif // CCSCROLLV_MQH_DECLARATION

#ifndef CCSCROLLV_MQH_IMPLEMENTATION
#define CCSCROLLV_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CScrollV::CScrollV(void)
  {
    // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CScrollV::~CScrollV(void)
  {
  }
 //+------------------------------------------------------------------+
 //| Slider control |
 //+------------------------------------------------------------------+
 bool CScrollV::ScrollBarControl(void)
  {
    // --- Exit if (1) there is no pointer to the main element or (2) the element is hidden
      if(!CElement::CheckMainPointer() || !CElementBase::IsVisible())
         return(false);
    // --- Exit if parent is disabled by another element
      if(!m_main.CElementBase::IsAvailable())
         return(false);
    // --- Checking focus above the slider
      int x =m_mouse.RelativeX(m_canvas);
      int y =m_mouse.RelativeY(m_canvas);
      CheckThumbFocus(x,y);
    // --- Let's check and remember the state of the mouse button
      CScroll::CheckMouseButtonState();
    // --- If control is transferred to the scroll bar, determine the position of the slider
      if(CScroll::State())
       {
         // --- If the slider is moved
         if(OnDragThumb(y))
           {
            // --- Changes the slider position number
            CalculateThumbPos();
            return(true);
           }
       }
   //---
      return(false);
  }
 //+------------------------------------------------------------------+
 //| Moves the slider to the specified position |
 //+------------------------------------------------------------------+
 void CScrollV::MovingThumb(const int pos=WRONG_VALUE)
  {
    // --- Exit if scrollbar is not needed
      if(!IsScroll())
         return;
    // --- To check the position of the slider
      uint check_pos=0;
    // --- We will adjust the position if it leaves the range
      if(pos<0 || pos>m_items_total-m_visible_items_total)
         check_pos=m_items_total-m_visible_items_total;
      else
         check_pos=pos;
    // --- Remember the position of the slider
      CScroll::CurrentPos(check_pos);
    // --- Calculate and set the Y coordinate of the scroll bar slider
      CalculateThumbY();
   }
 //+------------------------------------------------------------------+
 //| Calculation and setting of the Y coordinate of the scroll bar slider |
 //+------------------------------------------------------------------+
 void CScrollV::CalculateThumbY(void)
  {
    // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return;
    // --- Determine the current Y coordinate of the slider
      int scroll_thumb_y=int(m_thumb_width+(CurrentPos()*m_thumb_step_size));
    // --- If we go beyond the working area up
      if(scroll_thumb_y<=m_thumb_width)
         scroll_thumb_y=m_thumb_width;
    // --- If we go beyond the working area down
      if(scroll_thumb_y+m_thumb_length>=m_y_size-m_thumb_width || 
         CScroll::CurrentPos()>=m_thumb_steps_total-1)
       {
         scroll_thumb_y=int(m_y_size-m_thumb_width-m_thumb_length);
       }
    // --- Update the coordinate and offset along the Y axis
      m_thumb_y=scroll_thumb_y;
  }
 //+------------------------------------------------------------------+
 //| Changing the X coordinate of an element |
 //+------------------------------------------------------------------+
 void CScrollV::XDistance(const int x)
  {
    // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return;
    // --- Update the X coordinate of the element...
      CElementBase::X(CElement::CalculateX(x));
      CElementBase::XGap(x);
      m_canvas.X(x);
    // --- Set the coordinate and offset
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,x);
      m_canvas.XGap(x);
    // --- Move objects
      Moving();
  }
 //+------------------------------------------------------------------+
 //| Change scrollbar length |
 //+------------------------------------------------------------------+
 void CScrollV::ChangeYSize(const int height)
  {
    // ---Coordinates and dimensions
     int y=0,y_size=0;
    // --- Change element and background width
      CElementBase::YSize(height);
      m_canvas.YSize(height);
      m_canvas.Resize(m_x_size,height);
    // --- Adjust the position of the decrement button
      m_button_dec.Moving();
      m_button_inc.Moving();
    // --- Calculate and set the sizes of scrollbar objects
      CalculateThumbSize();
    // ---Adjusting the slider position
      if(m_thumb_y+m_thumb_length>=m_y_size-m_thumb_length || m_thumb_y<m_thumb_width)
        {
         CalculateThumbY();
         CalculateThumbPos();
        }
    // Fix Add here Repaint background + thumb onto the freshly-resized canvas, then push to chart
      Draw();
      CElement::Update(true);
  }
 //+------------------------------------------------------------------+
 //| Handling up/left button clicks |
 //+------------------------------------------------------------------+
 bool CScrollV::OnClickScrollInc(const int id=WRONG_VALUE,const int index=WRONG_VALUE)
  {
   // --- Check element identifier and index if there was an external call
      uint check_id    =(id!=WRONG_VALUE)? id : CElementBase::Id();
      uint check_index =(index!=WRONG_VALUE)? index : CElementBase::Index();
   // --- Exit if values ​​do not match
      if(check_id!=m_button_inc.Id() || check_index!=m_button_inc.Index())
         return(false);
   // --- Exit if (1) is currently active or (2) the number of steps is undefined
      if(CScroll::State() || m_thumb_steps_total<1)
         return(false);
   // --- Decrease the scroll bar position number
      if(CScroll::CurrentPos()>0)
         CScroll::m_current_pos--;
   // --- Calculate the Y coordinate of the scroll bar
      CalculateThumbY();
   // --- Press the button
      m_button_inc.IsPressed(false);
      return(true);
  }
 //+------------------------------------------------------------------+
 //| Handling down/right button clicks |
 //+------------------------------------------------------------------+
 bool CScrollV::OnClickScrollDec(const int id=WRONG_VALUE,const int index=WRONG_VALUE)
  {
   // --- Check element ID and index if there was an external call
      uint check_id    =(id!=WRONG_VALUE)? id : CElementBase::Id();
      uint check_index =(index!=WRONG_VALUE)? index : CElementBase::Index();
   // --- Exit if values ​​do not match
      if(check_id!=m_button_dec.Id() || check_index!=m_button_dec.Index())
         return(false);
   // --- Exit if (1) is currently active or (2) the number of steps is undefined
      if(CScroll::State() || m_thumb_steps_total<1)
         return(false);
   // --- Increase the scroll bar position number
      if(CScroll::CurrentPos()<CScroll::m_thumb_steps_total-1)
         CScroll::m_current_pos++;
   // --- Calculate the Y coordinate of the scroll bar
      CalculateThumbY();
   // --- Press the button
      m_button_dec.IsPressed(false);
      return(true);
  }
 //+------------------------------------------------------------------+
 //| Moving the slider |
 //+------------------------------------------------------------------+
 bool CScrollV::OnDragThumb(const int y)
  {
    // --- To define a new Y coordinate
      int new_y_point=0;
    // --- If the scroll bar is inactive,...
      if(!CScroll::State())
        {
         // --- ...reset auxiliary variables for moving the slider to zero
         m_thumb_size_fixing  =0;
         m_thumb_point_fixing =0;
         return(false);
        }
    // --- If the fixation point is zero, then remember the current cursor coordinate
      if(m_thumb_point_fixing==0)
         m_thumb_point_fixing=y;
    // --- If the distance value from the extreme point of the slider to the current cursor coordinate is zero, calculate it
      if(m_thumb_size_fixing==0)
         m_thumb_size_fixing=m_thumb_y-y;
    // --- If, while pressed, the threshold is passed down
      if(y-m_thumb_point_fixing>0)
        {
         // --- Calculate the Y coordinate
         new_y_point=y+m_thumb_size_fixing;
         // --- Update the position of the slider
         UpdateThumb(new_y_point);
         return(true);
        }
    // --- If, while pressed, the threshold is passed up
      if(y-m_thumb_point_fixing<0)
        {
         // --- Calculate the Y coordinate
         new_y_point=y-::fabs(m_thumb_size_fixing);
         // --- Update the position of the slider
         UpdateThumb(new_y_point);
         return(true);
        }
    //---
      return(false);
  }
 //+------------------------------------------------------------------+
 //| Update slider position |
 //+------------------------------------------------------------------+
 void CScrollV::UpdateThumb(const int new_y_point)
  {
      int y=new_y_point;
    // --- Resetting the fixation point
      m_thumb_point_fixing=0;
    // --- Checking for leaving the work area down and adjusting values
      if(new_y_point>m_y_size-m_thumb_width-m_thumb_length)
        {
         y=m_y_size-m_thumb_width-m_thumb_length;
         CScroll::CurrentPos(int(m_thumb_steps_total-1));
        }
    // --- Checking for upward exit from the work area and adjusting values
      if(new_y_point<=m_thumb_width)
        {
         y=m_thumb_width;
         CScroll::CurrentPos(0);
        }
    // --- Current coordinates
      RedrawThumb(y);
  }
 //+------------------------------------------------------------------+
 //| Adjusts the slider position number |
 //+------------------------------------------------------------------+
 void CScrollV::CalculateThumbPos(void)
  {
    // --- Exit if step is zero
      if(m_thumb_step_size==0)
         return;
    // --- Adjusts the position number of the scroll bar
      CScroll::CurrentPos(int((m_thumb_y-m_thumb_width+1)/m_thumb_step_size));
    // --- Check for leaving the work area down/up
      if(m_thumb_y+m_thumb_length>=m_y_size-m_thumb_width)
         CScroll::CurrentPos(int(m_thumb_steps_total-1));
      if(m_thumb_y<=m_thumb_width)
         CScroll::CurrentPos(0);
  }
 //+------------------------------------------------------------------+
 //| Quick redraw of the scroll bar slider |
 //+------------------------------------------------------------------+
 void CScrollV::RedrawThumb(const int y)
  {
    // --- Current coordinates
      int x1=0,y1=0,x2=0,y2=0;
      CalculateThumbBoundaries(x1,y1,x2,y2);
    // --- Erase the current position of the slider
      m_canvas.FillRectangle(x1,y1,x2-1,y2-1,m_back_color);
    // --- Update coordinates
      m_thumb_y=y;
      y2=y+m_thumb_length;
    // --- Draw new slider position
      m_canvas.FillRectangle(x1,y1,x2-1,y2-1,m_thumb_color_pressed);
  }
#endif // CCSCROLLV_MQH_IMPLEMENTATION

#ifndef CCSCROLLH_MQH_DECLARATION
#define CCSCROLLH_MQH_DECLARATION
 //+------------------------------------------------------------------+
 // | Class for controlling horizontal scrollbar |
 //+------------------------------------------------------------------+
 class CScrollH : public CScroll
  {
   public:
                        CScrollH(void);
                       ~CScrollH(void);
      // --- Slider control
      bool              ScrollBarControl(void);
      // --- Moves the slider to the specified position
      void              MovingThumb(const int pos=WRONG_VALUE);
      // --- Set new coordinate for scrollbar
      void              YDistance(const int y);
      // --- Change scrollbar length
      void              ChangeXSize(const int width);
      // --- Handling clicks on scrollbar buttons
      bool              OnClickScrollInc(const int id=WRONG_VALUE,const int index=WRONG_VALUE);
      bool              OnClickScrollDec(const int id=WRONG_VALUE,const int index=WRONG_VALUE);
      //---
   private:      
      bool              OnDragThumb(const int x);           // --- Moving the slider      
      void              UpdateThumb(const int new_x_point); // ---Updating the slider position
      void              CalculateThumbX(void);              // --- Calculate the X coordinate of the slider
      void              CalculateThumbPos(void);            // --- Adjusts the slider position number
      void              RedrawThumb(const int x);           // --- Quick redraw of the scroll bar slider
  };
#endif // CCSCROLLH_MQH_DECLARATION

#ifndef CCSCROLLH_MQH_IMPLEMENTATION
#define CCSCROLLH_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CScrollH::CScrollH(void)
  {
    // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CScrollH::~CScrollH(void)
  {
  }
 //+------------------------------------------------------------------+
 //| Scroll control                                                   |
 //+------------------------------------------------------------------+
 bool CScrollH::ScrollBarControl(void)
  {
    // --- Exit if (1) there is no pointer to the main element or (2) the element is hidden
      if(!CElement::CheckMainPointer() || !CElementBase::IsVisible())
         return(false);
    // --- Exit if parent is disabled by another element
      if(!m_main.CElementBase::IsAvailable())
         return(false);
    // --- Checking focus above the slider
      int x=m_mouse.RelativeX(m_canvas);
      int y=m_mouse.RelativeY(m_canvas);
      CheckThumbFocus(x,y);
    // --- Let's check and remember the state of the mouse button
      CScroll::CheckMouseButtonState();
    // --- If control is transferred to the scroll bar, determine the position of the slider
      if(CScroll::State())
       {
        // --- If the slider is moved
         if(OnDragThumb(x))
           {
            // --- Changes the slider position number
             CalculateThumbPos();
             return(true);
           }
       }
      return(false);
  }
 //+------------------------------------------------------------------+
 //| Moves the slider to the specified position |
 //+------------------------------------------------------------------+
 void CScrollH::MovingThumb(const int pos=WRONG_VALUE)
  {
   // --- Exit if scrollbar is not needed
      if(!IsScroll())
         return;
   // --- To check the position of the slider
      uint check_pos=0;
   // --- We will adjust the position if it leaves the range
      if(pos<0 || pos>m_items_total-m_visible_items_total)
         check_pos=m_items_total-m_visible_items_total;
      else
         check_pos=pos;
   // --- Remember the position of the slider
      CScroll::CurrentPos(check_pos);
   // --- Calculate and set the Y coordinate of the scroll bar slider
      CalculateThumbX();
  }
 //+------------------------------------------------------------------+
 //| Calculation of the X coordinate of the slider |
 //+------------------------------------------------------------------+
 void CScrollH::CalculateThumbX(void)
  {
   // --- Determine the current X coordinate of the slider
      double scroll_thumb_x=m_thumb_width+(CurrentPos()*m_thumb_step_size);
   // --- If we go beyond the working area to the left
      if(scroll_thumb_x<=m_thumb_width)
        {
         scroll_thumb_x=m_thumb_width;
        }
   // --- If we go beyond the working area to the right
      if(scroll_thumb_x+m_thumb_length>=m_x_size-m_thumb_width || 
         CScroll::CurrentPos()>=m_thumb_steps_total-1)
        {
         scroll_thumb_x=int(m_x_size-m_thumb_width-m_thumb_length);
        }
   // --- Update the coordinate and offset along the X axis
      m_thumb_x=(int)scroll_thumb_x;
  }
 //+------------------------------------------------------------------+
 //| Changing the Y coordinate of an element |
 //+------------------------------------------------------------------+
 void CScrollH::YDistance(const int y)
  {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return;
   // --- Update the Y coordinate of the element...
      CElementBase::Y(CElement::CalculateY(y));
      CElementBase::YGap(y);
   // --- ...and all scrollbar objects
      m_canvas.Y(y);
      m_thumb_y=y;
   // --- Set the coordinates for objects
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YDISTANCE,y);
   // --- Update the indentation of all element objects
      int y_gap=CElement::CalculateYGap(y);
      m_canvas.YGap(CElement::CalculateYGap(y));
  }
  //+------------------------------------------------------------------+
  // | Change scrollbar length |
  //+------------------------------------------------------------------+
  void CScrollH::ChangeXSize(const int width)
   {
    // ---Coordinates and dimensions
      int x=0,x_size=width-1;
    // --- Change element and background width
      CElementBase::XSize(x_size);
      m_canvas.XSize(x_size);
      m_canvas.Resize(x_size,m_y_size);
    // --- Adjust the position of the decrement button
      m_button_dec.Moving();
    // --- Calculate and set the sizes of scrollbar objects
      CalculateThumbSize();
    // ---Adjusting the slider position
      if(m_thumb_x+m_thumb_length>=m_x_size-m_thumb_length || m_thumb_x<m_thumb_width)
        {
         CalculateThumbX();
         CalculateThumbPos();
        }
   }
 //+------------------------------------------------------------------+
 // | Pressing the switch left |
 //+------------------------------------------------------------------+
 bool CScrollH::OnClickScrollInc(const int id=WRONG_VALUE,const int index=WRONG_VALUE)
  {
   // --- Check element ID and index if there was an external call
      uint check_id    =(id!=WRONG_VALUE)? id : CElementBase::Id();
      uint check_index =(index!=WRONG_VALUE)? index : CElementBase::Index();
   // --- Exit if values ​​do not match
      if(check_id!=m_button_inc.Id() || check_index!=m_button_inc.Index())
         return(false);
   // --- Exit if (1) is currently active or (2) the number of steps is undefined
      if(CScroll::State() || m_thumb_steps_total<1)
         return(false);
   // --- Decrease the scroll bar position number
      if(CScroll::CurrentPos()>0)
         CScroll::m_current_pos--;
   // --- Calculate the X coordinates of the scroll bar
      CalculateThumbX();
   // --- Press the button
      m_button_inc.IsPressed(false);
      return(true);
  }
 //+------------------------------------------------------------------+
 // | Pressing the switch to the right |
 //+------------------------------------------------------------------+
 bool CScrollH::OnClickScrollDec(const int id=WRONG_VALUE,const int index=WRONG_VALUE)
  {
   // --- Check element identifier and index if there was an external call
      uint check_id    =(id!=WRONG_VALUE)? id : CElementBase::Id();
      uint check_index =(index!=WRONG_VALUE)? index : CElementBase::Index();
   // --- Exit if values ​​do not match
      if(check_id!=m_button_inc.Id() || check_index!=m_button_dec.Index())
         return(false);
   // --- Exit if (1) is currently active or (2) the number of steps is undefined
      if(CScroll::State() || m_thumb_steps_total<1)
         return(false);
   // --- Increase the scroll bar position number
      if(CScroll::CurrentPos()<CScroll::m_thumb_steps_total-1)
         CScroll::m_current_pos++;
   // --- Calculate the X coordinate of a scroll bar
      CalculateThumbX();
   // --- Press the button
      m_button_dec.IsPressed(false);
      return(true);
  }
 //+------------------------------------------------------------------+
 // | Moving the slider |
 //+------------------------------------------------------------------+
 bool CScrollH::OnDragThumb(const int x)
  {
   // --- To define a new X coordinate
      int new_x_point=0;
   // --- If the scroll bar is inactive,...
      if(!CScroll::State())
        {
         // --- ...reset auxiliary variables for moving the slider to zero
         CScroll::m_thumb_size_fixing  =0;
         CScroll::m_thumb_point_fixing =0;
         return(false);
        }
   // --- If the fixation point is zero, then remember the current cursor coordinates
      if(CScroll::m_thumb_point_fixing==0)
         CScroll::m_thumb_point_fixing=x;
   // --- If the distance value from the extreme point of the slider to the current cursor coordinate is zero, calculate it
      if(CScroll::m_thumb_size_fixing==0)
         CScroll::m_thumb_size_fixing=m_thumb_x-x;
   // --- If, while pressed, you have passed the threshold to the right
      if(x-CScroll::m_thumb_point_fixing>0)
        {
         // --- Calculate the X coordinate
         new_x_point=x+CScroll::m_thumb_size_fixing;
         // ---Updating scrollbar position
         UpdateThumb(new_x_point);
         return(true);
        }
   // --- If, while pressed, the threshold is passed to the left
      if(x-CScroll::m_thumb_point_fixing<0)
        {
         // --- Calculate the X coordinate
         new_x_point=x-::fabs(CScroll::m_thumb_size_fixing);
         // ---Updating scrollbar position
         UpdateThumb(new_x_point);
         return(true);
        }
   //---
      return(false);
  }
 //+------------------------------------------------------------------+
 // | Update scrollbar position |
 //+------------------------------------------------------------------+
 void CScrollH::UpdateThumb(const int new_x_point)
  {
      int x=new_x_point;
   // --- Resetting the fixation point
      CScroll::m_thumb_point_fixing=0;
   // --- Checking for leaving the work area to the right and adjusting values
      if(new_x_point>m_x_size-m_thumb_width-m_thumb_length)
        {
         x=m_x_size-m_thumb_width-m_thumb_length;
         CScroll::CurrentPos(0);
        }
   // --- Checking for leaving the work area to the left and adjusting values
      if(new_x_point<=m_thumb_width)
        {
         x=m_thumb_width;
         CScroll::CurrentPos(int(m_thumb_steps_total));
        }
   // --- Current coordinates
      RedrawThumb(x);
  }
 //+------------------------------------------------------------------+
 // | Adjusts the slider position number |
 //+------------------------------------------------------------------+
 void CScrollH::CalculateThumbPos(void)
  {
   // --- Exit if step is zero
      if(CScroll::m_thumb_step_size==0)
         return;
   // --- Adjusts the position number of the scroll bar
      double pos=(m_thumb_x-m_thumb_width)/m_thumb_step_size;
      CScroll::CurrentPos((int)::MathCeil(pos));
   // --- Check for leaving the work area left/right
      if(m_thumb_x+m_thumb_length>=m_x_size-m_thumb_width-1)
         CScroll::CurrentPos(int(m_thumb_steps_total-1));
      if(m_thumb_x<m_thumb_width)
         CScroll::CurrentPos(0);
  }
 //+------------------------------------------------------------------+
 // | Quick redraw of the scroll bar slider |
 //+------------------------------------------------------------------+
 void CScrollH::RedrawThumb(const int x)
  {
   // --- Current coordinates
      int x1=0,y1=0,x2=0,y2=0;
      CalculateThumbBoundaries(x1,y1,x2,y2);
   // --- Erase the current position of the slider
      m_canvas.FillRectangle(x1,y1,x2-1,y2-1,m_back_color);
   // --- Update coordinates
      m_thumb_x=x;
      x2=x+m_thumb_length;
   // --- Draw new slider position
      m_canvas.FillRectangle(x1,y1,x2-1,y2-1,m_thumb_color_pressed);
  }
#endif // CCSCROLLH_MQH_IMPLEMENTATION
#endif // __SCROLLS_MQH__
