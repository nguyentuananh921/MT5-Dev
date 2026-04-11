//+------------------------------------------------------------------+
//|                                                 TableModel.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/17653  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table model class                                                |
//+------------------------------------------------------------------+
#ifndef __TABLEMODEL_MQH__
#define __TABLEMODEL_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "TableRow.mqh"
   #include "MqlParamObj.mqh"
   #include "..\Base\BaseObj.mqh"  
 class CTableModel : public CObject
  {
   protected:
      CTableRow         m_row_tmp;                             // String object to search in list
      CListObj          m_list_rows;                           // List of table rows
   // --- Creates a table model from a two-dimensional array
   template<typename T>
      void              CreateTableModel(T &array[][]);
      void              CreateTableModel(const uint num_rows,const uint num_columns);
      void              CreateTableModel(const matrix &row_data);
      void              CreateTableModel(CList &list_param);
   // --- Returns the correct data type
      ENUM_DATATYPE     GetCorrectDatatype(string type_name)
                        {
                           return
                           (
                              // --- Integer value
                              type_name=="bool" || type_name=="char"    || type_name=="uchar"   ||
                              type_name=="short"|| type_name=="ushort"  || type_name=="int"     ||
                              type_name=="uint" || type_name=="long"    || type_name=="ulong"   ?  TYPE_LONG      :
                              // --- Real value
                              type_name=="float"|| type_name=="double"                          ?  TYPE_DOUBLE    :
                              // --- Date/time value
                              type_name=="datetime"                                             ?  TYPE_DATETIME  :
                              // ---Color meaning
                              type_name=="color"                                                ?  TYPE_COLOR     :
                              /* --- String value */                                          TYPE_STRING    );
                        }
      
   // --- Creates and adds a new empty string to the end of the list
      CTableRow        *CreateNewEmptyRow(void);
   // --- Adds a string to the end of the list
      bool              AddNewRow(CTableRow *row);
   // --- Sets row and column positions for all table cells
      void              CellsPositionUpdate(void);
      
   public:
   // --- Returns (1) cell, (2) row by index, number of (3) rows, cells (4) in the specified row, (5) in the table
      CTableCell       *GetCell(const uint row, const uint col);
      CTableRow        *GetRow(const uint index)                  { return this.m_list_rows.GetNodeAtIndex(index);}
      uint              RowsTotal(void)                     const { return this.m_list_rows.Total();              }
      uint              CellsInRow(const uint index);
      uint              CellsTotal(void);

   // --- Sets (1) value, (2) precision, (3) time display flags, (4) color name display flag to specified cell
   template<typename T>
      void              CellSetValue(const uint row, const uint col, const T value);
      void              CellSetDigits(const uint row, const uint col, const int digits);
      void              CellSetTimeFlags(const uint row, const uint col, const uint flags);
      void              CellSetColorNamesFlag(const uint row, const uint col, const bool flag);
   // --- (1) Assigns, (2) cancels an object in a cell
      void              CellAssignObject(const uint row, const uint col,CObject *object);
      void              CellUnassignObject(const uint row, const uint col);
   // --- (1) Deletes (2) moves a cell
      bool              CellDelete(const uint row, const uint col);
      bool              CellMoveTo(const uint row, const uint cell_index, const uint index_to);
   // ---Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
      CObject          *CellGetObject(const uint row, const uint col);
      ENUM_OBJECT_TYPE  CellGetObjType(const uint row, const uint col);
   // --- (1) Returns, (2) logs the description of the cell, (3) the object assigned to the cell
      string            CellDescription(const uint row, const uint col);
      void              CellPrint(const uint row, const uint col);
      
   public:
   // --- Creates a new line and (1) appends it to the end of the list, (2) inserts it at the specified position in the list
      CTableRow        *RowAddNew(void);
      CTableRow        *RowInsertNewTo(const uint index_to);
   // --- (1) Deletes (2) moves a row, (3) clears row data
      bool              RowDelete(const uint index);
      bool              RowMoveTo(const uint row_index, const uint index_to);
      void              RowClearData(const uint index);
   // --- (1) Returns, (2) logs the description of the string
      string            RowDescription(const uint index);
      void              RowPrint(const uint index,const bool detail);
      
   // --- (1) Adds, (2) deletes (3) moves a column, (4) clears data, sets (5) type,
   // --- (6) data accuracy, display flags (7) time, (8) column color names
      bool              ColumnAddNew(const int index=-1);
      bool              ColumnDelete(const uint index);
      bool              ColumnMoveTo(const uint col_index, const uint index_to);
      void              ColumnClearData(const uint index);
      void              ColumnSetDatatype(const uint index,const ENUM_DATATYPE type);
      void              ColumnSetDigits(const uint index,const int digits);
      
      void              ColumnSetTimeFlags(const uint index, const uint flags);
      void              ColumnSetColorNamesFlag(const uint index, const bool flag);
   
   // --- Sorts the table by the specified column and direction
      void              SortByColumn(const uint column, const bool descending);
      
   // --- (1) Returns, (2) logs the table description
      virtual string    Description(void);
      void              Print(const bool detail);
      void              PrintTable(const int cell_width=CELL_WIDTH_IN_CHARS);
      
   // --- (1) Clears the data, (2) destroys the model
      void              ClearData(void);
      void              Destroy(void);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0)      const { return -1;         }
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_MODEL);  }
      
   // --- Constructors/destructor
   template<typename T> CTableModel(T &array[][])                                { this.CreateTableModel(array);                 }
                        CTableModel(const uint num_rows,const uint num_columns)  { this.CreateTableModel(num_rows,num_columns);  }
                        CTableModel(const matrix &row_data)                      { this.CreateTableModel(row_data);              }
                        CTableModel(CList &row_data)                             { this.CreateTableModel(row_data);              }
                        CTableModel(void){}
                     ~CTableModel(void){}
  };
