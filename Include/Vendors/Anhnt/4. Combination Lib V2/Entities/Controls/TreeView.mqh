//+------------------------------------------------------------------+
//|                                                     TreeView.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CTREEVIEW_MQH
#define CTREEVIEW_MQH
 #include "ListView.mqh"
 #include "TreeItem.mqh"
#ifndef CTREEVIEW_MQH_DECLARATION
#define CTREEVIEW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Tree of CTreeItem, expanded nodes flattened into list view rows  |
//+------------------------------------------------------------------+
class CTreeView : public CListView
 {
  private:
    CTreeItem         m_root;
    CTreeItem        *m_rows[];
    long              m_items_counter;
    long              m_selected_item_id;

    CTreeItem        *FindById(CTreeItem *node,const long id);
    void              AddRows(CTreeItem *node);
    void              FormTreeList(const bool redraw);
  protected:
    virtual void      DrawContent(void);
    virtual void      OnRelease(const int x,const int y);
  public:
    bool              CreateTreeView(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h);
    long              AddTreeItem(const long parent_id,const string text,const uint icon=INT_MAX,const bool redraw=false);
    void              DeleteTreeItem(const long id,const bool redraw=false);
    CTreeItem        *ItemPointer(const long id)                { return(this.FindById(::GetPointer(this.m_root),id)); }
    CTreeItem        *FindItem(const long parent_id,const string text);
    void              ItemState(const long id,const bool state,const bool redraw=false);
    void              SelectTreeItem(const long id,const bool redraw=false);
    long              SelectedItemId(void)                const { return(this.m_selected_item_id); }
    void              UpdateTreeList(const bool redraw=false)   { this.FormTreeList(redraw); }
                     CTreeView(void);
                    ~CTreeView(void) {}
 };
