//+------------------------------------------------------------------+
//|                                            ControlsDefines.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __CONTROLSDEFINES_MQH__
#define __CONTROLSDEFINES_MQH__
   //+------------------------------------------------------------------+
   //| Included Libraries |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   // | Macro substitutions |
   //+------------------------------------------------------------------+
      #define  DEF_LABEL_W                50          // Default text label width
      #define  DEF_LABEL_H                16          // Default text label height
      #define  DEF_BUTTON_W               60          // Default button width
      #define  DEF_BUTTON_H               16          // Default button height
      #define  DEF_TABLE_ROW_H            16          // Default table row height
      #define  DEF_TABLE_HEADER_H         20          // Default table header height
      #define  DEF_TABLE_ROWS_HEADER_W    24          // Minimum width of table row headers
      #define  DEF_TABLE_COLUMN_MIN_W     12          // Minimum table column width
      #define  DEF_PANEL_W                80          // Default panel width
      #define  DEF_PANEL_H                80          // Default panel height
      #define  DEF_PANEL_MIN_W            60          // Minimum panel width
      #define  DEF_PANEL_MIN_H            60          // Minimum panel height
      #define  DEF_SCROLLBAR_TH           13          // Default scrollbar thickness
      #define  DEF_THUMB_MIN_SIZE         8           // Minimum scroll bar thickness
      #define  DEF_AUTOREPEAT_DELAY       500         // Delay before auto-repeat starts
      #define  DEF_AUTOREPEAT_INTERVAL    100         // Auto repeat frequency

      #define  DEF_HINT_NAME_TOOLTIP      "HintTooltip"     // Name of the tooltip
      #define  DEF_HINT_NAME_HORZ         "HintHORZ"        // Tooltip name "Double horizontal arrow"
      #define  DEF_HINT_NAME_VERT         "HintVERT"        // Tooltip name "Double vertical arrow"
      #define  DEF_HINT_NAME_NWSE         "HintNWSE"        // Tooltip name "Double arrow top-left" --- bottom-right (NorthWest-SouthEast)
      #define  DEF_HINT_NAME_NESW         "HintNESW"        // Tooltip name "Double arrow bottom-left" --- top-right (NorthEast-SouthWest)
      #define  DEF_HINT_NAME_SHIFT_HORZ   "HintShiftHORZ"   // Tooltip name "Horizontal offset arrow"
      #define  DEF_HINT_NAME_SHIFT_VERT   "HintShiftVERT"   // Tooltip name "Vertical offset arrow"
#endif // __CONTROLSDEFINES_MQH__
