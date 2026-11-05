//+------------------------------------------------------------------+
//|                                                       IndAMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndAMA.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDAMA_MQH__
#define __INDAMA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDAMA_MQH_DECLARATION
#define CINDAMA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Adaptive Moving Average standard indicator                       |
 //+------------------------------------------------------------------+
 class CIndAMA : public CIndicatorDE
  {
   public:
                      CIndAMA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_AMA,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_AMA),manager.StandardIndicatorName(IND_AMA),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_AMA; }
  };
#endif // CINDAMA_MQH_DECLARATION
#endif // __INDAMA_MQH__
