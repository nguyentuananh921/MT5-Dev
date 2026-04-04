//+------------------------------------------------------------------+
//|                                                       Tables.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Included Libraries                                               |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>
// #include "..\Defines\TableDefines.mqh"
// #include "..\Defines\TableEnums.mqh"
#include "../Services/DELib.mqh"
#include "../Tables/TableCell.mqh"


// --- Forward declaration of classes
class CTableCell;                   // Table cell class
class CTableRow;                    // Table row class
class CTableModel;                  // Table model class
class CColumnCaption;               // Table Column Header Class
class CTableHeader;                 // Table header class
class CTable;                       // Table class
class CTableByParam;                // Table class based on an array of parameters

#ifndef MOVE_TO_TABLEDEFINES_MQH
#define MOVE_TO_TABLEDEFINES_MQH
   // //+------------------------------------------------------------------+
   // // | Macros |
   // //+------------------------------------------------------------------+
   // #define  __TABLES__                 // ID of this file
   // #define  MARKER_START_DATA    -1    // Marker for the start of data in the file
   // #define  MAX_STRING_LENGTH    128   // Maximum length of a string in a cell
   // #define  CELL_WIDTH_IN_CHARS  19    // Table cell width in characters
   // #define  ASC_IDX_CORRECTION   10000 // Column index offset for ascending sort
   // #define  DESC_IDX_CORRECTION  20000 // Column index offset for descending sort
#endif // MOVE_TO_TABLEDEFINES_MQH

#ifndef MOVE_TO_TABLEENUMS_MQH
#define MOVE_TO_TABLEENUMS_MQH
   // //+------------------------------------------------------------------+
   // //| Table Enums                                                      |
   // //+------------------------------------------------------------------+
   // enum ENUM_OBJECT_TYPE               // Enumerating Object Types
   // {
   //    OBJECT_TYPE_TABLE_CELL=10000,    // Table cell
   //    OBJECT_TYPE_TABLE_ROW,           // Table row
   //    OBJECT_TYPE_TABLE_MODEL,         // Table model
   //    OBJECT_TYPE_COLUMN_CAPTION,      // Table Column Header
   //    OBJECT_TYPE_TABLE_HEADER,        // Table title
   //    OBJECT_TYPE_TABLE,               // Table
   //    OBJECT_TYPE_TABLE_BY_PARAM,      // Table based on parameter array data
   // };
   
   // enum ENUM_CELL_COMPARE_MODE         // Table cell comparison modes
   // {
   //    CELL_COMPARE_MODE_COL,           // Comparison by column number
   //    CELL_COMPARE_MODE_ROW,           // Comparison by line number
   //    CELL_COMPARE_MODE_ROW_COL,       // Comparison by row and column
   // };
#endif // MOVE_TO_TABLEENUMS_MQH

#ifndef MOVE_TO_DELIB_MQH
#define MOVE_TO_DELIB_MQH
   // //+------------------------------------------------------------------+ 
   // // | Functions |
   // //+------------------------------------------------------------------+
   // //+------------------------------------------------------------------+
   // // |  Returns the object type as a string |
   // //+------------------------------------------------------------------+
   // string TypeDescription(const ENUM_OBJECT_TYPE type)
   // {
   //    string array[];
   //    int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);
   //    string result="";
   //    for(int i=2;i<total;i++)
   //    {
   //       array[i]+=" ";
   //       array[i].Lower();
   //       array[i].SetChar(0,ushort(array[i].GetChar(0)-0x20));
   //       result+=array[i];
   //    }
   //    result.TrimLeft();
   //    result.TrimRight();
   //    return result;
   // }
#endif // MOVE_TO_DELIB_MQH 
//+------------------------------------------------------------------+
// | Classes |
//+------------------------------------------------------------------+
#ifndef MOVE_TO_LISTOBJ_MQH
#define MOVE_TO_LISTOBJ_MQH
   // //+------------------------------------------------------------------+
   // // | Linked List Object Class |
   // //+------------------------------------------------------------------+
   // class CListObj : public CList
   // {
   // protected:
   //    ENUM_OBJECT_TYPE  m_element_type;   // The type of the object being created in CreateElement()
   // public:
   // // --- Virtual method (1) loading a list from a file, (2) creating a list element, (3) comparing
   //    virtual bool      Load(const int file_handle);
   //    virtual CObject  *CreateElement(void);
   // };
   // //+------------------------------------------------------------------+
   // // | Loading a list from a file |
   // //+------------------------------------------------------------------+
   // bool CListObj::Load(const int file_handle)
   // {
   //    // --- Variables
   //       CObject *node;
   //       bool     result=true;
   //    // --- Checking the handle
   //       if(file_handle==INVALID_HANDLE)
   //          return(false);
   //    // --- Loading and checking the list start marker - 0xFFFFFFFFFFFFFFFF
   //       if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //          return(false);
   //    // --- Loading and checking list type
   //       if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //          return(false);
   //    // --- Read list size (number of objects)
   //       uint num=::FileReadInteger(file_handle,INT_VALUE);
         
   //    // --- We sequentially re-create the list elements by calling the Load() method of node objects
   //       this.Clear();
   //       for(uint i=0; i<num; i++)
   //       {
   //          // --- Read and check the object data start marker - 0xFFFFFFFFFFFFFFFF
   //          if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //             return false;
   //          // --- Read the object type
   //          this.m_element_type=(ENUM_OBJECT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
   //          node=this.CreateElement();
   //          if(node==NULL)
   //             return false;
   //          this.Add(node);
   //          // --- Now the file pointer is offset relative to the beginning of the object marker by 12 bytes (8 - marker, 4 - type)
   //          // --- Let's place a pointer to the beginning of the object's data and load the object's properties from the file using the Load() method of the node element.
   //          if(!::FileSeek(file_handle,-12,SEEK_CUR))
   //             return false;
   //          result &=node.Load(file_handle);
   //       }
   //    // --- Result
   //       return result;
   // }
#endif // MOVE_TO_LISTOBJ_MQH

#ifndef MOVE_TO_DELIB_MQH
#define MOVE_TO_DELIB_MQH
   // //+------------------------------------------------------------------+
   // // | List item creation method |
   // //+------------------------------------------------------------------+
   // CObject *CListObj::CreateElement(void)
   // {
   // // --- Depending on the object type in m_element_type, create a new object
   //    switch(this.m_element_type)
   //    {
   //       case OBJECT_TYPE_TABLE_CELL      :  return new CTableCell();
   //       case OBJECT_TYPE_TABLE_ROW       :  return new CTableRow();
   //       case OBJECT_TYPE_TABLE_MODEL     :  return new CTableModel();
   //       case OBJECT_TYPE_COLUMN_CAPTION  :  return new CColumnCaption();
   //       case OBJECT_TYPE_TABLE_HEADER    :  return new CTableHeader();
   //       case OBJECT_TYPE_TABLE           :  return new CTable();
   //       case OBJECT_TYPE_TABLE_BY_PARAM  :  return new CTableByParam();
   //       default                          :  return NULL;
   //    }
   // }
#endif // MOVE_TO_DELIB_MQH

#ifndef MOVE_TO_TABLECELL_MQH
#define MOVE_TO_TABLECELL_MQH
   //+------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   // | Table cell class |
   //+------------------------------------------------------------------+
   // class CTableCell : public CObject
   // {
   // protected:
   // // --- Union for storing cell values ​​(double, long, string)
   //    union DataType
   //    {
   //       protected:
   //       double         double_value;
   //       long           long_value;
   //       ushort         ushort_value[MAX_STRING_LENGTH];

   //       public:
   //       // --- Setting values
   //       void           SetValueD(const double value) { this.double_value=value;                   }
   //       void           SetValueL(const long value)   { this.long_value=value;                     }
   //       void           SetValueS(const string value) { ::StringToShortArray(value,ushort_value);  }
         
   //       // --- Return values
   //       double         ValueD(void) const { return this.double_value; }
   //       long           ValueL(void) const { return this.long_value; }
   //       string         ValueS(void) const
   //                      {
   //                         string res=::ShortArrayToString(this.ushort_value);
   //                         res.TrimLeft();
   //                         res.TrimRight();
   //                         return res;
   //                      }
   //    };
   // // --- Variables
   //    DataType          m_datatype_value;                      // Meaning
   //    ENUM_DATATYPE     m_datatype;                            // Data type
   //    CObject          *m_object;                              // Object in cell
   //    ENUM_OBJECT_TYPE  m_object_type;                         // Type of object in cell
   //    int               m_row;                                 // Line number
   //    int               m_col;                                 // Column number
   //    int               m_digits;                              // Data accuracy
   //    uint              m_time_flags;                          // Date/Time Display Flags
   //    bool              m_color_flag;                          // Color name display flag
   //    bool              m_editable;                            // Editable cell flag
      
   // // --- Sets "empty value"
   //    void              SetEmptyValue(void)
   //                      {
   //                         switch(this.m_datatype)
   //                         {
   //                            case TYPE_LONG    :  
   //                            case TYPE_DATETIME:  
   //                            case TYPE_COLOR   :  this.SetValue(LONG_MAX);   break;
   //                            case TYPE_DOUBLE  :  this.SetValue(DBL_MAX);    break;
   //                            default           :  this.SetValue("");         break;
   //                         }
   //                      }
   // public:
   // // --- Returning coordinates and cell properties
   //    uint              Row(void)                           const { return this.m_row;                      }
   //    uint              Col(void)                           const { return this.m_col;                      }
   //    ENUM_DATATYPE     Datatype(void)                      const { return this.m_datatype;                 }
   //    int               Digits(void)                        const { return this.m_digits;                   }
   //    uint              DatetimeFlags(void)                 const { return this.m_time_flags;               }
   //    bool              ColorNameFlag(void)                 const { return this.m_color_flag;               }
   //    bool              IsEditable(void)                    const { return this.m_editable;                 }
   // // --- Returns (1) double, (2) long, (3) string value
   //    double            ValueD(void)                        const { return this.m_datatype_value.ValueD();  }
   //    long              ValueL(void)                        const { return this.m_datatype_value.ValueL();  }
   //    string            ValueS(void)                        const { return this.m_datatype_value.ValueS();  }
   // // --- Returns the value as a formatted string
   //    string            Value(void) const
   //                      {
   //                         switch(this.m_datatype)
   //                         {
   //                            case TYPE_DOUBLE  :  return(this.ValueD()!=DBL_MAX  ? ::DoubleToString(this.ValueD(),this.Digits())            : "");
   //                            case TYPE_LONG    :  return(this.ValueL()!=LONG_MAX ? ::IntegerToString(this.ValueL())                         : "");
   //                            case TYPE_DATETIME:  return(this.ValueL()!=LONG_MAX ? ::TimeToString(this.ValueL(),this.m_time_flags)          : "");
   //                            case TYPE_COLOR   :  return(this.ValueL()!=LONG_MAX ? ::ColorToString((color)this.ValueL(),this.m_color_flag)  : "");
   //                            default           :  return this.ValueS();
   //                         }
   //                      }
   // // --- Returns a description of the type of the stored value
   //    string            DatatypeDescription(void) const
   //                      {
   //                         string type=::StringSubstr(::EnumToString(this.m_datatype),5);
   //                         type.Lower();
   //                         return type;
   //                      }
   // // --- Clears data
   //    void              ClearData(void)                           { this.SetEmptyValue();                   }
   // // --- Setting variable values
   //    void              SetRow(const uint row)                    { this.m_row=(int)row;                    }
   //    void              SetCol(const uint col)                    { this.m_col=(int)col;                    }
   //    void              SetDatatype(const ENUM_DATATYPE datatype) { this.m_datatype=datatype;               }
   //    void              SetDigits(const int digits)               { this.m_digits=digits;                   }
   //    void              SetDatetimeFlags(const uint flags)        { this.m_time_flags=flags;                }
   //    void              SetColorNameFlag(const bool flag)         { this.m_color_flag=flag;                 }
   //    void              SetEditable(const bool flag)              { this.m_editable=flag;                   }
   // // --- Sets row and column
   //    void              SetPositionInTable(const uint row,const uint col)
   //                      {
   //                         this.SetRow(row);
   //                         this.SetCol(col);
   //                      }
   // // --- Assigns an object to a cell
   //    void              AssignObject(CObject *object)
   //                      {
   //                         if(object==NULL)
   //                         {
   //                            ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //                            return;
   //                         }
   //                         this.m_object=object;
   //                         this.m_object_type=(ENUM_OBJECT_TYPE)object.Type();
   //                      }
   // // --- Unassigns an object
   //    void              UnassignObject(void)
   //                      {
   //                         this.m_object=NULL;
   //                         this.m_object_type=-1;
   //                      }
                        
   // // --- Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
   //    CObject          *AssignedObject(void)                      { return this.m_object;                   }
   //    ENUM_OBJECT_TYPE  AssignedObjType(void)               const { return this.m_object_type;              }

   // // --- Sets a double value
   //    void              SetValue(const double value)
   //                      {
   //                         this.m_datatype=TYPE_DOUBLE;
   //                         if(this.m_editable)
   //                            this.m_datatype_value.SetValueD(value);
   //                      }
   // // --- Sets a long value
   //    void              SetValue(const long value)
   //                      {
   //                         this.m_datatype=TYPE_LONG;
   //                         if(this.m_editable)
   //                            this.m_datatype_value.SetValueL(value);
   //                      }
   // // --- Sets the datetime value
   //    void              SetValue(const datetime value)
   //                      {
   //                         this.m_datatype=TYPE_DATETIME;
   //                         if(this.m_editable)
   //                            this.m_datatype_value.SetValueL(value);
   //                      }
   // // --- Sets the color value
   //    void              SetValue(const color value)
   //                      {
   //                         this.m_datatype=TYPE_COLOR;
   //                         if(this.m_editable)
   //                            this.m_datatype_value.SetValueL(value);
   //                      }
   // // --- Sets the string value
   //    void              SetValue(const string value)
   //                      {
   //                         this.m_datatype=TYPE_STRING;
   //                         if(this.m_editable)
   //                            this.m_datatype_value.SetValueS(value);
   //                      }
      
   // // --- (1) Returns, (2) logs a description of the object
   //    virtual string    Description(void);
   //    void              Print(void);

   // // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //    virtual int       Compare(const CObject *node,const int mode=0) const;
   //    virtual bool      Save(const int file_handle);
   //    virtual bool      Load(const int file_handle);
   //    virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_CELL);}
      
      
   // // --- Constructors/destructor
   //                      CTableCell(void) : m_row(0), m_col(0), m_datatype(-1), m_digits(0), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
   //                      {
   //                         this.m_datatype_value.SetValueD(0);
   //                      }
   //                      // --- Accepts a double value
   //                      CTableCell(const uint row,const uint col,const double value,const int digits) :
   //                         m_row((int)row), m_col((int)col), m_datatype(TYPE_DOUBLE), m_digits(digits), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
   //                      {
   //                         this.m_datatype_value.SetValueD(value);
   //                      }
   //                      // --- Accepts a long value
   //                      CTableCell(const uint row,const uint col,const long value) :
   //                         m_row((int)row), m_col((int)col), m_datatype(TYPE_LONG), m_digits(0), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
   //                      {
   //                         this.m_datatype_value.SetValueL(value);
   //                      }
   //                      // --- Accepts a datetime value
   //                      CTableCell(const uint row,const uint col,const datetime value,const uint time_flags) :
   //                         m_row((int)row), m_col((int)col), m_datatype(TYPE_DATETIME), m_digits(0), m_time_flags(time_flags), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
   //                      {
   //                         this.m_datatype_value.SetValueL(value);
   //                      }
   //                      // --- Accepts a color value
   //                      CTableCell(const uint row,const uint col,const color value,const bool color_names_flag) :
   //                         m_row((int)row), m_col((int)col), m_datatype(TYPE_COLOR), m_digits(0), m_time_flags(0), m_color_flag(color_names_flag), m_editable(true), m_object(NULL), m_object_type(-1)
   //                      {
   //                         this.m_datatype_value.SetValueL(value);
   //                      }
   //                      // --- Accepts a string value
   //                      CTableCell(const uint row,const uint col,const string value) :
   //                         m_row((int)row), m_col((int)col), m_datatype(TYPE_STRING), m_digits(0), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
   //                      {
   //                         this.m_datatype_value.SetValueS(value);
   //                      }
   //                   ~CTableCell(void) {}
   // };
   // //+------------------------------------------------------------------+
   // // | Comparison of two objects |
   // //+------------------------------------------------------------------+
   // int CTableCell::Compare(const CObject *node,const int mode=0) const
   // {
   //    if(node==NULL)
   //       return -1;
   //    const CTableCell *obj=node;
   //    switch(mode)
   //    {
   //       case CELL_COMPARE_MODE_COL :  return(this.Col()>obj.Col() ? 1 : this.Col()<obj.Col() ? -1 : 0);
   //       case CELL_COMPARE_MODE_ROW :  return(this.Row()>obj.Row() ? 1 : this.Row()<obj.Row() ? -1 : 0);
   //       //---CELL_COMPARE_MODE_ROW_COL
   //       default                    :  return
   //                                     (
   //                                        this.Row()>obj.Row() ? 1 : this.Row()<obj.Row() ? -1 :
   //                                        this.Col()>obj.Col() ? 1 : this.Col()<obj.Col() ? -1 : 0
   //                                     );
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Saving to file |
   // //+------------------------------------------------------------------+
   // bool CTableCell::Save(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
   //       return(false);
   // // --- Save the object type
   //    if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
   //       return(false);

   //    // --- Save the data type
   //    if(::FileWriteInteger(file_handle,this.m_datatype,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save the object type in a cell
   //    if(::FileWriteInteger(file_handle,this.m_object_type,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save the line number
   //    if(::FileWriteInteger(file_handle,this.m_row,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save the column number
   //    if(::FileWriteInteger(file_handle,this.m_col,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Maintaining accurate data presentation
   //    if(::FileWriteInteger(file_handle,this.m_digits,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save date/time display flags
   //    if(::FileWriteInteger(file_handle,this.m_time_flags,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save the color name display flag
   //    if(::FileWriteInteger(file_handle,this.m_color_flag,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save the flag of the edited cell
   //    if(::FileWriteInteger(file_handle,this.m_editable,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save the value
   //    if(::FileWriteStruct(file_handle,this.m_datatype_value)!=sizeof(this.m_datatype_value))
   //       return(false);
      
   // // --- Everything is successful
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Loading from file |
   // //+------------------------------------------------------------------+
   // bool CTableCell::Load(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //       return(false);
   // // --- Loading the object type
   //    if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //       return(false);

   //    // --- Loading the data type
   //    this.m_datatype=(ENUM_DATATYPE)::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Load the type of object in the cell
   //    this.m_object_type=(ENUM_OBJECT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Load the line number
   //    this.m_row=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Loading the column number
   //    this.m_col=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Loading the accuracy of data presentation
   //    this.m_digits=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Loading date/time display flags
   //    this.m_time_flags=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Load the color name display flag
   //    this.m_color_flag=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Load the flag of the edited cell
   //    this.m_editable=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Loading value
   //    if(::FileReadStruct(file_handle,this.m_datatype_value)!=sizeof(this.m_datatype_value))
   //       return(false);
      
   // // --- Everything is successful
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of the object |
   // //+------------------------------------------------------------------+
   // string CTableCell::Description(void)
   // {
   //    return(::StringFormat("%s: Row %u, Col %u, %s <%s>Value: %s",
   //                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Row(),this.Col(),
   //                         (this.m_editable ? "Editable" : "Uneditable"),this.DatatypeDescription(),this.Value()));
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of an object |
   // //+------------------------------------------------------------------+
   // void CTableCell::Print(void)
   // {
   //    ::Print(this.Description());
   // }
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_TABLECELL_MQH

