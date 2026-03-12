//+------------------------------------------------------------------+
//|                                                TableDefines.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                https://www.mql5.com/en/articles/19979            |
//+------------------------------------------------------------------+

#ifndef __TABLE_DEFINES_MQH__
#define __TABLE_DEFINES_MQH__

#include "TableEnums.mqh"
// //+------------------------------------------------------------------+
// //| Macros                                                           |
// //+------------------------------------------------------------------+
// #define  __TABLES__                 // Identifier of this file
// #define  MARKER_START_DATA    -1    // Marker indicating the beginning of data in the file
// #define  MAX_STRING_LENGTH    128   // Maximum string length in a table cell
// #define  CELL_WIDTH_IN_CHARS  19    // Table cell width in characters
// #define  ASC_IDX_CORRECTION   10000 // Offset of column index for ascending sort
// #define  DESC_IDX_CORRECTION  20000 // Offset of column index for descending sort
// //+------------------------------------------------------------------+
//| Returns object type description as string                        |
//+------------------------------------------------------------------+
string TypeDescription(const ENUM_OBJECT_TYPE type)
  {
   string array[];
   int total = StringSplit(EnumToString(type), StringGetCharacter("_",0), array);

   string result = "";

   for(int i = 2; i < total; i++)
     {
      array[i] += " ";
      array[i].Lower();
      array[i].SetChar(0, ushort(array[i].GetChar(0) - 0x20));
      result += array[i];
     }

   result.TrimLeft();
   result.TrimRight();

   return result;
  }
#endif // __TABLE_DEFINES_MQH__