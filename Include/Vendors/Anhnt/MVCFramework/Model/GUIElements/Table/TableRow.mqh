//+------------------------------------------------------------------+
//|                                              19979 MVC Table.mq5 |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns	         |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+
//| Table row class                                                  |
//+------------------------------------------------------------------+

#ifndef __TABLE_ROW_MQH__
#define __TABLE_ROW_MQH__


//|Include stadard library
#include <Object.mqh>

#include "..\Base\BaseEnums.mqh" // enums
//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
// required full class definitions
#include "TableCell.mqh"
// forward declarations
class CListObj;

class CTableRow : public CObject
  {
protected:
   CTableCell m_cell_tmp;     // Temporary cell object used for searching in the list
   CListObj   *m_list_cells;   // List of cells
   uint       m_index;        // Row index

//--- Adds the specified cell to the end of the list
   bool AddNewCell(CTableCell *cell);

public:

   //--- (1) Set, (2) get row index
      void SetIndex(const uint index) { this.m_index=index; }
      uint Index(void) const          { return this.m_index; }

   //--- Update row and column position for all cells
      void CellsPositionUpdate(void);

   //--- Create new cell and add it to the end of the list
      CTableCell *CellAddNew(const double value);
      CTableCell *CellAddNew(const long value);
      CTableCell *CellAddNew(const datetime value);
      CTableCell *CellAddNew(const color value);
      CTableCell *CellAddNew(const string value);

   //--- (1) Return cell by index, (2) return number of cells
      CTableCell *GetCell(const uint index) { return this.m_list_cells.GetNodeAtIndex(index); }
      uint CellsTotal(void) const           { return this.m_list_cells.Total(); }

   //--- Set value in specified cell
      void CellSetValue(const uint index,const double value);
      void CellSetValue(const uint index,const long value);
      void CellSetValue(const uint index,const datetime value);
      void CellSetValue(const uint index,const color value);
      void CellSetValue(const uint index,const string value);

   //--- (1) Assign object to cell, (2) unassign object from cell
      void CellAssignObject(const uint index,CObject *object);
      void CellUnassignObject(const uint index);

   //--- (1) Get assigned object, (2) get type of assigned object
      CObject *CellGetObject(const uint index);
      ENUM_OBJECT_TYPE CellGetObjType(const uint index);

   //--- (1) Delete cell, (2) move cell
      bool CellDelete(const uint index);
      bool CellMoveTo(const uint cell_index,const uint index_to);

   //--- Clear cell data in the row
      void ClearData(void);

   //--- (1) Return description, (2) print description to log
      virtual string Description(void);
      void Print(const bool detail,const bool as_table=false,const int cell_width=CELL_WIDTH_IN_CHARS);

   //--- Virtual methods: (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int Compare(const CObject *node,const int mode=0) const;
      virtual bool Save(const int file_handle);
      virtual bool Load(const int file_handle);
      virtual int Type(void) const { return OBJECT_TYPE_TABLE_ROW; }

   //--- Constructors / destructor
      CTableRow(void) : m_index(0) {m_list_cells = new CListObj;}
      CTableRow(const uint index) : m_index(index) {m_list_cells = new CListObj;}
   ~CTableRow(void){delete m_list_cells;}
  };

