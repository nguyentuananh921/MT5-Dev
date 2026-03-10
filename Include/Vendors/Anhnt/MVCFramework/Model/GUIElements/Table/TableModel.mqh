//+------------------------------------------------------------------+
//|                                              TableModel.mqh      |
//+------------------------------------------------------------------+
//|                    Tables in the MVC Paradigm in MQL5             |
//|                 Customizable and sortable table columns           |
//|                          https://www.mql5.com/en/articles/19979  |
//+------------------------------------------------------------------+
#ifndef TABLEMODEL_MQH
#define TABLEMODEL_MQH
//+------------------------------------------------------------------+
//| Table model class                                                |
//+------------------------------------------------------------------+
//| Include standard library                                         |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Arrays/List.mqh>
//+------------------------------------------------------------------+
//| Include custom library                                           |
//+------------------------------------------------------------------+
#include "TableDefines.mqh"
#include "TableEnums.mqh"
#include "ListObj.mqh"
#include "TableCell.mqh"
#include "TableRow.mqh"
#include "MqlParamObj.mqh"

class CTableModel : public CObject
{
protected:
   CTableRow         m_row_tmp;                             // Row object for searching in the list
   CListObj          m_list_rows;                           // List of table rows
   //--- Creates table model from a 2D array
   template<typename T>
   void              CreateTableModel(T &array[][]);
   void              CreateTableModel(const uint num_rows,const uint num_columns);
   void              CreateTableModel(const matrix &row_data);
   void              CreateTableModel(CList &list_param);
   //--- Returns the correct data type
   ENUM_DATATYPE     GetCorrectDatatype(string type_name)
                       {
                        return
                          (
                           //--- Integer value
                           type_name=="bool" || type_name=="char"    || type_name=="uchar"   ||
                           type_name=="short"|| type_name=="ushort"  || type_name=="int"     ||
                           type_name=="uint" || type_name=="long"    || type_name=="ulong"   ?  TYPE_LONG      :
                           //--- Real value
                           type_name=="float"|| type_name=="double"                          ?  TYPE_DOUBLE    :
                           //--- Date/time value
                           type_name=="datetime"                                             ?  TYPE_DATETIME  :
                           //--- Color value
                           type_name=="color"                                                ?  TYPE_COLOR     :
                           /*--- String value */                                                TYPE_STRING    );
                       }
     
   //--- Creates and adds a new empty row to the end of the list
   CTableRow        *CreateNewEmptyRow(void);
   //--- Adds a row to the end of the list
   bool              AddNewRow(CTableRow *row);
   //--- Updates row and column positions for all cells in the table
   void              CellsPositionUpdate(void);   
   public:
   //--- Returns (1) cell, (2) row by index, (3) total rows, (4) cells in specified row, (5) total cells in table
      CTableCell       *GetCell(const uint row, const uint col);
      CTableRow        *GetRow(const uint index)                  { return this.m_list_rows.GetNodeAtIndex(index);}
      uint              RowsTotal(void)                     const { return this.m_list_rows.Total();              }
      uint              CellsInRow(const uint index);
      uint              CellsTotal(void);

   //--- Sets (1) value, (2) digits, (3) time display flags, (4) color names flag in specified cell
   template<typename T>
      void              CellSetValue(const uint row, const uint col, const T value);
      void              CellSetDigits(const uint row, const uint col, const int digits);
      void              CellSetTimeFlags(const uint row, const uint col, const uint flags);
      void              CellSetColorNamesFlag(const uint row, const uint col, const bool flag);
   //--- (1) Assigns, (2) unassigns object in cell
      void              CellAssignObject(const uint row, const uint col,CObject *object);
      void              CellUnassignObject(const uint row, const uint col);
   //--- (1) Deletes, (2) moves cell
      bool              CellDelete(const uint row, const uint col);
      bool              CellMoveTo(const uint row, const uint cell_index, const uint index_to);
   //--- Returns (1) object assigned to cell, (2) type of object assigned to cell
      CObject          *CellGetObject(const uint row, const uint col);
      ENUM_OBJECT_TYPE  CellGetObjType(const uint row, const uint col);
   //--- (1) Returns, (2) logs cell description, (3) object assigned to cell
      string            CellDescription(const uint row, const uint col);
      void              CellPrint(const uint row, const uint col);
      
