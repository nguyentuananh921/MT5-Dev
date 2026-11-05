//+------------------------------------------------------------------+
//|                                                       IndRVI.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndRVI.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDRVI_MQH__
#define __INDRVI_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDRVI_MQH_DECLARATION
#define CINDRVI_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Relative Vigor Index standard indicator                          |
 //+------------------------------------------------------------------+
 class CIndRVI : public CIndicatorDE
  {
   public:
                      CIndRVI(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_RVI,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_RVI),manager.StandardIndicatorName(IND_RVI),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_RVI; }
  };
#endif // CINDRVI_MQH_DECLARATION
#endif // __INDRVI_MQH__
