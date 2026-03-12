//+------------------------------------------------------------------+
//|                                                      ListObj.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//|                           https://www.mql5.com/en/articles/11732 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.04"
#include <Object.mqh>
#include "TableCell.mqh"
#include "../ListObj.mqh"
class CTableRow : public CObject
  {
protected:
   CTableCell         m_cell_tmp;                             // Cell object for searching in the list
   CListObj           m_list_cells;                           // List of cells
   uint               m_index;                                // Row index
   
//--- Adds the specified cell to the end of the list
   bool               AddNewCell(CTableCell *cell);
   
public:
//--- (1) Sets, (2) returns the row index
   void               SetIndex(const uint index)                { this.m_index=index;  }
   uint               Index(void)                         const { return this.m_index; }
//--- Updates the row and column positions for all cells
   void               CellsPositionUpdate(void);
   
//--- Creates a new cell and adds it to the end of the list
   CTableCell        *CellAddNew(const double value);
   CTableCell        *CellAddNew(const long value);
   CTableCell        *CellAddNew(const datetime value);
   CTableCell        *CellAddNew(const color value);
   CTableCell        *CellAddNew(const string value);
   
//--- Returns (1) a cell by index, (2) the total number of cells
   CTableCell        *GetCell(const uint index)                 { return this.m_list_cells.GetNodeAtIndex(index);  }
   uint               CellsTotal(void)                    const { return this.m_list_cells.Total();                }
   
//--- Sets a value in the specified cell
   void               CellSetValue(const uint index,const double value);
   void               CellSetValue(const uint index,const long value);
   void               CellSetValue(const uint index,const datetime value);
   void               CellSetValue(const uint index,const color value);
   void               CellSetValue(const uint index,const string value);
//--- (1) Assigns an object to a cell, (2) unassigns the object from a cell
   void               CellAssignObject(const uint index,CObject *object);
   void               CellUnassignObject(const uint index);
  
//--- Returns (1) the assigned object, (2) the type of the assigned object
   CObject           *CellGetObject(const uint index);
   ENUM_TABLE_OBJECT_TYPE  CellGetObjType(const uint index);
   
//--- (1) Deletes, (2) moves a cell
   bool               CellDelete(const uint index);
   bool               CellMoveTo(const uint cell_index, const uint index_to);
   
//--- Resets data in all cells of the row
   void               ClearData(void);

//--- (1) Returns, (2) prints the object description to the journal
   virtual string     Description(void);
   void               Print(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);

//--- Virtual methods: (1) comparison, (2) save to file, (3) load from file, (4) object type
   virtual int        Compare(const CObject *node,const int mode=0) const;
   virtual bool       Save(const int file_handle);
   virtual bool       Load(const int file_handle);
   virtual int        Type(void)                          const { return(OBJECT_TYPE_TABLE_ROW); }
   
//--- Constructors/Destructor
                      CTableRow(void) : m_index(0) {}
                      CTableRow(const uint index) : m_index(index) {}
                     ~CTableRow(void){}
  };

