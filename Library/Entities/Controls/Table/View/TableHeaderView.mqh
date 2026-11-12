//+------------------------------------------------------------------+
//|                                              TableHeaderView.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEHEADERVIEW_MQH
#define CTABLEHEADERVIEW_MQH
 #include "..\..\..\GBases\GElement.mqh"
 #define TABLE_FILTER_BUTTON_WIDTH  (16)
 #include "..\Model\TableHeader.mqh"
#ifndef CTABLEHEADERVIEW_MQH_DECLARATION
#define CTABLEHEADERVIEW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Column layout (Kazharski column options) + caption strip         |
//+------------------------------------------------------------------+
class CTableHeaderView : public CGBaseObj
 {
  private:
    CTableHeader     *m_header;
    int               m_width[];    
    ENUM_ALIGN_MODE   m_header_align[];                  //Align for Header
    ENUM_ALIGN_MODE   m_content_align[];                 //Align for the content of the cells of the column (a row can say otherwise for itself)
    int               m_text_x_offset[];
    int               m_image_x_offset[];
    CImage            m_header_image[];
    bool              m_default_resizable;
    int               m_is_sorted_column_index;
    ENUM_SORT_MODE   m_last_sort_direction;
    int               m_header_index_focus;
    int               m_shift_x;
    int               m_fixed_left;    // how many shown columns, from the left, stay still while the others scroll
    int               m_fixed_right;   // the same, from the right
    int               m_view_width;    // the room of the columns (set by the table view)
    CImage            m_sort_arrows[2];
    CImage            m_filter_arrow;
    bool              m_filter_enabled[];
    bool              m_filter_active[];
    bool              m_caption_hidden[];   // the caption is kept in the model and not drawn (the cells of the column are pictures)
    bool              m_resizable[];
    bool              m_shown[];    // a hidden column takes no room: its data stays in the model
    int               m_order[];    // display position -> column of the model
    bool              FixedState(int &shown,int &left_count,int &right_count,int &left_w,int &right_w);
    void              DrawHeaderColumn(CCanvas &canvas,const int column,const int x,const int y,const int h,const color back_hover,const color text,const color grid,const color filter_active);
  public:
    void              Bind(CTableHeader *header)                 { this.m_header=header;    }
    void              ColumnsInit(const int total);
    int               ColumnsTotal(void)                   const { return(::ArraySize(this.m_width)); }
    bool              ColumnShown(const int column)        const { return(column>=0 && column<this.ColumnsTotal() ? this.m_shown[column] : false); }
    void              ColumnShown(const int column,const bool flag);
    int               ColumnOrder(const int position)      const { return(position>=0 && position<this.ColumnsTotal() ? this.m_order[position] : WRONG_VALUE); }
    int               ColumnPosition(const int column)     const;
    bool              MoveColumn(const int column,const int delta);   // delta -1 = one place to the left
    string            ColumnsLayout(void) const;                      // "order|shown", e.g. "2,0,1|1,0,1" (shown by column of the model)
    bool              ColumnsLayout(const string layout);
    void              ColumnsReset(void);
    void              ColumnsWidth(const int &array[]);
    void              TextAlign(const ENUM_ALIGN_MODE &array[]);
    void              TextAlign(const uint column_index,const ENUM_ALIGN_MODE align);
    void              ContentAlign(const uint column_index,const ENUM_ALIGN_MODE align);
    ENUM_ALIGN_MODE   ColumnContentAlign(const int column) const { return(this.m_content_align[column]); }
    void              TextXOffset(const int &array[]);
    void              ImageXOffset(const int &array[]);
    void              SetHeaderImage(const uint column_index,const uint &resource_index[]);
    int               ColumnX(const int column);
    int               ColumnsWidthTotal(void);
    void              ShiftX(const int shift)                    { this.m_shift_x=shift;  }
  //--- Fixed columns: the first and the last shown columns stay still, only the ones between them scroll
    void              FixedColumns(const int left,const int right)  { this.m_fixed_left=::MathMax(left,0); this.m_fixed_right=::MathMax(right,0); }
    int               FixedLeft(void)                      const { return(this.m_fixed_left);  }
    int               FixedRight(void)                     const { return(this.m_fixed_right); }
    void              ViewWidth(const int width)                 { this.m_view_width=width;    }
    bool              FixedLayout(int &left_end,int &right_start);   // true while the fixed columns work: x where the scrolled ones start and stop
    int               ColumnRegion(const int column);               // 0 scrolled, 1 fixed at left, 2 fixed at right
    int               ShiftX(void)                         const { return(this.m_shift_x); }
    int               ColumnWidth(const int column)        const { return(this.m_shown[column] ? this.m_width[column] : 0); }
    void              ColumnWidth(const int column,const int width);
    ENUM_ALIGN_MODE   ColumnTextAlign(const int column)    const { return(this.m_header_align[column]);     }
    int               ColumnTextXOffset(const int column)  const { return(this.m_text_x_offset[column]);  }
    int               ColumnImageXOffset(const int column) const { return(this.m_image_x_offset[column]); }
    int               ColumnAt(const int x);
    int               ColumnBorderAt(const int x,const int tolerance);
    void              SortState(const int column,const ENUM_SORT_MODE direction) { this.m_is_sorted_column_index=column; this.m_last_sort_direction=direction; }
    int               SortedColumn(void)                   const { return(this.m_is_sorted_column_index); }
    ENUM_SORT_MODE   SortDirection(void)                  const { return(this.m_last_sort_direction);    }
    bool              HeaderFocus(const int column);
    void              FilterMode(const int column,const bool flag);
    void              CaptionVisible(const int column,const bool flag);
    void              ColumnResizeMode(const int column,const bool flag);
    void              FilterActive(const int column,const bool flag);
    int               FilterButtonAt(const int x);
    void              DrawHeader(CCanvas &canvas,const int y,const int h,const int right,const color back,const color back_hover,const color text,const color grid,const color filter_active);
                     CTableHeaderView(void);
                    ~CTableHeaderView(void) {}
 };
