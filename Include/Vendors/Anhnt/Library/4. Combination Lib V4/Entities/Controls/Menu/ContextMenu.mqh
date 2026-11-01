//+------------------------------------------------------------------+
//|                                                  ContextMenu.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CCONTEXTMENU_MQH
#define CCONTEXTMENU_MQH
 #include "..\MenuBase.mqh"
#ifndef CCONTEXTMENU_MQH_DECLARATION
#define CCONTEXTMENU_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Vertical pop-up menu; as a CMenuItem child it opens at its item  |
//+------------------------------------------------------------------+
class CContextMenu : public CMenuBase
 {
  private:
    ENUM_FIX_CONTEXT_MENU m_fix_side;
  protected:
    virtual void      InitColors(void);
    virtual void      InitItemColors(CMenuItem &item);
  public:
    bool              CreateContextMenu(const long chart_id,const int subwin,const string name,const int w,const int x=0,const int y=0);
    void              FixSide(const ENUM_FIX_CONTEXT_MENU side)     { m_fix_side=side; }
                     CContextMenu(void) : m_fix_side(FIX_RIGHT) {}
                    ~CContextMenu(void) {}
 };
#endif // CCONTEXTMENU_MQH_DECLARATION
#ifndef CCONTEXTMENU_MQH_IMPLEMENTATION
#define CCONTEXTMENU_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski: back C'240,240,240', border C'150,170,180'            |
//+------------------------------------------------------------------+
void CContextMenu::InitColors(void)
 {
  this.m_color_background.InitColors(C'240,240,240',C'240,240,240',C'240,240,240',clrLightGray);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(C'150,170,180',C'150,170,180',C'150,170,180',C'150,170,180');
  this.m_color_background_act.InitColors(C'240,240,240',C'240,240,240',C'240,240,240',clrLightGray);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(C'150,170,180',C'150,170,180',C'150,170,180',C'150,170,180');
 }
//+------------------------------------------------------------------+
//| Kazharski items: hover/pressed C'51,153,255' with white text     |
//+------------------------------------------------------------------+
void CContextMenu::InitItemColors(CMenuItem &item)
 {
  color back=C'240,240,240',hot=C'51,153,255';
  item.GetBackColorControl().InitColors(back,hot,hot,clrLightGray);
  item.GetForeColorControl().InitColors(clrBlack,clrWhite,clrWhite,clrGray);
  item.GetBorderColorControl().InitColors(back,back,back,back);
  item.GetBackColorActControl().InitColors(hot,hot,hot,clrLightGray);
  item.GetForeColorActControl().InitColors(clrWhite,clrWhite,clrWhite,clrGray);
  item.GetBorderColorActControl().InitColors(back,back,back,back);
 }
//+------------------------------------------------------------------+
//| Height from the items; x=y=0 under a CMenuItem = FixSide place   |
//+------------------------------------------------------------------+
bool CContextMenu::CreateContextMenu(const long chart_id,const int subwin,const string name,const int w,const int x=0,const int y=0)
 {
  int h=this.m_item_y_size*this.ItemsTotal()+2+::ArraySize(this.m_sep_line_index)*9;
  int cx=x,cy=y;
  CMenuItem *item=dynamic_cast<CMenuItem *>(this.m_parent);
  if(item!=NULL && x==0 && y==0)
    {
     cx=(this.m_fix_side==FIX_RIGHT ? item.Width()-3 : 1);
     cy=(this.m_fix_side==FIX_RIGHT ? -1 : item.Height()-1);
    }
  if(!this.Create(chart_id,subwin,name,cx,cy,w,h))
     return(false);
  if(!this.CreateItems())
     return(false);
  this.Hide();
  return(true);
 }
#endif // CCONTEXTMENU_MQH_IMPLEMENTATION
#endif // CCONTEXTMENU_MQH
