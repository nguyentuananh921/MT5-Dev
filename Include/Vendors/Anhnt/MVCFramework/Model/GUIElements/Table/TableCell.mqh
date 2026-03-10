//+------------------------------------------------------------------+
//|                                                    TableCell.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __TABLE_CELL_MQH__
#define __TABLE_CELL_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Object.mqh>

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "TableDefines.mqh"
#include "TableEnums.mqh"

//+------------------------------------------------------------------+
//| Table cell class                                                 |
//+------------------------------------------------------------------+
class CTableCell : public CObject
  {
protected:

//--- Union for storing cell values (double, long, string)
   union DataType
     {
      protected:
      double         double_value;
      long           long_value;
      ushort         ushort_value[MAX_STRING_LENGTH];

      public:

      //--- Set values
      void           SetValueD(const double value) { this.double_value=value;                   }
      void           SetValueL(const long value)   { this.long_value=value;                     }
      void           SetValueS(const string value) { ::StringToShortArray(value,ushort_value);  }

      //--- Return values
      double         ValueD(void) const { return this.double_value; }
      long           ValueL(void) const { return this.long_value;   }

      string         ValueS(void) const
                       {
                        string res=::ShortArrayToString(this.ushort_value);
                        res.TrimLeft();
                        res.TrimRight();
                        return res;
                       }
     };

//--- Variables
   DataType          m_datatype_value;     // Stored value
   ENUM_DATATYPE     m_datatype;           // Data type
   CObject          *m_object;             // Object stored in the cell
   ENUM_OBJECT_TYPE  m_object_type;        // Type of stored object
   int               m_row;                // Row index
   int               m_col;                // Column index
   int               m_digits;             // Display precision
   uint              m_time_flags;         // Date/time display flags
   bool              m_color_flag;         // Flag for displaying color name
   bool              m_editable;           // Editable cell flag

//--- Set empty value
   void              SetEmptyValue(void)
                       {
                        switch(this.m_datatype)
                          {
                           case TYPE_LONG:
                           case TYPE_DATETIME:
                           case TYPE_COLOR   : this.SetValue(LONG_MAX); break;
                           case TYPE_DOUBLE  : this.SetValue(DBL_MAX);  break;
                           default           : this.SetValue("");       break;
                          }
                       }

public:

//--- Return coordinates and properties
   uint              Row(void)             const { return this.m_row;        }
   uint              Col(void)             const { return this.m_col;        }
   ENUM_DATATYPE     Datatype(void)        const { return this.m_datatype;   }
   int               Digits(void)          const { return this.m_digits;     }
   uint              DatetimeFlags(void)   const { return this.m_time_flags; }
   bool              ColorNameFlag(void)   const { return this.m_color_flag; }
   bool              IsEditable(void)      const { return this.m_editable;   }

//--- Return value as (1) double (2) long (3) string
   double            ValueD(void) const { return this.m_datatype_value.ValueD(); }
   long              ValueL(void) const { return this.m_datatype_value.ValueL(); }
   string            ValueS(void) const { return this.m_datatype_value.ValueS(); }

//--- Return formatted string value
   string Value(void) const
     {
      switch(this.m_datatype)
        {
         case TYPE_DOUBLE  : return(this.ValueD()!=DBL_MAX  ? ::DoubleToString(this.ValueD(),this.Digits())            : "");
         case TYPE_LONG    : return(this.ValueL()!=LONG_MAX ? ::IntegerToString(this.ValueL())                         : "");
         case TYPE_DATETIME: return(this.ValueL()!=LONG_MAX ? ::TimeToString(this.ValueL(),this.m_time_flags)          : "");
         case TYPE_COLOR   : return(this.ValueL()!=LONG_MAX ? ::ColorToString((color)this.ValueL(),this.m_color_flag)  : "");
         default           : return this.ValueS();
        }
     }

//--- Return description of stored datatype
   string DatatypeDescription(void) const
     {
      string type=::StringSubstr(::EnumToString(this.m_datatype),5);
      type.Lower();
      return type;
     }

//--- Clear data
   void ClearData(void) { this.SetEmptyValue(); }

//--- Set variable values
   void SetRow(const uint row)                    { this.m_row=(int)row;  }
   void SetCol(const uint col)                    { this.m_col=(int)col;  }
   void SetDatatype(const ENUM_DATATYPE datatype) { this.m_datatype=datatype; }
   void SetDigits(const int digits)               { this.m_digits=digits; }
   void SetDatetimeFlags(const uint flags)        { this.m_time_flags=flags; }
   void SetColorNameFlag(const bool flag)         { this.m_color_flag=flag; }
   void SetEditable(const bool flag)              { this.m_editable=flag; }

//--- Set row and column
   void SetPositionInTable(const uint row,const uint col)
     {
      this.SetRow(row);
      this.SetCol(col);
     }

//--- Assign object to cell
   void AssignObject(CObject *object)
     {
      if(object==NULL)
        {
         ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
         return;
        }
      this.m_object=object;
      this.m_object_type=(ENUM_OBJECT_TYPE)object.Type();
     }

//--- Unassign object
   void UnassignObject(void)
     {
      this.m_object=NULL;
      this.m_object_type=-1;
     }

//--- Return assigned object and its type
   CObject          *AssignedObject(void) { return this.m_object; }
   ENUM_OBJECT_TYPE  AssignedObjType(void) const { return this.m_object_type; }

//--- Set double value
   void SetValue(const double value)
     {
      this.m_datatype=TYPE_DOUBLE;
      if(this.m_editable)
         this.m_datatype_value.SetValueD(value);
     }

//--- Set long value
   void SetValue(const long value)
     {
      this.m_datatype=TYPE_LONG;
      if(this.m_editable)
         this.m_datatype_value.SetValueL(value);
     }

//--- Set datetime value
   void SetValue(const datetime value)
     {
      this.m_datatype=TYPE_DATETIME;
      if(this.m_editable)
         this.m_datatype_value.SetValueL(value);
     }

//--- Set color value
   void SetValue(const color value)
     {
      this.m_datatype=TYPE_COLOR;
      if(this.m_editable)
         this.m_datatype_value.SetValueL(value);
     }

//--- Set string value
   void SetValue(const string value)
     {
      this.m_datatype=TYPE_STRING;
      if(this.m_editable)
         this.m_datatype_value.SetValueS(value);
     }

//--- Return description / print
   virtual string Description(void);
   void           Print(void);

//--- Virtual methods
   virtual int  Compare(const CObject *node,const int mode=0) const;
   virtual bool Save(const int file_handle);
   virtual bool Load(const int file_handle);
   virtual int  Type(void) const { return OBJECT_TYPE_TABLE_CELL; }

//--- Constructors
   CTableCell(void);
   CTableCell(const uint row,const uint col,const double value,const int digits);
   CTableCell(const uint row,const uint col,const long value);
   CTableCell(const uint row,const uint col,const datetime value,const uint time_flags);
   CTableCell(const uint row,const uint col,const color value,const bool color_names_flag);
   CTableCell(const uint row,const uint col,const string value);
   ~CTableCell(void) {}
  };
  //+------------------------------------------------------------------+
