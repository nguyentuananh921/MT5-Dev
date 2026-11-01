//+------------------------------------------------------------------+
//|                                                       IndCCI.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndCCI.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDCCI_MQH__
#define __INDCCI_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDCCI_MQH_DECLARATION
#define CINDCCI_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Commodity Channel Index standard indicator                       |
 //+------------------------------------------------------------------+
 class CIndCCI : public CIndicatorDE
  {
   public:
                      CIndCCI(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_CCI,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_CCI),GetIndicatorNameForType(IND_CCI),
                                      "",mql_param) { this.m_type=OBJECT_DE_TYPE_IND_CCI; }
  };
#endif // CINDCCI_MQH_DECLARATION
#endif // __INDCCI_MQH__
