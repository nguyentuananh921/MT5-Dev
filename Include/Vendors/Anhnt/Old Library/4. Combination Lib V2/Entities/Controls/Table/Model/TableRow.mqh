//+------------------------------------------------------------------+
//|                                                     TableRow.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEROW_MQH
#define CTABLEROW_MQH
 #include "TableCell.mqh"
 #define TABLE_SORT_DESCEND_FLAG  (0x10000)
#ifndef CTABLEROW_MQH_DECLARATION
#define CTABLEROW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Row = owner of its cells                                         |
//+------------------------------------------------------------------+
class CTableRow : public CBaseObj
 {
  private:
    CArrayObj         m_list_cells;
    int               m_index;
  public:
    bool              CreateCells(const int total);
    CTableCell       *Cell(const int index)                  { return(dynamic_cast<CTableCell *>(this.m_list_cells.At(index))); }
    int               CellsTotal(void)                 const { return(this.m_list_cells.Total()); }
    void              SetIndex(const int index)              { this.m_index=index;  }
    int               Index(void)                      const { return(this.m_index); }
    virtual int       Compare(const CObject *node,const int mode=0) const;
                     CTableRow(void) : m_index(0)            { this.m_list_cells.FreeMode(true); }
                    ~CTableRow(void) {}
 };
#endif // CTABLEROW_MQH_DECLARATION
#ifndef CTABLEROW_MQH_IMPLEMENTATION
#define CTABLEROW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Adds or removes cells from the end to reach total                |
//+------------------------------------------------------------------+
bool CTableRow::CreateCells(const int total)
 {
  while(this.m_list_cells.Total()>total)
     this.m_list_cells.Delete(this.m_list_cells.Total()-1);
  while(this.m_list_cells.Total()<total)
    {
     CTableCell *cell=new CTableCell();
     if(cell==NULL || !this.m_list_cells.Add(cell))
       {
        delete cell;
        return(false);
       }
    }
  return(true);
 }
//+------------------------------------------------------------------+
//| mode = column | TABLE_SORT_DESCEND_FLAG; compares by cell type   |
//+------------------------------------------------------------------+
int CTableRow::Compare(const CObject *node,const int mode=0) const
 {
  const CTableRow *other=node;
  int column=(mode & 0xFFFF);
  CTableCell *a=dynamic_cast<CTableCell *>(this.m_list_cells.At(column));
  CTableCell *b=(other!=NULL ? dynamic_cast<CTableCell *>(other.m_list_cells.At(column)) : NULL);
  if(a==NULL || b==NULL)
     return(0);
  int result=0;
  if(a.Datatype()==TYPE_STRING)
     result=::StringCompare(a.ValueS(),b.ValueS());
  else if(a.Datatype()==TYPE_DOUBLE)
     result=(a.ValueD()>b.ValueD() ? 1 : a.ValueD()<b.ValueD() ? -1 : 0);
  else
     result=(a.ValueL()>b.ValueL() ? 1 : a.ValueL()<b.ValueL() ? -1 : 0);
  return((mode & TABLE_SORT_DESCEND_FLAG)!=0 ? -result : result);
 }
#endif // CTABLEROW_MQH_IMPLEMENTATION
#endif // CTABLEROW_MQH
