//+------------------------------------------------------------------+
//|                                            GraphicDELib.mqh      |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __GRAPHIC_DELIB_MQH__
#define __GRAPHIC_DELIB_MQH__

#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "..\..\Defines\GraphDefines.mqh"
  #include "CommonDELib.mqh"
  #include "TimeseriesDELib.mqh"
//+------------------------------------------------------------------+
//| Return the description of the chart corner for pixel coordinates  |
//+------------------------------------------------------------------+
string BaseCornerDescription(const ENUM_BASE_CORNER corner)
  {
    return
        (
          corner==CORNER_LEFT_UPPER  ? "Left Upper"  :
          corner==CORNER_LEFT_LOWER  ? "Left Lower"  :
          corner==CORNER_RIGHT_LOWER ? "Right Lower" :
          corner==CORNER_RIGHT_UPPER ? "Right Upper" :
          "Unknown"
        );
  }
//+------------------------------------------------------------------+
//| Return the description of the graphical object frame look        |
//+------------------------------------------------------------------+
string BorderTypeDescription(const ENUM_BORDER_TYPE border_type)
  {
    return
        (
          border_type==BORDER_FLAT   ? "Flat"   :
          border_type==BORDER_RAISED ? "Raised" :
          border_type==BORDER_SUNKEN ? "Sunken" :
          "Unknown"
        );
  }
//+------------------------------------------------------------------+
//| Return the description of the standard graphical object type     |
//+------------------------------------------------------------------+
string StdGraphObjectTypeDescription(const ENUM_OBJECT type)
  {
    return
        (
          type==OBJ_VLINE             ? "Vertical Line"      :
          type==OBJ_HLINE             ? "Horizontal Line"    :
          type==OBJ_TREND             ? "Trend Line"         :
          type==OBJ_TRENDBYANGLE      ? "Trend By Angle"     :
          type==OBJ_CYCLES            ? "Cycles"             :
          type==OBJ_ARROWED_LINE      ? "Arrowed Line"       :
          type==OBJ_CHANNEL           ? "Channel"            :
          type==OBJ_STDDEVCHANNEL     ? "StdDev Channel"     :
          type==OBJ_REGRESSION        ? "Regression"         :
          type==OBJ_PITCHFORK         ? "Pitchfork"          :
          type==OBJ_GANNLINE          ? "Gann Line"          :
          type==OBJ_GANNFAN           ? "Gann Fan"           :
          type==OBJ_GANNGRID          ? "Gann Grid"          :
          type==OBJ_FIBO              ? "Fibonacci"          :
          type==OBJ_FIBOTIMES         ? "Fibonacci Times"    :
          type==OBJ_FIBOFAN           ? "Fibonacci Fan"      :
          type==OBJ_FIBOARC           ? "Fibonacci Arc"      :
          type==OBJ_FIBOCHANNEL       ? "Fibonacci Channel"  :
          type==OBJ_EXPANSION         ? "Expansion"          :
          type==OBJ_ELLIOTWAVE5       ? "Elliott Wave 5"     :
          type==OBJ_ELLIOTWAVE3       ? "Elliott Wave 3"     :
          type==OBJ_RECTANGLE         ? "Rectangle"          :
          type==OBJ_TRIANGLE          ? "Triangle"           :
          type==OBJ_ELLIPSE           ? "Ellipse"            :
          type==OBJ_ARROW_THUMB_UP    ? "Arrow Thumb Up"     :
          type==OBJ_ARROW_THUMB_DOWN  ? "Arrow Thumb Down"   :
          type==OBJ_ARROW_UP          ? "Arrow Up"           :
          type==OBJ_ARROW_DOWN        ? "Arrow Down"         :
          type==OBJ_ARROW_STOP        ? "Arrow Stop"         :
          type==OBJ_ARROW_CHECK       ? "Arrow Check"        :
          type==OBJ_ARROW_LEFT_PRICE  ? "Arrow Left Price"   :
          type==OBJ_ARROW_RIGHT_PRICE ? "Arrow Right Price"  :
          type==OBJ_ARROW_BUY         ? "Arrow Buy"          :
          type==OBJ_ARROW_SELL        ? "Arrow Sell"         :
          type==OBJ_ARROW             ? "Arrow"              :
          type==OBJ_TEXT              ? "Text"               :
          type==OBJ_LABEL             ? "Label"              :
          type==OBJ_BUTTON            ? "Button"             :
          type==OBJ_CHART             ? "Chart"              :
          type==OBJ_BITMAP            ? "Bitmap"             :
          type==OBJ_BITMAP_LABEL      ? "Bitmap Label"       :
          type==OBJ_EDIT              ? "Edit"               :
          type==OBJ_EVENT             ? "Event"              :
          type==OBJ_RECTANGLE_LABEL   ? "Rectangle Label"    :
          "Unknown"
        );
  }
