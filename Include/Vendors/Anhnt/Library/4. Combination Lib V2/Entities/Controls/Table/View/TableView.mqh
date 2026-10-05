//+------------------------------------------------------------------+
//|                                                    TableView.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEVIEW_MQH
#define CTABLEVIEW_MQH
 #include "..\..\ListView.mqh"
 #include "..\..\Scrolls\ScrollH.mqh"
 #include "..\..\TextBox.mqh"
 #include "..\..\Pointer.mqh"
 #include "TableRowView.mqh"
 #include "..\Model\TableModel.mqh"
#ifndef CTABLEVIEW_MQH_DECLARATION
#define CTABLEVIEW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| One canvas: header strip + visible rows; Update() redraws only   |
//| changed cells; one shared edit box / list opens over a cell      |
//+------------------------------------------------------------------+
class CTableView : public CGElement
 {
  protected:
    CTableModel      *m_model;
    CTableHeaderView  m_header_view;
    CTableRowView    *m_rows[];
    CTableRowView    *m_hidden_rows[];
    CScrollV          m_scrollv;
    CScrollH          m_scrollh;
    CTextBox          m_edit;
    CListView         m_listview;
    CPointer          m_column_resize;
    int               m_header_y_size;
    int               m_cell_y_size;
    bool              m_show_headers;
    bool              m_lights_hover;
    bool              m_selectable_row;
    bool              m_is_sort_mode;
    color             m_grid_color;
    color             m_headers_color;
    color             m_headers_color_hover;
    color             m_headers_text_color;
    color             m_cell_color;
    color             m_cell_color_hover;
    color             m_label_color;
    color             m_selected_row_color;
    color             m_selected_row_text_color;
    int               m_selected_item;
    int               m_item_index_focus;
    int               m_visible_table_from_index;
    int               m_last_edit_column_index;
    int               m_last_edit_row_index;
    string            m_edit_value;
    int               m_min_column_width;
    int               m_column_resize_control;
    int               m_column_resize_x_fixed;
    int               m_column_resize_prev_width;
    int               m_shift_x_step;
    string            m_filter_hidden[];
    int               m_filter_column;

    int               RowsTop(void)                        const { return(this.m_show_headers ? 1+this.m_header_y_size : 1); }
    int               RowsBottom(void)                     const { return(this.m_y_size-1-(this.m_scrollh.IsVisible() ? 16 : 0)); }
    void              DrawBorder(void);
    bool              InHeader(const int y)                const { return(this.m_show_headers && y-this.m_y>=1 && y-this.m_y<=this.m_header_y_size); }
    int               ContentRight(void);
    int               RowIndexAt(const int x,const int y);
    void              RecalculateAndResizeTable(const bool redraw);
    void              DrawRowAt(const int row);
    void              DrawHeaderStrip(void);
    void              OpenEdit(const int column,const int row);
    void              OpenComboList(const int column,const int row);
    void              OpenFilterList(const int column);
    void              CommitFilter(void);
    void              FiltersReset(void);
    bool              RowPasses(CTableRow *row);
    int               ModelRowIndex(const int row);
    void              CheckEditEnd(void);
    void              CloseOverlays(void);
    void              UpdateResizePointer(void);
    virtual void      InitColors(void);
    virtual void      DrawContent(void);
    virtual void      OnBlur(void);
    virtual void      OnPress(const int x,const int y);
    virtual void      OnMove(const int x,const int y);
    virtual void      OnRelease(const int x,const int y);
    virtual void      MouseActiveAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam);
  public:
    bool              CreateTableView(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h);
    void              Bind(CTableModel *model)                   { this.m_model=model; this.m_header_view.Bind(model.Header()); }
    void              Rebuild(const bool redraw=false,const bool keep_filter=false);
    void              ClearFilters(const bool redraw=false);
    CTableRowView    *RowViewByModel(const int model_row);
    CTableHeaderView *GetHeaderViewPointer(void)                 { return(::GetPointer(this.m_header_view)); }
    CScrollV         *GetScrollVPointer(void)                    { return(::GetPointer(this.m_scrollv));     }
    CScrollH         *GetScrollHPointer(void)                    { return(::GetPointer(this.m_scrollh));     }
    CTextBox         *GetTextBoxPointer(void)                    { return(::GetPointer(this.m_edit));        }
    CListView        *GetListViewPointer(void)                   { return(::GetPointer(this.m_listview));    }
    CTableRowView    *RowView(const int row)                     { return(row>=0 && row<::ArraySize(this.m_rows) ? this.m_rows[row] : NULL); }
    CTableCellView   *CellView(const int column,const int row);
    void              ShowHeaders(const bool flag)               { this.m_show_headers=flag;      }
    void              HeaderYSize(const int y_size)              { this.m_header_y_size=y_size;   }
    void              CellYSize(const int y_size)                { this.m_cell_y_size=y_size;     }
    void              LightsHover(const bool flag)               { this.m_lights_hover=flag;      }
    void              SelectableRow(const bool flag)             { this.m_selectable_row=flag;    }
    void              IsSortMode(const bool flag)                { this.m_is_sort_mode=flag;      }
    void              IsFilterMode(const int column,const bool flag) { this.m_header_view.FilterMode(column,flag); }
    void              ColumnResizeMode(const bool flag,const int column=-1) { this.m_header_view.ColumnResizeMode(column,flag); }
    void              MinColumnWidth(const int width)            { this.m_min_column_width=(width>3 ? width : 3); }
    void              GridColor(const color clr)                 { this.m_grid_color=clr;         }
    void              HeadersColor(const color clr)              { this.m_headers_color=clr;      }
    void              HeadersColorHover(const color clr)         { this.m_headers_color_hover=clr; }
    void              HeadersTextColor(const color clr)          { this.m_headers_text_color=clr; }
    void              CellColor(const color clr)                 { this.m_cell_color=clr;         }
    void              CellColorHover(const color clr)            { this.m_cell_color_hover=clr;   }
    string            EditedValue(void)                    const { return(this.m_edit_value);     }
    int               VisibleRowsTotal(void);
    int               SelectedItem(void)                   const { return(this.m_selected_item);    }
    int               HoveredRow(void)                     const { return(this.m_item_index_focus); }
    void              SelectRow(const int row,const bool redraw=false);
    void              Scrolling(const int pos=WRONG_VALUE);
    void              ChangeSize(const int w,const int h);
    bool              Update(const bool redraw=false);
    virtual void      Show(void);
    virtual void      Hide(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CTableView(void);
                    ~CTableView(void) {}
 };