#ifndef MOVE_TO_TABLEROW_MQH
#define MOVE_TO_TABLEROW_MQH
   ////+------------------------------------------------------------------+
   // // | Table row class |
   // //+------------------------------------------------------------------+
   // class CTableRow : public CObject
   // {
   // protected:
   //    CTableCell        m_cell_tmp;                            // Cell object to search in the list
   //    CListObj          m_list_cells;                          // List of cells
   //    uint              m_index;                               // Row index
      
   // // --- Adds the specified cell to the end of the list
   //    bool              AddNewCell(CTableCell *cell);
      
   // public:
   // // --- (1) Sets, (2) returns the row index
   //    void              SetIndex(const uint index)                { this.m_index=index;  }
   //    uint              Index(void)                         const { return this.m_index; }
   // // --- Sets row and column positions for all cells
   //    void              CellsPositionUpdate(void);
      
   // // --- Creates a new cell and adds it to the end of the list
   //    CTableCell       *CellAddNew(const double value);
   //    CTableCell       *CellAddNew(const long value);
   //    CTableCell       *CellAddNew(const datetime value);
   //    CTableCell       *CellAddNew(const color value);
   //    CTableCell       *CellAddNew(const string value);
      
   // // --- Returns (1) cell by index, (2) number of cells
   //    CTableCell       *GetCell(const uint index)                 { return this.m_list_cells.GetNodeAtIndex(index);  }
   //    uint              CellsTotal(void)                    const { return this.m_list_cells.Total();                }
      
   // // --- Sets the value to the specified cell
   //    void              CellSetValue(const uint index,const double value);
   //    void              CellSetValue(const uint index,const long value);
   //    void              CellSetValue(const uint index,const datetime value);
   //    void              CellSetValue(const uint index,const color value);
   //    void              CellSetValue(const uint index,const string value);
   // // --- (1) assigns to a cell, (2) removes an assigned object from a cell
   //    void              CellAssignObject(const uint index,CObject *object);
   //    void              CellUnassignObject(const uint index);
   
   // // --- Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
   //    CObject          *CellGetObject(const uint index);
   //    ENUM_OBJECT_TYPE  CellGetObjType(const uint index);
      
   // // --- (1) Deletes (2) moves a cell
   //    bool              CellDelete(const uint index);
   //    bool              CellMoveTo(const uint cell_index, const uint index_to);
      
   // // --- Resets row cell data to zero
   //    void              ClearData(void);

   // // --- (1) Returns, (2) logs a description of the object
   //    virtual string    Description(void);
   //    void              Print(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);

   // // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //    virtual int       Compare(const CObject *node,const int mode=0) const;
   //    virtual bool      Save(const int file_handle);
   //    virtual bool      Load(const int file_handle);
   //    virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_ROW); }
      
   // // --- Constructors/destructor
   //                      CTableRow(void) : m_index(0) {}
   //                      CTableRow(const uint index) : m_index(index) {}
   //                   ~CTableRow(void){}
   // };
   // //+------------------------------------------------------------------+
   // // | Comparison of two objects |
   // //+------------------------------------------------------------------+
   // int CTableRow::Compare(const CObject *node,const int mode=0) const
   // {
   // /* Sort(0) - by row index
      
   //    Sort(ASC_IDX_CORRECTION) - ascending by column 0
   //    Sort(1+ASC_IDX_CORRECTION) - ascending by column 1
   //    Sort(2+ASC_IDX_CORRECTION) - ascending by column 2
   //    etc.
   //    Sort(DESC_IDX_CORRECTION) - descending by column 0
   //    Sort(1+DESC_IDX_CORRECTION) - descending by column 1
   //    Sort(2+DESC_IDX_CORRECTION) - descending by column 2
   //    etc. */  
   //    if(node==NULL)
   //       return -1;
      
   //    if(mode==0)
   //    {
   //       const CTableRow *obj=node;
   //       return(this.Index()>obj.Index() ? 1 : this.Index()<obj.Index() ? -1 : 0);
   //    }
      
   // //---
   //    bool asc=(mode>=ASC_IDX_CORRECTION && mode<DESC_IDX_CORRECTION);
   //    int  col= mode%(asc ? ASC_IDX_CORRECTION : DESC_IDX_CORRECTION);
         
   // // --- Remove node constancy
   //    CTableRow *nonconst_this=(CTableRow*)&this;
   //    CTableRow *nonconst_node=(CTableRow*)node;

   // // --- Get the current and compared cells by index mode
   //    CTableCell *cell_current =nonconst_this.GetCell(col);
   //    CTableCell *cell_compared=nonconst_node.GetCell(col);
   //    if(cell_current==NULL || cell_compared==NULL)
   //       return -1;
      
   // // --- Compare depending on cell type
   //    int cmp=0;
   //    switch(cell_current.Datatype())
   //    {
   //       case TYPE_DOUBLE  :  cmp=(cell_current.ValueD()>cell_compared.ValueD() ? 1 : cell_current.ValueD()<cell_compared.ValueD() ? -1 : 0); break;
   //       case TYPE_LONG    :
   //       case TYPE_DATETIME:
   //       case TYPE_COLOR   :  cmp=(cell_current.ValueL()>cell_compared.ValueL() ? 1 : cell_current.ValueL()<cell_compared.ValueL() ? -1 : 0); break;
   //       case TYPE_STRING  :  cmp=::StringCompare(cell_current.ValueS(),cell_compared.ValueS());                                              break;
   //       default           :  break;
   //    }
   //    return(asc ? cmp : -cmp);   
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new double cell and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableCell *CTableRow::CellAddNew(const double value)
   // {
   // // --- Create a new cell object storing a value of type double
   //    CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,2);
   //    if(cell==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
   //       return NULL;
   //    }
   // // --- Add the created cell to the end of the list
   //    if(!this.AddNewCell(cell))
   //    {
   //       delete cell;
   //       return NULL;
   //    }
   // // --- Return a pointer to the object
   //    return cell;
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new long cell and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableCell *CTableRow::CellAddNew(const long value)
   // {
   // // --- Create a new cell object storing a value of type long
   //    CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   //    if(cell==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
   //       return NULL;
   //    }
   // // --- Add the created cell to the end of the list
   //    if(!this.AddNewCell(cell))
   //    {
   //       delete cell;
   //       return NULL;
   //    }
   // // --- Return a pointer to the object
   //    return cell;
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new datetime cell and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableCell *CTableRow::CellAddNew(const datetime value)
   // {
   // // --- Create a new cell object storing a value with type datetime
   //    CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   //    if(cell==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
   //       return NULL;
   //    }
   // // --- Add the created cell to the end of the list
   //    if(!this.AddNewCell(cell))
   //    {
   //       delete cell;
   //       return NULL;
   //    }
   // // --- Return a pointer to the object
   //    return cell;
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new color cell and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableCell *CTableRow::CellAddNew(const color value)
   // {
   // // --- Create a new cell object storing a value of type color
   //    CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,true);
   //    if(cell==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
   //       return NULL;
   //    }
   // // --- Add the created cell to the end of the list
   //    if(!this.AddNewCell(cell))
   //    {
   //       delete cell;
   //       return NULL;
   //    }
   // // --- Return a pointer to the object
   //    return cell;
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new string cell and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableCell *CTableRow::CellAddNew(const string value)
   // {
   // // --- Create a new cell object storing a value of type string
   //    CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   //    if(cell==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
   //       return NULL;
   //    }
   // // --- Add the created cell to the end of the list
   //    if(!this.AddNewCell(cell))
   //    {
   //       delete cell;
   //       return NULL;
   //    }
   // // --- Return a pointer to the object
   //    return cell;
   // }
   // //+------------------------------------------------------------------+
   // // | Adds a cell to the end of the list |
   // //+------------------------------------------------------------------+
   // bool CTableRow::AddNewCell(CTableCell *cell)
   // {
   // // --- If an empty object is passed, we report and return false
   //    if(cell==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Empty CTableCell object passed",__FUNCTION__);
   //       return false;
   //    }
   // // --- Set the cell index in the list and add the created cell to the end of the list
   //    cell.SetPositionInTable(this.m_index,this.CellsTotal());
   //    if(this.m_list_cells.Add(cell)==WRONG_VALUE)
   //    {
   //       ::PrintFormat("%s: Error. Failed to add cell (%u,%u) to list",__FUNCTION__,this.m_index,this.CellsTotal());
   //       return false;
   //    }
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Sets a double value to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellSetValue(const uint index,const double value)
   // {
   // // --- We get the desired cell from the list and write a new value into it
   //    CTableCell *cell=this.GetCell(index);
   //    if(cell!=NULL)
   //       cell.SetValue(value);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets a long value to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellSetValue(const uint index,const long value)
   // {
   // // --- We get the desired cell from the list and write a new value into it
   //    CTableCell *cell=this.GetCell(index);
   //    if(cell!=NULL)
   //       cell.SetValue(value);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets a datetime value to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellSetValue(const uint index,const datetime value)
   // {
   // // --- We get the desired cell from the list and write a new value into it
   //    CTableCell *cell=this.GetCell(index);
   //    if(cell!=NULL)
   //       cell.SetValue(value);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the color value to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellSetValue(const uint index,const color value)
   // {
   // // --- We get the desired cell from the list and write a new value into it
   //    CTableCell *cell=this.GetCell(index);
   //    if(cell!=NULL)
   //       cell.SetValue(value);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets a string value to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellSetValue(const uint index,const string value)
   // {
   // // --- We get the desired cell from the list and write a new value into it
   //    CTableCell *cell=this.GetCell(index);
   //    if(cell!=NULL)
   //       cell.SetValue(value);
   // }
   // //+------------------------------------------------------------------+
   // // | Assigns an object to a cell |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellAssignObject(const uint index,CObject *object)
   // {
   // // --- Get the desired cell from the list and write a pointer to the object into it
   //    CTableCell *cell=this.GetCell(index);
   //    if(cell!=NULL)
   //       cell.AssignObject(object);
   // }
   // //+------------------------------------------------------------------+
   // // | Unassigns an object to a cell |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellUnassignObject(const uint index)
   // {
   // // --- We get the desired cell from the list and cancel the pointer to the object and its type in it
   //    CTableCell *cell=this.GetCell(index);
   //    if(cell!=NULL)
   //       cell.UnassignObject();
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the object assigned to the cell |
   // //+------------------------------------------------------------------+
   // CObject *CTableRow::CellGetObject(const uint index)
   // {
   // // --- Get the desired cell from the list and return a pointer to the assigned object
   //    CTableCell *cell=this.GetCell(index);
   //    return(cell!=NULL ? cell.AssignedObject() : NULL);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the type of the object assigned to the cell |
   // //+------------------------------------------------------------------+
   // ENUM_OBJECT_TYPE CTableRow::CellGetObjType(const uint index)
   // {
   // // --- Get the desired cell from the list and return the type of the assigned object
   //    CTableCell *cell=this.GetCell(index);
   //    return(cell!=NULL ? cell.AssignedObjType() : (ENUM_OBJECT_TYPE)WRONG_VALUE);
   // }
   // //+------------------------------------------------------------------+
   // // | Deletes a cell |
   // //+------------------------------------------------------------------+
   // bool CTableRow::CellDelete(const uint index)
   // {
   // // --- Delete a cell in the list by index
   //    if(!this.m_list_cells.Delete(index))
   //       return false;
   // // --- Update indexes for the remaining cells in the list
   //    this.CellsPositionUpdate();
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Moves the cell to the specified position |
   // //+------------------------------------------------------------------+
   // bool CTableRow::CellMoveTo(const uint cell_index,const uint index_to)
   // {
   // // --- Get the desired cell by index in the list, making it current
   //    CTableCell *cell=this.GetCell(cell_index);
   // // --- Move the current cell to the specified position in the list
   //    if(cell==NULL || !this.m_list_cells.MoveToIndex(index_to))
   //       return false;
   // // --- Update the indexes of all cells in the list
   //    this.CellsPositionUpdate();
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Sets row and column positions for all cells |
   // //+------------------------------------------------------------------+
   // void CTableRow::CellsPositionUpdate(void)
   // {
   // // --- Loop through all cells in the list
   //    for(int i=0;i<this.m_list_cells.Total();i++)
   //    {
   //       // --- get the next cell and set the row and column indexes in it
   //       CTableCell *cell=this.GetCell(i);
   //       if(cell!=NULL)
   //          cell.SetPositionInTable(this.Index(),this.m_list_cells.IndexOf(cell));
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Resets row cell data to zero |
   // //+------------------------------------------------------------------+
   // void CTableRow::ClearData(void)
   // {
   // // --- Loop through all cells in the list
   //    for(uint i=0;i<this.CellsTotal();i++)
   //    {
   //       // --- get the next cell and set it to an empty value
   //       CTableCell *cell=this.GetCell(i);
   //       if(cell!=NULL)
   //          cell.ClearData();
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of the object |
   // //+------------------------------------------------------------------+
   // string CTableRow::Description(void)
   // {
   //    return(::StringFormat("%s: Position %u, Cells total: %u",
   //                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Index(),this.CellsTotal()));
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of an object |
   // //+------------------------------------------------------------------+
   // void CTableRow::Print(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS)
   // {
         
   // // --- Number of cells
   //    int total=(int)this.CellsTotal();
      
   // // --- If the output is in tabular form
   //    string res="";
   //    if(as_table)
   //    {
   //       // --- create a table row from the values ​​of all cells
   //       string head=" Row "+(string)this.Index();
   //       string res=::StringFormat("|%-*s |",cell_width,head);
   //       for(int i=0;i<total;i++)
   //       {
   //          CTableCell *cell=this.GetCell(i);
   //          if(cell==NULL)
   //             continue;
   //          res+=::StringFormat("%*s |",cell_width,cell.Value());
   //       }
   //       // --- Output the line to the log
   //       ::Print(res);
   //       return;
   //    }
      
   // // --- Output the title as a line description
   //    ::Print(this.Description()+(detail ? ":" : ""));
      
   // // --- If detailed description
   //    if(detail)
   //    {
         
   //       // ---Output not in tabular form
   //       // --- Loop through a list of row cells
   //       for(int i=0; i<total; i++)
   //       {
   //          // --- get the current cell and add its description to the final line
   //          CTableCell *cell=this.GetCell(i);
   //          if(cell!=NULL)
   //             res+="  "+cell.Description()+(i<total-1 ? "\n" : "");
   //       }
   //       // --- Log the line created in the loop
   //       ::Print(res);
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Saving to file |
   // //+------------------------------------------------------------------+
   // bool CTableRow::Save(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
   //       return(false);
   // // --- Save the object type
   //    if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
   //       return(false);

   // // --- Save the index
   //    if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
   //       return(false);
   // // --- Save the list of cells
   //    if(!this.m_list_cells.Save(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Loading from file |
   // //+------------------------------------------------------------------+
   // bool CTableRow::Load(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //       return(false);
   // // --- Loading the object type
   //    if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //       return(false);

   // // --- Loading the index
   //    this.m_index=::FileReadInteger(file_handle,INT_VALUE);
   // // --- Loading a list of cells
   //    if(!this.m_list_cells.Load(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_TABLEROW_MQH

