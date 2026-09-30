//+------------------------------------------------------------------+
//|                                                       Scroll.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Link                       https://www.mql5.com/en/articles/2943  |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CSCROLL_MQH
#define CSCROLL_MQH
 #include "Button.mqh"
#ifndef CSCROLL_MQH_DECLARATION
#define CSCROLL_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Base class for creating a scrollbar                              |
//+------------------------------------------------------------------+
class CScroll : public CGElement
 {
  protected:
    CButton           m_button_inc;
    CButton           m_button_dec;
    int               m_area_width;
    int               m_area_length;
    uint              m_inc_file;
    uint              m_inc_file_locked;
    uint              m_inc_file_pressed;
    uint              m_dec_file;
    uint              m_dec_file_locked;
    uint              m_dec_file_pressed;
    bool              m_thumb_focus;
    bool              m_thumb_dragging;
    color             m_thumb_color;
    color             m_thumb_color_hover;
    color             m_thumb_color_pressed;
    int               m_items_total;
    int               m_visible_items_total;
    int               m_thumb_x;
    int               m_thumb_y;
    int               m_thumb_width;
    int               m_thumb_length;
    int               m_thumb_min_length;
    double            m_thumb_step_size;
    double            m_thumb_steps_total;
    int               m_thumb_size_fixing;
    int               m_current_pos;

    virtual bool      IsVertical(void)                      const { return true;                   }
    virtual void      InitColors(void);
    virtual void      DrawContent(void);
    virtual void      OnPress(const int x,const int y);
    virtual void      OnMove(const int x,const int y);
    virtual void      OnRelease(const int x,const int y);
    virtual void      MouseActiveAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam);
    uint              ThumbColorCurrent(void);
    bool              CheckThumbFocus(const int x,const int y);
    bool              CalculateThumbSize(void);
    void              CalculateThumbBoundaries(int &x1,int &y1,int &x2,int &y2);
    void              CalculateThumbCoord(void);
    bool              CreateScrollButton(CButton &button_obj,const int index);
    bool              SetPos(const int pos);
  public:
    bool              CreateScroll(const long chart_id,const int subwin,const string name,const int x,const int y,
                                   const int w,const int h,const int items_total,const int visible_items_total);
    CButton          *GetIncButtonPointer(void)                   { return(::GetPointer(m_button_inc)); }
    CButton          *GetDecButtonPointer(void)                   { return(::GetPointer(m_button_dec)); }
    void              ScrollWidth(const int width)                { m_area_width=width;                 }
    int               ScrollWidth(void)                     const { return(m_area_width);               }
    void              IncFile(const uint resource_index)          { m_inc_file=resource_index;          }
    void              IncFileLocked(const uint resource_index)    { m_inc_file_locked=resource_index;   }
    void              IncFilePressed(const uint resource_index)   { m_inc_file_pressed=resource_index;  }
    void              DecFile(const uint resource_index)          { m_dec_file=resource_index;          }
    void              DecFileLocked(const uint resource_index)    { m_dec_file_locked=resource_index;   }
    void              DecFilePressed(const uint resource_index)   { m_dec_file_pressed=resource_index;  }
    void              ThumbColor(const color clr)                 { m_thumb_color=clr;                  }
    void              ThumbColorHover(const color clr)            { m_thumb_color_hover=clr;            }
    void              ThumbColorPressed(const color clr)          { m_thumb_color_pressed=clr;          }
    int               CurrentPos(void)                      const { return(m_current_pos);              }
    bool              IsScroll(void)                        const { return(m_items_total>m_visible_items_total); }
    void              MovingThumb(const int pos);
    void              ChangeThumbSize(const int items_total,const int visible_items_total);
    bool              OnClickScrollInc(const long id);
    bool              OnClickScrollDec(const long id);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CScroll(void);
                    ~CScroll(void) {}
 };
#endif // CSCROLL_MQH_DECLARATION
#ifndef CSCROLL_MQH_IMPLEMENTATION
#define CSCROLL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor - Kazharski defaults                                 |
//+------------------------------------------------------------------+
CScroll::CScroll(void) : m_area_width(15),
                         m_area_length(0),
                         m_inc_file(INT_MAX),
                         m_inc_file_locked(INT_MAX),
                         m_inc_file_pressed(INT_MAX),
                         m_dec_file(INT_MAX),
                         m_dec_file_locked(INT_MAX),
                         m_dec_file_pressed(INT_MAX),
                         m_thumb_focus(false),
                         m_thumb_dragging(false),
                         m_thumb_color(C'205,205,205'),
                         m_thumb_color_hover(C'166,166,166'),
                         m_thumb_color_pressed(C'96,96,96'),
                         m_items_total(1),
                         m_visible_items_total(1),
                         m_thumb_x(0),
                         m_thumb_y(0),
                         m_thumb_width(0),
                         m_thumb_length(0),
                         m_thumb_min_length(15),
                         m_thumb_step_size(0),
                         m_thumb_steps_total(1),
                         m_thumb_size_fixing(0),
                         m_current_pos(0)
 {
 }
