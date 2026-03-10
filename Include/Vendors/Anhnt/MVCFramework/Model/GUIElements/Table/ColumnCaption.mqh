//+------------------------------------------------------------------+
//|                                                ColumnCaption.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|            https://www.mql5.com/en/articles/19979                |
//+------------------------------------------------------------------+
#ifndef COLUMNCAPTION_MQH
#define COLUMNCAPTION_MQH
//+------------------------------------------------------------------+
//| Table column caption class                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Object.mqh> 

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "TableDefines.mqh"

class CColumnCaption : public CObject
  {
protected:
//--- Variables
   ushort            m_ushort_array[MAX_STRING_LENGTH];        // Caption character array
   uint              m_column;                                 // Column index
   ENUM_DATATYPE     m_datatype;                               // Data type

public:
//--- (1) Sets, (2) returns the column index
   void              SetColumn(const uint column)              { this.m_column=column;    }
   uint              Column(void)                        const { return this.m_column;    }

//--- (1) Sets, (2) returns the column data type
   ENUM_DATATYPE     Datatype(void)                      const { return this.m_datatype;  }
   void              SetDatatype(const ENUM_DATATYPE datatype) { this.m_datatype=datatype;}
   
//--- Clears data
   void              ClearData(void)                           { this.SetValue("");       }
   
//--- Sets caption text
   void              SetValue(const string value)
                       {
                        ::StringToShortArray(value,this.m_ushort_array);
                       }
//--- Returns caption text
   string            Value(void) const
                       {
                        string res=::ShortArrayToString(this.m_ushort_array);
                        res.TrimLeft();
                        res.TrimRight();
                        return res;
                       }
   
//--- (1) Returns, (2) prints object description
   virtual string    Description(void);
   void              Print(void);

//--- Virtual methods: (1) comparison, (2) saving to file, (3) loading from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void) const { return(OBJECT_TYPE_COLUMN_CAPTION);  }
   
//--- Constructors / destructor
                     CColumnCaption(void) : m_column(0) { this.SetValue(""); }
                     CColumnCaption(const uint column,const string value) : m_column(column) { this.SetValue(value); }
                    ~CColumnCaption(void) {}
  };
//+------------------------------------------------------------------+
//| Comparison of two objects                                        |
//+------------------------------------------------------------------+
int CColumnCaption::Compare(const CObject *node,const int mode=0) const
  {
   if(node==NULL)
      return -1;
   const CColumnCaption *obj=node;
   return(this.Column()>obj.Column() ? 1 : this.Column()<obj.Column() ? -1 : 0);
  }
//+------------------------------------------------------------------+
//| Save to file                                                     |
//+------------------------------------------------------------------+
bool CColumnCaption::Save(const int file_handle)
  {
   if(file_handle==INVALID_HANDLE)
      return(false);

   if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
      return(false);

   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return(false);

   if(::FileWriteInteger(file_handle,this.m_column,INT_VALUE)!=INT_VALUE)
      return(false);

   if(::FileWriteArray(file_handle,this.m_ushort_array)!=sizeof(this.m_ushort_array))
      return(false);

   return true;
  }
//+------------------------------------------------------------------+
//| Load from file                                                   |
//+------------------------------------------------------------------+
bool CColumnCaption::Load(const int file_handle)
  {
   if(file_handle==INVALID_HANDLE)
      return(false);

   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);

   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return(false);

   this.m_column=::FileReadInteger(file_handle,INT_VALUE);

   if(::FileReadArray(file_handle,this.m_ushort_array)!=sizeof(this.m_ushort_array))
      return(false);

   return true;
  }
//+------------------------------------------------------------------+
//| Returns object description                                       |
//+------------------------------------------------------------------+
string CColumnCaption::Description(void)
  {
   return(::StringFormat("%s: Column %u, Value: \"%s\"",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Column(),this.Value()));
  }
//+------------------------------------------------------------------+
//| Prints object description to log                                 |
//+------------------------------------------------------------------+
void CColumnCaption::Print(void)
  {
   ::Print(this.Description());
  }
//+------------------------------------------------------------------+

#endif