#endif // CTABLEVIEW_MQH_DECLARATION
#ifndef CTABLEVIEW_MQH_IMPLEMENTATION
#define CTABLEVIEW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski CTable defaults                                        |
//+------------------------------------------------------------------+
CTableView::CTableView(void) : m_model(NULL),
                               m_header_y_size(20),
                               m_cell_y_size(20),
                               m_show_headers(false),
                               m_lights_hover(false),
                               m_selectable_row(false),
                               m_is_sort_mode(false),
                               m_grid_color(clrLightGray),
                               m_headers_color(C'255,244,213'),
                               m_headers_color_hover(C'229,241,251'),
                               m_headers_text_color(clrBlack),
                               m_cell_color(clrWhite),
                               m_cell_color_hover(C'229,243,255'),
                               m_label_color(clrBlack),
                               m_selected_row_color(C'51,153,255'),
                               m_selected_row_text_color(clrWhite),
                               m_selected_item(WRONG_VALUE),
                               m_item_index_focus(WRONG_VALUE),
                               m_visible_table_from_index(0),
                               m_last_edit_column_index(WRONG_VALUE),
                               m_last_edit_row_index(WRONG_VALUE),
                               m_edit_value(""),
                               m_min_column_width(30),
                               m_column_resize_control(WRONG_VALUE),
                               m_column_resize_x_fixed(0),
                               m_column_resize_prev_width(0),
                               m_shift_x_step(10),
                               m_filter_column(WRONG_VALUE)
 {
 }
//+------------------------------------------------------------------+
//| White table, border in the grid color                            |
//+------------------------------------------------------------------+
void CTableView::InitColors(void)
 {
  this.m_color_background.InitColors(this.m_cell_color,this.m_cell_color,this.m_cell_color,clrWhiteSmoke);
  this.m_color_foreground.InitColors(this.m_label_color,this.m_label_color,this.m_label_color,clrGray);
  this.m_color_border.InitColors(this.m_grid_color,this.m_grid_color,this.m_grid_color,this.m_grid_color);
  this.m_color_background_act.InitColors(this.m_cell_color,this.m_cell_color,this.m_cell_color,clrWhiteSmoke);
  this.m_color_foreground_act.InitColors(this.m_label_color,this.m_label_color,this.m_label_color,clrGray);
  this.m_color_border_act.InitColors(this.m_grid_color,this.m_grid_color,this.m_grid_color,this.m_grid_color);
 }
//+------------------------------------------------------------------+
//| Scrollbar under the header; hidden edit box, list and pointer    |
//+------------------------------------------------------------------+
bool CTableView::CreateTableView(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h)
 {
  if(this.m_model==NULL || !this.Create(chart_id,subwin,name,x,y,w,h))
     return(false);
  this.AddChild(::GetPointer(this.m_header_view));
  this.AddChild(::GetPointer(this.m_scrollv));
  int top=this.RowsTop();
  if(!this.m_scrollv.CreateScroll(chart_id,subwin,this.Name()+"_scrollv",w-16,top,15,h-top-1,1,1))
     return(false);
  this.AddChild(::GetPointer(this.m_scrollh));
  if(!this.m_scrollh.CreateScroll(chart_id,subwin,this.Name()+"_scrollh",1,h-16,w-2,15,1,1))
     return(false);
  this.AddChild(::GetPointer(this.m_edit));
  if(!this.m_edit.CreateTextBox(chart_id,subwin,this.Name()+"_edit",0,0,100,this.m_cell_y_size-1))
     return(false);
  this.m_edit.Hide();
  this.AddChild(::GetPointer(this.m_listview));
  this.m_listview.LightsHover(true);
  if(!this.m_listview.CreateListView(chart_id,subwin,this.Name()+"_list",0,0,120,93))
     return(false);
  this.m_listview.Hide();
  this.m_column_resize.XGap(8);
  this.m_column_resize.YGap(8);
  this.m_column_resize.Type(MP_X_RESIZE);
  if(!this.m_column_resize.CreatePointer(chart_id,subwin))
     return(false);
  this.Rebuild(true);
  return(true);
 }
