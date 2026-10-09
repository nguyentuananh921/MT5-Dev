//+------------------------------------------------------------------+
//|                                                        Frame.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CFRAME_MQH
#define CFRAME_MQH
 #include "Label.mqh"
#ifndef CFRAME_MQH_DECLARATION
#define CFRAME_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Group box: border with the caption cut into its top edge,        |
//| controls inside are its children                                 |
//+------------------------------------------------------------------+
class CFrame : public CLabel
 {
  private:
    bool              m_auto_xresize_mode;
    bool              m_auto_yresize_mode;
    int               m_auto_xresize_right_offset;
    int               m_auto_yresize_bottom_offset;
  protected:
    virtual void      InitColors(void);
  public:
    bool              CreateFrame(const long chart_id,const int subwin,const string name,const int x,const int y,const int w=0,const int h=0);
    void              AutoXResizeMode(const bool mode)              { m_auto_xresize_mode=mode;           }
    void              AutoYResizeMode(const bool mode)              { m_auto_yresize_mode=mode;           }
    void              AutoXResizeRightOffset(const int offset)      { m_auto_xresize_right_offset=offset; }
    void              AutoYResizeBottomOffset(const int offset)     { m_auto_yresize_bottom_offset=offset; }
    virtual void      Draw(const bool chart_redraw);
    virtual void      ChangeWidthByRightWindowSide(void);
    virtual void      ChangeHeightByBottomWindowSide(void);
                     CFrame(void);
                    ~CFrame(void) {}
 };
#endif // CFRAME_MQH_DECLARATION
#ifndef CFRAME_MQH_IMPLEMENTATION
#define CFRAME_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski: caption at x=12 plus label gap 5                      |
//+------------------------------------------------------------------+
CFrame::CFrame(void) : m_auto_xresize_mode(false),
                       m_auto_yresize_mode(false),
                       m_auto_xresize_right_offset(0),
                       m_auto_yresize_bottom_offset(0)
 {
  this.LabelXGap(17);
 }
//+------------------------------------------------------------------+
//| Transparent, border C'150,170,180', caption black                |
//+------------------------------------------------------------------+
void CFrame::InitColors(void)
 {
  color border=C'150,170,180';
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrSilver);
  this.m_color_border.InitColors(border,border,border,clrSilver);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrSilver);
  this.m_color_border_act.InitColors(border,border,border,clrSilver);
 }
//+------------------------------------------------------------------+
//| w/h < 1 or auto mode: size up to the parent's right/bottom edge  |
//+------------------------------------------------------------------+
bool CFrame::CreateFrame(const long chart_id,const int subwin,const string name,const int x,const int y,const int w=0,const int h=0)
 {
  int fw=w,fh=h;
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent!=NULL && (fw<1 || this.m_auto_xresize_mode))
     fw=parent.Width()-x-this.m_auto_xresize_right_offset;
  if(parent!=NULL && (fh<1 || this.m_auto_yresize_mode))
     fh=parent.Height()-y-this.m_auto_yresize_bottom_offset;
  return(this.Create(chart_id,subwin,name,x,y,::MathMax(fw,1),::MathMax(fh,1)));
 }
//+------------------------------------------------------------------+
//| Border from the caption's middle down, top edge split around it  |
//+------------------------------------------------------------------+
void CFrame::Draw(const bool chart_redraw)
 {
  this.m_canvas.Erase(0);
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  int  tw =(this.m_text=="" ? 0 : this.m_canvas.TextWidth(this.m_text));
  int  top=(this.m_text=="" ? 0 : this.m_canvas.TextHeight(this.m_text)/2);
  int  x2 =this.m_x_size-1;
  int  y2 =this.m_y_size-1;
  uint clr=::ColorToARGB(this.BorderColor(),255);
  this.m_canvas.Line(0,top,0,y2,clr);
  this.m_canvas.Line(x2,top,x2,y2,clr);
  this.m_canvas.Line(0,y2,x2,y2,clr);
  if(tw==0)
     this.m_canvas.Line(0,top,x2,top,clr);
  else
    {
     this.m_canvas.Line(0,top,this.m_text_x-3,top,clr);
     this.m_canvas.Line(this.m_text_x+tw+2,top,x2,top,clr);
     this.m_canvas.TextOut(this.m_text_x,0,this.m_text,::ColorToARGB(this.ForeColor(),255),TA_LEFT|TA_TOP);
    }
  this.m_canvas.Update(chart_redraw);
 }
//+------------------------------------------------------------------+
//| Auto x-resize: follow the parent's right edge, then the children |
//+------------------------------------------------------------------+
void CFrame::ChangeWidthByRightWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(this.m_auto_xresize_mode && parent!=NULL)
     this.Resize(parent.Width()-this.m_x_gap-this.m_auto_xresize_right_offset,this.m_y_size);
  CGElement::ChangeWidthByRightWindowSide();
 }
//+------------------------------------------------------------------+
//| Auto y-resize: follow the parent's bottom edge, then the children|
//+------------------------------------------------------------------+
void CFrame::ChangeHeightByBottomWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(this.m_auto_yresize_mode && parent!=NULL)
     this.Resize(this.m_x_size,parent.Height()-this.m_y_gap-this.m_auto_yresize_bottom_offset);
  CGElement::ChangeHeightByBottomWindowSide();
 }
#endif // CFRAME_MQH_IMPLEMENTATION
#endif // CFRAME_MQH
