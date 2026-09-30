//+------------------------------------------------------------------+
//|                                                         Tabs.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABS_MQH
#define CTABS_MQH
 #include "ButtonsGroup.mqh"
#ifndef CTABS_MQH_DECLARATION
#define CTABS_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Tabs: header = buttons group above, canvas = content area        |
//+------------------------------------------------------------------+
class CTabs : public CGElement
 {
  private:
    CButtonsGroup     m_tabs;
    CButton           m_btn_scroll_left;
    CButton           m_btn_scroll_right;
    int               m_scroll_first_visible;
    struct TElements
      {
       CGElement        *elements[];
      };
    TElements         m_tab[];
    string            m_tab_text[];
    int               m_tab_width[];
    ENUM_TABS_POSITION m_position_mode;
    int               m_tab_y_size;
    int               m_selected_tab;
    bool              m_auto_xresize_mode;
    bool              m_auto_yresize_mode;
    int               m_auto_xresize_right_offset;
    int               m_auto_yresize_bottom_offset;

    bool              CreateButtons(void);
    bool              CreateScrollButtons(void);
    bool              CreateScrollButton(CButton &button_obj,const string suffix,const uint icon,const uint icon_pressed);
    int               SumWidthTabs(void);
    bool              IsTabsOverflow(void);
    void              CheckTabIndex(void);
    void              ShiftTabsHeader(void);
    bool              OnClickTab(const long id,const int index);
    bool              OnClickScrollLeft(const long id);
    bool              OnClickScrollRight(const long id);
  protected:
    virtual void      InitColors(void);
  public:
    bool              CreateTabs(const long chart_id,const int subwin,const string name,const int x,const int y,const int w=0,const int h=0);
    CButtonsGroup    *GetButtonsGroupPointer(void)                    { return(::GetPointer(m_tabs));  }
    int               TabsTotal(void)                           const { return(::ArraySize(m_tab));    }
    void              PositionMode(const ENUM_TABS_POSITION mode)     { m_position_mode=mode;          }
    ENUM_TABS_POSITION PositionMode(void)                       const { return(m_position_mode);       }
    void              TabsYSize(const int y_size)                     { m_tab_y_size=y_size;           }
    int               SelectedTab(void)                         const { return(m_selected_tab);        }
    void              AutoXResizeMode(const bool flag)                { m_auto_xresize_mode=flag;      }
    void              AutoYResizeMode(const bool flag)                { m_auto_yresize_mode=flag;      }
    void              AutoXResizeRightOffset(const int offset)        { m_auto_xresize_right_offset=offset;  }
    void              AutoYResizeBottomOffset(const int offset)       { m_auto_yresize_bottom_offset=offset; }
    void              AddTab(const string tab_text="",const int tab_width=50);
    void              Text(const uint index,const string text);
    void              SelectTab(const int index);
    void              AddToElementsArray(const int tab_index,CGElement &object);
    void              ShowTabElements(void);
    virtual void      ChangeWidthByRightWindowSide(void);
    virtual void      ChangeHeightByBottomWindowSide(void);
    virtual void      Show(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CTabs(void);
                    ~CTabs(void) {}
 };
#endif // CTABS_MQH_DECLARATION
#ifndef CTABS_MQH_IMPLEMENTATION
#define CTABS_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTabs::CTabs(void) : m_scroll_first_visible(0),
                     m_position_mode(TABS_TOP),
                     m_tab_y_size(22),
                     m_selected_tab(WRONG_VALUE),
                     m_auto_xresize_mode(false),
                     m_auto_yresize_mode(false),
                     m_auto_xresize_right_offset(0),
                     m_auto_yresize_bottom_offset(0)
 {
 }
//+------------------------------------------------------------------+
//| Kazharski content area: white, border C'217,217,217'             |
//+------------------------------------------------------------------+
void CTabs::InitColors(void)
 {
  this.m_color_background.InitColors(clrWhite,clrWhite,clrWhite,clrWhite);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(C'217,217,217',C'217,217,217',C'217,217,217',C'217,217,217');
  this.m_color_background_act.InitColors(clrWhite,clrWhite,clrWhite,clrWhite);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(C'217,217,217',C'217,217,217',C'217,217,217',C'217,217,217');
 }
//+------------------------------------------------------------------+
//| Adds a tab before CreateTabs                                     |
//+------------------------------------------------------------------+
void CTabs::AddTab(const string tab_text="",const int tab_width=50)
 {
  int size=::ArraySize(this.m_tab);
  ::ArrayResize(this.m_tab,size+1,10);
  ::ArrayResize(this.m_tab_text,size+1,10);
  ::ArrayResize(this.m_tab_width,size+1,10);
  this.m_tab_text[size] =tab_text;
  this.m_tab_width[size]=tab_width;
 }
//+------------------------------------------------------------------+
//| Content area, header group above it, scroll buttons              |
//+------------------------------------------------------------------+
bool CTabs::CreateTabs(const long chart_id,const int subwin,const string name,const int x,const int y,const int w=0,const int h=0)
 {
  if(this.TabsTotal()<1)
    {
     ::Print(__FUNCTION__," > The call to this method should be made when there is at least one tab in the group! Use the CTabs::AddTab() method");
     return(false);
    }
  int width =w;
  int height=h;
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent!=NULL && (width<1 || this.m_auto_xresize_mode))
     width=parent.Width()-x-this.m_auto_xresize_right_offset;
  if(parent!=NULL && (height<1 || this.m_auto_yresize_mode))
     height=parent.Height()-y-this.m_auto_yresize_bottom_offset;
  this.CheckTabIndex();
  if(!this.Create(chart_id,subwin,name,x,y,width,height))
     return(false);
  if(!this.CreateButtons())
     return(false);
  if(!this.CreateScrollButtons())
     return(false);
  this.ShiftTabsHeader();
  this.ShowTabElements();
  return(true);
 }
