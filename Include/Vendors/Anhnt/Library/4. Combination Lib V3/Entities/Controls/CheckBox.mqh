//+------------------------------------------------------------------+
//|                                                     CheckBox.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CCHECKBOX_MQH
#define CCHECKBOX_MQH
 #include "ButtonTriggered.mqh"
//+------------------------------------------------------------------+
//| Checkbox: Kazharski icons and colors on the MVC triggered button |
//+------------------------------------------------------------------+
class CCheckBox : public CButtonTriggered
 {
  protected:
    virtual void      InitColors(void);
    virtual void      OnRelease(const int x,const int y);
  public:
                     CCheckBox(void);
                    ~CCheckBox(void) {}
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(void)
 {
  this.IconFile(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG);
  this.IconFileLocked(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_LOCKED_BMP);
  this.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
  this.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_LOCKED_BMP);
 }
//+------------------------------------------------------------------+
//| Kazharski CCheckBox: transparent, text hover C'0,120,215'        |
//+------------------------------------------------------------------+
void CCheckBox::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrBlack,C'0,120,215',clrBlack,clrSilver);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrBlack,C'0,120,215',clrBlack,clrSilver);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//| Click flips the check, dparam carries the new state              |
//+------------------------------------------------------------------+
void CCheckBox::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_mouse_focus)
     return;
  this.SetState(!this.m_state);
  this.SendEvent(ON_CLICK_CHECKBOX,(this.m_state ? 1 : 0),this.m_text);
 }
#endif // CCHECKBOX_MQH