//+------------------------------------------------------------------+
//| Creates a table model from a two-dimensional array               |
//+------------------------------------------------------------------+
template<typename T>
void CTableModel::CreateTableModel(T &array[][])
 {
   // --- Get the number of rows and columns of the table from the array properties
      int rows_total=::ArrayRange(array,0);
      int cols_total=::ArrayRange(array,1);
   // --- In a loop through row indexes
      for(int r=0; r<rows_total; r++)
      {
         // --- create a new empty string and add it to the end of the list of strings
         CTableRow *row=this.CreateNewEmptyRow();
         // --- If a row is created and added to the list,
         if(row!=NULL)
         {
            // --- In a loop by the number of cells in a row
            // --- create all cells, adding each new one to the end of the list of row cells
            for(int c=0; c<cols_total; c++)
               row.CellAddNew(array[r][c]);
         }
      }
 }
//+----------------------------------------------------------------------+
//| Creates a table model from the specified number of rows and columns  |
//+----------------------------------------------------------------------+
void CTableModel::CreateTableModel(const uint num_rows,const uint num_columns)
 {
   // --- In a loop by number of lines
      for(uint r=0; r<num_rows; r++)
      {
         // --- create a new empty string and add it to the end of the list of strings
         CTableRow *row=this.CreateNewEmptyRow();
         // --- If a row is created and added to the list,
         if(row!=NULL)
         {
            // --- In a loop by number of columns
            // --- create all cells, adding each new one to the end of the list of row cells
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
//| Creates a table model from the specified matrix                  |
//+------------------------------------------------------------------+
void CTableModel::CreateTableModel(const matrix &row_data)
 {
   // --- Number of rows and columns
      ulong num_rows=row_data.Rows();
      ulong num_columns=row_data.Cols();
   // --- In a loop by number of lines
      for(uint r=0; r<num_rows; r++)
      {
         // --- create a new empty string and add it to the end of the list of strings
         CTableRow *row=this.CreateNewEmptyRow();
         // --- If a row is created and added to the list,
         if(row!=NULL)
         {
            // --- In a loop by number of columns
            // --- create all cells, adding each new one to the end of the list of row cells
            for(uint c=0; c<num_columns; c++)
               row.CellAddNew(row_data[r][c]);
         }
      }
 }
//+------------------------------------------------------------------+
//| Creates a table model from a list of parameters                  |
//+------------------------------------------------------------------+
void CTableModel::CreateTableModel(CList &list_param)
 {
   // --- If an empty list is transmitted, we report this and leave
      if(list_param.Total()==0)
      {
         ::PrintFormat("%s: Error. Empty list passed",__FUNCTION__);
         return;
      }
   // --- Get a pointer to the first row of the table to determine the number of columns
   // --- If the first line could not be obtained, or there are no cells in it, we report this and leave
      CList *first_row=list_param.GetFirstNode();
      if(first_row==NULL || first_row.Total()==0)
      {
         if(first_row==NULL)
            ::PrintFormat("%s: Error. Failed to get first row of list",__FUNCTION__);
         else
            ::PrintFormat("%s: Error. First row does not contain data",__FUNCTION__);
         return;
      }
   // --- Number of rows and columns
      ulong num_rows=list_param.Total();
      ulong num_columns=first_row.Total();
   // --- In a loop by number of lines
      for(uint r=0; r<num_rows; r++)
      {
         // --- get the next table row from the list_param list
         CList *col_list=list_param.GetNodeAtIndex(r);
         if(col_list==NULL)
            continue;
         // --- create a new empty string and add it to the end of the list of strings
         CTableRow *row=this.CreateNewEmptyRow();
         // --- If a row is created and added to the list,
         if(row!=NULL)
         {
            // --- In a loop by number of columns
            // --- create all cells, adding each new one to the end of the list of row cells
            for(uint c=0; c<num_columns; c++)
            {
               CMqlParamObj *param=col_list.GetNodeAtIndex(c);
               if(param==NULL)
                  continue;

               // --- We declare a pointer to the cell and the type of data that will be contained in it
               CTableCell *cell=NULL;
               ENUM_DATATYPE datatype=param.Datatype();
               // ---Depending on data type
               switch(datatype)
               {
                  // --- real data type
                  case TYPE_FLOAT   :
                  case TYPE_DOUBLE  :  cell=row.CellAddNew((double)param.ValueD());    // Create a new cell with double data and
                                       if(cell!=NULL)
                                          cell.SetDigits((int)param.ValueL());         // record the accuracy of the displayed data
                                       break;
                  // --- datetime data type
                  case TYPE_DATETIME:  cell=row.CellAddNew((datetime)param.ValueL());  // Create a new cell with datetime data and
                                       if(cell!=NULL)
                                          cell.SetDatetimeFlags((int)param.ValueD());  // write date/time display flags
                                       break;
                  // --- data type color
                  case TYPE_COLOR   :  cell=row.CellAddNew((color)param.ValueL());     // Create a new cell with color data and
                                       if(cell!=NULL)
                                          cell.SetColorNameFlag((bool)param.ValueD()); // write down a flag for displaying the names of known colors
                                       break;
                  // --- string data type
                  case TYPE_STRING  :  cell=row.CellAddNew((string)param.ValueS());    // Create a new cell with string data
                                       break; 
                  // --- integer data type
                  default           :  cell=row.CellAddNew((long)param.ValueL());      // Create a new cell with long data
                                       break; 
               }
            }
         }
      }
 }
//+------------------------------------------------------------------+
//|Creates a new empty string and adds it to the end of the list     |
//+------------------------------------------------------------------+
CTableRow *CTableModel::CreateNewEmptyRow(void)
 {
   // --- Create a new string object
      CTableRow *row=new CTableRow(this.m_list_rows.Total());
      if(row==NULL)
      {
         ::PrintFormat("%s: Error. Failed to create new row at position %u",__FUNCTION__, this.m_list_rows.Total());
         return NULL;
      }
   // --- If the string could not be added to the list, delete the created new object and return NULL
      if(!this.AddNewRow(row))
      {
         delete row;
         return NULL;
      }
      
   // --- Success - return a pointer to the created object
      return row;
 }
//+------------------------------------------------------------------+
//| Adds a string to the end of the list                             |
//+------------------------------------------------------------------+
bool CTableModel::AddNewRow(CTableRow *row)
 {
   // --- If an empty object is passed, we report this and return false
      if(row==NULL)
      {
         ::PrintFormat("%s: Error. Empty CTableRow object passed",__FUNCTION__);
         return false;
      }
   // --- Set the line to its index in the list and add it to the end of the list
      row.SetIndex(this.RowsTotal());
      if(this.m_list_rows.Add(row)==WRONG_VALUE)
      {
         ::PrintFormat("%s: Error. Failed to add row (%u) to list",__FUNCTION__,row.Index());
         return false;
      }

   // --- Successfully
      return true;
 }
//+------------------------------------------------------------------+
//| Creates a new line and adds it to the end of the list            |
//+------------------------------------------------------------------+
CTableRow *CTableModel::RowAddNew(void)
 {
   // --- Create a new empty string and add it to the end of the list of strings
      CTableRow *row=this.CreateNewEmptyRow();
      if(row==NULL)
         return NULL;
         
   // --- Create cells based on the number of cells in the first row
      for(uint i=0;i<this.CellsInRow(0);i++)
         row.CellAddNew(0.0);
      row.ClearData();
      
   // --- Success - return a pointer to the created object
      return row;
 }
//+------------------------------------------------------------------+
//| Creates and adds a new row at the specified list position        |
//+------------------------------------------------------------------+
// Sometimes you need to insert a new row not at the end of the list of rows, 
// but between the existing ones. 
// This method first creates a new row at the end of the list, fills it with cells, 
// clears them, and then moves the row to the desired position.
//+------------------------------------------------------------------+
CTableRow *CTableModel::RowInsertNewTo(const uint index_to)
 {
   // --- Create a new empty string and add it to the end of the list of strings
      CTableRow *row=this.CreateNewEmptyRow();
      if(row==NULL)
         return NULL;
      
   // --- Create cells based on the number of cells in the first row
      for(uint i=0;i<this.CellsInRow(0);i++)
         row.CellAddNew(0.0);
      row.ClearData();
      
   // --- Shift the line to the index_to position
      this.RowMoveTo(this.m_list_rows.IndexOf(row),index_to);
      
   // --- Success - return a pointer to the created object
      return row;
 }
//+------------------------------------------------------------------+
//| Sets the value to the specified cell                            |
//+------------------------------------------------------------------+
template<typename T>
void CTableModel::CellSetValue(const uint row,const uint col,const T value)
 {
   // --- Get a cell by row and column indexes
      CTableCell *cell=this.GetCell(row,col);
      if(cell==NULL)
         return;
   // --- We get the correct type of data being set (double, long, datetime, color, string)
      ENUM_DATATYPE type=this.GetCorrectDatatype(typename(T));
   // --- Depending on the data type, call the corresponding data type
   // --- cell method for setting a value, explicitly specifying the required type
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
//| Sets the accuracy of displaying data in the specified cell       |
//+------------------------------------------------------------------+
void CTableModel::CellSetDigits(const uint row,const uint col,const int digits)
 {
   // --- Get the cell by row and column indices and
   // --- call its corresponding method to set the value
      CTableCell *cell=this.GetCell(row,col);
      if(cell!=NULL)
         cell.SetDigits(digits);
 }
//+------------------------------------------------------------------+
//| Sets time display flags to the specified cell                    |
//+------------------------------------------------------------------+
void CTableModel::CellSetTimeFlags(const uint row,const uint col,const uint flags)
 {
   // --- Get the cell by row and column indices and
   // --- call its corresponding method to set the value
      CTableCell *cell=this.GetCell(row,col);
      if(cell!=NULL)
         cell.SetDatetimeFlags(flags);
 }
//+------------------------------------------------------------------+
//| Sets the flag to display color names in the specified cell       |
//+------------------------------------------------------------------+
void CTableModel::CellSetColorNamesFlag(const uint row,const uint col,const bool flag)
 {
   // --- Get the cell by row and column indices and
   // --- call its corresponding method to set the value
      CTableCell *cell=this.GetCell(row,col);
      if(cell!=NULL)
         cell.SetColorNameFlag(flag);
 }
//+------------------------------------------------------------------+
//| Assigns an object to a cell                                      |
//+------------------------------------------------------------------+
void CTableModel::CellAssignObject(const uint row,const uint col,CObject *object)
 {
   // --- Get the cell by row and column indices and
   // --- call its corresponding method to set the value
      CTableCell *cell=this.GetCell(row,col);
      if(cell!=NULL)
         cell.AssignObject(object);
 }
//+------------------------------------------------------------------+
//| Unassigns an object in a cell                                    |
//+------------------------------------------------------------------+
void CTableModel::CellUnassignObject(const uint row,const uint col)
 {
   // --- Get the cell by row and column indices and
   // --- call its corresponding method to set the value
      CTableCell *cell=this.GetCell(row,col);
      if(cell!=NULL)
         cell.UnassignObject();
 }
//+------------------------------------------------------------------+
//| Deletes a cell                                                   |
//+------------------------------------------------------------------+
bool CTableModel::CellDelete(const uint row,const uint col)
 {
   // --- Get a row by index and return the result of deleting a cell from the list
      CTableRow *row_obj=this.GetRow(row);
      return(row_obj!=NULL ? row_obj.CellDelete(col) : false);
 }
//+------------------------------------------------------------------+
//| Moves a cell                                                     |
//+------------------------------------------------------------------+
bool CTableModel::CellMoveTo(const uint row,const uint cell_index,const uint index_to)
 {
   // --- Get the row by index and return the result of moving the cell to a new position
      CTableRow *row_obj=this.GetRow(row);
      return(row_obj!=NULL ? row_obj.CellMoveTo(cell_index,index_to) : false);
 }
//+------------------------------------------------------------------+
//| Returns the object assigned to the cell                          |
//+------------------------------------------------------------------+
CObject *CTableModel::CellGetObject(const uint row,const uint col)
 {
   // --- Get the row by index and return the object assigned to the cell with index col
      CTableRow *row_obj=this.GetRow(row);
      return(row_obj!=NULL ? row_obj.CellGetObject(col) : NULL);
 }
//+------------------------------------------------------------------+
//| Returns the type of the object assigned to the cell              |
//+------------------------------------------------------------------+
ENUM_OBJECT_TYPE CTableModel::CellGetObjType(const uint row,const uint col)
 {
   // --- Get the row by index and return the type of the object assigned to the cell with index col
      CTableRow *row_obj=this.GetRow(row);
      return(row_obj!=NULL ? row_obj.CellGetObjType(col) : (ENUM_OBJECT_TYPE)WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Returns the number of cells in the specified row                 |
//+------------------------------------------------------------------+
uint CTableModel::CellsInRow(const uint index)
 {
   CTableRow *row=this.GetRow(index);
   return(row!=NULL ? row.CellsTotal() : 0);
 }
//+------------------------------------------------------------------+
//| Returns the number of cells in the table                         |
//+------------------------------------------------------------------+
uint CTableModel::CellsTotal(void)
 {
   // --- counting cells in a row-by-row loop (slow if there are a large number of rows)
      uint res=0, total=this.RowsTotal();
      for(int i=0; i<(int)total; i++)
      {
         CTableRow *row=this.GetRow(i);
         res+=(row!=NULL ? row.CellsTotal() : 0);
      }
      return res;
 }
//+------------------------------------------------------------------+
//| Returns the specified table cell                                 |
//+------------------------------------------------------------------+
CTableCell *CTableModel::GetCell(const uint row,const uint col)
 {
   // --- Get a row by index row and return the cell of the row by index col
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
//| Logs a cell description                                          |
//+------------------------------------------------------------------+
void CTableModel::CellPrint(const uint row,const uint col)
 {
   // --- Get a cell by row and column index and return its description
      CTableCell *cell=this.GetCell(row,col);
      if(cell!=NULL)
         cell.Print();
 }
//+------------------------------------------------------------------+
//| Deletes a line                                                   |
//+------------------------------------------------------------------+
bool CTableModel::RowDelete(const uint index)
 {
   // --- Remove a line from the list by index
      if(!this.m_list_rows.Delete(index))
         return false;
   // --- After deleting a row, you need to update all indexes of all table cells
      this.CellsPositionUpdate();
      return true;
 }
//+------------------------------------------------------------------+
//| Moves a line to the specified position                           |
//+------------------------------------------------------------------+
bool CTableModel::RowMoveTo(const uint row_index,const uint index_to)
 {
   // --- Get the row by index, making it current
      CTableRow *row=this.GetRow(row_index);
   // --- Move the current line to the specified position in the list
      if(row==NULL || !this.m_list_rows.MoveToIndex(index_to))
         return false;
   // --- After moving a row, you need to update all indexes of all table cells
      this.CellsPositionUpdate();
      return true;
 }
//+------------------------------------------------------------------+
//| Sets row and column positions for all cells                      |
//+------------------------------------------------------------------+
void CTableModel::CellsPositionUpdate(void)
 {
   // --- Looping through a list of strings
      for(int i=0;i<this.m_list_rows.Total();i++)
      {
         // --- we get the next line
         CTableRow *row=this.GetRow(i);
         if(row==NULL)
            continue;
         // --- set the row index found by the IndexOf() method of the list
         row.SetIndex(this.m_list_rows.IndexOf(row));
         // --- Update the position indexes of the row cells
         row.CellsPositionUpdate();
   }
 }
//+------------------------------------------------------------------+
//| Clears a row (only data in cells)                                |
//+------------------------------------------------------------------+
void CTableModel::RowClearData(const uint index)
 {
   // --- Get a string from the list and clear the data of the string cells using the ClearData() method
      CTableRow *row=this.GetRow(index);
      if(row!=NULL)
         row.ClearData();
 }
//+------------------------------------------------------------------+
//| Clears the table (data of all cells)                             |
//+------------------------------------------------------------------+
void CTableModel::ClearData(void)
 {
   // --- In a loop through all rows of the table, we clear the data of each row
      for(uint i=0;i<this.RowsTotal();i++)
         this.RowClearData(i);
 }
//+------------------------------------------------------------------+
//| Returns the description of a string                              |
//+------------------------------------------------------------------+
string CTableModel::RowDescription(const uint index)
 {
   // --- Get a string by index and return its description
      CTableRow *row=this.GetRow(index);
      return(row!=NULL ? row.Description() : "");
 }
//+------------------------------------------------------------------+
//| Logs a description of a string                                   |
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
   // --- Declare variables
      CTableCell *cell=NULL;
      bool res=true;
   // --- In a loop by number of lines
      for(uint i=0;i<this.RowsTotal();i++)
      {
         // --- we get the next line
         CTableRow *row=this.GetRow(i);
         if(row!=NULL)
         {
            // --- add a cell with type double to the end of the line
            cell=row.CellAddNew(0.0);
            if(cell==NULL)
               res &=false;
            // --- clear the cell
            else
               cell.ClearData();
         }
      }
   // --- If the column index is not negative, shift the column to the specified position
      if(res && index>-1)
         res &=this.ColumnMoveTo(this.CellsInRow(0)-1,index);
   // --- Return the result
      return res;
 }
//+------------------------------------------------------------------+
//| Removes a column                                                 |
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
//| Moves column                                                     |
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
   // --- In a loop through all rows of the table
      for(uint i=0;i<this.RowsTotal();i++)
      {
         // --- get from each row a cell with a column index and clear it
         CTableCell *cell=this.GetCell(i, index);
         if(cell!=NULL)
            cell.ClearData();
      }
 }
//+------------------------------------------------------------------+
//| Sets the column data type                                        |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetDatatype(const uint index,const ENUM_DATATYPE type)
 {
   // --- In a loop through all rows of the table
      for(uint i=0;i<this.RowsTotal();i++)
      {
         // --- get from each row a cell with a column index and set the data type
         CTableCell *cell=this.GetCell(i, index);
         if(cell!=NULL)
            cell.SetDatatype(type);
      }
 }
//+------------------------------------------------------------------+
//| Sets the precision of the column data                            |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetDigits(const uint index,const int digits)
 {
   // --- In a loop through all rows of the table
      for(uint i=0;i<this.RowsTotal();i++)
      {
         // --- get from each row a cell with a column index and set the data precision
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
   // --- In a loop through all rows of the table
      for(uint i=0;i<this.RowsTotal();i++)
      {
         // --- get from each row a cell with a column index and set the time display flags
         CTableCell *cell=this.GetCell(i, index);
         if(cell!=NULL)
            cell.SetDatetimeFlags(flags);
   }
 }
//+------------------------------------------------------------------+
//| Sets the display flagb of column color names                     |
//+------------------------------------------------------------------+
void CTableModel::ColumnSetColorNamesFlag(const uint index,const bool flag)
 {
   // --- In a loop through all rows of the table
      for(uint i=0;i<this.RowsTotal();i++)
      {
         // --- get from each row a cell with a column index and set the flag for displaying color names
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
//| Returns the description of the object                            |
//+------------------------------------------------------------------+
string CTableModel::Description(void)
 {
   // --- Get the formatted object type from the static helper
   string typeStr = CBaseObj::FormatObjectType((ENUM_OBJECT_TYPE)this.Type());

   // --- Return the row description including index and count of cells
   return ::StringFormat("%s: Row %u, Cells in row: %u, Cells Total %u", 
                         typeStr, this.RowsTotal(),this.CellsInRow(0),this.CellsTotal());
                         
   /*return(::StringFormat("%s: Rows %u, Cells in row %u, Cells Total %u",
                        TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.RowsTotal(),this.CellsInRow(0),this.CellsTotal()));*/
 }
//+------------------------------------------------------------------+
//| Logs a description of an object                                  |
//+------------------------------------------------------------------+
void CTableModel::Print(const bool detail)
 {
   // --- Output the header to the log
      ::Print(this.Description()+(detail ? ":" : ""));
   // ---If detailed description,
      if(detail)
      {
         // --- In a loop through all rows of the table
         for(uint i=0; i<this.RowsTotal(); i++)
         {
            // --- we get the next line and display its detailed description in the log
            CTableRow *row=this.GetRow(i);
            if(row!=NULL)
               row.Print(true,false);
         }
      }
 }
//+------------------------------------------------------------------+
//| Logs a description of an object in tabular form                  |
//+------------------------------------------------------------------+
void CTableModel::PrintTable(const int cell_width=CELL_WIDTH_IN_CHARS)
 {
   // --- Get a pointer to the first row (index 0)
      CTableRow *row=this.GetRow(0);
      if(row==NULL)
         return;
      // --- Using the number of cells in the first row of the table, we create a table title line
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
      // --- Output the header line to the log
      ::Print(res);
      
      // --- Let's loop through all the rows of the table and print them in tabular form
      for(uint i=0;i<this.RowsTotal();i++)
      {
         CTableRow *row=this.GetRow(i);
         if(row!=NULL)
            row.Print(true,true,cell_width);
      }
 }
//+------------------------------------------------------------------+
//| Destroys the model                                               |
//+------------------------------------------------------------------+
void CTableModel::Destroy(void)
 {
   // --- Clear the list of strings
      this.m_list_rows.Clear();
 }
//+------------------------------------------------------------------+
//| Saving to file                                                   |
//+------------------------------------------------------------------+
bool CTableModel::Save(const int file_handle)
 {
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return(false);
   // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
         return(false);
   // --- Save the object type
      if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
         return(false);

      // --- Save the list of strings
      if(!this.m_list_rows.Save(file_handle))
         return(false);
      
   // --- Successfully
      return true;
 }
//+------------------------------------------------------------------+
//| Loading from file                                                |
//+------------------------------------------------------------------+
bool CTableModel::Load(const int file_handle)
 {
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return(false);
   // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileReadLong(file_handle)!=MARKER_START_DATA)
         return(false);
   // --- Loading the object type
      if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
         return(false);

      // --- Load a list of strings
      if(!this.m_list_rows.Load(file_handle))
         return(false);
      
   // --- Successfully
      return true;
 }
//+------------------------------------------------------------------+
#endif // __TABLEMODEL_MQH__
