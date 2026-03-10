//+------------------------------------------------------------------+
//|                                                        Table.mqh |
//+------------------------------------------------------------------+
//|                    Tables in the MVC Paradigm in MQL5             |
//|                 Customizable and sortable table columns           |
//|                          https://www.mql5.com/en/articles/19979  |
//+------------------------------------------------------------------+

#ifndef TABLE_MQH
#define TABLE_MQH

//+------------------------------------------------------------------+
//| Table class                                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Object.mqh>          // CObject
#include <Arrays\List.mqh>     // CList

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "TableDefines.mqh"    // MARKER_START_DATA, CELL_WIDTH_IN_CHARS
#include "TableEnums.mqh"      // ENUM_OBJECT_TYPE, ENUM_DATATYPE
#include "TableModel.mqh"      // CTableModel
#include "TableHeader.mqh"     // CTableHeader
#include "TableRow.mqh"        // CTableRow
#include "TableCell.mqh"       // CTableCell
#include "ColumnCaption.mqh"   // CColumnCaption
class CTable : public CObject
{
private:
//--- Fills the column header array in Excel style
bool              FillArrayExcelNames(const uint num_columns);
//--- Returns the column name as in Excel
string            GetExcelColumnName(uint column_number);
//--- Returns header availability
bool              HeaderCheck(void) const { return(this.m_table_header!=NULL && this.m_table_header.ColumnsTotal()>0);  }

protected:
CTableModel      *m_table_model;                                // Pointer to the table model
CTableHeader     *m_table_header;                               // Pointer to the table header
CList             m_list_rows;                                  // List of parameter arrays from structure fields
string            m_array_names[];                              // Array of column headers
int               m_id;                                         // Table identifier
//--- Copies the header names array
bool              ArrayNamesCopy(const string &column_names[],const uint columns_total);

public:
//--- (1) Sets, (2) returns the table model
void              SetTableModel(CTableModel *table_model)      { this.m_table_model=table_model;      }
CTableModel      *GetTableModel(void)                          { return this.m_table_model;           }
//--- (1) Sets, (2) returns the header
void              SetTableHeader(CTableHeader *table_header)   { this.m_table_header=table_header;    }
CTableHeader     *GetTableHeader(void)                         { return this.m_table_header;          }

//--- (1) Sets, (2) returns the table identifier
void              SetID(const int id)                          { this.m_id=id;                        }
int               ID(void)                               const { return this.m_id;                    }

//--- Clears column header data
void              HeaderClearData(void)
{
if(this.m_table_header!=NULL)
this.m_table_header.ClearData();
}
//--- Deletes the table header
void              HeaderDestroy(void)
{
if(this.m_table_header==NULL)
return;
this.m_table_header.Destroy();
this.m_table_header=NULL;
}

//--- (1) Clears all data, (2) destroys table model and header
void              ClearData(void)
{
if(this.m_table_model!=NULL)
this.m_table_model.ClearData();
}
void              Destroy(void)
{
if(this.m_table_model==NULL)
return;
this.m_table_model.Destroy();
this.m_table_model=NULL;
}

//--- Returns (1) header, (2) cell, (3) row by index, number of (4) rows, (5) columns, cells (6) in specified row, (7) in table
CColumnCaption   *GetColumnCaption(const uint index)        { return(this.m_table_header!=NULL  ?  this.m_table_header.GetColumnCaption(index)  :  NULL);   }
CTableCell       *GetCell(const uint row, const uint col)   { return(this.m_table_model!=NULL   ?  this.m_table_model.GetCell(row,col)          :  NULL);   }
CTableRow        *GetRow(const uint index)                  { return(this.m_table_model!=NULL   ?  this.m_table_model.GetRow(index)             :  NULL);   }
uint              RowsTotal(void)                     const { return(this.m_table_model!=NULL   ?  this.m_table_model.RowsTotal()               :  0);      }
uint              ColumnsTotal(void)                  const { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsInRow(0)             :  0);      }
uint              CellsInRow(const uint index)              { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsInRow(index)         :  0);      }
uint              CellsTotal(void)                          { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsTotal()              :  0);      }

