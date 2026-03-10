//+------------------------------------------------------------------+
//|                                                  BaseDefines.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|               https://www.mql5.com/en/articles/19979             |
//+------------------------------------------------------------------+
#ifndef __BASE_DEFINES_MQH__
#define __BASE_DEFINES_MQH__
//+------------------------------------------------------------------+
//| Macro substitutions                     |
//+------------------------------------------------------------------+
#define  clrNULL              0x00FFFFFF  // Transparent color for CCanvas
#ifndef  __TABLES__
#define  MARKER_START_DATA    -1          // Marker indicating beginning of data in file
#endif
#define  DEF_FONTNAME         "Calibri"   // Default font
#define  DEF_FONTSIZE         10          // Default font size
#define  DEF_EDGE_THICKNESS   3           // Thickness of border capture zone

#define  ACTIVE_ELEMENT_MIN   ELEMENT_TYPE_LABEL               // Minimum active element value
#define  ACTIVE_ELEMENT_MAX   ELEMENT_TYPE_TABLE_HEADER_VIEW   // Maximum active element value
#endif // __BASE_DEFINES_MQH__