//+------------------------------------------------------------------+
//| Kazharski scrollbar background C'240,240,240', no visible border |
//+------------------------------------------------------------------+
void CScroll::InitColors(void)
 {
  this.m_color_background.InitColors(C'240,240,240',C'240,240,240',C'240,240,240',C'240,240,240');
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(C'240,240,240',C'240,240,240',C'240,240,240',C'240,240,240');
  this.m_color_background_act.InitColors(C'240,240,240',C'240,240,240',C'240,240,240',C'240,240,240');
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(C'240,240,240',C'240,240,240',C'240,240,240',C'240,240,240');
 }
//+------------------------------------------------------------------+
//| Creates the scrollbar and its two buttons as children            |
//+------------------------------------------------------------------+
bool CScroll::CreateScroll(const long chart_id,const int subwin,const string name,const int x,const int y,
                           const int w,const int h,const int items_total,const int visible_items_total)
 {
  this.m_area_width         =(this.IsVertical() ? w : h);
  this.m_area_length        =(this.IsVertical() ? h : w);
  this.m_items_total        =(items_total<1) ? 1 : items_total;
  this.m_visible_items_total=(visible_items_total>0) ? visible_items_total : 1;
  this.m_thumb_width        =this.m_area_width;
  this.m_thumb_steps_total  =(this.IsScroll() ? this.m_items_total-this.m_visible_items_total : 1);
  this.CalculateThumbSize();
  this.CalculateThumbCoord();
  if(!this.Create(chart_id,subwin,name,x,y,w,h))
     return(false);
  if(!this.CreateScrollButton(this.m_button_inc,0))
     return(false);
  if(!this.CreateScrollButton(this.m_button_dec,1))
     return(false);
  return(true);
 }
//+------------------------------------------------------------------+
//| Up/left (index 0) or down/right (index 1) button                 |
//+------------------------------------------------------------------+
bool CScroll::CreateScrollButton(CButton &button_obj,const int index)
 {
  int  x=0,y=0;
  uint file=0,file_locked=0,file_pressed=0;
  if(index==0)
    {
     if(this.IsVertical())
       {
        file        =(this.m_inc_file==INT_MAX)         ? IMAGE_RESOURCE_BMP16_SCROLL_UP_BLACK_BMP : this.m_inc_file;
        file_locked =(this.m_inc_file_locked==INT_MAX)  ? IMAGE_RESOURCE_BMP16_SCROLL_UP_BLACK_BMP : this.m_inc_file_locked;
        file_pressed=(this.m_inc_file_pressed==INT_MAX) ? IMAGE_RESOURCE_BMP16_SCROLL_UP_WHITE_BMP : this.m_inc_file_pressed;
       }
     else
       {
        file        =(this.m_inc_file==INT_MAX)         ? IMAGE_RESOURCE_BMP16_SCROLL_LEFT_BLACK_BMP : this.m_inc_file;
        file_locked =(this.m_inc_file_locked==INT_MAX)  ? IMAGE_RESOURCE_BMP16_SCROLL_LEFT_BLACK_BMP : this.m_inc_file_locked;
        file_pressed=(this.m_inc_file_pressed==INT_MAX) ? IMAGE_RESOURCE_BMP16_SCROLL_LEFT_WHITE_BMP : this.m_inc_file_pressed;
       }
    }
  else
    {
     if(this.IsVertical())
       {
        x=0;
        y=this.m_area_length-this.m_thumb_width;
        file        =(this.m_dec_file==INT_MAX)         ? IMAGE_RESOURCE_BMP16_SCROLL_DOWN_BLACK_BMP : this.m_dec_file;
        file_locked =(this.m_dec_file_locked==INT_MAX)  ? IMAGE_RESOURCE_BMP16_SCROLL_DOWN_BLACK_BMP : this.m_dec_file_locked;
        file_pressed=(this.m_dec_file_pressed==INT_MAX) ? IMAGE_RESOURCE_BMP16_SCROLL_DOWN_WHITE_BMP : this.m_dec_file_pressed;
       }
     else
       {
        x=this.m_area_length-this.m_thumb_width;
        y=0;
        file        =(this.m_dec_file==INT_MAX)         ? IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_BLACK_BMP : this.m_dec_file;
        file_locked =(this.m_dec_file_locked==INT_MAX)  ? IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_BLACK_BMP : this.m_dec_file_locked;
        file_pressed=(this.m_dec_file_pressed==INT_MAX) ? IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_WHITE_BMP : this.m_dec_file_pressed;
       }
    }
  this.AddChild(&button_obj);
  button_obj.IconFile(file);
  button_obj.IconFileLocked(file_locked);
  button_obj.IconFilePressed(file_pressed);
  button_obj.IconFilePressedLocked(file_locked);
  string suffix=(index==0 ? "_inc" : "_dec");
  if(!button_obj.Create(this.m_chart_id,this.m_subwindow,this.Name()+suffix,x,y,this.m_thumb_width,this.m_thumb_width))
     return(false);
  color back=C'240,240,240';
  button_obj.GetBackColorControl().InitColors(back,C'218,218,218',this.m_thumb_color_pressed,clrLightGray);
  button_obj.GetBorderColorControl().InitColors(back,C'218,218,218',this.m_thumb_color_pressed,clrLightGray);
  button_obj.GetBackColorActControl().InitColors(back,C'218,218,218',this.m_thumb_color_pressed,clrLightGray);
  button_obj.GetBorderColorActControl().InitColors(back,C'218,218,218',this.m_thumb_color_pressed,clrLightGray);
  button_obj.ColorChange(COLOR_STATE_DEFAULT);
  button_obj.Draw(false);
  return(true);
 }
