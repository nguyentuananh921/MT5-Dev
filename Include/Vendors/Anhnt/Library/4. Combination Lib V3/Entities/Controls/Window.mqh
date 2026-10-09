//+------------------------------------------------------------------+
//|                                                       Window.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
#property strict

#ifndef CWINDOW_MQH
#define CWINDOW_MQH
 #include "ButtonTriggered.mqh"
 #include "Pointer.mqh"
#ifndef CWINDOW_MQH_DECLARATION
#define CWINDOW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Form class for controls                                          |
//+------------------------------------------------------------------+
class CWindow : public CGElement
 {
  private:
    CButton           m_button_close;
    CButton           m_button_fullscreen;
    CButton           m_button_collapse;
    CButtonTriggered  m_button_tooltip;
    CPointer          m_xy_resize;
    bool              m_xy_resize_mode;
    int               m_resize_mode_index;
    int               m_x_fixed;
    int               m_size_fixed;
    int               m_point_fixed;
    bool              m_is_movable;
    bool              m_is_minimized;
    bool              m_is_fullscreen;
    int               m_last_x;
    int               m_last_y;
    int               m_last_x_size;
    int               m_last_y_size;
    int               m_minimum_x_size;
    int               m_minimum_y_size;
    ENUM_WINDOW_TYPE  m_window_type;
    int               m_full_height;
    int               m_caption_height;
    color             m_caption_color;
    color             m_caption_color_hover;
    color             m_caption_color_locked;
    color             m_back_color;
    string            m_label_text;
    bool              m_close_button;
    bool              m_fullscreen_button;
    bool              m_collapse_button;
    bool              m_tooltips_button;
    int               m_right_limit;
    int               m_size_fixing_x;
    int               m_size_fixing_y;
    ENUM_MOUSE_STATE  m_clamping_area_mouse;

    bool              CreateButtons(void);
    bool              CreateButton(CButton &button_obj,const string suffix,const uint icon_index,const bool is_close);
    void              ArrangeButtons(void);
    void              Collapse(void);
    void              Expand(void);
    bool              IsCaptionButton(CGBaseObj *obj);
    bool              CreateResizePointer(void);
    int               ResizeModeIndex(const int x,const int y);
    void              UpdateResizePointer(const int mouse_x,const int mouse_y);
    void              CalculateAndResizeWindow(const int mouse_x,const int mouse_y);
    void              ZeroResizeVariables(void);
    void              AfterResize(void);
  protected:
    virtual void      InitColors(void);
    virtual void      DrawContent(void);
    virtual void      OnPress(const int x,const int y);
    virtual void      OnMove(const int x,const int y);
    virtual void      OnRelease(const int x,const int y);
  public:
    bool              CreateWindow(const long chart_id,const int subwin,const string caption_text,const int x,const int y,const int w,const int h);
    CButton          *GetCloseButtonPointer(void)                     { return(::GetPointer(m_button_close));      }
    CButton          *GetFullscreenButtonPointer(void)                { return(::GetPointer(m_button_fullscreen)); }
    CButton          *GetCollapseButtonPointer(void)                  { return(::GetPointer(m_button_collapse));   }
    CButtonTriggered *GetTooltipButtonPointer(void)                   { return(::GetPointer(m_button_tooltip));    }
    ENUM_WINDOW_TYPE  WindowType(void)                          const { return(m_window_type);                     }
    void              WindowType(const ENUM_WINDOW_TYPE flag)         { m_window_type=flag;                        }
    void              CaptionHeight(const int height)                 { m_caption_height=height;                   }
    int               CaptionHeight(void)                       const { return(m_caption_height);                  }
    void              CaptionColor(const color clr)                   { m_caption_color=clr;                       }
    void              CaptionColorHover(const color clr)              { m_caption_color_hover=clr;                 }
    void              CaptionColorLocked(const color clr)             { m_caption_color_locked=clr;                }
    void              BackColor(const color clr)                      { m_back_color=clr;                          }
    void              CloseButtonIsUsed(const bool state)             { m_close_button=state;                      }
    bool              CloseButtonIsUsed(void)                   const { return(m_close_button);                    }
    void              FullscreenButtonIsUsed(const bool state)        { m_fullscreen_button=state;                 }
    bool              FullscreenButtonIsUsed(void)              const { return(m_fullscreen_button);               }
    void              CollapseButtonIsUsed(const bool state)          { m_collapse_button=state;                   }
    bool              CollapseButtonIsUsed(void)                const { return(m_collapse_button);                 }
    void              TooltipsButtonIsUsed(const bool state)          { m_tooltips_button=state;                   }
    bool              TooltipsButtonIsUsed(void)                const { return(m_tooltips_button);                 }
    bool              TooltipButtonState(void)                  const { return(m_button_tooltip.State());          }
    bool              IsMovable(void)                           const { return(m_is_movable);                      }
    void              IsMovable(const bool state)                     { m_is_movable=state;                        }
    bool              IsMinimized(void)                         const { return(m_is_minimized);                    }
    void              MinimumXSize(const int x_size)                  { m_minimum_x_size=x_size;                   }
    void              MinimumYSize(const int y_size)                  { m_minimum_y_size=y_size;                   }
    bool              ResizeMode(void)                          const { return(m_xy_resize_mode);                  }
    void              ResizeMode(const bool state)                    { m_xy_resize_mode=state;                    }
    bool              ResizeState(void)                         const { return(m_clamping_area_mouse==PRESSED_INSIDE_BORDER); }
    uint              DefaultIcon(void);
    void              IconFile(const uint resource_index);
    bool              CursorInsideCaption(const int x,const int y);
    void              OpenWindow(void);
    void              CloseWindow(void);
    bool              OnClickCloseButton(const long id);
    bool              OnClickFullScreenButton(const long id);
    bool              OnClickCollapseButton(const long id);
    bool              OnClickTooltipsButton(const long id);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CWindow(void);
                    ~CWindow(void) {}
 };
