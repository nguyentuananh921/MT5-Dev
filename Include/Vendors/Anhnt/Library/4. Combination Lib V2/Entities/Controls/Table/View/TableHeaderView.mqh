//+------------------------------------------------------------------+
//|                                              TableHeaderView.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEHEADERVIEW_MQH
#define CTABLEHEADERVIEW_MQH
 #include "..\..\..\GBases\GElement.mqh"
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
    ENUM_ALIGN_MODE   m_text_align[];
    int               m_text_x_offset[];
    int               m_image_x_offset[];
    CImage            m_header_image[];
    int               m_default_width;
    ENUM_ALIGN_MODE   m_default_text_align;
    int               m_is_sorted_column_index;
    ENUM_CSORT_MODE   m_last_sort_direction;
    int               m_header_index_focus;
    int               m_shift_x;
    CImage            m_sort_arrows[2];
  public:
    void              Bind(CTableHeader *header)                 { this.m_header=header;    }
    void              ColumnsInit(const int total);
    int               ColumnsTotal(void)                   const { return(::ArraySize(this.m_width)); }
    void              DefaultWidth(const int width)              { this.m_default_width=width; }
    void              DefaultTextAlign(const ENUM_ALIGN_MODE align) { this.m_default_text_align=align; }
    void              ColumnsWidth(const int &array[]);
    void              TextAlign(const ENUM_ALIGN_MODE &array[]);
    void              TextAlign(const uint column_index,const ENUM_ALIGN_MODE align);
    void              TextXOffset(const int &array[]);
    void              ImageXOffset(const int &array[]);
    void              SetHeaderImage(const uint column_index,const uint &resource_index[]);
    int               ColumnX(const int column);
    int               ColumnsWidthTotal(void);
    void              ShiftX(const int shift)                    { this.m_shift_x=shift;  }
    int               ShiftX(void)                         const { return(this.m_shift_x); }
    int               ColumnWidth(const int column)        const { return(this.m_width[column]);          }
    void              ColumnWidth(const int column,const int width);
    ENUM_ALIGN_MODE   ColumnTextAlign(const int column)    const { return(this.m_text_align[column]);     }
    int               ColumnTextXOffset(const int column)  const { return(this.m_text_x_offset[column]);  }
    int               ColumnImageXOffset(const int column) const { return(this.m_image_x_offset[column]); }
    int               ColumnAt(const int x);
    int               ColumnBorderAt(const int x,const int tolerance);
    void              SortState(const int column,const ENUM_CSORT_MODE direction) { this.m_is_sorted_column_index=column; this.m_last_sort_direction=direction; }
    int               SortedColumn(void)                   const { return(this.m_is_sorted_column_index); }
    ENUM_CSORT_MODE   SortDirection(void)                  const { return(this.m_last_sort_direction);    }
    bool              HeaderFocus(const int column);
    void              DrawHeader(CCanvas &canvas,const int y,const int h,const int right,const color back,const color back_hover,const color text,const color grid);
                     CTableHeaderView(void);
                    ~CTableHeaderView(void) {}
 };
#endif // CTABLEHEADERVIEW_MQH_DECLARATION
#ifndef CTABLEHEADERVIEW_MQH_IMPLEMENTATION
#define CTABLEHEADERVIEW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski defaults: width 100, centered                          |
//+------------------------------------------------------------------+
CTableHeaderView::CTableHeaderView(void) : m_header(NULL),
                                           m_default_width(100),
                                           m_default_text_align(ALIGN_CENTER),
                                           m_is_sorted_column_index(WRONG_VALUE),
                                           m_last_sort_direction(SORT_ASCEND),
                                           m_header_index_focus(WRONG_VALUE),
                                           m_shift_x(0)
 {
  this.m_sort_arrows[0].ReadImageData(IMAGE_RESOURCE_BMP16_ARROW_UP_PNG);
  this.m_sort_arrows[1].ReadImageData(IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG);
 }
