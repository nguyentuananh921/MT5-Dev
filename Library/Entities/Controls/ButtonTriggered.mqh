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
    bool              m_state_texts;            // New in V5: the text follows the state (StateTexts)
    string            m_text_on;
    string            m_text_off;
    virtual void      OnRelease(const int x,const int y);
    virtual void      DrawImage(void);
  public:
                     CButtonTriggered(void) : m_state_texts(false) {}
                    ~CButtonTriggered(void) {}
    //--- New in V5: the text when ON / OFF ("ON" / "OFF"); it is put at each draw, so SetState then Draw shows it
    void              StateTexts(const string on,const string off) { m_text_on=on; m_text_off=off; m_state_texts=true; }
 };
//+------------------------------------------------------------------+
//| The text of the state first: the text is drawn after the image   |
//+------------------------------------------------------------------+
void CButtonTriggered::DrawImage(void)
 {
  if(this.m_state_texts)
     this.m_text=(this.m_state ? this.m_text_on : this.m_text_off);
  CButton::DrawImage();
 }
//+------------------------------------------------------------------+
//| Released over the button = flip state, dparam carries it         |
//+------------------------------------------------------------------+
void CButtonTriggered::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_mouse_focus)
     return;
  this.SetState(!this.m_state);
  this.SendEvent(CLICK_EVENT_BUTTON,(this.m_state ? 1 : 0),this.m_text);
 }
#endif // CBUTTONTRIGGERED_MQH