//+------------------------------------------------------------------+
//| Header: plain buttons in radio mode, active one highlighted      |
//+------------------------------------------------------------------+
bool CTabs::CreateButtons(void)
 {
  int x=0;
  for(int i=0; i<this.TabsTotal(); i++)
    {
     this.m_tabs.AddButton(x,0,this.m_tab_text[i],this.m_tab_width[i],clrWhiteSmoke,C'229,241,251',C'204,228,247');
     x+=this.m_tab_width[i]-1;
    }
  this.m_tabs.ButtonYSize(this.m_tab_y_size);
  this.m_tabs.RadioButtonsMode(true);
  this.AddChild(::GetPointer(this.m_tabs));
  if(!this.m_tabs.CreateButtonsGroup(this.m_chart_id,this.m_subwindow,this.Name()+"_header",0,-this.m_tab_y_size+1))
     return(false);
  for(int i=0; i<this.TabsTotal(); i++)
    {
     CButtonTriggered *button=this.m_tabs.GetButtonPointer(i);
     button.GetBorderColorControl().InitColors(C'217,217,217',C'217,217,217',C'217,217,217',C'217,217,217');
     button.ColorChange(COLOR_STATE_DEFAULT);
     button.Draw(false);
    }
  this.m_tabs.SelectButton(this.m_selected_tab);
  return(true);
 }