//--- Sets (1) value, (2) precision, (3) time display flags, (4) color name display flag in specified cell
template<typename T>
void              CellSetValue(const uint row, const uint col, const T value);
void              CellSetDigits(const uint row, const uint col, const int digits);
void              CellSetTimeFlags(const uint row, const uint col, const uint flags);
void              CellSetColorNamesFlag(const uint row, const uint col, const bool flag);
//--- (1) Assigns, (2) unassigns an object in a cell
void              CellAssignObject(const uint row, const uint col,CObject *object);
void              CellUnassignObject(const uint row, const uint col);
//--- Returns string value of specified cell
virtual string    CellValueAt(const uint row, const uint col);

protected:
//--- (1) Deletes (2) moves a cell
bool              CellDelete(const uint row, const uint col);
bool              CellMoveTo(const uint row, const uint cell_index, const uint index_to);

public:
//--- (1) Returns, (2) logs cell description, (3) assigned object in cell
string            CellDescription(const uint row, const uint col);
void              CellPrint(const uint row, const uint col);
//--- Returns (1) assigned object in cell, (2) type of assigned object in cell
CObject          *CellGetObject(const uint row, const uint col);
ENUM_OBJECT_TYPE  CellGetObjType(const uint row, const uint col);

//--- Creates new row and (1) adds to end of list, (2) inserts at specified list position
CTableRow        *RowAddNew(void);
CTableRow        *RowInsertNewTo(const uint index_to);
//--- (1) Deletes (2) moves row, (3) clears row data
bool              RowDelete(const uint index);
bool              RowMoveTo(const uint row_index, const uint index_to);
void              RowClearData(const uint index);
//--- (1) Returns, (2) logs row description
string            RowDescription(const uint index);
void              RowPrint(const uint index,const bool detail);

//--- (1) Adds new, (2) deletes, (3) moves column, (4) clears column data
bool              ColumnAddNew(const string caption,const int index=-1);
bool              ColumnDelete(const uint index);
bool              ColumnMoveTo(const uint index, const uint index_to);
void              ColumnClearData(const uint index);

//--- Sets (1) value for specified header, (2) data precision,
//--- display flags for (3) time, (4) color names for specified column
void              ColumnCaptionSetValue(const uint index,const string value);
void              ColumnSetDigits(const uint index,const int digits);
void              ColumnSetTimeFlags(const uint index,const uint flags);
void              ColumnSetColorNamesFlag(const uint col, const bool flag);

//--- (1) Sets, (2) returns data type for specified column
void              ColumnSetDatatype(const uint index,const ENUM_DATATYPE type);
ENUM_DATATYPE     ColumnDatatype(const uint index);

//--- (1) Returns, (2) logs object description
virtual string    Description(void);
void              Print(const int column_width=CELL_WIDTH_IN_CHARS);

//--- Sorts the table by specified column and direction
void              SortByColumn(const uint column, const bool descending)
{
if(this.m_table_model!=NULL)
this.m_table_model.SortByColumn(column,descending);
}

//--- Virtual methods (1) comparison, (2) save to file, (3) load from file, (4) object type
virtual int       Compare(const CObject *node,const int mode=0) const;
virtual bool      Save(const int file_handle);
virtual bool      Load(const int file_handle);
virtual int       Type(void)                             const { return(OBJECT_TYPE_TABLE);            }

//--- Constructors/destructor
CTable(void) : m_table_model(NULL), m_table_header(NULL) { this.m_list_rows.Clear();}
template<typename T> CTable(T &row_data[][],const string &column_names[]);
CTable(const uint num_rows, const uint num_columns);
CTable(const matrix &row_data,const string &column_names[]);
~CTable (void);
};

//+-------------------------------------------------------------------+
//| Constructor with table array and header array.                    |
//| Defines column count and names according to column_names          |
//| Row count is defined by row_data array size,                      |
//| which is also used to fill the table                              |
//+-------------------------------------------------------------------+
template<typename T>
CTable::CTable(T &row_data[][],const string &column_names[]) : m_id(-1)
{
this.m_table_model=new CTableModel(row_data);
if(column_names.Size()>0)
this.ArrayNamesCopy(column_names,row_data.Range(1));
else
{
::PrintFormat("%s: An empty array names was passed. The header array will be filled in Excel style (A, B, C)",FUNCTION);
this.FillArrayExcelNames((uint)::ArrayRange(row_data,1));
}
this.m_table_header=new CTableHeader(this.m_array_names);
}