//+------------------------------------------------------------------+
//| Row views follow the model rows by identity, so their cell       |
//| settings and the selection survive sorting and deleting.         |
//| New data shows every row; keep_filter keeps the column filters   |
//+------------------------------------------------------------------+
void CTableView::Rebuild(const bool redraw=false,const bool keep_filter=false)
 {
  if(this.m_model==NULL)
     return;
  this.CloseOverlays();
  this.m_header_view.ColumnsInit((int)this.m_model.ColumnsTotal());
  if(keep_filter)
     ::ArrayResize(this.m_filter_hidden,this.m_header_view.ColumnsTotal());
  else
     this.FiltersReset();
  int total=(int)this.m_model.RowsTotal();
  int size =::ArraySize(this.m_rows);
  int hidden=::ArraySize(this.m_hidden_rows);
  CTableRow *selected=(this.m_selected_item>=0 && this.m_selected_item<size ? this.m_rows[this.m_selected_item].Row() : NULL);
  CTableRowView *old[];
  ::ArrayResize(old,size+hidden);
  for(int i=0; i<size; i++)
     old[i]=this.m_rows[i];
  for(int i=0; i<hidden; i++)
     old[size+i]=this.m_hidden_rows[i];
  size+=hidden;
  CTableRowView *rows[];
  ::ArrayResize(rows,total);
  for(int i=0; i<total; i++)
    {
     rows[i]=NULL;
     CTableRow *model_row=this.m_model.Row(i);
     for(int j=0; j<size && rows[i]==NULL; j++)
        if(old[j]!=NULL && old[j].Row()==model_row)
          {
           rows[i]=old[j];
           old[j]=NULL;
          }
    }
  int next=0;
  for(int i=0; i<total; i++)
    {
     if(rows[i]!=NULL)
        continue;
     while(next<size && old[next]==NULL)
        next++;
     if(next<size)
       {
        rows[i]=old[next];
        old[next]=NULL;
       }
     else
       {
        rows[i]=new CTableRowView();
        this.AddChild(rows[i]);
       }
    }
  for(int j=0; j<size; j++)
    {
     if(old[j]==NULL)
        continue;
     this.DeleteChild(old[j]);
     delete old[j];
    }
  ::ArrayResize(this.m_rows,0);
  ::ArrayResize(this.m_hidden_rows,0);
  this.m_selected_item=WRONG_VALUE;
  for(int i=0; i<total; i++)
    {
     CTableRow *model_row=this.m_model.Row(i);
     rows[i].Bind(model_row);
     if(!this.RowPasses(model_row))
       {
        int h=::ArraySize(this.m_hidden_rows);
        ::ArrayResize(this.m_hidden_rows,h+1,100);
        this.m_hidden_rows[h]=rows[i];
        continue;
       }
     int v=::ArraySize(this.m_rows);
     ::ArrayResize(this.m_rows,v+1,100);
     this.m_rows[v]=rows[i];
     if(selected!=NULL && model_row==selected)
        this.m_selected_item=v;
    }
  this.m_item_index_focus=WRONG_VALUE;
  if(this.m_canvas.ChartObjectName()!="")
     this.RecalculateAndResizeTable(redraw);
 }
