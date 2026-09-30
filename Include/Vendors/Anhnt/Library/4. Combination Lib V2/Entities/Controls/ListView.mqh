//+------------------------------------------------------------------+
//|                                                     ListView.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Link                       https://www.mql5.com/en/articles/2380  |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CLISTVIEW_MQH
#define CLISTVIEW_MQH
 #include "Scrolls\ScrollV.mqh"
#ifndef CLISTVIEW_MQH_DECLARATION
#define CLISTVIEW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| List of text rows drawn on one canvas, only visible rows drawn   |
//+------------------------------------------------------------------+
class CListView : public CGElement
 {
  protected:
    CScrollV          m_scrollv;
    struct LVItemOptions
      {
       string            m_value;
       bool              m_state;
      };
    LVItemOptions     m_items[];
    int               m_item_y_size;
    int               m_selected_item;
    string            m_selected_item_text;
    int               m_item_index_focus;
    bool              m_checkbox_mode;
    bool              m_lights_hover;
    int               m_visible_list_from_index;
    color             m_back_color_hover;
    color             m_back_color_pressed;
    color             m_label_color;
    color             m_label_color_pressed;
    CImage            m_check_off;
    CImage            m_check_on;

    int               ContentWidth(void);
    int               ItemIndexAt(const int x,const int y);
    void              DrawIcon(CImage &image,const int x,const int y);
    void              RecalculateAndResizeList(const bool redraw);
    virtual void      InitColors(void);
    virtual void      DrawContent(void);
    virtual void      OnBlur(void);
    virtual void      OnRelease(const int x,const int y);
    virtual void      MouseActiveAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam);
  public:
    bool              CreateListView(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h);
    CScrollV         *GetScrollVPointer(void)                          { return(::GetPointer(m_scrollv)); }
    void              ItemYSize(const int y_size)                       { m_item_y_size=y_size;            }
    int               ItemsTotal(void)                            const { return(::ArraySize(m_items));    }
    int               VisibleItemsTotal(void);
    void              LightsHover(const bool state)                     { m_lights_hover=state;            }
    void              CheckBoxMode(const bool state)                    { m_checkbox_mode=state;           }
    int               SelectedItemIndex(void)                     const { return(m_selected_item);         }
    string            SelectedItemText(void)                      const { return(m_selected_item_text);    }
    void              SetValue(const uint item_index,const string value,const bool redraw=false);
    string            GetValue(const uint item_index);
    bool              GetState(const uint item_index);
    void              SelectItem(const uint item_index,const bool redraw=false);
    void              ListSize(const int items_total);
    void              Rebuilding(const int items_total,const bool redraw=false);
    void              AddItem(const int item_index,const string value="",const bool redraw=false);
    void              DeleteItem(const int item_index,const bool redraw=false);
    void              Clear(const bool redraw=false);
    void              Scrolling(const int pos=WRONG_VALUE);
    virtual void      Show(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CListView(void);
                    ~CListView(void) {}
 };
#endif // CLISTVIEW_MQH_DECLARATION
#ifndef CLISTVIEW_MQH_IMPLEMENTATION
#define CLISTVIEW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor - Kazharski defaults                                 |
//+------------------------------------------------------------------+
CListView::CListView(void) : m_item_y_size(18),
                             m_selected_item(WRONG_VALUE),
                             m_selected_item_text(""),
                             m_item_index_focus(WRONG_VALUE),
                             m_checkbox_mode(false),
                             m_lights_hover(false),
                             m_visible_list_from_index(0),
                             m_back_color_hover(C'229,243,255'),
                             m_back_color_pressed(C'51,153,255'),
                             m_label_color(clrBlack),
                             m_label_color_pressed(clrWhite)
 {
 }
//+------------------------------------------------------------------+
//| Kazharski list: white, border C'150,170,180'                     |
//+------------------------------------------------------------------+
void CListView::InitColors(void)
 {
  this.m_color_background.InitColors(clrWhite,clrWhite,clrWhite,clrWhite);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(C'150,170,180',C'150,170,180',C'150,170,180',C'150,170,180');
  this.m_color_background_act.InitColors(clrWhite,clrWhite,clrWhite,clrWhite);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(C'150,170,180',C'150,170,180',C'150,170,180',C'150,170,180');
 }
