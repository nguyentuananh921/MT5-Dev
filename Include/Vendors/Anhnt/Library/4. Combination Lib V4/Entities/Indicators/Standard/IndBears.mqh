//+------------------------------------------------------------------+
//|                                                     IndBears.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndBears.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDBEARS_MQH__
#define __INDBEARS_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDBEARS_MQH_DECLARATION
#define CINDBEARS_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Bears Power standard indicator                                   |
 //+------------------------------------------------------------------+
 class CIndBears : public CIndicatorDE
  {
   public:
                      CIndBears(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_BEARS,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_BEARS; }
  };
#endif // CINDBEARS_MQH_DECLARATION
#endif // __INDBEARS_MQH__