#ifndef MOVE_TO_MQLPARAMOBJ_MQH
#define MOVE_TO_MQLPARAMOBJ_MQH
   //+------------------------------------------------------------------+
   // // | Structure parameter object class |
   // //+------------------------------------------------------------------+
   // class CMqlParamObj : public CObject
   // {
   // protected:
   // public:
   //    MqlParam          m_param;
   // // --- Setting parameters
   //    void              Set(const MqlParam &param)
   //                      {
   //                         this.m_param.type=param.type;
   //                         this.m_param.double_value=param.double_value;
   //                         this.m_param.integer_value=param.integer_value;
   //                         this.m_param.string_value=param.string_value;
   //                      }
   // // --- Return parameters
   //    MqlParam          Param(void)       const { return this.m_param;              }
   //    ENUM_DATATYPE     Datatype(void)    const { return this.m_param.type;         }
   //    double            ValueD(void)      const { return this.m_param.double_value; }
   //    long              ValueL(void)      const { return this.m_param.integer_value;}
   //    string            ValueS(void)      const { return this.m_param.string_value; }
   // // ---Object description
   //    virtual string    Description(void)
   //                      {
   //                         string t=::StringSubstr(::EnumToString(this.m_param.type),5);
   //                         t.Lower();
   //                         string v="";
   //                         switch(this.m_param.type)
   //                         {
   //                            case TYPE_STRING  :  v=this.ValueS();                                                     break;
   //                            case TYPE_FLOAT   :  case TYPE_DOUBLE : v=::DoubleToString(this.ValueD());                break;
   //                            case TYPE_DATETIME:  v=::TimeToString(this.ValueL(),TIME_DATE|TIME_MINUTES|TIME_SECONDS); break;
   //                            default           :  v=(string)this.ValueL();                                             break;
   //                         }
   //                         return(::StringFormat("<%s>%s",t,v));
   //                      }
      
   // // --- Constructors/destructor
   //                      CMqlParamObj(void){}
   //                      CMqlParamObj(const MqlParam &param) { this.Set(param);  }
   //                   ~CMqlParamObj(void){}
   // };
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_MQLPARAMOBJ_MQH  

#ifndef MOVE_TO_DATALISTCREATOR_MQH
#define MOVE_TO_DATALISTCREATOR_MQH
   // //+------------------------------------------------------------------+
   // // | Class for creating lists of data |
   // //+------------------------------------------------------------------+
   // class DataListCreator
   // {
   // public:
   // // --- Adds a new row to the CList list_data
   //    static CList     *AddNewRowToDataList(CList *list_data)
   //                      {
   //                         CList *row=new CList;
   //                         if(row==NULL || list_data.Add(row)<0)
   //                            return NULL;
   //                         return row;
   //                      }
   // // --- Creates a new parameters object CMqlParamObj and adds it to the CList
   //    static bool       AddNewCellParamToRow(CList *row,MqlParam &param)
   //                      {
   //                         CMqlParamObj *cell=new CMqlParamObj(param);
   //                         if(cell==NULL)
   //                            return false;
   //                         if(row.Add(cell)<0)
   //                         {
   //                            delete cell;
   //                            return false;
   //                         }
   //                         return true;
   //                      }
   // };
#endif // MOVE_TO_DATALISTCREATOR_MQH