//+------------------------------------------------------------------+
//| Current slider color                                             |
//+------------------------------------------------------------------+
uint CScroll::ThumbColorCurrent(void)
 {
  color clr=this.m_thumb_color;
  if(this.m_thumb_dragging)
     clr=this.m_thumb_color_pressed;
  else if(this.m_thumb_focus)
     clr=this.m_thumb_color_hover;
  return(::ColorToARGB(clr,255));
 }
//+------------------------------------------------------------------+
//| Checking focus above the slider, x/y local to the scrollbar      |
//+------------------------------------------------------------------+
bool CScroll::CheckThumbFocus(const int x,const int y)
 {
  bool focus=false;
  if(this.IsVertical())
     focus=(x>=this.m_thumb_x && x<this.m_thumb_x+this.m_thumb_width && y>=this.m_thumb_y && y<this.m_thumb_y+this.m_thumb_length);
  else
     focus=(x>=this.m_thumb_x && x<this.m_thumb_x+this.m_thumb_length && y>=this.m_thumb_y && y<this.m_thumb_y+this.m_thumb_width);
  if(focus==this.m_thumb_focus)
     return(false);
  this.m_thumb_focus=focus;
  return(true);
 }
//+------------------------------------------------------------------+
//| Slider length proportional to the visible part of the list       |
//+------------------------------------------------------------------+
bool CScroll::CalculateThumbSize(void)
 {
  int track=this.m_area_length-this.m_thumb_width*2;
  if(track<1)
     return(false);
  int length=(int)(track*(double)this.m_visible_items_total/this.m_items_total);
  this.m_thumb_length=(length<this.m_thumb_min_length ? this.m_thumb_min_length : (length>track ? track : length));
  this.m_thumb_step_size=(this.m_thumb_steps_total>0 ? (track-this.m_thumb_length)/this.m_thumb_steps_total : 0);
  return(true);
 }
//+------------------------------------------------------------------+
//| Calculating scrollbar slider boundaries                          |
//+------------------------------------------------------------------+
void CScroll::CalculateThumbBoundaries(int &x1,int &y1,int &x2,int &y2)
 {
  if(this.IsVertical())
    {
     x1=0;
     y1=this.m_thumb_y;
     x2=x1+this.m_thumb_width;
     y2=y1+this.m_thumb_length;
    }
  else
    {
     x1=this.m_thumb_x;
     y1=0;
     x2=x1+this.m_thumb_length;
     y2=y1+this.m_thumb_width;
    }
 }
//+------------------------------------------------------------------+
//| Slider coordinate from the current position                      |
//+------------------------------------------------------------------+
void CScroll::CalculateThumbCoord(void)
 {
  int coord=(int)(this.m_thumb_width+this.m_current_pos*this.m_thumb_step_size);
  int max  =this.m_area_length-this.m_thumb_width-this.m_thumb_length;
  if(coord>max)
     coord=max;
  if(coord<this.m_thumb_width)
     coord=this.m_thumb_width;
  if(this.IsVertical())
    {
     this.m_thumb_x=0;
     this.m_thumb_y=coord;
    }
  else
    {
     this.m_thumb_x=coord;
     this.m_thumb_y=0;
    }
 }
//+------------------------------------------------------------------+
//| Draws the slider over the background                             |
//+------------------------------------------------------------------+
void CScroll::DrawContent(void)
 {
  if(!this.IsScroll())
     return;
  int x1=0,y1=0,x2=0,y2=0;
  this.CalculateThumbBoundaries(x1,y1,x2,y2);
  this.m_canvas.FillRectangle(x1,y1,x2-1,y2-1,this.ThumbColorCurrent());
 }