//+------------------------------------------------------------------+
//| Every column shows every value again                             |
//+------------------------------------------------------------------+
void CTableView::FiltersReset(void)
 {
  int total=this.m_header_view.ColumnsTotal();
  ::ArrayResize(this.m_filter_hidden,total);
  for(int i=0; i<total; i++)
    {
     this.m_filter_hidden[i]="";
     this.m_header_view.FilterActive(i,false);
    }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableView::ClearFilters(const bool redraw=false)
 {
  this.FiltersReset();
  this.Rebuild(redraw,true);
 }
//+------------------------------------------------------------------+
//| A column hides a row when its value is in the hidden list;       |
//| the list is "\x01value\x01value\x01", empty = no filter          |
//+------------------------------------------------------------------+
bool CTableView::RowPasses(CTableRow *row)
 {
  string sep=::ShortToString(1);
  for(int c=0; c<::ArraySize(this.m_filter_hidden); c++)
    {
     if(this.m_filter_hidden[c]=="")
        continue;
     CTableCell *cell=row.Cell(c);
     if(cell!=NULL && ::StringFind(this.m_filter_hidden[c],sep+cell.Value()+sep)>=0)
        return(false);
    }
  return(true);
 }
//+------------------------------------------------------------------+
//| Displayed row -> model row (what the events carry)               |
//+------------------------------------------------------------------+
int CTableView::ModelRowIndex(const int row)
 {
  if(row<0 || row>=::ArraySize(this.m_rows) || this.m_rows[row].Row()==NULL)
     return(WRONG_VALUE);
  return(this.m_rows[row].Row().Index());
 }
//+------------------------------------------------------------------+
//| Row view of a model row, filtered-out rows included              |
//+------------------------------------------------------------------+
CTableRowView *CTableView::RowViewByModel(const int model_row)
 {
  if(this.ModelRowIndex(model_row)==model_row)
     return(this.m_rows[model_row]);
  for(int i=0; i<::ArraySize(this.m_rows); i++)
     if(this.m_rows[i].Row()!=NULL && this.m_rows[i].Row().Index()==model_row)
        return(this.m_rows[i]);
  for(int i=0; i<::ArraySize(this.m_hidden_rows); i++)
     if(this.m_hidden_rows[i].Row()!=NULL && this.m_hidden_rows[i].Row().Index()==model_row)
        return(this.m_hidden_rows[i]);
  return(NULL);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTableCellView *CTableView::CellView(const int column,const int row)
 {
  CTableRowView *row_view=this.RowView(row);
  return(row_view!=NULL ? row_view.CellView(column) : NULL);
 }
//+------------------------------------------------------------------+
//| Rows that fit under the header strip                             |
//+------------------------------------------------------------------+
int CTableView::VisibleRowsTotal(void)
 {
  int visible=(this.RowsBottom()-this.RowsTop())/this.m_cell_y_size;
  return(visible<1 ? 1 : visible);
 }
//+------------------------------------------------------------------+
//| Last drawable x (scrollbar or right border excluded)             |
//+------------------------------------------------------------------+
int CTableView::ContentRight(void)
 {
  return(this.m_scrollv.IsVisible() ? this.m_x_size-18 : this.m_x_size-2);
 }
//+------------------------------------------------------------------+
//| Row under chart x,y, WRONG_VALUE outside the rows                |
//+------------------------------------------------------------------+
int CTableView::RowIndexAt(const int x,const int y)
 {
  int lx=x-this.m_x;
  int ly=y-this.m_y-this.RowsTop();
  if(lx<1 || lx>this.ContentRight() || ly<0)
     return(WRONG_VALUE);
  int r=ly/this.m_cell_y_size;
  if(r>=this.VisibleRowsTotal())
     return(WRONG_VALUE);
  int row=this.m_visible_table_from_index+r;
  return(row<::ArraySize(this.m_rows) ? row : WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Both scrollbars: each one's room depends on the other being shown|
//+------------------------------------------------------------------+
void CTableView::RecalculateAndResizeTable(const bool redraw)
 {
  int  total  =::ArraySize(this.m_rows);
  int  columns=this.m_header_view.ColumnsWidthTotal();
  int  top    =this.RowsTop();
  bool need_h =(columns>this.m_x_size-2);
  bool need_v =(total>(this.m_y_size-1-(need_h ? 16 : 0)-top)/this.m_cell_y_size);
  if(need_v && !need_h)
    {
     need_h=(columns>this.m_x_size-18);
     need_v=(total>(this.m_y_size-1-(need_h ? 16 : 0)-top)/this.m_cell_y_size);
    }
  int visible =::MathMax((this.m_y_size-1-(need_h ? 16 : 0)-top)/this.m_cell_y_size,1);
  int max_from=::MathMax(total-visible,0);
  if(this.m_visible_table_from_index>max_from)
     this.m_visible_table_from_index=max_from;
  this.m_scrollv.ChangeYSize(this.m_y_size-top-1-(need_h ? 16 : 0));
  this.m_scrollv.ChangeThumbSize(::MathMax(total,1),visible);
  if(need_v && this.IsVisible())
     this.m_scrollv.Show();
  else
     this.m_scrollv.Hide();
  this.m_scrollv.MovingThumb(this.m_visible_table_from_index);
  int view_w   =this.m_x_size-2-(need_v ? 16 : 0);
  int max_shift=::MathMax(columns-view_w,0);
  int shift    =::MathMin(this.m_header_view.ShiftX(),max_shift);
  this.m_header_view.ShiftX(shift);
  this.m_scrollh.ChangeXSize(view_w);
  this.m_scrollh.ChangeThumbSize(::MathMax((columns+this.m_shift_x_step-1)/this.m_shift_x_step,1),::MathMax(view_w/this.m_shift_x_step,1));
  if(need_h && this.IsVisible())
     this.m_scrollh.Show();
  else
     this.m_scrollh.Hide();
  this.m_scrollh.MovingThumb(shift/this.m_shift_x_step);
  this.Draw(redraw);
 }
//+------------------------------------------------------------------+
//| Cells scrolled out at left may paint over the border             |
//+------------------------------------------------------------------+
void CTableView::DrawBorder(void)
 {
  this.m_canvas.Rectangle(0,0,this.m_x_size-1,this.m_y_size-1,::ColorToARGB(this.m_grid_color,255));
 }
//+------------------------------------------------------------------+
//| Full row with its state colors, if visible                       |
//+------------------------------------------------------------------+
void CTableView::DrawRowAt(const int row)
 {
  int r=row-this.m_visible_table_from_index;
  if(row<0 || row>=::ArraySize(this.m_rows) || r<0 || r>=this.VisibleRowsTotal())
     return;
  bool  selected=(row==this.m_selected_item);
  color back=(selected ? this.m_selected_row_color : (this.m_lights_hover && row==this.m_item_index_focus ? this.m_cell_color_hover : this.m_cell_color));
  color text=(selected ? this.m_selected_row_text_color : this.m_label_color);
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  this.m_rows[row].DrawRow(this.m_canvas,this.m_header_view,this.RowsTop()+r*this.m_cell_y_size,this.m_cell_y_size,this.ContentRight(),back,text,this.m_grid_color,selected);
  this.m_rows[row].ResetChanged();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableView::DrawHeaderStrip(void)
 {
  if(!this.m_show_headers)
     return;
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  this.m_header_view.DrawHeader(this.m_canvas,1,this.m_header_y_size,this.m_x_size-2,this.m_headers_color,this.m_headers_color_hover,this.m_headers_text_color,this.m_grid_color,this.m_selected_row_color);
 }
//+------------------------------------------------------------------+
//| Header strip + every visible row                                 |
//+------------------------------------------------------------------+
void CTableView::DrawContent(void)
 {
  this.DrawHeaderStrip();
  int visible=this.VisibleRowsTotal();
  for(int r=0; r<visible; r++)
     this.DrawRowAt(this.m_visible_table_from_index+r);
  this.DrawBorder();
 }
//+------------------------------------------------------------------+
//| Only changed cells of the visible rows, one canvas update;       |
//| true if anything was drawn                                       |
//+------------------------------------------------------------------+
bool CTableView::Update(const bool redraw=false)
 {
  bool drawn=false;
  int  visible=this.VisibleRowsTotal();
  int  right=this.ContentRight();
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  for(int r=0; r<visible; r++)
    {
     int row=this.m_visible_table_from_index+r;
     if(row>=::ArraySize(this.m_rows))
        break;
     if(!this.m_rows[row].IsChanged())
        continue;
     bool  selected=(row==this.m_selected_item);
     color back=(selected ? this.m_selected_row_color : (this.m_lights_hover && row==this.m_item_index_focus ? this.m_cell_color_hover : this.m_cell_color));
     color text=(selected ? this.m_selected_row_text_color : this.m_label_color);
     int   y=this.RowsTop()+r*this.m_cell_y_size;
     for(int c=0; c<this.m_rows[row].CellsTotal(); c++)
       {
        CTableCellView *view=this.m_rows[row].CellView(c);
        if(view==NULL || view.Cell()==NULL || !view.Cell().IsEvent())
           continue;
        this.m_rows[row].DrawCellAt(this.m_canvas,this.m_header_view,c,y,this.m_cell_y_size,right,back,text,this.m_grid_color,selected);
        view.Cell().SetEventFlag(false);
        drawn=true;
       }
    }
  if(!drawn)
     return(false);
  if(this.m_header_view.ShiftX()>0)
     this.DrawBorder();
  this.m_canvas.Update(redraw);
  return(true);
 }
//+------------------------------------------------------------------+
//| Selects a row (WRONG_VALUE = none) and scrolls it into view      |
//+------------------------------------------------------------------+
void CTableView::SelectRow(const int row,const bool redraw=false)
 {
  int prev=this.m_selected_item;
  this.m_selected_item=(row>=0 && row<::ArraySize(this.m_rows) ? row : WRONG_VALUE);
  int visible=this.VisibleRowsTotal();
  if(this.m_selected_item!=WRONG_VALUE && this.m_selected_item<this.m_visible_table_from_index)
     this.Scrolling(this.m_selected_item);
  else if(this.m_selected_item!=WRONG_VALUE && this.m_selected_item>=this.m_visible_table_from_index+visible)
     this.Scrolling(this.m_selected_item-visible+1);
  else
    {
     this.DrawRowAt(prev);
     this.DrawRowAt(this.m_selected_item);
     this.m_canvas.Update(redraw);
    }
 }
//+------------------------------------------------------------------+
//| First visible row = pos (end if WRONG_VALUE)                     |
//+------------------------------------------------------------------+
void CTableView::Scrolling(const int pos=WRONG_VALUE)
 {
  int max_from=::MathMax(::ArraySize(this.m_rows)-this.VisibleRowsTotal(),0);
  int from=(pos==WRONG_VALUE || pos>max_from) ? max_from : (pos<0 ? 0 : pos);
  if(from==this.m_visible_table_from_index)
     return;
  this.CloseOverlays();
  this.m_visible_table_from_index=from;
  this.m_scrollv.MovingThumb(from);
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| New table size: scrollbar follows the right edge and the height  |
//+------------------------------------------------------------------+
void CTableView::ChangeSize(const int w,const int h)
 {
  if(w<1 || h<1 || (w==this.m_x_size && h==this.m_y_size))
     return;
  this.CloseOverlays();
  this.Resize(w,h);
  int top=this.RowsTop();
  this.m_scrollv.Move(this.m_x+w-16,this.m_y+top);
  this.m_scrollh.Move(this.m_x+1,this.m_y+h-16);
  this.RecalculateAndResizeTable(false);
 }
//+------------------------------------------------------------------+
//| Edit box over the cell, text selected                            |
//+------------------------------------------------------------------+
void CTableView::OpenEdit(const int column,const int row)
 {
  CTableCellView *view=this.CellView(column,row);
  int r=row-this.m_visible_table_from_index;
  if(view==NULL || view.Cell()==NULL || r<0 || r>=this.VisibleRowsTotal())
     return;
  int left=this.m_header_view.ColumnX(column);
  int cx  =::MathMax(left,1);
  int w   =::MathMin(left+this.m_header_view.ColumnWidth(column)-1,this.ContentRight()+1)-cx;
  this.m_edit.Resize(w,this.m_cell_y_size-1);
  this.m_edit.Move(this.m_x+cx,this.m_y+this.RowsTop()+r*this.m_cell_y_size);
  this.m_edit.SetValue(view.Cell().Value());
  this.m_edit.Show();
  this.m_edit.ActivateTextBox(true);
  this.m_last_edit_column_index=column;
  this.m_last_edit_row_index   =row;
 }
//+------------------------------------------------------------------+
//| Shared list under the cell with its choices, others blocked      |
//+------------------------------------------------------------------+
void CTableView::OpenComboList(const int column,const int row)
 {
  CTableCellView *view=this.CellView(column,row);
  int r=row-this.m_visible_table_from_index;
  if(view==NULL || view.ValueListTotal()<1 || r<0 || r>=this.VisibleRowsTotal())
     return;
  int total=view.ValueListTotal();
  this.m_listview.CheckBoxMode(false);
  this.m_listview.Rebuilding(total,false);
  for(int i=0; i<total; i++)
     this.m_listview.SetValue(i,view.ValueListItem(i));
  this.m_listview.Move(this.m_x+::MathMax(this.m_header_view.ColumnX(column),1),this.m_y+this.RowsTop()+(r+1)*this.m_cell_y_size);
  this.m_listview.Show();
  int selected=view.ValueListIndex();
  if(selected!=WRONG_VALUE)
     this.m_listview.SelectItem(selected,true);
  else
     this.m_listview.Draw(true);
  this.m_last_edit_column_index=column;
  this.m_last_edit_row_index   =row;
  ::EventChartCustom(this.m_chart_id,ON_SET_AVAILABLE,this.ObjectID(),0,"");
 }
//+------------------------------------------------------------------+
//| Excel-like list under the header: "(All)" + the distinct values  |
//| of the column in its own sort order, checked = shown             |
//+------------------------------------------------------------------+
void CTableView::OpenFilterList(const int column)
 {
  if(column<0 || column>=::ArraySize(this.m_filter_hidden))
     return;
  CTableRow *sample[];
  string     value[];
  int        total=0;
  for(uint r=0; r<this.m_model.RowsTotal(); r++)
    {
     CTableRow  *row =this.m_model.Row(r);
     CTableCell *cell=(row!=NULL ? row.Cell(column) : NULL);
     if(cell==NULL)
        continue;
     string text=cell.Value();
     bool   found=false;
     for(int i=0; i<total && !found; i++)
        found=(value[i]==text);
     if(found)
        continue;
     ::ArrayResize(sample,total+1,100);
     ::ArrayResize(value,total+1,100);
     int pos=total++;
     while(pos>0 && sample[pos-1].Compare(row,column)>0)
       {
        sample[pos]=sample[pos-1];
        value[pos] =value[pos-1];
        pos--;
       }
     sample[pos]=row;
     value[pos] =text;
    }
  string sep=::ShortToString(1);
  bool   all=true;
  this.m_listview.CheckBoxMode(true);
  this.m_listview.Rebuilding(total+1,false);
  for(int i=0; i<total; i++)
    {
     bool shown=(::StringFind(this.m_filter_hidden[column],sep+value[i]+sep)<0);
     this.m_listview.SetValue(i+1,value[i]);
     this.m_listview.SetState(i+1,shown);
     all=(all && shown);
    }
  this.m_listview.SetValue(0,"(All)");
  this.m_listview.SetState(0,all);
  this.m_listview.Move(this.m_x+::MathMax(this.m_header_view.ColumnX(column),1),this.m_y+this.RowsTop());
  this.m_listview.Show();
  this.m_listview.Draw(true);
  this.m_filter_column=column;
  ::EventChartCustom(this.m_chart_id,ON_SET_AVAILABLE,this.ObjectID(),0,"");
 }
//+------------------------------------------------------------------+
//| List closed by an outside click: unchecked values become hidden  |
//+------------------------------------------------------------------+
void CTableView::CommitFilter(void)
 {
  int column=this.m_filter_column;
  if(column==WRONG_VALUE || column>=::ArraySize(this.m_filter_hidden) || !this.m_listview.IsVisible())
     return;
  string sep=::ShortToString(1);
  string hidden="";
  for(int i=1; i<this.m_listview.ItemsTotal(); i++)
    {
     if(this.m_listview.GetState(i))
        continue;
     if(hidden=="")
        hidden=sep;
     hidden+=this.m_listview.GetValue(i)+sep;
    }
  this.m_filter_hidden[column]=hidden;
  this.m_header_view.FilterActive(column,hidden!="");
  this.m_visible_table_from_index=0;
  this.Rebuild(true,true);
 }
//+------------------------------------------------------------------+
//| Edit box left edit mode (Enter, Esc, outside press): shout once  |
//| with the text kept for the controller                            |
//+------------------------------------------------------------------+
void CTableView::CheckEditEnd(void)
 {
  if(this.m_last_edit_column_index==WRONG_VALUE || !this.m_edit.IsVisible() || this.m_edit.TextEditState())
     return;
  int column=this.m_last_edit_column_index;
  int row   =this.m_last_edit_row_index;
  this.m_edit_value=this.m_edit.GetValue();
  this.m_edit.Hide();
  this.m_last_edit_column_index=WRONG_VALUE;
  this.m_last_edit_row_index   =WRONG_VALUE;
  int model_row=this.ModelRowIndex(row);
  this.SendEvent(ON_END_EDIT,model_row,(string)column+"_"+(string)model_row);
  ::ChartRedraw(this.m_chart_id);
 }
//+------------------------------------------------------------------+
//| Cancels the edit box and closes the list                         |
//+------------------------------------------------------------------+
void CTableView::CloseOverlays(void)
 {
  if(this.m_listview.IsVisible())
    {
     this.m_listview.Hide();
     ::EventChartCustom(this.m_chart_id,ON_SET_AVAILABLE,this.ObjectID(),1,"");
    }
  if(this.m_edit.IsVisible())
     this.m_edit.Hide();
  this.m_last_edit_column_index=WRONG_VALUE;
  this.m_last_edit_row_index   =WRONG_VALUE;
  this.m_filter_column         =WRONG_VALUE;
 }
//+------------------------------------------------------------------+
//| Resize pointer on a header column border or while dragging       |
//+------------------------------------------------------------------+
void CTableView::UpdateResizePointer(void)
 {
  int  mx=s_mouse.X();
  int  my=s_mouse.Y();
  bool show=(this.m_column_resize_control!=WRONG_VALUE ||
             (this.m_mouse_focus && !s_mouse.IsLeftBtn() && this.InHeader(my) &&
              this.m_header_view.ColumnBorderAt(mx-this.m_x,3)!=WRONG_VALUE));
  if(!show)
    {
     if(this.m_column_resize.IsVisible())
       {
        this.m_column_resize.Hide();
        ::ChartRedraw(this.m_chart_id);
       }
     return;
    }
  this.m_column_resize.Moving(mx,my);
  if(!this.m_column_resize.IsVisible())
    {
     this.m_column_resize.Draw(false);
     this.m_column_resize.Show();
    }
  ::ChartRedraw(this.m_chart_id);
 }
//+------------------------------------------------------------------+
//| Mouse left the table: no hovered row or caption                  |
//+------------------------------------------------------------------+
void CTableView::OnBlur(void)
 {
  CGElement::OnBlur();
  if(this.m_header_view.HeaderFocus(WRONG_VALUE))
    {
     this.DrawHeaderStrip();
     this.m_canvas.Update(true);
    }
  if(this.m_item_index_focus==WRONG_VALUE)
     return;
  int prev=this.m_item_index_focus;
  this.m_item_index_focus=WRONG_VALUE;
  this.DrawRowAt(prev);
  this.m_canvas.Update(true);
 }
//+------------------------------------------------------------------+
//| Press on a caption border starts a column resize                 |
//+------------------------------------------------------------------+
void CTableView::OnPress(const int x,const int y)
 {
  CGElement::OnPress(x,y);
  if(this.m_listview.IsVisible() || !this.InHeader(y))
     return;
  int column=this.m_header_view.ColumnBorderAt(x-this.m_x,3);
  if(column==WRONG_VALUE)
     return;
  this.m_column_resize_control   =column;
  this.m_column_resize_x_fixed   =x;
  this.m_column_resize_prev_width=this.m_header_view.ColumnWidth(column);
 }
//+------------------------------------------------------------------+
//| Dragging a column border                                         |
//+------------------------------------------------------------------+
void CTableView::OnMove(const int x,const int y)
 {
  if(this.m_column_resize_control==WRONG_VALUE)
     return;
  int width=::MathMax(this.m_min_column_width,this.m_column_resize_prev_width+x-this.m_column_resize_x_fixed);
  if(width==this.m_header_view.ColumnWidth(this.m_column_resize_control))
     return;
  this.m_header_view.ColumnWidth(this.m_column_resize_control,width);
  this.RecalculateAndResizeTable(true);
 }
//+------------------------------------------------------------------+
//| Kazharski events, sparam "column_row": caption = sort request,   |
//| checkbox/button cells, combobox/edit cells open their overlay,   |
//| then row selection                                               |
//+------------------------------------------------------------------+
void CTableView::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  this.CheckEditEnd();
  if(this.m_column_resize_control!=WRONG_VALUE)
    {
     this.m_column_resize_control=WRONG_VALUE;
     return;
    }
  if(this.m_listview.IsVisible())
    {
     if(!this.m_listview.MouseFocus())
       {
        this.CommitFilter();
        this.CloseOverlays();
       }
     return;
    }
  if(!this.m_mouse_focus || (this.m_edit.IsVisible() && this.m_edit.MouseFocus()))
     return;
  if(this.InHeader(y))
    {
     int filter=this.m_header_view.FilterButtonAt(x-this.m_x);
     if(filter!=WRONG_VALUE)
       {
        this.OpenFilterList(filter);
        return;
       }
     int caption=this.m_header_view.ColumnAt(x-this.m_x);
     if(this.m_is_sort_mode && caption!=WRONG_VALUE)
        this.SendEvent(ON_SORT_DATA,caption,"");
     return;
    }
  int row=this.RowIndexAt(x,y);
  int column=(row!=WRONG_VALUE ? this.m_header_view.ColumnAt(x-this.m_x) : WRONG_VALUE);
  if(column==WRONG_VALUE)
     return;
  int model_row=this.ModelRowIndex(row);
  string cell_id=(string)column+"_"+(string)model_row;
  CTableCellView *view=this.CellView(column,row);
  ENUM_TYPE_CELL type=(view!=NULL ? view.CellType() : CELL_SIMPLE);
  if(type==CELL_CHECKBOX)
     this.SendEvent(ON_CLICK_CHECKBOX,model_row,cell_id);
  else if(type==CELL_BUTTON)
     this.SendEvent(ON_CLICK_BUTTON,model_row,cell_id);
  if(this.m_selectable_row)
    {
     this.SelectRow(row,true);
     this.SendEvent(ON_CLICK_LIST_ITEM,model_row,cell_id);
    }
  if(type==CELL_COMBOBOX)
     this.OpenComboList(column,row);
  else if(type==CELL_EDIT)
     this.OpenEdit(column,row);
 }
//+------------------------------------------------------------------+
//| Wheel over the rows scrolls the table (not while the list is up) |
//+------------------------------------------------------------------+
void CTableView::MouseActiveAreaWhellHandler(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  if(s_mouse.IsCtrl() || this.m_listview.IsVisible() || s_mouse.X()-this.m_x>this.ContentRight())
     return;
  this.Scrolling(this.m_visible_table_from_index+(s_mouse.DeltaWheel()>0 ? -1 : 1));
 }
//+------------------------------------------------------------------+
//| Base Show cascades to the children: overlays stay closed         |
//+------------------------------------------------------------------+
void CTableView::Show(void)
 {
  CGElement::Show();
  this.m_edit.Hide();
  this.m_listview.Hide();
  //--- Scrollbars by pixels, not IsScroll()'s rounded steps
  this.RecalculateAndResizeTable(false);
 }
//+------------------------------------------------------------------+
//| Hiding closes the overlays (unblocking the others)               |
//+------------------------------------------------------------------+
void CTableView::Hide(void)
 {
  this.CloseOverlays();
  this.m_column_resize.Hide();
  CGElement::Hide();
 }
//+------------------------------------------------------------------+
//| Scroll, list choice, edit end, outside press, hover, pointer     |
//+------------------------------------------------------------------+
void CTableView::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  bool prev_left=this.m_prev_left;
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(!this.IsVisible())
     return;
  this.CheckEditEnd();
  if(id==CHARTEVENT_CUSTOM+ON_SCROLL_CHANGE)
    {
     if(lparam==this.m_scrollv.ObjectID() && (int)dparam!=this.m_visible_table_from_index)
       {
        this.CloseOverlays();
        this.m_visible_table_from_index=(int)dparam;
        this.Draw(true);
       }
     if(lparam==this.m_scrollh.ObjectID())
       {
        int view_w=this.m_x_size-2-(this.m_scrollv.IsVisible() ? 16 : 0);
        int shift =::MathMin((int)dparam*this.m_shift_x_step,::MathMax(this.m_header_view.ColumnsWidthTotal()-view_w,0));
        if(shift!=this.m_header_view.ShiftX())
          {
           this.CloseOverlays();
           this.m_header_view.ShiftX(shift);
           this.Draw(true);
          }
       }
     return;
    }
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM && lparam==this.m_listview.ObjectID() && this.m_filter_column!=WRONG_VALUE)
    {
     int  item=(int)dparam;
     bool all =this.m_listview.GetState(0);
     for(int i=1; i<this.m_listview.ItemsTotal(); i++)
       {
        if(item==0)
           this.m_listview.SetState(i,all);
        else if(!this.m_listview.GetState(i))
           all=false;
       }
     if(item!=0)
        this.m_listview.SetState(0,all);
     this.m_listview.Draw(true);
     return;
    }
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM && lparam==this.m_listview.ObjectID())
    {
     int column=this.m_last_edit_column_index;
     int row   =this.ModelRowIndex(this.m_last_edit_row_index);
     this.CloseOverlays();
     if(column!=WRONG_VALUE)
        this.SendEvent(ON_CLICK_COMBOBOX_ITEM,dparam,(string)column+"_"+(string)row);
     ::ChartRedraw(this.m_chart_id);
     return;
    }
  if(id==CHARTEVENT_CHART_CHANGE)
    {
     this.CloseOverlays();
     return;
    }
  if(id!=CHARTEVENT_MOUSE_MOVE || this.m_is_locked || !this.m_is_available)
     return;
  if(this.m_listview.IsVisible() && s_mouse.IsLeftBtn() && !prev_left && !this.m_listview.MouseFocus() && !this.m_mouse_focus)
    {
     this.CommitFilter();
     this.CloseOverlays();
     ::ChartRedraw(this.m_chart_id);
    }
  this.UpdateResizePointer();
  if(this.m_is_sort_mode && this.m_column_resize_control==WRONG_VALUE)
    {
     int caption=(this.m_mouse_focus && this.InHeader(s_mouse.Y()) ? this.m_header_view.ColumnAt(s_mouse.X()-this.m_x) : WRONG_VALUE);
     if(this.m_header_view.HeaderFocus(caption))
       {
        this.DrawHeaderStrip();
        this.m_canvas.Update(true);
       }
    }
  if(!this.m_lights_hover || this.m_listview.IsVisible())
     return;
  int focus=(this.m_mouse_focus ? this.RowIndexAt(s_mouse.X(),s_mouse.Y()) : WRONG_VALUE);
  if(focus==this.m_item_index_focus)
     return;
  int prev=this.m_item_index_focus;
  this.m_item_index_focus=focus;
  this.DrawRowAt(prev);
  this.DrawRowAt(focus);
  this.m_canvas.Update(true);
 }
#endif // CTABLEVIEW_MQH_IMPLEMENTATION
#endif // CTABLEVIEW_MQH
