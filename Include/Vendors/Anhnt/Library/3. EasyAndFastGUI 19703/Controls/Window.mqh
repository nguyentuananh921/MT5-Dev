//+------------------------------------------------------------------+
//|                                                       Window.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\ElementBase.mqh"
#include "Button.mqh"
#include "Pointer.mqh"
//+------------------------------------------------------------------+
// | Form class for controls |
//+------------------------------------------------------------------+
class CWindow : public CElement
  {
private:
   // --- Objects for creating a form
   CButton           m_button_close;
   CButton           m_button_fullscreen;
   CButton           m_button_collapse;
   CButton           m_button_tooltip;
   CPointer          m_xy_resize;
   // --- Index of the previous active window
   int               m_prev_active_window_index;
   // --- Ability to move the window on the chart
   bool              m_is_movable;
   // --- Minimized window status
   bool              m_is_minimized;
   // --- Window status in full screen mode
   bool              m_is_fullscreen;
   // --- Last window coordinates and sizes before converting to full screen size
   int               m_last_x;
   int               m_last_y;
   int               m_last_x_size;
   int               m_last_y_size;
   bool              m_last_auto_xresize;
   bool              m_last_auto_yresize;
   // --- Minimum window sizes
   int               m_minimum_x_size;
   int               m_minimum_y_size;
   // --- Window type
   ENUM_WINDOW_TYPE  m_window_type;
   // --- Fixed subwindow height mode (for indicators)
   bool              m_height_subwindow_mode;
   // --- Form collapse mode in the indicator subwindow
   bool              m_rollup_subwindow_mode;
   // --- Height of the indicator subwindow
   int               m_subwindow_height;
   // --- Full height of the form
   int               m_full_height;
   // --- Header height
   int               m_caption_height;
   // --- Header colors
   color             m_caption_color;
   color             m_caption_color_hover;
   color             m_caption_color_locked;
   // --- Enables transparency for the header only
   bool              m_transparent_only_caption;
   // --- Availability of a button for (1) closing, (2) expanding to full screen mode, (3) minimizing the window
   bool              m_close_button;
   bool              m_fullscreen_button;
   bool              m_collapse_button;
   // --- Availability of a button for the mode of displaying tooltips
   bool              m_tooltips_button;
   bool              m_tooltips_button_state;
   // --- Chart dimensions
   int               m_chart_width;
   int               m_chart_height;
   // --- To define the boundaries of the capture area in the window title
   int               m_right_limit;
   // --- Variables associated with window movement
   int               m_prev_x;
   int               m_prev_y;
   int               m_size_fixing_x;
   int               m_size_fixing_y;
   // --- State of the mouse button, taking into account where it was pressed
   ENUM_MOUSE_STATE  m_clamping_area_mouse;
   // --- Window resizing mode
   bool              m_xy_resize_mode;
   // ---Border index for window resizing
   int               m_resize_mode_index;
   // --- Variables related to window resizing
   int               m_x_fixed;
   int               m_size_fixed;
   int               m_point_fixed;
   // --- To manage the chart state
   bool              m_custom_event_chart_state;
   //---
public:
                     CWindow(void);
                    ~CWindow(void);
   // --- Methods for creating a window
   bool              CreateWindow(const long chart_id,const int window,const string caption_text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const long chart_id,const int subwin,const string caption_text,const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateButtons(void);
   bool              CreateResizePointer(void);
   //---
public:
   // --- Returns pointers
   CButton          *GetCloseButtonPointer(void)                     { return(::GetPointer(m_button_close));      }
   CButton          *GetFullscreenButtonPointer(void)                { return(::GetPointer(m_button_fullscreen)); }
   CButton          *GetCollapseButtonPointer(void)                  { return(::GetPointer(m_button_collapse));   }
   CButton          *GetTooltipButtonPointer(void)                   { return(::GetPointer(m_button_tooltip));    }
   CPointer         *GetResizePointer(void)                          { return(::GetPointer(m_xy_resize));         }
   // --- (1) Get and save the index of the previous active window
   int               PrevActiveWindowIndex(void)               const { return(m_prev_active_window_index);        }
   void              PrevActiveWindowIndex(const int index)          { m_prev_active_window_index=index;          }
   // --- (1) Window type, (2) Title capture area limitation
   ENUM_WINDOW_TYPE  WindowType(void)                          const { return(m_window_type);                     }
   void              WindowType(const ENUM_WINDOW_TYPE flag)         { m_window_type=flag;                        }
   void              RightLimit(const int value)                     { m_right_limit=value;                       }
   // --- Header height
   void              CaptionHeight(const int height)                 { m_caption_height=height;                   }
   int               CaptionHeight(void)                       const { return(m_caption_height);                  }
   // --- (1) Title colors, (2) turns on transparency mode for the window title only
   void              CaptionColor(const color clr)                   { m_caption_color=clr;                       }
   color             CaptionColor(void)                        const { return(m_caption_color);                   }
   void              CaptionColorHover(const color clr)              { m_caption_color_hover=clr;                 }
   color             CaptionColorHover(void)                   const { return(m_caption_color_hover);             }
   void              CaptionColorLocked(const color clr)             { m_caption_color_locked=clr;                }
   color             CaptionColorLocked(void)                  const { return(m_caption_color_locked);            }
   void              TransparentOnlyCaption(const bool state)        { m_transparent_only_caption=state;          }
   // --- (1) Use the button to close the window, (2) use the full screen button,
   // (3) use the button to minimize/maximize the window, (4) use the hint button
   void              CloseButtonIsUsed(const bool state)             { m_close_button=state;                      }
   bool              CloseButtonIsUsed(void)                   const { return(m_close_button);                    }
   void              FullscreenButtonIsUsed(const bool state)        { m_fullscreen_button=state;                 }
   bool              FullscreenButtonIsUsed(void)              const { return(m_fullscreen_button);               }
   void              CollapseButtonIsUsed(const bool state)          { m_collapse_button=state;                   }
   bool              CollapseButtonIsUsed(void)                const { return(m_collapse_button);                 }
   void              TooltipsButtonIsUsed(const bool state)          { m_tooltips_button=state;                   }
   bool              TooltipsButtonIsUsed(void)                const { return(m_tooltips_button);                 }
   // --- (1) Checking the tooltip display mode
   void              TooltipButtonState(const bool state)            { m_tooltips_button_state=state;             }
   bool              TooltipButtonState(void)                  const { return(m_tooltips_button_state);           }
   // --- Ability to move the window
   bool              IsMovable(void)                           const { return(m_is_movable);                      }
   void              IsMovable(const bool state)                     { m_is_movable=state;                        }
   // --- (1) Minimized window status, (2) returns the area where the left mouse button was pressed
   bool              IsMinimized(void)                         const { return(m_is_minimized);                    }
   void              IsMinimized(const bool state)                   { m_is_minimized=state;                      }
   ENUM_MOUSE_STATE  ClampingAreaMouse(void)                   const { return(m_clamping_area_mouse);             }
   // --- Setting minimum window sizes
   void              MinimumXSize(const int x_size)                  { m_minimum_x_size=x_size;                   }
   void              MinimumYSize(const int y_size)                  { m_minimum_y_size=y_size;                   }
   // --- Ability to resize the window
   bool              ResizeMode(void)                          const { return(m_xy_resize_mode);                  }
   void              ResizeMode(const bool state)                    { m_xy_resize_mode=state;                    }
   // --- Window resizing process status
   bool              ResizeState(void) const { return(m_resize_mode_index!=WRONG_VALUE && m_mouse.LeftButtonState()); }

   // ---Default shortcut
   uint              DefaultIcon(void);
   // --- Setting the window state
   void              State(const bool flag);
   // --- Minimizing mode of the indicator subwindow
   void              RollUpSubwindowMode(const bool flag,const bool height_mode);
   // --- Size management
   void              ChangeWindowWidth(const int width);
   void              ChangeWindowHeight(const int height);
   // --- Changes the height of the indicator subwindow
   void              ChangeSubwindowHeight(const int height);

   // --- Getting graph dimensions
   void              SetWindowProperties(void);
   // --- Checking the cursor in the title area
   bool              CursorInsideCaption(const int x,const int y);
   // --- Resetting variables
   void              ZeroMoveVariables(void);
   void              ZeroResizeVariables(void);

   // --- Checking the status of the left mouse button
   void              CheckMouseButtonState(void);
   // --- Setting the schedule mode
   void              SetChartState(void);
   // ---Updating form coordinates
   void              UpdateWindowXY(const int x,const int y);
   // --- Custom flag for managing chart properties
   void              CustomEventChartState(const bool state) { m_custom_event_chart_state=state; }

   // --- Opening a window
   void              OpenWindow(void);
   // --- Closing the main window
   void              CloseWindow(void);
   // ---Close the dialog box
   void              CloseDialogBox(void);
   // --- Changing window state
   void              ChangeWindowState(void);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // ---Move element
   virtual void      Moving(const int x,const int y);
   // --- Show, hide, reset, delete
   virtual void      Show(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
public:
   // --- Handling clicks on the "Close window" button
   bool              OnClickCloseButton(const int id=WRONG_VALUE,const int index=WRONG_VALUE);
   // --- To full screen size or to the previous window size
   bool              OnClickFullScreenButton(const int id=WRONG_VALUE,const int index=WRONG_VALUE);
   // --- Handling clicks on the "Collapse window" button
   bool              OnClickCollapseButton(const int id=WRONG_VALUE,const int index=WRONG_VALUE);
   // --- Handling clicks on the "Tooltips" button
   bool              OnClickTooltipsButton(const uint id,const uint index);
   
private:
   // --- Methods for (1) minimizing and (2) maximizing a window
   void              Collapse(void);
   void              Expand(void);

   // --- Controls window sizes
   void              ResizeWindow(void);
   // ---Checking readiness for window resizing
   bool              CheckResizePointer(const int x,const int y);
   // --- Returns the mode index for window resizing
   int               ResizeModeIndex(const int x,const int y);
   // ---Updating window sizes
   void              UpdateSize(const int x,const int y);
   // --- Checking window border dragging
   int               CheckDragWindowBorder(const int x,const int y);
   // --- Calculation and resizing of windows
   void              CalculateAndResizeWindow(const int distance);

   // --- Draws the background
   virtual void      DrawBackground(void);
   // --- Draws the foreground
   virtual void      DrawForeground(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWindow::CWindow(void) : m_right_limit(0),
                         m_caption_height(20),
                         m_caption_color(C'77,118,201'),
                         m_caption_color_hover(C'77,118,201'),
                         m_caption_color_locked(C'188,165,219'),
                         m_transparent_only_caption(true),
                         m_prev_active_window_index(0),
                         m_subwindow_height(0),
                         m_rollup_subwindow_mode(false),
                         m_height_subwindow_mode(false),
                         m_is_movable(false),
                         m_x_fixed(0),
                         m_size_fixed(0),
                         m_point_fixed(0),
                         m_xy_resize_mode(false),
                         m_resize_mode_index(WRONG_VALUE),
                         m_is_minimized(false),
                         m_is_fullscreen(false),
                         m_last_x(0),
                         m_last_y(0),
                         m_last_x_size(0),
                         m_last_y_size(0),
                         m_minimum_x_size(0),
                         m_minimum_y_size(0),
                         m_last_auto_xresize(false),
                         m_last_auto_yresize(false),
                         m_close_button(true),
                         m_fullscreen_button(false),
                         m_collapse_button(false),
                         m_tooltips_button(false),
                         m_tooltips_button_state(false),
                         m_window_type(W_MAIN),
                         m_clamping_area_mouse(NOT_PRESSED)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
// --- Get the dimensions of the chart window
   SetWindowProperties();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWindow::~CWindow(void)
  {
  }
//+------------------------------------------------------------------+
// | Graphics Event Handler |
//+------------------------------------------------------------------+
void CWindow::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Exit if the form is in another chart subwindow
      if(!CElementBase::CheckSubwindowNumber())
        {
         // --- If chart scrolling is disabled
         if(!m_chart.GetInteger(CHART_MOUSE_SCROLL))
           {
            // --- Reset
            ZeroMoveVariables();
            CElementBase::MouseFocus(false);
            // --- Set the chart state
            m_chart.MouseScroll(true);
            m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS,true);
           }
         //---
         return;
        }
      // --- Checking mouse focus
      CElementBase::CheckMouseFocus();
      // --- Let's check and remember the state of the mouse button
      CheckMouseButtonState();
      // --- Set the chart state
      SetChartState();
      // --- Exit if this form is blocked
      if(CElementBase::IsLocked())
         return;
      // --- Redraw the element if (1) there was a border crossing and (2) the state colors are different
      if(CElementBase::CheckCrossingBorder())
        {
         if(m_caption_color!=m_caption_color_hover)
            Update(true);
        }
      // --- If control is transferred to the window
      if(m_clamping_area_mouse==PRESSED_INSIDE_HEADER)
        {
         // --- Exit if the sill numbers do not match
         if(CElementBase::m_subwin!=CElementBase::m_mouse.SubWindowNumber())
            return;
         // ---Updating window coordinates
         UpdateWindowXY(m_mouse.X(),m_mouse.Y());
         return;
        }
      // --- Resizing the window
      ResizeWindow();
      return;
     }
// --- Processing the click event on the chart
   if(id==CHARTEVENT_CLICK)
     {
      // --- Get the dimensions of the chart window
      SetWindowProperties();
      return;
     }
// --- Handling a double-click event on an object
   if(id==CHARTEVENT_CUSTOM+ON_DOUBLE_CLICK)
     {
      // --- If the event was generated on the window title
      if(CursorInsideCaption(m_mouse.X(),m_mouse.Y()))
        {
          OnClickFullScreenButton(m_button_fullscreen.Id(),m_button_fullscreen.Index());
        }
      //---
      return;
     }
// --- Handling click events on form buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      // --- Close window
      if(OnClickCloseButton((uint)lparam,(uint)dparam))
         return;
      // --- Checking full screen mode
      if(OnClickFullScreenButton((uint)lparam,(uint)dparam))
         return;
      // --- Collapse/Expand window
      if(OnClickCollapseButton((uint)lparam,(uint)dparam))
         return;
      // --- If you click on the "Tooltips" button
      if(OnClickTooltipsButton((uint)lparam,(uint)dparam))
         return;
      //---
      return;
     }
// --- Chart properties change event
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      // --- If the button is released
      if(m_clamping_area_mouse==NOT_PRESSED)
        {
         // --- Get the dimensions of the chart window
         SetWindowProperties();
         // ---Coordinate adjustment
         UpdateWindowXY(m_x,m_y);
        }
      // --- Change width if mode is enabled
      if(CElementBase::AutoXResizeMode())
         ChangeWindowWidth(m_chart.WidthInPixels()-2);
      // --- Change height if mode is enabled
      if(CElementBase::AutoYResizeMode())
         ChangeWindowHeight(m_chart.HeightInPixels(m_subwin)-3);
      //---
      return;
     }