//+------------------------------------------------------------------+
//| Two 15px arrows at the right end of the header row               |
//+------------------------------------------------------------------+
bool CTabs::CreateScrollButtons(void)
 {
  if(!this.CreateScrollButton(this.m_btn_scroll_left,"_scroll_left",IMAGE_RESOURCE_BMP16_SCROLL_LEFT_BLACK_BMP,IMAGE_RESOURCE_BMP16_SCROLL_LEFT_WHITE_BMP))
     return(false);
  if(!this.CreateScrollButton(this.m_btn_scroll_right,"_scroll_right",IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_BLACK_BMP,IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_WHITE_BMP))
     return(false);
  this.m_btn_scroll_left.Move(this.m_x+this.m_x_size-30,this.m_y-this.m_tab_y_size+1);
  this.m_btn_scroll_right.Move(this.m_x+this.m_x_size-15,this.m_y-this.m_tab_y_size+1);
  return(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTabs::CreateScrollButton(CButton &button_obj,const string suffix,const uint icon,const uint icon_pressed)
 {
  this.AddChild(&button_obj);
  button_obj.IconFile(icon);
  button_obj.IconFileLocked(icon);
  button_obj.IconFilePressed(icon_pressed);
  if(!button_obj.Create(this.m_chart_id,this.m_subwindow,this.Name()+suffix,0,-this.m_tab_y_size+1,15,this.m_tab_y_size))
     return(false);
  button_obj.GetBackColorControl().InitColors(clrWhiteSmoke,C'229,241,251',C'96,96,96',clrLightGray);
  button_obj.GetBorderColorControl().InitColors(C'217,217,217',C'217,217,217',C'217,217,217',C'217,217,217');
  button_obj.ColorChange(COLOR_STATE_DEFAULT);
  button_obj.Draw(false);
  return(true);
 }
//+------------------------------------------------------------------+
//| Total width of all tabs (1px overlap between neighbours)         |
//+------------------------------------------------------------------+
int CTabs::SumWidthTabs(void)
 {
  int width=0;
  int total=this.TabsTotal();
  for(int i=0; i<total; i++)
     width+=this.m_tab_width[i];
  return(width-(total-1));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTabs::IsTabsOverflow(void)
 {
  return(this.SumWidthTabs()>this.m_x_size);
 }
//+------------------------------------------------------------------+
//| Checking the index of the selected tab                           |
//+------------------------------------------------------------------+
void CTabs::CheckTabIndex(void)
 {
  int array_size=::ArraySize(this.m_tab);
  if(this.m_selected_tab<0)
     this.m_selected_tab=0;
  if(this.m_selected_tab>=array_size)
     this.m_selected_tab=array_size-1;
 }
//+------------------------------------------------------------------+
//| Lays out the header, hides tabs out of view when overflowing     |
//+------------------------------------------------------------------+
void CTabs::ShiftTabsHeader(void)
 {
  bool overflow=this.IsTabsOverflow();
  if(!overflow)
     this.m_scroll_first_visible=0;
  int offset=0;
  for(int i=0; i<this.m_scroll_first_visible; i++)
     offset+=this.m_tab_width[i]-1;
  int header_y=this.m_y-this.m_tab_y_size+1;
  int x=0;
  for(int i=0; i<this.TabsTotal(); i++)
    {
     CButtonTriggered *button=this.m_tabs.GetButtonPointer(i);
     int new_x=x-offset;
     button.Move(this.m_x+new_x,header_y);
     bool in_view=(!overflow || (new_x>=0 && new_x+this.m_tab_width[i]<=this.m_x_size-30));
     if(this.IsVisible() && in_view)
        button.Show();
     else
        button.Hide();
     x+=this.m_tab_width[i]-1;
    }
  if(this.IsVisible() && overflow)
    {
     this.m_btn_scroll_left.Show();
     this.m_btn_scroll_right.Show();
    }
  else
    {
     this.m_btn_scroll_left.Hide();
     this.m_btn_scroll_right.Hide();
    }
 }
//+------------------------------------------------------------------+
//| Sets the tab text                                                |
//+------------------------------------------------------------------+
void CTabs::Text(const uint index,const string text)
 {
  uint total=this.TabsTotal();
  if(total<1)
     return;
  uint correct_index=(index>=total) ? total-1 : index;
  this.m_tab_text[correct_index]=text;
  CButtonTriggered *button=this.m_tabs.GetButtonPointer(correct_index);
  if(button==NULL)
     return;
  button.SetText(text);
  button.Draw(false);
 }
//+------------------------------------------------------------------+
//| Highlights the specified tab                                     |
//+------------------------------------------------------------------+
void CTabs::SelectTab(const int index)
 {
  this.m_selected_tab=index;
  this.CheckTabIndex();
  this.m_tabs.SelectButton(this.m_selected_tab);
  this.ShowTabElements();
 }
//+------------------------------------------------------------------+
//| Registers an element to a tab; call before the element Create    |
//+------------------------------------------------------------------+
void CTabs::AddToElementsArray(const int tab_index,CGElement &object)
 {
  int array_size=::ArraySize(this.m_tab);
  if(array_size<1 || tab_index<0 || tab_index>=array_size)
     return;
  this.AddChild(&object);
  int size=::ArraySize(this.m_tab[tab_index].elements);
  ::ArrayResize(this.m_tab[tab_index].elements,size+1);
  this.m_tab[tab_index].elements[size]=::GetPointer(object);
 }
//+------------------------------------------------------------------+
//| Shows items in the selected tab only                             |
//+------------------------------------------------------------------+
void CTabs::ShowTabElements(void)
 {
  if(!this.IsVisible())
     return;
  this.CheckTabIndex();
  int tabs_total=this.TabsTotal();
  for(int i=0; i<tabs_total; i++)
    {
     int total=::ArraySize(this.m_tab[i].elements);
     for(int j=0; j<total; j++)
       {
        CGElement *el=this.m_tab[i].elements[j];
        if(::CheckPointer(el)==POINTER_INVALID)
           continue;
        if(i==this.m_selected_tab)
           el.Show();
        else
           el.Hide();
       }
    }
  this.SendEvent(ON_CLICK_TAB,this.m_selected_tab,this.m_tab_text[this.m_selected_tab]);
 }
//+------------------------------------------------------------------+
//| Parent got wider/narrower: follow it, relayout the header        |
//+------------------------------------------------------------------+
void CTabs::ChangeWidthByRightWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent!=NULL && this.m_auto_xresize_mode)
    {
     int width=parent.Width()-this.m_x_gap-this.m_auto_xresize_right_offset;
     if(width>0 && width!=this.m_x_size)
       {
        this.Resize(width,this.m_y_size);
        int header_y=this.m_y-this.m_tab_y_size+1;
        this.m_btn_scroll_left.Move(this.m_x+this.m_x_size-30,header_y);
        this.m_btn_scroll_right.Move(this.m_x+this.m_x_size-15,header_y);
        this.ShiftTabsHeader();
       }
    }
  CGElement::ChangeWidthByRightWindowSide();
 }
//+------------------------------------------------------------------+
//| Parent got taller/shorter: follow it                             |
//+------------------------------------------------------------------+
void CTabs::ChangeHeightByBottomWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent!=NULL && this.m_auto_yresize_mode)
    {
     int height=parent.Height()-this.m_y_gap-this.m_auto_yresize_bottom_offset;
     if(height>0 && height!=this.m_y_size)
        this.Resize(this.m_x_size,height);
    }
  CGElement::ChangeHeightByBottomWindowSide();
 }