//+------------------------------------------------------------------+
//| Return the anchor point description for the Arrow object         |
//+------------------------------------------------------------------+
string AnchorForArrowObjDescription(const ENUM_ARROW_ANCHOR anchor)
  {
    return
        (
          anchor==ANCHOR_TOP    ? "Top"    :
          anchor==ANCHOR_BOTTOM ? "Bottom" :
          "Unknown"
        );
  }
//+------------------------------------------------------------------+
//| Return the anchor point description for graphical objects        |
//+------------------------------------------------------------------+
string AnchorForGraphicsObjDescription(const ENUM_ANCHOR_POINT anchor)
  {
    return
        (
          anchor==ANCHOR_LEFT_UPPER  ? "Left Upper"  :
          anchor==ANCHOR_LEFT        ? "Left"        :
          anchor==ANCHOR_LEFT_LOWER  ? "Left Lower"  :
          anchor==ANCHOR_LOWER       ? "Lower"       :
          anchor==ANCHOR_RIGHT_LOWER ? "Right Lower" :
          anchor==ANCHOR_RIGHT       ? "Right"       :
          anchor==ANCHOR_RIGHT_UPPER ? "Right Upper" :
          anchor==ANCHOR_UPPER       ? "Upper"       :
          anchor==ANCHOR_CENTER      ? "Center"      :
          "Unknown"
        );
  }
//+------------------------------------------------------------------+
//| Return whether the graphical object is visible on a timeframe    |
//+------------------------------------------------------------------+
bool IsVisibleOnTimeframe(const ENUM_TIMEFRAMES timeframe, const int flags)
  {
    if(flags==OBJ_ALL_PERIODS) return true;
    if(flags==OBJ_NO_PERIODS)  return false;
    int flag=0;
    switch((int)timeframe)
      {
        case PERIOD_M1  : flag=0x00000001; break;
        case PERIOD_M2  : flag=0x00000002; break;
        case PERIOD_M3  : flag=0x00000004; break;
        case PERIOD_M4  : flag=0x00000008; break;
        case PERIOD_M5  : flag=0x00000010; break;
        case PERIOD_M6  : flag=0x00000020; break;
        case PERIOD_M10 : flag=0x00000040; break;
        case PERIOD_M12 : flag=0x00000080; break;
        case PERIOD_M15 : flag=0x00000100; break;
        case PERIOD_M20 : flag=0x00000200; break;
        case PERIOD_M30 : flag=0x00000400; break;
        case PERIOD_H1  : flag=0x00000800; break;
        case PERIOD_H2  : flag=0x00001000; break;
        case PERIOD_H3  : flag=0x00002000; break;
        case PERIOD_H4  : flag=0x00004000; break;
        case PERIOD_H6  : flag=0x00008000; break;
        case PERIOD_H8  : flag=0x00010000; break;
        case PERIOD_H12 : flag=0x00020000; break;
        case PERIOD_D1  : flag=0x00040000; break;
        case PERIOD_W1  : flag=0x00080000; break;
        case PERIOD_MN1 : flag=0x00100000; break;
        default         : break;
      }
    return((flags & flag)==flag);
  }
