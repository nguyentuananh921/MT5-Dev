//+------------------------------------------------------------------+
//|                                                      Tooltip.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CTOOLTIP_MQH
#define CTOOLTIP_MQH
 #include "Window.mqh"
#ifndef CTOOLTIP_MQH_DECLARATION
#define CTOOLTIP_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Header + lines box. As a child it shows under its parent on      |
//| hover; top-level it is driven by Moving/ShowTooltip/FadeOut.     |
//| Fading runs on OnTimerEvent.                                     |
//+------------------------------------------------------------------+
class CTooltip : public CGElement
 {
  private:
    string            m_header_text;
    color             m_header_color;
    string            m_tooltip_lines[];
    uchar             m_alpha;
    bool              m_fade_out;

    bool              IsAllowed(CGElement *element);
  protected:
    virtual void      InitColors(void);
  public:
    bool              CreateTooltip(const long chart_id,const int subwin,const string name,const int w=100,const int h=50);
    void              HeaderText(const string text)             { m_header_text=text;  }
    void              HeaderColor(const color clr)              { m_header_color=clr;  }
    void              AddString(const string text);
    void              ClearStrings(void)                        { ::ArrayFree(m_tooltip_lines); m_alpha=0; m_fade_out=false; }
    void              Moving(const int x,const int y)           { this.Move(x,y);      }
    void              ShowTooltip(void);
    void              FadeOutTooltip(void)                      { m_fade_out=(m_alpha>0); }
    virtual bool      CheckMouseFocus(const int x,const int y)  { m_mouse_focus=false; return(false); }
    virtual void      Draw(const bool chart_redraw);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    virtual void      OnTimerEvent(void);
                     CTooltip(void);
                    ~CTooltip(void) {}
 };
#endif // CTOOLTIP_MQH_DECLARATION
#ifndef CTOOLTIP_MQH_IMPLEMENTATION
#define CTOOLTIP_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski defaults                                               |
//+------------------------------------------------------------------+
CTooltip::CTooltip(void) : m_header_text(""),
                           m_header_color(C'50,50,50'),
                           m_alpha(0),
                           m_fade_out(false)
 {
 }
//+------------------------------------------------------------------+
//| Kazharski: white box, border C'150,170,180', lines DimGray       |
//+------------------------------------------------------------------+
void CTooltip::InitColors(void)
 {
  color border=C'150,170,180';
  this.m_color_background.InitColors(clrWhite,clrWhite,clrWhite,clrWhite);
  this.m_color_foreground.InitColors(clrDimGray,clrDimGray,clrDimGray,clrDimGray);
  this.m_color_border.InitColors(border,border,border,border);
  this.m_color_background_act.InitColors(clrWhite,clrWhite,clrWhite,clrWhite);
  this.m_color_foreground_act.InitColors(clrDimGray,clrDimGray,clrDimGray,clrDimGray);
  this.m_color_border_act.InitColors(border,border,border,border);
 }
//+------------------------------------------------------------------+
//| Under the parent (1px gap) when it has one, else at 0,0          |
//+------------------------------------------------------------------+
bool CTooltip::CreateTooltip(const long chart_id,const int subwin,const string name,const int w=100,const int h=50)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  return(this.Create(chart_id,subwin,name,0,(parent!=NULL ? parent.Height()+1 : 0),w,h));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTooltip::AddString(const string text)
 {
  int size=::ArraySize(this.m_tooltip_lines);
  ::ArrayResize(this.m_tooltip_lines,size+1);
  this.m_tooltip_lines[size]=text;
 }
//+------------------------------------------------------------------+
//| Kazharski IsTooltip: a window with the tooltip button shows      |
//| tooltips only while that button is pressed                       |
//+------------------------------------------------------------------+
bool CTooltip::IsAllowed(CGElement *element)
 {
  if(element.IsLocked() || !element.IsAvailable())
     return(false);
  for(CGBaseObj *node=element; node!=NULL; node=node.Parent())
    {
     CWindow *window=dynamic_cast<CWindow *>(node);
     if(window!=NULL)
        return(!window.TooltipsButtonIsUsed() || window.TooltipButtonState());
    }
  return(true);
 }
//+------------------------------------------------------------------+
//| Full opacity, brought on top when it was hidden                  |
//+------------------------------------------------------------------+
void CTooltip::ShowTooltip(void)
 {
  if(this.m_alpha==0)
    {
     this.Hide();
     this.Show();
    }
  this.m_alpha   =255;
  this.m_fade_out=false;
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Everything drawn with the current alpha, nothing at 0            |
//+------------------------------------------------------------------+
void CTooltip::Draw(const bool chart_redraw)
 {
  this.m_canvas.Erase(0);
  if(this.m_alpha>0)
    {
     //--- clrNONE background/border = transparent
     if(this.BackColor()!=clrNONE)
        this.m_canvas.FillRectangle(0,0,this.m_x_size-1,this.m_y_size-1,::ColorToARGB(this.BackColor(),this.m_alpha));
     if(this.BorderColor()!=clrNONE)
        this.m_canvas.Rectangle(0,0,this.m_x_size-1,this.m_y_size-1,::ColorToARGB(this.BorderColor(),this.m_alpha));
     int x=5,y=5;
     if(this.m_header_text!="")
       {
        this.m_canvas.FontSet(this.m_font,-this.m_font_size*10,FW_BLACK);
        this.m_canvas.TextOut(x,y,this.m_header_text,::ColorToARGB(this.m_header_color,this.m_alpha),TA_LEFT|TA_TOP);
        x=15;
        y=25;
       }
     this.m_canvas.FontSet(this.m_font,-this.m_font_size*10,FW_THIN);
     for(int i=0; i<::ArraySize(this.m_tooltip_lines); i++,y+=15)
        this.m_canvas.TextOut(x,y,this.m_tooltip_lines[i],::ColorToARGB(this.ForeColor(),this.m_alpha),TA_LEFT|TA_TOP);
    }
  this.m_canvas.Update(chart_redraw);
 }
//+------------------------------------------------------------------+
//| As a child: follow the parent's hover                            |
//+------------------------------------------------------------------+
void CTooltip::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  CGElement *element=dynamic_cast<CGElement *>(this.m_parent);
  if(id!=CHARTEVENT_MOUSE_MOVE || element==NULL || !this.IsVisible())
     return;
  if(element.MouseFocus() && this.IsAllowed(element))
    {
     if(this.m_alpha<255 || this.m_fade_out)
        this.ShowTooltip();
    }
  else if(this.m_alpha>0 && !this.m_fade_out)
     this.FadeOutTooltip();
 }
//+------------------------------------------------------------------+
//| Fade-out step per timer tick (~0.3 s from full to hidden)        |
//+------------------------------------------------------------------+
void CTooltip::OnTimerEvent(void)
 {
  CGElement::OnTimerEvent();
  if(!this.m_fade_out)
     return;
  this.m_alpha=(uchar)::MathMax((int)this.m_alpha-15,0);
  if(this.m_alpha==0)
     this.m_fade_out=false;
  this.Draw(true);
 }
#endif // CTOOLTIP_MQH_IMPLEMENTATION
#endif // CTOOLTIP_MQH
