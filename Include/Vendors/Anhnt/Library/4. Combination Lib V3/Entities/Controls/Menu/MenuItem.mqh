//+------------------------------------------------------------------+
//|                                                     MenuItem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CMENUITEM_MQH
#define CMENUITEM_MQH
 #include "..\Button.mqh"
#ifndef CMENUITEM_MQH_DECLARATION
#define CMENUITEM_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Menu entry; its sub-menu, if any, is its CMenuBase child         |
//+------------------------------------------------------------------+
class CMenuItem : public CButton
 {
  private:
    ENUM_TYPE_MENU_ITEM m_type_menu_item;
    bool              m_show_right_arrow;
    int               m_arrow_x_gap;
    bool              m_checkbox_state;
  protected:
    virtual void      DrawImage(void);
    virtual void      OnRelease(const int x,const int y);
  public:
    bool              CreateMenuItem(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h);
    void              TypeMenuItem(const ENUM_TYPE_MENU_ITEM type)  { m_type_menu_item=type;  }
    ENUM_TYPE_MENU_ITEM TypeMenuItem(void)                    const { return(m_type_menu_item); }
    void              ShowRightArrow(const bool flag)               { m_show_right_arrow=flag;  }
    bool              CheckBoxState(void)                     const { return(m_checkbox_state); }
    void              CheckBoxState(const bool state);
                     CMenuItem(void);
                    ~CMenuItem(void) {}
 };
#endif // CMENUITEM_MQH_DECLARATION
#ifndef CMENUITEM_MQH_IMPLEMENTATION
#define CMENUITEM_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski defaults                                               |
//+------------------------------------------------------------------+
CMenuItem::CMenuItem(void) : m_type_menu_item(MI_SIMPLE),
                             m_show_right_arrow(true),
                             m_arrow_x_gap(18),
                             m_checkbox_state(true)
 {
 }
//+------------------------------------------------------------------+
//| Checkbox icons replace group 0, arrow goes to group 1            |
//+------------------------------------------------------------------+
bool CMenuItem::CreateMenuItem(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h)
 {
  if(this.m_type_menu_item==MI_CHECKBOX)
    {
     this.IconFile(IMAGE_RESOURCE_BMP16_CHECKBOX_MINI_BLACK_BMP);
     this.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_MINI_WHITE_BMP);
    }
  if(this.m_type_menu_item==MI_HAS_CONTEXT_MENU && this.m_show_right_arrow)
    {
     if(this.ImagesGroupTotal()<1)
        this.IconFile((uint)INT_MAX);
     this.AddImagesGroup(w-this.m_arrow_x_gap,(h-16)/2);
     this.AddImage(1,IMAGE_RESOURCE_BMP16_ARROW_RIGHT_BLACK_BMP);
     this.AddImage(1,IMAGE_RESOURCE_BMP16_ARROW_RIGHT_WHITE_BMP);
    }
  return(this.Create(chart_id,subwin,name,x,y,w,h));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMenuItem::CheckBoxState(const bool state)
 {
  this.m_checkbox_state=state;
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Icon at x=3 (white on hover for checkbox), arrow on the right    |
//+------------------------------------------------------------------+
void CMenuItem::DrawImage(void)
 {
  bool hot=(this.m_focused || this.m_state);
  if(this.ImagesTotal(0)>=4)
    {
     int slot=(this.m_is_locked ? 1 : 0);
     if(this.m_type_menu_item==MI_CHECKBOX)
        slot=(!this.m_checkbox_state ? WRONG_VALUE : (hot ? 2 : 0));
     if(slot!=WRONG_VALUE && this.m_images_group[0].m_image[slot].Width()<1)
        slot=0;
     this.m_images_group[0].m_selected_image=slot;
     if(slot!=WRONG_VALUE)
       {
        this.m_images_group[0].m_x_gap=3;
        this.m_images_group[0].m_y_gap=(this.m_y_size-(int)this.m_images_group[0].m_image[slot].Height())/2;
       }
    }
  if(this.ImagesGroupTotal()>1)
     this.ChangeImage(1,hot ? 1 : 0);
  CGElement::DrawImage();
 }
//+------------------------------------------------------------------+
//| Checkbox flips on click; the parent menu decides the rest        |
//+------------------------------------------------------------------+
void CMenuItem::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_mouse_focus)
     return;
  if(this.m_type_menu_item==MI_CHECKBOX)
     this.m_checkbox_state=!this.m_checkbox_state;
  this.SendEvent(ON_CLICK_BUTTON,0,this.m_text);
 }
#endif // CMENUITEM_MQH_IMPLEMENTATION
#endif // CMENUITEM_MQH
