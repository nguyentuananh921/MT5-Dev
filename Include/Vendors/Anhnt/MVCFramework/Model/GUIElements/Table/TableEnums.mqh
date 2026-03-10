//+------------------------------------------------------------------+
//|                                                 TableEnums.mqh   |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                https://www.mql5.com/en/articles/19979            |
//+------------------------------------------------------------------+

#ifndef __TABLE_ENUMS_MQH__
#define __TABLE_ENUMS_MQH__

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+

// Enumeration of object types
enum ENUM_OBJECT_TYPE
  {
   OBJECT_TYPE_TABLE_CELL=10000,    // Table cell
   OBJECT_TYPE_TABLE_ROW,           // Table row
   OBJECT_TYPE_TABLE_MODEL,         // Table model
   OBJECT_TYPE_COLUMN_CAPTION,      // Table column caption
   OBJECT_TYPE_TABLE_HEADER,        // Table header
   OBJECT_TYPE_TABLE,               // Table
   OBJECT_TYPE_TABLE_BY_PARAM,      // Table built from parameter array data
  };

// Table cell comparison modes
enum ENUM_CELL_COMPARE_MODE
  {
   CELL_COMPARE_MODE_COL,           // Compare by column number
   CELL_COMPARE_MODE_ROW,           // Compare by row number
   CELL_COMPARE_MODE_ROW_COL,       // Compare by row and column
  };

#endif // __TABLE_ENUMS_MQH__