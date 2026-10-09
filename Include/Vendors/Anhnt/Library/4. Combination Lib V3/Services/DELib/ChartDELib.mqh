//+------------------------------------------------------------------+
//|                                              ChartDELib.mqh      |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"



#ifndef CCHARTDELIB_MQH
#define CCHARTDELIB_MQH
//+------------------------------------------------------------------+
//| Return the description of the method of displaying a price chart |
//| Using in                                                         |
//| ChartObj.mqh + Symbol.mqh
//+------------------------------------------------------------------+
string ChartModeDescription(ENUM_CHART_MODE mode)
  {
   return
     (
      mode==CHART_BARS     ? CMessage::Text(MSG_CHART_OBJ_CHART_BARS)      :
      mode==CHART_CANDLES  ? CMessage::Text(MSG_CHART_OBJ_CHART_CANDLES)   :
      CMessage::Text(MSG_CHART_OBJ_CHART_LINE)
     );
  }
//+--------------------------------------------------------------------------+
//|Return the description of the mode of displaying volumes on a price chart |
//| ChartObj.mqh                                                     |
//+--------------------------------------------------------------------------+
string ChartModeVolumeDescription(ENUM_CHART_VOLUME_MODE mode)
  {
   return
     (
      mode==CHART_VOLUME_TICK ? CMessage::Text(MSG_CHART_OBJ_CHART_VOLUME_TICK)  :
      mode==CHART_VOLUME_REAL ? CMessage::Text(MSG_CHART_OBJ_CHART_VOLUME_REAL)  :
      CMessage::Text(MSG_CHART_OBJ_CHART_VOLUME_HIDE)
     );
  }
#endif // CCHARTDELIB_MQH