//+------------------------------------------------------------------+
//| Create a new standard graphical object                           |
//+------------------------------------------------------------------+
bool CreateNewStdGraphObject(const long     chart_id,
                             const string   name,
                             const ENUM_OBJECT type,
                             const int      subwindow,
                             const datetime time1,
                             const double   price1,
                             const datetime time2  =0,
                             const double   price2  =0,
                             const datetime time3  =0,
                             const double   price3  =0,
                             const datetime time4  =0,
                             const double   price4  =0,
                             const datetime time5  =0,
                             const double   price5  =0)
  {
    ::ResetLastError();
    switch(type)
      {
        //--- Lines
        case OBJ_VLINE          : return ::ObjectCreate(chart_id,name,OBJ_VLINE,subwindow,time1,0);
        case OBJ_HLINE          : return ::ObjectCreate(chart_id,name,OBJ_HLINE,subwindow,0,price1);
        case OBJ_TREND          : return ::ObjectCreate(chart_id,name,OBJ_TREND,subwindow,time1,price1,time2,price2);
        case OBJ_TRENDBYANGLE   : return ::ObjectCreate(chart_id,name,OBJ_TRENDBYANGLE,subwindow,time1,price1,time2,price2);
        case OBJ_CYCLES         : return ::ObjectCreate(chart_id,name,OBJ_CYCLES,subwindow,time1,price1,time2,price2);
        case OBJ_ARROWED_LINE   : return ::ObjectCreate(chart_id,name,OBJ_ARROWED_LINE,subwindow,time1,price1,time2,price2);
        //--- Channels
        case OBJ_CHANNEL        : return ::ObjectCreate(chart_id,name,OBJ_CHANNEL,subwindow,time1,price1,time2,price2,time3,price3);
        case OBJ_STDDEVCHANNEL  : return ::ObjectCreate(chart_id,name,OBJ_STDDEVCHANNEL,subwindow,time1,price1,time2,price2);
        case OBJ_REGRESSION     : return ::ObjectCreate(chart_id,name,OBJ_REGRESSION,subwindow,time1,price1,time2,price2);
        case OBJ_PITCHFORK      : return ::ObjectCreate(chart_id,name,OBJ_PITCHFORK,subwindow,time1,price1,time2,price2,time3,price3);
        //--- Gann
        case OBJ_GANNLINE       : return ::ObjectCreate(chart_id,name,OBJ_GANNLINE,subwindow,time1,price1,time2,price2);
        case OBJ_GANNFAN        : return ::ObjectCreate(chart_id,name,OBJ_GANNFAN,subwindow,time1,price1,time2,price2);
        case OBJ_GANNGRID       : return ::ObjectCreate(chart_id,name,OBJ_GANNGRID,subwindow,time1,price1,time2,price2);
        //--- Fibo
        case OBJ_FIBO           : return ::ObjectCreate(chart_id,name,OBJ_FIBO,subwindow,time1,price1,time2,price2);
        case OBJ_FIBOTIMES      : return ::ObjectCreate(chart_id,name,OBJ_FIBOTIMES,subwindow,time1,price1,time2,price2);
        case OBJ_FIBOFAN        : return ::ObjectCreate(chart_id,name,OBJ_FIBOFAN,subwindow,time1,price1,time2,price2);
        case OBJ_FIBOARC        : return ::ObjectCreate(chart_id,name,OBJ_FIBOARC,subwindow,time1,price1,time2,price2);
        case OBJ_FIBOCHANNEL    : return ::ObjectCreate(chart_id,name,OBJ_FIBOCHANNEL,subwindow,time1,price1,time2,price2,time3,price3);
        case OBJ_EXPANSION      : return ::ObjectCreate(chart_id,name,OBJ_EXPANSION,subwindow,time1,price1,time2,price2,time3,price3);
        //--- Elliott
        case OBJ_ELLIOTWAVE5    : return ::ObjectCreate(chart_id,name,OBJ_ELLIOTWAVE5,subwindow,time1,price1,time2,price2,time3,price3,time4,price4,time5,price5);
        case OBJ_ELLIOTWAVE3    : return ::ObjectCreate(chart_id,name,OBJ_ELLIOTWAVE3,subwindow,time1,price1,time2,price2,time3,price3);
        //--- Shapes
        case OBJ_RECTANGLE      : return ::ObjectCreate(chart_id,name,OBJ_RECTANGLE,subwindow,time1,price1,time2,price2);
        case OBJ_TRIANGLE       : return ::ObjectCreate(chart_id,name,OBJ_TRIANGLE,subwindow,time1,price1,time2,price2,time3,price3);
        case OBJ_ELLIPSE        : return ::ObjectCreate(chart_id,name,OBJ_ELLIPSE,subwindow,time1,price1,time2,price2,time3,price3);
        //--- Arrows
        case OBJ_ARROW_THUMB_UP   : return ::ObjectCreate(chart_id,name,OBJ_ARROW_THUMB_UP,subwindow,time1,price1);
        case OBJ_ARROW_THUMB_DOWN : return ::ObjectCreate(chart_id,name,OBJ_ARROW_THUMB_DOWN,subwindow,time1,price1);
        case OBJ_ARROW_UP         : return ::ObjectCreate(chart_id,name,OBJ_ARROW_UP,subwindow,time1,price1);
        case OBJ_ARROW_DOWN       : return ::ObjectCreate(chart_id,name,OBJ_ARROW_DOWN,subwindow,time1,price1);
        case OBJ_ARROW_STOP       : return ::ObjectCreate(chart_id,name,OBJ_ARROW_STOP,subwindow,time1,price1);
        case OBJ_ARROW_CHECK      : return ::ObjectCreate(chart_id,name,OBJ_ARROW_CHECK,subwindow,time1,price1);
        case OBJ_ARROW_LEFT_PRICE : return ::ObjectCreate(chart_id,name,OBJ_ARROW_LEFT_PRICE,subwindow,time1,price1);
        case OBJ_ARROW_RIGHT_PRICE: return ::ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,subwindow,time1,price1);
        case OBJ_ARROW_BUY        : return ::ObjectCreate(chart_id,name,OBJ_ARROW_BUY,subwindow,time1,price1);
        case OBJ_ARROW_SELL       : return ::ObjectCreate(chart_id,name,OBJ_ARROW_SELL,subwindow,time1,price1);
        case OBJ_ARROW            : return ::ObjectCreate(chart_id,name,OBJ_ARROW,subwindow,time1,price1);
        //--- Graphical objects
        case OBJ_TEXT           : return ::ObjectCreate(chart_id,name,OBJ_TEXT,subwindow,time1,price1);
        case OBJ_LABEL          : return ::ObjectCreate(chart_id,name,OBJ_LABEL,subwindow,0,0);
        case OBJ_BUTTON         : return ::ObjectCreate(chart_id,name,OBJ_BUTTON,subwindow,0,0);
        case OBJ_CHART          : return ::ObjectCreate(chart_id,name,OBJ_CHART,subwindow,0,0);
        case OBJ_BITMAP         : return ::ObjectCreate(chart_id,name,OBJ_BITMAP,subwindow,time1,price1);
        case OBJ_BITMAP_LABEL   : return ::ObjectCreate(chart_id,name,OBJ_BITMAP_LABEL,subwindow,0,0);
        case OBJ_EDIT           : return ::ObjectCreate(chart_id,name,OBJ_EDIT,subwindow,0,0);
        case OBJ_EVENT          : return ::ObjectCreate(chart_id,name,OBJ_EVENT,subwindow,time1,0);
        case OBJ_RECTANGLE_LABEL: return ::ObjectCreate(chart_id,name,OBJ_RECTANGLE_LABEL,subwindow,0,0);
        //---
        default: return false;
      }
  }

