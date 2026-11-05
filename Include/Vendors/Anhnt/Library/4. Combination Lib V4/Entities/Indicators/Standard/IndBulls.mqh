//+------------------------------------------------------------------+
//|                                                     IndBulls.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndBulls.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDBULLS_MQH__
#define __INDBULLS_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDBULLS_MQH_DECLARATION
#define CINDBULLS_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Bulls Power standard indicator                                   |
 //+------------------------------------------------------------------+
 class CIndBulls : public CIndicatorDE
  {
   public:
                      CIndBulls(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_BULLS,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_BULLS),manager.StandardIndicatorName(IND_BULLS),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_BULLS; }
  };
#endif // CINDBULLS_MQH_DECLARATION
#endif // __INDBULLS_MQH__