#ifndef MOVE_TO_TABLEMODEL_MQH
#define MOVE_TO_TABLEMODEL_MQH
   // //+------------------------------------------------------------------+
   // // | Table model class |
   // //+------------------------------------------------------------------+
   // class CTableModel : public CObject
   // {
   // protected:
   //    CTableRow         m_row_tmp;                             // String object to search in list
   //    CListObj          m_list_rows;                           // List of table rows
   // // --- Creates a table model from a two-dimensional array
   // template<typename T>
   //    void              CreateTableModel(T &array[][]);
   //    void              CreateTableModel(const uint num_rows,const uint num_columns);
   //    void              CreateTableModel(const matrix &row_data);
   //    void              CreateTableModel(CList &list_param);
   // // --- Returns the correct data type
   //    ENUM_DATATYPE     GetCorrectDatatype(string type_name)
   //                      {
   //                         return
   //                         (
   //                            // --- Integer value
   //                            type_name=="bool" || type_name=="char"    || type_name=="uchar"   ||
   //                            type_name=="short"|| type_name=="ushort"  || type_name=="int"     ||
   //                            type_name=="uint" || type_name=="long"    || type_name=="ulong"   ?  TYPE_LONG      :
   //                            // --- Real value
   //                            type_name=="float"|| type_name=="double"                          ?  TYPE_DOUBLE    :
   //                            // --- Date/time value
   //                            type_name=="datetime"                                             ?  TYPE_DATETIME  :
   //                            // ---Color meaning
   //                            type_name=="color"                                                ?  TYPE_COLOR     :
   //                            /* --- String value */                                          TYPE_STRING    );
   //                      }
      
   // // --- Creates and adds a new empty string to the end of the list
   //    CTableRow        *CreateNewEmptyRow(void);
   // // --- Adds a string to the end of the list
   //    bool              AddNewRow(CTableRow *row);
   // // --- Sets row and column positions for all table cells
   //    void              CellsPositionUpdate(void);
      
   // public:
   // // --- Returns (1) cell, (2) row by index, number of (3) rows, cells (4) in the specified row, (5) in the table
   //    CTableCell       *GetCell(const uint row, const uint col);
   //    CTableRow        *GetRow(const uint index)                  { return this.m_list_rows.GetNodeAtIndex(index);}
   //    uint              RowsTotal(void)                     const { return this.m_list_rows.Total();              }
   //    uint              CellsInRow(const uint index);
   //    uint              CellsTotal(void);

   // // --- Sets (1) value, (2) precision, (3) time display flags, (4) color name display flag to specified cell
   // template<typename T>
   //    void              CellSetValue(const uint row, const uint col, const T value);
   //    void              CellSetDigits(const uint row, const uint col, const int digits);
   //    void              CellSetTimeFlags(const uint row, const uint col, const uint flags);
   //    void              CellSetColorNamesFlag(const uint row, const uint col, const bool flag);
   // // --- (1) Assigns, (2) cancels an object in a cell
   //    void              CellAssignObject(const uint row, const uint col,CObject *object);
   //    void              CellUnassignObject(const uint row, const uint col);
   // // --- (1) Deletes (2) moves a cell
   //    bool              CellDelete(const uint row, const uint col);
   //    bool              CellMoveTo(const uint row, const uint cell_index, const uint index_to);
   // // ---Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
   //    CObject          *CellGetObject(const uint row, const uint col);
   //    ENUM_OBJECT_TYPE  CellGetObjType(const uint row, const uint col);
   // // --- (1) Returns, (2) logs the description of the cell, (3) the object assigned to the cell
   //    string            CellDescription(const uint row, const uint col);
   //    void              CellPrint(const uint row, const uint col);
      
   // public:
   // // --- Creates a new line and (1) appends it to the end of the list, (2) inserts it at the specified position in the list
   //    CTableRow        *RowAddNew(void);
   //    CTableRow        *RowInsertNewTo(const uint index_to);
   // // --- (1) Deletes (2) moves a row, (3) clears row data
   //    bool              RowDelete(const uint index);
   //    bool              RowMoveTo(const uint row_index, const uint index_to);
   //    void              RowClearData(const uint index);
   // // --- (1) Returns, (2) logs the description of the string
   //    string            RowDescription(const uint index);
   //    void              RowPrint(const uint index,const bool detail);
      
   // // --- (1) Adds, (2) deletes (3) moves a column, (4) clears data, sets (5) type,
   // // --- (6) data accuracy, display flags (7) time, (8) column color names
   //    bool              ColumnAddNew(const int index=-1);
   //    bool              ColumnDelete(const uint index);
   //    bool              ColumnMoveTo(const uint col_index, const uint index_to);
   //    void              ColumnClearData(const uint index);
   //    void              ColumnSetDatatype(const uint index,const ENUM_DATATYPE type);
   //    void              ColumnSetDigits(const uint index,const int digits);
      
   //    void              ColumnSetTimeFlags(const uint index, const uint flags);
   //    void              ColumnSetColorNamesFlag(const uint index, const bool flag);
   
   // // --- Sorts the table by the specified column and direction
   //    void              SortByColumn(const uint column, const bool descending);
      
   // // --- (1) Returns, (2) logs the table description
   //    virtual string    Description(void);
   //    void              Print(const bool detail);
   //    void              PrintTable(const int cell_width=CELL_WIDTH_IN_CHARS);
      
   // // --- (1) Clears the data, (2) destroys the model
   //    void              ClearData(void);
   //    void              Destroy(void);
      
   // // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //    virtual int       Compare(const CObject *node,const int mode=0)      const { return -1;         }
   //    virtual bool      Save(const int file_handle);
   //    virtual bool      Load(const int file_handle);
   //    virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_MODEL);  }
      
   // // --- Constructors/destructor
   // template<typename T> CTableModel(T &array[][])                                { this.CreateTableModel(array);                 }
   //                      CTableModel(const uint num_rows,const uint num_columns)  { this.CreateTableModel(num_rows,num_columns);  }
   //                      CTableModel(const matrix &row_data)                      { this.CreateTableModel(row_data);              }
   //                      CTableModel(CList &row_data)                             { this.CreateTableModel(row_data);              }
   //                      CTableModel(void){}
   //                   ~CTableModel(void){}
   // };
   // //+------------------------------------------------------------------+
   // // | Creates a table model from a two-dimensional array |
   // //+------------------------------------------------------------------+
   // template<typename T>
   // void CTableModel::CreateTableModel(T &array[][])
   // {
   // // --- Get the number of rows and columns of the table from the array properties
   //    int rows_total=::ArrayRange(array,0);
   //    int cols_total=::ArrayRange(array,1);
   // // --- In a loop through row indexes
   //    for(int r=0; r<rows_total; r++)
   //    {
   //       // --- create a new empty string and add it to the end of the list of strings
   //       CTableRow *row=this.CreateNewEmptyRow();
   //       // --- If a row is created and added to the list,
   //       if(row!=NULL)
   //       {
   //          // --- In a loop by the number of cells in a row
   //          // --- create all cells, adding each new one to the end of the list of row cells
   //          for(int c=0; c<cols_total; c++)
   //             row.CellAddNew(array[r][c]);
   //       }
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a table model from the specified number of rows and columns |
   // //+------------------------------------------------------------------+
   // void CTableModel::CreateTableModel(const uint num_rows,const uint num_columns)
   // {
   // // --- In a loop by number of lines
   //    for(uint r=0; r<num_rows; r++)
   //    {
   //       // --- create a new empty string and add it to the end of the list of strings
   //       CTableRow *row=this.CreateNewEmptyRow();
   //       // --- If a row is created and added to the list,
   //       if(row!=NULL)
   //       {
   //          // --- In a loop by number of columns
   //          // --- create all cells, adding each new one to the end of the list of row cells
   //          for(uint c=0; c<num_columns; c++)
   //          {
   //             CTableCell *cell=row.CellAddNew(0.0);
   //             if(cell!=NULL)
   //                cell.ClearData();
   //          }
   //       }
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a table model from the specified matrix |
   // //+------------------------------------------------------------------+
   // void CTableModel::CreateTableModel(const matrix &row_data)
   // {
   // // --- Number of rows and columns
   //    ulong num_rows=row_data.Rows();
   //    ulong num_columns=row_data.Cols();
   // // --- In a loop by number of lines
   //    for(uint r=0; r<num_rows; r++)
   //    {
   //       // --- create a new empty string and add it to the end of the list of strings
   //       CTableRow *row=this.CreateNewEmptyRow();
   //       // --- If a row is created and added to the list,
   //       if(row!=NULL)
   //       {
   //          // --- In a loop by number of columns
   //          // --- create all cells, adding each new one to the end of the list of row cells
   //          for(uint c=0; c<num_columns; c++)
   //             row.CellAddNew(row_data[r][c]);
   //       }
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a table model from a list of parameters |
   // //+------------------------------------------------------------------+
   // void CTableModel::CreateTableModel(CList &list_param)
   // {
   // // --- If an empty list is transmitted, we report this and leave
   //    if(list_param.Total()==0)
   //    {
   //       ::PrintFormat("%s: Error. Empty list passed",__FUNCTION__);
   //       return;
   //    }
   // // --- Get a pointer to the first row of the table to determine the number of columns
   // // --- If the first line could not be obtained, or there are no cells in it, we report this and leave
   //    CList *first_row=list_param.GetFirstNode();
   //    if(first_row==NULL || first_row.Total()==0)
   //    {
   //       if(first_row==NULL)
   //          ::PrintFormat("%s: Error. Failed to get first row of list",__FUNCTION__);
   //       else
   //          ::PrintFormat("%s: Error. First row does not contain data",__FUNCTION__);
   //       return;
   //    }
   // // --- Number of rows and columns
   //    ulong num_rows=list_param.Total();
   //    ulong num_columns=first_row.Total();
   // // --- In a loop by number of lines
   //    for(uint r=0; r<num_rows; r++)
   //    {
   //       // --- get the next table row from the list_param list
   //       CList *col_list=list_param.GetNodeAtIndex(r);
   //       if(col_list==NULL)
   //          continue;
   //       // --- create a new empty string and add it to the end of the list of strings
   //       CTableRow *row=this.CreateNewEmptyRow();
   //       // --- If a row is created and added to the list,
   //       if(row!=NULL)
   //       {
   //          // --- In a loop by number of columns
   //          // --- create all cells, adding each new one to the end of the list of row cells
   //          for(uint c=0; c<num_columns; c++)
   //          {
   //             CMqlParamObj *param=col_list.GetNodeAtIndex(c);
   //             if(param==NULL)
   //                continue;

   //             // --- We declare a pointer to the cell and the type of data that will be contained in it
   //             CTableCell *cell=NULL;
   //             ENUM_DATATYPE datatype=param.Datatype();
   //             // ---Depending on data type
   //             switch(datatype)
   //             {
   //                // --- real data type
   //                case TYPE_FLOAT   :
   //                case TYPE_DOUBLE  :  cell=row.CellAddNew((double)param.ValueD());    // Create a new cell with double data and
   //                                     if(cell!=NULL)
   //                                        cell.SetDigits((int)param.ValueL());         // record the accuracy of the displayed data
   //                                     break;
   //                // --- datetime data type
   //                case TYPE_DATETIME:  cell=row.CellAddNew((datetime)param.ValueL());  // Create a new cell with datetime data and
   //                                     if(cell!=NULL)
   //                                        cell.SetDatetimeFlags((int)param.ValueD());  // write date/time display flags
   //                                     break;
   //                // --- data type color
   //                case TYPE_COLOR   :  cell=row.CellAddNew((color)param.ValueL());     // Create a new cell with color data and
   //                                     if(cell!=NULL)
   //                                        cell.SetColorNameFlag((bool)param.ValueD()); // write down a flag for displaying the names of known colors
   //                                     break;
   //                // --- string data type
   //                case TYPE_STRING  :  cell=row.CellAddNew((string)param.ValueS());    // Create a new cell with string data
   //                                     break; 
   //                // --- integer data type
   //                default           :  cell=row.CellAddNew((long)param.ValueL());      // Create a new cell with long data
   //                                     break; 
   //             }
   //          }
   //       }
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new empty string and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableRow *CTableModel::CreateNewEmptyRow(void)
   // {
   // // --- Create a new string object
   //    CTableRow *row=new CTableRow(this.m_list_rows.Total());
   //    if(row==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Failed to create new row at position %u",__FUNCTION__, this.m_list_rows.Total());
   //       return NULL;
   //    }
   // // --- If the string could not be added to the list, delete the created new object and return NULL
   //    if(!this.AddNewRow(row))
   //    {
   //       delete row;
   //       return NULL;
   //    }
      
   // // --- Success - return a pointer to the created object
   //    return row;
   // }
   // //+------------------------------------------------------------------+
   // // | Adds a string to the end of the list |
   // //+------------------------------------------------------------------+
   // bool CTableModel::AddNewRow(CTableRow *row)
   // {
   // // --- If an empty object is passed, we report this and return false
   //    if(row==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Empty CTableRow object passed",__FUNCTION__);
   //       return false;
   //    }
   // // --- Set the line to its index in the list and add it to the end of the list
   //    row.SetIndex(this.RowsTotal());
   //    if(this.m_list_rows.Add(row)==WRONG_VALUE)
   //    {
   //       ::PrintFormat("%s: Error. Failed to add row (%u) to list",__FUNCTION__,row.Index());
   //       return false;
   //    }

   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new line and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableRow *CTableModel::RowAddNew(void)
   // {
   // // --- Create a new empty string and add it to the end of the list of strings
   //    CTableRow *row=this.CreateNewEmptyRow();
   //    if(row==NULL)
   //       return NULL;
         
   // // --- Create cells based on the number of cells in the first row
   //    for(uint i=0;i<this.CellsInRow(0);i++)
   //       row.CellAddNew(0.0);
   //    row.ClearData();
      
   // // --- Success - return a pointer to the created object
   //    return row;
   // }
   // //+------------------------------------------------------------------+
   // // | Creates and adds a new row at the specified list position |
   // //+------------------------------------------------------------------+
   // CTableRow *CTableModel::RowInsertNewTo(const uint index_to)
   // {
   // // --- Create a new empty string and add it to the end of the list of strings
   //    CTableRow *row=this.CreateNewEmptyRow();
   //    if(row==NULL)
   //       return NULL;
      
   // // --- Create cells based on the number of cells in the first row
   //    for(uint i=0;i<this.CellsInRow(0);i++)
   //       row.CellAddNew(0.0);
   //    row.ClearData();
      
   // // --- Shift the line to the index_to position
   //    this.RowMoveTo(this.m_list_rows.IndexOf(row),index_to);
      
   // // --- Success - return a pointer to the created object
   //    return row;
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the value to the specified cell |
   // //+------------------------------------------------------------------+
   // template<typename T>
   // void CTableModel::CellSetValue(const uint row,const uint col,const T value)
   // {
   // // --- Get a cell by row and column indexes
   //    CTableCell *cell=this.GetCell(row,col);
   //    if(cell==NULL)
   //       return;
   // // --- We get the correct type of data being set (double, long, datetime, color, string)
   //    ENUM_DATATYPE type=this.GetCorrectDatatype(typename(T));
   // // --- Depending on the data type, call the corresponding data type
   // // --- cell method for setting a value, explicitly specifying the required type
   //    switch(type)
   //    {
   //       case TYPE_DOUBLE  :  cell.SetValue((double)value);    break;
   //       case TYPE_LONG    :  cell.SetValue((long)value);      break;
   //       case TYPE_DATETIME:  cell.SetValue((datetime)value);  break;
   //       case TYPE_COLOR   :  cell.SetValue((color)value);     break;
   //       case TYPE_STRING  :  cell.SetValue((string)value);    break;
   //       default           :  break;
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the accuracy of displaying data in the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableModel::CellSetDigits(const uint row,const uint col,const int digits)
   // {
   // // --- Get the cell by row and column indices and
   // // --- call its corresponding method to set the value
   //    CTableCell *cell=this.GetCell(row,col);
   //    if(cell!=NULL)
   //       cell.SetDigits(digits);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets time display flags to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableModel::CellSetTimeFlags(const uint row,const uint col,const uint flags)
   // {
   // // --- Get the cell by row and column indices and
   // // --- call its corresponding method to set the value
   //    CTableCell *cell=this.GetCell(row,col);
   //    if(cell!=NULL)
   //       cell.SetDatetimeFlags(flags);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the flag to display color names in the specified cell |
   // //+------------------------------------------------------------------+
   // void CTableModel::CellSetColorNamesFlag(const uint row,const uint col,const bool flag)
   // {
   // // --- Get the cell by row and column indices and
   // // --- call its corresponding method to set the value
   //    CTableCell *cell=this.GetCell(row,col);
   //    if(cell!=NULL)
   //       cell.SetColorNameFlag(flag);
   // }
   // //+------------------------------------------------------------------+
   // // | Assigns an object to a cell |
   // //+------------------------------------------------------------------+
   // void CTableModel::CellAssignObject(const uint row,const uint col,CObject *object)
   // {
   // // --- Get the cell by row and column indices and
   // // --- call its corresponding method to set the value
   //    CTableCell *cell=this.GetCell(row,col);
   //    if(cell!=NULL)
   //       cell.AssignObject(object);
   // }
   // //+------------------------------------------------------------------+
   // // | Unassigns an object in a cell |
   // //+------------------------------------------------------------------+
   // void CTableModel::CellUnassignObject(const uint row,const uint col)
   // {
   // // --- Get the cell by row and column indices and
   // // --- call its corresponding method to set the value
   //    CTableCell *cell=this.GetCell(row,col);
   //    if(cell!=NULL)
   //       cell.UnassignObject();
   // }
   // //+------------------------------------------------------------------+
   // // | Deletes a cell |
   // //+------------------------------------------------------------------+
   // bool CTableModel::CellDelete(const uint row,const uint col)
   // {
   // // --- Get a row by index and return the result of deleting a cell from the list
   //    CTableRow *row_obj=this.GetRow(row);
   //    return(row_obj!=NULL ? row_obj.CellDelete(col) : false);
   // }
   // //+------------------------------------------------------------------+
   // // | Moves a cell |
   // //+------------------------------------------------------------------+
   // bool CTableModel::CellMoveTo(const uint row,const uint cell_index,const uint index_to)
   // {
   // // --- Get the row by index and return the result of moving the cell to a new position
   //    CTableRow *row_obj=this.GetRow(row);
   //    return(row_obj!=NULL ? row_obj.CellMoveTo(cell_index,index_to) : false);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the object assigned to the cell |
   // //+------------------------------------------------------------------+
   // CObject *CTableModel::CellGetObject(const uint row,const uint col)
   // {
   // // --- Get the row by index and return the object assigned to the cell with index col
   //    CTableRow *row_obj=this.GetRow(row);
   //    return(row_obj!=NULL ? row_obj.CellGetObject(col) : NULL);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the type of the object assigned to the cell |
   // //+------------------------------------------------------------------+
   // ENUM_OBJECT_TYPE CTableModel::CellGetObjType(const uint row,const uint col)
   // {
   // // --- Get the row by index and return the type of the object assigned to the cell with index col
   //    CTableRow *row_obj=this.GetRow(row);
   //    return(row_obj!=NULL ? row_obj.CellGetObjType(col) : (ENUM_OBJECT_TYPE)WRONG_VALUE);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the number of cells in the specified row |
   // //+------------------------------------------------------------------+
   // uint CTableModel::CellsInRow(const uint index)
   // {
   //    CTableRow *row=this.GetRow(index);
   //    return(row!=NULL ? row.CellsTotal() : 0);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the number of cells in the table |
   // //+------------------------------------------------------------------+
   // uint CTableModel::CellsTotal(void)
   // {
   // // --- counting cells in a row-by-row loop (slow if there are a large number of rows)
   //    uint res=0, total=this.RowsTotal();
   //    for(int i=0; i<(int)total; i++)
   //    {
   //       CTableRow *row=this.GetRow(i);
   //       res+=(row!=NULL ? row.CellsTotal() : 0);
   //    }
   //    return res;
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the specified table cell |
   // //+------------------------------------------------------------------+
   // CTableCell *CTableModel::GetCell(const uint row,const uint col)
   // {
   // // --- Get a row by index row and return the cell of the row by index col
   //    CTableRow *row_obj=this.GetRow(row);
   //    return(row_obj!=NULL ? row_obj.GetCell(col) : NULL);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns cell description |
   // //+------------------------------------------------------------------+
   // string CTableModel::CellDescription(const uint row,const uint col)
   // {
   //    CTableCell *cell=this.GetCell(row,col);
   //    return(cell!=NULL ? cell.Description() : "");
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a cell description |
   // //+------------------------------------------------------------------+
   // void CTableModel::CellPrint(const uint row,const uint col)
   // {
   // // --- Get a cell by row and column index and return its description
   //    CTableCell *cell=this.GetCell(row,col);
   //    if(cell!=NULL)
   //       cell.Print();
   // }
   // //+------------------------------------------------------------------+
   // // | Deletes a line |
   // //+------------------------------------------------------------------+
   // bool CTableModel::RowDelete(const uint index)
   // {
   // // --- Remove a line from the list by index
   //    if(!this.m_list_rows.Delete(index))
   //       return false;
   // // --- After deleting a row, you need to update all indexes of all table cells
   //    this.CellsPositionUpdate();
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Moves a line to the specified position |
   // //+------------------------------------------------------------------+
   // bool CTableModel::RowMoveTo(const uint row_index,const uint index_to)
   // {
   // // --- Get the row by index, making it current
   //    CTableRow *row=this.GetRow(row_index);
   // // --- Move the current line to the specified position in the list
   //    if(row==NULL || !this.m_list_rows.MoveToIndex(index_to))
   //       return false;
   // // --- After moving a row, you need to update all indexes of all table cells
   //    this.CellsPositionUpdate();
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Sets row and column positions for all cells |
   // //+------------------------------------------------------------------+
   // void CTableModel::CellsPositionUpdate(void)
   // {
   // // --- Looping through a list of strings
   //    for(int i=0;i<this.m_list_rows.Total();i++)
   //    {
   //       // --- we get the next line
   //       CTableRow *row=this.GetRow(i);
   //       if(row==NULL)
   //          continue;
   //       // --- set the row index found by the IndexOf() method of the list
   //       row.SetIndex(this.m_list_rows.IndexOf(row));
   //       // --- Update the position indexes of the row cells
   //       row.CellsPositionUpdate();
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Clears a row (only data in cells) |
   // //+------------------------------------------------------------------+
   // void CTableModel::RowClearData(const uint index)
   // {
   // // --- Get a string from the list and clear the data of the string cells using the ClearData() method
   //    CTableRow *row=this.GetRow(index);
   //    if(row!=NULL)
   //       row.ClearData();
   // }
   // //+------------------------------------------------------------------+
   // // | Clears the table (data of all cells) |
   // //+------------------------------------------------------------------+
   // void CTableModel::ClearData(void)
   // {
   // // --- In a loop through all rows of the table, we clear the data of each row
   //    for(uint i=0;i<this.RowsTotal();i++)
   //       this.RowClearData(i);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of a string |
   // //+------------------------------------------------------------------+
   // string CTableModel::RowDescription(const uint index)
   // {
   // // --- Get a string by index and return its description
   //    CTableRow *row=this.GetRow(index);
   //    return(row!=NULL ? row.Description() : "");
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of a string |
   // //+------------------------------------------------------------------+
   // void CTableModel::RowPrint(const uint index,const bool detail)
   // {
   //    CTableRow *row=this.GetRow(index);
   //    if(row!=NULL)
   //       row.Print(detail);
   // }
   // //+------------------------------------------------------------------+
   // // | Adds a column |
   // //+------------------------------------------------------------------+
   // bool CTableModel::ColumnAddNew(const int index=-1)
   // {
   // // --- Declare variables
   //    CTableCell *cell=NULL;
   //    bool res=true;
   // // --- In a loop by number of lines
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       // --- we get the next line
   //       CTableRow *row=this.GetRow(i);
   //       if(row!=NULL)
   //       {
   //          // --- add a cell with type double to the end of the line
   //          cell=row.CellAddNew(0.0);
   //          if(cell==NULL)
   //             res &=false;
   //          // --- clear the cell
   //          else
   //             cell.ClearData();
   //       }
   //    }
   // // --- If the column index is not negative, shift the column to the specified position
   //    if(res && index>-1)
   //       res &=this.ColumnMoveTo(this.CellsInRow(0)-1,index);
   // // --- Return the result
   //    return res;
   // }
   // //+------------------------------------------------------------------+
   // // | Removes a column |
   // //+------------------------------------------------------------------+
   // bool CTableModel::ColumnDelete(const uint index)
   // {
   //    bool res=true;
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       CTableRow *row=this.GetRow(i);
   //       if(row!=NULL)
   //          res &=row.CellDelete(index);
   //    }
   //    return res;
   // }
   // //+------------------------------------------------------------------+
   // // | Moves column |
   // //+------------------------------------------------------------------+
   // bool CTableModel::ColumnMoveTo(const uint col_index,const uint index_to)
   // {
   //    bool res=true;
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       CTableRow *row=this.GetRow(i);
   //       if(row!=NULL)
   //          res &=row.CellMoveTo(col_index,index_to);
   //    }
   //    return res;
   // }
   // //+------------------------------------------------------------------+
   // // | Clears column data |
   // //+------------------------------------------------------------------+
   // void CTableModel::ColumnClearData(const uint index)
   // {
   // // --- In a loop through all rows of the table
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       // --- get from each row a cell with a column index and clear it
   //       CTableCell *cell=this.GetCell(i, index);
   //       if(cell!=NULL)
   //          cell.ClearData();
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the column data type |
   // //+------------------------------------------------------------------+
   // void CTableModel::ColumnSetDatatype(const uint index,const ENUM_DATATYPE type)
   // {
   // // --- In a loop through all rows of the table
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       // --- get from each row a cell with a column index and set the data type
   //       CTableCell *cell=this.GetCell(i, index);
   //       if(cell!=NULL)
   //          cell.SetDatatype(type);
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the precision of the column data |
   // //+------------------------------------------------------------------+
   // void CTableModel::ColumnSetDigits(const uint index,const int digits)
   // {
   // // --- In a loop through all rows of the table
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       // --- get from each row a cell with a column index and set the data precision
   //       CTableCell *cell=this.GetCell(i, index);
   //       if(cell!=NULL)
   //          cell.SetDigits(digits);
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Sets column time display flags |
   // //+------------------------------------------------------------------+
   // void CTableModel::ColumnSetTimeFlags(const uint index,const uint flags)
   // {
   // // --- In a loop through all rows of the table
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       // --- get from each row a cell with a column index and set the time display flags
   //       CTableCell *cell=this.GetCell(i, index);
   //       if(cell!=NULL)
   //          cell.SetDatetimeFlags(flags);
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the display flagb of column color names |
   // //+------------------------------------------------------------------+
   // void CTableModel::ColumnSetColorNamesFlag(const uint index,const bool flag)
   // {
   // // --- In a loop through all rows of the table
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       // --- get from each row a cell with a column index and set the flag for displaying color names
   //       CTableCell *cell=this.GetCell(i, index);
   //       if(cell!=NULL)
   //          cell.SetColorNameFlag(flag);
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Sorts the table by the specified column and direction |
   // //+------------------------------------------------------------------+
   // void CTableModel::SortByColumn(const uint column,const bool descending)
   // {
   //    if(this.m_list_rows.Total()==0)
   //       return;
   //    int mode=(int)column+(descending ? DESC_IDX_CORRECTION : ASC_IDX_CORRECTION);
   //    this.m_list_rows.Sort(mode);
   //    this.CellsPositionUpdate();   
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of the object |
   // //+------------------------------------------------------------------+
   // string CTableModel::Description(void)
   // {
   //    return(::StringFormat("%s: Rows %u, Cells in row %u, Cells Total %u",
   //                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.RowsTotal(),this.CellsInRow(0),this.CellsTotal()));
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of an object |
   // //+------------------------------------------------------------------+
   // void CTableModel::Print(const bool detail)
   // {
   // // --- Output the header to the log
   //    ::Print(this.Description()+(detail ? ":" : ""));
   // // ---If detailed description,
   //    if(detail)
   //    {
   //       // --- In a loop through all rows of the table
   //       for(uint i=0; i<this.RowsTotal(); i++)
   //       {
   //          // --- we get the next line and display its detailed description in the log
   //          CTableRow *row=this.GetRow(i);
   //          if(row!=NULL)
   //             row.Print(true,false);
   //       }
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of an object in tabular form |
   // //+------------------------------------------------------------------+
   // void CTableModel::PrintTable(const int cell_width=CELL_WIDTH_IN_CHARS)
   // {
   // // --- Get a pointer to the first row (index 0)
   //    CTableRow *row=this.GetRow(0);
   //    if(row==NULL)
   //       return;
   //    // --- Using the number of cells in the first row of the table, we create a table title line
   //    uint total=row.CellsTotal();
   //    string head=" n/n";
   //    string res=::StringFormat("|%*s |",cell_width,head);
   //    for(uint i=0;i<total;i++)
   //    {
   //       if(this.GetCell(0, i)==NULL)
   //          continue;
   //       string cell_idx=" Column "+(string)i;
   //       res+=::StringFormat("%*s |",cell_width,cell_idx);
   //    }
   //    // --- Output the header line to the log
   //    ::Print(res);
      
   //    // --- Let's loop through all the rows of the table and print them in tabular form
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       CTableRow *row=this.GetRow(i);
   //       if(row!=NULL)
   //          row.Print(true,true,cell_width);
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Destroys the model |
   // //+------------------------------------------------------------------+
   // void CTableModel::Destroy(void)
   // {
   // // --- Clear the list of strings
   //    this.m_list_rows.Clear();
   // }
   // //+------------------------------------------------------------------+
   // // | Saving to file |
   // //+------------------------------------------------------------------+
   // bool CTableModel::Save(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
   //       return(false);
   // // --- Save the object type
   //    if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
   //       return(false);

   //    // --- Save the list of strings
   //    if(!this.m_list_rows.Save(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Loading from file |
   // //+------------------------------------------------------------------+
   // bool CTableModel::Load(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //       return(false);
   // // --- Loading the object type
   //    if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //       return(false);

   //    // --- Load a list of strings
   //    if(!this.m_list_rows.Load(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_TABLEMODEL_MQH

