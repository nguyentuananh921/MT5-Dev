//+------------------------------------------------------------------+
//|                                                     GElement.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CGELEMENT_MQH
#define CGELEMENT_MQH
 #include <Canvas\Canvas.mqh>
 #include "GBaseObj.mqh"
 #include "..\Graph\Properties\ColorElement.mqh"
 #include "..\..\Services\Colors.mqh"
 #include "..\..\Services\Mouse.mqh"
 #include "..\Graph\Properties\Image.mqh"
 #include "..\Defines\GUIDefines.mqh"
#ifndef CGELEMENT_MQH_DECLARATION
#define CGELEMENT_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Base class of canvas-based graphical elements                    |
 //+------------------------------------------------------------------+
 class CGElement : public CGBaseObj
  {
   private:
    static int        s_id_counter;
    static int        s_tools_lock_count;
    static bool       s_saved_mouse_scroll;
    static bool       s_saved_context_menu;
    static bool       s_saved_crosshair;
   protected:
    CCanvas           m_canvas;
    int               m_x;
    int               m_y;
    int               m_x_size;
    int               m_y_size;
    int               m_x_gap;
    int               m_y_gap;
    CColorElement     m_color_background;
    CColorElement     m_color_foreground;
    CColorElement     m_color_border;
    CColorElement     m_color_background_act;
    CColorElement     m_color_foreground_act;
    CColorElement     m_color_border_act;
    bool              m_state;
    ENUM_COLOR_STATE  m_color_state;
    string            m_font;
    int               m_font_size;
    struct EImagesGroup
      {
       CImage            m_image[];
       int               m_x_gap;
       int               m_y_gap;
       int               m_selected_image;
      };
    EImagesGroup      m_images_group[];
    bool              m_mouse_focus;
    bool              m_focused;
    bool              m_is_pressed;
    bool              m_is_locked;
    bool              m_is_available;
    bool              m_prev_left;
    bool              m_chart_tools_locked;
    bool              m_lock_chart_tools;    // false: focus/press never lock the chart (display-only elements)
    static CMouse     s_mouse;
    ENUM_MOUSE_EVENT  m_mouse_event_last;
    int               m_press_area;
    int               m_act_shift_left;
    int               m_act_shift_top;
    int               m_act_shift_right;
    int               m_act_shift_bottom;
    int               m_control_area_x;
    int               m_control_area_y;
    int               m_control_area_width;
    int               m_control_area_height;
    int               m_border_resize_area_left;
    int               m_border_resize_area_right;
    int               m_border_resize_area_top;
    int               m_border_resize_area_bottom;

    int               MouseArea(const int x,const int y);
    ENUM_MOUSE_FORM_STATE MouseFormState(const int area,const bool inside,const bool pressed,const bool wheel,const bool released);
    void              OnMouseEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    virtual void      MouseOutsideNotPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)        {}
    virtual void      MouseOutsidePressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)           {}
    virtual void      MouseOutsideWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)             {}
    virtual void      MouseInsideNotPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)         {}
    virtual void      MouseInsidePressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)            {}
    virtual void      MouseInsideWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)              {}
    virtual void      MouseActiveAreaNotPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)     {}
    virtual void      MouseActiveAreaPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)        {}
    virtual void      MouseActiveAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)          {}
    virtual void      MouseActiveAreaReleasedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)       {}
    virtual void      MouseScrollAreaNotPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)     {}
    virtual void      MouseScrollAreaPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)        {}
    virtual void      MouseScrollAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)          {}
    virtual void      MouseControlAreaNotPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)    {}
    virtual void      MouseControlAreaPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)       {}
    virtual void      MouseControlAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)         {}
    virtual void      MouseResizeAreaNotPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)     {}
    virtual void      MouseResizeAreaPressedHandler(const int id,const long &lparam,const double &dparam,const string &sparam)        {}
    virtual void      MouseResizeAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)          {}
    void              SetChartTools(const bool enable);
    void              LockChartTools(const bool flag)       { this.m_lock_chart_tools=flag;    }
    void              DrawFrame(void);
    bool              SendEvent(const ushort event_id,const double dparam,const string sparam);
    bool              CheckOutOfRange(const uint group_index,const uint image_index);
    color             BackColor(void);
    color             ForeColor(void);
    color             BorderColor(void);
    virtual void      InitColors(void);
    virtual void      DrawImage(void);
    virtual void      DrawContent(void)                           {}
    virtual void      OnFocus(void);
    virtual void      OnBlur(void);
    virtual void      OnPress(const int x,const int y);
    virtual void      OnMove(const int x,const int y)             {}
    virtual void      OnRelease(const int x,const int y);
   public:
    bool              Create(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h);
    void              Destroy(void);
    virtual void      Draw(const bool chart_redraw);
    void              Move(const int x,const int y);
    void              Resize(const int w,const int h);
    virtual void      ChangeWidthByRightWindowSide(void);
    virtual void      ChangeHeightByBottomWindowSide(void);
    virtual void      Show(void);
    virtual void      Hide(void);
    void              BringToTop(void);
    int               X(void)                              const { return this.m_x;           }
    int               Y(void)                               const { return this.m_y;           }
    int               Width(void)                           const { return this.m_x_size;           }
    int               Height(void)                          const { return this.m_y_size;           }
    void              Font(const string font)                     { this.m_font=font;               }
    string            Font(void)                            const { return this.m_font;             }
    void              FontSize(const int font_size)               { this.m_font_size=font_size;     }
    int               FontSize(void)                        const { return this.m_font_size;        }
    virtual bool      CheckMouseFocus(const int x,const int y);
    bool              MouseFocus(void)                      const { return this.m_mouse_focus; }
    ENUM_MOUSE_EVENT  MouseEventLast(void)                  const { return this.m_mouse_event_last; }
    int               RightEdge(void)                       const { return this.m_x+this.m_x_size-1; }
    int               BottomEdge(void)                      const { return this.m_y+this.m_y_size-1; }
    void              SetActiveAreaShift(const int left_shift,const int bottom_shift,const int right_shift,const int top_shift);
    int               ActiveAreaLeftShift(void)             const { return this.m_act_shift_left;   }
    int               ActiveAreaRightShift(void)            const { return this.m_act_shift_right;  }
    int               ActiveAreaTopShift(void)              const { return this.m_act_shift_top;    }
    int               ActiveAreaBottomShift(void)           const { return this.m_act_shift_bottom; }
    int               ActiveAreaLeft(void)                  const { return this.m_x+this.m_act_shift_left;         }
    int               ActiveAreaRight(void)                 const { return this.RightEdge()-this.m_act_shift_right; }
    int               ActiveAreaTop(void)                   const { return this.m_y+this.m_act_shift_top;          }
    int               ActiveAreaBottom(void)                const { return this.BottomEdge()-this.m_act_shift_bottom; }
    void              SetControlAreaX(const int value)            { this.m_control_area_x=value;      }
    void              SetControlAreaY(const int value)            { this.m_control_area_y=value;      }
    void              SetControlAreaWidth(const int value)        { this.m_control_area_width=value;  }
    void              SetControlAreaHeight(const int value)       { this.m_control_area_height=value; }
    int               ControlAreaXShift(void)               const { return this.m_control_area_x;      }
    int               ControlAreaYShift(void)               const { return this.m_control_area_y;      }
    int               ControlAreaWidth(void)                const { return this.m_control_area_width;  }
    int               ControlAreaHeight(void)               const { return this.m_control_area_height; }
    int               ControlAreaLeft(void)                 const { return this.m_x+this.m_control_area_x;              }
    int               ControlAreaRight(void)                const { return this.ControlAreaLeft()+this.m_control_area_width;  }
    int               ControlAreaTop(void)                  const { return this.m_y+this.m_control_area_y;              }
    int               ControlAreaBottom(void)               const { return this.ControlAreaTop()+this.m_control_area_height; }
    void              SetBorderResizeAreaLeft(const int value)    { this.m_border_resize_area_left=value;   }
    void              SetBorderResizeAreaRight(const int value)   { this.m_border_resize_area_right=value;  }
    void              SetBorderResizeAreaTop(const int value)     { this.m_border_resize_area_top=value;    }
    void              SetBorderResizeAreaBottom(const int value)  { this.m_border_resize_area_bottom=value; }
    int               BorderResizeAreaLeft(void)            const { return this.m_border_resize_area_left;   }
    int               BorderResizeAreaRight(void)           const { return this.m_border_resize_area_right;  }
    int               BorderResizeAreaTop(void)             const { return this.m_border_resize_area_top;    }
    int               BorderResizeAreaBottom(void)          const { return this.m_border_resize_area_bottom; }
    bool              CursorInsideElement(const int x,const int y);
    bool              CursorInsideActiveArea(const int x,const int y);
    bool              CursorInsideControlArea(const int x,const int y);
    bool              CursorInsideResizeTopArea(const int x,const int y);
    bool              CursorInsideResizeBottomArea(const int x,const int y);
    bool              CursorInsideResizeLeftArea(const int x,const int y);
    bool              CursorInsideResizeRightArea(const int x,const int y);
    bool              CursorInsideResizeTopLeftArea(const int x,const int y);
    bool              CursorInsideResizeTopRightArea(const int x,const int y);
    bool              CursorInsideResizeBottomLeftArea(const int x,const int y);
    bool              CursorInsideResizeBottomRightArea(const int x,const int y);
    bool              ColorChange(const ENUM_COLOR_STATE state);
    CColorElement    *GetBackColorControl(void)                   { return &this.m_color_background;     }
    CColorElement    *GetForeColorControl(void)                   { return &this.m_color_foreground;     }
    CColorElement    *GetBorderColorControl(void)                 { return &this.m_color_border;         }
    CColorElement    *GetBackColorActControl(void)                { return &this.m_color_background_act; }
    CColorElement    *GetForeColorActControl(void)                { return &this.m_color_foreground_act; }
    CColorElement    *GetBorderColorActControl(void)              { return &this.m_color_border_act;     }
    bool              IsLocked(void)                        const { return this.m_is_locked;   }
    virtual void      IsLocked(const bool state);
    bool              IsAvailable(void)                     const { return this.m_is_available; }
    virtual void      IsAvailable(const bool state);
    bool              HasDescendant(const long element_id);
    bool              State(void)                           const { return this.m_state;       }
    void              SetState(const bool state);
    uint              ImagesGroupTotal(void)                const { return(::ArraySize(this.m_images_group)); }
    int               ImagesTotal(const uint group_index);
    void              AddImagesGroup(const int x_gap,const int y_gap);
    void              AddImage(const uint group_index,const string file_path);
    void              AddImage(const uint group_index,const uint resource_index);
    void              SetImage(const uint group_index,const uint image_index,const string file_path);
    void              SetImage(const uint group_index,const uint image_index,const uint resource_index);
    void              ChangeImage(const uint group_index,const uint image_index);
    int               SelectedImage(const uint group_index=0);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    virtual void      OnTimerEvent(void);
                     CGElement(void);
                    ~CGElement(void);
  };