//+------------------------------------------------------------------+
//| New columns take the defaults, existing ones keep their layout   |
//+------------------------------------------------------------------+
void CTableHeaderView::ColumnsInit(const int total)
 {
  int size=::ArraySize(this.m_width);
  ::ArrayResize(this.m_width,total);
  ::ArrayResize(this.m_text_align,total);
  ::ArrayResize(this.m_text_x_offset,total);
  ::ArrayResize(this.m_image_x_offset,total);
  ::ArrayResize(this.m_header_image,total);
  for(int i=size; i<total; i++)
    {
     this.m_width[i]         =this.m_default_width;
     this.m_text_align[i]    =this.m_default_text_align;
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
     this.m_text_align[i]=array[i];
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::TextAlign(const uint column_index,const ENUM_ALIGN_MODE align)
 {
  if(column_index<(uint)this.ColumnsTotal())
     this.m_text_align[column_index]=align;
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
//| Left edge inside the table border, minus the horizontal shift    |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnX(const int column)
 {
  int x=1-this.m_shift_x;
  for(int i=0; i<column && i<this.ColumnsTotal(); i++)
     x+=this.m_width[i];
  return(x);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnsWidthTotal(void)
 {
  int width=0;
  for(int i=0; i<this.ColumnsTotal(); i++)
     width+=this.m_width[i];
  return(width);
 }
//+------------------------------------------------------------------+
//| Column under local x, WRONG_VALUE past the last one              |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnAt(const int x)
 {
  int left=1-this.m_shift_x;
  for(int i=0; i<this.ColumnsTotal(); i++)
    {
     if(x>=left && x<left+this.m_width[i])
        return(i);
     left+=this.m_width[i];
    }
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Column whose right edge is within tolerance of local x           |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnBorderAt(const int x,const int tolerance)
 {
  int right=-this.m_shift_x;
  for(int i=0; i<this.ColumnsTotal(); i++)
    {
     right+=this.m_width[i];
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
//| Caption strip with the column grid, clipped at right             |
//+------------------------------------------------------------------+
void CTableHeaderView::DrawHeader(CCanvas &canvas,const int y,const int h,const int right,const color back,const color back_hover,const color text,const color grid)
 {
  canvas.FillRectangle(1,y,right,y+h-1,::ColorToARGB(back,255));
  uint grid_color=::ColorToARGB(grid,255);
  canvas.Line(1,y+h-1,right,y+h-1,grid_color);
  int x=1-this.m_shift_x;
  for(int i=0; i<this.ColumnsTotal() && x<=right; i++)
    {
     int w=this.m_width[i];
     if(x+w<=1)
       {
        x+=w;
        continue;
       }
     if(i==this.m_header_index_focus)
        canvas.FillRectangle(::MathMax(x,1),y,::MathMin(x+w-2,right),y+h-2,::ColorToARGB(back_hover,255));
     if(this.m_header_image[i].Width()>0)
        this.m_header_image[i].Draw(canvas,x+this.m_image_x_offset[i],y+(h-1-(int)this.m_header_image[i].Height())/2);
     if(i==this.m_is_sorted_column_index)
       {
        int a=(this.m_last_sort_direction==SORT_ASCEND ? 0 : 1);
        this.m_sort_arrows[a].Draw(canvas,x+w-2-(int)this.m_sort_arrows[a].Width(),y+(h-1-(int)this.m_sort_arrows[a].Height())/2);
       }
     string caption=(this.m_header!=NULL ? this.m_header.Caption(i) : "");
     if(this.m_text_align[i]==ALIGN_LEFT)
        canvas.TextOut(x+this.m_text_x_offset[i],y+(h-1)/2,caption,::ColorToARGB(text,255),TA_LEFT|TA_VCENTER);
     else if(this.m_text_align[i]==ALIGN_RIGHT)
        canvas.TextOut(x+w-1-this.m_text_x_offset[i],y+(h-1)/2,caption,::ColorToARGB(text,255),TA_RIGHT|TA_VCENTER);
     else
        canvas.TextOut(x+w/2,y+(h-1)/2,caption,::ColorToARGB(text,255),TA_CENTER|TA_VCENTER);
     x+=w;
     canvas.Line(x-1,y,x-1,y+h-1,grid_color);
    }
 }
#endif // CTABLEHEADERVIEW_MQH_IMPLEMENTATION
#endif // CTABLEHEADERVIEW_MQH