#ifndef MOVE_TO_CCOLUMNCAPTION_MQH
#define MOVE_TO_CCOLUMNCAPTION_MQH
   ////+------------------------------------------------------------------+
   // // | Table Column Header Class |
   // //+------------------------------------------------------------------+
   // class CColumnCaption : public CObject
   // {
   // protected:
   // // --- Variables
   //    ushort            m_ushort_array[MAX_STRING_LENGTH];        // Header character array
   //    uint              m_column;                                 // Column number
   //    ENUM_DATATYPE     m_datatype;                               // Data type

   // public:
   // // --- (1) Sets, (2) returns the column number
   //    void              SetColumn(const uint column)              { this.m_column=column;    }
   //    uint              Column(void)                        const { return this.m_column;    }

   // // --- (1) Sets, (2) returns the data type of the column
   //    ENUM_DATATYPE     Datatype(void)                      const { return this.m_datatype;  }
   //    void              SetDatatype(const ENUM_DATATYPE datatype) { this.m_datatype=datatype;}
      
   // // --- Clears data
   //    void              ClearData(void)                           { this.SetValue("");       }
      
   // // --- Sets the title
   //    void              SetValue(const string value)
   //                      {
   //                         ::StringToShortArray(value,this.m_ushort_array);
   //                      }
   // // --- Returns the title text
   //    string            Value(void) const
   //                      {
   //                         string res=::ShortArrayToString(this.m_ushort_array);
   //                         res.TrimLeft();
   //                         res.TrimRight();
   //                         return res;
   //                      }
      
   // // --- (1) Returns, (2) logs a description of the object
   //    virtual string    Description(void);
   //    void              Print(void);

   // // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //    virtual int       Compare(const CObject *node,const int mode=0) const;
   //    virtual bool      Save(const int file_handle);
   //    virtual bool      Load(const int file_handle);
   //    virtual int       Type(void)                          const { return(OBJECT_TYPE_COLUMN_CAPTION);  }
      
      
   // // --- Constructors/destructor
   //                      CColumnCaption(void) : m_column(0) { this.SetValue(""); }
   //                      CColumnCaption(const uint column,const string value) : m_column(column) { this.SetValue(value); }
   //                   ~CColumnCaption(void) {}
   // };
   // //+------------------------------------------------------------------+
   // // | Comparison of two objects |
   // //+------------------------------------------------------------------+
   // int CColumnCaption::Compare(const CObject *node,const int mode=0) const
   // {
   //    if(node==NULL)
   //       return -1;
   //    const CColumnCaption *obj=node;
   //    return(this.Column()>obj.Column() ? 1 : this.Column()<obj.Column() ? -1 : 0);
   // }
   // //+------------------------------------------------------------------+
   // // | Saving to file |
   // //+------------------------------------------------------------------+
   // bool CColumnCaption::Save(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
   //       return(false);
   // // --- Save the object type
   //    if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
   //       return(false);

   //    // --- Save the column number
   //    if(::FileWriteInteger(file_handle,this.m_column,INT_VALUE)!=INT_VALUE)
   //       return(false);
   //    // --- Save the value
   //    if(::FileWriteArray(file_handle,this.m_ushort_array)!=sizeof(this.m_ushort_array))
   //       return(false);
      
   // //--- Всё успешно
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Loading from file |
   // //+------------------------------------------------------------------+
   // bool CColumnCaption::Load(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //       return(false);
   // // --- Loading the object type
   //    if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //       return(false);

   //    // --- Loading the column number
   //    this.m_column=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Loading value
   //    if(::FileReadArray(file_handle,this.m_ushort_array)!=sizeof(this.m_ushort_array))
   //       return(false);
      
   // // --- Everything is successful
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of the object |
   // //+------------------------------------------------------------------+
   // string CColumnCaption::Description(void)
   // {
   //    return(::StringFormat("%s: Column %u, Value: \"%s\"",
   //                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Column(),this.Value()));
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of an object |
   // //+------------------------------------------------------------------+
   // void CColumnCaption::Print(void)
   // {
   //    ::Print(this.Description());
   // }
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_CCOLUMNCAPTION_MQH   