//+------------------------------------------------------------------+
//| Show everything, then re-apply header crop and tab selection     |
//+------------------------------------------------------------------+
void CTabs::Show(void)
 {
  //--- No base cascade: the other tabs' content must never become visible, not even for one redraw
  this.m_visible=true;
  ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
  this.m_tabs.Show();
  this.ShiftTabsHeader();
  this.ShowTabElements();
 }
//+------------------------------------------------------------------+
//| Clicking on a tab in the header group                            |
//+------------------------------------------------------------------+
bool CTabs::OnClickTab(const long id,const int index)
 {
  if(id!=this.m_tabs.ObjectID() || this.m_is_locked || index<0)
     return(false);
  this.m_selected_tab=index;
  this.ShowTabElements();
  ::ChartRedraw(this.m_chart_id);
  return(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTabs::OnClickScrollLeft(const long id)
 {
  if(id!=this.m_btn_scroll_left.ObjectID())
     return(false);
  if(this.m_scroll_first_visible>0)
     this.m_scroll_first_visible--;
  this.ShiftTabsHeader();
  ::ChartRedraw(this.m_chart_id);
  return(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTabs::OnClickScrollRight(const long id)
 {
  if(id!=this.m_btn_scroll_right.ObjectID())
     return(false);
  int offset=0;
  for(int i=0; i<this.m_scroll_first_visible; i++)
     offset+=this.m_tab_width[i]-1;
  if(this.SumWidthTabs()-offset>this.m_x_size-30)
     this.m_scroll_first_visible++;
  this.ShiftTabsHeader();
  ::ChartRedraw(this.m_chart_id);
  return(true);
 }
//+------------------------------------------------------------------+
//| Children and mouse first, then header and scroll clicks          |
//+------------------------------------------------------------------+
void CTabs::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON)
    {
     this.OnClickTab(lparam,(int)dparam);
     return;
    }
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
    {
     if(!this.OnClickScrollLeft(lparam))
        this.OnClickScrollRight(lparam);
    }
 }
#endif // CTABS_MQH_IMPLEMENTATION
#endif // CTABS_MQH
