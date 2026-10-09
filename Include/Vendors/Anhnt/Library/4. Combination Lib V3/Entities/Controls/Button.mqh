//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CBUTTON_MQH
#define CBUTTON_MQH
 #include "Label.mqh"
#ifndef CBUTTON_MQH_DECLARATION
#define CBUTTON_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Label that reacts to the mouse and shouts ON_CLICK_BUTTON        |
//+------------------------------------------------------------------+
class CButton : public CLabel
 {
  private:
    int               m_icon_x_gap;
    void              SetIconSlot(const uint slot,const uint resource_index);
  protected:
    virtual void      InitColors(void);
    virtual void      DrawImage(void);
    virtual int       TextMaxWidth(void);
    virtual void      OnRelease(const int x,const int y);
  public:
    void              IconFile(const uint resource_index)              { this.SetIconSlot(0,resource_index); }
    void              IconFileLocked(const uint resource_index)        { this.SetIconSlot(1,resource_index); }
    void              IconFilePressed(const uint resource_index)       { this.SetIconSlot(2,resource_index); }
    void              IconFilePressedLocked(const uint resource_index) { this.SetIconSlot(3,resource_index); }
    void              IconXGap(const int x_gap)                        { this.m_icon_x_gap=x_gap;            }
                     CButton(void);
                    ~CButton(void) {}
 };
#endif // CBUTTON_MQH_DECLARATION
#ifndef CBUTTON_MQH_IMPLEMENTATION
#define CBUTTON_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CButton::CButton(void) : m_icon_x_gap(WRONG_VALUE)
 {
  this.m_text_align=TA_CENTER;
 }
//+------------------------------------------------------------------+
//| Kazharski CButton defaults: default / hover / pressed / locked   |
//+------------------------------------------------------------------+
void CButton::InitColors(void)
 {
  this.m_color_background.InitColors(clrGainsboro,C'229,241,251',C'204,228,247',clrLightGray);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(C'150,170,180',C'0,120,215',C'0,84,153',clrDarkGray);
  this.m_color_background_act.InitColors(C'204,228,247',C'204,228,247',C'204,228,247',clrLightGray);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(C'0,84,153',C'0,84,153',C'0,84,153',clrDarkGray);
 }
//+------------------------------------------------------------------+
//| Kazharski icon slots in group 0: normal/locked/pressed/pr.locked |
//+------------------------------------------------------------------+
void CButton::SetIconSlot(const uint slot,const uint resource_index)
 {
  if(this.ImagesGroupTotal()<1)
     this.AddImagesGroup(0,0);
  while(this.ImagesTotal(0)<4)
     this.AddImage(0,(uint)INT_MAX);
  this.SetImage(0,slot,resource_index);
 }
//+------------------------------------------------------------------+
//| Icon centered vertically, same gap on the left, text after it,   |
//| or at IconXGap with the text left where LabelXGap put it         |
//+------------------------------------------------------------------+
void CButton::DrawImage(void)
 {
  if(this.ImagesTotal(0)<4)
     return;
  uint slot=(this.m_is_locked ? (this.m_state ? 3 : 1) : ((this.m_is_pressed || this.m_state) ? 2 : 0));
  if(this.m_images_group[0].m_image[slot].Width()<1)
     slot=0;
  this.ChangeImage(0,slot);
  int i=this.SelectedImage(0);
  if(i!=WRONG_VALUE && this.m_images_group[0].m_image[i].Width()>0)
    {
     int icon_w=(int)this.m_images_group[0].m_image[i].Width();
     int icon_h=(int)this.m_images_group[0].m_image[i].Height();
     int gap=(this.m_y_size-icon_h)/2;
     if(gap<0)
        gap=0;
     this.m_images_group[0].m_y_gap=gap;
     if(this.m_icon_x_gap!=WRONG_VALUE)
        this.m_images_group[0].m_x_gap=this.m_icon_x_gap;
     else
       {
        this.m_images_group[0].m_x_gap=gap;
        this.m_text_x=2*gap+icon_w;
        this.m_text_align=TA_LEFT;
       }
    }
  CGElement::DrawImage();
 }
//+------------------------------------------------------------------+
//| An icon placed right of the text (IconXGap) ends the text room   |
//+------------------------------------------------------------------+
int CButton::TextMaxWidth(void)
 {
  if(this.m_icon_x_gap!=WRONG_VALUE && this.m_icon_x_gap>this.m_text_x && (this.m_text_align & TA_CENTER)!=TA_CENTER)
     return(this.m_icon_x_gap-this.m_text_x-2);
  return(CLabel::TextMaxWidth());
 }
//+------------------------------------------------------------------+
//| Released over the button = click                                 |
//+------------------------------------------------------------------+
void CButton::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(this.m_mouse_focus)
     this.SendEvent(ON_CLICK_BUTTON,0,this.m_text);
 }
#endif // CBUTTON_MQH_IMPLEMENTATION
#endif // CBUTTON_MQH
