//+------------------------------------------------------------------+
//|                                             CColumnCaption.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>
#include "..\Defines\TableDefines.mqh"
#include "..\Defines\TableEnums.mqh"

#ifndef __CCOLUMNCAPTION_MQH__
#define __CCOLUMNCAPTION_MQH__
     //+------------------------------------------------------------------+
   // | Table Column Header Class |
   //+------------------------------------------------------------------+
   class CColumnCaption : public CObject
   {
      protected:
      // --- Variables
         ushort            m_ushort_array[MAX_STRING_LENGTH];        // Header character array
         uint              m_column;                                 // Column number
         ENUM_DATATYPE     m_datatype;                               // Data type

      public:
      // --- (1) Sets, (2) returns the column number
         void              SetColumn(const uint column)              { this.m_column=column;    }
         uint              Column(void)                        const { return this.m_column;    }

      // --- (1) Sets, (2) returns the data type of the column
         ENUM_DATATYPE     Datatype(void)                      const { return this.m_datatype;  }
         void              SetDatatype(const ENUM_DATATYPE datatype) { this.m_datatype=datatype;}
         
      // --- Clears data
         void              ClearData(void)                           { this.SetValue("");       }
         
      // --- Sets the title
         void              SetValue(const string value)
                           {
                              ::StringToShortArray(value,this.m_ushort_array);
                           }
      // --- Returns the title text
         string            Value(void) const
                           {
                              string res=::ShortArrayToString(this.m_ushort_array);
                              res.TrimLeft();
                              res.TrimRight();
                              return res;
                           }
         
      // --- (1) Returns, (2) logs a description of the object
         virtual string    Description(void);
         void              Print(void);

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(OBJECT_TYPE_COLUMN_CAPTION);  }
         
         
      // --- Constructors/destructor
                           CColumnCaption(void) : m_column(0) { this.SetValue(""); }
                           CColumnCaption(const uint column,const string value) : m_column(column) { this.SetValue(value); }
                        ~CColumnCaption(void) {}
   };
   //+------------------------------------------------------------------+
   // | Comparison of two objects |
   //+------------------------------------------------------------------+
   int CColumnCaption::Compare(const CObject *node,const int mode=0) const
   {
      if(node==NULL)
         return -1;
      const CColumnCaption *obj=node;
      return(this.Column()>obj.Column() ? 1 : this.Column()<obj.Column() ? -1 : 0);
   }
   //+------------------------------------------------------------------+
   // | Saving to file |
   //+------------------------------------------------------------------+
   bool CColumnCaption::Save(const int file_handle)
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

      // --- Save the column number
      if(::FileWriteInteger(file_handle,this.m_column,INT_VALUE)!=INT_VALUE)
         return(false);
      // --- Save the value
      if(::FileWriteArray(file_handle,this.m_ushort_array)!=sizeof(this.m_ushort_array))
         return(false);
      
   //--- Всё успешно
      return true;
   }
   //+------------------------------------------------------------------+
   // | Loading from file |
   //+------------------------------------------------------------------+
   bool CColumnCaption::Load(const int file_handle)
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

      // --- Loading the column number
      this.m_column=::FileReadInteger(file_handle,INT_VALUE);
      // --- Loading value
      if(::FileReadArray(file_handle,this.m_ushort_array)!=sizeof(this.m_ushort_array))
         return(false);
      
   // --- Everything is successful
      return true;
   }
   //+------------------------------------------------------------------+
   // | Returns the description of the object |
   //+------------------------------------------------------------------+
   string CColumnCaption::Description(void)
   {
      return(::StringFormat("%s: Column %u, Value: \"%s\"",
                           TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Column(),this.Value()));
   }
   //+------------------------------------------------------------------+
   // | Logs a description of an object |
   //+------------------------------------------------------------------+
   void CColumnCaption::Print(void)
   {
      ::Print(this.Description());
   }
   //+------------------------------------------------------------------+
#endif // __CCOLUMNCAPTION_MQH__
