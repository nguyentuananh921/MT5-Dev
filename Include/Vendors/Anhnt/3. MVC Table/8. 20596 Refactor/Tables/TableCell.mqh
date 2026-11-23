//+------------------------------------------------------------------+
//|                                                  TableCell.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/17653  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table cell class                                                 |
//+------------------------------------------------------------------+
#ifndef __TABLECELL_MQH__
#define __TABLECELL_MQH__  
    //+------------------------------------------------------------------+
    //| Included Standard Libraries                                      |
    //+------------------------------------------------------------------+
    //#include <Arrays\List.mqh>

    //+------------------------------------------------------------------+
    //| Included Custome Libraries                                       |
    //+------------------------------------------------------------------+
    #include "..\Defines\TableDefines.mqh"
    #include "..\Defines\TableEnums.mqh"
    #include "..\Base\BaseObj.mqh"
   
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
        
    // --- Sets "empty value"
        void              SetEmptyValue(void)
                            {
                            switch(this.m_datatype)
                            {
                                case TYPE_LONG    :  
                                case TYPE_DATETIME:  
                                case TYPE_COLOR   :  this.SetValue(LONG_MAX);   break;
                                case TYPE_DOUBLE  :  this.SetValue(DBL_MAX);    break;
                                default           :  this.SetValue("");         break;
                            }
                            }
    public:
      // --- Returning coordinates and cell properties
        uint              Row(void)                           const { return this.m_row;                      }
        uint              Col(void)                           const { return this.m_col;                      }
        ENUM_DATATYPE     Datatype(void)                      const { return this.m_datatype;                 }
        int               Digits(void)                        const { return this.m_digits;                   }
        uint              DatetimeFlags(void)                 const { return this.m_time_flags;               }
        bool              ColorNameFlag(void)                 const { return this.m_color_flag;               }
        bool              IsEditable(void)                    const { return this.m_editable;                 }
      // --- Returns (1) double, (2) long, (3) string value
        double            ValueD(void)                        const { return this.m_datatype_value.ValueD();  }
        long              ValueL(void)                        const { return this.m_datatype_value.ValueL();  }
        string            ValueS(void)                        const { return this.m_datatype_value.ValueS();  }
      // --- Returns the value as a formatted string
        string            Value(void) const
                            {
                            switch(this.m_datatype)
                            {
                                case TYPE_DOUBLE  :  return(this.ValueD()!=DBL_MAX  ? ::DoubleToString(this.ValueD(),this.Digits())            : "");
                                case TYPE_LONG    :  return(this.ValueL()!=LONG_MAX ? ::IntegerToString(this.ValueL())                         : "");
                                case TYPE_DATETIME:  return(this.ValueL()!=LONG_MAX ? ::TimeToString(this.ValueL(),this.m_time_flags)          : "");
                                case TYPE_COLOR   :  return(this.ValueL()!=LONG_MAX ? ::ColorToString((color)this.ValueL(),this.m_color_flag)  : "");
                                default           :  return this.ValueS();
                            }
                            }
      // --- Returns a description of the type of the stored value
        string            DatatypeDescription(void) const
                            {
                            string type=::StringSubstr(::EnumToString(this.m_datatype),5);
                            type.Lower();
                            return type;
                            }
      // --- Clears data
        void              ClearData(void)                           { this.SetEmptyValue();                   }
      // --- Setting variable values
        void              SetRow(const uint row)                    { this.m_row=(int)row;                    }
        void              SetCol(const uint col)                    { this.m_col=(int)col;                    }
        void              SetDatatype(const ENUM_DATATYPE datatype) { this.m_datatype=datatype;               }
        void              SetDigits(const int digits)               { this.m_digits=digits;                   }
        void              SetDatetimeFlags(const uint flags)        { this.m_time_flags=flags;                }
        void              SetColorNameFlag(const bool flag)         { this.m_color_flag=flag;                 }
        void              SetEditable(const bool flag)              { this.m_editable=flag;                   }
      // --- Sets row and column
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
                            
      // --- Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
        CObject          *AssignedObject(void)                      { return this.m_object;                   }
        ENUM_OBJECT_TYPE  AssignedObjType(void)               const { return this.m_object_type;              }

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
        
      // --- (1) Returns, (2) logs a description of the object
        virtual string    Description(void);
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
      if(node==NULL)
         return -1;
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
      // --- Get the formatted object type using the static helper from CBaseObj
      string typeStr = CBaseObj::FormatObjectType((ENUM_OBJECT_TYPE)this.Type());
      
      // --- Return the comprehensive description of the table cell
      return ::StringFormat("%s: Row %u, Col %u, %s <%s>Value: %s",
                            typeStr, this.Row(), this.Col(),
                            (this.m_editable ? "Editable" : "Uneditable"),
                            this.DatatypeDescription(), this.Value());
      /*return(::StringFormat("%s: Row %u, Col %u, %s <%s>Value: %s",
                           TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Row(),this.Col(),
                           (this.m_editable ? "Editable" : "Uneditable"),this.DatatypeDescription(),this.Value()));*/
   }
   //+------------------------------------------------------------------+
   // | Logs a description of an object |
   //+------------------------------------------------------------------+
   void CTableCell::Print(void)
   {
      ::Print(this.Description());
   }
   //+------------------------------------------------------------------+
#endif // __TABLECELL_MQH__

