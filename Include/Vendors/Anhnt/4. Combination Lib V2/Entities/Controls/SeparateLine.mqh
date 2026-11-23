//+------------------------------------------------------------------+
//|                                                 SeparateLine.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CSEPARATELINE_MQH
#define CSEPARATELINE_MQH
 #include "..\GBases\GElement.mqh"
#ifndef CSEPARATELINE_MQH_DECLARATION
#define CSEPARATELINE_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Two-color line: dark then light, horizontal or vertical          |
//+------------------------------------------------------------------+
class CSeparateLine : public CGElement
 {
  private:
    ENUM_TYPE_SEP_LINE m_type_sep_line;
    color             m_dark_color;
    color             m_light_color;
  protected:
    virtual void      InitColors(void);
    virtual void      DrawContent(void);
  public:
    bool              CreateSeparateLine(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h);
    void              TypeSepLine(const ENUM_TYPE_SEP_LINE type) { m_type_sep_line=type; }
    void              DarkColor(const color clr)                 { m_dark_color=clr;     }
    void              LightColor(const color clr)                { m_light_color=clr;    }
                     CSeparateLine(void);
                    ~CSeparateLine(void) {}
 };
#endif // CSEPARATELINE_MQH_DECLARATION
#ifndef CSEPARATELINE_MQH_IMPLEMENTATION
#define CSEPARATELINE_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSeparateLine::CSeparateLine(void) : m_type_sep_line(H_SEP_LINE),
                                     m_dark_color(C'160,160,160'),
                                     m_light_color(clrWhite)
 {
 }
//+------------------------------------------------------------------+
//| Transparent canvas, only the two lines are drawn                 |
//+------------------------------------------------------------------+
void CSeparateLine::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSeparateLine::CreateSeparateLine(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h)
 {
  return(this.Create(chart_id,subwin,name,x,y,w,h));
 }
//+------------------------------------------------------------------+
//| H: dark top, light bottom; V: dark left, light right             |
//+------------------------------------------------------------------+
void CSeparateLine::DrawContent(void)
 {
  int x2=this.m_x_size-1;
  int y2=this.m_y_size-1;
  if(this.m_type_sep_line==H_SEP_LINE)
    {
     this.m_canvas.Line(0,0,x2,0,::ColorToARGB(this.m_dark_color));
     this.m_canvas.Line(0,y2,x2,y2,::ColorToARGB(this.m_light_color));
    }
  else
    {
     this.m_canvas.Line(0,0,0,y2,::ColorToARGB(this.m_dark_color));
     this.m_canvas.Line(x2,0,x2,y2,::ColorToARGB(this.m_light_color));
    }
 }
#endif // CSEPARATELINE_MQH_IMPLEMENTATION
#endif // CSEPARATELINE_MQH