#endif // CWINDOW_MQH_DECLARATION
#ifndef CWINDOW_MQH_IMPLEMENTATION
#define CWINDOW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor - Kazharski defaults                                 |
//+------------------------------------------------------------------+
CWindow::CWindow(void) : m_is_movable(false),
                         m_is_minimized(false),
                         m_is_fullscreen(false),
                         m_last_x(0),
                         m_last_y(0),
                         m_last_x_size(0),
                         m_last_y_size(0),
                         m_minimum_x_size(0),
                         m_minimum_y_size(0),
                         m_window_type(W_MAIN),
                         m_full_height(0),
                         m_caption_height(WINDOW_CAPTION_HEIGHT),
                         m_caption_color(C'77,118,201'),
                         m_caption_color_hover(C'77,118,201'),
                         m_caption_color_locked(C'188,165,219'),
                         m_back_color(clrWhiteSmoke),
                         m_label_text(""),
                         m_close_button(false),
                         m_fullscreen_button(false),
                         m_collapse_button(false),
                         m_tooltips_button(false),
                         m_right_limit(0),
                         m_size_fixing_x(0),
                         m_size_fixing_y(0),
                         m_clamping_area_mouse(NOT_PRESSED),
                         m_xy_resize_mode(false),
                         m_resize_mode_index(WRONG_VALUE),
                         m_x_fixed(0),
                         m_size_fixed(0),
                         m_point_fixed(0)
 {
 }
//+------------------------------------------------------------------+
//| Whole canvas in caption color, body is filled in DrawContent     |
//+------------------------------------------------------------------+
void CWindow::InitColors(void)
 {
  this.m_color_background.InitColors(this.m_caption_color,this.m_caption_color_hover,this.m_caption_color,this.m_caption_color_locked);
  this.m_color_foreground.InitColors(clrWhite,clrWhite,clrWhite,clrBlack);
  this.m_color_border.InitColors(this.m_caption_color,this.m_caption_color_hover,this.m_caption_color,this.m_caption_color_locked);
  this.m_color_background_act.InitColors(this.m_caption_color,this.m_caption_color_hover,this.m_caption_color,this.m_caption_color_locked);
  this.m_color_foreground_act.InitColors(clrWhite,clrWhite,clrWhite,clrBlack);
  this.m_color_border_act.InitColors(this.m_caption_color,this.m_caption_color_hover,this.m_caption_color,this.m_caption_color_locked);
 }
//+------------------------------------------------------------------+
//| Program icon by program type                                     |
//+------------------------------------------------------------------+
uint CWindow::DefaultIcon(void)
 {
  ENUM_PROGRAM_TYPE type=(ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE);
  if(type==PROGRAM_SCRIPT)
     return(IMAGE_RESOURCE_BMP16_SCRIPT_BMP);
  if(type==PROGRAM_INDICATOR)
     return(IMAGE_RESOURCE_BMP16_INDICATOR_BMP);
  return(IMAGE_RESOURCE_BMP16_ADVISOR_BMP);
 }