//+------------------------------------------------------------------+
//| Comparison of two objects                                        |
//+------------------------------------------------------------------+
int CTableRow::Compare(const CObject *node,const int mode=0) const
  {
/*
    Sort(0)                      - by row index
    
    Sort(ASC_IDX_CORRECTION)     - ascending by column 0
    Sort(1+ASC_IDX_CORRECTION)   - ascending by column 1
    Sort(2+ASC_IDX_CORRECTION)   - ascending by column 2
    etc.
    Sort(DESC_IDX_CORRECTION)    - descending by column 0
    Sort(1+DESC_IDX_CORRECTION)  - descending by column 1
    Sort(2+DESC_IDX_CORRECTION)  - descending by column 2
    etc.
*/  
   if(node==NULL)
      return -1;
   
   if(mode==0)
     {
      const CTableRow *obj=node;
      return(this.Index()>obj.Index() ? 1 : this.Index()<obj.Index() ? -1 : 0);
     }
   
//--- Identify sorting direction and column index
   bool asc=(mode>=ASC_IDX_CORRECTION && mode<DESC_IDX_CORRECTION);
   int  col= mode%(asc ? ASC_IDX_CORRECTION : DESC_IDX_CORRECTION);
      
//--- Remove constness of node for pointer operations
   CTableRow *nonconst_this=(CTableRow*)&this;
   CTableRow *nonconst_node=(CTableRow*)node;

//--- Get current and compared cells by column index
   CTableCell *cell_current =nonconst_this.GetCell(col);
   CTableCell *cell_compared=nonconst_node.GetCell(col);
   if(cell_current==NULL || cell_compared==NULL)
      return -1;
   
//--- Compare depending on cell data type
   int cmp=0;
   switch(cell_current.Datatype())
     {
      case TYPE_DOUBLE  :  cmp=(cell_current.ValueD()>cell_compared.ValueD() ? 1 : cell_current.ValueD()<cell_compared.ValueD() ? -1 : 0); break;
      case TYPE_LONG    :
      case TYPE_DATETIME:
      case TYPE_COLOR   :  cmp=(cell_current.ValueL()>cell_compared.ValueL() ? 1 : cell_current.ValueL()<cell_compared.ValueL() ? -1 : 0); break;
      case TYPE_STRING  :  cmp=::StringCompare(cell_current.ValueS(),cell_compared.ValueS());                                             break;
      default           :  break;
     }
   return(asc ? cmp : -cmp);   
  }

//+------------------------------------------------------------------+
//| Creates a new double-cell and adds it to the end of the list     |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const double value)
  {
//--- Create new cell object for double value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,2);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
//--- Add created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
//--- Return pointer to the object
   return cell;
  }

//+------------------------------------------------------------------+
//| Creates a new long-cell and adds it to the end of the list       |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const long value)
  {
//--- Create new cell object for long value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
//--- Add created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| Creates a new datetime-cell and adds it to the end of the list   |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const datetime value)
  {
//--- Create new cell object for datetime value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| Creates a new color-cell and adds it to the end of the list      |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const color value)
  {
//--- Create new cell object for color value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,true);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| Creates a new string-cell and adds it to the end of the list     |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const string value)
  {
//--- Create new cell object for string value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| Adds a cell to the end of the list                               |
//+------------------------------------------------------------------+
bool CTableRow::AddNewCell(CTableCell *cell)
  {
//--- Return false if the passed object is null
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Empty CTableCell object passed",__FUNCTION__);
      return false;
     }
//--- Set cell index and add it to the list
   cell.SetPositionInTable(this.m_index,this.CellsTotal());
   if(this.m_list_cells.Add(cell)==WRONG_VALUE)
     {
      ::PrintFormat("%s: Error. Failed to add cell (%u,%u) to list",__FUNCTION__,this.m_index,this.CellsTotal());
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Value setters for specific cell indexes                          |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const double value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL) cell.SetValue(value);
  }
void CTableRow::CellSetValue(const uint index,const long value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL) cell.SetValue(value);
  }
void CTableRow::CellSetValue(const uint index,const datetime value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL) cell.SetValue(value);
  }
void CTableRow::CellSetValue(const uint index,const color value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL) cell.SetValue(value);
  }
void CTableRow::CellSetValue(const uint index,const string value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL) cell.SetValue(value);
  }

//+------------------------------------------------------------------+
//| Assigns/Unassigns an external object to a cell                   |
//+------------------------------------------------------------------+
void CTableRow::CellAssignObject(const uint index,CObject *object)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL) cell.AssignObject(object);
  }
void CTableRow::CellUnassignObject(const uint index)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL) cell.UnassignObject();
  }

//+------------------------------------------------------------------+
//| Returns assigned object or its type from a cell                  |
//+------------------------------------------------------------------+
CObject *CTableRow::CellGetObject(const uint index)
  {
   CTableCell *cell=this.GetCell(index);
   return(cell!=NULL ? cell.AssignedObject() : NULL);
  }