#ifndef MOVE_TO_TABLEHEADER_MQH
#define MOVE_TO_TABLEHEADER_MQH
   //+------------------------------------------------------------------+
   // | Table header class |
   //+------------------------------------------------------------------+
   // class CTableHeader : public CObject
   // {
   // protected:
   //    CColumnCaption    m_caption_tmp;                         // Column header object to search in list
   //    CListObj          m_list_captions;                       // List of column headers
      
   // // --- Adds the specified header to the end of the list
   //    bool              AddNewColumnCaption(CColumnCaption *caption);
   // // --- Creates a table header from a string array
   //    void              CreateHeader(string &array[]);
   // // --- Sets the column position of all column headers
   //    void              ColumnPositionUpdate(void);
      
   // public:
   // // --- Creates a new title and adds it to the end of the list
   //    CColumnCaption   *CreateNewColumnCaption(const string caption);
      
   // // --- Returns (1) the header by index, (2) the number of column headers
   //    CColumnCaption   *GetColumnCaption(const uint index)        { return this.m_list_captions.GetNodeAtIndex(index);  }
   //    uint              ColumnsTotal(void)                  const { return this.m_list_captions.Total();                }
      
   // // --- Sets the value of the specified column header
   //    void              ColumnCaptionSetValue(const uint index,const string value);
      
   // // --- (1) Sets, (2) returns the data type for the specified column header
   //    void              ColumnCaptionSetDatatype(const uint index,const ENUM_DATATYPE type);
   //    ENUM_DATATYPE     ColumnCaptionDatatype(const uint index);
      
   // // --- (1) Removes (2) moves the column header
   //    bool              ColumnCaptionDelete(const uint index);
   //    bool              ColumnCaptionMoveTo(const uint caption_index, const uint index_to);
      
   // // --- Clears column header data
   //    void              ClearData(void);

   // // --- Clears the list of column headers
   //    void              Destroy(void)                             { this.m_list_captions.Clear();                       }

   // // --- (1) Returns, (2) logs a description of the object
   //    virtual string    Description(void);
   //    void              Print(const bool detail, const bool as_table=false, const int column_width=CELL_WIDTH_IN_CHARS);

   // // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //    virtual int       Compare(const CObject *node,const int mode=0)   const { return -1;            }
   //    virtual bool      Save(const int file_handle);
   //    virtual bool      Load(const int file_handle);
   //    virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_HEADER); }
      
   // // --- Constructors/destructor
   //                      CTableHeader(void) {}
   //                      CTableHeader(string &array[]) { this.CreateHeader(array);   }
   //                   ~CTableHeader(void){}
   // };
   // //+------------------------------------------------------------------+
   // // | Creates a new title and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CColumnCaption *CTableHeader::CreateNewColumnCaption(const string caption)
   // {
   // // --- Create a new header object
   //    CColumnCaption *caption_obj=new CColumnCaption(this.ColumnsTotal(),caption);
   //    if(caption_obj==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Failed to create new column caption at position %u",__FUNCTION__, this.ColumnsTotal());
   //       return NULL;
   //    }
   // // --- Add the created title to the end of the list
   //    if(!this.AddNewColumnCaption(caption_obj))
   //    {
   //       delete caption_obj;
   //       return NULL;
   //    }
   // // --- Return a pointer to the object
   //    return caption_obj;
   // }
   // //+------------------------------------------------------------------+
   // // | Adds a title to the end of the list |
   // //+------------------------------------------------------------------+
   // bool CTableHeader::AddNewColumnCaption(CColumnCaption *caption)
   // {
   // // --- If an empty object is passed, we report and return false
   //    if(caption==NULL)
   //    {
   //       ::PrintFormat("%s: Error. Empty CColumnCaption object passed",__FUNCTION__);
   //       return false;
   //    }
   // // --- Set the title index in the list and add the created title to the end of the list
   //    caption.SetColumn(this.ColumnsTotal());
   //    if(this.m_list_captions.Add(caption)==WRONG_VALUE)
   //    {
   //       ::PrintFormat("%s: Error. Failed to add caption (%u) to list",__FUNCTION__,this.ColumnsTotal());
   //       return false;
   //    }
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a table header from a string array |
   // //+------------------------------------------------------------------+
   // void CTableHeader::CreateHeader(string &array[])
   // {
   // // --- Get the number of table columns from the array properties
   //    uint total=array.Size();
   // // --- Looping through the array size
   // // --- create all the headers, adding each new one to the end of the list
   //    for(uint i=0; i<total; i++)
   //       this.CreateNewColumnCaption(array[i]);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the value to the specified column header |
   // //+------------------------------------------------------------------+
   // void CTableHeader::ColumnCaptionSetValue(const uint index,const string value)
   // {
   // // --- We get the desired header from the list and write a new value into it
   //    CColumnCaption *caption=this.GetColumnCaption(index);
   //    if(caption!=NULL)
   //       caption.SetValue(value);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the data type for the specified column header |
   // //+------------------------------------------------------------------+
   // void CTableHeader::ColumnCaptionSetDatatype(const uint index,const ENUM_DATATYPE type)
   // {
   // // --- We get the desired header from the list and write a new value into it
   //    CColumnCaption *caption=this.GetColumnCaption(index);
   //    if(caption!=NULL)
   //       caption.SetDatatype(type);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the data type of the specified column header |
   // //+------------------------------------------------------------------+
   // ENUM_DATATYPE CTableHeader::ColumnCaptionDatatype(const uint index)
   // {
   // // --- We get the desired header from the list and return the column data type from it
   //    CColumnCaption *caption=this.GetColumnCaption(index);
   //    return(caption!=NULL ? caption.Datatype() : (ENUM_DATATYPE)WRONG_VALUE);
   // }
   // //+------------------------------------------------------------------+
   // // | Removes the header of the specified column |
   // //+------------------------------------------------------------------+
   // bool CTableHeader::ColumnCaptionDelete(const uint index)
   // {
   // // --- Delete a title in the list by index
   //    if(!this.m_list_captions.Delete(index))
   //       return false;
   // // --- Update the indexes for the remaining titles in the list
   //    this.ColumnPositionUpdate();
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Moves the column header to the specified position |
   // //+------------------------------------------------------------------+
   // bool CTableHeader::ColumnCaptionMoveTo(const uint caption_index,const uint index_to)
   // {
   // // --- Get the desired title by index in the list, making it current
   //    CColumnCaption *caption=this.GetColumnCaption(caption_index);
   // // --- Move the current title to the specified position in the list
   //    if(caption==NULL || !this.m_list_captions.MoveToIndex(index_to))
   //       return false;
   // // --- Update the indexes of all titles in the list
   //    this.ColumnPositionUpdate();
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Sets column positions for all headers |
   // //+------------------------------------------------------------------+
   // void CTableHeader::ColumnPositionUpdate(void)
   // {
   // // --- Loop through all titles in the list
   //    for(int i=0;i<this.m_list_captions.Total();i++)
   //    {
   //       // --- get the next header and set the column index to it
   //       CColumnCaption *caption=this.GetColumnCaption(i);
   //       if(caption!=NULL)
   //          caption.SetColumn(this.m_list_captions.IndexOf(caption));
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Clears column header data in a list |
   // //+------------------------------------------------------------------+
   // void CTableHeader::ClearData(void)
   // {
   // // --- Loop through all titles in the list
   //    for(uint i=0;i<this.ColumnsTotal();i++)
   //    {
   //       // --- get the next header and set it to an empty value
   //       CColumnCaption *caption=this.GetColumnCaption(i);
   //       if(caption!=NULL)
   //          caption.ClearData();
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of the object |
   // //+------------------------------------------------------------------+
   // string CTableHeader::Description(void)
   // {
   //    return(::StringFormat("%s: Captions total: %u",
   //                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.ColumnsTotal()));
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of an object |
   // //+------------------------------------------------------------------+
   // void CTableHeader::Print(const bool detail, const bool as_table=false, const int column_width=CELL_WIDTH_IN_CHARS)
   // {
   // // --- Number of titles
   //    int total=(int)this.ColumnsTotal();
      
   // // --- If the output is in tabular form
   //    string res="";
   //    if(as_table)
   //    {
   //       // --- create a table row from the values ​​of all headers
   //       res="|";
   //       for(int i=0;i<total;i++)
   //       {
   //          CColumnCaption *caption=this.GetColumnCaption(i);
   //          if(caption==NULL)
   //             continue;
   //          res+=::StringFormat("%*s |",column_width,caption.Value());
   //       }
   //       // --- We output the line to the log and leave
   //       ::Print(res);
   //       return;
   //    }
      
   // // --- Output the title as a line description
   //    ::Print(this.Description()+(detail ? ":" : ""));
      
   // // --- If detailed description
   //    if(detail)
   //    {
   //       // --- In a loop through the list of row headers
   //       for(int i=0; i<total; i++)
   //       {
   //          // --- get the current title and add its description to the final line
   //          CColumnCaption *caption=this.GetColumnCaption(i);
   //          if(caption!=NULL)
   //             res+="  "+caption.Description()+(i<total-1 ? "\n" : "");
   //       }
   //       // --- Log the line created in the loop
   //       ::Print(res);
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Saving to file |
   // //+------------------------------------------------------------------+
   // bool CTableHeader::Save(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
   //       return(false);
   // // --- Save the object type
   //    if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
   //       return(false);

   // // --- Save the list of titles
   //    if(!this.m_list_captions.Save(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Loading from file |
   // //+------------------------------------------------------------------+
   // bool CTableHeader::Load(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //       return(false);
   // // --- Loading the object type
   //    if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //       return(false);

   // // --- Loading the list of titles
   //    if(!this.m_list_captions.Load(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_TABLEHEADER_MQH

