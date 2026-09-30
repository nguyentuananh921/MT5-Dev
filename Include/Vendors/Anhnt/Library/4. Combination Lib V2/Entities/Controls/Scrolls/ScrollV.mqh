//+------------------------------------------------------------------+
//|                                                      ScrollV.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Link                       https://www.mql5.com/en/articles/2943  |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CSCROLLV_MQH
#define CSCROLLV_MQH
 #include "..\Scroll.mqh"
//+------------------------------------------------------------------+
//| Vertical scrollbar                                               |
//+------------------------------------------------------------------+
class CScrollV : public CScroll
 {
  protected:
    virtual bool      IsVertical(void)                      const { return true;  }
  public:
    void              ChangeYSize(const int height);
                     CScrollV(void) {}
                    ~CScrollV(void) {}
 };
//+------------------------------------------------------------------+
//| New length: down button to the bottom, slider recalculated       |
//+------------------------------------------------------------------+
void CScrollV::ChangeYSize(const int height)
 {
  if(height<1 || height==this.m_area_length)
     return;
  this.m_area_length=height;
  this.Resize(this.m_area_width,height);
  this.m_button_dec.Move(this.m_x,this.m_y+height-this.m_thumb_width);
  this.CalculateThumbSize();
  this.CalculateThumbCoord();
  this.Draw(false);
 }
#endif // CSCROLLV_MQH