   public:
   //--- Creates a new row and (1) adds to end of list, (2) inserts at specified position
      CTableRow        *RowAddNew(void);
      CTableRow        *RowInsertNewTo(const uint index_to);
   //--- (1) Deletes, (2) moves row, (3) clears row data
      bool              RowDelete(const uint index);
      bool              RowMoveTo(const uint row_index, const uint index_to);
      void              RowClearData(const uint index);
   //--- (1) Returns, (2) logs row description
      string            RowDescription(const uint index);
      void              RowPrint(const uint index,const bool detail);
      
   //--- (1) Adds, (2) deletes, (3) moves column, (4) clears data, (5) sets datatype,
   //--- (6) data digits, (7) time flags, (8) color names flag for column
      bool              ColumnAddNew(const int index=-1);
      bool              ColumnDelete(const uint index);
      bool              ColumnMoveTo(const uint col_index, const uint index_to);
      void              ColumnClearData(const uint index);
      void              ColumnSetDatatype(const uint index,const ENUM_DATATYPE type);
      void              ColumnSetDigits(const uint index,const int digits);
      
      void              ColumnSetTimeFlags(const uint index, const uint flags);
      void              ColumnSetColorNamesFlag(const uint index, const bool flag);
   
   //--- Sorts table by specified column and direction
      void              SortByColumn(const uint column, const bool descending);
      
   //--- (1) Returns, (2) logs table description
      virtual string    Description(void);
      void              Print(const bool detail);
      void              PrintTable(const int cell_width=CELL_WIDTH_IN_CHARS);
      
   //--- (1) Clears data, (2) destroys model
      void              ClearData(void);
      void              Destroy(void);
      
   //--- Virtual methods for (1) comparison, (2) saving to file, (3) loading from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0)      const { return -1;         }
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_MODEL);  }
      
   //--- Constructors/Destructor
   template<typename T> CTableModel(T &array[][])                                { this.CreateTableModel(array);                 }
                        CTableModel(const uint num_rows,const uint num_columns)  { this.CreateTableModel(num_rows,num_columns);  }
                        CTableModel(const matrix &row_data)                      { this.CreateTableModel(row_data);              }
                        CTableModel(CList &row_data)                             { this.CreateTableModel(row_data);              }
                        CTableModel(void){}
                     ~CTableModel(void){}
  };

//+------------------------------------------------------------------+
//| Creates table model from a 2D array                              |
//+------------------------------------------------------------------+
template<typename T>
void CTableModel::CreateTableModel(T &array[][])
  {
   //--- Get the number of rows and columns from array properties
   int rows_total=::ArrayRange(array,0);
   int cols_total=::ArrayRange(array,1);
//--- Loop through row indices
   for(int r=0; r<rows_total; r++)
     {
      //--- Create a new empty row and add it to the end of the rows list
      CTableRow *row=this.CreateNewEmptyRow();
      //--- If row is created and added to the list,
      if(row!=NULL)
        {
         //--- Loop through the number of cells in the row 
         //--- Create all cells, adding each new one to the end of the row's cell list
         for(int c=0; c<cols_total; c++)
            row.CellAddNew(array[r][c]);
        }
     }
  }