#endif // CGELEMENT_MQH_DECLARATION
#ifndef CGELEMENT_MQH_IMPLEMENTATION
#define CGELEMENT_MQH_IMPLEMENTATION
 int  CGElement::s_id_counter=0;
 int  CGElement::s_tools_lock_count=0;
 bool CGElement::s_saved_mouse_scroll=true;
 bool CGElement::s_saved_context_menu=true;
 bool CGElement::s_saved_crosshair=true;
 CMouse CGElement::s_mouse;
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 CGElement::CGElement(void) : m_x(0),m_y(0),m_x_size(0),m_y_size(0),m_x_gap(0),m_y_gap(0),m_state(false),m_color_state(COLOR_STATE_DEFAULT),m_font(DEF_FONT),m_font_size(DEF_FONT_SIZE),
                             m_mouse_focus(false),m_focused(false),m_is_pressed(false),m_is_locked(false),m_is_available(true),m_prev_left(false),
                             m_chart_tools_locked(false),m_lock_chart_tools(true),m_mouse_event_last(MOUSE_EVENT_NO_EVENT),m_press_area(0),
                             m_act_shift_left(0),m_act_shift_top(0),m_act_shift_right(0),m_act_shift_bottom(0),
                             m_control_area_x(0),m_control_area_y(0),m_control_area_width(0),m_control_area_height(0),
                             m_border_resize_area_left(0),m_border_resize_area_right(0),m_border_resize_area_top(0),m_border_resize_area_bottom(0)
  {
   this.SetObjectID(++s_id_counter);
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 CGElement::~CGElement(void)
  {
   this.Destroy();
  }
 //+------------------------------------------------------------------+
 //| x,y are offsets from the parent when AddChild was called first   |
 //+------------------------------------------------------------------+
 bool CGElement::Create(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h)
  {
   this.SetChartID(chart_id);
   this.m_subwindow=subwin;
   this.SetName(::StringSubstr(this.m_name_prefix+(string)this.ObjectID()+"_"+name,0,63));
   CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
   this.m_x_gap=x;
   this.m_y_gap=y;
   this.m_x=(parent!=NULL ? parent.X()+x : x);
   this.m_y=(parent!=NULL ? parent.Y()+y : y);
   this.m_x_size=w;
   this.m_y_size=h;
   this.m_shift_y=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,subwin);
   if(!this.m_canvas.CreateBitmapLabel(this.m_chart_id,subwin,this.Name(),this.m_x,this.m_y,w,h,COLOR_FORMAT_ARGB_NORMALIZE))
     return false;
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_MOUSE_MOVE,true);
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_MOUSE_WHEEL,true);
   this.InitColors();
   this.ColorChange(COLOR_STATE_DEFAULT);
   //--- Hidden before Create, or a child of a hidden parent: born hidden
   if(!this.m_visible || (parent!=NULL && !parent.IsVisible()))
    {
     this.m_visible=false;
     ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
    }
   this.Draw(this.m_visible);
   return true;
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::Destroy(void)
  {
   this.SetChartTools(true);
   this.m_canvas.Destroy();
  }
 //+------------------------------------------------------------------+
 //| New canvas size, redrawn without chart redraw                    |
 //+------------------------------------------------------------------+
 void CGElement::Resize(const int w,const int h)
  {
   if(w<1 || h<1 || (w==this.m_x_size && h==this.m_y_size))
      return;
   this.m_x_size=w;
   this.m_y_size=h;
   this.m_canvas.Resize(w,h);
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_XSIZE,w);
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_YSIZE,h);
   this.Draw(false);
  }
 //+------------------------------------------------------------------+
 //| Parent width changed: auto-resize controls override, default     |
 //| just passes it down the subtree                                  |
 //+------------------------------------------------------------------+
 void CGElement::ChangeWidthByRightWindowSide(void)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL)
         child.ChangeWidthByRightWindowSide();
     }
  }
 //+------------------------------------------------------------------+
 //| Parent height changed: same as above                             |
 //+------------------------------------------------------------------+
 void CGElement::ChangeHeightByBottomWindowSide(void)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL)
         child.ChangeHeightByBottomWindowSide();
     }
  }
 //+------------------------------------------------------------------+
 //| Kazharski IsLocked: blocked colors, no mouse, whole subtree      |
 //+------------------------------------------------------------------+
 void CGElement::IsLocked(const bool state)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL)
         child.IsLocked(state);
     }
   if(this.m_is_locked==state)
      return;
   this.m_is_locked=state;
   if(state)
    {
     this.m_focused=false;
     this.m_is_pressed=false;
     this.SetChartTools(true);
    }
   this.ColorChange(state ? COLOR_STATE_BLOCKED : COLOR_STATE_DEFAULT);
   this.Draw(false);
  }
 //+------------------------------------------------------------------+
 //| Kazharski IsAvailable: no mouse, colors kept, whole subtree      |
 //+------------------------------------------------------------------+
 void CGElement::IsAvailable(const bool state)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL)
         child.IsAvailable(state);
     }
   if(this.m_is_available==state)
      return;
   this.m_is_available=state;
   if(state)
      return;
   this.m_is_pressed=false;
   if(!this.m_focused)
      return;
   this.m_focused=false;
   this.SetChartTools(true);
   this.OnBlur();
  }
 //+------------------------------------------------------------------+
 //| True if element_id is a child or a deeper descendant             |
 //+------------------------------------------------------------------+
 bool CGElement::HasDescendant(const long element_id)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL && (child.ObjectID()==element_id || child.HasDescendant(element_id)))
         return(true);
     }
   return(false);
  }
 //+------------------------------------------------------------------+
 //| Show itself first, then the subtree so children stay on top      |
 //+------------------------------------------------------------------+
 void CGElement::Show(void)
  {
   this.m_visible=true;
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL)
         child.Show();
     }
  }
 //+------------------------------------------------------------------+
 //| Hide itself and the whole subtree                                |
 //+------------------------------------------------------------------+
 void CGElement::Hide(void)
  {
   this.m_visible=false;
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   //--- Hidden under the mouse: it never gets the leave event, give the chart tools back now
   if(this.m_focused || this.m_is_pressed)
    {
     this.m_focused   =false;
     this.m_is_pressed=false;
     this.SetChartTools(true);
    }
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL)
         child.Hide();
     }
  }
 //--- DoEasy BringToTop: re-show the visible subtree on top, hidden elements stay hidden
 void CGElement::BringToTop(void)
  {
   if(!this.m_visible)
      return;
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
      if(child!=NULL)
         child.BringToTop();
     }
  }
 //+------------------------------------------------------------------+
 //| Move to chart coordinates x,y and drag all children along        |
 //+------------------------------------------------------------------+
 void CGElement::Move(const int x,const int y)
  {
   this.m_x=x;
   this.m_y=y;
   CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
   if(parent!=NULL)
     {
     this.m_x_gap=x-parent.X();
     this.m_y_gap=y-parent.Y();
    }
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_XDISTANCE,x);
   ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_YDISTANCE,y);
   for(int i=0; i<this.ChildrenTotal(); i++)
    {
     CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
     if(child==NULL)
        continue;
     child.Move(x+child.m_x_gap,y+child.m_y_gap);
    }
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::InitColors(void)
  {
   this.m_color_background.InitColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
   this.m_color_border.InitColors(clrDarkGray,clrDarkGray,clrDarkGray,clrLightGray);
   this.m_color_background_act.InitColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
   this.m_color_border_act.InitColors(clrDarkGray,clrDarkGray,clrDarkGray,clrLightGray);
  }
 //+------------------------------------------------------------------+
 //| Returns true if any color of the set in use changed              |
 //+------------------------------------------------------------------+
 bool CGElement::ColorChange(const ENUM_COLOR_STATE state)
  {
   this.m_color_state=state;
   bool back      =this.m_color_background.SetCurrentAs(state);
   bool fore      =this.m_color_foreground.SetCurrentAs(state);
   bool border    =this.m_color_border.SetCurrentAs(state);
   bool back_act  =this.m_color_background_act.SetCurrentAs(state);
   bool fore_act  =this.m_color_foreground_act.SetCurrentAs(state);
   bool border_act=this.m_color_border_act.SetCurrentAs(state);
   if(this.m_state)
      return(back_act || fore_act || border_act);
   return(back || fore || border);
  }
 //+------------------------------------------------------------------+
 //| Current colors of the set in use (normal or activated)           |
 //+------------------------------------------------------------------+
 color CGElement::BackColor(void)
  {
   return(this.m_state ? this.m_color_background_act.GetCurrent() : this.m_color_background.GetCurrent());
  }
 color CGElement::ForeColor(void)
  {
   return(this.m_state ? this.m_color_foreground_act.GetCurrent() : this.m_color_foreground.GetCurrent());
  }
 color CGElement::BorderColor(void)
  {
   return(this.m_state ? this.m_color_border_act.GetCurrent() : this.m_color_border.GetCurrent());
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::SetState(const bool state)
  {
   if(this.m_state==state)
      return;
   this.m_state=state;
   this.Draw(true);
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::DrawFrame(void)
  {
   color back=this.BackColor();
   this.m_canvas.Erase(back==clrNONE ? 0 : ::ColorToARGB(back,255));
   color border=this.BorderColor();
   if(border!=clrNONE)
      this.m_canvas.Rectangle(0,0,this.m_x_size-1,this.m_y_size-1,::ColorToARGB(border,255));
  }
 //+------------------------------------------------------------------+
 //| Kazharski order: background, border, image, text                 |
 //+------------------------------------------------------------------+
 void CGElement::Draw(const bool chart_redraw)
  {
   this.DrawFrame();
   this.DrawImage();
   this.DrawContent();
   this.m_canvas.Update(chart_redraw);
  }
 //+------------------------------------------------------------------+
 //| Check out of range                                               |
 //+------------------------------------------------------------------+
 bool CGElement::CheckOutOfRange(const uint group_index,const uint image_index)
  {
   uint images_group_total=::ArraySize(this.m_images_group);
   if(images_group_total<1 || group_index>=images_group_total)
      return(false);
   uint images_total=::ArraySize(this.m_images_group[group_index].m_image);
   if(images_total<1 || image_index>=images_total)
      return(false);
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Returns the number of images in the specified group              |
 //+------------------------------------------------------------------+
 int CGElement::ImagesTotal(const uint group_index)
  {
   uint images_group_total=::ArraySize(this.m_images_group);
   if(images_group_total<1 || group_index>=images_group_total)
      return(WRONG_VALUE);
   return(::ArraySize(this.m_images_group[group_index].m_image));
  }
 //+------------------------------------------------------------------+
 //| Adding a group of images                                         |
 //+------------------------------------------------------------------+
 void CGElement::AddImagesGroup(const int x_gap,const int y_gap)
  {
   uint images_group_total=::ArraySize(this.m_images_group);
   ::ArrayResize(this.m_images_group,images_group_total+1);
   this.m_images_group[images_group_total].m_x_gap=x_gap;
   this.m_images_group[images_group_total].m_y_gap=y_gap;
   this.m_images_group[images_group_total].m_selected_image=0;
  }
 //+------------------------------------------------------------------+
 //| Adding an image (resource path) to the specified group           |
 //+------------------------------------------------------------------+
 void CGElement::AddImage(const uint group_index,const string file_path)
  {
   uint images_group_total=::ArraySize(this.m_images_group);
   if(images_group_total<1)
    {
     ::Print(__FUNCTION__," > You can add a group of images using methods CGElement::AddImagesGroup()");
     return;
    }
   uint check_group_index=(group_index<images_group_total) ? group_index : images_group_total-1;
   uint images_total=::ArraySize(this.m_images_group[check_group_index].m_image);
   ::ArrayResize(this.m_images_group[check_group_index].m_image,images_total+1);
   this.m_images_group[check_group_index].m_image[images_total].ReadImageData(file_path);
  }
 //+------------------------------------------------------------------+
 //| Adding an image (ImageDataDefine index) to the specified group   |
 //+------------------------------------------------------------------+
 void CGElement::AddImage(const uint group_index,const uint resource_index)
  {
   uint images_group_total=::ArraySize(this.m_images_group);
   if(images_group_total<1)
    {
     ::Print(__FUNCTION__," > You can add a group of images using methods CGElement::AddImagesGroup()");
     return;
    }
   uint check_group_index=(group_index<images_group_total) ? group_index : images_group_total-1;
   uint images_total=::ArraySize(this.m_images_group[check_group_index].m_image);
   ::ArrayResize(this.m_images_group[check_group_index].m_image,images_total+1);
   this.m_images_group[check_group_index].m_image[images_total].ReadImageData(resource_index);
  }
 //+------------------------------------------------------------------+
 //| Replacing an image (resource path)                               |
 //+------------------------------------------------------------------+
 void CGElement::SetImage(const uint group_index,const uint image_index,const string file_path)
  {
   if(!this.CheckOutOfRange(group_index,image_index))
      return;
   this.m_images_group[group_index].m_image[image_index].DeleteImageData();
   this.m_images_group[group_index].m_image[image_index].ReadImageData(file_path);
  }
 //+------------------------------------------------------------------+
 //| Replacing an image (ImageDataDefine index)                       |
 //+------------------------------------------------------------------+
 void CGElement::SetImage(const uint group_index,const uint image_index,const uint resource_index)
  {
   if(!this.CheckOutOfRange(group_index,image_index))
      return;
   this.m_images_group[group_index].m_image[image_index].DeleteImageData();
   this.m_images_group[group_index].m_image[image_index].ReadImageData(resource_index);
  }
 //+------------------------------------------------------------------+
 //| Switch image                                                     |
 //+------------------------------------------------------------------+
 void CGElement::ChangeImage(const uint group_index,const uint image_index)
  {
   if(!this.CheckOutOfRange(group_index,image_index))
      return;
   this.m_images_group[group_index].m_selected_image=(int)image_index;
  }
 //+------------------------------------------------------------------+
 //| Returns the image selected for display in the specified group    |
 //+------------------------------------------------------------------+
 int CGElement::SelectedImage(const uint group_index=0)
  {
   uint images_group_total=::ArraySize(this.m_images_group);
   if(images_group_total<1 || group_index>=images_group_total)
      return(WRONG_VALUE);
   uint images_total=::ArraySize(this.m_images_group[group_index].m_image);
   if(images_total<1)
      return(WRONG_VALUE);
   return(this.m_images_group[group_index].m_selected_image);
  }
 //+------------------------------------------------------------------+
 //| Draws the selected image of every group                          |
 //+------------------------------------------------------------------+
 void CGElement::DrawImage(void)
  {
   uint group_total=this.ImagesGroupTotal();
   for(uint g=0; g<group_total; g++)
     {
      int i=this.SelectedImage(g);
      if(i==WRONG_VALUE)
         continue;
      int  x=this.m_images_group[g].m_x_gap;
      int  y=this.m_images_group[g].m_y_gap;
      uint height=this.m_images_group[g].m_image[i].Height();
      uint width =this.m_images_group[g].m_image[i].Width();
      for(uint ly=0,p=0; ly<height; ly++)
        {
         for(uint lx=0; lx<width; lx++,p++)
           {
            if((this.m_images_group[g].m_image[i].Data(p)>>24)==0)
               continue;
            uint rx=x+lx;
            uint ry=y+ly;
            uint background =::ColorToARGB(this.m_canvas.PixelGet(rx,ry));
            uint pixel_color=this.m_images_group[g].m_image[i].Data(p);
            uint foreground =::ColorToARGB(CColors::BlendColors(background,pixel_color));
            this.m_canvas.PixelSet(rx,ry,foreground);
           }
        }
     }
   }
 //+------------------------------------------------------------------+
 //| Default hit test: the element rectangle                          |
 //+------------------------------------------------------------------+
 bool CGElement::CheckMouseFocus(const int x,const int y)
  {
   this.m_mouse_focus=(x>=this.m_x && x<this.m_x+this.m_x_size && y>=this.m_y && y<this.m_y+this.m_y_size);
   return this.m_mouse_focus;
 }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::OnFocus(void)
  {
   if(this.ColorChange(COLOR_STATE_FOCUSED))
      this.Draw(true);
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::OnBlur(void)
  {
   if(this.ColorChange(COLOR_STATE_DEFAULT))
      this.Draw(true);
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::OnPress(const int x,const int y)
  {
   if(this.ColorChange(COLOR_STATE_PRESSED))
      this.Draw(true);
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::OnRelease(const int x,const int y)
  {
   if(this.ColorChange(this.m_mouse_focus ? COLOR_STATE_FOCUSED : COLOR_STATE_DEFAULT))
      this.Draw(true);
  }
 //+------------------------------------------------------------------+
 //| Kazharski payload: lparam = element Id                           |
 //+------------------------------------------------------------------+
 bool CGElement::SendEvent(const ushort event_id,const double dparam,const string sparam)
  {
   return ::EventChartCustom(this.m_chart_id,event_id,this.ObjectID(),dparam,sparam);
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 void CGElement::SetChartTools(const bool enable)
  {
   if(!enable)
    {
     if(this.m_chart_tools_locked)
        return;
     this.m_chart_tools_locked=true;
     if(s_tools_lock_count++>0)
        return;
     s_saved_mouse_scroll=(bool)::ChartGetInteger(this.m_chart_id,CHART_MOUSE_SCROLL);
     s_saved_context_menu=(bool)::ChartGetInteger(this.m_chart_id,CHART_CONTEXT_MENU);
     s_saved_crosshair   =(bool)::ChartGetInteger(this.m_chart_id,CHART_CROSSHAIR_TOOL);
     ::ChartSetInteger(this.m_chart_id,CHART_MOUSE_SCROLL,false);
     ::ChartSetInteger(this.m_chart_id,CHART_CONTEXT_MENU,false);
     ::ChartSetInteger(this.m_chart_id,CHART_CROSSHAIR_TOOL,false);
     return;
    }
   if(!this.m_chart_tools_locked)
      return;
   this.m_chart_tools_locked=false;
   if(--s_tools_lock_count>0)
      return;
   ::ChartSetInteger(this.m_chart_id,CHART_MOUSE_SCROLL,s_saved_mouse_scroll);
   ::ChartSetInteger(this.m_chart_id,CHART_CONTEXT_MENU,s_saved_context_menu);
   ::ChartSetInteger(this.m_chart_id,CHART_CROSSHAIR_TOOL,s_saved_crosshair);
  }
 //+------------------------------------------------------------------+
 //| DoEasy SetActiveAreaShift (left, bottom, right, top)             |
 //+------------------------------------------------------------------+
 void CGElement::SetActiveAreaShift(const int left_shift,const int bottom_shift,const int right_shift,const int top_shift)
  {
   this.m_act_shift_left  =left_shift;
   this.m_act_shift_bottom=bottom_shift;
   this.m_act_shift_right =right_shift;
   this.m_act_shift_top   =top_shift;
  }
 //+------------------------------------------------------------------+
 //| DoEasy area tests, x/y in chart (subwindow) coordinates          |
 //+------------------------------------------------------------------+
 bool CGElement::CursorInsideElement(const int x,const int y)
  {
   return(x>=this.m_x && x<=this.RightEdge() && y>=this.m_y && y<=this.BottomEdge());
  }
 bool CGElement::CursorInsideActiveArea(const int x,const int y)
  {
   return(x>=this.ActiveAreaLeft() && x<=this.ActiveAreaRight() && y>=this.ActiveAreaTop() && y<=this.ActiveAreaBottom());
  }
 bool CGElement::CursorInsideControlArea(const int x,const int y)
  {
   return(this.m_control_area_width>0 && this.m_control_area_height>0 &&
         x>=this.ControlAreaLeft() && x<this.ControlAreaRight() && y>=this.ControlAreaTop() && y<this.ControlAreaBottom());
  }
 bool CGElement::CursorInsideResizeTopArea(const int x,const int y)
  {
   return(this.m_border_resize_area_top>0 && x>=this.m_x+DEF_CONTROL_CORNER_AREA && x<=this.RightEdge()-DEF_CONTROL_CORNER_AREA &&
         y>=this.m_y && y<=this.m_y+this.m_border_resize_area_top);
  }
 bool CGElement::CursorInsideResizeBottomArea(const int x,const int y)
  {
   return(this.m_border_resize_area_bottom>0 && x>=this.m_x+DEF_CONTROL_CORNER_AREA && x<=this.RightEdge()-DEF_CONTROL_CORNER_AREA &&
         y>=this.BottomEdge()-this.m_border_resize_area_bottom && y<=this.BottomEdge());
  }
 bool CGElement::CursorInsideResizeLeftArea(const int x,const int y)
  {
   return(this.m_border_resize_area_left>0 && x>=this.m_x && x<=this.m_x+this.m_border_resize_area_left &&
         y>=this.m_y+DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge()-DEF_CONTROL_CORNER_AREA);
  }
 bool CGElement::CursorInsideResizeRightArea(const int x,const int y)
  {
   return(this.m_border_resize_area_right>0 && x>=this.RightEdge()-this.m_border_resize_area_right && x<=this.RightEdge() &&
         y>=this.m_y+DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge()-DEF_CONTROL_CORNER_AREA);
  }
 bool CGElement::CursorInsideResizeTopLeftArea(const int x,const int y)
  {
   return(this.m_border_resize_area_top>0 && this.m_border_resize_area_left>0 &&
         x>=this.m_x && x<this.m_x+DEF_CONTROL_CORNER_AREA && y>=this.m_y && y<this.m_y+DEF_CONTROL_CORNER_AREA);
  }
 bool CGElement::CursorInsideResizeTopRightArea(const int x,const int y)
  {
   return(this.m_border_resize_area_top>0 && this.m_border_resize_area_right>0 &&
         x>this.RightEdge()-DEF_CONTROL_CORNER_AREA && x<=this.RightEdge() && y>=this.m_y && y<this.m_y+DEF_CONTROL_CORNER_AREA);
  }
 bool CGElement::CursorInsideResizeBottomLeftArea(const int x,const int y)
  {
   return(this.m_border_resize_area_bottom>0 && this.m_border_resize_area_left>0 &&
         x>=this.m_x && x<this.m_x+DEF_CONTROL_CORNER_AREA && y>this.BottomEdge()-DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge());
  }
 bool CGElement::CursorInsideResizeBottomRightArea(const int x,const int y)
  {
   return(this.m_border_resize_area_bottom>0 && this.m_border_resize_area_right>0 &&
         x>this.RightEdge()-DEF_CONTROL_CORNER_AREA && x<=this.RightEdge() && y>this.BottomEdge()-DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge());
  }
 //+------------------------------------------------------------------+
 //| Area code: 0 form, 1 active, 2 control, 3..10 resize             |
 //| (top, bottom, left, right, top-left, top-right, bottom-left,     |
 //| bottom-right) - same order as ENUM_MOUSE_FORM_STATE              |
 //+------------------------------------------------------------------+
 int CGElement::MouseArea(const int x,const int y)
  {
   if(this.CursorInsideResizeTopLeftArea(x,y))     return(7);
   if(this.CursorInsideResizeTopRightArea(x,y))    return(8);
   if(this.CursorInsideResizeBottomLeftArea(x,y))  return(9);
   if(this.CursorInsideResizeBottomRightArea(x,y)) return(10);
   if(this.CursorInsideResizeTopArea(x,y))         return(3);
   if(this.CursorInsideResizeBottomArea(x,y))      return(4);
   if(this.CursorInsideResizeLeftArea(x,y))        return(5);
   if(this.CursorInsideResizeRightArea(x,y))       return(6);
   if(this.CursorInsideControlArea(x,y))           return(2);
   if(this.CursorInsideActiveArea(x,y))            return(1);
   return(0);
  }
 //+------------------------------------------------------------------+
 //| Area + buttons -> DoEasy ENUM_MOUSE_FORM_STATE                   |
 //+------------------------------------------------------------------+
 ENUM_MOUSE_FORM_STATE CGElement::MouseFormState(const int area,const bool inside,const bool pressed,const bool wheel,const bool released)
  {
   int kind=(wheel ? 2 : (pressed ? 1 : 0));
   if(!inside)
      return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_OUTSIDE_FORM_NOT_PRESSED+kind));
   switch(area)
     {
     case 1 :
        if(released)
           return(MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_RELEASED);
        return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_NOT_PRESSED+kind));
     case 2 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_NOT_PRESSED+kind));
     case 3 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_NOT_PRESSED+kind));
     case 4 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_AREA_NOT_PRESSED+kind));
     case 5 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_LEFT_AREA_NOT_PRESSED+kind));
     case 6 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_RIGHT_AREA_NOT_PRESSED+kind));
     case 7 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_LEFT_AREA_NOT_PRESSED+kind));
     case 8 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_RIGHT_AREA_NOT_PRESSED+kind));
     case 9 :  return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_LEFT_AREA_NOT_PRESSED+kind));
     case 10 : return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_NOT_PRESSED+kind));
     default : return((ENUM_MOUSE_FORM_STATE)(MOUSE_FORM_STATE_INSIDE_FORM_NOT_PRESSED+kind));
     }
  }
 //+------------------------------------------------------------------+
 //| DoEasy CForm::OnMouseEvent: event -> handler                     |
 //+------------------------------------------------------------------+
 void CGElement::OnMouseEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   ENUM_MOUSE_FORM_STATE state=(ENUM_MOUSE_FORM_STATE)(id-MOUSE_EVENT_NO_EVENT);
   switch(state)
    {
     case MOUSE_FORM_STATE_OUTSIDE_FORM_NOT_PRESSED        : this.MouseOutsideNotPressedHandler(id,lparam,dparam,sparam);     return;
     case MOUSE_FORM_STATE_OUTSIDE_FORM_PRESSED            : this.MouseOutsidePressedHandler(id,lparam,dparam,sparam);        return;
     case MOUSE_FORM_STATE_OUTSIDE_FORM_WHEEL              : this.MouseOutsideWhellHandler(id,lparam,dparam,sparam);          return;
     case MOUSE_FORM_STATE_INSIDE_FORM_NOT_PRESSED         : this.MouseInsideNotPressedHandler(id,lparam,dparam,sparam);      return;
     case MOUSE_FORM_STATE_INSIDE_FORM_PRESSED             : this.MouseInsidePressedHandler(id,lparam,dparam,sparam);         return;
     case MOUSE_FORM_STATE_INSIDE_FORM_WHEEL               : this.MouseInsideWhellHandler(id,lparam,dparam,sparam);           return;
     case MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_NOT_PRESSED  : this.MouseActiveAreaNotPressedHandler(id,lparam,dparam,sparam);  return;
     case MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_PRESSED      : this.MouseActiveAreaPressedHandler(id,lparam,dparam,sparam);     return;
     case MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_WHEEL        : this.MouseActiveAreaWhellHandler(id,lparam,dparam,sparam);       return;
     case MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_RELEASED     : this.MouseActiveAreaReleasedHandler(id,lparam,dparam,sparam);    return;
     case MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_NOT_PRESSED  : this.MouseScrollAreaNotPressedHandler(id,lparam,dparam,sparam); return;
     case MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_PRESSED      : this.MouseScrollAreaPressedHandler(id,lparam,dparam,sparam);    return;
     case MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_WHEEL        : this.MouseScrollAreaWhellHandler(id,lparam,dparam,sparam);      return;
     case MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_NOT_PRESSED : this.MouseScrollAreaNotPressedHandler(id,lparam,dparam,sparam); return;
     case MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_PRESSED     : this.MouseScrollAreaPressedHandler(id,lparam,dparam,sparam);    return;
     case MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_WHEEL       : this.MouseScrollAreaWhellHandler(id,lparam,dparam,sparam);      return;
     case MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_NOT_PRESSED : this.MouseControlAreaNotPressedHandler(id,lparam,dparam,sparam); return;
     case MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_PRESSED     : this.MouseControlAreaPressedHandler(id,lparam,dparam,sparam);    return;
     case MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_WHEEL       : this.MouseControlAreaWhellHandler(id,lparam,dparam,sparam);      return;
     default : break;
    }
  if(state>=MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_NOT_PRESSED && state<=MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_WHEEL)
    {
     int kind=(state-MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_NOT_PRESSED)%3;
     if(kind==0)
        this.MouseResizeAreaNotPressedHandler(id,lparam,dparam,sparam);
     else if(kind==1)
        this.MouseResizeAreaPressedHandler(id,lparam,dparam,sparam);
     else
        this.MouseResizeAreaWhellHandler(id,lparam,dparam,sparam);
    }
  }
 //+------------------------------------------------------------------+
 //| Shared CMouse -> transitions (focus/press/move/release) ->       |
 //| DoEasy mouse state -> DoEasy handler                             |
 //+------------------------------------------------------------------+
 void CGElement::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(!this.IsVisible())
      return;
   if(dynamic_cast<CGElement *>(this.m_parent)==NULL)
      s_mouse.OnEvent(id,lparam,dparam,sparam);
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
     CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
     if(child!=NULL)
        child.OnChartEvent(id,lparam,dparam,sparam);
     }
   if(id==CHARTEVENT_CUSTOM+ON_SET_AVAILABLE)
     {
      int branch=WRONG_VALUE;
      for(int i=0; i<this.ChildrenTotal() && branch==WRONG_VALUE; i++)
       {
        CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
        if(child!=NULL && (child.ObjectID()==lparam || child.HasDescendant(lparam)))
           branch=i;
       }
      if(branch==WRONG_VALUE)
        return;
      for(int i=0; i<this.ChildrenTotal(); i++)
       {
        CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
        if(child!=NULL && i!=branch)
           child.IsAvailable(dparam!=0);
       }
      return;
     }
   if(id==CHARTEVENT_CHART_CHANGE)
    {
     this.m_shift_y=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,this.m_subwindow);
     return;
    }
   if((id!=CHARTEVENT_MOUSE_MOVE && id!=CHARTEVENT_MOUSE_WHEEL) || this.m_is_locked)
     return;
   if(!this.m_is_available)
    {
     this.m_prev_left=s_mouse.IsLeftBtn();
     return;
    }
   int  x      =s_mouse.X();
   int  y      =s_mouse.Y();
   bool wheel  =(id==CHARTEVENT_MOUSE_WHEEL);
   bool left   =s_mouse.IsLeftBtn();
   bool pressed=((s_mouse.GetMouseFlags() & 0x0013)!=0);
   bool focus  =(this.CheckMouseFocus(x,y) && s_mouse.SubWin()==this.m_subwindow);
   int  area   =(focus ? this.MouseArea(x,y) : 0);
   bool released=false;
   if(!wheel)
    {
     if(this.m_is_pressed)
       {
        if(left)
           this.OnMove(x,y);
        else
          {
           this.m_is_pressed=false;
           this.m_focused=focus;
           released=(focus && area==this.m_press_area);
           this.OnRelease(x,y);
           if(!focus)
              this.SetChartTools(true);
          }
       }
     else if(left)
       {
        if(!this.m_prev_left && focus)
          {
           this.m_is_pressed=true;
           this.m_press_area=area;
           if(this.m_lock_chart_tools)
              this.SetChartTools(false);
           this.OnPress(x,y);
          }
       }
     else if(focus && !this.m_focused)
       {
        this.m_focused=true;
        if(this.m_lock_chart_tools)
           this.SetChartTools(false);
        this.OnFocus();
       }
     else if(!focus && this.m_focused)
       {
        this.m_focused=false;
        this.SetChartTools(true);
        this.OnBlur();
       }
     this.m_prev_left=left;
    }
   bool captured=(this.m_is_pressed && left);
   ENUM_MOUSE_FORM_STATE state=this.MouseFormState(captured ? this.m_press_area : area,focus || captured,pressed,wheel,released);
   int event=(int)state+MOUSE_EVENT_NO_EVENT;
   this.OnMouseEvent(event,lparam,dparam,sparam);
   this.m_mouse_event_last=(ENUM_MOUSE_EVENT)event;
  }
 //+------------------------------------------------------------------+
 //| Timer tick (TIMER_STEP_MSC) passed down the visible subtree      |
 //+------------------------------------------------------------------+
 void CGElement::OnTimerEvent(void)
  {
   if(!this.IsVisible())
     return;
   for(int i=0; i<this.ChildrenTotal(); i++)
    {
     CGElement *child=dynamic_cast<CGElement *>(this.Child(i));
     if(child!=NULL)
        child.OnTimerEvent();
    }
  }
#endif // CGELEMENT_MQH_IMPLEMENTATION
#endif // CGELEMENT_MQH
