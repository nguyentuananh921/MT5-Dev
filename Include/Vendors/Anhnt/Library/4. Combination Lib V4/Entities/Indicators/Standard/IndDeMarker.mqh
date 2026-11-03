//+------------------------------------------------------------------+
//|                                                  IndDeMarker.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndDeMarker.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDDEMARKER_MQH__
#define __INDDEMARKER_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDDEMARKER_MQH_DECLARATION
#define CINDDEMARKER_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| DeMarker standard indicator                                      |
 //+------------------------------------------------------------------+
 class CIndDeMarker : public CIndicatorDE
  {
   public:
                      CIndDeMarker(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_DEMARKER,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_DEMARKER),GetIndicatorNameForType(IND_DEMARKER),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_DEMARKER; }
  };
#endif // CINDDEMARKER_MQH_DECLARATION
#endif // __INDDEMARKER_MQH__
