//+------------------------------------------------------------------+
//|                                                  IndIchimoku.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndIchimoku.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDICHIMOKU_MQH__
#define __INDICHIMOKU_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDICHIMOKU_MQH_DECLARATION
#define CINDICHIMOKU_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Ichimoku Kinko Hyo standard indicator                            |
 //+------------------------------------------------------------------+
 class CIndIchimoku : public CIndicatorDE
  {
   public:
                      CIndIchimoku(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_ICHIMOKU,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_ICHIMOKU; }
  };
#endif // CINDICHIMOKU_MQH_DECLARATION
#endif // __INDICHIMOKU_MQH__
