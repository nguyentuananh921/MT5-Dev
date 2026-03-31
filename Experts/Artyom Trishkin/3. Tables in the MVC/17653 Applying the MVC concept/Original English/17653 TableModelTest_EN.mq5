//+------------------------------------------------------------------+
//|                                               TableModelTest.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>

// --- Forward declaration of classes
class CTableCell;                   // Table cell class
class CTableRow;                    // Table row class
class CTableModel;                  // Table model class

//+------------------------------------------------------------------+
// | Macros |
//+------------------------------------------------------------------+
#define  MARKER_START_DATA    -1    // Marker for the start of data in a file
#define  MAX_STRING_LENGTH    128   // Maximum length of a string in a cell

//+------------------------------------------------------------------+
// | Transfers |
//+------------------------------------------------------------------+
enum ENUM_OBJECT_TYPE               // Enumerating Object Types
  {
   OBJECT_TYPE_TABLE_CELL=10000,    // Table cell
   OBJECT_TYPE_TABLE_ROW,           // Table row
   OBJECT_TYPE_TABLE_MODEL,         // Table model
  };
  
enum ENUM_CELL_COMPARE_MODE         // Table cell comparison modes
  {
   CELL_COMPARE_MODE_COL,           // Comparison by column number
   CELL_COMPARE_MODE_ROW,           // Comparison by line number
   CELL_COMPARE_MODE_ROW_COL,       // Comparison by row and column
  };
  
//+------------------------------------------------------------------+
// | Functions |
//+------------------------------------------------------------------+
// --- Returns the object type as a string
string TypeDescription(const ENUM_OBJECT_TYPE type)
  {
   string array[];
   int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);
   string result="";
   for(int i=2;i<total;i++)
     {
      array[i]+=" ";
      array[i].Lower();
      array[i].SetChar(0,ushort(array[i].GetChar(0)-0x20));
      result+=array[i];
     }
   result.TrimLeft();
   result.TrimRight();
   return result;
  }
//+------------------------------------------------------------------+
// | Classes |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Linked List Object Class |
//+------------------------------------------------------------------+
class CListObj : public CList
  {
protected:
   ENUM_OBJECT_TYPE  m_element_type;   // The type of the object being created in CreateElement()
public:
// --- Virtual method (1) loading a list from a file, (2) creating a list element
   virtual bool      Load(const int file_handle);
   virtual CObject  *CreateElement(void);
  };
