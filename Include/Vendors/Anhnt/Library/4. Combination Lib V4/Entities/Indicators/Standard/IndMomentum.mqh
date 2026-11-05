//+------------------------------------------------------------------+
//|                                                  IndMomentum.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndMomentum.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDMOMENTUM_MQH__
#define __INDMOMENTUM_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDMOMENTUM_MQH_DECLARATION
#define CINDMOMENTUM_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Momentum standard indicator                                      |
 //+------------------------------------------------------------------+
 class CIndMomentum : public CIndicatorDE
  {
   public:
                      CIndMomentum(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_MOMENTUM,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_MOMENTUM),manager.StandardIndicatorName(IND_MOMENTUM),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_MOMENTUM; }
  };
#endif // CINDMOMENTUM_MQH_DECLARATION
#endif // __INDMOMENTUM_MQH__