//+------------------------------------------------------------------+
//| Sets the position, returns true and shouts if it changed         |
//+------------------------------------------------------------------+
bool CScroll::SetPos(const int pos)
 {
  int max_pos=(this.IsScroll() ? this.m_items_total-this.m_visible_items_total : 0);
  int check_pos=(pos<0 ? 0 : (pos>max_pos ? max_pos : pos));
  if(check_pos==this.m_current_pos)
     return(false);
  this.m_current_pos=check_pos;
  this.SendEvent(ON_SCROLL_CHANGE,this.m_current_pos,"");
  return(true);
 }
//+------------------------------------------------------------------+
//| Moves the slider to the specified position                       |
//+------------------------------------------------------------------+
void CScroll::MovingThumb(const int pos)
 {
  this.SetPos(pos);
  this.CalculateThumbCoord();
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Changing the slider size according to new conditions             |
//+------------------------------------------------------------------+
void CScroll::ChangeThumbSize(const int items_total,const int visible_items_total)
 {
  this.m_items_total        =(items_total<1) ? 1 : items_total;
  this.m_visible_items_total=(visible_items_total>0) ? visible_items_total : 1;
  this.m_thumb_steps_total  =(this.IsScroll() ? this.m_items_total-this.m_visible_items_total : 1);
  this.CalculateThumbSize();
  this.SetPos(this.m_current_pos);
  this.CalculateThumbCoord();
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Up/left button click                                             |
//+------------------------------------------------------------------+
bool CScroll::OnClickScrollInc(const long id)
 {
  if(id!=this.m_button_inc.ObjectID() || !this.IsScroll())
     return(false);
  this.MovingThumb(this.m_current_pos-1);
  return(true);
 }
//+------------------------------------------------------------------+
//| Down/right button click                                          |
//+------------------------------------------------------------------+
bool CScroll::OnClickScrollDec(const long id)
 {
  if(id!=this.m_button_dec.ObjectID() || !this.IsScroll())
     return(false);
  this.MovingThumb(this.m_current_pos+1);
  return(true);
 }
//+------------------------------------------------------------------+
//| Press on the slider starts dragging                              |
//+------------------------------------------------------------------+
void CScroll::OnPress(const int x,const int y)
 {
  int lx=x-this.m_x;
  int ly=y-this.m_y;
  this.CheckThumbFocus(lx,ly);
  if(!this.m_thumb_focus || !this.IsScroll())
     return;
  this.m_thumb_dragging=true;
  this.m_thumb_size_fixing=(this.IsVertical() ? ly-this.m_thumb_y : lx-this.m_thumb_x);
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Dragging follows the cursor even outside the scrollbar           |
//+------------------------------------------------------------------+
void CScroll::OnMove(const int x,const int y)
 {
  if(!this.m_thumb_dragging || this.m_thumb_step_size<=0)
     return;
  int local=(this.IsVertical() ? y-this.m_y : x-this.m_x);
  int coord=local-this.m_thumb_size_fixing;
  int max  =this.m_area_length-this.m_thumb_width-this.m_thumb_length;
  if(coord>max)
     coord=max;
  if(coord<this.m_thumb_width)
     coord=this.m_thumb_width;
  if(this.IsVertical())
     this.m_thumb_y=coord;
  else
     this.m_thumb_x=coord;
  this.SetPos((int)::round((coord-this.m_thumb_width)/this.m_thumb_step_size));
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Release ends dragging and snaps the slider to its position       |
//+------------------------------------------------------------------+
void CScroll::OnRelease(const int x,const int y)
 {
  this.m_thumb_dragging=false;
  this.m_thumb_size_fixing=0;
  this.CheckThumbFocus(x-this.m_x,y-this.m_y);
  this.CalculateThumbCoord();
  CGElement::OnRelease(x,y);
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Slider hover, own buttons clicks, then the base mouse handling   |
//+------------------------------------------------------------------+
void CScroll::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
    {
     if(!this.OnClickScrollInc(lparam))
        this.OnClickScrollDec(lparam);
     return;
    }
  if(id!=CHARTEVENT_MOUSE_MOVE || this.m_thumb_dragging || !this.m_is_available)
     return;
  if(this.CheckThumbFocus(s_mouse.X()-this.m_x,s_mouse.Y()-this.m_y))
     this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Wheel over the scrollbar moves by one position per notch         |
//+------------------------------------------------------------------+
void CScroll::MouseActiveAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  if(!this.IsScroll())
     return;
  this.MovingThumb(this.m_current_pos+(s_mouse.DeltaWheel()>0 ? -1 : 1));
 }
#endif // CSCROLL_MQH_IMPLEMENTATION
#endif // CSCROLL_MQH