//+------------------------------------------------------------------+
//| Caption icon in image group 0                                    |
//+------------------------------------------------------------------+
void CWindow::IconFile(const uint resource_index)
 {
  if(this.ImagesGroupTotal()<1)
     this.AddImagesGroup(5,2);
  if(this.ImagesTotal(0)<1)
     this.AddImage(0,resource_index);
  else
     this.SetImage(0,0,resource_index);
  this.ChangeImage(0,0);
 }
//+------------------------------------------------------------------+
//| Creates the form, then its caption buttons as children           |
//+------------------------------------------------------------------+
bool CWindow::CreateWindow(const long chart_id,const int subwin,const string caption_text,const int x,const int y,const int w,const int h)
 {
  this.m_label_text=caption_text;
  this.m_full_height=h;
  if(this.m_window_type==W_POPUP)
     this.m_is_movable=false;
  this.m_minimum_x_size=(this.m_minimum_x_size<200) ? w : this.m_minimum_x_size;
  this.m_minimum_y_size=(this.m_minimum_y_size<200) ? h : this.m_minimum_y_size;
  if(this.ImagesTotal(0)<1)
     this.IconFile(this.DefaultIcon());
  if(!this.Create(chart_id,subwin,"window_"+caption_text,x,y,w,h))
     return(false);
  if(!this.CreateButtons())
     return(false);
  return(this.CreateResizePointer());
 }
//+------------------------------------------------------------------+
//| Close, fullscreen, collapse, tooltip - right to left             |
//+------------------------------------------------------------------+
bool CWindow::CreateButtons(void)
 {
  if((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)==PROGRAM_SCRIPT || this.m_window_type==W_POPUP)
     return(true);
  bool dialog=(this.m_window_type==W_DIALOG);
  if(this.m_close_button && !this.CreateButton(this.m_button_close,"_close",IMAGE_RESOURCE_BMP16_CLOSE_WHITE_BMP,true))
     return(false);
  if(this.m_fullscreen_button && !dialog && !this.CreateButton(this.m_button_fullscreen,"_fullscreen",IMAGE_RESOURCE_BMP16_FULL_SCREEN_BMP,false))
     return(false);
  if(this.m_collapse_button && !dialog && !this.CreateButton(this.m_button_collapse,"_collapse",IMAGE_RESOURCE_BMP16_UP_THIN_WHITE_BMP,false))
     return(false);
  if(this.m_tooltips_button && !dialog)
    {
     if(!this.CreateButton(this.m_button_tooltip,"_tooltip",IMAGE_RESOURCE_BMP16_HELP_LIGHT_BMP,false))
        return(false);
     this.m_button_tooltip.IconFilePressed(IMAGE_RESOURCE_BMP16_HELP_LIGHT_BMP);
     this.m_button_tooltip.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_HELP_LIGHT_BMP);
    }
  this.ArrangeButtons();
  return(true);
 }
//+------------------------------------------------------------------+
//| One 20x20 caption button with Kazharski colors                   |
//+------------------------------------------------------------------+
bool CWindow::CreateButton(CButton &button_obj,const string suffix,const uint icon_index,const bool is_close)
 {
  this.AddChild(&button_obj);
  button_obj.IconFile(icon_index);
  button_obj.IconFileLocked(icon_index);
  int y_gap=(this.m_caption_height-WINDOW_BUTTON_SIZE)/2;
  if(!button_obj.Create(this.m_chart_id,this.m_subwindow,this.Name()+suffix,0,y_gap,WINDOW_BUTTON_SIZE,WINDOW_BUTTON_SIZE))
     return(false);
  color hover  =(is_close ? C'242,27,45'  : C'90,139,232');
  color pressed=(is_close ? C'149,68,116' : C'67,103,173');
  button_obj.GetBackColorControl().InitColors(this.m_caption_color,hover,pressed,this.m_caption_color_locked);
  button_obj.GetBorderColorControl().InitColors(this.m_caption_color,this.m_caption_color,this.m_caption_color,this.m_caption_color_locked);
  button_obj.GetBackColorActControl().InitColors(pressed,pressed,pressed,this.m_caption_color_locked);
  button_obj.GetBorderColorActControl().InitColors(this.m_caption_color,this.m_caption_color,this.m_caption_color,this.m_caption_color_locked);
  button_obj.ColorChange(COLOR_STATE_DEFAULT);
  button_obj.Draw(false);
  return(true);
 }
