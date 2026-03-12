//+------------------------------------------------------------------+
//|                                                  TableByParam.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|            https://www.mql5.com/en/articles/19979                |
//+------------------------------------------------------------------+
#ifndef TABLEBYPARAM_MQH
#define TABLEBYPARAM_MQH
//+------------------------------------------------------------------+
//| Class for creating tables based on an array of parameters        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Table.mqh"
class CTableByParam : public CTable
  {
public:
   virtual int       Type(void) const { return(OBJECT_TYPE_TABLE_BY_PARAM); }

//--- Constructor / destructor
                     CTableByParam(void)  { this.m_list_rows.Clear(); }
                     CTableByParam(CList &row_data,const string &column_names[]);
                    ~CTableByParam(void) {}
  };
//+------------------------------------------------------------------+
//| Constructor specifying a table array based on the row_data list  |
//| containing objects with structure field data.                    |
//| Determines the number and names of columns according to the      |
//| number of column names in the column_names array                 |
//+------------------------------------------------------------------+
CTableByParam::CTableByParam(CList &row_data,const string &column_names[])
  {
//--- Copy the passed data list into a variable and
//--- create a table model based on this list
   this.m_list_rows=row_data;
   this.m_table_model=new CTableModel(this.m_list_rows);
   
//--- Copy the passed list of captions into m_array_names and
//--- create a table header based on this list
   this.ArrayNamesCopy(column_names,column_names.Size());
   this.m_table_header=new CTableHeader(this.m_array_names);
  }
//+------------------------------------------------------------------+

#endif