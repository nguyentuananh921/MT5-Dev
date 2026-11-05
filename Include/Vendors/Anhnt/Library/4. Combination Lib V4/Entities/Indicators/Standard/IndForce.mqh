//+------------------------------------------------------------------+
//|                                                     IndForce.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndForce.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDFORCE_MQH__
#define __INDFORCE_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDFORCE_MQH_DECLARATION
#define CINDFORCE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Force Index standard indicator                                   |
 //+------------------------------------------------------------------+
 class CIndForce : public CIndicatorDE
  {
   public:
                      CIndForce(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_FORCE,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_FORCE),manager.StandardIndicatorName(IND_FORCE),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_FORCE; }
  };
#endif // CINDFORCE_MQH_DECLARATION
#endif // __INDFORCE_MQH__