//+------------------------------------------------------------------+
//| Keeps the caption buttons anchored to the right edge             |
//+------------------------------------------------------------------+
void CWindow::ArrangeButtons(void)
 {
  int y_gap=(this.m_caption_height-WINDOW_BUTTON_SIZE)/2;
  int i=0;
  this.m_right_limit=0;
  CButton *buttons[4];
  buttons[0]=::GetPointer(this.m_button_close);
  buttons[1]=::GetPointer(this.m_button_fullscreen);
  buttons[2]=::GetPointer(this.m_button_collapse);
  buttons[3]=::GetPointer(this.m_button_tooltip);
  for(int b=0; b<4; b++)
    {
     if(buttons[b].Parent()!=::GetPointer(this))
        continue;
     this.m_right_limit+=WINDOW_BUTTON_SIZE-((i<3) ? 0 : 1);
     i++;
     buttons[b].Move(this.m_x+this.m_x_size-this.m_right_limit,this.m_y+y_gap);
    }
  this.SetControlAreaX(0);
  this.SetControlAreaY(0);
  this.SetControlAreaWidth(this.m_x_size-this.m_right_limit);
  this.SetControlAreaHeight(this.m_caption_height);
 }
//+------------------------------------------------------------------+
//| True for the four caption buttons                                |
//+------------------------------------------------------------------+
bool CWindow::IsCaptionButton(CGBaseObj *obj)
 {
  return(obj==::GetPointer(this.m_button_close) || obj==::GetPointer(this.m_button_fullscreen) ||
         obj==::GetPointer(this.m_button_collapse) || obj==::GetPointer(this.m_button_tooltip));
 }
//+------------------------------------------------------------------+
//| Body below the caption and the caption text                      |
//+------------------------------------------------------------------+
void CWindow::DrawContent(void)
 {
  if(!this.m_is_minimized)
     this.m_canvas.FillRectangle(1,this.m_caption_height,this.m_x_size-2,this.m_y_size-2,::ColorToARGB(this.m_back_color,255));
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  this.m_canvas.TextOut(24,this.m_caption_height/2,this.m_label_text,::ColorToARGB(this.ForeColor(),255),TA_LEFT|TA_VCENTER);
 }
//+------------------------------------------------------------------+
//| Caption left of the buttons = DoEasy control area                |
//+------------------------------------------------------------------+
bool CWindow::CursorInsideCaption(const int x,const int y)
 {
  return(this.CursorInsideControlArea(x,y));
 }
//+------------------------------------------------------------------+
//| Press on the caption starts moving the window                    |
//+------------------------------------------------------------------+
void CWindow::OnPress(const int x,const int y)
 {
  CGElement::OnPress(x,y);
  if(this.m_resize_mode_index!=WRONG_VALUE)
    {
     this.m_clamping_area_mouse=PRESSED_INSIDE_BORDER;
     this.m_x_fixed    =this.m_x;
     this.m_size_fixed =(this.m_resize_mode_index==2 ? this.m_y_size : this.m_x_size);
     this.m_point_fixed=(this.m_resize_mode_index==2 ? y : x);
     return;
    }
  if(this.m_is_movable && !this.m_is_fullscreen && this.CursorInsideCaption(x,y))
    {
     this.m_clamping_area_mouse=PRESSED_INSIDE_HEADER;
     this.m_size_fixing_x=x-this.m_x;
     this.m_size_fixing_y=y-this.m_y;
     return;
    }
  this.m_clamping_area_mouse=PRESSED_INSIDE;
 }
