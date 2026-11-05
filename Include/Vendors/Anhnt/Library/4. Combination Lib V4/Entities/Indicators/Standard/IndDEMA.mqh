//+------------------------------------------------------------------+
//|                                                      IndDEMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndDEMA.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDDEMA_MQH__
#define __INDDEMA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDDEMA_MQH_DECLARATION
#define CINDDEMA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Double Exponential Moving Average standard indicator             |
 //+------------------------------------------------------------------+
 class CIndDEMA : public CIndicatorDE
  {
   public:
                      CIndDEMA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_DEMA,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_DEMA),manager.StandardIndicatorName(IND_DEMA),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_DEMA; }
  };
#endif // CINDDEMA_MQH_DECLARATION
#endif // __INDDEMA_MQH__
