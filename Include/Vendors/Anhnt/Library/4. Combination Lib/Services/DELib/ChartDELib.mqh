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
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "..\..\Defines\Defines.mqh"
  #include "..\..\Notify\Message\Message.mqh"
  #include "..\InputData\CommonInpData.mqh"
  #include "CommonDELib.mqh"
//+------------------------------------------------------------------+
//| Return the file name (program name+local time)                   |
//| Using in                                                         |
//| ChartObj.mqh                                                     |
//+------------------------------------------------------------------+
string FileNameWithTimeLocal(const string time_prefix=NULL)
 {
   string name=
     (
      MQLInfoString(MQL_PROGRAM_NAME)+"_"+time_prefix+(time_prefix==NULL ? "" : "_")+
      TimeToString(TimeLocal(),TIME_DATE|TIME_MINUTES|TIME_SECONDS)
     );
   ResetLastError();
   if(StringReplace(name," ","_")==WRONG_VALUE)
      CMessage::ToLog(DFUN,GetLastError(),true);
   if(StringReplace(name,":",".")==WRONG_VALUE)
      CMessage::ToLog(DFUN,GetLastError(),true);
   return name;
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