//+------------------------------------------------------------------+
//| Compare two objects                                              |
//+------------------------------------------------------------------+
int CTableRow::Compare(const CObject *node,const int mode=0) const
  {
   /*
      Sort(0)                     - sort by row index

      Sort(ASC_IDX_CORRECTION)   - ascending by column 0
      Sort(1+ASC_IDX_CORRECTION) - ascending by column 1
      Sort(2+ASC_IDX_CORRECTION) - ascending by column 2

      Sort(DESC_IDX_CORRECTION)   - descending by column 0
      Sort(1+DESC_IDX_CORRECTION) - descending by column 1
      Sort(2+DESC_IDX_CORRECTION) - descending by column 2
   */

   if(node==NULL)
      return -1;

   if(mode==0)
     {
      const CTableRow *obj=node;
      return(this.Index()>obj.Index() ? 1 : this.Index()<obj.Index() ? -1 : 0);
     }

   bool asc=(mode>=ASC_IDX_CORRECTION && mode<DESC_IDX_CORRECTION);
   int col=mode%(asc ? ASC_IDX_CORRECTION : DESC_IDX_CORRECTION);

//--- remove const
   CTableRow *nonconst_this=(CTableRow*)&this;
   CTableRow *nonconst_node=(CTableRow*)node;

//--- get cells
   CTableCell *cell_current =nonconst_this.GetCell(col);
   CTableCell *cell_compared=nonconst_node.GetCell(col);

   if(cell_current==NULL || cell_compared==NULL)
      return -1;

//--- compare depending on datatype
   int cmp=0;

   switch(cell_current.Datatype())
     {
      case TYPE_DOUBLE:
         cmp=(cell_current.ValueD()>cell_compared.ValueD() ? 1 :
              cell_current.ValueD()<cell_compared.ValueD() ? -1 : 0);
         break;

      case TYPE_LONG:
      case TYPE_DATETIME:
      case TYPE_COLOR:
         cmp=(cell_current.ValueL()>cell_compared.ValueL() ? 1 :
              cell_current.ValueL()<cell_compared.ValueL() ? -1 : 0);
         break;

      case TYPE_STRING:
         cmp=::StringCompare(cell_current.ValueS(),cell_compared.ValueS());
         break;

      default:
         break;
     }

   return(asc ? cmp : -cmp);
  }
  //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CTableRow::Creates a new double-cell and adds it to the list     |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const double value)
  {
   //--- Create a new cell object storing a double value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,2);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
   //--- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   //--- Return pointer to the object
   return cell;
  }