//+------------------------------------------------------------------+
//| Moving with the cursor, kept inside the chart                    |
//+------------------------------------------------------------------+
void CWindow::OnMove(const int x,const int y)
 {
  if(this.m_clamping_area_mouse==PRESSED_INSIDE_BORDER)
    {
     this.CalculateAndResizeWindow(x,y);
     return;
    }
  if(this.m_clamping_area_mouse!=PRESSED_INSIDE_HEADER)
     return;
  int chart_w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
  int chart_h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,this.m_subwindow);
  int nx=x-this.m_size_fixing_x;
  int ny=y-this.m_size_fixing_y;
  if(nx>chart_w-this.m_x_size)
     nx=chart_w-this.m_x_size;
  if(nx<0)
     nx=0;
  if(ny>chart_h-this.m_caption_height)
     ny=chart_h-this.m_caption_height;
  if(ny<0)
     ny=0;
  if(nx==this.m_x && ny==this.m_y)
     return;
  this.Move(nx,ny);
  ::ChartRedraw(this.m_chart_id);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWindow::OnRelease(const int x,const int y)
 {
  if(this.m_clamping_area_mouse==PRESSED_INSIDE_BORDER)
    {
     if(this.m_resize_mode_index==2)
        this.SendEvent(ON_WINDOW_CHANGE_YSIZE,this.m_y_size,this.m_label_text);
     else
        this.SendEvent(ON_WINDOW_CHANGE_XSIZE,this.m_x_size,this.m_label_text);
    }
  this.m_clamping_area_mouse=NOT_PRESSED;
  this.ZeroResizeVariables();
  CGElement::OnRelease(x,y);
 }
//+------------------------------------------------------------------+
//| Kazharski resize cursor: 23x23, hotspot (13,11)                  |
//+------------------------------------------------------------------+
bool CWindow::CreateResizePointer(void)
 {
  if(!this.m_xy_resize_mode || this.m_window_type==W_POPUP)
     return(true);
  this.SetBorderResizeAreaLeft(5);
  this.SetBorderResizeAreaRight(5);
  this.SetBorderResizeAreaBottom(5);
  this.m_xy_resize.XGap(13);
  this.m_xy_resize.YGap(11);
  this.m_xy_resize.Type(MP_WINDOW_RESIZE);
  return(this.m_xy_resize.CreatePointer(this.m_chart_id,this.m_subwindow,23,23));
 }
//+------------------------------------------------------------------+
//| DoEasy resize area under x,y: 0 left, 1 right, 2 bottom, else -1 |
//+------------------------------------------------------------------+
int CWindow::ResizeModeIndex(const int x,const int y)
 {
  if(this.CursorInsideResizeLeftArea(x,y))
     return(0);
  if(this.CursorInsideResizeRightArea(x,y))
     return(1);
  if(this.CursorInsideResizeBottomArea(x,y))
     return(2);
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Shows the pointer on a border, follows the cursor, hides it      |
//+------------------------------------------------------------------+
void CWindow::UpdateResizePointer(const int mouse_x,const int mouse_y)
 {
  if(this.m_clamping_area_mouse!=PRESSED_INSIDE_BORDER)
     this.m_resize_mode_index=this.ResizeModeIndex(mouse_x,mouse_y);
  if(this.m_resize_mode_index==WRONG_VALUE)
    {
     if(this.m_xy_resize.IsVisible())
       {
        this.m_xy_resize.Hide();
        ::ChartRedraw(this.m_chart_id);
       }
     return;
    }
  this.m_xy_resize.ChangeImage(0,(this.m_resize_mode_index==2 ? 1 : 0));
  this.m_xy_resize.Moving(mouse_x,mouse_y);
  if(!this.m_xy_resize.IsVisible())
    {
     this.m_xy_resize.Draw(false);
     this.m_xy_resize.Show();
    }
  ::ChartRedraw(this.m_chart_id);
 }
//+------------------------------------------------------------------+
//| Left border moves x and width, right width, bottom height        |
//+------------------------------------------------------------------+
void CWindow::CalculateAndResizeWindow(const int mouse_x,const int mouse_y)
 {
  int chart_w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
  int chart_h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,this.m_subwindow);
  if(this.m_resize_mode_index==0)
    {
     int distance  =mouse_x-this.m_point_fixed;
     int new_x     =this.m_x_fixed+distance;
     int new_x_size=this.m_size_fixed-distance;
     if(new_x<0 || new_x_size<this.m_minimum_x_size || new_x_size==this.m_x_size)
        return;
     this.Move(new_x,this.m_y);
     this.Resize(new_x_size,this.m_y_size);
    }
  else if(this.m_resize_mode_index==1)
    {
     int new_x_size=this.m_size_fixed+mouse_x-this.m_point_fixed;
     if(this.m_x+new_x_size>chart_w || new_x_size<this.m_minimum_x_size || new_x_size==this.m_x_size)
        return;
     this.Resize(new_x_size,this.m_y_size);
    }
  else if(this.m_resize_mode_index==2)
    {
     int new_y_size=this.m_size_fixed+mouse_y-this.m_point_fixed;
     if(this.m_y+new_y_size>chart_h || new_y_size<this.m_minimum_y_size || new_y_size==this.m_y_size)
        return;
     this.Resize(this.m_x_size,new_y_size);
     this.m_full_height=new_y_size;
    }
  else
     return;
  this.AfterResize();
 }