#endif // CTABLEHEADERVIEW_MQH_DECLARATION
#ifndef CTABLEHEADERVIEW_MQH_IMPLEMENTATION
#define CTABLEHEADERVIEW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski defaults: a column is 100 wide, its caption centered   |
//+------------------------------------------------------------------+
CTableHeaderView::CTableHeaderView(void) : m_header(NULL),
                                           m_default_resizable(false),
                                           m_is_sorted_column_index(WRONG_VALUE),
                                           m_last_sort_direction(SORT_ASCENDING),
                                           m_header_index_focus(WRONG_VALUE),
                                           m_shift_x(0),
                                           m_fixed_left(0),
                                           m_fixed_right(0),
                                           m_view_width(0)
 {
  this.m_sort_arrows[0].ReadImageData(IMAGE_RESOURCE_BMP16_ARROW_UP_PNG);
  this.m_sort_arrows[1].ReadImageData(IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG);
  this.m_filter_arrow.ReadImageData(IMAGE_RESOURCE_BMP16_DOWN_THICK_BLACK_BMP);
 }
//+------------------------------------------------------------------+
//| New columns take the defaults, existing ones keep their layout   |
//+------------------------------------------------------------------+
void CTableHeaderView::ColumnsInit(const int total)
 {
  int size=::ArraySize(this.m_width);
  ::ArrayResize(this.m_width,total);
  ::ArrayResize(this.m_header_align,total);
  ::ArrayResize(this.m_content_align,total);
  ::ArrayResize(this.m_text_x_offset,total);
  ::ArrayResize(this.m_image_x_offset,total);
  ::ArrayResize(this.m_header_image,total);
  ::ArrayResize(this.m_filter_active,total);
  ::ArrayResize(this.m_filter_enabled,total);
  ::ArrayResize(this.m_caption_hidden,total);
  ::ArrayResize(this.m_resizable,total);
  ::ArrayResize(this.m_shown,total);
  ::ArrayResize(this.m_order,total);
  for(int i=size; i<total; i++)
    {
     this.m_shown[i]         =true;
     this.m_order[i]         =i;
     this.m_filter_active[i] =false;
     this.m_filter_enabled[i]=false;
     this.m_caption_hidden[i]=false;
     this.m_resizable[i]     =this.m_default_resizable;
     this.m_width[i]         =100;   // a column the EA has not given a width
     this.m_header_align[i]    =ALIGN_CENTER;   // the caption of a new column is centered
     this.m_content_align[i]   =ALIGN_LEFT;     // its cells are on the left
     this.m_text_x_offset[i] =5;
     this.m_image_x_offset[i]=3;
    }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::ColumnsWidth(const int &array[])
 {
  for(int i=0; i<::MathMin(::ArraySize(array),this.ColumnsTotal()); i++)
     this.m_width[i]=array[i];
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::TextAlign(const ENUM_ALIGN_MODE &array[])
 {
  for(int i=0; i<::MathMin(::ArraySize(array),this.ColumnsTotal()); i++)
     this.m_header_align[i]=array[i];
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::ContentAlign(const uint column_index,const ENUM_ALIGN_MODE align)
 {
  if(column_index<(uint)this.ColumnsTotal())
     this.m_content_align[column_index]=align;
 }
void CTableHeaderView::TextAlign(const uint column_index,const ENUM_ALIGN_MODE align)
 {
  if(column_index<(uint)this.ColumnsTotal())
     this.m_header_align[column_index]=align;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::TextXOffset(const int &array[])
 {
  for(int i=0; i<::MathMin(::ArraySize(array),this.ColumnsTotal()); i++)
     this.m_text_x_offset[i]=array[i];
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::ImageXOffset(const int &array[])
 {
  for(int i=0; i<::MathMin(::ArraySize(array),this.ColumnsTotal()); i++)
     this.m_image_x_offset[i]=array[i];
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::ColumnWidth(const int column,const int width)
 {
  if(column>=0 && column<this.ColumnsTotal())
     this.m_width[column]=width;
 }
//+------------------------------------------------------------------+
//| Kazharski SetHeaderImage: first picture of the list is shown     |
//+------------------------------------------------------------------+
void CTableHeaderView::SetHeaderImage(const uint column_index,const uint &resource_index[])
 {
  if(column_index>=(uint)this.ColumnsTotal() || ::ArraySize(resource_index)<1)
     return;
  this.m_header_image[column_index].DeleteImageData();
  this.m_header_image[column_index].ReadImageData(resource_index[0]);
 }
//+------------------------------------------------------------------+
//| The fixed columns work only when the columns do not fit the room |
//| and the fixed ones leave some room for the others                |
//+------------------------------------------------------------------+
bool CTableHeaderView::FixedState(int &shown,int &left_count,int &right_count,int &left_w,int &right_w)
 {
  shown=0;
  left_count=0;
  right_count=0;
  left_w=0;
  right_w=0;
  if((this.m_fixed_left<1 && this.m_fixed_right<1) || this.m_view_width<1)
     return(false);
  int total=0;
  for(int i=0; i<this.ColumnsTotal(); i++)
     if(this.m_shown[i])
       {
        shown++;
        total+=this.m_width[i];
       }
  if(total<=this.m_view_width)
     return(false);
  left_count =::MathMin(this.m_fixed_left,shown);
  right_count=::MathMin(this.m_fixed_right,shown-left_count);
  int sp=0;
  for(int p=0; p<this.ColumnsTotal(); p++)
    {
     int i=this.m_order[p];
     if(!this.m_shown[i])
        continue;
     if(sp<left_count)
        left_w+=this.m_width[i];
     else if(sp>=shown-right_count)
        right_w+=this.m_width[i];
     sp++;
    }
  return(left_w+right_w<this.m_view_width-30);
 }
//+------------------------------------------------------------------+
//| x where the scrolled columns start and stop (they pass under the |
//| fixed ones), true while the fixed columns work                   |
//+------------------------------------------------------------------+
bool CTableHeaderView::FixedLayout(int &left_end,int &right_start)
 {
  int shown,left_count,right_count,left_w,right_w;
  left_end=0;
  right_start=0;
  if(!this.FixedState(shown,left_count,right_count,left_w,right_w))
     return(false);
  left_end=1+left_w;
  right_start=1+this.m_view_width-right_w;
  return(true);
 }
//+------------------------------------------------------------------+
//| 0 scrolled (or nothing is fixed), 1 fixed at left, 2 fixed right|
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnRegion(const int column)
 {
  int shown,left_count,right_count,left_w,right_w;
  if(!this.FixedState(shown,left_count,right_count,left_w,right_w))
     return(0);
  int sp=0;
  for(int p=0; p<this.ColumnsTotal(); p++)
    {
     int i=this.m_order[p];
     if(!this.m_shown[i])
        continue;
     if(i==column)
        return(sp<left_count ? 1 : (sp>=shown-right_count ? 2 : 0));
     sp++;
    }
  return(0);
 }
//+------------------------------------------------------------------+
//| Left edge inside the table border: the scrolled columns move by  |
//| the horizontal shift, the fixed ones stay where they are         |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnX(const int column)
 {
  int shown,left_count,right_count,left_w,right_w;
  bool fixed=this.FixedState(shown,left_count,right_count,left_w,right_w);
  int before=0,sp=0;
  for(int p=0; p<this.ColumnsTotal(); p++)
    {
     int i=this.m_order[p];
     if(i==column)
        break;
     if(this.m_shown[i])
       {
        before+=this.m_width[i];
        sp++;
       }
    }
  if(fixed && sp<left_count)
     return(1+before);
  if(fixed && sp>=shown-right_count)
     return(1+this.m_view_width-this.ColumnsWidthTotal()+before);
  return(1-this.m_shift_x+before);
 }
//+------------------------------------------------------------------+
//| What the shown columns take                                      |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnsWidthTotal(void)
 {
  int width=0;
  for(int i=0; i<this.ColumnsTotal(); i++)
     if(this.m_shown[i])
        width+=this.m_width[i];
  return(width);
 }
//+------------------------------------------------------------------+
//| Column under local x, WRONG_VALUE past the last one; a scrolled  |
//| column is not under x where a fixed one covers it                |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnAt(const int x)
 {
  int left_end,right_start;
  bool fixed=this.FixedLayout(left_end,right_start);
  for(int p=0; p<this.ColumnsTotal(); p++)
    {
     int i=this.m_order[p];
     if(!this.m_shown[i])
        continue;
     int left=this.ColumnX(i);
     if(x<left || x>=left+this.m_width[i])
        continue;
     if(!fixed || this.ColumnRegion(i)!=0 || (x>=left_end && x<right_start))
        return(i);
    }
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Resizable column whose right edge is within tolerance of local x |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnBorderAt(const int x,const int tolerance)
 {
  int left_end,right_start;
  bool fixed=this.FixedLayout(left_end,right_start);
  for(int p=0; p<this.ColumnsTotal(); p++)
    {
     int i=this.m_order[p];
     if(!this.m_shown[i] || !this.m_resizable[i])
        continue;
     int right=this.ColumnX(i)+this.m_width[i]-1;
     if(fixed && this.ColumnRegion(i)==0 && (right<left_end || right>=right_start))
        continue;
     if(::MathAbs(x-right)<=tolerance)
        return(i);
    }
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Hovered caption; true if it changed                              |
//+------------------------------------------------------------------+
bool CTableHeaderView::HeaderFocus(const int column)
 {
  if(column==this.m_header_index_focus)
     return(false);
  this.m_header_index_focus=column;
  return(true);
 }
//+------------------------------------------------------------------+
//| Filter button on/off for one column                              |
//+------------------------------------------------------------------+
void CTableHeaderView::FilterMode(const int column,const bool flag)
 {
  if(column>=0 && column<this.ColumnsTotal())
     this.m_filter_enabled[column]=flag;
 }
//+------------------------------------------------------------------+
//| The caption of a column drawn or not: it stays in the model      |
//+------------------------------------------------------------------+
void CTableHeaderView::CaptionVisible(const int column,const bool flag)
 {
  if(column>=0 && column<this.ColumnsTotal())
     this.m_caption_hidden[column]=!flag;
 }
//+------------------------------------------------------------------+
//| Border drag on/off for one column, column<0 = every column       |
//+------------------------------------------------------------------+
void CTableHeaderView::ColumnResizeMode(const int column,const bool flag)
 {
  if(column<0)
    {
     this.m_default_resizable=flag;
     for(int i=0; i<this.ColumnsTotal(); i++)
        this.m_resizable[i]=flag;
     return;
    }
  if(column<this.ColumnsTotal())
     this.m_resizable[column]=flag;
 }
//+------------------------------------------------------------------+
//| Funnel flag of a column (drawn in the filter color)              |
//+------------------------------------------------------------------+
void CTableHeaderView::FilterActive(const int column,const bool flag)
 {
  if(column>=0 && column<this.ColumnsTotal())
     this.m_filter_active[column]=flag;
 }
//+------------------------------------------------------------------+
//| Column whose filter button is under local x, WRONG_VALUE if none |
//+------------------------------------------------------------------+
int CTableHeaderView::FilterButtonAt(const int x)
 {
  int column=this.ColumnAt(x);
  if(column==WRONG_VALUE || !this.m_filter_enabled[column])
     return(WRONG_VALUE);
  return(x>=this.ColumnX(column)+this.m_width[column]-TABLE_FILTER_BUTTON_WIDTH ? column : WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Show or hide a column (the last shown column cannot be hidden)   |
//+------------------------------------------------------------------+
void CTableHeaderView::ColumnShown(const int column,const bool flag)
 {
  if(column<0 || column>=this.ColumnsTotal() || this.m_shown[column]==flag)
     return;
  if(!flag)
    {
     int shown=0;
     for(int i=0; i<this.ColumnsTotal(); i++)
        if(this.m_shown[i])
           shown++;
     if(shown<=1)
        return;
    }
  this.m_shown[column]=flag;
 }
int CTableHeaderView::ColumnPosition(const int column) const
 {
  for(int p=0; p<this.ColumnsTotal(); p++)
     if(this.m_order[p]==column)
        return(p);
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| One place left (-1) or right (+1) in the display order          |
//+------------------------------------------------------------------+
bool CTableHeaderView::MoveColumn(const int column,const int delta)
 {
  int from=this.ColumnPosition(column);
  int to=from+delta;
  if(from==WRONG_VALUE || to<0 || to>=this.ColumnsTotal())
     return(false);
  int other=this.m_order[to];
  this.m_order[to]=column;
  this.m_order[from]=other;
  return(true);
 }
void CTableHeaderView::ColumnsReset(void)
 {
  for(int i=0; i<this.ColumnsTotal(); i++)
    {
     this.m_order[i]=i;
     this.m_shown[i]=true;
    }
 }
//+------------------------------------------------------------------+
//| "2,0,1|1,0,1": the model column of each place, then the shown flag |
//| of each column of the model                                      |
//+------------------------------------------------------------------+
string CTableHeaderView::ColumnsLayout(void) const
 {
  string order="",shown="";
  for(int i=0; i<this.ColumnsTotal(); i++)
    {
     order+=(i>0 ? "," : "")+(string)this.m_order[i];
     shown+=(i>0 ? "," : "")+(this.m_shown[i] ? "1" : "0");
    }
  return(order+"|"+shown);
 }
//+------------------------------------------------------------------+
//| A layout that does not fit the columns of the table is refused   |
//+------------------------------------------------------------------+
bool CTableHeaderView::ColumnsLayout(const string layout)
 {
  string parts[],order[],shown[];
  int total=this.ColumnsTotal();
  if(::StringSplit(layout,'|',parts)!=2 || ::StringSplit(parts[0],',',order)!=total || ::StringSplit(parts[1],',',shown)!=total)
     return(false);
  bool seen[];
  ::ArrayResize(seen,total);
  ::ArrayInitialize(seen,false);
  int new_order[];
  ::ArrayResize(new_order,total);
  int any=0;
  for(int i=0; i<total; i++)
    {
     int column=(int)::StringToInteger(order[i]);
     if(column<0 || column>=total || seen[column])
        return(false);
     seen[column]=true;
     new_order[i]=column;
     any+=(shown[i]=="1" ? 1 : 0);
    }
  if(any<1)
     return(false);
  for(int i=0; i<total; i++)
    {
     this.m_order[i]=new_order[i];
     this.m_shown[i]=(shown[i]=="1");
    }
  return(true);
 }
//+------------------------------------------------------------------+
//| One caption at x: hover, image, filter, sort arrow, text, grid   |
//+------------------------------------------------------------------+
void CTableHeaderView::DrawHeaderColumn(CCanvas &canvas,const int column,const int x,const int y,const int h,const color back_hover,const color text,const color grid,const color filter_active)
 {
  int i=column;
  uint grid_color=::ColorToARGB(grid,255);
  int w=this.m_width[i];
  if(i==this.m_header_index_focus)
     canvas.FillRectangle(::MathMax(x,1),y,x+w-2,y+h-2,::ColorToARGB(back_hover,255));
  if(this.m_header_image[i].Width()>0)
     this.m_header_image[i].Draw(canvas,x+this.m_image_x_offset[i],y+(h-1-(int)this.m_header_image[i].Height())/2);
  int button=(this.m_filter_enabled[i] ? TABLE_FILTER_BUTTON_WIDTH : 0);
  if(this.m_filter_enabled[i])
    {
     int ax=x+w-TABLE_FILTER_BUTTON_WIDTH+(TABLE_FILTER_BUTTON_WIDTH-(int)this.m_filter_arrow.Width())/2;
     this.m_filter_arrow.Draw(canvas,ax,y+(h-1-(int)this.m_filter_arrow.Height())/2);
     if(this.m_filter_active[i])
        canvas.FillCircle(x+w-5,y+4,3,::ColorToARGB(filter_active,255));
    }
  if(i==this.m_is_sorted_column_index)
    {
     int a=(this.m_last_sort_direction==SORT_ASCENDING ? 0 : 1);
     this.m_sort_arrows[a].Draw(canvas,x+w-2-button-(int)this.m_sort_arrows[a].Width(),y+(h-1-(int)this.m_sort_arrows[a].Height())/2);
    }
  string caption=(this.m_header!=NULL && this.m_header_image[i].Width()<1 && !this.m_caption_hidden[i] ? this.m_header.Caption(i) : "");   // a picture takes the place of the text
  if(this.m_header_align[i]==ALIGN_LEFT)
     canvas.TextOut(x+this.m_text_x_offset[i],y+(h-1)/2,caption,::ColorToARGB(text,255),TA_LEFT|TA_VCENTER);
  else if(this.m_header_align[i]==ALIGN_RIGHT)
     canvas.TextOut(x+w-1-this.m_text_x_offset[i],y+(h-1)/2,caption,::ColorToARGB(text,255),TA_RIGHT|TA_VCENTER);
  else
     canvas.TextOut(x+w/2,y+(h-1)/2,caption,::ColorToARGB(text,255),TA_CENTER|TA_VCENTER);
  canvas.Line(x+w-1,y,x+w-1,y+h-1,grid_color);
 }
//+------------------------------------------------------------------+
//| Caption strip with the column grid, clipped at right; the        |
//| scrolled columns first, the fixed ones over them                 |
//+------------------------------------------------------------------+
void CTableHeaderView::DrawHeader(CCanvas &canvas,const int y,const int h,const int right,const color back,const color back_hover,const color text,const color grid,const color filter_active)
 {
  canvas.FillRectangle(1,y,right,y+h-1,::ColorToARGB(back,255));
  uint grid_color=::ColorToARGB(grid,255);
  canvas.Line(1,y+h-1,right,y+h-1,grid_color);
  int left_end,right_start;
  bool fixed=this.FixedLayout(left_end,right_start);
  for(int pass=0; pass<(fixed ? 2 : 1); pass++)
    {
     if(pass==1)   // the scrolled captions that went past the fixed ones at right (over the scrollbar too) are covered
        canvas.FillRectangle(right_start,y,right,y+h-2,::ColorToARGB(back,255));
     for(int p=0; p<this.ColumnsTotal(); p++)
       {
        int i=this.m_order[p];
        if(!this.m_shown[i])
           continue;
        if(fixed && (this.ColumnRegion(i)!=0)!=(pass==1))
           continue;
        int x=this.ColumnX(i);
        if(x>right || x+this.m_width[i]<=1)
           continue;
        if(pass==1)
           canvas.FillRectangle(x,y,x+this.m_width[i]-2,y+h-2,::ColorToARGB(back,255));
        this.DrawHeaderColumn(canvas,i,x,y,h,back_hover,text,grid,filter_active);
       }
    }
 }
#endif // CTABLEHEADERVIEW_MQH_IMPLEMENTATION
#endif // CTABLEHEADERVIEW_MQH
