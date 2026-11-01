//+------------------------------------------------------------------+
//|                                                     IndVIDYA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndVIDYA.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDVIDYA_MQH__
#define __INDVIDYA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDVIDYA_MQH_DECLARATION
#define CINDVIDYA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Variable Index Dynamic Average standard indicator                |
 //+------------------------------------------------------------------+
 class CIndVIDYA : public CIndicatorDE
  {
   public:
                      CIndVIDYA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_VIDYA,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_VIDYA),GetIndicatorNameForType(IND_VIDYA),
                                      "",mql_param) { this.m_type=OBJECT_DE_TYPE_IND_VIDYA; }
  };
#endif // CINDVIDYA_MQH_DECLARATION
#endif // __INDVIDYA_MQH__
