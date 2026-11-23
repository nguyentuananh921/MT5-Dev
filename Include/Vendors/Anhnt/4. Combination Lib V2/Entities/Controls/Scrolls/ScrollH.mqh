//+------------------------------------------------------------------+
//|                                                      ScrollH.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Link                       https://www.mql5.com/en/articles/2943  |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CSCROLLH_MQH
#define CSCROLLH_MQH
 #include "..\Scroll.mqh"
//+------------------------------------------------------------------+
//| Horizontal scrollbar                                             |
//+------------------------------------------------------------------+
class CScrollH : public CScroll
 {
  protected:
    virtual bool      IsVertical(void)                      const { return false; }
  public:
    void              ChangeXSize(const int width);
                     CScrollH(void) {}
                    ~CScrollH(void) {}
 };
//+------------------------------------------------------------------+
//| New length: right button to the end, slider recalculated         |
//+------------------------------------------------------------------+
void CScrollH::ChangeXSize(const int width)
 {
  if(width<1 || width==this.m_area_length)
     return;
  this.m_area_length=width;
  this.Resize(width,this.m_area_width);
  this.m_button_dec.Move(this.m_x+width-this.m_thumb_width,this.m_y);
  this.CalculateThumbSize();
  this.CalculateThumbCoord();
  this.Draw(false);
 }
#endif // CSCROLLH_MQH