//+------------------------------------------------------------------+
//| Return the graphical object type as string                       |
//+------------------------------------------------------------------+
string TypeGraphElementAsString(const ENUM_GRAPH_ELEMENT_TYPE type)
  {
    ushort array[];
    int total=StringToShortArray(StringSubstr(EnumToString(type),18),array);
    for(int i=0;i<total-1;i++)
      {
        if(array[i]==95)
          {
            i+=1;
            continue;
          }
        else
              array[i]+=0x20;
      }
    string txt=ShortArrayToString(array);
    StringReplace(txt,"_WfBase","WFBase");
    StringReplace(txt,"_Wf_","");
    StringReplace(txt,"_Obj","");
    StringReplace(txt,"_","");
    StringReplace(txt,"Groupbox","GroupBox");
    StringReplace(txt,"ButtonsUdBox","ButtonsUDBox");
    StringReplace(txt,"ButtonsLrBox","ButtonsLRBox");
    return txt;
  }
//+------------------------------------------------------------------+
//| Return the description of the object location inside the control |
//+------------------------------------------------------------------+
string AlignmentDescription(const ENUM_CANV_ELEMENT_ALIGNMENT alignment)
  {
    switch(alignment)
      {
        case CANV_ELEMENT_ALIGNMENT_TOP    : return CMessage::Text(MSG_LIB_TEXT_TOP);    break;
        case CANV_ELEMENT_ALIGNMENT_BOTTOM : return CMessage::Text(MSG_LIB_TEXT_BOTTOM); break;
        case CANV_ELEMENT_ALIGNMENT_LEFT   : return CMessage::Text(MSG_LIB_TEXT_LEFT);   break;
        case CANV_ELEMENT_ALIGNMENT_RIGHT  : return CMessage::Text(MSG_LIB_TEXT_RIGHT);  break;
        default                            : return "Unknown";                            break;
      }
  }
