//+------------------------------------------------------------------+
//|                                                      IndTEMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndTEMA.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDTEMA_MQH__
#define __INDTEMA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDTEMA_MQH_DECLARATION
#define CINDTEMA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Triple Exponential Moving Average standard indicator             |
 //+------------------------------------------------------------------+
 class CIndTEMA : public CIndicatorDE
  {
   public:
                      CIndTEMA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_TEMA,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_TEMA; }
  };
#endif // CINDTEMA_MQH_DECLARATION
#endif // __INDTEMA_MQH__