#endif // CTREEVIEW_MQH_DECLARATION
#ifndef CTREEVIEW_MQH_IMPLEMENTATION
#define CTREEVIEW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski CTreeItem colors: pressed C'204,232,255', black text   |
//+------------------------------------------------------------------+
CTreeView::CTreeView(void) : m_items_counter(0),m_selected_item_id(WRONG_VALUE)
 {
  this.m_back_color_pressed =C'204,232,255';
  this.m_label_color_pressed=clrBlack;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTreeView::CreateTreeView(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h)
 {
  if(!this.CreateListView(chart_id,subwin,name,x,y,w,h))
     return(false);
  this.FormTreeList(true);
  return(true);
 }
//+------------------------------------------------------------------+
//| Depth-first search from node                                     |
//+------------------------------------------------------------------+
CTreeItem *CTreeView::FindById(CTreeItem *node,const long id)
 {
  for(int i=0; i<node.ChildrenTotal(); i++)
    {
     CTreeItem *child=node.ChildItem(i);
     if(child==NULL)
        continue;
     if(child.ObjectID()==id)
        return(child);
     CTreeItem *found=this.FindById(child,id);
     if(found!=NULL)
        return(found);
    }
  return(NULL);
 }
//+------------------------------------------------------------------+
//| First child of parent_id (WRONG_VALUE = top level) with the text |
//+------------------------------------------------------------------+
CTreeItem *CTreeView::FindItem(const long parent_id,const string text)
 {
  CTreeItem *parent=(parent_id==WRONG_VALUE ? ::GetPointer(this.m_root) : this.ItemPointer(parent_id));
  if(parent==NULL)
     return(NULL);
  for(int i=0; i<parent.ChildrenTotal(); i++)
    {
     CTreeItem *child=parent.ChildItem(i);
     if(child!=NULL && child.LabelText()==text)
        return(child);
    }
  return(NULL);
 }
//+------------------------------------------------------------------+
//| Adds a child of parent_id (WRONG_VALUE = top level), returns id  |
//+------------------------------------------------------------------+
long CTreeView::AddTreeItem(const long parent_id,const string text,const uint icon=INT_MAX,const bool redraw=false)
 {
  CTreeItem *parent=(parent_id==WRONG_VALUE ? ::GetPointer(this.m_root) : this.ItemPointer(parent_id));
  if(parent==NULL)
     return(WRONG_VALUE);
  CTreeItem *item=new CTreeItem();
  if(item==NULL)
     return(WRONG_VALUE);
  item.SetObjectID(++this.m_items_counter);
  item.LabelText(text);
  item.IconFile(icon);
  if(!parent.AddChild(item))
    {
     delete item;
     return(WRONG_VALUE);
    }
  this.FormTreeList(redraw);
  return(item.ObjectID());
 }
//+------------------------------------------------------------------+
//| Removes the item with its whole branch                           |
//+------------------------------------------------------------------+
void CTreeView::DeleteTreeItem(const long id,const bool redraw=false)
 {
  CTreeItem *item=this.ItemPointer(id);
  if(item==NULL)
     return;
  if(this.m_selected_item_id==id || this.FindById(item,this.m_selected_item_id)!=NULL)
     this.m_selected_item_id=WRONG_VALUE;
  item.Parent().DeleteChild(item);
  delete item;
  this.FormTreeList(redraw);
 }
//+------------------------------------------------------------------+
//| Expands (true) or collapses (false) an item                      |
//+------------------------------------------------------------------+
void CTreeView::ItemState(const long id,const bool state,const bool redraw=false)
 {
  CTreeItem *item=this.ItemPointer(id);
  if(item==NULL || item.ItemState()==state)
     return;
  item.ItemState(state);
  this.FormTreeList(redraw);
 }
//+------------------------------------------------------------------+
//| Selects an item, expanding its parents so it can be seen         |
//+------------------------------------------------------------------+
void CTreeView::SelectTreeItem(const long id,const bool redraw=false)
 {
  CTreeItem *item=this.ItemPointer(id);
  if(item==NULL)
     return;
  this.m_selected_item_id=id;
  for(CTreeItem *parent=item.ParentItem(); parent!=NULL; parent=parent.ParentItem())
     parent.ItemState(true);
  this.FormTreeList(false);
  if(this.m_selected_item!=WRONG_VALUE)
     this.SelectItem(this.m_selected_item,redraw);
 }
//+------------------------------------------------------------------+
//| Appends node's children, and the children of expanded ones       |
//+------------------------------------------------------------------+
void CTreeView::AddRows(CTreeItem *node)
 {
  for(int i=0; i<node.ChildrenTotal(); i++)
    {
     CTreeItem *child=node.ChildItem(i);
     if(child==NULL)
        continue;
     int total=::ArraySize(this.m_rows);
     ::ArrayResize(this.m_rows,total+1,100);
     this.m_rows[total]=child;
     if(child.ItemState())
        this.AddRows(child);
    }
 }
//+------------------------------------------------------------------+
//| Rebuilds the visible rows after any change of the tree           |
//+------------------------------------------------------------------+
void CTreeView::FormTreeList(const bool redraw)
 {
  ::ArrayResize(this.m_rows,0,100);
  this.AddRows(::GetPointer(this.m_root));
  int total=::ArraySize(this.m_rows);
  ::ArrayResize(this.m_items,total);
  this.m_selected_item     =WRONG_VALUE;
  this.m_selected_item_text="";
  this.m_item_index_focus  =WRONG_VALUE;
  for(int i=0; i<total; i++)
    {
     this.m_items[i].m_value=this.m_rows[i].LabelText();
     this.m_items[i].m_state=false;
     if(this.m_rows[i].ObjectID()==this.m_selected_item_id)
       {
        this.m_selected_item     =i;
        this.m_selected_item_text=this.m_items[i].m_value;
       }
    }
  if(this.m_canvas.ChartObjectName()!="")
     this.RecalculateAndResizeList(redraw);
 }
//+------------------------------------------------------------------+
//| Visible rows: highlight by the tree, the rest by the item        |
//+------------------------------------------------------------------+
void CTreeView::DrawContent(void)
 {
  int width  =this.ContentWidth();
  int visible=this.VisibleItemsTotal();
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  for(int r=0; r<visible; r++)
    {
     int i=this.m_visible_list_from_index+r;
     if(i>=::ArraySize(this.m_rows))
        break;
     int y1=1+r*this.m_item_y_size;
     int y2=y1+this.m_item_y_size-1;
     bool selected=(i==this.m_selected_item);
     if(selected)
       {
        this.m_canvas.FillRectangle(1,y1,width-1,y2,::ColorToARGB(this.m_back_color_pressed,255));
        this.m_canvas.Rectangle(1,y1,width-1,y2,::ColorToARGB(C'153,209,255',255));
       }
     else if(this.m_lights_hover && i==this.m_item_index_focus)
        this.m_canvas.FillRectangle(1,y1,width-1,y2,::ColorToARGB(this.m_back_color_hover,255));
     this.m_rows[i].DrawItem(this.m_canvas,y1,this.m_item_y_size,selected ? this.m_label_color_pressed : this.m_label_color);
    }
 }
//+------------------------------------------------------------------+
//| Arrow click expands/collapses, row click selects and shouts      |
//+------------------------------------------------------------------+
void CTreeView::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_mouse_focus)
     return;
  int index=this.ItemIndexAt(x,y);
  if(index==WRONG_VALUE)
     return;
  CTreeItem *item=this.m_rows[index];
  int lx=x-this.m_x;
  int arrow_x=item.ArrowXGap();
  if(item.ChildrenTotal()>0 && lx>=arrow_x && lx<arrow_x+16)
    {
     item.ItemState(!item.ItemState());
     this.FormTreeList(true);
     return;
    }
  this.m_selected_item_id  =item.ObjectID();
  this.m_selected_item     =index;
  this.m_selected_item_text=item.LabelText();
  this.Draw(true);
  this.SendEvent(ON_CHANGE_TREE_PATH,(double)item.ObjectID(),item.LabelText());
 }
#endif // CTREEVIEW_MQH_IMPLEMENTATION
#endif // CTREEVIEW_MQH