//+------------------------------------------------------------------+
//| Resetting variables                                              |
//+------------------------------------------------------------------+
void CWindow::ZeroResizeVariables(void)
 {
  this.m_x_fixed    =0;
  this.m_size_fixed =0;
  this.m_point_fixed=0;
 }
//+------------------------------------------------------------------+
//| Buttons to the right edge, auto-resize children follow           |
//+------------------------------------------------------------------+
void CWindow::AfterResize(void)
 {
  this.ArrangeButtons();
  this.ChangeWidthByRightWindowSide();
  this.ChangeHeightByBottomWindowSide();
  this.Draw(false);
  ::ChartRedraw(this.m_chart_id);
 }
//+------------------------------------------------------------------+
//| Main window: remove the program, dialog: hide and shout          |
//+------------------------------------------------------------------+
bool CWindow::OnClickCloseButton(const long id)
 {
  if(this.m_button_close.Parent()!=::GetPointer(this) || id!=this.m_button_close.ObjectID())
     return(false);
  if(this.m_window_type==W_MAIN)
    {
     ENUM_PROGRAM_TYPE type=(ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE);
     if(type==PROGRAM_EXPERT)
       {
        if(::MessageBox("You want to remove the program from the chart?",NULL,MB_YESNO|MB_ICONQUESTION)==IDYES)
          {
           ::Print(__FUNCTION__," > The program was removed from the chart with your consent!");
           ::ExpertRemove();
          }
       }
     else if(type==PROGRAM_INDICATOR)
       {
        if(::ChartIndicatorDelete(this.m_chart_id,::ChartWindowFind(),::MQLInfoString(MQL_PROGRAM_NAME)))
           ::Print(__FUNCTION__," > The program was removed from the chart with your consent!");
       }
     return(true);
    }
  this.CloseWindow();
  return(true);
 }
//+------------------------------------------------------------------+
//| Show and shout; dparam = window type so a popup locks nothing    |
//+------------------------------------------------------------------+
void CWindow::OpenWindow(void)
 {
  this.Show();
  ::ChartRedraw(this.m_chart_id);
  this.SendEvent(ON_OPEN_DIALOG_BOX,this.m_window_type,this.m_label_text);
 }
//+------------------------------------------------------------------+
//| Hide and shout; dparam = window type                             |
//+------------------------------------------------------------------+
void CWindow::CloseWindow(void)
 {
  this.Hide();
  ::ChartRedraw(this.m_chart_id);
  this.SendEvent(ON_CLOSE_DIALOG_BOX,this.m_window_type,this.m_label_text);
 }
//+------------------------------------------------------------------+
//| To full chart size or back to the previous size                  |
//+------------------------------------------------------------------+
bool CWindow::OnClickFullScreenButton(const long id)
 {
  if(this.m_button_fullscreen.Parent()!=::GetPointer(this) || id!=this.m_button_fullscreen.ObjectID())
     return(false);
  if(this.m_is_minimized)
     return(true);
  if(!this.m_is_fullscreen)
    {
     this.m_last_x     =this.m_x;
     this.m_last_y     =this.m_y;
     this.m_last_x_size=this.m_x_size;
     this.m_last_y_size=this.m_y_size;
     int chart_w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
     int chart_h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,this.m_subwindow);
     this.Move(0,0);
     this.Resize(chart_w-1,chart_h-1);
     this.m_full_height=chart_h-1;
     this.m_is_fullscreen=true;
     this.m_button_fullscreen.IconFile(IMAGE_RESOURCE_BMP16_MINIMIZE_TO_WINDOW_BMP);
     this.m_button_fullscreen.IconFileLocked(IMAGE_RESOURCE_BMP16_MINIMIZE_TO_WINDOW_BMP);
    }
  else
    {
     this.Move(this.m_last_x,this.m_last_y);
     this.Resize(this.m_last_x_size,this.m_last_y_size);
     this.m_full_height=this.m_last_y_size;
     this.m_is_fullscreen=false;
     this.m_button_fullscreen.IconFile(IMAGE_RESOURCE_BMP16_FULL_SCREEN_BMP);
     this.m_button_fullscreen.IconFileLocked(IMAGE_RESOURCE_BMP16_FULL_SCREEN_BMP);
    }
  this.m_button_fullscreen.Draw(false);
  this.AfterResize();
  this.SendEvent(ON_WINDOW_CHANGE_XSIZE,this.m_x_size,this.m_label_text);
  return(true);
 }