//+------------------------------------------------------------------+
//| Table constructor with definition of column and row count.       |
//| Columns will have Excel-style names "A", "B", "C" etc.           |
//+------------------------------------------------------------------+
CTable::CTable(const uint num_rows,const uint num_columns) : m_table_header(NULL), m_id(-1)
{
this.m_table_model=new CTableModel(num_rows,num_columns);
if(this.FillArrayExcelNames(num_columns))
this.m_table_header=new CTableHeader(this.m_array_names);
}

//+-------------------------------------------------------------------+
//| Table constructor with column initialization by column_names      |
//| Row count is defined by row_data parameter, of matrix type        |
//+-------------------------------------------------------------------+
CTable::CTable(const matrix &row_data,const string &column_names[]) : m_id(-1)
{
this.m_table_model=new CTableModel(row_data);
if(column_names.Size()>0)
this.ArrayNamesCopy(column_names,(uint)row_data.Cols());
else
{
::PrintFormat("%s: An empty array names was passed. The header array will be filled in Excel style (A, B, C)",FUNCTION);
this.FillArrayExcelNames((uint)row_data.Cols());
}
this.m_table_header=new CTableHeader(this.m_array_names);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTable::~CTable(void)
{
if(this.m_table_model!=NULL)
{
this.m_table_model.Destroy();
delete this.m_table_model;
}
if(this.m_table_header!=NULL)
{
this.m_table_header.Destroy();
delete this.m_table_header;
}
}

//+------------------------------------------------------------------+
//| Comparison of two objects                                        |
//+------------------------------------------------------------------+
int CTable::Compare(const CObject *node,const int mode=0) const
{
if(node==NULL)
return -1;
const CTable *obj=node;
return(this.ID()>obj.ID() ? 1 : this.ID()<obj.ID() ? -1 : 0);
}

//+------------------------------------------------------------------+
//| Returns the column name as in Excel                              |
//+------------------------------------------------------------------+
string CTable::GetExcelColumnName(uint column_number)
{
string column_name="";
uint index=column_number;

//--- Check that column number is greater than 0
if(index==0)
return (FUNCTION+": Error. Invalid column number passed");

//--- Convert number to column name
while(!::IsStopped() && index>0)
{
index--;                                           // Decrease number by 1 to make it 0-indexed
uint    remainder =index % 26;                       // Remainder of division by 26
uchar char_code ='A'+(uchar)remainder;             // Calculate character code (letter)
column_name=::CharToString(char_code)+column_name; // Add letter to start of string
index/=26;                                         // Move to next digit
}
return column_name;
}

//+------------------------------------------------------------------+
//| Fills the column header array in Excel style                     |
//+------------------------------------------------------------------+
bool CTable::FillArrayExcelNames(const uint num_columns)
{
::ResetLastError();
if(::ArrayResize(this.m_array_names,num_columns,num_columns)!=num_columns)
{
::PrintFormat("%s: ArrayResize() failed. Error %d",FUNCTION,::GetLastError());
return false;
}
for(int i=0;i<(int)num_columns;i++)
this.m_array_names[i]=this.GetExcelColumnName(i+1);

return true;
}

//+------------------------------------------------------------------+
//| Copies the header names array                                    |
//+------------------------------------------------------------------+
bool CTable::ArrayNamesCopy(const string &column_names[],const uint columns_total)
{
if(columns_total==0)
{
::PrintFormat("%s: Error. The table has no columns",FUNCTION);
return false;
}
if(columns_total>column_names.Size())
{
::PrintFormat("%s: The number of header names is less than the number of columns. The header array will be filled in Excel style (A, B, C)",FUNCTION);
return this.FillArrayExcelNames(columns_total);
}
uint total=::fmin(columns_total,column_names.Size());
return(::ArrayCopy(this.m_array_names,column_names,0,0,total)==total);
}

//+------------------------------------------------------------------+
//| Sets value in specified cell                                     |
//+------------------------------------------------------------------+
template<typename T>
void CTable::CellSetValue(const uint row, const uint col, const T value)
{
if(this.m_table_model!=NULL)
this.m_table_model.CellSetValue(row,col,value);
}

//+------------------------------------------------------------------+
//| Sets precision in specified cell                                 |
//+------------------------------------------------------------------+
void CTable::CellSetDigits(const uint row, const uint col, const int digits)
{
if(this.m_table_model!=NULL)
this.m_table_model.CellSetDigits(row,col,digits);
}

//+------------------------------------------------------------------+
//| Sets time display flags in specified cell                        |
//+------------------------------------------------------------------+
void CTable::CellSetTimeFlags(const uint row, const uint col, const uint flags)
{
if(this.m_table_model!=NULL)
this.m_table_model.CellSetTimeFlags(row,col,flags);
}

//+------------------------------------------------------------------+
//| Sets color name display flag in specified cell                   |
//+------------------------------------------------------------------+
void CTable::CellSetColorNamesFlag(const uint row, const uint col, const bool flag)
{
if(this.m_table_model!=NULL)
this.m_table_model.CellSetColorNamesFlag(row,col,flag);
}

//+------------------------------------------------------------------+
//| Assigns object to cell                                           |
//+------------------------------------------------------------------+
void CTable::CellAssignObject(const uint row, const uint col,CObject *object)
{
if(this.m_table_model!=NULL)
this.m_table_model.CellAssignObject(row,col,object);
}

//+------------------------------------------------------------------+
//| Unassigns object in cell                                         |
//+------------------------------------------------------------------+
void CTable::CellUnassignObject(const uint row, const uint col)
{
if(this.m_table_model!=NULL)
this.m_table_model.CellUnassignObject(row,col);
}

//+------------------------------------------------------------------+
//| Returns string value of specified cell                           |
//+------------------------------------------------------------------+
string CTable::CellValueAt(const uint row,const uint col)
{
CTableCell *cell=this.GetCell(row,col);
return(cell!=NULL ? cell.Value() : "");
}

//+------------------------------------------------------------------+
//| Deletes a cell                                                   |
//+------------------------------------------------------------------+
bool CTable::CellDelete(const uint row, const uint col)
{
return(this.m_table_model!=NULL ? this.m_table_model.CellDelete(row,col) : false);
}

//+------------------------------------------------------------------+
//| Moves a cell                                                     |
//+------------------------------------------------------------------+
bool CTable::CellMoveTo(const uint row, const uint cell_index, const uint index_to)
{
return(this.m_table_model!=NULL ? this.m_table_model.CellMoveTo(row,cell_index,index_to) : false);
}

//+------------------------------------------------------------------+
//| Returns assigned object in cell                                  |
//+------------------------------------------------------------------+
CObject *CTable::CellGetObject(const uint row, const uint col)
{
return(this.m_table_model!=NULL ? this.m_table_model.CellGetObject(row,col) : NULL);
}

//+------------------------------------------------------------------+
//| Returns type of assigned object in cell                          |
//+------------------------------------------------------------------+
ENUM_OBJECT_TYPE CTable::CellGetObjType(const uint row,const uint col)
{
return(this.m_table_model!=NULL ? this.m_table_model.CellGetObjType(row,col) : (ENUM_OBJECT_TYPE)WRONG_VALUE);
}

//+------------------------------------------------------------------+
//| Returns cell description                                         |
//+------------------------------------------------------------------+
string CTable::CellDescription(const uint row, const uint col)
{
return(this.m_table_model!=NULL ? this.m_table_model.CellDescription(row,col) : "");
}

//+------------------------------------------------------------------+
//| Logs cell description                                            |
//+------------------------------------------------------------------+
void CTable::CellPrint(const uint row, const uint col)
{
if(this.m_table_model!=NULL)
this.m_table_model.CellPrint(row,col);
}

//+------------------------------------------------------------------+
//| Creates new row and adds to end of list                          |
//+------------------------------------------------------------------+
CTableRow *CTable::RowAddNew(void)
{
return(this.m_table_model!=NULL ? this.m_table_model.RowAddNew() : NULL);
}

//+------------------------------------------------------------------+
//| Creates new row and inserts at specified list position           |
//+------------------------------------------------------------------+
CTableRow *CTable::RowInsertNewTo(const uint index_to)
{
return(this.m_table_model!=NULL ? this.m_table_model.RowInsertNewTo(index_to) : NULL);
}

//+------------------------------------------------------------------+
//| Deletes a row                                                    |
//+------------------------------------------------------------------+
bool CTable::RowDelete(const uint index)
{
return(this.m_table_model!=NULL ? this.m_table_model.RowDelete(index) : false);
}

//+------------------------------------------------------------------+
//| Moves a row                                                      |
//+------------------------------------------------------------------+
bool CTable::RowMoveTo(const uint row_index, const uint index_to)
{
return(this.m_table_model!=NULL ? this.m_table_model.RowMoveTo(row_index,index_to) : false);
}

//+------------------------------------------------------------------+
//| Clears row data                                                  |
//+------------------------------------------------------------------+
void CTable::RowClearData(const uint index)
{
if(this.m_table_model!=NULL)
this.m_table_model.RowClearData(index);
}

//+------------------------------------------------------------------+
//| Returns row description                                          |
//+------------------------------------------------------------------+
string CTable::RowDescription(const uint index)
{
return(this.m_table_model!=NULL ? this.m_table_model.RowDescription(index) : "");
}

//+------------------------------------------------------------------+
//| Logs row description                                             |
//+------------------------------------------------------------------+
void CTable::RowPrint(const uint index,const bool detail)
{
if(this.m_table_model!=NULL)
this.m_table_model.RowPrint(index,detail);
}

//+------------------------------------------------------------------+
//| Creates new column and adds it to specified table position       |
//+------------------------------------------------------------------+
bool CTable::ColumnAddNew(const string caption,const int index=-1)
{
//--- If there is no table model, or error adding new column to model - return false
if(this.m_table_model==NULL || !this.m_table_model.ColumnAddNew(index))
return false;
//--- If there is no header - return true (column added without header)
if(this.m_table_header==NULL)
return true;

//--- Check creation of new column header and if not created - return false
CColumnCaption *caption_obj=this.m_table_header.CreateNewColumnCaption(caption);
if(caption_obj==NULL)
return false;
//--- If non-negative index is passed - return result of moving header to specified index
//--- Otherwise everything is ready - just return true
return(index>-1 ? this.m_table_header.ColumnCaptionMoveTo(caption_obj.Column(),index) : true);
}

//+------------------------------------------------------------------+
//| Deletes a column                                                 |
//+------------------------------------------------------------------+
bool CTable::ColumnDelete(const uint index)
{
if(!this.HeaderCheck() || !this.m_table_header.ColumnCaptionDelete(index))
return false;
return this.m_table_model.ColumnDelete(index);
}

//+------------------------------------------------------------------+
//| Moves a column                                                   |
//+------------------------------------------------------------------+
bool CTable::ColumnMoveTo(const uint index, const uint index_to)
{
if(!this.HeaderCheck() || !this.m_table_header.ColumnCaptionMoveTo(index,index_to))
return false;
return this.m_table_model.ColumnMoveTo(index,index_to);
}

//+------------------------------------------------------------------+
//| Clears column data                                               |
//+------------------------------------------------------------------+
void CTable::ColumnClearData(const uint index)
{
if(this.m_table_model!=NULL)
this.m_table_model.ColumnClearData(index);
}

//+------------------------------------------------------------------+
//| Sets value for specified header                                  |
//+------------------------------------------------------------------+
void CTable::ColumnCaptionSetValue(const uint index,const string value)
{
CColumnCaption *caption=this.m_table_header.GetColumnCaption(index);
if(caption!=NULL)
caption.SetValue(value);
}

//+------------------------------------------------------------------+
//| Sets data type for specified column                              |
//+------------------------------------------------------------------+
void CTable::ColumnSetDatatype(const uint index,const ENUM_DATATYPE type)
{
//--- If table model exists - set data type for column
if(this.m_table_model!=NULL)
this.m_table_model.ColumnSetDatatype(index,type);
//--- If header exists - set data type for header
if(this.m_table_header!=NULL)
this.m_table_header.ColumnCaptionSetDatatype(index,type);
}

//+------------------------------------------------------------------+
//| Sets data precision for specified column                         |
//+------------------------------------------------------------------+
void CTable::ColumnSetDigits(const uint index,const int digits)
{
if(this.m_table_model!=NULL)
this.m_table_model.ColumnSetDigits(index,digits);
}

//+------------------------------------------------------------------+
//| Sets time display flags for specified column                     |
//+------------------------------------------------------------------+
void CTable::ColumnSetTimeFlags(const uint index,const uint flags)
{
if(this.m_table_model!=NULL)
this.m_table_model.ColumnSetTimeFlags(index,flags);
}

//+------------------------------------------------------------------+
//| Sets color name display flags for specified column               |
//+------------------------------------------------------------------+
void CTable::ColumnSetColorNamesFlag(const uint index,const bool flag)
{
if(this.m_table_model!=NULL)
this.m_table_model.ColumnSetColorNamesFlag(index,flag);
}

//+------------------------------------------------------------------+
//| Returns data type for specified column                           |
//+------------------------------------------------------------------+
ENUM_DATATYPE CTable::ColumnDatatype(const uint index)
{
return(this.m_table_header!=NULL ? this.m_table_header.ColumnCaptionDatatype(index) : (ENUM_DATATYPE)WRONG_VALUE);
}

//+------------------------------------------------------------------+
//| Returns object description                                       |
//+------------------------------------------------------------------+
string CTable::Description(void)
{
return(::StringFormat("%s: Rows total: %u, Columns total: %u",
TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.RowsTotal(),this.ColumnsTotal()));
}

//+------------------------------------------------------------------+
//| Logs object description                                          |
//+------------------------------------------------------------------+
void CTable::Print(const int column_width=CELL_WIDTH_IN_CHARS)
{
if(this.HeaderCheck())
{
//--- Print header as row description
::Print(this.Description()+":");

  //--- Number of headers
  int total=(int)this.ColumnsTotal();
  
  string res="";
  //--- create string from values of all table column headers
  res="|";
  for(int i=0;i<total;i++)
    {
     CColumnCaption *caption=this.GetColumnCaption(i);
     if(caption==NULL)
        continue;
     res+=::StringFormat("%*s |",column_width,caption.Value());
    }
  //--- Supplement string on the left with header
  string hd="|";
  hd+=::StringFormat("%*s ",column_width,"n/n");
  res=hd+res;
  //--- Print header row to log
  ::Print(res);
 }
//--- Loop through all table rows and print them in tabular form
for(uint i=0;i<this.RowsTotal();i++)
{
CTableRow *row=this.GetRow(i);
if(row!=NULL)
{
//--- create table row from values of all cells
string head=" "+(string)row.Index();
string res=::StringFormat("|%-*s |",column_width,head);
for(int i_cell=0;i_cell<(int)row.CellsTotal();i_cell++)
{
CTableCell *cell=row.GetCell(i_cell);
if(cell==NULL)
continue;
res+=::StringFormat("%*s |",column_width,cell.Value());
}
//--- Print row to log
::Print(res);
}
}
}

//+------------------------------------------------------------------+
//| Saving to a file                                                 |
//+------------------------------------------------------------------+
bool CTable::Save(const int file_handle)
{
//--- Check handle
if(file_handle==INVALID_HANDLE)
return(false);
//--- Save start of data marker - 0xFFFFFFFFFFFFFFFF
if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
return(false);
//--- Save object type
if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
return(false);

//--- Save identifier
if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
return(false);
//--- Check table model
if(this.m_table_model==NULL)
return false;
//--- Save table model
if(!this.m_table_model.Save(file_handle))
return(false);

//--- Check table header
if(this.m_table_header==NULL)
return false;
//--- Save table header
if(!this.m_table_header.Save(file_handle))
return(false);

//--- Success
return true;
}

//+------------------------------------------------------------------+
//| Loading from a file                                              |
//+------------------------------------------------------------------+
bool CTable::Load(const int file_handle)
{
//--- Check handle
if(file_handle==INVALID_HANDLE)
return(false);
//--- Load and check start of data marker - 0xFFFFFFFFFFFFFFFF
if(::FileReadLong(file_handle)!=MARKER_START_DATA)
return(false);
//--- Load object type
if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
return(false);

//--- Load identifier
this.m_id=::FileReadInteger(file_handle,INT_VALUE);
//--- Check table model
if(this.m_table_model==NULL && (this.m_table_model=new CTableModel())==NULL)
return(false);

return true;
}


#endif // TABLE_MQH