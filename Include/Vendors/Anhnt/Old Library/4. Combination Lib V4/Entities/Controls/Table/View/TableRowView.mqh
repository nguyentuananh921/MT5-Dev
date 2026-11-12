//+------------------------------------------------------------------+
//|                                                 TableRowView.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEROWVIEW_MQH
#define CTABLEROWVIEW_MQH
 #include "TableCellView.mqh"
 #include "TableHeaderView.mqh"
 #include "..\Model\TableRow.mqh"
 #define TABLE_ALIGN_NOT_SET   (-1)   // a row has not set the alignment of a cell
#ifndef CTABLEROWVIEW_MQH_DECLARATION
#define CTABLEROWVIEW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Owner of the cell views of one model row                         |
//+------------------------------------------------------------------+
class CTableRowView : public CGBaseObj
 {
  private:
    CTableRow        *m_row;
    ENUM_ALIGN_MODE   m_text_align[];      //Align for content in cell: only what this row says for itself, the rest is TABLE_ALIGN_NOT_SET (the column decides)
  public:
    bool              Bind(CTableRow *row);
    CTableRow        *Row(void)                            const { return(this.m_row); }
    CTableCellView   *CellView(const int index)                  { return(dynamic_cast<CTableCellView *>(this.Child(index))); }
    int               CellsTotal(void)                     const { return(this.ChildrenTotal()); }
    bool              IsChanged(void);
    void              ResetChanged(void);
    //Add here to set align header and content text separate
     void              TextAlign(const ENUM_ALIGN_MODE &array[]);
     void              TextAlign(const uint column_index,const ENUM_ALIGN_MODE align);
     ENUM_ALIGN_MODE   ColumnTextAlign(const int column) const;
     bool              HasTextAlign(const int column) const;   // true when this row says its own for the column
    void              DrawCellAt(CCanvas &canvas,CTableHeaderView &header,const int column,const int y,const int h,const int right,
                                 const color back,const color text,const color grid,const bool selected);
    void              DrawCellOnly(CCanvas &canvas,CTableHeaderView &header,const int column,const int y,const int h,const int right,
                                   const color back,const color text,const color grid,const bool selected);
    void              DrawRow(CCanvas &canvas,CTableHeaderView &header,const int y,const int h,const int right,
                              const color back,const color text,const color grid,const bool selected);
                     CTableRowView(void) : m_row(NULL) {}
                    ~CTableRowView(void) {}
 };
#endif // CTABLEROWVIEW_MQH_DECLARATION
#ifndef CTABLEROWVIEW_MQH_IMPLEMENTATION
#define CTABLEROWVIEW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| One cell view per model cell; kept views keep type/images/colors |
//+------------------------------------------------------------------+
bool CTableRowView::Bind(CTableRow *row)
 {
  this.m_row=row;
  int total=(row!=NULL ? row.CellsTotal() : 0);
  while(this.ChildrenTotal()>total)
    {
     CGBaseObj *last=this.Child(this.ChildrenTotal()-1);
     this.DeleteChild(last);
     delete last;
    }
  while(this.ChildrenTotal()<total)
    {
     CTableCellView *view=new CTableCellView();
     if(view==NULL || !this.AddChild(view))
       {
        delete view;
        return(false);
       }
    }
  for(int i=0; i<total; i++)
     this.CellView(i).Bind(row.Cell(i));
  return(true);
 }