//+------------------------------------------------------------------+
//| Canvas = visible area, vertical scrollbar as a child             |
//+------------------------------------------------------------------+
bool CListView::CreateListView(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h)
 {
  this.m_check_off.ReadImageData(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG);
  this.m_check_on.ReadImageData(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
  if(!this.Create(chart_id,subwin,name,x,y,w,h))
     return(false);
  this.AddChild(::GetPointer(this.m_scrollv));
  int visible=(h-2)/this.m_item_y_size;
  if(!this.m_scrollv.CreateScroll(chart_id,subwin,this.Name()+"_scrollv",w-16,1,15,h-2,::MathMax(this.ItemsTotal(),1),::MathMax(visible,1)))
     return(false);
  this.RecalculateAndResizeList(true);
  return(true);
 }
//+------------------------------------------------------------------+
//| Number of rows that fit in the canvas                            |
//+------------------------------------------------------------------+
int CListView::VisibleItemsTotal(void)
 {
  int visible=(this.m_y_size-2)/this.m_item_y_size;
  return(visible<1 ? 1 : visible);
 }
//+------------------------------------------------------------------+
//| Exclusive right edge of the rows (scrollbar or right border)     |
//+------------------------------------------------------------------+
int CListView::ContentWidth(void)
 {
  return(this.m_scrollv.IsVisible() ? this.m_x_size-16 : this.m_x_size-1);
 }
//+------------------------------------------------------------------+
//| Row index under chart x,y, WRONG_VALUE if none                   |
//+------------------------------------------------------------------+
int CListView::ItemIndexAt(const int x,const int y)
 {
  int lx=x-this.m_x;
  int ly=y-this.m_y-1;
  if(lx<1 || lx>=this.ContentWidth() || ly<0)
     return(WRONG_VALUE);
  int row=ly/this.m_item_y_size;
  if(row>=this.VisibleItemsTotal())
     return(WRONG_VALUE);
  int index=this.m_visible_list_from_index+row;
  return(index<this.ItemsTotal() ? index : WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Scrollbar size/visibility and first visible row after a change   |
//+------------------------------------------------------------------+
void CListView::RecalculateAndResizeList(const bool redraw)
 {
  int total  =this.ItemsTotal();
  int visible=this.VisibleItemsTotal();
  int max_from=::MathMax(total-visible,0);
  if(this.m_visible_list_from_index>max_from)
     this.m_visible_list_from_index=max_from;
  this.m_scrollv.ChangeThumbSize(::MathMax(total,1),visible);
  if(total>visible && this.IsVisible())
     this.m_scrollv.Show();
  else
     this.m_scrollv.Hide();
  this.m_scrollv.MovingThumb(this.m_visible_list_from_index);
  this.Draw(redraw);
 }
//+------------------------------------------------------------------+
//| Draws a 16px icon with Kazharski blending                        |
//+------------------------------------------------------------------+
void CListView::DrawIcon(CImage &image,const int x,const int y)
 {
  uint height=image.Height();
  uint width =image.Width();
  for(uint ly=0,p=0; ly<height; ly++)
    {
     for(uint lx=0; lx<width; lx++,p++)
       {
        if((image.Data(p)>>24)==0)
           continue;
        uint background=::ColorToARGB(this.m_canvas.PixelGet(x+lx,y+ly));
        this.m_canvas.PixelSet(x+lx,y+ly,::ColorToARGB(CColors::BlendColors(background,image.Data(p))));
       }
    }
 }
//+------------------------------------------------------------------+
//| Visible rows: highlight, check icon, text                        |
//+------------------------------------------------------------------+
void CListView::DrawContent(void)
 {
  int width  =this.ContentWidth();
  int visible=this.VisibleItemsTotal();
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  for(int r=0; r<visible; r++)
    {
     int i=this.m_visible_list_from_index+r;
     if(i>=this.ItemsTotal())
        break;
     int y1=1+r*this.m_item_y_size;
     int y2=y1+this.m_item_y_size-1;
     bool selected=(i==this.m_selected_item);
     if(selected)
        this.m_canvas.FillRectangle(1,y1,width-1,y2,::ColorToARGB(this.m_back_color_pressed,255));
     else if(this.m_lights_hover && i==this.m_item_index_focus)
        this.m_canvas.FillRectangle(1,y1,width-1,y2,::ColorToARGB(this.m_back_color_hover,255));
     int text_x=4;
     if(this.m_checkbox_mode)
       {
        if(this.m_items[i].m_state)
           this.DrawIcon(this.m_check_on,3,y1+(this.m_item_y_size-(int)this.m_check_on.Height())/2);
        else
           this.DrawIcon(this.m_check_off,3,y1+(this.m_item_y_size-(int)this.m_check_off.Height())/2);
        text_x=22;
       }
     color text_color=(selected ? this.m_label_color_pressed : this.m_label_color);
     this.m_canvas.TextOut(text_x,y1+this.m_item_y_size/2,this.m_items[i].m_value,::ColorToARGB(text_color,255),TA_LEFT|TA_VCENTER);
    }
 }
//+------------------------------------------------------------------+
//| Mouse left the list: no hovered row                              |
//+------------------------------------------------------------------+
void CListView::OnBlur(void)
 {
  CGElement::OnBlur();
  if(this.m_item_index_focus==WRONG_VALUE)
     return;
  this.m_item_index_focus=WRONG_VALUE;
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Click on a row: select it (and flip its check in checkbox mode)  |
//+------------------------------------------------------------------+
void CListView::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_mouse_focus)
     return;
  int index=this.ItemIndexAt(x,y);
  if(index==WRONG_VALUE)
     return;
  if(this.m_checkbox_mode)
     this.m_items[index].m_state=!this.m_items[index].m_state;
  this.SelectItem(index,true);
  this.SendEvent(ON_CLICK_LIST_ITEM,index,this.m_items[index].m_value);
 }
//+------------------------------------------------------------------+
//| Wheel over the rows scrolls the list                             |
//+------------------------------------------------------------------+
void CListView::MouseActiveAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  if(s_mouse.X()-this.m_x>=this.ContentWidth())
     return;
  this.Scrolling(this.m_visible_list_from_index+(s_mouse.DeltaWheel()>0 ? -1 : 1));
 }
//+------------------------------------------------------------------+
//| Sets the item text                                               |
//+------------------------------------------------------------------+
void CListView::SetValue(const uint item_index,const string value,const bool redraw=false)
 {
  if(item_index>=(uint)this.ItemsTotal())
     return;
  this.m_items[item_index].m_value=value;
  if(item_index==(uint)this.m_selected_item)
     this.m_selected_item_text=value;
  if(redraw)
     this.Draw(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CListView::GetValue(const uint item_index)
 {
  return(item_index<(uint)this.ItemsTotal() ? this.m_items[item_index].m_value : "");
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CListView::GetState(const uint item_index)
 {
  return(item_index<(uint)this.ItemsTotal() ? this.m_items[item_index].m_state : false);
 }
//+------------------------------------------------------------------+
//| Selects an item and scrolls it into view                         |
//+------------------------------------------------------------------+
void CListView::SelectItem(const uint item_index,const bool redraw=false)
 {
  if(item_index>=(uint)this.ItemsTotal())
     return;
  this.m_selected_item     =(int)item_index;
  this.m_selected_item_text=this.m_items[item_index].m_value;
  int visible=this.VisibleItemsTotal();
  if((int)item_index<this.m_visible_list_from_index)
     this.Scrolling((int)item_index);
  else if((int)item_index>=this.m_visible_list_from_index+visible)
     this.Scrolling((int)item_index-visible+1);
  else if(redraw)
     this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Sets the number of items (before or after creation)              |
//+------------------------------------------------------------------+
void CListView::ListSize(const int items_total)
 {
  int total=::MathMax(items_total,0);
  ::ArrayResize(this.m_items,total);
  for(int i=0; i<total; i++)
    {
     this.m_items[i].m_value="";
     this.m_items[i].m_state=false;
    }
 }
//+------------------------------------------------------------------+
//| List reconstruction                                              |
//+------------------------------------------------------------------+
void CListView::Rebuilding(const int items_total,const bool redraw=false)
 {
  this.Clear(false);
  this.ListSize(items_total);
  this.RecalculateAndResizeList(redraw);
 }
//+------------------------------------------------------------------+
//| Inserts an item at item_index (appends if out of range)          |
//+------------------------------------------------------------------+
void CListView::AddItem(const int item_index,const string value="",const bool redraw=false)
 {
  int total=this.ItemsTotal();
  int index=(item_index<0 || item_index>total) ? total : item_index;
  ::ArrayResize(this.m_items,total+1,100);
  for(int i=total; i>index; i--)
     this.m_items[i]=this.m_items[i-1];
  this.m_items[index].m_value=value;
  this.m_items[index].m_state=false;
  if(this.m_selected_item>=index && this.m_selected_item!=WRONG_VALUE)
     this.m_selected_item++;
  this.RecalculateAndResizeList(redraw);
 }
//+------------------------------------------------------------------+
//| Removes the item at item_index                                   |
//+------------------------------------------------------------------+
void CListView::DeleteItem(const int item_index,const bool redraw=false)
 {
  int total=this.ItemsTotal();
  if(item_index<0 || item_index>=total)
     return;
  for(int i=item_index; i<total-1; i++)
     this.m_items[i]=this.m_items[i+1];
  ::ArrayResize(this.m_items,total-1);
  if(this.m_selected_item==item_index)
    {
     this.m_selected_item     =WRONG_VALUE;
     this.m_selected_item_text="";
    }
  else if(this.m_selected_item>item_index)
     this.m_selected_item--;
  this.RecalculateAndResizeList(redraw);
 }
//+------------------------------------------------------------------+
//| Removes all items                                                |
//+------------------------------------------------------------------+
void CListView::Clear(const bool redraw=false)
 {
  ::ArrayFree(this.m_items);
  this.m_selected_item          =WRONG_VALUE;
  this.m_selected_item_text     ="";
  this.m_item_index_focus       =WRONG_VALUE;
  this.m_visible_list_from_index=0;
  if(redraw)
     this.RecalculateAndResizeList(true);
 }
//+------------------------------------------------------------------+
//| Scroll so that row pos is the first visible (end if WRONG_VALUE) |
//+------------------------------------------------------------------+
void CListView::Scrolling(const int pos=WRONG_VALUE)
 {
  int max_from=::MathMax(this.ItemsTotal()-this.VisibleItemsTotal(),0);
  int from=(pos==WRONG_VALUE || pos>max_from) ? max_from : (pos<0 ? 0 : pos);
  if(from==this.m_visible_list_from_index)
     return;
  this.m_visible_list_from_index=from;
  this.m_scrollv.MovingThumb(from);
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Base Show cascades to the scrollbar, keep it hidden if not needed|
//+------------------------------------------------------------------+
void CListView::Show(void)
 {
  CGElement::Show();
  if(!this.m_scrollv.IsScroll())
     this.m_scrollv.Hide();
 }
//+------------------------------------------------------------------+
//| Scrollbar moved, hovered row changed                             |
//+------------------------------------------------------------------+
void CListView::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(id==CHARTEVENT_CUSTOM+ON_SCROLL_CHANGE)
    {
     if(lparam==this.m_scrollv.ObjectID() && (int)dparam!=this.m_visible_list_from_index)
       {
        this.m_visible_list_from_index=(int)dparam;
        this.Draw(true);
       }
     return;
    }
  if(id!=CHARTEVENT_MOUSE_MOVE || !this.m_lights_hover || !this.IsVisible() || this.m_is_locked || !this.m_is_available)
     return;
  int focus=(this.m_mouse_focus ? this.ItemIndexAt(s_mouse.X(),s_mouse.Y()) : WRONG_VALUE);
  if(focus==this.m_item_index_focus)
     return;
  this.m_item_index_focus=focus;
  this.Draw(true);
 }
#endif // CLISTVIEW_MQH_IMPLEMENTATION
#endif // CLISTVIEW_MQH