#ifndef MOVE_TO_TABLE_MQH
#define MOVE_TO_TABLE_MQH
   //+------------------------------------------------------------------+
   // // | Table class |
   // //+------------------------------------------------------------------+
   // class CTable : public CObject 
   // {
   // private:
   // // --- Populates an Excel-style array of column headers
   //    bool              FillArrayExcelNames(const uint num_columns);
   // // --- Returns the column name as in Excel
   //    string            GetExcelColumnName(uint column_number);
   // // --- Returns header availability
   //    bool              HeaderCheck(void) const { return(this.m_table_header!=NULL && this.m_table_header.ColumnsTotal()>0);  }
      
   // protected:
   //    CTableModel      *m_table_model;                               // Pointer to table model
   //    CTableHeader     *m_table_header;                              // Pointer to table header
   //    CList             m_list_rows;                                 // List of parameter arrays from structure fields
   //    string            m_array_names[];                             // Column header array
   //    int               m_id;                                        // Table ID
   // // --- Copies an array of header names
   //    bool              ArrayNamesCopy(const string &column_names[],const uint columns_total);
      
   // public:
   // // --- (1) Sets, (2) returns the table model
   //    void              SetTableModel(CTableModel *table_model)      { this.m_table_model=table_model;      }
   //    CTableModel      *GetTableModel(void)                          { return this.m_table_model;           }
   // // --- (1) Sets, (2) returns header
   //    void              SetTableHeader(CTableHeader *table_header)   { this.m_table_header=m_table_header;  }
   //    CTableHeader     *GetTableHeader(void)                         { return this.m_table_header;          }

   // // --- (1) Sets, (2) returns the table identifier
   //    void              SetID(const int id)                          { this.m_id=id;                        }
   //    int               ID(void)                               const { return this.m_id;                    }
      
   // // --- Clears column header data
   //    void              HeaderClearData(void)
   //                      {
   //                         if(this.m_table_header!=NULL)
   //                            this.m_table_header.ClearData();
   //                      }
   // // --- Removes the table header
   //    void              HeaderDestroy(void)
   //                      {
   //                         if(this.m_table_header==NULL)
   //                            return;
   //                         this.m_table_header.Destroy();
   //                         this.m_table_header=NULL;
   //                      }
                        
   // // --- (1) Clears all data, (2) destroys table model and header
   //    void              ClearData(void)
   //                      {
   //                         if(this.m_table_model!=NULL)
   //                            this.m_table_model.ClearData();
   //                      }
   //    void              Destroy(void)
   //                      {
   //                         if(this.m_table_model==NULL)
   //                            return;
   //                         this.m_table_model.Destroy();
   //                         this.m_table_model=NULL;
   //                      }
      
   // // --- Returns (1) title, (2) cell, (3) row by index, number of (4) rows, (5) columns, cells (6) in the specified row, (7) in the table
   //    CColumnCaption   *GetColumnCaption(const uint index)        { return(this.m_table_header!=NULL  ?  this.m_table_header.GetColumnCaption(index)  :  NULL);   }
   //    CTableCell       *GetCell(const uint row, const uint col)   { return(this.m_table_model!=NULL   ?  this.m_table_model.GetCell(row,col)          :  NULL);   }
   //    CTableRow        *GetRow(const uint index)                  { return(this.m_table_model!=NULL   ?  this.m_table_model.GetRow(index)             :  NULL);   }
   //    uint              RowsTotal(void)                     const { return(this.m_table_model!=NULL   ?  this.m_table_model.RowsTotal()               :  0);      }
   //    uint              ColumnsTotal(void)                  const { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsInRow(0)             :  0);      }
   //    uint              CellsInRow(const uint index)              { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsInRow(index)         :  0);      }
   //    uint              CellsTotal(void)                          { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsTotal()              :  0);      }

   // // --- Sets (1) value, (2) precision, (3) time display flags, (4) color name display flag to specified cell
   // template<typename T>
   //    void              CellSetValue(const uint row, const uint col, const T value);
   //    void              CellSetDigits(const uint row, const uint col, const int digits);
   //    void              CellSetTimeFlags(const uint row, const uint col, const uint flags);
   //    void              CellSetColorNamesFlag(const uint row, const uint col, const bool flag);
   // // --- (1) Assigns, (2) cancels an object in a cell
   //    void              CellAssignObject(const uint row, const uint col,CObject *object);
   //    void              CellUnassignObject(const uint row, const uint col);
   // // --- Returns the string value of the specified cell
   //    virtual string    CellValueAt(const uint row, const uint col);

   // protected:
   // // --- (1) Deletes (2) moves a cell
   //    bool              CellDelete(const uint row, const uint col);
   //    bool              CellMoveTo(const uint row, const uint cell_index, const uint index_to);
      
   // public:
   // // --- (1) Returns, (2) logs the description of the cell, (3) the object assigned to the cell
   //    string            CellDescription(const uint row, const uint col);
   //    void              CellPrint(const uint row, const uint col);
   // // ---Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
   //    CObject          *CellGetObject(const uint row, const uint col);
   //    ENUM_OBJECT_TYPE  CellGetObjType(const uint row, const uint col);
      
   // // --- Creates a new line and (1) appends it to the end of the list, (2) inserts it at the specified position in the list
   //    CTableRow        *RowAddNew(void);
   //    CTableRow        *RowInsertNewTo(const uint index_to);
   // // --- (1) Deletes (2) moves a row, (3) clears row data
   //    bool              RowDelete(const uint index);
   //    bool              RowMoveTo(const uint row_index, const uint index_to);
   //    void              RowClearData(const uint index);
   // // --- (1) Returns, (2) logs the description of the string
   //    string            RowDescription(const uint index);
   //    void              RowPrint(const uint index,const bool detail);
      
   // // --- (1) Add new, (2) delete, (3) move column, (4) clear column data
   //    bool              ColumnAddNew(const string caption,const int index=-1);
   //    bool              ColumnDelete(const uint index);
   //    bool              ColumnMoveTo(const uint index, const uint index_to);
   //    void              ColumnClearData(const uint index);
      
   // // --- Sets (1) the value of the specified header, (2) the accuracy of the data,
   // // --- flags for displaying (3) time, (4) color names to the specified column
   //    void              ColumnCaptionSetValue(const uint index,const string value);
   //    void              ColumnSetDigits(const uint index,const int digits);
   //    void              ColumnSetTimeFlags(const uint index,const uint flags);
   //    void              ColumnSetColorNamesFlag(const uint col, const bool flag);
      
   // // --- (1) Sets, (2) returns the data type for the specified column
   //    void              ColumnSetDatatype(const uint index,const ENUM_DATATYPE type);
   //    ENUM_DATATYPE     ColumnDatatype(const uint index);
      
   // // --- (1) Returns, (2) logs a description of the object
   //    virtual string    Description(void);
   //    void              Print(const int column_width=CELL_WIDTH_IN_CHARS);
   
   // // --- Sorts the table by the specified column and direction
   //    void              SortByColumn(const uint column, const bool descending)
   //                      {
   //                         if(this.m_table_model!=NULL)
   //                            this.m_table_model.SortByColumn(column,descending);
   //                      }
      
   // // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //    virtual int       Compare(const CObject *node,const int mode=0) const;
   //    virtual bool      Save(const int file_handle);
   //    virtual bool      Load(const int file_handle);
   //    virtual int       Type(void)                             const { return(OBJECT_TYPE_TABLE);           }
      
   // // --- Constructors/destructor
   //                      CTable(void) : m_table_model(NULL), m_table_header(NULL) { this.m_list_rows.Clear();}
   // template<typename T> CTable(T &row_data[][],const string &column_names[]);
   //                      CTable(const uint num_rows, const uint num_columns);
   //                      CTable(const matrix &row_data,const string &column_names[]);
   //                   ~CTable (void);
   // };
   // //+-------------------------------------------------------------------+
   // // | Constructor specifying a table array and an array of headers.     |
   // // | Determines the number and names of columns according to column_names|
   // // | The number of rows is determined by the size of the data array row_data, |
   // // | which is also used to fill out the table |
   // //+-------------------------------------------------------------------+
   // template<typename T>
   // CTable::CTable(T &row_data[][],const string &column_names[]) : m_id(-1)
   // {
   //    this.m_table_model=new CTableModel(row_data);
   //    if(column_names.Size()>0)
   //       this.ArrayNamesCopy(column_names,row_data.Range(1));
   //    else
   //    {
   //       ::PrintFormat("%s: An empty array names was passed. The header array will be filled in Excel style (A, B, C)",__FUNCTION__);
   //       this.FillArrayExcelNames((uint)::ArrayRange(row_data,1));
   //    }
   //    this.m_table_header=new CTableHeader(this.m_array_names);
   // }
   // //+------------------------------------------------------------------+
   // // | Table constructor with determination of the number of columns and rows.   |
   // // | The columns will have Excel names "A", "B", "C", etc.      |
   // //+------------------------------------------------------------------+
   // CTable::CTable(const uint num_rows,const uint num_columns) : m_table_header(NULL), m_id(-1)
   // {
   //    this.m_table_model=new CTableModel(num_rows,num_columns);
   //    if(this.FillArrayExcelNames(num_columns))
   //       this.m_table_header=new CTableHeader(this.m_array_names);
   // }
   // //+-------------------------------------------------------------------+
   // // | Table constructor with columns initialized according to column_names|
   // // | The number of rows is determined by the row_data parameter, with type matrix |
   // //+-------------------------------------------------------------------+
   // CTable::CTable(const matrix &row_data,const string &column_names[]) : m_id(-1)
   // {
   //    this.m_table_model=new CTableModel(row_data);
   //    if(column_names.Size()>0)
   //       this.ArrayNamesCopy(column_names,(uint)row_data.Cols());
   //    else
   //    {
   //       ::PrintFormat("%s: An empty array names was passed. The header array will be filled in Excel style (A, B, C)",__FUNCTION__);
   //       this.FillArrayExcelNames((uint)row_data.Cols());
   //    }
   //    this.m_table_header=new CTableHeader(this.m_array_names);
   // }
   // //+------------------------------------------------------------------+
   // // | Destructor |
   // //+------------------------------------------------------------------+
   // CTable::~CTable(void)
   // {
   //    if(this.m_table_model!=NULL)
   //    {
   //       this.m_table_model.Destroy();
   //       delete this.m_table_model;
   //    }
   //    if(this.m_table_header!=NULL)
   //    {
   //       this.m_table_header.Destroy();
   //       delete this.m_table_header;
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Comparison of two objects |
   // //+------------------------------------------------------------------+
   // int CTable::Compare(const CObject *node,const int mode=0) const
   // {
   //    if(node==NULL)
   //       return -1;
   //    const CTable *obj=node;
   //    return(this.ID()>obj.ID() ? 1 : this.ID()<obj.ID() ? -1 : 0);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the column name as in Excel |
   // //+------------------------------------------------------------------+
   // string CTable::GetExcelColumnName(uint column_number)
   // {
   //    string column_name="";
   //    uint index=column_number;

   // // --- Check that the column number is greater than 0
   //    if(index==0)
   //       return (__FUNCTION__+": Error. Invalid column number passed");
      
   // // --- Convert number to column name
   //    while(!::IsStopped() && index>0)
   //    {
   //       index--;                                           // Decrease the number by 1 to make it 0-index
   //       uint  remainder =index % 26;                       // Remainder of division by 26
   //       uchar char_code ='A'+(uchar)remainder;             // Calculate the code of a character (letter)
   //       column_name=::CharToString(char_code)+column_name; // Add a letter to the beginning of the line
   //       index/=26;                                         // Let's move on to the next level
   //    }
   //    return column_name;
   // }
   // //+------------------------------------------------------------------+
   // // | Fills an array of column headers in Excel style |
   // //+------------------------------------------------------------------+
   // bool CTable::FillArrayExcelNames(const uint num_columns)
   // {
   //    ::ResetLastError();
   //    if(::ArrayResize(this.m_array_names,num_columns,num_columns)!=num_columns)
   //    {
   //       ::PrintFormat("%s: ArrayResize() failed. Error %d",__FUNCTION__,::GetLastError());
   //       return false;
   //    }
   //    for(int i=0;i<(int)num_columns;i++)
   //       this.m_array_names[i]=this.GetExcelColumnName(i+1);

   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Copies an array of header names |
   // //+------------------------------------------------------------------+
   // bool CTable::ArrayNamesCopy(const string &column_names[],const uint columns_total)
   // {
   //    if(columns_total==0)
   //    {
   //       ::PrintFormat("%s: Error. The table has no columns",__FUNCTION__);
   //       return false;
   //    }
   //    if(columns_total>column_names.Size())
   //    {
   //       ::PrintFormat("%s: The number of header names is less than the number of columns. The header array will be filled in Excel style (A, B, C)",__FUNCTION__);
   //       return this.FillArrayExcelNames(columns_total);
   //    }
   //    uint total=::fmin(columns_total,column_names.Size());
   //    return(::ArrayCopy(this.m_array_names,column_names,0,0,total)==total);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the value to the specified cell |
   // //+------------------------------------------------------------------+
   // template<typename T>
   // void CTable::CellSetValue(const uint row, const uint col, const T value)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.CellSetValue(row,col,value);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the precision to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTable::CellSetDigits(const uint row, const uint col, const int digits)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.CellSetDigits(row,col,digits);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets time display flags to the specified cell |
   // //+------------------------------------------------------------------+
   // void CTable::CellSetTimeFlags(const uint row, const uint col, const uint flags)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.CellSetTimeFlags(row,col,flags);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the flag to display color names in the specified cell |
   // //+------------------------------------------------------------------+
   // void CTable::CellSetColorNamesFlag(const uint row, const uint col, const bool flag)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.CellSetColorNamesFlag(row,col,flag);
   // }
   // //+------------------------------------------------------------------+
   // // | Assigns an object to a cell |
   // //+------------------------------------------------------------------+
   // void CTable::CellAssignObject(const uint row, const uint col,CObject *object)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.CellAssignObject(row,col,object);
   // }
   // //+------------------------------------------------------------------+
   // // | Undoes an object in a cell |
   // //+------------------------------------------------------------------+
   // void CTable::CellUnassignObject(const uint row, const uint col)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.CellUnassignObject(row,col);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the string value of the specified cell |
   // //+------------------------------------------------------------------+
   // string CTable::CellValueAt(const uint row,const uint col)
   // {
   //    CTableCell *cell=this.GetCell(row,col);
   //    return(cell!=NULL ? cell.Value() : "");
   // }
   // //+------------------------------------------------------------------+
   // // | Deletes a cell |
   // //+------------------------------------------------------------------+
   // bool CTable::CellDelete(const uint row, const uint col)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.CellDelete(row,col) : false);
   // }
   // //+------------------------------------------------------------------+
   // // | Moves a cell |
   // //+------------------------------------------------------------------+
   // bool CTable::CellMoveTo(const uint row, const uint cell_index, const uint index_to)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.CellMoveTo(row,cell_index,index_to) : false);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the object assigned to the cell |
   // //+------------------------------------------------------------------+
   // CObject *CTable::CellGetObject(const uint row, const uint col)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.CellGetObject(row,col) : NULL);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the type of the object assigned to the cell |
   // //+------------------------------------------------------------------+
   // ENUM_OBJECT_TYPE CTable::CellGetObjType(const uint row,const uint col)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.CellGetObjType(row,col) : (ENUM_OBJECT_TYPE)WRONG_VALUE);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns cell description |
   // //+------------------------------------------------------------------+
   // string CTable::CellDescription(const uint row, const uint col)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.CellDescription(row,col) : "");
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a cell description |
   // //+------------------------------------------------------------------+
   // void CTable::CellPrint(const uint row, const uint col)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.CellPrint(row,col);
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new line and adds it to the end of the list |
   // //+------------------------------------------------------------------+
   // CTableRow *CTable::RowAddNew(void)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.RowAddNew() : NULL);
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new line and inserts it into the specified list position |
   // //+------------------------------------------------------------------+
   // CTableRow *CTable::RowInsertNewTo(const uint index_to)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.RowInsertNewTo(index_to) : NULL);
   // }
   // //+------------------------------------------------------------------+
   // // | Deletes a line |
   // //+------------------------------------------------------------------+
   // bool CTable::RowDelete(const uint index)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.RowDelete(index) : false);
   // }
   // //+------------------------------------------------------------------+
   // // | Moves line |
   // //+------------------------------------------------------------------+
   // bool CTable::RowMoveTo(const uint row_index, const uint index_to)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.RowMoveTo(row_index,index_to) : false);
   // }
   // //+------------------------------------------------------------------+
   // // | Clears row data |
   // //+------------------------------------------------------------------+
   // void CTable::RowClearData(const uint index)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.RowClearData(index);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of a string |
   // //+------------------------------------------------------------------+
   // string CTable::RowDescription(const uint index)
   // {
   //    return(this.m_table_model!=NULL ? this.m_table_model.RowDescription(index) : "");
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of a string |
   // //+------------------------------------------------------------------+
   // void CTable::RowPrint(const uint index,const bool detail)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.RowPrint(index,detail);
   // }
   // //+------------------------------------------------------------------+
   // // | Creates a new column and adds it to the specified table position|
   // //+------------------------------------------------------------------+
   // bool CTable::ColumnAddNew(const string caption,const int index=-1)
   // {
   // // --- If there is no table model, or there is an error adding a new column to the model, return false
   //    if(this.m_table_model==NULL || !this.m_table_model.ColumnAddNew(index))
   //       return false;
   // // --- If there is no header, return true (the column was added without a header)
   //    if(this.m_table_header==NULL)
   //       return true;
      
   // // --- Check the creation of a new column header and, if not created, return false
   //    CColumnCaption *caption_obj=this.m_table_header.CreateNewColumnCaption(caption);
   //    if(caption_obj==NULL)
   //       return false;
   // // --- If a non-negative index is passed, we return the result of moving the header to the specified index
   // // --- Otherwise, everything is already ready - just return true
   //    return(index>-1 ? this.m_table_header.ColumnCaptionMoveTo(caption_obj.Column(),index) : true);
   // }
   // //+------------------------------------------------------------------+
   // // | Removes a column |
   // //+------------------------------------------------------------------+
   // bool CTable::ColumnDelete(const uint index)
   // {
   //    if(!this.HeaderCheck() || !this.m_table_header.ColumnCaptionDelete(index))
   //       return false;
   //    return this.m_table_model.ColumnDelete(index);
   // }
   // //+------------------------------------------------------------------+
   // // | Moves column |
   // //+------------------------------------------------------------------+
   // bool CTable::ColumnMoveTo(const uint index, const uint index_to)
   // {
   //    if(!this.HeaderCheck() || !this.m_table_header.ColumnCaptionMoveTo(index,index_to))
   //       return false;
   //    return this.m_table_model.ColumnMoveTo(index,index_to);
   // }
   // //+------------------------------------------------------------------+
   // // | Clears column data |
   // //+------------------------------------------------------------------+
   // void CTable::ColumnClearData(const uint index)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.ColumnClearData(index);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the value to the specified header |
   // //+------------------------------------------------------------------+
   // void CTable::ColumnCaptionSetValue(const uint index,const string value)
   // {
   //    CColumnCaption *caption=this.m_table_header.GetColumnCaption(index);
   //    if(caption!=NULL)
   //       caption.SetValue(value);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the data type for the specified column |
   // //+------------------------------------------------------------------+
   // void CTable::ColumnSetDatatype(const uint index,const ENUM_DATATYPE type)
   // {
   // // --- If there is a table model, set the data type for the column
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.ColumnSetDatatype(index,type);
   // // --- If there is a header, set the data type for the header
   //    if(this.m_table_header!=NULL)
   //       this.m_table_header.ColumnCaptionSetDatatype(index,type);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the data precision of the specified column |
   // //+------------------------------------------------------------------+
   // void CTable::ColumnSetDigits(const uint index,const int digits)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.ColumnSetDigits(index,digits);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the time display flags for the specified column |
   // //+------------------------------------------------------------------+
   // void CTable::ColumnSetTimeFlags(const uint index,const uint flags)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.ColumnSetTimeFlags(index,flags);
   // }
   // //+------------------------------------------------------------------+
   // // | Sets the color name display flags for the specified column |
   // //+------------------------------------------------------------------+
   // void CTable::ColumnSetColorNamesFlag(const uint index,const bool flag)
   // {
   //    if(this.m_table_model!=NULL)
   //       this.m_table_model.ColumnSetColorNamesFlag(index,flag);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the data type for the specified column |
   // //+------------------------------------------------------------------+
   // ENUM_DATATYPE CTable::ColumnDatatype(const uint index)
   // {
   //    return(this.m_table_header!=NULL ? this.m_table_header.ColumnCaptionDatatype(index) : (ENUM_DATATYPE)WRONG_VALUE);
   // }
   // //+------------------------------------------------------------------+
   // // | Returns the description of the object |
   // //+------------------------------------------------------------------+
   // string CTable::Description(void)
   // {
   //    return(::StringFormat("%s: Rows total: %u, Columns total: %u",
   //                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.RowsTotal(),this.ColumnsTotal()));
   // }
   // //+------------------------------------------------------------------+
   // // | Logs a description of an object |
   // //+------------------------------------------------------------------+
   // void CTable::Print(const int column_width=CELL_WIDTH_IN_CHARS)
   // {
   //    if(this.HeaderCheck())
   //    {
   //       // --- Output the title as a line description
   //       ::Print(this.Description()+":");
         
   //       // --- Number of titles
   //       int total=(int)this.ColumnsTotal();
         
   //       string res="";
   //       // --- create a row from the values ​​of all table column headers
   //       res="|";
   //       for(int i=0;i<total;i++)
   //       {
   //          CColumnCaption *caption=this.GetColumnCaption(i);
   //          if(caption==NULL)
   //             continue;
   //          res+=::StringFormat("%*s |",column_width,caption.Value());
   //       }
   //       // --- We supplement the line on the left with a heading
   //       string hd="|";
   //       hd+=::StringFormat("%*s ",column_width,"n/n");
   //       res=hd+res;
   //       // --- Output the header line to the log
   //       ::Print(res);
   //    }
      
   // // --- Let's loop through all the rows of the table and print them in tabular form
   //    for(uint i=0;i<this.RowsTotal();i++)
   //    {
   //       CTableRow *row=this.GetRow(i);
   //       if(row!=NULL)
   //       {
   //          // --- create a table row from the values ​​of all cells
   //          string head=" "+(string)row.Index();
   //          string res=::StringFormat("|%-*s |",column_width,head);
   //          for(int i=0;i<(int)row.CellsTotal();i++)
   //          {
   //             CTableCell *cell=row.GetCell(i);
   //             if(cell==NULL)
   //                continue;
   //             res+=::StringFormat("%*s |",column_width,cell.Value());
   //          }
   //          // --- Output the line to the log
   //          ::Print(res);
   //       }
   //    }
   // }
   // //+------------------------------------------------------------------+
   // // | Saving to file |
   // //+------------------------------------------------------------------+
   // bool CTable::Save(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
   //       return(false);
   // // --- Save the object type
   //    if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
   //       return(false);
         
   // // --- Save the ID
   //    if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
   //       return(false);
   // // --- Checking the table model
   //    if(this.m_table_model==NULL)
   //       return false;
   // // --- Save the table model
   //    if(!this.m_table_model.Save(file_handle))
   //       return(false);

   // // --- Checking the table header
   //    if(this.m_table_header==NULL)
   //       return false;
   // // --- Save the table header
   //    if(!this.m_table_header.Save(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
   // // | Loading from file |
   // //+------------------------------------------------------------------+
   // bool CTable::Load(const int file_handle)
   // {
   // // --- Checking the handle
   //    if(file_handle==INVALID_HANDLE)
   //       return(false);
   // // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   //    if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //       return(false);
   // // --- Loading the object type
   //    if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //       return(false);

   // // --- Loading ID
   //    this.m_id=::FileReadInteger(file_handle,INT_VALUE);
   // // --- Checking the table model
   //    if(this.m_table_model==NULL && (this.m_table_model=new CTableModel())==NULL)
   //       return(false);
   // // --- Loading the table model
   //    if(!this.m_table_model.Load(file_handle))
   //       return(false);

   // // --- Checking the table header
   //    if(this.m_table_header==NULL && (this.m_table_header=new CTableHeader())==NULL)
   //       return false;
   // // --- Load the table header
   //    if(!this.m_table_header.Load(file_handle))
   //       return(false);
      
   // // --- Successfully
   //    return true;
   // }
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_TABLE_MQH