//+------------------------------------------------------------------+
//| CTableRow::Creates a new long-cell and adds it to the list       |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const long value)
  {
//--- Create a new cell object storing a long value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
//--- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| CTableRow::Creates a new datetime-cell and adds it to the list   |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const datetime value)
  {
//--- Create a new cell object storing a datetime value with default flags
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
//--- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| CTableRow::Creates a new color-cell and adds it to the list      |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const color value)
  {
//--- Create a new cell object storing a color value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,true);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
//--- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| CTableRow::Creates a new string-cell and adds it to the list     |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CellAddNew(const string value)
  {
//--- Create a new cell object storing a string value
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
//--- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
   return cell;
  }

//+------------------------------------------------------------------+
//| CTableRow::Internal helper to add a cell to the list             |
//+------------------------------------------------------------------+
bool CTableRow::AddNewCell(CTableCell *cell)
  {
//--- If an empty object is passed - report and return false
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Empty CTableCell object passed",__FUNCTION__);
      return false;
     }
//--- Set cell position indices and add to the list
   cell.SetPositionInTable(this.m_index,this.CellsTotal());
   if(this.m_list_cells.Add(cell)==WRONG_VALUE)
     {
      ::PrintFormat("%s: Error. Failed to add cell (%u,%u) to list",__FUNCTION__,this.m_index,this.CellsTotal());
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRow::Sets double value in a specific cell                  |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const double value)
  {
//--- Retrieve cell by index and update its value
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }

//+------------------------------------------------------------------+
//| CTableRow::Sets long value in a specific cell                    |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const long value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }

//+------------------------------------------------------------------+
//| CTableRow::Sets datetime value in a specific cell                |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const datetime value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }

//+------------------------------------------------------------------+
//| CTableRow::Sets color value in a specific cell                   |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const color value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }

//+------------------------------------------------------------------+
//| CTableRow::Sets string value in a specific cell                  |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const string value)
  {
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }

//+------------------------------------------------------------------+
//| CTableRow::Assigns an object to a cell                           |
//+------------------------------------------------------------------+
void CTableRow::CellAssignObject(const uint index,CObject *object)
  {
//--- Retrieve cell and assign a pointer to an external object
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.AssignObject(object);
  }

//+------------------------------------------------------------------+
//| CTableRow::Clears the assigned object from a cell                |
//+------------------------------------------------------------------+
void CTableRow::CellUnassignObject(const uint index)
  {
//--- Retrieve cell and reset its object pointer and type
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.UnassignObject();
  }
//+------------------------------------------------------------------+
//| CTableRow::Returns the object assigned to the cell               |
//+------------------------------------------------------------------+
CObject *CTableRow::CellGetObject(const uint index)
  {
//--- Get the cell from the list and return the pointer to the assigned object
   CTableCell *cell=this.GetCell(index);
   return(cell!=NULL ? cell.AssignedObject() : NULL);
  }

//+------------------------------------------------------------------+
//| CTableRow::Returns the type of the object assigned to the cell   |
//+------------------------------------------------------------------+
ENUM_OBJECT_TYPE CTableRow::CellGetObjType(const uint index)
  {
//--- Get the cell from the list and return the type of the assigned object
   CTableCell *cell=this.GetCell(index);
   return(cell!=NULL ? cell.AssignedObjType() : (ENUM_OBJECT_TYPE)WRONG_VALUE);
  }

//+------------------------------------------------------------------+
//| CTableRow::Deletes a cell                                        |
//+------------------------------------------------------------------+
bool CTableRow::CellDelete(const uint index)
  {
//--- Delete the cell from the list by index
   if(!this.m_list_cells.Delete(index))
      return false;
//--- Update indices for the remaining cells in the list
   this.CellsPositionUpdate();
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRow::Moves a cell to the specified position                |
//+------------------------------------------------------------------+
bool CTableRow::CellMoveTo(const uint cell_index,const uint index_to)
  {
//--- Get the target cell by index, making it the current list item
   CTableCell *cell=this.GetCell(cell_index);
//--- Move the current cell to the specified position in the list
   if(cell==NULL || !this.m_list_cells.MoveToIndex(index_to))
      return false;
//--- Update indices for all cells in the list
   this.CellsPositionUpdate();
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRow::Updates row and column positions for all cells        |
//+------------------------------------------------------------------+
void CTableRow::CellsPositionUpdate(void)
  {
//--- Loop through all cells in the list
   for(int i=0;i<this.m_list_cells.Total();i++)
     {
      //--- Get each cell and update its row and column indices
      CTableCell *cell=this.GetCell(i);
      if(cell!=NULL)
          cell.SetPositionInTable(this.Index(),this.m_list_cells.IndexOf(cell));
     }
  }

//+------------------------------------------------------------------+
//| CTableRow::Clears data for all cells in the row                  |
//+------------------------------------------------------------------+
void CTableRow::ClearData(void)
  {
//--- Loop through all cells in the list
   for(uint i=0;i<this.CellsTotal();i++)
     {
      //--- Get each cell and set its value to empty/default
      CTableCell *cell=this.GetCell(i);
      if(cell!=NULL)
          cell.ClearData();
     }
  }

//+------------------------------------------------------------------+
//| CTableRow::Returns object description                            |
//+------------------------------------------------------------------+
string CTableRow::Description(void)
  {
   return(::StringFormat("%s: Position %u, Cells total: %u",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Index(),this.CellsTotal()));
  }

//+------------------------------------------------------------------+
//| CTableRow::Prints row description to the journal                 |
//+------------------------------------------------------------------+
void CTableRow::Print(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS)
  {
//--- Number of cells
   int total=(int)this.CellsTotal();
   string res="";
   
//--- If outputting in table format
   if(as_table)
     {
      //--- Create a table row string from all cell values
      string head=" Row "+(string)this.Index();
      res=::StringFormat("|%-*s |",cell_width,head);
      for(int i=0;i<total;i++)
        {
         CTableCell *cell=this.GetCell(i);
         if(cell==NULL)
            continue;
         res+=::StringFormat("%*s |",cell_width,cell.Value());
        }
      //--- Print the row to the journal
      ::Print(res);
      return;
     }
     
//--- Print header as row description
   ::Print(this.Description()+(detail ? ":" : ""));
   
//--- If detailed description is requested
   if(detail)
     {
      //--- Loop through the row's cell list
      for(int i=0; i<total; i++)
        {
         //--- Get current cell and append its description to the result string
         CTableCell *cell=this.GetCell(i);
         if(cell!=NULL)
            res+="  "+cell.Description()+(i<total-1 ? "\n" : "");
        }
      //--- Print the generated description string to the journal
      ::Print(res);
     }
  }

//+------------------------------------------------------------------+
//| CTableRow::Save to file                                          |
//+------------------------------------------------------------------+
bool CTableRow::Save(const int file_handle)
  {
//--- Check file handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Save data start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
      return(false);
//--- Save object type
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return(false);

//--- Save index
   if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
      return(false);
//--- Save cells list
   if(!this.m_list_cells.Save(file_handle))
      return(false);
   
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRow::Load from file                                        |
//+------------------------------------------------------------------+
bool CTableRow::Load(const int file_handle)
  {
//--- Check file handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Load and verify data start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);
//--- Load object type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return(false);

//--- Load index
   this.m_index=::FileReadInteger(file_handle,INT_VALUE);
//--- Load cells list
   if(!this.m_list_cells.Load(file_handle))
      return(false);
   
//--- Success
   return true;
  }
  #endif 