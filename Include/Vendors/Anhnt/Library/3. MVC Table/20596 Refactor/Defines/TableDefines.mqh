//+------------------------------------------------------------------+
//|                                                TableDefines.mqh  |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __TABLED_EFINES_MQH__
#define __TABLED_EFINES_MQH__
    //+------------------------------------------------------------------+
    // | Included Libraries |
    //+------------------------------------------------------------------+
    #include <Arrays\List.mqh>
//+------------------------------------------------------------------+
    //| Macros for Table                                                 |
    //+------------------------------------------------------------------+
        #define  __TABLES__                 // ID of this file
        #define  MARKER_START_DATA    -1    // Marker for the start of data in the file
        #define  MAX_STRING_LENGTH    128   // Maximum length of a string in a cell
        #define  CELL_WIDTH_IN_CHARS  19    // Table cell width in characters
        #define  ASC_IDX_CORRECTION   10000 // Column index offset for ascending sort
        #define  DESC_IDX_CORRECTION  20000 // Column index offset for descending sort
#endif // __TABLE_DEFINES_MQH__