//+------------------------------------------------------------------+
//| Creates table model from specified number of rows and columns    |
//+------------------------------------------------------------------+
void CTableModel::CreateTableModel(const uint num_rows,const uint num_columns)
  {
//--- Loop through the number of rows
   for(uint r=0; r<num_rows; r++)
     {
      //--- Create a new empty row and add it to the end of the rows list
      CTableRow *row=this.CreateNewEmptyRow();
      //--- If row is created and added to the list,
      if(row!=NULL)
        {
         //--- Loop through the number of columns
         //--- Create all cells, adding each new one to the end of the row's cell list
         for(uint c=0; c<num_columns; c++)
           {
            CTableCell *cell=row.CellAddNew(0.0);
            if(cell!=NULL)
               cell.ClearData();
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Creates table model from specified matrix                        |
//+------------------------------------------------------------------+
void CTableModel::CreateTableModel(const matrix &row_data)
  {
//--- Number of rows and columns
   ulong num_rows=row_data.Rows();
   ulong num_columns=row_data.Cols();
//--- Loop through the number of rows
   for(uint r=0; r<num_rows; r++)
     {
      //--- Create a new empty row and add it to the end of the rows list
      CTableRow *row=this.CreateNewEmptyRow();
      //--- If row is created and added to the list,
      if(row!=NULL)
        {
         //--- Loop through the number of columns
         //--- Create all cells, adding each new one to the end of the row's cell list
         for(uint c=0; c<num_columns; c++)
            row.CellAddNew(row_data[r][c]);
        }
     }
  }

//+------------------------------------------------------------------+
//| Creates table model from parameter list                          |
//+------------------------------------------------------------------+
void CTableModel::CreateTableModel(CList &list_param)
  {
//--- If an empty list is passed - report and exit
   if(list_param.Total()==0)
     {
      ::PrintFormat("%s: Error. Empty list passed",__FUNCTION__);
      return;
     }
//--- Get pointer to the first row to determine column count
//--- If failed to get first row or it has no cells - report and exit
   CList *first_row=list_param.GetFirstNode();
   if(first_row==NULL || first_row.Total()==0)
     {
      if(first_row==NULL)
         ::PrintFormat("%s: Error. Failed to get first row of list",__FUNCTION__);
      else
         ::PrintFormat("%s: Error. First row does not contain data",__FUNCTION__);
      return;
     }
//--- Number of rows and columns
   ulong num_rows=list_param.Total();
   ulong num_columns=first_row.Total();
//--- Loop through the number of rows
   for(uint r=0; r<num_rows; r++)
     {
      //--- Get the next table row from list_param
      CList *col_list=list_param.GetNodeAtIndex(r);
      if(col_list==NULL)
         continue;
      //--- Create a new empty row and add it to the end of the rows list
      CTableRow *row=this.CreateNewEmptyRow();
      //--- If row is created and added to the list,
      if(row!=NULL)
        {
         //--- Loop through the number of columns
         //--- Create all cells, adding each new one to the end of the row's cell list
         for(uint c=0; c<num_columns; c++)
           {
            CMqlParamObj *param=col_list.GetNodeAtIndex(c);
            if(param==NULL)
               continue;

            //--- Declare cell pointer and data type it will contain
            CTableCell *cell=NULL;
            ENUM_DATATYPE datatype=param.Datatype();
            //--- Depending on data type
            switch(datatype)
              {
               //--- Real data type
               case TYPE_FLOAT   :
               case TYPE_DOUBLE  :  cell=row.CellAddNew((double)param.ValueD());    // Create new cell with double data
                                    if(cell!=NULL)
                                       cell.SetDigits((int)param.ValueL());         // and set display precision
                                    break;
               //--- datetime data type
               case TYPE_DATETIME:  cell=row.CellAddNew((datetime)param.ValueL());  // Create new cell with datetime data
                                    if(cell!=NULL)
                                       cell.SetDatetimeFlags((int)param.ValueD());  // and set date/time display flags
                                    break;
               //--- color data type
               case TYPE_COLOR   :  cell=row.CellAddNew((color)param.ValueL());     // Create new cell with color data
                                    if(cell!=NULL)
                                       cell.SetColorNameFlag((bool)param.ValueD()); // and set color name display flag
                                    break;
               //--- string data type
               case TYPE_STRING  :  cell=row.CellAddNew((string)param.ValueS());    // Create new cell with string data
                                    break; 
               //--- integer data type
               default           :  cell=row.CellAddNew((long)param.ValueL());      // Create new cell with long data
                                    break; 
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Creates a new empty row and adds to the end of the list          |
//+------------------------------------------------------------------+
CTableRow *CTableModel::CreateNewEmptyRow(void)
  {
//--- Create a new row object
   CTableRow *row=new CTableRow(this.m_list_rows.Total());
   if(row==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new row at position %u",__FUNCTION__, this.m_list_rows.Total());
      return NULL;
     }
//--- If row failed to be added to list - delete object and return NULL
   if(!this.AddNewRow(row))
     {
      delete row;
      return NULL;
     }
   
//--- Success - return pointer to created object
   return row;
  }

//+------------------------------------------------------------------+
//| Adds a row to the end of the list                                |
//+------------------------------------------------------------------+
bool CTableModel::AddNewRow(CTableRow *row)
  {
//--- If empty object passed - report and return false
   if(row==NULL)
     {
      ::PrintFormat("%s: Error. Empty CTableRow object passed",__FUNCTION__);
      return false;
     }
//--- Set row index and add to the end of the list
   row.SetIndex(this.RowsTotal());
   if(this.m_list_rows.Add(row)==WRONG_VALUE)
     {
      ::PrintFormat("%s: Error. Failed to add row (%u) to list",__FUNCTION__,row.Index());
      return false;
     }

//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| Creates a new row and adds to the end of the list                |
//+------------------------------------------------------------------+
CTableRow *CTableModel::RowAddNew(void)
  {
//--- Create new empty row and add to rows list
   CTableRow *row=this.CreateNewEmptyRow();
   if(row==NULL)
      return NULL;
      
//--- Create cells based on the first row's cell count
   for(uint i=0;i<this.CellsInRow(0);i++)
      row.CellAddNew(0.0);
   row.ClearData();
   
//--- Success - return pointer to created object
   return row;
  }

//+------------------------------------------------------------------+
//| Creates and adds a new row to the specified list position        |
//+------------------------------------------------------------------+
CTableRow *CTableModel::RowInsertNewTo(const uint index_to)
  {
//--- Create new empty row and add to rows list
   CTableRow *row=this.CreateNewEmptyRow();
   if(row==NULL)
      return NULL;
     
//--- Create cells based on the first row's cell count
   for(uint i=0;i<this.CellsInRow(0);i++)
      row.CellAddNew(0.0);
   row.ClearData();
   
//--- Shift row to position index_to
   this.RowMoveTo(this.m_list_rows.IndexOf(row),index_to);
   
//--- Success - return pointer to created object
   return row;
  }

//+------------------------------------------------------------------+
//| Sets value in the specified cell                                 |
//+------------------------------------------------------------------+
template<typename T>
void CTableModel::CellSetValue(const uint row,const uint col,const T value)
  {
//--- Get cell by row and column indices
   CTableCell *cell=this.GetCell(row,col);
   if(cell==NULL)
      return;
//--- Get correct data type for the value being set
   ENUM_DATATYPE type=this.GetCorrectDatatype(typename(T));
//--- Call the appropriate cell method based on data type
   switch(type)
     {
      case TYPE_DOUBLE  :  cell.SetValue((double)value);    break;
      case TYPE_LONG    :  cell.SetValue((long)value);      break;
      case TYPE_DATETIME:  cell.SetValue((datetime)value);  break;
      case TYPE_COLOR   :  cell.SetValue((color)value);     break;
      case TYPE_STRING  :  cell.SetValue((string)value);    break;
      default           :  break;
     }
  }

//+------------------------------------------------------------------+
//| Sets data display precision in the specified cell                |
//+------------------------------------------------------------------+
void CTableModel::CellSetDigits(const uint row,const uint col,const int digits)
  {
//--- Get cell and call its method to set precision
   CTableCell *cell=this.GetCell(row,col);
   if(cell!=NULL)
      cell.SetDigits(digits);
  }

//+------------------------------------------------------------------+
//| Sets time display flags in the specified cell                    |
//+------------------------------------------------------------------+
void CTableModel::CellSetTimeFlags(const uint row,const uint col,const uint flags)
  {
//--- Get cell and call its method to set flags
   CTableCell *cell=this.GetCell(row,col);
   if(cell!=NULL)
      cell.SetDatetimeFlags(flags);
  }

//+------------------------------------------------------------------+
//| Sets color names display flag in the specified cell              |
//+------------------------------------------------------------------+
void CTableModel::CellSetColorNamesFlag(const uint row,const uint col,const bool flag)
  {
//--- Get cell and call its method to set flag
   CTableCell *cell=this.GetCell(row,col);
   if(cell!=NULL)
      cell.SetColorNameFlag(flag);
  }

//+------------------------------------------------------------------+
//| Assigns an object to the cell                                    |
//+------------------------------------------------------------------+
void CTableModel::CellAssignObject(const uint row,const uint col,CObject *object)
  {
//--- Get cell and call its method to assign object
   CTableCell *cell=this.GetCell(row,col);
   if(cell!=NULL)
      cell.AssignObject(object);
  }

//+------------------------------------------------------------------+
//| Unassigns object from the cell                                   |
//+------------------------------------------------------------------+
void CTableModel::CellUnassignObject(const uint row,const uint col)
  {
//--- Get cell and call its method to unassign object
   CTableCell *cell=this.GetCell(row,col);
   if(cell!=NULL)
      cell.UnassignObject();
  }

//+------------------------------------------------------------------+
//| Deletes a cell                                                   |
//+------------------------------------------------------------------+
bool CTableModel::CellDelete(const uint row,const uint col)
  {
//--- Get row by index and return result of cell deletion
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.CellDelete(col) : false);
  }

//+------------------------------------------------------------------+
//| Moves a cell                                                     |
//+------------------------------------------------------------------+
bool CTableModel::CellMoveTo(const uint row,const uint cell_index,const uint index_to)
  {
//--- Get row by index and return result of cell relocation
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.CellMoveTo(cell_index,index_to) : false);
  }

//+------------------------------------------------------------------+
//| Returns object assigned to the cell                              |
//+------------------------------------------------------------------+
CObject *CTableModel::CellGetObject(const uint row,const uint col)
  {
//--- Get row by index and return object assigned to cell at index col
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.CellGetObject(col) : NULL);
  }

//+------------------------------------------------------------------+
//| Returns type of object assigned to the cell                      |
//+------------------------------------------------------------------+
ENUM_OBJECT_TYPE CTableModel::CellGetObjType(const uint row,const uint col)
  {
//--- Get row by index and return type of object assigned to cell at index col
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.CellGetObjType(col) : (ENUM_OBJECT_TYPE)WRONG_VALUE);
  }

//+------------------------------------------------------------------+
//| Returns cell count in the specified row                          |
//+------------------------------------------------------------------+
uint CTableModel::CellsInRow(const uint index)
  {
   CTableRow *row=this.GetRow(index);
   return(row!=NULL ? row.CellsTotal() : 0);
  }

//+------------------------------------------------------------------+
//| Returns total cell count in the table                            |
//+------------------------------------------------------------------+
uint CTableModel::CellsTotal(void)
  {
//--- Count cells by looping through rows (slow with large number of rows)
   uint res=0, total=this.RowsTotal();
   for(int i=0; i<(int)total; i++)
     {
      CTableRow *row=this.GetRow(i);
      res+=(row!=NULL ? row.CellsTotal() : 0);
     }
   return res;
  }

//+------------------------------------------------------------------+
//| Returns specified table cell                                     |
//+------------------------------------------------------------------+
CTableCell *CTableModel::GetCell(const uint row,const uint col)
  {
//--- Get row by row index and return cell by col index
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.GetCell(col) : NULL);
  }

//+------------------------------------------------------------------+
//| Returns cell description                                         |
//+------------------------------------------------------------------+
string CTableModel::CellDescription(const uint row,const uint col)
  {
   CTableCell *cell=this.GetCell(row,col);
   return(cell!=NULL ? cell.Description() : "");
  }

//+------------------------------------------------------------------+
//| Logs cell description                                            |
//+------------------------------------------------------------------+
void CTableModel::CellPrint(const uint row,const uint col)
  {
//--- Get cell and print its description
   CTableCell *cell=this.GetCell(row,col);
   if(cell!=NULL)
      cell.Print();
  }

//+------------------------------------------------------------------+
//| Deletes a row                                                    |
//+------------------------------------------------------------------+
bool CTableModel::RowDelete(const uint index)
  {
//--- Delete row from list by index
   if(!this.m_list_rows.Delete(index))
      return false;
//--- After deletion, all table cell indices must be updated
   this.CellsPositionUpdate();
   return true;
  }

//+------------------------------------------------------------------+
//| Moves row to specified position                                  |
//+------------------------------------------------------------------+
bool CTableModel::RowMoveTo(const uint row_index,const uint index_to)
  {
//--- Get row by index, making it the current node
   CTableRow *row=this.GetRow(row_index);
//--- Move current row to specified position in list
   if(row==NULL || !this.m_list_rows.MoveToIndex(index_to))
      return false;
//--- After moving, all table cell indices must be updated
   this.CellsPositionUpdate();
   return true;
  }

//+------------------------------------------------------------------+
//| Updates row and column positions for all cells                   |
//+------------------------------------------------------------------+
void CTableModel::CellsPositionUpdate(void)
  {
//--- Loop through the rows list
   for(int i=0;i<this.m_list_rows.Total();i++)
     {
      //--- Get each row
      CTableRow *row=this.GetRow(i);
      if(row==NULL)
         continue;
      //--- Set row index found by IndexOf() method
      row.SetIndex(this.m_list_rows.IndexOf(row));
      //--- Update row's cell position indices
      row.CellsPositionUpdate();
     }
  }

//+------------------------------------------------------------------+
//| Clears row (cell data only)                                      |
//+------------------------------------------------------------------+
void CTableRow::RowClearData(const uint index)
  {
//--- Get row and clear its cell data using ClearData() method
   CTableRow *row=this.GetRow(index);
   if(row!=NULL)
      row.ClearData();
  }

//+------------------------------------------------------------------+
//| Clears table (all cell data)                                     |
//+------------------------------------------------------------------+
void CTableModel::ClearData(void)
  {
//--- Loop through all table rows and clear data for each
   for(uint i=0;i<this.RowsTotal();i++)
      this.RowClearData(i);
  }

//+------------------------------------------------------------------+
//| Returns row description                                          |
//+------------------------------------------------------------------+
string CTableModel::RowDescription(const uint index)
  {
//--- Get row and return its description
   CTableRow *row=this.GetRow(index);
   return(row!=NULL ? row.Description() : "");
  }

//+------------------------------------------------------------------+
//| Logs row description                                             |
//+------------------------------------------------------------------+
void CTableModel::RowPrint(const uint index,const bool detail)
  {
   CTableRow *row=this.GetRow(index);
   if(row!=NULL)
      row.Print(detail);
  }
//+------------------------------------------------------------------+
//| Adds a column                                                    |
//+------------------------------------------------------------------+
bool CTableModel::ColumnAddNew(const int index=-1)
  {
//--- Declare variables
   CTableCell *cell=NULL;
   bool res=true;
//--- Loop through the number of rows
   for(uint i=0;i<this.RowsTotal();i++)
     {
      //--- get the next row
      CTableRow *row=this.GetRow(i);
      if(row!=NULL)
        {
         //--- add a cell with type double to the end of the row
         cell=row.CellAddNew(0.0);
         if(cell==NULL)
            res &=false;
         //--- clear the cell
         else
            cell.ClearData();
        }
     }
//--- If a non-negative column index is passed - shift the column to the specified position
   if(res && index>-1)
      res &=this.ColumnMoveTo(this.CellsInRow(0)-1,index);
//--- Return the result
   return res;
  }
//+------------------------------------------------------------------+
//| Deletes a column                                                 |
//+------------------------------------------------------------------+
bool CTableModel::ColumnDelete(const uint index)
  {
   bool res=true;
   for(uint i=0;i<this.RowsTotal();i++)
     {
      CTableRow *row=this.GetRow(i);
      if(row!=NULL)
         res &=row.CellDelete(index);
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Moves a column                                                   |
//+------------------------------------------------------------------+
bool CTableModel::ColumnMoveTo(const uint col_index,const uint index_to)
  {
   bool res=true;
   for(uint i=0;i<this.RowsTotal();i++)
     {
      CTableRow *row=this.GetRow(i);
      if(row!=NULL)
         res &=row.CellMoveTo(col_index,index_to);
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Clears column data                                               |
//+------------------------------------------------------------------+
void CTableModel::ColumnClearData(const uint index)
  {
//--- Loop through all table rows
   for(uint i=0;i<this.RowsTotal();i++)
     {
      //--- get a cell with the column index from each row and clear it
      CTableCell *cell=this.GetCell(i, index);
      if(cell!=NULL)
         cell.ClearData();
     }
  }
//+------------------------------------------------------------------+
//| Sets column data type                                            |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetDatatype(const uint index,const ENUM_DATATYPE type)
  {
//--- Loop through all table rows
   for(uint i=0;i<this.RowsTotal();i++)
     {
      //--- get a cell with the column index from each row and set the data type
      CTableCell *cell=this.GetCell(i, index);
      if(cell!=NULL)
         cell.SetDatatype(type);
     }
  }
//+------------------------------------------------------------------+
//| Sets column data precision                                       |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetDigits(const uint index,const int digits)
  {
//--- Loop through all table rows
   for(uint i=0;i<this.RowsTotal();i++)
     {
      //--- get a cell with the column index from each row and set the data precision
      CTableCell *cell=this.GetCell(i, index);
      if(cell!=NULL)
         cell.SetDigits(digits);
     }
  }
//+------------------------------------------------------------------+
//| Sets column time display flags                                   |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetTimeFlags(const uint index,const uint flags)
  {
//--- Loop through all table rows
   for(uint i=0;i<this.RowsTotal();i++)
     {
      //--- get a cell with the column index from each row and set the time display flags
      CTableCell *cell=this.GetCell(i, index);
      if(cell!=NULL)
         cell.SetDatetimeFlags(flags);
     }
  }
//+------------------------------------------------------------------+
//| Sets column color name display flags                             |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetColorNamesFlag(const uint index,const bool flag)
  {
//--- Loop through all table rows
   for(uint i=0;i<this.RowsTotal();i++)
     {
      //--- get a cell with the column index from each row and set the color name display flag
      CTableCell *cell=this.GetCell(i, index);
      if(cell!=NULL)
         cell.SetColorNameFlag(flag);
     }
  }
//+------------------------------------------------------------------+
//| Sorts the table by the specified column and direction            |
//+------------------------------------------------------------------+
void CTableModel::SortByColumn(const uint column,const bool descending)
  {
   if(this.m_list_rows.Total()==0)
      return;
   int mode=(int)column+(descending ? DESC_IDX_CORRECTION : ASC_IDX_CORRECTION);
   this.m_list_rows.Sort(mode);
   this.CellsPositionUpdate();   
  }
//+------------------------------------------------------------------+
//| Returns object description                                       |
//+------------------------------------------------------------------+
string CTableModel::Description(void)
  {
   return(::StringFormat("%s: Rows %u, Cells in row %u, Cells Total %u",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.RowsTotal(),this.CellsInRow(0),this.CellsTotal()));
  }
//+------------------------------------------------------------------+
//| Logs the object description                                      |
//+------------------------------------------------------------------+
void CTableModel::Print(const bool detail)
  {
//--- Print the header to the log
   ::Print(this.Description()+(detail ? ":" : ""));
//--- If detailed description,
   if(detail)
     {
      //--- Loop through all table rows
      for(uint i=0; i<this.RowsTotal(); i++)
        {
         //--- get the next row and print its detailed description to the log
         CTableRow *row=this.GetRow(i);
         if(row!=NULL)
            row.Print(true,false);
        }
     }
  }
//+------------------------------------------------------------------+
//| Logs the object description in tabular form                      |
//+------------------------------------------------------------------+
void CTableModel::PrintTable(const int cell_width=CELL_WIDTH_IN_CHARS)
  {
//--- Get a pointer to the first row (index 0)
   CTableRow *row=this.GetRow(0);
   if(row==NULL)
      return;
   //--- Create the table header row based on the number of cells in the first row
   uint total=row.CellsTotal();
   string head=" n/n";
   string res=::StringFormat("|%*s |",cell_width,head);
   for(uint i=0;i<total;i++)
     {
      if(this.GetCell(0, i)==NULL)
         continue;
      string cell_idx=" Column "+(string)i;
      res+=::StringFormat("%*s |",cell_width,cell_idx);
     }
   //--- Print the header row to the log
   ::Print(res);
   
   //--- Loop through all table rows and print them in tabular form
   for(uint i=0;i<this.RowsTotal();i++)
     {
      CTableRow *row_obj=this.GetRow(i);
      if(row_obj!=NULL)
         row_obj.Print(true,true,cell_width);
     }
  }
//+------------------------------------------------------------------+
//| Destroys the model                                               |
//+------------------------------------------------------------------+
void CTableModel::Destroy(void)
  {
//--- Clear the row list
   this.m_list_rows.Clear();
  }
//+------------------------------------------------------------------+
//| Saving to a file                                                 |
//+------------------------------------------------------------------+
bool CTableModel::Save(const int file_handle)
  {
//--- Check the handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Save the start of data marker - 0xFFFFFFFFFFFFFFFF
   if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
      return(false);
//--- Save the object type
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return(false);

   //--- Save the row list
   if(!this.m_list_rows.Save(file_handle))
      return(false);
   
//--- Success
   return true;
  }
//+------------------------------------------------------------------+
//| Loading from a file                                              |
//+------------------------------------------------------------------+
bool CTableModel::Load(const int file_handle)
  {
//--- Check the handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Load and check the start of data marker - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);
//--- Load the object type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return(false);

   //--- Load the row list
   if(!this.m_list_rows.Load(file_handle))
      return(false);
   
//--- Success
   return true;
  }
#endif // TABLEMODEL_MQH