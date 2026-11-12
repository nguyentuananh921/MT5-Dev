//+------------------------------------------------------------------+
//|                                                   TableModel.mqh |
//| MVC table model (articles 17653..20596)                          |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEMODEL_MQH
#define CTABLEMODEL_MQH
 #include "TableRow.mqh"
 #include "TableHeader.mqh"
#ifndef CTABLEMODEL_MQH_DECLARATION
#define CTABLEMODEL_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Header + rows of cells, pure data                                |
//+------------------------------------------------------------------+
class CTableModel : public CBaseObj
 {
  private:
    CTableHeader      m_header;
    CArrayObj         m_list_rows;

    void              RowsReindex(void);
  public:
    void              CreateTableModel(const uint num_rows,const uint num_columns);
    CTableHeader     *Header(void)                               { return(::GetPointer(this.m_header)); }
    uint              RowsTotal(void)                      const { return(this.m_list_rows.Total());    }
    uint              ColumnsTotal(void)                   const { return(this.m_header.ColumnsTotal()); }
    CTableRow        *Row(const uint index)                      { return(dynamic_cast<CTableRow *>(this.m_list_rows.At(index))); }
    CTableCell       *Cell(const uint row,const uint col);
    CTableRow        *AddRow(const int index=WRONG_VALUE);
    bool              RowDelete(const uint index);
    void              DeleteAllRows(void)                        { this.m_list_rows.Clear(); }
    void              ColumnSetDigits(const uint index,const int digits);
    void              SortByColumn(const uint column,const bool descending);
    template<typename T> void CellSetValue(const uint row,const uint col,const T value);
                     CTableModel(void)                           { this.m_list_rows.FreeMode(true); }
                    ~CTableModel(void) {}
 };
#endif // CTABLEMODEL_MQH_DECLARATION
#ifndef CTABLEMODEL_MQH_IMPLEMENTATION
#define CTABLEMODEL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| num_columns captions, num_rows empty rows                        |
//+------------------------------------------------------------------+
void CTableModel::CreateTableModel(const uint num_rows,const uint num_columns)
 {
  this.m_list_rows.Clear();
  this.m_header.SetColumnsTotal((int)num_columns);
  for(uint i=0; i<num_rows; i++)
     this.AddRow();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTableCell *CTableModel::Cell(const uint row,const uint col)
 {
  CTableRow *table_row=this.Row(row);
  return(table_row!=NULL ? table_row.Cell((int)col) : NULL);
 }
//+------------------------------------------------------------------+
//| Inserts at index (appends when out of range)                     |
//+------------------------------------------------------------------+
CTableRow *CTableModel::AddRow(const int index=WRONG_VALUE)
 {
  CTableRow *row=new CTableRow();
  if(row==NULL)
     return(NULL);
  if(!row.CreateCells(this.m_header.ColumnsTotal()))
    {
     delete row;
     return(NULL);
    }
  int total=this.m_list_rows.Total();
  bool added=(index<0 || index>=total ? this.m_list_rows.Add(row) : this.m_list_rows.Insert(row,index));
  if(!added)
    {
     delete row;
     return(NULL);
    }
  this.RowsReindex();
  return(row);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTableModel::RowDelete(const uint index)
 {
  if(!this.m_list_rows.Delete((int)index))
     return(false);
  this.RowsReindex();
  return(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableModel::RowsReindex(void)
 {
  for(int i=0; i<this.m_list_rows.Total(); i++)
    {
     CTableRow *row=this.Row(i);
     if(row!=NULL)
        row.SetIndex(i);
    }
 }
//+------------------------------------------------------------------+
//| Same digits for every cell of the column                         |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetDigits(const uint index,const int digits)
 {
  for(uint i=0; i<this.RowsTotal(); i++)
    {
     CTableCell *cell=this.Cell(i,index);
     if(cell!=NULL)
        cell.SetDigits(digits);
    }
 }
//+------------------------------------------------------------------+
//| MVC SortByColumn: rows reordered, indexes renumbered             |
//+------------------------------------------------------------------+
void CTableModel::SortByColumn(const uint column,const bool descending)
 {
  if(column>=this.ColumnsTotal())
     return;
  this.m_list_rows.Sort((int)column|(descending ? TABLE_SORT_DESCEND_FLAG : 0));
  this.RowsReindex();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T> void CTableModel::CellSetValue(const uint row,const uint col,const T value)
 {
  CTableCell *cell=this.Cell(row,col);
  if(cell!=NULL)
     cell.SetValue(value);
 }
#endif // CTABLEMODEL_MQH_IMPLEMENTATION
#endif // CTABLEMODEL_MQH
