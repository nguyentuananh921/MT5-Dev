//+------------------------------------------------------------------+
//|                                                   IndChaikin.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndChaikin.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDCHAIKIN_MQH__
#define __INDCHAIKIN_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDCHO_MQH_DECLARATION
#define CINDCHO_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Chaikin Oscillator standard indicator                            |
 //+------------------------------------------------------------------+
 class CIndCHO : public CIndicatorDE
  {
   public:
                      CIndCHO(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_CHAIKIN,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_CHAIKIN),manager.StandardIndicatorName(IND_CHAIKIN),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_CHAIKIN; }
  };
#endif // CINDCHO_MQH_DECLARATION
#endif // __INDCHAIKIN_MQH__
