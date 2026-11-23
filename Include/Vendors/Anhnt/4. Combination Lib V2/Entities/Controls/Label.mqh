//+------------------------------------------------------------------+
//|                                                        Label.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CLABEL_MQH
#define CLABEL_MQH
 #include "..\GBases\GElement.mqh"
#ifndef CLABEL_MQH_DECLARATION
#define CLABEL_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Text on canvas                                                   |
//+------------------------------------------------------------------+
class CLabel : public CGElement
 {
  protected:
    string            m_text;
    int               m_text_x;
    uint              m_text_align;

    virtual void      InitColors(void);
    virtual void      DrawContent(void);
    virtual int       TextMaxWidth(void);
    string            CorrectingText(const string text,const int max_width);
  public:
    void              SetText(const string text)                  { this.m_text=text;      }
    string            Text(void)                            const { return this.m_text;    }
    void              LabelXGap(const int x_gap)                  { this.m_text_x=x_gap; this.m_text_align=TA_LEFT; }
                     CLabel(void);
                    ~CLabel(void) {}
 };
#endif // CLABEL_MQH_DECLARATION
#ifndef CLABEL_MQH_IMPLEMENTATION
#define CLABEL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLabel::CLabel(void) : m_text(""),m_text_x(4),m_text_align(TA_LEFT)
 {
 }
//+------------------------------------------------------------------+
//| Transparent background and border, text color only               |
//+------------------------------------------------------------------+
void CLabel::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLabel::DrawContent(void)
 {
  int tx=((this.m_text_align & TA_CENTER)==TA_CENTER ? this.m_x_size/2 :
          (this.m_text_align & TA_RIGHT)==TA_RIGHT   ? this.m_x_size-this.m_text_x : this.m_text_x);
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  string text=this.CorrectingText(this.m_text,this.TextMaxWidth());
  this.m_canvas.TextOut(tx,this.m_y_size/2,text,::ColorToARGB(this.ForeColor(),255),this.m_text_align|TA_VCENTER);
 }
//+------------------------------------------------------------------+
//| Room for the text: from its x to the right edge (centered: all)  |
//+------------------------------------------------------------------+
int CLabel::TextMaxWidth(void)
 {
  return((this.m_text_align & TA_CENTER)==TA_CENTER ? this.m_x_size-4 : this.m_x_size-this.m_text_x-2);
 }
//+------------------------------------------------------------------+
//| Kazharski table: cut the text and end it with "..." to fit       |
//+------------------------------------------------------------------+
string CLabel::CorrectingText(const string text,const int max_width)
 {
  if(max_width<1 || this.m_canvas.TextWidth(text)<=max_width)
     return(text);
  for(int len=::StringLen(text)-1; len>0; len--)
    {
     string cut=::StringSubstr(text,0,len)+"...";
     if(this.m_canvas.TextWidth(cut)<=max_width)
        return(cut);
    }
  return("");
 }
#endif // CLABEL_MQH_IMPLEMENTATION
#endif // CLABEL_MQH
