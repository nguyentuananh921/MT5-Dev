//+------------------------------------------------------------------+
//|                                                     MenuBase.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CMENUBASE_MQH
#define CMENUBASE_MQH
 #include "Menu\MenuItem.mqh"
 #include "SeparateLine.mqh"
#ifndef CMENUBASE_MQH_DECLARATION
#define CMENUBASE_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Common parent of CMenuBar and CContextMenu: owns CMenuItem +     |
//| CSeparateLine children, opens/closes the items' sub-menus        |
//+------------------------------------------------------------------+
class CMenuBase : public CGElement
 {
  protected:
    CMenuItem         m_items[];
    CSeparateLine     m_sep_line[];
    string            m_text[];
    uint              m_image_resource_index_on[];
    uint              m_image_resource_index_off[];
    ENUM_TYPE_MENU_ITEM m_item_type[];
    int               m_item_x_size[];
    int               m_sep_line_index[];
    int               m_item_y_size;
    int               m_active_item_index;
    color             m_sepline_dark_color;
    color             m_sepline_light_color;

    virtual bool      IsHorizontal(void)                    const { return(false); }
    virtual void      InitItemColors(CMenuItem &item)             {}
    virtual ushort    ClickItemEventId(void)                const { return(ON_CLICK_CONTEXTMENU_ITEM); }
    bool              CreateItems(void);
    CMenuBase        *RootMenu(void);
    int               ItemIndexById(const long id);
    int               FocusedItemIndex(void);
    bool              MouseOverMenus(void);
    void              OpenSubMenu(const int index);
    void              CloseSubMenu(const int index);
    void              SetOthersAvailable(const bool state);
  public:
    CMenuItem        *GetItemPointer(const uint index);
    CSeparateLine    *GetSeparateLinePointer(const uint index);
    CMenuBase        *SubMenu(const int index);
    int               ItemsTotal(void)                      const { return(::ArraySize(m_text));     }
    int               SeparateLinesTotal(void)              const { return(::ArraySize(m_sep_line)); }
    void              ItemYSize(const int y_size)                 { m_item_y_size=y_size;            }
    void              SeparateLineDarkColor(const color clr)      { m_sepline_dark_color=clr;        }
    void              SeparateLineLightColor(const color clr)     { m_sepline_light_color=clr;       }
    void              AddItem(const string text,const uint resource_index_on,const uint resource_index_off,const ENUM_TYPE_MENU_ITEM type);
    void              AddSeparateLine(const int item_index);
    bool              HasOpenMenu(void)                     const { return(m_active_item_index!=WRONG_VALUE); }
    void              CloseMenus(void);
    virtual void      Show(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CMenuBase(void);
                    ~CMenuBase(void) {}
 };
#endif // CMENUBASE_MQH_DECLARATION
#ifndef CMENUBASE_MQH_IMPLEMENTATION
#define CMENUBASE_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski defaults                                               |
//+------------------------------------------------------------------+
CMenuBase::CMenuBase(void) : m_item_y_size(24),
                             m_active_item_index(WRONG_VALUE),
                             m_sepline_dark_color(C'160,160,160'),
                             m_sepline_light_color(clrWhite)
 {
 }
//+------------------------------------------------------------------+
//| Added before the menu is created                                 |
//+------------------------------------------------------------------+
void CMenuBase::AddItem(const string text,const uint resource_index_on,const uint resource_index_off,const ENUM_TYPE_MENU_ITEM type)
 {
  int size=::ArraySize(this.m_text);
  ::ArrayResize(this.m_text,size+1);
  ::ArrayResize(this.m_image_resource_index_on,size+1);
  ::ArrayResize(this.m_image_resource_index_off,size+1);
  ::ArrayResize(this.m_item_type,size+1);
  ::ArrayResize(this.m_item_x_size,size+1);
  this.m_text[size]                     =text;
  this.m_image_resource_index_on[size]  =resource_index_on;
  this.m_image_resource_index_off[size] =resource_index_off;
  this.m_item_type[size]                =type;
  this.m_item_x_size[size]              =0;
 }
//+------------------------------------------------------------------+
//| Separator after item_index, added before the menu is created     |
//+------------------------------------------------------------------+
void CMenuBase::AddSeparateLine(const int item_index)
 {
  int size=::ArraySize(this.m_sep_line_index);
  ::ArrayResize(this.m_sep_line_index,size+1);
  this.m_sep_line_index[size]=item_index;
 }
//+------------------------------------------------------------------+
//| Items in a row or a column, a separator after the marked ones    |
//+------------------------------------------------------------------+
bool CMenuBase::CreateItems(void)
 {
  int items_total=this.ItemsTotal();
  int seps_total =::ArraySize(this.m_sep_line_index);
  ::ArrayResize(this.m_items,items_total);
  ::ArrayResize(this.m_sep_line,seps_total);
  bool horizontal=this.IsHorizontal();
  int  x=(horizontal ? 0 : 1);
  int  y=(horizontal ? 0 : 1);
  int  s=0;
  for(int i=0; i<items_total; i++)
    {
     int w=(horizontal ? this.m_item_x_size[i] : this.m_x_size-2);
     int h=(horizontal ? this.m_y_size : this.m_item_y_size);
     this.AddChild(::GetPointer(this.m_items[i]));
     this.m_items[i].TypeMenuItem(this.m_item_type[i]);
     this.m_items[i].SetText(this.m_text[i]);
     this.m_items[i].IconFile(this.m_image_resource_index_on[i]);
     this.m_items[i].IconFileLocked(this.m_image_resource_index_off[i]);
     if(!horizontal)
        this.m_items[i].LabelXGap(24);
     if(!this.m_items[i].CreateMenuItem(this.m_chart_id,this.m_subwindow,this.Name()+"_item_"+(string)i,x,y,w,h))
        return(false);
     this.InitItemColors(this.m_items[i]);
     this.m_items[i].ColorChange(COLOR_STATE_DEFAULT);
     this.m_items[i].Draw(false);
     if(horizontal)
        x+=w;
     else
        y+=h;
     if(s>=seps_total || this.m_sep_line_index[s]!=i)
        continue;
     this.AddChild(::GetPointer(this.m_sep_line[s]));
     this.m_sep_line[s].TypeSepLine(horizontal ? V_SEP_LINE : H_SEP_LINE);
     this.m_sep_line[s].DarkColor(this.m_sepline_dark_color);
     this.m_sep_line[s].LightColor(this.m_sepline_light_color);
     bool created=(horizontal ?
                   this.m_sep_line[s].CreateSeparateLine(this.m_chart_id,this.m_subwindow,this.Name()+"_sep_"+(string)s,x+3,3,2,this.m_y_size-6) :
                   this.m_sep_line[s].CreateSeparateLine(this.m_chart_id,this.m_subwindow,this.Name()+"_sep_"+(string)s,5,y+3,this.m_x_size-10,2));
     if(!created)
        return(false);
     if(horizontal)
        x+=8;
     else
        y+=9;
     s++;
    }
  return(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMenuItem *CMenuBase::GetItemPointer(const uint index)
 {
  return(index<(uint)::ArraySize(this.m_items) ? ::GetPointer(this.m_items[index]) : NULL);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSeparateLine *CMenuBase::GetSeparateLinePointer(const uint index)
 {
  return(index<(uint)::ArraySize(this.m_sep_line) ? ::GetPointer(this.m_sep_line[index]) : NULL);
 }
//+------------------------------------------------------------------+
//| Sub-menu = the CMenuBase child of the item                       |
//+------------------------------------------------------------------+
CMenuBase *CMenuBase::SubMenu(const int index)
 {
  if(index<0 || index>=::ArraySize(this.m_items))
     return(NULL);
  for(int i=0; i<this.m_items[index].ChildrenTotal(); i++)
    {
     CMenuBase *menu=dynamic_cast<CMenuBase *>(this.m_items[index].Child(i));
     if(menu!=NULL)
        return(menu);
    }
  return(NULL);
 }
//+------------------------------------------------------------------+
//| Topmost CMenuBase above this one (itself if none)                |
//+------------------------------------------------------------------+
CMenuBase *CMenuBase::RootMenu(void)
 {
  CMenuBase *root=::GetPointer(this);
  for(CGBaseObj *node=this.m_parent; node!=NULL; node=node.Parent())
    {
     CMenuBase *menu=dynamic_cast<CMenuBase *>(node);
     if(menu!=NULL)
        root=menu;
    }
  return(root);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMenuBase::ItemIndexById(const long id)
 {
  for(int i=0; i<::ArraySize(this.m_items); i++)
     if(this.m_items[i].ObjectID()==id)
        return(i);
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMenuBase::FocusedItemIndex(void)
 {
  for(int i=0; i<::ArraySize(this.m_items); i++)
     if(this.m_items[i].MouseFocus())
        return(i);
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Mouse over this menu or any open sub-menu below it               |
//+------------------------------------------------------------------+
bool CMenuBase::MouseOverMenus(void)
 {
  if(this.m_mouse_focus)
     return(true);
  CMenuBase *sub=this.SubMenu(this.m_active_item_index);
  return(sub!=NULL && sub.MouseOverMenus());
 }
//+------------------------------------------------------------------+
//| Shows the item's sub-menu on top, parent blocks other controls   |
//+------------------------------------------------------------------+
void CMenuBase::OpenSubMenu(const int index)
 {
  CMenuBase *sub=this.SubMenu(index);
  if(sub==NULL)
     return;
  this.m_active_item_index=index;
  this.m_items[index].SetState(true);
  sub.Show();
  this.SetOthersAvailable(false);
  ::ChartRedraw(this.m_chart_id);
 }
//+------------------------------------------------------------------+
//| Hides the item's sub-menu and everything open below it           |
//+------------------------------------------------------------------+
void CMenuBase::CloseSubMenu(const int index)
 {
  CMenuBase *sub=this.SubMenu(index);
  if(sub!=NULL)
    {
     sub.CloseMenus();
     sub.Hide();
    }
  this.m_items[index].SetState(false);
  if(this.m_active_item_index==index)
     this.m_active_item_index=WRONG_VALUE;
 }
//+------------------------------------------------------------------+
//| ON_SET_AVAILABLE on behalf of the root menu: its parents block   |
//| (false) or unblock (true) everything outside the menu tree       |
//+------------------------------------------------------------------+
void CMenuBase::SetOthersAvailable(const bool state)
 {
  ::EventChartCustom(this.m_chart_id,ON_SET_AVAILABLE,this.RootMenu().ObjectID(),(state ? 1 : 0),"");
 }
//+------------------------------------------------------------------+
//| Closes every open sub-menu below this menu                       |
//+------------------------------------------------------------------+
void CMenuBase::CloseMenus(void)
 {
  if(this.m_active_item_index!=WRONG_VALUE)
     this.CloseSubMenu(this.m_active_item_index);
 }
//+------------------------------------------------------------------+
//| Base Show cascades to the sub-menus, keep closed ones hidden     |
//+------------------------------------------------------------------+
void CMenuBase::Show(void)
 {
  CGElement::Show();
  for(int i=0; i<::ArraySize(this.m_items); i++)
    {
     CMenuBase *sub=this.SubMenu(i);
     if(sub!=NULL && i!=this.m_active_item_index)
        sub.Hide();
    }
 }
//+------------------------------------------------------------------+
//| Item click: toggle its sub-menu or shout and close everything;   |
//| hover moves the open sub-menu; the root closes on outside press  |
//+------------------------------------------------------------------+
void CMenuBase::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  bool prev_left=this.m_prev_left;
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(!this.IsVisible())
     return;
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
    {
     int index=this.ItemIndexById(lparam);
     if(index==WRONG_VALUE)
        return;
     if(this.SubMenu(index)!=NULL)
       {
        bool opened=(index==this.m_active_item_index);
        this.CloseMenus();
        if(!opened)
           this.OpenSubMenu(index);
        else if(!this.RootMenu().HasOpenMenu())
           this.SetOthersAvailable(true);
        ::ChartRedraw(this.m_chart_id);
        return;
       }
     this.SendEvent(this.ClickItemEventId(),index,this.m_items[index].Text());
     CMenuBase *root=this.RootMenu();
     if(root.HasOpenMenu())
       {
        root.CloseMenus();
        this.SetOthersAvailable(true);
       }
     ::ChartRedraw(this.m_chart_id);
     return;
    }
  if(id!=CHARTEVENT_MOUSE_MOVE || this.m_active_item_index==WRONG_VALUE)
     return;
  if(!s_mouse.IsLeftBtn())
    {
     int focused=this.FocusedItemIndex();
     if(focused==WRONG_VALUE || focused==this.m_active_item_index)
        return;
     bool has_sub=(this.SubMenu(focused)!=NULL);
     if(this.IsHorizontal() && !has_sub)
        return;
     this.CloseSubMenu(this.m_active_item_index);
     if(has_sub)
        this.OpenSubMenu(focused);
     ::ChartRedraw(this.m_chart_id);
     return;
    }
  if(prev_left || this.RootMenu()!=::GetPointer(this) || this.MouseOverMenus())
     return;
  this.CloseMenus();
  this.SetOthersAvailable(true);
  ::ChartRedraw(this.m_chart_id);
 }
#endif // CMENUBASE_MQH_IMPLEMENTATION
#endif // CMENUBASE_MQH