#ifndef MOVE_TO_TABLEBYPARAM_MQH
#define MOVE_TO_TABLEBYPARAM_MQH
   //+------------------------------------------------------------------+
   // | Class for creating tables based on an array of parameters |
   //+------------------------------------------------------------------+
   // class CTableByParam : public CTable
   // {
   // public:
   //    virtual int       Type(void)     const { return(OBJECT_TYPE_TABLE_BY_PARAM);  }
   // // --- Constructor/destructor
   //                      CTableByParam(void)  { this.m_list_rows.Clear();            }
   //                      CTableByParam(CList &row_data,const string &column_names[]);
   //                   ~CTableByParam(void) {}
   // };
   // //+------------------------------------------------------------------+
   // // | Constructor specifying a table array based on the list row_data|
   // // | containing objects with structure field data.                   |
   // // | Determines the number and names of columns according to the quantity |
   // // | column names in the column_names array |
   // //+------------------------------------------------------------------+
   // CTableByParam::CTableByParam(CList &row_data,const string &column_names[])
   // {
   // // --- Copy the passed list of data into a variable and
   // // --- create a table model based on this list
   //    this.m_list_rows=row_data;
   //    this.m_table_model=new CTableModel(this.m_list_rows);
      
   // // --- Copy the passed list of headers to m_array_names and
   // // --- create a table header based on this list
   //    this.ArrayNamesCopy(column_names,column_names.Size());
   //    this.m_table_header=new CTableHeader(this.m_array_names);
   // }
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_TABLEBYPARAM_MQH



