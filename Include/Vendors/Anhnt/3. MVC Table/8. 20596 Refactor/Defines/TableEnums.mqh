//+------------------------------------------------------------------+
//|                                                TableEnums.mqh    |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table Enums                                                      |
//+------------------------------------------------------------------+
#ifndef __TABLE_ENUMS_MQH__
#define __TABLE_ENUMS_MQH__
    //+------------------------------------------------------------------+
    // | Included Libraries |
    //+------------------------------------------------------------------+
    #include <Arrays\List.mqh>
    enum ENUM_OBJECT_TYPE               // Enumerating Object Types
    {
        OBJECT_TYPE_TABLE_CELL=10000,    // Table cell
        OBJECT_TYPE_TABLE_ROW,           // Table row
        OBJECT_TYPE_TABLE_MODEL,         // Table model
        OBJECT_TYPE_COLUMN_CAPTION,      // Table Column Header
        OBJECT_TYPE_TABLE_HEADER,        // Table title
        OBJECT_TYPE_TABLE,               // Table
        OBJECT_TYPE_TABLE_BY_PARAM,      // Table based on parameter array data
    };    
    enum ENUM_CELL_COMPARE_MODE         // Table cell comparison modes
    {
        CELL_COMPARE_MODE_COL,           // Comparison by column number
        CELL_COMPARE_MODE_ROW,           // Comparison by line number
        CELL_COMPARE_MODE_ROW_COL,       // Comparison by row and column
    };
#endif // __TABLE_ENUMS_MQH__