//+------------------------------------------------------------------+
//| Any cell changed since the last draw                             |
//+------------------------------------------------------------------+
bool CTableRowView::IsChanged(void)
 {
  for(int i=0; i<this.CellsTotal(); i++)
    {
     CTableCellView *view=this.CellView(i);
     if(view!=NULL && view.Cell()!=NULL && view.Cell().IsEvent())
        return(true);
    }
  return(false);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableRowView::ResetChanged(void)
 {
  for(int i=0; i<this.CellsTotal(); i++)
    {
     CTableCellView *view=this.CellView(i);
     if(view!=NULL && view.Cell()!=NULL)
        view.Cell().SetEventFlag(false);
    }
 }
void CTableRowView::TextAlign(const ENUM_ALIGN_MODE &array[])
 {
   int cells=this.CellsTotal();
   int old=::ArraySize(this.m_text_align);
   ::ArrayResize(this.m_text_align,cells);
   for(int i=old; i<cells; i++)
      this.m_text_align[i]=(ENUM_ALIGN_MODE)TABLE_ALIGN_NOT_SET;
   for(int i=0; i<::MathMin(::ArraySize(array),cells); i++)
      this.m_text_align[i]=array[i];
 }
void CTableRowView::TextAlign(const uint column_index,const ENUM_ALIGN_MODE align)
 {
   int cells=this.CellsTotal();
   if(column_index>=(uint)cells)
      return;
   int old=::ArraySize(this.m_text_align);
   if(old<cells)
     {
      ::ArrayResize(this.m_text_align,cells);
      for(int i=old; i<cells; i++)
         this.m_text_align[i]=(ENUM_ALIGN_MODE)TABLE_ALIGN_NOT_SET;
     }
   this.m_text_align[column_index]=align;
 }
bool CTableRowView::HasTextAlign(const int column) const
 {
   return(column>=0 && column<::ArraySize(this.m_text_align) && (int)this.m_text_align[column]!=TABLE_ALIGN_NOT_SET);
 }
ENUM_ALIGN_MODE CTableRowView::ColumnTextAlign(const int column) const
 {
   return(this.HasTextAlign(column) ? this.m_text_align[column] : ALIGN_LEFT);
 }
//+------------------------------------------------------------------+
//| One cell, clipped at right, skipped when scrolled out at left;   |
//| a scrolled cell stops where the fixed columns at right start     |
//+------------------------------------------------------------------+
void CTableRowView::DrawCellOnly(CCanvas &canvas,CTableHeaderView &header,const int column,const int y,const int h,const int right,
                                 const color back,const color text,const color grid,const bool selected)
 {
  CTableCellView *view=this.CellView(column);
  if(view==NULL || column>=header.ColumnsTotal() || !header.ColumnShown(column))
     return;
  int x=header.ColumnX(column);
  int limit=right;
  int left_end,right_start;
  if(header.FixedLayout(left_end,right_start) && header.ColumnRegion(column)==0)
    {
     limit=::MathMin(right,right_start-1);
     if(x+header.ColumnWidth(column)<=left_end)
        return;
    }
  if(x>limit || x+header.ColumnWidth(column)<=1)
     return;
  int w=::MathMin(header.ColumnWidth(column),limit-x+2);
  view.DrawCell(canvas,
              x,
              y,
              w,
              h,
              back,
              text,
              (this.HasTextAlign(column) ? this.ColumnTextAlign(column) : header.ColumnContentAlign(column)),   // the row's own, else the column's
              header.ColumnTextXOffset(column),
              header.ColumnImageXOffset(column),
              selected);
 }
//+------------------------------------------------------------------+
//| One cell; a scrolled cell that reaches under the fixed columns   |
//| at left is followed by those cells, drawn over it                |
//+------------------------------------------------------------------+
void CTableRowView::DrawCellAt(CCanvas &canvas,CTableHeaderView &header,const int column,const int y,const int h,const int right,
                               const color back,const color text,const color grid,const bool selected)
 {
  this.DrawCellOnly(canvas,header,column,y,h,right,back,text,grid,selected);
  int left_end,right_start;
  if(!header.FixedLayout(left_end,right_start) || header.ColumnRegion(column)!=0 || header.ColumnX(column)>=left_end)
     return;
  for(int c=0; c<this.CellsTotal(); c++)
     if(header.ColumnRegion(c)==1)
        this.DrawCellOnly(canvas,header,c,y,h,right,back,text,grid,selected);
  canvas.Line(left_end-1,y,left_end-1,y+h-1,::ColorToARGB(grid,255));
 }
//+------------------------------------------------------------------+
//| Every cell, then the row's grid: the scrolled cells first, the   |
//| fixed ones over them                                             |
//+------------------------------------------------------------------+
void CTableRowView::DrawRow(CCanvas &canvas,CTableHeaderView &header,const int y,const int h,const int right,
                            const color back,const color text,const color grid,const bool selected)
 {
  uint grid_color=::ColorToARGB(grid,255);
  int left_end,right_start;
  bool fixed=header.FixedLayout(left_end,right_start);
  for(int pass=0; pass<(fixed ? 2 : 1); pass++)
     for(int i=0; i<this.CellsTotal(); i++)
       {
        if(!header.ColumnShown(i))
           continue;
        if(fixed && (header.ColumnRegion(i)!=0)!=(pass==1))
           continue;
        this.DrawCellOnly(canvas,header,i,y,h,right,back,text,grid,selected);
        int x2=header.ColumnX(i)+header.ColumnWidth(i)-1;
        if(x2>=1 && x2<=right)
           canvas.Line(x2,y,x2,y+h-1,grid_color);
       }
  canvas.Line(1,y+h-1,right,y+h-1,grid_color);
 }
#endif // CTABLEROWVIEW_MQH_IMPLEMENTATION
#endif // CTABLEROWVIEW_MQH