//| CTableCell::Compare two objects                                  |
//+------------------------------------------------------------------+
int CTableCell::Compare(const CObject *node,const int mode=0) const
  {
   if(node==NULL)
      return -1;
   const CTableCell *obj=node;
   switch(mode)
     {
      case CELL_COMPARE_MODE_COL :  return(this.Col()>obj.Col() ? 1 : this.Col()<obj.Col() ? -1 : 0);
      case CELL_COMPARE_MODE_ROW :  return(this.Row()>obj.Row() ? 1 : this.Row()<obj.Row() ? -1 : 0);
      //--- Default mode: CELL_COMPARE_MODE_ROW_COL
      default                    :  return
                                      (
                                       this.Row()>obj.Row() ? 1 : this.Row()<obj.Row() ? -1 :
                                       this.Col()>obj.Col() ? 1 : this.Col()<obj.Col() ? -1 : 0
                                      );
     }
  }

//+------------------------------------------------------------------+
//| CTableCell::Save to file                                         |
//+------------------------------------------------------------------+
bool CTableCell::Save(const int file_handle)
  {
//--- Check file handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Write data start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
      return(false);
//--- Save object type
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return(false);

   //--- Save data type (ENUM_DATATYPE)
   if(::FileWriteInteger(file_handle,this.m_datatype,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save cell's object type
   if(::FileWriteInteger(file_handle,this.m_object_type,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save row index
   if(::FileWriteInteger(file_handle,this.m_row,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save column index
   if(::FileWriteInteger(file_handle,this.m_col,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save decimal precision
   if(::FileWriteInteger(file_handle,this.m_digits,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save datetime display flags
   if(::FileWriteInteger(file_handle,this.m_time_flags,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save color name display flag
   if(::FileWriteInteger(file_handle,this.m_color_flag,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save editability flag
   if(::FileWriteInteger(file_handle,this.m_editable,INT_VALUE)!=INT_VALUE)
      return(false);
   //--- Save the raw value struct
   if(::FileWriteStruct(file_handle,this.m_datatype_value)!=sizeof(this.m_datatype_value))
      return(false);
   
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableCell::Load from file                                       |
//+------------------------------------------------------------------+
bool CTableCell::Load(const int file_handle)
  {
//--- Check file handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Read and verify data start marker
   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);
//--- Read and verify object type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return(false);

   //--- Load properties from file
   this.m_datatype=(ENUM_DATATYPE)::FileReadInteger(file_handle,INT_VALUE);
   this.m_object_type=(ENUM_OBJECT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
   this.m_row=::FileReadInteger(file_handle,INT_VALUE);
   this.m_col=::FileReadInteger(file_handle,INT_VALUE);
   this.m_digits=::FileReadInteger(file_handle,INT_VALUE);
   this.m_time_flags=::FileReadInteger(file_handle,INT_VALUE);
   this.m_color_flag=::FileReadInteger(file_handle,INT_VALUE);
   this.m_editable=::FileReadInteger(file_handle,INT_VALUE);
   //--- Load the raw value struct
   if(::FileReadStruct(file_handle,this.m_datatype_value)!=sizeof(this.m_datatype_value))
      return(false);
   
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableCell::Returns object description                           |
//+------------------------------------------------------------------+
string CTableCell::Description(void)
  {
   return(::StringFormat("%s: Row %u, Col %u, %s <%s>Value: %s",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Row(),this.Col(),
                         (this.m_editable ? "Editable" : "Uneditable"),this.DatatypeDescription(),this.Value()));
  }

//+------------------------------------------------------------------+
//| CTableCell::Prints description to the journal                    |
//+------------------------------------------------------------------+
void CTableCell::Print(void)
  {
   ::Print(this.Description());
  }

#endif