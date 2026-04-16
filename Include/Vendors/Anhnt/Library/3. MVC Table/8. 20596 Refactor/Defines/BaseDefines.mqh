//+------------------------------------------------------------------+
//|                                                BaseDefines.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __BASEDEFINES_MQH__
#define __BASEDEFINES_MQH__
   //+------------------------------------------------------------------+
   // | Included Libraries |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   // | Macro substitutions |
   //+------------------------------------------------------------------+
      #define  clrNULL              0x00FFFFFF  // Transparent color for CCanvas old value 0x00FFFFFF change to 0x00000000
      #ifndef  __TABLES__
      #define  MARKER_START_DATA    -1          // Marker for the start of data in the file
      #endif 
      #define  DEF_FONTNAME         "Calibri"   // Default font
      #define  DEF_FONTSIZE         10          // Default font size
      #define  DEF_EDGE_THICKNESS   3           // Border/corner zone thickness
#endif // __BASEDEFINES_MQH__

