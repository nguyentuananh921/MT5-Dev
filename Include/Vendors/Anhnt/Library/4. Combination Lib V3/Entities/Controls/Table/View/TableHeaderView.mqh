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
    int               m_text_x_offset[];
    int               m_image_x_offset[];
    CImage            m_header_image[];
    int               m_default_width;
    bool              m_default_resizable;
    ENUM_ALIGN_MODE   m_default_text_align;
    int               m_is_sorted_column_index;
    ENUM_CSORT_MODE   m_last_sort_direction;
    int               m_header_index_focus;
    int               m_shift_x;
    CImage            m_sort_arrows[2];
    CImage            m_filter_arrow;
    bool              m_filter_enabled[];
    bool              m_filter_active[];
    bool              m_resizable[];
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
    ENUM_ALIGN_MODE   ColumnTextAlign(const int column)    const { return(this.m_header_align[column]);     }
    int               ColumnTextXOffset(const int column)  const { return(this.m_text_x_offset[column]);  }
    int               ColumnImageXOffset(const int column) const { return(this.m_image_x_offset[column]); }
    int               ColumnAt(const int x);
    int               ColumnBorderAt(const int x,const int tolerance);
    void              SortState(const int column,const ENUM_CSORT_MODE direction) { this.m_is_sorted_column_index=column; this.m_last_sort_direction=direction; }
    int               SortedColumn(void)                   const { return(this.m_is_sorted_column_index); }
    ENUM_CSORT_MODE   SortDirection(void)                  const { return(this.m_last_sort_direction);    }
    bool              HeaderFocus(const int column);
    void              FilterMode(const int column,const bool flag);
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
//| Kazharski defaults: width 100, centered                          |
//+------------------------------------------------------------------+
CTableHeaderView::CTableHeaderView(void) : m_header(NULL),
                                           m_default_width(100),
                                           m_default_resizable(false),
                                           m_default_text_align(ALIGN_CENTER),
                                           m_is_sorted_column_index(WRONG_VALUE),
                                           m_last_sort_direction(SORT_ASCEND),
                                           m_header_index_focus(WRONG_VALUE),
                                           m_shift_x(0)
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
  ::ArrayResize(this.m_text_x_offset,total);
  ::ArrayResize(this.m_image_x_offset,total);
  ::ArrayResize(this.m_header_image,total);
  ::ArrayResize(this.m_filter_active,total);
  ::ArrayResize(this.m_filter_enabled,total);
  ::ArrayResize(this.m_resizable,total);
  for(int i=size; i<total; i++)
    {
     this.m_filter_active[i] =false;
     this.m_filter_enabled[i]=false;
     this.m_resizable[i]     =this.m_default_resizable;
     this.m_width[i]         =this.m_default_width;
     this.m_header_align[i]    =this.m_default_text_align;
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
//| Resizable column whose right edge is within tolerance of local x |
//+------------------------------------------------------------------+
int CTableHeaderView::ColumnBorderAt(const int x,const int tolerance)
 {
  int right=-this.m_shift_x;
  for(int i=0; i<this.ColumnsTotal(); i++)
    {
     right+=this.m_width[i];
     if(this.m_resizable[i] && ::MathAbs(x-right)<=tolerance)
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
//| Caption strip with the column grid, clipped at right             |
//+------------------------------------------------------------------+
void CTableHeaderView::DrawHeader(CCanvas &canvas,const int y,const int h,const int right,const color back,const color back_hover,const color text,const color grid,const color filter_active)
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
        int a=(this.m_last_sort_direction==SORT_ASCEND ? 0 : 1);
        this.m_sort_arrows[a].Draw(canvas,x+w-2-button-(int)this.m_sort_arrows[a].Width(),y+(h-1-(int)this.m_sort_arrows[a].Height())/2);
       }
     string caption=(this.m_header!=NULL ? this.m_header.Caption(i) : "");
     if(this.m_header_align[i]==ALIGN_LEFT)
        canvas.TextOut(x+this.m_text_x_offset[i],y+(h-1)/2,caption,::ColorToARGB(text,255),TA_LEFT|TA_VCENTER);
     else if(this.m_header_align[i]==ALIGN_RIGHT)
        canvas.TextOut(x+w-1-this.m_text_x_offset[i],y+(h-1)/2,caption,::ColorToARGB(text,255),TA_RIGHT|TA_VCENTER);
     else
        canvas.TextOut(x+w/2,y+(h-1)/2,caption,::ColorToARGB(text,255),TA_CENTER|TA_VCENTER);
     x+=w;
     canvas.Line(x-1,y,x-1,y+h-1,grid_color);
    }
 }
#endif // CTABLEHEADERVIEW_MQH_IMPLEMENTATION
#endif // CTABLEHEADERVIEW_MQH