//+------------------------------------------------------------------+
// | Loading a list from a file |
//+------------------------------------------------------------------+
bool CListObj::Load(const int file_handle)
  {
// --- Variables
   CObject *node;
   bool     result=true;
// --- Checking the handle
   if(file_handle==INVALID_HANDLE)
      return(false);
// --- Loading and checking the list start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);
// --- Loading and checking list type
   if(::FileReadInteger(file_handle,INT_VALUE)!=Type())
      return(false);
// --- Read list size (number of objects)
   uint num=::FileReadInteger(file_handle,INT_VALUE);
   
// --- We sequentially re-create the list elements by calling the Load() method of node objects
   this.Clear();
   for(uint i=0; i<num; i++)
     {
      // --- Read and check the object data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileReadLong(file_handle)!=MARKER_START_DATA)
         return false;
      // --- Read the object type
      this.m_element_type=(ENUM_OBJECT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
      node=this.CreateElement();
      if(node==NULL)
         return false;
      this.Add(node);
      // --- Now the file pointer is offset relative to the beginning of the object marker by 12 bytes (8 - marker, 4 - type)
      // --- Let's place a pointer to the beginning of the object's data and load the object's properties from the file using the Load() method of the node element.
      if(!::FileSeek(file_handle,-12,SEEK_CUR))
         return false;
      result &=node.Load(file_handle);
     }
// --- Result
   return result;
  }
//+------------------------------------------------------------------+
// | List item creation method |
//+------------------------------------------------------------------+
CObject *CListObj::CreateElement(void)
  {
// --- Depending on the object type in m_element_type, create a new object
   switch(this.m_element_type)
     {
      case OBJECT_TYPE_TABLE_CELL   :  return new CTableCell();
      case OBJECT_TYPE_TABLE_ROW    :  return new CTableRow();
      case OBJECT_TYPE_TABLE_MODEL  :  return new CTableModel();
      default                       :  return NULL;
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Table cell class |
//+------------------------------------------------------------------+
class CTableCell : public CObject
  {
protected:
// --- Union for storing cell values ​​(double, long, string)
   union DataType
     {
      protected:
      double         double_value;
      long           long_value;
      ushort         ushort_value[MAX_STRING_LENGTH];

      public:
      // --- Setting values
      void           SetValueD(const double value) { this.double_value=value;                   }
      void           SetValueL(const long value)   { this.long_value=value;                     }
      void           SetValueS(const string value) { ::StringToShortArray(value,ushort_value);  }
      
      // --- Return values
      double         ValueD(void) const { return this.double_value; }
      long           ValueL(void) const { return this.long_value; }
      string         ValueS(void) const
                       {
                        string res=::ShortArrayToString(this.ushort_value);
                        res.TrimLeft();
                        res.TrimRight();
                        return res;
                       }
     };
// --- Variables
   DataType          m_datatype_value;                      // Meaning
   ENUM_DATATYPE     m_datatype;                            // Data type
   CObject          *m_object;                              // Object in cell
   ENUM_OBJECT_TYPE  m_object_type;                         // Type of object in cell
   int               m_row;                                 // Line number
   int               m_col;                                 // Column number
   int               m_digits;                              // Data accuracy
   uint              m_time_flags;                          // Date/Time Display Flags
   bool              m_color_flag;                          // Color name display flag
   bool              m_editable;                            // Editable cell flag
   
public:
// --- Returning coordinates and cell properties
   uint              Row(void)                           const { return this.m_row;                            }
   uint              Col(void)                           const { return this.m_col;                            }
   ENUM_DATATYPE     Datatype(void)                      const { return this.m_datatype;                       }
   int               Digits(void)                        const { return this.m_digits;                         }
   uint              DatetimeFlags(void)                 const { return this.m_time_flags;                     }
   bool              ColorNameFlag(void)                 const { return this.m_color_flag;                     }
   bool              IsEditable(void)                    const { return this.m_editable;                       }
// --- Returns (1) double, (2) long, (3) string value
   double            ValueD(void)                        const { return this.m_datatype_value.ValueD();        }
   long              ValueL(void)                        const { return this.m_datatype_value.ValueL();        }
   string            ValueS(void)                        const { return this.m_datatype_value.ValueS();        }
// --- Returns the value as a formatted string
   string            Value(void) const
                       {
                        switch(this.m_datatype)
                          {
                           case TYPE_DOUBLE  :  return(::DoubleToString(this.ValueD(),this.Digits()));
                           case TYPE_LONG    :  return(::IntegerToString(this.ValueL()));
                           case TYPE_DATETIME:  return(::TimeToString(this.ValueL(),this.m_time_flags));
                           case TYPE_COLOR   :  return(::ColorToString((color)this.ValueL(),this.m_color_flag));
                           default           :  return this.ValueS();
                          }
                       }
   string            DatatypeDescription(void) const
                       {
                        string type=::StringSubstr(::EnumToString(this.m_datatype),5);
                        type.Lower();
                        return type;
                       }
// --- Setting variable values
   void              SetRow(const uint row)                    { this.m_row=(int)row;                          }
   void              SetCol(const uint col)                    { this.m_col=(int)col;                          }
   void              SetDatatype(const ENUM_DATATYPE datatype) { this.m_datatype=datatype;                     }
   void              SetDigits(const int digits)               { this.m_digits=digits;                         }
   void              SetDatetimeFlags(const uint flags)        { this.m_time_flags=flags;                      }
   void              SetColorNameFlag(const bool flag)         { this.m_color_flag=flag;                       }
   void              SetEditable(const bool flag)              { this.m_editable=flag;                         }
   void              SetPositionInTable(const uint row,const uint col)
                       {
                        this.SetRow(row);
                        this.SetCol(col);
                       }
// --- Assigns an object to a cell
   void              AssignObject(CObject *object)
                       {
                        if(object==NULL)
                          {
                           ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
                           return;
                          }
                        this.m_object=object;
                        this.m_object_type=(ENUM_OBJECT_TYPE)object.Type();
                       }
// --- Unassigns an object
   void              UnassignObject(void)
                       {
                        this.m_object=NULL;
                        this.m_object_type=-1;
                       }
                       
// --- Sets a double value
   void              SetValue(const double value)
                       {
                        this.m_datatype=TYPE_DOUBLE;
                        if(this.m_editable)
                           this.m_datatype_value.SetValueD(value);
                       }
// --- Sets a long value
   void              SetValue(const long value)
                       {
                        this.m_datatype=TYPE_LONG;
                        if(this.m_editable)
                           this.m_datatype_value.SetValueL(value);
                       }
// --- Sets the datetime value
   void              SetValue(const datetime value)
                       {
                        this.m_datatype=TYPE_DATETIME;
                        if(this.m_editable)
                           this.m_datatype_value.SetValueL(value);
                       }
// --- Sets the color value
   void              SetValue(const color value)
                       {
                        this.m_datatype=TYPE_COLOR;
                        if(this.m_editable)
                           this.m_datatype_value.SetValueL(value);
                       }
// --- Sets the string value
   void              SetValue(const string value)
                       {
                        this.m_datatype=TYPE_STRING;
                        if(this.m_editable)
                           this.m_datatype_value.SetValueS(value);
                       }
// --- Clears data
   void              ClearData(void)
                       {
                        if(this.Datatype()==TYPE_STRING)
                           this.SetValue("");
                        else
                           this.SetValue(0.0);
                       }
// --- (1) Returns, (2) logs a description of the object
   string            Description(void);
   void              Print(void);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_CELL);}
   
   
// --- Constructors/destructor
                     CTableCell(void) : m_row(0), m_col(0), m_datatype(-1), m_digits(0), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
                       {
                        this.m_datatype_value.SetValueD(0);
                       }
                     // --- Accepts a double value
                     CTableCell(const uint row,const uint col,const double value,const int digits) :
                        m_row((int)row), m_col((int)col), m_datatype(TYPE_DOUBLE), m_digits(digits), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
                       {
                        this.m_datatype_value.SetValueD(value);
                       }
                     // --- Accepts a long value
                     CTableCell(const uint row,const uint col,const long value) :
                        m_row((int)row), m_col((int)col), m_datatype(TYPE_LONG), m_digits(0), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
                       {
                        this.m_datatype_value.SetValueL(value);
                       }
                     // --- Accepts a datetime value
                     CTableCell(const uint row,const uint col,const datetime value,const uint time_flags) :
                        m_row((int)row), m_col((int)col), m_datatype(TYPE_DATETIME), m_digits(0), m_time_flags(time_flags), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
                       {
                        this.m_datatype_value.SetValueL(value);
                       }
                     // --- Accepts a color value
                     CTableCell(const uint row,const uint col,const color value,const bool color_names_flag) :
                        m_row((int)row), m_col((int)col), m_datatype(TYPE_COLOR), m_digits(0), m_time_flags(0), m_color_flag(color_names_flag), m_editable(true), m_object(NULL), m_object_type(-1)
                       {
                        this.m_datatype_value.SetValueL(value);
                       }
                     // --- Accepts a string value
                     CTableCell(const uint row,const uint col,const string value) :
                        m_row((int)row), m_col((int)col), m_datatype(TYPE_STRING), m_digits(0), m_time_flags(0), m_color_flag(false), m_editable(true), m_object(NULL), m_object_type(-1)
                       {
                        this.m_datatype_value.SetValueS(value);
                       }
                    ~CTableCell(void) {}
  };
//+------------------------------------------------------------------+
// | Comparison of two objects |
//+------------------------------------------------------------------+
int CTableCell::Compare(const CObject *node,const int mode=0) const
  {
   const CTableCell *obj=node;
   switch(mode)
     {
      case CELL_COMPARE_MODE_COL :  return(this.Col()>obj.Col() ? 1 : this.Col()<obj.Col() ? -1 : 0);
      case CELL_COMPARE_MODE_ROW :  return(this.Row()>obj.Row() ? 1 : this.Row()<obj.Row() ? -1 : 0);
      //---CELL_COMPARE_MODE_ROW_COL
      default                    :  return
                                      (
                                       this.Row()>obj.Row() ? 1 : this.Row()<obj.Row() ? -1 :
                                       this.Col()>obj.Col() ? 1 : this.Col()<obj.Col() ? -1 : 0
                                      );
     }
  }
//+------------------------------------------------------------------+
// | Saving to file |
//+------------------------------------------------------------------+
bool CTableCell::Save(const int file_handle)
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

   // --- Save the data type
   if(::FileWriteInteger(file_handle,this.m_datatype,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Save the object type in a cell
   if(::FileWriteInteger(file_handle,this.m_object_type,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Save the line number
   if(::FileWriteInteger(file_handle,this.m_row,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Save the column number
   if(::FileWriteInteger(file_handle,this.m_col,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Maintaining accurate data presentation
   if(::FileWriteInteger(file_handle,this.m_digits,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Save date/time display flags
   if(::FileWriteInteger(file_handle,this.m_time_flags,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Save the color name display flag
   if(::FileWriteInteger(file_handle,this.m_color_flag,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Save the flag of the edited cell
   if(::FileWriteInteger(file_handle,this.m_editable,INT_VALUE)!=INT_VALUE)
      return(false);
   // --- Save the value
   if(::FileWriteStruct(file_handle,this.m_datatype_value)!=sizeof(this.m_datatype_value))
      return(false);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | Loading from file |
//+------------------------------------------------------------------+
bool CTableCell::Load(const int file_handle)
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

   // --- Loading the data type
   this.m_datatype=(ENUM_DATATYPE)::FileReadInteger(file_handle,INT_VALUE);
   // --- Load the type of object in the cell
   this.m_object_type=(ENUM_OBJECT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
   // --- Load the line number
   this.m_row=::FileReadInteger(file_handle,INT_VALUE);
   // --- Loading the column number
   this.m_col=::FileReadInteger(file_handle,INT_VALUE);
   // --- Loading the accuracy of data presentation
   this.m_digits=::FileReadInteger(file_handle,INT_VALUE);
   // --- Loading date/time display flags
   this.m_time_flags=::FileReadInteger(file_handle,INT_VALUE);
   // --- Load the color name display flag
   this.m_color_flag=::FileReadInteger(file_handle,INT_VALUE);
   // --- Load the flag of the edited cell
   this.m_editable=::FileReadInteger(file_handle,INT_VALUE);
   // --- Loading value
   if(::FileReadStruct(file_handle,this.m_datatype_value)!=sizeof(this.m_datatype_value))
      return(false);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | Returns the description of the object |
//+------------------------------------------------------------------+
string CTableCell::Description(void)
  {
   return(::StringFormat("%s: Row %u, Col %u, %s <%s>Value: %s",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Row(),this.Col(),
                         (this.m_editable ? "Editable" : "Uneditable"),this.DatatypeDescription(),this.Value()));
  }
//+------------------------------------------------------------------+
// | Logs a description of an object |
//+------------------------------------------------------------------+
void CTableCell::Print(void)
  {
   ::Print(this.Description());
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Table row class |
//+------------------------------------------------------------------+
class CTableRow : public CObject
  {
protected:
   CTableCell        m_cell_tmp;                            // Cell object to search in the list
   CListObj          m_list_cells;                          // List of cells
   uint              m_index;                               // Row index
   
// --- Adds the specified cell to the end of the list
   bool              AddNewCell(CTableCell *cell);
   
public:
// --- (1) Sets, (2) returns the row index
   void              SetIndex(const uint index)                { this.m_index=index;  }
   uint              Index(void)                         const { return this.m_index; }
// --- Sets row and column positions for all cells
   void              CellsPositionUpdate(void);
   
// --- Creates a new cell and adds it to the end of the list
   CTableCell       *CreateNewCell(const double value);
   CTableCell       *CreateNewCell(const long value);
   CTableCell       *CreateNewCell(const datetime value);
   CTableCell       *CreateNewCell(const color value);
   CTableCell       *CreateNewCell(const string value);
   
// --- Returns (1) cell by index, (2) number of cells
   CTableCell       *GetCell(const uint index)                 { return this.m_list_cells.GetNodeAtIndex(index);  }
   uint              CellsTotal(void)                    const { return this.m_list_cells.Total();                }
   
// --- Sets the value to the specified cell
   void              CellSetValue(const uint index,const double value);
   void              CellSetValue(const uint index,const long value);
   void              CellSetValue(const uint index,const datetime value);
   void              CellSetValue(const uint index,const color value);
   void              CellSetValue(const uint index,const string value);
// --- (1) assigns to a cell, (2) removes an assigned object from a cell
   void              CellAssignObject(const uint index,CObject *object);
   void              CellUnassignObject(const uint index);
   
// --- (1) Deletes (2) moves a cell
   bool              CellDelete(const uint index);
   bool              CellMoveTo(const uint cell_index, const uint index_to);
   
// --- Resets row cell data to zero
   void              ClearData(void);

// --- (1) Returns, (2) logs a description of the object
   string            Description(void);
   void              Print(const bool detail, const bool as_table=false, const int cell_width=10);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_ROW); }
   
// --- Constructors/destructor
                     CTableRow(void) : m_index(0) {}
                     CTableRow(const uint index) : m_index(index) {}
                    ~CTableRow(void){}
  };
//+------------------------------------------------------------------+
// | Comparison of two objects |
//+------------------------------------------------------------------+
int CTableRow::Compare(const CObject *node,const int mode=0) const
  {
   const CTableRow *obj=node;
   return(this.Index()>obj.Index() ? 1 : this.Index()<obj.Index() ? -1 : 0);
  }
//+------------------------------------------------------------------+
// | Creates a new double cell and adds it to the end of the list |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CreateNewCell(const double value)
  {
// --- Create a new cell object storing a value of type double
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,2);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
// --- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
// --- Return a pointer to the object
   return cell;
  }
//+------------------------------------------------------------------+
// | Creates a new long cell and adds it to the end of the list |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CreateNewCell(const long value)
  {
// --- Create a new cell object storing a value of type long
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
// --- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
// --- Return a pointer to the object
   return cell;
  }
//+------------------------------------------------------------------+
// | Creates a new datetime cell and adds it to the end of the list |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CreateNewCell(const datetime value)
  {
// --- Create a new cell object storing a value with type datetime
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
// --- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
// --- Return a pointer to the object
   return cell;
  }
//+------------------------------------------------------------------+
// | Creates a new color cell and adds it to the end of the list |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CreateNewCell(const color value)
  {
// --- Create a new cell object storing a value of type color
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,true);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
// --- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
// --- Return a pointer to the object
   return cell;
  }
//+------------------------------------------------------------------+
// | Creates a new string cell and adds it to the end of the list |
//+------------------------------------------------------------------+
CTableCell *CTableRow::CreateNewCell(const string value)
  {
// --- Create a new cell object storing a value of type string
   CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
      return NULL;
     }
// --- Add the created cell to the end of the list
   if(!this.AddNewCell(cell))
     {
      delete cell;
      return NULL;
     }
// --- Return a pointer to the object
   return cell;
  }
//+------------------------------------------------------------------+
// | Adds a cell to the end of the list |
//+------------------------------------------------------------------+
bool CTableRow::AddNewCell(CTableCell *cell)
  {
// --- If an empty object is passed, we report and return false
   if(cell==NULL)
     {
      ::PrintFormat("%s: Error. Empty CTableCell object passed",__FUNCTION__);
      return false;
     }
// --- Set the cell index in the list and add the created cell to the end of the list
   cell.SetPositionInTable(this.m_index,this.CellsTotal());
   if(this.m_list_cells.Add(cell)==WRONG_VALUE)
     {
      ::PrintFormat("%s: Error. Failed to add cell (%u,%u) to list",__FUNCTION__,this.m_index,this.CellsTotal());
      return false;
     }
// --- Successfully
   return true;
  }
//+------------------------------------------------------------------+
// | Sets a double value to the specified cell |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const double value)
  {
// --- We get the desired cell from the list and write a new value into it
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }
//+------------------------------------------------------------------+
// | Sets a long value to the specified cell |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const long value)
  {
// --- We get the desired cell from the list and write a new value into it
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }
//+------------------------------------------------------------------+
// | Sets a datetime value to the specified cell |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const datetime value)
  {
// --- We get the desired cell from the list and write a new value into it
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }
//+------------------------------------------------------------------+
// | Sets the color value to the specified cell |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const color value)
  {
// --- We get the desired cell from the list and write a new value into it
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }
//+------------------------------------------------------------------+
// | Sets a string value to the specified cell |
//+------------------------------------------------------------------+
void CTableRow::CellSetValue(const uint index,const string value)
  {
// --- We get the desired cell from the list and write a new value into it
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.SetValue(value);
  }
//+------------------------------------------------------------------+
// | Assigns an object to a cell |
//+------------------------------------------------------------------+
void CTableRow::CellAssignObject(const uint index,CObject *object)
  {
// --- Get the desired cell from the list and write a pointer to the object into it
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.AssignObject(object);
  }
//+------------------------------------------------------------------+
// | Unassigns an object to a cell |
//+------------------------------------------------------------------+
void CTableRow::CellUnassignObject(const uint index)
  {
// --- We get the desired cell from the list and cancel the pointer to the object and its type in it
   CTableCell *cell=this.GetCell(index);
   if(cell!=NULL)
      cell.UnassignObject();
  }
//+------------------------------------------------------------------+
// | Deletes a cell |
//+------------------------------------------------------------------+
bool CTableRow::CellDelete(const uint index)
  {
// --- Delete a cell in the list by index
   if(!this.m_list_cells.Delete(index))
      return false;
// --- Update indexes for the remaining cells in the list
   this.CellsPositionUpdate();
   return true;
  }
//+------------------------------------------------------------------+
// | Moves the cell to the specified position |
//+------------------------------------------------------------------+
bool CTableRow::CellMoveTo(const uint cell_index,const uint index_to)
  {
// --- Get the desired cell by index in the list, making it current
   CTableCell *cell=this.GetCell(cell_index);
// --- Move the current cell to the specified position in the list
   if(cell==NULL || !this.m_list_cells.MoveToIndex(index_to))
      return false;
// --- Update the indexes of all cells in the list
   this.CellsPositionUpdate();
   return true;
  }
//+------------------------------------------------------------------+
// | Sets row and column positions for all cells |
//+------------------------------------------------------------------+
void CTableRow::CellsPositionUpdate(void)
  {
// --- Loop through all cells in the list
   for(int i=0;i<this.m_list_cells.Total();i++)
     {
      // --- get the next cell and set the row and column indexes in it
      CTableCell *cell=this.GetCell(i);
      if(cell!=NULL)
         cell.SetPositionInTable(this.Index(),this.m_list_cells.IndexOf(cell));
     }
  }
//+------------------------------------------------------------------+
// | Resets row cell data to zero |
//+------------------------------------------------------------------+
void CTableRow::ClearData(void)
  {
// --- Loop through all cells in the list
   for(uint i=0;i<this.CellsTotal();i++)
     {
      // --- get the next cell and set it to an empty value
      CTableCell *cell=this.GetCell(i);
      if(cell!=NULL)
         cell.ClearData();
     }
  }
//+------------------------------------------------------------------+
// | Returns the description of the object |
//+------------------------------------------------------------------+
string CTableRow::Description(void)
  {
   return(::StringFormat("%s: Position %u, Cells total: %u",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Index(),this.CellsTotal()));
  }
//+------------------------------------------------------------------+
// | Logs a description of an object |
//+------------------------------------------------------------------+
void CTableRow::Print(const bool detail, const bool as_table=false, const int cell_width=10)
  {
      
// --- Number of cells
   int total=(int)this.CellsTotal();
   
// --- If the output is in tabular form
   string res="";
   if(as_table)
     {
      // --- create a table row from the values ​​of all cells
      string head=" Row "+(string)this.Index();
      string res=::StringFormat("|%-*s |",cell_width,head);
      for(int i=0;i<total;i++)
        {
         CTableCell *cell=this.GetCell(i);
         if(cell==NULL)
            continue;
         res+=::StringFormat("%*s |",cell_width,cell.Value());
        }
      // --- Output the line to the log
      ::Print(res);
      return;
     }
     
// --- Output the title as a line description
   ::Print(this.Description()+(detail ? ":" : ""));
   
// --- If detailed description
   if(detail)
     {
      
      // ---Output not in tabular form
      // --- Loop through a list of row cells
      for(int i=0; i<total; i++)
        {
         // --- get the current cell and add its description to the final line
         CTableCell *cell=this.GetCell(i);
         if(cell!=NULL)
            res+="  "+cell.Description()+(i<total-1 ? "\n" : "");
        }
      // --- Log the line created in the loop
      ::Print(res);
     }
  }
//+------------------------------------------------------------------+
// | Saving to file |
//+------------------------------------------------------------------+
bool CTableRow::Save(const int file_handle)
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

// --- Save the index
   if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
      return(false);
// --- Save the list of cells
   if(!this.m_list_cells.Save(file_handle))
      return(false);
   
// --- Successfully
   return true;
  }
//+------------------------------------------------------------------+
// | Loading from file |
//+------------------------------------------------------------------+
bool CTableRow::Load(const int file_handle)
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

// --- Loading the index
   this.m_index=::FileReadInteger(file_handle,INT_VALUE);
// --- Loading a list of cells
   if(!this.m_list_cells.Load(file_handle))
      return(false);
   
// --- Successfully
   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Table model class |
//+------------------------------------------------------------------+
class CTableModel : public CObject
  {
protected:
   CTableRow         m_row_tmp;                             // String object to search in the list
   CListObj          m_list_rows;                           // List of table rows
// --- Creates a table model from a two-dimensional array
template<typename T>
   void              CreateTableModel(T &array[][]);
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
   CTableRow        *GetRow(const uint index)                  { return this.m_list_rows.GetNodeAtIndex(index);   }
   uint              RowsTotal(void)                     const { return this.m_list_rows.Total();  }
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
   
// --- (1) Returns, (2) logs the description of the cell, (3) the object assigned to the cell
   string            CellDescription(const uint row, const uint col);
   void              CellPrint(const uint row, const uint col);
   CObject          *CellGetObject(const uint row, const uint col);

public:
// --- Creates a new line and (1) appends it to the end of the list, (2) inserts it at the specified position in the list
   CTableRow        *RowAddNew(void);
   CTableRow        *RowInsertNewTo(const uint index_to);
// --- (1) Deletes (2) moves a row, (3) clears row data
   bool              RowDelete(const uint index);
   bool              RowMoveTo(const uint row_index, const uint index_to);
   void              RowResetData(const uint index);
// --- (1) Returns, (2) logs the description of the string
   string            RowDescription(const uint index);
   void              RowPrint(const uint index,const bool detail);
   
// --- (1) Deletes (2) moves a column, (3) clears column data
   bool              ColumnDelete(const uint index);
   bool              ColumnMoveTo(const uint row_index, const uint index_to);
   void              ColumnResetData(const uint index);
   
// --- (1) Returns, (2) logs the table description
   string            Description(void);
   void              Print(const bool detail);
   void              PrintTable(const int cell_width=10);
   
// --- (1) Clears the data, (2) destroys the model
   void              ClearData(void);
   void              Destroy(void);
   
// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_MODEL);  }
   
// --- Constructors/destructor
                     CTableModel(void){}
                     CTableModel(double &array[][])   { this.CreateTableModel(array); }
                     CTableModel(long &array[][])     { this.CreateTableModel(array); }
                     CTableModel(datetime &array[][]) { this.CreateTableModel(array); }
                     CTableModel(color &array[][])    { this.CreateTableModel(array); }
                     CTableModel(string &array[][])   { this.CreateTableModel(array); }
                    ~CTableModel(void){}
  };
//+------------------------------------------------------------------+
// | Creates a table model from a two-dimensional array |
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
            row.CreateNewCell(array[r][c]);
        }
     }
  }
//+------------------------------------------------------------------+
// | Creates a new empty string and adds it to the end of the list |
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
// | Adds a string to the end of the list |
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
// | Creates a new line and adds it to the end of the list |
//+------------------------------------------------------------------+
CTableRow *CTableModel::RowAddNew(void)
  {
// --- Create a new empty string and add it to the end of the list of strings
   CTableRow *row=this.CreateNewEmptyRow();
   if(row==NULL)
      return NULL;
      
// --- Create cells based on the number of cells in the first row
   for(uint i=0;i<this.CellsInRow(0);i++)
      row.CreateNewCell(0.0);
   row.ClearData();
   
// --- Success - return a pointer to the created object
   return row;
  }
//+------------------------------------------------------------------+
// | Creates and adds a new row at the specified list position |
//+------------------------------------------------------------------+
CTableRow *CTableModel::RowInsertNewTo(const uint index_to)
  {
// --- Create a new empty string and add it to the end of the list of strings
   CTableRow *row=this.CreateNewEmptyRow();
   if(row==NULL)
      return NULL;
     
// --- Create cells based on the number of cells in the first row
   for(uint i=0;i<this.CellsInRow(0);i++)
      row.CreateNewCell(0.0);
   row.ClearData();
   
// --- Shift the line to the index_to position
   this.RowMoveTo(this.m_list_rows.IndexOf(row),index_to);
   
// --- Success - return a pointer to the created object
   return row;
  }
//+------------------------------------------------------------------+
// | Sets the value to the specified cell |
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
// | Sets the accuracy of displaying data in the specified cell |
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
// | Sets time display flags to the specified cell |
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
// | Sets the flag to display color names in the specified cell |
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
// | Assigns an object to a cell |
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
// | Unassigns an object in a cell |
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
// | Deletes a cell |
//+------------------------------------------------------------------+
bool CTableModel::CellDelete(const uint row,const uint col)
  {
// --- Get a row by index and return the result of removing a cell from the list
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.CellDelete(col) : false);
  }
//+------------------------------------------------------------------+
// | Moves a cell |
//+------------------------------------------------------------------+
bool CTableModel::CellMoveTo(const uint row,const uint cell_index,const uint index_to)
  {
// --- Get the row by index and return the result of moving the cell to a new position
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.CellMoveTo(cell_index,index_to) : false);
  }
//+------------------------------------------------------------------+
// | Returns the number of cells in the specified row |
//+------------------------------------------------------------------+
uint CTableModel::CellsInRow(const uint index)
  {
   CTableRow *row=this.GetRow(index);
   return(row!=NULL ? row.CellsTotal() : 0);
  }
//+------------------------------------------------------------------+
// | Returns the number of cells in the table |
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
// | Returns the specified table cell |
//+------------------------------------------------------------------+
CTableCell *CTableModel::GetCell(const uint row,const uint col)
  {
// --- Get a row by index row and return the cell of the row by index col
   CTableRow *row_obj=this.GetRow(row);
   return(row_obj!=NULL ? row_obj.GetCell(col) : NULL);
  }
//+------------------------------------------------------------------+
// | Returns cell description |
//+------------------------------------------------------------------+
string CTableModel::CellDescription(const uint row,const uint col)
  {
   CTableCell *cell=this.GetCell(row,col);
   return(cell!=NULL ? cell.Description() : "");
  }
//+------------------------------------------------------------------+
// | Logs a cell description |
//+------------------------------------------------------------------+
void CTableModel::CellPrint(const uint row,const uint col)
  {
// --- Get a cell by row and column index and return its description
   CTableCell *cell=this.GetCell(row,col);
   if(cell!=NULL)
      cell.Print();
  }
//+------------------------------------------------------------------+
// | Deletes a line |
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
// | Moves a line to the specified position |
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
// | Sets row and column positions for all cells |
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
// | Clears a row (only data in cells) |
//+------------------------------------------------------------------+
void CTableModel::RowResetData(const uint index)
  {
// --- Get a string from the list and clear the data of the string cells using the ClearData() method
   CTableRow *row=this.GetRow(index);
   if(row!=NULL)
      row.ClearData();
  }
//+------------------------------------------------------------------+
// | Clears the table (data of all cells) |
//+------------------------------------------------------------------+
void CTableModel::ClearData(void)
  {
// --- In a loop through all rows of the table, we clear the data of each row
   for(uint i=0;i<this.RowsTotal();i++)
      this.RowResetData(i);
  }
//+------------------------------------------------------------------+
// | Returns the description of a string |
//+------------------------------------------------------------------+
string CTableModel::RowDescription(const uint index)
  {
// --- Get a string by index and return its description
   CTableRow *row=this.GetRow(index);
   return(row!=NULL ? row.Description() : "");
  }
//+------------------------------------------------------------------+
// | Logs a description of a string |
//+------------------------------------------------------------------+
void CTableModel::RowPrint(const uint index,const bool detail)
  {
   CTableRow *row=this.GetRow(index);
   if(row!=NULL)
      row.Print(detail);
  }
//+------------------------------------------------------------------+
// | Removes a column |
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
// | Moves column |
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
// | Clears column data |
//+------------------------------------------------------------------+
void CTableModel::ColumnResetData(const uint index)
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
// | Returns the description of the object |
//+------------------------------------------------------------------+
string CTableModel::Description(void)
  {
   return(::StringFormat("%s: Rows %u, Cells in row %u, Cells Total %u",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.RowsTotal(),this.CellsInRow(0),this.CellsTotal()));
  }
//+------------------------------------------------------------------+
// | Logs a description of an object |
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
// | Logs a description of an object in tabular form |
//+------------------------------------------------------------------+
void CTableModel::PrintTable(const int cell_width=10)
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
// | Destroys the model |
//+------------------------------------------------------------------+
void CTableModel::Destroy(void)
  {
// --- Clear the list of strings
   m_list_rows.Clear();
  }
//+------------------------------------------------------------------+
// | Saving to file |
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
// | Loading from file |
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
  
#define  PRINT_AS_TABLE    true  // Print the model as a table
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
// --- Declare and fill a 4x4 array
// --- Array type can be double, long, datetime, color, string
   long array[4][4]={{ 1,  2,  3,  4},
                     { 5,  6,  7,  8},
                     { 9, 10, 11, 12},
                     {13, 14, 15, 16}};
     
// --- Create a table model from the above created long array 4x4
   CTableModel *tm=new CTableModel(array);
   
// --- If the model is not created, we leave
   if(tm==NULL)
      return;

// --- Print the model in tabular form
   Print("The table model has been successfully created:");
   tm.PrintTable();
   
   
// --- Let's check the work with files and the functionality of the table model
// --- Open the file to write table model data into it
   int handle=FileOpen(MQLInfoString(MQL_PROGRAM_NAME)+".bin",FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(handle==INVALID_HANDLE)
      return;
      
   // --- Save the original created table to a file
   if(tm.Save(handle))
      Print("\nThe table model has been successfully saved to file.");
   
// --- Now insert a new row into the table at position 2
// --- Get the last cell of the created row and make it uneditable
// --- Print the modified table model in the journal
   if(tm.RowInsertNewTo(2))
     {
      Print("\nInsert a new row at position 2 and set cell 3 to non-editable");
      CTableCell *cell=tm.GetCell(2,3);
      if(cell!=NULL)
         cell.SetEditable(false);
      TableModelPrint(tm);
     }
   
// --- Now let's delete the table column with index 1 and
// --- print the resulting table model in the journal
   if(tm.ColumnDelete(1))
     {
      Print("\nRemove column from position 1");
      TableModelPrint(tm);
     }
   
// --- When saving table data, the file pointer was shifted to the last written data
// --- Place the pointer at the beginning of the file, load the previously saved original table and print it
   if(FileSeek(handle,0,SEEK_SET) && tm.Load(handle))
     {
      Print("\nLoad the original table view from the file:");
      TableModelPrint(tm);
     }
   
// --- Close the open file and delete the table model object
   FileClose(handle);
   delete tm;
  }
//+------------------------------------------------------------------+
// | Prints the table model |
//+------------------------------------------------------------------+
void TableModelPrint(CTableModel *tm)
  {
   if(PRINT_AS_TABLE)
      tm.PrintTable();  // Print the model as a table
   else
      tm.Print(true);   // Print detailed table data
  }
//+------------------------------------------------------------------+
