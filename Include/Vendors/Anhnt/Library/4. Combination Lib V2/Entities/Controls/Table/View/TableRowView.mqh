//+------------------------------------------------------------------+
//|                                                 TableRowView.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEROWVIEW_MQH
#define CTABLEROWVIEW_MQH
 #include "TableCellView.mqh"
 #include "TableHeaderView.mqh"
 #include "..\Model\TableRow.mqh"
#ifndef CTABLEROWVIEW_MQH_DECLARATION
#define CTABLEROWVIEW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Owner of the cell views of one model row                         |
//+------------------------------------------------------------------+
class CTableRowView : public CGBaseObj
 {
  private:
    CTableRow        *m_row;
  public:
    bool              Bind(CTableRow *row);
    CTableRow        *Row(void)                            const { return(this.m_row); }
    CTableCellView   *CellView(const int index)                  { return(dynamic_cast<CTableCellView *>(this.Child(index))); }
    int               CellsTotal(void)                     const { return(this.ChildrenTotal()); }
    bool              IsChanged(void);
    void              ResetChanged(void);
    void              DrawCellAt(CCanvas &canvas,CTableHeaderView &header,const int column,const int y,const int h,const int right,
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
//+------------------------------------------------------------------+
//| One cell, clipped at right, skipped when scrolled out at left    |
//+------------------------------------------------------------------+
void CTableRowView::DrawCellAt(CCanvas &canvas,CTableHeaderView &header,const int column,const int y,const int h,const int right,
                               const color back,const color text,const color grid,const bool selected)
 {
  CTableCellView *view=this.CellView(column);
  if(view==NULL || column>=header.ColumnsTotal())
     return;
  int x=header.ColumnX(column);
  if(x>right || x+header.ColumnWidth(column)<=1)
     return;
  int w=::MathMin(header.ColumnWidth(column),right-x+2);
  view.DrawCell(canvas,x,y,w,h,back,text,header.ColumnTextAlign(column),header.ColumnTextXOffset(column),header.ColumnImageXOffset(column),selected);
 }
//+------------------------------------------------------------------+
//| Every cell, then the row's grid                                  |
//+------------------------------------------------------------------+
void CTableRowView::DrawRow(CCanvas &canvas,CTableHeaderView &header,const int y,const int h,const int right,
                            const color back,const color text,const color grid,const bool selected)
 {
  uint grid_color=::ColorToARGB(grid,255);
  for(int i=0; i<this.CellsTotal(); i++)
    {
     this.DrawCellAt(canvas,header,i,y,h,right,back,text,grid,selected);
     int x2=header.ColumnX(i)+header.ColumnWidth(i)-1;
     if(x2>=1 && x2<=right)
        canvas.Line(x2,y,x2,y+h-1,grid_color);
    }
  canvas.Line(1,y+h-1,right,y+h-1,grid_color);
 }
#endif // CTABLEROWVIEW_MQH_IMPLEMENTATION
#endif // CTABLEROWVIEW_MQH
