//+------------------------------------------------------------------+
//|                                                        Tables.mqh|
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           mql5.com article 19979                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#ifndef __TABLES_MQH__
#define __TABLES_MQH__

//+------------------------------------------------------------------+
//| Included libraries                                               |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>

// //--- Forward class declarations
// class CTableCell;       // Table cell class
// class CTableRow;        // Table row class
// class CTableModel;      // Table model class
// class CColumnCaption;   // Table column caption class
// class CTableHeader;     // Table header class
// class CTable;           // Table class
// class CTableByParam;    // Table class based on parameter array

//+------------------------------------------------------------------+
//| Macros Move to TableDefines.mqh                                  |
//+------------------------------------------------------------------+
// #define  __TABLES__               // Identifier of this file
// #define  MARKER_START_DATA   -1   // Marker indicating start of data in file
// #define  MAX_STRING_LENGTH   128  // Maximum string length inside a cell
// #define  CELL_WIDTH_IN_CHARS 19   // Table cell width in characters
// #define  ASC_IDX_CORRECTION  10000 // Column index shift for ascending sort
// #define  DESC_IDX_CORRECTION 20000 // Column index shift for descending sort

//+------------------------------------------------------------------+
//| Enumerations Move to TableEnums.mqh                              |
//+------------------------------------------------------------------+

//--- Object types
// enum ENUM_OBJECT_TYPE
//   {
//    OBJECT_TYPE_TABLE_CELL = 10000, // Table cell
//    OBJECT_TYPE_TABLE_ROW,          // Table row
//    OBJECT_TYPE_TABLE_MODEL,        // Table model
//    OBJECT_TYPE_COLUMN_CAPTION,     // Column caption
//    OBJECT_TYPE_TABLE_HEADER,       // Table header
//    OBJECT_TYPE_TABLE,              // Table
//    OBJECT_TYPE_TABLE_BY_PARAM,     // Table created from parameter array
//   };

// //--- Table cell comparison modes
// enum ENUM_CELL_COMPARE_MODE
//   {
//    CELL_COMPARE_MODE_COL,      // Compare by column index
//    CELL_COMPARE_MODE_ROW,      // Compare by row index
//    CELL_COMPARE_MODE_ROW_COL,  // Compare by row and column
//   };

//+------------------------------------------------------------------+
//| Functions                                                        |
//+------------------------------------------------------------------+

// #include <Canvas/Canvas.mqh>
// //+------------------------------------------------------------------+
// //|Include Custome library                                           |
// //+------------------------------------------------------------------+
// #include "BaseDefines.mqh"
// #include "BaseEnums.mqh"

// #include "BoundedObj.mqh"
// #include "ColorElement.mqh"
// #include "AutoRepeat.mqh"
// #include "CommonManager.mqh"

#endif