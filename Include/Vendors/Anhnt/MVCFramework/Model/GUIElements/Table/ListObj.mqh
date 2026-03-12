//+------------------------------------------------------------------+
//|                                                       ListObj.mqh|
//|                   Tables in the MVC Paradigm in MQL5             |
//+------------------------------------------------------------------+

#ifndef __LIST_OBJ_MQH__
#define __LIST_OBJ_MQH__
//+------------------------------------------------------------------+
//| Classes                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Linked list class for storing objects                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh> 

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
/*
#include "TableDefines.mqh"
#include "TableEnums.mqh"
*/
#include <Vendors/Anhnt/CFramework/Defines/Defines.mqh>  // MARKER_START_DATA, CELL_WIDTH_IN_CHARS
#include <Vendors/Anhnt/CFramework/Defines/Enums.mqh>    // ENUM_OBJECT_TYPE, ENUM_DATATYPE


#include "TableCell.mqh"
#include "TableRow.mqh"
#include "TableModel.mqh"
#include "ColumnCaption.mqh"
#include "TableHeader.mqh"
#include "Table.mqh"
#include "TableByParam.mqh"

class CTableCell;
class CTableRow;
class CTableModel;
class CColumnCaption;
class CTableHeader;
class CTable;
class CTableByParam;

class CListObj : public CList
  {
protected:
   ENUM_TABLE_OBJECT_TYPE m_element_type;   // Type of object to be created in CreateElement()

public:

//--- Virtual methods: (1) load list from file, (2) create list element
   virtual bool     Load(const int file_handle);
   virtual CObject *CreateElement(void);
  };

//+------------------------------------------------------------------+
//| Load list from file                                              |
//+------------------------------------------------------------------+
bool CListObj::Load(const int file_handle)
  {
//--- Variables
   CObject *node;
   bool result = true;

//--- Check file handle
   if(file_handle == INVALID_HANDLE)
      return false;

//--- Load and verify start marker of list - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle) != MARKER_START_DATA)
      return false;

//--- Load and verify list type
   if(::FileReadInteger(file_handle,INT_VALUE) != this.Type())
      return false;

//--- Read list size (number of objects)
   uint num = ::FileReadInteger(file_handle,INT_VALUE);

//--- Recreate list elements sequentially using Load() method of node objects
   this.Clear();

   for(uint i = 0; i < num; i++)
     {
      //--- Read and verify object start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileReadLong(file_handle) != MARKER_START_DATA)
         return false;

      //--- Read object type
      this.m_element_type = (ENUM_OBJECT_TYPE)::FileReadInteger(file_handle,INT_VALUE);

      node = this.CreateElement();

      if(node == NULL)
         return false;

      this.Add(node);

      //--- File pointer is currently shifted relative to the object marker start by 12 bytes
      //--- (8 bytes marker + 4 bytes type)
      //--- Move pointer back to the beginning of object data and load properties
      //--- from file using node.Load()
      if(!::FileSeek(file_handle,-12,SEEK_CUR))
         return false;

      result &= node.Load(file_handle);
     }

//--- Return result
   return result;
  }

//+------------------------------------------------------------------+
//| Create list element                                              |
//+------------------------------------------------------------------+
CObject *CListObj::CreateElement(void)
  {
//--- Depending on object type in m_element_type, create new object
   switch(this.m_element_type)
     {
      case OBJECT_TYPE_TABLE_CELL      : return new CTableCell();
      case OBJECT_TYPE_TABLE_ROW       : return new CTableRow();
      case OBJECT_TYPE_TABLE_MODEL     : return new CTableModel();
      case OBJECT_TYPE_COLUMN_CAPTION  : return new CColumnCaption();
      case OBJECT_TYPE_TABLE_HEADER    : return new CTableHeader();
      case OBJECT_TYPE_TABLE           : return new CTable();
      case OBJECT_TYPE_TABLE_BY_PARAM  : return new CTableByParam();
      default                          : return NULL;
     }
  }

#endif