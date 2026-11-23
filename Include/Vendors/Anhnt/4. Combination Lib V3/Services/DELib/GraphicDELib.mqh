//+------------------------------------------------------------------+
//|                                            GraphicDELib.mqh      |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __GRAPHIC_DELIB_MQH__
#define __GRAPHIC_DELIB_MQH__
 //+------------------------------------------------------------------+
 //| Return the description of the standard graphical object type     |
 //+------------------------------------------------------------------+
 string StdGraphObjectTypeDescription(const ENUM_OBJECT type)
  {
    return
        (
          type==OBJ_TREND             ? "Trend Line"         :
          type==OBJ_RECTANGLE         ? "Rectangle"          :
          type==OBJ_TRIANGLE          ? "Triangle"           :
          type==OBJ_TEXT              ? "Text"               :
          type==OBJ_RECTANGLE_LABEL   ? "Rectangle Label"    :
          "Unknown"
        );
  }

#endif // __GRAPHIC_DELIB_MQH__