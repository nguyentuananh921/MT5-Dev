//+------------------------------------------------------------------+
//|                                                        IndAO.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndAO.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDAO_MQH__
#define __INDAO_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDAO_MQH_DECLARATION
#define CINDAO_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Awesome Oscillator standard indicator                            |
 //+------------------------------------------------------------------+
 class CIndAO : public CIndicatorDE
  {
   public:
                      CIndAO(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_AO,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_AO),GetIndicatorNameForType(IND_AO),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_AO; }
  };
#endif // CINDAO_MQH_DECLARATION
#endif // __INDAO_MQH__
