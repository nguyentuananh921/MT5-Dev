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
/*
#include "TableDefines.mqh"
#include "TableEnums.mqh"
*/
#include <Vendors/Anhnt/CFramework/Defines/Defines.mqh>  // MARKER_START_DATA, CELL_WIDTH_IN_CHARS
#include <Vendors/Anhnt/CFramework/Defines/Enums.mqh>    // ENUM_OBJECT_TYPE, ENUM_DATATYPE
#include <Vendors/Anhnt/CFramework/Models/ListObj.mqh>
#include "..\ListObj.mqh"
#include "TableCell.mqh"
#include "TableRow.mqh"
#include "MqlParamObj.mqh"

//+------------------------------------------------------------------+
//| Table model class                                                |
//+------------------------------------------------------------------+
class CTableModel : public CObject
  {
protected:
   CTableRow         m_row_tmp;                             // Row object for searching in the list
   CListObj          m_list_rows;                           // List of table rows
//--- Creates a table model from a 2D array
template<typename T>
   void               CreateTableModel(T &array[][]);
   void               CreateTableModel(const uint num_rows,const uint num_columns);
   void               CreateTableModel(const matrix &row_data);
   void               CreateTableModel(CList &list_param);
//--- Returns the correct data type
   ENUM_DATATYPE     GetCorrectDatatype(string type_name)
                       {
                        return
                          (
                           //--- Integer values
                           type_name=="bool" || type_name=="char"    || type_name=="uchar"   ||
                           type_name=="short"|| type_name=="ushort"  || type_name=="int"     ||
                           type_name=="uint" || type_name=="long"    || type_name=="ulong"   ?  TYPE_LONG      :
                           //--- Floating-point values
                           type_name=="float"|| type_name=="double"                           ?  TYPE_DOUBLE    :
                           //--- Date/Time values
                           type_name=="datetime"                                              ?  TYPE_DATETIME  :
                           //--- Color values
                           type_name=="color"                                                 ?  TYPE_COLOR     :
                           /*--- String values */                                               TYPE_STRING    );
                       }
     
//--- Creates and adds a new empty row to the end of the list
   CTableRow         *CreateNewEmptyRow(void);
//--- Adds a row to the end of the list
   bool               AddNewRow(CTableRow *row);
//--- Updates row and column positions for all table cells
   void               CellsPositionUpdate(void);
   
public:
//--- Returns (1) cell, (2) row by index, (3) total rows, (4) cells in row, (5) total cells in table
   CTableCell       *GetCell(const uint row, const uint col);
   CTableRow        *GetRow(const uint index)                  { return this.m_list_rows.GetNodeAtIndex(index);}
   uint              RowsTotal(void)                     const { return this.m_list_rows.Total();              }
   uint              CellsInRow(const uint index);
   uint              CellsTotal(void);

//--- Sets (1) value, (2) digits, (3) time flags, (4) color name flag for the specified cell
template<typename T>
   void              CellSetValue(const uint row, const uint col, const T value);
   void              CellSetDigits(const uint row, const uint col, const int digits);
   void              CellSetTimeFlags(const uint row, const uint col, const uint flags);
   void              CellSetColorNamesFlag(const uint row, const uint col, const bool flag);
//--- (1) Assigns, (2) unassigns an object in the cell
   void              CellAssignObject(const uint row, const uint col,CObject *object);
   void              CellUnassignObject(const uint row, const uint col);
//--- (1) Deletes, (2) moves the cell
   bool              CellDelete(const uint row, const uint col);
   bool              CellMoveTo(const uint row, const uint cell_index, const uint index_to);
//--- Returns (1) assigned object, (2) object type in the cell
   CObject          *CellGetObject(const uint row, const uint col);
   ENUM_TABLE_OBJECT_TYPE  CellGetObjType(const uint row, const uint col);
//--- (1) Returns, (2) prints cell description, (3) returns assigned object
   string            CellDescription(const uint row, const uint col);
   void              CellPrint(const uint row, const uint col);
   
public:
//--- Creates a new row and (1) adds to the end, (2) inserts at position
   CTableRow        *RowAddNew(void);
   CTableRow        *RowInsertNewTo(const uint index_to);
//--- (1) Deletes, (2) moves, (3) clears row data
   bool              RowDelete(const uint index);
   bool              RowMoveTo(const uint row_index, const uint index_to);
   void              RowClearData(const uint index);
//--- (1) Returns, (2) prints row description
   string            RowDescription(const uint index);
   void              RowPrint(const uint index,const bool detail);
   
//--- (1) Adds, (2) deletes, (3) moves a column, (4) clears data, (5) sets type,
//--- (6) digits, (7) time flags, (8) color names flags for the column
   bool              ColumnAddNew(const int index=-1);
   bool              ColumnDelete(const uint index);
   bool              ColumnMoveTo(const uint col_index, const uint index_to);
   void              ColumnClearData(const uint index);
   void              ColumnSetDatatype(const uint index,const ENUM_DATATYPE type);
   void              ColumnSetDigits(const uint index,const int digits);
   
   void              ColumnSetTimeFlags(const uint index, const uint flags);
   void              ColumnSetColorNamesFlag(const uint index, const bool flag);
  
//--- Sorts the table by the specified column and direction
   void              SortByColumn(const uint column, const bool descending);
   
//--- (1) Returns, (2) prints table description
   virtual string    Description(void);
   void              Print(const bool detail);
   void              PrintTable(const int cell_width=CELL_WIDTH_IN_CHARS);
   
//--- (1) Clears data, (2) destroys the model
   void              ClearData(void);
   void              Destroy(void);
   
//--- Virtual methods: (1) compare, (2) save, (3) load, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0)      const { return -1;         }
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_MODEL);  }
   
//--- Constructors/destructor
template<typename T> CTableModel(T &array[][])                                { this.CreateTableModel(array);                 }
                     CTableModel(const uint num_rows,const uint num_columns)  { this.CreateTableModel(num_rows,num_columns);  }
                     CTableModel(const matrix &row_data)                       { this.CreateTableModel(row_data);              }
                     CTableModel(CList &row_data)                              { this.CreateTableModel(row_data);              }
                     CTableModel(void){}
                    ~CTableModel(void){}
  };
#endif // TABLEMODEL_MQH