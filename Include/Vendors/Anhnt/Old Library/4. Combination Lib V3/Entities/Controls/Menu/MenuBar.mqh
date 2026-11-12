//+------------------------------------------------------------------+
//|                                                      MenuBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CMENUBAR_MQH
#define CMENUBAR_MQH
 #include "..\MenuBase.mqh"
#ifndef CMENUBAR_MQH_DECLARATION
#define CMENUBAR_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Horizontal main menu; hovering another item moves the open menu  |
//+------------------------------------------------------------------+
class CMenuBar : public CMenuBase
 {
  protected:
    virtual bool      IsHorizontal(void)                    const { return(true); }
    virtual ushort    ClickItemEventId(void)                const { return(ON_CLICK_MENU_ITEM); }
    virtual void      InitColors(void);
    virtual void      InitItemColors(CMenuItem &item);
  public:
    bool              CreateMenuBar(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h=22);
    void              AddItem(const int width,const string text);
    bool              State(void)                           const { return(this.HasOpenMenu()); }
    virtual void      ChangeWidthByRightWindowSide(void);
                     CMenuBar(void) {}
                    ~CMenuBar(void) {}
 };
#endif // CMENUBAR_MQH_DECLARATION
#ifndef CMENUBAR_MQH_IMPLEMENTATION
#define CMENUBAR_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski: back C'225,225,225', border = back                    |
//+------------------------------------------------------------------+
void CMenuBar::InitColors(void)
 {
  color back=C'225,225,225';
  this.m_color_background.InitColors(back,back,back,back);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(back,back,back,back);
  this.m_color_background_act.InitColors(back,back,back,back);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(back,back,back,back);
 }
//+------------------------------------------------------------------+
//| Kazharski items: hover/pressed C'51,153,255' with white text     |
//+------------------------------------------------------------------+
void CMenuBar::InitItemColors(CMenuItem &item)
 {
  color back=C'225,225,225',hot=C'51,153,255';
  item.GetBackColorControl().InitColors(back,hot,hot,back);
  item.GetForeColorControl().InitColors(clrBlack,clrWhite,clrWhite,clrGray);
  item.GetBorderColorControl().InitColors(back,back,back,back);
  item.GetBackColorActControl().InitColors(hot,hot,hot,back);
  item.GetForeColorActControl().InitColors(clrWhite,clrWhite,clrWhite,clrGray);
  item.GetBorderColorActControl().InitColors(back,back,back,back);
 }
//+------------------------------------------------------------------+
//| Added before the bar is created                                  |
//+------------------------------------------------------------------+
void CMenuBar::AddItem(const int width,const string text)
 {
  CMenuBase::AddItem(text,(uint)INT_MAX,(uint)INT_MAX,MI_SIMPLE);
  this.m_item_x_size[::ArraySize(this.m_item_x_size)-1]=width;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMenuBar::CreateMenuBar(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h=22)
 {
  if(!this.Create(chart_id,subwin,name,x,y,w,h))
     return(false);
  return(this.CreateItems());
 }
//+------------------------------------------------------------------+
//| Right edge 1px inside the parent (Kazharski auto x-resize)       |
//+------------------------------------------------------------------+
void CMenuBar::ChangeWidthByRightWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent==NULL)
     return;
  this.Resize(parent.Width()-this.m_x_gap-1,this.m_y_size);
  this.Draw(false);
 }
#endif // CMENUBAR_MQH_IMPLEMENTATION
#endif // CMENUBAR_MQH
