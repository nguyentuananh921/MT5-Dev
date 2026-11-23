//+------------------------------------------------------------------+
//|                                              ButtonTriggered.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CBUTTONTRIGGERED_MQH
#define CBUTTONTRIGGERED_MQH
 #include "Button.mqh"
//+------------------------------------------------------------------+
//| Two-state button: each click flips State()                       |
//+------------------------------------------------------------------+
class CButtonTriggered : public CButton
 {
  protected:
    virtual void      OnRelease(const int x,const int y);
  public:
                     CButtonTriggered(void) {}
                    ~CButtonTriggered(void) {}
 };
//+------------------------------------------------------------------+
//| Released over the button = flip state, dparam carries it         |
//+------------------------------------------------------------------+
void CButtonTriggered::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_mouse_focus)
     return;
  this.SetState(!this.m_state);
  this.SendEvent(ON_CLICK_BUTTON,(this.m_state ? 1 : 0),this.m_text);
 }
#endif // CBUTTONTRIGGERED_MQH