ENUM_TABLE_OBJECT_TYPE CTableRow::CellGetObjType(const uint index)
  {
   CTableCell *cell=this.GetCell(index);
   return(cell!=NULL ? cell.AssignedObjType() : (ENUM_TABLE_OBJECT_TYPE)WRONG_VALUE);
  }

//+------------------------------------------------------------------+
//| Deletes a cell and updates positions                             |
//+------------------------------------------------------------------+
bool CTableRow::CellDelete(const uint index)
  {
   if(!this.m_list_cells.DeleteAtIndex(index)) // Using our custom DeleteAtIndex
      return false;
   this.CellsPositionUpdate();
   return true;
  }

//+------------------------------------------------------------------+
//| Moves a cell to a new position and updates indices               |
//+------------------------------------------------------------------+
bool CTableRow::CellMoveTo(const uint cell_index,const uint index_to)
  {
   CTableCell *cell=this.GetCell(cell_index);
   if(cell==NULL || !this.m_list_cells.MoveToIndex((int)cell_index,(int)index_to))
      return false;
   this.CellsPositionUpdate();
   return true;
  }

//+------------------------------------------------------------------+
//| Updates row and column indices for all cells in the row          |
//+------------------------------------------------------------------+
void CTableRow::CellsPositionUpdate(void)
  {
   for(int i=0;i<this.m_list_cells.Total();i++)
     {
      CTableCell *cell=this.GetCell(i);
      if(cell!=NULL)
         cell.SetPositionInTable(this.Index(),(uint)i); // Direct use of loop index i
     }
  }

//+------------------------------------------------------------------+
//| Clears data for all cells in the row                             |
//+------------------------------------------------------------------+
void CTableRow::ClearData(void)
  {
   for(uint i=0;i<this.CellsTotal();i++)
     {
      CTableCell *cell=this.GetCell(i);
      if(cell!=NULL) cell.ClearData();
     }
  }

//+------------------------------------------------------------------+
//| Returns object description string                                |
//+------------------------------------------------------------------+
/*
string CTableRow::Description(void)
  {
   return(::StringFormat("%s: Position %u, Cells total: %u",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Index(),this.CellsTotal()));
  }
/*
//+------------------------------------------------------------------+
//| Prints object description to the journal                         |
//+------------------------------------------------------------------+
void CTableRow::Print(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS)
  {
   int total=(int)this.CellsTotal();
   
//--- Table-style output
   if(as_table)
     {
      string head=" Row "+(string)this.Index();
      string res=::StringFormat("|%-*s |",cell_width,head);
      for(int i=0;i<total;i++)
        {
         CTableCell *cell=this.GetCell(i);
         if(cell==NULL) continue;
         res+=::StringFormat("%*s |",cell_width,cell.Value());
        }
      ::Print(res);
      return;
     }
     
//--- Detailed or simple output
   ::Print(this.Description()+(detail ? ":" : ""));
   if(detail)
     {
      string res="";
      for(int i=0; i<total; i++)
        {
         CTableCell *cell=this.GetCell(i);
         if(cell!=NULL)
            res+="  "+cell.Description()+(i<total-1 ? "\n" : "");
        }
      ::Print(res);
     }
  }

//+------------------------------------------------------------------+
//| Save to file                                                     |
//+------------------------------------------------------------------+
bool CTableRow::Save(const int file_handle)
  {
   if(file_handle==INVALID_HANDLE) return(false);
   if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long)) return(false);
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE) return(false);
   if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE) return(false);
   if(!this.m_list_cells.Save(file_handle)) return(false);
   return true;
  }

//+------------------------------------------------------------------+
//| Load from file                                                   |
//+------------------------------------------------------------------+
bool CTableRow::Load(const int file_handle)
  {
   if(file_handle==INVALID_HANDLE) return(false);
   if(::FileReadLong(file_handle)!=MARKER_START_DATA) return(false);
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type()) return(false);
   this.m_index=::FileReadInteger(file_handle,INT_VALUE);
   if(!this.m_list_cells.Load(file_handle)) return(false);
   return true;
  }