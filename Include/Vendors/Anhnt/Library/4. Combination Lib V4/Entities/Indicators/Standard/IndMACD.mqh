//+------------------------------------------------------------------+
//|                                                      IndMACD.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndMACD.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDMACD_MQH__
#define __INDMACD_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDMACD_MQH_DECLARATION
#define CINDMACD_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Moving Average Convergence/Divergence standard indicator         |
 //+------------------------------------------------------------------+
 class CIndMACD : public CIndicatorDE
  {
   public:
                      CIndMACD(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_MACD,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_MACD),manager.StandardIndicatorName(IND_MACD),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_MACD; }
  };
#endif // CINDMACD_MQH_DECLARATION
#endif // __INDMACD_MQH__
