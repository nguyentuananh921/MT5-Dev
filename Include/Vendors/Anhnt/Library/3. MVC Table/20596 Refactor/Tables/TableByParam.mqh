//+------------------------------------------------------------------+
//|                                               TableByParam.mqh   |
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

#ifndef __TABLEBYPARAM_MQH__
#define __TABLEBYPARAM_MQH__
     //+------------------------------------------------------------------+
   // | Class for creating tables based on an array of parameters |
   //+------------------------------------------------------------------+
   class CTableByParam : public CTable
   {
   public:
      virtual int       Type(void)     const { return(OBJECT_TYPE_TABLE_BY_PARAM);  }
   // --- Constructor/destructor
                        CTableByParam(void)  { this.m_list_rows.Clear();            }
                        CTableByParam(CList &row_data,const string &column_names[]);
                        ~CTableByParam(void) {}
   };
   //+------------------------------------------------------------------+
   // | Constructor specifying a table array based on the list row_data|
   // | containing objects with structure field data.                   |
   // | Determines the number and names of columns according to the quantity |
   // | column names in the column_names array |
   //+------------------------------------------------------------------+
   CTableByParam::CTableByParam(CList &row_data,const string &column_names[])
   {
   // --- Copy the passed list of data into a variable and
   // --- create a table model based on this list
      this.m_list_rows=row_data;
      this.m_table_model=new CTableModel(this.m_list_rows);
      
   // --- Copy the passed list of headers to m_array_names and
   // --- create a table header based on this list
      this.ArrayNamesCopy(column_names,column_names.Size());
      this.m_table_header=new CTableHeader(this.m_array_names);
   }
   //+------------------------------------------------------------------+
#endif // __TABLEBYPARAM_MQH__