//+------------------------------------------------------------------+
//| Collapse or expand the window                                    |
//+------------------------------------------------------------------+
bool CWindow::OnClickCollapseButton(const long id)
 {
  if(this.m_button_collapse.Parent()!=::GetPointer(this) || id!=this.m_button_collapse.ObjectID())
     return(false);
  if(this.m_is_minimized)
     this.Expand();
  else
     this.Collapse();
  ::ChartRedraw(this.m_chart_id);
  return(true);
 }
//+------------------------------------------------------------------+
//| Only the caption stays, the content is hidden                    |
//+------------------------------------------------------------------+
void CWindow::Collapse(void)
 {
  this.m_full_height=this.m_y_size;
  this.m_is_minimized=true;
  for(int i=0; i<this.ChildrenTotal(); i++)
    {
     CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
     if(child!=NULL && !this.IsCaptionButton(child))
        child.Hide();
    }
  this.Resize(this.m_x_size,this.m_caption_height);
  this.m_button_collapse.IconFile(IMAGE_RESOURCE_BMP16_DOWN_THIN_WHITE_BMP);
  this.m_button_collapse.IconFileLocked(IMAGE_RESOURCE_BMP16_DOWN_THIN_WHITE_BMP);
  this.m_button_collapse.Draw(false);
  this.SendEvent(ON_WINDOW_COLLAPSE,this.m_subwindow,this.m_label_text);
 }
//+------------------------------------------------------------------+
//| Full height back, the content is shown again                     |
//+------------------------------------------------------------------+
void CWindow::Expand(void)
 {
  this.m_is_minimized=false;
  this.Resize(this.m_x_size,this.m_full_height);
  for(int i=0; i<this.ChildrenTotal(); i++)
    {
     CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
     if(child!=NULL && !this.IsCaptionButton(child))
        child.Show();
    }
  this.m_button_collapse.IconFile(IMAGE_RESOURCE_BMP16_UP_THIN_WHITE_BMP);
  this.m_button_collapse.IconFileLocked(IMAGE_RESOURCE_BMP16_UP_THIN_WHITE_BMP);
  this.m_button_collapse.Draw(false);
  this.SendEvent(ON_WINDOW_EXPAND,this.m_subwindow,this.m_label_text);
 }
//+------------------------------------------------------------------+
//| The tooltip button flips its own state, the window shouts it     |
//+------------------------------------------------------------------+
bool CWindow::OnClickTooltipsButton(const long id)
 {
  if(this.m_button_tooltip.Parent()!=::GetPointer(this) || id!=this.m_button_tooltip.ObjectID())
     return(false);
  this.SendEvent(ON_WINDOW_TOOLTIPS,(this.m_button_tooltip.State() ? 1 : 0),this.m_label_text);
  return(true);
 }
//+------------------------------------------------------------------+
//| Children and mouse first, then clicks of own caption buttons     |
//+------------------------------------------------------------------+
void CWindow::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(this.m_window_type==W_POPUP && id==CHARTEVENT_MOUSE_MOVE && this.IsVisible() && !this.m_mouse_focus)
    {
     this.CloseWindow();
     return;
    }
  if(id==CHARTEVENT_MOUSE_MOVE && this.m_xy_resize_mode && this.m_window_type!=W_POPUP && this.IsVisible() &&
     !this.m_is_locked && !this.m_is_fullscreen && !this.m_is_minimized && this.m_clamping_area_mouse!=PRESSED_INSIDE_HEADER)
     this.UpdateResizePointer(s_mouse.X(),s_mouse.Y());
  if(id!=CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     return;
  if(this.OnClickCloseButton(lparam))
     return;
  if(this.OnClickFullScreenButton(lparam))
     return;
  if(this.OnClickCollapseButton(lparam))
     return;
  this.OnClickTooltipsButton(lparam);
 }
#endif // CWINDOW_MQH_IMPLEMENTATION
#endif // CWINDOW_MQH