//+------------------------------------------------------------------+
//| Return the description of the tab size setting mode              |
//+------------------------------------------------------------------+
string TabSizeModeDescription(const ENUM_CANV_ELEMENT_TAB_SIZE_MODE mode)
  {
    switch(mode)
      {
        case CANV_ELEMENT_TAB_SIZE_MODE_NORMAL : return CMessage::Text(MSG_LIB_TEXT_TAB_SIZE_MODE_NORMAL); break;
        case CANV_ELEMENT_TAB_SIZE_MODE_FIXED  : return CMessage::Text(MSG_LIB_TEXT_TAB_SIZE_MODE_FIXED);  break;
        case CANV_ELEMENT_TAB_SIZE_MODE_FILL   : return CMessage::Text(MSG_LIB_TEXT_TAB_SIZE_MODE_FILL);   break;
        default                                : return "Unknown";                                          break;
      }
  }
//+------------------------------------------------------------------+
//| Return the maximum value in the array                            |
//+------------------------------------------------------------------+
template<typename T>
bool ArrayMaximumValue(const string source,const T &array[],T &max_value)
  {
   if(ArraySize(array)==0)
     {
      CMessage::ToLog(source,MSG_CANV_ELEMENT_ERR_EMPTY_ARRAY);
      return false;
     }
   max_value=0;
   int index=ArrayMaximum(array);
   if(index==WRONG_VALUE)
      return false;
   max_value=array[index];
   return true;
  }
//+------------------------------------------------------------------+
//| Return the minimum value in the array                            |
//+------------------------------------------------------------------+
template<typename T>
bool ArrayMinimumValue(const string source,const T &array[],T &min_value)
  {
   if(ArraySize(array)==0)
     {
      CMessage::ToLog(source,MSG_CANV_ELEMENT_ERR_EMPTY_ARRAY);
      return false;
     }
   min_value=0;
   int index=ArrayMinimum(array);
   if(index==WRONG_VALUE)
      return false;
   min_value=array[index];
   return true;
  }

//+------------------------------------------------------------------+
//| Return the description of the text alignment mode               |
//+------------------------------------------------------------------+
string AlignModeDescription(ENUM_ALIGN_MODE align)
  {
   return
     (
      align==ALIGN_LEFT    ? CMessage::Text(MSG_LIB_TEXT_ALIGN_LEFT)    :
      align==ALIGN_CENTER  ? CMessage::Text(MSG_LIB_TEXT_ALIGN_CENTER)  :
      align==ALIGN_RIGHT   ? CMessage::Text(MSG_LIB_TEXT_ALIGN_RIGHT)   :
      "Unknown"
     );
  }
//+------------------------------------------------------------------+
//| Return the description of the Elliott wave degree               |
//+------------------------------------------------------------------+
string ElliotWaveDegreeDescription(const ENUM_ELLIOT_WAVE_DEGREE degree)
  {
   return
     (
      degree==ELLIOTT_GRAND_SUPERCYCLE ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_GRAND_SUPERCYCLE) :
      degree==ELLIOTT_SUPERCYCLE       ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_SUPERCYCLE)       :
      degree==ELLIOTT_CYCLE            ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_CYCLE)            :
      degree==ELLIOTT_PRIMARY          ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_PRIMARY)          :
      degree==ELLIOTT_INTERMEDIATE     ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_INTERMEDIATE)     :
      degree==ELLIOTT_MINOR            ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_MINOR)            :
      degree==ELLIOTT_MINUTE           ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_MINUTE)           :
      degree==ELLIOTT_MINUETTE         ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_MINUETTE)         :
      degree==ELLIOTT_SUBMINUETTE      ? CMessage::Text(MSG_LIB_TEXT_ELLIOTT_SUBMINUETTE)      :
      "Unknown"
     );
  }
//+------------------------------------------------------------------+
//| Return the description of the Gann line direction               |
//+------------------------------------------------------------------+
string GannDirectDescription(const ENUM_GANN_DIRECTION direction)
  {
   return
     (
      direction==GANN_UP_TREND   ? CMessage::Text(MSG_LIB_TEXT_GANN_UP_TREND)   :
      direction==GANN_DOWN_TREND ? CMessage::Text(MSG_LIB_TEXT_GANN_DOWN_TREND) :
      "Unknown"
     );
  }

#endif // __GRAPHIC_DELIB_MQH__