// --- Processing the event of changing the height of the expert subwindow
   if(id==CHARTEVENT_CUSTOM+ON_SUBWINDOW_CHANGE_HEIGHT)
     {
      // --- Exit if (1) this message was from an expert or (2) this is not an expert
      if(sparam==PROGRAM_NAME || CElementBase::ProgramType()!=PROGRAM_EXPERT)
         return;
      // --- Exit if subwindow fixed height mode is not set
      if(!m_height_subwindow_mode)
         return;
      // --- Calculate and change the height of the subwindow
      m_subwindow_height=(m_is_minimized)? m_caption_height+3 : m_full_height+3;
      ChangeSubwindowHeight(m_subwindow_height);
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a form for controls |
//+------------------------------------------------------------------+
bool CWindow::CreateWindow(const long chart_id,const int subwin,const string caption_text,const int x,const int y)
  {
// --- Quit if identifier is not defined
   if(CElementBase::Id()==WRONG_VALUE)
     {
      ::Print(__FUNCTION__," > Перед созданием окна его указатель нужно сохранить в базе: CWndContainer::AddWindow(CWindow &object)");
      return(false);
     }
// --- Let's save pointers to ourselves
   CElement::WindowPointer(this);
   CElement::MainPointer(this);
// --- Save the properties of the chart window
   SetWindowProperties();
// --- Initializing properties
   InitializeProperties(chart_id,subwin,caption_text,x,y);
// --- Create all window objects
   if(!CreateCanvas())
      return(false);
   if(!CreateButtons())
      return(false);
   if(!CreateResizePointer())
      return(false);
// --- Value of the last installed ID
   CElementBase::LastId(CElementBase::Id());
// --- If this program indicator
   if(CElementBase::ProgramType()==PROGRAM_INDICATOR)
     {
      // --- If the subwindow fixed height mode is set
      if(m_height_subwindow_mode)
        {
         m_subwindow_height=m_full_height+3;
         ChangeSubwindowHeight(m_subwindow_height);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CWindow::InitializeProperties(const long chart_id,const int subwin,const string caption_text,const int x_gap,const int y_gap)
  {
   m_chart_id   =chart_id;
   m_subwin     =subwin;
   m_label_text =caption_text;
// ---Coordinates and dimensions
   m_x              =x_gap;
   m_y              =y_gap;
   m_x_size         =(m_auto_xresize_mode)? m_chart_width-2 : m_x_size;
   m_y_size         =(m_auto_yresize_mode)? m_chart_height-3 : m_y_size;
   m_x_size         =(m_x_size<1)? 200 : m_x_size;
   m_y_size         =(m_y_size<1)? 200 : m_y_size;
   m_full_height    =m_y_size;
   m_last_x_size    =m_x_size;
   m_last_y_size    =m_y_size;
   m_minimum_x_size =(m_minimum_x_size<200)? m_x_size : m_minimum_x_size;
   m_minimum_y_size =(m_minimum_y_size<200)? m_y_size : m_minimum_y_size;
// ---Default properties
   m_back_color         =(m_back_color!=clrNONE)? m_back_color : clrWhiteSmoke;
   m_icon_x_gap         =(m_icon_x_gap!=WRONG_VALUE)? m_icon_x_gap : 5;
   m_icon_y_gap         =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 2;
   m_label_x_gap        =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 24;
   m_label_y_gap        =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 3;
   m_label_color        =(m_label_color!=clrNONE)? m_label_color : clrWhite;
   m_label_color_hover  =(m_label_color_hover!=clrNONE)? m_label_color_hover : clrWhite;
   m_label_color_locked =(m_label_color_locked!=clrNONE)? m_label_color_locked : clrBlack;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CWindow::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("window");
// --- The size of the main window depends on the state (collapsed/expanded)
   if(m_window_type==W_MAIN)
      m_y_size=(m_is_minimized)? m_caption_height : m_full_height;
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
// --- Set properties
   if(CElement::IconFile() == "")
     {
      CElement::IconFile((uint)DefaultIcon());
      CElement::IconFileLocked((uint)DefaultIcon());
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates buttons on the form |
//+------------------------------------------------------------------+
bool CWindow::CreateButtons(void)
  {
// --- If the program type is "script", exit
   if(CElementBase::ProgramType()==PROGRAM_SCRIPT)
      return(true);
// --- Counter, size, quantity
   int i=0,x_size=20;
   int buttons_total=4;
// --- File path
   uint icon_index=INT_MAX;
// --- Exception in capture area
   m_right_limit=0;
//---
   CButton *button_obj=NULL;
//---
   for(int b=0; b<buttons_total; b++)
     {
      //---
      if(b==0)
        {
         CElementBase::LastId(LastId()-1);
         m_button_close.MainPointer(this);
         if(!m_close_button)
            continue;
         //---
         button_obj =::GetPointer(m_button_close);
         icon_index =RESOURCE_CLOSE_WHITE;
        }
      else if(b==1)
        {
         m_button_fullscreen.MainPointer(this);
         // --- Quit if (1) the button is not enabled or (2) it's a dialog box
         if(!m_fullscreen_button || m_window_type==W_DIALOG)
            continue;
         //---
         button_obj =::GetPointer(m_button_fullscreen);
         icon_index =RESOURCE_FULL_SCREEN;
        }
      else if(b==2)
        {
         m_button_collapse.MainPointer(this);
         // --- Quit if (1) the button is not enabled or (2) it's a dialog box
         if(!m_collapse_button || m_window_type==W_DIALOG)
            continue;
         //---
         button_obj=::GetPointer(m_button_collapse);
         if(m_is_minimized)
            icon_index =RESOURCE_DOWN_THIN_WHITE;
         else
            icon_index =RESOURCE_UP_THIN_WHITE;
        }
      else if(b==3)
        {
         m_button_tooltip.MainPointer(this);
         // --- Quit if (1) the button is not enabled or (2) it's a dialog box
         if(!m_tooltips_button || m_window_type==W_DIALOG)
            continue;
         //---
         button_obj =::GetPointer(m_button_tooltip);
         icon_index =RESOURCE_HELP;
        }
      // --- Properties
      button_obj.Index(i);
      button_obj.XSize(x_size);
      button_obj.YSize(x_size);
      button_obj.IconXGap(2);
      button_obj.IconYGap(2);
      button_obj.BackColor(m_caption_color);
      button_obj.BackColorHover((b<1)? C'242,27,45' : C'90,139,232');
      button_obj.BackColorPressed((b<1)? C'149,68,116' : C'67,103,173');
      button_obj.BackColorLocked(m_caption_color_locked);
      button_obj.BorderColor(m_caption_color);
      button_obj.BorderColorHover(m_caption_color);
      button_obj.BorderColorLocked(m_caption_color_locked);
      button_obj.BorderColorPressed(m_caption_color);
      button_obj.IconFile((uint)icon_index);
      button_obj.IconFileLocked((uint)icon_index);
      if(b==3)
        {
         button_obj.TwoState(true);
         button_obj.CElement::IconFilePressed((uint)icon_index);
         button_obj.CElement::IconFilePressedLocked((uint)icon_index);
        }
      button_obj.AnchorRightWindowSide(true);
      // --- Calculate the indentation for the next button
      m_right_limit+=x_size-((i<3)? 0 : 1);
      i++;
      // --- Let's create an element
      if(!button_obj.CreateButton("",m_right_limit,0))
         return(false);
      // --- Add element to array
      CElement::AddToArray(button_obj);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a resizing cursor pointer |
//+------------------------------------------------------------------+
bool CWindow::CreateResizePointer(void)
  {
// --- Exit if resizing mode is disabled
   if(!m_xy_resize_mode)
      return(true);
// --- Properties
   m_xy_resize.XGap(13);
   m_xy_resize.YGap(11);
   m_xy_resize.XSize(23);
   m_xy_resize.YSize(23);
   m_xy_resize.Id(CElementBase::Id());
   m_xy_resize.Type(MP_WINDOW_RESIZE);
// ---Creating an element
   if(!m_xy_resize.CreatePointer(m_chart_id,m_subwin))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Defining a default shortcut |
//+------------------------------------------------------------------+
uint CWindow::DefaultIcon(void)
  {
   uint resource_index =RESOURCE_ADVISOR;
   
   switch(CElementBase::ProgramType()) {
    case PROGRAM_SCRIPT: {
       resource_index =RESOURCE_SCRIPT;
       break;
      }
    case PROGRAM_EXPERT: {
       resource_index =RESOURCE_ADVISOR;
       break;
      }
    case PROGRAM_INDICATOR: {
       resource_index =RESOURCE_INDICATOR;
       break;
      }
   }
   return(resource_index);
  }
//+------------------------------------------------------------------+
// | Indicator subwindow collapse mode |
//+------------------------------------------------------------------+
void CWindow::RollUpSubwindowMode(const bool rollup_mode=false,const bool height_mode=false)
  {
// --- Exit if this is a script
   if(CElementBase::m_program_type==PROGRAM_SCRIPT)
      return;
//---
   m_rollup_subwindow_mode =rollup_mode;
   m_height_subwindow_mode =height_mode;
//---
   if(m_height_subwindow_mode)
      ChangeSubwindowHeight(m_subwindow_height);
  }
//+------------------------------------------------------------------+
// | Changes the height of the indicator subwindow |
//+------------------------------------------------------------------+
void CWindow::ChangeSubwindowHeight(const int height)
  {
// --- If the GUI is (1) not in a subwindow or (2) a program of the "Script" type
   if(CElementBase::m_subwin<=0 || CElementBase::m_program_type==PROGRAM_SCRIPT)
      return;
// --- If you need to change the height of the subwindow
   if(height>0)
     {
      // --- If the program is of the "Indicator" type
      if(CElementBase::m_program_type==PROGRAM_INDICATOR)
        {
         if(!::IndicatorSetInteger(INDICATOR_HEIGHT,height))
            ::Print(__FUNCTION__," > Не удалось изменить высоту подокна индикатора! Номер ошибки: ",::GetLastError());
        }
      // --- If the program is of the "Expert" type
      else
        {
         // --- Send a message to the SubWindow.ex5 indicator that the window needs to be resized
         ::EventChartCustom(m_chart_id,ON_SUBWINDOW_CHANGE_HEIGHT,(long)height,0,PROGRAM_NAME);
        }
     }
  }
//+------------------------------------------------------------------+
// | Changes the width of the window |
//+------------------------------------------------------------------+
void CWindow::ChangeWindowWidth(const int width)
  {
// --- If the width has not changed, we will exit
   if(width==m_canvas.XSize())
      return;
// --- Update the width for the background and header
   CElementBase::XSize(width);
   m_canvas.XSize(width);
   m_canvas.Resize(width,m_y_size);
// --- Redraw the window
   Draw();
// --- Message that the window has been resized
   ::EventChartCustom(m_chart_id,ON_WINDOW_CHANGE_XSIZE,(long)CElementBase::Id(),0,"");
  }
//+------------------------------------------------------------------+
// | Changes the window height |
//+------------------------------------------------------------------+
void CWindow::ChangeWindowHeight(const int height)
  {
// --- If the height has not changed, we will exit
   if(height==m_canvas.YSize())
      return;
// --- Exit if the window is minimized
   if(m_is_minimized)
      return;
// --- Update the height for the background
   CElementBase::YSize(height);
   m_canvas.YSize(height);
   m_canvas.Resize(m_x_size,height);
   m_full_height=m_last_y_size;
// --- Redraw the window
   Draw();
// --- Message that the window has been resized
   ::EventChartCustom(m_chart_id,ON_WINDOW_CHANGE_YSIZE,(long)CElementBase::Id(),0,"");
  }
//+------------------------------------------------------------------+
// | Getting graph dimensions |
//+------------------------------------------------------------------+
void CWindow::SetWindowProperties(void)
  {
// --- Get the width and height of the chart window
   m_chart_width  =m_chart.WidthInPixels();
   m_chart_height =m_chart.HeightInPixels(m_subwin);
  }
//+------------------------------------------------------------------+
// | Checking the cursor position in the window title area |
//+------------------------------------------------------------------+
bool CWindow::CursorInsideCaption(const int x,const int y)
  {
   return(x>m_x && x<X2()-m_right_limit && y>m_y && y<m_y+m_caption_height);
  }
//+------------------------------------------------------------------+
// | Resetting variables associated with window movement and |
// | state of the left mouse button |
//+------------------------------------------------------------------+
void CWindow::ZeroMoveVariables(void)
  {
// --- Exit if reset has already been done
   if(m_clamping_area_mouse==NOT_PRESSED)
      return;
// --- We send a message for recovery only if there was a capture in the header area
   if(m_clamping_area_mouse==PRESSED_INSIDE_HEADER)
     {
      // --- We will send a message to restore available items
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
      // --- Send a message about the completion of dragging the form
      ::EventChartCustom(m_chart_id,ON_WINDOW_DRAG_END,CElementBase::Id(),0,"");
     }
// --- Reset
   m_prev_x              =0;
   m_prev_y              =0;
   m_size_fixing_x       =0;
   m_size_fixing_y       =0;
   m_clamping_area_mouse =NOT_PRESSED;
  }
//+------------------------------------------------------------------+
// | Resetting variables associated with window resizing |
//+------------------------------------------------------------------+
void CWindow::ZeroResizeVariables(void)
  {
// --- Exit if reset has already been done
   if(m_point_fixed<1)
      return;
// --- Reset
   m_x_fixed     =0;
   m_size_fixed  =0;
   m_point_fixed =0;
// --- We will send a message to restore available items
   ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
// --- Send a message about the change in the graphical interface
   ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
  }
//+------------------------------------------------------------------+
// | Checks the state of the mouse button |
//+------------------------------------------------------------------+
void CWindow::CheckMouseButtonState(void)
  {
// --- If the button is released
   if(!m_mouse.LeftButtonState())
     {
      // --- Let's reset the variables
      ZeroMoveVariables();
      return;
     }
// ---If the button is pressed
   else
     {
      // --- Exit if the state is already fixed
      if(m_clamping_area_mouse!=NOT_PRESSED)
         return;
      // --- Outside the form area
      if(!CElementBase::MouseFocus())
         m_clamping_area_mouse=PRESSED_OUTSIDE;
      // --- In the form area
      else
        {
         // --- Exit if the form is in another chart subwindow
         if(!CElementBase::CheckSubwindowNumber())
            return;
         // --- If inside the header
         if(CursorInsideCaption(m_mouse.X(),m_mouse.Y()))
           {
            m_clamping_area_mouse=PRESSED_INSIDE_HEADER;
            // --- Send a message to determine available elements
            ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
            // --- Send a message about the change in the graphical interface
            ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
            return;
           }
         // --- If in the form area
         else
            m_clamping_area_mouse=PRESSED_INSIDE;
        }
     }
  }
//+------------------------------------------------------------------+
// | Let's set the chart state |
//+------------------------------------------------------------------+
void CWindow::SetChartState(void)
  {
// --- If (the cursor is in the panel area and the mouse button is released) or
// a mouse button was pressed inside a form or header area
   if((CElementBase::MouseFocus() && m_clamping_area_mouse==NOT_PRESSED) || 
      m_clamping_area_mouse==PRESSED_INSIDE_HEADER ||
      m_clamping_area_mouse==PRESSED_INSIDE_BORDER ||
      m_clamping_area_mouse==PRESSED_INSIDE ||
      m_custom_event_chart_state)
     {
      // --- Disable scrolling and management of trading levels, take away control of the mouse wheel
      m_chart.MouseScroll(false);
      m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS,false);
      m_chart.SetInteger(CHART_EVENT_MOUSE_WHEEL,true);
     }
// --- Enable control, if the cursor is outside the window area, leave mouse wheel control
   else
     {
      m_chart.MouseScroll(true);
      m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS,true);
      m_chart.SetInteger(CHART_EVENT_MOUSE_WHEEL,false);
     }
  }
//+------------------------------------------------------------------+
// | Update window coordinates |
//+------------------------------------------------------------------+
void CWindow::UpdateWindowXY(const int x,const int y)
  {
// --- Exit if fixed form mode is set
   if(!m_is_movable)
      return;
// --- To calculate new X- and Y-coordinates
   int new_x_point=0,new_y_point=0;
// --- Limits
   int limit_top=0,limit_left=0,limit_bottom=0,limit_right=0;
// ---If the mouse button is pressed
   if((bool)m_clamping_area_mouse)
     {
      // --- Remember the current XY coordinates of the cursor
      if(m_prev_y==0 || m_prev_x==0)
        {
         m_prev_y=y;
         m_prev_x=x;
        }
      // --- Remember the distance from the extreme point of the form to the cursor
      if(m_size_fixing_y==0 || m_size_fixing_x==0)
        {
         m_size_fixing_y =m_y-m_prev_y;
         m_size_fixing_x =m_x-m_prev_x;
        }
     }
// --- Let's set limits
   limit_top    =y-::fabs(m_size_fixing_y);
   limit_left   =x-::fabs(m_size_fixing_x);
   limit_bottom =m_y+m_caption_height;
   limit_right  =m_x+m_x_size;
// --- If we do not go beyond the chart down/up/right/left
   if(limit_bottom<m_chart_height && limit_top>=0 && 
      limit_right<m_chart_width && limit_left>=0)
     {
      new_y_point =y+m_size_fixing_y;
      new_x_point =x+m_size_fixing_x;
     }
// --- If you go beyond the boundaries of the chart
   else
     {
      if(limit_bottom>m_chart_height) // >down
        {
         new_y_point =m_chart_height-m_caption_height;
         new_x_point =x+m_size_fixing_x;
        }
      else if(limit_top<0) // >up
        {
         new_y_point =0;
         new_x_point =x+m_size_fixing_x;
        }
      if(limit_right>m_chart_width) // > right
        {
         new_x_point =m_chart_width-m_x_size;
         new_y_point =y+m_size_fixing_y;
        }
      else if(limit_left<0) // > left
        {
         new_x_point =0;
         new_y_point =y+m_size_fixing_y;
        }
     }
// --- Update the coordinates if there was a movement
   if(new_x_point>0 || new_y_point>0)
     {
      // --- Adjust the coordinates of the form
      m_x =(new_x_point<=0)? 1 : new_x_point;
      m_y =(new_y_point<=0)? 1 : new_y_point;
      //---
      if(new_x_point>0)
         m_x=(m_x>m_chart_width-m_x_size-1) ? m_chart_width-m_x_size-1 : m_x;
      if(new_y_point>0)
         m_y=(m_y>m_chart_height-m_caption_height-2) ? m_chart_height-m_caption_height-2 : m_y;
      // --- Reset the fixation points
      m_prev_x=0;
      m_prev_y=0;
     }
  }
//+------------------------------------------------------------------+
// | Window opening |
//+------------------------------------------------------------------+
void CWindow::OpenWindow(void)
  {
// --- Show element
   CWindow::Show();
// --- Send a message about this
   ::EventChartCustom(m_chart_id,ON_OPEN_DIALOG_BOX,CElementBase::Id(),0,m_program_name);
  }
//+------------------------------------------------------------------+
// | Closing a dialog box or program |
//+------------------------------------------------------------------+
void CWindow::CloseWindow(void)
  {
   OnClickCloseButton();
  }
//+------------------------------------------------------------------+
// | Closing the dialog |
//+------------------------------------------------------------------+
void CWindow::CloseDialogBox(void)
  {
// --- Send a message about this
   ::EventChartCustom(m_chart_id,ON_CLOSE_DIALOG_BOX,CElementBase::Id(),m_prev_active_window_index,m_label_text);
  }
//+------------------------------------------------------------------+
// | Changing the window state to the opposite one (collapse/maximize) |
//+------------------------------------------------------------------+
void CWindow::ChangeWindowState(void)
  {
   OnClickCollapseButton();
  }
//+------------------------------------------------------------------+
// | Sets the window state |
//+------------------------------------------------------------------+
void CWindow::State(const bool flag)
  {
   int elements_total=CElement::ElementsTotal();
// --- If you need to lock the window
   if(!flag)
     {
      // --- Set the status
      CElementBase::IsLocked(true);
      for(int i=0; i<elements_total; i++)
         m_elements[i].IsLocked(true);
     }
// ---If you need to unlock the window
   else
     {
      // --- Set the status
      CElementBase::IsLocked(false);
      for(int i=0; i<elements_total; i++)
         m_elements[i].IsLocked(false);
      // --- Reset focus
      CElementBase::MouseFocus(false);
     }
// --- Redraw the window
   Update(true);
   for(int i=0; i<elements_total; i++)
      m_elements[i].Update(true);
  }
//+------------------------------------------------------------------+
// | Moving a window |
//+------------------------------------------------------------------+
void CWindow::Moving(const int x,const int y)
  {
// ---Saving coordinates in variables
   m_canvas.X(x);
   m_canvas.Y(y);
// --- Updating the coordinates of graphic objects
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,x);
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YDISTANCE,y);
// --- Moving elements
   int elements_total=CElement::ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].Moving();
  }
//+------------------------------------------------------------------+
// | Shows window |
//+------------------------------------------------------------------+
void CWindow::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Visibility state
   CElementBase::IsVisible(true);
// --- Update object position
   Moving(m_x,m_y);
// --- Show object
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
// --- Show items
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].Show();
// --- Get the dimensions of the chart window
   SetWindowProperties();
  }
//+------------------------------------------------------------------+
// | Redrawing all window objects |
//+------------------------------------------------------------------+
void CWindow::Reset(void)
  {
// --- Hide and show object
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
// --- Visibility state
   CElementBase::IsVisible(true);
// --- Reset focus
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CWindow::Delete(void)
  {
   CElement::Delete();
// --- Resetting variables
   m_right_limit       =0;
   m_is_fullscreen     =false;
   m_auto_xresize_mode =false;
   m_auto_yresize_mode =false;
  }
//+------------------------------------------------------------------+
// | Closing a dialog box or program |
//+------------------------------------------------------------------+
bool CWindow::OnClickCloseButton(const int id=WRONG_VALUE,const int index=WRONG_VALUE)
  {
// --- Check element identifier and index if there was an external call
   uint check_id    =(id!=WRONG_VALUE)? id : CElementBase::Id();
   uint check_index =(index!=WRONG_VALUE)? index : CElementBase::Index();
// --- Exit if values ​​do not match
   if(check_id!=m_button_close.Id() || check_index!=m_button_close.Index())
      return(false);
// ---If this is the main window
   if(m_window_type==W_MAIN)
     {
      // --- If the program is of the "Expert" type
      if(CElementBase::ProgramType()==PROGRAM_EXPERT)
        {
         string text="You want to remove the program from the chart?";
         // --- Open a dialog box
         int mb_res=::MessageBox(text,NULL,MB_YESNO|MB_ICONQUESTION);
         // --- If the "Yes" button is pressed, then we will remove the program from the chart
         if(mb_res==IDYES)
           {
            ::Print(__FUNCTION__," > The program was removed from the chart with your consent!");
            // --- Removing an expert from the chart
            ::ExpertRemove();
            return(true);
           }
         else
           {
            m_button_close.MouseFocus(false);
            m_button_close.Update(true);
           }
        }
      // --- If the program is of the "Indicator" type
      else if(CElementBase::ProgramType()==PROGRAM_INDICATOR)
        {
         // --- Removing an indicator from the chart
         if(::ChartIndicatorDelete(m_chart_id,::ChartWindowFind(),CElementBase::ProgramName()))
           {
            ::Print(__FUNCTION__," > The program was removed from the chart with your consent!");
            return(true);
           }
        }
     }
// --- If this is a dialog box, close it
   else if(m_window_type==W_DIALOG)
      CloseDialogBox();
//---
   return(false);
  }
//+------------------------------------------------------------------+
// | To full screen size or to the previous form size |
//+------------------------------------------------------------------+
bool CWindow::OnClickFullScreenButton(const int id=WRONG_VALUE,const int index=WRONG_VALUE)
  {
// --- Check element identifier and index if there was an external call
   int check_id    =(id!=WRONG_VALUE)? id : CElementBase::Id();
   int check_index =(index!=WRONG_VALUE)? index : CElementBase::Index();
// --- Exit if indexes do not match
   if(check_id!=m_button_fullscreen.Id() || check_index!=m_button_fullscreen.Index())
      return(false);
// --- If the window is not in full screen size
   if(!m_is_fullscreen)
     {
      // --- Convert to full screen size
      m_is_fullscreen=true;
      // --- Get the current dimensions of the chart window
      SetWindowProperties();
      // --- Remember the current coordinates and dimensions of the form
      m_last_x            =m_x;
      m_last_y            =m_y;
      m_last_x_size       =m_x_size;
      m_last_y_size       =m_full_height;
      m_last_auto_xresize =m_auto_xresize_mode;
      m_last_auto_yresize =m_auto_yresize_mode;
      // --- Enable auto resizing of form
      m_auto_xresize_mode=true;
      m_auto_yresize_mode=true;
      // --- Expand the form to the entire chart
      ChangeWindowWidth(m_chart.WidthInPixels()-2);
      ChangeWindowHeight(m_chart.HeightInPixels(m_subwin)-3);
      // --- Update location
      m_x=m_y=1;
      Moving(m_x,m_y);
      // --- Replace the image in the button
      m_button_fullscreen.IconFile((uint)RESOURCE_MINIMIZE_TO_WINDOW);
      m_button_fullscreen.IconFileLocked((uint)RESOURCE_MINIMIZE_TO_WINDOW);
     }
// --- If the window is in full screen size
   else
     {
      // --- Convert to previous window size
      m_is_fullscreen=false;
      // --- Disable auto resizing
      m_auto_xresize_mode=m_last_auto_xresize;
      m_auto_yresize_mode=m_last_auto_yresize;
      // --- If the mode is disabled, then set the previous size
      if(!m_auto_xresize_mode)
         ChangeWindowWidth(m_last_x_size);
      if(!m_auto_yresize_mode)
         ChangeWindowHeight(m_last_y_size);
      // --- Update location
      m_x=m_last_x;
      m_y=m_last_y;
      Moving(m_x,m_y);
      // --- Replace the image in the button
      m_button_fullscreen.IconFile((uint)RESOURCE_FULL_SCREEN);
      m_button_fullscreen.IconFileLocked((uint)RESOURCE_FULL_SCREEN);
     }
// --- Remove focus from a button
   m_button_fullscreen.MouseFocus(false);
   m_button_fullscreen.Update(true);
   ChartRedraw();
   return(true);
  }
//+------------------------------------------------------------------+
// | Checking for window minimize/maximize events |
//+------------------------------------------------------------------+
bool CWindow::OnClickCollapseButton(const int id=WRONG_VALUE,const int index=WRONG_VALUE)
  {
// --- Check element identifier and index if there was an external call
   int check_id    =(id!=WRONG_VALUE)? id : CElementBase::Id();
   int check_index =(index!=WRONG_VALUE)? index : CElementBase::Index();
// --- Exit if indexes do not match
   if(check_id!=m_button_collapse.Id() || check_index!=m_button_collapse.Index())
      return(false);
// --- If the window is maximized
   if(!m_is_minimized)
      Collapse();
   else
      Expand();
// --- Remove focus from a button
   m_button_collapse.MouseFocus(false);
   m_button_collapse.Update(true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Minimizes the window |
//+------------------------------------------------------------------+
void CWindow::Collapse(void)
  {
// --- Replace button
   m_button_collapse.IconFile((uint)RESOURCE_DOWN_THIN_WHITE);
   m_button_collapse.IconFileLocked((uint)RESOURCE_DOWN_THIN_WHITE);
// ---Set and remember size
   CElementBase::YSize(m_caption_height);
   m_canvas.YSize(m_caption_height);
   m_canvas.Resize(m_x_size,m_canvas.YSize());
// --- Form state "Collapsed"
   m_is_minimized=true;
// --- Redraw the window
   Update(true);
// --- Calculate the height of the subwindow
   m_subwindow_height=m_caption_height+3;
// --- If this program is in a subwindow with a fixed height and with a subwindow collapse mode,
// set the size for the program subwindow
   if(m_height_subwindow_mode)
      if(m_rollup_subwindow_mode)
         ChangeSubwindowHeight(m_subwindow_height);
// --- Get the number of the program subwindow
   int subwin=(CElementBase::ProgramType()==PROGRAM_INDICATOR)? ::ChartWindowFind() : m_subwin;
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_WINDOW_COLLAPSE,CElementBase::Id(),subwin,"");
// --- Send a message about the change in the graphical interface
   ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
  }
//+------------------------------------------------------------------+
// | Maximizes the window |
//+------------------------------------------------------------------+
void CWindow::Expand(void)
  {
// --- Replace button
   m_button_collapse.IconFile((uint)RESOURCE_UP_THIN_WHITE);
   m_button_collapse.IconFileLocked((uint)RESOURCE_UP_THIN_WHITE);
// ---Set and remember size
   CElementBase::YSize(m_full_height);
   m_canvas.YSize(m_full_height);
   m_canvas.Resize(m_x_size,m_canvas.YSize());
// --- Form state "Expanded"
   m_is_minimized=false;
// --- Redraw the window
   Update(true);
// --- Calculate the height of the subwindow
   m_subwindow_height=m_full_height+3;
// --- If this is an indicator in a subwindow with a fixed height and with a subwindow collapse mode,
// set the size for the program subwindow
   if(m_height_subwindow_mode)
      if(m_rollup_subwindow_mode)
         ChangeSubwindowHeight(m_subwindow_height);
// --- Get the number of the program subwindow
   int subwin=(CElementBase::ProgramType()==PROGRAM_INDICATOR)? ::ChartWindowFind() : m_subwin;
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_WINDOW_EXPAND,CElementBase::Id(),subwin,"");
// --- Send a message about the change in the graphical interface
   ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
  }
//+------------------------------------------------------------------+
// | Handling a click on the "Tooltips" button |
//+------------------------------------------------------------------+
bool CWindow::OnClickTooltipsButton(const uint id,const uint index)
  {
// --- This button is not needed if the window is a dialog
   if(m_window_type==W_DIALOG)
      return(false);
// --- Exit if indexes do not match
   if(id!=m_button_tooltip.Id() || index!=m_button_tooltip.Index())
      return(false);
// --- Remember the state in the class field
   m_tooltips_button_state=m_button_tooltip.IsPressed();
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_WINDOW_TOOLTIPS,CElementBase::Id(),CElementBase::Index(),"");
   return(true);
  }
//+------------------------------------------------------------------+
// | Controls window sizes |
//+------------------------------------------------------------------+
void CWindow::ResizeWindow(void)
  {
// --- Quit if the window is not available
   if(!CElementBase::IsAvailable())
      return;
// --- Exit if the mouse button was not pressed above the border of the form
   if(m_clamping_area_mouse!=PRESSED_INSIDE_BORDER && m_clamping_area_mouse!=NOT_PRESSED)
      return;
// --- Exit if (1) window resizing mode is disabled or
// (2) window in full screen size or (3) window minimized
   if(!m_xy_resize_mode || m_is_fullscreen || m_is_minimized)
      return;
// --- Coordinates
   int x =m_mouse.RelativeX(m_canvas);
   int y =m_mouse.RelativeY(m_canvas);
// --- Readiness check for changing list widths
   if(!CheckResizePointer(x,y))
      return;
// ---Updating window sizes
   UpdateSize(x,y);
  }
//+------------------------------------------------------------------+
// | Checking readiness for window resizing |
//+------------------------------------------------------------------+
bool CWindow::CheckResizePointer(const int x,const int y)
  {
// --- Determine the current mode index
   m_resize_mode_index=ResizeModeIndex(x,y);
// --- If the cursor is hidden
   if(!m_xy_resize.IsVisible())
     {
      // ---If the mode is defined
      if(m_resize_mode_index!=WRONG_VALUE)
        {
         // --- To determine the index of the displayed picture of the mouse cursor
         int index=WRONG_VALUE;
         // --- If on vertical boundaries
         if(m_resize_mode_index==0 || m_resize_mode_index==1)
            index=0;
         // --- If on horizontal boundaries
         else if(m_resize_mode_index==2)
            index=1;
         // --- Change picture
         m_xy_resize.ChangeImage(0,index);
         // --- Move, redraw and show
         m_xy_resize.Moving(m_mouse.X(),m_mouse.Y());
         m_xy_resize.Update(true);
         m_xy_resize.Reset();
         return(true);
        }
     }
   else
     {
      // ---Move pointer
      if(m_resize_mode_index!=WRONG_VALUE)
         m_xy_resize.Moving(m_mouse.X(),m_mouse.Y());
      // --- Hide pointer
      else if(!m_mouse.LeftButtonState())
        {
         // --- Hide the pointer and reset the variables
         m_xy_resize.Hide();
         ZeroResizeVariables();
        }
      // --- Refresh chart
      m_chart.Redraw();
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
// | Returns the mode index for window resizing |
//+------------------------------------------------------------------+
int CWindow::ResizeModeIndex(const int x,const int y)
  {
// --- Return border index if there is already a capture
   if(m_resize_mode_index!=WRONG_VALUE && m_mouse.LeftButtonState())
      return(m_resize_mode_index);
// --- Thickness, margin and border index
   int width  =5;
   int offset =15;
   int index  =WRONG_VALUE;
// --- Checking focus on the left border
   if(x>0 && x<width && y>m_caption_height+offset && y<m_y_size-offset)
      index=0;
// --- Checking focus on the right border
   else if(x>m_x_size-width && x<m_x_size && y>m_caption_height+offset && y<m_y_size-offset)
      index=1;
// --- Checking focus on the lower border
   else if(y>m_y_size-width && y<m_y_size && x>offset && x<m_x_size-offset)
      index=2;
// --- If the index is received, mark the clicked area
   if(index!=WRONG_VALUE)
      m_clamping_area_mouse=PRESSED_INSIDE_BORDER;
// --- Return area index
   return(index);
  }
//+------------------------------------------------------------------+
// | Updating window sizes |
//+------------------------------------------------------------------+
void CWindow::UpdateSize(const int x,const int y)
  {
// --- If you are finished and the left mouse button is released, reset the values
   if(!m_mouse.LeftButtonState())
     {
      ZeroResizeVariables();
      return;
     }
// --- Exit if capturing and moving the border has not yet started
   int distance=0;
   if((distance=CheckDragWindowBorder(x,y))==0)
      return;
// --- Calculation and resizing of windows
   CalculateAndResizeWindow(distance);
// --- Redraw the window
   Update(true);
// --- Update object position
   Moving(m_x,m_y);
// --- Message that the window has been resized
   if(m_resize_mode_index==2)
      ::EventChartCustom(m_chart_id,ON_WINDOW_CHANGE_YSIZE,(long)CElementBase::Id(),0,"");
   else
      ::EventChartCustom(m_chart_id,ON_WINDOW_CHANGE_XSIZE,(long)CElementBase::Id(),0,"");
  }
//+------------------------------------------------------------------+
// | Window border drag testing |
//+------------------------------------------------------------------+
int CWindow::CheckDragWindowBorder(const int x,const int y)
  {
// --- To determine the moving distance
   int distance=0;
// --- If the border has not yet been captured
   if(m_point_fixed<1)
     {
      // --- If changing the size along the X axis
      if(m_resize_mode_index==0 || m_resize_mode_index==1)
        {
         m_x_fixed     =m_x;
         m_size_fixed  =m_x_size;
         m_point_fixed =x;
        }
      // --- If changing the size along the Y axis
      else if(m_resize_mode_index==2)
        {
         m_size_fixed  =m_y_size;
         m_point_fixed =y;
        }
      // --- Send a message to determine available elements
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
      return(0);
     }
// ---If it's the left border
   if(m_resize_mode_index==0)
      distance=m_mouse.X()-m_x_fixed;
// ---If this is the right border
   else if(m_resize_mode_index==1)
      distance=x-m_point_fixed;
// ---If this is the lower limit
   else if(m_resize_mode_index==2)
      distance=y-m_point_fixed;
// --- Return moving distance
   return(distance);
  }
//+------------------------------------------------------------------+
// | Calculation and resizing of windows |
//+------------------------------------------------------------------+
void CWindow::CalculateAndResizeWindow(const int distance)
  {
// ---Left border
   if(m_resize_mode_index==0)
     {
      int new_x      =m_x_fixed+distance-m_point_fixed;
      int new_x_size =m_size_fixed-distance+m_point_fixed;
      // --- Quit if we exceed the limits
      if(new_x<1 || new_x_size<=m_minimum_x_size)
         return;
      // --- Coordinates
      CElementBase::X(new_x);
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,new_x);
      // ---Set and remember size
      CElementBase::XSize(new_x_size);
      m_canvas.XSize(new_x_size);
      m_canvas.Resize(new_x_size,m_canvas.YSize());
     }
// --- Right border
   else if(m_resize_mode_index==1)
     {
      int gap_x2     =m_chart_width-m_mouse.X()-(m_size_fixed-m_point_fixed);
      int new_x_size =m_size_fixed+distance;
      // --- Quit if we exceed the limits
      if(gap_x2<1 || new_x_size<=m_minimum_x_size)
         return;
      // ---Set and remember size
      CElementBase::XSize(new_x_size);
      m_canvas.XSize(new_x_size);
      m_canvas.Resize(new_x_size,m_canvas.YSize());
     }
// --- Lower limit
   else if(m_resize_mode_index==2)
     {
      int gap_y2=m_chart_height-m_mouse.Y()-(m_size_fixed-m_point_fixed);
      int new_y_size=m_size_fixed+distance;
      // --- Quit if we exceed the limits
      if(gap_y2<2 || new_y_size<=m_minimum_y_size)
         return;
      // ---Set and remember size
      m_full_height=new_y_size;
      CElementBase::YSize(new_y_size);
      m_canvas.YSize(new_y_size);
      m_canvas.Resize(m_canvas.XSize(),new_y_size);
     }
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CWindow::Draw(void)
  {
// --- Draw background
   DrawBackground();
// --- Draw foreground
   DrawForeground();
// --- Draw a picture
   CElement::DrawImage();
// --- Draw text
   CElement::DrawText();
  }
//+------------------------------------------------------------------+
// | Draws the background |
//+------------------------------------------------------------------+
void CWindow::DrawBackground(void)
  {
   uint clr=(CElementBase::IsLocked())? m_caption_color_locked :(CElementBase::MouseFocus())? m_caption_color_hover : m_caption_color;
   CElement::m_canvas.Erase(::ColorToARGB(clr,m_alpha));
  }
//+------------------------------------------------------------------+
// | Draws the foreground |
//+------------------------------------------------------------------+
void CWindow::DrawForeground(void)
  {
// --- Exit if the window is minimized
   if(m_is_minimized)
      return;
// --- Coordinates
   int x  =1;
   int y  =m_caption_height;
   int x2 =m_x_size-2;
   int y2 =m_y_size-2;
// --- Draw a filled rectangle
   m_canvas.FillRectangle(x,y,x2,y2,::ColorToARGB(m_back_color,(m_transparent_only_caption)?(uchar)255 : m_alpha));
  }
//+------------------------------------------------------------------+
